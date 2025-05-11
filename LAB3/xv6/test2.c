#include "types.h"
#include "user.h"
#include "pstat.h"

#define N 4

int workload(int n)
{
    volatile int i, j = 0;
    for (i = 0; i < n; i++)
        j += i * j + 1;
    return j;
}

struct pstat st;
int main(void)
{
    
    int pids[N];
    int i;

    if (setSchedPolicy(2) < 0) {
        printf(1, "Failed to setSchedPolicy(2)\n");
        exit();
    }

    for (i = 0; i < N; i++) {
        int pid = fork();
        if (pid < 0) {
            printf(1, "Fork failed\n");
            exit();
        } else if (pid == 0) {
            // Child
            if (pid == 0) {
                // 자식 프로세스는 딱 50번만 실행
                for (int k = 0; k < 50; k++) {
                    if (i == 0) {
                        workload(300000); // Q3
                        sleep(10);
                    } else if (i == 1) {
                        workload(5000000); // Q2
                        sleep(3);
                    } else if (i == 2) {
                        workload(10000000); // Q1
                        if (k % 3 == 0)
                            sleep(3);
                    } else {
                        workload(500000000); // Q0
                    }
                }
                exit(); 
            }
            
        } else {
            pids[i] = pid;
        }
    }

    sleep(5000); // 충분히 실행 후 확인


    if (getpinfo(&st) < 0) {
        printf(1, "getpinfo failed\n");
        exit();
    }

    printf(1, "\n=== MLFQ (policy 2) test result ===\n");
    for (i = 0; i < NPROC; i++) {
        if (!st.inuse[i])
            continue;
        for (int j = 0; j < N; j++) {
            if (st.pid[i] == pids[j]) {
                printf(1, "Process %d (PID %d): priority %d\n", j + 1, st.pid[i], st.priority[i]);
                printf(1, "  TICKS      : [%d %d %d %d]\n",
                       st.ticks[i][0], st.ticks[i][1],
                       st.ticks[i][2], st.ticks[i][3]);
                printf(1, "  WAIT_TICKS : [%d %d %d %d]\n",
                       st.wait_ticks[i][0], st.wait_ticks[i][1],
                       st.wait_ticks[i][2], st.wait_ticks[i][3]);
                printf(1, "\n");
            }
        }
    }

    for (i = 0; i < N; i++)
    {
        kill(pids[i]);
    }
    for (i = 0; i < N; i++)
    {
        wait();
    }

    printf(1, "[TEST DONE] Hit Ctrl-a x to exit QEMU\n");
    exit();
}


