
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
8010005a:	bc 80 8c 19 80       	mov    $0x80198c80,%esp
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
8010006f:	68 e0 a3 10 80       	push   $0x8010a3e0
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 68 48 00 00       	call   801048e6 <initlock>
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
801000bd:	68 e7 a3 10 80       	push   $0x8010a3e7
801000c2:	50                   	push   %eax
801000c3:	e8 c1 46 00 00       	call   80104789 <initsleeplock>
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
80100101:	e8 02 48 00 00       	call   80104908 <acquire>
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
80100140:	e8 31 48 00 00       	call   80104976 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 6e 46 00 00       	call   801047c5 <acquiresleep>
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
801001c1:	e8 b0 47 00 00       	call   80104976 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 ed 45 00 00       	call   801047c5 <acquiresleep>
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
801001f5:	68 ee a3 10 80       	push   $0x8010a3ee
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
8010022d:	e8 af a0 00 00       	call   8010a2e1 <iderw>
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
8010024a:	e8 28 46 00 00       	call   80104877 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 ff a3 10 80       	push   $0x8010a3ff
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
80100278:	e8 64 a0 00 00       	call   8010a2e1 <iderw>
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
80100293:	e8 df 45 00 00       	call   80104877 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 06 a4 10 80       	push   $0x8010a406
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 6e 45 00 00       	call   80104829 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 3d 46 00 00       	call   80104908 <acquire>
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
80100336:	e8 3b 46 00 00       	call   80104976 <release>
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
80100410:	e8 f3 44 00 00       	call   80104908 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 0d a4 10 80       	push   $0x8010a40d
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
80100510:	c7 45 ec 16 a4 10 80 	movl   $0x8010a416,-0x14(%ebp)
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
8010059e:	e8 d3 43 00 00       	call   80104976 <release>
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
801005c7:	68 1d a4 10 80       	push   $0x8010a41d
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
801005e6:	68 31 a4 10 80       	push   $0x8010a431
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 c5 43 00 00       	call   801049c8 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 33 a4 10 80       	push   $0x8010a433
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
801006a0:	e8 93 7b 00 00       	call   80108238 <graphic_scroll_up>
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
801006f3:	e8 40 7b 00 00       	call   80108238 <graphic_scroll_up>
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
80100757:	e8 47 7b 00 00       	call   801082a3 <font_render>
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
80100793:	e8 17 5f 00 00       	call   801066af <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 0a 5f 00 00       	call   801066af <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 fd 5e 00 00       	call   801066af <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 ed 5e 00 00       	call   801066af <uartputc>
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
801007eb:	e8 18 41 00 00       	call   80104908 <acquire>
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
8010093f:	e8 8a 3c 00 00       	call   801045ce <wakeup>
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
80100962:	e8 0f 40 00 00       	call   80104976 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 17 3d 00 00       	call   8010468c <procdump>
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
8010099a:	e8 69 3f 00 00       	call   80104908 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 84 30 00 00       	call   80103a30 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 b6 3f 00 00       	call   80104976 <release>
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
801009e8:	e8 f7 3a 00 00       	call   801044e4 <sleep>
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
80100a66:	e8 0b 3f 00 00       	call   80104976 <release>
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
80100aa2:	e8 61 3e 00 00       	call   80104908 <acquire>
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
80100ae4:	e8 8d 3e 00 00       	call   80104976 <release>
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
80100b12:	68 37 a4 10 80       	push   $0x8010a437
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 c5 3d 00 00       	call   801048e6 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 3f a4 10 80 	movl   $0x8010a43f,-0xc(%ebp)
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
80100b89:	e8 a2 2e 00 00       	call   80103a30 <myproc>
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
80100bb5:	68 55 a4 10 80       	push   $0x8010a455
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
80100c11:	e8 95 6a 00 00       	call   801076ab <setupkvm>
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
80100cb7:	e8 e8 6d 00 00       	call   80107aa4 <allocuvm>
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
80100cfd:	e8 d5 6c 00 00       	call   801079d7 <loaduvm>
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
80100d6c:	e8 33 6d 00 00       	call   80107aa4 <allocuvm>
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
80100d90:	e8 71 6f 00 00       	call   80107d06 <clearpteu>
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
80100dc9:	e8 fe 3f 00 00       	call   80104dcc <strlen>
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
80100df6:	e8 d1 3f 00 00       	call   80104dcc <strlen>
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
80100e1c:	e8 84 70 00 00       	call   80107ea5 <copyout>
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
80100eb8:	e8 e8 6f 00 00       	call   80107ea5 <copyout>
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
80100f06:	e8 76 3e 00 00       	call   80104d81 <safestrcpy>
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
80100f49:	e8 7a 68 00 00       	call   801077c8 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 11 6d 00 00       	call   80107c6d <freevm>
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
80100f97:	e8 d1 6c 00 00       	call   80107c6d <freevm>
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
80100fc8:	68 61 a4 10 80       	push   $0x8010a461
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 0f 39 00 00       	call   801048e6 <initlock>
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
80100feb:	e8 18 39 00 00       	call   80104908 <acquire>
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
80101018:	e8 59 39 00 00       	call   80104976 <release>
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
8010103b:	e8 36 39 00 00       	call   80104976 <release>
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
80101058:	e8 ab 38 00 00       	call   80104908 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 68 a4 10 80       	push   $0x8010a468
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
8010108e:	e8 e3 38 00 00       	call   80104976 <release>
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
801010a9:	e8 5a 38 00 00       	call   80104908 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 70 a4 10 80       	push   $0x8010a470
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
801010e9:	e8 88 38 00 00       	call   80104976 <release>
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
80101137:	e8 3a 38 00 00       	call   80104976 <release>
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
80101286:	68 7a a4 10 80       	push   $0x8010a47a
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
80101389:	68 83 a4 10 80       	push   $0x8010a483
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
801013bf:	68 93 a4 10 80       	push   $0x8010a493
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
801013f7:	e8 41 38 00 00       	call   80104c3d <memmove>
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
8010143d:	e8 3c 37 00 00       	call   80104b7e <memset>
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
8010159c:	68 a0 a4 10 80       	push   $0x8010a4a0
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
80101627:	68 b6 a4 10 80       	push   $0x8010a4b6
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
8010168b:	68 c9 a4 10 80       	push   $0x8010a4c9
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 4c 32 00 00       	call   801048e6 <initlock>
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
801016c1:	68 d0 a4 10 80       	push   $0x8010a4d0
801016c6:	50                   	push   %eax
801016c7:	e8 bd 30 00 00       	call   80104789 <initsleeplock>
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
80101720:	68 d8 a4 10 80       	push   $0x8010a4d8
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
80101799:	e8 e0 33 00 00       	call   80104b7e <memset>
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
80101801:	68 2b a5 10 80       	push   $0x8010a52b
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
801018a7:	e8 91 33 00 00       	call   80104c3d <memmove>
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
801018dc:	e8 27 30 00 00       	call   80104908 <acquire>
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
8010192a:	e8 47 30 00 00       	call   80104976 <release>
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
80101966:	68 3d a5 10 80       	push   $0x8010a53d
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
801019a3:	e8 ce 2f 00 00       	call   80104976 <release>
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
801019be:	e8 45 2f 00 00       	call   80104908 <acquire>
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
801019dd:	e8 94 2f 00 00       	call   80104976 <release>
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
80101a03:	68 4d a5 10 80       	push   $0x8010a54d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 a9 2d 00 00       	call   801047c5 <acquiresleep>
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
80101ac1:	e8 77 31 00 00       	call   80104c3d <memmove>
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
80101af0:	68 53 a5 10 80       	push   $0x8010a553
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
80101b13:	e8 5f 2d 00 00       	call   80104877 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 62 a5 10 80       	push   $0x8010a562
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 e4 2c 00 00       	call   80104829 <releasesleep>
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
80101b5b:	e8 65 2c 00 00       	call   801047c5 <acquiresleep>
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
80101b81:	e8 82 2d 00 00       	call   80104908 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 d7 2d 00 00       	call   80104976 <release>
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
80101be1:	e8 43 2c 00 00       	call   80104829 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 12 2d 00 00       	call   80104908 <acquire>
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
80101c10:	e8 61 2d 00 00       	call   80104976 <release>
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
80101d54:	68 6a a5 10 80       	push   $0x8010a56a
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
80101ff2:	e8 46 2c 00 00       	call   80104c3d <memmove>
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
80102142:	e8 f6 2a 00 00       	call   80104c3d <memmove>
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
801021c2:	e8 0c 2b 00 00       	call   80104cd3 <strncmp>
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
801021e2:	68 7d a5 10 80       	push   $0x8010a57d
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
80102211:	68 8f a5 10 80       	push   $0x8010a58f
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
801022e6:	68 9e a5 10 80       	push   $0x8010a59e
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
80102321:	e8 03 2a 00 00       	call   80104d29 <strncpy>
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
8010234d:	68 ab a5 10 80       	push   $0x8010a5ab
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
801023bf:	e8 79 28 00 00       	call   80104c3d <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 62 28 00 00       	call   80104c3d <memmove>
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
80102425:	e8 06 16 00 00       	call   80103a30 <myproc>
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
801025bb:	0f b6 05 54 79 19 80 	movzbl 0x80197954,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 b4 a5 10 80       	push   $0x8010a5b4
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
80102674:	68 e6 a5 10 80       	push   $0x8010a5e6
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 63 22 00 00       	call   801048e6 <initlock>
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
80102733:	68 eb a5 10 80       	push   $0x8010a5eb
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 2f 24 00 00       	call   80104b7e <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 a0 21 00 00       	call   80104908 <acquire>
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
80102795:	e8 dc 21 00 00       	call   80104976 <release>
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
801027b7:	e8 4c 21 00 00       	call   80104908 <acquire>
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
801027e8:	e8 89 21 00 00       	call   80104976 <release>
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
80102d12:	e8 ce 1e 00 00       	call   80104be5 <memcmp>
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
80102e26:	68 f1 a5 10 80       	push   $0x8010a5f1
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 b1 1a 00 00       	call   801048e6 <initlock>
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
80102edb:	e8 5d 1d 00 00       	call   80104c3d <memmove>
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
8010304a:	e8 b9 18 00 00       	call   80104908 <acquire>
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
80103068:	e8 77 14 00 00       	call   801044e4 <sleep>
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
8010309d:	e8 42 14 00 00       	call   801044e4 <sleep>
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
801030bc:	e8 b5 18 00 00       	call   80104976 <release>
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
801030dd:	e8 26 18 00 00       	call   80104908 <acquire>
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
801030fe:	68 f5 a5 10 80       	push   $0x8010a5f5
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
8010312c:	e8 9d 14 00 00       	call   801045ce <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 35 18 00 00       	call   80104976 <release>
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
80103157:	e8 ac 17 00 00       	call   80104908 <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 58 14 00 00       	call   801045ce <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 f0 17 00 00       	call   80104976 <release>
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
801031fd:	e8 3b 1a 00 00       	call   80104c3d <memmove>
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
8010329a:	68 04 a6 10 80       	push   $0x8010a604
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 1a a6 10 80       	push   $0x8010a61a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 41 16 00 00       	call   80104908 <acquire>
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
80103340:	e8 31 16 00 00       	call   80104976 <release>
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
80103376:	e8 02 4e 00 00       	call   8010817d <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 02 44 00 00       	call   80107797 <kvmalloc>
  mpinit_uefi();
80103395:	e8 a9 4b 00 00       	call   80107f43 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 8b 3e 00 00       	call   8010722f <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 10 32 00 00       	call   801065c8 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 2c 2d 00 00       	call   801060ee <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 ed 6e 00 00       	call   8010a2be <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 e6 4f 00 00       	call   801083d6 <pci_init>
  arp_scan();
801033f0:	e8 1d 5d 00 00       	call   80109112 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 9e 07 00 00       	call   80103b98 <userinit>

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
80103405:	e8 a5 43 00 00       	call   801077af <switchkvm>
  seginit();
8010340a:	e8 20 3e 00 00       	call   8010722f <seginit>
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
80103420:	e8 78 05 00 00       	call   8010399d <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 71 05 00 00       	call   8010399d <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 35 a6 10 80       	push   $0x8010a635
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 21 2e 00 00       	call   80106264 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 70 05 00 00       	call   801039b8 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 c9 0c 00 00       	call   80104129 <scheduler>

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
80103476:	68 18 f5 10 80       	push   $0x8010f518
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 ba 17 00 00       	call   80104c3d <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 76 19 80 	movl   $0x80197680,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 24 05 00 00       	call   801039b8 <mycpu>
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
80103508:	a1 50 79 19 80       	mov    0x80197950,%eax
8010350d:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103513:	05 80 76 19 80       	add    $0x80197680,%eax
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
80103607:	68 49 a6 10 80       	push   $0x8010a649
8010360c:	50                   	push   %eax
8010360d:	e8 d4 12 00 00       	call   801048e6 <initlock>
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
801036cc:	e8 37 12 00 00       	call   80104908 <acquire>
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
801036f3:	e8 d6 0e 00 00       	call   801045ce <wakeup>
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
80103716:	e8 b3 0e 00 00       	call   801045ce <wakeup>
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
8010373f:	e8 32 12 00 00       	call   80104976 <release>
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
8010375e:	e8 13 12 00 00       	call   80104976 <release>
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
80103778:	e8 8b 11 00 00       	call   80104908 <acquire>
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
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 c5 11 00 00       	call   80104976 <release>
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
801037ca:	e8 ff 0d 00 00       	call   801045ce <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 fc 0c 00 00       	call   801044e4 <sleep>
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
8010384d:	e8 7c 0d 00 00       	call   801045ce <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 15 11 00 00       	call   80104976 <release>
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
80103879:	e8 8a 10 00 00       	call   80104908 <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 db 10 00 00       	call   80104976 <release>
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
801038b9:	e8 26 0c 00 00       	call   801044e4 <sleep>
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
8010394c:	e8 7d 0c 00 00       	call   801045ce <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 16 10 00 00       	call   80104976 <release>
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

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 50 a6 10 80       	push   $0x8010a650
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 4f 0f 00 00       	call   801048e6 <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave  
8010399c:	c3                   	ret    

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 76 19 80       	sub    $0x80197680,%eax
801039ad:	c1 f8 02             	sar    $0x2,%eax
801039b0:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
801039b6:	c9                   	leave  
801039b7:	c3                   	ret    

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 58 a6 10 80       	push   $0x8010a658
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1c f1 ff ff       	call   80102afa <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039f3:	05 80 76 19 80       	add    $0x80197680,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a0c:	05 80 76 19 80       	add    $0x80197680,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 50 79 19 80       	mov    0x80197950,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 7e a6 10 80       	push   $0x8010a67e
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave  
80103a2f:	c3                   	ret    

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 38 10 00 00       	call   80104a73 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 6c 10 00 00       	call   80104ac0 <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave  
80103a58:	c3                   	ret    

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 9c 0e 00 00       	call   80104908 <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 11                	jmp    80103a89 <allocproc+0x30>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 2a                	je     80103aac <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103a89:	81 7d f4 34 6e 19 80 	cmpl   $0x80196e34,-0xc(%ebp)
80103a90:	72 e6                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a92:	83 ec 0c             	sub    $0xc,%esp
80103a95:	68 00 42 19 80       	push   $0x80194200
80103a9a:	e8 d7 0e 00 00       	call   80104976 <release>
80103a9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa2:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa7:	e9 ea 00 00 00       	jmp    80103b96 <allocproc+0x13d>
      goto found;
80103aac:	90                   	nop

found:
  p->state = EMBRYO;
80103aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab7:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103abc:	8d 50 01             	lea    0x1(%eax),%edx
80103abf:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac8:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103acb:	83 ec 0c             	sub    $0xc,%esp
80103ace:	68 00 42 19 80       	push   $0x80194200
80103ad3:	e8 9e 0e 00 00       	call   80104976 <release>
80103ad8:	83 c4 10             	add    $0x10,%esp

  p->priority = 3;
80103adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ade:	c7 40 7c 03 00 00 00 	movl   $0x3,0x7c(%eax)
  memset(p->ticks, 0, sizeof(p->ticks));
80103ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae8:	83 e8 80             	sub    $0xffffff80,%eax
80103aeb:	83 ec 04             	sub    $0x4,%esp
80103aee:	6a 10                	push   $0x10
80103af0:	6a 00                	push   $0x0
80103af2:	50                   	push   %eax
80103af3:	e8 86 10 00 00       	call   80104b7e <memset>
80103af8:	83 c4 10             	add    $0x10,%esp
  memset(p->wait_ticks, 0, sizeof(p->wait_ticks));
80103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afe:	05 90 00 00 00       	add    $0x90,%eax
80103b03:	83 ec 04             	sub    $0x4,%esp
80103b06:	6a 10                	push   $0x10
80103b08:	6a 00                	push   $0x0
80103b0a:	50                   	push   %eax
80103b0b:	e8 6e 10 00 00       	call   80104b7e <memset>
80103b10:	83 c4 10             	add    $0x10,%esp
  
  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103b13:	e8 88 ec ff ff       	call   801027a0 <kalloc>
80103b18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b1b:	89 42 08             	mov    %eax,0x8(%edx)
80103b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b21:	8b 40 08             	mov    0x8(%eax),%eax
80103b24:	85 c0                	test   %eax,%eax
80103b26:	75 11                	jne    80103b39 <allocproc+0xe0>
    p->state = UNUSED;
80103b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b32:	b8 00 00 00 00       	mov    $0x0,%eax
80103b37:	eb 5d                	jmp    80103b96 <allocproc+0x13d>
  }
  sp = p->kstack + KSTACKSIZE;
80103b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3c:	8b 40 08             	mov    0x8(%eax),%eax
80103b3f:	05 00 10 00 00       	add    $0x1000,%eax
80103b44:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b47:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b51:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b54:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b58:	ba a8 60 10 80       	mov    $0x801060a8,%edx
80103b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b60:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b62:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b69:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b6c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b72:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b75:	83 ec 04             	sub    $0x4,%esp
80103b78:	6a 14                	push   $0x14
80103b7a:	6a 00                	push   $0x0
80103b7c:	50                   	push   %eax
80103b7d:	e8 fc 0f 00 00       	call   80104b7e <memset>
80103b82:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b88:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b8b:	ba 9e 44 10 80       	mov    $0x8010449e,%edx
80103b90:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b96:	c9                   	leave  
80103b97:	c3                   	ret    

80103b98 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b98:	55                   	push   %ebp
80103b99:	89 e5                	mov    %esp,%ebp
80103b9b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b9e:	e8 b6 fe ff ff       	call   80103a59 <allocproc>
80103ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba9:	a3 34 6e 19 80       	mov    %eax,0x80196e34
  if((p->pgdir = setupkvm()) == 0){
80103bae:	e8 f8 3a 00 00       	call   801076ab <setupkvm>
80103bb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bb6:	89 42 04             	mov    %eax,0x4(%edx)
80103bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbc:	8b 40 04             	mov    0x4(%eax),%eax
80103bbf:	85 c0                	test   %eax,%eax
80103bc1:	75 0d                	jne    80103bd0 <userinit+0x38>
    panic("userinit: out of memory?");
80103bc3:	83 ec 0c             	sub    $0xc,%esp
80103bc6:	68 8e a6 10 80       	push   $0x8010a68e
80103bcb:	e8 d9 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103bd0:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd8:	8b 40 04             	mov    0x4(%eax),%eax
80103bdb:	83 ec 04             	sub    $0x4,%esp
80103bde:	52                   	push   %edx
80103bdf:	68 ec f4 10 80       	push   $0x8010f4ec
80103be4:	50                   	push   %eax
80103be5:	e8 7d 3d 00 00       	call   80107967 <inituvm>
80103bea:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf9:	8b 40 18             	mov    0x18(%eax),%eax
80103bfc:	83 ec 04             	sub    $0x4,%esp
80103bff:	6a 4c                	push   $0x4c
80103c01:	6a 00                	push   $0x0
80103c03:	50                   	push   %eax
80103c04:	e8 75 0f 00 00       	call   80104b7e <memset>
80103c09:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0f:	8b 40 18             	mov    0x18(%eax),%eax
80103c12:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1b:	8b 40 18             	mov    0x18(%eax),%eax
80103c1e:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c27:	8b 50 18             	mov    0x18(%eax),%edx
80103c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2d:	8b 40 18             	mov    0x18(%eax),%eax
80103c30:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c34:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	8b 50 18             	mov    0x18(%eax),%edx
80103c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c41:	8b 40 18             	mov    0x18(%eax),%eax
80103c44:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c48:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4f:	8b 40 18             	mov    0x18(%eax),%eax
80103c52:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5c:	8b 40 18             	mov    0x18(%eax),%eax
80103c5f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c69:	8b 40 18             	mov    0x18(%eax),%eax
80103c6c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c76:	83 c0 6c             	add    $0x6c,%eax
80103c79:	83 ec 04             	sub    $0x4,%esp
80103c7c:	6a 10                	push   $0x10
80103c7e:	68 a7 a6 10 80       	push   $0x8010a6a7
80103c83:	50                   	push   %eax
80103c84:	e8 f8 10 00 00       	call   80104d81 <safestrcpy>
80103c89:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	68 b0 a6 10 80       	push   $0x8010a6b0
80103c94:	e8 84 e8 ff ff       	call   8010251d <namei>
80103c99:	83 c4 10             	add    $0x10,%esp
80103c9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c9f:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103ca2:	83 ec 0c             	sub    $0xc,%esp
80103ca5:	68 00 42 19 80       	push   $0x80194200
80103caa:	e8 59 0c 00 00       	call   80104908 <acquire>
80103caf:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103cbc:	83 ec 0c             	sub    $0xc,%esp
80103cbf:	68 00 42 19 80       	push   $0x80194200
80103cc4:	e8 ad 0c 00 00       	call   80104976 <release>
80103cc9:	83 c4 10             	add    $0x10,%esp
}
80103ccc:	90                   	nop
80103ccd:	c9                   	leave  
80103cce:	c3                   	ret    

80103ccf <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103ccf:	55                   	push   %ebp
80103cd0:	89 e5                	mov    %esp,%ebp
80103cd2:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103cd5:	e8 56 fd ff ff       	call   80103a30 <myproc>
80103cda:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce0:	8b 00                	mov    (%eax),%eax
80103ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ce5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce9:	7e 2e                	jle    80103d19 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ceb:	8b 55 08             	mov    0x8(%ebp),%edx
80103cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf1:	01 c2                	add    %eax,%edx
80103cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf6:	8b 40 04             	mov    0x4(%eax),%eax
80103cf9:	83 ec 04             	sub    $0x4,%esp
80103cfc:	52                   	push   %edx
80103cfd:	ff 75 f4             	push   -0xc(%ebp)
80103d00:	50                   	push   %eax
80103d01:	e8 9e 3d 00 00       	call   80107aa4 <allocuvm>
80103d06:	83 c4 10             	add    $0x10,%esp
80103d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d10:	75 3b                	jne    80103d4d <growproc+0x7e>
      return -1;
80103d12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d17:	eb 4f                	jmp    80103d68 <growproc+0x99>
  } else if(n < 0){
80103d19:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d1d:	79 2e                	jns    80103d4d <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d1f:	8b 55 08             	mov    0x8(%ebp),%edx
80103d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d25:	01 c2                	add    %eax,%edx
80103d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d2a:	8b 40 04             	mov    0x4(%eax),%eax
80103d2d:	83 ec 04             	sub    $0x4,%esp
80103d30:	52                   	push   %edx
80103d31:	ff 75 f4             	push   -0xc(%ebp)
80103d34:	50                   	push   %eax
80103d35:	e8 6f 3e 00 00       	call   80107ba9 <deallocuvm>
80103d3a:	83 c4 10             	add    $0x10,%esp
80103d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d44:	75 07                	jne    80103d4d <growproc+0x7e>
      return -1;
80103d46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d4b:	eb 1b                	jmp    80103d68 <growproc+0x99>
  }
  curproc->sz = sz;
80103d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d53:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d55:	83 ec 0c             	sub    $0xc,%esp
80103d58:	ff 75 f0             	push   -0x10(%ebp)
80103d5b:	e8 68 3a 00 00       	call   801077c8 <switchuvm>
80103d60:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d68:	c9                   	leave  
80103d69:	c3                   	ret    

80103d6a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d6a:	55                   	push   %ebp
80103d6b:	89 e5                	mov    %esp,%ebp
80103d6d:	57                   	push   %edi
80103d6e:	56                   	push   %esi
80103d6f:	53                   	push   %ebx
80103d70:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d73:	e8 b8 fc ff ff       	call   80103a30 <myproc>
80103d78:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d7b:	e8 d9 fc ff ff       	call   80103a59 <allocproc>
80103d80:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d83:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d87:	75 0a                	jne    80103d93 <fork+0x29>
    return -1;
80103d89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d8e:	e9 48 01 00 00       	jmp    80103edb <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d96:	8b 10                	mov    (%eax),%edx
80103d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d9b:	8b 40 04             	mov    0x4(%eax),%eax
80103d9e:	83 ec 08             	sub    $0x8,%esp
80103da1:	52                   	push   %edx
80103da2:	50                   	push   %eax
80103da3:	e8 9f 3f 00 00       	call   80107d47 <copyuvm>
80103da8:	83 c4 10             	add    $0x10,%esp
80103dab:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103dae:	89 42 04             	mov    %eax,0x4(%edx)
80103db1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db4:	8b 40 04             	mov    0x4(%eax),%eax
80103db7:	85 c0                	test   %eax,%eax
80103db9:	75 30                	jne    80103deb <fork+0x81>
    kfree(np->kstack);
80103dbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbe:	8b 40 08             	mov    0x8(%eax),%eax
80103dc1:	83 ec 0c             	sub    $0xc,%esp
80103dc4:	50                   	push   %eax
80103dc5:	e8 3c e9 ff ff       	call   80102706 <kfree>
80103dca:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103dcd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103dd7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dda:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103de1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103de6:	e9 f0 00 00 00       	jmp    80103edb <fork+0x171>
  }
  np->sz = curproc->sz;
80103deb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dee:	8b 10                	mov    (%eax),%edx
80103df0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df3:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103df5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dfb:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e01:	8b 48 18             	mov    0x18(%eax),%ecx
80103e04:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e07:	8b 40 18             	mov    0x18(%eax),%eax
80103e0a:	89 c2                	mov    %eax,%edx
80103e0c:	89 cb                	mov    %ecx,%ebx
80103e0e:	b8 13 00 00 00       	mov    $0x13,%eax
80103e13:	89 d7                	mov    %edx,%edi
80103e15:	89 de                	mov    %ebx,%esi
80103e17:	89 c1                	mov    %eax,%ecx
80103e19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e1e:	8b 40 18             	mov    0x18(%eax),%eax
80103e21:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103e28:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e2f:	eb 3b                	jmp    80103e6c <fork+0x102>
    if(curproc->ofile[i])
80103e31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e37:	83 c2 08             	add    $0x8,%edx
80103e3a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e3e:	85 c0                	test   %eax,%eax
80103e40:	74 26                	je     80103e68 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e42:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e45:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e48:	83 c2 08             	add    $0x8,%edx
80103e4b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e4f:	83 ec 0c             	sub    $0xc,%esp
80103e52:	50                   	push   %eax
80103e53:	e8 f2 d1 ff ff       	call   8010104a <filedup>
80103e58:	83 c4 10             	add    $0x10,%esp
80103e5b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e5e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e61:	83 c1 08             	add    $0x8,%ecx
80103e64:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e68:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e6c:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e70:	7e bf                	jle    80103e31 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e75:	8b 40 68             	mov    0x68(%eax),%eax
80103e78:	83 ec 0c             	sub    $0xc,%esp
80103e7b:	50                   	push   %eax
80103e7c:	e8 2f db ff ff       	call   801019b0 <idup>
80103e81:	83 c4 10             	add    $0x10,%esp
80103e84:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e87:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e8d:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e90:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e93:	83 c0 6c             	add    $0x6c,%eax
80103e96:	83 ec 04             	sub    $0x4,%esp
80103e99:	6a 10                	push   $0x10
80103e9b:	52                   	push   %edx
80103e9c:	50                   	push   %eax
80103e9d:	e8 df 0e 00 00       	call   80104d81 <safestrcpy>
80103ea2:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ea5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ea8:	8b 40 10             	mov    0x10(%eax),%eax
80103eab:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103eae:	83 ec 0c             	sub    $0xc,%esp
80103eb1:	68 00 42 19 80       	push   $0x80194200
80103eb6:	e8 4d 0a 00 00       	call   80104908 <acquire>
80103ebb:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103ebe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ec1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ec8:	83 ec 0c             	sub    $0xc,%esp
80103ecb:	68 00 42 19 80       	push   $0x80194200
80103ed0:	e8 a1 0a 00 00       	call   80104976 <release>
80103ed5:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ed8:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ede:	5b                   	pop    %ebx
80103edf:	5e                   	pop    %esi
80103ee0:	5f                   	pop    %edi
80103ee1:	5d                   	pop    %ebp
80103ee2:	c3                   	ret    

80103ee3 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ee3:	55                   	push   %ebp
80103ee4:	89 e5                	mov    %esp,%ebp
80103ee6:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103ee9:	e8 42 fb ff ff       	call   80103a30 <myproc>
80103eee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103ef1:	a1 34 6e 19 80       	mov    0x80196e34,%eax
80103ef6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ef9:	75 0d                	jne    80103f08 <exit+0x25>
    panic("init exiting");
80103efb:	83 ec 0c             	sub    $0xc,%esp
80103efe:	68 b2 a6 10 80       	push   $0x8010a6b2
80103f03:	e8 a1 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103f08:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103f0f:	eb 3f                	jmp    80103f50 <exit+0x6d>
    if(curproc->ofile[fd]){
80103f11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f14:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f17:	83 c2 08             	add    $0x8,%edx
80103f1a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f1e:	85 c0                	test   %eax,%eax
80103f20:	74 2a                	je     80103f4c <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f28:	83 c2 08             	add    $0x8,%edx
80103f2b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f2f:	83 ec 0c             	sub    $0xc,%esp
80103f32:	50                   	push   %eax
80103f33:	e8 63 d1 ff ff       	call   8010109b <fileclose>
80103f38:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f41:	83 c2 08             	add    $0x8,%edx
80103f44:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f4b:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f4c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f50:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f54:	7e bb                	jle    80103f11 <exit+0x2e>
    }
  }

  begin_op();
80103f56:	e8 e1 f0 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f5e:	8b 40 68             	mov    0x68(%eax),%eax
80103f61:	83 ec 0c             	sub    $0xc,%esp
80103f64:	50                   	push   %eax
80103f65:	e8 e1 db ff ff       	call   80101b4b <iput>
80103f6a:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f6d:	e8 56 f1 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80103f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f75:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f7c:	83 ec 0c             	sub    $0xc,%esp
80103f7f:	68 00 42 19 80       	push   $0x80194200
80103f84:	e8 7f 09 00 00       	call   80104908 <acquire>
80103f89:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f8f:	8b 40 14             	mov    0x14(%eax),%eax
80103f92:	83 ec 0c             	sub    $0xc,%esp
80103f95:	50                   	push   %eax
80103f96:	e8 f0 05 00 00       	call   8010458b <wakeup1>
80103f9b:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9e:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103fa5:	eb 3a                	jmp    80103fe1 <exit+0xfe>
    if(p->parent == curproc){
80103fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103faa:	8b 40 14             	mov    0x14(%eax),%eax
80103fad:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fb0:	75 28                	jne    80103fda <exit+0xf7>
      p->parent = initproc;
80103fb2:	8b 15 34 6e 19 80    	mov    0x80196e34,%edx
80103fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fbb:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc1:	8b 40 0c             	mov    0xc(%eax),%eax
80103fc4:	83 f8 05             	cmp    $0x5,%eax
80103fc7:	75 11                	jne    80103fda <exit+0xf7>
        wakeup1(initproc);
80103fc9:	a1 34 6e 19 80       	mov    0x80196e34,%eax
80103fce:	83 ec 0c             	sub    $0xc,%esp
80103fd1:	50                   	push   %eax
80103fd2:	e8 b4 05 00 00       	call   8010458b <wakeup1>
80103fd7:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fda:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103fe1:	81 7d f4 34 6e 19 80 	cmpl   $0x80196e34,-0xc(%ebp)
80103fe8:	72 bd                	jb     80103fa7 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fed:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103ff4:	e8 b2 03 00 00       	call   801043ab <sched>
  panic("zombie exit");
80103ff9:	83 ec 0c             	sub    $0xc,%esp
80103ffc:	68 bf a6 10 80       	push   $0x8010a6bf
80104001:	e8 a3 c5 ff ff       	call   801005a9 <panic>

80104006 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104006:	55                   	push   %ebp
80104007:	89 e5                	mov    %esp,%ebp
80104009:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010400c:	e8 1f fa ff ff       	call   80103a30 <myproc>
80104011:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104014:	83 ec 0c             	sub    $0xc,%esp
80104017:	68 00 42 19 80       	push   $0x80194200
8010401c:	e8 e7 08 00 00       	call   80104908 <acquire>
80104021:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104024:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010402b:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104032:	e9 a4 00 00 00       	jmp    801040db <wait+0xd5>
      if(p->parent != curproc)
80104037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403a:	8b 40 14             	mov    0x14(%eax),%eax
8010403d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104040:	0f 85 8d 00 00 00    	jne    801040d3 <wait+0xcd>
        continue;
      havekids = 1;
80104046:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010404d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104050:	8b 40 0c             	mov    0xc(%eax),%eax
80104053:	83 f8 05             	cmp    $0x5,%eax
80104056:	75 7c                	jne    801040d4 <wait+0xce>
        // Found one.
        pid = p->pid;
80104058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405b:	8b 40 10             	mov    0x10(%eax),%eax
8010405e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104064:	8b 40 08             	mov    0x8(%eax),%eax
80104067:	83 ec 0c             	sub    $0xc,%esp
8010406a:	50                   	push   %eax
8010406b:	e8 96 e6 ff ff       	call   80102706 <kfree>
80104070:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104076:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010407d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104080:	8b 40 04             	mov    0x4(%eax),%eax
80104083:	83 ec 0c             	sub    $0xc,%esp
80104086:	50                   	push   %eax
80104087:	e8 e1 3b 00 00       	call   80107c6d <freevm>
8010408c:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010408f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104092:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801040a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801040aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ad:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801040b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801040be:	83 ec 0c             	sub    $0xc,%esp
801040c1:	68 00 42 19 80       	push   $0x80194200
801040c6:	e8 ab 08 00 00       	call   80104976 <release>
801040cb:	83 c4 10             	add    $0x10,%esp
        return pid;
801040ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040d1:	eb 54                	jmp    80104127 <wait+0x121>
        continue;
801040d3:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040d4:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801040db:	81 7d f4 34 6e 19 80 	cmpl   $0x80196e34,-0xc(%ebp)
801040e2:	0f 82 4f ff ff ff    	jb     80104037 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040ec:	74 0a                	je     801040f8 <wait+0xf2>
801040ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040f1:	8b 40 24             	mov    0x24(%eax),%eax
801040f4:	85 c0                	test   %eax,%eax
801040f6:	74 17                	je     8010410f <wait+0x109>
      release(&ptable.lock);
801040f8:	83 ec 0c             	sub    $0xc,%esp
801040fb:	68 00 42 19 80       	push   $0x80194200
80104100:	e8 71 08 00 00       	call   80104976 <release>
80104105:	83 c4 10             	add    $0x10,%esp
      return -1;
80104108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410d:	eb 18                	jmp    80104127 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010410f:	83 ec 08             	sub    $0x8,%esp
80104112:	68 00 42 19 80       	push   $0x80194200
80104117:	ff 75 ec             	push   -0x14(%ebp)
8010411a:	e8 c5 03 00 00       	call   801044e4 <sleep>
8010411f:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104122:	e9 fd fe ff ff       	jmp    80104024 <wait+0x1e>
  }
}
80104127:	c9                   	leave  
80104128:	c3                   	ret    

80104129 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104129:	55                   	push   %ebp
8010412a:	89 e5                	mov    %esp,%ebp
8010412c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010412f:	e8 84 f8 ff ff       	call   801039b8 <mycpu>
80104134:	89 45 ec             	mov    %eax,-0x14(%ebp)
  c->proc = 0;
80104137:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010413a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104141:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104144:	e8 2f f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104149:	83 ec 0c             	sub    $0xc,%esp
8010414c:	68 00 42 19 80       	push   $0x80194200
80104151:	e8 b2 07 00 00       	call   80104908 <acquire>
80104156:	83 c4 10             	add    $0x10,%esp
    int policy = c->sched_policy;
80104159:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010415c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104162:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(policy == 0) {
80104165:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104169:	75 7b                	jne    801041e6 <scheduler+0xbd>
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010416b:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104172:	eb 64                	jmp    801041d8 <scheduler+0xaf>
        if(p->state != RUNNABLE)
80104174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104177:	8b 40 0c             	mov    0xc(%eax),%eax
8010417a:	83 f8 03             	cmp    $0x3,%eax
8010417d:	75 51                	jne    801041d0 <scheduler+0xa7>
          continue;

        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        c->proc = p;
8010417f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104182:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104185:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
8010418b:	83 ec 0c             	sub    $0xc,%esp
8010418e:	ff 75 f4             	push   -0xc(%ebp)
80104191:	e8 32 36 00 00       	call   801077c8 <switchuvm>
80104196:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
801041a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a6:	8b 40 1c             	mov    0x1c(%eax),%eax
801041a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801041ac:	83 c2 04             	add    $0x4,%edx
801041af:	83 ec 08             	sub    $0x8,%esp
801041b2:	50                   	push   %eax
801041b3:	52                   	push   %edx
801041b4:	e8 3a 0c 00 00       	call   80104df3 <swtch>
801041b9:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801041bc:	e8 ee 35 00 00       	call   801077af <switchkvm>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
801041c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041c4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041cb:	00 00 00 
801041ce:	eb 01                	jmp    801041d1 <scheduler+0xa8>
          continue;
801041d0:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041d1:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801041d8:	81 7d f4 34 6e 19 80 	cmpl   $0x80196e34,-0xc(%ebp)
801041df:	72 93                	jb     80104174 <scheduler+0x4b>
801041e1:	e9 b0 01 00 00       	jmp    80104396 <scheduler+0x26d>
      }  
    } else {
      for (int i = 3; i>= 0; i --){
801041e6:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
801041ed:	e9 9a 01 00 00       	jmp    8010438c <scheduler+0x263>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801041f2:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801041f9:	e9 7d 01 00 00       	jmp    8010437b <scheduler+0x252>
          if (p->state != RUNNABLE || p->priority != i)
801041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104201:	8b 40 0c             	mov    0xc(%eax),%eax
80104204:	83 f8 03             	cmp    $0x3,%eax
80104207:	0f 85 66 01 00 00    	jne    80104373 <scheduler+0x24a>
8010420d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104210:	8b 40 7c             	mov    0x7c(%eax),%eax
80104213:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104216:	0f 85 57 01 00 00    	jne    80104373 <scheduler+0x24a>
            continue;
          if (policy != 3) {
8010421c:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
80104220:	74 6e                	je     80104290 <scheduler+0x167>
            if ((i == 2 && p->wait_ticks[2] >= 160) ||
80104222:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
80104226:	75 10                	jne    80104238 <scheduler+0x10f>
80104228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80104231:	3d 9f 00 00 00       	cmp    $0x9f,%eax
80104236:	7f 2c                	jg     80104264 <scheduler+0x13b>
80104238:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
8010423c:	75 10                	jne    8010424e <scheduler+0x125>
                (i == 1 && p->wait_ticks[1] >= 320) ||
8010423e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104241:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80104247:	3d 3f 01 00 00       	cmp    $0x13f,%eax
8010424c:	7f 16                	jg     80104264 <scheduler+0x13b>
8010424e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104252:	75 3c                	jne    80104290 <scheduler+0x167>
                (i == 0 && p->wait_ticks[0] >= 500)) {
80104254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104257:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010425d:	3d f3 01 00 00       	cmp    $0x1f3,%eax
80104262:	7e 2c                	jle    80104290 <scheduler+0x167>
              p->priority++;
80104264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104267:	8b 40 7c             	mov    0x7c(%eax),%eax
8010426a:	8d 50 01             	lea    0x1(%eax),%edx
8010426d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104270:	89 50 7c             	mov    %edx,0x7c(%eax)
              memset(p->wait_ticks, 0, sizeof(p->wait_ticks));
80104273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104276:	05 90 00 00 00       	add    $0x90,%eax
8010427b:	83 ec 04             	sub    $0x4,%esp
8010427e:	6a 10                	push   $0x10
80104280:	6a 00                	push   $0x0
80104282:	50                   	push   %eax
80104283:	e8 f6 08 00 00       	call   80104b7e <memset>
80104288:	83 c4 10             	add    $0x10,%esp
              continue;
8010428b:	e9 e4 00 00 00       	jmp    80104374 <scheduler+0x24b>
            }
          }
          c->proc = p;
80104290:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104293:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104296:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
          switchuvm(p);
8010429c:	83 ec 0c             	sub    $0xc,%esp
8010429f:	ff 75 f4             	push   -0xc(%ebp)
801042a2:	e8 21 35 00 00       	call   801077c8 <switchuvm>
801042a7:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
801042aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ad:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
    
          swtch(&(c->scheduler), p->context);
801042b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b7:	8b 40 1c             	mov    0x1c(%eax),%eax
801042ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
801042bd:	83 c2 04             	add    $0x4,%edx
801042c0:	83 ec 08             	sub    $0x8,%esp
801042c3:	50                   	push   %eax
801042c4:	52                   	push   %edx
801042c5:	e8 29 0b 00 00       	call   80104df3 <swtch>
801042ca:	83 c4 10             	add    $0x10,%esp
          switchkvm();
801042cd:	e8 dd 34 00 00       	call   801077af <switchkvm>
    
          c->proc = 0;
801042d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042d5:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042dc:	00 00 00 
          if(policy == 2){
801042df:	83 7d e8 02          	cmpl   $0x2,-0x18(%ebp)
801042e3:	75 18                	jne    801042fd <scheduler+0x1d4>
            memset(p->ticks, 0, sizeof(p->ticks));
801042e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e8:	83 e8 80             	sub    $0xffffff80,%eax
801042eb:	83 ec 04             	sub    $0x4,%esp
801042ee:	6a 10                	push   $0x10
801042f0:	6a 00                	push   $0x0
801042f2:	50                   	push   %eax
801042f3:	e8 86 08 00 00       	call   80104b7e <memset>
801042f8:	83 c4 10             	add    $0x10,%esp
801042fb:	eb 77                	jmp    80104374 <scheduler+0x24b>
        } else {
          int pr = p->priority;
801042fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104300:	8b 40 7c             	mov    0x7c(%eax),%eax
80104303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          if ((pr == 3 && p->ticks[3] >= 8) ||
80104306:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
8010430a:	75 0e                	jne    8010431a <scheduler+0x1f1>
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104315:	83 f8 07             	cmp    $0x7,%eax
80104318:	7f 28                	jg     80104342 <scheduler+0x219>
8010431a:	83 7d e4 02          	cmpl   $0x2,-0x1c(%ebp)
8010431e:	75 0e                	jne    8010432e <scheduler+0x205>
              (pr == 2 && p->ticks[2] >= 16) ||
80104320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104323:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80104329:	83 f8 0f             	cmp    $0xf,%eax
8010432c:	7f 14                	jg     80104342 <scheduler+0x219>
8010432e:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
80104332:	75 40                	jne    80104374 <scheduler+0x24b>
              (pr == 1 && p->ticks[1] >= 32)) {
80104334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104337:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010433d:	83 f8 1f             	cmp    $0x1f,%eax
80104340:	7e 32                	jle    80104374 <scheduler+0x24b>
            if (p->priority > 0)
80104342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104345:	8b 40 7c             	mov    0x7c(%eax),%eax
80104348:	85 c0                	test   %eax,%eax
8010434a:	7e 0f                	jle    8010435b <scheduler+0x232>
              p->priority--;
8010434c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434f:	8b 40 7c             	mov    0x7c(%eax),%eax
80104352:	8d 50 ff             	lea    -0x1(%eax),%edx
80104355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104358:	89 50 7c             	mov    %edx,0x7c(%eax)
        
            memset(p->ticks, 0, sizeof(p->ticks));
8010435b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435e:	83 e8 80             	sub    $0xffffff80,%eax
80104361:	83 ec 04             	sub    $0x4,%esp
80104364:	6a 10                	push   $0x10
80104366:	6a 00                	push   $0x0
80104368:	50                   	push   %eax
80104369:	e8 10 08 00 00       	call   80104b7e <memset>
8010436e:	83 c4 10             	add    $0x10,%esp
80104371:	eb 01                	jmp    80104374 <scheduler+0x24b>
            continue;
80104373:	90                   	nop
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104374:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
8010437b:	81 7d f4 34 6e 19 80 	cmpl   $0x80196e34,-0xc(%ebp)
80104382:	0f 82 76 fe ff ff    	jb     801041fe <scheduler+0xd5>
      for (int i = 3; i>= 0; i --){
80104388:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010438c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104390:	0f 89 5c fe ff ff    	jns    801041f2 <scheduler+0xc9>
        }
  
      }      
    }
    }
    release(&ptable.lock);    
80104396:	83 ec 0c             	sub    $0xc,%esp
80104399:	68 00 42 19 80       	push   $0x80194200
8010439e:	e8 d3 05 00 00       	call   80104976 <release>
801043a3:	83 c4 10             	add    $0x10,%esp
  for(;;){
801043a6:	e9 99 fd ff ff       	jmp    80104144 <scheduler+0x1b>

801043ab <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801043ab:	55                   	push   %ebp
801043ac:	89 e5                	mov    %esp,%ebp
801043ae:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801043b1:	e8 7a f6 ff ff       	call   80103a30 <myproc>
801043b6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801043b9:	83 ec 0c             	sub    $0xc,%esp
801043bc:	68 00 42 19 80       	push   $0x80194200
801043c1:	e8 7d 06 00 00       	call   80104a43 <holding>
801043c6:	83 c4 10             	add    $0x10,%esp
801043c9:	85 c0                	test   %eax,%eax
801043cb:	75 0d                	jne    801043da <sched+0x2f>
    panic("sched ptable.lock");
801043cd:	83 ec 0c             	sub    $0xc,%esp
801043d0:	68 cb a6 10 80       	push   $0x8010a6cb
801043d5:	e8 cf c1 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801043da:	e8 d9 f5 ff ff       	call   801039b8 <mycpu>
801043df:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801043e5:	83 f8 01             	cmp    $0x1,%eax
801043e8:	74 0d                	je     801043f7 <sched+0x4c>
    panic("sched locks");
801043ea:	83 ec 0c             	sub    $0xc,%esp
801043ed:	68 dd a6 10 80       	push   $0x8010a6dd
801043f2:	e8 b2 c1 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801043f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fa:	8b 40 0c             	mov    0xc(%eax),%eax
801043fd:	83 f8 04             	cmp    $0x4,%eax
80104400:	75 0d                	jne    8010440f <sched+0x64>
    panic("sched running");
80104402:	83 ec 0c             	sub    $0xc,%esp
80104405:	68 e9 a6 10 80       	push   $0x8010a6e9
8010440a:	e8 9a c1 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
8010440f:	e8 54 f5 ff ff       	call   80103968 <readeflags>
80104414:	25 00 02 00 00       	and    $0x200,%eax
80104419:	85 c0                	test   %eax,%eax
8010441b:	74 0d                	je     8010442a <sched+0x7f>
    panic("sched interruptible");
8010441d:	83 ec 0c             	sub    $0xc,%esp
80104420:	68 f7 a6 10 80       	push   $0x8010a6f7
80104425:	e8 7f c1 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010442a:	e8 89 f5 ff ff       	call   801039b8 <mycpu>
8010442f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104435:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104438:	e8 7b f5 ff ff       	call   801039b8 <mycpu>
8010443d:	8b 40 04             	mov    0x4(%eax),%eax
80104440:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104443:	83 c2 1c             	add    $0x1c,%edx
80104446:	83 ec 08             	sub    $0x8,%esp
80104449:	50                   	push   %eax
8010444a:	52                   	push   %edx
8010444b:	e8 a3 09 00 00       	call   80104df3 <swtch>
80104450:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104453:	e8 60 f5 ff ff       	call   801039b8 <mycpu>
80104458:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010445b:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104461:	90                   	nop
80104462:	c9                   	leave  
80104463:	c3                   	ret    

80104464 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104464:	55                   	push   %ebp
80104465:	89 e5                	mov    %esp,%ebp
80104467:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010446a:	83 ec 0c             	sub    $0xc,%esp
8010446d:	68 00 42 19 80       	push   $0x80194200
80104472:	e8 91 04 00 00       	call   80104908 <acquire>
80104477:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010447a:	e8 b1 f5 ff ff       	call   80103a30 <myproc>
8010447f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104486:	e8 20 ff ff ff       	call   801043ab <sched>
  release(&ptable.lock);
8010448b:	83 ec 0c             	sub    $0xc,%esp
8010448e:	68 00 42 19 80       	push   $0x80194200
80104493:	e8 de 04 00 00       	call   80104976 <release>
80104498:	83 c4 10             	add    $0x10,%esp
}
8010449b:	90                   	nop
8010449c:	c9                   	leave  
8010449d:	c3                   	ret    

8010449e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010449e:	55                   	push   %ebp
8010449f:	89 e5                	mov    %esp,%ebp
801044a1:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801044a4:	83 ec 0c             	sub    $0xc,%esp
801044a7:	68 00 42 19 80       	push   $0x80194200
801044ac:	e8 c5 04 00 00       	call   80104976 <release>
801044b1:	83 c4 10             	add    $0x10,%esp

  if (first) {
801044b4:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801044b9:	85 c0                	test   %eax,%eax
801044bb:	74 24                	je     801044e1 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801044bd:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801044c4:	00 00 00 
    iinit(ROOTDEV);
801044c7:	83 ec 0c             	sub    $0xc,%esp
801044ca:	6a 01                	push   $0x1
801044cc:	e8 a7 d1 ff ff       	call   80101678 <iinit>
801044d1:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801044d4:	83 ec 0c             	sub    $0xc,%esp
801044d7:	6a 01                	push   $0x1
801044d9:	e8 3f e9 ff ff       	call   80102e1d <initlog>
801044de:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801044e1:	90                   	nop
801044e2:	c9                   	leave  
801044e3:	c3                   	ret    

801044e4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801044e4:	55                   	push   %ebp
801044e5:	89 e5                	mov    %esp,%ebp
801044e7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801044ea:	e8 41 f5 ff ff       	call   80103a30 <myproc>
801044ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801044f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044f6:	75 0d                	jne    80104505 <sleep+0x21>
    panic("sleep");
801044f8:	83 ec 0c             	sub    $0xc,%esp
801044fb:	68 0b a7 10 80       	push   $0x8010a70b
80104500:	e8 a4 c0 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104509:	75 0d                	jne    80104518 <sleep+0x34>
    panic("sleep without lk");
8010450b:	83 ec 0c             	sub    $0xc,%esp
8010450e:	68 11 a7 10 80       	push   $0x8010a711
80104513:	e8 91 c0 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104518:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010451f:	74 1e                	je     8010453f <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104521:	83 ec 0c             	sub    $0xc,%esp
80104524:	68 00 42 19 80       	push   $0x80194200
80104529:	e8 da 03 00 00       	call   80104908 <acquire>
8010452e:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104531:	83 ec 0c             	sub    $0xc,%esp
80104534:	ff 75 0c             	push   0xc(%ebp)
80104537:	e8 3a 04 00 00       	call   80104976 <release>
8010453c:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010453f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104542:	8b 55 08             	mov    0x8(%ebp),%edx
80104545:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454b:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104552:	e8 54 fe ff ff       	call   801043ab <sched>

  // Tidy up.
  p->chan = 0;
80104557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455a:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104561:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104568:	74 1e                	je     80104588 <sleep+0xa4>
    release(&ptable.lock);
8010456a:	83 ec 0c             	sub    $0xc,%esp
8010456d:	68 00 42 19 80       	push   $0x80194200
80104572:	e8 ff 03 00 00       	call   80104976 <release>
80104577:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010457a:	83 ec 0c             	sub    $0xc,%esp
8010457d:	ff 75 0c             	push   0xc(%ebp)
80104580:	e8 83 03 00 00       	call   80104908 <acquire>
80104585:	83 c4 10             	add    $0x10,%esp
  }
}
80104588:	90                   	nop
80104589:	c9                   	leave  
8010458a:	c3                   	ret    

8010458b <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010458b:	55                   	push   %ebp
8010458c:	89 e5                	mov    %esp,%ebp
8010458e:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104591:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104598:	eb 27                	jmp    801045c1 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010459a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010459d:	8b 40 0c             	mov    0xc(%eax),%eax
801045a0:	83 f8 02             	cmp    $0x2,%eax
801045a3:	75 15                	jne    801045ba <wakeup1+0x2f>
801045a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045a8:	8b 40 20             	mov    0x20(%eax),%eax
801045ab:	39 45 08             	cmp    %eax,0x8(%ebp)
801045ae:	75 0a                	jne    801045ba <wakeup1+0x2f>
      p->state = RUNNABLE;
801045b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045b3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045ba:	81 45 fc b0 00 00 00 	addl   $0xb0,-0x4(%ebp)
801045c1:	81 7d fc 34 6e 19 80 	cmpl   $0x80196e34,-0x4(%ebp)
801045c8:	72 d0                	jb     8010459a <wakeup1+0xf>
}
801045ca:	90                   	nop
801045cb:	90                   	nop
801045cc:	c9                   	leave  
801045cd:	c3                   	ret    

801045ce <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801045ce:	55                   	push   %ebp
801045cf:	89 e5                	mov    %esp,%ebp
801045d1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801045d4:	83 ec 0c             	sub    $0xc,%esp
801045d7:	68 00 42 19 80       	push   $0x80194200
801045dc:	e8 27 03 00 00       	call   80104908 <acquire>
801045e1:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801045e4:	83 ec 0c             	sub    $0xc,%esp
801045e7:	ff 75 08             	push   0x8(%ebp)
801045ea:	e8 9c ff ff ff       	call   8010458b <wakeup1>
801045ef:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801045f2:	83 ec 0c             	sub    $0xc,%esp
801045f5:	68 00 42 19 80       	push   $0x80194200
801045fa:	e8 77 03 00 00       	call   80104976 <release>
801045ff:	83 c4 10             	add    $0x10,%esp
}
80104602:	90                   	nop
80104603:	c9                   	leave  
80104604:	c3                   	ret    

80104605 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104605:	55                   	push   %ebp
80104606:	89 e5                	mov    %esp,%ebp
80104608:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010460b:	83 ec 0c             	sub    $0xc,%esp
8010460e:	68 00 42 19 80       	push   $0x80194200
80104613:	e8 f0 02 00 00       	call   80104908 <acquire>
80104618:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010461b:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104622:	eb 48                	jmp    8010466c <kill+0x67>
    if(p->pid == pid){
80104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104627:	8b 40 10             	mov    0x10(%eax),%eax
8010462a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010462d:	75 36                	jne    80104665 <kill+0x60>
      p->killed = 1;
8010462f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104632:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463c:	8b 40 0c             	mov    0xc(%eax),%eax
8010463f:	83 f8 02             	cmp    $0x2,%eax
80104642:	75 0a                	jne    8010464e <kill+0x49>
        p->state = RUNNABLE;
80104644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104647:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010464e:	83 ec 0c             	sub    $0xc,%esp
80104651:	68 00 42 19 80       	push   $0x80194200
80104656:	e8 1b 03 00 00       	call   80104976 <release>
8010465b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010465e:	b8 00 00 00 00       	mov    $0x0,%eax
80104663:	eb 25                	jmp    8010468a <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104665:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
8010466c:	81 7d f4 34 6e 19 80 	cmpl   $0x80196e34,-0xc(%ebp)
80104673:	72 af                	jb     80104624 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104675:	83 ec 0c             	sub    $0xc,%esp
80104678:	68 00 42 19 80       	push   $0x80194200
8010467d:	e8 f4 02 00 00       	call   80104976 <release>
80104682:	83 c4 10             	add    $0x10,%esp
  return -1;
80104685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010468a:	c9                   	leave  
8010468b:	c3                   	ret    

8010468c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010468c:	55                   	push   %ebp
8010468d:	89 e5                	mov    %esp,%ebp
8010468f:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104692:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104699:	e9 da 00 00 00       	jmp    80104778 <procdump+0xec>
    if(p->state == UNUSED)
8010469e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046a1:	8b 40 0c             	mov    0xc(%eax),%eax
801046a4:	85 c0                	test   %eax,%eax
801046a6:	0f 84 c4 00 00 00    	je     80104770 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801046ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046af:	8b 40 0c             	mov    0xc(%eax),%eax
801046b2:	83 f8 05             	cmp    $0x5,%eax
801046b5:	77 23                	ja     801046da <procdump+0x4e>
801046b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ba:	8b 40 0c             	mov    0xc(%eax),%eax
801046bd:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801046c4:	85 c0                	test   %eax,%eax
801046c6:	74 12                	je     801046da <procdump+0x4e>
      state = states[p->state];
801046c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046cb:	8b 40 0c             	mov    0xc(%eax),%eax
801046ce:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801046d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801046d8:	eb 07                	jmp    801046e1 <procdump+0x55>
    else
      state = "???";
801046da:	c7 45 ec 22 a7 10 80 	movl   $0x8010a722,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801046e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046e4:	8d 50 6c             	lea    0x6c(%eax),%edx
801046e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ea:	8b 40 10             	mov    0x10(%eax),%eax
801046ed:	52                   	push   %edx
801046ee:	ff 75 ec             	push   -0x14(%ebp)
801046f1:	50                   	push   %eax
801046f2:	68 26 a7 10 80       	push   $0x8010a726
801046f7:	e8 f8 bc ff ff       	call   801003f4 <cprintf>
801046fc:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801046ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104702:	8b 40 0c             	mov    0xc(%eax),%eax
80104705:	83 f8 02             	cmp    $0x2,%eax
80104708:	75 54                	jne    8010475e <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010470a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010470d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104710:	8b 40 0c             	mov    0xc(%eax),%eax
80104713:	83 c0 08             	add    $0x8,%eax
80104716:	89 c2                	mov    %eax,%edx
80104718:	83 ec 08             	sub    $0x8,%esp
8010471b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010471e:	50                   	push   %eax
8010471f:	52                   	push   %edx
80104720:	e8 a3 02 00 00       	call   801049c8 <getcallerpcs>
80104725:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104728:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010472f:	eb 1c                	jmp    8010474d <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104734:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104738:	83 ec 08             	sub    $0x8,%esp
8010473b:	50                   	push   %eax
8010473c:	68 2f a7 10 80       	push   $0x8010a72f
80104741:	e8 ae bc ff ff       	call   801003f4 <cprintf>
80104746:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104749:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010474d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104751:	7f 0b                	jg     8010475e <procdump+0xd2>
80104753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104756:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010475a:	85 c0                	test   %eax,%eax
8010475c:	75 d3                	jne    80104731 <procdump+0xa5>
    }
    cprintf("\n");
8010475e:	83 ec 0c             	sub    $0xc,%esp
80104761:	68 33 a7 10 80       	push   $0x8010a733
80104766:	e8 89 bc ff ff       	call   801003f4 <cprintf>
8010476b:	83 c4 10             	add    $0x10,%esp
8010476e:	eb 01                	jmp    80104771 <procdump+0xe5>
      continue;
80104770:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104771:	81 45 f0 b0 00 00 00 	addl   $0xb0,-0x10(%ebp)
80104778:	81 7d f0 34 6e 19 80 	cmpl   $0x80196e34,-0x10(%ebp)
8010477f:	0f 82 19 ff ff ff    	jb     8010469e <procdump+0x12>
  }
}
80104785:	90                   	nop
80104786:	90                   	nop
80104787:	c9                   	leave  
80104788:	c3                   	ret    

80104789 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104789:	55                   	push   %ebp
8010478a:	89 e5                	mov    %esp,%ebp
8010478c:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010478f:	8b 45 08             	mov    0x8(%ebp),%eax
80104792:	83 c0 04             	add    $0x4,%eax
80104795:	83 ec 08             	sub    $0x8,%esp
80104798:	68 5f a7 10 80       	push   $0x8010a75f
8010479d:	50                   	push   %eax
8010479e:	e8 43 01 00 00       	call   801048e6 <initlock>
801047a3:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801047a6:	8b 45 08             	mov    0x8(%ebp),%eax
801047a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801047ac:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801047af:	8b 45 08             	mov    0x8(%ebp),%eax
801047b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801047b8:	8b 45 08             	mov    0x8(%ebp),%eax
801047bb:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801047c2:	90                   	nop
801047c3:	c9                   	leave  
801047c4:	c3                   	ret    

801047c5 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801047c5:	55                   	push   %ebp
801047c6:	89 e5                	mov    %esp,%ebp
801047c8:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801047cb:	8b 45 08             	mov    0x8(%ebp),%eax
801047ce:	83 c0 04             	add    $0x4,%eax
801047d1:	83 ec 0c             	sub    $0xc,%esp
801047d4:	50                   	push   %eax
801047d5:	e8 2e 01 00 00       	call   80104908 <acquire>
801047da:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801047dd:	eb 15                	jmp    801047f4 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801047df:	8b 45 08             	mov    0x8(%ebp),%eax
801047e2:	83 c0 04             	add    $0x4,%eax
801047e5:	83 ec 08             	sub    $0x8,%esp
801047e8:	50                   	push   %eax
801047e9:	ff 75 08             	push   0x8(%ebp)
801047ec:	e8 f3 fc ff ff       	call   801044e4 <sleep>
801047f1:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801047f4:	8b 45 08             	mov    0x8(%ebp),%eax
801047f7:	8b 00                	mov    (%eax),%eax
801047f9:	85 c0                	test   %eax,%eax
801047fb:	75 e2                	jne    801047df <acquiresleep+0x1a>
  }
  lk->locked = 1;
801047fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104800:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104806:	e8 25 f2 ff ff       	call   80103a30 <myproc>
8010480b:	8b 50 10             	mov    0x10(%eax),%edx
8010480e:	8b 45 08             	mov    0x8(%ebp),%eax
80104811:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104814:	8b 45 08             	mov    0x8(%ebp),%eax
80104817:	83 c0 04             	add    $0x4,%eax
8010481a:	83 ec 0c             	sub    $0xc,%esp
8010481d:	50                   	push   %eax
8010481e:	e8 53 01 00 00       	call   80104976 <release>
80104823:	83 c4 10             	add    $0x10,%esp
}
80104826:	90                   	nop
80104827:	c9                   	leave  
80104828:	c3                   	ret    

80104829 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104829:	55                   	push   %ebp
8010482a:	89 e5                	mov    %esp,%ebp
8010482c:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010482f:	8b 45 08             	mov    0x8(%ebp),%eax
80104832:	83 c0 04             	add    $0x4,%eax
80104835:	83 ec 0c             	sub    $0xc,%esp
80104838:	50                   	push   %eax
80104839:	e8 ca 00 00 00       	call   80104908 <acquire>
8010483e:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104841:	8b 45 08             	mov    0x8(%ebp),%eax
80104844:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010484a:	8b 45 08             	mov    0x8(%ebp),%eax
8010484d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104854:	83 ec 0c             	sub    $0xc,%esp
80104857:	ff 75 08             	push   0x8(%ebp)
8010485a:	e8 6f fd ff ff       	call   801045ce <wakeup>
8010485f:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104862:	8b 45 08             	mov    0x8(%ebp),%eax
80104865:	83 c0 04             	add    $0x4,%eax
80104868:	83 ec 0c             	sub    $0xc,%esp
8010486b:	50                   	push   %eax
8010486c:	e8 05 01 00 00       	call   80104976 <release>
80104871:	83 c4 10             	add    $0x10,%esp
}
80104874:	90                   	nop
80104875:	c9                   	leave  
80104876:	c3                   	ret    

80104877 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104877:	55                   	push   %ebp
80104878:	89 e5                	mov    %esp,%ebp
8010487a:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
8010487d:	8b 45 08             	mov    0x8(%ebp),%eax
80104880:	83 c0 04             	add    $0x4,%eax
80104883:	83 ec 0c             	sub    $0xc,%esp
80104886:	50                   	push   %eax
80104887:	e8 7c 00 00 00       	call   80104908 <acquire>
8010488c:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
8010488f:	8b 45 08             	mov    0x8(%ebp),%eax
80104892:	8b 00                	mov    (%eax),%eax
80104894:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104897:	8b 45 08             	mov    0x8(%ebp),%eax
8010489a:	83 c0 04             	add    $0x4,%eax
8010489d:	83 ec 0c             	sub    $0xc,%esp
801048a0:	50                   	push   %eax
801048a1:	e8 d0 00 00 00       	call   80104976 <release>
801048a6:	83 c4 10             	add    $0x10,%esp
  return r;
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801048ac:	c9                   	leave  
801048ad:	c3                   	ret    

801048ae <readeflags>:
{
801048ae:	55                   	push   %ebp
801048af:	89 e5                	mov    %esp,%ebp
801048b1:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801048b4:	9c                   	pushf  
801048b5:	58                   	pop    %eax
801048b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801048b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801048bc:	c9                   	leave  
801048bd:	c3                   	ret    

801048be <cli>:
{
801048be:	55                   	push   %ebp
801048bf:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801048c1:	fa                   	cli    
}
801048c2:	90                   	nop
801048c3:	5d                   	pop    %ebp
801048c4:	c3                   	ret    

801048c5 <sti>:
{
801048c5:	55                   	push   %ebp
801048c6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801048c8:	fb                   	sti    
}
801048c9:	90                   	nop
801048ca:	5d                   	pop    %ebp
801048cb:	c3                   	ret    

801048cc <xchg>:
{
801048cc:	55                   	push   %ebp
801048cd:	89 e5                	mov    %esp,%ebp
801048cf:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801048d2:	8b 55 08             	mov    0x8(%ebp),%edx
801048d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801048d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801048db:	f0 87 02             	lock xchg %eax,(%edx)
801048de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801048e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801048e4:	c9                   	leave  
801048e5:	c3                   	ret    

801048e6 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801048e6:	55                   	push   %ebp
801048e7:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801048e9:	8b 45 08             	mov    0x8(%ebp),%eax
801048ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801048ef:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801048f2:	8b 45 08             	mov    0x8(%ebp),%eax
801048f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801048fb:	8b 45 08             	mov    0x8(%ebp),%eax
801048fe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104905:	90                   	nop
80104906:	5d                   	pop    %ebp
80104907:	c3                   	ret    

80104908 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104908:	55                   	push   %ebp
80104909:	89 e5                	mov    %esp,%ebp
8010490b:	53                   	push   %ebx
8010490c:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010490f:	e8 5f 01 00 00       	call   80104a73 <pushcli>
  if(holding(lk)){
80104914:	8b 45 08             	mov    0x8(%ebp),%eax
80104917:	83 ec 0c             	sub    $0xc,%esp
8010491a:	50                   	push   %eax
8010491b:	e8 23 01 00 00       	call   80104a43 <holding>
80104920:	83 c4 10             	add    $0x10,%esp
80104923:	85 c0                	test   %eax,%eax
80104925:	74 0d                	je     80104934 <acquire+0x2c>
    panic("acquire");
80104927:	83 ec 0c             	sub    $0xc,%esp
8010492a:	68 6a a7 10 80       	push   $0x8010a76a
8010492f:	e8 75 bc ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104934:	90                   	nop
80104935:	8b 45 08             	mov    0x8(%ebp),%eax
80104938:	83 ec 08             	sub    $0x8,%esp
8010493b:	6a 01                	push   $0x1
8010493d:	50                   	push   %eax
8010493e:	e8 89 ff ff ff       	call   801048cc <xchg>
80104943:	83 c4 10             	add    $0x10,%esp
80104946:	85 c0                	test   %eax,%eax
80104948:	75 eb                	jne    80104935 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010494a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010494f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104952:	e8 61 f0 ff ff       	call   801039b8 <mycpu>
80104957:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010495a:	8b 45 08             	mov    0x8(%ebp),%eax
8010495d:	83 c0 0c             	add    $0xc,%eax
80104960:	83 ec 08             	sub    $0x8,%esp
80104963:	50                   	push   %eax
80104964:	8d 45 08             	lea    0x8(%ebp),%eax
80104967:	50                   	push   %eax
80104968:	e8 5b 00 00 00       	call   801049c8 <getcallerpcs>
8010496d:	83 c4 10             	add    $0x10,%esp
}
80104970:	90                   	nop
80104971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104974:	c9                   	leave  
80104975:	c3                   	ret    

80104976 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104976:	55                   	push   %ebp
80104977:	89 e5                	mov    %esp,%ebp
80104979:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010497c:	83 ec 0c             	sub    $0xc,%esp
8010497f:	ff 75 08             	push   0x8(%ebp)
80104982:	e8 bc 00 00 00       	call   80104a43 <holding>
80104987:	83 c4 10             	add    $0x10,%esp
8010498a:	85 c0                	test   %eax,%eax
8010498c:	75 0d                	jne    8010499b <release+0x25>
    panic("release");
8010498e:	83 ec 0c             	sub    $0xc,%esp
80104991:	68 72 a7 10 80       	push   $0x8010a772
80104996:	e8 0e bc ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
8010499b:	8b 45 08             	mov    0x8(%ebp),%eax
8010499e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801049a5:	8b 45 08             	mov    0x8(%ebp),%eax
801049a8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801049af:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801049b4:	8b 45 08             	mov    0x8(%ebp),%eax
801049b7:	8b 55 08             	mov    0x8(%ebp),%edx
801049ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801049c0:	e8 fb 00 00 00       	call   80104ac0 <popcli>
}
801049c5:	90                   	nop
801049c6:	c9                   	leave  
801049c7:	c3                   	ret    

801049c8 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801049c8:	55                   	push   %ebp
801049c9:	89 e5                	mov    %esp,%ebp
801049cb:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801049ce:	8b 45 08             	mov    0x8(%ebp),%eax
801049d1:	83 e8 08             	sub    $0x8,%eax
801049d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801049d7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801049de:	eb 38                	jmp    80104a18 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801049e0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801049e4:	74 53                	je     80104a39 <getcallerpcs+0x71>
801049e6:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801049ed:	76 4a                	jbe    80104a39 <getcallerpcs+0x71>
801049ef:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801049f3:	74 44                	je     80104a39 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801049f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a02:	01 c2                	add    %eax,%edx
80104a04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a07:	8b 40 04             	mov    0x4(%eax),%eax
80104a0a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104a0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a0f:	8b 00                	mov    (%eax),%eax
80104a11:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104a14:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a18:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a1c:	7e c2                	jle    801049e0 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104a1e:	eb 19                	jmp    80104a39 <getcallerpcs+0x71>
    pcs[i] = 0;
80104a20:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a23:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a2d:	01 d0                	add    %edx,%eax
80104a2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104a35:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a39:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a3d:	7e e1                	jle    80104a20 <getcallerpcs+0x58>
}
80104a3f:	90                   	nop
80104a40:	90                   	nop
80104a41:	c9                   	leave  
80104a42:	c3                   	ret    

80104a43 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104a43:	55                   	push   %ebp
80104a44:	89 e5                	mov    %esp,%ebp
80104a46:	53                   	push   %ebx
80104a47:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4d:	8b 00                	mov    (%eax),%eax
80104a4f:	85 c0                	test   %eax,%eax
80104a51:	74 16                	je     80104a69 <holding+0x26>
80104a53:	8b 45 08             	mov    0x8(%ebp),%eax
80104a56:	8b 58 08             	mov    0x8(%eax),%ebx
80104a59:	e8 5a ef ff ff       	call   801039b8 <mycpu>
80104a5e:	39 c3                	cmp    %eax,%ebx
80104a60:	75 07                	jne    80104a69 <holding+0x26>
80104a62:	b8 01 00 00 00       	mov    $0x1,%eax
80104a67:	eb 05                	jmp    80104a6e <holding+0x2b>
80104a69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a71:	c9                   	leave  
80104a72:	c3                   	ret    

80104a73 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104a73:	55                   	push   %ebp
80104a74:	89 e5                	mov    %esp,%ebp
80104a76:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104a79:	e8 30 fe ff ff       	call   801048ae <readeflags>
80104a7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104a81:	e8 38 fe ff ff       	call   801048be <cli>
  if(mycpu()->ncli == 0)
80104a86:	e8 2d ef ff ff       	call   801039b8 <mycpu>
80104a8b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a91:	85 c0                	test   %eax,%eax
80104a93:	75 14                	jne    80104aa9 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104a95:	e8 1e ef ff ff       	call   801039b8 <mycpu>
80104a9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a9d:	81 e2 00 02 00 00    	and    $0x200,%edx
80104aa3:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104aa9:	e8 0a ef ff ff       	call   801039b8 <mycpu>
80104aae:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ab4:	83 c2 01             	add    $0x1,%edx
80104ab7:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104abd:	90                   	nop
80104abe:	c9                   	leave  
80104abf:	c3                   	ret    

80104ac0 <popcli>:

void
popcli(void)
{
80104ac0:	55                   	push   %ebp
80104ac1:	89 e5                	mov    %esp,%ebp
80104ac3:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104ac6:	e8 e3 fd ff ff       	call   801048ae <readeflags>
80104acb:	25 00 02 00 00       	and    $0x200,%eax
80104ad0:	85 c0                	test   %eax,%eax
80104ad2:	74 0d                	je     80104ae1 <popcli+0x21>
    panic("popcli - interruptible");
80104ad4:	83 ec 0c             	sub    $0xc,%esp
80104ad7:	68 7a a7 10 80       	push   $0x8010a77a
80104adc:	e8 c8 ba ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104ae1:	e8 d2 ee ff ff       	call   801039b8 <mycpu>
80104ae6:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104aec:	83 ea 01             	sub    $0x1,%edx
80104aef:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104af5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104afb:	85 c0                	test   %eax,%eax
80104afd:	79 0d                	jns    80104b0c <popcli+0x4c>
    panic("popcli");
80104aff:	83 ec 0c             	sub    $0xc,%esp
80104b02:	68 91 a7 10 80       	push   $0x8010a791
80104b07:	e8 9d ba ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104b0c:	e8 a7 ee ff ff       	call   801039b8 <mycpu>
80104b11:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b17:	85 c0                	test   %eax,%eax
80104b19:	75 14                	jne    80104b2f <popcli+0x6f>
80104b1b:	e8 98 ee ff ff       	call   801039b8 <mycpu>
80104b20:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b26:	85 c0                	test   %eax,%eax
80104b28:	74 05                	je     80104b2f <popcli+0x6f>
    sti();
80104b2a:	e8 96 fd ff ff       	call   801048c5 <sti>
}
80104b2f:	90                   	nop
80104b30:	c9                   	leave  
80104b31:	c3                   	ret    

80104b32 <stosb>:
{
80104b32:	55                   	push   %ebp
80104b33:	89 e5                	mov    %esp,%ebp
80104b35:	57                   	push   %edi
80104b36:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104b37:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b3a:	8b 55 10             	mov    0x10(%ebp),%edx
80104b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b40:	89 cb                	mov    %ecx,%ebx
80104b42:	89 df                	mov    %ebx,%edi
80104b44:	89 d1                	mov    %edx,%ecx
80104b46:	fc                   	cld    
80104b47:	f3 aa                	rep stos %al,%es:(%edi)
80104b49:	89 ca                	mov    %ecx,%edx
80104b4b:	89 fb                	mov    %edi,%ebx
80104b4d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b50:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b53:	90                   	nop
80104b54:	5b                   	pop    %ebx
80104b55:	5f                   	pop    %edi
80104b56:	5d                   	pop    %ebp
80104b57:	c3                   	ret    

80104b58 <stosl>:
{
80104b58:	55                   	push   %ebp
80104b59:	89 e5                	mov    %esp,%ebp
80104b5b:	57                   	push   %edi
80104b5c:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104b5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b60:	8b 55 10             	mov    0x10(%ebp),%edx
80104b63:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b66:	89 cb                	mov    %ecx,%ebx
80104b68:	89 df                	mov    %ebx,%edi
80104b6a:	89 d1                	mov    %edx,%ecx
80104b6c:	fc                   	cld    
80104b6d:	f3 ab                	rep stos %eax,%es:(%edi)
80104b6f:	89 ca                	mov    %ecx,%edx
80104b71:	89 fb                	mov    %edi,%ebx
80104b73:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b76:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b79:	90                   	nop
80104b7a:	5b                   	pop    %ebx
80104b7b:	5f                   	pop    %edi
80104b7c:	5d                   	pop    %ebp
80104b7d:	c3                   	ret    

80104b7e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104b7e:	55                   	push   %ebp
80104b7f:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104b81:	8b 45 08             	mov    0x8(%ebp),%eax
80104b84:	83 e0 03             	and    $0x3,%eax
80104b87:	85 c0                	test   %eax,%eax
80104b89:	75 43                	jne    80104bce <memset+0x50>
80104b8b:	8b 45 10             	mov    0x10(%ebp),%eax
80104b8e:	83 e0 03             	and    $0x3,%eax
80104b91:	85 c0                	test   %eax,%eax
80104b93:	75 39                	jne    80104bce <memset+0x50>
    c &= 0xFF;
80104b95:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104b9c:	8b 45 10             	mov    0x10(%ebp),%eax
80104b9f:	c1 e8 02             	shr    $0x2,%eax
80104ba2:	89 c2                	mov    %eax,%edx
80104ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba7:	c1 e0 18             	shl    $0x18,%eax
80104baa:	89 c1                	mov    %eax,%ecx
80104bac:	8b 45 0c             	mov    0xc(%ebp),%eax
80104baf:	c1 e0 10             	shl    $0x10,%eax
80104bb2:	09 c1                	or     %eax,%ecx
80104bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bb7:	c1 e0 08             	shl    $0x8,%eax
80104bba:	09 c8                	or     %ecx,%eax
80104bbc:	0b 45 0c             	or     0xc(%ebp),%eax
80104bbf:	52                   	push   %edx
80104bc0:	50                   	push   %eax
80104bc1:	ff 75 08             	push   0x8(%ebp)
80104bc4:	e8 8f ff ff ff       	call   80104b58 <stosl>
80104bc9:	83 c4 0c             	add    $0xc,%esp
80104bcc:	eb 12                	jmp    80104be0 <memset+0x62>
  } else
    stosb(dst, c, n);
80104bce:	8b 45 10             	mov    0x10(%ebp),%eax
80104bd1:	50                   	push   %eax
80104bd2:	ff 75 0c             	push   0xc(%ebp)
80104bd5:	ff 75 08             	push   0x8(%ebp)
80104bd8:	e8 55 ff ff ff       	call   80104b32 <stosb>
80104bdd:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104be0:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104be3:	c9                   	leave  
80104be4:	c3                   	ret    

80104be5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104be5:	55                   	push   %ebp
80104be6:	89 e5                	mov    %esp,%ebp
80104be8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104beb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bf4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104bf7:	eb 30                	jmp    80104c29 <memcmp+0x44>
    if(*s1 != *s2)
80104bf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bfc:	0f b6 10             	movzbl (%eax),%edx
80104bff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c02:	0f b6 00             	movzbl (%eax),%eax
80104c05:	38 c2                	cmp    %al,%dl
80104c07:	74 18                	je     80104c21 <memcmp+0x3c>
      return *s1 - *s2;
80104c09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c0c:	0f b6 00             	movzbl (%eax),%eax
80104c0f:	0f b6 d0             	movzbl %al,%edx
80104c12:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c15:	0f b6 00             	movzbl (%eax),%eax
80104c18:	0f b6 c8             	movzbl %al,%ecx
80104c1b:	89 d0                	mov    %edx,%eax
80104c1d:	29 c8                	sub    %ecx,%eax
80104c1f:	eb 1a                	jmp    80104c3b <memcmp+0x56>
    s1++, s2++;
80104c21:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104c25:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104c29:	8b 45 10             	mov    0x10(%ebp),%eax
80104c2c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c2f:	89 55 10             	mov    %edx,0x10(%ebp)
80104c32:	85 c0                	test   %eax,%eax
80104c34:	75 c3                	jne    80104bf9 <memcmp+0x14>
  }

  return 0;
80104c36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c3b:	c9                   	leave  
80104c3c:	c3                   	ret    

80104c3d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104c3d:	55                   	push   %ebp
80104c3e:	89 e5                	mov    %esp,%ebp
80104c40:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104c43:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c46:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104c49:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104c4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c52:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104c55:	73 54                	jae    80104cab <memmove+0x6e>
80104c57:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c5a:	8b 45 10             	mov    0x10(%ebp),%eax
80104c5d:	01 d0                	add    %edx,%eax
80104c5f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104c62:	73 47                	jae    80104cab <memmove+0x6e>
    s += n;
80104c64:	8b 45 10             	mov    0x10(%ebp),%eax
80104c67:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104c6a:	8b 45 10             	mov    0x10(%ebp),%eax
80104c6d:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104c70:	eb 13                	jmp    80104c85 <memmove+0x48>
      *--d = *--s;
80104c72:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104c76:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104c7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c7d:	0f b6 10             	movzbl (%eax),%edx
80104c80:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c83:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c85:	8b 45 10             	mov    0x10(%ebp),%eax
80104c88:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c8b:	89 55 10             	mov    %edx,0x10(%ebp)
80104c8e:	85 c0                	test   %eax,%eax
80104c90:	75 e0                	jne    80104c72 <memmove+0x35>
  if(s < d && s + n > d){
80104c92:	eb 24                	jmp    80104cb8 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104c94:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c97:	8d 42 01             	lea    0x1(%edx),%eax
80104c9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104c9d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ca0:	8d 48 01             	lea    0x1(%eax),%ecx
80104ca3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ca6:	0f b6 12             	movzbl (%edx),%edx
80104ca9:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104cab:	8b 45 10             	mov    0x10(%ebp),%eax
80104cae:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cb1:	89 55 10             	mov    %edx,0x10(%ebp)
80104cb4:	85 c0                	test   %eax,%eax
80104cb6:	75 dc                	jne    80104c94 <memmove+0x57>

  return dst;
80104cb8:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104cbb:	c9                   	leave  
80104cbc:	c3                   	ret    

80104cbd <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104cbd:	55                   	push   %ebp
80104cbe:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104cc0:	ff 75 10             	push   0x10(%ebp)
80104cc3:	ff 75 0c             	push   0xc(%ebp)
80104cc6:	ff 75 08             	push   0x8(%ebp)
80104cc9:	e8 6f ff ff ff       	call   80104c3d <memmove>
80104cce:	83 c4 0c             	add    $0xc,%esp
}
80104cd1:	c9                   	leave  
80104cd2:	c3                   	ret    

80104cd3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104cd3:	55                   	push   %ebp
80104cd4:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104cd6:	eb 0c                	jmp    80104ce4 <strncmp+0x11>
    n--, p++, q++;
80104cd8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104cdc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ce0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104ce4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ce8:	74 1a                	je     80104d04 <strncmp+0x31>
80104cea:	8b 45 08             	mov    0x8(%ebp),%eax
80104ced:	0f b6 00             	movzbl (%eax),%eax
80104cf0:	84 c0                	test   %al,%al
80104cf2:	74 10                	je     80104d04 <strncmp+0x31>
80104cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf7:	0f b6 10             	movzbl (%eax),%edx
80104cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cfd:	0f b6 00             	movzbl (%eax),%eax
80104d00:	38 c2                	cmp    %al,%dl
80104d02:	74 d4                	je     80104cd8 <strncmp+0x5>
  if(n == 0)
80104d04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d08:	75 07                	jne    80104d11 <strncmp+0x3e>
    return 0;
80104d0a:	b8 00 00 00 00       	mov    $0x0,%eax
80104d0f:	eb 16                	jmp    80104d27 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104d11:	8b 45 08             	mov    0x8(%ebp),%eax
80104d14:	0f b6 00             	movzbl (%eax),%eax
80104d17:	0f b6 d0             	movzbl %al,%edx
80104d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d1d:	0f b6 00             	movzbl (%eax),%eax
80104d20:	0f b6 c8             	movzbl %al,%ecx
80104d23:	89 d0                	mov    %edx,%eax
80104d25:	29 c8                	sub    %ecx,%eax
}
80104d27:	5d                   	pop    %ebp
80104d28:	c3                   	ret    

80104d29 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104d29:	55                   	push   %ebp
80104d2a:	89 e5                	mov    %esp,%ebp
80104d2c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d32:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104d35:	90                   	nop
80104d36:	8b 45 10             	mov    0x10(%ebp),%eax
80104d39:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d3c:	89 55 10             	mov    %edx,0x10(%ebp)
80104d3f:	85 c0                	test   %eax,%eax
80104d41:	7e 2c                	jle    80104d6f <strncpy+0x46>
80104d43:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d46:	8d 42 01             	lea    0x1(%edx),%eax
80104d49:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4f:	8d 48 01             	lea    0x1(%eax),%ecx
80104d52:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d55:	0f b6 12             	movzbl (%edx),%edx
80104d58:	88 10                	mov    %dl,(%eax)
80104d5a:	0f b6 00             	movzbl (%eax),%eax
80104d5d:	84 c0                	test   %al,%al
80104d5f:	75 d5                	jne    80104d36 <strncpy+0xd>
    ;
  while(n-- > 0)
80104d61:	eb 0c                	jmp    80104d6f <strncpy+0x46>
    *s++ = 0;
80104d63:	8b 45 08             	mov    0x8(%ebp),%eax
80104d66:	8d 50 01             	lea    0x1(%eax),%edx
80104d69:	89 55 08             	mov    %edx,0x8(%ebp)
80104d6c:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104d6f:	8b 45 10             	mov    0x10(%ebp),%eax
80104d72:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d75:	89 55 10             	mov    %edx,0x10(%ebp)
80104d78:	85 c0                	test   %eax,%eax
80104d7a:	7f e7                	jg     80104d63 <strncpy+0x3a>
  return os;
80104d7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d7f:	c9                   	leave  
80104d80:	c3                   	ret    

80104d81 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104d81:	55                   	push   %ebp
80104d82:	89 e5                	mov    %esp,%ebp
80104d84:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d87:	8b 45 08             	mov    0x8(%ebp),%eax
80104d8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104d8d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d91:	7f 05                	jg     80104d98 <safestrcpy+0x17>
    return os;
80104d93:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d96:	eb 32                	jmp    80104dca <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104d98:	90                   	nop
80104d99:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104d9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104da1:	7e 1e                	jle    80104dc1 <safestrcpy+0x40>
80104da3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104da6:	8d 42 01             	lea    0x1(%edx),%eax
80104da9:	89 45 0c             	mov    %eax,0xc(%ebp)
80104dac:	8b 45 08             	mov    0x8(%ebp),%eax
80104daf:	8d 48 01             	lea    0x1(%eax),%ecx
80104db2:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104db5:	0f b6 12             	movzbl (%edx),%edx
80104db8:	88 10                	mov    %dl,(%eax)
80104dba:	0f b6 00             	movzbl (%eax),%eax
80104dbd:	84 c0                	test   %al,%al
80104dbf:	75 d8                	jne    80104d99 <safestrcpy+0x18>
    ;
  *s = 0;
80104dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc4:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104dc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104dca:	c9                   	leave  
80104dcb:	c3                   	ret    

80104dcc <strlen>:

int
strlen(const char *s)
{
80104dcc:	55                   	push   %ebp
80104dcd:	89 e5                	mov    %esp,%ebp
80104dcf:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104dd2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104dd9:	eb 04                	jmp    80104ddf <strlen+0x13>
80104ddb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ddf:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104de2:	8b 45 08             	mov    0x8(%ebp),%eax
80104de5:	01 d0                	add    %edx,%eax
80104de7:	0f b6 00             	movzbl (%eax),%eax
80104dea:	84 c0                	test   %al,%al
80104dec:	75 ed                	jne    80104ddb <strlen+0xf>
    ;
  return n;
80104dee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104df1:	c9                   	leave  
80104df2:	c3                   	ret    

80104df3 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104df7:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104dfb:	55                   	push   %ebp
  pushl %ebx
80104dfc:	53                   	push   %ebx
  pushl %esi
80104dfd:	56                   	push   %esi
  pushl %edi
80104dfe:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104dff:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104e01:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104e03:	5f                   	pop    %edi
  popl %esi
80104e04:	5e                   	pop    %esi
  popl %ebx
80104e05:	5b                   	pop    %ebx
  popl %ebp
80104e06:	5d                   	pop    %ebp
  ret
80104e07:	c3                   	ret    

80104e08 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e08:	55                   	push   %ebp
80104e09:	89 e5                	mov    %esp,%ebp
80104e0b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104e0e:	e8 1d ec ff ff       	call   80103a30 <myproc>
80104e13:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e19:	8b 00                	mov    (%eax),%eax
80104e1b:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e1e:	73 0f                	jae    80104e2f <fetchint+0x27>
80104e20:	8b 45 08             	mov    0x8(%ebp),%eax
80104e23:	8d 50 04             	lea    0x4(%eax),%edx
80104e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e29:	8b 00                	mov    (%eax),%eax
80104e2b:	39 c2                	cmp    %eax,%edx
80104e2d:	76 07                	jbe    80104e36 <fetchint+0x2e>
    return -1;
80104e2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e34:	eb 0f                	jmp    80104e45 <fetchint+0x3d>
  *ip = *(int*)(addr);
80104e36:	8b 45 08             	mov    0x8(%ebp),%eax
80104e39:	8b 10                	mov    (%eax),%edx
80104e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e3e:	89 10                	mov    %edx,(%eax)
  return 0;
80104e40:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e45:	c9                   	leave  
80104e46:	c3                   	ret    

80104e47 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104e47:	55                   	push   %ebp
80104e48:	89 e5                	mov    %esp,%ebp
80104e4a:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104e4d:	e8 de eb ff ff       	call   80103a30 <myproc>
80104e52:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e58:	8b 00                	mov    (%eax),%eax
80104e5a:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e5d:	72 07                	jb     80104e66 <fetchstr+0x1f>
    return -1;
80104e5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e64:	eb 41                	jmp    80104ea7 <fetchstr+0x60>
  *pp = (char*)addr;
80104e66:	8b 55 08             	mov    0x8(%ebp),%edx
80104e69:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e6c:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e71:	8b 00                	mov    (%eax),%eax
80104e73:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104e76:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e79:	8b 00                	mov    (%eax),%eax
80104e7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e7e:	eb 1a                	jmp    80104e9a <fetchstr+0x53>
    if(*s == 0)
80104e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e83:	0f b6 00             	movzbl (%eax),%eax
80104e86:	84 c0                	test   %al,%al
80104e88:	75 0c                	jne    80104e96 <fetchstr+0x4f>
      return s - *pp;
80104e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8d:	8b 10                	mov    (%eax),%edx
80104e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e92:	29 d0                	sub    %edx,%eax
80104e94:	eb 11                	jmp    80104ea7 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104e96:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104ea0:	72 de                	jb     80104e80 <fetchstr+0x39>
  }
  return -1;
80104ea2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ea7:	c9                   	leave  
80104ea8:	c3                   	ret    

80104ea9 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104ea9:	55                   	push   %ebp
80104eaa:	89 e5                	mov    %esp,%ebp
80104eac:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104eaf:	e8 7c eb ff ff       	call   80103a30 <myproc>
80104eb4:	8b 40 18             	mov    0x18(%eax),%eax
80104eb7:	8b 50 44             	mov    0x44(%eax),%edx
80104eba:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebd:	c1 e0 02             	shl    $0x2,%eax
80104ec0:	01 d0                	add    %edx,%eax
80104ec2:	83 c0 04             	add    $0x4,%eax
80104ec5:	83 ec 08             	sub    $0x8,%esp
80104ec8:	ff 75 0c             	push   0xc(%ebp)
80104ecb:	50                   	push   %eax
80104ecc:	e8 37 ff ff ff       	call   80104e08 <fetchint>
80104ed1:	83 c4 10             	add    $0x10,%esp
}
80104ed4:	c9                   	leave  
80104ed5:	c3                   	ret    

80104ed6 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104ed6:	55                   	push   %ebp
80104ed7:	89 e5                	mov    %esp,%ebp
80104ed9:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104edc:	e8 4f eb ff ff       	call   80103a30 <myproc>
80104ee1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104ee4:	83 ec 08             	sub    $0x8,%esp
80104ee7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104eea:	50                   	push   %eax
80104eeb:	ff 75 08             	push   0x8(%ebp)
80104eee:	e8 b6 ff ff ff       	call   80104ea9 <argint>
80104ef3:	83 c4 10             	add    $0x10,%esp
80104ef6:	85 c0                	test   %eax,%eax
80104ef8:	79 07                	jns    80104f01 <argptr+0x2b>
    return -1;
80104efa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eff:	eb 3b                	jmp    80104f3c <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104f01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f05:	78 1f                	js     80104f26 <argptr+0x50>
80104f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0a:	8b 00                	mov    (%eax),%eax
80104f0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f0f:	39 d0                	cmp    %edx,%eax
80104f11:	76 13                	jbe    80104f26 <argptr+0x50>
80104f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f16:	89 c2                	mov    %eax,%edx
80104f18:	8b 45 10             	mov    0x10(%ebp),%eax
80104f1b:	01 c2                	add    %eax,%edx
80104f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f20:	8b 00                	mov    (%eax),%eax
80104f22:	39 c2                	cmp    %eax,%edx
80104f24:	76 07                	jbe    80104f2d <argptr+0x57>
    return -1;
80104f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f2b:	eb 0f                	jmp    80104f3c <argptr+0x66>
  *pp = (char*)i;
80104f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f30:	89 c2                	mov    %eax,%edx
80104f32:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f35:	89 10                	mov    %edx,(%eax)
  return 0;
80104f37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f3c:	c9                   	leave  
80104f3d:	c3                   	ret    

80104f3e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104f3e:	55                   	push   %ebp
80104f3f:	89 e5                	mov    %esp,%ebp
80104f41:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104f44:	83 ec 08             	sub    $0x8,%esp
80104f47:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f4a:	50                   	push   %eax
80104f4b:	ff 75 08             	push   0x8(%ebp)
80104f4e:	e8 56 ff ff ff       	call   80104ea9 <argint>
80104f53:	83 c4 10             	add    $0x10,%esp
80104f56:	85 c0                	test   %eax,%eax
80104f58:	79 07                	jns    80104f61 <argstr+0x23>
    return -1;
80104f5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f5f:	eb 12                	jmp    80104f73 <argstr+0x35>
  return fetchstr(addr, pp);
80104f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f64:	83 ec 08             	sub    $0x8,%esp
80104f67:	ff 75 0c             	push   0xc(%ebp)
80104f6a:	50                   	push   %eax
80104f6b:	e8 d7 fe ff ff       	call   80104e47 <fetchstr>
80104f70:	83 c4 10             	add    $0x10,%esp
}
80104f73:	c9                   	leave  
80104f74:	c3                   	ret    

80104f75 <syscall>:

};

void
syscall(void)
{
80104f75:	55                   	push   %ebp
80104f76:	89 e5                	mov    %esp,%ebp
80104f78:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104f7b:	e8 b0 ea ff ff       	call   80103a30 <myproc>
80104f80:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f86:	8b 40 18             	mov    0x18(%eax),%eax
80104f89:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104f8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f93:	7e 2f                	jle    80104fc4 <syscall+0x4f>
80104f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f98:	83 f8 17             	cmp    $0x17,%eax
80104f9b:	77 27                	ja     80104fc4 <syscall+0x4f>
80104f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa0:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104fa7:	85 c0                	test   %eax,%eax
80104fa9:	74 19                	je     80104fc4 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fae:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104fb5:	ff d0                	call   *%eax
80104fb7:	89 c2                	mov    %eax,%edx
80104fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fbc:	8b 40 18             	mov    0x18(%eax),%eax
80104fbf:	89 50 1c             	mov    %edx,0x1c(%eax)
80104fc2:	eb 2c                	jmp    80104ff0 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc7:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcd:	8b 40 10             	mov    0x10(%eax),%eax
80104fd0:	ff 75 f0             	push   -0x10(%ebp)
80104fd3:	52                   	push   %edx
80104fd4:	50                   	push   %eax
80104fd5:	68 98 a7 10 80       	push   $0x8010a798
80104fda:	e8 15 b4 ff ff       	call   801003f4 <cprintf>
80104fdf:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe5:	8b 40 18             	mov    0x18(%eax),%eax
80104fe8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104fef:	90                   	nop
80104ff0:	90                   	nop
80104ff1:	c9                   	leave  
80104ff2:	c3                   	ret    

80104ff3 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104ff3:	55                   	push   %ebp
80104ff4:	89 e5                	mov    %esp,%ebp
80104ff6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104ff9:	83 ec 08             	sub    $0x8,%esp
80104ffc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fff:	50                   	push   %eax
80105000:	ff 75 08             	push   0x8(%ebp)
80105003:	e8 a1 fe ff ff       	call   80104ea9 <argint>
80105008:	83 c4 10             	add    $0x10,%esp
8010500b:	85 c0                	test   %eax,%eax
8010500d:	79 07                	jns    80105016 <argfd+0x23>
    return -1;
8010500f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105014:	eb 4f                	jmp    80105065 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105016:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105019:	85 c0                	test   %eax,%eax
8010501b:	78 20                	js     8010503d <argfd+0x4a>
8010501d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105020:	83 f8 0f             	cmp    $0xf,%eax
80105023:	7f 18                	jg     8010503d <argfd+0x4a>
80105025:	e8 06 ea ff ff       	call   80103a30 <myproc>
8010502a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010502d:	83 c2 08             	add    $0x8,%edx
80105030:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105034:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105037:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010503b:	75 07                	jne    80105044 <argfd+0x51>
    return -1;
8010503d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105042:	eb 21                	jmp    80105065 <argfd+0x72>
  if(pfd)
80105044:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105048:	74 08                	je     80105052 <argfd+0x5f>
    *pfd = fd;
8010504a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010504d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105050:	89 10                	mov    %edx,(%eax)
  if(pf)
80105052:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105056:	74 08                	je     80105060 <argfd+0x6d>
    *pf = f;
80105058:	8b 45 10             	mov    0x10(%ebp),%eax
8010505b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010505e:	89 10                	mov    %edx,(%eax)
  return 0;
80105060:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105065:	c9                   	leave  
80105066:	c3                   	ret    

80105067 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105067:	55                   	push   %ebp
80105068:	89 e5                	mov    %esp,%ebp
8010506a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010506d:	e8 be e9 ff ff       	call   80103a30 <myproc>
80105072:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105075:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010507c:	eb 2a                	jmp    801050a8 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
8010507e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105081:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105084:	83 c2 08             	add    $0x8,%edx
80105087:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010508b:	85 c0                	test   %eax,%eax
8010508d:	75 15                	jne    801050a4 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
8010508f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105092:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105095:	8d 4a 08             	lea    0x8(%edx),%ecx
80105098:	8b 55 08             	mov    0x8(%ebp),%edx
8010509b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010509f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a2:	eb 0f                	jmp    801050b3 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801050a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050a8:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801050ac:	7e d0                	jle    8010507e <fdalloc+0x17>
    }
  }
  return -1;
801050ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050b3:	c9                   	leave  
801050b4:	c3                   	ret    

801050b5 <sys_dup>:

int
sys_dup(void)
{
801050b5:	55                   	push   %ebp
801050b6:	89 e5                	mov    %esp,%ebp
801050b8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801050bb:	83 ec 04             	sub    $0x4,%esp
801050be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050c1:	50                   	push   %eax
801050c2:	6a 00                	push   $0x0
801050c4:	6a 00                	push   $0x0
801050c6:	e8 28 ff ff ff       	call   80104ff3 <argfd>
801050cb:	83 c4 10             	add    $0x10,%esp
801050ce:	85 c0                	test   %eax,%eax
801050d0:	79 07                	jns    801050d9 <sys_dup+0x24>
    return -1;
801050d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d7:	eb 31                	jmp    8010510a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801050d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050dc:	83 ec 0c             	sub    $0xc,%esp
801050df:	50                   	push   %eax
801050e0:	e8 82 ff ff ff       	call   80105067 <fdalloc>
801050e5:	83 c4 10             	add    $0x10,%esp
801050e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050ef:	79 07                	jns    801050f8 <sys_dup+0x43>
    return -1;
801050f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050f6:	eb 12                	jmp    8010510a <sys_dup+0x55>
  filedup(f);
801050f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050fb:	83 ec 0c             	sub    $0xc,%esp
801050fe:	50                   	push   %eax
801050ff:	e8 46 bf ff ff       	call   8010104a <filedup>
80105104:	83 c4 10             	add    $0x10,%esp
  return fd;
80105107:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010510a:	c9                   	leave  
8010510b:	c3                   	ret    

8010510c <sys_read>:

int
sys_read(void)
{
8010510c:	55                   	push   %ebp
8010510d:	89 e5                	mov    %esp,%ebp
8010510f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105112:	83 ec 04             	sub    $0x4,%esp
80105115:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105118:	50                   	push   %eax
80105119:	6a 00                	push   $0x0
8010511b:	6a 00                	push   $0x0
8010511d:	e8 d1 fe ff ff       	call   80104ff3 <argfd>
80105122:	83 c4 10             	add    $0x10,%esp
80105125:	85 c0                	test   %eax,%eax
80105127:	78 2e                	js     80105157 <sys_read+0x4b>
80105129:	83 ec 08             	sub    $0x8,%esp
8010512c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010512f:	50                   	push   %eax
80105130:	6a 02                	push   $0x2
80105132:	e8 72 fd ff ff       	call   80104ea9 <argint>
80105137:	83 c4 10             	add    $0x10,%esp
8010513a:	85 c0                	test   %eax,%eax
8010513c:	78 19                	js     80105157 <sys_read+0x4b>
8010513e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105141:	83 ec 04             	sub    $0x4,%esp
80105144:	50                   	push   %eax
80105145:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105148:	50                   	push   %eax
80105149:	6a 01                	push   $0x1
8010514b:	e8 86 fd ff ff       	call   80104ed6 <argptr>
80105150:	83 c4 10             	add    $0x10,%esp
80105153:	85 c0                	test   %eax,%eax
80105155:	79 07                	jns    8010515e <sys_read+0x52>
    return -1;
80105157:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010515c:	eb 17                	jmp    80105175 <sys_read+0x69>
  return fileread(f, p, n);
8010515e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105161:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105167:	83 ec 04             	sub    $0x4,%esp
8010516a:	51                   	push   %ecx
8010516b:	52                   	push   %edx
8010516c:	50                   	push   %eax
8010516d:	e8 68 c0 ff ff       	call   801011da <fileread>
80105172:	83 c4 10             	add    $0x10,%esp
}
80105175:	c9                   	leave  
80105176:	c3                   	ret    

80105177 <sys_write>:

int
sys_write(void)
{
80105177:	55                   	push   %ebp
80105178:	89 e5                	mov    %esp,%ebp
8010517a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010517d:	83 ec 04             	sub    $0x4,%esp
80105180:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105183:	50                   	push   %eax
80105184:	6a 00                	push   $0x0
80105186:	6a 00                	push   $0x0
80105188:	e8 66 fe ff ff       	call   80104ff3 <argfd>
8010518d:	83 c4 10             	add    $0x10,%esp
80105190:	85 c0                	test   %eax,%eax
80105192:	78 2e                	js     801051c2 <sys_write+0x4b>
80105194:	83 ec 08             	sub    $0x8,%esp
80105197:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010519a:	50                   	push   %eax
8010519b:	6a 02                	push   $0x2
8010519d:	e8 07 fd ff ff       	call   80104ea9 <argint>
801051a2:	83 c4 10             	add    $0x10,%esp
801051a5:	85 c0                	test   %eax,%eax
801051a7:	78 19                	js     801051c2 <sys_write+0x4b>
801051a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ac:	83 ec 04             	sub    $0x4,%esp
801051af:	50                   	push   %eax
801051b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801051b3:	50                   	push   %eax
801051b4:	6a 01                	push   $0x1
801051b6:	e8 1b fd ff ff       	call   80104ed6 <argptr>
801051bb:	83 c4 10             	add    $0x10,%esp
801051be:	85 c0                	test   %eax,%eax
801051c0:	79 07                	jns    801051c9 <sys_write+0x52>
    return -1;
801051c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051c7:	eb 17                	jmp    801051e0 <sys_write+0x69>
  return filewrite(f, p, n);
801051c9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801051cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d2:	83 ec 04             	sub    $0x4,%esp
801051d5:	51                   	push   %ecx
801051d6:	52                   	push   %edx
801051d7:	50                   	push   %eax
801051d8:	e8 b5 c0 ff ff       	call   80101292 <filewrite>
801051dd:	83 c4 10             	add    $0x10,%esp
}
801051e0:	c9                   	leave  
801051e1:	c3                   	ret    

801051e2 <sys_close>:

int
sys_close(void)
{
801051e2:	55                   	push   %ebp
801051e3:	89 e5                	mov    %esp,%ebp
801051e5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801051e8:	83 ec 04             	sub    $0x4,%esp
801051eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051ee:	50                   	push   %eax
801051ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051f2:	50                   	push   %eax
801051f3:	6a 00                	push   $0x0
801051f5:	e8 f9 fd ff ff       	call   80104ff3 <argfd>
801051fa:	83 c4 10             	add    $0x10,%esp
801051fd:	85 c0                	test   %eax,%eax
801051ff:	79 07                	jns    80105208 <sys_close+0x26>
    return -1;
80105201:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105206:	eb 27                	jmp    8010522f <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105208:	e8 23 e8 ff ff       	call   80103a30 <myproc>
8010520d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105210:	83 c2 08             	add    $0x8,%edx
80105213:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010521a:	00 
  fileclose(f);
8010521b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521e:	83 ec 0c             	sub    $0xc,%esp
80105221:	50                   	push   %eax
80105222:	e8 74 be ff ff       	call   8010109b <fileclose>
80105227:	83 c4 10             	add    $0x10,%esp
  return 0;
8010522a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010522f:	c9                   	leave  
80105230:	c3                   	ret    

80105231 <sys_fstat>:

int
sys_fstat(void)
{
80105231:	55                   	push   %ebp
80105232:	89 e5                	mov    %esp,%ebp
80105234:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105237:	83 ec 04             	sub    $0x4,%esp
8010523a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010523d:	50                   	push   %eax
8010523e:	6a 00                	push   $0x0
80105240:	6a 00                	push   $0x0
80105242:	e8 ac fd ff ff       	call   80104ff3 <argfd>
80105247:	83 c4 10             	add    $0x10,%esp
8010524a:	85 c0                	test   %eax,%eax
8010524c:	78 17                	js     80105265 <sys_fstat+0x34>
8010524e:	83 ec 04             	sub    $0x4,%esp
80105251:	6a 14                	push   $0x14
80105253:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105256:	50                   	push   %eax
80105257:	6a 01                	push   $0x1
80105259:	e8 78 fc ff ff       	call   80104ed6 <argptr>
8010525e:	83 c4 10             	add    $0x10,%esp
80105261:	85 c0                	test   %eax,%eax
80105263:	79 07                	jns    8010526c <sys_fstat+0x3b>
    return -1;
80105265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010526a:	eb 13                	jmp    8010527f <sys_fstat+0x4e>
  return filestat(f, st);
8010526c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010526f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105272:	83 ec 08             	sub    $0x8,%esp
80105275:	52                   	push   %edx
80105276:	50                   	push   %eax
80105277:	e8 07 bf ff ff       	call   80101183 <filestat>
8010527c:	83 c4 10             	add    $0x10,%esp
}
8010527f:	c9                   	leave  
80105280:	c3                   	ret    

80105281 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105281:	55                   	push   %ebp
80105282:	89 e5                	mov    %esp,%ebp
80105284:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105287:	83 ec 08             	sub    $0x8,%esp
8010528a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010528d:	50                   	push   %eax
8010528e:	6a 00                	push   $0x0
80105290:	e8 a9 fc ff ff       	call   80104f3e <argstr>
80105295:	83 c4 10             	add    $0x10,%esp
80105298:	85 c0                	test   %eax,%eax
8010529a:	78 15                	js     801052b1 <sys_link+0x30>
8010529c:	83 ec 08             	sub    $0x8,%esp
8010529f:	8d 45 dc             	lea    -0x24(%ebp),%eax
801052a2:	50                   	push   %eax
801052a3:	6a 01                	push   $0x1
801052a5:	e8 94 fc ff ff       	call   80104f3e <argstr>
801052aa:	83 c4 10             	add    $0x10,%esp
801052ad:	85 c0                	test   %eax,%eax
801052af:	79 0a                	jns    801052bb <sys_link+0x3a>
    return -1;
801052b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b6:	e9 68 01 00 00       	jmp    80105423 <sys_link+0x1a2>

  begin_op();
801052bb:	e8 7c dd ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
801052c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801052c3:	83 ec 0c             	sub    $0xc,%esp
801052c6:	50                   	push   %eax
801052c7:	e8 51 d2 ff ff       	call   8010251d <namei>
801052cc:	83 c4 10             	add    $0x10,%esp
801052cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052d6:	75 0f                	jne    801052e7 <sys_link+0x66>
    end_op();
801052d8:	e8 eb dd ff ff       	call   801030c8 <end_op>
    return -1;
801052dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e2:	e9 3c 01 00 00       	jmp    80105423 <sys_link+0x1a2>
  }

  ilock(ip);
801052e7:	83 ec 0c             	sub    $0xc,%esp
801052ea:	ff 75 f4             	push   -0xc(%ebp)
801052ed:	e8 f8 c6 ff ff       	call   801019ea <ilock>
801052f2:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801052f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801052fc:	66 83 f8 01          	cmp    $0x1,%ax
80105300:	75 1d                	jne    8010531f <sys_link+0x9e>
    iunlockput(ip);
80105302:	83 ec 0c             	sub    $0xc,%esp
80105305:	ff 75 f4             	push   -0xc(%ebp)
80105308:	e8 0e c9 ff ff       	call   80101c1b <iunlockput>
8010530d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105310:	e8 b3 dd ff ff       	call   801030c8 <end_op>
    return -1;
80105315:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010531a:	e9 04 01 00 00       	jmp    80105423 <sys_link+0x1a2>
  }

  ip->nlink++;
8010531f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105322:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105326:	83 c0 01             	add    $0x1,%eax
80105329:	89 c2                	mov    %eax,%edx
8010532b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010532e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105332:	83 ec 0c             	sub    $0xc,%esp
80105335:	ff 75 f4             	push   -0xc(%ebp)
80105338:	e8 d0 c4 ff ff       	call   8010180d <iupdate>
8010533d:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105340:	83 ec 0c             	sub    $0xc,%esp
80105343:	ff 75 f4             	push   -0xc(%ebp)
80105346:	e8 b2 c7 ff ff       	call   80101afd <iunlock>
8010534b:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010534e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105351:	83 ec 08             	sub    $0x8,%esp
80105354:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105357:	52                   	push   %edx
80105358:	50                   	push   %eax
80105359:	e8 db d1 ff ff       	call   80102539 <nameiparent>
8010535e:	83 c4 10             	add    $0x10,%esp
80105361:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105364:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105368:	74 71                	je     801053db <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010536a:	83 ec 0c             	sub    $0xc,%esp
8010536d:	ff 75 f0             	push   -0x10(%ebp)
80105370:	e8 75 c6 ff ff       	call   801019ea <ilock>
80105375:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010537b:	8b 10                	mov    (%eax),%edx
8010537d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105380:	8b 00                	mov    (%eax),%eax
80105382:	39 c2                	cmp    %eax,%edx
80105384:	75 1d                	jne    801053a3 <sys_link+0x122>
80105386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105389:	8b 40 04             	mov    0x4(%eax),%eax
8010538c:	83 ec 04             	sub    $0x4,%esp
8010538f:	50                   	push   %eax
80105390:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105393:	50                   	push   %eax
80105394:	ff 75 f0             	push   -0x10(%ebp)
80105397:	e8 ea ce ff ff       	call   80102286 <dirlink>
8010539c:	83 c4 10             	add    $0x10,%esp
8010539f:	85 c0                	test   %eax,%eax
801053a1:	79 10                	jns    801053b3 <sys_link+0x132>
    iunlockput(dp);
801053a3:	83 ec 0c             	sub    $0xc,%esp
801053a6:	ff 75 f0             	push   -0x10(%ebp)
801053a9:	e8 6d c8 ff ff       	call   80101c1b <iunlockput>
801053ae:	83 c4 10             	add    $0x10,%esp
    goto bad;
801053b1:	eb 29                	jmp    801053dc <sys_link+0x15b>
  }
  iunlockput(dp);
801053b3:	83 ec 0c             	sub    $0xc,%esp
801053b6:	ff 75 f0             	push   -0x10(%ebp)
801053b9:	e8 5d c8 ff ff       	call   80101c1b <iunlockput>
801053be:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801053c1:	83 ec 0c             	sub    $0xc,%esp
801053c4:	ff 75 f4             	push   -0xc(%ebp)
801053c7:	e8 7f c7 ff ff       	call   80101b4b <iput>
801053cc:	83 c4 10             	add    $0x10,%esp

  end_op();
801053cf:	e8 f4 dc ff ff       	call   801030c8 <end_op>

  return 0;
801053d4:	b8 00 00 00 00       	mov    $0x0,%eax
801053d9:	eb 48                	jmp    80105423 <sys_link+0x1a2>
    goto bad;
801053db:	90                   	nop

bad:
  ilock(ip);
801053dc:	83 ec 0c             	sub    $0xc,%esp
801053df:	ff 75 f4             	push   -0xc(%ebp)
801053e2:	e8 03 c6 ff ff       	call   801019ea <ilock>
801053e7:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801053ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ed:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801053f1:	83 e8 01             	sub    $0x1,%eax
801053f4:	89 c2                	mov    %eax,%edx
801053f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f9:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801053fd:	83 ec 0c             	sub    $0xc,%esp
80105400:	ff 75 f4             	push   -0xc(%ebp)
80105403:	e8 05 c4 ff ff       	call   8010180d <iupdate>
80105408:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010540b:	83 ec 0c             	sub    $0xc,%esp
8010540e:	ff 75 f4             	push   -0xc(%ebp)
80105411:	e8 05 c8 ff ff       	call   80101c1b <iunlockput>
80105416:	83 c4 10             	add    $0x10,%esp
  end_op();
80105419:	e8 aa dc ff ff       	call   801030c8 <end_op>
  return -1;
8010541e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105423:	c9                   	leave  
80105424:	c3                   	ret    

80105425 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105425:	55                   	push   %ebp
80105426:	89 e5                	mov    %esp,%ebp
80105428:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010542b:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105432:	eb 40                	jmp    80105474 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105437:	6a 10                	push   $0x10
80105439:	50                   	push   %eax
8010543a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010543d:	50                   	push   %eax
8010543e:	ff 75 08             	push   0x8(%ebp)
80105441:	e8 90 ca ff ff       	call   80101ed6 <readi>
80105446:	83 c4 10             	add    $0x10,%esp
80105449:	83 f8 10             	cmp    $0x10,%eax
8010544c:	74 0d                	je     8010545b <isdirempty+0x36>
      panic("isdirempty: readi");
8010544e:	83 ec 0c             	sub    $0xc,%esp
80105451:	68 b4 a7 10 80       	push   $0x8010a7b4
80105456:	e8 4e b1 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010545b:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010545f:	66 85 c0             	test   %ax,%ax
80105462:	74 07                	je     8010546b <isdirempty+0x46>
      return 0;
80105464:	b8 00 00 00 00       	mov    $0x0,%eax
80105469:	eb 1b                	jmp    80105486 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010546b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010546e:	83 c0 10             	add    $0x10,%eax
80105471:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105474:	8b 45 08             	mov    0x8(%ebp),%eax
80105477:	8b 50 58             	mov    0x58(%eax),%edx
8010547a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010547d:	39 c2                	cmp    %eax,%edx
8010547f:	77 b3                	ja     80105434 <isdirempty+0xf>
  }
  return 1;
80105481:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105486:	c9                   	leave  
80105487:	c3                   	ret    

80105488 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105488:	55                   	push   %ebp
80105489:	89 e5                	mov    %esp,%ebp
8010548b:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010548e:	83 ec 08             	sub    $0x8,%esp
80105491:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105494:	50                   	push   %eax
80105495:	6a 00                	push   $0x0
80105497:	e8 a2 fa ff ff       	call   80104f3e <argstr>
8010549c:	83 c4 10             	add    $0x10,%esp
8010549f:	85 c0                	test   %eax,%eax
801054a1:	79 0a                	jns    801054ad <sys_unlink+0x25>
    return -1;
801054a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a8:	e9 bf 01 00 00       	jmp    8010566c <sys_unlink+0x1e4>

  begin_op();
801054ad:	e8 8a db ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801054b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801054b5:	83 ec 08             	sub    $0x8,%esp
801054b8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801054bb:	52                   	push   %edx
801054bc:	50                   	push   %eax
801054bd:	e8 77 d0 ff ff       	call   80102539 <nameiparent>
801054c2:	83 c4 10             	add    $0x10,%esp
801054c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054cc:	75 0f                	jne    801054dd <sys_unlink+0x55>
    end_op();
801054ce:	e8 f5 db ff ff       	call   801030c8 <end_op>
    return -1;
801054d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054d8:	e9 8f 01 00 00       	jmp    8010566c <sys_unlink+0x1e4>
  }

  ilock(dp);
801054dd:	83 ec 0c             	sub    $0xc,%esp
801054e0:	ff 75 f4             	push   -0xc(%ebp)
801054e3:	e8 02 c5 ff ff       	call   801019ea <ilock>
801054e8:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801054eb:	83 ec 08             	sub    $0x8,%esp
801054ee:	68 c6 a7 10 80       	push   $0x8010a7c6
801054f3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801054f6:	50                   	push   %eax
801054f7:	e8 b5 cc ff ff       	call   801021b1 <namecmp>
801054fc:	83 c4 10             	add    $0x10,%esp
801054ff:	85 c0                	test   %eax,%eax
80105501:	0f 84 49 01 00 00    	je     80105650 <sys_unlink+0x1c8>
80105507:	83 ec 08             	sub    $0x8,%esp
8010550a:	68 c8 a7 10 80       	push   $0x8010a7c8
8010550f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105512:	50                   	push   %eax
80105513:	e8 99 cc ff ff       	call   801021b1 <namecmp>
80105518:	83 c4 10             	add    $0x10,%esp
8010551b:	85 c0                	test   %eax,%eax
8010551d:	0f 84 2d 01 00 00    	je     80105650 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105523:	83 ec 04             	sub    $0x4,%esp
80105526:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105529:	50                   	push   %eax
8010552a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010552d:	50                   	push   %eax
8010552e:	ff 75 f4             	push   -0xc(%ebp)
80105531:	e8 96 cc ff ff       	call   801021cc <dirlookup>
80105536:	83 c4 10             	add    $0x10,%esp
80105539:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010553c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105540:	0f 84 0d 01 00 00    	je     80105653 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105546:	83 ec 0c             	sub    $0xc,%esp
80105549:	ff 75 f0             	push   -0x10(%ebp)
8010554c:	e8 99 c4 ff ff       	call   801019ea <ilock>
80105551:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105554:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105557:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010555b:	66 85 c0             	test   %ax,%ax
8010555e:	7f 0d                	jg     8010556d <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105560:	83 ec 0c             	sub    $0xc,%esp
80105563:	68 cb a7 10 80       	push   $0x8010a7cb
80105568:	e8 3c b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010556d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105570:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105574:	66 83 f8 01          	cmp    $0x1,%ax
80105578:	75 25                	jne    8010559f <sys_unlink+0x117>
8010557a:	83 ec 0c             	sub    $0xc,%esp
8010557d:	ff 75 f0             	push   -0x10(%ebp)
80105580:	e8 a0 fe ff ff       	call   80105425 <isdirempty>
80105585:	83 c4 10             	add    $0x10,%esp
80105588:	85 c0                	test   %eax,%eax
8010558a:	75 13                	jne    8010559f <sys_unlink+0x117>
    iunlockput(ip);
8010558c:	83 ec 0c             	sub    $0xc,%esp
8010558f:	ff 75 f0             	push   -0x10(%ebp)
80105592:	e8 84 c6 ff ff       	call   80101c1b <iunlockput>
80105597:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010559a:	e9 b5 00 00 00       	jmp    80105654 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
8010559f:	83 ec 04             	sub    $0x4,%esp
801055a2:	6a 10                	push   $0x10
801055a4:	6a 00                	push   $0x0
801055a6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801055a9:	50                   	push   %eax
801055aa:	e8 cf f5 ff ff       	call   80104b7e <memset>
801055af:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801055b2:	8b 45 c8             	mov    -0x38(%ebp),%eax
801055b5:	6a 10                	push   $0x10
801055b7:	50                   	push   %eax
801055b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801055bb:	50                   	push   %eax
801055bc:	ff 75 f4             	push   -0xc(%ebp)
801055bf:	e8 67 ca ff ff       	call   8010202b <writei>
801055c4:	83 c4 10             	add    $0x10,%esp
801055c7:	83 f8 10             	cmp    $0x10,%eax
801055ca:	74 0d                	je     801055d9 <sys_unlink+0x151>
    panic("unlink: writei");
801055cc:	83 ec 0c             	sub    $0xc,%esp
801055cf:	68 dd a7 10 80       	push   $0x8010a7dd
801055d4:	e8 d0 af ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801055d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055dc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055e0:	66 83 f8 01          	cmp    $0x1,%ax
801055e4:	75 21                	jne    80105607 <sys_unlink+0x17f>
    dp->nlink--;
801055e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055ed:	83 e8 01             	sub    $0x1,%eax
801055f0:	89 c2                	mov    %eax,%edx
801055f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f5:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801055f9:	83 ec 0c             	sub    $0xc,%esp
801055fc:	ff 75 f4             	push   -0xc(%ebp)
801055ff:	e8 09 c2 ff ff       	call   8010180d <iupdate>
80105604:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105607:	83 ec 0c             	sub    $0xc,%esp
8010560a:	ff 75 f4             	push   -0xc(%ebp)
8010560d:	e8 09 c6 ff ff       	call   80101c1b <iunlockput>
80105612:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105615:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105618:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010561c:	83 e8 01             	sub    $0x1,%eax
8010561f:	89 c2                	mov    %eax,%edx
80105621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105624:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105628:	83 ec 0c             	sub    $0xc,%esp
8010562b:	ff 75 f0             	push   -0x10(%ebp)
8010562e:	e8 da c1 ff ff       	call   8010180d <iupdate>
80105633:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105636:	83 ec 0c             	sub    $0xc,%esp
80105639:	ff 75 f0             	push   -0x10(%ebp)
8010563c:	e8 da c5 ff ff       	call   80101c1b <iunlockput>
80105641:	83 c4 10             	add    $0x10,%esp

  end_op();
80105644:	e8 7f da ff ff       	call   801030c8 <end_op>

  return 0;
80105649:	b8 00 00 00 00       	mov    $0x0,%eax
8010564e:	eb 1c                	jmp    8010566c <sys_unlink+0x1e4>
    goto bad;
80105650:	90                   	nop
80105651:	eb 01                	jmp    80105654 <sys_unlink+0x1cc>
    goto bad;
80105653:	90                   	nop

bad:
  iunlockput(dp);
80105654:	83 ec 0c             	sub    $0xc,%esp
80105657:	ff 75 f4             	push   -0xc(%ebp)
8010565a:	e8 bc c5 ff ff       	call   80101c1b <iunlockput>
8010565f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105662:	e8 61 da ff ff       	call   801030c8 <end_op>
  return -1;
80105667:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010566c:	c9                   	leave  
8010566d:	c3                   	ret    

8010566e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010566e:	55                   	push   %ebp
8010566f:	89 e5                	mov    %esp,%ebp
80105671:	83 ec 38             	sub    $0x38,%esp
80105674:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105677:	8b 55 10             	mov    0x10(%ebp),%edx
8010567a:	8b 45 14             	mov    0x14(%ebp),%eax
8010567d:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105681:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105685:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105689:	83 ec 08             	sub    $0x8,%esp
8010568c:	8d 45 de             	lea    -0x22(%ebp),%eax
8010568f:	50                   	push   %eax
80105690:	ff 75 08             	push   0x8(%ebp)
80105693:	e8 a1 ce ff ff       	call   80102539 <nameiparent>
80105698:	83 c4 10             	add    $0x10,%esp
8010569b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010569e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056a2:	75 0a                	jne    801056ae <create+0x40>
    return 0;
801056a4:	b8 00 00 00 00       	mov    $0x0,%eax
801056a9:	e9 90 01 00 00       	jmp    8010583e <create+0x1d0>
  ilock(dp);
801056ae:	83 ec 0c             	sub    $0xc,%esp
801056b1:	ff 75 f4             	push   -0xc(%ebp)
801056b4:	e8 31 c3 ff ff       	call   801019ea <ilock>
801056b9:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801056bc:	83 ec 04             	sub    $0x4,%esp
801056bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056c2:	50                   	push   %eax
801056c3:	8d 45 de             	lea    -0x22(%ebp),%eax
801056c6:	50                   	push   %eax
801056c7:	ff 75 f4             	push   -0xc(%ebp)
801056ca:	e8 fd ca ff ff       	call   801021cc <dirlookup>
801056cf:	83 c4 10             	add    $0x10,%esp
801056d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801056d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056d9:	74 50                	je     8010572b <create+0xbd>
    iunlockput(dp);
801056db:	83 ec 0c             	sub    $0xc,%esp
801056de:	ff 75 f4             	push   -0xc(%ebp)
801056e1:	e8 35 c5 ff ff       	call   80101c1b <iunlockput>
801056e6:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801056e9:	83 ec 0c             	sub    $0xc,%esp
801056ec:	ff 75 f0             	push   -0x10(%ebp)
801056ef:	e8 f6 c2 ff ff       	call   801019ea <ilock>
801056f4:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801056f7:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801056fc:	75 15                	jne    80105713 <create+0xa5>
801056fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105701:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105705:	66 83 f8 02          	cmp    $0x2,%ax
80105709:	75 08                	jne    80105713 <create+0xa5>
      return ip;
8010570b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010570e:	e9 2b 01 00 00       	jmp    8010583e <create+0x1d0>
    iunlockput(ip);
80105713:	83 ec 0c             	sub    $0xc,%esp
80105716:	ff 75 f0             	push   -0x10(%ebp)
80105719:	e8 fd c4 ff ff       	call   80101c1b <iunlockput>
8010571e:	83 c4 10             	add    $0x10,%esp
    return 0;
80105721:	b8 00 00 00 00       	mov    $0x0,%eax
80105726:	e9 13 01 00 00       	jmp    8010583e <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010572b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010572f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105732:	8b 00                	mov    (%eax),%eax
80105734:	83 ec 08             	sub    $0x8,%esp
80105737:	52                   	push   %edx
80105738:	50                   	push   %eax
80105739:	e8 f8 bf ff ff       	call   80101736 <ialloc>
8010573e:	83 c4 10             	add    $0x10,%esp
80105741:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105744:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105748:	75 0d                	jne    80105757 <create+0xe9>
    panic("create: ialloc");
8010574a:	83 ec 0c             	sub    $0xc,%esp
8010574d:	68 ec a7 10 80       	push   $0x8010a7ec
80105752:	e8 52 ae ff ff       	call   801005a9 <panic>

  ilock(ip);
80105757:	83 ec 0c             	sub    $0xc,%esp
8010575a:	ff 75 f0             	push   -0x10(%ebp)
8010575d:	e8 88 c2 ff ff       	call   801019ea <ilock>
80105762:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105768:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010576c:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105773:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105777:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010577b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010577e:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105784:	83 ec 0c             	sub    $0xc,%esp
80105787:	ff 75 f0             	push   -0x10(%ebp)
8010578a:	e8 7e c0 ff ff       	call   8010180d <iupdate>
8010578f:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105792:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105797:	75 6a                	jne    80105803 <create+0x195>
    dp->nlink++;  // for ".."
80105799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057a0:	83 c0 01             	add    $0x1,%eax
801057a3:	89 c2                	mov    %eax,%edx
801057a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a8:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801057ac:	83 ec 0c             	sub    $0xc,%esp
801057af:	ff 75 f4             	push   -0xc(%ebp)
801057b2:	e8 56 c0 ff ff       	call   8010180d <iupdate>
801057b7:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801057ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057bd:	8b 40 04             	mov    0x4(%eax),%eax
801057c0:	83 ec 04             	sub    $0x4,%esp
801057c3:	50                   	push   %eax
801057c4:	68 c6 a7 10 80       	push   $0x8010a7c6
801057c9:	ff 75 f0             	push   -0x10(%ebp)
801057cc:	e8 b5 ca ff ff       	call   80102286 <dirlink>
801057d1:	83 c4 10             	add    $0x10,%esp
801057d4:	85 c0                	test   %eax,%eax
801057d6:	78 1e                	js     801057f6 <create+0x188>
801057d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057db:	8b 40 04             	mov    0x4(%eax),%eax
801057de:	83 ec 04             	sub    $0x4,%esp
801057e1:	50                   	push   %eax
801057e2:	68 c8 a7 10 80       	push   $0x8010a7c8
801057e7:	ff 75 f0             	push   -0x10(%ebp)
801057ea:	e8 97 ca ff ff       	call   80102286 <dirlink>
801057ef:	83 c4 10             	add    $0x10,%esp
801057f2:	85 c0                	test   %eax,%eax
801057f4:	79 0d                	jns    80105803 <create+0x195>
      panic("create dots");
801057f6:	83 ec 0c             	sub    $0xc,%esp
801057f9:	68 fb a7 10 80       	push   $0x8010a7fb
801057fe:	e8 a6 ad ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105803:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105806:	8b 40 04             	mov    0x4(%eax),%eax
80105809:	83 ec 04             	sub    $0x4,%esp
8010580c:	50                   	push   %eax
8010580d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105810:	50                   	push   %eax
80105811:	ff 75 f4             	push   -0xc(%ebp)
80105814:	e8 6d ca ff ff       	call   80102286 <dirlink>
80105819:	83 c4 10             	add    $0x10,%esp
8010581c:	85 c0                	test   %eax,%eax
8010581e:	79 0d                	jns    8010582d <create+0x1bf>
    panic("create: dirlink");
80105820:	83 ec 0c             	sub    $0xc,%esp
80105823:	68 07 a8 10 80       	push   $0x8010a807
80105828:	e8 7c ad ff ff       	call   801005a9 <panic>

  iunlockput(dp);
8010582d:	83 ec 0c             	sub    $0xc,%esp
80105830:	ff 75 f4             	push   -0xc(%ebp)
80105833:	e8 e3 c3 ff ff       	call   80101c1b <iunlockput>
80105838:	83 c4 10             	add    $0x10,%esp

  return ip;
8010583b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010583e:	c9                   	leave  
8010583f:	c3                   	ret    

80105840 <sys_open>:

int
sys_open(void)
{
80105840:	55                   	push   %ebp
80105841:	89 e5                	mov    %esp,%ebp
80105843:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105846:	83 ec 08             	sub    $0x8,%esp
80105849:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010584c:	50                   	push   %eax
8010584d:	6a 00                	push   $0x0
8010584f:	e8 ea f6 ff ff       	call   80104f3e <argstr>
80105854:	83 c4 10             	add    $0x10,%esp
80105857:	85 c0                	test   %eax,%eax
80105859:	78 15                	js     80105870 <sys_open+0x30>
8010585b:	83 ec 08             	sub    $0x8,%esp
8010585e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105861:	50                   	push   %eax
80105862:	6a 01                	push   $0x1
80105864:	e8 40 f6 ff ff       	call   80104ea9 <argint>
80105869:	83 c4 10             	add    $0x10,%esp
8010586c:	85 c0                	test   %eax,%eax
8010586e:	79 0a                	jns    8010587a <sys_open+0x3a>
    return -1;
80105870:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105875:	e9 61 01 00 00       	jmp    801059db <sys_open+0x19b>

  begin_op();
8010587a:	e8 bd d7 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
8010587f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105882:	25 00 02 00 00       	and    $0x200,%eax
80105887:	85 c0                	test   %eax,%eax
80105889:	74 2a                	je     801058b5 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
8010588b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010588e:	6a 00                	push   $0x0
80105890:	6a 00                	push   $0x0
80105892:	6a 02                	push   $0x2
80105894:	50                   	push   %eax
80105895:	e8 d4 fd ff ff       	call   8010566e <create>
8010589a:	83 c4 10             	add    $0x10,%esp
8010589d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801058a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058a4:	75 75                	jne    8010591b <sys_open+0xdb>
      end_op();
801058a6:	e8 1d d8 ff ff       	call   801030c8 <end_op>
      return -1;
801058ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b0:	e9 26 01 00 00       	jmp    801059db <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801058b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058b8:	83 ec 0c             	sub    $0xc,%esp
801058bb:	50                   	push   %eax
801058bc:	e8 5c cc ff ff       	call   8010251d <namei>
801058c1:	83 c4 10             	add    $0x10,%esp
801058c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058cb:	75 0f                	jne    801058dc <sys_open+0x9c>
      end_op();
801058cd:	e8 f6 d7 ff ff       	call   801030c8 <end_op>
      return -1;
801058d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d7:	e9 ff 00 00 00       	jmp    801059db <sys_open+0x19b>
    }
    ilock(ip);
801058dc:	83 ec 0c             	sub    $0xc,%esp
801058df:	ff 75 f4             	push   -0xc(%ebp)
801058e2:	e8 03 c1 ff ff       	call   801019ea <ilock>
801058e7:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801058ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ed:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058f1:	66 83 f8 01          	cmp    $0x1,%ax
801058f5:	75 24                	jne    8010591b <sys_open+0xdb>
801058f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058fa:	85 c0                	test   %eax,%eax
801058fc:	74 1d                	je     8010591b <sys_open+0xdb>
      iunlockput(ip);
801058fe:	83 ec 0c             	sub    $0xc,%esp
80105901:	ff 75 f4             	push   -0xc(%ebp)
80105904:	e8 12 c3 ff ff       	call   80101c1b <iunlockput>
80105909:	83 c4 10             	add    $0x10,%esp
      end_op();
8010590c:	e8 b7 d7 ff ff       	call   801030c8 <end_op>
      return -1;
80105911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105916:	e9 c0 00 00 00       	jmp    801059db <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010591b:	e8 bd b6 ff ff       	call   80100fdd <filealloc>
80105920:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105923:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105927:	74 17                	je     80105940 <sys_open+0x100>
80105929:	83 ec 0c             	sub    $0xc,%esp
8010592c:	ff 75 f0             	push   -0x10(%ebp)
8010592f:	e8 33 f7 ff ff       	call   80105067 <fdalloc>
80105934:	83 c4 10             	add    $0x10,%esp
80105937:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010593a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010593e:	79 2e                	jns    8010596e <sys_open+0x12e>
    if(f)
80105940:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105944:	74 0e                	je     80105954 <sys_open+0x114>
      fileclose(f);
80105946:	83 ec 0c             	sub    $0xc,%esp
80105949:	ff 75 f0             	push   -0x10(%ebp)
8010594c:	e8 4a b7 ff ff       	call   8010109b <fileclose>
80105951:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105954:	83 ec 0c             	sub    $0xc,%esp
80105957:	ff 75 f4             	push   -0xc(%ebp)
8010595a:	e8 bc c2 ff ff       	call   80101c1b <iunlockput>
8010595f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105962:	e8 61 d7 ff ff       	call   801030c8 <end_op>
    return -1;
80105967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596c:	eb 6d                	jmp    801059db <sys_open+0x19b>
  }
  iunlock(ip);
8010596e:	83 ec 0c             	sub    $0xc,%esp
80105971:	ff 75 f4             	push   -0xc(%ebp)
80105974:	e8 84 c1 ff ff       	call   80101afd <iunlock>
80105979:	83 c4 10             	add    $0x10,%esp
  end_op();
8010597c:	e8 47 d7 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105981:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105984:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010598a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105990:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105993:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105996:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010599d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059a0:	83 e0 01             	and    $0x1,%eax
801059a3:	85 c0                	test   %eax,%eax
801059a5:	0f 94 c0             	sete   %al
801059a8:	89 c2                	mov    %eax,%edx
801059aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ad:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801059b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059b3:	83 e0 01             	and    $0x1,%eax
801059b6:	85 c0                	test   %eax,%eax
801059b8:	75 0a                	jne    801059c4 <sys_open+0x184>
801059ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059bd:	83 e0 02             	and    $0x2,%eax
801059c0:	85 c0                	test   %eax,%eax
801059c2:	74 07                	je     801059cb <sys_open+0x18b>
801059c4:	b8 01 00 00 00       	mov    $0x1,%eax
801059c9:	eb 05                	jmp    801059d0 <sys_open+0x190>
801059cb:	b8 00 00 00 00       	mov    $0x0,%eax
801059d0:	89 c2                	mov    %eax,%edx
801059d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d5:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801059d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801059db:	c9                   	leave  
801059dc:	c3                   	ret    

801059dd <sys_mkdir>:

int
sys_mkdir(void)
{
801059dd:	55                   	push   %ebp
801059de:	89 e5                	mov    %esp,%ebp
801059e0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801059e3:	e8 54 d6 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801059e8:	83 ec 08             	sub    $0x8,%esp
801059eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059ee:	50                   	push   %eax
801059ef:	6a 00                	push   $0x0
801059f1:	e8 48 f5 ff ff       	call   80104f3e <argstr>
801059f6:	83 c4 10             	add    $0x10,%esp
801059f9:	85 c0                	test   %eax,%eax
801059fb:	78 1b                	js     80105a18 <sys_mkdir+0x3b>
801059fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a00:	6a 00                	push   $0x0
80105a02:	6a 00                	push   $0x0
80105a04:	6a 01                	push   $0x1
80105a06:	50                   	push   %eax
80105a07:	e8 62 fc ff ff       	call   8010566e <create>
80105a0c:	83 c4 10             	add    $0x10,%esp
80105a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a16:	75 0c                	jne    80105a24 <sys_mkdir+0x47>
    end_op();
80105a18:	e8 ab d6 ff ff       	call   801030c8 <end_op>
    return -1;
80105a1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a22:	eb 18                	jmp    80105a3c <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105a24:	83 ec 0c             	sub    $0xc,%esp
80105a27:	ff 75 f4             	push   -0xc(%ebp)
80105a2a:	e8 ec c1 ff ff       	call   80101c1b <iunlockput>
80105a2f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a32:	e8 91 d6 ff ff       	call   801030c8 <end_op>
  return 0;
80105a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a3c:	c9                   	leave  
80105a3d:	c3                   	ret    

80105a3e <sys_mknod>:

int
sys_mknod(void)
{
80105a3e:	55                   	push   %ebp
80105a3f:	89 e5                	mov    %esp,%ebp
80105a41:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105a44:	e8 f3 d5 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105a49:	83 ec 08             	sub    $0x8,%esp
80105a4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a4f:	50                   	push   %eax
80105a50:	6a 00                	push   $0x0
80105a52:	e8 e7 f4 ff ff       	call   80104f3e <argstr>
80105a57:	83 c4 10             	add    $0x10,%esp
80105a5a:	85 c0                	test   %eax,%eax
80105a5c:	78 4f                	js     80105aad <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105a5e:	83 ec 08             	sub    $0x8,%esp
80105a61:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a64:	50                   	push   %eax
80105a65:	6a 01                	push   $0x1
80105a67:	e8 3d f4 ff ff       	call   80104ea9 <argint>
80105a6c:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105a6f:	85 c0                	test   %eax,%eax
80105a71:	78 3a                	js     80105aad <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105a73:	83 ec 08             	sub    $0x8,%esp
80105a76:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a79:	50                   	push   %eax
80105a7a:	6a 02                	push   $0x2
80105a7c:	e8 28 f4 ff ff       	call   80104ea9 <argint>
80105a81:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105a84:	85 c0                	test   %eax,%eax
80105a86:	78 25                	js     80105aad <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a8b:	0f bf c8             	movswl %ax,%ecx
80105a8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a91:	0f bf d0             	movswl %ax,%edx
80105a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a97:	51                   	push   %ecx
80105a98:	52                   	push   %edx
80105a99:	6a 03                	push   $0x3
80105a9b:	50                   	push   %eax
80105a9c:	e8 cd fb ff ff       	call   8010566e <create>
80105aa1:	83 c4 10             	add    $0x10,%esp
80105aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aab:	75 0c                	jne    80105ab9 <sys_mknod+0x7b>
    end_op();
80105aad:	e8 16 d6 ff ff       	call   801030c8 <end_op>
    return -1;
80105ab2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab7:	eb 18                	jmp    80105ad1 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105ab9:	83 ec 0c             	sub    $0xc,%esp
80105abc:	ff 75 f4             	push   -0xc(%ebp)
80105abf:	e8 57 c1 ff ff       	call   80101c1b <iunlockput>
80105ac4:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ac7:	e8 fc d5 ff ff       	call   801030c8 <end_op>
  return 0;
80105acc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ad1:	c9                   	leave  
80105ad2:	c3                   	ret    

80105ad3 <sys_chdir>:

int
sys_chdir(void)
{
80105ad3:	55                   	push   %ebp
80105ad4:	89 e5                	mov    %esp,%ebp
80105ad6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105ad9:	e8 52 df ff ff       	call   80103a30 <myproc>
80105ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105ae1:	e8 56 d5 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105ae6:	83 ec 08             	sub    $0x8,%esp
80105ae9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aec:	50                   	push   %eax
80105aed:	6a 00                	push   $0x0
80105aef:	e8 4a f4 ff ff       	call   80104f3e <argstr>
80105af4:	83 c4 10             	add    $0x10,%esp
80105af7:	85 c0                	test   %eax,%eax
80105af9:	78 18                	js     80105b13 <sys_chdir+0x40>
80105afb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105afe:	83 ec 0c             	sub    $0xc,%esp
80105b01:	50                   	push   %eax
80105b02:	e8 16 ca ff ff       	call   8010251d <namei>
80105b07:	83 c4 10             	add    $0x10,%esp
80105b0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b11:	75 0c                	jne    80105b1f <sys_chdir+0x4c>
    end_op();
80105b13:	e8 b0 d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1d:	eb 68                	jmp    80105b87 <sys_chdir+0xb4>
  }
  ilock(ip);
80105b1f:	83 ec 0c             	sub    $0xc,%esp
80105b22:	ff 75 f0             	push   -0x10(%ebp)
80105b25:	e8 c0 be ff ff       	call   801019ea <ilock>
80105b2a:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b30:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b34:	66 83 f8 01          	cmp    $0x1,%ax
80105b38:	74 1a                	je     80105b54 <sys_chdir+0x81>
    iunlockput(ip);
80105b3a:	83 ec 0c             	sub    $0xc,%esp
80105b3d:	ff 75 f0             	push   -0x10(%ebp)
80105b40:	e8 d6 c0 ff ff       	call   80101c1b <iunlockput>
80105b45:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b48:	e8 7b d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105b4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b52:	eb 33                	jmp    80105b87 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105b54:	83 ec 0c             	sub    $0xc,%esp
80105b57:	ff 75 f0             	push   -0x10(%ebp)
80105b5a:	e8 9e bf ff ff       	call   80101afd <iunlock>
80105b5f:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b65:	8b 40 68             	mov    0x68(%eax),%eax
80105b68:	83 ec 0c             	sub    $0xc,%esp
80105b6b:	50                   	push   %eax
80105b6c:	e8 da bf ff ff       	call   80101b4b <iput>
80105b71:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b74:	e8 4f d5 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b7f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105b82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b87:	c9                   	leave  
80105b88:	c3                   	ret    

80105b89 <sys_exec>:

int
sys_exec(void)
{
80105b89:	55                   	push   %ebp
80105b8a:	89 e5                	mov    %esp,%ebp
80105b8c:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105b92:	83 ec 08             	sub    $0x8,%esp
80105b95:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b98:	50                   	push   %eax
80105b99:	6a 00                	push   $0x0
80105b9b:	e8 9e f3 ff ff       	call   80104f3e <argstr>
80105ba0:	83 c4 10             	add    $0x10,%esp
80105ba3:	85 c0                	test   %eax,%eax
80105ba5:	78 18                	js     80105bbf <sys_exec+0x36>
80105ba7:	83 ec 08             	sub    $0x8,%esp
80105baa:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105bb0:	50                   	push   %eax
80105bb1:	6a 01                	push   $0x1
80105bb3:	e8 f1 f2 ff ff       	call   80104ea9 <argint>
80105bb8:	83 c4 10             	add    $0x10,%esp
80105bbb:	85 c0                	test   %eax,%eax
80105bbd:	79 0a                	jns    80105bc9 <sys_exec+0x40>
    return -1;
80105bbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc4:	e9 c6 00 00 00       	jmp    80105c8f <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105bc9:	83 ec 04             	sub    $0x4,%esp
80105bcc:	68 80 00 00 00       	push   $0x80
80105bd1:	6a 00                	push   $0x0
80105bd3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105bd9:	50                   	push   %eax
80105bda:	e8 9f ef ff ff       	call   80104b7e <memset>
80105bdf:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105be2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bec:	83 f8 1f             	cmp    $0x1f,%eax
80105bef:	76 0a                	jbe    80105bfb <sys_exec+0x72>
      return -1;
80105bf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf6:	e9 94 00 00 00       	jmp    80105c8f <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfe:	c1 e0 02             	shl    $0x2,%eax
80105c01:	89 c2                	mov    %eax,%edx
80105c03:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105c09:	01 c2                	add    %eax,%edx
80105c0b:	83 ec 08             	sub    $0x8,%esp
80105c0e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105c14:	50                   	push   %eax
80105c15:	52                   	push   %edx
80105c16:	e8 ed f1 ff ff       	call   80104e08 <fetchint>
80105c1b:	83 c4 10             	add    $0x10,%esp
80105c1e:	85 c0                	test   %eax,%eax
80105c20:	79 07                	jns    80105c29 <sys_exec+0xa0>
      return -1;
80105c22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c27:	eb 66                	jmp    80105c8f <sys_exec+0x106>
    if(uarg == 0){
80105c29:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105c2f:	85 c0                	test   %eax,%eax
80105c31:	75 27                	jne    80105c5a <sys_exec+0xd1>
      argv[i] = 0;
80105c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c36:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105c3d:	00 00 00 00 
      break;
80105c41:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c45:	83 ec 08             	sub    $0x8,%esp
80105c48:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105c4e:	52                   	push   %edx
80105c4f:	50                   	push   %eax
80105c50:	e8 2b af ff ff       	call   80100b80 <exec>
80105c55:	83 c4 10             	add    $0x10,%esp
80105c58:	eb 35                	jmp    80105c8f <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105c5a:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c63:	c1 e0 02             	shl    $0x2,%eax
80105c66:	01 c2                	add    %eax,%edx
80105c68:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105c6e:	83 ec 08             	sub    $0x8,%esp
80105c71:	52                   	push   %edx
80105c72:	50                   	push   %eax
80105c73:	e8 cf f1 ff ff       	call   80104e47 <fetchstr>
80105c78:	83 c4 10             	add    $0x10,%esp
80105c7b:	85 c0                	test   %eax,%eax
80105c7d:	79 07                	jns    80105c86 <sys_exec+0xfd>
      return -1;
80105c7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c84:	eb 09                	jmp    80105c8f <sys_exec+0x106>
  for(i=0;; i++){
80105c86:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105c8a:	e9 5a ff ff ff       	jmp    80105be9 <sys_exec+0x60>
}
80105c8f:	c9                   	leave  
80105c90:	c3                   	ret    

80105c91 <sys_pipe>:

int
sys_pipe(void)
{
80105c91:	55                   	push   %ebp
80105c92:	89 e5                	mov    %esp,%ebp
80105c94:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105c97:	83 ec 04             	sub    $0x4,%esp
80105c9a:	6a 08                	push   $0x8
80105c9c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c9f:	50                   	push   %eax
80105ca0:	6a 00                	push   $0x0
80105ca2:	e8 2f f2 ff ff       	call   80104ed6 <argptr>
80105ca7:	83 c4 10             	add    $0x10,%esp
80105caa:	85 c0                	test   %eax,%eax
80105cac:	79 0a                	jns    80105cb8 <sys_pipe+0x27>
    return -1;
80105cae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb3:	e9 ae 00 00 00       	jmp    80105d66 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105cb8:	83 ec 08             	sub    $0x8,%esp
80105cbb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cbe:	50                   	push   %eax
80105cbf:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105cc2:	50                   	push   %eax
80105cc3:	e8 a5 d8 ff ff       	call   8010356d <pipealloc>
80105cc8:	83 c4 10             	add    $0x10,%esp
80105ccb:	85 c0                	test   %eax,%eax
80105ccd:	79 0a                	jns    80105cd9 <sys_pipe+0x48>
    return -1;
80105ccf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd4:	e9 8d 00 00 00       	jmp    80105d66 <sys_pipe+0xd5>
  fd0 = -1;
80105cd9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105ce0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ce3:	83 ec 0c             	sub    $0xc,%esp
80105ce6:	50                   	push   %eax
80105ce7:	e8 7b f3 ff ff       	call   80105067 <fdalloc>
80105cec:	83 c4 10             	add    $0x10,%esp
80105cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cf2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cf6:	78 18                	js     80105d10 <sys_pipe+0x7f>
80105cf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cfb:	83 ec 0c             	sub    $0xc,%esp
80105cfe:	50                   	push   %eax
80105cff:	e8 63 f3 ff ff       	call   80105067 <fdalloc>
80105d04:	83 c4 10             	add    $0x10,%esp
80105d07:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d0e:	79 3e                	jns    80105d4e <sys_pipe+0xbd>
    if(fd0 >= 0)
80105d10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d14:	78 13                	js     80105d29 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105d16:	e8 15 dd ff ff       	call   80103a30 <myproc>
80105d1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d1e:	83 c2 08             	add    $0x8,%edx
80105d21:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d28:	00 
    fileclose(rf);
80105d29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d2c:	83 ec 0c             	sub    $0xc,%esp
80105d2f:	50                   	push   %eax
80105d30:	e8 66 b3 ff ff       	call   8010109b <fileclose>
80105d35:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105d38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d3b:	83 ec 0c             	sub    $0xc,%esp
80105d3e:	50                   	push   %eax
80105d3f:	e8 57 b3 ff ff       	call   8010109b <fileclose>
80105d44:	83 c4 10             	add    $0x10,%esp
    return -1;
80105d47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4c:	eb 18                	jmp    80105d66 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105d4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d54:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d59:	8d 50 04             	lea    0x4(%eax),%edx
80105d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5f:	89 02                	mov    %eax,(%edx)
  return 0;
80105d61:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d66:	c9                   	leave  
80105d67:	c3                   	ret    

80105d68 <sys_fork>:
  struct proc proc[NPROC];
} ptable;

int
sys_fork(void)
{
80105d68:	55                   	push   %ebp
80105d69:	89 e5                	mov    %esp,%ebp
80105d6b:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105d6e:	e8 f7 df ff ff       	call   80103d6a <fork>
}
80105d73:	c9                   	leave  
80105d74:	c3                   	ret    

80105d75 <sys_exit>:

int
sys_exit(void)
{
80105d75:	55                   	push   %ebp
80105d76:	89 e5                	mov    %esp,%ebp
80105d78:	83 ec 08             	sub    $0x8,%esp
  exit();
80105d7b:	e8 63 e1 ff ff       	call   80103ee3 <exit>
  return 0;  // not reached
80105d80:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d85:	c9                   	leave  
80105d86:	c3                   	ret    

80105d87 <sys_wait>:

int
sys_wait(void)
{
80105d87:	55                   	push   %ebp
80105d88:	89 e5                	mov    %esp,%ebp
80105d8a:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105d8d:	e8 74 e2 ff ff       	call   80104006 <wait>
}
80105d92:	c9                   	leave  
80105d93:	c3                   	ret    

80105d94 <sys_kill>:

int
sys_kill(void)
{
80105d94:	55                   	push   %ebp
80105d95:	89 e5                	mov    %esp,%ebp
80105d97:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105d9a:	83 ec 08             	sub    $0x8,%esp
80105d9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105da0:	50                   	push   %eax
80105da1:	6a 00                	push   $0x0
80105da3:	e8 01 f1 ff ff       	call   80104ea9 <argint>
80105da8:	83 c4 10             	add    $0x10,%esp
80105dab:	85 c0                	test   %eax,%eax
80105dad:	79 07                	jns    80105db6 <sys_kill+0x22>
    return -1;
80105daf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db4:	eb 0f                	jmp    80105dc5 <sys_kill+0x31>
  return kill(pid);
80105db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db9:	83 ec 0c             	sub    $0xc,%esp
80105dbc:	50                   	push   %eax
80105dbd:	e8 43 e8 ff ff       	call   80104605 <kill>
80105dc2:	83 c4 10             	add    $0x10,%esp
}
80105dc5:	c9                   	leave  
80105dc6:	c3                   	ret    

80105dc7 <sys_getpid>:

int
sys_getpid(void)
{
80105dc7:	55                   	push   %ebp
80105dc8:	89 e5                	mov    %esp,%ebp
80105dca:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105dcd:	e8 5e dc ff ff       	call   80103a30 <myproc>
80105dd2:	8b 40 10             	mov    0x10(%eax),%eax
}
80105dd5:	c9                   	leave  
80105dd6:	c3                   	ret    

80105dd7 <sys_sbrk>:

int
sys_sbrk(void)
{
80105dd7:	55                   	push   %ebp
80105dd8:	89 e5                	mov    %esp,%ebp
80105dda:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ddd:	83 ec 08             	sub    $0x8,%esp
80105de0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105de3:	50                   	push   %eax
80105de4:	6a 00                	push   $0x0
80105de6:	e8 be f0 ff ff       	call   80104ea9 <argint>
80105deb:	83 c4 10             	add    $0x10,%esp
80105dee:	85 c0                	test   %eax,%eax
80105df0:	79 07                	jns    80105df9 <sys_sbrk+0x22>
    return -1;
80105df2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df7:	eb 27                	jmp    80105e20 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105df9:	e8 32 dc ff ff       	call   80103a30 <myproc>
80105dfe:	8b 00                	mov    (%eax),%eax
80105e00:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e06:	83 ec 0c             	sub    $0xc,%esp
80105e09:	50                   	push   %eax
80105e0a:	e8 c0 de ff ff       	call   80103ccf <growproc>
80105e0f:	83 c4 10             	add    $0x10,%esp
80105e12:	85 c0                	test   %eax,%eax
80105e14:	79 07                	jns    80105e1d <sys_sbrk+0x46>
    return -1;
80105e16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1b:	eb 03                	jmp    80105e20 <sys_sbrk+0x49>
  return addr;
80105e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e20:	c9                   	leave  
80105e21:	c3                   	ret    

80105e22 <sys_sleep>:

int
sys_sleep(void)
{
80105e22:	55                   	push   %ebp
80105e23:	89 e5                	mov    %esp,%ebp
80105e25:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105e28:	83 ec 08             	sub    $0x8,%esp
80105e2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e2e:	50                   	push   %eax
80105e2f:	6a 00                	push   $0x0
80105e31:	e8 73 f0 ff ff       	call   80104ea9 <argint>
80105e36:	83 c4 10             	add    $0x10,%esp
80105e39:	85 c0                	test   %eax,%eax
80105e3b:	79 07                	jns    80105e44 <sys_sleep+0x22>
    return -1;
80105e3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e42:	eb 76                	jmp    80105eba <sys_sleep+0x98>
  acquire(&tickslock);
80105e44:	83 ec 0c             	sub    $0xc,%esp
80105e47:	68 40 76 19 80       	push   $0x80197640
80105e4c:	e8 b7 ea ff ff       	call   80104908 <acquire>
80105e51:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105e54:	a1 74 76 19 80       	mov    0x80197674,%eax
80105e59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105e5c:	eb 38                	jmp    80105e96 <sys_sleep+0x74>
    if(myproc()->killed){
80105e5e:	e8 cd db ff ff       	call   80103a30 <myproc>
80105e63:	8b 40 24             	mov    0x24(%eax),%eax
80105e66:	85 c0                	test   %eax,%eax
80105e68:	74 17                	je     80105e81 <sys_sleep+0x5f>
      release(&tickslock);
80105e6a:	83 ec 0c             	sub    $0xc,%esp
80105e6d:	68 40 76 19 80       	push   $0x80197640
80105e72:	e8 ff ea ff ff       	call   80104976 <release>
80105e77:	83 c4 10             	add    $0x10,%esp
      return -1;
80105e7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e7f:	eb 39                	jmp    80105eba <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105e81:	83 ec 08             	sub    $0x8,%esp
80105e84:	68 40 76 19 80       	push   $0x80197640
80105e89:	68 74 76 19 80       	push   $0x80197674
80105e8e:	e8 51 e6 ff ff       	call   801044e4 <sleep>
80105e93:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105e96:	a1 74 76 19 80       	mov    0x80197674,%eax
80105e9b:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105e9e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ea1:	39 d0                	cmp    %edx,%eax
80105ea3:	72 b9                	jb     80105e5e <sys_sleep+0x3c>
  }
  release(&tickslock);
80105ea5:	83 ec 0c             	sub    $0xc,%esp
80105ea8:	68 40 76 19 80       	push   $0x80197640
80105ead:	e8 c4 ea ff ff       	call   80104976 <release>
80105eb2:	83 c4 10             	add    $0x10,%esp
  return 0;
80105eb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105eba:	c9                   	leave  
80105ebb:	c3                   	ret    

80105ebc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105ebc:	55                   	push   %ebp
80105ebd:	89 e5                	mov    %esp,%ebp
80105ebf:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105ec2:	83 ec 0c             	sub    $0xc,%esp
80105ec5:	68 40 76 19 80       	push   $0x80197640
80105eca:	e8 39 ea ff ff       	call   80104908 <acquire>
80105ecf:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105ed2:	a1 74 76 19 80       	mov    0x80197674,%eax
80105ed7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105eda:	83 ec 0c             	sub    $0xc,%esp
80105edd:	68 40 76 19 80       	push   $0x80197640
80105ee2:	e8 8f ea ff ff       	call   80104976 <release>
80105ee7:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105eed:	c9                   	leave  
80105eee:	c3                   	ret    

80105eef <sys_getpinfo>:

int 
sys_getpinfo(void)
{
80105eef:	55                   	push   %ebp
80105ef0:	89 e5                	mov    %esp,%ebp
80105ef2:	53                   	push   %ebx
80105ef3:	83 ec 14             	sub    $0x14,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(*ps)) < 0)
80105ef6:	83 ec 04             	sub    $0x4,%esp
80105ef9:	68 00 10 00 00       	push   $0x1000
80105efe:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f01:	50                   	push   %eax
80105f02:	6a 00                	push   $0x0
80105f04:	e8 cd ef ff ff       	call   80104ed6 <argptr>
80105f09:	83 c4 10             	add    $0x10,%esp
80105f0c:	85 c0                	test   %eax,%eax
80105f0e:	79 0a                	jns    80105f1a <sys_getpinfo+0x2b>
    return -1;
80105f10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f15:	e9 30 01 00 00       	jmp    8010604a <sys_getpinfo+0x15b>

  acquire(&ptable.lock);
80105f1a:	83 ec 0c             	sub    $0xc,%esp
80105f1d:	68 00 42 19 80       	push   $0x80194200
80105f22:	e8 e1 e9 ff ff       	call   80104908 <acquire>
80105f27:	83 c4 10             	add    $0x10,%esp
  
  for (int i = 0; i < NPROC; i++) {
80105f2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105f31:	e9 f5 00 00 00       	jmp    8010602b <sys_getpinfo+0x13c>
    struct proc *p = &ptable.proc[i];
80105f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f39:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105f3f:	83 c0 30             	add    $0x30,%eax
80105f42:	05 00 42 19 80       	add    $0x80194200,%eax
80105f47:	83 c0 04             	add    $0x4,%eax
80105f4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ps->inuse[i] = (p->state != UNUSED);
80105f4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f50:	8b 40 0c             	mov    0xc(%eax),%eax
80105f53:	85 c0                	test   %eax,%eax
80105f55:	0f 95 c2             	setne  %dl
80105f58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f5b:	0f b6 ca             	movzbl %dl,%ecx
80105f5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f61:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
80105f64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f67:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105f6a:	8b 52 10             	mov    0x10(%edx),%edx
80105f6d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105f70:	83 c1 40             	add    $0x40,%ecx
80105f73:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = p->priority;
80105f76:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f79:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105f7c:	8b 52 7c             	mov    0x7c(%edx),%edx
80105f7f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105f82:	83 e9 80             	sub    $0xffffff80,%ecx
80105f85:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
80105f88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f8b:	8b 50 0c             	mov    0xc(%eax),%edx
80105f8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f91:	89 d1                	mov    %edx,%ecx
80105f93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f96:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80105f9c:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
80105f9f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105fa6:	eb 79                	jmp    80106021 <sys_getpinfo+0x132>
      ps->ticks[i][j] = p->ticks[j];
80105fa8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fab:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105fae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105fb1:	83 c1 20             	add    $0x20,%ecx
80105fb4:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80105fb7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105fba:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80105fc1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105fc4:	01 d9                	add    %ebx,%ecx
80105fc6:	81 c1 00 01 00 00    	add    $0x100,%ecx
80105fcc:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
80105fcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fd2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105fd5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105fd8:	83 c1 24             	add    $0x24,%ecx
80105fdb:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80105fde:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105fe1:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80105fe8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105feb:	01 d9                	add    %ebx,%ecx
80105fed:	81 c1 00 02 00 00    	add    $0x200,%ecx
80105ff3:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->total_ticks[i][j] = p->total_ticks[j];
80105ff6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ff9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ffc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105fff:	83 c1 28             	add    $0x28,%ecx
80106002:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80106005:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106008:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
8010600f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106012:	01 d9                	add    %ebx,%ecx
80106014:	81 c1 00 03 00 00    	add    $0x300,%ecx
8010601a:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
8010601d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106021:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80106025:	7e 81                	jle    80105fa8 <sys_getpinfo+0xb9>
  for (int i = 0; i < NPROC; i++) {
80106027:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010602b:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010602f:	0f 8e 01 ff ff ff    	jle    80105f36 <sys_getpinfo+0x47>
    }

  }
  release(&ptable.lock);
80106035:	83 ec 0c             	sub    $0xc,%esp
80106038:	68 00 42 19 80       	push   $0x80194200
8010603d:	e8 34 e9 ff ff       	call   80104976 <release>
80106042:	83 c4 10             	add    $0x10,%esp

  return 0;
80106045:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010604a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010604d:	c9                   	leave  
8010604e:	c3                   	ret    

8010604f <sys_setSchedPolicy>:

int 
sys_setSchedPolicy(void)
{
8010604f:	55                   	push   %ebp
80106050:	89 e5                	mov    %esp,%ebp
80106052:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
80106055:	83 ec 08             	sub    $0x8,%esp
80106058:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010605b:	50                   	push   %eax
8010605c:	6a 00                	push   $0x0
8010605e:	e8 46 ee ff ff       	call   80104ea9 <argint>
80106063:	83 c4 10             	add    $0x10,%esp
80106066:	85 c0                	test   %eax,%eax
80106068:	79 07                	jns    80106071 <sys_setSchedPolicy+0x22>
    return -1;
8010606a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606f:	eb 1d                	jmp    8010608e <sys_setSchedPolicy+0x3f>

  pushcli();  // 🔒 인터럽트 끄고
80106071:	e8 fd e9 ff ff       	call   80104a73 <pushcli>
  mycpu()->sched_policy = policy;
80106076:	e8 3d d9 ff ff       	call   801039b8 <mycpu>
8010607b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010607e:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();   // 🔓 복원
80106084:	e8 37 ea ff ff       	call   80104ac0 <popcli>
  return 0;
80106089:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010608e:	c9                   	leave  
8010608f:	c3                   	ret    

80106090 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106090:	1e                   	push   %ds
  pushl %es
80106091:	06                   	push   %es
  pushl %fs
80106092:	0f a0                	push   %fs
  pushl %gs
80106094:	0f a8                	push   %gs
  pushal
80106096:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106097:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010609b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010609d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010609f:	54                   	push   %esp
  call trap
801060a0:	e8 d7 01 00 00       	call   8010627c <trap>
  addl $4, %esp
801060a5:	83 c4 04             	add    $0x4,%esp

801060a8 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801060a8:	61                   	popa   
  popl %gs
801060a9:	0f a9                	pop    %gs
  popl %fs
801060ab:	0f a1                	pop    %fs
  popl %es
801060ad:	07                   	pop    %es
  popl %ds
801060ae:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801060af:	83 c4 08             	add    $0x8,%esp
  iret
801060b2:	cf                   	iret   

801060b3 <lidt>:
{
801060b3:	55                   	push   %ebp
801060b4:	89 e5                	mov    %esp,%ebp
801060b6:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801060b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801060bc:	83 e8 01             	sub    $0x1,%eax
801060bf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801060c3:	8b 45 08             	mov    0x8(%ebp),%eax
801060c6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801060ca:	8b 45 08             	mov    0x8(%ebp),%eax
801060cd:	c1 e8 10             	shr    $0x10,%eax
801060d0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801060d4:	8d 45 fa             	lea    -0x6(%ebp),%eax
801060d7:	0f 01 18             	lidtl  (%eax)
}
801060da:	90                   	nop
801060db:	c9                   	leave  
801060dc:	c3                   	ret    

801060dd <rcr2>:

static inline uint
rcr2(void)
{
801060dd:	55                   	push   %ebp
801060de:	89 e5                	mov    %esp,%ebp
801060e0:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801060e3:	0f 20 d0             	mov    %cr2,%eax
801060e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801060e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060ec:	c9                   	leave  
801060ed:	c3                   	ret    

801060ee <tvinit>:
  struct proc proc[NPROC];
} ptable;

void
tvinit(void)
{
801060ee:	55                   	push   %ebp
801060ef:	89 e5                	mov    %esp,%ebp
801060f1:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801060f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801060fb:	e9 c3 00 00 00       	jmp    801061c3 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106103:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
8010610a:	89 c2                	mov    %eax,%edx
8010610c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610f:	66 89 14 c5 40 6e 19 	mov    %dx,-0x7fe691c0(,%eax,8)
80106116:	80 
80106117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010611a:	66 c7 04 c5 42 6e 19 	movw   $0x8,-0x7fe691be(,%eax,8)
80106121:	80 08 00 
80106124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106127:	0f b6 14 c5 44 6e 19 	movzbl -0x7fe691bc(,%eax,8),%edx
8010612e:	80 
8010612f:	83 e2 e0             	and    $0xffffffe0,%edx
80106132:	88 14 c5 44 6e 19 80 	mov    %dl,-0x7fe691bc(,%eax,8)
80106139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613c:	0f b6 14 c5 44 6e 19 	movzbl -0x7fe691bc(,%eax,8),%edx
80106143:	80 
80106144:	83 e2 1f             	and    $0x1f,%edx
80106147:	88 14 c5 44 6e 19 80 	mov    %dl,-0x7fe691bc(,%eax,8)
8010614e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106151:	0f b6 14 c5 45 6e 19 	movzbl -0x7fe691bb(,%eax,8),%edx
80106158:	80 
80106159:	83 e2 f0             	and    $0xfffffff0,%edx
8010615c:	83 ca 0e             	or     $0xe,%edx
8010615f:	88 14 c5 45 6e 19 80 	mov    %dl,-0x7fe691bb(,%eax,8)
80106166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106169:	0f b6 14 c5 45 6e 19 	movzbl -0x7fe691bb(,%eax,8),%edx
80106170:	80 
80106171:	83 e2 ef             	and    $0xffffffef,%edx
80106174:	88 14 c5 45 6e 19 80 	mov    %dl,-0x7fe691bb(,%eax,8)
8010617b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010617e:	0f b6 14 c5 45 6e 19 	movzbl -0x7fe691bb(,%eax,8),%edx
80106185:	80 
80106186:	83 e2 9f             	and    $0xffffff9f,%edx
80106189:	88 14 c5 45 6e 19 80 	mov    %dl,-0x7fe691bb(,%eax,8)
80106190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106193:	0f b6 14 c5 45 6e 19 	movzbl -0x7fe691bb(,%eax,8),%edx
8010619a:	80 
8010619b:	83 ca 80             	or     $0xffffff80,%edx
8010619e:	88 14 c5 45 6e 19 80 	mov    %dl,-0x7fe691bb(,%eax,8)
801061a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a8:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801061af:	c1 e8 10             	shr    $0x10,%eax
801061b2:	89 c2                	mov    %eax,%edx
801061b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b7:	66 89 14 c5 46 6e 19 	mov    %dx,-0x7fe691ba(,%eax,8)
801061be:	80 
  for(i = 0; i < 256; i++)
801061bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801061c3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801061ca:	0f 8e 30 ff ff ff    	jle    80106100 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801061d0:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801061d5:	66 a3 40 70 19 80    	mov    %ax,0x80197040
801061db:	66 c7 05 42 70 19 80 	movw   $0x8,0x80197042
801061e2:	08 00 
801061e4:	0f b6 05 44 70 19 80 	movzbl 0x80197044,%eax
801061eb:	83 e0 e0             	and    $0xffffffe0,%eax
801061ee:	a2 44 70 19 80       	mov    %al,0x80197044
801061f3:	0f b6 05 44 70 19 80 	movzbl 0x80197044,%eax
801061fa:	83 e0 1f             	and    $0x1f,%eax
801061fd:	a2 44 70 19 80       	mov    %al,0x80197044
80106202:	0f b6 05 45 70 19 80 	movzbl 0x80197045,%eax
80106209:	83 c8 0f             	or     $0xf,%eax
8010620c:	a2 45 70 19 80       	mov    %al,0x80197045
80106211:	0f b6 05 45 70 19 80 	movzbl 0x80197045,%eax
80106218:	83 e0 ef             	and    $0xffffffef,%eax
8010621b:	a2 45 70 19 80       	mov    %al,0x80197045
80106220:	0f b6 05 45 70 19 80 	movzbl 0x80197045,%eax
80106227:	83 c8 60             	or     $0x60,%eax
8010622a:	a2 45 70 19 80       	mov    %al,0x80197045
8010622f:	0f b6 05 45 70 19 80 	movzbl 0x80197045,%eax
80106236:	83 c8 80             	or     $0xffffff80,%eax
80106239:	a2 45 70 19 80       	mov    %al,0x80197045
8010623e:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106243:	c1 e8 10             	shr    $0x10,%eax
80106246:	66 a3 46 70 19 80    	mov    %ax,0x80197046

  initlock(&tickslock, "time");
8010624c:	83 ec 08             	sub    $0x8,%esp
8010624f:	68 18 a8 10 80       	push   $0x8010a818
80106254:	68 40 76 19 80       	push   $0x80197640
80106259:	e8 88 e6 ff ff       	call   801048e6 <initlock>
8010625e:	83 c4 10             	add    $0x10,%esp
}
80106261:	90                   	nop
80106262:	c9                   	leave  
80106263:	c3                   	ret    

80106264 <idtinit>:

void
idtinit(void)
{
80106264:	55                   	push   %ebp
80106265:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106267:	68 00 08 00 00       	push   $0x800
8010626c:	68 40 6e 19 80       	push   $0x80196e40
80106271:	e8 3d fe ff ff       	call   801060b3 <lidt>
80106276:	83 c4 08             	add    $0x8,%esp
}
80106279:	90                   	nop
8010627a:	c9                   	leave  
8010627b:	c3                   	ret    

8010627c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010627c:	55                   	push   %ebp
8010627d:	89 e5                	mov    %esp,%ebp
8010627f:	57                   	push   %edi
80106280:	56                   	push   %esi
80106281:	53                   	push   %ebx
80106282:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106285:	8b 45 08             	mov    0x8(%ebp),%eax
80106288:	8b 40 30             	mov    0x30(%eax),%eax
8010628b:	83 f8 40             	cmp    $0x40,%eax
8010628e:	75 3b                	jne    801062cb <trap+0x4f>
    if(myproc()->killed)
80106290:	e8 9b d7 ff ff       	call   80103a30 <myproc>
80106295:	8b 40 24             	mov    0x24(%eax),%eax
80106298:	85 c0                	test   %eax,%eax
8010629a:	74 05                	je     801062a1 <trap+0x25>
      exit();
8010629c:	e8 42 dc ff ff       	call   80103ee3 <exit>
    myproc()->tf = tf;
801062a1:	e8 8a d7 ff ff       	call   80103a30 <myproc>
801062a6:	8b 55 08             	mov    0x8(%ebp),%edx
801062a9:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801062ac:	e8 c4 ec ff ff       	call   80104f75 <syscall>
    if(myproc()->killed)
801062b1:	e8 7a d7 ff ff       	call   80103a30 <myproc>
801062b6:	8b 40 24             	mov    0x24(%eax),%eax
801062b9:	85 c0                	test   %eax,%eax
801062bb:	0f 84 c0 02 00 00    	je     80106581 <trap+0x305>
      exit();
801062c1:	e8 1d dc ff ff       	call   80103ee3 <exit>
    return;
801062c6:	e9 b6 02 00 00       	jmp    80106581 <trap+0x305>
  }

  switch(tf->trapno){
801062cb:	8b 45 08             	mov    0x8(%ebp),%eax
801062ce:	8b 40 30             	mov    0x30(%eax),%eax
801062d1:	83 e8 20             	sub    $0x20,%eax
801062d4:	83 f8 1f             	cmp    $0x1f,%eax
801062d7:	0f 87 6f 01 00 00    	ja     8010644c <trap+0x1d0>
801062dd:	8b 04 85 c0 a8 10 80 	mov    -0x7fef5740(,%eax,4),%eax
801062e4:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801062e6:	e8 b2 d6 ff ff       	call   8010399d <cpuid>
801062eb:	85 c0                	test   %eax,%eax
801062ed:	75 3d                	jne    8010632c <trap+0xb0>
      acquire(&tickslock);
801062ef:	83 ec 0c             	sub    $0xc,%esp
801062f2:	68 40 76 19 80       	push   $0x80197640
801062f7:	e8 0c e6 ff ff       	call   80104908 <acquire>
801062fc:	83 c4 10             	add    $0x10,%esp
      ticks++;
801062ff:	a1 74 76 19 80       	mov    0x80197674,%eax
80106304:	83 c0 01             	add    $0x1,%eax
80106307:	a3 74 76 19 80       	mov    %eax,0x80197674
      wakeup(&ticks);
8010630c:	83 ec 0c             	sub    $0xc,%esp
8010630f:	68 74 76 19 80       	push   $0x80197674
80106314:	e8 b5 e2 ff ff       	call   801045ce <wakeup>
80106319:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010631c:	83 ec 0c             	sub    $0xc,%esp
8010631f:	68 40 76 19 80       	push   $0x80197640
80106324:	e8 4d e6 ff ff       	call   80104976 <release>
80106329:	83 c4 10             	add    $0x10,%esp
    }

    struct proc *cp = myproc();
8010632c:	e8 ff d6 ff ff       	call   80103a30 <myproc>
80106331:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (cp) {
80106334:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80106338:	74 36                	je     80106370 <trap+0xf4>
      // 현재 실행 중인 프로세스의 실행 시간 누적
      cp->ticks[cp->priority]++;
8010633a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010633d:	8b 40 7c             	mov    0x7c(%eax),%eax
80106340:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106343:	8d 48 20             	lea    0x20(%eax),%ecx
80106346:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80106349:	8d 4a 01             	lea    0x1(%edx),%ecx
8010634c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010634f:	83 c0 20             	add    $0x20,%eax
80106352:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
      cp->total_ticks[cp->priority]++;
80106355:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106358:	8b 40 7c             	mov    0x7c(%eax),%eax
8010635b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010635e:	8d 48 28             	lea    0x28(%eax),%ecx
80106361:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80106364:	8d 4a 01             	lea    0x1(%edx),%ecx
80106367:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010636a:	83 c0 28             	add    $0x28,%eax
8010636d:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    }
  
    // 나머지 RUNNABLE 프로세스들의 대기 시간 누적
    acquire(&ptable.lock);
80106370:	83 ec 0c             	sub    $0xc,%esp
80106373:	68 00 42 19 80       	push   $0x80194200
80106378:	e8 8b e5 ff ff       	call   80104908 <acquire>
8010637d:	83 c4 10             	add    $0x10,%esp
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80106380:	c7 45 e4 34 42 19 80 	movl   $0x80194234,-0x1c(%ebp)
80106387:	eb 35                	jmp    801063be <trap+0x142>
      if (p != cp && p->state == RUNNABLE) {
80106389:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010638c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
8010638f:	74 26                	je     801063b7 <trap+0x13b>
80106391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106394:	8b 40 0c             	mov    0xc(%eax),%eax
80106397:	83 f8 03             	cmp    $0x3,%eax
8010639a:	75 1b                	jne    801063b7 <trap+0x13b>
        p->wait_ticks[p->priority]++;
8010639c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010639f:	8b 40 7c             	mov    0x7c(%eax),%eax
801063a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801063a5:	8d 48 24             	lea    0x24(%eax),%ecx
801063a8:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
801063ab:	8d 4a 01             	lea    0x1(%edx),%ecx
801063ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801063b1:	83 c0 24             	add    $0x24,%eax
801063b4:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801063b7:	81 45 e4 b0 00 00 00 	addl   $0xb0,-0x1c(%ebp)
801063be:	81 7d e4 34 6e 19 80 	cmpl   $0x80196e34,-0x1c(%ebp)
801063c5:	72 c2                	jb     80106389 <trap+0x10d>
      }
    }
    release(&ptable.lock);
801063c7:	83 ec 0c             	sub    $0xc,%esp
801063ca:	68 00 42 19 80       	push   $0x80194200
801063cf:	e8 a2 e5 ff ff       	call   80104976 <release>
801063d4:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801063d7:	e8 40 c7 ff ff       	call   80102b1c <lapiceoi>
    break;
801063dc:	e9 20 01 00 00       	jmp    80106501 <trap+0x285>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801063e1:	e8 f5 3e 00 00       	call   8010a2db <ideintr>
    lapiceoi();
801063e6:	e8 31 c7 ff ff       	call   80102b1c <lapiceoi>
    break;
801063eb:	e9 11 01 00 00       	jmp    80106501 <trap+0x285>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801063f0:	e8 6c c5 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
801063f5:	e8 22 c7 ff ff       	call   80102b1c <lapiceoi>
    break;
801063fa:	e9 02 01 00 00       	jmp    80106501 <trap+0x285>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801063ff:	e8 53 03 00 00       	call   80106757 <uartintr>
    lapiceoi();
80106404:	e8 13 c7 ff ff       	call   80102b1c <lapiceoi>
    break;
80106409:	e9 f3 00 00 00       	jmp    80106501 <trap+0x285>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010640e:	e8 7b 2b 00 00       	call   80108f8e <i8254_intr>
    lapiceoi();
80106413:	e8 04 c7 ff ff       	call   80102b1c <lapiceoi>
    break;
80106418:	e9 e4 00 00 00       	jmp    80106501 <trap+0x285>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010641d:	8b 45 08             	mov    0x8(%ebp),%eax
80106420:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106423:	8b 45 08             	mov    0x8(%ebp),%eax
80106426:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010642a:	0f b7 d8             	movzwl %ax,%ebx
8010642d:	e8 6b d5 ff ff       	call   8010399d <cpuid>
80106432:	56                   	push   %esi
80106433:	53                   	push   %ebx
80106434:	50                   	push   %eax
80106435:	68 20 a8 10 80       	push   $0x8010a820
8010643a:	e8 b5 9f ff ff       	call   801003f4 <cprintf>
8010643f:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106442:	e8 d5 c6 ff ff       	call   80102b1c <lapiceoi>
    break;
80106447:	e9 b5 00 00 00       	jmp    80106501 <trap+0x285>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010644c:	e8 df d5 ff ff       	call   80103a30 <myproc>
80106451:	85 c0                	test   %eax,%eax
80106453:	74 11                	je     80106466 <trap+0x1ea>
80106455:	8b 45 08             	mov    0x8(%ebp),%eax
80106458:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010645c:	0f b7 c0             	movzwl %ax,%eax
8010645f:	83 e0 03             	and    $0x3,%eax
80106462:	85 c0                	test   %eax,%eax
80106464:	75 39                	jne    8010649f <trap+0x223>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106466:	e8 72 fc ff ff       	call   801060dd <rcr2>
8010646b:	89 c3                	mov    %eax,%ebx
8010646d:	8b 45 08             	mov    0x8(%ebp),%eax
80106470:	8b 70 38             	mov    0x38(%eax),%esi
80106473:	e8 25 d5 ff ff       	call   8010399d <cpuid>
80106478:	8b 55 08             	mov    0x8(%ebp),%edx
8010647b:	8b 52 30             	mov    0x30(%edx),%edx
8010647e:	83 ec 0c             	sub    $0xc,%esp
80106481:	53                   	push   %ebx
80106482:	56                   	push   %esi
80106483:	50                   	push   %eax
80106484:	52                   	push   %edx
80106485:	68 44 a8 10 80       	push   $0x8010a844
8010648a:	e8 65 9f ff ff       	call   801003f4 <cprintf>
8010648f:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106492:	83 ec 0c             	sub    $0xc,%esp
80106495:	68 76 a8 10 80       	push   $0x8010a876
8010649a:	e8 0a a1 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010649f:	e8 39 fc ff ff       	call   801060dd <rcr2>
801064a4:	89 c6                	mov    %eax,%esi
801064a6:	8b 45 08             	mov    0x8(%ebp),%eax
801064a9:	8b 40 38             	mov    0x38(%eax),%eax
801064ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801064af:	e8 e9 d4 ff ff       	call   8010399d <cpuid>
801064b4:	89 c3                	mov    %eax,%ebx
801064b6:	8b 45 08             	mov    0x8(%ebp),%eax
801064b9:	8b 78 34             	mov    0x34(%eax),%edi
801064bc:	89 7d d0             	mov    %edi,-0x30(%ebp)
801064bf:	8b 45 08             	mov    0x8(%ebp),%eax
801064c2:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801064c5:	e8 66 d5 ff ff       	call   80103a30 <myproc>
801064ca:	8d 48 6c             	lea    0x6c(%eax),%ecx
801064cd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
801064d0:	e8 5b d5 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801064d5:	8b 40 10             	mov    0x10(%eax),%eax
801064d8:	56                   	push   %esi
801064d9:	ff 75 d4             	push   -0x2c(%ebp)
801064dc:	53                   	push   %ebx
801064dd:	ff 75 d0             	push   -0x30(%ebp)
801064e0:	57                   	push   %edi
801064e1:	ff 75 cc             	push   -0x34(%ebp)
801064e4:	50                   	push   %eax
801064e5:	68 7c a8 10 80       	push   $0x8010a87c
801064ea:	e8 05 9f ff ff       	call   801003f4 <cprintf>
801064ef:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801064f2:	e8 39 d5 ff ff       	call   80103a30 <myproc>
801064f7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801064fe:	eb 01                	jmp    80106501 <trap+0x285>
    break;
80106500:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106501:	e8 2a d5 ff ff       	call   80103a30 <myproc>
80106506:	85 c0                	test   %eax,%eax
80106508:	74 23                	je     8010652d <trap+0x2b1>
8010650a:	e8 21 d5 ff ff       	call   80103a30 <myproc>
8010650f:	8b 40 24             	mov    0x24(%eax),%eax
80106512:	85 c0                	test   %eax,%eax
80106514:	74 17                	je     8010652d <trap+0x2b1>
80106516:	8b 45 08             	mov    0x8(%ebp),%eax
80106519:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010651d:	0f b7 c0             	movzwl %ax,%eax
80106520:	83 e0 03             	and    $0x3,%eax
80106523:	83 f8 03             	cmp    $0x3,%eax
80106526:	75 05                	jne    8010652d <trap+0x2b1>
    exit();
80106528:	e8 b6 d9 ff ff       	call   80103ee3 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010652d:	e8 fe d4 ff ff       	call   80103a30 <myproc>
80106532:	85 c0                	test   %eax,%eax
80106534:	74 1d                	je     80106553 <trap+0x2d7>
80106536:	e8 f5 d4 ff ff       	call   80103a30 <myproc>
8010653b:	8b 40 0c             	mov    0xc(%eax),%eax
8010653e:	83 f8 04             	cmp    $0x4,%eax
80106541:	75 10                	jne    80106553 <trap+0x2d7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106543:	8b 45 08             	mov    0x8(%ebp),%eax
80106546:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106549:	83 f8 20             	cmp    $0x20,%eax
8010654c:	75 05                	jne    80106553 <trap+0x2d7>
    yield();
8010654e:	e8 11 df ff ff       	call   80104464 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106553:	e8 d8 d4 ff ff       	call   80103a30 <myproc>
80106558:	85 c0                	test   %eax,%eax
8010655a:	74 26                	je     80106582 <trap+0x306>
8010655c:	e8 cf d4 ff ff       	call   80103a30 <myproc>
80106561:	8b 40 24             	mov    0x24(%eax),%eax
80106564:	85 c0                	test   %eax,%eax
80106566:	74 1a                	je     80106582 <trap+0x306>
80106568:	8b 45 08             	mov    0x8(%ebp),%eax
8010656b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010656f:	0f b7 c0             	movzwl %ax,%eax
80106572:	83 e0 03             	and    $0x3,%eax
80106575:	83 f8 03             	cmp    $0x3,%eax
80106578:	75 08                	jne    80106582 <trap+0x306>
    exit();
8010657a:	e8 64 d9 ff ff       	call   80103ee3 <exit>
8010657f:	eb 01                	jmp    80106582 <trap+0x306>
    return;
80106581:	90                   	nop
}
80106582:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106585:	5b                   	pop    %ebx
80106586:	5e                   	pop    %esi
80106587:	5f                   	pop    %edi
80106588:	5d                   	pop    %ebp
80106589:	c3                   	ret    

8010658a <inb>:
{
8010658a:	55                   	push   %ebp
8010658b:	89 e5                	mov    %esp,%ebp
8010658d:	83 ec 14             	sub    $0x14,%esp
80106590:	8b 45 08             	mov    0x8(%ebp),%eax
80106593:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106597:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010659b:	89 c2                	mov    %eax,%edx
8010659d:	ec                   	in     (%dx),%al
8010659e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801065a1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801065a5:	c9                   	leave  
801065a6:	c3                   	ret    

801065a7 <outb>:
{
801065a7:	55                   	push   %ebp
801065a8:	89 e5                	mov    %esp,%ebp
801065aa:	83 ec 08             	sub    $0x8,%esp
801065ad:	8b 45 08             	mov    0x8(%ebp),%eax
801065b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801065b3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801065b7:	89 d0                	mov    %edx,%eax
801065b9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801065bc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801065c0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801065c4:	ee                   	out    %al,(%dx)
}
801065c5:	90                   	nop
801065c6:	c9                   	leave  
801065c7:	c3                   	ret    

801065c8 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801065c8:	55                   	push   %ebp
801065c9:	89 e5                	mov    %esp,%ebp
801065cb:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801065ce:	6a 00                	push   $0x0
801065d0:	68 fa 03 00 00       	push   $0x3fa
801065d5:	e8 cd ff ff ff       	call   801065a7 <outb>
801065da:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801065dd:	68 80 00 00 00       	push   $0x80
801065e2:	68 fb 03 00 00       	push   $0x3fb
801065e7:	e8 bb ff ff ff       	call   801065a7 <outb>
801065ec:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801065ef:	6a 0c                	push   $0xc
801065f1:	68 f8 03 00 00       	push   $0x3f8
801065f6:	e8 ac ff ff ff       	call   801065a7 <outb>
801065fb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801065fe:	6a 00                	push   $0x0
80106600:	68 f9 03 00 00       	push   $0x3f9
80106605:	e8 9d ff ff ff       	call   801065a7 <outb>
8010660a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010660d:	6a 03                	push   $0x3
8010660f:	68 fb 03 00 00       	push   $0x3fb
80106614:	e8 8e ff ff ff       	call   801065a7 <outb>
80106619:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010661c:	6a 00                	push   $0x0
8010661e:	68 fc 03 00 00       	push   $0x3fc
80106623:	e8 7f ff ff ff       	call   801065a7 <outb>
80106628:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010662b:	6a 01                	push   $0x1
8010662d:	68 f9 03 00 00       	push   $0x3f9
80106632:	e8 70 ff ff ff       	call   801065a7 <outb>
80106637:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010663a:	68 fd 03 00 00       	push   $0x3fd
8010663f:	e8 46 ff ff ff       	call   8010658a <inb>
80106644:	83 c4 04             	add    $0x4,%esp
80106647:	3c ff                	cmp    $0xff,%al
80106649:	74 61                	je     801066ac <uartinit+0xe4>
    return;
  uart = 1;
8010664b:	c7 05 78 76 19 80 01 	movl   $0x1,0x80197678
80106652:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106655:	68 fa 03 00 00       	push   $0x3fa
8010665a:	e8 2b ff ff ff       	call   8010658a <inb>
8010665f:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106662:	68 f8 03 00 00       	push   $0x3f8
80106667:	e8 1e ff ff ff       	call   8010658a <inb>
8010666c:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010666f:	83 ec 08             	sub    $0x8,%esp
80106672:	6a 00                	push   $0x0
80106674:	6a 04                	push   $0x4
80106676:	e8 b3 bf ff ff       	call   8010262e <ioapicenable>
8010667b:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010667e:	c7 45 f4 40 a9 10 80 	movl   $0x8010a940,-0xc(%ebp)
80106685:	eb 19                	jmp    801066a0 <uartinit+0xd8>
    uartputc(*p);
80106687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010668a:	0f b6 00             	movzbl (%eax),%eax
8010668d:	0f be c0             	movsbl %al,%eax
80106690:	83 ec 0c             	sub    $0xc,%esp
80106693:	50                   	push   %eax
80106694:	e8 16 00 00 00       	call   801066af <uartputc>
80106699:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010669c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801066a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a3:	0f b6 00             	movzbl (%eax),%eax
801066a6:	84 c0                	test   %al,%al
801066a8:	75 dd                	jne    80106687 <uartinit+0xbf>
801066aa:	eb 01                	jmp    801066ad <uartinit+0xe5>
    return;
801066ac:	90                   	nop
}
801066ad:	c9                   	leave  
801066ae:	c3                   	ret    

801066af <uartputc>:

void
uartputc(int c)
{
801066af:	55                   	push   %ebp
801066b0:	89 e5                	mov    %esp,%ebp
801066b2:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801066b5:	a1 78 76 19 80       	mov    0x80197678,%eax
801066ba:	85 c0                	test   %eax,%eax
801066bc:	74 53                	je     80106711 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801066be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066c5:	eb 11                	jmp    801066d8 <uartputc+0x29>
    microdelay(10);
801066c7:	83 ec 0c             	sub    $0xc,%esp
801066ca:	6a 0a                	push   $0xa
801066cc:	e8 66 c4 ff ff       	call   80102b37 <microdelay>
801066d1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801066d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801066d8:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801066dc:	7f 1a                	jg     801066f8 <uartputc+0x49>
801066de:	83 ec 0c             	sub    $0xc,%esp
801066e1:	68 fd 03 00 00       	push   $0x3fd
801066e6:	e8 9f fe ff ff       	call   8010658a <inb>
801066eb:	83 c4 10             	add    $0x10,%esp
801066ee:	0f b6 c0             	movzbl %al,%eax
801066f1:	83 e0 20             	and    $0x20,%eax
801066f4:	85 c0                	test   %eax,%eax
801066f6:	74 cf                	je     801066c7 <uartputc+0x18>
  outb(COM1+0, c);
801066f8:	8b 45 08             	mov    0x8(%ebp),%eax
801066fb:	0f b6 c0             	movzbl %al,%eax
801066fe:	83 ec 08             	sub    $0x8,%esp
80106701:	50                   	push   %eax
80106702:	68 f8 03 00 00       	push   $0x3f8
80106707:	e8 9b fe ff ff       	call   801065a7 <outb>
8010670c:	83 c4 10             	add    $0x10,%esp
8010670f:	eb 01                	jmp    80106712 <uartputc+0x63>
    return;
80106711:	90                   	nop
}
80106712:	c9                   	leave  
80106713:	c3                   	ret    

80106714 <uartgetc>:

static int
uartgetc(void)
{
80106714:	55                   	push   %ebp
80106715:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106717:	a1 78 76 19 80       	mov    0x80197678,%eax
8010671c:	85 c0                	test   %eax,%eax
8010671e:	75 07                	jne    80106727 <uartgetc+0x13>
    return -1;
80106720:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106725:	eb 2e                	jmp    80106755 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106727:	68 fd 03 00 00       	push   $0x3fd
8010672c:	e8 59 fe ff ff       	call   8010658a <inb>
80106731:	83 c4 04             	add    $0x4,%esp
80106734:	0f b6 c0             	movzbl %al,%eax
80106737:	83 e0 01             	and    $0x1,%eax
8010673a:	85 c0                	test   %eax,%eax
8010673c:	75 07                	jne    80106745 <uartgetc+0x31>
    return -1;
8010673e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106743:	eb 10                	jmp    80106755 <uartgetc+0x41>
  return inb(COM1+0);
80106745:	68 f8 03 00 00       	push   $0x3f8
8010674a:	e8 3b fe ff ff       	call   8010658a <inb>
8010674f:	83 c4 04             	add    $0x4,%esp
80106752:	0f b6 c0             	movzbl %al,%eax
}
80106755:	c9                   	leave  
80106756:	c3                   	ret    

80106757 <uartintr>:

void
uartintr(void)
{
80106757:	55                   	push   %ebp
80106758:	89 e5                	mov    %esp,%ebp
8010675a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010675d:	83 ec 0c             	sub    $0xc,%esp
80106760:	68 14 67 10 80       	push   $0x80106714
80106765:	e8 6c a0 ff ff       	call   801007d6 <consoleintr>
8010676a:	83 c4 10             	add    $0x10,%esp
}
8010676d:	90                   	nop
8010676e:	c9                   	leave  
8010676f:	c3                   	ret    

80106770 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106770:	6a 00                	push   $0x0
  pushl $0
80106772:	6a 00                	push   $0x0
  jmp alltraps
80106774:	e9 17 f9 ff ff       	jmp    80106090 <alltraps>

80106779 <vector1>:
.globl vector1
vector1:
  pushl $0
80106779:	6a 00                	push   $0x0
  pushl $1
8010677b:	6a 01                	push   $0x1
  jmp alltraps
8010677d:	e9 0e f9 ff ff       	jmp    80106090 <alltraps>

80106782 <vector2>:
.globl vector2
vector2:
  pushl $0
80106782:	6a 00                	push   $0x0
  pushl $2
80106784:	6a 02                	push   $0x2
  jmp alltraps
80106786:	e9 05 f9 ff ff       	jmp    80106090 <alltraps>

8010678b <vector3>:
.globl vector3
vector3:
  pushl $0
8010678b:	6a 00                	push   $0x0
  pushl $3
8010678d:	6a 03                	push   $0x3
  jmp alltraps
8010678f:	e9 fc f8 ff ff       	jmp    80106090 <alltraps>

80106794 <vector4>:
.globl vector4
vector4:
  pushl $0
80106794:	6a 00                	push   $0x0
  pushl $4
80106796:	6a 04                	push   $0x4
  jmp alltraps
80106798:	e9 f3 f8 ff ff       	jmp    80106090 <alltraps>

8010679d <vector5>:
.globl vector5
vector5:
  pushl $0
8010679d:	6a 00                	push   $0x0
  pushl $5
8010679f:	6a 05                	push   $0x5
  jmp alltraps
801067a1:	e9 ea f8 ff ff       	jmp    80106090 <alltraps>

801067a6 <vector6>:
.globl vector6
vector6:
  pushl $0
801067a6:	6a 00                	push   $0x0
  pushl $6
801067a8:	6a 06                	push   $0x6
  jmp alltraps
801067aa:	e9 e1 f8 ff ff       	jmp    80106090 <alltraps>

801067af <vector7>:
.globl vector7
vector7:
  pushl $0
801067af:	6a 00                	push   $0x0
  pushl $7
801067b1:	6a 07                	push   $0x7
  jmp alltraps
801067b3:	e9 d8 f8 ff ff       	jmp    80106090 <alltraps>

801067b8 <vector8>:
.globl vector8
vector8:
  pushl $8
801067b8:	6a 08                	push   $0x8
  jmp alltraps
801067ba:	e9 d1 f8 ff ff       	jmp    80106090 <alltraps>

801067bf <vector9>:
.globl vector9
vector9:
  pushl $0
801067bf:	6a 00                	push   $0x0
  pushl $9
801067c1:	6a 09                	push   $0x9
  jmp alltraps
801067c3:	e9 c8 f8 ff ff       	jmp    80106090 <alltraps>

801067c8 <vector10>:
.globl vector10
vector10:
  pushl $10
801067c8:	6a 0a                	push   $0xa
  jmp alltraps
801067ca:	e9 c1 f8 ff ff       	jmp    80106090 <alltraps>

801067cf <vector11>:
.globl vector11
vector11:
  pushl $11
801067cf:	6a 0b                	push   $0xb
  jmp alltraps
801067d1:	e9 ba f8 ff ff       	jmp    80106090 <alltraps>

801067d6 <vector12>:
.globl vector12
vector12:
  pushl $12
801067d6:	6a 0c                	push   $0xc
  jmp alltraps
801067d8:	e9 b3 f8 ff ff       	jmp    80106090 <alltraps>

801067dd <vector13>:
.globl vector13
vector13:
  pushl $13
801067dd:	6a 0d                	push   $0xd
  jmp alltraps
801067df:	e9 ac f8 ff ff       	jmp    80106090 <alltraps>

801067e4 <vector14>:
.globl vector14
vector14:
  pushl $14
801067e4:	6a 0e                	push   $0xe
  jmp alltraps
801067e6:	e9 a5 f8 ff ff       	jmp    80106090 <alltraps>

801067eb <vector15>:
.globl vector15
vector15:
  pushl $0
801067eb:	6a 00                	push   $0x0
  pushl $15
801067ed:	6a 0f                	push   $0xf
  jmp alltraps
801067ef:	e9 9c f8 ff ff       	jmp    80106090 <alltraps>

801067f4 <vector16>:
.globl vector16
vector16:
  pushl $0
801067f4:	6a 00                	push   $0x0
  pushl $16
801067f6:	6a 10                	push   $0x10
  jmp alltraps
801067f8:	e9 93 f8 ff ff       	jmp    80106090 <alltraps>

801067fd <vector17>:
.globl vector17
vector17:
  pushl $17
801067fd:	6a 11                	push   $0x11
  jmp alltraps
801067ff:	e9 8c f8 ff ff       	jmp    80106090 <alltraps>

80106804 <vector18>:
.globl vector18
vector18:
  pushl $0
80106804:	6a 00                	push   $0x0
  pushl $18
80106806:	6a 12                	push   $0x12
  jmp alltraps
80106808:	e9 83 f8 ff ff       	jmp    80106090 <alltraps>

8010680d <vector19>:
.globl vector19
vector19:
  pushl $0
8010680d:	6a 00                	push   $0x0
  pushl $19
8010680f:	6a 13                	push   $0x13
  jmp alltraps
80106811:	e9 7a f8 ff ff       	jmp    80106090 <alltraps>

80106816 <vector20>:
.globl vector20
vector20:
  pushl $0
80106816:	6a 00                	push   $0x0
  pushl $20
80106818:	6a 14                	push   $0x14
  jmp alltraps
8010681a:	e9 71 f8 ff ff       	jmp    80106090 <alltraps>

8010681f <vector21>:
.globl vector21
vector21:
  pushl $0
8010681f:	6a 00                	push   $0x0
  pushl $21
80106821:	6a 15                	push   $0x15
  jmp alltraps
80106823:	e9 68 f8 ff ff       	jmp    80106090 <alltraps>

80106828 <vector22>:
.globl vector22
vector22:
  pushl $0
80106828:	6a 00                	push   $0x0
  pushl $22
8010682a:	6a 16                	push   $0x16
  jmp alltraps
8010682c:	e9 5f f8 ff ff       	jmp    80106090 <alltraps>

80106831 <vector23>:
.globl vector23
vector23:
  pushl $0
80106831:	6a 00                	push   $0x0
  pushl $23
80106833:	6a 17                	push   $0x17
  jmp alltraps
80106835:	e9 56 f8 ff ff       	jmp    80106090 <alltraps>

8010683a <vector24>:
.globl vector24
vector24:
  pushl $0
8010683a:	6a 00                	push   $0x0
  pushl $24
8010683c:	6a 18                	push   $0x18
  jmp alltraps
8010683e:	e9 4d f8 ff ff       	jmp    80106090 <alltraps>

80106843 <vector25>:
.globl vector25
vector25:
  pushl $0
80106843:	6a 00                	push   $0x0
  pushl $25
80106845:	6a 19                	push   $0x19
  jmp alltraps
80106847:	e9 44 f8 ff ff       	jmp    80106090 <alltraps>

8010684c <vector26>:
.globl vector26
vector26:
  pushl $0
8010684c:	6a 00                	push   $0x0
  pushl $26
8010684e:	6a 1a                	push   $0x1a
  jmp alltraps
80106850:	e9 3b f8 ff ff       	jmp    80106090 <alltraps>

80106855 <vector27>:
.globl vector27
vector27:
  pushl $0
80106855:	6a 00                	push   $0x0
  pushl $27
80106857:	6a 1b                	push   $0x1b
  jmp alltraps
80106859:	e9 32 f8 ff ff       	jmp    80106090 <alltraps>

8010685e <vector28>:
.globl vector28
vector28:
  pushl $0
8010685e:	6a 00                	push   $0x0
  pushl $28
80106860:	6a 1c                	push   $0x1c
  jmp alltraps
80106862:	e9 29 f8 ff ff       	jmp    80106090 <alltraps>

80106867 <vector29>:
.globl vector29
vector29:
  pushl $0
80106867:	6a 00                	push   $0x0
  pushl $29
80106869:	6a 1d                	push   $0x1d
  jmp alltraps
8010686b:	e9 20 f8 ff ff       	jmp    80106090 <alltraps>

80106870 <vector30>:
.globl vector30
vector30:
  pushl $0
80106870:	6a 00                	push   $0x0
  pushl $30
80106872:	6a 1e                	push   $0x1e
  jmp alltraps
80106874:	e9 17 f8 ff ff       	jmp    80106090 <alltraps>

80106879 <vector31>:
.globl vector31
vector31:
  pushl $0
80106879:	6a 00                	push   $0x0
  pushl $31
8010687b:	6a 1f                	push   $0x1f
  jmp alltraps
8010687d:	e9 0e f8 ff ff       	jmp    80106090 <alltraps>

80106882 <vector32>:
.globl vector32
vector32:
  pushl $0
80106882:	6a 00                	push   $0x0
  pushl $32
80106884:	6a 20                	push   $0x20
  jmp alltraps
80106886:	e9 05 f8 ff ff       	jmp    80106090 <alltraps>

8010688b <vector33>:
.globl vector33
vector33:
  pushl $0
8010688b:	6a 00                	push   $0x0
  pushl $33
8010688d:	6a 21                	push   $0x21
  jmp alltraps
8010688f:	e9 fc f7 ff ff       	jmp    80106090 <alltraps>

80106894 <vector34>:
.globl vector34
vector34:
  pushl $0
80106894:	6a 00                	push   $0x0
  pushl $34
80106896:	6a 22                	push   $0x22
  jmp alltraps
80106898:	e9 f3 f7 ff ff       	jmp    80106090 <alltraps>

8010689d <vector35>:
.globl vector35
vector35:
  pushl $0
8010689d:	6a 00                	push   $0x0
  pushl $35
8010689f:	6a 23                	push   $0x23
  jmp alltraps
801068a1:	e9 ea f7 ff ff       	jmp    80106090 <alltraps>

801068a6 <vector36>:
.globl vector36
vector36:
  pushl $0
801068a6:	6a 00                	push   $0x0
  pushl $36
801068a8:	6a 24                	push   $0x24
  jmp alltraps
801068aa:	e9 e1 f7 ff ff       	jmp    80106090 <alltraps>

801068af <vector37>:
.globl vector37
vector37:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $37
801068b1:	6a 25                	push   $0x25
  jmp alltraps
801068b3:	e9 d8 f7 ff ff       	jmp    80106090 <alltraps>

801068b8 <vector38>:
.globl vector38
vector38:
  pushl $0
801068b8:	6a 00                	push   $0x0
  pushl $38
801068ba:	6a 26                	push   $0x26
  jmp alltraps
801068bc:	e9 cf f7 ff ff       	jmp    80106090 <alltraps>

801068c1 <vector39>:
.globl vector39
vector39:
  pushl $0
801068c1:	6a 00                	push   $0x0
  pushl $39
801068c3:	6a 27                	push   $0x27
  jmp alltraps
801068c5:	e9 c6 f7 ff ff       	jmp    80106090 <alltraps>

801068ca <vector40>:
.globl vector40
vector40:
  pushl $0
801068ca:	6a 00                	push   $0x0
  pushl $40
801068cc:	6a 28                	push   $0x28
  jmp alltraps
801068ce:	e9 bd f7 ff ff       	jmp    80106090 <alltraps>

801068d3 <vector41>:
.globl vector41
vector41:
  pushl $0
801068d3:	6a 00                	push   $0x0
  pushl $41
801068d5:	6a 29                	push   $0x29
  jmp alltraps
801068d7:	e9 b4 f7 ff ff       	jmp    80106090 <alltraps>

801068dc <vector42>:
.globl vector42
vector42:
  pushl $0
801068dc:	6a 00                	push   $0x0
  pushl $42
801068de:	6a 2a                	push   $0x2a
  jmp alltraps
801068e0:	e9 ab f7 ff ff       	jmp    80106090 <alltraps>

801068e5 <vector43>:
.globl vector43
vector43:
  pushl $0
801068e5:	6a 00                	push   $0x0
  pushl $43
801068e7:	6a 2b                	push   $0x2b
  jmp alltraps
801068e9:	e9 a2 f7 ff ff       	jmp    80106090 <alltraps>

801068ee <vector44>:
.globl vector44
vector44:
  pushl $0
801068ee:	6a 00                	push   $0x0
  pushl $44
801068f0:	6a 2c                	push   $0x2c
  jmp alltraps
801068f2:	e9 99 f7 ff ff       	jmp    80106090 <alltraps>

801068f7 <vector45>:
.globl vector45
vector45:
  pushl $0
801068f7:	6a 00                	push   $0x0
  pushl $45
801068f9:	6a 2d                	push   $0x2d
  jmp alltraps
801068fb:	e9 90 f7 ff ff       	jmp    80106090 <alltraps>

80106900 <vector46>:
.globl vector46
vector46:
  pushl $0
80106900:	6a 00                	push   $0x0
  pushl $46
80106902:	6a 2e                	push   $0x2e
  jmp alltraps
80106904:	e9 87 f7 ff ff       	jmp    80106090 <alltraps>

80106909 <vector47>:
.globl vector47
vector47:
  pushl $0
80106909:	6a 00                	push   $0x0
  pushl $47
8010690b:	6a 2f                	push   $0x2f
  jmp alltraps
8010690d:	e9 7e f7 ff ff       	jmp    80106090 <alltraps>

80106912 <vector48>:
.globl vector48
vector48:
  pushl $0
80106912:	6a 00                	push   $0x0
  pushl $48
80106914:	6a 30                	push   $0x30
  jmp alltraps
80106916:	e9 75 f7 ff ff       	jmp    80106090 <alltraps>

8010691b <vector49>:
.globl vector49
vector49:
  pushl $0
8010691b:	6a 00                	push   $0x0
  pushl $49
8010691d:	6a 31                	push   $0x31
  jmp alltraps
8010691f:	e9 6c f7 ff ff       	jmp    80106090 <alltraps>

80106924 <vector50>:
.globl vector50
vector50:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $50
80106926:	6a 32                	push   $0x32
  jmp alltraps
80106928:	e9 63 f7 ff ff       	jmp    80106090 <alltraps>

8010692d <vector51>:
.globl vector51
vector51:
  pushl $0
8010692d:	6a 00                	push   $0x0
  pushl $51
8010692f:	6a 33                	push   $0x33
  jmp alltraps
80106931:	e9 5a f7 ff ff       	jmp    80106090 <alltraps>

80106936 <vector52>:
.globl vector52
vector52:
  pushl $0
80106936:	6a 00                	push   $0x0
  pushl $52
80106938:	6a 34                	push   $0x34
  jmp alltraps
8010693a:	e9 51 f7 ff ff       	jmp    80106090 <alltraps>

8010693f <vector53>:
.globl vector53
vector53:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $53
80106941:	6a 35                	push   $0x35
  jmp alltraps
80106943:	e9 48 f7 ff ff       	jmp    80106090 <alltraps>

80106948 <vector54>:
.globl vector54
vector54:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $54
8010694a:	6a 36                	push   $0x36
  jmp alltraps
8010694c:	e9 3f f7 ff ff       	jmp    80106090 <alltraps>

80106951 <vector55>:
.globl vector55
vector55:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $55
80106953:	6a 37                	push   $0x37
  jmp alltraps
80106955:	e9 36 f7 ff ff       	jmp    80106090 <alltraps>

8010695a <vector56>:
.globl vector56
vector56:
  pushl $0
8010695a:	6a 00                	push   $0x0
  pushl $56
8010695c:	6a 38                	push   $0x38
  jmp alltraps
8010695e:	e9 2d f7 ff ff       	jmp    80106090 <alltraps>

80106963 <vector57>:
.globl vector57
vector57:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $57
80106965:	6a 39                	push   $0x39
  jmp alltraps
80106967:	e9 24 f7 ff ff       	jmp    80106090 <alltraps>

8010696c <vector58>:
.globl vector58
vector58:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $58
8010696e:	6a 3a                	push   $0x3a
  jmp alltraps
80106970:	e9 1b f7 ff ff       	jmp    80106090 <alltraps>

80106975 <vector59>:
.globl vector59
vector59:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $59
80106977:	6a 3b                	push   $0x3b
  jmp alltraps
80106979:	e9 12 f7 ff ff       	jmp    80106090 <alltraps>

8010697e <vector60>:
.globl vector60
vector60:
  pushl $0
8010697e:	6a 00                	push   $0x0
  pushl $60
80106980:	6a 3c                	push   $0x3c
  jmp alltraps
80106982:	e9 09 f7 ff ff       	jmp    80106090 <alltraps>

80106987 <vector61>:
.globl vector61
vector61:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $61
80106989:	6a 3d                	push   $0x3d
  jmp alltraps
8010698b:	e9 00 f7 ff ff       	jmp    80106090 <alltraps>

80106990 <vector62>:
.globl vector62
vector62:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $62
80106992:	6a 3e                	push   $0x3e
  jmp alltraps
80106994:	e9 f7 f6 ff ff       	jmp    80106090 <alltraps>

80106999 <vector63>:
.globl vector63
vector63:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $63
8010699b:	6a 3f                	push   $0x3f
  jmp alltraps
8010699d:	e9 ee f6 ff ff       	jmp    80106090 <alltraps>

801069a2 <vector64>:
.globl vector64
vector64:
  pushl $0
801069a2:	6a 00                	push   $0x0
  pushl $64
801069a4:	6a 40                	push   $0x40
  jmp alltraps
801069a6:	e9 e5 f6 ff ff       	jmp    80106090 <alltraps>

801069ab <vector65>:
.globl vector65
vector65:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $65
801069ad:	6a 41                	push   $0x41
  jmp alltraps
801069af:	e9 dc f6 ff ff       	jmp    80106090 <alltraps>

801069b4 <vector66>:
.globl vector66
vector66:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $66
801069b6:	6a 42                	push   $0x42
  jmp alltraps
801069b8:	e9 d3 f6 ff ff       	jmp    80106090 <alltraps>

801069bd <vector67>:
.globl vector67
vector67:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $67
801069bf:	6a 43                	push   $0x43
  jmp alltraps
801069c1:	e9 ca f6 ff ff       	jmp    80106090 <alltraps>

801069c6 <vector68>:
.globl vector68
vector68:
  pushl $0
801069c6:	6a 00                	push   $0x0
  pushl $68
801069c8:	6a 44                	push   $0x44
  jmp alltraps
801069ca:	e9 c1 f6 ff ff       	jmp    80106090 <alltraps>

801069cf <vector69>:
.globl vector69
vector69:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $69
801069d1:	6a 45                	push   $0x45
  jmp alltraps
801069d3:	e9 b8 f6 ff ff       	jmp    80106090 <alltraps>

801069d8 <vector70>:
.globl vector70
vector70:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $70
801069da:	6a 46                	push   $0x46
  jmp alltraps
801069dc:	e9 af f6 ff ff       	jmp    80106090 <alltraps>

801069e1 <vector71>:
.globl vector71
vector71:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $71
801069e3:	6a 47                	push   $0x47
  jmp alltraps
801069e5:	e9 a6 f6 ff ff       	jmp    80106090 <alltraps>

801069ea <vector72>:
.globl vector72
vector72:
  pushl $0
801069ea:	6a 00                	push   $0x0
  pushl $72
801069ec:	6a 48                	push   $0x48
  jmp alltraps
801069ee:	e9 9d f6 ff ff       	jmp    80106090 <alltraps>

801069f3 <vector73>:
.globl vector73
vector73:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $73
801069f5:	6a 49                	push   $0x49
  jmp alltraps
801069f7:	e9 94 f6 ff ff       	jmp    80106090 <alltraps>

801069fc <vector74>:
.globl vector74
vector74:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $74
801069fe:	6a 4a                	push   $0x4a
  jmp alltraps
80106a00:	e9 8b f6 ff ff       	jmp    80106090 <alltraps>

80106a05 <vector75>:
.globl vector75
vector75:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $75
80106a07:	6a 4b                	push   $0x4b
  jmp alltraps
80106a09:	e9 82 f6 ff ff       	jmp    80106090 <alltraps>

80106a0e <vector76>:
.globl vector76
vector76:
  pushl $0
80106a0e:	6a 00                	push   $0x0
  pushl $76
80106a10:	6a 4c                	push   $0x4c
  jmp alltraps
80106a12:	e9 79 f6 ff ff       	jmp    80106090 <alltraps>

80106a17 <vector77>:
.globl vector77
vector77:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $77
80106a19:	6a 4d                	push   $0x4d
  jmp alltraps
80106a1b:	e9 70 f6 ff ff       	jmp    80106090 <alltraps>

80106a20 <vector78>:
.globl vector78
vector78:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $78
80106a22:	6a 4e                	push   $0x4e
  jmp alltraps
80106a24:	e9 67 f6 ff ff       	jmp    80106090 <alltraps>

80106a29 <vector79>:
.globl vector79
vector79:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $79
80106a2b:	6a 4f                	push   $0x4f
  jmp alltraps
80106a2d:	e9 5e f6 ff ff       	jmp    80106090 <alltraps>

80106a32 <vector80>:
.globl vector80
vector80:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $80
80106a34:	6a 50                	push   $0x50
  jmp alltraps
80106a36:	e9 55 f6 ff ff       	jmp    80106090 <alltraps>

80106a3b <vector81>:
.globl vector81
vector81:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $81
80106a3d:	6a 51                	push   $0x51
  jmp alltraps
80106a3f:	e9 4c f6 ff ff       	jmp    80106090 <alltraps>

80106a44 <vector82>:
.globl vector82
vector82:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $82
80106a46:	6a 52                	push   $0x52
  jmp alltraps
80106a48:	e9 43 f6 ff ff       	jmp    80106090 <alltraps>

80106a4d <vector83>:
.globl vector83
vector83:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $83
80106a4f:	6a 53                	push   $0x53
  jmp alltraps
80106a51:	e9 3a f6 ff ff       	jmp    80106090 <alltraps>

80106a56 <vector84>:
.globl vector84
vector84:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $84
80106a58:	6a 54                	push   $0x54
  jmp alltraps
80106a5a:	e9 31 f6 ff ff       	jmp    80106090 <alltraps>

80106a5f <vector85>:
.globl vector85
vector85:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $85
80106a61:	6a 55                	push   $0x55
  jmp alltraps
80106a63:	e9 28 f6 ff ff       	jmp    80106090 <alltraps>

80106a68 <vector86>:
.globl vector86
vector86:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $86
80106a6a:	6a 56                	push   $0x56
  jmp alltraps
80106a6c:	e9 1f f6 ff ff       	jmp    80106090 <alltraps>

80106a71 <vector87>:
.globl vector87
vector87:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $87
80106a73:	6a 57                	push   $0x57
  jmp alltraps
80106a75:	e9 16 f6 ff ff       	jmp    80106090 <alltraps>

80106a7a <vector88>:
.globl vector88
vector88:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $88
80106a7c:	6a 58                	push   $0x58
  jmp alltraps
80106a7e:	e9 0d f6 ff ff       	jmp    80106090 <alltraps>

80106a83 <vector89>:
.globl vector89
vector89:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $89
80106a85:	6a 59                	push   $0x59
  jmp alltraps
80106a87:	e9 04 f6 ff ff       	jmp    80106090 <alltraps>

80106a8c <vector90>:
.globl vector90
vector90:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $90
80106a8e:	6a 5a                	push   $0x5a
  jmp alltraps
80106a90:	e9 fb f5 ff ff       	jmp    80106090 <alltraps>

80106a95 <vector91>:
.globl vector91
vector91:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $91
80106a97:	6a 5b                	push   $0x5b
  jmp alltraps
80106a99:	e9 f2 f5 ff ff       	jmp    80106090 <alltraps>

80106a9e <vector92>:
.globl vector92
vector92:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $92
80106aa0:	6a 5c                	push   $0x5c
  jmp alltraps
80106aa2:	e9 e9 f5 ff ff       	jmp    80106090 <alltraps>

80106aa7 <vector93>:
.globl vector93
vector93:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $93
80106aa9:	6a 5d                	push   $0x5d
  jmp alltraps
80106aab:	e9 e0 f5 ff ff       	jmp    80106090 <alltraps>

80106ab0 <vector94>:
.globl vector94
vector94:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $94
80106ab2:	6a 5e                	push   $0x5e
  jmp alltraps
80106ab4:	e9 d7 f5 ff ff       	jmp    80106090 <alltraps>

80106ab9 <vector95>:
.globl vector95
vector95:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $95
80106abb:	6a 5f                	push   $0x5f
  jmp alltraps
80106abd:	e9 ce f5 ff ff       	jmp    80106090 <alltraps>

80106ac2 <vector96>:
.globl vector96
vector96:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $96
80106ac4:	6a 60                	push   $0x60
  jmp alltraps
80106ac6:	e9 c5 f5 ff ff       	jmp    80106090 <alltraps>

80106acb <vector97>:
.globl vector97
vector97:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $97
80106acd:	6a 61                	push   $0x61
  jmp alltraps
80106acf:	e9 bc f5 ff ff       	jmp    80106090 <alltraps>

80106ad4 <vector98>:
.globl vector98
vector98:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $98
80106ad6:	6a 62                	push   $0x62
  jmp alltraps
80106ad8:	e9 b3 f5 ff ff       	jmp    80106090 <alltraps>

80106add <vector99>:
.globl vector99
vector99:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $99
80106adf:	6a 63                	push   $0x63
  jmp alltraps
80106ae1:	e9 aa f5 ff ff       	jmp    80106090 <alltraps>

80106ae6 <vector100>:
.globl vector100
vector100:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $100
80106ae8:	6a 64                	push   $0x64
  jmp alltraps
80106aea:	e9 a1 f5 ff ff       	jmp    80106090 <alltraps>

80106aef <vector101>:
.globl vector101
vector101:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $101
80106af1:	6a 65                	push   $0x65
  jmp alltraps
80106af3:	e9 98 f5 ff ff       	jmp    80106090 <alltraps>

80106af8 <vector102>:
.globl vector102
vector102:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $102
80106afa:	6a 66                	push   $0x66
  jmp alltraps
80106afc:	e9 8f f5 ff ff       	jmp    80106090 <alltraps>

80106b01 <vector103>:
.globl vector103
vector103:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $103
80106b03:	6a 67                	push   $0x67
  jmp alltraps
80106b05:	e9 86 f5 ff ff       	jmp    80106090 <alltraps>

80106b0a <vector104>:
.globl vector104
vector104:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $104
80106b0c:	6a 68                	push   $0x68
  jmp alltraps
80106b0e:	e9 7d f5 ff ff       	jmp    80106090 <alltraps>

80106b13 <vector105>:
.globl vector105
vector105:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $105
80106b15:	6a 69                	push   $0x69
  jmp alltraps
80106b17:	e9 74 f5 ff ff       	jmp    80106090 <alltraps>

80106b1c <vector106>:
.globl vector106
vector106:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $106
80106b1e:	6a 6a                	push   $0x6a
  jmp alltraps
80106b20:	e9 6b f5 ff ff       	jmp    80106090 <alltraps>

80106b25 <vector107>:
.globl vector107
vector107:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $107
80106b27:	6a 6b                	push   $0x6b
  jmp alltraps
80106b29:	e9 62 f5 ff ff       	jmp    80106090 <alltraps>

80106b2e <vector108>:
.globl vector108
vector108:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $108
80106b30:	6a 6c                	push   $0x6c
  jmp alltraps
80106b32:	e9 59 f5 ff ff       	jmp    80106090 <alltraps>

80106b37 <vector109>:
.globl vector109
vector109:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $109
80106b39:	6a 6d                	push   $0x6d
  jmp alltraps
80106b3b:	e9 50 f5 ff ff       	jmp    80106090 <alltraps>

80106b40 <vector110>:
.globl vector110
vector110:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $110
80106b42:	6a 6e                	push   $0x6e
  jmp alltraps
80106b44:	e9 47 f5 ff ff       	jmp    80106090 <alltraps>

80106b49 <vector111>:
.globl vector111
vector111:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $111
80106b4b:	6a 6f                	push   $0x6f
  jmp alltraps
80106b4d:	e9 3e f5 ff ff       	jmp    80106090 <alltraps>

80106b52 <vector112>:
.globl vector112
vector112:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $112
80106b54:	6a 70                	push   $0x70
  jmp alltraps
80106b56:	e9 35 f5 ff ff       	jmp    80106090 <alltraps>

80106b5b <vector113>:
.globl vector113
vector113:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $113
80106b5d:	6a 71                	push   $0x71
  jmp alltraps
80106b5f:	e9 2c f5 ff ff       	jmp    80106090 <alltraps>

80106b64 <vector114>:
.globl vector114
vector114:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $114
80106b66:	6a 72                	push   $0x72
  jmp alltraps
80106b68:	e9 23 f5 ff ff       	jmp    80106090 <alltraps>

80106b6d <vector115>:
.globl vector115
vector115:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $115
80106b6f:	6a 73                	push   $0x73
  jmp alltraps
80106b71:	e9 1a f5 ff ff       	jmp    80106090 <alltraps>

80106b76 <vector116>:
.globl vector116
vector116:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $116
80106b78:	6a 74                	push   $0x74
  jmp alltraps
80106b7a:	e9 11 f5 ff ff       	jmp    80106090 <alltraps>

80106b7f <vector117>:
.globl vector117
vector117:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $117
80106b81:	6a 75                	push   $0x75
  jmp alltraps
80106b83:	e9 08 f5 ff ff       	jmp    80106090 <alltraps>

80106b88 <vector118>:
.globl vector118
vector118:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $118
80106b8a:	6a 76                	push   $0x76
  jmp alltraps
80106b8c:	e9 ff f4 ff ff       	jmp    80106090 <alltraps>

80106b91 <vector119>:
.globl vector119
vector119:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $119
80106b93:	6a 77                	push   $0x77
  jmp alltraps
80106b95:	e9 f6 f4 ff ff       	jmp    80106090 <alltraps>

80106b9a <vector120>:
.globl vector120
vector120:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $120
80106b9c:	6a 78                	push   $0x78
  jmp alltraps
80106b9e:	e9 ed f4 ff ff       	jmp    80106090 <alltraps>

80106ba3 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $121
80106ba5:	6a 79                	push   $0x79
  jmp alltraps
80106ba7:	e9 e4 f4 ff ff       	jmp    80106090 <alltraps>

80106bac <vector122>:
.globl vector122
vector122:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $122
80106bae:	6a 7a                	push   $0x7a
  jmp alltraps
80106bb0:	e9 db f4 ff ff       	jmp    80106090 <alltraps>

80106bb5 <vector123>:
.globl vector123
vector123:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $123
80106bb7:	6a 7b                	push   $0x7b
  jmp alltraps
80106bb9:	e9 d2 f4 ff ff       	jmp    80106090 <alltraps>

80106bbe <vector124>:
.globl vector124
vector124:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $124
80106bc0:	6a 7c                	push   $0x7c
  jmp alltraps
80106bc2:	e9 c9 f4 ff ff       	jmp    80106090 <alltraps>

80106bc7 <vector125>:
.globl vector125
vector125:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $125
80106bc9:	6a 7d                	push   $0x7d
  jmp alltraps
80106bcb:	e9 c0 f4 ff ff       	jmp    80106090 <alltraps>

80106bd0 <vector126>:
.globl vector126
vector126:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $126
80106bd2:	6a 7e                	push   $0x7e
  jmp alltraps
80106bd4:	e9 b7 f4 ff ff       	jmp    80106090 <alltraps>

80106bd9 <vector127>:
.globl vector127
vector127:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $127
80106bdb:	6a 7f                	push   $0x7f
  jmp alltraps
80106bdd:	e9 ae f4 ff ff       	jmp    80106090 <alltraps>

80106be2 <vector128>:
.globl vector128
vector128:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $128
80106be4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106be9:	e9 a2 f4 ff ff       	jmp    80106090 <alltraps>

80106bee <vector129>:
.globl vector129
vector129:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $129
80106bf0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106bf5:	e9 96 f4 ff ff       	jmp    80106090 <alltraps>

80106bfa <vector130>:
.globl vector130
vector130:
  pushl $0
80106bfa:	6a 00                	push   $0x0
  pushl $130
80106bfc:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106c01:	e9 8a f4 ff ff       	jmp    80106090 <alltraps>

80106c06 <vector131>:
.globl vector131
vector131:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $131
80106c08:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106c0d:	e9 7e f4 ff ff       	jmp    80106090 <alltraps>

80106c12 <vector132>:
.globl vector132
vector132:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $132
80106c14:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106c19:	e9 72 f4 ff ff       	jmp    80106090 <alltraps>

80106c1e <vector133>:
.globl vector133
vector133:
  pushl $0
80106c1e:	6a 00                	push   $0x0
  pushl $133
80106c20:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106c25:	e9 66 f4 ff ff       	jmp    80106090 <alltraps>

80106c2a <vector134>:
.globl vector134
vector134:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $134
80106c2c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106c31:	e9 5a f4 ff ff       	jmp    80106090 <alltraps>

80106c36 <vector135>:
.globl vector135
vector135:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $135
80106c38:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106c3d:	e9 4e f4 ff ff       	jmp    80106090 <alltraps>

80106c42 <vector136>:
.globl vector136
vector136:
  pushl $0
80106c42:	6a 00                	push   $0x0
  pushl $136
80106c44:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106c49:	e9 42 f4 ff ff       	jmp    80106090 <alltraps>

80106c4e <vector137>:
.globl vector137
vector137:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $137
80106c50:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106c55:	e9 36 f4 ff ff       	jmp    80106090 <alltraps>

80106c5a <vector138>:
.globl vector138
vector138:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $138
80106c5c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106c61:	e9 2a f4 ff ff       	jmp    80106090 <alltraps>

80106c66 <vector139>:
.globl vector139
vector139:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $139
80106c68:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106c6d:	e9 1e f4 ff ff       	jmp    80106090 <alltraps>

80106c72 <vector140>:
.globl vector140
vector140:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $140
80106c74:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106c79:	e9 12 f4 ff ff       	jmp    80106090 <alltraps>

80106c7e <vector141>:
.globl vector141
vector141:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $141
80106c80:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106c85:	e9 06 f4 ff ff       	jmp    80106090 <alltraps>

80106c8a <vector142>:
.globl vector142
vector142:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $142
80106c8c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106c91:	e9 fa f3 ff ff       	jmp    80106090 <alltraps>

80106c96 <vector143>:
.globl vector143
vector143:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $143
80106c98:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106c9d:	e9 ee f3 ff ff       	jmp    80106090 <alltraps>

80106ca2 <vector144>:
.globl vector144
vector144:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $144
80106ca4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106ca9:	e9 e2 f3 ff ff       	jmp    80106090 <alltraps>

80106cae <vector145>:
.globl vector145
vector145:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $145
80106cb0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106cb5:	e9 d6 f3 ff ff       	jmp    80106090 <alltraps>

80106cba <vector146>:
.globl vector146
vector146:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $146
80106cbc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106cc1:	e9 ca f3 ff ff       	jmp    80106090 <alltraps>

80106cc6 <vector147>:
.globl vector147
vector147:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $147
80106cc8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106ccd:	e9 be f3 ff ff       	jmp    80106090 <alltraps>

80106cd2 <vector148>:
.globl vector148
vector148:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $148
80106cd4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106cd9:	e9 b2 f3 ff ff       	jmp    80106090 <alltraps>

80106cde <vector149>:
.globl vector149
vector149:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $149
80106ce0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106ce5:	e9 a6 f3 ff ff       	jmp    80106090 <alltraps>

80106cea <vector150>:
.globl vector150
vector150:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $150
80106cec:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106cf1:	e9 9a f3 ff ff       	jmp    80106090 <alltraps>

80106cf6 <vector151>:
.globl vector151
vector151:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $151
80106cf8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106cfd:	e9 8e f3 ff ff       	jmp    80106090 <alltraps>

80106d02 <vector152>:
.globl vector152
vector152:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $152
80106d04:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106d09:	e9 82 f3 ff ff       	jmp    80106090 <alltraps>

80106d0e <vector153>:
.globl vector153
vector153:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $153
80106d10:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106d15:	e9 76 f3 ff ff       	jmp    80106090 <alltraps>

80106d1a <vector154>:
.globl vector154
vector154:
  pushl $0
80106d1a:	6a 00                	push   $0x0
  pushl $154
80106d1c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106d21:	e9 6a f3 ff ff       	jmp    80106090 <alltraps>

80106d26 <vector155>:
.globl vector155
vector155:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $155
80106d28:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106d2d:	e9 5e f3 ff ff       	jmp    80106090 <alltraps>

80106d32 <vector156>:
.globl vector156
vector156:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $156
80106d34:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106d39:	e9 52 f3 ff ff       	jmp    80106090 <alltraps>

80106d3e <vector157>:
.globl vector157
vector157:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $157
80106d40:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106d45:	e9 46 f3 ff ff       	jmp    80106090 <alltraps>

80106d4a <vector158>:
.globl vector158
vector158:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $158
80106d4c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106d51:	e9 3a f3 ff ff       	jmp    80106090 <alltraps>

80106d56 <vector159>:
.globl vector159
vector159:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $159
80106d58:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106d5d:	e9 2e f3 ff ff       	jmp    80106090 <alltraps>

80106d62 <vector160>:
.globl vector160
vector160:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $160
80106d64:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106d69:	e9 22 f3 ff ff       	jmp    80106090 <alltraps>

80106d6e <vector161>:
.globl vector161
vector161:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $161
80106d70:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106d75:	e9 16 f3 ff ff       	jmp    80106090 <alltraps>

80106d7a <vector162>:
.globl vector162
vector162:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $162
80106d7c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106d81:	e9 0a f3 ff ff       	jmp    80106090 <alltraps>

80106d86 <vector163>:
.globl vector163
vector163:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $163
80106d88:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106d8d:	e9 fe f2 ff ff       	jmp    80106090 <alltraps>

80106d92 <vector164>:
.globl vector164
vector164:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $164
80106d94:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106d99:	e9 f2 f2 ff ff       	jmp    80106090 <alltraps>

80106d9e <vector165>:
.globl vector165
vector165:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $165
80106da0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106da5:	e9 e6 f2 ff ff       	jmp    80106090 <alltraps>

80106daa <vector166>:
.globl vector166
vector166:
  pushl $0
80106daa:	6a 00                	push   $0x0
  pushl $166
80106dac:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106db1:	e9 da f2 ff ff       	jmp    80106090 <alltraps>

80106db6 <vector167>:
.globl vector167
vector167:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $167
80106db8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106dbd:	e9 ce f2 ff ff       	jmp    80106090 <alltraps>

80106dc2 <vector168>:
.globl vector168
vector168:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $168
80106dc4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106dc9:	e9 c2 f2 ff ff       	jmp    80106090 <alltraps>

80106dce <vector169>:
.globl vector169
vector169:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $169
80106dd0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106dd5:	e9 b6 f2 ff ff       	jmp    80106090 <alltraps>

80106dda <vector170>:
.globl vector170
vector170:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $170
80106ddc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106de1:	e9 aa f2 ff ff       	jmp    80106090 <alltraps>

80106de6 <vector171>:
.globl vector171
vector171:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $171
80106de8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106ded:	e9 9e f2 ff ff       	jmp    80106090 <alltraps>

80106df2 <vector172>:
.globl vector172
vector172:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $172
80106df4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106df9:	e9 92 f2 ff ff       	jmp    80106090 <alltraps>

80106dfe <vector173>:
.globl vector173
vector173:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $173
80106e00:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106e05:	e9 86 f2 ff ff       	jmp    80106090 <alltraps>

80106e0a <vector174>:
.globl vector174
vector174:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $174
80106e0c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106e11:	e9 7a f2 ff ff       	jmp    80106090 <alltraps>

80106e16 <vector175>:
.globl vector175
vector175:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $175
80106e18:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106e1d:	e9 6e f2 ff ff       	jmp    80106090 <alltraps>

80106e22 <vector176>:
.globl vector176
vector176:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $176
80106e24:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106e29:	e9 62 f2 ff ff       	jmp    80106090 <alltraps>

80106e2e <vector177>:
.globl vector177
vector177:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $177
80106e30:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106e35:	e9 56 f2 ff ff       	jmp    80106090 <alltraps>

80106e3a <vector178>:
.globl vector178
vector178:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $178
80106e3c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106e41:	e9 4a f2 ff ff       	jmp    80106090 <alltraps>

80106e46 <vector179>:
.globl vector179
vector179:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $179
80106e48:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106e4d:	e9 3e f2 ff ff       	jmp    80106090 <alltraps>

80106e52 <vector180>:
.globl vector180
vector180:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $180
80106e54:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106e59:	e9 32 f2 ff ff       	jmp    80106090 <alltraps>

80106e5e <vector181>:
.globl vector181
vector181:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $181
80106e60:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106e65:	e9 26 f2 ff ff       	jmp    80106090 <alltraps>

80106e6a <vector182>:
.globl vector182
vector182:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $182
80106e6c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106e71:	e9 1a f2 ff ff       	jmp    80106090 <alltraps>

80106e76 <vector183>:
.globl vector183
vector183:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $183
80106e78:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106e7d:	e9 0e f2 ff ff       	jmp    80106090 <alltraps>

80106e82 <vector184>:
.globl vector184
vector184:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $184
80106e84:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106e89:	e9 02 f2 ff ff       	jmp    80106090 <alltraps>

80106e8e <vector185>:
.globl vector185
vector185:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $185
80106e90:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106e95:	e9 f6 f1 ff ff       	jmp    80106090 <alltraps>

80106e9a <vector186>:
.globl vector186
vector186:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $186
80106e9c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106ea1:	e9 ea f1 ff ff       	jmp    80106090 <alltraps>

80106ea6 <vector187>:
.globl vector187
vector187:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $187
80106ea8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106ead:	e9 de f1 ff ff       	jmp    80106090 <alltraps>

80106eb2 <vector188>:
.globl vector188
vector188:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $188
80106eb4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106eb9:	e9 d2 f1 ff ff       	jmp    80106090 <alltraps>

80106ebe <vector189>:
.globl vector189
vector189:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $189
80106ec0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106ec5:	e9 c6 f1 ff ff       	jmp    80106090 <alltraps>

80106eca <vector190>:
.globl vector190
vector190:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $190
80106ecc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106ed1:	e9 ba f1 ff ff       	jmp    80106090 <alltraps>

80106ed6 <vector191>:
.globl vector191
vector191:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $191
80106ed8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106edd:	e9 ae f1 ff ff       	jmp    80106090 <alltraps>

80106ee2 <vector192>:
.globl vector192
vector192:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $192
80106ee4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106ee9:	e9 a2 f1 ff ff       	jmp    80106090 <alltraps>

80106eee <vector193>:
.globl vector193
vector193:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $193
80106ef0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106ef5:	e9 96 f1 ff ff       	jmp    80106090 <alltraps>

80106efa <vector194>:
.globl vector194
vector194:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $194
80106efc:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106f01:	e9 8a f1 ff ff       	jmp    80106090 <alltraps>

80106f06 <vector195>:
.globl vector195
vector195:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $195
80106f08:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106f0d:	e9 7e f1 ff ff       	jmp    80106090 <alltraps>

80106f12 <vector196>:
.globl vector196
vector196:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $196
80106f14:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106f19:	e9 72 f1 ff ff       	jmp    80106090 <alltraps>

80106f1e <vector197>:
.globl vector197
vector197:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $197
80106f20:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106f25:	e9 66 f1 ff ff       	jmp    80106090 <alltraps>

80106f2a <vector198>:
.globl vector198
vector198:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $198
80106f2c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106f31:	e9 5a f1 ff ff       	jmp    80106090 <alltraps>

80106f36 <vector199>:
.globl vector199
vector199:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $199
80106f38:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106f3d:	e9 4e f1 ff ff       	jmp    80106090 <alltraps>

80106f42 <vector200>:
.globl vector200
vector200:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $200
80106f44:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106f49:	e9 42 f1 ff ff       	jmp    80106090 <alltraps>

80106f4e <vector201>:
.globl vector201
vector201:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $201
80106f50:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106f55:	e9 36 f1 ff ff       	jmp    80106090 <alltraps>

80106f5a <vector202>:
.globl vector202
vector202:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $202
80106f5c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106f61:	e9 2a f1 ff ff       	jmp    80106090 <alltraps>

80106f66 <vector203>:
.globl vector203
vector203:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $203
80106f68:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106f6d:	e9 1e f1 ff ff       	jmp    80106090 <alltraps>

80106f72 <vector204>:
.globl vector204
vector204:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $204
80106f74:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106f79:	e9 12 f1 ff ff       	jmp    80106090 <alltraps>

80106f7e <vector205>:
.globl vector205
vector205:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $205
80106f80:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106f85:	e9 06 f1 ff ff       	jmp    80106090 <alltraps>

80106f8a <vector206>:
.globl vector206
vector206:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $206
80106f8c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106f91:	e9 fa f0 ff ff       	jmp    80106090 <alltraps>

80106f96 <vector207>:
.globl vector207
vector207:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $207
80106f98:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106f9d:	e9 ee f0 ff ff       	jmp    80106090 <alltraps>

80106fa2 <vector208>:
.globl vector208
vector208:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $208
80106fa4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106fa9:	e9 e2 f0 ff ff       	jmp    80106090 <alltraps>

80106fae <vector209>:
.globl vector209
vector209:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $209
80106fb0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106fb5:	e9 d6 f0 ff ff       	jmp    80106090 <alltraps>

80106fba <vector210>:
.globl vector210
vector210:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $210
80106fbc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106fc1:	e9 ca f0 ff ff       	jmp    80106090 <alltraps>

80106fc6 <vector211>:
.globl vector211
vector211:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $211
80106fc8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106fcd:	e9 be f0 ff ff       	jmp    80106090 <alltraps>

80106fd2 <vector212>:
.globl vector212
vector212:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $212
80106fd4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106fd9:	e9 b2 f0 ff ff       	jmp    80106090 <alltraps>

80106fde <vector213>:
.globl vector213
vector213:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $213
80106fe0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106fe5:	e9 a6 f0 ff ff       	jmp    80106090 <alltraps>

80106fea <vector214>:
.globl vector214
vector214:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $214
80106fec:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106ff1:	e9 9a f0 ff ff       	jmp    80106090 <alltraps>

80106ff6 <vector215>:
.globl vector215
vector215:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $215
80106ff8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106ffd:	e9 8e f0 ff ff       	jmp    80106090 <alltraps>

80107002 <vector216>:
.globl vector216
vector216:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $216
80107004:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107009:	e9 82 f0 ff ff       	jmp    80106090 <alltraps>

8010700e <vector217>:
.globl vector217
vector217:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $217
80107010:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107015:	e9 76 f0 ff ff       	jmp    80106090 <alltraps>

8010701a <vector218>:
.globl vector218
vector218:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $218
8010701c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107021:	e9 6a f0 ff ff       	jmp    80106090 <alltraps>

80107026 <vector219>:
.globl vector219
vector219:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $219
80107028:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010702d:	e9 5e f0 ff ff       	jmp    80106090 <alltraps>

80107032 <vector220>:
.globl vector220
vector220:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $220
80107034:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107039:	e9 52 f0 ff ff       	jmp    80106090 <alltraps>

8010703e <vector221>:
.globl vector221
vector221:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $221
80107040:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107045:	e9 46 f0 ff ff       	jmp    80106090 <alltraps>

8010704a <vector222>:
.globl vector222
vector222:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $222
8010704c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107051:	e9 3a f0 ff ff       	jmp    80106090 <alltraps>

80107056 <vector223>:
.globl vector223
vector223:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $223
80107058:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010705d:	e9 2e f0 ff ff       	jmp    80106090 <alltraps>

80107062 <vector224>:
.globl vector224
vector224:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $224
80107064:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107069:	e9 22 f0 ff ff       	jmp    80106090 <alltraps>

8010706e <vector225>:
.globl vector225
vector225:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $225
80107070:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107075:	e9 16 f0 ff ff       	jmp    80106090 <alltraps>

8010707a <vector226>:
.globl vector226
vector226:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $226
8010707c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107081:	e9 0a f0 ff ff       	jmp    80106090 <alltraps>

80107086 <vector227>:
.globl vector227
vector227:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $227
80107088:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010708d:	e9 fe ef ff ff       	jmp    80106090 <alltraps>

80107092 <vector228>:
.globl vector228
vector228:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $228
80107094:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107099:	e9 f2 ef ff ff       	jmp    80106090 <alltraps>

8010709e <vector229>:
.globl vector229
vector229:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $229
801070a0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801070a5:	e9 e6 ef ff ff       	jmp    80106090 <alltraps>

801070aa <vector230>:
.globl vector230
vector230:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $230
801070ac:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801070b1:	e9 da ef ff ff       	jmp    80106090 <alltraps>

801070b6 <vector231>:
.globl vector231
vector231:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $231
801070b8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801070bd:	e9 ce ef ff ff       	jmp    80106090 <alltraps>

801070c2 <vector232>:
.globl vector232
vector232:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $232
801070c4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801070c9:	e9 c2 ef ff ff       	jmp    80106090 <alltraps>

801070ce <vector233>:
.globl vector233
vector233:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $233
801070d0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801070d5:	e9 b6 ef ff ff       	jmp    80106090 <alltraps>

801070da <vector234>:
.globl vector234
vector234:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $234
801070dc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801070e1:	e9 aa ef ff ff       	jmp    80106090 <alltraps>

801070e6 <vector235>:
.globl vector235
vector235:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $235
801070e8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801070ed:	e9 9e ef ff ff       	jmp    80106090 <alltraps>

801070f2 <vector236>:
.globl vector236
vector236:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $236
801070f4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801070f9:	e9 92 ef ff ff       	jmp    80106090 <alltraps>

801070fe <vector237>:
.globl vector237
vector237:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $237
80107100:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107105:	e9 86 ef ff ff       	jmp    80106090 <alltraps>

8010710a <vector238>:
.globl vector238
vector238:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $238
8010710c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107111:	e9 7a ef ff ff       	jmp    80106090 <alltraps>

80107116 <vector239>:
.globl vector239
vector239:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $239
80107118:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010711d:	e9 6e ef ff ff       	jmp    80106090 <alltraps>

80107122 <vector240>:
.globl vector240
vector240:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $240
80107124:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107129:	e9 62 ef ff ff       	jmp    80106090 <alltraps>

8010712e <vector241>:
.globl vector241
vector241:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $241
80107130:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107135:	e9 56 ef ff ff       	jmp    80106090 <alltraps>

8010713a <vector242>:
.globl vector242
vector242:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $242
8010713c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107141:	e9 4a ef ff ff       	jmp    80106090 <alltraps>

80107146 <vector243>:
.globl vector243
vector243:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $243
80107148:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010714d:	e9 3e ef ff ff       	jmp    80106090 <alltraps>

80107152 <vector244>:
.globl vector244
vector244:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $244
80107154:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107159:	e9 32 ef ff ff       	jmp    80106090 <alltraps>

8010715e <vector245>:
.globl vector245
vector245:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $245
80107160:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107165:	e9 26 ef ff ff       	jmp    80106090 <alltraps>

8010716a <vector246>:
.globl vector246
vector246:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $246
8010716c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107171:	e9 1a ef ff ff       	jmp    80106090 <alltraps>

80107176 <vector247>:
.globl vector247
vector247:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $247
80107178:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010717d:	e9 0e ef ff ff       	jmp    80106090 <alltraps>

80107182 <vector248>:
.globl vector248
vector248:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $248
80107184:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107189:	e9 02 ef ff ff       	jmp    80106090 <alltraps>

8010718e <vector249>:
.globl vector249
vector249:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $249
80107190:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107195:	e9 f6 ee ff ff       	jmp    80106090 <alltraps>

8010719a <vector250>:
.globl vector250
vector250:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $250
8010719c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801071a1:	e9 ea ee ff ff       	jmp    80106090 <alltraps>

801071a6 <vector251>:
.globl vector251
vector251:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $251
801071a8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801071ad:	e9 de ee ff ff       	jmp    80106090 <alltraps>

801071b2 <vector252>:
.globl vector252
vector252:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $252
801071b4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801071b9:	e9 d2 ee ff ff       	jmp    80106090 <alltraps>

801071be <vector253>:
.globl vector253
vector253:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $253
801071c0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801071c5:	e9 c6 ee ff ff       	jmp    80106090 <alltraps>

801071ca <vector254>:
.globl vector254
vector254:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $254
801071cc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801071d1:	e9 ba ee ff ff       	jmp    80106090 <alltraps>

801071d6 <vector255>:
.globl vector255
vector255:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $255
801071d8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801071dd:	e9 ae ee ff ff       	jmp    80106090 <alltraps>

801071e2 <lgdt>:
{
801071e2:	55                   	push   %ebp
801071e3:	89 e5                	mov    %esp,%ebp
801071e5:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801071e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801071eb:	83 e8 01             	sub    $0x1,%eax
801071ee:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801071f2:	8b 45 08             	mov    0x8(%ebp),%eax
801071f5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801071f9:	8b 45 08             	mov    0x8(%ebp),%eax
801071fc:	c1 e8 10             	shr    $0x10,%eax
801071ff:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107203:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107206:	0f 01 10             	lgdtl  (%eax)
}
80107209:	90                   	nop
8010720a:	c9                   	leave  
8010720b:	c3                   	ret    

8010720c <ltr>:
{
8010720c:	55                   	push   %ebp
8010720d:	89 e5                	mov    %esp,%ebp
8010720f:	83 ec 04             	sub    $0x4,%esp
80107212:	8b 45 08             	mov    0x8(%ebp),%eax
80107215:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107219:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010721d:	0f 00 d8             	ltr    %ax
}
80107220:	90                   	nop
80107221:	c9                   	leave  
80107222:	c3                   	ret    

80107223 <lcr3>:

static inline void
lcr3(uint val)
{
80107223:	55                   	push   %ebp
80107224:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107226:	8b 45 08             	mov    0x8(%ebp),%eax
80107229:	0f 22 d8             	mov    %eax,%cr3
}
8010722c:	90                   	nop
8010722d:	5d                   	pop    %ebp
8010722e:	c3                   	ret    

8010722f <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010722f:	55                   	push   %ebp
80107230:	89 e5                	mov    %esp,%ebp
80107232:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107235:	e8 63 c7 ff ff       	call   8010399d <cpuid>
8010723a:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107240:	05 80 76 19 80       	add    $0x80197680,%eax
80107245:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107254:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010725a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107264:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107268:	83 e2 f0             	and    $0xfffffff0,%edx
8010726b:	83 ca 0a             	or     $0xa,%edx
8010726e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107274:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107278:	83 ca 10             	or     $0x10,%edx
8010727b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010727e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107281:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107285:	83 e2 9f             	and    $0xffffff9f,%edx
80107288:	88 50 7d             	mov    %dl,0x7d(%eax)
8010728b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010728e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107292:	83 ca 80             	or     $0xffffff80,%edx
80107295:	88 50 7d             	mov    %dl,0x7d(%eax)
80107298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010729f:	83 ca 0f             	or     $0xf,%edx
801072a2:	88 50 7e             	mov    %dl,0x7e(%eax)
801072a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801072ac:	83 e2 ef             	and    $0xffffffef,%edx
801072af:	88 50 7e             	mov    %dl,0x7e(%eax)
801072b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801072b9:	83 e2 df             	and    $0xffffffdf,%edx
801072bc:	88 50 7e             	mov    %dl,0x7e(%eax)
801072bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801072c6:	83 ca 40             	or     $0x40,%edx
801072c9:	88 50 7e             	mov    %dl,0x7e(%eax)
801072cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072cf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801072d3:	83 ca 80             	or     $0xffffff80,%edx
801072d6:	88 50 7e             	mov    %dl,0x7e(%eax)
801072d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072dc:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801072e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e3:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801072ea:	ff ff 
801072ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ef:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801072f6:	00 00 
801072f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072fb:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107302:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107305:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010730c:	83 e2 f0             	and    $0xfffffff0,%edx
8010730f:	83 ca 02             	or     $0x2,%edx
80107312:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010731b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107322:	83 ca 10             	or     $0x10,%edx
80107325:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010732b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107335:	83 e2 9f             	and    $0xffffff9f,%edx
80107338:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010733e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107341:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107348:	83 ca 80             	or     $0xffffff80,%edx
8010734b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107354:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010735b:	83 ca 0f             	or     $0xf,%edx
8010735e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107367:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010736e:	83 e2 ef             	and    $0xffffffef,%edx
80107371:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107381:	83 e2 df             	and    $0xffffffdf,%edx
80107384:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010738a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107394:	83 ca 40             	or     $0x40,%edx
80107397:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010739d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801073a7:	83 ca 80             	or     $0xffffff80,%edx
801073aa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801073b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801073ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bd:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801073c4:	ff ff 
801073c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c9:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801073d0:	00 00 
801073d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d5:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801073dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073df:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073e6:	83 e2 f0             	and    $0xfffffff0,%edx
801073e9:	83 ca 0a             	or     $0xa,%edx
801073ec:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073fc:	83 ca 10             	or     $0x10,%edx
801073ff:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107408:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010740f:	83 ca 60             	or     $0x60,%edx
80107412:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107422:	83 ca 80             	or     $0xffffff80,%edx
80107425:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010742b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107435:	83 ca 0f             	or     $0xf,%edx
80107438:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010743e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107441:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107448:	83 e2 ef             	and    $0xffffffef,%edx
8010744b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107454:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010745b:	83 e2 df             	and    $0xffffffdf,%edx
8010745e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107467:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010746e:	83 ca 40             	or     $0x40,%edx
80107471:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107481:	83 ca 80             	or     $0xffffff80,%edx
80107484:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010748a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748d:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107497:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010749e:	ff ff 
801074a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801074aa:	00 00 
801074ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074af:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801074b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074c0:	83 e2 f0             	and    $0xfffffff0,%edx
801074c3:	83 ca 02             	or     $0x2,%edx
801074c6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074cf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074d6:	83 ca 10             	or     $0x10,%edx
801074d9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074e9:	83 ca 60             	or     $0x60,%edx
801074ec:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f5:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074fc:	83 ca 80             	or     $0xffffff80,%edx
801074ff:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107508:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010750f:	83 ca 0f             	or     $0xf,%edx
80107512:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107522:	83 e2 ef             	and    $0xffffffef,%edx
80107525:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010752b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107535:	83 e2 df             	and    $0xffffffdf,%edx
80107538:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010753e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107541:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107548:	83 ca 40             	or     $0x40,%edx
8010754b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107554:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010755b:	83 ca 80             	or     $0xffffff80,%edx
8010755e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107567:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010756e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107571:	83 c0 70             	add    $0x70,%eax
80107574:	83 ec 08             	sub    $0x8,%esp
80107577:	6a 30                	push   $0x30
80107579:	50                   	push   %eax
8010757a:	e8 63 fc ff ff       	call   801071e2 <lgdt>
8010757f:	83 c4 10             	add    $0x10,%esp
}
80107582:	90                   	nop
80107583:	c9                   	leave  
80107584:	c3                   	ret    

80107585 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107585:	55                   	push   %ebp
80107586:	89 e5                	mov    %esp,%ebp
80107588:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010758b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010758e:	c1 e8 16             	shr    $0x16,%eax
80107591:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107598:	8b 45 08             	mov    0x8(%ebp),%eax
8010759b:	01 d0                	add    %edx,%eax
8010759d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801075a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075a3:	8b 00                	mov    (%eax),%eax
801075a5:	83 e0 01             	and    $0x1,%eax
801075a8:	85 c0                	test   %eax,%eax
801075aa:	74 14                	je     801075c0 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801075ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075af:	8b 00                	mov    (%eax),%eax
801075b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801075b6:	05 00 00 00 80       	add    $0x80000000,%eax
801075bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801075be:	eb 42                	jmp    80107602 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801075c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801075c4:	74 0e                	je     801075d4 <walkpgdir+0x4f>
801075c6:	e8 d5 b1 ff ff       	call   801027a0 <kalloc>
801075cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801075ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801075d2:	75 07                	jne    801075db <walkpgdir+0x56>
      return 0;
801075d4:	b8 00 00 00 00       	mov    $0x0,%eax
801075d9:	eb 3e                	jmp    80107619 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801075db:	83 ec 04             	sub    $0x4,%esp
801075de:	68 00 10 00 00       	push   $0x1000
801075e3:	6a 00                	push   $0x0
801075e5:	ff 75 f4             	push   -0xc(%ebp)
801075e8:	e8 91 d5 ff ff       	call   80104b7e <memset>
801075ed:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801075f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f3:	05 00 00 00 80       	add    $0x80000000,%eax
801075f8:	83 c8 07             	or     $0x7,%eax
801075fb:	89 c2                	mov    %eax,%edx
801075fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107600:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107602:	8b 45 0c             	mov    0xc(%ebp),%eax
80107605:	c1 e8 0c             	shr    $0xc,%eax
80107608:	25 ff 03 00 00       	and    $0x3ff,%eax
8010760d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107617:	01 d0                	add    %edx,%eax
}
80107619:	c9                   	leave  
8010761a:	c3                   	ret    

8010761b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010761b:	55                   	push   %ebp
8010761c:	89 e5                	mov    %esp,%ebp
8010761e:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107621:	8b 45 0c             	mov    0xc(%ebp),%eax
80107624:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010762c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010762f:	8b 45 10             	mov    0x10(%ebp),%eax
80107632:	01 d0                	add    %edx,%eax
80107634:	83 e8 01             	sub    $0x1,%eax
80107637:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010763c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010763f:	83 ec 04             	sub    $0x4,%esp
80107642:	6a 01                	push   $0x1
80107644:	ff 75 f4             	push   -0xc(%ebp)
80107647:	ff 75 08             	push   0x8(%ebp)
8010764a:	e8 36 ff ff ff       	call   80107585 <walkpgdir>
8010764f:	83 c4 10             	add    $0x10,%esp
80107652:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107655:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107659:	75 07                	jne    80107662 <mappages+0x47>
      return -1;
8010765b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107660:	eb 47                	jmp    801076a9 <mappages+0x8e>
    if(*pte & PTE_P)
80107662:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107665:	8b 00                	mov    (%eax),%eax
80107667:	83 e0 01             	and    $0x1,%eax
8010766a:	85 c0                	test   %eax,%eax
8010766c:	74 0d                	je     8010767b <mappages+0x60>
      panic("remap");
8010766e:	83 ec 0c             	sub    $0xc,%esp
80107671:	68 48 a9 10 80       	push   $0x8010a948
80107676:	e8 2e 8f ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
8010767b:	8b 45 18             	mov    0x18(%ebp),%eax
8010767e:	0b 45 14             	or     0x14(%ebp),%eax
80107681:	83 c8 01             	or     $0x1,%eax
80107684:	89 c2                	mov    %eax,%edx
80107686:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107689:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010768b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107691:	74 10                	je     801076a3 <mappages+0x88>
      break;
    a += PGSIZE;
80107693:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010769a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801076a1:	eb 9c                	jmp    8010763f <mappages+0x24>
      break;
801076a3:	90                   	nop
  }
  return 0;
801076a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801076a9:	c9                   	leave  
801076aa:	c3                   	ret    

801076ab <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801076ab:	55                   	push   %ebp
801076ac:	89 e5                	mov    %esp,%ebp
801076ae:	53                   	push   %ebx
801076af:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801076b2:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801076b9:	8b 15 60 79 19 80    	mov    0x80197960,%edx
801076bf:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801076c4:	29 d0                	sub    %edx,%eax
801076c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801076c9:	a1 58 79 19 80       	mov    0x80197958,%eax
801076ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801076d1:	8b 15 58 79 19 80    	mov    0x80197958,%edx
801076d7:	a1 60 79 19 80       	mov    0x80197960,%eax
801076dc:	01 d0                	add    %edx,%eax
801076de:	89 45 e8             	mov    %eax,-0x18(%ebp)
801076e1:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801076e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076eb:	83 c0 30             	add    $0x30,%eax
801076ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
801076f1:	89 10                	mov    %edx,(%eax)
801076f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801076f6:	89 50 04             	mov    %edx,0x4(%eax)
801076f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801076fc:	89 50 08             	mov    %edx,0x8(%eax)
801076ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107702:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107705:	e8 96 b0 ff ff       	call   801027a0 <kalloc>
8010770a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010770d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107711:	75 07                	jne    8010771a <setupkvm+0x6f>
    return 0;
80107713:	b8 00 00 00 00       	mov    $0x0,%eax
80107718:	eb 78                	jmp    80107792 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
8010771a:	83 ec 04             	sub    $0x4,%esp
8010771d:	68 00 10 00 00       	push   $0x1000
80107722:	6a 00                	push   $0x0
80107724:	ff 75 f0             	push   -0x10(%ebp)
80107727:	e8 52 d4 ff ff       	call   80104b7e <memset>
8010772c:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010772f:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107736:	eb 4e                	jmp    80107786 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010773e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107741:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107747:	8b 58 08             	mov    0x8(%eax),%ebx
8010774a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774d:	8b 40 04             	mov    0x4(%eax),%eax
80107750:	29 c3                	sub    %eax,%ebx
80107752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107755:	8b 00                	mov    (%eax),%eax
80107757:	83 ec 0c             	sub    $0xc,%esp
8010775a:	51                   	push   %ecx
8010775b:	52                   	push   %edx
8010775c:	53                   	push   %ebx
8010775d:	50                   	push   %eax
8010775e:	ff 75 f0             	push   -0x10(%ebp)
80107761:	e8 b5 fe ff ff       	call   8010761b <mappages>
80107766:	83 c4 20             	add    $0x20,%esp
80107769:	85 c0                	test   %eax,%eax
8010776b:	79 15                	jns    80107782 <setupkvm+0xd7>
      freevm(pgdir);
8010776d:	83 ec 0c             	sub    $0xc,%esp
80107770:	ff 75 f0             	push   -0x10(%ebp)
80107773:	e8 f5 04 00 00       	call   80107c6d <freevm>
80107778:	83 c4 10             	add    $0x10,%esp
      return 0;
8010777b:	b8 00 00 00 00       	mov    $0x0,%eax
80107780:	eb 10                	jmp    80107792 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107782:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107786:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
8010778d:	72 a9                	jb     80107738 <setupkvm+0x8d>
    }
  return pgdir;
8010778f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107795:	c9                   	leave  
80107796:	c3                   	ret    

80107797 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107797:	55                   	push   %ebp
80107798:	89 e5                	mov    %esp,%ebp
8010779a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010779d:	e8 09 ff ff ff       	call   801076ab <setupkvm>
801077a2:	a3 7c 76 19 80       	mov    %eax,0x8019767c
  switchkvm();
801077a7:	e8 03 00 00 00       	call   801077af <switchkvm>
}
801077ac:	90                   	nop
801077ad:	c9                   	leave  
801077ae:	c3                   	ret    

801077af <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801077af:	55                   	push   %ebp
801077b0:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801077b2:	a1 7c 76 19 80       	mov    0x8019767c,%eax
801077b7:	05 00 00 00 80       	add    $0x80000000,%eax
801077bc:	50                   	push   %eax
801077bd:	e8 61 fa ff ff       	call   80107223 <lcr3>
801077c2:	83 c4 04             	add    $0x4,%esp
}
801077c5:	90                   	nop
801077c6:	c9                   	leave  
801077c7:	c3                   	ret    

801077c8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801077c8:	55                   	push   %ebp
801077c9:	89 e5                	mov    %esp,%ebp
801077cb:	56                   	push   %esi
801077cc:	53                   	push   %ebx
801077cd:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801077d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801077d4:	75 0d                	jne    801077e3 <switchuvm+0x1b>
    panic("switchuvm: no process");
801077d6:	83 ec 0c             	sub    $0xc,%esp
801077d9:	68 4e a9 10 80       	push   $0x8010a94e
801077de:	e8 c6 8d ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
801077e3:	8b 45 08             	mov    0x8(%ebp),%eax
801077e6:	8b 40 08             	mov    0x8(%eax),%eax
801077e9:	85 c0                	test   %eax,%eax
801077eb:	75 0d                	jne    801077fa <switchuvm+0x32>
    panic("switchuvm: no kstack");
801077ed:	83 ec 0c             	sub    $0xc,%esp
801077f0:	68 64 a9 10 80       	push   $0x8010a964
801077f5:	e8 af 8d ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
801077fa:	8b 45 08             	mov    0x8(%ebp),%eax
801077fd:	8b 40 04             	mov    0x4(%eax),%eax
80107800:	85 c0                	test   %eax,%eax
80107802:	75 0d                	jne    80107811 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107804:	83 ec 0c             	sub    $0xc,%esp
80107807:	68 79 a9 10 80       	push   $0x8010a979
8010780c:	e8 98 8d ff ff       	call   801005a9 <panic>

  pushcli();
80107811:	e8 5d d2 ff ff       	call   80104a73 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107816:	e8 9d c1 ff ff       	call   801039b8 <mycpu>
8010781b:	89 c3                	mov    %eax,%ebx
8010781d:	e8 96 c1 ff ff       	call   801039b8 <mycpu>
80107822:	83 c0 08             	add    $0x8,%eax
80107825:	89 c6                	mov    %eax,%esi
80107827:	e8 8c c1 ff ff       	call   801039b8 <mycpu>
8010782c:	83 c0 08             	add    $0x8,%eax
8010782f:	c1 e8 10             	shr    $0x10,%eax
80107832:	88 45 f7             	mov    %al,-0x9(%ebp)
80107835:	e8 7e c1 ff ff       	call   801039b8 <mycpu>
8010783a:	83 c0 08             	add    $0x8,%eax
8010783d:	c1 e8 18             	shr    $0x18,%eax
80107840:	89 c2                	mov    %eax,%edx
80107842:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107849:	67 00 
8010784b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107852:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107856:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010785c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107863:	83 e0 f0             	and    $0xfffffff0,%eax
80107866:	83 c8 09             	or     $0x9,%eax
80107869:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010786f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107876:	83 c8 10             	or     $0x10,%eax
80107879:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010787f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107886:	83 e0 9f             	and    $0xffffff9f,%eax
80107889:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010788f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107896:	83 c8 80             	or     $0xffffff80,%eax
80107899:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010789f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078a6:	83 e0 f0             	and    $0xfffffff0,%eax
801078a9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078af:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078b6:	83 e0 ef             	and    $0xffffffef,%eax
801078b9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078bf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078c6:	83 e0 df             	and    $0xffffffdf,%eax
801078c9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078cf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078d6:	83 c8 40             	or     $0x40,%eax
801078d9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078df:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078e6:	83 e0 7f             	and    $0x7f,%eax
801078e9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078ef:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801078f5:	e8 be c0 ff ff       	call   801039b8 <mycpu>
801078fa:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107901:	83 e2 ef             	and    $0xffffffef,%edx
80107904:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010790a:	e8 a9 c0 ff ff       	call   801039b8 <mycpu>
8010790f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107915:	8b 45 08             	mov    0x8(%ebp),%eax
80107918:	8b 40 08             	mov    0x8(%eax),%eax
8010791b:	89 c3                	mov    %eax,%ebx
8010791d:	e8 96 c0 ff ff       	call   801039b8 <mycpu>
80107922:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107928:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010792b:	e8 88 c0 ff ff       	call   801039b8 <mycpu>
80107930:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107936:	83 ec 0c             	sub    $0xc,%esp
80107939:	6a 28                	push   $0x28
8010793b:	e8 cc f8 ff ff       	call   8010720c <ltr>
80107940:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107943:	8b 45 08             	mov    0x8(%ebp),%eax
80107946:	8b 40 04             	mov    0x4(%eax),%eax
80107949:	05 00 00 00 80       	add    $0x80000000,%eax
8010794e:	83 ec 0c             	sub    $0xc,%esp
80107951:	50                   	push   %eax
80107952:	e8 cc f8 ff ff       	call   80107223 <lcr3>
80107957:	83 c4 10             	add    $0x10,%esp
  popcli();
8010795a:	e8 61 d1 ff ff       	call   80104ac0 <popcli>
}
8010795f:	90                   	nop
80107960:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107963:	5b                   	pop    %ebx
80107964:	5e                   	pop    %esi
80107965:	5d                   	pop    %ebp
80107966:	c3                   	ret    

80107967 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107967:	55                   	push   %ebp
80107968:	89 e5                	mov    %esp,%ebp
8010796a:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010796d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107974:	76 0d                	jbe    80107983 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107976:	83 ec 0c             	sub    $0xc,%esp
80107979:	68 8d a9 10 80       	push   $0x8010a98d
8010797e:	e8 26 8c ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107983:	e8 18 ae ff ff       	call   801027a0 <kalloc>
80107988:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010798b:	83 ec 04             	sub    $0x4,%esp
8010798e:	68 00 10 00 00       	push   $0x1000
80107993:	6a 00                	push   $0x0
80107995:	ff 75 f4             	push   -0xc(%ebp)
80107998:	e8 e1 d1 ff ff       	call   80104b7e <memset>
8010799d:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801079a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a3:	05 00 00 00 80       	add    $0x80000000,%eax
801079a8:	83 ec 0c             	sub    $0xc,%esp
801079ab:	6a 06                	push   $0x6
801079ad:	50                   	push   %eax
801079ae:	68 00 10 00 00       	push   $0x1000
801079b3:	6a 00                	push   $0x0
801079b5:	ff 75 08             	push   0x8(%ebp)
801079b8:	e8 5e fc ff ff       	call   8010761b <mappages>
801079bd:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801079c0:	83 ec 04             	sub    $0x4,%esp
801079c3:	ff 75 10             	push   0x10(%ebp)
801079c6:	ff 75 0c             	push   0xc(%ebp)
801079c9:	ff 75 f4             	push   -0xc(%ebp)
801079cc:	e8 6c d2 ff ff       	call   80104c3d <memmove>
801079d1:	83 c4 10             	add    $0x10,%esp
}
801079d4:	90                   	nop
801079d5:	c9                   	leave  
801079d6:	c3                   	ret    

801079d7 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801079d7:	55                   	push   %ebp
801079d8:	89 e5                	mov    %esp,%ebp
801079da:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801079dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801079e0:	25 ff 0f 00 00       	and    $0xfff,%eax
801079e5:	85 c0                	test   %eax,%eax
801079e7:	74 0d                	je     801079f6 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801079e9:	83 ec 0c             	sub    $0xc,%esp
801079ec:	68 a8 a9 10 80       	push   $0x8010a9a8
801079f1:	e8 b3 8b ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801079f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079fd:	e9 8f 00 00 00       	jmp    80107a91 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107a02:	8b 55 0c             	mov    0xc(%ebp),%edx
80107a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a08:	01 d0                	add    %edx,%eax
80107a0a:	83 ec 04             	sub    $0x4,%esp
80107a0d:	6a 00                	push   $0x0
80107a0f:	50                   	push   %eax
80107a10:	ff 75 08             	push   0x8(%ebp)
80107a13:	e8 6d fb ff ff       	call   80107585 <walkpgdir>
80107a18:	83 c4 10             	add    $0x10,%esp
80107a1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a1e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a22:	75 0d                	jne    80107a31 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107a24:	83 ec 0c             	sub    $0xc,%esp
80107a27:	68 cb a9 10 80       	push   $0x8010a9cb
80107a2c:	e8 78 8b ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a34:	8b 00                	mov    (%eax),%eax
80107a36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107a3e:	8b 45 18             	mov    0x18(%ebp),%eax
80107a41:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a44:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107a49:	77 0b                	ja     80107a56 <loaduvm+0x7f>
      n = sz - i;
80107a4b:	8b 45 18             	mov    0x18(%ebp),%eax
80107a4e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a51:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a54:	eb 07                	jmp    80107a5d <loaduvm+0x86>
    else
      n = PGSIZE;
80107a56:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107a5d:	8b 55 14             	mov    0x14(%ebp),%edx
80107a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a63:	01 d0                	add    %edx,%eax
80107a65:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a68:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107a6e:	ff 75 f0             	push   -0x10(%ebp)
80107a71:	50                   	push   %eax
80107a72:	52                   	push   %edx
80107a73:	ff 75 10             	push   0x10(%ebp)
80107a76:	e8 5b a4 ff ff       	call   80101ed6 <readi>
80107a7b:	83 c4 10             	add    $0x10,%esp
80107a7e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107a81:	74 07                	je     80107a8a <loaduvm+0xb3>
      return -1;
80107a83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a88:	eb 18                	jmp    80107aa2 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107a8a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	3b 45 18             	cmp    0x18(%ebp),%eax
80107a97:	0f 82 65 ff ff ff    	jb     80107a02 <loaduvm+0x2b>
  }
  return 0;
80107a9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107aa2:	c9                   	leave  
80107aa3:	c3                   	ret    

80107aa4 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107aa4:	55                   	push   %ebp
80107aa5:	89 e5                	mov    %esp,%ebp
80107aa7:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107aaa:	8b 45 10             	mov    0x10(%ebp),%eax
80107aad:	85 c0                	test   %eax,%eax
80107aaf:	79 0a                	jns    80107abb <allocuvm+0x17>
    return 0;
80107ab1:	b8 00 00 00 00       	mov    $0x0,%eax
80107ab6:	e9 ec 00 00 00       	jmp    80107ba7 <allocuvm+0x103>
  if(newsz < oldsz)
80107abb:	8b 45 10             	mov    0x10(%ebp),%eax
80107abe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ac1:	73 08                	jae    80107acb <allocuvm+0x27>
    return oldsz;
80107ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ac6:	e9 dc 00 00 00       	jmp    80107ba7 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107acb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ace:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ad3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ad8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107adb:	e9 b8 00 00 00       	jmp    80107b98 <allocuvm+0xf4>
    mem = kalloc();
80107ae0:	e8 bb ac ff ff       	call   801027a0 <kalloc>
80107ae5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107ae8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107aec:	75 2e                	jne    80107b1c <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107aee:	83 ec 0c             	sub    $0xc,%esp
80107af1:	68 e9 a9 10 80       	push   $0x8010a9e9
80107af6:	e8 f9 88 ff ff       	call   801003f4 <cprintf>
80107afb:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107afe:	83 ec 04             	sub    $0x4,%esp
80107b01:	ff 75 0c             	push   0xc(%ebp)
80107b04:	ff 75 10             	push   0x10(%ebp)
80107b07:	ff 75 08             	push   0x8(%ebp)
80107b0a:	e8 9a 00 00 00       	call   80107ba9 <deallocuvm>
80107b0f:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b12:	b8 00 00 00 00       	mov    $0x0,%eax
80107b17:	e9 8b 00 00 00       	jmp    80107ba7 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107b1c:	83 ec 04             	sub    $0x4,%esp
80107b1f:	68 00 10 00 00       	push   $0x1000
80107b24:	6a 00                	push   $0x0
80107b26:	ff 75 f0             	push   -0x10(%ebp)
80107b29:	e8 50 d0 ff ff       	call   80104b7e <memset>
80107b2e:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b34:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3d:	83 ec 0c             	sub    $0xc,%esp
80107b40:	6a 06                	push   $0x6
80107b42:	52                   	push   %edx
80107b43:	68 00 10 00 00       	push   $0x1000
80107b48:	50                   	push   %eax
80107b49:	ff 75 08             	push   0x8(%ebp)
80107b4c:	e8 ca fa ff ff       	call   8010761b <mappages>
80107b51:	83 c4 20             	add    $0x20,%esp
80107b54:	85 c0                	test   %eax,%eax
80107b56:	79 39                	jns    80107b91 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107b58:	83 ec 0c             	sub    $0xc,%esp
80107b5b:	68 01 aa 10 80       	push   $0x8010aa01
80107b60:	e8 8f 88 ff ff       	call   801003f4 <cprintf>
80107b65:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107b68:	83 ec 04             	sub    $0x4,%esp
80107b6b:	ff 75 0c             	push   0xc(%ebp)
80107b6e:	ff 75 10             	push   0x10(%ebp)
80107b71:	ff 75 08             	push   0x8(%ebp)
80107b74:	e8 30 00 00 00       	call   80107ba9 <deallocuvm>
80107b79:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107b7c:	83 ec 0c             	sub    $0xc,%esp
80107b7f:	ff 75 f0             	push   -0x10(%ebp)
80107b82:	e8 7f ab ff ff       	call   80102706 <kfree>
80107b87:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b8a:	b8 00 00 00 00       	mov    $0x0,%eax
80107b8f:	eb 16                	jmp    80107ba7 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107b91:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9b:	3b 45 10             	cmp    0x10(%ebp),%eax
80107b9e:	0f 82 3c ff ff ff    	jb     80107ae0 <allocuvm+0x3c>
    }
  }
  return newsz;
80107ba4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ba7:	c9                   	leave  
80107ba8:	c3                   	ret    

80107ba9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ba9:	55                   	push   %ebp
80107baa:	89 e5                	mov    %esp,%ebp
80107bac:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107baf:	8b 45 10             	mov    0x10(%ebp),%eax
80107bb2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107bb5:	72 08                	jb     80107bbf <deallocuvm+0x16>
    return oldsz;
80107bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bba:	e9 ac 00 00 00       	jmp    80107c6b <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107bbf:	8b 45 10             	mov    0x10(%ebp),%eax
80107bc2:	05 ff 0f 00 00       	add    $0xfff,%eax
80107bc7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107bcf:	e9 88 00 00 00       	jmp    80107c5c <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd7:	83 ec 04             	sub    $0x4,%esp
80107bda:	6a 00                	push   $0x0
80107bdc:	50                   	push   %eax
80107bdd:	ff 75 08             	push   0x8(%ebp)
80107be0:	e8 a0 f9 ff ff       	call   80107585 <walkpgdir>
80107be5:	83 c4 10             	add    $0x10,%esp
80107be8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107beb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bef:	75 16                	jne    80107c07 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf4:	c1 e8 16             	shr    $0x16,%eax
80107bf7:	83 c0 01             	add    $0x1,%eax
80107bfa:	c1 e0 16             	shl    $0x16,%eax
80107bfd:	2d 00 10 00 00       	sub    $0x1000,%eax
80107c02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c05:	eb 4e                	jmp    80107c55 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c0a:	8b 00                	mov    (%eax),%eax
80107c0c:	83 e0 01             	and    $0x1,%eax
80107c0f:	85 c0                	test   %eax,%eax
80107c11:	74 42                	je     80107c55 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c16:	8b 00                	mov    (%eax),%eax
80107c18:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107c20:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c24:	75 0d                	jne    80107c33 <deallocuvm+0x8a>
        panic("kfree");
80107c26:	83 ec 0c             	sub    $0xc,%esp
80107c29:	68 1d aa 10 80       	push   $0x8010aa1d
80107c2e:	e8 76 89 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107c33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c36:	05 00 00 00 80       	add    $0x80000000,%eax
80107c3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107c3e:	83 ec 0c             	sub    $0xc,%esp
80107c41:	ff 75 e8             	push   -0x18(%ebp)
80107c44:	e8 bd aa ff ff       	call   80102706 <kfree>
80107c49:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c4f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107c55:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c62:	0f 82 6c ff ff ff    	jb     80107bd4 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107c68:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107c6b:	c9                   	leave  
80107c6c:	c3                   	ret    

80107c6d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107c6d:	55                   	push   %ebp
80107c6e:	89 e5                	mov    %esp,%ebp
80107c70:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107c73:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107c77:	75 0d                	jne    80107c86 <freevm+0x19>
    panic("freevm: no pgdir");
80107c79:	83 ec 0c             	sub    $0xc,%esp
80107c7c:	68 23 aa 10 80       	push   $0x8010aa23
80107c81:	e8 23 89 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107c86:	83 ec 04             	sub    $0x4,%esp
80107c89:	6a 00                	push   $0x0
80107c8b:	68 00 00 00 80       	push   $0x80000000
80107c90:	ff 75 08             	push   0x8(%ebp)
80107c93:	e8 11 ff ff ff       	call   80107ba9 <deallocuvm>
80107c98:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107c9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ca2:	eb 48                	jmp    80107cec <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cae:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb1:	01 d0                	add    %edx,%eax
80107cb3:	8b 00                	mov    (%eax),%eax
80107cb5:	83 e0 01             	and    $0x1,%eax
80107cb8:	85 c0                	test   %eax,%eax
80107cba:	74 2c                	je     80107ce8 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80107cc9:	01 d0                	add    %edx,%eax
80107ccb:	8b 00                	mov    (%eax),%eax
80107ccd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cd2:	05 00 00 00 80       	add    $0x80000000,%eax
80107cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107cda:	83 ec 0c             	sub    $0xc,%esp
80107cdd:	ff 75 f0             	push   -0x10(%ebp)
80107ce0:	e8 21 aa ff ff       	call   80102706 <kfree>
80107ce5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107ce8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107cec:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107cf3:	76 af                	jbe    80107ca4 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107cf5:	83 ec 0c             	sub    $0xc,%esp
80107cf8:	ff 75 08             	push   0x8(%ebp)
80107cfb:	e8 06 aa ff ff       	call   80102706 <kfree>
80107d00:	83 c4 10             	add    $0x10,%esp
}
80107d03:	90                   	nop
80107d04:	c9                   	leave  
80107d05:	c3                   	ret    

80107d06 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107d06:	55                   	push   %ebp
80107d07:	89 e5                	mov    %esp,%ebp
80107d09:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107d0c:	83 ec 04             	sub    $0x4,%esp
80107d0f:	6a 00                	push   $0x0
80107d11:	ff 75 0c             	push   0xc(%ebp)
80107d14:	ff 75 08             	push   0x8(%ebp)
80107d17:	e8 69 f8 ff ff       	call   80107585 <walkpgdir>
80107d1c:	83 c4 10             	add    $0x10,%esp
80107d1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107d22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107d26:	75 0d                	jne    80107d35 <clearpteu+0x2f>
    panic("clearpteu");
80107d28:	83 ec 0c             	sub    $0xc,%esp
80107d2b:	68 34 aa 10 80       	push   $0x8010aa34
80107d30:	e8 74 88 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d38:	8b 00                	mov    (%eax),%eax
80107d3a:	83 e0 fb             	and    $0xfffffffb,%eax
80107d3d:	89 c2                	mov    %eax,%edx
80107d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d42:	89 10                	mov    %edx,(%eax)
}
80107d44:	90                   	nop
80107d45:	c9                   	leave  
80107d46:	c3                   	ret    

80107d47 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107d47:	55                   	push   %ebp
80107d48:	89 e5                	mov    %esp,%ebp
80107d4a:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107d4d:	e8 59 f9 ff ff       	call   801076ab <setupkvm>
80107d52:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d55:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d59:	75 0a                	jne    80107d65 <copyuvm+0x1e>
    return 0;
80107d5b:	b8 00 00 00 00       	mov    $0x0,%eax
80107d60:	e9 eb 00 00 00       	jmp    80107e50 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107d65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d6c:	e9 b7 00 00 00       	jmp    80107e28 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d74:	83 ec 04             	sub    $0x4,%esp
80107d77:	6a 00                	push   $0x0
80107d79:	50                   	push   %eax
80107d7a:	ff 75 08             	push   0x8(%ebp)
80107d7d:	e8 03 f8 ff ff       	call   80107585 <walkpgdir>
80107d82:	83 c4 10             	add    $0x10,%esp
80107d85:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d88:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d8c:	75 0d                	jne    80107d9b <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107d8e:	83 ec 0c             	sub    $0xc,%esp
80107d91:	68 3e aa 10 80       	push   $0x8010aa3e
80107d96:	e8 0e 88 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107d9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d9e:	8b 00                	mov    (%eax),%eax
80107da0:	83 e0 01             	and    $0x1,%eax
80107da3:	85 c0                	test   %eax,%eax
80107da5:	75 0d                	jne    80107db4 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107da7:	83 ec 0c             	sub    $0xc,%esp
80107daa:	68 58 aa 10 80       	push   $0x8010aa58
80107daf:	e8 f5 87 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107db4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107db7:	8b 00                	mov    (%eax),%eax
80107db9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dbe:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107dc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dc4:	8b 00                	mov    (%eax),%eax
80107dc6:	25 ff 0f 00 00       	and    $0xfff,%eax
80107dcb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107dce:	e8 cd a9 ff ff       	call   801027a0 <kalloc>
80107dd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107dd6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107dda:	74 5d                	je     80107e39 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107ddc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ddf:	05 00 00 00 80       	add    $0x80000000,%eax
80107de4:	83 ec 04             	sub    $0x4,%esp
80107de7:	68 00 10 00 00       	push   $0x1000
80107dec:	50                   	push   %eax
80107ded:	ff 75 e0             	push   -0x20(%ebp)
80107df0:	e8 48 ce ff ff       	call   80104c3d <memmove>
80107df5:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107df8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107dfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107dfe:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e07:	83 ec 0c             	sub    $0xc,%esp
80107e0a:	52                   	push   %edx
80107e0b:	51                   	push   %ecx
80107e0c:	68 00 10 00 00       	push   $0x1000
80107e11:	50                   	push   %eax
80107e12:	ff 75 f0             	push   -0x10(%ebp)
80107e15:	e8 01 f8 ff ff       	call   8010761b <mappages>
80107e1a:	83 c4 20             	add    $0x20,%esp
80107e1d:	85 c0                	test   %eax,%eax
80107e1f:	78 1b                	js     80107e3c <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107e21:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e2e:	0f 82 3d ff ff ff    	jb     80107d71 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e37:	eb 17                	jmp    80107e50 <copyuvm+0x109>
      goto bad;
80107e39:	90                   	nop
80107e3a:	eb 01                	jmp    80107e3d <copyuvm+0xf6>
      goto bad;
80107e3c:	90                   	nop

bad:
  freevm(d);
80107e3d:	83 ec 0c             	sub    $0xc,%esp
80107e40:	ff 75 f0             	push   -0x10(%ebp)
80107e43:	e8 25 fe ff ff       	call   80107c6d <freevm>
80107e48:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e50:	c9                   	leave  
80107e51:	c3                   	ret    

80107e52 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107e52:	55                   	push   %ebp
80107e53:	89 e5                	mov    %esp,%ebp
80107e55:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e58:	83 ec 04             	sub    $0x4,%esp
80107e5b:	6a 00                	push   $0x0
80107e5d:	ff 75 0c             	push   0xc(%ebp)
80107e60:	ff 75 08             	push   0x8(%ebp)
80107e63:	e8 1d f7 ff ff       	call   80107585 <walkpgdir>
80107e68:	83 c4 10             	add    $0x10,%esp
80107e6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e71:	8b 00                	mov    (%eax),%eax
80107e73:	83 e0 01             	and    $0x1,%eax
80107e76:	85 c0                	test   %eax,%eax
80107e78:	75 07                	jne    80107e81 <uva2ka+0x2f>
    return 0;
80107e7a:	b8 00 00 00 00       	mov    $0x0,%eax
80107e7f:	eb 22                	jmp    80107ea3 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e84:	8b 00                	mov    (%eax),%eax
80107e86:	83 e0 04             	and    $0x4,%eax
80107e89:	85 c0                	test   %eax,%eax
80107e8b:	75 07                	jne    80107e94 <uva2ka+0x42>
    return 0;
80107e8d:	b8 00 00 00 00       	mov    $0x0,%eax
80107e92:	eb 0f                	jmp    80107ea3 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e97:	8b 00                	mov    (%eax),%eax
80107e99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e9e:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107ea3:	c9                   	leave  
80107ea4:	c3                   	ret    

80107ea5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107ea5:	55                   	push   %ebp
80107ea6:	89 e5                	mov    %esp,%ebp
80107ea8:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107eab:	8b 45 10             	mov    0x10(%ebp),%eax
80107eae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107eb1:	eb 7f                	jmp    80107f32 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ebb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec1:	83 ec 08             	sub    $0x8,%esp
80107ec4:	50                   	push   %eax
80107ec5:	ff 75 08             	push   0x8(%ebp)
80107ec8:	e8 85 ff ff ff       	call   80107e52 <uva2ka>
80107ecd:	83 c4 10             	add    $0x10,%esp
80107ed0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107ed3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107ed7:	75 07                	jne    80107ee0 <copyout+0x3b>
      return -1;
80107ed9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ede:	eb 61                	jmp    80107f41 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ee3:	2b 45 0c             	sub    0xc(%ebp),%eax
80107ee6:	05 00 10 00 00       	add    $0x1000,%eax
80107eeb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ef1:	3b 45 14             	cmp    0x14(%ebp),%eax
80107ef4:	76 06                	jbe    80107efc <copyout+0x57>
      n = len;
80107ef6:	8b 45 14             	mov    0x14(%ebp),%eax
80107ef9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107efc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eff:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107f02:	89 c2                	mov    %eax,%edx
80107f04:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f07:	01 d0                	add    %edx,%eax
80107f09:	83 ec 04             	sub    $0x4,%esp
80107f0c:	ff 75 f0             	push   -0x10(%ebp)
80107f0f:	ff 75 f4             	push   -0xc(%ebp)
80107f12:	50                   	push   %eax
80107f13:	e8 25 cd ff ff       	call   80104c3d <memmove>
80107f18:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f1e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f24:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107f27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f2a:	05 00 10 00 00       	add    $0x1000,%eax
80107f2f:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107f32:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107f36:	0f 85 77 ff ff ff    	jne    80107eb3 <copyout+0xe>
  }
  return 0;
80107f3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f41:	c9                   	leave  
80107f42:	c3                   	ret    

80107f43 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107f43:	55                   	push   %ebp
80107f44:	89 e5                	mov    %esp,%ebp
80107f46:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107f49:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107f50:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f53:	8b 40 08             	mov    0x8(%eax),%eax
80107f56:	05 00 00 00 80       	add    $0x80000000,%eax
80107f5b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107f5e:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f68:	8b 40 24             	mov    0x24(%eax),%eax
80107f6b:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107f70:	c7 05 50 79 19 80 00 	movl   $0x0,0x80197950
80107f77:	00 00 00 

  while(i<madt->len){
80107f7a:	90                   	nop
80107f7b:	e9 bd 00 00 00       	jmp    8010803d <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107f80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f86:	01 d0                	add    %edx,%eax
80107f88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f8e:	0f b6 00             	movzbl (%eax),%eax
80107f91:	0f b6 c0             	movzbl %al,%eax
80107f94:	83 f8 05             	cmp    $0x5,%eax
80107f97:	0f 87 a0 00 00 00    	ja     8010803d <mpinit_uefi+0xfa>
80107f9d:	8b 04 85 74 aa 10 80 	mov    -0x7fef558c(,%eax,4),%eax
80107fa4:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107fac:	a1 50 79 19 80       	mov    0x80197950,%eax
80107fb1:	83 f8 03             	cmp    $0x3,%eax
80107fb4:	7f 28                	jg     80107fde <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107fb6:	8b 15 50 79 19 80    	mov    0x80197950,%edx
80107fbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107fbf:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107fc3:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80107fc9:	81 c2 80 76 19 80    	add    $0x80197680,%edx
80107fcf:	88 02                	mov    %al,(%edx)
          ncpu++;
80107fd1:	a1 50 79 19 80       	mov    0x80197950,%eax
80107fd6:	83 c0 01             	add    $0x1,%eax
80107fd9:	a3 50 79 19 80       	mov    %eax,0x80197950
        }
        i += lapic_entry->record_len;
80107fde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107fe1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107fe5:	0f b6 c0             	movzbl %al,%eax
80107fe8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107feb:	eb 50                	jmp    8010803d <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ff0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107ff3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ff6:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107ffa:	a2 54 79 19 80       	mov    %al,0x80197954
        i += ioapic->record_len;
80107fff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108002:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108006:	0f b6 c0             	movzbl %al,%eax
80108009:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010800c:	eb 2f                	jmp    8010803d <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010800e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108011:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108014:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108017:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010801b:	0f b6 c0             	movzbl %al,%eax
8010801e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108021:	eb 1a                	jmp    8010803d <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108023:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108026:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108029:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010802c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108030:	0f b6 c0             	movzbl %al,%eax
80108033:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108036:	eb 05                	jmp    8010803d <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80108038:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010803c:	90                   	nop
  while(i<madt->len){
8010803d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108040:	8b 40 04             	mov    0x4(%eax),%eax
80108043:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108046:	0f 82 34 ff ff ff    	jb     80107f80 <mpinit_uefi+0x3d>
    }
  }

}
8010804c:	90                   	nop
8010804d:	90                   	nop
8010804e:	c9                   	leave  
8010804f:	c3                   	ret    

80108050 <inb>:
{
80108050:	55                   	push   %ebp
80108051:	89 e5                	mov    %esp,%ebp
80108053:	83 ec 14             	sub    $0x14,%esp
80108056:	8b 45 08             	mov    0x8(%ebp),%eax
80108059:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010805d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108061:	89 c2                	mov    %eax,%edx
80108063:	ec                   	in     (%dx),%al
80108064:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108067:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010806b:	c9                   	leave  
8010806c:	c3                   	ret    

8010806d <outb>:
{
8010806d:	55                   	push   %ebp
8010806e:	89 e5                	mov    %esp,%ebp
80108070:	83 ec 08             	sub    $0x8,%esp
80108073:	8b 45 08             	mov    0x8(%ebp),%eax
80108076:	8b 55 0c             	mov    0xc(%ebp),%edx
80108079:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010807d:	89 d0                	mov    %edx,%eax
8010807f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108082:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108086:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010808a:	ee                   	out    %al,(%dx)
}
8010808b:	90                   	nop
8010808c:	c9                   	leave  
8010808d:	c3                   	ret    

8010808e <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010808e:	55                   	push   %ebp
8010808f:	89 e5                	mov    %esp,%ebp
80108091:	83 ec 28             	sub    $0x28,%esp
80108094:	8b 45 08             	mov    0x8(%ebp),%eax
80108097:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010809a:	6a 00                	push   $0x0
8010809c:	68 fa 03 00 00       	push   $0x3fa
801080a1:	e8 c7 ff ff ff       	call   8010806d <outb>
801080a6:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801080a9:	68 80 00 00 00       	push   $0x80
801080ae:	68 fb 03 00 00       	push   $0x3fb
801080b3:	e8 b5 ff ff ff       	call   8010806d <outb>
801080b8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801080bb:	6a 0c                	push   $0xc
801080bd:	68 f8 03 00 00       	push   $0x3f8
801080c2:	e8 a6 ff ff ff       	call   8010806d <outb>
801080c7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801080ca:	6a 00                	push   $0x0
801080cc:	68 f9 03 00 00       	push   $0x3f9
801080d1:	e8 97 ff ff ff       	call   8010806d <outb>
801080d6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801080d9:	6a 03                	push   $0x3
801080db:	68 fb 03 00 00       	push   $0x3fb
801080e0:	e8 88 ff ff ff       	call   8010806d <outb>
801080e5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801080e8:	6a 00                	push   $0x0
801080ea:	68 fc 03 00 00       	push   $0x3fc
801080ef:	e8 79 ff ff ff       	call   8010806d <outb>
801080f4:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801080f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080fe:	eb 11                	jmp    80108111 <uart_debug+0x83>
80108100:	83 ec 0c             	sub    $0xc,%esp
80108103:	6a 0a                	push   $0xa
80108105:	e8 2d aa ff ff       	call   80102b37 <microdelay>
8010810a:	83 c4 10             	add    $0x10,%esp
8010810d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108111:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108115:	7f 1a                	jg     80108131 <uart_debug+0xa3>
80108117:	83 ec 0c             	sub    $0xc,%esp
8010811a:	68 fd 03 00 00       	push   $0x3fd
8010811f:	e8 2c ff ff ff       	call   80108050 <inb>
80108124:	83 c4 10             	add    $0x10,%esp
80108127:	0f b6 c0             	movzbl %al,%eax
8010812a:	83 e0 20             	and    $0x20,%eax
8010812d:	85 c0                	test   %eax,%eax
8010812f:	74 cf                	je     80108100 <uart_debug+0x72>
  outb(COM1+0, p);
80108131:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108135:	0f b6 c0             	movzbl %al,%eax
80108138:	83 ec 08             	sub    $0x8,%esp
8010813b:	50                   	push   %eax
8010813c:	68 f8 03 00 00       	push   $0x3f8
80108141:	e8 27 ff ff ff       	call   8010806d <outb>
80108146:	83 c4 10             	add    $0x10,%esp
}
80108149:	90                   	nop
8010814a:	c9                   	leave  
8010814b:	c3                   	ret    

8010814c <uart_debugs>:

void uart_debugs(char *p){
8010814c:	55                   	push   %ebp
8010814d:	89 e5                	mov    %esp,%ebp
8010814f:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108152:	eb 1b                	jmp    8010816f <uart_debugs+0x23>
    uart_debug(*p++);
80108154:	8b 45 08             	mov    0x8(%ebp),%eax
80108157:	8d 50 01             	lea    0x1(%eax),%edx
8010815a:	89 55 08             	mov    %edx,0x8(%ebp)
8010815d:	0f b6 00             	movzbl (%eax),%eax
80108160:	0f be c0             	movsbl %al,%eax
80108163:	83 ec 0c             	sub    $0xc,%esp
80108166:	50                   	push   %eax
80108167:	e8 22 ff ff ff       	call   8010808e <uart_debug>
8010816c:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010816f:	8b 45 08             	mov    0x8(%ebp),%eax
80108172:	0f b6 00             	movzbl (%eax),%eax
80108175:	84 c0                	test   %al,%al
80108177:	75 db                	jne    80108154 <uart_debugs+0x8>
  }
}
80108179:	90                   	nop
8010817a:	90                   	nop
8010817b:	c9                   	leave  
8010817c:	c3                   	ret    

8010817d <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010817d:	55                   	push   %ebp
8010817e:	89 e5                	mov    %esp,%ebp
80108180:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108183:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010818a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010818d:	8b 50 14             	mov    0x14(%eax),%edx
80108190:	8b 40 10             	mov    0x10(%eax),%eax
80108193:	a3 58 79 19 80       	mov    %eax,0x80197958
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108198:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010819b:	8b 50 1c             	mov    0x1c(%eax),%edx
8010819e:	8b 40 18             	mov    0x18(%eax),%eax
801081a1:	a3 60 79 19 80       	mov    %eax,0x80197960
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801081a6:	8b 15 60 79 19 80    	mov    0x80197960,%edx
801081ac:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801081b1:	29 d0                	sub    %edx,%eax
801081b3:	a3 5c 79 19 80       	mov    %eax,0x8019795c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801081b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081bb:	8b 50 24             	mov    0x24(%eax),%edx
801081be:	8b 40 20             	mov    0x20(%eax),%eax
801081c1:	a3 64 79 19 80       	mov    %eax,0x80197964
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801081c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081c9:	8b 50 2c             	mov    0x2c(%eax),%edx
801081cc:	8b 40 28             	mov    0x28(%eax),%eax
801081cf:	a3 68 79 19 80       	mov    %eax,0x80197968
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801081d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081d7:	8b 50 34             	mov    0x34(%eax),%edx
801081da:	8b 40 30             	mov    0x30(%eax),%eax
801081dd:	a3 6c 79 19 80       	mov    %eax,0x8019796c
}
801081e2:	90                   	nop
801081e3:	c9                   	leave  
801081e4:	c3                   	ret    

801081e5 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801081e5:	55                   	push   %ebp
801081e6:	89 e5                	mov    %esp,%ebp
801081e8:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801081eb:	8b 15 6c 79 19 80    	mov    0x8019796c,%edx
801081f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801081f4:	0f af d0             	imul   %eax,%edx
801081f7:	8b 45 08             	mov    0x8(%ebp),%eax
801081fa:	01 d0                	add    %edx,%eax
801081fc:	c1 e0 02             	shl    $0x2,%eax
801081ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108202:	8b 15 5c 79 19 80    	mov    0x8019795c,%edx
80108208:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010820b:	01 d0                	add    %edx,%eax
8010820d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108210:	8b 45 10             	mov    0x10(%ebp),%eax
80108213:	0f b6 10             	movzbl (%eax),%edx
80108216:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108219:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010821b:	8b 45 10             	mov    0x10(%ebp),%eax
8010821e:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108222:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108225:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108228:	8b 45 10             	mov    0x10(%ebp),%eax
8010822b:	0f b6 50 02          	movzbl 0x2(%eax),%edx
8010822f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108232:	88 50 02             	mov    %dl,0x2(%eax)
}
80108235:	90                   	nop
80108236:	c9                   	leave  
80108237:	c3                   	ret    

80108238 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108238:	55                   	push   %ebp
80108239:	89 e5                	mov    %esp,%ebp
8010823b:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
8010823e:	8b 15 6c 79 19 80    	mov    0x8019796c,%edx
80108244:	8b 45 08             	mov    0x8(%ebp),%eax
80108247:	0f af c2             	imul   %edx,%eax
8010824a:	c1 e0 02             	shl    $0x2,%eax
8010824d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108250:	a1 60 79 19 80       	mov    0x80197960,%eax
80108255:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108258:	29 d0                	sub    %edx,%eax
8010825a:	8b 0d 5c 79 19 80    	mov    0x8019795c,%ecx
80108260:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108263:	01 ca                	add    %ecx,%edx
80108265:	89 d1                	mov    %edx,%ecx
80108267:	8b 15 5c 79 19 80    	mov    0x8019795c,%edx
8010826d:	83 ec 04             	sub    $0x4,%esp
80108270:	50                   	push   %eax
80108271:	51                   	push   %ecx
80108272:	52                   	push   %edx
80108273:	e8 c5 c9 ff ff       	call   80104c3d <memmove>
80108278:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
8010827b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827e:	8b 0d 5c 79 19 80    	mov    0x8019795c,%ecx
80108284:	8b 15 60 79 19 80    	mov    0x80197960,%edx
8010828a:	01 ca                	add    %ecx,%edx
8010828c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010828f:	29 ca                	sub    %ecx,%edx
80108291:	83 ec 04             	sub    $0x4,%esp
80108294:	50                   	push   %eax
80108295:	6a 00                	push   $0x0
80108297:	52                   	push   %edx
80108298:	e8 e1 c8 ff ff       	call   80104b7e <memset>
8010829d:	83 c4 10             	add    $0x10,%esp
}
801082a0:	90                   	nop
801082a1:	c9                   	leave  
801082a2:	c3                   	ret    

801082a3 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801082a3:	55                   	push   %ebp
801082a4:	89 e5                	mov    %esp,%ebp
801082a6:	53                   	push   %ebx
801082a7:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801082aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082b1:	e9 b1 00 00 00       	jmp    80108367 <font_render+0xc4>
    for(int j=14;j>-1;j--){
801082b6:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801082bd:	e9 97 00 00 00       	jmp    80108359 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801082c2:	8b 45 10             	mov    0x10(%ebp),%eax
801082c5:	83 e8 20             	sub    $0x20,%eax
801082c8:	6b d0 1e             	imul   $0x1e,%eax,%edx
801082cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ce:	01 d0                	add    %edx,%eax
801082d0:	0f b7 84 00 a0 aa 10 	movzwl -0x7fef5560(%eax,%eax,1),%eax
801082d7:	80 
801082d8:	0f b7 d0             	movzwl %ax,%edx
801082db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082de:	bb 01 00 00 00       	mov    $0x1,%ebx
801082e3:	89 c1                	mov    %eax,%ecx
801082e5:	d3 e3                	shl    %cl,%ebx
801082e7:	89 d8                	mov    %ebx,%eax
801082e9:	21 d0                	and    %edx,%eax
801082eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801082ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f1:	ba 01 00 00 00       	mov    $0x1,%edx
801082f6:	89 c1                	mov    %eax,%ecx
801082f8:	d3 e2                	shl    %cl,%edx
801082fa:	89 d0                	mov    %edx,%eax
801082fc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801082ff:	75 2b                	jne    8010832c <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108301:	8b 55 0c             	mov    0xc(%ebp),%edx
80108304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108307:	01 c2                	add    %eax,%edx
80108309:	b8 0e 00 00 00       	mov    $0xe,%eax
8010830e:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108311:	89 c1                	mov    %eax,%ecx
80108313:	8b 45 08             	mov    0x8(%ebp),%eax
80108316:	01 c8                	add    %ecx,%eax
80108318:	83 ec 04             	sub    $0x4,%esp
8010831b:	68 e0 f4 10 80       	push   $0x8010f4e0
80108320:	52                   	push   %edx
80108321:	50                   	push   %eax
80108322:	e8 be fe ff ff       	call   801081e5 <graphic_draw_pixel>
80108327:	83 c4 10             	add    $0x10,%esp
8010832a:	eb 29                	jmp    80108355 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010832c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010832f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108332:	01 c2                	add    %eax,%edx
80108334:	b8 0e 00 00 00       	mov    $0xe,%eax
80108339:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010833c:	89 c1                	mov    %eax,%ecx
8010833e:	8b 45 08             	mov    0x8(%ebp),%eax
80108341:	01 c8                	add    %ecx,%eax
80108343:	83 ec 04             	sub    $0x4,%esp
80108346:	68 70 79 19 80       	push   $0x80197970
8010834b:	52                   	push   %edx
8010834c:	50                   	push   %eax
8010834d:	e8 93 fe ff ff       	call   801081e5 <graphic_draw_pixel>
80108352:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108355:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108359:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010835d:	0f 89 5f ff ff ff    	jns    801082c2 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108363:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108367:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010836b:	0f 8e 45 ff ff ff    	jle    801082b6 <font_render+0x13>
      }
    }
  }
}
80108371:	90                   	nop
80108372:	90                   	nop
80108373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108376:	c9                   	leave  
80108377:	c3                   	ret    

80108378 <font_render_string>:

void font_render_string(char *string,int row){
80108378:	55                   	push   %ebp
80108379:	89 e5                	mov    %esp,%ebp
8010837b:	53                   	push   %ebx
8010837c:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010837f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108386:	eb 33                	jmp    801083bb <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108388:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010838b:	8b 45 08             	mov    0x8(%ebp),%eax
8010838e:	01 d0                	add    %edx,%eax
80108390:	0f b6 00             	movzbl (%eax),%eax
80108393:	0f be c8             	movsbl %al,%ecx
80108396:	8b 45 0c             	mov    0xc(%ebp),%eax
80108399:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010839c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010839f:	89 d8                	mov    %ebx,%eax
801083a1:	c1 e0 04             	shl    $0x4,%eax
801083a4:	29 d8                	sub    %ebx,%eax
801083a6:	83 c0 02             	add    $0x2,%eax
801083a9:	83 ec 04             	sub    $0x4,%esp
801083ac:	51                   	push   %ecx
801083ad:	52                   	push   %edx
801083ae:	50                   	push   %eax
801083af:	e8 ef fe ff ff       	call   801082a3 <font_render>
801083b4:	83 c4 10             	add    $0x10,%esp
    i++;
801083b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801083bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083be:	8b 45 08             	mov    0x8(%ebp),%eax
801083c1:	01 d0                	add    %edx,%eax
801083c3:	0f b6 00             	movzbl (%eax),%eax
801083c6:	84 c0                	test   %al,%al
801083c8:	74 06                	je     801083d0 <font_render_string+0x58>
801083ca:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801083ce:	7e b8                	jle    80108388 <font_render_string+0x10>
  }
}
801083d0:	90                   	nop
801083d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801083d4:	c9                   	leave  
801083d5:	c3                   	ret    

801083d6 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801083d6:	55                   	push   %ebp
801083d7:	89 e5                	mov    %esp,%ebp
801083d9:	53                   	push   %ebx
801083da:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801083dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083e4:	eb 6b                	jmp    80108451 <pci_init+0x7b>
    for(int j=0;j<32;j++){
801083e6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801083ed:	eb 58                	jmp    80108447 <pci_init+0x71>
      for(int k=0;k<8;k++){
801083ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801083f6:	eb 45                	jmp    8010843d <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801083f8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801083fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108401:	83 ec 0c             	sub    $0xc,%esp
80108404:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108407:	53                   	push   %ebx
80108408:	6a 00                	push   $0x0
8010840a:	51                   	push   %ecx
8010840b:	52                   	push   %edx
8010840c:	50                   	push   %eax
8010840d:	e8 b0 00 00 00       	call   801084c2 <pci_access_config>
80108412:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108415:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108418:	0f b7 c0             	movzwl %ax,%eax
8010841b:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108420:	74 17                	je     80108439 <pci_init+0x63>
        pci_init_device(i,j,k);
80108422:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108425:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842b:	83 ec 04             	sub    $0x4,%esp
8010842e:	51                   	push   %ecx
8010842f:	52                   	push   %edx
80108430:	50                   	push   %eax
80108431:	e8 37 01 00 00       	call   8010856d <pci_init_device>
80108436:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108439:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010843d:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108441:	7e b5                	jle    801083f8 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108443:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108447:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010844b:	7e a2                	jle    801083ef <pci_init+0x19>
  for(int i=0;i<256;i++){
8010844d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108451:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108458:	7e 8c                	jle    801083e6 <pci_init+0x10>
      }
      }
    }
  }
}
8010845a:	90                   	nop
8010845b:	90                   	nop
8010845c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010845f:	c9                   	leave  
80108460:	c3                   	ret    

80108461 <pci_write_config>:

void pci_write_config(uint config){
80108461:	55                   	push   %ebp
80108462:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108464:	8b 45 08             	mov    0x8(%ebp),%eax
80108467:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010846c:	89 c0                	mov    %eax,%eax
8010846e:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010846f:	90                   	nop
80108470:	5d                   	pop    %ebp
80108471:	c3                   	ret    

80108472 <pci_write_data>:

void pci_write_data(uint config){
80108472:	55                   	push   %ebp
80108473:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108475:	8b 45 08             	mov    0x8(%ebp),%eax
80108478:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010847d:	89 c0                	mov    %eax,%eax
8010847f:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108480:	90                   	nop
80108481:	5d                   	pop    %ebp
80108482:	c3                   	ret    

80108483 <pci_read_config>:
uint pci_read_config(){
80108483:	55                   	push   %ebp
80108484:	89 e5                	mov    %esp,%ebp
80108486:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108489:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010848e:	ed                   	in     (%dx),%eax
8010848f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108492:	83 ec 0c             	sub    $0xc,%esp
80108495:	68 c8 00 00 00       	push   $0xc8
8010849a:	e8 98 a6 ff ff       	call   80102b37 <microdelay>
8010849f:	83 c4 10             	add    $0x10,%esp
  return data;
801084a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801084a5:	c9                   	leave  
801084a6:	c3                   	ret    

801084a7 <pci_test>:


void pci_test(){
801084a7:	55                   	push   %ebp
801084a8:	89 e5                	mov    %esp,%ebp
801084aa:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801084ad:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801084b4:	ff 75 fc             	push   -0x4(%ebp)
801084b7:	e8 a5 ff ff ff       	call   80108461 <pci_write_config>
801084bc:	83 c4 04             	add    $0x4,%esp
}
801084bf:	90                   	nop
801084c0:	c9                   	leave  
801084c1:	c3                   	ret    

801084c2 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801084c2:	55                   	push   %ebp
801084c3:	89 e5                	mov    %esp,%ebp
801084c5:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801084c8:	8b 45 08             	mov    0x8(%ebp),%eax
801084cb:	c1 e0 10             	shl    $0x10,%eax
801084ce:	25 00 00 ff 00       	and    $0xff0000,%eax
801084d3:	89 c2                	mov    %eax,%edx
801084d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d8:	c1 e0 0b             	shl    $0xb,%eax
801084db:	0f b7 c0             	movzwl %ax,%eax
801084de:	09 c2                	or     %eax,%edx
801084e0:	8b 45 10             	mov    0x10(%ebp),%eax
801084e3:	c1 e0 08             	shl    $0x8,%eax
801084e6:	25 00 07 00 00       	and    $0x700,%eax
801084eb:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801084ed:	8b 45 14             	mov    0x14(%ebp),%eax
801084f0:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801084f5:	09 d0                	or     %edx,%eax
801084f7:	0d 00 00 00 80       	or     $0x80000000,%eax
801084fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801084ff:	ff 75 f4             	push   -0xc(%ebp)
80108502:	e8 5a ff ff ff       	call   80108461 <pci_write_config>
80108507:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010850a:	e8 74 ff ff ff       	call   80108483 <pci_read_config>
8010850f:	8b 55 18             	mov    0x18(%ebp),%edx
80108512:	89 02                	mov    %eax,(%edx)
}
80108514:	90                   	nop
80108515:	c9                   	leave  
80108516:	c3                   	ret    

80108517 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108517:	55                   	push   %ebp
80108518:	89 e5                	mov    %esp,%ebp
8010851a:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010851d:	8b 45 08             	mov    0x8(%ebp),%eax
80108520:	c1 e0 10             	shl    $0x10,%eax
80108523:	25 00 00 ff 00       	and    $0xff0000,%eax
80108528:	89 c2                	mov    %eax,%edx
8010852a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010852d:	c1 e0 0b             	shl    $0xb,%eax
80108530:	0f b7 c0             	movzwl %ax,%eax
80108533:	09 c2                	or     %eax,%edx
80108535:	8b 45 10             	mov    0x10(%ebp),%eax
80108538:	c1 e0 08             	shl    $0x8,%eax
8010853b:	25 00 07 00 00       	and    $0x700,%eax
80108540:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108542:	8b 45 14             	mov    0x14(%ebp),%eax
80108545:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010854a:	09 d0                	or     %edx,%eax
8010854c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108551:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108554:	ff 75 fc             	push   -0x4(%ebp)
80108557:	e8 05 ff ff ff       	call   80108461 <pci_write_config>
8010855c:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010855f:	ff 75 18             	push   0x18(%ebp)
80108562:	e8 0b ff ff ff       	call   80108472 <pci_write_data>
80108567:	83 c4 04             	add    $0x4,%esp
}
8010856a:	90                   	nop
8010856b:	c9                   	leave  
8010856c:	c3                   	ret    

8010856d <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010856d:	55                   	push   %ebp
8010856e:	89 e5                	mov    %esp,%ebp
80108570:	53                   	push   %ebx
80108571:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108574:	8b 45 08             	mov    0x8(%ebp),%eax
80108577:	a2 74 79 19 80       	mov    %al,0x80197974
  dev.device_num = device_num;
8010857c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010857f:	a2 75 79 19 80       	mov    %al,0x80197975
  dev.function_num = function_num;
80108584:	8b 45 10             	mov    0x10(%ebp),%eax
80108587:	a2 76 79 19 80       	mov    %al,0x80197976
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010858c:	ff 75 10             	push   0x10(%ebp)
8010858f:	ff 75 0c             	push   0xc(%ebp)
80108592:	ff 75 08             	push   0x8(%ebp)
80108595:	68 e4 c0 10 80       	push   $0x8010c0e4
8010859a:	e8 55 7e ff ff       	call   801003f4 <cprintf>
8010859f:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801085a2:	83 ec 0c             	sub    $0xc,%esp
801085a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085a8:	50                   	push   %eax
801085a9:	6a 00                	push   $0x0
801085ab:	ff 75 10             	push   0x10(%ebp)
801085ae:	ff 75 0c             	push   0xc(%ebp)
801085b1:	ff 75 08             	push   0x8(%ebp)
801085b4:	e8 09 ff ff ff       	call   801084c2 <pci_access_config>
801085b9:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801085bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085bf:	c1 e8 10             	shr    $0x10,%eax
801085c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801085c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085c8:	25 ff ff 00 00       	and    $0xffff,%eax
801085cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801085d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d3:	a3 78 79 19 80       	mov    %eax,0x80197978
  dev.vendor_id = vendor_id;
801085d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085db:	a3 7c 79 19 80       	mov    %eax,0x8019797c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801085e0:	83 ec 04             	sub    $0x4,%esp
801085e3:	ff 75 f0             	push   -0x10(%ebp)
801085e6:	ff 75 f4             	push   -0xc(%ebp)
801085e9:	68 18 c1 10 80       	push   $0x8010c118
801085ee:	e8 01 7e ff ff       	call   801003f4 <cprintf>
801085f3:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801085f6:	83 ec 0c             	sub    $0xc,%esp
801085f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085fc:	50                   	push   %eax
801085fd:	6a 08                	push   $0x8
801085ff:	ff 75 10             	push   0x10(%ebp)
80108602:	ff 75 0c             	push   0xc(%ebp)
80108605:	ff 75 08             	push   0x8(%ebp)
80108608:	e8 b5 fe ff ff       	call   801084c2 <pci_access_config>
8010860d:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108610:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108613:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108616:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108619:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010861c:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010861f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108622:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108625:	0f b6 c0             	movzbl %al,%eax
80108628:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010862b:	c1 eb 18             	shr    $0x18,%ebx
8010862e:	83 ec 0c             	sub    $0xc,%esp
80108631:	51                   	push   %ecx
80108632:	52                   	push   %edx
80108633:	50                   	push   %eax
80108634:	53                   	push   %ebx
80108635:	68 3c c1 10 80       	push   $0x8010c13c
8010863a:	e8 b5 7d ff ff       	call   801003f4 <cprintf>
8010863f:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108642:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108645:	c1 e8 18             	shr    $0x18,%eax
80108648:	a2 80 79 19 80       	mov    %al,0x80197980
  dev.sub_class = (data>>16)&0xFF;
8010864d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108650:	c1 e8 10             	shr    $0x10,%eax
80108653:	a2 81 79 19 80       	mov    %al,0x80197981
  dev.interface = (data>>8)&0xFF;
80108658:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010865b:	c1 e8 08             	shr    $0x8,%eax
8010865e:	a2 82 79 19 80       	mov    %al,0x80197982
  dev.revision_id = data&0xFF;
80108663:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108666:	a2 83 79 19 80       	mov    %al,0x80197983
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010866b:	83 ec 0c             	sub    $0xc,%esp
8010866e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108671:	50                   	push   %eax
80108672:	6a 10                	push   $0x10
80108674:	ff 75 10             	push   0x10(%ebp)
80108677:	ff 75 0c             	push   0xc(%ebp)
8010867a:	ff 75 08             	push   0x8(%ebp)
8010867d:	e8 40 fe ff ff       	call   801084c2 <pci_access_config>
80108682:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108685:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108688:	a3 84 79 19 80       	mov    %eax,0x80197984
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010868d:	83 ec 0c             	sub    $0xc,%esp
80108690:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108693:	50                   	push   %eax
80108694:	6a 14                	push   $0x14
80108696:	ff 75 10             	push   0x10(%ebp)
80108699:	ff 75 0c             	push   0xc(%ebp)
8010869c:	ff 75 08             	push   0x8(%ebp)
8010869f:	e8 1e fe ff ff       	call   801084c2 <pci_access_config>
801086a4:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801086a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086aa:	a3 88 79 19 80       	mov    %eax,0x80197988
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801086af:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801086b6:	75 5a                	jne    80108712 <pci_init_device+0x1a5>
801086b8:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801086bf:	75 51                	jne    80108712 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801086c1:	83 ec 0c             	sub    $0xc,%esp
801086c4:	68 81 c1 10 80       	push   $0x8010c181
801086c9:	e8 26 7d ff ff       	call   801003f4 <cprintf>
801086ce:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801086d1:	83 ec 0c             	sub    $0xc,%esp
801086d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086d7:	50                   	push   %eax
801086d8:	68 f0 00 00 00       	push   $0xf0
801086dd:	ff 75 10             	push   0x10(%ebp)
801086e0:	ff 75 0c             	push   0xc(%ebp)
801086e3:	ff 75 08             	push   0x8(%ebp)
801086e6:	e8 d7 fd ff ff       	call   801084c2 <pci_access_config>
801086eb:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801086ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f1:	83 ec 08             	sub    $0x8,%esp
801086f4:	50                   	push   %eax
801086f5:	68 9b c1 10 80       	push   $0x8010c19b
801086fa:	e8 f5 7c ff ff       	call   801003f4 <cprintf>
801086ff:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108702:	83 ec 0c             	sub    $0xc,%esp
80108705:	68 74 79 19 80       	push   $0x80197974
8010870a:	e8 09 00 00 00       	call   80108718 <i8254_init>
8010870f:	83 c4 10             	add    $0x10,%esp
  }
}
80108712:	90                   	nop
80108713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108716:	c9                   	leave  
80108717:	c3                   	ret    

80108718 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108718:	55                   	push   %ebp
80108719:	89 e5                	mov    %esp,%ebp
8010871b:	53                   	push   %ebx
8010871c:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010871f:	8b 45 08             	mov    0x8(%ebp),%eax
80108722:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108726:	0f b6 c8             	movzbl %al,%ecx
80108729:	8b 45 08             	mov    0x8(%ebp),%eax
8010872c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108730:	0f b6 d0             	movzbl %al,%edx
80108733:	8b 45 08             	mov    0x8(%ebp),%eax
80108736:	0f b6 00             	movzbl (%eax),%eax
80108739:	0f b6 c0             	movzbl %al,%eax
8010873c:	83 ec 0c             	sub    $0xc,%esp
8010873f:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108742:	53                   	push   %ebx
80108743:	6a 04                	push   $0x4
80108745:	51                   	push   %ecx
80108746:	52                   	push   %edx
80108747:	50                   	push   %eax
80108748:	e8 75 fd ff ff       	call   801084c2 <pci_access_config>
8010874d:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108750:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108753:	83 c8 04             	or     $0x4,%eax
80108756:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108759:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010875c:	8b 45 08             	mov    0x8(%ebp),%eax
8010875f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108763:	0f b6 c8             	movzbl %al,%ecx
80108766:	8b 45 08             	mov    0x8(%ebp),%eax
80108769:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010876d:	0f b6 d0             	movzbl %al,%edx
80108770:	8b 45 08             	mov    0x8(%ebp),%eax
80108773:	0f b6 00             	movzbl (%eax),%eax
80108776:	0f b6 c0             	movzbl %al,%eax
80108779:	83 ec 0c             	sub    $0xc,%esp
8010877c:	53                   	push   %ebx
8010877d:	6a 04                	push   $0x4
8010877f:	51                   	push   %ecx
80108780:	52                   	push   %edx
80108781:	50                   	push   %eax
80108782:	e8 90 fd ff ff       	call   80108517 <pci_write_config_register>
80108787:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
8010878a:	8b 45 08             	mov    0x8(%ebp),%eax
8010878d:	8b 40 10             	mov    0x10(%eax),%eax
80108790:	05 00 00 00 40       	add    $0x40000000,%eax
80108795:	a3 8c 79 19 80       	mov    %eax,0x8019798c
  uint *ctrl = (uint *)base_addr;
8010879a:	a1 8c 79 19 80       	mov    0x8019798c,%eax
8010879f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801087a2:	a1 8c 79 19 80       	mov    0x8019798c,%eax
801087a7:	05 d8 00 00 00       	add    $0xd8,%eax
801087ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801087af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b2:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801087b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bb:	8b 00                	mov    (%eax),%eax
801087bd:	0d 00 00 00 04       	or     $0x4000000,%eax
801087c2:	89 c2                	mov    %eax,%edx
801087c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c7:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801087c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087cc:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801087d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d5:	8b 00                	mov    (%eax),%eax
801087d7:	83 c8 40             	or     $0x40,%eax
801087da:	89 c2                	mov    %eax,%edx
801087dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087df:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801087e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e4:	8b 10                	mov    (%eax),%edx
801087e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e9:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801087eb:	83 ec 0c             	sub    $0xc,%esp
801087ee:	68 b0 c1 10 80       	push   $0x8010c1b0
801087f3:	e8 fc 7b ff ff       	call   801003f4 <cprintf>
801087f8:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801087fb:	e8 a0 9f ff ff       	call   801027a0 <kalloc>
80108800:	a3 98 79 19 80       	mov    %eax,0x80197998
  *intr_addr = 0;
80108805:	a1 98 79 19 80       	mov    0x80197998,%eax
8010880a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108810:	a1 98 79 19 80       	mov    0x80197998,%eax
80108815:	83 ec 08             	sub    $0x8,%esp
80108818:	50                   	push   %eax
80108819:	68 d2 c1 10 80       	push   $0x8010c1d2
8010881e:	e8 d1 7b ff ff       	call   801003f4 <cprintf>
80108823:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108826:	e8 50 00 00 00       	call   8010887b <i8254_init_recv>
  i8254_init_send();
8010882b:	e8 69 03 00 00       	call   80108b99 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108830:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108837:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010883a:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108841:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108844:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010884b:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010884e:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108855:	0f b6 c0             	movzbl %al,%eax
80108858:	83 ec 0c             	sub    $0xc,%esp
8010885b:	53                   	push   %ebx
8010885c:	51                   	push   %ecx
8010885d:	52                   	push   %edx
8010885e:	50                   	push   %eax
8010885f:	68 e0 c1 10 80       	push   $0x8010c1e0
80108864:	e8 8b 7b ff ff       	call   801003f4 <cprintf>
80108869:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010886c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108875:	90                   	nop
80108876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108879:	c9                   	leave  
8010887a:	c3                   	ret    

8010887b <i8254_init_recv>:

void i8254_init_recv(){
8010887b:	55                   	push   %ebp
8010887c:	89 e5                	mov    %esp,%ebp
8010887e:	57                   	push   %edi
8010887f:	56                   	push   %esi
80108880:	53                   	push   %ebx
80108881:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108884:	83 ec 0c             	sub    $0xc,%esp
80108887:	6a 00                	push   $0x0
80108889:	e8 e8 04 00 00       	call   80108d76 <i8254_read_eeprom>
8010888e:	83 c4 10             	add    $0x10,%esp
80108891:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108894:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108897:	a2 90 79 19 80       	mov    %al,0x80197990
  mac_addr[1] = data_l>>8;
8010889c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010889f:	c1 e8 08             	shr    $0x8,%eax
801088a2:	a2 91 79 19 80       	mov    %al,0x80197991
  uint data_m = i8254_read_eeprom(0x1);
801088a7:	83 ec 0c             	sub    $0xc,%esp
801088aa:	6a 01                	push   $0x1
801088ac:	e8 c5 04 00 00       	call   80108d76 <i8254_read_eeprom>
801088b1:	83 c4 10             	add    $0x10,%esp
801088b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801088b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801088ba:	a2 92 79 19 80       	mov    %al,0x80197992
  mac_addr[3] = data_m>>8;
801088bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801088c2:	c1 e8 08             	shr    $0x8,%eax
801088c5:	a2 93 79 19 80       	mov    %al,0x80197993
  uint data_h = i8254_read_eeprom(0x2);
801088ca:	83 ec 0c             	sub    $0xc,%esp
801088cd:	6a 02                	push   $0x2
801088cf:	e8 a2 04 00 00       	call   80108d76 <i8254_read_eeprom>
801088d4:	83 c4 10             	add    $0x10,%esp
801088d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801088da:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088dd:	a2 94 79 19 80       	mov    %al,0x80197994
  mac_addr[5] = data_h>>8;
801088e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088e5:	c1 e8 08             	shr    $0x8,%eax
801088e8:	a2 95 79 19 80       	mov    %al,0x80197995
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801088ed:	0f b6 05 95 79 19 80 	movzbl 0x80197995,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088f4:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801088f7:	0f b6 05 94 79 19 80 	movzbl 0x80197994,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088fe:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108901:	0f b6 05 93 79 19 80 	movzbl 0x80197993,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108908:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010890b:	0f b6 05 92 79 19 80 	movzbl 0x80197992,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108912:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108915:	0f b6 05 91 79 19 80 	movzbl 0x80197991,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010891c:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
8010891f:	0f b6 05 90 79 19 80 	movzbl 0x80197990,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108926:	0f b6 c0             	movzbl %al,%eax
80108929:	83 ec 04             	sub    $0x4,%esp
8010892c:	57                   	push   %edi
8010892d:	56                   	push   %esi
8010892e:	53                   	push   %ebx
8010892f:	51                   	push   %ecx
80108930:	52                   	push   %edx
80108931:	50                   	push   %eax
80108932:	68 f8 c1 10 80       	push   $0x8010c1f8
80108937:	e8 b8 7a ff ff       	call   801003f4 <cprintf>
8010893c:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
8010893f:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108944:	05 00 54 00 00       	add    $0x5400,%eax
80108949:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010894c:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108951:	05 04 54 00 00       	add    $0x5404,%eax
80108956:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108959:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010895c:	c1 e0 10             	shl    $0x10,%eax
8010895f:	0b 45 d8             	or     -0x28(%ebp),%eax
80108962:	89 c2                	mov    %eax,%edx
80108964:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108967:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108969:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010896c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108971:	89 c2                	mov    %eax,%edx
80108973:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108976:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108978:	a1 8c 79 19 80       	mov    0x8019798c,%eax
8010897d:	05 00 52 00 00       	add    $0x5200,%eax
80108982:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108985:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010898c:	eb 19                	jmp    801089a7 <i8254_init_recv+0x12c>
    mta[i] = 0;
8010898e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108991:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108998:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010899b:	01 d0                	add    %edx,%eax
8010899d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801089a3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801089a7:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801089ab:	7e e1                	jle    8010898e <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801089ad:	a1 8c 79 19 80       	mov    0x8019798c,%eax
801089b2:	05 d0 00 00 00       	add    $0xd0,%eax
801089b7:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801089ba:	8b 45 c0             	mov    -0x40(%ebp),%eax
801089bd:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801089c3:	a1 8c 79 19 80       	mov    0x8019798c,%eax
801089c8:	05 c8 00 00 00       	add    $0xc8,%eax
801089cd:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801089d0:	8b 45 bc             	mov    -0x44(%ebp),%eax
801089d3:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801089d9:	a1 8c 79 19 80       	mov    0x8019798c,%eax
801089de:	05 28 28 00 00       	add    $0x2828,%eax
801089e3:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801089e6:	8b 45 b8             	mov    -0x48(%ebp),%eax
801089e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801089ef:	a1 8c 79 19 80       	mov    0x8019798c,%eax
801089f4:	05 00 01 00 00       	add    $0x100,%eax
801089f9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801089fc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801089ff:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108a05:	e8 96 9d ff ff       	call   801027a0 <kalloc>
80108a0a:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108a0d:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108a12:	05 00 28 00 00       	add    $0x2800,%eax
80108a17:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108a1a:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108a1f:	05 04 28 00 00       	add    $0x2804,%eax
80108a24:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108a27:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108a2c:	05 08 28 00 00       	add    $0x2808,%eax
80108a31:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108a34:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108a39:	05 10 28 00 00       	add    $0x2810,%eax
80108a3e:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108a41:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108a46:	05 18 28 00 00       	add    $0x2818,%eax
80108a4b:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108a4e:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108a51:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108a57:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108a5a:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108a5c:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108a5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108a65:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108a68:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108a6e:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108a71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108a77:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108a7a:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108a80:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108a83:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108a86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108a8d:	eb 73                	jmp    80108b02 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108a8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a92:	c1 e0 04             	shl    $0x4,%eax
80108a95:	89 c2                	mov    %eax,%edx
80108a97:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a9a:	01 d0                	add    %edx,%eax
80108a9c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108aa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108aa6:	c1 e0 04             	shl    $0x4,%eax
80108aa9:	89 c2                	mov    %eax,%edx
80108aab:	8b 45 98             	mov    -0x68(%ebp),%eax
80108aae:	01 d0                	add    %edx,%eax
80108ab0:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108ab6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ab9:	c1 e0 04             	shl    $0x4,%eax
80108abc:	89 c2                	mov    %eax,%edx
80108abe:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ac1:	01 d0                	add    %edx,%eax
80108ac3:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108ac9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108acc:	c1 e0 04             	shl    $0x4,%eax
80108acf:	89 c2                	mov    %eax,%edx
80108ad1:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ad4:	01 d0                	add    %edx,%eax
80108ad6:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108ada:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108add:	c1 e0 04             	shl    $0x4,%eax
80108ae0:	89 c2                	mov    %eax,%edx
80108ae2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ae5:	01 d0                	add    %edx,%eax
80108ae7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108aeb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108aee:	c1 e0 04             	shl    $0x4,%eax
80108af1:	89 c2                	mov    %eax,%edx
80108af3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108af6:	01 d0                	add    %edx,%eax
80108af8:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108afe:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108b02:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108b09:	7e 84                	jle    80108a8f <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108b0b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108b12:	eb 57                	jmp    80108b6b <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108b14:	e8 87 9c ff ff       	call   801027a0 <kalloc>
80108b19:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108b1c:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108b20:	75 12                	jne    80108b34 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108b22:	83 ec 0c             	sub    $0xc,%esp
80108b25:	68 18 c2 10 80       	push   $0x8010c218
80108b2a:	e8 c5 78 ff ff       	call   801003f4 <cprintf>
80108b2f:	83 c4 10             	add    $0x10,%esp
      break;
80108b32:	eb 3d                	jmp    80108b71 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108b34:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b37:	c1 e0 04             	shl    $0x4,%eax
80108b3a:	89 c2                	mov    %eax,%edx
80108b3c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b3f:	01 d0                	add    %edx,%eax
80108b41:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108b44:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b4a:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108b4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b4f:	83 c0 01             	add    $0x1,%eax
80108b52:	c1 e0 04             	shl    $0x4,%eax
80108b55:	89 c2                	mov    %eax,%edx
80108b57:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b5a:	01 d0                	add    %edx,%eax
80108b5c:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108b5f:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108b65:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108b67:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108b6b:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108b6f:	7e a3                	jle    80108b14 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108b71:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b74:	8b 00                	mov    (%eax),%eax
80108b76:	83 c8 02             	or     $0x2,%eax
80108b79:	89 c2                	mov    %eax,%edx
80108b7b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b7e:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108b80:	83 ec 0c             	sub    $0xc,%esp
80108b83:	68 38 c2 10 80       	push   $0x8010c238
80108b88:	e8 67 78 ff ff       	call   801003f4 <cprintf>
80108b8d:	83 c4 10             	add    $0x10,%esp
}
80108b90:	90                   	nop
80108b91:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108b94:	5b                   	pop    %ebx
80108b95:	5e                   	pop    %esi
80108b96:	5f                   	pop    %edi
80108b97:	5d                   	pop    %ebp
80108b98:	c3                   	ret    

80108b99 <i8254_init_send>:

void i8254_init_send(){
80108b99:	55                   	push   %ebp
80108b9a:	89 e5                	mov    %esp,%ebp
80108b9c:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108b9f:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108ba4:	05 28 38 00 00       	add    $0x3828,%eax
80108ba9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108bac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108baf:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108bb5:	e8 e6 9b ff ff       	call   801027a0 <kalloc>
80108bba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108bbd:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108bc2:	05 00 38 00 00       	add    $0x3800,%eax
80108bc7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108bca:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108bcf:	05 04 38 00 00       	add    $0x3804,%eax
80108bd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108bd7:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108bdc:	05 08 38 00 00       	add    $0x3808,%eax
80108be1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108be4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108be7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108bed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108bf0:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108bf2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bf5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108bfb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108bfe:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108c04:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108c09:	05 10 38 00 00       	add    $0x3810,%eax
80108c0e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108c11:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108c16:	05 18 38 00 00       	add    $0x3818,%eax
80108c1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108c1e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108c27:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108c30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c33:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108c36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c3d:	e9 82 00 00 00       	jmp    80108cc4 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c45:	c1 e0 04             	shl    $0x4,%eax
80108c48:	89 c2                	mov    %eax,%edx
80108c4a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c4d:	01 d0                	add    %edx,%eax
80108c4f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c59:	c1 e0 04             	shl    $0x4,%eax
80108c5c:	89 c2                	mov    %eax,%edx
80108c5e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c61:	01 d0                	add    %edx,%eax
80108c63:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6c:	c1 e0 04             	shl    $0x4,%eax
80108c6f:	89 c2                	mov    %eax,%edx
80108c71:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c74:	01 d0                	add    %edx,%eax
80108c76:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c7d:	c1 e0 04             	shl    $0x4,%eax
80108c80:	89 c2                	mov    %eax,%edx
80108c82:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c85:	01 d0                	add    %edx,%eax
80108c87:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8e:	c1 e0 04             	shl    $0x4,%eax
80108c91:	89 c2                	mov    %eax,%edx
80108c93:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c96:	01 d0                	add    %edx,%eax
80108c98:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9f:	c1 e0 04             	shl    $0x4,%eax
80108ca2:	89 c2                	mov    %eax,%edx
80108ca4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ca7:	01 d0                	add    %edx,%eax
80108ca9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb0:	c1 e0 04             	shl    $0x4,%eax
80108cb3:	89 c2                	mov    %eax,%edx
80108cb5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cb8:	01 d0                	add    %edx,%eax
80108cba:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108cc0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108cc4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108ccb:	0f 8e 71 ff ff ff    	jle    80108c42 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108cd1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108cd8:	eb 57                	jmp    80108d31 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108cda:	e8 c1 9a ff ff       	call   801027a0 <kalloc>
80108cdf:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108ce2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108ce6:	75 12                	jne    80108cfa <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108ce8:	83 ec 0c             	sub    $0xc,%esp
80108ceb:	68 18 c2 10 80       	push   $0x8010c218
80108cf0:	e8 ff 76 ff ff       	call   801003f4 <cprintf>
80108cf5:	83 c4 10             	add    $0x10,%esp
      break;
80108cf8:	eb 3d                	jmp    80108d37 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cfd:	c1 e0 04             	shl    $0x4,%eax
80108d00:	89 c2                	mov    %eax,%edx
80108d02:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d05:	01 d0                	add    %edx,%eax
80108d07:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108d0a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d10:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d15:	83 c0 01             	add    $0x1,%eax
80108d18:	c1 e0 04             	shl    $0x4,%eax
80108d1b:	89 c2                	mov    %eax,%edx
80108d1d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d20:	01 d0                	add    %edx,%eax
80108d22:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108d25:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d2b:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108d2d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108d31:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108d35:	7e a3                	jle    80108cda <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108d37:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108d3c:	05 00 04 00 00       	add    $0x400,%eax
80108d41:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108d44:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108d47:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108d4d:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108d52:	05 10 04 00 00       	add    $0x410,%eax
80108d57:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108d5a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108d5d:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108d63:	83 ec 0c             	sub    $0xc,%esp
80108d66:	68 58 c2 10 80       	push   $0x8010c258
80108d6b:	e8 84 76 ff ff       	call   801003f4 <cprintf>
80108d70:	83 c4 10             	add    $0x10,%esp

}
80108d73:	90                   	nop
80108d74:	c9                   	leave  
80108d75:	c3                   	ret    

80108d76 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108d76:	55                   	push   %ebp
80108d77:	89 e5                	mov    %esp,%ebp
80108d79:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108d7c:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108d81:	83 c0 14             	add    $0x14,%eax
80108d84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108d87:	8b 45 08             	mov    0x8(%ebp),%eax
80108d8a:	c1 e0 08             	shl    $0x8,%eax
80108d8d:	0f b7 c0             	movzwl %ax,%eax
80108d90:	83 c8 01             	or     $0x1,%eax
80108d93:	89 c2                	mov    %eax,%edx
80108d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d98:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108d9a:	83 ec 0c             	sub    $0xc,%esp
80108d9d:	68 78 c2 10 80       	push   $0x8010c278
80108da2:	e8 4d 76 ff ff       	call   801003f4 <cprintf>
80108da7:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dad:	8b 00                	mov    (%eax),%eax
80108daf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108db5:	83 e0 10             	and    $0x10,%eax
80108db8:	85 c0                	test   %eax,%eax
80108dba:	75 02                	jne    80108dbe <i8254_read_eeprom+0x48>
  while(1){
80108dbc:	eb dc                	jmp    80108d9a <i8254_read_eeprom+0x24>
      break;
80108dbe:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc2:	8b 00                	mov    (%eax),%eax
80108dc4:	c1 e8 10             	shr    $0x10,%eax
}
80108dc7:	c9                   	leave  
80108dc8:	c3                   	ret    

80108dc9 <i8254_recv>:
void i8254_recv(){
80108dc9:	55                   	push   %ebp
80108dca:	89 e5                	mov    %esp,%ebp
80108dcc:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108dcf:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108dd4:	05 10 28 00 00       	add    $0x2810,%eax
80108dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108ddc:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108de1:	05 18 28 00 00       	add    $0x2818,%eax
80108de6:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108de9:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108dee:	05 00 28 00 00       	add    $0x2800,%eax
80108df3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108df6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108df9:	8b 00                	mov    (%eax),%eax
80108dfb:	05 00 00 00 80       	add    $0x80000000,%eax
80108e00:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e06:	8b 10                	mov    (%eax),%edx
80108e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e0b:	8b 08                	mov    (%eax),%ecx
80108e0d:	89 d0                	mov    %edx,%eax
80108e0f:	29 c8                	sub    %ecx,%eax
80108e11:	25 ff 00 00 00       	and    $0xff,%eax
80108e16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108e19:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108e1d:	7e 37                	jle    80108e56 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e22:	8b 00                	mov    (%eax),%eax
80108e24:	c1 e0 04             	shl    $0x4,%eax
80108e27:	89 c2                	mov    %eax,%edx
80108e29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e2c:	01 d0                	add    %edx,%eax
80108e2e:	8b 00                	mov    (%eax),%eax
80108e30:	05 00 00 00 80       	add    $0x80000000,%eax
80108e35:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e3b:	8b 00                	mov    (%eax),%eax
80108e3d:	83 c0 01             	add    $0x1,%eax
80108e40:	0f b6 d0             	movzbl %al,%edx
80108e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e46:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108e48:	83 ec 0c             	sub    $0xc,%esp
80108e4b:	ff 75 e0             	push   -0x20(%ebp)
80108e4e:	e8 15 09 00 00       	call   80109768 <eth_proc>
80108e53:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e59:	8b 10                	mov    (%eax),%edx
80108e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e5e:	8b 00                	mov    (%eax),%eax
80108e60:	39 c2                	cmp    %eax,%edx
80108e62:	75 9f                	jne    80108e03 <i8254_recv+0x3a>
      (*rdt)--;
80108e64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e67:	8b 00                	mov    (%eax),%eax
80108e69:	8d 50 ff             	lea    -0x1(%eax),%edx
80108e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6f:	89 10                	mov    %edx,(%eax)
  while(1){
80108e71:	eb 90                	jmp    80108e03 <i8254_recv+0x3a>

80108e73 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108e73:	55                   	push   %ebp
80108e74:	89 e5                	mov    %esp,%ebp
80108e76:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108e79:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108e7e:	05 10 38 00 00       	add    $0x3810,%eax
80108e83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108e86:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108e8b:	05 18 38 00 00       	add    $0x3818,%eax
80108e90:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108e93:	a1 8c 79 19 80       	mov    0x8019798c,%eax
80108e98:	05 00 38 00 00       	add    $0x3800,%eax
80108e9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108ea0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ea3:	8b 00                	mov    (%eax),%eax
80108ea5:	05 00 00 00 80       	add    $0x80000000,%eax
80108eaa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb0:	8b 10                	mov    (%eax),%edx
80108eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb5:	8b 08                	mov    (%eax),%ecx
80108eb7:	89 d0                	mov    %edx,%eax
80108eb9:	29 c8                	sub    %ecx,%eax
80108ebb:	0f b6 d0             	movzbl %al,%edx
80108ebe:	b8 00 01 00 00       	mov    $0x100,%eax
80108ec3:	29 d0                	sub    %edx,%eax
80108ec5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ecb:	8b 00                	mov    (%eax),%eax
80108ecd:	25 ff 00 00 00       	and    $0xff,%eax
80108ed2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108ed5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108ed9:	0f 8e a8 00 00 00    	jle    80108f87 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108edf:	8b 45 08             	mov    0x8(%ebp),%eax
80108ee2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108ee5:	89 d1                	mov    %edx,%ecx
80108ee7:	c1 e1 04             	shl    $0x4,%ecx
80108eea:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108eed:	01 ca                	add    %ecx,%edx
80108eef:	8b 12                	mov    (%edx),%edx
80108ef1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108ef7:	83 ec 04             	sub    $0x4,%esp
80108efa:	ff 75 0c             	push   0xc(%ebp)
80108efd:	50                   	push   %eax
80108efe:	52                   	push   %edx
80108eff:	e8 39 bd ff ff       	call   80104c3d <memmove>
80108f04:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108f07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f0a:	c1 e0 04             	shl    $0x4,%eax
80108f0d:	89 c2                	mov    %eax,%edx
80108f0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f12:	01 d0                	add    %edx,%eax
80108f14:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f17:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108f1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f1e:	c1 e0 04             	shl    $0x4,%eax
80108f21:	89 c2                	mov    %eax,%edx
80108f23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f26:	01 d0                	add    %edx,%eax
80108f28:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108f2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f2f:	c1 e0 04             	shl    $0x4,%eax
80108f32:	89 c2                	mov    %eax,%edx
80108f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f37:	01 d0                	add    %edx,%eax
80108f39:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f40:	c1 e0 04             	shl    $0x4,%eax
80108f43:	89 c2                	mov    %eax,%edx
80108f45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f48:	01 d0                	add    %edx,%eax
80108f4a:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108f4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f51:	c1 e0 04             	shl    $0x4,%eax
80108f54:	89 c2                	mov    %eax,%edx
80108f56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f59:	01 d0                	add    %edx,%eax
80108f5b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108f61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f64:	c1 e0 04             	shl    $0x4,%eax
80108f67:	89 c2                	mov    %eax,%edx
80108f69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f6c:	01 d0                	add    %edx,%eax
80108f6e:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f75:	8b 00                	mov    (%eax),%eax
80108f77:	83 c0 01             	add    $0x1,%eax
80108f7a:	0f b6 d0             	movzbl %al,%edx
80108f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f80:	89 10                	mov    %edx,(%eax)
    return len;
80108f82:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f85:	eb 05                	jmp    80108f8c <i8254_send+0x119>
  }else{
    return -1;
80108f87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108f8c:	c9                   	leave  
80108f8d:	c3                   	ret    

80108f8e <i8254_intr>:

void i8254_intr(){
80108f8e:	55                   	push   %ebp
80108f8f:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108f91:	a1 98 79 19 80       	mov    0x80197998,%eax
80108f96:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108f9c:	90                   	nop
80108f9d:	5d                   	pop    %ebp
80108f9e:	c3                   	ret    

80108f9f <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108f9f:	55                   	push   %ebp
80108fa0:	89 e5                	mov    %esp,%ebp
80108fa2:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80108fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fae:	0f b7 00             	movzwl (%eax),%eax
80108fb1:	66 3d 00 01          	cmp    $0x100,%ax
80108fb5:	74 0a                	je     80108fc1 <arp_proc+0x22>
80108fb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fbc:	e9 4f 01 00 00       	jmp    80109110 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc4:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108fc8:	66 83 f8 08          	cmp    $0x8,%ax
80108fcc:	74 0a                	je     80108fd8 <arp_proc+0x39>
80108fce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fd3:	e9 38 01 00 00       	jmp    80109110 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fdb:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108fdf:	3c 06                	cmp    $0x6,%al
80108fe1:	74 0a                	je     80108fed <arp_proc+0x4e>
80108fe3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fe8:	e9 23 01 00 00       	jmp    80109110 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff0:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108ff4:	3c 04                	cmp    $0x4,%al
80108ff6:	74 0a                	je     80109002 <arp_proc+0x63>
80108ff8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ffd:	e9 0e 01 00 00       	jmp    80109110 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109005:	83 c0 18             	add    $0x18,%eax
80109008:	83 ec 04             	sub    $0x4,%esp
8010900b:	6a 04                	push   $0x4
8010900d:	50                   	push   %eax
8010900e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109013:	e8 cd bb ff ff       	call   80104be5 <memcmp>
80109018:	83 c4 10             	add    $0x10,%esp
8010901b:	85 c0                	test   %eax,%eax
8010901d:	74 27                	je     80109046 <arp_proc+0xa7>
8010901f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109022:	83 c0 0e             	add    $0xe,%eax
80109025:	83 ec 04             	sub    $0x4,%esp
80109028:	6a 04                	push   $0x4
8010902a:	50                   	push   %eax
8010902b:	68 e4 f4 10 80       	push   $0x8010f4e4
80109030:	e8 b0 bb ff ff       	call   80104be5 <memcmp>
80109035:	83 c4 10             	add    $0x10,%esp
80109038:	85 c0                	test   %eax,%eax
8010903a:	74 0a                	je     80109046 <arp_proc+0xa7>
8010903c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109041:	e9 ca 00 00 00       	jmp    80109110 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109049:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010904d:	66 3d 00 01          	cmp    $0x100,%ax
80109051:	75 69                	jne    801090bc <arp_proc+0x11d>
80109053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109056:	83 c0 18             	add    $0x18,%eax
80109059:	83 ec 04             	sub    $0x4,%esp
8010905c:	6a 04                	push   $0x4
8010905e:	50                   	push   %eax
8010905f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109064:	e8 7c bb ff ff       	call   80104be5 <memcmp>
80109069:	83 c4 10             	add    $0x10,%esp
8010906c:	85 c0                	test   %eax,%eax
8010906e:	75 4c                	jne    801090bc <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109070:	e8 2b 97 ff ff       	call   801027a0 <kalloc>
80109075:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109078:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
8010907f:	83 ec 04             	sub    $0x4,%esp
80109082:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109085:	50                   	push   %eax
80109086:	ff 75 f0             	push   -0x10(%ebp)
80109089:	ff 75 f4             	push   -0xc(%ebp)
8010908c:	e8 1f 04 00 00       	call   801094b0 <arp_reply_pkt_create>
80109091:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109094:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109097:	83 ec 08             	sub    $0x8,%esp
8010909a:	50                   	push   %eax
8010909b:	ff 75 f0             	push   -0x10(%ebp)
8010909e:	e8 d0 fd ff ff       	call   80108e73 <i8254_send>
801090a3:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801090a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090a9:	83 ec 0c             	sub    $0xc,%esp
801090ac:	50                   	push   %eax
801090ad:	e8 54 96 ff ff       	call   80102706 <kfree>
801090b2:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801090b5:	b8 02 00 00 00       	mov    $0x2,%eax
801090ba:	eb 54                	jmp    80109110 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801090bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090bf:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801090c3:	66 3d 00 02          	cmp    $0x200,%ax
801090c7:	75 42                	jne    8010910b <arp_proc+0x16c>
801090c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090cc:	83 c0 18             	add    $0x18,%eax
801090cf:	83 ec 04             	sub    $0x4,%esp
801090d2:	6a 04                	push   $0x4
801090d4:	50                   	push   %eax
801090d5:	68 e4 f4 10 80       	push   $0x8010f4e4
801090da:	e8 06 bb ff ff       	call   80104be5 <memcmp>
801090df:	83 c4 10             	add    $0x10,%esp
801090e2:	85 c0                	test   %eax,%eax
801090e4:	75 25                	jne    8010910b <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801090e6:	83 ec 0c             	sub    $0xc,%esp
801090e9:	68 7c c2 10 80       	push   $0x8010c27c
801090ee:	e8 01 73 ff ff       	call   801003f4 <cprintf>
801090f3:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801090f6:	83 ec 0c             	sub    $0xc,%esp
801090f9:	ff 75 f4             	push   -0xc(%ebp)
801090fc:	e8 af 01 00 00       	call   801092b0 <arp_table_update>
80109101:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109104:	b8 01 00 00 00       	mov    $0x1,%eax
80109109:	eb 05                	jmp    80109110 <arp_proc+0x171>
  }else{
    return -1;
8010910b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109110:	c9                   	leave  
80109111:	c3                   	ret    

80109112 <arp_scan>:

void arp_scan(){
80109112:	55                   	push   %ebp
80109113:	89 e5                	mov    %esp,%ebp
80109115:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109118:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010911f:	eb 6f                	jmp    80109190 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109121:	e8 7a 96 ff ff       	call   801027a0 <kalloc>
80109126:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109129:	83 ec 04             	sub    $0x4,%esp
8010912c:	ff 75 f4             	push   -0xc(%ebp)
8010912f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109132:	50                   	push   %eax
80109133:	ff 75 ec             	push   -0x14(%ebp)
80109136:	e8 62 00 00 00       	call   8010919d <arp_broadcast>
8010913b:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010913e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109141:	83 ec 08             	sub    $0x8,%esp
80109144:	50                   	push   %eax
80109145:	ff 75 ec             	push   -0x14(%ebp)
80109148:	e8 26 fd ff ff       	call   80108e73 <i8254_send>
8010914d:	83 c4 10             	add    $0x10,%esp
80109150:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109153:	eb 22                	jmp    80109177 <arp_scan+0x65>
      microdelay(1);
80109155:	83 ec 0c             	sub    $0xc,%esp
80109158:	6a 01                	push   $0x1
8010915a:	e8 d8 99 ff ff       	call   80102b37 <microdelay>
8010915f:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109162:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109165:	83 ec 08             	sub    $0x8,%esp
80109168:	50                   	push   %eax
80109169:	ff 75 ec             	push   -0x14(%ebp)
8010916c:	e8 02 fd ff ff       	call   80108e73 <i8254_send>
80109171:	83 c4 10             	add    $0x10,%esp
80109174:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109177:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010917b:	74 d8                	je     80109155 <arp_scan+0x43>
    }
    kfree((char *)send);
8010917d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109180:	83 ec 0c             	sub    $0xc,%esp
80109183:	50                   	push   %eax
80109184:	e8 7d 95 ff ff       	call   80102706 <kfree>
80109189:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010918c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109190:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109197:	7e 88                	jle    80109121 <arp_scan+0xf>
  }
}
80109199:	90                   	nop
8010919a:	90                   	nop
8010919b:	c9                   	leave  
8010919c:	c3                   	ret    

8010919d <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010919d:	55                   	push   %ebp
8010919e:	89 e5                	mov    %esp,%ebp
801091a0:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801091a3:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801091a7:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801091ab:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801091af:	8b 45 10             	mov    0x10(%ebp),%eax
801091b2:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801091b5:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801091bc:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801091c2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801091c9:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801091cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801091d2:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801091d8:	8b 45 08             	mov    0x8(%ebp),%eax
801091db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801091de:	8b 45 08             	mov    0x8(%ebp),%eax
801091e1:	83 c0 0e             	add    $0xe,%eax
801091e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801091e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ea:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801091ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f1:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801091f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f8:	83 ec 04             	sub    $0x4,%esp
801091fb:	6a 06                	push   $0x6
801091fd:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109200:	52                   	push   %edx
80109201:	50                   	push   %eax
80109202:	e8 36 ba ff ff       	call   80104c3d <memmove>
80109207:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010920a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010920d:	83 c0 06             	add    $0x6,%eax
80109210:	83 ec 04             	sub    $0x4,%esp
80109213:	6a 06                	push   $0x6
80109215:	68 90 79 19 80       	push   $0x80197990
8010921a:	50                   	push   %eax
8010921b:	e8 1d ba ff ff       	call   80104c3d <memmove>
80109220:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109223:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109226:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010922b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010922e:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109234:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109237:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010923b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010923e:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109242:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109245:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010924b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924e:	8d 50 12             	lea    0x12(%eax),%edx
80109251:	83 ec 04             	sub    $0x4,%esp
80109254:	6a 06                	push   $0x6
80109256:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109259:	50                   	push   %eax
8010925a:	52                   	push   %edx
8010925b:	e8 dd b9 ff ff       	call   80104c3d <memmove>
80109260:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109263:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109266:	8d 50 18             	lea    0x18(%eax),%edx
80109269:	83 ec 04             	sub    $0x4,%esp
8010926c:	6a 04                	push   $0x4
8010926e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109271:	50                   	push   %eax
80109272:	52                   	push   %edx
80109273:	e8 c5 b9 ff ff       	call   80104c3d <memmove>
80109278:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010927b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010927e:	83 c0 08             	add    $0x8,%eax
80109281:	83 ec 04             	sub    $0x4,%esp
80109284:	6a 06                	push   $0x6
80109286:	68 90 79 19 80       	push   $0x80197990
8010928b:	50                   	push   %eax
8010928c:	e8 ac b9 ff ff       	call   80104c3d <memmove>
80109291:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109294:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109297:	83 c0 0e             	add    $0xe,%eax
8010929a:	83 ec 04             	sub    $0x4,%esp
8010929d:	6a 04                	push   $0x4
8010929f:	68 e4 f4 10 80       	push   $0x8010f4e4
801092a4:	50                   	push   %eax
801092a5:	e8 93 b9 ff ff       	call   80104c3d <memmove>
801092aa:	83 c4 10             	add    $0x10,%esp
}
801092ad:	90                   	nop
801092ae:	c9                   	leave  
801092af:	c3                   	ret    

801092b0 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801092b0:	55                   	push   %ebp
801092b1:	89 e5                	mov    %esp,%ebp
801092b3:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801092b6:	8b 45 08             	mov    0x8(%ebp),%eax
801092b9:	83 c0 0e             	add    $0xe,%eax
801092bc:	83 ec 0c             	sub    $0xc,%esp
801092bf:	50                   	push   %eax
801092c0:	e8 bc 00 00 00       	call   80109381 <arp_table_search>
801092c5:	83 c4 10             	add    $0x10,%esp
801092c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801092cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801092cf:	78 2d                	js     801092fe <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801092d1:	8b 45 08             	mov    0x8(%ebp),%eax
801092d4:	8d 48 08             	lea    0x8(%eax),%ecx
801092d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092da:	89 d0                	mov    %edx,%eax
801092dc:	c1 e0 02             	shl    $0x2,%eax
801092df:	01 d0                	add    %edx,%eax
801092e1:	01 c0                	add    %eax,%eax
801092e3:	01 d0                	add    %edx,%eax
801092e5:	05 a0 79 19 80       	add    $0x801979a0,%eax
801092ea:	83 c0 04             	add    $0x4,%eax
801092ed:	83 ec 04             	sub    $0x4,%esp
801092f0:	6a 06                	push   $0x6
801092f2:	51                   	push   %ecx
801092f3:	50                   	push   %eax
801092f4:	e8 44 b9 ff ff       	call   80104c3d <memmove>
801092f9:	83 c4 10             	add    $0x10,%esp
801092fc:	eb 70                	jmp    8010936e <arp_table_update+0xbe>
  }else{
    index += 1;
801092fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109302:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109305:	8b 45 08             	mov    0x8(%ebp),%eax
80109308:	8d 48 08             	lea    0x8(%eax),%ecx
8010930b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010930e:	89 d0                	mov    %edx,%eax
80109310:	c1 e0 02             	shl    $0x2,%eax
80109313:	01 d0                	add    %edx,%eax
80109315:	01 c0                	add    %eax,%eax
80109317:	01 d0                	add    %edx,%eax
80109319:	05 a0 79 19 80       	add    $0x801979a0,%eax
8010931e:	83 c0 04             	add    $0x4,%eax
80109321:	83 ec 04             	sub    $0x4,%esp
80109324:	6a 06                	push   $0x6
80109326:	51                   	push   %ecx
80109327:	50                   	push   %eax
80109328:	e8 10 b9 ff ff       	call   80104c3d <memmove>
8010932d:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109330:	8b 45 08             	mov    0x8(%ebp),%eax
80109333:	8d 48 0e             	lea    0xe(%eax),%ecx
80109336:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109339:	89 d0                	mov    %edx,%eax
8010933b:	c1 e0 02             	shl    $0x2,%eax
8010933e:	01 d0                	add    %edx,%eax
80109340:	01 c0                	add    %eax,%eax
80109342:	01 d0                	add    %edx,%eax
80109344:	05 a0 79 19 80       	add    $0x801979a0,%eax
80109349:	83 ec 04             	sub    $0x4,%esp
8010934c:	6a 04                	push   $0x4
8010934e:	51                   	push   %ecx
8010934f:	50                   	push   %eax
80109350:	e8 e8 b8 ff ff       	call   80104c3d <memmove>
80109355:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109358:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010935b:	89 d0                	mov    %edx,%eax
8010935d:	c1 e0 02             	shl    $0x2,%eax
80109360:	01 d0                	add    %edx,%eax
80109362:	01 c0                	add    %eax,%eax
80109364:	01 d0                	add    %edx,%eax
80109366:	05 aa 79 19 80       	add    $0x801979aa,%eax
8010936b:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010936e:	83 ec 0c             	sub    $0xc,%esp
80109371:	68 a0 79 19 80       	push   $0x801979a0
80109376:	e8 83 00 00 00       	call   801093fe <print_arp_table>
8010937b:	83 c4 10             	add    $0x10,%esp
}
8010937e:	90                   	nop
8010937f:	c9                   	leave  
80109380:	c3                   	ret    

80109381 <arp_table_search>:

int arp_table_search(uchar *ip){
80109381:	55                   	push   %ebp
80109382:	89 e5                	mov    %esp,%ebp
80109384:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109387:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010938e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109395:	eb 59                	jmp    801093f0 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109397:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010939a:	89 d0                	mov    %edx,%eax
8010939c:	c1 e0 02             	shl    $0x2,%eax
8010939f:	01 d0                	add    %edx,%eax
801093a1:	01 c0                	add    %eax,%eax
801093a3:	01 d0                	add    %edx,%eax
801093a5:	05 a0 79 19 80       	add    $0x801979a0,%eax
801093aa:	83 ec 04             	sub    $0x4,%esp
801093ad:	6a 04                	push   $0x4
801093af:	ff 75 08             	push   0x8(%ebp)
801093b2:	50                   	push   %eax
801093b3:	e8 2d b8 ff ff       	call   80104be5 <memcmp>
801093b8:	83 c4 10             	add    $0x10,%esp
801093bb:	85 c0                	test   %eax,%eax
801093bd:	75 05                	jne    801093c4 <arp_table_search+0x43>
      return i;
801093bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c2:	eb 38                	jmp    801093fc <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801093c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801093c7:	89 d0                	mov    %edx,%eax
801093c9:	c1 e0 02             	shl    $0x2,%eax
801093cc:	01 d0                	add    %edx,%eax
801093ce:	01 c0                	add    %eax,%eax
801093d0:	01 d0                	add    %edx,%eax
801093d2:	05 aa 79 19 80       	add    $0x801979aa,%eax
801093d7:	0f b6 00             	movzbl (%eax),%eax
801093da:	84 c0                	test   %al,%al
801093dc:	75 0e                	jne    801093ec <arp_table_search+0x6b>
801093de:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801093e2:	75 08                	jne    801093ec <arp_table_search+0x6b>
      empty = -i;
801093e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e7:	f7 d8                	neg    %eax
801093e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801093ec:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801093f0:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801093f4:	7e a1                	jle    80109397 <arp_table_search+0x16>
    }
  }
  return empty-1;
801093f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f9:	83 e8 01             	sub    $0x1,%eax
}
801093fc:	c9                   	leave  
801093fd:	c3                   	ret    

801093fe <print_arp_table>:

void print_arp_table(){
801093fe:	55                   	push   %ebp
801093ff:	89 e5                	mov    %esp,%ebp
80109401:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010940b:	e9 92 00 00 00       	jmp    801094a2 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109410:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109413:	89 d0                	mov    %edx,%eax
80109415:	c1 e0 02             	shl    $0x2,%eax
80109418:	01 d0                	add    %edx,%eax
8010941a:	01 c0                	add    %eax,%eax
8010941c:	01 d0                	add    %edx,%eax
8010941e:	05 aa 79 19 80       	add    $0x801979aa,%eax
80109423:	0f b6 00             	movzbl (%eax),%eax
80109426:	84 c0                	test   %al,%al
80109428:	74 74                	je     8010949e <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010942a:	83 ec 08             	sub    $0x8,%esp
8010942d:	ff 75 f4             	push   -0xc(%ebp)
80109430:	68 8f c2 10 80       	push   $0x8010c28f
80109435:	e8 ba 6f ff ff       	call   801003f4 <cprintf>
8010943a:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010943d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109440:	89 d0                	mov    %edx,%eax
80109442:	c1 e0 02             	shl    $0x2,%eax
80109445:	01 d0                	add    %edx,%eax
80109447:	01 c0                	add    %eax,%eax
80109449:	01 d0                	add    %edx,%eax
8010944b:	05 a0 79 19 80       	add    $0x801979a0,%eax
80109450:	83 ec 0c             	sub    $0xc,%esp
80109453:	50                   	push   %eax
80109454:	e8 54 02 00 00       	call   801096ad <print_ipv4>
80109459:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010945c:	83 ec 0c             	sub    $0xc,%esp
8010945f:	68 9e c2 10 80       	push   $0x8010c29e
80109464:	e8 8b 6f ff ff       	call   801003f4 <cprintf>
80109469:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010946c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010946f:	89 d0                	mov    %edx,%eax
80109471:	c1 e0 02             	shl    $0x2,%eax
80109474:	01 d0                	add    %edx,%eax
80109476:	01 c0                	add    %eax,%eax
80109478:	01 d0                	add    %edx,%eax
8010947a:	05 a0 79 19 80       	add    $0x801979a0,%eax
8010947f:	83 c0 04             	add    $0x4,%eax
80109482:	83 ec 0c             	sub    $0xc,%esp
80109485:	50                   	push   %eax
80109486:	e8 70 02 00 00       	call   801096fb <print_mac>
8010948b:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010948e:	83 ec 0c             	sub    $0xc,%esp
80109491:	68 a0 c2 10 80       	push   $0x8010c2a0
80109496:	e8 59 6f ff ff       	call   801003f4 <cprintf>
8010949b:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010949e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094a2:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801094a6:	0f 8e 64 ff ff ff    	jle    80109410 <print_arp_table+0x12>
    }
  }
}
801094ac:	90                   	nop
801094ad:	90                   	nop
801094ae:	c9                   	leave  
801094af:	c3                   	ret    

801094b0 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801094b0:	55                   	push   %ebp
801094b1:	89 e5                	mov    %esp,%ebp
801094b3:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801094b6:	8b 45 10             	mov    0x10(%ebp),%eax
801094b9:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801094bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801094c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801094c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801094c8:	83 c0 0e             	add    $0xe,%eax
801094cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801094ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d1:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801094d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d8:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801094dc:	8b 45 08             	mov    0x8(%ebp),%eax
801094df:	8d 50 08             	lea    0x8(%eax),%edx
801094e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e5:	83 ec 04             	sub    $0x4,%esp
801094e8:	6a 06                	push   $0x6
801094ea:	52                   	push   %edx
801094eb:	50                   	push   %eax
801094ec:	e8 4c b7 ff ff       	call   80104c3d <memmove>
801094f1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801094f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f7:	83 c0 06             	add    $0x6,%eax
801094fa:	83 ec 04             	sub    $0x4,%esp
801094fd:	6a 06                	push   $0x6
801094ff:	68 90 79 19 80       	push   $0x80197990
80109504:	50                   	push   %eax
80109505:	e8 33 b7 ff ff       	call   80104c3d <memmove>
8010950a:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010950d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109510:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109515:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109518:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010951e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109521:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109528:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010952c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010952f:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109535:	8b 45 08             	mov    0x8(%ebp),%eax
80109538:	8d 50 08             	lea    0x8(%eax),%edx
8010953b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010953e:	83 c0 12             	add    $0x12,%eax
80109541:	83 ec 04             	sub    $0x4,%esp
80109544:	6a 06                	push   $0x6
80109546:	52                   	push   %edx
80109547:	50                   	push   %eax
80109548:	e8 f0 b6 ff ff       	call   80104c3d <memmove>
8010954d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109550:	8b 45 08             	mov    0x8(%ebp),%eax
80109553:	8d 50 0e             	lea    0xe(%eax),%edx
80109556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109559:	83 c0 18             	add    $0x18,%eax
8010955c:	83 ec 04             	sub    $0x4,%esp
8010955f:	6a 04                	push   $0x4
80109561:	52                   	push   %edx
80109562:	50                   	push   %eax
80109563:	e8 d5 b6 ff ff       	call   80104c3d <memmove>
80109568:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010956b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956e:	83 c0 08             	add    $0x8,%eax
80109571:	83 ec 04             	sub    $0x4,%esp
80109574:	6a 06                	push   $0x6
80109576:	68 90 79 19 80       	push   $0x80197990
8010957b:	50                   	push   %eax
8010957c:	e8 bc b6 ff ff       	call   80104c3d <memmove>
80109581:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109587:	83 c0 0e             	add    $0xe,%eax
8010958a:	83 ec 04             	sub    $0x4,%esp
8010958d:	6a 04                	push   $0x4
8010958f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109594:	50                   	push   %eax
80109595:	e8 a3 b6 ff ff       	call   80104c3d <memmove>
8010959a:	83 c4 10             	add    $0x10,%esp
}
8010959d:	90                   	nop
8010959e:	c9                   	leave  
8010959f:	c3                   	ret    

801095a0 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801095a0:	55                   	push   %ebp
801095a1:	89 e5                	mov    %esp,%ebp
801095a3:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801095a6:	83 ec 0c             	sub    $0xc,%esp
801095a9:	68 a2 c2 10 80       	push   $0x8010c2a2
801095ae:	e8 41 6e ff ff       	call   801003f4 <cprintf>
801095b3:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801095b6:	8b 45 08             	mov    0x8(%ebp),%eax
801095b9:	83 c0 0e             	add    $0xe,%eax
801095bc:	83 ec 0c             	sub    $0xc,%esp
801095bf:	50                   	push   %eax
801095c0:	e8 e8 00 00 00       	call   801096ad <print_ipv4>
801095c5:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801095c8:	83 ec 0c             	sub    $0xc,%esp
801095cb:	68 a0 c2 10 80       	push   $0x8010c2a0
801095d0:	e8 1f 6e ff ff       	call   801003f4 <cprintf>
801095d5:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801095d8:	8b 45 08             	mov    0x8(%ebp),%eax
801095db:	83 c0 08             	add    $0x8,%eax
801095de:	83 ec 0c             	sub    $0xc,%esp
801095e1:	50                   	push   %eax
801095e2:	e8 14 01 00 00       	call   801096fb <print_mac>
801095e7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801095ea:	83 ec 0c             	sub    $0xc,%esp
801095ed:	68 a0 c2 10 80       	push   $0x8010c2a0
801095f2:	e8 fd 6d ff ff       	call   801003f4 <cprintf>
801095f7:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801095fa:	83 ec 0c             	sub    $0xc,%esp
801095fd:	68 b9 c2 10 80       	push   $0x8010c2b9
80109602:	e8 ed 6d ff ff       	call   801003f4 <cprintf>
80109607:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010960a:	8b 45 08             	mov    0x8(%ebp),%eax
8010960d:	83 c0 18             	add    $0x18,%eax
80109610:	83 ec 0c             	sub    $0xc,%esp
80109613:	50                   	push   %eax
80109614:	e8 94 00 00 00       	call   801096ad <print_ipv4>
80109619:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010961c:	83 ec 0c             	sub    $0xc,%esp
8010961f:	68 a0 c2 10 80       	push   $0x8010c2a0
80109624:	e8 cb 6d ff ff       	call   801003f4 <cprintf>
80109629:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010962c:	8b 45 08             	mov    0x8(%ebp),%eax
8010962f:	83 c0 12             	add    $0x12,%eax
80109632:	83 ec 0c             	sub    $0xc,%esp
80109635:	50                   	push   %eax
80109636:	e8 c0 00 00 00       	call   801096fb <print_mac>
8010963b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010963e:	83 ec 0c             	sub    $0xc,%esp
80109641:	68 a0 c2 10 80       	push   $0x8010c2a0
80109646:	e8 a9 6d ff ff       	call   801003f4 <cprintf>
8010964b:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010964e:	83 ec 0c             	sub    $0xc,%esp
80109651:	68 d0 c2 10 80       	push   $0x8010c2d0
80109656:	e8 99 6d ff ff       	call   801003f4 <cprintf>
8010965b:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010965e:	8b 45 08             	mov    0x8(%ebp),%eax
80109661:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109665:	66 3d 00 01          	cmp    $0x100,%ax
80109669:	75 12                	jne    8010967d <print_arp_info+0xdd>
8010966b:	83 ec 0c             	sub    $0xc,%esp
8010966e:	68 dc c2 10 80       	push   $0x8010c2dc
80109673:	e8 7c 6d ff ff       	call   801003f4 <cprintf>
80109678:	83 c4 10             	add    $0x10,%esp
8010967b:	eb 1d                	jmp    8010969a <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010967d:	8b 45 08             	mov    0x8(%ebp),%eax
80109680:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109684:	66 3d 00 02          	cmp    $0x200,%ax
80109688:	75 10                	jne    8010969a <print_arp_info+0xfa>
    cprintf("Reply\n");
8010968a:	83 ec 0c             	sub    $0xc,%esp
8010968d:	68 e5 c2 10 80       	push   $0x8010c2e5
80109692:	e8 5d 6d ff ff       	call   801003f4 <cprintf>
80109697:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010969a:	83 ec 0c             	sub    $0xc,%esp
8010969d:	68 a0 c2 10 80       	push   $0x8010c2a0
801096a2:	e8 4d 6d ff ff       	call   801003f4 <cprintf>
801096a7:	83 c4 10             	add    $0x10,%esp
}
801096aa:	90                   	nop
801096ab:	c9                   	leave  
801096ac:	c3                   	ret    

801096ad <print_ipv4>:

void print_ipv4(uchar *ip){
801096ad:	55                   	push   %ebp
801096ae:	89 e5                	mov    %esp,%ebp
801096b0:	53                   	push   %ebx
801096b1:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801096b4:	8b 45 08             	mov    0x8(%ebp),%eax
801096b7:	83 c0 03             	add    $0x3,%eax
801096ba:	0f b6 00             	movzbl (%eax),%eax
801096bd:	0f b6 d8             	movzbl %al,%ebx
801096c0:	8b 45 08             	mov    0x8(%ebp),%eax
801096c3:	83 c0 02             	add    $0x2,%eax
801096c6:	0f b6 00             	movzbl (%eax),%eax
801096c9:	0f b6 c8             	movzbl %al,%ecx
801096cc:	8b 45 08             	mov    0x8(%ebp),%eax
801096cf:	83 c0 01             	add    $0x1,%eax
801096d2:	0f b6 00             	movzbl (%eax),%eax
801096d5:	0f b6 d0             	movzbl %al,%edx
801096d8:	8b 45 08             	mov    0x8(%ebp),%eax
801096db:	0f b6 00             	movzbl (%eax),%eax
801096de:	0f b6 c0             	movzbl %al,%eax
801096e1:	83 ec 0c             	sub    $0xc,%esp
801096e4:	53                   	push   %ebx
801096e5:	51                   	push   %ecx
801096e6:	52                   	push   %edx
801096e7:	50                   	push   %eax
801096e8:	68 ec c2 10 80       	push   $0x8010c2ec
801096ed:	e8 02 6d ff ff       	call   801003f4 <cprintf>
801096f2:	83 c4 20             	add    $0x20,%esp
}
801096f5:	90                   	nop
801096f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801096f9:	c9                   	leave  
801096fa:	c3                   	ret    

801096fb <print_mac>:

void print_mac(uchar *mac){
801096fb:	55                   	push   %ebp
801096fc:	89 e5                	mov    %esp,%ebp
801096fe:	57                   	push   %edi
801096ff:	56                   	push   %esi
80109700:	53                   	push   %ebx
80109701:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109704:	8b 45 08             	mov    0x8(%ebp),%eax
80109707:	83 c0 05             	add    $0x5,%eax
8010970a:	0f b6 00             	movzbl (%eax),%eax
8010970d:	0f b6 f8             	movzbl %al,%edi
80109710:	8b 45 08             	mov    0x8(%ebp),%eax
80109713:	83 c0 04             	add    $0x4,%eax
80109716:	0f b6 00             	movzbl (%eax),%eax
80109719:	0f b6 f0             	movzbl %al,%esi
8010971c:	8b 45 08             	mov    0x8(%ebp),%eax
8010971f:	83 c0 03             	add    $0x3,%eax
80109722:	0f b6 00             	movzbl (%eax),%eax
80109725:	0f b6 d8             	movzbl %al,%ebx
80109728:	8b 45 08             	mov    0x8(%ebp),%eax
8010972b:	83 c0 02             	add    $0x2,%eax
8010972e:	0f b6 00             	movzbl (%eax),%eax
80109731:	0f b6 c8             	movzbl %al,%ecx
80109734:	8b 45 08             	mov    0x8(%ebp),%eax
80109737:	83 c0 01             	add    $0x1,%eax
8010973a:	0f b6 00             	movzbl (%eax),%eax
8010973d:	0f b6 d0             	movzbl %al,%edx
80109740:	8b 45 08             	mov    0x8(%ebp),%eax
80109743:	0f b6 00             	movzbl (%eax),%eax
80109746:	0f b6 c0             	movzbl %al,%eax
80109749:	83 ec 04             	sub    $0x4,%esp
8010974c:	57                   	push   %edi
8010974d:	56                   	push   %esi
8010974e:	53                   	push   %ebx
8010974f:	51                   	push   %ecx
80109750:	52                   	push   %edx
80109751:	50                   	push   %eax
80109752:	68 04 c3 10 80       	push   $0x8010c304
80109757:	e8 98 6c ff ff       	call   801003f4 <cprintf>
8010975c:	83 c4 20             	add    $0x20,%esp
}
8010975f:	90                   	nop
80109760:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109763:	5b                   	pop    %ebx
80109764:	5e                   	pop    %esi
80109765:	5f                   	pop    %edi
80109766:	5d                   	pop    %ebp
80109767:	c3                   	ret    

80109768 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109768:	55                   	push   %ebp
80109769:	89 e5                	mov    %esp,%ebp
8010976b:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010976e:	8b 45 08             	mov    0x8(%ebp),%eax
80109771:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109774:	8b 45 08             	mov    0x8(%ebp),%eax
80109777:	83 c0 0e             	add    $0xe,%eax
8010977a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010977d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109780:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109784:	3c 08                	cmp    $0x8,%al
80109786:	75 1b                	jne    801097a3 <eth_proc+0x3b>
80109788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010978b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010978f:	3c 06                	cmp    $0x6,%al
80109791:	75 10                	jne    801097a3 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109793:	83 ec 0c             	sub    $0xc,%esp
80109796:	ff 75 f0             	push   -0x10(%ebp)
80109799:	e8 01 f8 ff ff       	call   80108f9f <arp_proc>
8010979e:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801097a1:	eb 24                	jmp    801097c7 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801097a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a6:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801097aa:	3c 08                	cmp    $0x8,%al
801097ac:	75 19                	jne    801097c7 <eth_proc+0x5f>
801097ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b1:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801097b5:	84 c0                	test   %al,%al
801097b7:	75 0e                	jne    801097c7 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801097b9:	83 ec 0c             	sub    $0xc,%esp
801097bc:	ff 75 08             	push   0x8(%ebp)
801097bf:	e8 a3 00 00 00       	call   80109867 <ipv4_proc>
801097c4:	83 c4 10             	add    $0x10,%esp
}
801097c7:	90                   	nop
801097c8:	c9                   	leave  
801097c9:	c3                   	ret    

801097ca <N2H_ushort>:

ushort N2H_ushort(ushort value){
801097ca:	55                   	push   %ebp
801097cb:	89 e5                	mov    %esp,%ebp
801097cd:	83 ec 04             	sub    $0x4,%esp
801097d0:	8b 45 08             	mov    0x8(%ebp),%eax
801097d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801097d7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801097db:	c1 e0 08             	shl    $0x8,%eax
801097de:	89 c2                	mov    %eax,%edx
801097e0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801097e4:	66 c1 e8 08          	shr    $0x8,%ax
801097e8:	01 d0                	add    %edx,%eax
}
801097ea:	c9                   	leave  
801097eb:	c3                   	ret    

801097ec <H2N_ushort>:

ushort H2N_ushort(ushort value){
801097ec:	55                   	push   %ebp
801097ed:	89 e5                	mov    %esp,%ebp
801097ef:	83 ec 04             	sub    $0x4,%esp
801097f2:	8b 45 08             	mov    0x8(%ebp),%eax
801097f5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801097f9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801097fd:	c1 e0 08             	shl    $0x8,%eax
80109800:	89 c2                	mov    %eax,%edx
80109802:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109806:	66 c1 e8 08          	shr    $0x8,%ax
8010980a:	01 d0                	add    %edx,%eax
}
8010980c:	c9                   	leave  
8010980d:	c3                   	ret    

8010980e <H2N_uint>:

uint H2N_uint(uint value){
8010980e:	55                   	push   %ebp
8010980f:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109811:	8b 45 08             	mov    0x8(%ebp),%eax
80109814:	c1 e0 18             	shl    $0x18,%eax
80109817:	25 00 00 00 0f       	and    $0xf000000,%eax
8010981c:	89 c2                	mov    %eax,%edx
8010981e:	8b 45 08             	mov    0x8(%ebp),%eax
80109821:	c1 e0 08             	shl    $0x8,%eax
80109824:	25 00 f0 00 00       	and    $0xf000,%eax
80109829:	09 c2                	or     %eax,%edx
8010982b:	8b 45 08             	mov    0x8(%ebp),%eax
8010982e:	c1 e8 08             	shr    $0x8,%eax
80109831:	83 e0 0f             	and    $0xf,%eax
80109834:	01 d0                	add    %edx,%eax
}
80109836:	5d                   	pop    %ebp
80109837:	c3                   	ret    

80109838 <N2H_uint>:

uint N2H_uint(uint value){
80109838:	55                   	push   %ebp
80109839:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010983b:	8b 45 08             	mov    0x8(%ebp),%eax
8010983e:	c1 e0 18             	shl    $0x18,%eax
80109841:	89 c2                	mov    %eax,%edx
80109843:	8b 45 08             	mov    0x8(%ebp),%eax
80109846:	c1 e0 08             	shl    $0x8,%eax
80109849:	25 00 00 ff 00       	and    $0xff0000,%eax
8010984e:	01 c2                	add    %eax,%edx
80109850:	8b 45 08             	mov    0x8(%ebp),%eax
80109853:	c1 e8 08             	shr    $0x8,%eax
80109856:	25 00 ff 00 00       	and    $0xff00,%eax
8010985b:	01 c2                	add    %eax,%edx
8010985d:	8b 45 08             	mov    0x8(%ebp),%eax
80109860:	c1 e8 18             	shr    $0x18,%eax
80109863:	01 d0                	add    %edx,%eax
}
80109865:	5d                   	pop    %ebp
80109866:	c3                   	ret    

80109867 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109867:	55                   	push   %ebp
80109868:	89 e5                	mov    %esp,%ebp
8010986a:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010986d:	8b 45 08             	mov    0x8(%ebp),%eax
80109870:	83 c0 0e             	add    $0xe,%eax
80109873:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109879:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010987d:	0f b7 d0             	movzwl %ax,%edx
80109880:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109885:	39 c2                	cmp    %eax,%edx
80109887:	74 60                	je     801098e9 <ipv4_proc+0x82>
80109889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010988c:	83 c0 0c             	add    $0xc,%eax
8010988f:	83 ec 04             	sub    $0x4,%esp
80109892:	6a 04                	push   $0x4
80109894:	50                   	push   %eax
80109895:	68 e4 f4 10 80       	push   $0x8010f4e4
8010989a:	e8 46 b3 ff ff       	call   80104be5 <memcmp>
8010989f:	83 c4 10             	add    $0x10,%esp
801098a2:	85 c0                	test   %eax,%eax
801098a4:	74 43                	je     801098e9 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801098a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098a9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801098ad:	0f b7 c0             	movzwl %ax,%eax
801098b0:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801098b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b8:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801098bc:	3c 01                	cmp    $0x1,%al
801098be:	75 10                	jne    801098d0 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801098c0:	83 ec 0c             	sub    $0xc,%esp
801098c3:	ff 75 08             	push   0x8(%ebp)
801098c6:	e8 a3 00 00 00       	call   8010996e <icmp_proc>
801098cb:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801098ce:	eb 19                	jmp    801098e9 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801098d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801098d7:	3c 06                	cmp    $0x6,%al
801098d9:	75 0e                	jne    801098e9 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801098db:	83 ec 0c             	sub    $0xc,%esp
801098de:	ff 75 08             	push   0x8(%ebp)
801098e1:	e8 b3 03 00 00       	call   80109c99 <tcp_proc>
801098e6:	83 c4 10             	add    $0x10,%esp
}
801098e9:	90                   	nop
801098ea:	c9                   	leave  
801098eb:	c3                   	ret    

801098ec <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801098ec:	55                   	push   %ebp
801098ed:	89 e5                	mov    %esp,%ebp
801098ef:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801098f2:	8b 45 08             	mov    0x8(%ebp),%eax
801098f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801098f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098fb:	0f b6 00             	movzbl (%eax),%eax
801098fe:	83 e0 0f             	and    $0xf,%eax
80109901:	01 c0                	add    %eax,%eax
80109903:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109906:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010990d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109914:	eb 48                	jmp    8010995e <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109916:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109919:	01 c0                	add    %eax,%eax
8010991b:	89 c2                	mov    %eax,%edx
8010991d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109920:	01 d0                	add    %edx,%eax
80109922:	0f b6 00             	movzbl (%eax),%eax
80109925:	0f b6 c0             	movzbl %al,%eax
80109928:	c1 e0 08             	shl    $0x8,%eax
8010992b:	89 c2                	mov    %eax,%edx
8010992d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109930:	01 c0                	add    %eax,%eax
80109932:	8d 48 01             	lea    0x1(%eax),%ecx
80109935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109938:	01 c8                	add    %ecx,%eax
8010993a:	0f b6 00             	movzbl (%eax),%eax
8010993d:	0f b6 c0             	movzbl %al,%eax
80109940:	01 d0                	add    %edx,%eax
80109942:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109945:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010994c:	76 0c                	jbe    8010995a <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010994e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109951:	0f b7 c0             	movzwl %ax,%eax
80109954:	83 c0 01             	add    $0x1,%eax
80109957:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010995a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010995e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109962:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109965:	7c af                	jl     80109916 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109967:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010996a:	f7 d0                	not    %eax
}
8010996c:	c9                   	leave  
8010996d:	c3                   	ret    

8010996e <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010996e:	55                   	push   %ebp
8010996f:	89 e5                	mov    %esp,%ebp
80109971:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109974:	8b 45 08             	mov    0x8(%ebp),%eax
80109977:	83 c0 0e             	add    $0xe,%eax
8010997a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010997d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109980:	0f b6 00             	movzbl (%eax),%eax
80109983:	0f b6 c0             	movzbl %al,%eax
80109986:	83 e0 0f             	and    $0xf,%eax
80109989:	c1 e0 02             	shl    $0x2,%eax
8010998c:	89 c2                	mov    %eax,%edx
8010998e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109991:	01 d0                	add    %edx,%eax
80109993:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109999:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010999d:	84 c0                	test   %al,%al
8010999f:	75 4f                	jne    801099f0 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801099a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099a4:	0f b6 00             	movzbl (%eax),%eax
801099a7:	3c 08                	cmp    $0x8,%al
801099a9:	75 45                	jne    801099f0 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801099ab:	e8 f0 8d ff ff       	call   801027a0 <kalloc>
801099b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801099b3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801099ba:	83 ec 04             	sub    $0x4,%esp
801099bd:	8d 45 e8             	lea    -0x18(%ebp),%eax
801099c0:	50                   	push   %eax
801099c1:	ff 75 ec             	push   -0x14(%ebp)
801099c4:	ff 75 08             	push   0x8(%ebp)
801099c7:	e8 78 00 00 00       	call   80109a44 <icmp_reply_pkt_create>
801099cc:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801099cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099d2:	83 ec 08             	sub    $0x8,%esp
801099d5:	50                   	push   %eax
801099d6:	ff 75 ec             	push   -0x14(%ebp)
801099d9:	e8 95 f4 ff ff       	call   80108e73 <i8254_send>
801099de:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
801099e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099e4:	83 ec 0c             	sub    $0xc,%esp
801099e7:	50                   	push   %eax
801099e8:	e8 19 8d ff ff       	call   80102706 <kfree>
801099ed:	83 c4 10             	add    $0x10,%esp
    }
  }
}
801099f0:	90                   	nop
801099f1:	c9                   	leave  
801099f2:	c3                   	ret    

801099f3 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
801099f3:	55                   	push   %ebp
801099f4:	89 e5                	mov    %esp,%ebp
801099f6:	53                   	push   %ebx
801099f7:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
801099fa:	8b 45 08             	mov    0x8(%ebp),%eax
801099fd:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a01:	0f b7 c0             	movzwl %ax,%eax
80109a04:	83 ec 0c             	sub    $0xc,%esp
80109a07:	50                   	push   %eax
80109a08:	e8 bd fd ff ff       	call   801097ca <N2H_ushort>
80109a0d:	83 c4 10             	add    $0x10,%esp
80109a10:	0f b7 d8             	movzwl %ax,%ebx
80109a13:	8b 45 08             	mov    0x8(%ebp),%eax
80109a16:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109a1a:	0f b7 c0             	movzwl %ax,%eax
80109a1d:	83 ec 0c             	sub    $0xc,%esp
80109a20:	50                   	push   %eax
80109a21:	e8 a4 fd ff ff       	call   801097ca <N2H_ushort>
80109a26:	83 c4 10             	add    $0x10,%esp
80109a29:	0f b7 c0             	movzwl %ax,%eax
80109a2c:	83 ec 04             	sub    $0x4,%esp
80109a2f:	53                   	push   %ebx
80109a30:	50                   	push   %eax
80109a31:	68 23 c3 10 80       	push   $0x8010c323
80109a36:	e8 b9 69 ff ff       	call   801003f4 <cprintf>
80109a3b:	83 c4 10             	add    $0x10,%esp
}
80109a3e:	90                   	nop
80109a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a42:	c9                   	leave  
80109a43:	c3                   	ret    

80109a44 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109a44:	55                   	push   %ebp
80109a45:	89 e5                	mov    %esp,%ebp
80109a47:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80109a4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109a50:	8b 45 08             	mov    0x8(%ebp),%eax
80109a53:	83 c0 0e             	add    $0xe,%eax
80109a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a5c:	0f b6 00             	movzbl (%eax),%eax
80109a5f:	0f b6 c0             	movzbl %al,%eax
80109a62:	83 e0 0f             	and    $0xf,%eax
80109a65:	c1 e0 02             	shl    $0x2,%eax
80109a68:	89 c2                	mov    %eax,%edx
80109a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a6d:	01 d0                	add    %edx,%eax
80109a6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109a72:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a75:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109a78:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a7b:	83 c0 0e             	add    $0xe,%eax
80109a7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109a81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a84:	83 c0 14             	add    $0x14,%eax
80109a87:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109a8a:	8b 45 10             	mov    0x10(%ebp),%eax
80109a8d:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a96:	8d 50 06             	lea    0x6(%eax),%edx
80109a99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a9c:	83 ec 04             	sub    $0x4,%esp
80109a9f:	6a 06                	push   $0x6
80109aa1:	52                   	push   %edx
80109aa2:	50                   	push   %eax
80109aa3:	e8 95 b1 ff ff       	call   80104c3d <memmove>
80109aa8:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109aab:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109aae:	83 c0 06             	add    $0x6,%eax
80109ab1:	83 ec 04             	sub    $0x4,%esp
80109ab4:	6a 06                	push   $0x6
80109ab6:	68 90 79 19 80       	push   $0x80197990
80109abb:	50                   	push   %eax
80109abc:	e8 7c b1 ff ff       	call   80104c3d <memmove>
80109ac1:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109ac4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ac7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109acb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ace:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109ad2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ad5:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109ad8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109adb:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109adf:	83 ec 0c             	sub    $0xc,%esp
80109ae2:	6a 54                	push   $0x54
80109ae4:	e8 03 fd ff ff       	call   801097ec <H2N_ushort>
80109ae9:	83 c4 10             	add    $0x10,%esp
80109aec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109aef:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109af3:	0f b7 15 60 7c 19 80 	movzwl 0x80197c60,%edx
80109afa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109afd:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109b01:	0f b7 05 60 7c 19 80 	movzwl 0x80197c60,%eax
80109b08:	83 c0 01             	add    $0x1,%eax
80109b0b:	66 a3 60 7c 19 80    	mov    %ax,0x80197c60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109b11:	83 ec 0c             	sub    $0xc,%esp
80109b14:	68 00 40 00 00       	push   $0x4000
80109b19:	e8 ce fc ff ff       	call   801097ec <H2N_ushort>
80109b1e:	83 c4 10             	add    $0x10,%esp
80109b21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b24:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109b28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b2b:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109b2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b32:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109b36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b39:	83 c0 0c             	add    $0xc,%eax
80109b3c:	83 ec 04             	sub    $0x4,%esp
80109b3f:	6a 04                	push   $0x4
80109b41:	68 e4 f4 10 80       	push   $0x8010f4e4
80109b46:	50                   	push   %eax
80109b47:	e8 f1 b0 ff ff       	call   80104c3d <memmove>
80109b4c:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b52:	8d 50 0c             	lea    0xc(%eax),%edx
80109b55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b58:	83 c0 10             	add    $0x10,%eax
80109b5b:	83 ec 04             	sub    $0x4,%esp
80109b5e:	6a 04                	push   $0x4
80109b60:	52                   	push   %edx
80109b61:	50                   	push   %eax
80109b62:	e8 d6 b0 ff ff       	call   80104c3d <memmove>
80109b67:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109b6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b6d:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109b73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b76:	83 ec 0c             	sub    $0xc,%esp
80109b79:	50                   	push   %eax
80109b7a:	e8 6d fd ff ff       	call   801098ec <ipv4_chksum>
80109b7f:	83 c4 10             	add    $0x10,%esp
80109b82:	0f b7 c0             	movzwl %ax,%eax
80109b85:	83 ec 0c             	sub    $0xc,%esp
80109b88:	50                   	push   %eax
80109b89:	e8 5e fc ff ff       	call   801097ec <H2N_ushort>
80109b8e:	83 c4 10             	add    $0x10,%esp
80109b91:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b94:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109b98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b9b:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109b9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ba1:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ba5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ba8:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109bac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109baf:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109bb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bb6:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109bba:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bbd:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109bc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bc4:	8d 50 08             	lea    0x8(%eax),%edx
80109bc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bca:	83 c0 08             	add    $0x8,%eax
80109bcd:	83 ec 04             	sub    $0x4,%esp
80109bd0:	6a 08                	push   $0x8
80109bd2:	52                   	push   %edx
80109bd3:	50                   	push   %eax
80109bd4:	e8 64 b0 ff ff       	call   80104c3d <memmove>
80109bd9:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109bdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bdf:	8d 50 10             	lea    0x10(%eax),%edx
80109be2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109be5:	83 c0 10             	add    $0x10,%eax
80109be8:	83 ec 04             	sub    $0x4,%esp
80109beb:	6a 30                	push   $0x30
80109bed:	52                   	push   %edx
80109bee:	50                   	push   %eax
80109bef:	e8 49 b0 ff ff       	call   80104c3d <memmove>
80109bf4:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109bf7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bfa:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109c00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c03:	83 ec 0c             	sub    $0xc,%esp
80109c06:	50                   	push   %eax
80109c07:	e8 1c 00 00 00       	call   80109c28 <icmp_chksum>
80109c0c:	83 c4 10             	add    $0x10,%esp
80109c0f:	0f b7 c0             	movzwl %ax,%eax
80109c12:	83 ec 0c             	sub    $0xc,%esp
80109c15:	50                   	push   %eax
80109c16:	e8 d1 fb ff ff       	call   801097ec <H2N_ushort>
80109c1b:	83 c4 10             	add    $0x10,%esp
80109c1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c21:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109c25:	90                   	nop
80109c26:	c9                   	leave  
80109c27:	c3                   	ret    

80109c28 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109c28:	55                   	push   %ebp
80109c29:	89 e5                	mov    %esp,%ebp
80109c2b:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80109c31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109c34:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109c3b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109c42:	eb 48                	jmp    80109c8c <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109c44:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c47:	01 c0                	add    %eax,%eax
80109c49:	89 c2                	mov    %eax,%edx
80109c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c4e:	01 d0                	add    %edx,%eax
80109c50:	0f b6 00             	movzbl (%eax),%eax
80109c53:	0f b6 c0             	movzbl %al,%eax
80109c56:	c1 e0 08             	shl    $0x8,%eax
80109c59:	89 c2                	mov    %eax,%edx
80109c5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c5e:	01 c0                	add    %eax,%eax
80109c60:	8d 48 01             	lea    0x1(%eax),%ecx
80109c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c66:	01 c8                	add    %ecx,%eax
80109c68:	0f b6 00             	movzbl (%eax),%eax
80109c6b:	0f b6 c0             	movzbl %al,%eax
80109c6e:	01 d0                	add    %edx,%eax
80109c70:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109c73:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109c7a:	76 0c                	jbe    80109c88 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109c7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c7f:	0f b7 c0             	movzwl %ax,%eax
80109c82:	83 c0 01             	add    $0x1,%eax
80109c85:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109c88:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109c8c:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109c90:	7e b2                	jle    80109c44 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109c92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c95:	f7 d0                	not    %eax
}
80109c97:	c9                   	leave  
80109c98:	c3                   	ret    

80109c99 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109c99:	55                   	push   %ebp
80109c9a:	89 e5                	mov    %esp,%ebp
80109c9c:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca2:	83 c0 0e             	add    $0xe,%eax
80109ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cab:	0f b6 00             	movzbl (%eax),%eax
80109cae:	0f b6 c0             	movzbl %al,%eax
80109cb1:	83 e0 0f             	and    $0xf,%eax
80109cb4:	c1 e0 02             	shl    $0x2,%eax
80109cb7:	89 c2                	mov    %eax,%edx
80109cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cbc:	01 d0                	add    %edx,%eax
80109cbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cc4:	83 c0 14             	add    $0x14,%eax
80109cc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109cca:	e8 d1 8a ff ff       	call   801027a0 <kalloc>
80109ccf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109cd2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cdc:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ce0:	0f b6 c0             	movzbl %al,%eax
80109ce3:	83 e0 02             	and    $0x2,%eax
80109ce6:	85 c0                	test   %eax,%eax
80109ce8:	74 3d                	je     80109d27 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109cea:	83 ec 0c             	sub    $0xc,%esp
80109ced:	6a 00                	push   $0x0
80109cef:	6a 12                	push   $0x12
80109cf1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109cf4:	50                   	push   %eax
80109cf5:	ff 75 e8             	push   -0x18(%ebp)
80109cf8:	ff 75 08             	push   0x8(%ebp)
80109cfb:	e8 a2 01 00 00       	call   80109ea2 <tcp_pkt_create>
80109d00:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109d03:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d06:	83 ec 08             	sub    $0x8,%esp
80109d09:	50                   	push   %eax
80109d0a:	ff 75 e8             	push   -0x18(%ebp)
80109d0d:	e8 61 f1 ff ff       	call   80108e73 <i8254_send>
80109d12:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109d15:	a1 64 7c 19 80       	mov    0x80197c64,%eax
80109d1a:	83 c0 01             	add    $0x1,%eax
80109d1d:	a3 64 7c 19 80       	mov    %eax,0x80197c64
80109d22:	e9 69 01 00 00       	jmp    80109e90 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d2a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d2e:	3c 18                	cmp    $0x18,%al
80109d30:	0f 85 10 01 00 00    	jne    80109e46 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109d36:	83 ec 04             	sub    $0x4,%esp
80109d39:	6a 03                	push   $0x3
80109d3b:	68 3e c3 10 80       	push   $0x8010c33e
80109d40:	ff 75 ec             	push   -0x14(%ebp)
80109d43:	e8 9d ae ff ff       	call   80104be5 <memcmp>
80109d48:	83 c4 10             	add    $0x10,%esp
80109d4b:	85 c0                	test   %eax,%eax
80109d4d:	74 74                	je     80109dc3 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109d4f:	83 ec 0c             	sub    $0xc,%esp
80109d52:	68 42 c3 10 80       	push   $0x8010c342
80109d57:	e8 98 66 ff ff       	call   801003f4 <cprintf>
80109d5c:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109d5f:	83 ec 0c             	sub    $0xc,%esp
80109d62:	6a 00                	push   $0x0
80109d64:	6a 10                	push   $0x10
80109d66:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d69:	50                   	push   %eax
80109d6a:	ff 75 e8             	push   -0x18(%ebp)
80109d6d:	ff 75 08             	push   0x8(%ebp)
80109d70:	e8 2d 01 00 00       	call   80109ea2 <tcp_pkt_create>
80109d75:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109d78:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d7b:	83 ec 08             	sub    $0x8,%esp
80109d7e:	50                   	push   %eax
80109d7f:	ff 75 e8             	push   -0x18(%ebp)
80109d82:	e8 ec f0 ff ff       	call   80108e73 <i8254_send>
80109d87:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109d8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d8d:	83 c0 36             	add    $0x36,%eax
80109d90:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109d93:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109d96:	50                   	push   %eax
80109d97:	ff 75 e0             	push   -0x20(%ebp)
80109d9a:	6a 00                	push   $0x0
80109d9c:	6a 00                	push   $0x0
80109d9e:	e8 5a 04 00 00       	call   8010a1fd <http_proc>
80109da3:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109da6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109da9:	83 ec 0c             	sub    $0xc,%esp
80109dac:	50                   	push   %eax
80109dad:	6a 18                	push   $0x18
80109daf:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109db2:	50                   	push   %eax
80109db3:	ff 75 e8             	push   -0x18(%ebp)
80109db6:	ff 75 08             	push   0x8(%ebp)
80109db9:	e8 e4 00 00 00       	call   80109ea2 <tcp_pkt_create>
80109dbe:	83 c4 20             	add    $0x20,%esp
80109dc1:	eb 62                	jmp    80109e25 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109dc3:	83 ec 0c             	sub    $0xc,%esp
80109dc6:	6a 00                	push   $0x0
80109dc8:	6a 10                	push   $0x10
80109dca:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109dcd:	50                   	push   %eax
80109dce:	ff 75 e8             	push   -0x18(%ebp)
80109dd1:	ff 75 08             	push   0x8(%ebp)
80109dd4:	e8 c9 00 00 00       	call   80109ea2 <tcp_pkt_create>
80109dd9:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109ddc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ddf:	83 ec 08             	sub    $0x8,%esp
80109de2:	50                   	push   %eax
80109de3:	ff 75 e8             	push   -0x18(%ebp)
80109de6:	e8 88 f0 ff ff       	call   80108e73 <i8254_send>
80109deb:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109dee:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109df1:	83 c0 36             	add    $0x36,%eax
80109df4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109df7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109dfa:	50                   	push   %eax
80109dfb:	ff 75 e4             	push   -0x1c(%ebp)
80109dfe:	6a 00                	push   $0x0
80109e00:	6a 00                	push   $0x0
80109e02:	e8 f6 03 00 00       	call   8010a1fd <http_proc>
80109e07:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109e0a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109e0d:	83 ec 0c             	sub    $0xc,%esp
80109e10:	50                   	push   %eax
80109e11:	6a 18                	push   $0x18
80109e13:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e16:	50                   	push   %eax
80109e17:	ff 75 e8             	push   -0x18(%ebp)
80109e1a:	ff 75 08             	push   0x8(%ebp)
80109e1d:	e8 80 00 00 00       	call   80109ea2 <tcp_pkt_create>
80109e22:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109e25:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e28:	83 ec 08             	sub    $0x8,%esp
80109e2b:	50                   	push   %eax
80109e2c:	ff 75 e8             	push   -0x18(%ebp)
80109e2f:	e8 3f f0 ff ff       	call   80108e73 <i8254_send>
80109e34:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109e37:	a1 64 7c 19 80       	mov    0x80197c64,%eax
80109e3c:	83 c0 01             	add    $0x1,%eax
80109e3f:	a3 64 7c 19 80       	mov    %eax,0x80197c64
80109e44:	eb 4a                	jmp    80109e90 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e49:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e4d:	3c 10                	cmp    $0x10,%al
80109e4f:	75 3f                	jne    80109e90 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109e51:	a1 68 7c 19 80       	mov    0x80197c68,%eax
80109e56:	83 f8 01             	cmp    $0x1,%eax
80109e59:	75 35                	jne    80109e90 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109e5b:	83 ec 0c             	sub    $0xc,%esp
80109e5e:	6a 00                	push   $0x0
80109e60:	6a 01                	push   $0x1
80109e62:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e65:	50                   	push   %eax
80109e66:	ff 75 e8             	push   -0x18(%ebp)
80109e69:	ff 75 08             	push   0x8(%ebp)
80109e6c:	e8 31 00 00 00       	call   80109ea2 <tcp_pkt_create>
80109e71:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e77:	83 ec 08             	sub    $0x8,%esp
80109e7a:	50                   	push   %eax
80109e7b:	ff 75 e8             	push   -0x18(%ebp)
80109e7e:	e8 f0 ef ff ff       	call   80108e73 <i8254_send>
80109e83:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109e86:	c7 05 68 7c 19 80 00 	movl   $0x0,0x80197c68
80109e8d:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109e90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e93:	83 ec 0c             	sub    $0xc,%esp
80109e96:	50                   	push   %eax
80109e97:	e8 6a 88 ff ff       	call   80102706 <kfree>
80109e9c:	83 c4 10             	add    $0x10,%esp
}
80109e9f:	90                   	nop
80109ea0:	c9                   	leave  
80109ea1:	c3                   	ret    

80109ea2 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109ea2:	55                   	push   %ebp
80109ea3:	89 e5                	mov    %esp,%ebp
80109ea5:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80109eab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109eae:	8b 45 08             	mov    0x8(%ebp),%eax
80109eb1:	83 c0 0e             	add    $0xe,%eax
80109eb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eba:	0f b6 00             	movzbl (%eax),%eax
80109ebd:	0f b6 c0             	movzbl %al,%eax
80109ec0:	83 e0 0f             	and    $0xf,%eax
80109ec3:	c1 e0 02             	shl    $0x2,%eax
80109ec6:	89 c2                	mov    %eax,%edx
80109ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ecb:	01 d0                	add    %edx,%eax
80109ecd:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ed3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ed9:	83 c0 0e             	add    $0xe,%eax
80109edc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ee2:	83 c0 14             	add    $0x14,%eax
80109ee5:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109ee8:	8b 45 18             	mov    0x18(%ebp),%eax
80109eeb:	8d 50 36             	lea    0x36(%eax),%edx
80109eee:	8b 45 10             	mov    0x10(%ebp),%eax
80109ef1:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ef6:	8d 50 06             	lea    0x6(%eax),%edx
80109ef9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109efc:	83 ec 04             	sub    $0x4,%esp
80109eff:	6a 06                	push   $0x6
80109f01:	52                   	push   %edx
80109f02:	50                   	push   %eax
80109f03:	e8 35 ad ff ff       	call   80104c3d <memmove>
80109f08:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109f0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f0e:	83 c0 06             	add    $0x6,%eax
80109f11:	83 ec 04             	sub    $0x4,%esp
80109f14:	6a 06                	push   $0x6
80109f16:	68 90 79 19 80       	push   $0x80197990
80109f1b:	50                   	push   %eax
80109f1c:	e8 1c ad ff ff       	call   80104c3d <memmove>
80109f21:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109f24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f27:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109f2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f2e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109f32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f35:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109f38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f3b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109f3f:	8b 45 18             	mov    0x18(%ebp),%eax
80109f42:	83 c0 28             	add    $0x28,%eax
80109f45:	0f b7 c0             	movzwl %ax,%eax
80109f48:	83 ec 0c             	sub    $0xc,%esp
80109f4b:	50                   	push   %eax
80109f4c:	e8 9b f8 ff ff       	call   801097ec <H2N_ushort>
80109f51:	83 c4 10             	add    $0x10,%esp
80109f54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f57:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109f5b:	0f b7 15 60 7c 19 80 	movzwl 0x80197c60,%edx
80109f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f65:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109f69:	0f b7 05 60 7c 19 80 	movzwl 0x80197c60,%eax
80109f70:	83 c0 01             	add    $0x1,%eax
80109f73:	66 a3 60 7c 19 80    	mov    %ax,0x80197c60
  ipv4_send->fragment = H2N_ushort(0x0000);
80109f79:	83 ec 0c             	sub    $0xc,%esp
80109f7c:	6a 00                	push   $0x0
80109f7e:	e8 69 f8 ff ff       	call   801097ec <H2N_ushort>
80109f83:	83 c4 10             	add    $0x10,%esp
80109f86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f89:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109f8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f90:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109f94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f97:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109f9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f9e:	83 c0 0c             	add    $0xc,%eax
80109fa1:	83 ec 04             	sub    $0x4,%esp
80109fa4:	6a 04                	push   $0x4
80109fa6:	68 e4 f4 10 80       	push   $0x8010f4e4
80109fab:	50                   	push   %eax
80109fac:	e8 8c ac ff ff       	call   80104c3d <memmove>
80109fb1:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fb7:	8d 50 0c             	lea    0xc(%eax),%edx
80109fba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fbd:	83 c0 10             	add    $0x10,%eax
80109fc0:	83 ec 04             	sub    $0x4,%esp
80109fc3:	6a 04                	push   $0x4
80109fc5:	52                   	push   %edx
80109fc6:	50                   	push   %eax
80109fc7:	e8 71 ac ff ff       	call   80104c3d <memmove>
80109fcc:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109fcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fd2:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fdb:	83 ec 0c             	sub    $0xc,%esp
80109fde:	50                   	push   %eax
80109fdf:	e8 08 f9 ff ff       	call   801098ec <ipv4_chksum>
80109fe4:	83 c4 10             	add    $0x10,%esp
80109fe7:	0f b7 c0             	movzwl %ax,%eax
80109fea:	83 ec 0c             	sub    $0xc,%esp
80109fed:	50                   	push   %eax
80109fee:	e8 f9 f7 ff ff       	call   801097ec <H2N_ushort>
80109ff3:	83 c4 10             	add    $0x10,%esp
80109ff6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ff9:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a000:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a004:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a007:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a00a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a00d:	0f b7 10             	movzwl (%eax),%edx
8010a010:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a013:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a017:	a1 64 7c 19 80       	mov    0x80197c64,%eax
8010a01c:	83 ec 0c             	sub    $0xc,%esp
8010a01f:	50                   	push   %eax
8010a020:	e8 e9 f7 ff ff       	call   8010980e <H2N_uint>
8010a025:	83 c4 10             	add    $0x10,%esp
8010a028:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a02b:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a02e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a031:	8b 40 04             	mov    0x4(%eax),%eax
8010a034:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a03a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a03d:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a040:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a043:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a047:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a04a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a04e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a051:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a055:	8b 45 14             	mov    0x14(%ebp),%eax
8010a058:	89 c2                	mov    %eax,%edx
8010a05a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a05d:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a060:	83 ec 0c             	sub    $0xc,%esp
8010a063:	68 90 38 00 00       	push   $0x3890
8010a068:	e8 7f f7 ff ff       	call   801097ec <H2N_ushort>
8010a06d:	83 c4 10             	add    $0x10,%esp
8010a070:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a073:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a077:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a07a:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a080:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a083:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a089:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a08c:	83 ec 0c             	sub    $0xc,%esp
8010a08f:	50                   	push   %eax
8010a090:	e8 1f 00 00 00       	call   8010a0b4 <tcp_chksum>
8010a095:	83 c4 10             	add    $0x10,%esp
8010a098:	83 c0 08             	add    $0x8,%eax
8010a09b:	0f b7 c0             	movzwl %ax,%eax
8010a09e:	83 ec 0c             	sub    $0xc,%esp
8010a0a1:	50                   	push   %eax
8010a0a2:	e8 45 f7 ff ff       	call   801097ec <H2N_ushort>
8010a0a7:	83 c4 10             	add    $0x10,%esp
8010a0aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a0ad:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a0b1:	90                   	nop
8010a0b2:	c9                   	leave  
8010a0b3:	c3                   	ret    

8010a0b4 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a0b4:	55                   	push   %ebp
8010a0b5:	89 e5                	mov    %esp,%ebp
8010a0b7:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a0ba:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a0c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0c3:	83 c0 14             	add    $0x14,%eax
8010a0c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a0c9:	83 ec 04             	sub    $0x4,%esp
8010a0cc:	6a 04                	push   $0x4
8010a0ce:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a0d3:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a0d6:	50                   	push   %eax
8010a0d7:	e8 61 ab ff ff       	call   80104c3d <memmove>
8010a0dc:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a0df:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0e2:	83 c0 0c             	add    $0xc,%eax
8010a0e5:	83 ec 04             	sub    $0x4,%esp
8010a0e8:	6a 04                	push   $0x4
8010a0ea:	50                   	push   %eax
8010a0eb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a0ee:	83 c0 04             	add    $0x4,%eax
8010a0f1:	50                   	push   %eax
8010a0f2:	e8 46 ab ff ff       	call   80104c3d <memmove>
8010a0f7:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a0fa:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a0fe:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a102:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a105:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a109:	0f b7 c0             	movzwl %ax,%eax
8010a10c:	83 ec 0c             	sub    $0xc,%esp
8010a10f:	50                   	push   %eax
8010a110:	e8 b5 f6 ff ff       	call   801097ca <N2H_ushort>
8010a115:	83 c4 10             	add    $0x10,%esp
8010a118:	83 e8 14             	sub    $0x14,%eax
8010a11b:	0f b7 c0             	movzwl %ax,%eax
8010a11e:	83 ec 0c             	sub    $0xc,%esp
8010a121:	50                   	push   %eax
8010a122:	e8 c5 f6 ff ff       	call   801097ec <H2N_ushort>
8010a127:	83 c4 10             	add    $0x10,%esp
8010a12a:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a12e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a135:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a138:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a13b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a142:	eb 33                	jmp    8010a177 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a144:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a147:	01 c0                	add    %eax,%eax
8010a149:	89 c2                	mov    %eax,%edx
8010a14b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a14e:	01 d0                	add    %edx,%eax
8010a150:	0f b6 00             	movzbl (%eax),%eax
8010a153:	0f b6 c0             	movzbl %al,%eax
8010a156:	c1 e0 08             	shl    $0x8,%eax
8010a159:	89 c2                	mov    %eax,%edx
8010a15b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a15e:	01 c0                	add    %eax,%eax
8010a160:	8d 48 01             	lea    0x1(%eax),%ecx
8010a163:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a166:	01 c8                	add    %ecx,%eax
8010a168:	0f b6 00             	movzbl (%eax),%eax
8010a16b:	0f b6 c0             	movzbl %al,%eax
8010a16e:	01 d0                	add    %edx,%eax
8010a170:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a173:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a177:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a17b:	7e c7                	jle    8010a144 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a17d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a180:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a183:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a18a:	eb 33                	jmp    8010a1bf <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a18c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a18f:	01 c0                	add    %eax,%eax
8010a191:	89 c2                	mov    %eax,%edx
8010a193:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a196:	01 d0                	add    %edx,%eax
8010a198:	0f b6 00             	movzbl (%eax),%eax
8010a19b:	0f b6 c0             	movzbl %al,%eax
8010a19e:	c1 e0 08             	shl    $0x8,%eax
8010a1a1:	89 c2                	mov    %eax,%edx
8010a1a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1a6:	01 c0                	add    %eax,%eax
8010a1a8:	8d 48 01             	lea    0x1(%eax),%ecx
8010a1ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1ae:	01 c8                	add    %ecx,%eax
8010a1b0:	0f b6 00             	movzbl (%eax),%eax
8010a1b3:	0f b6 c0             	movzbl %al,%eax
8010a1b6:	01 d0                	add    %edx,%eax
8010a1b8:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a1bb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a1bf:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a1c3:	0f b7 c0             	movzwl %ax,%eax
8010a1c6:	83 ec 0c             	sub    $0xc,%esp
8010a1c9:	50                   	push   %eax
8010a1ca:	e8 fb f5 ff ff       	call   801097ca <N2H_ushort>
8010a1cf:	83 c4 10             	add    $0x10,%esp
8010a1d2:	66 d1 e8             	shr    %ax
8010a1d5:	0f b7 c0             	movzwl %ax,%eax
8010a1d8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a1db:	7c af                	jl     8010a18c <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a1dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1e0:	c1 e8 10             	shr    $0x10,%eax
8010a1e3:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a1e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1e9:	f7 d0                	not    %eax
}
8010a1eb:	c9                   	leave  
8010a1ec:	c3                   	ret    

8010a1ed <tcp_fin>:

void tcp_fin(){
8010a1ed:	55                   	push   %ebp
8010a1ee:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a1f0:	c7 05 68 7c 19 80 01 	movl   $0x1,0x80197c68
8010a1f7:	00 00 00 
}
8010a1fa:	90                   	nop
8010a1fb:	5d                   	pop    %ebp
8010a1fc:	c3                   	ret    

8010a1fd <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a1fd:	55                   	push   %ebp
8010a1fe:	89 e5                	mov    %esp,%ebp
8010a200:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a203:	8b 45 10             	mov    0x10(%ebp),%eax
8010a206:	83 ec 04             	sub    $0x4,%esp
8010a209:	6a 00                	push   $0x0
8010a20b:	68 4b c3 10 80       	push   $0x8010c34b
8010a210:	50                   	push   %eax
8010a211:	e8 65 00 00 00       	call   8010a27b <http_strcpy>
8010a216:	83 c4 10             	add    $0x10,%esp
8010a219:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a21c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a21f:	83 ec 04             	sub    $0x4,%esp
8010a222:	ff 75 f4             	push   -0xc(%ebp)
8010a225:	68 5e c3 10 80       	push   $0x8010c35e
8010a22a:	50                   	push   %eax
8010a22b:	e8 4b 00 00 00       	call   8010a27b <http_strcpy>
8010a230:	83 c4 10             	add    $0x10,%esp
8010a233:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a236:	8b 45 10             	mov    0x10(%ebp),%eax
8010a239:	83 ec 04             	sub    $0x4,%esp
8010a23c:	ff 75 f4             	push   -0xc(%ebp)
8010a23f:	68 79 c3 10 80       	push   $0x8010c379
8010a244:	50                   	push   %eax
8010a245:	e8 31 00 00 00       	call   8010a27b <http_strcpy>
8010a24a:	83 c4 10             	add    $0x10,%esp
8010a24d:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a250:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a253:	83 e0 01             	and    $0x1,%eax
8010a256:	85 c0                	test   %eax,%eax
8010a258:	74 11                	je     8010a26b <http_proc+0x6e>
    char *payload = (char *)send;
8010a25a:	8b 45 10             	mov    0x10(%ebp),%eax
8010a25d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a260:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a263:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a266:	01 d0                	add    %edx,%eax
8010a268:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a26b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a26e:	8b 45 14             	mov    0x14(%ebp),%eax
8010a271:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a273:	e8 75 ff ff ff       	call   8010a1ed <tcp_fin>
}
8010a278:	90                   	nop
8010a279:	c9                   	leave  
8010a27a:	c3                   	ret    

8010a27b <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a27b:	55                   	push   %ebp
8010a27c:	89 e5                	mov    %esp,%ebp
8010a27e:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a281:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a288:	eb 20                	jmp    8010a2aa <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a28a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a28d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a290:	01 d0                	add    %edx,%eax
8010a292:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a295:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a298:	01 ca                	add    %ecx,%edx
8010a29a:	89 d1                	mov    %edx,%ecx
8010a29c:	8b 55 08             	mov    0x8(%ebp),%edx
8010a29f:	01 ca                	add    %ecx,%edx
8010a2a1:	0f b6 00             	movzbl (%eax),%eax
8010a2a4:	88 02                	mov    %al,(%edx)
    i++;
8010a2a6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a2aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a2ad:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a2b0:	01 d0                	add    %edx,%eax
8010a2b2:	0f b6 00             	movzbl (%eax),%eax
8010a2b5:	84 c0                	test   %al,%al
8010a2b7:	75 d1                	jne    8010a28a <http_strcpy+0xf>
  }
  return i;
8010a2b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a2bc:	c9                   	leave  
8010a2bd:	c3                   	ret    

8010a2be <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a2be:	55                   	push   %ebp
8010a2bf:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a2c1:	c7 05 70 7c 19 80 a2 	movl   $0x8010f5a2,0x80197c70
8010a2c8:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a2cb:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a2d0:	c1 e8 09             	shr    $0x9,%eax
8010a2d3:	a3 6c 7c 19 80       	mov    %eax,0x80197c6c
}
8010a2d8:	90                   	nop
8010a2d9:	5d                   	pop    %ebp
8010a2da:	c3                   	ret    

8010a2db <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a2db:	55                   	push   %ebp
8010a2dc:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a2de:	90                   	nop
8010a2df:	5d                   	pop    %ebp
8010a2e0:	c3                   	ret    

8010a2e1 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a2e1:	55                   	push   %ebp
8010a2e2:	89 e5                	mov    %esp,%ebp
8010a2e4:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a2e7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ea:	83 c0 0c             	add    $0xc,%eax
8010a2ed:	83 ec 0c             	sub    $0xc,%esp
8010a2f0:	50                   	push   %eax
8010a2f1:	e8 81 a5 ff ff       	call   80104877 <holdingsleep>
8010a2f6:	83 c4 10             	add    $0x10,%esp
8010a2f9:	85 c0                	test   %eax,%eax
8010a2fb:	75 0d                	jne    8010a30a <iderw+0x29>
    panic("iderw: buf not locked");
8010a2fd:	83 ec 0c             	sub    $0xc,%esp
8010a300:	68 8a c3 10 80       	push   $0x8010c38a
8010a305:	e8 9f 62 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a30a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a30d:	8b 00                	mov    (%eax),%eax
8010a30f:	83 e0 06             	and    $0x6,%eax
8010a312:	83 f8 02             	cmp    $0x2,%eax
8010a315:	75 0d                	jne    8010a324 <iderw+0x43>
    panic("iderw: nothing to do");
8010a317:	83 ec 0c             	sub    $0xc,%esp
8010a31a:	68 a0 c3 10 80       	push   $0x8010c3a0
8010a31f:	e8 85 62 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a324:	8b 45 08             	mov    0x8(%ebp),%eax
8010a327:	8b 40 04             	mov    0x4(%eax),%eax
8010a32a:	83 f8 01             	cmp    $0x1,%eax
8010a32d:	74 0d                	je     8010a33c <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a32f:	83 ec 0c             	sub    $0xc,%esp
8010a332:	68 b5 c3 10 80       	push   $0x8010c3b5
8010a337:	e8 6d 62 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a33c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a33f:	8b 40 08             	mov    0x8(%eax),%eax
8010a342:	8b 15 6c 7c 19 80    	mov    0x80197c6c,%edx
8010a348:	39 d0                	cmp    %edx,%eax
8010a34a:	72 0d                	jb     8010a359 <iderw+0x78>
    panic("iderw: block out of range");
8010a34c:	83 ec 0c             	sub    $0xc,%esp
8010a34f:	68 d3 c3 10 80       	push   $0x8010c3d3
8010a354:	e8 50 62 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a359:	8b 15 70 7c 19 80    	mov    0x80197c70,%edx
8010a35f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a362:	8b 40 08             	mov    0x8(%eax),%eax
8010a365:	c1 e0 09             	shl    $0x9,%eax
8010a368:	01 d0                	add    %edx,%eax
8010a36a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a36d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a370:	8b 00                	mov    (%eax),%eax
8010a372:	83 e0 04             	and    $0x4,%eax
8010a375:	85 c0                	test   %eax,%eax
8010a377:	74 2b                	je     8010a3a4 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a379:	8b 45 08             	mov    0x8(%ebp),%eax
8010a37c:	8b 00                	mov    (%eax),%eax
8010a37e:	83 e0 fb             	and    $0xfffffffb,%eax
8010a381:	89 c2                	mov    %eax,%edx
8010a383:	8b 45 08             	mov    0x8(%ebp),%eax
8010a386:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a388:	8b 45 08             	mov    0x8(%ebp),%eax
8010a38b:	83 c0 5c             	add    $0x5c,%eax
8010a38e:	83 ec 04             	sub    $0x4,%esp
8010a391:	68 00 02 00 00       	push   $0x200
8010a396:	50                   	push   %eax
8010a397:	ff 75 f4             	push   -0xc(%ebp)
8010a39a:	e8 9e a8 ff ff       	call   80104c3d <memmove>
8010a39f:	83 c4 10             	add    $0x10,%esp
8010a3a2:	eb 1a                	jmp    8010a3be <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a3a4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3a7:	83 c0 5c             	add    $0x5c,%eax
8010a3aa:	83 ec 04             	sub    $0x4,%esp
8010a3ad:	68 00 02 00 00       	push   $0x200
8010a3b2:	ff 75 f4             	push   -0xc(%ebp)
8010a3b5:	50                   	push   %eax
8010a3b6:	e8 82 a8 ff ff       	call   80104c3d <memmove>
8010a3bb:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a3be:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3c1:	8b 00                	mov    (%eax),%eax
8010a3c3:	83 c8 02             	or     $0x2,%eax
8010a3c6:	89 c2                	mov    %eax,%edx
8010a3c8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3cb:	89 10                	mov    %edx,(%eax)
}
8010a3cd:	90                   	nop
8010a3ce:	c9                   	leave  
8010a3cf:	c3                   	ret    
