
_test3:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "user.h"
#include "pstat.h"

#define NUM_PROCS 4

void workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
    int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
    for (i = 0; i < n; i++)
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 11                	jmp    27 <workload+0x27>
        j += i * j + 1;
  16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  19:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f8             	add    %eax,-0x8(%ebp)
    for (i = 0; i < n; i++)
  23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	7c e7                	jl     16 <workload+0x16>
}
  2f:	90                   	nop
  30:	90                   	nop
  31:	c9                   	leave  
  32:	c3                   	ret    

00000033 <main>:

struct pstat st;
int main(void) {
  33:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  37:	83 e4 f0             	and    $0xfffffff0,%esp
  3a:	ff 71 fc             	push   -0x4(%ecx)
  3d:	55                   	push   %ebp
  3e:	89 e5                	mov    %esp,%ebp
  40:	53                   	push   %ebx
  41:	51                   	push   %ecx
  42:	83 ec 30             	sub    $0x30,%esp

    int pids[NUM_PROCS];

    if (setSchedPolicy(3) < 0) {
  45:	83 ec 0c             	sub    $0xc,%esp
  48:	6a 03                	push   $0x3
  4a:	e8 68 06 00 00       	call   6b7 <setSchedPolicy>
  4f:	83 c4 10             	add    $0x10,%esp
  52:	85 c0                	test   %eax,%eax
  54:	79 17                	jns    6d <main+0x3a>
        printf(1, "Failed to setSchedPolicy(3)\n");
  56:	83 ec 08             	sub    $0x8,%esp
  59:	68 4c 0b 00 00       	push   $0xb4c
  5e:	6a 01                	push   $0x1
  60:	e8 2e 07 00 00       	call   793 <printf>
  65:	83 c4 10             	add    $0x10,%esp
        exit();
  68:	e8 a2 05 00 00       	call   60f <exit>
    }

    for (int i = 0; i < NUM_PROCS; i++) {
  6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  74:	e9 b9 00 00 00       	jmp    132 <main+0xff>
        int pid = fork();
  79:	e8 89 05 00 00       	call   607 <fork>
  7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if (pid < 0) {
  81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  85:	79 1e                	jns    a5 <main+0x72>
            printf(1, "❌ fork failed for child %d\n", i + 1);
  87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8a:	83 c0 01             	add    $0x1,%eax
  8d:	83 ec 04             	sub    $0x4,%esp
  90:	50                   	push   %eax
  91:	68 69 0b 00 00       	push   $0xb69
  96:	6a 01                	push   $0x1
  98:	e8 f6 06 00 00       	call   793 <printf>
  9d:	83 c4 10             	add    $0x10,%esp
            exit();
  a0:	e8 6a 05 00 00       	call   60f <exit>
        } else if (pid == 0) {
  a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  a9:	75 60                	jne    10b <main+0xd8>
            // child process
            if (i == 0 || i == 1) {
  ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  af:	74 06                	je     b7 <main+0x84>
  b1:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  b5:	75 32                	jne    e9 <main+0xb6>
                // yield() 유도용 짧은 작업 반복
                for (int k = 0; k < 32; k++) {
  b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  be:	eb 21                	jmp    e1 <main+0xae>
                    workload(3000000);
  c0:	83 ec 0c             	sub    $0xc,%esp
  c3:	68 c0 c6 2d 00       	push   $0x2dc6c0
  c8:	e8 33 ff ff ff       	call   0 <workload>
  cd:	83 c4 10             	add    $0x10,%esp
                    sleep(10);
  d0:	83 ec 0c             	sub    $0xc,%esp
  d3:	6a 0a                	push   $0xa
  d5:	e8 c5 05 00 00       	call   69f <sleep>
  da:	83 c4 10             	add    $0x10,%esp
                for (int k = 0; k < 32; k++) {
  dd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  e1:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  e5:	7e d9                	jle    c0 <main+0x8d>
  e7:	eb 10                	jmp    f9 <main+0xc6>
                }
            } else {
                // 긴 workload로 time slice 소진 유도
                workload(150000000);
  e9:	83 ec 0c             	sub    $0xc,%esp
  ec:	68 80 d1 f0 08       	push   $0x8f0d180
  f1:	e8 0a ff ff ff       	call   0 <workload>
  f6:	83 c4 10             	add    $0x10,%esp
            }
            sleep(50);  // 너무 길지 않게 조절
  f9:	83 ec 0c             	sub    $0xc,%esp
  fc:	6a 32                	push   $0x32
  fe:	e8 9c 05 00 00       	call   69f <sleep>
 103:	83 c4 10             	add    $0x10,%esp
            exit();
 106:	e8 04 05 00 00       	call   60f <exit>
        } else {
            pids[i] = pid;
 10b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 10e:	8b 55 e0             	mov    -0x20(%ebp),%edx
 111:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
            printf(1, "[parent] child %d created, real pid = %d\n", i + 1, pid);
 115:	8b 45 f4             	mov    -0xc(%ebp),%eax
 118:	83 c0 01             	add    $0x1,%eax
 11b:	ff 75 e0             	push   -0x20(%ebp)
 11e:	50                   	push   %eax
 11f:	68 88 0b 00 00       	push   $0xb88
 124:	6a 01                	push   $0x1
 126:	e8 68 06 00 00       	call   793 <printf>
 12b:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < NUM_PROCS; i++) {
 12e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 132:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 136:	0f 8e 3d ff ff ff    	jle    79 <main+0x46>
        }
    }

    sleep(300); // 모든 프로세스가 충분히 실행되도록 대기
 13c:	83 ec 0c             	sub    $0xc,%esp
 13f:	68 2c 01 00 00       	push   $0x12c
 144:	e8 56 05 00 00       	call   69f <sleep>
 149:	83 c4 10             	add    $0x10,%esp

    if (getpinfo(&st) < 0) {
 14c:	83 ec 0c             	sub    $0xc,%esp
 14f:	68 c0 0f 00 00       	push   $0xfc0
 154:	e8 56 05 00 00       	call   6af <getpinfo>
 159:	83 c4 10             	add    $0x10,%esp
 15c:	85 c0                	test   %eax,%eax
 15e:	79 17                	jns    177 <main+0x144>
        printf(1, "getpinfo failed\n");
 160:	83 ec 08             	sub    $0x8,%esp
 163:	68 b2 0b 00 00       	push   $0xbb2
 168:	6a 01                	push   $0x1
 16a:	e8 24 06 00 00       	call   793 <printf>
 16f:	83 c4 10             	add    $0x10,%esp
        exit();
 172:	e8 98 04 00 00       	call   60f <exit>
    }

    printf(1, "\n=== MLFQ (policy 3) test result ===\n");
 177:	83 ec 08             	sub    $0x8,%esp
 17a:	68 c4 0b 00 00       	push   $0xbc4
 17f:	6a 01                	push   $0x1
 181:	e8 0d 06 00 00       	call   793 <printf>
 186:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < NPROC; i++) {
 189:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 190:	e9 fc 01 00 00       	jmp    391 <main+0x35e>
        if (!st.inuse[i])
 195:	8b 45 ec             	mov    -0x14(%ebp),%eax
 198:	8b 04 85 c0 0f 00 00 	mov    0xfc0(,%eax,4),%eax
 19f:	85 c0                	test   %eax,%eax
 1a1:	0f 84 e5 01 00 00    	je     38c <main+0x359>
            continue;

        for (int j = 0; j < NUM_PROCS; j++) {
 1a7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 1ae:	e9 cd 01 00 00       	jmp    380 <main+0x34d>
            if (st.pid[i] == pids[j]) {
 1b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1b6:	83 c0 40             	add    $0x40,%eax
 1b9:	8b 14 85 c0 0f 00 00 	mov    0xfc0(,%eax,4),%edx
 1c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1c3:	8b 44 85 d0          	mov    -0x30(%ebp,%eax,4),%eax
 1c7:	39 c2                	cmp    %eax,%edx
 1c9:	0f 85 ad 01 00 00    	jne    37c <main+0x349>
                printf(1, "pid %d | real pid %d | priority %d\n", j + 1, st.pid[i], st.priority[i]);
 1cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1d2:	83 e8 80             	sub    $0xffffff80,%eax
 1d5:	8b 14 85 c0 0f 00 00 	mov    0xfc0(,%eax,4),%edx
 1dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1df:	83 c0 40             	add    $0x40,%eax
 1e2:	8b 04 85 c0 0f 00 00 	mov    0xfc0(,%eax,4),%eax
 1e9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
 1ec:	83 c1 01             	add    $0x1,%ecx
 1ef:	83 ec 0c             	sub    $0xc,%esp
 1f2:	52                   	push   %edx
 1f3:	50                   	push   %eax
 1f4:	51                   	push   %ecx
 1f5:	68 ec 0b 00 00       	push   $0xbec
 1fa:	6a 01                	push   $0x1
 1fc:	e8 92 05 00 00       	call   793 <printf>
 201:	83 c4 20             	add    $0x20,%esp
                printf(1, "ticks      : [%d %d %d %d]\n",
 204:	8b 45 ec             	mov    -0x14(%ebp),%eax
 207:	c1 e0 04             	shl    $0x4,%eax
 20a:	05 cc 13 00 00       	add    $0x13cc,%eax
 20f:	8b 18                	mov    (%eax),%ebx
 211:	8b 45 ec             	mov    -0x14(%ebp),%eax
 214:	c1 e0 04             	shl    $0x4,%eax
 217:	05 c8 13 00 00       	add    $0x13c8,%eax
 21c:	8b 08                	mov    (%eax),%ecx
 21e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 221:	c1 e0 04             	shl    $0x4,%eax
 224:	05 c4 13 00 00       	add    $0x13c4,%eax
 229:	8b 10                	mov    (%eax),%edx
 22b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 22e:	83 c0 40             	add    $0x40,%eax
 231:	c1 e0 04             	shl    $0x4,%eax
 234:	05 c0 0f 00 00       	add    $0xfc0,%eax
 239:	8b 00                	mov    (%eax),%eax
 23b:	83 ec 08             	sub    $0x8,%esp
 23e:	53                   	push   %ebx
 23f:	51                   	push   %ecx
 240:	52                   	push   %edx
 241:	50                   	push   %eax
 242:	68 10 0c 00 00       	push   $0xc10
 247:	6a 01                	push   $0x1
 249:	e8 45 05 00 00       	call   793 <printf>
 24e:	83 c4 20             	add    $0x20,%esp
                       st.ticks[i][0], st.ticks[i][1],
                       st.ticks[i][2], st.ticks[i][3]);
                printf(1, "wait_ticks : [%d %d %d %d]\n",
 251:	8b 45 ec             	mov    -0x14(%ebp),%eax
 254:	c1 e0 04             	shl    $0x4,%eax
 257:	05 cc 17 00 00       	add    $0x17cc,%eax
 25c:	8b 18                	mov    (%eax),%ebx
 25e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 261:	c1 e0 04             	shl    $0x4,%eax
 264:	05 c8 17 00 00       	add    $0x17c8,%eax
 269:	8b 08                	mov    (%eax),%ecx
 26b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 26e:	c1 e0 04             	shl    $0x4,%eax
 271:	05 c4 17 00 00       	add    $0x17c4,%eax
 276:	8b 10                	mov    (%eax),%edx
 278:	8b 45 ec             	mov    -0x14(%ebp),%eax
 27b:	83 e8 80             	sub    $0xffffff80,%eax
 27e:	c1 e0 04             	shl    $0x4,%eax
 281:	05 c0 0f 00 00       	add    $0xfc0,%eax
 286:	8b 00                	mov    (%eax),%eax
 288:	83 ec 08             	sub    $0x8,%esp
 28b:	53                   	push   %ebx
 28c:	51                   	push   %ecx
 28d:	52                   	push   %edx
 28e:	50                   	push   %eax
 28f:	68 2c 0c 00 00       	push   $0xc2c
 294:	6a 01                	push   $0x1
 296:	e8 f8 04 00 00       	call   793 <printf>
 29b:	83 c4 20             	add    $0x20,%esp
                       st.wait_ticks[i][0], st.wait_ticks[i][1],
                       st.wait_ticks[i][2], st.wait_ticks[i][3]);
                printf(1, "total_ticks: [%d %d %d %d]\n",
 29e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2a1:	c1 e0 04             	shl    $0x4,%eax
 2a4:	05 cc 1b 00 00       	add    $0x1bcc,%eax
 2a9:	8b 18                	mov    (%eax),%ebx
 2ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2ae:	c1 e0 04             	shl    $0x4,%eax
 2b1:	05 c8 1b 00 00       	add    $0x1bc8,%eax
 2b6:	8b 08                	mov    (%eax),%ecx
 2b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2bb:	c1 e0 04             	shl    $0x4,%eax
 2be:	05 c4 1b 00 00       	add    $0x1bc4,%eax
 2c3:	8b 10                	mov    (%eax),%edx
 2c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2c8:	05 c0 00 00 00       	add    $0xc0,%eax
 2cd:	c1 e0 04             	shl    $0x4,%eax
 2d0:	05 c0 0f 00 00       	add    $0xfc0,%eax
 2d5:	8b 00                	mov    (%eax),%eax
 2d7:	83 ec 08             	sub    $0x8,%esp
 2da:	53                   	push   %ebx
 2db:	51                   	push   %ecx
 2dc:	52                   	push   %edx
 2dd:	50                   	push   %eax
 2de:	68 48 0c 00 00       	push   $0xc48
 2e3:	6a 01                	push   $0x1
 2e5:	e8 a9 04 00 00       	call   793 <printf>
 2ea:	83 c4 20             	add    $0x20,%esp
                    st.total_ticks[i][0], st.total_ticks[i][1],
                    st.total_ticks[i][2], st.total_ticks[i][3]);
                        
                if (st.total_ticks[i][3] < 8)
 2ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2f0:	c1 e0 04             	shl    $0x4,%eax
 2f3:	05 cc 1b 00 00       	add    $0x1bcc,%eax
 2f8:	8b 00                	mov    (%eax),%eax
 2fa:	83 f8 07             	cmp    $0x7,%eax
 2fd:	7f 14                	jg     313 <main+0x2e0>
                    printf(1, "✅ Q3에서 8틱 미만 실행: 자발적 양보 확인됨\n");
 2ff:	83 ec 08             	sub    $0x8,%esp
 302:	68 64 0c 00 00       	push   $0xc64
 307:	6a 01                	push   $0x1
 309:	e8 85 04 00 00       	call   793 <printf>
 30e:	83 c4 10             	add    $0x10,%esp
 311:	eb 12                	jmp    325 <main+0x2f2>
                else
                    printf(1, "❌ Q3에서 8틱 이상 실행됨: time slice 소진함\n");
 313:	83 ec 08             	sub    $0x8,%esp
 316:	68 a4 0c 00 00       	push   $0xca4
 31b:	6a 01                	push   $0x1
 31d:	e8 71 04 00 00       	call   793 <printf>
 322:	83 c4 10             	add    $0x10,%esp
                    
                if (st.priority[i] == 0)
 325:	8b 45 ec             	mov    -0x14(%ebp),%eax
 328:	83 e8 80             	sub    $0xffffff80,%eax
 32b:	8b 04 85 c0 0f 00 00 	mov    0xfc0(,%eax,4),%eax
 332:	85 c0                	test   %eax,%eax
 334:	75 14                	jne    34a <main+0x317>
                    printf(1, "✅ Q0 도달 확인 완료\n");
 336:	83 ec 08             	sub    $0x8,%esp
 339:	68 de 0c 00 00       	push   $0xcde
 33e:	6a 01                	push   $0x1
 340:	e8 4e 04 00 00       	call   793 <printf>
 345:	83 c4 10             	add    $0x10,%esp
 348:	eb 20                	jmp    36a <main+0x337>
                else
                    printf(1, "❌ 아직 Q0에 도달하지 않음 (priority = %d)\n", st.priority[i]);
 34a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 34d:	83 e8 80             	sub    $0xffffff80,%eax
 350:	8b 04 85 c0 0f 00 00 	mov    0xfc0(,%eax,4),%eax
 357:	83 ec 04             	sub    $0x4,%esp
 35a:	50                   	push   %eax
 35b:	68 fc 0c 00 00       	push   $0xcfc
 360:	6a 01                	push   $0x1
 362:	e8 2c 04 00 00       	call   793 <printf>
 367:	83 c4 10             	add    $0x10,%esp

                printf(1, "\n");
 36a:	83 ec 08             	sub    $0x8,%esp
 36d:	68 32 0d 00 00       	push   $0xd32
 372:	6a 01                	push   $0x1
 374:	e8 1a 04 00 00       	call   793 <printf>
 379:	83 c4 10             	add    $0x10,%esp
        for (int j = 0; j < NUM_PROCS; j++) {
 37c:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
 380:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
 384:	0f 8e 29 fe ff ff    	jle    1b3 <main+0x180>
 38a:	eb 01                	jmp    38d <main+0x35a>
            continue;
 38c:	90                   	nop
    for (int i = 0; i < NPROC; i++) {
 38d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 391:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
 395:	0f 8e fa fd ff ff    	jle    195 <main+0x162>
            }
        }
    }

    for (int i = 0; i < NUM_PROCS; i++)
 39b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 3a2:	eb 09                	jmp    3ad <main+0x37a>
        wait();
 3a4:	e8 6e 02 00 00       	call   617 <wait>
    for (int i = 0; i < NUM_PROCS; i++)
 3a9:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 3ad:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
 3b1:	7e f1                	jle    3a4 <main+0x371>

    exit();
 3b3:	e8 57 02 00 00       	call   60f <exit>

000003b8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3b8:	55                   	push   %ebp
 3b9:	89 e5                	mov    %esp,%ebp
 3bb:	57                   	push   %edi
 3bc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3c0:	8b 55 10             	mov    0x10(%ebp),%edx
 3c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c6:	89 cb                	mov    %ecx,%ebx
 3c8:	89 df                	mov    %ebx,%edi
 3ca:	89 d1                	mov    %edx,%ecx
 3cc:	fc                   	cld    
 3cd:	f3 aa                	rep stos %al,%es:(%edi)
 3cf:	89 ca                	mov    %ecx,%edx
 3d1:	89 fb                	mov    %edi,%ebx
 3d3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3d6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3d9:	90                   	nop
 3da:	5b                   	pop    %ebx
 3db:	5f                   	pop    %edi
 3dc:	5d                   	pop    %ebp
 3dd:	c3                   	ret    

000003de <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3de:	55                   	push   %ebp
 3df:	89 e5                	mov    %esp,%ebp
 3e1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3e4:	8b 45 08             	mov    0x8(%ebp),%eax
 3e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3ea:	90                   	nop
 3eb:	8b 55 0c             	mov    0xc(%ebp),%edx
 3ee:	8d 42 01             	lea    0x1(%edx),%eax
 3f1:	89 45 0c             	mov    %eax,0xc(%ebp)
 3f4:	8b 45 08             	mov    0x8(%ebp),%eax
 3f7:	8d 48 01             	lea    0x1(%eax),%ecx
 3fa:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3fd:	0f b6 12             	movzbl (%edx),%edx
 400:	88 10                	mov    %dl,(%eax)
 402:	0f b6 00             	movzbl (%eax),%eax
 405:	84 c0                	test   %al,%al
 407:	75 e2                	jne    3eb <strcpy+0xd>
    ;
  return os;
 409:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 40c:	c9                   	leave  
 40d:	c3                   	ret    

0000040e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 40e:	55                   	push   %ebp
 40f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 411:	eb 08                	jmp    41b <strcmp+0xd>
    p++, q++;
 413:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 417:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 41b:	8b 45 08             	mov    0x8(%ebp),%eax
 41e:	0f b6 00             	movzbl (%eax),%eax
 421:	84 c0                	test   %al,%al
 423:	74 10                	je     435 <strcmp+0x27>
 425:	8b 45 08             	mov    0x8(%ebp),%eax
 428:	0f b6 10             	movzbl (%eax),%edx
 42b:	8b 45 0c             	mov    0xc(%ebp),%eax
 42e:	0f b6 00             	movzbl (%eax),%eax
 431:	38 c2                	cmp    %al,%dl
 433:	74 de                	je     413 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 435:	8b 45 08             	mov    0x8(%ebp),%eax
 438:	0f b6 00             	movzbl (%eax),%eax
 43b:	0f b6 d0             	movzbl %al,%edx
 43e:	8b 45 0c             	mov    0xc(%ebp),%eax
 441:	0f b6 00             	movzbl (%eax),%eax
 444:	0f b6 c8             	movzbl %al,%ecx
 447:	89 d0                	mov    %edx,%eax
 449:	29 c8                	sub    %ecx,%eax
}
 44b:	5d                   	pop    %ebp
 44c:	c3                   	ret    

0000044d <strlen>:

uint
strlen(char *s)
{
 44d:	55                   	push   %ebp
 44e:	89 e5                	mov    %esp,%ebp
 450:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 453:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 45a:	eb 04                	jmp    460 <strlen+0x13>
 45c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 460:	8b 55 fc             	mov    -0x4(%ebp),%edx
 463:	8b 45 08             	mov    0x8(%ebp),%eax
 466:	01 d0                	add    %edx,%eax
 468:	0f b6 00             	movzbl (%eax),%eax
 46b:	84 c0                	test   %al,%al
 46d:	75 ed                	jne    45c <strlen+0xf>
    ;
  return n;
 46f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 472:	c9                   	leave  
 473:	c3                   	ret    

00000474 <memset>:

void*
memset(void *dst, int c, uint n)
{
 474:	55                   	push   %ebp
 475:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 477:	8b 45 10             	mov    0x10(%ebp),%eax
 47a:	50                   	push   %eax
 47b:	ff 75 0c             	push   0xc(%ebp)
 47e:	ff 75 08             	push   0x8(%ebp)
 481:	e8 32 ff ff ff       	call   3b8 <stosb>
 486:	83 c4 0c             	add    $0xc,%esp
  return dst;
 489:	8b 45 08             	mov    0x8(%ebp),%eax
}
 48c:	c9                   	leave  
 48d:	c3                   	ret    

0000048e <strchr>:

char*
strchr(const char *s, char c)
{
 48e:	55                   	push   %ebp
 48f:	89 e5                	mov    %esp,%ebp
 491:	83 ec 04             	sub    $0x4,%esp
 494:	8b 45 0c             	mov    0xc(%ebp),%eax
 497:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 49a:	eb 14                	jmp    4b0 <strchr+0x22>
    if(*s == c)
 49c:	8b 45 08             	mov    0x8(%ebp),%eax
 49f:	0f b6 00             	movzbl (%eax),%eax
 4a2:	38 45 fc             	cmp    %al,-0x4(%ebp)
 4a5:	75 05                	jne    4ac <strchr+0x1e>
      return (char*)s;
 4a7:	8b 45 08             	mov    0x8(%ebp),%eax
 4aa:	eb 13                	jmp    4bf <strchr+0x31>
  for(; *s; s++)
 4ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4b0:	8b 45 08             	mov    0x8(%ebp),%eax
 4b3:	0f b6 00             	movzbl (%eax),%eax
 4b6:	84 c0                	test   %al,%al
 4b8:	75 e2                	jne    49c <strchr+0xe>
  return 0;
 4ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4bf:	c9                   	leave  
 4c0:	c3                   	ret    

000004c1 <gets>:

char*
gets(char *buf, int max)
{
 4c1:	55                   	push   %ebp
 4c2:	89 e5                	mov    %esp,%ebp
 4c4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4ce:	eb 42                	jmp    512 <gets+0x51>
    cc = read(0, &c, 1);
 4d0:	83 ec 04             	sub    $0x4,%esp
 4d3:	6a 01                	push   $0x1
 4d5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4d8:	50                   	push   %eax
 4d9:	6a 00                	push   $0x0
 4db:	e8 47 01 00 00       	call   627 <read>
 4e0:	83 c4 10             	add    $0x10,%esp
 4e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4ea:	7e 33                	jle    51f <gets+0x5e>
      break;
    buf[i++] = c;
 4ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ef:	8d 50 01             	lea    0x1(%eax),%edx
 4f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4f5:	89 c2                	mov    %eax,%edx
 4f7:	8b 45 08             	mov    0x8(%ebp),%eax
 4fa:	01 c2                	add    %eax,%edx
 4fc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 500:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 502:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 506:	3c 0a                	cmp    $0xa,%al
 508:	74 16                	je     520 <gets+0x5f>
 50a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 50e:	3c 0d                	cmp    $0xd,%al
 510:	74 0e                	je     520 <gets+0x5f>
  for(i=0; i+1 < max; ){
 512:	8b 45 f4             	mov    -0xc(%ebp),%eax
 515:	83 c0 01             	add    $0x1,%eax
 518:	39 45 0c             	cmp    %eax,0xc(%ebp)
 51b:	7f b3                	jg     4d0 <gets+0xf>
 51d:	eb 01                	jmp    520 <gets+0x5f>
      break;
 51f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 520:	8b 55 f4             	mov    -0xc(%ebp),%edx
 523:	8b 45 08             	mov    0x8(%ebp),%eax
 526:	01 d0                	add    %edx,%eax
 528:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 52b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 52e:	c9                   	leave  
 52f:	c3                   	ret    

00000530 <stat>:

int
stat(char *n, struct stat *st)
{
 530:	55                   	push   %ebp
 531:	89 e5                	mov    %esp,%ebp
 533:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 536:	83 ec 08             	sub    $0x8,%esp
 539:	6a 00                	push   $0x0
 53b:	ff 75 08             	push   0x8(%ebp)
 53e:	e8 0c 01 00 00       	call   64f <open>
 543:	83 c4 10             	add    $0x10,%esp
 546:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 549:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 54d:	79 07                	jns    556 <stat+0x26>
    return -1;
 54f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 554:	eb 25                	jmp    57b <stat+0x4b>
  r = fstat(fd, st);
 556:	83 ec 08             	sub    $0x8,%esp
 559:	ff 75 0c             	push   0xc(%ebp)
 55c:	ff 75 f4             	push   -0xc(%ebp)
 55f:	e8 03 01 00 00       	call   667 <fstat>
 564:	83 c4 10             	add    $0x10,%esp
 567:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 56a:	83 ec 0c             	sub    $0xc,%esp
 56d:	ff 75 f4             	push   -0xc(%ebp)
 570:	e8 c2 00 00 00       	call   637 <close>
 575:	83 c4 10             	add    $0x10,%esp
  return r;
 578:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 57b:	c9                   	leave  
 57c:	c3                   	ret    

0000057d <atoi>:

int
atoi(const char *s)
{
 57d:	55                   	push   %ebp
 57e:	89 e5                	mov    %esp,%ebp
 580:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 583:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 58a:	eb 25                	jmp    5b1 <atoi+0x34>
    n = n*10 + *s++ - '0';
 58c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 58f:	89 d0                	mov    %edx,%eax
 591:	c1 e0 02             	shl    $0x2,%eax
 594:	01 d0                	add    %edx,%eax
 596:	01 c0                	add    %eax,%eax
 598:	89 c1                	mov    %eax,%ecx
 59a:	8b 45 08             	mov    0x8(%ebp),%eax
 59d:	8d 50 01             	lea    0x1(%eax),%edx
 5a0:	89 55 08             	mov    %edx,0x8(%ebp)
 5a3:	0f b6 00             	movzbl (%eax),%eax
 5a6:	0f be c0             	movsbl %al,%eax
 5a9:	01 c8                	add    %ecx,%eax
 5ab:	83 e8 30             	sub    $0x30,%eax
 5ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5b1:	8b 45 08             	mov    0x8(%ebp),%eax
 5b4:	0f b6 00             	movzbl (%eax),%eax
 5b7:	3c 2f                	cmp    $0x2f,%al
 5b9:	7e 0a                	jle    5c5 <atoi+0x48>
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	0f b6 00             	movzbl (%eax),%eax
 5c1:	3c 39                	cmp    $0x39,%al
 5c3:	7e c7                	jle    58c <atoi+0xf>
  return n;
 5c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5c8:	c9                   	leave  
 5c9:	c3                   	ret    

000005ca <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 5ca:	55                   	push   %ebp
 5cb:	89 e5                	mov    %esp,%ebp
 5cd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 5d0:	8b 45 08             	mov    0x8(%ebp),%eax
 5d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5dc:	eb 17                	jmp    5f5 <memmove+0x2b>
    *dst++ = *src++;
 5de:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5e1:	8d 42 01             	lea    0x1(%edx),%eax
 5e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ea:	8d 48 01             	lea    0x1(%eax),%ecx
 5ed:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5f0:	0f b6 12             	movzbl (%edx),%edx
 5f3:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5f5:	8b 45 10             	mov    0x10(%ebp),%eax
 5f8:	8d 50 ff             	lea    -0x1(%eax),%edx
 5fb:	89 55 10             	mov    %edx,0x10(%ebp)
 5fe:	85 c0                	test   %eax,%eax
 600:	7f dc                	jg     5de <memmove+0x14>
  return vdst;
 602:	8b 45 08             	mov    0x8(%ebp),%eax
}
 605:	c9                   	leave  
 606:	c3                   	ret    

00000607 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 607:	b8 01 00 00 00       	mov    $0x1,%eax
 60c:	cd 40                	int    $0x40
 60e:	c3                   	ret    

0000060f <exit>:
SYSCALL(exit)
 60f:	b8 02 00 00 00       	mov    $0x2,%eax
 614:	cd 40                	int    $0x40
 616:	c3                   	ret    

00000617 <wait>:
SYSCALL(wait)
 617:	b8 03 00 00 00       	mov    $0x3,%eax
 61c:	cd 40                	int    $0x40
 61e:	c3                   	ret    

0000061f <pipe>:
SYSCALL(pipe)
 61f:	b8 04 00 00 00       	mov    $0x4,%eax
 624:	cd 40                	int    $0x40
 626:	c3                   	ret    

00000627 <read>:
SYSCALL(read)
 627:	b8 05 00 00 00       	mov    $0x5,%eax
 62c:	cd 40                	int    $0x40
 62e:	c3                   	ret    

0000062f <write>:
SYSCALL(write)
 62f:	b8 10 00 00 00       	mov    $0x10,%eax
 634:	cd 40                	int    $0x40
 636:	c3                   	ret    

00000637 <close>:
SYSCALL(close)
 637:	b8 15 00 00 00       	mov    $0x15,%eax
 63c:	cd 40                	int    $0x40
 63e:	c3                   	ret    

0000063f <kill>:
SYSCALL(kill)
 63f:	b8 06 00 00 00       	mov    $0x6,%eax
 644:	cd 40                	int    $0x40
 646:	c3                   	ret    

00000647 <exec>:
SYSCALL(exec)
 647:	b8 07 00 00 00       	mov    $0x7,%eax
 64c:	cd 40                	int    $0x40
 64e:	c3                   	ret    

0000064f <open>:
SYSCALL(open)
 64f:	b8 0f 00 00 00       	mov    $0xf,%eax
 654:	cd 40                	int    $0x40
 656:	c3                   	ret    

00000657 <mknod>:
SYSCALL(mknod)
 657:	b8 11 00 00 00       	mov    $0x11,%eax
 65c:	cd 40                	int    $0x40
 65e:	c3                   	ret    

0000065f <unlink>:
SYSCALL(unlink)
 65f:	b8 12 00 00 00       	mov    $0x12,%eax
 664:	cd 40                	int    $0x40
 666:	c3                   	ret    

00000667 <fstat>:
SYSCALL(fstat)
 667:	b8 08 00 00 00       	mov    $0x8,%eax
 66c:	cd 40                	int    $0x40
 66e:	c3                   	ret    

0000066f <link>:
SYSCALL(link)
 66f:	b8 13 00 00 00       	mov    $0x13,%eax
 674:	cd 40                	int    $0x40
 676:	c3                   	ret    

00000677 <mkdir>:
SYSCALL(mkdir)
 677:	b8 14 00 00 00       	mov    $0x14,%eax
 67c:	cd 40                	int    $0x40
 67e:	c3                   	ret    

0000067f <chdir>:
SYSCALL(chdir)
 67f:	b8 09 00 00 00       	mov    $0x9,%eax
 684:	cd 40                	int    $0x40
 686:	c3                   	ret    

00000687 <dup>:
SYSCALL(dup)
 687:	b8 0a 00 00 00       	mov    $0xa,%eax
 68c:	cd 40                	int    $0x40
 68e:	c3                   	ret    

0000068f <getpid>:
SYSCALL(getpid)
 68f:	b8 0b 00 00 00       	mov    $0xb,%eax
 694:	cd 40                	int    $0x40
 696:	c3                   	ret    

00000697 <sbrk>:
SYSCALL(sbrk)
 697:	b8 0c 00 00 00       	mov    $0xc,%eax
 69c:	cd 40                	int    $0x40
 69e:	c3                   	ret    

0000069f <sleep>:
SYSCALL(sleep)
 69f:	b8 0d 00 00 00       	mov    $0xd,%eax
 6a4:	cd 40                	int    $0x40
 6a6:	c3                   	ret    

000006a7 <uptime>:
SYSCALL(uptime)
 6a7:	b8 0e 00 00 00       	mov    $0xe,%eax
 6ac:	cd 40                	int    $0x40
 6ae:	c3                   	ret    

000006af <getpinfo>:
SYSCALL(getpinfo)
 6af:	b8 16 00 00 00       	mov    $0x16,%eax
 6b4:	cd 40                	int    $0x40
 6b6:	c3                   	ret    

000006b7 <setSchedPolicy>:
 6b7:	b8 17 00 00 00       	mov    $0x17,%eax
 6bc:	cd 40                	int    $0x40
 6be:	c3                   	ret    

000006bf <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6bf:	55                   	push   %ebp
 6c0:	89 e5                	mov    %esp,%ebp
 6c2:	83 ec 18             	sub    $0x18,%esp
 6c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6cb:	83 ec 04             	sub    $0x4,%esp
 6ce:	6a 01                	push   $0x1
 6d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6d3:	50                   	push   %eax
 6d4:	ff 75 08             	push   0x8(%ebp)
 6d7:	e8 53 ff ff ff       	call   62f <write>
 6dc:	83 c4 10             	add    $0x10,%esp
}
 6df:	90                   	nop
 6e0:	c9                   	leave  
 6e1:	c3                   	ret    

000006e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6e2:	55                   	push   %ebp
 6e3:	89 e5                	mov    %esp,%ebp
 6e5:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6ef:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6f3:	74 17                	je     70c <printint+0x2a>
 6f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6f9:	79 11                	jns    70c <printint+0x2a>
    neg = 1;
 6fb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 702:	8b 45 0c             	mov    0xc(%ebp),%eax
 705:	f7 d8                	neg    %eax
 707:	89 45 ec             	mov    %eax,-0x14(%ebp)
 70a:	eb 06                	jmp    712 <printint+0x30>
  } else {
    x = xx;
 70c:	8b 45 0c             	mov    0xc(%ebp),%eax
 70f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 712:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 719:	8b 4d 10             	mov    0x10(%ebp),%ecx
 71c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 71f:	ba 00 00 00 00       	mov    $0x0,%edx
 724:	f7 f1                	div    %ecx
 726:	89 d1                	mov    %edx,%ecx
 728:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72b:	8d 50 01             	lea    0x1(%eax),%edx
 72e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 731:	0f b6 91 a4 0f 00 00 	movzbl 0xfa4(%ecx),%edx
 738:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 73c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 73f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 742:	ba 00 00 00 00       	mov    $0x0,%edx
 747:	f7 f1                	div    %ecx
 749:	89 45 ec             	mov    %eax,-0x14(%ebp)
 74c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 750:	75 c7                	jne    719 <printint+0x37>
  if(neg)
 752:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 756:	74 2d                	je     785 <printint+0xa3>
    buf[i++] = '-';
 758:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75b:	8d 50 01             	lea    0x1(%eax),%edx
 75e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 761:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 766:	eb 1d                	jmp    785 <printint+0xa3>
    putc(fd, buf[i]);
 768:	8d 55 dc             	lea    -0x24(%ebp),%edx
 76b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76e:	01 d0                	add    %edx,%eax
 770:	0f b6 00             	movzbl (%eax),%eax
 773:	0f be c0             	movsbl %al,%eax
 776:	83 ec 08             	sub    $0x8,%esp
 779:	50                   	push   %eax
 77a:	ff 75 08             	push   0x8(%ebp)
 77d:	e8 3d ff ff ff       	call   6bf <putc>
 782:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 785:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 789:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 78d:	79 d9                	jns    768 <printint+0x86>
}
 78f:	90                   	nop
 790:	90                   	nop
 791:	c9                   	leave  
 792:	c3                   	ret    

00000793 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 793:	55                   	push   %ebp
 794:	89 e5                	mov    %esp,%ebp
 796:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 799:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7a0:	8d 45 0c             	lea    0xc(%ebp),%eax
 7a3:	83 c0 04             	add    $0x4,%eax
 7a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7b0:	e9 59 01 00 00       	jmp    90e <printf+0x17b>
    c = fmt[i] & 0xff;
 7b5:	8b 55 0c             	mov    0xc(%ebp),%edx
 7b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bb:	01 d0                	add    %edx,%eax
 7bd:	0f b6 00             	movzbl (%eax),%eax
 7c0:	0f be c0             	movsbl %al,%eax
 7c3:	25 ff 00 00 00       	and    $0xff,%eax
 7c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7cf:	75 2c                	jne    7fd <printf+0x6a>
      if(c == '%'){
 7d1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7d5:	75 0c                	jne    7e3 <printf+0x50>
        state = '%';
 7d7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7de:	e9 27 01 00 00       	jmp    90a <printf+0x177>
      } else {
        putc(fd, c);
 7e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7e6:	0f be c0             	movsbl %al,%eax
 7e9:	83 ec 08             	sub    $0x8,%esp
 7ec:	50                   	push   %eax
 7ed:	ff 75 08             	push   0x8(%ebp)
 7f0:	e8 ca fe ff ff       	call   6bf <putc>
 7f5:	83 c4 10             	add    $0x10,%esp
 7f8:	e9 0d 01 00 00       	jmp    90a <printf+0x177>
      }
    } else if(state == '%'){
 7fd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 801:	0f 85 03 01 00 00    	jne    90a <printf+0x177>
      if(c == 'd'){
 807:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 80b:	75 1e                	jne    82b <printf+0x98>
        printint(fd, *ap, 10, 1);
 80d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	6a 01                	push   $0x1
 814:	6a 0a                	push   $0xa
 816:	50                   	push   %eax
 817:	ff 75 08             	push   0x8(%ebp)
 81a:	e8 c3 fe ff ff       	call   6e2 <printint>
 81f:	83 c4 10             	add    $0x10,%esp
        ap++;
 822:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 826:	e9 d8 00 00 00       	jmp    903 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 82b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 82f:	74 06                	je     837 <printf+0xa4>
 831:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 835:	75 1e                	jne    855 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 837:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83a:	8b 00                	mov    (%eax),%eax
 83c:	6a 00                	push   $0x0
 83e:	6a 10                	push   $0x10
 840:	50                   	push   %eax
 841:	ff 75 08             	push   0x8(%ebp)
 844:	e8 99 fe ff ff       	call   6e2 <printint>
 849:	83 c4 10             	add    $0x10,%esp
        ap++;
 84c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 850:	e9 ae 00 00 00       	jmp    903 <printf+0x170>
      } else if(c == 's'){
 855:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 859:	75 43                	jne    89e <printf+0x10b>
        s = (char*)*ap;
 85b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 85e:	8b 00                	mov    (%eax),%eax
 860:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 863:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 867:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 86b:	75 25                	jne    892 <printf+0xff>
          s = "(null)";
 86d:	c7 45 f4 34 0d 00 00 	movl   $0xd34,-0xc(%ebp)
        while(*s != 0){
 874:	eb 1c                	jmp    892 <printf+0xff>
          putc(fd, *s);
 876:	8b 45 f4             	mov    -0xc(%ebp),%eax
 879:	0f b6 00             	movzbl (%eax),%eax
 87c:	0f be c0             	movsbl %al,%eax
 87f:	83 ec 08             	sub    $0x8,%esp
 882:	50                   	push   %eax
 883:	ff 75 08             	push   0x8(%ebp)
 886:	e8 34 fe ff ff       	call   6bf <putc>
 88b:	83 c4 10             	add    $0x10,%esp
          s++;
 88e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 892:	8b 45 f4             	mov    -0xc(%ebp),%eax
 895:	0f b6 00             	movzbl (%eax),%eax
 898:	84 c0                	test   %al,%al
 89a:	75 da                	jne    876 <printf+0xe3>
 89c:	eb 65                	jmp    903 <printf+0x170>
        }
      } else if(c == 'c'){
 89e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8a2:	75 1d                	jne    8c1 <printf+0x12e>
        putc(fd, *ap);
 8a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8a7:	8b 00                	mov    (%eax),%eax
 8a9:	0f be c0             	movsbl %al,%eax
 8ac:	83 ec 08             	sub    $0x8,%esp
 8af:	50                   	push   %eax
 8b0:	ff 75 08             	push   0x8(%ebp)
 8b3:	e8 07 fe ff ff       	call   6bf <putc>
 8b8:	83 c4 10             	add    $0x10,%esp
        ap++;
 8bb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8bf:	eb 42                	jmp    903 <printf+0x170>
      } else if(c == '%'){
 8c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8c5:	75 17                	jne    8de <printf+0x14b>
        putc(fd, c);
 8c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ca:	0f be c0             	movsbl %al,%eax
 8cd:	83 ec 08             	sub    $0x8,%esp
 8d0:	50                   	push   %eax
 8d1:	ff 75 08             	push   0x8(%ebp)
 8d4:	e8 e6 fd ff ff       	call   6bf <putc>
 8d9:	83 c4 10             	add    $0x10,%esp
 8dc:	eb 25                	jmp    903 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8de:	83 ec 08             	sub    $0x8,%esp
 8e1:	6a 25                	push   $0x25
 8e3:	ff 75 08             	push   0x8(%ebp)
 8e6:	e8 d4 fd ff ff       	call   6bf <putc>
 8eb:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8f1:	0f be c0             	movsbl %al,%eax
 8f4:	83 ec 08             	sub    $0x8,%esp
 8f7:	50                   	push   %eax
 8f8:	ff 75 08             	push   0x8(%ebp)
 8fb:	e8 bf fd ff ff       	call   6bf <putc>
 900:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 903:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 90a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 90e:	8b 55 0c             	mov    0xc(%ebp),%edx
 911:	8b 45 f0             	mov    -0x10(%ebp),%eax
 914:	01 d0                	add    %edx,%eax
 916:	0f b6 00             	movzbl (%eax),%eax
 919:	84 c0                	test   %al,%al
 91b:	0f 85 94 fe ff ff    	jne    7b5 <printf+0x22>
    }
  }
}
 921:	90                   	nop
 922:	90                   	nop
 923:	c9                   	leave  
 924:	c3                   	ret    

00000925 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 925:	55                   	push   %ebp
 926:	89 e5                	mov    %esp,%ebp
 928:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 92b:	8b 45 08             	mov    0x8(%ebp),%eax
 92e:	83 e8 08             	sub    $0x8,%eax
 931:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 934:	a1 c8 1f 00 00       	mov    0x1fc8,%eax
 939:	89 45 fc             	mov    %eax,-0x4(%ebp)
 93c:	eb 24                	jmp    962 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 93e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 941:	8b 00                	mov    (%eax),%eax
 943:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 946:	72 12                	jb     95a <free+0x35>
 948:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 94e:	77 24                	ja     974 <free+0x4f>
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
 953:	8b 00                	mov    (%eax),%eax
 955:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 958:	72 1a                	jb     974 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 95a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95d:	8b 00                	mov    (%eax),%eax
 95f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 962:	8b 45 f8             	mov    -0x8(%ebp),%eax
 965:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 968:	76 d4                	jbe    93e <free+0x19>
 96a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96d:	8b 00                	mov    (%eax),%eax
 96f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 972:	73 ca                	jae    93e <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 974:	8b 45 f8             	mov    -0x8(%ebp),%eax
 977:	8b 40 04             	mov    0x4(%eax),%eax
 97a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 981:	8b 45 f8             	mov    -0x8(%ebp),%eax
 984:	01 c2                	add    %eax,%edx
 986:	8b 45 fc             	mov    -0x4(%ebp),%eax
 989:	8b 00                	mov    (%eax),%eax
 98b:	39 c2                	cmp    %eax,%edx
 98d:	75 24                	jne    9b3 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 98f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 992:	8b 50 04             	mov    0x4(%eax),%edx
 995:	8b 45 fc             	mov    -0x4(%ebp),%eax
 998:	8b 00                	mov    (%eax),%eax
 99a:	8b 40 04             	mov    0x4(%eax),%eax
 99d:	01 c2                	add    %eax,%edx
 99f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a2:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a8:	8b 00                	mov    (%eax),%eax
 9aa:	8b 10                	mov    (%eax),%edx
 9ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9af:	89 10                	mov    %edx,(%eax)
 9b1:	eb 0a                	jmp    9bd <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b6:	8b 10                	mov    (%eax),%edx
 9b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bb:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c0:	8b 40 04             	mov    0x4(%eax),%eax
 9c3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cd:	01 d0                	add    %edx,%eax
 9cf:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9d2:	75 20                	jne    9f4 <free+0xcf>
    p->s.size += bp->s.size;
 9d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d7:	8b 50 04             	mov    0x4(%eax),%edx
 9da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9dd:	8b 40 04             	mov    0x4(%eax),%eax
 9e0:	01 c2                	add    %eax,%edx
 9e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9eb:	8b 10                	mov    (%eax),%edx
 9ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f0:	89 10                	mov    %edx,(%eax)
 9f2:	eb 08                	jmp    9fc <free+0xd7>
  } else
    p->s.ptr = bp;
 9f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9fa:	89 10                	mov    %edx,(%eax)
  freep = p;
 9fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ff:	a3 c8 1f 00 00       	mov    %eax,0x1fc8
}
 a04:	90                   	nop
 a05:	c9                   	leave  
 a06:	c3                   	ret    

00000a07 <morecore>:

static Header*
morecore(uint nu)
{
 a07:	55                   	push   %ebp
 a08:	89 e5                	mov    %esp,%ebp
 a0a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a0d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a14:	77 07                	ja     a1d <morecore+0x16>
    nu = 4096;
 a16:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a1d:	8b 45 08             	mov    0x8(%ebp),%eax
 a20:	c1 e0 03             	shl    $0x3,%eax
 a23:	83 ec 0c             	sub    $0xc,%esp
 a26:	50                   	push   %eax
 a27:	e8 6b fc ff ff       	call   697 <sbrk>
 a2c:	83 c4 10             	add    $0x10,%esp
 a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a32:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a36:	75 07                	jne    a3f <morecore+0x38>
    return 0;
 a38:	b8 00 00 00 00       	mov    $0x0,%eax
 a3d:	eb 26                	jmp    a65 <morecore+0x5e>
  hp = (Header*)p;
 a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a48:	8b 55 08             	mov    0x8(%ebp),%edx
 a4b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a51:	83 c0 08             	add    $0x8,%eax
 a54:	83 ec 0c             	sub    $0xc,%esp
 a57:	50                   	push   %eax
 a58:	e8 c8 fe ff ff       	call   925 <free>
 a5d:	83 c4 10             	add    $0x10,%esp
  return freep;
 a60:	a1 c8 1f 00 00       	mov    0x1fc8,%eax
}
 a65:	c9                   	leave  
 a66:	c3                   	ret    

00000a67 <malloc>:

void*
malloc(uint nbytes)
{
 a67:	55                   	push   %ebp
 a68:	89 e5                	mov    %esp,%ebp
 a6a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a6d:	8b 45 08             	mov    0x8(%ebp),%eax
 a70:	83 c0 07             	add    $0x7,%eax
 a73:	c1 e8 03             	shr    $0x3,%eax
 a76:	83 c0 01             	add    $0x1,%eax
 a79:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a7c:	a1 c8 1f 00 00       	mov    0x1fc8,%eax
 a81:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a88:	75 23                	jne    aad <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a8a:	c7 45 f0 c0 1f 00 00 	movl   $0x1fc0,-0x10(%ebp)
 a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a94:	a3 c8 1f 00 00       	mov    %eax,0x1fc8
 a99:	a1 c8 1f 00 00       	mov    0x1fc8,%eax
 a9e:	a3 c0 1f 00 00       	mov    %eax,0x1fc0
    base.s.size = 0;
 aa3:	c7 05 c4 1f 00 00 00 	movl   $0x0,0x1fc4
 aaa:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab0:	8b 00                	mov    (%eax),%eax
 ab2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab8:	8b 40 04             	mov    0x4(%eax),%eax
 abb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 abe:	77 4d                	ja     b0d <malloc+0xa6>
      if(p->s.size == nunits)
 ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac3:	8b 40 04             	mov    0x4(%eax),%eax
 ac6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ac9:	75 0c                	jne    ad7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ace:	8b 10                	mov    (%eax),%edx
 ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad3:	89 10                	mov    %edx,(%eax)
 ad5:	eb 26                	jmp    afd <malloc+0x96>
      else {
        p->s.size -= nunits;
 ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ada:	8b 40 04             	mov    0x4(%eax),%eax
 add:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ae0:	89 c2                	mov    %eax,%edx
 ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aeb:	8b 40 04             	mov    0x4(%eax),%eax
 aee:	c1 e0 03             	shl    $0x3,%eax
 af1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 afa:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b00:	a3 c8 1f 00 00       	mov    %eax,0x1fc8
      return (void*)(p + 1);
 b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b08:	83 c0 08             	add    $0x8,%eax
 b0b:	eb 3b                	jmp    b48 <malloc+0xe1>
    }
    if(p == freep)
 b0d:	a1 c8 1f 00 00       	mov    0x1fc8,%eax
 b12:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b15:	75 1e                	jne    b35 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b17:	83 ec 0c             	sub    $0xc,%esp
 b1a:	ff 75 ec             	push   -0x14(%ebp)
 b1d:	e8 e5 fe ff ff       	call   a07 <morecore>
 b22:	83 c4 10             	add    $0x10,%esp
 b25:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b2c:	75 07                	jne    b35 <malloc+0xce>
        return 0;
 b2e:	b8 00 00 00 00       	mov    $0x0,%eax
 b33:	eb 13                	jmp    b48 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b38:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3e:	8b 00                	mov    (%eax),%eax
 b40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b43:	e9 6d ff ff ff       	jmp    ab5 <malloc+0x4e>
  }
}
 b48:	c9                   	leave  
 b49:	c3                   	ret    
