
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
8010005a:	bc 80 7f 19 80       	mov    $0x80197f80,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 66 33 10 80       	mov    $0x80103366,%edx
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
8010006f:	68 e0 a2 10 80       	push   $0x8010a2e0
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 bc 47 00 00       	call   8010483a <initlock>
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
801000bd:	68 e7 a2 10 80       	push   $0x8010a2e7
801000c2:	50                   	push   %eax
801000c3:	e8 15 46 00 00       	call   801046dd <initsleeplock>
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
80100101:	e8 56 47 00 00       	call   8010485c <acquire>
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
80100140:	e8 85 47 00 00       	call   801048ca <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 c2 45 00 00       	call   80104719 <acquiresleep>
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
801001c1:	e8 04 47 00 00       	call   801048ca <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 41 45 00 00       	call   80104719 <acquiresleep>
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
801001f5:	68 ee a2 10 80       	push   $0x8010a2ee
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
8010022d:	e8 a8 9f 00 00       	call   8010a1da <iderw>
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
8010024a:	e8 7c 45 00 00       	call   801047cb <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 ff a2 10 80       	push   $0x8010a2ff
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
80100278:	e8 5d 9f 00 00       	call   8010a1da <iderw>
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
80100293:	e8 33 45 00 00       	call   801047cb <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 06 a3 10 80       	push   $0x8010a306
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 c2 44 00 00       	call   8010477d <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 91 45 00 00       	call   8010485c <acquire>
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
80100336:	e8 8f 45 00 00       	call   801048ca <release>
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
80100410:	e8 47 44 00 00       	call   8010485c <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 0d a3 10 80       	push   $0x8010a30d
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
80100510:	c7 45 ec 16 a3 10 80 	movl   $0x8010a316,-0x14(%ebp)
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
8010059e:	e8 27 43 00 00       	call   801048ca <release>
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
801005be:	e8 38 25 00 00       	call   80102afb <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 1d a3 10 80       	push   $0x8010a31d
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
801005e6:	68 31 a3 10 80       	push   $0x8010a331
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 19 43 00 00       	call   8010491c <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 33 a3 10 80       	push   $0x8010a333
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
801006a0:	e8 8c 7a 00 00       	call   80108131 <graphic_scroll_up>
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
801006f3:	e8 39 7a 00 00       	call   80108131 <graphic_scroll_up>
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
80100757:	e8 40 7a 00 00       	call   8010819c <font_render>
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
80100793:	e8 24 5e 00 00       	call   801065bc <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 17 5e 00 00       	call   801065bc <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 0a 5e 00 00       	call   801065bc <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 fa 5d 00 00       	call   801065bc <uartputc>
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
801007eb:	e8 6c 40 00 00       	call   8010485c <acquire>
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
8010093f:	e8 92 3a 00 00       	call   801043d6 <wakeup>
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
80100962:	e8 63 3f 00 00       	call   801048ca <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 1c 3b 00 00       	call   80104491 <procdump>
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
80100984:	e8 75 11 00 00       	call   80101afe <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 bd 3e 00 00       	call   8010485c <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 85 30 00 00       	call   80103a31 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 0a 3f 00 00       	call   801048ca <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1d 10 00 00       	call   801019eb <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 02 39 00 00       	call   801042ef <sleep>
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
80100a66:	e8 5f 3e 00 00       	call   801048ca <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 72 0f 00 00       	call   801019eb <ilock>
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
80100a92:	e8 67 10 00 00       	call   80101afe <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 b5 3d 00 00       	call   8010485c <acquire>
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
80100ae4:	e8 e1 3d 00 00       	call   801048ca <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f4 0e 00 00       	call   801019eb <ilock>
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
80100b12:	68 37 a3 10 80       	push   $0x8010a337
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 19 3d 00 00       	call   8010483a <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 3f a3 10 80 	movl   $0x8010a33f,-0xc(%ebp)
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
80100b75:	e8 b5 1a 00 00       	call   8010262f <ioapicenable>
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
80100b83:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 a3 2e 00 00       	call   80103a31 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a7 24 00 00       	call   8010303d <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7d 19 00 00       	call   8010251e <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    //cprintf("[exec] fail: namei('%s') returned 0\n", path);
    end_op();
80100bad:	e8 17 25 00 00       	call   801030c9 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 58 a3 10 80       	push   $0x8010a358
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f2 03 00 00       	jmp    80100fbe <exec+0x43e>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 14 0e 00 00       	call   801019eb <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf)){
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e3 12 00 00       	call   80101ed7 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 6a 03 00 00    	jne    80100f6a <exec+0x3ea>
    //cprintf("[exec] fail: read ELF header\n");   
    goto bad;
  }  
  if(elf.magic != ELF_MAGIC){
80100c00:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 5c 03 00 00    	jne    80100f6d <exec+0x3ed>
    //cprintf("[exec] fail: bad ELF magic\n");
    goto bad;
  }  

  if((pgdir = setupkvm()) == 0){
80100c11:	e8 a2 69 00 00       	call   801075b8 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 4d 03 00 00    	je     80100f70 <exec+0x3f0>
  }  
  //cprintf("[exec] ELF entry for %s: 0x%x\n", path, elf.entry);
  // Load program into memory.
  //cprintf("[exec] checking entry mapping: VA 0x%x => KA 0x%x\n", elf.entry, (uint)uva2ka(pgdir, (char*)elf.entry));

  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e4 fe ff ff    	lea    -0x11c(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 83 12 00 00       	call   80101ed7 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 13 03 00 00    	jne    80100f73 <exec+0x3f3>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    //cprintf("[exec] PH[%d] vaddr=0x%x memsz=0x%x filesz=0x%x\n", i, ph.vaddr, ph.memsz, ph.filesz);

    if(ph.memsz < ph.filesz) {
80100c6f:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100c75:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 f3 02 00 00    	jb     80100f76 <exec+0x3f6>
      //cprintf("[exec] fail: memsz < filesz\n");
      goto bad;
    }
    if(ph.vaddr + ph.memsz < ph.vaddr) {
80100c83:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100c89:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 da 02 00 00    	jb     80100f79 <exec+0x3f9>
      //cprintf("[exec] fail: overflow in vaddr + memsz\n");
      goto bad;
    }
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0) {
80100c9f:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100ca5:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 f5 6c 00 00       	call   801079b1 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 b0 02 00 00    	je     80100f7c <exec+0x3fc>
      //cprintf("[exec] fail: allocuvm failed, target=0x%x\n", ph.vaddr + ph.memsz);
      goto bad;
    }
    if(ph.vaddr % PGSIZE != 0) {
80100ccc:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 a0 02 00 00    	jne    80100f7f <exec+0x3ff>
      //cprintf("[exec] fail: vaddr not aligned: 0x%x\n", ph.vaddr);
      goto bad;
    }
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0) 
80100cdf:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100ce5:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ceb:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 e2 6b 00 00       	call   801078e4 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 75 02 00 00    	js     80100f82 <exec+0x402>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 30 ff ff ff 	movzwl -0xd0(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      //cprintf("[exec] fail: loaduvm failed for ph[%d]\n", i);
      goto bad;
  }

  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e1 0e 00 00       	call   80101c1c <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 86 23 00 00       	call   801030c9 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  uint sz_program = sz;
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  sz = KERNBASE - 1;
80100d50:	c7 45 e0 ff ff ff 7f 	movl   $0x7fffffff,-0x20(%ebp)
  if ((sz = allocuvm(pgdir, sz-PGSIZE, sz)) == 0) {
80100d57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5a:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d5f:	83 ec 04             	sub    $0x4,%esp
80100d62:	ff 75 e0             	push   -0x20(%ebp)
80100d65:	50                   	push   %eax
80100d66:	ff 75 d4             	push   -0x2c(%ebp)
80100d69:	e8 43 6c 00 00       	call   801079b1 <allocuvm>
80100d6e:	83 c4 10             	add    $0x10,%esp
80100d71:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d74:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d78:	75 15                	jne    80100d8f <exec+0x20f>
    cprintf("[exec] fail: stack allocuvm failed\n");
80100d7a:	83 ec 0c             	sub    $0xc,%esp
80100d7d:	68 64 a3 10 80       	push   $0x8010a364
80100d82:	e8 6d f6 ff ff       	call   801003f4 <cprintf>
80100d87:	83 c4 10             	add    $0x10,%esp
    goto bad;
80100d8a:	e9 fd 01 00 00       	jmp    80100f8c <exec+0x40c>
  }
  sp = KERNBASE - 1;
80100d8f:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)



  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d96:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d9d:	e9 96 00 00 00       	jmp    80100e38 <exec+0x2b8>
    if(argc >= MAXARG)
80100da2:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100da6:	0f 87 d9 01 00 00    	ja     80100f85 <exec+0x405>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100daf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db9:	01 d0                	add    %edx,%eax
80100dbb:	8b 00                	mov    (%eax),%eax
80100dbd:	83 ec 0c             	sub    $0xc,%esp
80100dc0:	50                   	push   %eax
80100dc1:	e8 5a 3f 00 00       	call   80104d20 <strlen>
80100dc6:	83 c4 10             	add    $0x10,%esp
80100dc9:	89 c2                	mov    %eax,%edx
80100dcb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dce:	29 d0                	sub    %edx,%eax
80100dd0:	83 e8 01             	sub    $0x1,%eax
80100dd3:	83 e0 fc             	and    $0xfffffffc,%eax
80100dd6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0){
80100dd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de6:	01 d0                	add    %edx,%eax
80100de8:	8b 00                	mov    (%eax),%eax
80100dea:	83 ec 0c             	sub    $0xc,%esp
80100ded:	50                   	push   %eax
80100dee:	e8 2d 3f 00 00       	call   80104d20 <strlen>
80100df3:	83 c4 10             	add    $0x10,%esp
80100df6:	83 c0 01             	add    $0x1,%eax
80100df9:	89 c2                	mov    %eax,%edx
80100dfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfe:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e05:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e08:	01 c8                	add    %ecx,%eax
80100e0a:	8b 00                	mov    (%eax),%eax
80100e0c:	52                   	push   %edx
80100e0d:	50                   	push   %eax
80100e0e:	ff 75 dc             	push   -0x24(%ebp)
80100e11:	ff 75 d4             	push   -0x2c(%ebp)
80100e14:	e8 85 6f 00 00       	call   80107d9e <copyout>
80100e19:	83 c4 10             	add    $0x10,%esp
80100e1c:	85 c0                	test   %eax,%eax
80100e1e:	0f 88 64 01 00 00    	js     80100f88 <exec+0x408>
      //cprintf("[exec] about to copyout ustack: sp=0x%x size=%d\n", sp, (3+argc+1)*4);
      goto bad;
    }  
    ustack[3+argc] = sp;
80100e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e27:	8d 50 03             	lea    0x3(%eax),%edx
80100e2a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2d:	89 84 95 38 ff ff ff 	mov    %eax,-0xc8(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e34:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e42:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e45:	01 d0                	add    %edx,%eax
80100e47:	8b 00                	mov    (%eax),%eax
80100e49:	85 c0                	test   %eax,%eax
80100e4b:	0f 85 51 ff ff ff    	jne    80100da2 <exec+0x222>

  cprintf("[exec] argc = %d\n", argc);
  cprintf("[exec] argv pointer (ustack[2]) = 0x%x\n", ustack[2]);
  cprintf("[exec] stack top (sp) = 0x%x\n", sp); **/

  ustack[3+argc] = 0;
80100e51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e54:	83 c0 03             	add    $0x3,%eax
80100e57:	c7 84 85 38 ff ff ff 	movl   $0x0,-0xc8(%ebp,%eax,4)
80100e5e:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e62:	c7 85 38 ff ff ff ff 	movl   $0xffffffff,-0xc8(%ebp)
80100e69:	ff ff ff 
  ustack[1] = argc;
80100e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6f:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e78:	83 c0 01             	add    $0x1,%eax
80100e7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e82:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e85:	29 d0                	sub    %edx,%eax
80100e87:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)

  sp -= (3+argc+1) * 4;
80100e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e90:	83 c0 04             	add    $0x4,%eax
80100e93:	c1 e0 02             	shl    $0x2,%eax
80100e96:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0){
80100e99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9c:	83 c0 04             	add    $0x4,%eax
80100e9f:	c1 e0 02             	shl    $0x2,%eax
80100ea2:	50                   	push   %eax
80100ea3:	8d 85 38 ff ff ff    	lea    -0xc8(%ebp),%eax
80100ea9:	50                   	push   %eax
80100eaa:	ff 75 dc             	push   -0x24(%ebp)
80100ead:	ff 75 d4             	push   -0x2c(%ebp)
80100eb0:	e8 e9 6e 00 00       	call   80107d9e <copyout>
80100eb5:	83 c4 10             	add    $0x10,%esp
80100eb8:	85 c0                	test   %eax,%eax
80100eba:	0f 88 cb 00 00 00    	js     80100f8b <exec+0x40b>
    //cprintf("[exec] fail: copyout ustack failed\n");
    goto bad;
  }  

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80100ec3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ecc:	eb 17                	jmp    80100ee5 <exec+0x365>
    if(*s == '/')
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	0f b6 00             	movzbl (%eax),%eax
80100ed4:	3c 2f                	cmp    $0x2f,%al
80100ed6:	75 09                	jne    80100ee1 <exec+0x361>
      last = s+1;
80100ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edb:	83 c0 01             	add    $0x1,%eax
80100ede:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee8:	0f b6 00             	movzbl (%eax),%eax
80100eeb:	84 c0                	test   %al,%al
80100eed:	75 df                	jne    80100ece <exec+0x34e>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100eef:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ef2:	83 c0 6c             	add    $0x6c,%eax
80100ef5:	83 ec 04             	sub    $0x4,%esp
80100ef8:	6a 10                	push   $0x10
80100efa:	ff 75 f0             	push   -0x10(%ebp)
80100efd:	50                   	push   %eax
80100efe:	e8 d2 3d 00 00       	call   80104cd5 <safestrcpy>
80100f03:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f06:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f09:	8b 40 04             	mov    0x4(%eax),%eax
80100f0c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  curproc->pgdir = pgdir;
80100f0f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f12:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f15:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = PGROUNDUP(sz_program);
80100f18:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100f1b:	05 ff 0f 00 00       	add    $0xfff,%eax
80100f20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100f25:	89 c2                	mov    %eax,%edx
80100f27:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2a:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry; // main
80100f2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2f:	8b 40 18             	mov    0x18(%eax),%eax
80100f32:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80100f38:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3e:	8b 40 18             	mov    0x18(%eax),%eax
80100f41:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f44:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f47:	83 ec 0c             	sub    $0xc,%esp
80100f4a:	ff 75 d0             	push   -0x30(%ebp)
80100f4d:	e8 83 67 00 00       	call   801076d5 <switchuvm>
80100f52:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f55:	83 ec 0c             	sub    $0xc,%esp
80100f58:	ff 75 c8             	push   -0x38(%ebp)
80100f5b:	e8 1a 6c 00 00       	call   80107b7a <freevm>
80100f60:	83 c4 10             	add    $0x10,%esp

  //cprintf("[exec] success: sz=0x%x, sp=0x%x\n", sz, sp);
  //cprintf("[exec] tf after exec: eax=0x%x esp=0x%x eip=0x%x\n", curproc->tf->eax, curproc->tf->esp, curproc->tf->eip);

  return 0;
80100f63:	b8 00 00 00 00       	mov    $0x0,%eax
80100f68:	eb 54                	jmp    80100fbe <exec+0x43e>
    goto bad;
80100f6a:	90                   	nop
80100f6b:	eb 1f                	jmp    80100f8c <exec+0x40c>
    goto bad;
80100f6d:	90                   	nop
80100f6e:	eb 1c                	jmp    80100f8c <exec+0x40c>
    goto bad;
80100f70:	90                   	nop
80100f71:	eb 19                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f73:	90                   	nop
80100f74:	eb 16                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f76:	90                   	nop
80100f77:	eb 13                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 10                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 0d                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 0a                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 07                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f85:	90                   	nop
80100f86:	eb 04                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 01                	jmp    80100f8c <exec+0x40c>
    goto bad;
80100f8b:	90                   	nop

 bad:
  //cprintf("[exec] fail: reached bad label, sz=0x%x pid=%d\n", sz, curproc->pid);

  if(pgdir)
80100f8c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f90:	74 0e                	je     80100fa0 <exec+0x420>
    freevm(pgdir);
80100f92:	83 ec 0c             	sub    $0xc,%esp
80100f95:	ff 75 d4             	push   -0x2c(%ebp)
80100f98:	e8 dd 6b 00 00       	call   80107b7a <freevm>
80100f9d:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa4:	74 13                	je     80100fb9 <exec+0x439>
    //cprintf("[exec] fail: inside cleanup\n");
    iunlockput(ip);
80100fa6:	83 ec 0c             	sub    $0xc,%esp
80100fa9:	ff 75 d8             	push   -0x28(%ebp)
80100fac:	e8 6b 0c 00 00       	call   80101c1c <iunlockput>
80100fb1:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb4:	e8 10 21 00 00       	call   801030c9 <end_op>
  }
  return -1;
80100fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbe:	c9                   	leave  
80100fbf:	c3                   	ret    

80100fc0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc0:	55                   	push   %ebp
80100fc1:	89 e5                	mov    %esp,%ebp
80100fc3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc6:	83 ec 08             	sub    $0x8,%esp
80100fc9:	68 88 a3 10 80       	push   $0x8010a388
80100fce:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd3:	e8 62 38 00 00       	call   8010483a <initlock>
80100fd8:	83 c4 10             	add    $0x10,%esp
}
80100fdb:	90                   	nop
80100fdc:	c9                   	leave  
80100fdd:	c3                   	ret    

80100fde <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fde:	55                   	push   %ebp
80100fdf:	89 e5                	mov    %esp,%ebp
80100fe1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe4:	83 ec 0c             	sub    $0xc,%esp
80100fe7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fec:	e8 6b 38 00 00       	call   8010485c <acquire>
80100ff1:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff4:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ffb:	eb 2d                	jmp    8010102a <filealloc+0x4c>
    if(f->ref == 0){
80100ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101000:	8b 40 04             	mov    0x4(%eax),%eax
80101003:	85 c0                	test   %eax,%eax
80101005:	75 1f                	jne    80101026 <filealloc+0x48>
      f->ref = 1;
80101007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101011:	83 ec 0c             	sub    $0xc,%esp
80101014:	68 a0 1a 19 80       	push   $0x80191aa0
80101019:	e8 ac 38 00 00       	call   801048ca <release>
8010101e:	83 c4 10             	add    $0x10,%esp
      return f;
80101021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101024:	eb 23                	jmp    80101049 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101026:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010102a:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101032:	72 c9                	jb     80100ffd <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101034:	83 ec 0c             	sub    $0xc,%esp
80101037:	68 a0 1a 19 80       	push   $0x80191aa0
8010103c:	e8 89 38 00 00       	call   801048ca <release>
80101041:	83 c4 10             	add    $0x10,%esp
  return 0;
80101044:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101049:	c9                   	leave  
8010104a:	c3                   	ret    

8010104b <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104b:	55                   	push   %ebp
8010104c:	89 e5                	mov    %esp,%ebp
8010104e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101051:	83 ec 0c             	sub    $0xc,%esp
80101054:	68 a0 1a 19 80       	push   $0x80191aa0
80101059:	e8 fe 37 00 00       	call   8010485c <acquire>
8010105e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101061:	8b 45 08             	mov    0x8(%ebp),%eax
80101064:	8b 40 04             	mov    0x4(%eax),%eax
80101067:	85 c0                	test   %eax,%eax
80101069:	7f 0d                	jg     80101078 <filedup+0x2d>
    panic("filedup");
8010106b:	83 ec 0c             	sub    $0xc,%esp
8010106e:	68 8f a3 10 80       	push   $0x8010a38f
80101073:	e8 31 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101078:	8b 45 08             	mov    0x8(%ebp),%eax
8010107b:	8b 40 04             	mov    0x4(%eax),%eax
8010107e:	8d 50 01             	lea    0x1(%eax),%edx
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101087:	83 ec 0c             	sub    $0xc,%esp
8010108a:	68 a0 1a 19 80       	push   $0x80191aa0
8010108f:	e8 36 38 00 00       	call   801048ca <release>
80101094:	83 c4 10             	add    $0x10,%esp
  return f;
80101097:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010109a:	c9                   	leave  
8010109b:	c3                   	ret    

8010109c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109c:	55                   	push   %ebp
8010109d:	89 e5                	mov    %esp,%ebp
8010109f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a2:	83 ec 0c             	sub    $0xc,%esp
801010a5:	68 a0 1a 19 80       	push   $0x80191aa0
801010aa:	e8 ad 37 00 00       	call   8010485c <acquire>
801010af:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b2:	8b 45 08             	mov    0x8(%ebp),%eax
801010b5:	8b 40 04             	mov    0x4(%eax),%eax
801010b8:	85 c0                	test   %eax,%eax
801010ba:	7f 0d                	jg     801010c9 <fileclose+0x2d>
    panic("fileclose");
801010bc:	83 ec 0c             	sub    $0xc,%esp
801010bf:	68 97 a3 10 80       	push   $0x8010a397
801010c4:	e8 e0 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c9:	8b 45 08             	mov    0x8(%ebp),%eax
801010cc:	8b 40 04             	mov    0x4(%eax),%eax
801010cf:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	89 50 04             	mov    %edx,0x4(%eax)
801010d8:	8b 45 08             	mov    0x8(%ebp),%eax
801010db:	8b 40 04             	mov    0x4(%eax),%eax
801010de:	85 c0                	test   %eax,%eax
801010e0:	7e 15                	jle    801010f7 <fileclose+0x5b>
    release(&ftable.lock);
801010e2:	83 ec 0c             	sub    $0xc,%esp
801010e5:	68 a0 1a 19 80       	push   $0x80191aa0
801010ea:	e8 db 37 00 00       	call   801048ca <release>
801010ef:	83 c4 10             	add    $0x10,%esp
801010f2:	e9 8b 00 00 00       	jmp    80101182 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f7:	8b 45 08             	mov    0x8(%ebp),%eax
801010fa:	8b 10                	mov    (%eax),%edx
801010fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010ff:	8b 50 04             	mov    0x4(%eax),%edx
80101102:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101105:	8b 50 08             	mov    0x8(%eax),%edx
80101108:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110b:	8b 50 0c             	mov    0xc(%eax),%edx
8010110e:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101111:	8b 50 10             	mov    0x10(%eax),%edx
80101114:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101117:	8b 40 14             	mov    0x14(%eax),%eax
8010111a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111d:	8b 45 08             	mov    0x8(%ebp),%eax
80101120:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101127:	8b 45 08             	mov    0x8(%ebp),%eax
8010112a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101130:	83 ec 0c             	sub    $0xc,%esp
80101133:	68 a0 1a 19 80       	push   $0x80191aa0
80101138:	e8 8d 37 00 00       	call   801048ca <release>
8010113d:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101140:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101143:	83 f8 01             	cmp    $0x1,%eax
80101146:	75 19                	jne    80101161 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101148:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114c:	0f be d0             	movsbl %al,%edx
8010114f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101152:	83 ec 08             	sub    $0x8,%esp
80101155:	52                   	push   %edx
80101156:	50                   	push   %eax
80101157:	e8 64 25 00 00       	call   801036c0 <pipeclose>
8010115c:	83 c4 10             	add    $0x10,%esp
8010115f:	eb 21                	jmp    80101182 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101161:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101164:	83 f8 02             	cmp    $0x2,%eax
80101167:	75 19                	jne    80101182 <fileclose+0xe6>
    begin_op();
80101169:	e8 cf 1e 00 00       	call   8010303d <begin_op>
    iput(ff.ip);
8010116e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101171:	83 ec 0c             	sub    $0xc,%esp
80101174:	50                   	push   %eax
80101175:	e8 d2 09 00 00       	call   80101b4c <iput>
8010117a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117d:	e8 47 1f 00 00       	call   801030c9 <end_op>
  }
}
80101182:	c9                   	leave  
80101183:	c3                   	ret    

80101184 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101184:	55                   	push   %ebp
80101185:	89 e5                	mov    %esp,%ebp
80101187:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 00                	mov    (%eax),%eax
8010118f:	83 f8 02             	cmp    $0x2,%eax
80101192:	75 40                	jne    801011d4 <filestat+0x50>
    ilock(f->ip);
80101194:	8b 45 08             	mov    0x8(%ebp),%eax
80101197:	8b 40 10             	mov    0x10(%eax),%eax
8010119a:	83 ec 0c             	sub    $0xc,%esp
8010119d:	50                   	push   %eax
8010119e:	e8 48 08 00 00       	call   801019eb <ilock>
801011a3:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a6:	8b 45 08             	mov    0x8(%ebp),%eax
801011a9:	8b 40 10             	mov    0x10(%eax),%eax
801011ac:	83 ec 08             	sub    $0x8,%esp
801011af:	ff 75 0c             	push   0xc(%ebp)
801011b2:	50                   	push   %eax
801011b3:	e8 d9 0c 00 00       	call   80101e91 <stati>
801011b8:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011bb:	8b 45 08             	mov    0x8(%ebp),%eax
801011be:	8b 40 10             	mov    0x10(%eax),%eax
801011c1:	83 ec 0c             	sub    $0xc,%esp
801011c4:	50                   	push   %eax
801011c5:	e8 34 09 00 00       	call   80101afe <iunlock>
801011ca:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cd:	b8 00 00 00 00       	mov    $0x0,%eax
801011d2:	eb 05                	jmp    801011d9 <filestat+0x55>
  }
  return -1;
801011d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d9:	c9                   	leave  
801011da:	c3                   	ret    

801011db <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011db:	55                   	push   %ebp
801011dc:	89 e5                	mov    %esp,%ebp
801011de:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e8:	84 c0                	test   %al,%al
801011ea:	75 0a                	jne    801011f6 <fileread+0x1b>
    return -1;
801011ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f1:	e9 9b 00 00 00       	jmp    80101291 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 00                	mov    (%eax),%eax
801011fb:	83 f8 01             	cmp    $0x1,%eax
801011fe:	75 1a                	jne    8010121a <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101200:	8b 45 08             	mov    0x8(%ebp),%eax
80101203:	8b 40 0c             	mov    0xc(%eax),%eax
80101206:	83 ec 04             	sub    $0x4,%esp
80101209:	ff 75 10             	push   0x10(%ebp)
8010120c:	ff 75 0c             	push   0xc(%ebp)
8010120f:	50                   	push   %eax
80101210:	e8 58 26 00 00       	call   8010386d <piperead>
80101215:	83 c4 10             	add    $0x10,%esp
80101218:	eb 77                	jmp    80101291 <fileread+0xb6>
  if(f->type == FD_INODE){
8010121a:	8b 45 08             	mov    0x8(%ebp),%eax
8010121d:	8b 00                	mov    (%eax),%eax
8010121f:	83 f8 02             	cmp    $0x2,%eax
80101222:	75 60                	jne    80101284 <fileread+0xa9>
    ilock(f->ip);
80101224:	8b 45 08             	mov    0x8(%ebp),%eax
80101227:	8b 40 10             	mov    0x10(%eax),%eax
8010122a:	83 ec 0c             	sub    $0xc,%esp
8010122d:	50                   	push   %eax
8010122e:	e8 b8 07 00 00       	call   801019eb <ilock>
80101233:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101236:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101239:	8b 45 08             	mov    0x8(%ebp),%eax
8010123c:	8b 50 14             	mov    0x14(%eax),%edx
8010123f:	8b 45 08             	mov    0x8(%ebp),%eax
80101242:	8b 40 10             	mov    0x10(%eax),%eax
80101245:	51                   	push   %ecx
80101246:	52                   	push   %edx
80101247:	ff 75 0c             	push   0xc(%ebp)
8010124a:	50                   	push   %eax
8010124b:	e8 87 0c 00 00       	call   80101ed7 <readi>
80101250:	83 c4 10             	add    $0x10,%esp
80101253:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101256:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010125a:	7e 11                	jle    8010126d <fileread+0x92>
      f->off += r;
8010125c:	8b 45 08             	mov    0x8(%ebp),%eax
8010125f:	8b 50 14             	mov    0x14(%eax),%edx
80101262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101265:	01 c2                	add    %eax,%edx
80101267:	8b 45 08             	mov    0x8(%ebp),%eax
8010126a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126d:	8b 45 08             	mov    0x8(%ebp),%eax
80101270:	8b 40 10             	mov    0x10(%eax),%eax
80101273:	83 ec 0c             	sub    $0xc,%esp
80101276:	50                   	push   %eax
80101277:	e8 82 08 00 00       	call   80101afe <iunlock>
8010127c:	83 c4 10             	add    $0x10,%esp
    return r;
8010127f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101282:	eb 0d                	jmp    80101291 <fileread+0xb6>
  }
  panic("fileread");
80101284:	83 ec 0c             	sub    $0xc,%esp
80101287:	68 a1 a3 10 80       	push   $0x8010a3a1
8010128c:	e8 18 f3 ff ff       	call   801005a9 <panic>
}
80101291:	c9                   	leave  
80101292:	c3                   	ret    

80101293 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101293:	55                   	push   %ebp
80101294:	89 e5                	mov    %esp,%ebp
80101296:	53                   	push   %ebx
80101297:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010129a:	8b 45 08             	mov    0x8(%ebp),%eax
8010129d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a1:	84 c0                	test   %al,%al
801012a3:	75 0a                	jne    801012af <filewrite+0x1c>
    return -1;
801012a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012aa:	e9 1b 01 00 00       	jmp    801013ca <filewrite+0x137>
  if(f->type == FD_PIPE)
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	8b 00                	mov    (%eax),%eax
801012b4:	83 f8 01             	cmp    $0x1,%eax
801012b7:	75 1d                	jne    801012d6 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b9:	8b 45 08             	mov    0x8(%ebp),%eax
801012bc:	8b 40 0c             	mov    0xc(%eax),%eax
801012bf:	83 ec 04             	sub    $0x4,%esp
801012c2:	ff 75 10             	push   0x10(%ebp)
801012c5:	ff 75 0c             	push   0xc(%ebp)
801012c8:	50                   	push   %eax
801012c9:	e8 9d 24 00 00       	call   8010376b <pipewrite>
801012ce:	83 c4 10             	add    $0x10,%esp
801012d1:	e9 f4 00 00 00       	jmp    801013ca <filewrite+0x137>
  if(f->type == FD_INODE){
801012d6:	8b 45 08             	mov    0x8(%ebp),%eax
801012d9:	8b 00                	mov    (%eax),%eax
801012db:	83 f8 02             	cmp    $0x2,%eax
801012de:	0f 85 d9 00 00 00    	jne    801013bd <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e4:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f2:	e9 a3 00 00 00       	jmp    8010139a <filewrite+0x107>
      int n1 = n - i;
801012f7:	8b 45 10             	mov    0x10(%ebp),%eax
801012fa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101300:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101303:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101306:	7e 06                	jle    8010130e <filewrite+0x7b>
        n1 = max;
80101308:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130e:	e8 2a 1d 00 00       	call   8010303d <begin_op>
      ilock(f->ip);
80101313:	8b 45 08             	mov    0x8(%ebp),%eax
80101316:	8b 40 10             	mov    0x10(%eax),%eax
80101319:	83 ec 0c             	sub    $0xc,%esp
8010131c:	50                   	push   %eax
8010131d:	e8 c9 06 00 00       	call   801019eb <ilock>
80101322:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101325:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101328:	8b 45 08             	mov    0x8(%ebp),%eax
8010132b:	8b 50 14             	mov    0x14(%eax),%edx
8010132e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101331:	8b 45 0c             	mov    0xc(%ebp),%eax
80101334:	01 c3                	add    %eax,%ebx
80101336:	8b 45 08             	mov    0x8(%ebp),%eax
80101339:	8b 40 10             	mov    0x10(%eax),%eax
8010133c:	51                   	push   %ecx
8010133d:	52                   	push   %edx
8010133e:	53                   	push   %ebx
8010133f:	50                   	push   %eax
80101340:	e8 e7 0c 00 00       	call   8010202c <writei>
80101345:	83 c4 10             	add    $0x10,%esp
80101348:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134f:	7e 11                	jle    80101362 <filewrite+0xcf>
        f->off += r;
80101351:	8b 45 08             	mov    0x8(%ebp),%eax
80101354:	8b 50 14             	mov    0x14(%eax),%edx
80101357:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010135a:	01 c2                	add    %eax,%edx
8010135c:	8b 45 08             	mov    0x8(%ebp),%eax
8010135f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101362:	8b 45 08             	mov    0x8(%ebp),%eax
80101365:	8b 40 10             	mov    0x10(%eax),%eax
80101368:	83 ec 0c             	sub    $0xc,%esp
8010136b:	50                   	push   %eax
8010136c:	e8 8d 07 00 00       	call   80101afe <iunlock>
80101371:	83 c4 10             	add    $0x10,%esp
      end_op();
80101374:	e8 50 1d 00 00       	call   801030c9 <end_op>

      if(r < 0)
80101379:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137d:	78 29                	js     801013a8 <filewrite+0x115>
        break;
      if(r != n1)
8010137f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101382:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101385:	74 0d                	je     80101394 <filewrite+0x101>
        panic("short filewrite");
80101387:	83 ec 0c             	sub    $0xc,%esp
8010138a:	68 aa a3 10 80       	push   $0x8010a3aa
8010138f:	e8 15 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101394:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101397:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139d:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a0:	0f 8c 51 ff ff ff    	jl     801012f7 <filewrite+0x64>
801013a6:	eb 01                	jmp    801013a9 <filewrite+0x116>
        break;
801013a8:	90                   	nop
    }
    return i == n ? n : -1;
801013a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801013af:	75 05                	jne    801013b6 <filewrite+0x123>
801013b1:	8b 45 10             	mov    0x10(%ebp),%eax
801013b4:	eb 14                	jmp    801013ca <filewrite+0x137>
801013b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013bb:	eb 0d                	jmp    801013ca <filewrite+0x137>
  }
  panic("filewrite");
801013bd:	83 ec 0c             	sub    $0xc,%esp
801013c0:	68 ba a3 10 80       	push   $0x8010a3ba
801013c5:	e8 df f1 ff ff       	call   801005a9 <panic>
}
801013ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cd:	c9                   	leave  
801013ce:	c3                   	ret    

801013cf <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013cf:	55                   	push   %ebp
801013d0:	89 e5                	mov    %esp,%ebp
801013d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d5:	8b 45 08             	mov    0x8(%ebp),%eax
801013d8:	83 ec 08             	sub    $0x8,%esp
801013db:	6a 01                	push   $0x1
801013dd:	50                   	push   %eax
801013de:	e8 1e ee ff ff       	call   80100201 <bread>
801013e3:	83 c4 10             	add    $0x10,%esp
801013e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ec:	83 c0 5c             	add    $0x5c,%eax
801013ef:	83 ec 04             	sub    $0x4,%esp
801013f2:	6a 1c                	push   $0x1c
801013f4:	50                   	push   %eax
801013f5:	ff 75 0c             	push   0xc(%ebp)
801013f8:	e8 94 37 00 00       	call   80104b91 <memmove>
801013fd:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101400:	83 ec 0c             	sub    $0xc,%esp
80101403:	ff 75 f4             	push   -0xc(%ebp)
80101406:	e8 78 ee ff ff       	call   80100283 <brelse>
8010140b:	83 c4 10             	add    $0x10,%esp
}
8010140e:	90                   	nop
8010140f:	c9                   	leave  
80101410:	c3                   	ret    

80101411 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101411:	55                   	push   %ebp
80101412:	89 e5                	mov    %esp,%ebp
80101414:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101417:	8b 55 0c             	mov    0xc(%ebp),%edx
8010141a:	8b 45 08             	mov    0x8(%ebp),%eax
8010141d:	83 ec 08             	sub    $0x8,%esp
80101420:	52                   	push   %edx
80101421:	50                   	push   %eax
80101422:	e8 da ed ff ff       	call   80100201 <bread>
80101427:	83 c4 10             	add    $0x10,%esp
8010142a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101430:	83 c0 5c             	add    $0x5c,%eax
80101433:	83 ec 04             	sub    $0x4,%esp
80101436:	68 00 02 00 00       	push   $0x200
8010143b:	6a 00                	push   $0x0
8010143d:	50                   	push   %eax
8010143e:	e8 8f 36 00 00       	call   80104ad2 <memset>
80101443:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101446:	83 ec 0c             	sub    $0xc,%esp
80101449:	ff 75 f4             	push   -0xc(%ebp)
8010144c:	e8 25 1e 00 00       	call   80103276 <log_write>
80101451:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101454:	83 ec 0c             	sub    $0xc,%esp
80101457:	ff 75 f4             	push   -0xc(%ebp)
8010145a:	e8 24 ee ff ff       	call   80100283 <brelse>
8010145f:	83 c4 10             	add    $0x10,%esp
}
80101462:	90                   	nop
80101463:	c9                   	leave  
80101464:	c3                   	ret    

80101465 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101465:	55                   	push   %ebp
80101466:	89 e5                	mov    %esp,%ebp
80101468:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101472:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101479:	e9 0b 01 00 00       	jmp    80101589 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101481:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101487:	85 c0                	test   %eax,%eax
80101489:	0f 48 c2             	cmovs  %edx,%eax
8010148c:	c1 f8 0c             	sar    $0xc,%eax
8010148f:	89 c2                	mov    %eax,%edx
80101491:	a1 58 24 19 80       	mov    0x80192458,%eax
80101496:	01 d0                	add    %edx,%eax
80101498:	83 ec 08             	sub    $0x8,%esp
8010149b:	50                   	push   %eax
8010149c:	ff 75 08             	push   0x8(%ebp)
8010149f:	e8 5d ed ff ff       	call   80100201 <bread>
801014a4:	83 c4 10             	add    $0x10,%esp
801014a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b1:	e9 9e 00 00 00       	jmp    80101554 <balloc+0xef>
      m = 1 << (bi % 8);
801014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b9:	83 e0 07             	and    $0x7,%eax
801014bc:	ba 01 00 00 00       	mov    $0x1,%edx
801014c1:	89 c1                	mov    %eax,%ecx
801014c3:	d3 e2                	shl    %cl,%edx
801014c5:	89 d0                	mov    %edx,%eax
801014c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cd:	8d 50 07             	lea    0x7(%eax),%edx
801014d0:	85 c0                	test   %eax,%eax
801014d2:	0f 48 c2             	cmovs  %edx,%eax
801014d5:	c1 f8 03             	sar    $0x3,%eax
801014d8:	89 c2                	mov    %eax,%edx
801014da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dd:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e2:	0f b6 c0             	movzbl %al,%eax
801014e5:	23 45 e8             	and    -0x18(%ebp),%eax
801014e8:	85 c0                	test   %eax,%eax
801014ea:	75 64                	jne    80101550 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ef:	8d 50 07             	lea    0x7(%eax),%edx
801014f2:	85 c0                	test   %eax,%eax
801014f4:	0f 48 c2             	cmovs  %edx,%eax
801014f7:	c1 f8 03             	sar    $0x3,%eax
801014fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fd:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101502:	89 d1                	mov    %edx,%ecx
80101504:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101507:	09 ca                	or     %ecx,%edx
80101509:	89 d1                	mov    %edx,%ecx
8010150b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101512:	83 ec 0c             	sub    $0xc,%esp
80101515:	ff 75 ec             	push   -0x14(%ebp)
80101518:	e8 59 1d 00 00       	call   80103276 <log_write>
8010151d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101520:	83 ec 0c             	sub    $0xc,%esp
80101523:	ff 75 ec             	push   -0x14(%ebp)
80101526:	e8 58 ed ff ff       	call   80100283 <brelse>
8010152b:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101534:	01 c2                	add    %eax,%edx
80101536:	8b 45 08             	mov    0x8(%ebp),%eax
80101539:	83 ec 08             	sub    $0x8,%esp
8010153c:	52                   	push   %edx
8010153d:	50                   	push   %eax
8010153e:	e8 ce fe ff ff       	call   80101411 <bzero>
80101543:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101546:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154c:	01 d0                	add    %edx,%eax
8010154e:	eb 57                	jmp    801015a7 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101550:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101554:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155b:	7f 17                	jg     80101574 <balloc+0x10f>
8010155d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101560:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101563:	01 d0                	add    %edx,%eax
80101565:	89 c2                	mov    %eax,%edx
80101567:	a1 40 24 19 80       	mov    0x80192440,%eax
8010156c:	39 c2                	cmp    %eax,%edx
8010156e:	0f 82 42 ff ff ff    	jb     801014b6 <balloc+0x51>
      }
    }
    brelse(bp);
80101574:	83 ec 0c             	sub    $0xc,%esp
80101577:	ff 75 ec             	push   -0x14(%ebp)
8010157a:	e8 04 ed ff ff       	call   80100283 <brelse>
8010157f:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101582:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101589:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101592:	39 c2                	cmp    %eax,%edx
80101594:	0f 87 e4 fe ff ff    	ja     8010147e <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010159a:	83 ec 0c             	sub    $0xc,%esp
8010159d:	68 c4 a3 10 80       	push   $0x8010a3c4
801015a2:	e8 02 f0 ff ff       	call   801005a9 <panic>
}
801015a7:	c9                   	leave  
801015a8:	c3                   	ret    

801015a9 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a9:	55                   	push   %ebp
801015aa:	89 e5                	mov    %esp,%ebp
801015ac:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015af:	83 ec 08             	sub    $0x8,%esp
801015b2:	68 40 24 19 80       	push   $0x80192440
801015b7:	ff 75 08             	push   0x8(%ebp)
801015ba:	e8 10 fe ff ff       	call   801013cf <readsb>
801015bf:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c5:	c1 e8 0c             	shr    $0xc,%eax
801015c8:	89 c2                	mov    %eax,%edx
801015ca:	a1 58 24 19 80       	mov    0x80192458,%eax
801015cf:	01 c2                	add    %eax,%edx
801015d1:	8b 45 08             	mov    0x8(%ebp),%eax
801015d4:	83 ec 08             	sub    $0x8,%esp
801015d7:	52                   	push   %edx
801015d8:	50                   	push   %eax
801015d9:	e8 23 ec ff ff       	call   80100201 <bread>
801015de:	83 c4 10             	add    $0x10,%esp
801015e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e7:	25 ff 0f 00 00       	and    $0xfff,%eax
801015ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f2:	83 e0 07             	and    $0x7,%eax
801015f5:	ba 01 00 00 00       	mov    $0x1,%edx
801015fa:	89 c1                	mov    %eax,%ecx
801015fc:	d3 e2                	shl    %cl,%edx
801015fe:	89 d0                	mov    %edx,%eax
80101600:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101606:	8d 50 07             	lea    0x7(%eax),%edx
80101609:	85 c0                	test   %eax,%eax
8010160b:	0f 48 c2             	cmovs  %edx,%eax
8010160e:	c1 f8 03             	sar    $0x3,%eax
80101611:	89 c2                	mov    %eax,%edx
80101613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101616:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161b:	0f b6 c0             	movzbl %al,%eax
8010161e:	23 45 ec             	and    -0x14(%ebp),%eax
80101621:	85 c0                	test   %eax,%eax
80101623:	75 0d                	jne    80101632 <bfree+0x89>
    panic("freeing free block");
80101625:	83 ec 0c             	sub    $0xc,%esp
80101628:	68 da a3 10 80       	push   $0x8010a3da
8010162d:	e8 77 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101635:	8d 50 07             	lea    0x7(%eax),%edx
80101638:	85 c0                	test   %eax,%eax
8010163a:	0f 48 c2             	cmovs  %edx,%eax
8010163d:	c1 f8 03             	sar    $0x3,%eax
80101640:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101643:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101648:	89 d1                	mov    %edx,%ecx
8010164a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164d:	f7 d2                	not    %edx
8010164f:	21 ca                	and    %ecx,%edx
80101651:	89 d1                	mov    %edx,%ecx
80101653:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101656:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010165a:	83 ec 0c             	sub    $0xc,%esp
8010165d:	ff 75 f4             	push   -0xc(%ebp)
80101660:	e8 11 1c 00 00       	call   80103276 <log_write>
80101665:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	ff 75 f4             	push   -0xc(%ebp)
8010166e:	e8 10 ec ff ff       	call   80100283 <brelse>
80101673:	83 c4 10             	add    $0x10,%esp
}
80101676:	90                   	nop
80101677:	c9                   	leave  
80101678:	c3                   	ret    

80101679 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101679:	55                   	push   %ebp
8010167a:	89 e5                	mov    %esp,%ebp
8010167c:	57                   	push   %edi
8010167d:	56                   	push   %esi
8010167e:	53                   	push   %ebx
8010167f:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101682:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101689:	83 ec 08             	sub    $0x8,%esp
8010168c:	68 ed a3 10 80       	push   $0x8010a3ed
80101691:	68 60 24 19 80       	push   $0x80192460
80101696:	e8 9f 31 00 00       	call   8010483a <initlock>
8010169b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a5:	eb 2d                	jmp    801016d4 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016aa:	89 d0                	mov    %edx,%eax
801016ac:	c1 e0 03             	shl    $0x3,%eax
801016af:	01 d0                	add    %edx,%eax
801016b1:	c1 e0 04             	shl    $0x4,%eax
801016b4:	83 c0 30             	add    $0x30,%eax
801016b7:	05 60 24 19 80       	add    $0x80192460,%eax
801016bc:	83 c0 10             	add    $0x10,%eax
801016bf:	83 ec 08             	sub    $0x8,%esp
801016c2:	68 f4 a3 10 80       	push   $0x8010a3f4
801016c7:	50                   	push   %eax
801016c8:	e8 10 30 00 00       	call   801046dd <initsleeplock>
801016cd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d4:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d8:	7e cd                	jle    801016a7 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016da:	83 ec 08             	sub    $0x8,%esp
801016dd:	68 40 24 19 80       	push   $0x80192440
801016e2:	ff 75 08             	push   0x8(%ebp)
801016e5:	e8 e5 fc ff ff       	call   801013cf <readsb>
801016ea:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ed:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f5:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fb:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101701:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101707:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170d:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101713:	a1 40 24 19 80       	mov    0x80192440,%eax
80101718:	ff 75 d4             	push   -0x2c(%ebp)
8010171b:	57                   	push   %edi
8010171c:	56                   	push   %esi
8010171d:	53                   	push   %ebx
8010171e:	51                   	push   %ecx
8010171f:	52                   	push   %edx
80101720:	50                   	push   %eax
80101721:	68 fc a3 10 80       	push   $0x8010a3fc
80101726:	e8 c9 ec ff ff       	call   801003f4 <cprintf>
8010172b:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172e:	90                   	nop
8010172f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101732:	5b                   	pop    %ebx
80101733:	5e                   	pop    %esi
80101734:	5f                   	pop    %edi
80101735:	5d                   	pop    %ebp
80101736:	c3                   	ret    

80101737 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101737:	55                   	push   %ebp
80101738:	89 e5                	mov    %esp,%ebp
8010173a:	83 ec 28             	sub    $0x28,%esp
8010173d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101740:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101744:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174b:	e9 9e 00 00 00       	jmp    801017ee <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101753:	c1 e8 03             	shr    $0x3,%eax
80101756:	89 c2                	mov    %eax,%edx
80101758:	a1 54 24 19 80       	mov    0x80192454,%eax
8010175d:	01 d0                	add    %edx,%eax
8010175f:	83 ec 08             	sub    $0x8,%esp
80101762:	50                   	push   %eax
80101763:	ff 75 08             	push   0x8(%ebp)
80101766:	e8 96 ea ff ff       	call   80100201 <bread>
8010176b:	83 c4 10             	add    $0x10,%esp
8010176e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101774:	8d 50 5c             	lea    0x5c(%eax),%edx
80101777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177a:	83 e0 07             	and    $0x7,%eax
8010177d:	c1 e0 06             	shl    $0x6,%eax
80101780:	01 d0                	add    %edx,%eax
80101782:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101785:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101788:	0f b7 00             	movzwl (%eax),%eax
8010178b:	66 85 c0             	test   %ax,%ax
8010178e:	75 4c                	jne    801017dc <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101790:	83 ec 04             	sub    $0x4,%esp
80101793:	6a 40                	push   $0x40
80101795:	6a 00                	push   $0x0
80101797:	ff 75 ec             	push   -0x14(%ebp)
8010179a:	e8 33 33 00 00       	call   80104ad2 <memset>
8010179f:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a5:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a9:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ac:	83 ec 0c             	sub    $0xc,%esp
801017af:	ff 75 f0             	push   -0x10(%ebp)
801017b2:	e8 bf 1a 00 00       	call   80103276 <log_write>
801017b7:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017ba:	83 ec 0c             	sub    $0xc,%esp
801017bd:	ff 75 f0             	push   -0x10(%ebp)
801017c0:	e8 be ea ff ff       	call   80100283 <brelse>
801017c5:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cb:	83 ec 08             	sub    $0x8,%esp
801017ce:	50                   	push   %eax
801017cf:	ff 75 08             	push   0x8(%ebp)
801017d2:	e8 f8 00 00 00       	call   801018cf <iget>
801017d7:	83 c4 10             	add    $0x10,%esp
801017da:	eb 30                	jmp    8010180c <ialloc+0xd5>
    }
    brelse(bp);
801017dc:	83 ec 0c             	sub    $0xc,%esp
801017df:	ff 75 f0             	push   -0x10(%ebp)
801017e2:	e8 9c ea ff ff       	call   80100283 <brelse>
801017e7:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ee:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f7:	39 c2                	cmp    %eax,%edx
801017f9:	0f 87 51 ff ff ff    	ja     80101750 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017ff:	83 ec 0c             	sub    $0xc,%esp
80101802:	68 4f a4 10 80       	push   $0x8010a44f
80101807:	e8 9d ed ff ff       	call   801005a9 <panic>
}
8010180c:	c9                   	leave  
8010180d:	c3                   	ret    

8010180e <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180e:	55                   	push   %ebp
8010180f:	89 e5                	mov    %esp,%ebp
80101811:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101814:	8b 45 08             	mov    0x8(%ebp),%eax
80101817:	8b 40 04             	mov    0x4(%eax),%eax
8010181a:	c1 e8 03             	shr    $0x3,%eax
8010181d:	89 c2                	mov    %eax,%edx
8010181f:	a1 54 24 19 80       	mov    0x80192454,%eax
80101824:	01 c2                	add    %eax,%edx
80101826:	8b 45 08             	mov    0x8(%ebp),%eax
80101829:	8b 00                	mov    (%eax),%eax
8010182b:	83 ec 08             	sub    $0x8,%esp
8010182e:	52                   	push   %edx
8010182f:	50                   	push   %eax
80101830:	e8 cc e9 ff ff       	call   80100201 <bread>
80101835:	83 c4 10             	add    $0x10,%esp
80101838:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101841:	8b 45 08             	mov    0x8(%ebp),%eax
80101844:	8b 40 04             	mov    0x4(%eax),%eax
80101847:	83 e0 07             	and    $0x7,%eax
8010184a:	c1 e0 06             	shl    $0x6,%eax
8010184d:	01 d0                	add    %edx,%eax
8010184f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101852:	8b 45 08             	mov    0x8(%ebp),%eax
80101855:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185c:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185f:	8b 45 08             	mov    0x8(%ebp),%eax
80101862:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101869:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186d:	8b 45 08             	mov    0x8(%ebp),%eax
80101870:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101877:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187b:	8b 45 08             	mov    0x8(%ebp),%eax
8010187e:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101885:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101889:	8b 45 08             	mov    0x8(%ebp),%eax
8010188c:	8b 50 58             	mov    0x58(%eax),%edx
8010188f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101892:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101895:	8b 45 08             	mov    0x8(%ebp),%eax
80101898:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189e:	83 c0 0c             	add    $0xc,%eax
801018a1:	83 ec 04             	sub    $0x4,%esp
801018a4:	6a 34                	push   $0x34
801018a6:	52                   	push   %edx
801018a7:	50                   	push   %eax
801018a8:	e8 e4 32 00 00       	call   80104b91 <memmove>
801018ad:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b0:	83 ec 0c             	sub    $0xc,%esp
801018b3:	ff 75 f4             	push   -0xc(%ebp)
801018b6:	e8 bb 19 00 00       	call   80103276 <log_write>
801018bb:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018be:	83 ec 0c             	sub    $0xc,%esp
801018c1:	ff 75 f4             	push   -0xc(%ebp)
801018c4:	e8 ba e9 ff ff       	call   80100283 <brelse>
801018c9:	83 c4 10             	add    $0x10,%esp
}
801018cc:	90                   	nop
801018cd:	c9                   	leave  
801018ce:	c3                   	ret    

801018cf <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018cf:	55                   	push   %ebp
801018d0:	89 e5                	mov    %esp,%ebp
801018d2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d5:	83 ec 0c             	sub    $0xc,%esp
801018d8:	68 60 24 19 80       	push   $0x80192460
801018dd:	e8 7a 2f 00 00       	call   8010485c <acquire>
801018e2:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018ec:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018f3:	eb 60                	jmp    80101955 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f8:	8b 40 08             	mov    0x8(%eax),%eax
801018fb:	85 c0                	test   %eax,%eax
801018fd:	7e 39                	jle    80101938 <iget+0x69>
801018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101902:	8b 00                	mov    (%eax),%eax
80101904:	39 45 08             	cmp    %eax,0x8(%ebp)
80101907:	75 2f                	jne    80101938 <iget+0x69>
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190c:	8b 40 04             	mov    0x4(%eax),%eax
8010190f:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101912:	75 24                	jne    80101938 <iget+0x69>
      ip->ref++;
80101914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101917:	8b 40 08             	mov    0x8(%eax),%eax
8010191a:	8d 50 01             	lea    0x1(%eax),%edx
8010191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101920:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101923:	83 ec 0c             	sub    $0xc,%esp
80101926:	68 60 24 19 80       	push   $0x80192460
8010192b:	e8 9a 2f 00 00       	call   801048ca <release>
80101930:	83 c4 10             	add    $0x10,%esp
      return ip;
80101933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101936:	eb 77                	jmp    801019af <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101938:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193c:	75 10                	jne    8010194e <iget+0x7f>
8010193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101941:	8b 40 08             	mov    0x8(%eax),%eax
80101944:	85 c0                	test   %eax,%eax
80101946:	75 06                	jne    8010194e <iget+0x7f>
      empty = ip;
80101948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101955:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195c:	72 97                	jb     801018f5 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101962:	75 0d                	jne    80101971 <iget+0xa2>
    panic("iget: no inodes");
80101964:	83 ec 0c             	sub    $0xc,%esp
80101967:	68 61 a4 10 80       	push   $0x8010a461
8010196c:	e8 38 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101971:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101974:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197a:	8b 55 08             	mov    0x8(%ebp),%edx
8010197d:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101982:	8b 55 0c             	mov    0xc(%ebp),%edx
80101985:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101995:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199c:	83 ec 0c             	sub    $0xc,%esp
8010199f:	68 60 24 19 80       	push   $0x80192460
801019a4:	e8 21 2f 00 00       	call   801048ca <release>
801019a9:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019af:	c9                   	leave  
801019b0:	c3                   	ret    

801019b1 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b1:	55                   	push   %ebp
801019b2:	89 e5                	mov    %esp,%ebp
801019b4:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b7:	83 ec 0c             	sub    $0xc,%esp
801019ba:	68 60 24 19 80       	push   $0x80192460
801019bf:	e8 98 2e 00 00       	call   8010485c <acquire>
801019c4:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ca:	8b 40 08             	mov    0x8(%eax),%eax
801019cd:	8d 50 01             	lea    0x1(%eax),%edx
801019d0:	8b 45 08             	mov    0x8(%ebp),%eax
801019d3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d6:	83 ec 0c             	sub    $0xc,%esp
801019d9:	68 60 24 19 80       	push   $0x80192460
801019de:	e8 e7 2e 00 00       	call   801048ca <release>
801019e3:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e9:	c9                   	leave  
801019ea:	c3                   	ret    

801019eb <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019eb:	55                   	push   %ebp
801019ec:	89 e5                	mov    %esp,%ebp
801019ee:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f5:	74 0a                	je     80101a01 <ilock+0x16>
801019f7:	8b 45 08             	mov    0x8(%ebp),%eax
801019fa:	8b 40 08             	mov    0x8(%eax),%eax
801019fd:	85 c0                	test   %eax,%eax
801019ff:	7f 0d                	jg     80101a0e <ilock+0x23>
    panic("ilock");
80101a01:	83 ec 0c             	sub    $0xc,%esp
80101a04:	68 71 a4 10 80       	push   $0x8010a471
80101a09:	e8 9b eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	83 c0 0c             	add    $0xc,%eax
80101a14:	83 ec 0c             	sub    $0xc,%esp
80101a17:	50                   	push   %eax
80101a18:	e8 fc 2c 00 00       	call   80104719 <acquiresleep>
80101a1d:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a26:	85 c0                	test   %eax,%eax
80101a28:	0f 85 cd 00 00 00    	jne    80101afb <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a31:	8b 40 04             	mov    0x4(%eax),%eax
80101a34:	c1 e8 03             	shr    $0x3,%eax
80101a37:	89 c2                	mov    %eax,%edx
80101a39:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a3e:	01 c2                	add    %eax,%edx
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	8b 00                	mov    (%eax),%eax
80101a45:	83 ec 08             	sub    $0x8,%esp
80101a48:	52                   	push   %edx
80101a49:	50                   	push   %eax
80101a4a:	e8 b2 e7 ff ff       	call   80100201 <bread>
80101a4f:	83 c4 10             	add    $0x10,%esp
80101a52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a58:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5e:	8b 40 04             	mov    0x4(%eax),%eax
80101a61:	83 e0 07             	and    $0x7,%eax
80101a64:	c1 e0 06             	shl    $0x6,%eax
80101a67:	01 d0                	add    %edx,%eax
80101a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6f:	0f b7 10             	movzwl (%eax),%edx
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a91:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a98:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa6:	8b 50 08             	mov    0x8(%eax),%edx
80101aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aac:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab2:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	83 c0 5c             	add    $0x5c,%eax
80101abb:	83 ec 04             	sub    $0x4,%esp
80101abe:	6a 34                	push   $0x34
80101ac0:	52                   	push   %edx
80101ac1:	50                   	push   %eax
80101ac2:	e8 ca 30 00 00       	call   80104b91 <memmove>
80101ac7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101aca:	83 ec 0c             	sub    $0xc,%esp
80101acd:	ff 75 f4             	push   -0xc(%ebp)
80101ad0:	e8 ae e7 ff ff       	call   80100283 <brelse>
80101ad5:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae9:	66 85 c0             	test   %ax,%ax
80101aec:	75 0d                	jne    80101afb <ilock+0x110>
      panic("ilock: no type");
80101aee:	83 ec 0c             	sub    $0xc,%esp
80101af1:	68 77 a4 10 80       	push   $0x8010a477
80101af6:	e8 ae ea ff ff       	call   801005a9 <panic>
  }
}
80101afb:	90                   	nop
80101afc:	c9                   	leave  
80101afd:	c3                   	ret    

80101afe <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afe:	55                   	push   %ebp
80101aff:	89 e5                	mov    %esp,%ebp
80101b01:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b04:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b08:	74 20                	je     80101b2a <iunlock+0x2c>
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	83 c0 0c             	add    $0xc,%eax
80101b10:	83 ec 0c             	sub    $0xc,%esp
80101b13:	50                   	push   %eax
80101b14:	e8 b2 2c 00 00       	call   801047cb <holdingsleep>
80101b19:	83 c4 10             	add    $0x10,%esp
80101b1c:	85 c0                	test   %eax,%eax
80101b1e:	74 0a                	je     80101b2a <iunlock+0x2c>
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	8b 40 08             	mov    0x8(%eax),%eax
80101b26:	85 c0                	test   %eax,%eax
80101b28:	7f 0d                	jg     80101b37 <iunlock+0x39>
    panic("iunlock");
80101b2a:	83 ec 0c             	sub    $0xc,%esp
80101b2d:	68 86 a4 10 80       	push   $0x8010a486
80101b32:	e8 72 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b37:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3a:	83 c0 0c             	add    $0xc,%eax
80101b3d:	83 ec 0c             	sub    $0xc,%esp
80101b40:	50                   	push   %eax
80101b41:	e8 37 2c 00 00       	call   8010477d <releasesleep>
80101b46:	83 c4 10             	add    $0x10,%esp
}
80101b49:	90                   	nop
80101b4a:	c9                   	leave  
80101b4b:	c3                   	ret    

80101b4c <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4c:	55                   	push   %ebp
80101b4d:	89 e5                	mov    %esp,%ebp
80101b4f:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b52:	8b 45 08             	mov    0x8(%ebp),%eax
80101b55:	83 c0 0c             	add    $0xc,%eax
80101b58:	83 ec 0c             	sub    $0xc,%esp
80101b5b:	50                   	push   %eax
80101b5c:	e8 b8 2b 00 00       	call   80104719 <acquiresleep>
80101b61:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b6a:	85 c0                	test   %eax,%eax
80101b6c:	74 6a                	je     80101bd8 <iput+0x8c>
80101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b71:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b75:	66 85 c0             	test   %ax,%ax
80101b78:	75 5e                	jne    80101bd8 <iput+0x8c>
    acquire(&icache.lock);
80101b7a:	83 ec 0c             	sub    $0xc,%esp
80101b7d:	68 60 24 19 80       	push   $0x80192460
80101b82:	e8 d5 2c 00 00       	call   8010485c <acquire>
80101b87:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8d:	8b 40 08             	mov    0x8(%eax),%eax
80101b90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b93:	83 ec 0c             	sub    $0xc,%esp
80101b96:	68 60 24 19 80       	push   $0x80192460
80101b9b:	e8 2a 2d 00 00       	call   801048ca <release>
80101ba0:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba3:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba7:	75 2f                	jne    80101bd8 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	ff 75 08             	push   0x8(%ebp)
80101baf:	e8 ad 01 00 00       	call   80101d61 <itrunc>
80101bb4:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bba:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bc0:	83 ec 0c             	sub    $0xc,%esp
80101bc3:	ff 75 08             	push   0x8(%ebp)
80101bc6:	e8 43 fc ff ff       	call   8010180e <iupdate>
80101bcb:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bce:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd1:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdb:	83 c0 0c             	add    $0xc,%eax
80101bde:	83 ec 0c             	sub    $0xc,%esp
80101be1:	50                   	push   %eax
80101be2:	e8 96 2b 00 00       	call   8010477d <releasesleep>
80101be7:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bea:	83 ec 0c             	sub    $0xc,%esp
80101bed:	68 60 24 19 80       	push   $0x80192460
80101bf2:	e8 65 2c 00 00       	call   8010485c <acquire>
80101bf7:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	8b 40 08             	mov    0x8(%eax),%eax
80101c00:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c03:	8b 45 08             	mov    0x8(%ebp),%eax
80101c06:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c09:	83 ec 0c             	sub    $0xc,%esp
80101c0c:	68 60 24 19 80       	push   $0x80192460
80101c11:	e8 b4 2c 00 00       	call   801048ca <release>
80101c16:	83 c4 10             	add    $0x10,%esp
}
80101c19:	90                   	nop
80101c1a:	c9                   	leave  
80101c1b:	c3                   	ret    

80101c1c <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1c:	55                   	push   %ebp
80101c1d:	89 e5                	mov    %esp,%ebp
80101c1f:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c22:	83 ec 0c             	sub    $0xc,%esp
80101c25:	ff 75 08             	push   0x8(%ebp)
80101c28:	e8 d1 fe ff ff       	call   80101afe <iunlock>
80101c2d:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	ff 75 08             	push   0x8(%ebp)
80101c36:	e8 11 ff ff ff       	call   80101b4c <iput>
80101c3b:	83 c4 10             	add    $0x10,%esp
}
80101c3e:	90                   	nop
80101c3f:	c9                   	leave  
80101c40:	c3                   	ret    

80101c41 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c41:	55                   	push   %ebp
80101c42:	89 e5                	mov    %esp,%ebp
80101c44:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c47:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4b:	77 42                	ja     80101c8f <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c50:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c53:	83 c2 14             	add    $0x14,%edx
80101c56:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c61:	75 24                	jne    80101c87 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 00                	mov    (%eax),%eax
80101c68:	83 ec 0c             	sub    $0xc,%esp
80101c6b:	50                   	push   %eax
80101c6c:	e8 f4 f7 ff ff       	call   80101465 <balloc>
80101c71:	83 c4 10             	add    $0x10,%esp
80101c74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7d:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c83:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c8a:	e9 d0 00 00 00       	jmp    80101d5f <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8f:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c93:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c97:	0f 87 b5 00 00 00    	ja     80101d52 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cad:	75 20                	jne    80101ccf <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	8b 00                	mov    (%eax),%eax
80101cb4:	83 ec 0c             	sub    $0xc,%esp
80101cb7:	50                   	push   %eax
80101cb8:	e8 a8 f7 ff ff       	call   80101465 <balloc>
80101cbd:	83 c4 10             	add    $0x10,%esp
80101cc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd2:	8b 00                	mov    (%eax),%eax
80101cd4:	83 ec 08             	sub    $0x8,%esp
80101cd7:	ff 75 f4             	push   -0xc(%ebp)
80101cda:	50                   	push   %eax
80101cdb:	e8 21 e5 ff ff       	call   80100201 <bread>
80101ce0:	83 c4 10             	add    $0x10,%esp
80101ce3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce9:	83 c0 5c             	add    $0x5c,%eax
80101cec:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cef:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfc:	01 d0                	add    %edx,%eax
80101cfe:	8b 00                	mov    (%eax),%eax
80101d00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d07:	75 36                	jne    80101d3f <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d09:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0c:	8b 00                	mov    (%eax),%eax
80101d0e:	83 ec 0c             	sub    $0xc,%esp
80101d11:	50                   	push   %eax
80101d12:	e8 4e f7 ff ff       	call   80101465 <balloc>
80101d17:	83 c4 10             	add    $0x10,%esp
80101d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d2a:	01 c2                	add    %eax,%edx
80101d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2f:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d31:	83 ec 0c             	sub    $0xc,%esp
80101d34:	ff 75 f0             	push   -0x10(%ebp)
80101d37:	e8 3a 15 00 00       	call   80103276 <log_write>
80101d3c:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3f:	83 ec 0c             	sub    $0xc,%esp
80101d42:	ff 75 f0             	push   -0x10(%ebp)
80101d45:	e8 39 e5 ff ff       	call   80100283 <brelse>
80101d4a:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d50:	eb 0d                	jmp    80101d5f <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d52:	83 ec 0c             	sub    $0xc,%esp
80101d55:	68 8e a4 10 80       	push   $0x8010a48e
80101d5a:	e8 4a e8 ff ff       	call   801005a9 <panic>
}
80101d5f:	c9                   	leave  
80101d60:	c3                   	ret    

80101d61 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d61:	55                   	push   %ebp
80101d62:	89 e5                	mov    %esp,%ebp
80101d64:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6e:	eb 45                	jmp    80101db5 <itrunc+0x54>
    if(ip->addrs[i]){
80101d70:	8b 45 08             	mov    0x8(%ebp),%eax
80101d73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d76:	83 c2 14             	add    $0x14,%edx
80101d79:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7d:	85 c0                	test   %eax,%eax
80101d7f:	74 30                	je     80101db1 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d87:	83 c2 14             	add    $0x14,%edx
80101d8a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8e:	8b 55 08             	mov    0x8(%ebp),%edx
80101d91:	8b 12                	mov    (%edx),%edx
80101d93:	83 ec 08             	sub    $0x8,%esp
80101d96:	50                   	push   %eax
80101d97:	52                   	push   %edx
80101d98:	e8 0c f8 ff ff       	call   801015a9 <bfree>
80101d9d:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da6:	83 c2 14             	add    $0x14,%edx
80101da9:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db0:	00 
  for(i = 0; i < NDIRECT; i++){
80101db1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db5:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db9:	7e b5                	jle    80101d70 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbe:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc4:	85 c0                	test   %eax,%eax
80101dc6:	0f 84 aa 00 00 00    	je     80101e76 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcf:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	8b 00                	mov    (%eax),%eax
80101dda:	83 ec 08             	sub    $0x8,%esp
80101ddd:	52                   	push   %edx
80101dde:	50                   	push   %eax
80101ddf:	e8 1d e4 ff ff       	call   80100201 <bread>
80101de4:	83 c4 10             	add    $0x10,%esp
80101de7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ded:	83 c0 5c             	add    $0x5c,%eax
80101df0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101dfa:	eb 3c                	jmp    80101e38 <itrunc+0xd7>
      if(a[j])
80101dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e06:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e09:	01 d0                	add    %edx,%eax
80101e0b:	8b 00                	mov    (%eax),%eax
80101e0d:	85 c0                	test   %eax,%eax
80101e0f:	74 23                	je     80101e34 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1e:	01 d0                	add    %edx,%eax
80101e20:	8b 00                	mov    (%eax),%eax
80101e22:	8b 55 08             	mov    0x8(%ebp),%edx
80101e25:	8b 12                	mov    (%edx),%edx
80101e27:	83 ec 08             	sub    $0x8,%esp
80101e2a:	50                   	push   %eax
80101e2b:	52                   	push   %edx
80101e2c:	e8 78 f7 ff ff       	call   801015a9 <bfree>
80101e31:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e34:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3b:	83 f8 7f             	cmp    $0x7f,%eax
80101e3e:	76 bc                	jbe    80101dfc <itrunc+0x9b>
    }
    brelse(bp);
80101e40:	83 ec 0c             	sub    $0xc,%esp
80101e43:	ff 75 ec             	push   -0x14(%ebp)
80101e46:	e8 38 e4 ff ff       	call   80100283 <brelse>
80101e4b:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e51:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e57:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5a:	8b 12                	mov    (%edx),%edx
80101e5c:	83 ec 08             	sub    $0x8,%esp
80101e5f:	50                   	push   %eax
80101e60:	52                   	push   %edx
80101e61:	e8 43 f7 ff ff       	call   801015a9 <bfree>
80101e66:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e69:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6c:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e73:	00 00 00 
  }

  ip->size = 0;
80101e76:	8b 45 08             	mov    0x8(%ebp),%eax
80101e79:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e80:	83 ec 0c             	sub    $0xc,%esp
80101e83:	ff 75 08             	push   0x8(%ebp)
80101e86:	e8 83 f9 ff ff       	call   8010180e <iupdate>
80101e8b:	83 c4 10             	add    $0x10,%esp
}
80101e8e:	90                   	nop
80101e8f:	c9                   	leave  
80101e90:	c3                   	ret    

80101e91 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e91:	55                   	push   %ebp
80101e92:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e94:	8b 45 08             	mov    0x8(%ebp),%eax
80101e97:	8b 00                	mov    (%eax),%eax
80101e99:	89 c2                	mov    %eax,%edx
80101e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	8b 50 04             	mov    0x4(%eax),%edx
80101ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eaa:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ead:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb0:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb7:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec4:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	8b 50 58             	mov    0x58(%eax),%edx
80101ece:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed1:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed4:	90                   	nop
80101ed5:	5d                   	pop    %ebp
80101ed6:	c3                   	ret    

80101ed7 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed7:	55                   	push   %ebp
80101ed8:	89 e5                	mov    %esp,%ebp
80101eda:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee4:	66 83 f8 03          	cmp    $0x3,%ax
80101ee8:	75 5c                	jne    80101f46 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef1:	66 85 c0             	test   %ax,%ax
80101ef4:	78 20                	js     80101f16 <readi+0x3f>
80101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efd:	66 83 f8 09          	cmp    $0x9,%ax
80101f01:	7f 13                	jg     80101f16 <readi+0x3f>
80101f03:	8b 45 08             	mov    0x8(%ebp),%eax
80101f06:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f0a:	98                   	cwtl   
80101f0b:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f12:	85 c0                	test   %eax,%eax
80101f14:	75 0a                	jne    80101f20 <readi+0x49>
      return -1;
80101f16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1b:	e9 0a 01 00 00       	jmp    8010202a <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f20:	8b 45 08             	mov    0x8(%ebp),%eax
80101f23:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f27:	98                   	cwtl   
80101f28:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f2f:	8b 55 14             	mov    0x14(%ebp),%edx
80101f32:	83 ec 04             	sub    $0x4,%esp
80101f35:	52                   	push   %edx
80101f36:	ff 75 0c             	push   0xc(%ebp)
80101f39:	ff 75 08             	push   0x8(%ebp)
80101f3c:	ff d0                	call   *%eax
80101f3e:	83 c4 10             	add    $0x10,%esp
80101f41:	e9 e4 00 00 00       	jmp    8010202a <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f46:	8b 45 08             	mov    0x8(%ebp),%eax
80101f49:	8b 40 58             	mov    0x58(%eax),%eax
80101f4c:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4f:	77 0d                	ja     80101f5e <readi+0x87>
80101f51:	8b 55 10             	mov    0x10(%ebp),%edx
80101f54:	8b 45 14             	mov    0x14(%ebp),%eax
80101f57:	01 d0                	add    %edx,%eax
80101f59:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5c:	76 0a                	jbe    80101f68 <readi+0x91>
    return -1;
80101f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f63:	e9 c2 00 00 00       	jmp    8010202a <readi+0x153>
  if(off + n > ip->size)
80101f68:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6e:	01 c2                	add    %eax,%edx
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
80101f73:	8b 40 58             	mov    0x58(%eax),%eax
80101f76:	39 c2                	cmp    %eax,%edx
80101f78:	76 0c                	jbe    80101f86 <readi+0xaf>
    n = ip->size - off;
80101f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7d:	8b 40 58             	mov    0x58(%eax),%eax
80101f80:	2b 45 10             	sub    0x10(%ebp),%eax
80101f83:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8d:	e9 89 00 00 00       	jmp    8010201b <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f92:	8b 45 10             	mov    0x10(%ebp),%eax
80101f95:	c1 e8 09             	shr    $0x9,%eax
80101f98:	83 ec 08             	sub    $0x8,%esp
80101f9b:	50                   	push   %eax
80101f9c:	ff 75 08             	push   0x8(%ebp)
80101f9f:	e8 9d fc ff ff       	call   80101c41 <bmap>
80101fa4:	83 c4 10             	add    $0x10,%esp
80101fa7:	8b 55 08             	mov    0x8(%ebp),%edx
80101faa:	8b 12                	mov    (%edx),%edx
80101fac:	83 ec 08             	sub    $0x8,%esp
80101faf:	50                   	push   %eax
80101fb0:	52                   	push   %edx
80101fb1:	e8 4b e2 ff ff       	call   80100201 <bread>
80101fb6:	83 c4 10             	add    $0x10,%esp
80101fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbc:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbf:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc4:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc9:	29 c2                	sub    %eax,%edx
80101fcb:	8b 45 14             	mov    0x14(%ebp),%eax
80101fce:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd1:	39 c2                	cmp    %eax,%edx
80101fd3:	0f 46 c2             	cmovbe %edx,%eax
80101fd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdc:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fdf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe7:	01 d0                	add    %edx,%eax
80101fe9:	83 ec 04             	sub    $0x4,%esp
80101fec:	ff 75 ec             	push   -0x14(%ebp)
80101fef:	50                   	push   %eax
80101ff0:	ff 75 0c             	push   0xc(%ebp)
80101ff3:	e8 99 2b 00 00       	call   80104b91 <memmove>
80101ff8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffb:	83 ec 0c             	sub    $0xc,%esp
80101ffe:	ff 75 f0             	push   -0x10(%ebp)
80102001:	e8 7d e2 ff ff       	call   80100283 <brelse>
80102006:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102009:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102012:	01 45 10             	add    %eax,0x10(%ebp)
80102015:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102018:	01 45 0c             	add    %eax,0xc(%ebp)
8010201b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102021:	0f 82 6b ff ff ff    	jb     80101f92 <readi+0xbb>
  }
  return n;
80102027:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202a:	c9                   	leave  
8010202b:	c3                   	ret    

8010202c <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202c:	55                   	push   %ebp
8010202d:	89 e5                	mov    %esp,%ebp
8010202f:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102032:	8b 45 08             	mov    0x8(%ebp),%eax
80102035:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102039:	66 83 f8 03          	cmp    $0x3,%ax
8010203d:	75 5c                	jne    8010209b <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102046:	66 85 c0             	test   %ax,%ax
80102049:	78 20                	js     8010206b <writei+0x3f>
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102052:	66 83 f8 09          	cmp    $0x9,%ax
80102056:	7f 13                	jg     8010206b <writei+0x3f>
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205f:	98                   	cwtl   
80102060:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102067:	85 c0                	test   %eax,%eax
80102069:	75 0a                	jne    80102075 <writei+0x49>
      return -1;
8010206b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102070:	e9 3b 01 00 00       	jmp    801021b0 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207c:	98                   	cwtl   
8010207d:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102084:	8b 55 14             	mov    0x14(%ebp),%edx
80102087:	83 ec 04             	sub    $0x4,%esp
8010208a:	52                   	push   %edx
8010208b:	ff 75 0c             	push   0xc(%ebp)
8010208e:	ff 75 08             	push   0x8(%ebp)
80102091:	ff d0                	call   *%eax
80102093:	83 c4 10             	add    $0x10,%esp
80102096:	e9 15 01 00 00       	jmp    801021b0 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209b:	8b 45 08             	mov    0x8(%ebp),%eax
8010209e:	8b 40 58             	mov    0x58(%eax),%eax
801020a1:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a4:	77 0d                	ja     801020b3 <writei+0x87>
801020a6:	8b 55 10             	mov    0x10(%ebp),%edx
801020a9:	8b 45 14             	mov    0x14(%ebp),%eax
801020ac:	01 d0                	add    %edx,%eax
801020ae:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b1:	76 0a                	jbe    801020bd <writei+0x91>
    return -1;
801020b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b8:	e9 f3 00 00 00       	jmp    801021b0 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bd:	8b 55 10             	mov    0x10(%ebp),%edx
801020c0:	8b 45 14             	mov    0x14(%ebp),%eax
801020c3:	01 d0                	add    %edx,%eax
801020c5:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020ca:	76 0a                	jbe    801020d6 <writei+0xaa>
    return -1;
801020cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d1:	e9 da 00 00 00       	jmp    801021b0 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dd:	e9 97 00 00 00       	jmp    80102179 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e2:	8b 45 10             	mov    0x10(%ebp),%eax
801020e5:	c1 e8 09             	shr    $0x9,%eax
801020e8:	83 ec 08             	sub    $0x8,%esp
801020eb:	50                   	push   %eax
801020ec:	ff 75 08             	push   0x8(%ebp)
801020ef:	e8 4d fb ff ff       	call   80101c41 <bmap>
801020f4:	83 c4 10             	add    $0x10,%esp
801020f7:	8b 55 08             	mov    0x8(%ebp),%edx
801020fa:	8b 12                	mov    (%edx),%edx
801020fc:	83 ec 08             	sub    $0x8,%esp
801020ff:	50                   	push   %eax
80102100:	52                   	push   %edx
80102101:	e8 fb e0 ff ff       	call   80100201 <bread>
80102106:	83 c4 10             	add    $0x10,%esp
80102109:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210c:	8b 45 10             	mov    0x10(%ebp),%eax
8010210f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102114:	ba 00 02 00 00       	mov    $0x200,%edx
80102119:	29 c2                	sub    %eax,%edx
8010211b:	8b 45 14             	mov    0x14(%ebp),%eax
8010211e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102121:	39 c2                	cmp    %eax,%edx
80102123:	0f 46 c2             	cmovbe %edx,%eax
80102126:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102129:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212f:	8b 45 10             	mov    0x10(%ebp),%eax
80102132:	25 ff 01 00 00       	and    $0x1ff,%eax
80102137:	01 d0                	add    %edx,%eax
80102139:	83 ec 04             	sub    $0x4,%esp
8010213c:	ff 75 ec             	push   -0x14(%ebp)
8010213f:	ff 75 0c             	push   0xc(%ebp)
80102142:	50                   	push   %eax
80102143:	e8 49 2a 00 00       	call   80104b91 <memmove>
80102148:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214b:	83 ec 0c             	sub    $0xc,%esp
8010214e:	ff 75 f0             	push   -0x10(%ebp)
80102151:	e8 20 11 00 00       	call   80103276 <log_write>
80102156:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102159:	83 ec 0c             	sub    $0xc,%esp
8010215c:	ff 75 f0             	push   -0x10(%ebp)
8010215f:	e8 1f e1 ff ff       	call   80100283 <brelse>
80102164:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102167:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102170:	01 45 10             	add    %eax,0x10(%ebp)
80102173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102176:	01 45 0c             	add    %eax,0xc(%ebp)
80102179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217f:	0f 82 5d ff ff ff    	jb     801020e2 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102185:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102189:	74 22                	je     801021ad <writei+0x181>
8010218b:	8b 45 08             	mov    0x8(%ebp),%eax
8010218e:	8b 40 58             	mov    0x58(%eax),%eax
80102191:	39 45 10             	cmp    %eax,0x10(%ebp)
80102194:	76 17                	jbe    801021ad <writei+0x181>
    ip->size = off;
80102196:	8b 45 08             	mov    0x8(%ebp),%eax
80102199:	8b 55 10             	mov    0x10(%ebp),%edx
8010219c:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219f:	83 ec 0c             	sub    $0xc,%esp
801021a2:	ff 75 08             	push   0x8(%ebp)
801021a5:	e8 64 f6 ff ff       	call   8010180e <iupdate>
801021aa:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ad:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b0:	c9                   	leave  
801021b1:	c3                   	ret    

801021b2 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b2:	55                   	push   %ebp
801021b3:	89 e5                	mov    %esp,%ebp
801021b5:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b8:	83 ec 04             	sub    $0x4,%esp
801021bb:	6a 0e                	push   $0xe
801021bd:	ff 75 0c             	push   0xc(%ebp)
801021c0:	ff 75 08             	push   0x8(%ebp)
801021c3:	e8 5f 2a 00 00       	call   80104c27 <strncmp>
801021c8:	83 c4 10             	add    $0x10,%esp
}
801021cb:	c9                   	leave  
801021cc:	c3                   	ret    

801021cd <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cd:	55                   	push   %ebp
801021ce:	89 e5                	mov    %esp,%ebp
801021d0:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d3:	8b 45 08             	mov    0x8(%ebp),%eax
801021d6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021da:	66 83 f8 01          	cmp    $0x1,%ax
801021de:	74 0d                	je     801021ed <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e0:	83 ec 0c             	sub    $0xc,%esp
801021e3:	68 a1 a4 10 80       	push   $0x8010a4a1
801021e8:	e8 bc e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f4:	eb 7b                	jmp    80102271 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f6:	6a 10                	push   $0x10
801021f8:	ff 75 f4             	push   -0xc(%ebp)
801021fb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fe:	50                   	push   %eax
801021ff:	ff 75 08             	push   0x8(%ebp)
80102202:	e8 d0 fc ff ff       	call   80101ed7 <readi>
80102207:	83 c4 10             	add    $0x10,%esp
8010220a:	83 f8 10             	cmp    $0x10,%eax
8010220d:	74 0d                	je     8010221c <dirlookup+0x4f>
      panic("dirlookup read");
8010220f:	83 ec 0c             	sub    $0xc,%esp
80102212:	68 b3 a4 10 80       	push   $0x8010a4b3
80102217:	e8 8d e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102220:	66 85 c0             	test   %ax,%ax
80102223:	74 47                	je     8010226c <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102225:	83 ec 08             	sub    $0x8,%esp
80102228:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222b:	83 c0 02             	add    $0x2,%eax
8010222e:	50                   	push   %eax
8010222f:	ff 75 0c             	push   0xc(%ebp)
80102232:	e8 7b ff ff ff       	call   801021b2 <namecmp>
80102237:	83 c4 10             	add    $0x10,%esp
8010223a:	85 c0                	test   %eax,%eax
8010223c:	75 2f                	jne    8010226d <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102242:	74 08                	je     8010224c <dirlookup+0x7f>
        *poff = off;
80102244:	8b 45 10             	mov    0x10(%ebp),%eax
80102247:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010224a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102250:	0f b7 c0             	movzwl %ax,%eax
80102253:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102256:	8b 45 08             	mov    0x8(%ebp),%eax
80102259:	8b 00                	mov    (%eax),%eax
8010225b:	83 ec 08             	sub    $0x8,%esp
8010225e:	ff 75 f0             	push   -0x10(%ebp)
80102261:	50                   	push   %eax
80102262:	e8 68 f6 ff ff       	call   801018cf <iget>
80102267:	83 c4 10             	add    $0x10,%esp
8010226a:	eb 19                	jmp    80102285 <dirlookup+0xb8>
      continue;
8010226c:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 40 58             	mov    0x58(%eax),%eax
80102277:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010227a:	0f 82 76 ff ff ff    	jb     801021f6 <dirlookup+0x29>
    }
  }

  return 0;
80102280:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102285:	c9                   	leave  
80102286:	c3                   	ret    

80102287 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102287:	55                   	push   %ebp
80102288:	89 e5                	mov    %esp,%ebp
8010228a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228d:	83 ec 04             	sub    $0x4,%esp
80102290:	6a 00                	push   $0x0
80102292:	ff 75 0c             	push   0xc(%ebp)
80102295:	ff 75 08             	push   0x8(%ebp)
80102298:	e8 30 ff ff ff       	call   801021cd <dirlookup>
8010229d:	83 c4 10             	add    $0x10,%esp
801022a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a7:	74 18                	je     801022c1 <dirlink+0x3a>
    iput(ip);
801022a9:	83 ec 0c             	sub    $0xc,%esp
801022ac:	ff 75 f0             	push   -0x10(%ebp)
801022af:	e8 98 f8 ff ff       	call   80101b4c <iput>
801022b4:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bc:	e9 9c 00 00 00       	jmp    8010235d <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c8:	eb 39                	jmp    80102303 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cd:	6a 10                	push   $0x10
801022cf:	50                   	push   %eax
801022d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d3:	50                   	push   %eax
801022d4:	ff 75 08             	push   0x8(%ebp)
801022d7:	e8 fb fb ff ff       	call   80101ed7 <readi>
801022dc:	83 c4 10             	add    $0x10,%esp
801022df:	83 f8 10             	cmp    $0x10,%eax
801022e2:	74 0d                	je     801022f1 <dirlink+0x6a>
      panic("dirlink read");
801022e4:	83 ec 0c             	sub    $0xc,%esp
801022e7:	68 c2 a4 10 80       	push   $0x8010a4c2
801022ec:	e8 b8 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f5:	66 85 c0             	test   %ax,%ax
801022f8:	74 18                	je     80102312 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fd:	83 c0 10             	add    $0x10,%eax
80102300:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102303:	8b 45 08             	mov    0x8(%ebp),%eax
80102306:	8b 50 58             	mov    0x58(%eax),%edx
80102309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230c:	39 c2                	cmp    %eax,%edx
8010230e:	77 ba                	ja     801022ca <dirlink+0x43>
80102310:	eb 01                	jmp    80102313 <dirlink+0x8c>
      break;
80102312:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102313:	83 ec 04             	sub    $0x4,%esp
80102316:	6a 0e                	push   $0xe
80102318:	ff 75 0c             	push   0xc(%ebp)
8010231b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231e:	83 c0 02             	add    $0x2,%eax
80102321:	50                   	push   %eax
80102322:	e8 56 29 00 00       	call   80104c7d <strncpy>
80102327:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010232a:	8b 45 10             	mov    0x10(%ebp),%eax
8010232d:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102334:	6a 10                	push   $0x10
80102336:	50                   	push   %eax
80102337:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233a:	50                   	push   %eax
8010233b:	ff 75 08             	push   0x8(%ebp)
8010233e:	e8 e9 fc ff ff       	call   8010202c <writei>
80102343:	83 c4 10             	add    $0x10,%esp
80102346:	83 f8 10             	cmp    $0x10,%eax
80102349:	74 0d                	je     80102358 <dirlink+0xd1>
    panic("dirlink");
8010234b:	83 ec 0c             	sub    $0xc,%esp
8010234e:	68 cf a4 10 80       	push   $0x8010a4cf
80102353:	e8 51 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102358:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235d:	c9                   	leave  
8010235e:	c3                   	ret    

8010235f <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235f:	55                   	push   %ebp
80102360:	89 e5                	mov    %esp,%ebp
80102362:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102365:	eb 04                	jmp    8010236b <skipelem+0xc>
    path++;
80102367:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	0f b6 00             	movzbl (%eax),%eax
80102371:	3c 2f                	cmp    $0x2f,%al
80102373:	74 f2                	je     80102367 <skipelem+0x8>
  if(*path == 0)
80102375:	8b 45 08             	mov    0x8(%ebp),%eax
80102378:	0f b6 00             	movzbl (%eax),%eax
8010237b:	84 c0                	test   %al,%al
8010237d:	75 07                	jne    80102386 <skipelem+0x27>
    return 0;
8010237f:	b8 00 00 00 00       	mov    $0x0,%eax
80102384:	eb 77                	jmp    801023fd <skipelem+0x9e>
  s = path;
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238c:	eb 04                	jmp    80102392 <skipelem+0x33>
    path++;
8010238e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102392:	8b 45 08             	mov    0x8(%ebp),%eax
80102395:	0f b6 00             	movzbl (%eax),%eax
80102398:	3c 2f                	cmp    $0x2f,%al
8010239a:	74 0a                	je     801023a6 <skipelem+0x47>
8010239c:	8b 45 08             	mov    0x8(%ebp),%eax
8010239f:	0f b6 00             	movzbl (%eax),%eax
801023a2:	84 c0                	test   %al,%al
801023a4:	75 e8                	jne    8010238e <skipelem+0x2f>
  len = path - s;
801023a6:	8b 45 08             	mov    0x8(%ebp),%eax
801023a9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023af:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b3:	7e 15                	jle    801023ca <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b5:	83 ec 04             	sub    $0x4,%esp
801023b8:	6a 0e                	push   $0xe
801023ba:	ff 75 f4             	push   -0xc(%ebp)
801023bd:	ff 75 0c             	push   0xc(%ebp)
801023c0:	e8 cc 27 00 00       	call   80104b91 <memmove>
801023c5:	83 c4 10             	add    $0x10,%esp
801023c8:	eb 26                	jmp    801023f0 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cd:	83 ec 04             	sub    $0x4,%esp
801023d0:	50                   	push   %eax
801023d1:	ff 75 f4             	push   -0xc(%ebp)
801023d4:	ff 75 0c             	push   0xc(%ebp)
801023d7:	e8 b5 27 00 00       	call   80104b91 <memmove>
801023dc:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e5:	01 d0                	add    %edx,%eax
801023e7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023ea:	eb 04                	jmp    801023f0 <skipelem+0x91>
    path++;
801023ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023f0:	8b 45 08             	mov    0x8(%ebp),%eax
801023f3:	0f b6 00             	movzbl (%eax),%eax
801023f6:	3c 2f                	cmp    $0x2f,%al
801023f8:	74 f2                	je     801023ec <skipelem+0x8d>
  return path;
801023fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fd:	c9                   	leave  
801023fe:	c3                   	ret    

801023ff <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023ff:	55                   	push   %ebp
80102400:	89 e5                	mov    %esp,%ebp
80102402:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102405:	8b 45 08             	mov    0x8(%ebp),%eax
80102408:	0f b6 00             	movzbl (%eax),%eax
8010240b:	3c 2f                	cmp    $0x2f,%al
8010240d:	75 17                	jne    80102426 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240f:	83 ec 08             	sub    $0x8,%esp
80102412:	6a 01                	push   $0x1
80102414:	6a 01                	push   $0x1
80102416:	e8 b4 f4 ff ff       	call   801018cf <iget>
8010241b:	83 c4 10             	add    $0x10,%esp
8010241e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102421:	e9 ba 00 00 00       	jmp    801024e0 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102426:	e8 06 16 00 00       	call   80103a31 <myproc>
8010242b:	8b 40 68             	mov    0x68(%eax),%eax
8010242e:	83 ec 0c             	sub    $0xc,%esp
80102431:	50                   	push   %eax
80102432:	e8 7a f5 ff ff       	call   801019b1 <idup>
80102437:	83 c4 10             	add    $0x10,%esp
8010243a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243d:	e9 9e 00 00 00       	jmp    801024e0 <namex+0xe1>
    ilock(ip);
80102442:	83 ec 0c             	sub    $0xc,%esp
80102445:	ff 75 f4             	push   -0xc(%ebp)
80102448:	e8 9e f5 ff ff       	call   801019eb <ilock>
8010244d:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102453:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102457:	66 83 f8 01          	cmp    $0x1,%ax
8010245b:	74 18                	je     80102475 <namex+0x76>
      iunlockput(ip);
8010245d:	83 ec 0c             	sub    $0xc,%esp
80102460:	ff 75 f4             	push   -0xc(%ebp)
80102463:	e8 b4 f7 ff ff       	call   80101c1c <iunlockput>
80102468:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246b:	b8 00 00 00 00       	mov    $0x0,%eax
80102470:	e9 a7 00 00 00       	jmp    8010251c <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102475:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102479:	74 20                	je     8010249b <namex+0x9c>
8010247b:	8b 45 08             	mov    0x8(%ebp),%eax
8010247e:	0f b6 00             	movzbl (%eax),%eax
80102481:	84 c0                	test   %al,%al
80102483:	75 16                	jne    8010249b <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102485:	83 ec 0c             	sub    $0xc,%esp
80102488:	ff 75 f4             	push   -0xc(%ebp)
8010248b:	e8 6e f6 ff ff       	call   80101afe <iunlock>
80102490:	83 c4 10             	add    $0x10,%esp
      return ip;
80102493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102496:	e9 81 00 00 00       	jmp    8010251c <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249b:	83 ec 04             	sub    $0x4,%esp
8010249e:	6a 00                	push   $0x0
801024a0:	ff 75 10             	push   0x10(%ebp)
801024a3:	ff 75 f4             	push   -0xc(%ebp)
801024a6:	e8 22 fd ff ff       	call   801021cd <dirlookup>
801024ab:	83 c4 10             	add    $0x10,%esp
801024ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b5:	75 15                	jne    801024cc <namex+0xcd>
      iunlockput(ip);
801024b7:	83 ec 0c             	sub    $0xc,%esp
801024ba:	ff 75 f4             	push   -0xc(%ebp)
801024bd:	e8 5a f7 ff ff       	call   80101c1c <iunlockput>
801024c2:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c5:	b8 00 00 00 00       	mov    $0x0,%eax
801024ca:	eb 50                	jmp    8010251c <namex+0x11d>
    }
    iunlockput(ip);
801024cc:	83 ec 0c             	sub    $0xc,%esp
801024cf:	ff 75 f4             	push   -0xc(%ebp)
801024d2:	e8 45 f7 ff ff       	call   80101c1c <iunlockput>
801024d7:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024e0:	83 ec 08             	sub    $0x8,%esp
801024e3:	ff 75 10             	push   0x10(%ebp)
801024e6:	ff 75 08             	push   0x8(%ebp)
801024e9:	e8 71 fe ff ff       	call   8010235f <skipelem>
801024ee:	83 c4 10             	add    $0x10,%esp
801024f1:	89 45 08             	mov    %eax,0x8(%ebp)
801024f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f8:	0f 85 44 ff ff ff    	jne    80102442 <namex+0x43>
  }
  if(nameiparent){
801024fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102502:	74 15                	je     80102519 <namex+0x11a>
    iput(ip);
80102504:	83 ec 0c             	sub    $0xc,%esp
80102507:	ff 75 f4             	push   -0xc(%ebp)
8010250a:	e8 3d f6 ff ff       	call   80101b4c <iput>
8010250f:	83 c4 10             	add    $0x10,%esp
    return 0;
80102512:	b8 00 00 00 00       	mov    $0x0,%eax
80102517:	eb 03                	jmp    8010251c <namex+0x11d>
  }
  return ip;
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251c:	c9                   	leave  
8010251d:	c3                   	ret    

8010251e <namei>:

struct inode*
namei(char *path)
{
8010251e:	55                   	push   %ebp
8010251f:	89 e5                	mov    %esp,%ebp
80102521:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102524:	83 ec 04             	sub    $0x4,%esp
80102527:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010252a:	50                   	push   %eax
8010252b:	6a 00                	push   $0x0
8010252d:	ff 75 08             	push   0x8(%ebp)
80102530:	e8 ca fe ff ff       	call   801023ff <namex>
80102535:	83 c4 10             	add    $0x10,%esp
}
80102538:	c9                   	leave  
80102539:	c3                   	ret    

8010253a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010253a:	55                   	push   %ebp
8010253b:	89 e5                	mov    %esp,%ebp
8010253d:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102540:	83 ec 04             	sub    $0x4,%esp
80102543:	ff 75 0c             	push   0xc(%ebp)
80102546:	6a 01                	push   $0x1
80102548:	ff 75 08             	push   0x8(%ebp)
8010254b:	e8 af fe ff ff       	call   801023ff <namex>
80102550:	83 c4 10             	add    $0x10,%esp
}
80102553:	c9                   	leave  
80102554:	c3                   	ret    

80102555 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102555:	55                   	push   %ebp
80102556:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102558:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255d:	8b 55 08             	mov    0x8(%ebp),%edx
80102560:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102562:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102567:	8b 40 10             	mov    0x10(%eax),%eax
}
8010256a:	5d                   	pop    %ebp
8010256b:	c3                   	ret    

8010256c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256c:	55                   	push   %ebp
8010256d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102574:	8b 55 08             	mov    0x8(%ebp),%edx
80102577:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102579:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102581:	89 50 10             	mov    %edx,0x10(%eax)
}
80102584:	90                   	nop
80102585:	5d                   	pop    %ebp
80102586:	c3                   	ret    

80102587 <ioapicinit>:

void
ioapicinit(void)
{
80102587:	55                   	push   %ebp
80102588:	89 e5                	mov    %esp,%ebp
8010258a:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258d:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102594:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102597:	6a 01                	push   $0x1
80102599:	e8 b7 ff ff ff       	call   80102555 <ioapicread>
8010259e:	83 c4 04             	add    $0x4,%esp
801025a1:	c1 e8 10             	shr    $0x10,%eax
801025a4:	25 ff 00 00 00       	and    $0xff,%eax
801025a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ac:	6a 00                	push   $0x0
801025ae:	e8 a2 ff ff ff       	call   80102555 <ioapicread>
801025b3:	83 c4 04             	add    $0x4,%esp
801025b6:	c1 e8 18             	shr    $0x18,%eax
801025b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bc:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801025c3:	0f b6 c0             	movzbl %al,%eax
801025c6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c9:	74 10                	je     801025db <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025cb:	83 ec 0c             	sub    $0xc,%esp
801025ce:	68 d8 a4 10 80       	push   $0x8010a4d8
801025d3:	e8 1c de ff ff       	call   801003f4 <cprintf>
801025d8:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e2:	eb 3f                	jmp    80102623 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e7:	83 c0 20             	add    $0x20,%eax
801025ea:	0d 00 00 01 00       	or     $0x10000,%eax
801025ef:	89 c2                	mov    %eax,%edx
801025f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f4:	83 c0 08             	add    $0x8,%eax
801025f7:	01 c0                	add    %eax,%eax
801025f9:	83 ec 08             	sub    $0x8,%esp
801025fc:	52                   	push   %edx
801025fd:	50                   	push   %eax
801025fe:	e8 69 ff ff ff       	call   8010256c <ioapicwrite>
80102603:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102609:	83 c0 08             	add    $0x8,%eax
8010260c:	01 c0                	add    %eax,%eax
8010260e:	83 c0 01             	add    $0x1,%eax
80102611:	83 ec 08             	sub    $0x8,%esp
80102614:	6a 00                	push   $0x0
80102616:	50                   	push   %eax
80102617:	e8 50 ff ff ff       	call   8010256c <ioapicwrite>
8010261c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102626:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102629:	7e b9                	jle    801025e4 <ioapicinit+0x5d>
  }
}
8010262b:	90                   	nop
8010262c:	90                   	nop
8010262d:	c9                   	leave  
8010262e:	c3                   	ret    

8010262f <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262f:	55                   	push   %ebp
80102630:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102632:	8b 45 08             	mov    0x8(%ebp),%eax
80102635:	83 c0 20             	add    $0x20,%eax
80102638:	89 c2                	mov    %eax,%edx
8010263a:	8b 45 08             	mov    0x8(%ebp),%eax
8010263d:	83 c0 08             	add    $0x8,%eax
80102640:	01 c0                	add    %eax,%eax
80102642:	52                   	push   %edx
80102643:	50                   	push   %eax
80102644:	e8 23 ff ff ff       	call   8010256c <ioapicwrite>
80102649:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264f:	c1 e0 18             	shl    $0x18,%eax
80102652:	89 c2                	mov    %eax,%edx
80102654:	8b 45 08             	mov    0x8(%ebp),%eax
80102657:	83 c0 08             	add    $0x8,%eax
8010265a:	01 c0                	add    %eax,%eax
8010265c:	83 c0 01             	add    $0x1,%eax
8010265f:	52                   	push   %edx
80102660:	50                   	push   %eax
80102661:	e8 06 ff ff ff       	call   8010256c <ioapicwrite>
80102666:	83 c4 08             	add    $0x8,%esp
}
80102669:	90                   	nop
8010266a:	c9                   	leave  
8010266b:	c3                   	ret    

8010266c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266c:	55                   	push   %ebp
8010266d:	89 e5                	mov    %esp,%ebp
8010266f:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102672:	83 ec 08             	sub    $0x8,%esp
80102675:	68 0a a5 10 80       	push   $0x8010a50a
8010267a:	68 c0 40 19 80       	push   $0x801940c0
8010267f:	e8 b6 21 00 00       	call   8010483a <initlock>
80102684:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102687:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268e:	00 00 00 
  freerange(vstart, vend);
80102691:	83 ec 08             	sub    $0x8,%esp
80102694:	ff 75 0c             	push   0xc(%ebp)
80102697:	ff 75 08             	push   0x8(%ebp)
8010269a:	e8 2a 00 00 00       	call   801026c9 <freerange>
8010269f:	83 c4 10             	add    $0x10,%esp
}
801026a2:	90                   	nop
801026a3:	c9                   	leave  
801026a4:	c3                   	ret    

801026a5 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a5:	55                   	push   %ebp
801026a6:	89 e5                	mov    %esp,%ebp
801026a8:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026ab:	83 ec 08             	sub    $0x8,%esp
801026ae:	ff 75 0c             	push   0xc(%ebp)
801026b1:	ff 75 08             	push   0x8(%ebp)
801026b4:	e8 10 00 00 00       	call   801026c9 <freerange>
801026b9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bc:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c3:	00 00 00 
}
801026c6:	90                   	nop
801026c7:	c9                   	leave  
801026c8:	c3                   	ret    

801026c9 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c9:	55                   	push   %ebp
801026ca:	89 e5                	mov    %esp,%ebp
801026cc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026cf:	8b 45 08             	mov    0x8(%ebp),%eax
801026d2:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026df:	eb 15                	jmp    801026f6 <freerange+0x2d>
    kfree(p);
801026e1:	83 ec 0c             	sub    $0xc,%esp
801026e4:	ff 75 f4             	push   -0xc(%ebp)
801026e7:	e8 1b 00 00 00       	call   80102707 <kfree>
801026ec:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ef:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f9:	05 00 10 00 00       	add    $0x1000,%eax
801026fe:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102701:	73 de                	jae    801026e1 <freerange+0x18>
}
80102703:	90                   	nop
80102704:	90                   	nop
80102705:	c9                   	leave  
80102706:	c3                   	ret    

80102707 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102707:	55                   	push   %ebp
80102708:	89 e5                	mov    %esp,%ebp
8010270a:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	25 ff 0f 00 00       	and    $0xfff,%eax
80102715:	85 c0                	test   %eax,%eax
80102717:	75 18                	jne    80102731 <kfree+0x2a>
80102719:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
80102720:	72 0f                	jb     80102731 <kfree+0x2a>
80102722:	8b 45 08             	mov    0x8(%ebp),%eax
80102725:	05 00 00 00 80       	add    $0x80000000,%eax
8010272a:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272f:	76 0d                	jbe    8010273e <kfree+0x37>
    panic("kfree");
80102731:	83 ec 0c             	sub    $0xc,%esp
80102734:	68 0f a5 10 80       	push   $0x8010a50f
80102739:	e8 6b de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273e:	83 ec 04             	sub    $0x4,%esp
80102741:	68 00 10 00 00       	push   $0x1000
80102746:	6a 01                	push   $0x1
80102748:	ff 75 08             	push   0x8(%ebp)
8010274b:	e8 82 23 00 00       	call   80104ad2 <memset>
80102750:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102753:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102758:	85 c0                	test   %eax,%eax
8010275a:	74 10                	je     8010276c <kfree+0x65>
    acquire(&kmem.lock);
8010275c:	83 ec 0c             	sub    $0xc,%esp
8010275f:	68 c0 40 19 80       	push   $0x801940c0
80102764:	e8 f3 20 00 00       	call   8010485c <acquire>
80102769:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276c:	8b 45 08             	mov    0x8(%ebp),%eax
8010276f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102772:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277b:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102780:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102785:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010278a:	85 c0                	test   %eax,%eax
8010278c:	74 10                	je     8010279e <kfree+0x97>
    release(&kmem.lock);
8010278e:	83 ec 0c             	sub    $0xc,%esp
80102791:	68 c0 40 19 80       	push   $0x801940c0
80102796:	e8 2f 21 00 00       	call   801048ca <release>
8010279b:	83 c4 10             	add    $0x10,%esp
}
8010279e:	90                   	nop
8010279f:	c9                   	leave  
801027a0:	c3                   	ret    

801027a1 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a1:	55                   	push   %ebp
801027a2:	89 e5                	mov    %esp,%ebp
801027a4:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ac:	85 c0                	test   %eax,%eax
801027ae:	74 10                	je     801027c0 <kalloc+0x1f>
    acquire(&kmem.lock);
801027b0:	83 ec 0c             	sub    $0xc,%esp
801027b3:	68 c0 40 19 80       	push   $0x801940c0
801027b8:	e8 9f 20 00 00       	call   8010485c <acquire>
801027bd:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027c0:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cc:	74 0a                	je     801027d8 <kalloc+0x37>
    kmem.freelist = r->next;
801027ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d1:	8b 00                	mov    (%eax),%eax
801027d3:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d8:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dd:	85 c0                	test   %eax,%eax
801027df:	74 10                	je     801027f1 <kalloc+0x50>
    release(&kmem.lock);
801027e1:	83 ec 0c             	sub    $0xc,%esp
801027e4:	68 c0 40 19 80       	push   $0x801940c0
801027e9:	e8 dc 20 00 00       	call   801048ca <release>
801027ee:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f4:	c9                   	leave  
801027f5:	c3                   	ret    

801027f6 <inb>:
{
801027f6:	55                   	push   %ebp
801027f7:	89 e5                	mov    %esp,%ebp
801027f9:	83 ec 14             	sub    $0x14,%esp
801027fc:	8b 45 08             	mov    0x8(%ebp),%eax
801027ff:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102803:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102807:	89 c2                	mov    %eax,%edx
80102809:	ec                   	in     (%dx),%al
8010280a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102811:	c9                   	leave  
80102812:	c3                   	ret    

80102813 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102813:	55                   	push   %ebp
80102814:	89 e5                	mov    %esp,%ebp
80102816:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102819:	6a 64                	push   $0x64
8010281b:	e8 d6 ff ff ff       	call   801027f6 <inb>
80102820:	83 c4 04             	add    $0x4,%esp
80102823:	0f b6 c0             	movzbl %al,%eax
80102826:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282c:	83 e0 01             	and    $0x1,%eax
8010282f:	85 c0                	test   %eax,%eax
80102831:	75 0a                	jne    8010283d <kbdgetc+0x2a>
    return -1;
80102833:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102838:	e9 23 01 00 00       	jmp    80102960 <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283d:	6a 60                	push   $0x60
8010283f:	e8 b2 ff ff ff       	call   801027f6 <inb>
80102844:	83 c4 04             	add    $0x4,%esp
80102847:	0f b6 c0             	movzbl %al,%eax
8010284a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102854:	75 17                	jne    8010286d <kbdgetc+0x5a>
    shift |= E0ESC;
80102856:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285b:	83 c8 40             	or     $0x40,%eax
8010285e:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102863:	b8 00 00 00 00       	mov    $0x0,%eax
80102868:	e9 f3 00 00 00       	jmp    80102960 <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102870:	25 80 00 00 00       	and    $0x80,%eax
80102875:	85 c0                	test   %eax,%eax
80102877:	74 45                	je     801028be <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102879:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287e:	83 e0 40             	and    $0x40,%eax
80102881:	85 c0                	test   %eax,%eax
80102883:	75 08                	jne    8010288d <kbdgetc+0x7a>
80102885:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102888:	83 e0 7f             	and    $0x7f,%eax
8010288b:	eb 03                	jmp    80102890 <kbdgetc+0x7d>
8010288d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102890:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102893:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102896:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289b:	0f b6 00             	movzbl (%eax),%eax
8010289e:	83 c8 40             	or     $0x40,%eax
801028a1:	0f b6 c0             	movzbl %al,%eax
801028a4:	f7 d0                	not    %eax
801028a6:	89 c2                	mov    %eax,%edx
801028a8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ad:	21 d0                	and    %edx,%eax
801028af:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b4:	b8 00 00 00 00       	mov    $0x0,%eax
801028b9:	e9 a2 00 00 00       	jmp    80102960 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028be:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c3:	83 e0 40             	and    $0x40,%eax
801028c6:	85 c0                	test   %eax,%eax
801028c8:	74 14                	je     801028de <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028ca:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d1:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d6:	83 e0 bf             	and    $0xffffffbf,%eax
801028d9:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e1:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e6:	0f b6 00             	movzbl (%eax),%eax
801028e9:	0f b6 d0             	movzbl %al,%edx
801028ec:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f1:	09 d0                	or     %edx,%eax
801028f3:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fb:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102900:	0f b6 00             	movzbl (%eax),%eax
80102903:	0f b6 d0             	movzbl %al,%edx
80102906:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290b:	31 d0                	xor    %edx,%eax
8010290d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102912:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102917:	83 e0 03             	and    $0x3,%eax
8010291a:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102921:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102924:	01 d0                	add    %edx,%eax
80102926:	0f b6 00             	movzbl (%eax),%eax
80102929:	0f b6 c0             	movzbl %al,%eax
8010292c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292f:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102934:	83 e0 08             	and    $0x8,%eax
80102937:	85 c0                	test   %eax,%eax
80102939:	74 22                	je     8010295d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293f:	76 0c                	jbe    8010294d <kbdgetc+0x13a>
80102941:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102945:	77 06                	ja     8010294d <kbdgetc+0x13a>
      c += 'A' - 'a';
80102947:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294b:	eb 10                	jmp    8010295d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102951:	76 0a                	jbe    8010295d <kbdgetc+0x14a>
80102953:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102957:	77 04                	ja     8010295d <kbdgetc+0x14a>
      c += 'a' - 'A';
80102959:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102960:	c9                   	leave  
80102961:	c3                   	ret    

80102962 <kbdintr>:

void
kbdintr(void)
{
80102962:	55                   	push   %ebp
80102963:	89 e5                	mov    %esp,%ebp
80102965:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102968:	83 ec 0c             	sub    $0xc,%esp
8010296b:	68 13 28 10 80       	push   $0x80102813
80102970:	e8 61 de ff ff       	call   801007d6 <consoleintr>
80102975:	83 c4 10             	add    $0x10,%esp
}
80102978:	90                   	nop
80102979:	c9                   	leave  
8010297a:	c3                   	ret    

8010297b <inb>:
{
8010297b:	55                   	push   %ebp
8010297c:	89 e5                	mov    %esp,%ebp
8010297e:	83 ec 14             	sub    $0x14,%esp
80102981:	8b 45 08             	mov    0x8(%ebp),%eax
80102984:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102988:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298c:	89 c2                	mov    %eax,%edx
8010298e:	ec                   	in     (%dx),%al
8010298f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102992:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102996:	c9                   	leave  
80102997:	c3                   	ret    

80102998 <outb>:
{
80102998:	55                   	push   %ebp
80102999:	89 e5                	mov    %esp,%ebp
8010299b:	83 ec 08             	sub    $0x8,%esp
8010299e:	8b 45 08             	mov    0x8(%ebp),%eax
801029a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a8:	89 d0                	mov    %edx,%eax
801029aa:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ad:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b5:	ee                   	out    %al,(%dx)
}
801029b6:	90                   	nop
801029b7:	c9                   	leave  
801029b8:	c3                   	ret    

801029b9 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b9:	55                   	push   %ebp
801029ba:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bc:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c2:	8b 45 08             	mov    0x8(%ebp),%eax
801029c5:	c1 e0 02             	shl    $0x2,%eax
801029c8:	01 c2                	add    %eax,%edx
801029ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029cf:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d4:	83 c0 20             	add    $0x20,%eax
801029d7:	8b 00                	mov    (%eax),%eax
}
801029d9:	90                   	nop
801029da:	5d                   	pop    %ebp
801029db:	c3                   	ret    

801029dc <lapicinit>:

void
lapicinit(void)
{
801029dc:	55                   	push   %ebp
801029dd:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029df:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e4:	85 c0                	test   %eax,%eax
801029e6:	0f 84 0c 01 00 00    	je     80102af8 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029ec:	68 3f 01 00 00       	push   $0x13f
801029f1:	6a 3c                	push   $0x3c
801029f3:	e8 c1 ff ff ff       	call   801029b9 <lapicw>
801029f8:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fb:	6a 0b                	push   $0xb
801029fd:	68 f8 00 00 00       	push   $0xf8
80102a02:	e8 b2 ff ff ff       	call   801029b9 <lapicw>
80102a07:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a0a:	68 20 00 02 00       	push   $0x20020
80102a0f:	68 c8 00 00 00       	push   $0xc8
80102a14:	e8 a0 ff ff ff       	call   801029b9 <lapicw>
80102a19:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1c:	68 80 96 98 00       	push   $0x989680
80102a21:	68 e0 00 00 00       	push   $0xe0
80102a26:	e8 8e ff ff ff       	call   801029b9 <lapicw>
80102a2b:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2e:	68 00 00 01 00       	push   $0x10000
80102a33:	68 d4 00 00 00       	push   $0xd4
80102a38:	e8 7c ff ff ff       	call   801029b9 <lapicw>
80102a3d:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a40:	68 00 00 01 00       	push   $0x10000
80102a45:	68 d8 00 00 00       	push   $0xd8
80102a4a:	e8 6a ff ff ff       	call   801029b9 <lapicw>
80102a4f:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a52:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a57:	83 c0 30             	add    $0x30,%eax
80102a5a:	8b 00                	mov    (%eax),%eax
80102a5c:	c1 e8 10             	shr    $0x10,%eax
80102a5f:	25 fc 00 00 00       	and    $0xfc,%eax
80102a64:	85 c0                	test   %eax,%eax
80102a66:	74 12                	je     80102a7a <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a68:	68 00 00 01 00       	push   $0x10000
80102a6d:	68 d0 00 00 00       	push   $0xd0
80102a72:	e8 42 ff ff ff       	call   801029b9 <lapicw>
80102a77:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a7a:	6a 33                	push   $0x33
80102a7c:	68 dc 00 00 00       	push   $0xdc
80102a81:	e8 33 ff ff ff       	call   801029b9 <lapicw>
80102a86:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a89:	6a 00                	push   $0x0
80102a8b:	68 a0 00 00 00       	push   $0xa0
80102a90:	e8 24 ff ff ff       	call   801029b9 <lapicw>
80102a95:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a98:	6a 00                	push   $0x0
80102a9a:	68 a0 00 00 00       	push   $0xa0
80102a9f:	e8 15 ff ff ff       	call   801029b9 <lapicw>
80102aa4:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa7:	6a 00                	push   $0x0
80102aa9:	6a 2c                	push   $0x2c
80102aab:	e8 09 ff ff ff       	call   801029b9 <lapicw>
80102ab0:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab3:	6a 00                	push   $0x0
80102ab5:	68 c4 00 00 00       	push   $0xc4
80102aba:	e8 fa fe ff ff       	call   801029b9 <lapicw>
80102abf:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac2:	68 00 85 08 00       	push   $0x88500
80102ac7:	68 c0 00 00 00       	push   $0xc0
80102acc:	e8 e8 fe ff ff       	call   801029b9 <lapicw>
80102ad1:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad4:	90                   	nop
80102ad5:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ada:	05 00 03 00 00       	add    $0x300,%eax
80102adf:	8b 00                	mov    (%eax),%eax
80102ae1:	25 00 10 00 00       	and    $0x1000,%eax
80102ae6:	85 c0                	test   %eax,%eax
80102ae8:	75 eb                	jne    80102ad5 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102aea:	6a 00                	push   $0x0
80102aec:	6a 20                	push   $0x20
80102aee:	e8 c6 fe ff ff       	call   801029b9 <lapicw>
80102af3:	83 c4 08             	add    $0x8,%esp
80102af6:	eb 01                	jmp    80102af9 <lapicinit+0x11d>
    return;
80102af8:	90                   	nop
}
80102af9:	c9                   	leave  
80102afa:	c3                   	ret    

80102afb <lapicid>:

int
lapicid(void)
{
80102afb:	55                   	push   %ebp
80102afc:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afe:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b03:	85 c0                	test   %eax,%eax
80102b05:	75 07                	jne    80102b0e <lapicid+0x13>
    return 0;
80102b07:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0c:	eb 0d                	jmp    80102b1b <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0e:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b13:	83 c0 20             	add    $0x20,%eax
80102b16:	8b 00                	mov    (%eax),%eax
80102b18:	c1 e8 18             	shr    $0x18,%eax
}
80102b1b:	5d                   	pop    %ebp
80102b1c:	c3                   	ret    

80102b1d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1d:	55                   	push   %ebp
80102b1e:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b20:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b25:	85 c0                	test   %eax,%eax
80102b27:	74 0c                	je     80102b35 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b29:	6a 00                	push   $0x0
80102b2b:	6a 2c                	push   $0x2c
80102b2d:	e8 87 fe ff ff       	call   801029b9 <lapicw>
80102b32:	83 c4 08             	add    $0x8,%esp
}
80102b35:	90                   	nop
80102b36:	c9                   	leave  
80102b37:	c3                   	ret    

80102b38 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b38:	55                   	push   %ebp
80102b39:	89 e5                	mov    %esp,%ebp
}
80102b3b:	90                   	nop
80102b3c:	5d                   	pop    %ebp
80102b3d:	c3                   	ret    

80102b3e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3e:	55                   	push   %ebp
80102b3f:	89 e5                	mov    %esp,%ebp
80102b41:	83 ec 14             	sub    $0x14,%esp
80102b44:	8b 45 08             	mov    0x8(%ebp),%eax
80102b47:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b4a:	6a 0f                	push   $0xf
80102b4c:	6a 70                	push   $0x70
80102b4e:	e8 45 fe ff ff       	call   80102998 <outb>
80102b53:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b56:	6a 0a                	push   $0xa
80102b58:	6a 71                	push   $0x71
80102b5a:	e8 39 fe ff ff       	call   80102998 <outb>
80102b5f:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b62:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b69:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6c:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b71:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b74:	c1 e8 04             	shr    $0x4,%eax
80102b77:	89 c2                	mov    %eax,%edx
80102b79:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7c:	83 c0 02             	add    $0x2,%eax
80102b7f:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b82:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b86:	c1 e0 18             	shl    $0x18,%eax
80102b89:	50                   	push   %eax
80102b8a:	68 c4 00 00 00       	push   $0xc4
80102b8f:	e8 25 fe ff ff       	call   801029b9 <lapicw>
80102b94:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b97:	68 00 c5 00 00       	push   $0xc500
80102b9c:	68 c0 00 00 00       	push   $0xc0
80102ba1:	e8 13 fe ff ff       	call   801029b9 <lapicw>
80102ba6:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba9:	68 c8 00 00 00       	push   $0xc8
80102bae:	e8 85 ff ff ff       	call   80102b38 <microdelay>
80102bb3:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb6:	68 00 85 00 00       	push   $0x8500
80102bbb:	68 c0 00 00 00       	push   $0xc0
80102bc0:	e8 f4 fd ff ff       	call   801029b9 <lapicw>
80102bc5:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc8:	6a 64                	push   $0x64
80102bca:	e8 69 ff ff ff       	call   80102b38 <microdelay>
80102bcf:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd9:	eb 3d                	jmp    80102c18 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bdb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bdf:	c1 e0 18             	shl    $0x18,%eax
80102be2:	50                   	push   %eax
80102be3:	68 c4 00 00 00       	push   $0xc4
80102be8:	e8 cc fd ff ff       	call   801029b9 <lapicw>
80102bed:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf3:	c1 e8 0c             	shr    $0xc,%eax
80102bf6:	80 cc 06             	or     $0x6,%ah
80102bf9:	50                   	push   %eax
80102bfa:	68 c0 00 00 00       	push   $0xc0
80102bff:	e8 b5 fd ff ff       	call   801029b9 <lapicw>
80102c04:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c07:	68 c8 00 00 00       	push   $0xc8
80102c0c:	e8 27 ff ff ff       	call   80102b38 <microdelay>
80102c11:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c14:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c18:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1c:	7e bd                	jle    80102bdb <lapicstartap+0x9d>
  }
}
80102c1e:	90                   	nop
80102c1f:	90                   	nop
80102c20:	c9                   	leave  
80102c21:	c3                   	ret    

80102c22 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c22:	55                   	push   %ebp
80102c23:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c25:	8b 45 08             	mov    0x8(%ebp),%eax
80102c28:	0f b6 c0             	movzbl %al,%eax
80102c2b:	50                   	push   %eax
80102c2c:	6a 70                	push   $0x70
80102c2e:	e8 65 fd ff ff       	call   80102998 <outb>
80102c33:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c36:	68 c8 00 00 00       	push   $0xc8
80102c3b:	e8 f8 fe ff ff       	call   80102b38 <microdelay>
80102c40:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c43:	6a 71                	push   $0x71
80102c45:	e8 31 fd ff ff       	call   8010297b <inb>
80102c4a:	83 c4 04             	add    $0x4,%esp
80102c4d:	0f b6 c0             	movzbl %al,%eax
}
80102c50:	c9                   	leave  
80102c51:	c3                   	ret    

80102c52 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c55:	6a 00                	push   $0x0
80102c57:	e8 c6 ff ff ff       	call   80102c22 <cmos_read>
80102c5c:	83 c4 04             	add    $0x4,%esp
80102c5f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c62:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c64:	6a 02                	push   $0x2
80102c66:	e8 b7 ff ff ff       	call   80102c22 <cmos_read>
80102c6b:	83 c4 04             	add    $0x4,%esp
80102c6e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c71:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c74:	6a 04                	push   $0x4
80102c76:	e8 a7 ff ff ff       	call   80102c22 <cmos_read>
80102c7b:	83 c4 04             	add    $0x4,%esp
80102c7e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c81:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c84:	6a 07                	push   $0x7
80102c86:	e8 97 ff ff ff       	call   80102c22 <cmos_read>
80102c8b:	83 c4 04             	add    $0x4,%esp
80102c8e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c91:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c94:	6a 08                	push   $0x8
80102c96:	e8 87 ff ff ff       	call   80102c22 <cmos_read>
80102c9b:	83 c4 04             	add    $0x4,%esp
80102c9e:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca1:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca4:	6a 09                	push   $0x9
80102ca6:	e8 77 ff ff ff       	call   80102c22 <cmos_read>
80102cab:	83 c4 04             	add    $0x4,%esp
80102cae:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb1:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb4:	90                   	nop
80102cb5:	c9                   	leave  
80102cb6:	c3                   	ret    

80102cb7 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb7:	55                   	push   %ebp
80102cb8:	89 e5                	mov    %esp,%ebp
80102cba:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbd:	6a 0b                	push   $0xb
80102cbf:	e8 5e ff ff ff       	call   80102c22 <cmos_read>
80102cc4:	83 c4 04             	add    $0x4,%esp
80102cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccd:	83 e0 04             	and    $0x4,%eax
80102cd0:	85 c0                	test   %eax,%eax
80102cd2:	0f 94 c0             	sete   %al
80102cd5:	0f b6 c0             	movzbl %al,%eax
80102cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cdb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cde:	50                   	push   %eax
80102cdf:	e8 6e ff ff ff       	call   80102c52 <fill_rtcdate>
80102ce4:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce7:	6a 0a                	push   $0xa
80102ce9:	e8 34 ff ff ff       	call   80102c22 <cmos_read>
80102cee:	83 c4 04             	add    $0x4,%esp
80102cf1:	25 80 00 00 00       	and    $0x80,%eax
80102cf6:	85 c0                	test   %eax,%eax
80102cf8:	75 27                	jne    80102d21 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cfa:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfd:	50                   	push   %eax
80102cfe:	e8 4f ff ff ff       	call   80102c52 <fill_rtcdate>
80102d03:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d06:	83 ec 04             	sub    $0x4,%esp
80102d09:	6a 18                	push   $0x18
80102d0b:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0e:	50                   	push   %eax
80102d0f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d12:	50                   	push   %eax
80102d13:	e8 21 1e 00 00       	call   80104b39 <memcmp>
80102d18:	83 c4 10             	add    $0x10,%esp
80102d1b:	85 c0                	test   %eax,%eax
80102d1d:	74 05                	je     80102d24 <cmostime+0x6d>
80102d1f:	eb ba                	jmp    80102cdb <cmostime+0x24>
        continue;
80102d21:	90                   	nop
    fill_rtcdate(&t1);
80102d22:	eb b7                	jmp    80102cdb <cmostime+0x24>
      break;
80102d24:	90                   	nop
  }

  // convert
  if(bcd) {
80102d25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d29:	0f 84 b4 00 00 00    	je     80102de3 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d32:	c1 e8 04             	shr    $0x4,%eax
80102d35:	89 c2                	mov    %eax,%edx
80102d37:	89 d0                	mov    %edx,%eax
80102d39:	c1 e0 02             	shl    $0x2,%eax
80102d3c:	01 d0                	add    %edx,%eax
80102d3e:	01 c0                	add    %eax,%eax
80102d40:	89 c2                	mov    %eax,%edx
80102d42:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d45:	83 e0 0f             	and    $0xf,%eax
80102d48:	01 d0                	add    %edx,%eax
80102d4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d50:	c1 e8 04             	shr    $0x4,%eax
80102d53:	89 c2                	mov    %eax,%edx
80102d55:	89 d0                	mov    %edx,%eax
80102d57:	c1 e0 02             	shl    $0x2,%eax
80102d5a:	01 d0                	add    %edx,%eax
80102d5c:	01 c0                	add    %eax,%eax
80102d5e:	89 c2                	mov    %eax,%edx
80102d60:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d63:	83 e0 0f             	and    $0xf,%eax
80102d66:	01 d0                	add    %edx,%eax
80102d68:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6e:	c1 e8 04             	shr    $0x4,%eax
80102d71:	89 c2                	mov    %eax,%edx
80102d73:	89 d0                	mov    %edx,%eax
80102d75:	c1 e0 02             	shl    $0x2,%eax
80102d78:	01 d0                	add    %edx,%eax
80102d7a:	01 c0                	add    %eax,%eax
80102d7c:	89 c2                	mov    %eax,%edx
80102d7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d81:	83 e0 0f             	and    $0xf,%eax
80102d84:	01 d0                	add    %edx,%eax
80102d86:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8c:	c1 e8 04             	shr    $0x4,%eax
80102d8f:	89 c2                	mov    %eax,%edx
80102d91:	89 d0                	mov    %edx,%eax
80102d93:	c1 e0 02             	shl    $0x2,%eax
80102d96:	01 d0                	add    %edx,%eax
80102d98:	01 c0                	add    %eax,%eax
80102d9a:	89 c2                	mov    %eax,%edx
80102d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9f:	83 e0 0f             	and    $0xf,%eax
80102da2:	01 d0                	add    %edx,%eax
80102da4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102daa:	c1 e8 04             	shr    $0x4,%eax
80102dad:	89 c2                	mov    %eax,%edx
80102daf:	89 d0                	mov    %edx,%eax
80102db1:	c1 e0 02             	shl    $0x2,%eax
80102db4:	01 d0                	add    %edx,%eax
80102db6:	01 c0                	add    %eax,%eax
80102db8:	89 c2                	mov    %eax,%edx
80102dba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbd:	83 e0 0f             	and    $0xf,%eax
80102dc0:	01 d0                	add    %edx,%eax
80102dc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc8:	c1 e8 04             	shr    $0x4,%eax
80102dcb:	89 c2                	mov    %eax,%edx
80102dcd:	89 d0                	mov    %edx,%eax
80102dcf:	c1 e0 02             	shl    $0x2,%eax
80102dd2:	01 d0                	add    %edx,%eax
80102dd4:	01 c0                	add    %eax,%eax
80102dd6:	89 c2                	mov    %eax,%edx
80102dd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ddb:	83 e0 0f             	and    $0xf,%eax
80102dde:	01 d0                	add    %edx,%eax
80102de0:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de3:	8b 45 08             	mov    0x8(%ebp),%eax
80102de6:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de9:	89 10                	mov    %edx,(%eax)
80102deb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102dee:	89 50 04             	mov    %edx,0x4(%eax)
80102df1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df4:	89 50 08             	mov    %edx,0x8(%eax)
80102df7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dfa:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfd:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e00:	89 50 10             	mov    %edx,0x10(%eax)
80102e03:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e06:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e09:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0c:	8b 40 14             	mov    0x14(%eax),%eax
80102e0f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e15:	8b 45 08             	mov    0x8(%ebp),%eax
80102e18:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1b:	90                   	nop
80102e1c:	c9                   	leave  
80102e1d:	c3                   	ret    

80102e1e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1e:	55                   	push   %ebp
80102e1f:	89 e5                	mov    %esp,%ebp
80102e21:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e24:	83 ec 08             	sub    $0x8,%esp
80102e27:	68 15 a5 10 80       	push   $0x8010a515
80102e2c:	68 20 41 19 80       	push   $0x80194120
80102e31:	e8 04 1a 00 00       	call   8010483a <initlock>
80102e36:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e39:	83 ec 08             	sub    $0x8,%esp
80102e3c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3f:	50                   	push   %eax
80102e40:	ff 75 08             	push   0x8(%ebp)
80102e43:	e8 87 e5 ff ff       	call   801013cf <readsb>
80102e48:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4e:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e53:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e56:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5e:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e63:	e8 b3 01 00 00       	call   8010301b <recover_from_log>
}
80102e68:	90                   	nop
80102e69:	c9                   	leave  
80102e6a:	c3                   	ret    

80102e6b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6b:	55                   	push   %ebp
80102e6c:	89 e5                	mov    %esp,%ebp
80102e6e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e78:	e9 95 00 00 00       	jmp    80102f12 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7d:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e86:	01 d0                	add    %edx,%eax
80102e88:	83 c0 01             	add    $0x1,%eax
80102e8b:	89 c2                	mov    %eax,%edx
80102e8d:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e92:	83 ec 08             	sub    $0x8,%esp
80102e95:	52                   	push   %edx
80102e96:	50                   	push   %eax
80102e97:	e8 65 d3 ff ff       	call   80100201 <bread>
80102e9c:	83 c4 10             	add    $0x10,%esp
80102e9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea5:	83 c0 10             	add    $0x10,%eax
80102ea8:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eaf:	89 c2                	mov    %eax,%edx
80102eb1:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb6:	83 ec 08             	sub    $0x8,%esp
80102eb9:	52                   	push   %edx
80102eba:	50                   	push   %eax
80102ebb:	e8 41 d3 ff ff       	call   80100201 <bread>
80102ec0:	83 c4 10             	add    $0x10,%esp
80102ec3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec9:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ecf:	83 c0 5c             	add    $0x5c,%eax
80102ed2:	83 ec 04             	sub    $0x4,%esp
80102ed5:	68 00 02 00 00       	push   $0x200
80102eda:	52                   	push   %edx
80102edb:	50                   	push   %eax
80102edc:	e8 b0 1c 00 00       	call   80104b91 <memmove>
80102ee1:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee4:	83 ec 0c             	sub    $0xc,%esp
80102ee7:	ff 75 ec             	push   -0x14(%ebp)
80102eea:	e8 4b d3 ff ff       	call   8010023a <bwrite>
80102eef:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef2:	83 ec 0c             	sub    $0xc,%esp
80102ef5:	ff 75 f0             	push   -0x10(%ebp)
80102ef8:	e8 86 d3 ff ff       	call   80100283 <brelse>
80102efd:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f00:	83 ec 0c             	sub    $0xc,%esp
80102f03:	ff 75 ec             	push   -0x14(%ebp)
80102f06:	e8 78 d3 ff ff       	call   80100283 <brelse>
80102f0b:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f12:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f17:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f1a:	0f 8c 5d ff ff ff    	jl     80102e7d <install_trans+0x12>
  }
}
80102f20:	90                   	nop
80102f21:	90                   	nop
80102f22:	c9                   	leave  
80102f23:	c3                   	ret    

80102f24 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f24:	55                   	push   %ebp
80102f25:	89 e5                	mov    %esp,%ebp
80102f27:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f2a:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2f:	89 c2                	mov    %eax,%edx
80102f31:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f36:	83 ec 08             	sub    $0x8,%esp
80102f39:	52                   	push   %edx
80102f3a:	50                   	push   %eax
80102f3b:	e8 c1 d2 ff ff       	call   80100201 <bread>
80102f40:	83 c4 10             	add    $0x10,%esp
80102f43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f49:	83 c0 5c             	add    $0x5c,%eax
80102f4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f52:	8b 00                	mov    (%eax),%eax
80102f54:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f60:	eb 1b                	jmp    80102f7d <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f68:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6f:	83 c2 10             	add    $0x10,%edx
80102f72:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7d:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f82:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f85:	7c db                	jl     80102f62 <read_head+0x3e>
  }
  brelse(buf);
80102f87:	83 ec 0c             	sub    $0xc,%esp
80102f8a:	ff 75 f0             	push   -0x10(%ebp)
80102f8d:	e8 f1 d2 ff ff       	call   80100283 <brelse>
80102f92:	83 c4 10             	add    $0x10,%esp
}
80102f95:	90                   	nop
80102f96:	c9                   	leave  
80102f97:	c3                   	ret    

80102f98 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f98:	55                   	push   %ebp
80102f99:	89 e5                	mov    %esp,%ebp
80102f9b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9e:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa3:	89 c2                	mov    %eax,%edx
80102fa5:	a1 64 41 19 80       	mov    0x80194164,%eax
80102faa:	83 ec 08             	sub    $0x8,%esp
80102fad:	52                   	push   %edx
80102fae:	50                   	push   %eax
80102faf:	e8 4d d2 ff ff       	call   80100201 <bread>
80102fb4:	83 c4 10             	add    $0x10,%esp
80102fb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbd:	83 c0 5c             	add    $0x5c,%eax
80102fc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc3:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd5:	eb 1b                	jmp    80102ff2 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fda:	83 c0 10             	add    $0x10,%eax
80102fdd:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fea:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff2:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ffa:	7c db                	jl     80102fd7 <write_head+0x3f>
  }
  bwrite(buf);
80102ffc:	83 ec 0c             	sub    $0xc,%esp
80102fff:	ff 75 f0             	push   -0x10(%ebp)
80103002:	e8 33 d2 ff ff       	call   8010023a <bwrite>
80103007:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010300a:	83 ec 0c             	sub    $0xc,%esp
8010300d:	ff 75 f0             	push   -0x10(%ebp)
80103010:	e8 6e d2 ff ff       	call   80100283 <brelse>
80103015:	83 c4 10             	add    $0x10,%esp
}
80103018:	90                   	nop
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <recover_from_log>:

static void
recover_from_log(void)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
8010301e:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103021:	e8 fe fe ff ff       	call   80102f24 <read_head>
  install_trans(); // if committed, copy from log to disk
80103026:	e8 40 fe ff ff       	call   80102e6b <install_trans>
  log.lh.n = 0;
8010302b:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103032:	00 00 00 
  write_head(); // clear the log
80103035:	e8 5e ff ff ff       	call   80102f98 <write_head>
}
8010303a:	90                   	nop
8010303b:	c9                   	leave  
8010303c:	c3                   	ret    

8010303d <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303d:	55                   	push   %ebp
8010303e:	89 e5                	mov    %esp,%ebp
80103040:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103043:	83 ec 0c             	sub    $0xc,%esp
80103046:	68 20 41 19 80       	push   $0x80194120
8010304b:	e8 0c 18 00 00       	call   8010485c <acquire>
80103050:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103053:	a1 60 41 19 80       	mov    0x80194160,%eax
80103058:	85 c0                	test   %eax,%eax
8010305a:	74 17                	je     80103073 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305c:	83 ec 08             	sub    $0x8,%esp
8010305f:	68 20 41 19 80       	push   $0x80194120
80103064:	68 20 41 19 80       	push   $0x80194120
80103069:	e8 81 12 00 00       	call   801042ef <sleep>
8010306e:	83 c4 10             	add    $0x10,%esp
80103071:	eb e0                	jmp    80103053 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103073:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103079:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307e:	8d 50 01             	lea    0x1(%eax),%edx
80103081:	89 d0                	mov    %edx,%eax
80103083:	c1 e0 02             	shl    $0x2,%eax
80103086:	01 d0                	add    %edx,%eax
80103088:	01 c0                	add    %eax,%eax
8010308a:	01 c8                	add    %ecx,%eax
8010308c:	83 f8 1e             	cmp    $0x1e,%eax
8010308f:	7e 17                	jle    801030a8 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103091:	83 ec 08             	sub    $0x8,%esp
80103094:	68 20 41 19 80       	push   $0x80194120
80103099:	68 20 41 19 80       	push   $0x80194120
8010309e:	e8 4c 12 00 00       	call   801042ef <sleep>
801030a3:	83 c4 10             	add    $0x10,%esp
801030a6:	eb ab                	jmp    80103053 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a8:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ad:	83 c0 01             	add    $0x1,%eax
801030b0:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b5:	83 ec 0c             	sub    $0xc,%esp
801030b8:	68 20 41 19 80       	push   $0x80194120
801030bd:	e8 08 18 00 00       	call   801048ca <release>
801030c2:	83 c4 10             	add    $0x10,%esp
      break;
801030c5:	90                   	nop
    }
  }
}
801030c6:	90                   	nop
801030c7:	c9                   	leave  
801030c8:	c3                   	ret    

801030c9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c9:	55                   	push   %ebp
801030ca:	89 e5                	mov    %esp,%ebp
801030cc:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d6:	83 ec 0c             	sub    $0xc,%esp
801030d9:	68 20 41 19 80       	push   $0x80194120
801030de:	e8 79 17 00 00       	call   8010485c <acquire>
801030e3:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030eb:	83 e8 01             	sub    $0x1,%eax
801030ee:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f3:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f8:	85 c0                	test   %eax,%eax
801030fa:	74 0d                	je     80103109 <end_op+0x40>
    panic("log.committing");
801030fc:	83 ec 0c             	sub    $0xc,%esp
801030ff:	68 19 a5 10 80       	push   $0x8010a519
80103104:	e8 a0 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103109:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310e:	85 c0                	test   %eax,%eax
80103110:	75 13                	jne    80103125 <end_op+0x5c>
    do_commit = 1;
80103112:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103119:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103120:	00 00 00 
80103123:	eb 10                	jmp    80103135 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103125:	83 ec 0c             	sub    $0xc,%esp
80103128:	68 20 41 19 80       	push   $0x80194120
8010312d:	e8 a4 12 00 00       	call   801043d6 <wakeup>
80103132:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103135:	83 ec 0c             	sub    $0xc,%esp
80103138:	68 20 41 19 80       	push   $0x80194120
8010313d:	e8 88 17 00 00       	call   801048ca <release>
80103142:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103145:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103149:	74 3f                	je     8010318a <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314b:	e8 f6 00 00 00       	call   80103246 <commit>
    acquire(&log.lock);
80103150:	83 ec 0c             	sub    $0xc,%esp
80103153:	68 20 41 19 80       	push   $0x80194120
80103158:	e8 ff 16 00 00       	call   8010485c <acquire>
8010315d:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103160:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103167:	00 00 00 
    wakeup(&log);
8010316a:	83 ec 0c             	sub    $0xc,%esp
8010316d:	68 20 41 19 80       	push   $0x80194120
80103172:	e8 5f 12 00 00       	call   801043d6 <wakeup>
80103177:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317a:	83 ec 0c             	sub    $0xc,%esp
8010317d:	68 20 41 19 80       	push   $0x80194120
80103182:	e8 43 17 00 00       	call   801048ca <release>
80103187:	83 c4 10             	add    $0x10,%esp
  }
}
8010318a:	90                   	nop
8010318b:	c9                   	leave  
8010318c:	c3                   	ret    

8010318d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318d:	55                   	push   %ebp
8010318e:	89 e5                	mov    %esp,%ebp
80103190:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319a:	e9 95 00 00 00       	jmp    80103234 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319f:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a8:	01 d0                	add    %edx,%eax
801031aa:	83 c0 01             	add    $0x1,%eax
801031ad:	89 c2                	mov    %eax,%edx
801031af:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b4:	83 ec 08             	sub    $0x8,%esp
801031b7:	52                   	push   %edx
801031b8:	50                   	push   %eax
801031b9:	e8 43 d0 ff ff       	call   80100201 <bread>
801031be:	83 c4 10             	add    $0x10,%esp
801031c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c7:	83 c0 10             	add    $0x10,%eax
801031ca:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d1:	89 c2                	mov    %eax,%edx
801031d3:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d8:	83 ec 08             	sub    $0x8,%esp
801031db:	52                   	push   %edx
801031dc:	50                   	push   %eax
801031dd:	e8 1f d0 ff ff       	call   80100201 <bread>
801031e2:	83 c4 10             	add    $0x10,%esp
801031e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031eb:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f1:	83 c0 5c             	add    $0x5c,%eax
801031f4:	83 ec 04             	sub    $0x4,%esp
801031f7:	68 00 02 00 00       	push   $0x200
801031fc:	52                   	push   %edx
801031fd:	50                   	push   %eax
801031fe:	e8 8e 19 00 00       	call   80104b91 <memmove>
80103203:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103206:	83 ec 0c             	sub    $0xc,%esp
80103209:	ff 75 f0             	push   -0x10(%ebp)
8010320c:	e8 29 d0 ff ff       	call   8010023a <bwrite>
80103211:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103214:	83 ec 0c             	sub    $0xc,%esp
80103217:	ff 75 ec             	push   -0x14(%ebp)
8010321a:	e8 64 d0 ff ff       	call   80100283 <brelse>
8010321f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103222:	83 ec 0c             	sub    $0xc,%esp
80103225:	ff 75 f0             	push   -0x10(%ebp)
80103228:	e8 56 d0 ff ff       	call   80100283 <brelse>
8010322d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103230:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103234:	a1 68 41 19 80       	mov    0x80194168,%eax
80103239:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323c:	0f 8c 5d ff ff ff    	jl     8010319f <write_log+0x12>
  }
}
80103242:	90                   	nop
80103243:	90                   	nop
80103244:	c9                   	leave  
80103245:	c3                   	ret    

80103246 <commit>:

static void
commit()
{
80103246:	55                   	push   %ebp
80103247:	89 e5                	mov    %esp,%ebp
80103249:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103251:	85 c0                	test   %eax,%eax
80103253:	7e 1e                	jle    80103273 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103255:	e8 33 ff ff ff       	call   8010318d <write_log>
    write_head();    // Write header to disk -- the real commit
8010325a:	e8 39 fd ff ff       	call   80102f98 <write_head>
    install_trans(); // Now install writes to home locations
8010325f:	e8 07 fc ff ff       	call   80102e6b <install_trans>
    log.lh.n = 0;
80103264:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326b:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326e:	e8 25 fd ff ff       	call   80102f98 <write_head>
  }
}
80103273:	90                   	nop
80103274:	c9                   	leave  
80103275:	c3                   	ret    

80103276 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103276:	55                   	push   %ebp
80103277:	89 e5                	mov    %esp,%ebp
80103279:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103281:	83 f8 1d             	cmp    $0x1d,%eax
80103284:	7f 12                	jg     80103298 <log_write+0x22>
80103286:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328b:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103291:	83 ea 01             	sub    $0x1,%edx
80103294:	39 d0                	cmp    %edx,%eax
80103296:	7c 0d                	jl     801032a5 <log_write+0x2f>
    panic("too big a transaction");
80103298:	83 ec 0c             	sub    $0xc,%esp
8010329b:	68 28 a5 10 80       	push   $0x8010a528
801032a0:	e8 04 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032aa:	85 c0                	test   %eax,%eax
801032ac:	7f 0d                	jg     801032bb <log_write+0x45>
    panic("log_write outside of trans");
801032ae:	83 ec 0c             	sub    $0xc,%esp
801032b1:	68 3e a5 10 80       	push   $0x8010a53e
801032b6:	e8 ee d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bb:	83 ec 0c             	sub    $0xc,%esp
801032be:	68 20 41 19 80       	push   $0x80194120
801032c3:	e8 94 15 00 00       	call   8010485c <acquire>
801032c8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d2:	eb 1d                	jmp    801032f1 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d7:	83 c0 10             	add    $0x10,%eax
801032da:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e1:	89 c2                	mov    %eax,%edx
801032e3:	8b 45 08             	mov    0x8(%ebp),%eax
801032e6:	8b 40 08             	mov    0x8(%eax),%eax
801032e9:	39 c2                	cmp    %eax,%edx
801032eb:	74 10                	je     801032fd <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f1:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f9:	7c d9                	jl     801032d4 <log_write+0x5e>
801032fb:	eb 01                	jmp    801032fe <log_write+0x88>
      break;
801032fd:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103301:	8b 40 08             	mov    0x8(%eax),%eax
80103304:	89 c2                	mov    %eax,%edx
80103306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103309:	83 c0 10             	add    $0x10,%eax
8010330c:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103313:	a1 68 41 19 80       	mov    0x80194168,%eax
80103318:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331b:	75 0d                	jne    8010332a <log_write+0xb4>
    log.lh.n++;
8010331d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103322:	83 c0 01             	add    $0x1,%eax
80103325:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010332a:	8b 45 08             	mov    0x8(%ebp),%eax
8010332d:	8b 00                	mov    (%eax),%eax
8010332f:	83 c8 04             	or     $0x4,%eax
80103332:	89 c2                	mov    %eax,%edx
80103334:	8b 45 08             	mov    0x8(%ebp),%eax
80103337:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103339:	83 ec 0c             	sub    $0xc,%esp
8010333c:	68 20 41 19 80       	push   $0x80194120
80103341:	e8 84 15 00 00       	call   801048ca <release>
80103346:	83 c4 10             	add    $0x10,%esp
}
80103349:	90                   	nop
8010334a:	c9                   	leave  
8010334b:	c3                   	ret    

8010334c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334c:	55                   	push   %ebp
8010334d:	89 e5                	mov    %esp,%ebp
8010334f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103352:	8b 55 08             	mov    0x8(%ebp),%edx
80103355:	8b 45 0c             	mov    0xc(%ebp),%eax
80103358:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335b:	f0 87 02             	lock xchg %eax,(%edx)
8010335e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103361:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103364:	c9                   	leave  
80103365:	c3                   	ret    

80103366 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103366:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010336a:	83 e4 f0             	and    $0xfffffff0,%esp
8010336d:	ff 71 fc             	push   -0x4(%ecx)
80103370:	55                   	push   %ebp
80103371:	89 e5                	mov    %esp,%ebp
80103373:	51                   	push   %ecx
80103374:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103377:	e8 fa 4c 00 00       	call   80108076 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337c:	83 ec 08             	sub    $0x8,%esp
8010337f:	68 00 00 40 80       	push   $0x80400000
80103384:	68 00 80 19 80       	push   $0x80198000
80103389:	e8 de f2 ff ff       	call   8010266c <kinit1>
8010338e:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103391:	e8 0e 43 00 00       	call   801076a4 <kvmalloc>
  mpinit_uefi();
80103396:	e8 a1 4a 00 00       	call   80107e3c <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339b:	e8 3c f6 ff ff       	call   801029dc <lapicinit>
  seginit();       // segment descriptors
801033a0:	e8 97 3d 00 00       	call   8010713c <seginit>
  picinit();    // disable pic
801033a5:	e8 9d 01 00 00       	call   80103547 <picinit>
  ioapicinit();    // another interrupt controller
801033aa:	e8 d8 f1 ff ff       	call   80102587 <ioapicinit>
  consoleinit();   // console hardware
801033af:	e8 4b d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b4:	e8 1c 31 00 00       	call   801064d5 <uartinit>
  pinit();         // process table
801033b9:	e8 c2 05 00 00       	call   80103980 <pinit>
  tvinit();        // trap vectors
801033be:	e8 0c 2b 00 00       	call   80105ecf <tvinit>
  binit();         // buffer cache
801033c3:	e8 9e cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c8:	e8 f3 db ff ff       	call   80100fc0 <fileinit>
  ideinit();       // disk 
801033cd:	e8 e5 6d 00 00       	call   8010a1b7 <ideinit>
  startothers();   // start other processors
801033d2:	e8 8a 00 00 00       	call   80103461 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d7:	83 ec 08             	sub    $0x8,%esp
801033da:	68 00 00 00 a0       	push   $0xa0000000
801033df:	68 00 00 40 80       	push   $0x80400000
801033e4:	e8 bc f2 ff ff       	call   801026a5 <kinit2>
801033e9:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ec:	e8 de 4e 00 00       	call   801082cf <pci_init>
  arp_scan();
801033f1:	e8 15 5c 00 00       	call   8010900b <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f6:	e8 63 07 00 00       	call   80103b5e <userinit>

  mpmain();        // finish this processor's setup
801033fb:	e8 1a 00 00 00       	call   8010341a <mpmain>

80103400 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103400:	55                   	push   %ebp
80103401:	89 e5                	mov    %esp,%ebp
80103403:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103406:	e8 b1 42 00 00       	call   801076bc <switchkvm>
  seginit();
8010340b:	e8 2c 3d 00 00       	call   8010713c <seginit>
  lapicinit();
80103410:	e8 c7 f5 ff ff       	call   801029dc <lapicinit>
  mpmain();
80103415:	e8 00 00 00 00       	call   8010341a <mpmain>

8010341a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010341a:	55                   	push   %ebp
8010341b:	89 e5                	mov    %esp,%ebp
8010341d:	53                   	push   %ebx
8010341e:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103421:	e8 78 05 00 00       	call   8010399e <cpuid>
80103426:	89 c3                	mov    %eax,%ebx
80103428:	e8 71 05 00 00       	call   8010399e <cpuid>
8010342d:	83 ec 04             	sub    $0x4,%esp
80103430:	53                   	push   %ebx
80103431:	50                   	push   %eax
80103432:	68 59 a5 10 80       	push   $0x8010a559
80103437:	e8 b8 cf ff ff       	call   801003f4 <cprintf>
8010343c:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343f:	e8 01 2c 00 00       	call   80106045 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103444:	e8 70 05 00 00       	call   801039b9 <mycpu>
80103449:	05 a0 00 00 00       	add    $0xa0,%eax
8010344e:	83 ec 08             	sub    $0x8,%esp
80103451:	6a 01                	push   $0x1
80103453:	50                   	push   %eax
80103454:	e8 f3 fe ff ff       	call   8010334c <xchg>
80103459:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345c:	e8 9d 0c 00 00       	call   801040fe <scheduler>

80103461 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103461:	55                   	push   %ebp
80103462:	89 e5                	mov    %esp,%ebp
80103464:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103467:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103473:	83 ec 04             	sub    $0x4,%esp
80103476:	50                   	push   %eax
80103477:	68 18 f5 10 80       	push   $0x8010f518
8010347c:	ff 75 f0             	push   -0x10(%ebp)
8010347f:	e8 0d 17 00 00       	call   80104b91 <memmove>
80103484:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103487:	c7 45 f4 80 69 19 80 	movl   $0x80196980,-0xc(%ebp)
8010348e:	eb 79                	jmp    80103509 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103490:	e8 24 05 00 00       	call   801039b9 <mycpu>
80103495:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103498:	74 67                	je     80103501 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010349a:	e8 02 f3 ff ff       	call   801027a1 <kalloc>
8010349f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a5:	83 e8 04             	sub    $0x4,%eax
801034a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ab:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b1:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b6:	83 e8 08             	sub    $0x8,%eax
801034b9:	c7 00 00 34 10 80    	movl   $0x80103400,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034bf:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cd:	83 e8 0c             	sub    $0xc,%eax
801034d0:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034de:	0f b6 00             	movzbl (%eax),%eax
801034e1:	0f b6 c0             	movzbl %al,%eax
801034e4:	83 ec 08             	sub    $0x8,%esp
801034e7:	52                   	push   %edx
801034e8:	50                   	push   %eax
801034e9:	e8 50 f6 ff ff       	call   80102b3e <lapicstartap>
801034ee:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f1:	90                   	nop
801034f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fb:	85 c0                	test   %eax,%eax
801034fd:	74 f3                	je     801034f2 <startothers+0x91>
801034ff:	eb 01                	jmp    80103502 <startothers+0xa1>
      continue;
80103501:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103502:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103509:	a1 40 6c 19 80       	mov    0x80196c40,%eax
8010350e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103514:	05 80 69 19 80       	add    $0x80196980,%eax
80103519:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351c:	0f 82 6e ff ff ff    	jb     80103490 <startothers+0x2f>
      ;
  }
}
80103522:	90                   	nop
80103523:	90                   	nop
80103524:	c9                   	leave  
80103525:	c3                   	ret    

80103526 <outb>:
{
80103526:	55                   	push   %ebp
80103527:	89 e5                	mov    %esp,%ebp
80103529:	83 ec 08             	sub    $0x8,%esp
8010352c:	8b 45 08             	mov    0x8(%ebp),%eax
8010352f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103532:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103536:	89 d0                	mov    %edx,%eax
80103538:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103543:	ee                   	out    %al,(%dx)
}
80103544:	90                   	nop
80103545:	c9                   	leave  
80103546:	c3                   	ret    

80103547 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103547:	55                   	push   %ebp
80103548:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010354a:	68 ff 00 00 00       	push   $0xff
8010354f:	6a 21                	push   $0x21
80103551:	e8 d0 ff ff ff       	call   80103526 <outb>
80103556:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103559:	68 ff 00 00 00       	push   $0xff
8010355e:	68 a1 00 00 00       	push   $0xa1
80103563:	e8 be ff ff ff       	call   80103526 <outb>
80103568:	83 c4 08             	add    $0x8,%esp
}
8010356b:	90                   	nop
8010356c:	c9                   	leave  
8010356d:	c3                   	ret    

8010356e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356e:	55                   	push   %ebp
8010356f:	89 e5                	mov    %esp,%ebp
80103571:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103574:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103584:	8b 45 0c             	mov    0xc(%ebp),%eax
80103587:	8b 10                	mov    (%eax),%edx
80103589:	8b 45 08             	mov    0x8(%ebp),%eax
8010358c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358e:	e8 4b da ff ff       	call   80100fde <filealloc>
80103593:	8b 55 08             	mov    0x8(%ebp),%edx
80103596:	89 02                	mov    %eax,(%edx)
80103598:	8b 45 08             	mov    0x8(%ebp),%eax
8010359b:	8b 00                	mov    (%eax),%eax
8010359d:	85 c0                	test   %eax,%eax
8010359f:	0f 84 c8 00 00 00    	je     8010366d <pipealloc+0xff>
801035a5:	e8 34 da ff ff       	call   80100fde <filealloc>
801035aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ad:	89 02                	mov    %eax,(%edx)
801035af:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b2:	8b 00                	mov    (%eax),%eax
801035b4:	85 c0                	test   %eax,%eax
801035b6:	0f 84 b1 00 00 00    	je     8010366d <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bc:	e8 e0 f1 ff ff       	call   801027a1 <kalloc>
801035c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c8:	0f 84 a2 00 00 00    	je     80103670 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d1:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d8:	00 00 00 
  p->writeopen = 1;
801035db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035de:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e5:	00 00 00 
  p->nwrite = 0;
801035e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035eb:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f2:	00 00 00 
  p->nread = 0;
801035f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f8:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035ff:	00 00 00 
  initlock(&p->lock, "pipe");
80103602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103605:	83 ec 08             	sub    $0x8,%esp
80103608:	68 6d a5 10 80       	push   $0x8010a56d
8010360d:	50                   	push   %eax
8010360e:	e8 27 12 00 00       	call   8010483a <initlock>
80103613:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103616:	8b 45 08             	mov    0x8(%ebp),%eax
80103619:	8b 00                	mov    (%eax),%eax
8010361b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103621:	8b 45 08             	mov    0x8(%ebp),%eax
80103624:	8b 00                	mov    (%eax),%eax
80103626:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010362a:	8b 45 08             	mov    0x8(%ebp),%eax
8010362d:	8b 00                	mov    (%eax),%eax
8010362f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103633:	8b 45 08             	mov    0x8(%ebp),%eax
80103636:	8b 00                	mov    (%eax),%eax
80103638:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103641:	8b 00                	mov    (%eax),%eax
80103643:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103649:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364c:	8b 00                	mov    (%eax),%eax
8010364e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103652:	8b 45 0c             	mov    0xc(%ebp),%eax
80103655:	8b 00                	mov    (%eax),%eax
80103657:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365e:	8b 00                	mov    (%eax),%eax
80103660:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103663:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103666:	b8 00 00 00 00       	mov    $0x0,%eax
8010366b:	eb 51                	jmp    801036be <pipealloc+0x150>
    goto bad;
8010366d:	90                   	nop
8010366e:	eb 01                	jmp    80103671 <pipealloc+0x103>
    goto bad;
80103670:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103671:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103675:	74 0e                	je     80103685 <pipealloc+0x117>
    kfree((char*)p);
80103677:	83 ec 0c             	sub    $0xc,%esp
8010367a:	ff 75 f4             	push   -0xc(%ebp)
8010367d:	e8 85 f0 ff ff       	call   80102707 <kfree>
80103682:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103685:	8b 45 08             	mov    0x8(%ebp),%eax
80103688:	8b 00                	mov    (%eax),%eax
8010368a:	85 c0                	test   %eax,%eax
8010368c:	74 11                	je     8010369f <pipealloc+0x131>
    fileclose(*f0);
8010368e:	8b 45 08             	mov    0x8(%ebp),%eax
80103691:	8b 00                	mov    (%eax),%eax
80103693:	83 ec 0c             	sub    $0xc,%esp
80103696:	50                   	push   %eax
80103697:	e8 00 da ff ff       	call   8010109c <fileclose>
8010369c:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369f:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a2:	8b 00                	mov    (%eax),%eax
801036a4:	85 c0                	test   %eax,%eax
801036a6:	74 11                	je     801036b9 <pipealloc+0x14b>
    fileclose(*f1);
801036a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801036ab:	8b 00                	mov    (%eax),%eax
801036ad:	83 ec 0c             	sub    $0xc,%esp
801036b0:	50                   	push   %eax
801036b1:	e8 e6 d9 ff ff       	call   8010109c <fileclose>
801036b6:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036be:	c9                   	leave  
801036bf:	c3                   	ret    

801036c0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036c0:	55                   	push   %ebp
801036c1:	89 e5                	mov    %esp,%ebp
801036c3:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	83 ec 0c             	sub    $0xc,%esp
801036cc:	50                   	push   %eax
801036cd:	e8 8a 11 00 00       	call   8010485c <acquire>
801036d2:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d9:	74 23                	je     801036fe <pipeclose+0x3e>
    p->writeopen = 0;
801036db:	8b 45 08             	mov    0x8(%ebp),%eax
801036de:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e5:	00 00 00 
    wakeup(&p->nread);
801036e8:	8b 45 08             	mov    0x8(%ebp),%eax
801036eb:	05 34 02 00 00       	add    $0x234,%eax
801036f0:	83 ec 0c             	sub    $0xc,%esp
801036f3:	50                   	push   %eax
801036f4:	e8 dd 0c 00 00       	call   801043d6 <wakeup>
801036f9:	83 c4 10             	add    $0x10,%esp
801036fc:	eb 21                	jmp    8010371f <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103701:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103708:	00 00 00 
    wakeup(&p->nwrite);
8010370b:	8b 45 08             	mov    0x8(%ebp),%eax
8010370e:	05 38 02 00 00       	add    $0x238,%eax
80103713:	83 ec 0c             	sub    $0xc,%esp
80103716:	50                   	push   %eax
80103717:	e8 ba 0c 00 00       	call   801043d6 <wakeup>
8010371c:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371f:	8b 45 08             	mov    0x8(%ebp),%eax
80103722:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103728:	85 c0                	test   %eax,%eax
8010372a:	75 2c                	jne    80103758 <pipeclose+0x98>
8010372c:	8b 45 08             	mov    0x8(%ebp),%eax
8010372f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103735:	85 c0                	test   %eax,%eax
80103737:	75 1f                	jne    80103758 <pipeclose+0x98>
    release(&p->lock);
80103739:	8b 45 08             	mov    0x8(%ebp),%eax
8010373c:	83 ec 0c             	sub    $0xc,%esp
8010373f:	50                   	push   %eax
80103740:	e8 85 11 00 00       	call   801048ca <release>
80103745:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103748:	83 ec 0c             	sub    $0xc,%esp
8010374b:	ff 75 08             	push   0x8(%ebp)
8010374e:	e8 b4 ef ff ff       	call   80102707 <kfree>
80103753:	83 c4 10             	add    $0x10,%esp
80103756:	eb 10                	jmp    80103768 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103758:	8b 45 08             	mov    0x8(%ebp),%eax
8010375b:	83 ec 0c             	sub    $0xc,%esp
8010375e:	50                   	push   %eax
8010375f:	e8 66 11 00 00       	call   801048ca <release>
80103764:	83 c4 10             	add    $0x10,%esp
}
80103767:	90                   	nop
80103768:	90                   	nop
80103769:	c9                   	leave  
8010376a:	c3                   	ret    

8010376b <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376b:	55                   	push   %ebp
8010376c:	89 e5                	mov    %esp,%ebp
8010376e:	53                   	push   %ebx
8010376f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103772:	8b 45 08             	mov    0x8(%ebp),%eax
80103775:	83 ec 0c             	sub    $0xc,%esp
80103778:	50                   	push   %eax
80103779:	e8 de 10 00 00       	call   8010485c <acquire>
8010377e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103781:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103788:	e9 ad 00 00 00       	jmp    8010383a <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378d:	8b 45 08             	mov    0x8(%ebp),%eax
80103790:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103796:	85 c0                	test   %eax,%eax
80103798:	74 0c                	je     801037a6 <pipewrite+0x3b>
8010379a:	e8 92 02 00 00       	call   80103a31 <myproc>
8010379f:	8b 40 24             	mov    0x24(%eax),%eax
801037a2:	85 c0                	test   %eax,%eax
801037a4:	74 19                	je     801037bf <pipewrite+0x54>
        release(&p->lock);
801037a6:	8b 45 08             	mov    0x8(%ebp),%eax
801037a9:	83 ec 0c             	sub    $0xc,%esp
801037ac:	50                   	push   %eax
801037ad:	e8 18 11 00 00       	call   801048ca <release>
801037b2:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037ba:	e9 a9 00 00 00       	jmp    80103868 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037bf:	8b 45 08             	mov    0x8(%ebp),%eax
801037c2:	05 34 02 00 00       	add    $0x234,%eax
801037c7:	83 ec 0c             	sub    $0xc,%esp
801037ca:	50                   	push   %eax
801037cb:	e8 06 0c 00 00       	call   801043d6 <wakeup>
801037d0:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d3:	8b 45 08             	mov    0x8(%ebp),%eax
801037d6:	8b 55 08             	mov    0x8(%ebp),%edx
801037d9:	81 c2 38 02 00 00    	add    $0x238,%edx
801037df:	83 ec 08             	sub    $0x8,%esp
801037e2:	50                   	push   %eax
801037e3:	52                   	push   %edx
801037e4:	e8 06 0b 00 00       	call   801042ef <sleep>
801037e9:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037ec:	8b 45 08             	mov    0x8(%ebp),%eax
801037ef:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f5:	8b 45 08             	mov    0x8(%ebp),%eax
801037f8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fe:	05 00 02 00 00       	add    $0x200,%eax
80103803:	39 c2                	cmp    %eax,%edx
80103805:	74 86                	je     8010378d <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103807:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010380a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103810:	8b 45 08             	mov    0x8(%ebp),%eax
80103813:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103819:	8d 48 01             	lea    0x1(%eax),%ecx
8010381c:	8b 55 08             	mov    0x8(%ebp),%edx
8010381f:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103825:	25 ff 01 00 00       	and    $0x1ff,%eax
8010382a:	89 c1                	mov    %eax,%ecx
8010382c:	0f b6 13             	movzbl (%ebx),%edx
8010382f:	8b 45 08             	mov    0x8(%ebp),%eax
80103832:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103836:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010383a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383d:	3b 45 10             	cmp    0x10(%ebp),%eax
80103840:	7c aa                	jl     801037ec <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103842:	8b 45 08             	mov    0x8(%ebp),%eax
80103845:	05 34 02 00 00       	add    $0x234,%eax
8010384a:	83 ec 0c             	sub    $0xc,%esp
8010384d:	50                   	push   %eax
8010384e:	e8 83 0b 00 00       	call   801043d6 <wakeup>
80103853:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103856:	8b 45 08             	mov    0x8(%ebp),%eax
80103859:	83 ec 0c             	sub    $0xc,%esp
8010385c:	50                   	push   %eax
8010385d:	e8 68 10 00 00       	call   801048ca <release>
80103862:	83 c4 10             	add    $0x10,%esp
  return n;
80103865:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386b:	c9                   	leave  
8010386c:	c3                   	ret    

8010386d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386d:	55                   	push   %ebp
8010386e:	89 e5                	mov    %esp,%ebp
80103870:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103873:	8b 45 08             	mov    0x8(%ebp),%eax
80103876:	83 ec 0c             	sub    $0xc,%esp
80103879:	50                   	push   %eax
8010387a:	e8 dd 0f 00 00       	call   8010485c <acquire>
8010387f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103882:	eb 3e                	jmp    801038c2 <piperead+0x55>
    if(myproc()->killed){
80103884:	e8 a8 01 00 00       	call   80103a31 <myproc>
80103889:	8b 40 24             	mov    0x24(%eax),%eax
8010388c:	85 c0                	test   %eax,%eax
8010388e:	74 19                	je     801038a9 <piperead+0x3c>
      release(&p->lock);
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	83 ec 0c             	sub    $0xc,%esp
80103896:	50                   	push   %eax
80103897:	e8 2e 10 00 00       	call   801048ca <release>
8010389c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a4:	e9 be 00 00 00       	jmp    80103967 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a9:	8b 45 08             	mov    0x8(%ebp),%eax
801038ac:	8b 55 08             	mov    0x8(%ebp),%edx
801038af:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b5:	83 ec 08             	sub    $0x8,%esp
801038b8:	50                   	push   %eax
801038b9:	52                   	push   %edx
801038ba:	e8 30 0a 00 00       	call   801042ef <sleep>
801038bf:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c2:	8b 45 08             	mov    0x8(%ebp),%eax
801038c5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038cb:	8b 45 08             	mov    0x8(%ebp),%eax
801038ce:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d4:	39 c2                	cmp    %eax,%edx
801038d6:	75 0d                	jne    801038e5 <piperead+0x78>
801038d8:	8b 45 08             	mov    0x8(%ebp),%eax
801038db:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e1:	85 c0                	test   %eax,%eax
801038e3:	75 9f                	jne    80103884 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038ec:	eb 48                	jmp    80103936 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ee:	8b 45 08             	mov    0x8(%ebp),%eax
801038f1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f7:	8b 45 08             	mov    0x8(%ebp),%eax
801038fa:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103900:	39 c2                	cmp    %eax,%edx
80103902:	74 3c                	je     80103940 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103904:	8b 45 08             	mov    0x8(%ebp),%eax
80103907:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390d:	8d 48 01             	lea    0x1(%eax),%ecx
80103910:	8b 55 08             	mov    0x8(%ebp),%edx
80103913:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103919:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391e:	89 c1                	mov    %eax,%ecx
80103920:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103923:	8b 45 0c             	mov    0xc(%ebp),%eax
80103926:	01 c2                	add    %eax,%edx
80103928:	8b 45 08             	mov    0x8(%ebp),%eax
8010392b:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103930:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103932:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103939:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393c:	7c b0                	jl     801038ee <piperead+0x81>
8010393e:	eb 01                	jmp    80103941 <piperead+0xd4>
      break;
80103940:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103941:	8b 45 08             	mov    0x8(%ebp),%eax
80103944:	05 38 02 00 00       	add    $0x238,%eax
80103949:	83 ec 0c             	sub    $0xc,%esp
8010394c:	50                   	push   %eax
8010394d:	e8 84 0a 00 00       	call   801043d6 <wakeup>
80103952:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103955:	8b 45 08             	mov    0x8(%ebp),%eax
80103958:	83 ec 0c             	sub    $0xc,%esp
8010395b:	50                   	push   %eax
8010395c:	e8 69 0f 00 00       	call   801048ca <release>
80103961:	83 c4 10             	add    $0x10,%esp
  return i;
80103964:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103967:	c9                   	leave  
80103968:	c3                   	ret    

80103969 <readeflags>:
{
80103969:	55                   	push   %ebp
8010396a:	89 e5                	mov    %esp,%ebp
8010396c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396f:	9c                   	pushf  
80103970:	58                   	pop    %eax
80103971:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103974:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103977:	c9                   	leave  
80103978:	c3                   	ret    

80103979 <sti>:
{
80103979:	55                   	push   %ebp
8010397a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397c:	fb                   	sti    
}
8010397d:	90                   	nop
8010397e:	5d                   	pop    %ebp
8010397f:	c3                   	ret    

80103980 <pinit>:
static void wakeup1(void *chan);
pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);

void
pinit(void)
{
80103980:	55                   	push   %ebp
80103981:	89 e5                	mov    %esp,%ebp
80103983:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103986:	83 ec 08             	sub    $0x8,%esp
80103989:	68 74 a5 10 80       	push   $0x8010a574
8010398e:	68 00 42 19 80       	push   $0x80194200
80103993:	e8 a2 0e 00 00       	call   8010483a <initlock>
80103998:	83 c4 10             	add    $0x10,%esp
}
8010399b:	90                   	nop
8010399c:	c9                   	leave  
8010399d:	c3                   	ret    

8010399e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399e:	55                   	push   %ebp
8010399f:	89 e5                	mov    %esp,%ebp
801039a1:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a4:	e8 10 00 00 00       	call   801039b9 <mycpu>
801039a9:	2d 80 69 19 80       	sub    $0x80196980,%eax
801039ae:	c1 f8 04             	sar    $0x4,%eax
801039b1:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b7:	c9                   	leave  
801039b8:	c3                   	ret    

801039b9 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b9:	55                   	push   %ebp
801039ba:	89 e5                	mov    %esp,%ebp
801039bc:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039bf:	e8 a5 ff ff ff       	call   80103969 <readeflags>
801039c4:	25 00 02 00 00       	and    $0x200,%eax
801039c9:	85 c0                	test   %eax,%eax
801039cb:	74 0d                	je     801039da <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cd:	83 ec 0c             	sub    $0xc,%esp
801039d0:	68 7c a5 10 80       	push   $0x8010a57c
801039d5:	e8 cf cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039da:	e8 1c f1 ff ff       	call   80102afb <lapicid>
801039df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e9:	eb 2d                	jmp    80103a18 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ee:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f4:	05 80 69 19 80       	add    $0x80196980,%eax
801039f9:	0f b6 00             	movzbl (%eax),%eax
801039fc:	0f b6 c0             	movzbl %al,%eax
801039ff:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a02:	75 10                	jne    80103a14 <mycpu+0x5b>
      return &cpus[i];
80103a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a07:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0d:	05 80 69 19 80       	add    $0x80196980,%eax
80103a12:	eb 1b                	jmp    80103a2f <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a18:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103a1d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a20:	7c c9                	jl     801039eb <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a22:	83 ec 0c             	sub    $0xc,%esp
80103a25:	68 a2 a5 10 80       	push   $0x8010a5a2
80103a2a:	e8 7a cb ff ff       	call   801005a9 <panic>
}
80103a2f:	c9                   	leave  
80103a30:	c3                   	ret    

80103a31 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a31:	55                   	push   %ebp
80103a32:	89 e5                	mov    %esp,%ebp
80103a34:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a37:	e8 8b 0f 00 00       	call   801049c7 <pushcli>
  c = mycpu();
80103a3c:	e8 78 ff ff ff       	call   801039b9 <mycpu>
80103a41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a47:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a50:	e8 bf 0f 00 00       	call   80104a14 <popcli>
  return p;
80103a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a58:	c9                   	leave  
80103a59:	c3                   	ret    

80103a5a <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a5a:	55                   	push   %ebp
80103a5b:	89 e5                	mov    %esp,%ebp
80103a5d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a60:	83 ec 0c             	sub    $0xc,%esp
80103a63:	68 00 42 19 80       	push   $0x80194200
80103a68:	e8 ef 0d 00 00       	call   8010485c <acquire>
80103a6d:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a70:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a77:	eb 0e                	jmp    80103a87 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7c:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7f:	85 c0                	test   %eax,%eax
80103a81:	74 27                	je     80103aaa <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a83:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a87:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103a8e:	72 e9                	jb     80103a79 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a90:	83 ec 0c             	sub    $0xc,%esp
80103a93:	68 00 42 19 80       	push   $0x80194200
80103a98:	e8 2d 0e 00 00       	call   801048ca <release>
80103a9d:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa0:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa5:	e9 b2 00 00 00       	jmp    80103b5c <allocproc+0x102>
      goto found;
80103aaa:	90                   	nop

found:
  p->state = EMBRYO;
80103aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aae:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab5:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103aba:	8d 50 01             	lea    0x1(%eax),%edx
80103abd:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac6:	89 42 10             	mov    %eax,0x10(%edx)
  
  release(&ptable.lock);
80103ac9:	83 ec 0c             	sub    $0xc,%esp
80103acc:	68 00 42 19 80       	push   $0x80194200
80103ad1:	e8 f4 0d 00 00       	call   801048ca <release>
80103ad6:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ad9:	e8 c3 ec ff ff       	call   801027a1 <kalloc>
80103ade:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae1:	89 42 08             	mov    %eax,0x8(%edx)
80103ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae7:	8b 40 08             	mov    0x8(%eax),%eax
80103aea:	85 c0                	test   %eax,%eax
80103aec:	75 11                	jne    80103aff <allocproc+0xa5>
    p->state = UNUSED;
80103aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103af8:	b8 00 00 00 00       	mov    $0x0,%eax
80103afd:	eb 5d                	jmp    80103b5c <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b02:	8b 40 08             	mov    0x8(%eax),%eax
80103b05:	05 00 10 00 00       	add    $0x1000,%eax
80103b0a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0d:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b14:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b17:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b1a:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b1e:	ba 7d 5e 10 80       	mov    $0x80105e7d,%edx
80103b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b26:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b28:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b32:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b38:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3b:	83 ec 04             	sub    $0x4,%esp
80103b3e:	6a 14                	push   $0x14
80103b40:	6a 00                	push   $0x0
80103b42:	50                   	push   %eax
80103b43:	e8 8a 0f 00 00       	call   80104ad2 <memset>
80103b48:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4e:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b51:	ba a9 42 10 80       	mov    $0x801042a9,%edx
80103b56:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5c:	c9                   	leave  
80103b5d:	c3                   	ret    

80103b5e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b5e:	55                   	push   %ebp
80103b5f:	89 e5                	mov    %esp,%ebp
80103b61:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b64:	e8 f1 fe ff ff       	call   80103a5a <allocproc>
80103b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6f:	a3 34 61 19 80       	mov    %eax,0x80196134
  if((p->pgdir = setupkvm()) == 0){
80103b74:	e8 3f 3a 00 00       	call   801075b8 <setupkvm>
80103b79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7c:	89 42 04             	mov    %eax,0x4(%edx)
80103b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b82:	8b 40 04             	mov    0x4(%eax),%eax
80103b85:	85 c0                	test   %eax,%eax
80103b87:	75 0d                	jne    80103b96 <userinit+0x38>
    panic("userinit: out of memory?");
80103b89:	83 ec 0c             	sub    $0xc,%esp
80103b8c:	68 b2 a5 10 80       	push   $0x8010a5b2
80103b91:	e8 13 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b96:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9e:	8b 40 04             	mov    0x4(%eax),%eax
80103ba1:	83 ec 04             	sub    $0x4,%esp
80103ba4:	52                   	push   %edx
80103ba5:	68 ec f4 10 80       	push   $0x8010f4ec
80103baa:	50                   	push   %eax
80103bab:	e8 c4 3c 00 00       	call   80107874 <inituvm>
80103bb0:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb6:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbf:	8b 40 18             	mov    0x18(%eax),%eax
80103bc2:	83 ec 04             	sub    $0x4,%esp
80103bc5:	6a 4c                	push   $0x4c
80103bc7:	6a 00                	push   $0x0
80103bc9:	50                   	push   %eax
80103bca:	e8 03 0f 00 00       	call   80104ad2 <memset>
80103bcf:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd5:	8b 40 18             	mov    0x18(%eax),%eax
80103bd8:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be1:	8b 40 18             	mov    0x18(%eax),%eax
80103be4:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bed:	8b 50 18             	mov    0x18(%eax),%edx
80103bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf3:	8b 40 18             	mov    0x18(%eax),%eax
80103bf6:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bfa:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c01:	8b 50 18             	mov    0x18(%eax),%edx
80103c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c07:	8b 40 18             	mov    0x18(%eax),%eax
80103c0a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c0e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c15:	8b 40 18             	mov    0x18(%eax),%eax
80103c18:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c22:	8b 40 18             	mov    0x18(%eax),%eax
80103c25:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2f:	8b 40 18             	mov    0x18(%eax),%eax
80103c32:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3c:	83 c0 6c             	add    $0x6c,%eax
80103c3f:	83 ec 04             	sub    $0x4,%esp
80103c42:	6a 10                	push   $0x10
80103c44:	68 cb a5 10 80       	push   $0x8010a5cb
80103c49:	50                   	push   %eax
80103c4a:	e8 86 10 00 00       	call   80104cd5 <safestrcpy>
80103c4f:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c52:	83 ec 0c             	sub    $0xc,%esp
80103c55:	68 d4 a5 10 80       	push   $0x8010a5d4
80103c5a:	e8 bf e8 ff ff       	call   8010251e <namei>
80103c5f:	83 c4 10             	add    $0x10,%esp
80103c62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c65:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c68:	83 ec 0c             	sub    $0xc,%esp
80103c6b:	68 00 42 19 80       	push   $0x80194200
80103c70:	e8 e7 0b 00 00       	call   8010485c <acquire>
80103c75:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c82:	83 ec 0c             	sub    $0xc,%esp
80103c85:	68 00 42 19 80       	push   $0x80194200
80103c8a:	e8 3b 0c 00 00       	call   801048ca <release>
80103c8f:	83 c4 10             	add    $0x10,%esp
}
80103c92:	90                   	nop
80103c93:	c9                   	leave  
80103c94:	c3                   	ret    

80103c95 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c95:	55                   	push   %ebp
80103c96:	89 e5                	mov    %esp,%ebp
80103c98:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9b:	e8 91 fd ff ff       	call   80103a31 <myproc>
80103ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca6:	8b 00                	mov    (%eax),%eax
80103ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103cab:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103caf:	7e 2e                	jle    80103cdf <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb1:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb7:	01 c2                	add    %eax,%edx
80103cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbc:	8b 40 04             	mov    0x4(%eax),%eax
80103cbf:	83 ec 04             	sub    $0x4,%esp
80103cc2:	52                   	push   %edx
80103cc3:	ff 75 f4             	push   -0xc(%ebp)
80103cc6:	50                   	push   %eax
80103cc7:	e8 e5 3c 00 00       	call   801079b1 <allocuvm>
80103ccc:	83 c4 10             	add    $0x10,%esp
80103ccf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd6:	75 3b                	jne    80103d13 <growproc+0x7e>
      return -1;
80103cd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdd:	eb 4f                	jmp    80103d2e <growproc+0x99>
  } else if(n < 0){
80103cdf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce3:	79 2e                	jns    80103d13 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce5:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ceb:	01 c2                	add    %eax,%edx
80103ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf0:	8b 40 04             	mov    0x4(%eax),%eax
80103cf3:	83 ec 04             	sub    $0x4,%esp
80103cf6:	52                   	push   %edx
80103cf7:	ff 75 f4             	push   -0xc(%ebp)
80103cfa:	50                   	push   %eax
80103cfb:	e8 b6 3d 00 00       	call   80107ab6 <deallocuvm>
80103d00:	83 c4 10             	add    $0x10,%esp
80103d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d0a:	75 07                	jne    80103d13 <growproc+0x7e>
      return -1;
80103d0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d11:	eb 1b                	jmp    80103d2e <growproc+0x99>
  }
  curproc->sz = sz;
80103d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d19:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1b:	83 ec 0c             	sub    $0xc,%esp
80103d1e:	ff 75 f0             	push   -0x10(%ebp)
80103d21:	e8 af 39 00 00       	call   801076d5 <switchuvm>
80103d26:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d29:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d2e:	c9                   	leave  
80103d2f:	c3                   	ret    

80103d30 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d30:	55                   	push   %ebp
80103d31:	89 e5                	mov    %esp,%ebp
80103d33:	57                   	push   %edi
80103d34:	56                   	push   %esi
80103d35:	53                   	push   %ebx
80103d36:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d39:	e8 f3 fc ff ff       	call   80103a31 <myproc>
80103d3e:	89 45 e0             	mov    %eax,-0x20(%ebp)

  if (curproc->sz < KERNBASE - PGSIZE)
80103d41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d44:	8b 00                	mov    (%eax),%eax
80103d46:	3d ff ef ff 7f       	cmp    $0x7fffefff,%eax
80103d4b:	77 09                	ja     80103d56 <fork+0x26>
    curproc->sz = KERNBASE - PGSIZE;
80103d4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d50:	c7 00 00 f0 ff 7f    	movl   $0x7ffff000,(%eax)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d56:	e8 ff fc ff ff       	call   80103a5a <allocproc>
80103d5b:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d5e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d62:	75 0a                	jne    80103d6e <fork+0x3e>
    return -1;
80103d64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d69:	e9 48 01 00 00       	jmp    80103eb6 <fork+0x186>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d71:	8b 10                	mov    (%eax),%edx
80103d73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d76:	8b 40 04             	mov    0x4(%eax),%eax
80103d79:	83 ec 08             	sub    $0x8,%esp
80103d7c:	52                   	push   %edx
80103d7d:	50                   	push   %eax
80103d7e:	e8 d1 3e 00 00       	call   80107c54 <copyuvm>
80103d83:	83 c4 10             	add    $0x10,%esp
80103d86:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d89:	89 42 04             	mov    %eax,0x4(%edx)
80103d8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d8f:	8b 40 04             	mov    0x4(%eax),%eax
80103d92:	85 c0                	test   %eax,%eax
80103d94:	75 30                	jne    80103dc6 <fork+0x96>
    kfree(np->kstack);
80103d96:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d99:	8b 40 08             	mov    0x8(%eax),%eax
80103d9c:	83 ec 0c             	sub    $0xc,%esp
80103d9f:	50                   	push   %eax
80103da0:	e8 62 e9 ff ff       	call   80102707 <kfree>
80103da5:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103da8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103db2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103dbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dc1:	e9 f0 00 00 00       	jmp    80103eb6 <fork+0x186>
  }
  np->sz = curproc->sz;
80103dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc9:	8b 10                	mov    (%eax),%edx
80103dcb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dce:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dd0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dd6:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ddc:	8b 48 18             	mov    0x18(%eax),%ecx
80103ddf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de2:	8b 40 18             	mov    0x18(%eax),%eax
80103de5:	89 c2                	mov    %eax,%edx
80103de7:	89 cb                	mov    %ecx,%ebx
80103de9:	b8 13 00 00 00       	mov    $0x13,%eax
80103dee:	89 d7                	mov    %edx,%edi
80103df0:	89 de                	mov    %ebx,%esi
80103df2:	89 c1                	mov    %eax,%ecx
80103df4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)


  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103df6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df9:	8b 40 18             	mov    0x18(%eax),%eax
80103dfc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)


  for(i = 0; i < NOFILE; i++)
80103e03:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e0a:	eb 3b                	jmp    80103e47 <fork+0x117>
    if(curproc->ofile[i])
80103e0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e12:	83 c2 08             	add    $0x8,%edx
80103e15:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e19:	85 c0                	test   %eax,%eax
80103e1b:	74 26                	je     80103e43 <fork+0x113>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e23:	83 c2 08             	add    $0x8,%edx
80103e26:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e2a:	83 ec 0c             	sub    $0xc,%esp
80103e2d:	50                   	push   %eax
80103e2e:	e8 18 d2 ff ff       	call   8010104b <filedup>
80103e33:	83 c4 10             	add    $0x10,%esp
80103e36:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e39:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e3c:	83 c1 08             	add    $0x8,%ecx
80103e3f:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e43:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e47:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e4b:	7e bf                	jle    80103e0c <fork+0xdc>
  np->cwd = idup(curproc->cwd);
80103e4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e50:	8b 40 68             	mov    0x68(%eax),%eax
80103e53:	83 ec 0c             	sub    $0xc,%esp
80103e56:	50                   	push   %eax
80103e57:	e8 55 db ff ff       	call   801019b1 <idup>
80103e5c:	83 c4 10             	add    $0x10,%esp
80103e5f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e62:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e68:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6e:	83 c0 6c             	add    $0x6c,%eax
80103e71:	83 ec 04             	sub    $0x4,%esp
80103e74:	6a 10                	push   $0x10
80103e76:	52                   	push   %edx
80103e77:	50                   	push   %eax
80103e78:	e8 58 0e 00 00       	call   80104cd5 <safestrcpy>
80103e7d:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e83:	8b 40 10             	mov    0x10(%eax),%eax
80103e86:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e89:	83 ec 0c             	sub    $0xc,%esp
80103e8c:	68 00 42 19 80       	push   $0x80194200
80103e91:	e8 c6 09 00 00       	call   8010485c <acquire>
80103e96:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e99:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e9c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ea3:	83 ec 0c             	sub    $0xc,%esp
80103ea6:	68 00 42 19 80       	push   $0x80194200
80103eab:	e8 1a 0a 00 00       	call   801048ca <release>
80103eb0:	83 c4 10             	add    $0x10,%esp
  return pid;
80103eb3:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103eb9:	5b                   	pop    %ebx
80103eba:	5e                   	pop    %esi
80103ebb:	5f                   	pop    %edi
80103ebc:	5d                   	pop    %ebp
80103ebd:	c3                   	ret    

80103ebe <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ebe:	55                   	push   %ebp
80103ebf:	89 e5                	mov    %esp,%ebp
80103ec1:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103ec4:	e8 68 fb ff ff       	call   80103a31 <myproc>
80103ec9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103ecc:	a1 34 61 19 80       	mov    0x80196134,%eax
80103ed1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ed4:	75 0d                	jne    80103ee3 <exit+0x25>
    panic("init exiting");
80103ed6:	83 ec 0c             	sub    $0xc,%esp
80103ed9:	68 d6 a5 10 80       	push   $0x8010a5d6
80103ede:	e8 c6 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ee3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103eea:	eb 3f                	jmp    80103f2b <exit+0x6d>
    if(curproc->ofile[fd]){
80103eec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eef:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ef2:	83 c2 08             	add    $0x8,%edx
80103ef5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef9:	85 c0                	test   %eax,%eax
80103efb:	74 2a                	je     80103f27 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103efd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f00:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f03:	83 c2 08             	add    $0x8,%edx
80103f06:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f0a:	83 ec 0c             	sub    $0xc,%esp
80103f0d:	50                   	push   %eax
80103f0e:	e8 89 d1 ff ff       	call   8010109c <fileclose>
80103f13:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f19:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f1c:	83 c2 08             	add    $0x8,%edx
80103f1f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f26:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f27:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f2b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f2f:	7e bb                	jle    80103eec <exit+0x2e>
    }
  }

  begin_op();
80103f31:	e8 07 f1 ff ff       	call   8010303d <begin_op>
  iput(curproc->cwd);
80103f36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f39:	8b 40 68             	mov    0x68(%eax),%eax
80103f3c:	83 ec 0c             	sub    $0xc,%esp
80103f3f:	50                   	push   %eax
80103f40:	e8 07 dc ff ff       	call   80101b4c <iput>
80103f45:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f48:	e8 7c f1 ff ff       	call   801030c9 <end_op>
  curproc->cwd = 0;
80103f4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f50:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f57:	83 ec 0c             	sub    $0xc,%esp
80103f5a:	68 00 42 19 80       	push   $0x80194200
80103f5f:	e8 f8 08 00 00       	call   8010485c <acquire>
80103f64:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f6a:	8b 40 14             	mov    0x14(%eax),%eax
80103f6d:	83 ec 0c             	sub    $0xc,%esp
80103f70:	50                   	push   %eax
80103f71:	e8 20 04 00 00       	call   80104396 <wakeup1>
80103f76:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f79:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f80:	eb 37                	jmp    80103fb9 <exit+0xfb>
    if(p->parent == curproc){
80103f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f85:	8b 40 14             	mov    0x14(%eax),%eax
80103f88:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f8b:	75 28                	jne    80103fb5 <exit+0xf7>
      p->parent = initproc;
80103f8d:	8b 15 34 61 19 80    	mov    0x80196134,%edx
80103f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f96:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9c:	8b 40 0c             	mov    0xc(%eax),%eax
80103f9f:	83 f8 05             	cmp    $0x5,%eax
80103fa2:	75 11                	jne    80103fb5 <exit+0xf7>
        wakeup1(initproc);
80103fa4:	a1 34 61 19 80       	mov    0x80196134,%eax
80103fa9:	83 ec 0c             	sub    $0xc,%esp
80103fac:	50                   	push   %eax
80103fad:	e8 e4 03 00 00       	call   80104396 <wakeup1>
80103fb2:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fb5:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103fb9:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103fc0:	72 c0                	jb     80103f82 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fc5:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fcc:	e8 e5 01 00 00       	call   801041b6 <sched>
  panic("zombie exit");
80103fd1:	83 ec 0c             	sub    $0xc,%esp
80103fd4:	68 e3 a5 10 80       	push   $0x8010a5e3
80103fd9:	e8 cb c5 ff ff       	call   801005a9 <panic>

80103fde <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fde:	55                   	push   %ebp
80103fdf:	89 e5                	mov    %esp,%ebp
80103fe1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fe4:	e8 48 fa ff ff       	call   80103a31 <myproc>
80103fe9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fec:	83 ec 0c             	sub    $0xc,%esp
80103fef:	68 00 42 19 80       	push   $0x80194200
80103ff4:	e8 63 08 00 00       	call   8010485c <acquire>
80103ff9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103ffc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104003:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010400a:	e9 a1 00 00 00       	jmp    801040b0 <wait+0xd2>
      if(p->parent != curproc)
8010400f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104012:	8b 40 14             	mov    0x14(%eax),%eax
80104015:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104018:	0f 85 8d 00 00 00    	jne    801040ab <wait+0xcd>
        continue;
      havekids = 1;
8010401e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104028:	8b 40 0c             	mov    0xc(%eax),%eax
8010402b:	83 f8 05             	cmp    $0x5,%eax
8010402e:	75 7c                	jne    801040ac <wait+0xce>
        // Found one.
        pid = p->pid;
80104030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104033:	8b 40 10             	mov    0x10(%eax),%eax
80104036:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403c:	8b 40 08             	mov    0x8(%eax),%eax
8010403f:	83 ec 0c             	sub    $0xc,%esp
80104042:	50                   	push   %eax
80104043:	e8 bf e6 ff ff       	call   80102707 <kfree>
80104048:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010404b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104058:	8b 40 04             	mov    0x4(%eax),%eax
8010405b:	83 ec 0c             	sub    $0xc,%esp
8010405e:	50                   	push   %eax
8010405f:	e8 16 3b 00 00       	call   80107b7a <freevm>
80104064:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104067:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104074:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010407b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104085:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010408c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104096:	83 ec 0c             	sub    $0xc,%esp
80104099:	68 00 42 19 80       	push   $0x80194200
8010409e:	e8 27 08 00 00       	call   801048ca <release>
801040a3:	83 c4 10             	add    $0x10,%esp
        return pid;
801040a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040a9:	eb 51                	jmp    801040fc <wait+0x11e>
        continue;
801040ab:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040ac:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801040b0:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801040b7:	0f 82 52 ff ff ff    	jb     8010400f <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040c1:	74 0a                	je     801040cd <wait+0xef>
801040c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040c6:	8b 40 24             	mov    0x24(%eax),%eax
801040c9:	85 c0                	test   %eax,%eax
801040cb:	74 17                	je     801040e4 <wait+0x106>
      release(&ptable.lock);
801040cd:	83 ec 0c             	sub    $0xc,%esp
801040d0:	68 00 42 19 80       	push   $0x80194200
801040d5:	e8 f0 07 00 00       	call   801048ca <release>
801040da:	83 c4 10             	add    $0x10,%esp
      return -1;
801040dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e2:	eb 18                	jmp    801040fc <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040e4:	83 ec 08             	sub    $0x8,%esp
801040e7:	68 00 42 19 80       	push   $0x80194200
801040ec:	ff 75 ec             	push   -0x14(%ebp)
801040ef:	e8 fb 01 00 00       	call   801042ef <sleep>
801040f4:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040f7:	e9 00 ff ff ff       	jmp    80103ffc <wait+0x1e>
  }
}
801040fc:	c9                   	leave  
801040fd:	c3                   	ret    

801040fe <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040fe:	55                   	push   %ebp
801040ff:	89 e5                	mov    %esp,%ebp
80104101:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104104:	e8 b0 f8 ff ff       	call   801039b9 <mycpu>
80104109:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
8010410c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010410f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104116:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104119:	e8 5b f8 ff ff       	call   80103979 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010411e:	83 ec 0c             	sub    $0xc,%esp
80104121:	68 00 42 19 80       	push   $0x80194200
80104126:	e8 31 07 00 00       	call   8010485c <acquire>
8010412b:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010412e:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104135:	eb 61                	jmp    80104198 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413a:	8b 40 0c             	mov    0xc(%eax),%eax
8010413d:	83 f8 03             	cmp    $0x3,%eax
80104140:	75 51                	jne    80104193 <scheduler+0x95>
        continue;
  
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104142:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104145:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104148:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010414e:	83 ec 0c             	sub    $0xc,%esp
80104151:	ff 75 f4             	push   -0xc(%ebp)
80104154:	e8 7c 35 00 00       	call   801076d5 <switchuvm>
80104159:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010415c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104169:	8b 40 1c             	mov    0x1c(%eax),%eax
8010416c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010416f:	83 c2 04             	add    $0x4,%edx
80104172:	83 ec 08             	sub    $0x8,%esp
80104175:	50                   	push   %eax
80104176:	52                   	push   %edx
80104177:	e8 cb 0b 00 00       	call   80104d47 <swtch>
8010417c:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010417f:	e8 38 35 00 00       	call   801076bc <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104184:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104187:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010418e:	00 00 00 
80104191:	eb 01                	jmp    80104194 <scheduler+0x96>
        continue;
80104193:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104194:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104198:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
8010419f:	72 96                	jb     80104137 <scheduler+0x39>
    }
    release(&ptable.lock);
801041a1:	83 ec 0c             	sub    $0xc,%esp
801041a4:	68 00 42 19 80       	push   $0x80194200
801041a9:	e8 1c 07 00 00       	call   801048ca <release>
801041ae:	83 c4 10             	add    $0x10,%esp
    sti();
801041b1:	e9 63 ff ff ff       	jmp    80104119 <scheduler+0x1b>

801041b6 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041b6:	55                   	push   %ebp
801041b7:	89 e5                	mov    %esp,%ebp
801041b9:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041bc:	e8 70 f8 ff ff       	call   80103a31 <myproc>
801041c1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041c4:	83 ec 0c             	sub    $0xc,%esp
801041c7:	68 00 42 19 80       	push   $0x80194200
801041cc:	e8 c6 07 00 00       	call   80104997 <holding>
801041d1:	83 c4 10             	add    $0x10,%esp
801041d4:	85 c0                	test   %eax,%eax
801041d6:	75 0d                	jne    801041e5 <sched+0x2f>
    panic("sched ptable.lock");
801041d8:	83 ec 0c             	sub    $0xc,%esp
801041db:	68 ef a5 10 80       	push   $0x8010a5ef
801041e0:	e8 c4 c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041e5:	e8 cf f7 ff ff       	call   801039b9 <mycpu>
801041ea:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041f0:	83 f8 01             	cmp    $0x1,%eax
801041f3:	74 0d                	je     80104202 <sched+0x4c>
    panic("sched locks");
801041f5:	83 ec 0c             	sub    $0xc,%esp
801041f8:	68 01 a6 10 80       	push   $0x8010a601
801041fd:	e8 a7 c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104205:	8b 40 0c             	mov    0xc(%eax),%eax
80104208:	83 f8 04             	cmp    $0x4,%eax
8010420b:	75 0d                	jne    8010421a <sched+0x64>
    panic("sched running");
8010420d:	83 ec 0c             	sub    $0xc,%esp
80104210:	68 0d a6 10 80       	push   $0x8010a60d
80104215:	e8 8f c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
8010421a:	e8 4a f7 ff ff       	call   80103969 <readeflags>
8010421f:	25 00 02 00 00       	and    $0x200,%eax
80104224:	85 c0                	test   %eax,%eax
80104226:	74 0d                	je     80104235 <sched+0x7f>
    panic("sched interruptible");
80104228:	83 ec 0c             	sub    $0xc,%esp
8010422b:	68 1b a6 10 80       	push   $0x8010a61b
80104230:	e8 74 c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104235:	e8 7f f7 ff ff       	call   801039b9 <mycpu>
8010423a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104240:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104243:	e8 71 f7 ff ff       	call   801039b9 <mycpu>
80104248:	8b 40 04             	mov    0x4(%eax),%eax
8010424b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424e:	83 c2 1c             	add    $0x1c,%edx
80104251:	83 ec 08             	sub    $0x8,%esp
80104254:	50                   	push   %eax
80104255:	52                   	push   %edx
80104256:	e8 ec 0a 00 00       	call   80104d47 <swtch>
8010425b:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010425e:	e8 56 f7 ff ff       	call   801039b9 <mycpu>
80104263:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104266:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010426c:	90                   	nop
8010426d:	c9                   	leave  
8010426e:	c3                   	ret    

8010426f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010426f:	55                   	push   %ebp
80104270:	89 e5                	mov    %esp,%ebp
80104272:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104275:	83 ec 0c             	sub    $0xc,%esp
80104278:	68 00 42 19 80       	push   $0x80194200
8010427d:	e8 da 05 00 00       	call   8010485c <acquire>
80104282:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104285:	e8 a7 f7 ff ff       	call   80103a31 <myproc>
8010428a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104291:	e8 20 ff ff ff       	call   801041b6 <sched>
  release(&ptable.lock);
80104296:	83 ec 0c             	sub    $0xc,%esp
80104299:	68 00 42 19 80       	push   $0x80194200
8010429e:	e8 27 06 00 00       	call   801048ca <release>
801042a3:	83 c4 10             	add    $0x10,%esp
}
801042a6:	90                   	nop
801042a7:	c9                   	leave  
801042a8:	c3                   	ret    

801042a9 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801042a9:	55                   	push   %ebp
801042aa:	89 e5                	mov    %esp,%ebp
801042ac:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801042af:	83 ec 0c             	sub    $0xc,%esp
801042b2:	68 00 42 19 80       	push   $0x80194200
801042b7:	e8 0e 06 00 00       	call   801048ca <release>
801042bc:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042bf:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042c4:	85 c0                	test   %eax,%eax
801042c6:	74 24                	je     801042ec <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042c8:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042cf:	00 00 00 
    iinit(ROOTDEV);
801042d2:	83 ec 0c             	sub    $0xc,%esp
801042d5:	6a 01                	push   $0x1
801042d7:	e8 9d d3 ff ff       	call   80101679 <iinit>
801042dc:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042df:	83 ec 0c             	sub    $0xc,%esp
801042e2:	6a 01                	push   $0x1
801042e4:	e8 35 eb ff ff       	call   80102e1e <initlog>
801042e9:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042ec:	90                   	nop
801042ed:	c9                   	leave  
801042ee:	c3                   	ret    

801042ef <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042ef:	55                   	push   %ebp
801042f0:	89 e5                	mov    %esp,%ebp
801042f2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042f5:	e8 37 f7 ff ff       	call   80103a31 <myproc>
801042fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104301:	75 0d                	jne    80104310 <sleep+0x21>
    panic("sleep");
80104303:	83 ec 0c             	sub    $0xc,%esp
80104306:	68 2f a6 10 80       	push   $0x8010a62f
8010430b:	e8 99 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104310:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104314:	75 0d                	jne    80104323 <sleep+0x34>
    panic("sleep without lk");
80104316:	83 ec 0c             	sub    $0xc,%esp
80104319:	68 35 a6 10 80       	push   $0x8010a635
8010431e:	e8 86 c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104323:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010432a:	74 1e                	je     8010434a <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010432c:	83 ec 0c             	sub    $0xc,%esp
8010432f:	68 00 42 19 80       	push   $0x80194200
80104334:	e8 23 05 00 00       	call   8010485c <acquire>
80104339:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010433c:	83 ec 0c             	sub    $0xc,%esp
8010433f:	ff 75 0c             	push   0xc(%ebp)
80104342:	e8 83 05 00 00       	call   801048ca <release>
80104347:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010434a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434d:	8b 55 08             	mov    0x8(%ebp),%edx
80104350:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104356:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010435d:	e8 54 fe ff ff       	call   801041b6 <sched>

  // Tidy up.
  p->chan = 0;
80104362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104365:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010436c:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104373:	74 1e                	je     80104393 <sleep+0xa4>
    release(&ptable.lock);
80104375:	83 ec 0c             	sub    $0xc,%esp
80104378:	68 00 42 19 80       	push   $0x80194200
8010437d:	e8 48 05 00 00       	call   801048ca <release>
80104382:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104385:	83 ec 0c             	sub    $0xc,%esp
80104388:	ff 75 0c             	push   0xc(%ebp)
8010438b:	e8 cc 04 00 00       	call   8010485c <acquire>
80104390:	83 c4 10             	add    $0x10,%esp
  }
}
80104393:	90                   	nop
80104394:	c9                   	leave  
80104395:	c3                   	ret    

80104396 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104396:	55                   	push   %ebp
80104397:	89 e5                	mov    %esp,%ebp
80104399:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010439c:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
801043a3:	eb 24                	jmp    801043c9 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
801043a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a8:	8b 40 0c             	mov    0xc(%eax),%eax
801043ab:	83 f8 02             	cmp    $0x2,%eax
801043ae:	75 15                	jne    801043c5 <wakeup1+0x2f>
801043b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043b3:	8b 40 20             	mov    0x20(%eax),%eax
801043b6:	39 45 08             	cmp    %eax,0x8(%ebp)
801043b9:	75 0a                	jne    801043c5 <wakeup1+0x2f>
      p->state = RUNNABLE;
801043bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043be:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043c5:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801043c9:	81 7d fc 34 61 19 80 	cmpl   $0x80196134,-0x4(%ebp)
801043d0:	72 d3                	jb     801043a5 <wakeup1+0xf>
}
801043d2:	90                   	nop
801043d3:	90                   	nop
801043d4:	c9                   	leave  
801043d5:	c3                   	ret    

801043d6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043d6:	55                   	push   %ebp
801043d7:	89 e5                	mov    %esp,%ebp
801043d9:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043dc:	83 ec 0c             	sub    $0xc,%esp
801043df:	68 00 42 19 80       	push   $0x80194200
801043e4:	e8 73 04 00 00       	call   8010485c <acquire>
801043e9:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043ec:	83 ec 0c             	sub    $0xc,%esp
801043ef:	ff 75 08             	push   0x8(%ebp)
801043f2:	e8 9f ff ff ff       	call   80104396 <wakeup1>
801043f7:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043fa:	83 ec 0c             	sub    $0xc,%esp
801043fd:	68 00 42 19 80       	push   $0x80194200
80104402:	e8 c3 04 00 00       	call   801048ca <release>
80104407:	83 c4 10             	add    $0x10,%esp
}
8010440a:	90                   	nop
8010440b:	c9                   	leave  
8010440c:	c3                   	ret    

8010440d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010440d:	55                   	push   %ebp
8010440e:	89 e5                	mov    %esp,%ebp
80104410:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104413:	83 ec 0c             	sub    $0xc,%esp
80104416:	68 00 42 19 80       	push   $0x80194200
8010441b:	e8 3c 04 00 00       	call   8010485c <acquire>
80104420:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104423:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010442a:	eb 45                	jmp    80104471 <kill+0x64>
    if(p->pid == pid){
8010442c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442f:	8b 40 10             	mov    0x10(%eax),%eax
80104432:	39 45 08             	cmp    %eax,0x8(%ebp)
80104435:	75 36                	jne    8010446d <kill+0x60>
      p->killed = 1;
80104437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104444:	8b 40 0c             	mov    0xc(%eax),%eax
80104447:	83 f8 02             	cmp    $0x2,%eax
8010444a:	75 0a                	jne    80104456 <kill+0x49>
        p->state = RUNNABLE;
8010444c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104456:	83 ec 0c             	sub    $0xc,%esp
80104459:	68 00 42 19 80       	push   $0x80194200
8010445e:	e8 67 04 00 00       	call   801048ca <release>
80104463:	83 c4 10             	add    $0x10,%esp
      return 0;
80104466:	b8 00 00 00 00       	mov    $0x0,%eax
8010446b:	eb 22                	jmp    8010448f <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010446d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104471:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104478:	72 b2                	jb     8010442c <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010447a:	83 ec 0c             	sub    $0xc,%esp
8010447d:	68 00 42 19 80       	push   $0x80194200
80104482:	e8 43 04 00 00       	call   801048ca <release>
80104487:	83 c4 10             	add    $0x10,%esp
  return -1;
8010448a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010448f:	c9                   	leave  
80104490:	c3                   	ret    

80104491 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104491:	55                   	push   %ebp
80104492:	89 e5                	mov    %esp,%ebp
80104494:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104497:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
8010449e:	e9 d7 00 00 00       	jmp    8010457a <procdump+0xe9>
    if(p->state == UNUSED)
801044a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a6:	8b 40 0c             	mov    0xc(%eax),%eax
801044a9:	85 c0                	test   %eax,%eax
801044ab:	0f 84 c4 00 00 00    	je     80104575 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b4:	8b 40 0c             	mov    0xc(%eax),%eax
801044b7:	83 f8 05             	cmp    $0x5,%eax
801044ba:	77 23                	ja     801044df <procdump+0x4e>
801044bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044bf:	8b 40 0c             	mov    0xc(%eax),%eax
801044c2:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044c9:	85 c0                	test   %eax,%eax
801044cb:	74 12                	je     801044df <procdump+0x4e>
      state = states[p->state];
801044cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d0:	8b 40 0c             	mov    0xc(%eax),%eax
801044d3:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044da:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044dd:	eb 07                	jmp    801044e6 <procdump+0x55>
    else
      state = "???";
801044df:	c7 45 ec 46 a6 10 80 	movl   $0x8010a646,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e9:	8d 50 6c             	lea    0x6c(%eax),%edx
801044ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ef:	8b 40 10             	mov    0x10(%eax),%eax
801044f2:	52                   	push   %edx
801044f3:	ff 75 ec             	push   -0x14(%ebp)
801044f6:	50                   	push   %eax
801044f7:	68 4a a6 10 80       	push   $0x8010a64a
801044fc:	e8 f3 be ff ff       	call   801003f4 <cprintf>
80104501:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104504:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104507:	8b 40 0c             	mov    0xc(%eax),%eax
8010450a:	83 f8 02             	cmp    $0x2,%eax
8010450d:	75 54                	jne    80104563 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010450f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104512:	8b 40 1c             	mov    0x1c(%eax),%eax
80104515:	8b 40 0c             	mov    0xc(%eax),%eax
80104518:	83 c0 08             	add    $0x8,%eax
8010451b:	89 c2                	mov    %eax,%edx
8010451d:	83 ec 08             	sub    $0x8,%esp
80104520:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104523:	50                   	push   %eax
80104524:	52                   	push   %edx
80104525:	e8 f2 03 00 00       	call   8010491c <getcallerpcs>
8010452a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010452d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104534:	eb 1c                	jmp    80104552 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104539:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010453d:	83 ec 08             	sub    $0x8,%esp
80104540:	50                   	push   %eax
80104541:	68 53 a6 10 80       	push   $0x8010a653
80104546:	e8 a9 be ff ff       	call   801003f4 <cprintf>
8010454b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010454e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104552:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104556:	7f 0b                	jg     80104563 <procdump+0xd2>
80104558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010455f:	85 c0                	test   %eax,%eax
80104561:	75 d3                	jne    80104536 <procdump+0xa5>
    }
    cprintf("\n");
80104563:	83 ec 0c             	sub    $0xc,%esp
80104566:	68 57 a6 10 80       	push   $0x8010a657
8010456b:	e8 84 be ff ff       	call   801003f4 <cprintf>
80104570:	83 c4 10             	add    $0x10,%esp
80104573:	eb 01                	jmp    80104576 <procdump+0xe5>
      continue;
80104575:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104576:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010457a:	81 7d f0 34 61 19 80 	cmpl   $0x80196134,-0x10(%ebp)
80104581:	0f 82 1c ff ff ff    	jb     801044a3 <procdump+0x12>
  }
}
80104587:	90                   	nop
80104588:	90                   	nop
80104589:	c9                   	leave  
8010458a:	c3                   	ret    

8010458b <printpt>:

int 
printpt(int pid) 
{ 
8010458b:	55                   	push   %ebp
8010458c:	89 e5                	mov    %esp,%ebp
8010458e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104591:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104598:	eb 0f                	jmp    801045a9 <printpt+0x1e>
    if (p->pid == pid)
8010459a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459d:	8b 40 10             	mov    0x10(%eax),%eax
801045a0:	39 45 08             	cmp    %eax,0x8(%ebp)
801045a3:	74 0f                	je     801045b4 <printpt+0x29>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801045a5:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801045a9:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801045b0:	72 e8                	jb     8010459a <printpt+0xf>
801045b2:	eb 01                	jmp    801045b5 <printpt+0x2a>
      break;
801045b4:	90                   	nop
  }

  if (p == &ptable.proc[NPROC]) {
801045b5:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801045bc:	75 1d                	jne    801045db <printpt+0x50>
    cprintf("printpt: pid %d not found\n", pid);
801045be:	83 ec 08             	sub    $0x8,%esp
801045c1:	ff 75 08             	push   0x8(%ebp)
801045c4:	68 59 a6 10 80       	push   $0x8010a659
801045c9:	e8 26 be ff ff       	call   801003f4 <cprintf>
801045ce:	83 c4 10             	add    $0x10,%esp
    return -1;
801045d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d6:	e9 00 01 00 00       	jmp    801046db <printpt+0x150>
  }

  if (p->pgdir == 0) {
801045db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045de:	8b 40 04             	mov    0x4(%eax),%eax
801045e1:	85 c0                	test   %eax,%eax
801045e3:	75 1d                	jne    80104602 <printpt+0x77>
    cprintf("printpt: pid %d has no pgdir\n", pid);
801045e5:	83 ec 08             	sub    $0x8,%esp
801045e8:	ff 75 08             	push   0x8(%ebp)
801045eb:	68 74 a6 10 80       	push   $0x8010a674
801045f0:	e8 ff bd ff ff       	call   801003f4 <cprintf>
801045f5:	83 c4 10             	add    $0x10,%esp
    return -1;
801045f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045fd:	e9 d9 00 00 00       	jmp    801046db <printpt+0x150>
  } 

  cprintf("START PAGE TABLE (pid %d)\n", pid);
80104602:	83 ec 08             	sub    $0x8,%esp
80104605:	ff 75 08             	push   0x8(%ebp)
80104608:	68 92 a6 10 80       	push   $0x8010a692
8010460d:	e8 e2 bd ff ff       	call   801003f4 <cprintf>
80104612:	83 c4 10             	add    $0x10,%esp

  for (uint va = 0; va < KERNBASE; va += PGSIZE) {
80104615:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010461c:	e9 9a 00 00 00       	jmp    801046bb <printpt+0x130>
    pte_t *pte = walkpgdir(p->pgdir, (void *)va, 0);
80104621:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104627:	8b 40 04             	mov    0x4(%eax),%eax
8010462a:	83 ec 04             	sub    $0x4,%esp
8010462d:	6a 00                	push   $0x0
8010462f:	52                   	push   %edx
80104630:	50                   	push   %eax
80104631:	e8 5c 2e 00 00       	call   80107492 <walkpgdir>
80104636:	83 c4 10             	add    $0x10,%esp
80104639:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pte && (*pte & PTE_P)) {
8010463c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104640:	74 72                	je     801046b4 <printpt+0x129>
80104642:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104645:	8b 00                	mov    (%eax),%eax
80104647:	83 e0 01             	and    $0x1,%eax
8010464a:	85 c0                	test   %eax,%eax
8010464c:	74 66                	je     801046b4 <printpt+0x129>
      const char *u = (*pte & PTE_U) ? "U" : "K";
8010464e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104651:	8b 00                	mov    (%eax),%eax
80104653:	83 e0 04             	and    $0x4,%eax
80104656:	85 c0                	test   %eax,%eax
80104658:	74 07                	je     80104661 <printpt+0xd6>
8010465a:	b8 ad a6 10 80       	mov    $0x8010a6ad,%eax
8010465f:	eb 05                	jmp    80104666 <printpt+0xdb>
80104661:	b8 af a6 10 80       	mov    $0x8010a6af,%eax
80104666:	89 45 e8             	mov    %eax,-0x18(%ebp)
      const char *w = (*pte & PTE_W) ? "W" : "-";
80104669:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010466c:	8b 00                	mov    (%eax),%eax
8010466e:	83 e0 02             	and    $0x2,%eax
80104671:	85 c0                	test   %eax,%eax
80104673:	74 07                	je     8010467c <printpt+0xf1>
80104675:	b8 b1 a6 10 80       	mov    $0x8010a6b1,%eax
8010467a:	eb 05                	jmp    80104681 <printpt+0xf6>
8010467c:	b8 b3 a6 10 80       	mov    $0x8010a6b3,%eax
80104681:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint vpn = va >> 12;
80104684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104687:	c1 e8 0c             	shr    $0xc,%eax
8010468a:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint ppn = PTE_ADDR(*pte) >> 12;
8010468d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104690:	8b 00                	mov    (%eax),%eax
80104692:	c1 e8 0c             	shr    $0xc,%eax
80104695:	89 45 dc             	mov    %eax,-0x24(%ebp)
      cprintf("%x P %s %s %x\n", vpn, u, w, ppn);
80104698:	83 ec 0c             	sub    $0xc,%esp
8010469b:	ff 75 dc             	push   -0x24(%ebp)
8010469e:	ff 75 e4             	push   -0x1c(%ebp)
801046a1:	ff 75 e8             	push   -0x18(%ebp)
801046a4:	ff 75 e0             	push   -0x20(%ebp)
801046a7:	68 b5 a6 10 80       	push   $0x8010a6b5
801046ac:	e8 43 bd ff ff       	call   801003f4 <cprintf>
801046b1:	83 c4 20             	add    $0x20,%esp
  for (uint va = 0; va < KERNBASE; va += PGSIZE) {
801046b4:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
801046bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046be:	85 c0                	test   %eax,%eax
801046c0:	0f 89 5b ff ff ff    	jns    80104621 <printpt+0x96>
    }
  }


  cprintf("END PAGE TABLE\n");
801046c6:	83 ec 0c             	sub    $0xc,%esp
801046c9:	68 c4 a6 10 80       	push   $0x8010a6c4
801046ce:	e8 21 bd ff ff       	call   801003f4 <cprintf>
801046d3:	83 c4 10             	add    $0x10,%esp
  return 0;
801046d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046db:	c9                   	leave  
801046dc:	c3                   	ret    

801046dd <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801046dd:	55                   	push   %ebp
801046de:	89 e5                	mov    %esp,%ebp
801046e0:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801046e3:	8b 45 08             	mov    0x8(%ebp),%eax
801046e6:	83 c0 04             	add    $0x4,%eax
801046e9:	83 ec 08             	sub    $0x8,%esp
801046ec:	68 fe a6 10 80       	push   $0x8010a6fe
801046f1:	50                   	push   %eax
801046f2:	e8 43 01 00 00       	call   8010483a <initlock>
801046f7:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801046fa:	8b 45 08             	mov    0x8(%ebp),%eax
801046fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80104700:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104703:	8b 45 08             	mov    0x8(%ebp),%eax
80104706:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010470c:	8b 45 08             	mov    0x8(%ebp),%eax
8010470f:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104716:	90                   	nop
80104717:	c9                   	leave  
80104718:	c3                   	ret    

80104719 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104719:	55                   	push   %ebp
8010471a:	89 e5                	mov    %esp,%ebp
8010471c:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010471f:	8b 45 08             	mov    0x8(%ebp),%eax
80104722:	83 c0 04             	add    $0x4,%eax
80104725:	83 ec 0c             	sub    $0xc,%esp
80104728:	50                   	push   %eax
80104729:	e8 2e 01 00 00       	call   8010485c <acquire>
8010472e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104731:	eb 15                	jmp    80104748 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104733:	8b 45 08             	mov    0x8(%ebp),%eax
80104736:	83 c0 04             	add    $0x4,%eax
80104739:	83 ec 08             	sub    $0x8,%esp
8010473c:	50                   	push   %eax
8010473d:	ff 75 08             	push   0x8(%ebp)
80104740:	e8 aa fb ff ff       	call   801042ef <sleep>
80104745:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104748:	8b 45 08             	mov    0x8(%ebp),%eax
8010474b:	8b 00                	mov    (%eax),%eax
8010474d:	85 c0                	test   %eax,%eax
8010474f:	75 e2                	jne    80104733 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104751:	8b 45 08             	mov    0x8(%ebp),%eax
80104754:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010475a:	e8 d2 f2 ff ff       	call   80103a31 <myproc>
8010475f:	8b 50 10             	mov    0x10(%eax),%edx
80104762:	8b 45 08             	mov    0x8(%ebp),%eax
80104765:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104768:	8b 45 08             	mov    0x8(%ebp),%eax
8010476b:	83 c0 04             	add    $0x4,%eax
8010476e:	83 ec 0c             	sub    $0xc,%esp
80104771:	50                   	push   %eax
80104772:	e8 53 01 00 00       	call   801048ca <release>
80104777:	83 c4 10             	add    $0x10,%esp
}
8010477a:	90                   	nop
8010477b:	c9                   	leave  
8010477c:	c3                   	ret    

8010477d <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010477d:	55                   	push   %ebp
8010477e:	89 e5                	mov    %esp,%ebp
80104780:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104783:	8b 45 08             	mov    0x8(%ebp),%eax
80104786:	83 c0 04             	add    $0x4,%eax
80104789:	83 ec 0c             	sub    $0xc,%esp
8010478c:	50                   	push   %eax
8010478d:	e8 ca 00 00 00       	call   8010485c <acquire>
80104792:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104795:	8b 45 08             	mov    0x8(%ebp),%eax
80104798:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010479e:	8b 45 08             	mov    0x8(%ebp),%eax
801047a1:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801047a8:	83 ec 0c             	sub    $0xc,%esp
801047ab:	ff 75 08             	push   0x8(%ebp)
801047ae:	e8 23 fc ff ff       	call   801043d6 <wakeup>
801047b3:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801047b6:	8b 45 08             	mov    0x8(%ebp),%eax
801047b9:	83 c0 04             	add    $0x4,%eax
801047bc:	83 ec 0c             	sub    $0xc,%esp
801047bf:	50                   	push   %eax
801047c0:	e8 05 01 00 00       	call   801048ca <release>
801047c5:	83 c4 10             	add    $0x10,%esp
}
801047c8:	90                   	nop
801047c9:	c9                   	leave  
801047ca:	c3                   	ret    

801047cb <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801047cb:	55                   	push   %ebp
801047cc:	89 e5                	mov    %esp,%ebp
801047ce:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801047d1:	8b 45 08             	mov    0x8(%ebp),%eax
801047d4:	83 c0 04             	add    $0x4,%eax
801047d7:	83 ec 0c             	sub    $0xc,%esp
801047da:	50                   	push   %eax
801047db:	e8 7c 00 00 00       	call   8010485c <acquire>
801047e0:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801047e3:	8b 45 08             	mov    0x8(%ebp),%eax
801047e6:	8b 00                	mov    (%eax),%eax
801047e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801047eb:	8b 45 08             	mov    0x8(%ebp),%eax
801047ee:	83 c0 04             	add    $0x4,%eax
801047f1:	83 ec 0c             	sub    $0xc,%esp
801047f4:	50                   	push   %eax
801047f5:	e8 d0 00 00 00       	call   801048ca <release>
801047fa:	83 c4 10             	add    $0x10,%esp
  return r;
801047fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104800:	c9                   	leave  
80104801:	c3                   	ret    

80104802 <readeflags>:
{
80104802:	55                   	push   %ebp
80104803:	89 e5                	mov    %esp,%ebp
80104805:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104808:	9c                   	pushf  
80104809:	58                   	pop    %eax
8010480a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010480d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104810:	c9                   	leave  
80104811:	c3                   	ret    

80104812 <cli>:
{
80104812:	55                   	push   %ebp
80104813:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104815:	fa                   	cli    
}
80104816:	90                   	nop
80104817:	5d                   	pop    %ebp
80104818:	c3                   	ret    

80104819 <sti>:
{
80104819:	55                   	push   %ebp
8010481a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010481c:	fb                   	sti    
}
8010481d:	90                   	nop
8010481e:	5d                   	pop    %ebp
8010481f:	c3                   	ret    

80104820 <xchg>:
{
80104820:	55                   	push   %ebp
80104821:	89 e5                	mov    %esp,%ebp
80104823:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104826:	8b 55 08             	mov    0x8(%ebp),%edx
80104829:	8b 45 0c             	mov    0xc(%ebp),%eax
8010482c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010482f:	f0 87 02             	lock xchg %eax,(%edx)
80104832:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104835:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104838:	c9                   	leave  
80104839:	c3                   	ret    

8010483a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010483a:	55                   	push   %ebp
8010483b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010483d:	8b 45 08             	mov    0x8(%ebp),%eax
80104840:	8b 55 0c             	mov    0xc(%ebp),%edx
80104843:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104846:	8b 45 08             	mov    0x8(%ebp),%eax
80104849:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010484f:	8b 45 08             	mov    0x8(%ebp),%eax
80104852:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104859:	90                   	nop
8010485a:	5d                   	pop    %ebp
8010485b:	c3                   	ret    

8010485c <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010485c:	55                   	push   %ebp
8010485d:	89 e5                	mov    %esp,%ebp
8010485f:	53                   	push   %ebx
80104860:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104863:	e8 5f 01 00 00       	call   801049c7 <pushcli>
  if(holding(lk)){
80104868:	8b 45 08             	mov    0x8(%ebp),%eax
8010486b:	83 ec 0c             	sub    $0xc,%esp
8010486e:	50                   	push   %eax
8010486f:	e8 23 01 00 00       	call   80104997 <holding>
80104874:	83 c4 10             	add    $0x10,%esp
80104877:	85 c0                	test   %eax,%eax
80104879:	74 0d                	je     80104888 <acquire+0x2c>
    panic("acquire");
8010487b:	83 ec 0c             	sub    $0xc,%esp
8010487e:	68 09 a7 10 80       	push   $0x8010a709
80104883:	e8 21 bd ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104888:	90                   	nop
80104889:	8b 45 08             	mov    0x8(%ebp),%eax
8010488c:	83 ec 08             	sub    $0x8,%esp
8010488f:	6a 01                	push   $0x1
80104891:	50                   	push   %eax
80104892:	e8 89 ff ff ff       	call   80104820 <xchg>
80104897:	83 c4 10             	add    $0x10,%esp
8010489a:	85 c0                	test   %eax,%eax
8010489c:	75 eb                	jne    80104889 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010489e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801048a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
801048a6:	e8 0e f1 ff ff       	call   801039b9 <mycpu>
801048ab:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801048ae:	8b 45 08             	mov    0x8(%ebp),%eax
801048b1:	83 c0 0c             	add    $0xc,%eax
801048b4:	83 ec 08             	sub    $0x8,%esp
801048b7:	50                   	push   %eax
801048b8:	8d 45 08             	lea    0x8(%ebp),%eax
801048bb:	50                   	push   %eax
801048bc:	e8 5b 00 00 00       	call   8010491c <getcallerpcs>
801048c1:	83 c4 10             	add    $0x10,%esp
}
801048c4:	90                   	nop
801048c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048c8:	c9                   	leave  
801048c9:	c3                   	ret    

801048ca <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801048ca:	55                   	push   %ebp
801048cb:	89 e5                	mov    %esp,%ebp
801048cd:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801048d0:	83 ec 0c             	sub    $0xc,%esp
801048d3:	ff 75 08             	push   0x8(%ebp)
801048d6:	e8 bc 00 00 00       	call   80104997 <holding>
801048db:	83 c4 10             	add    $0x10,%esp
801048de:	85 c0                	test   %eax,%eax
801048e0:	75 0d                	jne    801048ef <release+0x25>
    panic("release");
801048e2:	83 ec 0c             	sub    $0xc,%esp
801048e5:	68 11 a7 10 80       	push   $0x8010a711
801048ea:	e8 ba bc ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801048ef:	8b 45 08             	mov    0x8(%ebp),%eax
801048f2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801048f9:	8b 45 08             	mov    0x8(%ebp),%eax
801048fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104903:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104908:	8b 45 08             	mov    0x8(%ebp),%eax
8010490b:	8b 55 08             	mov    0x8(%ebp),%edx
8010490e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104914:	e8 fb 00 00 00       	call   80104a14 <popcli>
}
80104919:	90                   	nop
8010491a:	c9                   	leave  
8010491b:	c3                   	ret    

8010491c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010491c:	55                   	push   %ebp
8010491d:	89 e5                	mov    %esp,%ebp
8010491f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104922:	8b 45 08             	mov    0x8(%ebp),%eax
80104925:	83 e8 08             	sub    $0x8,%eax
80104928:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010492b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104932:	eb 38                	jmp    8010496c <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104934:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104938:	74 53                	je     8010498d <getcallerpcs+0x71>
8010493a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104941:	76 4a                	jbe    8010498d <getcallerpcs+0x71>
80104943:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104947:	74 44                	je     8010498d <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104949:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010494c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104953:	8b 45 0c             	mov    0xc(%ebp),%eax
80104956:	01 c2                	add    %eax,%edx
80104958:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010495b:	8b 40 04             	mov    0x4(%eax),%eax
8010495e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104960:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104963:	8b 00                	mov    (%eax),%eax
80104965:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104968:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010496c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104970:	7e c2                	jle    80104934 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104972:	eb 19                	jmp    8010498d <getcallerpcs+0x71>
    pcs[i] = 0;
80104974:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104977:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010497e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104981:	01 d0                	add    %edx,%eax
80104983:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104989:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010498d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104991:	7e e1                	jle    80104974 <getcallerpcs+0x58>
}
80104993:	90                   	nop
80104994:	90                   	nop
80104995:	c9                   	leave  
80104996:	c3                   	ret    

80104997 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104997:	55                   	push   %ebp
80104998:	89 e5                	mov    %esp,%ebp
8010499a:	53                   	push   %ebx
8010499b:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010499e:	8b 45 08             	mov    0x8(%ebp),%eax
801049a1:	8b 00                	mov    (%eax),%eax
801049a3:	85 c0                	test   %eax,%eax
801049a5:	74 16                	je     801049bd <holding+0x26>
801049a7:	8b 45 08             	mov    0x8(%ebp),%eax
801049aa:	8b 58 08             	mov    0x8(%eax),%ebx
801049ad:	e8 07 f0 ff ff       	call   801039b9 <mycpu>
801049b2:	39 c3                	cmp    %eax,%ebx
801049b4:	75 07                	jne    801049bd <holding+0x26>
801049b6:	b8 01 00 00 00       	mov    $0x1,%eax
801049bb:	eb 05                	jmp    801049c2 <holding+0x2b>
801049bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049c5:	c9                   	leave  
801049c6:	c3                   	ret    

801049c7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801049c7:	55                   	push   %ebp
801049c8:	89 e5                	mov    %esp,%ebp
801049ca:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801049cd:	e8 30 fe ff ff       	call   80104802 <readeflags>
801049d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801049d5:	e8 38 fe ff ff       	call   80104812 <cli>
  if(mycpu()->ncli == 0)
801049da:	e8 da ef ff ff       	call   801039b9 <mycpu>
801049df:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049e5:	85 c0                	test   %eax,%eax
801049e7:	75 14                	jne    801049fd <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801049e9:	e8 cb ef ff ff       	call   801039b9 <mycpu>
801049ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049f1:	81 e2 00 02 00 00    	and    $0x200,%edx
801049f7:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801049fd:	e8 b7 ef ff ff       	call   801039b9 <mycpu>
80104a02:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a08:	83 c2 01             	add    $0x1,%edx
80104a0b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104a11:	90                   	nop
80104a12:	c9                   	leave  
80104a13:	c3                   	ret    

80104a14 <popcli>:

void
popcli(void)
{
80104a14:	55                   	push   %ebp
80104a15:	89 e5                	mov    %esp,%ebp
80104a17:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104a1a:	e8 e3 fd ff ff       	call   80104802 <readeflags>
80104a1f:	25 00 02 00 00       	and    $0x200,%eax
80104a24:	85 c0                	test   %eax,%eax
80104a26:	74 0d                	je     80104a35 <popcli+0x21>
    panic("popcli - interruptible");
80104a28:	83 ec 0c             	sub    $0xc,%esp
80104a2b:	68 19 a7 10 80       	push   $0x8010a719
80104a30:	e8 74 bb ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104a35:	e8 7f ef ff ff       	call   801039b9 <mycpu>
80104a3a:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a40:	83 ea 01             	sub    $0x1,%edx
80104a43:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104a49:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a4f:	85 c0                	test   %eax,%eax
80104a51:	79 0d                	jns    80104a60 <popcli+0x4c>
    panic("popcli");
80104a53:	83 ec 0c             	sub    $0xc,%esp
80104a56:	68 30 a7 10 80       	push   $0x8010a730
80104a5b:	e8 49 bb ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a60:	e8 54 ef ff ff       	call   801039b9 <mycpu>
80104a65:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a6b:	85 c0                	test   %eax,%eax
80104a6d:	75 14                	jne    80104a83 <popcli+0x6f>
80104a6f:	e8 45 ef ff ff       	call   801039b9 <mycpu>
80104a74:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a7a:	85 c0                	test   %eax,%eax
80104a7c:	74 05                	je     80104a83 <popcli+0x6f>
    sti();
80104a7e:	e8 96 fd ff ff       	call   80104819 <sti>
}
80104a83:	90                   	nop
80104a84:	c9                   	leave  
80104a85:	c3                   	ret    

80104a86 <stosb>:
{
80104a86:	55                   	push   %ebp
80104a87:	89 e5                	mov    %esp,%ebp
80104a89:	57                   	push   %edi
80104a8a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a8e:	8b 55 10             	mov    0x10(%ebp),%edx
80104a91:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a94:	89 cb                	mov    %ecx,%ebx
80104a96:	89 df                	mov    %ebx,%edi
80104a98:	89 d1                	mov    %edx,%ecx
80104a9a:	fc                   	cld    
80104a9b:	f3 aa                	rep stos %al,%es:(%edi)
80104a9d:	89 ca                	mov    %ecx,%edx
80104a9f:	89 fb                	mov    %edi,%ebx
80104aa1:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104aa4:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104aa7:	90                   	nop
80104aa8:	5b                   	pop    %ebx
80104aa9:	5f                   	pop    %edi
80104aaa:	5d                   	pop    %ebp
80104aab:	c3                   	ret    

80104aac <stosl>:
{
80104aac:	55                   	push   %ebp
80104aad:	89 e5                	mov    %esp,%ebp
80104aaf:	57                   	push   %edi
80104ab0:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104ab1:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ab4:	8b 55 10             	mov    0x10(%ebp),%edx
80104ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aba:	89 cb                	mov    %ecx,%ebx
80104abc:	89 df                	mov    %ebx,%edi
80104abe:	89 d1                	mov    %edx,%ecx
80104ac0:	fc                   	cld    
80104ac1:	f3 ab                	rep stos %eax,%es:(%edi)
80104ac3:	89 ca                	mov    %ecx,%edx
80104ac5:	89 fb                	mov    %edi,%ebx
80104ac7:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104aca:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104acd:	90                   	nop
80104ace:	5b                   	pop    %ebx
80104acf:	5f                   	pop    %edi
80104ad0:	5d                   	pop    %ebp
80104ad1:	c3                   	ret    

80104ad2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104ad2:	55                   	push   %ebp
80104ad3:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad8:	83 e0 03             	and    $0x3,%eax
80104adb:	85 c0                	test   %eax,%eax
80104add:	75 43                	jne    80104b22 <memset+0x50>
80104adf:	8b 45 10             	mov    0x10(%ebp),%eax
80104ae2:	83 e0 03             	and    $0x3,%eax
80104ae5:	85 c0                	test   %eax,%eax
80104ae7:	75 39                	jne    80104b22 <memset+0x50>
    c &= 0xFF;
80104ae9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104af0:	8b 45 10             	mov    0x10(%ebp),%eax
80104af3:	c1 e8 02             	shr    $0x2,%eax
80104af6:	89 c2                	mov    %eax,%edx
80104af8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104afb:	c1 e0 18             	shl    $0x18,%eax
80104afe:	89 c1                	mov    %eax,%ecx
80104b00:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b03:	c1 e0 10             	shl    $0x10,%eax
80104b06:	09 c1                	or     %eax,%ecx
80104b08:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b0b:	c1 e0 08             	shl    $0x8,%eax
80104b0e:	09 c8                	or     %ecx,%eax
80104b10:	0b 45 0c             	or     0xc(%ebp),%eax
80104b13:	52                   	push   %edx
80104b14:	50                   	push   %eax
80104b15:	ff 75 08             	push   0x8(%ebp)
80104b18:	e8 8f ff ff ff       	call   80104aac <stosl>
80104b1d:	83 c4 0c             	add    $0xc,%esp
80104b20:	eb 12                	jmp    80104b34 <memset+0x62>
  } else
    stosb(dst, c, n);
80104b22:	8b 45 10             	mov    0x10(%ebp),%eax
80104b25:	50                   	push   %eax
80104b26:	ff 75 0c             	push   0xc(%ebp)
80104b29:	ff 75 08             	push   0x8(%ebp)
80104b2c:	e8 55 ff ff ff       	call   80104a86 <stosb>
80104b31:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104b34:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104b37:	c9                   	leave  
80104b38:	c3                   	ret    

80104b39 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b39:	55                   	push   %ebp
80104b3a:	89 e5                	mov    %esp,%ebp
80104b3c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104b3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b42:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104b45:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b48:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104b4b:	eb 30                	jmp    80104b7d <memcmp+0x44>
    if(*s1 != *s2)
80104b4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b50:	0f b6 10             	movzbl (%eax),%edx
80104b53:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b56:	0f b6 00             	movzbl (%eax),%eax
80104b59:	38 c2                	cmp    %al,%dl
80104b5b:	74 18                	je     80104b75 <memcmp+0x3c>
      return *s1 - *s2;
80104b5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b60:	0f b6 00             	movzbl (%eax),%eax
80104b63:	0f b6 d0             	movzbl %al,%edx
80104b66:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b69:	0f b6 00             	movzbl (%eax),%eax
80104b6c:	0f b6 c8             	movzbl %al,%ecx
80104b6f:	89 d0                	mov    %edx,%eax
80104b71:	29 c8                	sub    %ecx,%eax
80104b73:	eb 1a                	jmp    80104b8f <memcmp+0x56>
    s1++, s2++;
80104b75:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b79:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104b7d:	8b 45 10             	mov    0x10(%ebp),%eax
80104b80:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b83:	89 55 10             	mov    %edx,0x10(%ebp)
80104b86:	85 c0                	test   %eax,%eax
80104b88:	75 c3                	jne    80104b4d <memcmp+0x14>
  }

  return 0;
80104b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b8f:	c9                   	leave  
80104b90:	c3                   	ret    

80104b91 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104b91:	55                   	push   %ebp
80104b92:	89 e5                	mov    %esp,%ebp
80104b94:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104b97:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104ba3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ba6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104ba9:	73 54                	jae    80104bff <memmove+0x6e>
80104bab:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bae:	8b 45 10             	mov    0x10(%ebp),%eax
80104bb1:	01 d0                	add    %edx,%eax
80104bb3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104bb6:	73 47                	jae    80104bff <memmove+0x6e>
    s += n;
80104bb8:	8b 45 10             	mov    0x10(%ebp),%eax
80104bbb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104bbe:	8b 45 10             	mov    0x10(%ebp),%eax
80104bc1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104bc4:	eb 13                	jmp    80104bd9 <memmove+0x48>
      *--d = *--s;
80104bc6:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104bca:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104bce:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bd1:	0f b6 10             	movzbl (%eax),%edx
80104bd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bd7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bd9:	8b 45 10             	mov    0x10(%ebp),%eax
80104bdc:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bdf:	89 55 10             	mov    %edx,0x10(%ebp)
80104be2:	85 c0                	test   %eax,%eax
80104be4:	75 e0                	jne    80104bc6 <memmove+0x35>
  if(s < d && s + n > d){
80104be6:	eb 24                	jmp    80104c0c <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104be8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104beb:	8d 42 01             	lea    0x1(%edx),%eax
80104bee:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104bf1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bf4:	8d 48 01             	lea    0x1(%eax),%ecx
80104bf7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104bfa:	0f b6 12             	movzbl (%edx),%edx
80104bfd:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bff:	8b 45 10             	mov    0x10(%ebp),%eax
80104c02:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c05:	89 55 10             	mov    %edx,0x10(%ebp)
80104c08:	85 c0                	test   %eax,%eax
80104c0a:	75 dc                	jne    80104be8 <memmove+0x57>

  return dst;
80104c0c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104c0f:	c9                   	leave  
80104c10:	c3                   	ret    

80104c11 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104c11:	55                   	push   %ebp
80104c12:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104c14:	ff 75 10             	push   0x10(%ebp)
80104c17:	ff 75 0c             	push   0xc(%ebp)
80104c1a:	ff 75 08             	push   0x8(%ebp)
80104c1d:	e8 6f ff ff ff       	call   80104b91 <memmove>
80104c22:	83 c4 0c             	add    $0xc,%esp
}
80104c25:	c9                   	leave  
80104c26:	c3                   	ret    

80104c27 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c27:	55                   	push   %ebp
80104c28:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104c2a:	eb 0c                	jmp    80104c38 <strncmp+0x11>
    n--, p++, q++;
80104c2c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104c30:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104c34:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104c38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c3c:	74 1a                	je     80104c58 <strncmp+0x31>
80104c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c41:	0f b6 00             	movzbl (%eax),%eax
80104c44:	84 c0                	test   %al,%al
80104c46:	74 10                	je     80104c58 <strncmp+0x31>
80104c48:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4b:	0f b6 10             	movzbl (%eax),%edx
80104c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c51:	0f b6 00             	movzbl (%eax),%eax
80104c54:	38 c2                	cmp    %al,%dl
80104c56:	74 d4                	je     80104c2c <strncmp+0x5>
  if(n == 0)
80104c58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c5c:	75 07                	jne    80104c65 <strncmp+0x3e>
    return 0;
80104c5e:	b8 00 00 00 00       	mov    $0x0,%eax
80104c63:	eb 16                	jmp    80104c7b <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104c65:	8b 45 08             	mov    0x8(%ebp),%eax
80104c68:	0f b6 00             	movzbl (%eax),%eax
80104c6b:	0f b6 d0             	movzbl %al,%edx
80104c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c71:	0f b6 00             	movzbl (%eax),%eax
80104c74:	0f b6 c8             	movzbl %al,%ecx
80104c77:	89 d0                	mov    %edx,%eax
80104c79:	29 c8                	sub    %ecx,%eax
}
80104c7b:	5d                   	pop    %ebp
80104c7c:	c3                   	ret    

80104c7d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c7d:	55                   	push   %ebp
80104c7e:	89 e5                	mov    %esp,%ebp
80104c80:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c83:	8b 45 08             	mov    0x8(%ebp),%eax
80104c86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c89:	90                   	nop
80104c8a:	8b 45 10             	mov    0x10(%ebp),%eax
80104c8d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c90:	89 55 10             	mov    %edx,0x10(%ebp)
80104c93:	85 c0                	test   %eax,%eax
80104c95:	7e 2c                	jle    80104cc3 <strncpy+0x46>
80104c97:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c9a:	8d 42 01             	lea    0x1(%edx),%eax
80104c9d:	89 45 0c             	mov    %eax,0xc(%ebp)
80104ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca3:	8d 48 01             	lea    0x1(%eax),%ecx
80104ca6:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104ca9:	0f b6 12             	movzbl (%edx),%edx
80104cac:	88 10                	mov    %dl,(%eax)
80104cae:	0f b6 00             	movzbl (%eax),%eax
80104cb1:	84 c0                	test   %al,%al
80104cb3:	75 d5                	jne    80104c8a <strncpy+0xd>
    ;
  while(n-- > 0)
80104cb5:	eb 0c                	jmp    80104cc3 <strncpy+0x46>
    *s++ = 0;
80104cb7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cba:	8d 50 01             	lea    0x1(%eax),%edx
80104cbd:	89 55 08             	mov    %edx,0x8(%ebp)
80104cc0:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104cc3:	8b 45 10             	mov    0x10(%ebp),%eax
80104cc6:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cc9:	89 55 10             	mov    %edx,0x10(%ebp)
80104ccc:	85 c0                	test   %eax,%eax
80104cce:	7f e7                	jg     80104cb7 <strncpy+0x3a>
  return os;
80104cd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cd3:	c9                   	leave  
80104cd4:	c3                   	ret    

80104cd5 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104cd5:	55                   	push   %ebp
80104cd6:	89 e5                	mov    %esp,%ebp
80104cd8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cde:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104ce1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ce5:	7f 05                	jg     80104cec <safestrcpy+0x17>
    return os;
80104ce7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cea:	eb 32                	jmp    80104d1e <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104cec:	90                   	nop
80104ced:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104cf1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cf5:	7e 1e                	jle    80104d15 <safestrcpy+0x40>
80104cf7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cfa:	8d 42 01             	lea    0x1(%edx),%eax
80104cfd:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d00:	8b 45 08             	mov    0x8(%ebp),%eax
80104d03:	8d 48 01             	lea    0x1(%eax),%ecx
80104d06:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d09:	0f b6 12             	movzbl (%edx),%edx
80104d0c:	88 10                	mov    %dl,(%eax)
80104d0e:	0f b6 00             	movzbl (%eax),%eax
80104d11:	84 c0                	test   %al,%al
80104d13:	75 d8                	jne    80104ced <safestrcpy+0x18>
    ;
  *s = 0;
80104d15:	8b 45 08             	mov    0x8(%ebp),%eax
80104d18:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104d1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d1e:	c9                   	leave  
80104d1f:	c3                   	ret    

80104d20 <strlen>:

int
strlen(const char *s)
{
80104d20:	55                   	push   %ebp
80104d21:	89 e5                	mov    %esp,%ebp
80104d23:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104d26:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d2d:	eb 04                	jmp    80104d33 <strlen+0x13>
80104d2f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d33:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d36:	8b 45 08             	mov    0x8(%ebp),%eax
80104d39:	01 d0                	add    %edx,%eax
80104d3b:	0f b6 00             	movzbl (%eax),%eax
80104d3e:	84 c0                	test   %al,%al
80104d40:	75 ed                	jne    80104d2f <strlen+0xf>
    ;
  return n;
80104d42:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d45:	c9                   	leave  
80104d46:	c3                   	ret    

80104d47 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d47:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d4b:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d4f:	55                   	push   %ebp
  pushl %ebx
80104d50:	53                   	push   %ebx
  pushl %esi
80104d51:	56                   	push   %esi
  pushl %edi
80104d52:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d53:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d55:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d57:	5f                   	pop    %edi
  popl %esi
80104d58:	5e                   	pop    %esi
  popl %ebx
80104d59:	5b                   	pop    %ebx
  popl %ebp
80104d5a:	5d                   	pop    %ebp
  ret
80104d5b:	c3                   	ret    

80104d5c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d5c:	55                   	push   %ebp
80104d5d:	89 e5                	mov    %esp,%ebp
  if(addr >= KERNBASE || addr+4 > KERNBASE)
80104d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d62:	85 c0                	test   %eax,%eax
80104d64:	78 0d                	js     80104d73 <fetchint+0x17>
80104d66:	8b 45 08             	mov    0x8(%ebp),%eax
80104d69:	83 c0 04             	add    $0x4,%eax
80104d6c:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104d71:	76 07                	jbe    80104d7a <fetchint+0x1e>
    return -1;
80104d73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d78:	eb 0f                	jmp    80104d89 <fetchint+0x2d>
  *ip = *(int*)(addr);
80104d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7d:	8b 10                	mov    (%eax),%edx
80104d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d82:	89 10                	mov    %edx,(%eax)
  return 0;
80104d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d89:	5d                   	pop    %ebp
80104d8a:	c3                   	ret    

80104d8b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104d8b:	55                   	push   %ebp
80104d8c:	89 e5                	mov    %esp,%ebp
80104d8e:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
80104d91:	8b 45 08             	mov    0x8(%ebp),%eax
80104d94:	85 c0                	test   %eax,%eax
80104d96:	79 07                	jns    80104d9f <fetchstr+0x14>
    return -1;
80104d98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d9d:	eb 40                	jmp    80104ddf <fetchstr+0x54>
  *pp = (char*)addr;
80104d9f:	8b 55 08             	mov    0x8(%ebp),%edx
80104da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da5:	89 10                	mov    %edx,(%eax)
  ep = (char*)KERNBASE;
80104da7:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80104dae:	8b 45 0c             	mov    0xc(%ebp),%eax
80104db1:	8b 00                	mov    (%eax),%eax
80104db3:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104db6:	eb 1a                	jmp    80104dd2 <fetchstr+0x47>
    if(*s == 0)
80104db8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dbb:	0f b6 00             	movzbl (%eax),%eax
80104dbe:	84 c0                	test   %al,%al
80104dc0:	75 0c                	jne    80104dce <fetchstr+0x43>
      return s - *pp;
80104dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc5:	8b 10                	mov    (%eax),%edx
80104dc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dca:	29 d0                	sub    %edx,%eax
80104dcc:	eb 11                	jmp    80104ddf <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
80104dce:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104dd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dd5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104dd8:	72 de                	jb     80104db8 <fetchstr+0x2d>
  }
  return -1;
80104dda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ddf:	c9                   	leave  
80104de0:	c3                   	ret    

80104de1 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104de1:	55                   	push   %ebp
80104de2:	89 e5                	mov    %esp,%ebp
80104de4:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104de7:	e8 45 ec ff ff       	call   80103a31 <myproc>
80104dec:	8b 40 18             	mov    0x18(%eax),%eax
80104def:	8b 50 44             	mov    0x44(%eax),%edx
80104df2:	8b 45 08             	mov    0x8(%ebp),%eax
80104df5:	c1 e0 02             	shl    $0x2,%eax
80104df8:	01 d0                	add    %edx,%eax
80104dfa:	83 c0 04             	add    $0x4,%eax
80104dfd:	83 ec 08             	sub    $0x8,%esp
80104e00:	ff 75 0c             	push   0xc(%ebp)
80104e03:	50                   	push   %eax
80104e04:	e8 53 ff ff ff       	call   80104d5c <fetchint>
80104e09:	83 c4 10             	add    $0x10,%esp
}
80104e0c:	c9                   	leave  
80104e0d:	c3                   	ret    

80104e0e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104e0e:	55                   	push   %ebp
80104e0f:	89 e5                	mov    %esp,%ebp
80104e11:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
80104e14:	83 ec 08             	sub    $0x8,%esp
80104e17:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e1a:	50                   	push   %eax
80104e1b:	ff 75 08             	push   0x8(%ebp)
80104e1e:	e8 be ff ff ff       	call   80104de1 <argint>
80104e23:	83 c4 10             	add    $0x10,%esp
80104e26:	85 c0                	test   %eax,%eax
80104e28:	79 07                	jns    80104e31 <argptr+0x23>
    return -1;
80104e2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e2f:	eb 34                	jmp    80104e65 <argptr+0x57>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80104e31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e35:	78 18                	js     80104e4f <argptr+0x41>
80104e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3a:	85 c0                	test   %eax,%eax
80104e3c:	78 11                	js     80104e4f <argptr+0x41>
80104e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e41:	89 c2                	mov    %eax,%edx
80104e43:	8b 45 10             	mov    0x10(%ebp),%eax
80104e46:	01 d0                	add    %edx,%eax
80104e48:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104e4d:	76 07                	jbe    80104e56 <argptr+0x48>
    return -1;
80104e4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e54:	eb 0f                	jmp    80104e65 <argptr+0x57>
  *pp = (char*)i;
80104e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e59:	89 c2                	mov    %eax,%edx
80104e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5e:	89 10                	mov    %edx,(%eax)
  return 0;
80104e60:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e65:	c9                   	leave  
80104e66:	c3                   	ret    

80104e67 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104e67:	55                   	push   %ebp
80104e68:	89 e5                	mov    %esp,%ebp
80104e6a:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104e6d:	83 ec 08             	sub    $0x8,%esp
80104e70:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e73:	50                   	push   %eax
80104e74:	ff 75 08             	push   0x8(%ebp)
80104e77:	e8 65 ff ff ff       	call   80104de1 <argint>
80104e7c:	83 c4 10             	add    $0x10,%esp
80104e7f:	85 c0                	test   %eax,%eax
80104e81:	79 07                	jns    80104e8a <argstr+0x23>
    return -1;
80104e83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e88:	eb 12                	jmp    80104e9c <argstr+0x35>
  return fetchstr(addr, pp);
80104e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8d:	83 ec 08             	sub    $0x8,%esp
80104e90:	ff 75 0c             	push   0xc(%ebp)
80104e93:	50                   	push   %eax
80104e94:	e8 f2 fe ff ff       	call   80104d8b <fetchstr>
80104e99:	83 c4 10             	add    $0x10,%esp
}
80104e9c:	c9                   	leave  
80104e9d:	c3                   	ret    

80104e9e <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80104e9e:	55                   	push   %ebp
80104e9f:	89 e5                	mov    %esp,%ebp
80104ea1:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104ea4:	e8 88 eb ff ff       	call   80103a31 <myproc>
80104ea9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eaf:	8b 40 18             	mov    0x18(%eax),%eax
80104eb2:	8b 40 1c             	mov    0x1c(%eax),%eax
80104eb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104eb8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ebc:	7e 2f                	jle    80104eed <syscall+0x4f>
80104ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec1:	83 f8 16             	cmp    $0x16,%eax
80104ec4:	77 27                	ja     80104eed <syscall+0x4f>
80104ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec9:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104ed0:	85 c0                	test   %eax,%eax
80104ed2:	74 19                	je     80104eed <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed7:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104ede:	ff d0                	call   *%eax
80104ee0:	89 c2                	mov    %eax,%edx
80104ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee5:	8b 40 18             	mov    0x18(%eax),%eax
80104ee8:	89 50 1c             	mov    %edx,0x1c(%eax)
80104eeb:	eb 2c                	jmp    80104f19 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef0:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef6:	8b 40 10             	mov    0x10(%eax),%eax
80104ef9:	ff 75 f0             	push   -0x10(%ebp)
80104efc:	52                   	push   %edx
80104efd:	50                   	push   %eax
80104efe:	68 37 a7 10 80       	push   $0x8010a737
80104f03:	e8 ec b4 ff ff       	call   801003f4 <cprintf>
80104f08:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0e:	8b 40 18             	mov    0x18(%eax),%eax
80104f11:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104f18:	90                   	nop
80104f19:	90                   	nop
80104f1a:	c9                   	leave  
80104f1b:	c3                   	ret    

80104f1c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104f1c:	55                   	push   %ebp
80104f1d:	89 e5                	mov    %esp,%ebp
80104f1f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104f22:	83 ec 08             	sub    $0x8,%esp
80104f25:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f28:	50                   	push   %eax
80104f29:	ff 75 08             	push   0x8(%ebp)
80104f2c:	e8 b0 fe ff ff       	call   80104de1 <argint>
80104f31:	83 c4 10             	add    $0x10,%esp
80104f34:	85 c0                	test   %eax,%eax
80104f36:	79 07                	jns    80104f3f <argfd+0x23>
    return -1;
80104f38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f3d:	eb 4f                	jmp    80104f8e <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f42:	85 c0                	test   %eax,%eax
80104f44:	78 20                	js     80104f66 <argfd+0x4a>
80104f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f49:	83 f8 0f             	cmp    $0xf,%eax
80104f4c:	7f 18                	jg     80104f66 <argfd+0x4a>
80104f4e:	e8 de ea ff ff       	call   80103a31 <myproc>
80104f53:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f56:	83 c2 08             	add    $0x8,%edx
80104f59:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f64:	75 07                	jne    80104f6d <argfd+0x51>
    return -1;
80104f66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f6b:	eb 21                	jmp    80104f8e <argfd+0x72>
  if(pfd)
80104f6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f71:	74 08                	je     80104f7b <argfd+0x5f>
    *pfd = fd;
80104f73:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f76:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f79:	89 10                	mov    %edx,(%eax)
  if(pf)
80104f7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f7f:	74 08                	je     80104f89 <argfd+0x6d>
    *pf = f;
80104f81:	8b 45 10             	mov    0x10(%ebp),%eax
80104f84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f87:	89 10                	mov    %edx,(%eax)
  return 0;
80104f89:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f8e:	c9                   	leave  
80104f8f:	c3                   	ret    

80104f90 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104f90:	55                   	push   %ebp
80104f91:	89 e5                	mov    %esp,%ebp
80104f93:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104f96:	e8 96 ea ff ff       	call   80103a31 <myproc>
80104f9b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104f9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fa5:	eb 2a                	jmp    80104fd1 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104fa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104faa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fad:	83 c2 08             	add    $0x8,%edx
80104fb0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fb4:	85 c0                	test   %eax,%eax
80104fb6:	75 15                	jne    80104fcd <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fbe:	8d 4a 08             	lea    0x8(%edx),%ecx
80104fc1:	8b 55 08             	mov    0x8(%ebp),%edx
80104fc4:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcb:	eb 0f                	jmp    80104fdc <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104fcd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fd1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104fd5:	7e d0                	jle    80104fa7 <fdalloc+0x17>
    }
  }
  return -1;
80104fd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fdc:	c9                   	leave  
80104fdd:	c3                   	ret    

80104fde <sys_dup>:

int
sys_dup(void)
{
80104fde:	55                   	push   %ebp
80104fdf:	89 e5                	mov    %esp,%ebp
80104fe1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104fe4:	83 ec 04             	sub    $0x4,%esp
80104fe7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fea:	50                   	push   %eax
80104feb:	6a 00                	push   $0x0
80104fed:	6a 00                	push   $0x0
80104fef:	e8 28 ff ff ff       	call   80104f1c <argfd>
80104ff4:	83 c4 10             	add    $0x10,%esp
80104ff7:	85 c0                	test   %eax,%eax
80104ff9:	79 07                	jns    80105002 <sys_dup+0x24>
    return -1;
80104ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105000:	eb 31                	jmp    80105033 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105002:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105005:	83 ec 0c             	sub    $0xc,%esp
80105008:	50                   	push   %eax
80105009:	e8 82 ff ff ff       	call   80104f90 <fdalloc>
8010500e:	83 c4 10             	add    $0x10,%esp
80105011:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105014:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105018:	79 07                	jns    80105021 <sys_dup+0x43>
    return -1;
8010501a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010501f:	eb 12                	jmp    80105033 <sys_dup+0x55>
  filedup(f);
80105021:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105024:	83 ec 0c             	sub    $0xc,%esp
80105027:	50                   	push   %eax
80105028:	e8 1e c0 ff ff       	call   8010104b <filedup>
8010502d:	83 c4 10             	add    $0x10,%esp
  return fd;
80105030:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105033:	c9                   	leave  
80105034:	c3                   	ret    

80105035 <sys_read>:

int
sys_read(void)
{
80105035:	55                   	push   %ebp
80105036:	89 e5                	mov    %esp,%ebp
80105038:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010503b:	83 ec 04             	sub    $0x4,%esp
8010503e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105041:	50                   	push   %eax
80105042:	6a 00                	push   $0x0
80105044:	6a 00                	push   $0x0
80105046:	e8 d1 fe ff ff       	call   80104f1c <argfd>
8010504b:	83 c4 10             	add    $0x10,%esp
8010504e:	85 c0                	test   %eax,%eax
80105050:	78 2e                	js     80105080 <sys_read+0x4b>
80105052:	83 ec 08             	sub    $0x8,%esp
80105055:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105058:	50                   	push   %eax
80105059:	6a 02                	push   $0x2
8010505b:	e8 81 fd ff ff       	call   80104de1 <argint>
80105060:	83 c4 10             	add    $0x10,%esp
80105063:	85 c0                	test   %eax,%eax
80105065:	78 19                	js     80105080 <sys_read+0x4b>
80105067:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506a:	83 ec 04             	sub    $0x4,%esp
8010506d:	50                   	push   %eax
8010506e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105071:	50                   	push   %eax
80105072:	6a 01                	push   $0x1
80105074:	e8 95 fd ff ff       	call   80104e0e <argptr>
80105079:	83 c4 10             	add    $0x10,%esp
8010507c:	85 c0                	test   %eax,%eax
8010507e:	79 07                	jns    80105087 <sys_read+0x52>
    return -1;
80105080:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105085:	eb 17                	jmp    8010509e <sys_read+0x69>
  return fileread(f, p, n);
80105087:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010508a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010508d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105090:	83 ec 04             	sub    $0x4,%esp
80105093:	51                   	push   %ecx
80105094:	52                   	push   %edx
80105095:	50                   	push   %eax
80105096:	e8 40 c1 ff ff       	call   801011db <fileread>
8010509b:	83 c4 10             	add    $0x10,%esp
}
8010509e:	c9                   	leave  
8010509f:	c3                   	ret    

801050a0 <sys_write>:

int
sys_write(void)
{
801050a0:	55                   	push   %ebp
801050a1:	89 e5                	mov    %esp,%ebp
801050a3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801050a6:	83 ec 04             	sub    $0x4,%esp
801050a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050ac:	50                   	push   %eax
801050ad:	6a 00                	push   $0x0
801050af:	6a 00                	push   $0x0
801050b1:	e8 66 fe ff ff       	call   80104f1c <argfd>
801050b6:	83 c4 10             	add    $0x10,%esp
801050b9:	85 c0                	test   %eax,%eax
801050bb:	78 2e                	js     801050eb <sys_write+0x4b>
801050bd:	83 ec 08             	sub    $0x8,%esp
801050c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050c3:	50                   	push   %eax
801050c4:	6a 02                	push   $0x2
801050c6:	e8 16 fd ff ff       	call   80104de1 <argint>
801050cb:	83 c4 10             	add    $0x10,%esp
801050ce:	85 c0                	test   %eax,%eax
801050d0:	78 19                	js     801050eb <sys_write+0x4b>
801050d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d5:	83 ec 04             	sub    $0x4,%esp
801050d8:	50                   	push   %eax
801050d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801050dc:	50                   	push   %eax
801050dd:	6a 01                	push   $0x1
801050df:	e8 2a fd ff ff       	call   80104e0e <argptr>
801050e4:	83 c4 10             	add    $0x10,%esp
801050e7:	85 c0                	test   %eax,%eax
801050e9:	79 07                	jns    801050f2 <sys_write+0x52>
    return -1;
801050eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050f0:	eb 17                	jmp    80105109 <sys_write+0x69>
  return filewrite(f, p, n);
801050f2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801050f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fb:	83 ec 04             	sub    $0x4,%esp
801050fe:	51                   	push   %ecx
801050ff:	52                   	push   %edx
80105100:	50                   	push   %eax
80105101:	e8 8d c1 ff ff       	call   80101293 <filewrite>
80105106:	83 c4 10             	add    $0x10,%esp
}
80105109:	c9                   	leave  
8010510a:	c3                   	ret    

8010510b <sys_close>:

int
sys_close(void)
{
8010510b:	55                   	push   %ebp
8010510c:	89 e5                	mov    %esp,%ebp
8010510e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105111:	83 ec 04             	sub    $0x4,%esp
80105114:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105117:	50                   	push   %eax
80105118:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010511b:	50                   	push   %eax
8010511c:	6a 00                	push   $0x0
8010511e:	e8 f9 fd ff ff       	call   80104f1c <argfd>
80105123:	83 c4 10             	add    $0x10,%esp
80105126:	85 c0                	test   %eax,%eax
80105128:	79 07                	jns    80105131 <sys_close+0x26>
    return -1;
8010512a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010512f:	eb 27                	jmp    80105158 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105131:	e8 fb e8 ff ff       	call   80103a31 <myproc>
80105136:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105139:	83 c2 08             	add    $0x8,%edx
8010513c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105143:	00 
  fileclose(f);
80105144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105147:	83 ec 0c             	sub    $0xc,%esp
8010514a:	50                   	push   %eax
8010514b:	e8 4c bf ff ff       	call   8010109c <fileclose>
80105150:	83 c4 10             	add    $0x10,%esp
  return 0;
80105153:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105158:	c9                   	leave  
80105159:	c3                   	ret    

8010515a <sys_fstat>:

int
sys_fstat(void)
{
8010515a:	55                   	push   %ebp
8010515b:	89 e5                	mov    %esp,%ebp
8010515d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105160:	83 ec 04             	sub    $0x4,%esp
80105163:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105166:	50                   	push   %eax
80105167:	6a 00                	push   $0x0
80105169:	6a 00                	push   $0x0
8010516b:	e8 ac fd ff ff       	call   80104f1c <argfd>
80105170:	83 c4 10             	add    $0x10,%esp
80105173:	85 c0                	test   %eax,%eax
80105175:	78 17                	js     8010518e <sys_fstat+0x34>
80105177:	83 ec 04             	sub    $0x4,%esp
8010517a:	6a 14                	push   $0x14
8010517c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010517f:	50                   	push   %eax
80105180:	6a 01                	push   $0x1
80105182:	e8 87 fc ff ff       	call   80104e0e <argptr>
80105187:	83 c4 10             	add    $0x10,%esp
8010518a:	85 c0                	test   %eax,%eax
8010518c:	79 07                	jns    80105195 <sys_fstat+0x3b>
    return -1;
8010518e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105193:	eb 13                	jmp    801051a8 <sys_fstat+0x4e>
  return filestat(f, st);
80105195:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519b:	83 ec 08             	sub    $0x8,%esp
8010519e:	52                   	push   %edx
8010519f:	50                   	push   %eax
801051a0:	e8 df bf ff ff       	call   80101184 <filestat>
801051a5:	83 c4 10             	add    $0x10,%esp
}
801051a8:	c9                   	leave  
801051a9:	c3                   	ret    

801051aa <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801051aa:	55                   	push   %ebp
801051ab:	89 e5                	mov    %esp,%ebp
801051ad:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801051b0:	83 ec 08             	sub    $0x8,%esp
801051b3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801051b6:	50                   	push   %eax
801051b7:	6a 00                	push   $0x0
801051b9:	e8 a9 fc ff ff       	call   80104e67 <argstr>
801051be:	83 c4 10             	add    $0x10,%esp
801051c1:	85 c0                	test   %eax,%eax
801051c3:	78 15                	js     801051da <sys_link+0x30>
801051c5:	83 ec 08             	sub    $0x8,%esp
801051c8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801051cb:	50                   	push   %eax
801051cc:	6a 01                	push   $0x1
801051ce:	e8 94 fc ff ff       	call   80104e67 <argstr>
801051d3:	83 c4 10             	add    $0x10,%esp
801051d6:	85 c0                	test   %eax,%eax
801051d8:	79 0a                	jns    801051e4 <sys_link+0x3a>
    return -1;
801051da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051df:	e9 68 01 00 00       	jmp    8010534c <sys_link+0x1a2>

  begin_op();
801051e4:	e8 54 de ff ff       	call   8010303d <begin_op>
  if((ip = namei(old)) == 0){
801051e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801051ec:	83 ec 0c             	sub    $0xc,%esp
801051ef:	50                   	push   %eax
801051f0:	e8 29 d3 ff ff       	call   8010251e <namei>
801051f5:	83 c4 10             	add    $0x10,%esp
801051f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051ff:	75 0f                	jne    80105210 <sys_link+0x66>
    end_op();
80105201:	e8 c3 de ff ff       	call   801030c9 <end_op>
    return -1;
80105206:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520b:	e9 3c 01 00 00       	jmp    8010534c <sys_link+0x1a2>
  }

  ilock(ip);
80105210:	83 ec 0c             	sub    $0xc,%esp
80105213:	ff 75 f4             	push   -0xc(%ebp)
80105216:	e8 d0 c7 ff ff       	call   801019eb <ilock>
8010521b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010521e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105221:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105225:	66 83 f8 01          	cmp    $0x1,%ax
80105229:	75 1d                	jne    80105248 <sys_link+0x9e>
    iunlockput(ip);
8010522b:	83 ec 0c             	sub    $0xc,%esp
8010522e:	ff 75 f4             	push   -0xc(%ebp)
80105231:	e8 e6 c9 ff ff       	call   80101c1c <iunlockput>
80105236:	83 c4 10             	add    $0x10,%esp
    end_op();
80105239:	e8 8b de ff ff       	call   801030c9 <end_op>
    return -1;
8010523e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105243:	e9 04 01 00 00       	jmp    8010534c <sys_link+0x1a2>
  }

  ip->nlink++;
80105248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010524f:	83 c0 01             	add    $0x1,%eax
80105252:	89 c2                	mov    %eax,%edx
80105254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105257:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010525b:	83 ec 0c             	sub    $0xc,%esp
8010525e:	ff 75 f4             	push   -0xc(%ebp)
80105261:	e8 a8 c5 ff ff       	call   8010180e <iupdate>
80105266:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105269:	83 ec 0c             	sub    $0xc,%esp
8010526c:	ff 75 f4             	push   -0xc(%ebp)
8010526f:	e8 8a c8 ff ff       	call   80101afe <iunlock>
80105274:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105277:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010527a:	83 ec 08             	sub    $0x8,%esp
8010527d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105280:	52                   	push   %edx
80105281:	50                   	push   %eax
80105282:	e8 b3 d2 ff ff       	call   8010253a <nameiparent>
80105287:	83 c4 10             	add    $0x10,%esp
8010528a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010528d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105291:	74 71                	je     80105304 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105293:	83 ec 0c             	sub    $0xc,%esp
80105296:	ff 75 f0             	push   -0x10(%ebp)
80105299:	e8 4d c7 ff ff       	call   801019eb <ilock>
8010529e:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801052a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052a4:	8b 10                	mov    (%eax),%edx
801052a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a9:	8b 00                	mov    (%eax),%eax
801052ab:	39 c2                	cmp    %eax,%edx
801052ad:	75 1d                	jne    801052cc <sys_link+0x122>
801052af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b2:	8b 40 04             	mov    0x4(%eax),%eax
801052b5:	83 ec 04             	sub    $0x4,%esp
801052b8:	50                   	push   %eax
801052b9:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801052bc:	50                   	push   %eax
801052bd:	ff 75 f0             	push   -0x10(%ebp)
801052c0:	e8 c2 cf ff ff       	call   80102287 <dirlink>
801052c5:	83 c4 10             	add    $0x10,%esp
801052c8:	85 c0                	test   %eax,%eax
801052ca:	79 10                	jns    801052dc <sys_link+0x132>
    iunlockput(dp);
801052cc:	83 ec 0c             	sub    $0xc,%esp
801052cf:	ff 75 f0             	push   -0x10(%ebp)
801052d2:	e8 45 c9 ff ff       	call   80101c1c <iunlockput>
801052d7:	83 c4 10             	add    $0x10,%esp
    goto bad;
801052da:	eb 29                	jmp    80105305 <sys_link+0x15b>
  }
  iunlockput(dp);
801052dc:	83 ec 0c             	sub    $0xc,%esp
801052df:	ff 75 f0             	push   -0x10(%ebp)
801052e2:	e8 35 c9 ff ff       	call   80101c1c <iunlockput>
801052e7:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801052ea:	83 ec 0c             	sub    $0xc,%esp
801052ed:	ff 75 f4             	push   -0xc(%ebp)
801052f0:	e8 57 c8 ff ff       	call   80101b4c <iput>
801052f5:	83 c4 10             	add    $0x10,%esp

  end_op();
801052f8:	e8 cc dd ff ff       	call   801030c9 <end_op>

  return 0;
801052fd:	b8 00 00 00 00       	mov    $0x0,%eax
80105302:	eb 48                	jmp    8010534c <sys_link+0x1a2>
    goto bad;
80105304:	90                   	nop

bad:
  ilock(ip);
80105305:	83 ec 0c             	sub    $0xc,%esp
80105308:	ff 75 f4             	push   -0xc(%ebp)
8010530b:	e8 db c6 ff ff       	call   801019eb <ilock>
80105310:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105316:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010531a:	83 e8 01             	sub    $0x1,%eax
8010531d:	89 c2                	mov    %eax,%edx
8010531f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105322:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105326:	83 ec 0c             	sub    $0xc,%esp
80105329:	ff 75 f4             	push   -0xc(%ebp)
8010532c:	e8 dd c4 ff ff       	call   8010180e <iupdate>
80105331:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105334:	83 ec 0c             	sub    $0xc,%esp
80105337:	ff 75 f4             	push   -0xc(%ebp)
8010533a:	e8 dd c8 ff ff       	call   80101c1c <iunlockput>
8010533f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105342:	e8 82 dd ff ff       	call   801030c9 <end_op>
  return -1;
80105347:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010534c:	c9                   	leave  
8010534d:	c3                   	ret    

8010534e <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010534e:	55                   	push   %ebp
8010534f:	89 e5                	mov    %esp,%ebp
80105351:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105354:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010535b:	eb 40                	jmp    8010539d <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010535d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105360:	6a 10                	push   $0x10
80105362:	50                   	push   %eax
80105363:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105366:	50                   	push   %eax
80105367:	ff 75 08             	push   0x8(%ebp)
8010536a:	e8 68 cb ff ff       	call   80101ed7 <readi>
8010536f:	83 c4 10             	add    $0x10,%esp
80105372:	83 f8 10             	cmp    $0x10,%eax
80105375:	74 0d                	je     80105384 <isdirempty+0x36>
      panic("isdirempty: readi");
80105377:	83 ec 0c             	sub    $0xc,%esp
8010537a:	68 53 a7 10 80       	push   $0x8010a753
8010537f:	e8 25 b2 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105384:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105388:	66 85 c0             	test   %ax,%ax
8010538b:	74 07                	je     80105394 <isdirempty+0x46>
      return 0;
8010538d:	b8 00 00 00 00       	mov    $0x0,%eax
80105392:	eb 1b                	jmp    801053af <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105397:	83 c0 10             	add    $0x10,%eax
8010539a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010539d:	8b 45 08             	mov    0x8(%ebp),%eax
801053a0:	8b 50 58             	mov    0x58(%eax),%edx
801053a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a6:	39 c2                	cmp    %eax,%edx
801053a8:	77 b3                	ja     8010535d <isdirempty+0xf>
  }
  return 1;
801053aa:	b8 01 00 00 00       	mov    $0x1,%eax
}
801053af:	c9                   	leave  
801053b0:	c3                   	ret    

801053b1 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801053b1:	55                   	push   %ebp
801053b2:	89 e5                	mov    %esp,%ebp
801053b4:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801053b7:	83 ec 08             	sub    $0x8,%esp
801053ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801053bd:	50                   	push   %eax
801053be:	6a 00                	push   $0x0
801053c0:	e8 a2 fa ff ff       	call   80104e67 <argstr>
801053c5:	83 c4 10             	add    $0x10,%esp
801053c8:	85 c0                	test   %eax,%eax
801053ca:	79 0a                	jns    801053d6 <sys_unlink+0x25>
    return -1;
801053cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d1:	e9 bf 01 00 00       	jmp    80105595 <sys_unlink+0x1e4>

  begin_op();
801053d6:	e8 62 dc ff ff       	call   8010303d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801053db:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053de:	83 ec 08             	sub    $0x8,%esp
801053e1:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801053e4:	52                   	push   %edx
801053e5:	50                   	push   %eax
801053e6:	e8 4f d1 ff ff       	call   8010253a <nameiparent>
801053eb:	83 c4 10             	add    $0x10,%esp
801053ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053f5:	75 0f                	jne    80105406 <sys_unlink+0x55>
    end_op();
801053f7:	e8 cd dc ff ff       	call   801030c9 <end_op>
    return -1;
801053fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105401:	e9 8f 01 00 00       	jmp    80105595 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105406:	83 ec 0c             	sub    $0xc,%esp
80105409:	ff 75 f4             	push   -0xc(%ebp)
8010540c:	e8 da c5 ff ff       	call   801019eb <ilock>
80105411:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105414:	83 ec 08             	sub    $0x8,%esp
80105417:	68 65 a7 10 80       	push   $0x8010a765
8010541c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010541f:	50                   	push   %eax
80105420:	e8 8d cd ff ff       	call   801021b2 <namecmp>
80105425:	83 c4 10             	add    $0x10,%esp
80105428:	85 c0                	test   %eax,%eax
8010542a:	0f 84 49 01 00 00    	je     80105579 <sys_unlink+0x1c8>
80105430:	83 ec 08             	sub    $0x8,%esp
80105433:	68 67 a7 10 80       	push   $0x8010a767
80105438:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010543b:	50                   	push   %eax
8010543c:	e8 71 cd ff ff       	call   801021b2 <namecmp>
80105441:	83 c4 10             	add    $0x10,%esp
80105444:	85 c0                	test   %eax,%eax
80105446:	0f 84 2d 01 00 00    	je     80105579 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010544c:	83 ec 04             	sub    $0x4,%esp
8010544f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105452:	50                   	push   %eax
80105453:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105456:	50                   	push   %eax
80105457:	ff 75 f4             	push   -0xc(%ebp)
8010545a:	e8 6e cd ff ff       	call   801021cd <dirlookup>
8010545f:	83 c4 10             	add    $0x10,%esp
80105462:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105465:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105469:	0f 84 0d 01 00 00    	je     8010557c <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010546f:	83 ec 0c             	sub    $0xc,%esp
80105472:	ff 75 f0             	push   -0x10(%ebp)
80105475:	e8 71 c5 ff ff       	call   801019eb <ilock>
8010547a:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010547d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105480:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105484:	66 85 c0             	test   %ax,%ax
80105487:	7f 0d                	jg     80105496 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105489:	83 ec 0c             	sub    $0xc,%esp
8010548c:	68 6a a7 10 80       	push   $0x8010a76a
80105491:	e8 13 b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105499:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010549d:	66 83 f8 01          	cmp    $0x1,%ax
801054a1:	75 25                	jne    801054c8 <sys_unlink+0x117>
801054a3:	83 ec 0c             	sub    $0xc,%esp
801054a6:	ff 75 f0             	push   -0x10(%ebp)
801054a9:	e8 a0 fe ff ff       	call   8010534e <isdirempty>
801054ae:	83 c4 10             	add    $0x10,%esp
801054b1:	85 c0                	test   %eax,%eax
801054b3:	75 13                	jne    801054c8 <sys_unlink+0x117>
    iunlockput(ip);
801054b5:	83 ec 0c             	sub    $0xc,%esp
801054b8:	ff 75 f0             	push   -0x10(%ebp)
801054bb:	e8 5c c7 ff ff       	call   80101c1c <iunlockput>
801054c0:	83 c4 10             	add    $0x10,%esp
    goto bad;
801054c3:	e9 b5 00 00 00       	jmp    8010557d <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801054c8:	83 ec 04             	sub    $0x4,%esp
801054cb:	6a 10                	push   $0x10
801054cd:	6a 00                	push   $0x0
801054cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801054d2:	50                   	push   %eax
801054d3:	e8 fa f5 ff ff       	call   80104ad2 <memset>
801054d8:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801054db:	8b 45 c8             	mov    -0x38(%ebp),%eax
801054de:	6a 10                	push   $0x10
801054e0:	50                   	push   %eax
801054e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801054e4:	50                   	push   %eax
801054e5:	ff 75 f4             	push   -0xc(%ebp)
801054e8:	e8 3f cb ff ff       	call   8010202c <writei>
801054ed:	83 c4 10             	add    $0x10,%esp
801054f0:	83 f8 10             	cmp    $0x10,%eax
801054f3:	74 0d                	je     80105502 <sys_unlink+0x151>
    panic("unlink: writei");
801054f5:	83 ec 0c             	sub    $0xc,%esp
801054f8:	68 7c a7 10 80       	push   $0x8010a77c
801054fd:	e8 a7 b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105502:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105505:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105509:	66 83 f8 01          	cmp    $0x1,%ax
8010550d:	75 21                	jne    80105530 <sys_unlink+0x17f>
    dp->nlink--;
8010550f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105512:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105516:	83 e8 01             	sub    $0x1,%eax
80105519:	89 c2                	mov    %eax,%edx
8010551b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010551e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105522:	83 ec 0c             	sub    $0xc,%esp
80105525:	ff 75 f4             	push   -0xc(%ebp)
80105528:	e8 e1 c2 ff ff       	call   8010180e <iupdate>
8010552d:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105530:	83 ec 0c             	sub    $0xc,%esp
80105533:	ff 75 f4             	push   -0xc(%ebp)
80105536:	e8 e1 c6 ff ff       	call   80101c1c <iunlockput>
8010553b:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010553e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105541:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105545:	83 e8 01             	sub    $0x1,%eax
80105548:	89 c2                	mov    %eax,%edx
8010554a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010554d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105551:	83 ec 0c             	sub    $0xc,%esp
80105554:	ff 75 f0             	push   -0x10(%ebp)
80105557:	e8 b2 c2 ff ff       	call   8010180e <iupdate>
8010555c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010555f:	83 ec 0c             	sub    $0xc,%esp
80105562:	ff 75 f0             	push   -0x10(%ebp)
80105565:	e8 b2 c6 ff ff       	call   80101c1c <iunlockput>
8010556a:	83 c4 10             	add    $0x10,%esp

  end_op();
8010556d:	e8 57 db ff ff       	call   801030c9 <end_op>

  return 0;
80105572:	b8 00 00 00 00       	mov    $0x0,%eax
80105577:	eb 1c                	jmp    80105595 <sys_unlink+0x1e4>
    goto bad;
80105579:	90                   	nop
8010557a:	eb 01                	jmp    8010557d <sys_unlink+0x1cc>
    goto bad;
8010557c:	90                   	nop

bad:
  iunlockput(dp);
8010557d:	83 ec 0c             	sub    $0xc,%esp
80105580:	ff 75 f4             	push   -0xc(%ebp)
80105583:	e8 94 c6 ff ff       	call   80101c1c <iunlockput>
80105588:	83 c4 10             	add    $0x10,%esp
  end_op();
8010558b:	e8 39 db ff ff       	call   801030c9 <end_op>
  return -1;
80105590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105595:	c9                   	leave  
80105596:	c3                   	ret    

80105597 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105597:	55                   	push   %ebp
80105598:	89 e5                	mov    %esp,%ebp
8010559a:	83 ec 38             	sub    $0x38,%esp
8010559d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801055a0:	8b 55 10             	mov    0x10(%ebp),%edx
801055a3:	8b 45 14             	mov    0x14(%ebp),%eax
801055a6:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801055aa:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801055ae:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801055b2:	83 ec 08             	sub    $0x8,%esp
801055b5:	8d 45 de             	lea    -0x22(%ebp),%eax
801055b8:	50                   	push   %eax
801055b9:	ff 75 08             	push   0x8(%ebp)
801055bc:	e8 79 cf ff ff       	call   8010253a <nameiparent>
801055c1:	83 c4 10             	add    $0x10,%esp
801055c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055cb:	75 0a                	jne    801055d7 <create+0x40>
    return 0;
801055cd:	b8 00 00 00 00       	mov    $0x0,%eax
801055d2:	e9 90 01 00 00       	jmp    80105767 <create+0x1d0>
  ilock(dp);
801055d7:	83 ec 0c             	sub    $0xc,%esp
801055da:	ff 75 f4             	push   -0xc(%ebp)
801055dd:	e8 09 c4 ff ff       	call   801019eb <ilock>
801055e2:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801055e5:	83 ec 04             	sub    $0x4,%esp
801055e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055eb:	50                   	push   %eax
801055ec:	8d 45 de             	lea    -0x22(%ebp),%eax
801055ef:	50                   	push   %eax
801055f0:	ff 75 f4             	push   -0xc(%ebp)
801055f3:	e8 d5 cb ff ff       	call   801021cd <dirlookup>
801055f8:	83 c4 10             	add    $0x10,%esp
801055fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105602:	74 50                	je     80105654 <create+0xbd>
    iunlockput(dp);
80105604:	83 ec 0c             	sub    $0xc,%esp
80105607:	ff 75 f4             	push   -0xc(%ebp)
8010560a:	e8 0d c6 ff ff       	call   80101c1c <iunlockput>
8010560f:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105612:	83 ec 0c             	sub    $0xc,%esp
80105615:	ff 75 f0             	push   -0x10(%ebp)
80105618:	e8 ce c3 ff ff       	call   801019eb <ilock>
8010561d:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105620:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105625:	75 15                	jne    8010563c <create+0xa5>
80105627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010562a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010562e:	66 83 f8 02          	cmp    $0x2,%ax
80105632:	75 08                	jne    8010563c <create+0xa5>
      return ip;
80105634:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105637:	e9 2b 01 00 00       	jmp    80105767 <create+0x1d0>
    iunlockput(ip);
8010563c:	83 ec 0c             	sub    $0xc,%esp
8010563f:	ff 75 f0             	push   -0x10(%ebp)
80105642:	e8 d5 c5 ff ff       	call   80101c1c <iunlockput>
80105647:	83 c4 10             	add    $0x10,%esp
    return 0;
8010564a:	b8 00 00 00 00       	mov    $0x0,%eax
8010564f:	e9 13 01 00 00       	jmp    80105767 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105654:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565b:	8b 00                	mov    (%eax),%eax
8010565d:	83 ec 08             	sub    $0x8,%esp
80105660:	52                   	push   %edx
80105661:	50                   	push   %eax
80105662:	e8 d0 c0 ff ff       	call   80101737 <ialloc>
80105667:	83 c4 10             	add    $0x10,%esp
8010566a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010566d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105671:	75 0d                	jne    80105680 <create+0xe9>
    panic("create: ialloc");
80105673:	83 ec 0c             	sub    $0xc,%esp
80105676:	68 8b a7 10 80       	push   $0x8010a78b
8010567b:	e8 29 af ff ff       	call   801005a9 <panic>

  ilock(ip);
80105680:	83 ec 0c             	sub    $0xc,%esp
80105683:	ff 75 f0             	push   -0x10(%ebp)
80105686:	e8 60 c3 ff ff       	call   801019eb <ilock>
8010568b:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010568e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105691:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105695:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010569c:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801056a0:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801056a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056a7:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801056ad:	83 ec 0c             	sub    $0xc,%esp
801056b0:	ff 75 f0             	push   -0x10(%ebp)
801056b3:	e8 56 c1 ff ff       	call   8010180e <iupdate>
801056b8:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801056bb:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801056c0:	75 6a                	jne    8010572c <create+0x195>
    dp->nlink++;  // for ".."
801056c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056c9:	83 c0 01             	add    $0x1,%eax
801056cc:	89 c2                	mov    %eax,%edx
801056ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d1:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801056d5:	83 ec 0c             	sub    $0xc,%esp
801056d8:	ff 75 f4             	push   -0xc(%ebp)
801056db:	e8 2e c1 ff ff       	call   8010180e <iupdate>
801056e0:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801056e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e6:	8b 40 04             	mov    0x4(%eax),%eax
801056e9:	83 ec 04             	sub    $0x4,%esp
801056ec:	50                   	push   %eax
801056ed:	68 65 a7 10 80       	push   $0x8010a765
801056f2:	ff 75 f0             	push   -0x10(%ebp)
801056f5:	e8 8d cb ff ff       	call   80102287 <dirlink>
801056fa:	83 c4 10             	add    $0x10,%esp
801056fd:	85 c0                	test   %eax,%eax
801056ff:	78 1e                	js     8010571f <create+0x188>
80105701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105704:	8b 40 04             	mov    0x4(%eax),%eax
80105707:	83 ec 04             	sub    $0x4,%esp
8010570a:	50                   	push   %eax
8010570b:	68 67 a7 10 80       	push   $0x8010a767
80105710:	ff 75 f0             	push   -0x10(%ebp)
80105713:	e8 6f cb ff ff       	call   80102287 <dirlink>
80105718:	83 c4 10             	add    $0x10,%esp
8010571b:	85 c0                	test   %eax,%eax
8010571d:	79 0d                	jns    8010572c <create+0x195>
      panic("create dots");
8010571f:	83 ec 0c             	sub    $0xc,%esp
80105722:	68 9a a7 10 80       	push   $0x8010a79a
80105727:	e8 7d ae ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010572c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010572f:	8b 40 04             	mov    0x4(%eax),%eax
80105732:	83 ec 04             	sub    $0x4,%esp
80105735:	50                   	push   %eax
80105736:	8d 45 de             	lea    -0x22(%ebp),%eax
80105739:	50                   	push   %eax
8010573a:	ff 75 f4             	push   -0xc(%ebp)
8010573d:	e8 45 cb ff ff       	call   80102287 <dirlink>
80105742:	83 c4 10             	add    $0x10,%esp
80105745:	85 c0                	test   %eax,%eax
80105747:	79 0d                	jns    80105756 <create+0x1bf>
    panic("create: dirlink");
80105749:	83 ec 0c             	sub    $0xc,%esp
8010574c:	68 a6 a7 10 80       	push   $0x8010a7a6
80105751:	e8 53 ae ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105756:	83 ec 0c             	sub    $0xc,%esp
80105759:	ff 75 f4             	push   -0xc(%ebp)
8010575c:	e8 bb c4 ff ff       	call   80101c1c <iunlockput>
80105761:	83 c4 10             	add    $0x10,%esp

  return ip;
80105764:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105767:	c9                   	leave  
80105768:	c3                   	ret    

80105769 <sys_open>:

int
sys_open(void)
{
80105769:	55                   	push   %ebp
8010576a:	89 e5                	mov    %esp,%ebp
8010576c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010576f:	83 ec 08             	sub    $0x8,%esp
80105772:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105775:	50                   	push   %eax
80105776:	6a 00                	push   $0x0
80105778:	e8 ea f6 ff ff       	call   80104e67 <argstr>
8010577d:	83 c4 10             	add    $0x10,%esp
80105780:	85 c0                	test   %eax,%eax
80105782:	78 15                	js     80105799 <sys_open+0x30>
80105784:	83 ec 08             	sub    $0x8,%esp
80105787:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010578a:	50                   	push   %eax
8010578b:	6a 01                	push   $0x1
8010578d:	e8 4f f6 ff ff       	call   80104de1 <argint>
80105792:	83 c4 10             	add    $0x10,%esp
80105795:	85 c0                	test   %eax,%eax
80105797:	79 0a                	jns    801057a3 <sys_open+0x3a>
    return -1;
80105799:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579e:	e9 61 01 00 00       	jmp    80105904 <sys_open+0x19b>

  begin_op();
801057a3:	e8 95 d8 ff ff       	call   8010303d <begin_op>

  if(omode & O_CREATE){
801057a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057ab:	25 00 02 00 00       	and    $0x200,%eax
801057b0:	85 c0                	test   %eax,%eax
801057b2:	74 2a                	je     801057de <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801057b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801057b7:	6a 00                	push   $0x0
801057b9:	6a 00                	push   $0x0
801057bb:	6a 02                	push   $0x2
801057bd:	50                   	push   %eax
801057be:	e8 d4 fd ff ff       	call   80105597 <create>
801057c3:	83 c4 10             	add    $0x10,%esp
801057c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801057c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057cd:	75 75                	jne    80105844 <sys_open+0xdb>
      end_op();
801057cf:	e8 f5 d8 ff ff       	call   801030c9 <end_op>
      return -1;
801057d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d9:	e9 26 01 00 00       	jmp    80105904 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801057de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801057e1:	83 ec 0c             	sub    $0xc,%esp
801057e4:	50                   	push   %eax
801057e5:	e8 34 cd ff ff       	call   8010251e <namei>
801057ea:	83 c4 10             	add    $0x10,%esp
801057ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057f4:	75 0f                	jne    80105805 <sys_open+0x9c>
      end_op();
801057f6:	e8 ce d8 ff ff       	call   801030c9 <end_op>
      return -1;
801057fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105800:	e9 ff 00 00 00       	jmp    80105904 <sys_open+0x19b>
    }
    ilock(ip);
80105805:	83 ec 0c             	sub    $0xc,%esp
80105808:	ff 75 f4             	push   -0xc(%ebp)
8010580b:	e8 db c1 ff ff       	call   801019eb <ilock>
80105810:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105816:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010581a:	66 83 f8 01          	cmp    $0x1,%ax
8010581e:	75 24                	jne    80105844 <sys_open+0xdb>
80105820:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105823:	85 c0                	test   %eax,%eax
80105825:	74 1d                	je     80105844 <sys_open+0xdb>
      iunlockput(ip);
80105827:	83 ec 0c             	sub    $0xc,%esp
8010582a:	ff 75 f4             	push   -0xc(%ebp)
8010582d:	e8 ea c3 ff ff       	call   80101c1c <iunlockput>
80105832:	83 c4 10             	add    $0x10,%esp
      end_op();
80105835:	e8 8f d8 ff ff       	call   801030c9 <end_op>
      return -1;
8010583a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583f:	e9 c0 00 00 00       	jmp    80105904 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105844:	e8 95 b7 ff ff       	call   80100fde <filealloc>
80105849:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010584c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105850:	74 17                	je     80105869 <sys_open+0x100>
80105852:	83 ec 0c             	sub    $0xc,%esp
80105855:	ff 75 f0             	push   -0x10(%ebp)
80105858:	e8 33 f7 ff ff       	call   80104f90 <fdalloc>
8010585d:	83 c4 10             	add    $0x10,%esp
80105860:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105863:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105867:	79 2e                	jns    80105897 <sys_open+0x12e>
    if(f)
80105869:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010586d:	74 0e                	je     8010587d <sys_open+0x114>
      fileclose(f);
8010586f:	83 ec 0c             	sub    $0xc,%esp
80105872:	ff 75 f0             	push   -0x10(%ebp)
80105875:	e8 22 b8 ff ff       	call   8010109c <fileclose>
8010587a:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010587d:	83 ec 0c             	sub    $0xc,%esp
80105880:	ff 75 f4             	push   -0xc(%ebp)
80105883:	e8 94 c3 ff ff       	call   80101c1c <iunlockput>
80105888:	83 c4 10             	add    $0x10,%esp
    end_op();
8010588b:	e8 39 d8 ff ff       	call   801030c9 <end_op>
    return -1;
80105890:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105895:	eb 6d                	jmp    80105904 <sys_open+0x19b>
  }
  iunlock(ip);
80105897:	83 ec 0c             	sub    $0xc,%esp
8010589a:	ff 75 f4             	push   -0xc(%ebp)
8010589d:	e8 5c c2 ff ff       	call   80101afe <iunlock>
801058a2:	83 c4 10             	add    $0x10,%esp
  end_op();
801058a5:	e8 1f d8 ff ff       	call   801030c9 <end_op>

  f->type = FD_INODE;
801058aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ad:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058b9:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801058bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bf:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801058c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058c9:	83 e0 01             	and    $0x1,%eax
801058cc:	85 c0                	test   %eax,%eax
801058ce:	0f 94 c0             	sete   %al
801058d1:	89 c2                	mov    %eax,%edx
801058d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d6:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058dc:	83 e0 01             	and    $0x1,%eax
801058df:	85 c0                	test   %eax,%eax
801058e1:	75 0a                	jne    801058ed <sys_open+0x184>
801058e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058e6:	83 e0 02             	and    $0x2,%eax
801058e9:	85 c0                	test   %eax,%eax
801058eb:	74 07                	je     801058f4 <sys_open+0x18b>
801058ed:	b8 01 00 00 00       	mov    $0x1,%eax
801058f2:	eb 05                	jmp    801058f9 <sys_open+0x190>
801058f4:	b8 00 00 00 00       	mov    $0x0,%eax
801058f9:	89 c2                	mov    %eax,%edx
801058fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fe:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105901:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105904:	c9                   	leave  
80105905:	c3                   	ret    

80105906 <sys_mkdir>:

int
sys_mkdir(void)
{
80105906:	55                   	push   %ebp
80105907:	89 e5                	mov    %esp,%ebp
80105909:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010590c:	e8 2c d7 ff ff       	call   8010303d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105911:	83 ec 08             	sub    $0x8,%esp
80105914:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105917:	50                   	push   %eax
80105918:	6a 00                	push   $0x0
8010591a:	e8 48 f5 ff ff       	call   80104e67 <argstr>
8010591f:	83 c4 10             	add    $0x10,%esp
80105922:	85 c0                	test   %eax,%eax
80105924:	78 1b                	js     80105941 <sys_mkdir+0x3b>
80105926:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105929:	6a 00                	push   $0x0
8010592b:	6a 00                	push   $0x0
8010592d:	6a 01                	push   $0x1
8010592f:	50                   	push   %eax
80105930:	e8 62 fc ff ff       	call   80105597 <create>
80105935:	83 c4 10             	add    $0x10,%esp
80105938:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010593b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010593f:	75 0c                	jne    8010594d <sys_mkdir+0x47>
    end_op();
80105941:	e8 83 d7 ff ff       	call   801030c9 <end_op>
    return -1;
80105946:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594b:	eb 18                	jmp    80105965 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010594d:	83 ec 0c             	sub    $0xc,%esp
80105950:	ff 75 f4             	push   -0xc(%ebp)
80105953:	e8 c4 c2 ff ff       	call   80101c1c <iunlockput>
80105958:	83 c4 10             	add    $0x10,%esp
  end_op();
8010595b:	e8 69 d7 ff ff       	call   801030c9 <end_op>
  return 0;
80105960:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105965:	c9                   	leave  
80105966:	c3                   	ret    

80105967 <sys_mknod>:

int
sys_mknod(void)
{
80105967:	55                   	push   %ebp
80105968:	89 e5                	mov    %esp,%ebp
8010596a:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010596d:	e8 cb d6 ff ff       	call   8010303d <begin_op>
  if((argstr(0, &path)) < 0 ||
80105972:	83 ec 08             	sub    $0x8,%esp
80105975:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105978:	50                   	push   %eax
80105979:	6a 00                	push   $0x0
8010597b:	e8 e7 f4 ff ff       	call   80104e67 <argstr>
80105980:	83 c4 10             	add    $0x10,%esp
80105983:	85 c0                	test   %eax,%eax
80105985:	78 4f                	js     801059d6 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105987:	83 ec 08             	sub    $0x8,%esp
8010598a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010598d:	50                   	push   %eax
8010598e:	6a 01                	push   $0x1
80105990:	e8 4c f4 ff ff       	call   80104de1 <argint>
80105995:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105998:	85 c0                	test   %eax,%eax
8010599a:	78 3a                	js     801059d6 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
8010599c:	83 ec 08             	sub    $0x8,%esp
8010599f:	8d 45 e8             	lea    -0x18(%ebp),%eax
801059a2:	50                   	push   %eax
801059a3:	6a 02                	push   $0x2
801059a5:	e8 37 f4 ff ff       	call   80104de1 <argint>
801059aa:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801059ad:	85 c0                	test   %eax,%eax
801059af:	78 25                	js     801059d6 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801059b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801059b4:	0f bf c8             	movswl %ax,%ecx
801059b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059ba:	0f bf d0             	movswl %ax,%edx
801059bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c0:	51                   	push   %ecx
801059c1:	52                   	push   %edx
801059c2:	6a 03                	push   $0x3
801059c4:	50                   	push   %eax
801059c5:	e8 cd fb ff ff       	call   80105597 <create>
801059ca:	83 c4 10             	add    $0x10,%esp
801059cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801059d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059d4:	75 0c                	jne    801059e2 <sys_mknod+0x7b>
    end_op();
801059d6:	e8 ee d6 ff ff       	call   801030c9 <end_op>
    return -1;
801059db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e0:	eb 18                	jmp    801059fa <sys_mknod+0x93>
  }
  iunlockput(ip);
801059e2:	83 ec 0c             	sub    $0xc,%esp
801059e5:	ff 75 f4             	push   -0xc(%ebp)
801059e8:	e8 2f c2 ff ff       	call   80101c1c <iunlockput>
801059ed:	83 c4 10             	add    $0x10,%esp
  end_op();
801059f0:	e8 d4 d6 ff ff       	call   801030c9 <end_op>
  return 0;
801059f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059fa:	c9                   	leave  
801059fb:	c3                   	ret    

801059fc <sys_chdir>:

int
sys_chdir(void)
{
801059fc:	55                   	push   %ebp
801059fd:	89 e5                	mov    %esp,%ebp
801059ff:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105a02:	e8 2a e0 ff ff       	call   80103a31 <myproc>
80105a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105a0a:	e8 2e d6 ff ff       	call   8010303d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a0f:	83 ec 08             	sub    $0x8,%esp
80105a12:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a15:	50                   	push   %eax
80105a16:	6a 00                	push   $0x0
80105a18:	e8 4a f4 ff ff       	call   80104e67 <argstr>
80105a1d:	83 c4 10             	add    $0x10,%esp
80105a20:	85 c0                	test   %eax,%eax
80105a22:	78 18                	js     80105a3c <sys_chdir+0x40>
80105a24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a27:	83 ec 0c             	sub    $0xc,%esp
80105a2a:	50                   	push   %eax
80105a2b:	e8 ee ca ff ff       	call   8010251e <namei>
80105a30:	83 c4 10             	add    $0x10,%esp
80105a33:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a36:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a3a:	75 0c                	jne    80105a48 <sys_chdir+0x4c>
    end_op();
80105a3c:	e8 88 d6 ff ff       	call   801030c9 <end_op>
    return -1;
80105a41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a46:	eb 68                	jmp    80105ab0 <sys_chdir+0xb4>
  }
  ilock(ip);
80105a48:	83 ec 0c             	sub    $0xc,%esp
80105a4b:	ff 75 f0             	push   -0x10(%ebp)
80105a4e:	e8 98 bf ff ff       	call   801019eb <ilock>
80105a53:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a59:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a5d:	66 83 f8 01          	cmp    $0x1,%ax
80105a61:	74 1a                	je     80105a7d <sys_chdir+0x81>
    iunlockput(ip);
80105a63:	83 ec 0c             	sub    $0xc,%esp
80105a66:	ff 75 f0             	push   -0x10(%ebp)
80105a69:	e8 ae c1 ff ff       	call   80101c1c <iunlockput>
80105a6e:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a71:	e8 53 d6 ff ff       	call   801030c9 <end_op>
    return -1;
80105a76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a7b:	eb 33                	jmp    80105ab0 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105a7d:	83 ec 0c             	sub    $0xc,%esp
80105a80:	ff 75 f0             	push   -0x10(%ebp)
80105a83:	e8 76 c0 ff ff       	call   80101afe <iunlock>
80105a88:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8e:	8b 40 68             	mov    0x68(%eax),%eax
80105a91:	83 ec 0c             	sub    $0xc,%esp
80105a94:	50                   	push   %eax
80105a95:	e8 b2 c0 ff ff       	call   80101b4c <iput>
80105a9a:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a9d:	e8 27 d6 ff ff       	call   801030c9 <end_op>
  curproc->cwd = ip;
80105aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105aa8:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ab0:	c9                   	leave  
80105ab1:	c3                   	ret    

80105ab2 <sys_exec>:

int
sys_exec(void)
{
80105ab2:	55                   	push   %ebp
80105ab3:	89 e5                	mov    %esp,%ebp
80105ab5:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105abb:	83 ec 08             	sub    $0x8,%esp
80105abe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ac1:	50                   	push   %eax
80105ac2:	6a 00                	push   $0x0
80105ac4:	e8 9e f3 ff ff       	call   80104e67 <argstr>
80105ac9:	83 c4 10             	add    $0x10,%esp
80105acc:	85 c0                	test   %eax,%eax
80105ace:	78 18                	js     80105ae8 <sys_exec+0x36>
80105ad0:	83 ec 08             	sub    $0x8,%esp
80105ad3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105ad9:	50                   	push   %eax
80105ada:	6a 01                	push   $0x1
80105adc:	e8 00 f3 ff ff       	call   80104de1 <argint>
80105ae1:	83 c4 10             	add    $0x10,%esp
80105ae4:	85 c0                	test   %eax,%eax
80105ae6:	79 0a                	jns    80105af2 <sys_exec+0x40>
    return -1;
80105ae8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aed:	e9 c6 00 00 00       	jmp    80105bb8 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105af2:	83 ec 04             	sub    $0x4,%esp
80105af5:	68 80 00 00 00       	push   $0x80
80105afa:	6a 00                	push   $0x0
80105afc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105b02:	50                   	push   %eax
80105b03:	e8 ca ef ff ff       	call   80104ad2 <memset>
80105b08:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105b0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b15:	83 f8 1f             	cmp    $0x1f,%eax
80105b18:	76 0a                	jbe    80105b24 <sys_exec+0x72>
      return -1;
80105b1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1f:	e9 94 00 00 00       	jmp    80105bb8 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b27:	c1 e0 02             	shl    $0x2,%eax
80105b2a:	89 c2                	mov    %eax,%edx
80105b2c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105b32:	01 c2                	add    %eax,%edx
80105b34:	83 ec 08             	sub    $0x8,%esp
80105b37:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105b3d:	50                   	push   %eax
80105b3e:	52                   	push   %edx
80105b3f:	e8 18 f2 ff ff       	call   80104d5c <fetchint>
80105b44:	83 c4 10             	add    $0x10,%esp
80105b47:	85 c0                	test   %eax,%eax
80105b49:	79 07                	jns    80105b52 <sys_exec+0xa0>
      return -1;
80105b4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b50:	eb 66                	jmp    80105bb8 <sys_exec+0x106>
    if(uarg == 0){
80105b52:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b58:	85 c0                	test   %eax,%eax
80105b5a:	75 27                	jne    80105b83 <sys_exec+0xd1>
      argv[i] = 0;
80105b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5f:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105b66:	00 00 00 00 
      break;
80105b6a:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6e:	83 ec 08             	sub    $0x8,%esp
80105b71:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b77:	52                   	push   %edx
80105b78:	50                   	push   %eax
80105b79:	e8 02 b0 ff ff       	call   80100b80 <exec>
80105b7e:	83 c4 10             	add    $0x10,%esp
80105b81:	eb 35                	jmp    80105bb8 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105b83:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8c:	c1 e0 02             	shl    $0x2,%eax
80105b8f:	01 c2                	add    %eax,%edx
80105b91:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b97:	83 ec 08             	sub    $0x8,%esp
80105b9a:	52                   	push   %edx
80105b9b:	50                   	push   %eax
80105b9c:	e8 ea f1 ff ff       	call   80104d8b <fetchstr>
80105ba1:	83 c4 10             	add    $0x10,%esp
80105ba4:	85 c0                	test   %eax,%eax
80105ba6:	79 07                	jns    80105baf <sys_exec+0xfd>
      return -1;
80105ba8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bad:	eb 09                	jmp    80105bb8 <sys_exec+0x106>
  for(i=0;; i++){
80105baf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105bb3:	e9 5a ff ff ff       	jmp    80105b12 <sys_exec+0x60>
}
80105bb8:	c9                   	leave  
80105bb9:	c3                   	ret    

80105bba <sys_pipe>:

int
sys_pipe(void)
{
80105bba:	55                   	push   %ebp
80105bbb:	89 e5                	mov    %esp,%ebp
80105bbd:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bc0:	83 ec 04             	sub    $0x4,%esp
80105bc3:	6a 08                	push   $0x8
80105bc5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bc8:	50                   	push   %eax
80105bc9:	6a 00                	push   $0x0
80105bcb:	e8 3e f2 ff ff       	call   80104e0e <argptr>
80105bd0:	83 c4 10             	add    $0x10,%esp
80105bd3:	85 c0                	test   %eax,%eax
80105bd5:	79 0a                	jns    80105be1 <sys_pipe+0x27>
    return -1;
80105bd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdc:	e9 ae 00 00 00       	jmp    80105c8f <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105be1:	83 ec 08             	sub    $0x8,%esp
80105be4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105be7:	50                   	push   %eax
80105be8:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105beb:	50                   	push   %eax
80105bec:	e8 7d d9 ff ff       	call   8010356e <pipealloc>
80105bf1:	83 c4 10             	add    $0x10,%esp
80105bf4:	85 c0                	test   %eax,%eax
80105bf6:	79 0a                	jns    80105c02 <sys_pipe+0x48>
    return -1;
80105bf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfd:	e9 8d 00 00 00       	jmp    80105c8f <sys_pipe+0xd5>
  fd0 = -1;
80105c02:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c0c:	83 ec 0c             	sub    $0xc,%esp
80105c0f:	50                   	push   %eax
80105c10:	e8 7b f3 ff ff       	call   80104f90 <fdalloc>
80105c15:	83 c4 10             	add    $0x10,%esp
80105c18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c1f:	78 18                	js     80105c39 <sys_pipe+0x7f>
80105c21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c24:	83 ec 0c             	sub    $0xc,%esp
80105c27:	50                   	push   %eax
80105c28:	e8 63 f3 ff ff       	call   80104f90 <fdalloc>
80105c2d:	83 c4 10             	add    $0x10,%esp
80105c30:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c37:	79 3e                	jns    80105c77 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105c39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c3d:	78 13                	js     80105c52 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105c3f:	e8 ed dd ff ff       	call   80103a31 <myproc>
80105c44:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c47:	83 c2 08             	add    $0x8,%edx
80105c4a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c51:	00 
    fileclose(rf);
80105c52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c55:	83 ec 0c             	sub    $0xc,%esp
80105c58:	50                   	push   %eax
80105c59:	e8 3e b4 ff ff       	call   8010109c <fileclose>
80105c5e:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105c61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c64:	83 ec 0c             	sub    $0xc,%esp
80105c67:	50                   	push   %eax
80105c68:	e8 2f b4 ff ff       	call   8010109c <fileclose>
80105c6d:	83 c4 10             	add    $0x10,%esp
    return -1;
80105c70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c75:	eb 18                	jmp    80105c8f <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105c77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c7d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105c7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c82:	8d 50 04             	lea    0x4(%eax),%edx
80105c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c88:	89 02                	mov    %eax,(%edx)
  return 0;
80105c8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c8f:	c9                   	leave  
80105c90:	c3                   	ret    

80105c91 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105c91:	55                   	push   %ebp
80105c92:	89 e5                	mov    %esp,%ebp
80105c94:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105c97:	e8 94 e0 ff ff       	call   80103d30 <fork>
}
80105c9c:	c9                   	leave  
80105c9d:	c3                   	ret    

80105c9e <sys_exit>:

int
sys_exit(void)
{
80105c9e:	55                   	push   %ebp
80105c9f:	89 e5                	mov    %esp,%ebp
80105ca1:	83 ec 08             	sub    $0x8,%esp
  exit();
80105ca4:	e8 15 e2 ff ff       	call   80103ebe <exit>
  return 0;  // not reached
80105ca9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cae:	c9                   	leave  
80105caf:	c3                   	ret    

80105cb0 <sys_wait>:

int
sys_wait(void)
{
80105cb0:	55                   	push   %ebp
80105cb1:	89 e5                	mov    %esp,%ebp
80105cb3:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105cb6:	e8 23 e3 ff ff       	call   80103fde <wait>
}
80105cbb:	c9                   	leave  
80105cbc:	c3                   	ret    

80105cbd <sys_kill>:

int
sys_kill(void)
{
80105cbd:	55                   	push   %ebp
80105cbe:	89 e5                	mov    %esp,%ebp
80105cc0:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105cc3:	83 ec 08             	sub    $0x8,%esp
80105cc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cc9:	50                   	push   %eax
80105cca:	6a 00                	push   $0x0
80105ccc:	e8 10 f1 ff ff       	call   80104de1 <argint>
80105cd1:	83 c4 10             	add    $0x10,%esp
80105cd4:	85 c0                	test   %eax,%eax
80105cd6:	79 07                	jns    80105cdf <sys_kill+0x22>
    return -1;
80105cd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cdd:	eb 0f                	jmp    80105cee <sys_kill+0x31>
  return kill(pid);
80105cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce2:	83 ec 0c             	sub    $0xc,%esp
80105ce5:	50                   	push   %eax
80105ce6:	e8 22 e7 ff ff       	call   8010440d <kill>
80105ceb:	83 c4 10             	add    $0x10,%esp
}
80105cee:	c9                   	leave  
80105cef:	c3                   	ret    

80105cf0 <sys_getpid>:

int
sys_getpid(void)
{
80105cf0:	55                   	push   %ebp
80105cf1:	89 e5                	mov    %esp,%ebp
80105cf3:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105cf6:	e8 36 dd ff ff       	call   80103a31 <myproc>
80105cfb:	8b 40 10             	mov    0x10(%eax),%eax
}
80105cfe:	c9                   	leave  
80105cff:	c3                   	ret    

80105d00 <sys_sbrk>:

int
sys_sbrk(void)
{
80105d00:	55                   	push   %ebp
80105d01:	89 e5                	mov    %esp,%ebp
80105d03:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;
  struct proc *p = myproc();
80105d06:	e8 26 dd ff ff       	call   80103a31 <myproc>
80105d0b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(argint(0, &n) < 0)
80105d0e:	83 ec 08             	sub    $0x8,%esp
80105d11:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d14:	50                   	push   %eax
80105d15:	6a 00                	push   $0x0
80105d17:	e8 c5 f0 ff ff       	call   80104de1 <argint>
80105d1c:	83 c4 10             	add    $0x10,%esp
80105d1f:	85 c0                	test   %eax,%eax
80105d21:	79 07                	jns    80105d2a <sys_sbrk+0x2a>
    return -1;
80105d23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d28:	eb 34                	jmp    80105d5e <sys_sbrk+0x5e>
  addr = p->sz;
80105d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2d:	8b 00                	mov    (%eax),%eax
80105d2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  if(n < 0 && addr + n < 0){
80105d32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d35:	85 c0                	test   %eax,%eax
80105d37:	79 13                	jns    80105d4c <sys_sbrk+0x4c>
80105d39:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3f:	01 d0                	add    %edx,%eax
80105d41:	85 c0                	test   %eax,%eax
80105d43:	79 07                	jns    80105d4c <sys_sbrk+0x4c>
    return -1;
80105d45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4a:	eb 12                	jmp    80105d5e <sys_sbrk+0x5e>
  }
  
  p->sz += n;
80105d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4f:	8b 10                	mov    (%eax),%edx
80105d51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d54:	01 c2                	add    %eax,%edx
80105d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d59:	89 10                	mov    %edx,(%eax)

  return addr;
80105d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105d5e:	c9                   	leave  
80105d5f:	c3                   	ret    

80105d60 <sys_sleep>:

int
sys_sleep(void)
{
80105d60:	55                   	push   %ebp
80105d61:	89 e5                	mov    %esp,%ebp
80105d63:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105d66:	83 ec 08             	sub    $0x8,%esp
80105d69:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d6c:	50                   	push   %eax
80105d6d:	6a 00                	push   $0x0
80105d6f:	e8 6d f0 ff ff       	call   80104de1 <argint>
80105d74:	83 c4 10             	add    $0x10,%esp
80105d77:	85 c0                	test   %eax,%eax
80105d79:	79 07                	jns    80105d82 <sys_sleep+0x22>
    return -1;
80105d7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d80:	eb 76                	jmp    80105df8 <sys_sleep+0x98>
  acquire(&tickslock);
80105d82:	83 ec 0c             	sub    $0xc,%esp
80105d85:	68 40 69 19 80       	push   $0x80196940
80105d8a:	e8 cd ea ff ff       	call   8010485c <acquire>
80105d8f:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105d92:	a1 74 69 19 80       	mov    0x80196974,%eax
80105d97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105d9a:	eb 38                	jmp    80105dd4 <sys_sleep+0x74>
    if(myproc()->killed){
80105d9c:	e8 90 dc ff ff       	call   80103a31 <myproc>
80105da1:	8b 40 24             	mov    0x24(%eax),%eax
80105da4:	85 c0                	test   %eax,%eax
80105da6:	74 17                	je     80105dbf <sys_sleep+0x5f>
      release(&tickslock);
80105da8:	83 ec 0c             	sub    $0xc,%esp
80105dab:	68 40 69 19 80       	push   $0x80196940
80105db0:	e8 15 eb ff ff       	call   801048ca <release>
80105db5:	83 c4 10             	add    $0x10,%esp
      return -1;
80105db8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dbd:	eb 39                	jmp    80105df8 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105dbf:	83 ec 08             	sub    $0x8,%esp
80105dc2:	68 40 69 19 80       	push   $0x80196940
80105dc7:	68 74 69 19 80       	push   $0x80196974
80105dcc:	e8 1e e5 ff ff       	call   801042ef <sleep>
80105dd1:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105dd4:	a1 74 69 19 80       	mov    0x80196974,%eax
80105dd9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105ddc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ddf:	39 d0                	cmp    %edx,%eax
80105de1:	72 b9                	jb     80105d9c <sys_sleep+0x3c>
  }
  release(&tickslock);
80105de3:	83 ec 0c             	sub    $0xc,%esp
80105de6:	68 40 69 19 80       	push   $0x80196940
80105deb:	e8 da ea ff ff       	call   801048ca <release>
80105df0:	83 c4 10             	add    $0x10,%esp
  return 0;
80105df3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105df8:	c9                   	leave  
80105df9:	c3                   	ret    

80105dfa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105dfa:	55                   	push   %ebp
80105dfb:	89 e5                	mov    %esp,%ebp
80105dfd:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105e00:	83 ec 0c             	sub    $0xc,%esp
80105e03:	68 40 69 19 80       	push   $0x80196940
80105e08:	e8 4f ea ff ff       	call   8010485c <acquire>
80105e0d:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105e10:	a1 74 69 19 80       	mov    0x80196974,%eax
80105e15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105e18:	83 ec 0c             	sub    $0xc,%esp
80105e1b:	68 40 69 19 80       	push   $0x80196940
80105e20:	e8 a5 ea ff ff       	call   801048ca <release>
80105e25:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e2b:	c9                   	leave  
80105e2c:	c3                   	ret    

80105e2d <sys_printpt>:

int sys_printpt(void)
{
80105e2d:	55                   	push   %ebp
80105e2e:	89 e5                	mov    %esp,%ebp
80105e30:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if (argint(0, &pid) < 0)
80105e33:	83 ec 08             	sub    $0x8,%esp
80105e36:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e39:	50                   	push   %eax
80105e3a:	6a 00                	push   $0x0
80105e3c:	e8 a0 ef ff ff       	call   80104de1 <argint>
80105e41:	83 c4 10             	add    $0x10,%esp
80105e44:	85 c0                	test   %eax,%eax
80105e46:	79 07                	jns    80105e4f <sys_printpt+0x22>
    return -1;
80105e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e4d:	eb 14                	jmp    80105e63 <sys_printpt+0x36>

  printpt(pid);
80105e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e52:	83 ec 0c             	sub    $0xc,%esp
80105e55:	50                   	push   %eax
80105e56:	e8 30 e7 ff ff       	call   8010458b <printpt>
80105e5b:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e63:	c9                   	leave  
80105e64:	c3                   	ret    

80105e65 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105e65:	1e                   	push   %ds
  pushl %es
80105e66:	06                   	push   %es
  pushl %fs
80105e67:	0f a0                	push   %fs
  pushl %gs
80105e69:	0f a8                	push   %gs
  pushal
80105e6b:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105e6c:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105e70:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105e72:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105e74:	54                   	push   %esp
  call trap
80105e75:	e8 e3 01 00 00       	call   8010605d <trap>
  addl $4, %esp
80105e7a:	83 c4 04             	add    $0x4,%esp

80105e7d <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105e7d:	61                   	popa   
  popl %gs
80105e7e:	0f a9                	pop    %gs
  popl %fs
80105e80:	0f a1                	pop    %fs
  popl %es
80105e82:	07                   	pop    %es
  popl %ds
80105e83:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105e84:	83 c4 08             	add    $0x8,%esp
  iret
80105e87:	cf                   	iret   

80105e88 <lidt>:
{
80105e88:	55                   	push   %ebp
80105e89:	89 e5                	mov    %esp,%ebp
80105e8b:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e91:	83 e8 01             	sub    $0x1,%eax
80105e94:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105e98:	8b 45 08             	mov    0x8(%ebp),%eax
80105e9b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea2:	c1 e8 10             	shr    $0x10,%eax
80105ea5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105ea9:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105eac:	0f 01 18             	lidtl  (%eax)
}
80105eaf:	90                   	nop
80105eb0:	c9                   	leave  
80105eb1:	c3                   	ret    

80105eb2 <rcr2>:

static inline uint
rcr2(void)
{
80105eb2:	55                   	push   %ebp
80105eb3:	89 e5                	mov    %esp,%ebp
80105eb5:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105eb8:	0f 20 d0             	mov    %cr2,%eax
80105ebb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105ebe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ec1:	c9                   	leave  
80105ec2:	c3                   	ret    

80105ec3 <lcr3>:

static inline void
lcr3(uint val)
{
80105ec3:	55                   	push   %ebp
80105ec4:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec9:	0f 22 d8             	mov    %eax,%cr3
}
80105ecc:	90                   	nop
80105ecd:	5d                   	pop    %ebp
80105ece:	c3                   	ret    

80105ecf <tvinit>:
int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);
pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);

void
tvinit(void)
{
80105ecf:	55                   	push   %ebp
80105ed0:	89 e5                	mov    %esp,%ebp
80105ed2:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105ed5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105edc:	e9 c3 00 00 00       	jmp    80105fa4 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee4:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105eeb:	89 c2                	mov    %eax,%edx
80105eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef0:	66 89 14 c5 40 61 19 	mov    %dx,-0x7fe69ec0(,%eax,8)
80105ef7:	80 
80105ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efb:	66 c7 04 c5 42 61 19 	movw   $0x8,-0x7fe69ebe(,%eax,8)
80105f02:	80 08 00 
80105f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f08:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105f0f:	80 
80105f10:	83 e2 e0             	and    $0xffffffe0,%edx
80105f13:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1d:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105f24:	80 
80105f25:	83 e2 1f             	and    $0x1f,%edx
80105f28:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f32:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f39:	80 
80105f3a:	83 e2 f0             	and    $0xfffffff0,%edx
80105f3d:	83 ca 0e             	or     $0xe,%edx
80105f40:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4a:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f51:	80 
80105f52:	83 e2 ef             	and    $0xffffffef,%edx
80105f55:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5f:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f66:	80 
80105f67:	83 e2 9f             	and    $0xffffff9f,%edx
80105f6a:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f74:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f7b:	80 
80105f7c:	83 ca 80             	or     $0xffffff80,%edx
80105f7f:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f89:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f90:	c1 e8 10             	shr    $0x10,%eax
80105f93:	89 c2                	mov    %eax,%edx
80105f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f98:	66 89 14 c5 46 61 19 	mov    %dx,-0x7fe69eba(,%eax,8)
80105f9f:	80 
  for(i = 0; i < 256; i++)
80105fa0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105fa4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105fab:	0f 8e 30 ff ff ff    	jle    80105ee1 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105fb1:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105fb6:	66 a3 40 63 19 80    	mov    %ax,0x80196340
80105fbc:	66 c7 05 42 63 19 80 	movw   $0x8,0x80196342
80105fc3:	08 00 
80105fc5:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105fcc:	83 e0 e0             	and    $0xffffffe0,%eax
80105fcf:	a2 44 63 19 80       	mov    %al,0x80196344
80105fd4:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105fdb:	83 e0 1f             	and    $0x1f,%eax
80105fde:	a2 44 63 19 80       	mov    %al,0x80196344
80105fe3:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105fea:	83 c8 0f             	or     $0xf,%eax
80105fed:	a2 45 63 19 80       	mov    %al,0x80196345
80105ff2:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105ff9:	83 e0 ef             	and    $0xffffffef,%eax
80105ffc:	a2 45 63 19 80       	mov    %al,0x80196345
80106001:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80106008:	83 c8 60             	or     $0x60,%eax
8010600b:	a2 45 63 19 80       	mov    %al,0x80196345
80106010:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80106017:	83 c8 80             	or     $0xffffff80,%eax
8010601a:	a2 45 63 19 80       	mov    %al,0x80196345
8010601f:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106024:	c1 e8 10             	shr    $0x10,%eax
80106027:	66 a3 46 63 19 80    	mov    %ax,0x80196346

  initlock(&tickslock, "time");
8010602d:	83 ec 08             	sub    $0x8,%esp
80106030:	68 b8 a7 10 80       	push   $0x8010a7b8
80106035:	68 40 69 19 80       	push   $0x80196940
8010603a:	e8 fb e7 ff ff       	call   8010483a <initlock>
8010603f:	83 c4 10             	add    $0x10,%esp
}
80106042:	90                   	nop
80106043:	c9                   	leave  
80106044:	c3                   	ret    

80106045 <idtinit>:

void
idtinit(void)
{
80106045:	55                   	push   %ebp
80106046:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106048:	68 00 08 00 00       	push   $0x800
8010604d:	68 40 61 19 80       	push   $0x80196140
80106052:	e8 31 fe ff ff       	call   80105e88 <lidt>
80106057:	83 c4 08             	add    $0x8,%esp
}
8010605a:	90                   	nop
8010605b:	c9                   	leave  
8010605c:	c3                   	ret    

8010605d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010605d:	55                   	push   %ebp
8010605e:	89 e5                	mov    %esp,%ebp
80106060:	57                   	push   %edi
80106061:	56                   	push   %esi
80106062:	53                   	push   %ebx
80106063:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106066:	8b 45 08             	mov    0x8(%ebp),%eax
80106069:	8b 40 30             	mov    0x30(%eax),%eax
8010606c:	83 f8 40             	cmp    $0x40,%eax
8010606f:	75 3b                	jne    801060ac <trap+0x4f>
    if(myproc()->killed)
80106071:	e8 bb d9 ff ff       	call   80103a31 <myproc>
80106076:	8b 40 24             	mov    0x24(%eax),%eax
80106079:	85 c0                	test   %eax,%eax
8010607b:	74 05                	je     80106082 <trap+0x25>
      exit();
8010607d:	e8 3c de ff ff       	call   80103ebe <exit>
    myproc()->tf = tf;
80106082:	e8 aa d9 ff ff       	call   80103a31 <myproc>
80106087:	8b 55 08             	mov    0x8(%ebp),%edx
8010608a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010608d:	e8 0c ee ff ff       	call   80104e9e <syscall>
    if(myproc()->killed)
80106092:	e8 9a d9 ff ff       	call   80103a31 <myproc>
80106097:	8b 40 24             	mov    0x24(%eax),%eax
8010609a:	85 c0                	test   %eax,%eax
8010609c:	0f 84 ec 03 00 00    	je     8010648e <trap+0x431>
      exit();
801060a2:	e8 17 de ff ff       	call   80103ebe <exit>
    return;
801060a7:	e9 e2 03 00 00       	jmp    8010648e <trap+0x431>
  }

  switch(tf->trapno){
801060ac:	8b 45 08             	mov    0x8(%ebp),%eax
801060af:	8b 40 30             	mov    0x30(%eax),%eax
801060b2:	83 e8 0e             	sub    $0xe,%eax
801060b5:	83 f8 31             	cmp    $0x31,%eax
801060b8:	0f 87 c8 01 00 00    	ja     80106286 <trap+0x229>
801060be:	8b 04 85 5c a9 10 80 	mov    -0x7fef56a4(,%eax,4),%eax
801060c5:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801060c7:	e8 d2 d8 ff ff       	call   8010399e <cpuid>
801060cc:	85 c0                	test   %eax,%eax
801060ce:	75 3d                	jne    8010610d <trap+0xb0>
      acquire(&tickslock);
801060d0:	83 ec 0c             	sub    $0xc,%esp
801060d3:	68 40 69 19 80       	push   $0x80196940
801060d8:	e8 7f e7 ff ff       	call   8010485c <acquire>
801060dd:	83 c4 10             	add    $0x10,%esp
      ticks++;
801060e0:	a1 74 69 19 80       	mov    0x80196974,%eax
801060e5:	83 c0 01             	add    $0x1,%eax
801060e8:	a3 74 69 19 80       	mov    %eax,0x80196974
      wakeup(&ticks);
801060ed:	83 ec 0c             	sub    $0xc,%esp
801060f0:	68 74 69 19 80       	push   $0x80196974
801060f5:	e8 dc e2 ff ff       	call   801043d6 <wakeup>
801060fa:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801060fd:	83 ec 0c             	sub    $0xc,%esp
80106100:	68 40 69 19 80       	push   $0x80196940
80106105:	e8 c0 e7 ff ff       	call   801048ca <release>
8010610a:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010610d:	e8 0b ca ff ff       	call   80102b1d <lapiceoi>
    break;
80106112:	e9 f7 02 00 00       	jmp    8010640e <trap+0x3b1>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106117:	e8 b8 40 00 00       	call   8010a1d4 <ideintr>
    lapiceoi();
8010611c:	e8 fc c9 ff ff       	call   80102b1d <lapiceoi>
    break;
80106121:	e9 e8 02 00 00       	jmp    8010640e <trap+0x3b1>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106126:	e8 37 c8 ff ff       	call   80102962 <kbdintr>
    lapiceoi();
8010612b:	e8 ed c9 ff ff       	call   80102b1d <lapiceoi>
    break;
80106130:	e9 d9 02 00 00       	jmp    8010640e <trap+0x3b1>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106135:	e8 2a 05 00 00       	call   80106664 <uartintr>
    lapiceoi();
8010613a:	e8 de c9 ff ff       	call   80102b1d <lapiceoi>
    break;
8010613f:	e9 ca 02 00 00       	jmp    8010640e <trap+0x3b1>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106144:	e8 3e 2d 00 00       	call   80108e87 <i8254_intr>
    lapiceoi();
80106149:	e8 cf c9 ff ff       	call   80102b1d <lapiceoi>
    break;
8010614e:	e9 bb 02 00 00       	jmp    8010640e <trap+0x3b1>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106153:	8b 45 08             	mov    0x8(%ebp),%eax
80106156:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106159:	8b 45 08             	mov    0x8(%ebp),%eax
8010615c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106160:	0f b7 d8             	movzwl %ax,%ebx
80106163:	e8 36 d8 ff ff       	call   8010399e <cpuid>
80106168:	56                   	push   %esi
80106169:	53                   	push   %ebx
8010616a:	50                   	push   %eax
8010616b:	68 c0 a7 10 80       	push   $0x8010a7c0
80106170:	e8 7f a2 ff ff       	call   801003f4 <cprintf>
80106175:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106178:	e8 a0 c9 ff ff       	call   80102b1d <lapiceoi>
    break;
8010617d:	e9 8c 02 00 00       	jmp    8010640e <trap+0x3b1>

  case T_PGFLT: {
    uint fault_va = rcr2();
80106182:	e8 2b fd ff ff       	call   80105eb2 <rcr2>
80106187:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    uint va = PGROUNDDOWN(fault_va);
8010618a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010618d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106192:	89 45 e0             	mov    %eax,-0x20(%ebp)
    struct proc *p = myproc();
80106195:	e8 97 d8 ff ff       	call   80103a31 <myproc>
8010619a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    //cprintf("trap 14\n");
    //cprintf("[trap] page fault pid=%d name=%s va=0x%x eip=0x%x esp=0x%x\n", p ? p->pid : -1, p ? p->name : "(null)", fault_va, tf->eip, tf->esp); 
    
    if (p == 0)
8010619d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801061a1:	75 0d                	jne    801061b0 <trap+0x153>
      panic("page fault with no process");
801061a3:	83 ec 0c             	sub    $0xc,%esp
801061a6:	68 e4 a7 10 80       	push   $0x8010a7e4
801061ab:	e8 f9 a3 ff ff       	call   801005a9 <panic>
    /**if (va >= p->sz) {
      p->killed = 1;
      break;
    } **/
    
    char *mem = kalloc();
801061b0:	e8 ec c5 ff ff       	call   801027a1 <kalloc>
801061b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (mem == 0) {
801061b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801061bc:	75 1f                	jne    801061dd <trap+0x180>
      cprintf("trap: out of memory\n");
801061be:	83 ec 0c             	sub    $0xc,%esp
801061c1:	68 ff a7 10 80       	push   $0x8010a7ff
801061c6:	e8 29 a2 ff ff       	call   801003f4 <cprintf>
801061cb:	83 c4 10             	add    $0x10,%esp
      p->killed = 1;
801061ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
801061d1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
801061d8:	e9 31 02 00 00       	jmp    8010640e <trap+0x3b1>
    }
    memset(mem, 0, PGSIZE);
801061dd:	83 ec 04             	sub    $0x4,%esp
801061e0:	68 00 10 00 00       	push   $0x1000
801061e5:	6a 00                	push   $0x0
801061e7:	ff 75 d8             	push   -0x28(%ebp)
801061ea:	e8 e3 e8 ff ff       	call   80104ad2 <memset>
801061ef:	83 c4 10             	add    $0x10,%esp
    if (mappages(p->pgdir, (char*)va, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
801061f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801061f5:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801061fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
801061fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106201:	8b 40 04             	mov    0x4(%eax),%eax
80106204:	83 ec 0c             	sub    $0xc,%esp
80106207:	6a 06                	push   $0x6
80106209:	51                   	push   %ecx
8010620a:	68 00 10 00 00       	push   $0x1000
8010620f:	52                   	push   %edx
80106210:	50                   	push   %eax
80106211:	e8 12 13 00 00       	call   80107528 <mappages>
80106216:	83 c4 20             	add    $0x20,%esp
80106219:	85 c0                	test   %eax,%eax
8010621b:	79 2d                	jns    8010624a <trap+0x1ed>
      kfree(mem);
8010621d:	83 ec 0c             	sub    $0xc,%esp
80106220:	ff 75 d8             	push   -0x28(%ebp)
80106223:	e8 df c4 ff ff       	call   80102707 <kfree>
80106228:	83 c4 10             	add    $0x10,%esp
      cprintf("kill kfree(mem)\n");
8010622b:	83 ec 0c             	sub    $0xc,%esp
8010622e:	68 14 a8 10 80       	push   $0x8010a814
80106233:	e8 bc a1 ff ff       	call   801003f4 <cprintf>
80106238:	83 c4 10             	add    $0x10,%esp
      p->killed = 1;
8010623b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010623e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
80106245:	e9 c4 01 00 00       	jmp    8010640e <trap+0x3b1>
    }
    if (va + PGSIZE > p->sz)
8010624a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010624d:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
80106253:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106256:	8b 00                	mov    (%eax),%eax
80106258:	39 c2                	cmp    %eax,%edx
8010625a:	76 0e                	jbe    8010626a <trap+0x20d>
      p->sz = va + PGSIZE;
8010625c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010625f:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
80106265:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106268:	89 10                	mov    %edx,(%eax)

    lcr3(V2P(p->pgdir));
8010626a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010626d:	8b 40 04             	mov    0x4(%eax),%eax
80106270:	05 00 00 00 80       	add    $0x80000000,%eax
80106275:	83 ec 0c             	sub    $0xc,%esp
80106278:	50                   	push   %eax
80106279:	e8 45 fc ff ff       	call   80105ec3 <lcr3>
8010627e:	83 c4 10             	add    $0x10,%esp
    return;
80106281:	e9 09 02 00 00       	jmp    8010648f <trap+0x432>

  }

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106286:	e8 a6 d7 ff ff       	call   80103a31 <myproc>
8010628b:	85 c0                	test   %eax,%eax
8010628d:	74 11                	je     801062a0 <trap+0x243>
8010628f:	8b 45 08             	mov    0x8(%ebp),%eax
80106292:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106296:	0f b7 c0             	movzwl %ax,%eax
80106299:	83 e0 03             	and    $0x3,%eax
8010629c:	85 c0                	test   %eax,%eax
8010629e:	75 39                	jne    801062d9 <trap+0x27c>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801062a0:	e8 0d fc ff ff       	call   80105eb2 <rcr2>
801062a5:	89 c3                	mov    %eax,%ebx
801062a7:	8b 45 08             	mov    0x8(%ebp),%eax
801062aa:	8b 70 38             	mov    0x38(%eax),%esi
801062ad:	e8 ec d6 ff ff       	call   8010399e <cpuid>
801062b2:	8b 55 08             	mov    0x8(%ebp),%edx
801062b5:	8b 52 30             	mov    0x30(%edx),%edx
801062b8:	83 ec 0c             	sub    $0xc,%esp
801062bb:	53                   	push   %ebx
801062bc:	56                   	push   %esi
801062bd:	50                   	push   %eax
801062be:	52                   	push   %edx
801062bf:	68 28 a8 10 80       	push   $0x8010a828
801062c4:	e8 2b a1 ff ff       	call   801003f4 <cprintf>
801062c9:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801062cc:	83 ec 0c             	sub    $0xc,%esp
801062cf:	68 5a a8 10 80       	push   $0x8010a85a
801062d4:	e8 d0 a2 ff ff       	call   801005a9 <panic>
    }

    // In user space, unexpected trap: print extra diagnostics
    struct proc *p = myproc();
801062d9:	e8 53 d7 ff ff       	call   80103a31 <myproc>
801062de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    uint eip = tf->eip;
801062e1:	8b 45 08             	mov    0x8(%ebp),%eax
801062e4:	8b 40 38             	mov    0x38(%eax),%eax
801062e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
    uint esp = tf->esp;
801062ea:	8b 45 08             	mov    0x8(%ebp),%eax
801062ed:	8b 40 44             	mov    0x44(%eax),%eax
801062f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d eip 0x%x addr 0x%x--kill proc\n",
801062f3:	e8 ba fb ff ff       	call   80105eb2 <rcr2>
801062f8:	89 c3                	mov    %eax,%ebx
801062fa:	e8 9f d6 ff ff       	call   8010399e <cpuid>
801062ff:	8b 55 08             	mov    0x8(%ebp),%edx
80106302:	8b 72 34             	mov    0x34(%edx),%esi
80106305:	8b 55 08             	mov    0x8(%ebp),%edx
80106308:	8b 4a 30             	mov    0x30(%edx),%ecx
            p->pid, p->name, tf->trapno, tf->err, cpuid(), eip, rcr2());
8010630b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010630e:	8d 7a 6c             	lea    0x6c(%edx),%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d eip 0x%x addr 0x%x--kill proc\n",
80106311:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106314:	8b 52 10             	mov    0x10(%edx),%edx
80106317:	53                   	push   %ebx
80106318:	ff 75 d0             	push   -0x30(%ebp)
8010631b:	50                   	push   %eax
8010631c:	56                   	push   %esi
8010631d:	51                   	push   %ecx
8010631e:	57                   	push   %edi
8010631f:	52                   	push   %edx
80106320:	68 60 a8 10 80       	push   $0x8010a860
80106325:	e8 ca a0 ff ff       	call   801003f4 <cprintf>
8010632a:	83 c4 20             	add    $0x20,%esp

    pte_t *pte_eip = walkpgdir(p->pgdir, (void*)eip, 0);
8010632d:	8b 55 d0             	mov    -0x30(%ebp),%edx
80106330:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80106333:	8b 40 04             	mov    0x4(%eax),%eax
80106336:	83 ec 04             	sub    $0x4,%esp
80106339:	6a 00                	push   $0x0
8010633b:	52                   	push   %edx
8010633c:	50                   	push   %eax
8010633d:	e8 50 11 00 00       	call   80107492 <walkpgdir>
80106342:	83 c4 10             	add    $0x10,%esp
80106345:	89 45 c8             	mov    %eax,-0x38(%ebp)
    if (pte_eip && (*pte_eip & PTE_P)) {
80106348:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
8010634c:	74 36                	je     80106384 <trap+0x327>
8010634e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106351:	8b 00                	mov    (%eax),%eax
80106353:	83 e0 01             	and    $0x1,%eax
80106356:	85 c0                	test   %eax,%eax
80106358:	74 2a                	je     80106384 <trap+0x327>
      cprintf("  [trap] eip 0x%x is mapped to PA: 0x%x, flags=0x%x\n",
              eip, PTE_ADDR(*pte_eip), PTE_FLAGS(*pte_eip));
8010635a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010635d:	8b 00                	mov    (%eax),%eax
      cprintf("  [trap] eip 0x%x is mapped to PA: 0x%x, flags=0x%x\n",
8010635f:	25 ff 0f 00 00       	and    $0xfff,%eax
80106364:	89 c2                	mov    %eax,%edx
              eip, PTE_ADDR(*pte_eip), PTE_FLAGS(*pte_eip));
80106366:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106369:	8b 00                	mov    (%eax),%eax
      cprintf("  [trap] eip 0x%x is mapped to PA: 0x%x, flags=0x%x\n",
8010636b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106370:	52                   	push   %edx
80106371:	50                   	push   %eax
80106372:	ff 75 d0             	push   -0x30(%ebp)
80106375:	68 a4 a8 10 80       	push   $0x8010a8a4
8010637a:	e8 75 a0 ff ff       	call   801003f4 <cprintf>
8010637f:	83 c4 10             	add    $0x10,%esp
80106382:	eb 13                	jmp    80106397 <trap+0x33a>
    } else {
      cprintf("  [trap] eip 0x%x is NOT mapped!\n", eip);
80106384:	83 ec 08             	sub    $0x8,%esp
80106387:	ff 75 d0             	push   -0x30(%ebp)
8010638a:	68 dc a8 10 80       	push   $0x8010a8dc
8010638f:	e8 60 a0 ff ff       	call   801003f4 <cprintf>
80106394:	83 c4 10             	add    $0x10,%esp
    }

    pte_t *pte_esp = walkpgdir(p->pgdir, (void*)esp, 0);
80106397:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010639a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010639d:	8b 40 04             	mov    0x4(%eax),%eax
801063a0:	83 ec 04             	sub    $0x4,%esp
801063a3:	6a 00                	push   $0x0
801063a5:	52                   	push   %edx
801063a6:	50                   	push   %eax
801063a7:	e8 e6 10 00 00       	call   80107492 <walkpgdir>
801063ac:	83 c4 10             	add    $0x10,%esp
801063af:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    if (pte_esp && (*pte_esp & PTE_P)) {
801063b2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
801063b6:	74 36                	je     801063ee <trap+0x391>
801063b8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801063bb:	8b 00                	mov    (%eax),%eax
801063bd:	83 e0 01             	and    $0x1,%eax
801063c0:	85 c0                	test   %eax,%eax
801063c2:	74 2a                	je     801063ee <trap+0x391>
      cprintf("  [trap] esp 0x%x is mapped to PA: 0x%x, flags=0x%x\n",
              esp, PTE_ADDR(*pte_esp), PTE_FLAGS(*pte_esp));
801063c4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801063c7:	8b 00                	mov    (%eax),%eax
      cprintf("  [trap] esp 0x%x is mapped to PA: 0x%x, flags=0x%x\n",
801063c9:	25 ff 0f 00 00       	and    $0xfff,%eax
801063ce:	89 c2                	mov    %eax,%edx
              esp, PTE_ADDR(*pte_esp), PTE_FLAGS(*pte_esp));
801063d0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801063d3:	8b 00                	mov    (%eax),%eax
      cprintf("  [trap] esp 0x%x is mapped to PA: 0x%x, flags=0x%x\n",
801063d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801063da:	52                   	push   %edx
801063db:	50                   	push   %eax
801063dc:	ff 75 cc             	push   -0x34(%ebp)
801063df:	68 00 a9 10 80       	push   $0x8010a900
801063e4:	e8 0b a0 ff ff       	call   801003f4 <cprintf>
801063e9:	83 c4 10             	add    $0x10,%esp
801063ec:	eb 13                	jmp    80106401 <trap+0x3a4>
    } else {
      cprintf("  [trap] esp 0x%x is NOT mapped!\n", esp);
801063ee:	83 ec 08             	sub    $0x8,%esp
801063f1:	ff 75 cc             	push   -0x34(%ebp)
801063f4:	68 38 a9 10 80       	push   $0x8010a938
801063f9:	e8 f6 9f ff ff       	call   801003f4 <cprintf>
801063fe:	83 c4 10             	add    $0x10,%esp
    }

    p->killed = 1;
80106401:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80106404:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
    break;
8010640b:	eb 01                	jmp    8010640e <trap+0x3b1>
    break;
8010640d:	90                   	nop
  }  
  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010640e:	e8 1e d6 ff ff       	call   80103a31 <myproc>
80106413:	85 c0                	test   %eax,%eax
80106415:	74 23                	je     8010643a <trap+0x3dd>
80106417:	e8 15 d6 ff ff       	call   80103a31 <myproc>
8010641c:	8b 40 24             	mov    0x24(%eax),%eax
8010641f:	85 c0                	test   %eax,%eax
80106421:	74 17                	je     8010643a <trap+0x3dd>
80106423:	8b 45 08             	mov    0x8(%ebp),%eax
80106426:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010642a:	0f b7 c0             	movzwl %ax,%eax
8010642d:	83 e0 03             	and    $0x3,%eax
80106430:	83 f8 03             	cmp    $0x3,%eax
80106433:	75 05                	jne    8010643a <trap+0x3dd>
    exit();
80106435:	e8 84 da ff ff       	call   80103ebe <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010643a:	e8 f2 d5 ff ff       	call   80103a31 <myproc>
8010643f:	85 c0                	test   %eax,%eax
80106441:	74 1d                	je     80106460 <trap+0x403>
80106443:	e8 e9 d5 ff ff       	call   80103a31 <myproc>
80106448:	8b 40 0c             	mov    0xc(%eax),%eax
8010644b:	83 f8 04             	cmp    $0x4,%eax
8010644e:	75 10                	jne    80106460 <trap+0x403>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106450:	8b 45 08             	mov    0x8(%ebp),%eax
80106453:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106456:	83 f8 20             	cmp    $0x20,%eax
80106459:	75 05                	jne    80106460 <trap+0x403>
    yield();
8010645b:	e8 0f de ff ff       	call   8010426f <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106460:	e8 cc d5 ff ff       	call   80103a31 <myproc>
80106465:	85 c0                	test   %eax,%eax
80106467:	74 26                	je     8010648f <trap+0x432>
80106469:	e8 c3 d5 ff ff       	call   80103a31 <myproc>
8010646e:	8b 40 24             	mov    0x24(%eax),%eax
80106471:	85 c0                	test   %eax,%eax
80106473:	74 1a                	je     8010648f <trap+0x432>
80106475:	8b 45 08             	mov    0x8(%ebp),%eax
80106478:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010647c:	0f b7 c0             	movzwl %ax,%eax
8010647f:	83 e0 03             	and    $0x3,%eax
80106482:	83 f8 03             	cmp    $0x3,%eax
80106485:	75 08                	jne    8010648f <trap+0x432>
    exit();
80106487:	e8 32 da ff ff       	call   80103ebe <exit>
8010648c:	eb 01                	jmp    8010648f <trap+0x432>
    return;
8010648e:	90                   	nop
}
8010648f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106492:	5b                   	pop    %ebx
80106493:	5e                   	pop    %esi
80106494:	5f                   	pop    %edi
80106495:	5d                   	pop    %ebp
80106496:	c3                   	ret    

80106497 <inb>:
{
80106497:	55                   	push   %ebp
80106498:	89 e5                	mov    %esp,%ebp
8010649a:	83 ec 14             	sub    $0x14,%esp
8010649d:	8b 45 08             	mov    0x8(%ebp),%eax
801064a0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801064a4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801064a8:	89 c2                	mov    %eax,%edx
801064aa:	ec                   	in     (%dx),%al
801064ab:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801064ae:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801064b2:	c9                   	leave  
801064b3:	c3                   	ret    

801064b4 <outb>:
{
801064b4:	55                   	push   %ebp
801064b5:	89 e5                	mov    %esp,%ebp
801064b7:	83 ec 08             	sub    $0x8,%esp
801064ba:	8b 45 08             	mov    0x8(%ebp),%eax
801064bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801064c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801064c4:	89 d0                	mov    %edx,%eax
801064c6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801064c9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801064cd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801064d1:	ee                   	out    %al,(%dx)
}
801064d2:	90                   	nop
801064d3:	c9                   	leave  
801064d4:	c3                   	ret    

801064d5 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801064d5:	55                   	push   %ebp
801064d6:	89 e5                	mov    %esp,%ebp
801064d8:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801064db:	6a 00                	push   $0x0
801064dd:	68 fa 03 00 00       	push   $0x3fa
801064e2:	e8 cd ff ff ff       	call   801064b4 <outb>
801064e7:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801064ea:	68 80 00 00 00       	push   $0x80
801064ef:	68 fb 03 00 00       	push   $0x3fb
801064f4:	e8 bb ff ff ff       	call   801064b4 <outb>
801064f9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801064fc:	6a 0c                	push   $0xc
801064fe:	68 f8 03 00 00       	push   $0x3f8
80106503:	e8 ac ff ff ff       	call   801064b4 <outb>
80106508:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010650b:	6a 00                	push   $0x0
8010650d:	68 f9 03 00 00       	push   $0x3f9
80106512:	e8 9d ff ff ff       	call   801064b4 <outb>
80106517:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010651a:	6a 03                	push   $0x3
8010651c:	68 fb 03 00 00       	push   $0x3fb
80106521:	e8 8e ff ff ff       	call   801064b4 <outb>
80106526:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106529:	6a 00                	push   $0x0
8010652b:	68 fc 03 00 00       	push   $0x3fc
80106530:	e8 7f ff ff ff       	call   801064b4 <outb>
80106535:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106538:	6a 01                	push   $0x1
8010653a:	68 f9 03 00 00       	push   $0x3f9
8010653f:	e8 70 ff ff ff       	call   801064b4 <outb>
80106544:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106547:	68 fd 03 00 00       	push   $0x3fd
8010654c:	e8 46 ff ff ff       	call   80106497 <inb>
80106551:	83 c4 04             	add    $0x4,%esp
80106554:	3c ff                	cmp    $0xff,%al
80106556:	74 61                	je     801065b9 <uartinit+0xe4>
    return;
  uart = 1;
80106558:	c7 05 78 69 19 80 01 	movl   $0x1,0x80196978
8010655f:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106562:	68 fa 03 00 00       	push   $0x3fa
80106567:	e8 2b ff ff ff       	call   80106497 <inb>
8010656c:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010656f:	68 f8 03 00 00       	push   $0x3f8
80106574:	e8 1e ff ff ff       	call   80106497 <inb>
80106579:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010657c:	83 ec 08             	sub    $0x8,%esp
8010657f:	6a 00                	push   $0x0
80106581:	6a 04                	push   $0x4
80106583:	e8 a7 c0 ff ff       	call   8010262f <ioapicenable>
80106588:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010658b:	c7 45 f4 24 aa 10 80 	movl   $0x8010aa24,-0xc(%ebp)
80106592:	eb 19                	jmp    801065ad <uartinit+0xd8>
    uartputc(*p);
80106594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106597:	0f b6 00             	movzbl (%eax),%eax
8010659a:	0f be c0             	movsbl %al,%eax
8010659d:	83 ec 0c             	sub    $0xc,%esp
801065a0:	50                   	push   %eax
801065a1:	e8 16 00 00 00       	call   801065bc <uartputc>
801065a6:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801065a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b0:	0f b6 00             	movzbl (%eax),%eax
801065b3:	84 c0                	test   %al,%al
801065b5:	75 dd                	jne    80106594 <uartinit+0xbf>
801065b7:	eb 01                	jmp    801065ba <uartinit+0xe5>
    return;
801065b9:	90                   	nop
}
801065ba:	c9                   	leave  
801065bb:	c3                   	ret    

801065bc <uartputc>:

void
uartputc(int c)
{
801065bc:	55                   	push   %ebp
801065bd:	89 e5                	mov    %esp,%ebp
801065bf:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801065c2:	a1 78 69 19 80       	mov    0x80196978,%eax
801065c7:	85 c0                	test   %eax,%eax
801065c9:	74 53                	je     8010661e <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801065cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801065d2:	eb 11                	jmp    801065e5 <uartputc+0x29>
    microdelay(10);
801065d4:	83 ec 0c             	sub    $0xc,%esp
801065d7:	6a 0a                	push   $0xa
801065d9:	e8 5a c5 ff ff       	call   80102b38 <microdelay>
801065de:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801065e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065e5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801065e9:	7f 1a                	jg     80106605 <uartputc+0x49>
801065eb:	83 ec 0c             	sub    $0xc,%esp
801065ee:	68 fd 03 00 00       	push   $0x3fd
801065f3:	e8 9f fe ff ff       	call   80106497 <inb>
801065f8:	83 c4 10             	add    $0x10,%esp
801065fb:	0f b6 c0             	movzbl %al,%eax
801065fe:	83 e0 20             	and    $0x20,%eax
80106601:	85 c0                	test   %eax,%eax
80106603:	74 cf                	je     801065d4 <uartputc+0x18>
  outb(COM1+0, c);
80106605:	8b 45 08             	mov    0x8(%ebp),%eax
80106608:	0f b6 c0             	movzbl %al,%eax
8010660b:	83 ec 08             	sub    $0x8,%esp
8010660e:	50                   	push   %eax
8010660f:	68 f8 03 00 00       	push   $0x3f8
80106614:	e8 9b fe ff ff       	call   801064b4 <outb>
80106619:	83 c4 10             	add    $0x10,%esp
8010661c:	eb 01                	jmp    8010661f <uartputc+0x63>
    return;
8010661e:	90                   	nop
}
8010661f:	c9                   	leave  
80106620:	c3                   	ret    

80106621 <uartgetc>:

static int
uartgetc(void)
{
80106621:	55                   	push   %ebp
80106622:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106624:	a1 78 69 19 80       	mov    0x80196978,%eax
80106629:	85 c0                	test   %eax,%eax
8010662b:	75 07                	jne    80106634 <uartgetc+0x13>
    return -1;
8010662d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106632:	eb 2e                	jmp    80106662 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106634:	68 fd 03 00 00       	push   $0x3fd
80106639:	e8 59 fe ff ff       	call   80106497 <inb>
8010663e:	83 c4 04             	add    $0x4,%esp
80106641:	0f b6 c0             	movzbl %al,%eax
80106644:	83 e0 01             	and    $0x1,%eax
80106647:	85 c0                	test   %eax,%eax
80106649:	75 07                	jne    80106652 <uartgetc+0x31>
    return -1;
8010664b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106650:	eb 10                	jmp    80106662 <uartgetc+0x41>
  return inb(COM1+0);
80106652:	68 f8 03 00 00       	push   $0x3f8
80106657:	e8 3b fe ff ff       	call   80106497 <inb>
8010665c:	83 c4 04             	add    $0x4,%esp
8010665f:	0f b6 c0             	movzbl %al,%eax
}
80106662:	c9                   	leave  
80106663:	c3                   	ret    

80106664 <uartintr>:

void
uartintr(void)
{
80106664:	55                   	push   %ebp
80106665:	89 e5                	mov    %esp,%ebp
80106667:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010666a:	83 ec 0c             	sub    $0xc,%esp
8010666d:	68 21 66 10 80       	push   $0x80106621
80106672:	e8 5f a1 ff ff       	call   801007d6 <consoleintr>
80106677:	83 c4 10             	add    $0x10,%esp
}
8010667a:	90                   	nop
8010667b:	c9                   	leave  
8010667c:	c3                   	ret    

8010667d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010667d:	6a 00                	push   $0x0
  pushl $0
8010667f:	6a 00                	push   $0x0
  jmp alltraps
80106681:	e9 df f7 ff ff       	jmp    80105e65 <alltraps>

80106686 <vector1>:
.globl vector1
vector1:
  pushl $0
80106686:	6a 00                	push   $0x0
  pushl $1
80106688:	6a 01                	push   $0x1
  jmp alltraps
8010668a:	e9 d6 f7 ff ff       	jmp    80105e65 <alltraps>

8010668f <vector2>:
.globl vector2
vector2:
  pushl $0
8010668f:	6a 00                	push   $0x0
  pushl $2
80106691:	6a 02                	push   $0x2
  jmp alltraps
80106693:	e9 cd f7 ff ff       	jmp    80105e65 <alltraps>

80106698 <vector3>:
.globl vector3
vector3:
  pushl $0
80106698:	6a 00                	push   $0x0
  pushl $3
8010669a:	6a 03                	push   $0x3
  jmp alltraps
8010669c:	e9 c4 f7 ff ff       	jmp    80105e65 <alltraps>

801066a1 <vector4>:
.globl vector4
vector4:
  pushl $0
801066a1:	6a 00                	push   $0x0
  pushl $4
801066a3:	6a 04                	push   $0x4
  jmp alltraps
801066a5:	e9 bb f7 ff ff       	jmp    80105e65 <alltraps>

801066aa <vector5>:
.globl vector5
vector5:
  pushl $0
801066aa:	6a 00                	push   $0x0
  pushl $5
801066ac:	6a 05                	push   $0x5
  jmp alltraps
801066ae:	e9 b2 f7 ff ff       	jmp    80105e65 <alltraps>

801066b3 <vector6>:
.globl vector6
vector6:
  pushl $0
801066b3:	6a 00                	push   $0x0
  pushl $6
801066b5:	6a 06                	push   $0x6
  jmp alltraps
801066b7:	e9 a9 f7 ff ff       	jmp    80105e65 <alltraps>

801066bc <vector7>:
.globl vector7
vector7:
  pushl $0
801066bc:	6a 00                	push   $0x0
  pushl $7
801066be:	6a 07                	push   $0x7
  jmp alltraps
801066c0:	e9 a0 f7 ff ff       	jmp    80105e65 <alltraps>

801066c5 <vector8>:
.globl vector8
vector8:
  pushl $8
801066c5:	6a 08                	push   $0x8
  jmp alltraps
801066c7:	e9 99 f7 ff ff       	jmp    80105e65 <alltraps>

801066cc <vector9>:
.globl vector9
vector9:
  pushl $0
801066cc:	6a 00                	push   $0x0
  pushl $9
801066ce:	6a 09                	push   $0x9
  jmp alltraps
801066d0:	e9 90 f7 ff ff       	jmp    80105e65 <alltraps>

801066d5 <vector10>:
.globl vector10
vector10:
  pushl $10
801066d5:	6a 0a                	push   $0xa
  jmp alltraps
801066d7:	e9 89 f7 ff ff       	jmp    80105e65 <alltraps>

801066dc <vector11>:
.globl vector11
vector11:
  pushl $11
801066dc:	6a 0b                	push   $0xb
  jmp alltraps
801066de:	e9 82 f7 ff ff       	jmp    80105e65 <alltraps>

801066e3 <vector12>:
.globl vector12
vector12:
  pushl $12
801066e3:	6a 0c                	push   $0xc
  jmp alltraps
801066e5:	e9 7b f7 ff ff       	jmp    80105e65 <alltraps>

801066ea <vector13>:
.globl vector13
vector13:
  pushl $13
801066ea:	6a 0d                	push   $0xd
  jmp alltraps
801066ec:	e9 74 f7 ff ff       	jmp    80105e65 <alltraps>

801066f1 <vector14>:
.globl vector14
vector14:
  pushl $14
801066f1:	6a 0e                	push   $0xe
  jmp alltraps
801066f3:	e9 6d f7 ff ff       	jmp    80105e65 <alltraps>

801066f8 <vector15>:
.globl vector15
vector15:
  pushl $0
801066f8:	6a 00                	push   $0x0
  pushl $15
801066fa:	6a 0f                	push   $0xf
  jmp alltraps
801066fc:	e9 64 f7 ff ff       	jmp    80105e65 <alltraps>

80106701 <vector16>:
.globl vector16
vector16:
  pushl $0
80106701:	6a 00                	push   $0x0
  pushl $16
80106703:	6a 10                	push   $0x10
  jmp alltraps
80106705:	e9 5b f7 ff ff       	jmp    80105e65 <alltraps>

8010670a <vector17>:
.globl vector17
vector17:
  pushl $17
8010670a:	6a 11                	push   $0x11
  jmp alltraps
8010670c:	e9 54 f7 ff ff       	jmp    80105e65 <alltraps>

80106711 <vector18>:
.globl vector18
vector18:
  pushl $0
80106711:	6a 00                	push   $0x0
  pushl $18
80106713:	6a 12                	push   $0x12
  jmp alltraps
80106715:	e9 4b f7 ff ff       	jmp    80105e65 <alltraps>

8010671a <vector19>:
.globl vector19
vector19:
  pushl $0
8010671a:	6a 00                	push   $0x0
  pushl $19
8010671c:	6a 13                	push   $0x13
  jmp alltraps
8010671e:	e9 42 f7 ff ff       	jmp    80105e65 <alltraps>

80106723 <vector20>:
.globl vector20
vector20:
  pushl $0
80106723:	6a 00                	push   $0x0
  pushl $20
80106725:	6a 14                	push   $0x14
  jmp alltraps
80106727:	e9 39 f7 ff ff       	jmp    80105e65 <alltraps>

8010672c <vector21>:
.globl vector21
vector21:
  pushl $0
8010672c:	6a 00                	push   $0x0
  pushl $21
8010672e:	6a 15                	push   $0x15
  jmp alltraps
80106730:	e9 30 f7 ff ff       	jmp    80105e65 <alltraps>

80106735 <vector22>:
.globl vector22
vector22:
  pushl $0
80106735:	6a 00                	push   $0x0
  pushl $22
80106737:	6a 16                	push   $0x16
  jmp alltraps
80106739:	e9 27 f7 ff ff       	jmp    80105e65 <alltraps>

8010673e <vector23>:
.globl vector23
vector23:
  pushl $0
8010673e:	6a 00                	push   $0x0
  pushl $23
80106740:	6a 17                	push   $0x17
  jmp alltraps
80106742:	e9 1e f7 ff ff       	jmp    80105e65 <alltraps>

80106747 <vector24>:
.globl vector24
vector24:
  pushl $0
80106747:	6a 00                	push   $0x0
  pushl $24
80106749:	6a 18                	push   $0x18
  jmp alltraps
8010674b:	e9 15 f7 ff ff       	jmp    80105e65 <alltraps>

80106750 <vector25>:
.globl vector25
vector25:
  pushl $0
80106750:	6a 00                	push   $0x0
  pushl $25
80106752:	6a 19                	push   $0x19
  jmp alltraps
80106754:	e9 0c f7 ff ff       	jmp    80105e65 <alltraps>

80106759 <vector26>:
.globl vector26
vector26:
  pushl $0
80106759:	6a 00                	push   $0x0
  pushl $26
8010675b:	6a 1a                	push   $0x1a
  jmp alltraps
8010675d:	e9 03 f7 ff ff       	jmp    80105e65 <alltraps>

80106762 <vector27>:
.globl vector27
vector27:
  pushl $0
80106762:	6a 00                	push   $0x0
  pushl $27
80106764:	6a 1b                	push   $0x1b
  jmp alltraps
80106766:	e9 fa f6 ff ff       	jmp    80105e65 <alltraps>

8010676b <vector28>:
.globl vector28
vector28:
  pushl $0
8010676b:	6a 00                	push   $0x0
  pushl $28
8010676d:	6a 1c                	push   $0x1c
  jmp alltraps
8010676f:	e9 f1 f6 ff ff       	jmp    80105e65 <alltraps>

80106774 <vector29>:
.globl vector29
vector29:
  pushl $0
80106774:	6a 00                	push   $0x0
  pushl $29
80106776:	6a 1d                	push   $0x1d
  jmp alltraps
80106778:	e9 e8 f6 ff ff       	jmp    80105e65 <alltraps>

8010677d <vector30>:
.globl vector30
vector30:
  pushl $0
8010677d:	6a 00                	push   $0x0
  pushl $30
8010677f:	6a 1e                	push   $0x1e
  jmp alltraps
80106781:	e9 df f6 ff ff       	jmp    80105e65 <alltraps>

80106786 <vector31>:
.globl vector31
vector31:
  pushl $0
80106786:	6a 00                	push   $0x0
  pushl $31
80106788:	6a 1f                	push   $0x1f
  jmp alltraps
8010678a:	e9 d6 f6 ff ff       	jmp    80105e65 <alltraps>

8010678f <vector32>:
.globl vector32
vector32:
  pushl $0
8010678f:	6a 00                	push   $0x0
  pushl $32
80106791:	6a 20                	push   $0x20
  jmp alltraps
80106793:	e9 cd f6 ff ff       	jmp    80105e65 <alltraps>

80106798 <vector33>:
.globl vector33
vector33:
  pushl $0
80106798:	6a 00                	push   $0x0
  pushl $33
8010679a:	6a 21                	push   $0x21
  jmp alltraps
8010679c:	e9 c4 f6 ff ff       	jmp    80105e65 <alltraps>

801067a1 <vector34>:
.globl vector34
vector34:
  pushl $0
801067a1:	6a 00                	push   $0x0
  pushl $34
801067a3:	6a 22                	push   $0x22
  jmp alltraps
801067a5:	e9 bb f6 ff ff       	jmp    80105e65 <alltraps>

801067aa <vector35>:
.globl vector35
vector35:
  pushl $0
801067aa:	6a 00                	push   $0x0
  pushl $35
801067ac:	6a 23                	push   $0x23
  jmp alltraps
801067ae:	e9 b2 f6 ff ff       	jmp    80105e65 <alltraps>

801067b3 <vector36>:
.globl vector36
vector36:
  pushl $0
801067b3:	6a 00                	push   $0x0
  pushl $36
801067b5:	6a 24                	push   $0x24
  jmp alltraps
801067b7:	e9 a9 f6 ff ff       	jmp    80105e65 <alltraps>

801067bc <vector37>:
.globl vector37
vector37:
  pushl $0
801067bc:	6a 00                	push   $0x0
  pushl $37
801067be:	6a 25                	push   $0x25
  jmp alltraps
801067c0:	e9 a0 f6 ff ff       	jmp    80105e65 <alltraps>

801067c5 <vector38>:
.globl vector38
vector38:
  pushl $0
801067c5:	6a 00                	push   $0x0
  pushl $38
801067c7:	6a 26                	push   $0x26
  jmp alltraps
801067c9:	e9 97 f6 ff ff       	jmp    80105e65 <alltraps>

801067ce <vector39>:
.globl vector39
vector39:
  pushl $0
801067ce:	6a 00                	push   $0x0
  pushl $39
801067d0:	6a 27                	push   $0x27
  jmp alltraps
801067d2:	e9 8e f6 ff ff       	jmp    80105e65 <alltraps>

801067d7 <vector40>:
.globl vector40
vector40:
  pushl $0
801067d7:	6a 00                	push   $0x0
  pushl $40
801067d9:	6a 28                	push   $0x28
  jmp alltraps
801067db:	e9 85 f6 ff ff       	jmp    80105e65 <alltraps>

801067e0 <vector41>:
.globl vector41
vector41:
  pushl $0
801067e0:	6a 00                	push   $0x0
  pushl $41
801067e2:	6a 29                	push   $0x29
  jmp alltraps
801067e4:	e9 7c f6 ff ff       	jmp    80105e65 <alltraps>

801067e9 <vector42>:
.globl vector42
vector42:
  pushl $0
801067e9:	6a 00                	push   $0x0
  pushl $42
801067eb:	6a 2a                	push   $0x2a
  jmp alltraps
801067ed:	e9 73 f6 ff ff       	jmp    80105e65 <alltraps>

801067f2 <vector43>:
.globl vector43
vector43:
  pushl $0
801067f2:	6a 00                	push   $0x0
  pushl $43
801067f4:	6a 2b                	push   $0x2b
  jmp alltraps
801067f6:	e9 6a f6 ff ff       	jmp    80105e65 <alltraps>

801067fb <vector44>:
.globl vector44
vector44:
  pushl $0
801067fb:	6a 00                	push   $0x0
  pushl $44
801067fd:	6a 2c                	push   $0x2c
  jmp alltraps
801067ff:	e9 61 f6 ff ff       	jmp    80105e65 <alltraps>

80106804 <vector45>:
.globl vector45
vector45:
  pushl $0
80106804:	6a 00                	push   $0x0
  pushl $45
80106806:	6a 2d                	push   $0x2d
  jmp alltraps
80106808:	e9 58 f6 ff ff       	jmp    80105e65 <alltraps>

8010680d <vector46>:
.globl vector46
vector46:
  pushl $0
8010680d:	6a 00                	push   $0x0
  pushl $46
8010680f:	6a 2e                	push   $0x2e
  jmp alltraps
80106811:	e9 4f f6 ff ff       	jmp    80105e65 <alltraps>

80106816 <vector47>:
.globl vector47
vector47:
  pushl $0
80106816:	6a 00                	push   $0x0
  pushl $47
80106818:	6a 2f                	push   $0x2f
  jmp alltraps
8010681a:	e9 46 f6 ff ff       	jmp    80105e65 <alltraps>

8010681f <vector48>:
.globl vector48
vector48:
  pushl $0
8010681f:	6a 00                	push   $0x0
  pushl $48
80106821:	6a 30                	push   $0x30
  jmp alltraps
80106823:	e9 3d f6 ff ff       	jmp    80105e65 <alltraps>

80106828 <vector49>:
.globl vector49
vector49:
  pushl $0
80106828:	6a 00                	push   $0x0
  pushl $49
8010682a:	6a 31                	push   $0x31
  jmp alltraps
8010682c:	e9 34 f6 ff ff       	jmp    80105e65 <alltraps>

80106831 <vector50>:
.globl vector50
vector50:
  pushl $0
80106831:	6a 00                	push   $0x0
  pushl $50
80106833:	6a 32                	push   $0x32
  jmp alltraps
80106835:	e9 2b f6 ff ff       	jmp    80105e65 <alltraps>

8010683a <vector51>:
.globl vector51
vector51:
  pushl $0
8010683a:	6a 00                	push   $0x0
  pushl $51
8010683c:	6a 33                	push   $0x33
  jmp alltraps
8010683e:	e9 22 f6 ff ff       	jmp    80105e65 <alltraps>

80106843 <vector52>:
.globl vector52
vector52:
  pushl $0
80106843:	6a 00                	push   $0x0
  pushl $52
80106845:	6a 34                	push   $0x34
  jmp alltraps
80106847:	e9 19 f6 ff ff       	jmp    80105e65 <alltraps>

8010684c <vector53>:
.globl vector53
vector53:
  pushl $0
8010684c:	6a 00                	push   $0x0
  pushl $53
8010684e:	6a 35                	push   $0x35
  jmp alltraps
80106850:	e9 10 f6 ff ff       	jmp    80105e65 <alltraps>

80106855 <vector54>:
.globl vector54
vector54:
  pushl $0
80106855:	6a 00                	push   $0x0
  pushl $54
80106857:	6a 36                	push   $0x36
  jmp alltraps
80106859:	e9 07 f6 ff ff       	jmp    80105e65 <alltraps>

8010685e <vector55>:
.globl vector55
vector55:
  pushl $0
8010685e:	6a 00                	push   $0x0
  pushl $55
80106860:	6a 37                	push   $0x37
  jmp alltraps
80106862:	e9 fe f5 ff ff       	jmp    80105e65 <alltraps>

80106867 <vector56>:
.globl vector56
vector56:
  pushl $0
80106867:	6a 00                	push   $0x0
  pushl $56
80106869:	6a 38                	push   $0x38
  jmp alltraps
8010686b:	e9 f5 f5 ff ff       	jmp    80105e65 <alltraps>

80106870 <vector57>:
.globl vector57
vector57:
  pushl $0
80106870:	6a 00                	push   $0x0
  pushl $57
80106872:	6a 39                	push   $0x39
  jmp alltraps
80106874:	e9 ec f5 ff ff       	jmp    80105e65 <alltraps>

80106879 <vector58>:
.globl vector58
vector58:
  pushl $0
80106879:	6a 00                	push   $0x0
  pushl $58
8010687b:	6a 3a                	push   $0x3a
  jmp alltraps
8010687d:	e9 e3 f5 ff ff       	jmp    80105e65 <alltraps>

80106882 <vector59>:
.globl vector59
vector59:
  pushl $0
80106882:	6a 00                	push   $0x0
  pushl $59
80106884:	6a 3b                	push   $0x3b
  jmp alltraps
80106886:	e9 da f5 ff ff       	jmp    80105e65 <alltraps>

8010688b <vector60>:
.globl vector60
vector60:
  pushl $0
8010688b:	6a 00                	push   $0x0
  pushl $60
8010688d:	6a 3c                	push   $0x3c
  jmp alltraps
8010688f:	e9 d1 f5 ff ff       	jmp    80105e65 <alltraps>

80106894 <vector61>:
.globl vector61
vector61:
  pushl $0
80106894:	6a 00                	push   $0x0
  pushl $61
80106896:	6a 3d                	push   $0x3d
  jmp alltraps
80106898:	e9 c8 f5 ff ff       	jmp    80105e65 <alltraps>

8010689d <vector62>:
.globl vector62
vector62:
  pushl $0
8010689d:	6a 00                	push   $0x0
  pushl $62
8010689f:	6a 3e                	push   $0x3e
  jmp alltraps
801068a1:	e9 bf f5 ff ff       	jmp    80105e65 <alltraps>

801068a6 <vector63>:
.globl vector63
vector63:
  pushl $0
801068a6:	6a 00                	push   $0x0
  pushl $63
801068a8:	6a 3f                	push   $0x3f
  jmp alltraps
801068aa:	e9 b6 f5 ff ff       	jmp    80105e65 <alltraps>

801068af <vector64>:
.globl vector64
vector64:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $64
801068b1:	6a 40                	push   $0x40
  jmp alltraps
801068b3:	e9 ad f5 ff ff       	jmp    80105e65 <alltraps>

801068b8 <vector65>:
.globl vector65
vector65:
  pushl $0
801068b8:	6a 00                	push   $0x0
  pushl $65
801068ba:	6a 41                	push   $0x41
  jmp alltraps
801068bc:	e9 a4 f5 ff ff       	jmp    80105e65 <alltraps>

801068c1 <vector66>:
.globl vector66
vector66:
  pushl $0
801068c1:	6a 00                	push   $0x0
  pushl $66
801068c3:	6a 42                	push   $0x42
  jmp alltraps
801068c5:	e9 9b f5 ff ff       	jmp    80105e65 <alltraps>

801068ca <vector67>:
.globl vector67
vector67:
  pushl $0
801068ca:	6a 00                	push   $0x0
  pushl $67
801068cc:	6a 43                	push   $0x43
  jmp alltraps
801068ce:	e9 92 f5 ff ff       	jmp    80105e65 <alltraps>

801068d3 <vector68>:
.globl vector68
vector68:
  pushl $0
801068d3:	6a 00                	push   $0x0
  pushl $68
801068d5:	6a 44                	push   $0x44
  jmp alltraps
801068d7:	e9 89 f5 ff ff       	jmp    80105e65 <alltraps>

801068dc <vector69>:
.globl vector69
vector69:
  pushl $0
801068dc:	6a 00                	push   $0x0
  pushl $69
801068de:	6a 45                	push   $0x45
  jmp alltraps
801068e0:	e9 80 f5 ff ff       	jmp    80105e65 <alltraps>

801068e5 <vector70>:
.globl vector70
vector70:
  pushl $0
801068e5:	6a 00                	push   $0x0
  pushl $70
801068e7:	6a 46                	push   $0x46
  jmp alltraps
801068e9:	e9 77 f5 ff ff       	jmp    80105e65 <alltraps>

801068ee <vector71>:
.globl vector71
vector71:
  pushl $0
801068ee:	6a 00                	push   $0x0
  pushl $71
801068f0:	6a 47                	push   $0x47
  jmp alltraps
801068f2:	e9 6e f5 ff ff       	jmp    80105e65 <alltraps>

801068f7 <vector72>:
.globl vector72
vector72:
  pushl $0
801068f7:	6a 00                	push   $0x0
  pushl $72
801068f9:	6a 48                	push   $0x48
  jmp alltraps
801068fb:	e9 65 f5 ff ff       	jmp    80105e65 <alltraps>

80106900 <vector73>:
.globl vector73
vector73:
  pushl $0
80106900:	6a 00                	push   $0x0
  pushl $73
80106902:	6a 49                	push   $0x49
  jmp alltraps
80106904:	e9 5c f5 ff ff       	jmp    80105e65 <alltraps>

80106909 <vector74>:
.globl vector74
vector74:
  pushl $0
80106909:	6a 00                	push   $0x0
  pushl $74
8010690b:	6a 4a                	push   $0x4a
  jmp alltraps
8010690d:	e9 53 f5 ff ff       	jmp    80105e65 <alltraps>

80106912 <vector75>:
.globl vector75
vector75:
  pushl $0
80106912:	6a 00                	push   $0x0
  pushl $75
80106914:	6a 4b                	push   $0x4b
  jmp alltraps
80106916:	e9 4a f5 ff ff       	jmp    80105e65 <alltraps>

8010691b <vector76>:
.globl vector76
vector76:
  pushl $0
8010691b:	6a 00                	push   $0x0
  pushl $76
8010691d:	6a 4c                	push   $0x4c
  jmp alltraps
8010691f:	e9 41 f5 ff ff       	jmp    80105e65 <alltraps>

80106924 <vector77>:
.globl vector77
vector77:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $77
80106926:	6a 4d                	push   $0x4d
  jmp alltraps
80106928:	e9 38 f5 ff ff       	jmp    80105e65 <alltraps>

8010692d <vector78>:
.globl vector78
vector78:
  pushl $0
8010692d:	6a 00                	push   $0x0
  pushl $78
8010692f:	6a 4e                	push   $0x4e
  jmp alltraps
80106931:	e9 2f f5 ff ff       	jmp    80105e65 <alltraps>

80106936 <vector79>:
.globl vector79
vector79:
  pushl $0
80106936:	6a 00                	push   $0x0
  pushl $79
80106938:	6a 4f                	push   $0x4f
  jmp alltraps
8010693a:	e9 26 f5 ff ff       	jmp    80105e65 <alltraps>

8010693f <vector80>:
.globl vector80
vector80:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $80
80106941:	6a 50                	push   $0x50
  jmp alltraps
80106943:	e9 1d f5 ff ff       	jmp    80105e65 <alltraps>

80106948 <vector81>:
.globl vector81
vector81:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $81
8010694a:	6a 51                	push   $0x51
  jmp alltraps
8010694c:	e9 14 f5 ff ff       	jmp    80105e65 <alltraps>

80106951 <vector82>:
.globl vector82
vector82:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $82
80106953:	6a 52                	push   $0x52
  jmp alltraps
80106955:	e9 0b f5 ff ff       	jmp    80105e65 <alltraps>

8010695a <vector83>:
.globl vector83
vector83:
  pushl $0
8010695a:	6a 00                	push   $0x0
  pushl $83
8010695c:	6a 53                	push   $0x53
  jmp alltraps
8010695e:	e9 02 f5 ff ff       	jmp    80105e65 <alltraps>

80106963 <vector84>:
.globl vector84
vector84:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $84
80106965:	6a 54                	push   $0x54
  jmp alltraps
80106967:	e9 f9 f4 ff ff       	jmp    80105e65 <alltraps>

8010696c <vector85>:
.globl vector85
vector85:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $85
8010696e:	6a 55                	push   $0x55
  jmp alltraps
80106970:	e9 f0 f4 ff ff       	jmp    80105e65 <alltraps>

80106975 <vector86>:
.globl vector86
vector86:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $86
80106977:	6a 56                	push   $0x56
  jmp alltraps
80106979:	e9 e7 f4 ff ff       	jmp    80105e65 <alltraps>

8010697e <vector87>:
.globl vector87
vector87:
  pushl $0
8010697e:	6a 00                	push   $0x0
  pushl $87
80106980:	6a 57                	push   $0x57
  jmp alltraps
80106982:	e9 de f4 ff ff       	jmp    80105e65 <alltraps>

80106987 <vector88>:
.globl vector88
vector88:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $88
80106989:	6a 58                	push   $0x58
  jmp alltraps
8010698b:	e9 d5 f4 ff ff       	jmp    80105e65 <alltraps>

80106990 <vector89>:
.globl vector89
vector89:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $89
80106992:	6a 59                	push   $0x59
  jmp alltraps
80106994:	e9 cc f4 ff ff       	jmp    80105e65 <alltraps>

80106999 <vector90>:
.globl vector90
vector90:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $90
8010699b:	6a 5a                	push   $0x5a
  jmp alltraps
8010699d:	e9 c3 f4 ff ff       	jmp    80105e65 <alltraps>

801069a2 <vector91>:
.globl vector91
vector91:
  pushl $0
801069a2:	6a 00                	push   $0x0
  pushl $91
801069a4:	6a 5b                	push   $0x5b
  jmp alltraps
801069a6:	e9 ba f4 ff ff       	jmp    80105e65 <alltraps>

801069ab <vector92>:
.globl vector92
vector92:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $92
801069ad:	6a 5c                	push   $0x5c
  jmp alltraps
801069af:	e9 b1 f4 ff ff       	jmp    80105e65 <alltraps>

801069b4 <vector93>:
.globl vector93
vector93:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $93
801069b6:	6a 5d                	push   $0x5d
  jmp alltraps
801069b8:	e9 a8 f4 ff ff       	jmp    80105e65 <alltraps>

801069bd <vector94>:
.globl vector94
vector94:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $94
801069bf:	6a 5e                	push   $0x5e
  jmp alltraps
801069c1:	e9 9f f4 ff ff       	jmp    80105e65 <alltraps>

801069c6 <vector95>:
.globl vector95
vector95:
  pushl $0
801069c6:	6a 00                	push   $0x0
  pushl $95
801069c8:	6a 5f                	push   $0x5f
  jmp alltraps
801069ca:	e9 96 f4 ff ff       	jmp    80105e65 <alltraps>

801069cf <vector96>:
.globl vector96
vector96:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $96
801069d1:	6a 60                	push   $0x60
  jmp alltraps
801069d3:	e9 8d f4 ff ff       	jmp    80105e65 <alltraps>

801069d8 <vector97>:
.globl vector97
vector97:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $97
801069da:	6a 61                	push   $0x61
  jmp alltraps
801069dc:	e9 84 f4 ff ff       	jmp    80105e65 <alltraps>

801069e1 <vector98>:
.globl vector98
vector98:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $98
801069e3:	6a 62                	push   $0x62
  jmp alltraps
801069e5:	e9 7b f4 ff ff       	jmp    80105e65 <alltraps>

801069ea <vector99>:
.globl vector99
vector99:
  pushl $0
801069ea:	6a 00                	push   $0x0
  pushl $99
801069ec:	6a 63                	push   $0x63
  jmp alltraps
801069ee:	e9 72 f4 ff ff       	jmp    80105e65 <alltraps>

801069f3 <vector100>:
.globl vector100
vector100:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $100
801069f5:	6a 64                	push   $0x64
  jmp alltraps
801069f7:	e9 69 f4 ff ff       	jmp    80105e65 <alltraps>

801069fc <vector101>:
.globl vector101
vector101:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $101
801069fe:	6a 65                	push   $0x65
  jmp alltraps
80106a00:	e9 60 f4 ff ff       	jmp    80105e65 <alltraps>

80106a05 <vector102>:
.globl vector102
vector102:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $102
80106a07:	6a 66                	push   $0x66
  jmp alltraps
80106a09:	e9 57 f4 ff ff       	jmp    80105e65 <alltraps>

80106a0e <vector103>:
.globl vector103
vector103:
  pushl $0
80106a0e:	6a 00                	push   $0x0
  pushl $103
80106a10:	6a 67                	push   $0x67
  jmp alltraps
80106a12:	e9 4e f4 ff ff       	jmp    80105e65 <alltraps>

80106a17 <vector104>:
.globl vector104
vector104:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $104
80106a19:	6a 68                	push   $0x68
  jmp alltraps
80106a1b:	e9 45 f4 ff ff       	jmp    80105e65 <alltraps>

80106a20 <vector105>:
.globl vector105
vector105:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $105
80106a22:	6a 69                	push   $0x69
  jmp alltraps
80106a24:	e9 3c f4 ff ff       	jmp    80105e65 <alltraps>

80106a29 <vector106>:
.globl vector106
vector106:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $106
80106a2b:	6a 6a                	push   $0x6a
  jmp alltraps
80106a2d:	e9 33 f4 ff ff       	jmp    80105e65 <alltraps>

80106a32 <vector107>:
.globl vector107
vector107:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $107
80106a34:	6a 6b                	push   $0x6b
  jmp alltraps
80106a36:	e9 2a f4 ff ff       	jmp    80105e65 <alltraps>

80106a3b <vector108>:
.globl vector108
vector108:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $108
80106a3d:	6a 6c                	push   $0x6c
  jmp alltraps
80106a3f:	e9 21 f4 ff ff       	jmp    80105e65 <alltraps>

80106a44 <vector109>:
.globl vector109
vector109:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $109
80106a46:	6a 6d                	push   $0x6d
  jmp alltraps
80106a48:	e9 18 f4 ff ff       	jmp    80105e65 <alltraps>

80106a4d <vector110>:
.globl vector110
vector110:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $110
80106a4f:	6a 6e                	push   $0x6e
  jmp alltraps
80106a51:	e9 0f f4 ff ff       	jmp    80105e65 <alltraps>

80106a56 <vector111>:
.globl vector111
vector111:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $111
80106a58:	6a 6f                	push   $0x6f
  jmp alltraps
80106a5a:	e9 06 f4 ff ff       	jmp    80105e65 <alltraps>

80106a5f <vector112>:
.globl vector112
vector112:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $112
80106a61:	6a 70                	push   $0x70
  jmp alltraps
80106a63:	e9 fd f3 ff ff       	jmp    80105e65 <alltraps>

80106a68 <vector113>:
.globl vector113
vector113:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $113
80106a6a:	6a 71                	push   $0x71
  jmp alltraps
80106a6c:	e9 f4 f3 ff ff       	jmp    80105e65 <alltraps>

80106a71 <vector114>:
.globl vector114
vector114:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $114
80106a73:	6a 72                	push   $0x72
  jmp alltraps
80106a75:	e9 eb f3 ff ff       	jmp    80105e65 <alltraps>

80106a7a <vector115>:
.globl vector115
vector115:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $115
80106a7c:	6a 73                	push   $0x73
  jmp alltraps
80106a7e:	e9 e2 f3 ff ff       	jmp    80105e65 <alltraps>

80106a83 <vector116>:
.globl vector116
vector116:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $116
80106a85:	6a 74                	push   $0x74
  jmp alltraps
80106a87:	e9 d9 f3 ff ff       	jmp    80105e65 <alltraps>

80106a8c <vector117>:
.globl vector117
vector117:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $117
80106a8e:	6a 75                	push   $0x75
  jmp alltraps
80106a90:	e9 d0 f3 ff ff       	jmp    80105e65 <alltraps>

80106a95 <vector118>:
.globl vector118
vector118:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $118
80106a97:	6a 76                	push   $0x76
  jmp alltraps
80106a99:	e9 c7 f3 ff ff       	jmp    80105e65 <alltraps>

80106a9e <vector119>:
.globl vector119
vector119:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $119
80106aa0:	6a 77                	push   $0x77
  jmp alltraps
80106aa2:	e9 be f3 ff ff       	jmp    80105e65 <alltraps>

80106aa7 <vector120>:
.globl vector120
vector120:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $120
80106aa9:	6a 78                	push   $0x78
  jmp alltraps
80106aab:	e9 b5 f3 ff ff       	jmp    80105e65 <alltraps>

80106ab0 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $121
80106ab2:	6a 79                	push   $0x79
  jmp alltraps
80106ab4:	e9 ac f3 ff ff       	jmp    80105e65 <alltraps>

80106ab9 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $122
80106abb:	6a 7a                	push   $0x7a
  jmp alltraps
80106abd:	e9 a3 f3 ff ff       	jmp    80105e65 <alltraps>

80106ac2 <vector123>:
.globl vector123
vector123:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $123
80106ac4:	6a 7b                	push   $0x7b
  jmp alltraps
80106ac6:	e9 9a f3 ff ff       	jmp    80105e65 <alltraps>

80106acb <vector124>:
.globl vector124
vector124:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $124
80106acd:	6a 7c                	push   $0x7c
  jmp alltraps
80106acf:	e9 91 f3 ff ff       	jmp    80105e65 <alltraps>

80106ad4 <vector125>:
.globl vector125
vector125:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $125
80106ad6:	6a 7d                	push   $0x7d
  jmp alltraps
80106ad8:	e9 88 f3 ff ff       	jmp    80105e65 <alltraps>

80106add <vector126>:
.globl vector126
vector126:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $126
80106adf:	6a 7e                	push   $0x7e
  jmp alltraps
80106ae1:	e9 7f f3 ff ff       	jmp    80105e65 <alltraps>

80106ae6 <vector127>:
.globl vector127
vector127:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $127
80106ae8:	6a 7f                	push   $0x7f
  jmp alltraps
80106aea:	e9 76 f3 ff ff       	jmp    80105e65 <alltraps>

80106aef <vector128>:
.globl vector128
vector128:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $128
80106af1:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106af6:	e9 6a f3 ff ff       	jmp    80105e65 <alltraps>

80106afb <vector129>:
.globl vector129
vector129:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $129
80106afd:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106b02:	e9 5e f3 ff ff       	jmp    80105e65 <alltraps>

80106b07 <vector130>:
.globl vector130
vector130:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $130
80106b09:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106b0e:	e9 52 f3 ff ff       	jmp    80105e65 <alltraps>

80106b13 <vector131>:
.globl vector131
vector131:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $131
80106b15:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106b1a:	e9 46 f3 ff ff       	jmp    80105e65 <alltraps>

80106b1f <vector132>:
.globl vector132
vector132:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $132
80106b21:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106b26:	e9 3a f3 ff ff       	jmp    80105e65 <alltraps>

80106b2b <vector133>:
.globl vector133
vector133:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $133
80106b2d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106b32:	e9 2e f3 ff ff       	jmp    80105e65 <alltraps>

80106b37 <vector134>:
.globl vector134
vector134:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $134
80106b39:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106b3e:	e9 22 f3 ff ff       	jmp    80105e65 <alltraps>

80106b43 <vector135>:
.globl vector135
vector135:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $135
80106b45:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106b4a:	e9 16 f3 ff ff       	jmp    80105e65 <alltraps>

80106b4f <vector136>:
.globl vector136
vector136:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $136
80106b51:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106b56:	e9 0a f3 ff ff       	jmp    80105e65 <alltraps>

80106b5b <vector137>:
.globl vector137
vector137:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $137
80106b5d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106b62:	e9 fe f2 ff ff       	jmp    80105e65 <alltraps>

80106b67 <vector138>:
.globl vector138
vector138:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $138
80106b69:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106b6e:	e9 f2 f2 ff ff       	jmp    80105e65 <alltraps>

80106b73 <vector139>:
.globl vector139
vector139:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $139
80106b75:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106b7a:	e9 e6 f2 ff ff       	jmp    80105e65 <alltraps>

80106b7f <vector140>:
.globl vector140
vector140:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $140
80106b81:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106b86:	e9 da f2 ff ff       	jmp    80105e65 <alltraps>

80106b8b <vector141>:
.globl vector141
vector141:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $141
80106b8d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106b92:	e9 ce f2 ff ff       	jmp    80105e65 <alltraps>

80106b97 <vector142>:
.globl vector142
vector142:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $142
80106b99:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106b9e:	e9 c2 f2 ff ff       	jmp    80105e65 <alltraps>

80106ba3 <vector143>:
.globl vector143
vector143:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $143
80106ba5:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106baa:	e9 b6 f2 ff ff       	jmp    80105e65 <alltraps>

80106baf <vector144>:
.globl vector144
vector144:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $144
80106bb1:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106bb6:	e9 aa f2 ff ff       	jmp    80105e65 <alltraps>

80106bbb <vector145>:
.globl vector145
vector145:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $145
80106bbd:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106bc2:	e9 9e f2 ff ff       	jmp    80105e65 <alltraps>

80106bc7 <vector146>:
.globl vector146
vector146:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $146
80106bc9:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106bce:	e9 92 f2 ff ff       	jmp    80105e65 <alltraps>

80106bd3 <vector147>:
.globl vector147
vector147:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $147
80106bd5:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106bda:	e9 86 f2 ff ff       	jmp    80105e65 <alltraps>

80106bdf <vector148>:
.globl vector148
vector148:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $148
80106be1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106be6:	e9 7a f2 ff ff       	jmp    80105e65 <alltraps>

80106beb <vector149>:
.globl vector149
vector149:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $149
80106bed:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106bf2:	e9 6e f2 ff ff       	jmp    80105e65 <alltraps>

80106bf7 <vector150>:
.globl vector150
vector150:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $150
80106bf9:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106bfe:	e9 62 f2 ff ff       	jmp    80105e65 <alltraps>

80106c03 <vector151>:
.globl vector151
vector151:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $151
80106c05:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106c0a:	e9 56 f2 ff ff       	jmp    80105e65 <alltraps>

80106c0f <vector152>:
.globl vector152
vector152:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $152
80106c11:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106c16:	e9 4a f2 ff ff       	jmp    80105e65 <alltraps>

80106c1b <vector153>:
.globl vector153
vector153:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $153
80106c1d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106c22:	e9 3e f2 ff ff       	jmp    80105e65 <alltraps>

80106c27 <vector154>:
.globl vector154
vector154:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $154
80106c29:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106c2e:	e9 32 f2 ff ff       	jmp    80105e65 <alltraps>

80106c33 <vector155>:
.globl vector155
vector155:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $155
80106c35:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106c3a:	e9 26 f2 ff ff       	jmp    80105e65 <alltraps>

80106c3f <vector156>:
.globl vector156
vector156:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $156
80106c41:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106c46:	e9 1a f2 ff ff       	jmp    80105e65 <alltraps>

80106c4b <vector157>:
.globl vector157
vector157:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $157
80106c4d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106c52:	e9 0e f2 ff ff       	jmp    80105e65 <alltraps>

80106c57 <vector158>:
.globl vector158
vector158:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $158
80106c59:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106c5e:	e9 02 f2 ff ff       	jmp    80105e65 <alltraps>

80106c63 <vector159>:
.globl vector159
vector159:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $159
80106c65:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106c6a:	e9 f6 f1 ff ff       	jmp    80105e65 <alltraps>

80106c6f <vector160>:
.globl vector160
vector160:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $160
80106c71:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106c76:	e9 ea f1 ff ff       	jmp    80105e65 <alltraps>

80106c7b <vector161>:
.globl vector161
vector161:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $161
80106c7d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106c82:	e9 de f1 ff ff       	jmp    80105e65 <alltraps>

80106c87 <vector162>:
.globl vector162
vector162:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $162
80106c89:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106c8e:	e9 d2 f1 ff ff       	jmp    80105e65 <alltraps>

80106c93 <vector163>:
.globl vector163
vector163:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $163
80106c95:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106c9a:	e9 c6 f1 ff ff       	jmp    80105e65 <alltraps>

80106c9f <vector164>:
.globl vector164
vector164:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $164
80106ca1:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106ca6:	e9 ba f1 ff ff       	jmp    80105e65 <alltraps>

80106cab <vector165>:
.globl vector165
vector165:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $165
80106cad:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106cb2:	e9 ae f1 ff ff       	jmp    80105e65 <alltraps>

80106cb7 <vector166>:
.globl vector166
vector166:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $166
80106cb9:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106cbe:	e9 a2 f1 ff ff       	jmp    80105e65 <alltraps>

80106cc3 <vector167>:
.globl vector167
vector167:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $167
80106cc5:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106cca:	e9 96 f1 ff ff       	jmp    80105e65 <alltraps>

80106ccf <vector168>:
.globl vector168
vector168:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $168
80106cd1:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106cd6:	e9 8a f1 ff ff       	jmp    80105e65 <alltraps>

80106cdb <vector169>:
.globl vector169
vector169:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $169
80106cdd:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106ce2:	e9 7e f1 ff ff       	jmp    80105e65 <alltraps>

80106ce7 <vector170>:
.globl vector170
vector170:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $170
80106ce9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106cee:	e9 72 f1 ff ff       	jmp    80105e65 <alltraps>

80106cf3 <vector171>:
.globl vector171
vector171:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $171
80106cf5:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106cfa:	e9 66 f1 ff ff       	jmp    80105e65 <alltraps>

80106cff <vector172>:
.globl vector172
vector172:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $172
80106d01:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106d06:	e9 5a f1 ff ff       	jmp    80105e65 <alltraps>

80106d0b <vector173>:
.globl vector173
vector173:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $173
80106d0d:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106d12:	e9 4e f1 ff ff       	jmp    80105e65 <alltraps>

80106d17 <vector174>:
.globl vector174
vector174:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $174
80106d19:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106d1e:	e9 42 f1 ff ff       	jmp    80105e65 <alltraps>

80106d23 <vector175>:
.globl vector175
vector175:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $175
80106d25:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106d2a:	e9 36 f1 ff ff       	jmp    80105e65 <alltraps>

80106d2f <vector176>:
.globl vector176
vector176:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $176
80106d31:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106d36:	e9 2a f1 ff ff       	jmp    80105e65 <alltraps>

80106d3b <vector177>:
.globl vector177
vector177:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $177
80106d3d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106d42:	e9 1e f1 ff ff       	jmp    80105e65 <alltraps>

80106d47 <vector178>:
.globl vector178
vector178:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $178
80106d49:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106d4e:	e9 12 f1 ff ff       	jmp    80105e65 <alltraps>

80106d53 <vector179>:
.globl vector179
vector179:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $179
80106d55:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106d5a:	e9 06 f1 ff ff       	jmp    80105e65 <alltraps>

80106d5f <vector180>:
.globl vector180
vector180:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $180
80106d61:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106d66:	e9 fa f0 ff ff       	jmp    80105e65 <alltraps>

80106d6b <vector181>:
.globl vector181
vector181:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $181
80106d6d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106d72:	e9 ee f0 ff ff       	jmp    80105e65 <alltraps>

80106d77 <vector182>:
.globl vector182
vector182:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $182
80106d79:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106d7e:	e9 e2 f0 ff ff       	jmp    80105e65 <alltraps>

80106d83 <vector183>:
.globl vector183
vector183:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $183
80106d85:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106d8a:	e9 d6 f0 ff ff       	jmp    80105e65 <alltraps>

80106d8f <vector184>:
.globl vector184
vector184:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $184
80106d91:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106d96:	e9 ca f0 ff ff       	jmp    80105e65 <alltraps>

80106d9b <vector185>:
.globl vector185
vector185:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $185
80106d9d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106da2:	e9 be f0 ff ff       	jmp    80105e65 <alltraps>

80106da7 <vector186>:
.globl vector186
vector186:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $186
80106da9:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106dae:	e9 b2 f0 ff ff       	jmp    80105e65 <alltraps>

80106db3 <vector187>:
.globl vector187
vector187:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $187
80106db5:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106dba:	e9 a6 f0 ff ff       	jmp    80105e65 <alltraps>

80106dbf <vector188>:
.globl vector188
vector188:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $188
80106dc1:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106dc6:	e9 9a f0 ff ff       	jmp    80105e65 <alltraps>

80106dcb <vector189>:
.globl vector189
vector189:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $189
80106dcd:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106dd2:	e9 8e f0 ff ff       	jmp    80105e65 <alltraps>

80106dd7 <vector190>:
.globl vector190
vector190:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $190
80106dd9:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106dde:	e9 82 f0 ff ff       	jmp    80105e65 <alltraps>

80106de3 <vector191>:
.globl vector191
vector191:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $191
80106de5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106dea:	e9 76 f0 ff ff       	jmp    80105e65 <alltraps>

80106def <vector192>:
.globl vector192
vector192:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $192
80106df1:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106df6:	e9 6a f0 ff ff       	jmp    80105e65 <alltraps>

80106dfb <vector193>:
.globl vector193
vector193:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $193
80106dfd:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106e02:	e9 5e f0 ff ff       	jmp    80105e65 <alltraps>

80106e07 <vector194>:
.globl vector194
vector194:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $194
80106e09:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106e0e:	e9 52 f0 ff ff       	jmp    80105e65 <alltraps>

80106e13 <vector195>:
.globl vector195
vector195:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $195
80106e15:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106e1a:	e9 46 f0 ff ff       	jmp    80105e65 <alltraps>

80106e1f <vector196>:
.globl vector196
vector196:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $196
80106e21:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106e26:	e9 3a f0 ff ff       	jmp    80105e65 <alltraps>

80106e2b <vector197>:
.globl vector197
vector197:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $197
80106e2d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106e32:	e9 2e f0 ff ff       	jmp    80105e65 <alltraps>

80106e37 <vector198>:
.globl vector198
vector198:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $198
80106e39:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106e3e:	e9 22 f0 ff ff       	jmp    80105e65 <alltraps>

80106e43 <vector199>:
.globl vector199
vector199:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $199
80106e45:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106e4a:	e9 16 f0 ff ff       	jmp    80105e65 <alltraps>

80106e4f <vector200>:
.globl vector200
vector200:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $200
80106e51:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106e56:	e9 0a f0 ff ff       	jmp    80105e65 <alltraps>

80106e5b <vector201>:
.globl vector201
vector201:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $201
80106e5d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106e62:	e9 fe ef ff ff       	jmp    80105e65 <alltraps>

80106e67 <vector202>:
.globl vector202
vector202:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $202
80106e69:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106e6e:	e9 f2 ef ff ff       	jmp    80105e65 <alltraps>

80106e73 <vector203>:
.globl vector203
vector203:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $203
80106e75:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106e7a:	e9 e6 ef ff ff       	jmp    80105e65 <alltraps>

80106e7f <vector204>:
.globl vector204
vector204:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $204
80106e81:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106e86:	e9 da ef ff ff       	jmp    80105e65 <alltraps>

80106e8b <vector205>:
.globl vector205
vector205:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $205
80106e8d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106e92:	e9 ce ef ff ff       	jmp    80105e65 <alltraps>

80106e97 <vector206>:
.globl vector206
vector206:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $206
80106e99:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106e9e:	e9 c2 ef ff ff       	jmp    80105e65 <alltraps>

80106ea3 <vector207>:
.globl vector207
vector207:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $207
80106ea5:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106eaa:	e9 b6 ef ff ff       	jmp    80105e65 <alltraps>

80106eaf <vector208>:
.globl vector208
vector208:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $208
80106eb1:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106eb6:	e9 aa ef ff ff       	jmp    80105e65 <alltraps>

80106ebb <vector209>:
.globl vector209
vector209:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $209
80106ebd:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106ec2:	e9 9e ef ff ff       	jmp    80105e65 <alltraps>

80106ec7 <vector210>:
.globl vector210
vector210:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $210
80106ec9:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106ece:	e9 92 ef ff ff       	jmp    80105e65 <alltraps>

80106ed3 <vector211>:
.globl vector211
vector211:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $211
80106ed5:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106eda:	e9 86 ef ff ff       	jmp    80105e65 <alltraps>

80106edf <vector212>:
.globl vector212
vector212:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $212
80106ee1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106ee6:	e9 7a ef ff ff       	jmp    80105e65 <alltraps>

80106eeb <vector213>:
.globl vector213
vector213:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $213
80106eed:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106ef2:	e9 6e ef ff ff       	jmp    80105e65 <alltraps>

80106ef7 <vector214>:
.globl vector214
vector214:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $214
80106ef9:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106efe:	e9 62 ef ff ff       	jmp    80105e65 <alltraps>

80106f03 <vector215>:
.globl vector215
vector215:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $215
80106f05:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106f0a:	e9 56 ef ff ff       	jmp    80105e65 <alltraps>

80106f0f <vector216>:
.globl vector216
vector216:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $216
80106f11:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106f16:	e9 4a ef ff ff       	jmp    80105e65 <alltraps>

80106f1b <vector217>:
.globl vector217
vector217:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $217
80106f1d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106f22:	e9 3e ef ff ff       	jmp    80105e65 <alltraps>

80106f27 <vector218>:
.globl vector218
vector218:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $218
80106f29:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106f2e:	e9 32 ef ff ff       	jmp    80105e65 <alltraps>

80106f33 <vector219>:
.globl vector219
vector219:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $219
80106f35:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106f3a:	e9 26 ef ff ff       	jmp    80105e65 <alltraps>

80106f3f <vector220>:
.globl vector220
vector220:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $220
80106f41:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106f46:	e9 1a ef ff ff       	jmp    80105e65 <alltraps>

80106f4b <vector221>:
.globl vector221
vector221:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $221
80106f4d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106f52:	e9 0e ef ff ff       	jmp    80105e65 <alltraps>

80106f57 <vector222>:
.globl vector222
vector222:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $222
80106f59:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106f5e:	e9 02 ef ff ff       	jmp    80105e65 <alltraps>

80106f63 <vector223>:
.globl vector223
vector223:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $223
80106f65:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106f6a:	e9 f6 ee ff ff       	jmp    80105e65 <alltraps>

80106f6f <vector224>:
.globl vector224
vector224:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $224
80106f71:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106f76:	e9 ea ee ff ff       	jmp    80105e65 <alltraps>

80106f7b <vector225>:
.globl vector225
vector225:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $225
80106f7d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106f82:	e9 de ee ff ff       	jmp    80105e65 <alltraps>

80106f87 <vector226>:
.globl vector226
vector226:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $226
80106f89:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106f8e:	e9 d2 ee ff ff       	jmp    80105e65 <alltraps>

80106f93 <vector227>:
.globl vector227
vector227:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $227
80106f95:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106f9a:	e9 c6 ee ff ff       	jmp    80105e65 <alltraps>

80106f9f <vector228>:
.globl vector228
vector228:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $228
80106fa1:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106fa6:	e9 ba ee ff ff       	jmp    80105e65 <alltraps>

80106fab <vector229>:
.globl vector229
vector229:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $229
80106fad:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106fb2:	e9 ae ee ff ff       	jmp    80105e65 <alltraps>

80106fb7 <vector230>:
.globl vector230
vector230:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $230
80106fb9:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106fbe:	e9 a2 ee ff ff       	jmp    80105e65 <alltraps>

80106fc3 <vector231>:
.globl vector231
vector231:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $231
80106fc5:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106fca:	e9 96 ee ff ff       	jmp    80105e65 <alltraps>

80106fcf <vector232>:
.globl vector232
vector232:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $232
80106fd1:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106fd6:	e9 8a ee ff ff       	jmp    80105e65 <alltraps>

80106fdb <vector233>:
.globl vector233
vector233:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $233
80106fdd:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106fe2:	e9 7e ee ff ff       	jmp    80105e65 <alltraps>

80106fe7 <vector234>:
.globl vector234
vector234:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $234
80106fe9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106fee:	e9 72 ee ff ff       	jmp    80105e65 <alltraps>

80106ff3 <vector235>:
.globl vector235
vector235:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $235
80106ff5:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106ffa:	e9 66 ee ff ff       	jmp    80105e65 <alltraps>

80106fff <vector236>:
.globl vector236
vector236:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $236
80107001:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107006:	e9 5a ee ff ff       	jmp    80105e65 <alltraps>

8010700b <vector237>:
.globl vector237
vector237:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $237
8010700d:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107012:	e9 4e ee ff ff       	jmp    80105e65 <alltraps>

80107017 <vector238>:
.globl vector238
vector238:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $238
80107019:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010701e:	e9 42 ee ff ff       	jmp    80105e65 <alltraps>

80107023 <vector239>:
.globl vector239
vector239:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $239
80107025:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010702a:	e9 36 ee ff ff       	jmp    80105e65 <alltraps>

8010702f <vector240>:
.globl vector240
vector240:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $240
80107031:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107036:	e9 2a ee ff ff       	jmp    80105e65 <alltraps>

8010703b <vector241>:
.globl vector241
vector241:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $241
8010703d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107042:	e9 1e ee ff ff       	jmp    80105e65 <alltraps>

80107047 <vector242>:
.globl vector242
vector242:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $242
80107049:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010704e:	e9 12 ee ff ff       	jmp    80105e65 <alltraps>

80107053 <vector243>:
.globl vector243
vector243:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $243
80107055:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010705a:	e9 06 ee ff ff       	jmp    80105e65 <alltraps>

8010705f <vector244>:
.globl vector244
vector244:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $244
80107061:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107066:	e9 fa ed ff ff       	jmp    80105e65 <alltraps>

8010706b <vector245>:
.globl vector245
vector245:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $245
8010706d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107072:	e9 ee ed ff ff       	jmp    80105e65 <alltraps>

80107077 <vector246>:
.globl vector246
vector246:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $246
80107079:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010707e:	e9 e2 ed ff ff       	jmp    80105e65 <alltraps>

80107083 <vector247>:
.globl vector247
vector247:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $247
80107085:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010708a:	e9 d6 ed ff ff       	jmp    80105e65 <alltraps>

8010708f <vector248>:
.globl vector248
vector248:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $248
80107091:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107096:	e9 ca ed ff ff       	jmp    80105e65 <alltraps>

8010709b <vector249>:
.globl vector249
vector249:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $249
8010709d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801070a2:	e9 be ed ff ff       	jmp    80105e65 <alltraps>

801070a7 <vector250>:
.globl vector250
vector250:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $250
801070a9:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801070ae:	e9 b2 ed ff ff       	jmp    80105e65 <alltraps>

801070b3 <vector251>:
.globl vector251
vector251:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $251
801070b5:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801070ba:	e9 a6 ed ff ff       	jmp    80105e65 <alltraps>

801070bf <vector252>:
.globl vector252
vector252:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $252
801070c1:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801070c6:	e9 9a ed ff ff       	jmp    80105e65 <alltraps>

801070cb <vector253>:
.globl vector253
vector253:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $253
801070cd:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801070d2:	e9 8e ed ff ff       	jmp    80105e65 <alltraps>

801070d7 <vector254>:
.globl vector254
vector254:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $254
801070d9:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801070de:	e9 82 ed ff ff       	jmp    80105e65 <alltraps>

801070e3 <vector255>:
.globl vector255
vector255:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $255
801070e5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801070ea:	e9 76 ed ff ff       	jmp    80105e65 <alltraps>

801070ef <lgdt>:
{
801070ef:	55                   	push   %ebp
801070f0:	89 e5                	mov    %esp,%ebp
801070f2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801070f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801070f8:	83 e8 01             	sub    $0x1,%eax
801070fb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801070ff:	8b 45 08             	mov    0x8(%ebp),%eax
80107102:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107106:	8b 45 08             	mov    0x8(%ebp),%eax
80107109:	c1 e8 10             	shr    $0x10,%eax
8010710c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107110:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107113:	0f 01 10             	lgdtl  (%eax)
}
80107116:	90                   	nop
80107117:	c9                   	leave  
80107118:	c3                   	ret    

80107119 <ltr>:
{
80107119:	55                   	push   %ebp
8010711a:	89 e5                	mov    %esp,%ebp
8010711c:	83 ec 04             	sub    $0x4,%esp
8010711f:	8b 45 08             	mov    0x8(%ebp),%eax
80107122:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107126:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010712a:	0f 00 d8             	ltr    %ax
}
8010712d:	90                   	nop
8010712e:	c9                   	leave  
8010712f:	c3                   	ret    

80107130 <lcr3>:
{
80107130:	55                   	push   %ebp
80107131:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107133:	8b 45 08             	mov    0x8(%ebp),%eax
80107136:	0f 22 d8             	mov    %eax,%cr3
}
80107139:	90                   	nop
8010713a:	5d                   	pop    %ebp
8010713b:	c3                   	ret    

8010713c <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010713c:	55                   	push   %ebp
8010713d:	89 e5                	mov    %esp,%ebp
8010713f:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107142:	e8 57 c8 ff ff       	call   8010399e <cpuid>
80107147:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010714d:	05 80 69 19 80       	add    $0x80196980,%eax
80107152:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107158:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010715e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107161:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010716a:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010716e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107171:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107175:	83 e2 f0             	and    $0xfffffff0,%edx
80107178:	83 ca 0a             	or     $0xa,%edx
8010717b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010717e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107181:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107185:	83 ca 10             	or     $0x10,%edx
80107188:	88 50 7d             	mov    %dl,0x7d(%eax)
8010718b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010718e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107192:	83 e2 9f             	and    $0xffffff9f,%edx
80107195:	88 50 7d             	mov    %dl,0x7d(%eax)
80107198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010719f:	83 ca 80             	or     $0xffffff80,%edx
801071a2:	88 50 7d             	mov    %dl,0x7d(%eax)
801071a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071ac:	83 ca 0f             	or     $0xf,%edx
801071af:	88 50 7e             	mov    %dl,0x7e(%eax)
801071b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071b9:	83 e2 ef             	and    $0xffffffef,%edx
801071bc:	88 50 7e             	mov    %dl,0x7e(%eax)
801071bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071c6:	83 e2 df             	and    $0xffffffdf,%edx
801071c9:	88 50 7e             	mov    %dl,0x7e(%eax)
801071cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071cf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071d3:	83 ca 40             	or     $0x40,%edx
801071d6:	88 50 7e             	mov    %dl,0x7e(%eax)
801071d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071dc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071e0:	83 ca 80             	or     $0xffffff80,%edx
801071e3:	88 50 7e             	mov    %dl,0x7e(%eax)
801071e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801071ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801071f7:	ff ff 
801071f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fc:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107203:	00 00 
80107205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107208:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010720f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107212:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107219:	83 e2 f0             	and    $0xfffffff0,%edx
8010721c:	83 ca 02             	or     $0x2,%edx
8010721f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107228:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010722f:	83 ca 10             	or     $0x10,%edx
80107232:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107242:	83 e2 9f             	and    $0xffffff9f,%edx
80107245:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010724b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107255:	83 ca 80             	or     $0xffffff80,%edx
80107258:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010725e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107261:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107268:	83 ca 0f             	or     $0xf,%edx
8010726b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107274:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010727b:	83 e2 ef             	and    $0xffffffef,%edx
8010727e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107287:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010728e:	83 e2 df             	and    $0xffffffdf,%edx
80107291:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801072a1:	83 ca 40             	or     $0x40,%edx
801072a4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801072aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ad:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801072b4:	83 ca 80             	or     $0xffffff80,%edx
801072b7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801072bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c0:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801072c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ca:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801072d1:	ff ff 
801072d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d6:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801072dd:	00 00 
801072df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e2:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801072e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ec:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801072f3:	83 e2 f0             	and    $0xfffffff0,%edx
801072f6:	83 ca 0a             	or     $0xa,%edx
801072f9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801072ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107302:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107309:	83 ca 10             	or     $0x10,%edx
8010730c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107315:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010731c:	83 ca 60             	or     $0x60,%edx
8010731f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107328:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010732f:	83 ca 80             	or     $0xffffff80,%edx
80107332:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107342:	83 ca 0f             	or     $0xf,%edx
80107345:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010734b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107355:	83 e2 ef             	and    $0xffffffef,%edx
80107358:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010735e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107361:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107368:	83 e2 df             	and    $0xffffffdf,%edx
8010736b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107374:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010737b:	83 ca 40             	or     $0x40,%edx
8010737e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107387:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010738e:	83 ca 80             	or     $0xffffff80,%edx
80107391:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739a:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801073a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a4:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801073ab:	ff ff 
801073ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b0:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801073b7:	00 00 
801073b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bc:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801073c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801073cd:	83 e2 f0             	and    $0xfffffff0,%edx
801073d0:	83 ca 02             	or     $0x2,%edx
801073d3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801073d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073dc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801073e3:	83 ca 10             	or     $0x10,%edx
801073e6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801073ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ef:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801073f6:	83 ca 60             	or     $0x60,%edx
801073f9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801073ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107402:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107409:	83 ca 80             	or     $0xffffff80,%edx
8010740c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107415:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010741c:	83 ca 0f             	or     $0xf,%edx
8010741f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107428:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010742f:	83 e2 ef             	and    $0xffffffef,%edx
80107432:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107442:	83 e2 df             	and    $0xffffffdf,%edx
80107445:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010744b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107455:	83 ca 40             	or     $0x40,%edx
80107458:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010745e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107461:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107468:	83 ca 80             	or     $0xffffff80,%edx
8010746b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107474:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010747b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747e:	83 c0 70             	add    $0x70,%eax
80107481:	83 ec 08             	sub    $0x8,%esp
80107484:	6a 30                	push   $0x30
80107486:	50                   	push   %eax
80107487:	e8 63 fc ff ff       	call   801070ef <lgdt>
8010748c:	83 c4 10             	add    $0x10,%esp
}
8010748f:	90                   	nop
80107490:	c9                   	leave  
80107491:	c3                   	ret    

80107492 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107492:	55                   	push   %ebp
80107493:	89 e5                	mov    %esp,%ebp
80107495:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107498:	8b 45 0c             	mov    0xc(%ebp),%eax
8010749b:	c1 e8 16             	shr    $0x16,%eax
8010749e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801074a5:	8b 45 08             	mov    0x8(%ebp),%eax
801074a8:	01 d0                	add    %edx,%eax
801074aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801074ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074b0:	8b 00                	mov    (%eax),%eax
801074b2:	83 e0 01             	and    $0x1,%eax
801074b5:	85 c0                	test   %eax,%eax
801074b7:	74 14                	je     801074cd <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801074b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074bc:	8b 00                	mov    (%eax),%eax
801074be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801074c3:	05 00 00 00 80       	add    $0x80000000,%eax
801074c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801074cb:	eb 42                	jmp    8010750f <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801074cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801074d1:	74 0e                	je     801074e1 <walkpgdir+0x4f>
801074d3:	e8 c9 b2 ff ff       	call   801027a1 <kalloc>
801074d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801074db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801074df:	75 07                	jne    801074e8 <walkpgdir+0x56>
      return 0;
801074e1:	b8 00 00 00 00       	mov    $0x0,%eax
801074e6:	eb 3e                	jmp    80107526 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801074e8:	83 ec 04             	sub    $0x4,%esp
801074eb:	68 00 10 00 00       	push   $0x1000
801074f0:	6a 00                	push   $0x0
801074f2:	ff 75 f4             	push   -0xc(%ebp)
801074f5:	e8 d8 d5 ff ff       	call   80104ad2 <memset>
801074fa:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801074fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107500:	05 00 00 00 80       	add    $0x80000000,%eax
80107505:	83 c8 07             	or     $0x7,%eax
80107508:	89 c2                	mov    %eax,%edx
8010750a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010750d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010750f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107512:	c1 e8 0c             	shr    $0xc,%eax
80107515:	25 ff 03 00 00       	and    $0x3ff,%eax
8010751a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107524:	01 d0                	add    %edx,%eax
}
80107526:	c9                   	leave  
80107527:	c3                   	ret    

80107528 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107528:	55                   	push   %ebp
80107529:	89 e5                	mov    %esp,%ebp
8010752b:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010752e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107531:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107536:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107539:	8b 55 0c             	mov    0xc(%ebp),%edx
8010753c:	8b 45 10             	mov    0x10(%ebp),%eax
8010753f:	01 d0                	add    %edx,%eax
80107541:	83 e8 01             	sub    $0x1,%eax
80107544:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107549:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010754c:	83 ec 04             	sub    $0x4,%esp
8010754f:	6a 01                	push   $0x1
80107551:	ff 75 f4             	push   -0xc(%ebp)
80107554:	ff 75 08             	push   0x8(%ebp)
80107557:	e8 36 ff ff ff       	call   80107492 <walkpgdir>
8010755c:	83 c4 10             	add    $0x10,%esp
8010755f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107562:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107566:	75 07                	jne    8010756f <mappages+0x47>
      return -1;
80107568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010756d:	eb 47                	jmp    801075b6 <mappages+0x8e>
    if(*pte & PTE_P)
8010756f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107572:	8b 00                	mov    (%eax),%eax
80107574:	83 e0 01             	and    $0x1,%eax
80107577:	85 c0                	test   %eax,%eax
80107579:	74 0d                	je     80107588 <mappages+0x60>
      panic("remap");
8010757b:	83 ec 0c             	sub    $0xc,%esp
8010757e:	68 2c aa 10 80       	push   $0x8010aa2c
80107583:	e8 21 90 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107588:	8b 45 18             	mov    0x18(%ebp),%eax
8010758b:	0b 45 14             	or     0x14(%ebp),%eax
8010758e:	83 c8 01             	or     $0x1,%eax
80107591:	89 c2                	mov    %eax,%edx
80107593:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107596:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010759e:	74 10                	je     801075b0 <mappages+0x88>
      break;
    a += PGSIZE;
801075a0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801075a7:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801075ae:	eb 9c                	jmp    8010754c <mappages+0x24>
      break;
801075b0:	90                   	nop
  }
  return 0;
801075b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801075b6:	c9                   	leave  
801075b7:	c3                   	ret    

801075b8 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801075b8:	55                   	push   %ebp
801075b9:	89 e5                	mov    %esp,%ebp
801075bb:	53                   	push   %ebx
801075bc:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801075bf:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801075c6:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
801075cc:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801075d1:	29 d0                	sub    %edx,%eax
801075d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801075d6:	a1 48 6c 19 80       	mov    0x80196c48,%eax
801075db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801075de:	8b 15 48 6c 19 80    	mov    0x80196c48,%edx
801075e4:	a1 50 6c 19 80       	mov    0x80196c50,%eax
801075e9:	01 d0                	add    %edx,%eax
801075eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
801075ee:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801075f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f8:	83 c0 30             	add    $0x30,%eax
801075fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
801075fe:	89 10                	mov    %edx,(%eax)
80107600:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107603:	89 50 04             	mov    %edx,0x4(%eax)
80107606:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107609:	89 50 08             	mov    %edx,0x8(%eax)
8010760c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010760f:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107612:	e8 8a b1 ff ff       	call   801027a1 <kalloc>
80107617:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010761a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010761e:	75 07                	jne    80107627 <setupkvm+0x6f>
    return 0;
80107620:	b8 00 00 00 00       	mov    $0x0,%eax
80107625:	eb 78                	jmp    8010769f <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107627:	83 ec 04             	sub    $0x4,%esp
8010762a:	68 00 10 00 00       	push   $0x1000
8010762f:	6a 00                	push   $0x0
80107631:	ff 75 f0             	push   -0x10(%ebp)
80107634:	e8 99 d4 ff ff       	call   80104ad2 <memset>
80107639:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010763c:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107643:	eb 4e                	jmp    80107693 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107648:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010764b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764e:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107654:	8b 58 08             	mov    0x8(%eax),%ebx
80107657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765a:	8b 40 04             	mov    0x4(%eax),%eax
8010765d:	29 c3                	sub    %eax,%ebx
8010765f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107662:	8b 00                	mov    (%eax),%eax
80107664:	83 ec 0c             	sub    $0xc,%esp
80107667:	51                   	push   %ecx
80107668:	52                   	push   %edx
80107669:	53                   	push   %ebx
8010766a:	50                   	push   %eax
8010766b:	ff 75 f0             	push   -0x10(%ebp)
8010766e:	e8 b5 fe ff ff       	call   80107528 <mappages>
80107673:	83 c4 20             	add    $0x20,%esp
80107676:	85 c0                	test   %eax,%eax
80107678:	79 15                	jns    8010768f <setupkvm+0xd7>
      freevm(pgdir);
8010767a:	83 ec 0c             	sub    $0xc,%esp
8010767d:	ff 75 f0             	push   -0x10(%ebp)
80107680:	e8 f5 04 00 00       	call   80107b7a <freevm>
80107685:	83 c4 10             	add    $0x10,%esp
      return 0;
80107688:	b8 00 00 00 00       	mov    $0x0,%eax
8010768d:	eb 10                	jmp    8010769f <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010768f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107693:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
8010769a:	72 a9                	jb     80107645 <setupkvm+0x8d>
    }
  return pgdir;
8010769c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010769f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801076a2:	c9                   	leave  
801076a3:	c3                   	ret    

801076a4 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801076a4:	55                   	push   %ebp
801076a5:	89 e5                	mov    %esp,%ebp
801076a7:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801076aa:	e8 09 ff ff ff       	call   801075b8 <setupkvm>
801076af:	a3 7c 69 19 80       	mov    %eax,0x8019697c
  switchkvm();
801076b4:	e8 03 00 00 00       	call   801076bc <switchkvm>
}
801076b9:	90                   	nop
801076ba:	c9                   	leave  
801076bb:	c3                   	ret    

801076bc <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801076bc:	55                   	push   %ebp
801076bd:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801076bf:	a1 7c 69 19 80       	mov    0x8019697c,%eax
801076c4:	05 00 00 00 80       	add    $0x80000000,%eax
801076c9:	50                   	push   %eax
801076ca:	e8 61 fa ff ff       	call   80107130 <lcr3>
801076cf:	83 c4 04             	add    $0x4,%esp
}
801076d2:	90                   	nop
801076d3:	c9                   	leave  
801076d4:	c3                   	ret    

801076d5 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801076d5:	55                   	push   %ebp
801076d6:	89 e5                	mov    %esp,%ebp
801076d8:	56                   	push   %esi
801076d9:	53                   	push   %ebx
801076da:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801076dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801076e1:	75 0d                	jne    801076f0 <switchuvm+0x1b>
    panic("switchuvm: no process");
801076e3:	83 ec 0c             	sub    $0xc,%esp
801076e6:	68 32 aa 10 80       	push   $0x8010aa32
801076eb:	e8 b9 8e ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
801076f0:	8b 45 08             	mov    0x8(%ebp),%eax
801076f3:	8b 40 08             	mov    0x8(%eax),%eax
801076f6:	85 c0                	test   %eax,%eax
801076f8:	75 0d                	jne    80107707 <switchuvm+0x32>
    panic("switchuvm: no kstack");
801076fa:	83 ec 0c             	sub    $0xc,%esp
801076fd:	68 48 aa 10 80       	push   $0x8010aa48
80107702:	e8 a2 8e ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107707:	8b 45 08             	mov    0x8(%ebp),%eax
8010770a:	8b 40 04             	mov    0x4(%eax),%eax
8010770d:	85 c0                	test   %eax,%eax
8010770f:	75 0d                	jne    8010771e <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107711:	83 ec 0c             	sub    $0xc,%esp
80107714:	68 5d aa 10 80       	push   $0x8010aa5d
80107719:	e8 8b 8e ff ff       	call   801005a9 <panic>

  pushcli();
8010771e:	e8 a4 d2 ff ff       	call   801049c7 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107723:	e8 91 c2 ff ff       	call   801039b9 <mycpu>
80107728:	89 c3                	mov    %eax,%ebx
8010772a:	e8 8a c2 ff ff       	call   801039b9 <mycpu>
8010772f:	83 c0 08             	add    $0x8,%eax
80107732:	89 c6                	mov    %eax,%esi
80107734:	e8 80 c2 ff ff       	call   801039b9 <mycpu>
80107739:	83 c0 08             	add    $0x8,%eax
8010773c:	c1 e8 10             	shr    $0x10,%eax
8010773f:	88 45 f7             	mov    %al,-0x9(%ebp)
80107742:	e8 72 c2 ff ff       	call   801039b9 <mycpu>
80107747:	83 c0 08             	add    $0x8,%eax
8010774a:	c1 e8 18             	shr    $0x18,%eax
8010774d:	89 c2                	mov    %eax,%edx
8010774f:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107756:	67 00 
80107758:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010775f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107763:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107769:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107770:	83 e0 f0             	and    $0xfffffff0,%eax
80107773:	83 c8 09             	or     $0x9,%eax
80107776:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010777c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107783:	83 c8 10             	or     $0x10,%eax
80107786:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010778c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107793:	83 e0 9f             	and    $0xffffff9f,%eax
80107796:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010779c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801077a3:	83 c8 80             	or     $0xffffff80,%eax
801077a6:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801077ac:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801077b3:	83 e0 f0             	and    $0xfffffff0,%eax
801077b6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801077bc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801077c3:	83 e0 ef             	and    $0xffffffef,%eax
801077c6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801077cc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801077d3:	83 e0 df             	and    $0xffffffdf,%eax
801077d6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801077dc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801077e3:	83 c8 40             	or     $0x40,%eax
801077e6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801077ec:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801077f3:	83 e0 7f             	and    $0x7f,%eax
801077f6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801077fc:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107802:	e8 b2 c1 ff ff       	call   801039b9 <mycpu>
80107807:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010780e:	83 e2 ef             	and    $0xffffffef,%edx
80107811:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107817:	e8 9d c1 ff ff       	call   801039b9 <mycpu>
8010781c:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107822:	8b 45 08             	mov    0x8(%ebp),%eax
80107825:	8b 40 08             	mov    0x8(%eax),%eax
80107828:	89 c3                	mov    %eax,%ebx
8010782a:	e8 8a c1 ff ff       	call   801039b9 <mycpu>
8010782f:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107835:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107838:	e8 7c c1 ff ff       	call   801039b9 <mycpu>
8010783d:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107843:	83 ec 0c             	sub    $0xc,%esp
80107846:	6a 28                	push   $0x28
80107848:	e8 cc f8 ff ff       	call   80107119 <ltr>
8010784d:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107850:	8b 45 08             	mov    0x8(%ebp),%eax
80107853:	8b 40 04             	mov    0x4(%eax),%eax
80107856:	05 00 00 00 80       	add    $0x80000000,%eax
8010785b:	83 ec 0c             	sub    $0xc,%esp
8010785e:	50                   	push   %eax
8010785f:	e8 cc f8 ff ff       	call   80107130 <lcr3>
80107864:	83 c4 10             	add    $0x10,%esp
  popcli();
80107867:	e8 a8 d1 ff ff       	call   80104a14 <popcli>
}
8010786c:	90                   	nop
8010786d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107870:	5b                   	pop    %ebx
80107871:	5e                   	pop    %esi
80107872:	5d                   	pop    %ebp
80107873:	c3                   	ret    

80107874 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107874:	55                   	push   %ebp
80107875:	89 e5                	mov    %esp,%ebp
80107877:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010787a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107881:	76 0d                	jbe    80107890 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107883:	83 ec 0c             	sub    $0xc,%esp
80107886:	68 71 aa 10 80       	push   $0x8010aa71
8010788b:	e8 19 8d ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107890:	e8 0c af ff ff       	call   801027a1 <kalloc>
80107895:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107898:	83 ec 04             	sub    $0x4,%esp
8010789b:	68 00 10 00 00       	push   $0x1000
801078a0:	6a 00                	push   $0x0
801078a2:	ff 75 f4             	push   -0xc(%ebp)
801078a5:	e8 28 d2 ff ff       	call   80104ad2 <memset>
801078aa:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801078ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b0:	05 00 00 00 80       	add    $0x80000000,%eax
801078b5:	83 ec 0c             	sub    $0xc,%esp
801078b8:	6a 06                	push   $0x6
801078ba:	50                   	push   %eax
801078bb:	68 00 10 00 00       	push   $0x1000
801078c0:	6a 00                	push   $0x0
801078c2:	ff 75 08             	push   0x8(%ebp)
801078c5:	e8 5e fc ff ff       	call   80107528 <mappages>
801078ca:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801078cd:	83 ec 04             	sub    $0x4,%esp
801078d0:	ff 75 10             	push   0x10(%ebp)
801078d3:	ff 75 0c             	push   0xc(%ebp)
801078d6:	ff 75 f4             	push   -0xc(%ebp)
801078d9:	e8 b3 d2 ff ff       	call   80104b91 <memmove>
801078de:	83 c4 10             	add    $0x10,%esp
}
801078e1:	90                   	nop
801078e2:	c9                   	leave  
801078e3:	c3                   	ret    

801078e4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801078e4:	55                   	push   %ebp
801078e5:	89 e5                	mov    %esp,%ebp
801078e7:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801078ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801078ed:	25 ff 0f 00 00       	and    $0xfff,%eax
801078f2:	85 c0                	test   %eax,%eax
801078f4:	74 0d                	je     80107903 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801078f6:	83 ec 0c             	sub    $0xc,%esp
801078f9:	68 8c aa 10 80       	push   $0x8010aa8c
801078fe:	e8 a6 8c ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107903:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010790a:	e9 8f 00 00 00       	jmp    8010799e <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010790f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107915:	01 d0                	add    %edx,%eax
80107917:	83 ec 04             	sub    $0x4,%esp
8010791a:	6a 00                	push   $0x0
8010791c:	50                   	push   %eax
8010791d:	ff 75 08             	push   0x8(%ebp)
80107920:	e8 6d fb ff ff       	call   80107492 <walkpgdir>
80107925:	83 c4 10             	add    $0x10,%esp
80107928:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010792b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010792f:	75 0d                	jne    8010793e <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107931:	83 ec 0c             	sub    $0xc,%esp
80107934:	68 af aa 10 80       	push   $0x8010aaaf
80107939:	e8 6b 8c ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010793e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107941:	8b 00                	mov    (%eax),%eax
80107943:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107948:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010794b:	8b 45 18             	mov    0x18(%ebp),%eax
8010794e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107951:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107956:	77 0b                	ja     80107963 <loaduvm+0x7f>
      n = sz - i;
80107958:	8b 45 18             	mov    0x18(%ebp),%eax
8010795b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010795e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107961:	eb 07                	jmp    8010796a <loaduvm+0x86>
    else
      n = PGSIZE;
80107963:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010796a:	8b 55 14             	mov    0x14(%ebp),%edx
8010796d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107970:	01 d0                	add    %edx,%eax
80107972:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107975:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010797b:	ff 75 f0             	push   -0x10(%ebp)
8010797e:	50                   	push   %eax
8010797f:	52                   	push   %edx
80107980:	ff 75 10             	push   0x10(%ebp)
80107983:	e8 4f a5 ff ff       	call   80101ed7 <readi>
80107988:	83 c4 10             	add    $0x10,%esp
8010798b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010798e:	74 07                	je     80107997 <loaduvm+0xb3>
      return -1;
80107990:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107995:	eb 18                	jmp    801079af <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107997:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010799e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a1:	3b 45 18             	cmp    0x18(%ebp),%eax
801079a4:	0f 82 65 ff ff ff    	jb     8010790f <loaduvm+0x2b>
  }
  return 0;
801079aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801079af:	c9                   	leave  
801079b0:	c3                   	ret    

801079b1 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801079b1:	55                   	push   %ebp
801079b2:	89 e5                	mov    %esp,%ebp
801079b4:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801079b7:	8b 45 10             	mov    0x10(%ebp),%eax
801079ba:	85 c0                	test   %eax,%eax
801079bc:	79 0a                	jns    801079c8 <allocuvm+0x17>
    return 0;
801079be:	b8 00 00 00 00       	mov    $0x0,%eax
801079c3:	e9 ec 00 00 00       	jmp    80107ab4 <allocuvm+0x103>
  if(newsz < oldsz)
801079c8:	8b 45 10             	mov    0x10(%ebp),%eax
801079cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
801079ce:	73 08                	jae    801079d8 <allocuvm+0x27>
    return oldsz;
801079d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801079d3:	e9 dc 00 00 00       	jmp    80107ab4 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801079d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801079db:	05 ff 0f 00 00       	add    $0xfff,%eax
801079e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801079e8:	e9 b8 00 00 00       	jmp    80107aa5 <allocuvm+0xf4>
    mem = kalloc();
801079ed:	e8 af ad ff ff       	call   801027a1 <kalloc>
801079f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801079f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079f9:	75 2e                	jne    80107a29 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
801079fb:	83 ec 0c             	sub    $0xc,%esp
801079fe:	68 cd aa 10 80       	push   $0x8010aacd
80107a03:	e8 ec 89 ff ff       	call   801003f4 <cprintf>
80107a08:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107a0b:	83 ec 04             	sub    $0x4,%esp
80107a0e:	ff 75 0c             	push   0xc(%ebp)
80107a11:	ff 75 10             	push   0x10(%ebp)
80107a14:	ff 75 08             	push   0x8(%ebp)
80107a17:	e8 9a 00 00 00       	call   80107ab6 <deallocuvm>
80107a1c:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a1f:	b8 00 00 00 00       	mov    $0x0,%eax
80107a24:	e9 8b 00 00 00       	jmp    80107ab4 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107a29:	83 ec 04             	sub    $0x4,%esp
80107a2c:	68 00 10 00 00       	push   $0x1000
80107a31:	6a 00                	push   $0x0
80107a33:	ff 75 f0             	push   -0x10(%ebp)
80107a36:	e8 97 d0 ff ff       	call   80104ad2 <memset>
80107a3b:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a41:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4a:	83 ec 0c             	sub    $0xc,%esp
80107a4d:	6a 06                	push   $0x6
80107a4f:	52                   	push   %edx
80107a50:	68 00 10 00 00       	push   $0x1000
80107a55:	50                   	push   %eax
80107a56:	ff 75 08             	push   0x8(%ebp)
80107a59:	e8 ca fa ff ff       	call   80107528 <mappages>
80107a5e:	83 c4 20             	add    $0x20,%esp
80107a61:	85 c0                	test   %eax,%eax
80107a63:	79 39                	jns    80107a9e <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107a65:	83 ec 0c             	sub    $0xc,%esp
80107a68:	68 e5 aa 10 80       	push   $0x8010aae5
80107a6d:	e8 82 89 ff ff       	call   801003f4 <cprintf>
80107a72:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107a75:	83 ec 04             	sub    $0x4,%esp
80107a78:	ff 75 0c             	push   0xc(%ebp)
80107a7b:	ff 75 10             	push   0x10(%ebp)
80107a7e:	ff 75 08             	push   0x8(%ebp)
80107a81:	e8 30 00 00 00       	call   80107ab6 <deallocuvm>
80107a86:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107a89:	83 ec 0c             	sub    $0xc,%esp
80107a8c:	ff 75 f0             	push   -0x10(%ebp)
80107a8f:	e8 73 ac ff ff       	call   80102707 <kfree>
80107a94:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a97:	b8 00 00 00 00       	mov    $0x0,%eax
80107a9c:	eb 16                	jmp    80107ab4 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107a9e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa8:	3b 45 10             	cmp    0x10(%ebp),%eax
80107aab:	0f 82 3c ff ff ff    	jb     801079ed <allocuvm+0x3c>
    }
  }
  return newsz;
80107ab1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ab4:	c9                   	leave  
80107ab5:	c3                   	ret    

80107ab6 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ab6:	55                   	push   %ebp
80107ab7:	89 e5                	mov    %esp,%ebp
80107ab9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107abc:	8b 45 10             	mov    0x10(%ebp),%eax
80107abf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ac2:	72 08                	jb     80107acc <deallocuvm+0x16>
    return oldsz;
80107ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ac7:	e9 ac 00 00 00       	jmp    80107b78 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107acc:	8b 45 10             	mov    0x10(%ebp),%eax
80107acf:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ad4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107adc:	e9 88 00 00 00       	jmp    80107b69 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae4:	83 ec 04             	sub    $0x4,%esp
80107ae7:	6a 00                	push   $0x0
80107ae9:	50                   	push   %eax
80107aea:	ff 75 08             	push   0x8(%ebp)
80107aed:	e8 a0 f9 ff ff       	call   80107492 <walkpgdir>
80107af2:	83 c4 10             	add    $0x10,%esp
80107af5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107af8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107afc:	75 16                	jne    80107b14 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	c1 e8 16             	shr    $0x16,%eax
80107b04:	83 c0 01             	add    $0x1,%eax
80107b07:	c1 e0 16             	shl    $0x16,%eax
80107b0a:	2d 00 10 00 00       	sub    $0x1000,%eax
80107b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b12:	eb 4e                	jmp    80107b62 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b17:	8b 00                	mov    (%eax),%eax
80107b19:	83 e0 01             	and    $0x1,%eax
80107b1c:	85 c0                	test   %eax,%eax
80107b1e:	74 42                	je     80107b62 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b23:	8b 00                	mov    (%eax),%eax
80107b25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107b2d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b31:	75 0d                	jne    80107b40 <deallocuvm+0x8a>
        panic("kfree");
80107b33:	83 ec 0c             	sub    $0xc,%esp
80107b36:	68 01 ab 10 80       	push   $0x8010ab01
80107b3b:	e8 69 8a ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b43:	05 00 00 00 80       	add    $0x80000000,%eax
80107b48:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107b4b:	83 ec 0c             	sub    $0xc,%esp
80107b4e:	ff 75 e8             	push   -0x18(%ebp)
80107b51:	e8 b1 ab ff ff       	call   80102707 <kfree>
80107b56:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107b62:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b6f:	0f 82 6c ff ff ff    	jb     80107ae1 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107b75:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107b78:	c9                   	leave  
80107b79:	c3                   	ret    

80107b7a <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107b7a:	55                   	push   %ebp
80107b7b:	89 e5                	mov    %esp,%ebp
80107b7d:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107b80:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b84:	75 0d                	jne    80107b93 <freevm+0x19>
    panic("freevm: no pgdir");
80107b86:	83 ec 0c             	sub    $0xc,%esp
80107b89:	68 07 ab 10 80       	push   $0x8010ab07
80107b8e:	e8 16 8a ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107b93:	83 ec 04             	sub    $0x4,%esp
80107b96:	6a 00                	push   $0x0
80107b98:	68 00 00 00 80       	push   $0x80000000
80107b9d:	ff 75 08             	push   0x8(%ebp)
80107ba0:	e8 11 ff ff ff       	call   80107ab6 <deallocuvm>
80107ba5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107ba8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107baf:	eb 48                	jmp    80107bf9 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80107bbe:	01 d0                	add    %edx,%eax
80107bc0:	8b 00                	mov    (%eax),%eax
80107bc2:	83 e0 01             	and    $0x1,%eax
80107bc5:	85 c0                	test   %eax,%eax
80107bc7:	74 2c                	je     80107bf5 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80107bd6:	01 d0                	add    %edx,%eax
80107bd8:	8b 00                	mov    (%eax),%eax
80107bda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bdf:	05 00 00 00 80       	add    $0x80000000,%eax
80107be4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107be7:	83 ec 0c             	sub    $0xc,%esp
80107bea:	ff 75 f0             	push   -0x10(%ebp)
80107bed:	e8 15 ab ff ff       	call   80102707 <kfree>
80107bf2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107bf5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107bf9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107c00:	76 af                	jbe    80107bb1 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107c02:	83 ec 0c             	sub    $0xc,%esp
80107c05:	ff 75 08             	push   0x8(%ebp)
80107c08:	e8 fa aa ff ff       	call   80102707 <kfree>
80107c0d:	83 c4 10             	add    $0x10,%esp
}
80107c10:	90                   	nop
80107c11:	c9                   	leave  
80107c12:	c3                   	ret    

80107c13 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107c13:	55                   	push   %ebp
80107c14:	89 e5                	mov    %esp,%ebp
80107c16:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107c19:	83 ec 04             	sub    $0x4,%esp
80107c1c:	6a 00                	push   $0x0
80107c1e:	ff 75 0c             	push   0xc(%ebp)
80107c21:	ff 75 08             	push   0x8(%ebp)
80107c24:	e8 69 f8 ff ff       	call   80107492 <walkpgdir>
80107c29:	83 c4 10             	add    $0x10,%esp
80107c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c33:	75 0d                	jne    80107c42 <clearpteu+0x2f>
    panic("clearpteu");
80107c35:	83 ec 0c             	sub    $0xc,%esp
80107c38:	68 18 ab 10 80       	push   $0x8010ab18
80107c3d:	e8 67 89 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c45:	8b 00                	mov    (%eax),%eax
80107c47:	83 e0 fb             	and    $0xfffffffb,%eax
80107c4a:	89 c2                	mov    %eax,%edx
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	89 10                	mov    %edx,(%eax)
}
80107c51:	90                   	nop
80107c52:	c9                   	leave  
80107c53:	c3                   	ret    

80107c54 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107c54:	55                   	push   %ebp
80107c55:	89 e5                	mov    %esp,%ebp
80107c57:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107c5a:	e8 59 f9 ff ff       	call   801075b8 <setupkvm>
80107c5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c62:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c66:	75 0a                	jne    80107c72 <copyuvm+0x1e>
    return 0;
80107c68:	b8 00 00 00 00       	mov    $0x0,%eax
80107c6d:	e9 d7 00 00 00       	jmp    80107d49 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107c72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c79:	e9 a3 00 00 00       	jmp    80107d21 <copyuvm+0xcd>

    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c81:	83 ec 04             	sub    $0x4,%esp
80107c84:	6a 00                	push   $0x0
80107c86:	50                   	push   %eax
80107c87:	ff 75 08             	push   0x8(%ebp)
80107c8a:	e8 03 f8 ff ff       	call   80107492 <walkpgdir>
80107c8f:	83 c4 10             	add    $0x10,%esp
80107c92:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c95:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c99:	74 7b                	je     80107d16 <copyuvm+0xc2>
      continue; //존재하지 않는 페이지는 건너뜀
    if(!(*pte & PTE_P))
80107c9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c9e:	8b 00                	mov    (%eax),%eax
80107ca0:	83 e0 01             	and    $0x1,%eax
80107ca3:	85 c0                	test   %eax,%eax
80107ca5:	74 72                	je     80107d19 <copyuvm+0xc5>
      continue; //매핑되지 않은 페이지는 건너뜀

    pa = PTE_ADDR(*pte);
80107ca7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107caa:	8b 00                	mov    (%eax),%eax
80107cac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cb1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107cb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cb7:	8b 00                	mov    (%eax),%eax
80107cb9:	25 ff 0f 00 00       	and    $0xfff,%eax
80107cbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107cc1:	e8 db aa ff ff       	call   801027a1 <kalloc>
80107cc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107cc9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107ccd:	74 63                	je     80107d32 <copyuvm+0xde>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107ccf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107cd2:	05 00 00 00 80       	add    $0x80000000,%eax
80107cd7:	83 ec 04             	sub    $0x4,%esp
80107cda:	68 00 10 00 00       	push   $0x1000
80107cdf:	50                   	push   %eax
80107ce0:	ff 75 e0             	push   -0x20(%ebp)
80107ce3:	e8 a9 ce ff ff       	call   80104b91 <memmove>
80107ce8:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107ceb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107cf1:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfa:	83 ec 0c             	sub    $0xc,%esp
80107cfd:	52                   	push   %edx
80107cfe:	51                   	push   %ecx
80107cff:	68 00 10 00 00       	push   $0x1000
80107d04:	50                   	push   %eax
80107d05:	ff 75 f0             	push   -0x10(%ebp)
80107d08:	e8 1b f8 ff ff       	call   80107528 <mappages>
80107d0d:	83 c4 20             	add    $0x20,%esp
80107d10:	85 c0                	test   %eax,%eax
80107d12:	78 21                	js     80107d35 <copyuvm+0xe1>
80107d14:	eb 04                	jmp    80107d1a <copyuvm+0xc6>
      continue; //존재하지 않는 페이지는 건너뜀
80107d16:	90                   	nop
80107d17:	eb 01                	jmp    80107d1a <copyuvm+0xc6>
      continue; //매핑되지 않은 페이지는 건너뜀
80107d19:	90                   	nop
  for(i = 0; i < sz; i += PGSIZE){
80107d1a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d24:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d27:	0f 82 51 ff ff ff    	jb     80107c7e <copyuvm+0x2a>
      goto bad;
  }
  
  return d;
80107d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d30:	eb 17                	jmp    80107d49 <copyuvm+0xf5>
      goto bad;
80107d32:	90                   	nop
80107d33:	eb 01                	jmp    80107d36 <copyuvm+0xe2>
      goto bad;
80107d35:	90                   	nop

bad:
  freevm(d);
80107d36:	83 ec 0c             	sub    $0xc,%esp
80107d39:	ff 75 f0             	push   -0x10(%ebp)
80107d3c:	e8 39 fe ff ff       	call   80107b7a <freevm>
80107d41:	83 c4 10             	add    $0x10,%esp
  return 0;
80107d44:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d49:	c9                   	leave  
80107d4a:	c3                   	ret    

80107d4b <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107d4b:	55                   	push   %ebp
80107d4c:	89 e5                	mov    %esp,%ebp
80107d4e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107d51:	83 ec 04             	sub    $0x4,%esp
80107d54:	6a 00                	push   $0x0
80107d56:	ff 75 0c             	push   0xc(%ebp)
80107d59:	ff 75 08             	push   0x8(%ebp)
80107d5c:	e8 31 f7 ff ff       	call   80107492 <walkpgdir>
80107d61:	83 c4 10             	add    $0x10,%esp
80107d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6a:	8b 00                	mov    (%eax),%eax
80107d6c:	83 e0 01             	and    $0x1,%eax
80107d6f:	85 c0                	test   %eax,%eax
80107d71:	75 07                	jne    80107d7a <uva2ka+0x2f>
    return 0;
80107d73:	b8 00 00 00 00       	mov    $0x0,%eax
80107d78:	eb 22                	jmp    80107d9c <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7d:	8b 00                	mov    (%eax),%eax
80107d7f:	83 e0 04             	and    $0x4,%eax
80107d82:	85 c0                	test   %eax,%eax
80107d84:	75 07                	jne    80107d8d <uva2ka+0x42>
    return 0;
80107d86:	b8 00 00 00 00       	mov    $0x0,%eax
80107d8b:	eb 0f                	jmp    80107d9c <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d90:	8b 00                	mov    (%eax),%eax
80107d92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d97:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107d9c:	c9                   	leave  
80107d9d:	c3                   	ret    

80107d9e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107d9e:	55                   	push   %ebp
80107d9f:	89 e5                	mov    %esp,%ebp
80107da1:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107da4:	8b 45 10             	mov    0x10(%ebp),%eax
80107da7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107daa:	eb 7f                	jmp    80107e2b <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107dac:	8b 45 0c             	mov    0xc(%ebp),%eax
80107daf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107db4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107db7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dba:	83 ec 08             	sub    $0x8,%esp
80107dbd:	50                   	push   %eax
80107dbe:	ff 75 08             	push   0x8(%ebp)
80107dc1:	e8 85 ff ff ff       	call   80107d4b <uva2ka>
80107dc6:	83 c4 10             	add    $0x10,%esp
80107dc9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0){
80107dcc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107dd0:	75 07                	jne    80107dd9 <copyout+0x3b>
      return -1;
80107dd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107dd7:	eb 61                	jmp    80107e3a <copyout+0x9c>
    }
    n = PGSIZE - (va - va0);
80107dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ddc:	2b 45 0c             	sub    0xc(%ebp),%eax
80107ddf:	05 00 10 00 00       	add    $0x1000,%eax
80107de4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dea:	3b 45 14             	cmp    0x14(%ebp),%eax
80107ded:	76 06                	jbe    80107df5 <copyout+0x57>
      n = len;
80107def:	8b 45 14             	mov    0x14(%ebp),%eax
80107df2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107df8:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107dfb:	89 c2                	mov    %eax,%edx
80107dfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e00:	01 d0                	add    %edx,%eax
80107e02:	83 ec 04             	sub    $0x4,%esp
80107e05:	ff 75 f0             	push   -0x10(%ebp)
80107e08:	ff 75 f4             	push   -0xc(%ebp)
80107e0b:	50                   	push   %eax
80107e0c:	e8 80 cd ff ff       	call   80104b91 <memmove>
80107e11:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e17:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e1d:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107e20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e23:	05 00 10 00 00       	add    $0x1000,%eax
80107e28:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107e2b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107e2f:	0f 85 77 ff ff ff    	jne    80107dac <copyout+0xe>
  }
  return 0;
80107e35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e3a:	c9                   	leave  
80107e3b:	c3                   	ret    

80107e3c <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107e3c:	55                   	push   %ebp
80107e3d:	89 e5                	mov    %esp,%ebp
80107e3f:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107e42:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107e49:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e4c:	8b 40 08             	mov    0x8(%eax),%eax
80107e4f:	05 00 00 00 80       	add    $0x80000000,%eax
80107e54:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107e57:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e61:	8b 40 24             	mov    0x24(%eax),%eax
80107e64:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107e69:	c7 05 40 6c 19 80 00 	movl   $0x0,0x80196c40
80107e70:	00 00 00 

  while(i<madt->len){
80107e73:	90                   	nop
80107e74:	e9 bd 00 00 00       	jmp    80107f36 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107e79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e7f:	01 d0                	add    %edx,%eax
80107e81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e87:	0f b6 00             	movzbl (%eax),%eax
80107e8a:	0f b6 c0             	movzbl %al,%eax
80107e8d:	83 f8 05             	cmp    $0x5,%eax
80107e90:	0f 87 a0 00 00 00    	ja     80107f36 <mpinit_uefi+0xfa>
80107e96:	8b 04 85 24 ab 10 80 	mov    -0x7fef54dc(,%eax,4),%eax
80107e9d:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ea2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107ea5:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107eaa:	83 f8 03             	cmp    $0x3,%eax
80107ead:	7f 28                	jg     80107ed7 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107eaf:	8b 15 40 6c 19 80    	mov    0x80196c40,%edx
80107eb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107eb8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107ebc:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107ec2:	81 c2 80 69 19 80    	add    $0x80196980,%edx
80107ec8:	88 02                	mov    %al,(%edx)
          ncpu++;
80107eca:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107ecf:	83 c0 01             	add    $0x1,%eax
80107ed2:	a3 40 6c 19 80       	mov    %eax,0x80196c40
        }
        i += lapic_entry->record_len;
80107ed7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107eda:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ede:	0f b6 c0             	movzbl %al,%eax
80107ee1:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ee4:	eb 50                	jmp    80107f36 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ee9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107eec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107eef:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107ef3:	a2 44 6c 19 80       	mov    %al,0x80196c44
        i += ioapic->record_len;
80107ef8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107efb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107eff:	0f b6 c0             	movzbl %al,%eax
80107f02:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f05:	eb 2f                	jmp    80107f36 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107f0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f10:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f14:	0f b6 c0             	movzbl %al,%eax
80107f17:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f1a:	eb 1a                	jmp    80107f36 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f25:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f29:	0f b6 c0             	movzbl %al,%eax
80107f2c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f2f:	eb 05                	jmp    80107f36 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107f31:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107f35:	90                   	nop
  while(i<madt->len){
80107f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f39:	8b 40 04             	mov    0x4(%eax),%eax
80107f3c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107f3f:	0f 82 34 ff ff ff    	jb     80107e79 <mpinit_uefi+0x3d>
    }
  }

}
80107f45:	90                   	nop
80107f46:	90                   	nop
80107f47:	c9                   	leave  
80107f48:	c3                   	ret    

80107f49 <inb>:
{
80107f49:	55                   	push   %ebp
80107f4a:	89 e5                	mov    %esp,%ebp
80107f4c:	83 ec 14             	sub    $0x14,%esp
80107f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80107f52:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107f56:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107f5a:	89 c2                	mov    %eax,%edx
80107f5c:	ec                   	in     (%dx),%al
80107f5d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107f60:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107f64:	c9                   	leave  
80107f65:	c3                   	ret    

80107f66 <outb>:
{
80107f66:	55                   	push   %ebp
80107f67:	89 e5                	mov    %esp,%ebp
80107f69:	83 ec 08             	sub    $0x8,%esp
80107f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80107f6f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f72:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107f76:	89 d0                	mov    %edx,%eax
80107f78:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107f7b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107f7f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107f83:	ee                   	out    %al,(%dx)
}
80107f84:	90                   	nop
80107f85:	c9                   	leave  
80107f86:	c3                   	ret    

80107f87 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107f87:	55                   	push   %ebp
80107f88:	89 e5                	mov    %esp,%ebp
80107f8a:	83 ec 28             	sub    $0x28,%esp
80107f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80107f90:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107f93:	6a 00                	push   $0x0
80107f95:	68 fa 03 00 00       	push   $0x3fa
80107f9a:	e8 c7 ff ff ff       	call   80107f66 <outb>
80107f9f:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107fa2:	68 80 00 00 00       	push   $0x80
80107fa7:	68 fb 03 00 00       	push   $0x3fb
80107fac:	e8 b5 ff ff ff       	call   80107f66 <outb>
80107fb1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107fb4:	6a 0c                	push   $0xc
80107fb6:	68 f8 03 00 00       	push   $0x3f8
80107fbb:	e8 a6 ff ff ff       	call   80107f66 <outb>
80107fc0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107fc3:	6a 00                	push   $0x0
80107fc5:	68 f9 03 00 00       	push   $0x3f9
80107fca:	e8 97 ff ff ff       	call   80107f66 <outb>
80107fcf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107fd2:	6a 03                	push   $0x3
80107fd4:	68 fb 03 00 00       	push   $0x3fb
80107fd9:	e8 88 ff ff ff       	call   80107f66 <outb>
80107fde:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107fe1:	6a 00                	push   $0x0
80107fe3:	68 fc 03 00 00       	push   $0x3fc
80107fe8:	e8 79 ff ff ff       	call   80107f66 <outb>
80107fed:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107ff0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ff7:	eb 11                	jmp    8010800a <uart_debug+0x83>
80107ff9:	83 ec 0c             	sub    $0xc,%esp
80107ffc:	6a 0a                	push   $0xa
80107ffe:	e8 35 ab ff ff       	call   80102b38 <microdelay>
80108003:	83 c4 10             	add    $0x10,%esp
80108006:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010800a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010800e:	7f 1a                	jg     8010802a <uart_debug+0xa3>
80108010:	83 ec 0c             	sub    $0xc,%esp
80108013:	68 fd 03 00 00       	push   $0x3fd
80108018:	e8 2c ff ff ff       	call   80107f49 <inb>
8010801d:	83 c4 10             	add    $0x10,%esp
80108020:	0f b6 c0             	movzbl %al,%eax
80108023:	83 e0 20             	and    $0x20,%eax
80108026:	85 c0                	test   %eax,%eax
80108028:	74 cf                	je     80107ff9 <uart_debug+0x72>
  outb(COM1+0, p);
8010802a:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010802e:	0f b6 c0             	movzbl %al,%eax
80108031:	83 ec 08             	sub    $0x8,%esp
80108034:	50                   	push   %eax
80108035:	68 f8 03 00 00       	push   $0x3f8
8010803a:	e8 27 ff ff ff       	call   80107f66 <outb>
8010803f:	83 c4 10             	add    $0x10,%esp
}
80108042:	90                   	nop
80108043:	c9                   	leave  
80108044:	c3                   	ret    

80108045 <uart_debugs>:

void uart_debugs(char *p){
80108045:	55                   	push   %ebp
80108046:	89 e5                	mov    %esp,%ebp
80108048:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010804b:	eb 1b                	jmp    80108068 <uart_debugs+0x23>
    uart_debug(*p++);
8010804d:	8b 45 08             	mov    0x8(%ebp),%eax
80108050:	8d 50 01             	lea    0x1(%eax),%edx
80108053:	89 55 08             	mov    %edx,0x8(%ebp)
80108056:	0f b6 00             	movzbl (%eax),%eax
80108059:	0f be c0             	movsbl %al,%eax
8010805c:	83 ec 0c             	sub    $0xc,%esp
8010805f:	50                   	push   %eax
80108060:	e8 22 ff ff ff       	call   80107f87 <uart_debug>
80108065:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108068:	8b 45 08             	mov    0x8(%ebp),%eax
8010806b:	0f b6 00             	movzbl (%eax),%eax
8010806e:	84 c0                	test   %al,%al
80108070:	75 db                	jne    8010804d <uart_debugs+0x8>
  }
}
80108072:	90                   	nop
80108073:	90                   	nop
80108074:	c9                   	leave  
80108075:	c3                   	ret    

80108076 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108076:	55                   	push   %ebp
80108077:	89 e5                	mov    %esp,%ebp
80108079:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010807c:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108083:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108086:	8b 50 14             	mov    0x14(%eax),%edx
80108089:	8b 40 10             	mov    0x10(%eax),%eax
8010808c:	a3 48 6c 19 80       	mov    %eax,0x80196c48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108091:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108094:	8b 50 1c             	mov    0x1c(%eax),%edx
80108097:	8b 40 18             	mov    0x18(%eax),%eax
8010809a:	a3 50 6c 19 80       	mov    %eax,0x80196c50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010809f:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
801080a5:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801080aa:	29 d0                	sub    %edx,%eax
801080ac:	a3 4c 6c 19 80       	mov    %eax,0x80196c4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801080b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080b4:	8b 50 24             	mov    0x24(%eax),%edx
801080b7:	8b 40 20             	mov    0x20(%eax),%eax
801080ba:	a3 54 6c 19 80       	mov    %eax,0x80196c54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801080bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080c2:	8b 50 2c             	mov    0x2c(%eax),%edx
801080c5:	8b 40 28             	mov    0x28(%eax),%eax
801080c8:	a3 58 6c 19 80       	mov    %eax,0x80196c58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801080cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080d0:	8b 50 34             	mov    0x34(%eax),%edx
801080d3:	8b 40 30             	mov    0x30(%eax),%eax
801080d6:	a3 5c 6c 19 80       	mov    %eax,0x80196c5c
}
801080db:	90                   	nop
801080dc:	c9                   	leave  
801080dd:	c3                   	ret    

801080de <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801080de:	55                   	push   %ebp
801080df:	89 e5                	mov    %esp,%ebp
801080e1:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801080e4:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
801080ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801080ed:	0f af d0             	imul   %eax,%edx
801080f0:	8b 45 08             	mov    0x8(%ebp),%eax
801080f3:	01 d0                	add    %edx,%eax
801080f5:	c1 e0 02             	shl    $0x2,%eax
801080f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801080fb:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80108101:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108104:	01 d0                	add    %edx,%eax
80108106:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108109:	8b 45 10             	mov    0x10(%ebp),%eax
8010810c:	0f b6 10             	movzbl (%eax),%edx
8010810f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108112:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108114:	8b 45 10             	mov    0x10(%ebp),%eax
80108117:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010811b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010811e:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108121:	8b 45 10             	mov    0x10(%ebp),%eax
80108124:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108128:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010812b:	88 50 02             	mov    %dl,0x2(%eax)
}
8010812e:	90                   	nop
8010812f:	c9                   	leave  
80108130:	c3                   	ret    

80108131 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108131:	55                   	push   %ebp
80108132:	89 e5                	mov    %esp,%ebp
80108134:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108137:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
8010813d:	8b 45 08             	mov    0x8(%ebp),%eax
80108140:	0f af c2             	imul   %edx,%eax
80108143:	c1 e0 02             	shl    $0x2,%eax
80108146:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108149:	a1 50 6c 19 80       	mov    0x80196c50,%eax
8010814e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108151:	29 d0                	sub    %edx,%eax
80108153:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80108159:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010815c:	01 ca                	add    %ecx,%edx
8010815e:	89 d1                	mov    %edx,%ecx
80108160:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80108166:	83 ec 04             	sub    $0x4,%esp
80108169:	50                   	push   %eax
8010816a:	51                   	push   %ecx
8010816b:	52                   	push   %edx
8010816c:	e8 20 ca ff ff       	call   80104b91 <memmove>
80108171:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108177:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
8010817d:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80108183:	01 ca                	add    %ecx,%edx
80108185:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108188:	29 ca                	sub    %ecx,%edx
8010818a:	83 ec 04             	sub    $0x4,%esp
8010818d:	50                   	push   %eax
8010818e:	6a 00                	push   $0x0
80108190:	52                   	push   %edx
80108191:	e8 3c c9 ff ff       	call   80104ad2 <memset>
80108196:	83 c4 10             	add    $0x10,%esp
}
80108199:	90                   	nop
8010819a:	c9                   	leave  
8010819b:	c3                   	ret    

8010819c <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010819c:	55                   	push   %ebp
8010819d:	89 e5                	mov    %esp,%ebp
8010819f:	53                   	push   %ebx
801081a0:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801081a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081aa:	e9 b1 00 00 00       	jmp    80108260 <font_render+0xc4>
    for(int j=14;j>-1;j--){
801081af:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801081b6:	e9 97 00 00 00       	jmp    80108252 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801081bb:	8b 45 10             	mov    0x10(%ebp),%eax
801081be:	83 e8 20             	sub    $0x20,%eax
801081c1:	6b d0 1e             	imul   $0x1e,%eax,%edx
801081c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c7:	01 d0                	add    %edx,%eax
801081c9:	0f b7 84 00 40 ab 10 	movzwl -0x7fef54c0(%eax,%eax,1),%eax
801081d0:	80 
801081d1:	0f b7 d0             	movzwl %ax,%edx
801081d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d7:	bb 01 00 00 00       	mov    $0x1,%ebx
801081dc:	89 c1                	mov    %eax,%ecx
801081de:	d3 e3                	shl    %cl,%ebx
801081e0:	89 d8                	mov    %ebx,%eax
801081e2:	21 d0                	and    %edx,%eax
801081e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801081e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ea:	ba 01 00 00 00       	mov    $0x1,%edx
801081ef:	89 c1                	mov    %eax,%ecx
801081f1:	d3 e2                	shl    %cl,%edx
801081f3:	89 d0                	mov    %edx,%eax
801081f5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801081f8:	75 2b                	jne    80108225 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801081fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801081fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108200:	01 c2                	add    %eax,%edx
80108202:	b8 0e 00 00 00       	mov    $0xe,%eax
80108207:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010820a:	89 c1                	mov    %eax,%ecx
8010820c:	8b 45 08             	mov    0x8(%ebp),%eax
8010820f:	01 c8                	add    %ecx,%eax
80108211:	83 ec 04             	sub    $0x4,%esp
80108214:	68 e0 f4 10 80       	push   $0x8010f4e0
80108219:	52                   	push   %edx
8010821a:	50                   	push   %eax
8010821b:	e8 be fe ff ff       	call   801080de <graphic_draw_pixel>
80108220:	83 c4 10             	add    $0x10,%esp
80108223:	eb 29                	jmp    8010824e <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108225:	8b 55 0c             	mov    0xc(%ebp),%edx
80108228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822b:	01 c2                	add    %eax,%edx
8010822d:	b8 0e 00 00 00       	mov    $0xe,%eax
80108232:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108235:	89 c1                	mov    %eax,%ecx
80108237:	8b 45 08             	mov    0x8(%ebp),%eax
8010823a:	01 c8                	add    %ecx,%eax
8010823c:	83 ec 04             	sub    $0x4,%esp
8010823f:	68 60 6c 19 80       	push   $0x80196c60
80108244:	52                   	push   %edx
80108245:	50                   	push   %eax
80108246:	e8 93 fe ff ff       	call   801080de <graphic_draw_pixel>
8010824b:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010824e:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108252:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108256:	0f 89 5f ff ff ff    	jns    801081bb <font_render+0x1f>
  for(int i=0;i<30;i++){
8010825c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108260:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108264:	0f 8e 45 ff ff ff    	jle    801081af <font_render+0x13>
      }
    }
  }
}
8010826a:	90                   	nop
8010826b:	90                   	nop
8010826c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010826f:	c9                   	leave  
80108270:	c3                   	ret    

80108271 <font_render_string>:

void font_render_string(char *string,int row){
80108271:	55                   	push   %ebp
80108272:	89 e5                	mov    %esp,%ebp
80108274:	53                   	push   %ebx
80108275:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108278:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010827f:	eb 33                	jmp    801082b4 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108281:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108284:	8b 45 08             	mov    0x8(%ebp),%eax
80108287:	01 d0                	add    %edx,%eax
80108289:	0f b6 00             	movzbl (%eax),%eax
8010828c:	0f be c8             	movsbl %al,%ecx
8010828f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108292:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108295:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108298:	89 d8                	mov    %ebx,%eax
8010829a:	c1 e0 04             	shl    $0x4,%eax
8010829d:	29 d8                	sub    %ebx,%eax
8010829f:	83 c0 02             	add    $0x2,%eax
801082a2:	83 ec 04             	sub    $0x4,%esp
801082a5:	51                   	push   %ecx
801082a6:	52                   	push   %edx
801082a7:	50                   	push   %eax
801082a8:	e8 ef fe ff ff       	call   8010819c <font_render>
801082ad:	83 c4 10             	add    $0x10,%esp
    i++;
801082b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801082b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801082b7:	8b 45 08             	mov    0x8(%ebp),%eax
801082ba:	01 d0                	add    %edx,%eax
801082bc:	0f b6 00             	movzbl (%eax),%eax
801082bf:	84 c0                	test   %al,%al
801082c1:	74 06                	je     801082c9 <font_render_string+0x58>
801082c3:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801082c7:	7e b8                	jle    80108281 <font_render_string+0x10>
  }
}
801082c9:	90                   	nop
801082ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801082cd:	c9                   	leave  
801082ce:	c3                   	ret    

801082cf <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801082cf:	55                   	push   %ebp
801082d0:	89 e5                	mov    %esp,%ebp
801082d2:	53                   	push   %ebx
801082d3:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801082d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082dd:	eb 6b                	jmp    8010834a <pci_init+0x7b>
    for(int j=0;j<32;j++){
801082df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801082e6:	eb 58                	jmp    80108340 <pci_init+0x71>
      for(int k=0;k<8;k++){
801082e8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801082ef:	eb 45                	jmp    80108336 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801082f1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801082f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fa:	83 ec 0c             	sub    $0xc,%esp
801082fd:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108300:	53                   	push   %ebx
80108301:	6a 00                	push   $0x0
80108303:	51                   	push   %ecx
80108304:	52                   	push   %edx
80108305:	50                   	push   %eax
80108306:	e8 b0 00 00 00       	call   801083bb <pci_access_config>
8010830b:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010830e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108311:	0f b7 c0             	movzwl %ax,%eax
80108314:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108319:	74 17                	je     80108332 <pci_init+0x63>
        pci_init_device(i,j,k);
8010831b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010831e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108324:	83 ec 04             	sub    $0x4,%esp
80108327:	51                   	push   %ecx
80108328:	52                   	push   %edx
80108329:	50                   	push   %eax
8010832a:	e8 37 01 00 00       	call   80108466 <pci_init_device>
8010832f:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108332:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108336:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010833a:	7e b5                	jle    801082f1 <pci_init+0x22>
    for(int j=0;j<32;j++){
8010833c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108340:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108344:	7e a2                	jle    801082e8 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108346:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010834a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108351:	7e 8c                	jle    801082df <pci_init+0x10>
      }
      }
    }
  }
}
80108353:	90                   	nop
80108354:	90                   	nop
80108355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108358:	c9                   	leave  
80108359:	c3                   	ret    

8010835a <pci_write_config>:

void pci_write_config(uint config){
8010835a:	55                   	push   %ebp
8010835b:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010835d:	8b 45 08             	mov    0x8(%ebp),%eax
80108360:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108365:	89 c0                	mov    %eax,%eax
80108367:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108368:	90                   	nop
80108369:	5d                   	pop    %ebp
8010836a:	c3                   	ret    

8010836b <pci_write_data>:

void pci_write_data(uint config){
8010836b:	55                   	push   %ebp
8010836c:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010836e:	8b 45 08             	mov    0x8(%ebp),%eax
80108371:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108376:	89 c0                	mov    %eax,%eax
80108378:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108379:	90                   	nop
8010837a:	5d                   	pop    %ebp
8010837b:	c3                   	ret    

8010837c <pci_read_config>:
uint pci_read_config(){
8010837c:	55                   	push   %ebp
8010837d:	89 e5                	mov    %esp,%ebp
8010837f:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108382:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108387:	ed                   	in     (%dx),%eax
80108388:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
8010838b:	83 ec 0c             	sub    $0xc,%esp
8010838e:	68 c8 00 00 00       	push   $0xc8
80108393:	e8 a0 a7 ff ff       	call   80102b38 <microdelay>
80108398:	83 c4 10             	add    $0x10,%esp
  return data;
8010839b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010839e:	c9                   	leave  
8010839f:	c3                   	ret    

801083a0 <pci_test>:


void pci_test(){
801083a0:	55                   	push   %ebp
801083a1:	89 e5                	mov    %esp,%ebp
801083a3:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801083a6:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801083ad:	ff 75 fc             	push   -0x4(%ebp)
801083b0:	e8 a5 ff ff ff       	call   8010835a <pci_write_config>
801083b5:	83 c4 04             	add    $0x4,%esp
}
801083b8:	90                   	nop
801083b9:	c9                   	leave  
801083ba:	c3                   	ret    

801083bb <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801083bb:	55                   	push   %ebp
801083bc:	89 e5                	mov    %esp,%ebp
801083be:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083c1:	8b 45 08             	mov    0x8(%ebp),%eax
801083c4:	c1 e0 10             	shl    $0x10,%eax
801083c7:	25 00 00 ff 00       	and    $0xff0000,%eax
801083cc:	89 c2                	mov    %eax,%edx
801083ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d1:	c1 e0 0b             	shl    $0xb,%eax
801083d4:	0f b7 c0             	movzwl %ax,%eax
801083d7:	09 c2                	or     %eax,%edx
801083d9:	8b 45 10             	mov    0x10(%ebp),%eax
801083dc:	c1 e0 08             	shl    $0x8,%eax
801083df:	25 00 07 00 00       	and    $0x700,%eax
801083e4:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801083e6:	8b 45 14             	mov    0x14(%ebp),%eax
801083e9:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083ee:	09 d0                	or     %edx,%eax
801083f0:	0d 00 00 00 80       	or     $0x80000000,%eax
801083f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801083f8:	ff 75 f4             	push   -0xc(%ebp)
801083fb:	e8 5a ff ff ff       	call   8010835a <pci_write_config>
80108400:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108403:	e8 74 ff ff ff       	call   8010837c <pci_read_config>
80108408:	8b 55 18             	mov    0x18(%ebp),%edx
8010840b:	89 02                	mov    %eax,(%edx)
}
8010840d:	90                   	nop
8010840e:	c9                   	leave  
8010840f:	c3                   	ret    

80108410 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108410:	55                   	push   %ebp
80108411:	89 e5                	mov    %esp,%ebp
80108413:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108416:	8b 45 08             	mov    0x8(%ebp),%eax
80108419:	c1 e0 10             	shl    $0x10,%eax
8010841c:	25 00 00 ff 00       	and    $0xff0000,%eax
80108421:	89 c2                	mov    %eax,%edx
80108423:	8b 45 0c             	mov    0xc(%ebp),%eax
80108426:	c1 e0 0b             	shl    $0xb,%eax
80108429:	0f b7 c0             	movzwl %ax,%eax
8010842c:	09 c2                	or     %eax,%edx
8010842e:	8b 45 10             	mov    0x10(%ebp),%eax
80108431:	c1 e0 08             	shl    $0x8,%eax
80108434:	25 00 07 00 00       	and    $0x700,%eax
80108439:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010843b:	8b 45 14             	mov    0x14(%ebp),%eax
8010843e:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108443:	09 d0                	or     %edx,%eax
80108445:	0d 00 00 00 80       	or     $0x80000000,%eax
8010844a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010844d:	ff 75 fc             	push   -0x4(%ebp)
80108450:	e8 05 ff ff ff       	call   8010835a <pci_write_config>
80108455:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108458:	ff 75 18             	push   0x18(%ebp)
8010845b:	e8 0b ff ff ff       	call   8010836b <pci_write_data>
80108460:	83 c4 04             	add    $0x4,%esp
}
80108463:	90                   	nop
80108464:	c9                   	leave  
80108465:	c3                   	ret    

80108466 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108466:	55                   	push   %ebp
80108467:	89 e5                	mov    %esp,%ebp
80108469:	53                   	push   %ebx
8010846a:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010846d:	8b 45 08             	mov    0x8(%ebp),%eax
80108470:	a2 64 6c 19 80       	mov    %al,0x80196c64
  dev.device_num = device_num;
80108475:	8b 45 0c             	mov    0xc(%ebp),%eax
80108478:	a2 65 6c 19 80       	mov    %al,0x80196c65
  dev.function_num = function_num;
8010847d:	8b 45 10             	mov    0x10(%ebp),%eax
80108480:	a2 66 6c 19 80       	mov    %al,0x80196c66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108485:	ff 75 10             	push   0x10(%ebp)
80108488:	ff 75 0c             	push   0xc(%ebp)
8010848b:	ff 75 08             	push   0x8(%ebp)
8010848e:	68 84 c1 10 80       	push   $0x8010c184
80108493:	e8 5c 7f ff ff       	call   801003f4 <cprintf>
80108498:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
8010849b:	83 ec 0c             	sub    $0xc,%esp
8010849e:	8d 45 ec             	lea    -0x14(%ebp),%eax
801084a1:	50                   	push   %eax
801084a2:	6a 00                	push   $0x0
801084a4:	ff 75 10             	push   0x10(%ebp)
801084a7:	ff 75 0c             	push   0xc(%ebp)
801084aa:	ff 75 08             	push   0x8(%ebp)
801084ad:	e8 09 ff ff ff       	call   801083bb <pci_access_config>
801084b2:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801084b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084b8:	c1 e8 10             	shr    $0x10,%eax
801084bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801084be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084c1:	25 ff ff 00 00       	and    $0xffff,%eax
801084c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801084c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cc:	a3 68 6c 19 80       	mov    %eax,0x80196c68
  dev.vendor_id = vendor_id;
801084d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084d4:	a3 6c 6c 19 80       	mov    %eax,0x80196c6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801084d9:	83 ec 04             	sub    $0x4,%esp
801084dc:	ff 75 f0             	push   -0x10(%ebp)
801084df:	ff 75 f4             	push   -0xc(%ebp)
801084e2:	68 b8 c1 10 80       	push   $0x8010c1b8
801084e7:	e8 08 7f ff ff       	call   801003f4 <cprintf>
801084ec:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801084ef:	83 ec 0c             	sub    $0xc,%esp
801084f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801084f5:	50                   	push   %eax
801084f6:	6a 08                	push   $0x8
801084f8:	ff 75 10             	push   0x10(%ebp)
801084fb:	ff 75 0c             	push   0xc(%ebp)
801084fe:	ff 75 08             	push   0x8(%ebp)
80108501:	e8 b5 fe ff ff       	call   801083bb <pci_access_config>
80108506:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108509:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010850c:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010850f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108512:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108515:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108518:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010851b:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010851e:	0f b6 c0             	movzbl %al,%eax
80108521:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108524:	c1 eb 18             	shr    $0x18,%ebx
80108527:	83 ec 0c             	sub    $0xc,%esp
8010852a:	51                   	push   %ecx
8010852b:	52                   	push   %edx
8010852c:	50                   	push   %eax
8010852d:	53                   	push   %ebx
8010852e:	68 dc c1 10 80       	push   $0x8010c1dc
80108533:	e8 bc 7e ff ff       	call   801003f4 <cprintf>
80108538:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010853b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010853e:	c1 e8 18             	shr    $0x18,%eax
80108541:	a2 70 6c 19 80       	mov    %al,0x80196c70
  dev.sub_class = (data>>16)&0xFF;
80108546:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108549:	c1 e8 10             	shr    $0x10,%eax
8010854c:	a2 71 6c 19 80       	mov    %al,0x80196c71
  dev.interface = (data>>8)&0xFF;
80108551:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108554:	c1 e8 08             	shr    $0x8,%eax
80108557:	a2 72 6c 19 80       	mov    %al,0x80196c72
  dev.revision_id = data&0xFF;
8010855c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010855f:	a2 73 6c 19 80       	mov    %al,0x80196c73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108564:	83 ec 0c             	sub    $0xc,%esp
80108567:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010856a:	50                   	push   %eax
8010856b:	6a 10                	push   $0x10
8010856d:	ff 75 10             	push   0x10(%ebp)
80108570:	ff 75 0c             	push   0xc(%ebp)
80108573:	ff 75 08             	push   0x8(%ebp)
80108576:	e8 40 fe ff ff       	call   801083bb <pci_access_config>
8010857b:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010857e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108581:	a3 74 6c 19 80       	mov    %eax,0x80196c74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108586:	83 ec 0c             	sub    $0xc,%esp
80108589:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010858c:	50                   	push   %eax
8010858d:	6a 14                	push   $0x14
8010858f:	ff 75 10             	push   0x10(%ebp)
80108592:	ff 75 0c             	push   0xc(%ebp)
80108595:	ff 75 08             	push   0x8(%ebp)
80108598:	e8 1e fe ff ff       	call   801083bb <pci_access_config>
8010859d:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801085a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085a3:	a3 78 6c 19 80       	mov    %eax,0x80196c78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801085a8:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801085af:	75 5a                	jne    8010860b <pci_init_device+0x1a5>
801085b1:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801085b8:	75 51                	jne    8010860b <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801085ba:	83 ec 0c             	sub    $0xc,%esp
801085bd:	68 21 c2 10 80       	push   $0x8010c221
801085c2:	e8 2d 7e ff ff       	call   801003f4 <cprintf>
801085c7:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801085ca:	83 ec 0c             	sub    $0xc,%esp
801085cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085d0:	50                   	push   %eax
801085d1:	68 f0 00 00 00       	push   $0xf0
801085d6:	ff 75 10             	push   0x10(%ebp)
801085d9:	ff 75 0c             	push   0xc(%ebp)
801085dc:	ff 75 08             	push   0x8(%ebp)
801085df:	e8 d7 fd ff ff       	call   801083bb <pci_access_config>
801085e4:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801085e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ea:	83 ec 08             	sub    $0x8,%esp
801085ed:	50                   	push   %eax
801085ee:	68 3b c2 10 80       	push   $0x8010c23b
801085f3:	e8 fc 7d ff ff       	call   801003f4 <cprintf>
801085f8:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801085fb:	83 ec 0c             	sub    $0xc,%esp
801085fe:	68 64 6c 19 80       	push   $0x80196c64
80108603:	e8 09 00 00 00       	call   80108611 <i8254_init>
80108608:	83 c4 10             	add    $0x10,%esp
  }
}
8010860b:	90                   	nop
8010860c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010860f:	c9                   	leave  
80108610:	c3                   	ret    

80108611 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108611:	55                   	push   %ebp
80108612:	89 e5                	mov    %esp,%ebp
80108614:	53                   	push   %ebx
80108615:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108618:	8b 45 08             	mov    0x8(%ebp),%eax
8010861b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010861f:	0f b6 c8             	movzbl %al,%ecx
80108622:	8b 45 08             	mov    0x8(%ebp),%eax
80108625:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108629:	0f b6 d0             	movzbl %al,%edx
8010862c:	8b 45 08             	mov    0x8(%ebp),%eax
8010862f:	0f b6 00             	movzbl (%eax),%eax
80108632:	0f b6 c0             	movzbl %al,%eax
80108635:	83 ec 0c             	sub    $0xc,%esp
80108638:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010863b:	53                   	push   %ebx
8010863c:	6a 04                	push   $0x4
8010863e:	51                   	push   %ecx
8010863f:	52                   	push   %edx
80108640:	50                   	push   %eax
80108641:	e8 75 fd ff ff       	call   801083bb <pci_access_config>
80108646:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108649:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010864c:	83 c8 04             	or     $0x4,%eax
8010864f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108652:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108655:	8b 45 08             	mov    0x8(%ebp),%eax
80108658:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010865c:	0f b6 c8             	movzbl %al,%ecx
8010865f:	8b 45 08             	mov    0x8(%ebp),%eax
80108662:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108666:	0f b6 d0             	movzbl %al,%edx
80108669:	8b 45 08             	mov    0x8(%ebp),%eax
8010866c:	0f b6 00             	movzbl (%eax),%eax
8010866f:	0f b6 c0             	movzbl %al,%eax
80108672:	83 ec 0c             	sub    $0xc,%esp
80108675:	53                   	push   %ebx
80108676:	6a 04                	push   $0x4
80108678:	51                   	push   %ecx
80108679:	52                   	push   %edx
8010867a:	50                   	push   %eax
8010867b:	e8 90 fd ff ff       	call   80108410 <pci_write_config_register>
80108680:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108683:	8b 45 08             	mov    0x8(%ebp),%eax
80108686:	8b 40 10             	mov    0x10(%eax),%eax
80108689:	05 00 00 00 40       	add    $0x40000000,%eax
8010868e:	a3 7c 6c 19 80       	mov    %eax,0x80196c7c
  uint *ctrl = (uint *)base_addr;
80108693:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108698:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010869b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086a0:	05 d8 00 00 00       	add    $0xd8,%eax
801086a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801086a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086ab:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801086b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b4:	8b 00                	mov    (%eax),%eax
801086b6:	0d 00 00 00 04       	or     $0x4000000,%eax
801086bb:	89 c2                	mov    %eax,%edx
801086bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c0:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801086c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086c5:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801086cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ce:	8b 00                	mov    (%eax),%eax
801086d0:	83 c8 40             	or     $0x40,%eax
801086d3:	89 c2                	mov    %eax,%edx
801086d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d8:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801086da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dd:	8b 10                	mov    (%eax),%edx
801086df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e2:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801086e4:	83 ec 0c             	sub    $0xc,%esp
801086e7:	68 50 c2 10 80       	push   $0x8010c250
801086ec:	e8 03 7d ff ff       	call   801003f4 <cprintf>
801086f1:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801086f4:	e8 a8 a0 ff ff       	call   801027a1 <kalloc>
801086f9:	a3 88 6c 19 80       	mov    %eax,0x80196c88
  *intr_addr = 0;
801086fe:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108703:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108709:	a1 88 6c 19 80       	mov    0x80196c88,%eax
8010870e:	83 ec 08             	sub    $0x8,%esp
80108711:	50                   	push   %eax
80108712:	68 72 c2 10 80       	push   $0x8010c272
80108717:	e8 d8 7c ff ff       	call   801003f4 <cprintf>
8010871c:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010871f:	e8 50 00 00 00       	call   80108774 <i8254_init_recv>
  i8254_init_send();
80108724:	e8 69 03 00 00       	call   80108a92 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108729:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108730:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108733:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010873a:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010873d:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108744:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108747:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010874e:	0f b6 c0             	movzbl %al,%eax
80108751:	83 ec 0c             	sub    $0xc,%esp
80108754:	53                   	push   %ebx
80108755:	51                   	push   %ecx
80108756:	52                   	push   %edx
80108757:	50                   	push   %eax
80108758:	68 80 c2 10 80       	push   $0x8010c280
8010875d:	e8 92 7c ff ff       	call   801003f4 <cprintf>
80108762:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108768:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
8010876e:	90                   	nop
8010876f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108772:	c9                   	leave  
80108773:	c3                   	ret    

80108774 <i8254_init_recv>:

void i8254_init_recv(){
80108774:	55                   	push   %ebp
80108775:	89 e5                	mov    %esp,%ebp
80108777:	57                   	push   %edi
80108778:	56                   	push   %esi
80108779:	53                   	push   %ebx
8010877a:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
8010877d:	83 ec 0c             	sub    $0xc,%esp
80108780:	6a 00                	push   $0x0
80108782:	e8 e8 04 00 00       	call   80108c6f <i8254_read_eeprom>
80108787:	83 c4 10             	add    $0x10,%esp
8010878a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
8010878d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108790:	a2 80 6c 19 80       	mov    %al,0x80196c80
  mac_addr[1] = data_l>>8;
80108795:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108798:	c1 e8 08             	shr    $0x8,%eax
8010879b:	a2 81 6c 19 80       	mov    %al,0x80196c81
  uint data_m = i8254_read_eeprom(0x1);
801087a0:	83 ec 0c             	sub    $0xc,%esp
801087a3:	6a 01                	push   $0x1
801087a5:	e8 c5 04 00 00       	call   80108c6f <i8254_read_eeprom>
801087aa:	83 c4 10             	add    $0x10,%esp
801087ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801087b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801087b3:	a2 82 6c 19 80       	mov    %al,0x80196c82
  mac_addr[3] = data_m>>8;
801087b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801087bb:	c1 e8 08             	shr    $0x8,%eax
801087be:	a2 83 6c 19 80       	mov    %al,0x80196c83
  uint data_h = i8254_read_eeprom(0x2);
801087c3:	83 ec 0c             	sub    $0xc,%esp
801087c6:	6a 02                	push   $0x2
801087c8:	e8 a2 04 00 00       	call   80108c6f <i8254_read_eeprom>
801087cd:	83 c4 10             	add    $0x10,%esp
801087d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801087d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801087d6:	a2 84 6c 19 80       	mov    %al,0x80196c84
  mac_addr[5] = data_h>>8;
801087db:	8b 45 d0             	mov    -0x30(%ebp),%eax
801087de:	c1 e8 08             	shr    $0x8,%eax
801087e1:	a2 85 6c 19 80       	mov    %al,0x80196c85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801087e6:	0f b6 05 85 6c 19 80 	movzbl 0x80196c85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087ed:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801087f0:	0f b6 05 84 6c 19 80 	movzbl 0x80196c84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087f7:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801087fa:	0f b6 05 83 6c 19 80 	movzbl 0x80196c83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108801:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108804:	0f b6 05 82 6c 19 80 	movzbl 0x80196c82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010880b:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010880e:	0f b6 05 81 6c 19 80 	movzbl 0x80196c81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108815:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108818:	0f b6 05 80 6c 19 80 	movzbl 0x80196c80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010881f:	0f b6 c0             	movzbl %al,%eax
80108822:	83 ec 04             	sub    $0x4,%esp
80108825:	57                   	push   %edi
80108826:	56                   	push   %esi
80108827:	53                   	push   %ebx
80108828:	51                   	push   %ecx
80108829:	52                   	push   %edx
8010882a:	50                   	push   %eax
8010882b:	68 98 c2 10 80       	push   $0x8010c298
80108830:	e8 bf 7b ff ff       	call   801003f4 <cprintf>
80108835:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108838:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010883d:	05 00 54 00 00       	add    $0x5400,%eax
80108842:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108845:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010884a:	05 04 54 00 00       	add    $0x5404,%eax
8010884f:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108852:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108855:	c1 e0 10             	shl    $0x10,%eax
80108858:	0b 45 d8             	or     -0x28(%ebp),%eax
8010885b:	89 c2                	mov    %eax,%edx
8010885d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108860:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108862:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108865:	0d 00 00 00 80       	or     $0x80000000,%eax
8010886a:	89 c2                	mov    %eax,%edx
8010886c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010886f:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108871:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108876:	05 00 52 00 00       	add    $0x5200,%eax
8010887b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
8010887e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108885:	eb 19                	jmp    801088a0 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108887:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010888a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108891:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108894:	01 d0                	add    %edx,%eax
80108896:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
8010889c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801088a0:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801088a4:	7e e1                	jle    80108887 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801088a6:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088ab:	05 d0 00 00 00       	add    $0xd0,%eax
801088b0:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801088b3:	8b 45 c0             	mov    -0x40(%ebp),%eax
801088b6:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801088bc:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088c1:	05 c8 00 00 00       	add    $0xc8,%eax
801088c6:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801088c9:	8b 45 bc             	mov    -0x44(%ebp),%eax
801088cc:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801088d2:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088d7:	05 28 28 00 00       	add    $0x2828,%eax
801088dc:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801088df:	8b 45 b8             	mov    -0x48(%ebp),%eax
801088e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801088e8:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088ed:	05 00 01 00 00       	add    $0x100,%eax
801088f2:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801088f5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088f8:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801088fe:	e8 9e 9e ff ff       	call   801027a1 <kalloc>
80108903:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108906:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010890b:	05 00 28 00 00       	add    $0x2800,%eax
80108910:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108913:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108918:	05 04 28 00 00       	add    $0x2804,%eax
8010891d:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108920:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108925:	05 08 28 00 00       	add    $0x2808,%eax
8010892a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
8010892d:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108932:	05 10 28 00 00       	add    $0x2810,%eax
80108937:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010893a:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010893f:	05 18 28 00 00       	add    $0x2818,%eax
80108944:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108947:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010894a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108950:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108953:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108955:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108958:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
8010895e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108961:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108967:	8b 45 a0             	mov    -0x60(%ebp),%eax
8010896a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108970:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108973:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108979:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010897c:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010897f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108986:	eb 73                	jmp    801089fb <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108988:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010898b:	c1 e0 04             	shl    $0x4,%eax
8010898e:	89 c2                	mov    %eax,%edx
80108990:	8b 45 98             	mov    -0x68(%ebp),%eax
80108993:	01 d0                	add    %edx,%eax
80108995:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
8010899c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010899f:	c1 e0 04             	shl    $0x4,%eax
801089a2:	89 c2                	mov    %eax,%edx
801089a4:	8b 45 98             	mov    -0x68(%ebp),%eax
801089a7:	01 d0                	add    %edx,%eax
801089a9:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801089af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089b2:	c1 e0 04             	shl    $0x4,%eax
801089b5:	89 c2                	mov    %eax,%edx
801089b7:	8b 45 98             	mov    -0x68(%ebp),%eax
801089ba:	01 d0                	add    %edx,%eax
801089bc:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801089c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089c5:	c1 e0 04             	shl    $0x4,%eax
801089c8:	89 c2                	mov    %eax,%edx
801089ca:	8b 45 98             	mov    -0x68(%ebp),%eax
801089cd:	01 d0                	add    %edx,%eax
801089cf:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801089d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089d6:	c1 e0 04             	shl    $0x4,%eax
801089d9:	89 c2                	mov    %eax,%edx
801089db:	8b 45 98             	mov    -0x68(%ebp),%eax
801089de:	01 d0                	add    %edx,%eax
801089e0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801089e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089e7:	c1 e0 04             	shl    $0x4,%eax
801089ea:	89 c2                	mov    %eax,%edx
801089ec:	8b 45 98             	mov    -0x68(%ebp),%eax
801089ef:	01 d0                	add    %edx,%eax
801089f1:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801089f7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801089fb:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108a02:	7e 84                	jle    80108988 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108a04:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108a0b:	eb 57                	jmp    80108a64 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108a0d:	e8 8f 9d ff ff       	call   801027a1 <kalloc>
80108a12:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108a15:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108a19:	75 12                	jne    80108a2d <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108a1b:	83 ec 0c             	sub    $0xc,%esp
80108a1e:	68 b8 c2 10 80       	push   $0x8010c2b8
80108a23:	e8 cc 79 ff ff       	call   801003f4 <cprintf>
80108a28:	83 c4 10             	add    $0x10,%esp
      break;
80108a2b:	eb 3d                	jmp    80108a6a <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108a2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a30:	c1 e0 04             	shl    $0x4,%eax
80108a33:	89 c2                	mov    %eax,%edx
80108a35:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a38:	01 d0                	add    %edx,%eax
80108a3a:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108a3d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a43:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a45:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a48:	83 c0 01             	add    $0x1,%eax
80108a4b:	c1 e0 04             	shl    $0x4,%eax
80108a4e:	89 c2                	mov    %eax,%edx
80108a50:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a53:	01 d0                	add    %edx,%eax
80108a55:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108a58:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a5e:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108a60:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108a64:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108a68:	7e a3                	jle    80108a0d <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108a6a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a6d:	8b 00                	mov    (%eax),%eax
80108a6f:	83 c8 02             	or     $0x2,%eax
80108a72:	89 c2                	mov    %eax,%edx
80108a74:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a77:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108a79:	83 ec 0c             	sub    $0xc,%esp
80108a7c:	68 d8 c2 10 80       	push   $0x8010c2d8
80108a81:	e8 6e 79 ff ff       	call   801003f4 <cprintf>
80108a86:	83 c4 10             	add    $0x10,%esp
}
80108a89:	90                   	nop
80108a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108a8d:	5b                   	pop    %ebx
80108a8e:	5e                   	pop    %esi
80108a8f:	5f                   	pop    %edi
80108a90:	5d                   	pop    %ebp
80108a91:	c3                   	ret    

80108a92 <i8254_init_send>:

void i8254_init_send(){
80108a92:	55                   	push   %ebp
80108a93:	89 e5                	mov    %esp,%ebp
80108a95:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108a98:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a9d:	05 28 38 00 00       	add    $0x3828,%eax
80108aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108aa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aa8:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108aae:	e8 ee 9c ff ff       	call   801027a1 <kalloc>
80108ab3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108ab6:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108abb:	05 00 38 00 00       	add    $0x3800,%eax
80108ac0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108ac3:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ac8:	05 04 38 00 00       	add    $0x3804,%eax
80108acd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108ad0:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ad5:	05 08 38 00 00       	add    $0x3808,%eax
80108ada:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108add:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ae0:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108ae6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ae9:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108aeb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108aee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108af4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108af7:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108afd:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b02:	05 10 38 00 00       	add    $0x3810,%eax
80108b07:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108b0a:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b0f:	05 18 38 00 00       	add    $0x3818,%eax
80108b14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108b17:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108b20:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b23:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108b29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108b2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b36:	e9 82 00 00 00       	jmp    80108bbd <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b3e:	c1 e0 04             	shl    $0x4,%eax
80108b41:	89 c2                	mov    %eax,%edx
80108b43:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b46:	01 d0                	add    %edx,%eax
80108b48:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b52:	c1 e0 04             	shl    $0x4,%eax
80108b55:	89 c2                	mov    %eax,%edx
80108b57:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b5a:	01 d0                	add    %edx,%eax
80108b5c:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b65:	c1 e0 04             	shl    $0x4,%eax
80108b68:	89 c2                	mov    %eax,%edx
80108b6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b6d:	01 d0                	add    %edx,%eax
80108b6f:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b76:	c1 e0 04             	shl    $0x4,%eax
80108b79:	89 c2                	mov    %eax,%edx
80108b7b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b7e:	01 d0                	add    %edx,%eax
80108b80:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b87:	c1 e0 04             	shl    $0x4,%eax
80108b8a:	89 c2                	mov    %eax,%edx
80108b8c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b8f:	01 d0                	add    %edx,%eax
80108b91:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b98:	c1 e0 04             	shl    $0x4,%eax
80108b9b:	89 c2                	mov    %eax,%edx
80108b9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ba0:	01 d0                	add    %edx,%eax
80108ba2:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba9:	c1 e0 04             	shl    $0x4,%eax
80108bac:	89 c2                	mov    %eax,%edx
80108bae:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bb1:	01 d0                	add    %edx,%eax
80108bb3:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108bb9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108bbd:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108bc4:	0f 8e 71 ff ff ff    	jle    80108b3b <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108bca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108bd1:	eb 57                	jmp    80108c2a <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108bd3:	e8 c9 9b ff ff       	call   801027a1 <kalloc>
80108bd8:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108bdb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108bdf:	75 12                	jne    80108bf3 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108be1:	83 ec 0c             	sub    $0xc,%esp
80108be4:	68 b8 c2 10 80       	push   $0x8010c2b8
80108be9:	e8 06 78 ff ff       	call   801003f4 <cprintf>
80108bee:	83 c4 10             	add    $0x10,%esp
      break;
80108bf1:	eb 3d                	jmp    80108c30 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bf6:	c1 e0 04             	shl    $0x4,%eax
80108bf9:	89 c2                	mov    %eax,%edx
80108bfb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bfe:	01 d0                	add    %edx,%eax
80108c00:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108c03:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c09:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c0e:	83 c0 01             	add    $0x1,%eax
80108c11:	c1 e0 04             	shl    $0x4,%eax
80108c14:	89 c2                	mov    %eax,%edx
80108c16:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c19:	01 d0                	add    %edx,%eax
80108c1b:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108c1e:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108c24:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108c26:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108c2a:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108c2e:	7e a3                	jle    80108bd3 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108c30:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c35:	05 00 04 00 00       	add    $0x400,%eax
80108c3a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108c3d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c40:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108c46:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c4b:	05 10 04 00 00       	add    $0x410,%eax
80108c50:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108c53:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108c56:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108c5c:	83 ec 0c             	sub    $0xc,%esp
80108c5f:	68 f8 c2 10 80       	push   $0x8010c2f8
80108c64:	e8 8b 77 ff ff       	call   801003f4 <cprintf>
80108c69:	83 c4 10             	add    $0x10,%esp

}
80108c6c:	90                   	nop
80108c6d:	c9                   	leave  
80108c6e:	c3                   	ret    

80108c6f <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108c6f:	55                   	push   %ebp
80108c70:	89 e5                	mov    %esp,%ebp
80108c72:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108c75:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c7a:	83 c0 14             	add    $0x14,%eax
80108c7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108c80:	8b 45 08             	mov    0x8(%ebp),%eax
80108c83:	c1 e0 08             	shl    $0x8,%eax
80108c86:	0f b7 c0             	movzwl %ax,%eax
80108c89:	83 c8 01             	or     $0x1,%eax
80108c8c:	89 c2                	mov    %eax,%edx
80108c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c91:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108c93:	83 ec 0c             	sub    $0xc,%esp
80108c96:	68 18 c3 10 80       	push   $0x8010c318
80108c9b:	e8 54 77 ff ff       	call   801003f4 <cprintf>
80108ca0:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca6:	8b 00                	mov    (%eax),%eax
80108ca8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cae:	83 e0 10             	and    $0x10,%eax
80108cb1:	85 c0                	test   %eax,%eax
80108cb3:	75 02                	jne    80108cb7 <i8254_read_eeprom+0x48>
  while(1){
80108cb5:	eb dc                	jmp    80108c93 <i8254_read_eeprom+0x24>
      break;
80108cb7:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cbb:	8b 00                	mov    (%eax),%eax
80108cbd:	c1 e8 10             	shr    $0x10,%eax
}
80108cc0:	c9                   	leave  
80108cc1:	c3                   	ret    

80108cc2 <i8254_recv>:
void i8254_recv(){
80108cc2:	55                   	push   %ebp
80108cc3:	89 e5                	mov    %esp,%ebp
80108cc5:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108cc8:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ccd:	05 10 28 00 00       	add    $0x2810,%eax
80108cd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108cd5:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108cda:	05 18 28 00 00       	add    $0x2818,%eax
80108cdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ce2:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ce7:	05 00 28 00 00       	add    $0x2800,%eax
80108cec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108cef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cf2:	8b 00                	mov    (%eax),%eax
80108cf4:	05 00 00 00 80       	add    $0x80000000,%eax
80108cf9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cff:	8b 10                	mov    (%eax),%edx
80108d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d04:	8b 08                	mov    (%eax),%ecx
80108d06:	89 d0                	mov    %edx,%eax
80108d08:	29 c8                	sub    %ecx,%eax
80108d0a:	25 ff 00 00 00       	and    $0xff,%eax
80108d0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108d12:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108d16:	7e 37                	jle    80108d4f <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d1b:	8b 00                	mov    (%eax),%eax
80108d1d:	c1 e0 04             	shl    $0x4,%eax
80108d20:	89 c2                	mov    %eax,%edx
80108d22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d25:	01 d0                	add    %edx,%eax
80108d27:	8b 00                	mov    (%eax),%eax
80108d29:	05 00 00 00 80       	add    $0x80000000,%eax
80108d2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d34:	8b 00                	mov    (%eax),%eax
80108d36:	83 c0 01             	add    $0x1,%eax
80108d39:	0f b6 d0             	movzbl %al,%edx
80108d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d3f:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108d41:	83 ec 0c             	sub    $0xc,%esp
80108d44:	ff 75 e0             	push   -0x20(%ebp)
80108d47:	e8 15 09 00 00       	call   80109661 <eth_proc>
80108d4c:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d52:	8b 10                	mov    (%eax),%edx
80108d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d57:	8b 00                	mov    (%eax),%eax
80108d59:	39 c2                	cmp    %eax,%edx
80108d5b:	75 9f                	jne    80108cfc <i8254_recv+0x3a>
      (*rdt)--;
80108d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d60:	8b 00                	mov    (%eax),%eax
80108d62:	8d 50 ff             	lea    -0x1(%eax),%edx
80108d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d68:	89 10                	mov    %edx,(%eax)
  while(1){
80108d6a:	eb 90                	jmp    80108cfc <i8254_recv+0x3a>

80108d6c <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108d6c:	55                   	push   %ebp
80108d6d:	89 e5                	mov    %esp,%ebp
80108d6f:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d72:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108d77:	05 10 38 00 00       	add    $0x3810,%eax
80108d7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d7f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108d84:	05 18 38 00 00       	add    $0x3818,%eax
80108d89:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108d8c:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108d91:	05 00 38 00 00       	add    $0x3800,%eax
80108d96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108d99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d9c:	8b 00                	mov    (%eax),%eax
80108d9e:	05 00 00 00 80       	add    $0x80000000,%eax
80108da3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108da9:	8b 10                	mov    (%eax),%edx
80108dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dae:	8b 08                	mov    (%eax),%ecx
80108db0:	89 d0                	mov    %edx,%eax
80108db2:	29 c8                	sub    %ecx,%eax
80108db4:	0f b6 d0             	movzbl %al,%edx
80108db7:	b8 00 01 00 00       	mov    $0x100,%eax
80108dbc:	29 d0                	sub    %edx,%eax
80108dbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc4:	8b 00                	mov    (%eax),%eax
80108dc6:	25 ff 00 00 00       	and    $0xff,%eax
80108dcb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108dce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108dd2:	0f 8e a8 00 00 00    	jle    80108e80 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80108ddb:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108dde:	89 d1                	mov    %edx,%ecx
80108de0:	c1 e1 04             	shl    $0x4,%ecx
80108de3:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108de6:	01 ca                	add    %ecx,%edx
80108de8:	8b 12                	mov    (%edx),%edx
80108dea:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108df0:	83 ec 04             	sub    $0x4,%esp
80108df3:	ff 75 0c             	push   0xc(%ebp)
80108df6:	50                   	push   %eax
80108df7:	52                   	push   %edx
80108df8:	e8 94 bd ff ff       	call   80104b91 <memmove>
80108dfd:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108e00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e03:	c1 e0 04             	shl    $0x4,%eax
80108e06:	89 c2                	mov    %eax,%edx
80108e08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e0b:	01 d0                	add    %edx,%eax
80108e0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e10:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e17:	c1 e0 04             	shl    $0x4,%eax
80108e1a:	89 c2                	mov    %eax,%edx
80108e1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e1f:	01 d0                	add    %edx,%eax
80108e21:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108e25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e28:	c1 e0 04             	shl    $0x4,%eax
80108e2b:	89 c2                	mov    %eax,%edx
80108e2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e30:	01 d0                	add    %edx,%eax
80108e32:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108e36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e39:	c1 e0 04             	shl    $0x4,%eax
80108e3c:	89 c2                	mov    %eax,%edx
80108e3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e41:	01 d0                	add    %edx,%eax
80108e43:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e4a:	c1 e0 04             	shl    $0x4,%eax
80108e4d:	89 c2                	mov    %eax,%edx
80108e4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e52:	01 d0                	add    %edx,%eax
80108e54:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108e5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e5d:	c1 e0 04             	shl    $0x4,%eax
80108e60:	89 c2                	mov    %eax,%edx
80108e62:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e65:	01 d0                	add    %edx,%eax
80108e67:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6e:	8b 00                	mov    (%eax),%eax
80108e70:	83 c0 01             	add    $0x1,%eax
80108e73:	0f b6 d0             	movzbl %al,%edx
80108e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e79:	89 10                	mov    %edx,(%eax)
    return len;
80108e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e7e:	eb 05                	jmp    80108e85 <i8254_send+0x119>
  }else{
    return -1;
80108e80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108e85:	c9                   	leave  
80108e86:	c3                   	ret    

80108e87 <i8254_intr>:

void i8254_intr(){
80108e87:	55                   	push   %ebp
80108e88:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108e8a:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108e8f:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108e95:	90                   	nop
80108e96:	5d                   	pop    %ebp
80108e97:	c3                   	ret    

80108e98 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108e98:	55                   	push   %ebp
80108e99:	89 e5                	mov    %esp,%ebp
80108e9b:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108e9e:	8b 45 08             	mov    0x8(%ebp),%eax
80108ea1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea7:	0f b7 00             	movzwl (%eax),%eax
80108eaa:	66 3d 00 01          	cmp    $0x100,%ax
80108eae:	74 0a                	je     80108eba <arp_proc+0x22>
80108eb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108eb5:	e9 4f 01 00 00       	jmp    80109009 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ebd:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108ec1:	66 83 f8 08          	cmp    $0x8,%ax
80108ec5:	74 0a                	je     80108ed1 <arp_proc+0x39>
80108ec7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ecc:	e9 38 01 00 00       	jmp    80109009 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108ed8:	3c 06                	cmp    $0x6,%al
80108eda:	74 0a                	je     80108ee6 <arp_proc+0x4e>
80108edc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ee1:	e9 23 01 00 00       	jmp    80109009 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee9:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108eed:	3c 04                	cmp    $0x4,%al
80108eef:	74 0a                	je     80108efb <arp_proc+0x63>
80108ef1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ef6:	e9 0e 01 00 00       	jmp    80109009 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108efe:	83 c0 18             	add    $0x18,%eax
80108f01:	83 ec 04             	sub    $0x4,%esp
80108f04:	6a 04                	push   $0x4
80108f06:	50                   	push   %eax
80108f07:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f0c:	e8 28 bc ff ff       	call   80104b39 <memcmp>
80108f11:	83 c4 10             	add    $0x10,%esp
80108f14:	85 c0                	test   %eax,%eax
80108f16:	74 27                	je     80108f3f <arp_proc+0xa7>
80108f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1b:	83 c0 0e             	add    $0xe,%eax
80108f1e:	83 ec 04             	sub    $0x4,%esp
80108f21:	6a 04                	push   $0x4
80108f23:	50                   	push   %eax
80108f24:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f29:	e8 0b bc ff ff       	call   80104b39 <memcmp>
80108f2e:	83 c4 10             	add    $0x10,%esp
80108f31:	85 c0                	test   %eax,%eax
80108f33:	74 0a                	je     80108f3f <arp_proc+0xa7>
80108f35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f3a:	e9 ca 00 00 00       	jmp    80109009 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f42:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108f46:	66 3d 00 01          	cmp    $0x100,%ax
80108f4a:	75 69                	jne    80108fb5 <arp_proc+0x11d>
80108f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f4f:	83 c0 18             	add    $0x18,%eax
80108f52:	83 ec 04             	sub    $0x4,%esp
80108f55:	6a 04                	push   $0x4
80108f57:	50                   	push   %eax
80108f58:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f5d:	e8 d7 bb ff ff       	call   80104b39 <memcmp>
80108f62:	83 c4 10             	add    $0x10,%esp
80108f65:	85 c0                	test   %eax,%eax
80108f67:	75 4c                	jne    80108fb5 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108f69:	e8 33 98 ff ff       	call   801027a1 <kalloc>
80108f6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108f71:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108f78:	83 ec 04             	sub    $0x4,%esp
80108f7b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108f7e:	50                   	push   %eax
80108f7f:	ff 75 f0             	push   -0x10(%ebp)
80108f82:	ff 75 f4             	push   -0xc(%ebp)
80108f85:	e8 1f 04 00 00       	call   801093a9 <arp_reply_pkt_create>
80108f8a:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108f8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f90:	83 ec 08             	sub    $0x8,%esp
80108f93:	50                   	push   %eax
80108f94:	ff 75 f0             	push   -0x10(%ebp)
80108f97:	e8 d0 fd ff ff       	call   80108d6c <i8254_send>
80108f9c:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa2:	83 ec 0c             	sub    $0xc,%esp
80108fa5:	50                   	push   %eax
80108fa6:	e8 5c 97 ff ff       	call   80102707 <kfree>
80108fab:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108fae:	b8 02 00 00 00       	mov    $0x2,%eax
80108fb3:	eb 54                	jmp    80109009 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108fbc:	66 3d 00 02          	cmp    $0x200,%ax
80108fc0:	75 42                	jne    80109004 <arp_proc+0x16c>
80108fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc5:	83 c0 18             	add    $0x18,%eax
80108fc8:	83 ec 04             	sub    $0x4,%esp
80108fcb:	6a 04                	push   $0x4
80108fcd:	50                   	push   %eax
80108fce:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fd3:	e8 61 bb ff ff       	call   80104b39 <memcmp>
80108fd8:	83 c4 10             	add    $0x10,%esp
80108fdb:	85 c0                	test   %eax,%eax
80108fdd:	75 25                	jne    80109004 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108fdf:	83 ec 0c             	sub    $0xc,%esp
80108fe2:	68 1c c3 10 80       	push   $0x8010c31c
80108fe7:	e8 08 74 ff ff       	call   801003f4 <cprintf>
80108fec:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108fef:	83 ec 0c             	sub    $0xc,%esp
80108ff2:	ff 75 f4             	push   -0xc(%ebp)
80108ff5:	e8 af 01 00 00       	call   801091a9 <arp_table_update>
80108ffa:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108ffd:	b8 01 00 00 00       	mov    $0x1,%eax
80109002:	eb 05                	jmp    80109009 <arp_proc+0x171>
  }else{
    return -1;
80109004:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109009:	c9                   	leave  
8010900a:	c3                   	ret    

8010900b <arp_scan>:

void arp_scan(){
8010900b:	55                   	push   %ebp
8010900c:	89 e5                	mov    %esp,%ebp
8010900e:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109011:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109018:	eb 6f                	jmp    80109089 <arp_scan+0x7e>
    uint send = (uint)kalloc();
8010901a:	e8 82 97 ff ff       	call   801027a1 <kalloc>
8010901f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109022:	83 ec 04             	sub    $0x4,%esp
80109025:	ff 75 f4             	push   -0xc(%ebp)
80109028:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010902b:	50                   	push   %eax
8010902c:	ff 75 ec             	push   -0x14(%ebp)
8010902f:	e8 62 00 00 00       	call   80109096 <arp_broadcast>
80109034:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109037:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010903a:	83 ec 08             	sub    $0x8,%esp
8010903d:	50                   	push   %eax
8010903e:	ff 75 ec             	push   -0x14(%ebp)
80109041:	e8 26 fd ff ff       	call   80108d6c <i8254_send>
80109046:	83 c4 10             	add    $0x10,%esp
80109049:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010904c:	eb 22                	jmp    80109070 <arp_scan+0x65>
      microdelay(1);
8010904e:	83 ec 0c             	sub    $0xc,%esp
80109051:	6a 01                	push   $0x1
80109053:	e8 e0 9a ff ff       	call   80102b38 <microdelay>
80109058:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010905b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010905e:	83 ec 08             	sub    $0x8,%esp
80109061:	50                   	push   %eax
80109062:	ff 75 ec             	push   -0x14(%ebp)
80109065:	e8 02 fd ff ff       	call   80108d6c <i8254_send>
8010906a:	83 c4 10             	add    $0x10,%esp
8010906d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109070:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109074:	74 d8                	je     8010904e <arp_scan+0x43>
    }
    kfree((char *)send);
80109076:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109079:	83 ec 0c             	sub    $0xc,%esp
8010907c:	50                   	push   %eax
8010907d:	e8 85 96 ff ff       	call   80102707 <kfree>
80109082:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109085:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109089:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109090:	7e 88                	jle    8010901a <arp_scan+0xf>
  }
}
80109092:	90                   	nop
80109093:	90                   	nop
80109094:	c9                   	leave  
80109095:	c3                   	ret    

80109096 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109096:	55                   	push   %ebp
80109097:	89 e5                	mov    %esp,%ebp
80109099:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
8010909c:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801090a0:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801090a4:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801090a8:	8b 45 10             	mov    0x10(%ebp),%eax
801090ab:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801090ae:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801090b5:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801090bb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801090c2:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801090c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801090cb:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801090d1:	8b 45 08             	mov    0x8(%ebp),%eax
801090d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801090d7:	8b 45 08             	mov    0x8(%ebp),%eax
801090da:	83 c0 0e             	add    $0xe,%eax
801090dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801090e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e3:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801090e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ea:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801090ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f1:	83 ec 04             	sub    $0x4,%esp
801090f4:	6a 06                	push   $0x6
801090f6:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801090f9:	52                   	push   %edx
801090fa:	50                   	push   %eax
801090fb:	e8 91 ba ff ff       	call   80104b91 <memmove>
80109100:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109106:	83 c0 06             	add    $0x6,%eax
80109109:	83 ec 04             	sub    $0x4,%esp
8010910c:	6a 06                	push   $0x6
8010910e:	68 80 6c 19 80       	push   $0x80196c80
80109113:	50                   	push   %eax
80109114:	e8 78 ba ff ff       	call   80104b91 <memmove>
80109119:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010911c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010911f:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109127:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010912d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109130:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109134:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109137:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010913b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010913e:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109147:	8d 50 12             	lea    0x12(%eax),%edx
8010914a:	83 ec 04             	sub    $0x4,%esp
8010914d:	6a 06                	push   $0x6
8010914f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109152:	50                   	push   %eax
80109153:	52                   	push   %edx
80109154:	e8 38 ba ff ff       	call   80104b91 <memmove>
80109159:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010915c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010915f:	8d 50 18             	lea    0x18(%eax),%edx
80109162:	83 ec 04             	sub    $0x4,%esp
80109165:	6a 04                	push   $0x4
80109167:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010916a:	50                   	push   %eax
8010916b:	52                   	push   %edx
8010916c:	e8 20 ba ff ff       	call   80104b91 <memmove>
80109171:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109174:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109177:	83 c0 08             	add    $0x8,%eax
8010917a:	83 ec 04             	sub    $0x4,%esp
8010917d:	6a 06                	push   $0x6
8010917f:	68 80 6c 19 80       	push   $0x80196c80
80109184:	50                   	push   %eax
80109185:	e8 07 ba ff ff       	call   80104b91 <memmove>
8010918a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010918d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109190:	83 c0 0e             	add    $0xe,%eax
80109193:	83 ec 04             	sub    $0x4,%esp
80109196:	6a 04                	push   $0x4
80109198:	68 e4 f4 10 80       	push   $0x8010f4e4
8010919d:	50                   	push   %eax
8010919e:	e8 ee b9 ff ff       	call   80104b91 <memmove>
801091a3:	83 c4 10             	add    $0x10,%esp
}
801091a6:	90                   	nop
801091a7:	c9                   	leave  
801091a8:	c3                   	ret    

801091a9 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801091a9:	55                   	push   %ebp
801091aa:	89 e5                	mov    %esp,%ebp
801091ac:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801091af:	8b 45 08             	mov    0x8(%ebp),%eax
801091b2:	83 c0 0e             	add    $0xe,%eax
801091b5:	83 ec 0c             	sub    $0xc,%esp
801091b8:	50                   	push   %eax
801091b9:	e8 bc 00 00 00       	call   8010927a <arp_table_search>
801091be:	83 c4 10             	add    $0x10,%esp
801091c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801091c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801091c8:	78 2d                	js     801091f7 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801091ca:	8b 45 08             	mov    0x8(%ebp),%eax
801091cd:	8d 48 08             	lea    0x8(%eax),%ecx
801091d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091d3:	89 d0                	mov    %edx,%eax
801091d5:	c1 e0 02             	shl    $0x2,%eax
801091d8:	01 d0                	add    %edx,%eax
801091da:	01 c0                	add    %eax,%eax
801091dc:	01 d0                	add    %edx,%eax
801091de:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801091e3:	83 c0 04             	add    $0x4,%eax
801091e6:	83 ec 04             	sub    $0x4,%esp
801091e9:	6a 06                	push   $0x6
801091eb:	51                   	push   %ecx
801091ec:	50                   	push   %eax
801091ed:	e8 9f b9 ff ff       	call   80104b91 <memmove>
801091f2:	83 c4 10             	add    $0x10,%esp
801091f5:	eb 70                	jmp    80109267 <arp_table_update+0xbe>
  }else{
    index += 1;
801091f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801091fb:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801091fe:	8b 45 08             	mov    0x8(%ebp),%eax
80109201:	8d 48 08             	lea    0x8(%eax),%ecx
80109204:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109207:	89 d0                	mov    %edx,%eax
80109209:	c1 e0 02             	shl    $0x2,%eax
8010920c:	01 d0                	add    %edx,%eax
8010920e:	01 c0                	add    %eax,%eax
80109210:	01 d0                	add    %edx,%eax
80109212:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109217:	83 c0 04             	add    $0x4,%eax
8010921a:	83 ec 04             	sub    $0x4,%esp
8010921d:	6a 06                	push   $0x6
8010921f:	51                   	push   %ecx
80109220:	50                   	push   %eax
80109221:	e8 6b b9 ff ff       	call   80104b91 <memmove>
80109226:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109229:	8b 45 08             	mov    0x8(%ebp),%eax
8010922c:	8d 48 0e             	lea    0xe(%eax),%ecx
8010922f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109232:	89 d0                	mov    %edx,%eax
80109234:	c1 e0 02             	shl    $0x2,%eax
80109237:	01 d0                	add    %edx,%eax
80109239:	01 c0                	add    %eax,%eax
8010923b:	01 d0                	add    %edx,%eax
8010923d:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109242:	83 ec 04             	sub    $0x4,%esp
80109245:	6a 04                	push   $0x4
80109247:	51                   	push   %ecx
80109248:	50                   	push   %eax
80109249:	e8 43 b9 ff ff       	call   80104b91 <memmove>
8010924e:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109251:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109254:	89 d0                	mov    %edx,%eax
80109256:	c1 e0 02             	shl    $0x2,%eax
80109259:	01 d0                	add    %edx,%eax
8010925b:	01 c0                	add    %eax,%eax
8010925d:	01 d0                	add    %edx,%eax
8010925f:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109264:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109267:	83 ec 0c             	sub    $0xc,%esp
8010926a:	68 a0 6c 19 80       	push   $0x80196ca0
8010926f:	e8 83 00 00 00       	call   801092f7 <print_arp_table>
80109274:	83 c4 10             	add    $0x10,%esp
}
80109277:	90                   	nop
80109278:	c9                   	leave  
80109279:	c3                   	ret    

8010927a <arp_table_search>:

int arp_table_search(uchar *ip){
8010927a:	55                   	push   %ebp
8010927b:	89 e5                	mov    %esp,%ebp
8010927d:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109280:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109287:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010928e:	eb 59                	jmp    801092e9 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109290:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109293:	89 d0                	mov    %edx,%eax
80109295:	c1 e0 02             	shl    $0x2,%eax
80109298:	01 d0                	add    %edx,%eax
8010929a:	01 c0                	add    %eax,%eax
8010929c:	01 d0                	add    %edx,%eax
8010929e:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801092a3:	83 ec 04             	sub    $0x4,%esp
801092a6:	6a 04                	push   $0x4
801092a8:	ff 75 08             	push   0x8(%ebp)
801092ab:	50                   	push   %eax
801092ac:	e8 88 b8 ff ff       	call   80104b39 <memcmp>
801092b1:	83 c4 10             	add    $0x10,%esp
801092b4:	85 c0                	test   %eax,%eax
801092b6:	75 05                	jne    801092bd <arp_table_search+0x43>
      return i;
801092b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092bb:	eb 38                	jmp    801092f5 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801092bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801092c0:	89 d0                	mov    %edx,%eax
801092c2:	c1 e0 02             	shl    $0x2,%eax
801092c5:	01 d0                	add    %edx,%eax
801092c7:	01 c0                	add    %eax,%eax
801092c9:	01 d0                	add    %edx,%eax
801092cb:	05 aa 6c 19 80       	add    $0x80196caa,%eax
801092d0:	0f b6 00             	movzbl (%eax),%eax
801092d3:	84 c0                	test   %al,%al
801092d5:	75 0e                	jne    801092e5 <arp_table_search+0x6b>
801092d7:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801092db:	75 08                	jne    801092e5 <arp_table_search+0x6b>
      empty = -i;
801092dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e0:	f7 d8                	neg    %eax
801092e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801092e5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801092e9:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801092ed:	7e a1                	jle    80109290 <arp_table_search+0x16>
    }
  }
  return empty-1;
801092ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f2:	83 e8 01             	sub    $0x1,%eax
}
801092f5:	c9                   	leave  
801092f6:	c3                   	ret    

801092f7 <print_arp_table>:

void print_arp_table(){
801092f7:	55                   	push   %ebp
801092f8:	89 e5                	mov    %esp,%ebp
801092fa:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801092fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109304:	e9 92 00 00 00       	jmp    8010939b <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109309:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010930c:	89 d0                	mov    %edx,%eax
8010930e:	c1 e0 02             	shl    $0x2,%eax
80109311:	01 d0                	add    %edx,%eax
80109313:	01 c0                	add    %eax,%eax
80109315:	01 d0                	add    %edx,%eax
80109317:	05 aa 6c 19 80       	add    $0x80196caa,%eax
8010931c:	0f b6 00             	movzbl (%eax),%eax
8010931f:	84 c0                	test   %al,%al
80109321:	74 74                	je     80109397 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109323:	83 ec 08             	sub    $0x8,%esp
80109326:	ff 75 f4             	push   -0xc(%ebp)
80109329:	68 2f c3 10 80       	push   $0x8010c32f
8010932e:	e8 c1 70 ff ff       	call   801003f4 <cprintf>
80109333:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109336:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109339:	89 d0                	mov    %edx,%eax
8010933b:	c1 e0 02             	shl    $0x2,%eax
8010933e:	01 d0                	add    %edx,%eax
80109340:	01 c0                	add    %eax,%eax
80109342:	01 d0                	add    %edx,%eax
80109344:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109349:	83 ec 0c             	sub    $0xc,%esp
8010934c:	50                   	push   %eax
8010934d:	e8 54 02 00 00       	call   801095a6 <print_ipv4>
80109352:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109355:	83 ec 0c             	sub    $0xc,%esp
80109358:	68 3e c3 10 80       	push   $0x8010c33e
8010935d:	e8 92 70 ff ff       	call   801003f4 <cprintf>
80109362:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109365:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109368:	89 d0                	mov    %edx,%eax
8010936a:	c1 e0 02             	shl    $0x2,%eax
8010936d:	01 d0                	add    %edx,%eax
8010936f:	01 c0                	add    %eax,%eax
80109371:	01 d0                	add    %edx,%eax
80109373:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109378:	83 c0 04             	add    $0x4,%eax
8010937b:	83 ec 0c             	sub    $0xc,%esp
8010937e:	50                   	push   %eax
8010937f:	e8 70 02 00 00       	call   801095f4 <print_mac>
80109384:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109387:	83 ec 0c             	sub    $0xc,%esp
8010938a:	68 40 c3 10 80       	push   $0x8010c340
8010938f:	e8 60 70 ff ff       	call   801003f4 <cprintf>
80109394:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109397:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010939b:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010939f:	0f 8e 64 ff ff ff    	jle    80109309 <print_arp_table+0x12>
    }
  }
}
801093a5:	90                   	nop
801093a6:	90                   	nop
801093a7:	c9                   	leave  
801093a8:	c3                   	ret    

801093a9 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801093a9:	55                   	push   %ebp
801093aa:	89 e5                	mov    %esp,%ebp
801093ac:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801093af:	8b 45 10             	mov    0x10(%ebp),%eax
801093b2:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801093b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801093bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801093be:	8b 45 0c             	mov    0xc(%ebp),%eax
801093c1:	83 c0 0e             	add    $0xe,%eax
801093c4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801093c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ca:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801093ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d1:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801093d5:	8b 45 08             	mov    0x8(%ebp),%eax
801093d8:	8d 50 08             	lea    0x8(%eax),%edx
801093db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093de:	83 ec 04             	sub    $0x4,%esp
801093e1:	6a 06                	push   $0x6
801093e3:	52                   	push   %edx
801093e4:	50                   	push   %eax
801093e5:	e8 a7 b7 ff ff       	call   80104b91 <memmove>
801093ea:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801093ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f0:	83 c0 06             	add    $0x6,%eax
801093f3:	83 ec 04             	sub    $0x4,%esp
801093f6:	6a 06                	push   $0x6
801093f8:	68 80 6c 19 80       	push   $0x80196c80
801093fd:	50                   	push   %eax
801093fe:	e8 8e b7 ff ff       	call   80104b91 <memmove>
80109403:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109406:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109409:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010940e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109411:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010941a:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010941e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109421:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109428:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010942e:	8b 45 08             	mov    0x8(%ebp),%eax
80109431:	8d 50 08             	lea    0x8(%eax),%edx
80109434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109437:	83 c0 12             	add    $0x12,%eax
8010943a:	83 ec 04             	sub    $0x4,%esp
8010943d:	6a 06                	push   $0x6
8010943f:	52                   	push   %edx
80109440:	50                   	push   %eax
80109441:	e8 4b b7 ff ff       	call   80104b91 <memmove>
80109446:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109449:	8b 45 08             	mov    0x8(%ebp),%eax
8010944c:	8d 50 0e             	lea    0xe(%eax),%edx
8010944f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109452:	83 c0 18             	add    $0x18,%eax
80109455:	83 ec 04             	sub    $0x4,%esp
80109458:	6a 04                	push   $0x4
8010945a:	52                   	push   %edx
8010945b:	50                   	push   %eax
8010945c:	e8 30 b7 ff ff       	call   80104b91 <memmove>
80109461:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109464:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109467:	83 c0 08             	add    $0x8,%eax
8010946a:	83 ec 04             	sub    $0x4,%esp
8010946d:	6a 06                	push   $0x6
8010946f:	68 80 6c 19 80       	push   $0x80196c80
80109474:	50                   	push   %eax
80109475:	e8 17 b7 ff ff       	call   80104b91 <memmove>
8010947a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010947d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109480:	83 c0 0e             	add    $0xe,%eax
80109483:	83 ec 04             	sub    $0x4,%esp
80109486:	6a 04                	push   $0x4
80109488:	68 e4 f4 10 80       	push   $0x8010f4e4
8010948d:	50                   	push   %eax
8010948e:	e8 fe b6 ff ff       	call   80104b91 <memmove>
80109493:	83 c4 10             	add    $0x10,%esp
}
80109496:	90                   	nop
80109497:	c9                   	leave  
80109498:	c3                   	ret    

80109499 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109499:	55                   	push   %ebp
8010949a:	89 e5                	mov    %esp,%ebp
8010949c:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010949f:	83 ec 0c             	sub    $0xc,%esp
801094a2:	68 42 c3 10 80       	push   $0x8010c342
801094a7:	e8 48 6f ff ff       	call   801003f4 <cprintf>
801094ac:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801094af:	8b 45 08             	mov    0x8(%ebp),%eax
801094b2:	83 c0 0e             	add    $0xe,%eax
801094b5:	83 ec 0c             	sub    $0xc,%esp
801094b8:	50                   	push   %eax
801094b9:	e8 e8 00 00 00       	call   801095a6 <print_ipv4>
801094be:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094c1:	83 ec 0c             	sub    $0xc,%esp
801094c4:	68 40 c3 10 80       	push   $0x8010c340
801094c9:	e8 26 6f ff ff       	call   801003f4 <cprintf>
801094ce:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801094d1:	8b 45 08             	mov    0x8(%ebp),%eax
801094d4:	83 c0 08             	add    $0x8,%eax
801094d7:	83 ec 0c             	sub    $0xc,%esp
801094da:	50                   	push   %eax
801094db:	e8 14 01 00 00       	call   801095f4 <print_mac>
801094e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094e3:	83 ec 0c             	sub    $0xc,%esp
801094e6:	68 40 c3 10 80       	push   $0x8010c340
801094eb:	e8 04 6f ff ff       	call   801003f4 <cprintf>
801094f0:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801094f3:	83 ec 0c             	sub    $0xc,%esp
801094f6:	68 59 c3 10 80       	push   $0x8010c359
801094fb:	e8 f4 6e ff ff       	call   801003f4 <cprintf>
80109500:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109503:	8b 45 08             	mov    0x8(%ebp),%eax
80109506:	83 c0 18             	add    $0x18,%eax
80109509:	83 ec 0c             	sub    $0xc,%esp
8010950c:	50                   	push   %eax
8010950d:	e8 94 00 00 00       	call   801095a6 <print_ipv4>
80109512:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109515:	83 ec 0c             	sub    $0xc,%esp
80109518:	68 40 c3 10 80       	push   $0x8010c340
8010951d:	e8 d2 6e ff ff       	call   801003f4 <cprintf>
80109522:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109525:	8b 45 08             	mov    0x8(%ebp),%eax
80109528:	83 c0 12             	add    $0x12,%eax
8010952b:	83 ec 0c             	sub    $0xc,%esp
8010952e:	50                   	push   %eax
8010952f:	e8 c0 00 00 00       	call   801095f4 <print_mac>
80109534:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109537:	83 ec 0c             	sub    $0xc,%esp
8010953a:	68 40 c3 10 80       	push   $0x8010c340
8010953f:	e8 b0 6e ff ff       	call   801003f4 <cprintf>
80109544:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109547:	83 ec 0c             	sub    $0xc,%esp
8010954a:	68 70 c3 10 80       	push   $0x8010c370
8010954f:	e8 a0 6e ff ff       	call   801003f4 <cprintf>
80109554:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109557:	8b 45 08             	mov    0x8(%ebp),%eax
8010955a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010955e:	66 3d 00 01          	cmp    $0x100,%ax
80109562:	75 12                	jne    80109576 <print_arp_info+0xdd>
80109564:	83 ec 0c             	sub    $0xc,%esp
80109567:	68 7c c3 10 80       	push   $0x8010c37c
8010956c:	e8 83 6e ff ff       	call   801003f4 <cprintf>
80109571:	83 c4 10             	add    $0x10,%esp
80109574:	eb 1d                	jmp    80109593 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109576:	8b 45 08             	mov    0x8(%ebp),%eax
80109579:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010957d:	66 3d 00 02          	cmp    $0x200,%ax
80109581:	75 10                	jne    80109593 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109583:	83 ec 0c             	sub    $0xc,%esp
80109586:	68 85 c3 10 80       	push   $0x8010c385
8010958b:	e8 64 6e ff ff       	call   801003f4 <cprintf>
80109590:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109593:	83 ec 0c             	sub    $0xc,%esp
80109596:	68 40 c3 10 80       	push   $0x8010c340
8010959b:	e8 54 6e ff ff       	call   801003f4 <cprintf>
801095a0:	83 c4 10             	add    $0x10,%esp
}
801095a3:	90                   	nop
801095a4:	c9                   	leave  
801095a5:	c3                   	ret    

801095a6 <print_ipv4>:

void print_ipv4(uchar *ip){
801095a6:	55                   	push   %ebp
801095a7:	89 e5                	mov    %esp,%ebp
801095a9:	53                   	push   %ebx
801095aa:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801095ad:	8b 45 08             	mov    0x8(%ebp),%eax
801095b0:	83 c0 03             	add    $0x3,%eax
801095b3:	0f b6 00             	movzbl (%eax),%eax
801095b6:	0f b6 d8             	movzbl %al,%ebx
801095b9:	8b 45 08             	mov    0x8(%ebp),%eax
801095bc:	83 c0 02             	add    $0x2,%eax
801095bf:	0f b6 00             	movzbl (%eax),%eax
801095c2:	0f b6 c8             	movzbl %al,%ecx
801095c5:	8b 45 08             	mov    0x8(%ebp),%eax
801095c8:	83 c0 01             	add    $0x1,%eax
801095cb:	0f b6 00             	movzbl (%eax),%eax
801095ce:	0f b6 d0             	movzbl %al,%edx
801095d1:	8b 45 08             	mov    0x8(%ebp),%eax
801095d4:	0f b6 00             	movzbl (%eax),%eax
801095d7:	0f b6 c0             	movzbl %al,%eax
801095da:	83 ec 0c             	sub    $0xc,%esp
801095dd:	53                   	push   %ebx
801095de:	51                   	push   %ecx
801095df:	52                   	push   %edx
801095e0:	50                   	push   %eax
801095e1:	68 8c c3 10 80       	push   $0x8010c38c
801095e6:	e8 09 6e ff ff       	call   801003f4 <cprintf>
801095eb:	83 c4 20             	add    $0x20,%esp
}
801095ee:	90                   	nop
801095ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801095f2:	c9                   	leave  
801095f3:	c3                   	ret    

801095f4 <print_mac>:

void print_mac(uchar *mac){
801095f4:	55                   	push   %ebp
801095f5:	89 e5                	mov    %esp,%ebp
801095f7:	57                   	push   %edi
801095f8:	56                   	push   %esi
801095f9:	53                   	push   %ebx
801095fa:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801095fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109600:	83 c0 05             	add    $0x5,%eax
80109603:	0f b6 00             	movzbl (%eax),%eax
80109606:	0f b6 f8             	movzbl %al,%edi
80109609:	8b 45 08             	mov    0x8(%ebp),%eax
8010960c:	83 c0 04             	add    $0x4,%eax
8010960f:	0f b6 00             	movzbl (%eax),%eax
80109612:	0f b6 f0             	movzbl %al,%esi
80109615:	8b 45 08             	mov    0x8(%ebp),%eax
80109618:	83 c0 03             	add    $0x3,%eax
8010961b:	0f b6 00             	movzbl (%eax),%eax
8010961e:	0f b6 d8             	movzbl %al,%ebx
80109621:	8b 45 08             	mov    0x8(%ebp),%eax
80109624:	83 c0 02             	add    $0x2,%eax
80109627:	0f b6 00             	movzbl (%eax),%eax
8010962a:	0f b6 c8             	movzbl %al,%ecx
8010962d:	8b 45 08             	mov    0x8(%ebp),%eax
80109630:	83 c0 01             	add    $0x1,%eax
80109633:	0f b6 00             	movzbl (%eax),%eax
80109636:	0f b6 d0             	movzbl %al,%edx
80109639:	8b 45 08             	mov    0x8(%ebp),%eax
8010963c:	0f b6 00             	movzbl (%eax),%eax
8010963f:	0f b6 c0             	movzbl %al,%eax
80109642:	83 ec 04             	sub    $0x4,%esp
80109645:	57                   	push   %edi
80109646:	56                   	push   %esi
80109647:	53                   	push   %ebx
80109648:	51                   	push   %ecx
80109649:	52                   	push   %edx
8010964a:	50                   	push   %eax
8010964b:	68 a4 c3 10 80       	push   $0x8010c3a4
80109650:	e8 9f 6d ff ff       	call   801003f4 <cprintf>
80109655:	83 c4 20             	add    $0x20,%esp
}
80109658:	90                   	nop
80109659:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010965c:	5b                   	pop    %ebx
8010965d:	5e                   	pop    %esi
8010965e:	5f                   	pop    %edi
8010965f:	5d                   	pop    %ebp
80109660:	c3                   	ret    

80109661 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109661:	55                   	push   %ebp
80109662:	89 e5                	mov    %esp,%ebp
80109664:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109667:	8b 45 08             	mov    0x8(%ebp),%eax
8010966a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010966d:	8b 45 08             	mov    0x8(%ebp),%eax
80109670:	83 c0 0e             	add    $0xe,%eax
80109673:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109679:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010967d:	3c 08                	cmp    $0x8,%al
8010967f:	75 1b                	jne    8010969c <eth_proc+0x3b>
80109681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109684:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109688:	3c 06                	cmp    $0x6,%al
8010968a:	75 10                	jne    8010969c <eth_proc+0x3b>
    arp_proc(pkt_addr);
8010968c:	83 ec 0c             	sub    $0xc,%esp
8010968f:	ff 75 f0             	push   -0x10(%ebp)
80109692:	e8 01 f8 ff ff       	call   80108e98 <arp_proc>
80109697:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010969a:	eb 24                	jmp    801096c0 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010969c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010969f:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801096a3:	3c 08                	cmp    $0x8,%al
801096a5:	75 19                	jne    801096c0 <eth_proc+0x5f>
801096a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096aa:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801096ae:	84 c0                	test   %al,%al
801096b0:	75 0e                	jne    801096c0 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801096b2:	83 ec 0c             	sub    $0xc,%esp
801096b5:	ff 75 08             	push   0x8(%ebp)
801096b8:	e8 a3 00 00 00       	call   80109760 <ipv4_proc>
801096bd:	83 c4 10             	add    $0x10,%esp
}
801096c0:	90                   	nop
801096c1:	c9                   	leave  
801096c2:	c3                   	ret    

801096c3 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801096c3:	55                   	push   %ebp
801096c4:	89 e5                	mov    %esp,%ebp
801096c6:	83 ec 04             	sub    $0x4,%esp
801096c9:	8b 45 08             	mov    0x8(%ebp),%eax
801096cc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801096d0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096d4:	c1 e0 08             	shl    $0x8,%eax
801096d7:	89 c2                	mov    %eax,%edx
801096d9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096dd:	66 c1 e8 08          	shr    $0x8,%ax
801096e1:	01 d0                	add    %edx,%eax
}
801096e3:	c9                   	leave  
801096e4:	c3                   	ret    

801096e5 <H2N_ushort>:

ushort H2N_ushort(ushort value){
801096e5:	55                   	push   %ebp
801096e6:	89 e5                	mov    %esp,%ebp
801096e8:	83 ec 04             	sub    $0x4,%esp
801096eb:	8b 45 08             	mov    0x8(%ebp),%eax
801096ee:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801096f2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096f6:	c1 e0 08             	shl    $0x8,%eax
801096f9:	89 c2                	mov    %eax,%edx
801096fb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096ff:	66 c1 e8 08          	shr    $0x8,%ax
80109703:	01 d0                	add    %edx,%eax
}
80109705:	c9                   	leave  
80109706:	c3                   	ret    

80109707 <H2N_uint>:

uint H2N_uint(uint value){
80109707:	55                   	push   %ebp
80109708:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010970a:	8b 45 08             	mov    0x8(%ebp),%eax
8010970d:	c1 e0 18             	shl    $0x18,%eax
80109710:	25 00 00 00 0f       	and    $0xf000000,%eax
80109715:	89 c2                	mov    %eax,%edx
80109717:	8b 45 08             	mov    0x8(%ebp),%eax
8010971a:	c1 e0 08             	shl    $0x8,%eax
8010971d:	25 00 f0 00 00       	and    $0xf000,%eax
80109722:	09 c2                	or     %eax,%edx
80109724:	8b 45 08             	mov    0x8(%ebp),%eax
80109727:	c1 e8 08             	shr    $0x8,%eax
8010972a:	83 e0 0f             	and    $0xf,%eax
8010972d:	01 d0                	add    %edx,%eax
}
8010972f:	5d                   	pop    %ebp
80109730:	c3                   	ret    

80109731 <N2H_uint>:

uint N2H_uint(uint value){
80109731:	55                   	push   %ebp
80109732:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109734:	8b 45 08             	mov    0x8(%ebp),%eax
80109737:	c1 e0 18             	shl    $0x18,%eax
8010973a:	89 c2                	mov    %eax,%edx
8010973c:	8b 45 08             	mov    0x8(%ebp),%eax
8010973f:	c1 e0 08             	shl    $0x8,%eax
80109742:	25 00 00 ff 00       	and    $0xff0000,%eax
80109747:	01 c2                	add    %eax,%edx
80109749:	8b 45 08             	mov    0x8(%ebp),%eax
8010974c:	c1 e8 08             	shr    $0x8,%eax
8010974f:	25 00 ff 00 00       	and    $0xff00,%eax
80109754:	01 c2                	add    %eax,%edx
80109756:	8b 45 08             	mov    0x8(%ebp),%eax
80109759:	c1 e8 18             	shr    $0x18,%eax
8010975c:	01 d0                	add    %edx,%eax
}
8010975e:	5d                   	pop    %ebp
8010975f:	c3                   	ret    

80109760 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109760:	55                   	push   %ebp
80109761:	89 e5                	mov    %esp,%ebp
80109763:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109766:	8b 45 08             	mov    0x8(%ebp),%eax
80109769:	83 c0 0e             	add    $0xe,%eax
8010976c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010976f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109772:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109776:	0f b7 d0             	movzwl %ax,%edx
80109779:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
8010977e:	39 c2                	cmp    %eax,%edx
80109780:	74 60                	je     801097e2 <ipv4_proc+0x82>
80109782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109785:	83 c0 0c             	add    $0xc,%eax
80109788:	83 ec 04             	sub    $0x4,%esp
8010978b:	6a 04                	push   $0x4
8010978d:	50                   	push   %eax
8010978e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109793:	e8 a1 b3 ff ff       	call   80104b39 <memcmp>
80109798:	83 c4 10             	add    $0x10,%esp
8010979b:	85 c0                	test   %eax,%eax
8010979d:	74 43                	je     801097e2 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
8010979f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801097a6:	0f b7 c0             	movzwl %ax,%eax
801097a9:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801097ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b1:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801097b5:	3c 01                	cmp    $0x1,%al
801097b7:	75 10                	jne    801097c9 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801097b9:	83 ec 0c             	sub    $0xc,%esp
801097bc:	ff 75 08             	push   0x8(%ebp)
801097bf:	e8 a3 00 00 00       	call   80109867 <icmp_proc>
801097c4:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801097c7:	eb 19                	jmp    801097e2 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801097c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097cc:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801097d0:	3c 06                	cmp    $0x6,%al
801097d2:	75 0e                	jne    801097e2 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801097d4:	83 ec 0c             	sub    $0xc,%esp
801097d7:	ff 75 08             	push   0x8(%ebp)
801097da:	e8 b3 03 00 00       	call   80109b92 <tcp_proc>
801097df:	83 c4 10             	add    $0x10,%esp
}
801097e2:	90                   	nop
801097e3:	c9                   	leave  
801097e4:	c3                   	ret    

801097e5 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801097e5:	55                   	push   %ebp
801097e6:	89 e5                	mov    %esp,%ebp
801097e8:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801097eb:	8b 45 08             	mov    0x8(%ebp),%eax
801097ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801097f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f4:	0f b6 00             	movzbl (%eax),%eax
801097f7:	83 e0 0f             	and    $0xf,%eax
801097fa:	01 c0                	add    %eax,%eax
801097fc:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
801097ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109806:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010980d:	eb 48                	jmp    80109857 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010980f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109812:	01 c0                	add    %eax,%eax
80109814:	89 c2                	mov    %eax,%edx
80109816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109819:	01 d0                	add    %edx,%eax
8010981b:	0f b6 00             	movzbl (%eax),%eax
8010981e:	0f b6 c0             	movzbl %al,%eax
80109821:	c1 e0 08             	shl    $0x8,%eax
80109824:	89 c2                	mov    %eax,%edx
80109826:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109829:	01 c0                	add    %eax,%eax
8010982b:	8d 48 01             	lea    0x1(%eax),%ecx
8010982e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109831:	01 c8                	add    %ecx,%eax
80109833:	0f b6 00             	movzbl (%eax),%eax
80109836:	0f b6 c0             	movzbl %al,%eax
80109839:	01 d0                	add    %edx,%eax
8010983b:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010983e:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109845:	76 0c                	jbe    80109853 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109847:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010984a:	0f b7 c0             	movzwl %ax,%eax
8010984d:	83 c0 01             	add    $0x1,%eax
80109850:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109853:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109857:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010985b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010985e:	7c af                	jl     8010980f <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109860:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109863:	f7 d0                	not    %eax
}
80109865:	c9                   	leave  
80109866:	c3                   	ret    

80109867 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109867:	55                   	push   %ebp
80109868:	89 e5                	mov    %esp,%ebp
8010986a:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010986d:	8b 45 08             	mov    0x8(%ebp),%eax
80109870:	83 c0 0e             	add    $0xe,%eax
80109873:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109879:	0f b6 00             	movzbl (%eax),%eax
8010987c:	0f b6 c0             	movzbl %al,%eax
8010987f:	83 e0 0f             	and    $0xf,%eax
80109882:	c1 e0 02             	shl    $0x2,%eax
80109885:	89 c2                	mov    %eax,%edx
80109887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010988a:	01 d0                	add    %edx,%eax
8010988c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010988f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109892:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109896:	84 c0                	test   %al,%al
80109898:	75 4f                	jne    801098e9 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010989a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010989d:	0f b6 00             	movzbl (%eax),%eax
801098a0:	3c 08                	cmp    $0x8,%al
801098a2:	75 45                	jne    801098e9 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801098a4:	e8 f8 8e ff ff       	call   801027a1 <kalloc>
801098a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801098ac:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801098b3:	83 ec 04             	sub    $0x4,%esp
801098b6:	8d 45 e8             	lea    -0x18(%ebp),%eax
801098b9:	50                   	push   %eax
801098ba:	ff 75 ec             	push   -0x14(%ebp)
801098bd:	ff 75 08             	push   0x8(%ebp)
801098c0:	e8 78 00 00 00       	call   8010993d <icmp_reply_pkt_create>
801098c5:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801098c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098cb:	83 ec 08             	sub    $0x8,%esp
801098ce:	50                   	push   %eax
801098cf:	ff 75 ec             	push   -0x14(%ebp)
801098d2:	e8 95 f4 ff ff       	call   80108d6c <i8254_send>
801098d7:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
801098da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098dd:	83 ec 0c             	sub    $0xc,%esp
801098e0:	50                   	push   %eax
801098e1:	e8 21 8e ff ff       	call   80102707 <kfree>
801098e6:	83 c4 10             	add    $0x10,%esp
    }
  }
}
801098e9:	90                   	nop
801098ea:	c9                   	leave  
801098eb:	c3                   	ret    

801098ec <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
801098ec:	55                   	push   %ebp
801098ed:	89 e5                	mov    %esp,%ebp
801098ef:	53                   	push   %ebx
801098f0:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
801098f3:	8b 45 08             	mov    0x8(%ebp),%eax
801098f6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098fa:	0f b7 c0             	movzwl %ax,%eax
801098fd:	83 ec 0c             	sub    $0xc,%esp
80109900:	50                   	push   %eax
80109901:	e8 bd fd ff ff       	call   801096c3 <N2H_ushort>
80109906:	83 c4 10             	add    $0x10,%esp
80109909:	0f b7 d8             	movzwl %ax,%ebx
8010990c:	8b 45 08             	mov    0x8(%ebp),%eax
8010990f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109913:	0f b7 c0             	movzwl %ax,%eax
80109916:	83 ec 0c             	sub    $0xc,%esp
80109919:	50                   	push   %eax
8010991a:	e8 a4 fd ff ff       	call   801096c3 <N2H_ushort>
8010991f:	83 c4 10             	add    $0x10,%esp
80109922:	0f b7 c0             	movzwl %ax,%eax
80109925:	83 ec 04             	sub    $0x4,%esp
80109928:	53                   	push   %ebx
80109929:	50                   	push   %eax
8010992a:	68 c3 c3 10 80       	push   $0x8010c3c3
8010992f:	e8 c0 6a ff ff       	call   801003f4 <cprintf>
80109934:	83 c4 10             	add    $0x10,%esp
}
80109937:	90                   	nop
80109938:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010993b:	c9                   	leave  
8010993c:	c3                   	ret    

8010993d <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010993d:	55                   	push   %ebp
8010993e:	89 e5                	mov    %esp,%ebp
80109940:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109943:	8b 45 08             	mov    0x8(%ebp),%eax
80109946:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109949:	8b 45 08             	mov    0x8(%ebp),%eax
8010994c:	83 c0 0e             	add    $0xe,%eax
8010994f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109952:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109955:	0f b6 00             	movzbl (%eax),%eax
80109958:	0f b6 c0             	movzbl %al,%eax
8010995b:	83 e0 0f             	and    $0xf,%eax
8010995e:	c1 e0 02             	shl    $0x2,%eax
80109961:	89 c2                	mov    %eax,%edx
80109963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109966:	01 d0                	add    %edx,%eax
80109968:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010996b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010996e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109971:	8b 45 0c             	mov    0xc(%ebp),%eax
80109974:	83 c0 0e             	add    $0xe,%eax
80109977:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010997a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010997d:	83 c0 14             	add    $0x14,%eax
80109980:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109983:	8b 45 10             	mov    0x10(%ebp),%eax
80109986:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010998c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010998f:	8d 50 06             	lea    0x6(%eax),%edx
80109992:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109995:	83 ec 04             	sub    $0x4,%esp
80109998:	6a 06                	push   $0x6
8010999a:	52                   	push   %edx
8010999b:	50                   	push   %eax
8010999c:	e8 f0 b1 ff ff       	call   80104b91 <memmove>
801099a1:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801099a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099a7:	83 c0 06             	add    $0x6,%eax
801099aa:	83 ec 04             	sub    $0x4,%esp
801099ad:	6a 06                	push   $0x6
801099af:	68 80 6c 19 80       	push   $0x80196c80
801099b4:	50                   	push   %eax
801099b5:	e8 d7 b1 ff ff       	call   80104b91 <memmove>
801099ba:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801099bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099c0:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801099c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099c7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
801099cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099ce:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
801099d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099d4:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
801099d8:	83 ec 0c             	sub    $0xc,%esp
801099db:	6a 54                	push   $0x54
801099dd:	e8 03 fd ff ff       	call   801096e5 <H2N_ushort>
801099e2:	83 c4 10             	add    $0x10,%esp
801099e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801099e8:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
801099ec:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
801099f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099f6:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
801099fa:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109a01:	83 c0 01             	add    $0x1,%eax
80109a04:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109a0a:	83 ec 0c             	sub    $0xc,%esp
80109a0d:	68 00 40 00 00       	push   $0x4000
80109a12:	e8 ce fc ff ff       	call   801096e5 <H2N_ushort>
80109a17:	83 c4 10             	add    $0x10,%esp
80109a1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109a1d:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a24:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109a28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a2b:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109a2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a32:	83 c0 0c             	add    $0xc,%eax
80109a35:	83 ec 04             	sub    $0x4,%esp
80109a38:	6a 04                	push   $0x4
80109a3a:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a3f:	50                   	push   %eax
80109a40:	e8 4c b1 ff ff       	call   80104b91 <memmove>
80109a45:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a4b:	8d 50 0c             	lea    0xc(%eax),%edx
80109a4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a51:	83 c0 10             	add    $0x10,%eax
80109a54:	83 ec 04             	sub    $0x4,%esp
80109a57:	6a 04                	push   $0x4
80109a59:	52                   	push   %edx
80109a5a:	50                   	push   %eax
80109a5b:	e8 31 b1 ff ff       	call   80104b91 <memmove>
80109a60:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109a63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a66:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a6f:	83 ec 0c             	sub    $0xc,%esp
80109a72:	50                   	push   %eax
80109a73:	e8 6d fd ff ff       	call   801097e5 <ipv4_chksum>
80109a78:	83 c4 10             	add    $0x10,%esp
80109a7b:	0f b7 c0             	movzwl %ax,%eax
80109a7e:	83 ec 0c             	sub    $0xc,%esp
80109a81:	50                   	push   %eax
80109a82:	e8 5e fc ff ff       	call   801096e5 <H2N_ushort>
80109a87:	83 c4 10             	add    $0x10,%esp
80109a8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109a8d:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109a91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a94:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109a97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a9a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109a9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109aa1:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109aa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109aa8:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109aac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109aaf:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109ab3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ab6:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109aba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109abd:	8d 50 08             	lea    0x8(%eax),%edx
80109ac0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ac3:	83 c0 08             	add    $0x8,%eax
80109ac6:	83 ec 04             	sub    $0x4,%esp
80109ac9:	6a 08                	push   $0x8
80109acb:	52                   	push   %edx
80109acc:	50                   	push   %eax
80109acd:	e8 bf b0 ff ff       	call   80104b91 <memmove>
80109ad2:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109ad5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ad8:	8d 50 10             	lea    0x10(%eax),%edx
80109adb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ade:	83 c0 10             	add    $0x10,%eax
80109ae1:	83 ec 04             	sub    $0x4,%esp
80109ae4:	6a 30                	push   $0x30
80109ae6:	52                   	push   %edx
80109ae7:	50                   	push   %eax
80109ae8:	e8 a4 b0 ff ff       	call   80104b91 <memmove>
80109aed:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109af3:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109af9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109afc:	83 ec 0c             	sub    $0xc,%esp
80109aff:	50                   	push   %eax
80109b00:	e8 1c 00 00 00       	call   80109b21 <icmp_chksum>
80109b05:	83 c4 10             	add    $0x10,%esp
80109b08:	0f b7 c0             	movzwl %ax,%eax
80109b0b:	83 ec 0c             	sub    $0xc,%esp
80109b0e:	50                   	push   %eax
80109b0f:	e8 d1 fb ff ff       	call   801096e5 <H2N_ushort>
80109b14:	83 c4 10             	add    $0x10,%esp
80109b17:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109b1a:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109b1e:	90                   	nop
80109b1f:	c9                   	leave  
80109b20:	c3                   	ret    

80109b21 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109b21:	55                   	push   %ebp
80109b22:	89 e5                	mov    %esp,%ebp
80109b24:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109b27:	8b 45 08             	mov    0x8(%ebp),%eax
80109b2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109b2d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109b34:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109b3b:	eb 48                	jmp    80109b85 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b40:	01 c0                	add    %eax,%eax
80109b42:	89 c2                	mov    %eax,%edx
80109b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b47:	01 d0                	add    %edx,%eax
80109b49:	0f b6 00             	movzbl (%eax),%eax
80109b4c:	0f b6 c0             	movzbl %al,%eax
80109b4f:	c1 e0 08             	shl    $0x8,%eax
80109b52:	89 c2                	mov    %eax,%edx
80109b54:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b57:	01 c0                	add    %eax,%eax
80109b59:	8d 48 01             	lea    0x1(%eax),%ecx
80109b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b5f:	01 c8                	add    %ecx,%eax
80109b61:	0f b6 00             	movzbl (%eax),%eax
80109b64:	0f b6 c0             	movzbl %al,%eax
80109b67:	01 d0                	add    %edx,%eax
80109b69:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109b6c:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109b73:	76 0c                	jbe    80109b81 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109b75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b78:	0f b7 c0             	movzwl %ax,%eax
80109b7b:	83 c0 01             	add    $0x1,%eax
80109b7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109b81:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b85:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109b89:	7e b2                	jle    80109b3d <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109b8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b8e:	f7 d0                	not    %eax
}
80109b90:	c9                   	leave  
80109b91:	c3                   	ret    

80109b92 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109b92:	55                   	push   %ebp
80109b93:	89 e5                	mov    %esp,%ebp
80109b95:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109b98:	8b 45 08             	mov    0x8(%ebp),%eax
80109b9b:	83 c0 0e             	add    $0xe,%eax
80109b9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ba4:	0f b6 00             	movzbl (%eax),%eax
80109ba7:	0f b6 c0             	movzbl %al,%eax
80109baa:	83 e0 0f             	and    $0xf,%eax
80109bad:	c1 e0 02             	shl    $0x2,%eax
80109bb0:	89 c2                	mov    %eax,%edx
80109bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bb5:	01 d0                	add    %edx,%eax
80109bb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bbd:	83 c0 14             	add    $0x14,%eax
80109bc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109bc3:	e8 d9 8b ff ff       	call   801027a1 <kalloc>
80109bc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109bcb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109bd9:	0f b6 c0             	movzbl %al,%eax
80109bdc:	83 e0 02             	and    $0x2,%eax
80109bdf:	85 c0                	test   %eax,%eax
80109be1:	74 3d                	je     80109c20 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109be3:	83 ec 0c             	sub    $0xc,%esp
80109be6:	6a 00                	push   $0x0
80109be8:	6a 12                	push   $0x12
80109bea:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109bed:	50                   	push   %eax
80109bee:	ff 75 e8             	push   -0x18(%ebp)
80109bf1:	ff 75 08             	push   0x8(%ebp)
80109bf4:	e8 a2 01 00 00       	call   80109d9b <tcp_pkt_create>
80109bf9:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109bfc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109bff:	83 ec 08             	sub    $0x8,%esp
80109c02:	50                   	push   %eax
80109c03:	ff 75 e8             	push   -0x18(%ebp)
80109c06:	e8 61 f1 ff ff       	call   80108d6c <i8254_send>
80109c0b:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109c0e:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109c13:	83 c0 01             	add    $0x1,%eax
80109c16:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109c1b:	e9 69 01 00 00       	jmp    80109d89 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c23:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c27:	3c 18                	cmp    $0x18,%al
80109c29:	0f 85 10 01 00 00    	jne    80109d3f <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109c2f:	83 ec 04             	sub    $0x4,%esp
80109c32:	6a 03                	push   $0x3
80109c34:	68 de c3 10 80       	push   $0x8010c3de
80109c39:	ff 75 ec             	push   -0x14(%ebp)
80109c3c:	e8 f8 ae ff ff       	call   80104b39 <memcmp>
80109c41:	83 c4 10             	add    $0x10,%esp
80109c44:	85 c0                	test   %eax,%eax
80109c46:	74 74                	je     80109cbc <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109c48:	83 ec 0c             	sub    $0xc,%esp
80109c4b:	68 e2 c3 10 80       	push   $0x8010c3e2
80109c50:	e8 9f 67 ff ff       	call   801003f4 <cprintf>
80109c55:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109c58:	83 ec 0c             	sub    $0xc,%esp
80109c5b:	6a 00                	push   $0x0
80109c5d:	6a 10                	push   $0x10
80109c5f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c62:	50                   	push   %eax
80109c63:	ff 75 e8             	push   -0x18(%ebp)
80109c66:	ff 75 08             	push   0x8(%ebp)
80109c69:	e8 2d 01 00 00       	call   80109d9b <tcp_pkt_create>
80109c6e:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109c71:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c74:	83 ec 08             	sub    $0x8,%esp
80109c77:	50                   	push   %eax
80109c78:	ff 75 e8             	push   -0x18(%ebp)
80109c7b:	e8 ec f0 ff ff       	call   80108d6c <i8254_send>
80109c80:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109c83:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c86:	83 c0 36             	add    $0x36,%eax
80109c89:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109c8c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109c8f:	50                   	push   %eax
80109c90:	ff 75 e0             	push   -0x20(%ebp)
80109c93:	6a 00                	push   $0x0
80109c95:	6a 00                	push   $0x0
80109c97:	e8 5a 04 00 00       	call   8010a0f6 <http_proc>
80109c9c:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109c9f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ca2:	83 ec 0c             	sub    $0xc,%esp
80109ca5:	50                   	push   %eax
80109ca6:	6a 18                	push   $0x18
80109ca8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109cab:	50                   	push   %eax
80109cac:	ff 75 e8             	push   -0x18(%ebp)
80109caf:	ff 75 08             	push   0x8(%ebp)
80109cb2:	e8 e4 00 00 00       	call   80109d9b <tcp_pkt_create>
80109cb7:	83 c4 20             	add    $0x20,%esp
80109cba:	eb 62                	jmp    80109d1e <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109cbc:	83 ec 0c             	sub    $0xc,%esp
80109cbf:	6a 00                	push   $0x0
80109cc1:	6a 10                	push   $0x10
80109cc3:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109cc6:	50                   	push   %eax
80109cc7:	ff 75 e8             	push   -0x18(%ebp)
80109cca:	ff 75 08             	push   0x8(%ebp)
80109ccd:	e8 c9 00 00 00       	call   80109d9b <tcp_pkt_create>
80109cd2:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109cd5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109cd8:	83 ec 08             	sub    $0x8,%esp
80109cdb:	50                   	push   %eax
80109cdc:	ff 75 e8             	push   -0x18(%ebp)
80109cdf:	e8 88 f0 ff ff       	call   80108d6c <i8254_send>
80109ce4:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109ce7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cea:	83 c0 36             	add    $0x36,%eax
80109ced:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109cf0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109cf3:	50                   	push   %eax
80109cf4:	ff 75 e4             	push   -0x1c(%ebp)
80109cf7:	6a 00                	push   $0x0
80109cf9:	6a 00                	push   $0x0
80109cfb:	e8 f6 03 00 00       	call   8010a0f6 <http_proc>
80109d00:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109d03:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109d06:	83 ec 0c             	sub    $0xc,%esp
80109d09:	50                   	push   %eax
80109d0a:	6a 18                	push   $0x18
80109d0c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d0f:	50                   	push   %eax
80109d10:	ff 75 e8             	push   -0x18(%ebp)
80109d13:	ff 75 08             	push   0x8(%ebp)
80109d16:	e8 80 00 00 00       	call   80109d9b <tcp_pkt_create>
80109d1b:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109d1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d21:	83 ec 08             	sub    $0x8,%esp
80109d24:	50                   	push   %eax
80109d25:	ff 75 e8             	push   -0x18(%ebp)
80109d28:	e8 3f f0 ff ff       	call   80108d6c <i8254_send>
80109d2d:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109d30:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109d35:	83 c0 01             	add    $0x1,%eax
80109d38:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109d3d:	eb 4a                	jmp    80109d89 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d42:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d46:	3c 10                	cmp    $0x10,%al
80109d48:	75 3f                	jne    80109d89 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109d4a:	a1 68 6f 19 80       	mov    0x80196f68,%eax
80109d4f:	83 f8 01             	cmp    $0x1,%eax
80109d52:	75 35                	jne    80109d89 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109d54:	83 ec 0c             	sub    $0xc,%esp
80109d57:	6a 00                	push   $0x0
80109d59:	6a 01                	push   $0x1
80109d5b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d5e:	50                   	push   %eax
80109d5f:	ff 75 e8             	push   -0x18(%ebp)
80109d62:	ff 75 08             	push   0x8(%ebp)
80109d65:	e8 31 00 00 00       	call   80109d9b <tcp_pkt_create>
80109d6a:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109d6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d70:	83 ec 08             	sub    $0x8,%esp
80109d73:	50                   	push   %eax
80109d74:	ff 75 e8             	push   -0x18(%ebp)
80109d77:	e8 f0 ef ff ff       	call   80108d6c <i8254_send>
80109d7c:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109d7f:	c7 05 68 6f 19 80 00 	movl   $0x0,0x80196f68
80109d86:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109d89:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d8c:	83 ec 0c             	sub    $0xc,%esp
80109d8f:	50                   	push   %eax
80109d90:	e8 72 89 ff ff       	call   80102707 <kfree>
80109d95:	83 c4 10             	add    $0x10,%esp
}
80109d98:	90                   	nop
80109d99:	c9                   	leave  
80109d9a:	c3                   	ret    

80109d9b <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109d9b:	55                   	push   %ebp
80109d9c:	89 e5                	mov    %esp,%ebp
80109d9e:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109da1:	8b 45 08             	mov    0x8(%ebp),%eax
80109da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109da7:	8b 45 08             	mov    0x8(%ebp),%eax
80109daa:	83 c0 0e             	add    $0xe,%eax
80109dad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109db3:	0f b6 00             	movzbl (%eax),%eax
80109db6:	0f b6 c0             	movzbl %al,%eax
80109db9:	83 e0 0f             	and    $0xf,%eax
80109dbc:	c1 e0 02             	shl    $0x2,%eax
80109dbf:	89 c2                	mov    %eax,%edx
80109dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dc4:	01 d0                	add    %edx,%eax
80109dc6:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80109dcc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80109dd2:	83 c0 0e             	add    $0xe,%eax
80109dd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109dd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ddb:	83 c0 14             	add    $0x14,%eax
80109dde:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109de1:	8b 45 18             	mov    0x18(%ebp),%eax
80109de4:	8d 50 36             	lea    0x36(%eax),%edx
80109de7:	8b 45 10             	mov    0x10(%ebp),%eax
80109dea:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109def:	8d 50 06             	lea    0x6(%eax),%edx
80109df2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109df5:	83 ec 04             	sub    $0x4,%esp
80109df8:	6a 06                	push   $0x6
80109dfa:	52                   	push   %edx
80109dfb:	50                   	push   %eax
80109dfc:	e8 90 ad ff ff       	call   80104b91 <memmove>
80109e01:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109e04:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e07:	83 c0 06             	add    $0x6,%eax
80109e0a:	83 ec 04             	sub    $0x4,%esp
80109e0d:	6a 06                	push   $0x6
80109e0f:	68 80 6c 19 80       	push   $0x80196c80
80109e14:	50                   	push   %eax
80109e15:	e8 77 ad ff ff       	call   80104b91 <memmove>
80109e1a:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109e1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e20:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109e24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e27:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e2e:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e34:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109e38:	8b 45 18             	mov    0x18(%ebp),%eax
80109e3b:	83 c0 28             	add    $0x28,%eax
80109e3e:	0f b7 c0             	movzwl %ax,%eax
80109e41:	83 ec 0c             	sub    $0xc,%esp
80109e44:	50                   	push   %eax
80109e45:	e8 9b f8 ff ff       	call   801096e5 <H2N_ushort>
80109e4a:	83 c4 10             	add    $0x10,%esp
80109e4d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e50:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e54:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
80109e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e5e:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109e62:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109e69:	83 c0 01             	add    $0x1,%eax
80109e6c:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x0000);
80109e72:	83 ec 0c             	sub    $0xc,%esp
80109e75:	6a 00                	push   $0x0
80109e77:	e8 69 f8 ff ff       	call   801096e5 <H2N_ushort>
80109e7c:	83 c4 10             	add    $0x10,%esp
80109e7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e82:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e89:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e90:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e97:	83 c0 0c             	add    $0xc,%eax
80109e9a:	83 ec 04             	sub    $0x4,%esp
80109e9d:	6a 04                	push   $0x4
80109e9f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109ea4:	50                   	push   %eax
80109ea5:	e8 e7 ac ff ff       	call   80104b91 <memmove>
80109eaa:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eb0:	8d 50 0c             	lea    0xc(%eax),%edx
80109eb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109eb6:	83 c0 10             	add    $0x10,%eax
80109eb9:	83 ec 04             	sub    $0x4,%esp
80109ebc:	6a 04                	push   $0x4
80109ebe:	52                   	push   %edx
80109ebf:	50                   	push   %eax
80109ec0:	e8 cc ac ff ff       	call   80104b91 <memmove>
80109ec5:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109ec8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ecb:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109ed1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed4:	83 ec 0c             	sub    $0xc,%esp
80109ed7:	50                   	push   %eax
80109ed8:	e8 08 f9 ff ff       	call   801097e5 <ipv4_chksum>
80109edd:	83 c4 10             	add    $0x10,%esp
80109ee0:	0f b7 c0             	movzwl %ax,%eax
80109ee3:	83 ec 0c             	sub    $0xc,%esp
80109ee6:	50                   	push   %eax
80109ee7:	e8 f9 f7 ff ff       	call   801096e5 <H2N_ushort>
80109eec:	83 c4 10             	add    $0x10,%esp
80109eef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ef2:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ef9:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109efd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f00:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f06:	0f b7 10             	movzwl (%eax),%edx
80109f09:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f0c:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109f10:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109f15:	83 ec 0c             	sub    $0xc,%esp
80109f18:	50                   	push   %eax
80109f19:	e8 e9 f7 ff ff       	call   80109707 <H2N_uint>
80109f1e:	83 c4 10             	add    $0x10,%esp
80109f21:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f24:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109f27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f2a:	8b 40 04             	mov    0x4(%eax),%eax
80109f2d:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109f33:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f36:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109f39:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f3c:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109f40:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f43:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109f47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f4a:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109f4e:	8b 45 14             	mov    0x14(%ebp),%eax
80109f51:	89 c2                	mov    %eax,%edx
80109f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f56:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109f59:	83 ec 0c             	sub    $0xc,%esp
80109f5c:	68 90 38 00 00       	push   $0x3890
80109f61:	e8 7f f7 ff ff       	call   801096e5 <H2N_ushort>
80109f66:	83 c4 10             	add    $0x10,%esp
80109f69:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f6c:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109f70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f73:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109f79:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f7c:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109f82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f85:	83 ec 0c             	sub    $0xc,%esp
80109f88:	50                   	push   %eax
80109f89:	e8 1f 00 00 00       	call   80109fad <tcp_chksum>
80109f8e:	83 c4 10             	add    $0x10,%esp
80109f91:	83 c0 08             	add    $0x8,%eax
80109f94:	0f b7 c0             	movzwl %ax,%eax
80109f97:	83 ec 0c             	sub    $0xc,%esp
80109f9a:	50                   	push   %eax
80109f9b:	e8 45 f7 ff ff       	call   801096e5 <H2N_ushort>
80109fa0:	83 c4 10             	add    $0x10,%esp
80109fa3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109fa6:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109faa:	90                   	nop
80109fab:	c9                   	leave  
80109fac:	c3                   	ret    

80109fad <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109fad:	55                   	push   %ebp
80109fae:	89 e5                	mov    %esp,%ebp
80109fb0:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109fb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fbc:	83 c0 14             	add    $0x14,%eax
80109fbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109fc2:	83 ec 04             	sub    $0x4,%esp
80109fc5:	6a 04                	push   $0x4
80109fc7:	68 e4 f4 10 80       	push   $0x8010f4e4
80109fcc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109fcf:	50                   	push   %eax
80109fd0:	e8 bc ab ff ff       	call   80104b91 <memmove>
80109fd5:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109fd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fdb:	83 c0 0c             	add    $0xc,%eax
80109fde:	83 ec 04             	sub    $0x4,%esp
80109fe1:	6a 04                	push   $0x4
80109fe3:	50                   	push   %eax
80109fe4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109fe7:	83 c0 04             	add    $0x4,%eax
80109fea:	50                   	push   %eax
80109feb:	e8 a1 ab ff ff       	call   80104b91 <memmove>
80109ff0:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109ff3:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109ff7:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109ffb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ffe:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a002:	0f b7 c0             	movzwl %ax,%eax
8010a005:	83 ec 0c             	sub    $0xc,%esp
8010a008:	50                   	push   %eax
8010a009:	e8 b5 f6 ff ff       	call   801096c3 <N2H_ushort>
8010a00e:	83 c4 10             	add    $0x10,%esp
8010a011:	83 e8 14             	sub    $0x14,%eax
8010a014:	0f b7 c0             	movzwl %ax,%eax
8010a017:	83 ec 0c             	sub    $0xc,%esp
8010a01a:	50                   	push   %eax
8010a01b:	e8 c5 f6 ff ff       	call   801096e5 <H2N_ushort>
8010a020:	83 c4 10             	add    $0x10,%esp
8010a023:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a027:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a02e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a031:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a034:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a03b:	eb 33                	jmp    8010a070 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a03d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a040:	01 c0                	add    %eax,%eax
8010a042:	89 c2                	mov    %eax,%edx
8010a044:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a047:	01 d0                	add    %edx,%eax
8010a049:	0f b6 00             	movzbl (%eax),%eax
8010a04c:	0f b6 c0             	movzbl %al,%eax
8010a04f:	c1 e0 08             	shl    $0x8,%eax
8010a052:	89 c2                	mov    %eax,%edx
8010a054:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a057:	01 c0                	add    %eax,%eax
8010a059:	8d 48 01             	lea    0x1(%eax),%ecx
8010a05c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a05f:	01 c8                	add    %ecx,%eax
8010a061:	0f b6 00             	movzbl (%eax),%eax
8010a064:	0f b6 c0             	movzbl %al,%eax
8010a067:	01 d0                	add    %edx,%eax
8010a069:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a06c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a070:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a074:	7e c7                	jle    8010a03d <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a076:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a079:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a07c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a083:	eb 33                	jmp    8010a0b8 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a085:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a088:	01 c0                	add    %eax,%eax
8010a08a:	89 c2                	mov    %eax,%edx
8010a08c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a08f:	01 d0                	add    %edx,%eax
8010a091:	0f b6 00             	movzbl (%eax),%eax
8010a094:	0f b6 c0             	movzbl %al,%eax
8010a097:	c1 e0 08             	shl    $0x8,%eax
8010a09a:	89 c2                	mov    %eax,%edx
8010a09c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a09f:	01 c0                	add    %eax,%eax
8010a0a1:	8d 48 01             	lea    0x1(%eax),%ecx
8010a0a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0a7:	01 c8                	add    %ecx,%eax
8010a0a9:	0f b6 00             	movzbl (%eax),%eax
8010a0ac:	0f b6 c0             	movzbl %al,%eax
8010a0af:	01 d0                	add    %edx,%eax
8010a0b1:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a0b4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a0b8:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a0bc:	0f b7 c0             	movzwl %ax,%eax
8010a0bf:	83 ec 0c             	sub    $0xc,%esp
8010a0c2:	50                   	push   %eax
8010a0c3:	e8 fb f5 ff ff       	call   801096c3 <N2H_ushort>
8010a0c8:	83 c4 10             	add    $0x10,%esp
8010a0cb:	66 d1 e8             	shr    %ax
8010a0ce:	0f b7 c0             	movzwl %ax,%eax
8010a0d1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a0d4:	7c af                	jl     8010a085 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a0d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0d9:	c1 e8 10             	shr    $0x10,%eax
8010a0dc:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a0df:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0e2:	f7 d0                	not    %eax
}
8010a0e4:	c9                   	leave  
8010a0e5:	c3                   	ret    

8010a0e6 <tcp_fin>:

void tcp_fin(){
8010a0e6:	55                   	push   %ebp
8010a0e7:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a0e9:	c7 05 68 6f 19 80 01 	movl   $0x1,0x80196f68
8010a0f0:	00 00 00 
}
8010a0f3:	90                   	nop
8010a0f4:	5d                   	pop    %ebp
8010a0f5:	c3                   	ret    

8010a0f6 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a0f6:	55                   	push   %ebp
8010a0f7:	89 e5                	mov    %esp,%ebp
8010a0f9:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a0fc:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0ff:	83 ec 04             	sub    $0x4,%esp
8010a102:	6a 00                	push   $0x0
8010a104:	68 eb c3 10 80       	push   $0x8010c3eb
8010a109:	50                   	push   %eax
8010a10a:	e8 65 00 00 00       	call   8010a174 <http_strcpy>
8010a10f:	83 c4 10             	add    $0x10,%esp
8010a112:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a115:	8b 45 10             	mov    0x10(%ebp),%eax
8010a118:	83 ec 04             	sub    $0x4,%esp
8010a11b:	ff 75 f4             	push   -0xc(%ebp)
8010a11e:	68 fe c3 10 80       	push   $0x8010c3fe
8010a123:	50                   	push   %eax
8010a124:	e8 4b 00 00 00       	call   8010a174 <http_strcpy>
8010a129:	83 c4 10             	add    $0x10,%esp
8010a12c:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a12f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a132:	83 ec 04             	sub    $0x4,%esp
8010a135:	ff 75 f4             	push   -0xc(%ebp)
8010a138:	68 19 c4 10 80       	push   $0x8010c419
8010a13d:	50                   	push   %eax
8010a13e:	e8 31 00 00 00       	call   8010a174 <http_strcpy>
8010a143:	83 c4 10             	add    $0x10,%esp
8010a146:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a14c:	83 e0 01             	and    $0x1,%eax
8010a14f:	85 c0                	test   %eax,%eax
8010a151:	74 11                	je     8010a164 <http_proc+0x6e>
    char *payload = (char *)send;
8010a153:	8b 45 10             	mov    0x10(%ebp),%eax
8010a156:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a159:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a15c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a15f:	01 d0                	add    %edx,%eax
8010a161:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a164:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a167:	8b 45 14             	mov    0x14(%ebp),%eax
8010a16a:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a16c:	e8 75 ff ff ff       	call   8010a0e6 <tcp_fin>
}
8010a171:	90                   	nop
8010a172:	c9                   	leave  
8010a173:	c3                   	ret    

8010a174 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a174:	55                   	push   %ebp
8010a175:	89 e5                	mov    %esp,%ebp
8010a177:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a17a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a181:	eb 20                	jmp    8010a1a3 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a183:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a186:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a189:	01 d0                	add    %edx,%eax
8010a18b:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a18e:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a191:	01 ca                	add    %ecx,%edx
8010a193:	89 d1                	mov    %edx,%ecx
8010a195:	8b 55 08             	mov    0x8(%ebp),%edx
8010a198:	01 ca                	add    %ecx,%edx
8010a19a:	0f b6 00             	movzbl (%eax),%eax
8010a19d:	88 02                	mov    %al,(%edx)
    i++;
8010a19f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a1a3:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a1a6:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1a9:	01 d0                	add    %edx,%eax
8010a1ab:	0f b6 00             	movzbl (%eax),%eax
8010a1ae:	84 c0                	test   %al,%al
8010a1b0:	75 d1                	jne    8010a183 <http_strcpy+0xf>
  }
  return i;
8010a1b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a1b5:	c9                   	leave  
8010a1b6:	c3                   	ret    

8010a1b7 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a1b7:	55                   	push   %ebp
8010a1b8:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a1ba:	c7 05 70 6f 19 80 a2 	movl   $0x8010f5a2,0x80196f70
8010a1c1:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a1c4:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a1c9:	c1 e8 09             	shr    $0x9,%eax
8010a1cc:	a3 6c 6f 19 80       	mov    %eax,0x80196f6c
}
8010a1d1:	90                   	nop
8010a1d2:	5d                   	pop    %ebp
8010a1d3:	c3                   	ret    

8010a1d4 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a1d4:	55                   	push   %ebp
8010a1d5:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a1d7:	90                   	nop
8010a1d8:	5d                   	pop    %ebp
8010a1d9:	c3                   	ret    

8010a1da <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a1da:	55                   	push   %ebp
8010a1db:	89 e5                	mov    %esp,%ebp
8010a1dd:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a1e0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1e3:	83 c0 0c             	add    $0xc,%eax
8010a1e6:	83 ec 0c             	sub    $0xc,%esp
8010a1e9:	50                   	push   %eax
8010a1ea:	e8 dc a5 ff ff       	call   801047cb <holdingsleep>
8010a1ef:	83 c4 10             	add    $0x10,%esp
8010a1f2:	85 c0                	test   %eax,%eax
8010a1f4:	75 0d                	jne    8010a203 <iderw+0x29>
    panic("iderw: buf not locked");
8010a1f6:	83 ec 0c             	sub    $0xc,%esp
8010a1f9:	68 2a c4 10 80       	push   $0x8010c42a
8010a1fe:	e8 a6 63 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a203:	8b 45 08             	mov    0x8(%ebp),%eax
8010a206:	8b 00                	mov    (%eax),%eax
8010a208:	83 e0 06             	and    $0x6,%eax
8010a20b:	83 f8 02             	cmp    $0x2,%eax
8010a20e:	75 0d                	jne    8010a21d <iderw+0x43>
    panic("iderw: nothing to do");
8010a210:	83 ec 0c             	sub    $0xc,%esp
8010a213:	68 40 c4 10 80       	push   $0x8010c440
8010a218:	e8 8c 63 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a21d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a220:	8b 40 04             	mov    0x4(%eax),%eax
8010a223:	83 f8 01             	cmp    $0x1,%eax
8010a226:	74 0d                	je     8010a235 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a228:	83 ec 0c             	sub    $0xc,%esp
8010a22b:	68 55 c4 10 80       	push   $0x8010c455
8010a230:	e8 74 63 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a235:	8b 45 08             	mov    0x8(%ebp),%eax
8010a238:	8b 40 08             	mov    0x8(%eax),%eax
8010a23b:	8b 15 6c 6f 19 80    	mov    0x80196f6c,%edx
8010a241:	39 d0                	cmp    %edx,%eax
8010a243:	72 0d                	jb     8010a252 <iderw+0x78>
    panic("iderw: block out of range");
8010a245:	83 ec 0c             	sub    $0xc,%esp
8010a248:	68 73 c4 10 80       	push   $0x8010c473
8010a24d:	e8 57 63 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a252:	8b 15 70 6f 19 80    	mov    0x80196f70,%edx
8010a258:	8b 45 08             	mov    0x8(%ebp),%eax
8010a25b:	8b 40 08             	mov    0x8(%eax),%eax
8010a25e:	c1 e0 09             	shl    $0x9,%eax
8010a261:	01 d0                	add    %edx,%eax
8010a263:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a266:	8b 45 08             	mov    0x8(%ebp),%eax
8010a269:	8b 00                	mov    (%eax),%eax
8010a26b:	83 e0 04             	and    $0x4,%eax
8010a26e:	85 c0                	test   %eax,%eax
8010a270:	74 2b                	je     8010a29d <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a272:	8b 45 08             	mov    0x8(%ebp),%eax
8010a275:	8b 00                	mov    (%eax),%eax
8010a277:	83 e0 fb             	and    $0xfffffffb,%eax
8010a27a:	89 c2                	mov    %eax,%edx
8010a27c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a27f:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a281:	8b 45 08             	mov    0x8(%ebp),%eax
8010a284:	83 c0 5c             	add    $0x5c,%eax
8010a287:	83 ec 04             	sub    $0x4,%esp
8010a28a:	68 00 02 00 00       	push   $0x200
8010a28f:	50                   	push   %eax
8010a290:	ff 75 f4             	push   -0xc(%ebp)
8010a293:	e8 f9 a8 ff ff       	call   80104b91 <memmove>
8010a298:	83 c4 10             	add    $0x10,%esp
8010a29b:	eb 1a                	jmp    8010a2b7 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a29d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2a0:	83 c0 5c             	add    $0x5c,%eax
8010a2a3:	83 ec 04             	sub    $0x4,%esp
8010a2a6:	68 00 02 00 00       	push   $0x200
8010a2ab:	ff 75 f4             	push   -0xc(%ebp)
8010a2ae:	50                   	push   %eax
8010a2af:	e8 dd a8 ff ff       	call   80104b91 <memmove>
8010a2b4:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a2b7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ba:	8b 00                	mov    (%eax),%eax
8010a2bc:	83 c8 02             	or     $0x2,%eax
8010a2bf:	89 c2                	mov    %eax,%edx
8010a2c1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2c4:	89 10                	mov    %edx,(%eax)
}
8010a2c6:	90                   	nop
8010a2c7:	c9                   	leave  
8010a2c8:	c3                   	ret    
