
_test2:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "pstat.h"

#define N 4

int workload(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
    volatile int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
    for (i = 0; i < n; i++)
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 1d                	jmp    33 <workload+0x33>
        j += i * j + 1;
  16:	8b 55 fc             	mov    -0x4(%ebp),%edx
  19:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1c:	0f af c2             	imul   %edx,%eax
  1f:	8d 50 01             	lea    0x1(%eax),%edx
  22:	8b 45 f8             	mov    -0x8(%ebp),%eax
  25:	01 d0                	add    %edx,%eax
  27:	89 45 f8             	mov    %eax,-0x8(%ebp)
    for (i = 0; i < n; i++)
  2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2d:	83 c0 01             	add    $0x1,%eax
  30:	89 45 fc             	mov    %eax,-0x4(%ebp)
  33:	8b 45 fc             	mov    -0x4(%ebp),%eax
  36:	39 45 08             	cmp    %eax,0x8(%ebp)
  39:	7f db                	jg     16 <workload+0x16>
    return j;
  3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  3e:	c9                   	leave  
  3f:	c3                   	ret    

00000040 <main>:

struct pstat st;
int main(void)
{
  40:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  44:	83 e4 f0             	and    $0xfffffff0,%esp
  47:	ff 71 fc             	push   -0x4(%ecx)
  4a:	55                   	push   %ebp
  4b:	89 e5                	mov    %esp,%ebp
  4d:	53                   	push   %ebx
  4e:	51                   	push   %ecx
  4f:	83 ec 20             	sub    $0x20,%esp
    
    int pids[N];
    int i;

    if (setSchedPolicy(2) < 0) {
  52:	83 ec 0c             	sub    $0xc,%esp
  55:	6a 02                	push   $0x2
  57:	e8 07 06 00 00       	call   663 <setSchedPolicy>
  5c:	83 c4 10             	add    $0x10,%esp
  5f:	85 c0                	test   %eax,%eax
  61:	79 17                	jns    7a <main+0x3a>
        printf(1, "Failed to setSchedPolicy(2)\n");
  63:	83 ec 08             	sub    $0x8,%esp
  66:	68 00 0b 00 00       	push   $0xb00
  6b:	6a 01                	push   $0x1
  6d:	e8 d5 06 00 00       	call   747 <printf>
  72:	83 c4 10             	add    $0x10,%esp
        exit();
  75:	e8 41 05 00 00       	call   5bb <exit>
    }

    for (i = 0; i < N; i++) {
  7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  81:	e9 fe 00 00 00       	jmp    184 <main+0x144>
        int pid = fork();
  86:	e8 28 05 00 00       	call   5b3 <fork>
  8b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (pid < 0) {
  8e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  92:	79 17                	jns    ab <main+0x6b>
            printf(1, "Fork failed\n");
  94:	83 ec 08             	sub    $0x8,%esp
  97:	68 1d 0b 00 00       	push   $0xb1d
  9c:	6a 01                	push   $0x1
  9e:	e8 a4 06 00 00       	call   747 <printf>
  a3:	83 c4 10             	add    $0x10,%esp
            exit();
  a6:	e8 10 05 00 00       	call   5bb <exit>
        } else if (pid == 0) {
  ab:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  af:	0f 85 c1 00 00 00    	jne    176 <main+0x136>
            // Child
            while (1) {
                for (int k = 0; k < 50; k++) {
  b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  bc:	e9 a6 00 00 00       	jmp    167 <main+0x127>
                    if (i == 0) {
  c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  c5:	75 1f                	jne    e6 <main+0xa6>
                        workload(300000); // Q3
  c7:	83 ec 0c             	sub    $0xc,%esp
  ca:	68 e0 93 04 00       	push   $0x493e0
  cf:	e8 2c ff ff ff       	call   0 <workload>
  d4:	83 c4 10             	add    $0x10,%esp
                        sleep(10);
  d7:	83 ec 0c             	sub    $0xc,%esp
  da:	6a 0a                	push   $0xa
  dc:	e8 6a 05 00 00       	call   64b <sleep>
  e1:	83 c4 10             	add    $0x10,%esp
  e4:	eb 7d                	jmp    163 <main+0x123>
                    } else if (i == 1) {
  e6:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  ea:	75 1f                	jne    10b <main+0xcb>
                        workload(5000000); // Q2
  ec:	83 ec 0c             	sub    $0xc,%esp
  ef:	68 40 4b 4c 00       	push   $0x4c4b40
  f4:	e8 07 ff ff ff       	call   0 <workload>
  f9:	83 c4 10             	add    $0x10,%esp
                        sleep(3);
  fc:	83 ec 0c             	sub    $0xc,%esp
  ff:	6a 03                	push   $0x3
 101:	e8 45 05 00 00       	call   64b <sleep>
 106:	83 c4 10             	add    $0x10,%esp
 109:	eb 58                	jmp    163 <main+0x123>
                    } else if (i == 2) {
 10b:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 10f:	75 42                	jne    153 <main+0x113>
                        workload(10000000); // Q1
 111:	83 ec 0c             	sub    $0xc,%esp
 114:	68 80 96 98 00       	push   $0x989680
 119:	e8 e2 fe ff ff       	call   0 <workload>
 11e:	83 c4 10             	add    $0x10,%esp
                        if (k % 3 == 0)
 121:	8b 4d f0             	mov    -0x10(%ebp),%ecx
 124:	ba 56 55 55 55       	mov    $0x55555556,%edx
 129:	89 c8                	mov    %ecx,%eax
 12b:	f7 ea                	imul   %edx
 12d:	89 cb                	mov    %ecx,%ebx
 12f:	c1 fb 1f             	sar    $0x1f,%ebx
 132:	89 d0                	mov    %edx,%eax
 134:	29 d8                	sub    %ebx,%eax
 136:	89 c2                	mov    %eax,%edx
 138:	01 d2                	add    %edx,%edx
 13a:	01 c2                	add    %eax,%edx
 13c:	89 c8                	mov    %ecx,%eax
 13e:	29 d0                	sub    %edx,%eax
 140:	85 c0                	test   %eax,%eax
 142:	75 1f                	jne    163 <main+0x123>
                            sleep(3);
 144:	83 ec 0c             	sub    $0xc,%esp
 147:	6a 03                	push   $0x3
 149:	e8 fd 04 00 00       	call   64b <sleep>
 14e:	83 c4 10             	add    $0x10,%esp
 151:	eb 10                	jmp    163 <main+0x123>
                    } else {
                        workload(500000000); // Q0
 153:	83 ec 0c             	sub    $0xc,%esp
 156:	68 00 65 cd 1d       	push   $0x1dcd6500
 15b:	e8 a0 fe ff ff       	call   0 <workload>
 160:	83 c4 10             	add    $0x10,%esp
                for (int k = 0; k < 50; k++) {
 163:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 167:	83 7d f0 31          	cmpl   $0x31,-0x10(%ebp)
 16b:	0f 8e 50 ff ff ff    	jle    c1 <main+0x81>
 171:	e9 3f ff ff ff       	jmp    b5 <main+0x75>
                    }
                }
            }

        } else {
            pids[i] = pid;
 176:	8b 45 f4             	mov    -0xc(%ebp),%eax
 179:	8b 55 e8             	mov    -0x18(%ebp),%edx
 17c:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
    for (i = 0; i < N; i++) {
 180:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 184:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 188:	0f 8e f8 fe ff ff    	jle    86 <main+0x46>
        }
    }

    sleep(5000); // 충분히 실행 후 확인
 18e:	83 ec 0c             	sub    $0xc,%esp
 191:	68 88 13 00 00       	push   $0x1388
 196:	e8 b0 04 00 00       	call   64b <sleep>
 19b:	83 c4 10             	add    $0x10,%esp


    if (getpinfo(&st) < 0) {
 19e:	83 ec 0c             	sub    $0xc,%esp
 1a1:	68 60 0e 00 00       	push   $0xe60
 1a6:	e8 b0 04 00 00       	call   65b <getpinfo>
 1ab:	83 c4 10             	add    $0x10,%esp
 1ae:	85 c0                	test   %eax,%eax
 1b0:	79 17                	jns    1c9 <main+0x189>
        printf(1, "getpinfo failed\n");
 1b2:	83 ec 08             	sub    $0x8,%esp
 1b5:	68 2a 0b 00 00       	push   $0xb2a
 1ba:	6a 01                	push   $0x1
 1bc:	e8 86 05 00 00       	call   747 <printf>
 1c1:	83 c4 10             	add    $0x10,%esp
        exit();
 1c4:	e8 f2 03 00 00       	call   5bb <exit>
    }

    printf(1, "\n=== MLFQ (policy 2) test result ===\n");
 1c9:	83 ec 08             	sub    $0x8,%esp
 1cc:	68 3c 0b 00 00       	push   $0xb3c
 1d1:	6a 01                	push   $0x1
 1d3:	e8 6f 05 00 00       	call   747 <printf>
 1d8:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPROC; i++) {
 1db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1e2:	e9 30 01 00 00       	jmp    317 <main+0x2d7>
        if (!st.inuse[i])
 1e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ea:	8b 04 85 60 0e 00 00 	mov    0xe60(,%eax,4),%eax
 1f1:	85 c0                	test   %eax,%eax
 1f3:	0f 84 19 01 00 00    	je     312 <main+0x2d2>
            continue;
        for (int j = 0; j < N; j++) {
 1f9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 200:	e9 01 01 00 00       	jmp    306 <main+0x2c6>
            if (st.pid[i] == pids[j]) {
 205:	8b 45 f4             	mov    -0xc(%ebp),%eax
 208:	83 c0 40             	add    $0x40,%eax
 20b:	8b 14 85 60 0e 00 00 	mov    0xe60(,%eax,4),%edx
 212:	8b 45 ec             	mov    -0x14(%ebp),%eax
 215:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
 219:	39 c2                	cmp    %eax,%edx
 21b:	0f 85 e1 00 00 00    	jne    302 <main+0x2c2>
                printf(1, "Process %d (PID %d): priority %d\n", j + 1, st.pid[i], st.priority[i]);
 221:	8b 45 f4             	mov    -0xc(%ebp),%eax
 224:	83 e8 80             	sub    $0xffffff80,%eax
 227:	8b 14 85 60 0e 00 00 	mov    0xe60(,%eax,4),%edx
 22e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 231:	83 c0 40             	add    $0x40,%eax
 234:	8b 04 85 60 0e 00 00 	mov    0xe60(,%eax,4),%eax
 23b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 23e:	83 c1 01             	add    $0x1,%ecx
 241:	83 ec 0c             	sub    $0xc,%esp
 244:	52                   	push   %edx
 245:	50                   	push   %eax
 246:	51                   	push   %ecx
 247:	68 64 0b 00 00       	push   $0xb64
 24c:	6a 01                	push   $0x1
 24e:	e8 f4 04 00 00       	call   747 <printf>
 253:	83 c4 20             	add    $0x20,%esp
                printf(1, "  TICKS      : [%d %d %d %d]\n",
 256:	8b 45 f4             	mov    -0xc(%ebp),%eax
 259:	c1 e0 04             	shl    $0x4,%eax
 25c:	05 6c 12 00 00       	add    $0x126c,%eax
 261:	8b 18                	mov    (%eax),%ebx
 263:	8b 45 f4             	mov    -0xc(%ebp),%eax
 266:	c1 e0 04             	shl    $0x4,%eax
 269:	05 68 12 00 00       	add    $0x1268,%eax
 26e:	8b 08                	mov    (%eax),%ecx
 270:	8b 45 f4             	mov    -0xc(%ebp),%eax
 273:	c1 e0 04             	shl    $0x4,%eax
 276:	05 64 12 00 00       	add    $0x1264,%eax
 27b:	8b 10                	mov    (%eax),%edx
 27d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 280:	83 c0 40             	add    $0x40,%eax
 283:	c1 e0 04             	shl    $0x4,%eax
 286:	05 60 0e 00 00       	add    $0xe60,%eax
 28b:	8b 00                	mov    (%eax),%eax
 28d:	83 ec 08             	sub    $0x8,%esp
 290:	53                   	push   %ebx
 291:	51                   	push   %ecx
 292:	52                   	push   %edx
 293:	50                   	push   %eax
 294:	68 86 0b 00 00       	push   $0xb86
 299:	6a 01                	push   $0x1
 29b:	e8 a7 04 00 00       	call   747 <printf>
 2a0:	83 c4 20             	add    $0x20,%esp
                       st.ticks[i][0], st.ticks[i][1],
                       st.ticks[i][2], st.ticks[i][3]);
                printf(1, "  WAIT_TICKS : [%d %d %d %d]\n",
 2a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a6:	c1 e0 04             	shl    $0x4,%eax
 2a9:	05 6c 16 00 00       	add    $0x166c,%eax
 2ae:	8b 18                	mov    (%eax),%ebx
 2b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b3:	c1 e0 04             	shl    $0x4,%eax
 2b6:	05 68 16 00 00       	add    $0x1668,%eax
 2bb:	8b 08                	mov    (%eax),%ecx
 2bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c0:	c1 e0 04             	shl    $0x4,%eax
 2c3:	05 64 16 00 00       	add    $0x1664,%eax
 2c8:	8b 10                	mov    (%eax),%edx
 2ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2cd:	83 e8 80             	sub    $0xffffff80,%eax
 2d0:	c1 e0 04             	shl    $0x4,%eax
 2d3:	05 60 0e 00 00       	add    $0xe60,%eax
 2d8:	8b 00                	mov    (%eax),%eax
 2da:	83 ec 08             	sub    $0x8,%esp
 2dd:	53                   	push   %ebx
 2de:	51                   	push   %ecx
 2df:	52                   	push   %edx
 2e0:	50                   	push   %eax
 2e1:	68 a4 0b 00 00       	push   $0xba4
 2e6:	6a 01                	push   $0x1
 2e8:	e8 5a 04 00 00       	call   747 <printf>
 2ed:	83 c4 20             	add    $0x20,%esp
                       st.wait_ticks[i][0], st.wait_ticks[i][1],
                       st.wait_ticks[i][2], st.wait_ticks[i][3]);
                printf(1, "\n");
 2f0:	83 ec 08             	sub    $0x8,%esp
 2f3:	68 c2 0b 00 00       	push   $0xbc2
 2f8:	6a 01                	push   $0x1
 2fa:	e8 48 04 00 00       	call   747 <printf>
 2ff:	83 c4 10             	add    $0x10,%esp
        for (int j = 0; j < N; j++) {
 302:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 306:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
 30a:	0f 8e f5 fe ff ff    	jle    205 <main+0x1c5>
 310:	eb 01                	jmp    313 <main+0x2d3>
            continue;
 312:	90                   	nop
    for (i = 0; i < NPROC; i++) {
 313:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 317:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 31b:	0f 8e c6 fe ff ff    	jle    1e7 <main+0x1a7>
            }
        }
    }

    for (i = 0; i < N; i++)
 321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 328:	eb 17                	jmp    341 <main+0x301>
    {
        kill(pids[i]);
 32a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 32d:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
 331:	83 ec 0c             	sub    $0xc,%esp
 334:	50                   	push   %eax
 335:	e8 b1 02 00 00       	call   5eb <kill>
 33a:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < N; i++)
 33d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 341:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 345:	7e e3                	jle    32a <main+0x2ea>
    }
    for (i = 0; i < N; i++)
 347:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 34e:	eb 09                	jmp    359 <main+0x319>
    {
        wait();
 350:	e8 6e 02 00 00       	call   5c3 <wait>
    for (i = 0; i < N; i++)
 355:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 359:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 35d:	7e f1                	jle    350 <main+0x310>
    }

    exit();
 35f:	e8 57 02 00 00       	call   5bb <exit>

00000364 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
 367:	57                   	push   %edi
 368:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 369:	8b 4d 08             	mov    0x8(%ebp),%ecx
 36c:	8b 55 10             	mov    0x10(%ebp),%edx
 36f:	8b 45 0c             	mov    0xc(%ebp),%eax
 372:	89 cb                	mov    %ecx,%ebx
 374:	89 df                	mov    %ebx,%edi
 376:	89 d1                	mov    %edx,%ecx
 378:	fc                   	cld    
 379:	f3 aa                	rep stos %al,%es:(%edi)
 37b:	89 ca                	mov    %ecx,%edx
 37d:	89 fb                	mov    %edi,%ebx
 37f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 382:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 385:	90                   	nop
 386:	5b                   	pop    %ebx
 387:	5f                   	pop    %edi
 388:	5d                   	pop    %ebp
 389:	c3                   	ret    

0000038a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 38a:	55                   	push   %ebp
 38b:	89 e5                	mov    %esp,%ebp
 38d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 390:	8b 45 08             	mov    0x8(%ebp),%eax
 393:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 396:	90                   	nop
 397:	8b 55 0c             	mov    0xc(%ebp),%edx
 39a:	8d 42 01             	lea    0x1(%edx),%eax
 39d:	89 45 0c             	mov    %eax,0xc(%ebp)
 3a0:	8b 45 08             	mov    0x8(%ebp),%eax
 3a3:	8d 48 01             	lea    0x1(%eax),%ecx
 3a6:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3a9:	0f b6 12             	movzbl (%edx),%edx
 3ac:	88 10                	mov    %dl,(%eax)
 3ae:	0f b6 00             	movzbl (%eax),%eax
 3b1:	84 c0                	test   %al,%al
 3b3:	75 e2                	jne    397 <strcpy+0xd>
    ;
  return os;
 3b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b8:	c9                   	leave  
 3b9:	c3                   	ret    

000003ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3ba:	55                   	push   %ebp
 3bb:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3bd:	eb 08                	jmp    3c7 <strcmp+0xd>
    p++, q++;
 3bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3c7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ca:	0f b6 00             	movzbl (%eax),%eax
 3cd:	84 c0                	test   %al,%al
 3cf:	74 10                	je     3e1 <strcmp+0x27>
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	0f b6 10             	movzbl (%eax),%edx
 3d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3da:	0f b6 00             	movzbl (%eax),%eax
 3dd:	38 c2                	cmp    %al,%dl
 3df:	74 de                	je     3bf <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3e1:	8b 45 08             	mov    0x8(%ebp),%eax
 3e4:	0f b6 00             	movzbl (%eax),%eax
 3e7:	0f b6 d0             	movzbl %al,%edx
 3ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ed:	0f b6 00             	movzbl (%eax),%eax
 3f0:	0f b6 c8             	movzbl %al,%ecx
 3f3:	89 d0                	mov    %edx,%eax
 3f5:	29 c8                	sub    %ecx,%eax
}
 3f7:	5d                   	pop    %ebp
 3f8:	c3                   	ret    

000003f9 <strlen>:

uint
strlen(char *s)
{
 3f9:	55                   	push   %ebp
 3fa:	89 e5                	mov    %esp,%ebp
 3fc:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 406:	eb 04                	jmp    40c <strlen+0x13>
 408:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 40c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 40f:	8b 45 08             	mov    0x8(%ebp),%eax
 412:	01 d0                	add    %edx,%eax
 414:	0f b6 00             	movzbl (%eax),%eax
 417:	84 c0                	test   %al,%al
 419:	75 ed                	jne    408 <strlen+0xf>
    ;
  return n;
 41b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 41e:	c9                   	leave  
 41f:	c3                   	ret    

00000420 <memset>:

void*
memset(void *dst, int c, uint n)
{
 420:	55                   	push   %ebp
 421:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 423:	8b 45 10             	mov    0x10(%ebp),%eax
 426:	50                   	push   %eax
 427:	ff 75 0c             	push   0xc(%ebp)
 42a:	ff 75 08             	push   0x8(%ebp)
 42d:	e8 32 ff ff ff       	call   364 <stosb>
 432:	83 c4 0c             	add    $0xc,%esp
  return dst;
 435:	8b 45 08             	mov    0x8(%ebp),%eax
}
 438:	c9                   	leave  
 439:	c3                   	ret    

0000043a <strchr>:

char*
strchr(const char *s, char c)
{
 43a:	55                   	push   %ebp
 43b:	89 e5                	mov    %esp,%ebp
 43d:	83 ec 04             	sub    $0x4,%esp
 440:	8b 45 0c             	mov    0xc(%ebp),%eax
 443:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 446:	eb 14                	jmp    45c <strchr+0x22>
    if(*s == c)
 448:	8b 45 08             	mov    0x8(%ebp),%eax
 44b:	0f b6 00             	movzbl (%eax),%eax
 44e:	38 45 fc             	cmp    %al,-0x4(%ebp)
 451:	75 05                	jne    458 <strchr+0x1e>
      return (char*)s;
 453:	8b 45 08             	mov    0x8(%ebp),%eax
 456:	eb 13                	jmp    46b <strchr+0x31>
  for(; *s; s++)
 458:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 45c:	8b 45 08             	mov    0x8(%ebp),%eax
 45f:	0f b6 00             	movzbl (%eax),%eax
 462:	84 c0                	test   %al,%al
 464:	75 e2                	jne    448 <strchr+0xe>
  return 0;
 466:	b8 00 00 00 00       	mov    $0x0,%eax
}
 46b:	c9                   	leave  
 46c:	c3                   	ret    

0000046d <gets>:

char*
gets(char *buf, int max)
{
 46d:	55                   	push   %ebp
 46e:	89 e5                	mov    %esp,%ebp
 470:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 473:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 47a:	eb 42                	jmp    4be <gets+0x51>
    cc = read(0, &c, 1);
 47c:	83 ec 04             	sub    $0x4,%esp
 47f:	6a 01                	push   $0x1
 481:	8d 45 ef             	lea    -0x11(%ebp),%eax
 484:	50                   	push   %eax
 485:	6a 00                	push   $0x0
 487:	e8 47 01 00 00       	call   5d3 <read>
 48c:	83 c4 10             	add    $0x10,%esp
 48f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 492:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 496:	7e 33                	jle    4cb <gets+0x5e>
      break;
    buf[i++] = c;
 498:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49b:	8d 50 01             	lea    0x1(%eax),%edx
 49e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4a1:	89 c2                	mov    %eax,%edx
 4a3:	8b 45 08             	mov    0x8(%ebp),%eax
 4a6:	01 c2                	add    %eax,%edx
 4a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ac:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4ae:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b2:	3c 0a                	cmp    $0xa,%al
 4b4:	74 16                	je     4cc <gets+0x5f>
 4b6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ba:	3c 0d                	cmp    $0xd,%al
 4bc:	74 0e                	je     4cc <gets+0x5f>
  for(i=0; i+1 < max; ){
 4be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c1:	83 c0 01             	add    $0x1,%eax
 4c4:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4c7:	7f b3                	jg     47c <gets+0xf>
 4c9:	eb 01                	jmp    4cc <gets+0x5f>
      break;
 4cb:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4cf:	8b 45 08             	mov    0x8(%ebp),%eax
 4d2:	01 d0                	add    %edx,%eax
 4d4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4da:	c9                   	leave  
 4db:	c3                   	ret    

000004dc <stat>:

int
stat(char *n, struct stat *st)
{
 4dc:	55                   	push   %ebp
 4dd:	89 e5                	mov    %esp,%ebp
 4df:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4e2:	83 ec 08             	sub    $0x8,%esp
 4e5:	6a 00                	push   $0x0
 4e7:	ff 75 08             	push   0x8(%ebp)
 4ea:	e8 0c 01 00 00       	call   5fb <open>
 4ef:	83 c4 10             	add    $0x10,%esp
 4f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f9:	79 07                	jns    502 <stat+0x26>
    return -1;
 4fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 500:	eb 25                	jmp    527 <stat+0x4b>
  r = fstat(fd, st);
 502:	83 ec 08             	sub    $0x8,%esp
 505:	ff 75 0c             	push   0xc(%ebp)
 508:	ff 75 f4             	push   -0xc(%ebp)
 50b:	e8 03 01 00 00       	call   613 <fstat>
 510:	83 c4 10             	add    $0x10,%esp
 513:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 516:	83 ec 0c             	sub    $0xc,%esp
 519:	ff 75 f4             	push   -0xc(%ebp)
 51c:	e8 c2 00 00 00       	call   5e3 <close>
 521:	83 c4 10             	add    $0x10,%esp
  return r;
 524:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 527:	c9                   	leave  
 528:	c3                   	ret    

00000529 <atoi>:

int
atoi(const char *s)
{
 529:	55                   	push   %ebp
 52a:	89 e5                	mov    %esp,%ebp
 52c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 52f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 536:	eb 25                	jmp    55d <atoi+0x34>
    n = n*10 + *s++ - '0';
 538:	8b 55 fc             	mov    -0x4(%ebp),%edx
 53b:	89 d0                	mov    %edx,%eax
 53d:	c1 e0 02             	shl    $0x2,%eax
 540:	01 d0                	add    %edx,%eax
 542:	01 c0                	add    %eax,%eax
 544:	89 c1                	mov    %eax,%ecx
 546:	8b 45 08             	mov    0x8(%ebp),%eax
 549:	8d 50 01             	lea    0x1(%eax),%edx
 54c:	89 55 08             	mov    %edx,0x8(%ebp)
 54f:	0f b6 00             	movzbl (%eax),%eax
 552:	0f be c0             	movsbl %al,%eax
 555:	01 c8                	add    %ecx,%eax
 557:	83 e8 30             	sub    $0x30,%eax
 55a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 55d:	8b 45 08             	mov    0x8(%ebp),%eax
 560:	0f b6 00             	movzbl (%eax),%eax
 563:	3c 2f                	cmp    $0x2f,%al
 565:	7e 0a                	jle    571 <atoi+0x48>
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	0f b6 00             	movzbl (%eax),%eax
 56d:	3c 39                	cmp    $0x39,%al
 56f:	7e c7                	jle    538 <atoi+0xf>
  return n;
 571:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 574:	c9                   	leave  
 575:	c3                   	ret    

00000576 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 576:	55                   	push   %ebp
 577:	89 e5                	mov    %esp,%ebp
 579:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 57c:	8b 45 08             	mov    0x8(%ebp),%eax
 57f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 582:	8b 45 0c             	mov    0xc(%ebp),%eax
 585:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 588:	eb 17                	jmp    5a1 <memmove+0x2b>
    *dst++ = *src++;
 58a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 58d:	8d 42 01             	lea    0x1(%edx),%eax
 590:	89 45 f8             	mov    %eax,-0x8(%ebp)
 593:	8b 45 fc             	mov    -0x4(%ebp),%eax
 596:	8d 48 01             	lea    0x1(%eax),%ecx
 599:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 59c:	0f b6 12             	movzbl (%edx),%edx
 59f:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5a1:	8b 45 10             	mov    0x10(%ebp),%eax
 5a4:	8d 50 ff             	lea    -0x1(%eax),%edx
 5a7:	89 55 10             	mov    %edx,0x10(%ebp)
 5aa:	85 c0                	test   %eax,%eax
 5ac:	7f dc                	jg     58a <memmove+0x14>
  return vdst;
 5ae:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5b1:	c9                   	leave  
 5b2:	c3                   	ret    

000005b3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5b3:	b8 01 00 00 00       	mov    $0x1,%eax
 5b8:	cd 40                	int    $0x40
 5ba:	c3                   	ret    

000005bb <exit>:
SYSCALL(exit)
 5bb:	b8 02 00 00 00       	mov    $0x2,%eax
 5c0:	cd 40                	int    $0x40
 5c2:	c3                   	ret    

000005c3 <wait>:
SYSCALL(wait)
 5c3:	b8 03 00 00 00       	mov    $0x3,%eax
 5c8:	cd 40                	int    $0x40
 5ca:	c3                   	ret    

000005cb <pipe>:
SYSCALL(pipe)
 5cb:	b8 04 00 00 00       	mov    $0x4,%eax
 5d0:	cd 40                	int    $0x40
 5d2:	c3                   	ret    

000005d3 <read>:
SYSCALL(read)
 5d3:	b8 05 00 00 00       	mov    $0x5,%eax
 5d8:	cd 40                	int    $0x40
 5da:	c3                   	ret    

000005db <write>:
SYSCALL(write)
 5db:	b8 10 00 00 00       	mov    $0x10,%eax
 5e0:	cd 40                	int    $0x40
 5e2:	c3                   	ret    

000005e3 <close>:
SYSCALL(close)
 5e3:	b8 15 00 00 00       	mov    $0x15,%eax
 5e8:	cd 40                	int    $0x40
 5ea:	c3                   	ret    

000005eb <kill>:
SYSCALL(kill)
 5eb:	b8 06 00 00 00       	mov    $0x6,%eax
 5f0:	cd 40                	int    $0x40
 5f2:	c3                   	ret    

000005f3 <exec>:
SYSCALL(exec)
 5f3:	b8 07 00 00 00       	mov    $0x7,%eax
 5f8:	cd 40                	int    $0x40
 5fa:	c3                   	ret    

000005fb <open>:
SYSCALL(open)
 5fb:	b8 0f 00 00 00       	mov    $0xf,%eax
 600:	cd 40                	int    $0x40
 602:	c3                   	ret    

00000603 <mknod>:
SYSCALL(mknod)
 603:	b8 11 00 00 00       	mov    $0x11,%eax
 608:	cd 40                	int    $0x40
 60a:	c3                   	ret    

0000060b <unlink>:
SYSCALL(unlink)
 60b:	b8 12 00 00 00       	mov    $0x12,%eax
 610:	cd 40                	int    $0x40
 612:	c3                   	ret    

00000613 <fstat>:
SYSCALL(fstat)
 613:	b8 08 00 00 00       	mov    $0x8,%eax
 618:	cd 40                	int    $0x40
 61a:	c3                   	ret    

0000061b <link>:
SYSCALL(link)
 61b:	b8 13 00 00 00       	mov    $0x13,%eax
 620:	cd 40                	int    $0x40
 622:	c3                   	ret    

00000623 <mkdir>:
SYSCALL(mkdir)
 623:	b8 14 00 00 00       	mov    $0x14,%eax
 628:	cd 40                	int    $0x40
 62a:	c3                   	ret    

0000062b <chdir>:
SYSCALL(chdir)
 62b:	b8 09 00 00 00       	mov    $0x9,%eax
 630:	cd 40                	int    $0x40
 632:	c3                   	ret    

00000633 <dup>:
SYSCALL(dup)
 633:	b8 0a 00 00 00       	mov    $0xa,%eax
 638:	cd 40                	int    $0x40
 63a:	c3                   	ret    

0000063b <getpid>:
SYSCALL(getpid)
 63b:	b8 0b 00 00 00       	mov    $0xb,%eax
 640:	cd 40                	int    $0x40
 642:	c3                   	ret    

00000643 <sbrk>:
SYSCALL(sbrk)
 643:	b8 0c 00 00 00       	mov    $0xc,%eax
 648:	cd 40                	int    $0x40
 64a:	c3                   	ret    

0000064b <sleep>:
SYSCALL(sleep)
 64b:	b8 0d 00 00 00       	mov    $0xd,%eax
 650:	cd 40                	int    $0x40
 652:	c3                   	ret    

00000653 <uptime>:
SYSCALL(uptime)
 653:	b8 0e 00 00 00       	mov    $0xe,%eax
 658:	cd 40                	int    $0x40
 65a:	c3                   	ret    

0000065b <getpinfo>:
SYSCALL(getpinfo)
 65b:	b8 16 00 00 00       	mov    $0x16,%eax
 660:	cd 40                	int    $0x40
 662:	c3                   	ret    

00000663 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 663:	b8 17 00 00 00       	mov    $0x17,%eax
 668:	cd 40                	int    $0x40
 66a:	c3                   	ret    

0000066b <getqinfo>:
 66b:	b8 18 00 00 00       	mov    $0x18,%eax
 670:	cd 40                	int    $0x40
 672:	c3                   	ret    

00000673 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 673:	55                   	push   %ebp
 674:	89 e5                	mov    %esp,%ebp
 676:	83 ec 18             	sub    $0x18,%esp
 679:	8b 45 0c             	mov    0xc(%ebp),%eax
 67c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 67f:	83 ec 04             	sub    $0x4,%esp
 682:	6a 01                	push   $0x1
 684:	8d 45 f4             	lea    -0xc(%ebp),%eax
 687:	50                   	push   %eax
 688:	ff 75 08             	push   0x8(%ebp)
 68b:	e8 4b ff ff ff       	call   5db <write>
 690:	83 c4 10             	add    $0x10,%esp
}
 693:	90                   	nop
 694:	c9                   	leave  
 695:	c3                   	ret    

00000696 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 696:	55                   	push   %ebp
 697:	89 e5                	mov    %esp,%ebp
 699:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 69c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6a3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6a7:	74 17                	je     6c0 <printint+0x2a>
 6a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6ad:	79 11                	jns    6c0 <printint+0x2a>
    neg = 1;
 6af:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b9:	f7 d8                	neg    %eax
 6bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6be:	eb 06                	jmp    6c6 <printint+0x30>
  } else {
    x = xx;
 6c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d3:	ba 00 00 00 00       	mov    $0x0,%edx
 6d8:	f7 f1                	div    %ecx
 6da:	89 d1                	mov    %edx,%ecx
 6dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6df:	8d 50 01             	lea    0x1(%eax),%edx
 6e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6e5:	0f b6 91 34 0e 00 00 	movzbl 0xe34(%ecx),%edx
 6ec:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f6:	ba 00 00 00 00       	mov    $0x0,%edx
 6fb:	f7 f1                	div    %ecx
 6fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 700:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 704:	75 c7                	jne    6cd <printint+0x37>
  if(neg)
 706:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 70a:	74 2d                	je     739 <printint+0xa3>
    buf[i++] = '-';
 70c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70f:	8d 50 01             	lea    0x1(%eax),%edx
 712:	89 55 f4             	mov    %edx,-0xc(%ebp)
 715:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 71a:	eb 1d                	jmp    739 <printint+0xa3>
    putc(fd, buf[i]);
 71c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 71f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 722:	01 d0                	add    %edx,%eax
 724:	0f b6 00             	movzbl (%eax),%eax
 727:	0f be c0             	movsbl %al,%eax
 72a:	83 ec 08             	sub    $0x8,%esp
 72d:	50                   	push   %eax
 72e:	ff 75 08             	push   0x8(%ebp)
 731:	e8 3d ff ff ff       	call   673 <putc>
 736:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 739:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 73d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 741:	79 d9                	jns    71c <printint+0x86>
}
 743:	90                   	nop
 744:	90                   	nop
 745:	c9                   	leave  
 746:	c3                   	ret    

00000747 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 747:	55                   	push   %ebp
 748:	89 e5                	mov    %esp,%ebp
 74a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 74d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 754:	8d 45 0c             	lea    0xc(%ebp),%eax
 757:	83 c0 04             	add    $0x4,%eax
 75a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 75d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 764:	e9 59 01 00 00       	jmp    8c2 <printf+0x17b>
    c = fmt[i] & 0xff;
 769:	8b 55 0c             	mov    0xc(%ebp),%edx
 76c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76f:	01 d0                	add    %edx,%eax
 771:	0f b6 00             	movzbl (%eax),%eax
 774:	0f be c0             	movsbl %al,%eax
 777:	25 ff 00 00 00       	and    $0xff,%eax
 77c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 77f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 783:	75 2c                	jne    7b1 <printf+0x6a>
      if(c == '%'){
 785:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 789:	75 0c                	jne    797 <printf+0x50>
        state = '%';
 78b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 792:	e9 27 01 00 00       	jmp    8be <printf+0x177>
      } else {
        putc(fd, c);
 797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79a:	0f be c0             	movsbl %al,%eax
 79d:	83 ec 08             	sub    $0x8,%esp
 7a0:	50                   	push   %eax
 7a1:	ff 75 08             	push   0x8(%ebp)
 7a4:	e8 ca fe ff ff       	call   673 <putc>
 7a9:	83 c4 10             	add    $0x10,%esp
 7ac:	e9 0d 01 00 00       	jmp    8be <printf+0x177>
      }
    } else if(state == '%'){
 7b1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7b5:	0f 85 03 01 00 00    	jne    8be <printf+0x177>
      if(c == 'd'){
 7bb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7bf:	75 1e                	jne    7df <printf+0x98>
        printint(fd, *ap, 10, 1);
 7c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c4:	8b 00                	mov    (%eax),%eax
 7c6:	6a 01                	push   $0x1
 7c8:	6a 0a                	push   $0xa
 7ca:	50                   	push   %eax
 7cb:	ff 75 08             	push   0x8(%ebp)
 7ce:	e8 c3 fe ff ff       	call   696 <printint>
 7d3:	83 c4 10             	add    $0x10,%esp
        ap++;
 7d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7da:	e9 d8 00 00 00       	jmp    8b7 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7df:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7e3:	74 06                	je     7eb <printf+0xa4>
 7e5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7e9:	75 1e                	jne    809 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ee:	8b 00                	mov    (%eax),%eax
 7f0:	6a 00                	push   $0x0
 7f2:	6a 10                	push   $0x10
 7f4:	50                   	push   %eax
 7f5:	ff 75 08             	push   0x8(%ebp)
 7f8:	e8 99 fe ff ff       	call   696 <printint>
 7fd:	83 c4 10             	add    $0x10,%esp
        ap++;
 800:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 804:	e9 ae 00 00 00       	jmp    8b7 <printf+0x170>
      } else if(c == 's'){
 809:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 80d:	75 43                	jne    852 <printf+0x10b>
        s = (char*)*ap;
 80f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 812:	8b 00                	mov    (%eax),%eax
 814:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 817:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 81b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 81f:	75 25                	jne    846 <printf+0xff>
          s = "(null)";
 821:	c7 45 f4 c4 0b 00 00 	movl   $0xbc4,-0xc(%ebp)
        while(*s != 0){
 828:	eb 1c                	jmp    846 <printf+0xff>
          putc(fd, *s);
 82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82d:	0f b6 00             	movzbl (%eax),%eax
 830:	0f be c0             	movsbl %al,%eax
 833:	83 ec 08             	sub    $0x8,%esp
 836:	50                   	push   %eax
 837:	ff 75 08             	push   0x8(%ebp)
 83a:	e8 34 fe ff ff       	call   673 <putc>
 83f:	83 c4 10             	add    $0x10,%esp
          s++;
 842:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 846:	8b 45 f4             	mov    -0xc(%ebp),%eax
 849:	0f b6 00             	movzbl (%eax),%eax
 84c:	84 c0                	test   %al,%al
 84e:	75 da                	jne    82a <printf+0xe3>
 850:	eb 65                	jmp    8b7 <printf+0x170>
        }
      } else if(c == 'c'){
 852:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 856:	75 1d                	jne    875 <printf+0x12e>
        putc(fd, *ap);
 858:	8b 45 e8             	mov    -0x18(%ebp),%eax
 85b:	8b 00                	mov    (%eax),%eax
 85d:	0f be c0             	movsbl %al,%eax
 860:	83 ec 08             	sub    $0x8,%esp
 863:	50                   	push   %eax
 864:	ff 75 08             	push   0x8(%ebp)
 867:	e8 07 fe ff ff       	call   673 <putc>
 86c:	83 c4 10             	add    $0x10,%esp
        ap++;
 86f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 873:	eb 42                	jmp    8b7 <printf+0x170>
      } else if(c == '%'){
 875:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 879:	75 17                	jne    892 <printf+0x14b>
        putc(fd, c);
 87b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 87e:	0f be c0             	movsbl %al,%eax
 881:	83 ec 08             	sub    $0x8,%esp
 884:	50                   	push   %eax
 885:	ff 75 08             	push   0x8(%ebp)
 888:	e8 e6 fd ff ff       	call   673 <putc>
 88d:	83 c4 10             	add    $0x10,%esp
 890:	eb 25                	jmp    8b7 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 892:	83 ec 08             	sub    $0x8,%esp
 895:	6a 25                	push   $0x25
 897:	ff 75 08             	push   0x8(%ebp)
 89a:	e8 d4 fd ff ff       	call   673 <putc>
 89f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a5:	0f be c0             	movsbl %al,%eax
 8a8:	83 ec 08             	sub    $0x8,%esp
 8ab:	50                   	push   %eax
 8ac:	ff 75 08             	push   0x8(%ebp)
 8af:	e8 bf fd ff ff       	call   673 <putc>
 8b4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8b7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8be:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8c2:	8b 55 0c             	mov    0xc(%ebp),%edx
 8c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c8:	01 d0                	add    %edx,%eax
 8ca:	0f b6 00             	movzbl (%eax),%eax
 8cd:	84 c0                	test   %al,%al
 8cf:	0f 85 94 fe ff ff    	jne    769 <printf+0x22>
    }
  }
}
 8d5:	90                   	nop
 8d6:	90                   	nop
 8d7:	c9                   	leave  
 8d8:	c3                   	ret    

000008d9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8d9:	55                   	push   %ebp
 8da:	89 e5                	mov    %esp,%ebp
 8dc:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8df:	8b 45 08             	mov    0x8(%ebp),%eax
 8e2:	83 e8 08             	sub    $0x8,%eax
 8e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e8:	a1 68 1a 00 00       	mov    0x1a68,%eax
 8ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f0:	eb 24                	jmp    916 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f5:	8b 00                	mov    (%eax),%eax
 8f7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8fa:	72 12                	jb     90e <free+0x35>
 8fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ff:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 902:	77 24                	ja     928 <free+0x4f>
 904:	8b 45 fc             	mov    -0x4(%ebp),%eax
 907:	8b 00                	mov    (%eax),%eax
 909:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 90c:	72 1a                	jb     928 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 911:	8b 00                	mov    (%eax),%eax
 913:	89 45 fc             	mov    %eax,-0x4(%ebp)
 916:	8b 45 f8             	mov    -0x8(%ebp),%eax
 919:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 91c:	76 d4                	jbe    8f2 <free+0x19>
 91e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 921:	8b 00                	mov    (%eax),%eax
 923:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 926:	73 ca                	jae    8f2 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 928:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92b:	8b 40 04             	mov    0x4(%eax),%eax
 92e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 935:	8b 45 f8             	mov    -0x8(%ebp),%eax
 938:	01 c2                	add    %eax,%edx
 93a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93d:	8b 00                	mov    (%eax),%eax
 93f:	39 c2                	cmp    %eax,%edx
 941:	75 24                	jne    967 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	8b 50 04             	mov    0x4(%eax),%edx
 949:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94c:	8b 00                	mov    (%eax),%eax
 94e:	8b 40 04             	mov    0x4(%eax),%eax
 951:	01 c2                	add    %eax,%edx
 953:	8b 45 f8             	mov    -0x8(%ebp),%eax
 956:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	8b 00                	mov    (%eax),%eax
 95e:	8b 10                	mov    (%eax),%edx
 960:	8b 45 f8             	mov    -0x8(%ebp),%eax
 963:	89 10                	mov    %edx,(%eax)
 965:	eb 0a                	jmp    971 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 967:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96a:	8b 10                	mov    (%eax),%edx
 96c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 971:	8b 45 fc             	mov    -0x4(%ebp),%eax
 974:	8b 40 04             	mov    0x4(%eax),%eax
 977:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 97e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 981:	01 d0                	add    %edx,%eax
 983:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 986:	75 20                	jne    9a8 <free+0xcf>
    p->s.size += bp->s.size;
 988:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98b:	8b 50 04             	mov    0x4(%eax),%edx
 98e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 991:	8b 40 04             	mov    0x4(%eax),%eax
 994:	01 c2                	add    %eax,%edx
 996:	8b 45 fc             	mov    -0x4(%ebp),%eax
 999:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 99c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99f:	8b 10                	mov    (%eax),%edx
 9a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a4:	89 10                	mov    %edx,(%eax)
 9a6:	eb 08                	jmp    9b0 <free+0xd7>
  } else
    p->s.ptr = bp;
 9a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ab:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9ae:	89 10                	mov    %edx,(%eax)
  freep = p;
 9b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b3:	a3 68 1a 00 00       	mov    %eax,0x1a68
}
 9b8:	90                   	nop
 9b9:	c9                   	leave  
 9ba:	c3                   	ret    

000009bb <morecore>:

static Header*
morecore(uint nu)
{
 9bb:	55                   	push   %ebp
 9bc:	89 e5                	mov    %esp,%ebp
 9be:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9c1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9c8:	77 07                	ja     9d1 <morecore+0x16>
    nu = 4096;
 9ca:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9d1:	8b 45 08             	mov    0x8(%ebp),%eax
 9d4:	c1 e0 03             	shl    $0x3,%eax
 9d7:	83 ec 0c             	sub    $0xc,%esp
 9da:	50                   	push   %eax
 9db:	e8 63 fc ff ff       	call   643 <sbrk>
 9e0:	83 c4 10             	add    $0x10,%esp
 9e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9e6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9ea:	75 07                	jne    9f3 <morecore+0x38>
    return 0;
 9ec:	b8 00 00 00 00       	mov    $0x0,%eax
 9f1:	eb 26                	jmp    a19 <morecore+0x5e>
  hp = (Header*)p;
 9f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fc:	8b 55 08             	mov    0x8(%ebp),%edx
 9ff:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a05:	83 c0 08             	add    $0x8,%eax
 a08:	83 ec 0c             	sub    $0xc,%esp
 a0b:	50                   	push   %eax
 a0c:	e8 c8 fe ff ff       	call   8d9 <free>
 a11:	83 c4 10             	add    $0x10,%esp
  return freep;
 a14:	a1 68 1a 00 00       	mov    0x1a68,%eax
}
 a19:	c9                   	leave  
 a1a:	c3                   	ret    

00000a1b <malloc>:

void*
malloc(uint nbytes)
{
 a1b:	55                   	push   %ebp
 a1c:	89 e5                	mov    %esp,%ebp
 a1e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a21:	8b 45 08             	mov    0x8(%ebp),%eax
 a24:	83 c0 07             	add    $0x7,%eax
 a27:	c1 e8 03             	shr    $0x3,%eax
 a2a:	83 c0 01             	add    $0x1,%eax
 a2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a30:	a1 68 1a 00 00       	mov    0x1a68,%eax
 a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a3c:	75 23                	jne    a61 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a3e:	c7 45 f0 60 1a 00 00 	movl   $0x1a60,-0x10(%ebp)
 a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a48:	a3 68 1a 00 00       	mov    %eax,0x1a68
 a4d:	a1 68 1a 00 00       	mov    0x1a68,%eax
 a52:	a3 60 1a 00 00       	mov    %eax,0x1a60
    base.s.size = 0;
 a57:	c7 05 64 1a 00 00 00 	movl   $0x0,0x1a64
 a5e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a64:	8b 00                	mov    (%eax),%eax
 a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6c:	8b 40 04             	mov    0x4(%eax),%eax
 a6f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a72:	77 4d                	ja     ac1 <malloc+0xa6>
      if(p->s.size == nunits)
 a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a77:	8b 40 04             	mov    0x4(%eax),%eax
 a7a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a7d:	75 0c                	jne    a8b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a82:	8b 10                	mov    (%eax),%edx
 a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a87:	89 10                	mov    %edx,(%eax)
 a89:	eb 26                	jmp    ab1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8e:	8b 40 04             	mov    0x4(%eax),%eax
 a91:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a94:	89 c2                	mov    %eax,%edx
 a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a99:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9f:	8b 40 04             	mov    0x4(%eax),%eax
 aa2:	c1 e0 03             	shl    $0x3,%eax
 aa5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aab:	8b 55 ec             	mov    -0x14(%ebp),%edx
 aae:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab4:	a3 68 1a 00 00       	mov    %eax,0x1a68
      return (void*)(p + 1);
 ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abc:	83 c0 08             	add    $0x8,%eax
 abf:	eb 3b                	jmp    afc <malloc+0xe1>
    }
    if(p == freep)
 ac1:	a1 68 1a 00 00       	mov    0x1a68,%eax
 ac6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ac9:	75 1e                	jne    ae9 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 acb:	83 ec 0c             	sub    $0xc,%esp
 ace:	ff 75 ec             	push   -0x14(%ebp)
 ad1:	e8 e5 fe ff ff       	call   9bb <morecore>
 ad6:	83 c4 10             	add    $0x10,%esp
 ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 adc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae0:	75 07                	jne    ae9 <malloc+0xce>
        return 0;
 ae2:	b8 00 00 00 00       	mov    $0x0,%eax
 ae7:	eb 13                	jmp    afc <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aec:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af2:	8b 00                	mov    (%eax),%eax
 af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 af7:	e9 6d ff ff ff       	jmp    a69 <malloc+0x4e>
  }
}
 afc:	c9                   	leave  
 afd:	c3                   	ret    
