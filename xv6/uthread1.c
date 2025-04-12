#include "types.h"
#include "stat.h"
#include "user.h"

#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2

#define STACK_SIZE  8192
#define MAX_THREAD  4

typedef struct thread {
  int sp;
  char stack[STACK_SIZE];
  int state;
} thread_t, *thread_p;

static thread_t all_thread[MAX_THREAD];
thread_p current_thread;
thread_p next_thread;

extern void thread_switch(void);  // asm에서 정의됨
extern void uthread_init(int);    // usys.S 통해 syscall 등록됨

// cooperative scheduler
static void thread_schedule(void)
{
  thread_p t;
  next_thread = 0;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == RUNNABLE && t != current_thread) {
      next_thread = t;
      break;
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
    next_thread = current_thread;
  }

  if (next_thread == 0) {
    // 모든 스레드가 FREE 상태 → 종료
    exit();  
  }

  if (current_thread != next_thread) {
    next_thread->state = RUNNING;
    current_thread->state = RUNNABLE;
    thread_switch();
  } else {
    next_thread = 0;
  }
}

// 쓰레드 초기화
void thread_init(void)
{
  uthread_init((int)thread_schedule);
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
}

// 쓰레드 생성 (thread_exit 없이!)
void thread_create(void (*func)())
{
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }

  if (t == all_thread + MAX_THREAD) return;

  t->sp = (int)(t->stack + STACK_SIZE);

  // ✅ func() 끝나면 thread_schedule()로 리턴
  t->sp -= 4;
  *(int *)(t->sp) = (int)thread_schedule;

  // ✅ 첫 진입 지점 (ret → func)
  t->sp -= 4;
  *(int *)(t->sp) = (int)func;

  // ✅ pushal/popall 공간
  t->sp -= 28;

  t->state = RUNNABLE;
}

// 테스트용 쓰레드 함수
static void mythread(void)
{
  int i;
  for (i = 0; i < 1000000; i++) {
    // dummy 연산으로 시간 보내기
    int x = i * i;
    if (i % 200000 == 0) {
      thread_schedule();  // cooperative yield
    }
  }
  // 스레드 종료
  current_thread->state = FREE;
  thread_schedule();
}

// main
int main(int argc, char *argv[])
{
  thread_init();
  thread_create(mythread);
  thread_create(mythread);
  thread_schedule();
  exit();
}