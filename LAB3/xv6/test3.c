#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

#define NUM_PROCS 4

void workload(int n) {
    int i, j = 0;
    for (i = 0; i < n; i++)
        j += i * j + 1;
}

struct pstat st;
int main(void) {

    int pids[NUM_PROCS];

    if (setSchedPolicy(3) < 0) {
        printf(1, "Failed to setSchedPolicy(3)\n");
        exit();
    }

    for (int i = 0; i < NUM_PROCS; i++) {
        int pid = fork();
        if (pid < 0) {
            exit();
        } else if (pid == 0) {
            // child process
            if (i == 0 || i == 1) {
                // yield() 유도용 짧은 작업 반복
                for (int k = 0; k < 32; k++) {
                    workload(3000000);
                    sleep(10);
                }
            } else {
                // 긴 workload로 time slice 소진 유도
                workload(150000000);
            }
            sleep(50);  // 너무 길지 않게 조절
            exit();
        } else {
            pids[i] = pid;
            printf(1, "[parent] child %d created, real pid = %d\n", i + 1, pid);
        }
    }

    sleep(300); // 모든 프로세스가 충분히 실행되도록 대기

    if (getpinfo(&st) < 0) {
        printf(1, "getpinfo failed\n");
        exit();
    }

    printf(1, "\n=== MLFQ (policy 3) test result ===\n");
    for (int i = 0; i < NPROC; i++) {
        if (!st.inuse[i])
            continue;

        for (int j = 0; j < NUM_PROCS; j++) {
            if (st.pid[i] == pids[j]) {
                printf(1, "pid %d | real pid %d | priority %d\n", j + 1, st.pid[i], st.priority[i]);
                printf(1, "ticks      : [%d %d %d %d]\n",
                       st.ticks[i][0], st.ticks[i][1],
                       st.ticks[i][2], st.ticks[i][3]);
                printf(1, "wait_ticks : [%d %d %d %d]\n",
                       st.wait_ticks[i][0], st.wait_ticks[i][1],
                       st.wait_ticks[i][2], st.wait_ticks[i][3]);
                printf(1, "total_ticks: [%d %d %d %d]\n",
                    st.total_ticks[i][0], st.total_ticks[i][1],
                    st.total_ticks[i][2], st.total_ticks[i][3]);
                printf(1, "\n");
            }
        }
    }

    for (int i = 0; i < NUM_PROCS; i++)
        wait();

    exit();
}

