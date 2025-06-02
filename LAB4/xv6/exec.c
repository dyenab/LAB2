#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
  char *s, *last;
  int i, off;
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();

  begin_op();

  if((ip = namei(path)) == 0){
    //cprintf("[exec] fail: namei('%s') returned 0\n", path);
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf)){
    //cprintf("[exec] fail: read ELF header\n");   
    goto bad;
  }  
  if(elf.magic != ELF_MAGIC){
    //cprintf("[exec] fail: bad ELF magic\n");
    goto bad;
  }  

  if((pgdir = setupkvm()) == 0){
    //cprintf("[exec] fail: setupkvm failed\n");
    goto bad;
  }  
  //cprintf("[exec] ELF entry for %s: 0x%x\n", path, elf.entry);
  // Load program into memory.
  //cprintf("[exec] checking entry mapping: VA 0x%x => KA 0x%x\n", elf.entry, (uint)uva2ka(pgdir, (char*)elf.entry));

  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    //cprintf("[exec] PH[%d] vaddr=0x%x memsz=0x%x filesz=0x%x\n", i, ph.vaddr, ph.memsz, ph.filesz);

    if(ph.memsz < ph.filesz) {
      //cprintf("[exec] fail: memsz < filesz\n");
      goto bad;
    }
    if(ph.vaddr + ph.memsz < ph.vaddr) {
      //cprintf("[exec] fail: overflow in vaddr + memsz\n");
      goto bad;
    }
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0) {
      //cprintf("[exec] fail: allocuvm failed, target=0x%x\n", ph.vaddr + ph.memsz);
      goto bad;
    }
    if(ph.vaddr % PGSIZE != 0) {
      //cprintf("[exec] fail: vaddr not aligned: 0x%x\n", ph.vaddr);
      goto bad;
    }
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0) 
      //cprintf("[exec] fail: loaduvm failed for ph[%d]\n", i);
      goto bad;
  }

  iunlockput(ip);
  end_op();
  ip = 0;

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  uint sz_program = sz;
  sz = KERNBASE - 1;
  if ((sz = allocuvm(pgdir, sz-PGSIZE, sz)) == 0) {
    cprintf("[exec] fail: stack allocuvm failed\n");
    goto bad;
  }
  sp = KERNBASE - 1;



  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0){
      //cprintf("[exec] about to copyout ustack: sp=0x%x size=%d\n", sp, (3+argc+1)*4);
      goto bad;
    }  
    ustack[3+argc] = sp;
  }

  /** for(int i = 0; i < argc; i++)
    cprintf("[exec] argv[%d] = 0x%x \"%s\"\n", i, ustack[3+i], argv[i]);

  cprintf("[exec] argc = %d\n", argc);
  cprintf("[exec] argv pointer (ustack[2]) = 0x%x\n", ustack[2]);
  cprintf("[exec] stack top (sp) = 0x%x\n", sp); **/

  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0){
    //cprintf("[exec] fail: copyout ustack failed\n");
    goto bad;
  }  

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
  curproc->pgdir = pgdir;
  curproc->sz = PGROUNDUP(sz_program);
  curproc->tf->eip = elf.entry; // main
  curproc->tf->esp = sp;
  switchuvm(curproc);
  freevm(oldpgdir);

  //cprintf("[exec] success: sz=0x%x, sp=0x%x\n", sz, sp);
  //cprintf("[exec] tf after exec: eax=0x%x esp=0x%x eip=0x%x\n", curproc->tf->eax, curproc->tf->esp, curproc->tf->eip);

  return 0;

 bad:
  //cprintf("[exec] fail: reached bad label, sz=0x%x pid=%d\n", sz, curproc->pid);

  if(pgdir)
    freevm(pgdir);
  if(ip){
    //cprintf("[exec] fail: inside cleanup\n");
    iunlockput(ip);
    end_op();
  }
  return -1;
}
