#include "types.h"
#include "stat.h"
#include "user.h"

/* Possible states of a thread; */
#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2
#define WAIT        0x3

#define STACK_SIZE  8192
#define MAX_THREAD  10

typedef struct thread thread_t, *thread_p;
typedef struct mutex mutex_t, *mutex_p;

struct thread {
  int        sp;                /* saved stack pointer */
  char stack[STACK_SIZE];       /* the thread's stack */
  int        state;             /* FREE, RUNNING, RUNNABLE, WAIT */
  int        tid;    /* thread id */
  int        ptid;  /* parent thread id */
};
static thread_t all_thread[MAX_THREAD];
thread_p  current_thread;
thread_p  next_thread;
extern void thread_switch(void);
extern void thread_schedule(void);
extern int thread_inc(void);
extern int thread_dec(void);

void 
thread_init(void)
{
  uthread_init((int)thread_schedule);

  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
  current_thread->tid=0;
  current_thread->ptid=0;
}

void 
thread_schedule(void)
{ 
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == RUNNABLE && t != current_thread) {
      next_thread = t;
      break;
    }
  }
  
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  }

  if (next_thread == 0) {
    if(current_thread->state==RUNNING){
      next_thread = current_thread;
    } else {  
    printf(2, "thread_schedule: no runnable threads\n");
    exit();
    }
  }

  if (current_thread != next_thread) {         /* switch threads?  */
    next_thread->state = RUNNING;
    if(current_thread != &all_thread[0]&&current_thread->state==RUNNING){ 
      current_thread->state=RUNNABLE;
    } 
    thread_switch();
  } else
    next_thread = 0;
}

void 
thread_create(void (*func)())
{
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
  t->sp -= 4;                              // space for return address
  
  t->tid = t - all_thread;                 //child id = 배열 인덱스
  t->ptid = current_thread->tid;           //parent id = 
  
  * (int *) (t->sp) = (int)func;           // push return address on stack
  t->sp -= 28;                             // space for registers that thread_switch expects
  t->state = RUNNABLE;
  thread_inc();
}

static void 
thread_join_all(void)
{
  while(1){
    int has_child = 0;
    for (int i = 0; i < MAX_THREAD; i++){
      if(all_thread[i].ptid==current_thread->tid&&all_thread[i].state!=FREE){
        has_child = 1;
        break;
      }  
    }
    if (!has_child){
      all_thread[1].state = RUNNABLE;
      return ;
    }  
  
    current_thread->state = WAIT;
    thread_schedule();
  }  
}

static void wake_parent(void){
  int last_child = 0;
  for(int i = 0; i < MAX_THREAD; i++){
    if(all_thread[i].state !=FREE && all_thread[i].state !=WAIT){
      last_child = 1;
      break;
    }

  }
  if(!last_child){
    for(int i = 0; i<MAX_THREAD; i++){
      if(all_thread[i].tid == current_thread->ptid && all_thread[i].state==WAIT){
        all_thread[i].state = RUNNABLE;
        break;
      }
    }
  }
} 

static void 
child_thread(void)
{
  int i;
  printf(1, "child thread running\n");
  for (i = 0; i < 100; i++) {
    printf(1, "child thread 0x%x\n", (int) current_thread);
  }
  printf(1, "child thread: exit\n");
  current_thread->state = FREE;
  thread_dec();
  wake_parent();
  thread_schedule();
}

void 
mythread(void)
{
  int i;
  printf(1, "my thread running\n");
  for (i = 0; i < 5; i++) {
    thread_create(child_thread);
  }
  thread_join_all();
  printf(1, "my thread: exit\n");
  current_thread->state = FREE;
  thread_dec();
  thread_schedule();
}

int 
main(int argc, char *argv[]) 
{
  thread_init();
  thread_create(mythread);
  thread_join_all();
  return 0;
}
