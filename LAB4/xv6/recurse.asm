
_recurse:     file format elf32-i386


Disassembly of section .text:

00000000 <recurse>:
// Prevent this function from being optimized, which might give it closed form
#pragma GCC push_options
#pragma GCC optimize ("O0")

static int recurse(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int x;
  printf(1, "[debug] level %d: &x = 0x%x\n", n, &x);
   6:	8d 45 f4             	lea    -0xc(%ebp),%eax
   9:	50                   	push   %eax
   a:	ff 75 08             	push   0x8(%ebp)
   d:	68 7b 08 00 00       	push   $0x87b
  12:	6a 01                	push   $0x1
  14:	e8 ab 04 00 00       	call   4c4 <printf>
  19:	83 c4 10             	add    $0x10,%esp
  if(n == 0)
  1c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  20:	75 07                	jne    29 <recurse+0x29>
    return 0;
  22:	b8 00 00 00 00       	mov    $0x0,%eax
  27:	eb 17                	jmp    40 <recurse+0x40>
  return n + recurse(n - 1);
  29:	8b 45 08             	mov    0x8(%ebp),%eax
  2c:	83 e8 01             	sub    $0x1,%eax
  2f:	83 ec 0c             	sub    $0xc,%esp
  32:	50                   	push   %eax
  33:	e8 c8 ff ff ff       	call   0 <recurse>
  38:	83 c4 10             	add    $0x10,%esp
  3b:	8b 55 08             	mov    0x8(%ebp),%edx
  3e:	01 d0                	add    %edx,%eax
}
  40:	c9                   	leave  
  41:	c3                   	ret    

00000042 <main>:
#pragma GCC pop_options

int main(int argc, char *argv[])
{
  42:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  46:	83 e4 f0             	and    $0xfffffff0,%esp
  49:	ff 71 fc             	push   -0x4(%ecx)
  4c:	55                   	push   %ebp
  4d:	89 e5                	mov    %esp,%ebp
  4f:	53                   	push   %ebx
  50:	51                   	push   %ecx
  51:	83 ec 10             	sub    $0x10,%esp
  54:	89 cb                	mov    %ecx,%ebx
  int n, m;

  if(argc != 2){
  56:	83 3b 02             	cmpl   $0x2,(%ebx)
  59:	74 1d                	je     78 <main+0x36>
    printf(1, "Usage: %s levels\n", argv[0]);
  5b:	8b 43 04             	mov    0x4(%ebx),%eax
  5e:	8b 00                	mov    (%eax),%eax
  60:	83 ec 04             	sub    $0x4,%esp
  63:	50                   	push   %eax
  64:	68 98 08 00 00       	push   $0x898
  69:	6a 01                	push   $0x1
  6b:	e8 54 04 00 00       	call   4c4 <printf>
  70:	83 c4 10             	add    $0x10,%esp
    exit();
  73:	e8 d0 02 00 00       	call   348 <exit>
  }
  printpt(getpid()); // Uncomment for the test.
  78:	e8 4b 03 00 00       	call   3c8 <getpid>
  7d:	83 ec 0c             	sub    $0xc,%esp
  80:	50                   	push   %eax
  81:	e8 62 03 00 00       	call   3e8 <printpt>
  86:	83 c4 10             	add    $0x10,%esp
  n = atoi(argv[1]);
  89:	8b 43 04             	mov    0x4(%ebx),%eax
  8c:	83 c0 04             	add    $0x4,%eax
  8f:	8b 00                	mov    (%eax),%eax
  91:	83 ec 0c             	sub    $0xc,%esp
  94:	50                   	push   %eax
  95:	e8 1c 02 00 00       	call   2b6 <atoi>
  9a:	83 c4 10             	add    $0x10,%esp
  9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  printf(1, "Recursing %d levels\n", n);
  a0:	83 ec 04             	sub    $0x4,%esp
  a3:	ff 75 f4             	push   -0xc(%ebp)
  a6:	68 aa 08 00 00       	push   $0x8aa
  ab:	6a 01                	push   $0x1
  ad:	e8 12 04 00 00       	call   4c4 <printf>
  b2:	83 c4 10             	add    $0x10,%esp
  m = recurse(n);
  b5:	83 ec 0c             	sub    $0xc,%esp
  b8:	ff 75 f4             	push   -0xc(%ebp)
  bb:	e8 40 ff ff ff       	call   0 <recurse>
  c0:	83 c4 10             	add    $0x10,%esp
  c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(1, "Yielded a value of %d\n", m);
  c6:	83 ec 04             	sub    $0x4,%esp
  c9:	ff 75 f0             	push   -0x10(%ebp)
  cc:	68 bf 08 00 00       	push   $0x8bf
  d1:	6a 01                	push   $0x1
  d3:	e8 ec 03 00 00       	call   4c4 <printf>
  d8:	83 c4 10             	add    $0x10,%esp
  printpt(getpid()); // Uncomment for the test.
  db:	e8 e8 02 00 00       	call   3c8 <getpid>
  e0:	83 ec 0c             	sub    $0xc,%esp
  e3:	50                   	push   %eax
  e4:	e8 ff 02 00 00       	call   3e8 <printpt>
  e9:	83 c4 10             	add    $0x10,%esp
  exit(); 
  ec:	e8 57 02 00 00       	call   348 <exit>

000000f1 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  f1:	55                   	push   %ebp
  f2:	89 e5                	mov    %esp,%ebp
  f4:	57                   	push   %edi
  f5:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  f9:	8b 55 10             	mov    0x10(%ebp),%edx
  fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  ff:	89 cb                	mov    %ecx,%ebx
 101:	89 df                	mov    %ebx,%edi
 103:	89 d1                	mov    %edx,%ecx
 105:	fc                   	cld    
 106:	f3 aa                	rep stos %al,%es:(%edi)
 108:	89 ca                	mov    %ecx,%edx
 10a:	89 fb                	mov    %edi,%ebx
 10c:	89 5d 08             	mov    %ebx,0x8(%ebp)
 10f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 112:	90                   	nop
 113:	5b                   	pop    %ebx
 114:	5f                   	pop    %edi
 115:	5d                   	pop    %ebp
 116:	c3                   	ret    

00000117 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 117:	55                   	push   %ebp
 118:	89 e5                	mov    %esp,%ebp
 11a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 123:	90                   	nop
 124:	8b 55 0c             	mov    0xc(%ebp),%edx
 127:	8d 42 01             	lea    0x1(%edx),%eax
 12a:	89 45 0c             	mov    %eax,0xc(%ebp)
 12d:	8b 45 08             	mov    0x8(%ebp),%eax
 130:	8d 48 01             	lea    0x1(%eax),%ecx
 133:	89 4d 08             	mov    %ecx,0x8(%ebp)
 136:	0f b6 12             	movzbl (%edx),%edx
 139:	88 10                	mov    %dl,(%eax)
 13b:	0f b6 00             	movzbl (%eax),%eax
 13e:	84 c0                	test   %al,%al
 140:	75 e2                	jne    124 <strcpy+0xd>
    ;
  return os;
 142:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 145:	c9                   	leave  
 146:	c3                   	ret    

00000147 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 147:	55                   	push   %ebp
 148:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 14a:	eb 08                	jmp    154 <strcmp+0xd>
    p++, q++;
 14c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 150:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	0f b6 00             	movzbl (%eax),%eax
 15a:	84 c0                	test   %al,%al
 15c:	74 10                	je     16e <strcmp+0x27>
 15e:	8b 45 08             	mov    0x8(%ebp),%eax
 161:	0f b6 10             	movzbl (%eax),%edx
 164:	8b 45 0c             	mov    0xc(%ebp),%eax
 167:	0f b6 00             	movzbl (%eax),%eax
 16a:	38 c2                	cmp    %al,%dl
 16c:	74 de                	je     14c <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	0f b6 00             	movzbl (%eax),%eax
 174:	0f b6 d0             	movzbl %al,%edx
 177:	8b 45 0c             	mov    0xc(%ebp),%eax
 17a:	0f b6 00             	movzbl (%eax),%eax
 17d:	0f b6 c8             	movzbl %al,%ecx
 180:	89 d0                	mov    %edx,%eax
 182:	29 c8                	sub    %ecx,%eax
}
 184:	5d                   	pop    %ebp
 185:	c3                   	ret    

00000186 <strlen>:

uint
strlen(char *s)
{
 186:	55                   	push   %ebp
 187:	89 e5                	mov    %esp,%ebp
 189:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 18c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 193:	eb 04                	jmp    199 <strlen+0x13>
 195:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 199:	8b 55 fc             	mov    -0x4(%ebp),%edx
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	01 d0                	add    %edx,%eax
 1a1:	0f b6 00             	movzbl (%eax),%eax
 1a4:	84 c0                	test   %al,%al
 1a6:	75 ed                	jne    195 <strlen+0xf>
    ;
  return n;
 1a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1ab:	c9                   	leave  
 1ac:	c3                   	ret    

000001ad <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ad:	55                   	push   %ebp
 1ae:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1b0:	8b 45 10             	mov    0x10(%ebp),%eax
 1b3:	50                   	push   %eax
 1b4:	ff 75 0c             	push   0xc(%ebp)
 1b7:	ff 75 08             	push   0x8(%ebp)
 1ba:	e8 32 ff ff ff       	call   f1 <stosb>
 1bf:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1c2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c5:	c9                   	leave  
 1c6:	c3                   	ret    

000001c7 <strchr>:

char*
strchr(const char *s, char c)
{
 1c7:	55                   	push   %ebp
 1c8:	89 e5                	mov    %esp,%ebp
 1ca:	83 ec 04             	sub    $0x4,%esp
 1cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1d3:	eb 14                	jmp    1e9 <strchr+0x22>
    if(*s == c)
 1d5:	8b 45 08             	mov    0x8(%ebp),%eax
 1d8:	0f b6 00             	movzbl (%eax),%eax
 1db:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1de:	75 05                	jne    1e5 <strchr+0x1e>
      return (char*)s;
 1e0:	8b 45 08             	mov    0x8(%ebp),%eax
 1e3:	eb 13                	jmp    1f8 <strchr+0x31>
  for(; *s; s++)
 1e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ec:	0f b6 00             	movzbl (%eax),%eax
 1ef:	84 c0                	test   %al,%al
 1f1:	75 e2                	jne    1d5 <strchr+0xe>
  return 0;
 1f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1f8:	c9                   	leave  
 1f9:	c3                   	ret    

000001fa <gets>:

char*
gets(char *buf, int max)
{
 1fa:	55                   	push   %ebp
 1fb:	89 e5                	mov    %esp,%ebp
 1fd:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 200:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 207:	eb 42                	jmp    24b <gets+0x51>
    cc = read(0, &c, 1);
 209:	83 ec 04             	sub    $0x4,%esp
 20c:	6a 01                	push   $0x1
 20e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 211:	50                   	push   %eax
 212:	6a 00                	push   $0x0
 214:	e8 47 01 00 00       	call   360 <read>
 219:	83 c4 10             	add    $0x10,%esp
 21c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 21f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 223:	7e 33                	jle    258 <gets+0x5e>
      break;
    buf[i++] = c;
 225:	8b 45 f4             	mov    -0xc(%ebp),%eax
 228:	8d 50 01             	lea    0x1(%eax),%edx
 22b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 22e:	89 c2                	mov    %eax,%edx
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	01 c2                	add    %eax,%edx
 235:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 239:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 23b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 23f:	3c 0a                	cmp    $0xa,%al
 241:	74 16                	je     259 <gets+0x5f>
 243:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 247:	3c 0d                	cmp    $0xd,%al
 249:	74 0e                	je     259 <gets+0x5f>
  for(i=0; i+1 < max; ){
 24b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24e:	83 c0 01             	add    $0x1,%eax
 251:	39 45 0c             	cmp    %eax,0xc(%ebp)
 254:	7f b3                	jg     209 <gets+0xf>
 256:	eb 01                	jmp    259 <gets+0x5f>
      break;
 258:	90                   	nop
      break;
  }
  buf[i] = '\0';
 259:	8b 55 f4             	mov    -0xc(%ebp),%edx
 25c:	8b 45 08             	mov    0x8(%ebp),%eax
 25f:	01 d0                	add    %edx,%eax
 261:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 264:	8b 45 08             	mov    0x8(%ebp),%eax
}
 267:	c9                   	leave  
 268:	c3                   	ret    

00000269 <stat>:

int
stat(char *n, struct stat *st)
{
 269:	55                   	push   %ebp
 26a:	89 e5                	mov    %esp,%ebp
 26c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 26f:	83 ec 08             	sub    $0x8,%esp
 272:	6a 00                	push   $0x0
 274:	ff 75 08             	push   0x8(%ebp)
 277:	e8 0c 01 00 00       	call   388 <open>
 27c:	83 c4 10             	add    $0x10,%esp
 27f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 282:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 286:	79 07                	jns    28f <stat+0x26>
    return -1;
 288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 28d:	eb 25                	jmp    2b4 <stat+0x4b>
  r = fstat(fd, st);
 28f:	83 ec 08             	sub    $0x8,%esp
 292:	ff 75 0c             	push   0xc(%ebp)
 295:	ff 75 f4             	push   -0xc(%ebp)
 298:	e8 03 01 00 00       	call   3a0 <fstat>
 29d:	83 c4 10             	add    $0x10,%esp
 2a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2a3:	83 ec 0c             	sub    $0xc,%esp
 2a6:	ff 75 f4             	push   -0xc(%ebp)
 2a9:	e8 c2 00 00 00       	call   370 <close>
 2ae:	83 c4 10             	add    $0x10,%esp
  return r;
 2b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2b4:	c9                   	leave  
 2b5:	c3                   	ret    

000002b6 <atoi>:

int
atoi(const char *s)
{
 2b6:	55                   	push   %ebp
 2b7:	89 e5                	mov    %esp,%ebp
 2b9:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2c3:	eb 25                	jmp    2ea <atoi+0x34>
    n = n*10 + *s++ - '0';
 2c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2c8:	89 d0                	mov    %edx,%eax
 2ca:	c1 e0 02             	shl    $0x2,%eax
 2cd:	01 d0                	add    %edx,%eax
 2cf:	01 c0                	add    %eax,%eax
 2d1:	89 c1                	mov    %eax,%ecx
 2d3:	8b 45 08             	mov    0x8(%ebp),%eax
 2d6:	8d 50 01             	lea    0x1(%eax),%edx
 2d9:	89 55 08             	mov    %edx,0x8(%ebp)
 2dc:	0f b6 00             	movzbl (%eax),%eax
 2df:	0f be c0             	movsbl %al,%eax
 2e2:	01 c8                	add    %ecx,%eax
 2e4:	83 e8 30             	sub    $0x30,%eax
 2e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2ea:	8b 45 08             	mov    0x8(%ebp),%eax
 2ed:	0f b6 00             	movzbl (%eax),%eax
 2f0:	3c 2f                	cmp    $0x2f,%al
 2f2:	7e 0a                	jle    2fe <atoi+0x48>
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	0f b6 00             	movzbl (%eax),%eax
 2fa:	3c 39                	cmp    $0x39,%al
 2fc:	7e c7                	jle    2c5 <atoi+0xf>
  return n;
 2fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 301:	c9                   	leave  
 302:	c3                   	ret    

00000303 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 303:	55                   	push   %ebp
 304:	89 e5                	mov    %esp,%ebp
 306:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 30f:	8b 45 0c             	mov    0xc(%ebp),%eax
 312:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 315:	eb 17                	jmp    32e <memmove+0x2b>
    *dst++ = *src++;
 317:	8b 55 f8             	mov    -0x8(%ebp),%edx
 31a:	8d 42 01             	lea    0x1(%edx),%eax
 31d:	89 45 f8             	mov    %eax,-0x8(%ebp)
 320:	8b 45 fc             	mov    -0x4(%ebp),%eax
 323:	8d 48 01             	lea    0x1(%eax),%ecx
 326:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 329:	0f b6 12             	movzbl (%edx),%edx
 32c:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 32e:	8b 45 10             	mov    0x10(%ebp),%eax
 331:	8d 50 ff             	lea    -0x1(%eax),%edx
 334:	89 55 10             	mov    %edx,0x10(%ebp)
 337:	85 c0                	test   %eax,%eax
 339:	7f dc                	jg     317 <memmove+0x14>
  return vdst;
 33b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33e:	c9                   	leave  
 33f:	c3                   	ret    

00000340 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 340:	b8 01 00 00 00       	mov    $0x1,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <exit>:
SYSCALL(exit)
 348:	b8 02 00 00 00       	mov    $0x2,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <wait>:
SYSCALL(wait)
 350:	b8 03 00 00 00       	mov    $0x3,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <pipe>:
SYSCALL(pipe)
 358:	b8 04 00 00 00       	mov    $0x4,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <read>:
SYSCALL(read)
 360:	b8 05 00 00 00       	mov    $0x5,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <write>:
SYSCALL(write)
 368:	b8 10 00 00 00       	mov    $0x10,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <close>:
SYSCALL(close)
 370:	b8 15 00 00 00       	mov    $0x15,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <kill>:
SYSCALL(kill)
 378:	b8 06 00 00 00       	mov    $0x6,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <exec>:
SYSCALL(exec)
 380:	b8 07 00 00 00       	mov    $0x7,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <open>:
SYSCALL(open)
 388:	b8 0f 00 00 00       	mov    $0xf,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <mknod>:
SYSCALL(mknod)
 390:	b8 11 00 00 00       	mov    $0x11,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <unlink>:
SYSCALL(unlink)
 398:	b8 12 00 00 00       	mov    $0x12,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <fstat>:
SYSCALL(fstat)
 3a0:	b8 08 00 00 00       	mov    $0x8,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <link>:
SYSCALL(link)
 3a8:	b8 13 00 00 00       	mov    $0x13,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <mkdir>:
SYSCALL(mkdir)
 3b0:	b8 14 00 00 00       	mov    $0x14,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <chdir>:
SYSCALL(chdir)
 3b8:	b8 09 00 00 00       	mov    $0x9,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <dup>:
SYSCALL(dup)
 3c0:	b8 0a 00 00 00       	mov    $0xa,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <getpid>:
SYSCALL(getpid)
 3c8:	b8 0b 00 00 00       	mov    $0xb,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <sbrk>:
SYSCALL(sbrk)
 3d0:	b8 0c 00 00 00       	mov    $0xc,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <sleep>:
SYSCALL(sleep)
 3d8:	b8 0d 00 00 00       	mov    $0xd,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <uptime>:
SYSCALL(uptime)
 3e0:	b8 0e 00 00 00       	mov    $0xe,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <printpt>:
 3e8:	b8 16 00 00 00       	mov    $0x16,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	83 ec 18             	sub    $0x18,%esp
 3f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3fc:	83 ec 04             	sub    $0x4,%esp
 3ff:	6a 01                	push   $0x1
 401:	8d 45 f4             	lea    -0xc(%ebp),%eax
 404:	50                   	push   %eax
 405:	ff 75 08             	push   0x8(%ebp)
 408:	e8 5b ff ff ff       	call   368 <write>
 40d:	83 c4 10             	add    $0x10,%esp
}
 410:	90                   	nop
 411:	c9                   	leave  
 412:	c3                   	ret    

00000413 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 413:	55                   	push   %ebp
 414:	89 e5                	mov    %esp,%ebp
 416:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 419:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 420:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 424:	74 17                	je     43d <printint+0x2a>
 426:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 42a:	79 11                	jns    43d <printint+0x2a>
    neg = 1;
 42c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 433:	8b 45 0c             	mov    0xc(%ebp),%eax
 436:	f7 d8                	neg    %eax
 438:	89 45 ec             	mov    %eax,-0x14(%ebp)
 43b:	eb 06                	jmp    443 <printint+0x30>
  } else {
    x = xx;
 43d:	8b 45 0c             	mov    0xc(%ebp),%eax
 440:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 443:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 44a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 44d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 450:	ba 00 00 00 00       	mov    $0x0,%edx
 455:	f7 f1                	div    %ecx
 457:	89 d1                	mov    %edx,%ecx
 459:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45c:	8d 50 01             	lea    0x1(%eax),%edx
 45f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 462:	0f b6 91 48 0b 00 00 	movzbl 0xb48(%ecx),%edx
 469:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 46d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 470:	8b 45 ec             	mov    -0x14(%ebp),%eax
 473:	ba 00 00 00 00       	mov    $0x0,%edx
 478:	f7 f1                	div    %ecx
 47a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 47d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 481:	75 c7                	jne    44a <printint+0x37>
  if(neg)
 483:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 487:	74 2d                	je     4b6 <printint+0xa3>
    buf[i++] = '-';
 489:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48c:	8d 50 01             	lea    0x1(%eax),%edx
 48f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 492:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 497:	eb 1d                	jmp    4b6 <printint+0xa3>
    putc(fd, buf[i]);
 499:	8d 55 dc             	lea    -0x24(%ebp),%edx
 49c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49f:	01 d0                	add    %edx,%eax
 4a1:	0f b6 00             	movzbl (%eax),%eax
 4a4:	0f be c0             	movsbl %al,%eax
 4a7:	83 ec 08             	sub    $0x8,%esp
 4aa:	50                   	push   %eax
 4ab:	ff 75 08             	push   0x8(%ebp)
 4ae:	e8 3d ff ff ff       	call   3f0 <putc>
 4b3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4be:	79 d9                	jns    499 <printint+0x86>
}
 4c0:	90                   	nop
 4c1:	90                   	nop
 4c2:	c9                   	leave  
 4c3:	c3                   	ret    

000004c4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4c4:	55                   	push   %ebp
 4c5:	89 e5                	mov    %esp,%ebp
 4c7:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4d1:	8d 45 0c             	lea    0xc(%ebp),%eax
 4d4:	83 c0 04             	add    $0x4,%eax
 4d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4e1:	e9 59 01 00 00       	jmp    63f <printf+0x17b>
    c = fmt[i] & 0xff;
 4e6:	8b 55 0c             	mov    0xc(%ebp),%edx
 4e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4ec:	01 d0                	add    %edx,%eax
 4ee:	0f b6 00             	movzbl (%eax),%eax
 4f1:	0f be c0             	movsbl %al,%eax
 4f4:	25 ff 00 00 00       	and    $0xff,%eax
 4f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 500:	75 2c                	jne    52e <printf+0x6a>
      if(c == '%'){
 502:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 506:	75 0c                	jne    514 <printf+0x50>
        state = '%';
 508:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 50f:	e9 27 01 00 00       	jmp    63b <printf+0x177>
      } else {
        putc(fd, c);
 514:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 517:	0f be c0             	movsbl %al,%eax
 51a:	83 ec 08             	sub    $0x8,%esp
 51d:	50                   	push   %eax
 51e:	ff 75 08             	push   0x8(%ebp)
 521:	e8 ca fe ff ff       	call   3f0 <putc>
 526:	83 c4 10             	add    $0x10,%esp
 529:	e9 0d 01 00 00       	jmp    63b <printf+0x177>
      }
    } else if(state == '%'){
 52e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 532:	0f 85 03 01 00 00    	jne    63b <printf+0x177>
      if(c == 'd'){
 538:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 53c:	75 1e                	jne    55c <printf+0x98>
        printint(fd, *ap, 10, 1);
 53e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 541:	8b 00                	mov    (%eax),%eax
 543:	6a 01                	push   $0x1
 545:	6a 0a                	push   $0xa
 547:	50                   	push   %eax
 548:	ff 75 08             	push   0x8(%ebp)
 54b:	e8 c3 fe ff ff       	call   413 <printint>
 550:	83 c4 10             	add    $0x10,%esp
        ap++;
 553:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 557:	e9 d8 00 00 00       	jmp    634 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 55c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 560:	74 06                	je     568 <printf+0xa4>
 562:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 566:	75 1e                	jne    586 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 568:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56b:	8b 00                	mov    (%eax),%eax
 56d:	6a 00                	push   $0x0
 56f:	6a 10                	push   $0x10
 571:	50                   	push   %eax
 572:	ff 75 08             	push   0x8(%ebp)
 575:	e8 99 fe ff ff       	call   413 <printint>
 57a:	83 c4 10             	add    $0x10,%esp
        ap++;
 57d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 581:	e9 ae 00 00 00       	jmp    634 <printf+0x170>
      } else if(c == 's'){
 586:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 58a:	75 43                	jne    5cf <printf+0x10b>
        s = (char*)*ap;
 58c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 58f:	8b 00                	mov    (%eax),%eax
 591:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 594:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 598:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 59c:	75 25                	jne    5c3 <printf+0xff>
          s = "(null)";
 59e:	c7 45 f4 d6 08 00 00 	movl   $0x8d6,-0xc(%ebp)
        while(*s != 0){
 5a5:	eb 1c                	jmp    5c3 <printf+0xff>
          putc(fd, *s);
 5a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5aa:	0f b6 00             	movzbl (%eax),%eax
 5ad:	0f be c0             	movsbl %al,%eax
 5b0:	83 ec 08             	sub    $0x8,%esp
 5b3:	50                   	push   %eax
 5b4:	ff 75 08             	push   0x8(%ebp)
 5b7:	e8 34 fe ff ff       	call   3f0 <putc>
 5bc:	83 c4 10             	add    $0x10,%esp
          s++;
 5bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c6:	0f b6 00             	movzbl (%eax),%eax
 5c9:	84 c0                	test   %al,%al
 5cb:	75 da                	jne    5a7 <printf+0xe3>
 5cd:	eb 65                	jmp    634 <printf+0x170>
        }
      } else if(c == 'c'){
 5cf:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5d3:	75 1d                	jne    5f2 <printf+0x12e>
        putc(fd, *ap);
 5d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d8:	8b 00                	mov    (%eax),%eax
 5da:	0f be c0             	movsbl %al,%eax
 5dd:	83 ec 08             	sub    $0x8,%esp
 5e0:	50                   	push   %eax
 5e1:	ff 75 08             	push   0x8(%ebp)
 5e4:	e8 07 fe ff ff       	call   3f0 <putc>
 5e9:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ec:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f0:	eb 42                	jmp    634 <printf+0x170>
      } else if(c == '%'){
 5f2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f6:	75 17                	jne    60f <printf+0x14b>
        putc(fd, c);
 5f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fb:	0f be c0             	movsbl %al,%eax
 5fe:	83 ec 08             	sub    $0x8,%esp
 601:	50                   	push   %eax
 602:	ff 75 08             	push   0x8(%ebp)
 605:	e8 e6 fd ff ff       	call   3f0 <putc>
 60a:	83 c4 10             	add    $0x10,%esp
 60d:	eb 25                	jmp    634 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 60f:	83 ec 08             	sub    $0x8,%esp
 612:	6a 25                	push   $0x25
 614:	ff 75 08             	push   0x8(%ebp)
 617:	e8 d4 fd ff ff       	call   3f0 <putc>
 61c:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 61f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 622:	0f be c0             	movsbl %al,%eax
 625:	83 ec 08             	sub    $0x8,%esp
 628:	50                   	push   %eax
 629:	ff 75 08             	push   0x8(%ebp)
 62c:	e8 bf fd ff ff       	call   3f0 <putc>
 631:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 634:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 63b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 63f:	8b 55 0c             	mov    0xc(%ebp),%edx
 642:	8b 45 f0             	mov    -0x10(%ebp),%eax
 645:	01 d0                	add    %edx,%eax
 647:	0f b6 00             	movzbl (%eax),%eax
 64a:	84 c0                	test   %al,%al
 64c:	0f 85 94 fe ff ff    	jne    4e6 <printf+0x22>
    }
  }
}
 652:	90                   	nop
 653:	90                   	nop
 654:	c9                   	leave  
 655:	c3                   	ret    

00000656 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 656:	55                   	push   %ebp
 657:	89 e5                	mov    %esp,%ebp
 659:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 65c:	8b 45 08             	mov    0x8(%ebp),%eax
 65f:	83 e8 08             	sub    $0x8,%eax
 662:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 665:	a1 64 0b 00 00       	mov    0xb64,%eax
 66a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 66d:	eb 24                	jmp    693 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 66f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 672:	8b 00                	mov    (%eax),%eax
 674:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 677:	72 12                	jb     68b <free+0x35>
 679:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 67f:	77 24                	ja     6a5 <free+0x4f>
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	8b 00                	mov    (%eax),%eax
 686:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 689:	72 1a                	jb     6a5 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68e:	8b 00                	mov    (%eax),%eax
 690:	89 45 fc             	mov    %eax,-0x4(%ebp)
 693:	8b 45 f8             	mov    -0x8(%ebp),%eax
 696:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 699:	76 d4                	jbe    66f <free+0x19>
 69b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69e:	8b 00                	mov    (%eax),%eax
 6a0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6a3:	73 ca                	jae    66f <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a8:	8b 40 04             	mov    0x4(%eax),%eax
 6ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b5:	01 c2                	add    %eax,%edx
 6b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ba:	8b 00                	mov    (%eax),%eax
 6bc:	39 c2                	cmp    %eax,%edx
 6be:	75 24                	jne    6e4 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c3:	8b 50 04             	mov    0x4(%eax),%edx
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	8b 00                	mov    (%eax),%eax
 6cb:	8b 40 04             	mov    0x4(%eax),%eax
 6ce:	01 c2                	add    %eax,%edx
 6d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d9:	8b 00                	mov    (%eax),%eax
 6db:	8b 10                	mov    (%eax),%edx
 6dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e0:	89 10                	mov    %edx,(%eax)
 6e2:	eb 0a                	jmp    6ee <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e7:	8b 10                	mov    (%eax),%edx
 6e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ec:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f1:	8b 40 04             	mov    0x4(%eax),%eax
 6f4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fe:	01 d0                	add    %edx,%eax
 700:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 703:	75 20                	jne    725 <free+0xcf>
    p->s.size += bp->s.size;
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	8b 50 04             	mov    0x4(%eax),%edx
 70b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70e:	8b 40 04             	mov    0x4(%eax),%eax
 711:	01 c2                	add    %eax,%edx
 713:	8b 45 fc             	mov    -0x4(%ebp),%eax
 716:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 719:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71c:	8b 10                	mov    (%eax),%edx
 71e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 721:	89 10                	mov    %edx,(%eax)
 723:	eb 08                	jmp    72d <free+0xd7>
  } else
    p->s.ptr = bp;
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	8b 55 f8             	mov    -0x8(%ebp),%edx
 72b:	89 10                	mov    %edx,(%eax)
  freep = p;
 72d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 730:	a3 64 0b 00 00       	mov    %eax,0xb64
}
 735:	90                   	nop
 736:	c9                   	leave  
 737:	c3                   	ret    

00000738 <morecore>:

static Header*
morecore(uint nu)
{
 738:	55                   	push   %ebp
 739:	89 e5                	mov    %esp,%ebp
 73b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 73e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 745:	77 07                	ja     74e <morecore+0x16>
    nu = 4096;
 747:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 74e:	8b 45 08             	mov    0x8(%ebp),%eax
 751:	c1 e0 03             	shl    $0x3,%eax
 754:	83 ec 0c             	sub    $0xc,%esp
 757:	50                   	push   %eax
 758:	e8 73 fc ff ff       	call   3d0 <sbrk>
 75d:	83 c4 10             	add    $0x10,%esp
 760:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 763:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 767:	75 07                	jne    770 <morecore+0x38>
    return 0;
 769:	b8 00 00 00 00       	mov    $0x0,%eax
 76e:	eb 26                	jmp    796 <morecore+0x5e>
  hp = (Header*)p;
 770:	8b 45 f4             	mov    -0xc(%ebp),%eax
 773:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 776:	8b 45 f0             	mov    -0x10(%ebp),%eax
 779:	8b 55 08             	mov    0x8(%ebp),%edx
 77c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 77f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 782:	83 c0 08             	add    $0x8,%eax
 785:	83 ec 0c             	sub    $0xc,%esp
 788:	50                   	push   %eax
 789:	e8 c8 fe ff ff       	call   656 <free>
 78e:	83 c4 10             	add    $0x10,%esp
  return freep;
 791:	a1 64 0b 00 00       	mov    0xb64,%eax
}
 796:	c9                   	leave  
 797:	c3                   	ret    

00000798 <malloc>:

void*
malloc(uint nbytes)
{
 798:	55                   	push   %ebp
 799:	89 e5                	mov    %esp,%ebp
 79b:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79e:	8b 45 08             	mov    0x8(%ebp),%eax
 7a1:	83 c0 07             	add    $0x7,%eax
 7a4:	c1 e8 03             	shr    $0x3,%eax
 7a7:	83 c0 01             	add    $0x1,%eax
 7aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7ad:	a1 64 0b 00 00       	mov    0xb64,%eax
 7b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7b9:	75 23                	jne    7de <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7bb:	c7 45 f0 5c 0b 00 00 	movl   $0xb5c,-0x10(%ebp)
 7c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c5:	a3 64 0b 00 00       	mov    %eax,0xb64
 7ca:	a1 64 0b 00 00       	mov    0xb64,%eax
 7cf:	a3 5c 0b 00 00       	mov    %eax,0xb5c
    base.s.size = 0;
 7d4:	c7 05 60 0b 00 00 00 	movl   $0x0,0xb60
 7db:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e1:	8b 00                	mov    (%eax),%eax
 7e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e9:	8b 40 04             	mov    0x4(%eax),%eax
 7ec:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7ef:	77 4d                	ja     83e <malloc+0xa6>
      if(p->s.size == nunits)
 7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f4:	8b 40 04             	mov    0x4(%eax),%eax
 7f7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7fa:	75 0c                	jne    808 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ff:	8b 10                	mov    (%eax),%edx
 801:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804:	89 10                	mov    %edx,(%eax)
 806:	eb 26                	jmp    82e <malloc+0x96>
      else {
        p->s.size -= nunits;
 808:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80b:	8b 40 04             	mov    0x4(%eax),%eax
 80e:	2b 45 ec             	sub    -0x14(%ebp),%eax
 811:	89 c2                	mov    %eax,%edx
 813:	8b 45 f4             	mov    -0xc(%ebp),%eax
 816:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	8b 40 04             	mov    0x4(%eax),%eax
 81f:	c1 e0 03             	shl    $0x3,%eax
 822:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 825:	8b 45 f4             	mov    -0xc(%ebp),%eax
 828:	8b 55 ec             	mov    -0x14(%ebp),%edx
 82b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 82e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 831:	a3 64 0b 00 00       	mov    %eax,0xb64
      return (void*)(p + 1);
 836:	8b 45 f4             	mov    -0xc(%ebp),%eax
 839:	83 c0 08             	add    $0x8,%eax
 83c:	eb 3b                	jmp    879 <malloc+0xe1>
    }
    if(p == freep)
 83e:	a1 64 0b 00 00       	mov    0xb64,%eax
 843:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 846:	75 1e                	jne    866 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 848:	83 ec 0c             	sub    $0xc,%esp
 84b:	ff 75 ec             	push   -0x14(%ebp)
 84e:	e8 e5 fe ff ff       	call   738 <morecore>
 853:	83 c4 10             	add    $0x10,%esp
 856:	89 45 f4             	mov    %eax,-0xc(%ebp)
 859:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 85d:	75 07                	jne    866 <malloc+0xce>
        return 0;
 85f:	b8 00 00 00 00       	mov    $0x0,%eax
 864:	eb 13                	jmp    879 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	8b 45 f4             	mov    -0xc(%ebp),%eax
 869:	89 45 f0             	mov    %eax,-0x10(%ebp)
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	8b 00                	mov    (%eax),%eax
 871:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 874:	e9 6d ff ff ff       	jmp    7e6 <malloc+0x4e>
  }
}
 879:	c9                   	leave  
 87a:	c3                   	ret    
