
_test1:     file format elf32-i386


Disassembly of section .text:

00000000 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
   5:	8b 4d 08             	mov    0x8(%ebp),%ecx
   8:	8b 55 10             	mov    0x10(%ebp),%edx
   b:	8b 45 0c             	mov    0xc(%ebp),%eax
   e:	89 cb                	mov    %ecx,%ebx
  10:	89 df                	mov    %ebx,%edi
  12:	89 d1                	mov    %edx,%ecx
  14:	fc                   	cld    
  15:	f3 aa                	rep stos %al,%es:(%edi)
  17:	89 ca                	mov    %ecx,%edx
  19:	89 fb                	mov    %edi,%ebx
  1b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  1e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  21:	90                   	nop
  22:	5b                   	pop    %ebx
  23:	5f                   	pop    %edi
  24:	5d                   	pop    %ebp
  25:	c3                   	ret    

00000026 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  26:	55                   	push   %ebp
  27:	89 e5                	mov    %esp,%ebp
  29:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  2c:	8b 45 08             	mov    0x8(%ebp),%eax
  2f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  32:	90                   	nop
  33:	8b 55 0c             	mov    0xc(%ebp),%edx
  36:	8d 42 01             	lea    0x1(%edx),%eax
  39:	89 45 0c             	mov    %eax,0xc(%ebp)
  3c:	8b 45 08             	mov    0x8(%ebp),%eax
  3f:	8d 48 01             	lea    0x1(%eax),%ecx
  42:	89 4d 08             	mov    %ecx,0x8(%ebp)
  45:	0f b6 12             	movzbl (%edx),%edx
  48:	88 10                	mov    %dl,(%eax)
  4a:	0f b6 00             	movzbl (%eax),%eax
  4d:	84 c0                	test   %al,%al
  4f:	75 e2                	jne    33 <strcpy+0xd>
    ;
  return os;
  51:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  54:	c9                   	leave  
  55:	c3                   	ret    

00000056 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  56:	55                   	push   %ebp
  57:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  59:	eb 08                	jmp    63 <strcmp+0xd>
    p++, q++;
  5b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  5f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  63:	8b 45 08             	mov    0x8(%ebp),%eax
  66:	0f b6 00             	movzbl (%eax),%eax
  69:	84 c0                	test   %al,%al
  6b:	74 10                	je     7d <strcmp+0x27>
  6d:	8b 45 08             	mov    0x8(%ebp),%eax
  70:	0f b6 10             	movzbl (%eax),%edx
  73:	8b 45 0c             	mov    0xc(%ebp),%eax
  76:	0f b6 00             	movzbl (%eax),%eax
  79:	38 c2                	cmp    %al,%dl
  7b:	74 de                	je     5b <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  7d:	8b 45 08             	mov    0x8(%ebp),%eax
  80:	0f b6 00             	movzbl (%eax),%eax
  83:	0f b6 d0             	movzbl %al,%edx
  86:	8b 45 0c             	mov    0xc(%ebp),%eax
  89:	0f b6 00             	movzbl (%eax),%eax
  8c:	0f b6 c8             	movzbl %al,%ecx
  8f:	89 d0                	mov    %edx,%eax
  91:	29 c8                	sub    %ecx,%eax
}
  93:	5d                   	pop    %ebp
  94:	c3                   	ret    

00000095 <strlen>:

uint
strlen(char *s)
{
  95:	55                   	push   %ebp
  96:	89 e5                	mov    %esp,%ebp
  98:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  9b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  a2:	eb 04                	jmp    a8 <strlen+0x13>
  a4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  a8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  ab:	8b 45 08             	mov    0x8(%ebp),%eax
  ae:	01 d0                	add    %edx,%eax
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	84 c0                	test   %al,%al
  b5:	75 ed                	jne    a4 <strlen+0xf>
    ;
  return n;
  b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ba:	c9                   	leave  
  bb:	c3                   	ret    

000000bc <memset>:

void*
memset(void *dst, int c, uint n)
{
  bc:	55                   	push   %ebp
  bd:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
  bf:	8b 45 10             	mov    0x10(%ebp),%eax
  c2:	50                   	push   %eax
  c3:	ff 75 0c             	push   0xc(%ebp)
  c6:	ff 75 08             	push   0x8(%ebp)
  c9:	e8 32 ff ff ff       	call   0 <stosb>
  ce:	83 c4 0c             	add    $0xc,%esp
  return dst;
  d1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  d4:	c9                   	leave  
  d5:	c3                   	ret    

000000d6 <strchr>:

char*
strchr(const char *s, char c)
{
  d6:	55                   	push   %ebp
  d7:	89 e5                	mov    %esp,%ebp
  d9:	83 ec 04             	sub    $0x4,%esp
  dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  df:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  e2:	eb 14                	jmp    f8 <strchr+0x22>
    if(*s == c)
  e4:	8b 45 08             	mov    0x8(%ebp),%eax
  e7:	0f b6 00             	movzbl (%eax),%eax
  ea:	38 45 fc             	cmp    %al,-0x4(%ebp)
  ed:	75 05                	jne    f4 <strchr+0x1e>
      return (char*)s;
  ef:	8b 45 08             	mov    0x8(%ebp),%eax
  f2:	eb 13                	jmp    107 <strchr+0x31>
  for(; *s; s++)
  f4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  f8:	8b 45 08             	mov    0x8(%ebp),%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	84 c0                	test   %al,%al
 100:	75 e2                	jne    e4 <strchr+0xe>
  return 0;
 102:	b8 00 00 00 00       	mov    $0x0,%eax
}
 107:	c9                   	leave  
 108:	c3                   	ret    

00000109 <gets>:

char*
gets(char *buf, int max)
{
 109:	55                   	push   %ebp
 10a:	89 e5                	mov    %esp,%ebp
 10c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 10f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 116:	eb 42                	jmp    15a <gets+0x51>
    cc = read(0, &c, 1);
 118:	83 ec 04             	sub    $0x4,%esp
 11b:	6a 01                	push   $0x1
 11d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 120:	50                   	push   %eax
 121:	6a 00                	push   $0x0
 123:	e8 47 01 00 00       	call   26f <read>
 128:	83 c4 10             	add    $0x10,%esp
 12b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 12e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 132:	7e 33                	jle    167 <gets+0x5e>
      break;
    buf[i++] = c;
 134:	8b 45 f4             	mov    -0xc(%ebp),%eax
 137:	8d 50 01             	lea    0x1(%eax),%edx
 13a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 13d:	89 c2                	mov    %eax,%edx
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	01 c2                	add    %eax,%edx
 144:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 148:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 14a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 14e:	3c 0a                	cmp    $0xa,%al
 150:	74 16                	je     168 <gets+0x5f>
 152:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 156:	3c 0d                	cmp    $0xd,%al
 158:	74 0e                	je     168 <gets+0x5f>
  for(i=0; i+1 < max; ){
 15a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15d:	83 c0 01             	add    $0x1,%eax
 160:	39 45 0c             	cmp    %eax,0xc(%ebp)
 163:	7f b3                	jg     118 <gets+0xf>
 165:	eb 01                	jmp    168 <gets+0x5f>
      break;
 167:	90                   	nop
      break;
  }
  buf[i] = '\0';
 168:	8b 55 f4             	mov    -0xc(%ebp),%edx
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	01 d0                	add    %edx,%eax
 170:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 173:	8b 45 08             	mov    0x8(%ebp),%eax
}
 176:	c9                   	leave  
 177:	c3                   	ret    

00000178 <stat>:

int
stat(char *n, struct stat *st)
{
 178:	55                   	push   %ebp
 179:	89 e5                	mov    %esp,%ebp
 17b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17e:	83 ec 08             	sub    $0x8,%esp
 181:	6a 00                	push   $0x0
 183:	ff 75 08             	push   0x8(%ebp)
 186:	e8 0c 01 00 00       	call   297 <open>
 18b:	83 c4 10             	add    $0x10,%esp
 18e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 191:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 195:	79 07                	jns    19e <stat+0x26>
    return -1;
 197:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 19c:	eb 25                	jmp    1c3 <stat+0x4b>
  r = fstat(fd, st);
 19e:	83 ec 08             	sub    $0x8,%esp
 1a1:	ff 75 0c             	push   0xc(%ebp)
 1a4:	ff 75 f4             	push   -0xc(%ebp)
 1a7:	e8 03 01 00 00       	call   2af <fstat>
 1ac:	83 c4 10             	add    $0x10,%esp
 1af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1b2:	83 ec 0c             	sub    $0xc,%esp
 1b5:	ff 75 f4             	push   -0xc(%ebp)
 1b8:	e8 c2 00 00 00       	call   27f <close>
 1bd:	83 c4 10             	add    $0x10,%esp
  return r;
 1c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1c3:	c9                   	leave  
 1c4:	c3                   	ret    

000001c5 <atoi>:

int
atoi(const char *s)
{
 1c5:	55                   	push   %ebp
 1c6:	89 e5                	mov    %esp,%ebp
 1c8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1d2:	eb 25                	jmp    1f9 <atoi+0x34>
    n = n*10 + *s++ - '0';
 1d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1d7:	89 d0                	mov    %edx,%eax
 1d9:	c1 e0 02             	shl    $0x2,%eax
 1dc:	01 d0                	add    %edx,%eax
 1de:	01 c0                	add    %eax,%eax
 1e0:	89 c1                	mov    %eax,%ecx
 1e2:	8b 45 08             	mov    0x8(%ebp),%eax
 1e5:	8d 50 01             	lea    0x1(%eax),%edx
 1e8:	89 55 08             	mov    %edx,0x8(%ebp)
 1eb:	0f b6 00             	movzbl (%eax),%eax
 1ee:	0f be c0             	movsbl %al,%eax
 1f1:	01 c8                	add    %ecx,%eax
 1f3:	83 e8 30             	sub    $0x30,%eax
 1f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	0f b6 00             	movzbl (%eax),%eax
 1ff:	3c 2f                	cmp    $0x2f,%al
 201:	7e 0a                	jle    20d <atoi+0x48>
 203:	8b 45 08             	mov    0x8(%ebp),%eax
 206:	0f b6 00             	movzbl (%eax),%eax
 209:	3c 39                	cmp    $0x39,%al
 20b:	7e c7                	jle    1d4 <atoi+0xf>
  return n;
 20d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 210:	c9                   	leave  
 211:	c3                   	ret    

00000212 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 212:	55                   	push   %ebp
 213:	89 e5                	mov    %esp,%ebp
 215:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 218:	8b 45 08             	mov    0x8(%ebp),%eax
 21b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 21e:	8b 45 0c             	mov    0xc(%ebp),%eax
 221:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 224:	eb 17                	jmp    23d <memmove+0x2b>
    *dst++ = *src++;
 226:	8b 55 f8             	mov    -0x8(%ebp),%edx
 229:	8d 42 01             	lea    0x1(%edx),%eax
 22c:	89 45 f8             	mov    %eax,-0x8(%ebp)
 22f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 232:	8d 48 01             	lea    0x1(%eax),%ecx
 235:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 238:	0f b6 12             	movzbl (%edx),%edx
 23b:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 23d:	8b 45 10             	mov    0x10(%ebp),%eax
 240:	8d 50 ff             	lea    -0x1(%eax),%edx
 243:	89 55 10             	mov    %edx,0x10(%ebp)
 246:	85 c0                	test   %eax,%eax
 248:	7f dc                	jg     226 <memmove+0x14>
  return vdst;
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 24d:	c9                   	leave  
 24e:	c3                   	ret    

0000024f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 24f:	b8 01 00 00 00       	mov    $0x1,%eax
 254:	cd 40                	int    $0x40
 256:	c3                   	ret    

00000257 <exit>:
SYSCALL(exit)
 257:	b8 02 00 00 00       	mov    $0x2,%eax
 25c:	cd 40                	int    $0x40
 25e:	c3                   	ret    

0000025f <wait>:
SYSCALL(wait)
 25f:	b8 03 00 00 00       	mov    $0x3,%eax
 264:	cd 40                	int    $0x40
 266:	c3                   	ret    

00000267 <pipe>:
SYSCALL(pipe)
 267:	b8 04 00 00 00       	mov    $0x4,%eax
 26c:	cd 40                	int    $0x40
 26e:	c3                   	ret    

0000026f <read>:
SYSCALL(read)
 26f:	b8 05 00 00 00       	mov    $0x5,%eax
 274:	cd 40                	int    $0x40
 276:	c3                   	ret    

00000277 <write>:
SYSCALL(write)
 277:	b8 10 00 00 00       	mov    $0x10,%eax
 27c:	cd 40                	int    $0x40
 27e:	c3                   	ret    

0000027f <close>:
SYSCALL(close)
 27f:	b8 15 00 00 00       	mov    $0x15,%eax
 284:	cd 40                	int    $0x40
 286:	c3                   	ret    

00000287 <kill>:
SYSCALL(kill)
 287:	b8 06 00 00 00       	mov    $0x6,%eax
 28c:	cd 40                	int    $0x40
 28e:	c3                   	ret    

0000028f <exec>:
SYSCALL(exec)
 28f:	b8 07 00 00 00       	mov    $0x7,%eax
 294:	cd 40                	int    $0x40
 296:	c3                   	ret    

00000297 <open>:
SYSCALL(open)
 297:	b8 0f 00 00 00       	mov    $0xf,%eax
 29c:	cd 40                	int    $0x40
 29e:	c3                   	ret    

0000029f <mknod>:
SYSCALL(mknod)
 29f:	b8 11 00 00 00       	mov    $0x11,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <unlink>:
SYSCALL(unlink)
 2a7:	b8 12 00 00 00       	mov    $0x12,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <fstat>:
SYSCALL(fstat)
 2af:	b8 08 00 00 00       	mov    $0x8,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    

000002b7 <link>:
SYSCALL(link)
 2b7:	b8 13 00 00 00       	mov    $0x13,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <mkdir>:
SYSCALL(mkdir)
 2bf:	b8 14 00 00 00       	mov    $0x14,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret    

000002c7 <chdir>:
SYSCALL(chdir)
 2c7:	b8 09 00 00 00       	mov    $0x9,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <dup>:
SYSCALL(dup)
 2cf:	b8 0a 00 00 00       	mov    $0xa,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <getpid>:
SYSCALL(getpid)
 2d7:	b8 0b 00 00 00       	mov    $0xb,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <sbrk>:
SYSCALL(sbrk)
 2df:	b8 0c 00 00 00       	mov    $0xc,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <sleep>:
SYSCALL(sleep)
 2e7:	b8 0d 00 00 00       	mov    $0xd,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <uptime>:
SYSCALL(uptime)
 2ef:	b8 0e 00 00 00       	mov    $0xe,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <getpinfo>:
SYSCALL(getpinfo)
 2f7:	b8 16 00 00 00       	mov    $0x16,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 2ff:	b8 17 00 00 00       	mov    $0x17,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <getqinfo>:
 307:	b8 18 00 00 00       	mov    $0x18,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 30f:	55                   	push   %ebp
 310:	89 e5                	mov    %esp,%ebp
 312:	83 ec 18             	sub    $0x18,%esp
 315:	8b 45 0c             	mov    0xc(%ebp),%eax
 318:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 31b:	83 ec 04             	sub    $0x4,%esp
 31e:	6a 01                	push   $0x1
 320:	8d 45 f4             	lea    -0xc(%ebp),%eax
 323:	50                   	push   %eax
 324:	ff 75 08             	push   0x8(%ebp)
 327:	e8 4b ff ff ff       	call   277 <write>
 32c:	83 c4 10             	add    $0x10,%esp
}
 32f:	90                   	nop
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 338:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 33f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 343:	74 17                	je     35c <printint+0x2a>
 345:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 349:	79 11                	jns    35c <printint+0x2a>
    neg = 1;
 34b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 352:	8b 45 0c             	mov    0xc(%ebp),%eax
 355:	f7 d8                	neg    %eax
 357:	89 45 ec             	mov    %eax,-0x14(%ebp)
 35a:	eb 06                	jmp    362 <printint+0x30>
  } else {
    x = xx;
 35c:	8b 45 0c             	mov    0xc(%ebp),%eax
 35f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 362:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 369:	8b 4d 10             	mov    0x10(%ebp),%ecx
 36c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 36f:	ba 00 00 00 00       	mov    $0x0,%edx
 374:	f7 f1                	div    %ecx
 376:	89 d1                	mov    %edx,%ecx
 378:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37b:	8d 50 01             	lea    0x1(%eax),%edx
 37e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 381:	0f b6 91 c4 09 00 00 	movzbl 0x9c4(%ecx),%edx
 388:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 38c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 38f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 392:	ba 00 00 00 00       	mov    $0x0,%edx
 397:	f7 f1                	div    %ecx
 399:	89 45 ec             	mov    %eax,-0x14(%ebp)
 39c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3a0:	75 c7                	jne    369 <printint+0x37>
  if(neg)
 3a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3a6:	74 2d                	je     3d5 <printint+0xa3>
    buf[i++] = '-';
 3a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ab:	8d 50 01             	lea    0x1(%eax),%edx
 3ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3b1:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3b6:	eb 1d                	jmp    3d5 <printint+0xa3>
    putc(fd, buf[i]);
 3b8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3be:	01 d0                	add    %edx,%eax
 3c0:	0f b6 00             	movzbl (%eax),%eax
 3c3:	0f be c0             	movsbl %al,%eax
 3c6:	83 ec 08             	sub    $0x8,%esp
 3c9:	50                   	push   %eax
 3ca:	ff 75 08             	push   0x8(%ebp)
 3cd:	e8 3d ff ff ff       	call   30f <putc>
 3d2:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 3d5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3dd:	79 d9                	jns    3b8 <printint+0x86>
}
 3df:	90                   	nop
 3e0:	90                   	nop
 3e1:	c9                   	leave  
 3e2:	c3                   	ret    

000003e3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 3e3:	55                   	push   %ebp
 3e4:	89 e5                	mov    %esp,%ebp
 3e6:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 3e9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 3f0:	8d 45 0c             	lea    0xc(%ebp),%eax
 3f3:	83 c0 04             	add    $0x4,%eax
 3f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 3f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 400:	e9 59 01 00 00       	jmp    55e <printf+0x17b>
    c = fmt[i] & 0xff;
 405:	8b 55 0c             	mov    0xc(%ebp),%edx
 408:	8b 45 f0             	mov    -0x10(%ebp),%eax
 40b:	01 d0                	add    %edx,%eax
 40d:	0f b6 00             	movzbl (%eax),%eax
 410:	0f be c0             	movsbl %al,%eax
 413:	25 ff 00 00 00       	and    $0xff,%eax
 418:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 41b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 41f:	75 2c                	jne    44d <printf+0x6a>
      if(c == '%'){
 421:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 425:	75 0c                	jne    433 <printf+0x50>
        state = '%';
 427:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 42e:	e9 27 01 00 00       	jmp    55a <printf+0x177>
      } else {
        putc(fd, c);
 433:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 436:	0f be c0             	movsbl %al,%eax
 439:	83 ec 08             	sub    $0x8,%esp
 43c:	50                   	push   %eax
 43d:	ff 75 08             	push   0x8(%ebp)
 440:	e8 ca fe ff ff       	call   30f <putc>
 445:	83 c4 10             	add    $0x10,%esp
 448:	e9 0d 01 00 00       	jmp    55a <printf+0x177>
      }
    } else if(state == '%'){
 44d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 451:	0f 85 03 01 00 00    	jne    55a <printf+0x177>
      if(c == 'd'){
 457:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 45b:	75 1e                	jne    47b <printf+0x98>
        printint(fd, *ap, 10, 1);
 45d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 460:	8b 00                	mov    (%eax),%eax
 462:	6a 01                	push   $0x1
 464:	6a 0a                	push   $0xa
 466:	50                   	push   %eax
 467:	ff 75 08             	push   0x8(%ebp)
 46a:	e8 c3 fe ff ff       	call   332 <printint>
 46f:	83 c4 10             	add    $0x10,%esp
        ap++;
 472:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 476:	e9 d8 00 00 00       	jmp    553 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 47b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 47f:	74 06                	je     487 <printf+0xa4>
 481:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 485:	75 1e                	jne    4a5 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 487:	8b 45 e8             	mov    -0x18(%ebp),%eax
 48a:	8b 00                	mov    (%eax),%eax
 48c:	6a 00                	push   $0x0
 48e:	6a 10                	push   $0x10
 490:	50                   	push   %eax
 491:	ff 75 08             	push   0x8(%ebp)
 494:	e8 99 fe ff ff       	call   332 <printint>
 499:	83 c4 10             	add    $0x10,%esp
        ap++;
 49c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4a0:	e9 ae 00 00 00       	jmp    553 <printf+0x170>
      } else if(c == 's'){
 4a5:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4a9:	75 43                	jne    4ee <printf+0x10b>
        s = (char*)*ap;
 4ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ae:	8b 00                	mov    (%eax),%eax
 4b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4bb:	75 25                	jne    4e2 <printf+0xff>
          s = "(null)";
 4bd:	c7 45 f4 9a 07 00 00 	movl   $0x79a,-0xc(%ebp)
        while(*s != 0){
 4c4:	eb 1c                	jmp    4e2 <printf+0xff>
          putc(fd, *s);
 4c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c9:	0f b6 00             	movzbl (%eax),%eax
 4cc:	0f be c0             	movsbl %al,%eax
 4cf:	83 ec 08             	sub    $0x8,%esp
 4d2:	50                   	push   %eax
 4d3:	ff 75 08             	push   0x8(%ebp)
 4d6:	e8 34 fe ff ff       	call   30f <putc>
 4db:	83 c4 10             	add    $0x10,%esp
          s++;
 4de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 4e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e5:	0f b6 00             	movzbl (%eax),%eax
 4e8:	84 c0                	test   %al,%al
 4ea:	75 da                	jne    4c6 <printf+0xe3>
 4ec:	eb 65                	jmp    553 <printf+0x170>
        }
      } else if(c == 'c'){
 4ee:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 4f2:	75 1d                	jne    511 <printf+0x12e>
        putc(fd, *ap);
 4f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f7:	8b 00                	mov    (%eax),%eax
 4f9:	0f be c0             	movsbl %al,%eax
 4fc:	83 ec 08             	sub    $0x8,%esp
 4ff:	50                   	push   %eax
 500:	ff 75 08             	push   0x8(%ebp)
 503:	e8 07 fe ff ff       	call   30f <putc>
 508:	83 c4 10             	add    $0x10,%esp
        ap++;
 50b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 50f:	eb 42                	jmp    553 <printf+0x170>
      } else if(c == '%'){
 511:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 515:	75 17                	jne    52e <printf+0x14b>
        putc(fd, c);
 517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51a:	0f be c0             	movsbl %al,%eax
 51d:	83 ec 08             	sub    $0x8,%esp
 520:	50                   	push   %eax
 521:	ff 75 08             	push   0x8(%ebp)
 524:	e8 e6 fd ff ff       	call   30f <putc>
 529:	83 c4 10             	add    $0x10,%esp
 52c:	eb 25                	jmp    553 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 52e:	83 ec 08             	sub    $0x8,%esp
 531:	6a 25                	push   $0x25
 533:	ff 75 08             	push   0x8(%ebp)
 536:	e8 d4 fd ff ff       	call   30f <putc>
 53b:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 53e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 541:	0f be c0             	movsbl %al,%eax
 544:	83 ec 08             	sub    $0x8,%esp
 547:	50                   	push   %eax
 548:	ff 75 08             	push   0x8(%ebp)
 54b:	e8 bf fd ff ff       	call   30f <putc>
 550:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 553:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 55a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 55e:	8b 55 0c             	mov    0xc(%ebp),%edx
 561:	8b 45 f0             	mov    -0x10(%ebp),%eax
 564:	01 d0                	add    %edx,%eax
 566:	0f b6 00             	movzbl (%eax),%eax
 569:	84 c0                	test   %al,%al
 56b:	0f 85 94 fe ff ff    	jne    405 <printf+0x22>
    }
  }
}
 571:	90                   	nop
 572:	90                   	nop
 573:	c9                   	leave  
 574:	c3                   	ret    

00000575 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 575:	55                   	push   %ebp
 576:	89 e5                	mov    %esp,%ebp
 578:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 57b:	8b 45 08             	mov    0x8(%ebp),%eax
 57e:	83 e8 08             	sub    $0x8,%eax
 581:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 584:	a1 e0 09 00 00       	mov    0x9e0,%eax
 589:	89 45 fc             	mov    %eax,-0x4(%ebp)
 58c:	eb 24                	jmp    5b2 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 58e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 591:	8b 00                	mov    (%eax),%eax
 593:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 596:	72 12                	jb     5aa <free+0x35>
 598:	8b 45 f8             	mov    -0x8(%ebp),%eax
 59b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 59e:	77 24                	ja     5c4 <free+0x4f>
 5a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5a3:	8b 00                	mov    (%eax),%eax
 5a5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5a8:	72 1a                	jb     5c4 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ad:	8b 00                	mov    (%eax),%eax
 5af:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5b5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5b8:	76 d4                	jbe    58e <free+0x19>
 5ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5bd:	8b 00                	mov    (%eax),%eax
 5bf:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5c2:	73 ca                	jae    58e <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5c7:	8b 40 04             	mov    0x4(%eax),%eax
 5ca:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 5d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d4:	01 c2                	add    %eax,%edx
 5d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d9:	8b 00                	mov    (%eax),%eax
 5db:	39 c2                	cmp    %eax,%edx
 5dd:	75 24                	jne    603 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 5df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5e2:	8b 50 04             	mov    0x4(%eax),%edx
 5e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e8:	8b 00                	mov    (%eax),%eax
 5ea:	8b 40 04             	mov    0x4(%eax),%eax
 5ed:	01 c2                	add    %eax,%edx
 5ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f2:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 5f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f8:	8b 00                	mov    (%eax),%eax
 5fa:	8b 10                	mov    (%eax),%edx
 5fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ff:	89 10                	mov    %edx,(%eax)
 601:	eb 0a                	jmp    60d <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 603:	8b 45 fc             	mov    -0x4(%ebp),%eax
 606:	8b 10                	mov    (%eax),%edx
 608:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 60d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 610:	8b 40 04             	mov    0x4(%eax),%eax
 613:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 61a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61d:	01 d0                	add    %edx,%eax
 61f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 622:	75 20                	jne    644 <free+0xcf>
    p->s.size += bp->s.size;
 624:	8b 45 fc             	mov    -0x4(%ebp),%eax
 627:	8b 50 04             	mov    0x4(%eax),%edx
 62a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62d:	8b 40 04             	mov    0x4(%eax),%eax
 630:	01 c2                	add    %eax,%edx
 632:	8b 45 fc             	mov    -0x4(%ebp),%eax
 635:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 638:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63b:	8b 10                	mov    (%eax),%edx
 63d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 640:	89 10                	mov    %edx,(%eax)
 642:	eb 08                	jmp    64c <free+0xd7>
  } else
    p->s.ptr = bp;
 644:	8b 45 fc             	mov    -0x4(%ebp),%eax
 647:	8b 55 f8             	mov    -0x8(%ebp),%edx
 64a:	89 10                	mov    %edx,(%eax)
  freep = p;
 64c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64f:	a3 e0 09 00 00       	mov    %eax,0x9e0
}
 654:	90                   	nop
 655:	c9                   	leave  
 656:	c3                   	ret    

00000657 <morecore>:

static Header*
morecore(uint nu)
{
 657:	55                   	push   %ebp
 658:	89 e5                	mov    %esp,%ebp
 65a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 65d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 664:	77 07                	ja     66d <morecore+0x16>
    nu = 4096;
 666:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 66d:	8b 45 08             	mov    0x8(%ebp),%eax
 670:	c1 e0 03             	shl    $0x3,%eax
 673:	83 ec 0c             	sub    $0xc,%esp
 676:	50                   	push   %eax
 677:	e8 63 fc ff ff       	call   2df <sbrk>
 67c:	83 c4 10             	add    $0x10,%esp
 67f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 682:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 686:	75 07                	jne    68f <morecore+0x38>
    return 0;
 688:	b8 00 00 00 00       	mov    $0x0,%eax
 68d:	eb 26                	jmp    6b5 <morecore+0x5e>
  hp = (Header*)p;
 68f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 692:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 695:	8b 45 f0             	mov    -0x10(%ebp),%eax
 698:	8b 55 08             	mov    0x8(%ebp),%edx
 69b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 69e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a1:	83 c0 08             	add    $0x8,%eax
 6a4:	83 ec 0c             	sub    $0xc,%esp
 6a7:	50                   	push   %eax
 6a8:	e8 c8 fe ff ff       	call   575 <free>
 6ad:	83 c4 10             	add    $0x10,%esp
  return freep;
 6b0:	a1 e0 09 00 00       	mov    0x9e0,%eax
}
 6b5:	c9                   	leave  
 6b6:	c3                   	ret    

000006b7 <malloc>:

void*
malloc(uint nbytes)
{
 6b7:	55                   	push   %ebp
 6b8:	89 e5                	mov    %esp,%ebp
 6ba:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6bd:	8b 45 08             	mov    0x8(%ebp),%eax
 6c0:	83 c0 07             	add    $0x7,%eax
 6c3:	c1 e8 03             	shr    $0x3,%eax
 6c6:	83 c0 01             	add    $0x1,%eax
 6c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6cc:	a1 e0 09 00 00       	mov    0x9e0,%eax
 6d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6d8:	75 23                	jne    6fd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 6da:	c7 45 f0 d8 09 00 00 	movl   $0x9d8,-0x10(%ebp)
 6e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e4:	a3 e0 09 00 00       	mov    %eax,0x9e0
 6e9:	a1 e0 09 00 00       	mov    0x9e0,%eax
 6ee:	a3 d8 09 00 00       	mov    %eax,0x9d8
    base.s.size = 0;
 6f3:	c7 05 dc 09 00 00 00 	movl   $0x0,0x9dc
 6fa:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 700:	8b 00                	mov    (%eax),%eax
 702:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 705:	8b 45 f4             	mov    -0xc(%ebp),%eax
 708:	8b 40 04             	mov    0x4(%eax),%eax
 70b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 70e:	77 4d                	ja     75d <malloc+0xa6>
      if(p->s.size == nunits)
 710:	8b 45 f4             	mov    -0xc(%ebp),%eax
 713:	8b 40 04             	mov    0x4(%eax),%eax
 716:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 719:	75 0c                	jne    727 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 71b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71e:	8b 10                	mov    (%eax),%edx
 720:	8b 45 f0             	mov    -0x10(%ebp),%eax
 723:	89 10                	mov    %edx,(%eax)
 725:	eb 26                	jmp    74d <malloc+0x96>
      else {
        p->s.size -= nunits;
 727:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72a:	8b 40 04             	mov    0x4(%eax),%eax
 72d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 730:	89 c2                	mov    %eax,%edx
 732:	8b 45 f4             	mov    -0xc(%ebp),%eax
 735:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 738:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73b:	8b 40 04             	mov    0x4(%eax),%eax
 73e:	c1 e0 03             	shl    $0x3,%eax
 741:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 744:	8b 45 f4             	mov    -0xc(%ebp),%eax
 747:	8b 55 ec             	mov    -0x14(%ebp),%edx
 74a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 74d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 750:	a3 e0 09 00 00       	mov    %eax,0x9e0
      return (void*)(p + 1);
 755:	8b 45 f4             	mov    -0xc(%ebp),%eax
 758:	83 c0 08             	add    $0x8,%eax
 75b:	eb 3b                	jmp    798 <malloc+0xe1>
    }
    if(p == freep)
 75d:	a1 e0 09 00 00       	mov    0x9e0,%eax
 762:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 765:	75 1e                	jne    785 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 767:	83 ec 0c             	sub    $0xc,%esp
 76a:	ff 75 ec             	push   -0x14(%ebp)
 76d:	e8 e5 fe ff ff       	call   657 <morecore>
 772:	83 c4 10             	add    $0x10,%esp
 775:	89 45 f4             	mov    %eax,-0xc(%ebp)
 778:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 77c:	75 07                	jne    785 <malloc+0xce>
        return 0;
 77e:	b8 00 00 00 00       	mov    $0x0,%eax
 783:	eb 13                	jmp    798 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 785:	8b 45 f4             	mov    -0xc(%ebp),%eax
 788:	89 45 f0             	mov    %eax,-0x10(%ebp)
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 793:	e9 6d ff ff ff       	jmp    705 <malloc+0x4e>
  }
}
 798:	c9                   	leave  
 799:	c3                   	ret    
