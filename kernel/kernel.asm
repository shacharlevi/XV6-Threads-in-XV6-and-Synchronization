
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
    80000068:	f1c78793          	addi	a5,a5,-228 # 80005f80 <timervec>
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
    80000130:	4fc080e7          	jalr	1276(ra) # 80002628 <either_copyin>
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
    800001cc:	2a8080e7          	jalr	680(ra) # 80002470 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f58080e7          	jalr	-168(ra) # 8000212e <sleep>
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
    80000216:	3be080e7          	jalr	958(ra) # 800025d0 <either_copyout>
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
    800002f6:	38e080e7          	jalr	910(ra) # 80002680 <procdump>
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
    8000044a:	d68080e7          	jalr	-664(ra) # 800021ae <wakeup>
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
    80000896:	91c080e7          	jalr	-1764(ra) # 800021ae <wakeup>
    
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
    80000920:	812080e7          	jalr	-2030(ra) # 8000212e <sleep>
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
    80000ec2:	af0080e7          	jalr	-1296(ra) # 800029ae <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	0fa080e7          	jalr	250(ra) # 80005fc0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fe0080e7          	jalr	-32(ra) # 80001eae <scheduler>
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
    80000f3a:	a50080e7          	jalr	-1456(ra) # 80002986 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a70080e7          	jalr	-1424(ra) # 800029ae <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	064080e7          	jalr	100(ra) # 80005faa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	072080e7          	jalr	114(ra) # 80005fc0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	1f0080e7          	jalr	496(ra) # 80003146 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	894080e7          	jalr	-1900(ra) # 800037f2 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	832080e7          	jalr	-1998(ra) # 80004798 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	15a080e7          	jalr	346(ra) # 800060c8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	ce0080e7          	jalr	-800(ra) # 80001c56 <userinit>
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
    8000193a:	df8080e7          	jalr	-520(ra) # 8000272e <kthreadinit>
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
    80001988:	e04a                	sd	s2,0(sp)
    8000198a:	1000                	addi	s0,sp,32
  push_off();
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	1fe080e7          	jalr	510(ra) # 80000b8a <push_off>
    80001994:	8492                	mv	s1,tp
  int id = r_tp();
    80001996:	2481                	sext.w	s1,s1
  struct cpu *c = mycpu();
  acquire(&c->kthread->t_lock);
    80001998:	00749793          	slli	a5,s1,0x7
    8000199c:	0000f497          	auipc	s1,0xf
    800019a0:	25448493          	addi	s1,s1,596 # 80010bf0 <pid_lock>
    800019a4:	94be                	add	s1,s1,a5
    800019a6:	7888                	ld	a0,48(s1)
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	22e080e7          	jalr	558(ra) # 80000bd6 <acquire>
  struct proc *p = c->kthread->process;
    800019b0:	789c                	ld	a5,48(s1)
    800019b2:	0387b903          	ld	s2,56(a5)
  pop_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	274080e7          	jalr	628(ra) # 80000c2a <pop_off>
  release(&c->kthread->t_lock);
    800019be:	7888                	ld	a0,48(s1)
    800019c0:	fffff097          	auipc	ra,0xfffff
    800019c4:	2ca080e7          	jalr	714(ra) # 80000c8a <release>
  return p;
}
    800019c8:	854a                	mv	a0,s2
    800019ca:	60e2                	ld	ra,24(sp)
    800019cc:	6442                	ld	s0,16(sp)
    800019ce:	64a2                	ld	s1,8(sp)
    800019d0:	6902                	ld	s2,0(sp)
    800019d2:	6105                	addi	sp,sp,32
    800019d4:	8082                	ret

00000000800019d6 <allocpid>:

int
allocpid()
{
    800019d6:	1101                	addi	sp,sp,-32
    800019d8:	ec06                	sd	ra,24(sp)
    800019da:	e822                	sd	s0,16(sp)
    800019dc:	e426                	sd	s1,8(sp)
    800019de:	e04a                	sd	s2,0(sp)
    800019e0:	1000                	addi	s0,sp,32
  int pid;
  
  acquire(&pid_lock);
    800019e2:	0000f917          	auipc	s2,0xf
    800019e6:	20e90913          	addi	s2,s2,526 # 80010bf0 <pid_lock>
    800019ea:	854a                	mv	a0,s2
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	1ea080e7          	jalr	490(ra) # 80000bd6 <acquire>
  pid = nextpid;
    800019f4:	00007797          	auipc	a5,0x7
    800019f8:	ef078793          	addi	a5,a5,-272 # 800088e4 <nextpid>
    800019fc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019fe:	0014871b          	addiw	a4,s1,1
    80001a02:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a04:	854a                	mv	a0,s2
    80001a06:	fffff097          	auipc	ra,0xfffff
    80001a0a:	284080e7          	jalr	644(ra) # 80000c8a <release>

  return pid;
}
    80001a0e:	8526                	mv	a0,s1
    80001a10:	60e2                	ld	ra,24(sp)
    80001a12:	6442                	ld	s0,16(sp)
    80001a14:	64a2                	ld	s1,8(sp)
    80001a16:	6902                	ld	s2,0(sp)
    80001a18:	6105                	addi	sp,sp,32
    80001a1a:	8082                	ret

0000000080001a1c <proc_pagetable>:

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
    80001a1c:	1101                	addi	sp,sp,-32
    80001a1e:	ec06                	sd	ra,24(sp)
    80001a20:	e822                	sd	s0,16(sp)
    80001a22:	e426                	sd	s1,8(sp)
    80001a24:	e04a                	sd	s2,0(sp)
    80001a26:	1000                	addi	s0,sp,32
    80001a28:	892a                	mv	s2,a0
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
    80001a2a:	00000097          	auipc	ra,0x0
    80001a2e:	8fe080e7          	jalr	-1794(ra) # 80001328 <uvmcreate>
    80001a32:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a34:	c121                	beqz	a0,80001a74 <proc_pagetable+0x58>

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a36:	4729                	li	a4,10
    80001a38:	00005697          	auipc	a3,0x5
    80001a3c:	5c868693          	addi	a3,a3,1480 # 80007000 <_trampoline>
    80001a40:	6605                	lui	a2,0x1
    80001a42:	040005b7          	lui	a1,0x4000
    80001a46:	15fd                	addi	a1,a1,-1
    80001a48:	05b2                	slli	a1,a1,0xc
    80001a4a:	fffff097          	auipc	ra,0xfffff
    80001a4e:	654080e7          	jalr	1620(ra) # 8000109e <mappages>
    80001a52:	02054863          	bltz	a0,80001a82 <proc_pagetable+0x66>
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME(0), PGSIZE,
    80001a56:	4719                	li	a4,6
    80001a58:	0e893683          	ld	a3,232(s2)
    80001a5c:	6605                	lui	a2,0x1
    80001a5e:	020005b7          	lui	a1,0x2000
    80001a62:	15fd                	addi	a1,a1,-1
    80001a64:	05b6                	slli	a1,a1,0xd
    80001a66:	8526                	mv	a0,s1
    80001a68:	fffff097          	auipc	ra,0xfffff
    80001a6c:	636080e7          	jalr	1590(ra) # 8000109e <mappages>
    80001a70:	02054163          	bltz	a0,80001a92 <proc_pagetable+0x76>
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}
    80001a74:	8526                	mv	a0,s1
    80001a76:	60e2                	ld	ra,24(sp)
    80001a78:	6442                	ld	s0,16(sp)
    80001a7a:	64a2                	ld	s1,8(sp)
    80001a7c:	6902                	ld	s2,0(sp)
    80001a7e:	6105                	addi	sp,sp,32
    80001a80:	8082                	ret
    uvmfree(pagetable, 0);
    80001a82:	4581                	li	a1,0
    80001a84:	8526                	mv	a0,s1
    80001a86:	00000097          	auipc	ra,0x0
    80001a8a:	aa6080e7          	jalr	-1370(ra) # 8000152c <uvmfree>
    return 0;
    80001a8e:	4481                	li	s1,0
    80001a90:	b7d5                	j	80001a74 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a92:	4681                	li	a3,0
    80001a94:	4605                	li	a2,1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	8526                	mv	a0,s1
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	7c4080e7          	jalr	1988(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001aa8:	4581                	li	a1,0
    80001aaa:	8526                	mv	a0,s1
    80001aac:	00000097          	auipc	ra,0x0
    80001ab0:	a80080e7          	jalr	-1408(ra) # 8000152c <uvmfree>
    return 0;
    80001ab4:	4481                	li	s1,0
    80001ab6:	bf7d                	j	80001a74 <proc_pagetable+0x58>

0000000080001ab8 <proc_freepagetable>:

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
    80001ab8:	1101                	addi	sp,sp,-32
    80001aba:	ec06                	sd	ra,24(sp)
    80001abc:	e822                	sd	s0,16(sp)
    80001abe:	e426                	sd	s1,8(sp)
    80001ac0:	e04a                	sd	s2,0(sp)
    80001ac2:	1000                	addi	s0,sp,32
    80001ac4:	84aa                	mv	s1,a0
    80001ac6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ac8:	4681                	li	a3,0
    80001aca:	4605                	li	a2,1
    80001acc:	040005b7          	lui	a1,0x4000
    80001ad0:	15fd                	addi	a1,a1,-1
    80001ad2:	05b2                	slli	a1,a1,0xc
    80001ad4:	fffff097          	auipc	ra,0xfffff
    80001ad8:	790080e7          	jalr	1936(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME(0), 1, 0);
    80001adc:	4681                	li	a3,0
    80001ade:	4605                	li	a2,1
    80001ae0:	020005b7          	lui	a1,0x2000
    80001ae4:	15fd                	addi	a1,a1,-1
    80001ae6:	05b6                	slli	a1,a1,0xd
    80001ae8:	8526                	mv	a0,s1
    80001aea:	fffff097          	auipc	ra,0xfffff
    80001aee:	77a080e7          	jalr	1914(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001af2:	85ca                	mv	a1,s2
    80001af4:	8526                	mv	a0,s1
    80001af6:	00000097          	auipc	ra,0x0
    80001afa:	a36080e7          	jalr	-1482(ra) # 8000152c <uvmfree>
}
    80001afe:	60e2                	ld	ra,24(sp)
    80001b00:	6442                	ld	s0,16(sp)
    80001b02:	64a2                	ld	s1,8(sp)
    80001b04:	6902                	ld	s2,0(sp)
    80001b06:	6105                	addi	sp,sp,32
    80001b08:	8082                	ret

0000000080001b0a <freeproc>:
{
    80001b0a:	1101                	addi	sp,sp,-32
    80001b0c:	ec06                	sd	ra,24(sp)
    80001b0e:	e822                	sd	s0,16(sp)
    80001b10:	e426                	sd	s1,8(sp)
    80001b12:	e04a                	sd	s2,0(sp)
    80001b14:	1000                	addi	s0,sp,32
    80001b16:	84aa                	mv	s1,a0
      acquire(&kt->t_lock);
    80001b18:	02850913          	addi	s2,a0,40
    80001b1c:	854a                	mv	a0,s2
    80001b1e:	fffff097          	auipc	ra,0xfffff
    80001b22:	0b8080e7          	jalr	184(ra) # 80000bd6 <acquire>
      freethread(kt);
    80001b26:	854a                	mv	a0,s2
    80001b28:	00001097          	auipc	ra,0x1
    80001b2c:	d98080e7          	jalr	-616(ra) # 800028c0 <freethread>
  if(p->base_trapframes)
    80001b30:	74e8                	ld	a0,232(s1)
    80001b32:	c509                	beqz	a0,80001b3c <freeproc+0x32>
    kfree((void*)p->base_trapframes);
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	eb6080e7          	jalr	-330(ra) # 800009ea <kfree>
  p->base_trapframes = 0;
    80001b3c:	0e04b423          	sd	zero,232(s1)
  if(p->pagetable)
    80001b40:	1004b503          	ld	a0,256(s1)
    80001b44:	c511                	beqz	a0,80001b50 <freeproc+0x46>
    proc_freepagetable(p->pagetable, p->sz);
    80001b46:	7cec                	ld	a1,248(s1)
    80001b48:	00000097          	auipc	ra,0x0
    80001b4c:	f70080e7          	jalr	-144(ra) # 80001ab8 <proc_freepagetable>
  p->pagetable = 0;
    80001b50:	1004b023          	sd	zero,256(s1)
  p->sz = 0;
    80001b54:	0e04bc23          	sd	zero,248(s1)
  p->pid = 0;
    80001b58:	0204a223          	sw	zero,36(s1)
  p->parent = 0;
    80001b5c:	0e04b823          	sd	zero,240(s1)
  p->name[0] = 0;
    80001b60:	18048823          	sb	zero,400(s1)
  p->killed = 0;
    80001b64:	0004ae23          	sw	zero,28(s1)
  p->xstate = 0;
    80001b68:	0204a023          	sw	zero,32(s1)
  p->state = UNUSED;
    80001b6c:	0004ac23          	sw	zero,24(s1)
  p->p_counter=0;
    80001b70:	1a04a023          	sw	zero,416(s1)
}
    80001b74:	60e2                	ld	ra,24(sp)
    80001b76:	6442                	ld	s0,16(sp)
    80001b78:	64a2                	ld	s1,8(sp)
    80001b7a:	6902                	ld	s2,0(sp)
    80001b7c:	6105                	addi	sp,sp,32
    80001b7e:	8082                	ret

0000000080001b80 <allocproc>:
{
    80001b80:	1101                	addi	sp,sp,-32
    80001b82:	ec06                	sd	ra,24(sp)
    80001b84:	e822                	sd	s0,16(sp)
    80001b86:	e426                	sd	s1,8(sp)
    80001b88:	e04a                	sd	s2,0(sp)
    80001b8a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b8c:	0000f497          	auipc	s1,0xf
    80001b90:	49448493          	addi	s1,s1,1172 # 80011020 <proc>
    80001b94:	00016917          	auipc	s2,0x16
    80001b98:	48c90913          	addi	s2,s2,1164 # 80018020 <tickslock>
    acquire(&p->lock);
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	038080e7          	jalr	56(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001ba6:	4c9c                	lw	a5,24(s1)
    80001ba8:	cf81                	beqz	a5,80001bc0 <allocproc+0x40>
      release(&p->lock);
    80001baa:	8526                	mv	a0,s1
    80001bac:	fffff097          	auipc	ra,0xfffff
    80001bb0:	0de080e7          	jalr	222(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bb4:	1c048493          	addi	s1,s1,448
    80001bb8:	ff2492e3          	bne	s1,s2,80001b9c <allocproc+0x1c>
  return 0;
    80001bbc:	4481                	li	s1,0
    80001bbe:	a089                	j	80001c00 <allocproc+0x80>
  p->p_counter=1;
    80001bc0:	4905                	li	s2,1
    80001bc2:	1b24a023          	sw	s2,416(s1)
  p->pid = allocpid();
    80001bc6:	00000097          	auipc	ra,0x0
    80001bca:	e10080e7          	jalr	-496(ra) # 800019d6 <allocpid>
    80001bce:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001bd0:	0124ac23          	sw	s2,24(s1)
  if((p->base_trapframes = (struct trapframe *)kalloc()) == 0){
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	f12080e7          	jalr	-238(ra) # 80000ae6 <kalloc>
    80001bdc:	892a                	mv	s2,a0
    80001bde:	f4e8                	sd	a0,232(s1)
    80001be0:	c51d                	beqz	a0,80001c0e <allocproc+0x8e>
  struct kthread *new_t=allockthread(p);
    80001be2:	8526                	mv	a0,s1
    80001be4:	00001097          	auipc	ra,0x1
    80001be8:	c5c080e7          	jalr	-932(ra) # 80002840 <allockthread>
  if(new_t==0){
    80001bec:	cd0d                	beqz	a0,80001c26 <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001bee:	8526                	mv	a0,s1
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	e2c080e7          	jalr	-468(ra) # 80001a1c <proc_pagetable>
    80001bf8:	892a                	mv	s2,a0
    80001bfa:	10a4b023          	sd	a0,256(s1)
  if(p->pagetable == 0){
    80001bfe:	c121                	beqz	a0,80001c3e <allocproc+0xbe>
}
    80001c00:	8526                	mv	a0,s1
    80001c02:	60e2                	ld	ra,24(sp)
    80001c04:	6442                	ld	s0,16(sp)
    80001c06:	64a2                	ld	s1,8(sp)
    80001c08:	6902                	ld	s2,0(sp)
    80001c0a:	6105                	addi	sp,sp,32
    80001c0c:	8082                	ret
    freeproc(p);
    80001c0e:	8526                	mv	a0,s1
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	efa080e7          	jalr	-262(ra) # 80001b0a <freeproc>
    release(&p->lock);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	070080e7          	jalr	112(ra) # 80000c8a <release>
    return 0;
    80001c22:	84ca                	mv	s1,s2
    80001c24:	bff1                	j	80001c00 <allocproc+0x80>
    freeproc(p);
    80001c26:	8526                	mv	a0,s1
    80001c28:	00000097          	auipc	ra,0x0
    80001c2c:	ee2080e7          	jalr	-286(ra) # 80001b0a <freeproc>
     release(&p->lock);
    80001c30:	8526                	mv	a0,s1
    80001c32:	fffff097          	auipc	ra,0xfffff
    80001c36:	058080e7          	jalr	88(ra) # 80000c8a <release>
    return (struct proc *)-1;
    80001c3a:	54fd                	li	s1,-1
    80001c3c:	b7d1                	j	80001c00 <allocproc+0x80>
    freeproc(p);
    80001c3e:	8526                	mv	a0,s1
    80001c40:	00000097          	auipc	ra,0x0
    80001c44:	eca080e7          	jalr	-310(ra) # 80001b0a <freeproc>
    release(&p->lock);
    80001c48:	8526                	mv	a0,s1
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	040080e7          	jalr	64(ra) # 80000c8a <release>
    return 0;
    80001c52:	84ca                	mv	s1,s2
    80001c54:	b775                	j	80001c00 <allocproc+0x80>

0000000080001c56 <userinit>:
};

// Set up first user process.
void
userinit(void)
{
    80001c56:	1101                	addi	sp,sp,-32
    80001c58:	ec06                	sd	ra,24(sp)
    80001c5a:	e822                	sd	s0,16(sp)
    80001c5c:	e426                	sd	s1,8(sp)
    80001c5e:	1000                	addi	s0,sp,32
  struct proc *p;
  p = allocproc();
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	f20080e7          	jalr	-224(ra) # 80001b80 <allocproc>
    80001c68:	84aa                	mv	s1,a0
  initproc = p;
    80001c6a:	00007797          	auipc	a5,0x7
    80001c6e:	d0a7b723          	sd	a0,-754(a5) # 80008978 <initproc>
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c72:	03400613          	li	a2,52
    80001c76:	00007597          	auipc	a1,0x7
    80001c7a:	c7a58593          	addi	a1,a1,-902 # 800088f0 <initcode>
    80001c7e:	10053503          	ld	a0,256(a0)
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	6d4080e7          	jalr	1748(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001c8a:	6785                	lui	a5,0x1
    80001c8c:	fcfc                	sd	a5,248(s1)
  // prepare for the very first "return" from kernel to user.
  // mykthread()->trapframe->epc = 0;      // user program counter
  p->kthread[0].trapframe->epc=0;
    80001c8e:	70f8                	ld	a4,224(s1)
    80001c90:	00073c23          	sd	zero,24(a4)
  // mykthread()->trapframe->sp = PGSIZE;  // user stack pointer
  p->kthread[0].trapframe->sp=PGSIZE;
    80001c94:	70f8                	ld	a4,224(s1)
    80001c96:	fb1c                	sd	a5,48(a4)
  // mykthread()->t_state=RUNNABLE_t;
  p->kthread[0].t_state=RUNNABLE_t;
    80001c98:	478d                	li	a5,3
    80001c9a:	c0bc                	sw	a5,64(s1)
  release(&(p->kthread[0].t_lock));
    80001c9c:	02848513          	addi	a0,s1,40
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	fea080e7          	jalr	-22(ra) # 80000c8a <release>
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ca8:	4641                	li	a2,16
    80001caa:	00006597          	auipc	a1,0x6
    80001cae:	55658593          	addi	a1,a1,1366 # 80008200 <digits+0x1c0>
    80001cb2:	19048513          	addi	a0,s1,400
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	166080e7          	jalr	358(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cbe:	00006517          	auipc	a0,0x6
    80001cc2:	55250513          	addi	a0,a0,1362 # 80008210 <digits+0x1d0>
    80001cc6:	00002097          	auipc	ra,0x2
    80001cca:	4ce080e7          	jalr	1230(ra) # 80004194 <namei>
    80001cce:	18a4b423          	sd	a0,392(s1)

  // p->state = RUNNABLE;

  release(&p->lock);
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	fb6080e7          	jalr	-74(ra) # 80000c8a <release>

}
    80001cdc:	60e2                	ld	ra,24(sp)
    80001cde:	6442                	ld	s0,16(sp)
    80001ce0:	64a2                	ld	s1,8(sp)
    80001ce2:	6105                	addi	sp,sp,32
    80001ce4:	8082                	ret

0000000080001ce6 <growproc>:

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
    80001ce6:	1101                	addi	sp,sp,-32
    80001ce8:	ec06                	sd	ra,24(sp)
    80001cea:	e822                	sd	s0,16(sp)
    80001cec:	e426                	sd	s1,8(sp)
    80001cee:	e04a                	sd	s2,0(sp)
    80001cf0:	1000                	addi	s0,sp,32
    80001cf2:	892a                	mv	s2,a0
  uint64 sz;
  struct proc *p = myproc();
    80001cf4:	00000097          	auipc	ra,0x0
    80001cf8:	c8c080e7          	jalr	-884(ra) # 80001980 <myproc>
    80001cfc:	84aa                	mv	s1,a0

  sz = p->sz;
    80001cfe:	7d6c                	ld	a1,248(a0)
  if(n > 0){
    80001d00:	01204c63          	bgtz	s2,80001d18 <growproc+0x32>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    80001d04:	02094763          	bltz	s2,80001d32 <growproc+0x4c>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
    80001d08:	fcec                	sd	a1,248(s1)
  return 0;
    80001d0a:	4501                	li	a0,0
}
    80001d0c:	60e2                	ld	ra,24(sp)
    80001d0e:	6442                	ld	s0,16(sp)
    80001d10:	64a2                	ld	s1,8(sp)
    80001d12:	6902                	ld	s2,0(sp)
    80001d14:	6105                	addi	sp,sp,32
    80001d16:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d18:	4691                	li	a3,4
    80001d1a:	00b90633          	add	a2,s2,a1
    80001d1e:	10053503          	ld	a0,256(a0)
    80001d22:	fffff097          	auipc	ra,0xfffff
    80001d26:	6ee080e7          	jalr	1774(ra) # 80001410 <uvmalloc>
    80001d2a:	85aa                	mv	a1,a0
    80001d2c:	fd71                	bnez	a0,80001d08 <growproc+0x22>
      return -1;
    80001d2e:	557d                	li	a0,-1
    80001d30:	bff1                	j	80001d0c <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d32:	00b90633          	add	a2,s2,a1
    80001d36:	10053503          	ld	a0,256(a0)
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	68e080e7          	jalr	1678(ra) # 800013c8 <uvmdealloc>
    80001d42:	85aa                	mv	a1,a0
    80001d44:	b7d1                	j	80001d08 <growproc+0x22>

0000000080001d46 <fork>:

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
    80001d46:	7139                	addi	sp,sp,-64
    80001d48:	fc06                	sd	ra,56(sp)
    80001d4a:	f822                	sd	s0,48(sp)
    80001d4c:	f426                	sd	s1,40(sp)
    80001d4e:	f04a                	sd	s2,32(sp)
    80001d50:	ec4e                	sd	s3,24(sp)
    80001d52:	e852                	sd	s4,16(sp)
    80001d54:	e456                	sd	s5,8(sp)
    80001d56:	0080                	addi	s0,sp,64
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
    80001d58:	00000097          	auipc	ra,0x0
    80001d5c:	c28080e7          	jalr	-984(ra) # 80001980 <myproc>
    80001d60:	8aaa                	mv	s5,a0
  struct kthread *kt = mykthread();
    80001d62:	00001097          	auipc	ra,0x1
    80001d66:	a3e080e7          	jalr	-1474(ra) # 800027a0 <mykthread>
    80001d6a:	84aa                	mv	s1,a0
  printf("in fork\n");
    80001d6c:	00006517          	auipc	a0,0x6
    80001d70:	4ac50513          	addi	a0,a0,1196 # 80008218 <digits+0x1d8>
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	814080e7          	jalr	-2028(ra) # 80000588 <printf>
  // Allocate process.
  if((np = allocproc()) == 0){
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	e04080e7          	jalr	-508(ra) # 80001b80 <allocproc>
    80001d84:	12050363          	beqz	a0,80001eaa <fork+0x164>
    80001d88:	8a2a                	mv	s4,a0
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8a:	0f8ab603          	ld	a2,248(s5)
    80001d8e:	10053583          	ld	a1,256(a0)
    80001d92:	100ab503          	ld	a0,256(s5)
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	7ce080e7          	jalr	1998(ra) # 80001564 <uvmcopy>
    80001d9e:	04054763          	bltz	a0,80001dec <fork+0xa6>
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;
    80001da2:	0f8ab783          	ld	a5,248(s5)
    80001da6:	0efa3c23          	sd	a5,248(s4) # fffffffffffff0f8 <end+0xffffffff7ffdbcf8>
  //   freeproc(np);
  //    release(&np->lock);
  //   return -1;
  // }
  // copy saved user registers.
  *(np->kthread[0].trapframe) = *(kt->trapframe);
    80001daa:	7cd4                	ld	a3,184(s1)
    80001dac:	87b6                	mv	a5,a3
    80001dae:	0e0a3703          	ld	a4,224(s4)
    80001db2:	12068693          	addi	a3,a3,288
    80001db6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dba:	6788                	ld	a0,8(a5)
    80001dbc:	6b8c                	ld	a1,16(a5)
    80001dbe:	6f90                	ld	a2,24(a5)
    80001dc0:	01073023          	sd	a6,0(a4)
    80001dc4:	e708                	sd	a0,8(a4)
    80001dc6:	eb0c                	sd	a1,16(a4)
    80001dc8:	ef10                	sd	a2,24(a4)
    80001dca:	02078793          	addi	a5,a5,32
    80001dce:	02070713          	addi	a4,a4,32
    80001dd2:	fed792e3          	bne	a5,a3,80001db6 <fork+0x70>

  // Cause fork to return 0 in the child.
  np->kthread[0].trapframe->a0 = 0;
    80001dd6:	0e0a3783          	ld	a5,224(s4)
    80001dda:	0607b823          	sd	zero,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    80001dde:	108a8493          	addi	s1,s5,264
    80001de2:	108a0913          	addi	s2,s4,264
    80001de6:	188a8993          	addi	s3,s5,392
    80001dea:	a00d                	j	80001e0c <fork+0xc6>
    freeproc(np);
    80001dec:	8552                	mv	a0,s4
    80001dee:	00000097          	auipc	ra,0x0
    80001df2:	d1c080e7          	jalr	-740(ra) # 80001b0a <freeproc>
    release(&np->lock);
    80001df6:	8552                	mv	a0,s4
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	e92080e7          	jalr	-366(ra) # 80000c8a <release>
    return -1;
    80001e00:	59fd                	li	s3,-1
    80001e02:	a851                	j	80001e96 <fork+0x150>
  for(i = 0; i < NOFILE; i++)
    80001e04:	04a1                	addi	s1,s1,8
    80001e06:	0921                	addi	s2,s2,8
    80001e08:	01348b63          	beq	s1,s3,80001e1e <fork+0xd8>
    if(p->ofile[i])
    80001e0c:	6088                	ld	a0,0(s1)
    80001e0e:	d97d                	beqz	a0,80001e04 <fork+0xbe>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e10:	00003097          	auipc	ra,0x3
    80001e14:	a1a080e7          	jalr	-1510(ra) # 8000482a <filedup>
    80001e18:	00a93023          	sd	a0,0(s2)
    80001e1c:	b7e5                	j	80001e04 <fork+0xbe>
  np->cwd = idup(p->cwd);
    80001e1e:	188ab503          	ld	a0,392(s5)
    80001e22:	00002097          	auipc	ra,0x2
    80001e26:	b8e080e7          	jalr	-1138(ra) # 800039b0 <idup>
    80001e2a:	18aa3423          	sd	a0,392(s4)

  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e2e:	4641                	li	a2,16
    80001e30:	190a8593          	addi	a1,s5,400
    80001e34:	190a0513          	addi	a0,s4,400
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	fe4080e7          	jalr	-28(ra) # 80000e1c <safestrcpy>

  pid = np->pid;
    80001e40:	024a2983          	lw	s3,36(s4)

  release(&np->kthread[0].t_lock);///acqire in allockthread
    80001e44:	028a0493          	addi	s1,s4,40
    80001e48:	8526                	mv	a0,s1
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	e40080e7          	jalr	-448(ra) # 80000c8a <release>
  release(&np->lock);///acqire in allocproc
    80001e52:	8552                	mv	a0,s4
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	e36080e7          	jalr	-458(ra) # 80000c8a <release>

  acquire(&wait_lock);
    80001e5c:	0000f917          	auipc	s2,0xf
    80001e60:	dac90913          	addi	s2,s2,-596 # 80010c08 <wait_lock>
    80001e64:	854a                	mv	a0,s2
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	d70080e7          	jalr	-656(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e6e:	0f5a3823          	sd	s5,240(s4)
  release(&wait_lock);
    80001e72:	854a                	mv	a0,s2
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	e16080e7          	jalr	-490(ra) # 80000c8a <release>

  // acquire(&np->lock);
  acquire(&np->kthread[0].t_lock);
    80001e7c:	8526                	mv	a0,s1
    80001e7e:	fffff097          	auipc	ra,0xfffff
    80001e82:	d58080e7          	jalr	-680(ra) # 80000bd6 <acquire>
  np->kthread[0].t_state = RUNNABLE_t;
    80001e86:	478d                	li	a5,3
    80001e88:	04fa2023          	sw	a5,64(s4)
  release(&np->kthread[0].t_lock);
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	dfc080e7          	jalr	-516(ra) # 80000c8a <release>
  // release(&np->lock);



  return pid;
}
    80001e96:	854e                	mv	a0,s3
    80001e98:	70e2                	ld	ra,56(sp)
    80001e9a:	7442                	ld	s0,48(sp)
    80001e9c:	74a2                	ld	s1,40(sp)
    80001e9e:	7902                	ld	s2,32(sp)
    80001ea0:	69e2                	ld	s3,24(sp)
    80001ea2:	6a42                	ld	s4,16(sp)
    80001ea4:	6aa2                	ld	s5,8(sp)
    80001ea6:	6121                	addi	sp,sp,64
    80001ea8:	8082                	ret
    return -1;
    80001eaa:	59fd                	li	s3,-1
    80001eac:	b7ed                	j	80001e96 <fork+0x150>

0000000080001eae <scheduler>:
// }


void
scheduler(void)
{
    80001eae:	7159                	addi	sp,sp,-112
    80001eb0:	f486                	sd	ra,104(sp)
    80001eb2:	f0a2                	sd	s0,96(sp)
    80001eb4:	eca6                	sd	s1,88(sp)
    80001eb6:	e8ca                	sd	s2,80(sp)
    80001eb8:	e4ce                	sd	s3,72(sp)
    80001eba:	e0d2                	sd	s4,64(sp)
    80001ebc:	fc56                	sd	s5,56(sp)
    80001ebe:	f85a                	sd	s6,48(sp)
    80001ec0:	f45e                	sd	s7,40(sp)
    80001ec2:	f062                	sd	s8,32(sp)
    80001ec4:	ec66                	sd	s9,24(sp)
    80001ec6:	e86a                	sd	s10,16(sp)
    80001ec8:	e46e                	sd	s11,8(sp)
    80001eca:	1880                	addi	s0,sp,112
    80001ecc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ece:	2781                	sext.w	a5,a5
  struct proc *p;
  struct cpu *c = mycpu();
  c->kthread = 0;
    80001ed0:	00779c13          	slli	s8,a5,0x7
    80001ed4:	0000f717          	auipc	a4,0xf
    80001ed8:	d1c70713          	addi	a4,a4,-740 # 80010bf0 <pid_lock>
    80001edc:	9762                	add	a4,a4,s8
    80001ede:	02073823          	sd	zero,48(a4)
            if(kt->t_state == RUNNABLE_t) {
                  printf("22in scheduler222\n");

              kt->t_state = RUNNING_t;
              c->kthread=kt;
              swtch(&c->context, &kt->context);
    80001ee2:	0000f717          	auipc	a4,0xf
    80001ee6:	d4670713          	addi	a4,a4,-698 # 80010c28 <cpus+0x8>
    80001eea:	9c3a                	add	s8,s8,a4
    printf("in scheduler\n");
    80001eec:	00006d97          	auipc	s11,0x6
    80001ef0:	33cd8d93          	addi	s11,s11,828 # 80008228 <digits+0x1e8>
    80001ef4:	00016a17          	auipc	s4,0x16
    80001ef8:	154a0a13          	addi	s4,s4,340 # 80018048 <bcache+0x10>
                  printf("22in scheduler222\n");
    80001efc:	00006d17          	auipc	s10,0x6
    80001f00:	33cd0d13          	addi	s10,s10,828 # 80008238 <digits+0x1f8>
              c->kthread=kt;
    80001f04:	079e                	slli	a5,a5,0x7
    80001f06:	0000fb17          	auipc	s6,0xf
    80001f0a:	ceab0b13          	addi	s6,s6,-790 # 80010bf0 <pid_lock>
    80001f0e:	9b3e                	add	s6,s6,a5
              c->kthread = 0;
                                printf("33in scheduler333\n");
    80001f10:	00006c97          	auipc	s9,0x6
    80001f14:	340c8c93          	addi	s9,s9,832 # 80008250 <digits+0x210>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f18:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f1c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f20:	10079073          	csrw	sstatus,a5
    printf("in scheduler\n");
    80001f24:	856e                	mv	a0,s11
    80001f26:	ffffe097          	auipc	ra,0xffffe
    80001f2a:	662080e7          	jalr	1634(ra) # 80000588 <printf>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f2e:	0000f497          	auipc	s1,0xf
    80001f32:	11a48493          	addi	s1,s1,282 # 80011048 <proc+0x28>
      if (p->state==USED){
    80001f36:	4985                	li	s3,1
            if(kt->t_state == RUNNABLE_t) {
    80001f38:	4a8d                	li	s5,3
              kt->t_state = RUNNING_t;
    80001f3a:	4b91                	li	s7,4
    80001f3c:	a811                	j	80001f50 <scheduler+0xa2>

            }
        release(&kt->t_lock); // Release the thread lock
    80001f3e:	854a                	mv	a0,s2
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	d4a080e7          	jalr	-694(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f48:	1c048493          	addi	s1,s1,448
    80001f4c:	fc9a06e3          	beq	s4,s1,80001f18 <scheduler+0x6a>
      if (p->state==USED){
    80001f50:	8926                	mv	s2,s1
    80001f52:	ff04a783          	lw	a5,-16(s1)
    80001f56:	ff3799e3          	bne	a5,s3,80001f48 <scheduler+0x9a>
          acquire(&kt->t_lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	c7a080e7          	jalr	-902(ra) # 80000bd6 <acquire>
            if(kt->t_state == RUNNABLE_t) {
    80001f64:	4c9c                	lw	a5,24(s1)
    80001f66:	fd579ce3          	bne	a5,s5,80001f3e <scheduler+0x90>
                  printf("22in scheduler222\n");
    80001f6a:	856a                	mv	a0,s10
    80001f6c:	ffffe097          	auipc	ra,0xffffe
    80001f70:	61c080e7          	jalr	1564(ra) # 80000588 <printf>
              kt->t_state = RUNNING_t;
    80001f74:	0174ac23          	sw	s7,24(s1)
              c->kthread=kt;
    80001f78:	029b3823          	sd	s1,48(s6)
              swtch(&c->context, &kt->context);
    80001f7c:	04048593          	addi	a1,s1,64
    80001f80:	8562                	mv	a0,s8
    80001f82:	00001097          	auipc	ra,0x1
    80001f86:	99a080e7          	jalr	-1638(ra) # 8000291c <swtch>
              c->kthread = 0;
    80001f8a:	020b3823          	sd	zero,48(s6)
                                printf("33in scheduler333\n");
    80001f8e:	8566                	mv	a0,s9
    80001f90:	ffffe097          	auipc	ra,0xffffe
    80001f94:	5f8080e7          	jalr	1528(ra) # 80000588 <printf>
    80001f98:	b75d                	j	80001f3e <scheduler+0x90>

0000000080001f9a <sched>:
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    80001f9a:	7179                	addi	sp,sp,-48
    80001f9c:	f406                	sd	ra,40(sp)
    80001f9e:	f022                	sd	s0,32(sp)
    80001fa0:	ec26                	sd	s1,24(sp)
    80001fa2:	e84a                	sd	s2,16(sp)
    80001fa4:	e44e                	sd	s3,8(sp)
    80001fa6:	1800                	addi	s0,sp,48
  int intena;
  struct kthread *t = mykthread();
    80001fa8:	00000097          	auipc	ra,0x0
    80001fac:	7f8080e7          	jalr	2040(ra) # 800027a0 <mykthread>
    80001fb0:	84aa                	mv	s1,a0

  if(!holding(&t->t_lock))
    80001fb2:	fffff097          	auipc	ra,0xfffff
    80001fb6:	baa080e7          	jalr	-1110(ra) # 80000b5c <holding>
    80001fba:	c93d                	beqz	a0,80002030 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fbc:	8792                	mv	a5,tp
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    80001fbe:	2781                	sext.w	a5,a5
    80001fc0:	079e                	slli	a5,a5,0x7
    80001fc2:	0000f717          	auipc	a4,0xf
    80001fc6:	c2e70713          	addi	a4,a4,-978 # 80010bf0 <pid_lock>
    80001fca:	97ba                	add	a5,a5,a4
    80001fcc:	0a87a703          	lw	a4,168(a5)
    80001fd0:	4785                	li	a5,1
    80001fd2:	06f71763          	bne	a4,a5,80002040 <sched+0xa6>
    panic("sched locks");
  if(t->t_state == RUNNING_t)
    80001fd6:	4c98                	lw	a4,24(s1)
    80001fd8:	4791                	li	a5,4
    80001fda:	06f70b63          	beq	a4,a5,80002050 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fde:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fe2:	8b89                	andi	a5,a5,2
    panic("sched running");
  if(intr_get())
    80001fe4:	efb5                	bnez	a5,80002060 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fe6:	8792                	mv	a5,tp
    panic("sched interruptible");

  intena = mycpu()->intena;
    80001fe8:	0000f917          	auipc	s2,0xf
    80001fec:	c0890913          	addi	s2,s2,-1016 # 80010bf0 <pid_lock>
    80001ff0:	2781                	sext.w	a5,a5
    80001ff2:	079e                	slli	a5,a5,0x7
    80001ff4:	97ca                	add	a5,a5,s2
    80001ff6:	0ac7a983          	lw	s3,172(a5)
    80001ffa:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80001ffc:	2781                	sext.w	a5,a5
    80001ffe:	079e                	slli	a5,a5,0x7
    80002000:	0000f597          	auipc	a1,0xf
    80002004:	c2858593          	addi	a1,a1,-984 # 80010c28 <cpus+0x8>
    80002008:	95be                	add	a1,a1,a5
    8000200a:	04048513          	addi	a0,s1,64
    8000200e:	00001097          	auipc	ra,0x1
    80002012:	90e080e7          	jalr	-1778(ra) # 8000291c <swtch>
    80002016:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002018:	2781                	sext.w	a5,a5
    8000201a:	079e                	slli	a5,a5,0x7
    8000201c:	97ca                	add	a5,a5,s2
    8000201e:	0b37a623          	sw	s3,172(a5)
}
    80002022:	70a2                	ld	ra,40(sp)
    80002024:	7402                	ld	s0,32(sp)
    80002026:	64e2                	ld	s1,24(sp)
    80002028:	6942                	ld	s2,16(sp)
    8000202a:	69a2                	ld	s3,8(sp)
    8000202c:	6145                	addi	sp,sp,48
    8000202e:	8082                	ret
    panic("sched p->lock");
    80002030:	00006517          	auipc	a0,0x6
    80002034:	23850513          	addi	a0,a0,568 # 80008268 <digits+0x228>
    80002038:	ffffe097          	auipc	ra,0xffffe
    8000203c:	506080e7          	jalr	1286(ra) # 8000053e <panic>
    panic("sched locks");
    80002040:	00006517          	auipc	a0,0x6
    80002044:	23850513          	addi	a0,a0,568 # 80008278 <digits+0x238>
    80002048:	ffffe097          	auipc	ra,0xffffe
    8000204c:	4f6080e7          	jalr	1270(ra) # 8000053e <panic>
    panic("sched running");
    80002050:	00006517          	auipc	a0,0x6
    80002054:	23850513          	addi	a0,a0,568 # 80008288 <digits+0x248>
    80002058:	ffffe097          	auipc	ra,0xffffe
    8000205c:	4e6080e7          	jalr	1254(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002060:	00006517          	auipc	a0,0x6
    80002064:	23850513          	addi	a0,a0,568 # 80008298 <digits+0x258>
    80002068:	ffffe097          	auipc	ra,0xffffe
    8000206c:	4d6080e7          	jalr	1238(ra) # 8000053e <panic>

0000000080002070 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
    80002070:	1101                	addi	sp,sp,-32
    80002072:	ec06                	sd	ra,24(sp)
    80002074:	e822                	sd	s0,16(sp)
    80002076:	e426                	sd	s1,8(sp)
    80002078:	e04a                	sd	s2,0(sp)
    8000207a:	1000                	addi	s0,sp,32
  printf("in yield\n");
    8000207c:	00006517          	auipc	a0,0x6
    80002080:	23450513          	addi	a0,a0,564 # 800082b0 <digits+0x270>
    80002084:	ffffe097          	auipc	ra,0xffffe
    80002088:	504080e7          	jalr	1284(ra) # 80000588 <printf>
  struct proc *p = myproc();
    8000208c:	00000097          	auipc	ra,0x0
    80002090:	8f4080e7          	jalr	-1804(ra) # 80001980 <myproc>
    80002094:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002096:	fffff097          	auipc	ra,0xfffff
    8000209a:	b40080e7          	jalr	-1216(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    8000209e:	02848913          	addi	s2,s1,40
    800020a2:	854a                	mv	a0,s2
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	b32080e7          	jalr	-1230(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state = RUNNABLE_t;
    800020ac:	478d                	li	a5,3
    800020ae:	c0bc                	sw	a5,64(s1)
  release(&p->kthread[0].t_lock);
    800020b0:	854a                	mv	a0,s2
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	bd8080e7          	jalr	-1064(ra) # 80000c8a <release>
  sched();
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	ee0080e7          	jalr	-288(ra) # 80001f9a <sched>
  release(&p->lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	bc6080e7          	jalr	-1082(ra) # 80000c8a <release>
}
    800020cc:	60e2                	ld	ra,24(sp)
    800020ce:	6442                	ld	s0,16(sp)
    800020d0:	64a2                	ld	s1,8(sp)
    800020d2:	6902                	ld	s2,0(sp)
    800020d4:	6105                	addi	sp,sp,32
    800020d6:	8082                	ret

00000000800020d8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800020d8:	1141                	addi	sp,sp,-16
    800020da:	e406                	sd	ra,8(sp)
    800020dc:	e022                	sd	s0,0(sp)
    800020de:	0800                	addi	s0,sp,16
  printf("forkret\n");
    800020e0:	00006517          	auipc	a0,0x6
    800020e4:	1e050513          	addi	a0,a0,480 # 800082c0 <digits+0x280>
    800020e8:	ffffe097          	auipc	ra,0xffffe
    800020ec:	4a0080e7          	jalr	1184(ra) # 80000588 <printf>
  static int first = 1;
  release(&(mykthread()->t_lock)); //still holding kt->lock from scheduler
    800020f0:	00000097          	auipc	ra,0x0
    800020f4:	6b0080e7          	jalr	1712(ra) # 800027a0 <mykthread>
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	b92080e7          	jalr	-1134(ra) # 80000c8a <release>
  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);

  if (first) {
    80002100:	00006797          	auipc	a5,0x6
    80002104:	7e07a783          	lw	a5,2016(a5) # 800088e0 <first.1>
    80002108:	eb89                	bnez	a5,8000211a <forkret+0x42>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    8000210a:	00001097          	auipc	ra,0x1
    8000210e:	8bc080e7          	jalr	-1860(ra) # 800029c6 <usertrapret>
}
    80002112:	60a2                	ld	ra,8(sp)
    80002114:	6402                	ld	s0,0(sp)
    80002116:	0141                	addi	sp,sp,16
    80002118:	8082                	ret
    first = 0;
    8000211a:	00006797          	auipc	a5,0x6
    8000211e:	7c07a323          	sw	zero,1990(a5) # 800088e0 <first.1>
    fsinit(ROOTDEV);
    80002122:	4505                	li	a0,1
    80002124:	00001097          	auipc	ra,0x1
    80002128:	64e080e7          	jalr	1614(ra) # 80003772 <fsinit>
    8000212c:	bff9                	j	8000210a <forkret+0x32>

000000008000212e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000212e:	7179                	addi	sp,sp,-48
    80002130:	f406                	sd	ra,40(sp)
    80002132:	f022                	sd	s0,32(sp)
    80002134:	ec26                	sd	s1,24(sp)
    80002136:	e84a                	sd	s2,16(sp)
    80002138:	e44e                	sd	s3,8(sp)
    8000213a:	e052                	sd	s4,0(sp)
    8000213c:	1800                	addi	s0,sp,48
    8000213e:	89aa                	mv	s3,a0
    80002140:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002142:	00000097          	auipc	ra,0x0
    80002146:	83e080e7          	jalr	-1986(ra) # 80001980 <myproc>
    8000214a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	a8a080e7          	jalr	-1398(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    80002154:	02848a13          	addi	s4,s1,40
    80002158:	8552                	mv	a0,s4
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	a7c080e7          	jalr	-1412(ra) # 80000bd6 <acquire>
  release(lk);
    80002162:	854a                	mv	a0,s2
    80002164:	fffff097          	auipc	ra,0xfffff
    80002168:	b26080e7          	jalr	-1242(ra) # 80000c8a <release>

  // Go to sleep.
  p->kthread[0].chan = chan;
    8000216c:	0534b423          	sd	s3,72(s1)
  p->kthread[0].t_state = SLEEPING_t;
    80002170:	4789                	li	a5,2
    80002172:	c0bc                	sw	a5,64(s1)

  sched();
    80002174:	00000097          	auipc	ra,0x0
    80002178:	e26080e7          	jalr	-474(ra) # 80001f9a <sched>

  // Tidy up.
  p->kthread[0].chan= 0;
    8000217c:	0404b423          	sd	zero,72(s1)

  // Reacquire original lock.
  release(&p->kthread[0].t_lock);
    80002180:	8552                	mv	a0,s4
    80002182:	fffff097          	auipc	ra,0xfffff
    80002186:	b08080e7          	jalr	-1272(ra) # 80000c8a <release>
  release(&p->lock);
    8000218a:	8526                	mv	a0,s1
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	afe080e7          	jalr	-1282(ra) # 80000c8a <release>
  acquire(lk);
    80002194:	854a                	mv	a0,s2
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	a40080e7          	jalr	-1472(ra) # 80000bd6 <acquire>
}
    8000219e:	70a2                	ld	ra,40(sp)
    800021a0:	7402                	ld	s0,32(sp)
    800021a2:	64e2                	ld	s1,24(sp)
    800021a4:	6942                	ld	s2,16(sp)
    800021a6:	69a2                	ld	s3,8(sp)
    800021a8:	6a02                	ld	s4,0(sp)
    800021aa:	6145                	addi	sp,sp,48
    800021ac:	8082                	ret

00000000800021ae <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021ae:	711d                	addi	sp,sp,-96
    800021b0:	ec86                	sd	ra,88(sp)
    800021b2:	e8a2                	sd	s0,80(sp)
    800021b4:	e4a6                	sd	s1,72(sp)
    800021b6:	e0ca                	sd	s2,64(sp)
    800021b8:	fc4e                	sd	s3,56(sp)
    800021ba:	f852                	sd	s4,48(sp)
    800021bc:	f456                	sd	s5,40(sp)
    800021be:	f05a                	sd	s6,32(sp)
    800021c0:	ec5e                	sd	s7,24(sp)
    800021c2:	e862                	sd	s8,16(sp)
    800021c4:	e466                	sd	s9,8(sp)
    800021c6:	1080                	addi	s0,sp,96
    800021c8:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *kt;
  for(p = proc; p < &proc[NPROC]; p++) {
    800021ca:	0000f497          	auipc	s1,0xf
    800021ce:	e7e48493          	addi	s1,s1,-386 # 80011048 <proc+0x28>
    800021d2:	00016a97          	auipc	s5,0x16
    800021d6:	e76a8a93          	addi	s5,s5,-394 # 80018048 <bcache+0x10>
              printf("start of wakeup\n");
    800021da:	00006a17          	auipc	s4,0x6
    800021de:	0f6a0a13          	addi	s4,s4,246 # 800082d0 <digits+0x290>
    // acquire(&p->lock);
      printf("in wakeup\n");
    800021e2:	00006997          	auipc	s3,0x6
    800021e6:	10698993          	addi	s3,s3,262 # 800082e8 <digits+0x2a8>
      // acquire(&p->lock);
    for(kt=p->kthread;kt<&p->kthread[NKT];kt++){
        if(kt !=mykthread()){
          acquire(&kt->t_lock);
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    800021ea:	4b89                	li	s7,2
          kt->t_state = RUNNABLE_t;
        }
        release(&kt->t_lock);
      // release(&p->lock);
          printf("out wakeup\n");
    800021ec:	00006b17          	auipc	s6,0x6
    800021f0:	10cb0b13          	addi	s6,s6,268 # 800082f8 <digits+0x2b8>
          kt->t_state = RUNNABLE_t;
    800021f4:	4c8d                	li	s9,3
    800021f6:	a839                	j	80002214 <wakeup+0x66>
        release(&kt->t_lock);
    800021f8:	854a                	mv	a0,s2
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	a90080e7          	jalr	-1392(ra) # 80000c8a <release>
          printf("out wakeup\n");
    80002202:	855a                	mv	a0,s6
    80002204:	ffffe097          	auipc	ra,0xffffe
    80002208:	384080e7          	jalr	900(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000220c:	1c048493          	addi	s1,s1,448
    80002210:	049a8163          	beq	s5,s1,80002252 <wakeup+0xa4>
              printf("start of wakeup\n");
    80002214:	8552                	mv	a0,s4
    80002216:	ffffe097          	auipc	ra,0xffffe
    8000221a:	372080e7          	jalr	882(ra) # 80000588 <printf>
      printf("in wakeup\n");
    8000221e:	854e                	mv	a0,s3
    80002220:	ffffe097          	auipc	ra,0xffffe
    80002224:	368080e7          	jalr	872(ra) # 80000588 <printf>
        if(kt !=mykthread()){
    80002228:	00000097          	auipc	ra,0x0
    8000222c:	578080e7          	jalr	1400(ra) # 800027a0 <mykthread>
    80002230:	8926                	mv	s2,s1
    80002232:	fc950de3          	beq	a0,s1,8000220c <wakeup+0x5e>
          acquire(&kt->t_lock);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	99e080e7          	jalr	-1634(ra) # 80000bd6 <acquire>
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    80002240:	4c9c                	lw	a5,24(s1)
    80002242:	fb779be3          	bne	a5,s7,800021f8 <wakeup+0x4a>
    80002246:	709c                	ld	a5,32(s1)
    80002248:	fb8798e3          	bne	a5,s8,800021f8 <wakeup+0x4a>
          kt->t_state = RUNNABLE_t;
    8000224c:	0194ac23          	sw	s9,24(s1)
    80002250:	b765                	j	800021f8 <wakeup+0x4a>

       }
    }
    // release(&p->lock);
  }
}
    80002252:	60e6                	ld	ra,88(sp)
    80002254:	6446                	ld	s0,80(sp)
    80002256:	64a6                	ld	s1,72(sp)
    80002258:	6906                	ld	s2,64(sp)
    8000225a:	79e2                	ld	s3,56(sp)
    8000225c:	7a42                	ld	s4,48(sp)
    8000225e:	7aa2                	ld	s5,40(sp)
    80002260:	7b02                	ld	s6,32(sp)
    80002262:	6be2                	ld	s7,24(sp)
    80002264:	6c42                	ld	s8,16(sp)
    80002266:	6ca2                	ld	s9,8(sp)
    80002268:	6125                	addi	sp,sp,96
    8000226a:	8082                	ret

000000008000226c <reparent>:
{
    8000226c:	7179                	addi	sp,sp,-48
    8000226e:	f406                	sd	ra,40(sp)
    80002270:	f022                	sd	s0,32(sp)
    80002272:	ec26                	sd	s1,24(sp)
    80002274:	e84a                	sd	s2,16(sp)
    80002276:	e44e                	sd	s3,8(sp)
    80002278:	e052                	sd	s4,0(sp)
    8000227a:	1800                	addi	s0,sp,48
    8000227c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000227e:	0000f497          	auipc	s1,0xf
    80002282:	da248493          	addi	s1,s1,-606 # 80011020 <proc>
      pp->parent = initproc;
    80002286:	00006a17          	auipc	s4,0x6
    8000228a:	6f2a0a13          	addi	s4,s4,1778 # 80008978 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000228e:	00016997          	auipc	s3,0x16
    80002292:	d9298993          	addi	s3,s3,-622 # 80018020 <tickslock>
    80002296:	a029                	j	800022a0 <reparent+0x34>
    80002298:	1c048493          	addi	s1,s1,448
    8000229c:	01348d63          	beq	s1,s3,800022b6 <reparent+0x4a>
    if(pp->parent == p){
    800022a0:	78fc                	ld	a5,240(s1)
    800022a2:	ff279be3          	bne	a5,s2,80002298 <reparent+0x2c>
      pp->parent = initproc;
    800022a6:	000a3503          	ld	a0,0(s4)
    800022aa:	f8e8                	sd	a0,240(s1)
      wakeup(initproc);
    800022ac:	00000097          	auipc	ra,0x0
    800022b0:	f02080e7          	jalr	-254(ra) # 800021ae <wakeup>
    800022b4:	b7d5                	j	80002298 <reparent+0x2c>
}
    800022b6:	70a2                	ld	ra,40(sp)
    800022b8:	7402                	ld	s0,32(sp)
    800022ba:	64e2                	ld	s1,24(sp)
    800022bc:	6942                	ld	s2,16(sp)
    800022be:	69a2                	ld	s3,8(sp)
    800022c0:	6a02                	ld	s4,0(sp)
    800022c2:	6145                	addi	sp,sp,48
    800022c4:	8082                	ret

00000000800022c6 <exit>:
{
    800022c6:	7179                	addi	sp,sp,-48
    800022c8:	f406                	sd	ra,40(sp)
    800022ca:	f022                	sd	s0,32(sp)
    800022cc:	ec26                	sd	s1,24(sp)
    800022ce:	e84a                	sd	s2,16(sp)
    800022d0:	e44e                	sd	s3,8(sp)
    800022d2:	e052                	sd	s4,0(sp)
    800022d4:	1800                	addi	s0,sp,48
    800022d6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	6a8080e7          	jalr	1704(ra) # 80001980 <myproc>
    800022e0:	89aa                	mv	s3,a0
  if(p == initproc)
    800022e2:	00006797          	auipc	a5,0x6
    800022e6:	6967b783          	ld	a5,1686(a5) # 80008978 <initproc>
    800022ea:	10850493          	addi	s1,a0,264
    800022ee:	18850913          	addi	s2,a0,392
    800022f2:	02a79363          	bne	a5,a0,80002318 <exit+0x52>
    panic("init exiting");
    800022f6:	00006517          	auipc	a0,0x6
    800022fa:	01250513          	addi	a0,a0,18 # 80008308 <digits+0x2c8>
    800022fe:	ffffe097          	auipc	ra,0xffffe
    80002302:	240080e7          	jalr	576(ra) # 8000053e <panic>
      fileclose(f);
    80002306:	00002097          	auipc	ra,0x2
    8000230a:	576080e7          	jalr	1398(ra) # 8000487c <fileclose>
      p->ofile[fd] = 0;
    8000230e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002312:	04a1                	addi	s1,s1,8
    80002314:	01248563          	beq	s1,s2,8000231e <exit+0x58>
    if(p->ofile[fd]){
    80002318:	6088                	ld	a0,0(s1)
    8000231a:	f575                	bnez	a0,80002306 <exit+0x40>
    8000231c:	bfdd                	j	80002312 <exit+0x4c>
  begin_op();
    8000231e:	00002097          	auipc	ra,0x2
    80002322:	092080e7          	jalr	146(ra) # 800043b0 <begin_op>
  iput(p->cwd);
    80002326:	1889b503          	ld	a0,392(s3)
    8000232a:	00002097          	auipc	ra,0x2
    8000232e:	87e080e7          	jalr	-1922(ra) # 80003ba8 <iput>
  end_op();
    80002332:	00002097          	auipc	ra,0x2
    80002336:	0fe080e7          	jalr	254(ra) # 80004430 <end_op>
  p->cwd = 0;
    8000233a:	1809b423          	sd	zero,392(s3)
  acquire(&wait_lock);
    8000233e:	0000f497          	auipc	s1,0xf
    80002342:	8ca48493          	addi	s1,s1,-1846 # 80010c08 <wait_lock>
    80002346:	8526                	mv	a0,s1
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	88e080e7          	jalr	-1906(ra) # 80000bd6 <acquire>
  reparent(p);
    80002350:	854e                	mv	a0,s3
    80002352:	00000097          	auipc	ra,0x0
    80002356:	f1a080e7          	jalr	-230(ra) # 8000226c <reparent>
  wakeup(p->parent);
    8000235a:	0f09b503          	ld	a0,240(s3)
    8000235e:	00000097          	auipc	ra,0x0
    80002362:	e50080e7          	jalr	-432(ra) # 800021ae <wakeup>
  acquire(&p->lock);
    80002366:	854e                	mv	a0,s3
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	86e080e7          	jalr	-1938(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    80002370:	02898913          	addi	s2,s3,40
    80002374:	854a                	mv	a0,s2
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	860080e7          	jalr	-1952(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state=ZOMBIE_t;
    8000237e:	4795                	li	a5,5
    80002380:	04f9a023          	sw	a5,64(s3)
  release(&p->kthread[0].t_lock);
    80002384:	854a                	mv	a0,s2
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	904080e7          	jalr	-1788(ra) # 80000c8a <release>
  p->xstate = status;
    8000238e:	0349a023          	sw	s4,32(s3)
  p->state = ZOMBIE;
    80002392:	4789                	li	a5,2
    80002394:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002398:	8526                	mv	a0,s1
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	8f0080e7          	jalr	-1808(ra) # 80000c8a <release>
  sched();
    800023a2:	00000097          	auipc	ra,0x0
    800023a6:	bf8080e7          	jalr	-1032(ra) # 80001f9a <sched>
  panic("zombie exit");
    800023aa:	00006517          	auipc	a0,0x6
    800023ae:	f6e50513          	addi	a0,a0,-146 # 80008318 <digits+0x2d8>
    800023b2:	ffffe097          	auipc	ra,0xffffe
    800023b6:	18c080e7          	jalr	396(ra) # 8000053e <panic>

00000000800023ba <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023ba:	7179                	addi	sp,sp,-48
    800023bc:	f406                	sd	ra,40(sp)
    800023be:	f022                	sd	s0,32(sp)
    800023c0:	ec26                	sd	s1,24(sp)
    800023c2:	e84a                	sd	s2,16(sp)
    800023c4:	e44e                	sd	s3,8(sp)
    800023c6:	1800                	addi	s0,sp,48
    800023c8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023ca:	0000f497          	auipc	s1,0xf
    800023ce:	c5648493          	addi	s1,s1,-938 # 80011020 <proc>
    800023d2:	00016997          	auipc	s3,0x16
    800023d6:	c4e98993          	addi	s3,s3,-946 # 80018020 <tickslock>
    acquire(&p->lock);
    800023da:	8526                	mv	a0,s1
    800023dc:	ffffe097          	auipc	ra,0xffffe
    800023e0:	7fa080e7          	jalr	2042(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800023e4:	50dc                	lw	a5,36(s1)
    800023e6:	01278d63          	beq	a5,s2,80002400 <kill+0x46>
      // }
      release(&p->lock);
      return 0;
    }
    
    release(&p->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	89e080e7          	jalr	-1890(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023f4:	1c048493          	addi	s1,s1,448
    800023f8:	ff3491e3          	bne	s1,s3,800023da <kill+0x20>
  }
  return -1;
    800023fc:	557d                	li	a0,-1
    800023fe:	a80d                	j	80002430 <kill+0x76>
      p->killed = 1;
    80002400:	4785                	li	a5,1
    80002402:	ccdc                	sw	a5,28(s1)
        acquire(&t->t_lock);
    80002404:	02848913          	addi	s2,s1,40
    80002408:	854a                	mv	a0,s2
    8000240a:	ffffe097          	auipc	ra,0xffffe
    8000240e:	7cc080e7          	jalr	1996(ra) # 80000bd6 <acquire>
        if(t->t_state == SLEEPING_t) {
    80002412:	40b8                	lw	a4,64(s1)
    80002414:	4789                	li	a5,2
    80002416:	02f70463          	beq	a4,a5,8000243e <kill+0x84>
        release(&t->t_lock);
    8000241a:	854a                	mv	a0,s2
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	86e080e7          	jalr	-1938(ra) # 80000c8a <release>
      release(&p->lock);
    80002424:	8526                	mv	a0,s1
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	864080e7          	jalr	-1948(ra) # 80000c8a <release>
      return 0;
    8000242e:	4501                	li	a0,0
}
    80002430:	70a2                	ld	ra,40(sp)
    80002432:	7402                	ld	s0,32(sp)
    80002434:	64e2                	ld	s1,24(sp)
    80002436:	6942                	ld	s2,16(sp)
    80002438:	69a2                	ld	s3,8(sp)
    8000243a:	6145                	addi	sp,sp,48
    8000243c:	8082                	ret
          t->t_state = RUNNABLE_t;
    8000243e:	478d                	li	a5,3
    80002440:	c0bc                	sw	a5,64(s1)
    80002442:	bfe1                	j	8000241a <kill+0x60>

0000000080002444 <setkilled>:


void
setkilled(struct proc *p)
{
    80002444:	1101                	addi	sp,sp,-32
    80002446:	ec06                	sd	ra,24(sp)
    80002448:	e822                	sd	s0,16(sp)
    8000244a:	e426                	sd	s1,8(sp)
    8000244c:	1000                	addi	s0,sp,32
    8000244e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002450:	ffffe097          	auipc	ra,0xffffe
    80002454:	786080e7          	jalr	1926(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002458:	4785                	li	a5,1
    8000245a:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    8000245c:	8526                	mv	a0,s1
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	82c080e7          	jalr	-2004(ra) # 80000c8a <release>
}
    80002466:	60e2                	ld	ra,24(sp)
    80002468:	6442                	ld	s0,16(sp)
    8000246a:	64a2                	ld	s1,8(sp)
    8000246c:	6105                	addi	sp,sp,32
    8000246e:	8082                	ret

0000000080002470 <killed>:

int
killed(struct proc *p)
{
    80002470:	1101                	addi	sp,sp,-32
    80002472:	ec06                	sd	ra,24(sp)
    80002474:	e822                	sd	s0,16(sp)
    80002476:	e426                	sd	s1,8(sp)
    80002478:	e04a                	sd	s2,0(sp)
    8000247a:	1000                	addi	s0,sp,32
    8000247c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000247e:	ffffe097          	auipc	ra,0xffffe
    80002482:	758080e7          	jalr	1880(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002486:	01c4a903          	lw	s2,28(s1)
  release(&p->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	7fe080e7          	jalr	2046(ra) # 80000c8a <release>
  return k;
}
    80002494:	854a                	mv	a0,s2
    80002496:	60e2                	ld	ra,24(sp)
    80002498:	6442                	ld	s0,16(sp)
    8000249a:	64a2                	ld	s1,8(sp)
    8000249c:	6902                	ld	s2,0(sp)
    8000249e:	6105                	addi	sp,sp,32
    800024a0:	8082                	ret

00000000800024a2 <wait>:
{
    800024a2:	715d                	addi	sp,sp,-80
    800024a4:	e486                	sd	ra,72(sp)
    800024a6:	e0a2                	sd	s0,64(sp)
    800024a8:	fc26                	sd	s1,56(sp)
    800024aa:	f84a                	sd	s2,48(sp)
    800024ac:	f44e                	sd	s3,40(sp)
    800024ae:	f052                	sd	s4,32(sp)
    800024b0:	ec56                	sd	s5,24(sp)
    800024b2:	e85a                	sd	s6,16(sp)
    800024b4:	e45e                	sd	s7,8(sp)
    800024b6:	e062                	sd	s8,0(sp)
    800024b8:	0880                	addi	s0,sp,80
    800024ba:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024bc:	fffff097          	auipc	ra,0xfffff
    800024c0:	4c4080e7          	jalr	1220(ra) # 80001980 <myproc>
    800024c4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024c6:	0000e517          	auipc	a0,0xe
    800024ca:	74250513          	addi	a0,a0,1858 # 80010c08 <wait_lock>
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	708080e7          	jalr	1800(ra) # 80000bd6 <acquire>
    havekids = 0;
    800024d6:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800024d8:	4a09                	li	s4,2
        havekids = 1;
    800024da:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024dc:	00016997          	auipc	s3,0x16
    800024e0:	b4498993          	addi	s3,s3,-1212 # 80018020 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024e4:	0000ec17          	auipc	s8,0xe
    800024e8:	724c0c13          	addi	s8,s8,1828 # 80010c08 <wait_lock>
    havekids = 0;
    800024ec:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024ee:	0000f497          	auipc	s1,0xf
    800024f2:	b3248493          	addi	s1,s1,-1230 # 80011020 <proc>
    800024f6:	a0bd                	j	80002564 <wait+0xc2>
          pid = pp->pid;
    800024f8:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024fc:	000b0e63          	beqz	s6,80002518 <wait+0x76>
    80002500:	4691                	li	a3,4
    80002502:	02048613          	addi	a2,s1,32
    80002506:	85da                	mv	a1,s6
    80002508:	10093503          	ld	a0,256(s2)
    8000250c:	fffff097          	auipc	ra,0xfffff
    80002510:	15c080e7          	jalr	348(ra) # 80001668 <copyout>
    80002514:	02054563          	bltz	a0,8000253e <wait+0x9c>
          freeproc(pp);
    80002518:	8526                	mv	a0,s1
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	5f0080e7          	jalr	1520(ra) # 80001b0a <freeproc>
          release(&pp->lock);
    80002522:	8526                	mv	a0,s1
    80002524:	ffffe097          	auipc	ra,0xffffe
    80002528:	766080e7          	jalr	1894(ra) # 80000c8a <release>
          release(&wait_lock);
    8000252c:	0000e517          	auipc	a0,0xe
    80002530:	6dc50513          	addi	a0,a0,1756 # 80010c08 <wait_lock>
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	756080e7          	jalr	1878(ra) # 80000c8a <release>
          return pid;
    8000253c:	a0b5                	j	800025a8 <wait+0x106>
            release(&pp->lock);
    8000253e:	8526                	mv	a0,s1
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	74a080e7          	jalr	1866(ra) # 80000c8a <release>
            release(&wait_lock);
    80002548:	0000e517          	auipc	a0,0xe
    8000254c:	6c050513          	addi	a0,a0,1728 # 80010c08 <wait_lock>
    80002550:	ffffe097          	auipc	ra,0xffffe
    80002554:	73a080e7          	jalr	1850(ra) # 80000c8a <release>
            return -1;
    80002558:	59fd                	li	s3,-1
    8000255a:	a0b9                	j	800025a8 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000255c:	1c048493          	addi	s1,s1,448
    80002560:	03348463          	beq	s1,s3,80002588 <wait+0xe6>
      if(pp->parent == p){
    80002564:	78fc                	ld	a5,240(s1)
    80002566:	ff279be3          	bne	a5,s2,8000255c <wait+0xba>
        acquire(&pp->lock);
    8000256a:	8526                	mv	a0,s1
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	66a080e7          	jalr	1642(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002574:	4c9c                	lw	a5,24(s1)
    80002576:	f94781e3          	beq	a5,s4,800024f8 <wait+0x56>
        release(&pp->lock);
    8000257a:	8526                	mv	a0,s1
    8000257c:	ffffe097          	auipc	ra,0xffffe
    80002580:	70e080e7          	jalr	1806(ra) # 80000c8a <release>
        havekids = 1;
    80002584:	8756                	mv	a4,s5
    80002586:	bfd9                	j	8000255c <wait+0xba>
    if(!havekids || killed(p)){
    80002588:	c719                	beqz	a4,80002596 <wait+0xf4>
    8000258a:	854a                	mv	a0,s2
    8000258c:	00000097          	auipc	ra,0x0
    80002590:	ee4080e7          	jalr	-284(ra) # 80002470 <killed>
    80002594:	c51d                	beqz	a0,800025c2 <wait+0x120>
      release(&wait_lock);
    80002596:	0000e517          	auipc	a0,0xe
    8000259a:	67250513          	addi	a0,a0,1650 # 80010c08 <wait_lock>
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	6ec080e7          	jalr	1772(ra) # 80000c8a <release>
      return -1;
    800025a6:	59fd                	li	s3,-1
}
    800025a8:	854e                	mv	a0,s3
    800025aa:	60a6                	ld	ra,72(sp)
    800025ac:	6406                	ld	s0,64(sp)
    800025ae:	74e2                	ld	s1,56(sp)
    800025b0:	7942                	ld	s2,48(sp)
    800025b2:	79a2                	ld	s3,40(sp)
    800025b4:	7a02                	ld	s4,32(sp)
    800025b6:	6ae2                	ld	s5,24(sp)
    800025b8:	6b42                	ld	s6,16(sp)
    800025ba:	6ba2                	ld	s7,8(sp)
    800025bc:	6c02                	ld	s8,0(sp)
    800025be:	6161                	addi	sp,sp,80
    800025c0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025c2:	85e2                	mv	a1,s8
    800025c4:	854a                	mv	a0,s2
    800025c6:	00000097          	auipc	ra,0x0
    800025ca:	b68080e7          	jalr	-1176(ra) # 8000212e <sleep>
    havekids = 0;
    800025ce:	bf39                	j	800024ec <wait+0x4a>

00000000800025d0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025d0:	7179                	addi	sp,sp,-48
    800025d2:	f406                	sd	ra,40(sp)
    800025d4:	f022                	sd	s0,32(sp)
    800025d6:	ec26                	sd	s1,24(sp)
    800025d8:	e84a                	sd	s2,16(sp)
    800025da:	e44e                	sd	s3,8(sp)
    800025dc:	e052                	sd	s4,0(sp)
    800025de:	1800                	addi	s0,sp,48
    800025e0:	84aa                	mv	s1,a0
    800025e2:	892e                	mv	s2,a1
    800025e4:	89b2                	mv	s3,a2
    800025e6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025e8:	fffff097          	auipc	ra,0xfffff
    800025ec:	398080e7          	jalr	920(ra) # 80001980 <myproc>
  if(user_dst){
    800025f0:	c095                	beqz	s1,80002614 <either_copyout+0x44>
    return copyout(p->pagetable, dst, src, len);
    800025f2:	86d2                	mv	a3,s4
    800025f4:	864e                	mv	a2,s3
    800025f6:	85ca                	mv	a1,s2
    800025f8:	10053503          	ld	a0,256(a0)
    800025fc:	fffff097          	auipc	ra,0xfffff
    80002600:	06c080e7          	jalr	108(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002604:	70a2                	ld	ra,40(sp)
    80002606:	7402                	ld	s0,32(sp)
    80002608:	64e2                	ld	s1,24(sp)
    8000260a:	6942                	ld	s2,16(sp)
    8000260c:	69a2                	ld	s3,8(sp)
    8000260e:	6a02                	ld	s4,0(sp)
    80002610:	6145                	addi	sp,sp,48
    80002612:	8082                	ret
    memmove((char *)dst, src, len);
    80002614:	000a061b          	sext.w	a2,s4
    80002618:	85ce                	mv	a1,s3
    8000261a:	854a                	mv	a0,s2
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	712080e7          	jalr	1810(ra) # 80000d2e <memmove>
    return 0;
    80002624:	8526                	mv	a0,s1
    80002626:	bff9                	j	80002604 <either_copyout+0x34>

0000000080002628 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002628:	7179                	addi	sp,sp,-48
    8000262a:	f406                	sd	ra,40(sp)
    8000262c:	f022                	sd	s0,32(sp)
    8000262e:	ec26                	sd	s1,24(sp)
    80002630:	e84a                	sd	s2,16(sp)
    80002632:	e44e                	sd	s3,8(sp)
    80002634:	e052                	sd	s4,0(sp)
    80002636:	1800                	addi	s0,sp,48
    80002638:	892a                	mv	s2,a0
    8000263a:	84ae                	mv	s1,a1
    8000263c:	89b2                	mv	s3,a2
    8000263e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002640:	fffff097          	auipc	ra,0xfffff
    80002644:	340080e7          	jalr	832(ra) # 80001980 <myproc>
  if(user_src){
    80002648:	c095                	beqz	s1,8000266c <either_copyin+0x44>
    return copyin(p->pagetable, dst, src, len);
    8000264a:	86d2                	mv	a3,s4
    8000264c:	864e                	mv	a2,s3
    8000264e:	85ca                	mv	a1,s2
    80002650:	10053503          	ld	a0,256(a0)
    80002654:	fffff097          	auipc	ra,0xfffff
    80002658:	0a0080e7          	jalr	160(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000265c:	70a2                	ld	ra,40(sp)
    8000265e:	7402                	ld	s0,32(sp)
    80002660:	64e2                	ld	s1,24(sp)
    80002662:	6942                	ld	s2,16(sp)
    80002664:	69a2                	ld	s3,8(sp)
    80002666:	6a02                	ld	s4,0(sp)
    80002668:	6145                	addi	sp,sp,48
    8000266a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000266c:	000a061b          	sext.w	a2,s4
    80002670:	85ce                	mv	a1,s3
    80002672:	854a                	mv	a0,s2
    80002674:	ffffe097          	auipc	ra,0xffffe
    80002678:	6ba080e7          	jalr	1722(ra) # 80000d2e <memmove>
    return 0;
    8000267c:	8526                	mv	a0,s1
    8000267e:	bff9                	j	8000265c <either_copyin+0x34>

0000000080002680 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002680:	715d                	addi	sp,sp,-80
    80002682:	e486                	sd	ra,72(sp)
    80002684:	e0a2                	sd	s0,64(sp)
    80002686:	fc26                	sd	s1,56(sp)
    80002688:	f84a                	sd	s2,48(sp)
    8000268a:	f44e                	sd	s3,40(sp)
    8000268c:	f052                	sd	s4,32(sp)
    8000268e:	ec56                	sd	s5,24(sp)
    80002690:	e85a                	sd	s6,16(sp)
    80002692:	e45e                	sd	s7,8(sp)
    80002694:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002696:	00006517          	auipc	a0,0x6
    8000269a:	c2250513          	addi	a0,a0,-990 # 800082b8 <digits+0x278>
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	eea080e7          	jalr	-278(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026a6:	0000f497          	auipc	s1,0xf
    800026aa:	b0a48493          	addi	s1,s1,-1270 # 800111b0 <proc+0x190>
    800026ae:	00016917          	auipc	s2,0x16
    800026b2:	b0290913          	addi	s2,s2,-1278 # 800181b0 <bcache+0x178>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b6:	4b09                	li	s6,2
      state = states[p->state];
    else
      state = "???";
    800026b8:	00006997          	auipc	s3,0x6
    800026bc:	c7098993          	addi	s3,s3,-912 # 80008328 <digits+0x2e8>
    printf("%d %s %s", p->pid, state, p->name);
    800026c0:	00006a97          	auipc	s5,0x6
    800026c4:	c70a8a93          	addi	s5,s5,-912 # 80008330 <digits+0x2f0>
    printf("\n");
    800026c8:	00006a17          	auipc	s4,0x6
    800026cc:	bf0a0a13          	addi	s4,s4,-1040 # 800082b8 <digits+0x278>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026d0:	00006b97          	auipc	s7,0x6
    800026d4:	c88b8b93          	addi	s7,s7,-888 # 80008358 <states.0>
    800026d8:	a00d                	j	800026fa <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026da:	e946a583          	lw	a1,-364(a3)
    800026de:	8556                	mv	a0,s5
    800026e0:	ffffe097          	auipc	ra,0xffffe
    800026e4:	ea8080e7          	jalr	-344(ra) # 80000588 <printf>
    printf("\n");
    800026e8:	8552                	mv	a0,s4
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	e9e080e7          	jalr	-354(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026f2:	1c048493          	addi	s1,s1,448
    800026f6:	03248163          	beq	s1,s2,80002718 <procdump+0x98>
    if(p->state == UNUSED)
    800026fa:	86a6                	mv	a3,s1
    800026fc:	e884a783          	lw	a5,-376(s1)
    80002700:	dbed                	beqz	a5,800026f2 <procdump+0x72>
      state = "???";
    80002702:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002704:	fcfb6be3          	bltu	s6,a5,800026da <procdump+0x5a>
    80002708:	1782                	slli	a5,a5,0x20
    8000270a:	9381                	srli	a5,a5,0x20
    8000270c:	078e                	slli	a5,a5,0x3
    8000270e:	97de                	add	a5,a5,s7
    80002710:	6390                	ld	a2,0(a5)
    80002712:	f661                	bnez	a2,800026da <procdump+0x5a>
      state = "???";
    80002714:	864e                	mv	a2,s3
    80002716:	b7d1                	j	800026da <procdump+0x5a>
  }
}
    80002718:	60a6                	ld	ra,72(sp)
    8000271a:	6406                	ld	s0,64(sp)
    8000271c:	74e2                	ld	s1,56(sp)
    8000271e:	7942                	ld	s2,48(sp)
    80002720:	79a2                	ld	s3,40(sp)
    80002722:	7a02                	ld	s4,32(sp)
    80002724:	6ae2                	ld	s5,24(sp)
    80002726:	6b42                	ld	s6,16(sp)
    80002728:	6ba2                	ld	s7,8(sp)
    8000272a:	6161                	addi	sp,sp,80
    8000272c:	8082                	ret

000000008000272e <kthreadinit>:
#include "defs.h"

extern struct proc proc[NPROC];
extern void forkret(void);
void kthreadinit(struct proc *p)
{
    8000272e:	1101                	addi	sp,sp,-32
    80002730:	ec06                	sd	ra,24(sp)
    80002732:	e822                	sd	s0,16(sp)
    80002734:	e426                	sd	s1,8(sp)
    80002736:	1000                	addi	s0,sp,32
    80002738:	84aa                	mv	s1,a0
  initlock(&(p->alloc_lock),"aloc_thread");
    8000273a:	00006597          	auipc	a1,0x6
    8000273e:	c3658593          	addi	a1,a1,-970 # 80008370 <states.0+0x18>
    80002742:	1a850513          	addi	a0,a0,424
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	400080e7          	jalr	1024(ra) # 80000b46 <initlock>
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
    8000274e:	00006597          	auipc	a1,0x6
    80002752:	c3258593          	addi	a1,a1,-974 # 80008380 <states.0+0x28>
    80002756:	02848513          	addi	a0,s1,40
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	3ec080e7          	jalr	1004(ra) # 80000b46 <initlock>
      kt->t_state = UNUSED_t;
    80002762:	0404a023          	sw	zero,64(s1)
      kt->process=p;
    80002766:	f0a4                	sd	s1,96(s1)
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    80002768:	0000f797          	auipc	a5,0xf
    8000276c:	8b878793          	addi	a5,a5,-1864 # 80011020 <proc>
    80002770:	40f487b3          	sub	a5,s1,a5
    80002774:	8799                	srai	a5,a5,0x6
    80002776:	00006717          	auipc	a4,0x6
    8000277a:	88a73703          	ld	a4,-1910(a4) # 80008000 <etext>
    8000277e:	02e787b3          	mul	a5,a5,a4
    80002782:	2785                	addiw	a5,a5,1
    80002784:	00d7979b          	slliw	a5,a5,0xd
    80002788:	04000737          	lui	a4,0x4000
    8000278c:	177d                	addi	a4,a4,-1
    8000278e:	0732                	slli	a4,a4,0xc
    80002790:	40f707b3          	sub	a5,a4,a5
    80002794:	ecfc                	sd	a5,216(s1)
  }
}
    80002796:	60e2                	ld	ra,24(sp)
    80002798:	6442                	ld	s0,16(sp)
    8000279a:	64a2                	ld	s1,8(sp)
    8000279c:	6105                	addi	sp,sp,32
    8000279e:	8082                	ret

00000000800027a0 <mykthread>:

struct kthread *mykthread()
{
    800027a0:	1101                	addi	sp,sp,-32
    800027a2:	ec06                	sd	ra,24(sp)
    800027a4:	e822                	sd	s0,16(sp)
    800027a6:	e426                	sd	s1,8(sp)
    800027a8:	1000                	addi	s0,sp,32
  push_off();
    800027aa:	ffffe097          	auipc	ra,0xffffe
    800027ae:	3e0080e7          	jalr	992(ra) # 80000b8a <push_off>
  struct cpu *c = mycpu();
    800027b2:	fffff097          	auipc	ra,0xfffff
    800027b6:	1b2080e7          	jalr	434(ra) # 80001964 <mycpu>
  struct kthread *kthread = c->kthread;
    800027ba:	6104                	ld	s1,0(a0)
  pop_off();
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	46e080e7          	jalr	1134(ra) # 80000c2a <pop_off>
  return kthread;
}
    800027c4:	8526                	mv	a0,s1
    800027c6:	60e2                	ld	ra,24(sp)
    800027c8:	6442                	ld	s0,16(sp)
    800027ca:	64a2                	ld	s1,8(sp)
    800027cc:	6105                	addi	sp,sp,32
    800027ce:	8082                	ret

00000000800027d0 <alloctid>:

int alloctid(struct proc *p){
    800027d0:	7179                	addi	sp,sp,-48
    800027d2:	f406                	sd	ra,40(sp)
    800027d4:	f022                	sd	s0,32(sp)
    800027d6:	ec26                	sd	s1,24(sp)
    800027d8:	e84a                	sd	s2,16(sp)
    800027da:	e44e                	sd	s3,8(sp)
    800027dc:	1800                	addi	s0,sp,48
    800027de:	84aa                	mv	s1,a0
  int tid;
  acquire(&(p->alloc_lock));
    800027e0:	1a850993          	addi	s3,a0,424
    800027e4:	854e                	mv	a0,s3
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	3f0080e7          	jalr	1008(ra) # 80000bd6 <acquire>
  tid = p->p_counter;
    800027ee:	1a04a903          	lw	s2,416(s1)
  p->p_counter++;
    800027f2:	0019079b          	addiw	a5,s2,1
    800027f6:	1af4a023          	sw	a5,416(s1)
  release(&(p->alloc_lock));
    800027fa:	854e                	mv	a0,s3
    800027fc:	ffffe097          	auipc	ra,0xffffe
    80002800:	48e080e7          	jalr	1166(ra) # 80000c8a <release>
  return tid;
}
    80002804:	854a                	mv	a0,s2
    80002806:	70a2                	ld	ra,40(sp)
    80002808:	7402                	ld	s0,32(sp)
    8000280a:	64e2                	ld	s1,24(sp)
    8000280c:	6942                	ld	s2,16(sp)
    8000280e:	69a2                	ld	s3,8(sp)
    80002810:	6145                	addi	sp,sp,48
    80002812:	8082                	ret

0000000080002814 <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    80002814:	1141                	addi	sp,sp,-16
    80002816:	e422                	sd	s0,8(sp)
    80002818:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    8000281a:	02850793          	addi	a5,a0,40
    8000281e:	8d9d                	sub	a1,a1,a5
    80002820:	8599                	srai	a1,a1,0x6
    80002822:	00005797          	auipc	a5,0x5
    80002826:	7e67b783          	ld	a5,2022(a5) # 80008008 <etext+0x8>
    8000282a:	02f585bb          	mulw	a1,a1,a5
    8000282e:	00359793          	slli	a5,a1,0x3
    80002832:	95be                	add	a1,a1,a5
    80002834:	0596                	slli	a1,a1,0x5
    80002836:	7568                	ld	a0,232(a0)
}
    80002838:	952e                	add	a0,a0,a1
    8000283a:	6422                	ld	s0,8(sp)
    8000283c:	0141                	addi	sp,sp,16
    8000283e:	8082                	ret

0000000080002840 <allockthread>:

struct kthread* allockthread(struct proc *p){
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	e426                	sd	s1,8(sp)
    80002848:	e04a                	sd	s2,0(sp)
    8000284a:	1000                	addi	s0,sp,32
    8000284c:	84aa                	mv	s1,a0
  
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    8000284e:	02850913          	addi	s2,a0,40
    {
      acquire(&kt->t_lock);
    80002852:	854a                	mv	a0,s2
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	382080e7          	jalr	898(ra) # 80000bd6 <acquire>
      if(kt->t_state == UNUSED_t) {
    8000285c:	40bc                	lw	a5,64(s1)
    8000285e:	cf91                	beqz	a5,8000287a <allockthread+0x3a>
        kt->context.ra = (uint64)forkret;
        kt->context.sp = kt->kstack + PGSIZE;
        return kt;
      } 
      else {
        release(&kt->t_lock);
    80002860:	854a                	mv	a0,s2
    80002862:	ffffe097          	auipc	ra,0xffffe
    80002866:	428080e7          	jalr	1064(ra) # 80000c8a <release>
      }
  }
  return 0;
    8000286a:	4901                	li	s2,0
}
    8000286c:	854a                	mv	a0,s2
    8000286e:	60e2                	ld	ra,24(sp)
    80002870:	6442                	ld	s0,16(sp)
    80002872:	64a2                	ld	s1,8(sp)
    80002874:	6902                	ld	s2,0(sp)
    80002876:	6105                	addi	sp,sp,32
    80002878:	8082                	ret
        kt->tid = alloctid(p);
    8000287a:	8526                	mv	a0,s1
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	f54080e7          	jalr	-172(ra) # 800027d0 <alloctid>
    80002884:	cca8                	sw	a0,88(s1)
        kt->t_state = USED_t;
    80002886:	4785                	li	a5,1
    80002888:	c0bc                	sw	a5,64(s1)
        kt->process=p;
    8000288a:	f0a4                	sd	s1,96(s1)
        kt->trapframe = get_kthread_trapframe(p,kt);
    8000288c:	85ca                	mv	a1,s2
    8000288e:	8526                	mv	a0,s1
    80002890:	00000097          	auipc	ra,0x0
    80002894:	f84080e7          	jalr	-124(ra) # 80002814 <get_kthread_trapframe>
    80002898:	f0e8                	sd	a0,224(s1)
        memset(&kt->context, 0, sizeof(kt->context));   
    8000289a:	07000613          	li	a2,112
    8000289e:	4581                	li	a1,0
    800028a0:	06848513          	addi	a0,s1,104
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	42e080e7          	jalr	1070(ra) # 80000cd2 <memset>
        kt->context.ra = (uint64)forkret;
    800028ac:	00000797          	auipc	a5,0x0
    800028b0:	82c78793          	addi	a5,a5,-2004 # 800020d8 <forkret>
    800028b4:	f4bc                	sd	a5,104(s1)
        kt->context.sp = kt->kstack + PGSIZE;
    800028b6:	6cfc                	ld	a5,216(s1)
    800028b8:	6705                	lui	a4,0x1
    800028ba:	97ba                	add	a5,a5,a4
    800028bc:	f8bc                	sd	a5,112(s1)
        return kt;
    800028be:	b77d                	j	8000286c <allockthread+0x2c>

00000000800028c0 <freethread>:

void
freethread(struct kthread *t){
    800028c0:	1101                	addi	sp,sp,-32
    800028c2:	ec06                	sd	ra,24(sp)
    800028c4:	e822                	sd	s0,16(sp)
    800028c6:	e426                	sd	s1,8(sp)
    800028c8:	1000                	addi	s0,sp,32
    800028ca:	84aa                	mv	s1,a0
  t->chan = 0;
    800028cc:	02053023          	sd	zero,32(a0)
  t->t_killed = 0;
    800028d0:	02052423          	sw	zero,40(a0)
  t->t_xstate = 0;
    800028d4:	02052623          	sw	zero,44(a0)
  t->t_state = UNUSED_t;
    800028d8:	00052c23          	sw	zero,24(a0)
  t->tid=0;
    800028dc:	02052823          	sw	zero,48(a0)
  t->process=0;
    800028e0:	02053c23          	sd	zero,56(a0)
  t->kstack=0;
    800028e4:	0a053823          	sd	zero,176(a0)
  if(t->trapframe)
    800028e8:	7d48                	ld	a0,184(a0)
    800028ea:	c509                	beqz	a0,800028f4 <freethread+0x34>
    kfree((void*)t->trapframe);
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	0fe080e7          	jalr	254(ra) # 800009ea <kfree>
  t->trapframe = 0;
    800028f4:	0a04bc23          	sd	zero,184(s1)
  memset(&t->context,0,sizeof(&t->context));
    800028f8:	4621                	li	a2,8
    800028fa:	4581                	li	a1,0
    800028fc:	04048513          	addi	a0,s1,64
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	3d2080e7          	jalr	978(ra) # 80000cd2 <memset>
  release(&t->t_lock);
    80002908:	8526                	mv	a0,s1
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	380080e7          	jalr	896(ra) # 80000c8a <release>
}
    80002912:	60e2                	ld	ra,24(sp)
    80002914:	6442                	ld	s0,16(sp)
    80002916:	64a2                	ld	s1,8(sp)
    80002918:	6105                	addi	sp,sp,32
    8000291a:	8082                	ret

000000008000291c <swtch>:
    8000291c:	00153023          	sd	ra,0(a0)
    80002920:	00253423          	sd	sp,8(a0)
    80002924:	e900                	sd	s0,16(a0)
    80002926:	ed04                	sd	s1,24(a0)
    80002928:	03253023          	sd	s2,32(a0)
    8000292c:	03353423          	sd	s3,40(a0)
    80002930:	03453823          	sd	s4,48(a0)
    80002934:	03553c23          	sd	s5,56(a0)
    80002938:	05653023          	sd	s6,64(a0)
    8000293c:	05753423          	sd	s7,72(a0)
    80002940:	05853823          	sd	s8,80(a0)
    80002944:	05953c23          	sd	s9,88(a0)
    80002948:	07a53023          	sd	s10,96(a0)
    8000294c:	07b53423          	sd	s11,104(a0)
    80002950:	0005b083          	ld	ra,0(a1)
    80002954:	0085b103          	ld	sp,8(a1)
    80002958:	6980                	ld	s0,16(a1)
    8000295a:	6d84                	ld	s1,24(a1)
    8000295c:	0205b903          	ld	s2,32(a1)
    80002960:	0285b983          	ld	s3,40(a1)
    80002964:	0305ba03          	ld	s4,48(a1)
    80002968:	0385ba83          	ld	s5,56(a1)
    8000296c:	0405bb03          	ld	s6,64(a1)
    80002970:	0485bb83          	ld	s7,72(a1)
    80002974:	0505bc03          	ld	s8,80(a1)
    80002978:	0585bc83          	ld	s9,88(a1)
    8000297c:	0605bd03          	ld	s10,96(a1)
    80002980:	0685bd83          	ld	s11,104(a1)
    80002984:	8082                	ret

0000000080002986 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002986:	1141                	addi	sp,sp,-16
    80002988:	e406                	sd	ra,8(sp)
    8000298a:	e022                	sd	s0,0(sp)
    8000298c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000298e:	00006597          	auipc	a1,0x6
    80002992:	a0258593          	addi	a1,a1,-1534 # 80008390 <states.0+0x38>
    80002996:	00015517          	auipc	a0,0x15
    8000299a:	68a50513          	addi	a0,a0,1674 # 80018020 <tickslock>
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	1a8080e7          	jalr	424(ra) # 80000b46 <initlock>
}
    800029a6:	60a2                	ld	ra,8(sp)
    800029a8:	6402                	ld	s0,0(sp)
    800029aa:	0141                	addi	sp,sp,16
    800029ac:	8082                	ret

00000000800029ae <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029ae:	1141                	addi	sp,sp,-16
    800029b0:	e422                	sd	s0,8(sp)
    800029b2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029b4:	00003797          	auipc	a5,0x3
    800029b8:	53c78793          	addi	a5,a5,1340 # 80005ef0 <kernelvec>
    800029bc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029c0:	6422                	ld	s0,8(sp)
    800029c2:	0141                	addi	sp,sp,16
    800029c4:	8082                	ret

00000000800029c6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029c6:	1101                	addi	sp,sp,-32
    800029c8:	ec06                	sd	ra,24(sp)
    800029ca:	e822                	sd	s0,16(sp)
    800029cc:	e426                	sd	s1,8(sp)
    800029ce:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800029d0:	fffff097          	auipc	ra,0xfffff
    800029d4:	fb0080e7          	jalr	-80(ra) # 80001980 <myproc>
    800029d8:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    800029da:	00000097          	auipc	ra,0x0
    800029de:	dc6080e7          	jalr	-570(ra) # 800027a0 <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029e6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029e8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029ec:	00004617          	auipc	a2,0x4
    800029f0:	61460613          	addi	a2,a2,1556 # 80007000 <_trampoline>
    800029f4:	00004697          	auipc	a3,0x4
    800029f8:	60c68693          	addi	a3,a3,1548 # 80007000 <_trampoline>
    800029fc:	8e91                	sub	a3,a3,a2
    800029fe:	040007b7          	lui	a5,0x4000
    80002a02:	17fd                	addi	a5,a5,-1
    80002a04:	07b2                	slli	a5,a5,0xc
    80002a06:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a08:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a0c:	7d58                	ld	a4,184(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a0e:	180026f3          	csrr	a3,satp
    80002a12:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    80002a14:	7d58                	ld	a4,184(a0)
    80002a16:	7954                	ld	a3,176(a0)
    80002a18:	6585                	lui	a1,0x1
    80002a1a:	96ae                	add	a3,a3,a1
    80002a1c:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    80002a1e:	7d58                	ld	a4,184(a0)
    80002a20:	00000697          	auipc	a3,0x0
    80002a24:	15e68693          	addi	a3,a3,350 # 80002b7e <usertrap>
    80002a28:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a2a:	7d58                	ld	a4,184(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a2c:	8692                	mv	a3,tp
    80002a2e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a30:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a34:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a38:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a3c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    80002a40:	7d58                	ld	a4,184(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a42:	6f18                	ld	a4,24(a4)
    80002a44:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a48:	1004b583          	ld	a1,256(s1)
    80002a4c:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002a4e:	02848493          	addi	s1,s1,40
    80002a52:	8d05                	sub	a0,a0,s1
    80002a54:	8519                	srai	a0,a0,0x6
    80002a56:	00005717          	auipc	a4,0x5
    80002a5a:	5b273703          	ld	a4,1458(a4) # 80008008 <etext+0x8>
    80002a5e:	02e50533          	mul	a0,a0,a4
    80002a62:	1502                	slli	a0,a0,0x20
    80002a64:	9101                	srli	a0,a0,0x20
    80002a66:	00351693          	slli	a3,a0,0x3
    80002a6a:	9536                	add	a0,a0,a3
    80002a6c:	0516                	slli	a0,a0,0x5
    80002a6e:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a72:	00004717          	auipc	a4,0x4
    80002a76:	62270713          	addi	a4,a4,1570 # 80007094 <userret>
    80002a7a:	8f11                	sub	a4,a4,a2
    80002a7c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002a7e:	577d                	li	a4,-1
    80002a80:	177e                	slli	a4,a4,0x3f
    80002a82:	8dd9                	or	a1,a1,a4
    80002a84:	16fd                	addi	a3,a3,-1
    80002a86:	06b6                	slli	a3,a3,0xd
    80002a88:	9536                	add	a0,a0,a3
    80002a8a:	9782                	jalr	a5
}
    80002a8c:	60e2                	ld	ra,24(sp)
    80002a8e:	6442                	ld	s0,16(sp)
    80002a90:	64a2                	ld	s1,8(sp)
    80002a92:	6105                	addi	sp,sp,32
    80002a94:	8082                	ret

0000000080002a96 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a96:	1101                	addi	sp,sp,-32
    80002a98:	ec06                	sd	ra,24(sp)
    80002a9a:	e822                	sd	s0,16(sp)
    80002a9c:	e426                	sd	s1,8(sp)
    80002a9e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002aa0:	00015497          	auipc	s1,0x15
    80002aa4:	58048493          	addi	s1,s1,1408 # 80018020 <tickslock>
    80002aa8:	8526                	mv	a0,s1
    80002aaa:	ffffe097          	auipc	ra,0xffffe
    80002aae:	12c080e7          	jalr	300(ra) # 80000bd6 <acquire>
  ticks++;
    80002ab2:	00006517          	auipc	a0,0x6
    80002ab6:	ece50513          	addi	a0,a0,-306 # 80008980 <ticks>
    80002aba:	411c                	lw	a5,0(a0)
    80002abc:	2785                	addiw	a5,a5,1
    80002abe:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002ac0:	fffff097          	auipc	ra,0xfffff
    80002ac4:	6ee080e7          	jalr	1774(ra) # 800021ae <wakeup>
  release(&tickslock);
    80002ac8:	8526                	mv	a0,s1
    80002aca:	ffffe097          	auipc	ra,0xffffe
    80002ace:	1c0080e7          	jalr	448(ra) # 80000c8a <release>
}
    80002ad2:	60e2                	ld	ra,24(sp)
    80002ad4:	6442                	ld	s0,16(sp)
    80002ad6:	64a2                	ld	s1,8(sp)
    80002ad8:	6105                	addi	sp,sp,32
    80002ada:	8082                	ret

0000000080002adc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002adc:	1101                	addi	sp,sp,-32
    80002ade:	ec06                	sd	ra,24(sp)
    80002ae0:	e822                	sd	s0,16(sp)
    80002ae2:	e426                	sd	s1,8(sp)
    80002ae4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ae6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002aea:	00074d63          	bltz	a4,80002b04 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002aee:	57fd                	li	a5,-1
    80002af0:	17fe                	slli	a5,a5,0x3f
    80002af2:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002af4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002af6:	06f70363          	beq	a4,a5,80002b5c <devintr+0x80>
  }
}
    80002afa:	60e2                	ld	ra,24(sp)
    80002afc:	6442                	ld	s0,16(sp)
    80002afe:	64a2                	ld	s1,8(sp)
    80002b00:	6105                	addi	sp,sp,32
    80002b02:	8082                	ret
     (scause & 0xff) == 9){
    80002b04:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b08:	46a5                	li	a3,9
    80002b0a:	fed792e3          	bne	a5,a3,80002aee <devintr+0x12>
    int irq = plic_claim();
    80002b0e:	00003097          	auipc	ra,0x3
    80002b12:	4ea080e7          	jalr	1258(ra) # 80005ff8 <plic_claim>
    80002b16:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b18:	47a9                	li	a5,10
    80002b1a:	02f50763          	beq	a0,a5,80002b48 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b1e:	4785                	li	a5,1
    80002b20:	02f50963          	beq	a0,a5,80002b52 <devintr+0x76>
    return 1;
    80002b24:	4505                	li	a0,1
    } else if(irq){
    80002b26:	d8f1                	beqz	s1,80002afa <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b28:	85a6                	mv	a1,s1
    80002b2a:	00006517          	auipc	a0,0x6
    80002b2e:	86e50513          	addi	a0,a0,-1938 # 80008398 <states.0+0x40>
    80002b32:	ffffe097          	auipc	ra,0xffffe
    80002b36:	a56080e7          	jalr	-1450(ra) # 80000588 <printf>
      plic_complete(irq);
    80002b3a:	8526                	mv	a0,s1
    80002b3c:	00003097          	auipc	ra,0x3
    80002b40:	4e0080e7          	jalr	1248(ra) # 8000601c <plic_complete>
    return 1;
    80002b44:	4505                	li	a0,1
    80002b46:	bf55                	j	80002afa <devintr+0x1e>
      uartintr();
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	e52080e7          	jalr	-430(ra) # 8000099a <uartintr>
    80002b50:	b7ed                	j	80002b3a <devintr+0x5e>
      virtio_disk_intr();
    80002b52:	00004097          	auipc	ra,0x4
    80002b56:	996080e7          	jalr	-1642(ra) # 800064e8 <virtio_disk_intr>
    80002b5a:	b7c5                	j	80002b3a <devintr+0x5e>
    if(cpuid() == 0){
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	df8080e7          	jalr	-520(ra) # 80001954 <cpuid>
    80002b64:	c901                	beqz	a0,80002b74 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b66:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b6a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b6c:	14479073          	csrw	sip,a5
    return 2;
    80002b70:	4509                	li	a0,2
    80002b72:	b761                	j	80002afa <devintr+0x1e>
      clockintr();
    80002b74:	00000097          	auipc	ra,0x0
    80002b78:	f22080e7          	jalr	-222(ra) # 80002a96 <clockintr>
    80002b7c:	b7ed                	j	80002b66 <devintr+0x8a>

0000000080002b7e <usertrap>:
{
    80002b7e:	1101                	addi	sp,sp,-32
    80002b80:	ec06                	sd	ra,24(sp)
    80002b82:	e822                	sd	s0,16(sp)
    80002b84:	e426                	sd	s1,8(sp)
    80002b86:	e04a                	sd	s2,0(sp)
    80002b88:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b8a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b8e:	1007f793          	andi	a5,a5,256
    80002b92:	e7b9                	bnez	a5,80002be0 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b94:	00003797          	auipc	a5,0x3
    80002b98:	35c78793          	addi	a5,a5,860 # 80005ef0 <kernelvec>
    80002b9c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ba0:	fffff097          	auipc	ra,0xfffff
    80002ba4:	de0080e7          	jalr	-544(ra) # 80001980 <myproc>
    80002ba8:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002baa:	00000097          	auipc	ra,0x0
    80002bae:	bf6080e7          	jalr	-1034(ra) # 800027a0 <mykthread>
    80002bb2:	892a                	mv	s2,a0
  kt->trapframe->epc = r_sepc();
    80002bb4:	7d5c                	ld	a5,184(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bb6:	14102773          	csrr	a4,sepc
    80002bba:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bbc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002bc0:	47a1                	li	a5,8
    80002bc2:	02f70763          	beq	a4,a5,80002bf0 <usertrap+0x72>
  } else if((which_dev = devintr()) != 0){
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	f16080e7          	jalr	-234(ra) # 80002adc <devintr>
    80002bce:	892a                	mv	s2,a0
    80002bd0:	c541                	beqz	a0,80002c58 <usertrap+0xda>
  if(killed(p))
    80002bd2:	8526                	mv	a0,s1
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	89c080e7          	jalr	-1892(ra) # 80002470 <killed>
    80002bdc:	c939                	beqz	a0,80002c32 <usertrap+0xb4>
    80002bde:	a0a9                	j	80002c28 <usertrap+0xaa>
    panic("usertrap: not from user mode");
    80002be0:	00005517          	auipc	a0,0x5
    80002be4:	7d850513          	addi	a0,a0,2008 # 800083b8 <states.0+0x60>
    80002be8:	ffffe097          	auipc	ra,0xffffe
    80002bec:	956080e7          	jalr	-1706(ra) # 8000053e <panic>
    if(killed(p))
    80002bf0:	8526                	mv	a0,s1
    80002bf2:	00000097          	auipc	ra,0x0
    80002bf6:	87e080e7          	jalr	-1922(ra) # 80002470 <killed>
    80002bfa:	e929                	bnez	a0,80002c4c <usertrap+0xce>
    kt->trapframe->epc += 4;
    80002bfc:	0b893703          	ld	a4,184(s2)
    80002c00:	6f1c                	ld	a5,24(a4)
    80002c02:	0791                	addi	a5,a5,4
    80002c04:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c06:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c0a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c0e:	10079073          	csrw	sstatus,a5
    syscall();
    80002c12:	00000097          	auipc	ra,0x0
    80002c16:	2d8080e7          	jalr	728(ra) # 80002eea <syscall>
  if(killed(p))
    80002c1a:	8526                	mv	a0,s1
    80002c1c:	00000097          	auipc	ra,0x0
    80002c20:	854080e7          	jalr	-1964(ra) # 80002470 <killed>
    80002c24:	c911                	beqz	a0,80002c38 <usertrap+0xba>
    80002c26:	4901                	li	s2,0
    exit(-1);
    80002c28:	557d                	li	a0,-1
    80002c2a:	fffff097          	auipc	ra,0xfffff
    80002c2e:	69c080e7          	jalr	1692(ra) # 800022c6 <exit>
  if(which_dev == 2)
    80002c32:	4789                	li	a5,2
    80002c34:	04f90f63          	beq	s2,a5,80002c92 <usertrap+0x114>
  usertrapret();
    80002c38:	00000097          	auipc	ra,0x0
    80002c3c:	d8e080e7          	jalr	-626(ra) # 800029c6 <usertrapret>
}
    80002c40:	60e2                	ld	ra,24(sp)
    80002c42:	6442                	ld	s0,16(sp)
    80002c44:	64a2                	ld	s1,8(sp)
    80002c46:	6902                	ld	s2,0(sp)
    80002c48:	6105                	addi	sp,sp,32
    80002c4a:	8082                	ret
      exit(-1);
    80002c4c:	557d                	li	a0,-1
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	678080e7          	jalr	1656(ra) # 800022c6 <exit>
    80002c56:	b75d                	j	80002bfc <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c58:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c5c:	50d0                	lw	a2,36(s1)
    80002c5e:	00005517          	auipc	a0,0x5
    80002c62:	77a50513          	addi	a0,a0,1914 # 800083d8 <states.0+0x80>
    80002c66:	ffffe097          	auipc	ra,0xffffe
    80002c6a:	922080e7          	jalr	-1758(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c6e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c72:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c76:	00005517          	auipc	a0,0x5
    80002c7a:	79250513          	addi	a0,a0,1938 # 80008408 <states.0+0xb0>
    80002c7e:	ffffe097          	auipc	ra,0xffffe
    80002c82:	90a080e7          	jalr	-1782(ra) # 80000588 <printf>
    setkilled(p);
    80002c86:	8526                	mv	a0,s1
    80002c88:	fffff097          	auipc	ra,0xfffff
    80002c8c:	7bc080e7          	jalr	1980(ra) # 80002444 <setkilled>
    80002c90:	b769                	j	80002c1a <usertrap+0x9c>
    yield();
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	3de080e7          	jalr	990(ra) # 80002070 <yield>
    80002c9a:	bf79                	j	80002c38 <usertrap+0xba>

0000000080002c9c <kerneltrap>:
{
    80002c9c:	7179                	addi	sp,sp,-48
    80002c9e:	f406                	sd	ra,40(sp)
    80002ca0:	f022                	sd	s0,32(sp)
    80002ca2:	ec26                	sd	s1,24(sp)
    80002ca4:	e84a                	sd	s2,16(sp)
    80002ca6:	e44e                	sd	s3,8(sp)
    80002ca8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002caa:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cae:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cb2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002cb6:	1004f793          	andi	a5,s1,256
    80002cba:	cb85                	beqz	a5,80002cea <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cbc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cc0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cc2:	ef85                	bnez	a5,80002cfa <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cc4:	00000097          	auipc	ra,0x0
    80002cc8:	e18080e7          	jalr	-488(ra) # 80002adc <devintr>
    80002ccc:	cd1d                	beqz	a0,80002d0a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002cce:	4789                	li	a5,2
    80002cd0:	06f50a63          	beq	a0,a5,80002d44 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cd4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cd8:	10049073          	csrw	sstatus,s1
}
    80002cdc:	70a2                	ld	ra,40(sp)
    80002cde:	7402                	ld	s0,32(sp)
    80002ce0:	64e2                	ld	s1,24(sp)
    80002ce2:	6942                	ld	s2,16(sp)
    80002ce4:	69a2                	ld	s3,8(sp)
    80002ce6:	6145                	addi	sp,sp,48
    80002ce8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cea:	00005517          	auipc	a0,0x5
    80002cee:	73e50513          	addi	a0,a0,1854 # 80008428 <states.0+0xd0>
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	84c080e7          	jalr	-1972(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002cfa:	00005517          	auipc	a0,0x5
    80002cfe:	75650513          	addi	a0,a0,1878 # 80008450 <states.0+0xf8>
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	83c080e7          	jalr	-1988(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002d0a:	85ce                	mv	a1,s3
    80002d0c:	00005517          	auipc	a0,0x5
    80002d10:	76450513          	addi	a0,a0,1892 # 80008470 <states.0+0x118>
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	874080e7          	jalr	-1932(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d1c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d20:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d24:	00005517          	auipc	a0,0x5
    80002d28:	75c50513          	addi	a0,a0,1884 # 80008480 <states.0+0x128>
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	85c080e7          	jalr	-1956(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002d34:	00005517          	auipc	a0,0x5
    80002d38:	76450513          	addi	a0,a0,1892 # 80008498 <states.0+0x140>
    80002d3c:	ffffe097          	auipc	ra,0xffffe
    80002d40:	802080e7          	jalr	-2046(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002d44:	fffff097          	auipc	ra,0xfffff
    80002d48:	c3c080e7          	jalr	-964(ra) # 80001980 <myproc>
    80002d4c:	d541                	beqz	a0,80002cd4 <kerneltrap+0x38>
    80002d4e:	fffff097          	auipc	ra,0xfffff
    80002d52:	c32080e7          	jalr	-974(ra) # 80001980 <myproc>
    80002d56:	4138                	lw	a4,64(a0)
    80002d58:	4791                	li	a5,4
    80002d5a:	f6f71de3          	bne	a4,a5,80002cd4 <kerneltrap+0x38>
    yield();
    80002d5e:	fffff097          	auipc	ra,0xfffff
    80002d62:	312080e7          	jalr	786(ra) # 80002070 <yield>
    80002d66:	b7bd                	j	80002cd4 <kerneltrap+0x38>

0000000080002d68 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d68:	1101                	addi	sp,sp,-32
    80002d6a:	ec06                	sd	ra,24(sp)
    80002d6c:	e822                	sd	s0,16(sp)
    80002d6e:	e426                	sd	s1,8(sp)
    80002d70:	1000                	addi	s0,sp,32
    80002d72:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    80002d74:	00000097          	auipc	ra,0x0
    80002d78:	a2c080e7          	jalr	-1492(ra) # 800027a0 <mykthread>
  switch (n) {
    80002d7c:	4795                	li	a5,5
    80002d7e:	0497e163          	bltu	a5,s1,80002dc0 <argraw+0x58>
    80002d82:	048a                	slli	s1,s1,0x2
    80002d84:	00005717          	auipc	a4,0x5
    80002d88:	74c70713          	addi	a4,a4,1868 # 800084d0 <states.0+0x178>
    80002d8c:	94ba                	add	s1,s1,a4
    80002d8e:	409c                	lw	a5,0(s1)
    80002d90:	97ba                	add	a5,a5,a4
    80002d92:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    80002d94:	7d5c                	ld	a5,184(a0)
    80002d96:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d98:	60e2                	ld	ra,24(sp)
    80002d9a:	6442                	ld	s0,16(sp)
    80002d9c:	64a2                	ld	s1,8(sp)
    80002d9e:	6105                	addi	sp,sp,32
    80002da0:	8082                	ret
    return kt->trapframe->a1;
    80002da2:	7d5c                	ld	a5,184(a0)
    80002da4:	7fa8                	ld	a0,120(a5)
    80002da6:	bfcd                	j	80002d98 <argraw+0x30>
    return kt->trapframe->a2;
    80002da8:	7d5c                	ld	a5,184(a0)
    80002daa:	63c8                	ld	a0,128(a5)
    80002dac:	b7f5                	j	80002d98 <argraw+0x30>
    return kt->trapframe->a3;
    80002dae:	7d5c                	ld	a5,184(a0)
    80002db0:	67c8                	ld	a0,136(a5)
    80002db2:	b7dd                	j	80002d98 <argraw+0x30>
    return kt->trapframe->a4;
    80002db4:	7d5c                	ld	a5,184(a0)
    80002db6:	6bc8                	ld	a0,144(a5)
    80002db8:	b7c5                	j	80002d98 <argraw+0x30>
    return kt->trapframe->a5;
    80002dba:	7d5c                	ld	a5,184(a0)
    80002dbc:	6fc8                	ld	a0,152(a5)
    80002dbe:	bfe9                	j	80002d98 <argraw+0x30>
  panic("argraw");
    80002dc0:	00005517          	auipc	a0,0x5
    80002dc4:	6e850513          	addi	a0,a0,1768 # 800084a8 <states.0+0x150>
    80002dc8:	ffffd097          	auipc	ra,0xffffd
    80002dcc:	776080e7          	jalr	1910(ra) # 8000053e <panic>

0000000080002dd0 <fetchaddr>:
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	e426                	sd	s1,8(sp)
    80002dd8:	e04a                	sd	s2,0(sp)
    80002dda:	1000                	addi	s0,sp,32
    80002ddc:	84aa                	mv	s1,a0
    80002dde:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	ba0080e7          	jalr	-1120(ra) # 80001980 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002de8:	7d7c                	ld	a5,248(a0)
    80002dea:	02f4f963          	bgeu	s1,a5,80002e1c <fetchaddr+0x4c>
    80002dee:	00848713          	addi	a4,s1,8
    80002df2:	02e7e763          	bltu	a5,a4,80002e20 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002df6:	46a1                	li	a3,8
    80002df8:	8626                	mv	a2,s1
    80002dfa:	85ca                	mv	a1,s2
    80002dfc:	10053503          	ld	a0,256(a0)
    80002e00:	fffff097          	auipc	ra,0xfffff
    80002e04:	8f4080e7          	jalr	-1804(ra) # 800016f4 <copyin>
    80002e08:	00a03533          	snez	a0,a0
    80002e0c:	40a00533          	neg	a0,a0
}
    80002e10:	60e2                	ld	ra,24(sp)
    80002e12:	6442                	ld	s0,16(sp)
    80002e14:	64a2                	ld	s1,8(sp)
    80002e16:	6902                	ld	s2,0(sp)
    80002e18:	6105                	addi	sp,sp,32
    80002e1a:	8082                	ret
    return -1;
    80002e1c:	557d                	li	a0,-1
    80002e1e:	bfcd                	j	80002e10 <fetchaddr+0x40>
    80002e20:	557d                	li	a0,-1
    80002e22:	b7fd                	j	80002e10 <fetchaddr+0x40>

0000000080002e24 <fetchstr>:
{
    80002e24:	7179                	addi	sp,sp,-48
    80002e26:	f406                	sd	ra,40(sp)
    80002e28:	f022                	sd	s0,32(sp)
    80002e2a:	ec26                	sd	s1,24(sp)
    80002e2c:	e84a                	sd	s2,16(sp)
    80002e2e:	e44e                	sd	s3,8(sp)
    80002e30:	1800                	addi	s0,sp,48
    80002e32:	892a                	mv	s2,a0
    80002e34:	84ae                	mv	s1,a1
    80002e36:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	b48080e7          	jalr	-1208(ra) # 80001980 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e40:	86ce                	mv	a3,s3
    80002e42:	864a                	mv	a2,s2
    80002e44:	85a6                	mv	a1,s1
    80002e46:	10053503          	ld	a0,256(a0)
    80002e4a:	fffff097          	auipc	ra,0xfffff
    80002e4e:	938080e7          	jalr	-1736(ra) # 80001782 <copyinstr>
    80002e52:	00054e63          	bltz	a0,80002e6e <fetchstr+0x4a>
  return strlen(buf);
    80002e56:	8526                	mv	a0,s1
    80002e58:	ffffe097          	auipc	ra,0xffffe
    80002e5c:	ff6080e7          	jalr	-10(ra) # 80000e4e <strlen>
}
    80002e60:	70a2                	ld	ra,40(sp)
    80002e62:	7402                	ld	s0,32(sp)
    80002e64:	64e2                	ld	s1,24(sp)
    80002e66:	6942                	ld	s2,16(sp)
    80002e68:	69a2                	ld	s3,8(sp)
    80002e6a:	6145                	addi	sp,sp,48
    80002e6c:	8082                	ret
    return -1;
    80002e6e:	557d                	li	a0,-1
    80002e70:	bfc5                	j	80002e60 <fetchstr+0x3c>

0000000080002e72 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e72:	1101                	addi	sp,sp,-32
    80002e74:	ec06                	sd	ra,24(sp)
    80002e76:	e822                	sd	s0,16(sp)
    80002e78:	e426                	sd	s1,8(sp)
    80002e7a:	1000                	addi	s0,sp,32
    80002e7c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e7e:	00000097          	auipc	ra,0x0
    80002e82:	eea080e7          	jalr	-278(ra) # 80002d68 <argraw>
    80002e86:	c088                	sw	a0,0(s1)
}
    80002e88:	60e2                	ld	ra,24(sp)
    80002e8a:	6442                	ld	s0,16(sp)
    80002e8c:	64a2                	ld	s1,8(sp)
    80002e8e:	6105                	addi	sp,sp,32
    80002e90:	8082                	ret

0000000080002e92 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e92:	1101                	addi	sp,sp,-32
    80002e94:	ec06                	sd	ra,24(sp)
    80002e96:	e822                	sd	s0,16(sp)
    80002e98:	e426                	sd	s1,8(sp)
    80002e9a:	1000                	addi	s0,sp,32
    80002e9c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e9e:	00000097          	auipc	ra,0x0
    80002ea2:	eca080e7          	jalr	-310(ra) # 80002d68 <argraw>
    80002ea6:	e088                	sd	a0,0(s1)
}
    80002ea8:	60e2                	ld	ra,24(sp)
    80002eaa:	6442                	ld	s0,16(sp)
    80002eac:	64a2                	ld	s1,8(sp)
    80002eae:	6105                	addi	sp,sp,32
    80002eb0:	8082                	ret

0000000080002eb2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002eb2:	7179                	addi	sp,sp,-48
    80002eb4:	f406                	sd	ra,40(sp)
    80002eb6:	f022                	sd	s0,32(sp)
    80002eb8:	ec26                	sd	s1,24(sp)
    80002eba:	e84a                	sd	s2,16(sp)
    80002ebc:	1800                	addi	s0,sp,48
    80002ebe:	84ae                	mv	s1,a1
    80002ec0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ec2:	fd840593          	addi	a1,s0,-40
    80002ec6:	00000097          	auipc	ra,0x0
    80002eca:	fcc080e7          	jalr	-52(ra) # 80002e92 <argaddr>
  return fetchstr(addr, buf, max);
    80002ece:	864a                	mv	a2,s2
    80002ed0:	85a6                	mv	a1,s1
    80002ed2:	fd843503          	ld	a0,-40(s0)
    80002ed6:	00000097          	auipc	ra,0x0
    80002eda:	f4e080e7          	jalr	-178(ra) # 80002e24 <fetchstr>
}
    80002ede:	70a2                	ld	ra,40(sp)
    80002ee0:	7402                	ld	s0,32(sp)
    80002ee2:	64e2                	ld	s1,24(sp)
    80002ee4:	6942                	ld	s2,16(sp)
    80002ee6:	6145                	addi	sp,sp,48
    80002ee8:	8082                	ret

0000000080002eea <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002eea:	7179                	addi	sp,sp,-48
    80002eec:	f406                	sd	ra,40(sp)
    80002eee:	f022                	sd	s0,32(sp)
    80002ef0:	ec26                	sd	s1,24(sp)
    80002ef2:	e84a                	sd	s2,16(sp)
    80002ef4:	e44e                	sd	s3,8(sp)
    80002ef6:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002ef8:	fffff097          	auipc	ra,0xfffff
    80002efc:	a88080e7          	jalr	-1400(ra) # 80001980 <myproc>
    80002f00:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    80002f02:	00000097          	auipc	ra,0x0
    80002f06:	89e080e7          	jalr	-1890(ra) # 800027a0 <mykthread>
    80002f0a:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80002f0c:	0b853983          	ld	s3,184(a0)
    80002f10:	0a89b783          	ld	a5,168(s3)
    80002f14:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f18:	37fd                	addiw	a5,a5,-1
    80002f1a:	4751                	li	a4,20
    80002f1c:	00f76f63          	bltu	a4,a5,80002f3a <syscall+0x50>
    80002f20:	00369713          	slli	a4,a3,0x3
    80002f24:	00005797          	auipc	a5,0x5
    80002f28:	5c478793          	addi	a5,a5,1476 # 800084e8 <syscalls>
    80002f2c:	97ba                	add	a5,a5,a4
    80002f2e:	639c                	ld	a5,0(a5)
    80002f30:	c789                	beqz	a5,80002f3a <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    80002f32:	9782                	jalr	a5
    80002f34:	06a9b823          	sd	a0,112(s3)
    80002f38:	a005                	j	80002f58 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f3a:	19090613          	addi	a2,s2,400
    80002f3e:	02492583          	lw	a1,36(s2)
    80002f42:	00005517          	auipc	a0,0x5
    80002f46:	56e50513          	addi	a0,a0,1390 # 800084b0 <states.0+0x158>
    80002f4a:	ffffd097          	auipc	ra,0xffffd
    80002f4e:	63e080e7          	jalr	1598(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    80002f52:	7cdc                	ld	a5,184(s1)
    80002f54:	577d                	li	a4,-1
    80002f56:	fbb8                	sd	a4,112(a5)
  }
}
    80002f58:	70a2                	ld	ra,40(sp)
    80002f5a:	7402                	ld	s0,32(sp)
    80002f5c:	64e2                	ld	s1,24(sp)
    80002f5e:	6942                	ld	s2,16(sp)
    80002f60:	69a2                	ld	s3,8(sp)
    80002f62:	6145                	addi	sp,sp,48
    80002f64:	8082                	ret

0000000080002f66 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f66:	1101                	addi	sp,sp,-32
    80002f68:	ec06                	sd	ra,24(sp)
    80002f6a:	e822                	sd	s0,16(sp)
    80002f6c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f6e:	fec40593          	addi	a1,s0,-20
    80002f72:	4501                	li	a0,0
    80002f74:	00000097          	auipc	ra,0x0
    80002f78:	efe080e7          	jalr	-258(ra) # 80002e72 <argint>
  exit(n);
    80002f7c:	fec42503          	lw	a0,-20(s0)
    80002f80:	fffff097          	auipc	ra,0xfffff
    80002f84:	346080e7          	jalr	838(ra) # 800022c6 <exit>
  return 0;  // not reached
}
    80002f88:	4501                	li	a0,0
    80002f8a:	60e2                	ld	ra,24(sp)
    80002f8c:	6442                	ld	s0,16(sp)
    80002f8e:	6105                	addi	sp,sp,32
    80002f90:	8082                	ret

0000000080002f92 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f92:	1141                	addi	sp,sp,-16
    80002f94:	e406                	sd	ra,8(sp)
    80002f96:	e022                	sd	s0,0(sp)
    80002f98:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	9e6080e7          	jalr	-1562(ra) # 80001980 <myproc>
}
    80002fa2:	5148                	lw	a0,36(a0)
    80002fa4:	60a2                	ld	ra,8(sp)
    80002fa6:	6402                	ld	s0,0(sp)
    80002fa8:	0141                	addi	sp,sp,16
    80002faa:	8082                	ret

0000000080002fac <sys_fork>:

uint64
sys_fork(void)
{
    80002fac:	1141                	addi	sp,sp,-16
    80002fae:	e406                	sd	ra,8(sp)
    80002fb0:	e022                	sd	s0,0(sp)
    80002fb2:	0800                	addi	s0,sp,16
  return fork();
    80002fb4:	fffff097          	auipc	ra,0xfffff
    80002fb8:	d92080e7          	jalr	-622(ra) # 80001d46 <fork>
}
    80002fbc:	60a2                	ld	ra,8(sp)
    80002fbe:	6402                	ld	s0,0(sp)
    80002fc0:	0141                	addi	sp,sp,16
    80002fc2:	8082                	ret

0000000080002fc4 <sys_wait>:

uint64
sys_wait(void)
{
    80002fc4:	1101                	addi	sp,sp,-32
    80002fc6:	ec06                	sd	ra,24(sp)
    80002fc8:	e822                	sd	s0,16(sp)
    80002fca:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002fcc:	fe840593          	addi	a1,s0,-24
    80002fd0:	4501                	li	a0,0
    80002fd2:	00000097          	auipc	ra,0x0
    80002fd6:	ec0080e7          	jalr	-320(ra) # 80002e92 <argaddr>
  return wait(p);
    80002fda:	fe843503          	ld	a0,-24(s0)
    80002fde:	fffff097          	auipc	ra,0xfffff
    80002fe2:	4c4080e7          	jalr	1220(ra) # 800024a2 <wait>
}
    80002fe6:	60e2                	ld	ra,24(sp)
    80002fe8:	6442                	ld	s0,16(sp)
    80002fea:	6105                	addi	sp,sp,32
    80002fec:	8082                	ret

0000000080002fee <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fee:	7179                	addi	sp,sp,-48
    80002ff0:	f406                	sd	ra,40(sp)
    80002ff2:	f022                	sd	s0,32(sp)
    80002ff4:	ec26                	sd	s1,24(sp)
    80002ff6:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ff8:	fdc40593          	addi	a1,s0,-36
    80002ffc:	4501                	li	a0,0
    80002ffe:	00000097          	auipc	ra,0x0
    80003002:	e74080e7          	jalr	-396(ra) # 80002e72 <argint>
  addr = myproc()->sz;
    80003006:	fffff097          	auipc	ra,0xfffff
    8000300a:	97a080e7          	jalr	-1670(ra) # 80001980 <myproc>
    8000300e:	7d64                	ld	s1,248(a0)
  if(growproc(n) < 0)
    80003010:	fdc42503          	lw	a0,-36(s0)
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	cd2080e7          	jalr	-814(ra) # 80001ce6 <growproc>
    8000301c:	00054863          	bltz	a0,8000302c <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003020:	8526                	mv	a0,s1
    80003022:	70a2                	ld	ra,40(sp)
    80003024:	7402                	ld	s0,32(sp)
    80003026:	64e2                	ld	s1,24(sp)
    80003028:	6145                	addi	sp,sp,48
    8000302a:	8082                	ret
    return -1;
    8000302c:	54fd                	li	s1,-1
    8000302e:	bfcd                	j	80003020 <sys_sbrk+0x32>

0000000080003030 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003030:	7139                	addi	sp,sp,-64
    80003032:	fc06                	sd	ra,56(sp)
    80003034:	f822                	sd	s0,48(sp)
    80003036:	f426                	sd	s1,40(sp)
    80003038:	f04a                	sd	s2,32(sp)
    8000303a:	ec4e                	sd	s3,24(sp)
    8000303c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000303e:	fcc40593          	addi	a1,s0,-52
    80003042:	4501                	li	a0,0
    80003044:	00000097          	auipc	ra,0x0
    80003048:	e2e080e7          	jalr	-466(ra) # 80002e72 <argint>
  acquire(&tickslock);
    8000304c:	00015517          	auipc	a0,0x15
    80003050:	fd450513          	addi	a0,a0,-44 # 80018020 <tickslock>
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	b82080e7          	jalr	-1150(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    8000305c:	00006917          	auipc	s2,0x6
    80003060:	92492903          	lw	s2,-1756(s2) # 80008980 <ticks>
  while(ticks - ticks0 < n){
    80003064:	fcc42783          	lw	a5,-52(s0)
    80003068:	cf9d                	beqz	a5,800030a6 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000306a:	00015997          	auipc	s3,0x15
    8000306e:	fb698993          	addi	s3,s3,-74 # 80018020 <tickslock>
    80003072:	00006497          	auipc	s1,0x6
    80003076:	90e48493          	addi	s1,s1,-1778 # 80008980 <ticks>
    if(killed(myproc())){
    8000307a:	fffff097          	auipc	ra,0xfffff
    8000307e:	906080e7          	jalr	-1786(ra) # 80001980 <myproc>
    80003082:	fffff097          	auipc	ra,0xfffff
    80003086:	3ee080e7          	jalr	1006(ra) # 80002470 <killed>
    8000308a:	ed15                	bnez	a0,800030c6 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000308c:	85ce                	mv	a1,s3
    8000308e:	8526                	mv	a0,s1
    80003090:	fffff097          	auipc	ra,0xfffff
    80003094:	09e080e7          	jalr	158(ra) # 8000212e <sleep>
  while(ticks - ticks0 < n){
    80003098:	409c                	lw	a5,0(s1)
    8000309a:	412787bb          	subw	a5,a5,s2
    8000309e:	fcc42703          	lw	a4,-52(s0)
    800030a2:	fce7ece3          	bltu	a5,a4,8000307a <sys_sleep+0x4a>
  }
  release(&tickslock);
    800030a6:	00015517          	auipc	a0,0x15
    800030aa:	f7a50513          	addi	a0,a0,-134 # 80018020 <tickslock>
    800030ae:	ffffe097          	auipc	ra,0xffffe
    800030b2:	bdc080e7          	jalr	-1060(ra) # 80000c8a <release>
  return 0;
    800030b6:	4501                	li	a0,0
}
    800030b8:	70e2                	ld	ra,56(sp)
    800030ba:	7442                	ld	s0,48(sp)
    800030bc:	74a2                	ld	s1,40(sp)
    800030be:	7902                	ld	s2,32(sp)
    800030c0:	69e2                	ld	s3,24(sp)
    800030c2:	6121                	addi	sp,sp,64
    800030c4:	8082                	ret
      release(&tickslock);
    800030c6:	00015517          	auipc	a0,0x15
    800030ca:	f5a50513          	addi	a0,a0,-166 # 80018020 <tickslock>
    800030ce:	ffffe097          	auipc	ra,0xffffe
    800030d2:	bbc080e7          	jalr	-1092(ra) # 80000c8a <release>
      return -1;
    800030d6:	557d                	li	a0,-1
    800030d8:	b7c5                	j	800030b8 <sys_sleep+0x88>

00000000800030da <sys_kill>:

uint64
sys_kill(void)
{
    800030da:	1101                	addi	sp,sp,-32
    800030dc:	ec06                	sd	ra,24(sp)
    800030de:	e822                	sd	s0,16(sp)
    800030e0:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800030e2:	fec40593          	addi	a1,s0,-20
    800030e6:	4501                	li	a0,0
    800030e8:	00000097          	auipc	ra,0x0
    800030ec:	d8a080e7          	jalr	-630(ra) # 80002e72 <argint>
  return kill(pid);
    800030f0:	fec42503          	lw	a0,-20(s0)
    800030f4:	fffff097          	auipc	ra,0xfffff
    800030f8:	2c6080e7          	jalr	710(ra) # 800023ba <kill>
}
    800030fc:	60e2                	ld	ra,24(sp)
    800030fe:	6442                	ld	s0,16(sp)
    80003100:	6105                	addi	sp,sp,32
    80003102:	8082                	ret

0000000080003104 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003104:	1101                	addi	sp,sp,-32
    80003106:	ec06                	sd	ra,24(sp)
    80003108:	e822                	sd	s0,16(sp)
    8000310a:	e426                	sd	s1,8(sp)
    8000310c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000310e:	00015517          	auipc	a0,0x15
    80003112:	f1250513          	addi	a0,a0,-238 # 80018020 <tickslock>
    80003116:	ffffe097          	auipc	ra,0xffffe
    8000311a:	ac0080e7          	jalr	-1344(ra) # 80000bd6 <acquire>
  xticks = ticks;
    8000311e:	00006497          	auipc	s1,0x6
    80003122:	8624a483          	lw	s1,-1950(s1) # 80008980 <ticks>
  release(&tickslock);
    80003126:	00015517          	auipc	a0,0x15
    8000312a:	efa50513          	addi	a0,a0,-262 # 80018020 <tickslock>
    8000312e:	ffffe097          	auipc	ra,0xffffe
    80003132:	b5c080e7          	jalr	-1188(ra) # 80000c8a <release>
  return xticks;
}
    80003136:	02049513          	slli	a0,s1,0x20
    8000313a:	9101                	srli	a0,a0,0x20
    8000313c:	60e2                	ld	ra,24(sp)
    8000313e:	6442                	ld	s0,16(sp)
    80003140:	64a2                	ld	s1,8(sp)
    80003142:	6105                	addi	sp,sp,32
    80003144:	8082                	ret

0000000080003146 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003146:	7179                	addi	sp,sp,-48
    80003148:	f406                	sd	ra,40(sp)
    8000314a:	f022                	sd	s0,32(sp)
    8000314c:	ec26                	sd	s1,24(sp)
    8000314e:	e84a                	sd	s2,16(sp)
    80003150:	e44e                	sd	s3,8(sp)
    80003152:	e052                	sd	s4,0(sp)
    80003154:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003156:	00005597          	auipc	a1,0x5
    8000315a:	44258593          	addi	a1,a1,1090 # 80008598 <syscalls+0xb0>
    8000315e:	00015517          	auipc	a0,0x15
    80003162:	eda50513          	addi	a0,a0,-294 # 80018038 <bcache>
    80003166:	ffffe097          	auipc	ra,0xffffe
    8000316a:	9e0080e7          	jalr	-1568(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000316e:	0001d797          	auipc	a5,0x1d
    80003172:	eca78793          	addi	a5,a5,-310 # 80020038 <bcache+0x8000>
    80003176:	0001d717          	auipc	a4,0x1d
    8000317a:	12a70713          	addi	a4,a4,298 # 800202a0 <bcache+0x8268>
    8000317e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003182:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003186:	00015497          	auipc	s1,0x15
    8000318a:	eca48493          	addi	s1,s1,-310 # 80018050 <bcache+0x18>
    b->next = bcache.head.next;
    8000318e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003190:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003192:	00005a17          	auipc	s4,0x5
    80003196:	40ea0a13          	addi	s4,s4,1038 # 800085a0 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000319a:	2b893783          	ld	a5,696(s2)
    8000319e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800031a0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800031a4:	85d2                	mv	a1,s4
    800031a6:	01048513          	addi	a0,s1,16
    800031aa:	00001097          	auipc	ra,0x1
    800031ae:	4c4080e7          	jalr	1220(ra) # 8000466e <initsleeplock>
    bcache.head.next->prev = b;
    800031b2:	2b893783          	ld	a5,696(s2)
    800031b6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031b8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031bc:	45848493          	addi	s1,s1,1112
    800031c0:	fd349de3          	bne	s1,s3,8000319a <binit+0x54>
  }
}
    800031c4:	70a2                	ld	ra,40(sp)
    800031c6:	7402                	ld	s0,32(sp)
    800031c8:	64e2                	ld	s1,24(sp)
    800031ca:	6942                	ld	s2,16(sp)
    800031cc:	69a2                	ld	s3,8(sp)
    800031ce:	6a02                	ld	s4,0(sp)
    800031d0:	6145                	addi	sp,sp,48
    800031d2:	8082                	ret

00000000800031d4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031d4:	7179                	addi	sp,sp,-48
    800031d6:	f406                	sd	ra,40(sp)
    800031d8:	f022                	sd	s0,32(sp)
    800031da:	ec26                	sd	s1,24(sp)
    800031dc:	e84a                	sd	s2,16(sp)
    800031de:	e44e                	sd	s3,8(sp)
    800031e0:	1800                	addi	s0,sp,48
    800031e2:	892a                	mv	s2,a0
    800031e4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031e6:	00015517          	auipc	a0,0x15
    800031ea:	e5250513          	addi	a0,a0,-430 # 80018038 <bcache>
    800031ee:	ffffe097          	auipc	ra,0xffffe
    800031f2:	9e8080e7          	jalr	-1560(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031f6:	0001d497          	auipc	s1,0x1d
    800031fa:	0fa4b483          	ld	s1,250(s1) # 800202f0 <bcache+0x82b8>
    800031fe:	0001d797          	auipc	a5,0x1d
    80003202:	0a278793          	addi	a5,a5,162 # 800202a0 <bcache+0x8268>
    80003206:	02f48f63          	beq	s1,a5,80003244 <bread+0x70>
    8000320a:	873e                	mv	a4,a5
    8000320c:	a021                	j	80003214 <bread+0x40>
    8000320e:	68a4                	ld	s1,80(s1)
    80003210:	02e48a63          	beq	s1,a4,80003244 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003214:	449c                	lw	a5,8(s1)
    80003216:	ff279ce3          	bne	a5,s2,8000320e <bread+0x3a>
    8000321a:	44dc                	lw	a5,12(s1)
    8000321c:	ff3799e3          	bne	a5,s3,8000320e <bread+0x3a>
      b->refcnt++;
    80003220:	40bc                	lw	a5,64(s1)
    80003222:	2785                	addiw	a5,a5,1
    80003224:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003226:	00015517          	auipc	a0,0x15
    8000322a:	e1250513          	addi	a0,a0,-494 # 80018038 <bcache>
    8000322e:	ffffe097          	auipc	ra,0xffffe
    80003232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003236:	01048513          	addi	a0,s1,16
    8000323a:	00001097          	auipc	ra,0x1
    8000323e:	46e080e7          	jalr	1134(ra) # 800046a8 <acquiresleep>
      return b;
    80003242:	a8b9                	j	800032a0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003244:	0001d497          	auipc	s1,0x1d
    80003248:	0a44b483          	ld	s1,164(s1) # 800202e8 <bcache+0x82b0>
    8000324c:	0001d797          	auipc	a5,0x1d
    80003250:	05478793          	addi	a5,a5,84 # 800202a0 <bcache+0x8268>
    80003254:	00f48863          	beq	s1,a5,80003264 <bread+0x90>
    80003258:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000325a:	40bc                	lw	a5,64(s1)
    8000325c:	cf81                	beqz	a5,80003274 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000325e:	64a4                	ld	s1,72(s1)
    80003260:	fee49de3          	bne	s1,a4,8000325a <bread+0x86>
  panic("bget: no buffers");
    80003264:	00005517          	auipc	a0,0x5
    80003268:	34450513          	addi	a0,a0,836 # 800085a8 <syscalls+0xc0>
    8000326c:	ffffd097          	auipc	ra,0xffffd
    80003270:	2d2080e7          	jalr	722(ra) # 8000053e <panic>
      b->dev = dev;
    80003274:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003278:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000327c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003280:	4785                	li	a5,1
    80003282:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003284:	00015517          	auipc	a0,0x15
    80003288:	db450513          	addi	a0,a0,-588 # 80018038 <bcache>
    8000328c:	ffffe097          	auipc	ra,0xffffe
    80003290:	9fe080e7          	jalr	-1538(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003294:	01048513          	addi	a0,s1,16
    80003298:	00001097          	auipc	ra,0x1
    8000329c:	410080e7          	jalr	1040(ra) # 800046a8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800032a0:	409c                	lw	a5,0(s1)
    800032a2:	cb89                	beqz	a5,800032b4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800032a4:	8526                	mv	a0,s1
    800032a6:	70a2                	ld	ra,40(sp)
    800032a8:	7402                	ld	s0,32(sp)
    800032aa:	64e2                	ld	s1,24(sp)
    800032ac:	6942                	ld	s2,16(sp)
    800032ae:	69a2                	ld	s3,8(sp)
    800032b0:	6145                	addi	sp,sp,48
    800032b2:	8082                	ret
    virtio_disk_rw(b, 0);
    800032b4:	4581                	li	a1,0
    800032b6:	8526                	mv	a0,s1
    800032b8:	00003097          	auipc	ra,0x3
    800032bc:	ffc080e7          	jalr	-4(ra) # 800062b4 <virtio_disk_rw>
    b->valid = 1;
    800032c0:	4785                	li	a5,1
    800032c2:	c09c                	sw	a5,0(s1)
  return b;
    800032c4:	b7c5                	j	800032a4 <bread+0xd0>

00000000800032c6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032c6:	1101                	addi	sp,sp,-32
    800032c8:	ec06                	sd	ra,24(sp)
    800032ca:	e822                	sd	s0,16(sp)
    800032cc:	e426                	sd	s1,8(sp)
    800032ce:	1000                	addi	s0,sp,32
    800032d0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032d2:	0541                	addi	a0,a0,16
    800032d4:	00001097          	auipc	ra,0x1
    800032d8:	46e080e7          	jalr	1134(ra) # 80004742 <holdingsleep>
    800032dc:	cd01                	beqz	a0,800032f4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032de:	4585                	li	a1,1
    800032e0:	8526                	mv	a0,s1
    800032e2:	00003097          	auipc	ra,0x3
    800032e6:	fd2080e7          	jalr	-46(ra) # 800062b4 <virtio_disk_rw>
}
    800032ea:	60e2                	ld	ra,24(sp)
    800032ec:	6442                	ld	s0,16(sp)
    800032ee:	64a2                	ld	s1,8(sp)
    800032f0:	6105                	addi	sp,sp,32
    800032f2:	8082                	ret
    panic("bwrite");
    800032f4:	00005517          	auipc	a0,0x5
    800032f8:	2cc50513          	addi	a0,a0,716 # 800085c0 <syscalls+0xd8>
    800032fc:	ffffd097          	auipc	ra,0xffffd
    80003300:	242080e7          	jalr	578(ra) # 8000053e <panic>

0000000080003304 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003304:	1101                	addi	sp,sp,-32
    80003306:	ec06                	sd	ra,24(sp)
    80003308:	e822                	sd	s0,16(sp)
    8000330a:	e426                	sd	s1,8(sp)
    8000330c:	e04a                	sd	s2,0(sp)
    8000330e:	1000                	addi	s0,sp,32
    80003310:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003312:	01050913          	addi	s2,a0,16
    80003316:	854a                	mv	a0,s2
    80003318:	00001097          	auipc	ra,0x1
    8000331c:	42a080e7          	jalr	1066(ra) # 80004742 <holdingsleep>
    80003320:	c92d                	beqz	a0,80003392 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003322:	854a                	mv	a0,s2
    80003324:	00001097          	auipc	ra,0x1
    80003328:	3da080e7          	jalr	986(ra) # 800046fe <releasesleep>

  acquire(&bcache.lock);
    8000332c:	00015517          	auipc	a0,0x15
    80003330:	d0c50513          	addi	a0,a0,-756 # 80018038 <bcache>
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	8a2080e7          	jalr	-1886(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000333c:	40bc                	lw	a5,64(s1)
    8000333e:	37fd                	addiw	a5,a5,-1
    80003340:	0007871b          	sext.w	a4,a5
    80003344:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003346:	eb05                	bnez	a4,80003376 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003348:	68bc                	ld	a5,80(s1)
    8000334a:	64b8                	ld	a4,72(s1)
    8000334c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000334e:	64bc                	ld	a5,72(s1)
    80003350:	68b8                	ld	a4,80(s1)
    80003352:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003354:	0001d797          	auipc	a5,0x1d
    80003358:	ce478793          	addi	a5,a5,-796 # 80020038 <bcache+0x8000>
    8000335c:	2b87b703          	ld	a4,696(a5)
    80003360:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003362:	0001d717          	auipc	a4,0x1d
    80003366:	f3e70713          	addi	a4,a4,-194 # 800202a0 <bcache+0x8268>
    8000336a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000336c:	2b87b703          	ld	a4,696(a5)
    80003370:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003372:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003376:	00015517          	auipc	a0,0x15
    8000337a:	cc250513          	addi	a0,a0,-830 # 80018038 <bcache>
    8000337e:	ffffe097          	auipc	ra,0xffffe
    80003382:	90c080e7          	jalr	-1780(ra) # 80000c8a <release>
}
    80003386:	60e2                	ld	ra,24(sp)
    80003388:	6442                	ld	s0,16(sp)
    8000338a:	64a2                	ld	s1,8(sp)
    8000338c:	6902                	ld	s2,0(sp)
    8000338e:	6105                	addi	sp,sp,32
    80003390:	8082                	ret
    panic("brelse");
    80003392:	00005517          	auipc	a0,0x5
    80003396:	23650513          	addi	a0,a0,566 # 800085c8 <syscalls+0xe0>
    8000339a:	ffffd097          	auipc	ra,0xffffd
    8000339e:	1a4080e7          	jalr	420(ra) # 8000053e <panic>

00000000800033a2 <bpin>:

void
bpin(struct buf *b) {
    800033a2:	1101                	addi	sp,sp,-32
    800033a4:	ec06                	sd	ra,24(sp)
    800033a6:	e822                	sd	s0,16(sp)
    800033a8:	e426                	sd	s1,8(sp)
    800033aa:	1000                	addi	s0,sp,32
    800033ac:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033ae:	00015517          	auipc	a0,0x15
    800033b2:	c8a50513          	addi	a0,a0,-886 # 80018038 <bcache>
    800033b6:	ffffe097          	auipc	ra,0xffffe
    800033ba:	820080e7          	jalr	-2016(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800033be:	40bc                	lw	a5,64(s1)
    800033c0:	2785                	addiw	a5,a5,1
    800033c2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033c4:	00015517          	auipc	a0,0x15
    800033c8:	c7450513          	addi	a0,a0,-908 # 80018038 <bcache>
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	8be080e7          	jalr	-1858(ra) # 80000c8a <release>
}
    800033d4:	60e2                	ld	ra,24(sp)
    800033d6:	6442                	ld	s0,16(sp)
    800033d8:	64a2                	ld	s1,8(sp)
    800033da:	6105                	addi	sp,sp,32
    800033dc:	8082                	ret

00000000800033de <bunpin>:

void
bunpin(struct buf *b) {
    800033de:	1101                	addi	sp,sp,-32
    800033e0:	ec06                	sd	ra,24(sp)
    800033e2:	e822                	sd	s0,16(sp)
    800033e4:	e426                	sd	s1,8(sp)
    800033e6:	1000                	addi	s0,sp,32
    800033e8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033ea:	00015517          	auipc	a0,0x15
    800033ee:	c4e50513          	addi	a0,a0,-946 # 80018038 <bcache>
    800033f2:	ffffd097          	auipc	ra,0xffffd
    800033f6:	7e4080e7          	jalr	2020(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800033fa:	40bc                	lw	a5,64(s1)
    800033fc:	37fd                	addiw	a5,a5,-1
    800033fe:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003400:	00015517          	auipc	a0,0x15
    80003404:	c3850513          	addi	a0,a0,-968 # 80018038 <bcache>
    80003408:	ffffe097          	auipc	ra,0xffffe
    8000340c:	882080e7          	jalr	-1918(ra) # 80000c8a <release>
}
    80003410:	60e2                	ld	ra,24(sp)
    80003412:	6442                	ld	s0,16(sp)
    80003414:	64a2                	ld	s1,8(sp)
    80003416:	6105                	addi	sp,sp,32
    80003418:	8082                	ret

000000008000341a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000341a:	1101                	addi	sp,sp,-32
    8000341c:	ec06                	sd	ra,24(sp)
    8000341e:	e822                	sd	s0,16(sp)
    80003420:	e426                	sd	s1,8(sp)
    80003422:	e04a                	sd	s2,0(sp)
    80003424:	1000                	addi	s0,sp,32
    80003426:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003428:	00d5d59b          	srliw	a1,a1,0xd
    8000342c:	0001d797          	auipc	a5,0x1d
    80003430:	2e87a783          	lw	a5,744(a5) # 80020714 <sb+0x1c>
    80003434:	9dbd                	addw	a1,a1,a5
    80003436:	00000097          	auipc	ra,0x0
    8000343a:	d9e080e7          	jalr	-610(ra) # 800031d4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000343e:	0074f713          	andi	a4,s1,7
    80003442:	4785                	li	a5,1
    80003444:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003448:	14ce                	slli	s1,s1,0x33
    8000344a:	90d9                	srli	s1,s1,0x36
    8000344c:	00950733          	add	a4,a0,s1
    80003450:	05874703          	lbu	a4,88(a4)
    80003454:	00e7f6b3          	and	a3,a5,a4
    80003458:	c69d                	beqz	a3,80003486 <bfree+0x6c>
    8000345a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000345c:	94aa                	add	s1,s1,a0
    8000345e:	fff7c793          	not	a5,a5
    80003462:	8ff9                	and	a5,a5,a4
    80003464:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003468:	00001097          	auipc	ra,0x1
    8000346c:	120080e7          	jalr	288(ra) # 80004588 <log_write>
  brelse(bp);
    80003470:	854a                	mv	a0,s2
    80003472:	00000097          	auipc	ra,0x0
    80003476:	e92080e7          	jalr	-366(ra) # 80003304 <brelse>
}
    8000347a:	60e2                	ld	ra,24(sp)
    8000347c:	6442                	ld	s0,16(sp)
    8000347e:	64a2                	ld	s1,8(sp)
    80003480:	6902                	ld	s2,0(sp)
    80003482:	6105                	addi	sp,sp,32
    80003484:	8082                	ret
    panic("freeing free block");
    80003486:	00005517          	auipc	a0,0x5
    8000348a:	14a50513          	addi	a0,a0,330 # 800085d0 <syscalls+0xe8>
    8000348e:	ffffd097          	auipc	ra,0xffffd
    80003492:	0b0080e7          	jalr	176(ra) # 8000053e <panic>

0000000080003496 <balloc>:
{
    80003496:	711d                	addi	sp,sp,-96
    80003498:	ec86                	sd	ra,88(sp)
    8000349a:	e8a2                	sd	s0,80(sp)
    8000349c:	e4a6                	sd	s1,72(sp)
    8000349e:	e0ca                	sd	s2,64(sp)
    800034a0:	fc4e                	sd	s3,56(sp)
    800034a2:	f852                	sd	s4,48(sp)
    800034a4:	f456                	sd	s5,40(sp)
    800034a6:	f05a                	sd	s6,32(sp)
    800034a8:	ec5e                	sd	s7,24(sp)
    800034aa:	e862                	sd	s8,16(sp)
    800034ac:	e466                	sd	s9,8(sp)
    800034ae:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034b0:	0001d797          	auipc	a5,0x1d
    800034b4:	24c7a783          	lw	a5,588(a5) # 800206fc <sb+0x4>
    800034b8:	10078163          	beqz	a5,800035ba <balloc+0x124>
    800034bc:	8baa                	mv	s7,a0
    800034be:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034c0:	0001db17          	auipc	s6,0x1d
    800034c4:	238b0b13          	addi	s6,s6,568 # 800206f8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034c8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034ca:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034cc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034ce:	6c89                	lui	s9,0x2
    800034d0:	a061                	j	80003558 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034d2:	974a                	add	a4,a4,s2
    800034d4:	8fd5                	or	a5,a5,a3
    800034d6:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800034da:	854a                	mv	a0,s2
    800034dc:	00001097          	auipc	ra,0x1
    800034e0:	0ac080e7          	jalr	172(ra) # 80004588 <log_write>
        brelse(bp);
    800034e4:	854a                	mv	a0,s2
    800034e6:	00000097          	auipc	ra,0x0
    800034ea:	e1e080e7          	jalr	-482(ra) # 80003304 <brelse>
  bp = bread(dev, bno);
    800034ee:	85a6                	mv	a1,s1
    800034f0:	855e                	mv	a0,s7
    800034f2:	00000097          	auipc	ra,0x0
    800034f6:	ce2080e7          	jalr	-798(ra) # 800031d4 <bread>
    800034fa:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034fc:	40000613          	li	a2,1024
    80003500:	4581                	li	a1,0
    80003502:	05850513          	addi	a0,a0,88
    80003506:	ffffd097          	auipc	ra,0xffffd
    8000350a:	7cc080e7          	jalr	1996(ra) # 80000cd2 <memset>
  log_write(bp);
    8000350e:	854a                	mv	a0,s2
    80003510:	00001097          	auipc	ra,0x1
    80003514:	078080e7          	jalr	120(ra) # 80004588 <log_write>
  brelse(bp);
    80003518:	854a                	mv	a0,s2
    8000351a:	00000097          	auipc	ra,0x0
    8000351e:	dea080e7          	jalr	-534(ra) # 80003304 <brelse>
}
    80003522:	8526                	mv	a0,s1
    80003524:	60e6                	ld	ra,88(sp)
    80003526:	6446                	ld	s0,80(sp)
    80003528:	64a6                	ld	s1,72(sp)
    8000352a:	6906                	ld	s2,64(sp)
    8000352c:	79e2                	ld	s3,56(sp)
    8000352e:	7a42                	ld	s4,48(sp)
    80003530:	7aa2                	ld	s5,40(sp)
    80003532:	7b02                	ld	s6,32(sp)
    80003534:	6be2                	ld	s7,24(sp)
    80003536:	6c42                	ld	s8,16(sp)
    80003538:	6ca2                	ld	s9,8(sp)
    8000353a:	6125                	addi	sp,sp,96
    8000353c:	8082                	ret
    brelse(bp);
    8000353e:	854a                	mv	a0,s2
    80003540:	00000097          	auipc	ra,0x0
    80003544:	dc4080e7          	jalr	-572(ra) # 80003304 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003548:	015c87bb          	addw	a5,s9,s5
    8000354c:	00078a9b          	sext.w	s5,a5
    80003550:	004b2703          	lw	a4,4(s6)
    80003554:	06eaf363          	bgeu	s5,a4,800035ba <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003558:	41fad79b          	sraiw	a5,s5,0x1f
    8000355c:	0137d79b          	srliw	a5,a5,0x13
    80003560:	015787bb          	addw	a5,a5,s5
    80003564:	40d7d79b          	sraiw	a5,a5,0xd
    80003568:	01cb2583          	lw	a1,28(s6)
    8000356c:	9dbd                	addw	a1,a1,a5
    8000356e:	855e                	mv	a0,s7
    80003570:	00000097          	auipc	ra,0x0
    80003574:	c64080e7          	jalr	-924(ra) # 800031d4 <bread>
    80003578:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000357a:	004b2503          	lw	a0,4(s6)
    8000357e:	000a849b          	sext.w	s1,s5
    80003582:	8662                	mv	a2,s8
    80003584:	faa4fde3          	bgeu	s1,a0,8000353e <balloc+0xa8>
      m = 1 << (bi % 8);
    80003588:	41f6579b          	sraiw	a5,a2,0x1f
    8000358c:	01d7d69b          	srliw	a3,a5,0x1d
    80003590:	00c6873b          	addw	a4,a3,a2
    80003594:	00777793          	andi	a5,a4,7
    80003598:	9f95                	subw	a5,a5,a3
    8000359a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000359e:	4037571b          	sraiw	a4,a4,0x3
    800035a2:	00e906b3          	add	a3,s2,a4
    800035a6:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    800035aa:	00d7f5b3          	and	a1,a5,a3
    800035ae:	d195                	beqz	a1,800034d2 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035b0:	2605                	addiw	a2,a2,1
    800035b2:	2485                	addiw	s1,s1,1
    800035b4:	fd4618e3          	bne	a2,s4,80003584 <balloc+0xee>
    800035b8:	b759                	j	8000353e <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800035ba:	00005517          	auipc	a0,0x5
    800035be:	02e50513          	addi	a0,a0,46 # 800085e8 <syscalls+0x100>
    800035c2:	ffffd097          	auipc	ra,0xffffd
    800035c6:	fc6080e7          	jalr	-58(ra) # 80000588 <printf>
  return 0;
    800035ca:	4481                	li	s1,0
    800035cc:	bf99                	j	80003522 <balloc+0x8c>

00000000800035ce <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035ce:	7179                	addi	sp,sp,-48
    800035d0:	f406                	sd	ra,40(sp)
    800035d2:	f022                	sd	s0,32(sp)
    800035d4:	ec26                	sd	s1,24(sp)
    800035d6:	e84a                	sd	s2,16(sp)
    800035d8:	e44e                	sd	s3,8(sp)
    800035da:	e052                	sd	s4,0(sp)
    800035dc:	1800                	addi	s0,sp,48
    800035de:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035e0:	47ad                	li	a5,11
    800035e2:	02b7e763          	bltu	a5,a1,80003610 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800035e6:	02059493          	slli	s1,a1,0x20
    800035ea:	9081                	srli	s1,s1,0x20
    800035ec:	048a                	slli	s1,s1,0x2
    800035ee:	94aa                	add	s1,s1,a0
    800035f0:	0504a903          	lw	s2,80(s1)
    800035f4:	06091e63          	bnez	s2,80003670 <bmap+0xa2>
      addr = balloc(ip->dev);
    800035f8:	4108                	lw	a0,0(a0)
    800035fa:	00000097          	auipc	ra,0x0
    800035fe:	e9c080e7          	jalr	-356(ra) # 80003496 <balloc>
    80003602:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003606:	06090563          	beqz	s2,80003670 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000360a:	0524a823          	sw	s2,80(s1)
    8000360e:	a08d                	j	80003670 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003610:	ff45849b          	addiw	s1,a1,-12
    80003614:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003618:	0ff00793          	li	a5,255
    8000361c:	08e7e563          	bltu	a5,a4,800036a6 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003620:	08052903          	lw	s2,128(a0)
    80003624:	00091d63          	bnez	s2,8000363e <bmap+0x70>
      addr = balloc(ip->dev);
    80003628:	4108                	lw	a0,0(a0)
    8000362a:	00000097          	auipc	ra,0x0
    8000362e:	e6c080e7          	jalr	-404(ra) # 80003496 <balloc>
    80003632:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003636:	02090d63          	beqz	s2,80003670 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000363a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000363e:	85ca                	mv	a1,s2
    80003640:	0009a503          	lw	a0,0(s3)
    80003644:	00000097          	auipc	ra,0x0
    80003648:	b90080e7          	jalr	-1136(ra) # 800031d4 <bread>
    8000364c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000364e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003652:	02049593          	slli	a1,s1,0x20
    80003656:	9181                	srli	a1,a1,0x20
    80003658:	058a                	slli	a1,a1,0x2
    8000365a:	00b784b3          	add	s1,a5,a1
    8000365e:	0004a903          	lw	s2,0(s1)
    80003662:	02090063          	beqz	s2,80003682 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003666:	8552                	mv	a0,s4
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	c9c080e7          	jalr	-868(ra) # 80003304 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003670:	854a                	mv	a0,s2
    80003672:	70a2                	ld	ra,40(sp)
    80003674:	7402                	ld	s0,32(sp)
    80003676:	64e2                	ld	s1,24(sp)
    80003678:	6942                	ld	s2,16(sp)
    8000367a:	69a2                	ld	s3,8(sp)
    8000367c:	6a02                	ld	s4,0(sp)
    8000367e:	6145                	addi	sp,sp,48
    80003680:	8082                	ret
      addr = balloc(ip->dev);
    80003682:	0009a503          	lw	a0,0(s3)
    80003686:	00000097          	auipc	ra,0x0
    8000368a:	e10080e7          	jalr	-496(ra) # 80003496 <balloc>
    8000368e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003692:	fc090ae3          	beqz	s2,80003666 <bmap+0x98>
        a[bn] = addr;
    80003696:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000369a:	8552                	mv	a0,s4
    8000369c:	00001097          	auipc	ra,0x1
    800036a0:	eec080e7          	jalr	-276(ra) # 80004588 <log_write>
    800036a4:	b7c9                	j	80003666 <bmap+0x98>
  panic("bmap: out of range");
    800036a6:	00005517          	auipc	a0,0x5
    800036aa:	f5a50513          	addi	a0,a0,-166 # 80008600 <syscalls+0x118>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	e90080e7          	jalr	-368(ra) # 8000053e <panic>

00000000800036b6 <iget>:
{
    800036b6:	7179                	addi	sp,sp,-48
    800036b8:	f406                	sd	ra,40(sp)
    800036ba:	f022                	sd	s0,32(sp)
    800036bc:	ec26                	sd	s1,24(sp)
    800036be:	e84a                	sd	s2,16(sp)
    800036c0:	e44e                	sd	s3,8(sp)
    800036c2:	e052                	sd	s4,0(sp)
    800036c4:	1800                	addi	s0,sp,48
    800036c6:	89aa                	mv	s3,a0
    800036c8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036ca:	0001d517          	auipc	a0,0x1d
    800036ce:	04e50513          	addi	a0,a0,78 # 80020718 <itable>
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	504080e7          	jalr	1284(ra) # 80000bd6 <acquire>
  empty = 0;
    800036da:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036dc:	0001d497          	auipc	s1,0x1d
    800036e0:	05448493          	addi	s1,s1,84 # 80020730 <itable+0x18>
    800036e4:	0001f697          	auipc	a3,0x1f
    800036e8:	adc68693          	addi	a3,a3,-1316 # 800221c0 <log>
    800036ec:	a039                	j	800036fa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036ee:	02090b63          	beqz	s2,80003724 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036f2:	08848493          	addi	s1,s1,136
    800036f6:	02d48a63          	beq	s1,a3,8000372a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036fa:	449c                	lw	a5,8(s1)
    800036fc:	fef059e3          	blez	a5,800036ee <iget+0x38>
    80003700:	4098                	lw	a4,0(s1)
    80003702:	ff3716e3          	bne	a4,s3,800036ee <iget+0x38>
    80003706:	40d8                	lw	a4,4(s1)
    80003708:	ff4713e3          	bne	a4,s4,800036ee <iget+0x38>
      ip->ref++;
    8000370c:	2785                	addiw	a5,a5,1
    8000370e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003710:	0001d517          	auipc	a0,0x1d
    80003714:	00850513          	addi	a0,a0,8 # 80020718 <itable>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	572080e7          	jalr	1394(ra) # 80000c8a <release>
      return ip;
    80003720:	8926                	mv	s2,s1
    80003722:	a03d                	j	80003750 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003724:	f7f9                	bnez	a5,800036f2 <iget+0x3c>
    80003726:	8926                	mv	s2,s1
    80003728:	b7e9                	j	800036f2 <iget+0x3c>
  if(empty == 0)
    8000372a:	02090c63          	beqz	s2,80003762 <iget+0xac>
  ip->dev = dev;
    8000372e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003732:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003736:	4785                	li	a5,1
    80003738:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000373c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003740:	0001d517          	auipc	a0,0x1d
    80003744:	fd850513          	addi	a0,a0,-40 # 80020718 <itable>
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	542080e7          	jalr	1346(ra) # 80000c8a <release>
}
    80003750:	854a                	mv	a0,s2
    80003752:	70a2                	ld	ra,40(sp)
    80003754:	7402                	ld	s0,32(sp)
    80003756:	64e2                	ld	s1,24(sp)
    80003758:	6942                	ld	s2,16(sp)
    8000375a:	69a2                	ld	s3,8(sp)
    8000375c:	6a02                	ld	s4,0(sp)
    8000375e:	6145                	addi	sp,sp,48
    80003760:	8082                	ret
    panic("iget: no inodes");
    80003762:	00005517          	auipc	a0,0x5
    80003766:	eb650513          	addi	a0,a0,-330 # 80008618 <syscalls+0x130>
    8000376a:	ffffd097          	auipc	ra,0xffffd
    8000376e:	dd4080e7          	jalr	-556(ra) # 8000053e <panic>

0000000080003772 <fsinit>:
fsinit(int dev) {
    80003772:	7179                	addi	sp,sp,-48
    80003774:	f406                	sd	ra,40(sp)
    80003776:	f022                	sd	s0,32(sp)
    80003778:	ec26                	sd	s1,24(sp)
    8000377a:	e84a                	sd	s2,16(sp)
    8000377c:	e44e                	sd	s3,8(sp)
    8000377e:	1800                	addi	s0,sp,48
    80003780:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003782:	4585                	li	a1,1
    80003784:	00000097          	auipc	ra,0x0
    80003788:	a50080e7          	jalr	-1456(ra) # 800031d4 <bread>
    8000378c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000378e:	0001d997          	auipc	s3,0x1d
    80003792:	f6a98993          	addi	s3,s3,-150 # 800206f8 <sb>
    80003796:	02000613          	li	a2,32
    8000379a:	05850593          	addi	a1,a0,88
    8000379e:	854e                	mv	a0,s3
    800037a0:	ffffd097          	auipc	ra,0xffffd
    800037a4:	58e080e7          	jalr	1422(ra) # 80000d2e <memmove>
  brelse(bp);
    800037a8:	8526                	mv	a0,s1
    800037aa:	00000097          	auipc	ra,0x0
    800037ae:	b5a080e7          	jalr	-1190(ra) # 80003304 <brelse>
  if(sb.magic != FSMAGIC)
    800037b2:	0009a703          	lw	a4,0(s3)
    800037b6:	102037b7          	lui	a5,0x10203
    800037ba:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037be:	02f71263          	bne	a4,a5,800037e2 <fsinit+0x70>
  initlog(dev, &sb);
    800037c2:	0001d597          	auipc	a1,0x1d
    800037c6:	f3658593          	addi	a1,a1,-202 # 800206f8 <sb>
    800037ca:	854a                	mv	a0,s2
    800037cc:	00001097          	auipc	ra,0x1
    800037d0:	b40080e7          	jalr	-1216(ra) # 8000430c <initlog>
}
    800037d4:	70a2                	ld	ra,40(sp)
    800037d6:	7402                	ld	s0,32(sp)
    800037d8:	64e2                	ld	s1,24(sp)
    800037da:	6942                	ld	s2,16(sp)
    800037dc:	69a2                	ld	s3,8(sp)
    800037de:	6145                	addi	sp,sp,48
    800037e0:	8082                	ret
    panic("invalid file system");
    800037e2:	00005517          	auipc	a0,0x5
    800037e6:	e4650513          	addi	a0,a0,-442 # 80008628 <syscalls+0x140>
    800037ea:	ffffd097          	auipc	ra,0xffffd
    800037ee:	d54080e7          	jalr	-684(ra) # 8000053e <panic>

00000000800037f2 <iinit>:
{
    800037f2:	7179                	addi	sp,sp,-48
    800037f4:	f406                	sd	ra,40(sp)
    800037f6:	f022                	sd	s0,32(sp)
    800037f8:	ec26                	sd	s1,24(sp)
    800037fa:	e84a                	sd	s2,16(sp)
    800037fc:	e44e                	sd	s3,8(sp)
    800037fe:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003800:	00005597          	auipc	a1,0x5
    80003804:	e4058593          	addi	a1,a1,-448 # 80008640 <syscalls+0x158>
    80003808:	0001d517          	auipc	a0,0x1d
    8000380c:	f1050513          	addi	a0,a0,-240 # 80020718 <itable>
    80003810:	ffffd097          	auipc	ra,0xffffd
    80003814:	336080e7          	jalr	822(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003818:	0001d497          	auipc	s1,0x1d
    8000381c:	f2848493          	addi	s1,s1,-216 # 80020740 <itable+0x28>
    80003820:	0001f997          	auipc	s3,0x1f
    80003824:	9b098993          	addi	s3,s3,-1616 # 800221d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003828:	00005917          	auipc	s2,0x5
    8000382c:	e2090913          	addi	s2,s2,-480 # 80008648 <syscalls+0x160>
    80003830:	85ca                	mv	a1,s2
    80003832:	8526                	mv	a0,s1
    80003834:	00001097          	auipc	ra,0x1
    80003838:	e3a080e7          	jalr	-454(ra) # 8000466e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000383c:	08848493          	addi	s1,s1,136
    80003840:	ff3498e3          	bne	s1,s3,80003830 <iinit+0x3e>
}
    80003844:	70a2                	ld	ra,40(sp)
    80003846:	7402                	ld	s0,32(sp)
    80003848:	64e2                	ld	s1,24(sp)
    8000384a:	6942                	ld	s2,16(sp)
    8000384c:	69a2                	ld	s3,8(sp)
    8000384e:	6145                	addi	sp,sp,48
    80003850:	8082                	ret

0000000080003852 <ialloc>:
{
    80003852:	715d                	addi	sp,sp,-80
    80003854:	e486                	sd	ra,72(sp)
    80003856:	e0a2                	sd	s0,64(sp)
    80003858:	fc26                	sd	s1,56(sp)
    8000385a:	f84a                	sd	s2,48(sp)
    8000385c:	f44e                	sd	s3,40(sp)
    8000385e:	f052                	sd	s4,32(sp)
    80003860:	ec56                	sd	s5,24(sp)
    80003862:	e85a                	sd	s6,16(sp)
    80003864:	e45e                	sd	s7,8(sp)
    80003866:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003868:	0001d717          	auipc	a4,0x1d
    8000386c:	e9c72703          	lw	a4,-356(a4) # 80020704 <sb+0xc>
    80003870:	4785                	li	a5,1
    80003872:	04e7fa63          	bgeu	a5,a4,800038c6 <ialloc+0x74>
    80003876:	8aaa                	mv	s5,a0
    80003878:	8bae                	mv	s7,a1
    8000387a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000387c:	0001da17          	auipc	s4,0x1d
    80003880:	e7ca0a13          	addi	s4,s4,-388 # 800206f8 <sb>
    80003884:	00048b1b          	sext.w	s6,s1
    80003888:	0044d793          	srli	a5,s1,0x4
    8000388c:	018a2583          	lw	a1,24(s4)
    80003890:	9dbd                	addw	a1,a1,a5
    80003892:	8556                	mv	a0,s5
    80003894:	00000097          	auipc	ra,0x0
    80003898:	940080e7          	jalr	-1728(ra) # 800031d4 <bread>
    8000389c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000389e:	05850993          	addi	s3,a0,88
    800038a2:	00f4f793          	andi	a5,s1,15
    800038a6:	079a                	slli	a5,a5,0x6
    800038a8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800038aa:	00099783          	lh	a5,0(s3)
    800038ae:	c3a1                	beqz	a5,800038ee <ialloc+0x9c>
    brelse(bp);
    800038b0:	00000097          	auipc	ra,0x0
    800038b4:	a54080e7          	jalr	-1452(ra) # 80003304 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038b8:	0485                	addi	s1,s1,1
    800038ba:	00ca2703          	lw	a4,12(s4)
    800038be:	0004879b          	sext.w	a5,s1
    800038c2:	fce7e1e3          	bltu	a5,a4,80003884 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800038c6:	00005517          	auipc	a0,0x5
    800038ca:	d8a50513          	addi	a0,a0,-630 # 80008650 <syscalls+0x168>
    800038ce:	ffffd097          	auipc	ra,0xffffd
    800038d2:	cba080e7          	jalr	-838(ra) # 80000588 <printf>
  return 0;
    800038d6:	4501                	li	a0,0
}
    800038d8:	60a6                	ld	ra,72(sp)
    800038da:	6406                	ld	s0,64(sp)
    800038dc:	74e2                	ld	s1,56(sp)
    800038de:	7942                	ld	s2,48(sp)
    800038e0:	79a2                	ld	s3,40(sp)
    800038e2:	7a02                	ld	s4,32(sp)
    800038e4:	6ae2                	ld	s5,24(sp)
    800038e6:	6b42                	ld	s6,16(sp)
    800038e8:	6ba2                	ld	s7,8(sp)
    800038ea:	6161                	addi	sp,sp,80
    800038ec:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038ee:	04000613          	li	a2,64
    800038f2:	4581                	li	a1,0
    800038f4:	854e                	mv	a0,s3
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	3dc080e7          	jalr	988(ra) # 80000cd2 <memset>
      dip->type = type;
    800038fe:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003902:	854a                	mv	a0,s2
    80003904:	00001097          	auipc	ra,0x1
    80003908:	c84080e7          	jalr	-892(ra) # 80004588 <log_write>
      brelse(bp);
    8000390c:	854a                	mv	a0,s2
    8000390e:	00000097          	auipc	ra,0x0
    80003912:	9f6080e7          	jalr	-1546(ra) # 80003304 <brelse>
      return iget(dev, inum);
    80003916:	85da                	mv	a1,s6
    80003918:	8556                	mv	a0,s5
    8000391a:	00000097          	auipc	ra,0x0
    8000391e:	d9c080e7          	jalr	-612(ra) # 800036b6 <iget>
    80003922:	bf5d                	j	800038d8 <ialloc+0x86>

0000000080003924 <iupdate>:
{
    80003924:	1101                	addi	sp,sp,-32
    80003926:	ec06                	sd	ra,24(sp)
    80003928:	e822                	sd	s0,16(sp)
    8000392a:	e426                	sd	s1,8(sp)
    8000392c:	e04a                	sd	s2,0(sp)
    8000392e:	1000                	addi	s0,sp,32
    80003930:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003932:	415c                	lw	a5,4(a0)
    80003934:	0047d79b          	srliw	a5,a5,0x4
    80003938:	0001d597          	auipc	a1,0x1d
    8000393c:	dd85a583          	lw	a1,-552(a1) # 80020710 <sb+0x18>
    80003940:	9dbd                	addw	a1,a1,a5
    80003942:	4108                	lw	a0,0(a0)
    80003944:	00000097          	auipc	ra,0x0
    80003948:	890080e7          	jalr	-1904(ra) # 800031d4 <bread>
    8000394c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000394e:	05850793          	addi	a5,a0,88
    80003952:	40c8                	lw	a0,4(s1)
    80003954:	893d                	andi	a0,a0,15
    80003956:	051a                	slli	a0,a0,0x6
    80003958:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000395a:	04449703          	lh	a4,68(s1)
    8000395e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003962:	04649703          	lh	a4,70(s1)
    80003966:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000396a:	04849703          	lh	a4,72(s1)
    8000396e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003972:	04a49703          	lh	a4,74(s1)
    80003976:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000397a:	44f8                	lw	a4,76(s1)
    8000397c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000397e:	03400613          	li	a2,52
    80003982:	05048593          	addi	a1,s1,80
    80003986:	0531                	addi	a0,a0,12
    80003988:	ffffd097          	auipc	ra,0xffffd
    8000398c:	3a6080e7          	jalr	934(ra) # 80000d2e <memmove>
  log_write(bp);
    80003990:	854a                	mv	a0,s2
    80003992:	00001097          	auipc	ra,0x1
    80003996:	bf6080e7          	jalr	-1034(ra) # 80004588 <log_write>
  brelse(bp);
    8000399a:	854a                	mv	a0,s2
    8000399c:	00000097          	auipc	ra,0x0
    800039a0:	968080e7          	jalr	-1688(ra) # 80003304 <brelse>
}
    800039a4:	60e2                	ld	ra,24(sp)
    800039a6:	6442                	ld	s0,16(sp)
    800039a8:	64a2                	ld	s1,8(sp)
    800039aa:	6902                	ld	s2,0(sp)
    800039ac:	6105                	addi	sp,sp,32
    800039ae:	8082                	ret

00000000800039b0 <idup>:
{
    800039b0:	1101                	addi	sp,sp,-32
    800039b2:	ec06                	sd	ra,24(sp)
    800039b4:	e822                	sd	s0,16(sp)
    800039b6:	e426                	sd	s1,8(sp)
    800039b8:	1000                	addi	s0,sp,32
    800039ba:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039bc:	0001d517          	auipc	a0,0x1d
    800039c0:	d5c50513          	addi	a0,a0,-676 # 80020718 <itable>
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  ip->ref++;
    800039cc:	449c                	lw	a5,8(s1)
    800039ce:	2785                	addiw	a5,a5,1
    800039d0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039d2:	0001d517          	auipc	a0,0x1d
    800039d6:	d4650513          	addi	a0,a0,-698 # 80020718 <itable>
    800039da:	ffffd097          	auipc	ra,0xffffd
    800039de:	2b0080e7          	jalr	688(ra) # 80000c8a <release>
}
    800039e2:	8526                	mv	a0,s1
    800039e4:	60e2                	ld	ra,24(sp)
    800039e6:	6442                	ld	s0,16(sp)
    800039e8:	64a2                	ld	s1,8(sp)
    800039ea:	6105                	addi	sp,sp,32
    800039ec:	8082                	ret

00000000800039ee <ilock>:
{
    800039ee:	1101                	addi	sp,sp,-32
    800039f0:	ec06                	sd	ra,24(sp)
    800039f2:	e822                	sd	s0,16(sp)
    800039f4:	e426                	sd	s1,8(sp)
    800039f6:	e04a                	sd	s2,0(sp)
    800039f8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039fa:	c115                	beqz	a0,80003a1e <ilock+0x30>
    800039fc:	84aa                	mv	s1,a0
    800039fe:	451c                	lw	a5,8(a0)
    80003a00:	00f05f63          	blez	a5,80003a1e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a04:	0541                	addi	a0,a0,16
    80003a06:	00001097          	auipc	ra,0x1
    80003a0a:	ca2080e7          	jalr	-862(ra) # 800046a8 <acquiresleep>
  if(ip->valid == 0){
    80003a0e:	40bc                	lw	a5,64(s1)
    80003a10:	cf99                	beqz	a5,80003a2e <ilock+0x40>
}
    80003a12:	60e2                	ld	ra,24(sp)
    80003a14:	6442                	ld	s0,16(sp)
    80003a16:	64a2                	ld	s1,8(sp)
    80003a18:	6902                	ld	s2,0(sp)
    80003a1a:	6105                	addi	sp,sp,32
    80003a1c:	8082                	ret
    panic("ilock");
    80003a1e:	00005517          	auipc	a0,0x5
    80003a22:	c4a50513          	addi	a0,a0,-950 # 80008668 <syscalls+0x180>
    80003a26:	ffffd097          	auipc	ra,0xffffd
    80003a2a:	b18080e7          	jalr	-1256(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a2e:	40dc                	lw	a5,4(s1)
    80003a30:	0047d79b          	srliw	a5,a5,0x4
    80003a34:	0001d597          	auipc	a1,0x1d
    80003a38:	cdc5a583          	lw	a1,-804(a1) # 80020710 <sb+0x18>
    80003a3c:	9dbd                	addw	a1,a1,a5
    80003a3e:	4088                	lw	a0,0(s1)
    80003a40:	fffff097          	auipc	ra,0xfffff
    80003a44:	794080e7          	jalr	1940(ra) # 800031d4 <bread>
    80003a48:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a4a:	05850593          	addi	a1,a0,88
    80003a4e:	40dc                	lw	a5,4(s1)
    80003a50:	8bbd                	andi	a5,a5,15
    80003a52:	079a                	slli	a5,a5,0x6
    80003a54:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a56:	00059783          	lh	a5,0(a1)
    80003a5a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a5e:	00259783          	lh	a5,2(a1)
    80003a62:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a66:	00459783          	lh	a5,4(a1)
    80003a6a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a6e:	00659783          	lh	a5,6(a1)
    80003a72:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a76:	459c                	lw	a5,8(a1)
    80003a78:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a7a:	03400613          	li	a2,52
    80003a7e:	05b1                	addi	a1,a1,12
    80003a80:	05048513          	addi	a0,s1,80
    80003a84:	ffffd097          	auipc	ra,0xffffd
    80003a88:	2aa080e7          	jalr	682(ra) # 80000d2e <memmove>
    brelse(bp);
    80003a8c:	854a                	mv	a0,s2
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	876080e7          	jalr	-1930(ra) # 80003304 <brelse>
    ip->valid = 1;
    80003a96:	4785                	li	a5,1
    80003a98:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a9a:	04449783          	lh	a5,68(s1)
    80003a9e:	fbb5                	bnez	a5,80003a12 <ilock+0x24>
      panic("ilock: no type");
    80003aa0:	00005517          	auipc	a0,0x5
    80003aa4:	bd050513          	addi	a0,a0,-1072 # 80008670 <syscalls+0x188>
    80003aa8:	ffffd097          	auipc	ra,0xffffd
    80003aac:	a96080e7          	jalr	-1386(ra) # 8000053e <panic>

0000000080003ab0 <iunlock>:
{
    80003ab0:	1101                	addi	sp,sp,-32
    80003ab2:	ec06                	sd	ra,24(sp)
    80003ab4:	e822                	sd	s0,16(sp)
    80003ab6:	e426                	sd	s1,8(sp)
    80003ab8:	e04a                	sd	s2,0(sp)
    80003aba:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003abc:	c905                	beqz	a0,80003aec <iunlock+0x3c>
    80003abe:	84aa                	mv	s1,a0
    80003ac0:	01050913          	addi	s2,a0,16
    80003ac4:	854a                	mv	a0,s2
    80003ac6:	00001097          	auipc	ra,0x1
    80003aca:	c7c080e7          	jalr	-900(ra) # 80004742 <holdingsleep>
    80003ace:	cd19                	beqz	a0,80003aec <iunlock+0x3c>
    80003ad0:	449c                	lw	a5,8(s1)
    80003ad2:	00f05d63          	blez	a5,80003aec <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ad6:	854a                	mv	a0,s2
    80003ad8:	00001097          	auipc	ra,0x1
    80003adc:	c26080e7          	jalr	-986(ra) # 800046fe <releasesleep>
}
    80003ae0:	60e2                	ld	ra,24(sp)
    80003ae2:	6442                	ld	s0,16(sp)
    80003ae4:	64a2                	ld	s1,8(sp)
    80003ae6:	6902                	ld	s2,0(sp)
    80003ae8:	6105                	addi	sp,sp,32
    80003aea:	8082                	ret
    panic("iunlock");
    80003aec:	00005517          	auipc	a0,0x5
    80003af0:	b9450513          	addi	a0,a0,-1132 # 80008680 <syscalls+0x198>
    80003af4:	ffffd097          	auipc	ra,0xffffd
    80003af8:	a4a080e7          	jalr	-1462(ra) # 8000053e <panic>

0000000080003afc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003afc:	7179                	addi	sp,sp,-48
    80003afe:	f406                	sd	ra,40(sp)
    80003b00:	f022                	sd	s0,32(sp)
    80003b02:	ec26                	sd	s1,24(sp)
    80003b04:	e84a                	sd	s2,16(sp)
    80003b06:	e44e                	sd	s3,8(sp)
    80003b08:	e052                	sd	s4,0(sp)
    80003b0a:	1800                	addi	s0,sp,48
    80003b0c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b0e:	05050493          	addi	s1,a0,80
    80003b12:	08050913          	addi	s2,a0,128
    80003b16:	a021                	j	80003b1e <itrunc+0x22>
    80003b18:	0491                	addi	s1,s1,4
    80003b1a:	01248d63          	beq	s1,s2,80003b34 <itrunc+0x38>
    if(ip->addrs[i]){
    80003b1e:	408c                	lw	a1,0(s1)
    80003b20:	dde5                	beqz	a1,80003b18 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b22:	0009a503          	lw	a0,0(s3)
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	8f4080e7          	jalr	-1804(ra) # 8000341a <bfree>
      ip->addrs[i] = 0;
    80003b2e:	0004a023          	sw	zero,0(s1)
    80003b32:	b7dd                	j	80003b18 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b34:	0809a583          	lw	a1,128(s3)
    80003b38:	e185                	bnez	a1,80003b58 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b3a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b3e:	854e                	mv	a0,s3
    80003b40:	00000097          	auipc	ra,0x0
    80003b44:	de4080e7          	jalr	-540(ra) # 80003924 <iupdate>
}
    80003b48:	70a2                	ld	ra,40(sp)
    80003b4a:	7402                	ld	s0,32(sp)
    80003b4c:	64e2                	ld	s1,24(sp)
    80003b4e:	6942                	ld	s2,16(sp)
    80003b50:	69a2                	ld	s3,8(sp)
    80003b52:	6a02                	ld	s4,0(sp)
    80003b54:	6145                	addi	sp,sp,48
    80003b56:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b58:	0009a503          	lw	a0,0(s3)
    80003b5c:	fffff097          	auipc	ra,0xfffff
    80003b60:	678080e7          	jalr	1656(ra) # 800031d4 <bread>
    80003b64:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b66:	05850493          	addi	s1,a0,88
    80003b6a:	45850913          	addi	s2,a0,1112
    80003b6e:	a021                	j	80003b76 <itrunc+0x7a>
    80003b70:	0491                	addi	s1,s1,4
    80003b72:	01248b63          	beq	s1,s2,80003b88 <itrunc+0x8c>
      if(a[j])
    80003b76:	408c                	lw	a1,0(s1)
    80003b78:	dde5                	beqz	a1,80003b70 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b7a:	0009a503          	lw	a0,0(s3)
    80003b7e:	00000097          	auipc	ra,0x0
    80003b82:	89c080e7          	jalr	-1892(ra) # 8000341a <bfree>
    80003b86:	b7ed                	j	80003b70 <itrunc+0x74>
    brelse(bp);
    80003b88:	8552                	mv	a0,s4
    80003b8a:	fffff097          	auipc	ra,0xfffff
    80003b8e:	77a080e7          	jalr	1914(ra) # 80003304 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b92:	0809a583          	lw	a1,128(s3)
    80003b96:	0009a503          	lw	a0,0(s3)
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	880080e7          	jalr	-1920(ra) # 8000341a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ba2:	0809a023          	sw	zero,128(s3)
    80003ba6:	bf51                	j	80003b3a <itrunc+0x3e>

0000000080003ba8 <iput>:
{
    80003ba8:	1101                	addi	sp,sp,-32
    80003baa:	ec06                	sd	ra,24(sp)
    80003bac:	e822                	sd	s0,16(sp)
    80003bae:	e426                	sd	s1,8(sp)
    80003bb0:	e04a                	sd	s2,0(sp)
    80003bb2:	1000                	addi	s0,sp,32
    80003bb4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bb6:	0001d517          	auipc	a0,0x1d
    80003bba:	b6250513          	addi	a0,a0,-1182 # 80020718 <itable>
    80003bbe:	ffffd097          	auipc	ra,0xffffd
    80003bc2:	018080e7          	jalr	24(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bc6:	4498                	lw	a4,8(s1)
    80003bc8:	4785                	li	a5,1
    80003bca:	02f70363          	beq	a4,a5,80003bf0 <iput+0x48>
  ip->ref--;
    80003bce:	449c                	lw	a5,8(s1)
    80003bd0:	37fd                	addiw	a5,a5,-1
    80003bd2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bd4:	0001d517          	auipc	a0,0x1d
    80003bd8:	b4450513          	addi	a0,a0,-1212 # 80020718 <itable>
    80003bdc:	ffffd097          	auipc	ra,0xffffd
    80003be0:	0ae080e7          	jalr	174(ra) # 80000c8a <release>
}
    80003be4:	60e2                	ld	ra,24(sp)
    80003be6:	6442                	ld	s0,16(sp)
    80003be8:	64a2                	ld	s1,8(sp)
    80003bea:	6902                	ld	s2,0(sp)
    80003bec:	6105                	addi	sp,sp,32
    80003bee:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bf0:	40bc                	lw	a5,64(s1)
    80003bf2:	dff1                	beqz	a5,80003bce <iput+0x26>
    80003bf4:	04a49783          	lh	a5,74(s1)
    80003bf8:	fbf9                	bnez	a5,80003bce <iput+0x26>
    acquiresleep(&ip->lock);
    80003bfa:	01048913          	addi	s2,s1,16
    80003bfe:	854a                	mv	a0,s2
    80003c00:	00001097          	auipc	ra,0x1
    80003c04:	aa8080e7          	jalr	-1368(ra) # 800046a8 <acquiresleep>
    release(&itable.lock);
    80003c08:	0001d517          	auipc	a0,0x1d
    80003c0c:	b1050513          	addi	a0,a0,-1264 # 80020718 <itable>
    80003c10:	ffffd097          	auipc	ra,0xffffd
    80003c14:	07a080e7          	jalr	122(ra) # 80000c8a <release>
    itrunc(ip);
    80003c18:	8526                	mv	a0,s1
    80003c1a:	00000097          	auipc	ra,0x0
    80003c1e:	ee2080e7          	jalr	-286(ra) # 80003afc <itrunc>
    ip->type = 0;
    80003c22:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c26:	8526                	mv	a0,s1
    80003c28:	00000097          	auipc	ra,0x0
    80003c2c:	cfc080e7          	jalr	-772(ra) # 80003924 <iupdate>
    ip->valid = 0;
    80003c30:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c34:	854a                	mv	a0,s2
    80003c36:	00001097          	auipc	ra,0x1
    80003c3a:	ac8080e7          	jalr	-1336(ra) # 800046fe <releasesleep>
    acquire(&itable.lock);
    80003c3e:	0001d517          	auipc	a0,0x1d
    80003c42:	ada50513          	addi	a0,a0,-1318 # 80020718 <itable>
    80003c46:	ffffd097          	auipc	ra,0xffffd
    80003c4a:	f90080e7          	jalr	-112(ra) # 80000bd6 <acquire>
    80003c4e:	b741                	j	80003bce <iput+0x26>

0000000080003c50 <iunlockput>:
{
    80003c50:	1101                	addi	sp,sp,-32
    80003c52:	ec06                	sd	ra,24(sp)
    80003c54:	e822                	sd	s0,16(sp)
    80003c56:	e426                	sd	s1,8(sp)
    80003c58:	1000                	addi	s0,sp,32
    80003c5a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	e54080e7          	jalr	-428(ra) # 80003ab0 <iunlock>
  iput(ip);
    80003c64:	8526                	mv	a0,s1
    80003c66:	00000097          	auipc	ra,0x0
    80003c6a:	f42080e7          	jalr	-190(ra) # 80003ba8 <iput>
}
    80003c6e:	60e2                	ld	ra,24(sp)
    80003c70:	6442                	ld	s0,16(sp)
    80003c72:	64a2                	ld	s1,8(sp)
    80003c74:	6105                	addi	sp,sp,32
    80003c76:	8082                	ret

0000000080003c78 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c78:	1141                	addi	sp,sp,-16
    80003c7a:	e422                	sd	s0,8(sp)
    80003c7c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c7e:	411c                	lw	a5,0(a0)
    80003c80:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c82:	415c                	lw	a5,4(a0)
    80003c84:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c86:	04451783          	lh	a5,68(a0)
    80003c8a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c8e:	04a51783          	lh	a5,74(a0)
    80003c92:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c96:	04c56783          	lwu	a5,76(a0)
    80003c9a:	e99c                	sd	a5,16(a1)
}
    80003c9c:	6422                	ld	s0,8(sp)
    80003c9e:	0141                	addi	sp,sp,16
    80003ca0:	8082                	ret

0000000080003ca2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ca2:	457c                	lw	a5,76(a0)
    80003ca4:	0ed7e963          	bltu	a5,a3,80003d96 <readi+0xf4>
{
    80003ca8:	7159                	addi	sp,sp,-112
    80003caa:	f486                	sd	ra,104(sp)
    80003cac:	f0a2                	sd	s0,96(sp)
    80003cae:	eca6                	sd	s1,88(sp)
    80003cb0:	e8ca                	sd	s2,80(sp)
    80003cb2:	e4ce                	sd	s3,72(sp)
    80003cb4:	e0d2                	sd	s4,64(sp)
    80003cb6:	fc56                	sd	s5,56(sp)
    80003cb8:	f85a                	sd	s6,48(sp)
    80003cba:	f45e                	sd	s7,40(sp)
    80003cbc:	f062                	sd	s8,32(sp)
    80003cbe:	ec66                	sd	s9,24(sp)
    80003cc0:	e86a                	sd	s10,16(sp)
    80003cc2:	e46e                	sd	s11,8(sp)
    80003cc4:	1880                	addi	s0,sp,112
    80003cc6:	8b2a                	mv	s6,a0
    80003cc8:	8bae                	mv	s7,a1
    80003cca:	8a32                	mv	s4,a2
    80003ccc:	84b6                	mv	s1,a3
    80003cce:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003cd0:	9f35                	addw	a4,a4,a3
    return 0;
    80003cd2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cd4:	0ad76063          	bltu	a4,a3,80003d74 <readi+0xd2>
  if(off + n > ip->size)
    80003cd8:	00e7f463          	bgeu	a5,a4,80003ce0 <readi+0x3e>
    n = ip->size - off;
    80003cdc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ce0:	0a0a8963          	beqz	s5,80003d92 <readi+0xf0>
    80003ce4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ce6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cea:	5c7d                	li	s8,-1
    80003cec:	a82d                	j	80003d26 <readi+0x84>
    80003cee:	020d1d93          	slli	s11,s10,0x20
    80003cf2:	020ddd93          	srli	s11,s11,0x20
    80003cf6:	05890793          	addi	a5,s2,88
    80003cfa:	86ee                	mv	a3,s11
    80003cfc:	963e                	add	a2,a2,a5
    80003cfe:	85d2                	mv	a1,s4
    80003d00:	855e                	mv	a0,s7
    80003d02:	fffff097          	auipc	ra,0xfffff
    80003d06:	8ce080e7          	jalr	-1842(ra) # 800025d0 <either_copyout>
    80003d0a:	05850d63          	beq	a0,s8,80003d64 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d0e:	854a                	mv	a0,s2
    80003d10:	fffff097          	auipc	ra,0xfffff
    80003d14:	5f4080e7          	jalr	1524(ra) # 80003304 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d18:	013d09bb          	addw	s3,s10,s3
    80003d1c:	009d04bb          	addw	s1,s10,s1
    80003d20:	9a6e                	add	s4,s4,s11
    80003d22:	0559f763          	bgeu	s3,s5,80003d70 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003d26:	00a4d59b          	srliw	a1,s1,0xa
    80003d2a:	855a                	mv	a0,s6
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	8a2080e7          	jalr	-1886(ra) # 800035ce <bmap>
    80003d34:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d38:	cd85                	beqz	a1,80003d70 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d3a:	000b2503          	lw	a0,0(s6)
    80003d3e:	fffff097          	auipc	ra,0xfffff
    80003d42:	496080e7          	jalr	1174(ra) # 800031d4 <bread>
    80003d46:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d48:	3ff4f613          	andi	a2,s1,1023
    80003d4c:	40cc87bb          	subw	a5,s9,a2
    80003d50:	413a873b          	subw	a4,s5,s3
    80003d54:	8d3e                	mv	s10,a5
    80003d56:	2781                	sext.w	a5,a5
    80003d58:	0007069b          	sext.w	a3,a4
    80003d5c:	f8f6f9e3          	bgeu	a3,a5,80003cee <readi+0x4c>
    80003d60:	8d3a                	mv	s10,a4
    80003d62:	b771                	j	80003cee <readi+0x4c>
      brelse(bp);
    80003d64:	854a                	mv	a0,s2
    80003d66:	fffff097          	auipc	ra,0xfffff
    80003d6a:	59e080e7          	jalr	1438(ra) # 80003304 <brelse>
      tot = -1;
    80003d6e:	59fd                	li	s3,-1
  }
  return tot;
    80003d70:	0009851b          	sext.w	a0,s3
}
    80003d74:	70a6                	ld	ra,104(sp)
    80003d76:	7406                	ld	s0,96(sp)
    80003d78:	64e6                	ld	s1,88(sp)
    80003d7a:	6946                	ld	s2,80(sp)
    80003d7c:	69a6                	ld	s3,72(sp)
    80003d7e:	6a06                	ld	s4,64(sp)
    80003d80:	7ae2                	ld	s5,56(sp)
    80003d82:	7b42                	ld	s6,48(sp)
    80003d84:	7ba2                	ld	s7,40(sp)
    80003d86:	7c02                	ld	s8,32(sp)
    80003d88:	6ce2                	ld	s9,24(sp)
    80003d8a:	6d42                	ld	s10,16(sp)
    80003d8c:	6da2                	ld	s11,8(sp)
    80003d8e:	6165                	addi	sp,sp,112
    80003d90:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d92:	89d6                	mv	s3,s5
    80003d94:	bff1                	j	80003d70 <readi+0xce>
    return 0;
    80003d96:	4501                	li	a0,0
}
    80003d98:	8082                	ret

0000000080003d9a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d9a:	457c                	lw	a5,76(a0)
    80003d9c:	10d7e863          	bltu	a5,a3,80003eac <writei+0x112>
{
    80003da0:	7159                	addi	sp,sp,-112
    80003da2:	f486                	sd	ra,104(sp)
    80003da4:	f0a2                	sd	s0,96(sp)
    80003da6:	eca6                	sd	s1,88(sp)
    80003da8:	e8ca                	sd	s2,80(sp)
    80003daa:	e4ce                	sd	s3,72(sp)
    80003dac:	e0d2                	sd	s4,64(sp)
    80003dae:	fc56                	sd	s5,56(sp)
    80003db0:	f85a                	sd	s6,48(sp)
    80003db2:	f45e                	sd	s7,40(sp)
    80003db4:	f062                	sd	s8,32(sp)
    80003db6:	ec66                	sd	s9,24(sp)
    80003db8:	e86a                	sd	s10,16(sp)
    80003dba:	e46e                	sd	s11,8(sp)
    80003dbc:	1880                	addi	s0,sp,112
    80003dbe:	8aaa                	mv	s5,a0
    80003dc0:	8bae                	mv	s7,a1
    80003dc2:	8a32                	mv	s4,a2
    80003dc4:	8936                	mv	s2,a3
    80003dc6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003dc8:	00e687bb          	addw	a5,a3,a4
    80003dcc:	0ed7e263          	bltu	a5,a3,80003eb0 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dd0:	00043737          	lui	a4,0x43
    80003dd4:	0ef76063          	bltu	a4,a5,80003eb4 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dd8:	0c0b0863          	beqz	s6,80003ea8 <writei+0x10e>
    80003ddc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dde:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003de2:	5c7d                	li	s8,-1
    80003de4:	a091                	j	80003e28 <writei+0x8e>
    80003de6:	020d1d93          	slli	s11,s10,0x20
    80003dea:	020ddd93          	srli	s11,s11,0x20
    80003dee:	05848793          	addi	a5,s1,88
    80003df2:	86ee                	mv	a3,s11
    80003df4:	8652                	mv	a2,s4
    80003df6:	85de                	mv	a1,s7
    80003df8:	953e                	add	a0,a0,a5
    80003dfa:	fffff097          	auipc	ra,0xfffff
    80003dfe:	82e080e7          	jalr	-2002(ra) # 80002628 <either_copyin>
    80003e02:	07850263          	beq	a0,s8,80003e66 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e06:	8526                	mv	a0,s1
    80003e08:	00000097          	auipc	ra,0x0
    80003e0c:	780080e7          	jalr	1920(ra) # 80004588 <log_write>
    brelse(bp);
    80003e10:	8526                	mv	a0,s1
    80003e12:	fffff097          	auipc	ra,0xfffff
    80003e16:	4f2080e7          	jalr	1266(ra) # 80003304 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e1a:	013d09bb          	addw	s3,s10,s3
    80003e1e:	012d093b          	addw	s2,s10,s2
    80003e22:	9a6e                	add	s4,s4,s11
    80003e24:	0569f663          	bgeu	s3,s6,80003e70 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003e28:	00a9559b          	srliw	a1,s2,0xa
    80003e2c:	8556                	mv	a0,s5
    80003e2e:	fffff097          	auipc	ra,0xfffff
    80003e32:	7a0080e7          	jalr	1952(ra) # 800035ce <bmap>
    80003e36:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e3a:	c99d                	beqz	a1,80003e70 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e3c:	000aa503          	lw	a0,0(s5)
    80003e40:	fffff097          	auipc	ra,0xfffff
    80003e44:	394080e7          	jalr	916(ra) # 800031d4 <bread>
    80003e48:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e4a:	3ff97513          	andi	a0,s2,1023
    80003e4e:	40ac87bb          	subw	a5,s9,a0
    80003e52:	413b073b          	subw	a4,s6,s3
    80003e56:	8d3e                	mv	s10,a5
    80003e58:	2781                	sext.w	a5,a5
    80003e5a:	0007069b          	sext.w	a3,a4
    80003e5e:	f8f6f4e3          	bgeu	a3,a5,80003de6 <writei+0x4c>
    80003e62:	8d3a                	mv	s10,a4
    80003e64:	b749                	j	80003de6 <writei+0x4c>
      brelse(bp);
    80003e66:	8526                	mv	a0,s1
    80003e68:	fffff097          	auipc	ra,0xfffff
    80003e6c:	49c080e7          	jalr	1180(ra) # 80003304 <brelse>
  }

  if(off > ip->size)
    80003e70:	04caa783          	lw	a5,76(s5)
    80003e74:	0127f463          	bgeu	a5,s2,80003e7c <writei+0xe2>
    ip->size = off;
    80003e78:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e7c:	8556                	mv	a0,s5
    80003e7e:	00000097          	auipc	ra,0x0
    80003e82:	aa6080e7          	jalr	-1370(ra) # 80003924 <iupdate>

  return tot;
    80003e86:	0009851b          	sext.w	a0,s3
}
    80003e8a:	70a6                	ld	ra,104(sp)
    80003e8c:	7406                	ld	s0,96(sp)
    80003e8e:	64e6                	ld	s1,88(sp)
    80003e90:	6946                	ld	s2,80(sp)
    80003e92:	69a6                	ld	s3,72(sp)
    80003e94:	6a06                	ld	s4,64(sp)
    80003e96:	7ae2                	ld	s5,56(sp)
    80003e98:	7b42                	ld	s6,48(sp)
    80003e9a:	7ba2                	ld	s7,40(sp)
    80003e9c:	7c02                	ld	s8,32(sp)
    80003e9e:	6ce2                	ld	s9,24(sp)
    80003ea0:	6d42                	ld	s10,16(sp)
    80003ea2:	6da2                	ld	s11,8(sp)
    80003ea4:	6165                	addi	sp,sp,112
    80003ea6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ea8:	89da                	mv	s3,s6
    80003eaa:	bfc9                	j	80003e7c <writei+0xe2>
    return -1;
    80003eac:	557d                	li	a0,-1
}
    80003eae:	8082                	ret
    return -1;
    80003eb0:	557d                	li	a0,-1
    80003eb2:	bfe1                	j	80003e8a <writei+0xf0>
    return -1;
    80003eb4:	557d                	li	a0,-1
    80003eb6:	bfd1                	j	80003e8a <writei+0xf0>

0000000080003eb8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003eb8:	1141                	addi	sp,sp,-16
    80003eba:	e406                	sd	ra,8(sp)
    80003ebc:	e022                	sd	s0,0(sp)
    80003ebe:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ec0:	4639                	li	a2,14
    80003ec2:	ffffd097          	auipc	ra,0xffffd
    80003ec6:	ee0080e7          	jalr	-288(ra) # 80000da2 <strncmp>
}
    80003eca:	60a2                	ld	ra,8(sp)
    80003ecc:	6402                	ld	s0,0(sp)
    80003ece:	0141                	addi	sp,sp,16
    80003ed0:	8082                	ret

0000000080003ed2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ed2:	7139                	addi	sp,sp,-64
    80003ed4:	fc06                	sd	ra,56(sp)
    80003ed6:	f822                	sd	s0,48(sp)
    80003ed8:	f426                	sd	s1,40(sp)
    80003eda:	f04a                	sd	s2,32(sp)
    80003edc:	ec4e                	sd	s3,24(sp)
    80003ede:	e852                	sd	s4,16(sp)
    80003ee0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ee2:	04451703          	lh	a4,68(a0)
    80003ee6:	4785                	li	a5,1
    80003ee8:	00f71a63          	bne	a4,a5,80003efc <dirlookup+0x2a>
    80003eec:	892a                	mv	s2,a0
    80003eee:	89ae                	mv	s3,a1
    80003ef0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ef2:	457c                	lw	a5,76(a0)
    80003ef4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ef6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ef8:	e79d                	bnez	a5,80003f26 <dirlookup+0x54>
    80003efa:	a8a5                	j	80003f72 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003efc:	00004517          	auipc	a0,0x4
    80003f00:	78c50513          	addi	a0,a0,1932 # 80008688 <syscalls+0x1a0>
    80003f04:	ffffc097          	auipc	ra,0xffffc
    80003f08:	63a080e7          	jalr	1594(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003f0c:	00004517          	auipc	a0,0x4
    80003f10:	79450513          	addi	a0,a0,1940 # 800086a0 <syscalls+0x1b8>
    80003f14:	ffffc097          	auipc	ra,0xffffc
    80003f18:	62a080e7          	jalr	1578(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f1c:	24c1                	addiw	s1,s1,16
    80003f1e:	04c92783          	lw	a5,76(s2)
    80003f22:	04f4f763          	bgeu	s1,a5,80003f70 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f26:	4741                	li	a4,16
    80003f28:	86a6                	mv	a3,s1
    80003f2a:	fc040613          	addi	a2,s0,-64
    80003f2e:	4581                	li	a1,0
    80003f30:	854a                	mv	a0,s2
    80003f32:	00000097          	auipc	ra,0x0
    80003f36:	d70080e7          	jalr	-656(ra) # 80003ca2 <readi>
    80003f3a:	47c1                	li	a5,16
    80003f3c:	fcf518e3          	bne	a0,a5,80003f0c <dirlookup+0x3a>
    if(de.inum == 0)
    80003f40:	fc045783          	lhu	a5,-64(s0)
    80003f44:	dfe1                	beqz	a5,80003f1c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f46:	fc240593          	addi	a1,s0,-62
    80003f4a:	854e                	mv	a0,s3
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	f6c080e7          	jalr	-148(ra) # 80003eb8 <namecmp>
    80003f54:	f561                	bnez	a0,80003f1c <dirlookup+0x4a>
      if(poff)
    80003f56:	000a0463          	beqz	s4,80003f5e <dirlookup+0x8c>
        *poff = off;
    80003f5a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f5e:	fc045583          	lhu	a1,-64(s0)
    80003f62:	00092503          	lw	a0,0(s2)
    80003f66:	fffff097          	auipc	ra,0xfffff
    80003f6a:	750080e7          	jalr	1872(ra) # 800036b6 <iget>
    80003f6e:	a011                	j	80003f72 <dirlookup+0xa0>
  return 0;
    80003f70:	4501                	li	a0,0
}
    80003f72:	70e2                	ld	ra,56(sp)
    80003f74:	7442                	ld	s0,48(sp)
    80003f76:	74a2                	ld	s1,40(sp)
    80003f78:	7902                	ld	s2,32(sp)
    80003f7a:	69e2                	ld	s3,24(sp)
    80003f7c:	6a42                	ld	s4,16(sp)
    80003f7e:	6121                	addi	sp,sp,64
    80003f80:	8082                	ret

0000000080003f82 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f82:	711d                	addi	sp,sp,-96
    80003f84:	ec86                	sd	ra,88(sp)
    80003f86:	e8a2                	sd	s0,80(sp)
    80003f88:	e4a6                	sd	s1,72(sp)
    80003f8a:	e0ca                	sd	s2,64(sp)
    80003f8c:	fc4e                	sd	s3,56(sp)
    80003f8e:	f852                	sd	s4,48(sp)
    80003f90:	f456                	sd	s5,40(sp)
    80003f92:	f05a                	sd	s6,32(sp)
    80003f94:	ec5e                	sd	s7,24(sp)
    80003f96:	e862                	sd	s8,16(sp)
    80003f98:	e466                	sd	s9,8(sp)
    80003f9a:	1080                	addi	s0,sp,96
    80003f9c:	84aa                	mv	s1,a0
    80003f9e:	8aae                	mv	s5,a1
    80003fa0:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003fa2:	00054703          	lbu	a4,0(a0)
    80003fa6:	02f00793          	li	a5,47
    80003faa:	02f70363          	beq	a4,a5,80003fd0 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003fae:	ffffe097          	auipc	ra,0xffffe
    80003fb2:	9d2080e7          	jalr	-1582(ra) # 80001980 <myproc>
    80003fb6:	18853503          	ld	a0,392(a0)
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	9f6080e7          	jalr	-1546(ra) # 800039b0 <idup>
    80003fc2:	89aa                	mv	s3,a0
  while(*path == '/')
    80003fc4:	02f00913          	li	s2,47
  len = path - s;
    80003fc8:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003fca:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fcc:	4b85                	li	s7,1
    80003fce:	a865                	j	80004086 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fd0:	4585                	li	a1,1
    80003fd2:	4505                	li	a0,1
    80003fd4:	fffff097          	auipc	ra,0xfffff
    80003fd8:	6e2080e7          	jalr	1762(ra) # 800036b6 <iget>
    80003fdc:	89aa                	mv	s3,a0
    80003fde:	b7dd                	j	80003fc4 <namex+0x42>
      iunlockput(ip);
    80003fe0:	854e                	mv	a0,s3
    80003fe2:	00000097          	auipc	ra,0x0
    80003fe6:	c6e080e7          	jalr	-914(ra) # 80003c50 <iunlockput>
      return 0;
    80003fea:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fec:	854e                	mv	a0,s3
    80003fee:	60e6                	ld	ra,88(sp)
    80003ff0:	6446                	ld	s0,80(sp)
    80003ff2:	64a6                	ld	s1,72(sp)
    80003ff4:	6906                	ld	s2,64(sp)
    80003ff6:	79e2                	ld	s3,56(sp)
    80003ff8:	7a42                	ld	s4,48(sp)
    80003ffa:	7aa2                	ld	s5,40(sp)
    80003ffc:	7b02                	ld	s6,32(sp)
    80003ffe:	6be2                	ld	s7,24(sp)
    80004000:	6c42                	ld	s8,16(sp)
    80004002:	6ca2                	ld	s9,8(sp)
    80004004:	6125                	addi	sp,sp,96
    80004006:	8082                	ret
      iunlock(ip);
    80004008:	854e                	mv	a0,s3
    8000400a:	00000097          	auipc	ra,0x0
    8000400e:	aa6080e7          	jalr	-1370(ra) # 80003ab0 <iunlock>
      return ip;
    80004012:	bfe9                	j	80003fec <namex+0x6a>
      iunlockput(ip);
    80004014:	854e                	mv	a0,s3
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	c3a080e7          	jalr	-966(ra) # 80003c50 <iunlockput>
      return 0;
    8000401e:	89e6                	mv	s3,s9
    80004020:	b7f1                	j	80003fec <namex+0x6a>
  len = path - s;
    80004022:	40b48633          	sub	a2,s1,a1
    80004026:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000402a:	099c5463          	bge	s8,s9,800040b2 <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000402e:	4639                	li	a2,14
    80004030:	8552                	mv	a0,s4
    80004032:	ffffd097          	auipc	ra,0xffffd
    80004036:	cfc080e7          	jalr	-772(ra) # 80000d2e <memmove>
  while(*path == '/')
    8000403a:	0004c783          	lbu	a5,0(s1)
    8000403e:	01279763          	bne	a5,s2,8000404c <namex+0xca>
    path++;
    80004042:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004044:	0004c783          	lbu	a5,0(s1)
    80004048:	ff278de3          	beq	a5,s2,80004042 <namex+0xc0>
    ilock(ip);
    8000404c:	854e                	mv	a0,s3
    8000404e:	00000097          	auipc	ra,0x0
    80004052:	9a0080e7          	jalr	-1632(ra) # 800039ee <ilock>
    if(ip->type != T_DIR){
    80004056:	04499783          	lh	a5,68(s3)
    8000405a:	f97793e3          	bne	a5,s7,80003fe0 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000405e:	000a8563          	beqz	s5,80004068 <namex+0xe6>
    80004062:	0004c783          	lbu	a5,0(s1)
    80004066:	d3cd                	beqz	a5,80004008 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004068:	865a                	mv	a2,s6
    8000406a:	85d2                	mv	a1,s4
    8000406c:	854e                	mv	a0,s3
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	e64080e7          	jalr	-412(ra) # 80003ed2 <dirlookup>
    80004076:	8caa                	mv	s9,a0
    80004078:	dd51                	beqz	a0,80004014 <namex+0x92>
    iunlockput(ip);
    8000407a:	854e                	mv	a0,s3
    8000407c:	00000097          	auipc	ra,0x0
    80004080:	bd4080e7          	jalr	-1068(ra) # 80003c50 <iunlockput>
    ip = next;
    80004084:	89e6                	mv	s3,s9
  while(*path == '/')
    80004086:	0004c783          	lbu	a5,0(s1)
    8000408a:	05279763          	bne	a5,s2,800040d8 <namex+0x156>
    path++;
    8000408e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004090:	0004c783          	lbu	a5,0(s1)
    80004094:	ff278de3          	beq	a5,s2,8000408e <namex+0x10c>
  if(*path == 0)
    80004098:	c79d                	beqz	a5,800040c6 <namex+0x144>
    path++;
    8000409a:	85a6                	mv	a1,s1
  len = path - s;
    8000409c:	8cda                	mv	s9,s6
    8000409e:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800040a0:	01278963          	beq	a5,s2,800040b2 <namex+0x130>
    800040a4:	dfbd                	beqz	a5,80004022 <namex+0xa0>
    path++;
    800040a6:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800040a8:	0004c783          	lbu	a5,0(s1)
    800040ac:	ff279ce3          	bne	a5,s2,800040a4 <namex+0x122>
    800040b0:	bf8d                	j	80004022 <namex+0xa0>
    memmove(name, s, len);
    800040b2:	2601                	sext.w	a2,a2
    800040b4:	8552                	mv	a0,s4
    800040b6:	ffffd097          	auipc	ra,0xffffd
    800040ba:	c78080e7          	jalr	-904(ra) # 80000d2e <memmove>
    name[len] = 0;
    800040be:	9cd2                	add	s9,s9,s4
    800040c0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800040c4:	bf9d                	j	8000403a <namex+0xb8>
  if(nameiparent){
    800040c6:	f20a83e3          	beqz	s5,80003fec <namex+0x6a>
    iput(ip);
    800040ca:	854e                	mv	a0,s3
    800040cc:	00000097          	auipc	ra,0x0
    800040d0:	adc080e7          	jalr	-1316(ra) # 80003ba8 <iput>
    return 0;
    800040d4:	4981                	li	s3,0
    800040d6:	bf19                	j	80003fec <namex+0x6a>
  if(*path == 0)
    800040d8:	d7fd                	beqz	a5,800040c6 <namex+0x144>
  while(*path != '/' && *path != 0)
    800040da:	0004c783          	lbu	a5,0(s1)
    800040de:	85a6                	mv	a1,s1
    800040e0:	b7d1                	j	800040a4 <namex+0x122>

00000000800040e2 <dirlink>:
{
    800040e2:	7139                	addi	sp,sp,-64
    800040e4:	fc06                	sd	ra,56(sp)
    800040e6:	f822                	sd	s0,48(sp)
    800040e8:	f426                	sd	s1,40(sp)
    800040ea:	f04a                	sd	s2,32(sp)
    800040ec:	ec4e                	sd	s3,24(sp)
    800040ee:	e852                	sd	s4,16(sp)
    800040f0:	0080                	addi	s0,sp,64
    800040f2:	892a                	mv	s2,a0
    800040f4:	8a2e                	mv	s4,a1
    800040f6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040f8:	4601                	li	a2,0
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	dd8080e7          	jalr	-552(ra) # 80003ed2 <dirlookup>
    80004102:	e93d                	bnez	a0,80004178 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004104:	04c92483          	lw	s1,76(s2)
    80004108:	c49d                	beqz	s1,80004136 <dirlink+0x54>
    8000410a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000410c:	4741                	li	a4,16
    8000410e:	86a6                	mv	a3,s1
    80004110:	fc040613          	addi	a2,s0,-64
    80004114:	4581                	li	a1,0
    80004116:	854a                	mv	a0,s2
    80004118:	00000097          	auipc	ra,0x0
    8000411c:	b8a080e7          	jalr	-1142(ra) # 80003ca2 <readi>
    80004120:	47c1                	li	a5,16
    80004122:	06f51163          	bne	a0,a5,80004184 <dirlink+0xa2>
    if(de.inum == 0)
    80004126:	fc045783          	lhu	a5,-64(s0)
    8000412a:	c791                	beqz	a5,80004136 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000412c:	24c1                	addiw	s1,s1,16
    8000412e:	04c92783          	lw	a5,76(s2)
    80004132:	fcf4ede3          	bltu	s1,a5,8000410c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004136:	4639                	li	a2,14
    80004138:	85d2                	mv	a1,s4
    8000413a:	fc240513          	addi	a0,s0,-62
    8000413e:	ffffd097          	auipc	ra,0xffffd
    80004142:	ca0080e7          	jalr	-864(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004146:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000414a:	4741                	li	a4,16
    8000414c:	86a6                	mv	a3,s1
    8000414e:	fc040613          	addi	a2,s0,-64
    80004152:	4581                	li	a1,0
    80004154:	854a                	mv	a0,s2
    80004156:	00000097          	auipc	ra,0x0
    8000415a:	c44080e7          	jalr	-956(ra) # 80003d9a <writei>
    8000415e:	1541                	addi	a0,a0,-16
    80004160:	00a03533          	snez	a0,a0
    80004164:	40a00533          	neg	a0,a0
}
    80004168:	70e2                	ld	ra,56(sp)
    8000416a:	7442                	ld	s0,48(sp)
    8000416c:	74a2                	ld	s1,40(sp)
    8000416e:	7902                	ld	s2,32(sp)
    80004170:	69e2                	ld	s3,24(sp)
    80004172:	6a42                	ld	s4,16(sp)
    80004174:	6121                	addi	sp,sp,64
    80004176:	8082                	ret
    iput(ip);
    80004178:	00000097          	auipc	ra,0x0
    8000417c:	a30080e7          	jalr	-1488(ra) # 80003ba8 <iput>
    return -1;
    80004180:	557d                	li	a0,-1
    80004182:	b7dd                	j	80004168 <dirlink+0x86>
      panic("dirlink read");
    80004184:	00004517          	auipc	a0,0x4
    80004188:	52c50513          	addi	a0,a0,1324 # 800086b0 <syscalls+0x1c8>
    8000418c:	ffffc097          	auipc	ra,0xffffc
    80004190:	3b2080e7          	jalr	946(ra) # 8000053e <panic>

0000000080004194 <namei>:

struct inode*
namei(char *path)
{
    80004194:	1101                	addi	sp,sp,-32
    80004196:	ec06                	sd	ra,24(sp)
    80004198:	e822                	sd	s0,16(sp)
    8000419a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000419c:	fe040613          	addi	a2,s0,-32
    800041a0:	4581                	li	a1,0
    800041a2:	00000097          	auipc	ra,0x0
    800041a6:	de0080e7          	jalr	-544(ra) # 80003f82 <namex>
}
    800041aa:	60e2                	ld	ra,24(sp)
    800041ac:	6442                	ld	s0,16(sp)
    800041ae:	6105                	addi	sp,sp,32
    800041b0:	8082                	ret

00000000800041b2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041b2:	1141                	addi	sp,sp,-16
    800041b4:	e406                	sd	ra,8(sp)
    800041b6:	e022                	sd	s0,0(sp)
    800041b8:	0800                	addi	s0,sp,16
    800041ba:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041bc:	4585                	li	a1,1
    800041be:	00000097          	auipc	ra,0x0
    800041c2:	dc4080e7          	jalr	-572(ra) # 80003f82 <namex>
}
    800041c6:	60a2                	ld	ra,8(sp)
    800041c8:	6402                	ld	s0,0(sp)
    800041ca:	0141                	addi	sp,sp,16
    800041cc:	8082                	ret

00000000800041ce <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041ce:	1101                	addi	sp,sp,-32
    800041d0:	ec06                	sd	ra,24(sp)
    800041d2:	e822                	sd	s0,16(sp)
    800041d4:	e426                	sd	s1,8(sp)
    800041d6:	e04a                	sd	s2,0(sp)
    800041d8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041da:	0001e917          	auipc	s2,0x1e
    800041de:	fe690913          	addi	s2,s2,-26 # 800221c0 <log>
    800041e2:	01892583          	lw	a1,24(s2)
    800041e6:	02892503          	lw	a0,40(s2)
    800041ea:	fffff097          	auipc	ra,0xfffff
    800041ee:	fea080e7          	jalr	-22(ra) # 800031d4 <bread>
    800041f2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041f4:	02c92683          	lw	a3,44(s2)
    800041f8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041fa:	02d05763          	blez	a3,80004228 <write_head+0x5a>
    800041fe:	0001e797          	auipc	a5,0x1e
    80004202:	ff278793          	addi	a5,a5,-14 # 800221f0 <log+0x30>
    80004206:	05c50713          	addi	a4,a0,92
    8000420a:	36fd                	addiw	a3,a3,-1
    8000420c:	1682                	slli	a3,a3,0x20
    8000420e:	9281                	srli	a3,a3,0x20
    80004210:	068a                	slli	a3,a3,0x2
    80004212:	0001e617          	auipc	a2,0x1e
    80004216:	fe260613          	addi	a2,a2,-30 # 800221f4 <log+0x34>
    8000421a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000421c:	4390                	lw	a2,0(a5)
    8000421e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004220:	0791                	addi	a5,a5,4
    80004222:	0711                	addi	a4,a4,4
    80004224:	fed79ce3          	bne	a5,a3,8000421c <write_head+0x4e>
  }
  bwrite(buf);
    80004228:	8526                	mv	a0,s1
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	09c080e7          	jalr	156(ra) # 800032c6 <bwrite>
  brelse(buf);
    80004232:	8526                	mv	a0,s1
    80004234:	fffff097          	auipc	ra,0xfffff
    80004238:	0d0080e7          	jalr	208(ra) # 80003304 <brelse>
}
    8000423c:	60e2                	ld	ra,24(sp)
    8000423e:	6442                	ld	s0,16(sp)
    80004240:	64a2                	ld	s1,8(sp)
    80004242:	6902                	ld	s2,0(sp)
    80004244:	6105                	addi	sp,sp,32
    80004246:	8082                	ret

0000000080004248 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004248:	0001e797          	auipc	a5,0x1e
    8000424c:	fa47a783          	lw	a5,-92(a5) # 800221ec <log+0x2c>
    80004250:	0af05d63          	blez	a5,8000430a <install_trans+0xc2>
{
    80004254:	7139                	addi	sp,sp,-64
    80004256:	fc06                	sd	ra,56(sp)
    80004258:	f822                	sd	s0,48(sp)
    8000425a:	f426                	sd	s1,40(sp)
    8000425c:	f04a                	sd	s2,32(sp)
    8000425e:	ec4e                	sd	s3,24(sp)
    80004260:	e852                	sd	s4,16(sp)
    80004262:	e456                	sd	s5,8(sp)
    80004264:	e05a                	sd	s6,0(sp)
    80004266:	0080                	addi	s0,sp,64
    80004268:	8b2a                	mv	s6,a0
    8000426a:	0001ea97          	auipc	s5,0x1e
    8000426e:	f86a8a93          	addi	s5,s5,-122 # 800221f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004272:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004274:	0001e997          	auipc	s3,0x1e
    80004278:	f4c98993          	addi	s3,s3,-180 # 800221c0 <log>
    8000427c:	a00d                	j	8000429e <install_trans+0x56>
    brelse(lbuf);
    8000427e:	854a                	mv	a0,s2
    80004280:	fffff097          	auipc	ra,0xfffff
    80004284:	084080e7          	jalr	132(ra) # 80003304 <brelse>
    brelse(dbuf);
    80004288:	8526                	mv	a0,s1
    8000428a:	fffff097          	auipc	ra,0xfffff
    8000428e:	07a080e7          	jalr	122(ra) # 80003304 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004292:	2a05                	addiw	s4,s4,1
    80004294:	0a91                	addi	s5,s5,4
    80004296:	02c9a783          	lw	a5,44(s3)
    8000429a:	04fa5e63          	bge	s4,a5,800042f6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000429e:	0189a583          	lw	a1,24(s3)
    800042a2:	014585bb          	addw	a1,a1,s4
    800042a6:	2585                	addiw	a1,a1,1
    800042a8:	0289a503          	lw	a0,40(s3)
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	f28080e7          	jalr	-216(ra) # 800031d4 <bread>
    800042b4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042b6:	000aa583          	lw	a1,0(s5)
    800042ba:	0289a503          	lw	a0,40(s3)
    800042be:	fffff097          	auipc	ra,0xfffff
    800042c2:	f16080e7          	jalr	-234(ra) # 800031d4 <bread>
    800042c6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042c8:	40000613          	li	a2,1024
    800042cc:	05890593          	addi	a1,s2,88
    800042d0:	05850513          	addi	a0,a0,88
    800042d4:	ffffd097          	auipc	ra,0xffffd
    800042d8:	a5a080e7          	jalr	-1446(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800042dc:	8526                	mv	a0,s1
    800042de:	fffff097          	auipc	ra,0xfffff
    800042e2:	fe8080e7          	jalr	-24(ra) # 800032c6 <bwrite>
    if(recovering == 0)
    800042e6:	f80b1ce3          	bnez	s6,8000427e <install_trans+0x36>
      bunpin(dbuf);
    800042ea:	8526                	mv	a0,s1
    800042ec:	fffff097          	auipc	ra,0xfffff
    800042f0:	0f2080e7          	jalr	242(ra) # 800033de <bunpin>
    800042f4:	b769                	j	8000427e <install_trans+0x36>
}
    800042f6:	70e2                	ld	ra,56(sp)
    800042f8:	7442                	ld	s0,48(sp)
    800042fa:	74a2                	ld	s1,40(sp)
    800042fc:	7902                	ld	s2,32(sp)
    800042fe:	69e2                	ld	s3,24(sp)
    80004300:	6a42                	ld	s4,16(sp)
    80004302:	6aa2                	ld	s5,8(sp)
    80004304:	6b02                	ld	s6,0(sp)
    80004306:	6121                	addi	sp,sp,64
    80004308:	8082                	ret
    8000430a:	8082                	ret

000000008000430c <initlog>:
{
    8000430c:	7179                	addi	sp,sp,-48
    8000430e:	f406                	sd	ra,40(sp)
    80004310:	f022                	sd	s0,32(sp)
    80004312:	ec26                	sd	s1,24(sp)
    80004314:	e84a                	sd	s2,16(sp)
    80004316:	e44e                	sd	s3,8(sp)
    80004318:	1800                	addi	s0,sp,48
    8000431a:	892a                	mv	s2,a0
    8000431c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000431e:	0001e497          	auipc	s1,0x1e
    80004322:	ea248493          	addi	s1,s1,-350 # 800221c0 <log>
    80004326:	00004597          	auipc	a1,0x4
    8000432a:	39a58593          	addi	a1,a1,922 # 800086c0 <syscalls+0x1d8>
    8000432e:	8526                	mv	a0,s1
    80004330:	ffffd097          	auipc	ra,0xffffd
    80004334:	816080e7          	jalr	-2026(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004338:	0149a583          	lw	a1,20(s3)
    8000433c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000433e:	0109a783          	lw	a5,16(s3)
    80004342:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004344:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004348:	854a                	mv	a0,s2
    8000434a:	fffff097          	auipc	ra,0xfffff
    8000434e:	e8a080e7          	jalr	-374(ra) # 800031d4 <bread>
  log.lh.n = lh->n;
    80004352:	4d34                	lw	a3,88(a0)
    80004354:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004356:	02d05563          	blez	a3,80004380 <initlog+0x74>
    8000435a:	05c50793          	addi	a5,a0,92
    8000435e:	0001e717          	auipc	a4,0x1e
    80004362:	e9270713          	addi	a4,a4,-366 # 800221f0 <log+0x30>
    80004366:	36fd                	addiw	a3,a3,-1
    80004368:	1682                	slli	a3,a3,0x20
    8000436a:	9281                	srli	a3,a3,0x20
    8000436c:	068a                	slli	a3,a3,0x2
    8000436e:	06050613          	addi	a2,a0,96
    80004372:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004374:	4390                	lw	a2,0(a5)
    80004376:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004378:	0791                	addi	a5,a5,4
    8000437a:	0711                	addi	a4,a4,4
    8000437c:	fed79ce3          	bne	a5,a3,80004374 <initlog+0x68>
  brelse(buf);
    80004380:	fffff097          	auipc	ra,0xfffff
    80004384:	f84080e7          	jalr	-124(ra) # 80003304 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004388:	4505                	li	a0,1
    8000438a:	00000097          	auipc	ra,0x0
    8000438e:	ebe080e7          	jalr	-322(ra) # 80004248 <install_trans>
  log.lh.n = 0;
    80004392:	0001e797          	auipc	a5,0x1e
    80004396:	e407ad23          	sw	zero,-422(a5) # 800221ec <log+0x2c>
  write_head(); // clear the log
    8000439a:	00000097          	auipc	ra,0x0
    8000439e:	e34080e7          	jalr	-460(ra) # 800041ce <write_head>
}
    800043a2:	70a2                	ld	ra,40(sp)
    800043a4:	7402                	ld	s0,32(sp)
    800043a6:	64e2                	ld	s1,24(sp)
    800043a8:	6942                	ld	s2,16(sp)
    800043aa:	69a2                	ld	s3,8(sp)
    800043ac:	6145                	addi	sp,sp,48
    800043ae:	8082                	ret

00000000800043b0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043b0:	1101                	addi	sp,sp,-32
    800043b2:	ec06                	sd	ra,24(sp)
    800043b4:	e822                	sd	s0,16(sp)
    800043b6:	e426                	sd	s1,8(sp)
    800043b8:	e04a                	sd	s2,0(sp)
    800043ba:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043bc:	0001e517          	auipc	a0,0x1e
    800043c0:	e0450513          	addi	a0,a0,-508 # 800221c0 <log>
    800043c4:	ffffd097          	auipc	ra,0xffffd
    800043c8:	812080e7          	jalr	-2030(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800043cc:	0001e497          	auipc	s1,0x1e
    800043d0:	df448493          	addi	s1,s1,-524 # 800221c0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043d4:	4979                	li	s2,30
    800043d6:	a039                	j	800043e4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800043d8:	85a6                	mv	a1,s1
    800043da:	8526                	mv	a0,s1
    800043dc:	ffffe097          	auipc	ra,0xffffe
    800043e0:	d52080e7          	jalr	-686(ra) # 8000212e <sleep>
    if(log.committing){
    800043e4:	50dc                	lw	a5,36(s1)
    800043e6:	fbed                	bnez	a5,800043d8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043e8:	509c                	lw	a5,32(s1)
    800043ea:	0017871b          	addiw	a4,a5,1
    800043ee:	0007069b          	sext.w	a3,a4
    800043f2:	0027179b          	slliw	a5,a4,0x2
    800043f6:	9fb9                	addw	a5,a5,a4
    800043f8:	0017979b          	slliw	a5,a5,0x1
    800043fc:	54d8                	lw	a4,44(s1)
    800043fe:	9fb9                	addw	a5,a5,a4
    80004400:	00f95963          	bge	s2,a5,80004412 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004404:	85a6                	mv	a1,s1
    80004406:	8526                	mv	a0,s1
    80004408:	ffffe097          	auipc	ra,0xffffe
    8000440c:	d26080e7          	jalr	-730(ra) # 8000212e <sleep>
    80004410:	bfd1                	j	800043e4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004412:	0001e517          	auipc	a0,0x1e
    80004416:	dae50513          	addi	a0,a0,-594 # 800221c0 <log>
    8000441a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000441c:	ffffd097          	auipc	ra,0xffffd
    80004420:	86e080e7          	jalr	-1938(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004424:	60e2                	ld	ra,24(sp)
    80004426:	6442                	ld	s0,16(sp)
    80004428:	64a2                	ld	s1,8(sp)
    8000442a:	6902                	ld	s2,0(sp)
    8000442c:	6105                	addi	sp,sp,32
    8000442e:	8082                	ret

0000000080004430 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004430:	7139                	addi	sp,sp,-64
    80004432:	fc06                	sd	ra,56(sp)
    80004434:	f822                	sd	s0,48(sp)
    80004436:	f426                	sd	s1,40(sp)
    80004438:	f04a                	sd	s2,32(sp)
    8000443a:	ec4e                	sd	s3,24(sp)
    8000443c:	e852                	sd	s4,16(sp)
    8000443e:	e456                	sd	s5,8(sp)
    80004440:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004442:	0001e497          	auipc	s1,0x1e
    80004446:	d7e48493          	addi	s1,s1,-642 # 800221c0 <log>
    8000444a:	8526                	mv	a0,s1
    8000444c:	ffffc097          	auipc	ra,0xffffc
    80004450:	78a080e7          	jalr	1930(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004454:	509c                	lw	a5,32(s1)
    80004456:	37fd                	addiw	a5,a5,-1
    80004458:	0007891b          	sext.w	s2,a5
    8000445c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000445e:	50dc                	lw	a5,36(s1)
    80004460:	e7b9                	bnez	a5,800044ae <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004462:	04091e63          	bnez	s2,800044be <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004466:	0001e497          	auipc	s1,0x1e
    8000446a:	d5a48493          	addi	s1,s1,-678 # 800221c0 <log>
    8000446e:	4785                	li	a5,1
    80004470:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004472:	8526                	mv	a0,s1
    80004474:	ffffd097          	auipc	ra,0xffffd
    80004478:	816080e7          	jalr	-2026(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000447c:	54dc                	lw	a5,44(s1)
    8000447e:	06f04763          	bgtz	a5,800044ec <end_op+0xbc>
    acquire(&log.lock);
    80004482:	0001e497          	auipc	s1,0x1e
    80004486:	d3e48493          	addi	s1,s1,-706 # 800221c0 <log>
    8000448a:	8526                	mv	a0,s1
    8000448c:	ffffc097          	auipc	ra,0xffffc
    80004490:	74a080e7          	jalr	1866(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004494:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004498:	8526                	mv	a0,s1
    8000449a:	ffffe097          	auipc	ra,0xffffe
    8000449e:	d14080e7          	jalr	-748(ra) # 800021ae <wakeup>
    release(&log.lock);
    800044a2:	8526                	mv	a0,s1
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	7e6080e7          	jalr	2022(ra) # 80000c8a <release>
}
    800044ac:	a03d                	j	800044da <end_op+0xaa>
    panic("log.committing");
    800044ae:	00004517          	auipc	a0,0x4
    800044b2:	21a50513          	addi	a0,a0,538 # 800086c8 <syscalls+0x1e0>
    800044b6:	ffffc097          	auipc	ra,0xffffc
    800044ba:	088080e7          	jalr	136(ra) # 8000053e <panic>
    wakeup(&log);
    800044be:	0001e497          	auipc	s1,0x1e
    800044c2:	d0248493          	addi	s1,s1,-766 # 800221c0 <log>
    800044c6:	8526                	mv	a0,s1
    800044c8:	ffffe097          	auipc	ra,0xffffe
    800044cc:	ce6080e7          	jalr	-794(ra) # 800021ae <wakeup>
  release(&log.lock);
    800044d0:	8526                	mv	a0,s1
    800044d2:	ffffc097          	auipc	ra,0xffffc
    800044d6:	7b8080e7          	jalr	1976(ra) # 80000c8a <release>
}
    800044da:	70e2                	ld	ra,56(sp)
    800044dc:	7442                	ld	s0,48(sp)
    800044de:	74a2                	ld	s1,40(sp)
    800044e0:	7902                	ld	s2,32(sp)
    800044e2:	69e2                	ld	s3,24(sp)
    800044e4:	6a42                	ld	s4,16(sp)
    800044e6:	6aa2                	ld	s5,8(sp)
    800044e8:	6121                	addi	sp,sp,64
    800044ea:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ec:	0001ea97          	auipc	s5,0x1e
    800044f0:	d04a8a93          	addi	s5,s5,-764 # 800221f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044f4:	0001ea17          	auipc	s4,0x1e
    800044f8:	ccca0a13          	addi	s4,s4,-820 # 800221c0 <log>
    800044fc:	018a2583          	lw	a1,24(s4)
    80004500:	012585bb          	addw	a1,a1,s2
    80004504:	2585                	addiw	a1,a1,1
    80004506:	028a2503          	lw	a0,40(s4)
    8000450a:	fffff097          	auipc	ra,0xfffff
    8000450e:	cca080e7          	jalr	-822(ra) # 800031d4 <bread>
    80004512:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004514:	000aa583          	lw	a1,0(s5)
    80004518:	028a2503          	lw	a0,40(s4)
    8000451c:	fffff097          	auipc	ra,0xfffff
    80004520:	cb8080e7          	jalr	-840(ra) # 800031d4 <bread>
    80004524:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004526:	40000613          	li	a2,1024
    8000452a:	05850593          	addi	a1,a0,88
    8000452e:	05848513          	addi	a0,s1,88
    80004532:	ffffc097          	auipc	ra,0xffffc
    80004536:	7fc080e7          	jalr	2044(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000453a:	8526                	mv	a0,s1
    8000453c:	fffff097          	auipc	ra,0xfffff
    80004540:	d8a080e7          	jalr	-630(ra) # 800032c6 <bwrite>
    brelse(from);
    80004544:	854e                	mv	a0,s3
    80004546:	fffff097          	auipc	ra,0xfffff
    8000454a:	dbe080e7          	jalr	-578(ra) # 80003304 <brelse>
    brelse(to);
    8000454e:	8526                	mv	a0,s1
    80004550:	fffff097          	auipc	ra,0xfffff
    80004554:	db4080e7          	jalr	-588(ra) # 80003304 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004558:	2905                	addiw	s2,s2,1
    8000455a:	0a91                	addi	s5,s5,4
    8000455c:	02ca2783          	lw	a5,44(s4)
    80004560:	f8f94ee3          	blt	s2,a5,800044fc <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004564:	00000097          	auipc	ra,0x0
    80004568:	c6a080e7          	jalr	-918(ra) # 800041ce <write_head>
    install_trans(0); // Now install writes to home locations
    8000456c:	4501                	li	a0,0
    8000456e:	00000097          	auipc	ra,0x0
    80004572:	cda080e7          	jalr	-806(ra) # 80004248 <install_trans>
    log.lh.n = 0;
    80004576:	0001e797          	auipc	a5,0x1e
    8000457a:	c607ab23          	sw	zero,-906(a5) # 800221ec <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000457e:	00000097          	auipc	ra,0x0
    80004582:	c50080e7          	jalr	-944(ra) # 800041ce <write_head>
    80004586:	bdf5                	j	80004482 <end_op+0x52>

0000000080004588 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004588:	1101                	addi	sp,sp,-32
    8000458a:	ec06                	sd	ra,24(sp)
    8000458c:	e822                	sd	s0,16(sp)
    8000458e:	e426                	sd	s1,8(sp)
    80004590:	e04a                	sd	s2,0(sp)
    80004592:	1000                	addi	s0,sp,32
    80004594:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004596:	0001e917          	auipc	s2,0x1e
    8000459a:	c2a90913          	addi	s2,s2,-982 # 800221c0 <log>
    8000459e:	854a                	mv	a0,s2
    800045a0:	ffffc097          	auipc	ra,0xffffc
    800045a4:	636080e7          	jalr	1590(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045a8:	02c92603          	lw	a2,44(s2)
    800045ac:	47f5                	li	a5,29
    800045ae:	06c7c563          	blt	a5,a2,80004618 <log_write+0x90>
    800045b2:	0001e797          	auipc	a5,0x1e
    800045b6:	c2a7a783          	lw	a5,-982(a5) # 800221dc <log+0x1c>
    800045ba:	37fd                	addiw	a5,a5,-1
    800045bc:	04f65e63          	bge	a2,a5,80004618 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045c0:	0001e797          	auipc	a5,0x1e
    800045c4:	c207a783          	lw	a5,-992(a5) # 800221e0 <log+0x20>
    800045c8:	06f05063          	blez	a5,80004628 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045cc:	4781                	li	a5,0
    800045ce:	06c05563          	blez	a2,80004638 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045d2:	44cc                	lw	a1,12(s1)
    800045d4:	0001e717          	auipc	a4,0x1e
    800045d8:	c1c70713          	addi	a4,a4,-996 # 800221f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800045dc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045de:	4314                	lw	a3,0(a4)
    800045e0:	04b68c63          	beq	a3,a1,80004638 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800045e4:	2785                	addiw	a5,a5,1
    800045e6:	0711                	addi	a4,a4,4
    800045e8:	fef61be3          	bne	a2,a5,800045de <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045ec:	0621                	addi	a2,a2,8
    800045ee:	060a                	slli	a2,a2,0x2
    800045f0:	0001e797          	auipc	a5,0x1e
    800045f4:	bd078793          	addi	a5,a5,-1072 # 800221c0 <log>
    800045f8:	963e                	add	a2,a2,a5
    800045fa:	44dc                	lw	a5,12(s1)
    800045fc:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045fe:	8526                	mv	a0,s1
    80004600:	fffff097          	auipc	ra,0xfffff
    80004604:	da2080e7          	jalr	-606(ra) # 800033a2 <bpin>
    log.lh.n++;
    80004608:	0001e717          	auipc	a4,0x1e
    8000460c:	bb870713          	addi	a4,a4,-1096 # 800221c0 <log>
    80004610:	575c                	lw	a5,44(a4)
    80004612:	2785                	addiw	a5,a5,1
    80004614:	d75c                	sw	a5,44(a4)
    80004616:	a835                	j	80004652 <log_write+0xca>
    panic("too big a transaction");
    80004618:	00004517          	auipc	a0,0x4
    8000461c:	0c050513          	addi	a0,a0,192 # 800086d8 <syscalls+0x1f0>
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	f1e080e7          	jalr	-226(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004628:	00004517          	auipc	a0,0x4
    8000462c:	0c850513          	addi	a0,a0,200 # 800086f0 <syscalls+0x208>
    80004630:	ffffc097          	auipc	ra,0xffffc
    80004634:	f0e080e7          	jalr	-242(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004638:	00878713          	addi	a4,a5,8
    8000463c:	00271693          	slli	a3,a4,0x2
    80004640:	0001e717          	auipc	a4,0x1e
    80004644:	b8070713          	addi	a4,a4,-1152 # 800221c0 <log>
    80004648:	9736                	add	a4,a4,a3
    8000464a:	44d4                	lw	a3,12(s1)
    8000464c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000464e:	faf608e3          	beq	a2,a5,800045fe <log_write+0x76>
  }
  release(&log.lock);
    80004652:	0001e517          	auipc	a0,0x1e
    80004656:	b6e50513          	addi	a0,a0,-1170 # 800221c0 <log>
    8000465a:	ffffc097          	auipc	ra,0xffffc
    8000465e:	630080e7          	jalr	1584(ra) # 80000c8a <release>
}
    80004662:	60e2                	ld	ra,24(sp)
    80004664:	6442                	ld	s0,16(sp)
    80004666:	64a2                	ld	s1,8(sp)
    80004668:	6902                	ld	s2,0(sp)
    8000466a:	6105                	addi	sp,sp,32
    8000466c:	8082                	ret

000000008000466e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000466e:	1101                	addi	sp,sp,-32
    80004670:	ec06                	sd	ra,24(sp)
    80004672:	e822                	sd	s0,16(sp)
    80004674:	e426                	sd	s1,8(sp)
    80004676:	e04a                	sd	s2,0(sp)
    80004678:	1000                	addi	s0,sp,32
    8000467a:	84aa                	mv	s1,a0
    8000467c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000467e:	00004597          	auipc	a1,0x4
    80004682:	09258593          	addi	a1,a1,146 # 80008710 <syscalls+0x228>
    80004686:	0521                	addi	a0,a0,8
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	4be080e7          	jalr	1214(ra) # 80000b46 <initlock>
  lk->name = name;
    80004690:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004694:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004698:	0204a423          	sw	zero,40(s1)
}
    8000469c:	60e2                	ld	ra,24(sp)
    8000469e:	6442                	ld	s0,16(sp)
    800046a0:	64a2                	ld	s1,8(sp)
    800046a2:	6902                	ld	s2,0(sp)
    800046a4:	6105                	addi	sp,sp,32
    800046a6:	8082                	ret

00000000800046a8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046a8:	1101                	addi	sp,sp,-32
    800046aa:	ec06                	sd	ra,24(sp)
    800046ac:	e822                	sd	s0,16(sp)
    800046ae:	e426                	sd	s1,8(sp)
    800046b0:	e04a                	sd	s2,0(sp)
    800046b2:	1000                	addi	s0,sp,32
    800046b4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046b6:	00850913          	addi	s2,a0,8
    800046ba:	854a                	mv	a0,s2
    800046bc:	ffffc097          	auipc	ra,0xffffc
    800046c0:	51a080e7          	jalr	1306(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800046c4:	409c                	lw	a5,0(s1)
    800046c6:	cb89                	beqz	a5,800046d8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046c8:	85ca                	mv	a1,s2
    800046ca:	8526                	mv	a0,s1
    800046cc:	ffffe097          	auipc	ra,0xffffe
    800046d0:	a62080e7          	jalr	-1438(ra) # 8000212e <sleep>
  while (lk->locked) {
    800046d4:	409c                	lw	a5,0(s1)
    800046d6:	fbed                	bnez	a5,800046c8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046d8:	4785                	li	a5,1
    800046da:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046dc:	ffffd097          	auipc	ra,0xffffd
    800046e0:	2a4080e7          	jalr	676(ra) # 80001980 <myproc>
    800046e4:	515c                	lw	a5,36(a0)
    800046e6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046e8:	854a                	mv	a0,s2
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	5a0080e7          	jalr	1440(ra) # 80000c8a <release>
}
    800046f2:	60e2                	ld	ra,24(sp)
    800046f4:	6442                	ld	s0,16(sp)
    800046f6:	64a2                	ld	s1,8(sp)
    800046f8:	6902                	ld	s2,0(sp)
    800046fa:	6105                	addi	sp,sp,32
    800046fc:	8082                	ret

00000000800046fe <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046fe:	1101                	addi	sp,sp,-32
    80004700:	ec06                	sd	ra,24(sp)
    80004702:	e822                	sd	s0,16(sp)
    80004704:	e426                	sd	s1,8(sp)
    80004706:	e04a                	sd	s2,0(sp)
    80004708:	1000                	addi	s0,sp,32
    8000470a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000470c:	00850913          	addi	s2,a0,8
    80004710:	854a                	mv	a0,s2
    80004712:	ffffc097          	auipc	ra,0xffffc
    80004716:	4c4080e7          	jalr	1220(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000471a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000471e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004722:	8526                	mv	a0,s1
    80004724:	ffffe097          	auipc	ra,0xffffe
    80004728:	a8a080e7          	jalr	-1398(ra) # 800021ae <wakeup>
  release(&lk->lk);
    8000472c:	854a                	mv	a0,s2
    8000472e:	ffffc097          	auipc	ra,0xffffc
    80004732:	55c080e7          	jalr	1372(ra) # 80000c8a <release>
}
    80004736:	60e2                	ld	ra,24(sp)
    80004738:	6442                	ld	s0,16(sp)
    8000473a:	64a2                	ld	s1,8(sp)
    8000473c:	6902                	ld	s2,0(sp)
    8000473e:	6105                	addi	sp,sp,32
    80004740:	8082                	ret

0000000080004742 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004742:	7179                	addi	sp,sp,-48
    80004744:	f406                	sd	ra,40(sp)
    80004746:	f022                	sd	s0,32(sp)
    80004748:	ec26                	sd	s1,24(sp)
    8000474a:	e84a                	sd	s2,16(sp)
    8000474c:	e44e                	sd	s3,8(sp)
    8000474e:	1800                	addi	s0,sp,48
    80004750:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004752:	00850913          	addi	s2,a0,8
    80004756:	854a                	mv	a0,s2
    80004758:	ffffc097          	auipc	ra,0xffffc
    8000475c:	47e080e7          	jalr	1150(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004760:	409c                	lw	a5,0(s1)
    80004762:	ef99                	bnez	a5,80004780 <holdingsleep+0x3e>
    80004764:	4481                	li	s1,0
  release(&lk->lk);
    80004766:	854a                	mv	a0,s2
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	522080e7          	jalr	1314(ra) # 80000c8a <release>
  return r;
}
    80004770:	8526                	mv	a0,s1
    80004772:	70a2                	ld	ra,40(sp)
    80004774:	7402                	ld	s0,32(sp)
    80004776:	64e2                	ld	s1,24(sp)
    80004778:	6942                	ld	s2,16(sp)
    8000477a:	69a2                	ld	s3,8(sp)
    8000477c:	6145                	addi	sp,sp,48
    8000477e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004780:	0284a983          	lw	s3,40(s1)
    80004784:	ffffd097          	auipc	ra,0xffffd
    80004788:	1fc080e7          	jalr	508(ra) # 80001980 <myproc>
    8000478c:	5144                	lw	s1,36(a0)
    8000478e:	413484b3          	sub	s1,s1,s3
    80004792:	0014b493          	seqz	s1,s1
    80004796:	bfc1                	j	80004766 <holdingsleep+0x24>

0000000080004798 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004798:	1141                	addi	sp,sp,-16
    8000479a:	e406                	sd	ra,8(sp)
    8000479c:	e022                	sd	s0,0(sp)
    8000479e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047a0:	00004597          	auipc	a1,0x4
    800047a4:	f8058593          	addi	a1,a1,-128 # 80008720 <syscalls+0x238>
    800047a8:	0001e517          	auipc	a0,0x1e
    800047ac:	b6050513          	addi	a0,a0,-1184 # 80022308 <ftable>
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	396080e7          	jalr	918(ra) # 80000b46 <initlock>
}
    800047b8:	60a2                	ld	ra,8(sp)
    800047ba:	6402                	ld	s0,0(sp)
    800047bc:	0141                	addi	sp,sp,16
    800047be:	8082                	ret

00000000800047c0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047c0:	1101                	addi	sp,sp,-32
    800047c2:	ec06                	sd	ra,24(sp)
    800047c4:	e822                	sd	s0,16(sp)
    800047c6:	e426                	sd	s1,8(sp)
    800047c8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047ca:	0001e517          	auipc	a0,0x1e
    800047ce:	b3e50513          	addi	a0,a0,-1218 # 80022308 <ftable>
    800047d2:	ffffc097          	auipc	ra,0xffffc
    800047d6:	404080e7          	jalr	1028(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047da:	0001e497          	auipc	s1,0x1e
    800047de:	b4648493          	addi	s1,s1,-1210 # 80022320 <ftable+0x18>
    800047e2:	0001f717          	auipc	a4,0x1f
    800047e6:	ade70713          	addi	a4,a4,-1314 # 800232c0 <disk>
    if(f->ref == 0){
    800047ea:	40dc                	lw	a5,4(s1)
    800047ec:	cf99                	beqz	a5,8000480a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047ee:	02848493          	addi	s1,s1,40
    800047f2:	fee49ce3          	bne	s1,a4,800047ea <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047f6:	0001e517          	auipc	a0,0x1e
    800047fa:	b1250513          	addi	a0,a0,-1262 # 80022308 <ftable>
    800047fe:	ffffc097          	auipc	ra,0xffffc
    80004802:	48c080e7          	jalr	1164(ra) # 80000c8a <release>
  return 0;
    80004806:	4481                	li	s1,0
    80004808:	a819                	j	8000481e <filealloc+0x5e>
      f->ref = 1;
    8000480a:	4785                	li	a5,1
    8000480c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000480e:	0001e517          	auipc	a0,0x1e
    80004812:	afa50513          	addi	a0,a0,-1286 # 80022308 <ftable>
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	474080e7          	jalr	1140(ra) # 80000c8a <release>
}
    8000481e:	8526                	mv	a0,s1
    80004820:	60e2                	ld	ra,24(sp)
    80004822:	6442                	ld	s0,16(sp)
    80004824:	64a2                	ld	s1,8(sp)
    80004826:	6105                	addi	sp,sp,32
    80004828:	8082                	ret

000000008000482a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000482a:	1101                	addi	sp,sp,-32
    8000482c:	ec06                	sd	ra,24(sp)
    8000482e:	e822                	sd	s0,16(sp)
    80004830:	e426                	sd	s1,8(sp)
    80004832:	1000                	addi	s0,sp,32
    80004834:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004836:	0001e517          	auipc	a0,0x1e
    8000483a:	ad250513          	addi	a0,a0,-1326 # 80022308 <ftable>
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	398080e7          	jalr	920(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004846:	40dc                	lw	a5,4(s1)
    80004848:	02f05263          	blez	a5,8000486c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000484c:	2785                	addiw	a5,a5,1
    8000484e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004850:	0001e517          	auipc	a0,0x1e
    80004854:	ab850513          	addi	a0,a0,-1352 # 80022308 <ftable>
    80004858:	ffffc097          	auipc	ra,0xffffc
    8000485c:	432080e7          	jalr	1074(ra) # 80000c8a <release>
  return f;
}
    80004860:	8526                	mv	a0,s1
    80004862:	60e2                	ld	ra,24(sp)
    80004864:	6442                	ld	s0,16(sp)
    80004866:	64a2                	ld	s1,8(sp)
    80004868:	6105                	addi	sp,sp,32
    8000486a:	8082                	ret
    panic("filedup");
    8000486c:	00004517          	auipc	a0,0x4
    80004870:	ebc50513          	addi	a0,a0,-324 # 80008728 <syscalls+0x240>
    80004874:	ffffc097          	auipc	ra,0xffffc
    80004878:	cca080e7          	jalr	-822(ra) # 8000053e <panic>

000000008000487c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000487c:	7139                	addi	sp,sp,-64
    8000487e:	fc06                	sd	ra,56(sp)
    80004880:	f822                	sd	s0,48(sp)
    80004882:	f426                	sd	s1,40(sp)
    80004884:	f04a                	sd	s2,32(sp)
    80004886:	ec4e                	sd	s3,24(sp)
    80004888:	e852                	sd	s4,16(sp)
    8000488a:	e456                	sd	s5,8(sp)
    8000488c:	0080                	addi	s0,sp,64
    8000488e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004890:	0001e517          	auipc	a0,0x1e
    80004894:	a7850513          	addi	a0,a0,-1416 # 80022308 <ftable>
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	33e080e7          	jalr	830(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800048a0:	40dc                	lw	a5,4(s1)
    800048a2:	06f05163          	blez	a5,80004904 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800048a6:	37fd                	addiw	a5,a5,-1
    800048a8:	0007871b          	sext.w	a4,a5
    800048ac:	c0dc                	sw	a5,4(s1)
    800048ae:	06e04363          	bgtz	a4,80004914 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048b2:	0004a903          	lw	s2,0(s1)
    800048b6:	0094ca83          	lbu	s5,9(s1)
    800048ba:	0104ba03          	ld	s4,16(s1)
    800048be:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048c2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048c6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048ca:	0001e517          	auipc	a0,0x1e
    800048ce:	a3e50513          	addi	a0,a0,-1474 # 80022308 <ftable>
    800048d2:	ffffc097          	auipc	ra,0xffffc
    800048d6:	3b8080e7          	jalr	952(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800048da:	4785                	li	a5,1
    800048dc:	04f90d63          	beq	s2,a5,80004936 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048e0:	3979                	addiw	s2,s2,-2
    800048e2:	4785                	li	a5,1
    800048e4:	0527e063          	bltu	a5,s2,80004924 <fileclose+0xa8>
    begin_op();
    800048e8:	00000097          	auipc	ra,0x0
    800048ec:	ac8080e7          	jalr	-1336(ra) # 800043b0 <begin_op>
    iput(ff.ip);
    800048f0:	854e                	mv	a0,s3
    800048f2:	fffff097          	auipc	ra,0xfffff
    800048f6:	2b6080e7          	jalr	694(ra) # 80003ba8 <iput>
    end_op();
    800048fa:	00000097          	auipc	ra,0x0
    800048fe:	b36080e7          	jalr	-1226(ra) # 80004430 <end_op>
    80004902:	a00d                	j	80004924 <fileclose+0xa8>
    panic("fileclose");
    80004904:	00004517          	auipc	a0,0x4
    80004908:	e2c50513          	addi	a0,a0,-468 # 80008730 <syscalls+0x248>
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	c32080e7          	jalr	-974(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004914:	0001e517          	auipc	a0,0x1e
    80004918:	9f450513          	addi	a0,a0,-1548 # 80022308 <ftable>
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	36e080e7          	jalr	878(ra) # 80000c8a <release>
  }
}
    80004924:	70e2                	ld	ra,56(sp)
    80004926:	7442                	ld	s0,48(sp)
    80004928:	74a2                	ld	s1,40(sp)
    8000492a:	7902                	ld	s2,32(sp)
    8000492c:	69e2                	ld	s3,24(sp)
    8000492e:	6a42                	ld	s4,16(sp)
    80004930:	6aa2                	ld	s5,8(sp)
    80004932:	6121                	addi	sp,sp,64
    80004934:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004936:	85d6                	mv	a1,s5
    80004938:	8552                	mv	a0,s4
    8000493a:	00000097          	auipc	ra,0x0
    8000493e:	34c080e7          	jalr	844(ra) # 80004c86 <pipeclose>
    80004942:	b7cd                	j	80004924 <fileclose+0xa8>

0000000080004944 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004944:	715d                	addi	sp,sp,-80
    80004946:	e486                	sd	ra,72(sp)
    80004948:	e0a2                	sd	s0,64(sp)
    8000494a:	fc26                	sd	s1,56(sp)
    8000494c:	f84a                	sd	s2,48(sp)
    8000494e:	f44e                	sd	s3,40(sp)
    80004950:	0880                	addi	s0,sp,80
    80004952:	84aa                	mv	s1,a0
    80004954:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004956:	ffffd097          	auipc	ra,0xffffd
    8000495a:	02a080e7          	jalr	42(ra) # 80001980 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000495e:	409c                	lw	a5,0(s1)
    80004960:	37f9                	addiw	a5,a5,-2
    80004962:	4705                	li	a4,1
    80004964:	04f76763          	bltu	a4,a5,800049b2 <filestat+0x6e>
    80004968:	892a                	mv	s2,a0
    ilock(f->ip);
    8000496a:	6c88                	ld	a0,24(s1)
    8000496c:	fffff097          	auipc	ra,0xfffff
    80004970:	082080e7          	jalr	130(ra) # 800039ee <ilock>
    stati(f->ip, &st);
    80004974:	fb840593          	addi	a1,s0,-72
    80004978:	6c88                	ld	a0,24(s1)
    8000497a:	fffff097          	auipc	ra,0xfffff
    8000497e:	2fe080e7          	jalr	766(ra) # 80003c78 <stati>
    iunlock(f->ip);
    80004982:	6c88                	ld	a0,24(s1)
    80004984:	fffff097          	auipc	ra,0xfffff
    80004988:	12c080e7          	jalr	300(ra) # 80003ab0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000498c:	46e1                	li	a3,24
    8000498e:	fb840613          	addi	a2,s0,-72
    80004992:	85ce                	mv	a1,s3
    80004994:	10093503          	ld	a0,256(s2)
    80004998:	ffffd097          	auipc	ra,0xffffd
    8000499c:	cd0080e7          	jalr	-816(ra) # 80001668 <copyout>
    800049a0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800049a4:	60a6                	ld	ra,72(sp)
    800049a6:	6406                	ld	s0,64(sp)
    800049a8:	74e2                	ld	s1,56(sp)
    800049aa:	7942                	ld	s2,48(sp)
    800049ac:	79a2                	ld	s3,40(sp)
    800049ae:	6161                	addi	sp,sp,80
    800049b0:	8082                	ret
  return -1;
    800049b2:	557d                	li	a0,-1
    800049b4:	bfc5                	j	800049a4 <filestat+0x60>

00000000800049b6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800049b6:	7179                	addi	sp,sp,-48
    800049b8:	f406                	sd	ra,40(sp)
    800049ba:	f022                	sd	s0,32(sp)
    800049bc:	ec26                	sd	s1,24(sp)
    800049be:	e84a                	sd	s2,16(sp)
    800049c0:	e44e                	sd	s3,8(sp)
    800049c2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049c4:	00854783          	lbu	a5,8(a0)
    800049c8:	c3d5                	beqz	a5,80004a6c <fileread+0xb6>
    800049ca:	84aa                	mv	s1,a0
    800049cc:	89ae                	mv	s3,a1
    800049ce:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800049d0:	411c                	lw	a5,0(a0)
    800049d2:	4705                	li	a4,1
    800049d4:	04e78963          	beq	a5,a4,80004a26 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049d8:	470d                	li	a4,3
    800049da:	04e78d63          	beq	a5,a4,80004a34 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800049de:	4709                	li	a4,2
    800049e0:	06e79e63          	bne	a5,a4,80004a5c <fileread+0xa6>
    ilock(f->ip);
    800049e4:	6d08                	ld	a0,24(a0)
    800049e6:	fffff097          	auipc	ra,0xfffff
    800049ea:	008080e7          	jalr	8(ra) # 800039ee <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049ee:	874a                	mv	a4,s2
    800049f0:	5094                	lw	a3,32(s1)
    800049f2:	864e                	mv	a2,s3
    800049f4:	4585                	li	a1,1
    800049f6:	6c88                	ld	a0,24(s1)
    800049f8:	fffff097          	auipc	ra,0xfffff
    800049fc:	2aa080e7          	jalr	682(ra) # 80003ca2 <readi>
    80004a00:	892a                	mv	s2,a0
    80004a02:	00a05563          	blez	a0,80004a0c <fileread+0x56>
      f->off += r;
    80004a06:	509c                	lw	a5,32(s1)
    80004a08:	9fa9                	addw	a5,a5,a0
    80004a0a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a0c:	6c88                	ld	a0,24(s1)
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	0a2080e7          	jalr	162(ra) # 80003ab0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a16:	854a                	mv	a0,s2
    80004a18:	70a2                	ld	ra,40(sp)
    80004a1a:	7402                	ld	s0,32(sp)
    80004a1c:	64e2                	ld	s1,24(sp)
    80004a1e:	6942                	ld	s2,16(sp)
    80004a20:	69a2                	ld	s3,8(sp)
    80004a22:	6145                	addi	sp,sp,48
    80004a24:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a26:	6908                	ld	a0,16(a0)
    80004a28:	00000097          	auipc	ra,0x0
    80004a2c:	3c6080e7          	jalr	966(ra) # 80004dee <piperead>
    80004a30:	892a                	mv	s2,a0
    80004a32:	b7d5                	j	80004a16 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a34:	02451783          	lh	a5,36(a0)
    80004a38:	03079693          	slli	a3,a5,0x30
    80004a3c:	92c1                	srli	a3,a3,0x30
    80004a3e:	4725                	li	a4,9
    80004a40:	02d76863          	bltu	a4,a3,80004a70 <fileread+0xba>
    80004a44:	0792                	slli	a5,a5,0x4
    80004a46:	0001e717          	auipc	a4,0x1e
    80004a4a:	82270713          	addi	a4,a4,-2014 # 80022268 <devsw>
    80004a4e:	97ba                	add	a5,a5,a4
    80004a50:	639c                	ld	a5,0(a5)
    80004a52:	c38d                	beqz	a5,80004a74 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a54:	4505                	li	a0,1
    80004a56:	9782                	jalr	a5
    80004a58:	892a                	mv	s2,a0
    80004a5a:	bf75                	j	80004a16 <fileread+0x60>
    panic("fileread");
    80004a5c:	00004517          	auipc	a0,0x4
    80004a60:	ce450513          	addi	a0,a0,-796 # 80008740 <syscalls+0x258>
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	ada080e7          	jalr	-1318(ra) # 8000053e <panic>
    return -1;
    80004a6c:	597d                	li	s2,-1
    80004a6e:	b765                	j	80004a16 <fileread+0x60>
      return -1;
    80004a70:	597d                	li	s2,-1
    80004a72:	b755                	j	80004a16 <fileread+0x60>
    80004a74:	597d                	li	s2,-1
    80004a76:	b745                	j	80004a16 <fileread+0x60>

0000000080004a78 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a78:	715d                	addi	sp,sp,-80
    80004a7a:	e486                	sd	ra,72(sp)
    80004a7c:	e0a2                	sd	s0,64(sp)
    80004a7e:	fc26                	sd	s1,56(sp)
    80004a80:	f84a                	sd	s2,48(sp)
    80004a82:	f44e                	sd	s3,40(sp)
    80004a84:	f052                	sd	s4,32(sp)
    80004a86:	ec56                	sd	s5,24(sp)
    80004a88:	e85a                	sd	s6,16(sp)
    80004a8a:	e45e                	sd	s7,8(sp)
    80004a8c:	e062                	sd	s8,0(sp)
    80004a8e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a90:	00954783          	lbu	a5,9(a0)
    80004a94:	10078663          	beqz	a5,80004ba0 <filewrite+0x128>
    80004a98:	892a                	mv	s2,a0
    80004a9a:	8aae                	mv	s5,a1
    80004a9c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a9e:	411c                	lw	a5,0(a0)
    80004aa0:	4705                	li	a4,1
    80004aa2:	02e78263          	beq	a5,a4,80004ac6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004aa6:	470d                	li	a4,3
    80004aa8:	02e78663          	beq	a5,a4,80004ad4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004aac:	4709                	li	a4,2
    80004aae:	0ee79163          	bne	a5,a4,80004b90 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004ab2:	0ac05d63          	blez	a2,80004b6c <filewrite+0xf4>
    int i = 0;
    80004ab6:	4981                	li	s3,0
    80004ab8:	6b05                	lui	s6,0x1
    80004aba:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004abe:	6b85                	lui	s7,0x1
    80004ac0:	c00b8b9b          	addiw	s7,s7,-1024
    80004ac4:	a861                	j	80004b5c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004ac6:	6908                	ld	a0,16(a0)
    80004ac8:	00000097          	auipc	ra,0x0
    80004acc:	22e080e7          	jalr	558(ra) # 80004cf6 <pipewrite>
    80004ad0:	8a2a                	mv	s4,a0
    80004ad2:	a045                	j	80004b72 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ad4:	02451783          	lh	a5,36(a0)
    80004ad8:	03079693          	slli	a3,a5,0x30
    80004adc:	92c1                	srli	a3,a3,0x30
    80004ade:	4725                	li	a4,9
    80004ae0:	0cd76263          	bltu	a4,a3,80004ba4 <filewrite+0x12c>
    80004ae4:	0792                	slli	a5,a5,0x4
    80004ae6:	0001d717          	auipc	a4,0x1d
    80004aea:	78270713          	addi	a4,a4,1922 # 80022268 <devsw>
    80004aee:	97ba                	add	a5,a5,a4
    80004af0:	679c                	ld	a5,8(a5)
    80004af2:	cbdd                	beqz	a5,80004ba8 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004af4:	4505                	li	a0,1
    80004af6:	9782                	jalr	a5
    80004af8:	8a2a                	mv	s4,a0
    80004afa:	a8a5                	j	80004b72 <filewrite+0xfa>
    80004afc:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004b00:	00000097          	auipc	ra,0x0
    80004b04:	8b0080e7          	jalr	-1872(ra) # 800043b0 <begin_op>
      ilock(f->ip);
    80004b08:	01893503          	ld	a0,24(s2)
    80004b0c:	fffff097          	auipc	ra,0xfffff
    80004b10:	ee2080e7          	jalr	-286(ra) # 800039ee <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b14:	8762                	mv	a4,s8
    80004b16:	02092683          	lw	a3,32(s2)
    80004b1a:	01598633          	add	a2,s3,s5
    80004b1e:	4585                	li	a1,1
    80004b20:	01893503          	ld	a0,24(s2)
    80004b24:	fffff097          	auipc	ra,0xfffff
    80004b28:	276080e7          	jalr	630(ra) # 80003d9a <writei>
    80004b2c:	84aa                	mv	s1,a0
    80004b2e:	00a05763          	blez	a0,80004b3c <filewrite+0xc4>
        f->off += r;
    80004b32:	02092783          	lw	a5,32(s2)
    80004b36:	9fa9                	addw	a5,a5,a0
    80004b38:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b3c:	01893503          	ld	a0,24(s2)
    80004b40:	fffff097          	auipc	ra,0xfffff
    80004b44:	f70080e7          	jalr	-144(ra) # 80003ab0 <iunlock>
      end_op();
    80004b48:	00000097          	auipc	ra,0x0
    80004b4c:	8e8080e7          	jalr	-1816(ra) # 80004430 <end_op>

      if(r != n1){
    80004b50:	009c1f63          	bne	s8,s1,80004b6e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004b54:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b58:	0149db63          	bge	s3,s4,80004b6e <filewrite+0xf6>
      int n1 = n - i;
    80004b5c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b60:	84be                	mv	s1,a5
    80004b62:	2781                	sext.w	a5,a5
    80004b64:	f8fb5ce3          	bge	s6,a5,80004afc <filewrite+0x84>
    80004b68:	84de                	mv	s1,s7
    80004b6a:	bf49                	j	80004afc <filewrite+0x84>
    int i = 0;
    80004b6c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b6e:	013a1f63          	bne	s4,s3,80004b8c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b72:	8552                	mv	a0,s4
    80004b74:	60a6                	ld	ra,72(sp)
    80004b76:	6406                	ld	s0,64(sp)
    80004b78:	74e2                	ld	s1,56(sp)
    80004b7a:	7942                	ld	s2,48(sp)
    80004b7c:	79a2                	ld	s3,40(sp)
    80004b7e:	7a02                	ld	s4,32(sp)
    80004b80:	6ae2                	ld	s5,24(sp)
    80004b82:	6b42                	ld	s6,16(sp)
    80004b84:	6ba2                	ld	s7,8(sp)
    80004b86:	6c02                	ld	s8,0(sp)
    80004b88:	6161                	addi	sp,sp,80
    80004b8a:	8082                	ret
    ret = (i == n ? n : -1);
    80004b8c:	5a7d                	li	s4,-1
    80004b8e:	b7d5                	j	80004b72 <filewrite+0xfa>
    panic("filewrite");
    80004b90:	00004517          	auipc	a0,0x4
    80004b94:	bc050513          	addi	a0,a0,-1088 # 80008750 <syscalls+0x268>
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	9a6080e7          	jalr	-1626(ra) # 8000053e <panic>
    return -1;
    80004ba0:	5a7d                	li	s4,-1
    80004ba2:	bfc1                	j	80004b72 <filewrite+0xfa>
      return -1;
    80004ba4:	5a7d                	li	s4,-1
    80004ba6:	b7f1                	j	80004b72 <filewrite+0xfa>
    80004ba8:	5a7d                	li	s4,-1
    80004baa:	b7e1                	j	80004b72 <filewrite+0xfa>

0000000080004bac <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004bac:	7179                	addi	sp,sp,-48
    80004bae:	f406                	sd	ra,40(sp)
    80004bb0:	f022                	sd	s0,32(sp)
    80004bb2:	ec26                	sd	s1,24(sp)
    80004bb4:	e84a                	sd	s2,16(sp)
    80004bb6:	e44e                	sd	s3,8(sp)
    80004bb8:	e052                	sd	s4,0(sp)
    80004bba:	1800                	addi	s0,sp,48
    80004bbc:	84aa                	mv	s1,a0
    80004bbe:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004bc0:	0005b023          	sd	zero,0(a1)
    80004bc4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004bc8:	00000097          	auipc	ra,0x0
    80004bcc:	bf8080e7          	jalr	-1032(ra) # 800047c0 <filealloc>
    80004bd0:	e088                	sd	a0,0(s1)
    80004bd2:	c551                	beqz	a0,80004c5e <pipealloc+0xb2>
    80004bd4:	00000097          	auipc	ra,0x0
    80004bd8:	bec080e7          	jalr	-1044(ra) # 800047c0 <filealloc>
    80004bdc:	00aa3023          	sd	a0,0(s4)
    80004be0:	c92d                	beqz	a0,80004c52 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004be2:	ffffc097          	auipc	ra,0xffffc
    80004be6:	f04080e7          	jalr	-252(ra) # 80000ae6 <kalloc>
    80004bea:	892a                	mv	s2,a0
    80004bec:	c125                	beqz	a0,80004c4c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004bee:	4985                	li	s3,1
    80004bf0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004bf4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004bf8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004bfc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c00:	00004597          	auipc	a1,0x4
    80004c04:	b6058593          	addi	a1,a1,-1184 # 80008760 <syscalls+0x278>
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	f3e080e7          	jalr	-194(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004c10:	609c                	ld	a5,0(s1)
    80004c12:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c16:	609c                	ld	a5,0(s1)
    80004c18:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c1c:	609c                	ld	a5,0(s1)
    80004c1e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c22:	609c                	ld	a5,0(s1)
    80004c24:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c28:	000a3783          	ld	a5,0(s4)
    80004c2c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c30:	000a3783          	ld	a5,0(s4)
    80004c34:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c38:	000a3783          	ld	a5,0(s4)
    80004c3c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c40:	000a3783          	ld	a5,0(s4)
    80004c44:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c48:	4501                	li	a0,0
    80004c4a:	a025                	j	80004c72 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c4c:	6088                	ld	a0,0(s1)
    80004c4e:	e501                	bnez	a0,80004c56 <pipealloc+0xaa>
    80004c50:	a039                	j	80004c5e <pipealloc+0xb2>
    80004c52:	6088                	ld	a0,0(s1)
    80004c54:	c51d                	beqz	a0,80004c82 <pipealloc+0xd6>
    fileclose(*f0);
    80004c56:	00000097          	auipc	ra,0x0
    80004c5a:	c26080e7          	jalr	-986(ra) # 8000487c <fileclose>
  if(*f1)
    80004c5e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c62:	557d                	li	a0,-1
  if(*f1)
    80004c64:	c799                	beqz	a5,80004c72 <pipealloc+0xc6>
    fileclose(*f1);
    80004c66:	853e                	mv	a0,a5
    80004c68:	00000097          	auipc	ra,0x0
    80004c6c:	c14080e7          	jalr	-1004(ra) # 8000487c <fileclose>
  return -1;
    80004c70:	557d                	li	a0,-1
}
    80004c72:	70a2                	ld	ra,40(sp)
    80004c74:	7402                	ld	s0,32(sp)
    80004c76:	64e2                	ld	s1,24(sp)
    80004c78:	6942                	ld	s2,16(sp)
    80004c7a:	69a2                	ld	s3,8(sp)
    80004c7c:	6a02                	ld	s4,0(sp)
    80004c7e:	6145                	addi	sp,sp,48
    80004c80:	8082                	ret
  return -1;
    80004c82:	557d                	li	a0,-1
    80004c84:	b7fd                	j	80004c72 <pipealloc+0xc6>

0000000080004c86 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c86:	1101                	addi	sp,sp,-32
    80004c88:	ec06                	sd	ra,24(sp)
    80004c8a:	e822                	sd	s0,16(sp)
    80004c8c:	e426                	sd	s1,8(sp)
    80004c8e:	e04a                	sd	s2,0(sp)
    80004c90:	1000                	addi	s0,sp,32
    80004c92:	84aa                	mv	s1,a0
    80004c94:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c96:	ffffc097          	auipc	ra,0xffffc
    80004c9a:	f40080e7          	jalr	-192(ra) # 80000bd6 <acquire>
  if(writable){
    80004c9e:	02090d63          	beqz	s2,80004cd8 <pipeclose+0x52>
    pi->writeopen = 0;
    80004ca2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ca6:	21848513          	addi	a0,s1,536
    80004caa:	ffffd097          	auipc	ra,0xffffd
    80004cae:	504080e7          	jalr	1284(ra) # 800021ae <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004cb2:	2204b783          	ld	a5,544(s1)
    80004cb6:	eb95                	bnez	a5,80004cea <pipeclose+0x64>
    release(&pi->lock);
    80004cb8:	8526                	mv	a0,s1
    80004cba:	ffffc097          	auipc	ra,0xffffc
    80004cbe:	fd0080e7          	jalr	-48(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004cc2:	8526                	mv	a0,s1
    80004cc4:	ffffc097          	auipc	ra,0xffffc
    80004cc8:	d26080e7          	jalr	-730(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004ccc:	60e2                	ld	ra,24(sp)
    80004cce:	6442                	ld	s0,16(sp)
    80004cd0:	64a2                	ld	s1,8(sp)
    80004cd2:	6902                	ld	s2,0(sp)
    80004cd4:	6105                	addi	sp,sp,32
    80004cd6:	8082                	ret
    pi->readopen = 0;
    80004cd8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004cdc:	21c48513          	addi	a0,s1,540
    80004ce0:	ffffd097          	auipc	ra,0xffffd
    80004ce4:	4ce080e7          	jalr	1230(ra) # 800021ae <wakeup>
    80004ce8:	b7e9                	j	80004cb2 <pipeclose+0x2c>
    release(&pi->lock);
    80004cea:	8526                	mv	a0,s1
    80004cec:	ffffc097          	auipc	ra,0xffffc
    80004cf0:	f9e080e7          	jalr	-98(ra) # 80000c8a <release>
}
    80004cf4:	bfe1                	j	80004ccc <pipeclose+0x46>

0000000080004cf6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cf6:	711d                	addi	sp,sp,-96
    80004cf8:	ec86                	sd	ra,88(sp)
    80004cfa:	e8a2                	sd	s0,80(sp)
    80004cfc:	e4a6                	sd	s1,72(sp)
    80004cfe:	e0ca                	sd	s2,64(sp)
    80004d00:	fc4e                	sd	s3,56(sp)
    80004d02:	f852                	sd	s4,48(sp)
    80004d04:	f456                	sd	s5,40(sp)
    80004d06:	f05a                	sd	s6,32(sp)
    80004d08:	ec5e                	sd	s7,24(sp)
    80004d0a:	e862                	sd	s8,16(sp)
    80004d0c:	1080                	addi	s0,sp,96
    80004d0e:	84aa                	mv	s1,a0
    80004d10:	8aae                	mv	s5,a1
    80004d12:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d14:	ffffd097          	auipc	ra,0xffffd
    80004d18:	c6c080e7          	jalr	-916(ra) # 80001980 <myproc>
    80004d1c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d1e:	8526                	mv	a0,s1
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	eb6080e7          	jalr	-330(ra) # 80000bd6 <acquire>
  while(i < n){
    80004d28:	0b405663          	blez	s4,80004dd4 <pipewrite+0xde>
  int i = 0;
    80004d2c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d2e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d30:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d34:	21c48b93          	addi	s7,s1,540
    80004d38:	a089                	j	80004d7a <pipewrite+0x84>
      release(&pi->lock);
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	ffffc097          	auipc	ra,0xffffc
    80004d40:	f4e080e7          	jalr	-178(ra) # 80000c8a <release>
      return -1;
    80004d44:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d46:	854a                	mv	a0,s2
    80004d48:	60e6                	ld	ra,88(sp)
    80004d4a:	6446                	ld	s0,80(sp)
    80004d4c:	64a6                	ld	s1,72(sp)
    80004d4e:	6906                	ld	s2,64(sp)
    80004d50:	79e2                	ld	s3,56(sp)
    80004d52:	7a42                	ld	s4,48(sp)
    80004d54:	7aa2                	ld	s5,40(sp)
    80004d56:	7b02                	ld	s6,32(sp)
    80004d58:	6be2                	ld	s7,24(sp)
    80004d5a:	6c42                	ld	s8,16(sp)
    80004d5c:	6125                	addi	sp,sp,96
    80004d5e:	8082                	ret
      wakeup(&pi->nread);
    80004d60:	8562                	mv	a0,s8
    80004d62:	ffffd097          	auipc	ra,0xffffd
    80004d66:	44c080e7          	jalr	1100(ra) # 800021ae <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d6a:	85a6                	mv	a1,s1
    80004d6c:	855e                	mv	a0,s7
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	3c0080e7          	jalr	960(ra) # 8000212e <sleep>
  while(i < n){
    80004d76:	07495063          	bge	s2,s4,80004dd6 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d7a:	2204a783          	lw	a5,544(s1)
    80004d7e:	dfd5                	beqz	a5,80004d3a <pipewrite+0x44>
    80004d80:	854e                	mv	a0,s3
    80004d82:	ffffd097          	auipc	ra,0xffffd
    80004d86:	6ee080e7          	jalr	1774(ra) # 80002470 <killed>
    80004d8a:	f945                	bnez	a0,80004d3a <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d8c:	2184a783          	lw	a5,536(s1)
    80004d90:	21c4a703          	lw	a4,540(s1)
    80004d94:	2007879b          	addiw	a5,a5,512
    80004d98:	fcf704e3          	beq	a4,a5,80004d60 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d9c:	4685                	li	a3,1
    80004d9e:	01590633          	add	a2,s2,s5
    80004da2:	faf40593          	addi	a1,s0,-81
    80004da6:	1009b503          	ld	a0,256(s3)
    80004daa:	ffffd097          	auipc	ra,0xffffd
    80004dae:	94a080e7          	jalr	-1718(ra) # 800016f4 <copyin>
    80004db2:	03650263          	beq	a0,s6,80004dd6 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004db6:	21c4a783          	lw	a5,540(s1)
    80004dba:	0017871b          	addiw	a4,a5,1
    80004dbe:	20e4ae23          	sw	a4,540(s1)
    80004dc2:	1ff7f793          	andi	a5,a5,511
    80004dc6:	97a6                	add	a5,a5,s1
    80004dc8:	faf44703          	lbu	a4,-81(s0)
    80004dcc:	00e78c23          	sb	a4,24(a5)
      i++;
    80004dd0:	2905                	addiw	s2,s2,1
    80004dd2:	b755                	j	80004d76 <pipewrite+0x80>
  int i = 0;
    80004dd4:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004dd6:	21848513          	addi	a0,s1,536
    80004dda:	ffffd097          	auipc	ra,0xffffd
    80004dde:	3d4080e7          	jalr	980(ra) # 800021ae <wakeup>
  release(&pi->lock);
    80004de2:	8526                	mv	a0,s1
    80004de4:	ffffc097          	auipc	ra,0xffffc
    80004de8:	ea6080e7          	jalr	-346(ra) # 80000c8a <release>
  return i;
    80004dec:	bfa9                	j	80004d46 <pipewrite+0x50>

0000000080004dee <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004dee:	715d                	addi	sp,sp,-80
    80004df0:	e486                	sd	ra,72(sp)
    80004df2:	e0a2                	sd	s0,64(sp)
    80004df4:	fc26                	sd	s1,56(sp)
    80004df6:	f84a                	sd	s2,48(sp)
    80004df8:	f44e                	sd	s3,40(sp)
    80004dfa:	f052                	sd	s4,32(sp)
    80004dfc:	ec56                	sd	s5,24(sp)
    80004dfe:	e85a                	sd	s6,16(sp)
    80004e00:	0880                	addi	s0,sp,80
    80004e02:	84aa                	mv	s1,a0
    80004e04:	892e                	mv	s2,a1
    80004e06:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e08:	ffffd097          	auipc	ra,0xffffd
    80004e0c:	b78080e7          	jalr	-1160(ra) # 80001980 <myproc>
    80004e10:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e12:	8526                	mv	a0,s1
    80004e14:	ffffc097          	auipc	ra,0xffffc
    80004e18:	dc2080e7          	jalr	-574(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e1c:	2184a703          	lw	a4,536(s1)
    80004e20:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e24:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e28:	02f71763          	bne	a4,a5,80004e56 <piperead+0x68>
    80004e2c:	2244a783          	lw	a5,548(s1)
    80004e30:	c39d                	beqz	a5,80004e56 <piperead+0x68>
    if(killed(pr)){
    80004e32:	8552                	mv	a0,s4
    80004e34:	ffffd097          	auipc	ra,0xffffd
    80004e38:	63c080e7          	jalr	1596(ra) # 80002470 <killed>
    80004e3c:	e941                	bnez	a0,80004ecc <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e3e:	85a6                	mv	a1,s1
    80004e40:	854e                	mv	a0,s3
    80004e42:	ffffd097          	auipc	ra,0xffffd
    80004e46:	2ec080e7          	jalr	748(ra) # 8000212e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e4a:	2184a703          	lw	a4,536(s1)
    80004e4e:	21c4a783          	lw	a5,540(s1)
    80004e52:	fcf70de3          	beq	a4,a5,80004e2c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e56:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e58:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e5a:	05505363          	blez	s5,80004ea0 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004e5e:	2184a783          	lw	a5,536(s1)
    80004e62:	21c4a703          	lw	a4,540(s1)
    80004e66:	02f70d63          	beq	a4,a5,80004ea0 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e6a:	0017871b          	addiw	a4,a5,1
    80004e6e:	20e4ac23          	sw	a4,536(s1)
    80004e72:	1ff7f793          	andi	a5,a5,511
    80004e76:	97a6                	add	a5,a5,s1
    80004e78:	0187c783          	lbu	a5,24(a5)
    80004e7c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e80:	4685                	li	a3,1
    80004e82:	fbf40613          	addi	a2,s0,-65
    80004e86:	85ca                	mv	a1,s2
    80004e88:	100a3503          	ld	a0,256(s4)
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	7dc080e7          	jalr	2012(ra) # 80001668 <copyout>
    80004e94:	01650663          	beq	a0,s6,80004ea0 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e98:	2985                	addiw	s3,s3,1
    80004e9a:	0905                	addi	s2,s2,1
    80004e9c:	fd3a91e3          	bne	s5,s3,80004e5e <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ea0:	21c48513          	addi	a0,s1,540
    80004ea4:	ffffd097          	auipc	ra,0xffffd
    80004ea8:	30a080e7          	jalr	778(ra) # 800021ae <wakeup>
  release(&pi->lock);
    80004eac:	8526                	mv	a0,s1
    80004eae:	ffffc097          	auipc	ra,0xffffc
    80004eb2:	ddc080e7          	jalr	-548(ra) # 80000c8a <release>
  return i;
}
    80004eb6:	854e                	mv	a0,s3
    80004eb8:	60a6                	ld	ra,72(sp)
    80004eba:	6406                	ld	s0,64(sp)
    80004ebc:	74e2                	ld	s1,56(sp)
    80004ebe:	7942                	ld	s2,48(sp)
    80004ec0:	79a2                	ld	s3,40(sp)
    80004ec2:	7a02                	ld	s4,32(sp)
    80004ec4:	6ae2                	ld	s5,24(sp)
    80004ec6:	6b42                	ld	s6,16(sp)
    80004ec8:	6161                	addi	sp,sp,80
    80004eca:	8082                	ret
      release(&pi->lock);
    80004ecc:	8526                	mv	a0,s1
    80004ece:	ffffc097          	auipc	ra,0xffffc
    80004ed2:	dbc080e7          	jalr	-580(ra) # 80000c8a <release>
      return -1;
    80004ed6:	59fd                	li	s3,-1
    80004ed8:	bff9                	j	80004eb6 <piperead+0xc8>

0000000080004eda <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004eda:	1141                	addi	sp,sp,-16
    80004edc:	e422                	sd	s0,8(sp)
    80004ede:	0800                	addi	s0,sp,16
    80004ee0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004ee2:	8905                	andi	a0,a0,1
    80004ee4:	c111                	beqz	a0,80004ee8 <flags2perm+0xe>
      perm = PTE_X;
    80004ee6:	4521                	li	a0,8
    if(flags & 0x2)
    80004ee8:	8b89                	andi	a5,a5,2
    80004eea:	c399                	beqz	a5,80004ef0 <flags2perm+0x16>
      perm |= PTE_W;
    80004eec:	00456513          	ori	a0,a0,4
    return perm;
}
    80004ef0:	6422                	ld	s0,8(sp)
    80004ef2:	0141                	addi	sp,sp,16
    80004ef4:	8082                	ret

0000000080004ef6 <exec>:

int
exec(char *path, char **argv)
{
    80004ef6:	de010113          	addi	sp,sp,-544
    80004efa:	20113c23          	sd	ra,536(sp)
    80004efe:	20813823          	sd	s0,528(sp)
    80004f02:	20913423          	sd	s1,520(sp)
    80004f06:	21213023          	sd	s2,512(sp)
    80004f0a:	ffce                	sd	s3,504(sp)
    80004f0c:	fbd2                	sd	s4,496(sp)
    80004f0e:	f7d6                	sd	s5,488(sp)
    80004f10:	f3da                	sd	s6,480(sp)
    80004f12:	efde                	sd	s7,472(sp)
    80004f14:	ebe2                	sd	s8,464(sp)
    80004f16:	e7e6                	sd	s9,456(sp)
    80004f18:	e3ea                	sd	s10,448(sp)
    80004f1a:	ff6e                	sd	s11,440(sp)
    80004f1c:	1400                	addi	s0,sp,544
    80004f1e:	892a                	mv	s2,a0
    80004f20:	dea43423          	sd	a0,-536(s0)
    80004f24:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f28:	ffffd097          	auipc	ra,0xffffd
    80004f2c:	a58080e7          	jalr	-1448(ra) # 80001980 <myproc>
    80004f30:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80004f32:	ffffe097          	auipc	ra,0xffffe
    80004f36:	86e080e7          	jalr	-1938(ra) # 800027a0 <mykthread>

  begin_op();
    80004f3a:	fffff097          	auipc	ra,0xfffff
    80004f3e:	476080e7          	jalr	1142(ra) # 800043b0 <begin_op>

  if((ip = namei(path)) == 0){
    80004f42:	854a                	mv	a0,s2
    80004f44:	fffff097          	auipc	ra,0xfffff
    80004f48:	250080e7          	jalr	592(ra) # 80004194 <namei>
    80004f4c:	c93d                	beqz	a0,80004fc2 <exec+0xcc>
    80004f4e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f50:	fffff097          	auipc	ra,0xfffff
    80004f54:	a9e080e7          	jalr	-1378(ra) # 800039ee <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f58:	04000713          	li	a4,64
    80004f5c:	4681                	li	a3,0
    80004f5e:	e5040613          	addi	a2,s0,-432
    80004f62:	4581                	li	a1,0
    80004f64:	8556                	mv	a0,s5
    80004f66:	fffff097          	auipc	ra,0xfffff
    80004f6a:	d3c080e7          	jalr	-708(ra) # 80003ca2 <readi>
    80004f6e:	04000793          	li	a5,64
    80004f72:	00f51a63          	bne	a0,a5,80004f86 <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f76:	e5042703          	lw	a4,-432(s0)
    80004f7a:	464c47b7          	lui	a5,0x464c4
    80004f7e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f82:	04f70663          	beq	a4,a5,80004fce <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f86:	8556                	mv	a0,s5
    80004f88:	fffff097          	auipc	ra,0xfffff
    80004f8c:	cc8080e7          	jalr	-824(ra) # 80003c50 <iunlockput>
    end_op();
    80004f90:	fffff097          	auipc	ra,0xfffff
    80004f94:	4a0080e7          	jalr	1184(ra) # 80004430 <end_op>
  }
  return -1;
    80004f98:	557d                	li	a0,-1
}
    80004f9a:	21813083          	ld	ra,536(sp)
    80004f9e:	21013403          	ld	s0,528(sp)
    80004fa2:	20813483          	ld	s1,520(sp)
    80004fa6:	20013903          	ld	s2,512(sp)
    80004faa:	79fe                	ld	s3,504(sp)
    80004fac:	7a5e                	ld	s4,496(sp)
    80004fae:	7abe                	ld	s5,488(sp)
    80004fb0:	7b1e                	ld	s6,480(sp)
    80004fb2:	6bfe                	ld	s7,472(sp)
    80004fb4:	6c5e                	ld	s8,464(sp)
    80004fb6:	6cbe                	ld	s9,456(sp)
    80004fb8:	6d1e                	ld	s10,448(sp)
    80004fba:	7dfa                	ld	s11,440(sp)
    80004fbc:	22010113          	addi	sp,sp,544
    80004fc0:	8082                	ret
    end_op();
    80004fc2:	fffff097          	auipc	ra,0xfffff
    80004fc6:	46e080e7          	jalr	1134(ra) # 80004430 <end_op>
    return -1;
    80004fca:	557d                	li	a0,-1
    80004fcc:	b7f9                	j	80004f9a <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    80004fce:	8526                	mv	a0,s1
    80004fd0:	ffffd097          	auipc	ra,0xffffd
    80004fd4:	a4c080e7          	jalr	-1460(ra) # 80001a1c <proc_pagetable>
    80004fd8:	8b2a                	mv	s6,a0
    80004fda:	d555                	beqz	a0,80004f86 <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fdc:	e7042783          	lw	a5,-400(s0)
    80004fe0:	e8845703          	lhu	a4,-376(s0)
    80004fe4:	c735                	beqz	a4,80005050 <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fe6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fe8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004fec:	6a05                	lui	s4,0x1
    80004fee:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004ff2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004ff6:	6d85                	lui	s11,0x1
    80004ff8:	7d7d                	lui	s10,0xfffff
    80004ffa:	a4a9                	j	80005244 <exec+0x34e>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ffc:	00003517          	auipc	a0,0x3
    80005000:	76c50513          	addi	a0,a0,1900 # 80008768 <syscalls+0x280>
    80005004:	ffffb097          	auipc	ra,0xffffb
    80005008:	53a080e7          	jalr	1338(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000500c:	874a                	mv	a4,s2
    8000500e:	009c86bb          	addw	a3,s9,s1
    80005012:	4581                	li	a1,0
    80005014:	8556                	mv	a0,s5
    80005016:	fffff097          	auipc	ra,0xfffff
    8000501a:	c8c080e7          	jalr	-884(ra) # 80003ca2 <readi>
    8000501e:	2501                	sext.w	a0,a0
    80005020:	1aa91f63          	bne	s2,a0,800051de <exec+0x2e8>
  for(i = 0; i < sz; i += PGSIZE){
    80005024:	009d84bb          	addw	s1,s11,s1
    80005028:	013d09bb          	addw	s3,s10,s3
    8000502c:	1f74fc63          	bgeu	s1,s7,80005224 <exec+0x32e>
    pa = walkaddr(pagetable, va + i);
    80005030:	02049593          	slli	a1,s1,0x20
    80005034:	9181                	srli	a1,a1,0x20
    80005036:	95e2                	add	a1,a1,s8
    80005038:	855a                	mv	a0,s6
    8000503a:	ffffc097          	auipc	ra,0xffffc
    8000503e:	022080e7          	jalr	34(ra) # 8000105c <walkaddr>
    80005042:	862a                	mv	a2,a0
    if(pa == 0)
    80005044:	dd45                	beqz	a0,80004ffc <exec+0x106>
      n = PGSIZE;
    80005046:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005048:	fd49f2e3          	bgeu	s3,s4,8000500c <exec+0x116>
      n = sz - i;
    8000504c:	894e                	mv	s2,s3
    8000504e:	bf7d                	j	8000500c <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005050:	4901                	li	s2,0
  iunlockput(ip);
    80005052:	8556                	mv	a0,s5
    80005054:	fffff097          	auipc	ra,0xfffff
    80005058:	bfc080e7          	jalr	-1028(ra) # 80003c50 <iunlockput>
  end_op();
    8000505c:	fffff097          	auipc	ra,0xfffff
    80005060:	3d4080e7          	jalr	980(ra) # 80004430 <end_op>
  p = myproc();
    80005064:	ffffd097          	auipc	ra,0xffffd
    80005068:	91c080e7          	jalr	-1764(ra) # 80001980 <myproc>
    8000506c:	8baa                	mv	s7,a0
  kt = mykthread();
    8000506e:	ffffd097          	auipc	ra,0xffffd
    80005072:	732080e7          	jalr	1842(ra) # 800027a0 <mykthread>
    80005076:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80005078:	0f8bbd83          	ld	s11,248(s7) # 10f8 <_entry-0x7fffef08>
  sz = PGROUNDUP(sz);
    8000507c:	6785                	lui	a5,0x1
    8000507e:	17fd                	addi	a5,a5,-1
    80005080:	993e                	add	s2,s2,a5
    80005082:	77fd                	lui	a5,0xfffff
    80005084:	00f977b3          	and	a5,s2,a5
    80005088:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000508c:	4691                	li	a3,4
    8000508e:	6609                	lui	a2,0x2
    80005090:	963e                	add	a2,a2,a5
    80005092:	85be                	mv	a1,a5
    80005094:	855a                	mv	a0,s6
    80005096:	ffffc097          	auipc	ra,0xffffc
    8000509a:	37a080e7          	jalr	890(ra) # 80001410 <uvmalloc>
    8000509e:	8c2a                	mv	s8,a0
  ip = 0;
    800050a0:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800050a2:	12050e63          	beqz	a0,800051de <exec+0x2e8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050a6:	75f9                	lui	a1,0xffffe
    800050a8:	95aa                	add	a1,a1,a0
    800050aa:	855a                	mv	a0,s6
    800050ac:	ffffc097          	auipc	ra,0xffffc
    800050b0:	58a080e7          	jalr	1418(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    800050b4:	7afd                	lui	s5,0xfffff
    800050b6:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800050b8:	df043783          	ld	a5,-528(s0)
    800050bc:	6388                	ld	a0,0(a5)
    800050be:	c925                	beqz	a0,8000512e <exec+0x238>
    800050c0:	e9040993          	addi	s3,s0,-368
    800050c4:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800050c8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050ca:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050cc:	ffffc097          	auipc	ra,0xffffc
    800050d0:	d82080e7          	jalr	-638(ra) # 80000e4e <strlen>
    800050d4:	0015079b          	addiw	a5,a0,1
    800050d8:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050dc:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800050e0:	13596663          	bltu	s2,s5,8000520c <exec+0x316>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050e4:	df043783          	ld	a5,-528(s0)
    800050e8:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffdbc00>
    800050ec:	8552                	mv	a0,s4
    800050ee:	ffffc097          	auipc	ra,0xffffc
    800050f2:	d60080e7          	jalr	-672(ra) # 80000e4e <strlen>
    800050f6:	0015069b          	addiw	a3,a0,1
    800050fa:	8652                	mv	a2,s4
    800050fc:	85ca                	mv	a1,s2
    800050fe:	855a                	mv	a0,s6
    80005100:	ffffc097          	auipc	ra,0xffffc
    80005104:	568080e7          	jalr	1384(ra) # 80001668 <copyout>
    80005108:	10054663          	bltz	a0,80005214 <exec+0x31e>
    ustack[argc] = sp;
    8000510c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005110:	0485                	addi	s1,s1,1
    80005112:	df043783          	ld	a5,-528(s0)
    80005116:	07a1                	addi	a5,a5,8
    80005118:	def43823          	sd	a5,-528(s0)
    8000511c:	6388                	ld	a0,0(a5)
    8000511e:	c911                	beqz	a0,80005132 <exec+0x23c>
    if(argc >= MAXARG)
    80005120:	09a1                	addi	s3,s3,8
    80005122:	fb3c95e3          	bne	s9,s3,800050cc <exec+0x1d6>
  sz = sz1;
    80005126:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000512a:	4a81                	li	s5,0
    8000512c:	a84d                	j	800051de <exec+0x2e8>
  sp = sz;
    8000512e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005130:	4481                	li	s1,0
  ustack[argc] = 0;
    80005132:	00349793          	slli	a5,s1,0x3
    80005136:	f9040713          	addi	a4,s0,-112
    8000513a:	97ba                	add	a5,a5,a4
    8000513c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005140:	00148693          	addi	a3,s1,1
    80005144:	068e                	slli	a3,a3,0x3
    80005146:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000514a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000514e:	01597663          	bgeu	s2,s5,8000515a <exec+0x264>
  sz = sz1;
    80005152:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005156:	4a81                	li	s5,0
    80005158:	a059                	j	800051de <exec+0x2e8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000515a:	e9040613          	addi	a2,s0,-368
    8000515e:	85ca                	mv	a1,s2
    80005160:	855a                	mv	a0,s6
    80005162:	ffffc097          	auipc	ra,0xffffc
    80005166:	506080e7          	jalr	1286(ra) # 80001668 <copyout>
    8000516a:	0a054963          	bltz	a0,8000521c <exec+0x326>
  kt->trapframe->a1 = sp;
    8000516e:	0b8d3783          	ld	a5,184(s10) # fffffffffffff0b8 <end+0xffffffff7ffdbcb8>
    80005172:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005176:	de843783          	ld	a5,-536(s0)
    8000517a:	0007c703          	lbu	a4,0(a5)
    8000517e:	cf11                	beqz	a4,8000519a <exec+0x2a4>
    80005180:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005182:	02f00693          	li	a3,47
    80005186:	a039                	j	80005194 <exec+0x29e>
      last = s+1;
    80005188:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000518c:	0785                	addi	a5,a5,1
    8000518e:	fff7c703          	lbu	a4,-1(a5)
    80005192:	c701                	beqz	a4,8000519a <exec+0x2a4>
    if(*s == '/')
    80005194:	fed71ce3          	bne	a4,a3,8000518c <exec+0x296>
    80005198:	bfc5                	j	80005188 <exec+0x292>
  safestrcpy(p->name, last, sizeof(p->name));
    8000519a:	4641                	li	a2,16
    8000519c:	de843583          	ld	a1,-536(s0)
    800051a0:	190b8513          	addi	a0,s7,400
    800051a4:	ffffc097          	auipc	ra,0xffffc
    800051a8:	c78080e7          	jalr	-904(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800051ac:	100bb503          	ld	a0,256(s7)
  p->pagetable = pagetable;
    800051b0:	116bb023          	sd	s6,256(s7)
  p->sz = sz;
    800051b4:	0f8bbc23          	sd	s8,248(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    800051b8:	0b8d3783          	ld	a5,184(s10)
    800051bc:	e6843703          	ld	a4,-408(s0)
    800051c0:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    800051c2:	0b8d3783          	ld	a5,184(s10)
    800051c6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051ca:	85ee                	mv	a1,s11
    800051cc:	ffffd097          	auipc	ra,0xffffd
    800051d0:	8ec080e7          	jalr	-1812(ra) # 80001ab8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051d4:	0004851b          	sext.w	a0,s1
    800051d8:	b3c9                	j	80004f9a <exec+0xa4>
    800051da:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051de:	df843583          	ld	a1,-520(s0)
    800051e2:	855a                	mv	a0,s6
    800051e4:	ffffd097          	auipc	ra,0xffffd
    800051e8:	8d4080e7          	jalr	-1836(ra) # 80001ab8 <proc_freepagetable>
  if(ip){
    800051ec:	d80a9de3          	bnez	s5,80004f86 <exec+0x90>
  return -1;
    800051f0:	557d                	li	a0,-1
    800051f2:	b365                	j	80004f9a <exec+0xa4>
    800051f4:	df243c23          	sd	s2,-520(s0)
    800051f8:	b7dd                	j	800051de <exec+0x2e8>
    800051fa:	df243c23          	sd	s2,-520(s0)
    800051fe:	b7c5                	j	800051de <exec+0x2e8>
    80005200:	df243c23          	sd	s2,-520(s0)
    80005204:	bfe9                	j	800051de <exec+0x2e8>
    80005206:	df243c23          	sd	s2,-520(s0)
    8000520a:	bfd1                	j	800051de <exec+0x2e8>
  sz = sz1;
    8000520c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005210:	4a81                	li	s5,0
    80005212:	b7f1                	j	800051de <exec+0x2e8>
  sz = sz1;
    80005214:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005218:	4a81                	li	s5,0
    8000521a:	b7d1                	j	800051de <exec+0x2e8>
  sz = sz1;
    8000521c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005220:	4a81                	li	s5,0
    80005222:	bf75                	j	800051de <exec+0x2e8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005224:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005228:	e0843783          	ld	a5,-504(s0)
    8000522c:	0017869b          	addiw	a3,a5,1
    80005230:	e0d43423          	sd	a3,-504(s0)
    80005234:	e0043783          	ld	a5,-512(s0)
    80005238:	0387879b          	addiw	a5,a5,56
    8000523c:	e8845703          	lhu	a4,-376(s0)
    80005240:	e0e6d9e3          	bge	a3,a4,80005052 <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005244:	2781                	sext.w	a5,a5
    80005246:	e0f43023          	sd	a5,-512(s0)
    8000524a:	03800713          	li	a4,56
    8000524e:	86be                	mv	a3,a5
    80005250:	e1840613          	addi	a2,s0,-488
    80005254:	4581                	li	a1,0
    80005256:	8556                	mv	a0,s5
    80005258:	fffff097          	auipc	ra,0xfffff
    8000525c:	a4a080e7          	jalr	-1462(ra) # 80003ca2 <readi>
    80005260:	03800793          	li	a5,56
    80005264:	f6f51be3          	bne	a0,a5,800051da <exec+0x2e4>
    if(ph.type != ELF_PROG_LOAD)
    80005268:	e1842783          	lw	a5,-488(s0)
    8000526c:	4705                	li	a4,1
    8000526e:	fae79de3          	bne	a5,a4,80005228 <exec+0x332>
    if(ph.memsz < ph.filesz)
    80005272:	e4043483          	ld	s1,-448(s0)
    80005276:	e3843783          	ld	a5,-456(s0)
    8000527a:	f6f4ede3          	bltu	s1,a5,800051f4 <exec+0x2fe>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000527e:	e2843783          	ld	a5,-472(s0)
    80005282:	94be                	add	s1,s1,a5
    80005284:	f6f4ebe3          	bltu	s1,a5,800051fa <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    80005288:	de043703          	ld	a4,-544(s0)
    8000528c:	8ff9                	and	a5,a5,a4
    8000528e:	fbad                	bnez	a5,80005200 <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005290:	e1c42503          	lw	a0,-484(s0)
    80005294:	00000097          	auipc	ra,0x0
    80005298:	c46080e7          	jalr	-954(ra) # 80004eda <flags2perm>
    8000529c:	86aa                	mv	a3,a0
    8000529e:	8626                	mv	a2,s1
    800052a0:	85ca                	mv	a1,s2
    800052a2:	855a                	mv	a0,s6
    800052a4:	ffffc097          	auipc	ra,0xffffc
    800052a8:	16c080e7          	jalr	364(ra) # 80001410 <uvmalloc>
    800052ac:	dea43c23          	sd	a0,-520(s0)
    800052b0:	d939                	beqz	a0,80005206 <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052b2:	e2843c03          	ld	s8,-472(s0)
    800052b6:	e2042c83          	lw	s9,-480(s0)
    800052ba:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052be:	f60b83e3          	beqz	s7,80005224 <exec+0x32e>
    800052c2:	89de                	mv	s3,s7
    800052c4:	4481                	li	s1,0
    800052c6:	b3ad                	j	80005030 <exec+0x13a>

00000000800052c8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052c8:	7179                	addi	sp,sp,-48
    800052ca:	f406                	sd	ra,40(sp)
    800052cc:	f022                	sd	s0,32(sp)
    800052ce:	ec26                	sd	s1,24(sp)
    800052d0:	e84a                	sd	s2,16(sp)
    800052d2:	1800                	addi	s0,sp,48
    800052d4:	892e                	mv	s2,a1
    800052d6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800052d8:	fdc40593          	addi	a1,s0,-36
    800052dc:	ffffe097          	auipc	ra,0xffffe
    800052e0:	b96080e7          	jalr	-1130(ra) # 80002e72 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052e4:	fdc42703          	lw	a4,-36(s0)
    800052e8:	47bd                	li	a5,15
    800052ea:	02e7eb63          	bltu	a5,a4,80005320 <argfd+0x58>
    800052ee:	ffffc097          	auipc	ra,0xffffc
    800052f2:	692080e7          	jalr	1682(ra) # 80001980 <myproc>
    800052f6:	fdc42703          	lw	a4,-36(s0)
    800052fa:	02070793          	addi	a5,a4,32
    800052fe:	078e                	slli	a5,a5,0x3
    80005300:	953e                	add	a0,a0,a5
    80005302:	651c                	ld	a5,8(a0)
    80005304:	c385                	beqz	a5,80005324 <argfd+0x5c>
    return -1;
  if(pfd)
    80005306:	00090463          	beqz	s2,8000530e <argfd+0x46>
    *pfd = fd;
    8000530a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000530e:	4501                	li	a0,0
  if(pf)
    80005310:	c091                	beqz	s1,80005314 <argfd+0x4c>
    *pf = f;
    80005312:	e09c                	sd	a5,0(s1)
}
    80005314:	70a2                	ld	ra,40(sp)
    80005316:	7402                	ld	s0,32(sp)
    80005318:	64e2                	ld	s1,24(sp)
    8000531a:	6942                	ld	s2,16(sp)
    8000531c:	6145                	addi	sp,sp,48
    8000531e:	8082                	ret
    return -1;
    80005320:	557d                	li	a0,-1
    80005322:	bfcd                	j	80005314 <argfd+0x4c>
    80005324:	557d                	li	a0,-1
    80005326:	b7fd                	j	80005314 <argfd+0x4c>

0000000080005328 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005328:	1101                	addi	sp,sp,-32
    8000532a:	ec06                	sd	ra,24(sp)
    8000532c:	e822                	sd	s0,16(sp)
    8000532e:	e426                	sd	s1,8(sp)
    80005330:	1000                	addi	s0,sp,32
    80005332:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005334:	ffffc097          	auipc	ra,0xffffc
    80005338:	64c080e7          	jalr	1612(ra) # 80001980 <myproc>
    8000533c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000533e:	10850793          	addi	a5,a0,264
    80005342:	4501                	li	a0,0
    80005344:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005346:	6398                	ld	a4,0(a5)
    80005348:	cb19                	beqz	a4,8000535e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000534a:	2505                	addiw	a0,a0,1
    8000534c:	07a1                	addi	a5,a5,8
    8000534e:	fed51ce3          	bne	a0,a3,80005346 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005352:	557d                	li	a0,-1
}
    80005354:	60e2                	ld	ra,24(sp)
    80005356:	6442                	ld	s0,16(sp)
    80005358:	64a2                	ld	s1,8(sp)
    8000535a:	6105                	addi	sp,sp,32
    8000535c:	8082                	ret
      p->ofile[fd] = f;
    8000535e:	02050793          	addi	a5,a0,32
    80005362:	078e                	slli	a5,a5,0x3
    80005364:	963e                	add	a2,a2,a5
    80005366:	e604                	sd	s1,8(a2)
      return fd;
    80005368:	b7f5                	j	80005354 <fdalloc+0x2c>

000000008000536a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000536a:	715d                	addi	sp,sp,-80
    8000536c:	e486                	sd	ra,72(sp)
    8000536e:	e0a2                	sd	s0,64(sp)
    80005370:	fc26                	sd	s1,56(sp)
    80005372:	f84a                	sd	s2,48(sp)
    80005374:	f44e                	sd	s3,40(sp)
    80005376:	f052                	sd	s4,32(sp)
    80005378:	ec56                	sd	s5,24(sp)
    8000537a:	e85a                	sd	s6,16(sp)
    8000537c:	0880                	addi	s0,sp,80
    8000537e:	8b2e                	mv	s6,a1
    80005380:	89b2                	mv	s3,a2
    80005382:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005384:	fb040593          	addi	a1,s0,-80
    80005388:	fffff097          	auipc	ra,0xfffff
    8000538c:	e2a080e7          	jalr	-470(ra) # 800041b2 <nameiparent>
    80005390:	84aa                	mv	s1,a0
    80005392:	14050f63          	beqz	a0,800054f0 <create+0x186>
    return 0;

  ilock(dp);
    80005396:	ffffe097          	auipc	ra,0xffffe
    8000539a:	658080e7          	jalr	1624(ra) # 800039ee <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000539e:	4601                	li	a2,0
    800053a0:	fb040593          	addi	a1,s0,-80
    800053a4:	8526                	mv	a0,s1
    800053a6:	fffff097          	auipc	ra,0xfffff
    800053aa:	b2c080e7          	jalr	-1236(ra) # 80003ed2 <dirlookup>
    800053ae:	8aaa                	mv	s5,a0
    800053b0:	c931                	beqz	a0,80005404 <create+0x9a>
    iunlockput(dp);
    800053b2:	8526                	mv	a0,s1
    800053b4:	fffff097          	auipc	ra,0xfffff
    800053b8:	89c080e7          	jalr	-1892(ra) # 80003c50 <iunlockput>
    ilock(ip);
    800053bc:	8556                	mv	a0,s5
    800053be:	ffffe097          	auipc	ra,0xffffe
    800053c2:	630080e7          	jalr	1584(ra) # 800039ee <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053c6:	000b059b          	sext.w	a1,s6
    800053ca:	4789                	li	a5,2
    800053cc:	02f59563          	bne	a1,a5,800053f6 <create+0x8c>
    800053d0:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbc44>
    800053d4:	37f9                	addiw	a5,a5,-2
    800053d6:	17c2                	slli	a5,a5,0x30
    800053d8:	93c1                	srli	a5,a5,0x30
    800053da:	4705                	li	a4,1
    800053dc:	00f76d63          	bltu	a4,a5,800053f6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800053e0:	8556                	mv	a0,s5
    800053e2:	60a6                	ld	ra,72(sp)
    800053e4:	6406                	ld	s0,64(sp)
    800053e6:	74e2                	ld	s1,56(sp)
    800053e8:	7942                	ld	s2,48(sp)
    800053ea:	79a2                	ld	s3,40(sp)
    800053ec:	7a02                	ld	s4,32(sp)
    800053ee:	6ae2                	ld	s5,24(sp)
    800053f0:	6b42                	ld	s6,16(sp)
    800053f2:	6161                	addi	sp,sp,80
    800053f4:	8082                	ret
    iunlockput(ip);
    800053f6:	8556                	mv	a0,s5
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	858080e7          	jalr	-1960(ra) # 80003c50 <iunlockput>
    return 0;
    80005400:	4a81                	li	s5,0
    80005402:	bff9                	j	800053e0 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005404:	85da                	mv	a1,s6
    80005406:	4088                	lw	a0,0(s1)
    80005408:	ffffe097          	auipc	ra,0xffffe
    8000540c:	44a080e7          	jalr	1098(ra) # 80003852 <ialloc>
    80005410:	8a2a                	mv	s4,a0
    80005412:	c539                	beqz	a0,80005460 <create+0xf6>
  ilock(ip);
    80005414:	ffffe097          	auipc	ra,0xffffe
    80005418:	5da080e7          	jalr	1498(ra) # 800039ee <ilock>
  ip->major = major;
    8000541c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005420:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005424:	4905                	li	s2,1
    80005426:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000542a:	8552                	mv	a0,s4
    8000542c:	ffffe097          	auipc	ra,0xffffe
    80005430:	4f8080e7          	jalr	1272(ra) # 80003924 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005434:	000b059b          	sext.w	a1,s6
    80005438:	03258b63          	beq	a1,s2,8000546e <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000543c:	004a2603          	lw	a2,4(s4)
    80005440:	fb040593          	addi	a1,s0,-80
    80005444:	8526                	mv	a0,s1
    80005446:	fffff097          	auipc	ra,0xfffff
    8000544a:	c9c080e7          	jalr	-868(ra) # 800040e2 <dirlink>
    8000544e:	06054f63          	bltz	a0,800054cc <create+0x162>
  iunlockput(dp);
    80005452:	8526                	mv	a0,s1
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	7fc080e7          	jalr	2044(ra) # 80003c50 <iunlockput>
  return ip;
    8000545c:	8ad2                	mv	s5,s4
    8000545e:	b749                	j	800053e0 <create+0x76>
    iunlockput(dp);
    80005460:	8526                	mv	a0,s1
    80005462:	ffffe097          	auipc	ra,0xffffe
    80005466:	7ee080e7          	jalr	2030(ra) # 80003c50 <iunlockput>
    return 0;
    8000546a:	8ad2                	mv	s5,s4
    8000546c:	bf95                	j	800053e0 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000546e:	004a2603          	lw	a2,4(s4)
    80005472:	00003597          	auipc	a1,0x3
    80005476:	31658593          	addi	a1,a1,790 # 80008788 <syscalls+0x2a0>
    8000547a:	8552                	mv	a0,s4
    8000547c:	fffff097          	auipc	ra,0xfffff
    80005480:	c66080e7          	jalr	-922(ra) # 800040e2 <dirlink>
    80005484:	04054463          	bltz	a0,800054cc <create+0x162>
    80005488:	40d0                	lw	a2,4(s1)
    8000548a:	00003597          	auipc	a1,0x3
    8000548e:	30658593          	addi	a1,a1,774 # 80008790 <syscalls+0x2a8>
    80005492:	8552                	mv	a0,s4
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	c4e080e7          	jalr	-946(ra) # 800040e2 <dirlink>
    8000549c:	02054863          	bltz	a0,800054cc <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800054a0:	004a2603          	lw	a2,4(s4)
    800054a4:	fb040593          	addi	a1,s0,-80
    800054a8:	8526                	mv	a0,s1
    800054aa:	fffff097          	auipc	ra,0xfffff
    800054ae:	c38080e7          	jalr	-968(ra) # 800040e2 <dirlink>
    800054b2:	00054d63          	bltz	a0,800054cc <create+0x162>
    dp->nlink++;  // for ".."
    800054b6:	04a4d783          	lhu	a5,74(s1)
    800054ba:	2785                	addiw	a5,a5,1
    800054bc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054c0:	8526                	mv	a0,s1
    800054c2:	ffffe097          	auipc	ra,0xffffe
    800054c6:	462080e7          	jalr	1122(ra) # 80003924 <iupdate>
    800054ca:	b761                	j	80005452 <create+0xe8>
  ip->nlink = 0;
    800054cc:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800054d0:	8552                	mv	a0,s4
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	452080e7          	jalr	1106(ra) # 80003924 <iupdate>
  iunlockput(ip);
    800054da:	8552                	mv	a0,s4
    800054dc:	ffffe097          	auipc	ra,0xffffe
    800054e0:	774080e7          	jalr	1908(ra) # 80003c50 <iunlockput>
  iunlockput(dp);
    800054e4:	8526                	mv	a0,s1
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	76a080e7          	jalr	1898(ra) # 80003c50 <iunlockput>
  return 0;
    800054ee:	bdcd                	j	800053e0 <create+0x76>
    return 0;
    800054f0:	8aaa                	mv	s5,a0
    800054f2:	b5fd                	j	800053e0 <create+0x76>

00000000800054f4 <sys_dup>:
{
    800054f4:	7179                	addi	sp,sp,-48
    800054f6:	f406                	sd	ra,40(sp)
    800054f8:	f022                	sd	s0,32(sp)
    800054fa:	ec26                	sd	s1,24(sp)
    800054fc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054fe:	fd840613          	addi	a2,s0,-40
    80005502:	4581                	li	a1,0
    80005504:	4501                	li	a0,0
    80005506:	00000097          	auipc	ra,0x0
    8000550a:	dc2080e7          	jalr	-574(ra) # 800052c8 <argfd>
    return -1;
    8000550e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005510:	02054363          	bltz	a0,80005536 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005514:	fd843503          	ld	a0,-40(s0)
    80005518:	00000097          	auipc	ra,0x0
    8000551c:	e10080e7          	jalr	-496(ra) # 80005328 <fdalloc>
    80005520:	84aa                	mv	s1,a0
    return -1;
    80005522:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005524:	00054963          	bltz	a0,80005536 <sys_dup+0x42>
  filedup(f);
    80005528:	fd843503          	ld	a0,-40(s0)
    8000552c:	fffff097          	auipc	ra,0xfffff
    80005530:	2fe080e7          	jalr	766(ra) # 8000482a <filedup>
  return fd;
    80005534:	87a6                	mv	a5,s1
}
    80005536:	853e                	mv	a0,a5
    80005538:	70a2                	ld	ra,40(sp)
    8000553a:	7402                	ld	s0,32(sp)
    8000553c:	64e2                	ld	s1,24(sp)
    8000553e:	6145                	addi	sp,sp,48
    80005540:	8082                	ret

0000000080005542 <sys_read>:
{
    80005542:	7179                	addi	sp,sp,-48
    80005544:	f406                	sd	ra,40(sp)
    80005546:	f022                	sd	s0,32(sp)
    80005548:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000554a:	fd840593          	addi	a1,s0,-40
    8000554e:	4505                	li	a0,1
    80005550:	ffffe097          	auipc	ra,0xffffe
    80005554:	942080e7          	jalr	-1726(ra) # 80002e92 <argaddr>
  argint(2, &n);
    80005558:	fe440593          	addi	a1,s0,-28
    8000555c:	4509                	li	a0,2
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	914080e7          	jalr	-1772(ra) # 80002e72 <argint>
  if(argfd(0, 0, &f) < 0)
    80005566:	fe840613          	addi	a2,s0,-24
    8000556a:	4581                	li	a1,0
    8000556c:	4501                	li	a0,0
    8000556e:	00000097          	auipc	ra,0x0
    80005572:	d5a080e7          	jalr	-678(ra) # 800052c8 <argfd>
    80005576:	87aa                	mv	a5,a0
    return -1;
    80005578:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000557a:	0007cc63          	bltz	a5,80005592 <sys_read+0x50>
  return fileread(f, p, n);
    8000557e:	fe442603          	lw	a2,-28(s0)
    80005582:	fd843583          	ld	a1,-40(s0)
    80005586:	fe843503          	ld	a0,-24(s0)
    8000558a:	fffff097          	auipc	ra,0xfffff
    8000558e:	42c080e7          	jalr	1068(ra) # 800049b6 <fileread>
}
    80005592:	70a2                	ld	ra,40(sp)
    80005594:	7402                	ld	s0,32(sp)
    80005596:	6145                	addi	sp,sp,48
    80005598:	8082                	ret

000000008000559a <sys_write>:
{
    8000559a:	7179                	addi	sp,sp,-48
    8000559c:	f406                	sd	ra,40(sp)
    8000559e:	f022                	sd	s0,32(sp)
    800055a0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800055a2:	fd840593          	addi	a1,s0,-40
    800055a6:	4505                	li	a0,1
    800055a8:	ffffe097          	auipc	ra,0xffffe
    800055ac:	8ea080e7          	jalr	-1814(ra) # 80002e92 <argaddr>
  argint(2, &n);
    800055b0:	fe440593          	addi	a1,s0,-28
    800055b4:	4509                	li	a0,2
    800055b6:	ffffe097          	auipc	ra,0xffffe
    800055ba:	8bc080e7          	jalr	-1860(ra) # 80002e72 <argint>
  if(argfd(0, 0, &f) < 0)
    800055be:	fe840613          	addi	a2,s0,-24
    800055c2:	4581                	li	a1,0
    800055c4:	4501                	li	a0,0
    800055c6:	00000097          	auipc	ra,0x0
    800055ca:	d02080e7          	jalr	-766(ra) # 800052c8 <argfd>
    800055ce:	87aa                	mv	a5,a0
    return -1;
    800055d0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055d2:	0007cc63          	bltz	a5,800055ea <sys_write+0x50>
  return filewrite(f, p, n);
    800055d6:	fe442603          	lw	a2,-28(s0)
    800055da:	fd843583          	ld	a1,-40(s0)
    800055de:	fe843503          	ld	a0,-24(s0)
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	496080e7          	jalr	1174(ra) # 80004a78 <filewrite>
}
    800055ea:	70a2                	ld	ra,40(sp)
    800055ec:	7402                	ld	s0,32(sp)
    800055ee:	6145                	addi	sp,sp,48
    800055f0:	8082                	ret

00000000800055f2 <sys_close>:
{
    800055f2:	1101                	addi	sp,sp,-32
    800055f4:	ec06                	sd	ra,24(sp)
    800055f6:	e822                	sd	s0,16(sp)
    800055f8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055fa:	fe040613          	addi	a2,s0,-32
    800055fe:	fec40593          	addi	a1,s0,-20
    80005602:	4501                	li	a0,0
    80005604:	00000097          	auipc	ra,0x0
    80005608:	cc4080e7          	jalr	-828(ra) # 800052c8 <argfd>
    return -1;
    8000560c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000560e:	02054563          	bltz	a0,80005638 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005612:	ffffc097          	auipc	ra,0xffffc
    80005616:	36e080e7          	jalr	878(ra) # 80001980 <myproc>
    8000561a:	fec42783          	lw	a5,-20(s0)
    8000561e:	02078793          	addi	a5,a5,32
    80005622:	078e                	slli	a5,a5,0x3
    80005624:	97aa                	add	a5,a5,a0
    80005626:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000562a:	fe043503          	ld	a0,-32(s0)
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	24e080e7          	jalr	590(ra) # 8000487c <fileclose>
  return 0;
    80005636:	4781                	li	a5,0
}
    80005638:	853e                	mv	a0,a5
    8000563a:	60e2                	ld	ra,24(sp)
    8000563c:	6442                	ld	s0,16(sp)
    8000563e:	6105                	addi	sp,sp,32
    80005640:	8082                	ret

0000000080005642 <sys_fstat>:
{
    80005642:	1101                	addi	sp,sp,-32
    80005644:	ec06                	sd	ra,24(sp)
    80005646:	e822                	sd	s0,16(sp)
    80005648:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000564a:	fe040593          	addi	a1,s0,-32
    8000564e:	4505                	li	a0,1
    80005650:	ffffe097          	auipc	ra,0xffffe
    80005654:	842080e7          	jalr	-1982(ra) # 80002e92 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005658:	fe840613          	addi	a2,s0,-24
    8000565c:	4581                	li	a1,0
    8000565e:	4501                	li	a0,0
    80005660:	00000097          	auipc	ra,0x0
    80005664:	c68080e7          	jalr	-920(ra) # 800052c8 <argfd>
    80005668:	87aa                	mv	a5,a0
    return -1;
    8000566a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000566c:	0007ca63          	bltz	a5,80005680 <sys_fstat+0x3e>
  return filestat(f, st);
    80005670:	fe043583          	ld	a1,-32(s0)
    80005674:	fe843503          	ld	a0,-24(s0)
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	2cc080e7          	jalr	716(ra) # 80004944 <filestat>
}
    80005680:	60e2                	ld	ra,24(sp)
    80005682:	6442                	ld	s0,16(sp)
    80005684:	6105                	addi	sp,sp,32
    80005686:	8082                	ret

0000000080005688 <sys_link>:
{
    80005688:	7169                	addi	sp,sp,-304
    8000568a:	f606                	sd	ra,296(sp)
    8000568c:	f222                	sd	s0,288(sp)
    8000568e:	ee26                	sd	s1,280(sp)
    80005690:	ea4a                	sd	s2,272(sp)
    80005692:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005694:	08000613          	li	a2,128
    80005698:	ed040593          	addi	a1,s0,-304
    8000569c:	4501                	li	a0,0
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	814080e7          	jalr	-2028(ra) # 80002eb2 <argstr>
    return -1;
    800056a6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056a8:	10054e63          	bltz	a0,800057c4 <sys_link+0x13c>
    800056ac:	08000613          	li	a2,128
    800056b0:	f5040593          	addi	a1,s0,-176
    800056b4:	4505                	li	a0,1
    800056b6:	ffffd097          	auipc	ra,0xffffd
    800056ba:	7fc080e7          	jalr	2044(ra) # 80002eb2 <argstr>
    return -1;
    800056be:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056c0:	10054263          	bltz	a0,800057c4 <sys_link+0x13c>
  begin_op();
    800056c4:	fffff097          	auipc	ra,0xfffff
    800056c8:	cec080e7          	jalr	-788(ra) # 800043b0 <begin_op>
  if((ip = namei(old)) == 0){
    800056cc:	ed040513          	addi	a0,s0,-304
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	ac4080e7          	jalr	-1340(ra) # 80004194 <namei>
    800056d8:	84aa                	mv	s1,a0
    800056da:	c551                	beqz	a0,80005766 <sys_link+0xde>
  ilock(ip);
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	312080e7          	jalr	786(ra) # 800039ee <ilock>
  if(ip->type == T_DIR){
    800056e4:	04449703          	lh	a4,68(s1)
    800056e8:	4785                	li	a5,1
    800056ea:	08f70463          	beq	a4,a5,80005772 <sys_link+0xea>
  ip->nlink++;
    800056ee:	04a4d783          	lhu	a5,74(s1)
    800056f2:	2785                	addiw	a5,a5,1
    800056f4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056f8:	8526                	mv	a0,s1
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	22a080e7          	jalr	554(ra) # 80003924 <iupdate>
  iunlock(ip);
    80005702:	8526                	mv	a0,s1
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	3ac080e7          	jalr	940(ra) # 80003ab0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000570c:	fd040593          	addi	a1,s0,-48
    80005710:	f5040513          	addi	a0,s0,-176
    80005714:	fffff097          	auipc	ra,0xfffff
    80005718:	a9e080e7          	jalr	-1378(ra) # 800041b2 <nameiparent>
    8000571c:	892a                	mv	s2,a0
    8000571e:	c935                	beqz	a0,80005792 <sys_link+0x10a>
  ilock(dp);
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	2ce080e7          	jalr	718(ra) # 800039ee <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005728:	00092703          	lw	a4,0(s2)
    8000572c:	409c                	lw	a5,0(s1)
    8000572e:	04f71d63          	bne	a4,a5,80005788 <sys_link+0x100>
    80005732:	40d0                	lw	a2,4(s1)
    80005734:	fd040593          	addi	a1,s0,-48
    80005738:	854a                	mv	a0,s2
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	9a8080e7          	jalr	-1624(ra) # 800040e2 <dirlink>
    80005742:	04054363          	bltz	a0,80005788 <sys_link+0x100>
  iunlockput(dp);
    80005746:	854a                	mv	a0,s2
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	508080e7          	jalr	1288(ra) # 80003c50 <iunlockput>
  iput(ip);
    80005750:	8526                	mv	a0,s1
    80005752:	ffffe097          	auipc	ra,0xffffe
    80005756:	456080e7          	jalr	1110(ra) # 80003ba8 <iput>
  end_op();
    8000575a:	fffff097          	auipc	ra,0xfffff
    8000575e:	cd6080e7          	jalr	-810(ra) # 80004430 <end_op>
  return 0;
    80005762:	4781                	li	a5,0
    80005764:	a085                	j	800057c4 <sys_link+0x13c>
    end_op();
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	cca080e7          	jalr	-822(ra) # 80004430 <end_op>
    return -1;
    8000576e:	57fd                	li	a5,-1
    80005770:	a891                	j	800057c4 <sys_link+0x13c>
    iunlockput(ip);
    80005772:	8526                	mv	a0,s1
    80005774:	ffffe097          	auipc	ra,0xffffe
    80005778:	4dc080e7          	jalr	1244(ra) # 80003c50 <iunlockput>
    end_op();
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	cb4080e7          	jalr	-844(ra) # 80004430 <end_op>
    return -1;
    80005784:	57fd                	li	a5,-1
    80005786:	a83d                	j	800057c4 <sys_link+0x13c>
    iunlockput(dp);
    80005788:	854a                	mv	a0,s2
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	4c6080e7          	jalr	1222(ra) # 80003c50 <iunlockput>
  ilock(ip);
    80005792:	8526                	mv	a0,s1
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	25a080e7          	jalr	602(ra) # 800039ee <ilock>
  ip->nlink--;
    8000579c:	04a4d783          	lhu	a5,74(s1)
    800057a0:	37fd                	addiw	a5,a5,-1
    800057a2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057a6:	8526                	mv	a0,s1
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	17c080e7          	jalr	380(ra) # 80003924 <iupdate>
  iunlockput(ip);
    800057b0:	8526                	mv	a0,s1
    800057b2:	ffffe097          	auipc	ra,0xffffe
    800057b6:	49e080e7          	jalr	1182(ra) # 80003c50 <iunlockput>
  end_op();
    800057ba:	fffff097          	auipc	ra,0xfffff
    800057be:	c76080e7          	jalr	-906(ra) # 80004430 <end_op>
  return -1;
    800057c2:	57fd                	li	a5,-1
}
    800057c4:	853e                	mv	a0,a5
    800057c6:	70b2                	ld	ra,296(sp)
    800057c8:	7412                	ld	s0,288(sp)
    800057ca:	64f2                	ld	s1,280(sp)
    800057cc:	6952                	ld	s2,272(sp)
    800057ce:	6155                	addi	sp,sp,304
    800057d0:	8082                	ret

00000000800057d2 <sys_unlink>:
{
    800057d2:	7151                	addi	sp,sp,-240
    800057d4:	f586                	sd	ra,232(sp)
    800057d6:	f1a2                	sd	s0,224(sp)
    800057d8:	eda6                	sd	s1,216(sp)
    800057da:	e9ca                	sd	s2,208(sp)
    800057dc:	e5ce                	sd	s3,200(sp)
    800057de:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057e0:	08000613          	li	a2,128
    800057e4:	f3040593          	addi	a1,s0,-208
    800057e8:	4501                	li	a0,0
    800057ea:	ffffd097          	auipc	ra,0xffffd
    800057ee:	6c8080e7          	jalr	1736(ra) # 80002eb2 <argstr>
    800057f2:	18054163          	bltz	a0,80005974 <sys_unlink+0x1a2>
  begin_op();
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	bba080e7          	jalr	-1094(ra) # 800043b0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057fe:	fb040593          	addi	a1,s0,-80
    80005802:	f3040513          	addi	a0,s0,-208
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	9ac080e7          	jalr	-1620(ra) # 800041b2 <nameiparent>
    8000580e:	84aa                	mv	s1,a0
    80005810:	c979                	beqz	a0,800058e6 <sys_unlink+0x114>
  ilock(dp);
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	1dc080e7          	jalr	476(ra) # 800039ee <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000581a:	00003597          	auipc	a1,0x3
    8000581e:	f6e58593          	addi	a1,a1,-146 # 80008788 <syscalls+0x2a0>
    80005822:	fb040513          	addi	a0,s0,-80
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	692080e7          	jalr	1682(ra) # 80003eb8 <namecmp>
    8000582e:	14050a63          	beqz	a0,80005982 <sys_unlink+0x1b0>
    80005832:	00003597          	auipc	a1,0x3
    80005836:	f5e58593          	addi	a1,a1,-162 # 80008790 <syscalls+0x2a8>
    8000583a:	fb040513          	addi	a0,s0,-80
    8000583e:	ffffe097          	auipc	ra,0xffffe
    80005842:	67a080e7          	jalr	1658(ra) # 80003eb8 <namecmp>
    80005846:	12050e63          	beqz	a0,80005982 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000584a:	f2c40613          	addi	a2,s0,-212
    8000584e:	fb040593          	addi	a1,s0,-80
    80005852:	8526                	mv	a0,s1
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	67e080e7          	jalr	1662(ra) # 80003ed2 <dirlookup>
    8000585c:	892a                	mv	s2,a0
    8000585e:	12050263          	beqz	a0,80005982 <sys_unlink+0x1b0>
  ilock(ip);
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	18c080e7          	jalr	396(ra) # 800039ee <ilock>
  if(ip->nlink < 1)
    8000586a:	04a91783          	lh	a5,74(s2)
    8000586e:	08f05263          	blez	a5,800058f2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005872:	04491703          	lh	a4,68(s2)
    80005876:	4785                	li	a5,1
    80005878:	08f70563          	beq	a4,a5,80005902 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000587c:	4641                	li	a2,16
    8000587e:	4581                	li	a1,0
    80005880:	fc040513          	addi	a0,s0,-64
    80005884:	ffffb097          	auipc	ra,0xffffb
    80005888:	44e080e7          	jalr	1102(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000588c:	4741                	li	a4,16
    8000588e:	f2c42683          	lw	a3,-212(s0)
    80005892:	fc040613          	addi	a2,s0,-64
    80005896:	4581                	li	a1,0
    80005898:	8526                	mv	a0,s1
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	500080e7          	jalr	1280(ra) # 80003d9a <writei>
    800058a2:	47c1                	li	a5,16
    800058a4:	0af51563          	bne	a0,a5,8000594e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800058a8:	04491703          	lh	a4,68(s2)
    800058ac:	4785                	li	a5,1
    800058ae:	0af70863          	beq	a4,a5,8000595e <sys_unlink+0x18c>
  iunlockput(dp);
    800058b2:	8526                	mv	a0,s1
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	39c080e7          	jalr	924(ra) # 80003c50 <iunlockput>
  ip->nlink--;
    800058bc:	04a95783          	lhu	a5,74(s2)
    800058c0:	37fd                	addiw	a5,a5,-1
    800058c2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058c6:	854a                	mv	a0,s2
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	05c080e7          	jalr	92(ra) # 80003924 <iupdate>
  iunlockput(ip);
    800058d0:	854a                	mv	a0,s2
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	37e080e7          	jalr	894(ra) # 80003c50 <iunlockput>
  end_op();
    800058da:	fffff097          	auipc	ra,0xfffff
    800058de:	b56080e7          	jalr	-1194(ra) # 80004430 <end_op>
  return 0;
    800058e2:	4501                	li	a0,0
    800058e4:	a84d                	j	80005996 <sys_unlink+0x1c4>
    end_op();
    800058e6:	fffff097          	auipc	ra,0xfffff
    800058ea:	b4a080e7          	jalr	-1206(ra) # 80004430 <end_op>
    return -1;
    800058ee:	557d                	li	a0,-1
    800058f0:	a05d                	j	80005996 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800058f2:	00003517          	auipc	a0,0x3
    800058f6:	ea650513          	addi	a0,a0,-346 # 80008798 <syscalls+0x2b0>
    800058fa:	ffffb097          	auipc	ra,0xffffb
    800058fe:	c44080e7          	jalr	-956(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005902:	04c92703          	lw	a4,76(s2)
    80005906:	02000793          	li	a5,32
    8000590a:	f6e7f9e3          	bgeu	a5,a4,8000587c <sys_unlink+0xaa>
    8000590e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005912:	4741                	li	a4,16
    80005914:	86ce                	mv	a3,s3
    80005916:	f1840613          	addi	a2,s0,-232
    8000591a:	4581                	li	a1,0
    8000591c:	854a                	mv	a0,s2
    8000591e:	ffffe097          	auipc	ra,0xffffe
    80005922:	384080e7          	jalr	900(ra) # 80003ca2 <readi>
    80005926:	47c1                	li	a5,16
    80005928:	00f51b63          	bne	a0,a5,8000593e <sys_unlink+0x16c>
    if(de.inum != 0)
    8000592c:	f1845783          	lhu	a5,-232(s0)
    80005930:	e7a1                	bnez	a5,80005978 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005932:	29c1                	addiw	s3,s3,16
    80005934:	04c92783          	lw	a5,76(s2)
    80005938:	fcf9ede3          	bltu	s3,a5,80005912 <sys_unlink+0x140>
    8000593c:	b781                	j	8000587c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000593e:	00003517          	auipc	a0,0x3
    80005942:	e7250513          	addi	a0,a0,-398 # 800087b0 <syscalls+0x2c8>
    80005946:	ffffb097          	auipc	ra,0xffffb
    8000594a:	bf8080e7          	jalr	-1032(ra) # 8000053e <panic>
    panic("unlink: writei");
    8000594e:	00003517          	auipc	a0,0x3
    80005952:	e7a50513          	addi	a0,a0,-390 # 800087c8 <syscalls+0x2e0>
    80005956:	ffffb097          	auipc	ra,0xffffb
    8000595a:	be8080e7          	jalr	-1048(ra) # 8000053e <panic>
    dp->nlink--;
    8000595e:	04a4d783          	lhu	a5,74(s1)
    80005962:	37fd                	addiw	a5,a5,-1
    80005964:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005968:	8526                	mv	a0,s1
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	fba080e7          	jalr	-70(ra) # 80003924 <iupdate>
    80005972:	b781                	j	800058b2 <sys_unlink+0xe0>
    return -1;
    80005974:	557d                	li	a0,-1
    80005976:	a005                	j	80005996 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005978:	854a                	mv	a0,s2
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	2d6080e7          	jalr	726(ra) # 80003c50 <iunlockput>
  iunlockput(dp);
    80005982:	8526                	mv	a0,s1
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	2cc080e7          	jalr	716(ra) # 80003c50 <iunlockput>
  end_op();
    8000598c:	fffff097          	auipc	ra,0xfffff
    80005990:	aa4080e7          	jalr	-1372(ra) # 80004430 <end_op>
  return -1;
    80005994:	557d                	li	a0,-1
}
    80005996:	70ae                	ld	ra,232(sp)
    80005998:	740e                	ld	s0,224(sp)
    8000599a:	64ee                	ld	s1,216(sp)
    8000599c:	694e                	ld	s2,208(sp)
    8000599e:	69ae                	ld	s3,200(sp)
    800059a0:	616d                	addi	sp,sp,240
    800059a2:	8082                	ret

00000000800059a4 <sys_open>:

uint64
sys_open(void)
{
    800059a4:	7131                	addi	sp,sp,-192
    800059a6:	fd06                	sd	ra,184(sp)
    800059a8:	f922                	sd	s0,176(sp)
    800059aa:	f526                	sd	s1,168(sp)
    800059ac:	f14a                	sd	s2,160(sp)
    800059ae:	ed4e                	sd	s3,152(sp)
    800059b0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800059b2:	f4c40593          	addi	a1,s0,-180
    800059b6:	4505                	li	a0,1
    800059b8:	ffffd097          	auipc	ra,0xffffd
    800059bc:	4ba080e7          	jalr	1210(ra) # 80002e72 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059c0:	08000613          	li	a2,128
    800059c4:	f5040593          	addi	a1,s0,-176
    800059c8:	4501                	li	a0,0
    800059ca:	ffffd097          	auipc	ra,0xffffd
    800059ce:	4e8080e7          	jalr	1256(ra) # 80002eb2 <argstr>
    800059d2:	87aa                	mv	a5,a0
    return -1;
    800059d4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059d6:	0a07c963          	bltz	a5,80005a88 <sys_open+0xe4>

  begin_op();
    800059da:	fffff097          	auipc	ra,0xfffff
    800059de:	9d6080e7          	jalr	-1578(ra) # 800043b0 <begin_op>

  if(omode & O_CREATE){
    800059e2:	f4c42783          	lw	a5,-180(s0)
    800059e6:	2007f793          	andi	a5,a5,512
    800059ea:	cfc5                	beqz	a5,80005aa2 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800059ec:	4681                	li	a3,0
    800059ee:	4601                	li	a2,0
    800059f0:	4589                	li	a1,2
    800059f2:	f5040513          	addi	a0,s0,-176
    800059f6:	00000097          	auipc	ra,0x0
    800059fa:	974080e7          	jalr	-1676(ra) # 8000536a <create>
    800059fe:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a00:	c959                	beqz	a0,80005a96 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a02:	04449703          	lh	a4,68(s1)
    80005a06:	478d                	li	a5,3
    80005a08:	00f71763          	bne	a4,a5,80005a16 <sys_open+0x72>
    80005a0c:	0464d703          	lhu	a4,70(s1)
    80005a10:	47a5                	li	a5,9
    80005a12:	0ce7ed63          	bltu	a5,a4,80005aec <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a16:	fffff097          	auipc	ra,0xfffff
    80005a1a:	daa080e7          	jalr	-598(ra) # 800047c0 <filealloc>
    80005a1e:	89aa                	mv	s3,a0
    80005a20:	10050363          	beqz	a0,80005b26 <sys_open+0x182>
    80005a24:	00000097          	auipc	ra,0x0
    80005a28:	904080e7          	jalr	-1788(ra) # 80005328 <fdalloc>
    80005a2c:	892a                	mv	s2,a0
    80005a2e:	0e054763          	bltz	a0,80005b1c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a32:	04449703          	lh	a4,68(s1)
    80005a36:	478d                	li	a5,3
    80005a38:	0cf70563          	beq	a4,a5,80005b02 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a3c:	4789                	li	a5,2
    80005a3e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a42:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a46:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a4a:	f4c42783          	lw	a5,-180(s0)
    80005a4e:	0017c713          	xori	a4,a5,1
    80005a52:	8b05                	andi	a4,a4,1
    80005a54:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a58:	0037f713          	andi	a4,a5,3
    80005a5c:	00e03733          	snez	a4,a4
    80005a60:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a64:	4007f793          	andi	a5,a5,1024
    80005a68:	c791                	beqz	a5,80005a74 <sys_open+0xd0>
    80005a6a:	04449703          	lh	a4,68(s1)
    80005a6e:	4789                	li	a5,2
    80005a70:	0af70063          	beq	a4,a5,80005b10 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a74:	8526                	mv	a0,s1
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	03a080e7          	jalr	58(ra) # 80003ab0 <iunlock>
  end_op();
    80005a7e:	fffff097          	auipc	ra,0xfffff
    80005a82:	9b2080e7          	jalr	-1614(ra) # 80004430 <end_op>

  return fd;
    80005a86:	854a                	mv	a0,s2
}
    80005a88:	70ea                	ld	ra,184(sp)
    80005a8a:	744a                	ld	s0,176(sp)
    80005a8c:	74aa                	ld	s1,168(sp)
    80005a8e:	790a                	ld	s2,160(sp)
    80005a90:	69ea                	ld	s3,152(sp)
    80005a92:	6129                	addi	sp,sp,192
    80005a94:	8082                	ret
      end_op();
    80005a96:	fffff097          	auipc	ra,0xfffff
    80005a9a:	99a080e7          	jalr	-1638(ra) # 80004430 <end_op>
      return -1;
    80005a9e:	557d                	li	a0,-1
    80005aa0:	b7e5                	j	80005a88 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005aa2:	f5040513          	addi	a0,s0,-176
    80005aa6:	ffffe097          	auipc	ra,0xffffe
    80005aaa:	6ee080e7          	jalr	1774(ra) # 80004194 <namei>
    80005aae:	84aa                	mv	s1,a0
    80005ab0:	c905                	beqz	a0,80005ae0 <sys_open+0x13c>
    ilock(ip);
    80005ab2:	ffffe097          	auipc	ra,0xffffe
    80005ab6:	f3c080e7          	jalr	-196(ra) # 800039ee <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005aba:	04449703          	lh	a4,68(s1)
    80005abe:	4785                	li	a5,1
    80005ac0:	f4f711e3          	bne	a4,a5,80005a02 <sys_open+0x5e>
    80005ac4:	f4c42783          	lw	a5,-180(s0)
    80005ac8:	d7b9                	beqz	a5,80005a16 <sys_open+0x72>
      iunlockput(ip);
    80005aca:	8526                	mv	a0,s1
    80005acc:	ffffe097          	auipc	ra,0xffffe
    80005ad0:	184080e7          	jalr	388(ra) # 80003c50 <iunlockput>
      end_op();
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	95c080e7          	jalr	-1700(ra) # 80004430 <end_op>
      return -1;
    80005adc:	557d                	li	a0,-1
    80005ade:	b76d                	j	80005a88 <sys_open+0xe4>
      end_op();
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	950080e7          	jalr	-1712(ra) # 80004430 <end_op>
      return -1;
    80005ae8:	557d                	li	a0,-1
    80005aea:	bf79                	j	80005a88 <sys_open+0xe4>
    iunlockput(ip);
    80005aec:	8526                	mv	a0,s1
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	162080e7          	jalr	354(ra) # 80003c50 <iunlockput>
    end_op();
    80005af6:	fffff097          	auipc	ra,0xfffff
    80005afa:	93a080e7          	jalr	-1734(ra) # 80004430 <end_op>
    return -1;
    80005afe:	557d                	li	a0,-1
    80005b00:	b761                	j	80005a88 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b02:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b06:	04649783          	lh	a5,70(s1)
    80005b0a:	02f99223          	sh	a5,36(s3)
    80005b0e:	bf25                	j	80005a46 <sys_open+0xa2>
    itrunc(ip);
    80005b10:	8526                	mv	a0,s1
    80005b12:	ffffe097          	auipc	ra,0xffffe
    80005b16:	fea080e7          	jalr	-22(ra) # 80003afc <itrunc>
    80005b1a:	bfa9                	j	80005a74 <sys_open+0xd0>
      fileclose(f);
    80005b1c:	854e                	mv	a0,s3
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	d5e080e7          	jalr	-674(ra) # 8000487c <fileclose>
    iunlockput(ip);
    80005b26:	8526                	mv	a0,s1
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	128080e7          	jalr	296(ra) # 80003c50 <iunlockput>
    end_op();
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	900080e7          	jalr	-1792(ra) # 80004430 <end_op>
    return -1;
    80005b38:	557d                	li	a0,-1
    80005b3a:	b7b9                	j	80005a88 <sys_open+0xe4>

0000000080005b3c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b3c:	7175                	addi	sp,sp,-144
    80005b3e:	e506                	sd	ra,136(sp)
    80005b40:	e122                	sd	s0,128(sp)
    80005b42:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b44:	fffff097          	auipc	ra,0xfffff
    80005b48:	86c080e7          	jalr	-1940(ra) # 800043b0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b4c:	08000613          	li	a2,128
    80005b50:	f7040593          	addi	a1,s0,-144
    80005b54:	4501                	li	a0,0
    80005b56:	ffffd097          	auipc	ra,0xffffd
    80005b5a:	35c080e7          	jalr	860(ra) # 80002eb2 <argstr>
    80005b5e:	02054963          	bltz	a0,80005b90 <sys_mkdir+0x54>
    80005b62:	4681                	li	a3,0
    80005b64:	4601                	li	a2,0
    80005b66:	4585                	li	a1,1
    80005b68:	f7040513          	addi	a0,s0,-144
    80005b6c:	fffff097          	auipc	ra,0xfffff
    80005b70:	7fe080e7          	jalr	2046(ra) # 8000536a <create>
    80005b74:	cd11                	beqz	a0,80005b90 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	0da080e7          	jalr	218(ra) # 80003c50 <iunlockput>
  end_op();
    80005b7e:	fffff097          	auipc	ra,0xfffff
    80005b82:	8b2080e7          	jalr	-1870(ra) # 80004430 <end_op>
  return 0;
    80005b86:	4501                	li	a0,0
}
    80005b88:	60aa                	ld	ra,136(sp)
    80005b8a:	640a                	ld	s0,128(sp)
    80005b8c:	6149                	addi	sp,sp,144
    80005b8e:	8082                	ret
    end_op();
    80005b90:	fffff097          	auipc	ra,0xfffff
    80005b94:	8a0080e7          	jalr	-1888(ra) # 80004430 <end_op>
    return -1;
    80005b98:	557d                	li	a0,-1
    80005b9a:	b7fd                	j	80005b88 <sys_mkdir+0x4c>

0000000080005b9c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b9c:	7135                	addi	sp,sp,-160
    80005b9e:	ed06                	sd	ra,152(sp)
    80005ba0:	e922                	sd	s0,144(sp)
    80005ba2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ba4:	fffff097          	auipc	ra,0xfffff
    80005ba8:	80c080e7          	jalr	-2036(ra) # 800043b0 <begin_op>
  argint(1, &major);
    80005bac:	f6c40593          	addi	a1,s0,-148
    80005bb0:	4505                	li	a0,1
    80005bb2:	ffffd097          	auipc	ra,0xffffd
    80005bb6:	2c0080e7          	jalr	704(ra) # 80002e72 <argint>
  argint(2, &minor);
    80005bba:	f6840593          	addi	a1,s0,-152
    80005bbe:	4509                	li	a0,2
    80005bc0:	ffffd097          	auipc	ra,0xffffd
    80005bc4:	2b2080e7          	jalr	690(ra) # 80002e72 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bc8:	08000613          	li	a2,128
    80005bcc:	f7040593          	addi	a1,s0,-144
    80005bd0:	4501                	li	a0,0
    80005bd2:	ffffd097          	auipc	ra,0xffffd
    80005bd6:	2e0080e7          	jalr	736(ra) # 80002eb2 <argstr>
    80005bda:	02054b63          	bltz	a0,80005c10 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005bde:	f6841683          	lh	a3,-152(s0)
    80005be2:	f6c41603          	lh	a2,-148(s0)
    80005be6:	458d                	li	a1,3
    80005be8:	f7040513          	addi	a0,s0,-144
    80005bec:	fffff097          	auipc	ra,0xfffff
    80005bf0:	77e080e7          	jalr	1918(ra) # 8000536a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bf4:	cd11                	beqz	a0,80005c10 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bf6:	ffffe097          	auipc	ra,0xffffe
    80005bfa:	05a080e7          	jalr	90(ra) # 80003c50 <iunlockput>
  end_op();
    80005bfe:	fffff097          	auipc	ra,0xfffff
    80005c02:	832080e7          	jalr	-1998(ra) # 80004430 <end_op>
  return 0;
    80005c06:	4501                	li	a0,0
}
    80005c08:	60ea                	ld	ra,152(sp)
    80005c0a:	644a                	ld	s0,144(sp)
    80005c0c:	610d                	addi	sp,sp,160
    80005c0e:	8082                	ret
    end_op();
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	820080e7          	jalr	-2016(ra) # 80004430 <end_op>
    return -1;
    80005c18:	557d                	li	a0,-1
    80005c1a:	b7fd                	j	80005c08 <sys_mknod+0x6c>

0000000080005c1c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c1c:	7135                	addi	sp,sp,-160
    80005c1e:	ed06                	sd	ra,152(sp)
    80005c20:	e922                	sd	s0,144(sp)
    80005c22:	e526                	sd	s1,136(sp)
    80005c24:	e14a                	sd	s2,128(sp)
    80005c26:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c28:	ffffc097          	auipc	ra,0xffffc
    80005c2c:	d58080e7          	jalr	-680(ra) # 80001980 <myproc>
    80005c30:	892a                	mv	s2,a0
  
  begin_op();
    80005c32:	ffffe097          	auipc	ra,0xffffe
    80005c36:	77e080e7          	jalr	1918(ra) # 800043b0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c3a:	08000613          	li	a2,128
    80005c3e:	f6040593          	addi	a1,s0,-160
    80005c42:	4501                	li	a0,0
    80005c44:	ffffd097          	auipc	ra,0xffffd
    80005c48:	26e080e7          	jalr	622(ra) # 80002eb2 <argstr>
    80005c4c:	04054b63          	bltz	a0,80005ca2 <sys_chdir+0x86>
    80005c50:	f6040513          	addi	a0,s0,-160
    80005c54:	ffffe097          	auipc	ra,0xffffe
    80005c58:	540080e7          	jalr	1344(ra) # 80004194 <namei>
    80005c5c:	84aa                	mv	s1,a0
    80005c5e:	c131                	beqz	a0,80005ca2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c60:	ffffe097          	auipc	ra,0xffffe
    80005c64:	d8e080e7          	jalr	-626(ra) # 800039ee <ilock>
  if(ip->type != T_DIR){
    80005c68:	04449703          	lh	a4,68(s1)
    80005c6c:	4785                	li	a5,1
    80005c6e:	04f71063          	bne	a4,a5,80005cae <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c72:	8526                	mv	a0,s1
    80005c74:	ffffe097          	auipc	ra,0xffffe
    80005c78:	e3c080e7          	jalr	-452(ra) # 80003ab0 <iunlock>
  iput(p->cwd);
    80005c7c:	18893503          	ld	a0,392(s2)
    80005c80:	ffffe097          	auipc	ra,0xffffe
    80005c84:	f28080e7          	jalr	-216(ra) # 80003ba8 <iput>
  end_op();
    80005c88:	ffffe097          	auipc	ra,0xffffe
    80005c8c:	7a8080e7          	jalr	1960(ra) # 80004430 <end_op>
  p->cwd = ip;
    80005c90:	18993423          	sd	s1,392(s2)
  return 0;
    80005c94:	4501                	li	a0,0
}
    80005c96:	60ea                	ld	ra,152(sp)
    80005c98:	644a                	ld	s0,144(sp)
    80005c9a:	64aa                	ld	s1,136(sp)
    80005c9c:	690a                	ld	s2,128(sp)
    80005c9e:	610d                	addi	sp,sp,160
    80005ca0:	8082                	ret
    end_op();
    80005ca2:	ffffe097          	auipc	ra,0xffffe
    80005ca6:	78e080e7          	jalr	1934(ra) # 80004430 <end_op>
    return -1;
    80005caa:	557d                	li	a0,-1
    80005cac:	b7ed                	j	80005c96 <sys_chdir+0x7a>
    iunlockput(ip);
    80005cae:	8526                	mv	a0,s1
    80005cb0:	ffffe097          	auipc	ra,0xffffe
    80005cb4:	fa0080e7          	jalr	-96(ra) # 80003c50 <iunlockput>
    end_op();
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	778080e7          	jalr	1912(ra) # 80004430 <end_op>
    return -1;
    80005cc0:	557d                	li	a0,-1
    80005cc2:	bfd1                	j	80005c96 <sys_chdir+0x7a>

0000000080005cc4 <sys_exec>:

uint64
sys_exec(void)
{
    80005cc4:	7145                	addi	sp,sp,-464
    80005cc6:	e786                	sd	ra,456(sp)
    80005cc8:	e3a2                	sd	s0,448(sp)
    80005cca:	ff26                	sd	s1,440(sp)
    80005ccc:	fb4a                	sd	s2,432(sp)
    80005cce:	f74e                	sd	s3,424(sp)
    80005cd0:	f352                	sd	s4,416(sp)
    80005cd2:	ef56                	sd	s5,408(sp)
    80005cd4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cd6:	e3840593          	addi	a1,s0,-456
    80005cda:	4505                	li	a0,1
    80005cdc:	ffffd097          	auipc	ra,0xffffd
    80005ce0:	1b6080e7          	jalr	438(ra) # 80002e92 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ce4:	08000613          	li	a2,128
    80005ce8:	f4040593          	addi	a1,s0,-192
    80005cec:	4501                	li	a0,0
    80005cee:	ffffd097          	auipc	ra,0xffffd
    80005cf2:	1c4080e7          	jalr	452(ra) # 80002eb2 <argstr>
    80005cf6:	87aa                	mv	a5,a0
    return -1;
    80005cf8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005cfa:	0c07c263          	bltz	a5,80005dbe <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005cfe:	10000613          	li	a2,256
    80005d02:	4581                	li	a1,0
    80005d04:	e4040513          	addi	a0,s0,-448
    80005d08:	ffffb097          	auipc	ra,0xffffb
    80005d0c:	fca080e7          	jalr	-54(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d10:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d14:	89a6                	mv	s3,s1
    80005d16:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d18:	02000a13          	li	s4,32
    80005d1c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d20:	00391793          	slli	a5,s2,0x3
    80005d24:	e3040593          	addi	a1,s0,-464
    80005d28:	e3843503          	ld	a0,-456(s0)
    80005d2c:	953e                	add	a0,a0,a5
    80005d2e:	ffffd097          	auipc	ra,0xffffd
    80005d32:	0a2080e7          	jalr	162(ra) # 80002dd0 <fetchaddr>
    80005d36:	02054a63          	bltz	a0,80005d6a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005d3a:	e3043783          	ld	a5,-464(s0)
    80005d3e:	c3b9                	beqz	a5,80005d84 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d40:	ffffb097          	auipc	ra,0xffffb
    80005d44:	da6080e7          	jalr	-602(ra) # 80000ae6 <kalloc>
    80005d48:	85aa                	mv	a1,a0
    80005d4a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d4e:	cd11                	beqz	a0,80005d6a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d50:	6605                	lui	a2,0x1
    80005d52:	e3043503          	ld	a0,-464(s0)
    80005d56:	ffffd097          	auipc	ra,0xffffd
    80005d5a:	0ce080e7          	jalr	206(ra) # 80002e24 <fetchstr>
    80005d5e:	00054663          	bltz	a0,80005d6a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005d62:	0905                	addi	s2,s2,1
    80005d64:	09a1                	addi	s3,s3,8
    80005d66:	fb491be3          	bne	s2,s4,80005d1c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d6a:	10048913          	addi	s2,s1,256
    80005d6e:	6088                	ld	a0,0(s1)
    80005d70:	c531                	beqz	a0,80005dbc <sys_exec+0xf8>
    kfree(argv[i]);
    80005d72:	ffffb097          	auipc	ra,0xffffb
    80005d76:	c78080e7          	jalr	-904(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d7a:	04a1                	addi	s1,s1,8
    80005d7c:	ff2499e3          	bne	s1,s2,80005d6e <sys_exec+0xaa>
  return -1;
    80005d80:	557d                	li	a0,-1
    80005d82:	a835                	j	80005dbe <sys_exec+0xfa>
      argv[i] = 0;
    80005d84:	0a8e                	slli	s5,s5,0x3
    80005d86:	fc040793          	addi	a5,s0,-64
    80005d8a:	9abe                	add	s5,s5,a5
    80005d8c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d90:	e4040593          	addi	a1,s0,-448
    80005d94:	f4040513          	addi	a0,s0,-192
    80005d98:	fffff097          	auipc	ra,0xfffff
    80005d9c:	15e080e7          	jalr	350(ra) # 80004ef6 <exec>
    80005da0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005da2:	10048993          	addi	s3,s1,256
    80005da6:	6088                	ld	a0,0(s1)
    80005da8:	c901                	beqz	a0,80005db8 <sys_exec+0xf4>
    kfree(argv[i]);
    80005daa:	ffffb097          	auipc	ra,0xffffb
    80005dae:	c40080e7          	jalr	-960(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005db2:	04a1                	addi	s1,s1,8
    80005db4:	ff3499e3          	bne	s1,s3,80005da6 <sys_exec+0xe2>
  return ret;
    80005db8:	854a                	mv	a0,s2
    80005dba:	a011                	j	80005dbe <sys_exec+0xfa>
  return -1;
    80005dbc:	557d                	li	a0,-1
}
    80005dbe:	60be                	ld	ra,456(sp)
    80005dc0:	641e                	ld	s0,448(sp)
    80005dc2:	74fa                	ld	s1,440(sp)
    80005dc4:	795a                	ld	s2,432(sp)
    80005dc6:	79ba                	ld	s3,424(sp)
    80005dc8:	7a1a                	ld	s4,416(sp)
    80005dca:	6afa                	ld	s5,408(sp)
    80005dcc:	6179                	addi	sp,sp,464
    80005dce:	8082                	ret

0000000080005dd0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005dd0:	7139                	addi	sp,sp,-64
    80005dd2:	fc06                	sd	ra,56(sp)
    80005dd4:	f822                	sd	s0,48(sp)
    80005dd6:	f426                	sd	s1,40(sp)
    80005dd8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dda:	ffffc097          	auipc	ra,0xffffc
    80005dde:	ba6080e7          	jalr	-1114(ra) # 80001980 <myproc>
    80005de2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005de4:	fd840593          	addi	a1,s0,-40
    80005de8:	4501                	li	a0,0
    80005dea:	ffffd097          	auipc	ra,0xffffd
    80005dee:	0a8080e7          	jalr	168(ra) # 80002e92 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005df2:	fc840593          	addi	a1,s0,-56
    80005df6:	fd040513          	addi	a0,s0,-48
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	db2080e7          	jalr	-590(ra) # 80004bac <pipealloc>
    return -1;
    80005e02:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e04:	0c054963          	bltz	a0,80005ed6 <sys_pipe+0x106>
  fd0 = -1;
    80005e08:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e0c:	fd043503          	ld	a0,-48(s0)
    80005e10:	fffff097          	auipc	ra,0xfffff
    80005e14:	518080e7          	jalr	1304(ra) # 80005328 <fdalloc>
    80005e18:	fca42223          	sw	a0,-60(s0)
    80005e1c:	0a054063          	bltz	a0,80005ebc <sys_pipe+0xec>
    80005e20:	fc843503          	ld	a0,-56(s0)
    80005e24:	fffff097          	auipc	ra,0xfffff
    80005e28:	504080e7          	jalr	1284(ra) # 80005328 <fdalloc>
    80005e2c:	fca42023          	sw	a0,-64(s0)
    80005e30:	06054c63          	bltz	a0,80005ea8 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e34:	4691                	li	a3,4
    80005e36:	fc440613          	addi	a2,s0,-60
    80005e3a:	fd843583          	ld	a1,-40(s0)
    80005e3e:	1004b503          	ld	a0,256(s1)
    80005e42:	ffffc097          	auipc	ra,0xffffc
    80005e46:	826080e7          	jalr	-2010(ra) # 80001668 <copyout>
    80005e4a:	02054163          	bltz	a0,80005e6c <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e4e:	4691                	li	a3,4
    80005e50:	fc040613          	addi	a2,s0,-64
    80005e54:	fd843583          	ld	a1,-40(s0)
    80005e58:	0591                	addi	a1,a1,4
    80005e5a:	1004b503          	ld	a0,256(s1)
    80005e5e:	ffffc097          	auipc	ra,0xffffc
    80005e62:	80a080e7          	jalr	-2038(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e66:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e68:	06055763          	bgez	a0,80005ed6 <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80005e6c:	fc442783          	lw	a5,-60(s0)
    80005e70:	02078793          	addi	a5,a5,32
    80005e74:	078e                	slli	a5,a5,0x3
    80005e76:	97a6                	add	a5,a5,s1
    80005e78:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e7c:	fc042503          	lw	a0,-64(s0)
    80005e80:	02050513          	addi	a0,a0,32
    80005e84:	050e                	slli	a0,a0,0x3
    80005e86:	94aa                	add	s1,s1,a0
    80005e88:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e8c:	fd043503          	ld	a0,-48(s0)
    80005e90:	fffff097          	auipc	ra,0xfffff
    80005e94:	9ec080e7          	jalr	-1556(ra) # 8000487c <fileclose>
    fileclose(wf);
    80005e98:	fc843503          	ld	a0,-56(s0)
    80005e9c:	fffff097          	auipc	ra,0xfffff
    80005ea0:	9e0080e7          	jalr	-1568(ra) # 8000487c <fileclose>
    return -1;
    80005ea4:	57fd                	li	a5,-1
    80005ea6:	a805                	j	80005ed6 <sys_pipe+0x106>
    if(fd0 >= 0)
    80005ea8:	fc442783          	lw	a5,-60(s0)
    80005eac:	0007c863          	bltz	a5,80005ebc <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80005eb0:	02078793          	addi	a5,a5,32
    80005eb4:	078e                	slli	a5,a5,0x3
    80005eb6:	94be                	add	s1,s1,a5
    80005eb8:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005ebc:	fd043503          	ld	a0,-48(s0)
    80005ec0:	fffff097          	auipc	ra,0xfffff
    80005ec4:	9bc080e7          	jalr	-1604(ra) # 8000487c <fileclose>
    fileclose(wf);
    80005ec8:	fc843503          	ld	a0,-56(s0)
    80005ecc:	fffff097          	auipc	ra,0xfffff
    80005ed0:	9b0080e7          	jalr	-1616(ra) # 8000487c <fileclose>
    return -1;
    80005ed4:	57fd                	li	a5,-1
}
    80005ed6:	853e                	mv	a0,a5
    80005ed8:	70e2                	ld	ra,56(sp)
    80005eda:	7442                	ld	s0,48(sp)
    80005edc:	74a2                	ld	s1,40(sp)
    80005ede:	6121                	addi	sp,sp,64
    80005ee0:	8082                	ret
	...

0000000080005ef0 <kernelvec>:
    80005ef0:	7111                	addi	sp,sp,-256
    80005ef2:	e006                	sd	ra,0(sp)
    80005ef4:	e40a                	sd	sp,8(sp)
    80005ef6:	e80e                	sd	gp,16(sp)
    80005ef8:	ec12                	sd	tp,24(sp)
    80005efa:	f016                	sd	t0,32(sp)
    80005efc:	f41a                	sd	t1,40(sp)
    80005efe:	f81e                	sd	t2,48(sp)
    80005f00:	fc22                	sd	s0,56(sp)
    80005f02:	e0a6                	sd	s1,64(sp)
    80005f04:	e4aa                	sd	a0,72(sp)
    80005f06:	e8ae                	sd	a1,80(sp)
    80005f08:	ecb2                	sd	a2,88(sp)
    80005f0a:	f0b6                	sd	a3,96(sp)
    80005f0c:	f4ba                	sd	a4,104(sp)
    80005f0e:	f8be                	sd	a5,112(sp)
    80005f10:	fcc2                	sd	a6,120(sp)
    80005f12:	e146                	sd	a7,128(sp)
    80005f14:	e54a                	sd	s2,136(sp)
    80005f16:	e94e                	sd	s3,144(sp)
    80005f18:	ed52                	sd	s4,152(sp)
    80005f1a:	f156                	sd	s5,160(sp)
    80005f1c:	f55a                	sd	s6,168(sp)
    80005f1e:	f95e                	sd	s7,176(sp)
    80005f20:	fd62                	sd	s8,184(sp)
    80005f22:	e1e6                	sd	s9,192(sp)
    80005f24:	e5ea                	sd	s10,200(sp)
    80005f26:	e9ee                	sd	s11,208(sp)
    80005f28:	edf2                	sd	t3,216(sp)
    80005f2a:	f1f6                	sd	t4,224(sp)
    80005f2c:	f5fa                	sd	t5,232(sp)
    80005f2e:	f9fe                	sd	t6,240(sp)
    80005f30:	d6dfc0ef          	jal	ra,80002c9c <kerneltrap>
    80005f34:	6082                	ld	ra,0(sp)
    80005f36:	6122                	ld	sp,8(sp)
    80005f38:	61c2                	ld	gp,16(sp)
    80005f3a:	7282                	ld	t0,32(sp)
    80005f3c:	7322                	ld	t1,40(sp)
    80005f3e:	73c2                	ld	t2,48(sp)
    80005f40:	7462                	ld	s0,56(sp)
    80005f42:	6486                	ld	s1,64(sp)
    80005f44:	6526                	ld	a0,72(sp)
    80005f46:	65c6                	ld	a1,80(sp)
    80005f48:	6666                	ld	a2,88(sp)
    80005f4a:	7686                	ld	a3,96(sp)
    80005f4c:	7726                	ld	a4,104(sp)
    80005f4e:	77c6                	ld	a5,112(sp)
    80005f50:	7866                	ld	a6,120(sp)
    80005f52:	688a                	ld	a7,128(sp)
    80005f54:	692a                	ld	s2,136(sp)
    80005f56:	69ca                	ld	s3,144(sp)
    80005f58:	6a6a                	ld	s4,152(sp)
    80005f5a:	7a8a                	ld	s5,160(sp)
    80005f5c:	7b2a                	ld	s6,168(sp)
    80005f5e:	7bca                	ld	s7,176(sp)
    80005f60:	7c6a                	ld	s8,184(sp)
    80005f62:	6c8e                	ld	s9,192(sp)
    80005f64:	6d2e                	ld	s10,200(sp)
    80005f66:	6dce                	ld	s11,208(sp)
    80005f68:	6e6e                	ld	t3,216(sp)
    80005f6a:	7e8e                	ld	t4,224(sp)
    80005f6c:	7f2e                	ld	t5,232(sp)
    80005f6e:	7fce                	ld	t6,240(sp)
    80005f70:	6111                	addi	sp,sp,256
    80005f72:	10200073          	sret
    80005f76:	00000013          	nop
    80005f7a:	00000013          	nop
    80005f7e:	0001                	nop

0000000080005f80 <timervec>:
    80005f80:	34051573          	csrrw	a0,mscratch,a0
    80005f84:	e10c                	sd	a1,0(a0)
    80005f86:	e510                	sd	a2,8(a0)
    80005f88:	e914                	sd	a3,16(a0)
    80005f8a:	6d0c                	ld	a1,24(a0)
    80005f8c:	7110                	ld	a2,32(a0)
    80005f8e:	6194                	ld	a3,0(a1)
    80005f90:	96b2                	add	a3,a3,a2
    80005f92:	e194                	sd	a3,0(a1)
    80005f94:	4589                	li	a1,2
    80005f96:	14459073          	csrw	sip,a1
    80005f9a:	6914                	ld	a3,16(a0)
    80005f9c:	6510                	ld	a2,8(a0)
    80005f9e:	610c                	ld	a1,0(a0)
    80005fa0:	34051573          	csrrw	a0,mscratch,a0
    80005fa4:	30200073          	mret
	...

0000000080005faa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005faa:	1141                	addi	sp,sp,-16
    80005fac:	e422                	sd	s0,8(sp)
    80005fae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fb0:	0c0007b7          	lui	a5,0xc000
    80005fb4:	4705                	li	a4,1
    80005fb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fb8:	c3d8                	sw	a4,4(a5)
}
    80005fba:	6422                	ld	s0,8(sp)
    80005fbc:	0141                	addi	sp,sp,16
    80005fbe:	8082                	ret

0000000080005fc0 <plicinithart>:

void
plicinithart(void)
{
    80005fc0:	1141                	addi	sp,sp,-16
    80005fc2:	e406                	sd	ra,8(sp)
    80005fc4:	e022                	sd	s0,0(sp)
    80005fc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fc8:	ffffc097          	auipc	ra,0xffffc
    80005fcc:	98c080e7          	jalr	-1652(ra) # 80001954 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fd0:	0085171b          	slliw	a4,a0,0x8
    80005fd4:	0c0027b7          	lui	a5,0xc002
    80005fd8:	97ba                	add	a5,a5,a4
    80005fda:	40200713          	li	a4,1026
    80005fde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fe2:	00d5151b          	slliw	a0,a0,0xd
    80005fe6:	0c2017b7          	lui	a5,0xc201
    80005fea:	953e                	add	a0,a0,a5
    80005fec:	00052023          	sw	zero,0(a0)
}
    80005ff0:	60a2                	ld	ra,8(sp)
    80005ff2:	6402                	ld	s0,0(sp)
    80005ff4:	0141                	addi	sp,sp,16
    80005ff6:	8082                	ret

0000000080005ff8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ff8:	1141                	addi	sp,sp,-16
    80005ffa:	e406                	sd	ra,8(sp)
    80005ffc:	e022                	sd	s0,0(sp)
    80005ffe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006000:	ffffc097          	auipc	ra,0xffffc
    80006004:	954080e7          	jalr	-1708(ra) # 80001954 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006008:	00d5179b          	slliw	a5,a0,0xd
    8000600c:	0c201537          	lui	a0,0xc201
    80006010:	953e                	add	a0,a0,a5
  return irq;
}
    80006012:	4148                	lw	a0,4(a0)
    80006014:	60a2                	ld	ra,8(sp)
    80006016:	6402                	ld	s0,0(sp)
    80006018:	0141                	addi	sp,sp,16
    8000601a:	8082                	ret

000000008000601c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000601c:	1101                	addi	sp,sp,-32
    8000601e:	ec06                	sd	ra,24(sp)
    80006020:	e822                	sd	s0,16(sp)
    80006022:	e426                	sd	s1,8(sp)
    80006024:	1000                	addi	s0,sp,32
    80006026:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006028:	ffffc097          	auipc	ra,0xffffc
    8000602c:	92c080e7          	jalr	-1748(ra) # 80001954 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006030:	00d5151b          	slliw	a0,a0,0xd
    80006034:	0c2017b7          	lui	a5,0xc201
    80006038:	97aa                	add	a5,a5,a0
    8000603a:	c3c4                	sw	s1,4(a5)
}
    8000603c:	60e2                	ld	ra,24(sp)
    8000603e:	6442                	ld	s0,16(sp)
    80006040:	64a2                	ld	s1,8(sp)
    80006042:	6105                	addi	sp,sp,32
    80006044:	8082                	ret

0000000080006046 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006046:	1141                	addi	sp,sp,-16
    80006048:	e406                	sd	ra,8(sp)
    8000604a:	e022                	sd	s0,0(sp)
    8000604c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000604e:	479d                	li	a5,7
    80006050:	04a7cc63          	blt	a5,a0,800060a8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006054:	0001d797          	auipc	a5,0x1d
    80006058:	26c78793          	addi	a5,a5,620 # 800232c0 <disk>
    8000605c:	97aa                	add	a5,a5,a0
    8000605e:	0187c783          	lbu	a5,24(a5)
    80006062:	ebb9                	bnez	a5,800060b8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006064:	00451613          	slli	a2,a0,0x4
    80006068:	0001d797          	auipc	a5,0x1d
    8000606c:	25878793          	addi	a5,a5,600 # 800232c0 <disk>
    80006070:	6394                	ld	a3,0(a5)
    80006072:	96b2                	add	a3,a3,a2
    80006074:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006078:	6398                	ld	a4,0(a5)
    8000607a:	9732                	add	a4,a4,a2
    8000607c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006080:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006084:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006088:	953e                	add	a0,a0,a5
    8000608a:	4785                	li	a5,1
    8000608c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006090:	0001d517          	auipc	a0,0x1d
    80006094:	24850513          	addi	a0,a0,584 # 800232d8 <disk+0x18>
    80006098:	ffffc097          	auipc	ra,0xffffc
    8000609c:	116080e7          	jalr	278(ra) # 800021ae <wakeup>
}
    800060a0:	60a2                	ld	ra,8(sp)
    800060a2:	6402                	ld	s0,0(sp)
    800060a4:	0141                	addi	sp,sp,16
    800060a6:	8082                	ret
    panic("free_desc 1");
    800060a8:	00002517          	auipc	a0,0x2
    800060ac:	73050513          	addi	a0,a0,1840 # 800087d8 <syscalls+0x2f0>
    800060b0:	ffffa097          	auipc	ra,0xffffa
    800060b4:	48e080e7          	jalr	1166(ra) # 8000053e <panic>
    panic("free_desc 2");
    800060b8:	00002517          	auipc	a0,0x2
    800060bc:	73050513          	addi	a0,a0,1840 # 800087e8 <syscalls+0x300>
    800060c0:	ffffa097          	auipc	ra,0xffffa
    800060c4:	47e080e7          	jalr	1150(ra) # 8000053e <panic>

00000000800060c8 <virtio_disk_init>:
{
    800060c8:	1101                	addi	sp,sp,-32
    800060ca:	ec06                	sd	ra,24(sp)
    800060cc:	e822                	sd	s0,16(sp)
    800060ce:	e426                	sd	s1,8(sp)
    800060d0:	e04a                	sd	s2,0(sp)
    800060d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060d4:	00002597          	auipc	a1,0x2
    800060d8:	72458593          	addi	a1,a1,1828 # 800087f8 <syscalls+0x310>
    800060dc:	0001d517          	auipc	a0,0x1d
    800060e0:	30c50513          	addi	a0,a0,780 # 800233e8 <disk+0x128>
    800060e4:	ffffb097          	auipc	ra,0xffffb
    800060e8:	a62080e7          	jalr	-1438(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060ec:	100017b7          	lui	a5,0x10001
    800060f0:	4398                	lw	a4,0(a5)
    800060f2:	2701                	sext.w	a4,a4
    800060f4:	747277b7          	lui	a5,0x74727
    800060f8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060fc:	14f71c63          	bne	a4,a5,80006254 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006100:	100017b7          	lui	a5,0x10001
    80006104:	43dc                	lw	a5,4(a5)
    80006106:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006108:	4709                	li	a4,2
    8000610a:	14e79563          	bne	a5,a4,80006254 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000610e:	100017b7          	lui	a5,0x10001
    80006112:	479c                	lw	a5,8(a5)
    80006114:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006116:	12e79f63          	bne	a5,a4,80006254 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000611a:	100017b7          	lui	a5,0x10001
    8000611e:	47d8                	lw	a4,12(a5)
    80006120:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006122:	554d47b7          	lui	a5,0x554d4
    80006126:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000612a:	12f71563          	bne	a4,a5,80006254 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000612e:	100017b7          	lui	a5,0x10001
    80006132:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006136:	4705                	li	a4,1
    80006138:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000613a:	470d                	li	a4,3
    8000613c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000613e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006140:	c7ffe737          	lui	a4,0xc7ffe
    80006144:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb35f>
    80006148:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000614a:	2701                	sext.w	a4,a4
    8000614c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000614e:	472d                	li	a4,11
    80006150:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006152:	5bbc                	lw	a5,112(a5)
    80006154:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006158:	8ba1                	andi	a5,a5,8
    8000615a:	10078563          	beqz	a5,80006264 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000615e:	100017b7          	lui	a5,0x10001
    80006162:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006166:	43fc                	lw	a5,68(a5)
    80006168:	2781                	sext.w	a5,a5
    8000616a:	10079563          	bnez	a5,80006274 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000616e:	100017b7          	lui	a5,0x10001
    80006172:	5bdc                	lw	a5,52(a5)
    80006174:	2781                	sext.w	a5,a5
  if(max == 0)
    80006176:	10078763          	beqz	a5,80006284 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000617a:	471d                	li	a4,7
    8000617c:	10f77c63          	bgeu	a4,a5,80006294 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006180:	ffffb097          	auipc	ra,0xffffb
    80006184:	966080e7          	jalr	-1690(ra) # 80000ae6 <kalloc>
    80006188:	0001d497          	auipc	s1,0x1d
    8000618c:	13848493          	addi	s1,s1,312 # 800232c0 <disk>
    80006190:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006192:	ffffb097          	auipc	ra,0xffffb
    80006196:	954080e7          	jalr	-1708(ra) # 80000ae6 <kalloc>
    8000619a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000619c:	ffffb097          	auipc	ra,0xffffb
    800061a0:	94a080e7          	jalr	-1718(ra) # 80000ae6 <kalloc>
    800061a4:	87aa                	mv	a5,a0
    800061a6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800061a8:	6088                	ld	a0,0(s1)
    800061aa:	cd6d                	beqz	a0,800062a4 <virtio_disk_init+0x1dc>
    800061ac:	0001d717          	auipc	a4,0x1d
    800061b0:	11c73703          	ld	a4,284(a4) # 800232c8 <disk+0x8>
    800061b4:	cb65                	beqz	a4,800062a4 <virtio_disk_init+0x1dc>
    800061b6:	c7fd                	beqz	a5,800062a4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800061b8:	6605                	lui	a2,0x1
    800061ba:	4581                	li	a1,0
    800061bc:	ffffb097          	auipc	ra,0xffffb
    800061c0:	b16080e7          	jalr	-1258(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800061c4:	0001d497          	auipc	s1,0x1d
    800061c8:	0fc48493          	addi	s1,s1,252 # 800232c0 <disk>
    800061cc:	6605                	lui	a2,0x1
    800061ce:	4581                	li	a1,0
    800061d0:	6488                	ld	a0,8(s1)
    800061d2:	ffffb097          	auipc	ra,0xffffb
    800061d6:	b00080e7          	jalr	-1280(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800061da:	6605                	lui	a2,0x1
    800061dc:	4581                	li	a1,0
    800061de:	6888                	ld	a0,16(s1)
    800061e0:	ffffb097          	auipc	ra,0xffffb
    800061e4:	af2080e7          	jalr	-1294(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061e8:	100017b7          	lui	a5,0x10001
    800061ec:	4721                	li	a4,8
    800061ee:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800061f0:	4098                	lw	a4,0(s1)
    800061f2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800061f6:	40d8                	lw	a4,4(s1)
    800061f8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800061fc:	6498                	ld	a4,8(s1)
    800061fe:	0007069b          	sext.w	a3,a4
    80006202:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006206:	9701                	srai	a4,a4,0x20
    80006208:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000620c:	6898                	ld	a4,16(s1)
    8000620e:	0007069b          	sext.w	a3,a4
    80006212:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006216:	9701                	srai	a4,a4,0x20
    80006218:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000621c:	4705                	li	a4,1
    8000621e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006220:	00e48c23          	sb	a4,24(s1)
    80006224:	00e48ca3          	sb	a4,25(s1)
    80006228:	00e48d23          	sb	a4,26(s1)
    8000622c:	00e48da3          	sb	a4,27(s1)
    80006230:	00e48e23          	sb	a4,28(s1)
    80006234:	00e48ea3          	sb	a4,29(s1)
    80006238:	00e48f23          	sb	a4,30(s1)
    8000623c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006240:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006244:	0727a823          	sw	s2,112(a5)
}
    80006248:	60e2                	ld	ra,24(sp)
    8000624a:	6442                	ld	s0,16(sp)
    8000624c:	64a2                	ld	s1,8(sp)
    8000624e:	6902                	ld	s2,0(sp)
    80006250:	6105                	addi	sp,sp,32
    80006252:	8082                	ret
    panic("could not find virtio disk");
    80006254:	00002517          	auipc	a0,0x2
    80006258:	5b450513          	addi	a0,a0,1460 # 80008808 <syscalls+0x320>
    8000625c:	ffffa097          	auipc	ra,0xffffa
    80006260:	2e2080e7          	jalr	738(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006264:	00002517          	auipc	a0,0x2
    80006268:	5c450513          	addi	a0,a0,1476 # 80008828 <syscalls+0x340>
    8000626c:	ffffa097          	auipc	ra,0xffffa
    80006270:	2d2080e7          	jalr	722(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006274:	00002517          	auipc	a0,0x2
    80006278:	5d450513          	addi	a0,a0,1492 # 80008848 <syscalls+0x360>
    8000627c:	ffffa097          	auipc	ra,0xffffa
    80006280:	2c2080e7          	jalr	706(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006284:	00002517          	auipc	a0,0x2
    80006288:	5e450513          	addi	a0,a0,1508 # 80008868 <syscalls+0x380>
    8000628c:	ffffa097          	auipc	ra,0xffffa
    80006290:	2b2080e7          	jalr	690(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006294:	00002517          	auipc	a0,0x2
    80006298:	5f450513          	addi	a0,a0,1524 # 80008888 <syscalls+0x3a0>
    8000629c:	ffffa097          	auipc	ra,0xffffa
    800062a0:	2a2080e7          	jalr	674(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800062a4:	00002517          	auipc	a0,0x2
    800062a8:	60450513          	addi	a0,a0,1540 # 800088a8 <syscalls+0x3c0>
    800062ac:	ffffa097          	auipc	ra,0xffffa
    800062b0:	292080e7          	jalr	658(ra) # 8000053e <panic>

00000000800062b4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062b4:	7119                	addi	sp,sp,-128
    800062b6:	fc86                	sd	ra,120(sp)
    800062b8:	f8a2                	sd	s0,112(sp)
    800062ba:	f4a6                	sd	s1,104(sp)
    800062bc:	f0ca                	sd	s2,96(sp)
    800062be:	ecce                	sd	s3,88(sp)
    800062c0:	e8d2                	sd	s4,80(sp)
    800062c2:	e4d6                	sd	s5,72(sp)
    800062c4:	e0da                	sd	s6,64(sp)
    800062c6:	fc5e                	sd	s7,56(sp)
    800062c8:	f862                	sd	s8,48(sp)
    800062ca:	f466                	sd	s9,40(sp)
    800062cc:	f06a                	sd	s10,32(sp)
    800062ce:	ec6e                	sd	s11,24(sp)
    800062d0:	0100                	addi	s0,sp,128
    800062d2:	8aaa                	mv	s5,a0
    800062d4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062d6:	00c52d03          	lw	s10,12(a0)
    800062da:	001d1d1b          	slliw	s10,s10,0x1
    800062de:	1d02                	slli	s10,s10,0x20
    800062e0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800062e4:	0001d517          	auipc	a0,0x1d
    800062e8:	10450513          	addi	a0,a0,260 # 800233e8 <disk+0x128>
    800062ec:	ffffb097          	auipc	ra,0xffffb
    800062f0:	8ea080e7          	jalr	-1814(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800062f4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800062f6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800062f8:	0001db97          	auipc	s7,0x1d
    800062fc:	fc8b8b93          	addi	s7,s7,-56 # 800232c0 <disk>
  for(int i = 0; i < 3; i++){
    80006300:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006302:	0001dc97          	auipc	s9,0x1d
    80006306:	0e6c8c93          	addi	s9,s9,230 # 800233e8 <disk+0x128>
    8000630a:	a08d                	j	8000636c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000630c:	00fb8733          	add	a4,s7,a5
    80006310:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006314:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006316:	0207c563          	bltz	a5,80006340 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000631a:	2905                	addiw	s2,s2,1
    8000631c:	0611                	addi	a2,a2,4
    8000631e:	05690c63          	beq	s2,s6,80006376 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006322:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006324:	0001d717          	auipc	a4,0x1d
    80006328:	f9c70713          	addi	a4,a4,-100 # 800232c0 <disk>
    8000632c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000632e:	01874683          	lbu	a3,24(a4)
    80006332:	fee9                	bnez	a3,8000630c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006334:	2785                	addiw	a5,a5,1
    80006336:	0705                	addi	a4,a4,1
    80006338:	fe979be3          	bne	a5,s1,8000632e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000633c:	57fd                	li	a5,-1
    8000633e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006340:	01205d63          	blez	s2,8000635a <virtio_disk_rw+0xa6>
    80006344:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006346:	000a2503          	lw	a0,0(s4)
    8000634a:	00000097          	auipc	ra,0x0
    8000634e:	cfc080e7          	jalr	-772(ra) # 80006046 <free_desc>
      for(int j = 0; j < i; j++)
    80006352:	2d85                	addiw	s11,s11,1
    80006354:	0a11                	addi	s4,s4,4
    80006356:	ffb918e3          	bne	s2,s11,80006346 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000635a:	85e6                	mv	a1,s9
    8000635c:	0001d517          	auipc	a0,0x1d
    80006360:	f7c50513          	addi	a0,a0,-132 # 800232d8 <disk+0x18>
    80006364:	ffffc097          	auipc	ra,0xffffc
    80006368:	dca080e7          	jalr	-566(ra) # 8000212e <sleep>
  for(int i = 0; i < 3; i++){
    8000636c:	f8040a13          	addi	s4,s0,-128
{
    80006370:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006372:	894e                	mv	s2,s3
    80006374:	b77d                	j	80006322 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006376:	f8042583          	lw	a1,-128(s0)
    8000637a:	00a58793          	addi	a5,a1,10
    8000637e:	0792                	slli	a5,a5,0x4

  if(write)
    80006380:	0001d617          	auipc	a2,0x1d
    80006384:	f4060613          	addi	a2,a2,-192 # 800232c0 <disk>
    80006388:	00f60733          	add	a4,a2,a5
    8000638c:	018036b3          	snez	a3,s8
    80006390:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006392:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006396:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000639a:	f6078693          	addi	a3,a5,-160
    8000639e:	6218                	ld	a4,0(a2)
    800063a0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063a2:	00878513          	addi	a0,a5,8
    800063a6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063a8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063aa:	6208                	ld	a0,0(a2)
    800063ac:	96aa                	add	a3,a3,a0
    800063ae:	4741                	li	a4,16
    800063b0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063b2:	4705                	li	a4,1
    800063b4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800063b8:	f8442703          	lw	a4,-124(s0)
    800063bc:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063c0:	0712                	slli	a4,a4,0x4
    800063c2:	953a                	add	a0,a0,a4
    800063c4:	058a8693          	addi	a3,s5,88
    800063c8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800063ca:	6208                	ld	a0,0(a2)
    800063cc:	972a                	add	a4,a4,a0
    800063ce:	40000693          	li	a3,1024
    800063d2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063d4:	001c3c13          	seqz	s8,s8
    800063d8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063da:	001c6c13          	ori	s8,s8,1
    800063de:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800063e2:	f8842603          	lw	a2,-120(s0)
    800063e6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063ea:	0001d697          	auipc	a3,0x1d
    800063ee:	ed668693          	addi	a3,a3,-298 # 800232c0 <disk>
    800063f2:	00258713          	addi	a4,a1,2
    800063f6:	0712                	slli	a4,a4,0x4
    800063f8:	9736                	add	a4,a4,a3
    800063fa:	587d                	li	a6,-1
    800063fc:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006400:	0612                	slli	a2,a2,0x4
    80006402:	9532                	add	a0,a0,a2
    80006404:	f9078793          	addi	a5,a5,-112
    80006408:	97b6                	add	a5,a5,a3
    8000640a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000640c:	629c                	ld	a5,0(a3)
    8000640e:	97b2                	add	a5,a5,a2
    80006410:	4605                	li	a2,1
    80006412:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006414:	4509                	li	a0,2
    80006416:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000641a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000641e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006422:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006426:	6698                	ld	a4,8(a3)
    80006428:	00275783          	lhu	a5,2(a4)
    8000642c:	8b9d                	andi	a5,a5,7
    8000642e:	0786                	slli	a5,a5,0x1
    80006430:	97ba                	add	a5,a5,a4
    80006432:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006436:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000643a:	6698                	ld	a4,8(a3)
    8000643c:	00275783          	lhu	a5,2(a4)
    80006440:	2785                	addiw	a5,a5,1
    80006442:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006446:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000644a:	100017b7          	lui	a5,0x10001
    8000644e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006452:	004aa783          	lw	a5,4(s5)
    80006456:	02c79163          	bne	a5,a2,80006478 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000645a:	0001d917          	auipc	s2,0x1d
    8000645e:	f8e90913          	addi	s2,s2,-114 # 800233e8 <disk+0x128>
  while(b->disk == 1) {
    80006462:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006464:	85ca                	mv	a1,s2
    80006466:	8556                	mv	a0,s5
    80006468:	ffffc097          	auipc	ra,0xffffc
    8000646c:	cc6080e7          	jalr	-826(ra) # 8000212e <sleep>
  while(b->disk == 1) {
    80006470:	004aa783          	lw	a5,4(s5)
    80006474:	fe9788e3          	beq	a5,s1,80006464 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006478:	f8042903          	lw	s2,-128(s0)
    8000647c:	00290793          	addi	a5,s2,2
    80006480:	00479713          	slli	a4,a5,0x4
    80006484:	0001d797          	auipc	a5,0x1d
    80006488:	e3c78793          	addi	a5,a5,-452 # 800232c0 <disk>
    8000648c:	97ba                	add	a5,a5,a4
    8000648e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006492:	0001d997          	auipc	s3,0x1d
    80006496:	e2e98993          	addi	s3,s3,-466 # 800232c0 <disk>
    8000649a:	00491713          	slli	a4,s2,0x4
    8000649e:	0009b783          	ld	a5,0(s3)
    800064a2:	97ba                	add	a5,a5,a4
    800064a4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064a8:	854a                	mv	a0,s2
    800064aa:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064ae:	00000097          	auipc	ra,0x0
    800064b2:	b98080e7          	jalr	-1128(ra) # 80006046 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064b6:	8885                	andi	s1,s1,1
    800064b8:	f0ed                	bnez	s1,8000649a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064ba:	0001d517          	auipc	a0,0x1d
    800064be:	f2e50513          	addi	a0,a0,-210 # 800233e8 <disk+0x128>
    800064c2:	ffffa097          	auipc	ra,0xffffa
    800064c6:	7c8080e7          	jalr	1992(ra) # 80000c8a <release>
}
    800064ca:	70e6                	ld	ra,120(sp)
    800064cc:	7446                	ld	s0,112(sp)
    800064ce:	74a6                	ld	s1,104(sp)
    800064d0:	7906                	ld	s2,96(sp)
    800064d2:	69e6                	ld	s3,88(sp)
    800064d4:	6a46                	ld	s4,80(sp)
    800064d6:	6aa6                	ld	s5,72(sp)
    800064d8:	6b06                	ld	s6,64(sp)
    800064da:	7be2                	ld	s7,56(sp)
    800064dc:	7c42                	ld	s8,48(sp)
    800064de:	7ca2                	ld	s9,40(sp)
    800064e0:	7d02                	ld	s10,32(sp)
    800064e2:	6de2                	ld	s11,24(sp)
    800064e4:	6109                	addi	sp,sp,128
    800064e6:	8082                	ret

00000000800064e8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064e8:	1101                	addi	sp,sp,-32
    800064ea:	ec06                	sd	ra,24(sp)
    800064ec:	e822                	sd	s0,16(sp)
    800064ee:	e426                	sd	s1,8(sp)
    800064f0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064f2:	0001d497          	auipc	s1,0x1d
    800064f6:	dce48493          	addi	s1,s1,-562 # 800232c0 <disk>
    800064fa:	0001d517          	auipc	a0,0x1d
    800064fe:	eee50513          	addi	a0,a0,-274 # 800233e8 <disk+0x128>
    80006502:	ffffa097          	auipc	ra,0xffffa
    80006506:	6d4080e7          	jalr	1748(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000650a:	10001737          	lui	a4,0x10001
    8000650e:	533c                	lw	a5,96(a4)
    80006510:	8b8d                	andi	a5,a5,3
    80006512:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006514:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006518:	689c                	ld	a5,16(s1)
    8000651a:	0204d703          	lhu	a4,32(s1)
    8000651e:	0027d783          	lhu	a5,2(a5)
    80006522:	04f70863          	beq	a4,a5,80006572 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006526:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000652a:	6898                	ld	a4,16(s1)
    8000652c:	0204d783          	lhu	a5,32(s1)
    80006530:	8b9d                	andi	a5,a5,7
    80006532:	078e                	slli	a5,a5,0x3
    80006534:	97ba                	add	a5,a5,a4
    80006536:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006538:	00278713          	addi	a4,a5,2
    8000653c:	0712                	slli	a4,a4,0x4
    8000653e:	9726                	add	a4,a4,s1
    80006540:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006544:	e721                	bnez	a4,8000658c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006546:	0789                	addi	a5,a5,2
    80006548:	0792                	slli	a5,a5,0x4
    8000654a:	97a6                	add	a5,a5,s1
    8000654c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000654e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006552:	ffffc097          	auipc	ra,0xffffc
    80006556:	c5c080e7          	jalr	-932(ra) # 800021ae <wakeup>

    disk.used_idx += 1;
    8000655a:	0204d783          	lhu	a5,32(s1)
    8000655e:	2785                	addiw	a5,a5,1
    80006560:	17c2                	slli	a5,a5,0x30
    80006562:	93c1                	srli	a5,a5,0x30
    80006564:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006568:	6898                	ld	a4,16(s1)
    8000656a:	00275703          	lhu	a4,2(a4)
    8000656e:	faf71ce3          	bne	a4,a5,80006526 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006572:	0001d517          	auipc	a0,0x1d
    80006576:	e7650513          	addi	a0,a0,-394 # 800233e8 <disk+0x128>
    8000657a:	ffffa097          	auipc	ra,0xffffa
    8000657e:	710080e7          	jalr	1808(ra) # 80000c8a <release>
}
    80006582:	60e2                	ld	ra,24(sp)
    80006584:	6442                	ld	s0,16(sp)
    80006586:	64a2                	ld	s1,8(sp)
    80006588:	6105                	addi	sp,sp,32
    8000658a:	8082                	ret
      panic("virtio_disk_intr status");
    8000658c:	00002517          	auipc	a0,0x2
    80006590:	33450513          	addi	a0,a0,820 # 800088c0 <syscalls+0x3d8>
    80006594:	ffffa097          	auipc	ra,0xffffa
    80006598:	faa080e7          	jalr	-86(ra) # 8000053e <panic>
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
