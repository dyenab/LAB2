#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"
#include "i8254.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;
int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);
pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 0xB:
    i8254_intr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;

  case T_PGFLT: {
    uint fault_va = rcr2();
    uint va = PGROUNDDOWN(fault_va);
    struct proc *p = myproc();
    //cprintf("trap 14\n");
    //cprintf("[trap] page fault pid=%d name=%s va=0x%x eip=0x%x esp=0x%x\n", p ? p->pid : -1, p ? p->name : "(null)", fault_va, tf->eip, tf->esp); 
    
    if (p == 0)
      panic("page fault with no process");

    /**if (va >= p->sz) {
      p->killed = 1;
      break;
    } **/
    
    char *mem = kalloc();
    if (mem == 0) {
      cprintf("trap: out of memory\n");
      p->killed = 1;
      break;
    }
    memset(mem, 0, PGSIZE);
    if (mappages(p->pgdir, (char*)va, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
      kfree(mem);
      cprintf("kill kfree(mem)\n");
      p->killed = 1;
      break;
    }
    if (va + PGSIZE > p->sz)
      p->sz = va + PGSIZE;

    lcr3(V2P(p->pgdir));
    return;

  }

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }

    // In user space, unexpected trap: print extra diagnostics
    struct proc *p = myproc();
    uint eip = tf->eip;
    uint esp = tf->esp;
    cprintf("pid %d %s: trap %d err %d on cpu %d eip 0x%x addr 0x%x--kill proc\n",
            p->pid, p->name, tf->trapno, tf->err, cpuid(), eip, rcr2());

    pte_t *pte_eip = walkpgdir(p->pgdir, (void*)eip, 0);
    if (pte_eip && (*pte_eip & PTE_P)) {
      cprintf("  [trap] eip 0x%x is mapped to PA: 0x%x, flags=0x%x\n",
              eip, PTE_ADDR(*pte_eip), PTE_FLAGS(*pte_eip));
    } else {
      cprintf("  [trap] eip 0x%x is NOT mapped!\n", eip);
    }

    pte_t *pte_esp = walkpgdir(p->pgdir, (void*)esp, 0);
    if (pte_esp && (*pte_esp & PTE_P)) {
      cprintf("  [trap] esp 0x%x is mapped to PA: 0x%x, flags=0x%x\n",
              esp, PTE_ADDR(*pte_esp), PTE_FLAGS(*pte_esp));
    } else {
      cprintf("  [trap] esp 0x%x is NOT mapped!\n", esp);
    }

    p->killed = 1;
    break;
  }  
  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}

