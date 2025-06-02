
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 88 19 80       	mov    $0x80198880,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 65 33 10 80       	mov    $0x80103365,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 20 a5 10 80       	push   $0x8010a520
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 ae 49 00 00       	call   80104a2c <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 27 a5 10 80       	push   $0x8010a527
801000c2:	50                   	push   %eax
801000c3:	e8 07 48 00 00       	call   801048cf <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 48 49 00 00       	call   80104a4e <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 77 49 00 00       	call   80104abc <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 b4 47 00 00       	call   8010490b <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 f6 48 00 00       	call   80104abc <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 33 47 00 00       	call   8010490b <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 2e a5 10 80       	push   $0x8010a52e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 ea a1 00 00       	call   8010a41c <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 6e 47 00 00       	call   801049bd <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 3f a5 10 80       	push   $0x8010a53f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 9f a1 00 00       	call   8010a41c <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 25 47 00 00       	call   801049bd <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 46 a5 10 80       	push   $0x8010a546
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 b4 46 00 00       	call   8010496f <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 83 47 00 00       	call   80104a4e <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 81 47 00 00       	call   80104abc <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 39 46 00 00       	call   80104a4e <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 4d a5 10 80       	push   $0x8010a54d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 56 a5 10 80 	movl   $0x8010a556,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 19 45 00 00       	call   80104abc <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 37 25 00 00       	call   80102afa <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 5d a5 10 80       	push   $0x8010a55d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 71 a5 10 80       	push   $0x8010a571
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 0b 45 00 00       	call   80104b0e <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 73 a5 10 80       	push   $0x8010a573
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 ce 7c 00 00       	call   80108373 <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 7b 7c 00 00       	call   80108373 <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 82 7c 00 00       	call   801083de <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 52 60 00 00       	call   801067ea <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 45 60 00 00       	call   801067ea <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 38 60 00 00       	call   801067ea <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 28 60 00 00       	call   801067ea <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 5e 42 00 00       	call   80104a4e <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 d0 3d 00 00       	call   80104714 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 55 41 00 00       	call   80104abc <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 5d 3e 00 00       	call   801047d2 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 af 40 00 00       	call   80104a4e <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 20 31 00 00       	call   80103acc <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 fc 40 00 00       	call   80104abc <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 3d 3c 00 00       	call   8010462a <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 51 40 00 00       	call   80104abc <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 a7 3f 00 00       	call   80104a4e <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 d3 3f 00 00       	call   80104abc <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 77 a5 10 80       	push   $0x8010a577
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 0b 3f 00 00       	call   80104a2c <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 7f a5 10 80 	movl   $0x8010a57f,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 b4 1a 00 00       	call   8010262e <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 3e 2f 00 00       	call   80103acc <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a6 24 00 00       	call   8010303c <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 16 25 00 00       	call   801030c8 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 95 a5 10 80       	push   $0x8010a595
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 d0 6b 00 00       	call   801077e6 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 23 6f 00 00       	call   80107bdf <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 10 6e 00 00       	call   80107b12 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 85 23 00 00       	call   801030c8 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 6e 6e 00 00       	call   80107bdf <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 ac 70 00 00       	call   80107e41 <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 44 41 00 00       	call   80104f12 <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 17 41 00 00       	call   80104f12 <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 bf 71 00 00       	call   80107fe0 <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 23 71 00 00       	call   80107fe0 <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 6c             	add    $0x6c,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 bc 3f 00 00       	call   80104ec7 <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 b5 69 00 00       	call   80107903 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 4c 6e 00 00       	call   80107da8 <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 0c 6e 00 00       	call   80107da8 <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 10 21 00 00       	call   801030c8 <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 a1 a5 10 80       	push   $0x8010a5a1
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 55 3a 00 00       	call   80104a2c <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 1a 19 80       	push   $0x80191aa0
80100feb:	e8 5e 3a 00 00       	call   80104a4e <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 1a 19 80       	push   $0x80191aa0
80101018:	e8 9f 3a 00 00       	call   80104abc <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 1a 19 80       	push   $0x80191aa0
8010103b:	e8 7c 3a 00 00       	call   80104abc <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 1a 19 80       	push   $0x80191aa0
80101058:	e8 f1 39 00 00       	call   80104a4e <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 a8 a5 10 80       	push   $0x8010a5a8
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 1a 19 80       	push   $0x80191aa0
8010108e:	e8 29 3a 00 00       	call   80104abc <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 1a 19 80       	push   $0x80191aa0
801010a9:	e8 a0 39 00 00       	call   80104a4e <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 b0 a5 10 80       	push   $0x8010a5b0
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 1a 19 80       	push   $0x80191aa0
801010e9:	e8 ce 39 00 00       	call   80104abc <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 1a 19 80       	push   $0x80191aa0
80101137:	e8 80 39 00 00       	call   80104abc <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 64 25 00 00       	call   801036bf <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 cf 1e 00 00       	call   8010303c <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 47 1f 00 00       	call   801030c8 <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 58 26 00 00       	call   8010386c <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 ba a5 10 80       	push   $0x8010a5ba
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 9d 24 00 00       	call   8010376a <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 2a 1d 00 00       	call   8010303c <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 50 1d 00 00       	call   801030c8 <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 c3 a5 10 80       	push   $0x8010a5c3
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 d3 a5 10 80       	push   $0x8010a5d3
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 87 39 00 00       	call   80104d83 <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 82 38 00 00       	call   80104cc4 <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 25 1e 00 00       	call   80103275 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 24 19 80       	mov    0x80192458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 59 1d 00 00       	call   80103275 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 24 19 80       	mov    0x80192440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 e0 a5 10 80       	push   $0x8010a5e0
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 24 19 80       	push   $0x80192440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 24 19 80       	mov    0x80192458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 f6 a5 10 80       	push   $0x8010a5f6
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 11 1c 00 00       	call   80103275 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 09 a6 10 80       	push   $0x8010a609
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 92 33 00 00       	call   80104a2c <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 24 19 80       	add    $0x80192460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 10 a6 10 80       	push   $0x8010a610
801016c6:	50                   	push   %eax
801016c7:	e8 03 32 00 00       	call   801048cf <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 24 19 80       	push   $0x80192440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fa:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101700:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101706:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170c:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101712:	a1 40 24 19 80       	mov    0x80192440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 18 a6 10 80       	push   $0x8010a618
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 24 19 80       	mov    0x80192454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 26 35 00 00       	call   80104cc4 <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 bf 1a 00 00       	call   80103275 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 6b a6 10 80       	push   $0x8010a66b
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 24 19 80       	mov    0x80192454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 d7 34 00 00       	call   80104d83 <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 bb 19 00 00       	call   80103275 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 24 19 80       	push   $0x80192460
801018dc:	e8 6d 31 00 00       	call   80104a4e <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 24 19 80       	push   $0x80192460
8010192a:	e8 8d 31 00 00       	call   80104abc <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 7d a6 10 80       	push   $0x8010a67d
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 24 19 80       	push   $0x80192460
801019a3:	e8 14 31 00 00       	call   80104abc <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 24 19 80       	push   $0x80192460
801019be:	e8 8b 30 00 00       	call   80104a4e <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 24 19 80       	push   $0x80192460
801019dd:	e8 da 30 00 00       	call   80104abc <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 8d a6 10 80       	push   $0x8010a68d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 ef 2e 00 00       	call   8010490b <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 bd 32 00 00       	call   80104d83 <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 93 a6 10 80       	push   $0x8010a693
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 a5 2e 00 00       	call   801049bd <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 a2 a6 10 80       	push   $0x8010a6a2
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 2a 2e 00 00       	call   8010496f <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 ab 2d 00 00       	call   8010490b <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 24 19 80       	push   $0x80192460
80101b81:	e8 c8 2e 00 00       	call   80104a4e <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 1d 2f 00 00       	call   80104abc <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 89 2d 00 00       	call   8010496f <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 58 2e 00 00       	call   80104a4e <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 24 19 80       	push   $0x80192460
80101c10:	e8 a7 2e 00 00       	call   80104abc <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 3a 15 00 00       	call   80103275 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 aa a6 10 80       	push   $0x8010a6aa
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 8c 2d 00 00       	call   80104d83 <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 3c 2c 00 00       	call   80104d83 <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 20 11 00 00       	call   80103275 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 52 2c 00 00       	call   80104e19 <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 bd a6 10 80       	push   $0x8010a6bd
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 cf a6 10 80       	push   $0x8010a6cf
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 de a6 10 80       	push   $0x8010a6de
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 49 2b 00 00       	call   80104e6f <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 eb a6 10 80       	push   $0x8010a6eb
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 bf 29 00 00       	call   80104d83 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 a8 29 00 00       	call   80104d83 <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 a2 16 00 00       	call   80103acc <myproc>
8010242a:	8b 40 68             	mov    0x68(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102557:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255c:	8b 55 08             	mov    0x8(%ebp),%edx
8010255f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102561:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102566:	8b 40 10             	mov    0x10(%eax),%eax
}
80102569:	5d                   	pop    %ebp
8010256a:	c3                   	ret    

8010256b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102573:	8b 55 08             	mov    0x8(%ebp),%edx
80102576:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102578:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102580:	89 50 10             	mov    %edx,0x10(%eax)
}
80102583:	90                   	nop
80102584:	5d                   	pop    %ebp
80102585:	c3                   	ret    

80102586 <ioapicinit>:

void
ioapicinit(void)
{
80102586:	55                   	push   %ebp
80102587:	89 e5                	mov    %esp,%ebp
80102589:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258c:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102593:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102596:	6a 01                	push   $0x1
80102598:	e8 b7 ff ff ff       	call   80102554 <ioapicread>
8010259d:	83 c4 04             	add    $0x4,%esp
801025a0:	c1 e8 10             	shr    $0x10,%eax
801025a3:	25 ff 00 00 00       	and    $0xff,%eax
801025a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ab:	6a 00                	push   $0x0
801025ad:	e8 a2 ff ff ff       	call   80102554 <ioapicread>
801025b2:	83 c4 04             	add    $0x4,%esp
801025b5:	c1 e8 18             	shr    $0x18,%eax
801025b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bb:	0f b6 05 54 75 19 80 	movzbl 0x80197554,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 f4 a6 10 80       	push   $0x8010a6f4
801025d2:	e8 1d de ff ff       	call   801003f4 <cprintf>
801025d7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e1:	eb 3f                	jmp    80102622 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e6:	83 c0 20             	add    $0x20,%eax
801025e9:	0d 00 00 01 00       	or     $0x10000,%eax
801025ee:	89 c2                	mov    %eax,%edx
801025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f3:	83 c0 08             	add    $0x8,%eax
801025f6:	01 c0                	add    %eax,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	52                   	push   %edx
801025fc:	50                   	push   %eax
801025fd:	e8 69 ff ff ff       	call   8010256b <ioapicwrite>
80102602:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102608:	83 c0 08             	add    $0x8,%eax
8010260b:	01 c0                	add    %eax,%eax
8010260d:	83 c0 01             	add    $0x1,%eax
80102610:	83 ec 08             	sub    $0x8,%esp
80102613:	6a 00                	push   $0x0
80102615:	50                   	push   %eax
80102616:	e8 50 ff ff ff       	call   8010256b <ioapicwrite>
8010261b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102625:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102628:	7e b9                	jle    801025e3 <ioapicinit+0x5d>
  }
}
8010262a:	90                   	nop
8010262b:	90                   	nop
8010262c:	c9                   	leave  
8010262d:	c3                   	ret    

8010262e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102631:	8b 45 08             	mov    0x8(%ebp),%eax
80102634:	83 c0 20             	add    $0x20,%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 08             	add    $0x8,%eax
8010263f:	01 c0                	add    %eax,%eax
80102641:	52                   	push   %edx
80102642:	50                   	push   %eax
80102643:	e8 23 ff ff ff       	call   8010256b <ioapicwrite>
80102648:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264e:	c1 e0 18             	shl    $0x18,%eax
80102651:	89 c2                	mov    %eax,%edx
80102653:	8b 45 08             	mov    0x8(%ebp),%eax
80102656:	83 c0 08             	add    $0x8,%eax
80102659:	01 c0                	add    %eax,%eax
8010265b:	83 c0 01             	add    $0x1,%eax
8010265e:	52                   	push   %edx
8010265f:	50                   	push   %eax
80102660:	e8 06 ff ff ff       	call   8010256b <ioapicwrite>
80102665:	83 c4 08             	add    $0x8,%esp
}
80102668:	90                   	nop
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102671:	83 ec 08             	sub    $0x8,%esp
80102674:	68 26 a7 10 80       	push   $0x8010a726
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 a9 23 00 00       	call   80104a2c <initlock>
80102683:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102686:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268d:	00 00 00 
  freerange(vstart, vend);
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	ff 75 0c             	push   0xc(%ebp)
80102696:	ff 75 08             	push   0x8(%ebp)
80102699:	e8 2a 00 00 00       	call   801026c8 <freerange>
8010269e:	83 c4 10             	add    $0x10,%esp
}
801026a1:	90                   	nop
801026a2:	c9                   	leave  
801026a3:	c3                   	ret    

801026a4 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a4:	55                   	push   %ebp
801026a5:	89 e5                	mov    %esp,%ebp
801026a7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	ff 75 0c             	push   0xc(%ebp)
801026b0:	ff 75 08             	push   0x8(%ebp)
801026b3:	e8 10 00 00 00       	call   801026c8 <freerange>
801026b8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bb:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c2:	00 00 00 
}
801026c5:	90                   	nop
801026c6:	c9                   	leave  
801026c7:	c3                   	ret    

801026c8 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026ce:	8b 45 08             	mov    0x8(%ebp),%eax
801026d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026de:	eb 15                	jmp    801026f5 <freerange+0x2d>
    kfree(p);
801026e0:	83 ec 0c             	sub    $0xc,%esp
801026e3:	ff 75 f4             	push   -0xc(%ebp)
801026e6:	e8 1b 00 00 00       	call   80102706 <kfree>
801026eb:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f8:	05 00 10 00 00       	add    $0x1000,%eax
801026fd:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102700:	73 de                	jae    801026e0 <freerange+0x18>
}
80102702:	90                   	nop
80102703:	90                   	nop
80102704:	c9                   	leave  
80102705:	c3                   	ret    

80102706 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102706:	55                   	push   %ebp
80102707:	89 e5                	mov    %esp,%ebp
80102709:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102714:	85 c0                	test   %eax,%eax
80102716:	75 18                	jne    80102730 <kfree+0x2a>
80102718:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010271f:	72 0f                	jb     80102730 <kfree+0x2a>
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	05 00 00 00 80       	add    $0x80000000,%eax
80102729:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272e:	76 0d                	jbe    8010273d <kfree+0x37>
    panic("kfree");
80102730:	83 ec 0c             	sub    $0xc,%esp
80102733:	68 2b a7 10 80       	push   $0x8010a72b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 75 25 00 00       	call   80104cc4 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 e6 22 00 00       	call   80104a4e <acquire>
80102768:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276b:	8b 45 08             	mov    0x8(%ebp),%eax
8010276e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102771:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277f:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102784:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102789:	85 c0                	test   %eax,%eax
8010278b:	74 10                	je     8010279d <kfree+0x97>
    release(&kmem.lock);
8010278d:	83 ec 0c             	sub    $0xc,%esp
80102790:	68 c0 40 19 80       	push   $0x801940c0
80102795:	e8 22 23 00 00       	call   80104abc <release>
8010279a:	83 c4 10             	add    $0x10,%esp
}
8010279d:	90                   	nop
8010279e:	c9                   	leave  
8010279f:	c3                   	ret    

801027a0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a0:	55                   	push   %ebp
801027a1:	89 e5                	mov    %esp,%ebp
801027a3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a6:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ab:	85 c0                	test   %eax,%eax
801027ad:	74 10                	je     801027bf <kalloc+0x1f>
    acquire(&kmem.lock);
801027af:	83 ec 0c             	sub    $0xc,%esp
801027b2:	68 c0 40 19 80       	push   $0x801940c0
801027b7:	e8 92 22 00 00       	call   80104a4e <acquire>
801027bc:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027bf:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cb:	74 0a                	je     801027d7 <kalloc+0x37>
    kmem.freelist = r->next;
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	8b 00                	mov    (%eax),%eax
801027d2:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dc:	85 c0                	test   %eax,%eax
801027de:	74 10                	je     801027f0 <kalloc+0x50>
    release(&kmem.lock);
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	68 c0 40 19 80       	push   $0x801940c0
801027e8:	e8 cf 22 00 00       	call   80104abc <release>
801027ed:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f3:	c9                   	leave  
801027f4:	c3                   	ret    

801027f5 <inb>:
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102802:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102806:	89 c2                	mov    %eax,%edx
80102808:	ec                   	in     (%dx),%al
80102809:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102810:	c9                   	leave  
80102811:	c3                   	ret    

80102812 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102812:	55                   	push   %ebp
80102813:	89 e5                	mov    %esp,%ebp
80102815:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102818:	6a 64                	push   $0x64
8010281a:	e8 d6 ff ff ff       	call   801027f5 <inb>
8010281f:	83 c4 04             	add    $0x4,%esp
80102822:	0f b6 c0             	movzbl %al,%eax
80102825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	83 e0 01             	and    $0x1,%eax
8010282e:	85 c0                	test   %eax,%eax
80102830:	75 0a                	jne    8010283c <kbdgetc+0x2a>
    return -1;
80102832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102837:	e9 23 01 00 00       	jmp    8010295f <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283c:	6a 60                	push   $0x60
8010283e:	e8 b2 ff ff ff       	call   801027f5 <inb>
80102843:	83 c4 04             	add    $0x4,%esp
80102846:	0f b6 c0             	movzbl %al,%eax
80102849:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102853:	75 17                	jne    8010286c <kbdgetc+0x5a>
    shift |= E0ESC;
80102855:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285a:	83 c8 40             	or     $0x40,%eax
8010285d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102862:	b8 00 00 00 00       	mov    $0x0,%eax
80102867:	e9 f3 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	25 80 00 00 00       	and    $0x80,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	74 45                	je     801028bd <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102878:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287d:	83 e0 40             	and    $0x40,%eax
80102880:	85 c0                	test   %eax,%eax
80102882:	75 08                	jne    8010288c <kbdgetc+0x7a>
80102884:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102887:	83 e0 7f             	and    $0x7f,%eax
8010288a:	eb 03                	jmp    8010288f <kbdgetc+0x7d>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102895:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289a:	0f b6 00             	movzbl (%eax),%eax
8010289d:	83 c8 40             	or     $0x40,%eax
801028a0:	0f b6 c0             	movzbl %al,%eax
801028a3:	f7 d0                	not    %eax
801028a5:	89 c2                	mov    %eax,%edx
801028a7:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ac:	21 d0                	and    %edx,%eax
801028ae:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b3:	b8 00 00 00 00       	mov    $0x0,%eax
801028b8:	e9 a2 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028bd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c2:	83 e0 40             	and    $0x40,%eax
801028c5:	85 c0                	test   %eax,%eax
801028c7:	74 14                	je     801028dd <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028c9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d0:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d5:	83 e0 bf             	and    $0xffffffbf,%eax
801028d8:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e0:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e5:	0f b6 00             	movzbl (%eax),%eax
801028e8:	0f b6 d0             	movzbl %al,%edx
801028eb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f0:	09 d0                	or     %edx,%eax
801028f2:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fa:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028ff:	0f b6 00             	movzbl (%eax),%eax
80102902:	0f b6 d0             	movzbl %al,%edx
80102905:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290a:	31 d0                	xor    %edx,%eax
8010290c:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102911:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102916:	83 e0 03             	and    $0x3,%eax
80102919:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102923:	01 d0                	add    %edx,%eax
80102925:	0f b6 00             	movzbl (%eax),%eax
80102928:	0f b6 c0             	movzbl %al,%eax
8010292b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292e:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102933:	83 e0 08             	and    $0x8,%eax
80102936:	85 c0                	test   %eax,%eax
80102938:	74 22                	je     8010295c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293e:	76 0c                	jbe    8010294c <kbdgetc+0x13a>
80102940:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102944:	77 06                	ja     8010294c <kbdgetc+0x13a>
      c += 'A' - 'a';
80102946:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294a:	eb 10                	jmp    8010295c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102950:	76 0a                	jbe    8010295c <kbdgetc+0x14a>
80102952:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102956:	77 04                	ja     8010295c <kbdgetc+0x14a>
      c += 'a' - 'A';
80102958:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010295f:	c9                   	leave  
80102960:	c3                   	ret    

80102961 <kbdintr>:

void
kbdintr(void)
{
80102961:	55                   	push   %ebp
80102962:	89 e5                	mov    %esp,%ebp
80102964:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 12 28 10 80       	push   $0x80102812
8010296f:	e8 62 de ff ff       	call   801007d6 <consoleintr>
80102974:	83 c4 10             	add    $0x10,%esp
}
80102977:	90                   	nop
80102978:	c9                   	leave  
80102979:	c3                   	ret    

8010297a <inb>:
{
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 14             	sub    $0x14,%esp
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102987:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298b:	89 c2                	mov    %eax,%edx
8010298d:	ec                   	in     (%dx),%al
8010298e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102991:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102995:	c9                   	leave  
80102996:	c3                   	ret    

80102997 <outb>:
{
80102997:	55                   	push   %ebp
80102998:	89 e5                	mov    %esp,%ebp
8010299a:	83 ec 08             	sub    $0x8,%esp
8010299d:	8b 45 08             	mov    0x8(%ebp),%eax
801029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a7:	89 d0                	mov    %edx,%eax
801029a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b4:	ee                   	out    %al,(%dx)
}
801029b5:	90                   	nop
801029b6:	c9                   	leave  
801029b7:	c3                   	ret    

801029b8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b8:	55                   	push   %ebp
801029b9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bb:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c1 e0 02             	shl    $0x2,%eax
801029c7:	01 c2                	add    %eax,%edx
801029c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029ce:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d3:	83 c0 20             	add    $0x20,%eax
801029d6:	8b 00                	mov    (%eax),%eax
}
801029d8:	90                   	nop
801029d9:	5d                   	pop    %ebp
801029da:	c3                   	ret    

801029db <lapicinit>:

void
lapicinit(void)
{
801029db:	55                   	push   %ebp
801029dc:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029de:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e3:	85 c0                	test   %eax,%eax
801029e5:	0f 84 0c 01 00 00    	je     80102af7 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029eb:	68 3f 01 00 00       	push   $0x13f
801029f0:	6a 3c                	push   $0x3c
801029f2:	e8 c1 ff ff ff       	call   801029b8 <lapicw>
801029f7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fa:	6a 0b                	push   $0xb
801029fc:	68 f8 00 00 00       	push   $0xf8
80102a01:	e8 b2 ff ff ff       	call   801029b8 <lapicw>
80102a06:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a09:	68 20 00 02 00       	push   $0x20020
80102a0e:	68 c8 00 00 00       	push   $0xc8
80102a13:	e8 a0 ff ff ff       	call   801029b8 <lapicw>
80102a18:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1b:	68 80 96 98 00       	push   $0x989680
80102a20:	68 e0 00 00 00       	push   $0xe0
80102a25:	e8 8e ff ff ff       	call   801029b8 <lapicw>
80102a2a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2d:	68 00 00 01 00       	push   $0x10000
80102a32:	68 d4 00 00 00       	push   $0xd4
80102a37:	e8 7c ff ff ff       	call   801029b8 <lapicw>
80102a3c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a3f:	68 00 00 01 00       	push   $0x10000
80102a44:	68 d8 00 00 00       	push   $0xd8
80102a49:	e8 6a ff ff ff       	call   801029b8 <lapicw>
80102a4e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a51:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a56:	83 c0 30             	add    $0x30,%eax
80102a59:	8b 00                	mov    (%eax),%eax
80102a5b:	c1 e8 10             	shr    $0x10,%eax
80102a5e:	25 fc 00 00 00       	and    $0xfc,%eax
80102a63:	85 c0                	test   %eax,%eax
80102a65:	74 12                	je     80102a79 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a67:	68 00 00 01 00       	push   $0x10000
80102a6c:	68 d0 00 00 00       	push   $0xd0
80102a71:	e8 42 ff ff ff       	call   801029b8 <lapicw>
80102a76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a79:	6a 33                	push   $0x33
80102a7b:	68 dc 00 00 00       	push   $0xdc
80102a80:	e8 33 ff ff ff       	call   801029b8 <lapicw>
80102a85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a88:	6a 00                	push   $0x0
80102a8a:	68 a0 00 00 00       	push   $0xa0
80102a8f:	e8 24 ff ff ff       	call   801029b8 <lapicw>
80102a94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a97:	6a 00                	push   $0x0
80102a99:	68 a0 00 00 00       	push   $0xa0
80102a9e:	e8 15 ff ff ff       	call   801029b8 <lapicw>
80102aa3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa6:	6a 00                	push   $0x0
80102aa8:	6a 2c                	push   $0x2c
80102aaa:	e8 09 ff ff ff       	call   801029b8 <lapicw>
80102aaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab2:	6a 00                	push   $0x0
80102ab4:	68 c4 00 00 00       	push   $0xc4
80102ab9:	e8 fa fe ff ff       	call   801029b8 <lapicw>
80102abe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac1:	68 00 85 08 00       	push   $0x88500
80102ac6:	68 c0 00 00 00       	push   $0xc0
80102acb:	e8 e8 fe ff ff       	call   801029b8 <lapicw>
80102ad0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad3:	90                   	nop
80102ad4:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ad9:	05 00 03 00 00       	add    $0x300,%eax
80102ade:	8b 00                	mov    (%eax),%eax
80102ae0:	25 00 10 00 00       	and    $0x1000,%eax
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	75 eb                	jne    80102ad4 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ae9:	6a 00                	push   $0x0
80102aeb:	6a 20                	push   $0x20
80102aed:	e8 c6 fe ff ff       	call   801029b8 <lapicw>
80102af2:	83 c4 08             	add    $0x8,%esp
80102af5:	eb 01                	jmp    80102af8 <lapicinit+0x11d>
    return;
80102af7:	90                   	nop
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <lapicid>:

int
lapicid(void)
{
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afd:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b02:	85 c0                	test   %eax,%eax
80102b04:	75 07                	jne    80102b0d <lapicid+0x13>
    return 0;
80102b06:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0b:	eb 0d                	jmp    80102b1a <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0d:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b12:	83 c0 20             	add    $0x20,%eax
80102b15:	8b 00                	mov    (%eax),%eax
80102b17:	c1 e8 18             	shr    $0x18,%eax
}
80102b1a:	5d                   	pop    %ebp
80102b1b:	c3                   	ret    

80102b1c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b1f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b24:	85 c0                	test   %eax,%eax
80102b26:	74 0c                	je     80102b34 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b28:	6a 00                	push   $0x0
80102b2a:	6a 2c                	push   $0x2c
80102b2c:	e8 87 fe ff ff       	call   801029b8 <lapicw>
80102b31:	83 c4 08             	add    $0x8,%esp
}
80102b34:	90                   	nop
80102b35:	c9                   	leave  
80102b36:	c3                   	ret    

80102b37 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b37:	55                   	push   %ebp
80102b38:	89 e5                	mov    %esp,%ebp
}
80102b3a:	90                   	nop
80102b3b:	5d                   	pop    %ebp
80102b3c:	c3                   	ret    

80102b3d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
80102b40:	83 ec 14             	sub    $0x14,%esp
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b49:	6a 0f                	push   $0xf
80102b4b:	6a 70                	push   $0x70
80102b4d:	e8 45 fe ff ff       	call   80102997 <outb>
80102b52:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b55:	6a 0a                	push   $0xa
80102b57:	6a 71                	push   $0x71
80102b59:	e8 39 fe ff ff       	call   80102997 <outb>
80102b5e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b61:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b73:	c1 e8 04             	shr    $0x4,%eax
80102b76:	89 c2                	mov    %eax,%edx
80102b78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7b:	83 c0 02             	add    $0x2,%eax
80102b7e:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b81:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b85:	c1 e0 18             	shl    $0x18,%eax
80102b88:	50                   	push   %eax
80102b89:	68 c4 00 00 00       	push   $0xc4
80102b8e:	e8 25 fe ff ff       	call   801029b8 <lapicw>
80102b93:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b96:	68 00 c5 00 00       	push   $0xc500
80102b9b:	68 c0 00 00 00       	push   $0xc0
80102ba0:	e8 13 fe ff ff       	call   801029b8 <lapicw>
80102ba5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba8:	68 c8 00 00 00       	push   $0xc8
80102bad:	e8 85 ff ff ff       	call   80102b37 <microdelay>
80102bb2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb5:	68 00 85 00 00       	push   $0x8500
80102bba:	68 c0 00 00 00       	push   $0xc0
80102bbf:	e8 f4 fd ff ff       	call   801029b8 <lapicw>
80102bc4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc7:	6a 64                	push   $0x64
80102bc9:	e8 69 ff ff ff       	call   80102b37 <microdelay>
80102bce:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd8:	eb 3d                	jmp    80102c17 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bda:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bde:	c1 e0 18             	shl    $0x18,%eax
80102be1:	50                   	push   %eax
80102be2:	68 c4 00 00 00       	push   $0xc4
80102be7:	e8 cc fd ff ff       	call   801029b8 <lapicw>
80102bec:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bef:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf2:	c1 e8 0c             	shr    $0xc,%eax
80102bf5:	80 cc 06             	or     $0x6,%ah
80102bf8:	50                   	push   %eax
80102bf9:	68 c0 00 00 00       	push   $0xc0
80102bfe:	e8 b5 fd ff ff       	call   801029b8 <lapicw>
80102c03:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c06:	68 c8 00 00 00       	push   $0xc8
80102c0b:	e8 27 ff ff ff       	call   80102b37 <microdelay>
80102c10:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c17:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1b:	7e bd                	jle    80102bda <lapicstartap+0x9d>
  }
}
80102c1d:	90                   	nop
80102c1e:	90                   	nop
80102c1f:	c9                   	leave  
80102c20:	c3                   	ret    

80102c21 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c21:	55                   	push   %ebp
80102c22:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c24:	8b 45 08             	mov    0x8(%ebp),%eax
80102c27:	0f b6 c0             	movzbl %al,%eax
80102c2a:	50                   	push   %eax
80102c2b:	6a 70                	push   $0x70
80102c2d:	e8 65 fd ff ff       	call   80102997 <outb>
80102c32:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c35:	68 c8 00 00 00       	push   $0xc8
80102c3a:	e8 f8 fe ff ff       	call   80102b37 <microdelay>
80102c3f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c42:	6a 71                	push   $0x71
80102c44:	e8 31 fd ff ff       	call   8010297a <inb>
80102c49:	83 c4 04             	add    $0x4,%esp
80102c4c:	0f b6 c0             	movzbl %al,%eax
}
80102c4f:	c9                   	leave  
80102c50:	c3                   	ret    

80102c51 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c54:	6a 00                	push   $0x0
80102c56:	e8 c6 ff ff ff       	call   80102c21 <cmos_read>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c61:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c63:	6a 02                	push   $0x2
80102c65:	e8 b7 ff ff ff       	call   80102c21 <cmos_read>
80102c6a:	83 c4 04             	add    $0x4,%esp
80102c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c70:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c73:	6a 04                	push   $0x4
80102c75:	e8 a7 ff ff ff       	call   80102c21 <cmos_read>
80102c7a:	83 c4 04             	add    $0x4,%esp
80102c7d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c80:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c83:	6a 07                	push   $0x7
80102c85:	e8 97 ff ff ff       	call   80102c21 <cmos_read>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c90:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c93:	6a 08                	push   $0x8
80102c95:	e8 87 ff ff ff       	call   80102c21 <cmos_read>
80102c9a:	83 c4 04             	add    $0x4,%esp
80102c9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca3:	6a 09                	push   $0x9
80102ca5:	e8 77 ff ff ff       	call   80102c21 <cmos_read>
80102caa:	83 c4 04             	add    $0x4,%esp
80102cad:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb0:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb3:	90                   	nop
80102cb4:	c9                   	leave  
80102cb5:	c3                   	ret    

80102cb6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb6:	55                   	push   %ebp
80102cb7:	89 e5                	mov    %esp,%ebp
80102cb9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbc:	6a 0b                	push   $0xb
80102cbe:	e8 5e ff ff ff       	call   80102c21 <cmos_read>
80102cc3:	83 c4 04             	add    $0x4,%esp
80102cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	83 e0 04             	and    $0x4,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	0f 94 c0             	sete   %al
80102cd4:	0f b6 c0             	movzbl %al,%eax
80102cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cda:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdd:	50                   	push   %eax
80102cde:	e8 6e ff ff ff       	call   80102c51 <fill_rtcdate>
80102ce3:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce6:	6a 0a                	push   $0xa
80102ce8:	e8 34 ff ff ff       	call   80102c21 <cmos_read>
80102ced:	83 c4 04             	add    $0x4,%esp
80102cf0:	25 80 00 00 00       	and    $0x80,%eax
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	75 27                	jne    80102d20 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cf9:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfc:	50                   	push   %eax
80102cfd:	e8 4f ff ff ff       	call   80102c51 <fill_rtcdate>
80102d02:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d05:	83 ec 04             	sub    $0x4,%esp
80102d08:	6a 18                	push   $0x18
80102d0a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0d:	50                   	push   %eax
80102d0e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d11:	50                   	push   %eax
80102d12:	e8 14 20 00 00       	call   80104d2b <memcmp>
80102d17:	83 c4 10             	add    $0x10,%esp
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	74 05                	je     80102d23 <cmostime+0x6d>
80102d1e:	eb ba                	jmp    80102cda <cmostime+0x24>
        continue;
80102d20:	90                   	nop
    fill_rtcdate(&t1);
80102d21:	eb b7                	jmp    80102cda <cmostime+0x24>
      break;
80102d23:	90                   	nop
  }

  // convert
  if(bcd) {
80102d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d28:	0f 84 b4 00 00 00    	je     80102de2 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d31:	c1 e8 04             	shr    $0x4,%eax
80102d34:	89 c2                	mov    %eax,%edx
80102d36:	89 d0                	mov    %edx,%eax
80102d38:	c1 e0 02             	shl    $0x2,%eax
80102d3b:	01 d0                	add    %edx,%eax
80102d3d:	01 c0                	add    %eax,%eax
80102d3f:	89 c2                	mov    %eax,%edx
80102d41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d44:	83 e0 0f             	and    $0xf,%eax
80102d47:	01 d0                	add    %edx,%eax
80102d49:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4f:	c1 e8 04             	shr    $0x4,%eax
80102d52:	89 c2                	mov    %eax,%edx
80102d54:	89 d0                	mov    %edx,%eax
80102d56:	c1 e0 02             	shl    $0x2,%eax
80102d59:	01 d0                	add    %edx,%eax
80102d5b:	01 c0                	add    %eax,%eax
80102d5d:	89 c2                	mov    %eax,%edx
80102d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d62:	83 e0 0f             	and    $0xf,%eax
80102d65:	01 d0                	add    %edx,%eax
80102d67:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6d:	c1 e8 04             	shr    $0x4,%eax
80102d70:	89 c2                	mov    %eax,%edx
80102d72:	89 d0                	mov    %edx,%eax
80102d74:	c1 e0 02             	shl    $0x2,%eax
80102d77:	01 d0                	add    %edx,%eax
80102d79:	01 c0                	add    %eax,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d80:	83 e0 0f             	and    $0xf,%eax
80102d83:	01 d0                	add    %edx,%eax
80102d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8b:	c1 e8 04             	shr    $0x4,%eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	89 d0                	mov    %edx,%eax
80102d92:	c1 e0 02             	shl    $0x2,%eax
80102d95:	01 d0                	add    %edx,%eax
80102d97:	01 c0                	add    %eax,%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9e:	83 e0 0f             	and    $0xf,%eax
80102da1:	01 d0                	add    %edx,%eax
80102da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da9:	c1 e8 04             	shr    $0x4,%eax
80102dac:	89 c2                	mov    %eax,%edx
80102dae:	89 d0                	mov    %edx,%eax
80102db0:	c1 e0 02             	shl    $0x2,%eax
80102db3:	01 d0                	add    %edx,%eax
80102db5:	01 c0                	add    %eax,%eax
80102db7:	89 c2                	mov    %eax,%edx
80102db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbc:	83 e0 0f             	and    $0xf,%eax
80102dbf:	01 d0                	add    %edx,%eax
80102dc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc7:	c1 e8 04             	shr    $0x4,%eax
80102dca:	89 c2                	mov    %eax,%edx
80102dcc:	89 d0                	mov    %edx,%eax
80102dce:	c1 e0 02             	shl    $0x2,%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	01 c0                	add    %eax,%eax
80102dd5:	89 c2                	mov    %eax,%edx
80102dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dda:	83 e0 0f             	and    $0xf,%eax
80102ddd:	01 d0                	add    %edx,%eax
80102ddf:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de2:	8b 45 08             	mov    0x8(%ebp),%eax
80102de5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de8:	89 10                	mov    %edx,(%eax)
80102dea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102ded:	89 50 04             	mov    %edx,0x4(%eax)
80102df0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df3:	89 50 08             	mov    %edx,0x8(%eax)
80102df6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102df9:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dff:	89 50 10             	mov    %edx,0x10(%eax)
80102e02:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e05:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	8b 40 14             	mov    0x14(%eax),%eax
80102e0e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1a:	90                   	nop
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
80102e20:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e23:	83 ec 08             	sub    $0x8,%esp
80102e26:	68 31 a7 10 80       	push   $0x8010a731
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 f7 1b 00 00       	call   80104a2c <initlock>
80102e35:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e38:	83 ec 08             	sub    $0x8,%esp
80102e3b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3e:	50                   	push   %eax
80102e3f:	ff 75 08             	push   0x8(%ebp)
80102e42:	e8 87 e5 ff ff       	call   801013ce <readsb>
80102e47:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4d:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e55:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5d:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e62:	e8 b3 01 00 00       	call   8010301a <recover_from_log>
}
80102e67:	90                   	nop
80102e68:	c9                   	leave  
80102e69:	c3                   	ret    

80102e6a <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6a:	55                   	push   %ebp
80102e6b:	89 e5                	mov    %esp,%ebp
80102e6d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e77:	e9 95 00 00 00       	jmp    80102f11 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7c:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e85:	01 d0                	add    %edx,%eax
80102e87:	83 c0 01             	add    $0x1,%eax
80102e8a:	89 c2                	mov    %eax,%edx
80102e8c:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e91:	83 ec 08             	sub    $0x8,%esp
80102e94:	52                   	push   %edx
80102e95:	50                   	push   %eax
80102e96:	e8 66 d3 ff ff       	call   80100201 <bread>
80102e9b:	83 c4 10             	add    $0x10,%esp
80102e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea4:	83 c0 10             	add    $0x10,%eax
80102ea7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eae:	89 c2                	mov    %eax,%edx
80102eb0:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	52                   	push   %edx
80102eb9:	50                   	push   %eax
80102eba:	e8 42 d3 ff ff       	call   80100201 <bread>
80102ebf:	83 c4 10             	add    $0x10,%esp
80102ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec8:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ece:	83 c0 5c             	add    $0x5c,%eax
80102ed1:	83 ec 04             	sub    $0x4,%esp
80102ed4:	68 00 02 00 00       	push   $0x200
80102ed9:	52                   	push   %edx
80102eda:	50                   	push   %eax
80102edb:	e8 a3 1e 00 00       	call   80104d83 <memmove>
80102ee0:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee3:	83 ec 0c             	sub    $0xc,%esp
80102ee6:	ff 75 ec             	push   -0x14(%ebp)
80102ee9:	e8 4c d3 ff ff       	call   8010023a <bwrite>
80102eee:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef1:	83 ec 0c             	sub    $0xc,%esp
80102ef4:	ff 75 f0             	push   -0x10(%ebp)
80102ef7:	e8 87 d3 ff ff       	call   80100283 <brelse>
80102efc:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102eff:	83 ec 0c             	sub    $0xc,%esp
80102f02:	ff 75 ec             	push   -0x14(%ebp)
80102f05:	e8 79 d3 ff ff       	call   80100283 <brelse>
80102f0a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f11:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f16:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f19:	0f 8c 5d ff ff ff    	jl     80102e7c <install_trans+0x12>
  }
}
80102f1f:	90                   	nop
80102f20:	90                   	nop
80102f21:	c9                   	leave  
80102f22:	c3                   	ret    

80102f23 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f23:	55                   	push   %ebp
80102f24:	89 e5                	mov    %esp,%ebp
80102f26:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f29:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2e:	89 c2                	mov    %eax,%edx
80102f30:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f35:	83 ec 08             	sub    $0x8,%esp
80102f38:	52                   	push   %edx
80102f39:	50                   	push   %eax
80102f3a:	e8 c2 d2 ff ff       	call   80100201 <bread>
80102f3f:	83 c4 10             	add    $0x10,%esp
80102f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f48:	83 c0 5c             	add    $0x5c,%eax
80102f4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	8b 00                	mov    (%eax),%eax
80102f53:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f5f:	eb 1b                	jmp    80102f7c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f67:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6e:	83 c2 10             	add    $0x10,%edx
80102f71:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7c:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f84:	7c db                	jl     80102f61 <read_head+0x3e>
  }
  brelse(buf);
80102f86:	83 ec 0c             	sub    $0xc,%esp
80102f89:	ff 75 f0             	push   -0x10(%ebp)
80102f8c:	e8 f2 d2 ff ff       	call   80100283 <brelse>
80102f91:	83 c4 10             	add    $0x10,%esp
}
80102f94:	90                   	nop
80102f95:	c9                   	leave  
80102f96:	c3                   	ret    

80102f97 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9d:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa2:	89 c2                	mov    %eax,%edx
80102fa4:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fa9:	83 ec 08             	sub    $0x8,%esp
80102fac:	52                   	push   %edx
80102fad:	50                   	push   %eax
80102fae:	e8 4e d2 ff ff       	call   80100201 <bread>
80102fb3:	83 c4 10             	add    $0x10,%esp
80102fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbc:	83 c0 5c             	add    $0x5c,%eax
80102fbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc2:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd4:	eb 1b                	jmp    80102ff1 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd9:	83 c0 10             	add    $0x10,%eax
80102fdc:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fe9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff1:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ff9:	7c db                	jl     80102fd6 <write_head+0x3f>
  }
  bwrite(buf);
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	ff 75 f0             	push   -0x10(%ebp)
80103001:	e8 34 d2 ff ff       	call   8010023a <bwrite>
80103006:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	ff 75 f0             	push   -0x10(%ebp)
8010300f:	e8 6f d2 ff ff       	call   80100283 <brelse>
80103014:	83 c4 10             	add    $0x10,%esp
}
80103017:	90                   	nop
80103018:	c9                   	leave  
80103019:	c3                   	ret    

8010301a <recover_from_log>:

static void
recover_from_log(void)
{
8010301a:	55                   	push   %ebp
8010301b:	89 e5                	mov    %esp,%ebp
8010301d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103020:	e8 fe fe ff ff       	call   80102f23 <read_head>
  install_trans(); // if committed, copy from log to disk
80103025:	e8 40 fe ff ff       	call   80102e6a <install_trans>
  log.lh.n = 0;
8010302a:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103031:	00 00 00 
  write_head(); // clear the log
80103034:	e8 5e ff ff ff       	call   80102f97 <write_head>
}
80103039:	90                   	nop
8010303a:	c9                   	leave  
8010303b:	c3                   	ret    

8010303c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
8010303f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103042:	83 ec 0c             	sub    $0xc,%esp
80103045:	68 20 41 19 80       	push   $0x80194120
8010304a:	e8 ff 19 00 00       	call   80104a4e <acquire>
8010304f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103052:	a1 60 41 19 80       	mov    0x80194160,%eax
80103057:	85 c0                	test   %eax,%eax
80103059:	74 17                	je     80103072 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 20 41 19 80       	push   $0x80194120
80103063:	68 20 41 19 80       	push   $0x80194120
80103068:	e8 bd 15 00 00       	call   8010462a <sleep>
8010306d:	83 c4 10             	add    $0x10,%esp
80103070:	eb e0                	jmp    80103052 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103072:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103078:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307d:	8d 50 01             	lea    0x1(%eax),%edx
80103080:	89 d0                	mov    %edx,%eax
80103082:	c1 e0 02             	shl    $0x2,%eax
80103085:	01 d0                	add    %edx,%eax
80103087:	01 c0                	add    %eax,%eax
80103089:	01 c8                	add    %ecx,%eax
8010308b:	83 f8 1e             	cmp    $0x1e,%eax
8010308e:	7e 17                	jle    801030a7 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103090:	83 ec 08             	sub    $0x8,%esp
80103093:	68 20 41 19 80       	push   $0x80194120
80103098:	68 20 41 19 80       	push   $0x80194120
8010309d:	e8 88 15 00 00       	call   8010462a <sleep>
801030a2:	83 c4 10             	add    $0x10,%esp
801030a5:	eb ab                	jmp    80103052 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ac:	83 c0 01             	add    $0x1,%eax
801030af:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b4:	83 ec 0c             	sub    $0xc,%esp
801030b7:	68 20 41 19 80       	push   $0x80194120
801030bc:	e8 fb 19 00 00       	call   80104abc <release>
801030c1:	83 c4 10             	add    $0x10,%esp
      break;
801030c4:	90                   	nop
    }
  }
}
801030c5:	90                   	nop
801030c6:	c9                   	leave  
801030c7:	c3                   	ret    

801030c8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d5:	83 ec 0c             	sub    $0xc,%esp
801030d8:	68 20 41 19 80       	push   $0x80194120
801030dd:	e8 6c 19 00 00       	call   80104a4e <acquire>
801030e2:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ea:	83 e8 01             	sub    $0x1,%eax
801030ed:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f2:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 0d                	je     80103108 <end_op+0x40>
    panic("log.committing");
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	68 35 a7 10 80       	push   $0x8010a735
80103103:	e8 a1 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103108:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 13                	jne    80103124 <end_op+0x5c>
    do_commit = 1;
80103111:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103118:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010311f:	00 00 00 
80103122:	eb 10                	jmp    80103134 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 20 41 19 80       	push   $0x80194120
8010312c:	e8 e3 15 00 00       	call   80104714 <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 7b 19 00 00       	call   80104abc <release>
80103141:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103148:	74 3f                	je     80103189 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314a:	e8 f6 00 00 00       	call   80103245 <commit>
    acquire(&log.lock);
8010314f:	83 ec 0c             	sub    $0xc,%esp
80103152:	68 20 41 19 80       	push   $0x80194120
80103157:	e8 f2 18 00 00       	call   80104a4e <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 9e 15 00 00       	call   80104714 <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 36 19 00 00       	call   80104abc <release>
80103186:	83 c4 10             	add    $0x10,%esp
  }
}
80103189:	90                   	nop
8010318a:	c9                   	leave  
8010318b:	c3                   	ret    

8010318c <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103199:	e9 95 00 00 00       	jmp    80103233 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	01 d0                	add    %edx,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b3:	83 ec 08             	sub    $0x8,%esp
801031b6:	52                   	push   %edx
801031b7:	50                   	push   %eax
801031b8:	e8 44 d0 ff ff       	call   80100201 <bread>
801031bd:	83 c4 10             	add    $0x10,%esp
801031c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c6:	83 c0 10             	add    $0x10,%eax
801031c9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d0:	89 c2                	mov    %eax,%edx
801031d2:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d7:	83 ec 08             	sub    $0x8,%esp
801031da:	52                   	push   %edx
801031db:	50                   	push   %eax
801031dc:	e8 20 d0 ff ff       	call   80100201 <bread>
801031e1:	83 c4 10             	add    $0x10,%esp
801031e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f0:	83 c0 5c             	add    $0x5c,%eax
801031f3:	83 ec 04             	sub    $0x4,%esp
801031f6:	68 00 02 00 00       	push   $0x200
801031fb:	52                   	push   %edx
801031fc:	50                   	push   %eax
801031fd:	e8 81 1b 00 00       	call   80104d83 <memmove>
80103202:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103205:	83 ec 0c             	sub    $0xc,%esp
80103208:	ff 75 f0             	push   -0x10(%ebp)
8010320b:	e8 2a d0 ff ff       	call   8010023a <bwrite>
80103210:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103213:	83 ec 0c             	sub    $0xc,%esp
80103216:	ff 75 ec             	push   -0x14(%ebp)
80103219:	e8 65 d0 ff ff       	call   80100283 <brelse>
8010321e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103221:	83 ec 0c             	sub    $0xc,%esp
80103224:	ff 75 f0             	push   -0x10(%ebp)
80103227:	e8 57 d0 ff ff       	call   80100283 <brelse>
8010322c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010322f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103233:	a1 68 41 19 80       	mov    0x80194168,%eax
80103238:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323b:	0f 8c 5d ff ff ff    	jl     8010319e <write_log+0x12>
  }
}
80103241:	90                   	nop
80103242:	90                   	nop
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <commit>:

static void
commit()
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103250:	85 c0                	test   %eax,%eax
80103252:	7e 1e                	jle    80103272 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103254:	e8 33 ff ff ff       	call   8010318c <write_log>
    write_head();    // Write header to disk -- the real commit
80103259:	e8 39 fd ff ff       	call   80102f97 <write_head>
    install_trans(); // Now install writes to home locations
8010325e:	e8 07 fc ff ff       	call   80102e6a <install_trans>
    log.lh.n = 0;
80103263:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326d:	e8 25 fd ff ff       	call   80102f97 <write_head>
  }
}
80103272:	90                   	nop
80103273:	c9                   	leave  
80103274:	c3                   	ret    

80103275 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103275:	55                   	push   %ebp
80103276:	89 e5                	mov    %esp,%ebp
80103278:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103280:	83 f8 1d             	cmp    $0x1d,%eax
80103283:	7f 12                	jg     80103297 <log_write+0x22>
80103285:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328a:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103290:	83 ea 01             	sub    $0x1,%edx
80103293:	39 d0                	cmp    %edx,%eax
80103295:	7c 0d                	jl     801032a4 <log_write+0x2f>
    panic("too big a transaction");
80103297:	83 ec 0c             	sub    $0xc,%esp
8010329a:	68 44 a7 10 80       	push   $0x8010a744
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 5a a7 10 80       	push   $0x8010a75a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 87 17 00 00       	call   80104a4e <acquire>
801032c7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d1:	eb 1d                	jmp    801032f0 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d6:	83 c0 10             	add    $0x10,%eax
801032d9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	8b 45 08             	mov    0x8(%ebp),%eax
801032e5:	8b 40 08             	mov    0x8(%eax),%eax
801032e8:	39 c2                	cmp    %eax,%edx
801032ea:	74 10                	je     801032fc <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f0:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f8:	7c d9                	jl     801032d3 <log_write+0x5e>
801032fa:	eb 01                	jmp    801032fd <log_write+0x88>
      break;
801032fc:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103300:	8b 40 08             	mov    0x8(%eax),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103308:	83 c0 10             	add    $0x10,%eax
8010330b:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103312:	a1 68 41 19 80       	mov    0x80194168,%eax
80103317:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331a:	75 0d                	jne    80103329 <log_write+0xb4>
    log.lh.n++;
8010331c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103321:	83 c0 01             	add    $0x1,%eax
80103324:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103329:	8b 45 08             	mov    0x8(%ebp),%eax
8010332c:	8b 00                	mov    (%eax),%eax
8010332e:	83 c8 04             	or     $0x4,%eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	8b 45 08             	mov    0x8(%ebp),%eax
80103336:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	68 20 41 19 80       	push   $0x80194120
80103340:	e8 77 17 00 00       	call   80104abc <release>
80103345:	83 c4 10             	add    $0x10,%esp
}
80103348:	90                   	nop
80103349:	c9                   	leave  
8010334a:	c3                   	ret    

8010334b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
8010334e:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103351:	8b 55 08             	mov    0x8(%ebp),%edx
80103354:	8b 45 0c             	mov    0xc(%ebp),%eax
80103357:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335a:	f0 87 02             	lock xchg %eax,(%edx)
8010335d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103360:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103363:	c9                   	leave  
80103364:	c3                   	ret    

80103365 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103365:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103369:	83 e4 f0             	and    $0xfffffff0,%esp
8010336c:	ff 71 fc             	push   -0x4(%ecx)
8010336f:	55                   	push   %ebp
80103370:	89 e5                	mov    %esp,%ebp
80103372:	51                   	push   %ecx
80103373:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103376:	e8 3d 4f 00 00       	call   801082b8 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 3d 45 00 00       	call   801078d2 <kvmalloc>
  mpinit_uefi();
80103395:	e8 e4 4c 00 00       	call   8010807e <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 c6 3f 00 00       	call   8010736a <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 4b 33 00 00       	call   80106703 <uartinit>
  pinit();         // process table
801033b8:	e8 5e 06 00 00       	call   80103a1b <pinit>
  tvinit();        // trap vectors
801033bd:	e8 82 2e 00 00       	call   80106244 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 28 70 00 00       	call   8010a3f9 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 21 51 00 00       	call   80108511 <pci_init>
  arp_scan();
801033f0:	e8 58 5e 00 00       	call   8010924d <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 3a 08 00 00       	call   80103c34 <userinit>

  mpmain();        // finish this processor's setup
801033fa:	e8 1a 00 00 00       	call   80103419 <mpmain>

801033ff <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103405:	e8 e0 44 00 00       	call   801078ea <switchkvm>
  seginit();
8010340a:	e8 5b 3f 00 00       	call   8010736a <seginit>
  lapicinit();
8010340f:	e8 c7 f5 ff ff       	call   801029db <lapicinit>
  mpmain();
80103414:	e8 00 00 00 00       	call   80103419 <mpmain>

80103419 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	53                   	push   %ebx
8010341d:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103420:	e8 14 06 00 00       	call   80103a39 <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 0d 06 00 00       	call   80103a39 <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 75 a7 10 80       	push   $0x8010a775
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 77 2f 00 00       	call   801063ba <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 0c 06 00 00       	call   80103a54 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 65 0d 00 00       	call   801041c5 <scheduler>

80103460 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103460:	55                   	push   %ebp
80103461:	89 e5                	mov    %esp,%ebp
80103463:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103466:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103472:	83 ec 04             	sub    $0x4,%esp
80103475:	50                   	push   %eax
80103476:	68 38 f5 10 80       	push   $0x8010f538
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 00 19 00 00       	call   80104d83 <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 72 19 80 	movl   $0x80197280,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 c0 05 00 00       	call   80103a54 <mycpu>
80103494:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103497:	74 67                	je     80103500 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103499:	e8 02 f3 ff ff       	call   801027a0 <kalloc>
8010349e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a4:	83 e8 04             	sub    $0x4,%eax
801034a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034aa:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b0:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	83 e8 08             	sub    $0x8,%eax
801034b8:	c7 00 ff 33 10 80    	movl   $0x801033ff,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034be:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cc:	83 e8 0c             	sub    $0xc,%eax
801034cf:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dd:	0f b6 00             	movzbl (%eax),%eax
801034e0:	0f b6 c0             	movzbl %al,%eax
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	52                   	push   %edx
801034e7:	50                   	push   %eax
801034e8:	e8 50 f6 ff ff       	call   80102b3d <lapicstartap>
801034ed:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f0:	90                   	nop
801034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fa:	85 c0                	test   %eax,%eax
801034fc:	74 f3                	je     801034f1 <startothers+0x91>
801034fe:	eb 01                	jmp    80103501 <startothers+0xa1>
      continue;
80103500:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103501:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
80103508:	a1 50 75 19 80       	mov    0x80197550,%eax
8010350d:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103513:	05 80 72 19 80       	add    $0x80197280,%eax
80103518:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351b:	0f 82 6e ff ff ff    	jb     8010348f <startothers+0x2f>
      ;
  }
}
80103521:	90                   	nop
80103522:	90                   	nop
80103523:	c9                   	leave  
80103524:	c3                   	ret    

80103525 <outb>:
{
80103525:	55                   	push   %ebp
80103526:	89 e5                	mov    %esp,%ebp
80103528:	83 ec 08             	sub    $0x8,%esp
8010352b:	8b 45 08             	mov    0x8(%ebp),%eax
8010352e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103531:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103535:	89 d0                	mov    %edx,%eax
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d0 ff ff ff       	call   80103525 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 be ff ff ff       	call   80103525 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave  
8010356c:	c3                   	ret    

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 4b da ff ff       	call   80100fdd <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 34 da ff ff       	call   80100fdd <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e0 f1 ff ff       	call   801027a0 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 89 a7 10 80       	push   $0x8010a789
8010360c:	50                   	push   %eax
8010360d:	e8 1a 14 00 00       	call   80104a2c <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 85 f0 ff ff       	call   80102706 <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 00 da ff ff       	call   8010109b <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 e6 d9 ff ff       	call   8010109b <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave  
801036be:	c3                   	ret    

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 7d 13 00 00       	call   80104a4e <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 1c 10 00 00       	call   80104714 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 f9 0f 00 00       	call   80104714 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 78 13 00 00       	call   80104abc <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 b4 ef ff ff       	call   80102706 <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 59 13 00 00       	call   80104abc <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 d1 12 00 00       	call   80104a4e <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 2e 03 00 00       	call   80103acc <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 0b 13 00 00       	call   80104abc <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 45 0f 00 00       	call   80104714 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 42 0e 00 00       	call   8010462a <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 c2 0e 00 00       	call   80104714 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 5b 12 00 00       	call   80104abc <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 d0 11 00 00       	call   80104a4e <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 44 02 00 00       	call   80103acc <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 21 12 00 00       	call   80104abc <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 6c 0d 00 00       	call   8010462a <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 c3 0d 00 00       	call   80104714 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 5c 11 00 00       	call   80104abc <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave  
80103967:	c3                   	ret    

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf  
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti    
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret    

8010397f <getqinfo>:
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

int getqinfo(int pid) {
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80103985:	83 ec 0c             	sub    $0xc,%esp
80103988:	68 00 42 19 80       	push   $0x80194200
8010398d:	e8 bc 10 00 00       	call   80104a4e <acquire>
80103992:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103995:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010399c:	eb 5d                	jmp    801039fb <getqinfo+0x7c>
      if(p->pid == pid) {
8010399e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a1:	8b 40 10             	mov    0x10(%eax),%eax
801039a4:	39 45 08             	cmp    %eax,0x8(%ebp)
801039a7:	75 4b                	jne    801039f4 <getqinfo+0x75>
          cprintf("Process %d is in Queue %d\n", pid, p->priority);
801039a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ac:	8b 40 7c             	mov    0x7c(%eax),%eax
801039af:	83 ec 04             	sub    $0x4,%esp
801039b2:	50                   	push   %eax
801039b3:	ff 75 08             	push   0x8(%ebp)
801039b6:	68 90 a7 10 80       	push   $0x8010a790
801039bb:	e8 34 ca ff ff       	call   801003f4 <cprintf>
801039c0:	83 c4 10             	add    $0x10,%esp
          cprintf("Wait time: %d ticks\n", p->wait_ticks);
801039c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c6:	05 90 00 00 00       	add    $0x90,%eax
801039cb:	83 ec 08             	sub    $0x8,%esp
801039ce:	50                   	push   %eax
801039cf:	68 ab a7 10 80       	push   $0x8010a7ab
801039d4:	e8 1b ca ff ff       	call   801003f4 <cprintf>
801039d9:	83 c4 10             	add    $0x10,%esp
          release(&ptable.lock);
801039dc:	83 ec 0c             	sub    $0xc,%esp
801039df:	68 00 42 19 80       	push   $0x80194200
801039e4:	e8 d3 10 00 00       	call   80104abc <release>
801039e9:	83 c4 10             	add    $0x10,%esp
          return p->priority;          
801039ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ef:	8b 40 7c             	mov    0x7c(%eax),%eax
801039f2:	eb 25                	jmp    80103a19 <getqinfo+0x9a>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801039f4:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801039fb:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80103a02:	72 9a                	jb     8010399e <getqinfo+0x1f>
        }
  }
  release(&ptable.lock);
80103a04:	83 ec 0c             	sub    $0xc,%esp
80103a07:	68 00 42 19 80       	push   $0x80194200
80103a0c:	e8 ab 10 00 00       	call   80104abc <release>
80103a11:	83 c4 10             	add    $0x10,%esp
  return -1; 
80103a14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103a19:	c9                   	leave  
80103a1a:	c3                   	ret    

80103a1b <pinit>:

void
pinit(void)
{
80103a1b:	55                   	push   %ebp
80103a1c:	89 e5                	mov    %esp,%ebp
80103a1e:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103a21:	83 ec 08             	sub    $0x8,%esp
80103a24:	68 c0 a7 10 80       	push   $0x8010a7c0
80103a29:	68 00 42 19 80       	push   $0x80194200
80103a2e:	e8 f9 0f 00 00       	call   80104a2c <initlock>
80103a33:	83 c4 10             	add    $0x10,%esp
}
80103a36:	90                   	nop
80103a37:	c9                   	leave  
80103a38:	c3                   	ret    

80103a39 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103a39:	55                   	push   %ebp
80103a3a:	89 e5                	mov    %esp,%ebp
80103a3c:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103a3f:	e8 10 00 00 00       	call   80103a54 <mycpu>
80103a44:	2d 80 72 19 80       	sub    $0x80197280,%eax
80103a49:	c1 f8 02             	sar    $0x2,%eax
80103a4c:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
80103a52:	c9                   	leave  
80103a53:	c3                   	ret    

80103a54 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103a54:	55                   	push   %ebp
80103a55:	89 e5                	mov    %esp,%ebp
80103a57:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103a5a:	e8 09 ff ff ff       	call   80103968 <readeflags>
80103a5f:	25 00 02 00 00       	and    $0x200,%eax
80103a64:	85 c0                	test   %eax,%eax
80103a66:	74 0d                	je     80103a75 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103a68:	83 ec 0c             	sub    $0xc,%esp
80103a6b:	68 c8 a7 10 80       	push   $0x8010a7c8
80103a70:	e8 34 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103a75:	e8 80 f0 ff ff       	call   80102afa <lapicid>
80103a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103a7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a84:	eb 2d                	jmp    80103ab3 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a89:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a8f:	05 80 72 19 80       	add    $0x80197280,%eax
80103a94:	0f b6 00             	movzbl (%eax),%eax
80103a97:	0f b6 c0             	movzbl %al,%eax
80103a9a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a9d:	75 10                	jne    80103aaf <mycpu+0x5b>
      return &cpus[i];
80103a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa2:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103aa8:	05 80 72 19 80       	add    $0x80197280,%eax
80103aad:	eb 1b                	jmp    80103aca <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103aaf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ab3:	a1 50 75 19 80       	mov    0x80197550,%eax
80103ab8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103abb:	7c c9                	jl     80103a86 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103abd:	83 ec 0c             	sub    $0xc,%esp
80103ac0:	68 ee a7 10 80       	push   $0x8010a7ee
80103ac5:	e8 df ca ff ff       	call   801005a9 <panic>
}
80103aca:	c9                   	leave  
80103acb:	c3                   	ret    

80103acc <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103acc:	55                   	push   %ebp
80103acd:	89 e5                	mov    %esp,%ebp
80103acf:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103ad2:	e8 e2 10 00 00       	call   80104bb9 <pushcli>
  c = mycpu();
80103ad7:	e8 78 ff ff ff       	call   80103a54 <mycpu>
80103adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103ae8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103aeb:	e8 16 11 00 00       	call   80104c06 <popcli>
  return p;
80103af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103af3:	c9                   	leave  
80103af4:	c3                   	ret    

80103af5 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103af5:	55                   	push   %ebp
80103af6:	89 e5                	mov    %esp,%ebp
80103af8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103afb:	83 ec 0c             	sub    $0xc,%esp
80103afe:	68 00 42 19 80       	push   $0x80194200
80103b03:	e8 46 0f 00 00       	call   80104a4e <acquire>
80103b08:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103b0b:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103b12:	eb 11                	jmp    80103b25 <allocproc+0x30>
    if(p->state == UNUSED){
80103b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b17:	8b 40 0c             	mov    0xc(%eax),%eax
80103b1a:	85 c0                	test   %eax,%eax
80103b1c:	74 2a                	je     80103b48 <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103b1e:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80103b25:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80103b2c:	72 e6                	jb     80103b14 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103b2e:	83 ec 0c             	sub    $0xc,%esp
80103b31:	68 00 42 19 80       	push   $0x80194200
80103b36:	e8 81 0f 00 00       	call   80104abc <release>
80103b3b:	83 c4 10             	add    $0x10,%esp
  return 0;
80103b3e:	b8 00 00 00 00       	mov    $0x0,%eax
80103b43:	e9 ea 00 00 00       	jmp    80103c32 <allocproc+0x13d>
      goto found;
80103b48:	90                   	nop

found:
  p->state = EMBRYO;
80103b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4c:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103b53:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103b58:	8d 50 01             	lea    0x1(%eax),%edx
80103b5b:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103b61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b64:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103b67:	83 ec 0c             	sub    $0xc,%esp
80103b6a:	68 00 42 19 80       	push   $0x80194200
80103b6f:	e8 48 0f 00 00       	call   80104abc <release>
80103b74:	83 c4 10             	add    $0x10,%esp

  p->priority = 3;
80103b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7a:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  memset(p->ticks, 0, sizeof(p->ticks));
80103b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b84:	83 e8 80             	sub    $0xffffff80,%eax
80103b87:	83 ec 04             	sub    $0x4,%esp
80103b8a:	6a 10                	push   $0x10
80103b8c:	6a 00                	push   $0x0
80103b8e:	50                   	push   %eax
80103b8f:	e8 30 11 00 00       	call   80104cc4 <memset>
80103b94:	83 c4 10             	add    $0x10,%esp
  memset(p->wait_ticks, 0, sizeof(p->wait_ticks));
80103b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9a:	05 90 00 00 00       	add    $0x90,%eax
80103b9f:	83 ec 04             	sub    $0x4,%esp
80103ba2:	6a 10                	push   $0x10
80103ba4:	6a 00                	push   $0x0
80103ba6:	50                   	push   %eax
80103ba7:	e8 18 11 00 00       	call   80104cc4 <memset>
80103bac:	83 c4 10             	add    $0x10,%esp
  
  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103baf:	e8 ec eb ff ff       	call   801027a0 <kalloc>
80103bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bb7:	89 42 08             	mov    %eax,0x8(%edx)
80103bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbd:	8b 40 08             	mov    0x8(%eax),%eax
80103bc0:	85 c0                	test   %eax,%eax
80103bc2:	75 11                	jne    80103bd5 <allocproc+0xe0>
    p->state = UNUSED;
80103bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103bce:	b8 00 00 00 00       	mov    $0x0,%eax
80103bd3:	eb 5d                	jmp    80103c32 <allocproc+0x13d>
  }
  sp = p->kstack + KSTACKSIZE;
80103bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd8:	8b 40 08             	mov    0x8(%eax),%eax
80103bdb:	05 00 10 00 00       	add    $0x1000,%eax
80103be0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103be3:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103bed:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103bf0:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103bf4:	ba fe 61 10 80       	mov    $0x801061fe,%edx
80103bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfc:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103bfe:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c05:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103c08:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0e:	8b 40 1c             	mov    0x1c(%eax),%eax
80103c11:	83 ec 04             	sub    $0x4,%esp
80103c14:	6a 14                	push   $0x14
80103c16:	6a 00                	push   $0x0
80103c18:	50                   	push   %eax
80103c19:	e8 a6 10 00 00       	call   80104cc4 <memset>
80103c1e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	8b 40 1c             	mov    0x1c(%eax),%eax
80103c27:	ba e4 45 10 80       	mov    $0x801045e4,%edx
80103c2c:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103c32:	c9                   	leave  
80103c33:	c3                   	ret    

80103c34 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103c34:	55                   	push   %ebp
80103c35:	89 e5                	mov    %esp,%ebp
80103c37:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103c3a:	e8 b6 fe ff ff       	call   80103af5 <allocproc>
80103c3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c45:	a3 34 6a 19 80       	mov    %eax,0x80196a34
  if((p->pgdir = setupkvm()) == 0){
80103c4a:	e8 97 3b 00 00       	call   801077e6 <setupkvm>
80103c4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c52:	89 42 04             	mov    %eax,0x4(%edx)
80103c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c58:	8b 40 04             	mov    0x4(%eax),%eax
80103c5b:	85 c0                	test   %eax,%eax
80103c5d:	75 0d                	jne    80103c6c <userinit+0x38>
    panic("userinit: out of memory?");
80103c5f:	83 ec 0c             	sub    $0xc,%esp
80103c62:	68 fe a7 10 80       	push   $0x8010a7fe
80103c67:	e8 3d c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103c6c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c74:	8b 40 04             	mov    0x4(%eax),%eax
80103c77:	83 ec 04             	sub    $0x4,%esp
80103c7a:	52                   	push   %edx
80103c7b:	68 0c f5 10 80       	push   $0x8010f50c
80103c80:	50                   	push   %eax
80103c81:	e8 1c 3e 00 00       	call   80107aa2 <inituvm>
80103c86:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c95:	8b 40 18             	mov    0x18(%eax),%eax
80103c98:	83 ec 04             	sub    $0x4,%esp
80103c9b:	6a 4c                	push   $0x4c
80103c9d:	6a 00                	push   $0x0
80103c9f:	50                   	push   %eax
80103ca0:	e8 1f 10 00 00       	call   80104cc4 <memset>
80103ca5:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cab:	8b 40 18             	mov    0x18(%eax),%eax
80103cae:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb7:	8b 40 18             	mov    0x18(%eax),%eax
80103cba:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc3:	8b 50 18             	mov    0x18(%eax),%edx
80103cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc9:	8b 40 18             	mov    0x18(%eax),%eax
80103ccc:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103cd0:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd7:	8b 50 18             	mov    0x18(%eax),%edx
80103cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdd:	8b 40 18             	mov    0x18(%eax),%eax
80103ce0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103ce4:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ceb:	8b 40 18             	mov    0x18(%eax),%eax
80103cee:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf8:	8b 40 18             	mov    0x18(%eax),%eax
80103cfb:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d05:	8b 40 18             	mov    0x18(%eax),%eax
80103d08:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d12:	83 c0 6c             	add    $0x6c,%eax
80103d15:	83 ec 04             	sub    $0x4,%esp
80103d18:	6a 10                	push   $0x10
80103d1a:	68 17 a8 10 80       	push   $0x8010a817
80103d1f:	50                   	push   %eax
80103d20:	e8 a2 11 00 00       	call   80104ec7 <safestrcpy>
80103d25:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103d28:	83 ec 0c             	sub    $0xc,%esp
80103d2b:	68 20 a8 10 80       	push   $0x8010a820
80103d30:	e8 e8 e7 ff ff       	call   8010251d <namei>
80103d35:	83 c4 10             	add    $0x10,%esp
80103d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d3b:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103d3e:	83 ec 0c             	sub    $0xc,%esp
80103d41:	68 00 42 19 80       	push   $0x80194200
80103d46:	e8 03 0d 00 00       	call   80104a4e <acquire>
80103d4b:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d51:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103d58:	83 ec 0c             	sub    $0xc,%esp
80103d5b:	68 00 42 19 80       	push   $0x80194200
80103d60:	e8 57 0d 00 00       	call   80104abc <release>
80103d65:	83 c4 10             	add    $0x10,%esp
}
80103d68:	90                   	nop
80103d69:	c9                   	leave  
80103d6a:	c3                   	ret    

80103d6b <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103d6b:	55                   	push   %ebp
80103d6c:	89 e5                	mov    %esp,%ebp
80103d6e:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103d71:	e8 56 fd ff ff       	call   80103acc <myproc>
80103d76:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d7c:	8b 00                	mov    (%eax),%eax
80103d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103d81:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d85:	7e 2e                	jle    80103db5 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d87:	8b 55 08             	mov    0x8(%ebp),%edx
80103d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8d:	01 c2                	add    %eax,%edx
80103d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d92:	8b 40 04             	mov    0x4(%eax),%eax
80103d95:	83 ec 04             	sub    $0x4,%esp
80103d98:	52                   	push   %edx
80103d99:	ff 75 f4             	push   -0xc(%ebp)
80103d9c:	50                   	push   %eax
80103d9d:	e8 3d 3e 00 00       	call   80107bdf <allocuvm>
80103da2:	83 c4 10             	add    $0x10,%esp
80103da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103da8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dac:	75 3b                	jne    80103de9 <growproc+0x7e>
      return -1;
80103dae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103db3:	eb 4f                	jmp    80103e04 <growproc+0x99>
  } else if(n < 0){
80103db5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103db9:	79 2e                	jns    80103de9 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103dbb:	8b 55 08             	mov    0x8(%ebp),%edx
80103dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc1:	01 c2                	add    %eax,%edx
80103dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc6:	8b 40 04             	mov    0x4(%eax),%eax
80103dc9:	83 ec 04             	sub    $0x4,%esp
80103dcc:	52                   	push   %edx
80103dcd:	ff 75 f4             	push   -0xc(%ebp)
80103dd0:	50                   	push   %eax
80103dd1:	e8 0e 3f 00 00       	call   80107ce4 <deallocuvm>
80103dd6:	83 c4 10             	add    $0x10,%esp
80103dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ddc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103de0:	75 07                	jne    80103de9 <growproc+0x7e>
      return -1;
80103de2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103de7:	eb 1b                	jmp    80103e04 <growproc+0x99>
  }
  curproc->sz = sz;
80103de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103def:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103df1:	83 ec 0c             	sub    $0xc,%esp
80103df4:	ff 75 f0             	push   -0x10(%ebp)
80103df7:	e8 07 3b 00 00       	call   80107903 <switchuvm>
80103dfc:	83 c4 10             	add    $0x10,%esp
  return 0;
80103dff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e04:	c9                   	leave  
80103e05:	c3                   	ret    

80103e06 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103e06:	55                   	push   %ebp
80103e07:	89 e5                	mov    %esp,%ebp
80103e09:	57                   	push   %edi
80103e0a:	56                   	push   %esi
80103e0b:	53                   	push   %ebx
80103e0c:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103e0f:	e8 b8 fc ff ff       	call   80103acc <myproc>
80103e14:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103e17:	e8 d9 fc ff ff       	call   80103af5 <allocproc>
80103e1c:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103e1f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103e23:	75 0a                	jne    80103e2f <fork+0x29>
    return -1;
80103e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e2a:	e9 48 01 00 00       	jmp    80103f77 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103e2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e32:	8b 10                	mov    (%eax),%edx
80103e34:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e37:	8b 40 04             	mov    0x4(%eax),%eax
80103e3a:	83 ec 08             	sub    $0x8,%esp
80103e3d:	52                   	push   %edx
80103e3e:	50                   	push   %eax
80103e3f:	e8 3e 40 00 00       	call   80107e82 <copyuvm>
80103e44:	83 c4 10             	add    $0x10,%esp
80103e47:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4a:	89 42 04             	mov    %eax,0x4(%edx)
80103e4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e50:	8b 40 04             	mov    0x4(%eax),%eax
80103e53:	85 c0                	test   %eax,%eax
80103e55:	75 30                	jne    80103e87 <fork+0x81>
    kfree(np->kstack);
80103e57:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5a:	8b 40 08             	mov    0x8(%eax),%eax
80103e5d:	83 ec 0c             	sub    $0xc,%esp
80103e60:	50                   	push   %eax
80103e61:	e8 a0 e8 ff ff       	call   80102706 <kfree>
80103e66:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103e69:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103e73:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e76:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e82:	e9 f0 00 00 00       	jmp    80103f77 <fork+0x171>
  }
  np->sz = curproc->sz;
80103e87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e8a:	8b 10                	mov    (%eax),%edx
80103e8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e8f:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e91:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e94:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103e97:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e9d:	8b 48 18             	mov    0x18(%eax),%ecx
80103ea0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ea3:	8b 40 18             	mov    0x18(%eax),%eax
80103ea6:	89 c2                	mov    %eax,%edx
80103ea8:	89 cb                	mov    %ecx,%ebx
80103eaa:	b8 13 00 00 00       	mov    $0x13,%eax
80103eaf:	89 d7                	mov    %edx,%edi
80103eb1:	89 de                	mov    %ebx,%esi
80103eb3:	89 c1                	mov    %eax,%ecx
80103eb5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103eb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103eba:	8b 40 18             	mov    0x18(%eax),%eax
80103ebd:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103ec4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103ecb:	eb 3b                	jmp    80103f08 <fork+0x102>
    if(curproc->ofile[i])
80103ecd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ed0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103ed3:	83 c2 08             	add    $0x8,%edx
80103ed6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103eda:	85 c0                	test   %eax,%eax
80103edc:	74 26                	je     80103f04 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103ede:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ee1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103ee4:	83 c2 08             	add    $0x8,%edx
80103ee7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103eeb:	83 ec 0c             	sub    $0xc,%esp
80103eee:	50                   	push   %eax
80103eef:	e8 56 d1 ff ff       	call   8010104a <filedup>
80103ef4:	83 c4 10             	add    $0x10,%esp
80103ef7:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103efa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103efd:	83 c1 08             	add    $0x8,%ecx
80103f00:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103f04:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103f08:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103f0c:	7e bf                	jle    80103ecd <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103f0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f11:	8b 40 68             	mov    0x68(%eax),%eax
80103f14:	83 ec 0c             	sub    $0xc,%esp
80103f17:	50                   	push   %eax
80103f18:	e8 93 da ff ff       	call   801019b0 <idup>
80103f1d:	83 c4 10             	add    $0x10,%esp
80103f20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f23:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103f26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f29:	8d 50 6c             	lea    0x6c(%eax),%edx
80103f2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f2f:	83 c0 6c             	add    $0x6c,%eax
80103f32:	83 ec 04             	sub    $0x4,%esp
80103f35:	6a 10                	push   $0x10
80103f37:	52                   	push   %edx
80103f38:	50                   	push   %eax
80103f39:	e8 89 0f 00 00       	call   80104ec7 <safestrcpy>
80103f3e:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103f41:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f44:	8b 40 10             	mov    0x10(%eax),%eax
80103f47:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103f4a:	83 ec 0c             	sub    $0xc,%esp
80103f4d:	68 00 42 19 80       	push   $0x80194200
80103f52:	e8 f7 0a 00 00       	call   80104a4e <acquire>
80103f57:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103f5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f5d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103f64:	83 ec 0c             	sub    $0xc,%esp
80103f67:	68 00 42 19 80       	push   $0x80194200
80103f6c:	e8 4b 0b 00 00       	call   80104abc <release>
80103f71:	83 c4 10             	add    $0x10,%esp

  return pid;
80103f74:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f7a:	5b                   	pop    %ebx
80103f7b:	5e                   	pop    %esi
80103f7c:	5f                   	pop    %edi
80103f7d:	5d                   	pop    %ebp
80103f7e:	c3                   	ret    

80103f7f <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103f7f:	55                   	push   %ebp
80103f80:	89 e5                	mov    %esp,%ebp
80103f82:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103f85:	e8 42 fb ff ff       	call   80103acc <myproc>
80103f8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103f8d:	a1 34 6a 19 80       	mov    0x80196a34,%eax
80103f92:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f95:	75 0d                	jne    80103fa4 <exit+0x25>
    panic("init exiting");
80103f97:	83 ec 0c             	sub    $0xc,%esp
80103f9a:	68 22 a8 10 80       	push   $0x8010a822
80103f9f:	e8 05 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103fa4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103fab:	eb 3f                	jmp    80103fec <exit+0x6d>
    if(curproc->ofile[fd]){
80103fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fb3:	83 c2 08             	add    $0x8,%edx
80103fb6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fba:	85 c0                	test   %eax,%eax
80103fbc:	74 2a                	je     80103fe8 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103fbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fc1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fc4:	83 c2 08             	add    $0x8,%edx
80103fc7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fcb:	83 ec 0c             	sub    $0xc,%esp
80103fce:	50                   	push   %eax
80103fcf:	e8 c7 d0 ff ff       	call   8010109b <fileclose>
80103fd4:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103fd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fda:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fdd:	83 c2 08             	add    $0x8,%edx
80103fe0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103fe7:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103fe8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103fec:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103ff0:	7e bb                	jle    80103fad <exit+0x2e>
    }
  }

  begin_op();
80103ff2:	e8 45 f0 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103ff7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ffa:	8b 40 68             	mov    0x68(%eax),%eax
80103ffd:	83 ec 0c             	sub    $0xc,%esp
80104000:	50                   	push   %eax
80104001:	e8 45 db ff ff       	call   80101b4b <iput>
80104006:	83 c4 10             	add    $0x10,%esp
  end_op();
80104009:	e8 ba f0 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
8010400e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104011:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104018:	83 ec 0c             	sub    $0xc,%esp
8010401b:	68 00 42 19 80       	push   $0x80194200
80104020:	e8 29 0a 00 00       	call   80104a4e <acquire>
80104025:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010402b:	8b 40 14             	mov    0x14(%eax),%eax
8010402e:	83 ec 0c             	sub    $0xc,%esp
80104031:	50                   	push   %eax
80104032:	e8 9a 06 00 00       	call   801046d1 <wakeup1>
80104037:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010403a:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104041:	eb 3a                	jmp    8010407d <exit+0xfe>
    if(p->parent == curproc){
80104043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104046:	8b 40 14             	mov    0x14(%eax),%eax
80104049:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010404c:	75 28                	jne    80104076 <exit+0xf7>
      p->parent = initproc;
8010404e:	8b 15 34 6a 19 80    	mov    0x80196a34,%edx
80104054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104057:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010405a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405d:	8b 40 0c             	mov    0xc(%eax),%eax
80104060:	83 f8 05             	cmp    $0x5,%eax
80104063:	75 11                	jne    80104076 <exit+0xf7>
        wakeup1(initproc);
80104065:	a1 34 6a 19 80       	mov    0x80196a34,%eax
8010406a:	83 ec 0c             	sub    $0xc,%esp
8010406d:	50                   	push   %eax
8010406e:	e8 5e 06 00 00       	call   801046d1 <wakeup1>
80104073:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104076:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
8010407d:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80104084:	72 bd                	jb     80104043 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104086:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104089:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104090:	e8 5c 04 00 00       	call   801044f1 <sched>
  panic("zombie exit");
80104095:	83 ec 0c             	sub    $0xc,%esp
80104098:	68 2f a8 10 80       	push   $0x8010a82f
8010409d:	e8 07 c5 ff ff       	call   801005a9 <panic>

801040a2 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801040a2:	55                   	push   %ebp
801040a3:	89 e5                	mov    %esp,%ebp
801040a5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801040a8:	e8 1f fa ff ff       	call   80103acc <myproc>
801040ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801040b0:	83 ec 0c             	sub    $0xc,%esp
801040b3:	68 00 42 19 80       	push   $0x80194200
801040b8:	e8 91 09 00 00       	call   80104a4e <acquire>
801040bd:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801040c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040c7:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801040ce:	e9 a4 00 00 00       	jmp    80104177 <wait+0xd5>
      if(p->parent != curproc)
801040d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d6:	8b 40 14             	mov    0x14(%eax),%eax
801040d9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040dc:	0f 85 8d 00 00 00    	jne    8010416f <wait+0xcd>
        continue;
      havekids = 1;
801040e2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801040e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ec:	8b 40 0c             	mov    0xc(%eax),%eax
801040ef:	83 f8 05             	cmp    $0x5,%eax
801040f2:	75 7c                	jne    80104170 <wait+0xce>
        // Found one.
        pid = p->pid;
801040f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f7:	8b 40 10             	mov    0x10(%eax),%eax
801040fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801040fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104100:	8b 40 08             	mov    0x8(%eax),%eax
80104103:	83 ec 0c             	sub    $0xc,%esp
80104106:	50                   	push   %eax
80104107:	e8 fa e5 ff ff       	call   80102706 <kfree>
8010410c:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010410f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104112:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411c:	8b 40 04             	mov    0x4(%eax),%eax
8010411f:	83 ec 0c             	sub    $0xc,%esp
80104122:	50                   	push   %eax
80104123:	e8 80 3c 00 00       	call   80107da8 <freevm>
80104128:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010412b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104138:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010413f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104142:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104149:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104153:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010415a:	83 ec 0c             	sub    $0xc,%esp
8010415d:	68 00 42 19 80       	push   $0x80194200
80104162:	e8 55 09 00 00       	call   80104abc <release>
80104167:	83 c4 10             	add    $0x10,%esp
        return pid;
8010416a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010416d:	eb 54                	jmp    801041c3 <wait+0x121>
        continue;
8010416f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104170:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104177:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
8010417e:	0f 82 4f ff ff ff    	jb     801040d3 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104184:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104188:	74 0a                	je     80104194 <wait+0xf2>
8010418a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010418d:	8b 40 24             	mov    0x24(%eax),%eax
80104190:	85 c0                	test   %eax,%eax
80104192:	74 17                	je     801041ab <wait+0x109>
      release(&ptable.lock);
80104194:	83 ec 0c             	sub    $0xc,%esp
80104197:	68 00 42 19 80       	push   $0x80194200
8010419c:	e8 1b 09 00 00       	call   80104abc <release>
801041a1:	83 c4 10             	add    $0x10,%esp
      return -1;
801041a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041a9:	eb 18                	jmp    801041c3 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801041ab:	83 ec 08             	sub    $0x8,%esp
801041ae:	68 00 42 19 80       	push   $0x80194200
801041b3:	ff 75 ec             	push   -0x14(%ebp)
801041b6:	e8 6f 04 00 00       	call   8010462a <sleep>
801041bb:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801041be:	e9 fd fe ff ff       	jmp    801040c0 <wait+0x1e>
  }
}
801041c3:	c9                   	leave  
801041c4:	c3                   	ret    

801041c5 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801041c5:	55                   	push   %ebp
801041c6:	89 e5                	mov    %esp,%ebp
801041c8:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801041cb:	e8 84 f8 ff ff       	call   80103a54 <mycpu>
801041d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
801041d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041d6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041dd:	00 00 00 

  for (;;) {
    // Enable interrupts on this processor.
    sti();
801041e0:	e8 93 f7 ff ff       	call   80103978 <sti>
    acquire(&ptable.lock);
801041e5:	83 ec 0c             	sub    $0xc,%esp
801041e8:	68 00 42 19 80       	push   $0x80194200
801041ed:	e8 5c 08 00 00       	call   80104a4e <acquire>
801041f2:	83 c4 10             	add    $0x10,%esp
    int policy = c->sched_policy;
801041f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041f8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801041fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (policy == 0) {
80104201:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104205:	75 7b                	jne    80104282 <scheduler+0xbd>
      // Round-robin
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104207:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010420e:	eb 64                	jmp    80104274 <scheduler+0xaf>
        if (p->state != RUNNABLE)
80104210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104213:	8b 40 0c             	mov    0xc(%eax),%eax
80104216:	83 f8 03             	cmp    $0x3,%eax
80104219:	75 51                	jne    8010426c <scheduler+0xa7>
          continue;

        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        c->proc = p;
8010421b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010421e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104221:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
80104227:	83 ec 0c             	sub    $0xc,%esp
8010422a:	ff 75 f4             	push   -0xc(%ebp)
8010422d:	e8 d1 36 00 00       	call   80107903 <switchuvm>
80104232:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104238:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
8010423f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104242:	8b 40 1c             	mov    0x1c(%eax),%eax
80104245:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104248:	83 c2 04             	add    $0x4,%edx
8010424b:	83 ec 08             	sub    $0x8,%esp
8010424e:	50                   	push   %eax
8010424f:	52                   	push   %edx
80104250:	e8 e4 0c 00 00       	call   80104f39 <swtch>
80104255:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104258:	e8 8d 36 00 00       	call   801078ea <switchkvm>
        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
8010425d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104260:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104267:	00 00 00 
8010426a:	eb 01                	jmp    8010426d <scheduler+0xa8>
          continue;
8010426c:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010426d:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104274:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
8010427b:	72 93                	jb     80104210 <scheduler+0x4b>
8010427d:	e9 5a 02 00 00       	jmp    801044dc <scheduler+0x317>

    } else {
      // MLFQ

      // Boosting 조건 (정책 3번은 boosting X)
      if (policy != 3) {
80104282:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
80104286:	0f 84 ab 00 00 00    	je     80104337 <scheduler+0x172>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010428c:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104293:	e9 92 00 00 00       	jmp    8010432a <scheduler+0x165>
          if (p->state != RUNNABLE)
80104298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429b:	8b 40 0c             	mov    0xc(%eax),%eax
8010429e:	83 f8 03             	cmp    $0x3,%eax
801042a1:	75 7f                	jne    80104322 <scheduler+0x15d>
            continue;

          int prio = p->priority;
801042a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a6:	8b 40 7c             	mov    0x7c(%eax),%eax
801042a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
          if ((prio == 2 && p->wait_ticks[2] >= 160) ||
801042ac:	83 7d e0 02          	cmpl   $0x2,-0x20(%ebp)
801042b0:	75 10                	jne    801042c2 <scheduler+0xfd>
801042b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b5:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801042bb:	3d 9f 00 00 00       	cmp    $0x9f,%eax
801042c0:	7f 2c                	jg     801042ee <scheduler+0x129>
801042c2:	83 7d e0 01          	cmpl   $0x1,-0x20(%ebp)
801042c6:	75 10                	jne    801042d8 <scheduler+0x113>
              (prio == 1 && p->wait_ticks[1] >= 320) ||
801042c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cb:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801042d1:	3d 3f 01 00 00       	cmp    $0x13f,%eax
801042d6:	7f 16                	jg     801042ee <scheduler+0x129>
801042d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801042dc:	75 45                	jne    80104323 <scheduler+0x15e>
              (prio == 0 && p->wait_ticks[0] >= 500)) {
801042de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e1:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801042e7:	3d f3 01 00 00       	cmp    $0x1f3,%eax
801042ec:	7e 35                	jle    80104323 <scheduler+0x15e>
            if (p->priority < 3){
801042ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f1:	8b 40 7c             	mov    0x7c(%eax),%eax
801042f4:	83 f8 02             	cmp    $0x2,%eax
801042f7:	7f 0f                	jg     80104308 <scheduler+0x143>

              p->priority++;
801042f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fc:	8b 40 7c             	mov    0x7c(%eax),%eax
801042ff:	8d 50 01             	lea    0x1(%eax),%edx
80104302:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104305:	89 50 7c             	mov    %edx,0x7c(%eax)
            }  
            memset(p->wait_ticks, 0, sizeof(p->wait_ticks));
80104308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430b:	05 90 00 00 00       	add    $0x90,%eax
80104310:	83 ec 04             	sub    $0x4,%esp
80104313:	6a 10                	push   $0x10
80104315:	6a 00                	push   $0x0
80104317:	50                   	push   %eax
80104318:	e8 a7 09 00 00       	call   80104cc4 <memset>
8010431d:	83 c4 10             	add    $0x10,%esp
80104320:	eb 01                	jmp    80104323 <scheduler+0x15e>
            continue;
80104322:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104323:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
8010432a:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
80104331:	0f 82 61 ff ff ff    	jb     80104298 <scheduler+0xd3>
          }
        }
      }

      int scheduled = 0;
80104337:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      for (int level = 3; level >= 0 && !scheduled; level--) {
8010433e:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
80104345:	e9 82 01 00 00       	jmp    801044cc <scheduler+0x307>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010434a:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104351:	e9 65 01 00 00       	jmp    801044bb <scheduler+0x2f6>
          if (p->state != RUNNABLE || p->priority != level)
80104356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104359:	8b 40 0c             	mov    0xc(%eax),%eax
8010435c:	83 f8 03             	cmp    $0x3,%eax
8010435f:	0f 85 4e 01 00 00    	jne    801044b3 <scheduler+0x2ee>
80104365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104368:	8b 40 7c             	mov    0x7c(%eax),%eax
8010436b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010436e:	0f 85 3f 01 00 00    	jne    801044b3 <scheduler+0x2ee>
            continue;

          c->proc = p;
80104374:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104377:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010437a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
80104380:	83 ec 0c             	sub    $0xc,%esp
80104383:	ff 75 f4             	push   -0xc(%ebp)
80104386:	e8 78 35 00 00       	call   80107903 <switchuvm>
8010438b:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
8010438e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104391:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

          swtch(&(c->scheduler), p->context);
80104398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010439e:	8b 55 e8             	mov    -0x18(%ebp),%edx
801043a1:	83 c2 04             	add    $0x4,%edx
801043a4:	83 ec 08             	sub    $0x8,%esp
801043a7:	50                   	push   %eax
801043a8:	52                   	push   %edx
801043a9:	e8 8b 0b 00 00       	call   80104f39 <swtch>
801043ae:	83 c4 10             	add    $0x10,%esp
          switchkvm();
801043b1:	e8 34 35 00 00       	call   801078ea <switchkvm>
          c->proc = 0;
801043b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043b9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043c0:	00 00 00 

         
          int pr = p->priority;
801043c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c6:	8b 40 7c             	mov    0x7c(%eax),%eax
801043c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
          if (policy == 2) {
801043cc:	83 7d e4 02          	cmpl   $0x2,-0x1c(%ebp)
801043d0:	75 6d                	jne    8010443f <scheduler+0x27a>
            // 강등 조건 + cheat 허용
            if ((pr == 3 && p->ticks[3] >= 8) ||
801043d2:	83 7d dc 03          	cmpl   $0x3,-0x24(%ebp)
801043d6:	75 0e                	jne    801043e6 <scheduler+0x221>
801043d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043db:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801043e1:	83 f8 07             	cmp    $0x7,%eax
801043e4:	7f 28                	jg     8010440e <scheduler+0x249>
801043e6:	83 7d dc 02          	cmpl   $0x2,-0x24(%ebp)
801043ea:	75 0e                	jne    801043fa <scheduler+0x235>
                (pr == 2 && p->ticks[2] >= 16) ||
801043ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ef:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801043f5:	83 f8 0f             	cmp    $0xf,%eax
801043f8:	7f 14                	jg     8010440e <scheduler+0x249>
801043fa:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
801043fe:	75 27                	jne    80104427 <scheduler+0x262>
                (pr == 1 && p->ticks[1] >= 32)) {
80104400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104403:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104409:	83 f8 1f             	cmp    $0x1f,%eax
8010440c:	7e 19                	jle    80104427 <scheduler+0x262>
    
                if (p->priority > 0)
8010440e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104411:	8b 40 7c             	mov    0x7c(%eax),%eax
80104414:	85 c0                	test   %eax,%eax
80104416:	7e 0f                	jle    80104427 <scheduler+0x262>
                    p->priority--; 
80104418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441b:	8b 40 7c             	mov    0x7c(%eax),%eax
8010441e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104424:	89 50 7c             	mov    %edx,0x7c(%eax)
              }
              memset(p->ticks, 0, sizeof(p->ticks));    
80104427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442a:	83 e8 80             	sub    $0xffffff80,%eax
8010442d:	83 ec 04             	sub    $0x4,%esp
80104430:	6a 10                	push   $0x10
80104432:	6a 00                	push   $0x0
80104434:	50                   	push   %eax
80104435:	e8 8a 08 00 00       	call   80104cc4 <memset>
8010443a:	83 c4 10             	add    $0x10,%esp
8010443d:	eb 6b                	jmp    801044aa <scheduler+0x2e5>
          }        
          else {
            // 정책 1, 3은 tick 비교 + 초기화 = cheat 방지
            if ((pr == 3 && p->ticks[3] >= 8) ||
8010443f:	83 7d dc 03          	cmpl   $0x3,-0x24(%ebp)
80104443:	75 0e                	jne    80104453 <scheduler+0x28e>
80104445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104448:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010444e:	83 f8 07             	cmp    $0x7,%eax
80104451:	7f 28                	jg     8010447b <scheduler+0x2b6>
80104453:	83 7d dc 02          	cmpl   $0x2,-0x24(%ebp)
80104457:	75 0e                	jne    80104467 <scheduler+0x2a2>
                (pr == 2 && p->ticks[2] >= 16) ||
80104459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445c:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80104462:	83 f8 0f             	cmp    $0xf,%eax
80104465:	7f 14                	jg     8010447b <scheduler+0x2b6>
80104467:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
8010446b:	75 3d                	jne    801044aa <scheduler+0x2e5>
                (pr == 1 && p->ticks[1] >= 32)) {
8010446d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104470:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104476:	83 f8 1f             	cmp    $0x1f,%eax
80104479:	7e 2f                	jle    801044aa <scheduler+0x2e5>
              if (p->priority > 0)
8010447b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447e:	8b 40 7c             	mov    0x7c(%eax),%eax
80104481:	85 c0                	test   %eax,%eax
80104483:	7e 0f                	jle    80104494 <scheduler+0x2cf>
                p->priority--;
80104485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104488:	8b 40 7c             	mov    0x7c(%eax),%eax
8010448b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010448e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104491:	89 50 7c             	mov    %edx,0x7c(%eax)
              memset(p->ticks, 0, sizeof(p->ticks));
80104494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104497:	83 e8 80             	sub    $0xffffff80,%eax
8010449a:	83 ec 04             	sub    $0x4,%esp
8010449d:	6a 10                	push   $0x10
8010449f:	6a 00                	push   $0x0
801044a1:	50                   	push   %eax
801044a2:	e8 1d 08 00 00       	call   80104cc4 <memset>
801044a7:	83 c4 10             	add    $0x10,%esp
            }
          }
        
          scheduled = 1;
801044aa:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
          break;
801044b1:	eb 15                	jmp    801044c8 <scheduler+0x303>
            continue;
801044b3:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801044b4:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801044bb:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
801044c2:	0f 82 8e fe ff ff    	jb     80104356 <scheduler+0x191>
      for (int level = 3; level >= 0 && !scheduled; level--) {
801044c8:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
801044cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801044d0:	78 0a                	js     801044dc <scheduler+0x317>
801044d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801044d6:	0f 84 6e fe ff ff    	je     8010434a <scheduler+0x185>
        }
      }
    }

    release(&ptable.lock);
801044dc:	83 ec 0c             	sub    $0xc,%esp
801044df:	68 00 42 19 80       	push   $0x80194200
801044e4:	e8 d3 05 00 00       	call   80104abc <release>
801044e9:	83 c4 10             	add    $0x10,%esp
  for (;;) {
801044ec:	e9 ef fc ff ff       	jmp    801041e0 <scheduler+0x1b>

801044f1 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801044f1:	55                   	push   %ebp
801044f2:	89 e5                	mov    %esp,%ebp
801044f4:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801044f7:	e8 d0 f5 ff ff       	call   80103acc <myproc>
801044fc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801044ff:	83 ec 0c             	sub    $0xc,%esp
80104502:	68 00 42 19 80       	push   $0x80194200
80104507:	e8 7d 06 00 00       	call   80104b89 <holding>
8010450c:	83 c4 10             	add    $0x10,%esp
8010450f:	85 c0                	test   %eax,%eax
80104511:	75 0d                	jne    80104520 <sched+0x2f>
    panic("sched ptable.lock");
80104513:	83 ec 0c             	sub    $0xc,%esp
80104516:	68 3b a8 10 80       	push   $0x8010a83b
8010451b:	e8 89 c0 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104520:	e8 2f f5 ff ff       	call   80103a54 <mycpu>
80104525:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010452b:	83 f8 01             	cmp    $0x1,%eax
8010452e:	74 0d                	je     8010453d <sched+0x4c>
    panic("sched locks");
80104530:	83 ec 0c             	sub    $0xc,%esp
80104533:	68 4d a8 10 80       	push   $0x8010a84d
80104538:	e8 6c c0 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
8010453d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104540:	8b 40 0c             	mov    0xc(%eax),%eax
80104543:	83 f8 04             	cmp    $0x4,%eax
80104546:	75 0d                	jne    80104555 <sched+0x64>
    panic("sched running");
80104548:	83 ec 0c             	sub    $0xc,%esp
8010454b:	68 59 a8 10 80       	push   $0x8010a859
80104550:	e8 54 c0 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104555:	e8 0e f4 ff ff       	call   80103968 <readeflags>
8010455a:	25 00 02 00 00       	and    $0x200,%eax
8010455f:	85 c0                	test   %eax,%eax
80104561:	74 0d                	je     80104570 <sched+0x7f>
    panic("sched interruptible");
80104563:	83 ec 0c             	sub    $0xc,%esp
80104566:	68 67 a8 10 80       	push   $0x8010a867
8010456b:	e8 39 c0 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104570:	e8 df f4 ff ff       	call   80103a54 <mycpu>
80104575:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010457b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010457e:	e8 d1 f4 ff ff       	call   80103a54 <mycpu>
80104583:	8b 40 04             	mov    0x4(%eax),%eax
80104586:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104589:	83 c2 1c             	add    $0x1c,%edx
8010458c:	83 ec 08             	sub    $0x8,%esp
8010458f:	50                   	push   %eax
80104590:	52                   	push   %edx
80104591:	e8 a3 09 00 00       	call   80104f39 <swtch>
80104596:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104599:	e8 b6 f4 ff ff       	call   80103a54 <mycpu>
8010459e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045a1:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801045a7:	90                   	nop
801045a8:	c9                   	leave  
801045a9:	c3                   	ret    

801045aa <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801045aa:	55                   	push   %ebp
801045ab:	89 e5                	mov    %esp,%ebp
801045ad:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801045b0:	83 ec 0c             	sub    $0xc,%esp
801045b3:	68 00 42 19 80       	push   $0x80194200
801045b8:	e8 91 04 00 00       	call   80104a4e <acquire>
801045bd:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801045c0:	e8 07 f5 ff ff       	call   80103acc <myproc>
801045c5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801045cc:	e8 20 ff ff ff       	call   801044f1 <sched>
  release(&ptable.lock);
801045d1:	83 ec 0c             	sub    $0xc,%esp
801045d4:	68 00 42 19 80       	push   $0x80194200
801045d9:	e8 de 04 00 00       	call   80104abc <release>
801045de:	83 c4 10             	add    $0x10,%esp
}
801045e1:	90                   	nop
801045e2:	c9                   	leave  
801045e3:	c3                   	ret    

801045e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801045e4:	55                   	push   %ebp
801045e5:	89 e5                	mov    %esp,%ebp
801045e7:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801045ea:	83 ec 0c             	sub    $0xc,%esp
801045ed:	68 00 42 19 80       	push   $0x80194200
801045f2:	e8 c5 04 00 00       	call   80104abc <release>
801045f7:	83 c4 10             	add    $0x10,%esp

  if (first) {
801045fa:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801045ff:	85 c0                	test   %eax,%eax
80104601:	74 24                	je     80104627 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104603:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010460a:	00 00 00 
    iinit(ROOTDEV);
8010460d:	83 ec 0c             	sub    $0xc,%esp
80104610:	6a 01                	push   $0x1
80104612:	e8 61 d0 ff ff       	call   80101678 <iinit>
80104617:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010461a:	83 ec 0c             	sub    $0xc,%esp
8010461d:	6a 01                	push   $0x1
8010461f:	e8 f9 e7 ff ff       	call   80102e1d <initlog>
80104624:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104627:	90                   	nop
80104628:	c9                   	leave  
80104629:	c3                   	ret    

8010462a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010462a:	55                   	push   %ebp
8010462b:	89 e5                	mov    %esp,%ebp
8010462d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104630:	e8 97 f4 ff ff       	call   80103acc <myproc>
80104635:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104638:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010463c:	75 0d                	jne    8010464b <sleep+0x21>
    panic("sleep");
8010463e:	83 ec 0c             	sub    $0xc,%esp
80104641:	68 7b a8 10 80       	push   $0x8010a87b
80104646:	e8 5e bf ff ff       	call   801005a9 <panic>

  if(lk == 0)
8010464b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010464f:	75 0d                	jne    8010465e <sleep+0x34>
    panic("sleep without lk");
80104651:	83 ec 0c             	sub    $0xc,%esp
80104654:	68 81 a8 10 80       	push   $0x8010a881
80104659:	e8 4b bf ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010465e:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104665:	74 1e                	je     80104685 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104667:	83 ec 0c             	sub    $0xc,%esp
8010466a:	68 00 42 19 80       	push   $0x80194200
8010466f:	e8 da 03 00 00       	call   80104a4e <acquire>
80104674:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104677:	83 ec 0c             	sub    $0xc,%esp
8010467a:	ff 75 0c             	push   0xc(%ebp)
8010467d:	e8 3a 04 00 00       	call   80104abc <release>
80104682:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104688:	8b 55 08             	mov    0x8(%ebp),%edx
8010468b:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010468e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104691:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104698:	e8 54 fe ff ff       	call   801044f1 <sched>

  // Tidy up.
  p->chan = 0;
8010469d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a0:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801046a7:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801046ae:	74 1e                	je     801046ce <sleep+0xa4>
    release(&ptable.lock);
801046b0:	83 ec 0c             	sub    $0xc,%esp
801046b3:	68 00 42 19 80       	push   $0x80194200
801046b8:	e8 ff 03 00 00       	call   80104abc <release>
801046bd:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801046c0:	83 ec 0c             	sub    $0xc,%esp
801046c3:	ff 75 0c             	push   0xc(%ebp)
801046c6:	e8 83 03 00 00       	call   80104a4e <acquire>
801046cb:	83 c4 10             	add    $0x10,%esp
  }
}
801046ce:	90                   	nop
801046cf:	c9                   	leave  
801046d0:	c3                   	ret    

801046d1 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801046d1:	55                   	push   %ebp
801046d2:	89 e5                	mov    %esp,%ebp
801046d4:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801046d7:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
801046de:	eb 27                	jmp    80104707 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801046e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801046e3:	8b 40 0c             	mov    0xc(%eax),%eax
801046e6:	83 f8 02             	cmp    $0x2,%eax
801046e9:	75 15                	jne    80104700 <wakeup1+0x2f>
801046eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801046ee:	8b 40 20             	mov    0x20(%eax),%eax
801046f1:	39 45 08             	cmp    %eax,0x8(%ebp)
801046f4:	75 0a                	jne    80104700 <wakeup1+0x2f>
      p->state = RUNNABLE;
801046f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801046f9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104700:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
80104707:	81 7d fc 34 6a 19 80 	cmpl   $0x80196a34,-0x4(%ebp)
8010470e:	72 d0                	jb     801046e0 <wakeup1+0xf>
}
80104710:	90                   	nop
80104711:	90                   	nop
80104712:	c9                   	leave  
80104713:	c3                   	ret    

80104714 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104714:	55                   	push   %ebp
80104715:	89 e5                	mov    %esp,%ebp
80104717:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010471a:	83 ec 0c             	sub    $0xc,%esp
8010471d:	68 00 42 19 80       	push   $0x80194200
80104722:	e8 27 03 00 00       	call   80104a4e <acquire>
80104727:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010472a:	83 ec 0c             	sub    $0xc,%esp
8010472d:	ff 75 08             	push   0x8(%ebp)
80104730:	e8 9c ff ff ff       	call   801046d1 <wakeup1>
80104735:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104738:	83 ec 0c             	sub    $0xc,%esp
8010473b:	68 00 42 19 80       	push   $0x80194200
80104740:	e8 77 03 00 00       	call   80104abc <release>
80104745:	83 c4 10             	add    $0x10,%esp
}
80104748:	90                   	nop
80104749:	c9                   	leave  
8010474a:	c3                   	ret    

8010474b <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010474b:	55                   	push   %ebp
8010474c:	89 e5                	mov    %esp,%ebp
8010474e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104751:	83 ec 0c             	sub    $0xc,%esp
80104754:	68 00 42 19 80       	push   $0x80194200
80104759:	e8 f0 02 00 00       	call   80104a4e <acquire>
8010475e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104761:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104768:	eb 48                	jmp    801047b2 <kill+0x67>
    if(p->pid == pid){
8010476a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476d:	8b 40 10             	mov    0x10(%eax),%eax
80104770:	39 45 08             	cmp    %eax,0x8(%ebp)
80104773:	75 36                	jne    801047ab <kill+0x60>
      p->killed = 1;
80104775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104778:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010477f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104782:	8b 40 0c             	mov    0xc(%eax),%eax
80104785:	83 f8 02             	cmp    $0x2,%eax
80104788:	75 0a                	jne    80104794 <kill+0x49>
        p->state = RUNNABLE;
8010478a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104794:	83 ec 0c             	sub    $0xc,%esp
80104797:	68 00 42 19 80       	push   $0x80194200
8010479c:	e8 1b 03 00 00       	call   80104abc <release>
801047a1:	83 c4 10             	add    $0x10,%esp
      return 0;
801047a4:	b8 00 00 00 00       	mov    $0x0,%eax
801047a9:	eb 25                	jmp    801047d0 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ab:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801047b2:	81 7d f4 34 6a 19 80 	cmpl   $0x80196a34,-0xc(%ebp)
801047b9:	72 af                	jb     8010476a <kill+0x1f>
    }
  }
  release(&ptable.lock);
801047bb:	83 ec 0c             	sub    $0xc,%esp
801047be:	68 00 42 19 80       	push   $0x80194200
801047c3:	e8 f4 02 00 00       	call   80104abc <release>
801047c8:	83 c4 10             	add    $0x10,%esp
  return -1;
801047cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801047d0:	c9                   	leave  
801047d1:	c3                   	ret    

801047d2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801047d2:	55                   	push   %ebp
801047d3:	89 e5                	mov    %esp,%ebp
801047d5:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047d8:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
801047df:	e9 da 00 00 00       	jmp    801048be <procdump+0xec>
    if(p->state == UNUSED)
801047e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e7:	8b 40 0c             	mov    0xc(%eax),%eax
801047ea:	85 c0                	test   %eax,%eax
801047ec:	0f 84 c4 00 00 00    	je     801048b6 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801047f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047f5:	8b 40 0c             	mov    0xc(%eax),%eax
801047f8:	83 f8 05             	cmp    $0x5,%eax
801047fb:	77 23                	ja     80104820 <procdump+0x4e>
801047fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104800:	8b 40 0c             	mov    0xc(%eax),%eax
80104803:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010480a:	85 c0                	test   %eax,%eax
8010480c:	74 12                	je     80104820 <procdump+0x4e>
      state = states[p->state];
8010480e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104811:	8b 40 0c             	mov    0xc(%eax),%eax
80104814:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010481b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010481e:	eb 07                	jmp    80104827 <procdump+0x55>
    else
      state = "???";
80104820:	c7 45 ec 92 a8 10 80 	movl   $0x8010a892,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104827:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010482a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010482d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104830:	8b 40 10             	mov    0x10(%eax),%eax
80104833:	52                   	push   %edx
80104834:	ff 75 ec             	push   -0x14(%ebp)
80104837:	50                   	push   %eax
80104838:	68 96 a8 10 80       	push   $0x8010a896
8010483d:	e8 b2 bb ff ff       	call   801003f4 <cprintf>
80104842:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104845:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104848:	8b 40 0c             	mov    0xc(%eax),%eax
8010484b:	83 f8 02             	cmp    $0x2,%eax
8010484e:	75 54                	jne    801048a4 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104850:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104853:	8b 40 1c             	mov    0x1c(%eax),%eax
80104856:	8b 40 0c             	mov    0xc(%eax),%eax
80104859:	83 c0 08             	add    $0x8,%eax
8010485c:	89 c2                	mov    %eax,%edx
8010485e:	83 ec 08             	sub    $0x8,%esp
80104861:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104864:	50                   	push   %eax
80104865:	52                   	push   %edx
80104866:	e8 a3 02 00 00       	call   80104b0e <getcallerpcs>
8010486b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010486e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104875:	eb 1c                	jmp    80104893 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010487e:	83 ec 08             	sub    $0x8,%esp
80104881:	50                   	push   %eax
80104882:	68 9f a8 10 80       	push   $0x8010a89f
80104887:	e8 68 bb ff ff       	call   801003f4 <cprintf>
8010488c:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010488f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104893:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104897:	7f 0b                	jg     801048a4 <procdump+0xd2>
80104899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801048a0:	85 c0                	test   %eax,%eax
801048a2:	75 d3                	jne    80104877 <procdump+0xa5>
    }
    cprintf("\n");
801048a4:	83 ec 0c             	sub    $0xc,%esp
801048a7:	68 a3 a8 10 80       	push   $0x8010a8a3
801048ac:	e8 43 bb ff ff       	call   801003f4 <cprintf>
801048b1:	83 c4 10             	add    $0x10,%esp
801048b4:	eb 01                	jmp    801048b7 <procdump+0xe5>
      continue;
801048b6:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048b7:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
801048be:	81 7d f0 34 6a 19 80 	cmpl   $0x80196a34,-0x10(%ebp)
801048c5:	0f 82 19 ff ff ff    	jb     801047e4 <procdump+0x12>
  }
}
801048cb:	90                   	nop
801048cc:	90                   	nop
801048cd:	c9                   	leave  
801048ce:	c3                   	ret    

801048cf <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801048cf:	55                   	push   %ebp
801048d0:	89 e5                	mov    %esp,%ebp
801048d2:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801048d5:	8b 45 08             	mov    0x8(%ebp),%eax
801048d8:	83 c0 04             	add    $0x4,%eax
801048db:	83 ec 08             	sub    $0x8,%esp
801048de:	68 cf a8 10 80       	push   $0x8010a8cf
801048e3:	50                   	push   %eax
801048e4:	e8 43 01 00 00       	call   80104a2c <initlock>
801048e9:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801048ec:	8b 45 08             	mov    0x8(%ebp),%eax
801048ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801048f2:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801048f5:	8b 45 08             	mov    0x8(%ebp),%eax
801048f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801048fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104901:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104908:	90                   	nop
80104909:	c9                   	leave  
8010490a:	c3                   	ret    

8010490b <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010490b:	55                   	push   %ebp
8010490c:	89 e5                	mov    %esp,%ebp
8010490e:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104911:	8b 45 08             	mov    0x8(%ebp),%eax
80104914:	83 c0 04             	add    $0x4,%eax
80104917:	83 ec 0c             	sub    $0xc,%esp
8010491a:	50                   	push   %eax
8010491b:	e8 2e 01 00 00       	call   80104a4e <acquire>
80104920:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104923:	eb 15                	jmp    8010493a <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104925:	8b 45 08             	mov    0x8(%ebp),%eax
80104928:	83 c0 04             	add    $0x4,%eax
8010492b:	83 ec 08             	sub    $0x8,%esp
8010492e:	50                   	push   %eax
8010492f:	ff 75 08             	push   0x8(%ebp)
80104932:	e8 f3 fc ff ff       	call   8010462a <sleep>
80104937:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010493a:	8b 45 08             	mov    0x8(%ebp),%eax
8010493d:	8b 00                	mov    (%eax),%eax
8010493f:	85 c0                	test   %eax,%eax
80104941:	75 e2                	jne    80104925 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104943:	8b 45 08             	mov    0x8(%ebp),%eax
80104946:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010494c:	e8 7b f1 ff ff       	call   80103acc <myproc>
80104951:	8b 50 10             	mov    0x10(%eax),%edx
80104954:	8b 45 08             	mov    0x8(%ebp),%eax
80104957:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010495a:	8b 45 08             	mov    0x8(%ebp),%eax
8010495d:	83 c0 04             	add    $0x4,%eax
80104960:	83 ec 0c             	sub    $0xc,%esp
80104963:	50                   	push   %eax
80104964:	e8 53 01 00 00       	call   80104abc <release>
80104969:	83 c4 10             	add    $0x10,%esp
}
8010496c:	90                   	nop
8010496d:	c9                   	leave  
8010496e:	c3                   	ret    

8010496f <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010496f:	55                   	push   %ebp
80104970:	89 e5                	mov    %esp,%ebp
80104972:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104975:	8b 45 08             	mov    0x8(%ebp),%eax
80104978:	83 c0 04             	add    $0x4,%eax
8010497b:	83 ec 0c             	sub    $0xc,%esp
8010497e:	50                   	push   %eax
8010497f:	e8 ca 00 00 00       	call   80104a4e <acquire>
80104984:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104987:	8b 45 08             	mov    0x8(%ebp),%eax
8010498a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104990:	8b 45 08             	mov    0x8(%ebp),%eax
80104993:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010499a:	83 ec 0c             	sub    $0xc,%esp
8010499d:	ff 75 08             	push   0x8(%ebp)
801049a0:	e8 6f fd ff ff       	call   80104714 <wakeup>
801049a5:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801049a8:	8b 45 08             	mov    0x8(%ebp),%eax
801049ab:	83 c0 04             	add    $0x4,%eax
801049ae:	83 ec 0c             	sub    $0xc,%esp
801049b1:	50                   	push   %eax
801049b2:	e8 05 01 00 00       	call   80104abc <release>
801049b7:	83 c4 10             	add    $0x10,%esp
}
801049ba:	90                   	nop
801049bb:	c9                   	leave  
801049bc:	c3                   	ret    

801049bd <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801049bd:	55                   	push   %ebp
801049be:	89 e5                	mov    %esp,%ebp
801049c0:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801049c3:	8b 45 08             	mov    0x8(%ebp),%eax
801049c6:	83 c0 04             	add    $0x4,%eax
801049c9:	83 ec 0c             	sub    $0xc,%esp
801049cc:	50                   	push   %eax
801049cd:	e8 7c 00 00 00       	call   80104a4e <acquire>
801049d2:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801049d5:	8b 45 08             	mov    0x8(%ebp),%eax
801049d8:	8b 00                	mov    (%eax),%eax
801049da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801049dd:	8b 45 08             	mov    0x8(%ebp),%eax
801049e0:	83 c0 04             	add    $0x4,%eax
801049e3:	83 ec 0c             	sub    $0xc,%esp
801049e6:	50                   	push   %eax
801049e7:	e8 d0 00 00 00       	call   80104abc <release>
801049ec:	83 c4 10             	add    $0x10,%esp
  return r;
801049ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801049f2:	c9                   	leave  
801049f3:	c3                   	ret    

801049f4 <readeflags>:
{
801049f4:	55                   	push   %ebp
801049f5:	89 e5                	mov    %esp,%ebp
801049f7:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801049fa:	9c                   	pushf  
801049fb:	58                   	pop    %eax
801049fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801049ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a02:	c9                   	leave  
80104a03:	c3                   	ret    

80104a04 <cli>:
{
80104a04:	55                   	push   %ebp
80104a05:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104a07:	fa                   	cli    
}
80104a08:	90                   	nop
80104a09:	5d                   	pop    %ebp
80104a0a:	c3                   	ret    

80104a0b <sti>:
{
80104a0b:	55                   	push   %ebp
80104a0c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104a0e:	fb                   	sti    
}
80104a0f:	90                   	nop
80104a10:	5d                   	pop    %ebp
80104a11:	c3                   	ret    

80104a12 <xchg>:
{
80104a12:	55                   	push   %ebp
80104a13:	89 e5                	mov    %esp,%ebp
80104a15:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104a18:	8b 55 08             	mov    0x8(%ebp),%edx
80104a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a21:	f0 87 02             	lock xchg %eax,(%edx)
80104a24:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104a27:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a2a:	c9                   	leave  
80104a2b:	c3                   	ret    

80104a2c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104a2c:	55                   	push   %ebp
80104a2d:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a32:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a35:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104a38:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104a41:	8b 45 08             	mov    0x8(%ebp),%eax
80104a44:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104a4b:	90                   	nop
80104a4c:	5d                   	pop    %ebp
80104a4d:	c3                   	ret    

80104a4e <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104a4e:	55                   	push   %ebp
80104a4f:	89 e5                	mov    %esp,%ebp
80104a51:	53                   	push   %ebx
80104a52:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104a55:	e8 5f 01 00 00       	call   80104bb9 <pushcli>
  if(holding(lk)){
80104a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5d:	83 ec 0c             	sub    $0xc,%esp
80104a60:	50                   	push   %eax
80104a61:	e8 23 01 00 00       	call   80104b89 <holding>
80104a66:	83 c4 10             	add    $0x10,%esp
80104a69:	85 c0                	test   %eax,%eax
80104a6b:	74 0d                	je     80104a7a <acquire+0x2c>
    panic("acquire");
80104a6d:	83 ec 0c             	sub    $0xc,%esp
80104a70:	68 da a8 10 80       	push   $0x8010a8da
80104a75:	e8 2f bb ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104a7a:	90                   	nop
80104a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7e:	83 ec 08             	sub    $0x8,%esp
80104a81:	6a 01                	push   $0x1
80104a83:	50                   	push   %eax
80104a84:	e8 89 ff ff ff       	call   80104a12 <xchg>
80104a89:	83 c4 10             	add    $0x10,%esp
80104a8c:	85 c0                	test   %eax,%eax
80104a8e:	75 eb                	jne    80104a7b <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104a90:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104a95:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104a98:	e8 b7 ef ff ff       	call   80103a54 <mycpu>
80104a9d:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa3:	83 c0 0c             	add    $0xc,%eax
80104aa6:	83 ec 08             	sub    $0x8,%esp
80104aa9:	50                   	push   %eax
80104aaa:	8d 45 08             	lea    0x8(%ebp),%eax
80104aad:	50                   	push   %eax
80104aae:	e8 5b 00 00 00       	call   80104b0e <getcallerpcs>
80104ab3:	83 c4 10             	add    $0x10,%esp
}
80104ab6:	90                   	nop
80104ab7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104aba:	c9                   	leave  
80104abb:	c3                   	ret    

80104abc <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104abc:	55                   	push   %ebp
80104abd:	89 e5                	mov    %esp,%ebp
80104abf:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104ac2:	83 ec 0c             	sub    $0xc,%esp
80104ac5:	ff 75 08             	push   0x8(%ebp)
80104ac8:	e8 bc 00 00 00       	call   80104b89 <holding>
80104acd:	83 c4 10             	add    $0x10,%esp
80104ad0:	85 c0                	test   %eax,%eax
80104ad2:	75 0d                	jne    80104ae1 <release+0x25>
    panic("release");
80104ad4:	83 ec 0c             	sub    $0xc,%esp
80104ad7:	68 e2 a8 10 80       	push   $0x8010a8e2
80104adc:	e8 c8 ba ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80104aee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104af5:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104afa:	8b 45 08             	mov    0x8(%ebp),%eax
80104afd:	8b 55 08             	mov    0x8(%ebp),%edx
80104b00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104b06:	e8 fb 00 00 00       	call   80104c06 <popcli>
}
80104b0b:	90                   	nop
80104b0c:	c9                   	leave  
80104b0d:	c3                   	ret    

80104b0e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104b0e:	55                   	push   %ebp
80104b0f:	89 e5                	mov    %esp,%ebp
80104b11:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104b14:	8b 45 08             	mov    0x8(%ebp),%eax
80104b17:	83 e8 08             	sub    $0x8,%eax
80104b1a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b1d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104b24:	eb 38                	jmp    80104b5e <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104b26:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104b2a:	74 53                	je     80104b7f <getcallerpcs+0x71>
80104b2c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104b33:	76 4a                	jbe    80104b7f <getcallerpcs+0x71>
80104b35:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104b39:	74 44                	je     80104b7f <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104b3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b3e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b45:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b48:	01 c2                	add    %eax,%edx
80104b4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b4d:	8b 40 04             	mov    0x4(%eax),%eax
80104b50:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104b52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b55:	8b 00                	mov    (%eax),%eax
80104b57:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b5a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104b5e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104b62:	7e c2                	jle    80104b26 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104b64:	eb 19                	jmp    80104b7f <getcallerpcs+0x71>
    pcs[i] = 0;
80104b66:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b73:	01 d0                	add    %edx,%eax
80104b75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104b7b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104b7f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104b83:	7e e1                	jle    80104b66 <getcallerpcs+0x58>
}
80104b85:	90                   	nop
80104b86:	90                   	nop
80104b87:	c9                   	leave  
80104b88:	c3                   	ret    

80104b89 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104b89:	55                   	push   %ebp
80104b8a:	89 e5                	mov    %esp,%ebp
80104b8c:	53                   	push   %ebx
80104b8d:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104b90:	8b 45 08             	mov    0x8(%ebp),%eax
80104b93:	8b 00                	mov    (%eax),%eax
80104b95:	85 c0                	test   %eax,%eax
80104b97:	74 16                	je     80104baf <holding+0x26>
80104b99:	8b 45 08             	mov    0x8(%ebp),%eax
80104b9c:	8b 58 08             	mov    0x8(%eax),%ebx
80104b9f:	e8 b0 ee ff ff       	call   80103a54 <mycpu>
80104ba4:	39 c3                	cmp    %eax,%ebx
80104ba6:	75 07                	jne    80104baf <holding+0x26>
80104ba8:	b8 01 00 00 00       	mov    $0x1,%eax
80104bad:	eb 05                	jmp    80104bb4 <holding+0x2b>
80104baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bb7:	c9                   	leave  
80104bb8:	c3                   	ret    

80104bb9 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104bb9:	55                   	push   %ebp
80104bba:	89 e5                	mov    %esp,%ebp
80104bbc:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104bbf:	e8 30 fe ff ff       	call   801049f4 <readeflags>
80104bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104bc7:	e8 38 fe ff ff       	call   80104a04 <cli>
  if(mycpu()->ncli == 0)
80104bcc:	e8 83 ee ff ff       	call   80103a54 <mycpu>
80104bd1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104bd7:	85 c0                	test   %eax,%eax
80104bd9:	75 14                	jne    80104bef <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104bdb:	e8 74 ee ff ff       	call   80103a54 <mycpu>
80104be0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104be3:	81 e2 00 02 00 00    	and    $0x200,%edx
80104be9:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104bef:	e8 60 ee ff ff       	call   80103a54 <mycpu>
80104bf4:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104bfa:	83 c2 01             	add    $0x1,%edx
80104bfd:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104c03:	90                   	nop
80104c04:	c9                   	leave  
80104c05:	c3                   	ret    

80104c06 <popcli>:

void
popcli(void)
{
80104c06:	55                   	push   %ebp
80104c07:	89 e5                	mov    %esp,%ebp
80104c09:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104c0c:	e8 e3 fd ff ff       	call   801049f4 <readeflags>
80104c11:	25 00 02 00 00       	and    $0x200,%eax
80104c16:	85 c0                	test   %eax,%eax
80104c18:	74 0d                	je     80104c27 <popcli+0x21>
    panic("popcli - interruptible");
80104c1a:	83 ec 0c             	sub    $0xc,%esp
80104c1d:	68 ea a8 10 80       	push   $0x8010a8ea
80104c22:	e8 82 b9 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104c27:	e8 28 ee ff ff       	call   80103a54 <mycpu>
80104c2c:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c32:	83 ea 01             	sub    $0x1,%edx
80104c35:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104c3b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c41:	85 c0                	test   %eax,%eax
80104c43:	79 0d                	jns    80104c52 <popcli+0x4c>
    panic("popcli");
80104c45:	83 ec 0c             	sub    $0xc,%esp
80104c48:	68 01 a9 10 80       	push   $0x8010a901
80104c4d:	e8 57 b9 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104c52:	e8 fd ed ff ff       	call   80103a54 <mycpu>
80104c57:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c5d:	85 c0                	test   %eax,%eax
80104c5f:	75 14                	jne    80104c75 <popcli+0x6f>
80104c61:	e8 ee ed ff ff       	call   80103a54 <mycpu>
80104c66:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104c6c:	85 c0                	test   %eax,%eax
80104c6e:	74 05                	je     80104c75 <popcli+0x6f>
    sti();
80104c70:	e8 96 fd ff ff       	call   80104a0b <sti>
}
80104c75:	90                   	nop
80104c76:	c9                   	leave  
80104c77:	c3                   	ret    

80104c78 <stosb>:
{
80104c78:	55                   	push   %ebp
80104c79:	89 e5                	mov    %esp,%ebp
80104c7b:	57                   	push   %edi
80104c7c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104c7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104c80:	8b 55 10             	mov    0x10(%ebp),%edx
80104c83:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c86:	89 cb                	mov    %ecx,%ebx
80104c88:	89 df                	mov    %ebx,%edi
80104c8a:	89 d1                	mov    %edx,%ecx
80104c8c:	fc                   	cld    
80104c8d:	f3 aa                	rep stos %al,%es:(%edi)
80104c8f:	89 ca                	mov    %ecx,%edx
80104c91:	89 fb                	mov    %edi,%ebx
80104c93:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104c96:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104c99:	90                   	nop
80104c9a:	5b                   	pop    %ebx
80104c9b:	5f                   	pop    %edi
80104c9c:	5d                   	pop    %ebp
80104c9d:	c3                   	ret    

80104c9e <stosl>:
{
80104c9e:	55                   	push   %ebp
80104c9f:	89 e5                	mov    %esp,%ebp
80104ca1:	57                   	push   %edi
80104ca2:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ca6:	8b 55 10             	mov    0x10(%ebp),%edx
80104ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cac:	89 cb                	mov    %ecx,%ebx
80104cae:	89 df                	mov    %ebx,%edi
80104cb0:	89 d1                	mov    %edx,%ecx
80104cb2:	fc                   	cld    
80104cb3:	f3 ab                	rep stos %eax,%es:(%edi)
80104cb5:	89 ca                	mov    %ecx,%edx
80104cb7:	89 fb                	mov    %edi,%ebx
80104cb9:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104cbc:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104cbf:	90                   	nop
80104cc0:	5b                   	pop    %ebx
80104cc1:	5f                   	pop    %edi
80104cc2:	5d                   	pop    %ebp
80104cc3:	c3                   	ret    

80104cc4 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104cc4:	55                   	push   %ebp
80104cc5:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cca:	83 e0 03             	and    $0x3,%eax
80104ccd:	85 c0                	test   %eax,%eax
80104ccf:	75 43                	jne    80104d14 <memset+0x50>
80104cd1:	8b 45 10             	mov    0x10(%ebp),%eax
80104cd4:	83 e0 03             	and    $0x3,%eax
80104cd7:	85 c0                	test   %eax,%eax
80104cd9:	75 39                	jne    80104d14 <memset+0x50>
    c &= 0xFF;
80104cdb:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104ce2:	8b 45 10             	mov    0x10(%ebp),%eax
80104ce5:	c1 e8 02             	shr    $0x2,%eax
80104ce8:	89 c2                	mov    %eax,%edx
80104cea:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ced:	c1 e0 18             	shl    $0x18,%eax
80104cf0:	89 c1                	mov    %eax,%ecx
80104cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cf5:	c1 e0 10             	shl    $0x10,%eax
80104cf8:	09 c1                	or     %eax,%ecx
80104cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cfd:	c1 e0 08             	shl    $0x8,%eax
80104d00:	09 c8                	or     %ecx,%eax
80104d02:	0b 45 0c             	or     0xc(%ebp),%eax
80104d05:	52                   	push   %edx
80104d06:	50                   	push   %eax
80104d07:	ff 75 08             	push   0x8(%ebp)
80104d0a:	e8 8f ff ff ff       	call   80104c9e <stosl>
80104d0f:	83 c4 0c             	add    $0xc,%esp
80104d12:	eb 12                	jmp    80104d26 <memset+0x62>
  } else
    stosb(dst, c, n);
80104d14:	8b 45 10             	mov    0x10(%ebp),%eax
80104d17:	50                   	push   %eax
80104d18:	ff 75 0c             	push   0xc(%ebp)
80104d1b:	ff 75 08             	push   0x8(%ebp)
80104d1e:	e8 55 ff ff ff       	call   80104c78 <stosb>
80104d23:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104d26:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104d29:	c9                   	leave  
80104d2a:	c3                   	ret    

80104d2b <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104d2b:	55                   	push   %ebp
80104d2c:	89 e5                	mov    %esp,%ebp
80104d2e:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104d31:	8b 45 08             	mov    0x8(%ebp),%eax
80104d34:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104d37:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d3a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104d3d:	eb 30                	jmp    80104d6f <memcmp+0x44>
    if(*s1 != *s2)
80104d3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d42:	0f b6 10             	movzbl (%eax),%edx
80104d45:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d48:	0f b6 00             	movzbl (%eax),%eax
80104d4b:	38 c2                	cmp    %al,%dl
80104d4d:	74 18                	je     80104d67 <memcmp+0x3c>
      return *s1 - *s2;
80104d4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d52:	0f b6 00             	movzbl (%eax),%eax
80104d55:	0f b6 d0             	movzbl %al,%edx
80104d58:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d5b:	0f b6 00             	movzbl (%eax),%eax
80104d5e:	0f b6 c8             	movzbl %al,%ecx
80104d61:	89 d0                	mov    %edx,%eax
80104d63:	29 c8                	sub    %ecx,%eax
80104d65:	eb 1a                	jmp    80104d81 <memcmp+0x56>
    s1++, s2++;
80104d67:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d6b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104d6f:	8b 45 10             	mov    0x10(%ebp),%eax
80104d72:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d75:	89 55 10             	mov    %edx,0x10(%ebp)
80104d78:	85 c0                	test   %eax,%eax
80104d7a:	75 c3                	jne    80104d3f <memcmp+0x14>
  }

  return 0;
80104d7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d81:	c9                   	leave  
80104d82:	c3                   	ret    

80104d83 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104d83:	55                   	push   %ebp
80104d84:	89 e5                	mov    %esp,%ebp
80104d86:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104d8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d92:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104d95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d98:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104d9b:	73 54                	jae    80104df1 <memmove+0x6e>
80104d9d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104da0:	8b 45 10             	mov    0x10(%ebp),%eax
80104da3:	01 d0                	add    %edx,%eax
80104da5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104da8:	73 47                	jae    80104df1 <memmove+0x6e>
    s += n;
80104daa:	8b 45 10             	mov    0x10(%ebp),%eax
80104dad:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104db0:	8b 45 10             	mov    0x10(%ebp),%eax
80104db3:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104db6:	eb 13                	jmp    80104dcb <memmove+0x48>
      *--d = *--s;
80104db8:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104dbc:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104dc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dc3:	0f b6 10             	movzbl (%eax),%edx
80104dc6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dc9:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104dcb:	8b 45 10             	mov    0x10(%ebp),%eax
80104dce:	8d 50 ff             	lea    -0x1(%eax),%edx
80104dd1:	89 55 10             	mov    %edx,0x10(%ebp)
80104dd4:	85 c0                	test   %eax,%eax
80104dd6:	75 e0                	jne    80104db8 <memmove+0x35>
  if(s < d && s + n > d){
80104dd8:	eb 24                	jmp    80104dfe <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104dda:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ddd:	8d 42 01             	lea    0x1(%edx),%eax
80104de0:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104de3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104de6:	8d 48 01             	lea    0x1(%eax),%ecx
80104de9:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104dec:	0f b6 12             	movzbl (%edx),%edx
80104def:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104df1:	8b 45 10             	mov    0x10(%ebp),%eax
80104df4:	8d 50 ff             	lea    -0x1(%eax),%edx
80104df7:	89 55 10             	mov    %edx,0x10(%ebp)
80104dfa:	85 c0                	test   %eax,%eax
80104dfc:	75 dc                	jne    80104dda <memmove+0x57>

  return dst;
80104dfe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e01:	c9                   	leave  
80104e02:	c3                   	ret    

80104e03 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104e03:	55                   	push   %ebp
80104e04:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104e06:	ff 75 10             	push   0x10(%ebp)
80104e09:	ff 75 0c             	push   0xc(%ebp)
80104e0c:	ff 75 08             	push   0x8(%ebp)
80104e0f:	e8 6f ff ff ff       	call   80104d83 <memmove>
80104e14:	83 c4 0c             	add    $0xc,%esp
}
80104e17:	c9                   	leave  
80104e18:	c3                   	ret    

80104e19 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104e19:	55                   	push   %ebp
80104e1a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104e1c:	eb 0c                	jmp    80104e2a <strncmp+0x11>
    n--, p++, q++;
80104e1e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104e22:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104e26:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104e2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e2e:	74 1a                	je     80104e4a <strncmp+0x31>
80104e30:	8b 45 08             	mov    0x8(%ebp),%eax
80104e33:	0f b6 00             	movzbl (%eax),%eax
80104e36:	84 c0                	test   %al,%al
80104e38:	74 10                	je     80104e4a <strncmp+0x31>
80104e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3d:	0f b6 10             	movzbl (%eax),%edx
80104e40:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e43:	0f b6 00             	movzbl (%eax),%eax
80104e46:	38 c2                	cmp    %al,%dl
80104e48:	74 d4                	je     80104e1e <strncmp+0x5>
  if(n == 0)
80104e4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e4e:	75 07                	jne    80104e57 <strncmp+0x3e>
    return 0;
80104e50:	b8 00 00 00 00       	mov    $0x0,%eax
80104e55:	eb 16                	jmp    80104e6d <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104e57:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5a:	0f b6 00             	movzbl (%eax),%eax
80104e5d:	0f b6 d0             	movzbl %al,%edx
80104e60:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e63:	0f b6 00             	movzbl (%eax),%eax
80104e66:	0f b6 c8             	movzbl %al,%ecx
80104e69:	89 d0                	mov    %edx,%eax
80104e6b:	29 c8                	sub    %ecx,%eax
}
80104e6d:	5d                   	pop    %ebp
80104e6e:	c3                   	ret    

80104e6f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104e6f:	55                   	push   %ebp
80104e70:	89 e5                	mov    %esp,%ebp
80104e72:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104e75:	8b 45 08             	mov    0x8(%ebp),%eax
80104e78:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104e7b:	90                   	nop
80104e7c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e7f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e82:	89 55 10             	mov    %edx,0x10(%ebp)
80104e85:	85 c0                	test   %eax,%eax
80104e87:	7e 2c                	jle    80104eb5 <strncpy+0x46>
80104e89:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e8c:	8d 42 01             	lea    0x1(%edx),%eax
80104e8f:	89 45 0c             	mov    %eax,0xc(%ebp)
80104e92:	8b 45 08             	mov    0x8(%ebp),%eax
80104e95:	8d 48 01             	lea    0x1(%eax),%ecx
80104e98:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104e9b:	0f b6 12             	movzbl (%edx),%edx
80104e9e:	88 10                	mov    %dl,(%eax)
80104ea0:	0f b6 00             	movzbl (%eax),%eax
80104ea3:	84 c0                	test   %al,%al
80104ea5:	75 d5                	jne    80104e7c <strncpy+0xd>
    ;
  while(n-- > 0)
80104ea7:	eb 0c                	jmp    80104eb5 <strncpy+0x46>
    *s++ = 0;
80104ea9:	8b 45 08             	mov    0x8(%ebp),%eax
80104eac:	8d 50 01             	lea    0x1(%eax),%edx
80104eaf:	89 55 08             	mov    %edx,0x8(%ebp)
80104eb2:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104eb5:	8b 45 10             	mov    0x10(%ebp),%eax
80104eb8:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ebb:	89 55 10             	mov    %edx,0x10(%ebp)
80104ebe:	85 c0                	test   %eax,%eax
80104ec0:	7f e7                	jg     80104ea9 <strncpy+0x3a>
  return os;
80104ec2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ec5:	c9                   	leave  
80104ec6:	c3                   	ret    

80104ec7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104ec7:	55                   	push   %ebp
80104ec8:	89 e5                	mov    %esp,%ebp
80104eca:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104ed3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ed7:	7f 05                	jg     80104ede <safestrcpy+0x17>
    return os;
80104ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104edc:	eb 32                	jmp    80104f10 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104ede:	90                   	nop
80104edf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ee3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ee7:	7e 1e                	jle    80104f07 <safestrcpy+0x40>
80104ee9:	8b 55 0c             	mov    0xc(%ebp),%edx
80104eec:	8d 42 01             	lea    0x1(%edx),%eax
80104eef:	89 45 0c             	mov    %eax,0xc(%ebp)
80104ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef5:	8d 48 01             	lea    0x1(%eax),%ecx
80104ef8:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104efb:	0f b6 12             	movzbl (%edx),%edx
80104efe:	88 10                	mov    %dl,(%eax)
80104f00:	0f b6 00             	movzbl (%eax),%eax
80104f03:	84 c0                	test   %al,%al
80104f05:	75 d8                	jne    80104edf <safestrcpy+0x18>
    ;
  *s = 0;
80104f07:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0a:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104f0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f10:	c9                   	leave  
80104f11:	c3                   	ret    

80104f12 <strlen>:

int
strlen(const char *s)
{
80104f12:	55                   	push   %ebp
80104f13:	89 e5                	mov    %esp,%ebp
80104f15:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104f18:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104f1f:	eb 04                	jmp    80104f25 <strlen+0x13>
80104f21:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f25:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f28:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2b:	01 d0                	add    %edx,%eax
80104f2d:	0f b6 00             	movzbl (%eax),%eax
80104f30:	84 c0                	test   %al,%al
80104f32:	75 ed                	jne    80104f21 <strlen+0xf>
    ;
  return n;
80104f34:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f37:	c9                   	leave  
80104f38:	c3                   	ret    

80104f39 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104f39:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104f3d:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104f41:	55                   	push   %ebp
  pushl %ebx
80104f42:	53                   	push   %ebx
  pushl %esi
80104f43:	56                   	push   %esi
  pushl %edi
80104f44:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104f45:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104f47:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104f49:	5f                   	pop    %edi
  popl %esi
80104f4a:	5e                   	pop    %esi
  popl %ebx
80104f4b:	5b                   	pop    %ebx
  popl %ebp
80104f4c:	5d                   	pop    %ebp
  ret
80104f4d:	c3                   	ret    

80104f4e <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104f4e:	55                   	push   %ebp
80104f4f:	89 e5                	mov    %esp,%ebp
80104f51:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104f54:	e8 73 eb ff ff       	call   80103acc <myproc>
80104f59:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f5f:	8b 00                	mov    (%eax),%eax
80104f61:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f64:	73 0f                	jae    80104f75 <fetchint+0x27>
80104f66:	8b 45 08             	mov    0x8(%ebp),%eax
80104f69:	8d 50 04             	lea    0x4(%eax),%edx
80104f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6f:	8b 00                	mov    (%eax),%eax
80104f71:	39 c2                	cmp    %eax,%edx
80104f73:	76 07                	jbe    80104f7c <fetchint+0x2e>
    return -1;
80104f75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f7a:	eb 0f                	jmp    80104f8b <fetchint+0x3d>
  *ip = *(int*)(addr);
80104f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7f:	8b 10                	mov    (%eax),%edx
80104f81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f84:	89 10                	mov    %edx,(%eax)
  return 0;
80104f86:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f8b:	c9                   	leave  
80104f8c:	c3                   	ret    

80104f8d <sys_getqinfo>:

int sys_getqinfo(void) {
80104f8d:	55                   	push   %ebp
80104f8e:	89 e5                	mov    %esp,%ebp
80104f90:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80104f93:	83 ec 08             	sub    $0x8,%esp
80104f96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f99:	50                   	push   %eax
80104f9a:	6a 00                	push   $0x0
80104f9c:	e8 81 00 00 00       	call   80105022 <argint>
80104fa1:	83 c4 10             	add    $0x10,%esp
80104fa4:	85 c0                	test   %eax,%eax
80104fa6:	79 07                	jns    80104faf <sys_getqinfo+0x22>
      return -1;
80104fa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fad:	eb 0f                	jmp    80104fbe <sys_getqinfo+0x31>

  return getqinfo(pid); 
80104faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb2:	83 ec 0c             	sub    $0xc,%esp
80104fb5:	50                   	push   %eax
80104fb6:	e8 c4 e9 ff ff       	call   8010397f <getqinfo>
80104fbb:	83 c4 10             	add    $0x10,%esp
}
80104fbe:	c9                   	leave  
80104fbf:	c3                   	ret    

80104fc0 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104fc0:	55                   	push   %ebp
80104fc1:	89 e5                	mov    %esp,%ebp
80104fc3:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104fc6:	e8 01 eb ff ff       	call   80103acc <myproc>
80104fcb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd1:	8b 00                	mov    (%eax),%eax
80104fd3:	39 45 08             	cmp    %eax,0x8(%ebp)
80104fd6:	72 07                	jb     80104fdf <fetchstr+0x1f>
    return -1;
80104fd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fdd:	eb 41                	jmp    80105020 <fetchstr+0x60>
  *pp = (char*)addr;
80104fdf:	8b 55 08             	mov    0x8(%ebp),%edx
80104fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe5:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fea:	8b 00                	mov    (%eax),%eax
80104fec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104fef:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff2:	8b 00                	mov    (%eax),%eax
80104ff4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ff7:	eb 1a                	jmp    80105013 <fetchstr+0x53>
    if(*s == 0)
80104ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ffc:	0f b6 00             	movzbl (%eax),%eax
80104fff:	84 c0                	test   %al,%al
80105001:	75 0c                	jne    8010500f <fetchstr+0x4f>
      return s - *pp;
80105003:	8b 45 0c             	mov    0xc(%ebp),%eax
80105006:	8b 10                	mov    (%eax),%edx
80105008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500b:	29 d0                	sub    %edx,%eax
8010500d:	eb 11                	jmp    80105020 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
8010500f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105016:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105019:	72 de                	jb     80104ff9 <fetchstr+0x39>
  }
  return -1;
8010501b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105020:	c9                   	leave  
80105021:	c3                   	ret    

80105022 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105022:	55                   	push   %ebp
80105023:	89 e5                	mov    %esp,%ebp
80105025:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105028:	e8 9f ea ff ff       	call   80103acc <myproc>
8010502d:	8b 40 18             	mov    0x18(%eax),%eax
80105030:	8b 50 44             	mov    0x44(%eax),%edx
80105033:	8b 45 08             	mov    0x8(%ebp),%eax
80105036:	c1 e0 02             	shl    $0x2,%eax
80105039:	01 d0                	add    %edx,%eax
8010503b:	83 c0 04             	add    $0x4,%eax
8010503e:	83 ec 08             	sub    $0x8,%esp
80105041:	ff 75 0c             	push   0xc(%ebp)
80105044:	50                   	push   %eax
80105045:	e8 04 ff ff ff       	call   80104f4e <fetchint>
8010504a:	83 c4 10             	add    $0x10,%esp
}
8010504d:	c9                   	leave  
8010504e:	c3                   	ret    

8010504f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010504f:	55                   	push   %ebp
80105050:	89 e5                	mov    %esp,%ebp
80105052:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105055:	e8 72 ea ff ff       	call   80103acc <myproc>
8010505a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010505d:	83 ec 08             	sub    $0x8,%esp
80105060:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105063:	50                   	push   %eax
80105064:	ff 75 08             	push   0x8(%ebp)
80105067:	e8 b6 ff ff ff       	call   80105022 <argint>
8010506c:	83 c4 10             	add    $0x10,%esp
8010506f:	85 c0                	test   %eax,%eax
80105071:	79 07                	jns    8010507a <argptr+0x2b>
    return -1;
80105073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105078:	eb 3b                	jmp    801050b5 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010507a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010507e:	78 1f                	js     8010509f <argptr+0x50>
80105080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105083:	8b 00                	mov    (%eax),%eax
80105085:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105088:	39 d0                	cmp    %edx,%eax
8010508a:	76 13                	jbe    8010509f <argptr+0x50>
8010508c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508f:	89 c2                	mov    %eax,%edx
80105091:	8b 45 10             	mov    0x10(%ebp),%eax
80105094:	01 c2                	add    %eax,%edx
80105096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105099:	8b 00                	mov    (%eax),%eax
8010509b:	39 c2                	cmp    %eax,%edx
8010509d:	76 07                	jbe    801050a6 <argptr+0x57>
    return -1;
8010509f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050a4:	eb 0f                	jmp    801050b5 <argptr+0x66>
  *pp = (char*)i;
801050a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a9:	89 c2                	mov    %eax,%edx
801050ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ae:	89 10                	mov    %edx,(%eax)
  return 0;
801050b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050b5:	c9                   	leave  
801050b6:	c3                   	ret    

801050b7 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801050b7:	55                   	push   %ebp
801050b8:	89 e5                	mov    %esp,%ebp
801050ba:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801050bd:	83 ec 08             	sub    $0x8,%esp
801050c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050c3:	50                   	push   %eax
801050c4:	ff 75 08             	push   0x8(%ebp)
801050c7:	e8 56 ff ff ff       	call   80105022 <argint>
801050cc:	83 c4 10             	add    $0x10,%esp
801050cf:	85 c0                	test   %eax,%eax
801050d1:	79 07                	jns    801050da <argstr+0x23>
    return -1;
801050d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d8:	eb 12                	jmp    801050ec <argstr+0x35>
  return fetchstr(addr, pp);
801050da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050dd:	83 ec 08             	sub    $0x8,%esp
801050e0:	ff 75 0c             	push   0xc(%ebp)
801050e3:	50                   	push   %eax
801050e4:	e8 d7 fe ff ff       	call   80104fc0 <fetchstr>
801050e9:	83 c4 10             	add    $0x10,%esp
}
801050ec:	c9                   	leave  
801050ed:	c3                   	ret    

801050ee <syscall>:

};

void
syscall(void)
{
801050ee:	55                   	push   %ebp
801050ef:	89 e5                	mov    %esp,%ebp
801050f1:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801050f4:	e8 d3 e9 ff ff       	call   80103acc <myproc>
801050f9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801050fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ff:	8b 40 18             	mov    0x18(%eax),%eax
80105102:	8b 40 1c             	mov    0x1c(%eax),%eax
80105105:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105108:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010510c:	7e 2f                	jle    8010513d <syscall+0x4f>
8010510e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105111:	83 f8 18             	cmp    $0x18,%eax
80105114:	77 27                	ja     8010513d <syscall+0x4f>
80105116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105119:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105120:	85 c0                	test   %eax,%eax
80105122:	74 19                	je     8010513d <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105127:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010512e:	ff d0                	call   *%eax
80105130:	89 c2                	mov    %eax,%edx
80105132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105135:	8b 40 18             	mov    0x18(%eax),%eax
80105138:	89 50 1c             	mov    %edx,0x1c(%eax)
8010513b:	eb 2c                	jmp    80105169 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010513d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105140:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105146:	8b 40 10             	mov    0x10(%eax),%eax
80105149:	ff 75 f0             	push   -0x10(%ebp)
8010514c:	52                   	push   %edx
8010514d:	50                   	push   %eax
8010514e:	68 08 a9 10 80       	push   $0x8010a908
80105153:	e8 9c b2 ff ff       	call   801003f4 <cprintf>
80105158:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
8010515b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010515e:	8b 40 18             	mov    0x18(%eax),%eax
80105161:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105168:	90                   	nop
80105169:	90                   	nop
8010516a:	c9                   	leave  
8010516b:	c3                   	ret    

8010516c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010516c:	55                   	push   %ebp
8010516d:	89 e5                	mov    %esp,%ebp
8010516f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105172:	83 ec 08             	sub    $0x8,%esp
80105175:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105178:	50                   	push   %eax
80105179:	ff 75 08             	push   0x8(%ebp)
8010517c:	e8 a1 fe ff ff       	call   80105022 <argint>
80105181:	83 c4 10             	add    $0x10,%esp
80105184:	85 c0                	test   %eax,%eax
80105186:	79 07                	jns    8010518f <argfd+0x23>
    return -1;
80105188:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010518d:	eb 4f                	jmp    801051de <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010518f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105192:	85 c0                	test   %eax,%eax
80105194:	78 20                	js     801051b6 <argfd+0x4a>
80105196:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105199:	83 f8 0f             	cmp    $0xf,%eax
8010519c:	7f 18                	jg     801051b6 <argfd+0x4a>
8010519e:	e8 29 e9 ff ff       	call   80103acc <myproc>
801051a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051a6:	83 c2 08             	add    $0x8,%edx
801051a9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801051ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051b4:	75 07                	jne    801051bd <argfd+0x51>
    return -1;
801051b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051bb:	eb 21                	jmp    801051de <argfd+0x72>
  if(pfd)
801051bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801051c1:	74 08                	je     801051cb <argfd+0x5f>
    *pfd = fd;
801051c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c9:	89 10                	mov    %edx,(%eax)
  if(pf)
801051cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051cf:	74 08                	je     801051d9 <argfd+0x6d>
    *pf = f;
801051d1:	8b 45 10             	mov    0x10(%ebp),%eax
801051d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051d7:	89 10                	mov    %edx,(%eax)
  return 0;
801051d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051de:	c9                   	leave  
801051df:	c3                   	ret    

801051e0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801051e0:	55                   	push   %ebp
801051e1:	89 e5                	mov    %esp,%ebp
801051e3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801051e6:	e8 e1 e8 ff ff       	call   80103acc <myproc>
801051eb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801051ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801051f5:	eb 2a                	jmp    80105221 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801051f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051fd:	83 c2 08             	add    $0x8,%edx
80105200:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105204:	85 c0                	test   %eax,%eax
80105206:	75 15                	jne    8010521d <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105208:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010520b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010520e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105211:	8b 55 08             	mov    0x8(%ebp),%edx
80105214:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521b:	eb 0f                	jmp    8010522c <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010521d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105221:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105225:	7e d0                	jle    801051f7 <fdalloc+0x17>
    }
  }
  return -1;
80105227:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010522c:	c9                   	leave  
8010522d:	c3                   	ret    

8010522e <sys_dup>:

int
sys_dup(void)
{
8010522e:	55                   	push   %ebp
8010522f:	89 e5                	mov    %esp,%ebp
80105231:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105234:	83 ec 04             	sub    $0x4,%esp
80105237:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010523a:	50                   	push   %eax
8010523b:	6a 00                	push   $0x0
8010523d:	6a 00                	push   $0x0
8010523f:	e8 28 ff ff ff       	call   8010516c <argfd>
80105244:	83 c4 10             	add    $0x10,%esp
80105247:	85 c0                	test   %eax,%eax
80105249:	79 07                	jns    80105252 <sys_dup+0x24>
    return -1;
8010524b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105250:	eb 31                	jmp    80105283 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105255:	83 ec 0c             	sub    $0xc,%esp
80105258:	50                   	push   %eax
80105259:	e8 82 ff ff ff       	call   801051e0 <fdalloc>
8010525e:	83 c4 10             	add    $0x10,%esp
80105261:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105264:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105268:	79 07                	jns    80105271 <sys_dup+0x43>
    return -1;
8010526a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010526f:	eb 12                	jmp    80105283 <sys_dup+0x55>
  filedup(f);
80105271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105274:	83 ec 0c             	sub    $0xc,%esp
80105277:	50                   	push   %eax
80105278:	e8 cd bd ff ff       	call   8010104a <filedup>
8010527d:	83 c4 10             	add    $0x10,%esp
  return fd;
80105280:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105283:	c9                   	leave  
80105284:	c3                   	ret    

80105285 <sys_read>:

int
sys_read(void)
{
80105285:	55                   	push   %ebp
80105286:	89 e5                	mov    %esp,%ebp
80105288:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010528b:	83 ec 04             	sub    $0x4,%esp
8010528e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105291:	50                   	push   %eax
80105292:	6a 00                	push   $0x0
80105294:	6a 00                	push   $0x0
80105296:	e8 d1 fe ff ff       	call   8010516c <argfd>
8010529b:	83 c4 10             	add    $0x10,%esp
8010529e:	85 c0                	test   %eax,%eax
801052a0:	78 2e                	js     801052d0 <sys_read+0x4b>
801052a2:	83 ec 08             	sub    $0x8,%esp
801052a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052a8:	50                   	push   %eax
801052a9:	6a 02                	push   $0x2
801052ab:	e8 72 fd ff ff       	call   80105022 <argint>
801052b0:	83 c4 10             	add    $0x10,%esp
801052b3:	85 c0                	test   %eax,%eax
801052b5:	78 19                	js     801052d0 <sys_read+0x4b>
801052b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ba:	83 ec 04             	sub    $0x4,%esp
801052bd:	50                   	push   %eax
801052be:	8d 45 ec             	lea    -0x14(%ebp),%eax
801052c1:	50                   	push   %eax
801052c2:	6a 01                	push   $0x1
801052c4:	e8 86 fd ff ff       	call   8010504f <argptr>
801052c9:	83 c4 10             	add    $0x10,%esp
801052cc:	85 c0                	test   %eax,%eax
801052ce:	79 07                	jns    801052d7 <sys_read+0x52>
    return -1;
801052d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d5:	eb 17                	jmp    801052ee <sys_read+0x69>
  return fileread(f, p, n);
801052d7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801052da:	8b 55 ec             	mov    -0x14(%ebp),%edx
801052dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e0:	83 ec 04             	sub    $0x4,%esp
801052e3:	51                   	push   %ecx
801052e4:	52                   	push   %edx
801052e5:	50                   	push   %eax
801052e6:	e8 ef be ff ff       	call   801011da <fileread>
801052eb:	83 c4 10             	add    $0x10,%esp
}
801052ee:	c9                   	leave  
801052ef:	c3                   	ret    

801052f0 <sys_write>:

int
sys_write(void)
{
801052f0:	55                   	push   %ebp
801052f1:	89 e5                	mov    %esp,%ebp
801052f3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052f6:	83 ec 04             	sub    $0x4,%esp
801052f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052fc:	50                   	push   %eax
801052fd:	6a 00                	push   $0x0
801052ff:	6a 00                	push   $0x0
80105301:	e8 66 fe ff ff       	call   8010516c <argfd>
80105306:	83 c4 10             	add    $0x10,%esp
80105309:	85 c0                	test   %eax,%eax
8010530b:	78 2e                	js     8010533b <sys_write+0x4b>
8010530d:	83 ec 08             	sub    $0x8,%esp
80105310:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105313:	50                   	push   %eax
80105314:	6a 02                	push   $0x2
80105316:	e8 07 fd ff ff       	call   80105022 <argint>
8010531b:	83 c4 10             	add    $0x10,%esp
8010531e:	85 c0                	test   %eax,%eax
80105320:	78 19                	js     8010533b <sys_write+0x4b>
80105322:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105325:	83 ec 04             	sub    $0x4,%esp
80105328:	50                   	push   %eax
80105329:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010532c:	50                   	push   %eax
8010532d:	6a 01                	push   $0x1
8010532f:	e8 1b fd ff ff       	call   8010504f <argptr>
80105334:	83 c4 10             	add    $0x10,%esp
80105337:	85 c0                	test   %eax,%eax
80105339:	79 07                	jns    80105342 <sys_write+0x52>
    return -1;
8010533b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105340:	eb 17                	jmp    80105359 <sys_write+0x69>
  return filewrite(f, p, n);
80105342:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105345:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105348:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010534b:	83 ec 04             	sub    $0x4,%esp
8010534e:	51                   	push   %ecx
8010534f:	52                   	push   %edx
80105350:	50                   	push   %eax
80105351:	e8 3c bf ff ff       	call   80101292 <filewrite>
80105356:	83 c4 10             	add    $0x10,%esp
}
80105359:	c9                   	leave  
8010535a:	c3                   	ret    

8010535b <sys_close>:

int
sys_close(void)
{
8010535b:	55                   	push   %ebp
8010535c:	89 e5                	mov    %esp,%ebp
8010535e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105361:	83 ec 04             	sub    $0x4,%esp
80105364:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105367:	50                   	push   %eax
80105368:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010536b:	50                   	push   %eax
8010536c:	6a 00                	push   $0x0
8010536e:	e8 f9 fd ff ff       	call   8010516c <argfd>
80105373:	83 c4 10             	add    $0x10,%esp
80105376:	85 c0                	test   %eax,%eax
80105378:	79 07                	jns    80105381 <sys_close+0x26>
    return -1;
8010537a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010537f:	eb 27                	jmp    801053a8 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105381:	e8 46 e7 ff ff       	call   80103acc <myproc>
80105386:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105389:	83 c2 08             	add    $0x8,%edx
8010538c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105393:	00 
  fileclose(f);
80105394:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105397:	83 ec 0c             	sub    $0xc,%esp
8010539a:	50                   	push   %eax
8010539b:	e8 fb bc ff ff       	call   8010109b <fileclose>
801053a0:	83 c4 10             	add    $0x10,%esp
  return 0;
801053a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053a8:	c9                   	leave  
801053a9:	c3                   	ret    

801053aa <sys_fstat>:

int
sys_fstat(void)
{
801053aa:	55                   	push   %ebp
801053ab:	89 e5                	mov    %esp,%ebp
801053ad:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801053b0:	83 ec 04             	sub    $0x4,%esp
801053b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053b6:	50                   	push   %eax
801053b7:	6a 00                	push   $0x0
801053b9:	6a 00                	push   $0x0
801053bb:	e8 ac fd ff ff       	call   8010516c <argfd>
801053c0:	83 c4 10             	add    $0x10,%esp
801053c3:	85 c0                	test   %eax,%eax
801053c5:	78 17                	js     801053de <sys_fstat+0x34>
801053c7:	83 ec 04             	sub    $0x4,%esp
801053ca:	6a 14                	push   $0x14
801053cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053cf:	50                   	push   %eax
801053d0:	6a 01                	push   $0x1
801053d2:	e8 78 fc ff ff       	call   8010504f <argptr>
801053d7:	83 c4 10             	add    $0x10,%esp
801053da:	85 c0                	test   %eax,%eax
801053dc:	79 07                	jns    801053e5 <sys_fstat+0x3b>
    return -1;
801053de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e3:	eb 13                	jmp    801053f8 <sys_fstat+0x4e>
  return filestat(f, st);
801053e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053eb:	83 ec 08             	sub    $0x8,%esp
801053ee:	52                   	push   %edx
801053ef:	50                   	push   %eax
801053f0:	e8 8e bd ff ff       	call   80101183 <filestat>
801053f5:	83 c4 10             	add    $0x10,%esp
}
801053f8:	c9                   	leave  
801053f9:	c3                   	ret    

801053fa <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801053fa:	55                   	push   %ebp
801053fb:	89 e5                	mov    %esp,%ebp
801053fd:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105400:	83 ec 08             	sub    $0x8,%esp
80105403:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105406:	50                   	push   %eax
80105407:	6a 00                	push   $0x0
80105409:	e8 a9 fc ff ff       	call   801050b7 <argstr>
8010540e:	83 c4 10             	add    $0x10,%esp
80105411:	85 c0                	test   %eax,%eax
80105413:	78 15                	js     8010542a <sys_link+0x30>
80105415:	83 ec 08             	sub    $0x8,%esp
80105418:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010541b:	50                   	push   %eax
8010541c:	6a 01                	push   $0x1
8010541e:	e8 94 fc ff ff       	call   801050b7 <argstr>
80105423:	83 c4 10             	add    $0x10,%esp
80105426:	85 c0                	test   %eax,%eax
80105428:	79 0a                	jns    80105434 <sys_link+0x3a>
    return -1;
8010542a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010542f:	e9 68 01 00 00       	jmp    8010559c <sys_link+0x1a2>

  begin_op();
80105434:	e8 03 dc ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
80105439:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010543c:	83 ec 0c             	sub    $0xc,%esp
8010543f:	50                   	push   %eax
80105440:	e8 d8 d0 ff ff       	call   8010251d <namei>
80105445:	83 c4 10             	add    $0x10,%esp
80105448:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010544b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010544f:	75 0f                	jne    80105460 <sys_link+0x66>
    end_op();
80105451:	e8 72 dc ff ff       	call   801030c8 <end_op>
    return -1;
80105456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545b:	e9 3c 01 00 00       	jmp    8010559c <sys_link+0x1a2>
  }

  ilock(ip);
80105460:	83 ec 0c             	sub    $0xc,%esp
80105463:	ff 75 f4             	push   -0xc(%ebp)
80105466:	e8 7f c5 ff ff       	call   801019ea <ilock>
8010546b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010546e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105471:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105475:	66 83 f8 01          	cmp    $0x1,%ax
80105479:	75 1d                	jne    80105498 <sys_link+0x9e>
    iunlockput(ip);
8010547b:	83 ec 0c             	sub    $0xc,%esp
8010547e:	ff 75 f4             	push   -0xc(%ebp)
80105481:	e8 95 c7 ff ff       	call   80101c1b <iunlockput>
80105486:	83 c4 10             	add    $0x10,%esp
    end_op();
80105489:	e8 3a dc ff ff       	call   801030c8 <end_op>
    return -1;
8010548e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105493:	e9 04 01 00 00       	jmp    8010559c <sys_link+0x1a2>
  }

  ip->nlink++;
80105498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010549b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010549f:	83 c0 01             	add    $0x1,%eax
801054a2:	89 c2                	mov    %eax,%edx
801054a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a7:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801054ab:	83 ec 0c             	sub    $0xc,%esp
801054ae:	ff 75 f4             	push   -0xc(%ebp)
801054b1:	e8 57 c3 ff ff       	call   8010180d <iupdate>
801054b6:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801054b9:	83 ec 0c             	sub    $0xc,%esp
801054bc:	ff 75 f4             	push   -0xc(%ebp)
801054bf:	e8 39 c6 ff ff       	call   80101afd <iunlock>
801054c4:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801054c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801054ca:	83 ec 08             	sub    $0x8,%esp
801054cd:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801054d0:	52                   	push   %edx
801054d1:	50                   	push   %eax
801054d2:	e8 62 d0 ff ff       	call   80102539 <nameiparent>
801054d7:	83 c4 10             	add    $0x10,%esp
801054da:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054e1:	74 71                	je     80105554 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801054e3:	83 ec 0c             	sub    $0xc,%esp
801054e6:	ff 75 f0             	push   -0x10(%ebp)
801054e9:	e8 fc c4 ff ff       	call   801019ea <ilock>
801054ee:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801054f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f4:	8b 10                	mov    (%eax),%edx
801054f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f9:	8b 00                	mov    (%eax),%eax
801054fb:	39 c2                	cmp    %eax,%edx
801054fd:	75 1d                	jne    8010551c <sys_link+0x122>
801054ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105502:	8b 40 04             	mov    0x4(%eax),%eax
80105505:	83 ec 04             	sub    $0x4,%esp
80105508:	50                   	push   %eax
80105509:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010550c:	50                   	push   %eax
8010550d:	ff 75 f0             	push   -0x10(%ebp)
80105510:	e8 71 cd ff ff       	call   80102286 <dirlink>
80105515:	83 c4 10             	add    $0x10,%esp
80105518:	85 c0                	test   %eax,%eax
8010551a:	79 10                	jns    8010552c <sys_link+0x132>
    iunlockput(dp);
8010551c:	83 ec 0c             	sub    $0xc,%esp
8010551f:	ff 75 f0             	push   -0x10(%ebp)
80105522:	e8 f4 c6 ff ff       	call   80101c1b <iunlockput>
80105527:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010552a:	eb 29                	jmp    80105555 <sys_link+0x15b>
  }
  iunlockput(dp);
8010552c:	83 ec 0c             	sub    $0xc,%esp
8010552f:	ff 75 f0             	push   -0x10(%ebp)
80105532:	e8 e4 c6 ff ff       	call   80101c1b <iunlockput>
80105537:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010553a:	83 ec 0c             	sub    $0xc,%esp
8010553d:	ff 75 f4             	push   -0xc(%ebp)
80105540:	e8 06 c6 ff ff       	call   80101b4b <iput>
80105545:	83 c4 10             	add    $0x10,%esp

  end_op();
80105548:	e8 7b db ff ff       	call   801030c8 <end_op>

  return 0;
8010554d:	b8 00 00 00 00       	mov    $0x0,%eax
80105552:	eb 48                	jmp    8010559c <sys_link+0x1a2>
    goto bad;
80105554:	90                   	nop

bad:
  ilock(ip);
80105555:	83 ec 0c             	sub    $0xc,%esp
80105558:	ff 75 f4             	push   -0xc(%ebp)
8010555b:	e8 8a c4 ff ff       	call   801019ea <ilock>
80105560:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105566:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010556a:	83 e8 01             	sub    $0x1,%eax
8010556d:	89 c2                	mov    %eax,%edx
8010556f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105572:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105576:	83 ec 0c             	sub    $0xc,%esp
80105579:	ff 75 f4             	push   -0xc(%ebp)
8010557c:	e8 8c c2 ff ff       	call   8010180d <iupdate>
80105581:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105584:	83 ec 0c             	sub    $0xc,%esp
80105587:	ff 75 f4             	push   -0xc(%ebp)
8010558a:	e8 8c c6 ff ff       	call   80101c1b <iunlockput>
8010558f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105592:	e8 31 db ff ff       	call   801030c8 <end_op>
  return -1;
80105597:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010559c:	c9                   	leave  
8010559d:	c3                   	ret    

8010559e <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010559e:	55                   	push   %ebp
8010559f:	89 e5                	mov    %esp,%ebp
801055a1:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801055a4:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801055ab:	eb 40                	jmp    801055ed <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801055ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b0:	6a 10                	push   $0x10
801055b2:	50                   	push   %eax
801055b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801055b6:	50                   	push   %eax
801055b7:	ff 75 08             	push   0x8(%ebp)
801055ba:	e8 17 c9 ff ff       	call   80101ed6 <readi>
801055bf:	83 c4 10             	add    $0x10,%esp
801055c2:	83 f8 10             	cmp    $0x10,%eax
801055c5:	74 0d                	je     801055d4 <isdirempty+0x36>
      panic("isdirempty: readi");
801055c7:	83 ec 0c             	sub    $0xc,%esp
801055ca:	68 24 a9 10 80       	push   $0x8010a924
801055cf:	e8 d5 af ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801055d4:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801055d8:	66 85 c0             	test   %ax,%ax
801055db:	74 07                	je     801055e4 <isdirempty+0x46>
      return 0;
801055dd:	b8 00 00 00 00       	mov    $0x0,%eax
801055e2:	eb 1b                	jmp    801055ff <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801055e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e7:	83 c0 10             	add    $0x10,%eax
801055ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055ed:	8b 45 08             	mov    0x8(%ebp),%eax
801055f0:	8b 50 58             	mov    0x58(%eax),%edx
801055f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f6:	39 c2                	cmp    %eax,%edx
801055f8:	77 b3                	ja     801055ad <isdirempty+0xf>
  }
  return 1;
801055fa:	b8 01 00 00 00       	mov    $0x1,%eax
}
801055ff:	c9                   	leave  
80105600:	c3                   	ret    

80105601 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105601:	55                   	push   %ebp
80105602:	89 e5                	mov    %esp,%ebp
80105604:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105607:	83 ec 08             	sub    $0x8,%esp
8010560a:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010560d:	50                   	push   %eax
8010560e:	6a 00                	push   $0x0
80105610:	e8 a2 fa ff ff       	call   801050b7 <argstr>
80105615:	83 c4 10             	add    $0x10,%esp
80105618:	85 c0                	test   %eax,%eax
8010561a:	79 0a                	jns    80105626 <sys_unlink+0x25>
    return -1;
8010561c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105621:	e9 bf 01 00 00       	jmp    801057e5 <sys_unlink+0x1e4>

  begin_op();
80105626:	e8 11 da ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010562b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010562e:	83 ec 08             	sub    $0x8,%esp
80105631:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105634:	52                   	push   %edx
80105635:	50                   	push   %eax
80105636:	e8 fe ce ff ff       	call   80102539 <nameiparent>
8010563b:	83 c4 10             	add    $0x10,%esp
8010563e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105641:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105645:	75 0f                	jne    80105656 <sys_unlink+0x55>
    end_op();
80105647:	e8 7c da ff ff       	call   801030c8 <end_op>
    return -1;
8010564c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105651:	e9 8f 01 00 00       	jmp    801057e5 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105656:	83 ec 0c             	sub    $0xc,%esp
80105659:	ff 75 f4             	push   -0xc(%ebp)
8010565c:	e8 89 c3 ff ff       	call   801019ea <ilock>
80105661:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105664:	83 ec 08             	sub    $0x8,%esp
80105667:	68 36 a9 10 80       	push   $0x8010a936
8010566c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010566f:	50                   	push   %eax
80105670:	e8 3c cb ff ff       	call   801021b1 <namecmp>
80105675:	83 c4 10             	add    $0x10,%esp
80105678:	85 c0                	test   %eax,%eax
8010567a:	0f 84 49 01 00 00    	je     801057c9 <sys_unlink+0x1c8>
80105680:	83 ec 08             	sub    $0x8,%esp
80105683:	68 38 a9 10 80       	push   $0x8010a938
80105688:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010568b:	50                   	push   %eax
8010568c:	e8 20 cb ff ff       	call   801021b1 <namecmp>
80105691:	83 c4 10             	add    $0x10,%esp
80105694:	85 c0                	test   %eax,%eax
80105696:	0f 84 2d 01 00 00    	je     801057c9 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010569c:	83 ec 04             	sub    $0x4,%esp
8010569f:	8d 45 c8             	lea    -0x38(%ebp),%eax
801056a2:	50                   	push   %eax
801056a3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056a6:	50                   	push   %eax
801056a7:	ff 75 f4             	push   -0xc(%ebp)
801056aa:	e8 1d cb ff ff       	call   801021cc <dirlookup>
801056af:	83 c4 10             	add    $0x10,%esp
801056b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801056b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056b9:	0f 84 0d 01 00 00    	je     801057cc <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
801056bf:	83 ec 0c             	sub    $0xc,%esp
801056c2:	ff 75 f0             	push   -0x10(%ebp)
801056c5:	e8 20 c3 ff ff       	call   801019ea <ilock>
801056ca:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801056cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056d4:	66 85 c0             	test   %ax,%ax
801056d7:	7f 0d                	jg     801056e6 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801056d9:	83 ec 0c             	sub    $0xc,%esp
801056dc:	68 3b a9 10 80       	push   $0x8010a93b
801056e1:	e8 c3 ae ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801056e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056ed:	66 83 f8 01          	cmp    $0x1,%ax
801056f1:	75 25                	jne    80105718 <sys_unlink+0x117>
801056f3:	83 ec 0c             	sub    $0xc,%esp
801056f6:	ff 75 f0             	push   -0x10(%ebp)
801056f9:	e8 a0 fe ff ff       	call   8010559e <isdirempty>
801056fe:	83 c4 10             	add    $0x10,%esp
80105701:	85 c0                	test   %eax,%eax
80105703:	75 13                	jne    80105718 <sys_unlink+0x117>
    iunlockput(ip);
80105705:	83 ec 0c             	sub    $0xc,%esp
80105708:	ff 75 f0             	push   -0x10(%ebp)
8010570b:	e8 0b c5 ff ff       	call   80101c1b <iunlockput>
80105710:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105713:	e9 b5 00 00 00       	jmp    801057cd <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105718:	83 ec 04             	sub    $0x4,%esp
8010571b:	6a 10                	push   $0x10
8010571d:	6a 00                	push   $0x0
8010571f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105722:	50                   	push   %eax
80105723:	e8 9c f5 ff ff       	call   80104cc4 <memset>
80105728:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010572b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010572e:	6a 10                	push   $0x10
80105730:	50                   	push   %eax
80105731:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105734:	50                   	push   %eax
80105735:	ff 75 f4             	push   -0xc(%ebp)
80105738:	e8 ee c8 ff ff       	call   8010202b <writei>
8010573d:	83 c4 10             	add    $0x10,%esp
80105740:	83 f8 10             	cmp    $0x10,%eax
80105743:	74 0d                	je     80105752 <sys_unlink+0x151>
    panic("unlink: writei");
80105745:	83 ec 0c             	sub    $0xc,%esp
80105748:	68 4d a9 10 80       	push   $0x8010a94d
8010574d:	e8 57 ae ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105752:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105755:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105759:	66 83 f8 01          	cmp    $0x1,%ax
8010575d:	75 21                	jne    80105780 <sys_unlink+0x17f>
    dp->nlink--;
8010575f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105762:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105766:	83 e8 01             	sub    $0x1,%eax
80105769:	89 c2                	mov    %eax,%edx
8010576b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105772:	83 ec 0c             	sub    $0xc,%esp
80105775:	ff 75 f4             	push   -0xc(%ebp)
80105778:	e8 90 c0 ff ff       	call   8010180d <iupdate>
8010577d:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105780:	83 ec 0c             	sub    $0xc,%esp
80105783:	ff 75 f4             	push   -0xc(%ebp)
80105786:	e8 90 c4 ff ff       	call   80101c1b <iunlockput>
8010578b:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010578e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105791:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105795:	83 e8 01             	sub    $0x1,%eax
80105798:	89 c2                	mov    %eax,%edx
8010579a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010579d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801057a1:	83 ec 0c             	sub    $0xc,%esp
801057a4:	ff 75 f0             	push   -0x10(%ebp)
801057a7:	e8 61 c0 ff ff       	call   8010180d <iupdate>
801057ac:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801057af:	83 ec 0c             	sub    $0xc,%esp
801057b2:	ff 75 f0             	push   -0x10(%ebp)
801057b5:	e8 61 c4 ff ff       	call   80101c1b <iunlockput>
801057ba:	83 c4 10             	add    $0x10,%esp

  end_op();
801057bd:	e8 06 d9 ff ff       	call   801030c8 <end_op>

  return 0;
801057c2:	b8 00 00 00 00       	mov    $0x0,%eax
801057c7:	eb 1c                	jmp    801057e5 <sys_unlink+0x1e4>
    goto bad;
801057c9:	90                   	nop
801057ca:	eb 01                	jmp    801057cd <sys_unlink+0x1cc>
    goto bad;
801057cc:	90                   	nop

bad:
  iunlockput(dp);
801057cd:	83 ec 0c             	sub    $0xc,%esp
801057d0:	ff 75 f4             	push   -0xc(%ebp)
801057d3:	e8 43 c4 ff ff       	call   80101c1b <iunlockput>
801057d8:	83 c4 10             	add    $0x10,%esp
  end_op();
801057db:	e8 e8 d8 ff ff       	call   801030c8 <end_op>
  return -1;
801057e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057e5:	c9                   	leave  
801057e6:	c3                   	ret    

801057e7 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801057e7:	55                   	push   %ebp
801057e8:	89 e5                	mov    %esp,%ebp
801057ea:	83 ec 38             	sub    $0x38,%esp
801057ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801057f0:	8b 55 10             	mov    0x10(%ebp),%edx
801057f3:	8b 45 14             	mov    0x14(%ebp),%eax
801057f6:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801057fa:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801057fe:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105802:	83 ec 08             	sub    $0x8,%esp
80105805:	8d 45 de             	lea    -0x22(%ebp),%eax
80105808:	50                   	push   %eax
80105809:	ff 75 08             	push   0x8(%ebp)
8010580c:	e8 28 cd ff ff       	call   80102539 <nameiparent>
80105811:	83 c4 10             	add    $0x10,%esp
80105814:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105817:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010581b:	75 0a                	jne    80105827 <create+0x40>
    return 0;
8010581d:	b8 00 00 00 00       	mov    $0x0,%eax
80105822:	e9 90 01 00 00       	jmp    801059b7 <create+0x1d0>
  ilock(dp);
80105827:	83 ec 0c             	sub    $0xc,%esp
8010582a:	ff 75 f4             	push   -0xc(%ebp)
8010582d:	e8 b8 c1 ff ff       	call   801019ea <ilock>
80105832:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105835:	83 ec 04             	sub    $0x4,%esp
80105838:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010583b:	50                   	push   %eax
8010583c:	8d 45 de             	lea    -0x22(%ebp),%eax
8010583f:	50                   	push   %eax
80105840:	ff 75 f4             	push   -0xc(%ebp)
80105843:	e8 84 c9 ff ff       	call   801021cc <dirlookup>
80105848:	83 c4 10             	add    $0x10,%esp
8010584b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010584e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105852:	74 50                	je     801058a4 <create+0xbd>
    iunlockput(dp);
80105854:	83 ec 0c             	sub    $0xc,%esp
80105857:	ff 75 f4             	push   -0xc(%ebp)
8010585a:	e8 bc c3 ff ff       	call   80101c1b <iunlockput>
8010585f:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105862:	83 ec 0c             	sub    $0xc,%esp
80105865:	ff 75 f0             	push   -0x10(%ebp)
80105868:	e8 7d c1 ff ff       	call   801019ea <ilock>
8010586d:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105870:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105875:	75 15                	jne    8010588c <create+0xa5>
80105877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010587e:	66 83 f8 02          	cmp    $0x2,%ax
80105882:	75 08                	jne    8010588c <create+0xa5>
      return ip;
80105884:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105887:	e9 2b 01 00 00       	jmp    801059b7 <create+0x1d0>
    iunlockput(ip);
8010588c:	83 ec 0c             	sub    $0xc,%esp
8010588f:	ff 75 f0             	push   -0x10(%ebp)
80105892:	e8 84 c3 ff ff       	call   80101c1b <iunlockput>
80105897:	83 c4 10             	add    $0x10,%esp
    return 0;
8010589a:	b8 00 00 00 00       	mov    $0x0,%eax
8010589f:	e9 13 01 00 00       	jmp    801059b7 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801058a4:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801058a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ab:	8b 00                	mov    (%eax),%eax
801058ad:	83 ec 08             	sub    $0x8,%esp
801058b0:	52                   	push   %edx
801058b1:	50                   	push   %eax
801058b2:	e8 7f be ff ff       	call   80101736 <ialloc>
801058b7:	83 c4 10             	add    $0x10,%esp
801058ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058c1:	75 0d                	jne    801058d0 <create+0xe9>
    panic("create: ialloc");
801058c3:	83 ec 0c             	sub    $0xc,%esp
801058c6:	68 5c a9 10 80       	push   $0x8010a95c
801058cb:	e8 d9 ac ff ff       	call   801005a9 <panic>

  ilock(ip);
801058d0:	83 ec 0c             	sub    $0xc,%esp
801058d3:	ff 75 f0             	push   -0x10(%ebp)
801058d6:	e8 0f c1 ff ff       	call   801019ea <ilock>
801058db:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801058de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e1:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801058e5:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801058e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ec:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801058f0:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801058f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f7:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801058fd:	83 ec 0c             	sub    $0xc,%esp
80105900:	ff 75 f0             	push   -0x10(%ebp)
80105903:	e8 05 bf ff ff       	call   8010180d <iupdate>
80105908:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010590b:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105910:	75 6a                	jne    8010597c <create+0x195>
    dp->nlink++;  // for ".."
80105912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105915:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105919:	83 c0 01             	add    $0x1,%eax
8010591c:	89 c2                	mov    %eax,%edx
8010591e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105921:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105925:	83 ec 0c             	sub    $0xc,%esp
80105928:	ff 75 f4             	push   -0xc(%ebp)
8010592b:	e8 dd be ff ff       	call   8010180d <iupdate>
80105930:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105933:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105936:	8b 40 04             	mov    0x4(%eax),%eax
80105939:	83 ec 04             	sub    $0x4,%esp
8010593c:	50                   	push   %eax
8010593d:	68 36 a9 10 80       	push   $0x8010a936
80105942:	ff 75 f0             	push   -0x10(%ebp)
80105945:	e8 3c c9 ff ff       	call   80102286 <dirlink>
8010594a:	83 c4 10             	add    $0x10,%esp
8010594d:	85 c0                	test   %eax,%eax
8010594f:	78 1e                	js     8010596f <create+0x188>
80105951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105954:	8b 40 04             	mov    0x4(%eax),%eax
80105957:	83 ec 04             	sub    $0x4,%esp
8010595a:	50                   	push   %eax
8010595b:	68 38 a9 10 80       	push   $0x8010a938
80105960:	ff 75 f0             	push   -0x10(%ebp)
80105963:	e8 1e c9 ff ff       	call   80102286 <dirlink>
80105968:	83 c4 10             	add    $0x10,%esp
8010596b:	85 c0                	test   %eax,%eax
8010596d:	79 0d                	jns    8010597c <create+0x195>
      panic("create dots");
8010596f:	83 ec 0c             	sub    $0xc,%esp
80105972:	68 6b a9 10 80       	push   $0x8010a96b
80105977:	e8 2d ac ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010597c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597f:	8b 40 04             	mov    0x4(%eax),%eax
80105982:	83 ec 04             	sub    $0x4,%esp
80105985:	50                   	push   %eax
80105986:	8d 45 de             	lea    -0x22(%ebp),%eax
80105989:	50                   	push   %eax
8010598a:	ff 75 f4             	push   -0xc(%ebp)
8010598d:	e8 f4 c8 ff ff       	call   80102286 <dirlink>
80105992:	83 c4 10             	add    $0x10,%esp
80105995:	85 c0                	test   %eax,%eax
80105997:	79 0d                	jns    801059a6 <create+0x1bf>
    panic("create: dirlink");
80105999:	83 ec 0c             	sub    $0xc,%esp
8010599c:	68 77 a9 10 80       	push   $0x8010a977
801059a1:	e8 03 ac ff ff       	call   801005a9 <panic>

  iunlockput(dp);
801059a6:	83 ec 0c             	sub    $0xc,%esp
801059a9:	ff 75 f4             	push   -0xc(%ebp)
801059ac:	e8 6a c2 ff ff       	call   80101c1b <iunlockput>
801059b1:	83 c4 10             	add    $0x10,%esp

  return ip;
801059b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801059b7:	c9                   	leave  
801059b8:	c3                   	ret    

801059b9 <sys_open>:

int
sys_open(void)
{
801059b9:	55                   	push   %ebp
801059ba:	89 e5                	mov    %esp,%ebp
801059bc:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801059bf:	83 ec 08             	sub    $0x8,%esp
801059c2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801059c5:	50                   	push   %eax
801059c6:	6a 00                	push   $0x0
801059c8:	e8 ea f6 ff ff       	call   801050b7 <argstr>
801059cd:	83 c4 10             	add    $0x10,%esp
801059d0:	85 c0                	test   %eax,%eax
801059d2:	78 15                	js     801059e9 <sys_open+0x30>
801059d4:	83 ec 08             	sub    $0x8,%esp
801059d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801059da:	50                   	push   %eax
801059db:	6a 01                	push   $0x1
801059dd:	e8 40 f6 ff ff       	call   80105022 <argint>
801059e2:	83 c4 10             	add    $0x10,%esp
801059e5:	85 c0                	test   %eax,%eax
801059e7:	79 0a                	jns    801059f3 <sys_open+0x3a>
    return -1;
801059e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ee:	e9 61 01 00 00       	jmp    80105b54 <sys_open+0x19b>

  begin_op();
801059f3:	e8 44 d6 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
801059f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059fb:	25 00 02 00 00       	and    $0x200,%eax
80105a00:	85 c0                	test   %eax,%eax
80105a02:	74 2a                	je     80105a2e <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105a04:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a07:	6a 00                	push   $0x0
80105a09:	6a 00                	push   $0x0
80105a0b:	6a 02                	push   $0x2
80105a0d:	50                   	push   %eax
80105a0e:	e8 d4 fd ff ff       	call   801057e7 <create>
80105a13:	83 c4 10             	add    $0x10,%esp
80105a16:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105a19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a1d:	75 75                	jne    80105a94 <sys_open+0xdb>
      end_op();
80105a1f:	e8 a4 d6 ff ff       	call   801030c8 <end_op>
      return -1;
80105a24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a29:	e9 26 01 00 00       	jmp    80105b54 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105a2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a31:	83 ec 0c             	sub    $0xc,%esp
80105a34:	50                   	push   %eax
80105a35:	e8 e3 ca ff ff       	call   8010251d <namei>
80105a3a:	83 c4 10             	add    $0x10,%esp
80105a3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a44:	75 0f                	jne    80105a55 <sys_open+0x9c>
      end_op();
80105a46:	e8 7d d6 ff ff       	call   801030c8 <end_op>
      return -1;
80105a4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a50:	e9 ff 00 00 00       	jmp    80105b54 <sys_open+0x19b>
    }
    ilock(ip);
80105a55:	83 ec 0c             	sub    $0xc,%esp
80105a58:	ff 75 f4             	push   -0xc(%ebp)
80105a5b:	e8 8a bf ff ff       	call   801019ea <ilock>
80105a60:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a66:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a6a:	66 83 f8 01          	cmp    $0x1,%ax
80105a6e:	75 24                	jne    80105a94 <sys_open+0xdb>
80105a70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a73:	85 c0                	test   %eax,%eax
80105a75:	74 1d                	je     80105a94 <sys_open+0xdb>
      iunlockput(ip);
80105a77:	83 ec 0c             	sub    $0xc,%esp
80105a7a:	ff 75 f4             	push   -0xc(%ebp)
80105a7d:	e8 99 c1 ff ff       	call   80101c1b <iunlockput>
80105a82:	83 c4 10             	add    $0x10,%esp
      end_op();
80105a85:	e8 3e d6 ff ff       	call   801030c8 <end_op>
      return -1;
80105a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a8f:	e9 c0 00 00 00       	jmp    80105b54 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105a94:	e8 44 b5 ff ff       	call   80100fdd <filealloc>
80105a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105aa0:	74 17                	je     80105ab9 <sys_open+0x100>
80105aa2:	83 ec 0c             	sub    $0xc,%esp
80105aa5:	ff 75 f0             	push   -0x10(%ebp)
80105aa8:	e8 33 f7 ff ff       	call   801051e0 <fdalloc>
80105aad:	83 c4 10             	add    $0x10,%esp
80105ab0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105ab3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105ab7:	79 2e                	jns    80105ae7 <sys_open+0x12e>
    if(f)
80105ab9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105abd:	74 0e                	je     80105acd <sys_open+0x114>
      fileclose(f);
80105abf:	83 ec 0c             	sub    $0xc,%esp
80105ac2:	ff 75 f0             	push   -0x10(%ebp)
80105ac5:	e8 d1 b5 ff ff       	call   8010109b <fileclose>
80105aca:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105acd:	83 ec 0c             	sub    $0xc,%esp
80105ad0:	ff 75 f4             	push   -0xc(%ebp)
80105ad3:	e8 43 c1 ff ff       	call   80101c1b <iunlockput>
80105ad8:	83 c4 10             	add    $0x10,%esp
    end_op();
80105adb:	e8 e8 d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105ae0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae5:	eb 6d                	jmp    80105b54 <sys_open+0x19b>
  }
  iunlock(ip);
80105ae7:	83 ec 0c             	sub    $0xc,%esp
80105aea:	ff 75 f4             	push   -0xc(%ebp)
80105aed:	e8 0b c0 ff ff       	call   80101afd <iunlock>
80105af2:	83 c4 10             	add    $0x10,%esp
  end_op();
80105af5:	e8 ce d5 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105afd:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b09:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105b16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b19:	83 e0 01             	and    $0x1,%eax
80105b1c:	85 c0                	test   %eax,%eax
80105b1e:	0f 94 c0             	sete   %al
80105b21:	89 c2                	mov    %eax,%edx
80105b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b26:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105b29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b2c:	83 e0 01             	and    $0x1,%eax
80105b2f:	85 c0                	test   %eax,%eax
80105b31:	75 0a                	jne    80105b3d <sys_open+0x184>
80105b33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b36:	83 e0 02             	and    $0x2,%eax
80105b39:	85 c0                	test   %eax,%eax
80105b3b:	74 07                	je     80105b44 <sys_open+0x18b>
80105b3d:	b8 01 00 00 00       	mov    $0x1,%eax
80105b42:	eb 05                	jmp    80105b49 <sys_open+0x190>
80105b44:	b8 00 00 00 00       	mov    $0x0,%eax
80105b49:	89 c2                	mov    %eax,%edx
80105b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4e:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105b51:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105b54:	c9                   	leave  
80105b55:	c3                   	ret    

80105b56 <sys_mkdir>:

int
sys_mkdir(void)
{
80105b56:	55                   	push   %ebp
80105b57:	89 e5                	mov    %esp,%ebp
80105b59:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105b5c:	e8 db d4 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105b61:	83 ec 08             	sub    $0x8,%esp
80105b64:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b67:	50                   	push   %eax
80105b68:	6a 00                	push   $0x0
80105b6a:	e8 48 f5 ff ff       	call   801050b7 <argstr>
80105b6f:	83 c4 10             	add    $0x10,%esp
80105b72:	85 c0                	test   %eax,%eax
80105b74:	78 1b                	js     80105b91 <sys_mkdir+0x3b>
80105b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b79:	6a 00                	push   $0x0
80105b7b:	6a 00                	push   $0x0
80105b7d:	6a 01                	push   $0x1
80105b7f:	50                   	push   %eax
80105b80:	e8 62 fc ff ff       	call   801057e7 <create>
80105b85:	83 c4 10             	add    $0x10,%esp
80105b88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b8f:	75 0c                	jne    80105b9d <sys_mkdir+0x47>
    end_op();
80105b91:	e8 32 d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105b96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9b:	eb 18                	jmp    80105bb5 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105b9d:	83 ec 0c             	sub    $0xc,%esp
80105ba0:	ff 75 f4             	push   -0xc(%ebp)
80105ba3:	e8 73 c0 ff ff       	call   80101c1b <iunlockput>
80105ba8:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bab:	e8 18 d5 ff ff       	call   801030c8 <end_op>
  return 0;
80105bb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bb5:	c9                   	leave  
80105bb6:	c3                   	ret    

80105bb7 <sys_mknod>:

int
sys_mknod(void)
{
80105bb7:	55                   	push   %ebp
80105bb8:	89 e5                	mov    %esp,%ebp
80105bba:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105bbd:	e8 7a d4 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105bc2:	83 ec 08             	sub    $0x8,%esp
80105bc5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bc8:	50                   	push   %eax
80105bc9:	6a 00                	push   $0x0
80105bcb:	e8 e7 f4 ff ff       	call   801050b7 <argstr>
80105bd0:	83 c4 10             	add    $0x10,%esp
80105bd3:	85 c0                	test   %eax,%eax
80105bd5:	78 4f                	js     80105c26 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105bd7:	83 ec 08             	sub    $0x8,%esp
80105bda:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bdd:	50                   	push   %eax
80105bde:	6a 01                	push   $0x1
80105be0:	e8 3d f4 ff ff       	call   80105022 <argint>
80105be5:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105be8:	85 c0                	test   %eax,%eax
80105bea:	78 3a                	js     80105c26 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105bec:	83 ec 08             	sub    $0x8,%esp
80105bef:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105bf2:	50                   	push   %eax
80105bf3:	6a 02                	push   $0x2
80105bf5:	e8 28 f4 ff ff       	call   80105022 <argint>
80105bfa:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105bfd:	85 c0                	test   %eax,%eax
80105bff:	78 25                	js     80105c26 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c04:	0f bf c8             	movswl %ax,%ecx
80105c07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c0a:	0f bf d0             	movswl %ax,%edx
80105c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c10:	51                   	push   %ecx
80105c11:	52                   	push   %edx
80105c12:	6a 03                	push   $0x3
80105c14:	50                   	push   %eax
80105c15:	e8 cd fb ff ff       	call   801057e7 <create>
80105c1a:	83 c4 10             	add    $0x10,%esp
80105c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105c20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c24:	75 0c                	jne    80105c32 <sys_mknod+0x7b>
    end_op();
80105c26:	e8 9d d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105c2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c30:	eb 18                	jmp    80105c4a <sys_mknod+0x93>
  }
  iunlockput(ip);
80105c32:	83 ec 0c             	sub    $0xc,%esp
80105c35:	ff 75 f4             	push   -0xc(%ebp)
80105c38:	e8 de bf ff ff       	call   80101c1b <iunlockput>
80105c3d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c40:	e8 83 d4 ff ff       	call   801030c8 <end_op>
  return 0;
80105c45:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c4a:	c9                   	leave  
80105c4b:	c3                   	ret    

80105c4c <sys_chdir>:

int
sys_chdir(void)
{
80105c4c:	55                   	push   %ebp
80105c4d:	89 e5                	mov    %esp,%ebp
80105c4f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105c52:	e8 75 de ff ff       	call   80103acc <myproc>
80105c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105c5a:	e8 dd d3 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105c5f:	83 ec 08             	sub    $0x8,%esp
80105c62:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c65:	50                   	push   %eax
80105c66:	6a 00                	push   $0x0
80105c68:	e8 4a f4 ff ff       	call   801050b7 <argstr>
80105c6d:	83 c4 10             	add    $0x10,%esp
80105c70:	85 c0                	test   %eax,%eax
80105c72:	78 18                	js     80105c8c <sys_chdir+0x40>
80105c74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c77:	83 ec 0c             	sub    $0xc,%esp
80105c7a:	50                   	push   %eax
80105c7b:	e8 9d c8 ff ff       	call   8010251d <namei>
80105c80:	83 c4 10             	add    $0x10,%esp
80105c83:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c86:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c8a:	75 0c                	jne    80105c98 <sys_chdir+0x4c>
    end_op();
80105c8c:	e8 37 d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105c91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c96:	eb 68                	jmp    80105d00 <sys_chdir+0xb4>
  }
  ilock(ip);
80105c98:	83 ec 0c             	sub    $0xc,%esp
80105c9b:	ff 75 f0             	push   -0x10(%ebp)
80105c9e:	e8 47 bd ff ff       	call   801019ea <ilock>
80105ca3:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cad:	66 83 f8 01          	cmp    $0x1,%ax
80105cb1:	74 1a                	je     80105ccd <sys_chdir+0x81>
    iunlockput(ip);
80105cb3:	83 ec 0c             	sub    $0xc,%esp
80105cb6:	ff 75 f0             	push   -0x10(%ebp)
80105cb9:	e8 5d bf ff ff       	call   80101c1b <iunlockput>
80105cbe:	83 c4 10             	add    $0x10,%esp
    end_op();
80105cc1:	e8 02 d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105cc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccb:	eb 33                	jmp    80105d00 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105ccd:	83 ec 0c             	sub    $0xc,%esp
80105cd0:	ff 75 f0             	push   -0x10(%ebp)
80105cd3:	e8 25 be ff ff       	call   80101afd <iunlock>
80105cd8:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cde:	8b 40 68             	mov    0x68(%eax),%eax
80105ce1:	83 ec 0c             	sub    $0xc,%esp
80105ce4:	50                   	push   %eax
80105ce5:	e8 61 be ff ff       	call   80101b4b <iput>
80105cea:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ced:	e8 d6 d3 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cf8:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105cfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d00:	c9                   	leave  
80105d01:	c3                   	ret    

80105d02 <sys_exec>:

int
sys_exec(void)
{
80105d02:	55                   	push   %ebp
80105d03:	89 e5                	mov    %esp,%ebp
80105d05:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105d0b:	83 ec 08             	sub    $0x8,%esp
80105d0e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d11:	50                   	push   %eax
80105d12:	6a 00                	push   $0x0
80105d14:	e8 9e f3 ff ff       	call   801050b7 <argstr>
80105d19:	83 c4 10             	add    $0x10,%esp
80105d1c:	85 c0                	test   %eax,%eax
80105d1e:	78 18                	js     80105d38 <sys_exec+0x36>
80105d20:	83 ec 08             	sub    $0x8,%esp
80105d23:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105d29:	50                   	push   %eax
80105d2a:	6a 01                	push   $0x1
80105d2c:	e8 f1 f2 ff ff       	call   80105022 <argint>
80105d31:	83 c4 10             	add    $0x10,%esp
80105d34:	85 c0                	test   %eax,%eax
80105d36:	79 0a                	jns    80105d42 <sys_exec+0x40>
    return -1;
80105d38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d3d:	e9 c6 00 00 00       	jmp    80105e08 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105d42:	83 ec 04             	sub    $0x4,%esp
80105d45:	68 80 00 00 00       	push   $0x80
80105d4a:	6a 00                	push   $0x0
80105d4c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105d52:	50                   	push   %eax
80105d53:	e8 6c ef ff ff       	call   80104cc4 <memset>
80105d58:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105d5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d65:	83 f8 1f             	cmp    $0x1f,%eax
80105d68:	76 0a                	jbe    80105d74 <sys_exec+0x72>
      return -1;
80105d6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6f:	e9 94 00 00 00       	jmp    80105e08 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d77:	c1 e0 02             	shl    $0x2,%eax
80105d7a:	89 c2                	mov    %eax,%edx
80105d7c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105d82:	01 c2                	add    %eax,%edx
80105d84:	83 ec 08             	sub    $0x8,%esp
80105d87:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105d8d:	50                   	push   %eax
80105d8e:	52                   	push   %edx
80105d8f:	e8 ba f1 ff ff       	call   80104f4e <fetchint>
80105d94:	83 c4 10             	add    $0x10,%esp
80105d97:	85 c0                	test   %eax,%eax
80105d99:	79 07                	jns    80105da2 <sys_exec+0xa0>
      return -1;
80105d9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da0:	eb 66                	jmp    80105e08 <sys_exec+0x106>
    if(uarg == 0){
80105da2:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105da8:	85 c0                	test   %eax,%eax
80105daa:	75 27                	jne    80105dd3 <sys_exec+0xd1>
      argv[i] = 0;
80105dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daf:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105db6:	00 00 00 00 
      break;
80105dba:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbe:	83 ec 08             	sub    $0x8,%esp
80105dc1:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105dc7:	52                   	push   %edx
80105dc8:	50                   	push   %eax
80105dc9:	e8 b2 ad ff ff       	call   80100b80 <exec>
80105dce:	83 c4 10             	add    $0x10,%esp
80105dd1:	eb 35                	jmp    80105e08 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105dd3:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddc:	c1 e0 02             	shl    $0x2,%eax
80105ddf:	01 c2                	add    %eax,%edx
80105de1:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105de7:	83 ec 08             	sub    $0x8,%esp
80105dea:	52                   	push   %edx
80105deb:	50                   	push   %eax
80105dec:	e8 cf f1 ff ff       	call   80104fc0 <fetchstr>
80105df1:	83 c4 10             	add    $0x10,%esp
80105df4:	85 c0                	test   %eax,%eax
80105df6:	79 07                	jns    80105dff <sys_exec+0xfd>
      return -1;
80105df8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfd:	eb 09                	jmp    80105e08 <sys_exec+0x106>
  for(i=0;; i++){
80105dff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e03:	e9 5a ff ff ff       	jmp    80105d62 <sys_exec+0x60>
}
80105e08:	c9                   	leave  
80105e09:	c3                   	ret    

80105e0a <sys_pipe>:

int
sys_pipe(void)
{
80105e0a:	55                   	push   %ebp
80105e0b:	89 e5                	mov    %esp,%ebp
80105e0d:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105e10:	83 ec 04             	sub    $0x4,%esp
80105e13:	6a 08                	push   $0x8
80105e15:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e18:	50                   	push   %eax
80105e19:	6a 00                	push   $0x0
80105e1b:	e8 2f f2 ff ff       	call   8010504f <argptr>
80105e20:	83 c4 10             	add    $0x10,%esp
80105e23:	85 c0                	test   %eax,%eax
80105e25:	79 0a                	jns    80105e31 <sys_pipe+0x27>
    return -1;
80105e27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2c:	e9 ae 00 00 00       	jmp    80105edf <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105e31:	83 ec 08             	sub    $0x8,%esp
80105e34:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e37:	50                   	push   %eax
80105e38:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e3b:	50                   	push   %eax
80105e3c:	e8 2c d7 ff ff       	call   8010356d <pipealloc>
80105e41:	83 c4 10             	add    $0x10,%esp
80105e44:	85 c0                	test   %eax,%eax
80105e46:	79 0a                	jns    80105e52 <sys_pipe+0x48>
    return -1;
80105e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e4d:	e9 8d 00 00 00       	jmp    80105edf <sys_pipe+0xd5>
  fd0 = -1;
80105e52:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105e59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e5c:	83 ec 0c             	sub    $0xc,%esp
80105e5f:	50                   	push   %eax
80105e60:	e8 7b f3 ff ff       	call   801051e0 <fdalloc>
80105e65:	83 c4 10             	add    $0x10,%esp
80105e68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e6b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e6f:	78 18                	js     80105e89 <sys_pipe+0x7f>
80105e71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e74:	83 ec 0c             	sub    $0xc,%esp
80105e77:	50                   	push   %eax
80105e78:	e8 63 f3 ff ff       	call   801051e0 <fdalloc>
80105e7d:	83 c4 10             	add    $0x10,%esp
80105e80:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e87:	79 3e                	jns    80105ec7 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105e89:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e8d:	78 13                	js     80105ea2 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105e8f:	e8 38 dc ff ff       	call   80103acc <myproc>
80105e94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e97:	83 c2 08             	add    $0x8,%edx
80105e9a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ea1:	00 
    fileclose(rf);
80105ea2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ea5:	83 ec 0c             	sub    $0xc,%esp
80105ea8:	50                   	push   %eax
80105ea9:	e8 ed b1 ff ff       	call   8010109b <fileclose>
80105eae:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105eb4:	83 ec 0c             	sub    $0xc,%esp
80105eb7:	50                   	push   %eax
80105eb8:	e8 de b1 ff ff       	call   8010109b <fileclose>
80105ebd:	83 c4 10             	add    $0x10,%esp
    return -1;
80105ec0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec5:	eb 18                	jmp    80105edf <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105ec7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105eca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ecd:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105ecf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ed2:	8d 50 04             	lea    0x4(%eax),%edx
80105ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed8:	89 02                	mov    %eax,(%edx)
  return 0;
80105eda:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105edf:	c9                   	leave  
80105ee0:	c3                   	ret    

80105ee1 <sys_fork>:
  struct proc proc[NPROC];
} ptable;

int
sys_fork(void)
{
80105ee1:	55                   	push   %ebp
80105ee2:	89 e5                	mov    %esp,%ebp
80105ee4:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105ee7:	e8 1a df ff ff       	call   80103e06 <fork>
}
80105eec:	c9                   	leave  
80105eed:	c3                   	ret    

80105eee <sys_exit>:

int
sys_exit(void)
{
80105eee:	55                   	push   %ebp
80105eef:	89 e5                	mov    %esp,%ebp
80105ef1:	83 ec 08             	sub    $0x8,%esp
  exit();
80105ef4:	e8 86 e0 ff ff       	call   80103f7f <exit>
  return 0;  // not reached
80105ef9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105efe:	c9                   	leave  
80105eff:	c3                   	ret    

80105f00 <sys_wait>:

int
sys_wait(void)
{
80105f00:	55                   	push   %ebp
80105f01:	89 e5                	mov    %esp,%ebp
80105f03:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105f06:	e8 97 e1 ff ff       	call   801040a2 <wait>
}
80105f0b:	c9                   	leave  
80105f0c:	c3                   	ret    

80105f0d <sys_kill>:

int
sys_kill(void)
{
80105f0d:	55                   	push   %ebp
80105f0e:	89 e5                	mov    %esp,%ebp
80105f10:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105f13:	83 ec 08             	sub    $0x8,%esp
80105f16:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f19:	50                   	push   %eax
80105f1a:	6a 00                	push   $0x0
80105f1c:	e8 01 f1 ff ff       	call   80105022 <argint>
80105f21:	83 c4 10             	add    $0x10,%esp
80105f24:	85 c0                	test   %eax,%eax
80105f26:	79 07                	jns    80105f2f <sys_kill+0x22>
    return -1;
80105f28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f2d:	eb 0f                	jmp    80105f3e <sys_kill+0x31>
  return kill(pid);
80105f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f32:	83 ec 0c             	sub    $0xc,%esp
80105f35:	50                   	push   %eax
80105f36:	e8 10 e8 ff ff       	call   8010474b <kill>
80105f3b:	83 c4 10             	add    $0x10,%esp
}
80105f3e:	c9                   	leave  
80105f3f:	c3                   	ret    

80105f40 <sys_getpid>:

int
sys_getpid(void)
{
80105f40:	55                   	push   %ebp
80105f41:	89 e5                	mov    %esp,%ebp
80105f43:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105f46:	e8 81 db ff ff       	call   80103acc <myproc>
80105f4b:	8b 40 10             	mov    0x10(%eax),%eax
}
80105f4e:	c9                   	leave  
80105f4f:	c3                   	ret    

80105f50 <sys_sbrk>:

int
sys_sbrk(void)
{
80105f50:	55                   	push   %ebp
80105f51:	89 e5                	mov    %esp,%ebp
80105f53:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105f56:	83 ec 08             	sub    $0x8,%esp
80105f59:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f5c:	50                   	push   %eax
80105f5d:	6a 00                	push   $0x0
80105f5f:	e8 be f0 ff ff       	call   80105022 <argint>
80105f64:	83 c4 10             	add    $0x10,%esp
80105f67:	85 c0                	test   %eax,%eax
80105f69:	79 07                	jns    80105f72 <sys_sbrk+0x22>
    return -1;
80105f6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f70:	eb 27                	jmp    80105f99 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105f72:	e8 55 db ff ff       	call   80103acc <myproc>
80105f77:	8b 00                	mov    (%eax),%eax
80105f79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7f:	83 ec 0c             	sub    $0xc,%esp
80105f82:	50                   	push   %eax
80105f83:	e8 e3 dd ff ff       	call   80103d6b <growproc>
80105f88:	83 c4 10             	add    $0x10,%esp
80105f8b:	85 c0                	test   %eax,%eax
80105f8d:	79 07                	jns    80105f96 <sys_sbrk+0x46>
    return -1;
80105f8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f94:	eb 03                	jmp    80105f99 <sys_sbrk+0x49>
  return addr;
80105f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f99:	c9                   	leave  
80105f9a:	c3                   	ret    

80105f9b <sys_sleep>:

int
sys_sleep(void)
{
80105f9b:	55                   	push   %ebp
80105f9c:	89 e5                	mov    %esp,%ebp
80105f9e:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105fa1:	83 ec 08             	sub    $0x8,%esp
80105fa4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fa7:	50                   	push   %eax
80105fa8:	6a 00                	push   $0x0
80105faa:	e8 73 f0 ff ff       	call   80105022 <argint>
80105faf:	83 c4 10             	add    $0x10,%esp
80105fb2:	85 c0                	test   %eax,%eax
80105fb4:	79 07                	jns    80105fbd <sys_sleep+0x22>
    return -1;
80105fb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fbb:	eb 76                	jmp    80106033 <sys_sleep+0x98>
  acquire(&tickslock);
80105fbd:	83 ec 0c             	sub    $0xc,%esp
80105fc0:	68 40 72 19 80       	push   $0x80197240
80105fc5:	e8 84 ea ff ff       	call   80104a4e <acquire>
80105fca:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105fcd:	a1 74 72 19 80       	mov    0x80197274,%eax
80105fd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105fd5:	eb 38                	jmp    8010600f <sys_sleep+0x74>
    if(myproc()->killed){
80105fd7:	e8 f0 da ff ff       	call   80103acc <myproc>
80105fdc:	8b 40 24             	mov    0x24(%eax),%eax
80105fdf:	85 c0                	test   %eax,%eax
80105fe1:	74 17                	je     80105ffa <sys_sleep+0x5f>
      release(&tickslock);
80105fe3:	83 ec 0c             	sub    $0xc,%esp
80105fe6:	68 40 72 19 80       	push   $0x80197240
80105feb:	e8 cc ea ff ff       	call   80104abc <release>
80105ff0:	83 c4 10             	add    $0x10,%esp
      return -1;
80105ff3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff8:	eb 39                	jmp    80106033 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105ffa:	83 ec 08             	sub    $0x8,%esp
80105ffd:	68 40 72 19 80       	push   $0x80197240
80106002:	68 74 72 19 80       	push   $0x80197274
80106007:	e8 1e e6 ff ff       	call   8010462a <sleep>
8010600c:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010600f:	a1 74 72 19 80       	mov    0x80197274,%eax
80106014:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106017:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010601a:	39 d0                	cmp    %edx,%eax
8010601c:	72 b9                	jb     80105fd7 <sys_sleep+0x3c>
  }
  release(&tickslock);
8010601e:	83 ec 0c             	sub    $0xc,%esp
80106021:	68 40 72 19 80       	push   $0x80197240
80106026:	e8 91 ea ff ff       	call   80104abc <release>
8010602b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010602e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106033:	c9                   	leave  
80106034:	c3                   	ret    

80106035 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106035:	55                   	push   %ebp
80106036:	89 e5                	mov    %esp,%ebp
80106038:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010603b:	83 ec 0c             	sub    $0xc,%esp
8010603e:	68 40 72 19 80       	push   $0x80197240
80106043:	e8 06 ea ff ff       	call   80104a4e <acquire>
80106048:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010604b:	a1 74 72 19 80       	mov    0x80197274,%eax
80106050:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106053:	83 ec 0c             	sub    $0xc,%esp
80106056:	68 40 72 19 80       	push   $0x80197240
8010605b:	e8 5c ea ff ff       	call   80104abc <release>
80106060:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106063:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106066:	c9                   	leave  
80106067:	c3                   	ret    

80106068 <sys_getpinfo>:

int 
sys_getpinfo(void)
{
80106068:	55                   	push   %ebp
80106069:	89 e5                	mov    %esp,%ebp
8010606b:	53                   	push   %ebx
8010606c:	83 ec 14             	sub    $0x14,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(*ps)) < 0)
8010606f:	83 ec 04             	sub    $0x4,%esp
80106072:	68 00 0c 00 00       	push   $0xc00
80106077:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010607a:	50                   	push   %eax
8010607b:	6a 00                	push   $0x0
8010607d:	e8 cd ef ff ff       	call   8010504f <argptr>
80106082:	83 c4 10             	add    $0x10,%esp
80106085:	85 c0                	test   %eax,%eax
80106087:	79 0a                	jns    80106093 <sys_getpinfo+0x2b>
    return -1;
80106089:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010608e:	e9 0d 01 00 00       	jmp    801061a0 <sys_getpinfo+0x138>

  acquire(&ptable.lock);
80106093:	83 ec 0c             	sub    $0xc,%esp
80106096:	68 00 42 19 80       	push   $0x80194200
8010609b:	e8 ae e9 ff ff       	call   80104a4e <acquire>
801060a0:	83 c4 10             	add    $0x10,%esp
  
  for (int i = 0; i < NPROC; i++) {
801060a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801060aa:	e9 d2 00 00 00       	jmp    80106181 <sys_getpinfo+0x119>
    struct proc *p = &ptable.proc[i];
801060af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060b2:	89 d0                	mov    %edx,%eax
801060b4:	c1 e0 02             	shl    $0x2,%eax
801060b7:	01 d0                	add    %edx,%eax
801060b9:	c1 e0 05             	shl    $0x5,%eax
801060bc:	83 c0 30             	add    $0x30,%eax
801060bf:	05 00 42 19 80       	add    $0x80194200,%eax
801060c4:	83 c0 04             	add    $0x4,%eax
801060c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ps->inuse[i] = (p->state != UNUSED);
801060ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801060cd:	8b 40 0c             	mov    0xc(%eax),%eax
801060d0:	85 c0                	test   %eax,%eax
801060d2:	0f 95 c2             	setne  %dl
801060d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060d8:	0f b6 ca             	movzbl %dl,%ecx
801060db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060de:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
801060e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060e4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801060e7:	8b 52 10             	mov    0x10(%edx),%edx
801060ea:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801060ed:	83 c1 40             	add    $0x40,%ecx
801060f0:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = p->priority;
801060f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060f6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801060f9:	8b 52 7c             	mov    0x7c(%edx),%edx
801060fc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801060ff:	83 e9 80             	sub    $0xffffff80,%ecx
80106102:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
80106105:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106108:	8b 50 0c             	mov    0xc(%eax),%edx
8010610b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010610e:	89 d1                	mov    %edx,%ecx
80106110:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106113:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80106119:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
8010611c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106123:	eb 52                	jmp    80106177 <sys_getpinfo+0x10f>
      ps->ticks[i][j] = p->ticks[j];
80106125:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106128:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010612b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010612e:	83 c1 20             	add    $0x20,%ecx
80106131:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80106134:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106137:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
8010613e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106141:	01 d9                	add    %ebx,%ecx
80106143:	81 c1 00 01 00 00    	add    $0x100,%ecx
80106149:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
8010614c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010614f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106152:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106155:	83 c1 24             	add    $0x24,%ecx
80106158:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
8010615b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010615e:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80106165:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106168:	01 d9                	add    %ebx,%ecx
8010616a:	81 c1 00 02 00 00    	add    $0x200,%ecx
80106170:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80106173:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106177:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010617b:	7e a8                	jle    80106125 <sys_getpinfo+0xbd>
  for (int i = 0; i < NPROC; i++) {
8010617d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106181:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80106185:	0f 8e 24 ff ff ff    	jle    801060af <sys_getpinfo+0x47>
    }

  }
  release(&ptable.lock);
8010618b:	83 ec 0c             	sub    $0xc,%esp
8010618e:	68 00 42 19 80       	push   $0x80194200
80106193:	e8 24 e9 ff ff       	call   80104abc <release>
80106198:	83 c4 10             	add    $0x10,%esp

  return 0;
8010619b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801061a3:	c9                   	leave  
801061a4:	c3                   	ret    

801061a5 <sys_setSchedPolicy>:

int 
sys_setSchedPolicy(void)
{
801061a5:	55                   	push   %ebp
801061a6:	89 e5                	mov    %esp,%ebp
801061a8:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
801061ab:	83 ec 08             	sub    $0x8,%esp
801061ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061b1:	50                   	push   %eax
801061b2:	6a 00                	push   $0x0
801061b4:	e8 69 ee ff ff       	call   80105022 <argint>
801061b9:	83 c4 10             	add    $0x10,%esp
801061bc:	85 c0                	test   %eax,%eax
801061be:	79 07                	jns    801061c7 <sys_setSchedPolicy+0x22>
    return -1;
801061c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c5:	eb 1d                	jmp    801061e4 <sys_setSchedPolicy+0x3f>

  pushcli();  // 인터럽트 끔
801061c7:	e8 ed e9 ff ff       	call   80104bb9 <pushcli>
  mycpu()->sched_policy = policy;
801061cc:	e8 83 d8 ff ff       	call   80103a54 <mycpu>
801061d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061d4:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();   // 인터럽트 켬
801061da:	e8 27 ea ff ff       	call   80104c06 <popcli>
  return 0;
801061df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061e4:	c9                   	leave  
801061e5:	c3                   	ret    

801061e6 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801061e6:	1e                   	push   %ds
  pushl %es
801061e7:	06                   	push   %es
  pushl %fs
801061e8:	0f a0                	push   %fs
  pushl %gs
801061ea:	0f a8                	push   %gs
  pushal
801061ec:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801061ed:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801061f1:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801061f3:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801061f5:	54                   	push   %esp
  call trap
801061f6:	e8 d7 01 00 00       	call   801063d2 <trap>
  addl $4, %esp
801061fb:	83 c4 04             	add    $0x4,%esp

801061fe <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801061fe:	61                   	popa   
  popl %gs
801061ff:	0f a9                	pop    %gs
  popl %fs
80106201:	0f a1                	pop    %fs
  popl %es
80106203:	07                   	pop    %es
  popl %ds
80106204:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106205:	83 c4 08             	add    $0x8,%esp
  iret
80106208:	cf                   	iret   

80106209 <lidt>:
{
80106209:	55                   	push   %ebp
8010620a:	89 e5                	mov    %esp,%ebp
8010620c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010620f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106212:	83 e8 01             	sub    $0x1,%eax
80106215:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106219:	8b 45 08             	mov    0x8(%ebp),%eax
8010621c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106220:	8b 45 08             	mov    0x8(%ebp),%eax
80106223:	c1 e8 10             	shr    $0x10,%eax
80106226:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010622a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010622d:	0f 01 18             	lidtl  (%eax)
}
80106230:	90                   	nop
80106231:	c9                   	leave  
80106232:	c3                   	ret    

80106233 <rcr2>:

static inline uint
rcr2(void)
{
80106233:	55                   	push   %ebp
80106234:	89 e5                	mov    %esp,%ebp
80106236:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106239:	0f 20 d0             	mov    %cr2,%eax
8010623c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010623f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106242:	c9                   	leave  
80106243:	c3                   	ret    

80106244 <tvinit>:
  struct proc proc[NPROC];
} ptable;

void
tvinit(void)
{
80106244:	55                   	push   %ebp
80106245:	89 e5                	mov    %esp,%ebp
80106247:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010624a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106251:	e9 c3 00 00 00       	jmp    80106319 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106259:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80106260:	89 c2                	mov    %eax,%edx
80106262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106265:	66 89 14 c5 40 6a 19 	mov    %dx,-0x7fe695c0(,%eax,8)
8010626c:	80 
8010626d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106270:	66 c7 04 c5 42 6a 19 	movw   $0x8,-0x7fe695be(,%eax,8)
80106277:	80 08 00 
8010627a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627d:	0f b6 14 c5 44 6a 19 	movzbl -0x7fe695bc(,%eax,8),%edx
80106284:	80 
80106285:	83 e2 e0             	and    $0xffffffe0,%edx
80106288:	88 14 c5 44 6a 19 80 	mov    %dl,-0x7fe695bc(,%eax,8)
8010628f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106292:	0f b6 14 c5 44 6a 19 	movzbl -0x7fe695bc(,%eax,8),%edx
80106299:	80 
8010629a:	83 e2 1f             	and    $0x1f,%edx
8010629d:	88 14 c5 44 6a 19 80 	mov    %dl,-0x7fe695bc(,%eax,8)
801062a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a7:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
801062ae:	80 
801062af:	83 e2 f0             	and    $0xfffffff0,%edx
801062b2:	83 ca 0e             	or     $0xe,%edx
801062b5:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
801062bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bf:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
801062c6:	80 
801062c7:	83 e2 ef             	and    $0xffffffef,%edx
801062ca:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
801062d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d4:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
801062db:	80 
801062dc:	83 e2 9f             	and    $0xffffff9f,%edx
801062df:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
801062e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e9:	0f b6 14 c5 45 6a 19 	movzbl -0x7fe695bb(,%eax,8),%edx
801062f0:	80 
801062f1:	83 ca 80             	or     $0xffffff80,%edx
801062f4:	88 14 c5 45 6a 19 80 	mov    %dl,-0x7fe695bb(,%eax,8)
801062fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062fe:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80106305:	c1 e8 10             	shr    $0x10,%eax
80106308:	89 c2                	mov    %eax,%edx
8010630a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630d:	66 89 14 c5 46 6a 19 	mov    %dx,-0x7fe695ba(,%eax,8)
80106314:	80 
  for(i = 0; i < 256; i++)
80106315:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106319:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106320:	0f 8e 30 ff ff ff    	jle    80106256 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106326:	a1 84 f1 10 80       	mov    0x8010f184,%eax
8010632b:	66 a3 40 6c 19 80    	mov    %ax,0x80196c40
80106331:	66 c7 05 42 6c 19 80 	movw   $0x8,0x80196c42
80106338:	08 00 
8010633a:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
80106341:	83 e0 e0             	and    $0xffffffe0,%eax
80106344:	a2 44 6c 19 80       	mov    %al,0x80196c44
80106349:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
80106350:	83 e0 1f             	and    $0x1f,%eax
80106353:	a2 44 6c 19 80       	mov    %al,0x80196c44
80106358:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
8010635f:	83 c8 0f             	or     $0xf,%eax
80106362:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106367:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
8010636e:	83 e0 ef             	and    $0xffffffef,%eax
80106371:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106376:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
8010637d:	83 c8 60             	or     $0x60,%eax
80106380:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106385:	0f b6 05 45 6c 19 80 	movzbl 0x80196c45,%eax
8010638c:	83 c8 80             	or     $0xffffff80,%eax
8010638f:	a2 45 6c 19 80       	mov    %al,0x80196c45
80106394:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80106399:	c1 e8 10             	shr    $0x10,%eax
8010639c:	66 a3 46 6c 19 80    	mov    %ax,0x80196c46

  initlock(&tickslock, "time");
801063a2:	83 ec 08             	sub    $0x8,%esp
801063a5:	68 88 a9 10 80       	push   $0x8010a988
801063aa:	68 40 72 19 80       	push   $0x80197240
801063af:	e8 78 e6 ff ff       	call   80104a2c <initlock>
801063b4:	83 c4 10             	add    $0x10,%esp
}
801063b7:	90                   	nop
801063b8:	c9                   	leave  
801063b9:	c3                   	ret    

801063ba <idtinit>:

void
idtinit(void)
{
801063ba:	55                   	push   %ebp
801063bb:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801063bd:	68 00 08 00 00       	push   $0x800
801063c2:	68 40 6a 19 80       	push   $0x80196a40
801063c7:	e8 3d fe ff ff       	call   80106209 <lidt>
801063cc:	83 c4 08             	add    $0x8,%esp
}
801063cf:	90                   	nop
801063d0:	c9                   	leave  
801063d1:	c3                   	ret    

801063d2 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801063d2:	55                   	push   %ebp
801063d3:	89 e5                	mov    %esp,%ebp
801063d5:	57                   	push   %edi
801063d6:	56                   	push   %esi
801063d7:	53                   	push   %ebx
801063d8:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801063db:	8b 45 08             	mov    0x8(%ebp),%eax
801063de:	8b 40 30             	mov    0x30(%eax),%eax
801063e1:	83 f8 40             	cmp    $0x40,%eax
801063e4:	75 3b                	jne    80106421 <trap+0x4f>
    if(myproc()->killed)
801063e6:	e8 e1 d6 ff ff       	call   80103acc <myproc>
801063eb:	8b 40 24             	mov    0x24(%eax),%eax
801063ee:	85 c0                	test   %eax,%eax
801063f0:	74 05                	je     801063f7 <trap+0x25>
      exit();
801063f2:	e8 88 db ff ff       	call   80103f7f <exit>
    myproc()->tf = tf;
801063f7:	e8 d0 d6 ff ff       	call   80103acc <myproc>
801063fc:	8b 55 08             	mov    0x8(%ebp),%edx
801063ff:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106402:	e8 e7 ec ff ff       	call   801050ee <syscall>
    if(myproc()->killed)
80106407:	e8 c0 d6 ff ff       	call   80103acc <myproc>
8010640c:	8b 40 24             	mov    0x24(%eax),%eax
8010640f:	85 c0                	test   %eax,%eax
80106411:	0f 84 a5 02 00 00    	je     801066bc <trap+0x2ea>
      exit();
80106417:	e8 63 db ff ff       	call   80103f7f <exit>
    return;
8010641c:	e9 9b 02 00 00       	jmp    801066bc <trap+0x2ea>
  }

  switch(tf->trapno){
80106421:	8b 45 08             	mov    0x8(%ebp),%eax
80106424:	8b 40 30             	mov    0x30(%eax),%eax
80106427:	83 e8 20             	sub    $0x20,%eax
8010642a:	83 f8 1f             	cmp    $0x1f,%eax
8010642d:	0f 87 54 01 00 00    	ja     80106587 <trap+0x1b5>
80106433:	8b 04 85 30 aa 10 80 	mov    -0x7fef55d0(,%eax,4),%eax
8010643a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010643c:	e8 f8 d5 ff ff       	call   80103a39 <cpuid>
80106441:	85 c0                	test   %eax,%eax
80106443:	75 3d                	jne    80106482 <trap+0xb0>
      acquire(&tickslock);
80106445:	83 ec 0c             	sub    $0xc,%esp
80106448:	68 40 72 19 80       	push   $0x80197240
8010644d:	e8 fc e5 ff ff       	call   80104a4e <acquire>
80106452:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106455:	a1 74 72 19 80       	mov    0x80197274,%eax
8010645a:	83 c0 01             	add    $0x1,%eax
8010645d:	a3 74 72 19 80       	mov    %eax,0x80197274
      wakeup(&ticks);
80106462:	83 ec 0c             	sub    $0xc,%esp
80106465:	68 74 72 19 80       	push   $0x80197274
8010646a:	e8 a5 e2 ff ff       	call   80104714 <wakeup>
8010646f:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106472:	83 ec 0c             	sub    $0xc,%esp
80106475:	68 40 72 19 80       	push   $0x80197240
8010647a:	e8 3d e6 ff ff       	call   80104abc <release>
8010647f:	83 c4 10             	add    $0x10,%esp
    }

    struct proc *cp = myproc();
80106482:	e8 45 d6 ff ff       	call   80103acc <myproc>
80106487:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (cp) {
8010648a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010648e:	74 1b                	je     801064ab <trap+0xd9>
      // 현재 실행 중인 프로세스의 실행 시간 누적
      cp->ticks[cp->priority]++;
80106490:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106493:	8b 40 7c             	mov    0x7c(%eax),%eax
80106496:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106499:	8d 48 20             	lea    0x20(%eax),%ecx
8010649c:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
8010649f:	8d 4a 01             	lea    0x1(%edx),%ecx
801064a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801064a5:	83 c0 20             	add    $0x20,%eax
801064a8:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    }
  
    // 나머지 RUNNABLE 프로세스들의 대기 시간 누적
    acquire(&ptable.lock);
801064ab:	83 ec 0c             	sub    $0xc,%esp
801064ae:	68 00 42 19 80       	push   $0x80194200
801064b3:	e8 96 e5 ff ff       	call   80104a4e <acquire>
801064b8:	83 c4 10             	add    $0x10,%esp
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801064bb:	c7 45 e4 34 42 19 80 	movl   $0x80194234,-0x1c(%ebp)
801064c2:	eb 35                	jmp    801064f9 <trap+0x127>
      if (p != cp && p->state == RUNNABLE) {
801064c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064c7:	3b 45 e0             	cmp    -0x20(%ebp),%eax
801064ca:	74 26                	je     801064f2 <trap+0x120>
801064cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064cf:	8b 40 0c             	mov    0xc(%eax),%eax
801064d2:	83 f8 03             	cmp    $0x3,%eax
801064d5:	75 1b                	jne    801064f2 <trap+0x120>
        p->wait_ticks[p->priority]++;
801064d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064da:	8b 40 7c             	mov    0x7c(%eax),%eax
801064dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801064e0:	8d 48 24             	lea    0x24(%eax),%ecx
801064e3:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
801064e6:	8d 4a 01             	lea    0x1(%edx),%ecx
801064e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801064ec:	83 c0 24             	add    $0x24,%eax
801064ef:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801064f2:	81 45 e4 a0 00 00 00 	addl   $0xa0,-0x1c(%ebp)
801064f9:	81 7d e4 34 6a 19 80 	cmpl   $0x80196a34,-0x1c(%ebp)
80106500:	72 c2                	jb     801064c4 <trap+0xf2>
      }
    }
    release(&ptable.lock);
80106502:	83 ec 0c             	sub    $0xc,%esp
80106505:	68 00 42 19 80       	push   $0x80194200
8010650a:	e8 ad e5 ff ff       	call   80104abc <release>
8010650f:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106512:	e8 05 c6 ff ff       	call   80102b1c <lapiceoi>
    break;
80106517:	e9 20 01 00 00       	jmp    8010663c <trap+0x26a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010651c:	e8 f5 3e 00 00       	call   8010a416 <ideintr>
    lapiceoi();
80106521:	e8 f6 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
80106526:	e9 11 01 00 00       	jmp    8010663c <trap+0x26a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010652b:	e8 31 c4 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
80106530:	e8 e7 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
80106535:	e9 02 01 00 00       	jmp    8010663c <trap+0x26a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010653a:	e8 53 03 00 00       	call   80106892 <uartintr>
    lapiceoi();
8010653f:	e8 d8 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
80106544:	e9 f3 00 00 00       	jmp    8010663c <trap+0x26a>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106549:	e8 7b 2b 00 00       	call   801090c9 <i8254_intr>
    lapiceoi();
8010654e:	e8 c9 c5 ff ff       	call   80102b1c <lapiceoi>
    break;
80106553:	e9 e4 00 00 00       	jmp    8010663c <trap+0x26a>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106558:	8b 45 08             	mov    0x8(%ebp),%eax
8010655b:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010655e:	8b 45 08             	mov    0x8(%ebp),%eax
80106561:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106565:	0f b7 d8             	movzwl %ax,%ebx
80106568:	e8 cc d4 ff ff       	call   80103a39 <cpuid>
8010656d:	56                   	push   %esi
8010656e:	53                   	push   %ebx
8010656f:	50                   	push   %eax
80106570:	68 90 a9 10 80       	push   $0x8010a990
80106575:	e8 7a 9e ff ff       	call   801003f4 <cprintf>
8010657a:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010657d:	e8 9a c5 ff ff       	call   80102b1c <lapiceoi>
    break;
80106582:	e9 b5 00 00 00       	jmp    8010663c <trap+0x26a>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106587:	e8 40 d5 ff ff       	call   80103acc <myproc>
8010658c:	85 c0                	test   %eax,%eax
8010658e:	74 11                	je     801065a1 <trap+0x1cf>
80106590:	8b 45 08             	mov    0x8(%ebp),%eax
80106593:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106597:	0f b7 c0             	movzwl %ax,%eax
8010659a:	83 e0 03             	and    $0x3,%eax
8010659d:	85 c0                	test   %eax,%eax
8010659f:	75 39                	jne    801065da <trap+0x208>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065a1:	e8 8d fc ff ff       	call   80106233 <rcr2>
801065a6:	89 c3                	mov    %eax,%ebx
801065a8:	8b 45 08             	mov    0x8(%ebp),%eax
801065ab:	8b 70 38             	mov    0x38(%eax),%esi
801065ae:	e8 86 d4 ff ff       	call   80103a39 <cpuid>
801065b3:	8b 55 08             	mov    0x8(%ebp),%edx
801065b6:	8b 52 30             	mov    0x30(%edx),%edx
801065b9:	83 ec 0c             	sub    $0xc,%esp
801065bc:	53                   	push   %ebx
801065bd:	56                   	push   %esi
801065be:	50                   	push   %eax
801065bf:	52                   	push   %edx
801065c0:	68 b4 a9 10 80       	push   $0x8010a9b4
801065c5:	e8 2a 9e ff ff       	call   801003f4 <cprintf>
801065ca:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801065cd:	83 ec 0c             	sub    $0xc,%esp
801065d0:	68 e6 a9 10 80       	push   $0x8010a9e6
801065d5:	e8 cf 9f ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065da:	e8 54 fc ff ff       	call   80106233 <rcr2>
801065df:	89 c6                	mov    %eax,%esi
801065e1:	8b 45 08             	mov    0x8(%ebp),%eax
801065e4:	8b 40 38             	mov    0x38(%eax),%eax
801065e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801065ea:	e8 4a d4 ff ff       	call   80103a39 <cpuid>
801065ef:	89 c3                	mov    %eax,%ebx
801065f1:	8b 45 08             	mov    0x8(%ebp),%eax
801065f4:	8b 78 34             	mov    0x34(%eax),%edi
801065f7:	89 7d d0             	mov    %edi,-0x30(%ebp)
801065fa:	8b 45 08             	mov    0x8(%ebp),%eax
801065fd:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106600:	e8 c7 d4 ff ff       	call   80103acc <myproc>
80106605:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106608:	89 4d cc             	mov    %ecx,-0x34(%ebp)
8010660b:	e8 bc d4 ff ff       	call   80103acc <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106610:	8b 40 10             	mov    0x10(%eax),%eax
80106613:	56                   	push   %esi
80106614:	ff 75 d4             	push   -0x2c(%ebp)
80106617:	53                   	push   %ebx
80106618:	ff 75 d0             	push   -0x30(%ebp)
8010661b:	57                   	push   %edi
8010661c:	ff 75 cc             	push   -0x34(%ebp)
8010661f:	50                   	push   %eax
80106620:	68 ec a9 10 80       	push   $0x8010a9ec
80106625:	e8 ca 9d ff ff       	call   801003f4 <cprintf>
8010662a:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010662d:	e8 9a d4 ff ff       	call   80103acc <myproc>
80106632:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106639:	eb 01                	jmp    8010663c <trap+0x26a>
    break;
8010663b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010663c:	e8 8b d4 ff ff       	call   80103acc <myproc>
80106641:	85 c0                	test   %eax,%eax
80106643:	74 23                	je     80106668 <trap+0x296>
80106645:	e8 82 d4 ff ff       	call   80103acc <myproc>
8010664a:	8b 40 24             	mov    0x24(%eax),%eax
8010664d:	85 c0                	test   %eax,%eax
8010664f:	74 17                	je     80106668 <trap+0x296>
80106651:	8b 45 08             	mov    0x8(%ebp),%eax
80106654:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106658:	0f b7 c0             	movzwl %ax,%eax
8010665b:	83 e0 03             	and    $0x3,%eax
8010665e:	83 f8 03             	cmp    $0x3,%eax
80106661:	75 05                	jne    80106668 <trap+0x296>
    exit();
80106663:	e8 17 d9 ff ff       	call   80103f7f <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106668:	e8 5f d4 ff ff       	call   80103acc <myproc>
8010666d:	85 c0                	test   %eax,%eax
8010666f:	74 1d                	je     8010668e <trap+0x2bc>
80106671:	e8 56 d4 ff ff       	call   80103acc <myproc>
80106676:	8b 40 0c             	mov    0xc(%eax),%eax
80106679:	83 f8 04             	cmp    $0x4,%eax
8010667c:	75 10                	jne    8010668e <trap+0x2bc>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010667e:	8b 45 08             	mov    0x8(%ebp),%eax
80106681:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106684:	83 f8 20             	cmp    $0x20,%eax
80106687:	75 05                	jne    8010668e <trap+0x2bc>
    yield();
80106689:	e8 1c df ff ff       	call   801045aa <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010668e:	e8 39 d4 ff ff       	call   80103acc <myproc>
80106693:	85 c0                	test   %eax,%eax
80106695:	74 26                	je     801066bd <trap+0x2eb>
80106697:	e8 30 d4 ff ff       	call   80103acc <myproc>
8010669c:	8b 40 24             	mov    0x24(%eax),%eax
8010669f:	85 c0                	test   %eax,%eax
801066a1:	74 1a                	je     801066bd <trap+0x2eb>
801066a3:	8b 45 08             	mov    0x8(%ebp),%eax
801066a6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066aa:	0f b7 c0             	movzwl %ax,%eax
801066ad:	83 e0 03             	and    $0x3,%eax
801066b0:	83 f8 03             	cmp    $0x3,%eax
801066b3:	75 08                	jne    801066bd <trap+0x2eb>
    exit();
801066b5:	e8 c5 d8 ff ff       	call   80103f7f <exit>
801066ba:	eb 01                	jmp    801066bd <trap+0x2eb>
    return;
801066bc:	90                   	nop
}
801066bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066c0:	5b                   	pop    %ebx
801066c1:	5e                   	pop    %esi
801066c2:	5f                   	pop    %edi
801066c3:	5d                   	pop    %ebp
801066c4:	c3                   	ret    

801066c5 <inb>:
{
801066c5:	55                   	push   %ebp
801066c6:	89 e5                	mov    %esp,%ebp
801066c8:	83 ec 14             	sub    $0x14,%esp
801066cb:	8b 45 08             	mov    0x8(%ebp),%eax
801066ce:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066d2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801066d6:	89 c2                	mov    %eax,%edx
801066d8:	ec                   	in     (%dx),%al
801066d9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066dc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066e0:	c9                   	leave  
801066e1:	c3                   	ret    

801066e2 <outb>:
{
801066e2:	55                   	push   %ebp
801066e3:	89 e5                	mov    %esp,%ebp
801066e5:	83 ec 08             	sub    $0x8,%esp
801066e8:	8b 45 08             	mov    0x8(%ebp),%eax
801066eb:	8b 55 0c             	mov    0xc(%ebp),%edx
801066ee:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801066f2:	89 d0                	mov    %edx,%eax
801066f4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066f7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066fb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066ff:	ee                   	out    %al,(%dx)
}
80106700:	90                   	nop
80106701:	c9                   	leave  
80106702:	c3                   	ret    

80106703 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106703:	55                   	push   %ebp
80106704:	89 e5                	mov    %esp,%ebp
80106706:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106709:	6a 00                	push   $0x0
8010670b:	68 fa 03 00 00       	push   $0x3fa
80106710:	e8 cd ff ff ff       	call   801066e2 <outb>
80106715:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106718:	68 80 00 00 00       	push   $0x80
8010671d:	68 fb 03 00 00       	push   $0x3fb
80106722:	e8 bb ff ff ff       	call   801066e2 <outb>
80106727:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010672a:	6a 0c                	push   $0xc
8010672c:	68 f8 03 00 00       	push   $0x3f8
80106731:	e8 ac ff ff ff       	call   801066e2 <outb>
80106736:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106739:	6a 00                	push   $0x0
8010673b:	68 f9 03 00 00       	push   $0x3f9
80106740:	e8 9d ff ff ff       	call   801066e2 <outb>
80106745:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106748:	6a 03                	push   $0x3
8010674a:	68 fb 03 00 00       	push   $0x3fb
8010674f:	e8 8e ff ff ff       	call   801066e2 <outb>
80106754:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106757:	6a 00                	push   $0x0
80106759:	68 fc 03 00 00       	push   $0x3fc
8010675e:	e8 7f ff ff ff       	call   801066e2 <outb>
80106763:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106766:	6a 01                	push   $0x1
80106768:	68 f9 03 00 00       	push   $0x3f9
8010676d:	e8 70 ff ff ff       	call   801066e2 <outb>
80106772:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106775:	68 fd 03 00 00       	push   $0x3fd
8010677a:	e8 46 ff ff ff       	call   801066c5 <inb>
8010677f:	83 c4 04             	add    $0x4,%esp
80106782:	3c ff                	cmp    $0xff,%al
80106784:	74 61                	je     801067e7 <uartinit+0xe4>
    return;
  uart = 1;
80106786:	c7 05 78 72 19 80 01 	movl   $0x1,0x80197278
8010678d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106790:	68 fa 03 00 00       	push   $0x3fa
80106795:	e8 2b ff ff ff       	call   801066c5 <inb>
8010679a:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010679d:	68 f8 03 00 00       	push   $0x3f8
801067a2:	e8 1e ff ff ff       	call   801066c5 <inb>
801067a7:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801067aa:	83 ec 08             	sub    $0x8,%esp
801067ad:	6a 00                	push   $0x0
801067af:	6a 04                	push   $0x4
801067b1:	e8 78 be ff ff       	call   8010262e <ioapicenable>
801067b6:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801067b9:	c7 45 f4 b0 aa 10 80 	movl   $0x8010aab0,-0xc(%ebp)
801067c0:	eb 19                	jmp    801067db <uartinit+0xd8>
    uartputc(*p);
801067c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c5:	0f b6 00             	movzbl (%eax),%eax
801067c8:	0f be c0             	movsbl %al,%eax
801067cb:	83 ec 0c             	sub    $0xc,%esp
801067ce:	50                   	push   %eax
801067cf:	e8 16 00 00 00       	call   801067ea <uartputc>
801067d4:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801067d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067de:	0f b6 00             	movzbl (%eax),%eax
801067e1:	84 c0                	test   %al,%al
801067e3:	75 dd                	jne    801067c2 <uartinit+0xbf>
801067e5:	eb 01                	jmp    801067e8 <uartinit+0xe5>
    return;
801067e7:	90                   	nop
}
801067e8:	c9                   	leave  
801067e9:	c3                   	ret    

801067ea <uartputc>:

void
uartputc(int c)
{
801067ea:	55                   	push   %ebp
801067eb:	89 e5                	mov    %esp,%ebp
801067ed:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801067f0:	a1 78 72 19 80       	mov    0x80197278,%eax
801067f5:	85 c0                	test   %eax,%eax
801067f7:	74 53                	je     8010684c <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106800:	eb 11                	jmp    80106813 <uartputc+0x29>
    microdelay(10);
80106802:	83 ec 0c             	sub    $0xc,%esp
80106805:	6a 0a                	push   $0xa
80106807:	e8 2b c3 ff ff       	call   80102b37 <microdelay>
8010680c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010680f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106813:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106817:	7f 1a                	jg     80106833 <uartputc+0x49>
80106819:	83 ec 0c             	sub    $0xc,%esp
8010681c:	68 fd 03 00 00       	push   $0x3fd
80106821:	e8 9f fe ff ff       	call   801066c5 <inb>
80106826:	83 c4 10             	add    $0x10,%esp
80106829:	0f b6 c0             	movzbl %al,%eax
8010682c:	83 e0 20             	and    $0x20,%eax
8010682f:	85 c0                	test   %eax,%eax
80106831:	74 cf                	je     80106802 <uartputc+0x18>
  outb(COM1+0, c);
80106833:	8b 45 08             	mov    0x8(%ebp),%eax
80106836:	0f b6 c0             	movzbl %al,%eax
80106839:	83 ec 08             	sub    $0x8,%esp
8010683c:	50                   	push   %eax
8010683d:	68 f8 03 00 00       	push   $0x3f8
80106842:	e8 9b fe ff ff       	call   801066e2 <outb>
80106847:	83 c4 10             	add    $0x10,%esp
8010684a:	eb 01                	jmp    8010684d <uartputc+0x63>
    return;
8010684c:	90                   	nop
}
8010684d:	c9                   	leave  
8010684e:	c3                   	ret    

8010684f <uartgetc>:

static int
uartgetc(void)
{
8010684f:	55                   	push   %ebp
80106850:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106852:	a1 78 72 19 80       	mov    0x80197278,%eax
80106857:	85 c0                	test   %eax,%eax
80106859:	75 07                	jne    80106862 <uartgetc+0x13>
    return -1;
8010685b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106860:	eb 2e                	jmp    80106890 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106862:	68 fd 03 00 00       	push   $0x3fd
80106867:	e8 59 fe ff ff       	call   801066c5 <inb>
8010686c:	83 c4 04             	add    $0x4,%esp
8010686f:	0f b6 c0             	movzbl %al,%eax
80106872:	83 e0 01             	and    $0x1,%eax
80106875:	85 c0                	test   %eax,%eax
80106877:	75 07                	jne    80106880 <uartgetc+0x31>
    return -1;
80106879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687e:	eb 10                	jmp    80106890 <uartgetc+0x41>
  return inb(COM1+0);
80106880:	68 f8 03 00 00       	push   $0x3f8
80106885:	e8 3b fe ff ff       	call   801066c5 <inb>
8010688a:	83 c4 04             	add    $0x4,%esp
8010688d:	0f b6 c0             	movzbl %al,%eax
}
80106890:	c9                   	leave  
80106891:	c3                   	ret    

80106892 <uartintr>:

void
uartintr(void)
{
80106892:	55                   	push   %ebp
80106893:	89 e5                	mov    %esp,%ebp
80106895:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106898:	83 ec 0c             	sub    $0xc,%esp
8010689b:	68 4f 68 10 80       	push   $0x8010684f
801068a0:	e8 31 9f ff ff       	call   801007d6 <consoleintr>
801068a5:	83 c4 10             	add    $0x10,%esp
}
801068a8:	90                   	nop
801068a9:	c9                   	leave  
801068aa:	c3                   	ret    

801068ab <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801068ab:	6a 00                	push   $0x0
  pushl $0
801068ad:	6a 00                	push   $0x0
  jmp alltraps
801068af:	e9 32 f9 ff ff       	jmp    801061e6 <alltraps>

801068b4 <vector1>:
.globl vector1
vector1:
  pushl $0
801068b4:	6a 00                	push   $0x0
  pushl $1
801068b6:	6a 01                	push   $0x1
  jmp alltraps
801068b8:	e9 29 f9 ff ff       	jmp    801061e6 <alltraps>

801068bd <vector2>:
.globl vector2
vector2:
  pushl $0
801068bd:	6a 00                	push   $0x0
  pushl $2
801068bf:	6a 02                	push   $0x2
  jmp alltraps
801068c1:	e9 20 f9 ff ff       	jmp    801061e6 <alltraps>

801068c6 <vector3>:
.globl vector3
vector3:
  pushl $0
801068c6:	6a 00                	push   $0x0
  pushl $3
801068c8:	6a 03                	push   $0x3
  jmp alltraps
801068ca:	e9 17 f9 ff ff       	jmp    801061e6 <alltraps>

801068cf <vector4>:
.globl vector4
vector4:
  pushl $0
801068cf:	6a 00                	push   $0x0
  pushl $4
801068d1:	6a 04                	push   $0x4
  jmp alltraps
801068d3:	e9 0e f9 ff ff       	jmp    801061e6 <alltraps>

801068d8 <vector5>:
.globl vector5
vector5:
  pushl $0
801068d8:	6a 00                	push   $0x0
  pushl $5
801068da:	6a 05                	push   $0x5
  jmp alltraps
801068dc:	e9 05 f9 ff ff       	jmp    801061e6 <alltraps>

801068e1 <vector6>:
.globl vector6
vector6:
  pushl $0
801068e1:	6a 00                	push   $0x0
  pushl $6
801068e3:	6a 06                	push   $0x6
  jmp alltraps
801068e5:	e9 fc f8 ff ff       	jmp    801061e6 <alltraps>

801068ea <vector7>:
.globl vector7
vector7:
  pushl $0
801068ea:	6a 00                	push   $0x0
  pushl $7
801068ec:	6a 07                	push   $0x7
  jmp alltraps
801068ee:	e9 f3 f8 ff ff       	jmp    801061e6 <alltraps>

801068f3 <vector8>:
.globl vector8
vector8:
  pushl $8
801068f3:	6a 08                	push   $0x8
  jmp alltraps
801068f5:	e9 ec f8 ff ff       	jmp    801061e6 <alltraps>

801068fa <vector9>:
.globl vector9
vector9:
  pushl $0
801068fa:	6a 00                	push   $0x0
  pushl $9
801068fc:	6a 09                	push   $0x9
  jmp alltraps
801068fe:	e9 e3 f8 ff ff       	jmp    801061e6 <alltraps>

80106903 <vector10>:
.globl vector10
vector10:
  pushl $10
80106903:	6a 0a                	push   $0xa
  jmp alltraps
80106905:	e9 dc f8 ff ff       	jmp    801061e6 <alltraps>

8010690a <vector11>:
.globl vector11
vector11:
  pushl $11
8010690a:	6a 0b                	push   $0xb
  jmp alltraps
8010690c:	e9 d5 f8 ff ff       	jmp    801061e6 <alltraps>

80106911 <vector12>:
.globl vector12
vector12:
  pushl $12
80106911:	6a 0c                	push   $0xc
  jmp alltraps
80106913:	e9 ce f8 ff ff       	jmp    801061e6 <alltraps>

80106918 <vector13>:
.globl vector13
vector13:
  pushl $13
80106918:	6a 0d                	push   $0xd
  jmp alltraps
8010691a:	e9 c7 f8 ff ff       	jmp    801061e6 <alltraps>

8010691f <vector14>:
.globl vector14
vector14:
  pushl $14
8010691f:	6a 0e                	push   $0xe
  jmp alltraps
80106921:	e9 c0 f8 ff ff       	jmp    801061e6 <alltraps>

80106926 <vector15>:
.globl vector15
vector15:
  pushl $0
80106926:	6a 00                	push   $0x0
  pushl $15
80106928:	6a 0f                	push   $0xf
  jmp alltraps
8010692a:	e9 b7 f8 ff ff       	jmp    801061e6 <alltraps>

8010692f <vector16>:
.globl vector16
vector16:
  pushl $0
8010692f:	6a 00                	push   $0x0
  pushl $16
80106931:	6a 10                	push   $0x10
  jmp alltraps
80106933:	e9 ae f8 ff ff       	jmp    801061e6 <alltraps>

80106938 <vector17>:
.globl vector17
vector17:
  pushl $17
80106938:	6a 11                	push   $0x11
  jmp alltraps
8010693a:	e9 a7 f8 ff ff       	jmp    801061e6 <alltraps>

8010693f <vector18>:
.globl vector18
vector18:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $18
80106941:	6a 12                	push   $0x12
  jmp alltraps
80106943:	e9 9e f8 ff ff       	jmp    801061e6 <alltraps>

80106948 <vector19>:
.globl vector19
vector19:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $19
8010694a:	6a 13                	push   $0x13
  jmp alltraps
8010694c:	e9 95 f8 ff ff       	jmp    801061e6 <alltraps>

80106951 <vector20>:
.globl vector20
vector20:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $20
80106953:	6a 14                	push   $0x14
  jmp alltraps
80106955:	e9 8c f8 ff ff       	jmp    801061e6 <alltraps>

8010695a <vector21>:
.globl vector21
vector21:
  pushl $0
8010695a:	6a 00                	push   $0x0
  pushl $21
8010695c:	6a 15                	push   $0x15
  jmp alltraps
8010695e:	e9 83 f8 ff ff       	jmp    801061e6 <alltraps>

80106963 <vector22>:
.globl vector22
vector22:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $22
80106965:	6a 16                	push   $0x16
  jmp alltraps
80106967:	e9 7a f8 ff ff       	jmp    801061e6 <alltraps>

8010696c <vector23>:
.globl vector23
vector23:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $23
8010696e:	6a 17                	push   $0x17
  jmp alltraps
80106970:	e9 71 f8 ff ff       	jmp    801061e6 <alltraps>

80106975 <vector24>:
.globl vector24
vector24:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $24
80106977:	6a 18                	push   $0x18
  jmp alltraps
80106979:	e9 68 f8 ff ff       	jmp    801061e6 <alltraps>

8010697e <vector25>:
.globl vector25
vector25:
  pushl $0
8010697e:	6a 00                	push   $0x0
  pushl $25
80106980:	6a 19                	push   $0x19
  jmp alltraps
80106982:	e9 5f f8 ff ff       	jmp    801061e6 <alltraps>

80106987 <vector26>:
.globl vector26
vector26:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $26
80106989:	6a 1a                	push   $0x1a
  jmp alltraps
8010698b:	e9 56 f8 ff ff       	jmp    801061e6 <alltraps>

80106990 <vector27>:
.globl vector27
vector27:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $27
80106992:	6a 1b                	push   $0x1b
  jmp alltraps
80106994:	e9 4d f8 ff ff       	jmp    801061e6 <alltraps>

80106999 <vector28>:
.globl vector28
vector28:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $28
8010699b:	6a 1c                	push   $0x1c
  jmp alltraps
8010699d:	e9 44 f8 ff ff       	jmp    801061e6 <alltraps>

801069a2 <vector29>:
.globl vector29
vector29:
  pushl $0
801069a2:	6a 00                	push   $0x0
  pushl $29
801069a4:	6a 1d                	push   $0x1d
  jmp alltraps
801069a6:	e9 3b f8 ff ff       	jmp    801061e6 <alltraps>

801069ab <vector30>:
.globl vector30
vector30:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $30
801069ad:	6a 1e                	push   $0x1e
  jmp alltraps
801069af:	e9 32 f8 ff ff       	jmp    801061e6 <alltraps>

801069b4 <vector31>:
.globl vector31
vector31:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $31
801069b6:	6a 1f                	push   $0x1f
  jmp alltraps
801069b8:	e9 29 f8 ff ff       	jmp    801061e6 <alltraps>

801069bd <vector32>:
.globl vector32
vector32:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $32
801069bf:	6a 20                	push   $0x20
  jmp alltraps
801069c1:	e9 20 f8 ff ff       	jmp    801061e6 <alltraps>

801069c6 <vector33>:
.globl vector33
vector33:
  pushl $0
801069c6:	6a 00                	push   $0x0
  pushl $33
801069c8:	6a 21                	push   $0x21
  jmp alltraps
801069ca:	e9 17 f8 ff ff       	jmp    801061e6 <alltraps>

801069cf <vector34>:
.globl vector34
vector34:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $34
801069d1:	6a 22                	push   $0x22
  jmp alltraps
801069d3:	e9 0e f8 ff ff       	jmp    801061e6 <alltraps>

801069d8 <vector35>:
.globl vector35
vector35:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $35
801069da:	6a 23                	push   $0x23
  jmp alltraps
801069dc:	e9 05 f8 ff ff       	jmp    801061e6 <alltraps>

801069e1 <vector36>:
.globl vector36
vector36:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $36
801069e3:	6a 24                	push   $0x24
  jmp alltraps
801069e5:	e9 fc f7 ff ff       	jmp    801061e6 <alltraps>

801069ea <vector37>:
.globl vector37
vector37:
  pushl $0
801069ea:	6a 00                	push   $0x0
  pushl $37
801069ec:	6a 25                	push   $0x25
  jmp alltraps
801069ee:	e9 f3 f7 ff ff       	jmp    801061e6 <alltraps>

801069f3 <vector38>:
.globl vector38
vector38:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $38
801069f5:	6a 26                	push   $0x26
  jmp alltraps
801069f7:	e9 ea f7 ff ff       	jmp    801061e6 <alltraps>

801069fc <vector39>:
.globl vector39
vector39:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $39
801069fe:	6a 27                	push   $0x27
  jmp alltraps
80106a00:	e9 e1 f7 ff ff       	jmp    801061e6 <alltraps>

80106a05 <vector40>:
.globl vector40
vector40:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $40
80106a07:	6a 28                	push   $0x28
  jmp alltraps
80106a09:	e9 d8 f7 ff ff       	jmp    801061e6 <alltraps>

80106a0e <vector41>:
.globl vector41
vector41:
  pushl $0
80106a0e:	6a 00                	push   $0x0
  pushl $41
80106a10:	6a 29                	push   $0x29
  jmp alltraps
80106a12:	e9 cf f7 ff ff       	jmp    801061e6 <alltraps>

80106a17 <vector42>:
.globl vector42
vector42:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $42
80106a19:	6a 2a                	push   $0x2a
  jmp alltraps
80106a1b:	e9 c6 f7 ff ff       	jmp    801061e6 <alltraps>

80106a20 <vector43>:
.globl vector43
vector43:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $43
80106a22:	6a 2b                	push   $0x2b
  jmp alltraps
80106a24:	e9 bd f7 ff ff       	jmp    801061e6 <alltraps>

80106a29 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $44
80106a2b:	6a 2c                	push   $0x2c
  jmp alltraps
80106a2d:	e9 b4 f7 ff ff       	jmp    801061e6 <alltraps>

80106a32 <vector45>:
.globl vector45
vector45:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $45
80106a34:	6a 2d                	push   $0x2d
  jmp alltraps
80106a36:	e9 ab f7 ff ff       	jmp    801061e6 <alltraps>

80106a3b <vector46>:
.globl vector46
vector46:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $46
80106a3d:	6a 2e                	push   $0x2e
  jmp alltraps
80106a3f:	e9 a2 f7 ff ff       	jmp    801061e6 <alltraps>

80106a44 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $47
80106a46:	6a 2f                	push   $0x2f
  jmp alltraps
80106a48:	e9 99 f7 ff ff       	jmp    801061e6 <alltraps>

80106a4d <vector48>:
.globl vector48
vector48:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $48
80106a4f:	6a 30                	push   $0x30
  jmp alltraps
80106a51:	e9 90 f7 ff ff       	jmp    801061e6 <alltraps>

80106a56 <vector49>:
.globl vector49
vector49:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $49
80106a58:	6a 31                	push   $0x31
  jmp alltraps
80106a5a:	e9 87 f7 ff ff       	jmp    801061e6 <alltraps>

80106a5f <vector50>:
.globl vector50
vector50:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $50
80106a61:	6a 32                	push   $0x32
  jmp alltraps
80106a63:	e9 7e f7 ff ff       	jmp    801061e6 <alltraps>

80106a68 <vector51>:
.globl vector51
vector51:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $51
80106a6a:	6a 33                	push   $0x33
  jmp alltraps
80106a6c:	e9 75 f7 ff ff       	jmp    801061e6 <alltraps>

80106a71 <vector52>:
.globl vector52
vector52:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $52
80106a73:	6a 34                	push   $0x34
  jmp alltraps
80106a75:	e9 6c f7 ff ff       	jmp    801061e6 <alltraps>

80106a7a <vector53>:
.globl vector53
vector53:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $53
80106a7c:	6a 35                	push   $0x35
  jmp alltraps
80106a7e:	e9 63 f7 ff ff       	jmp    801061e6 <alltraps>

80106a83 <vector54>:
.globl vector54
vector54:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $54
80106a85:	6a 36                	push   $0x36
  jmp alltraps
80106a87:	e9 5a f7 ff ff       	jmp    801061e6 <alltraps>

80106a8c <vector55>:
.globl vector55
vector55:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $55
80106a8e:	6a 37                	push   $0x37
  jmp alltraps
80106a90:	e9 51 f7 ff ff       	jmp    801061e6 <alltraps>

80106a95 <vector56>:
.globl vector56
vector56:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $56
80106a97:	6a 38                	push   $0x38
  jmp alltraps
80106a99:	e9 48 f7 ff ff       	jmp    801061e6 <alltraps>

80106a9e <vector57>:
.globl vector57
vector57:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $57
80106aa0:	6a 39                	push   $0x39
  jmp alltraps
80106aa2:	e9 3f f7 ff ff       	jmp    801061e6 <alltraps>

80106aa7 <vector58>:
.globl vector58
vector58:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $58
80106aa9:	6a 3a                	push   $0x3a
  jmp alltraps
80106aab:	e9 36 f7 ff ff       	jmp    801061e6 <alltraps>

80106ab0 <vector59>:
.globl vector59
vector59:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $59
80106ab2:	6a 3b                	push   $0x3b
  jmp alltraps
80106ab4:	e9 2d f7 ff ff       	jmp    801061e6 <alltraps>

80106ab9 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $60
80106abb:	6a 3c                	push   $0x3c
  jmp alltraps
80106abd:	e9 24 f7 ff ff       	jmp    801061e6 <alltraps>

80106ac2 <vector61>:
.globl vector61
vector61:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $61
80106ac4:	6a 3d                	push   $0x3d
  jmp alltraps
80106ac6:	e9 1b f7 ff ff       	jmp    801061e6 <alltraps>

80106acb <vector62>:
.globl vector62
vector62:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $62
80106acd:	6a 3e                	push   $0x3e
  jmp alltraps
80106acf:	e9 12 f7 ff ff       	jmp    801061e6 <alltraps>

80106ad4 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $63
80106ad6:	6a 3f                	push   $0x3f
  jmp alltraps
80106ad8:	e9 09 f7 ff ff       	jmp    801061e6 <alltraps>

80106add <vector64>:
.globl vector64
vector64:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $64
80106adf:	6a 40                	push   $0x40
  jmp alltraps
80106ae1:	e9 00 f7 ff ff       	jmp    801061e6 <alltraps>

80106ae6 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $65
80106ae8:	6a 41                	push   $0x41
  jmp alltraps
80106aea:	e9 f7 f6 ff ff       	jmp    801061e6 <alltraps>

80106aef <vector66>:
.globl vector66
vector66:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $66
80106af1:	6a 42                	push   $0x42
  jmp alltraps
80106af3:	e9 ee f6 ff ff       	jmp    801061e6 <alltraps>

80106af8 <vector67>:
.globl vector67
vector67:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $67
80106afa:	6a 43                	push   $0x43
  jmp alltraps
80106afc:	e9 e5 f6 ff ff       	jmp    801061e6 <alltraps>

80106b01 <vector68>:
.globl vector68
vector68:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $68
80106b03:	6a 44                	push   $0x44
  jmp alltraps
80106b05:	e9 dc f6 ff ff       	jmp    801061e6 <alltraps>

80106b0a <vector69>:
.globl vector69
vector69:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $69
80106b0c:	6a 45                	push   $0x45
  jmp alltraps
80106b0e:	e9 d3 f6 ff ff       	jmp    801061e6 <alltraps>

80106b13 <vector70>:
.globl vector70
vector70:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $70
80106b15:	6a 46                	push   $0x46
  jmp alltraps
80106b17:	e9 ca f6 ff ff       	jmp    801061e6 <alltraps>

80106b1c <vector71>:
.globl vector71
vector71:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $71
80106b1e:	6a 47                	push   $0x47
  jmp alltraps
80106b20:	e9 c1 f6 ff ff       	jmp    801061e6 <alltraps>

80106b25 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $72
80106b27:	6a 48                	push   $0x48
  jmp alltraps
80106b29:	e9 b8 f6 ff ff       	jmp    801061e6 <alltraps>

80106b2e <vector73>:
.globl vector73
vector73:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $73
80106b30:	6a 49                	push   $0x49
  jmp alltraps
80106b32:	e9 af f6 ff ff       	jmp    801061e6 <alltraps>

80106b37 <vector74>:
.globl vector74
vector74:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $74
80106b39:	6a 4a                	push   $0x4a
  jmp alltraps
80106b3b:	e9 a6 f6 ff ff       	jmp    801061e6 <alltraps>

80106b40 <vector75>:
.globl vector75
vector75:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $75
80106b42:	6a 4b                	push   $0x4b
  jmp alltraps
80106b44:	e9 9d f6 ff ff       	jmp    801061e6 <alltraps>

80106b49 <vector76>:
.globl vector76
vector76:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $76
80106b4b:	6a 4c                	push   $0x4c
  jmp alltraps
80106b4d:	e9 94 f6 ff ff       	jmp    801061e6 <alltraps>

80106b52 <vector77>:
.globl vector77
vector77:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $77
80106b54:	6a 4d                	push   $0x4d
  jmp alltraps
80106b56:	e9 8b f6 ff ff       	jmp    801061e6 <alltraps>

80106b5b <vector78>:
.globl vector78
vector78:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $78
80106b5d:	6a 4e                	push   $0x4e
  jmp alltraps
80106b5f:	e9 82 f6 ff ff       	jmp    801061e6 <alltraps>

80106b64 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $79
80106b66:	6a 4f                	push   $0x4f
  jmp alltraps
80106b68:	e9 79 f6 ff ff       	jmp    801061e6 <alltraps>

80106b6d <vector80>:
.globl vector80
vector80:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $80
80106b6f:	6a 50                	push   $0x50
  jmp alltraps
80106b71:	e9 70 f6 ff ff       	jmp    801061e6 <alltraps>

80106b76 <vector81>:
.globl vector81
vector81:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $81
80106b78:	6a 51                	push   $0x51
  jmp alltraps
80106b7a:	e9 67 f6 ff ff       	jmp    801061e6 <alltraps>

80106b7f <vector82>:
.globl vector82
vector82:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $82
80106b81:	6a 52                	push   $0x52
  jmp alltraps
80106b83:	e9 5e f6 ff ff       	jmp    801061e6 <alltraps>

80106b88 <vector83>:
.globl vector83
vector83:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $83
80106b8a:	6a 53                	push   $0x53
  jmp alltraps
80106b8c:	e9 55 f6 ff ff       	jmp    801061e6 <alltraps>

80106b91 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $84
80106b93:	6a 54                	push   $0x54
  jmp alltraps
80106b95:	e9 4c f6 ff ff       	jmp    801061e6 <alltraps>

80106b9a <vector85>:
.globl vector85
vector85:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $85
80106b9c:	6a 55                	push   $0x55
  jmp alltraps
80106b9e:	e9 43 f6 ff ff       	jmp    801061e6 <alltraps>

80106ba3 <vector86>:
.globl vector86
vector86:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $86
80106ba5:	6a 56                	push   $0x56
  jmp alltraps
80106ba7:	e9 3a f6 ff ff       	jmp    801061e6 <alltraps>

80106bac <vector87>:
.globl vector87
vector87:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $87
80106bae:	6a 57                	push   $0x57
  jmp alltraps
80106bb0:	e9 31 f6 ff ff       	jmp    801061e6 <alltraps>

80106bb5 <vector88>:
.globl vector88
vector88:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $88
80106bb7:	6a 58                	push   $0x58
  jmp alltraps
80106bb9:	e9 28 f6 ff ff       	jmp    801061e6 <alltraps>

80106bbe <vector89>:
.globl vector89
vector89:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $89
80106bc0:	6a 59                	push   $0x59
  jmp alltraps
80106bc2:	e9 1f f6 ff ff       	jmp    801061e6 <alltraps>

80106bc7 <vector90>:
.globl vector90
vector90:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $90
80106bc9:	6a 5a                	push   $0x5a
  jmp alltraps
80106bcb:	e9 16 f6 ff ff       	jmp    801061e6 <alltraps>

80106bd0 <vector91>:
.globl vector91
vector91:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $91
80106bd2:	6a 5b                	push   $0x5b
  jmp alltraps
80106bd4:	e9 0d f6 ff ff       	jmp    801061e6 <alltraps>

80106bd9 <vector92>:
.globl vector92
vector92:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $92
80106bdb:	6a 5c                	push   $0x5c
  jmp alltraps
80106bdd:	e9 04 f6 ff ff       	jmp    801061e6 <alltraps>

80106be2 <vector93>:
.globl vector93
vector93:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $93
80106be4:	6a 5d                	push   $0x5d
  jmp alltraps
80106be6:	e9 fb f5 ff ff       	jmp    801061e6 <alltraps>

80106beb <vector94>:
.globl vector94
vector94:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $94
80106bed:	6a 5e                	push   $0x5e
  jmp alltraps
80106bef:	e9 f2 f5 ff ff       	jmp    801061e6 <alltraps>

80106bf4 <vector95>:
.globl vector95
vector95:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $95
80106bf6:	6a 5f                	push   $0x5f
  jmp alltraps
80106bf8:	e9 e9 f5 ff ff       	jmp    801061e6 <alltraps>

80106bfd <vector96>:
.globl vector96
vector96:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $96
80106bff:	6a 60                	push   $0x60
  jmp alltraps
80106c01:	e9 e0 f5 ff ff       	jmp    801061e6 <alltraps>

80106c06 <vector97>:
.globl vector97
vector97:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $97
80106c08:	6a 61                	push   $0x61
  jmp alltraps
80106c0a:	e9 d7 f5 ff ff       	jmp    801061e6 <alltraps>

80106c0f <vector98>:
.globl vector98
vector98:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $98
80106c11:	6a 62                	push   $0x62
  jmp alltraps
80106c13:	e9 ce f5 ff ff       	jmp    801061e6 <alltraps>

80106c18 <vector99>:
.globl vector99
vector99:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $99
80106c1a:	6a 63                	push   $0x63
  jmp alltraps
80106c1c:	e9 c5 f5 ff ff       	jmp    801061e6 <alltraps>

80106c21 <vector100>:
.globl vector100
vector100:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $100
80106c23:	6a 64                	push   $0x64
  jmp alltraps
80106c25:	e9 bc f5 ff ff       	jmp    801061e6 <alltraps>

80106c2a <vector101>:
.globl vector101
vector101:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $101
80106c2c:	6a 65                	push   $0x65
  jmp alltraps
80106c2e:	e9 b3 f5 ff ff       	jmp    801061e6 <alltraps>

80106c33 <vector102>:
.globl vector102
vector102:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $102
80106c35:	6a 66                	push   $0x66
  jmp alltraps
80106c37:	e9 aa f5 ff ff       	jmp    801061e6 <alltraps>

80106c3c <vector103>:
.globl vector103
vector103:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $103
80106c3e:	6a 67                	push   $0x67
  jmp alltraps
80106c40:	e9 a1 f5 ff ff       	jmp    801061e6 <alltraps>

80106c45 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $104
80106c47:	6a 68                	push   $0x68
  jmp alltraps
80106c49:	e9 98 f5 ff ff       	jmp    801061e6 <alltraps>

80106c4e <vector105>:
.globl vector105
vector105:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $105
80106c50:	6a 69                	push   $0x69
  jmp alltraps
80106c52:	e9 8f f5 ff ff       	jmp    801061e6 <alltraps>

80106c57 <vector106>:
.globl vector106
vector106:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $106
80106c59:	6a 6a                	push   $0x6a
  jmp alltraps
80106c5b:	e9 86 f5 ff ff       	jmp    801061e6 <alltraps>

80106c60 <vector107>:
.globl vector107
vector107:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $107
80106c62:	6a 6b                	push   $0x6b
  jmp alltraps
80106c64:	e9 7d f5 ff ff       	jmp    801061e6 <alltraps>

80106c69 <vector108>:
.globl vector108
vector108:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $108
80106c6b:	6a 6c                	push   $0x6c
  jmp alltraps
80106c6d:	e9 74 f5 ff ff       	jmp    801061e6 <alltraps>

80106c72 <vector109>:
.globl vector109
vector109:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $109
80106c74:	6a 6d                	push   $0x6d
  jmp alltraps
80106c76:	e9 6b f5 ff ff       	jmp    801061e6 <alltraps>

80106c7b <vector110>:
.globl vector110
vector110:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $110
80106c7d:	6a 6e                	push   $0x6e
  jmp alltraps
80106c7f:	e9 62 f5 ff ff       	jmp    801061e6 <alltraps>

80106c84 <vector111>:
.globl vector111
vector111:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $111
80106c86:	6a 6f                	push   $0x6f
  jmp alltraps
80106c88:	e9 59 f5 ff ff       	jmp    801061e6 <alltraps>

80106c8d <vector112>:
.globl vector112
vector112:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $112
80106c8f:	6a 70                	push   $0x70
  jmp alltraps
80106c91:	e9 50 f5 ff ff       	jmp    801061e6 <alltraps>

80106c96 <vector113>:
.globl vector113
vector113:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $113
80106c98:	6a 71                	push   $0x71
  jmp alltraps
80106c9a:	e9 47 f5 ff ff       	jmp    801061e6 <alltraps>

80106c9f <vector114>:
.globl vector114
vector114:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $114
80106ca1:	6a 72                	push   $0x72
  jmp alltraps
80106ca3:	e9 3e f5 ff ff       	jmp    801061e6 <alltraps>

80106ca8 <vector115>:
.globl vector115
vector115:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $115
80106caa:	6a 73                	push   $0x73
  jmp alltraps
80106cac:	e9 35 f5 ff ff       	jmp    801061e6 <alltraps>

80106cb1 <vector116>:
.globl vector116
vector116:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $116
80106cb3:	6a 74                	push   $0x74
  jmp alltraps
80106cb5:	e9 2c f5 ff ff       	jmp    801061e6 <alltraps>

80106cba <vector117>:
.globl vector117
vector117:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $117
80106cbc:	6a 75                	push   $0x75
  jmp alltraps
80106cbe:	e9 23 f5 ff ff       	jmp    801061e6 <alltraps>

80106cc3 <vector118>:
.globl vector118
vector118:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $118
80106cc5:	6a 76                	push   $0x76
  jmp alltraps
80106cc7:	e9 1a f5 ff ff       	jmp    801061e6 <alltraps>

80106ccc <vector119>:
.globl vector119
vector119:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $119
80106cce:	6a 77                	push   $0x77
  jmp alltraps
80106cd0:	e9 11 f5 ff ff       	jmp    801061e6 <alltraps>

80106cd5 <vector120>:
.globl vector120
vector120:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $120
80106cd7:	6a 78                	push   $0x78
  jmp alltraps
80106cd9:	e9 08 f5 ff ff       	jmp    801061e6 <alltraps>

80106cde <vector121>:
.globl vector121
vector121:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $121
80106ce0:	6a 79                	push   $0x79
  jmp alltraps
80106ce2:	e9 ff f4 ff ff       	jmp    801061e6 <alltraps>

80106ce7 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $122
80106ce9:	6a 7a                	push   $0x7a
  jmp alltraps
80106ceb:	e9 f6 f4 ff ff       	jmp    801061e6 <alltraps>

80106cf0 <vector123>:
.globl vector123
vector123:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $123
80106cf2:	6a 7b                	push   $0x7b
  jmp alltraps
80106cf4:	e9 ed f4 ff ff       	jmp    801061e6 <alltraps>

80106cf9 <vector124>:
.globl vector124
vector124:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $124
80106cfb:	6a 7c                	push   $0x7c
  jmp alltraps
80106cfd:	e9 e4 f4 ff ff       	jmp    801061e6 <alltraps>

80106d02 <vector125>:
.globl vector125
vector125:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $125
80106d04:	6a 7d                	push   $0x7d
  jmp alltraps
80106d06:	e9 db f4 ff ff       	jmp    801061e6 <alltraps>

80106d0b <vector126>:
.globl vector126
vector126:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $126
80106d0d:	6a 7e                	push   $0x7e
  jmp alltraps
80106d0f:	e9 d2 f4 ff ff       	jmp    801061e6 <alltraps>

80106d14 <vector127>:
.globl vector127
vector127:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $127
80106d16:	6a 7f                	push   $0x7f
  jmp alltraps
80106d18:	e9 c9 f4 ff ff       	jmp    801061e6 <alltraps>

80106d1d <vector128>:
.globl vector128
vector128:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $128
80106d1f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d24:	e9 bd f4 ff ff       	jmp    801061e6 <alltraps>

80106d29 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $129
80106d2b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d30:	e9 b1 f4 ff ff       	jmp    801061e6 <alltraps>

80106d35 <vector130>:
.globl vector130
vector130:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $130
80106d37:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d3c:	e9 a5 f4 ff ff       	jmp    801061e6 <alltraps>

80106d41 <vector131>:
.globl vector131
vector131:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $131
80106d43:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d48:	e9 99 f4 ff ff       	jmp    801061e6 <alltraps>

80106d4d <vector132>:
.globl vector132
vector132:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $132
80106d4f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d54:	e9 8d f4 ff ff       	jmp    801061e6 <alltraps>

80106d59 <vector133>:
.globl vector133
vector133:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $133
80106d5b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d60:	e9 81 f4 ff ff       	jmp    801061e6 <alltraps>

80106d65 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $134
80106d67:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d6c:	e9 75 f4 ff ff       	jmp    801061e6 <alltraps>

80106d71 <vector135>:
.globl vector135
vector135:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $135
80106d73:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d78:	e9 69 f4 ff ff       	jmp    801061e6 <alltraps>

80106d7d <vector136>:
.globl vector136
vector136:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $136
80106d7f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d84:	e9 5d f4 ff ff       	jmp    801061e6 <alltraps>

80106d89 <vector137>:
.globl vector137
vector137:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $137
80106d8b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d90:	e9 51 f4 ff ff       	jmp    801061e6 <alltraps>

80106d95 <vector138>:
.globl vector138
vector138:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $138
80106d97:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d9c:	e9 45 f4 ff ff       	jmp    801061e6 <alltraps>

80106da1 <vector139>:
.globl vector139
vector139:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $139
80106da3:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106da8:	e9 39 f4 ff ff       	jmp    801061e6 <alltraps>

80106dad <vector140>:
.globl vector140
vector140:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $140
80106daf:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106db4:	e9 2d f4 ff ff       	jmp    801061e6 <alltraps>

80106db9 <vector141>:
.globl vector141
vector141:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $141
80106dbb:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106dc0:	e9 21 f4 ff ff       	jmp    801061e6 <alltraps>

80106dc5 <vector142>:
.globl vector142
vector142:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $142
80106dc7:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106dcc:	e9 15 f4 ff ff       	jmp    801061e6 <alltraps>

80106dd1 <vector143>:
.globl vector143
vector143:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $143
80106dd3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106dd8:	e9 09 f4 ff ff       	jmp    801061e6 <alltraps>

80106ddd <vector144>:
.globl vector144
vector144:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $144
80106ddf:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106de4:	e9 fd f3 ff ff       	jmp    801061e6 <alltraps>

80106de9 <vector145>:
.globl vector145
vector145:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $145
80106deb:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106df0:	e9 f1 f3 ff ff       	jmp    801061e6 <alltraps>

80106df5 <vector146>:
.globl vector146
vector146:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $146
80106df7:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106dfc:	e9 e5 f3 ff ff       	jmp    801061e6 <alltraps>

80106e01 <vector147>:
.globl vector147
vector147:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $147
80106e03:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e08:	e9 d9 f3 ff ff       	jmp    801061e6 <alltraps>

80106e0d <vector148>:
.globl vector148
vector148:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $148
80106e0f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e14:	e9 cd f3 ff ff       	jmp    801061e6 <alltraps>

80106e19 <vector149>:
.globl vector149
vector149:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $149
80106e1b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e20:	e9 c1 f3 ff ff       	jmp    801061e6 <alltraps>

80106e25 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $150
80106e27:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e2c:	e9 b5 f3 ff ff       	jmp    801061e6 <alltraps>

80106e31 <vector151>:
.globl vector151
vector151:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $151
80106e33:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e38:	e9 a9 f3 ff ff       	jmp    801061e6 <alltraps>

80106e3d <vector152>:
.globl vector152
vector152:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $152
80106e3f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e44:	e9 9d f3 ff ff       	jmp    801061e6 <alltraps>

80106e49 <vector153>:
.globl vector153
vector153:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $153
80106e4b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e50:	e9 91 f3 ff ff       	jmp    801061e6 <alltraps>

80106e55 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $154
80106e57:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e5c:	e9 85 f3 ff ff       	jmp    801061e6 <alltraps>

80106e61 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $155
80106e63:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e68:	e9 79 f3 ff ff       	jmp    801061e6 <alltraps>

80106e6d <vector156>:
.globl vector156
vector156:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $156
80106e6f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e74:	e9 6d f3 ff ff       	jmp    801061e6 <alltraps>

80106e79 <vector157>:
.globl vector157
vector157:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $157
80106e7b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e80:	e9 61 f3 ff ff       	jmp    801061e6 <alltraps>

80106e85 <vector158>:
.globl vector158
vector158:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $158
80106e87:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e8c:	e9 55 f3 ff ff       	jmp    801061e6 <alltraps>

80106e91 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $159
80106e93:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e98:	e9 49 f3 ff ff       	jmp    801061e6 <alltraps>

80106e9d <vector160>:
.globl vector160
vector160:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $160
80106e9f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ea4:	e9 3d f3 ff ff       	jmp    801061e6 <alltraps>

80106ea9 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $161
80106eab:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106eb0:	e9 31 f3 ff ff       	jmp    801061e6 <alltraps>

80106eb5 <vector162>:
.globl vector162
vector162:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $162
80106eb7:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ebc:	e9 25 f3 ff ff       	jmp    801061e6 <alltraps>

80106ec1 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $163
80106ec3:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ec8:	e9 19 f3 ff ff       	jmp    801061e6 <alltraps>

80106ecd <vector164>:
.globl vector164
vector164:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $164
80106ecf:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106ed4:	e9 0d f3 ff ff       	jmp    801061e6 <alltraps>

80106ed9 <vector165>:
.globl vector165
vector165:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $165
80106edb:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ee0:	e9 01 f3 ff ff       	jmp    801061e6 <alltraps>

80106ee5 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $166
80106ee7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106eec:	e9 f5 f2 ff ff       	jmp    801061e6 <alltraps>

80106ef1 <vector167>:
.globl vector167
vector167:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $167
80106ef3:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106ef8:	e9 e9 f2 ff ff       	jmp    801061e6 <alltraps>

80106efd <vector168>:
.globl vector168
vector168:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $168
80106eff:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f04:	e9 dd f2 ff ff       	jmp    801061e6 <alltraps>

80106f09 <vector169>:
.globl vector169
vector169:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $169
80106f0b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f10:	e9 d1 f2 ff ff       	jmp    801061e6 <alltraps>

80106f15 <vector170>:
.globl vector170
vector170:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $170
80106f17:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f1c:	e9 c5 f2 ff ff       	jmp    801061e6 <alltraps>

80106f21 <vector171>:
.globl vector171
vector171:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $171
80106f23:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f28:	e9 b9 f2 ff ff       	jmp    801061e6 <alltraps>

80106f2d <vector172>:
.globl vector172
vector172:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $172
80106f2f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f34:	e9 ad f2 ff ff       	jmp    801061e6 <alltraps>

80106f39 <vector173>:
.globl vector173
vector173:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $173
80106f3b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f40:	e9 a1 f2 ff ff       	jmp    801061e6 <alltraps>

80106f45 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $174
80106f47:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f4c:	e9 95 f2 ff ff       	jmp    801061e6 <alltraps>

80106f51 <vector175>:
.globl vector175
vector175:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $175
80106f53:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f58:	e9 89 f2 ff ff       	jmp    801061e6 <alltraps>

80106f5d <vector176>:
.globl vector176
vector176:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $176
80106f5f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f64:	e9 7d f2 ff ff       	jmp    801061e6 <alltraps>

80106f69 <vector177>:
.globl vector177
vector177:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $177
80106f6b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f70:	e9 71 f2 ff ff       	jmp    801061e6 <alltraps>

80106f75 <vector178>:
.globl vector178
vector178:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $178
80106f77:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f7c:	e9 65 f2 ff ff       	jmp    801061e6 <alltraps>

80106f81 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $179
80106f83:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f88:	e9 59 f2 ff ff       	jmp    801061e6 <alltraps>

80106f8d <vector180>:
.globl vector180
vector180:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $180
80106f8f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f94:	e9 4d f2 ff ff       	jmp    801061e6 <alltraps>

80106f99 <vector181>:
.globl vector181
vector181:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $181
80106f9b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106fa0:	e9 41 f2 ff ff       	jmp    801061e6 <alltraps>

80106fa5 <vector182>:
.globl vector182
vector182:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $182
80106fa7:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106fac:	e9 35 f2 ff ff       	jmp    801061e6 <alltraps>

80106fb1 <vector183>:
.globl vector183
vector183:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $183
80106fb3:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106fb8:	e9 29 f2 ff ff       	jmp    801061e6 <alltraps>

80106fbd <vector184>:
.globl vector184
vector184:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $184
80106fbf:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106fc4:	e9 1d f2 ff ff       	jmp    801061e6 <alltraps>

80106fc9 <vector185>:
.globl vector185
vector185:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $185
80106fcb:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106fd0:	e9 11 f2 ff ff       	jmp    801061e6 <alltraps>

80106fd5 <vector186>:
.globl vector186
vector186:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $186
80106fd7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106fdc:	e9 05 f2 ff ff       	jmp    801061e6 <alltraps>

80106fe1 <vector187>:
.globl vector187
vector187:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $187
80106fe3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106fe8:	e9 f9 f1 ff ff       	jmp    801061e6 <alltraps>

80106fed <vector188>:
.globl vector188
vector188:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $188
80106fef:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106ff4:	e9 ed f1 ff ff       	jmp    801061e6 <alltraps>

80106ff9 <vector189>:
.globl vector189
vector189:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $189
80106ffb:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107000:	e9 e1 f1 ff ff       	jmp    801061e6 <alltraps>

80107005 <vector190>:
.globl vector190
vector190:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $190
80107007:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010700c:	e9 d5 f1 ff ff       	jmp    801061e6 <alltraps>

80107011 <vector191>:
.globl vector191
vector191:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $191
80107013:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107018:	e9 c9 f1 ff ff       	jmp    801061e6 <alltraps>

8010701d <vector192>:
.globl vector192
vector192:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $192
8010701f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107024:	e9 bd f1 ff ff       	jmp    801061e6 <alltraps>

80107029 <vector193>:
.globl vector193
vector193:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $193
8010702b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107030:	e9 b1 f1 ff ff       	jmp    801061e6 <alltraps>

80107035 <vector194>:
.globl vector194
vector194:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $194
80107037:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010703c:	e9 a5 f1 ff ff       	jmp    801061e6 <alltraps>

80107041 <vector195>:
.globl vector195
vector195:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $195
80107043:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107048:	e9 99 f1 ff ff       	jmp    801061e6 <alltraps>

8010704d <vector196>:
.globl vector196
vector196:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $196
8010704f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107054:	e9 8d f1 ff ff       	jmp    801061e6 <alltraps>

80107059 <vector197>:
.globl vector197
vector197:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $197
8010705b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107060:	e9 81 f1 ff ff       	jmp    801061e6 <alltraps>

80107065 <vector198>:
.globl vector198
vector198:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $198
80107067:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010706c:	e9 75 f1 ff ff       	jmp    801061e6 <alltraps>

80107071 <vector199>:
.globl vector199
vector199:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $199
80107073:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107078:	e9 69 f1 ff ff       	jmp    801061e6 <alltraps>

8010707d <vector200>:
.globl vector200
vector200:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $200
8010707f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107084:	e9 5d f1 ff ff       	jmp    801061e6 <alltraps>

80107089 <vector201>:
.globl vector201
vector201:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $201
8010708b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107090:	e9 51 f1 ff ff       	jmp    801061e6 <alltraps>

80107095 <vector202>:
.globl vector202
vector202:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $202
80107097:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010709c:	e9 45 f1 ff ff       	jmp    801061e6 <alltraps>

801070a1 <vector203>:
.globl vector203
vector203:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $203
801070a3:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801070a8:	e9 39 f1 ff ff       	jmp    801061e6 <alltraps>

801070ad <vector204>:
.globl vector204
vector204:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $204
801070af:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801070b4:	e9 2d f1 ff ff       	jmp    801061e6 <alltraps>

801070b9 <vector205>:
.globl vector205
vector205:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $205
801070bb:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070c0:	e9 21 f1 ff ff       	jmp    801061e6 <alltraps>

801070c5 <vector206>:
.globl vector206
vector206:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $206
801070c7:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070cc:	e9 15 f1 ff ff       	jmp    801061e6 <alltraps>

801070d1 <vector207>:
.globl vector207
vector207:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $207
801070d3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801070d8:	e9 09 f1 ff ff       	jmp    801061e6 <alltraps>

801070dd <vector208>:
.globl vector208
vector208:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $208
801070df:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070e4:	e9 fd f0 ff ff       	jmp    801061e6 <alltraps>

801070e9 <vector209>:
.globl vector209
vector209:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $209
801070eb:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801070f0:	e9 f1 f0 ff ff       	jmp    801061e6 <alltraps>

801070f5 <vector210>:
.globl vector210
vector210:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $210
801070f7:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070fc:	e9 e5 f0 ff ff       	jmp    801061e6 <alltraps>

80107101 <vector211>:
.globl vector211
vector211:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $211
80107103:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107108:	e9 d9 f0 ff ff       	jmp    801061e6 <alltraps>

8010710d <vector212>:
.globl vector212
vector212:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $212
8010710f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107114:	e9 cd f0 ff ff       	jmp    801061e6 <alltraps>

80107119 <vector213>:
.globl vector213
vector213:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $213
8010711b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107120:	e9 c1 f0 ff ff       	jmp    801061e6 <alltraps>

80107125 <vector214>:
.globl vector214
vector214:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $214
80107127:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010712c:	e9 b5 f0 ff ff       	jmp    801061e6 <alltraps>

80107131 <vector215>:
.globl vector215
vector215:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $215
80107133:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107138:	e9 a9 f0 ff ff       	jmp    801061e6 <alltraps>

8010713d <vector216>:
.globl vector216
vector216:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $216
8010713f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107144:	e9 9d f0 ff ff       	jmp    801061e6 <alltraps>

80107149 <vector217>:
.globl vector217
vector217:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $217
8010714b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107150:	e9 91 f0 ff ff       	jmp    801061e6 <alltraps>

80107155 <vector218>:
.globl vector218
vector218:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $218
80107157:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010715c:	e9 85 f0 ff ff       	jmp    801061e6 <alltraps>

80107161 <vector219>:
.globl vector219
vector219:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $219
80107163:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107168:	e9 79 f0 ff ff       	jmp    801061e6 <alltraps>

8010716d <vector220>:
.globl vector220
vector220:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $220
8010716f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107174:	e9 6d f0 ff ff       	jmp    801061e6 <alltraps>

80107179 <vector221>:
.globl vector221
vector221:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $221
8010717b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107180:	e9 61 f0 ff ff       	jmp    801061e6 <alltraps>

80107185 <vector222>:
.globl vector222
vector222:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $222
80107187:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010718c:	e9 55 f0 ff ff       	jmp    801061e6 <alltraps>

80107191 <vector223>:
.globl vector223
vector223:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $223
80107193:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107198:	e9 49 f0 ff ff       	jmp    801061e6 <alltraps>

8010719d <vector224>:
.globl vector224
vector224:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $224
8010719f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801071a4:	e9 3d f0 ff ff       	jmp    801061e6 <alltraps>

801071a9 <vector225>:
.globl vector225
vector225:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $225
801071ab:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801071b0:	e9 31 f0 ff ff       	jmp    801061e6 <alltraps>

801071b5 <vector226>:
.globl vector226
vector226:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $226
801071b7:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801071bc:	e9 25 f0 ff ff       	jmp    801061e6 <alltraps>

801071c1 <vector227>:
.globl vector227
vector227:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $227
801071c3:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071c8:	e9 19 f0 ff ff       	jmp    801061e6 <alltraps>

801071cd <vector228>:
.globl vector228
vector228:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $228
801071cf:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801071d4:	e9 0d f0 ff ff       	jmp    801061e6 <alltraps>

801071d9 <vector229>:
.globl vector229
vector229:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $229
801071db:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071e0:	e9 01 f0 ff ff       	jmp    801061e6 <alltraps>

801071e5 <vector230>:
.globl vector230
vector230:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $230
801071e7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801071ec:	e9 f5 ef ff ff       	jmp    801061e6 <alltraps>

801071f1 <vector231>:
.globl vector231
vector231:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $231
801071f3:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801071f8:	e9 e9 ef ff ff       	jmp    801061e6 <alltraps>

801071fd <vector232>:
.globl vector232
vector232:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $232
801071ff:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107204:	e9 dd ef ff ff       	jmp    801061e6 <alltraps>

80107209 <vector233>:
.globl vector233
vector233:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $233
8010720b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107210:	e9 d1 ef ff ff       	jmp    801061e6 <alltraps>

80107215 <vector234>:
.globl vector234
vector234:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $234
80107217:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010721c:	e9 c5 ef ff ff       	jmp    801061e6 <alltraps>

80107221 <vector235>:
.globl vector235
vector235:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $235
80107223:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107228:	e9 b9 ef ff ff       	jmp    801061e6 <alltraps>

8010722d <vector236>:
.globl vector236
vector236:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $236
8010722f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107234:	e9 ad ef ff ff       	jmp    801061e6 <alltraps>

80107239 <vector237>:
.globl vector237
vector237:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $237
8010723b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107240:	e9 a1 ef ff ff       	jmp    801061e6 <alltraps>

80107245 <vector238>:
.globl vector238
vector238:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $238
80107247:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010724c:	e9 95 ef ff ff       	jmp    801061e6 <alltraps>

80107251 <vector239>:
.globl vector239
vector239:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $239
80107253:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107258:	e9 89 ef ff ff       	jmp    801061e6 <alltraps>

8010725d <vector240>:
.globl vector240
vector240:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $240
8010725f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107264:	e9 7d ef ff ff       	jmp    801061e6 <alltraps>

80107269 <vector241>:
.globl vector241
vector241:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $241
8010726b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107270:	e9 71 ef ff ff       	jmp    801061e6 <alltraps>

80107275 <vector242>:
.globl vector242
vector242:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $242
80107277:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010727c:	e9 65 ef ff ff       	jmp    801061e6 <alltraps>

80107281 <vector243>:
.globl vector243
vector243:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $243
80107283:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107288:	e9 59 ef ff ff       	jmp    801061e6 <alltraps>

8010728d <vector244>:
.globl vector244
vector244:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $244
8010728f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107294:	e9 4d ef ff ff       	jmp    801061e6 <alltraps>

80107299 <vector245>:
.globl vector245
vector245:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $245
8010729b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801072a0:	e9 41 ef ff ff       	jmp    801061e6 <alltraps>

801072a5 <vector246>:
.globl vector246
vector246:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $246
801072a7:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801072ac:	e9 35 ef ff ff       	jmp    801061e6 <alltraps>

801072b1 <vector247>:
.globl vector247
vector247:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $247
801072b3:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801072b8:	e9 29 ef ff ff       	jmp    801061e6 <alltraps>

801072bd <vector248>:
.globl vector248
vector248:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $248
801072bf:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072c4:	e9 1d ef ff ff       	jmp    801061e6 <alltraps>

801072c9 <vector249>:
.globl vector249
vector249:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $249
801072cb:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072d0:	e9 11 ef ff ff       	jmp    801061e6 <alltraps>

801072d5 <vector250>:
.globl vector250
vector250:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $250
801072d7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072dc:	e9 05 ef ff ff       	jmp    801061e6 <alltraps>

801072e1 <vector251>:
.globl vector251
vector251:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $251
801072e3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801072e8:	e9 f9 ee ff ff       	jmp    801061e6 <alltraps>

801072ed <vector252>:
.globl vector252
vector252:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $252
801072ef:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801072f4:	e9 ed ee ff ff       	jmp    801061e6 <alltraps>

801072f9 <vector253>:
.globl vector253
vector253:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $253
801072fb:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107300:	e9 e1 ee ff ff       	jmp    801061e6 <alltraps>

80107305 <vector254>:
.globl vector254
vector254:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $254
80107307:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010730c:	e9 d5 ee ff ff       	jmp    801061e6 <alltraps>

80107311 <vector255>:
.globl vector255
vector255:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $255
80107313:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107318:	e9 c9 ee ff ff       	jmp    801061e6 <alltraps>

8010731d <lgdt>:
{
8010731d:	55                   	push   %ebp
8010731e:	89 e5                	mov    %esp,%ebp
80107320:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107323:	8b 45 0c             	mov    0xc(%ebp),%eax
80107326:	83 e8 01             	sub    $0x1,%eax
80107329:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010732d:	8b 45 08             	mov    0x8(%ebp),%eax
80107330:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107334:	8b 45 08             	mov    0x8(%ebp),%eax
80107337:	c1 e8 10             	shr    $0x10,%eax
8010733a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010733e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107341:	0f 01 10             	lgdtl  (%eax)
}
80107344:	90                   	nop
80107345:	c9                   	leave  
80107346:	c3                   	ret    

80107347 <ltr>:
{
80107347:	55                   	push   %ebp
80107348:	89 e5                	mov    %esp,%ebp
8010734a:	83 ec 04             	sub    $0x4,%esp
8010734d:	8b 45 08             	mov    0x8(%ebp),%eax
80107350:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107354:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107358:	0f 00 d8             	ltr    %ax
}
8010735b:	90                   	nop
8010735c:	c9                   	leave  
8010735d:	c3                   	ret    

8010735e <lcr3>:

static inline void
lcr3(uint val)
{
8010735e:	55                   	push   %ebp
8010735f:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107361:	8b 45 08             	mov    0x8(%ebp),%eax
80107364:	0f 22 d8             	mov    %eax,%cr3
}
80107367:	90                   	nop
80107368:	5d                   	pop    %ebp
80107369:	c3                   	ret    

8010736a <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010736a:	55                   	push   %ebp
8010736b:	89 e5                	mov    %esp,%ebp
8010736d:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107370:	e8 c4 c6 ff ff       	call   80103a39 <cpuid>
80107375:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
8010737b:	05 80 72 19 80       	add    $0x80197280,%eax
80107380:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107386:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010738c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107398:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010739c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073a3:	83 e2 f0             	and    $0xfffffff0,%edx
801073a6:	83 ca 0a             	or     $0xa,%edx
801073a9:	88 50 7d             	mov    %dl,0x7d(%eax)
801073ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073af:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073b3:	83 ca 10             	or     $0x10,%edx
801073b6:	88 50 7d             	mov    %dl,0x7d(%eax)
801073b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073c0:	83 e2 9f             	and    $0xffffff9f,%edx
801073c3:	88 50 7d             	mov    %dl,0x7d(%eax)
801073c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073cd:	83 ca 80             	or     $0xffffff80,%edx
801073d0:	88 50 7d             	mov    %dl,0x7d(%eax)
801073d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073da:	83 ca 0f             	or     $0xf,%edx
801073dd:	88 50 7e             	mov    %dl,0x7e(%eax)
801073e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073e7:	83 e2 ef             	and    $0xffffffef,%edx
801073ea:	88 50 7e             	mov    %dl,0x7e(%eax)
801073ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073f4:	83 e2 df             	and    $0xffffffdf,%edx
801073f7:	88 50 7e             	mov    %dl,0x7e(%eax)
801073fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107401:	83 ca 40             	or     $0x40,%edx
80107404:	88 50 7e             	mov    %dl,0x7e(%eax)
80107407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010740e:	83 ca 80             	or     $0xffffff80,%edx
80107411:	88 50 7e             	mov    %dl,0x7e(%eax)
80107414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107417:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010741b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107425:	ff ff 
80107427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107431:	00 00 
80107433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107436:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010743d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107440:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107447:	83 e2 f0             	and    $0xfffffff0,%edx
8010744a:	83 ca 02             	or     $0x2,%edx
8010744d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107456:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010745d:	83 ca 10             	or     $0x10,%edx
80107460:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107469:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107470:	83 e2 9f             	and    $0xffffff9f,%edx
80107473:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107483:	83 ca 80             	or     $0xffffff80,%edx
80107486:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010748c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107496:	83 ca 0f             	or     $0xf,%edx
80107499:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010749f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074a9:	83 e2 ef             	and    $0xffffffef,%edx
801074ac:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074bc:	83 e2 df             	and    $0xffffffdf,%edx
801074bf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074cf:	83 ca 40             	or     $0x40,%edx
801074d2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074db:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074e2:	83 ca 80             	or     $0xffffff80,%edx
801074e5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ee:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801074f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f8:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801074ff:	ff ff 
80107501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107504:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010750b:	00 00 
8010750d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107510:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107521:	83 e2 f0             	and    $0xfffffff0,%edx
80107524:	83 ca 0a             	or     $0xa,%edx
80107527:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010752d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107530:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107537:	83 ca 10             	or     $0x10,%edx
8010753a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107543:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010754a:	83 ca 60             	or     $0x60,%edx
8010754d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107556:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010755d:	83 ca 80             	or     $0xffffff80,%edx
80107560:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107569:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107570:	83 ca 0f             	or     $0xf,%edx
80107573:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107583:	83 e2 ef             	and    $0xffffffef,%edx
80107586:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010758c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107596:	83 e2 df             	and    $0xffffffdf,%edx
80107599:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010759f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075a9:	83 ca 40             	or     $0x40,%edx
801075ac:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075bc:	83 ca 80             	or     $0xffffff80,%edx
801075bf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c8:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801075cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d2:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801075d9:	ff ff 
801075db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075de:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801075e5:	00 00 
801075e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ea:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801075f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075fb:	83 e2 f0             	and    $0xfffffff0,%edx
801075fe:	83 ca 02             	or     $0x2,%edx
80107601:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107611:	83 ca 10             	or     $0x10,%edx
80107614:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010761a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107624:	83 ca 60             	or     $0x60,%edx
80107627:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010762d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107630:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107637:	83 ca 80             	or     $0xffffff80,%edx
8010763a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107643:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010764a:	83 ca 0f             	or     $0xf,%edx
8010764d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107656:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010765d:	83 e2 ef             	and    $0xffffffef,%edx
80107660:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107669:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107670:	83 e2 df             	and    $0xffffffdf,%edx
80107673:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107683:	83 ca 40             	or     $0x40,%edx
80107686:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010768c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107696:	83 ca 80             	or     $0xffffff80,%edx
80107699:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010769f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a2:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801076a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ac:	83 c0 70             	add    $0x70,%eax
801076af:	83 ec 08             	sub    $0x8,%esp
801076b2:	6a 30                	push   $0x30
801076b4:	50                   	push   %eax
801076b5:	e8 63 fc ff ff       	call   8010731d <lgdt>
801076ba:	83 c4 10             	add    $0x10,%esp
}
801076bd:	90                   	nop
801076be:	c9                   	leave  
801076bf:	c3                   	ret    

801076c0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801076c0:	55                   	push   %ebp
801076c1:	89 e5                	mov    %esp,%ebp
801076c3:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801076c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801076c9:	c1 e8 16             	shr    $0x16,%eax
801076cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076d3:	8b 45 08             	mov    0x8(%ebp),%eax
801076d6:	01 d0                	add    %edx,%eax
801076d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801076db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076de:	8b 00                	mov    (%eax),%eax
801076e0:	83 e0 01             	and    $0x1,%eax
801076e3:	85 c0                	test   %eax,%eax
801076e5:	74 14                	je     801076fb <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801076e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076ea:	8b 00                	mov    (%eax),%eax
801076ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076f1:	05 00 00 00 80       	add    $0x80000000,%eax
801076f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076f9:	eb 42                	jmp    8010773d <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801076fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801076ff:	74 0e                	je     8010770f <walkpgdir+0x4f>
80107701:	e8 9a b0 ff ff       	call   801027a0 <kalloc>
80107706:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010770d:	75 07                	jne    80107716 <walkpgdir+0x56>
      return 0;
8010770f:	b8 00 00 00 00       	mov    $0x0,%eax
80107714:	eb 3e                	jmp    80107754 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107716:	83 ec 04             	sub    $0x4,%esp
80107719:	68 00 10 00 00       	push   $0x1000
8010771e:	6a 00                	push   $0x0
80107720:	ff 75 f4             	push   -0xc(%ebp)
80107723:	e8 9c d5 ff ff       	call   80104cc4 <memset>
80107728:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010772b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772e:	05 00 00 00 80       	add    $0x80000000,%eax
80107733:	83 c8 07             	or     $0x7,%eax
80107736:	89 c2                	mov    %eax,%edx
80107738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010773b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010773d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107740:	c1 e8 0c             	shr    $0xc,%eax
80107743:	25 ff 03 00 00       	and    $0x3ff,%eax
80107748:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010774f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107752:	01 d0                	add    %edx,%eax
}
80107754:	c9                   	leave  
80107755:	c3                   	ret    

80107756 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107756:	55                   	push   %ebp
80107757:	89 e5                	mov    %esp,%ebp
80107759:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010775c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010775f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107764:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107767:	8b 55 0c             	mov    0xc(%ebp),%edx
8010776a:	8b 45 10             	mov    0x10(%ebp),%eax
8010776d:	01 d0                	add    %edx,%eax
8010776f:	83 e8 01             	sub    $0x1,%eax
80107772:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107777:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010777a:	83 ec 04             	sub    $0x4,%esp
8010777d:	6a 01                	push   $0x1
8010777f:	ff 75 f4             	push   -0xc(%ebp)
80107782:	ff 75 08             	push   0x8(%ebp)
80107785:	e8 36 ff ff ff       	call   801076c0 <walkpgdir>
8010778a:	83 c4 10             	add    $0x10,%esp
8010778d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107790:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107794:	75 07                	jne    8010779d <mappages+0x47>
      return -1;
80107796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010779b:	eb 47                	jmp    801077e4 <mappages+0x8e>
    if(*pte & PTE_P)
8010779d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077a0:	8b 00                	mov    (%eax),%eax
801077a2:	83 e0 01             	and    $0x1,%eax
801077a5:	85 c0                	test   %eax,%eax
801077a7:	74 0d                	je     801077b6 <mappages+0x60>
      panic("remap");
801077a9:	83 ec 0c             	sub    $0xc,%esp
801077ac:	68 b8 aa 10 80       	push   $0x8010aab8
801077b1:	e8 f3 8d ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801077b6:	8b 45 18             	mov    0x18(%ebp),%eax
801077b9:	0b 45 14             	or     0x14(%ebp),%eax
801077bc:	83 c8 01             	or     $0x1,%eax
801077bf:	89 c2                	mov    %eax,%edx
801077c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077c4:	89 10                	mov    %edx,(%eax)
    if(a == last)
801077c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801077cc:	74 10                	je     801077de <mappages+0x88>
      break;
    a += PGSIZE;
801077ce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801077d5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077dc:	eb 9c                	jmp    8010777a <mappages+0x24>
      break;
801077de:	90                   	nop
  }
  return 0;
801077df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077e4:	c9                   	leave  
801077e5:	c3                   	ret    

801077e6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801077e6:	55                   	push   %ebp
801077e7:	89 e5                	mov    %esp,%ebp
801077e9:	53                   	push   %ebx
801077ea:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801077ed:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801077f4:	8b 15 60 75 19 80    	mov    0x80197560,%edx
801077fa:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801077ff:	29 d0                	sub    %edx,%eax
80107801:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107804:	a1 58 75 19 80       	mov    0x80197558,%eax
80107809:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010780c:	8b 15 58 75 19 80    	mov    0x80197558,%edx
80107812:	a1 60 75 19 80       	mov    0x80197560,%eax
80107817:	01 d0                	add    %edx,%eax
80107819:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010781c:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107826:	83 c0 30             	add    $0x30,%eax
80107829:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010782c:	89 10                	mov    %edx,(%eax)
8010782e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107831:	89 50 04             	mov    %edx,0x4(%eax)
80107834:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107837:	89 50 08             	mov    %edx,0x8(%eax)
8010783a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010783d:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107840:	e8 5b af ff ff       	call   801027a0 <kalloc>
80107845:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107848:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010784c:	75 07                	jne    80107855 <setupkvm+0x6f>
    return 0;
8010784e:	b8 00 00 00 00       	mov    $0x0,%eax
80107853:	eb 78                	jmp    801078cd <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107855:	83 ec 04             	sub    $0x4,%esp
80107858:	68 00 10 00 00       	push   $0x1000
8010785d:	6a 00                	push   $0x0
8010785f:	ff 75 f0             	push   -0x10(%ebp)
80107862:	e8 5d d4 ff ff       	call   80104cc4 <memset>
80107867:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010786a:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107871:	eb 4e                	jmp    801078c1 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107876:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787c:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107882:	8b 58 08             	mov    0x8(%eax),%ebx
80107885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107888:	8b 40 04             	mov    0x4(%eax),%eax
8010788b:	29 c3                	sub    %eax,%ebx
8010788d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107890:	8b 00                	mov    (%eax),%eax
80107892:	83 ec 0c             	sub    $0xc,%esp
80107895:	51                   	push   %ecx
80107896:	52                   	push   %edx
80107897:	53                   	push   %ebx
80107898:	50                   	push   %eax
80107899:	ff 75 f0             	push   -0x10(%ebp)
8010789c:	e8 b5 fe ff ff       	call   80107756 <mappages>
801078a1:	83 c4 20             	add    $0x20,%esp
801078a4:	85 c0                	test   %eax,%eax
801078a6:	79 15                	jns    801078bd <setupkvm+0xd7>
      freevm(pgdir);
801078a8:	83 ec 0c             	sub    $0xc,%esp
801078ab:	ff 75 f0             	push   -0x10(%ebp)
801078ae:	e8 f5 04 00 00       	call   80107da8 <freevm>
801078b3:	83 c4 10             	add    $0x10,%esp
      return 0;
801078b6:	b8 00 00 00 00       	mov    $0x0,%eax
801078bb:	eb 10                	jmp    801078cd <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078bd:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801078c1:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
801078c8:	72 a9                	jb     80107873 <setupkvm+0x8d>
    }
  return pgdir;
801078ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801078cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801078d0:	c9                   	leave  
801078d1:	c3                   	ret    

801078d2 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801078d2:	55                   	push   %ebp
801078d3:	89 e5                	mov    %esp,%ebp
801078d5:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801078d8:	e8 09 ff ff ff       	call   801077e6 <setupkvm>
801078dd:	a3 7c 72 19 80       	mov    %eax,0x8019727c
  switchkvm();
801078e2:	e8 03 00 00 00       	call   801078ea <switchkvm>
}
801078e7:	90                   	nop
801078e8:	c9                   	leave  
801078e9:	c3                   	ret    

801078ea <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078ea:	55                   	push   %ebp
801078eb:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078ed:	a1 7c 72 19 80       	mov    0x8019727c,%eax
801078f2:	05 00 00 00 80       	add    $0x80000000,%eax
801078f7:	50                   	push   %eax
801078f8:	e8 61 fa ff ff       	call   8010735e <lcr3>
801078fd:	83 c4 04             	add    $0x4,%esp
}
80107900:	90                   	nop
80107901:	c9                   	leave  
80107902:	c3                   	ret    

80107903 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107903:	55                   	push   %ebp
80107904:	89 e5                	mov    %esp,%ebp
80107906:	56                   	push   %esi
80107907:	53                   	push   %ebx
80107908:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010790b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010790f:	75 0d                	jne    8010791e <switchuvm+0x1b>
    panic("switchuvm: no process");
80107911:	83 ec 0c             	sub    $0xc,%esp
80107914:	68 be aa 10 80       	push   $0x8010aabe
80107919:	e8 8b 8c ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010791e:	8b 45 08             	mov    0x8(%ebp),%eax
80107921:	8b 40 08             	mov    0x8(%eax),%eax
80107924:	85 c0                	test   %eax,%eax
80107926:	75 0d                	jne    80107935 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107928:	83 ec 0c             	sub    $0xc,%esp
8010792b:	68 d4 aa 10 80       	push   $0x8010aad4
80107930:	e8 74 8c ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107935:	8b 45 08             	mov    0x8(%ebp),%eax
80107938:	8b 40 04             	mov    0x4(%eax),%eax
8010793b:	85 c0                	test   %eax,%eax
8010793d:	75 0d                	jne    8010794c <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010793f:	83 ec 0c             	sub    $0xc,%esp
80107942:	68 e9 aa 10 80       	push   $0x8010aae9
80107947:	e8 5d 8c ff ff       	call   801005a9 <panic>

  pushcli();
8010794c:	e8 68 d2 ff ff       	call   80104bb9 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107951:	e8 fe c0 ff ff       	call   80103a54 <mycpu>
80107956:	89 c3                	mov    %eax,%ebx
80107958:	e8 f7 c0 ff ff       	call   80103a54 <mycpu>
8010795d:	83 c0 08             	add    $0x8,%eax
80107960:	89 c6                	mov    %eax,%esi
80107962:	e8 ed c0 ff ff       	call   80103a54 <mycpu>
80107967:	83 c0 08             	add    $0x8,%eax
8010796a:	c1 e8 10             	shr    $0x10,%eax
8010796d:	88 45 f7             	mov    %al,-0x9(%ebp)
80107970:	e8 df c0 ff ff       	call   80103a54 <mycpu>
80107975:	83 c0 08             	add    $0x8,%eax
80107978:	c1 e8 18             	shr    $0x18,%eax
8010797b:	89 c2                	mov    %eax,%edx
8010797d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107984:	67 00 
80107986:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010798d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107991:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107997:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010799e:	83 e0 f0             	and    $0xfffffff0,%eax
801079a1:	83 c8 09             	or     $0x9,%eax
801079a4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079aa:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079b1:	83 c8 10             	or     $0x10,%eax
801079b4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079ba:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079c1:	83 e0 9f             	and    $0xffffff9f,%eax
801079c4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079ca:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079d1:	83 c8 80             	or     $0xffffff80,%eax
801079d4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079da:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079e1:	83 e0 f0             	and    $0xfffffff0,%eax
801079e4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079ea:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079f1:	83 e0 ef             	and    $0xffffffef,%eax
801079f4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079fa:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a01:	83 e0 df             	and    $0xffffffdf,%eax
80107a04:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a0a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a11:	83 c8 40             	or     $0x40,%eax
80107a14:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a1a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a21:	83 e0 7f             	and    $0x7f,%eax
80107a24:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a2a:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a30:	e8 1f c0 ff ff       	call   80103a54 <mycpu>
80107a35:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a3c:	83 e2 ef             	and    $0xffffffef,%edx
80107a3f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a45:	e8 0a c0 ff ff       	call   80103a54 <mycpu>
80107a4a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a50:	8b 45 08             	mov    0x8(%ebp),%eax
80107a53:	8b 40 08             	mov    0x8(%eax),%eax
80107a56:	89 c3                	mov    %eax,%ebx
80107a58:	e8 f7 bf ff ff       	call   80103a54 <mycpu>
80107a5d:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a63:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a66:	e8 e9 bf ff ff       	call   80103a54 <mycpu>
80107a6b:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a71:	83 ec 0c             	sub    $0xc,%esp
80107a74:	6a 28                	push   $0x28
80107a76:	e8 cc f8 ff ff       	call   80107347 <ltr>
80107a7b:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80107a81:	8b 40 04             	mov    0x4(%eax),%eax
80107a84:	05 00 00 00 80       	add    $0x80000000,%eax
80107a89:	83 ec 0c             	sub    $0xc,%esp
80107a8c:	50                   	push   %eax
80107a8d:	e8 cc f8 ff ff       	call   8010735e <lcr3>
80107a92:	83 c4 10             	add    $0x10,%esp
  popcli();
80107a95:	e8 6c d1 ff ff       	call   80104c06 <popcli>
}
80107a9a:	90                   	nop
80107a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107a9e:	5b                   	pop    %ebx
80107a9f:	5e                   	pop    %esi
80107aa0:	5d                   	pop    %ebp
80107aa1:	c3                   	ret    

80107aa2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107aa2:	55                   	push   %ebp
80107aa3:	89 e5                	mov    %esp,%ebp
80107aa5:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107aa8:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107aaf:	76 0d                	jbe    80107abe <inituvm+0x1c>
    panic("inituvm: more than a page");
80107ab1:	83 ec 0c             	sub    $0xc,%esp
80107ab4:	68 fd aa 10 80       	push   $0x8010aafd
80107ab9:	e8 eb 8a ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107abe:	e8 dd ac ff ff       	call   801027a0 <kalloc>
80107ac3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107ac6:	83 ec 04             	sub    $0x4,%esp
80107ac9:	68 00 10 00 00       	push   $0x1000
80107ace:	6a 00                	push   $0x0
80107ad0:	ff 75 f4             	push   -0xc(%ebp)
80107ad3:	e8 ec d1 ff ff       	call   80104cc4 <memset>
80107ad8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ade:	05 00 00 00 80       	add    $0x80000000,%eax
80107ae3:	83 ec 0c             	sub    $0xc,%esp
80107ae6:	6a 06                	push   $0x6
80107ae8:	50                   	push   %eax
80107ae9:	68 00 10 00 00       	push   $0x1000
80107aee:	6a 00                	push   $0x0
80107af0:	ff 75 08             	push   0x8(%ebp)
80107af3:	e8 5e fc ff ff       	call   80107756 <mappages>
80107af8:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107afb:	83 ec 04             	sub    $0x4,%esp
80107afe:	ff 75 10             	push   0x10(%ebp)
80107b01:	ff 75 0c             	push   0xc(%ebp)
80107b04:	ff 75 f4             	push   -0xc(%ebp)
80107b07:	e8 77 d2 ff ff       	call   80104d83 <memmove>
80107b0c:	83 c4 10             	add    $0x10,%esp
}
80107b0f:	90                   	nop
80107b10:	c9                   	leave  
80107b11:	c3                   	ret    

80107b12 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b12:	55                   	push   %ebp
80107b13:	89 e5                	mov    %esp,%ebp
80107b15:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b18:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b1b:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b20:	85 c0                	test   %eax,%eax
80107b22:	74 0d                	je     80107b31 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107b24:	83 ec 0c             	sub    $0xc,%esp
80107b27:	68 18 ab 10 80       	push   $0x8010ab18
80107b2c:	e8 78 8a ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b38:	e9 8f 00 00 00       	jmp    80107bcc <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b43:	01 d0                	add    %edx,%eax
80107b45:	83 ec 04             	sub    $0x4,%esp
80107b48:	6a 00                	push   $0x0
80107b4a:	50                   	push   %eax
80107b4b:	ff 75 08             	push   0x8(%ebp)
80107b4e:	e8 6d fb ff ff       	call   801076c0 <walkpgdir>
80107b53:	83 c4 10             	add    $0x10,%esp
80107b56:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b59:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b5d:	75 0d                	jne    80107b6c <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107b5f:	83 ec 0c             	sub    $0xc,%esp
80107b62:	68 3b ab 10 80       	push   $0x8010ab3b
80107b67:	e8 3d 8a ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b6f:	8b 00                	mov    (%eax),%eax
80107b71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b76:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b79:	8b 45 18             	mov    0x18(%ebp),%eax
80107b7c:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b7f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b84:	77 0b                	ja     80107b91 <loaduvm+0x7f>
      n = sz - i;
80107b86:	8b 45 18             	mov    0x18(%ebp),%eax
80107b89:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b8f:	eb 07                	jmp    80107b98 <loaduvm+0x86>
    else
      n = PGSIZE;
80107b91:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107b98:	8b 55 14             	mov    0x14(%ebp),%edx
80107b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9e:	01 d0                	add    %edx,%eax
80107ba0:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107ba3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107ba9:	ff 75 f0             	push   -0x10(%ebp)
80107bac:	50                   	push   %eax
80107bad:	52                   	push   %edx
80107bae:	ff 75 10             	push   0x10(%ebp)
80107bb1:	e8 20 a3 ff ff       	call   80101ed6 <readi>
80107bb6:	83 c4 10             	add    $0x10,%esp
80107bb9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107bbc:	74 07                	je     80107bc5 <loaduvm+0xb3>
      return -1;
80107bbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bc3:	eb 18                	jmp    80107bdd <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107bc5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcf:	3b 45 18             	cmp    0x18(%ebp),%eax
80107bd2:	0f 82 65 ff ff ff    	jb     80107b3d <loaduvm+0x2b>
  }
  return 0;
80107bd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bdd:	c9                   	leave  
80107bde:	c3                   	ret    

80107bdf <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107bdf:	55                   	push   %ebp
80107be0:	89 e5                	mov    %esp,%ebp
80107be2:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107be5:	8b 45 10             	mov    0x10(%ebp),%eax
80107be8:	85 c0                	test   %eax,%eax
80107bea:	79 0a                	jns    80107bf6 <allocuvm+0x17>
    return 0;
80107bec:	b8 00 00 00 00       	mov    $0x0,%eax
80107bf1:	e9 ec 00 00 00       	jmp    80107ce2 <allocuvm+0x103>
  if(newsz < oldsz)
80107bf6:	8b 45 10             	mov    0x10(%ebp),%eax
80107bf9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107bfc:	73 08                	jae    80107c06 <allocuvm+0x27>
    return oldsz;
80107bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c01:	e9 dc 00 00 00       	jmp    80107ce2 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107c06:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c09:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c16:	e9 b8 00 00 00       	jmp    80107cd3 <allocuvm+0xf4>
    mem = kalloc();
80107c1b:	e8 80 ab ff ff       	call   801027a0 <kalloc>
80107c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c27:	75 2e                	jne    80107c57 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107c29:	83 ec 0c             	sub    $0xc,%esp
80107c2c:	68 59 ab 10 80       	push   $0x8010ab59
80107c31:	e8 be 87 ff ff       	call   801003f4 <cprintf>
80107c36:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c39:	83 ec 04             	sub    $0x4,%esp
80107c3c:	ff 75 0c             	push   0xc(%ebp)
80107c3f:	ff 75 10             	push   0x10(%ebp)
80107c42:	ff 75 08             	push   0x8(%ebp)
80107c45:	e8 9a 00 00 00       	call   80107ce4 <deallocuvm>
80107c4a:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c4d:	b8 00 00 00 00       	mov    $0x0,%eax
80107c52:	e9 8b 00 00 00       	jmp    80107ce2 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107c57:	83 ec 04             	sub    $0x4,%esp
80107c5a:	68 00 10 00 00       	push   $0x1000
80107c5f:	6a 00                	push   $0x0
80107c61:	ff 75 f0             	push   -0x10(%ebp)
80107c64:	e8 5b d0 ff ff       	call   80104cc4 <memset>
80107c69:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c6f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c78:	83 ec 0c             	sub    $0xc,%esp
80107c7b:	6a 06                	push   $0x6
80107c7d:	52                   	push   %edx
80107c7e:	68 00 10 00 00       	push   $0x1000
80107c83:	50                   	push   %eax
80107c84:	ff 75 08             	push   0x8(%ebp)
80107c87:	e8 ca fa ff ff       	call   80107756 <mappages>
80107c8c:	83 c4 20             	add    $0x20,%esp
80107c8f:	85 c0                	test   %eax,%eax
80107c91:	79 39                	jns    80107ccc <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107c93:	83 ec 0c             	sub    $0xc,%esp
80107c96:	68 71 ab 10 80       	push   $0x8010ab71
80107c9b:	e8 54 87 ff ff       	call   801003f4 <cprintf>
80107ca0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ca3:	83 ec 04             	sub    $0x4,%esp
80107ca6:	ff 75 0c             	push   0xc(%ebp)
80107ca9:	ff 75 10             	push   0x10(%ebp)
80107cac:	ff 75 08             	push   0x8(%ebp)
80107caf:	e8 30 00 00 00       	call   80107ce4 <deallocuvm>
80107cb4:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107cb7:	83 ec 0c             	sub    $0xc,%esp
80107cba:	ff 75 f0             	push   -0x10(%ebp)
80107cbd:	e8 44 aa ff ff       	call   80102706 <kfree>
80107cc2:	83 c4 10             	add    $0x10,%esp
      return 0;
80107cc5:	b8 00 00 00 00       	mov    $0x0,%eax
80107cca:	eb 16                	jmp    80107ce2 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107ccc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	3b 45 10             	cmp    0x10(%ebp),%eax
80107cd9:	0f 82 3c ff ff ff    	jb     80107c1b <allocuvm+0x3c>
    }
  }
  return newsz;
80107cdf:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ce2:	c9                   	leave  
80107ce3:	c3                   	ret    

80107ce4 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ce4:	55                   	push   %ebp
80107ce5:	89 e5                	mov    %esp,%ebp
80107ce7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107cea:	8b 45 10             	mov    0x10(%ebp),%eax
80107ced:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107cf0:	72 08                	jb     80107cfa <deallocuvm+0x16>
    return oldsz;
80107cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cf5:	e9 ac 00 00 00       	jmp    80107da6 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107cfa:	8b 45 10             	mov    0x10(%ebp),%eax
80107cfd:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d0a:	e9 88 00 00 00       	jmp    80107d97 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d12:	83 ec 04             	sub    $0x4,%esp
80107d15:	6a 00                	push   $0x0
80107d17:	50                   	push   %eax
80107d18:	ff 75 08             	push   0x8(%ebp)
80107d1b:	e8 a0 f9 ff ff       	call   801076c0 <walkpgdir>
80107d20:	83 c4 10             	add    $0x10,%esp
80107d23:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d2a:	75 16                	jne    80107d42 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2f:	c1 e8 16             	shr    $0x16,%eax
80107d32:	83 c0 01             	add    $0x1,%eax
80107d35:	c1 e0 16             	shl    $0x16,%eax
80107d38:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d40:	eb 4e                	jmp    80107d90 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d45:	8b 00                	mov    (%eax),%eax
80107d47:	83 e0 01             	and    $0x1,%eax
80107d4a:	85 c0                	test   %eax,%eax
80107d4c:	74 42                	je     80107d90 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d51:	8b 00                	mov    (%eax),%eax
80107d53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d58:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d5b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d5f:	75 0d                	jne    80107d6e <deallocuvm+0x8a>
        panic("kfree");
80107d61:	83 ec 0c             	sub    $0xc,%esp
80107d64:	68 8d ab 10 80       	push   $0x8010ab8d
80107d69:	e8 3b 88 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107d6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d71:	05 00 00 00 80       	add    $0x80000000,%eax
80107d76:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107d79:	83 ec 0c             	sub    $0xc,%esp
80107d7c:	ff 75 e8             	push   -0x18(%ebp)
80107d7f:	e8 82 a9 ff ff       	call   80102706 <kfree>
80107d84:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d8a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107d90:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d9d:	0f 82 6c ff ff ff    	jb     80107d0f <deallocuvm+0x2b>
    }
  }
  return newsz;
80107da3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107da6:	c9                   	leave  
80107da7:	c3                   	ret    

80107da8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107da8:	55                   	push   %ebp
80107da9:	89 e5                	mov    %esp,%ebp
80107dab:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107dae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107db2:	75 0d                	jne    80107dc1 <freevm+0x19>
    panic("freevm: no pgdir");
80107db4:	83 ec 0c             	sub    $0xc,%esp
80107db7:	68 93 ab 10 80       	push   $0x8010ab93
80107dbc:	e8 e8 87 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107dc1:	83 ec 04             	sub    $0x4,%esp
80107dc4:	6a 00                	push   $0x0
80107dc6:	68 00 00 00 80       	push   $0x80000000
80107dcb:	ff 75 08             	push   0x8(%ebp)
80107dce:	e8 11 ff ff ff       	call   80107ce4 <deallocuvm>
80107dd3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107dd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ddd:	eb 48                	jmp    80107e27 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107de9:	8b 45 08             	mov    0x8(%ebp),%eax
80107dec:	01 d0                	add    %edx,%eax
80107dee:	8b 00                	mov    (%eax),%eax
80107df0:	83 e0 01             	and    $0x1,%eax
80107df3:	85 c0                	test   %eax,%eax
80107df5:	74 2c                	je     80107e23 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e01:	8b 45 08             	mov    0x8(%ebp),%eax
80107e04:	01 d0                	add    %edx,%eax
80107e06:	8b 00                	mov    (%eax),%eax
80107e08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e0d:	05 00 00 00 80       	add    $0x80000000,%eax
80107e12:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e15:	83 ec 0c             	sub    $0xc,%esp
80107e18:	ff 75 f0             	push   -0x10(%ebp)
80107e1b:	e8 e6 a8 ff ff       	call   80102706 <kfree>
80107e20:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e27:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e2e:	76 af                	jbe    80107ddf <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107e30:	83 ec 0c             	sub    $0xc,%esp
80107e33:	ff 75 08             	push   0x8(%ebp)
80107e36:	e8 cb a8 ff ff       	call   80102706 <kfree>
80107e3b:	83 c4 10             	add    $0x10,%esp
}
80107e3e:	90                   	nop
80107e3f:	c9                   	leave  
80107e40:	c3                   	ret    

80107e41 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e41:	55                   	push   %ebp
80107e42:	89 e5                	mov    %esp,%ebp
80107e44:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e47:	83 ec 04             	sub    $0x4,%esp
80107e4a:	6a 00                	push   $0x0
80107e4c:	ff 75 0c             	push   0xc(%ebp)
80107e4f:	ff 75 08             	push   0x8(%ebp)
80107e52:	e8 69 f8 ff ff       	call   801076c0 <walkpgdir>
80107e57:	83 c4 10             	add    $0x10,%esp
80107e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e61:	75 0d                	jne    80107e70 <clearpteu+0x2f>
    panic("clearpteu");
80107e63:	83 ec 0c             	sub    $0xc,%esp
80107e66:	68 a4 ab 10 80       	push   $0x8010aba4
80107e6b:	e8 39 87 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e73:	8b 00                	mov    (%eax),%eax
80107e75:	83 e0 fb             	and    $0xfffffffb,%eax
80107e78:	89 c2                	mov    %eax,%edx
80107e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7d:	89 10                	mov    %edx,(%eax)
}
80107e7f:	90                   	nop
80107e80:	c9                   	leave  
80107e81:	c3                   	ret    

80107e82 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e82:	55                   	push   %ebp
80107e83:	89 e5                	mov    %esp,%ebp
80107e85:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107e88:	e8 59 f9 ff ff       	call   801077e6 <setupkvm>
80107e8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e94:	75 0a                	jne    80107ea0 <copyuvm+0x1e>
    return 0;
80107e96:	b8 00 00 00 00       	mov    $0x0,%eax
80107e9b:	e9 eb 00 00 00       	jmp    80107f8b <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107ea0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ea7:	e9 b7 00 00 00       	jmp    80107f63 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaf:	83 ec 04             	sub    $0x4,%esp
80107eb2:	6a 00                	push   $0x0
80107eb4:	50                   	push   %eax
80107eb5:	ff 75 08             	push   0x8(%ebp)
80107eb8:	e8 03 f8 ff ff       	call   801076c0 <walkpgdir>
80107ebd:	83 c4 10             	add    $0x10,%esp
80107ec0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ec3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ec7:	75 0d                	jne    80107ed6 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107ec9:	83 ec 0c             	sub    $0xc,%esp
80107ecc:	68 ae ab 10 80       	push   $0x8010abae
80107ed1:	e8 d3 86 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107ed6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ed9:	8b 00                	mov    (%eax),%eax
80107edb:	83 e0 01             	and    $0x1,%eax
80107ede:	85 c0                	test   %eax,%eax
80107ee0:	75 0d                	jne    80107eef <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107ee2:	83 ec 0c             	sub    $0xc,%esp
80107ee5:	68 c8 ab 10 80       	push   $0x8010abc8
80107eea:	e8 ba 86 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ef2:	8b 00                	mov    (%eax),%eax
80107ef4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ef9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eff:	8b 00                	mov    (%eax),%eax
80107f01:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107f09:	e8 92 a8 ff ff       	call   801027a0 <kalloc>
80107f0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f15:	74 5d                	je     80107f74 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107f17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f1a:	05 00 00 00 80       	add    $0x80000000,%eax
80107f1f:	83 ec 04             	sub    $0x4,%esp
80107f22:	68 00 10 00 00       	push   $0x1000
80107f27:	50                   	push   %eax
80107f28:	ff 75 e0             	push   -0x20(%ebp)
80107f2b:	e8 53 ce ff ff       	call   80104d83 <memmove>
80107f30:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107f33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f39:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f42:	83 ec 0c             	sub    $0xc,%esp
80107f45:	52                   	push   %edx
80107f46:	51                   	push   %ecx
80107f47:	68 00 10 00 00       	push   $0x1000
80107f4c:	50                   	push   %eax
80107f4d:	ff 75 f0             	push   -0x10(%ebp)
80107f50:	e8 01 f8 ff ff       	call   80107756 <mappages>
80107f55:	83 c4 20             	add    $0x20,%esp
80107f58:	85 c0                	test   %eax,%eax
80107f5a:	78 1b                	js     80107f77 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107f5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f66:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f69:	0f 82 3d ff ff ff    	jb     80107eac <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f72:	eb 17                	jmp    80107f8b <copyuvm+0x109>
      goto bad;
80107f74:	90                   	nop
80107f75:	eb 01                	jmp    80107f78 <copyuvm+0xf6>
      goto bad;
80107f77:	90                   	nop

bad:
  freevm(d);
80107f78:	83 ec 0c             	sub    $0xc,%esp
80107f7b:	ff 75 f0             	push   -0x10(%ebp)
80107f7e:	e8 25 fe ff ff       	call   80107da8 <freevm>
80107f83:	83 c4 10             	add    $0x10,%esp
  return 0;
80107f86:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f8b:	c9                   	leave  
80107f8c:	c3                   	ret    

80107f8d <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107f8d:	55                   	push   %ebp
80107f8e:	89 e5                	mov    %esp,%ebp
80107f90:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f93:	83 ec 04             	sub    $0x4,%esp
80107f96:	6a 00                	push   $0x0
80107f98:	ff 75 0c             	push   0xc(%ebp)
80107f9b:	ff 75 08             	push   0x8(%ebp)
80107f9e:	e8 1d f7 ff ff       	call   801076c0 <walkpgdir>
80107fa3:	83 c4 10             	add    $0x10,%esp
80107fa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fac:	8b 00                	mov    (%eax),%eax
80107fae:	83 e0 01             	and    $0x1,%eax
80107fb1:	85 c0                	test   %eax,%eax
80107fb3:	75 07                	jne    80107fbc <uva2ka+0x2f>
    return 0;
80107fb5:	b8 00 00 00 00       	mov    $0x0,%eax
80107fba:	eb 22                	jmp    80107fde <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbf:	8b 00                	mov    (%eax),%eax
80107fc1:	83 e0 04             	and    $0x4,%eax
80107fc4:	85 c0                	test   %eax,%eax
80107fc6:	75 07                	jne    80107fcf <uva2ka+0x42>
    return 0;
80107fc8:	b8 00 00 00 00       	mov    $0x0,%eax
80107fcd:	eb 0f                	jmp    80107fde <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd2:	8b 00                	mov    (%eax),%eax
80107fd4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fd9:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107fde:	c9                   	leave  
80107fdf:	c3                   	ret    

80107fe0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107fe0:	55                   	push   %ebp
80107fe1:	89 e5                	mov    %esp,%ebp
80107fe3:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80107fe9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107fec:	eb 7f                	jmp    8010806d <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ff1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ff6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107ff9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ffc:	83 ec 08             	sub    $0x8,%esp
80107fff:	50                   	push   %eax
80108000:	ff 75 08             	push   0x8(%ebp)
80108003:	e8 85 ff ff ff       	call   80107f8d <uva2ka>
80108008:	83 c4 10             	add    $0x10,%esp
8010800b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010800e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108012:	75 07                	jne    8010801b <copyout+0x3b>
      return -1;
80108014:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108019:	eb 61                	jmp    8010807c <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010801b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010801e:	2b 45 0c             	sub    0xc(%ebp),%eax
80108021:	05 00 10 00 00       	add    $0x1000,%eax
80108026:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010802f:	76 06                	jbe    80108037 <copyout+0x57>
      n = len;
80108031:	8b 45 14             	mov    0x14(%ebp),%eax
80108034:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108037:	8b 45 0c             	mov    0xc(%ebp),%eax
8010803a:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010803d:	89 c2                	mov    %eax,%edx
8010803f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108042:	01 d0                	add    %edx,%eax
80108044:	83 ec 04             	sub    $0x4,%esp
80108047:	ff 75 f0             	push   -0x10(%ebp)
8010804a:	ff 75 f4             	push   -0xc(%ebp)
8010804d:	50                   	push   %eax
8010804e:	e8 30 cd ff ff       	call   80104d83 <memmove>
80108053:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108059:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010805c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010805f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108062:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108065:	05 00 10 00 00       	add    $0x1000,%eax
8010806a:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010806d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108071:	0f 85 77 ff ff ff    	jne    80107fee <copyout+0xe>
  }
  return 0;
80108077:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010807c:	c9                   	leave  
8010807d:	c3                   	ret    

8010807e <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010807e:	55                   	push   %ebp
8010807f:	89 e5                	mov    %esp,%ebp
80108081:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108084:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
8010808b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010808e:	8b 40 08             	mov    0x8(%eax),%eax
80108091:	05 00 00 00 80       	add    $0x80000000,%eax
80108096:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108099:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801080a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a3:	8b 40 24             	mov    0x24(%eax),%eax
801080a6:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
801080ab:	c7 05 50 75 19 80 00 	movl   $0x0,0x80197550
801080b2:	00 00 00 

  while(i<madt->len){
801080b5:	90                   	nop
801080b6:	e9 bd 00 00 00       	jmp    80108178 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
801080bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080c1:	01 d0                	add    %edx,%eax
801080c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801080c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c9:	0f b6 00             	movzbl (%eax),%eax
801080cc:	0f b6 c0             	movzbl %al,%eax
801080cf:	83 f8 05             	cmp    $0x5,%eax
801080d2:	0f 87 a0 00 00 00    	ja     80108178 <mpinit_uefi+0xfa>
801080d8:	8b 04 85 e4 ab 10 80 	mov    -0x7fef541c(,%eax,4),%eax
801080df:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801080e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801080e7:	a1 50 75 19 80       	mov    0x80197550,%eax
801080ec:	83 f8 03             	cmp    $0x3,%eax
801080ef:	7f 28                	jg     80108119 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801080f1:	8b 15 50 75 19 80    	mov    0x80197550,%edx
801080f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080fa:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801080fe:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108104:	81 c2 80 72 19 80    	add    $0x80197280,%edx
8010810a:	88 02                	mov    %al,(%edx)
          ncpu++;
8010810c:	a1 50 75 19 80       	mov    0x80197550,%eax
80108111:	83 c0 01             	add    $0x1,%eax
80108114:	a3 50 75 19 80       	mov    %eax,0x80197550
        }
        i += lapic_entry->record_len;
80108119:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010811c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108120:	0f b6 c0             	movzbl %al,%eax
80108123:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108126:	eb 50                	jmp    80108178 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010812b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010812e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108131:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108135:	a2 54 75 19 80       	mov    %al,0x80197554
        i += ioapic->record_len;
8010813a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010813d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108141:	0f b6 c0             	movzbl %al,%eax
80108144:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108147:	eb 2f                	jmp    80108178 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108149:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010814c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010814f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108152:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108156:	0f b6 c0             	movzbl %al,%eax
80108159:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010815c:	eb 1a                	jmp    80108178 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010815e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108161:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108164:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108167:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010816b:	0f b6 c0             	movzbl %al,%eax
8010816e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108171:	eb 05                	jmp    80108178 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80108173:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108177:	90                   	nop
  while(i<madt->len){
80108178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817b:	8b 40 04             	mov    0x4(%eax),%eax
8010817e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108181:	0f 82 34 ff ff ff    	jb     801080bb <mpinit_uefi+0x3d>
    }
  }

}
80108187:	90                   	nop
80108188:	90                   	nop
80108189:	c9                   	leave  
8010818a:	c3                   	ret    

8010818b <inb>:
{
8010818b:	55                   	push   %ebp
8010818c:	89 e5                	mov    %esp,%ebp
8010818e:	83 ec 14             	sub    $0x14,%esp
80108191:	8b 45 08             	mov    0x8(%ebp),%eax
80108194:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108198:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010819c:	89 c2                	mov    %eax,%edx
8010819e:	ec                   	in     (%dx),%al
8010819f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801081a2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801081a6:	c9                   	leave  
801081a7:	c3                   	ret    

801081a8 <outb>:
{
801081a8:	55                   	push   %ebp
801081a9:	89 e5                	mov    %esp,%ebp
801081ab:	83 ec 08             	sub    $0x8,%esp
801081ae:	8b 45 08             	mov    0x8(%ebp),%eax
801081b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801081b4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801081b8:	89 d0                	mov    %edx,%eax
801081ba:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801081bd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801081c1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801081c5:	ee                   	out    %al,(%dx)
}
801081c6:	90                   	nop
801081c7:	c9                   	leave  
801081c8:	c3                   	ret    

801081c9 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801081c9:	55                   	push   %ebp
801081ca:	89 e5                	mov    %esp,%ebp
801081cc:	83 ec 28             	sub    $0x28,%esp
801081cf:	8b 45 08             	mov    0x8(%ebp),%eax
801081d2:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801081d5:	6a 00                	push   $0x0
801081d7:	68 fa 03 00 00       	push   $0x3fa
801081dc:	e8 c7 ff ff ff       	call   801081a8 <outb>
801081e1:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801081e4:	68 80 00 00 00       	push   $0x80
801081e9:	68 fb 03 00 00       	push   $0x3fb
801081ee:	e8 b5 ff ff ff       	call   801081a8 <outb>
801081f3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801081f6:	6a 0c                	push   $0xc
801081f8:	68 f8 03 00 00       	push   $0x3f8
801081fd:	e8 a6 ff ff ff       	call   801081a8 <outb>
80108202:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108205:	6a 00                	push   $0x0
80108207:	68 f9 03 00 00       	push   $0x3f9
8010820c:	e8 97 ff ff ff       	call   801081a8 <outb>
80108211:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108214:	6a 03                	push   $0x3
80108216:	68 fb 03 00 00       	push   $0x3fb
8010821b:	e8 88 ff ff ff       	call   801081a8 <outb>
80108220:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108223:	6a 00                	push   $0x0
80108225:	68 fc 03 00 00       	push   $0x3fc
8010822a:	e8 79 ff ff ff       	call   801081a8 <outb>
8010822f:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108232:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108239:	eb 11                	jmp    8010824c <uart_debug+0x83>
8010823b:	83 ec 0c             	sub    $0xc,%esp
8010823e:	6a 0a                	push   $0xa
80108240:	e8 f2 a8 ff ff       	call   80102b37 <microdelay>
80108245:	83 c4 10             	add    $0x10,%esp
80108248:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010824c:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108250:	7f 1a                	jg     8010826c <uart_debug+0xa3>
80108252:	83 ec 0c             	sub    $0xc,%esp
80108255:	68 fd 03 00 00       	push   $0x3fd
8010825a:	e8 2c ff ff ff       	call   8010818b <inb>
8010825f:	83 c4 10             	add    $0x10,%esp
80108262:	0f b6 c0             	movzbl %al,%eax
80108265:	83 e0 20             	and    $0x20,%eax
80108268:	85 c0                	test   %eax,%eax
8010826a:	74 cf                	je     8010823b <uart_debug+0x72>
  outb(COM1+0, p);
8010826c:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108270:	0f b6 c0             	movzbl %al,%eax
80108273:	83 ec 08             	sub    $0x8,%esp
80108276:	50                   	push   %eax
80108277:	68 f8 03 00 00       	push   $0x3f8
8010827c:	e8 27 ff ff ff       	call   801081a8 <outb>
80108281:	83 c4 10             	add    $0x10,%esp
}
80108284:	90                   	nop
80108285:	c9                   	leave  
80108286:	c3                   	ret    

80108287 <uart_debugs>:

void uart_debugs(char *p){
80108287:	55                   	push   %ebp
80108288:	89 e5                	mov    %esp,%ebp
8010828a:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010828d:	eb 1b                	jmp    801082aa <uart_debugs+0x23>
    uart_debug(*p++);
8010828f:	8b 45 08             	mov    0x8(%ebp),%eax
80108292:	8d 50 01             	lea    0x1(%eax),%edx
80108295:	89 55 08             	mov    %edx,0x8(%ebp)
80108298:	0f b6 00             	movzbl (%eax),%eax
8010829b:	0f be c0             	movsbl %al,%eax
8010829e:	83 ec 0c             	sub    $0xc,%esp
801082a1:	50                   	push   %eax
801082a2:	e8 22 ff ff ff       	call   801081c9 <uart_debug>
801082a7:	83 c4 10             	add    $0x10,%esp
  while(*p){
801082aa:	8b 45 08             	mov    0x8(%ebp),%eax
801082ad:	0f b6 00             	movzbl (%eax),%eax
801082b0:	84 c0                	test   %al,%al
801082b2:	75 db                	jne    8010828f <uart_debugs+0x8>
  }
}
801082b4:	90                   	nop
801082b5:	90                   	nop
801082b6:	c9                   	leave  
801082b7:	c3                   	ret    

801082b8 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801082b8:	55                   	push   %ebp
801082b9:	89 e5                	mov    %esp,%ebp
801082bb:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801082be:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801082c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082c8:	8b 50 14             	mov    0x14(%eax),%edx
801082cb:	8b 40 10             	mov    0x10(%eax),%eax
801082ce:	a3 58 75 19 80       	mov    %eax,0x80197558
  gpu.vram_size = boot_param->graphic_config.frame_size;
801082d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082d6:	8b 50 1c             	mov    0x1c(%eax),%edx
801082d9:	8b 40 18             	mov    0x18(%eax),%eax
801082dc:	a3 60 75 19 80       	mov    %eax,0x80197560
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801082e1:	8b 15 60 75 19 80    	mov    0x80197560,%edx
801082e7:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801082ec:	29 d0                	sub    %edx,%eax
801082ee:	a3 5c 75 19 80       	mov    %eax,0x8019755c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801082f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082f6:	8b 50 24             	mov    0x24(%eax),%edx
801082f9:	8b 40 20             	mov    0x20(%eax),%eax
801082fc:	a3 64 75 19 80       	mov    %eax,0x80197564
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108301:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108304:	8b 50 2c             	mov    0x2c(%eax),%edx
80108307:	8b 40 28             	mov    0x28(%eax),%eax
8010830a:	a3 68 75 19 80       	mov    %eax,0x80197568
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010830f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108312:	8b 50 34             	mov    0x34(%eax),%edx
80108315:	8b 40 30             	mov    0x30(%eax),%eax
80108318:	a3 6c 75 19 80       	mov    %eax,0x8019756c
}
8010831d:	90                   	nop
8010831e:	c9                   	leave  
8010831f:	c3                   	ret    

80108320 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108320:	55                   	push   %ebp
80108321:	89 e5                	mov    %esp,%ebp
80108323:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108326:	8b 15 6c 75 19 80    	mov    0x8019756c,%edx
8010832c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010832f:	0f af d0             	imul   %eax,%edx
80108332:	8b 45 08             	mov    0x8(%ebp),%eax
80108335:	01 d0                	add    %edx,%eax
80108337:	c1 e0 02             	shl    $0x2,%eax
8010833a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
8010833d:	8b 15 5c 75 19 80    	mov    0x8019755c,%edx
80108343:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108346:	01 d0                	add    %edx,%eax
80108348:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
8010834b:	8b 45 10             	mov    0x10(%ebp),%eax
8010834e:	0f b6 10             	movzbl (%eax),%edx
80108351:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108354:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108356:	8b 45 10             	mov    0x10(%ebp),%eax
80108359:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010835d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108360:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108363:	8b 45 10             	mov    0x10(%ebp),%eax
80108366:	0f b6 50 02          	movzbl 0x2(%eax),%edx
8010836a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010836d:	88 50 02             	mov    %dl,0x2(%eax)
}
80108370:	90                   	nop
80108371:	c9                   	leave  
80108372:	c3                   	ret    

80108373 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108373:	55                   	push   %ebp
80108374:	89 e5                	mov    %esp,%ebp
80108376:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108379:	8b 15 6c 75 19 80    	mov    0x8019756c,%edx
8010837f:	8b 45 08             	mov    0x8(%ebp),%eax
80108382:	0f af c2             	imul   %edx,%eax
80108385:	c1 e0 02             	shl    $0x2,%eax
80108388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
8010838b:	a1 60 75 19 80       	mov    0x80197560,%eax
80108390:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108393:	29 d0                	sub    %edx,%eax
80108395:	8b 0d 5c 75 19 80    	mov    0x8019755c,%ecx
8010839b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010839e:	01 ca                	add    %ecx,%edx
801083a0:	89 d1                	mov    %edx,%ecx
801083a2:	8b 15 5c 75 19 80    	mov    0x8019755c,%edx
801083a8:	83 ec 04             	sub    $0x4,%esp
801083ab:	50                   	push   %eax
801083ac:	51                   	push   %ecx
801083ad:	52                   	push   %edx
801083ae:	e8 d0 c9 ff ff       	call   80104d83 <memmove>
801083b3:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801083b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b9:	8b 0d 5c 75 19 80    	mov    0x8019755c,%ecx
801083bf:	8b 15 60 75 19 80    	mov    0x80197560,%edx
801083c5:	01 ca                	add    %ecx,%edx
801083c7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801083ca:	29 ca                	sub    %ecx,%edx
801083cc:	83 ec 04             	sub    $0x4,%esp
801083cf:	50                   	push   %eax
801083d0:	6a 00                	push   $0x0
801083d2:	52                   	push   %edx
801083d3:	e8 ec c8 ff ff       	call   80104cc4 <memset>
801083d8:	83 c4 10             	add    $0x10,%esp
}
801083db:	90                   	nop
801083dc:	c9                   	leave  
801083dd:	c3                   	ret    

801083de <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801083de:	55                   	push   %ebp
801083df:	89 e5                	mov    %esp,%ebp
801083e1:	53                   	push   %ebx
801083e2:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801083e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083ec:	e9 b1 00 00 00       	jmp    801084a2 <font_render+0xc4>
    for(int j=14;j>-1;j--){
801083f1:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801083f8:	e9 97 00 00 00       	jmp    80108494 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801083fd:	8b 45 10             	mov    0x10(%ebp),%eax
80108400:	83 e8 20             	sub    $0x20,%eax
80108403:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108409:	01 d0                	add    %edx,%eax
8010840b:	0f b7 84 00 00 ac 10 	movzwl -0x7fef5400(%eax,%eax,1),%eax
80108412:	80 
80108413:	0f b7 d0             	movzwl %ax,%edx
80108416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108419:	bb 01 00 00 00       	mov    $0x1,%ebx
8010841e:	89 c1                	mov    %eax,%ecx
80108420:	d3 e3                	shl    %cl,%ebx
80108422:	89 d8                	mov    %ebx,%eax
80108424:	21 d0                	and    %edx,%eax
80108426:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842c:	ba 01 00 00 00       	mov    $0x1,%edx
80108431:	89 c1                	mov    %eax,%ecx
80108433:	d3 e2                	shl    %cl,%edx
80108435:	89 d0                	mov    %edx,%eax
80108437:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010843a:	75 2b                	jne    80108467 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
8010843c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010843f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108442:	01 c2                	add    %eax,%edx
80108444:	b8 0e 00 00 00       	mov    $0xe,%eax
80108449:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010844c:	89 c1                	mov    %eax,%ecx
8010844e:	8b 45 08             	mov    0x8(%ebp),%eax
80108451:	01 c8                	add    %ecx,%eax
80108453:	83 ec 04             	sub    $0x4,%esp
80108456:	68 00 f5 10 80       	push   $0x8010f500
8010845b:	52                   	push   %edx
8010845c:	50                   	push   %eax
8010845d:	e8 be fe ff ff       	call   80108320 <graphic_draw_pixel>
80108462:	83 c4 10             	add    $0x10,%esp
80108465:	eb 29                	jmp    80108490 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108467:	8b 55 0c             	mov    0xc(%ebp),%edx
8010846a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846d:	01 c2                	add    %eax,%edx
8010846f:	b8 0e 00 00 00       	mov    $0xe,%eax
80108474:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108477:	89 c1                	mov    %eax,%ecx
80108479:	8b 45 08             	mov    0x8(%ebp),%eax
8010847c:	01 c8                	add    %ecx,%eax
8010847e:	83 ec 04             	sub    $0x4,%esp
80108481:	68 70 75 19 80       	push   $0x80197570
80108486:	52                   	push   %edx
80108487:	50                   	push   %eax
80108488:	e8 93 fe ff ff       	call   80108320 <graphic_draw_pixel>
8010848d:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108490:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108494:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108498:	0f 89 5f ff ff ff    	jns    801083fd <font_render+0x1f>
  for(int i=0;i<30;i++){
8010849e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084a2:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801084a6:	0f 8e 45 ff ff ff    	jle    801083f1 <font_render+0x13>
      }
    }
  }
}
801084ac:	90                   	nop
801084ad:	90                   	nop
801084ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084b1:	c9                   	leave  
801084b2:	c3                   	ret    

801084b3 <font_render_string>:

void font_render_string(char *string,int row){
801084b3:	55                   	push   %ebp
801084b4:	89 e5                	mov    %esp,%ebp
801084b6:	53                   	push   %ebx
801084b7:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801084ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801084c1:	eb 33                	jmp    801084f6 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801084c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084c6:	8b 45 08             	mov    0x8(%ebp),%eax
801084c9:	01 d0                	add    %edx,%eax
801084cb:	0f b6 00             	movzbl (%eax),%eax
801084ce:	0f be c8             	movsbl %al,%ecx
801084d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d4:	6b d0 1e             	imul   $0x1e,%eax,%edx
801084d7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801084da:	89 d8                	mov    %ebx,%eax
801084dc:	c1 e0 04             	shl    $0x4,%eax
801084df:	29 d8                	sub    %ebx,%eax
801084e1:	83 c0 02             	add    $0x2,%eax
801084e4:	83 ec 04             	sub    $0x4,%esp
801084e7:	51                   	push   %ecx
801084e8:	52                   	push   %edx
801084e9:	50                   	push   %eax
801084ea:	e8 ef fe ff ff       	call   801083de <font_render>
801084ef:	83 c4 10             	add    $0x10,%esp
    i++;
801084f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801084f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084f9:	8b 45 08             	mov    0x8(%ebp),%eax
801084fc:	01 d0                	add    %edx,%eax
801084fe:	0f b6 00             	movzbl (%eax),%eax
80108501:	84 c0                	test   %al,%al
80108503:	74 06                	je     8010850b <font_render_string+0x58>
80108505:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108509:	7e b8                	jle    801084c3 <font_render_string+0x10>
  }
}
8010850b:	90                   	nop
8010850c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010850f:	c9                   	leave  
80108510:	c3                   	ret    

80108511 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108511:	55                   	push   %ebp
80108512:	89 e5                	mov    %esp,%ebp
80108514:	53                   	push   %ebx
80108515:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108518:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010851f:	eb 6b                	jmp    8010858c <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108521:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108528:	eb 58                	jmp    80108582 <pci_init+0x71>
      for(int k=0;k<8;k++){
8010852a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108531:	eb 45                	jmp    80108578 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108533:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108536:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853c:	83 ec 0c             	sub    $0xc,%esp
8010853f:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108542:	53                   	push   %ebx
80108543:	6a 00                	push   $0x0
80108545:	51                   	push   %ecx
80108546:	52                   	push   %edx
80108547:	50                   	push   %eax
80108548:	e8 b0 00 00 00       	call   801085fd <pci_access_config>
8010854d:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108550:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108553:	0f b7 c0             	movzwl %ax,%eax
80108556:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010855b:	74 17                	je     80108574 <pci_init+0x63>
        pci_init_device(i,j,k);
8010855d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108560:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108566:	83 ec 04             	sub    $0x4,%esp
80108569:	51                   	push   %ecx
8010856a:	52                   	push   %edx
8010856b:	50                   	push   %eax
8010856c:	e8 37 01 00 00       	call   801086a8 <pci_init_device>
80108571:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108574:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108578:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010857c:	7e b5                	jle    80108533 <pci_init+0x22>
    for(int j=0;j<32;j++){
8010857e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108582:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108586:	7e a2                	jle    8010852a <pci_init+0x19>
  for(int i=0;i<256;i++){
80108588:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010858c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108593:	7e 8c                	jle    80108521 <pci_init+0x10>
      }
      }
    }
  }
}
80108595:	90                   	nop
80108596:	90                   	nop
80108597:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010859a:	c9                   	leave  
8010859b:	c3                   	ret    

8010859c <pci_write_config>:

void pci_write_config(uint config){
8010859c:	55                   	push   %ebp
8010859d:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010859f:	8b 45 08             	mov    0x8(%ebp),%eax
801085a2:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801085a7:	89 c0                	mov    %eax,%eax
801085a9:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801085aa:	90                   	nop
801085ab:	5d                   	pop    %ebp
801085ac:	c3                   	ret    

801085ad <pci_write_data>:

void pci_write_data(uint config){
801085ad:	55                   	push   %ebp
801085ae:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801085b0:	8b 45 08             	mov    0x8(%ebp),%eax
801085b3:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801085b8:	89 c0                	mov    %eax,%eax
801085ba:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801085bb:	90                   	nop
801085bc:	5d                   	pop    %ebp
801085bd:	c3                   	ret    

801085be <pci_read_config>:
uint pci_read_config(){
801085be:	55                   	push   %ebp
801085bf:	89 e5                	mov    %esp,%ebp
801085c1:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801085c4:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801085c9:	ed                   	in     (%dx),%eax
801085ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801085cd:	83 ec 0c             	sub    $0xc,%esp
801085d0:	68 c8 00 00 00       	push   $0xc8
801085d5:	e8 5d a5 ff ff       	call   80102b37 <microdelay>
801085da:	83 c4 10             	add    $0x10,%esp
  return data;
801085dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801085e0:	c9                   	leave  
801085e1:	c3                   	ret    

801085e2 <pci_test>:


void pci_test(){
801085e2:	55                   	push   %ebp
801085e3:	89 e5                	mov    %esp,%ebp
801085e5:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801085e8:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801085ef:	ff 75 fc             	push   -0x4(%ebp)
801085f2:	e8 a5 ff ff ff       	call   8010859c <pci_write_config>
801085f7:	83 c4 04             	add    $0x4,%esp
}
801085fa:	90                   	nop
801085fb:	c9                   	leave  
801085fc:	c3                   	ret    

801085fd <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801085fd:	55                   	push   %ebp
801085fe:	89 e5                	mov    %esp,%ebp
80108600:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108603:	8b 45 08             	mov    0x8(%ebp),%eax
80108606:	c1 e0 10             	shl    $0x10,%eax
80108609:	25 00 00 ff 00       	and    $0xff0000,%eax
8010860e:	89 c2                	mov    %eax,%edx
80108610:	8b 45 0c             	mov    0xc(%ebp),%eax
80108613:	c1 e0 0b             	shl    $0xb,%eax
80108616:	0f b7 c0             	movzwl %ax,%eax
80108619:	09 c2                	or     %eax,%edx
8010861b:	8b 45 10             	mov    0x10(%ebp),%eax
8010861e:	c1 e0 08             	shl    $0x8,%eax
80108621:	25 00 07 00 00       	and    $0x700,%eax
80108626:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108628:	8b 45 14             	mov    0x14(%ebp),%eax
8010862b:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108630:	09 d0                	or     %edx,%eax
80108632:	0d 00 00 00 80       	or     $0x80000000,%eax
80108637:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010863a:	ff 75 f4             	push   -0xc(%ebp)
8010863d:	e8 5a ff ff ff       	call   8010859c <pci_write_config>
80108642:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108645:	e8 74 ff ff ff       	call   801085be <pci_read_config>
8010864a:	8b 55 18             	mov    0x18(%ebp),%edx
8010864d:	89 02                	mov    %eax,(%edx)
}
8010864f:	90                   	nop
80108650:	c9                   	leave  
80108651:	c3                   	ret    

80108652 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108652:	55                   	push   %ebp
80108653:	89 e5                	mov    %esp,%ebp
80108655:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108658:	8b 45 08             	mov    0x8(%ebp),%eax
8010865b:	c1 e0 10             	shl    $0x10,%eax
8010865e:	25 00 00 ff 00       	and    $0xff0000,%eax
80108663:	89 c2                	mov    %eax,%edx
80108665:	8b 45 0c             	mov    0xc(%ebp),%eax
80108668:	c1 e0 0b             	shl    $0xb,%eax
8010866b:	0f b7 c0             	movzwl %ax,%eax
8010866e:	09 c2                	or     %eax,%edx
80108670:	8b 45 10             	mov    0x10(%ebp),%eax
80108673:	c1 e0 08             	shl    $0x8,%eax
80108676:	25 00 07 00 00       	and    $0x700,%eax
8010867b:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010867d:	8b 45 14             	mov    0x14(%ebp),%eax
80108680:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108685:	09 d0                	or     %edx,%eax
80108687:	0d 00 00 00 80       	or     $0x80000000,%eax
8010868c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010868f:	ff 75 fc             	push   -0x4(%ebp)
80108692:	e8 05 ff ff ff       	call   8010859c <pci_write_config>
80108697:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010869a:	ff 75 18             	push   0x18(%ebp)
8010869d:	e8 0b ff ff ff       	call   801085ad <pci_write_data>
801086a2:	83 c4 04             	add    $0x4,%esp
}
801086a5:	90                   	nop
801086a6:	c9                   	leave  
801086a7:	c3                   	ret    

801086a8 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801086a8:	55                   	push   %ebp
801086a9:	89 e5                	mov    %esp,%ebp
801086ab:	53                   	push   %ebx
801086ac:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801086af:	8b 45 08             	mov    0x8(%ebp),%eax
801086b2:	a2 74 75 19 80       	mov    %al,0x80197574
  dev.device_num = device_num;
801086b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801086ba:	a2 75 75 19 80       	mov    %al,0x80197575
  dev.function_num = function_num;
801086bf:	8b 45 10             	mov    0x10(%ebp),%eax
801086c2:	a2 76 75 19 80       	mov    %al,0x80197576
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801086c7:	ff 75 10             	push   0x10(%ebp)
801086ca:	ff 75 0c             	push   0xc(%ebp)
801086cd:	ff 75 08             	push   0x8(%ebp)
801086d0:	68 44 c2 10 80       	push   $0x8010c244
801086d5:	e8 1a 7d ff ff       	call   801003f4 <cprintf>
801086da:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801086dd:	83 ec 0c             	sub    $0xc,%esp
801086e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086e3:	50                   	push   %eax
801086e4:	6a 00                	push   $0x0
801086e6:	ff 75 10             	push   0x10(%ebp)
801086e9:	ff 75 0c             	push   0xc(%ebp)
801086ec:	ff 75 08             	push   0x8(%ebp)
801086ef:	e8 09 ff ff ff       	call   801085fd <pci_access_config>
801086f4:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801086f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086fa:	c1 e8 10             	shr    $0x10,%eax
801086fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108700:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108703:	25 ff ff 00 00       	and    $0xffff,%eax
80108708:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
8010870b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870e:	a3 78 75 19 80       	mov    %eax,0x80197578
  dev.vendor_id = vendor_id;
80108713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108716:	a3 7c 75 19 80       	mov    %eax,0x8019757c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
8010871b:	83 ec 04             	sub    $0x4,%esp
8010871e:	ff 75 f0             	push   -0x10(%ebp)
80108721:	ff 75 f4             	push   -0xc(%ebp)
80108724:	68 78 c2 10 80       	push   $0x8010c278
80108729:	e8 c6 7c ff ff       	call   801003f4 <cprintf>
8010872e:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108731:	83 ec 0c             	sub    $0xc,%esp
80108734:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108737:	50                   	push   %eax
80108738:	6a 08                	push   $0x8
8010873a:	ff 75 10             	push   0x10(%ebp)
8010873d:	ff 75 0c             	push   0xc(%ebp)
80108740:	ff 75 08             	push   0x8(%ebp)
80108743:	e8 b5 fe ff ff       	call   801085fd <pci_access_config>
80108748:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010874b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010874e:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108751:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108754:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108757:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010875a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010875d:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108760:	0f b6 c0             	movzbl %al,%eax
80108763:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108766:	c1 eb 18             	shr    $0x18,%ebx
80108769:	83 ec 0c             	sub    $0xc,%esp
8010876c:	51                   	push   %ecx
8010876d:	52                   	push   %edx
8010876e:	50                   	push   %eax
8010876f:	53                   	push   %ebx
80108770:	68 9c c2 10 80       	push   $0x8010c29c
80108775:	e8 7a 7c ff ff       	call   801003f4 <cprintf>
8010877a:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010877d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108780:	c1 e8 18             	shr    $0x18,%eax
80108783:	a2 80 75 19 80       	mov    %al,0x80197580
  dev.sub_class = (data>>16)&0xFF;
80108788:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010878b:	c1 e8 10             	shr    $0x10,%eax
8010878e:	a2 81 75 19 80       	mov    %al,0x80197581
  dev.interface = (data>>8)&0xFF;
80108793:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108796:	c1 e8 08             	shr    $0x8,%eax
80108799:	a2 82 75 19 80       	mov    %al,0x80197582
  dev.revision_id = data&0xFF;
8010879e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087a1:	a2 83 75 19 80       	mov    %al,0x80197583
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801087a6:	83 ec 0c             	sub    $0xc,%esp
801087a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087ac:	50                   	push   %eax
801087ad:	6a 10                	push   $0x10
801087af:	ff 75 10             	push   0x10(%ebp)
801087b2:	ff 75 0c             	push   0xc(%ebp)
801087b5:	ff 75 08             	push   0x8(%ebp)
801087b8:	e8 40 fe ff ff       	call   801085fd <pci_access_config>
801087bd:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801087c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c3:	a3 84 75 19 80       	mov    %eax,0x80197584
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801087c8:	83 ec 0c             	sub    $0xc,%esp
801087cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087ce:	50                   	push   %eax
801087cf:	6a 14                	push   $0x14
801087d1:	ff 75 10             	push   0x10(%ebp)
801087d4:	ff 75 0c             	push   0xc(%ebp)
801087d7:	ff 75 08             	push   0x8(%ebp)
801087da:	e8 1e fe ff ff       	call   801085fd <pci_access_config>
801087df:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801087e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e5:	a3 88 75 19 80       	mov    %eax,0x80197588
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801087ea:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801087f1:	75 5a                	jne    8010884d <pci_init_device+0x1a5>
801087f3:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801087fa:	75 51                	jne    8010884d <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801087fc:	83 ec 0c             	sub    $0xc,%esp
801087ff:	68 e1 c2 10 80       	push   $0x8010c2e1
80108804:	e8 eb 7b ff ff       	call   801003f4 <cprintf>
80108809:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010880c:	83 ec 0c             	sub    $0xc,%esp
8010880f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108812:	50                   	push   %eax
80108813:	68 f0 00 00 00       	push   $0xf0
80108818:	ff 75 10             	push   0x10(%ebp)
8010881b:	ff 75 0c             	push   0xc(%ebp)
8010881e:	ff 75 08             	push   0x8(%ebp)
80108821:	e8 d7 fd ff ff       	call   801085fd <pci_access_config>
80108826:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108829:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010882c:	83 ec 08             	sub    $0x8,%esp
8010882f:	50                   	push   %eax
80108830:	68 fb c2 10 80       	push   $0x8010c2fb
80108835:	e8 ba 7b ff ff       	call   801003f4 <cprintf>
8010883a:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010883d:	83 ec 0c             	sub    $0xc,%esp
80108840:	68 74 75 19 80       	push   $0x80197574
80108845:	e8 09 00 00 00       	call   80108853 <i8254_init>
8010884a:	83 c4 10             	add    $0x10,%esp
  }
}
8010884d:	90                   	nop
8010884e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108851:	c9                   	leave  
80108852:	c3                   	ret    

80108853 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108853:	55                   	push   %ebp
80108854:	89 e5                	mov    %esp,%ebp
80108856:	53                   	push   %ebx
80108857:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010885a:	8b 45 08             	mov    0x8(%ebp),%eax
8010885d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108861:	0f b6 c8             	movzbl %al,%ecx
80108864:	8b 45 08             	mov    0x8(%ebp),%eax
80108867:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010886b:	0f b6 d0             	movzbl %al,%edx
8010886e:	8b 45 08             	mov    0x8(%ebp),%eax
80108871:	0f b6 00             	movzbl (%eax),%eax
80108874:	0f b6 c0             	movzbl %al,%eax
80108877:	83 ec 0c             	sub    $0xc,%esp
8010887a:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010887d:	53                   	push   %ebx
8010887e:	6a 04                	push   $0x4
80108880:	51                   	push   %ecx
80108881:	52                   	push   %edx
80108882:	50                   	push   %eax
80108883:	e8 75 fd ff ff       	call   801085fd <pci_access_config>
80108888:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010888b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010888e:	83 c8 04             	or     $0x4,%eax
80108891:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108894:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108897:	8b 45 08             	mov    0x8(%ebp),%eax
8010889a:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010889e:	0f b6 c8             	movzbl %al,%ecx
801088a1:	8b 45 08             	mov    0x8(%ebp),%eax
801088a4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801088a8:	0f b6 d0             	movzbl %al,%edx
801088ab:	8b 45 08             	mov    0x8(%ebp),%eax
801088ae:	0f b6 00             	movzbl (%eax),%eax
801088b1:	0f b6 c0             	movzbl %al,%eax
801088b4:	83 ec 0c             	sub    $0xc,%esp
801088b7:	53                   	push   %ebx
801088b8:	6a 04                	push   $0x4
801088ba:	51                   	push   %ecx
801088bb:	52                   	push   %edx
801088bc:	50                   	push   %eax
801088bd:	e8 90 fd ff ff       	call   80108652 <pci_write_config_register>
801088c2:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801088c5:	8b 45 08             	mov    0x8(%ebp),%eax
801088c8:	8b 40 10             	mov    0x10(%eax),%eax
801088cb:	05 00 00 00 40       	add    $0x40000000,%eax
801088d0:	a3 8c 75 19 80       	mov    %eax,0x8019758c
  uint *ctrl = (uint *)base_addr;
801088d5:	a1 8c 75 19 80       	mov    0x8019758c,%eax
801088da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801088dd:	a1 8c 75 19 80       	mov    0x8019758c,%eax
801088e2:	05 d8 00 00 00       	add    $0xd8,%eax
801088e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801088ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ed:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f6:	8b 00                	mov    (%eax),%eax
801088f8:	0d 00 00 00 04       	or     $0x4000000,%eax
801088fd:	89 c2                	mov    %eax,%edx
801088ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108902:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108907:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010890d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108910:	8b 00                	mov    (%eax),%eax
80108912:	83 c8 40             	or     $0x40,%eax
80108915:	89 c2                	mov    %eax,%edx
80108917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891a:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010891c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891f:	8b 10                	mov    (%eax),%edx
80108921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108924:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108926:	83 ec 0c             	sub    $0xc,%esp
80108929:	68 10 c3 10 80       	push   $0x8010c310
8010892e:	e8 c1 7a ff ff       	call   801003f4 <cprintf>
80108933:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108936:	e8 65 9e ff ff       	call   801027a0 <kalloc>
8010893b:	a3 98 75 19 80       	mov    %eax,0x80197598
  *intr_addr = 0;
80108940:	a1 98 75 19 80       	mov    0x80197598,%eax
80108945:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
8010894b:	a1 98 75 19 80       	mov    0x80197598,%eax
80108950:	83 ec 08             	sub    $0x8,%esp
80108953:	50                   	push   %eax
80108954:	68 32 c3 10 80       	push   $0x8010c332
80108959:	e8 96 7a ff ff       	call   801003f4 <cprintf>
8010895e:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108961:	e8 50 00 00 00       	call   801089b6 <i8254_init_recv>
  i8254_init_send();
80108966:	e8 69 03 00 00       	call   80108cd4 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010896b:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108972:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108975:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010897c:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010897f:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108986:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108989:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108990:	0f b6 c0             	movzbl %al,%eax
80108993:	83 ec 0c             	sub    $0xc,%esp
80108996:	53                   	push   %ebx
80108997:	51                   	push   %ecx
80108998:	52                   	push   %edx
80108999:	50                   	push   %eax
8010899a:	68 40 c3 10 80       	push   $0x8010c340
8010899f:	e8 50 7a ff ff       	call   801003f4 <cprintf>
801089a4:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801089a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801089b0:	90                   	nop
801089b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089b4:	c9                   	leave  
801089b5:	c3                   	ret    

801089b6 <i8254_init_recv>:

void i8254_init_recv(){
801089b6:	55                   	push   %ebp
801089b7:	89 e5                	mov    %esp,%ebp
801089b9:	57                   	push   %edi
801089ba:	56                   	push   %esi
801089bb:	53                   	push   %ebx
801089bc:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801089bf:	83 ec 0c             	sub    $0xc,%esp
801089c2:	6a 00                	push   $0x0
801089c4:	e8 e8 04 00 00       	call   80108eb1 <i8254_read_eeprom>
801089c9:	83 c4 10             	add    $0x10,%esp
801089cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801089cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089d2:	a2 90 75 19 80       	mov    %al,0x80197590
  mac_addr[1] = data_l>>8;
801089d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089da:	c1 e8 08             	shr    $0x8,%eax
801089dd:	a2 91 75 19 80       	mov    %al,0x80197591
  uint data_m = i8254_read_eeprom(0x1);
801089e2:	83 ec 0c             	sub    $0xc,%esp
801089e5:	6a 01                	push   $0x1
801089e7:	e8 c5 04 00 00       	call   80108eb1 <i8254_read_eeprom>
801089ec:	83 c4 10             	add    $0x10,%esp
801089ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801089f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089f5:	a2 92 75 19 80       	mov    %al,0x80197592
  mac_addr[3] = data_m>>8;
801089fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089fd:	c1 e8 08             	shr    $0x8,%eax
80108a00:	a2 93 75 19 80       	mov    %al,0x80197593
  uint data_h = i8254_read_eeprom(0x2);
80108a05:	83 ec 0c             	sub    $0xc,%esp
80108a08:	6a 02                	push   $0x2
80108a0a:	e8 a2 04 00 00       	call   80108eb1 <i8254_read_eeprom>
80108a0f:	83 c4 10             	add    $0x10,%esp
80108a12:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108a15:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a18:	a2 94 75 19 80       	mov    %al,0x80197594
  mac_addr[5] = data_h>>8;
80108a1d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a20:	c1 e8 08             	shr    $0x8,%eax
80108a23:	a2 95 75 19 80       	mov    %al,0x80197595
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108a28:	0f b6 05 95 75 19 80 	movzbl 0x80197595,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a2f:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108a32:	0f b6 05 94 75 19 80 	movzbl 0x80197594,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a39:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108a3c:	0f b6 05 93 75 19 80 	movzbl 0x80197593,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a43:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108a46:	0f b6 05 92 75 19 80 	movzbl 0x80197592,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a4d:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108a50:	0f b6 05 91 75 19 80 	movzbl 0x80197591,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a57:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108a5a:	0f b6 05 90 75 19 80 	movzbl 0x80197590,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a61:	0f b6 c0             	movzbl %al,%eax
80108a64:	83 ec 04             	sub    $0x4,%esp
80108a67:	57                   	push   %edi
80108a68:	56                   	push   %esi
80108a69:	53                   	push   %ebx
80108a6a:	51                   	push   %ecx
80108a6b:	52                   	push   %edx
80108a6c:	50                   	push   %eax
80108a6d:	68 58 c3 10 80       	push   $0x8010c358
80108a72:	e8 7d 79 ff ff       	call   801003f4 <cprintf>
80108a77:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108a7a:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108a7f:	05 00 54 00 00       	add    $0x5400,%eax
80108a84:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108a87:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108a8c:	05 04 54 00 00       	add    $0x5404,%eax
80108a91:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108a94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a97:	c1 e0 10             	shl    $0x10,%eax
80108a9a:	0b 45 d8             	or     -0x28(%ebp),%eax
80108a9d:	89 c2                	mov    %eax,%edx
80108a9f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108aa2:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108aa4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108aa7:	0d 00 00 00 80       	or     $0x80000000,%eax
80108aac:	89 c2                	mov    %eax,%edx
80108aae:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108ab1:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108ab3:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108ab8:	05 00 52 00 00       	add    $0x5200,%eax
80108abd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108ac0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108ac7:	eb 19                	jmp    80108ae2 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108ac9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108acc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ad3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ad6:	01 d0                	add    %edx,%eax
80108ad8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108ade:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108ae2:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108ae6:	7e e1                	jle    80108ac9 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108ae8:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108aed:	05 d0 00 00 00       	add    $0xd0,%eax
80108af2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108af5:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108af8:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108afe:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b03:	05 c8 00 00 00       	add    $0xc8,%eax
80108b08:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b0b:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108b0e:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108b14:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b19:	05 28 28 00 00       	add    $0x2828,%eax
80108b1e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108b21:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108b24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108b2a:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b2f:	05 00 01 00 00       	add    $0x100,%eax
80108b34:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108b37:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b3a:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108b40:	e8 5b 9c ff ff       	call   801027a0 <kalloc>
80108b45:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b48:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b4d:	05 00 28 00 00       	add    $0x2800,%eax
80108b52:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108b55:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b5a:	05 04 28 00 00       	add    $0x2804,%eax
80108b5f:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108b62:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b67:	05 08 28 00 00       	add    $0x2808,%eax
80108b6c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b6f:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b74:	05 10 28 00 00       	add    $0x2810,%eax
80108b79:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b7c:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108b81:	05 18 28 00 00       	add    $0x2818,%eax
80108b86:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108b89:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b8c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b92:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108b95:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108b97:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108b9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108ba0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108ba3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108ba9:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108bac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108bb2:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108bb5:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108bbb:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108bbe:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108bc1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108bc8:	eb 73                	jmp    80108c3d <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108bca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bcd:	c1 e0 04             	shl    $0x4,%eax
80108bd0:	89 c2                	mov    %eax,%edx
80108bd2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bd5:	01 d0                	add    %edx,%eax
80108bd7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108bde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108be1:	c1 e0 04             	shl    $0x4,%eax
80108be4:	89 c2                	mov    %eax,%edx
80108be6:	8b 45 98             	mov    -0x68(%ebp),%eax
80108be9:	01 d0                	add    %edx,%eax
80108beb:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108bf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bf4:	c1 e0 04             	shl    $0x4,%eax
80108bf7:	89 c2                	mov    %eax,%edx
80108bf9:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bfc:	01 d0                	add    %edx,%eax
80108bfe:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108c04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c07:	c1 e0 04             	shl    $0x4,%eax
80108c0a:	89 c2                	mov    %eax,%edx
80108c0c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c0f:	01 d0                	add    %edx,%eax
80108c11:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108c15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c18:	c1 e0 04             	shl    $0x4,%eax
80108c1b:	89 c2                	mov    %eax,%edx
80108c1d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c20:	01 d0                	add    %edx,%eax
80108c22:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108c26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c29:	c1 e0 04             	shl    $0x4,%eax
80108c2c:	89 c2                	mov    %eax,%edx
80108c2e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c31:	01 d0                	add    %edx,%eax
80108c33:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c39:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108c3d:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108c44:	7e 84                	jle    80108bca <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c46:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108c4d:	eb 57                	jmp    80108ca6 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108c4f:	e8 4c 9b ff ff       	call   801027a0 <kalloc>
80108c54:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108c57:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108c5b:	75 12                	jne    80108c6f <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108c5d:	83 ec 0c             	sub    $0xc,%esp
80108c60:	68 78 c3 10 80       	push   $0x8010c378
80108c65:	e8 8a 77 ff ff       	call   801003f4 <cprintf>
80108c6a:	83 c4 10             	add    $0x10,%esp
      break;
80108c6d:	eb 3d                	jmp    80108cac <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108c6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c72:	c1 e0 04             	shl    $0x4,%eax
80108c75:	89 c2                	mov    %eax,%edx
80108c77:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c7a:	01 d0                	add    %edx,%eax
80108c7c:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c7f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c85:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108c87:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c8a:	83 c0 01             	add    $0x1,%eax
80108c8d:	c1 e0 04             	shl    $0x4,%eax
80108c90:	89 c2                	mov    %eax,%edx
80108c92:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c95:	01 d0                	add    %edx,%eax
80108c97:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c9a:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108ca0:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108ca2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108ca6:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108caa:	7e a3                	jle    80108c4f <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108cac:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108caf:	8b 00                	mov    (%eax),%eax
80108cb1:	83 c8 02             	or     $0x2,%eax
80108cb4:	89 c2                	mov    %eax,%edx
80108cb6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108cb9:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108cbb:	83 ec 0c             	sub    $0xc,%esp
80108cbe:	68 98 c3 10 80       	push   $0x8010c398
80108cc3:	e8 2c 77 ff ff       	call   801003f4 <cprintf>
80108cc8:	83 c4 10             	add    $0x10,%esp
}
80108ccb:	90                   	nop
80108ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108ccf:	5b                   	pop    %ebx
80108cd0:	5e                   	pop    %esi
80108cd1:	5f                   	pop    %edi
80108cd2:	5d                   	pop    %ebp
80108cd3:	c3                   	ret    

80108cd4 <i8254_init_send>:

void i8254_init_send(){
80108cd4:	55                   	push   %ebp
80108cd5:	89 e5                	mov    %esp,%ebp
80108cd7:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108cda:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108cdf:	05 28 38 00 00       	add    $0x3828,%eax
80108ce4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108ce7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cea:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108cf0:	e8 ab 9a ff ff       	call   801027a0 <kalloc>
80108cf5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108cf8:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108cfd:	05 00 38 00 00       	add    $0x3800,%eax
80108d02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108d05:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d0a:	05 04 38 00 00       	add    $0x3804,%eax
80108d0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108d12:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d17:	05 08 38 00 00       	add    $0x3808,%eax
80108d1c:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108d1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d22:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d2b:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108d2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108d36:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d39:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d3f:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d44:	05 10 38 00 00       	add    $0x3810,%eax
80108d49:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d4c:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108d51:	05 18 38 00 00       	add    $0x3818,%eax
80108d56:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108d59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108d62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108d6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d6e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108d71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d78:	e9 82 00 00 00       	jmp    80108dff <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d80:	c1 e0 04             	shl    $0x4,%eax
80108d83:	89 c2                	mov    %eax,%edx
80108d85:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d88:	01 d0                	add    %edx,%eax
80108d8a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d94:	c1 e0 04             	shl    $0x4,%eax
80108d97:	89 c2                	mov    %eax,%edx
80108d99:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d9c:	01 d0                	add    %edx,%eax
80108d9e:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da7:	c1 e0 04             	shl    $0x4,%eax
80108daa:	89 c2                	mov    %eax,%edx
80108dac:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108daf:	01 d0                	add    %edx,%eax
80108db1:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db8:	c1 e0 04             	shl    $0x4,%eax
80108dbb:	89 c2                	mov    %eax,%edx
80108dbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dc0:	01 d0                	add    %edx,%eax
80108dc2:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc9:	c1 e0 04             	shl    $0x4,%eax
80108dcc:	89 c2                	mov    %eax,%edx
80108dce:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dd1:	01 d0                	add    %edx,%eax
80108dd3:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dda:	c1 e0 04             	shl    $0x4,%eax
80108ddd:	89 c2                	mov    %eax,%edx
80108ddf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108de2:	01 d0                	add    %edx,%eax
80108de4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108deb:	c1 e0 04             	shl    $0x4,%eax
80108dee:	89 c2                	mov    %eax,%edx
80108df0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108df3:	01 d0                	add    %edx,%eax
80108df5:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108dfb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108dff:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e06:	0f 8e 71 ff ff ff    	jle    80108d7d <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e0c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e13:	eb 57                	jmp    80108e6c <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108e15:	e8 86 99 ff ff       	call   801027a0 <kalloc>
80108e1a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108e1d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108e21:	75 12                	jne    80108e35 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108e23:	83 ec 0c             	sub    $0xc,%esp
80108e26:	68 78 c3 10 80       	push   $0x8010c378
80108e2b:	e8 c4 75 ff ff       	call   801003f4 <cprintf>
80108e30:	83 c4 10             	add    $0x10,%esp
      break;
80108e33:	eb 3d                	jmp    80108e72 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e38:	c1 e0 04             	shl    $0x4,%eax
80108e3b:	89 c2                	mov    %eax,%edx
80108e3d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e40:	01 d0                	add    %edx,%eax
80108e42:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e45:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e4b:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e50:	83 c0 01             	add    $0x1,%eax
80108e53:	c1 e0 04             	shl    $0x4,%eax
80108e56:	89 c2                	mov    %eax,%edx
80108e58:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e5b:	01 d0                	add    %edx,%eax
80108e5d:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e60:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e66:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e68:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e6c:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108e70:	7e a3                	jle    80108e15 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108e72:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108e77:	05 00 04 00 00       	add    $0x400,%eax
80108e7c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108e7f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108e82:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108e88:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108e8d:	05 10 04 00 00       	add    $0x410,%eax
80108e92:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108e95:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108e98:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108e9e:	83 ec 0c             	sub    $0xc,%esp
80108ea1:	68 b8 c3 10 80       	push   $0x8010c3b8
80108ea6:	e8 49 75 ff ff       	call   801003f4 <cprintf>
80108eab:	83 c4 10             	add    $0x10,%esp

}
80108eae:	90                   	nop
80108eaf:	c9                   	leave  
80108eb0:	c3                   	ret    

80108eb1 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108eb1:	55                   	push   %ebp
80108eb2:	89 e5                	mov    %esp,%ebp
80108eb4:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108eb7:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108ebc:	83 c0 14             	add    $0x14,%eax
80108ebf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ec5:	c1 e0 08             	shl    $0x8,%eax
80108ec8:	0f b7 c0             	movzwl %ax,%eax
80108ecb:	83 c8 01             	or     $0x1,%eax
80108ece:	89 c2                	mov    %eax,%edx
80108ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed3:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108ed5:	83 ec 0c             	sub    $0xc,%esp
80108ed8:	68 d8 c3 10 80       	push   $0x8010c3d8
80108edd:	e8 12 75 ff ff       	call   801003f4 <cprintf>
80108ee2:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee8:	8b 00                	mov    (%eax),%eax
80108eea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ef0:	83 e0 10             	and    $0x10,%eax
80108ef3:	85 c0                	test   %eax,%eax
80108ef5:	75 02                	jne    80108ef9 <i8254_read_eeprom+0x48>
  while(1){
80108ef7:	eb dc                	jmp    80108ed5 <i8254_read_eeprom+0x24>
      break;
80108ef9:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108efd:	8b 00                	mov    (%eax),%eax
80108eff:	c1 e8 10             	shr    $0x10,%eax
}
80108f02:	c9                   	leave  
80108f03:	c3                   	ret    

80108f04 <i8254_recv>:
void i8254_recv(){
80108f04:	55                   	push   %ebp
80108f05:	89 e5                	mov    %esp,%ebp
80108f07:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f0a:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f0f:	05 10 28 00 00       	add    $0x2810,%eax
80108f14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f17:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f1c:	05 18 28 00 00       	add    $0x2818,%eax
80108f21:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f24:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108f29:	05 00 28 00 00       	add    $0x2800,%eax
80108f2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f34:	8b 00                	mov    (%eax),%eax
80108f36:	05 00 00 00 80       	add    $0x80000000,%eax
80108f3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f41:	8b 10                	mov    (%eax),%edx
80108f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f46:	8b 08                	mov    (%eax),%ecx
80108f48:	89 d0                	mov    %edx,%eax
80108f4a:	29 c8                	sub    %ecx,%eax
80108f4c:	25 ff 00 00 00       	and    $0xff,%eax
80108f51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108f54:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f58:	7e 37                	jle    80108f91 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5d:	8b 00                	mov    (%eax),%eax
80108f5f:	c1 e0 04             	shl    $0x4,%eax
80108f62:	89 c2                	mov    %eax,%edx
80108f64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f67:	01 d0                	add    %edx,%eax
80108f69:	8b 00                	mov    (%eax),%eax
80108f6b:	05 00 00 00 80       	add    $0x80000000,%eax
80108f70:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f76:	8b 00                	mov    (%eax),%eax
80108f78:	83 c0 01             	add    $0x1,%eax
80108f7b:	0f b6 d0             	movzbl %al,%edx
80108f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f81:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108f83:	83 ec 0c             	sub    $0xc,%esp
80108f86:	ff 75 e0             	push   -0x20(%ebp)
80108f89:	e8 15 09 00 00       	call   801098a3 <eth_proc>
80108f8e:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f94:	8b 10                	mov    (%eax),%edx
80108f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f99:	8b 00                	mov    (%eax),%eax
80108f9b:	39 c2                	cmp    %eax,%edx
80108f9d:	75 9f                	jne    80108f3e <i8254_recv+0x3a>
      (*rdt)--;
80108f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa2:	8b 00                	mov    (%eax),%eax
80108fa4:	8d 50 ff             	lea    -0x1(%eax),%edx
80108fa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108faa:	89 10                	mov    %edx,(%eax)
  while(1){
80108fac:	eb 90                	jmp    80108f3e <i8254_recv+0x3a>

80108fae <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108fae:	55                   	push   %ebp
80108faf:	89 e5                	mov    %esp,%ebp
80108fb1:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108fb4:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108fb9:	05 10 38 00 00       	add    $0x3810,%eax
80108fbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108fc1:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108fc6:	05 18 38 00 00       	add    $0x3818,%eax
80108fcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108fce:	a1 8c 75 19 80       	mov    0x8019758c,%eax
80108fd3:	05 00 38 00 00       	add    $0x3800,%eax
80108fd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108fdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fde:	8b 00                	mov    (%eax),%eax
80108fe0:	05 00 00 00 80       	add    $0x80000000,%eax
80108fe5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108fe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108feb:	8b 10                	mov    (%eax),%edx
80108fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff0:	8b 08                	mov    (%eax),%ecx
80108ff2:	89 d0                	mov    %edx,%eax
80108ff4:	29 c8                	sub    %ecx,%eax
80108ff6:	0f b6 d0             	movzbl %al,%edx
80108ff9:	b8 00 01 00 00       	mov    $0x100,%eax
80108ffe:	29 d0                	sub    %edx,%eax
80109000:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109003:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109006:	8b 00                	mov    (%eax),%eax
80109008:	25 ff 00 00 00       	and    $0xff,%eax
8010900d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109010:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109014:	0f 8e a8 00 00 00    	jle    801090c2 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010901a:	8b 45 08             	mov    0x8(%ebp),%eax
8010901d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109020:	89 d1                	mov    %edx,%ecx
80109022:	c1 e1 04             	shl    $0x4,%ecx
80109025:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109028:	01 ca                	add    %ecx,%edx
8010902a:	8b 12                	mov    (%edx),%edx
8010902c:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109032:	83 ec 04             	sub    $0x4,%esp
80109035:	ff 75 0c             	push   0xc(%ebp)
80109038:	50                   	push   %eax
80109039:	52                   	push   %edx
8010903a:	e8 44 bd ff ff       	call   80104d83 <memmove>
8010903f:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109042:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109045:	c1 e0 04             	shl    $0x4,%eax
80109048:	89 c2                	mov    %eax,%edx
8010904a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010904d:	01 d0                	add    %edx,%eax
8010904f:	8b 55 0c             	mov    0xc(%ebp),%edx
80109052:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109056:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109059:	c1 e0 04             	shl    $0x4,%eax
8010905c:	89 c2                	mov    %eax,%edx
8010905e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109061:	01 d0                	add    %edx,%eax
80109063:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109067:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010906a:	c1 e0 04             	shl    $0x4,%eax
8010906d:	89 c2                	mov    %eax,%edx
8010906f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109072:	01 d0                	add    %edx,%eax
80109074:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109078:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010907b:	c1 e0 04             	shl    $0x4,%eax
8010907e:	89 c2                	mov    %eax,%edx
80109080:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109083:	01 d0                	add    %edx,%eax
80109085:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109089:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010908c:	c1 e0 04             	shl    $0x4,%eax
8010908f:	89 c2                	mov    %eax,%edx
80109091:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109094:	01 d0                	add    %edx,%eax
80109096:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
8010909c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010909f:	c1 e0 04             	shl    $0x4,%eax
801090a2:	89 c2                	mov    %eax,%edx
801090a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090a7:	01 d0                	add    %edx,%eax
801090a9:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801090ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090b0:	8b 00                	mov    (%eax),%eax
801090b2:	83 c0 01             	add    $0x1,%eax
801090b5:	0f b6 d0             	movzbl %al,%edx
801090b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090bb:	89 10                	mov    %edx,(%eax)
    return len;
801090bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801090c0:	eb 05                	jmp    801090c7 <i8254_send+0x119>
  }else{
    return -1;
801090c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801090c7:	c9                   	leave  
801090c8:	c3                   	ret    

801090c9 <i8254_intr>:

void i8254_intr(){
801090c9:	55                   	push   %ebp
801090ca:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801090cc:	a1 98 75 19 80       	mov    0x80197598,%eax
801090d1:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801090d7:	90                   	nop
801090d8:	5d                   	pop    %ebp
801090d9:	c3                   	ret    

801090da <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801090da:	55                   	push   %ebp
801090db:	89 e5                	mov    %esp,%ebp
801090dd:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801090e0:	8b 45 08             	mov    0x8(%ebp),%eax
801090e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801090e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e9:	0f b7 00             	movzwl (%eax),%eax
801090ec:	66 3d 00 01          	cmp    $0x100,%ax
801090f0:	74 0a                	je     801090fc <arp_proc+0x22>
801090f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090f7:	e9 4f 01 00 00       	jmp    8010924b <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801090fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ff:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109103:	66 83 f8 08          	cmp    $0x8,%ax
80109107:	74 0a                	je     80109113 <arp_proc+0x39>
80109109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010910e:	e9 38 01 00 00       	jmp    8010924b <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109116:	0f b6 40 04          	movzbl 0x4(%eax),%eax
8010911a:	3c 06                	cmp    $0x6,%al
8010911c:	74 0a                	je     80109128 <arp_proc+0x4e>
8010911e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109123:	e9 23 01 00 00       	jmp    8010924b <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010912b:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010912f:	3c 04                	cmp    $0x4,%al
80109131:	74 0a                	je     8010913d <arp_proc+0x63>
80109133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109138:	e9 0e 01 00 00       	jmp    8010924b <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010913d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109140:	83 c0 18             	add    $0x18,%eax
80109143:	83 ec 04             	sub    $0x4,%esp
80109146:	6a 04                	push   $0x4
80109148:	50                   	push   %eax
80109149:	68 04 f5 10 80       	push   $0x8010f504
8010914e:	e8 d8 bb ff ff       	call   80104d2b <memcmp>
80109153:	83 c4 10             	add    $0x10,%esp
80109156:	85 c0                	test   %eax,%eax
80109158:	74 27                	je     80109181 <arp_proc+0xa7>
8010915a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915d:	83 c0 0e             	add    $0xe,%eax
80109160:	83 ec 04             	sub    $0x4,%esp
80109163:	6a 04                	push   $0x4
80109165:	50                   	push   %eax
80109166:	68 04 f5 10 80       	push   $0x8010f504
8010916b:	e8 bb bb ff ff       	call   80104d2b <memcmp>
80109170:	83 c4 10             	add    $0x10,%esp
80109173:	85 c0                	test   %eax,%eax
80109175:	74 0a                	je     80109181 <arp_proc+0xa7>
80109177:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010917c:	e9 ca 00 00 00       	jmp    8010924b <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109184:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109188:	66 3d 00 01          	cmp    $0x100,%ax
8010918c:	75 69                	jne    801091f7 <arp_proc+0x11d>
8010918e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109191:	83 c0 18             	add    $0x18,%eax
80109194:	83 ec 04             	sub    $0x4,%esp
80109197:	6a 04                	push   $0x4
80109199:	50                   	push   %eax
8010919a:	68 04 f5 10 80       	push   $0x8010f504
8010919f:	e8 87 bb ff ff       	call   80104d2b <memcmp>
801091a4:	83 c4 10             	add    $0x10,%esp
801091a7:	85 c0                	test   %eax,%eax
801091a9:	75 4c                	jne    801091f7 <arp_proc+0x11d>
    uint send = (uint)kalloc();
801091ab:	e8 f0 95 ff ff       	call   801027a0 <kalloc>
801091b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801091b3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801091ba:	83 ec 04             	sub    $0x4,%esp
801091bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801091c0:	50                   	push   %eax
801091c1:	ff 75 f0             	push   -0x10(%ebp)
801091c4:	ff 75 f4             	push   -0xc(%ebp)
801091c7:	e8 1f 04 00 00       	call   801095eb <arp_reply_pkt_create>
801091cc:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801091cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091d2:	83 ec 08             	sub    $0x8,%esp
801091d5:	50                   	push   %eax
801091d6:	ff 75 f0             	push   -0x10(%ebp)
801091d9:	e8 d0 fd ff ff       	call   80108fae <i8254_send>
801091de:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801091e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e4:	83 ec 0c             	sub    $0xc,%esp
801091e7:	50                   	push   %eax
801091e8:	e8 19 95 ff ff       	call   80102706 <kfree>
801091ed:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801091f0:	b8 02 00 00 00       	mov    $0x2,%eax
801091f5:	eb 54                	jmp    8010924b <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801091f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091fa:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801091fe:	66 3d 00 02          	cmp    $0x200,%ax
80109202:	75 42                	jne    80109246 <arp_proc+0x16c>
80109204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109207:	83 c0 18             	add    $0x18,%eax
8010920a:	83 ec 04             	sub    $0x4,%esp
8010920d:	6a 04                	push   $0x4
8010920f:	50                   	push   %eax
80109210:	68 04 f5 10 80       	push   $0x8010f504
80109215:	e8 11 bb ff ff       	call   80104d2b <memcmp>
8010921a:	83 c4 10             	add    $0x10,%esp
8010921d:	85 c0                	test   %eax,%eax
8010921f:	75 25                	jne    80109246 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80109221:	83 ec 0c             	sub    $0xc,%esp
80109224:	68 dc c3 10 80       	push   $0x8010c3dc
80109229:	e8 c6 71 ff ff       	call   801003f4 <cprintf>
8010922e:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109231:	83 ec 0c             	sub    $0xc,%esp
80109234:	ff 75 f4             	push   -0xc(%ebp)
80109237:	e8 af 01 00 00       	call   801093eb <arp_table_update>
8010923c:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010923f:	b8 01 00 00 00       	mov    $0x1,%eax
80109244:	eb 05                	jmp    8010924b <arp_proc+0x171>
  }else{
    return -1;
80109246:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
8010924b:	c9                   	leave  
8010924c:	c3                   	ret    

8010924d <arp_scan>:

void arp_scan(){
8010924d:	55                   	push   %ebp
8010924e:	89 e5                	mov    %esp,%ebp
80109250:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109253:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010925a:	eb 6f                	jmp    801092cb <arp_scan+0x7e>
    uint send = (uint)kalloc();
8010925c:	e8 3f 95 ff ff       	call   801027a0 <kalloc>
80109261:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109264:	83 ec 04             	sub    $0x4,%esp
80109267:	ff 75 f4             	push   -0xc(%ebp)
8010926a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010926d:	50                   	push   %eax
8010926e:	ff 75 ec             	push   -0x14(%ebp)
80109271:	e8 62 00 00 00       	call   801092d8 <arp_broadcast>
80109276:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109279:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010927c:	83 ec 08             	sub    $0x8,%esp
8010927f:	50                   	push   %eax
80109280:	ff 75 ec             	push   -0x14(%ebp)
80109283:	e8 26 fd ff ff       	call   80108fae <i8254_send>
80109288:	83 c4 10             	add    $0x10,%esp
8010928b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010928e:	eb 22                	jmp    801092b2 <arp_scan+0x65>
      microdelay(1);
80109290:	83 ec 0c             	sub    $0xc,%esp
80109293:	6a 01                	push   $0x1
80109295:	e8 9d 98 ff ff       	call   80102b37 <microdelay>
8010929a:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010929d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092a0:	83 ec 08             	sub    $0x8,%esp
801092a3:	50                   	push   %eax
801092a4:	ff 75 ec             	push   -0x14(%ebp)
801092a7:	e8 02 fd ff ff       	call   80108fae <i8254_send>
801092ac:	83 c4 10             	add    $0x10,%esp
801092af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801092b2:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801092b6:	74 d8                	je     80109290 <arp_scan+0x43>
    }
    kfree((char *)send);
801092b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092bb:	83 ec 0c             	sub    $0xc,%esp
801092be:	50                   	push   %eax
801092bf:	e8 42 94 ff ff       	call   80102706 <kfree>
801092c4:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801092c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801092cb:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801092d2:	7e 88                	jle    8010925c <arp_scan+0xf>
  }
}
801092d4:	90                   	nop
801092d5:	90                   	nop
801092d6:	c9                   	leave  
801092d7:	c3                   	ret    

801092d8 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801092d8:	55                   	push   %ebp
801092d9:	89 e5                	mov    %esp,%ebp
801092db:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801092de:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801092e2:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801092e6:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801092ea:	8b 45 10             	mov    0x10(%ebp),%eax
801092ed:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801092f0:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801092f7:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801092fd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109304:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010930a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010930d:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109313:	8b 45 08             	mov    0x8(%ebp),%eax
80109316:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109319:	8b 45 08             	mov    0x8(%ebp),%eax
8010931c:	83 c0 0e             	add    $0xe,%eax
8010931f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109325:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932c:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109333:	83 ec 04             	sub    $0x4,%esp
80109336:	6a 06                	push   $0x6
80109338:	8d 55 e6             	lea    -0x1a(%ebp),%edx
8010933b:	52                   	push   %edx
8010933c:	50                   	push   %eax
8010933d:	e8 41 ba ff ff       	call   80104d83 <memmove>
80109342:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109348:	83 c0 06             	add    $0x6,%eax
8010934b:	83 ec 04             	sub    $0x4,%esp
8010934e:	6a 06                	push   $0x6
80109350:	68 90 75 19 80       	push   $0x80197590
80109355:	50                   	push   %eax
80109356:	e8 28 ba ff ff       	call   80104d83 <memmove>
8010935b:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010935e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109361:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109366:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109369:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010936f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109372:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109376:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109379:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010937d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109380:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109386:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109389:	8d 50 12             	lea    0x12(%eax),%edx
8010938c:	83 ec 04             	sub    $0x4,%esp
8010938f:	6a 06                	push   $0x6
80109391:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109394:	50                   	push   %eax
80109395:	52                   	push   %edx
80109396:	e8 e8 b9 ff ff       	call   80104d83 <memmove>
8010939b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010939e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093a1:	8d 50 18             	lea    0x18(%eax),%edx
801093a4:	83 ec 04             	sub    $0x4,%esp
801093a7:	6a 04                	push   $0x4
801093a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801093ac:	50                   	push   %eax
801093ad:	52                   	push   %edx
801093ae:	e8 d0 b9 ff ff       	call   80104d83 <memmove>
801093b3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801093b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093b9:	83 c0 08             	add    $0x8,%eax
801093bc:	83 ec 04             	sub    $0x4,%esp
801093bf:	6a 06                	push   $0x6
801093c1:	68 90 75 19 80       	push   $0x80197590
801093c6:	50                   	push   %eax
801093c7:	e8 b7 b9 ff ff       	call   80104d83 <memmove>
801093cc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801093cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d2:	83 c0 0e             	add    $0xe,%eax
801093d5:	83 ec 04             	sub    $0x4,%esp
801093d8:	6a 04                	push   $0x4
801093da:	68 04 f5 10 80       	push   $0x8010f504
801093df:	50                   	push   %eax
801093e0:	e8 9e b9 ff ff       	call   80104d83 <memmove>
801093e5:	83 c4 10             	add    $0x10,%esp
}
801093e8:	90                   	nop
801093e9:	c9                   	leave  
801093ea:	c3                   	ret    

801093eb <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801093eb:	55                   	push   %ebp
801093ec:	89 e5                	mov    %esp,%ebp
801093ee:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801093f1:	8b 45 08             	mov    0x8(%ebp),%eax
801093f4:	83 c0 0e             	add    $0xe,%eax
801093f7:	83 ec 0c             	sub    $0xc,%esp
801093fa:	50                   	push   %eax
801093fb:	e8 bc 00 00 00       	call   801094bc <arp_table_search>
80109400:	83 c4 10             	add    $0x10,%esp
80109403:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109406:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010940a:	78 2d                	js     80109439 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010940c:	8b 45 08             	mov    0x8(%ebp),%eax
8010940f:	8d 48 08             	lea    0x8(%eax),%ecx
80109412:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109415:	89 d0                	mov    %edx,%eax
80109417:	c1 e0 02             	shl    $0x2,%eax
8010941a:	01 d0                	add    %edx,%eax
8010941c:	01 c0                	add    %eax,%eax
8010941e:	01 d0                	add    %edx,%eax
80109420:	05 a0 75 19 80       	add    $0x801975a0,%eax
80109425:	83 c0 04             	add    $0x4,%eax
80109428:	83 ec 04             	sub    $0x4,%esp
8010942b:	6a 06                	push   $0x6
8010942d:	51                   	push   %ecx
8010942e:	50                   	push   %eax
8010942f:	e8 4f b9 ff ff       	call   80104d83 <memmove>
80109434:	83 c4 10             	add    $0x10,%esp
80109437:	eb 70                	jmp    801094a9 <arp_table_update+0xbe>
  }else{
    index += 1;
80109439:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
8010943d:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109440:	8b 45 08             	mov    0x8(%ebp),%eax
80109443:	8d 48 08             	lea    0x8(%eax),%ecx
80109446:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109449:	89 d0                	mov    %edx,%eax
8010944b:	c1 e0 02             	shl    $0x2,%eax
8010944e:	01 d0                	add    %edx,%eax
80109450:	01 c0                	add    %eax,%eax
80109452:	01 d0                	add    %edx,%eax
80109454:	05 a0 75 19 80       	add    $0x801975a0,%eax
80109459:	83 c0 04             	add    $0x4,%eax
8010945c:	83 ec 04             	sub    $0x4,%esp
8010945f:	6a 06                	push   $0x6
80109461:	51                   	push   %ecx
80109462:	50                   	push   %eax
80109463:	e8 1b b9 ff ff       	call   80104d83 <memmove>
80109468:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
8010946b:	8b 45 08             	mov    0x8(%ebp),%eax
8010946e:	8d 48 0e             	lea    0xe(%eax),%ecx
80109471:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109474:	89 d0                	mov    %edx,%eax
80109476:	c1 e0 02             	shl    $0x2,%eax
80109479:	01 d0                	add    %edx,%eax
8010947b:	01 c0                	add    %eax,%eax
8010947d:	01 d0                	add    %edx,%eax
8010947f:	05 a0 75 19 80       	add    $0x801975a0,%eax
80109484:	83 ec 04             	sub    $0x4,%esp
80109487:	6a 04                	push   $0x4
80109489:	51                   	push   %ecx
8010948a:	50                   	push   %eax
8010948b:	e8 f3 b8 ff ff       	call   80104d83 <memmove>
80109490:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109493:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109496:	89 d0                	mov    %edx,%eax
80109498:	c1 e0 02             	shl    $0x2,%eax
8010949b:	01 d0                	add    %edx,%eax
8010949d:	01 c0                	add    %eax,%eax
8010949f:	01 d0                	add    %edx,%eax
801094a1:	05 aa 75 19 80       	add    $0x801975aa,%eax
801094a6:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801094a9:	83 ec 0c             	sub    $0xc,%esp
801094ac:	68 a0 75 19 80       	push   $0x801975a0
801094b1:	e8 83 00 00 00       	call   80109539 <print_arp_table>
801094b6:	83 c4 10             	add    $0x10,%esp
}
801094b9:	90                   	nop
801094ba:	c9                   	leave  
801094bb:	c3                   	ret    

801094bc <arp_table_search>:

int arp_table_search(uchar *ip){
801094bc:	55                   	push   %ebp
801094bd:	89 e5                	mov    %esp,%ebp
801094bf:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801094c2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801094c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801094d0:	eb 59                	jmp    8010952b <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801094d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801094d5:	89 d0                	mov    %edx,%eax
801094d7:	c1 e0 02             	shl    $0x2,%eax
801094da:	01 d0                	add    %edx,%eax
801094dc:	01 c0                	add    %eax,%eax
801094de:	01 d0                	add    %edx,%eax
801094e0:	05 a0 75 19 80       	add    $0x801975a0,%eax
801094e5:	83 ec 04             	sub    $0x4,%esp
801094e8:	6a 04                	push   $0x4
801094ea:	ff 75 08             	push   0x8(%ebp)
801094ed:	50                   	push   %eax
801094ee:	e8 38 b8 ff ff       	call   80104d2b <memcmp>
801094f3:	83 c4 10             	add    $0x10,%esp
801094f6:	85 c0                	test   %eax,%eax
801094f8:	75 05                	jne    801094ff <arp_table_search+0x43>
      return i;
801094fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094fd:	eb 38                	jmp    80109537 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801094ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109502:	89 d0                	mov    %edx,%eax
80109504:	c1 e0 02             	shl    $0x2,%eax
80109507:	01 d0                	add    %edx,%eax
80109509:	01 c0                	add    %eax,%eax
8010950b:	01 d0                	add    %edx,%eax
8010950d:	05 aa 75 19 80       	add    $0x801975aa,%eax
80109512:	0f b6 00             	movzbl (%eax),%eax
80109515:	84 c0                	test   %al,%al
80109517:	75 0e                	jne    80109527 <arp_table_search+0x6b>
80109519:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010951d:	75 08                	jne    80109527 <arp_table_search+0x6b>
      empty = -i;
8010951f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109522:	f7 d8                	neg    %eax
80109524:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109527:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010952b:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010952f:	7e a1                	jle    801094d2 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109534:	83 e8 01             	sub    $0x1,%eax
}
80109537:	c9                   	leave  
80109538:	c3                   	ret    

80109539 <print_arp_table>:

void print_arp_table(){
80109539:	55                   	push   %ebp
8010953a:	89 e5                	mov    %esp,%ebp
8010953c:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010953f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109546:	e9 92 00 00 00       	jmp    801095dd <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
8010954b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010954e:	89 d0                	mov    %edx,%eax
80109550:	c1 e0 02             	shl    $0x2,%eax
80109553:	01 d0                	add    %edx,%eax
80109555:	01 c0                	add    %eax,%eax
80109557:	01 d0                	add    %edx,%eax
80109559:	05 aa 75 19 80       	add    $0x801975aa,%eax
8010955e:	0f b6 00             	movzbl (%eax),%eax
80109561:	84 c0                	test   %al,%al
80109563:	74 74                	je     801095d9 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109565:	83 ec 08             	sub    $0x8,%esp
80109568:	ff 75 f4             	push   -0xc(%ebp)
8010956b:	68 ef c3 10 80       	push   $0x8010c3ef
80109570:	e8 7f 6e ff ff       	call   801003f4 <cprintf>
80109575:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109578:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010957b:	89 d0                	mov    %edx,%eax
8010957d:	c1 e0 02             	shl    $0x2,%eax
80109580:	01 d0                	add    %edx,%eax
80109582:	01 c0                	add    %eax,%eax
80109584:	01 d0                	add    %edx,%eax
80109586:	05 a0 75 19 80       	add    $0x801975a0,%eax
8010958b:	83 ec 0c             	sub    $0xc,%esp
8010958e:	50                   	push   %eax
8010958f:	e8 54 02 00 00       	call   801097e8 <print_ipv4>
80109594:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109597:	83 ec 0c             	sub    $0xc,%esp
8010959a:	68 fe c3 10 80       	push   $0x8010c3fe
8010959f:	e8 50 6e ff ff       	call   801003f4 <cprintf>
801095a4:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801095a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095aa:	89 d0                	mov    %edx,%eax
801095ac:	c1 e0 02             	shl    $0x2,%eax
801095af:	01 d0                	add    %edx,%eax
801095b1:	01 c0                	add    %eax,%eax
801095b3:	01 d0                	add    %edx,%eax
801095b5:	05 a0 75 19 80       	add    $0x801975a0,%eax
801095ba:	83 c0 04             	add    $0x4,%eax
801095bd:	83 ec 0c             	sub    $0xc,%esp
801095c0:	50                   	push   %eax
801095c1:	e8 70 02 00 00       	call   80109836 <print_mac>
801095c6:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801095c9:	83 ec 0c             	sub    $0xc,%esp
801095cc:	68 00 c4 10 80       	push   $0x8010c400
801095d1:	e8 1e 6e ff ff       	call   801003f4 <cprintf>
801095d6:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801095d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801095dd:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801095e1:	0f 8e 64 ff ff ff    	jle    8010954b <print_arp_table+0x12>
    }
  }
}
801095e7:	90                   	nop
801095e8:	90                   	nop
801095e9:	c9                   	leave  
801095ea:	c3                   	ret    

801095eb <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801095eb:	55                   	push   %ebp
801095ec:	89 e5                	mov    %esp,%ebp
801095ee:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801095f1:	8b 45 10             	mov    0x10(%ebp),%eax
801095f4:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801095fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801095fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109600:	8b 45 0c             	mov    0xc(%ebp),%eax
80109603:	83 c0 0e             	add    $0xe,%eax
80109606:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010960c:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109613:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109617:	8b 45 08             	mov    0x8(%ebp),%eax
8010961a:	8d 50 08             	lea    0x8(%eax),%edx
8010961d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109620:	83 ec 04             	sub    $0x4,%esp
80109623:	6a 06                	push   $0x6
80109625:	52                   	push   %edx
80109626:	50                   	push   %eax
80109627:	e8 57 b7 ff ff       	call   80104d83 <memmove>
8010962c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010962f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109632:	83 c0 06             	add    $0x6,%eax
80109635:	83 ec 04             	sub    $0x4,%esp
80109638:	6a 06                	push   $0x6
8010963a:	68 90 75 19 80       	push   $0x80197590
8010963f:	50                   	push   %eax
80109640:	e8 3e b7 ff ff       	call   80104d83 <memmove>
80109645:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109648:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010964b:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109653:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010965c:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109663:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109667:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010966a:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109670:	8b 45 08             	mov    0x8(%ebp),%eax
80109673:	8d 50 08             	lea    0x8(%eax),%edx
80109676:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109679:	83 c0 12             	add    $0x12,%eax
8010967c:	83 ec 04             	sub    $0x4,%esp
8010967f:	6a 06                	push   $0x6
80109681:	52                   	push   %edx
80109682:	50                   	push   %eax
80109683:	e8 fb b6 ff ff       	call   80104d83 <memmove>
80109688:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010968b:	8b 45 08             	mov    0x8(%ebp),%eax
8010968e:	8d 50 0e             	lea    0xe(%eax),%edx
80109691:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109694:	83 c0 18             	add    $0x18,%eax
80109697:	83 ec 04             	sub    $0x4,%esp
8010969a:	6a 04                	push   $0x4
8010969c:	52                   	push   %edx
8010969d:	50                   	push   %eax
8010969e:	e8 e0 b6 ff ff       	call   80104d83 <memmove>
801096a3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801096a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a9:	83 c0 08             	add    $0x8,%eax
801096ac:	83 ec 04             	sub    $0x4,%esp
801096af:	6a 06                	push   $0x6
801096b1:	68 90 75 19 80       	push   $0x80197590
801096b6:	50                   	push   %eax
801096b7:	e8 c7 b6 ff ff       	call   80104d83 <memmove>
801096bc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801096bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096c2:	83 c0 0e             	add    $0xe,%eax
801096c5:	83 ec 04             	sub    $0x4,%esp
801096c8:	6a 04                	push   $0x4
801096ca:	68 04 f5 10 80       	push   $0x8010f504
801096cf:	50                   	push   %eax
801096d0:	e8 ae b6 ff ff       	call   80104d83 <memmove>
801096d5:	83 c4 10             	add    $0x10,%esp
}
801096d8:	90                   	nop
801096d9:	c9                   	leave  
801096da:	c3                   	ret    

801096db <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801096db:	55                   	push   %ebp
801096dc:	89 e5                	mov    %esp,%ebp
801096de:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801096e1:	83 ec 0c             	sub    $0xc,%esp
801096e4:	68 02 c4 10 80       	push   $0x8010c402
801096e9:	e8 06 6d ff ff       	call   801003f4 <cprintf>
801096ee:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801096f1:	8b 45 08             	mov    0x8(%ebp),%eax
801096f4:	83 c0 0e             	add    $0xe,%eax
801096f7:	83 ec 0c             	sub    $0xc,%esp
801096fa:	50                   	push   %eax
801096fb:	e8 e8 00 00 00       	call   801097e8 <print_ipv4>
80109700:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109703:	83 ec 0c             	sub    $0xc,%esp
80109706:	68 00 c4 10 80       	push   $0x8010c400
8010970b:	e8 e4 6c ff ff       	call   801003f4 <cprintf>
80109710:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109713:	8b 45 08             	mov    0x8(%ebp),%eax
80109716:	83 c0 08             	add    $0x8,%eax
80109719:	83 ec 0c             	sub    $0xc,%esp
8010971c:	50                   	push   %eax
8010971d:	e8 14 01 00 00       	call   80109836 <print_mac>
80109722:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109725:	83 ec 0c             	sub    $0xc,%esp
80109728:	68 00 c4 10 80       	push   $0x8010c400
8010972d:	e8 c2 6c ff ff       	call   801003f4 <cprintf>
80109732:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109735:	83 ec 0c             	sub    $0xc,%esp
80109738:	68 19 c4 10 80       	push   $0x8010c419
8010973d:	e8 b2 6c ff ff       	call   801003f4 <cprintf>
80109742:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109745:	8b 45 08             	mov    0x8(%ebp),%eax
80109748:	83 c0 18             	add    $0x18,%eax
8010974b:	83 ec 0c             	sub    $0xc,%esp
8010974e:	50                   	push   %eax
8010974f:	e8 94 00 00 00       	call   801097e8 <print_ipv4>
80109754:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109757:	83 ec 0c             	sub    $0xc,%esp
8010975a:	68 00 c4 10 80       	push   $0x8010c400
8010975f:	e8 90 6c ff ff       	call   801003f4 <cprintf>
80109764:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109767:	8b 45 08             	mov    0x8(%ebp),%eax
8010976a:	83 c0 12             	add    $0x12,%eax
8010976d:	83 ec 0c             	sub    $0xc,%esp
80109770:	50                   	push   %eax
80109771:	e8 c0 00 00 00       	call   80109836 <print_mac>
80109776:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109779:	83 ec 0c             	sub    $0xc,%esp
8010977c:	68 00 c4 10 80       	push   $0x8010c400
80109781:	e8 6e 6c ff ff       	call   801003f4 <cprintf>
80109786:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109789:	83 ec 0c             	sub    $0xc,%esp
8010978c:	68 30 c4 10 80       	push   $0x8010c430
80109791:	e8 5e 6c ff ff       	call   801003f4 <cprintf>
80109796:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109799:	8b 45 08             	mov    0x8(%ebp),%eax
8010979c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801097a0:	66 3d 00 01          	cmp    $0x100,%ax
801097a4:	75 12                	jne    801097b8 <print_arp_info+0xdd>
801097a6:	83 ec 0c             	sub    $0xc,%esp
801097a9:	68 3c c4 10 80       	push   $0x8010c43c
801097ae:	e8 41 6c ff ff       	call   801003f4 <cprintf>
801097b3:	83 c4 10             	add    $0x10,%esp
801097b6:	eb 1d                	jmp    801097d5 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801097b8:	8b 45 08             	mov    0x8(%ebp),%eax
801097bb:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801097bf:	66 3d 00 02          	cmp    $0x200,%ax
801097c3:	75 10                	jne    801097d5 <print_arp_info+0xfa>
    cprintf("Reply\n");
801097c5:	83 ec 0c             	sub    $0xc,%esp
801097c8:	68 45 c4 10 80       	push   $0x8010c445
801097cd:	e8 22 6c ff ff       	call   801003f4 <cprintf>
801097d2:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801097d5:	83 ec 0c             	sub    $0xc,%esp
801097d8:	68 00 c4 10 80       	push   $0x8010c400
801097dd:	e8 12 6c ff ff       	call   801003f4 <cprintf>
801097e2:	83 c4 10             	add    $0x10,%esp
}
801097e5:	90                   	nop
801097e6:	c9                   	leave  
801097e7:	c3                   	ret    

801097e8 <print_ipv4>:

void print_ipv4(uchar *ip){
801097e8:	55                   	push   %ebp
801097e9:	89 e5                	mov    %esp,%ebp
801097eb:	53                   	push   %ebx
801097ec:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801097ef:	8b 45 08             	mov    0x8(%ebp),%eax
801097f2:	83 c0 03             	add    $0x3,%eax
801097f5:	0f b6 00             	movzbl (%eax),%eax
801097f8:	0f b6 d8             	movzbl %al,%ebx
801097fb:	8b 45 08             	mov    0x8(%ebp),%eax
801097fe:	83 c0 02             	add    $0x2,%eax
80109801:	0f b6 00             	movzbl (%eax),%eax
80109804:	0f b6 c8             	movzbl %al,%ecx
80109807:	8b 45 08             	mov    0x8(%ebp),%eax
8010980a:	83 c0 01             	add    $0x1,%eax
8010980d:	0f b6 00             	movzbl (%eax),%eax
80109810:	0f b6 d0             	movzbl %al,%edx
80109813:	8b 45 08             	mov    0x8(%ebp),%eax
80109816:	0f b6 00             	movzbl (%eax),%eax
80109819:	0f b6 c0             	movzbl %al,%eax
8010981c:	83 ec 0c             	sub    $0xc,%esp
8010981f:	53                   	push   %ebx
80109820:	51                   	push   %ecx
80109821:	52                   	push   %edx
80109822:	50                   	push   %eax
80109823:	68 4c c4 10 80       	push   $0x8010c44c
80109828:	e8 c7 6b ff ff       	call   801003f4 <cprintf>
8010982d:	83 c4 20             	add    $0x20,%esp
}
80109830:	90                   	nop
80109831:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109834:	c9                   	leave  
80109835:	c3                   	ret    

80109836 <print_mac>:

void print_mac(uchar *mac){
80109836:	55                   	push   %ebp
80109837:	89 e5                	mov    %esp,%ebp
80109839:	57                   	push   %edi
8010983a:	56                   	push   %esi
8010983b:	53                   	push   %ebx
8010983c:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010983f:	8b 45 08             	mov    0x8(%ebp),%eax
80109842:	83 c0 05             	add    $0x5,%eax
80109845:	0f b6 00             	movzbl (%eax),%eax
80109848:	0f b6 f8             	movzbl %al,%edi
8010984b:	8b 45 08             	mov    0x8(%ebp),%eax
8010984e:	83 c0 04             	add    $0x4,%eax
80109851:	0f b6 00             	movzbl (%eax),%eax
80109854:	0f b6 f0             	movzbl %al,%esi
80109857:	8b 45 08             	mov    0x8(%ebp),%eax
8010985a:	83 c0 03             	add    $0x3,%eax
8010985d:	0f b6 00             	movzbl (%eax),%eax
80109860:	0f b6 d8             	movzbl %al,%ebx
80109863:	8b 45 08             	mov    0x8(%ebp),%eax
80109866:	83 c0 02             	add    $0x2,%eax
80109869:	0f b6 00             	movzbl (%eax),%eax
8010986c:	0f b6 c8             	movzbl %al,%ecx
8010986f:	8b 45 08             	mov    0x8(%ebp),%eax
80109872:	83 c0 01             	add    $0x1,%eax
80109875:	0f b6 00             	movzbl (%eax),%eax
80109878:	0f b6 d0             	movzbl %al,%edx
8010987b:	8b 45 08             	mov    0x8(%ebp),%eax
8010987e:	0f b6 00             	movzbl (%eax),%eax
80109881:	0f b6 c0             	movzbl %al,%eax
80109884:	83 ec 04             	sub    $0x4,%esp
80109887:	57                   	push   %edi
80109888:	56                   	push   %esi
80109889:	53                   	push   %ebx
8010988a:	51                   	push   %ecx
8010988b:	52                   	push   %edx
8010988c:	50                   	push   %eax
8010988d:	68 64 c4 10 80       	push   $0x8010c464
80109892:	e8 5d 6b ff ff       	call   801003f4 <cprintf>
80109897:	83 c4 20             	add    $0x20,%esp
}
8010989a:	90                   	nop
8010989b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010989e:	5b                   	pop    %ebx
8010989f:	5e                   	pop    %esi
801098a0:	5f                   	pop    %edi
801098a1:	5d                   	pop    %ebp
801098a2:	c3                   	ret    

801098a3 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801098a3:	55                   	push   %ebp
801098a4:	89 e5                	mov    %esp,%ebp
801098a6:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801098a9:	8b 45 08             	mov    0x8(%ebp),%eax
801098ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801098af:	8b 45 08             	mov    0x8(%ebp),%eax
801098b2:	83 c0 0e             	add    $0xe,%eax
801098b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801098b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098bb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801098bf:	3c 08                	cmp    $0x8,%al
801098c1:	75 1b                	jne    801098de <eth_proc+0x3b>
801098c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098c6:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098ca:	3c 06                	cmp    $0x6,%al
801098cc:	75 10                	jne    801098de <eth_proc+0x3b>
    arp_proc(pkt_addr);
801098ce:	83 ec 0c             	sub    $0xc,%esp
801098d1:	ff 75 f0             	push   -0x10(%ebp)
801098d4:	e8 01 f8 ff ff       	call   801090da <arp_proc>
801098d9:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801098dc:	eb 24                	jmp    80109902 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801098de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098e1:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801098e5:	3c 08                	cmp    $0x8,%al
801098e7:	75 19                	jne    80109902 <eth_proc+0x5f>
801098e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ec:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098f0:	84 c0                	test   %al,%al
801098f2:	75 0e                	jne    80109902 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801098f4:	83 ec 0c             	sub    $0xc,%esp
801098f7:	ff 75 08             	push   0x8(%ebp)
801098fa:	e8 a3 00 00 00       	call   801099a2 <ipv4_proc>
801098ff:	83 c4 10             	add    $0x10,%esp
}
80109902:	90                   	nop
80109903:	c9                   	leave  
80109904:	c3                   	ret    

80109905 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109905:	55                   	push   %ebp
80109906:	89 e5                	mov    %esp,%ebp
80109908:	83 ec 04             	sub    $0x4,%esp
8010990b:	8b 45 08             	mov    0x8(%ebp),%eax
8010990e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109912:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109916:	c1 e0 08             	shl    $0x8,%eax
80109919:	89 c2                	mov    %eax,%edx
8010991b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010991f:	66 c1 e8 08          	shr    $0x8,%ax
80109923:	01 d0                	add    %edx,%eax
}
80109925:	c9                   	leave  
80109926:	c3                   	ret    

80109927 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109927:	55                   	push   %ebp
80109928:	89 e5                	mov    %esp,%ebp
8010992a:	83 ec 04             	sub    $0x4,%esp
8010992d:	8b 45 08             	mov    0x8(%ebp),%eax
80109930:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109934:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109938:	c1 e0 08             	shl    $0x8,%eax
8010993b:	89 c2                	mov    %eax,%edx
8010993d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109941:	66 c1 e8 08          	shr    $0x8,%ax
80109945:	01 d0                	add    %edx,%eax
}
80109947:	c9                   	leave  
80109948:	c3                   	ret    

80109949 <H2N_uint>:

uint H2N_uint(uint value){
80109949:	55                   	push   %ebp
8010994a:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010994c:	8b 45 08             	mov    0x8(%ebp),%eax
8010994f:	c1 e0 18             	shl    $0x18,%eax
80109952:	25 00 00 00 0f       	and    $0xf000000,%eax
80109957:	89 c2                	mov    %eax,%edx
80109959:	8b 45 08             	mov    0x8(%ebp),%eax
8010995c:	c1 e0 08             	shl    $0x8,%eax
8010995f:	25 00 f0 00 00       	and    $0xf000,%eax
80109964:	09 c2                	or     %eax,%edx
80109966:	8b 45 08             	mov    0x8(%ebp),%eax
80109969:	c1 e8 08             	shr    $0x8,%eax
8010996c:	83 e0 0f             	and    $0xf,%eax
8010996f:	01 d0                	add    %edx,%eax
}
80109971:	5d                   	pop    %ebp
80109972:	c3                   	ret    

80109973 <N2H_uint>:

uint N2H_uint(uint value){
80109973:	55                   	push   %ebp
80109974:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109976:	8b 45 08             	mov    0x8(%ebp),%eax
80109979:	c1 e0 18             	shl    $0x18,%eax
8010997c:	89 c2                	mov    %eax,%edx
8010997e:	8b 45 08             	mov    0x8(%ebp),%eax
80109981:	c1 e0 08             	shl    $0x8,%eax
80109984:	25 00 00 ff 00       	and    $0xff0000,%eax
80109989:	01 c2                	add    %eax,%edx
8010998b:	8b 45 08             	mov    0x8(%ebp),%eax
8010998e:	c1 e8 08             	shr    $0x8,%eax
80109991:	25 00 ff 00 00       	and    $0xff00,%eax
80109996:	01 c2                	add    %eax,%edx
80109998:	8b 45 08             	mov    0x8(%ebp),%eax
8010999b:	c1 e8 18             	shr    $0x18,%eax
8010999e:	01 d0                	add    %edx,%eax
}
801099a0:	5d                   	pop    %ebp
801099a1:	c3                   	ret    

801099a2 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
801099a2:	55                   	push   %ebp
801099a3:	89 e5                	mov    %esp,%ebp
801099a5:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801099a8:	8b 45 08             	mov    0x8(%ebp),%eax
801099ab:	83 c0 0e             	add    $0xe,%eax
801099ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801099b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801099b8:	0f b7 d0             	movzwl %ax,%edx
801099bb:	a1 08 f5 10 80       	mov    0x8010f508,%eax
801099c0:	39 c2                	cmp    %eax,%edx
801099c2:	74 60                	je     80109a24 <ipv4_proc+0x82>
801099c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c7:	83 c0 0c             	add    $0xc,%eax
801099ca:	83 ec 04             	sub    $0x4,%esp
801099cd:	6a 04                	push   $0x4
801099cf:	50                   	push   %eax
801099d0:	68 04 f5 10 80       	push   $0x8010f504
801099d5:	e8 51 b3 ff ff       	call   80104d2b <memcmp>
801099da:	83 c4 10             	add    $0x10,%esp
801099dd:	85 c0                	test   %eax,%eax
801099df:	74 43                	je     80109a24 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801099e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099e4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801099e8:	0f b7 c0             	movzwl %ax,%eax
801099eb:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801099f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099f3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801099f7:	3c 01                	cmp    $0x1,%al
801099f9:	75 10                	jne    80109a0b <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801099fb:	83 ec 0c             	sub    $0xc,%esp
801099fe:	ff 75 08             	push   0x8(%ebp)
80109a01:	e8 a3 00 00 00       	call   80109aa9 <icmp_proc>
80109a06:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109a09:	eb 19                	jmp    80109a24 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a0e:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109a12:	3c 06                	cmp    $0x6,%al
80109a14:	75 0e                	jne    80109a24 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109a16:	83 ec 0c             	sub    $0xc,%esp
80109a19:	ff 75 08             	push   0x8(%ebp)
80109a1c:	e8 b3 03 00 00       	call   80109dd4 <tcp_proc>
80109a21:	83 c4 10             	add    $0x10,%esp
}
80109a24:	90                   	nop
80109a25:	c9                   	leave  
80109a26:	c3                   	ret    

80109a27 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109a27:	55                   	push   %ebp
80109a28:	89 e5                	mov    %esp,%ebp
80109a2a:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a36:	0f b6 00             	movzbl (%eax),%eax
80109a39:	83 e0 0f             	and    $0xf,%eax
80109a3c:	01 c0                	add    %eax,%eax
80109a3e:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109a41:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a48:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109a4f:	eb 48                	jmp    80109a99 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109a51:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a54:	01 c0                	add    %eax,%eax
80109a56:	89 c2                	mov    %eax,%edx
80109a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a5b:	01 d0                	add    %edx,%eax
80109a5d:	0f b6 00             	movzbl (%eax),%eax
80109a60:	0f b6 c0             	movzbl %al,%eax
80109a63:	c1 e0 08             	shl    $0x8,%eax
80109a66:	89 c2                	mov    %eax,%edx
80109a68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a6b:	01 c0                	add    %eax,%eax
80109a6d:	8d 48 01             	lea    0x1(%eax),%ecx
80109a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a73:	01 c8                	add    %ecx,%eax
80109a75:	0f b6 00             	movzbl (%eax),%eax
80109a78:	0f b6 c0             	movzbl %al,%eax
80109a7b:	01 d0                	add    %edx,%eax
80109a7d:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109a80:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109a87:	76 0c                	jbe    80109a95 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109a89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a8c:	0f b7 c0             	movzwl %ax,%eax
80109a8f:	83 c0 01             	add    $0x1,%eax
80109a92:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a95:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109a99:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109a9d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109aa0:	7c af                	jl     80109a51 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109aa2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109aa5:	f7 d0                	not    %eax
}
80109aa7:	c9                   	leave  
80109aa8:	c3                   	ret    

80109aa9 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109aa9:	55                   	push   %ebp
80109aaa:	89 e5                	mov    %esp,%ebp
80109aac:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab2:	83 c0 0e             	add    $0xe,%eax
80109ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109abb:	0f b6 00             	movzbl (%eax),%eax
80109abe:	0f b6 c0             	movzbl %al,%eax
80109ac1:	83 e0 0f             	and    $0xf,%eax
80109ac4:	c1 e0 02             	shl    $0x2,%eax
80109ac7:	89 c2                	mov    %eax,%edx
80109ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109acc:	01 d0                	add    %edx,%eax
80109ace:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ad4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109ad8:	84 c0                	test   %al,%al
80109ada:	75 4f                	jne    80109b2b <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109adf:	0f b6 00             	movzbl (%eax),%eax
80109ae2:	3c 08                	cmp    $0x8,%al
80109ae4:	75 45                	jne    80109b2b <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109ae6:	e8 b5 8c ff ff       	call   801027a0 <kalloc>
80109aeb:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109aee:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109af5:	83 ec 04             	sub    $0x4,%esp
80109af8:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109afb:	50                   	push   %eax
80109afc:	ff 75 ec             	push   -0x14(%ebp)
80109aff:	ff 75 08             	push   0x8(%ebp)
80109b02:	e8 78 00 00 00       	call   80109b7f <icmp_reply_pkt_create>
80109b07:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109b0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b0d:	83 ec 08             	sub    $0x8,%esp
80109b10:	50                   	push   %eax
80109b11:	ff 75 ec             	push   -0x14(%ebp)
80109b14:	e8 95 f4 ff ff       	call   80108fae <i8254_send>
80109b19:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109b1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b1f:	83 ec 0c             	sub    $0xc,%esp
80109b22:	50                   	push   %eax
80109b23:	e8 de 8b ff ff       	call   80102706 <kfree>
80109b28:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109b2b:	90                   	nop
80109b2c:	c9                   	leave  
80109b2d:	c3                   	ret    

80109b2e <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109b2e:	55                   	push   %ebp
80109b2f:	89 e5                	mov    %esp,%ebp
80109b31:	53                   	push   %ebx
80109b32:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109b35:	8b 45 08             	mov    0x8(%ebp),%eax
80109b38:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b3c:	0f b7 c0             	movzwl %ax,%eax
80109b3f:	83 ec 0c             	sub    $0xc,%esp
80109b42:	50                   	push   %eax
80109b43:	e8 bd fd ff ff       	call   80109905 <N2H_ushort>
80109b48:	83 c4 10             	add    $0x10,%esp
80109b4b:	0f b7 d8             	movzwl %ax,%ebx
80109b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b51:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b55:	0f b7 c0             	movzwl %ax,%eax
80109b58:	83 ec 0c             	sub    $0xc,%esp
80109b5b:	50                   	push   %eax
80109b5c:	e8 a4 fd ff ff       	call   80109905 <N2H_ushort>
80109b61:	83 c4 10             	add    $0x10,%esp
80109b64:	0f b7 c0             	movzwl %ax,%eax
80109b67:	83 ec 04             	sub    $0x4,%esp
80109b6a:	53                   	push   %ebx
80109b6b:	50                   	push   %eax
80109b6c:	68 83 c4 10 80       	push   $0x8010c483
80109b71:	e8 7e 68 ff ff       	call   801003f4 <cprintf>
80109b76:	83 c4 10             	add    $0x10,%esp
}
80109b79:	90                   	nop
80109b7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b7d:	c9                   	leave  
80109b7e:	c3                   	ret    

80109b7f <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109b7f:	55                   	push   %ebp
80109b80:	89 e5                	mov    %esp,%ebp
80109b82:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b85:	8b 45 08             	mov    0x8(%ebp),%eax
80109b88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b8e:	83 c0 0e             	add    $0xe,%eax
80109b91:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b97:	0f b6 00             	movzbl (%eax),%eax
80109b9a:	0f b6 c0             	movzbl %al,%eax
80109b9d:	83 e0 0f             	and    $0xf,%eax
80109ba0:	c1 e0 02             	shl    $0x2,%eax
80109ba3:	89 c2                	mov    %eax,%edx
80109ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ba8:	01 d0                	add    %edx,%eax
80109baa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109bad:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bb6:	83 c0 0e             	add    $0xe,%eax
80109bb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bbf:	83 c0 14             	add    $0x14,%eax
80109bc2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109bc5:	8b 45 10             	mov    0x10(%ebp),%eax
80109bc8:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bd1:	8d 50 06             	lea    0x6(%eax),%edx
80109bd4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bd7:	83 ec 04             	sub    $0x4,%esp
80109bda:	6a 06                	push   $0x6
80109bdc:	52                   	push   %edx
80109bdd:	50                   	push   %eax
80109bde:	e8 a0 b1 ff ff       	call   80104d83 <memmove>
80109be3:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109be6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109be9:	83 c0 06             	add    $0x6,%eax
80109bec:	83 ec 04             	sub    $0x4,%esp
80109bef:	6a 06                	push   $0x6
80109bf1:	68 90 75 19 80       	push   $0x80197590
80109bf6:	50                   	push   %eax
80109bf7:	e8 87 b1 ff ff       	call   80104d83 <memmove>
80109bfc:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109bff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c02:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c06:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c09:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c10:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c16:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109c1a:	83 ec 0c             	sub    $0xc,%esp
80109c1d:	6a 54                	push   $0x54
80109c1f:	e8 03 fd ff ff       	call   80109927 <H2N_ushort>
80109c24:	83 c4 10             	add    $0x10,%esp
80109c27:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c2a:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109c2e:	0f b7 15 60 78 19 80 	movzwl 0x80197860,%edx
80109c35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c38:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c3c:	0f b7 05 60 78 19 80 	movzwl 0x80197860,%eax
80109c43:	83 c0 01             	add    $0x1,%eax
80109c46:	66 a3 60 78 19 80    	mov    %ax,0x80197860
  ipv4_send->fragment = H2N_ushort(0x4000);
80109c4c:	83 ec 0c             	sub    $0xc,%esp
80109c4f:	68 00 40 00 00       	push   $0x4000
80109c54:	e8 ce fc ff ff       	call   80109927 <H2N_ushort>
80109c59:	83 c4 10             	add    $0x10,%esp
80109c5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c5f:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109c63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c66:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109c6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c6d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109c71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c74:	83 c0 0c             	add    $0xc,%eax
80109c77:	83 ec 04             	sub    $0x4,%esp
80109c7a:	6a 04                	push   $0x4
80109c7c:	68 04 f5 10 80       	push   $0x8010f504
80109c81:	50                   	push   %eax
80109c82:	e8 fc b0 ff ff       	call   80104d83 <memmove>
80109c87:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c8d:	8d 50 0c             	lea    0xc(%eax),%edx
80109c90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c93:	83 c0 10             	add    $0x10,%eax
80109c96:	83 ec 04             	sub    $0x4,%esp
80109c99:	6a 04                	push   $0x4
80109c9b:	52                   	push   %edx
80109c9c:	50                   	push   %eax
80109c9d:	e8 e1 b0 ff ff       	call   80104d83 <memmove>
80109ca2:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109ca5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ca8:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109cae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cb1:	83 ec 0c             	sub    $0xc,%esp
80109cb4:	50                   	push   %eax
80109cb5:	e8 6d fd ff ff       	call   80109a27 <ipv4_chksum>
80109cba:	83 c4 10             	add    $0x10,%esp
80109cbd:	0f b7 c0             	movzwl %ax,%eax
80109cc0:	83 ec 0c             	sub    $0xc,%esp
80109cc3:	50                   	push   %eax
80109cc4:	e8 5e fc ff ff       	call   80109927 <H2N_ushort>
80109cc9:	83 c4 10             	add    $0x10,%esp
80109ccc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ccf:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cd6:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cdc:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ce3:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109ce7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cea:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109cee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cf1:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109cf5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cf8:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109cfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cff:	8d 50 08             	lea    0x8(%eax),%edx
80109d02:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d05:	83 c0 08             	add    $0x8,%eax
80109d08:	83 ec 04             	sub    $0x4,%esp
80109d0b:	6a 08                	push   $0x8
80109d0d:	52                   	push   %edx
80109d0e:	50                   	push   %eax
80109d0f:	e8 6f b0 ff ff       	call   80104d83 <memmove>
80109d14:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109d17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d1a:	8d 50 10             	lea    0x10(%eax),%edx
80109d1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d20:	83 c0 10             	add    $0x10,%eax
80109d23:	83 ec 04             	sub    $0x4,%esp
80109d26:	6a 30                	push   $0x30
80109d28:	52                   	push   %edx
80109d29:	50                   	push   %eax
80109d2a:	e8 54 b0 ff ff       	call   80104d83 <memmove>
80109d2f:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109d32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d35:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109d3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d3e:	83 ec 0c             	sub    $0xc,%esp
80109d41:	50                   	push   %eax
80109d42:	e8 1c 00 00 00       	call   80109d63 <icmp_chksum>
80109d47:	83 c4 10             	add    $0x10,%esp
80109d4a:	0f b7 c0             	movzwl %ax,%eax
80109d4d:	83 ec 0c             	sub    $0xc,%esp
80109d50:	50                   	push   %eax
80109d51:	e8 d1 fb ff ff       	call   80109927 <H2N_ushort>
80109d56:	83 c4 10             	add    $0x10,%esp
80109d59:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d5c:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109d60:	90                   	nop
80109d61:	c9                   	leave  
80109d62:	c3                   	ret    

80109d63 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109d63:	55                   	push   %ebp
80109d64:	89 e5                	mov    %esp,%ebp
80109d66:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109d69:	8b 45 08             	mov    0x8(%ebp),%eax
80109d6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109d6f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d76:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109d7d:	eb 48                	jmp    80109dc7 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d82:	01 c0                	add    %eax,%eax
80109d84:	89 c2                	mov    %eax,%edx
80109d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d89:	01 d0                	add    %edx,%eax
80109d8b:	0f b6 00             	movzbl (%eax),%eax
80109d8e:	0f b6 c0             	movzbl %al,%eax
80109d91:	c1 e0 08             	shl    $0x8,%eax
80109d94:	89 c2                	mov    %eax,%edx
80109d96:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d99:	01 c0                	add    %eax,%eax
80109d9b:	8d 48 01             	lea    0x1(%eax),%ecx
80109d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109da1:	01 c8                	add    %ecx,%eax
80109da3:	0f b6 00             	movzbl (%eax),%eax
80109da6:	0f b6 c0             	movzbl %al,%eax
80109da9:	01 d0                	add    %edx,%eax
80109dab:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109dae:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109db5:	76 0c                	jbe    80109dc3 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109db7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109dba:	0f b7 c0             	movzwl %ax,%eax
80109dbd:	83 c0 01             	add    $0x1,%eax
80109dc0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109dc3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109dc7:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109dcb:	7e b2                	jle    80109d7f <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109dcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109dd0:	f7 d0                	not    %eax
}
80109dd2:	c9                   	leave  
80109dd3:	c3                   	ret    

80109dd4 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109dd4:	55                   	push   %ebp
80109dd5:	89 e5                	mov    %esp,%ebp
80109dd7:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109dda:	8b 45 08             	mov    0x8(%ebp),%eax
80109ddd:	83 c0 0e             	add    $0xe,%eax
80109de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109de6:	0f b6 00             	movzbl (%eax),%eax
80109de9:	0f b6 c0             	movzbl %al,%eax
80109dec:	83 e0 0f             	and    $0xf,%eax
80109def:	c1 e0 02             	shl    $0x2,%eax
80109df2:	89 c2                	mov    %eax,%edx
80109df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109df7:	01 d0                	add    %edx,%eax
80109df9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dff:	83 c0 14             	add    $0x14,%eax
80109e02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109e05:	e8 96 89 ff ff       	call   801027a0 <kalloc>
80109e0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109e0d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e17:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e1b:	0f b6 c0             	movzbl %al,%eax
80109e1e:	83 e0 02             	and    $0x2,%eax
80109e21:	85 c0                	test   %eax,%eax
80109e23:	74 3d                	je     80109e62 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109e25:	83 ec 0c             	sub    $0xc,%esp
80109e28:	6a 00                	push   $0x0
80109e2a:	6a 12                	push   $0x12
80109e2c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e2f:	50                   	push   %eax
80109e30:	ff 75 e8             	push   -0x18(%ebp)
80109e33:	ff 75 08             	push   0x8(%ebp)
80109e36:	e8 a2 01 00 00       	call   80109fdd <tcp_pkt_create>
80109e3b:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109e3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e41:	83 ec 08             	sub    $0x8,%esp
80109e44:	50                   	push   %eax
80109e45:	ff 75 e8             	push   -0x18(%ebp)
80109e48:	e8 61 f1 ff ff       	call   80108fae <i8254_send>
80109e4d:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109e50:	a1 64 78 19 80       	mov    0x80197864,%eax
80109e55:	83 c0 01             	add    $0x1,%eax
80109e58:	a3 64 78 19 80       	mov    %eax,0x80197864
80109e5d:	e9 69 01 00 00       	jmp    80109fcb <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e65:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e69:	3c 18                	cmp    $0x18,%al
80109e6b:	0f 85 10 01 00 00    	jne    80109f81 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109e71:	83 ec 04             	sub    $0x4,%esp
80109e74:	6a 03                	push   $0x3
80109e76:	68 9e c4 10 80       	push   $0x8010c49e
80109e7b:	ff 75 ec             	push   -0x14(%ebp)
80109e7e:	e8 a8 ae ff ff       	call   80104d2b <memcmp>
80109e83:	83 c4 10             	add    $0x10,%esp
80109e86:	85 c0                	test   %eax,%eax
80109e88:	74 74                	je     80109efe <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109e8a:	83 ec 0c             	sub    $0xc,%esp
80109e8d:	68 a2 c4 10 80       	push   $0x8010c4a2
80109e92:	e8 5d 65 ff ff       	call   801003f4 <cprintf>
80109e97:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e9a:	83 ec 0c             	sub    $0xc,%esp
80109e9d:	6a 00                	push   $0x0
80109e9f:	6a 10                	push   $0x10
80109ea1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ea4:	50                   	push   %eax
80109ea5:	ff 75 e8             	push   -0x18(%ebp)
80109ea8:	ff 75 08             	push   0x8(%ebp)
80109eab:	e8 2d 01 00 00       	call   80109fdd <tcp_pkt_create>
80109eb0:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109eb3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109eb6:	83 ec 08             	sub    $0x8,%esp
80109eb9:	50                   	push   %eax
80109eba:	ff 75 e8             	push   -0x18(%ebp)
80109ebd:	e8 ec f0 ff ff       	call   80108fae <i8254_send>
80109ec2:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109ec5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ec8:	83 c0 36             	add    $0x36,%eax
80109ecb:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ece:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109ed1:	50                   	push   %eax
80109ed2:	ff 75 e0             	push   -0x20(%ebp)
80109ed5:	6a 00                	push   $0x0
80109ed7:	6a 00                	push   $0x0
80109ed9:	e8 5a 04 00 00       	call   8010a338 <http_proc>
80109ede:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ee1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ee4:	83 ec 0c             	sub    $0xc,%esp
80109ee7:	50                   	push   %eax
80109ee8:	6a 18                	push   $0x18
80109eea:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109eed:	50                   	push   %eax
80109eee:	ff 75 e8             	push   -0x18(%ebp)
80109ef1:	ff 75 08             	push   0x8(%ebp)
80109ef4:	e8 e4 00 00 00       	call   80109fdd <tcp_pkt_create>
80109ef9:	83 c4 20             	add    $0x20,%esp
80109efc:	eb 62                	jmp    80109f60 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109efe:	83 ec 0c             	sub    $0xc,%esp
80109f01:	6a 00                	push   $0x0
80109f03:	6a 10                	push   $0x10
80109f05:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f08:	50                   	push   %eax
80109f09:	ff 75 e8             	push   -0x18(%ebp)
80109f0c:	ff 75 08             	push   0x8(%ebp)
80109f0f:	e8 c9 00 00 00       	call   80109fdd <tcp_pkt_create>
80109f14:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109f17:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f1a:	83 ec 08             	sub    $0x8,%esp
80109f1d:	50                   	push   %eax
80109f1e:	ff 75 e8             	push   -0x18(%ebp)
80109f21:	e8 88 f0 ff ff       	call   80108fae <i8254_send>
80109f26:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109f29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f2c:	83 c0 36             	add    $0x36,%eax
80109f2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109f32:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109f35:	50                   	push   %eax
80109f36:	ff 75 e4             	push   -0x1c(%ebp)
80109f39:	6a 00                	push   $0x0
80109f3b:	6a 00                	push   $0x0
80109f3d:	e8 f6 03 00 00       	call   8010a338 <http_proc>
80109f42:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109f45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109f48:	83 ec 0c             	sub    $0xc,%esp
80109f4b:	50                   	push   %eax
80109f4c:	6a 18                	push   $0x18
80109f4e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f51:	50                   	push   %eax
80109f52:	ff 75 e8             	push   -0x18(%ebp)
80109f55:	ff 75 08             	push   0x8(%ebp)
80109f58:	e8 80 00 00 00       	call   80109fdd <tcp_pkt_create>
80109f5d:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109f60:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f63:	83 ec 08             	sub    $0x8,%esp
80109f66:	50                   	push   %eax
80109f67:	ff 75 e8             	push   -0x18(%ebp)
80109f6a:	e8 3f f0 ff ff       	call   80108fae <i8254_send>
80109f6f:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f72:	a1 64 78 19 80       	mov    0x80197864,%eax
80109f77:	83 c0 01             	add    $0x1,%eax
80109f7a:	a3 64 78 19 80       	mov    %eax,0x80197864
80109f7f:	eb 4a                	jmp    80109fcb <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f84:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f88:	3c 10                	cmp    $0x10,%al
80109f8a:	75 3f                	jne    80109fcb <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109f8c:	a1 68 78 19 80       	mov    0x80197868,%eax
80109f91:	83 f8 01             	cmp    $0x1,%eax
80109f94:	75 35                	jne    80109fcb <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109f96:	83 ec 0c             	sub    $0xc,%esp
80109f99:	6a 00                	push   $0x0
80109f9b:	6a 01                	push   $0x1
80109f9d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fa0:	50                   	push   %eax
80109fa1:	ff 75 e8             	push   -0x18(%ebp)
80109fa4:	ff 75 08             	push   0x8(%ebp)
80109fa7:	e8 31 00 00 00       	call   80109fdd <tcp_pkt_create>
80109fac:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109faf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fb2:	83 ec 08             	sub    $0x8,%esp
80109fb5:	50                   	push   %eax
80109fb6:	ff 75 e8             	push   -0x18(%ebp)
80109fb9:	e8 f0 ef ff ff       	call   80108fae <i8254_send>
80109fbe:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109fc1:	c7 05 68 78 19 80 00 	movl   $0x0,0x80197868
80109fc8:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109fcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fce:	83 ec 0c             	sub    $0xc,%esp
80109fd1:	50                   	push   %eax
80109fd2:	e8 2f 87 ff ff       	call   80102706 <kfree>
80109fd7:	83 c4 10             	add    $0x10,%esp
}
80109fda:	90                   	nop
80109fdb:	c9                   	leave  
80109fdc:	c3                   	ret    

80109fdd <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109fdd:	55                   	push   %ebp
80109fde:	89 e5                	mov    %esp,%ebp
80109fe0:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80109fe6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80109fec:	83 c0 0e             	add    $0xe,%eax
80109fef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ff5:	0f b6 00             	movzbl (%eax),%eax
80109ff8:	0f b6 c0             	movzbl %al,%eax
80109ffb:	83 e0 0f             	and    $0xf,%eax
80109ffe:	c1 e0 02             	shl    $0x2,%eax
8010a001:	89 c2                	mov    %eax,%edx
8010a003:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a006:	01 d0                	add    %edx,%eax
8010a008:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a00b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a00e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a011:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a014:	83 c0 0e             	add    $0xe,%eax
8010a017:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a01a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a01d:	83 c0 14             	add    $0x14,%eax
8010a020:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a023:	8b 45 18             	mov    0x18(%ebp),%eax
8010a026:	8d 50 36             	lea    0x36(%eax),%edx
8010a029:	8b 45 10             	mov    0x10(%ebp),%eax
8010a02c:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a02e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a031:	8d 50 06             	lea    0x6(%eax),%edx
8010a034:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a037:	83 ec 04             	sub    $0x4,%esp
8010a03a:	6a 06                	push   $0x6
8010a03c:	52                   	push   %edx
8010a03d:	50                   	push   %eax
8010a03e:	e8 40 ad ff ff       	call   80104d83 <memmove>
8010a043:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a046:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a049:	83 c0 06             	add    $0x6,%eax
8010a04c:	83 ec 04             	sub    $0x4,%esp
8010a04f:	6a 06                	push   $0x6
8010a051:	68 90 75 19 80       	push   $0x80197590
8010a056:	50                   	push   %eax
8010a057:	e8 27 ad ff ff       	call   80104d83 <memmove>
8010a05c:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a05f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a062:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a066:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a069:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a06d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a070:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a076:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a07a:	8b 45 18             	mov    0x18(%ebp),%eax
8010a07d:	83 c0 28             	add    $0x28,%eax
8010a080:	0f b7 c0             	movzwl %ax,%eax
8010a083:	83 ec 0c             	sub    $0xc,%esp
8010a086:	50                   	push   %eax
8010a087:	e8 9b f8 ff ff       	call   80109927 <H2N_ushort>
8010a08c:	83 c4 10             	add    $0x10,%esp
8010a08f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a092:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a096:	0f b7 15 60 78 19 80 	movzwl 0x80197860,%edx
8010a09d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0a0:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a0a4:	0f b7 05 60 78 19 80 	movzwl 0x80197860,%eax
8010a0ab:	83 c0 01             	add    $0x1,%eax
8010a0ae:	66 a3 60 78 19 80    	mov    %ax,0x80197860
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a0b4:	83 ec 0c             	sub    $0xc,%esp
8010a0b7:	6a 00                	push   $0x0
8010a0b9:	e8 69 f8 ff ff       	call   80109927 <H2N_ushort>
8010a0be:	83 c4 10             	add    $0x10,%esp
8010a0c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0c4:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a0c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0cb:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a0cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0d2:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a0d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0d9:	83 c0 0c             	add    $0xc,%eax
8010a0dc:	83 ec 04             	sub    $0x4,%esp
8010a0df:	6a 04                	push   $0x4
8010a0e1:	68 04 f5 10 80       	push   $0x8010f504
8010a0e6:	50                   	push   %eax
8010a0e7:	e8 97 ac ff ff       	call   80104d83 <memmove>
8010a0ec:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a0ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0f2:	8d 50 0c             	lea    0xc(%eax),%edx
8010a0f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0f8:	83 c0 10             	add    $0x10,%eax
8010a0fb:	83 ec 04             	sub    $0x4,%esp
8010a0fe:	6a 04                	push   $0x4
8010a100:	52                   	push   %edx
8010a101:	50                   	push   %eax
8010a102:	e8 7c ac ff ff       	call   80104d83 <memmove>
8010a107:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a10a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a10d:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a116:	83 ec 0c             	sub    $0xc,%esp
8010a119:	50                   	push   %eax
8010a11a:	e8 08 f9 ff ff       	call   80109a27 <ipv4_chksum>
8010a11f:	83 c4 10             	add    $0x10,%esp
8010a122:	0f b7 c0             	movzwl %ax,%eax
8010a125:	83 ec 0c             	sub    $0xc,%esp
8010a128:	50                   	push   %eax
8010a129:	e8 f9 f7 ff ff       	call   80109927 <H2N_ushort>
8010a12e:	83 c4 10             	add    $0x10,%esp
8010a131:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a134:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a138:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a13b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a13f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a142:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a145:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a148:	0f b7 10             	movzwl (%eax),%edx
8010a14b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a14e:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a152:	a1 64 78 19 80       	mov    0x80197864,%eax
8010a157:	83 ec 0c             	sub    $0xc,%esp
8010a15a:	50                   	push   %eax
8010a15b:	e8 e9 f7 ff ff       	call   80109949 <H2N_uint>
8010a160:	83 c4 10             	add    $0x10,%esp
8010a163:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a166:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a169:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a16c:	8b 40 04             	mov    0x4(%eax),%eax
8010a16f:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a175:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a178:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a17b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a17e:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a182:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a185:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a189:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a18c:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a190:	8b 45 14             	mov    0x14(%ebp),%eax
8010a193:	89 c2                	mov    %eax,%edx
8010a195:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a198:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a19b:	83 ec 0c             	sub    $0xc,%esp
8010a19e:	68 90 38 00 00       	push   $0x3890
8010a1a3:	e8 7f f7 ff ff       	call   80109927 <H2N_ushort>
8010a1a8:	83 c4 10             	add    $0x10,%esp
8010a1ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1ae:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a1b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1b5:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a1bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1be:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a1c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1c7:	83 ec 0c             	sub    $0xc,%esp
8010a1ca:	50                   	push   %eax
8010a1cb:	e8 1f 00 00 00       	call   8010a1ef <tcp_chksum>
8010a1d0:	83 c4 10             	add    $0x10,%esp
8010a1d3:	83 c0 08             	add    $0x8,%eax
8010a1d6:	0f b7 c0             	movzwl %ax,%eax
8010a1d9:	83 ec 0c             	sub    $0xc,%esp
8010a1dc:	50                   	push   %eax
8010a1dd:	e8 45 f7 ff ff       	call   80109927 <H2N_ushort>
8010a1e2:	83 c4 10             	add    $0x10,%esp
8010a1e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1e8:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a1ec:	90                   	nop
8010a1ed:	c9                   	leave  
8010a1ee:	c3                   	ret    

8010a1ef <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a1ef:	55                   	push   %ebp
8010a1f0:	89 e5                	mov    %esp,%ebp
8010a1f2:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a1f5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a1fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1fe:	83 c0 14             	add    $0x14,%eax
8010a201:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a204:	83 ec 04             	sub    $0x4,%esp
8010a207:	6a 04                	push   $0x4
8010a209:	68 04 f5 10 80       	push   $0x8010f504
8010a20e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a211:	50                   	push   %eax
8010a212:	e8 6c ab ff ff       	call   80104d83 <memmove>
8010a217:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a21a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a21d:	83 c0 0c             	add    $0xc,%eax
8010a220:	83 ec 04             	sub    $0x4,%esp
8010a223:	6a 04                	push   $0x4
8010a225:	50                   	push   %eax
8010a226:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a229:	83 c0 04             	add    $0x4,%eax
8010a22c:	50                   	push   %eax
8010a22d:	e8 51 ab ff ff       	call   80104d83 <memmove>
8010a232:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a235:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a239:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a23d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a240:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a244:	0f b7 c0             	movzwl %ax,%eax
8010a247:	83 ec 0c             	sub    $0xc,%esp
8010a24a:	50                   	push   %eax
8010a24b:	e8 b5 f6 ff ff       	call   80109905 <N2H_ushort>
8010a250:	83 c4 10             	add    $0x10,%esp
8010a253:	83 e8 14             	sub    $0x14,%eax
8010a256:	0f b7 c0             	movzwl %ax,%eax
8010a259:	83 ec 0c             	sub    $0xc,%esp
8010a25c:	50                   	push   %eax
8010a25d:	e8 c5 f6 ff ff       	call   80109927 <H2N_ushort>
8010a262:	83 c4 10             	add    $0x10,%esp
8010a265:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a270:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a273:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a276:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a27d:	eb 33                	jmp    8010a2b2 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a27f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a282:	01 c0                	add    %eax,%eax
8010a284:	89 c2                	mov    %eax,%edx
8010a286:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a289:	01 d0                	add    %edx,%eax
8010a28b:	0f b6 00             	movzbl (%eax),%eax
8010a28e:	0f b6 c0             	movzbl %al,%eax
8010a291:	c1 e0 08             	shl    $0x8,%eax
8010a294:	89 c2                	mov    %eax,%edx
8010a296:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a299:	01 c0                	add    %eax,%eax
8010a29b:	8d 48 01             	lea    0x1(%eax),%ecx
8010a29e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2a1:	01 c8                	add    %ecx,%eax
8010a2a3:	0f b6 00             	movzbl (%eax),%eax
8010a2a6:	0f b6 c0             	movzbl %al,%eax
8010a2a9:	01 d0                	add    %edx,%eax
8010a2ab:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a2ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a2b2:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a2b6:	7e c7                	jle    8010a27f <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a2b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a2be:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a2c5:	eb 33                	jmp    8010a2fa <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a2c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2ca:	01 c0                	add    %eax,%eax
8010a2cc:	89 c2                	mov    %eax,%edx
8010a2ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2d1:	01 d0                	add    %edx,%eax
8010a2d3:	0f b6 00             	movzbl (%eax),%eax
8010a2d6:	0f b6 c0             	movzbl %al,%eax
8010a2d9:	c1 e0 08             	shl    $0x8,%eax
8010a2dc:	89 c2                	mov    %eax,%edx
8010a2de:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2e1:	01 c0                	add    %eax,%eax
8010a2e3:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2e9:	01 c8                	add    %ecx,%eax
8010a2eb:	0f b6 00             	movzbl (%eax),%eax
8010a2ee:	0f b6 c0             	movzbl %al,%eax
8010a2f1:	01 d0                	add    %edx,%eax
8010a2f3:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a2f6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a2fa:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a2fe:	0f b7 c0             	movzwl %ax,%eax
8010a301:	83 ec 0c             	sub    $0xc,%esp
8010a304:	50                   	push   %eax
8010a305:	e8 fb f5 ff ff       	call   80109905 <N2H_ushort>
8010a30a:	83 c4 10             	add    $0x10,%esp
8010a30d:	66 d1 e8             	shr    %ax
8010a310:	0f b7 c0             	movzwl %ax,%eax
8010a313:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a316:	7c af                	jl     8010a2c7 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a31b:	c1 e8 10             	shr    $0x10,%eax
8010a31e:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a321:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a324:	f7 d0                	not    %eax
}
8010a326:	c9                   	leave  
8010a327:	c3                   	ret    

8010a328 <tcp_fin>:

void tcp_fin(){
8010a328:	55                   	push   %ebp
8010a329:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a32b:	c7 05 68 78 19 80 01 	movl   $0x1,0x80197868
8010a332:	00 00 00 
}
8010a335:	90                   	nop
8010a336:	5d                   	pop    %ebp
8010a337:	c3                   	ret    

8010a338 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a338:	55                   	push   %ebp
8010a339:	89 e5                	mov    %esp,%ebp
8010a33b:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a33e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a341:	83 ec 04             	sub    $0x4,%esp
8010a344:	6a 00                	push   $0x0
8010a346:	68 ab c4 10 80       	push   $0x8010c4ab
8010a34b:	50                   	push   %eax
8010a34c:	e8 65 00 00 00       	call   8010a3b6 <http_strcpy>
8010a351:	83 c4 10             	add    $0x10,%esp
8010a354:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a357:	8b 45 10             	mov    0x10(%ebp),%eax
8010a35a:	83 ec 04             	sub    $0x4,%esp
8010a35d:	ff 75 f4             	push   -0xc(%ebp)
8010a360:	68 be c4 10 80       	push   $0x8010c4be
8010a365:	50                   	push   %eax
8010a366:	e8 4b 00 00 00       	call   8010a3b6 <http_strcpy>
8010a36b:	83 c4 10             	add    $0x10,%esp
8010a36e:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a371:	8b 45 10             	mov    0x10(%ebp),%eax
8010a374:	83 ec 04             	sub    $0x4,%esp
8010a377:	ff 75 f4             	push   -0xc(%ebp)
8010a37a:	68 d9 c4 10 80       	push   $0x8010c4d9
8010a37f:	50                   	push   %eax
8010a380:	e8 31 00 00 00       	call   8010a3b6 <http_strcpy>
8010a385:	83 c4 10             	add    $0x10,%esp
8010a388:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a38b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a38e:	83 e0 01             	and    $0x1,%eax
8010a391:	85 c0                	test   %eax,%eax
8010a393:	74 11                	je     8010a3a6 <http_proc+0x6e>
    char *payload = (char *)send;
8010a395:	8b 45 10             	mov    0x10(%ebp),%eax
8010a398:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a39b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a39e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3a1:	01 d0                	add    %edx,%eax
8010a3a3:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a3a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a3a9:	8b 45 14             	mov    0x14(%ebp),%eax
8010a3ac:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a3ae:	e8 75 ff ff ff       	call   8010a328 <tcp_fin>
}
8010a3b3:	90                   	nop
8010a3b4:	c9                   	leave  
8010a3b5:	c3                   	ret    

8010a3b6 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a3b6:	55                   	push   %ebp
8010a3b7:	89 e5                	mov    %esp,%ebp
8010a3b9:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a3bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a3c3:	eb 20                	jmp    8010a3e5 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a3c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3c8:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3cb:	01 d0                	add    %edx,%eax
8010a3cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a3d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3d3:	01 ca                	add    %ecx,%edx
8010a3d5:	89 d1                	mov    %edx,%ecx
8010a3d7:	8b 55 08             	mov    0x8(%ebp),%edx
8010a3da:	01 ca                	add    %ecx,%edx
8010a3dc:	0f b6 00             	movzbl (%eax),%eax
8010a3df:	88 02                	mov    %al,(%edx)
    i++;
8010a3e1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a3e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3e8:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3eb:	01 d0                	add    %edx,%eax
8010a3ed:	0f b6 00             	movzbl (%eax),%eax
8010a3f0:	84 c0                	test   %al,%al
8010a3f2:	75 d1                	jne    8010a3c5 <http_strcpy+0xf>
  }
  return i;
8010a3f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a3f7:	c9                   	leave  
8010a3f8:	c3                   	ret    

8010a3f9 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a3f9:	55                   	push   %ebp
8010a3fa:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a3fc:	c7 05 70 78 19 80 c2 	movl   $0x8010f5c2,0x80197870
8010a403:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a406:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a40b:	c1 e8 09             	shr    $0x9,%eax
8010a40e:	a3 6c 78 19 80       	mov    %eax,0x8019786c
}
8010a413:	90                   	nop
8010a414:	5d                   	pop    %ebp
8010a415:	c3                   	ret    

8010a416 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a416:	55                   	push   %ebp
8010a417:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a419:	90                   	nop
8010a41a:	5d                   	pop    %ebp
8010a41b:	c3                   	ret    

8010a41c <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a41c:	55                   	push   %ebp
8010a41d:	89 e5                	mov    %esp,%ebp
8010a41f:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a422:	8b 45 08             	mov    0x8(%ebp),%eax
8010a425:	83 c0 0c             	add    $0xc,%eax
8010a428:	83 ec 0c             	sub    $0xc,%esp
8010a42b:	50                   	push   %eax
8010a42c:	e8 8c a5 ff ff       	call   801049bd <holdingsleep>
8010a431:	83 c4 10             	add    $0x10,%esp
8010a434:	85 c0                	test   %eax,%eax
8010a436:	75 0d                	jne    8010a445 <iderw+0x29>
    panic("iderw: buf not locked");
8010a438:	83 ec 0c             	sub    $0xc,%esp
8010a43b:	68 ea c4 10 80       	push   $0x8010c4ea
8010a440:	e8 64 61 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a445:	8b 45 08             	mov    0x8(%ebp),%eax
8010a448:	8b 00                	mov    (%eax),%eax
8010a44a:	83 e0 06             	and    $0x6,%eax
8010a44d:	83 f8 02             	cmp    $0x2,%eax
8010a450:	75 0d                	jne    8010a45f <iderw+0x43>
    panic("iderw: nothing to do");
8010a452:	83 ec 0c             	sub    $0xc,%esp
8010a455:	68 00 c5 10 80       	push   $0x8010c500
8010a45a:	e8 4a 61 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a45f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a462:	8b 40 04             	mov    0x4(%eax),%eax
8010a465:	83 f8 01             	cmp    $0x1,%eax
8010a468:	74 0d                	je     8010a477 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a46a:	83 ec 0c             	sub    $0xc,%esp
8010a46d:	68 15 c5 10 80       	push   $0x8010c515
8010a472:	e8 32 61 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a477:	8b 45 08             	mov    0x8(%ebp),%eax
8010a47a:	8b 40 08             	mov    0x8(%eax),%eax
8010a47d:	8b 15 6c 78 19 80    	mov    0x8019786c,%edx
8010a483:	39 d0                	cmp    %edx,%eax
8010a485:	72 0d                	jb     8010a494 <iderw+0x78>
    panic("iderw: block out of range");
8010a487:	83 ec 0c             	sub    $0xc,%esp
8010a48a:	68 33 c5 10 80       	push   $0x8010c533
8010a48f:	e8 15 61 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a494:	8b 15 70 78 19 80    	mov    0x80197870,%edx
8010a49a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a49d:	8b 40 08             	mov    0x8(%eax),%eax
8010a4a0:	c1 e0 09             	shl    $0x9,%eax
8010a4a3:	01 d0                	add    %edx,%eax
8010a4a5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a4a8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ab:	8b 00                	mov    (%eax),%eax
8010a4ad:	83 e0 04             	and    $0x4,%eax
8010a4b0:	85 c0                	test   %eax,%eax
8010a4b2:	74 2b                	je     8010a4df <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a4b4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4b7:	8b 00                	mov    (%eax),%eax
8010a4b9:	83 e0 fb             	and    $0xfffffffb,%eax
8010a4bc:	89 c2                	mov    %eax,%edx
8010a4be:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4c1:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a4c3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4c6:	83 c0 5c             	add    $0x5c,%eax
8010a4c9:	83 ec 04             	sub    $0x4,%esp
8010a4cc:	68 00 02 00 00       	push   $0x200
8010a4d1:	50                   	push   %eax
8010a4d2:	ff 75 f4             	push   -0xc(%ebp)
8010a4d5:	e8 a9 a8 ff ff       	call   80104d83 <memmove>
8010a4da:	83 c4 10             	add    $0x10,%esp
8010a4dd:	eb 1a                	jmp    8010a4f9 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a4df:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4e2:	83 c0 5c             	add    $0x5c,%eax
8010a4e5:	83 ec 04             	sub    $0x4,%esp
8010a4e8:	68 00 02 00 00       	push   $0x200
8010a4ed:	ff 75 f4             	push   -0xc(%ebp)
8010a4f0:	50                   	push   %eax
8010a4f1:	e8 8d a8 ff ff       	call   80104d83 <memmove>
8010a4f6:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a4f9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4fc:	8b 00                	mov    (%eax),%eax
8010a4fe:	83 c8 02             	or     $0x2,%eax
8010a501:	89 c2                	mov    %eax,%edx
8010a503:	8b 45 08             	mov    0x8(%ebp),%eax
8010a506:	89 10                	mov    %edx,(%eax)
}
8010a508:	90                   	nop
8010a509:	c9                   	leave  
8010a50a:	c3                   	ret    
