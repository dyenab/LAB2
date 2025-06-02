
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
  4a:	e8 56 05 00 00       	call   5a5 <setSchedPolicy>
  4f:	83 c4 10             	add    $0x10,%esp
  52:	85 c0                	test   %eax,%eax
  54:	79 17                	jns    6d <main+0x3a>
        printf(1, "Failed to setSchedPolicy(3)\n");
  56:	83 ec 08             	sub    $0x8,%esp
  59:	68 40 0a 00 00       	push   $0xa40
  5e:	6a 01                	push   $0x1
  60:	e8 24 06 00 00       	call   689 <printf>
  65:	83 c4 10             	add    $0x10,%esp
        exit();
  68:	e8 90 04 00 00       	call   4fd <exit>
    }

    for (int i = 0; i < NUM_PROCS; i++) {
  6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  74:	eb 7a                	jmp    f0 <main+0xbd>
        int pid = fork();
  76:	e8 7a 04 00 00       	call   4f5 <fork>
  7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if (pid < 0) {
  7e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  82:	79 05                	jns    89 <main+0x56>
            exit();
  84:	e8 74 04 00 00       	call   4fd <exit>
        } else if (pid == 0) {
  89:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8d:	75 53                	jne    e2 <main+0xaf>
            // child process
            if (i == 0 || i == 1) {
  8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  93:	74 06                	je     9b <main+0x68>
  95:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  99:	75 32                	jne    cd <main+0x9a>
                // yield() 유도용 짧은 작업 반복
                for (int k = 0; k < 32; k++) {
  9b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  a2:	eb 21                	jmp    c5 <main+0x92>
                    workload(3000000);
  a4:	83 ec 0c             	sub    $0xc,%esp
  a7:	68 c0 c6 2d 00       	push   $0x2dc6c0
  ac:	e8 4f ff ff ff       	call   0 <workload>
  b1:	83 c4 10             	add    $0x10,%esp
                    sleep(5);
  b4:	83 ec 0c             	sub    $0xc,%esp
  b7:	6a 05                	push   $0x5
  b9:	e8 cf 04 00 00       	call   58d <sleep>
  be:	83 c4 10             	add    $0x10,%esp
                for (int k = 0; k < 32; k++) {
  c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  c5:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  c9:	7e d9                	jle    a4 <main+0x71>
  cb:	eb 10                	jmp    dd <main+0xaa>
                }
            } else {
                // 긴 workload로 time slice 소진 유도
                workload(150000000);
  cd:	83 ec 0c             	sub    $0xc,%esp
  d0:	68 80 d1 f0 08       	push   $0x8f0d180
  d5:	e8 26 ff ff ff       	call   0 <workload>
  da:	83 c4 10             	add    $0x10,%esp
            }
            exit();
  dd:	e8 1b 04 00 00       	call   4fd <exit>
        } else {
            pids[i] = pid;
  e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  e8:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
    for (int i = 0; i < NUM_PROCS; i++) {
  ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  f0:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  f4:	7e 80                	jle    76 <main+0x43>
        }
    }

    sleep(300); // 모든 프로세스가 충분히 실행되도록 대기
  f6:	83 ec 0c             	sub    $0xc,%esp
  f9:	68 2c 01 00 00       	push   $0x12c
  fe:	e8 8a 04 00 00       	call   58d <sleep>
 103:	83 c4 10             	add    $0x10,%esp

    if (getpinfo(&st) < 0) {
 106:	83 ec 0c             	sub    $0xc,%esp
 109:	68 80 0d 00 00       	push   $0xd80
 10e:	e8 8a 04 00 00       	call   59d <getpinfo>
 113:	83 c4 10             	add    $0x10,%esp
 116:	85 c0                	test   %eax,%eax
 118:	79 17                	jns    131 <main+0xfe>
        printf(1, "getpinfo failed\n");
 11a:	83 ec 08             	sub    $0x8,%esp
 11d:	68 5d 0a 00 00       	push   $0xa5d
 122:	6a 01                	push   $0x1
 124:	e8 60 05 00 00       	call   689 <printf>
 129:	83 c4 10             	add    $0x10,%esp
        exit();
 12c:	e8 cc 03 00 00       	call   4fd <exit>
    }

    printf(1, "\n=== MLFQ (policy 3) test result ===\n");
 131:	83 ec 08             	sub    $0x8,%esp
 134:	68 70 0a 00 00       	push   $0xa70
 139:	6a 01                	push   $0x1
 13b:	e8 49 05 00 00       	call   689 <printf>
 140:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < NPROC; i++) {
 143:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 14a:	e9 30 01 00 00       	jmp    27f <main+0x24c>
        if (!st.inuse[i])
 14f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 152:	8b 04 85 80 0d 00 00 	mov    0xd80(,%eax,4),%eax
 159:	85 c0                	test   %eax,%eax
 15b:	0f 84 19 01 00 00    	je     27a <main+0x247>
            continue;

        for (int j = 0; j < NUM_PROCS; j++) {
 161:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 168:	e9 01 01 00 00       	jmp    26e <main+0x23b>
            if (st.pid[i] == pids[j]) {
 16d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 170:	83 c0 40             	add    $0x40,%eax
 173:	8b 14 85 80 0d 00 00 	mov    0xd80(,%eax,4),%edx
 17a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 17d:	8b 44 85 d0          	mov    -0x30(%ebp,%eax,4),%eax
 181:	39 c2                	cmp    %eax,%edx
 183:	0f 85 e1 00 00 00    	jne    26a <main+0x237>
                printf(1, "pid %d | real pid %d | priority %d\n", j + 1, st.pid[i], st.priority[i]);
 189:	8b 45 ec             	mov    -0x14(%ebp),%eax
 18c:	83 e8 80             	sub    $0xffffff80,%eax
 18f:	8b 14 85 80 0d 00 00 	mov    0xd80(,%eax,4),%edx
 196:	8b 45 ec             	mov    -0x14(%ebp),%eax
 199:	83 c0 40             	add    $0x40,%eax
 19c:	8b 04 85 80 0d 00 00 	mov    0xd80(,%eax,4),%eax
 1a3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
 1a6:	83 c1 01             	add    $0x1,%ecx
 1a9:	83 ec 0c             	sub    $0xc,%esp
 1ac:	52                   	push   %edx
 1ad:	50                   	push   %eax
 1ae:	51                   	push   %ecx
 1af:	68 98 0a 00 00       	push   $0xa98
 1b4:	6a 01                	push   $0x1
 1b6:	e8 ce 04 00 00       	call   689 <printf>
 1bb:	83 c4 20             	add    $0x20,%esp
                printf(1, "ticks      : [%d %d %d %d]\n",
 1be:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1c1:	c1 e0 04             	shl    $0x4,%eax
 1c4:	05 8c 11 00 00       	add    $0x118c,%eax
 1c9:	8b 18                	mov    (%eax),%ebx
 1cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1ce:	c1 e0 04             	shl    $0x4,%eax
 1d1:	05 88 11 00 00       	add    $0x1188,%eax
 1d6:	8b 08                	mov    (%eax),%ecx
 1d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1db:	c1 e0 04             	shl    $0x4,%eax
 1de:	05 84 11 00 00       	add    $0x1184,%eax
 1e3:	8b 10                	mov    (%eax),%edx
 1e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1e8:	83 c0 40             	add    $0x40,%eax
 1eb:	c1 e0 04             	shl    $0x4,%eax
 1ee:	05 80 0d 00 00       	add    $0xd80,%eax
 1f3:	8b 00                	mov    (%eax),%eax
 1f5:	83 ec 08             	sub    $0x8,%esp
 1f8:	53                   	push   %ebx
 1f9:	51                   	push   %ecx
 1fa:	52                   	push   %edx
 1fb:	50                   	push   %eax
 1fc:	68 bc 0a 00 00       	push   $0xabc
 201:	6a 01                	push   $0x1
 203:	e8 81 04 00 00       	call   689 <printf>
 208:	83 c4 20             	add    $0x20,%esp
                       st.ticks[i][0], st.ticks[i][1],
                       st.ticks[i][2], st.ticks[i][3]);
                printf(1, "wait_ticks : [%d %d %d %d]\n",
 20b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 20e:	c1 e0 04             	shl    $0x4,%eax
 211:	05 8c 15 00 00       	add    $0x158c,%eax
 216:	8b 18                	mov    (%eax),%ebx
 218:	8b 45 ec             	mov    -0x14(%ebp),%eax
 21b:	c1 e0 04             	shl    $0x4,%eax
 21e:	05 88 15 00 00       	add    $0x1588,%eax
 223:	8b 08                	mov    (%eax),%ecx
 225:	8b 45 ec             	mov    -0x14(%ebp),%eax
 228:	c1 e0 04             	shl    $0x4,%eax
 22b:	05 84 15 00 00       	add    $0x1584,%eax
 230:	8b 10                	mov    (%eax),%edx
 232:	8b 45 ec             	mov    -0x14(%ebp),%eax
 235:	83 e8 80             	sub    $0xffffff80,%eax
 238:	c1 e0 04             	shl    $0x4,%eax
 23b:	05 80 0d 00 00       	add    $0xd80,%eax
 240:	8b 00                	mov    (%eax),%eax
 242:	83 ec 08             	sub    $0x8,%esp
 245:	53                   	push   %ebx
 246:	51                   	push   %ecx
 247:	52                   	push   %edx
 248:	50                   	push   %eax
 249:	68 d8 0a 00 00       	push   $0xad8
 24e:	6a 01                	push   $0x1
 250:	e8 34 04 00 00       	call   689 <printf>
 255:	83 c4 20             	add    $0x20,%esp
                       st.wait_ticks[i][0], st.wait_ticks[i][1],
                       st.wait_ticks[i][2], st.wait_ticks[i][3]);
                printf(1, "\n");
 258:	83 ec 08             	sub    $0x8,%esp
 25b:	68 f4 0a 00 00       	push   $0xaf4
 260:	6a 01                	push   $0x1
 262:	e8 22 04 00 00       	call   689 <printf>
 267:	83 c4 10             	add    $0x10,%esp
        for (int j = 0; j < NUM_PROCS; j++) {
 26a:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
 26e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
 272:	0f 8e f5 fe ff ff    	jle    16d <main+0x13a>
 278:	eb 01                	jmp    27b <main+0x248>
            continue;
 27a:	90                   	nop
    for (int i = 0; i < NPROC; i++) {
 27b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 27f:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
 283:	0f 8e c6 fe ff ff    	jle    14f <main+0x11c>
            }
        }
    }

    for (int i = 0; i < NUM_PROCS; i++)
 289:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 290:	eb 09                	jmp    29b <main+0x268>
        wait();
 292:	e8 6e 02 00 00       	call   505 <wait>
    for (int i = 0; i < NUM_PROCS; i++)
 297:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 29b:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
 29f:	7e f1                	jle    292 <main+0x25f>

    exit();
 2a1:	e8 57 02 00 00       	call   4fd <exit>

000002a6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2a6:	55                   	push   %ebp
 2a7:	89 e5                	mov    %esp,%ebp
 2a9:	57                   	push   %edi
 2aa:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2ae:	8b 55 10             	mov    0x10(%ebp),%edx
 2b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b4:	89 cb                	mov    %ecx,%ebx
 2b6:	89 df                	mov    %ebx,%edi
 2b8:	89 d1                	mov    %edx,%ecx
 2ba:	fc                   	cld    
 2bb:	f3 aa                	rep stos %al,%es:(%edi)
 2bd:	89 ca                	mov    %ecx,%edx
 2bf:	89 fb                	mov    %edi,%ebx
 2c1:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2c4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2c7:	90                   	nop
 2c8:	5b                   	pop    %ebx
 2c9:	5f                   	pop    %edi
 2ca:	5d                   	pop    %ebp
 2cb:	c3                   	ret    

000002cc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2cc:	55                   	push   %ebp
 2cd:	89 e5                	mov    %esp,%ebp
 2cf:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2d2:	8b 45 08             	mov    0x8(%ebp),%eax
 2d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2d8:	90                   	nop
 2d9:	8b 55 0c             	mov    0xc(%ebp),%edx
 2dc:	8d 42 01             	lea    0x1(%edx),%eax
 2df:	89 45 0c             	mov    %eax,0xc(%ebp)
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	8d 48 01             	lea    0x1(%eax),%ecx
 2e8:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2eb:	0f b6 12             	movzbl (%edx),%edx
 2ee:	88 10                	mov    %dl,(%eax)
 2f0:	0f b6 00             	movzbl (%eax),%eax
 2f3:	84 c0                	test   %al,%al
 2f5:	75 e2                	jne    2d9 <strcpy+0xd>
    ;
  return os;
 2f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2fa:	c9                   	leave  
 2fb:	c3                   	ret    

000002fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2fc:	55                   	push   %ebp
 2fd:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2ff:	eb 08                	jmp    309 <strcmp+0xd>
    p++, q++;
 301:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 305:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	0f b6 00             	movzbl (%eax),%eax
 30f:	84 c0                	test   %al,%al
 311:	74 10                	je     323 <strcmp+0x27>
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	0f b6 10             	movzbl (%eax),%edx
 319:	8b 45 0c             	mov    0xc(%ebp),%eax
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	38 c2                	cmp    %al,%dl
 321:	74 de                	je     301 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	0f b6 d0             	movzbl %al,%edx
 32c:	8b 45 0c             	mov    0xc(%ebp),%eax
 32f:	0f b6 00             	movzbl (%eax),%eax
 332:	0f b6 c8             	movzbl %al,%ecx
 335:	89 d0                	mov    %edx,%eax
 337:	29 c8                	sub    %ecx,%eax
}
 339:	5d                   	pop    %ebp
 33a:	c3                   	ret    

0000033b <strlen>:

uint
strlen(char *s)
{
 33b:	55                   	push   %ebp
 33c:	89 e5                	mov    %esp,%ebp
 33e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 341:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 348:	eb 04                	jmp    34e <strlen+0x13>
 34a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 34e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 351:	8b 45 08             	mov    0x8(%ebp),%eax
 354:	01 d0                	add    %edx,%eax
 356:	0f b6 00             	movzbl (%eax),%eax
 359:	84 c0                	test   %al,%al
 35b:	75 ed                	jne    34a <strlen+0xf>
    ;
  return n;
 35d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 360:	c9                   	leave  
 361:	c3                   	ret    

00000362 <memset>:

void*
memset(void *dst, int c, uint n)
{
 362:	55                   	push   %ebp
 363:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 365:	8b 45 10             	mov    0x10(%ebp),%eax
 368:	50                   	push   %eax
 369:	ff 75 0c             	push   0xc(%ebp)
 36c:	ff 75 08             	push   0x8(%ebp)
 36f:	e8 32 ff ff ff       	call   2a6 <stosb>
 374:	83 c4 0c             	add    $0xc,%esp
  return dst;
 377:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37a:	c9                   	leave  
 37b:	c3                   	ret    

0000037c <strchr>:

char*
strchr(const char *s, char c)
{
 37c:	55                   	push   %ebp
 37d:	89 e5                	mov    %esp,%ebp
 37f:	83 ec 04             	sub    $0x4,%esp
 382:	8b 45 0c             	mov    0xc(%ebp),%eax
 385:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 388:	eb 14                	jmp    39e <strchr+0x22>
    if(*s == c)
 38a:	8b 45 08             	mov    0x8(%ebp),%eax
 38d:	0f b6 00             	movzbl (%eax),%eax
 390:	38 45 fc             	cmp    %al,-0x4(%ebp)
 393:	75 05                	jne    39a <strchr+0x1e>
      return (char*)s;
 395:	8b 45 08             	mov    0x8(%ebp),%eax
 398:	eb 13                	jmp    3ad <strchr+0x31>
  for(; *s; s++)
 39a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 39e:	8b 45 08             	mov    0x8(%ebp),%eax
 3a1:	0f b6 00             	movzbl (%eax),%eax
 3a4:	84 c0                	test   %al,%al
 3a6:	75 e2                	jne    38a <strchr+0xe>
  return 0;
 3a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3ad:	c9                   	leave  
 3ae:	c3                   	ret    

000003af <gets>:

char*
gets(char *buf, int max)
{
 3af:	55                   	push   %ebp
 3b0:	89 e5                	mov    %esp,%ebp
 3b2:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3bc:	eb 42                	jmp    400 <gets+0x51>
    cc = read(0, &c, 1);
 3be:	83 ec 04             	sub    $0x4,%esp
 3c1:	6a 01                	push   $0x1
 3c3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3c6:	50                   	push   %eax
 3c7:	6a 00                	push   $0x0
 3c9:	e8 47 01 00 00       	call   515 <read>
 3ce:	83 c4 10             	add    $0x10,%esp
 3d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3d8:	7e 33                	jle    40d <gets+0x5e>
      break;
    buf[i++] = c;
 3da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3dd:	8d 50 01             	lea    0x1(%eax),%edx
 3e0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3e3:	89 c2                	mov    %eax,%edx
 3e5:	8b 45 08             	mov    0x8(%ebp),%eax
 3e8:	01 c2                	add    %eax,%edx
 3ea:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3ee:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3f0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f4:	3c 0a                	cmp    $0xa,%al
 3f6:	74 16                	je     40e <gets+0x5f>
 3f8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3fc:	3c 0d                	cmp    $0xd,%al
 3fe:	74 0e                	je     40e <gets+0x5f>
  for(i=0; i+1 < max; ){
 400:	8b 45 f4             	mov    -0xc(%ebp),%eax
 403:	83 c0 01             	add    $0x1,%eax
 406:	39 45 0c             	cmp    %eax,0xc(%ebp)
 409:	7f b3                	jg     3be <gets+0xf>
 40b:	eb 01                	jmp    40e <gets+0x5f>
      break;
 40d:	90                   	nop
      break;
  }
  buf[i] = '\0';
 40e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 411:	8b 45 08             	mov    0x8(%ebp),%eax
 414:	01 d0                	add    %edx,%eax
 416:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 419:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41c:	c9                   	leave  
 41d:	c3                   	ret    

0000041e <stat>:

int
stat(char *n, struct stat *st)
{
 41e:	55                   	push   %ebp
 41f:	89 e5                	mov    %esp,%ebp
 421:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 424:	83 ec 08             	sub    $0x8,%esp
 427:	6a 00                	push   $0x0
 429:	ff 75 08             	push   0x8(%ebp)
 42c:	e8 0c 01 00 00       	call   53d <open>
 431:	83 c4 10             	add    $0x10,%esp
 434:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 437:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 43b:	79 07                	jns    444 <stat+0x26>
    return -1;
 43d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 442:	eb 25                	jmp    469 <stat+0x4b>
  r = fstat(fd, st);
 444:	83 ec 08             	sub    $0x8,%esp
 447:	ff 75 0c             	push   0xc(%ebp)
 44a:	ff 75 f4             	push   -0xc(%ebp)
 44d:	e8 03 01 00 00       	call   555 <fstat>
 452:	83 c4 10             	add    $0x10,%esp
 455:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 458:	83 ec 0c             	sub    $0xc,%esp
 45b:	ff 75 f4             	push   -0xc(%ebp)
 45e:	e8 c2 00 00 00       	call   525 <close>
 463:	83 c4 10             	add    $0x10,%esp
  return r;
 466:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 469:	c9                   	leave  
 46a:	c3                   	ret    

0000046b <atoi>:

int
atoi(const char *s)
{
 46b:	55                   	push   %ebp
 46c:	89 e5                	mov    %esp,%ebp
 46e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 471:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 478:	eb 25                	jmp    49f <atoi+0x34>
    n = n*10 + *s++ - '0';
 47a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 47d:	89 d0                	mov    %edx,%eax
 47f:	c1 e0 02             	shl    $0x2,%eax
 482:	01 d0                	add    %edx,%eax
 484:	01 c0                	add    %eax,%eax
 486:	89 c1                	mov    %eax,%ecx
 488:	8b 45 08             	mov    0x8(%ebp),%eax
 48b:	8d 50 01             	lea    0x1(%eax),%edx
 48e:	89 55 08             	mov    %edx,0x8(%ebp)
 491:	0f b6 00             	movzbl (%eax),%eax
 494:	0f be c0             	movsbl %al,%eax
 497:	01 c8                	add    %ecx,%eax
 499:	83 e8 30             	sub    $0x30,%eax
 49c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 49f:	8b 45 08             	mov    0x8(%ebp),%eax
 4a2:	0f b6 00             	movzbl (%eax),%eax
 4a5:	3c 2f                	cmp    $0x2f,%al
 4a7:	7e 0a                	jle    4b3 <atoi+0x48>
 4a9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ac:	0f b6 00             	movzbl (%eax),%eax
 4af:	3c 39                	cmp    $0x39,%al
 4b1:	7e c7                	jle    47a <atoi+0xf>
  return n;
 4b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b6:	c9                   	leave  
 4b7:	c3                   	ret    

000004b8 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4b8:	55                   	push   %ebp
 4b9:	89 e5                	mov    %esp,%ebp
 4bb:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4be:	8b 45 08             	mov    0x8(%ebp),%eax
 4c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4ca:	eb 17                	jmp    4e3 <memmove+0x2b>
    *dst++ = *src++;
 4cc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4cf:	8d 42 01             	lea    0x1(%edx),%eax
 4d2:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4d8:	8d 48 01             	lea    0x1(%eax),%ecx
 4db:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4de:	0f b6 12             	movzbl (%edx),%edx
 4e1:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4e3:	8b 45 10             	mov    0x10(%ebp),%eax
 4e6:	8d 50 ff             	lea    -0x1(%eax),%edx
 4e9:	89 55 10             	mov    %edx,0x10(%ebp)
 4ec:	85 c0                	test   %eax,%eax
 4ee:	7f dc                	jg     4cc <memmove+0x14>
  return vdst;
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f3:	c9                   	leave  
 4f4:	c3                   	ret    

000004f5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4f5:	b8 01 00 00 00       	mov    $0x1,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret    

000004fd <exit>:
SYSCALL(exit)
 4fd:	b8 02 00 00 00       	mov    $0x2,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret    

00000505 <wait>:
SYSCALL(wait)
 505:	b8 03 00 00 00       	mov    $0x3,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret    

0000050d <pipe>:
SYSCALL(pipe)
 50d:	b8 04 00 00 00       	mov    $0x4,%eax
 512:	cd 40                	int    $0x40
 514:	c3                   	ret    

00000515 <read>:
SYSCALL(read)
 515:	b8 05 00 00 00       	mov    $0x5,%eax
 51a:	cd 40                	int    $0x40
 51c:	c3                   	ret    

0000051d <write>:
SYSCALL(write)
 51d:	b8 10 00 00 00       	mov    $0x10,%eax
 522:	cd 40                	int    $0x40
 524:	c3                   	ret    

00000525 <close>:
SYSCALL(close)
 525:	b8 15 00 00 00       	mov    $0x15,%eax
 52a:	cd 40                	int    $0x40
 52c:	c3                   	ret    

0000052d <kill>:
SYSCALL(kill)
 52d:	b8 06 00 00 00       	mov    $0x6,%eax
 532:	cd 40                	int    $0x40
 534:	c3                   	ret    

00000535 <exec>:
SYSCALL(exec)
 535:	b8 07 00 00 00       	mov    $0x7,%eax
 53a:	cd 40                	int    $0x40
 53c:	c3                   	ret    

0000053d <open>:
SYSCALL(open)
 53d:	b8 0f 00 00 00       	mov    $0xf,%eax
 542:	cd 40                	int    $0x40
 544:	c3                   	ret    

00000545 <mknod>:
SYSCALL(mknod)
 545:	b8 11 00 00 00       	mov    $0x11,%eax
 54a:	cd 40                	int    $0x40
 54c:	c3                   	ret    

0000054d <unlink>:
SYSCALL(unlink)
 54d:	b8 12 00 00 00       	mov    $0x12,%eax
 552:	cd 40                	int    $0x40
 554:	c3                   	ret    

00000555 <fstat>:
SYSCALL(fstat)
 555:	b8 08 00 00 00       	mov    $0x8,%eax
 55a:	cd 40                	int    $0x40
 55c:	c3                   	ret    

0000055d <link>:
SYSCALL(link)
 55d:	b8 13 00 00 00       	mov    $0x13,%eax
 562:	cd 40                	int    $0x40
 564:	c3                   	ret    

00000565 <mkdir>:
SYSCALL(mkdir)
 565:	b8 14 00 00 00       	mov    $0x14,%eax
 56a:	cd 40                	int    $0x40
 56c:	c3                   	ret    

0000056d <chdir>:
SYSCALL(chdir)
 56d:	b8 09 00 00 00       	mov    $0x9,%eax
 572:	cd 40                	int    $0x40
 574:	c3                   	ret    

00000575 <dup>:
SYSCALL(dup)
 575:	b8 0a 00 00 00       	mov    $0xa,%eax
 57a:	cd 40                	int    $0x40
 57c:	c3                   	ret    

0000057d <getpid>:
SYSCALL(getpid)
 57d:	b8 0b 00 00 00       	mov    $0xb,%eax
 582:	cd 40                	int    $0x40
 584:	c3                   	ret    

00000585 <sbrk>:
SYSCALL(sbrk)
 585:	b8 0c 00 00 00       	mov    $0xc,%eax
 58a:	cd 40                	int    $0x40
 58c:	c3                   	ret    

0000058d <sleep>:
SYSCALL(sleep)
 58d:	b8 0d 00 00 00       	mov    $0xd,%eax
 592:	cd 40                	int    $0x40
 594:	c3                   	ret    

00000595 <uptime>:
SYSCALL(uptime)
 595:	b8 0e 00 00 00       	mov    $0xe,%eax
 59a:	cd 40                	int    $0x40
 59c:	c3                   	ret    

0000059d <getpinfo>:
SYSCALL(getpinfo)
 59d:	b8 16 00 00 00       	mov    $0x16,%eax
 5a2:	cd 40                	int    $0x40
 5a4:	c3                   	ret    

000005a5 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 5a5:	b8 17 00 00 00       	mov    $0x17,%eax
 5aa:	cd 40                	int    $0x40
 5ac:	c3                   	ret    

000005ad <getqinfo>:
 5ad:	b8 18 00 00 00       	mov    $0x18,%eax
 5b2:	cd 40                	int    $0x40
 5b4:	c3                   	ret    

000005b5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5b5:	55                   	push   %ebp
 5b6:	89 e5                	mov    %esp,%ebp
 5b8:	83 ec 18             	sub    $0x18,%esp
 5bb:	8b 45 0c             	mov    0xc(%ebp),%eax
 5be:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c1:	83 ec 04             	sub    $0x4,%esp
 5c4:	6a 01                	push   $0x1
 5c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5c9:	50                   	push   %eax
 5ca:	ff 75 08             	push   0x8(%ebp)
 5cd:	e8 4b ff ff ff       	call   51d <write>
 5d2:	83 c4 10             	add    $0x10,%esp
}
 5d5:	90                   	nop
 5d6:	c9                   	leave  
 5d7:	c3                   	ret    

000005d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5d8:	55                   	push   %ebp
 5d9:	89 e5                	mov    %esp,%ebp
 5db:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5de:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5e5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5e9:	74 17                	je     602 <printint+0x2a>
 5eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5ef:	79 11                	jns    602 <printint+0x2a>
    neg = 1;
 5f1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5fb:	f7 d8                	neg    %eax
 5fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 600:	eb 06                	jmp    608 <printint+0x30>
  } else {
    x = xx;
 602:	8b 45 0c             	mov    0xc(%ebp),%eax
 605:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 608:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 60f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 612:	8b 45 ec             	mov    -0x14(%ebp),%eax
 615:	ba 00 00 00 00       	mov    $0x0,%edx
 61a:	f7 f1                	div    %ecx
 61c:	89 d1                	mov    %edx,%ecx
 61e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 621:	8d 50 01             	lea    0x1(%eax),%edx
 624:	89 55 f4             	mov    %edx,-0xc(%ebp)
 627:	0f b6 91 68 0d 00 00 	movzbl 0xd68(%ecx),%edx
 62e:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 632:	8b 4d 10             	mov    0x10(%ebp),%ecx
 635:	8b 45 ec             	mov    -0x14(%ebp),%eax
 638:	ba 00 00 00 00       	mov    $0x0,%edx
 63d:	f7 f1                	div    %ecx
 63f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 642:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 646:	75 c7                	jne    60f <printint+0x37>
  if(neg)
 648:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 64c:	74 2d                	je     67b <printint+0xa3>
    buf[i++] = '-';
 64e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 651:	8d 50 01             	lea    0x1(%eax),%edx
 654:	89 55 f4             	mov    %edx,-0xc(%ebp)
 657:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 65c:	eb 1d                	jmp    67b <printint+0xa3>
    putc(fd, buf[i]);
 65e:	8d 55 dc             	lea    -0x24(%ebp),%edx
 661:	8b 45 f4             	mov    -0xc(%ebp),%eax
 664:	01 d0                	add    %edx,%eax
 666:	0f b6 00             	movzbl (%eax),%eax
 669:	0f be c0             	movsbl %al,%eax
 66c:	83 ec 08             	sub    $0x8,%esp
 66f:	50                   	push   %eax
 670:	ff 75 08             	push   0x8(%ebp)
 673:	e8 3d ff ff ff       	call   5b5 <putc>
 678:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 67b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 67f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 683:	79 d9                	jns    65e <printint+0x86>
}
 685:	90                   	nop
 686:	90                   	nop
 687:	c9                   	leave  
 688:	c3                   	ret    

00000689 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 689:	55                   	push   %ebp
 68a:	89 e5                	mov    %esp,%ebp
 68c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 68f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 696:	8d 45 0c             	lea    0xc(%ebp),%eax
 699:	83 c0 04             	add    $0x4,%eax
 69c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 69f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6a6:	e9 59 01 00 00       	jmp    804 <printf+0x17b>
    c = fmt[i] & 0xff;
 6ab:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b1:	01 d0                	add    %edx,%eax
 6b3:	0f b6 00             	movzbl (%eax),%eax
 6b6:	0f be c0             	movsbl %al,%eax
 6b9:	25 ff 00 00 00       	and    $0xff,%eax
 6be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6c5:	75 2c                	jne    6f3 <printf+0x6a>
      if(c == '%'){
 6c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6cb:	75 0c                	jne    6d9 <printf+0x50>
        state = '%';
 6cd:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6d4:	e9 27 01 00 00       	jmp    800 <printf+0x177>
      } else {
        putc(fd, c);
 6d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6dc:	0f be c0             	movsbl %al,%eax
 6df:	83 ec 08             	sub    $0x8,%esp
 6e2:	50                   	push   %eax
 6e3:	ff 75 08             	push   0x8(%ebp)
 6e6:	e8 ca fe ff ff       	call   5b5 <putc>
 6eb:	83 c4 10             	add    $0x10,%esp
 6ee:	e9 0d 01 00 00       	jmp    800 <printf+0x177>
      }
    } else if(state == '%'){
 6f3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6f7:	0f 85 03 01 00 00    	jne    800 <printf+0x177>
      if(c == 'd'){
 6fd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 701:	75 1e                	jne    721 <printf+0x98>
        printint(fd, *ap, 10, 1);
 703:	8b 45 e8             	mov    -0x18(%ebp),%eax
 706:	8b 00                	mov    (%eax),%eax
 708:	6a 01                	push   $0x1
 70a:	6a 0a                	push   $0xa
 70c:	50                   	push   %eax
 70d:	ff 75 08             	push   0x8(%ebp)
 710:	e8 c3 fe ff ff       	call   5d8 <printint>
 715:	83 c4 10             	add    $0x10,%esp
        ap++;
 718:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 71c:	e9 d8 00 00 00       	jmp    7f9 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 721:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 725:	74 06                	je     72d <printf+0xa4>
 727:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 72b:	75 1e                	jne    74b <printf+0xc2>
        printint(fd, *ap, 16, 0);
 72d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	6a 00                	push   $0x0
 734:	6a 10                	push   $0x10
 736:	50                   	push   %eax
 737:	ff 75 08             	push   0x8(%ebp)
 73a:	e8 99 fe ff ff       	call   5d8 <printint>
 73f:	83 c4 10             	add    $0x10,%esp
        ap++;
 742:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 746:	e9 ae 00 00 00       	jmp    7f9 <printf+0x170>
      } else if(c == 's'){
 74b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 74f:	75 43                	jne    794 <printf+0x10b>
        s = (char*)*ap;
 751:	8b 45 e8             	mov    -0x18(%ebp),%eax
 754:	8b 00                	mov    (%eax),%eax
 756:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 759:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 75d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 761:	75 25                	jne    788 <printf+0xff>
          s = "(null)";
 763:	c7 45 f4 f6 0a 00 00 	movl   $0xaf6,-0xc(%ebp)
        while(*s != 0){
 76a:	eb 1c                	jmp    788 <printf+0xff>
          putc(fd, *s);
 76c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76f:	0f b6 00             	movzbl (%eax),%eax
 772:	0f be c0             	movsbl %al,%eax
 775:	83 ec 08             	sub    $0x8,%esp
 778:	50                   	push   %eax
 779:	ff 75 08             	push   0x8(%ebp)
 77c:	e8 34 fe ff ff       	call   5b5 <putc>
 781:	83 c4 10             	add    $0x10,%esp
          s++;
 784:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 788:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78b:	0f b6 00             	movzbl (%eax),%eax
 78e:	84 c0                	test   %al,%al
 790:	75 da                	jne    76c <printf+0xe3>
 792:	eb 65                	jmp    7f9 <printf+0x170>
        }
      } else if(c == 'c'){
 794:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 798:	75 1d                	jne    7b7 <printf+0x12e>
        putc(fd, *ap);
 79a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 79d:	8b 00                	mov    (%eax),%eax
 79f:	0f be c0             	movsbl %al,%eax
 7a2:	83 ec 08             	sub    $0x8,%esp
 7a5:	50                   	push   %eax
 7a6:	ff 75 08             	push   0x8(%ebp)
 7a9:	e8 07 fe ff ff       	call   5b5 <putc>
 7ae:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b5:	eb 42                	jmp    7f9 <printf+0x170>
      } else if(c == '%'){
 7b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7bb:	75 17                	jne    7d4 <printf+0x14b>
        putc(fd, c);
 7bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c0:	0f be c0             	movsbl %al,%eax
 7c3:	83 ec 08             	sub    $0x8,%esp
 7c6:	50                   	push   %eax
 7c7:	ff 75 08             	push   0x8(%ebp)
 7ca:	e8 e6 fd ff ff       	call   5b5 <putc>
 7cf:	83 c4 10             	add    $0x10,%esp
 7d2:	eb 25                	jmp    7f9 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7d4:	83 ec 08             	sub    $0x8,%esp
 7d7:	6a 25                	push   $0x25
 7d9:	ff 75 08             	push   0x8(%ebp)
 7dc:	e8 d4 fd ff ff       	call   5b5 <putc>
 7e1:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7e7:	0f be c0             	movsbl %al,%eax
 7ea:	83 ec 08             	sub    $0x8,%esp
 7ed:	50                   	push   %eax
 7ee:	ff 75 08             	push   0x8(%ebp)
 7f1:	e8 bf fd ff ff       	call   5b5 <putc>
 7f6:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7f9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 800:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 804:	8b 55 0c             	mov    0xc(%ebp),%edx
 807:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80a:	01 d0                	add    %edx,%eax
 80c:	0f b6 00             	movzbl (%eax),%eax
 80f:	84 c0                	test   %al,%al
 811:	0f 85 94 fe ff ff    	jne    6ab <printf+0x22>
    }
  }
}
 817:	90                   	nop
 818:	90                   	nop
 819:	c9                   	leave  
 81a:	c3                   	ret    

0000081b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81b:	55                   	push   %ebp
 81c:	89 e5                	mov    %esp,%ebp
 81e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 821:	8b 45 08             	mov    0x8(%ebp),%eax
 824:	83 e8 08             	sub    $0x8,%eax
 827:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82a:	a1 88 19 00 00       	mov    0x1988,%eax
 82f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 832:	eb 24                	jmp    858 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 834:	8b 45 fc             	mov    -0x4(%ebp),%eax
 837:	8b 00                	mov    (%eax),%eax
 839:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 83c:	72 12                	jb     850 <free+0x35>
 83e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 841:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 844:	77 24                	ja     86a <free+0x4f>
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 00                	mov    (%eax),%eax
 84b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 84e:	72 1a                	jb     86a <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	8b 00                	mov    (%eax),%eax
 855:	89 45 fc             	mov    %eax,-0x4(%ebp)
 858:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 85e:	76 d4                	jbe    834 <free+0x19>
 860:	8b 45 fc             	mov    -0x4(%ebp),%eax
 863:	8b 00                	mov    (%eax),%eax
 865:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 868:	73 ca                	jae    834 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 86a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86d:	8b 40 04             	mov    0x4(%eax),%eax
 870:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 877:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87a:	01 c2                	add    %eax,%edx
 87c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87f:	8b 00                	mov    (%eax),%eax
 881:	39 c2                	cmp    %eax,%edx
 883:	75 24                	jne    8a9 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 885:	8b 45 f8             	mov    -0x8(%ebp),%eax
 888:	8b 50 04             	mov    0x4(%eax),%edx
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	8b 00                	mov    (%eax),%eax
 890:	8b 40 04             	mov    0x4(%eax),%eax
 893:	01 c2                	add    %eax,%edx
 895:	8b 45 f8             	mov    -0x8(%ebp),%eax
 898:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 89b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89e:	8b 00                	mov    (%eax),%eax
 8a0:	8b 10                	mov    (%eax),%edx
 8a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a5:	89 10                	mov    %edx,(%eax)
 8a7:	eb 0a                	jmp    8b3 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ac:	8b 10                	mov    (%eax),%edx
 8ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b1:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b6:	8b 40 04             	mov    0x4(%eax),%eax
 8b9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c3:	01 d0                	add    %edx,%eax
 8c5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8c8:	75 20                	jne    8ea <free+0xcf>
    p->s.size += bp->s.size;
 8ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cd:	8b 50 04             	mov    0x4(%eax),%edx
 8d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d3:	8b 40 04             	mov    0x4(%eax),%eax
 8d6:	01 c2                	add    %eax,%edx
 8d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8db:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e1:	8b 10                	mov    (%eax),%edx
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	89 10                	mov    %edx,(%eax)
 8e8:	eb 08                	jmp    8f2 <free+0xd7>
  } else
    p->s.ptr = bp;
 8ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ed:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8f0:	89 10                	mov    %edx,(%eax)
  freep = p;
 8f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f5:	a3 88 19 00 00       	mov    %eax,0x1988
}
 8fa:	90                   	nop
 8fb:	c9                   	leave  
 8fc:	c3                   	ret    

000008fd <morecore>:

static Header*
morecore(uint nu)
{
 8fd:	55                   	push   %ebp
 8fe:	89 e5                	mov    %esp,%ebp
 900:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 903:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 90a:	77 07                	ja     913 <morecore+0x16>
    nu = 4096;
 90c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 913:	8b 45 08             	mov    0x8(%ebp),%eax
 916:	c1 e0 03             	shl    $0x3,%eax
 919:	83 ec 0c             	sub    $0xc,%esp
 91c:	50                   	push   %eax
 91d:	e8 63 fc ff ff       	call   585 <sbrk>
 922:	83 c4 10             	add    $0x10,%esp
 925:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 928:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 92c:	75 07                	jne    935 <morecore+0x38>
    return 0;
 92e:	b8 00 00 00 00       	mov    $0x0,%eax
 933:	eb 26                	jmp    95b <morecore+0x5e>
  hp = (Header*)p;
 935:	8b 45 f4             	mov    -0xc(%ebp),%eax
 938:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 93b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93e:	8b 55 08             	mov    0x8(%ebp),%edx
 941:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 944:	8b 45 f0             	mov    -0x10(%ebp),%eax
 947:	83 c0 08             	add    $0x8,%eax
 94a:	83 ec 0c             	sub    $0xc,%esp
 94d:	50                   	push   %eax
 94e:	e8 c8 fe ff ff       	call   81b <free>
 953:	83 c4 10             	add    $0x10,%esp
  return freep;
 956:	a1 88 19 00 00       	mov    0x1988,%eax
}
 95b:	c9                   	leave  
 95c:	c3                   	ret    

0000095d <malloc>:

void*
malloc(uint nbytes)
{
 95d:	55                   	push   %ebp
 95e:	89 e5                	mov    %esp,%ebp
 960:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 963:	8b 45 08             	mov    0x8(%ebp),%eax
 966:	83 c0 07             	add    $0x7,%eax
 969:	c1 e8 03             	shr    $0x3,%eax
 96c:	83 c0 01             	add    $0x1,%eax
 96f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 972:	a1 88 19 00 00       	mov    0x1988,%eax
 977:	89 45 f0             	mov    %eax,-0x10(%ebp)
 97a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 97e:	75 23                	jne    9a3 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 980:	c7 45 f0 80 19 00 00 	movl   $0x1980,-0x10(%ebp)
 987:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98a:	a3 88 19 00 00       	mov    %eax,0x1988
 98f:	a1 88 19 00 00       	mov    0x1988,%eax
 994:	a3 80 19 00 00       	mov    %eax,0x1980
    base.s.size = 0;
 999:	c7 05 84 19 00 00 00 	movl   $0x0,0x1984
 9a0:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a6:	8b 00                	mov    (%eax),%eax
 9a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ae:	8b 40 04             	mov    0x4(%eax),%eax
 9b1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9b4:	77 4d                	ja     a03 <malloc+0xa6>
      if(p->s.size == nunits)
 9b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b9:	8b 40 04             	mov    0x4(%eax),%eax
 9bc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9bf:	75 0c                	jne    9cd <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c4:	8b 10                	mov    (%eax),%edx
 9c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c9:	89 10                	mov    %edx,(%eax)
 9cb:	eb 26                	jmp    9f3 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d0:	8b 40 04             	mov    0x4(%eax),%eax
 9d3:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9d6:	89 c2                	mov    %eax,%edx
 9d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9db:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e1:	8b 40 04             	mov    0x4(%eax),%eax
 9e4:	c1 e0 03             	shl    $0x3,%eax
 9e7:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9f0:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f6:	a3 88 19 00 00       	mov    %eax,0x1988
      return (void*)(p + 1);
 9fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fe:	83 c0 08             	add    $0x8,%eax
 a01:	eb 3b                	jmp    a3e <malloc+0xe1>
    }
    if(p == freep)
 a03:	a1 88 19 00 00       	mov    0x1988,%eax
 a08:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a0b:	75 1e                	jne    a2b <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a0d:	83 ec 0c             	sub    $0xc,%esp
 a10:	ff 75 ec             	push   -0x14(%ebp)
 a13:	e8 e5 fe ff ff       	call   8fd <morecore>
 a18:	83 c4 10             	add    $0x10,%esp
 a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a22:	75 07                	jne    a2b <malloc+0xce>
        return 0;
 a24:	b8 00 00 00 00       	mov    $0x0,%eax
 a29:	eb 13                	jmp    a3e <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a34:	8b 00                	mov    (%eax),%eax
 a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a39:	e9 6d ff ff ff       	jmp    9ab <malloc+0x4e>
  }
}
 a3e:	c9                   	leave  
 a3f:	c3                   	ret    
