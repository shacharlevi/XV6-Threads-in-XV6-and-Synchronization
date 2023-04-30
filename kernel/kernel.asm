
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	93013103          	ld	sp,-1744(sp) # 80008930 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	93e70713          	addi	a4,a4,-1730 # 80008990 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	f0c78793          	addi	a5,a5,-244 # 80005f70 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb3ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	4ec080e7          	jalr	1260(ra) # 80002618 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	94650513          	addi	a0,a0,-1722 # 80010ad0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	93648493          	addi	s1,s1,-1738 # 80010ad0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	9c690913          	addi	s2,s2,-1594 # 80010b68 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7c0080e7          	jalr	1984(ra) # 80001980 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	298080e7          	jalr	664(ra) # 80002460 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f48080e7          	jalr	-184(ra) # 8000211e <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	3ae080e7          	jalr	942(ra) # 800025c0 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	8aa50513          	addi	a0,a0,-1878 # 80010ad0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	89450513          	addi	a0,a0,-1900 # 80010ad0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	8ef72b23          	sw	a5,-1802(a4) # 80010b68 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	80450513          	addi	a0,a0,-2044 # 80010ad0 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	37e080e7          	jalr	894(ra) # 80002670 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	7d650513          	addi	a0,a0,2006 # 80010ad0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	7b270713          	addi	a4,a4,1970 # 80010ad0 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	78878793          	addi	a5,a5,1928 # 80010ad0 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7f27a783          	lw	a5,2034(a5) # 80010b68 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	74670713          	addi	a4,a4,1862 # 80010ad0 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	73648493          	addi	s1,s1,1846 # 80010ad0 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	6fa70713          	addi	a4,a4,1786 # 80010ad0 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	78f72223          	sw	a5,1924(a4) # 80010b70 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	6be78793          	addi	a5,a5,1726 # 80010ad0 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	72c7ab23          	sw	a2,1846(a5) # 80010b6c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	72a50513          	addi	a0,a0,1834 # 80010b68 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	d58080e7          	jalr	-680(ra) # 8000219e <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	67050513          	addi	a0,a0,1648 # 80010ad0 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	df078793          	addi	a5,a5,-528 # 80022268 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	6407a323          	sw	zero,1606(a5) # 80010b90 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	d4c50513          	addi	a0,a0,-692 # 800082b8 <digits+0x278>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	3cf72923          	sw	a5,978(a4) # 80008950 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	5d6dad83          	lw	s11,1494(s11) # 80010b90 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	58050513          	addi	a0,a0,1408 # 80010b78 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	42250513          	addi	a0,a0,1058 # 80010b78 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	40648493          	addi	s1,s1,1030 # 80010b78 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	3c650513          	addi	a0,a0,966 # 80010b98 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	1527a783          	lw	a5,338(a5) # 80008950 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	1227b783          	ld	a5,290(a5) # 80008958 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	12273703          	ld	a4,290(a4) # 80008960 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	338a0a13          	addi	s4,s4,824 # 80010b98 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	0f048493          	addi	s1,s1,240 # 80008958 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	0f098993          	addi	s3,s3,240 # 80008960 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	90c080e7          	jalr	-1780(ra) # 8000219e <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	2ca50513          	addi	a0,a0,714 # 80010b98 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	0727a783          	lw	a5,114(a5) # 80008950 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	07873703          	ld	a4,120(a4) # 80008960 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	0687b783          	ld	a5,104(a5) # 80008958 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	29c98993          	addi	s3,s3,668 # 80010b98 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	05448493          	addi	s1,s1,84 # 80008958 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	05490913          	addi	s2,s2,84 # 80008960 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	802080e7          	jalr	-2046(ra) # 8000211e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	26648493          	addi	s1,s1,614 # 80010b98 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	00e7bd23          	sd	a4,26(a5) # 80008960 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	1dc48493          	addi	s1,s1,476 # 80010b98 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00023797          	auipc	a5,0x23
    80000a02:	a0278793          	addi	a5,a5,-1534 # 80023400 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	1b290913          	addi	s2,s2,434 # 80010bd0 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	11650513          	addi	a0,a0,278 # 80010bd0 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	93250513          	addi	a0,a0,-1742 # 80023400 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	0e048493          	addi	s1,s1,224 # 80010bd0 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	0c850513          	addi	a0,a0,200 # 80010bd0 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	09c50513          	addi	a0,a0,156 # 80010bd0 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	df4080e7          	jalr	-524(ra) # 80001964 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dc2080e7          	jalr	-574(ra) # 80001964 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	db6080e7          	jalr	-586(ra) # 80001964 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	d9e080e7          	jalr	-610(ra) # 80001964 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d5e080e7          	jalr	-674(ra) # 80001964 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d32080e7          	jalr	-718(ra) # 80001964 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	ad4080e7          	jalr	-1324(ra) # 80001954 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	ae070713          	addi	a4,a4,-1312 # 80008968 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ab8080e7          	jalr	-1352(ra) # 80001954 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	ae0080e7          	jalr	-1312(ra) # 8000299e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	0ea080e7          	jalr	234(ra) # 80005fb0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fd0080e7          	jalr	-48(ra) # 80001e9e <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	3d250513          	addi	a0,a0,978 # 800082b8 <digits+0x278>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	3b250513          	addi	a0,a0,946 # 800082b8 <digits+0x278>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	9a0080e7          	jalr	-1632(ra) # 800018ce <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	a40080e7          	jalr	-1472(ra) # 80002976 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a60080e7          	jalr	-1440(ra) # 8000299e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	054080e7          	jalr	84(ra) # 80005f9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	062080e7          	jalr	98(ra) # 80005fb0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	1e0080e7          	jalr	480(ra) # 80003136 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	884080e7          	jalr	-1916(ra) # 800037e2 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	822080e7          	jalr	-2014(ra) # 80004788 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	14a080e7          	jalr	330(ra) # 800060b8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	cd0080e7          	jalr	-816(ra) # 80001c46 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	9ef72223          	sw	a5,-1564(a4) # 80008968 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9d87b783          	ld	a5,-1576(a5) # 80008970 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	70a7be23          	sd	a0,1820(a5) # 80008970 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	715d                	addi	sp,sp,-80
    80001838:	e486                	sd	ra,72(sp)
    8000183a:	e0a2                	sd	s0,64(sp)
    8000183c:	fc26                	sd	s1,56(sp)
    8000183e:	f84a                	sd	s2,48(sp)
    80001840:	f44e                	sd	s3,40(sp)
    80001842:	f052                	sd	s4,32(sp)
    80001844:	ec56                	sd	s5,24(sp)
    80001846:	e85a                	sd	s6,16(sp)
    80001848:	e45e                	sd	s7,8(sp)
    8000184a:	0880                	addi	s0,sp,80
    8000184c:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184e:	0000f917          	auipc	s2,0xf
    80001852:	7d290913          	addi	s2,s2,2002 # 80011020 <proc>
    for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++) {
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      uint64 va = KSTACK((int) ((p - proc) * NKT + (kt - p->kthread)));
    80001856:	8bca                	mv	s7,s2
    80001858:	00006b17          	auipc	s6,0x6
    8000185c:	7a8b3b03          	ld	s6,1960(s6) # 80008000 <etext>
    80001860:	040009b7          	lui	s3,0x4000
    80001864:	19fd                	addi	s3,s3,-1
    80001866:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001868:	00016a97          	auipc	s5,0x16
    8000186c:	7b8a8a93          	addi	s5,s5,1976 # 80018020 <tickslock>
      uint64 va = KSTACK((int) ((p - proc) * NKT + (kt - p->kthread)));
    80001870:	417904b3          	sub	s1,s2,s7
    80001874:	8499                	srai	s1,s1,0x6
    80001876:	036484b3          	mul	s1,s1,s6
      char *pa = kalloc();
    8000187a:	fffff097          	auipc	ra,0xfffff
    8000187e:	26c080e7          	jalr	620(ra) # 80000ae6 <kalloc>
    80001882:	862a                	mv	a2,a0
      if(pa == 0)
    80001884:	cd0d                	beqz	a0,800018be <proc_mapstacks+0x88>
      uint64 va = KSTACK((int) ((p - proc) * NKT + (kt - p->kthread)));
    80001886:	0014859b          	addiw	a1,s1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b985b3          	sub	a1,s3,a1
    80001896:	8552                	mv	a0,s4
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	1c090913          	addi	s2,s2,448
    800018a4:	fd5916e3          	bne	s2,s5,80001870 <proc_mapstacks+0x3a>
    }
  }
}
    800018a8:	60a6                	ld	ra,72(sp)
    800018aa:	6406                	ld	s0,64(sp)
    800018ac:	74e2                	ld	s1,56(sp)
    800018ae:	7942                	ld	s2,48(sp)
    800018b0:	79a2                	ld	s3,40(sp)
    800018b2:	7a02                	ld	s4,32(sp)
    800018b4:	6ae2                	ld	s5,24(sp)
    800018b6:	6b42                	ld	s6,16(sp)
    800018b8:	6ba2                	ld	s7,8(sp)
    800018ba:	6161                	addi	sp,sp,80
    800018bc:	8082                	ret
        panic("kalloc");
    800018be:	00007517          	auipc	a0,0x7
    800018c2:	91a50513          	addi	a0,a0,-1766 # 800081d8 <digits+0x198>
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	c78080e7          	jalr	-904(ra) # 8000053e <panic>

00000000800018ce <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018ce:	7179                	addi	sp,sp,-48
    800018d0:	f406                	sd	ra,40(sp)
    800018d2:	f022                	sd	s0,32(sp)
    800018d4:	ec26                	sd	s1,24(sp)
    800018d6:	e84a                	sd	s2,16(sp)
    800018d8:	e44e                	sd	s3,8(sp)
    800018da:	1800                	addi	s0,sp,48
  struct proc *p;
  initlock(&pid_lock, "nextpid");
    800018dc:	00007597          	auipc	a1,0x7
    800018e0:	90458593          	addi	a1,a1,-1788 # 800081e0 <digits+0x1a0>
    800018e4:	0000f517          	auipc	a0,0xf
    800018e8:	30c50513          	addi	a0,a0,780 # 80010bf0 <pid_lock>
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	25a080e7          	jalr	602(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f4:	00007597          	auipc	a1,0x7
    800018f8:	8f458593          	addi	a1,a1,-1804 # 800081e8 <digits+0x1a8>
    800018fc:	0000f517          	auipc	a0,0xf
    80001900:	30c50513          	addi	a0,a0,780 # 80010c08 <wait_lock>
    80001904:	fffff097          	auipc	ra,0xfffff
    80001908:	242080e7          	jalr	578(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190c:	0000f497          	auipc	s1,0xf
    80001910:	71448493          	addi	s1,s1,1812 # 80011020 <proc>
     initlock(&p->lock, "proc"); 
    80001914:	00007997          	auipc	s3,0x7
    80001918:	8e498993          	addi	s3,s3,-1820 # 800081f8 <digits+0x1b8>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191c:	00016917          	auipc	s2,0x16
    80001920:	70490913          	addi	s2,s2,1796 # 80018020 <tickslock>
     initlock(&p->lock, "proc"); 
    80001924:	85ce                	mv	a1,s3
    80001926:	8526                	mv	a0,s1
    80001928:	fffff097          	auipc	ra,0xfffff
    8000192c:	21e080e7          	jalr	542(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001930:	0004ac23          	sw	zero,24(s1)
      kthreadinit(p);
    80001934:	8526                	mv	a0,s1
    80001936:	00001097          	auipc	ra,0x1
    8000193a:	de8080e7          	jalr	-536(ra) # 8000271e <kthreadinit>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193e:	1c048493          	addi	s1,s1,448
    80001942:	ff2491e3          	bne	s1,s2,80001924 <procinit+0x56>
  }

}
    80001946:	70a2                	ld	ra,40(sp)
    80001948:	7402                	ld	s0,32(sp)
    8000194a:	64e2                	ld	s1,24(sp)
    8000194c:	6942                	ld	s2,16(sp)
    8000194e:	69a2                	ld	s3,8(sp)
    80001950:	6145                	addi	sp,sp,48
    80001952:	8082                	ret

0000000080001954 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001954:	1141                	addi	sp,sp,-16
    80001956:	e422                	sd	s0,8(sp)
    80001958:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000195a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000195c:	2501                	sext.w	a0,a0
    8000195e:	6422                	ld	s0,8(sp)
    80001960:	0141                	addi	sp,sp,16
    80001962:	8082                	ret

0000000080001964 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001964:	1141                	addi	sp,sp,-16
    80001966:	e422                	sd	s0,8(sp)
    80001968:	0800                	addi	s0,sp,16
    8000196a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000196c:	2781                	sext.w	a5,a5
    8000196e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001970:	0000f517          	auipc	a0,0xf
    80001974:	2b050513          	addi	a0,a0,688 # 80010c20 <cpus>
    80001978:	953e                	add	a0,a0,a5
    8000197a:	6422                	ld	s0,8(sp)
    8000197c:	0141                	addi	sp,sp,16
    8000197e:	8082                	ret

0000000080001980 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001980:	1101                	addi	sp,sp,-32
    80001982:	ec06                	sd	ra,24(sp)
    80001984:	e822                	sd	s0,16(sp)
    80001986:	e426                	sd	s1,8(sp)
    80001988:	1000                	addi	s0,sp,32
  push_off();
    8000198a:	fffff097          	auipc	ra,0xfffff
    8000198e:	200080e7          	jalr	512(ra) # 80000b8a <push_off>
    80001992:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p=0;
  if(c->kthread !=0){
    80001994:	2781                	sext.w	a5,a5
    80001996:	079e                	slli	a5,a5,0x7
    80001998:	0000f717          	auipc	a4,0xf
    8000199c:	25870713          	addi	a4,a4,600 # 80010bf0 <pid_lock>
    800019a0:	97ba                	add	a5,a5,a4
    800019a2:	7b84                	ld	s1,48(a5)
    800019a4:	c091                	beqz	s1,800019a8 <myproc+0x28>
    struct kthread *kthread = c->kthread;
    p=kthread->process;
    800019a6:	7c84                	ld	s1,56(s1)
  }
  pop_off();
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	282080e7          	jalr	642(ra) # 80000c2a <pop_off>
  return p;
}
    800019b0:	8526                	mv	a0,s1
    800019b2:	60e2                	ld	ra,24(sp)
    800019b4:	6442                	ld	s0,16(sp)
    800019b6:	64a2                	ld	s1,8(sp)
    800019b8:	6105                	addi	sp,sp,32
    800019ba:	8082                	ret

00000000800019bc <allocpid>:

int
allocpid()
{
    800019bc:	1101                	addi	sp,sp,-32
    800019be:	ec06                	sd	ra,24(sp)
    800019c0:	e822                	sd	s0,16(sp)
    800019c2:	e426                	sd	s1,8(sp)
    800019c4:	e04a                	sd	s2,0(sp)
    800019c6:	1000                	addi	s0,sp,32
  int pid;
  
  acquire(&pid_lock);
    800019c8:	0000f917          	auipc	s2,0xf
    800019cc:	22890913          	addi	s2,s2,552 # 80010bf0 <pid_lock>
    800019d0:	854a                	mv	a0,s2
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	204080e7          	jalr	516(ra) # 80000bd6 <acquire>
  pid = nextpid;
    800019da:	00007797          	auipc	a5,0x7
    800019de:	f0a78793          	addi	a5,a5,-246 # 800088e4 <nextpid>
    800019e2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019e4:	0014871b          	addiw	a4,s1,1
    800019e8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019ea:	854a                	mv	a0,s2
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	29e080e7          	jalr	670(ra) # 80000c8a <release>

  return pid;
}
    800019f4:	8526                	mv	a0,s1
    800019f6:	60e2                	ld	ra,24(sp)
    800019f8:	6442                	ld	s0,16(sp)
    800019fa:	64a2                	ld	s1,8(sp)
    800019fc:	6902                	ld	s2,0(sp)
    800019fe:	6105                	addi	sp,sp,32
    80001a00:	8082                	ret

0000000080001a02 <proc_pagetable>:

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
    80001a02:	1101                	addi	sp,sp,-32
    80001a04:	ec06                	sd	ra,24(sp)
    80001a06:	e822                	sd	s0,16(sp)
    80001a08:	e426                	sd	s1,8(sp)
    80001a0a:	e04a                	sd	s2,0(sp)
    80001a0c:	1000                	addi	s0,sp,32
    80001a0e:	892a                	mv	s2,a0
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
    80001a10:	00000097          	auipc	ra,0x0
    80001a14:	918080e7          	jalr	-1768(ra) # 80001328 <uvmcreate>
    80001a18:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a1a:	c121                	beqz	a0,80001a5a <proc_pagetable+0x58>

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a1c:	4729                	li	a4,10
    80001a1e:	00005697          	auipc	a3,0x5
    80001a22:	5e268693          	addi	a3,a3,1506 # 80007000 <_trampoline>
    80001a26:	6605                	lui	a2,0x1
    80001a28:	040005b7          	lui	a1,0x4000
    80001a2c:	15fd                	addi	a1,a1,-1
    80001a2e:	05b2                	slli	a1,a1,0xc
    80001a30:	fffff097          	auipc	ra,0xfffff
    80001a34:	66e080e7          	jalr	1646(ra) # 8000109e <mappages>
    80001a38:	02054863          	bltz	a0,80001a68 <proc_pagetable+0x66>
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME(0), PGSIZE,
    80001a3c:	4719                	li	a4,6
    80001a3e:	0e893683          	ld	a3,232(s2)
    80001a42:	6605                	lui	a2,0x1
    80001a44:	020005b7          	lui	a1,0x2000
    80001a48:	15fd                	addi	a1,a1,-1
    80001a4a:	05b6                	slli	a1,a1,0xd
    80001a4c:	8526                	mv	a0,s1
    80001a4e:	fffff097          	auipc	ra,0xfffff
    80001a52:	650080e7          	jalr	1616(ra) # 8000109e <mappages>
    80001a56:	02054163          	bltz	a0,80001a78 <proc_pagetable+0x76>
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}
    80001a5a:	8526                	mv	a0,s1
    80001a5c:	60e2                	ld	ra,24(sp)
    80001a5e:	6442                	ld	s0,16(sp)
    80001a60:	64a2                	ld	s1,8(sp)
    80001a62:	6902                	ld	s2,0(sp)
    80001a64:	6105                	addi	sp,sp,32
    80001a66:	8082                	ret
    uvmfree(pagetable, 0);
    80001a68:	4581                	li	a1,0
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	00000097          	auipc	ra,0x0
    80001a70:	ac0080e7          	jalr	-1344(ra) # 8000152c <uvmfree>
    return 0;
    80001a74:	4481                	li	s1,0
    80001a76:	b7d5                	j	80001a5a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a78:	4681                	li	a3,0
    80001a7a:	4605                	li	a2,1
    80001a7c:	040005b7          	lui	a1,0x4000
    80001a80:	15fd                	addi	a1,a1,-1
    80001a82:	05b2                	slli	a1,a1,0xc
    80001a84:	8526                	mv	a0,s1
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	7de080e7          	jalr	2014(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a8e:	4581                	li	a1,0
    80001a90:	8526                	mv	a0,s1
    80001a92:	00000097          	auipc	ra,0x0
    80001a96:	a9a080e7          	jalr	-1382(ra) # 8000152c <uvmfree>
    return 0;
    80001a9a:	4481                	li	s1,0
    80001a9c:	bf7d                	j	80001a5a <proc_pagetable+0x58>

0000000080001a9e <proc_freepagetable>:

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	e04a                	sd	s2,0(sp)
    80001aa8:	1000                	addi	s0,sp,32
    80001aaa:	84aa                	mv	s1,a0
    80001aac:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aae:	4681                	li	a3,0
    80001ab0:	4605                	li	a2,1
    80001ab2:	040005b7          	lui	a1,0x4000
    80001ab6:	15fd                	addi	a1,a1,-1
    80001ab8:	05b2                	slli	a1,a1,0xc
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	7aa080e7          	jalr	1962(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME(0), 1, 0);
    80001ac2:	4681                	li	a3,0
    80001ac4:	4605                	li	a2,1
    80001ac6:	020005b7          	lui	a1,0x2000
    80001aca:	15fd                	addi	a1,a1,-1
    80001acc:	05b6                	slli	a1,a1,0xd
    80001ace:	8526                	mv	a0,s1
    80001ad0:	fffff097          	auipc	ra,0xfffff
    80001ad4:	794080e7          	jalr	1940(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ad8:	85ca                	mv	a1,s2
    80001ada:	8526                	mv	a0,s1
    80001adc:	00000097          	auipc	ra,0x0
    80001ae0:	a50080e7          	jalr	-1456(ra) # 8000152c <uvmfree>
}
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6902                	ld	s2,0(sp)
    80001aec:	6105                	addi	sp,sp,32
    80001aee:	8082                	ret

0000000080001af0 <freeproc>:
{
    80001af0:	1101                	addi	sp,sp,-32
    80001af2:	ec06                	sd	ra,24(sp)
    80001af4:	e822                	sd	s0,16(sp)
    80001af6:	e426                	sd	s1,8(sp)
    80001af8:	e04a                	sd	s2,0(sp)
    80001afa:	1000                	addi	s0,sp,32
    80001afc:	84aa                	mv	s1,a0
      acquire(&kt->t_lock);
    80001afe:	02850913          	addi	s2,a0,40
    80001b02:	854a                	mv	a0,s2
    80001b04:	fffff097          	auipc	ra,0xfffff
    80001b08:	0d2080e7          	jalr	210(ra) # 80000bd6 <acquire>
      freethread(kt);
    80001b0c:	854a                	mv	a0,s2
    80001b0e:	00001097          	auipc	ra,0x1
    80001b12:	da2080e7          	jalr	-606(ra) # 800028b0 <freethread>
  if(p->base_trapframes)
    80001b16:	74e8                	ld	a0,232(s1)
    80001b18:	c509                	beqz	a0,80001b22 <freeproc+0x32>
    kfree((void*)p->base_trapframes);
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	ed0080e7          	jalr	-304(ra) # 800009ea <kfree>
  p->base_trapframes = 0;
    80001b22:	0e04b423          	sd	zero,232(s1)
  if(p->pagetable)
    80001b26:	1004b503          	ld	a0,256(s1)
    80001b2a:	c511                	beqz	a0,80001b36 <freeproc+0x46>
    proc_freepagetable(p->pagetable, p->sz);
    80001b2c:	7cec                	ld	a1,248(s1)
    80001b2e:	00000097          	auipc	ra,0x0
    80001b32:	f70080e7          	jalr	-144(ra) # 80001a9e <proc_freepagetable>
  p->pagetable = 0;
    80001b36:	1004b023          	sd	zero,256(s1)
  p->sz = 0;
    80001b3a:	0e04bc23          	sd	zero,248(s1)
  p->pid = 0;
    80001b3e:	0204a223          	sw	zero,36(s1)
  p->parent = 0;
    80001b42:	0e04b823          	sd	zero,240(s1)
  p->name[0] = 0;
    80001b46:	18048823          	sb	zero,400(s1)
  p->killed = 0;
    80001b4a:	0004ae23          	sw	zero,28(s1)
  p->xstate = 0;
    80001b4e:	0204a023          	sw	zero,32(s1)
  p->state = UNUSED;
    80001b52:	0004ac23          	sw	zero,24(s1)
  p->p_counter=0;
    80001b56:	1a04a023          	sw	zero,416(s1)
}
    80001b5a:	60e2                	ld	ra,24(sp)
    80001b5c:	6442                	ld	s0,16(sp)
    80001b5e:	64a2                	ld	s1,8(sp)
    80001b60:	6902                	ld	s2,0(sp)
    80001b62:	6105                	addi	sp,sp,32
    80001b64:	8082                	ret

0000000080001b66 <allocproc>:
{
    80001b66:	1101                	addi	sp,sp,-32
    80001b68:	ec06                	sd	ra,24(sp)
    80001b6a:	e822                	sd	s0,16(sp)
    80001b6c:	e426                	sd	s1,8(sp)
    80001b6e:	e04a                	sd	s2,0(sp)
    80001b70:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b72:	0000f497          	auipc	s1,0xf
    80001b76:	4ae48493          	addi	s1,s1,1198 # 80011020 <proc>
    80001b7a:	00016917          	auipc	s2,0x16
    80001b7e:	4a690913          	addi	s2,s2,1190 # 80018020 <tickslock>
    acquire(&p->lock);
    80001b82:	8526                	mv	a0,s1
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	052080e7          	jalr	82(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001b8c:	4c9c                	lw	a5,24(s1)
    80001b8e:	cf81                	beqz	a5,80001ba6 <allocproc+0x40>
      release(&p->lock);
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	0f8080e7          	jalr	248(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b9a:	1c048493          	addi	s1,s1,448
    80001b9e:	ff2492e3          	bne	s1,s2,80001b82 <allocproc+0x1c>
  return 0;
    80001ba2:	4481                	li	s1,0
    80001ba4:	a089                	j	80001be6 <allocproc+0x80>
  p->p_counter=1;
    80001ba6:	4905                	li	s2,1
    80001ba8:	1b24a023          	sw	s2,416(s1)
  p->pid = allocpid();
    80001bac:	00000097          	auipc	ra,0x0
    80001bb0:	e10080e7          	jalr	-496(ra) # 800019bc <allocpid>
    80001bb4:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001bb6:	0124ac23          	sw	s2,24(s1)
  if((p->base_trapframes = (struct trapframe *)kalloc()) == 0){
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	f2c080e7          	jalr	-212(ra) # 80000ae6 <kalloc>
    80001bc2:	892a                	mv	s2,a0
    80001bc4:	f4e8                	sd	a0,232(s1)
    80001bc6:	c51d                	beqz	a0,80001bf4 <allocproc+0x8e>
  struct kthread *new_t=allockthread(p);
    80001bc8:	8526                	mv	a0,s1
    80001bca:	00001097          	auipc	ra,0x1
    80001bce:	c66080e7          	jalr	-922(ra) # 80002830 <allockthread>
  if(new_t==0){
    80001bd2:	cd0d                	beqz	a0,80001c0c <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001bd4:	8526                	mv	a0,s1
    80001bd6:	00000097          	auipc	ra,0x0
    80001bda:	e2c080e7          	jalr	-468(ra) # 80001a02 <proc_pagetable>
    80001bde:	892a                	mv	s2,a0
    80001be0:	10a4b023          	sd	a0,256(s1)
  if(p->pagetable == 0){
    80001be4:	c529                	beqz	a0,80001c2e <allocproc+0xc8>
}
    80001be6:	8526                	mv	a0,s1
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6902                	ld	s2,0(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret
    freeproc(p);
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	efa080e7          	jalr	-262(ra) # 80001af0 <freeproc>
    release(&p->lock);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	08a080e7          	jalr	138(ra) # 80000c8a <release>
    return 0;
    80001c08:	84ca                	mv	s1,s2
    80001c0a:	bff1                	j	80001be6 <allocproc+0x80>
    freeproc(p);
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	00000097          	auipc	ra,0x0
    80001c12:	ee2080e7          	jalr	-286(ra) # 80001af0 <freeproc>
     release(&new_t->t_lock);
    80001c16:	4501                	li	a0,0
    80001c18:	fffff097          	auipc	ra,0xfffff
    80001c1c:	072080e7          	jalr	114(ra) # 80000c8a <release>
     release(&p->lock);
    80001c20:	8526                	mv	a0,s1
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	068080e7          	jalr	104(ra) # 80000c8a <release>
    return (struct proc *)-1;
    80001c2a:	54fd                	li	s1,-1
    80001c2c:	bf6d                	j	80001be6 <allocproc+0x80>
    freeproc(p);
    80001c2e:	8526                	mv	a0,s1
    80001c30:	00000097          	auipc	ra,0x0
    80001c34:	ec0080e7          	jalr	-320(ra) # 80001af0 <freeproc>
    release(&p->lock);
    80001c38:	8526                	mv	a0,s1
    80001c3a:	fffff097          	auipc	ra,0xfffff
    80001c3e:	050080e7          	jalr	80(ra) # 80000c8a <release>
    return 0;
    80001c42:	84ca                	mv	s1,s2
    80001c44:	b74d                	j	80001be6 <allocproc+0x80>

0000000080001c46 <userinit>:
};

// Set up first user process.
void
userinit(void)
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	1000                	addi	s0,sp,32
  struct proc *p;
  p = allocproc();
    80001c50:	00000097          	auipc	ra,0x0
    80001c54:	f16080e7          	jalr	-234(ra) # 80001b66 <allocproc>
    80001c58:	84aa                	mv	s1,a0
  initproc = p;
    80001c5a:	00007797          	auipc	a5,0x7
    80001c5e:	d0a7bf23          	sd	a0,-738(a5) # 80008978 <initproc>
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c62:	03400613          	li	a2,52
    80001c66:	00007597          	auipc	a1,0x7
    80001c6a:	c8a58593          	addi	a1,a1,-886 # 800088f0 <initcode>
    80001c6e:	10053503          	ld	a0,256(a0)
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	6e4080e7          	jalr	1764(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001c7a:	6785                	lui	a5,0x1
    80001c7c:	fcfc                	sd	a5,248(s1)
  // prepare for the very first "return" from kernel to user.
  // mykthread()->trapframe->epc = 0;      // user program counter
  p->kthread[0].trapframe->epc=0;
    80001c7e:	70f8                	ld	a4,224(s1)
    80001c80:	00073c23          	sd	zero,24(a4)
  // mykthread()->trapframe->sp = PGSIZE;  // user stack pointer
  p->kthread[0].trapframe->sp=PGSIZE;
    80001c84:	70f8                	ld	a4,224(s1)
    80001c86:	fb1c                	sd	a5,48(a4)
  // mykthread()->t_state=RUNNABLE_t;
  p->kthread[0].t_state=RUNNABLE_t;
    80001c88:	478d                	li	a5,3
    80001c8a:	c0bc                	sw	a5,64(s1)

  release(&(p->kthread[0].t_lock));
    80001c8c:	02848513          	addi	a0,s1,40
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	ffa080e7          	jalr	-6(ra) # 80000c8a <release>

  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001c98:	4641                	li	a2,16
    80001c9a:	00006597          	auipc	a1,0x6
    80001c9e:	56658593          	addi	a1,a1,1382 # 80008200 <digits+0x1c0>
    80001ca2:	19048513          	addi	a0,s1,400
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	176080e7          	jalr	374(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cae:	00006517          	auipc	a0,0x6
    80001cb2:	56250513          	addi	a0,a0,1378 # 80008210 <digits+0x1d0>
    80001cb6:	00002097          	auipc	ra,0x2
    80001cba:	4ce080e7          	jalr	1230(ra) # 80004184 <namei>
    80001cbe:	18a4b423          	sd	a0,392(s1)

  // p->state = RUNNABLE;

  release(&p->lock);
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	fc6080e7          	jalr	-58(ra) # 80000c8a <release>

}
    80001ccc:	60e2                	ld	ra,24(sp)
    80001cce:	6442                	ld	s0,16(sp)
    80001cd0:	64a2                	ld	s1,8(sp)
    80001cd2:	6105                	addi	sp,sp,32
    80001cd4:	8082                	ret

0000000080001cd6 <growproc>:

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
    80001cd6:	1101                	addi	sp,sp,-32
    80001cd8:	ec06                	sd	ra,24(sp)
    80001cda:	e822                	sd	s0,16(sp)
    80001cdc:	e426                	sd	s1,8(sp)
    80001cde:	e04a                	sd	s2,0(sp)
    80001ce0:	1000                	addi	s0,sp,32
    80001ce2:	892a                	mv	s2,a0
  uint64 sz;
  struct proc *p = myproc();
    80001ce4:	00000097          	auipc	ra,0x0
    80001ce8:	c9c080e7          	jalr	-868(ra) # 80001980 <myproc>
    80001cec:	84aa                	mv	s1,a0

  sz = p->sz;
    80001cee:	7d6c                	ld	a1,248(a0)
  if(n > 0){
    80001cf0:	01204c63          	bgtz	s2,80001d08 <growproc+0x32>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    80001cf4:	02094763          	bltz	s2,80001d22 <growproc+0x4c>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
    80001cf8:	fcec                	sd	a1,248(s1)
  return 0;
    80001cfa:	4501                	li	a0,0
}
    80001cfc:	60e2                	ld	ra,24(sp)
    80001cfe:	6442                	ld	s0,16(sp)
    80001d00:	64a2                	ld	s1,8(sp)
    80001d02:	6902                	ld	s2,0(sp)
    80001d04:	6105                	addi	sp,sp,32
    80001d06:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d08:	4691                	li	a3,4
    80001d0a:	00b90633          	add	a2,s2,a1
    80001d0e:	10053503          	ld	a0,256(a0)
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	6fe080e7          	jalr	1790(ra) # 80001410 <uvmalloc>
    80001d1a:	85aa                	mv	a1,a0
    80001d1c:	fd71                	bnez	a0,80001cf8 <growproc+0x22>
      return -1;
    80001d1e:	557d                	li	a0,-1
    80001d20:	bff1                	j	80001cfc <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d22:	00b90633          	add	a2,s2,a1
    80001d26:	10053503          	ld	a0,256(a0)
    80001d2a:	fffff097          	auipc	ra,0xfffff
    80001d2e:	69e080e7          	jalr	1694(ra) # 800013c8 <uvmdealloc>
    80001d32:	85aa                	mv	a1,a0
    80001d34:	b7d1                	j	80001cf8 <growproc+0x22>

0000000080001d36 <fork>:

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
    80001d36:	7139                	addi	sp,sp,-64
    80001d38:	fc06                	sd	ra,56(sp)
    80001d3a:	f822                	sd	s0,48(sp)
    80001d3c:	f426                	sd	s1,40(sp)
    80001d3e:	f04a                	sd	s2,32(sp)
    80001d40:	ec4e                	sd	s3,24(sp)
    80001d42:	e852                	sd	s4,16(sp)
    80001d44:	e456                	sd	s5,8(sp)
    80001d46:	0080                	addi	s0,sp,64
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	c38080e7          	jalr	-968(ra) # 80001980 <myproc>
    80001d50:	8aaa                	mv	s5,a0
  struct kthread *kt = mykthread();
    80001d52:	00001097          	auipc	ra,0x1
    80001d56:	a3e080e7          	jalr	-1474(ra) # 80002790 <mykthread>
    80001d5a:	84aa                	mv	s1,a0
  printf("in fork\n");
    80001d5c:	00006517          	auipc	a0,0x6
    80001d60:	4bc50513          	addi	a0,a0,1212 # 80008218 <digits+0x1d8>
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	824080e7          	jalr	-2012(ra) # 80000588 <printf>
  // Allocate process.
  if((np = allocproc()) == 0){
    80001d6c:	00000097          	auipc	ra,0x0
    80001d70:	dfa080e7          	jalr	-518(ra) # 80001b66 <allocproc>
    80001d74:	12050363          	beqz	a0,80001e9a <fork+0x164>
    80001d78:	8a2a                	mv	s4,a0
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d7a:	0f8ab603          	ld	a2,248(s5)
    80001d7e:	10053583          	ld	a1,256(a0)
    80001d82:	100ab503          	ld	a0,256(s5)
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	7de080e7          	jalr	2014(ra) # 80001564 <uvmcopy>
    80001d8e:	04054763          	bltz	a0,80001ddc <fork+0xa6>
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;
    80001d92:	0f8ab783          	ld	a5,248(s5)
    80001d96:	0efa3c23          	sd	a5,248(s4) # fffffffffffff0f8 <end+0xffffffff7ffdbcf8>
  //   freeproc(np);
  //    release(&np->lock);
  //   return -1;
  // }
  // copy saved user registers.
  *(np->kthread[0].trapframe) = *(kt->trapframe);
    80001d9a:	7cd4                	ld	a3,184(s1)
    80001d9c:	87b6                	mv	a5,a3
    80001d9e:	0e0a3703          	ld	a4,224(s4)
    80001da2:	12068693          	addi	a3,a3,288
    80001da6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001daa:	6788                	ld	a0,8(a5)
    80001dac:	6b8c                	ld	a1,16(a5)
    80001dae:	6f90                	ld	a2,24(a5)
    80001db0:	01073023          	sd	a6,0(a4)
    80001db4:	e708                	sd	a0,8(a4)
    80001db6:	eb0c                	sd	a1,16(a4)
    80001db8:	ef10                	sd	a2,24(a4)
    80001dba:	02078793          	addi	a5,a5,32
    80001dbe:	02070713          	addi	a4,a4,32
    80001dc2:	fed792e3          	bne	a5,a3,80001da6 <fork+0x70>

  // Cause fork to return 0 in the child.
  np->kthread[0].trapframe->a0 = 0;
    80001dc6:	0e0a3783          	ld	a5,224(s4)
    80001dca:	0607b823          	sd	zero,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    80001dce:	108a8493          	addi	s1,s5,264
    80001dd2:	108a0913          	addi	s2,s4,264
    80001dd6:	188a8993          	addi	s3,s5,392
    80001dda:	a00d                	j	80001dfc <fork+0xc6>
    freeproc(np);
    80001ddc:	8552                	mv	a0,s4
    80001dde:	00000097          	auipc	ra,0x0
    80001de2:	d12080e7          	jalr	-750(ra) # 80001af0 <freeproc>
    release(&np->lock);
    80001de6:	8552                	mv	a0,s4
    80001de8:	fffff097          	auipc	ra,0xfffff
    80001dec:	ea2080e7          	jalr	-350(ra) # 80000c8a <release>
    return -1;
    80001df0:	59fd                	li	s3,-1
    80001df2:	a851                	j	80001e86 <fork+0x150>
  for(i = 0; i < NOFILE; i++)
    80001df4:	04a1                	addi	s1,s1,8
    80001df6:	0921                	addi	s2,s2,8
    80001df8:	01348b63          	beq	s1,s3,80001e0e <fork+0xd8>
    if(p->ofile[i])
    80001dfc:	6088                	ld	a0,0(s1)
    80001dfe:	d97d                	beqz	a0,80001df4 <fork+0xbe>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e00:	00003097          	auipc	ra,0x3
    80001e04:	a1a080e7          	jalr	-1510(ra) # 8000481a <filedup>
    80001e08:	00a93023          	sd	a0,0(s2)
    80001e0c:	b7e5                	j	80001df4 <fork+0xbe>
  np->cwd = idup(p->cwd);
    80001e0e:	188ab503          	ld	a0,392(s5)
    80001e12:	00002097          	auipc	ra,0x2
    80001e16:	b8e080e7          	jalr	-1138(ra) # 800039a0 <idup>
    80001e1a:	18aa3423          	sd	a0,392(s4)

  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e1e:	4641                	li	a2,16
    80001e20:	190a8593          	addi	a1,s5,400
    80001e24:	190a0513          	addi	a0,s4,400
    80001e28:	fffff097          	auipc	ra,0xfffff
    80001e2c:	ff4080e7          	jalr	-12(ra) # 80000e1c <safestrcpy>

  pid = np->pid;
    80001e30:	024a2983          	lw	s3,36(s4)

  release(&np->kthread[0].t_lock);///acqire in allockthread
    80001e34:	028a0493          	addi	s1,s4,40
    80001e38:	8526                	mv	a0,s1
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	e50080e7          	jalr	-432(ra) # 80000c8a <release>
  release(&np->lock);///acqire in allocproc
    80001e42:	8552                	mv	a0,s4
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	e46080e7          	jalr	-442(ra) # 80000c8a <release>

  acquire(&wait_lock);
    80001e4c:	0000f917          	auipc	s2,0xf
    80001e50:	dbc90913          	addi	s2,s2,-580 # 80010c08 <wait_lock>
    80001e54:	854a                	mv	a0,s2
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	d80080e7          	jalr	-640(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e5e:	0f5a3823          	sd	s5,240(s4)
  release(&wait_lock);
    80001e62:	854a                	mv	a0,s2
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	e26080e7          	jalr	-474(ra) # 80000c8a <release>

  // acquire(&np->lock);
  acquire(&np->kthread[0].t_lock);
    80001e6c:	8526                	mv	a0,s1
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	d68080e7          	jalr	-664(ra) # 80000bd6 <acquire>
  np->kthread[0].t_state = RUNNABLE_t;
    80001e76:	478d                	li	a5,3
    80001e78:	04fa2023          	sw	a5,64(s4)
  release(&np->kthread[0].t_lock);
    80001e7c:	8526                	mv	a0,s1
    80001e7e:	fffff097          	auipc	ra,0xfffff
    80001e82:	e0c080e7          	jalr	-500(ra) # 80000c8a <release>
  // release(&np->lock);



  return pid;
}
    80001e86:	854e                	mv	a0,s3
    80001e88:	70e2                	ld	ra,56(sp)
    80001e8a:	7442                	ld	s0,48(sp)
    80001e8c:	74a2                	ld	s1,40(sp)
    80001e8e:	7902                	ld	s2,32(sp)
    80001e90:	69e2                	ld	s3,24(sp)
    80001e92:	6a42                	ld	s4,16(sp)
    80001e94:	6aa2                	ld	s5,8(sp)
    80001e96:	6121                	addi	sp,sp,64
    80001e98:	8082                	ret
    return -1;
    80001e9a:	59fd                	li	s3,-1
    80001e9c:	b7ed                	j	80001e86 <fork+0x150>

0000000080001e9e <scheduler>:
// }


void
scheduler(void)
{
    80001e9e:	7159                	addi	sp,sp,-112
    80001ea0:	f486                	sd	ra,104(sp)
    80001ea2:	f0a2                	sd	s0,96(sp)
    80001ea4:	eca6                	sd	s1,88(sp)
    80001ea6:	e8ca                	sd	s2,80(sp)
    80001ea8:	e4ce                	sd	s3,72(sp)
    80001eaa:	e0d2                	sd	s4,64(sp)
    80001eac:	fc56                	sd	s5,56(sp)
    80001eae:	f85a                	sd	s6,48(sp)
    80001eb0:	f45e                	sd	s7,40(sp)
    80001eb2:	f062                	sd	s8,32(sp)
    80001eb4:	ec66                	sd	s9,24(sp)
    80001eb6:	e86a                	sd	s10,16(sp)
    80001eb8:	e46e                	sd	s11,8(sp)
    80001eba:	1880                	addi	s0,sp,112
    80001ebc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ebe:	2781                	sext.w	a5,a5
  struct proc *p;
  struct cpu *c = mycpu();
  c->kthread = 0;
    80001ec0:	00779c13          	slli	s8,a5,0x7
    80001ec4:	0000f717          	auipc	a4,0xf
    80001ec8:	d2c70713          	addi	a4,a4,-724 # 80010bf0 <pid_lock>
    80001ecc:	9762                	add	a4,a4,s8
    80001ece:	02073823          	sd	zero,48(a4)
            if(kt->t_state == RUNNABLE_t) {
                  printf("22in scheduler222\n");

              kt->t_state = RUNNING_t;
              c->kthread=kt;
              swtch(&c->context, &kt->context);
    80001ed2:	0000f717          	auipc	a4,0xf
    80001ed6:	d5670713          	addi	a4,a4,-682 # 80010c28 <cpus+0x8>
    80001eda:	9c3a                	add	s8,s8,a4
    printf("in scheduler\n");
    80001edc:	00006d97          	auipc	s11,0x6
    80001ee0:	34cd8d93          	addi	s11,s11,844 # 80008228 <digits+0x1e8>
    80001ee4:	00016a17          	auipc	s4,0x16
    80001ee8:	164a0a13          	addi	s4,s4,356 # 80018048 <bcache+0x10>
                  printf("22in scheduler222\n");
    80001eec:	00006d17          	auipc	s10,0x6
    80001ef0:	34cd0d13          	addi	s10,s10,844 # 80008238 <digits+0x1f8>
              c->kthread=kt;
    80001ef4:	079e                	slli	a5,a5,0x7
    80001ef6:	0000fb17          	auipc	s6,0xf
    80001efa:	cfab0b13          	addi	s6,s6,-774 # 80010bf0 <pid_lock>
    80001efe:	9b3e                	add	s6,s6,a5
              c->kthread = 0;
                                printf("33in scheduler333\n");
    80001f00:	00006c97          	auipc	s9,0x6
    80001f04:	350c8c93          	addi	s9,s9,848 # 80008250 <digits+0x210>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f08:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f0c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f10:	10079073          	csrw	sstatus,a5
    printf("in scheduler\n");
    80001f14:	856e                	mv	a0,s11
    80001f16:	ffffe097          	auipc	ra,0xffffe
    80001f1a:	672080e7          	jalr	1650(ra) # 80000588 <printf>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f1e:	0000f497          	auipc	s1,0xf
    80001f22:	12a48493          	addi	s1,s1,298 # 80011048 <proc+0x28>
      if (p->state==USED){
    80001f26:	4985                	li	s3,1
            if(kt->t_state == RUNNABLE_t) {
    80001f28:	4a8d                	li	s5,3
              kt->t_state = RUNNING_t;
    80001f2a:	4b91                	li	s7,4
    80001f2c:	a811                	j	80001f40 <scheduler+0xa2>

            }
        release(&kt->t_lock); // Release the thread lock
    80001f2e:	854a                	mv	a0,s2
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	d5a080e7          	jalr	-678(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f38:	1c048493          	addi	s1,s1,448
    80001f3c:	fc9a06e3          	beq	s4,s1,80001f08 <scheduler+0x6a>
      if (p->state==USED){
    80001f40:	8926                	mv	s2,s1
    80001f42:	ff04a783          	lw	a5,-16(s1)
    80001f46:	ff3799e3          	bne	a5,s3,80001f38 <scheduler+0x9a>
          acquire(&kt->t_lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	c8a080e7          	jalr	-886(ra) # 80000bd6 <acquire>
            if(kt->t_state == RUNNABLE_t) {
    80001f54:	4c9c                	lw	a5,24(s1)
    80001f56:	fd579ce3          	bne	a5,s5,80001f2e <scheduler+0x90>
                  printf("22in scheduler222\n");
    80001f5a:	856a                	mv	a0,s10
    80001f5c:	ffffe097          	auipc	ra,0xffffe
    80001f60:	62c080e7          	jalr	1580(ra) # 80000588 <printf>
              kt->t_state = RUNNING_t;
    80001f64:	0174ac23          	sw	s7,24(s1)
              c->kthread=kt;
    80001f68:	029b3823          	sd	s1,48(s6)
              swtch(&c->context, &kt->context);
    80001f6c:	04048593          	addi	a1,s1,64
    80001f70:	8562                	mv	a0,s8
    80001f72:	00001097          	auipc	ra,0x1
    80001f76:	99a080e7          	jalr	-1638(ra) # 8000290c <swtch>
              c->kthread = 0;
    80001f7a:	020b3823          	sd	zero,48(s6)
                                printf("33in scheduler333\n");
    80001f7e:	8566                	mv	a0,s9
    80001f80:	ffffe097          	auipc	ra,0xffffe
    80001f84:	608080e7          	jalr	1544(ra) # 80000588 <printf>
    80001f88:	b75d                	j	80001f2e <scheduler+0x90>

0000000080001f8a <sched>:
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    80001f8a:	7179                	addi	sp,sp,-48
    80001f8c:	f406                	sd	ra,40(sp)
    80001f8e:	f022                	sd	s0,32(sp)
    80001f90:	ec26                	sd	s1,24(sp)
    80001f92:	e84a                	sd	s2,16(sp)
    80001f94:	e44e                	sd	s3,8(sp)
    80001f96:	1800                	addi	s0,sp,48
  int intena;
  struct kthread *t = mykthread();
    80001f98:	00000097          	auipc	ra,0x0
    80001f9c:	7f8080e7          	jalr	2040(ra) # 80002790 <mykthread>
    80001fa0:	84aa                	mv	s1,a0

  if(!holding(&t->t_lock))
    80001fa2:	fffff097          	auipc	ra,0xfffff
    80001fa6:	bba080e7          	jalr	-1094(ra) # 80000b5c <holding>
    80001faa:	c93d                	beqz	a0,80002020 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fac:	8792                	mv	a5,tp
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    80001fae:	2781                	sext.w	a5,a5
    80001fb0:	079e                	slli	a5,a5,0x7
    80001fb2:	0000f717          	auipc	a4,0xf
    80001fb6:	c3e70713          	addi	a4,a4,-962 # 80010bf0 <pid_lock>
    80001fba:	97ba                	add	a5,a5,a4
    80001fbc:	0a87a703          	lw	a4,168(a5)
    80001fc0:	4785                	li	a5,1
    80001fc2:	06f71763          	bne	a4,a5,80002030 <sched+0xa6>
    panic("sched locks");
  if(t->t_state == RUNNING_t)
    80001fc6:	4c98                	lw	a4,24(s1)
    80001fc8:	4791                	li	a5,4
    80001fca:	06f70b63          	beq	a4,a5,80002040 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fce:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fd2:	8b89                	andi	a5,a5,2
    panic("sched running");
  if(intr_get())
    80001fd4:	efb5                	bnez	a5,80002050 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fd6:	8792                	mv	a5,tp
    panic("sched interruptible");

  intena = mycpu()->intena;
    80001fd8:	0000f917          	auipc	s2,0xf
    80001fdc:	c1890913          	addi	s2,s2,-1000 # 80010bf0 <pid_lock>
    80001fe0:	2781                	sext.w	a5,a5
    80001fe2:	079e                	slli	a5,a5,0x7
    80001fe4:	97ca                	add	a5,a5,s2
    80001fe6:	0ac7a983          	lw	s3,172(a5)
    80001fea:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80001fec:	2781                	sext.w	a5,a5
    80001fee:	079e                	slli	a5,a5,0x7
    80001ff0:	0000f597          	auipc	a1,0xf
    80001ff4:	c3858593          	addi	a1,a1,-968 # 80010c28 <cpus+0x8>
    80001ff8:	95be                	add	a1,a1,a5
    80001ffa:	04048513          	addi	a0,s1,64
    80001ffe:	00001097          	auipc	ra,0x1
    80002002:	90e080e7          	jalr	-1778(ra) # 8000290c <swtch>
    80002006:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002008:	2781                	sext.w	a5,a5
    8000200a:	079e                	slli	a5,a5,0x7
    8000200c:	97ca                	add	a5,a5,s2
    8000200e:	0b37a623          	sw	s3,172(a5)
}
    80002012:	70a2                	ld	ra,40(sp)
    80002014:	7402                	ld	s0,32(sp)
    80002016:	64e2                	ld	s1,24(sp)
    80002018:	6942                	ld	s2,16(sp)
    8000201a:	69a2                	ld	s3,8(sp)
    8000201c:	6145                	addi	sp,sp,48
    8000201e:	8082                	ret
    panic("sched p->lock");
    80002020:	00006517          	auipc	a0,0x6
    80002024:	24850513          	addi	a0,a0,584 # 80008268 <digits+0x228>
    80002028:	ffffe097          	auipc	ra,0xffffe
    8000202c:	516080e7          	jalr	1302(ra) # 8000053e <panic>
    panic("sched locks");
    80002030:	00006517          	auipc	a0,0x6
    80002034:	24850513          	addi	a0,a0,584 # 80008278 <digits+0x238>
    80002038:	ffffe097          	auipc	ra,0xffffe
    8000203c:	506080e7          	jalr	1286(ra) # 8000053e <panic>
    panic("sched running");
    80002040:	00006517          	auipc	a0,0x6
    80002044:	24850513          	addi	a0,a0,584 # 80008288 <digits+0x248>
    80002048:	ffffe097          	auipc	ra,0xffffe
    8000204c:	4f6080e7          	jalr	1270(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002050:	00006517          	auipc	a0,0x6
    80002054:	24850513          	addi	a0,a0,584 # 80008298 <digits+0x258>
    80002058:	ffffe097          	auipc	ra,0xffffe
    8000205c:	4e6080e7          	jalr	1254(ra) # 8000053e <panic>

0000000080002060 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
    80002060:	1101                	addi	sp,sp,-32
    80002062:	ec06                	sd	ra,24(sp)
    80002064:	e822                	sd	s0,16(sp)
    80002066:	e426                	sd	s1,8(sp)
    80002068:	e04a                	sd	s2,0(sp)
    8000206a:	1000                	addi	s0,sp,32
  printf("in yield\n");
    8000206c:	00006517          	auipc	a0,0x6
    80002070:	24450513          	addi	a0,a0,580 # 800082b0 <digits+0x270>
    80002074:	ffffe097          	auipc	ra,0xffffe
    80002078:	514080e7          	jalr	1300(ra) # 80000588 <printf>
  struct proc *p = myproc();
    8000207c:	00000097          	auipc	ra,0x0
    80002080:	904080e7          	jalr	-1788(ra) # 80001980 <myproc>
    80002084:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	b50080e7          	jalr	-1200(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    8000208e:	02848913          	addi	s2,s1,40
    80002092:	854a                	mv	a0,s2
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	b42080e7          	jalr	-1214(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state = RUNNABLE_t;
    8000209c:	478d                	li	a5,3
    8000209e:	c0bc                	sw	a5,64(s1)
  release(&p->kthread[0].t_lock);
    800020a0:	854a                	mv	a0,s2
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	be8080e7          	jalr	-1048(ra) # 80000c8a <release>
  sched();
    800020aa:	00000097          	auipc	ra,0x0
    800020ae:	ee0080e7          	jalr	-288(ra) # 80001f8a <sched>
  release(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	fffff097          	auipc	ra,0xfffff
    800020b8:	bd6080e7          	jalr	-1066(ra) # 80000c8a <release>
}
    800020bc:	60e2                	ld	ra,24(sp)
    800020be:	6442                	ld	s0,16(sp)
    800020c0:	64a2                	ld	s1,8(sp)
    800020c2:	6902                	ld	s2,0(sp)
    800020c4:	6105                	addi	sp,sp,32
    800020c6:	8082                	ret

00000000800020c8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800020c8:	1141                	addi	sp,sp,-16
    800020ca:	e406                	sd	ra,8(sp)
    800020cc:	e022                	sd	s0,0(sp)
    800020ce:	0800                	addi	s0,sp,16
  printf("forkret\n");
    800020d0:	00006517          	auipc	a0,0x6
    800020d4:	1f050513          	addi	a0,a0,496 # 800082c0 <digits+0x280>
    800020d8:	ffffe097          	auipc	ra,0xffffe
    800020dc:	4b0080e7          	jalr	1200(ra) # 80000588 <printf>
  static int first = 1;
  release(&(mykthread()->t_lock)); //still holding kt->lock from scheduler
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	6b0080e7          	jalr	1712(ra) # 80002790 <mykthread>
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	ba2080e7          	jalr	-1118(ra) # 80000c8a <release>
  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);

  if (first) {
    800020f0:	00006797          	auipc	a5,0x6
    800020f4:	7f07a783          	lw	a5,2032(a5) # 800088e0 <first.1>
    800020f8:	eb89                	bnez	a5,8000210a <forkret+0x42>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800020fa:	00001097          	auipc	ra,0x1
    800020fe:	8bc080e7          	jalr	-1860(ra) # 800029b6 <usertrapret>
}
    80002102:	60a2                	ld	ra,8(sp)
    80002104:	6402                	ld	s0,0(sp)
    80002106:	0141                	addi	sp,sp,16
    80002108:	8082                	ret
    first = 0;
    8000210a:	00006797          	auipc	a5,0x6
    8000210e:	7c07ab23          	sw	zero,2006(a5) # 800088e0 <first.1>
    fsinit(ROOTDEV);
    80002112:	4505                	li	a0,1
    80002114:	00001097          	auipc	ra,0x1
    80002118:	64e080e7          	jalr	1614(ra) # 80003762 <fsinit>
    8000211c:	bff9                	j	800020fa <forkret+0x32>

000000008000211e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000211e:	7179                	addi	sp,sp,-48
    80002120:	f406                	sd	ra,40(sp)
    80002122:	f022                	sd	s0,32(sp)
    80002124:	ec26                	sd	s1,24(sp)
    80002126:	e84a                	sd	s2,16(sp)
    80002128:	e44e                	sd	s3,8(sp)
    8000212a:	e052                	sd	s4,0(sp)
    8000212c:	1800                	addi	s0,sp,48
    8000212e:	89aa                	mv	s3,a0
    80002130:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002132:	00000097          	auipc	ra,0x0
    80002136:	84e080e7          	jalr	-1970(ra) # 80001980 <myproc>
    8000213a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	a9a080e7          	jalr	-1382(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    80002144:	02848a13          	addi	s4,s1,40
    80002148:	8552                	mv	a0,s4
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	a8c080e7          	jalr	-1396(ra) # 80000bd6 <acquire>
  release(lk);
    80002152:	854a                	mv	a0,s2
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	b36080e7          	jalr	-1226(ra) # 80000c8a <release>

  // Go to sleep.
  p->kthread[0].chan = chan;
    8000215c:	0534b423          	sd	s3,72(s1)
  p->kthread[0].t_state = SLEEPING_t;
    80002160:	4789                	li	a5,2
    80002162:	c0bc                	sw	a5,64(s1)

  sched();
    80002164:	00000097          	auipc	ra,0x0
    80002168:	e26080e7          	jalr	-474(ra) # 80001f8a <sched>

  // Tidy up.
  p->kthread[0].chan= 0;
    8000216c:	0404b423          	sd	zero,72(s1)

  // Reacquire original lock.
  release(&p->kthread[0].t_lock);
    80002170:	8552                	mv	a0,s4
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	b18080e7          	jalr	-1256(ra) # 80000c8a <release>
  release(&p->lock);
    8000217a:	8526                	mv	a0,s1
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	b0e080e7          	jalr	-1266(ra) # 80000c8a <release>
  acquire(lk);
    80002184:	854a                	mv	a0,s2
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	a50080e7          	jalr	-1456(ra) # 80000bd6 <acquire>
}
    8000218e:	70a2                	ld	ra,40(sp)
    80002190:	7402                	ld	s0,32(sp)
    80002192:	64e2                	ld	s1,24(sp)
    80002194:	6942                	ld	s2,16(sp)
    80002196:	69a2                	ld	s3,8(sp)
    80002198:	6a02                	ld	s4,0(sp)
    8000219a:	6145                	addi	sp,sp,48
    8000219c:	8082                	ret

000000008000219e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000219e:	711d                	addi	sp,sp,-96
    800021a0:	ec86                	sd	ra,88(sp)
    800021a2:	e8a2                	sd	s0,80(sp)
    800021a4:	e4a6                	sd	s1,72(sp)
    800021a6:	e0ca                	sd	s2,64(sp)
    800021a8:	fc4e                	sd	s3,56(sp)
    800021aa:	f852                	sd	s4,48(sp)
    800021ac:	f456                	sd	s5,40(sp)
    800021ae:	f05a                	sd	s6,32(sp)
    800021b0:	ec5e                	sd	s7,24(sp)
    800021b2:	e862                	sd	s8,16(sp)
    800021b4:	e466                	sd	s9,8(sp)
    800021b6:	1080                	addi	s0,sp,96
    800021b8:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *kt;
  for(p = proc; p < &proc[NPROC]; p++) {
    800021ba:	0000f497          	auipc	s1,0xf
    800021be:	e8e48493          	addi	s1,s1,-370 # 80011048 <proc+0x28>
    800021c2:	00016a97          	auipc	s5,0x16
    800021c6:	e86a8a93          	addi	s5,s5,-378 # 80018048 <bcache+0x10>
              printf("start of wakeup\n");
    800021ca:	00006a17          	auipc	s4,0x6
    800021ce:	106a0a13          	addi	s4,s4,262 # 800082d0 <digits+0x290>
    // acquire(&p->lock);
      printf("in wakeup\n");
    800021d2:	00006997          	auipc	s3,0x6
    800021d6:	11698993          	addi	s3,s3,278 # 800082e8 <digits+0x2a8>
      // acquire(&p->lock);
    for(kt=p->kthread;kt<&p->kthread[NKT];kt++){
        if(kt !=mykthread()){
          acquire(&kt->t_lock);
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    800021da:	4b89                	li	s7,2
          kt->t_state = RUNNABLE_t;
        }
        release(&kt->t_lock);
      // release(&p->lock);
          printf("out wakeup\n");
    800021dc:	00006b17          	auipc	s6,0x6
    800021e0:	11cb0b13          	addi	s6,s6,284 # 800082f8 <digits+0x2b8>
          kt->t_state = RUNNABLE_t;
    800021e4:	4c8d                	li	s9,3
    800021e6:	a839                	j	80002204 <wakeup+0x66>
        release(&kt->t_lock);
    800021e8:	854a                	mv	a0,s2
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	aa0080e7          	jalr	-1376(ra) # 80000c8a <release>
          printf("out wakeup\n");
    800021f2:	855a                	mv	a0,s6
    800021f4:	ffffe097          	auipc	ra,0xffffe
    800021f8:	394080e7          	jalr	916(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021fc:	1c048493          	addi	s1,s1,448
    80002200:	049a8163          	beq	s5,s1,80002242 <wakeup+0xa4>
              printf("start of wakeup\n");
    80002204:	8552                	mv	a0,s4
    80002206:	ffffe097          	auipc	ra,0xffffe
    8000220a:	382080e7          	jalr	898(ra) # 80000588 <printf>
      printf("in wakeup\n");
    8000220e:	854e                	mv	a0,s3
    80002210:	ffffe097          	auipc	ra,0xffffe
    80002214:	378080e7          	jalr	888(ra) # 80000588 <printf>
        if(kt !=mykthread()){
    80002218:	00000097          	auipc	ra,0x0
    8000221c:	578080e7          	jalr	1400(ra) # 80002790 <mykthread>
    80002220:	8926                	mv	s2,s1
    80002222:	fc950de3          	beq	a0,s1,800021fc <wakeup+0x5e>
          acquire(&kt->t_lock);
    80002226:	8526                	mv	a0,s1
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	9ae080e7          	jalr	-1618(ra) # 80000bd6 <acquire>
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    80002230:	4c9c                	lw	a5,24(s1)
    80002232:	fb779be3          	bne	a5,s7,800021e8 <wakeup+0x4a>
    80002236:	709c                	ld	a5,32(s1)
    80002238:	fb8798e3          	bne	a5,s8,800021e8 <wakeup+0x4a>
          kt->t_state = RUNNABLE_t;
    8000223c:	0194ac23          	sw	s9,24(s1)
    80002240:	b765                	j	800021e8 <wakeup+0x4a>

       }
    }
    // release(&p->lock);
  }
}
    80002242:	60e6                	ld	ra,88(sp)
    80002244:	6446                	ld	s0,80(sp)
    80002246:	64a6                	ld	s1,72(sp)
    80002248:	6906                	ld	s2,64(sp)
    8000224a:	79e2                	ld	s3,56(sp)
    8000224c:	7a42                	ld	s4,48(sp)
    8000224e:	7aa2                	ld	s5,40(sp)
    80002250:	7b02                	ld	s6,32(sp)
    80002252:	6be2                	ld	s7,24(sp)
    80002254:	6c42                	ld	s8,16(sp)
    80002256:	6ca2                	ld	s9,8(sp)
    80002258:	6125                	addi	sp,sp,96
    8000225a:	8082                	ret

000000008000225c <reparent>:
{
    8000225c:	7179                	addi	sp,sp,-48
    8000225e:	f406                	sd	ra,40(sp)
    80002260:	f022                	sd	s0,32(sp)
    80002262:	ec26                	sd	s1,24(sp)
    80002264:	e84a                	sd	s2,16(sp)
    80002266:	e44e                	sd	s3,8(sp)
    80002268:	e052                	sd	s4,0(sp)
    8000226a:	1800                	addi	s0,sp,48
    8000226c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000226e:	0000f497          	auipc	s1,0xf
    80002272:	db248493          	addi	s1,s1,-590 # 80011020 <proc>
      pp->parent = initproc;
    80002276:	00006a17          	auipc	s4,0x6
    8000227a:	702a0a13          	addi	s4,s4,1794 # 80008978 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000227e:	00016997          	auipc	s3,0x16
    80002282:	da298993          	addi	s3,s3,-606 # 80018020 <tickslock>
    80002286:	a029                	j	80002290 <reparent+0x34>
    80002288:	1c048493          	addi	s1,s1,448
    8000228c:	01348d63          	beq	s1,s3,800022a6 <reparent+0x4a>
    if(pp->parent == p){
    80002290:	78fc                	ld	a5,240(s1)
    80002292:	ff279be3          	bne	a5,s2,80002288 <reparent+0x2c>
      pp->parent = initproc;
    80002296:	000a3503          	ld	a0,0(s4)
    8000229a:	f8e8                	sd	a0,240(s1)
      wakeup(initproc);
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	f02080e7          	jalr	-254(ra) # 8000219e <wakeup>
    800022a4:	b7d5                	j	80002288 <reparent+0x2c>
}
    800022a6:	70a2                	ld	ra,40(sp)
    800022a8:	7402                	ld	s0,32(sp)
    800022aa:	64e2                	ld	s1,24(sp)
    800022ac:	6942                	ld	s2,16(sp)
    800022ae:	69a2                	ld	s3,8(sp)
    800022b0:	6a02                	ld	s4,0(sp)
    800022b2:	6145                	addi	sp,sp,48
    800022b4:	8082                	ret

00000000800022b6 <exit>:
{
    800022b6:	7179                	addi	sp,sp,-48
    800022b8:	f406                	sd	ra,40(sp)
    800022ba:	f022                	sd	s0,32(sp)
    800022bc:	ec26                	sd	s1,24(sp)
    800022be:	e84a                	sd	s2,16(sp)
    800022c0:	e44e                	sd	s3,8(sp)
    800022c2:	e052                	sd	s4,0(sp)
    800022c4:	1800                	addi	s0,sp,48
    800022c6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	6b8080e7          	jalr	1720(ra) # 80001980 <myproc>
    800022d0:	89aa                	mv	s3,a0
  if(p == initproc)
    800022d2:	00006797          	auipc	a5,0x6
    800022d6:	6a67b783          	ld	a5,1702(a5) # 80008978 <initproc>
    800022da:	10850493          	addi	s1,a0,264
    800022de:	18850913          	addi	s2,a0,392
    800022e2:	02a79363          	bne	a5,a0,80002308 <exit+0x52>
    panic("init exiting");
    800022e6:	00006517          	auipc	a0,0x6
    800022ea:	02250513          	addi	a0,a0,34 # 80008308 <digits+0x2c8>
    800022ee:	ffffe097          	auipc	ra,0xffffe
    800022f2:	250080e7          	jalr	592(ra) # 8000053e <panic>
      fileclose(f);
    800022f6:	00002097          	auipc	ra,0x2
    800022fa:	576080e7          	jalr	1398(ra) # 8000486c <fileclose>
      p->ofile[fd] = 0;
    800022fe:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002302:	04a1                	addi	s1,s1,8
    80002304:	01248563          	beq	s1,s2,8000230e <exit+0x58>
    if(p->ofile[fd]){
    80002308:	6088                	ld	a0,0(s1)
    8000230a:	f575                	bnez	a0,800022f6 <exit+0x40>
    8000230c:	bfdd                	j	80002302 <exit+0x4c>
  begin_op();
    8000230e:	00002097          	auipc	ra,0x2
    80002312:	092080e7          	jalr	146(ra) # 800043a0 <begin_op>
  iput(p->cwd);
    80002316:	1889b503          	ld	a0,392(s3)
    8000231a:	00002097          	auipc	ra,0x2
    8000231e:	87e080e7          	jalr	-1922(ra) # 80003b98 <iput>
  end_op();
    80002322:	00002097          	auipc	ra,0x2
    80002326:	0fe080e7          	jalr	254(ra) # 80004420 <end_op>
  p->cwd = 0;
    8000232a:	1809b423          	sd	zero,392(s3)
  acquire(&wait_lock);
    8000232e:	0000f497          	auipc	s1,0xf
    80002332:	8da48493          	addi	s1,s1,-1830 # 80010c08 <wait_lock>
    80002336:	8526                	mv	a0,s1
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	89e080e7          	jalr	-1890(ra) # 80000bd6 <acquire>
  reparent(p);
    80002340:	854e                	mv	a0,s3
    80002342:	00000097          	auipc	ra,0x0
    80002346:	f1a080e7          	jalr	-230(ra) # 8000225c <reparent>
  wakeup(p->parent);
    8000234a:	0f09b503          	ld	a0,240(s3)
    8000234e:	00000097          	auipc	ra,0x0
    80002352:	e50080e7          	jalr	-432(ra) # 8000219e <wakeup>
  acquire(&p->lock);
    80002356:	854e                	mv	a0,s3
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	87e080e7          	jalr	-1922(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    80002360:	02898913          	addi	s2,s3,40
    80002364:	854a                	mv	a0,s2
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	870080e7          	jalr	-1936(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state=ZOMBIE_t;
    8000236e:	4795                	li	a5,5
    80002370:	04f9a023          	sw	a5,64(s3)
  release(&p->kthread[0].t_lock);
    80002374:	854a                	mv	a0,s2
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	914080e7          	jalr	-1772(ra) # 80000c8a <release>
  p->xstate = status;
    8000237e:	0349a023          	sw	s4,32(s3)
  p->state = ZOMBIE;
    80002382:	4789                	li	a5,2
    80002384:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002388:	8526                	mv	a0,s1
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	900080e7          	jalr	-1792(ra) # 80000c8a <release>
  sched();
    80002392:	00000097          	auipc	ra,0x0
    80002396:	bf8080e7          	jalr	-1032(ra) # 80001f8a <sched>
  panic("zombie exit");
    8000239a:	00006517          	auipc	a0,0x6
    8000239e:	f7e50513          	addi	a0,a0,-130 # 80008318 <digits+0x2d8>
    800023a2:	ffffe097          	auipc	ra,0xffffe
    800023a6:	19c080e7          	jalr	412(ra) # 8000053e <panic>

00000000800023aa <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023aa:	7179                	addi	sp,sp,-48
    800023ac:	f406                	sd	ra,40(sp)
    800023ae:	f022                	sd	s0,32(sp)
    800023b0:	ec26                	sd	s1,24(sp)
    800023b2:	e84a                	sd	s2,16(sp)
    800023b4:	e44e                	sd	s3,8(sp)
    800023b6:	1800                	addi	s0,sp,48
    800023b8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023ba:	0000f497          	auipc	s1,0xf
    800023be:	c6648493          	addi	s1,s1,-922 # 80011020 <proc>
    800023c2:	00016997          	auipc	s3,0x16
    800023c6:	c5e98993          	addi	s3,s3,-930 # 80018020 <tickslock>
    acquire(&p->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	80a080e7          	jalr	-2038(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800023d4:	50dc                	lw	a5,36(s1)
    800023d6:	01278d63          	beq	a5,s2,800023f0 <kill+0x46>
      // }
      release(&p->lock);
      return 0;
    }
    
    release(&p->lock);
    800023da:	8526                	mv	a0,s1
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	8ae080e7          	jalr	-1874(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023e4:	1c048493          	addi	s1,s1,448
    800023e8:	ff3491e3          	bne	s1,s3,800023ca <kill+0x20>
  }
  return -1;
    800023ec:	557d                	li	a0,-1
    800023ee:	a80d                	j	80002420 <kill+0x76>
      p->killed = 1;
    800023f0:	4785                	li	a5,1
    800023f2:	ccdc                	sw	a5,28(s1)
        acquire(&t->t_lock);
    800023f4:	02848913          	addi	s2,s1,40
    800023f8:	854a                	mv	a0,s2
    800023fa:	ffffe097          	auipc	ra,0xffffe
    800023fe:	7dc080e7          	jalr	2012(ra) # 80000bd6 <acquire>
        if(t->t_state == SLEEPING_t) {
    80002402:	40b8                	lw	a4,64(s1)
    80002404:	4789                	li	a5,2
    80002406:	02f70463          	beq	a4,a5,8000242e <kill+0x84>
        release(&t->t_lock);
    8000240a:	854a                	mv	a0,s2
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	87e080e7          	jalr	-1922(ra) # 80000c8a <release>
      release(&p->lock);
    80002414:	8526                	mv	a0,s1
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	874080e7          	jalr	-1932(ra) # 80000c8a <release>
      return 0;
    8000241e:	4501                	li	a0,0
}
    80002420:	70a2                	ld	ra,40(sp)
    80002422:	7402                	ld	s0,32(sp)
    80002424:	64e2                	ld	s1,24(sp)
    80002426:	6942                	ld	s2,16(sp)
    80002428:	69a2                	ld	s3,8(sp)
    8000242a:	6145                	addi	sp,sp,48
    8000242c:	8082                	ret
          t->t_state = RUNNABLE_t;
    8000242e:	478d                	li	a5,3
    80002430:	c0bc                	sw	a5,64(s1)
    80002432:	bfe1                	j	8000240a <kill+0x60>

0000000080002434 <setkilled>:


void
setkilled(struct proc *p)
{
    80002434:	1101                	addi	sp,sp,-32
    80002436:	ec06                	sd	ra,24(sp)
    80002438:	e822                	sd	s0,16(sp)
    8000243a:	e426                	sd	s1,8(sp)
    8000243c:	1000                	addi	s0,sp,32
    8000243e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002440:	ffffe097          	auipc	ra,0xffffe
    80002444:	796080e7          	jalr	1942(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002448:	4785                	li	a5,1
    8000244a:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    8000244c:	8526                	mv	a0,s1
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	83c080e7          	jalr	-1988(ra) # 80000c8a <release>
}
    80002456:	60e2                	ld	ra,24(sp)
    80002458:	6442                	ld	s0,16(sp)
    8000245a:	64a2                	ld	s1,8(sp)
    8000245c:	6105                	addi	sp,sp,32
    8000245e:	8082                	ret

0000000080002460 <killed>:

int
killed(struct proc *p)
{
    80002460:	1101                	addi	sp,sp,-32
    80002462:	ec06                	sd	ra,24(sp)
    80002464:	e822                	sd	s0,16(sp)
    80002466:	e426                	sd	s1,8(sp)
    80002468:	e04a                	sd	s2,0(sp)
    8000246a:	1000                	addi	s0,sp,32
    8000246c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000246e:	ffffe097          	auipc	ra,0xffffe
    80002472:	768080e7          	jalr	1896(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002476:	01c4a903          	lw	s2,28(s1)
  release(&p->lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	80e080e7          	jalr	-2034(ra) # 80000c8a <release>
  return k;
}
    80002484:	854a                	mv	a0,s2
    80002486:	60e2                	ld	ra,24(sp)
    80002488:	6442                	ld	s0,16(sp)
    8000248a:	64a2                	ld	s1,8(sp)
    8000248c:	6902                	ld	s2,0(sp)
    8000248e:	6105                	addi	sp,sp,32
    80002490:	8082                	ret

0000000080002492 <wait>:
{
    80002492:	715d                	addi	sp,sp,-80
    80002494:	e486                	sd	ra,72(sp)
    80002496:	e0a2                	sd	s0,64(sp)
    80002498:	fc26                	sd	s1,56(sp)
    8000249a:	f84a                	sd	s2,48(sp)
    8000249c:	f44e                	sd	s3,40(sp)
    8000249e:	f052                	sd	s4,32(sp)
    800024a0:	ec56                	sd	s5,24(sp)
    800024a2:	e85a                	sd	s6,16(sp)
    800024a4:	e45e                	sd	s7,8(sp)
    800024a6:	e062                	sd	s8,0(sp)
    800024a8:	0880                	addi	s0,sp,80
    800024aa:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024ac:	fffff097          	auipc	ra,0xfffff
    800024b0:	4d4080e7          	jalr	1236(ra) # 80001980 <myproc>
    800024b4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024b6:	0000e517          	auipc	a0,0xe
    800024ba:	75250513          	addi	a0,a0,1874 # 80010c08 <wait_lock>
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	718080e7          	jalr	1816(ra) # 80000bd6 <acquire>
    havekids = 0;
    800024c6:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800024c8:	4a09                	li	s4,2
        havekids = 1;
    800024ca:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024cc:	00016997          	auipc	s3,0x16
    800024d0:	b5498993          	addi	s3,s3,-1196 # 80018020 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024d4:	0000ec17          	auipc	s8,0xe
    800024d8:	734c0c13          	addi	s8,s8,1844 # 80010c08 <wait_lock>
    havekids = 0;
    800024dc:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024de:	0000f497          	auipc	s1,0xf
    800024e2:	b4248493          	addi	s1,s1,-1214 # 80011020 <proc>
    800024e6:	a0bd                	j	80002554 <wait+0xc2>
          pid = pp->pid;
    800024e8:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024ec:	000b0e63          	beqz	s6,80002508 <wait+0x76>
    800024f0:	4691                	li	a3,4
    800024f2:	02048613          	addi	a2,s1,32
    800024f6:	85da                	mv	a1,s6
    800024f8:	10093503          	ld	a0,256(s2)
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	16c080e7          	jalr	364(ra) # 80001668 <copyout>
    80002504:	02054563          	bltz	a0,8000252e <wait+0x9c>
          freeproc(pp);
    80002508:	8526                	mv	a0,s1
    8000250a:	fffff097          	auipc	ra,0xfffff
    8000250e:	5e6080e7          	jalr	1510(ra) # 80001af0 <freeproc>
          release(&pp->lock);
    80002512:	8526                	mv	a0,s1
    80002514:	ffffe097          	auipc	ra,0xffffe
    80002518:	776080e7          	jalr	1910(ra) # 80000c8a <release>
          release(&wait_lock);
    8000251c:	0000e517          	auipc	a0,0xe
    80002520:	6ec50513          	addi	a0,a0,1772 # 80010c08 <wait_lock>
    80002524:	ffffe097          	auipc	ra,0xffffe
    80002528:	766080e7          	jalr	1894(ra) # 80000c8a <release>
          return pid;
    8000252c:	a0b5                	j	80002598 <wait+0x106>
            release(&pp->lock);
    8000252e:	8526                	mv	a0,s1
    80002530:	ffffe097          	auipc	ra,0xffffe
    80002534:	75a080e7          	jalr	1882(ra) # 80000c8a <release>
            release(&wait_lock);
    80002538:	0000e517          	auipc	a0,0xe
    8000253c:	6d050513          	addi	a0,a0,1744 # 80010c08 <wait_lock>
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	74a080e7          	jalr	1866(ra) # 80000c8a <release>
            return -1;
    80002548:	59fd                	li	s3,-1
    8000254a:	a0b9                	j	80002598 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000254c:	1c048493          	addi	s1,s1,448
    80002550:	03348463          	beq	s1,s3,80002578 <wait+0xe6>
      if(pp->parent == p){
    80002554:	78fc                	ld	a5,240(s1)
    80002556:	ff279be3          	bne	a5,s2,8000254c <wait+0xba>
        acquire(&pp->lock);
    8000255a:	8526                	mv	a0,s1
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	67a080e7          	jalr	1658(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002564:	4c9c                	lw	a5,24(s1)
    80002566:	f94781e3          	beq	a5,s4,800024e8 <wait+0x56>
        release(&pp->lock);
    8000256a:	8526                	mv	a0,s1
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	71e080e7          	jalr	1822(ra) # 80000c8a <release>
        havekids = 1;
    80002574:	8756                	mv	a4,s5
    80002576:	bfd9                	j	8000254c <wait+0xba>
    if(!havekids || killed(p)){
    80002578:	c719                	beqz	a4,80002586 <wait+0xf4>
    8000257a:	854a                	mv	a0,s2
    8000257c:	00000097          	auipc	ra,0x0
    80002580:	ee4080e7          	jalr	-284(ra) # 80002460 <killed>
    80002584:	c51d                	beqz	a0,800025b2 <wait+0x120>
      release(&wait_lock);
    80002586:	0000e517          	auipc	a0,0xe
    8000258a:	68250513          	addi	a0,a0,1666 # 80010c08 <wait_lock>
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	6fc080e7          	jalr	1788(ra) # 80000c8a <release>
      return -1;
    80002596:	59fd                	li	s3,-1
}
    80002598:	854e                	mv	a0,s3
    8000259a:	60a6                	ld	ra,72(sp)
    8000259c:	6406                	ld	s0,64(sp)
    8000259e:	74e2                	ld	s1,56(sp)
    800025a0:	7942                	ld	s2,48(sp)
    800025a2:	79a2                	ld	s3,40(sp)
    800025a4:	7a02                	ld	s4,32(sp)
    800025a6:	6ae2                	ld	s5,24(sp)
    800025a8:	6b42                	ld	s6,16(sp)
    800025aa:	6ba2                	ld	s7,8(sp)
    800025ac:	6c02                	ld	s8,0(sp)
    800025ae:	6161                	addi	sp,sp,80
    800025b0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025b2:	85e2                	mv	a1,s8
    800025b4:	854a                	mv	a0,s2
    800025b6:	00000097          	auipc	ra,0x0
    800025ba:	b68080e7          	jalr	-1176(ra) # 8000211e <sleep>
    havekids = 0;
    800025be:	bf39                	j	800024dc <wait+0x4a>

00000000800025c0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025c0:	7179                	addi	sp,sp,-48
    800025c2:	f406                	sd	ra,40(sp)
    800025c4:	f022                	sd	s0,32(sp)
    800025c6:	ec26                	sd	s1,24(sp)
    800025c8:	e84a                	sd	s2,16(sp)
    800025ca:	e44e                	sd	s3,8(sp)
    800025cc:	e052                	sd	s4,0(sp)
    800025ce:	1800                	addi	s0,sp,48
    800025d0:	84aa                	mv	s1,a0
    800025d2:	892e                	mv	s2,a1
    800025d4:	89b2                	mv	s3,a2
    800025d6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025d8:	fffff097          	auipc	ra,0xfffff
    800025dc:	3a8080e7          	jalr	936(ra) # 80001980 <myproc>
  if(user_dst){
    800025e0:	c095                	beqz	s1,80002604 <either_copyout+0x44>
    return copyout(p->pagetable, dst, src, len);
    800025e2:	86d2                	mv	a3,s4
    800025e4:	864e                	mv	a2,s3
    800025e6:	85ca                	mv	a1,s2
    800025e8:	10053503          	ld	a0,256(a0)
    800025ec:	fffff097          	auipc	ra,0xfffff
    800025f0:	07c080e7          	jalr	124(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025f4:	70a2                	ld	ra,40(sp)
    800025f6:	7402                	ld	s0,32(sp)
    800025f8:	64e2                	ld	s1,24(sp)
    800025fa:	6942                	ld	s2,16(sp)
    800025fc:	69a2                	ld	s3,8(sp)
    800025fe:	6a02                	ld	s4,0(sp)
    80002600:	6145                	addi	sp,sp,48
    80002602:	8082                	ret
    memmove((char *)dst, src, len);
    80002604:	000a061b          	sext.w	a2,s4
    80002608:	85ce                	mv	a1,s3
    8000260a:	854a                	mv	a0,s2
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	722080e7          	jalr	1826(ra) # 80000d2e <memmove>
    return 0;
    80002614:	8526                	mv	a0,s1
    80002616:	bff9                	j	800025f4 <either_copyout+0x34>

0000000080002618 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002618:	7179                	addi	sp,sp,-48
    8000261a:	f406                	sd	ra,40(sp)
    8000261c:	f022                	sd	s0,32(sp)
    8000261e:	ec26                	sd	s1,24(sp)
    80002620:	e84a                	sd	s2,16(sp)
    80002622:	e44e                	sd	s3,8(sp)
    80002624:	e052                	sd	s4,0(sp)
    80002626:	1800                	addi	s0,sp,48
    80002628:	892a                	mv	s2,a0
    8000262a:	84ae                	mv	s1,a1
    8000262c:	89b2                	mv	s3,a2
    8000262e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002630:	fffff097          	auipc	ra,0xfffff
    80002634:	350080e7          	jalr	848(ra) # 80001980 <myproc>
  if(user_src){
    80002638:	c095                	beqz	s1,8000265c <either_copyin+0x44>
    return copyin(p->pagetable, dst, src, len);
    8000263a:	86d2                	mv	a3,s4
    8000263c:	864e                	mv	a2,s3
    8000263e:	85ca                	mv	a1,s2
    80002640:	10053503          	ld	a0,256(a0)
    80002644:	fffff097          	auipc	ra,0xfffff
    80002648:	0b0080e7          	jalr	176(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000264c:	70a2                	ld	ra,40(sp)
    8000264e:	7402                	ld	s0,32(sp)
    80002650:	64e2                	ld	s1,24(sp)
    80002652:	6942                	ld	s2,16(sp)
    80002654:	69a2                	ld	s3,8(sp)
    80002656:	6a02                	ld	s4,0(sp)
    80002658:	6145                	addi	sp,sp,48
    8000265a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000265c:	000a061b          	sext.w	a2,s4
    80002660:	85ce                	mv	a1,s3
    80002662:	854a                	mv	a0,s2
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	6ca080e7          	jalr	1738(ra) # 80000d2e <memmove>
    return 0;
    8000266c:	8526                	mv	a0,s1
    8000266e:	bff9                	j	8000264c <either_copyin+0x34>

0000000080002670 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002670:	715d                	addi	sp,sp,-80
    80002672:	e486                	sd	ra,72(sp)
    80002674:	e0a2                	sd	s0,64(sp)
    80002676:	fc26                	sd	s1,56(sp)
    80002678:	f84a                	sd	s2,48(sp)
    8000267a:	f44e                	sd	s3,40(sp)
    8000267c:	f052                	sd	s4,32(sp)
    8000267e:	ec56                	sd	s5,24(sp)
    80002680:	e85a                	sd	s6,16(sp)
    80002682:	e45e                	sd	s7,8(sp)
    80002684:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002686:	00006517          	auipc	a0,0x6
    8000268a:	c3250513          	addi	a0,a0,-974 # 800082b8 <digits+0x278>
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	efa080e7          	jalr	-262(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002696:	0000f497          	auipc	s1,0xf
    8000269a:	b1a48493          	addi	s1,s1,-1254 # 800111b0 <proc+0x190>
    8000269e:	00016917          	auipc	s2,0x16
    800026a2:	b1290913          	addi	s2,s2,-1262 # 800181b0 <bcache+0x178>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026a6:	4b09                	li	s6,2
      state = states[p->state];
    else
      state = "???";
    800026a8:	00006997          	auipc	s3,0x6
    800026ac:	c8098993          	addi	s3,s3,-896 # 80008328 <digits+0x2e8>
    printf("%d %s %s", p->pid, state, p->name);
    800026b0:	00006a97          	auipc	s5,0x6
    800026b4:	c80a8a93          	addi	s5,s5,-896 # 80008330 <digits+0x2f0>
    printf("\n");
    800026b8:	00006a17          	auipc	s4,0x6
    800026bc:	c00a0a13          	addi	s4,s4,-1024 # 800082b8 <digits+0x278>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026c0:	00006b97          	auipc	s7,0x6
    800026c4:	c98b8b93          	addi	s7,s7,-872 # 80008358 <states.0>
    800026c8:	a00d                	j	800026ea <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026ca:	e946a583          	lw	a1,-364(a3)
    800026ce:	8556                	mv	a0,s5
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	eb8080e7          	jalr	-328(ra) # 80000588 <printf>
    printf("\n");
    800026d8:	8552                	mv	a0,s4
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	eae080e7          	jalr	-338(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026e2:	1c048493          	addi	s1,s1,448
    800026e6:	03248163          	beq	s1,s2,80002708 <procdump+0x98>
    if(p->state == UNUSED)
    800026ea:	86a6                	mv	a3,s1
    800026ec:	e884a783          	lw	a5,-376(s1)
    800026f0:	dbed                	beqz	a5,800026e2 <procdump+0x72>
      state = "???";
    800026f2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026f4:	fcfb6be3          	bltu	s6,a5,800026ca <procdump+0x5a>
    800026f8:	1782                	slli	a5,a5,0x20
    800026fa:	9381                	srli	a5,a5,0x20
    800026fc:	078e                	slli	a5,a5,0x3
    800026fe:	97de                	add	a5,a5,s7
    80002700:	6390                	ld	a2,0(a5)
    80002702:	f661                	bnez	a2,800026ca <procdump+0x5a>
      state = "???";
    80002704:	864e                	mv	a2,s3
    80002706:	b7d1                	j	800026ca <procdump+0x5a>
  }
}
    80002708:	60a6                	ld	ra,72(sp)
    8000270a:	6406                	ld	s0,64(sp)
    8000270c:	74e2                	ld	s1,56(sp)
    8000270e:	7942                	ld	s2,48(sp)
    80002710:	79a2                	ld	s3,40(sp)
    80002712:	7a02                	ld	s4,32(sp)
    80002714:	6ae2                	ld	s5,24(sp)
    80002716:	6b42                	ld	s6,16(sp)
    80002718:	6ba2                	ld	s7,8(sp)
    8000271a:	6161                	addi	sp,sp,80
    8000271c:	8082                	ret

000000008000271e <kthreadinit>:
#include "defs.h"

extern struct proc proc[NPROC];
extern void forkret(void);
void kthreadinit(struct proc *p)
{
    8000271e:	1101                	addi	sp,sp,-32
    80002720:	ec06                	sd	ra,24(sp)
    80002722:	e822                	sd	s0,16(sp)
    80002724:	e426                	sd	s1,8(sp)
    80002726:	1000                	addi	s0,sp,32
    80002728:	84aa                	mv	s1,a0
  initlock(&(p->alloc_lock),"aloc_thread");
    8000272a:	00006597          	auipc	a1,0x6
    8000272e:	c4658593          	addi	a1,a1,-954 # 80008370 <states.0+0x18>
    80002732:	1a850513          	addi	a0,a0,424
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	410080e7          	jalr	1040(ra) # 80000b46 <initlock>
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
    8000273e:	00006597          	auipc	a1,0x6
    80002742:	c4258593          	addi	a1,a1,-958 # 80008380 <states.0+0x28>
    80002746:	02848513          	addi	a0,s1,40
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	3fc080e7          	jalr	1020(ra) # 80000b46 <initlock>
      kt->t_state = UNUSED_t;
    80002752:	0404a023          	sw	zero,64(s1)
      kt->process=p;
    80002756:	f0a4                	sd	s1,96(s1)
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    80002758:	0000f797          	auipc	a5,0xf
    8000275c:	8c878793          	addi	a5,a5,-1848 # 80011020 <proc>
    80002760:	40f487b3          	sub	a5,s1,a5
    80002764:	8799                	srai	a5,a5,0x6
    80002766:	00006717          	auipc	a4,0x6
    8000276a:	89a73703          	ld	a4,-1894(a4) # 80008000 <etext>
    8000276e:	02e787b3          	mul	a5,a5,a4
    80002772:	2785                	addiw	a5,a5,1
    80002774:	00d7979b          	slliw	a5,a5,0xd
    80002778:	04000737          	lui	a4,0x4000
    8000277c:	177d                	addi	a4,a4,-1
    8000277e:	0732                	slli	a4,a4,0xc
    80002780:	40f707b3          	sub	a5,a4,a5
    80002784:	ecfc                	sd	a5,216(s1)
  }
}
    80002786:	60e2                	ld	ra,24(sp)
    80002788:	6442                	ld	s0,16(sp)
    8000278a:	64a2                	ld	s1,8(sp)
    8000278c:	6105                	addi	sp,sp,32
    8000278e:	8082                	ret

0000000080002790 <mykthread>:

struct kthread *mykthread()
{
    80002790:	1101                	addi	sp,sp,-32
    80002792:	ec06                	sd	ra,24(sp)
    80002794:	e822                	sd	s0,16(sp)
    80002796:	e426                	sd	s1,8(sp)
    80002798:	1000                	addi	s0,sp,32
  push_off();
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	3f0080e7          	jalr	1008(ra) # 80000b8a <push_off>
  struct cpu *c = mycpu();
    800027a2:	fffff097          	auipc	ra,0xfffff
    800027a6:	1c2080e7          	jalr	450(ra) # 80001964 <mycpu>
  struct kthread *kthread = c->kthread;
    800027aa:	6104                	ld	s1,0(a0)
  pop_off();
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	47e080e7          	jalr	1150(ra) # 80000c2a <pop_off>
  return kthread;
}
    800027b4:	8526                	mv	a0,s1
    800027b6:	60e2                	ld	ra,24(sp)
    800027b8:	6442                	ld	s0,16(sp)
    800027ba:	64a2                	ld	s1,8(sp)
    800027bc:	6105                	addi	sp,sp,32
    800027be:	8082                	ret

00000000800027c0 <alloctid>:

int alloctid(struct proc *p){
    800027c0:	7179                	addi	sp,sp,-48
    800027c2:	f406                	sd	ra,40(sp)
    800027c4:	f022                	sd	s0,32(sp)
    800027c6:	ec26                	sd	s1,24(sp)
    800027c8:	e84a                	sd	s2,16(sp)
    800027ca:	e44e                	sd	s3,8(sp)
    800027cc:	1800                	addi	s0,sp,48
    800027ce:	84aa                	mv	s1,a0
  int tid;
  acquire(&(p->alloc_lock));
    800027d0:	1a850993          	addi	s3,a0,424
    800027d4:	854e                	mv	a0,s3
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	400080e7          	jalr	1024(ra) # 80000bd6 <acquire>
  tid = p->p_counter;
    800027de:	1a04a903          	lw	s2,416(s1)
  p->p_counter++;
    800027e2:	0019079b          	addiw	a5,s2,1
    800027e6:	1af4a023          	sw	a5,416(s1)
  release(&(p->alloc_lock));
    800027ea:	854e                	mv	a0,s3
    800027ec:	ffffe097          	auipc	ra,0xffffe
    800027f0:	49e080e7          	jalr	1182(ra) # 80000c8a <release>
  return tid;
}
    800027f4:	854a                	mv	a0,s2
    800027f6:	70a2                	ld	ra,40(sp)
    800027f8:	7402                	ld	s0,32(sp)
    800027fa:	64e2                	ld	s1,24(sp)
    800027fc:	6942                	ld	s2,16(sp)
    800027fe:	69a2                	ld	s3,8(sp)
    80002800:	6145                	addi	sp,sp,48
    80002802:	8082                	ret

0000000080002804 <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    80002804:	1141                	addi	sp,sp,-16
    80002806:	e422                	sd	s0,8(sp)
    80002808:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    8000280a:	02850793          	addi	a5,a0,40
    8000280e:	8d9d                	sub	a1,a1,a5
    80002810:	8599                	srai	a1,a1,0x6
    80002812:	00005797          	auipc	a5,0x5
    80002816:	7f67b783          	ld	a5,2038(a5) # 80008008 <etext+0x8>
    8000281a:	02f585bb          	mulw	a1,a1,a5
    8000281e:	00359793          	slli	a5,a1,0x3
    80002822:	95be                	add	a1,a1,a5
    80002824:	0596                	slli	a1,a1,0x5
    80002826:	7568                	ld	a0,232(a0)
}
    80002828:	952e                	add	a0,a0,a1
    8000282a:	6422                	ld	s0,8(sp)
    8000282c:	0141                	addi	sp,sp,16
    8000282e:	8082                	ret

0000000080002830 <allockthread>:

struct kthread* allockthread(struct proc *p){
    80002830:	1101                	addi	sp,sp,-32
    80002832:	ec06                	sd	ra,24(sp)
    80002834:	e822                	sd	s0,16(sp)
    80002836:	e426                	sd	s1,8(sp)
    80002838:	e04a                	sd	s2,0(sp)
    8000283a:	1000                	addi	s0,sp,32
    8000283c:	84aa                	mv	s1,a0
  
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    8000283e:	02850913          	addi	s2,a0,40
    {
      acquire(&kt->t_lock);
    80002842:	854a                	mv	a0,s2
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	392080e7          	jalr	914(ra) # 80000bd6 <acquire>
      if(kt->t_state == UNUSED_t) {
    8000284c:	40bc                	lw	a5,64(s1)
    8000284e:	cf91                	beqz	a5,8000286a <allockthread+0x3a>
        kt->context.ra = (uint64)forkret;
        kt->context.sp = kt->kstack + PGSIZE;
        return kt;
      } 
      else {
        release(&kt->t_lock);
    80002850:	854a                	mv	a0,s2
    80002852:	ffffe097          	auipc	ra,0xffffe
    80002856:	438080e7          	jalr	1080(ra) # 80000c8a <release>
      }
  }
  return 0;
    8000285a:	4901                	li	s2,0
}
    8000285c:	854a                	mv	a0,s2
    8000285e:	60e2                	ld	ra,24(sp)
    80002860:	6442                	ld	s0,16(sp)
    80002862:	64a2                	ld	s1,8(sp)
    80002864:	6902                	ld	s2,0(sp)
    80002866:	6105                	addi	sp,sp,32
    80002868:	8082                	ret
        kt->tid = alloctid(p);
    8000286a:	8526                	mv	a0,s1
    8000286c:	00000097          	auipc	ra,0x0
    80002870:	f54080e7          	jalr	-172(ra) # 800027c0 <alloctid>
    80002874:	cca8                	sw	a0,88(s1)
        kt->t_state = USED_t;
    80002876:	4785                	li	a5,1
    80002878:	c0bc                	sw	a5,64(s1)
        kt->process=p;
    8000287a:	f0a4                	sd	s1,96(s1)
        kt->trapframe = get_kthread_trapframe(p,kt);
    8000287c:	85ca                	mv	a1,s2
    8000287e:	8526                	mv	a0,s1
    80002880:	00000097          	auipc	ra,0x0
    80002884:	f84080e7          	jalr	-124(ra) # 80002804 <get_kthread_trapframe>
    80002888:	f0e8                	sd	a0,224(s1)
        memset(&kt->context, 0, sizeof(kt->context));   
    8000288a:	07000613          	li	a2,112
    8000288e:	4581                	li	a1,0
    80002890:	06848513          	addi	a0,s1,104
    80002894:	ffffe097          	auipc	ra,0xffffe
    80002898:	43e080e7          	jalr	1086(ra) # 80000cd2 <memset>
        kt->context.ra = (uint64)forkret;
    8000289c:	00000797          	auipc	a5,0x0
    800028a0:	82c78793          	addi	a5,a5,-2004 # 800020c8 <forkret>
    800028a4:	f4bc                	sd	a5,104(s1)
        kt->context.sp = kt->kstack + PGSIZE;
    800028a6:	6cfc                	ld	a5,216(s1)
    800028a8:	6705                	lui	a4,0x1
    800028aa:	97ba                	add	a5,a5,a4
    800028ac:	f8bc                	sd	a5,112(s1)
        return kt;
    800028ae:	b77d                	j	8000285c <allockthread+0x2c>

00000000800028b0 <freethread>:

void
freethread(struct kthread *t){
    800028b0:	1101                	addi	sp,sp,-32
    800028b2:	ec06                	sd	ra,24(sp)
    800028b4:	e822                	sd	s0,16(sp)
    800028b6:	e426                	sd	s1,8(sp)
    800028b8:	1000                	addi	s0,sp,32
    800028ba:	84aa                	mv	s1,a0
  t->chan = 0;
    800028bc:	02053023          	sd	zero,32(a0)
  t->t_killed = 0;
    800028c0:	02052423          	sw	zero,40(a0)
  t->t_xstate = 0;
    800028c4:	02052623          	sw	zero,44(a0)
  t->t_state = UNUSED_t;
    800028c8:	00052c23          	sw	zero,24(a0)
  t->tid=0;
    800028cc:	02052823          	sw	zero,48(a0)
  t->process=0;
    800028d0:	02053c23          	sd	zero,56(a0)
  t->kstack=0;
    800028d4:	0a053823          	sd	zero,176(a0)
  if(t->trapframe)
    800028d8:	7d48                	ld	a0,184(a0)
    800028da:	c509                	beqz	a0,800028e4 <freethread+0x34>
    kfree((void*)t->trapframe);
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	10e080e7          	jalr	270(ra) # 800009ea <kfree>
  t->trapframe = 0;
    800028e4:	0a04bc23          	sd	zero,184(s1)
  memset(&t->context,0,sizeof(&t->context));
    800028e8:	4621                	li	a2,8
    800028ea:	4581                	li	a1,0
    800028ec:	04048513          	addi	a0,s1,64
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	3e2080e7          	jalr	994(ra) # 80000cd2 <memset>
  release(&t->t_lock);
    800028f8:	8526                	mv	a0,s1
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	390080e7          	jalr	912(ra) # 80000c8a <release>
}
    80002902:	60e2                	ld	ra,24(sp)
    80002904:	6442                	ld	s0,16(sp)
    80002906:	64a2                	ld	s1,8(sp)
    80002908:	6105                	addi	sp,sp,32
    8000290a:	8082                	ret

000000008000290c <swtch>:
    8000290c:	00153023          	sd	ra,0(a0)
    80002910:	00253423          	sd	sp,8(a0)
    80002914:	e900                	sd	s0,16(a0)
    80002916:	ed04                	sd	s1,24(a0)
    80002918:	03253023          	sd	s2,32(a0)
    8000291c:	03353423          	sd	s3,40(a0)
    80002920:	03453823          	sd	s4,48(a0)
    80002924:	03553c23          	sd	s5,56(a0)
    80002928:	05653023          	sd	s6,64(a0)
    8000292c:	05753423          	sd	s7,72(a0)
    80002930:	05853823          	sd	s8,80(a0)
    80002934:	05953c23          	sd	s9,88(a0)
    80002938:	07a53023          	sd	s10,96(a0)
    8000293c:	07b53423          	sd	s11,104(a0)
    80002940:	0005b083          	ld	ra,0(a1)
    80002944:	0085b103          	ld	sp,8(a1)
    80002948:	6980                	ld	s0,16(a1)
    8000294a:	6d84                	ld	s1,24(a1)
    8000294c:	0205b903          	ld	s2,32(a1)
    80002950:	0285b983          	ld	s3,40(a1)
    80002954:	0305ba03          	ld	s4,48(a1)
    80002958:	0385ba83          	ld	s5,56(a1)
    8000295c:	0405bb03          	ld	s6,64(a1)
    80002960:	0485bb83          	ld	s7,72(a1)
    80002964:	0505bc03          	ld	s8,80(a1)
    80002968:	0585bc83          	ld	s9,88(a1)
    8000296c:	0605bd03          	ld	s10,96(a1)
    80002970:	0685bd83          	ld	s11,104(a1)
    80002974:	8082                	ret

0000000080002976 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002976:	1141                	addi	sp,sp,-16
    80002978:	e406                	sd	ra,8(sp)
    8000297a:	e022                	sd	s0,0(sp)
    8000297c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000297e:	00006597          	auipc	a1,0x6
    80002982:	a1258593          	addi	a1,a1,-1518 # 80008390 <states.0+0x38>
    80002986:	00015517          	auipc	a0,0x15
    8000298a:	69a50513          	addi	a0,a0,1690 # 80018020 <tickslock>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	1b8080e7          	jalr	440(ra) # 80000b46 <initlock>
}
    80002996:	60a2                	ld	ra,8(sp)
    80002998:	6402                	ld	s0,0(sp)
    8000299a:	0141                	addi	sp,sp,16
    8000299c:	8082                	ret

000000008000299e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000299e:	1141                	addi	sp,sp,-16
    800029a0:	e422                	sd	s0,8(sp)
    800029a2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029a4:	00003797          	auipc	a5,0x3
    800029a8:	53c78793          	addi	a5,a5,1340 # 80005ee0 <kernelvec>
    800029ac:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029b0:	6422                	ld	s0,8(sp)
    800029b2:	0141                	addi	sp,sp,16
    800029b4:	8082                	ret

00000000800029b6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029b6:	1101                	addi	sp,sp,-32
    800029b8:	ec06                	sd	ra,24(sp)
    800029ba:	e822                	sd	s0,16(sp)
    800029bc:	e426                	sd	s1,8(sp)
    800029be:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800029c0:	fffff097          	auipc	ra,0xfffff
    800029c4:	fc0080e7          	jalr	-64(ra) # 80001980 <myproc>
    800029c8:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    800029ca:	00000097          	auipc	ra,0x0
    800029ce:	dc6080e7          	jalr	-570(ra) # 80002790 <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029d6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029d8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029dc:	00004617          	auipc	a2,0x4
    800029e0:	62460613          	addi	a2,a2,1572 # 80007000 <_trampoline>
    800029e4:	00004697          	auipc	a3,0x4
    800029e8:	61c68693          	addi	a3,a3,1564 # 80007000 <_trampoline>
    800029ec:	8e91                	sub	a3,a3,a2
    800029ee:	040007b7          	lui	a5,0x4000
    800029f2:	17fd                	addi	a5,a5,-1
    800029f4:	07b2                	slli	a5,a5,0xc
    800029f6:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f8:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    800029fc:	7d58                	ld	a4,184(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029fe:	180026f3          	csrr	a3,satp
    80002a02:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    80002a04:	7d58                	ld	a4,184(a0)
    80002a06:	7954                	ld	a3,176(a0)
    80002a08:	6585                	lui	a1,0x1
    80002a0a:	96ae                	add	a3,a3,a1
    80002a0c:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    80002a0e:	7d58                	ld	a4,184(a0)
    80002a10:	00000697          	auipc	a3,0x0
    80002a14:	15e68693          	addi	a3,a3,350 # 80002b6e <usertrap>
    80002a18:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a1a:	7d58                	ld	a4,184(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a1c:	8692                	mv	a3,tp
    80002a1e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a20:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a24:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a28:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a2c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    80002a30:	7d58                	ld	a4,184(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a32:	6f18                	ld	a4,24(a4)
    80002a34:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a38:	1004b583          	ld	a1,256(s1)
    80002a3c:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002a3e:	02848493          	addi	s1,s1,40
    80002a42:	8d05                	sub	a0,a0,s1
    80002a44:	8519                	srai	a0,a0,0x6
    80002a46:	00005717          	auipc	a4,0x5
    80002a4a:	5c273703          	ld	a4,1474(a4) # 80008008 <etext+0x8>
    80002a4e:	02e50533          	mul	a0,a0,a4
    80002a52:	1502                	slli	a0,a0,0x20
    80002a54:	9101                	srli	a0,a0,0x20
    80002a56:	00351693          	slli	a3,a0,0x3
    80002a5a:	9536                	add	a0,a0,a3
    80002a5c:	0516                	slli	a0,a0,0x5
    80002a5e:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a62:	00004717          	auipc	a4,0x4
    80002a66:	63270713          	addi	a4,a4,1586 # 80007094 <userret>
    80002a6a:	8f11                	sub	a4,a4,a2
    80002a6c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002a6e:	577d                	li	a4,-1
    80002a70:	177e                	slli	a4,a4,0x3f
    80002a72:	8dd9                	or	a1,a1,a4
    80002a74:	16fd                	addi	a3,a3,-1
    80002a76:	06b6                	slli	a3,a3,0xd
    80002a78:	9536                	add	a0,a0,a3
    80002a7a:	9782                	jalr	a5
}
    80002a7c:	60e2                	ld	ra,24(sp)
    80002a7e:	6442                	ld	s0,16(sp)
    80002a80:	64a2                	ld	s1,8(sp)
    80002a82:	6105                	addi	sp,sp,32
    80002a84:	8082                	ret

0000000080002a86 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a86:	1101                	addi	sp,sp,-32
    80002a88:	ec06                	sd	ra,24(sp)
    80002a8a:	e822                	sd	s0,16(sp)
    80002a8c:	e426                	sd	s1,8(sp)
    80002a8e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a90:	00015497          	auipc	s1,0x15
    80002a94:	59048493          	addi	s1,s1,1424 # 80018020 <tickslock>
    80002a98:	8526                	mv	a0,s1
    80002a9a:	ffffe097          	auipc	ra,0xffffe
    80002a9e:	13c080e7          	jalr	316(ra) # 80000bd6 <acquire>
  ticks++;
    80002aa2:	00006517          	auipc	a0,0x6
    80002aa6:	ede50513          	addi	a0,a0,-290 # 80008980 <ticks>
    80002aaa:	411c                	lw	a5,0(a0)
    80002aac:	2785                	addiw	a5,a5,1
    80002aae:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	6ee080e7          	jalr	1774(ra) # 8000219e <wakeup>
  release(&tickslock);
    80002ab8:	8526                	mv	a0,s1
    80002aba:	ffffe097          	auipc	ra,0xffffe
    80002abe:	1d0080e7          	jalr	464(ra) # 80000c8a <release>
}
    80002ac2:	60e2                	ld	ra,24(sp)
    80002ac4:	6442                	ld	s0,16(sp)
    80002ac6:	64a2                	ld	s1,8(sp)
    80002ac8:	6105                	addi	sp,sp,32
    80002aca:	8082                	ret

0000000080002acc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002acc:	1101                	addi	sp,sp,-32
    80002ace:	ec06                	sd	ra,24(sp)
    80002ad0:	e822                	sd	s0,16(sp)
    80002ad2:	e426                	sd	s1,8(sp)
    80002ad4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ad6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002ada:	00074d63          	bltz	a4,80002af4 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002ade:	57fd                	li	a5,-1
    80002ae0:	17fe                	slli	a5,a5,0x3f
    80002ae2:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ae4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ae6:	06f70363          	beq	a4,a5,80002b4c <devintr+0x80>
  }
}
    80002aea:	60e2                	ld	ra,24(sp)
    80002aec:	6442                	ld	s0,16(sp)
    80002aee:	64a2                	ld	s1,8(sp)
    80002af0:	6105                	addi	sp,sp,32
    80002af2:	8082                	ret
     (scause & 0xff) == 9){
    80002af4:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002af8:	46a5                	li	a3,9
    80002afa:	fed792e3          	bne	a5,a3,80002ade <devintr+0x12>
    int irq = plic_claim();
    80002afe:	00003097          	auipc	ra,0x3
    80002b02:	4ea080e7          	jalr	1258(ra) # 80005fe8 <plic_claim>
    80002b06:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b08:	47a9                	li	a5,10
    80002b0a:	02f50763          	beq	a0,a5,80002b38 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b0e:	4785                	li	a5,1
    80002b10:	02f50963          	beq	a0,a5,80002b42 <devintr+0x76>
    return 1;
    80002b14:	4505                	li	a0,1
    } else if(irq){
    80002b16:	d8f1                	beqz	s1,80002aea <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b18:	85a6                	mv	a1,s1
    80002b1a:	00006517          	auipc	a0,0x6
    80002b1e:	87e50513          	addi	a0,a0,-1922 # 80008398 <states.0+0x40>
    80002b22:	ffffe097          	auipc	ra,0xffffe
    80002b26:	a66080e7          	jalr	-1434(ra) # 80000588 <printf>
      plic_complete(irq);
    80002b2a:	8526                	mv	a0,s1
    80002b2c:	00003097          	auipc	ra,0x3
    80002b30:	4e0080e7          	jalr	1248(ra) # 8000600c <plic_complete>
    return 1;
    80002b34:	4505                	li	a0,1
    80002b36:	bf55                	j	80002aea <devintr+0x1e>
      uartintr();
    80002b38:	ffffe097          	auipc	ra,0xffffe
    80002b3c:	e62080e7          	jalr	-414(ra) # 8000099a <uartintr>
    80002b40:	b7ed                	j	80002b2a <devintr+0x5e>
      virtio_disk_intr();
    80002b42:	00004097          	auipc	ra,0x4
    80002b46:	996080e7          	jalr	-1642(ra) # 800064d8 <virtio_disk_intr>
    80002b4a:	b7c5                	j	80002b2a <devintr+0x5e>
    if(cpuid() == 0){
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	e08080e7          	jalr	-504(ra) # 80001954 <cpuid>
    80002b54:	c901                	beqz	a0,80002b64 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b56:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b5a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b5c:	14479073          	csrw	sip,a5
    return 2;
    80002b60:	4509                	li	a0,2
    80002b62:	b761                	j	80002aea <devintr+0x1e>
      clockintr();
    80002b64:	00000097          	auipc	ra,0x0
    80002b68:	f22080e7          	jalr	-222(ra) # 80002a86 <clockintr>
    80002b6c:	b7ed                	j	80002b56 <devintr+0x8a>

0000000080002b6e <usertrap>:
{
    80002b6e:	1101                	addi	sp,sp,-32
    80002b70:	ec06                	sd	ra,24(sp)
    80002b72:	e822                	sd	s0,16(sp)
    80002b74:	e426                	sd	s1,8(sp)
    80002b76:	e04a                	sd	s2,0(sp)
    80002b78:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b7a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b7e:	1007f793          	andi	a5,a5,256
    80002b82:	e7b9                	bnez	a5,80002bd0 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b84:	00003797          	auipc	a5,0x3
    80002b88:	35c78793          	addi	a5,a5,860 # 80005ee0 <kernelvec>
    80002b8c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b90:	fffff097          	auipc	ra,0xfffff
    80002b94:	df0080e7          	jalr	-528(ra) # 80001980 <myproc>
    80002b98:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002b9a:	00000097          	auipc	ra,0x0
    80002b9e:	bf6080e7          	jalr	-1034(ra) # 80002790 <mykthread>
    80002ba2:	892a                	mv	s2,a0
  kt->trapframe->epc = r_sepc();
    80002ba4:	7d5c                	ld	a5,184(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ba6:	14102773          	csrr	a4,sepc
    80002baa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bac:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002bb0:	47a1                	li	a5,8
    80002bb2:	02f70763          	beq	a4,a5,80002be0 <usertrap+0x72>
  } else if((which_dev = devintr()) != 0){
    80002bb6:	00000097          	auipc	ra,0x0
    80002bba:	f16080e7          	jalr	-234(ra) # 80002acc <devintr>
    80002bbe:	892a                	mv	s2,a0
    80002bc0:	c541                	beqz	a0,80002c48 <usertrap+0xda>
  if(killed(p))
    80002bc2:	8526                	mv	a0,s1
    80002bc4:	00000097          	auipc	ra,0x0
    80002bc8:	89c080e7          	jalr	-1892(ra) # 80002460 <killed>
    80002bcc:	c939                	beqz	a0,80002c22 <usertrap+0xb4>
    80002bce:	a0a9                	j	80002c18 <usertrap+0xaa>
    panic("usertrap: not from user mode");
    80002bd0:	00005517          	auipc	a0,0x5
    80002bd4:	7e850513          	addi	a0,a0,2024 # 800083b8 <states.0+0x60>
    80002bd8:	ffffe097          	auipc	ra,0xffffe
    80002bdc:	966080e7          	jalr	-1690(ra) # 8000053e <panic>
    if(killed(p))
    80002be0:	8526                	mv	a0,s1
    80002be2:	00000097          	auipc	ra,0x0
    80002be6:	87e080e7          	jalr	-1922(ra) # 80002460 <killed>
    80002bea:	e929                	bnez	a0,80002c3c <usertrap+0xce>
    kt->trapframe->epc += 4;
    80002bec:	0b893703          	ld	a4,184(s2)
    80002bf0:	6f1c                	ld	a5,24(a4)
    80002bf2:	0791                	addi	a5,a5,4
    80002bf4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bfa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bfe:	10079073          	csrw	sstatus,a5
    syscall();
    80002c02:	00000097          	auipc	ra,0x0
    80002c06:	2d8080e7          	jalr	728(ra) # 80002eda <syscall>
  if(killed(p))
    80002c0a:	8526                	mv	a0,s1
    80002c0c:	00000097          	auipc	ra,0x0
    80002c10:	854080e7          	jalr	-1964(ra) # 80002460 <killed>
    80002c14:	c911                	beqz	a0,80002c28 <usertrap+0xba>
    80002c16:	4901                	li	s2,0
    exit(-1);
    80002c18:	557d                	li	a0,-1
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	69c080e7          	jalr	1692(ra) # 800022b6 <exit>
  if(which_dev == 2)
    80002c22:	4789                	li	a5,2
    80002c24:	04f90f63          	beq	s2,a5,80002c82 <usertrap+0x114>
  usertrapret();
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	d8e080e7          	jalr	-626(ra) # 800029b6 <usertrapret>
}
    80002c30:	60e2                	ld	ra,24(sp)
    80002c32:	6442                	ld	s0,16(sp)
    80002c34:	64a2                	ld	s1,8(sp)
    80002c36:	6902                	ld	s2,0(sp)
    80002c38:	6105                	addi	sp,sp,32
    80002c3a:	8082                	ret
      exit(-1);
    80002c3c:	557d                	li	a0,-1
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	678080e7          	jalr	1656(ra) # 800022b6 <exit>
    80002c46:	b75d                	j	80002bec <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c48:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c4c:	50d0                	lw	a2,36(s1)
    80002c4e:	00005517          	auipc	a0,0x5
    80002c52:	78a50513          	addi	a0,a0,1930 # 800083d8 <states.0+0x80>
    80002c56:	ffffe097          	auipc	ra,0xffffe
    80002c5a:	932080e7          	jalr	-1742(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c5e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c62:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c66:	00005517          	auipc	a0,0x5
    80002c6a:	7a250513          	addi	a0,a0,1954 # 80008408 <states.0+0xb0>
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	91a080e7          	jalr	-1766(ra) # 80000588 <printf>
    setkilled(p);
    80002c76:	8526                	mv	a0,s1
    80002c78:	fffff097          	auipc	ra,0xfffff
    80002c7c:	7bc080e7          	jalr	1980(ra) # 80002434 <setkilled>
    80002c80:	b769                	j	80002c0a <usertrap+0x9c>
    yield();
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	3de080e7          	jalr	990(ra) # 80002060 <yield>
    80002c8a:	bf79                	j	80002c28 <usertrap+0xba>

0000000080002c8c <kerneltrap>:
{
    80002c8c:	7179                	addi	sp,sp,-48
    80002c8e:	f406                	sd	ra,40(sp)
    80002c90:	f022                	sd	s0,32(sp)
    80002c92:	ec26                	sd	s1,24(sp)
    80002c94:	e84a                	sd	s2,16(sp)
    80002c96:	e44e                	sd	s3,8(sp)
    80002c98:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c9a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c9e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ca2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ca6:	1004f793          	andi	a5,s1,256
    80002caa:	cb85                	beqz	a5,80002cda <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cac:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cb0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cb2:	ef85                	bnez	a5,80002cea <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cb4:	00000097          	auipc	ra,0x0
    80002cb8:	e18080e7          	jalr	-488(ra) # 80002acc <devintr>
    80002cbc:	cd1d                	beqz	a0,80002cfa <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002cbe:	4789                	li	a5,2
    80002cc0:	06f50a63          	beq	a0,a5,80002d34 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cc4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cc8:	10049073          	csrw	sstatus,s1
}
    80002ccc:	70a2                	ld	ra,40(sp)
    80002cce:	7402                	ld	s0,32(sp)
    80002cd0:	64e2                	ld	s1,24(sp)
    80002cd2:	6942                	ld	s2,16(sp)
    80002cd4:	69a2                	ld	s3,8(sp)
    80002cd6:	6145                	addi	sp,sp,48
    80002cd8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cda:	00005517          	auipc	a0,0x5
    80002cde:	74e50513          	addi	a0,a0,1870 # 80008428 <states.0+0xd0>
    80002ce2:	ffffe097          	auipc	ra,0xffffe
    80002ce6:	85c080e7          	jalr	-1956(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002cea:	00005517          	auipc	a0,0x5
    80002cee:	76650513          	addi	a0,a0,1894 # 80008450 <states.0+0xf8>
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	84c080e7          	jalr	-1972(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002cfa:	85ce                	mv	a1,s3
    80002cfc:	00005517          	auipc	a0,0x5
    80002d00:	77450513          	addi	a0,a0,1908 # 80008470 <states.0+0x118>
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	884080e7          	jalr	-1916(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d0c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d10:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d14:	00005517          	auipc	a0,0x5
    80002d18:	76c50513          	addi	a0,a0,1900 # 80008480 <states.0+0x128>
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	86c080e7          	jalr	-1940(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002d24:	00005517          	auipc	a0,0x5
    80002d28:	77450513          	addi	a0,a0,1908 # 80008498 <states.0+0x140>
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	812080e7          	jalr	-2030(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002d34:	fffff097          	auipc	ra,0xfffff
    80002d38:	c4c080e7          	jalr	-948(ra) # 80001980 <myproc>
    80002d3c:	d541                	beqz	a0,80002cc4 <kerneltrap+0x38>
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	c42080e7          	jalr	-958(ra) # 80001980 <myproc>
    80002d46:	4138                	lw	a4,64(a0)
    80002d48:	4791                	li	a5,4
    80002d4a:	f6f71de3          	bne	a4,a5,80002cc4 <kerneltrap+0x38>
    yield();
    80002d4e:	fffff097          	auipc	ra,0xfffff
    80002d52:	312080e7          	jalr	786(ra) # 80002060 <yield>
    80002d56:	b7bd                	j	80002cc4 <kerneltrap+0x38>

0000000080002d58 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d58:	1101                	addi	sp,sp,-32
    80002d5a:	ec06                	sd	ra,24(sp)
    80002d5c:	e822                	sd	s0,16(sp)
    80002d5e:	e426                	sd	s1,8(sp)
    80002d60:	1000                	addi	s0,sp,32
    80002d62:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    80002d64:	00000097          	auipc	ra,0x0
    80002d68:	a2c080e7          	jalr	-1492(ra) # 80002790 <mykthread>
  switch (n) {
    80002d6c:	4795                	li	a5,5
    80002d6e:	0497e163          	bltu	a5,s1,80002db0 <argraw+0x58>
    80002d72:	048a                	slli	s1,s1,0x2
    80002d74:	00005717          	auipc	a4,0x5
    80002d78:	75c70713          	addi	a4,a4,1884 # 800084d0 <states.0+0x178>
    80002d7c:	94ba                	add	s1,s1,a4
    80002d7e:	409c                	lw	a5,0(s1)
    80002d80:	97ba                	add	a5,a5,a4
    80002d82:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    80002d84:	7d5c                	ld	a5,184(a0)
    80002d86:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d88:	60e2                	ld	ra,24(sp)
    80002d8a:	6442                	ld	s0,16(sp)
    80002d8c:	64a2                	ld	s1,8(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret
    return kt->trapframe->a1;
    80002d92:	7d5c                	ld	a5,184(a0)
    80002d94:	7fa8                	ld	a0,120(a5)
    80002d96:	bfcd                	j	80002d88 <argraw+0x30>
    return kt->trapframe->a2;
    80002d98:	7d5c                	ld	a5,184(a0)
    80002d9a:	63c8                	ld	a0,128(a5)
    80002d9c:	b7f5                	j	80002d88 <argraw+0x30>
    return kt->trapframe->a3;
    80002d9e:	7d5c                	ld	a5,184(a0)
    80002da0:	67c8                	ld	a0,136(a5)
    80002da2:	b7dd                	j	80002d88 <argraw+0x30>
    return kt->trapframe->a4;
    80002da4:	7d5c                	ld	a5,184(a0)
    80002da6:	6bc8                	ld	a0,144(a5)
    80002da8:	b7c5                	j	80002d88 <argraw+0x30>
    return kt->trapframe->a5;
    80002daa:	7d5c                	ld	a5,184(a0)
    80002dac:	6fc8                	ld	a0,152(a5)
    80002dae:	bfe9                	j	80002d88 <argraw+0x30>
  panic("argraw");
    80002db0:	00005517          	auipc	a0,0x5
    80002db4:	6f850513          	addi	a0,a0,1784 # 800084a8 <states.0+0x150>
    80002db8:	ffffd097          	auipc	ra,0xffffd
    80002dbc:	786080e7          	jalr	1926(ra) # 8000053e <panic>

0000000080002dc0 <fetchaddr>:
{
    80002dc0:	1101                	addi	sp,sp,-32
    80002dc2:	ec06                	sd	ra,24(sp)
    80002dc4:	e822                	sd	s0,16(sp)
    80002dc6:	e426                	sd	s1,8(sp)
    80002dc8:	e04a                	sd	s2,0(sp)
    80002dca:	1000                	addi	s0,sp,32
    80002dcc:	84aa                	mv	s1,a0
    80002dce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dd0:	fffff097          	auipc	ra,0xfffff
    80002dd4:	bb0080e7          	jalr	-1104(ra) # 80001980 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002dd8:	7d7c                	ld	a5,248(a0)
    80002dda:	02f4f963          	bgeu	s1,a5,80002e0c <fetchaddr+0x4c>
    80002dde:	00848713          	addi	a4,s1,8
    80002de2:	02e7e763          	bltu	a5,a4,80002e10 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002de6:	46a1                	li	a3,8
    80002de8:	8626                	mv	a2,s1
    80002dea:	85ca                	mv	a1,s2
    80002dec:	10053503          	ld	a0,256(a0)
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	904080e7          	jalr	-1788(ra) # 800016f4 <copyin>
    80002df8:	00a03533          	snez	a0,a0
    80002dfc:	40a00533          	neg	a0,a0
}
    80002e00:	60e2                	ld	ra,24(sp)
    80002e02:	6442                	ld	s0,16(sp)
    80002e04:	64a2                	ld	s1,8(sp)
    80002e06:	6902                	ld	s2,0(sp)
    80002e08:	6105                	addi	sp,sp,32
    80002e0a:	8082                	ret
    return -1;
    80002e0c:	557d                	li	a0,-1
    80002e0e:	bfcd                	j	80002e00 <fetchaddr+0x40>
    80002e10:	557d                	li	a0,-1
    80002e12:	b7fd                	j	80002e00 <fetchaddr+0x40>

0000000080002e14 <fetchstr>:
{
    80002e14:	7179                	addi	sp,sp,-48
    80002e16:	f406                	sd	ra,40(sp)
    80002e18:	f022                	sd	s0,32(sp)
    80002e1a:	ec26                	sd	s1,24(sp)
    80002e1c:	e84a                	sd	s2,16(sp)
    80002e1e:	e44e                	sd	s3,8(sp)
    80002e20:	1800                	addi	s0,sp,48
    80002e22:	892a                	mv	s2,a0
    80002e24:	84ae                	mv	s1,a1
    80002e26:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e28:	fffff097          	auipc	ra,0xfffff
    80002e2c:	b58080e7          	jalr	-1192(ra) # 80001980 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e30:	86ce                	mv	a3,s3
    80002e32:	864a                	mv	a2,s2
    80002e34:	85a6                	mv	a1,s1
    80002e36:	10053503          	ld	a0,256(a0)
    80002e3a:	fffff097          	auipc	ra,0xfffff
    80002e3e:	948080e7          	jalr	-1720(ra) # 80001782 <copyinstr>
    80002e42:	00054e63          	bltz	a0,80002e5e <fetchstr+0x4a>
  return strlen(buf);
    80002e46:	8526                	mv	a0,s1
    80002e48:	ffffe097          	auipc	ra,0xffffe
    80002e4c:	006080e7          	jalr	6(ra) # 80000e4e <strlen>
}
    80002e50:	70a2                	ld	ra,40(sp)
    80002e52:	7402                	ld	s0,32(sp)
    80002e54:	64e2                	ld	s1,24(sp)
    80002e56:	6942                	ld	s2,16(sp)
    80002e58:	69a2                	ld	s3,8(sp)
    80002e5a:	6145                	addi	sp,sp,48
    80002e5c:	8082                	ret
    return -1;
    80002e5e:	557d                	li	a0,-1
    80002e60:	bfc5                	j	80002e50 <fetchstr+0x3c>

0000000080002e62 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e62:	1101                	addi	sp,sp,-32
    80002e64:	ec06                	sd	ra,24(sp)
    80002e66:	e822                	sd	s0,16(sp)
    80002e68:	e426                	sd	s1,8(sp)
    80002e6a:	1000                	addi	s0,sp,32
    80002e6c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e6e:	00000097          	auipc	ra,0x0
    80002e72:	eea080e7          	jalr	-278(ra) # 80002d58 <argraw>
    80002e76:	c088                	sw	a0,0(s1)
}
    80002e78:	60e2                	ld	ra,24(sp)
    80002e7a:	6442                	ld	s0,16(sp)
    80002e7c:	64a2                	ld	s1,8(sp)
    80002e7e:	6105                	addi	sp,sp,32
    80002e80:	8082                	ret

0000000080002e82 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e82:	1101                	addi	sp,sp,-32
    80002e84:	ec06                	sd	ra,24(sp)
    80002e86:	e822                	sd	s0,16(sp)
    80002e88:	e426                	sd	s1,8(sp)
    80002e8a:	1000                	addi	s0,sp,32
    80002e8c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e8e:	00000097          	auipc	ra,0x0
    80002e92:	eca080e7          	jalr	-310(ra) # 80002d58 <argraw>
    80002e96:	e088                	sd	a0,0(s1)
}
    80002e98:	60e2                	ld	ra,24(sp)
    80002e9a:	6442                	ld	s0,16(sp)
    80002e9c:	64a2                	ld	s1,8(sp)
    80002e9e:	6105                	addi	sp,sp,32
    80002ea0:	8082                	ret

0000000080002ea2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ea2:	7179                	addi	sp,sp,-48
    80002ea4:	f406                	sd	ra,40(sp)
    80002ea6:	f022                	sd	s0,32(sp)
    80002ea8:	ec26                	sd	s1,24(sp)
    80002eaa:	e84a                	sd	s2,16(sp)
    80002eac:	1800                	addi	s0,sp,48
    80002eae:	84ae                	mv	s1,a1
    80002eb0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002eb2:	fd840593          	addi	a1,s0,-40
    80002eb6:	00000097          	auipc	ra,0x0
    80002eba:	fcc080e7          	jalr	-52(ra) # 80002e82 <argaddr>
  return fetchstr(addr, buf, max);
    80002ebe:	864a                	mv	a2,s2
    80002ec0:	85a6                	mv	a1,s1
    80002ec2:	fd843503          	ld	a0,-40(s0)
    80002ec6:	00000097          	auipc	ra,0x0
    80002eca:	f4e080e7          	jalr	-178(ra) # 80002e14 <fetchstr>
}
    80002ece:	70a2                	ld	ra,40(sp)
    80002ed0:	7402                	ld	s0,32(sp)
    80002ed2:	64e2                	ld	s1,24(sp)
    80002ed4:	6942                	ld	s2,16(sp)
    80002ed6:	6145                	addi	sp,sp,48
    80002ed8:	8082                	ret

0000000080002eda <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002eda:	7179                	addi	sp,sp,-48
    80002edc:	f406                	sd	ra,40(sp)
    80002ede:	f022                	sd	s0,32(sp)
    80002ee0:	ec26                	sd	s1,24(sp)
    80002ee2:	e84a                	sd	s2,16(sp)
    80002ee4:	e44e                	sd	s3,8(sp)
    80002ee6:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002ee8:	fffff097          	auipc	ra,0xfffff
    80002eec:	a98080e7          	jalr	-1384(ra) # 80001980 <myproc>
    80002ef0:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    80002ef2:	00000097          	auipc	ra,0x0
    80002ef6:	89e080e7          	jalr	-1890(ra) # 80002790 <mykthread>
    80002efa:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80002efc:	0b853983          	ld	s3,184(a0)
    80002f00:	0a89b783          	ld	a5,168(s3)
    80002f04:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f08:	37fd                	addiw	a5,a5,-1
    80002f0a:	4751                	li	a4,20
    80002f0c:	00f76f63          	bltu	a4,a5,80002f2a <syscall+0x50>
    80002f10:	00369713          	slli	a4,a3,0x3
    80002f14:	00005797          	auipc	a5,0x5
    80002f18:	5d478793          	addi	a5,a5,1492 # 800084e8 <syscalls>
    80002f1c:	97ba                	add	a5,a5,a4
    80002f1e:	639c                	ld	a5,0(a5)
    80002f20:	c789                	beqz	a5,80002f2a <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    80002f22:	9782                	jalr	a5
    80002f24:	06a9b823          	sd	a0,112(s3)
    80002f28:	a005                	j	80002f48 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f2a:	19090613          	addi	a2,s2,400
    80002f2e:	02492583          	lw	a1,36(s2)
    80002f32:	00005517          	auipc	a0,0x5
    80002f36:	57e50513          	addi	a0,a0,1406 # 800084b0 <states.0+0x158>
    80002f3a:	ffffd097          	auipc	ra,0xffffd
    80002f3e:	64e080e7          	jalr	1614(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    80002f42:	7cdc                	ld	a5,184(s1)
    80002f44:	577d                	li	a4,-1
    80002f46:	fbb8                	sd	a4,112(a5)
  }
}
    80002f48:	70a2                	ld	ra,40(sp)
    80002f4a:	7402                	ld	s0,32(sp)
    80002f4c:	64e2                	ld	s1,24(sp)
    80002f4e:	6942                	ld	s2,16(sp)
    80002f50:	69a2                	ld	s3,8(sp)
    80002f52:	6145                	addi	sp,sp,48
    80002f54:	8082                	ret

0000000080002f56 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f56:	1101                	addi	sp,sp,-32
    80002f58:	ec06                	sd	ra,24(sp)
    80002f5a:	e822                	sd	s0,16(sp)
    80002f5c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f5e:	fec40593          	addi	a1,s0,-20
    80002f62:	4501                	li	a0,0
    80002f64:	00000097          	auipc	ra,0x0
    80002f68:	efe080e7          	jalr	-258(ra) # 80002e62 <argint>
  exit(n);
    80002f6c:	fec42503          	lw	a0,-20(s0)
    80002f70:	fffff097          	auipc	ra,0xfffff
    80002f74:	346080e7          	jalr	838(ra) # 800022b6 <exit>
  return 0;  // not reached
}
    80002f78:	4501                	li	a0,0
    80002f7a:	60e2                	ld	ra,24(sp)
    80002f7c:	6442                	ld	s0,16(sp)
    80002f7e:	6105                	addi	sp,sp,32
    80002f80:	8082                	ret

0000000080002f82 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f82:	1141                	addi	sp,sp,-16
    80002f84:	e406                	sd	ra,8(sp)
    80002f86:	e022                	sd	s0,0(sp)
    80002f88:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f8a:	fffff097          	auipc	ra,0xfffff
    80002f8e:	9f6080e7          	jalr	-1546(ra) # 80001980 <myproc>
}
    80002f92:	5148                	lw	a0,36(a0)
    80002f94:	60a2                	ld	ra,8(sp)
    80002f96:	6402                	ld	s0,0(sp)
    80002f98:	0141                	addi	sp,sp,16
    80002f9a:	8082                	ret

0000000080002f9c <sys_fork>:

uint64
sys_fork(void)
{
    80002f9c:	1141                	addi	sp,sp,-16
    80002f9e:	e406                	sd	ra,8(sp)
    80002fa0:	e022                	sd	s0,0(sp)
    80002fa2:	0800                	addi	s0,sp,16
  return fork();
    80002fa4:	fffff097          	auipc	ra,0xfffff
    80002fa8:	d92080e7          	jalr	-622(ra) # 80001d36 <fork>
}
    80002fac:	60a2                	ld	ra,8(sp)
    80002fae:	6402                	ld	s0,0(sp)
    80002fb0:	0141                	addi	sp,sp,16
    80002fb2:	8082                	ret

0000000080002fb4 <sys_wait>:

uint64
sys_wait(void)
{
    80002fb4:	1101                	addi	sp,sp,-32
    80002fb6:	ec06                	sd	ra,24(sp)
    80002fb8:	e822                	sd	s0,16(sp)
    80002fba:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002fbc:	fe840593          	addi	a1,s0,-24
    80002fc0:	4501                	li	a0,0
    80002fc2:	00000097          	auipc	ra,0x0
    80002fc6:	ec0080e7          	jalr	-320(ra) # 80002e82 <argaddr>
  return wait(p);
    80002fca:	fe843503          	ld	a0,-24(s0)
    80002fce:	fffff097          	auipc	ra,0xfffff
    80002fd2:	4c4080e7          	jalr	1220(ra) # 80002492 <wait>
}
    80002fd6:	60e2                	ld	ra,24(sp)
    80002fd8:	6442                	ld	s0,16(sp)
    80002fda:	6105                	addi	sp,sp,32
    80002fdc:	8082                	ret

0000000080002fde <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fde:	7179                	addi	sp,sp,-48
    80002fe0:	f406                	sd	ra,40(sp)
    80002fe2:	f022                	sd	s0,32(sp)
    80002fe4:	ec26                	sd	s1,24(sp)
    80002fe6:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002fe8:	fdc40593          	addi	a1,s0,-36
    80002fec:	4501                	li	a0,0
    80002fee:	00000097          	auipc	ra,0x0
    80002ff2:	e74080e7          	jalr	-396(ra) # 80002e62 <argint>
  addr = myproc()->sz;
    80002ff6:	fffff097          	auipc	ra,0xfffff
    80002ffa:	98a080e7          	jalr	-1654(ra) # 80001980 <myproc>
    80002ffe:	7d64                	ld	s1,248(a0)
  if(growproc(n) < 0)
    80003000:	fdc42503          	lw	a0,-36(s0)
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	cd2080e7          	jalr	-814(ra) # 80001cd6 <growproc>
    8000300c:	00054863          	bltz	a0,8000301c <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003010:	8526                	mv	a0,s1
    80003012:	70a2                	ld	ra,40(sp)
    80003014:	7402                	ld	s0,32(sp)
    80003016:	64e2                	ld	s1,24(sp)
    80003018:	6145                	addi	sp,sp,48
    8000301a:	8082                	ret
    return -1;
    8000301c:	54fd                	li	s1,-1
    8000301e:	bfcd                	j	80003010 <sys_sbrk+0x32>

0000000080003020 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003020:	7139                	addi	sp,sp,-64
    80003022:	fc06                	sd	ra,56(sp)
    80003024:	f822                	sd	s0,48(sp)
    80003026:	f426                	sd	s1,40(sp)
    80003028:	f04a                	sd	s2,32(sp)
    8000302a:	ec4e                	sd	s3,24(sp)
    8000302c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000302e:	fcc40593          	addi	a1,s0,-52
    80003032:	4501                	li	a0,0
    80003034:	00000097          	auipc	ra,0x0
    80003038:	e2e080e7          	jalr	-466(ra) # 80002e62 <argint>
  acquire(&tickslock);
    8000303c:	00015517          	auipc	a0,0x15
    80003040:	fe450513          	addi	a0,a0,-28 # 80018020 <tickslock>
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	b92080e7          	jalr	-1134(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    8000304c:	00006917          	auipc	s2,0x6
    80003050:	93492903          	lw	s2,-1740(s2) # 80008980 <ticks>
  while(ticks - ticks0 < n){
    80003054:	fcc42783          	lw	a5,-52(s0)
    80003058:	cf9d                	beqz	a5,80003096 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000305a:	00015997          	auipc	s3,0x15
    8000305e:	fc698993          	addi	s3,s3,-58 # 80018020 <tickslock>
    80003062:	00006497          	auipc	s1,0x6
    80003066:	91e48493          	addi	s1,s1,-1762 # 80008980 <ticks>
    if(killed(myproc())){
    8000306a:	fffff097          	auipc	ra,0xfffff
    8000306e:	916080e7          	jalr	-1770(ra) # 80001980 <myproc>
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	3ee080e7          	jalr	1006(ra) # 80002460 <killed>
    8000307a:	ed15                	bnez	a0,800030b6 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000307c:	85ce                	mv	a1,s3
    8000307e:	8526                	mv	a0,s1
    80003080:	fffff097          	auipc	ra,0xfffff
    80003084:	09e080e7          	jalr	158(ra) # 8000211e <sleep>
  while(ticks - ticks0 < n){
    80003088:	409c                	lw	a5,0(s1)
    8000308a:	412787bb          	subw	a5,a5,s2
    8000308e:	fcc42703          	lw	a4,-52(s0)
    80003092:	fce7ece3          	bltu	a5,a4,8000306a <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003096:	00015517          	auipc	a0,0x15
    8000309a:	f8a50513          	addi	a0,a0,-118 # 80018020 <tickslock>
    8000309e:	ffffe097          	auipc	ra,0xffffe
    800030a2:	bec080e7          	jalr	-1044(ra) # 80000c8a <release>
  return 0;
    800030a6:	4501                	li	a0,0
}
    800030a8:	70e2                	ld	ra,56(sp)
    800030aa:	7442                	ld	s0,48(sp)
    800030ac:	74a2                	ld	s1,40(sp)
    800030ae:	7902                	ld	s2,32(sp)
    800030b0:	69e2                	ld	s3,24(sp)
    800030b2:	6121                	addi	sp,sp,64
    800030b4:	8082                	ret
      release(&tickslock);
    800030b6:	00015517          	auipc	a0,0x15
    800030ba:	f6a50513          	addi	a0,a0,-150 # 80018020 <tickslock>
    800030be:	ffffe097          	auipc	ra,0xffffe
    800030c2:	bcc080e7          	jalr	-1076(ra) # 80000c8a <release>
      return -1;
    800030c6:	557d                	li	a0,-1
    800030c8:	b7c5                	j	800030a8 <sys_sleep+0x88>

00000000800030ca <sys_kill>:

uint64
sys_kill(void)
{
    800030ca:	1101                	addi	sp,sp,-32
    800030cc:	ec06                	sd	ra,24(sp)
    800030ce:	e822                	sd	s0,16(sp)
    800030d0:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800030d2:	fec40593          	addi	a1,s0,-20
    800030d6:	4501                	li	a0,0
    800030d8:	00000097          	auipc	ra,0x0
    800030dc:	d8a080e7          	jalr	-630(ra) # 80002e62 <argint>
  return kill(pid);
    800030e0:	fec42503          	lw	a0,-20(s0)
    800030e4:	fffff097          	auipc	ra,0xfffff
    800030e8:	2c6080e7          	jalr	710(ra) # 800023aa <kill>
}
    800030ec:	60e2                	ld	ra,24(sp)
    800030ee:	6442                	ld	s0,16(sp)
    800030f0:	6105                	addi	sp,sp,32
    800030f2:	8082                	ret

00000000800030f4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030f4:	1101                	addi	sp,sp,-32
    800030f6:	ec06                	sd	ra,24(sp)
    800030f8:	e822                	sd	s0,16(sp)
    800030fa:	e426                	sd	s1,8(sp)
    800030fc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030fe:	00015517          	auipc	a0,0x15
    80003102:	f2250513          	addi	a0,a0,-222 # 80018020 <tickslock>
    80003106:	ffffe097          	auipc	ra,0xffffe
    8000310a:	ad0080e7          	jalr	-1328(ra) # 80000bd6 <acquire>
  xticks = ticks;
    8000310e:	00006497          	auipc	s1,0x6
    80003112:	8724a483          	lw	s1,-1934(s1) # 80008980 <ticks>
  release(&tickslock);
    80003116:	00015517          	auipc	a0,0x15
    8000311a:	f0a50513          	addi	a0,a0,-246 # 80018020 <tickslock>
    8000311e:	ffffe097          	auipc	ra,0xffffe
    80003122:	b6c080e7          	jalr	-1172(ra) # 80000c8a <release>
  return xticks;
}
    80003126:	02049513          	slli	a0,s1,0x20
    8000312a:	9101                	srli	a0,a0,0x20
    8000312c:	60e2                	ld	ra,24(sp)
    8000312e:	6442                	ld	s0,16(sp)
    80003130:	64a2                	ld	s1,8(sp)
    80003132:	6105                	addi	sp,sp,32
    80003134:	8082                	ret

0000000080003136 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003136:	7179                	addi	sp,sp,-48
    80003138:	f406                	sd	ra,40(sp)
    8000313a:	f022                	sd	s0,32(sp)
    8000313c:	ec26                	sd	s1,24(sp)
    8000313e:	e84a                	sd	s2,16(sp)
    80003140:	e44e                	sd	s3,8(sp)
    80003142:	e052                	sd	s4,0(sp)
    80003144:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003146:	00005597          	auipc	a1,0x5
    8000314a:	45258593          	addi	a1,a1,1106 # 80008598 <syscalls+0xb0>
    8000314e:	00015517          	auipc	a0,0x15
    80003152:	eea50513          	addi	a0,a0,-278 # 80018038 <bcache>
    80003156:	ffffe097          	auipc	ra,0xffffe
    8000315a:	9f0080e7          	jalr	-1552(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000315e:	0001d797          	auipc	a5,0x1d
    80003162:	eda78793          	addi	a5,a5,-294 # 80020038 <bcache+0x8000>
    80003166:	0001d717          	auipc	a4,0x1d
    8000316a:	13a70713          	addi	a4,a4,314 # 800202a0 <bcache+0x8268>
    8000316e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003172:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003176:	00015497          	auipc	s1,0x15
    8000317a:	eda48493          	addi	s1,s1,-294 # 80018050 <bcache+0x18>
    b->next = bcache.head.next;
    8000317e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003180:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003182:	00005a17          	auipc	s4,0x5
    80003186:	41ea0a13          	addi	s4,s4,1054 # 800085a0 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000318a:	2b893783          	ld	a5,696(s2)
    8000318e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003190:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003194:	85d2                	mv	a1,s4
    80003196:	01048513          	addi	a0,s1,16
    8000319a:	00001097          	auipc	ra,0x1
    8000319e:	4c4080e7          	jalr	1220(ra) # 8000465e <initsleeplock>
    bcache.head.next->prev = b;
    800031a2:	2b893783          	ld	a5,696(s2)
    800031a6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031a8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031ac:	45848493          	addi	s1,s1,1112
    800031b0:	fd349de3          	bne	s1,s3,8000318a <binit+0x54>
  }
}
    800031b4:	70a2                	ld	ra,40(sp)
    800031b6:	7402                	ld	s0,32(sp)
    800031b8:	64e2                	ld	s1,24(sp)
    800031ba:	6942                	ld	s2,16(sp)
    800031bc:	69a2                	ld	s3,8(sp)
    800031be:	6a02                	ld	s4,0(sp)
    800031c0:	6145                	addi	sp,sp,48
    800031c2:	8082                	ret

00000000800031c4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031c4:	7179                	addi	sp,sp,-48
    800031c6:	f406                	sd	ra,40(sp)
    800031c8:	f022                	sd	s0,32(sp)
    800031ca:	ec26                	sd	s1,24(sp)
    800031cc:	e84a                	sd	s2,16(sp)
    800031ce:	e44e                	sd	s3,8(sp)
    800031d0:	1800                	addi	s0,sp,48
    800031d2:	892a                	mv	s2,a0
    800031d4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031d6:	00015517          	auipc	a0,0x15
    800031da:	e6250513          	addi	a0,a0,-414 # 80018038 <bcache>
    800031de:	ffffe097          	auipc	ra,0xffffe
    800031e2:	9f8080e7          	jalr	-1544(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031e6:	0001d497          	auipc	s1,0x1d
    800031ea:	10a4b483          	ld	s1,266(s1) # 800202f0 <bcache+0x82b8>
    800031ee:	0001d797          	auipc	a5,0x1d
    800031f2:	0b278793          	addi	a5,a5,178 # 800202a0 <bcache+0x8268>
    800031f6:	02f48f63          	beq	s1,a5,80003234 <bread+0x70>
    800031fa:	873e                	mv	a4,a5
    800031fc:	a021                	j	80003204 <bread+0x40>
    800031fe:	68a4                	ld	s1,80(s1)
    80003200:	02e48a63          	beq	s1,a4,80003234 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003204:	449c                	lw	a5,8(s1)
    80003206:	ff279ce3          	bne	a5,s2,800031fe <bread+0x3a>
    8000320a:	44dc                	lw	a5,12(s1)
    8000320c:	ff3799e3          	bne	a5,s3,800031fe <bread+0x3a>
      b->refcnt++;
    80003210:	40bc                	lw	a5,64(s1)
    80003212:	2785                	addiw	a5,a5,1
    80003214:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003216:	00015517          	auipc	a0,0x15
    8000321a:	e2250513          	addi	a0,a0,-478 # 80018038 <bcache>
    8000321e:	ffffe097          	auipc	ra,0xffffe
    80003222:	a6c080e7          	jalr	-1428(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003226:	01048513          	addi	a0,s1,16
    8000322a:	00001097          	auipc	ra,0x1
    8000322e:	46e080e7          	jalr	1134(ra) # 80004698 <acquiresleep>
      return b;
    80003232:	a8b9                	j	80003290 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003234:	0001d497          	auipc	s1,0x1d
    80003238:	0b44b483          	ld	s1,180(s1) # 800202e8 <bcache+0x82b0>
    8000323c:	0001d797          	auipc	a5,0x1d
    80003240:	06478793          	addi	a5,a5,100 # 800202a0 <bcache+0x8268>
    80003244:	00f48863          	beq	s1,a5,80003254 <bread+0x90>
    80003248:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000324a:	40bc                	lw	a5,64(s1)
    8000324c:	cf81                	beqz	a5,80003264 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000324e:	64a4                	ld	s1,72(s1)
    80003250:	fee49de3          	bne	s1,a4,8000324a <bread+0x86>
  panic("bget: no buffers");
    80003254:	00005517          	auipc	a0,0x5
    80003258:	35450513          	addi	a0,a0,852 # 800085a8 <syscalls+0xc0>
    8000325c:	ffffd097          	auipc	ra,0xffffd
    80003260:	2e2080e7          	jalr	738(ra) # 8000053e <panic>
      b->dev = dev;
    80003264:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003268:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000326c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003270:	4785                	li	a5,1
    80003272:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003274:	00015517          	auipc	a0,0x15
    80003278:	dc450513          	addi	a0,a0,-572 # 80018038 <bcache>
    8000327c:	ffffe097          	auipc	ra,0xffffe
    80003280:	a0e080e7          	jalr	-1522(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003284:	01048513          	addi	a0,s1,16
    80003288:	00001097          	auipc	ra,0x1
    8000328c:	410080e7          	jalr	1040(ra) # 80004698 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003290:	409c                	lw	a5,0(s1)
    80003292:	cb89                	beqz	a5,800032a4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003294:	8526                	mv	a0,s1
    80003296:	70a2                	ld	ra,40(sp)
    80003298:	7402                	ld	s0,32(sp)
    8000329a:	64e2                	ld	s1,24(sp)
    8000329c:	6942                	ld	s2,16(sp)
    8000329e:	69a2                	ld	s3,8(sp)
    800032a0:	6145                	addi	sp,sp,48
    800032a2:	8082                	ret
    virtio_disk_rw(b, 0);
    800032a4:	4581                	li	a1,0
    800032a6:	8526                	mv	a0,s1
    800032a8:	00003097          	auipc	ra,0x3
    800032ac:	ffc080e7          	jalr	-4(ra) # 800062a4 <virtio_disk_rw>
    b->valid = 1;
    800032b0:	4785                	li	a5,1
    800032b2:	c09c                	sw	a5,0(s1)
  return b;
    800032b4:	b7c5                	j	80003294 <bread+0xd0>

00000000800032b6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032b6:	1101                	addi	sp,sp,-32
    800032b8:	ec06                	sd	ra,24(sp)
    800032ba:	e822                	sd	s0,16(sp)
    800032bc:	e426                	sd	s1,8(sp)
    800032be:	1000                	addi	s0,sp,32
    800032c0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032c2:	0541                	addi	a0,a0,16
    800032c4:	00001097          	auipc	ra,0x1
    800032c8:	46e080e7          	jalr	1134(ra) # 80004732 <holdingsleep>
    800032cc:	cd01                	beqz	a0,800032e4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032ce:	4585                	li	a1,1
    800032d0:	8526                	mv	a0,s1
    800032d2:	00003097          	auipc	ra,0x3
    800032d6:	fd2080e7          	jalr	-46(ra) # 800062a4 <virtio_disk_rw>
}
    800032da:	60e2                	ld	ra,24(sp)
    800032dc:	6442                	ld	s0,16(sp)
    800032de:	64a2                	ld	s1,8(sp)
    800032e0:	6105                	addi	sp,sp,32
    800032e2:	8082                	ret
    panic("bwrite");
    800032e4:	00005517          	auipc	a0,0x5
    800032e8:	2dc50513          	addi	a0,a0,732 # 800085c0 <syscalls+0xd8>
    800032ec:	ffffd097          	auipc	ra,0xffffd
    800032f0:	252080e7          	jalr	594(ra) # 8000053e <panic>

00000000800032f4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032f4:	1101                	addi	sp,sp,-32
    800032f6:	ec06                	sd	ra,24(sp)
    800032f8:	e822                	sd	s0,16(sp)
    800032fa:	e426                	sd	s1,8(sp)
    800032fc:	e04a                	sd	s2,0(sp)
    800032fe:	1000                	addi	s0,sp,32
    80003300:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003302:	01050913          	addi	s2,a0,16
    80003306:	854a                	mv	a0,s2
    80003308:	00001097          	auipc	ra,0x1
    8000330c:	42a080e7          	jalr	1066(ra) # 80004732 <holdingsleep>
    80003310:	c92d                	beqz	a0,80003382 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003312:	854a                	mv	a0,s2
    80003314:	00001097          	auipc	ra,0x1
    80003318:	3da080e7          	jalr	986(ra) # 800046ee <releasesleep>

  acquire(&bcache.lock);
    8000331c:	00015517          	auipc	a0,0x15
    80003320:	d1c50513          	addi	a0,a0,-740 # 80018038 <bcache>
    80003324:	ffffe097          	auipc	ra,0xffffe
    80003328:	8b2080e7          	jalr	-1870(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000332c:	40bc                	lw	a5,64(s1)
    8000332e:	37fd                	addiw	a5,a5,-1
    80003330:	0007871b          	sext.w	a4,a5
    80003334:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003336:	eb05                	bnez	a4,80003366 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003338:	68bc                	ld	a5,80(s1)
    8000333a:	64b8                	ld	a4,72(s1)
    8000333c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000333e:	64bc                	ld	a5,72(s1)
    80003340:	68b8                	ld	a4,80(s1)
    80003342:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003344:	0001d797          	auipc	a5,0x1d
    80003348:	cf478793          	addi	a5,a5,-780 # 80020038 <bcache+0x8000>
    8000334c:	2b87b703          	ld	a4,696(a5)
    80003350:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003352:	0001d717          	auipc	a4,0x1d
    80003356:	f4e70713          	addi	a4,a4,-178 # 800202a0 <bcache+0x8268>
    8000335a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000335c:	2b87b703          	ld	a4,696(a5)
    80003360:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003362:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003366:	00015517          	auipc	a0,0x15
    8000336a:	cd250513          	addi	a0,a0,-814 # 80018038 <bcache>
    8000336e:	ffffe097          	auipc	ra,0xffffe
    80003372:	91c080e7          	jalr	-1764(ra) # 80000c8a <release>
}
    80003376:	60e2                	ld	ra,24(sp)
    80003378:	6442                	ld	s0,16(sp)
    8000337a:	64a2                	ld	s1,8(sp)
    8000337c:	6902                	ld	s2,0(sp)
    8000337e:	6105                	addi	sp,sp,32
    80003380:	8082                	ret
    panic("brelse");
    80003382:	00005517          	auipc	a0,0x5
    80003386:	24650513          	addi	a0,a0,582 # 800085c8 <syscalls+0xe0>
    8000338a:	ffffd097          	auipc	ra,0xffffd
    8000338e:	1b4080e7          	jalr	436(ra) # 8000053e <panic>

0000000080003392 <bpin>:

void
bpin(struct buf *b) {
    80003392:	1101                	addi	sp,sp,-32
    80003394:	ec06                	sd	ra,24(sp)
    80003396:	e822                	sd	s0,16(sp)
    80003398:	e426                	sd	s1,8(sp)
    8000339a:	1000                	addi	s0,sp,32
    8000339c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000339e:	00015517          	auipc	a0,0x15
    800033a2:	c9a50513          	addi	a0,a0,-870 # 80018038 <bcache>
    800033a6:	ffffe097          	auipc	ra,0xffffe
    800033aa:	830080e7          	jalr	-2000(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800033ae:	40bc                	lw	a5,64(s1)
    800033b0:	2785                	addiw	a5,a5,1
    800033b2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033b4:	00015517          	auipc	a0,0x15
    800033b8:	c8450513          	addi	a0,a0,-892 # 80018038 <bcache>
    800033bc:	ffffe097          	auipc	ra,0xffffe
    800033c0:	8ce080e7          	jalr	-1842(ra) # 80000c8a <release>
}
    800033c4:	60e2                	ld	ra,24(sp)
    800033c6:	6442                	ld	s0,16(sp)
    800033c8:	64a2                	ld	s1,8(sp)
    800033ca:	6105                	addi	sp,sp,32
    800033cc:	8082                	ret

00000000800033ce <bunpin>:

void
bunpin(struct buf *b) {
    800033ce:	1101                	addi	sp,sp,-32
    800033d0:	ec06                	sd	ra,24(sp)
    800033d2:	e822                	sd	s0,16(sp)
    800033d4:	e426                	sd	s1,8(sp)
    800033d6:	1000                	addi	s0,sp,32
    800033d8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033da:	00015517          	auipc	a0,0x15
    800033de:	c5e50513          	addi	a0,a0,-930 # 80018038 <bcache>
    800033e2:	ffffd097          	auipc	ra,0xffffd
    800033e6:	7f4080e7          	jalr	2036(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800033ea:	40bc                	lw	a5,64(s1)
    800033ec:	37fd                	addiw	a5,a5,-1
    800033ee:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033f0:	00015517          	auipc	a0,0x15
    800033f4:	c4850513          	addi	a0,a0,-952 # 80018038 <bcache>
    800033f8:	ffffe097          	auipc	ra,0xffffe
    800033fc:	892080e7          	jalr	-1902(ra) # 80000c8a <release>
}
    80003400:	60e2                	ld	ra,24(sp)
    80003402:	6442                	ld	s0,16(sp)
    80003404:	64a2                	ld	s1,8(sp)
    80003406:	6105                	addi	sp,sp,32
    80003408:	8082                	ret

000000008000340a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000340a:	1101                	addi	sp,sp,-32
    8000340c:	ec06                	sd	ra,24(sp)
    8000340e:	e822                	sd	s0,16(sp)
    80003410:	e426                	sd	s1,8(sp)
    80003412:	e04a                	sd	s2,0(sp)
    80003414:	1000                	addi	s0,sp,32
    80003416:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003418:	00d5d59b          	srliw	a1,a1,0xd
    8000341c:	0001d797          	auipc	a5,0x1d
    80003420:	2f87a783          	lw	a5,760(a5) # 80020714 <sb+0x1c>
    80003424:	9dbd                	addw	a1,a1,a5
    80003426:	00000097          	auipc	ra,0x0
    8000342a:	d9e080e7          	jalr	-610(ra) # 800031c4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000342e:	0074f713          	andi	a4,s1,7
    80003432:	4785                	li	a5,1
    80003434:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003438:	14ce                	slli	s1,s1,0x33
    8000343a:	90d9                	srli	s1,s1,0x36
    8000343c:	00950733          	add	a4,a0,s1
    80003440:	05874703          	lbu	a4,88(a4)
    80003444:	00e7f6b3          	and	a3,a5,a4
    80003448:	c69d                	beqz	a3,80003476 <bfree+0x6c>
    8000344a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000344c:	94aa                	add	s1,s1,a0
    8000344e:	fff7c793          	not	a5,a5
    80003452:	8ff9                	and	a5,a5,a4
    80003454:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003458:	00001097          	auipc	ra,0x1
    8000345c:	120080e7          	jalr	288(ra) # 80004578 <log_write>
  brelse(bp);
    80003460:	854a                	mv	a0,s2
    80003462:	00000097          	auipc	ra,0x0
    80003466:	e92080e7          	jalr	-366(ra) # 800032f4 <brelse>
}
    8000346a:	60e2                	ld	ra,24(sp)
    8000346c:	6442                	ld	s0,16(sp)
    8000346e:	64a2                	ld	s1,8(sp)
    80003470:	6902                	ld	s2,0(sp)
    80003472:	6105                	addi	sp,sp,32
    80003474:	8082                	ret
    panic("freeing free block");
    80003476:	00005517          	auipc	a0,0x5
    8000347a:	15a50513          	addi	a0,a0,346 # 800085d0 <syscalls+0xe8>
    8000347e:	ffffd097          	auipc	ra,0xffffd
    80003482:	0c0080e7          	jalr	192(ra) # 8000053e <panic>

0000000080003486 <balloc>:
{
    80003486:	711d                	addi	sp,sp,-96
    80003488:	ec86                	sd	ra,88(sp)
    8000348a:	e8a2                	sd	s0,80(sp)
    8000348c:	e4a6                	sd	s1,72(sp)
    8000348e:	e0ca                	sd	s2,64(sp)
    80003490:	fc4e                	sd	s3,56(sp)
    80003492:	f852                	sd	s4,48(sp)
    80003494:	f456                	sd	s5,40(sp)
    80003496:	f05a                	sd	s6,32(sp)
    80003498:	ec5e                	sd	s7,24(sp)
    8000349a:	e862                	sd	s8,16(sp)
    8000349c:	e466                	sd	s9,8(sp)
    8000349e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034a0:	0001d797          	auipc	a5,0x1d
    800034a4:	25c7a783          	lw	a5,604(a5) # 800206fc <sb+0x4>
    800034a8:	10078163          	beqz	a5,800035aa <balloc+0x124>
    800034ac:	8baa                	mv	s7,a0
    800034ae:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034b0:	0001db17          	auipc	s6,0x1d
    800034b4:	248b0b13          	addi	s6,s6,584 # 800206f8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034b8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034ba:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034bc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034be:	6c89                	lui	s9,0x2
    800034c0:	a061                	j	80003548 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034c2:	974a                	add	a4,a4,s2
    800034c4:	8fd5                	or	a5,a5,a3
    800034c6:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800034ca:	854a                	mv	a0,s2
    800034cc:	00001097          	auipc	ra,0x1
    800034d0:	0ac080e7          	jalr	172(ra) # 80004578 <log_write>
        brelse(bp);
    800034d4:	854a                	mv	a0,s2
    800034d6:	00000097          	auipc	ra,0x0
    800034da:	e1e080e7          	jalr	-482(ra) # 800032f4 <brelse>
  bp = bread(dev, bno);
    800034de:	85a6                	mv	a1,s1
    800034e0:	855e                	mv	a0,s7
    800034e2:	00000097          	auipc	ra,0x0
    800034e6:	ce2080e7          	jalr	-798(ra) # 800031c4 <bread>
    800034ea:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034ec:	40000613          	li	a2,1024
    800034f0:	4581                	li	a1,0
    800034f2:	05850513          	addi	a0,a0,88
    800034f6:	ffffd097          	auipc	ra,0xffffd
    800034fa:	7dc080e7          	jalr	2012(ra) # 80000cd2 <memset>
  log_write(bp);
    800034fe:	854a                	mv	a0,s2
    80003500:	00001097          	auipc	ra,0x1
    80003504:	078080e7          	jalr	120(ra) # 80004578 <log_write>
  brelse(bp);
    80003508:	854a                	mv	a0,s2
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	dea080e7          	jalr	-534(ra) # 800032f4 <brelse>
}
    80003512:	8526                	mv	a0,s1
    80003514:	60e6                	ld	ra,88(sp)
    80003516:	6446                	ld	s0,80(sp)
    80003518:	64a6                	ld	s1,72(sp)
    8000351a:	6906                	ld	s2,64(sp)
    8000351c:	79e2                	ld	s3,56(sp)
    8000351e:	7a42                	ld	s4,48(sp)
    80003520:	7aa2                	ld	s5,40(sp)
    80003522:	7b02                	ld	s6,32(sp)
    80003524:	6be2                	ld	s7,24(sp)
    80003526:	6c42                	ld	s8,16(sp)
    80003528:	6ca2                	ld	s9,8(sp)
    8000352a:	6125                	addi	sp,sp,96
    8000352c:	8082                	ret
    brelse(bp);
    8000352e:	854a                	mv	a0,s2
    80003530:	00000097          	auipc	ra,0x0
    80003534:	dc4080e7          	jalr	-572(ra) # 800032f4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003538:	015c87bb          	addw	a5,s9,s5
    8000353c:	00078a9b          	sext.w	s5,a5
    80003540:	004b2703          	lw	a4,4(s6)
    80003544:	06eaf363          	bgeu	s5,a4,800035aa <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003548:	41fad79b          	sraiw	a5,s5,0x1f
    8000354c:	0137d79b          	srliw	a5,a5,0x13
    80003550:	015787bb          	addw	a5,a5,s5
    80003554:	40d7d79b          	sraiw	a5,a5,0xd
    80003558:	01cb2583          	lw	a1,28(s6)
    8000355c:	9dbd                	addw	a1,a1,a5
    8000355e:	855e                	mv	a0,s7
    80003560:	00000097          	auipc	ra,0x0
    80003564:	c64080e7          	jalr	-924(ra) # 800031c4 <bread>
    80003568:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000356a:	004b2503          	lw	a0,4(s6)
    8000356e:	000a849b          	sext.w	s1,s5
    80003572:	8662                	mv	a2,s8
    80003574:	faa4fde3          	bgeu	s1,a0,8000352e <balloc+0xa8>
      m = 1 << (bi % 8);
    80003578:	41f6579b          	sraiw	a5,a2,0x1f
    8000357c:	01d7d69b          	srliw	a3,a5,0x1d
    80003580:	00c6873b          	addw	a4,a3,a2
    80003584:	00777793          	andi	a5,a4,7
    80003588:	9f95                	subw	a5,a5,a3
    8000358a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000358e:	4037571b          	sraiw	a4,a4,0x3
    80003592:	00e906b3          	add	a3,s2,a4
    80003596:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    8000359a:	00d7f5b3          	and	a1,a5,a3
    8000359e:	d195                	beqz	a1,800034c2 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035a0:	2605                	addiw	a2,a2,1
    800035a2:	2485                	addiw	s1,s1,1
    800035a4:	fd4618e3          	bne	a2,s4,80003574 <balloc+0xee>
    800035a8:	b759                	j	8000352e <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800035aa:	00005517          	auipc	a0,0x5
    800035ae:	03e50513          	addi	a0,a0,62 # 800085e8 <syscalls+0x100>
    800035b2:	ffffd097          	auipc	ra,0xffffd
    800035b6:	fd6080e7          	jalr	-42(ra) # 80000588 <printf>
  return 0;
    800035ba:	4481                	li	s1,0
    800035bc:	bf99                	j	80003512 <balloc+0x8c>

00000000800035be <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035be:	7179                	addi	sp,sp,-48
    800035c0:	f406                	sd	ra,40(sp)
    800035c2:	f022                	sd	s0,32(sp)
    800035c4:	ec26                	sd	s1,24(sp)
    800035c6:	e84a                	sd	s2,16(sp)
    800035c8:	e44e                	sd	s3,8(sp)
    800035ca:	e052                	sd	s4,0(sp)
    800035cc:	1800                	addi	s0,sp,48
    800035ce:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035d0:	47ad                	li	a5,11
    800035d2:	02b7e763          	bltu	a5,a1,80003600 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800035d6:	02059493          	slli	s1,a1,0x20
    800035da:	9081                	srli	s1,s1,0x20
    800035dc:	048a                	slli	s1,s1,0x2
    800035de:	94aa                	add	s1,s1,a0
    800035e0:	0504a903          	lw	s2,80(s1)
    800035e4:	06091e63          	bnez	s2,80003660 <bmap+0xa2>
      addr = balloc(ip->dev);
    800035e8:	4108                	lw	a0,0(a0)
    800035ea:	00000097          	auipc	ra,0x0
    800035ee:	e9c080e7          	jalr	-356(ra) # 80003486 <balloc>
    800035f2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035f6:	06090563          	beqz	s2,80003660 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800035fa:	0524a823          	sw	s2,80(s1)
    800035fe:	a08d                	j	80003660 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003600:	ff45849b          	addiw	s1,a1,-12
    80003604:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003608:	0ff00793          	li	a5,255
    8000360c:	08e7e563          	bltu	a5,a4,80003696 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003610:	08052903          	lw	s2,128(a0)
    80003614:	00091d63          	bnez	s2,8000362e <bmap+0x70>
      addr = balloc(ip->dev);
    80003618:	4108                	lw	a0,0(a0)
    8000361a:	00000097          	auipc	ra,0x0
    8000361e:	e6c080e7          	jalr	-404(ra) # 80003486 <balloc>
    80003622:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003626:	02090d63          	beqz	s2,80003660 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000362a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000362e:	85ca                	mv	a1,s2
    80003630:	0009a503          	lw	a0,0(s3)
    80003634:	00000097          	auipc	ra,0x0
    80003638:	b90080e7          	jalr	-1136(ra) # 800031c4 <bread>
    8000363c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000363e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003642:	02049593          	slli	a1,s1,0x20
    80003646:	9181                	srli	a1,a1,0x20
    80003648:	058a                	slli	a1,a1,0x2
    8000364a:	00b784b3          	add	s1,a5,a1
    8000364e:	0004a903          	lw	s2,0(s1)
    80003652:	02090063          	beqz	s2,80003672 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003656:	8552                	mv	a0,s4
    80003658:	00000097          	auipc	ra,0x0
    8000365c:	c9c080e7          	jalr	-868(ra) # 800032f4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003660:	854a                	mv	a0,s2
    80003662:	70a2                	ld	ra,40(sp)
    80003664:	7402                	ld	s0,32(sp)
    80003666:	64e2                	ld	s1,24(sp)
    80003668:	6942                	ld	s2,16(sp)
    8000366a:	69a2                	ld	s3,8(sp)
    8000366c:	6a02                	ld	s4,0(sp)
    8000366e:	6145                	addi	sp,sp,48
    80003670:	8082                	ret
      addr = balloc(ip->dev);
    80003672:	0009a503          	lw	a0,0(s3)
    80003676:	00000097          	auipc	ra,0x0
    8000367a:	e10080e7          	jalr	-496(ra) # 80003486 <balloc>
    8000367e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003682:	fc090ae3          	beqz	s2,80003656 <bmap+0x98>
        a[bn] = addr;
    80003686:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000368a:	8552                	mv	a0,s4
    8000368c:	00001097          	auipc	ra,0x1
    80003690:	eec080e7          	jalr	-276(ra) # 80004578 <log_write>
    80003694:	b7c9                	j	80003656 <bmap+0x98>
  panic("bmap: out of range");
    80003696:	00005517          	auipc	a0,0x5
    8000369a:	f6a50513          	addi	a0,a0,-150 # 80008600 <syscalls+0x118>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	ea0080e7          	jalr	-352(ra) # 8000053e <panic>

00000000800036a6 <iget>:
{
    800036a6:	7179                	addi	sp,sp,-48
    800036a8:	f406                	sd	ra,40(sp)
    800036aa:	f022                	sd	s0,32(sp)
    800036ac:	ec26                	sd	s1,24(sp)
    800036ae:	e84a                	sd	s2,16(sp)
    800036b0:	e44e                	sd	s3,8(sp)
    800036b2:	e052                	sd	s4,0(sp)
    800036b4:	1800                	addi	s0,sp,48
    800036b6:	89aa                	mv	s3,a0
    800036b8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036ba:	0001d517          	auipc	a0,0x1d
    800036be:	05e50513          	addi	a0,a0,94 # 80020718 <itable>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	514080e7          	jalr	1300(ra) # 80000bd6 <acquire>
  empty = 0;
    800036ca:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036cc:	0001d497          	auipc	s1,0x1d
    800036d0:	06448493          	addi	s1,s1,100 # 80020730 <itable+0x18>
    800036d4:	0001f697          	auipc	a3,0x1f
    800036d8:	aec68693          	addi	a3,a3,-1300 # 800221c0 <log>
    800036dc:	a039                	j	800036ea <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036de:	02090b63          	beqz	s2,80003714 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036e2:	08848493          	addi	s1,s1,136
    800036e6:	02d48a63          	beq	s1,a3,8000371a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036ea:	449c                	lw	a5,8(s1)
    800036ec:	fef059e3          	blez	a5,800036de <iget+0x38>
    800036f0:	4098                	lw	a4,0(s1)
    800036f2:	ff3716e3          	bne	a4,s3,800036de <iget+0x38>
    800036f6:	40d8                	lw	a4,4(s1)
    800036f8:	ff4713e3          	bne	a4,s4,800036de <iget+0x38>
      ip->ref++;
    800036fc:	2785                	addiw	a5,a5,1
    800036fe:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003700:	0001d517          	auipc	a0,0x1d
    80003704:	01850513          	addi	a0,a0,24 # 80020718 <itable>
    80003708:	ffffd097          	auipc	ra,0xffffd
    8000370c:	582080e7          	jalr	1410(ra) # 80000c8a <release>
      return ip;
    80003710:	8926                	mv	s2,s1
    80003712:	a03d                	j	80003740 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003714:	f7f9                	bnez	a5,800036e2 <iget+0x3c>
    80003716:	8926                	mv	s2,s1
    80003718:	b7e9                	j	800036e2 <iget+0x3c>
  if(empty == 0)
    8000371a:	02090c63          	beqz	s2,80003752 <iget+0xac>
  ip->dev = dev;
    8000371e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003722:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003726:	4785                	li	a5,1
    80003728:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000372c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003730:	0001d517          	auipc	a0,0x1d
    80003734:	fe850513          	addi	a0,a0,-24 # 80020718 <itable>
    80003738:	ffffd097          	auipc	ra,0xffffd
    8000373c:	552080e7          	jalr	1362(ra) # 80000c8a <release>
}
    80003740:	854a                	mv	a0,s2
    80003742:	70a2                	ld	ra,40(sp)
    80003744:	7402                	ld	s0,32(sp)
    80003746:	64e2                	ld	s1,24(sp)
    80003748:	6942                	ld	s2,16(sp)
    8000374a:	69a2                	ld	s3,8(sp)
    8000374c:	6a02                	ld	s4,0(sp)
    8000374e:	6145                	addi	sp,sp,48
    80003750:	8082                	ret
    panic("iget: no inodes");
    80003752:	00005517          	auipc	a0,0x5
    80003756:	ec650513          	addi	a0,a0,-314 # 80008618 <syscalls+0x130>
    8000375a:	ffffd097          	auipc	ra,0xffffd
    8000375e:	de4080e7          	jalr	-540(ra) # 8000053e <panic>

0000000080003762 <fsinit>:
fsinit(int dev) {
    80003762:	7179                	addi	sp,sp,-48
    80003764:	f406                	sd	ra,40(sp)
    80003766:	f022                	sd	s0,32(sp)
    80003768:	ec26                	sd	s1,24(sp)
    8000376a:	e84a                	sd	s2,16(sp)
    8000376c:	e44e                	sd	s3,8(sp)
    8000376e:	1800                	addi	s0,sp,48
    80003770:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003772:	4585                	li	a1,1
    80003774:	00000097          	auipc	ra,0x0
    80003778:	a50080e7          	jalr	-1456(ra) # 800031c4 <bread>
    8000377c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000377e:	0001d997          	auipc	s3,0x1d
    80003782:	f7a98993          	addi	s3,s3,-134 # 800206f8 <sb>
    80003786:	02000613          	li	a2,32
    8000378a:	05850593          	addi	a1,a0,88
    8000378e:	854e                	mv	a0,s3
    80003790:	ffffd097          	auipc	ra,0xffffd
    80003794:	59e080e7          	jalr	1438(ra) # 80000d2e <memmove>
  brelse(bp);
    80003798:	8526                	mv	a0,s1
    8000379a:	00000097          	auipc	ra,0x0
    8000379e:	b5a080e7          	jalr	-1190(ra) # 800032f4 <brelse>
  if(sb.magic != FSMAGIC)
    800037a2:	0009a703          	lw	a4,0(s3)
    800037a6:	102037b7          	lui	a5,0x10203
    800037aa:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037ae:	02f71263          	bne	a4,a5,800037d2 <fsinit+0x70>
  initlog(dev, &sb);
    800037b2:	0001d597          	auipc	a1,0x1d
    800037b6:	f4658593          	addi	a1,a1,-186 # 800206f8 <sb>
    800037ba:	854a                	mv	a0,s2
    800037bc:	00001097          	auipc	ra,0x1
    800037c0:	b40080e7          	jalr	-1216(ra) # 800042fc <initlog>
}
    800037c4:	70a2                	ld	ra,40(sp)
    800037c6:	7402                	ld	s0,32(sp)
    800037c8:	64e2                	ld	s1,24(sp)
    800037ca:	6942                	ld	s2,16(sp)
    800037cc:	69a2                	ld	s3,8(sp)
    800037ce:	6145                	addi	sp,sp,48
    800037d0:	8082                	ret
    panic("invalid file system");
    800037d2:	00005517          	auipc	a0,0x5
    800037d6:	e5650513          	addi	a0,a0,-426 # 80008628 <syscalls+0x140>
    800037da:	ffffd097          	auipc	ra,0xffffd
    800037de:	d64080e7          	jalr	-668(ra) # 8000053e <panic>

00000000800037e2 <iinit>:
{
    800037e2:	7179                	addi	sp,sp,-48
    800037e4:	f406                	sd	ra,40(sp)
    800037e6:	f022                	sd	s0,32(sp)
    800037e8:	ec26                	sd	s1,24(sp)
    800037ea:	e84a                	sd	s2,16(sp)
    800037ec:	e44e                	sd	s3,8(sp)
    800037ee:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800037f0:	00005597          	auipc	a1,0x5
    800037f4:	e5058593          	addi	a1,a1,-432 # 80008640 <syscalls+0x158>
    800037f8:	0001d517          	auipc	a0,0x1d
    800037fc:	f2050513          	addi	a0,a0,-224 # 80020718 <itable>
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	346080e7          	jalr	838(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003808:	0001d497          	auipc	s1,0x1d
    8000380c:	f3848493          	addi	s1,s1,-200 # 80020740 <itable+0x28>
    80003810:	0001f997          	auipc	s3,0x1f
    80003814:	9c098993          	addi	s3,s3,-1600 # 800221d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003818:	00005917          	auipc	s2,0x5
    8000381c:	e3090913          	addi	s2,s2,-464 # 80008648 <syscalls+0x160>
    80003820:	85ca                	mv	a1,s2
    80003822:	8526                	mv	a0,s1
    80003824:	00001097          	auipc	ra,0x1
    80003828:	e3a080e7          	jalr	-454(ra) # 8000465e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000382c:	08848493          	addi	s1,s1,136
    80003830:	ff3498e3          	bne	s1,s3,80003820 <iinit+0x3e>
}
    80003834:	70a2                	ld	ra,40(sp)
    80003836:	7402                	ld	s0,32(sp)
    80003838:	64e2                	ld	s1,24(sp)
    8000383a:	6942                	ld	s2,16(sp)
    8000383c:	69a2                	ld	s3,8(sp)
    8000383e:	6145                	addi	sp,sp,48
    80003840:	8082                	ret

0000000080003842 <ialloc>:
{
    80003842:	715d                	addi	sp,sp,-80
    80003844:	e486                	sd	ra,72(sp)
    80003846:	e0a2                	sd	s0,64(sp)
    80003848:	fc26                	sd	s1,56(sp)
    8000384a:	f84a                	sd	s2,48(sp)
    8000384c:	f44e                	sd	s3,40(sp)
    8000384e:	f052                	sd	s4,32(sp)
    80003850:	ec56                	sd	s5,24(sp)
    80003852:	e85a                	sd	s6,16(sp)
    80003854:	e45e                	sd	s7,8(sp)
    80003856:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003858:	0001d717          	auipc	a4,0x1d
    8000385c:	eac72703          	lw	a4,-340(a4) # 80020704 <sb+0xc>
    80003860:	4785                	li	a5,1
    80003862:	04e7fa63          	bgeu	a5,a4,800038b6 <ialloc+0x74>
    80003866:	8aaa                	mv	s5,a0
    80003868:	8bae                	mv	s7,a1
    8000386a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000386c:	0001da17          	auipc	s4,0x1d
    80003870:	e8ca0a13          	addi	s4,s4,-372 # 800206f8 <sb>
    80003874:	00048b1b          	sext.w	s6,s1
    80003878:	0044d793          	srli	a5,s1,0x4
    8000387c:	018a2583          	lw	a1,24(s4)
    80003880:	9dbd                	addw	a1,a1,a5
    80003882:	8556                	mv	a0,s5
    80003884:	00000097          	auipc	ra,0x0
    80003888:	940080e7          	jalr	-1728(ra) # 800031c4 <bread>
    8000388c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000388e:	05850993          	addi	s3,a0,88
    80003892:	00f4f793          	andi	a5,s1,15
    80003896:	079a                	slli	a5,a5,0x6
    80003898:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000389a:	00099783          	lh	a5,0(s3)
    8000389e:	c3a1                	beqz	a5,800038de <ialloc+0x9c>
    brelse(bp);
    800038a0:	00000097          	auipc	ra,0x0
    800038a4:	a54080e7          	jalr	-1452(ra) # 800032f4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038a8:	0485                	addi	s1,s1,1
    800038aa:	00ca2703          	lw	a4,12(s4)
    800038ae:	0004879b          	sext.w	a5,s1
    800038b2:	fce7e1e3          	bltu	a5,a4,80003874 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800038b6:	00005517          	auipc	a0,0x5
    800038ba:	d9a50513          	addi	a0,a0,-614 # 80008650 <syscalls+0x168>
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	cca080e7          	jalr	-822(ra) # 80000588 <printf>
  return 0;
    800038c6:	4501                	li	a0,0
}
    800038c8:	60a6                	ld	ra,72(sp)
    800038ca:	6406                	ld	s0,64(sp)
    800038cc:	74e2                	ld	s1,56(sp)
    800038ce:	7942                	ld	s2,48(sp)
    800038d0:	79a2                	ld	s3,40(sp)
    800038d2:	7a02                	ld	s4,32(sp)
    800038d4:	6ae2                	ld	s5,24(sp)
    800038d6:	6b42                	ld	s6,16(sp)
    800038d8:	6ba2                	ld	s7,8(sp)
    800038da:	6161                	addi	sp,sp,80
    800038dc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038de:	04000613          	li	a2,64
    800038e2:	4581                	li	a1,0
    800038e4:	854e                	mv	a0,s3
    800038e6:	ffffd097          	auipc	ra,0xffffd
    800038ea:	3ec080e7          	jalr	1004(ra) # 80000cd2 <memset>
      dip->type = type;
    800038ee:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038f2:	854a                	mv	a0,s2
    800038f4:	00001097          	auipc	ra,0x1
    800038f8:	c84080e7          	jalr	-892(ra) # 80004578 <log_write>
      brelse(bp);
    800038fc:	854a                	mv	a0,s2
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	9f6080e7          	jalr	-1546(ra) # 800032f4 <brelse>
      return iget(dev, inum);
    80003906:	85da                	mv	a1,s6
    80003908:	8556                	mv	a0,s5
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	d9c080e7          	jalr	-612(ra) # 800036a6 <iget>
    80003912:	bf5d                	j	800038c8 <ialloc+0x86>

0000000080003914 <iupdate>:
{
    80003914:	1101                	addi	sp,sp,-32
    80003916:	ec06                	sd	ra,24(sp)
    80003918:	e822                	sd	s0,16(sp)
    8000391a:	e426                	sd	s1,8(sp)
    8000391c:	e04a                	sd	s2,0(sp)
    8000391e:	1000                	addi	s0,sp,32
    80003920:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003922:	415c                	lw	a5,4(a0)
    80003924:	0047d79b          	srliw	a5,a5,0x4
    80003928:	0001d597          	auipc	a1,0x1d
    8000392c:	de85a583          	lw	a1,-536(a1) # 80020710 <sb+0x18>
    80003930:	9dbd                	addw	a1,a1,a5
    80003932:	4108                	lw	a0,0(a0)
    80003934:	00000097          	auipc	ra,0x0
    80003938:	890080e7          	jalr	-1904(ra) # 800031c4 <bread>
    8000393c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000393e:	05850793          	addi	a5,a0,88
    80003942:	40c8                	lw	a0,4(s1)
    80003944:	893d                	andi	a0,a0,15
    80003946:	051a                	slli	a0,a0,0x6
    80003948:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000394a:	04449703          	lh	a4,68(s1)
    8000394e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003952:	04649703          	lh	a4,70(s1)
    80003956:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000395a:	04849703          	lh	a4,72(s1)
    8000395e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003962:	04a49703          	lh	a4,74(s1)
    80003966:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000396a:	44f8                	lw	a4,76(s1)
    8000396c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000396e:	03400613          	li	a2,52
    80003972:	05048593          	addi	a1,s1,80
    80003976:	0531                	addi	a0,a0,12
    80003978:	ffffd097          	auipc	ra,0xffffd
    8000397c:	3b6080e7          	jalr	950(ra) # 80000d2e <memmove>
  log_write(bp);
    80003980:	854a                	mv	a0,s2
    80003982:	00001097          	auipc	ra,0x1
    80003986:	bf6080e7          	jalr	-1034(ra) # 80004578 <log_write>
  brelse(bp);
    8000398a:	854a                	mv	a0,s2
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	968080e7          	jalr	-1688(ra) # 800032f4 <brelse>
}
    80003994:	60e2                	ld	ra,24(sp)
    80003996:	6442                	ld	s0,16(sp)
    80003998:	64a2                	ld	s1,8(sp)
    8000399a:	6902                	ld	s2,0(sp)
    8000399c:	6105                	addi	sp,sp,32
    8000399e:	8082                	ret

00000000800039a0 <idup>:
{
    800039a0:	1101                	addi	sp,sp,-32
    800039a2:	ec06                	sd	ra,24(sp)
    800039a4:	e822                	sd	s0,16(sp)
    800039a6:	e426                	sd	s1,8(sp)
    800039a8:	1000                	addi	s0,sp,32
    800039aa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039ac:	0001d517          	auipc	a0,0x1d
    800039b0:	d6c50513          	addi	a0,a0,-660 # 80020718 <itable>
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	222080e7          	jalr	546(ra) # 80000bd6 <acquire>
  ip->ref++;
    800039bc:	449c                	lw	a5,8(s1)
    800039be:	2785                	addiw	a5,a5,1
    800039c0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039c2:	0001d517          	auipc	a0,0x1d
    800039c6:	d5650513          	addi	a0,a0,-682 # 80020718 <itable>
    800039ca:	ffffd097          	auipc	ra,0xffffd
    800039ce:	2c0080e7          	jalr	704(ra) # 80000c8a <release>
}
    800039d2:	8526                	mv	a0,s1
    800039d4:	60e2                	ld	ra,24(sp)
    800039d6:	6442                	ld	s0,16(sp)
    800039d8:	64a2                	ld	s1,8(sp)
    800039da:	6105                	addi	sp,sp,32
    800039dc:	8082                	ret

00000000800039de <ilock>:
{
    800039de:	1101                	addi	sp,sp,-32
    800039e0:	ec06                	sd	ra,24(sp)
    800039e2:	e822                	sd	s0,16(sp)
    800039e4:	e426                	sd	s1,8(sp)
    800039e6:	e04a                	sd	s2,0(sp)
    800039e8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039ea:	c115                	beqz	a0,80003a0e <ilock+0x30>
    800039ec:	84aa                	mv	s1,a0
    800039ee:	451c                	lw	a5,8(a0)
    800039f0:	00f05f63          	blez	a5,80003a0e <ilock+0x30>
  acquiresleep(&ip->lock);
    800039f4:	0541                	addi	a0,a0,16
    800039f6:	00001097          	auipc	ra,0x1
    800039fa:	ca2080e7          	jalr	-862(ra) # 80004698 <acquiresleep>
  if(ip->valid == 0){
    800039fe:	40bc                	lw	a5,64(s1)
    80003a00:	cf99                	beqz	a5,80003a1e <ilock+0x40>
}
    80003a02:	60e2                	ld	ra,24(sp)
    80003a04:	6442                	ld	s0,16(sp)
    80003a06:	64a2                	ld	s1,8(sp)
    80003a08:	6902                	ld	s2,0(sp)
    80003a0a:	6105                	addi	sp,sp,32
    80003a0c:	8082                	ret
    panic("ilock");
    80003a0e:	00005517          	auipc	a0,0x5
    80003a12:	c5a50513          	addi	a0,a0,-934 # 80008668 <syscalls+0x180>
    80003a16:	ffffd097          	auipc	ra,0xffffd
    80003a1a:	b28080e7          	jalr	-1240(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a1e:	40dc                	lw	a5,4(s1)
    80003a20:	0047d79b          	srliw	a5,a5,0x4
    80003a24:	0001d597          	auipc	a1,0x1d
    80003a28:	cec5a583          	lw	a1,-788(a1) # 80020710 <sb+0x18>
    80003a2c:	9dbd                	addw	a1,a1,a5
    80003a2e:	4088                	lw	a0,0(s1)
    80003a30:	fffff097          	auipc	ra,0xfffff
    80003a34:	794080e7          	jalr	1940(ra) # 800031c4 <bread>
    80003a38:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a3a:	05850593          	addi	a1,a0,88
    80003a3e:	40dc                	lw	a5,4(s1)
    80003a40:	8bbd                	andi	a5,a5,15
    80003a42:	079a                	slli	a5,a5,0x6
    80003a44:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a46:	00059783          	lh	a5,0(a1)
    80003a4a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a4e:	00259783          	lh	a5,2(a1)
    80003a52:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a56:	00459783          	lh	a5,4(a1)
    80003a5a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a5e:	00659783          	lh	a5,6(a1)
    80003a62:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a66:	459c                	lw	a5,8(a1)
    80003a68:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a6a:	03400613          	li	a2,52
    80003a6e:	05b1                	addi	a1,a1,12
    80003a70:	05048513          	addi	a0,s1,80
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	2ba080e7          	jalr	698(ra) # 80000d2e <memmove>
    brelse(bp);
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	00000097          	auipc	ra,0x0
    80003a82:	876080e7          	jalr	-1930(ra) # 800032f4 <brelse>
    ip->valid = 1;
    80003a86:	4785                	li	a5,1
    80003a88:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a8a:	04449783          	lh	a5,68(s1)
    80003a8e:	fbb5                	bnez	a5,80003a02 <ilock+0x24>
      panic("ilock: no type");
    80003a90:	00005517          	auipc	a0,0x5
    80003a94:	be050513          	addi	a0,a0,-1056 # 80008670 <syscalls+0x188>
    80003a98:	ffffd097          	auipc	ra,0xffffd
    80003a9c:	aa6080e7          	jalr	-1370(ra) # 8000053e <panic>

0000000080003aa0 <iunlock>:
{
    80003aa0:	1101                	addi	sp,sp,-32
    80003aa2:	ec06                	sd	ra,24(sp)
    80003aa4:	e822                	sd	s0,16(sp)
    80003aa6:	e426                	sd	s1,8(sp)
    80003aa8:	e04a                	sd	s2,0(sp)
    80003aaa:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003aac:	c905                	beqz	a0,80003adc <iunlock+0x3c>
    80003aae:	84aa                	mv	s1,a0
    80003ab0:	01050913          	addi	s2,a0,16
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	00001097          	auipc	ra,0x1
    80003aba:	c7c080e7          	jalr	-900(ra) # 80004732 <holdingsleep>
    80003abe:	cd19                	beqz	a0,80003adc <iunlock+0x3c>
    80003ac0:	449c                	lw	a5,8(s1)
    80003ac2:	00f05d63          	blez	a5,80003adc <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ac6:	854a                	mv	a0,s2
    80003ac8:	00001097          	auipc	ra,0x1
    80003acc:	c26080e7          	jalr	-986(ra) # 800046ee <releasesleep>
}
    80003ad0:	60e2                	ld	ra,24(sp)
    80003ad2:	6442                	ld	s0,16(sp)
    80003ad4:	64a2                	ld	s1,8(sp)
    80003ad6:	6902                	ld	s2,0(sp)
    80003ad8:	6105                	addi	sp,sp,32
    80003ada:	8082                	ret
    panic("iunlock");
    80003adc:	00005517          	auipc	a0,0x5
    80003ae0:	ba450513          	addi	a0,a0,-1116 # 80008680 <syscalls+0x198>
    80003ae4:	ffffd097          	auipc	ra,0xffffd
    80003ae8:	a5a080e7          	jalr	-1446(ra) # 8000053e <panic>

0000000080003aec <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003aec:	7179                	addi	sp,sp,-48
    80003aee:	f406                	sd	ra,40(sp)
    80003af0:	f022                	sd	s0,32(sp)
    80003af2:	ec26                	sd	s1,24(sp)
    80003af4:	e84a                	sd	s2,16(sp)
    80003af6:	e44e                	sd	s3,8(sp)
    80003af8:	e052                	sd	s4,0(sp)
    80003afa:	1800                	addi	s0,sp,48
    80003afc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003afe:	05050493          	addi	s1,a0,80
    80003b02:	08050913          	addi	s2,a0,128
    80003b06:	a021                	j	80003b0e <itrunc+0x22>
    80003b08:	0491                	addi	s1,s1,4
    80003b0a:	01248d63          	beq	s1,s2,80003b24 <itrunc+0x38>
    if(ip->addrs[i]){
    80003b0e:	408c                	lw	a1,0(s1)
    80003b10:	dde5                	beqz	a1,80003b08 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b12:	0009a503          	lw	a0,0(s3)
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	8f4080e7          	jalr	-1804(ra) # 8000340a <bfree>
      ip->addrs[i] = 0;
    80003b1e:	0004a023          	sw	zero,0(s1)
    80003b22:	b7dd                	j	80003b08 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b24:	0809a583          	lw	a1,128(s3)
    80003b28:	e185                	bnez	a1,80003b48 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b2a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b2e:	854e                	mv	a0,s3
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	de4080e7          	jalr	-540(ra) # 80003914 <iupdate>
}
    80003b38:	70a2                	ld	ra,40(sp)
    80003b3a:	7402                	ld	s0,32(sp)
    80003b3c:	64e2                	ld	s1,24(sp)
    80003b3e:	6942                	ld	s2,16(sp)
    80003b40:	69a2                	ld	s3,8(sp)
    80003b42:	6a02                	ld	s4,0(sp)
    80003b44:	6145                	addi	sp,sp,48
    80003b46:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b48:	0009a503          	lw	a0,0(s3)
    80003b4c:	fffff097          	auipc	ra,0xfffff
    80003b50:	678080e7          	jalr	1656(ra) # 800031c4 <bread>
    80003b54:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b56:	05850493          	addi	s1,a0,88
    80003b5a:	45850913          	addi	s2,a0,1112
    80003b5e:	a021                	j	80003b66 <itrunc+0x7a>
    80003b60:	0491                	addi	s1,s1,4
    80003b62:	01248b63          	beq	s1,s2,80003b78 <itrunc+0x8c>
      if(a[j])
    80003b66:	408c                	lw	a1,0(s1)
    80003b68:	dde5                	beqz	a1,80003b60 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b6a:	0009a503          	lw	a0,0(s3)
    80003b6e:	00000097          	auipc	ra,0x0
    80003b72:	89c080e7          	jalr	-1892(ra) # 8000340a <bfree>
    80003b76:	b7ed                	j	80003b60 <itrunc+0x74>
    brelse(bp);
    80003b78:	8552                	mv	a0,s4
    80003b7a:	fffff097          	auipc	ra,0xfffff
    80003b7e:	77a080e7          	jalr	1914(ra) # 800032f4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b82:	0809a583          	lw	a1,128(s3)
    80003b86:	0009a503          	lw	a0,0(s3)
    80003b8a:	00000097          	auipc	ra,0x0
    80003b8e:	880080e7          	jalr	-1920(ra) # 8000340a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b92:	0809a023          	sw	zero,128(s3)
    80003b96:	bf51                	j	80003b2a <itrunc+0x3e>

0000000080003b98 <iput>:
{
    80003b98:	1101                	addi	sp,sp,-32
    80003b9a:	ec06                	sd	ra,24(sp)
    80003b9c:	e822                	sd	s0,16(sp)
    80003b9e:	e426                	sd	s1,8(sp)
    80003ba0:	e04a                	sd	s2,0(sp)
    80003ba2:	1000                	addi	s0,sp,32
    80003ba4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ba6:	0001d517          	auipc	a0,0x1d
    80003baa:	b7250513          	addi	a0,a0,-1166 # 80020718 <itable>
    80003bae:	ffffd097          	auipc	ra,0xffffd
    80003bb2:	028080e7          	jalr	40(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bb6:	4498                	lw	a4,8(s1)
    80003bb8:	4785                	li	a5,1
    80003bba:	02f70363          	beq	a4,a5,80003be0 <iput+0x48>
  ip->ref--;
    80003bbe:	449c                	lw	a5,8(s1)
    80003bc0:	37fd                	addiw	a5,a5,-1
    80003bc2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bc4:	0001d517          	auipc	a0,0x1d
    80003bc8:	b5450513          	addi	a0,a0,-1196 # 80020718 <itable>
    80003bcc:	ffffd097          	auipc	ra,0xffffd
    80003bd0:	0be080e7          	jalr	190(ra) # 80000c8a <release>
}
    80003bd4:	60e2                	ld	ra,24(sp)
    80003bd6:	6442                	ld	s0,16(sp)
    80003bd8:	64a2                	ld	s1,8(sp)
    80003bda:	6902                	ld	s2,0(sp)
    80003bdc:	6105                	addi	sp,sp,32
    80003bde:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003be0:	40bc                	lw	a5,64(s1)
    80003be2:	dff1                	beqz	a5,80003bbe <iput+0x26>
    80003be4:	04a49783          	lh	a5,74(s1)
    80003be8:	fbf9                	bnez	a5,80003bbe <iput+0x26>
    acquiresleep(&ip->lock);
    80003bea:	01048913          	addi	s2,s1,16
    80003bee:	854a                	mv	a0,s2
    80003bf0:	00001097          	auipc	ra,0x1
    80003bf4:	aa8080e7          	jalr	-1368(ra) # 80004698 <acquiresleep>
    release(&itable.lock);
    80003bf8:	0001d517          	auipc	a0,0x1d
    80003bfc:	b2050513          	addi	a0,a0,-1248 # 80020718 <itable>
    80003c00:	ffffd097          	auipc	ra,0xffffd
    80003c04:	08a080e7          	jalr	138(ra) # 80000c8a <release>
    itrunc(ip);
    80003c08:	8526                	mv	a0,s1
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	ee2080e7          	jalr	-286(ra) # 80003aec <itrunc>
    ip->type = 0;
    80003c12:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c16:	8526                	mv	a0,s1
    80003c18:	00000097          	auipc	ra,0x0
    80003c1c:	cfc080e7          	jalr	-772(ra) # 80003914 <iupdate>
    ip->valid = 0;
    80003c20:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c24:	854a                	mv	a0,s2
    80003c26:	00001097          	auipc	ra,0x1
    80003c2a:	ac8080e7          	jalr	-1336(ra) # 800046ee <releasesleep>
    acquire(&itable.lock);
    80003c2e:	0001d517          	auipc	a0,0x1d
    80003c32:	aea50513          	addi	a0,a0,-1302 # 80020718 <itable>
    80003c36:	ffffd097          	auipc	ra,0xffffd
    80003c3a:	fa0080e7          	jalr	-96(ra) # 80000bd6 <acquire>
    80003c3e:	b741                	j	80003bbe <iput+0x26>

0000000080003c40 <iunlockput>:
{
    80003c40:	1101                	addi	sp,sp,-32
    80003c42:	ec06                	sd	ra,24(sp)
    80003c44:	e822                	sd	s0,16(sp)
    80003c46:	e426                	sd	s1,8(sp)
    80003c48:	1000                	addi	s0,sp,32
    80003c4a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c4c:	00000097          	auipc	ra,0x0
    80003c50:	e54080e7          	jalr	-428(ra) # 80003aa0 <iunlock>
  iput(ip);
    80003c54:	8526                	mv	a0,s1
    80003c56:	00000097          	auipc	ra,0x0
    80003c5a:	f42080e7          	jalr	-190(ra) # 80003b98 <iput>
}
    80003c5e:	60e2                	ld	ra,24(sp)
    80003c60:	6442                	ld	s0,16(sp)
    80003c62:	64a2                	ld	s1,8(sp)
    80003c64:	6105                	addi	sp,sp,32
    80003c66:	8082                	ret

0000000080003c68 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c68:	1141                	addi	sp,sp,-16
    80003c6a:	e422                	sd	s0,8(sp)
    80003c6c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c6e:	411c                	lw	a5,0(a0)
    80003c70:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c72:	415c                	lw	a5,4(a0)
    80003c74:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c76:	04451783          	lh	a5,68(a0)
    80003c7a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c7e:	04a51783          	lh	a5,74(a0)
    80003c82:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c86:	04c56783          	lwu	a5,76(a0)
    80003c8a:	e99c                	sd	a5,16(a1)
}
    80003c8c:	6422                	ld	s0,8(sp)
    80003c8e:	0141                	addi	sp,sp,16
    80003c90:	8082                	ret

0000000080003c92 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c92:	457c                	lw	a5,76(a0)
    80003c94:	0ed7e963          	bltu	a5,a3,80003d86 <readi+0xf4>
{
    80003c98:	7159                	addi	sp,sp,-112
    80003c9a:	f486                	sd	ra,104(sp)
    80003c9c:	f0a2                	sd	s0,96(sp)
    80003c9e:	eca6                	sd	s1,88(sp)
    80003ca0:	e8ca                	sd	s2,80(sp)
    80003ca2:	e4ce                	sd	s3,72(sp)
    80003ca4:	e0d2                	sd	s4,64(sp)
    80003ca6:	fc56                	sd	s5,56(sp)
    80003ca8:	f85a                	sd	s6,48(sp)
    80003caa:	f45e                	sd	s7,40(sp)
    80003cac:	f062                	sd	s8,32(sp)
    80003cae:	ec66                	sd	s9,24(sp)
    80003cb0:	e86a                	sd	s10,16(sp)
    80003cb2:	e46e                	sd	s11,8(sp)
    80003cb4:	1880                	addi	s0,sp,112
    80003cb6:	8b2a                	mv	s6,a0
    80003cb8:	8bae                	mv	s7,a1
    80003cba:	8a32                	mv	s4,a2
    80003cbc:	84b6                	mv	s1,a3
    80003cbe:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003cc0:	9f35                	addw	a4,a4,a3
    return 0;
    80003cc2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cc4:	0ad76063          	bltu	a4,a3,80003d64 <readi+0xd2>
  if(off + n > ip->size)
    80003cc8:	00e7f463          	bgeu	a5,a4,80003cd0 <readi+0x3e>
    n = ip->size - off;
    80003ccc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cd0:	0a0a8963          	beqz	s5,80003d82 <readi+0xf0>
    80003cd4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cda:	5c7d                	li	s8,-1
    80003cdc:	a82d                	j	80003d16 <readi+0x84>
    80003cde:	020d1d93          	slli	s11,s10,0x20
    80003ce2:	020ddd93          	srli	s11,s11,0x20
    80003ce6:	05890793          	addi	a5,s2,88
    80003cea:	86ee                	mv	a3,s11
    80003cec:	963e                	add	a2,a2,a5
    80003cee:	85d2                	mv	a1,s4
    80003cf0:	855e                	mv	a0,s7
    80003cf2:	fffff097          	auipc	ra,0xfffff
    80003cf6:	8ce080e7          	jalr	-1842(ra) # 800025c0 <either_copyout>
    80003cfa:	05850d63          	beq	a0,s8,80003d54 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cfe:	854a                	mv	a0,s2
    80003d00:	fffff097          	auipc	ra,0xfffff
    80003d04:	5f4080e7          	jalr	1524(ra) # 800032f4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d08:	013d09bb          	addw	s3,s10,s3
    80003d0c:	009d04bb          	addw	s1,s10,s1
    80003d10:	9a6e                	add	s4,s4,s11
    80003d12:	0559f763          	bgeu	s3,s5,80003d60 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003d16:	00a4d59b          	srliw	a1,s1,0xa
    80003d1a:	855a                	mv	a0,s6
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	8a2080e7          	jalr	-1886(ra) # 800035be <bmap>
    80003d24:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d28:	cd85                	beqz	a1,80003d60 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d2a:	000b2503          	lw	a0,0(s6)
    80003d2e:	fffff097          	auipc	ra,0xfffff
    80003d32:	496080e7          	jalr	1174(ra) # 800031c4 <bread>
    80003d36:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d38:	3ff4f613          	andi	a2,s1,1023
    80003d3c:	40cc87bb          	subw	a5,s9,a2
    80003d40:	413a873b          	subw	a4,s5,s3
    80003d44:	8d3e                	mv	s10,a5
    80003d46:	2781                	sext.w	a5,a5
    80003d48:	0007069b          	sext.w	a3,a4
    80003d4c:	f8f6f9e3          	bgeu	a3,a5,80003cde <readi+0x4c>
    80003d50:	8d3a                	mv	s10,a4
    80003d52:	b771                	j	80003cde <readi+0x4c>
      brelse(bp);
    80003d54:	854a                	mv	a0,s2
    80003d56:	fffff097          	auipc	ra,0xfffff
    80003d5a:	59e080e7          	jalr	1438(ra) # 800032f4 <brelse>
      tot = -1;
    80003d5e:	59fd                	li	s3,-1
  }
  return tot;
    80003d60:	0009851b          	sext.w	a0,s3
}
    80003d64:	70a6                	ld	ra,104(sp)
    80003d66:	7406                	ld	s0,96(sp)
    80003d68:	64e6                	ld	s1,88(sp)
    80003d6a:	6946                	ld	s2,80(sp)
    80003d6c:	69a6                	ld	s3,72(sp)
    80003d6e:	6a06                	ld	s4,64(sp)
    80003d70:	7ae2                	ld	s5,56(sp)
    80003d72:	7b42                	ld	s6,48(sp)
    80003d74:	7ba2                	ld	s7,40(sp)
    80003d76:	7c02                	ld	s8,32(sp)
    80003d78:	6ce2                	ld	s9,24(sp)
    80003d7a:	6d42                	ld	s10,16(sp)
    80003d7c:	6da2                	ld	s11,8(sp)
    80003d7e:	6165                	addi	sp,sp,112
    80003d80:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d82:	89d6                	mv	s3,s5
    80003d84:	bff1                	j	80003d60 <readi+0xce>
    return 0;
    80003d86:	4501                	li	a0,0
}
    80003d88:	8082                	ret

0000000080003d8a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d8a:	457c                	lw	a5,76(a0)
    80003d8c:	10d7e863          	bltu	a5,a3,80003e9c <writei+0x112>
{
    80003d90:	7159                	addi	sp,sp,-112
    80003d92:	f486                	sd	ra,104(sp)
    80003d94:	f0a2                	sd	s0,96(sp)
    80003d96:	eca6                	sd	s1,88(sp)
    80003d98:	e8ca                	sd	s2,80(sp)
    80003d9a:	e4ce                	sd	s3,72(sp)
    80003d9c:	e0d2                	sd	s4,64(sp)
    80003d9e:	fc56                	sd	s5,56(sp)
    80003da0:	f85a                	sd	s6,48(sp)
    80003da2:	f45e                	sd	s7,40(sp)
    80003da4:	f062                	sd	s8,32(sp)
    80003da6:	ec66                	sd	s9,24(sp)
    80003da8:	e86a                	sd	s10,16(sp)
    80003daa:	e46e                	sd	s11,8(sp)
    80003dac:	1880                	addi	s0,sp,112
    80003dae:	8aaa                	mv	s5,a0
    80003db0:	8bae                	mv	s7,a1
    80003db2:	8a32                	mv	s4,a2
    80003db4:	8936                	mv	s2,a3
    80003db6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003db8:	00e687bb          	addw	a5,a3,a4
    80003dbc:	0ed7e263          	bltu	a5,a3,80003ea0 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dc0:	00043737          	lui	a4,0x43
    80003dc4:	0ef76063          	bltu	a4,a5,80003ea4 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dc8:	0c0b0863          	beqz	s6,80003e98 <writei+0x10e>
    80003dcc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dce:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dd2:	5c7d                	li	s8,-1
    80003dd4:	a091                	j	80003e18 <writei+0x8e>
    80003dd6:	020d1d93          	slli	s11,s10,0x20
    80003dda:	020ddd93          	srli	s11,s11,0x20
    80003dde:	05848793          	addi	a5,s1,88
    80003de2:	86ee                	mv	a3,s11
    80003de4:	8652                	mv	a2,s4
    80003de6:	85de                	mv	a1,s7
    80003de8:	953e                	add	a0,a0,a5
    80003dea:	fffff097          	auipc	ra,0xfffff
    80003dee:	82e080e7          	jalr	-2002(ra) # 80002618 <either_copyin>
    80003df2:	07850263          	beq	a0,s8,80003e56 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003df6:	8526                	mv	a0,s1
    80003df8:	00000097          	auipc	ra,0x0
    80003dfc:	780080e7          	jalr	1920(ra) # 80004578 <log_write>
    brelse(bp);
    80003e00:	8526                	mv	a0,s1
    80003e02:	fffff097          	auipc	ra,0xfffff
    80003e06:	4f2080e7          	jalr	1266(ra) # 800032f4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e0a:	013d09bb          	addw	s3,s10,s3
    80003e0e:	012d093b          	addw	s2,s10,s2
    80003e12:	9a6e                	add	s4,s4,s11
    80003e14:	0569f663          	bgeu	s3,s6,80003e60 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003e18:	00a9559b          	srliw	a1,s2,0xa
    80003e1c:	8556                	mv	a0,s5
    80003e1e:	fffff097          	auipc	ra,0xfffff
    80003e22:	7a0080e7          	jalr	1952(ra) # 800035be <bmap>
    80003e26:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e2a:	c99d                	beqz	a1,80003e60 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e2c:	000aa503          	lw	a0,0(s5)
    80003e30:	fffff097          	auipc	ra,0xfffff
    80003e34:	394080e7          	jalr	916(ra) # 800031c4 <bread>
    80003e38:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e3a:	3ff97513          	andi	a0,s2,1023
    80003e3e:	40ac87bb          	subw	a5,s9,a0
    80003e42:	413b073b          	subw	a4,s6,s3
    80003e46:	8d3e                	mv	s10,a5
    80003e48:	2781                	sext.w	a5,a5
    80003e4a:	0007069b          	sext.w	a3,a4
    80003e4e:	f8f6f4e3          	bgeu	a3,a5,80003dd6 <writei+0x4c>
    80003e52:	8d3a                	mv	s10,a4
    80003e54:	b749                	j	80003dd6 <writei+0x4c>
      brelse(bp);
    80003e56:	8526                	mv	a0,s1
    80003e58:	fffff097          	auipc	ra,0xfffff
    80003e5c:	49c080e7          	jalr	1180(ra) # 800032f4 <brelse>
  }

  if(off > ip->size)
    80003e60:	04caa783          	lw	a5,76(s5)
    80003e64:	0127f463          	bgeu	a5,s2,80003e6c <writei+0xe2>
    ip->size = off;
    80003e68:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e6c:	8556                	mv	a0,s5
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	aa6080e7          	jalr	-1370(ra) # 80003914 <iupdate>

  return tot;
    80003e76:	0009851b          	sext.w	a0,s3
}
    80003e7a:	70a6                	ld	ra,104(sp)
    80003e7c:	7406                	ld	s0,96(sp)
    80003e7e:	64e6                	ld	s1,88(sp)
    80003e80:	6946                	ld	s2,80(sp)
    80003e82:	69a6                	ld	s3,72(sp)
    80003e84:	6a06                	ld	s4,64(sp)
    80003e86:	7ae2                	ld	s5,56(sp)
    80003e88:	7b42                	ld	s6,48(sp)
    80003e8a:	7ba2                	ld	s7,40(sp)
    80003e8c:	7c02                	ld	s8,32(sp)
    80003e8e:	6ce2                	ld	s9,24(sp)
    80003e90:	6d42                	ld	s10,16(sp)
    80003e92:	6da2                	ld	s11,8(sp)
    80003e94:	6165                	addi	sp,sp,112
    80003e96:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e98:	89da                	mv	s3,s6
    80003e9a:	bfc9                	j	80003e6c <writei+0xe2>
    return -1;
    80003e9c:	557d                	li	a0,-1
}
    80003e9e:	8082                	ret
    return -1;
    80003ea0:	557d                	li	a0,-1
    80003ea2:	bfe1                	j	80003e7a <writei+0xf0>
    return -1;
    80003ea4:	557d                	li	a0,-1
    80003ea6:	bfd1                	j	80003e7a <writei+0xf0>

0000000080003ea8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ea8:	1141                	addi	sp,sp,-16
    80003eaa:	e406                	sd	ra,8(sp)
    80003eac:	e022                	sd	s0,0(sp)
    80003eae:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003eb0:	4639                	li	a2,14
    80003eb2:	ffffd097          	auipc	ra,0xffffd
    80003eb6:	ef0080e7          	jalr	-272(ra) # 80000da2 <strncmp>
}
    80003eba:	60a2                	ld	ra,8(sp)
    80003ebc:	6402                	ld	s0,0(sp)
    80003ebe:	0141                	addi	sp,sp,16
    80003ec0:	8082                	ret

0000000080003ec2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ec2:	7139                	addi	sp,sp,-64
    80003ec4:	fc06                	sd	ra,56(sp)
    80003ec6:	f822                	sd	s0,48(sp)
    80003ec8:	f426                	sd	s1,40(sp)
    80003eca:	f04a                	sd	s2,32(sp)
    80003ecc:	ec4e                	sd	s3,24(sp)
    80003ece:	e852                	sd	s4,16(sp)
    80003ed0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ed2:	04451703          	lh	a4,68(a0)
    80003ed6:	4785                	li	a5,1
    80003ed8:	00f71a63          	bne	a4,a5,80003eec <dirlookup+0x2a>
    80003edc:	892a                	mv	s2,a0
    80003ede:	89ae                	mv	s3,a1
    80003ee0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee2:	457c                	lw	a5,76(a0)
    80003ee4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ee6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee8:	e79d                	bnez	a5,80003f16 <dirlookup+0x54>
    80003eea:	a8a5                	j	80003f62 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003eec:	00004517          	auipc	a0,0x4
    80003ef0:	79c50513          	addi	a0,a0,1948 # 80008688 <syscalls+0x1a0>
    80003ef4:	ffffc097          	auipc	ra,0xffffc
    80003ef8:	64a080e7          	jalr	1610(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003efc:	00004517          	auipc	a0,0x4
    80003f00:	7a450513          	addi	a0,a0,1956 # 800086a0 <syscalls+0x1b8>
    80003f04:	ffffc097          	auipc	ra,0xffffc
    80003f08:	63a080e7          	jalr	1594(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f0c:	24c1                	addiw	s1,s1,16
    80003f0e:	04c92783          	lw	a5,76(s2)
    80003f12:	04f4f763          	bgeu	s1,a5,80003f60 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f16:	4741                	li	a4,16
    80003f18:	86a6                	mv	a3,s1
    80003f1a:	fc040613          	addi	a2,s0,-64
    80003f1e:	4581                	li	a1,0
    80003f20:	854a                	mv	a0,s2
    80003f22:	00000097          	auipc	ra,0x0
    80003f26:	d70080e7          	jalr	-656(ra) # 80003c92 <readi>
    80003f2a:	47c1                	li	a5,16
    80003f2c:	fcf518e3          	bne	a0,a5,80003efc <dirlookup+0x3a>
    if(de.inum == 0)
    80003f30:	fc045783          	lhu	a5,-64(s0)
    80003f34:	dfe1                	beqz	a5,80003f0c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f36:	fc240593          	addi	a1,s0,-62
    80003f3a:	854e                	mv	a0,s3
    80003f3c:	00000097          	auipc	ra,0x0
    80003f40:	f6c080e7          	jalr	-148(ra) # 80003ea8 <namecmp>
    80003f44:	f561                	bnez	a0,80003f0c <dirlookup+0x4a>
      if(poff)
    80003f46:	000a0463          	beqz	s4,80003f4e <dirlookup+0x8c>
        *poff = off;
    80003f4a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f4e:	fc045583          	lhu	a1,-64(s0)
    80003f52:	00092503          	lw	a0,0(s2)
    80003f56:	fffff097          	auipc	ra,0xfffff
    80003f5a:	750080e7          	jalr	1872(ra) # 800036a6 <iget>
    80003f5e:	a011                	j	80003f62 <dirlookup+0xa0>
  return 0;
    80003f60:	4501                	li	a0,0
}
    80003f62:	70e2                	ld	ra,56(sp)
    80003f64:	7442                	ld	s0,48(sp)
    80003f66:	74a2                	ld	s1,40(sp)
    80003f68:	7902                	ld	s2,32(sp)
    80003f6a:	69e2                	ld	s3,24(sp)
    80003f6c:	6a42                	ld	s4,16(sp)
    80003f6e:	6121                	addi	sp,sp,64
    80003f70:	8082                	ret

0000000080003f72 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f72:	711d                	addi	sp,sp,-96
    80003f74:	ec86                	sd	ra,88(sp)
    80003f76:	e8a2                	sd	s0,80(sp)
    80003f78:	e4a6                	sd	s1,72(sp)
    80003f7a:	e0ca                	sd	s2,64(sp)
    80003f7c:	fc4e                	sd	s3,56(sp)
    80003f7e:	f852                	sd	s4,48(sp)
    80003f80:	f456                	sd	s5,40(sp)
    80003f82:	f05a                	sd	s6,32(sp)
    80003f84:	ec5e                	sd	s7,24(sp)
    80003f86:	e862                	sd	s8,16(sp)
    80003f88:	e466                	sd	s9,8(sp)
    80003f8a:	1080                	addi	s0,sp,96
    80003f8c:	84aa                	mv	s1,a0
    80003f8e:	8aae                	mv	s5,a1
    80003f90:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f92:	00054703          	lbu	a4,0(a0)
    80003f96:	02f00793          	li	a5,47
    80003f9a:	02f70363          	beq	a4,a5,80003fc0 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f9e:	ffffe097          	auipc	ra,0xffffe
    80003fa2:	9e2080e7          	jalr	-1566(ra) # 80001980 <myproc>
    80003fa6:	18853503          	ld	a0,392(a0)
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	9f6080e7          	jalr	-1546(ra) # 800039a0 <idup>
    80003fb2:	89aa                	mv	s3,a0
  while(*path == '/')
    80003fb4:	02f00913          	li	s2,47
  len = path - s;
    80003fb8:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003fba:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fbc:	4b85                	li	s7,1
    80003fbe:	a865                	j	80004076 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fc0:	4585                	li	a1,1
    80003fc2:	4505                	li	a0,1
    80003fc4:	fffff097          	auipc	ra,0xfffff
    80003fc8:	6e2080e7          	jalr	1762(ra) # 800036a6 <iget>
    80003fcc:	89aa                	mv	s3,a0
    80003fce:	b7dd                	j	80003fb4 <namex+0x42>
      iunlockput(ip);
    80003fd0:	854e                	mv	a0,s3
    80003fd2:	00000097          	auipc	ra,0x0
    80003fd6:	c6e080e7          	jalr	-914(ra) # 80003c40 <iunlockput>
      return 0;
    80003fda:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fdc:	854e                	mv	a0,s3
    80003fde:	60e6                	ld	ra,88(sp)
    80003fe0:	6446                	ld	s0,80(sp)
    80003fe2:	64a6                	ld	s1,72(sp)
    80003fe4:	6906                	ld	s2,64(sp)
    80003fe6:	79e2                	ld	s3,56(sp)
    80003fe8:	7a42                	ld	s4,48(sp)
    80003fea:	7aa2                	ld	s5,40(sp)
    80003fec:	7b02                	ld	s6,32(sp)
    80003fee:	6be2                	ld	s7,24(sp)
    80003ff0:	6c42                	ld	s8,16(sp)
    80003ff2:	6ca2                	ld	s9,8(sp)
    80003ff4:	6125                	addi	sp,sp,96
    80003ff6:	8082                	ret
      iunlock(ip);
    80003ff8:	854e                	mv	a0,s3
    80003ffa:	00000097          	auipc	ra,0x0
    80003ffe:	aa6080e7          	jalr	-1370(ra) # 80003aa0 <iunlock>
      return ip;
    80004002:	bfe9                	j	80003fdc <namex+0x6a>
      iunlockput(ip);
    80004004:	854e                	mv	a0,s3
    80004006:	00000097          	auipc	ra,0x0
    8000400a:	c3a080e7          	jalr	-966(ra) # 80003c40 <iunlockput>
      return 0;
    8000400e:	89e6                	mv	s3,s9
    80004010:	b7f1                	j	80003fdc <namex+0x6a>
  len = path - s;
    80004012:	40b48633          	sub	a2,s1,a1
    80004016:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000401a:	099c5463          	bge	s8,s9,800040a2 <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000401e:	4639                	li	a2,14
    80004020:	8552                	mv	a0,s4
    80004022:	ffffd097          	auipc	ra,0xffffd
    80004026:	d0c080e7          	jalr	-756(ra) # 80000d2e <memmove>
  while(*path == '/')
    8000402a:	0004c783          	lbu	a5,0(s1)
    8000402e:	01279763          	bne	a5,s2,8000403c <namex+0xca>
    path++;
    80004032:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004034:	0004c783          	lbu	a5,0(s1)
    80004038:	ff278de3          	beq	a5,s2,80004032 <namex+0xc0>
    ilock(ip);
    8000403c:	854e                	mv	a0,s3
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	9a0080e7          	jalr	-1632(ra) # 800039de <ilock>
    if(ip->type != T_DIR){
    80004046:	04499783          	lh	a5,68(s3)
    8000404a:	f97793e3          	bne	a5,s7,80003fd0 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000404e:	000a8563          	beqz	s5,80004058 <namex+0xe6>
    80004052:	0004c783          	lbu	a5,0(s1)
    80004056:	d3cd                	beqz	a5,80003ff8 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004058:	865a                	mv	a2,s6
    8000405a:	85d2                	mv	a1,s4
    8000405c:	854e                	mv	a0,s3
    8000405e:	00000097          	auipc	ra,0x0
    80004062:	e64080e7          	jalr	-412(ra) # 80003ec2 <dirlookup>
    80004066:	8caa                	mv	s9,a0
    80004068:	dd51                	beqz	a0,80004004 <namex+0x92>
    iunlockput(ip);
    8000406a:	854e                	mv	a0,s3
    8000406c:	00000097          	auipc	ra,0x0
    80004070:	bd4080e7          	jalr	-1068(ra) # 80003c40 <iunlockput>
    ip = next;
    80004074:	89e6                	mv	s3,s9
  while(*path == '/')
    80004076:	0004c783          	lbu	a5,0(s1)
    8000407a:	05279763          	bne	a5,s2,800040c8 <namex+0x156>
    path++;
    8000407e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004080:	0004c783          	lbu	a5,0(s1)
    80004084:	ff278de3          	beq	a5,s2,8000407e <namex+0x10c>
  if(*path == 0)
    80004088:	c79d                	beqz	a5,800040b6 <namex+0x144>
    path++;
    8000408a:	85a6                	mv	a1,s1
  len = path - s;
    8000408c:	8cda                	mv	s9,s6
    8000408e:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004090:	01278963          	beq	a5,s2,800040a2 <namex+0x130>
    80004094:	dfbd                	beqz	a5,80004012 <namex+0xa0>
    path++;
    80004096:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004098:	0004c783          	lbu	a5,0(s1)
    8000409c:	ff279ce3          	bne	a5,s2,80004094 <namex+0x122>
    800040a0:	bf8d                	j	80004012 <namex+0xa0>
    memmove(name, s, len);
    800040a2:	2601                	sext.w	a2,a2
    800040a4:	8552                	mv	a0,s4
    800040a6:	ffffd097          	auipc	ra,0xffffd
    800040aa:	c88080e7          	jalr	-888(ra) # 80000d2e <memmove>
    name[len] = 0;
    800040ae:	9cd2                	add	s9,s9,s4
    800040b0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800040b4:	bf9d                	j	8000402a <namex+0xb8>
  if(nameiparent){
    800040b6:	f20a83e3          	beqz	s5,80003fdc <namex+0x6a>
    iput(ip);
    800040ba:	854e                	mv	a0,s3
    800040bc:	00000097          	auipc	ra,0x0
    800040c0:	adc080e7          	jalr	-1316(ra) # 80003b98 <iput>
    return 0;
    800040c4:	4981                	li	s3,0
    800040c6:	bf19                	j	80003fdc <namex+0x6a>
  if(*path == 0)
    800040c8:	d7fd                	beqz	a5,800040b6 <namex+0x144>
  while(*path != '/' && *path != 0)
    800040ca:	0004c783          	lbu	a5,0(s1)
    800040ce:	85a6                	mv	a1,s1
    800040d0:	b7d1                	j	80004094 <namex+0x122>

00000000800040d2 <dirlink>:
{
    800040d2:	7139                	addi	sp,sp,-64
    800040d4:	fc06                	sd	ra,56(sp)
    800040d6:	f822                	sd	s0,48(sp)
    800040d8:	f426                	sd	s1,40(sp)
    800040da:	f04a                	sd	s2,32(sp)
    800040dc:	ec4e                	sd	s3,24(sp)
    800040de:	e852                	sd	s4,16(sp)
    800040e0:	0080                	addi	s0,sp,64
    800040e2:	892a                	mv	s2,a0
    800040e4:	8a2e                	mv	s4,a1
    800040e6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040e8:	4601                	li	a2,0
    800040ea:	00000097          	auipc	ra,0x0
    800040ee:	dd8080e7          	jalr	-552(ra) # 80003ec2 <dirlookup>
    800040f2:	e93d                	bnez	a0,80004168 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040f4:	04c92483          	lw	s1,76(s2)
    800040f8:	c49d                	beqz	s1,80004126 <dirlink+0x54>
    800040fa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040fc:	4741                	li	a4,16
    800040fe:	86a6                	mv	a3,s1
    80004100:	fc040613          	addi	a2,s0,-64
    80004104:	4581                	li	a1,0
    80004106:	854a                	mv	a0,s2
    80004108:	00000097          	auipc	ra,0x0
    8000410c:	b8a080e7          	jalr	-1142(ra) # 80003c92 <readi>
    80004110:	47c1                	li	a5,16
    80004112:	06f51163          	bne	a0,a5,80004174 <dirlink+0xa2>
    if(de.inum == 0)
    80004116:	fc045783          	lhu	a5,-64(s0)
    8000411a:	c791                	beqz	a5,80004126 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000411c:	24c1                	addiw	s1,s1,16
    8000411e:	04c92783          	lw	a5,76(s2)
    80004122:	fcf4ede3          	bltu	s1,a5,800040fc <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004126:	4639                	li	a2,14
    80004128:	85d2                	mv	a1,s4
    8000412a:	fc240513          	addi	a0,s0,-62
    8000412e:	ffffd097          	auipc	ra,0xffffd
    80004132:	cb0080e7          	jalr	-848(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004136:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000413a:	4741                	li	a4,16
    8000413c:	86a6                	mv	a3,s1
    8000413e:	fc040613          	addi	a2,s0,-64
    80004142:	4581                	li	a1,0
    80004144:	854a                	mv	a0,s2
    80004146:	00000097          	auipc	ra,0x0
    8000414a:	c44080e7          	jalr	-956(ra) # 80003d8a <writei>
    8000414e:	1541                	addi	a0,a0,-16
    80004150:	00a03533          	snez	a0,a0
    80004154:	40a00533          	neg	a0,a0
}
    80004158:	70e2                	ld	ra,56(sp)
    8000415a:	7442                	ld	s0,48(sp)
    8000415c:	74a2                	ld	s1,40(sp)
    8000415e:	7902                	ld	s2,32(sp)
    80004160:	69e2                	ld	s3,24(sp)
    80004162:	6a42                	ld	s4,16(sp)
    80004164:	6121                	addi	sp,sp,64
    80004166:	8082                	ret
    iput(ip);
    80004168:	00000097          	auipc	ra,0x0
    8000416c:	a30080e7          	jalr	-1488(ra) # 80003b98 <iput>
    return -1;
    80004170:	557d                	li	a0,-1
    80004172:	b7dd                	j	80004158 <dirlink+0x86>
      panic("dirlink read");
    80004174:	00004517          	auipc	a0,0x4
    80004178:	53c50513          	addi	a0,a0,1340 # 800086b0 <syscalls+0x1c8>
    8000417c:	ffffc097          	auipc	ra,0xffffc
    80004180:	3c2080e7          	jalr	962(ra) # 8000053e <panic>

0000000080004184 <namei>:

struct inode*
namei(char *path)
{
    80004184:	1101                	addi	sp,sp,-32
    80004186:	ec06                	sd	ra,24(sp)
    80004188:	e822                	sd	s0,16(sp)
    8000418a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000418c:	fe040613          	addi	a2,s0,-32
    80004190:	4581                	li	a1,0
    80004192:	00000097          	auipc	ra,0x0
    80004196:	de0080e7          	jalr	-544(ra) # 80003f72 <namex>
}
    8000419a:	60e2                	ld	ra,24(sp)
    8000419c:	6442                	ld	s0,16(sp)
    8000419e:	6105                	addi	sp,sp,32
    800041a0:	8082                	ret

00000000800041a2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041a2:	1141                	addi	sp,sp,-16
    800041a4:	e406                	sd	ra,8(sp)
    800041a6:	e022                	sd	s0,0(sp)
    800041a8:	0800                	addi	s0,sp,16
    800041aa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041ac:	4585                	li	a1,1
    800041ae:	00000097          	auipc	ra,0x0
    800041b2:	dc4080e7          	jalr	-572(ra) # 80003f72 <namex>
}
    800041b6:	60a2                	ld	ra,8(sp)
    800041b8:	6402                	ld	s0,0(sp)
    800041ba:	0141                	addi	sp,sp,16
    800041bc:	8082                	ret

00000000800041be <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041be:	1101                	addi	sp,sp,-32
    800041c0:	ec06                	sd	ra,24(sp)
    800041c2:	e822                	sd	s0,16(sp)
    800041c4:	e426                	sd	s1,8(sp)
    800041c6:	e04a                	sd	s2,0(sp)
    800041c8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041ca:	0001e917          	auipc	s2,0x1e
    800041ce:	ff690913          	addi	s2,s2,-10 # 800221c0 <log>
    800041d2:	01892583          	lw	a1,24(s2)
    800041d6:	02892503          	lw	a0,40(s2)
    800041da:	fffff097          	auipc	ra,0xfffff
    800041de:	fea080e7          	jalr	-22(ra) # 800031c4 <bread>
    800041e2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041e4:	02c92683          	lw	a3,44(s2)
    800041e8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041ea:	02d05763          	blez	a3,80004218 <write_head+0x5a>
    800041ee:	0001e797          	auipc	a5,0x1e
    800041f2:	00278793          	addi	a5,a5,2 # 800221f0 <log+0x30>
    800041f6:	05c50713          	addi	a4,a0,92
    800041fa:	36fd                	addiw	a3,a3,-1
    800041fc:	1682                	slli	a3,a3,0x20
    800041fe:	9281                	srli	a3,a3,0x20
    80004200:	068a                	slli	a3,a3,0x2
    80004202:	0001e617          	auipc	a2,0x1e
    80004206:	ff260613          	addi	a2,a2,-14 # 800221f4 <log+0x34>
    8000420a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000420c:	4390                	lw	a2,0(a5)
    8000420e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004210:	0791                	addi	a5,a5,4
    80004212:	0711                	addi	a4,a4,4
    80004214:	fed79ce3          	bne	a5,a3,8000420c <write_head+0x4e>
  }
  bwrite(buf);
    80004218:	8526                	mv	a0,s1
    8000421a:	fffff097          	auipc	ra,0xfffff
    8000421e:	09c080e7          	jalr	156(ra) # 800032b6 <bwrite>
  brelse(buf);
    80004222:	8526                	mv	a0,s1
    80004224:	fffff097          	auipc	ra,0xfffff
    80004228:	0d0080e7          	jalr	208(ra) # 800032f4 <brelse>
}
    8000422c:	60e2                	ld	ra,24(sp)
    8000422e:	6442                	ld	s0,16(sp)
    80004230:	64a2                	ld	s1,8(sp)
    80004232:	6902                	ld	s2,0(sp)
    80004234:	6105                	addi	sp,sp,32
    80004236:	8082                	ret

0000000080004238 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004238:	0001e797          	auipc	a5,0x1e
    8000423c:	fb47a783          	lw	a5,-76(a5) # 800221ec <log+0x2c>
    80004240:	0af05d63          	blez	a5,800042fa <install_trans+0xc2>
{
    80004244:	7139                	addi	sp,sp,-64
    80004246:	fc06                	sd	ra,56(sp)
    80004248:	f822                	sd	s0,48(sp)
    8000424a:	f426                	sd	s1,40(sp)
    8000424c:	f04a                	sd	s2,32(sp)
    8000424e:	ec4e                	sd	s3,24(sp)
    80004250:	e852                	sd	s4,16(sp)
    80004252:	e456                	sd	s5,8(sp)
    80004254:	e05a                	sd	s6,0(sp)
    80004256:	0080                	addi	s0,sp,64
    80004258:	8b2a                	mv	s6,a0
    8000425a:	0001ea97          	auipc	s5,0x1e
    8000425e:	f96a8a93          	addi	s5,s5,-106 # 800221f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004262:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004264:	0001e997          	auipc	s3,0x1e
    80004268:	f5c98993          	addi	s3,s3,-164 # 800221c0 <log>
    8000426c:	a00d                	j	8000428e <install_trans+0x56>
    brelse(lbuf);
    8000426e:	854a                	mv	a0,s2
    80004270:	fffff097          	auipc	ra,0xfffff
    80004274:	084080e7          	jalr	132(ra) # 800032f4 <brelse>
    brelse(dbuf);
    80004278:	8526                	mv	a0,s1
    8000427a:	fffff097          	auipc	ra,0xfffff
    8000427e:	07a080e7          	jalr	122(ra) # 800032f4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004282:	2a05                	addiw	s4,s4,1
    80004284:	0a91                	addi	s5,s5,4
    80004286:	02c9a783          	lw	a5,44(s3)
    8000428a:	04fa5e63          	bge	s4,a5,800042e6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000428e:	0189a583          	lw	a1,24(s3)
    80004292:	014585bb          	addw	a1,a1,s4
    80004296:	2585                	addiw	a1,a1,1
    80004298:	0289a503          	lw	a0,40(s3)
    8000429c:	fffff097          	auipc	ra,0xfffff
    800042a0:	f28080e7          	jalr	-216(ra) # 800031c4 <bread>
    800042a4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042a6:	000aa583          	lw	a1,0(s5)
    800042aa:	0289a503          	lw	a0,40(s3)
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	f16080e7          	jalr	-234(ra) # 800031c4 <bread>
    800042b6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042b8:	40000613          	li	a2,1024
    800042bc:	05890593          	addi	a1,s2,88
    800042c0:	05850513          	addi	a0,a0,88
    800042c4:	ffffd097          	auipc	ra,0xffffd
    800042c8:	a6a080e7          	jalr	-1430(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800042cc:	8526                	mv	a0,s1
    800042ce:	fffff097          	auipc	ra,0xfffff
    800042d2:	fe8080e7          	jalr	-24(ra) # 800032b6 <bwrite>
    if(recovering == 0)
    800042d6:	f80b1ce3          	bnez	s6,8000426e <install_trans+0x36>
      bunpin(dbuf);
    800042da:	8526                	mv	a0,s1
    800042dc:	fffff097          	auipc	ra,0xfffff
    800042e0:	0f2080e7          	jalr	242(ra) # 800033ce <bunpin>
    800042e4:	b769                	j	8000426e <install_trans+0x36>
}
    800042e6:	70e2                	ld	ra,56(sp)
    800042e8:	7442                	ld	s0,48(sp)
    800042ea:	74a2                	ld	s1,40(sp)
    800042ec:	7902                	ld	s2,32(sp)
    800042ee:	69e2                	ld	s3,24(sp)
    800042f0:	6a42                	ld	s4,16(sp)
    800042f2:	6aa2                	ld	s5,8(sp)
    800042f4:	6b02                	ld	s6,0(sp)
    800042f6:	6121                	addi	sp,sp,64
    800042f8:	8082                	ret
    800042fa:	8082                	ret

00000000800042fc <initlog>:
{
    800042fc:	7179                	addi	sp,sp,-48
    800042fe:	f406                	sd	ra,40(sp)
    80004300:	f022                	sd	s0,32(sp)
    80004302:	ec26                	sd	s1,24(sp)
    80004304:	e84a                	sd	s2,16(sp)
    80004306:	e44e                	sd	s3,8(sp)
    80004308:	1800                	addi	s0,sp,48
    8000430a:	892a                	mv	s2,a0
    8000430c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000430e:	0001e497          	auipc	s1,0x1e
    80004312:	eb248493          	addi	s1,s1,-334 # 800221c0 <log>
    80004316:	00004597          	auipc	a1,0x4
    8000431a:	3aa58593          	addi	a1,a1,938 # 800086c0 <syscalls+0x1d8>
    8000431e:	8526                	mv	a0,s1
    80004320:	ffffd097          	auipc	ra,0xffffd
    80004324:	826080e7          	jalr	-2010(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004328:	0149a583          	lw	a1,20(s3)
    8000432c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000432e:	0109a783          	lw	a5,16(s3)
    80004332:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004334:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004338:	854a                	mv	a0,s2
    8000433a:	fffff097          	auipc	ra,0xfffff
    8000433e:	e8a080e7          	jalr	-374(ra) # 800031c4 <bread>
  log.lh.n = lh->n;
    80004342:	4d34                	lw	a3,88(a0)
    80004344:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004346:	02d05563          	blez	a3,80004370 <initlog+0x74>
    8000434a:	05c50793          	addi	a5,a0,92
    8000434e:	0001e717          	auipc	a4,0x1e
    80004352:	ea270713          	addi	a4,a4,-350 # 800221f0 <log+0x30>
    80004356:	36fd                	addiw	a3,a3,-1
    80004358:	1682                	slli	a3,a3,0x20
    8000435a:	9281                	srli	a3,a3,0x20
    8000435c:	068a                	slli	a3,a3,0x2
    8000435e:	06050613          	addi	a2,a0,96
    80004362:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004364:	4390                	lw	a2,0(a5)
    80004366:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004368:	0791                	addi	a5,a5,4
    8000436a:	0711                	addi	a4,a4,4
    8000436c:	fed79ce3          	bne	a5,a3,80004364 <initlog+0x68>
  brelse(buf);
    80004370:	fffff097          	auipc	ra,0xfffff
    80004374:	f84080e7          	jalr	-124(ra) # 800032f4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004378:	4505                	li	a0,1
    8000437a:	00000097          	auipc	ra,0x0
    8000437e:	ebe080e7          	jalr	-322(ra) # 80004238 <install_trans>
  log.lh.n = 0;
    80004382:	0001e797          	auipc	a5,0x1e
    80004386:	e607a523          	sw	zero,-406(a5) # 800221ec <log+0x2c>
  write_head(); // clear the log
    8000438a:	00000097          	auipc	ra,0x0
    8000438e:	e34080e7          	jalr	-460(ra) # 800041be <write_head>
}
    80004392:	70a2                	ld	ra,40(sp)
    80004394:	7402                	ld	s0,32(sp)
    80004396:	64e2                	ld	s1,24(sp)
    80004398:	6942                	ld	s2,16(sp)
    8000439a:	69a2                	ld	s3,8(sp)
    8000439c:	6145                	addi	sp,sp,48
    8000439e:	8082                	ret

00000000800043a0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043a0:	1101                	addi	sp,sp,-32
    800043a2:	ec06                	sd	ra,24(sp)
    800043a4:	e822                	sd	s0,16(sp)
    800043a6:	e426                	sd	s1,8(sp)
    800043a8:	e04a                	sd	s2,0(sp)
    800043aa:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043ac:	0001e517          	auipc	a0,0x1e
    800043b0:	e1450513          	addi	a0,a0,-492 # 800221c0 <log>
    800043b4:	ffffd097          	auipc	ra,0xffffd
    800043b8:	822080e7          	jalr	-2014(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800043bc:	0001e497          	auipc	s1,0x1e
    800043c0:	e0448493          	addi	s1,s1,-508 # 800221c0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043c4:	4979                	li	s2,30
    800043c6:	a039                	j	800043d4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800043c8:	85a6                	mv	a1,s1
    800043ca:	8526                	mv	a0,s1
    800043cc:	ffffe097          	auipc	ra,0xffffe
    800043d0:	d52080e7          	jalr	-686(ra) # 8000211e <sleep>
    if(log.committing){
    800043d4:	50dc                	lw	a5,36(s1)
    800043d6:	fbed                	bnez	a5,800043c8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043d8:	509c                	lw	a5,32(s1)
    800043da:	0017871b          	addiw	a4,a5,1
    800043de:	0007069b          	sext.w	a3,a4
    800043e2:	0027179b          	slliw	a5,a4,0x2
    800043e6:	9fb9                	addw	a5,a5,a4
    800043e8:	0017979b          	slliw	a5,a5,0x1
    800043ec:	54d8                	lw	a4,44(s1)
    800043ee:	9fb9                	addw	a5,a5,a4
    800043f0:	00f95963          	bge	s2,a5,80004402 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043f4:	85a6                	mv	a1,s1
    800043f6:	8526                	mv	a0,s1
    800043f8:	ffffe097          	auipc	ra,0xffffe
    800043fc:	d26080e7          	jalr	-730(ra) # 8000211e <sleep>
    80004400:	bfd1                	j	800043d4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004402:	0001e517          	auipc	a0,0x1e
    80004406:	dbe50513          	addi	a0,a0,-578 # 800221c0 <log>
    8000440a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000440c:	ffffd097          	auipc	ra,0xffffd
    80004410:	87e080e7          	jalr	-1922(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004414:	60e2                	ld	ra,24(sp)
    80004416:	6442                	ld	s0,16(sp)
    80004418:	64a2                	ld	s1,8(sp)
    8000441a:	6902                	ld	s2,0(sp)
    8000441c:	6105                	addi	sp,sp,32
    8000441e:	8082                	ret

0000000080004420 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004420:	7139                	addi	sp,sp,-64
    80004422:	fc06                	sd	ra,56(sp)
    80004424:	f822                	sd	s0,48(sp)
    80004426:	f426                	sd	s1,40(sp)
    80004428:	f04a                	sd	s2,32(sp)
    8000442a:	ec4e                	sd	s3,24(sp)
    8000442c:	e852                	sd	s4,16(sp)
    8000442e:	e456                	sd	s5,8(sp)
    80004430:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004432:	0001e497          	auipc	s1,0x1e
    80004436:	d8e48493          	addi	s1,s1,-626 # 800221c0 <log>
    8000443a:	8526                	mv	a0,s1
    8000443c:	ffffc097          	auipc	ra,0xffffc
    80004440:	79a080e7          	jalr	1946(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004444:	509c                	lw	a5,32(s1)
    80004446:	37fd                	addiw	a5,a5,-1
    80004448:	0007891b          	sext.w	s2,a5
    8000444c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000444e:	50dc                	lw	a5,36(s1)
    80004450:	e7b9                	bnez	a5,8000449e <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004452:	04091e63          	bnez	s2,800044ae <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004456:	0001e497          	auipc	s1,0x1e
    8000445a:	d6a48493          	addi	s1,s1,-662 # 800221c0 <log>
    8000445e:	4785                	li	a5,1
    80004460:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004462:	8526                	mv	a0,s1
    80004464:	ffffd097          	auipc	ra,0xffffd
    80004468:	826080e7          	jalr	-2010(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000446c:	54dc                	lw	a5,44(s1)
    8000446e:	06f04763          	bgtz	a5,800044dc <end_op+0xbc>
    acquire(&log.lock);
    80004472:	0001e497          	auipc	s1,0x1e
    80004476:	d4e48493          	addi	s1,s1,-690 # 800221c0 <log>
    8000447a:	8526                	mv	a0,s1
    8000447c:	ffffc097          	auipc	ra,0xffffc
    80004480:	75a080e7          	jalr	1882(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004484:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004488:	8526                	mv	a0,s1
    8000448a:	ffffe097          	auipc	ra,0xffffe
    8000448e:	d14080e7          	jalr	-748(ra) # 8000219e <wakeup>
    release(&log.lock);
    80004492:	8526                	mv	a0,s1
    80004494:	ffffc097          	auipc	ra,0xffffc
    80004498:	7f6080e7          	jalr	2038(ra) # 80000c8a <release>
}
    8000449c:	a03d                	j	800044ca <end_op+0xaa>
    panic("log.committing");
    8000449e:	00004517          	auipc	a0,0x4
    800044a2:	22a50513          	addi	a0,a0,554 # 800086c8 <syscalls+0x1e0>
    800044a6:	ffffc097          	auipc	ra,0xffffc
    800044aa:	098080e7          	jalr	152(ra) # 8000053e <panic>
    wakeup(&log);
    800044ae:	0001e497          	auipc	s1,0x1e
    800044b2:	d1248493          	addi	s1,s1,-750 # 800221c0 <log>
    800044b6:	8526                	mv	a0,s1
    800044b8:	ffffe097          	auipc	ra,0xffffe
    800044bc:	ce6080e7          	jalr	-794(ra) # 8000219e <wakeup>
  release(&log.lock);
    800044c0:	8526                	mv	a0,s1
    800044c2:	ffffc097          	auipc	ra,0xffffc
    800044c6:	7c8080e7          	jalr	1992(ra) # 80000c8a <release>
}
    800044ca:	70e2                	ld	ra,56(sp)
    800044cc:	7442                	ld	s0,48(sp)
    800044ce:	74a2                	ld	s1,40(sp)
    800044d0:	7902                	ld	s2,32(sp)
    800044d2:	69e2                	ld	s3,24(sp)
    800044d4:	6a42                	ld	s4,16(sp)
    800044d6:	6aa2                	ld	s5,8(sp)
    800044d8:	6121                	addi	sp,sp,64
    800044da:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800044dc:	0001ea97          	auipc	s5,0x1e
    800044e0:	d14a8a93          	addi	s5,s5,-748 # 800221f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044e4:	0001ea17          	auipc	s4,0x1e
    800044e8:	cdca0a13          	addi	s4,s4,-804 # 800221c0 <log>
    800044ec:	018a2583          	lw	a1,24(s4)
    800044f0:	012585bb          	addw	a1,a1,s2
    800044f4:	2585                	addiw	a1,a1,1
    800044f6:	028a2503          	lw	a0,40(s4)
    800044fa:	fffff097          	auipc	ra,0xfffff
    800044fe:	cca080e7          	jalr	-822(ra) # 800031c4 <bread>
    80004502:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004504:	000aa583          	lw	a1,0(s5)
    80004508:	028a2503          	lw	a0,40(s4)
    8000450c:	fffff097          	auipc	ra,0xfffff
    80004510:	cb8080e7          	jalr	-840(ra) # 800031c4 <bread>
    80004514:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004516:	40000613          	li	a2,1024
    8000451a:	05850593          	addi	a1,a0,88
    8000451e:	05848513          	addi	a0,s1,88
    80004522:	ffffd097          	auipc	ra,0xffffd
    80004526:	80c080e7          	jalr	-2036(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000452a:	8526                	mv	a0,s1
    8000452c:	fffff097          	auipc	ra,0xfffff
    80004530:	d8a080e7          	jalr	-630(ra) # 800032b6 <bwrite>
    brelse(from);
    80004534:	854e                	mv	a0,s3
    80004536:	fffff097          	auipc	ra,0xfffff
    8000453a:	dbe080e7          	jalr	-578(ra) # 800032f4 <brelse>
    brelse(to);
    8000453e:	8526                	mv	a0,s1
    80004540:	fffff097          	auipc	ra,0xfffff
    80004544:	db4080e7          	jalr	-588(ra) # 800032f4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004548:	2905                	addiw	s2,s2,1
    8000454a:	0a91                	addi	s5,s5,4
    8000454c:	02ca2783          	lw	a5,44(s4)
    80004550:	f8f94ee3          	blt	s2,a5,800044ec <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004554:	00000097          	auipc	ra,0x0
    80004558:	c6a080e7          	jalr	-918(ra) # 800041be <write_head>
    install_trans(0); // Now install writes to home locations
    8000455c:	4501                	li	a0,0
    8000455e:	00000097          	auipc	ra,0x0
    80004562:	cda080e7          	jalr	-806(ra) # 80004238 <install_trans>
    log.lh.n = 0;
    80004566:	0001e797          	auipc	a5,0x1e
    8000456a:	c807a323          	sw	zero,-890(a5) # 800221ec <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000456e:	00000097          	auipc	ra,0x0
    80004572:	c50080e7          	jalr	-944(ra) # 800041be <write_head>
    80004576:	bdf5                	j	80004472 <end_op+0x52>

0000000080004578 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004578:	1101                	addi	sp,sp,-32
    8000457a:	ec06                	sd	ra,24(sp)
    8000457c:	e822                	sd	s0,16(sp)
    8000457e:	e426                	sd	s1,8(sp)
    80004580:	e04a                	sd	s2,0(sp)
    80004582:	1000                	addi	s0,sp,32
    80004584:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004586:	0001e917          	auipc	s2,0x1e
    8000458a:	c3a90913          	addi	s2,s2,-966 # 800221c0 <log>
    8000458e:	854a                	mv	a0,s2
    80004590:	ffffc097          	auipc	ra,0xffffc
    80004594:	646080e7          	jalr	1606(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004598:	02c92603          	lw	a2,44(s2)
    8000459c:	47f5                	li	a5,29
    8000459e:	06c7c563          	blt	a5,a2,80004608 <log_write+0x90>
    800045a2:	0001e797          	auipc	a5,0x1e
    800045a6:	c3a7a783          	lw	a5,-966(a5) # 800221dc <log+0x1c>
    800045aa:	37fd                	addiw	a5,a5,-1
    800045ac:	04f65e63          	bge	a2,a5,80004608 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045b0:	0001e797          	auipc	a5,0x1e
    800045b4:	c307a783          	lw	a5,-976(a5) # 800221e0 <log+0x20>
    800045b8:	06f05063          	blez	a5,80004618 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045bc:	4781                	li	a5,0
    800045be:	06c05563          	blez	a2,80004628 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045c2:	44cc                	lw	a1,12(s1)
    800045c4:	0001e717          	auipc	a4,0x1e
    800045c8:	c2c70713          	addi	a4,a4,-980 # 800221f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800045cc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045ce:	4314                	lw	a3,0(a4)
    800045d0:	04b68c63          	beq	a3,a1,80004628 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800045d4:	2785                	addiw	a5,a5,1
    800045d6:	0711                	addi	a4,a4,4
    800045d8:	fef61be3          	bne	a2,a5,800045ce <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045dc:	0621                	addi	a2,a2,8
    800045de:	060a                	slli	a2,a2,0x2
    800045e0:	0001e797          	auipc	a5,0x1e
    800045e4:	be078793          	addi	a5,a5,-1056 # 800221c0 <log>
    800045e8:	963e                	add	a2,a2,a5
    800045ea:	44dc                	lw	a5,12(s1)
    800045ec:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045ee:	8526                	mv	a0,s1
    800045f0:	fffff097          	auipc	ra,0xfffff
    800045f4:	da2080e7          	jalr	-606(ra) # 80003392 <bpin>
    log.lh.n++;
    800045f8:	0001e717          	auipc	a4,0x1e
    800045fc:	bc870713          	addi	a4,a4,-1080 # 800221c0 <log>
    80004600:	575c                	lw	a5,44(a4)
    80004602:	2785                	addiw	a5,a5,1
    80004604:	d75c                	sw	a5,44(a4)
    80004606:	a835                	j	80004642 <log_write+0xca>
    panic("too big a transaction");
    80004608:	00004517          	auipc	a0,0x4
    8000460c:	0d050513          	addi	a0,a0,208 # 800086d8 <syscalls+0x1f0>
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	f2e080e7          	jalr	-210(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004618:	00004517          	auipc	a0,0x4
    8000461c:	0d850513          	addi	a0,a0,216 # 800086f0 <syscalls+0x208>
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	f1e080e7          	jalr	-226(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004628:	00878713          	addi	a4,a5,8
    8000462c:	00271693          	slli	a3,a4,0x2
    80004630:	0001e717          	auipc	a4,0x1e
    80004634:	b9070713          	addi	a4,a4,-1136 # 800221c0 <log>
    80004638:	9736                	add	a4,a4,a3
    8000463a:	44d4                	lw	a3,12(s1)
    8000463c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000463e:	faf608e3          	beq	a2,a5,800045ee <log_write+0x76>
  }
  release(&log.lock);
    80004642:	0001e517          	auipc	a0,0x1e
    80004646:	b7e50513          	addi	a0,a0,-1154 # 800221c0 <log>
    8000464a:	ffffc097          	auipc	ra,0xffffc
    8000464e:	640080e7          	jalr	1600(ra) # 80000c8a <release>
}
    80004652:	60e2                	ld	ra,24(sp)
    80004654:	6442                	ld	s0,16(sp)
    80004656:	64a2                	ld	s1,8(sp)
    80004658:	6902                	ld	s2,0(sp)
    8000465a:	6105                	addi	sp,sp,32
    8000465c:	8082                	ret

000000008000465e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000465e:	1101                	addi	sp,sp,-32
    80004660:	ec06                	sd	ra,24(sp)
    80004662:	e822                	sd	s0,16(sp)
    80004664:	e426                	sd	s1,8(sp)
    80004666:	e04a                	sd	s2,0(sp)
    80004668:	1000                	addi	s0,sp,32
    8000466a:	84aa                	mv	s1,a0
    8000466c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000466e:	00004597          	auipc	a1,0x4
    80004672:	0a258593          	addi	a1,a1,162 # 80008710 <syscalls+0x228>
    80004676:	0521                	addi	a0,a0,8
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	4ce080e7          	jalr	1230(ra) # 80000b46 <initlock>
  lk->name = name;
    80004680:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004684:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004688:	0204a423          	sw	zero,40(s1)
}
    8000468c:	60e2                	ld	ra,24(sp)
    8000468e:	6442                	ld	s0,16(sp)
    80004690:	64a2                	ld	s1,8(sp)
    80004692:	6902                	ld	s2,0(sp)
    80004694:	6105                	addi	sp,sp,32
    80004696:	8082                	ret

0000000080004698 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004698:	1101                	addi	sp,sp,-32
    8000469a:	ec06                	sd	ra,24(sp)
    8000469c:	e822                	sd	s0,16(sp)
    8000469e:	e426                	sd	s1,8(sp)
    800046a0:	e04a                	sd	s2,0(sp)
    800046a2:	1000                	addi	s0,sp,32
    800046a4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046a6:	00850913          	addi	s2,a0,8
    800046aa:	854a                	mv	a0,s2
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	52a080e7          	jalr	1322(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800046b4:	409c                	lw	a5,0(s1)
    800046b6:	cb89                	beqz	a5,800046c8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046b8:	85ca                	mv	a1,s2
    800046ba:	8526                	mv	a0,s1
    800046bc:	ffffe097          	auipc	ra,0xffffe
    800046c0:	a62080e7          	jalr	-1438(ra) # 8000211e <sleep>
  while (lk->locked) {
    800046c4:	409c                	lw	a5,0(s1)
    800046c6:	fbed                	bnez	a5,800046b8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046c8:	4785                	li	a5,1
    800046ca:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046cc:	ffffd097          	auipc	ra,0xffffd
    800046d0:	2b4080e7          	jalr	692(ra) # 80001980 <myproc>
    800046d4:	515c                	lw	a5,36(a0)
    800046d6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046d8:	854a                	mv	a0,s2
    800046da:	ffffc097          	auipc	ra,0xffffc
    800046de:	5b0080e7          	jalr	1456(ra) # 80000c8a <release>
}
    800046e2:	60e2                	ld	ra,24(sp)
    800046e4:	6442                	ld	s0,16(sp)
    800046e6:	64a2                	ld	s1,8(sp)
    800046e8:	6902                	ld	s2,0(sp)
    800046ea:	6105                	addi	sp,sp,32
    800046ec:	8082                	ret

00000000800046ee <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046ee:	1101                	addi	sp,sp,-32
    800046f0:	ec06                	sd	ra,24(sp)
    800046f2:	e822                	sd	s0,16(sp)
    800046f4:	e426                	sd	s1,8(sp)
    800046f6:	e04a                	sd	s2,0(sp)
    800046f8:	1000                	addi	s0,sp,32
    800046fa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046fc:	00850913          	addi	s2,a0,8
    80004700:	854a                	mv	a0,s2
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	4d4080e7          	jalr	1236(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000470a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000470e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004712:	8526                	mv	a0,s1
    80004714:	ffffe097          	auipc	ra,0xffffe
    80004718:	a8a080e7          	jalr	-1398(ra) # 8000219e <wakeup>
  release(&lk->lk);
    8000471c:	854a                	mv	a0,s2
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	56c080e7          	jalr	1388(ra) # 80000c8a <release>
}
    80004726:	60e2                	ld	ra,24(sp)
    80004728:	6442                	ld	s0,16(sp)
    8000472a:	64a2                	ld	s1,8(sp)
    8000472c:	6902                	ld	s2,0(sp)
    8000472e:	6105                	addi	sp,sp,32
    80004730:	8082                	ret

0000000080004732 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004732:	7179                	addi	sp,sp,-48
    80004734:	f406                	sd	ra,40(sp)
    80004736:	f022                	sd	s0,32(sp)
    80004738:	ec26                	sd	s1,24(sp)
    8000473a:	e84a                	sd	s2,16(sp)
    8000473c:	e44e                	sd	s3,8(sp)
    8000473e:	1800                	addi	s0,sp,48
    80004740:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004742:	00850913          	addi	s2,a0,8
    80004746:	854a                	mv	a0,s2
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	48e080e7          	jalr	1166(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004750:	409c                	lw	a5,0(s1)
    80004752:	ef99                	bnez	a5,80004770 <holdingsleep+0x3e>
    80004754:	4481                	li	s1,0
  release(&lk->lk);
    80004756:	854a                	mv	a0,s2
    80004758:	ffffc097          	auipc	ra,0xffffc
    8000475c:	532080e7          	jalr	1330(ra) # 80000c8a <release>
  return r;
}
    80004760:	8526                	mv	a0,s1
    80004762:	70a2                	ld	ra,40(sp)
    80004764:	7402                	ld	s0,32(sp)
    80004766:	64e2                	ld	s1,24(sp)
    80004768:	6942                	ld	s2,16(sp)
    8000476a:	69a2                	ld	s3,8(sp)
    8000476c:	6145                	addi	sp,sp,48
    8000476e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004770:	0284a983          	lw	s3,40(s1)
    80004774:	ffffd097          	auipc	ra,0xffffd
    80004778:	20c080e7          	jalr	524(ra) # 80001980 <myproc>
    8000477c:	5144                	lw	s1,36(a0)
    8000477e:	413484b3          	sub	s1,s1,s3
    80004782:	0014b493          	seqz	s1,s1
    80004786:	bfc1                	j	80004756 <holdingsleep+0x24>

0000000080004788 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004788:	1141                	addi	sp,sp,-16
    8000478a:	e406                	sd	ra,8(sp)
    8000478c:	e022                	sd	s0,0(sp)
    8000478e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004790:	00004597          	auipc	a1,0x4
    80004794:	f9058593          	addi	a1,a1,-112 # 80008720 <syscalls+0x238>
    80004798:	0001e517          	auipc	a0,0x1e
    8000479c:	b7050513          	addi	a0,a0,-1168 # 80022308 <ftable>
    800047a0:	ffffc097          	auipc	ra,0xffffc
    800047a4:	3a6080e7          	jalr	934(ra) # 80000b46 <initlock>
}
    800047a8:	60a2                	ld	ra,8(sp)
    800047aa:	6402                	ld	s0,0(sp)
    800047ac:	0141                	addi	sp,sp,16
    800047ae:	8082                	ret

00000000800047b0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047b0:	1101                	addi	sp,sp,-32
    800047b2:	ec06                	sd	ra,24(sp)
    800047b4:	e822                	sd	s0,16(sp)
    800047b6:	e426                	sd	s1,8(sp)
    800047b8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047ba:	0001e517          	auipc	a0,0x1e
    800047be:	b4e50513          	addi	a0,a0,-1202 # 80022308 <ftable>
    800047c2:	ffffc097          	auipc	ra,0xffffc
    800047c6:	414080e7          	jalr	1044(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047ca:	0001e497          	auipc	s1,0x1e
    800047ce:	b5648493          	addi	s1,s1,-1194 # 80022320 <ftable+0x18>
    800047d2:	0001f717          	auipc	a4,0x1f
    800047d6:	aee70713          	addi	a4,a4,-1298 # 800232c0 <disk>
    if(f->ref == 0){
    800047da:	40dc                	lw	a5,4(s1)
    800047dc:	cf99                	beqz	a5,800047fa <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047de:	02848493          	addi	s1,s1,40
    800047e2:	fee49ce3          	bne	s1,a4,800047da <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047e6:	0001e517          	auipc	a0,0x1e
    800047ea:	b2250513          	addi	a0,a0,-1246 # 80022308 <ftable>
    800047ee:	ffffc097          	auipc	ra,0xffffc
    800047f2:	49c080e7          	jalr	1180(ra) # 80000c8a <release>
  return 0;
    800047f6:	4481                	li	s1,0
    800047f8:	a819                	j	8000480e <filealloc+0x5e>
      f->ref = 1;
    800047fa:	4785                	li	a5,1
    800047fc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047fe:	0001e517          	auipc	a0,0x1e
    80004802:	b0a50513          	addi	a0,a0,-1270 # 80022308 <ftable>
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	484080e7          	jalr	1156(ra) # 80000c8a <release>
}
    8000480e:	8526                	mv	a0,s1
    80004810:	60e2                	ld	ra,24(sp)
    80004812:	6442                	ld	s0,16(sp)
    80004814:	64a2                	ld	s1,8(sp)
    80004816:	6105                	addi	sp,sp,32
    80004818:	8082                	ret

000000008000481a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000481a:	1101                	addi	sp,sp,-32
    8000481c:	ec06                	sd	ra,24(sp)
    8000481e:	e822                	sd	s0,16(sp)
    80004820:	e426                	sd	s1,8(sp)
    80004822:	1000                	addi	s0,sp,32
    80004824:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004826:	0001e517          	auipc	a0,0x1e
    8000482a:	ae250513          	addi	a0,a0,-1310 # 80022308 <ftable>
    8000482e:	ffffc097          	auipc	ra,0xffffc
    80004832:	3a8080e7          	jalr	936(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004836:	40dc                	lw	a5,4(s1)
    80004838:	02f05263          	blez	a5,8000485c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000483c:	2785                	addiw	a5,a5,1
    8000483e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004840:	0001e517          	auipc	a0,0x1e
    80004844:	ac850513          	addi	a0,a0,-1336 # 80022308 <ftable>
    80004848:	ffffc097          	auipc	ra,0xffffc
    8000484c:	442080e7          	jalr	1090(ra) # 80000c8a <release>
  return f;
}
    80004850:	8526                	mv	a0,s1
    80004852:	60e2                	ld	ra,24(sp)
    80004854:	6442                	ld	s0,16(sp)
    80004856:	64a2                	ld	s1,8(sp)
    80004858:	6105                	addi	sp,sp,32
    8000485a:	8082                	ret
    panic("filedup");
    8000485c:	00004517          	auipc	a0,0x4
    80004860:	ecc50513          	addi	a0,a0,-308 # 80008728 <syscalls+0x240>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	cda080e7          	jalr	-806(ra) # 8000053e <panic>

000000008000486c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000486c:	7139                	addi	sp,sp,-64
    8000486e:	fc06                	sd	ra,56(sp)
    80004870:	f822                	sd	s0,48(sp)
    80004872:	f426                	sd	s1,40(sp)
    80004874:	f04a                	sd	s2,32(sp)
    80004876:	ec4e                	sd	s3,24(sp)
    80004878:	e852                	sd	s4,16(sp)
    8000487a:	e456                	sd	s5,8(sp)
    8000487c:	0080                	addi	s0,sp,64
    8000487e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004880:	0001e517          	auipc	a0,0x1e
    80004884:	a8850513          	addi	a0,a0,-1400 # 80022308 <ftable>
    80004888:	ffffc097          	auipc	ra,0xffffc
    8000488c:	34e080e7          	jalr	846(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004890:	40dc                	lw	a5,4(s1)
    80004892:	06f05163          	blez	a5,800048f4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004896:	37fd                	addiw	a5,a5,-1
    80004898:	0007871b          	sext.w	a4,a5
    8000489c:	c0dc                	sw	a5,4(s1)
    8000489e:	06e04363          	bgtz	a4,80004904 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048a2:	0004a903          	lw	s2,0(s1)
    800048a6:	0094ca83          	lbu	s5,9(s1)
    800048aa:	0104ba03          	ld	s4,16(s1)
    800048ae:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048b2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048b6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048ba:	0001e517          	auipc	a0,0x1e
    800048be:	a4e50513          	addi	a0,a0,-1458 # 80022308 <ftable>
    800048c2:	ffffc097          	auipc	ra,0xffffc
    800048c6:	3c8080e7          	jalr	968(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800048ca:	4785                	li	a5,1
    800048cc:	04f90d63          	beq	s2,a5,80004926 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048d0:	3979                	addiw	s2,s2,-2
    800048d2:	4785                	li	a5,1
    800048d4:	0527e063          	bltu	a5,s2,80004914 <fileclose+0xa8>
    begin_op();
    800048d8:	00000097          	auipc	ra,0x0
    800048dc:	ac8080e7          	jalr	-1336(ra) # 800043a0 <begin_op>
    iput(ff.ip);
    800048e0:	854e                	mv	a0,s3
    800048e2:	fffff097          	auipc	ra,0xfffff
    800048e6:	2b6080e7          	jalr	694(ra) # 80003b98 <iput>
    end_op();
    800048ea:	00000097          	auipc	ra,0x0
    800048ee:	b36080e7          	jalr	-1226(ra) # 80004420 <end_op>
    800048f2:	a00d                	j	80004914 <fileclose+0xa8>
    panic("fileclose");
    800048f4:	00004517          	auipc	a0,0x4
    800048f8:	e3c50513          	addi	a0,a0,-452 # 80008730 <syscalls+0x248>
    800048fc:	ffffc097          	auipc	ra,0xffffc
    80004900:	c42080e7          	jalr	-958(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004904:	0001e517          	auipc	a0,0x1e
    80004908:	a0450513          	addi	a0,a0,-1532 # 80022308 <ftable>
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	37e080e7          	jalr	894(ra) # 80000c8a <release>
  }
}
    80004914:	70e2                	ld	ra,56(sp)
    80004916:	7442                	ld	s0,48(sp)
    80004918:	74a2                	ld	s1,40(sp)
    8000491a:	7902                	ld	s2,32(sp)
    8000491c:	69e2                	ld	s3,24(sp)
    8000491e:	6a42                	ld	s4,16(sp)
    80004920:	6aa2                	ld	s5,8(sp)
    80004922:	6121                	addi	sp,sp,64
    80004924:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004926:	85d6                	mv	a1,s5
    80004928:	8552                	mv	a0,s4
    8000492a:	00000097          	auipc	ra,0x0
    8000492e:	34c080e7          	jalr	844(ra) # 80004c76 <pipeclose>
    80004932:	b7cd                	j	80004914 <fileclose+0xa8>

0000000080004934 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004934:	715d                	addi	sp,sp,-80
    80004936:	e486                	sd	ra,72(sp)
    80004938:	e0a2                	sd	s0,64(sp)
    8000493a:	fc26                	sd	s1,56(sp)
    8000493c:	f84a                	sd	s2,48(sp)
    8000493e:	f44e                	sd	s3,40(sp)
    80004940:	0880                	addi	s0,sp,80
    80004942:	84aa                	mv	s1,a0
    80004944:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004946:	ffffd097          	auipc	ra,0xffffd
    8000494a:	03a080e7          	jalr	58(ra) # 80001980 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000494e:	409c                	lw	a5,0(s1)
    80004950:	37f9                	addiw	a5,a5,-2
    80004952:	4705                	li	a4,1
    80004954:	04f76763          	bltu	a4,a5,800049a2 <filestat+0x6e>
    80004958:	892a                	mv	s2,a0
    ilock(f->ip);
    8000495a:	6c88                	ld	a0,24(s1)
    8000495c:	fffff097          	auipc	ra,0xfffff
    80004960:	082080e7          	jalr	130(ra) # 800039de <ilock>
    stati(f->ip, &st);
    80004964:	fb840593          	addi	a1,s0,-72
    80004968:	6c88                	ld	a0,24(s1)
    8000496a:	fffff097          	auipc	ra,0xfffff
    8000496e:	2fe080e7          	jalr	766(ra) # 80003c68 <stati>
    iunlock(f->ip);
    80004972:	6c88                	ld	a0,24(s1)
    80004974:	fffff097          	auipc	ra,0xfffff
    80004978:	12c080e7          	jalr	300(ra) # 80003aa0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000497c:	46e1                	li	a3,24
    8000497e:	fb840613          	addi	a2,s0,-72
    80004982:	85ce                	mv	a1,s3
    80004984:	10093503          	ld	a0,256(s2)
    80004988:	ffffd097          	auipc	ra,0xffffd
    8000498c:	ce0080e7          	jalr	-800(ra) # 80001668 <copyout>
    80004990:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004994:	60a6                	ld	ra,72(sp)
    80004996:	6406                	ld	s0,64(sp)
    80004998:	74e2                	ld	s1,56(sp)
    8000499a:	7942                	ld	s2,48(sp)
    8000499c:	79a2                	ld	s3,40(sp)
    8000499e:	6161                	addi	sp,sp,80
    800049a0:	8082                	ret
  return -1;
    800049a2:	557d                	li	a0,-1
    800049a4:	bfc5                	j	80004994 <filestat+0x60>

00000000800049a6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800049a6:	7179                	addi	sp,sp,-48
    800049a8:	f406                	sd	ra,40(sp)
    800049aa:	f022                	sd	s0,32(sp)
    800049ac:	ec26                	sd	s1,24(sp)
    800049ae:	e84a                	sd	s2,16(sp)
    800049b0:	e44e                	sd	s3,8(sp)
    800049b2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049b4:	00854783          	lbu	a5,8(a0)
    800049b8:	c3d5                	beqz	a5,80004a5c <fileread+0xb6>
    800049ba:	84aa                	mv	s1,a0
    800049bc:	89ae                	mv	s3,a1
    800049be:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800049c0:	411c                	lw	a5,0(a0)
    800049c2:	4705                	li	a4,1
    800049c4:	04e78963          	beq	a5,a4,80004a16 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049c8:	470d                	li	a4,3
    800049ca:	04e78d63          	beq	a5,a4,80004a24 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800049ce:	4709                	li	a4,2
    800049d0:	06e79e63          	bne	a5,a4,80004a4c <fileread+0xa6>
    ilock(f->ip);
    800049d4:	6d08                	ld	a0,24(a0)
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	008080e7          	jalr	8(ra) # 800039de <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049de:	874a                	mv	a4,s2
    800049e0:	5094                	lw	a3,32(s1)
    800049e2:	864e                	mv	a2,s3
    800049e4:	4585                	li	a1,1
    800049e6:	6c88                	ld	a0,24(s1)
    800049e8:	fffff097          	auipc	ra,0xfffff
    800049ec:	2aa080e7          	jalr	682(ra) # 80003c92 <readi>
    800049f0:	892a                	mv	s2,a0
    800049f2:	00a05563          	blez	a0,800049fc <fileread+0x56>
      f->off += r;
    800049f6:	509c                	lw	a5,32(s1)
    800049f8:	9fa9                	addw	a5,a5,a0
    800049fa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049fc:	6c88                	ld	a0,24(s1)
    800049fe:	fffff097          	auipc	ra,0xfffff
    80004a02:	0a2080e7          	jalr	162(ra) # 80003aa0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a06:	854a                	mv	a0,s2
    80004a08:	70a2                	ld	ra,40(sp)
    80004a0a:	7402                	ld	s0,32(sp)
    80004a0c:	64e2                	ld	s1,24(sp)
    80004a0e:	6942                	ld	s2,16(sp)
    80004a10:	69a2                	ld	s3,8(sp)
    80004a12:	6145                	addi	sp,sp,48
    80004a14:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a16:	6908                	ld	a0,16(a0)
    80004a18:	00000097          	auipc	ra,0x0
    80004a1c:	3c6080e7          	jalr	966(ra) # 80004dde <piperead>
    80004a20:	892a                	mv	s2,a0
    80004a22:	b7d5                	j	80004a06 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a24:	02451783          	lh	a5,36(a0)
    80004a28:	03079693          	slli	a3,a5,0x30
    80004a2c:	92c1                	srli	a3,a3,0x30
    80004a2e:	4725                	li	a4,9
    80004a30:	02d76863          	bltu	a4,a3,80004a60 <fileread+0xba>
    80004a34:	0792                	slli	a5,a5,0x4
    80004a36:	0001e717          	auipc	a4,0x1e
    80004a3a:	83270713          	addi	a4,a4,-1998 # 80022268 <devsw>
    80004a3e:	97ba                	add	a5,a5,a4
    80004a40:	639c                	ld	a5,0(a5)
    80004a42:	c38d                	beqz	a5,80004a64 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a44:	4505                	li	a0,1
    80004a46:	9782                	jalr	a5
    80004a48:	892a                	mv	s2,a0
    80004a4a:	bf75                	j	80004a06 <fileread+0x60>
    panic("fileread");
    80004a4c:	00004517          	auipc	a0,0x4
    80004a50:	cf450513          	addi	a0,a0,-780 # 80008740 <syscalls+0x258>
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	aea080e7          	jalr	-1302(ra) # 8000053e <panic>
    return -1;
    80004a5c:	597d                	li	s2,-1
    80004a5e:	b765                	j	80004a06 <fileread+0x60>
      return -1;
    80004a60:	597d                	li	s2,-1
    80004a62:	b755                	j	80004a06 <fileread+0x60>
    80004a64:	597d                	li	s2,-1
    80004a66:	b745                	j	80004a06 <fileread+0x60>

0000000080004a68 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a68:	715d                	addi	sp,sp,-80
    80004a6a:	e486                	sd	ra,72(sp)
    80004a6c:	e0a2                	sd	s0,64(sp)
    80004a6e:	fc26                	sd	s1,56(sp)
    80004a70:	f84a                	sd	s2,48(sp)
    80004a72:	f44e                	sd	s3,40(sp)
    80004a74:	f052                	sd	s4,32(sp)
    80004a76:	ec56                	sd	s5,24(sp)
    80004a78:	e85a                	sd	s6,16(sp)
    80004a7a:	e45e                	sd	s7,8(sp)
    80004a7c:	e062                	sd	s8,0(sp)
    80004a7e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a80:	00954783          	lbu	a5,9(a0)
    80004a84:	10078663          	beqz	a5,80004b90 <filewrite+0x128>
    80004a88:	892a                	mv	s2,a0
    80004a8a:	8aae                	mv	s5,a1
    80004a8c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a8e:	411c                	lw	a5,0(a0)
    80004a90:	4705                	li	a4,1
    80004a92:	02e78263          	beq	a5,a4,80004ab6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a96:	470d                	li	a4,3
    80004a98:	02e78663          	beq	a5,a4,80004ac4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a9c:	4709                	li	a4,2
    80004a9e:	0ee79163          	bne	a5,a4,80004b80 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004aa2:	0ac05d63          	blez	a2,80004b5c <filewrite+0xf4>
    int i = 0;
    80004aa6:	4981                	li	s3,0
    80004aa8:	6b05                	lui	s6,0x1
    80004aaa:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004aae:	6b85                	lui	s7,0x1
    80004ab0:	c00b8b9b          	addiw	s7,s7,-1024
    80004ab4:	a861                	j	80004b4c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004ab6:	6908                	ld	a0,16(a0)
    80004ab8:	00000097          	auipc	ra,0x0
    80004abc:	22e080e7          	jalr	558(ra) # 80004ce6 <pipewrite>
    80004ac0:	8a2a                	mv	s4,a0
    80004ac2:	a045                	j	80004b62 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ac4:	02451783          	lh	a5,36(a0)
    80004ac8:	03079693          	slli	a3,a5,0x30
    80004acc:	92c1                	srli	a3,a3,0x30
    80004ace:	4725                	li	a4,9
    80004ad0:	0cd76263          	bltu	a4,a3,80004b94 <filewrite+0x12c>
    80004ad4:	0792                	slli	a5,a5,0x4
    80004ad6:	0001d717          	auipc	a4,0x1d
    80004ada:	79270713          	addi	a4,a4,1938 # 80022268 <devsw>
    80004ade:	97ba                	add	a5,a5,a4
    80004ae0:	679c                	ld	a5,8(a5)
    80004ae2:	cbdd                	beqz	a5,80004b98 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ae4:	4505                	li	a0,1
    80004ae6:	9782                	jalr	a5
    80004ae8:	8a2a                	mv	s4,a0
    80004aea:	a8a5                	j	80004b62 <filewrite+0xfa>
    80004aec:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004af0:	00000097          	auipc	ra,0x0
    80004af4:	8b0080e7          	jalr	-1872(ra) # 800043a0 <begin_op>
      ilock(f->ip);
    80004af8:	01893503          	ld	a0,24(s2)
    80004afc:	fffff097          	auipc	ra,0xfffff
    80004b00:	ee2080e7          	jalr	-286(ra) # 800039de <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b04:	8762                	mv	a4,s8
    80004b06:	02092683          	lw	a3,32(s2)
    80004b0a:	01598633          	add	a2,s3,s5
    80004b0e:	4585                	li	a1,1
    80004b10:	01893503          	ld	a0,24(s2)
    80004b14:	fffff097          	auipc	ra,0xfffff
    80004b18:	276080e7          	jalr	630(ra) # 80003d8a <writei>
    80004b1c:	84aa                	mv	s1,a0
    80004b1e:	00a05763          	blez	a0,80004b2c <filewrite+0xc4>
        f->off += r;
    80004b22:	02092783          	lw	a5,32(s2)
    80004b26:	9fa9                	addw	a5,a5,a0
    80004b28:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b2c:	01893503          	ld	a0,24(s2)
    80004b30:	fffff097          	auipc	ra,0xfffff
    80004b34:	f70080e7          	jalr	-144(ra) # 80003aa0 <iunlock>
      end_op();
    80004b38:	00000097          	auipc	ra,0x0
    80004b3c:	8e8080e7          	jalr	-1816(ra) # 80004420 <end_op>

      if(r != n1){
    80004b40:	009c1f63          	bne	s8,s1,80004b5e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004b44:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b48:	0149db63          	bge	s3,s4,80004b5e <filewrite+0xf6>
      int n1 = n - i;
    80004b4c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b50:	84be                	mv	s1,a5
    80004b52:	2781                	sext.w	a5,a5
    80004b54:	f8fb5ce3          	bge	s6,a5,80004aec <filewrite+0x84>
    80004b58:	84de                	mv	s1,s7
    80004b5a:	bf49                	j	80004aec <filewrite+0x84>
    int i = 0;
    80004b5c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b5e:	013a1f63          	bne	s4,s3,80004b7c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b62:	8552                	mv	a0,s4
    80004b64:	60a6                	ld	ra,72(sp)
    80004b66:	6406                	ld	s0,64(sp)
    80004b68:	74e2                	ld	s1,56(sp)
    80004b6a:	7942                	ld	s2,48(sp)
    80004b6c:	79a2                	ld	s3,40(sp)
    80004b6e:	7a02                	ld	s4,32(sp)
    80004b70:	6ae2                	ld	s5,24(sp)
    80004b72:	6b42                	ld	s6,16(sp)
    80004b74:	6ba2                	ld	s7,8(sp)
    80004b76:	6c02                	ld	s8,0(sp)
    80004b78:	6161                	addi	sp,sp,80
    80004b7a:	8082                	ret
    ret = (i == n ? n : -1);
    80004b7c:	5a7d                	li	s4,-1
    80004b7e:	b7d5                	j	80004b62 <filewrite+0xfa>
    panic("filewrite");
    80004b80:	00004517          	auipc	a0,0x4
    80004b84:	bd050513          	addi	a0,a0,-1072 # 80008750 <syscalls+0x268>
    80004b88:	ffffc097          	auipc	ra,0xffffc
    80004b8c:	9b6080e7          	jalr	-1610(ra) # 8000053e <panic>
    return -1;
    80004b90:	5a7d                	li	s4,-1
    80004b92:	bfc1                	j	80004b62 <filewrite+0xfa>
      return -1;
    80004b94:	5a7d                	li	s4,-1
    80004b96:	b7f1                	j	80004b62 <filewrite+0xfa>
    80004b98:	5a7d                	li	s4,-1
    80004b9a:	b7e1                	j	80004b62 <filewrite+0xfa>

0000000080004b9c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b9c:	7179                	addi	sp,sp,-48
    80004b9e:	f406                	sd	ra,40(sp)
    80004ba0:	f022                	sd	s0,32(sp)
    80004ba2:	ec26                	sd	s1,24(sp)
    80004ba4:	e84a                	sd	s2,16(sp)
    80004ba6:	e44e                	sd	s3,8(sp)
    80004ba8:	e052                	sd	s4,0(sp)
    80004baa:	1800                	addi	s0,sp,48
    80004bac:	84aa                	mv	s1,a0
    80004bae:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004bb0:	0005b023          	sd	zero,0(a1)
    80004bb4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004bb8:	00000097          	auipc	ra,0x0
    80004bbc:	bf8080e7          	jalr	-1032(ra) # 800047b0 <filealloc>
    80004bc0:	e088                	sd	a0,0(s1)
    80004bc2:	c551                	beqz	a0,80004c4e <pipealloc+0xb2>
    80004bc4:	00000097          	auipc	ra,0x0
    80004bc8:	bec080e7          	jalr	-1044(ra) # 800047b0 <filealloc>
    80004bcc:	00aa3023          	sd	a0,0(s4)
    80004bd0:	c92d                	beqz	a0,80004c42 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004bd2:	ffffc097          	auipc	ra,0xffffc
    80004bd6:	f14080e7          	jalr	-236(ra) # 80000ae6 <kalloc>
    80004bda:	892a                	mv	s2,a0
    80004bdc:	c125                	beqz	a0,80004c3c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004bde:	4985                	li	s3,1
    80004be0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004be4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004be8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004bec:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004bf0:	00004597          	auipc	a1,0x4
    80004bf4:	b7058593          	addi	a1,a1,-1168 # 80008760 <syscalls+0x278>
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	f4e080e7          	jalr	-178(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004c00:	609c                	ld	a5,0(s1)
    80004c02:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c06:	609c                	ld	a5,0(s1)
    80004c08:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c0c:	609c                	ld	a5,0(s1)
    80004c0e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c12:	609c                	ld	a5,0(s1)
    80004c14:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c18:	000a3783          	ld	a5,0(s4)
    80004c1c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c20:	000a3783          	ld	a5,0(s4)
    80004c24:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c28:	000a3783          	ld	a5,0(s4)
    80004c2c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c30:	000a3783          	ld	a5,0(s4)
    80004c34:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c38:	4501                	li	a0,0
    80004c3a:	a025                	j	80004c62 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c3c:	6088                	ld	a0,0(s1)
    80004c3e:	e501                	bnez	a0,80004c46 <pipealloc+0xaa>
    80004c40:	a039                	j	80004c4e <pipealloc+0xb2>
    80004c42:	6088                	ld	a0,0(s1)
    80004c44:	c51d                	beqz	a0,80004c72 <pipealloc+0xd6>
    fileclose(*f0);
    80004c46:	00000097          	auipc	ra,0x0
    80004c4a:	c26080e7          	jalr	-986(ra) # 8000486c <fileclose>
  if(*f1)
    80004c4e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c52:	557d                	li	a0,-1
  if(*f1)
    80004c54:	c799                	beqz	a5,80004c62 <pipealloc+0xc6>
    fileclose(*f1);
    80004c56:	853e                	mv	a0,a5
    80004c58:	00000097          	auipc	ra,0x0
    80004c5c:	c14080e7          	jalr	-1004(ra) # 8000486c <fileclose>
  return -1;
    80004c60:	557d                	li	a0,-1
}
    80004c62:	70a2                	ld	ra,40(sp)
    80004c64:	7402                	ld	s0,32(sp)
    80004c66:	64e2                	ld	s1,24(sp)
    80004c68:	6942                	ld	s2,16(sp)
    80004c6a:	69a2                	ld	s3,8(sp)
    80004c6c:	6a02                	ld	s4,0(sp)
    80004c6e:	6145                	addi	sp,sp,48
    80004c70:	8082                	ret
  return -1;
    80004c72:	557d                	li	a0,-1
    80004c74:	b7fd                	j	80004c62 <pipealloc+0xc6>

0000000080004c76 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c76:	1101                	addi	sp,sp,-32
    80004c78:	ec06                	sd	ra,24(sp)
    80004c7a:	e822                	sd	s0,16(sp)
    80004c7c:	e426                	sd	s1,8(sp)
    80004c7e:	e04a                	sd	s2,0(sp)
    80004c80:	1000                	addi	s0,sp,32
    80004c82:	84aa                	mv	s1,a0
    80004c84:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	f50080e7          	jalr	-176(ra) # 80000bd6 <acquire>
  if(writable){
    80004c8e:	02090d63          	beqz	s2,80004cc8 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c92:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c96:	21848513          	addi	a0,s1,536
    80004c9a:	ffffd097          	auipc	ra,0xffffd
    80004c9e:	504080e7          	jalr	1284(ra) # 8000219e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ca2:	2204b783          	ld	a5,544(s1)
    80004ca6:	eb95                	bnez	a5,80004cda <pipeclose+0x64>
    release(&pi->lock);
    80004ca8:	8526                	mv	a0,s1
    80004caa:	ffffc097          	auipc	ra,0xffffc
    80004cae:	fe0080e7          	jalr	-32(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004cb2:	8526                	mv	a0,s1
    80004cb4:	ffffc097          	auipc	ra,0xffffc
    80004cb8:	d36080e7          	jalr	-714(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004cbc:	60e2                	ld	ra,24(sp)
    80004cbe:	6442                	ld	s0,16(sp)
    80004cc0:	64a2                	ld	s1,8(sp)
    80004cc2:	6902                	ld	s2,0(sp)
    80004cc4:	6105                	addi	sp,sp,32
    80004cc6:	8082                	ret
    pi->readopen = 0;
    80004cc8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ccc:	21c48513          	addi	a0,s1,540
    80004cd0:	ffffd097          	auipc	ra,0xffffd
    80004cd4:	4ce080e7          	jalr	1230(ra) # 8000219e <wakeup>
    80004cd8:	b7e9                	j	80004ca2 <pipeclose+0x2c>
    release(&pi->lock);
    80004cda:	8526                	mv	a0,s1
    80004cdc:	ffffc097          	auipc	ra,0xffffc
    80004ce0:	fae080e7          	jalr	-82(ra) # 80000c8a <release>
}
    80004ce4:	bfe1                	j	80004cbc <pipeclose+0x46>

0000000080004ce6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ce6:	711d                	addi	sp,sp,-96
    80004ce8:	ec86                	sd	ra,88(sp)
    80004cea:	e8a2                	sd	s0,80(sp)
    80004cec:	e4a6                	sd	s1,72(sp)
    80004cee:	e0ca                	sd	s2,64(sp)
    80004cf0:	fc4e                	sd	s3,56(sp)
    80004cf2:	f852                	sd	s4,48(sp)
    80004cf4:	f456                	sd	s5,40(sp)
    80004cf6:	f05a                	sd	s6,32(sp)
    80004cf8:	ec5e                	sd	s7,24(sp)
    80004cfa:	e862                	sd	s8,16(sp)
    80004cfc:	1080                	addi	s0,sp,96
    80004cfe:	84aa                	mv	s1,a0
    80004d00:	8aae                	mv	s5,a1
    80004d02:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d04:	ffffd097          	auipc	ra,0xffffd
    80004d08:	c7c080e7          	jalr	-900(ra) # 80001980 <myproc>
    80004d0c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d0e:	8526                	mv	a0,s1
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	ec6080e7          	jalr	-314(ra) # 80000bd6 <acquire>
  while(i < n){
    80004d18:	0b405663          	blez	s4,80004dc4 <pipewrite+0xde>
  int i = 0;
    80004d1c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d1e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d20:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d24:	21c48b93          	addi	s7,s1,540
    80004d28:	a089                	j	80004d6a <pipewrite+0x84>
      release(&pi->lock);
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	f5e080e7          	jalr	-162(ra) # 80000c8a <release>
      return -1;
    80004d34:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d36:	854a                	mv	a0,s2
    80004d38:	60e6                	ld	ra,88(sp)
    80004d3a:	6446                	ld	s0,80(sp)
    80004d3c:	64a6                	ld	s1,72(sp)
    80004d3e:	6906                	ld	s2,64(sp)
    80004d40:	79e2                	ld	s3,56(sp)
    80004d42:	7a42                	ld	s4,48(sp)
    80004d44:	7aa2                	ld	s5,40(sp)
    80004d46:	7b02                	ld	s6,32(sp)
    80004d48:	6be2                	ld	s7,24(sp)
    80004d4a:	6c42                	ld	s8,16(sp)
    80004d4c:	6125                	addi	sp,sp,96
    80004d4e:	8082                	ret
      wakeup(&pi->nread);
    80004d50:	8562                	mv	a0,s8
    80004d52:	ffffd097          	auipc	ra,0xffffd
    80004d56:	44c080e7          	jalr	1100(ra) # 8000219e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d5a:	85a6                	mv	a1,s1
    80004d5c:	855e                	mv	a0,s7
    80004d5e:	ffffd097          	auipc	ra,0xffffd
    80004d62:	3c0080e7          	jalr	960(ra) # 8000211e <sleep>
  while(i < n){
    80004d66:	07495063          	bge	s2,s4,80004dc6 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d6a:	2204a783          	lw	a5,544(s1)
    80004d6e:	dfd5                	beqz	a5,80004d2a <pipewrite+0x44>
    80004d70:	854e                	mv	a0,s3
    80004d72:	ffffd097          	auipc	ra,0xffffd
    80004d76:	6ee080e7          	jalr	1774(ra) # 80002460 <killed>
    80004d7a:	f945                	bnez	a0,80004d2a <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d7c:	2184a783          	lw	a5,536(s1)
    80004d80:	21c4a703          	lw	a4,540(s1)
    80004d84:	2007879b          	addiw	a5,a5,512
    80004d88:	fcf704e3          	beq	a4,a5,80004d50 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d8c:	4685                	li	a3,1
    80004d8e:	01590633          	add	a2,s2,s5
    80004d92:	faf40593          	addi	a1,s0,-81
    80004d96:	1009b503          	ld	a0,256(s3)
    80004d9a:	ffffd097          	auipc	ra,0xffffd
    80004d9e:	95a080e7          	jalr	-1702(ra) # 800016f4 <copyin>
    80004da2:	03650263          	beq	a0,s6,80004dc6 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004da6:	21c4a783          	lw	a5,540(s1)
    80004daa:	0017871b          	addiw	a4,a5,1
    80004dae:	20e4ae23          	sw	a4,540(s1)
    80004db2:	1ff7f793          	andi	a5,a5,511
    80004db6:	97a6                	add	a5,a5,s1
    80004db8:	faf44703          	lbu	a4,-81(s0)
    80004dbc:	00e78c23          	sb	a4,24(a5)
      i++;
    80004dc0:	2905                	addiw	s2,s2,1
    80004dc2:	b755                	j	80004d66 <pipewrite+0x80>
  int i = 0;
    80004dc4:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004dc6:	21848513          	addi	a0,s1,536
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	3d4080e7          	jalr	980(ra) # 8000219e <wakeup>
  release(&pi->lock);
    80004dd2:	8526                	mv	a0,s1
    80004dd4:	ffffc097          	auipc	ra,0xffffc
    80004dd8:	eb6080e7          	jalr	-330(ra) # 80000c8a <release>
  return i;
    80004ddc:	bfa9                	j	80004d36 <pipewrite+0x50>

0000000080004dde <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004dde:	715d                	addi	sp,sp,-80
    80004de0:	e486                	sd	ra,72(sp)
    80004de2:	e0a2                	sd	s0,64(sp)
    80004de4:	fc26                	sd	s1,56(sp)
    80004de6:	f84a                	sd	s2,48(sp)
    80004de8:	f44e                	sd	s3,40(sp)
    80004dea:	f052                	sd	s4,32(sp)
    80004dec:	ec56                	sd	s5,24(sp)
    80004dee:	e85a                	sd	s6,16(sp)
    80004df0:	0880                	addi	s0,sp,80
    80004df2:	84aa                	mv	s1,a0
    80004df4:	892e                	mv	s2,a1
    80004df6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004df8:	ffffd097          	auipc	ra,0xffffd
    80004dfc:	b88080e7          	jalr	-1144(ra) # 80001980 <myproc>
    80004e00:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e02:	8526                	mv	a0,s1
    80004e04:	ffffc097          	auipc	ra,0xffffc
    80004e08:	dd2080e7          	jalr	-558(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e0c:	2184a703          	lw	a4,536(s1)
    80004e10:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e14:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e18:	02f71763          	bne	a4,a5,80004e46 <piperead+0x68>
    80004e1c:	2244a783          	lw	a5,548(s1)
    80004e20:	c39d                	beqz	a5,80004e46 <piperead+0x68>
    if(killed(pr)){
    80004e22:	8552                	mv	a0,s4
    80004e24:	ffffd097          	auipc	ra,0xffffd
    80004e28:	63c080e7          	jalr	1596(ra) # 80002460 <killed>
    80004e2c:	e941                	bnez	a0,80004ebc <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e2e:	85a6                	mv	a1,s1
    80004e30:	854e                	mv	a0,s3
    80004e32:	ffffd097          	auipc	ra,0xffffd
    80004e36:	2ec080e7          	jalr	748(ra) # 8000211e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e3a:	2184a703          	lw	a4,536(s1)
    80004e3e:	21c4a783          	lw	a5,540(s1)
    80004e42:	fcf70de3          	beq	a4,a5,80004e1c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e46:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e48:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e4a:	05505363          	blez	s5,80004e90 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004e4e:	2184a783          	lw	a5,536(s1)
    80004e52:	21c4a703          	lw	a4,540(s1)
    80004e56:	02f70d63          	beq	a4,a5,80004e90 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e5a:	0017871b          	addiw	a4,a5,1
    80004e5e:	20e4ac23          	sw	a4,536(s1)
    80004e62:	1ff7f793          	andi	a5,a5,511
    80004e66:	97a6                	add	a5,a5,s1
    80004e68:	0187c783          	lbu	a5,24(a5)
    80004e6c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e70:	4685                	li	a3,1
    80004e72:	fbf40613          	addi	a2,s0,-65
    80004e76:	85ca                	mv	a1,s2
    80004e78:	100a3503          	ld	a0,256(s4)
    80004e7c:	ffffc097          	auipc	ra,0xffffc
    80004e80:	7ec080e7          	jalr	2028(ra) # 80001668 <copyout>
    80004e84:	01650663          	beq	a0,s6,80004e90 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e88:	2985                	addiw	s3,s3,1
    80004e8a:	0905                	addi	s2,s2,1
    80004e8c:	fd3a91e3          	bne	s5,s3,80004e4e <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e90:	21c48513          	addi	a0,s1,540
    80004e94:	ffffd097          	auipc	ra,0xffffd
    80004e98:	30a080e7          	jalr	778(ra) # 8000219e <wakeup>
  release(&pi->lock);
    80004e9c:	8526                	mv	a0,s1
    80004e9e:	ffffc097          	auipc	ra,0xffffc
    80004ea2:	dec080e7          	jalr	-532(ra) # 80000c8a <release>
  return i;
}
    80004ea6:	854e                	mv	a0,s3
    80004ea8:	60a6                	ld	ra,72(sp)
    80004eaa:	6406                	ld	s0,64(sp)
    80004eac:	74e2                	ld	s1,56(sp)
    80004eae:	7942                	ld	s2,48(sp)
    80004eb0:	79a2                	ld	s3,40(sp)
    80004eb2:	7a02                	ld	s4,32(sp)
    80004eb4:	6ae2                	ld	s5,24(sp)
    80004eb6:	6b42                	ld	s6,16(sp)
    80004eb8:	6161                	addi	sp,sp,80
    80004eba:	8082                	ret
      release(&pi->lock);
    80004ebc:	8526                	mv	a0,s1
    80004ebe:	ffffc097          	auipc	ra,0xffffc
    80004ec2:	dcc080e7          	jalr	-564(ra) # 80000c8a <release>
      return -1;
    80004ec6:	59fd                	li	s3,-1
    80004ec8:	bff9                	j	80004ea6 <piperead+0xc8>

0000000080004eca <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004eca:	1141                	addi	sp,sp,-16
    80004ecc:	e422                	sd	s0,8(sp)
    80004ece:	0800                	addi	s0,sp,16
    80004ed0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004ed2:	8905                	andi	a0,a0,1
    80004ed4:	c111                	beqz	a0,80004ed8 <flags2perm+0xe>
      perm = PTE_X;
    80004ed6:	4521                	li	a0,8
    if(flags & 0x2)
    80004ed8:	8b89                	andi	a5,a5,2
    80004eda:	c399                	beqz	a5,80004ee0 <flags2perm+0x16>
      perm |= PTE_W;
    80004edc:	00456513          	ori	a0,a0,4
    return perm;
}
    80004ee0:	6422                	ld	s0,8(sp)
    80004ee2:	0141                	addi	sp,sp,16
    80004ee4:	8082                	ret

0000000080004ee6 <exec>:

int
exec(char *path, char **argv)
{
    80004ee6:	de010113          	addi	sp,sp,-544
    80004eea:	20113c23          	sd	ra,536(sp)
    80004eee:	20813823          	sd	s0,528(sp)
    80004ef2:	20913423          	sd	s1,520(sp)
    80004ef6:	21213023          	sd	s2,512(sp)
    80004efa:	ffce                	sd	s3,504(sp)
    80004efc:	fbd2                	sd	s4,496(sp)
    80004efe:	f7d6                	sd	s5,488(sp)
    80004f00:	f3da                	sd	s6,480(sp)
    80004f02:	efde                	sd	s7,472(sp)
    80004f04:	ebe2                	sd	s8,464(sp)
    80004f06:	e7e6                	sd	s9,456(sp)
    80004f08:	e3ea                	sd	s10,448(sp)
    80004f0a:	ff6e                	sd	s11,440(sp)
    80004f0c:	1400                	addi	s0,sp,544
    80004f0e:	892a                	mv	s2,a0
    80004f10:	dea43423          	sd	a0,-536(s0)
    80004f14:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f18:	ffffd097          	auipc	ra,0xffffd
    80004f1c:	a68080e7          	jalr	-1432(ra) # 80001980 <myproc>
    80004f20:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80004f22:	ffffe097          	auipc	ra,0xffffe
    80004f26:	86e080e7          	jalr	-1938(ra) # 80002790 <mykthread>

  begin_op();
    80004f2a:	fffff097          	auipc	ra,0xfffff
    80004f2e:	476080e7          	jalr	1142(ra) # 800043a0 <begin_op>

  if((ip = namei(path)) == 0){
    80004f32:	854a                	mv	a0,s2
    80004f34:	fffff097          	auipc	ra,0xfffff
    80004f38:	250080e7          	jalr	592(ra) # 80004184 <namei>
    80004f3c:	c93d                	beqz	a0,80004fb2 <exec+0xcc>
    80004f3e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f40:	fffff097          	auipc	ra,0xfffff
    80004f44:	a9e080e7          	jalr	-1378(ra) # 800039de <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f48:	04000713          	li	a4,64
    80004f4c:	4681                	li	a3,0
    80004f4e:	e5040613          	addi	a2,s0,-432
    80004f52:	4581                	li	a1,0
    80004f54:	8556                	mv	a0,s5
    80004f56:	fffff097          	auipc	ra,0xfffff
    80004f5a:	d3c080e7          	jalr	-708(ra) # 80003c92 <readi>
    80004f5e:	04000793          	li	a5,64
    80004f62:	00f51a63          	bne	a0,a5,80004f76 <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f66:	e5042703          	lw	a4,-432(s0)
    80004f6a:	464c47b7          	lui	a5,0x464c4
    80004f6e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f72:	04f70663          	beq	a4,a5,80004fbe <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f76:	8556                	mv	a0,s5
    80004f78:	fffff097          	auipc	ra,0xfffff
    80004f7c:	cc8080e7          	jalr	-824(ra) # 80003c40 <iunlockput>
    end_op();
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	4a0080e7          	jalr	1184(ra) # 80004420 <end_op>
  }
  return -1;
    80004f88:	557d                	li	a0,-1
}
    80004f8a:	21813083          	ld	ra,536(sp)
    80004f8e:	21013403          	ld	s0,528(sp)
    80004f92:	20813483          	ld	s1,520(sp)
    80004f96:	20013903          	ld	s2,512(sp)
    80004f9a:	79fe                	ld	s3,504(sp)
    80004f9c:	7a5e                	ld	s4,496(sp)
    80004f9e:	7abe                	ld	s5,488(sp)
    80004fa0:	7b1e                	ld	s6,480(sp)
    80004fa2:	6bfe                	ld	s7,472(sp)
    80004fa4:	6c5e                	ld	s8,464(sp)
    80004fa6:	6cbe                	ld	s9,456(sp)
    80004fa8:	6d1e                	ld	s10,448(sp)
    80004faa:	7dfa                	ld	s11,440(sp)
    80004fac:	22010113          	addi	sp,sp,544
    80004fb0:	8082                	ret
    end_op();
    80004fb2:	fffff097          	auipc	ra,0xfffff
    80004fb6:	46e080e7          	jalr	1134(ra) # 80004420 <end_op>
    return -1;
    80004fba:	557d                	li	a0,-1
    80004fbc:	b7f9                	j	80004f8a <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    80004fbe:	8526                	mv	a0,s1
    80004fc0:	ffffd097          	auipc	ra,0xffffd
    80004fc4:	a42080e7          	jalr	-1470(ra) # 80001a02 <proc_pagetable>
    80004fc8:	8b2a                	mv	s6,a0
    80004fca:	d555                	beqz	a0,80004f76 <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fcc:	e7042783          	lw	a5,-400(s0)
    80004fd0:	e8845703          	lhu	a4,-376(s0)
    80004fd4:	c735                	beqz	a4,80005040 <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fd6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fd8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004fdc:	6a05                	lui	s4,0x1
    80004fde:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004fe2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004fe6:	6d85                	lui	s11,0x1
    80004fe8:	7d7d                	lui	s10,0xfffff
    80004fea:	a4a9                	j	80005234 <exec+0x34e>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004fec:	00003517          	auipc	a0,0x3
    80004ff0:	77c50513          	addi	a0,a0,1916 # 80008768 <syscalls+0x280>
    80004ff4:	ffffb097          	auipc	ra,0xffffb
    80004ff8:	54a080e7          	jalr	1354(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ffc:	874a                	mv	a4,s2
    80004ffe:	009c86bb          	addw	a3,s9,s1
    80005002:	4581                	li	a1,0
    80005004:	8556                	mv	a0,s5
    80005006:	fffff097          	auipc	ra,0xfffff
    8000500a:	c8c080e7          	jalr	-884(ra) # 80003c92 <readi>
    8000500e:	2501                	sext.w	a0,a0
    80005010:	1aa91f63          	bne	s2,a0,800051ce <exec+0x2e8>
  for(i = 0; i < sz; i += PGSIZE){
    80005014:	009d84bb          	addw	s1,s11,s1
    80005018:	013d09bb          	addw	s3,s10,s3
    8000501c:	1f74fc63          	bgeu	s1,s7,80005214 <exec+0x32e>
    pa = walkaddr(pagetable, va + i);
    80005020:	02049593          	slli	a1,s1,0x20
    80005024:	9181                	srli	a1,a1,0x20
    80005026:	95e2                	add	a1,a1,s8
    80005028:	855a                	mv	a0,s6
    8000502a:	ffffc097          	auipc	ra,0xffffc
    8000502e:	032080e7          	jalr	50(ra) # 8000105c <walkaddr>
    80005032:	862a                	mv	a2,a0
    if(pa == 0)
    80005034:	dd45                	beqz	a0,80004fec <exec+0x106>
      n = PGSIZE;
    80005036:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005038:	fd49f2e3          	bgeu	s3,s4,80004ffc <exec+0x116>
      n = sz - i;
    8000503c:	894e                	mv	s2,s3
    8000503e:	bf7d                	j	80004ffc <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005040:	4901                	li	s2,0
  iunlockput(ip);
    80005042:	8556                	mv	a0,s5
    80005044:	fffff097          	auipc	ra,0xfffff
    80005048:	bfc080e7          	jalr	-1028(ra) # 80003c40 <iunlockput>
  end_op();
    8000504c:	fffff097          	auipc	ra,0xfffff
    80005050:	3d4080e7          	jalr	980(ra) # 80004420 <end_op>
  p = myproc();
    80005054:	ffffd097          	auipc	ra,0xffffd
    80005058:	92c080e7          	jalr	-1748(ra) # 80001980 <myproc>
    8000505c:	8baa                	mv	s7,a0
  kt = mykthread();
    8000505e:	ffffd097          	auipc	ra,0xffffd
    80005062:	732080e7          	jalr	1842(ra) # 80002790 <mykthread>
    80005066:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80005068:	0f8bbd83          	ld	s11,248(s7) # 10f8 <_entry-0x7fffef08>
  sz = PGROUNDUP(sz);
    8000506c:	6785                	lui	a5,0x1
    8000506e:	17fd                	addi	a5,a5,-1
    80005070:	993e                	add	s2,s2,a5
    80005072:	77fd                	lui	a5,0xfffff
    80005074:	00f977b3          	and	a5,s2,a5
    80005078:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000507c:	4691                	li	a3,4
    8000507e:	6609                	lui	a2,0x2
    80005080:	963e                	add	a2,a2,a5
    80005082:	85be                	mv	a1,a5
    80005084:	855a                	mv	a0,s6
    80005086:	ffffc097          	auipc	ra,0xffffc
    8000508a:	38a080e7          	jalr	906(ra) # 80001410 <uvmalloc>
    8000508e:	8c2a                	mv	s8,a0
  ip = 0;
    80005090:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005092:	12050e63          	beqz	a0,800051ce <exec+0x2e8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005096:	75f9                	lui	a1,0xffffe
    80005098:	95aa                	add	a1,a1,a0
    8000509a:	855a                	mv	a0,s6
    8000509c:	ffffc097          	auipc	ra,0xffffc
    800050a0:	59a080e7          	jalr	1434(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    800050a4:	7afd                	lui	s5,0xfffff
    800050a6:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800050a8:	df043783          	ld	a5,-528(s0)
    800050ac:	6388                	ld	a0,0(a5)
    800050ae:	c925                	beqz	a0,8000511e <exec+0x238>
    800050b0:	e9040993          	addi	s3,s0,-368
    800050b4:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800050b8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050ba:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050bc:	ffffc097          	auipc	ra,0xffffc
    800050c0:	d92080e7          	jalr	-622(ra) # 80000e4e <strlen>
    800050c4:	0015079b          	addiw	a5,a0,1
    800050c8:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050cc:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800050d0:	13596663          	bltu	s2,s5,800051fc <exec+0x316>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050d4:	df043783          	ld	a5,-528(s0)
    800050d8:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffdbc00>
    800050dc:	8552                	mv	a0,s4
    800050de:	ffffc097          	auipc	ra,0xffffc
    800050e2:	d70080e7          	jalr	-656(ra) # 80000e4e <strlen>
    800050e6:	0015069b          	addiw	a3,a0,1
    800050ea:	8652                	mv	a2,s4
    800050ec:	85ca                	mv	a1,s2
    800050ee:	855a                	mv	a0,s6
    800050f0:	ffffc097          	auipc	ra,0xffffc
    800050f4:	578080e7          	jalr	1400(ra) # 80001668 <copyout>
    800050f8:	10054663          	bltz	a0,80005204 <exec+0x31e>
    ustack[argc] = sp;
    800050fc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005100:	0485                	addi	s1,s1,1
    80005102:	df043783          	ld	a5,-528(s0)
    80005106:	07a1                	addi	a5,a5,8
    80005108:	def43823          	sd	a5,-528(s0)
    8000510c:	6388                	ld	a0,0(a5)
    8000510e:	c911                	beqz	a0,80005122 <exec+0x23c>
    if(argc >= MAXARG)
    80005110:	09a1                	addi	s3,s3,8
    80005112:	fb3c95e3          	bne	s9,s3,800050bc <exec+0x1d6>
  sz = sz1;
    80005116:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000511a:	4a81                	li	s5,0
    8000511c:	a84d                	j	800051ce <exec+0x2e8>
  sp = sz;
    8000511e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005120:	4481                	li	s1,0
  ustack[argc] = 0;
    80005122:	00349793          	slli	a5,s1,0x3
    80005126:	f9040713          	addi	a4,s0,-112
    8000512a:	97ba                	add	a5,a5,a4
    8000512c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005130:	00148693          	addi	a3,s1,1
    80005134:	068e                	slli	a3,a3,0x3
    80005136:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000513a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000513e:	01597663          	bgeu	s2,s5,8000514a <exec+0x264>
  sz = sz1;
    80005142:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005146:	4a81                	li	s5,0
    80005148:	a059                	j	800051ce <exec+0x2e8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000514a:	e9040613          	addi	a2,s0,-368
    8000514e:	85ca                	mv	a1,s2
    80005150:	855a                	mv	a0,s6
    80005152:	ffffc097          	auipc	ra,0xffffc
    80005156:	516080e7          	jalr	1302(ra) # 80001668 <copyout>
    8000515a:	0a054963          	bltz	a0,8000520c <exec+0x326>
  kt->trapframe->a1 = sp;
    8000515e:	0b8d3783          	ld	a5,184(s10) # fffffffffffff0b8 <end+0xffffffff7ffdbcb8>
    80005162:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005166:	de843783          	ld	a5,-536(s0)
    8000516a:	0007c703          	lbu	a4,0(a5)
    8000516e:	cf11                	beqz	a4,8000518a <exec+0x2a4>
    80005170:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005172:	02f00693          	li	a3,47
    80005176:	a039                	j	80005184 <exec+0x29e>
      last = s+1;
    80005178:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000517c:	0785                	addi	a5,a5,1
    8000517e:	fff7c703          	lbu	a4,-1(a5)
    80005182:	c701                	beqz	a4,8000518a <exec+0x2a4>
    if(*s == '/')
    80005184:	fed71ce3          	bne	a4,a3,8000517c <exec+0x296>
    80005188:	bfc5                	j	80005178 <exec+0x292>
  safestrcpy(p->name, last, sizeof(p->name));
    8000518a:	4641                	li	a2,16
    8000518c:	de843583          	ld	a1,-536(s0)
    80005190:	190b8513          	addi	a0,s7,400
    80005194:	ffffc097          	auipc	ra,0xffffc
    80005198:	c88080e7          	jalr	-888(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000519c:	100bb503          	ld	a0,256(s7)
  p->pagetable = pagetable;
    800051a0:	116bb023          	sd	s6,256(s7)
  p->sz = sz;
    800051a4:	0f8bbc23          	sd	s8,248(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    800051a8:	0b8d3783          	ld	a5,184(s10)
    800051ac:	e6843703          	ld	a4,-408(s0)
    800051b0:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    800051b2:	0b8d3783          	ld	a5,184(s10)
    800051b6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051ba:	85ee                	mv	a1,s11
    800051bc:	ffffd097          	auipc	ra,0xffffd
    800051c0:	8e2080e7          	jalr	-1822(ra) # 80001a9e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051c4:	0004851b          	sext.w	a0,s1
    800051c8:	b3c9                	j	80004f8a <exec+0xa4>
    800051ca:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051ce:	df843583          	ld	a1,-520(s0)
    800051d2:	855a                	mv	a0,s6
    800051d4:	ffffd097          	auipc	ra,0xffffd
    800051d8:	8ca080e7          	jalr	-1846(ra) # 80001a9e <proc_freepagetable>
  if(ip){
    800051dc:	d80a9de3          	bnez	s5,80004f76 <exec+0x90>
  return -1;
    800051e0:	557d                	li	a0,-1
    800051e2:	b365                	j	80004f8a <exec+0xa4>
    800051e4:	df243c23          	sd	s2,-520(s0)
    800051e8:	b7dd                	j	800051ce <exec+0x2e8>
    800051ea:	df243c23          	sd	s2,-520(s0)
    800051ee:	b7c5                	j	800051ce <exec+0x2e8>
    800051f0:	df243c23          	sd	s2,-520(s0)
    800051f4:	bfe9                	j	800051ce <exec+0x2e8>
    800051f6:	df243c23          	sd	s2,-520(s0)
    800051fa:	bfd1                	j	800051ce <exec+0x2e8>
  sz = sz1;
    800051fc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005200:	4a81                	li	s5,0
    80005202:	b7f1                	j	800051ce <exec+0x2e8>
  sz = sz1;
    80005204:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005208:	4a81                	li	s5,0
    8000520a:	b7d1                	j	800051ce <exec+0x2e8>
  sz = sz1;
    8000520c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005210:	4a81                	li	s5,0
    80005212:	bf75                	j	800051ce <exec+0x2e8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005214:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005218:	e0843783          	ld	a5,-504(s0)
    8000521c:	0017869b          	addiw	a3,a5,1
    80005220:	e0d43423          	sd	a3,-504(s0)
    80005224:	e0043783          	ld	a5,-512(s0)
    80005228:	0387879b          	addiw	a5,a5,56
    8000522c:	e8845703          	lhu	a4,-376(s0)
    80005230:	e0e6d9e3          	bge	a3,a4,80005042 <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005234:	2781                	sext.w	a5,a5
    80005236:	e0f43023          	sd	a5,-512(s0)
    8000523a:	03800713          	li	a4,56
    8000523e:	86be                	mv	a3,a5
    80005240:	e1840613          	addi	a2,s0,-488
    80005244:	4581                	li	a1,0
    80005246:	8556                	mv	a0,s5
    80005248:	fffff097          	auipc	ra,0xfffff
    8000524c:	a4a080e7          	jalr	-1462(ra) # 80003c92 <readi>
    80005250:	03800793          	li	a5,56
    80005254:	f6f51be3          	bne	a0,a5,800051ca <exec+0x2e4>
    if(ph.type != ELF_PROG_LOAD)
    80005258:	e1842783          	lw	a5,-488(s0)
    8000525c:	4705                	li	a4,1
    8000525e:	fae79de3          	bne	a5,a4,80005218 <exec+0x332>
    if(ph.memsz < ph.filesz)
    80005262:	e4043483          	ld	s1,-448(s0)
    80005266:	e3843783          	ld	a5,-456(s0)
    8000526a:	f6f4ede3          	bltu	s1,a5,800051e4 <exec+0x2fe>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000526e:	e2843783          	ld	a5,-472(s0)
    80005272:	94be                	add	s1,s1,a5
    80005274:	f6f4ebe3          	bltu	s1,a5,800051ea <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    80005278:	de043703          	ld	a4,-544(s0)
    8000527c:	8ff9                	and	a5,a5,a4
    8000527e:	fbad                	bnez	a5,800051f0 <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005280:	e1c42503          	lw	a0,-484(s0)
    80005284:	00000097          	auipc	ra,0x0
    80005288:	c46080e7          	jalr	-954(ra) # 80004eca <flags2perm>
    8000528c:	86aa                	mv	a3,a0
    8000528e:	8626                	mv	a2,s1
    80005290:	85ca                	mv	a1,s2
    80005292:	855a                	mv	a0,s6
    80005294:	ffffc097          	auipc	ra,0xffffc
    80005298:	17c080e7          	jalr	380(ra) # 80001410 <uvmalloc>
    8000529c:	dea43c23          	sd	a0,-520(s0)
    800052a0:	d939                	beqz	a0,800051f6 <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052a2:	e2843c03          	ld	s8,-472(s0)
    800052a6:	e2042c83          	lw	s9,-480(s0)
    800052aa:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052ae:	f60b83e3          	beqz	s7,80005214 <exec+0x32e>
    800052b2:	89de                	mv	s3,s7
    800052b4:	4481                	li	s1,0
    800052b6:	b3ad                	j	80005020 <exec+0x13a>

00000000800052b8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052b8:	7179                	addi	sp,sp,-48
    800052ba:	f406                	sd	ra,40(sp)
    800052bc:	f022                	sd	s0,32(sp)
    800052be:	ec26                	sd	s1,24(sp)
    800052c0:	e84a                	sd	s2,16(sp)
    800052c2:	1800                	addi	s0,sp,48
    800052c4:	892e                	mv	s2,a1
    800052c6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800052c8:	fdc40593          	addi	a1,s0,-36
    800052cc:	ffffe097          	auipc	ra,0xffffe
    800052d0:	b96080e7          	jalr	-1130(ra) # 80002e62 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052d4:	fdc42703          	lw	a4,-36(s0)
    800052d8:	47bd                	li	a5,15
    800052da:	02e7eb63          	bltu	a5,a4,80005310 <argfd+0x58>
    800052de:	ffffc097          	auipc	ra,0xffffc
    800052e2:	6a2080e7          	jalr	1698(ra) # 80001980 <myproc>
    800052e6:	fdc42703          	lw	a4,-36(s0)
    800052ea:	02070793          	addi	a5,a4,32
    800052ee:	078e                	slli	a5,a5,0x3
    800052f0:	953e                	add	a0,a0,a5
    800052f2:	651c                	ld	a5,8(a0)
    800052f4:	c385                	beqz	a5,80005314 <argfd+0x5c>
    return -1;
  if(pfd)
    800052f6:	00090463          	beqz	s2,800052fe <argfd+0x46>
    *pfd = fd;
    800052fa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052fe:	4501                	li	a0,0
  if(pf)
    80005300:	c091                	beqz	s1,80005304 <argfd+0x4c>
    *pf = f;
    80005302:	e09c                	sd	a5,0(s1)
}
    80005304:	70a2                	ld	ra,40(sp)
    80005306:	7402                	ld	s0,32(sp)
    80005308:	64e2                	ld	s1,24(sp)
    8000530a:	6942                	ld	s2,16(sp)
    8000530c:	6145                	addi	sp,sp,48
    8000530e:	8082                	ret
    return -1;
    80005310:	557d                	li	a0,-1
    80005312:	bfcd                	j	80005304 <argfd+0x4c>
    80005314:	557d                	li	a0,-1
    80005316:	b7fd                	j	80005304 <argfd+0x4c>

0000000080005318 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005318:	1101                	addi	sp,sp,-32
    8000531a:	ec06                	sd	ra,24(sp)
    8000531c:	e822                	sd	s0,16(sp)
    8000531e:	e426                	sd	s1,8(sp)
    80005320:	1000                	addi	s0,sp,32
    80005322:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005324:	ffffc097          	auipc	ra,0xffffc
    80005328:	65c080e7          	jalr	1628(ra) # 80001980 <myproc>
    8000532c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000532e:	10850793          	addi	a5,a0,264
    80005332:	4501                	li	a0,0
    80005334:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005336:	6398                	ld	a4,0(a5)
    80005338:	cb19                	beqz	a4,8000534e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000533a:	2505                	addiw	a0,a0,1
    8000533c:	07a1                	addi	a5,a5,8
    8000533e:	fed51ce3          	bne	a0,a3,80005336 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005342:	557d                	li	a0,-1
}
    80005344:	60e2                	ld	ra,24(sp)
    80005346:	6442                	ld	s0,16(sp)
    80005348:	64a2                	ld	s1,8(sp)
    8000534a:	6105                	addi	sp,sp,32
    8000534c:	8082                	ret
      p->ofile[fd] = f;
    8000534e:	02050793          	addi	a5,a0,32
    80005352:	078e                	slli	a5,a5,0x3
    80005354:	963e                	add	a2,a2,a5
    80005356:	e604                	sd	s1,8(a2)
      return fd;
    80005358:	b7f5                	j	80005344 <fdalloc+0x2c>

000000008000535a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000535a:	715d                	addi	sp,sp,-80
    8000535c:	e486                	sd	ra,72(sp)
    8000535e:	e0a2                	sd	s0,64(sp)
    80005360:	fc26                	sd	s1,56(sp)
    80005362:	f84a                	sd	s2,48(sp)
    80005364:	f44e                	sd	s3,40(sp)
    80005366:	f052                	sd	s4,32(sp)
    80005368:	ec56                	sd	s5,24(sp)
    8000536a:	e85a                	sd	s6,16(sp)
    8000536c:	0880                	addi	s0,sp,80
    8000536e:	8b2e                	mv	s6,a1
    80005370:	89b2                	mv	s3,a2
    80005372:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005374:	fb040593          	addi	a1,s0,-80
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	e2a080e7          	jalr	-470(ra) # 800041a2 <nameiparent>
    80005380:	84aa                	mv	s1,a0
    80005382:	14050f63          	beqz	a0,800054e0 <create+0x186>
    return 0;

  ilock(dp);
    80005386:	ffffe097          	auipc	ra,0xffffe
    8000538a:	658080e7          	jalr	1624(ra) # 800039de <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000538e:	4601                	li	a2,0
    80005390:	fb040593          	addi	a1,s0,-80
    80005394:	8526                	mv	a0,s1
    80005396:	fffff097          	auipc	ra,0xfffff
    8000539a:	b2c080e7          	jalr	-1236(ra) # 80003ec2 <dirlookup>
    8000539e:	8aaa                	mv	s5,a0
    800053a0:	c931                	beqz	a0,800053f4 <create+0x9a>
    iunlockput(dp);
    800053a2:	8526                	mv	a0,s1
    800053a4:	fffff097          	auipc	ra,0xfffff
    800053a8:	89c080e7          	jalr	-1892(ra) # 80003c40 <iunlockput>
    ilock(ip);
    800053ac:	8556                	mv	a0,s5
    800053ae:	ffffe097          	auipc	ra,0xffffe
    800053b2:	630080e7          	jalr	1584(ra) # 800039de <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053b6:	000b059b          	sext.w	a1,s6
    800053ba:	4789                	li	a5,2
    800053bc:	02f59563          	bne	a1,a5,800053e6 <create+0x8c>
    800053c0:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbc44>
    800053c4:	37f9                	addiw	a5,a5,-2
    800053c6:	17c2                	slli	a5,a5,0x30
    800053c8:	93c1                	srli	a5,a5,0x30
    800053ca:	4705                	li	a4,1
    800053cc:	00f76d63          	bltu	a4,a5,800053e6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800053d0:	8556                	mv	a0,s5
    800053d2:	60a6                	ld	ra,72(sp)
    800053d4:	6406                	ld	s0,64(sp)
    800053d6:	74e2                	ld	s1,56(sp)
    800053d8:	7942                	ld	s2,48(sp)
    800053da:	79a2                	ld	s3,40(sp)
    800053dc:	7a02                	ld	s4,32(sp)
    800053de:	6ae2                	ld	s5,24(sp)
    800053e0:	6b42                	ld	s6,16(sp)
    800053e2:	6161                	addi	sp,sp,80
    800053e4:	8082                	ret
    iunlockput(ip);
    800053e6:	8556                	mv	a0,s5
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	858080e7          	jalr	-1960(ra) # 80003c40 <iunlockput>
    return 0;
    800053f0:	4a81                	li	s5,0
    800053f2:	bff9                	j	800053d0 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800053f4:	85da                	mv	a1,s6
    800053f6:	4088                	lw	a0,0(s1)
    800053f8:	ffffe097          	auipc	ra,0xffffe
    800053fc:	44a080e7          	jalr	1098(ra) # 80003842 <ialloc>
    80005400:	8a2a                	mv	s4,a0
    80005402:	c539                	beqz	a0,80005450 <create+0xf6>
  ilock(ip);
    80005404:	ffffe097          	auipc	ra,0xffffe
    80005408:	5da080e7          	jalr	1498(ra) # 800039de <ilock>
  ip->major = major;
    8000540c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005410:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005414:	4905                	li	s2,1
    80005416:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000541a:	8552                	mv	a0,s4
    8000541c:	ffffe097          	auipc	ra,0xffffe
    80005420:	4f8080e7          	jalr	1272(ra) # 80003914 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005424:	000b059b          	sext.w	a1,s6
    80005428:	03258b63          	beq	a1,s2,8000545e <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000542c:	004a2603          	lw	a2,4(s4)
    80005430:	fb040593          	addi	a1,s0,-80
    80005434:	8526                	mv	a0,s1
    80005436:	fffff097          	auipc	ra,0xfffff
    8000543a:	c9c080e7          	jalr	-868(ra) # 800040d2 <dirlink>
    8000543e:	06054f63          	bltz	a0,800054bc <create+0x162>
  iunlockput(dp);
    80005442:	8526                	mv	a0,s1
    80005444:	ffffe097          	auipc	ra,0xffffe
    80005448:	7fc080e7          	jalr	2044(ra) # 80003c40 <iunlockput>
  return ip;
    8000544c:	8ad2                	mv	s5,s4
    8000544e:	b749                	j	800053d0 <create+0x76>
    iunlockput(dp);
    80005450:	8526                	mv	a0,s1
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	7ee080e7          	jalr	2030(ra) # 80003c40 <iunlockput>
    return 0;
    8000545a:	8ad2                	mv	s5,s4
    8000545c:	bf95                	j	800053d0 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000545e:	004a2603          	lw	a2,4(s4)
    80005462:	00003597          	auipc	a1,0x3
    80005466:	32658593          	addi	a1,a1,806 # 80008788 <syscalls+0x2a0>
    8000546a:	8552                	mv	a0,s4
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	c66080e7          	jalr	-922(ra) # 800040d2 <dirlink>
    80005474:	04054463          	bltz	a0,800054bc <create+0x162>
    80005478:	40d0                	lw	a2,4(s1)
    8000547a:	00003597          	auipc	a1,0x3
    8000547e:	31658593          	addi	a1,a1,790 # 80008790 <syscalls+0x2a8>
    80005482:	8552                	mv	a0,s4
    80005484:	fffff097          	auipc	ra,0xfffff
    80005488:	c4e080e7          	jalr	-946(ra) # 800040d2 <dirlink>
    8000548c:	02054863          	bltz	a0,800054bc <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005490:	004a2603          	lw	a2,4(s4)
    80005494:	fb040593          	addi	a1,s0,-80
    80005498:	8526                	mv	a0,s1
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	c38080e7          	jalr	-968(ra) # 800040d2 <dirlink>
    800054a2:	00054d63          	bltz	a0,800054bc <create+0x162>
    dp->nlink++;  // for ".."
    800054a6:	04a4d783          	lhu	a5,74(s1)
    800054aa:	2785                	addiw	a5,a5,1
    800054ac:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054b0:	8526                	mv	a0,s1
    800054b2:	ffffe097          	auipc	ra,0xffffe
    800054b6:	462080e7          	jalr	1122(ra) # 80003914 <iupdate>
    800054ba:	b761                	j	80005442 <create+0xe8>
  ip->nlink = 0;
    800054bc:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800054c0:	8552                	mv	a0,s4
    800054c2:	ffffe097          	auipc	ra,0xffffe
    800054c6:	452080e7          	jalr	1106(ra) # 80003914 <iupdate>
  iunlockput(ip);
    800054ca:	8552                	mv	a0,s4
    800054cc:	ffffe097          	auipc	ra,0xffffe
    800054d0:	774080e7          	jalr	1908(ra) # 80003c40 <iunlockput>
  iunlockput(dp);
    800054d4:	8526                	mv	a0,s1
    800054d6:	ffffe097          	auipc	ra,0xffffe
    800054da:	76a080e7          	jalr	1898(ra) # 80003c40 <iunlockput>
  return 0;
    800054de:	bdcd                	j	800053d0 <create+0x76>
    return 0;
    800054e0:	8aaa                	mv	s5,a0
    800054e2:	b5fd                	j	800053d0 <create+0x76>

00000000800054e4 <sys_dup>:
{
    800054e4:	7179                	addi	sp,sp,-48
    800054e6:	f406                	sd	ra,40(sp)
    800054e8:	f022                	sd	s0,32(sp)
    800054ea:	ec26                	sd	s1,24(sp)
    800054ec:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054ee:	fd840613          	addi	a2,s0,-40
    800054f2:	4581                	li	a1,0
    800054f4:	4501                	li	a0,0
    800054f6:	00000097          	auipc	ra,0x0
    800054fa:	dc2080e7          	jalr	-574(ra) # 800052b8 <argfd>
    return -1;
    800054fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005500:	02054363          	bltz	a0,80005526 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005504:	fd843503          	ld	a0,-40(s0)
    80005508:	00000097          	auipc	ra,0x0
    8000550c:	e10080e7          	jalr	-496(ra) # 80005318 <fdalloc>
    80005510:	84aa                	mv	s1,a0
    return -1;
    80005512:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005514:	00054963          	bltz	a0,80005526 <sys_dup+0x42>
  filedup(f);
    80005518:	fd843503          	ld	a0,-40(s0)
    8000551c:	fffff097          	auipc	ra,0xfffff
    80005520:	2fe080e7          	jalr	766(ra) # 8000481a <filedup>
  return fd;
    80005524:	87a6                	mv	a5,s1
}
    80005526:	853e                	mv	a0,a5
    80005528:	70a2                	ld	ra,40(sp)
    8000552a:	7402                	ld	s0,32(sp)
    8000552c:	64e2                	ld	s1,24(sp)
    8000552e:	6145                	addi	sp,sp,48
    80005530:	8082                	ret

0000000080005532 <sys_read>:
{
    80005532:	7179                	addi	sp,sp,-48
    80005534:	f406                	sd	ra,40(sp)
    80005536:	f022                	sd	s0,32(sp)
    80005538:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000553a:	fd840593          	addi	a1,s0,-40
    8000553e:	4505                	li	a0,1
    80005540:	ffffe097          	auipc	ra,0xffffe
    80005544:	942080e7          	jalr	-1726(ra) # 80002e82 <argaddr>
  argint(2, &n);
    80005548:	fe440593          	addi	a1,s0,-28
    8000554c:	4509                	li	a0,2
    8000554e:	ffffe097          	auipc	ra,0xffffe
    80005552:	914080e7          	jalr	-1772(ra) # 80002e62 <argint>
  if(argfd(0, 0, &f) < 0)
    80005556:	fe840613          	addi	a2,s0,-24
    8000555a:	4581                	li	a1,0
    8000555c:	4501                	li	a0,0
    8000555e:	00000097          	auipc	ra,0x0
    80005562:	d5a080e7          	jalr	-678(ra) # 800052b8 <argfd>
    80005566:	87aa                	mv	a5,a0
    return -1;
    80005568:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000556a:	0007cc63          	bltz	a5,80005582 <sys_read+0x50>
  return fileread(f, p, n);
    8000556e:	fe442603          	lw	a2,-28(s0)
    80005572:	fd843583          	ld	a1,-40(s0)
    80005576:	fe843503          	ld	a0,-24(s0)
    8000557a:	fffff097          	auipc	ra,0xfffff
    8000557e:	42c080e7          	jalr	1068(ra) # 800049a6 <fileread>
}
    80005582:	70a2                	ld	ra,40(sp)
    80005584:	7402                	ld	s0,32(sp)
    80005586:	6145                	addi	sp,sp,48
    80005588:	8082                	ret

000000008000558a <sys_write>:
{
    8000558a:	7179                	addi	sp,sp,-48
    8000558c:	f406                	sd	ra,40(sp)
    8000558e:	f022                	sd	s0,32(sp)
    80005590:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005592:	fd840593          	addi	a1,s0,-40
    80005596:	4505                	li	a0,1
    80005598:	ffffe097          	auipc	ra,0xffffe
    8000559c:	8ea080e7          	jalr	-1814(ra) # 80002e82 <argaddr>
  argint(2, &n);
    800055a0:	fe440593          	addi	a1,s0,-28
    800055a4:	4509                	li	a0,2
    800055a6:	ffffe097          	auipc	ra,0xffffe
    800055aa:	8bc080e7          	jalr	-1860(ra) # 80002e62 <argint>
  if(argfd(0, 0, &f) < 0)
    800055ae:	fe840613          	addi	a2,s0,-24
    800055b2:	4581                	li	a1,0
    800055b4:	4501                	li	a0,0
    800055b6:	00000097          	auipc	ra,0x0
    800055ba:	d02080e7          	jalr	-766(ra) # 800052b8 <argfd>
    800055be:	87aa                	mv	a5,a0
    return -1;
    800055c0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055c2:	0007cc63          	bltz	a5,800055da <sys_write+0x50>
  return filewrite(f, p, n);
    800055c6:	fe442603          	lw	a2,-28(s0)
    800055ca:	fd843583          	ld	a1,-40(s0)
    800055ce:	fe843503          	ld	a0,-24(s0)
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	496080e7          	jalr	1174(ra) # 80004a68 <filewrite>
}
    800055da:	70a2                	ld	ra,40(sp)
    800055dc:	7402                	ld	s0,32(sp)
    800055de:	6145                	addi	sp,sp,48
    800055e0:	8082                	ret

00000000800055e2 <sys_close>:
{
    800055e2:	1101                	addi	sp,sp,-32
    800055e4:	ec06                	sd	ra,24(sp)
    800055e6:	e822                	sd	s0,16(sp)
    800055e8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055ea:	fe040613          	addi	a2,s0,-32
    800055ee:	fec40593          	addi	a1,s0,-20
    800055f2:	4501                	li	a0,0
    800055f4:	00000097          	auipc	ra,0x0
    800055f8:	cc4080e7          	jalr	-828(ra) # 800052b8 <argfd>
    return -1;
    800055fc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055fe:	02054563          	bltz	a0,80005628 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005602:	ffffc097          	auipc	ra,0xffffc
    80005606:	37e080e7          	jalr	894(ra) # 80001980 <myproc>
    8000560a:	fec42783          	lw	a5,-20(s0)
    8000560e:	02078793          	addi	a5,a5,32
    80005612:	078e                	slli	a5,a5,0x3
    80005614:	97aa                	add	a5,a5,a0
    80005616:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000561a:	fe043503          	ld	a0,-32(s0)
    8000561e:	fffff097          	auipc	ra,0xfffff
    80005622:	24e080e7          	jalr	590(ra) # 8000486c <fileclose>
  return 0;
    80005626:	4781                	li	a5,0
}
    80005628:	853e                	mv	a0,a5
    8000562a:	60e2                	ld	ra,24(sp)
    8000562c:	6442                	ld	s0,16(sp)
    8000562e:	6105                	addi	sp,sp,32
    80005630:	8082                	ret

0000000080005632 <sys_fstat>:
{
    80005632:	1101                	addi	sp,sp,-32
    80005634:	ec06                	sd	ra,24(sp)
    80005636:	e822                	sd	s0,16(sp)
    80005638:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000563a:	fe040593          	addi	a1,s0,-32
    8000563e:	4505                	li	a0,1
    80005640:	ffffe097          	auipc	ra,0xffffe
    80005644:	842080e7          	jalr	-1982(ra) # 80002e82 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005648:	fe840613          	addi	a2,s0,-24
    8000564c:	4581                	li	a1,0
    8000564e:	4501                	li	a0,0
    80005650:	00000097          	auipc	ra,0x0
    80005654:	c68080e7          	jalr	-920(ra) # 800052b8 <argfd>
    80005658:	87aa                	mv	a5,a0
    return -1;
    8000565a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000565c:	0007ca63          	bltz	a5,80005670 <sys_fstat+0x3e>
  return filestat(f, st);
    80005660:	fe043583          	ld	a1,-32(s0)
    80005664:	fe843503          	ld	a0,-24(s0)
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	2cc080e7          	jalr	716(ra) # 80004934 <filestat>
}
    80005670:	60e2                	ld	ra,24(sp)
    80005672:	6442                	ld	s0,16(sp)
    80005674:	6105                	addi	sp,sp,32
    80005676:	8082                	ret

0000000080005678 <sys_link>:
{
    80005678:	7169                	addi	sp,sp,-304
    8000567a:	f606                	sd	ra,296(sp)
    8000567c:	f222                	sd	s0,288(sp)
    8000567e:	ee26                	sd	s1,280(sp)
    80005680:	ea4a                	sd	s2,272(sp)
    80005682:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005684:	08000613          	li	a2,128
    80005688:	ed040593          	addi	a1,s0,-304
    8000568c:	4501                	li	a0,0
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	814080e7          	jalr	-2028(ra) # 80002ea2 <argstr>
    return -1;
    80005696:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005698:	10054e63          	bltz	a0,800057b4 <sys_link+0x13c>
    8000569c:	08000613          	li	a2,128
    800056a0:	f5040593          	addi	a1,s0,-176
    800056a4:	4505                	li	a0,1
    800056a6:	ffffd097          	auipc	ra,0xffffd
    800056aa:	7fc080e7          	jalr	2044(ra) # 80002ea2 <argstr>
    return -1;
    800056ae:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056b0:	10054263          	bltz	a0,800057b4 <sys_link+0x13c>
  begin_op();
    800056b4:	fffff097          	auipc	ra,0xfffff
    800056b8:	cec080e7          	jalr	-788(ra) # 800043a0 <begin_op>
  if((ip = namei(old)) == 0){
    800056bc:	ed040513          	addi	a0,s0,-304
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	ac4080e7          	jalr	-1340(ra) # 80004184 <namei>
    800056c8:	84aa                	mv	s1,a0
    800056ca:	c551                	beqz	a0,80005756 <sys_link+0xde>
  ilock(ip);
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	312080e7          	jalr	786(ra) # 800039de <ilock>
  if(ip->type == T_DIR){
    800056d4:	04449703          	lh	a4,68(s1)
    800056d8:	4785                	li	a5,1
    800056da:	08f70463          	beq	a4,a5,80005762 <sys_link+0xea>
  ip->nlink++;
    800056de:	04a4d783          	lhu	a5,74(s1)
    800056e2:	2785                	addiw	a5,a5,1
    800056e4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056e8:	8526                	mv	a0,s1
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	22a080e7          	jalr	554(ra) # 80003914 <iupdate>
  iunlock(ip);
    800056f2:	8526                	mv	a0,s1
    800056f4:	ffffe097          	auipc	ra,0xffffe
    800056f8:	3ac080e7          	jalr	940(ra) # 80003aa0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056fc:	fd040593          	addi	a1,s0,-48
    80005700:	f5040513          	addi	a0,s0,-176
    80005704:	fffff097          	auipc	ra,0xfffff
    80005708:	a9e080e7          	jalr	-1378(ra) # 800041a2 <nameiparent>
    8000570c:	892a                	mv	s2,a0
    8000570e:	c935                	beqz	a0,80005782 <sys_link+0x10a>
  ilock(dp);
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	2ce080e7          	jalr	718(ra) # 800039de <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005718:	00092703          	lw	a4,0(s2)
    8000571c:	409c                	lw	a5,0(s1)
    8000571e:	04f71d63          	bne	a4,a5,80005778 <sys_link+0x100>
    80005722:	40d0                	lw	a2,4(s1)
    80005724:	fd040593          	addi	a1,s0,-48
    80005728:	854a                	mv	a0,s2
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	9a8080e7          	jalr	-1624(ra) # 800040d2 <dirlink>
    80005732:	04054363          	bltz	a0,80005778 <sys_link+0x100>
  iunlockput(dp);
    80005736:	854a                	mv	a0,s2
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	508080e7          	jalr	1288(ra) # 80003c40 <iunlockput>
  iput(ip);
    80005740:	8526                	mv	a0,s1
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	456080e7          	jalr	1110(ra) # 80003b98 <iput>
  end_op();
    8000574a:	fffff097          	auipc	ra,0xfffff
    8000574e:	cd6080e7          	jalr	-810(ra) # 80004420 <end_op>
  return 0;
    80005752:	4781                	li	a5,0
    80005754:	a085                	j	800057b4 <sys_link+0x13c>
    end_op();
    80005756:	fffff097          	auipc	ra,0xfffff
    8000575a:	cca080e7          	jalr	-822(ra) # 80004420 <end_op>
    return -1;
    8000575e:	57fd                	li	a5,-1
    80005760:	a891                	j	800057b4 <sys_link+0x13c>
    iunlockput(ip);
    80005762:	8526                	mv	a0,s1
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	4dc080e7          	jalr	1244(ra) # 80003c40 <iunlockput>
    end_op();
    8000576c:	fffff097          	auipc	ra,0xfffff
    80005770:	cb4080e7          	jalr	-844(ra) # 80004420 <end_op>
    return -1;
    80005774:	57fd                	li	a5,-1
    80005776:	a83d                	j	800057b4 <sys_link+0x13c>
    iunlockput(dp);
    80005778:	854a                	mv	a0,s2
    8000577a:	ffffe097          	auipc	ra,0xffffe
    8000577e:	4c6080e7          	jalr	1222(ra) # 80003c40 <iunlockput>
  ilock(ip);
    80005782:	8526                	mv	a0,s1
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	25a080e7          	jalr	602(ra) # 800039de <ilock>
  ip->nlink--;
    8000578c:	04a4d783          	lhu	a5,74(s1)
    80005790:	37fd                	addiw	a5,a5,-1
    80005792:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005796:	8526                	mv	a0,s1
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	17c080e7          	jalr	380(ra) # 80003914 <iupdate>
  iunlockput(ip);
    800057a0:	8526                	mv	a0,s1
    800057a2:	ffffe097          	auipc	ra,0xffffe
    800057a6:	49e080e7          	jalr	1182(ra) # 80003c40 <iunlockput>
  end_op();
    800057aa:	fffff097          	auipc	ra,0xfffff
    800057ae:	c76080e7          	jalr	-906(ra) # 80004420 <end_op>
  return -1;
    800057b2:	57fd                	li	a5,-1
}
    800057b4:	853e                	mv	a0,a5
    800057b6:	70b2                	ld	ra,296(sp)
    800057b8:	7412                	ld	s0,288(sp)
    800057ba:	64f2                	ld	s1,280(sp)
    800057bc:	6952                	ld	s2,272(sp)
    800057be:	6155                	addi	sp,sp,304
    800057c0:	8082                	ret

00000000800057c2 <sys_unlink>:
{
    800057c2:	7151                	addi	sp,sp,-240
    800057c4:	f586                	sd	ra,232(sp)
    800057c6:	f1a2                	sd	s0,224(sp)
    800057c8:	eda6                	sd	s1,216(sp)
    800057ca:	e9ca                	sd	s2,208(sp)
    800057cc:	e5ce                	sd	s3,200(sp)
    800057ce:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057d0:	08000613          	li	a2,128
    800057d4:	f3040593          	addi	a1,s0,-208
    800057d8:	4501                	li	a0,0
    800057da:	ffffd097          	auipc	ra,0xffffd
    800057de:	6c8080e7          	jalr	1736(ra) # 80002ea2 <argstr>
    800057e2:	18054163          	bltz	a0,80005964 <sys_unlink+0x1a2>
  begin_op();
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	bba080e7          	jalr	-1094(ra) # 800043a0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057ee:	fb040593          	addi	a1,s0,-80
    800057f2:	f3040513          	addi	a0,s0,-208
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	9ac080e7          	jalr	-1620(ra) # 800041a2 <nameiparent>
    800057fe:	84aa                	mv	s1,a0
    80005800:	c979                	beqz	a0,800058d6 <sys_unlink+0x114>
  ilock(dp);
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	1dc080e7          	jalr	476(ra) # 800039de <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000580a:	00003597          	auipc	a1,0x3
    8000580e:	f7e58593          	addi	a1,a1,-130 # 80008788 <syscalls+0x2a0>
    80005812:	fb040513          	addi	a0,s0,-80
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	692080e7          	jalr	1682(ra) # 80003ea8 <namecmp>
    8000581e:	14050a63          	beqz	a0,80005972 <sys_unlink+0x1b0>
    80005822:	00003597          	auipc	a1,0x3
    80005826:	f6e58593          	addi	a1,a1,-146 # 80008790 <syscalls+0x2a8>
    8000582a:	fb040513          	addi	a0,s0,-80
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	67a080e7          	jalr	1658(ra) # 80003ea8 <namecmp>
    80005836:	12050e63          	beqz	a0,80005972 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000583a:	f2c40613          	addi	a2,s0,-212
    8000583e:	fb040593          	addi	a1,s0,-80
    80005842:	8526                	mv	a0,s1
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	67e080e7          	jalr	1662(ra) # 80003ec2 <dirlookup>
    8000584c:	892a                	mv	s2,a0
    8000584e:	12050263          	beqz	a0,80005972 <sys_unlink+0x1b0>
  ilock(ip);
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	18c080e7          	jalr	396(ra) # 800039de <ilock>
  if(ip->nlink < 1)
    8000585a:	04a91783          	lh	a5,74(s2)
    8000585e:	08f05263          	blez	a5,800058e2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005862:	04491703          	lh	a4,68(s2)
    80005866:	4785                	li	a5,1
    80005868:	08f70563          	beq	a4,a5,800058f2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000586c:	4641                	li	a2,16
    8000586e:	4581                	li	a1,0
    80005870:	fc040513          	addi	a0,s0,-64
    80005874:	ffffb097          	auipc	ra,0xffffb
    80005878:	45e080e7          	jalr	1118(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000587c:	4741                	li	a4,16
    8000587e:	f2c42683          	lw	a3,-212(s0)
    80005882:	fc040613          	addi	a2,s0,-64
    80005886:	4581                	li	a1,0
    80005888:	8526                	mv	a0,s1
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	500080e7          	jalr	1280(ra) # 80003d8a <writei>
    80005892:	47c1                	li	a5,16
    80005894:	0af51563          	bne	a0,a5,8000593e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005898:	04491703          	lh	a4,68(s2)
    8000589c:	4785                	li	a5,1
    8000589e:	0af70863          	beq	a4,a5,8000594e <sys_unlink+0x18c>
  iunlockput(dp);
    800058a2:	8526                	mv	a0,s1
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	39c080e7          	jalr	924(ra) # 80003c40 <iunlockput>
  ip->nlink--;
    800058ac:	04a95783          	lhu	a5,74(s2)
    800058b0:	37fd                	addiw	a5,a5,-1
    800058b2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058b6:	854a                	mv	a0,s2
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	05c080e7          	jalr	92(ra) # 80003914 <iupdate>
  iunlockput(ip);
    800058c0:	854a                	mv	a0,s2
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	37e080e7          	jalr	894(ra) # 80003c40 <iunlockput>
  end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	b56080e7          	jalr	-1194(ra) # 80004420 <end_op>
  return 0;
    800058d2:	4501                	li	a0,0
    800058d4:	a84d                	j	80005986 <sys_unlink+0x1c4>
    end_op();
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	b4a080e7          	jalr	-1206(ra) # 80004420 <end_op>
    return -1;
    800058de:	557d                	li	a0,-1
    800058e0:	a05d                	j	80005986 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800058e2:	00003517          	auipc	a0,0x3
    800058e6:	eb650513          	addi	a0,a0,-330 # 80008798 <syscalls+0x2b0>
    800058ea:	ffffb097          	auipc	ra,0xffffb
    800058ee:	c54080e7          	jalr	-940(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058f2:	04c92703          	lw	a4,76(s2)
    800058f6:	02000793          	li	a5,32
    800058fa:	f6e7f9e3          	bgeu	a5,a4,8000586c <sys_unlink+0xaa>
    800058fe:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005902:	4741                	li	a4,16
    80005904:	86ce                	mv	a3,s3
    80005906:	f1840613          	addi	a2,s0,-232
    8000590a:	4581                	li	a1,0
    8000590c:	854a                	mv	a0,s2
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	384080e7          	jalr	900(ra) # 80003c92 <readi>
    80005916:	47c1                	li	a5,16
    80005918:	00f51b63          	bne	a0,a5,8000592e <sys_unlink+0x16c>
    if(de.inum != 0)
    8000591c:	f1845783          	lhu	a5,-232(s0)
    80005920:	e7a1                	bnez	a5,80005968 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005922:	29c1                	addiw	s3,s3,16
    80005924:	04c92783          	lw	a5,76(s2)
    80005928:	fcf9ede3          	bltu	s3,a5,80005902 <sys_unlink+0x140>
    8000592c:	b781                	j	8000586c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000592e:	00003517          	auipc	a0,0x3
    80005932:	e8250513          	addi	a0,a0,-382 # 800087b0 <syscalls+0x2c8>
    80005936:	ffffb097          	auipc	ra,0xffffb
    8000593a:	c08080e7          	jalr	-1016(ra) # 8000053e <panic>
    panic("unlink: writei");
    8000593e:	00003517          	auipc	a0,0x3
    80005942:	e8a50513          	addi	a0,a0,-374 # 800087c8 <syscalls+0x2e0>
    80005946:	ffffb097          	auipc	ra,0xffffb
    8000594a:	bf8080e7          	jalr	-1032(ra) # 8000053e <panic>
    dp->nlink--;
    8000594e:	04a4d783          	lhu	a5,74(s1)
    80005952:	37fd                	addiw	a5,a5,-1
    80005954:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005958:	8526                	mv	a0,s1
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	fba080e7          	jalr	-70(ra) # 80003914 <iupdate>
    80005962:	b781                	j	800058a2 <sys_unlink+0xe0>
    return -1;
    80005964:	557d                	li	a0,-1
    80005966:	a005                	j	80005986 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005968:	854a                	mv	a0,s2
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	2d6080e7          	jalr	726(ra) # 80003c40 <iunlockput>
  iunlockput(dp);
    80005972:	8526                	mv	a0,s1
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	2cc080e7          	jalr	716(ra) # 80003c40 <iunlockput>
  end_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	aa4080e7          	jalr	-1372(ra) # 80004420 <end_op>
  return -1;
    80005984:	557d                	li	a0,-1
}
    80005986:	70ae                	ld	ra,232(sp)
    80005988:	740e                	ld	s0,224(sp)
    8000598a:	64ee                	ld	s1,216(sp)
    8000598c:	694e                	ld	s2,208(sp)
    8000598e:	69ae                	ld	s3,200(sp)
    80005990:	616d                	addi	sp,sp,240
    80005992:	8082                	ret

0000000080005994 <sys_open>:

uint64
sys_open(void)
{
    80005994:	7131                	addi	sp,sp,-192
    80005996:	fd06                	sd	ra,184(sp)
    80005998:	f922                	sd	s0,176(sp)
    8000599a:	f526                	sd	s1,168(sp)
    8000599c:	f14a                	sd	s2,160(sp)
    8000599e:	ed4e                	sd	s3,152(sp)
    800059a0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800059a2:	f4c40593          	addi	a1,s0,-180
    800059a6:	4505                	li	a0,1
    800059a8:	ffffd097          	auipc	ra,0xffffd
    800059ac:	4ba080e7          	jalr	1210(ra) # 80002e62 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059b0:	08000613          	li	a2,128
    800059b4:	f5040593          	addi	a1,s0,-176
    800059b8:	4501                	li	a0,0
    800059ba:	ffffd097          	auipc	ra,0xffffd
    800059be:	4e8080e7          	jalr	1256(ra) # 80002ea2 <argstr>
    800059c2:	87aa                	mv	a5,a0
    return -1;
    800059c4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059c6:	0a07c963          	bltz	a5,80005a78 <sys_open+0xe4>

  begin_op();
    800059ca:	fffff097          	auipc	ra,0xfffff
    800059ce:	9d6080e7          	jalr	-1578(ra) # 800043a0 <begin_op>

  if(omode & O_CREATE){
    800059d2:	f4c42783          	lw	a5,-180(s0)
    800059d6:	2007f793          	andi	a5,a5,512
    800059da:	cfc5                	beqz	a5,80005a92 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800059dc:	4681                	li	a3,0
    800059de:	4601                	li	a2,0
    800059e0:	4589                	li	a1,2
    800059e2:	f5040513          	addi	a0,s0,-176
    800059e6:	00000097          	auipc	ra,0x0
    800059ea:	974080e7          	jalr	-1676(ra) # 8000535a <create>
    800059ee:	84aa                	mv	s1,a0
    if(ip == 0){
    800059f0:	c959                	beqz	a0,80005a86 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800059f2:	04449703          	lh	a4,68(s1)
    800059f6:	478d                	li	a5,3
    800059f8:	00f71763          	bne	a4,a5,80005a06 <sys_open+0x72>
    800059fc:	0464d703          	lhu	a4,70(s1)
    80005a00:	47a5                	li	a5,9
    80005a02:	0ce7ed63          	bltu	a5,a4,80005adc <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	daa080e7          	jalr	-598(ra) # 800047b0 <filealloc>
    80005a0e:	89aa                	mv	s3,a0
    80005a10:	10050363          	beqz	a0,80005b16 <sys_open+0x182>
    80005a14:	00000097          	auipc	ra,0x0
    80005a18:	904080e7          	jalr	-1788(ra) # 80005318 <fdalloc>
    80005a1c:	892a                	mv	s2,a0
    80005a1e:	0e054763          	bltz	a0,80005b0c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a22:	04449703          	lh	a4,68(s1)
    80005a26:	478d                	li	a5,3
    80005a28:	0cf70563          	beq	a4,a5,80005af2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a2c:	4789                	li	a5,2
    80005a2e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a32:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a36:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a3a:	f4c42783          	lw	a5,-180(s0)
    80005a3e:	0017c713          	xori	a4,a5,1
    80005a42:	8b05                	andi	a4,a4,1
    80005a44:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a48:	0037f713          	andi	a4,a5,3
    80005a4c:	00e03733          	snez	a4,a4
    80005a50:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a54:	4007f793          	andi	a5,a5,1024
    80005a58:	c791                	beqz	a5,80005a64 <sys_open+0xd0>
    80005a5a:	04449703          	lh	a4,68(s1)
    80005a5e:	4789                	li	a5,2
    80005a60:	0af70063          	beq	a4,a5,80005b00 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a64:	8526                	mv	a0,s1
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	03a080e7          	jalr	58(ra) # 80003aa0 <iunlock>
  end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	9b2080e7          	jalr	-1614(ra) # 80004420 <end_op>

  return fd;
    80005a76:	854a                	mv	a0,s2
}
    80005a78:	70ea                	ld	ra,184(sp)
    80005a7a:	744a                	ld	s0,176(sp)
    80005a7c:	74aa                	ld	s1,168(sp)
    80005a7e:	790a                	ld	s2,160(sp)
    80005a80:	69ea                	ld	s3,152(sp)
    80005a82:	6129                	addi	sp,sp,192
    80005a84:	8082                	ret
      end_op();
    80005a86:	fffff097          	auipc	ra,0xfffff
    80005a8a:	99a080e7          	jalr	-1638(ra) # 80004420 <end_op>
      return -1;
    80005a8e:	557d                	li	a0,-1
    80005a90:	b7e5                	j	80005a78 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a92:	f5040513          	addi	a0,s0,-176
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	6ee080e7          	jalr	1774(ra) # 80004184 <namei>
    80005a9e:	84aa                	mv	s1,a0
    80005aa0:	c905                	beqz	a0,80005ad0 <sys_open+0x13c>
    ilock(ip);
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	f3c080e7          	jalr	-196(ra) # 800039de <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005aaa:	04449703          	lh	a4,68(s1)
    80005aae:	4785                	li	a5,1
    80005ab0:	f4f711e3          	bne	a4,a5,800059f2 <sys_open+0x5e>
    80005ab4:	f4c42783          	lw	a5,-180(s0)
    80005ab8:	d7b9                	beqz	a5,80005a06 <sys_open+0x72>
      iunlockput(ip);
    80005aba:	8526                	mv	a0,s1
    80005abc:	ffffe097          	auipc	ra,0xffffe
    80005ac0:	184080e7          	jalr	388(ra) # 80003c40 <iunlockput>
      end_op();
    80005ac4:	fffff097          	auipc	ra,0xfffff
    80005ac8:	95c080e7          	jalr	-1700(ra) # 80004420 <end_op>
      return -1;
    80005acc:	557d                	li	a0,-1
    80005ace:	b76d                	j	80005a78 <sys_open+0xe4>
      end_op();
    80005ad0:	fffff097          	auipc	ra,0xfffff
    80005ad4:	950080e7          	jalr	-1712(ra) # 80004420 <end_op>
      return -1;
    80005ad8:	557d                	li	a0,-1
    80005ada:	bf79                	j	80005a78 <sys_open+0xe4>
    iunlockput(ip);
    80005adc:	8526                	mv	a0,s1
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	162080e7          	jalr	354(ra) # 80003c40 <iunlockput>
    end_op();
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	93a080e7          	jalr	-1734(ra) # 80004420 <end_op>
    return -1;
    80005aee:	557d                	li	a0,-1
    80005af0:	b761                	j	80005a78 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005af2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005af6:	04649783          	lh	a5,70(s1)
    80005afa:	02f99223          	sh	a5,36(s3)
    80005afe:	bf25                	j	80005a36 <sys_open+0xa2>
    itrunc(ip);
    80005b00:	8526                	mv	a0,s1
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	fea080e7          	jalr	-22(ra) # 80003aec <itrunc>
    80005b0a:	bfa9                	j	80005a64 <sys_open+0xd0>
      fileclose(f);
    80005b0c:	854e                	mv	a0,s3
    80005b0e:	fffff097          	auipc	ra,0xfffff
    80005b12:	d5e080e7          	jalr	-674(ra) # 8000486c <fileclose>
    iunlockput(ip);
    80005b16:	8526                	mv	a0,s1
    80005b18:	ffffe097          	auipc	ra,0xffffe
    80005b1c:	128080e7          	jalr	296(ra) # 80003c40 <iunlockput>
    end_op();
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	900080e7          	jalr	-1792(ra) # 80004420 <end_op>
    return -1;
    80005b28:	557d                	li	a0,-1
    80005b2a:	b7b9                	j	80005a78 <sys_open+0xe4>

0000000080005b2c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b2c:	7175                	addi	sp,sp,-144
    80005b2e:	e506                	sd	ra,136(sp)
    80005b30:	e122                	sd	s0,128(sp)
    80005b32:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	86c080e7          	jalr	-1940(ra) # 800043a0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b3c:	08000613          	li	a2,128
    80005b40:	f7040593          	addi	a1,s0,-144
    80005b44:	4501                	li	a0,0
    80005b46:	ffffd097          	auipc	ra,0xffffd
    80005b4a:	35c080e7          	jalr	860(ra) # 80002ea2 <argstr>
    80005b4e:	02054963          	bltz	a0,80005b80 <sys_mkdir+0x54>
    80005b52:	4681                	li	a3,0
    80005b54:	4601                	li	a2,0
    80005b56:	4585                	li	a1,1
    80005b58:	f7040513          	addi	a0,s0,-144
    80005b5c:	fffff097          	auipc	ra,0xfffff
    80005b60:	7fe080e7          	jalr	2046(ra) # 8000535a <create>
    80005b64:	cd11                	beqz	a0,80005b80 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	0da080e7          	jalr	218(ra) # 80003c40 <iunlockput>
  end_op();
    80005b6e:	fffff097          	auipc	ra,0xfffff
    80005b72:	8b2080e7          	jalr	-1870(ra) # 80004420 <end_op>
  return 0;
    80005b76:	4501                	li	a0,0
}
    80005b78:	60aa                	ld	ra,136(sp)
    80005b7a:	640a                	ld	s0,128(sp)
    80005b7c:	6149                	addi	sp,sp,144
    80005b7e:	8082                	ret
    end_op();
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	8a0080e7          	jalr	-1888(ra) # 80004420 <end_op>
    return -1;
    80005b88:	557d                	li	a0,-1
    80005b8a:	b7fd                	j	80005b78 <sys_mkdir+0x4c>

0000000080005b8c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b8c:	7135                	addi	sp,sp,-160
    80005b8e:	ed06                	sd	ra,152(sp)
    80005b90:	e922                	sd	s0,144(sp)
    80005b92:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b94:	fffff097          	auipc	ra,0xfffff
    80005b98:	80c080e7          	jalr	-2036(ra) # 800043a0 <begin_op>
  argint(1, &major);
    80005b9c:	f6c40593          	addi	a1,s0,-148
    80005ba0:	4505                	li	a0,1
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	2c0080e7          	jalr	704(ra) # 80002e62 <argint>
  argint(2, &minor);
    80005baa:	f6840593          	addi	a1,s0,-152
    80005bae:	4509                	li	a0,2
    80005bb0:	ffffd097          	auipc	ra,0xffffd
    80005bb4:	2b2080e7          	jalr	690(ra) # 80002e62 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bb8:	08000613          	li	a2,128
    80005bbc:	f7040593          	addi	a1,s0,-144
    80005bc0:	4501                	li	a0,0
    80005bc2:	ffffd097          	auipc	ra,0xffffd
    80005bc6:	2e0080e7          	jalr	736(ra) # 80002ea2 <argstr>
    80005bca:	02054b63          	bltz	a0,80005c00 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005bce:	f6841683          	lh	a3,-152(s0)
    80005bd2:	f6c41603          	lh	a2,-148(s0)
    80005bd6:	458d                	li	a1,3
    80005bd8:	f7040513          	addi	a0,s0,-144
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	77e080e7          	jalr	1918(ra) # 8000535a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005be4:	cd11                	beqz	a0,80005c00 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005be6:	ffffe097          	auipc	ra,0xffffe
    80005bea:	05a080e7          	jalr	90(ra) # 80003c40 <iunlockput>
  end_op();
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	832080e7          	jalr	-1998(ra) # 80004420 <end_op>
  return 0;
    80005bf6:	4501                	li	a0,0
}
    80005bf8:	60ea                	ld	ra,152(sp)
    80005bfa:	644a                	ld	s0,144(sp)
    80005bfc:	610d                	addi	sp,sp,160
    80005bfe:	8082                	ret
    end_op();
    80005c00:	fffff097          	auipc	ra,0xfffff
    80005c04:	820080e7          	jalr	-2016(ra) # 80004420 <end_op>
    return -1;
    80005c08:	557d                	li	a0,-1
    80005c0a:	b7fd                	j	80005bf8 <sys_mknod+0x6c>

0000000080005c0c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c0c:	7135                	addi	sp,sp,-160
    80005c0e:	ed06                	sd	ra,152(sp)
    80005c10:	e922                	sd	s0,144(sp)
    80005c12:	e526                	sd	s1,136(sp)
    80005c14:	e14a                	sd	s2,128(sp)
    80005c16:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c18:	ffffc097          	auipc	ra,0xffffc
    80005c1c:	d68080e7          	jalr	-664(ra) # 80001980 <myproc>
    80005c20:	892a                	mv	s2,a0
  
  begin_op();
    80005c22:	ffffe097          	auipc	ra,0xffffe
    80005c26:	77e080e7          	jalr	1918(ra) # 800043a0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c2a:	08000613          	li	a2,128
    80005c2e:	f6040593          	addi	a1,s0,-160
    80005c32:	4501                	li	a0,0
    80005c34:	ffffd097          	auipc	ra,0xffffd
    80005c38:	26e080e7          	jalr	622(ra) # 80002ea2 <argstr>
    80005c3c:	04054b63          	bltz	a0,80005c92 <sys_chdir+0x86>
    80005c40:	f6040513          	addi	a0,s0,-160
    80005c44:	ffffe097          	auipc	ra,0xffffe
    80005c48:	540080e7          	jalr	1344(ra) # 80004184 <namei>
    80005c4c:	84aa                	mv	s1,a0
    80005c4e:	c131                	beqz	a0,80005c92 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c50:	ffffe097          	auipc	ra,0xffffe
    80005c54:	d8e080e7          	jalr	-626(ra) # 800039de <ilock>
  if(ip->type != T_DIR){
    80005c58:	04449703          	lh	a4,68(s1)
    80005c5c:	4785                	li	a5,1
    80005c5e:	04f71063          	bne	a4,a5,80005c9e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c62:	8526                	mv	a0,s1
    80005c64:	ffffe097          	auipc	ra,0xffffe
    80005c68:	e3c080e7          	jalr	-452(ra) # 80003aa0 <iunlock>
  iput(p->cwd);
    80005c6c:	18893503          	ld	a0,392(s2)
    80005c70:	ffffe097          	auipc	ra,0xffffe
    80005c74:	f28080e7          	jalr	-216(ra) # 80003b98 <iput>
  end_op();
    80005c78:	ffffe097          	auipc	ra,0xffffe
    80005c7c:	7a8080e7          	jalr	1960(ra) # 80004420 <end_op>
  p->cwd = ip;
    80005c80:	18993423          	sd	s1,392(s2)
  return 0;
    80005c84:	4501                	li	a0,0
}
    80005c86:	60ea                	ld	ra,152(sp)
    80005c88:	644a                	ld	s0,144(sp)
    80005c8a:	64aa                	ld	s1,136(sp)
    80005c8c:	690a                	ld	s2,128(sp)
    80005c8e:	610d                	addi	sp,sp,160
    80005c90:	8082                	ret
    end_op();
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	78e080e7          	jalr	1934(ra) # 80004420 <end_op>
    return -1;
    80005c9a:	557d                	li	a0,-1
    80005c9c:	b7ed                	j	80005c86 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c9e:	8526                	mv	a0,s1
    80005ca0:	ffffe097          	auipc	ra,0xffffe
    80005ca4:	fa0080e7          	jalr	-96(ra) # 80003c40 <iunlockput>
    end_op();
    80005ca8:	ffffe097          	auipc	ra,0xffffe
    80005cac:	778080e7          	jalr	1912(ra) # 80004420 <end_op>
    return -1;
    80005cb0:	557d                	li	a0,-1
    80005cb2:	bfd1                	j	80005c86 <sys_chdir+0x7a>

0000000080005cb4 <sys_exec>:

uint64
sys_exec(void)
{
    80005cb4:	7145                	addi	sp,sp,-464
    80005cb6:	e786                	sd	ra,456(sp)
    80005cb8:	e3a2                	sd	s0,448(sp)
    80005cba:	ff26                	sd	s1,440(sp)
    80005cbc:	fb4a                	sd	s2,432(sp)
    80005cbe:	f74e                	sd	s3,424(sp)
    80005cc0:	f352                	sd	s4,416(sp)
    80005cc2:	ef56                	sd	s5,408(sp)
    80005cc4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cc6:	e3840593          	addi	a1,s0,-456
    80005cca:	4505                	li	a0,1
    80005ccc:	ffffd097          	auipc	ra,0xffffd
    80005cd0:	1b6080e7          	jalr	438(ra) # 80002e82 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005cd4:	08000613          	li	a2,128
    80005cd8:	f4040593          	addi	a1,s0,-192
    80005cdc:	4501                	li	a0,0
    80005cde:	ffffd097          	auipc	ra,0xffffd
    80005ce2:	1c4080e7          	jalr	452(ra) # 80002ea2 <argstr>
    80005ce6:	87aa                	mv	a5,a0
    return -1;
    80005ce8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005cea:	0c07c263          	bltz	a5,80005dae <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005cee:	10000613          	li	a2,256
    80005cf2:	4581                	li	a1,0
    80005cf4:	e4040513          	addi	a0,s0,-448
    80005cf8:	ffffb097          	auipc	ra,0xffffb
    80005cfc:	fda080e7          	jalr	-38(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d00:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d04:	89a6                	mv	s3,s1
    80005d06:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d08:	02000a13          	li	s4,32
    80005d0c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d10:	00391793          	slli	a5,s2,0x3
    80005d14:	e3040593          	addi	a1,s0,-464
    80005d18:	e3843503          	ld	a0,-456(s0)
    80005d1c:	953e                	add	a0,a0,a5
    80005d1e:	ffffd097          	auipc	ra,0xffffd
    80005d22:	0a2080e7          	jalr	162(ra) # 80002dc0 <fetchaddr>
    80005d26:	02054a63          	bltz	a0,80005d5a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005d2a:	e3043783          	ld	a5,-464(s0)
    80005d2e:	c3b9                	beqz	a5,80005d74 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d30:	ffffb097          	auipc	ra,0xffffb
    80005d34:	db6080e7          	jalr	-586(ra) # 80000ae6 <kalloc>
    80005d38:	85aa                	mv	a1,a0
    80005d3a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d3e:	cd11                	beqz	a0,80005d5a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d40:	6605                	lui	a2,0x1
    80005d42:	e3043503          	ld	a0,-464(s0)
    80005d46:	ffffd097          	auipc	ra,0xffffd
    80005d4a:	0ce080e7          	jalr	206(ra) # 80002e14 <fetchstr>
    80005d4e:	00054663          	bltz	a0,80005d5a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005d52:	0905                	addi	s2,s2,1
    80005d54:	09a1                	addi	s3,s3,8
    80005d56:	fb491be3          	bne	s2,s4,80005d0c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d5a:	10048913          	addi	s2,s1,256
    80005d5e:	6088                	ld	a0,0(s1)
    80005d60:	c531                	beqz	a0,80005dac <sys_exec+0xf8>
    kfree(argv[i]);
    80005d62:	ffffb097          	auipc	ra,0xffffb
    80005d66:	c88080e7          	jalr	-888(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d6a:	04a1                	addi	s1,s1,8
    80005d6c:	ff2499e3          	bne	s1,s2,80005d5e <sys_exec+0xaa>
  return -1;
    80005d70:	557d                	li	a0,-1
    80005d72:	a835                	j	80005dae <sys_exec+0xfa>
      argv[i] = 0;
    80005d74:	0a8e                	slli	s5,s5,0x3
    80005d76:	fc040793          	addi	a5,s0,-64
    80005d7a:	9abe                	add	s5,s5,a5
    80005d7c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d80:	e4040593          	addi	a1,s0,-448
    80005d84:	f4040513          	addi	a0,s0,-192
    80005d88:	fffff097          	auipc	ra,0xfffff
    80005d8c:	15e080e7          	jalr	350(ra) # 80004ee6 <exec>
    80005d90:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d92:	10048993          	addi	s3,s1,256
    80005d96:	6088                	ld	a0,0(s1)
    80005d98:	c901                	beqz	a0,80005da8 <sys_exec+0xf4>
    kfree(argv[i]);
    80005d9a:	ffffb097          	auipc	ra,0xffffb
    80005d9e:	c50080e7          	jalr	-944(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005da2:	04a1                	addi	s1,s1,8
    80005da4:	ff3499e3          	bne	s1,s3,80005d96 <sys_exec+0xe2>
  return ret;
    80005da8:	854a                	mv	a0,s2
    80005daa:	a011                	j	80005dae <sys_exec+0xfa>
  return -1;
    80005dac:	557d                	li	a0,-1
}
    80005dae:	60be                	ld	ra,456(sp)
    80005db0:	641e                	ld	s0,448(sp)
    80005db2:	74fa                	ld	s1,440(sp)
    80005db4:	795a                	ld	s2,432(sp)
    80005db6:	79ba                	ld	s3,424(sp)
    80005db8:	7a1a                	ld	s4,416(sp)
    80005dba:	6afa                	ld	s5,408(sp)
    80005dbc:	6179                	addi	sp,sp,464
    80005dbe:	8082                	ret

0000000080005dc0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005dc0:	7139                	addi	sp,sp,-64
    80005dc2:	fc06                	sd	ra,56(sp)
    80005dc4:	f822                	sd	s0,48(sp)
    80005dc6:	f426                	sd	s1,40(sp)
    80005dc8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dca:	ffffc097          	auipc	ra,0xffffc
    80005dce:	bb6080e7          	jalr	-1098(ra) # 80001980 <myproc>
    80005dd2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005dd4:	fd840593          	addi	a1,s0,-40
    80005dd8:	4501                	li	a0,0
    80005dda:	ffffd097          	auipc	ra,0xffffd
    80005dde:	0a8080e7          	jalr	168(ra) # 80002e82 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005de2:	fc840593          	addi	a1,s0,-56
    80005de6:	fd040513          	addi	a0,s0,-48
    80005dea:	fffff097          	auipc	ra,0xfffff
    80005dee:	db2080e7          	jalr	-590(ra) # 80004b9c <pipealloc>
    return -1;
    80005df2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005df4:	0c054963          	bltz	a0,80005ec6 <sys_pipe+0x106>
  fd0 = -1;
    80005df8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005dfc:	fd043503          	ld	a0,-48(s0)
    80005e00:	fffff097          	auipc	ra,0xfffff
    80005e04:	518080e7          	jalr	1304(ra) # 80005318 <fdalloc>
    80005e08:	fca42223          	sw	a0,-60(s0)
    80005e0c:	0a054063          	bltz	a0,80005eac <sys_pipe+0xec>
    80005e10:	fc843503          	ld	a0,-56(s0)
    80005e14:	fffff097          	auipc	ra,0xfffff
    80005e18:	504080e7          	jalr	1284(ra) # 80005318 <fdalloc>
    80005e1c:	fca42023          	sw	a0,-64(s0)
    80005e20:	06054c63          	bltz	a0,80005e98 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e24:	4691                	li	a3,4
    80005e26:	fc440613          	addi	a2,s0,-60
    80005e2a:	fd843583          	ld	a1,-40(s0)
    80005e2e:	1004b503          	ld	a0,256(s1)
    80005e32:	ffffc097          	auipc	ra,0xffffc
    80005e36:	836080e7          	jalr	-1994(ra) # 80001668 <copyout>
    80005e3a:	02054163          	bltz	a0,80005e5c <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e3e:	4691                	li	a3,4
    80005e40:	fc040613          	addi	a2,s0,-64
    80005e44:	fd843583          	ld	a1,-40(s0)
    80005e48:	0591                	addi	a1,a1,4
    80005e4a:	1004b503          	ld	a0,256(s1)
    80005e4e:	ffffc097          	auipc	ra,0xffffc
    80005e52:	81a080e7          	jalr	-2022(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e56:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e58:	06055763          	bgez	a0,80005ec6 <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80005e5c:	fc442783          	lw	a5,-60(s0)
    80005e60:	02078793          	addi	a5,a5,32
    80005e64:	078e                	slli	a5,a5,0x3
    80005e66:	97a6                	add	a5,a5,s1
    80005e68:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e6c:	fc042503          	lw	a0,-64(s0)
    80005e70:	02050513          	addi	a0,a0,32
    80005e74:	050e                	slli	a0,a0,0x3
    80005e76:	94aa                	add	s1,s1,a0
    80005e78:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e7c:	fd043503          	ld	a0,-48(s0)
    80005e80:	fffff097          	auipc	ra,0xfffff
    80005e84:	9ec080e7          	jalr	-1556(ra) # 8000486c <fileclose>
    fileclose(wf);
    80005e88:	fc843503          	ld	a0,-56(s0)
    80005e8c:	fffff097          	auipc	ra,0xfffff
    80005e90:	9e0080e7          	jalr	-1568(ra) # 8000486c <fileclose>
    return -1;
    80005e94:	57fd                	li	a5,-1
    80005e96:	a805                	j	80005ec6 <sys_pipe+0x106>
    if(fd0 >= 0)
    80005e98:	fc442783          	lw	a5,-60(s0)
    80005e9c:	0007c863          	bltz	a5,80005eac <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80005ea0:	02078793          	addi	a5,a5,32
    80005ea4:	078e                	slli	a5,a5,0x3
    80005ea6:	94be                	add	s1,s1,a5
    80005ea8:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005eac:	fd043503          	ld	a0,-48(s0)
    80005eb0:	fffff097          	auipc	ra,0xfffff
    80005eb4:	9bc080e7          	jalr	-1604(ra) # 8000486c <fileclose>
    fileclose(wf);
    80005eb8:	fc843503          	ld	a0,-56(s0)
    80005ebc:	fffff097          	auipc	ra,0xfffff
    80005ec0:	9b0080e7          	jalr	-1616(ra) # 8000486c <fileclose>
    return -1;
    80005ec4:	57fd                	li	a5,-1
}
    80005ec6:	853e                	mv	a0,a5
    80005ec8:	70e2                	ld	ra,56(sp)
    80005eca:	7442                	ld	s0,48(sp)
    80005ecc:	74a2                	ld	s1,40(sp)
    80005ece:	6121                	addi	sp,sp,64
    80005ed0:	8082                	ret
	...

0000000080005ee0 <kernelvec>:
    80005ee0:	7111                	addi	sp,sp,-256
    80005ee2:	e006                	sd	ra,0(sp)
    80005ee4:	e40a                	sd	sp,8(sp)
    80005ee6:	e80e                	sd	gp,16(sp)
    80005ee8:	ec12                	sd	tp,24(sp)
    80005eea:	f016                	sd	t0,32(sp)
    80005eec:	f41a                	sd	t1,40(sp)
    80005eee:	f81e                	sd	t2,48(sp)
    80005ef0:	fc22                	sd	s0,56(sp)
    80005ef2:	e0a6                	sd	s1,64(sp)
    80005ef4:	e4aa                	sd	a0,72(sp)
    80005ef6:	e8ae                	sd	a1,80(sp)
    80005ef8:	ecb2                	sd	a2,88(sp)
    80005efa:	f0b6                	sd	a3,96(sp)
    80005efc:	f4ba                	sd	a4,104(sp)
    80005efe:	f8be                	sd	a5,112(sp)
    80005f00:	fcc2                	sd	a6,120(sp)
    80005f02:	e146                	sd	a7,128(sp)
    80005f04:	e54a                	sd	s2,136(sp)
    80005f06:	e94e                	sd	s3,144(sp)
    80005f08:	ed52                	sd	s4,152(sp)
    80005f0a:	f156                	sd	s5,160(sp)
    80005f0c:	f55a                	sd	s6,168(sp)
    80005f0e:	f95e                	sd	s7,176(sp)
    80005f10:	fd62                	sd	s8,184(sp)
    80005f12:	e1e6                	sd	s9,192(sp)
    80005f14:	e5ea                	sd	s10,200(sp)
    80005f16:	e9ee                	sd	s11,208(sp)
    80005f18:	edf2                	sd	t3,216(sp)
    80005f1a:	f1f6                	sd	t4,224(sp)
    80005f1c:	f5fa                	sd	t5,232(sp)
    80005f1e:	f9fe                	sd	t6,240(sp)
    80005f20:	d6dfc0ef          	jal	ra,80002c8c <kerneltrap>
    80005f24:	6082                	ld	ra,0(sp)
    80005f26:	6122                	ld	sp,8(sp)
    80005f28:	61c2                	ld	gp,16(sp)
    80005f2a:	7282                	ld	t0,32(sp)
    80005f2c:	7322                	ld	t1,40(sp)
    80005f2e:	73c2                	ld	t2,48(sp)
    80005f30:	7462                	ld	s0,56(sp)
    80005f32:	6486                	ld	s1,64(sp)
    80005f34:	6526                	ld	a0,72(sp)
    80005f36:	65c6                	ld	a1,80(sp)
    80005f38:	6666                	ld	a2,88(sp)
    80005f3a:	7686                	ld	a3,96(sp)
    80005f3c:	7726                	ld	a4,104(sp)
    80005f3e:	77c6                	ld	a5,112(sp)
    80005f40:	7866                	ld	a6,120(sp)
    80005f42:	688a                	ld	a7,128(sp)
    80005f44:	692a                	ld	s2,136(sp)
    80005f46:	69ca                	ld	s3,144(sp)
    80005f48:	6a6a                	ld	s4,152(sp)
    80005f4a:	7a8a                	ld	s5,160(sp)
    80005f4c:	7b2a                	ld	s6,168(sp)
    80005f4e:	7bca                	ld	s7,176(sp)
    80005f50:	7c6a                	ld	s8,184(sp)
    80005f52:	6c8e                	ld	s9,192(sp)
    80005f54:	6d2e                	ld	s10,200(sp)
    80005f56:	6dce                	ld	s11,208(sp)
    80005f58:	6e6e                	ld	t3,216(sp)
    80005f5a:	7e8e                	ld	t4,224(sp)
    80005f5c:	7f2e                	ld	t5,232(sp)
    80005f5e:	7fce                	ld	t6,240(sp)
    80005f60:	6111                	addi	sp,sp,256
    80005f62:	10200073          	sret
    80005f66:	00000013          	nop
    80005f6a:	00000013          	nop
    80005f6e:	0001                	nop

0000000080005f70 <timervec>:
    80005f70:	34051573          	csrrw	a0,mscratch,a0
    80005f74:	e10c                	sd	a1,0(a0)
    80005f76:	e510                	sd	a2,8(a0)
    80005f78:	e914                	sd	a3,16(a0)
    80005f7a:	6d0c                	ld	a1,24(a0)
    80005f7c:	7110                	ld	a2,32(a0)
    80005f7e:	6194                	ld	a3,0(a1)
    80005f80:	96b2                	add	a3,a3,a2
    80005f82:	e194                	sd	a3,0(a1)
    80005f84:	4589                	li	a1,2
    80005f86:	14459073          	csrw	sip,a1
    80005f8a:	6914                	ld	a3,16(a0)
    80005f8c:	6510                	ld	a2,8(a0)
    80005f8e:	610c                	ld	a1,0(a0)
    80005f90:	34051573          	csrrw	a0,mscratch,a0
    80005f94:	30200073          	mret
	...

0000000080005f9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f9a:	1141                	addi	sp,sp,-16
    80005f9c:	e422                	sd	s0,8(sp)
    80005f9e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fa0:	0c0007b7          	lui	a5,0xc000
    80005fa4:	4705                	li	a4,1
    80005fa6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fa8:	c3d8                	sw	a4,4(a5)
}
    80005faa:	6422                	ld	s0,8(sp)
    80005fac:	0141                	addi	sp,sp,16
    80005fae:	8082                	ret

0000000080005fb0 <plicinithart>:

void
plicinithart(void)
{
    80005fb0:	1141                	addi	sp,sp,-16
    80005fb2:	e406                	sd	ra,8(sp)
    80005fb4:	e022                	sd	s0,0(sp)
    80005fb6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fb8:	ffffc097          	auipc	ra,0xffffc
    80005fbc:	99c080e7          	jalr	-1636(ra) # 80001954 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fc0:	0085171b          	slliw	a4,a0,0x8
    80005fc4:	0c0027b7          	lui	a5,0xc002
    80005fc8:	97ba                	add	a5,a5,a4
    80005fca:	40200713          	li	a4,1026
    80005fce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fd2:	00d5151b          	slliw	a0,a0,0xd
    80005fd6:	0c2017b7          	lui	a5,0xc201
    80005fda:	953e                	add	a0,a0,a5
    80005fdc:	00052023          	sw	zero,0(a0)
}
    80005fe0:	60a2                	ld	ra,8(sp)
    80005fe2:	6402                	ld	s0,0(sp)
    80005fe4:	0141                	addi	sp,sp,16
    80005fe6:	8082                	ret

0000000080005fe8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fe8:	1141                	addi	sp,sp,-16
    80005fea:	e406                	sd	ra,8(sp)
    80005fec:	e022                	sd	s0,0(sp)
    80005fee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ff0:	ffffc097          	auipc	ra,0xffffc
    80005ff4:	964080e7          	jalr	-1692(ra) # 80001954 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ff8:	00d5179b          	slliw	a5,a0,0xd
    80005ffc:	0c201537          	lui	a0,0xc201
    80006000:	953e                	add	a0,a0,a5
  return irq;
}
    80006002:	4148                	lw	a0,4(a0)
    80006004:	60a2                	ld	ra,8(sp)
    80006006:	6402                	ld	s0,0(sp)
    80006008:	0141                	addi	sp,sp,16
    8000600a:	8082                	ret

000000008000600c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000600c:	1101                	addi	sp,sp,-32
    8000600e:	ec06                	sd	ra,24(sp)
    80006010:	e822                	sd	s0,16(sp)
    80006012:	e426                	sd	s1,8(sp)
    80006014:	1000                	addi	s0,sp,32
    80006016:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006018:	ffffc097          	auipc	ra,0xffffc
    8000601c:	93c080e7          	jalr	-1732(ra) # 80001954 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006020:	00d5151b          	slliw	a0,a0,0xd
    80006024:	0c2017b7          	lui	a5,0xc201
    80006028:	97aa                	add	a5,a5,a0
    8000602a:	c3c4                	sw	s1,4(a5)
}
    8000602c:	60e2                	ld	ra,24(sp)
    8000602e:	6442                	ld	s0,16(sp)
    80006030:	64a2                	ld	s1,8(sp)
    80006032:	6105                	addi	sp,sp,32
    80006034:	8082                	ret

0000000080006036 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006036:	1141                	addi	sp,sp,-16
    80006038:	e406                	sd	ra,8(sp)
    8000603a:	e022                	sd	s0,0(sp)
    8000603c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000603e:	479d                	li	a5,7
    80006040:	04a7cc63          	blt	a5,a0,80006098 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006044:	0001d797          	auipc	a5,0x1d
    80006048:	27c78793          	addi	a5,a5,636 # 800232c0 <disk>
    8000604c:	97aa                	add	a5,a5,a0
    8000604e:	0187c783          	lbu	a5,24(a5)
    80006052:	ebb9                	bnez	a5,800060a8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006054:	00451613          	slli	a2,a0,0x4
    80006058:	0001d797          	auipc	a5,0x1d
    8000605c:	26878793          	addi	a5,a5,616 # 800232c0 <disk>
    80006060:	6394                	ld	a3,0(a5)
    80006062:	96b2                	add	a3,a3,a2
    80006064:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006068:	6398                	ld	a4,0(a5)
    8000606a:	9732                	add	a4,a4,a2
    8000606c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006070:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006074:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006078:	953e                	add	a0,a0,a5
    8000607a:	4785                	li	a5,1
    8000607c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006080:	0001d517          	auipc	a0,0x1d
    80006084:	25850513          	addi	a0,a0,600 # 800232d8 <disk+0x18>
    80006088:	ffffc097          	auipc	ra,0xffffc
    8000608c:	116080e7          	jalr	278(ra) # 8000219e <wakeup>
}
    80006090:	60a2                	ld	ra,8(sp)
    80006092:	6402                	ld	s0,0(sp)
    80006094:	0141                	addi	sp,sp,16
    80006096:	8082                	ret
    panic("free_desc 1");
    80006098:	00002517          	auipc	a0,0x2
    8000609c:	74050513          	addi	a0,a0,1856 # 800087d8 <syscalls+0x2f0>
    800060a0:	ffffa097          	auipc	ra,0xffffa
    800060a4:	49e080e7          	jalr	1182(ra) # 8000053e <panic>
    panic("free_desc 2");
    800060a8:	00002517          	auipc	a0,0x2
    800060ac:	74050513          	addi	a0,a0,1856 # 800087e8 <syscalls+0x300>
    800060b0:	ffffa097          	auipc	ra,0xffffa
    800060b4:	48e080e7          	jalr	1166(ra) # 8000053e <panic>

00000000800060b8 <virtio_disk_init>:
{
    800060b8:	1101                	addi	sp,sp,-32
    800060ba:	ec06                	sd	ra,24(sp)
    800060bc:	e822                	sd	s0,16(sp)
    800060be:	e426                	sd	s1,8(sp)
    800060c0:	e04a                	sd	s2,0(sp)
    800060c2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060c4:	00002597          	auipc	a1,0x2
    800060c8:	73458593          	addi	a1,a1,1844 # 800087f8 <syscalls+0x310>
    800060cc:	0001d517          	auipc	a0,0x1d
    800060d0:	31c50513          	addi	a0,a0,796 # 800233e8 <disk+0x128>
    800060d4:	ffffb097          	auipc	ra,0xffffb
    800060d8:	a72080e7          	jalr	-1422(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060dc:	100017b7          	lui	a5,0x10001
    800060e0:	4398                	lw	a4,0(a5)
    800060e2:	2701                	sext.w	a4,a4
    800060e4:	747277b7          	lui	a5,0x74727
    800060e8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060ec:	14f71c63          	bne	a4,a5,80006244 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060f0:	100017b7          	lui	a5,0x10001
    800060f4:	43dc                	lw	a5,4(a5)
    800060f6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060f8:	4709                	li	a4,2
    800060fa:	14e79563          	bne	a5,a4,80006244 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060fe:	100017b7          	lui	a5,0x10001
    80006102:	479c                	lw	a5,8(a5)
    80006104:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006106:	12e79f63          	bne	a5,a4,80006244 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000610a:	100017b7          	lui	a5,0x10001
    8000610e:	47d8                	lw	a4,12(a5)
    80006110:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006112:	554d47b7          	lui	a5,0x554d4
    80006116:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000611a:	12f71563          	bne	a4,a5,80006244 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000611e:	100017b7          	lui	a5,0x10001
    80006122:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006126:	4705                	li	a4,1
    80006128:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000612a:	470d                	li	a4,3
    8000612c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000612e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006130:	c7ffe737          	lui	a4,0xc7ffe
    80006134:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb35f>
    80006138:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000613a:	2701                	sext.w	a4,a4
    8000613c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000613e:	472d                	li	a4,11
    80006140:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006142:	5bbc                	lw	a5,112(a5)
    80006144:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006148:	8ba1                	andi	a5,a5,8
    8000614a:	10078563          	beqz	a5,80006254 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000614e:	100017b7          	lui	a5,0x10001
    80006152:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006156:	43fc                	lw	a5,68(a5)
    80006158:	2781                	sext.w	a5,a5
    8000615a:	10079563          	bnez	a5,80006264 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000615e:	100017b7          	lui	a5,0x10001
    80006162:	5bdc                	lw	a5,52(a5)
    80006164:	2781                	sext.w	a5,a5
  if(max == 0)
    80006166:	10078763          	beqz	a5,80006274 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000616a:	471d                	li	a4,7
    8000616c:	10f77c63          	bgeu	a4,a5,80006284 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006170:	ffffb097          	auipc	ra,0xffffb
    80006174:	976080e7          	jalr	-1674(ra) # 80000ae6 <kalloc>
    80006178:	0001d497          	auipc	s1,0x1d
    8000617c:	14848493          	addi	s1,s1,328 # 800232c0 <disk>
    80006180:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006182:	ffffb097          	auipc	ra,0xffffb
    80006186:	964080e7          	jalr	-1692(ra) # 80000ae6 <kalloc>
    8000618a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000618c:	ffffb097          	auipc	ra,0xffffb
    80006190:	95a080e7          	jalr	-1702(ra) # 80000ae6 <kalloc>
    80006194:	87aa                	mv	a5,a0
    80006196:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006198:	6088                	ld	a0,0(s1)
    8000619a:	cd6d                	beqz	a0,80006294 <virtio_disk_init+0x1dc>
    8000619c:	0001d717          	auipc	a4,0x1d
    800061a0:	12c73703          	ld	a4,300(a4) # 800232c8 <disk+0x8>
    800061a4:	cb65                	beqz	a4,80006294 <virtio_disk_init+0x1dc>
    800061a6:	c7fd                	beqz	a5,80006294 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800061a8:	6605                	lui	a2,0x1
    800061aa:	4581                	li	a1,0
    800061ac:	ffffb097          	auipc	ra,0xffffb
    800061b0:	b26080e7          	jalr	-1242(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800061b4:	0001d497          	auipc	s1,0x1d
    800061b8:	10c48493          	addi	s1,s1,268 # 800232c0 <disk>
    800061bc:	6605                	lui	a2,0x1
    800061be:	4581                	li	a1,0
    800061c0:	6488                	ld	a0,8(s1)
    800061c2:	ffffb097          	auipc	ra,0xffffb
    800061c6:	b10080e7          	jalr	-1264(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800061ca:	6605                	lui	a2,0x1
    800061cc:	4581                	li	a1,0
    800061ce:	6888                	ld	a0,16(s1)
    800061d0:	ffffb097          	auipc	ra,0xffffb
    800061d4:	b02080e7          	jalr	-1278(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061d8:	100017b7          	lui	a5,0x10001
    800061dc:	4721                	li	a4,8
    800061de:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800061e0:	4098                	lw	a4,0(s1)
    800061e2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800061e6:	40d8                	lw	a4,4(s1)
    800061e8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800061ec:	6498                	ld	a4,8(s1)
    800061ee:	0007069b          	sext.w	a3,a4
    800061f2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800061f6:	9701                	srai	a4,a4,0x20
    800061f8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800061fc:	6898                	ld	a4,16(s1)
    800061fe:	0007069b          	sext.w	a3,a4
    80006202:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006206:	9701                	srai	a4,a4,0x20
    80006208:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000620c:	4705                	li	a4,1
    8000620e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006210:	00e48c23          	sb	a4,24(s1)
    80006214:	00e48ca3          	sb	a4,25(s1)
    80006218:	00e48d23          	sb	a4,26(s1)
    8000621c:	00e48da3          	sb	a4,27(s1)
    80006220:	00e48e23          	sb	a4,28(s1)
    80006224:	00e48ea3          	sb	a4,29(s1)
    80006228:	00e48f23          	sb	a4,30(s1)
    8000622c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006230:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006234:	0727a823          	sw	s2,112(a5)
}
    80006238:	60e2                	ld	ra,24(sp)
    8000623a:	6442                	ld	s0,16(sp)
    8000623c:	64a2                	ld	s1,8(sp)
    8000623e:	6902                	ld	s2,0(sp)
    80006240:	6105                	addi	sp,sp,32
    80006242:	8082                	ret
    panic("could not find virtio disk");
    80006244:	00002517          	auipc	a0,0x2
    80006248:	5c450513          	addi	a0,a0,1476 # 80008808 <syscalls+0x320>
    8000624c:	ffffa097          	auipc	ra,0xffffa
    80006250:	2f2080e7          	jalr	754(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006254:	00002517          	auipc	a0,0x2
    80006258:	5d450513          	addi	a0,a0,1492 # 80008828 <syscalls+0x340>
    8000625c:	ffffa097          	auipc	ra,0xffffa
    80006260:	2e2080e7          	jalr	738(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006264:	00002517          	auipc	a0,0x2
    80006268:	5e450513          	addi	a0,a0,1508 # 80008848 <syscalls+0x360>
    8000626c:	ffffa097          	auipc	ra,0xffffa
    80006270:	2d2080e7          	jalr	722(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006274:	00002517          	auipc	a0,0x2
    80006278:	5f450513          	addi	a0,a0,1524 # 80008868 <syscalls+0x380>
    8000627c:	ffffa097          	auipc	ra,0xffffa
    80006280:	2c2080e7          	jalr	706(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006284:	00002517          	auipc	a0,0x2
    80006288:	60450513          	addi	a0,a0,1540 # 80008888 <syscalls+0x3a0>
    8000628c:	ffffa097          	auipc	ra,0xffffa
    80006290:	2b2080e7          	jalr	690(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006294:	00002517          	auipc	a0,0x2
    80006298:	61450513          	addi	a0,a0,1556 # 800088a8 <syscalls+0x3c0>
    8000629c:	ffffa097          	auipc	ra,0xffffa
    800062a0:	2a2080e7          	jalr	674(ra) # 8000053e <panic>

00000000800062a4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062a4:	7119                	addi	sp,sp,-128
    800062a6:	fc86                	sd	ra,120(sp)
    800062a8:	f8a2                	sd	s0,112(sp)
    800062aa:	f4a6                	sd	s1,104(sp)
    800062ac:	f0ca                	sd	s2,96(sp)
    800062ae:	ecce                	sd	s3,88(sp)
    800062b0:	e8d2                	sd	s4,80(sp)
    800062b2:	e4d6                	sd	s5,72(sp)
    800062b4:	e0da                	sd	s6,64(sp)
    800062b6:	fc5e                	sd	s7,56(sp)
    800062b8:	f862                	sd	s8,48(sp)
    800062ba:	f466                	sd	s9,40(sp)
    800062bc:	f06a                	sd	s10,32(sp)
    800062be:	ec6e                	sd	s11,24(sp)
    800062c0:	0100                	addi	s0,sp,128
    800062c2:	8aaa                	mv	s5,a0
    800062c4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062c6:	00c52d03          	lw	s10,12(a0)
    800062ca:	001d1d1b          	slliw	s10,s10,0x1
    800062ce:	1d02                	slli	s10,s10,0x20
    800062d0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800062d4:	0001d517          	auipc	a0,0x1d
    800062d8:	11450513          	addi	a0,a0,276 # 800233e8 <disk+0x128>
    800062dc:	ffffb097          	auipc	ra,0xffffb
    800062e0:	8fa080e7          	jalr	-1798(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800062e4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800062e6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800062e8:	0001db97          	auipc	s7,0x1d
    800062ec:	fd8b8b93          	addi	s7,s7,-40 # 800232c0 <disk>
  for(int i = 0; i < 3; i++){
    800062f0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062f2:	0001dc97          	auipc	s9,0x1d
    800062f6:	0f6c8c93          	addi	s9,s9,246 # 800233e8 <disk+0x128>
    800062fa:	a08d                	j	8000635c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800062fc:	00fb8733          	add	a4,s7,a5
    80006300:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006304:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006306:	0207c563          	bltz	a5,80006330 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000630a:	2905                	addiw	s2,s2,1
    8000630c:	0611                	addi	a2,a2,4
    8000630e:	05690c63          	beq	s2,s6,80006366 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006312:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006314:	0001d717          	auipc	a4,0x1d
    80006318:	fac70713          	addi	a4,a4,-84 # 800232c0 <disk>
    8000631c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000631e:	01874683          	lbu	a3,24(a4)
    80006322:	fee9                	bnez	a3,800062fc <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006324:	2785                	addiw	a5,a5,1
    80006326:	0705                	addi	a4,a4,1
    80006328:	fe979be3          	bne	a5,s1,8000631e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000632c:	57fd                	li	a5,-1
    8000632e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006330:	01205d63          	blez	s2,8000634a <virtio_disk_rw+0xa6>
    80006334:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006336:	000a2503          	lw	a0,0(s4)
    8000633a:	00000097          	auipc	ra,0x0
    8000633e:	cfc080e7          	jalr	-772(ra) # 80006036 <free_desc>
      for(int j = 0; j < i; j++)
    80006342:	2d85                	addiw	s11,s11,1
    80006344:	0a11                	addi	s4,s4,4
    80006346:	ffb918e3          	bne	s2,s11,80006336 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000634a:	85e6                	mv	a1,s9
    8000634c:	0001d517          	auipc	a0,0x1d
    80006350:	f8c50513          	addi	a0,a0,-116 # 800232d8 <disk+0x18>
    80006354:	ffffc097          	auipc	ra,0xffffc
    80006358:	dca080e7          	jalr	-566(ra) # 8000211e <sleep>
  for(int i = 0; i < 3; i++){
    8000635c:	f8040a13          	addi	s4,s0,-128
{
    80006360:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006362:	894e                	mv	s2,s3
    80006364:	b77d                	j	80006312 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006366:	f8042583          	lw	a1,-128(s0)
    8000636a:	00a58793          	addi	a5,a1,10
    8000636e:	0792                	slli	a5,a5,0x4

  if(write)
    80006370:	0001d617          	auipc	a2,0x1d
    80006374:	f5060613          	addi	a2,a2,-176 # 800232c0 <disk>
    80006378:	00f60733          	add	a4,a2,a5
    8000637c:	018036b3          	snez	a3,s8
    80006380:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006382:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006386:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000638a:	f6078693          	addi	a3,a5,-160
    8000638e:	6218                	ld	a4,0(a2)
    80006390:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006392:	00878513          	addi	a0,a5,8
    80006396:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006398:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000639a:	6208                	ld	a0,0(a2)
    8000639c:	96aa                	add	a3,a3,a0
    8000639e:	4741                	li	a4,16
    800063a0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063a2:	4705                	li	a4,1
    800063a4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800063a8:	f8442703          	lw	a4,-124(s0)
    800063ac:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063b0:	0712                	slli	a4,a4,0x4
    800063b2:	953a                	add	a0,a0,a4
    800063b4:	058a8693          	addi	a3,s5,88
    800063b8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800063ba:	6208                	ld	a0,0(a2)
    800063bc:	972a                	add	a4,a4,a0
    800063be:	40000693          	li	a3,1024
    800063c2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063c4:	001c3c13          	seqz	s8,s8
    800063c8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063ca:	001c6c13          	ori	s8,s8,1
    800063ce:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800063d2:	f8842603          	lw	a2,-120(s0)
    800063d6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063da:	0001d697          	auipc	a3,0x1d
    800063de:	ee668693          	addi	a3,a3,-282 # 800232c0 <disk>
    800063e2:	00258713          	addi	a4,a1,2
    800063e6:	0712                	slli	a4,a4,0x4
    800063e8:	9736                	add	a4,a4,a3
    800063ea:	587d                	li	a6,-1
    800063ec:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063f0:	0612                	slli	a2,a2,0x4
    800063f2:	9532                	add	a0,a0,a2
    800063f4:	f9078793          	addi	a5,a5,-112
    800063f8:	97b6                	add	a5,a5,a3
    800063fa:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800063fc:	629c                	ld	a5,0(a3)
    800063fe:	97b2                	add	a5,a5,a2
    80006400:	4605                	li	a2,1
    80006402:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006404:	4509                	li	a0,2
    80006406:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000640a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000640e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006412:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006416:	6698                	ld	a4,8(a3)
    80006418:	00275783          	lhu	a5,2(a4)
    8000641c:	8b9d                	andi	a5,a5,7
    8000641e:	0786                	slli	a5,a5,0x1
    80006420:	97ba                	add	a5,a5,a4
    80006422:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006426:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000642a:	6698                	ld	a4,8(a3)
    8000642c:	00275783          	lhu	a5,2(a4)
    80006430:	2785                	addiw	a5,a5,1
    80006432:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006436:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000643a:	100017b7          	lui	a5,0x10001
    8000643e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006442:	004aa783          	lw	a5,4(s5)
    80006446:	02c79163          	bne	a5,a2,80006468 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000644a:	0001d917          	auipc	s2,0x1d
    8000644e:	f9e90913          	addi	s2,s2,-98 # 800233e8 <disk+0x128>
  while(b->disk == 1) {
    80006452:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006454:	85ca                	mv	a1,s2
    80006456:	8556                	mv	a0,s5
    80006458:	ffffc097          	auipc	ra,0xffffc
    8000645c:	cc6080e7          	jalr	-826(ra) # 8000211e <sleep>
  while(b->disk == 1) {
    80006460:	004aa783          	lw	a5,4(s5)
    80006464:	fe9788e3          	beq	a5,s1,80006454 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006468:	f8042903          	lw	s2,-128(s0)
    8000646c:	00290793          	addi	a5,s2,2
    80006470:	00479713          	slli	a4,a5,0x4
    80006474:	0001d797          	auipc	a5,0x1d
    80006478:	e4c78793          	addi	a5,a5,-436 # 800232c0 <disk>
    8000647c:	97ba                	add	a5,a5,a4
    8000647e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006482:	0001d997          	auipc	s3,0x1d
    80006486:	e3e98993          	addi	s3,s3,-450 # 800232c0 <disk>
    8000648a:	00491713          	slli	a4,s2,0x4
    8000648e:	0009b783          	ld	a5,0(s3)
    80006492:	97ba                	add	a5,a5,a4
    80006494:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006498:	854a                	mv	a0,s2
    8000649a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000649e:	00000097          	auipc	ra,0x0
    800064a2:	b98080e7          	jalr	-1128(ra) # 80006036 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064a6:	8885                	andi	s1,s1,1
    800064a8:	f0ed                	bnez	s1,8000648a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064aa:	0001d517          	auipc	a0,0x1d
    800064ae:	f3e50513          	addi	a0,a0,-194 # 800233e8 <disk+0x128>
    800064b2:	ffffa097          	auipc	ra,0xffffa
    800064b6:	7d8080e7          	jalr	2008(ra) # 80000c8a <release>
}
    800064ba:	70e6                	ld	ra,120(sp)
    800064bc:	7446                	ld	s0,112(sp)
    800064be:	74a6                	ld	s1,104(sp)
    800064c0:	7906                	ld	s2,96(sp)
    800064c2:	69e6                	ld	s3,88(sp)
    800064c4:	6a46                	ld	s4,80(sp)
    800064c6:	6aa6                	ld	s5,72(sp)
    800064c8:	6b06                	ld	s6,64(sp)
    800064ca:	7be2                	ld	s7,56(sp)
    800064cc:	7c42                	ld	s8,48(sp)
    800064ce:	7ca2                	ld	s9,40(sp)
    800064d0:	7d02                	ld	s10,32(sp)
    800064d2:	6de2                	ld	s11,24(sp)
    800064d4:	6109                	addi	sp,sp,128
    800064d6:	8082                	ret

00000000800064d8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064d8:	1101                	addi	sp,sp,-32
    800064da:	ec06                	sd	ra,24(sp)
    800064dc:	e822                	sd	s0,16(sp)
    800064de:	e426                	sd	s1,8(sp)
    800064e0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064e2:	0001d497          	auipc	s1,0x1d
    800064e6:	dde48493          	addi	s1,s1,-546 # 800232c0 <disk>
    800064ea:	0001d517          	auipc	a0,0x1d
    800064ee:	efe50513          	addi	a0,a0,-258 # 800233e8 <disk+0x128>
    800064f2:	ffffa097          	auipc	ra,0xffffa
    800064f6:	6e4080e7          	jalr	1764(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064fa:	10001737          	lui	a4,0x10001
    800064fe:	533c                	lw	a5,96(a4)
    80006500:	8b8d                	andi	a5,a5,3
    80006502:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006504:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006508:	689c                	ld	a5,16(s1)
    8000650a:	0204d703          	lhu	a4,32(s1)
    8000650e:	0027d783          	lhu	a5,2(a5)
    80006512:	04f70863          	beq	a4,a5,80006562 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006516:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000651a:	6898                	ld	a4,16(s1)
    8000651c:	0204d783          	lhu	a5,32(s1)
    80006520:	8b9d                	andi	a5,a5,7
    80006522:	078e                	slli	a5,a5,0x3
    80006524:	97ba                	add	a5,a5,a4
    80006526:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006528:	00278713          	addi	a4,a5,2
    8000652c:	0712                	slli	a4,a4,0x4
    8000652e:	9726                	add	a4,a4,s1
    80006530:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006534:	e721                	bnez	a4,8000657c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006536:	0789                	addi	a5,a5,2
    80006538:	0792                	slli	a5,a5,0x4
    8000653a:	97a6                	add	a5,a5,s1
    8000653c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000653e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006542:	ffffc097          	auipc	ra,0xffffc
    80006546:	c5c080e7          	jalr	-932(ra) # 8000219e <wakeup>

    disk.used_idx += 1;
    8000654a:	0204d783          	lhu	a5,32(s1)
    8000654e:	2785                	addiw	a5,a5,1
    80006550:	17c2                	slli	a5,a5,0x30
    80006552:	93c1                	srli	a5,a5,0x30
    80006554:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006558:	6898                	ld	a4,16(s1)
    8000655a:	00275703          	lhu	a4,2(a4)
    8000655e:	faf71ce3          	bne	a4,a5,80006516 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006562:	0001d517          	auipc	a0,0x1d
    80006566:	e8650513          	addi	a0,a0,-378 # 800233e8 <disk+0x128>
    8000656a:	ffffa097          	auipc	ra,0xffffa
    8000656e:	720080e7          	jalr	1824(ra) # 80000c8a <release>
}
    80006572:	60e2                	ld	ra,24(sp)
    80006574:	6442                	ld	s0,16(sp)
    80006576:	64a2                	ld	s1,8(sp)
    80006578:	6105                	addi	sp,sp,32
    8000657a:	8082                	ret
      panic("virtio_disk_intr status");
    8000657c:	00002517          	auipc	a0,0x2
    80006580:	34450513          	addi	a0,a0,836 # 800088c0 <syscalls+0x3d8>
    80006584:	ffffa097          	auipc	ra,0xffffa
    80006588:	fba080e7          	jalr	-70(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	12000073          	sfence.vma
    8000708a:	18031073          	csrw	satp,t1
    8000708e:	12000073          	sfence.vma
    80007092:	8282                	jr	t0

0000000080007094 <userret>:
    80007094:	18059073          	csrw	satp,a1
    80007098:	12000073          	sfence.vma
    8000709c:	07053283          	ld	t0,112(a0)
    800070a0:	14029073          	csrw	sscratch,t0
    800070a4:	02853083          	ld	ra,40(a0)
    800070a8:	03053103          	ld	sp,48(a0)
    800070ac:	03853183          	ld	gp,56(a0)
    800070b0:	04053203          	ld	tp,64(a0)
    800070b4:	04853283          	ld	t0,72(a0)
    800070b8:	05053303          	ld	t1,80(a0)
    800070bc:	05853383          	ld	t2,88(a0)
    800070c0:	7120                	ld	s0,96(a0)
    800070c2:	7524                	ld	s1,104(a0)
    800070c4:	7d2c                	ld	a1,120(a0)
    800070c6:	6150                	ld	a2,128(a0)
    800070c8:	6554                	ld	a3,136(a0)
    800070ca:	6958                	ld	a4,144(a0)
    800070cc:	6d5c                	ld	a5,152(a0)
    800070ce:	0a053803          	ld	a6,160(a0)
    800070d2:	0a853883          	ld	a7,168(a0)
    800070d6:	0b053903          	ld	s2,176(a0)
    800070da:	0b853983          	ld	s3,184(a0)
    800070de:	0c053a03          	ld	s4,192(a0)
    800070e2:	0c853a83          	ld	s5,200(a0)
    800070e6:	0d053b03          	ld	s6,208(a0)
    800070ea:	0d853b83          	ld	s7,216(a0)
    800070ee:	0e053c03          	ld	s8,224(a0)
    800070f2:	0e853c83          	ld	s9,232(a0)
    800070f6:	0f053d03          	ld	s10,240(a0)
    800070fa:	0f853d83          	ld	s11,248(a0)
    800070fe:	10053e03          	ld	t3,256(a0)
    80007102:	10853e83          	ld	t4,264(a0)
    80007106:	11053f03          	ld	t5,272(a0)
    8000710a:	11853f83          	ld	t6,280(a0)
    8000710e:	14051573          	csrrw	a0,sscratch,a0
    80007112:	10200073          	sret
	...
