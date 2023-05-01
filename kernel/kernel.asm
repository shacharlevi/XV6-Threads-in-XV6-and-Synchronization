
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
    80000068:	f2c78793          	addi	a5,a5,-212 # 80005f90 <timervec>
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
    80000130:	512080e7          	jalr	1298(ra) # 8000263e <either_copyin>
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
    800001cc:	2be080e7          	jalr	702(ra) # 80002486 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f64080e7          	jalr	-156(ra) # 8000213a <sleep>
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
    80000216:	3d4080e7          	jalr	980(ra) # 800025e6 <either_copyout>
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
    800002f6:	3a4080e7          	jalr	932(ra) # 80002696 <procdump>
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
    8000044a:	d74080e7          	jalr	-652(ra) # 800021ba <wakeup>
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
    80000896:	928080e7          	jalr	-1752(ra) # 800021ba <wakeup>
    
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
    80000920:	81e080e7          	jalr	-2018(ra) # 8000213a <sleep>
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
    80000ec2:	b06080e7          	jalr	-1274(ra) # 800029c4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	10a080e7          	jalr	266(ra) # 80005fd0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fec080e7          	jalr	-20(ra) # 80001eba <scheduler>
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
    80000f3a:	a66080e7          	jalr	-1434(ra) # 8000299c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a86080e7          	jalr	-1402(ra) # 800029c4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	074080e7          	jalr	116(ra) # 80005fba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	082080e7          	jalr	130(ra) # 80005fd0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	206080e7          	jalr	518(ra) # 8000315c <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	8aa080e7          	jalr	-1878(ra) # 80003808 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	848080e7          	jalr	-1976(ra) # 800047ae <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	16a080e7          	jalr	362(ra) # 800060d8 <virtio_disk_init>
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
    8000193a:	e0e080e7          	jalr	-498(ra) # 80002744 <kthreadinit>
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
    80001b12:	dc8080e7          	jalr	-568(ra) # 800028d6 <freethread>
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
    80001b66:	7179                	addi	sp,sp,-48
    80001b68:	f406                	sd	ra,40(sp)
    80001b6a:	f022                	sd	s0,32(sp)
    80001b6c:	ec26                	sd	s1,24(sp)
    80001b6e:	e84a                	sd	s2,16(sp)
    80001b70:	e44e                	sd	s3,8(sp)
    80001b72:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b74:	0000f497          	auipc	s1,0xf
    80001b78:	4ac48493          	addi	s1,s1,1196 # 80011020 <proc>
    80001b7c:	00016917          	auipc	s2,0x16
    80001b80:	4a490913          	addi	s2,s2,1188 # 80018020 <tickslock>
    acquire(&p->lock);
    80001b84:	8526                	mv	a0,s1
    80001b86:	fffff097          	auipc	ra,0xfffff
    80001b8a:	050080e7          	jalr	80(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001b8e:	4c9c                	lw	a5,24(s1)
    80001b90:	cf81                	beqz	a5,80001ba8 <allocproc+0x42>
      release(&p->lock);
    80001b92:	8526                	mv	a0,s1
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	0f6080e7          	jalr	246(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b9c:	1c048493          	addi	s1,s1,448
    80001ba0:	ff2492e3          	bne	s1,s2,80001b84 <allocproc+0x1e>
  return 0;
    80001ba4:	4481                	li	s1,0
    80001ba6:	a091                	j	80001bea <allocproc+0x84>
  p->p_counter=1;
    80001ba8:	4905                	li	s2,1
    80001baa:	1b24a023          	sw	s2,416(s1)
  p->pid = allocpid();
    80001bae:	00000097          	auipc	ra,0x0
    80001bb2:	e0e080e7          	jalr	-498(ra) # 800019bc <allocpid>
    80001bb6:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001bb8:	0124ac23          	sw	s2,24(s1)
  if((p->base_trapframes = (struct trapframe *)kalloc()) == 0){
    80001bbc:	fffff097          	auipc	ra,0xfffff
    80001bc0:	f2a080e7          	jalr	-214(ra) # 80000ae6 <kalloc>
    80001bc4:	892a                	mv	s2,a0
    80001bc6:	f4e8                	sd	a0,232(s1)
    80001bc8:	c90d                	beqz	a0,80001bfa <allocproc+0x94>
  struct kthread *new_t=allockthread(p);
    80001bca:	8526                	mv	a0,s1
    80001bcc:	00001097          	auipc	ra,0x1
    80001bd0:	c8a080e7          	jalr	-886(ra) # 80002856 <allockthread>
    80001bd4:	89aa                	mv	s3,a0
  if(new_t==0){
    80001bd6:	cd15                	beqz	a0,80001c12 <allocproc+0xac>
  p->pagetable = proc_pagetable(p);
    80001bd8:	8526                	mv	a0,s1
    80001bda:	00000097          	auipc	ra,0x0
    80001bde:	e28080e7          	jalr	-472(ra) # 80001a02 <proc_pagetable>
    80001be2:	892a                	mv	s2,a0
    80001be4:	10a4b023          	sd	a0,256(s1)
  if(p->pagetable == 0){
    80001be8:	c531                	beqz	a0,80001c34 <allocproc+0xce>
}
    80001bea:	8526                	mv	a0,s1
    80001bec:	70a2                	ld	ra,40(sp)
    80001bee:	7402                	ld	s0,32(sp)
    80001bf0:	64e2                	ld	s1,24(sp)
    80001bf2:	6942                	ld	s2,16(sp)
    80001bf4:	69a2                	ld	s3,8(sp)
    80001bf6:	6145                	addi	sp,sp,48
    80001bf8:	8082                	ret
    freeproc(p);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	ef4080e7          	jalr	-268(ra) # 80001af0 <freeproc>
    release(&p->lock);
    80001c04:	8526                	mv	a0,s1
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	084080e7          	jalr	132(ra) # 80000c8a <release>
    return 0;
    80001c0e:	84ca                	mv	s1,s2
    80001c10:	bfe9                	j	80001bea <allocproc+0x84>
    release(&new_t->t_lock);
    80001c12:	4501                	li	a0,0
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	076080e7          	jalr	118(ra) # 80000c8a <release>
    freeproc(p);
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	ed2080e7          	jalr	-302(ra) # 80001af0 <freeproc>
    release(&p->lock);
    80001c26:	8526                	mv	a0,s1
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	062080e7          	jalr	98(ra) # 80000c8a <release>
    return (struct proc *)-1;
    80001c30:	54fd                	li	s1,-1
    80001c32:	bf65                	j	80001bea <allocproc+0x84>
    release(&new_t->t_lock);
    80001c34:	854e                	mv	a0,s3
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	054080e7          	jalr	84(ra) # 80000c8a <release>
    freeproc(p);
    80001c3e:	8526                	mv	a0,s1
    80001c40:	00000097          	auipc	ra,0x0
    80001c44:	eb0080e7          	jalr	-336(ra) # 80001af0 <freeproc>
    release(&p->lock);
    80001c48:	8526                	mv	a0,s1
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	040080e7          	jalr	64(ra) # 80000c8a <release>
    return 0;
    80001c52:	84ca                	mv	s1,s2
    80001c54:	bf59                	j	80001bea <allocproc+0x84>

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
    80001c64:	f06080e7          	jalr	-250(ra) # 80001b66 <allocproc>
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
    80001cca:	4e4080e7          	jalr	1252(ra) # 800041aa <namei>
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
    80001d66:	a54080e7          	jalr	-1452(ra) # 800027b6 <mykthread>
    80001d6a:	84aa                	mv	s1,a0
  printf("in fork\n");
    80001d6c:	00006517          	auipc	a0,0x6
    80001d70:	4ac50513          	addi	a0,a0,1196 # 80008218 <digits+0x1d8>
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	814080e7          	jalr	-2028(ra) # 80000588 <printf>
  // Allocate process.
  if((np = allocproc()) == 0){
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	dea080e7          	jalr	-534(ra) # 80001b66 <allocproc>
    80001d84:	12050963          	beqz	a0,80001eb6 <fork+0x170>
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
    release(&np->kthread[0].t_lock);
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
    80001dea:	a03d                	j	80001e18 <fork+0xd2>
    freeproc(np);
    80001dec:	8552                	mv	a0,s4
    80001dee:	00000097          	auipc	ra,0x0
    80001df2:	d02080e7          	jalr	-766(ra) # 80001af0 <freeproc>
    release(&np->kthread[0].t_lock);
    80001df6:	028a0513          	addi	a0,s4,40
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	e90080e7          	jalr	-368(ra) # 80000c8a <release>
    release(&np->lock);
    80001e02:	8552                	mv	a0,s4
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	e86080e7          	jalr	-378(ra) # 80000c8a <release>
    return -1;
    80001e0c:	59fd                	li	s3,-1
    80001e0e:	a851                	j	80001ea2 <fork+0x15c>
  for(i = 0; i < NOFILE; i++)
    80001e10:	04a1                	addi	s1,s1,8
    80001e12:	0921                	addi	s2,s2,8
    80001e14:	01348b63          	beq	s1,s3,80001e2a <fork+0xe4>
    if(p->ofile[i])
    80001e18:	6088                	ld	a0,0(s1)
    80001e1a:	d97d                	beqz	a0,80001e10 <fork+0xca>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e1c:	00003097          	auipc	ra,0x3
    80001e20:	a24080e7          	jalr	-1500(ra) # 80004840 <filedup>
    80001e24:	00a93023          	sd	a0,0(s2)
    80001e28:	b7e5                	j	80001e10 <fork+0xca>
  np->cwd = idup(p->cwd);
    80001e2a:	188ab503          	ld	a0,392(s5)
    80001e2e:	00002097          	auipc	ra,0x2
    80001e32:	b98080e7          	jalr	-1128(ra) # 800039c6 <idup>
    80001e36:	18aa3423          	sd	a0,392(s4)

  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e3a:	4641                	li	a2,16
    80001e3c:	190a8593          	addi	a1,s5,400
    80001e40:	190a0513          	addi	a0,s4,400
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	fd8080e7          	jalr	-40(ra) # 80000e1c <safestrcpy>

  pid = np->pid;
    80001e4c:	024a2983          	lw	s3,36(s4)

  release(&np->kthread[0].t_lock);///acqire in allockthread
    80001e50:	028a0493          	addi	s1,s4,40
    80001e54:	8526                	mv	a0,s1
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	e34080e7          	jalr	-460(ra) # 80000c8a <release>
  release(&np->lock);///acqire in allocproc
    80001e5e:	8552                	mv	a0,s4
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	e2a080e7          	jalr	-470(ra) # 80000c8a <release>

  acquire(&wait_lock);
    80001e68:	0000f917          	auipc	s2,0xf
    80001e6c:	da090913          	addi	s2,s2,-608 # 80010c08 <wait_lock>
    80001e70:	854a                	mv	a0,s2
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	d64080e7          	jalr	-668(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e7a:	0f5a3823          	sd	s5,240(s4)
  release(&wait_lock);
    80001e7e:	854a                	mv	a0,s2
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	e0a080e7          	jalr	-502(ra) # 80000c8a <release>

  // acquire(&np->lock);
  acquire(&np->kthread[0].t_lock);
    80001e88:	8526                	mv	a0,s1
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	d4c080e7          	jalr	-692(ra) # 80000bd6 <acquire>
  np->kthread[0].t_state = RUNNABLE_t;
    80001e92:	478d                	li	a5,3
    80001e94:	04fa2023          	sw	a5,64(s4)
  release(&np->kthread[0].t_lock);
    80001e98:	8526                	mv	a0,s1
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	df0080e7          	jalr	-528(ra) # 80000c8a <release>
  // release(&np->lock);



  return pid;
}
    80001ea2:	854e                	mv	a0,s3
    80001ea4:	70e2                	ld	ra,56(sp)
    80001ea6:	7442                	ld	s0,48(sp)
    80001ea8:	74a2                	ld	s1,40(sp)
    80001eaa:	7902                	ld	s2,32(sp)
    80001eac:	69e2                	ld	s3,24(sp)
    80001eae:	6a42                	ld	s4,16(sp)
    80001eb0:	6aa2                	ld	s5,8(sp)
    80001eb2:	6121                	addi	sp,sp,64
    80001eb4:	8082                	ret
    return -1;
    80001eb6:	59fd                	li	s3,-1
    80001eb8:	b7ed                	j	80001ea2 <fork+0x15c>

0000000080001eba <scheduler>:
// }


void
scheduler(void)
{
    80001eba:	7159                	addi	sp,sp,-112
    80001ebc:	f486                	sd	ra,104(sp)
    80001ebe:	f0a2                	sd	s0,96(sp)
    80001ec0:	eca6                	sd	s1,88(sp)
    80001ec2:	e8ca                	sd	s2,80(sp)
    80001ec4:	e4ce                	sd	s3,72(sp)
    80001ec6:	e0d2                	sd	s4,64(sp)
    80001ec8:	fc56                	sd	s5,56(sp)
    80001eca:	f85a                	sd	s6,48(sp)
    80001ecc:	f45e                	sd	s7,40(sp)
    80001ece:	f062                	sd	s8,32(sp)
    80001ed0:	ec66                	sd	s9,24(sp)
    80001ed2:	e86a                	sd	s10,16(sp)
    80001ed4:	e46e                	sd	s11,8(sp)
    80001ed6:	1880                	addi	s0,sp,112
    80001ed8:	8792                	mv	a5,tp
  int id = r_tp();
    80001eda:	2781                	sext.w	a5,a5
  struct proc *p;
  struct cpu *c = mycpu();
  c->kthread = 0;
    80001edc:	00779c13          	slli	s8,a5,0x7
    80001ee0:	0000f717          	auipc	a4,0xf
    80001ee4:	d1070713          	addi	a4,a4,-752 # 80010bf0 <pid_lock>
    80001ee8:	9762                	add	a4,a4,s8
    80001eea:	02073823          	sd	zero,48(a4)
            if(kt->t_state == RUNNABLE_t) {
                  printf("22in scheduler222\n");

              kt->t_state = RUNNING_t;
              c->kthread=kt;
              swtch(&c->context, &kt->context);
    80001eee:	0000f717          	auipc	a4,0xf
    80001ef2:	d3a70713          	addi	a4,a4,-710 # 80010c28 <cpus+0x8>
    80001ef6:	9c3a                	add	s8,s8,a4
    printf("in scheduler\n");
    80001ef8:	00006d97          	auipc	s11,0x6
    80001efc:	330d8d93          	addi	s11,s11,816 # 80008228 <digits+0x1e8>
    80001f00:	00016a17          	auipc	s4,0x16
    80001f04:	148a0a13          	addi	s4,s4,328 # 80018048 <bcache+0x10>
                  printf("22in scheduler222\n");
    80001f08:	00006d17          	auipc	s10,0x6
    80001f0c:	330d0d13          	addi	s10,s10,816 # 80008238 <digits+0x1f8>
              c->kthread=kt;
    80001f10:	079e                	slli	a5,a5,0x7
    80001f12:	0000fb17          	auipc	s6,0xf
    80001f16:	cdeb0b13          	addi	s6,s6,-802 # 80010bf0 <pid_lock>
    80001f1a:	9b3e                	add	s6,s6,a5
              c->kthread = 0;
                                printf("33in scheduler333\n");
    80001f1c:	00006c97          	auipc	s9,0x6
    80001f20:	334c8c93          	addi	s9,s9,820 # 80008250 <digits+0x210>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f24:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f28:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f2c:	10079073          	csrw	sstatus,a5
    printf("in scheduler\n");
    80001f30:	856e                	mv	a0,s11
    80001f32:	ffffe097          	auipc	ra,0xffffe
    80001f36:	656080e7          	jalr	1622(ra) # 80000588 <printf>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f3a:	0000f497          	auipc	s1,0xf
    80001f3e:	10e48493          	addi	s1,s1,270 # 80011048 <proc+0x28>
      if (p->state==USED){
    80001f42:	4985                	li	s3,1
            if(kt->t_state == RUNNABLE_t) {
    80001f44:	4a8d                	li	s5,3
              kt->t_state = RUNNING_t;
    80001f46:	4b91                	li	s7,4
    80001f48:	a811                	j	80001f5c <scheduler+0xa2>

            }
        release(&kt->t_lock); // Release the thread lock
    80001f4a:	854a                	mv	a0,s2
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	d3e080e7          	jalr	-706(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f54:	1c048493          	addi	s1,s1,448
    80001f58:	fc9a06e3          	beq	s4,s1,80001f24 <scheduler+0x6a>
      if (p->state==USED){
    80001f5c:	8926                	mv	s2,s1
    80001f5e:	ff04a783          	lw	a5,-16(s1)
    80001f62:	ff3799e3          	bne	a5,s3,80001f54 <scheduler+0x9a>
          acquire(&kt->t_lock);
    80001f66:	8526                	mv	a0,s1
    80001f68:	fffff097          	auipc	ra,0xfffff
    80001f6c:	c6e080e7          	jalr	-914(ra) # 80000bd6 <acquire>
            if(kt->t_state == RUNNABLE_t) {
    80001f70:	4c9c                	lw	a5,24(s1)
    80001f72:	fd579ce3          	bne	a5,s5,80001f4a <scheduler+0x90>
                  printf("22in scheduler222\n");
    80001f76:	856a                	mv	a0,s10
    80001f78:	ffffe097          	auipc	ra,0xffffe
    80001f7c:	610080e7          	jalr	1552(ra) # 80000588 <printf>
              kt->t_state = RUNNING_t;
    80001f80:	0174ac23          	sw	s7,24(s1)
              c->kthread=kt;
    80001f84:	029b3823          	sd	s1,48(s6)
              swtch(&c->context, &kt->context);
    80001f88:	04048593          	addi	a1,s1,64
    80001f8c:	8562                	mv	a0,s8
    80001f8e:	00001097          	auipc	ra,0x1
    80001f92:	9a4080e7          	jalr	-1628(ra) # 80002932 <swtch>
              c->kthread = 0;
    80001f96:	020b3823          	sd	zero,48(s6)
                                printf("33in scheduler333\n");
    80001f9a:	8566                	mv	a0,s9
    80001f9c:	ffffe097          	auipc	ra,0xffffe
    80001fa0:	5ec080e7          	jalr	1516(ra) # 80000588 <printf>
    80001fa4:	b75d                	j	80001f4a <scheduler+0x90>

0000000080001fa6 <sched>:
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    80001fa6:	7179                	addi	sp,sp,-48
    80001fa8:	f406                	sd	ra,40(sp)
    80001faa:	f022                	sd	s0,32(sp)
    80001fac:	ec26                	sd	s1,24(sp)
    80001fae:	e84a                	sd	s2,16(sp)
    80001fb0:	e44e                	sd	s3,8(sp)
    80001fb2:	1800                	addi	s0,sp,48
  int intena;
  struct kthread *t = mykthread();
    80001fb4:	00001097          	auipc	ra,0x1
    80001fb8:	802080e7          	jalr	-2046(ra) # 800027b6 <mykthread>
    80001fbc:	84aa                	mv	s1,a0

  if(!holding(&t->t_lock))
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	b9e080e7          	jalr	-1122(ra) # 80000b5c <holding>
    80001fc6:	c93d                	beqz	a0,8000203c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fc8:	8792                	mv	a5,tp
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    80001fca:	2781                	sext.w	a5,a5
    80001fcc:	079e                	slli	a5,a5,0x7
    80001fce:	0000f717          	auipc	a4,0xf
    80001fd2:	c2270713          	addi	a4,a4,-990 # 80010bf0 <pid_lock>
    80001fd6:	97ba                	add	a5,a5,a4
    80001fd8:	0a87a703          	lw	a4,168(a5)
    80001fdc:	4785                	li	a5,1
    80001fde:	06f71763          	bne	a4,a5,8000204c <sched+0xa6>
    panic("sched locks");
  if(t->t_state == RUNNING_t)
    80001fe2:	4c98                	lw	a4,24(s1)
    80001fe4:	4791                	li	a5,4
    80001fe6:	06f70b63          	beq	a4,a5,8000205c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fea:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fee:	8b89                	andi	a5,a5,2
    panic("sched running");
  if(intr_get())
    80001ff0:	efb5                	bnez	a5,8000206c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ff2:	8792                	mv	a5,tp
    panic("sched interruptible");

  intena = mycpu()->intena;
    80001ff4:	0000f917          	auipc	s2,0xf
    80001ff8:	bfc90913          	addi	s2,s2,-1028 # 80010bf0 <pid_lock>
    80001ffc:	2781                	sext.w	a5,a5
    80001ffe:	079e                	slli	a5,a5,0x7
    80002000:	97ca                	add	a5,a5,s2
    80002002:	0ac7a983          	lw	s3,172(a5)
    80002006:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80002008:	2781                	sext.w	a5,a5
    8000200a:	079e                	slli	a5,a5,0x7
    8000200c:	0000f597          	auipc	a1,0xf
    80002010:	c1c58593          	addi	a1,a1,-996 # 80010c28 <cpus+0x8>
    80002014:	95be                	add	a1,a1,a5
    80002016:	04048513          	addi	a0,s1,64
    8000201a:	00001097          	auipc	ra,0x1
    8000201e:	918080e7          	jalr	-1768(ra) # 80002932 <swtch>
    80002022:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002024:	2781                	sext.w	a5,a5
    80002026:	079e                	slli	a5,a5,0x7
    80002028:	97ca                	add	a5,a5,s2
    8000202a:	0b37a623          	sw	s3,172(a5)
}
    8000202e:	70a2                	ld	ra,40(sp)
    80002030:	7402                	ld	s0,32(sp)
    80002032:	64e2                	ld	s1,24(sp)
    80002034:	6942                	ld	s2,16(sp)
    80002036:	69a2                	ld	s3,8(sp)
    80002038:	6145                	addi	sp,sp,48
    8000203a:	8082                	ret
    panic("sched p->lock");
    8000203c:	00006517          	auipc	a0,0x6
    80002040:	22c50513          	addi	a0,a0,556 # 80008268 <digits+0x228>
    80002044:	ffffe097          	auipc	ra,0xffffe
    80002048:	4fa080e7          	jalr	1274(ra) # 8000053e <panic>
    panic("sched locks");
    8000204c:	00006517          	auipc	a0,0x6
    80002050:	22c50513          	addi	a0,a0,556 # 80008278 <digits+0x238>
    80002054:	ffffe097          	auipc	ra,0xffffe
    80002058:	4ea080e7          	jalr	1258(ra) # 8000053e <panic>
    panic("sched running");
    8000205c:	00006517          	auipc	a0,0x6
    80002060:	22c50513          	addi	a0,a0,556 # 80008288 <digits+0x248>
    80002064:	ffffe097          	auipc	ra,0xffffe
    80002068:	4da080e7          	jalr	1242(ra) # 8000053e <panic>
    panic("sched interruptible");
    8000206c:	00006517          	auipc	a0,0x6
    80002070:	22c50513          	addi	a0,a0,556 # 80008298 <digits+0x258>
    80002074:	ffffe097          	auipc	ra,0xffffe
    80002078:	4ca080e7          	jalr	1226(ra) # 8000053e <panic>

000000008000207c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
    8000207c:	1101                	addi	sp,sp,-32
    8000207e:	ec06                	sd	ra,24(sp)
    80002080:	e822                	sd	s0,16(sp)
    80002082:	e426                	sd	s1,8(sp)
    80002084:	e04a                	sd	s2,0(sp)
    80002086:	1000                	addi	s0,sp,32
  printf("in yield\n");
    80002088:	00006517          	auipc	a0,0x6
    8000208c:	22850513          	addi	a0,a0,552 # 800082b0 <digits+0x270>
    80002090:	ffffe097          	auipc	ra,0xffffe
    80002094:	4f8080e7          	jalr	1272(ra) # 80000588 <printf>
  struct proc *p = myproc();
    80002098:	00000097          	auipc	ra,0x0
    8000209c:	8e8080e7          	jalr	-1816(ra) # 80001980 <myproc>
    800020a0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	b34080e7          	jalr	-1228(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    800020aa:	02848913          	addi	s2,s1,40
    800020ae:	854a                	mv	a0,s2
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	b26080e7          	jalr	-1242(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state = RUNNABLE_t;
    800020b8:	478d                	li	a5,3
    800020ba:	c0bc                	sw	a5,64(s1)
  release(&p->kthread[0].t_lock);
    800020bc:	854a                	mv	a0,s2
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	bcc080e7          	jalr	-1076(ra) # 80000c8a <release>
   sched();
    800020c6:	00000097          	auipc	ra,0x0
    800020ca:	ee0080e7          	jalr	-288(ra) # 80001fa6 <sched>
  release(&p->lock);
    800020ce:	8526                	mv	a0,s1
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	bba080e7          	jalr	-1094(ra) # 80000c8a <release>
   

}
    800020d8:	60e2                	ld	ra,24(sp)
    800020da:	6442                	ld	s0,16(sp)
    800020dc:	64a2                	ld	s1,8(sp)
    800020de:	6902                	ld	s2,0(sp)
    800020e0:	6105                	addi	sp,sp,32
    800020e2:	8082                	ret

00000000800020e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800020e4:	1141                	addi	sp,sp,-16
    800020e6:	e406                	sd	ra,8(sp)
    800020e8:	e022                	sd	s0,0(sp)
    800020ea:	0800                	addi	s0,sp,16
  printf("forkret\n");
    800020ec:	00006517          	auipc	a0,0x6
    800020f0:	1d450513          	addi	a0,a0,468 # 800082c0 <digits+0x280>
    800020f4:	ffffe097          	auipc	ra,0xffffe
    800020f8:	494080e7          	jalr	1172(ra) # 80000588 <printf>
  static int first = 1;
  release(&(mykthread()->t_lock)); //still holding kt->lock from scheduler
    800020fc:	00000097          	auipc	ra,0x0
    80002100:	6ba080e7          	jalr	1722(ra) # 800027b6 <mykthread>
    80002104:	fffff097          	auipc	ra,0xfffff
    80002108:	b86080e7          	jalr	-1146(ra) # 80000c8a <release>
  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);

  if (first) {
    8000210c:	00006797          	auipc	a5,0x6
    80002110:	7d47a783          	lw	a5,2004(a5) # 800088e0 <first.1>
    80002114:	eb89                	bnez	a5,80002126 <forkret+0x42>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80002116:	00001097          	auipc	ra,0x1
    8000211a:	8c6080e7          	jalr	-1850(ra) # 800029dc <usertrapret>
}
    8000211e:	60a2                	ld	ra,8(sp)
    80002120:	6402                	ld	s0,0(sp)
    80002122:	0141                	addi	sp,sp,16
    80002124:	8082                	ret
    first = 0;
    80002126:	00006797          	auipc	a5,0x6
    8000212a:	7a07ad23          	sw	zero,1978(a5) # 800088e0 <first.1>
    fsinit(ROOTDEV);
    8000212e:	4505                	li	a0,1
    80002130:	00001097          	auipc	ra,0x1
    80002134:	658080e7          	jalr	1624(ra) # 80003788 <fsinit>
    80002138:	bff9                	j	80002116 <forkret+0x32>

000000008000213a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000213a:	7179                	addi	sp,sp,-48
    8000213c:	f406                	sd	ra,40(sp)
    8000213e:	f022                	sd	s0,32(sp)
    80002140:	ec26                	sd	s1,24(sp)
    80002142:	e84a                	sd	s2,16(sp)
    80002144:	e44e                	sd	s3,8(sp)
    80002146:	e052                	sd	s4,0(sp)
    80002148:	1800                	addi	s0,sp,48
    8000214a:	89aa                	mv	s3,a0
    8000214c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000214e:	00000097          	auipc	ra,0x0
    80002152:	832080e7          	jalr	-1998(ra) # 80001980 <myproc>
    80002156:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	a7e080e7          	jalr	-1410(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    80002160:	02848a13          	addi	s4,s1,40
    80002164:	8552                	mv	a0,s4
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	a70080e7          	jalr	-1424(ra) # 80000bd6 <acquire>
  release(lk);
    8000216e:	854a                	mv	a0,s2
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	b1a080e7          	jalr	-1254(ra) # 80000c8a <release>

  // Go to sleep.
  p->kthread[0].chan = chan;
    80002178:	0534b423          	sd	s3,72(s1)
  p->kthread[0].t_state = SLEEPING_t;
    8000217c:	4789                	li	a5,2
    8000217e:	c0bc                	sw	a5,64(s1)

  sched();
    80002180:	00000097          	auipc	ra,0x0
    80002184:	e26080e7          	jalr	-474(ra) # 80001fa6 <sched>

  // Tidy up.
  p->kthread[0].chan= 0;
    80002188:	0404b423          	sd	zero,72(s1)

  // Reacquire original lock.
  release(&p->kthread[0].t_lock);
    8000218c:	8552                	mv	a0,s4
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	afc080e7          	jalr	-1284(ra) # 80000c8a <release>
  release(&p->lock);
    80002196:	8526                	mv	a0,s1
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	af2080e7          	jalr	-1294(ra) # 80000c8a <release>
  acquire(lk);
    800021a0:	854a                	mv	a0,s2
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	a34080e7          	jalr	-1484(ra) # 80000bd6 <acquire>
}
    800021aa:	70a2                	ld	ra,40(sp)
    800021ac:	7402                	ld	s0,32(sp)
    800021ae:	64e2                	ld	s1,24(sp)
    800021b0:	6942                	ld	s2,16(sp)
    800021b2:	69a2                	ld	s3,8(sp)
    800021b4:	6a02                	ld	s4,0(sp)
    800021b6:	6145                	addi	sp,sp,48
    800021b8:	8082                	ret

00000000800021ba <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021ba:	711d                	addi	sp,sp,-96
    800021bc:	ec86                	sd	ra,88(sp)
    800021be:	e8a2                	sd	s0,80(sp)
    800021c0:	e4a6                	sd	s1,72(sp)
    800021c2:	e0ca                	sd	s2,64(sp)
    800021c4:	fc4e                	sd	s3,56(sp)
    800021c6:	f852                	sd	s4,48(sp)
    800021c8:	f456                	sd	s5,40(sp)
    800021ca:	f05a                	sd	s6,32(sp)
    800021cc:	ec5e                	sd	s7,24(sp)
    800021ce:	e862                	sd	s8,16(sp)
    800021d0:	e466                	sd	s9,8(sp)
    800021d2:	1080                	addi	s0,sp,96
    800021d4:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *kt;
  for(p = proc; p < &proc[NPROC]; p++) {
    800021d6:	0000f497          	auipc	s1,0xf
    800021da:	e7248493          	addi	s1,s1,-398 # 80011048 <proc+0x28>
    800021de:	00016a97          	auipc	s5,0x16
    800021e2:	e6aa8a93          	addi	s5,s5,-406 # 80018048 <bcache+0x10>
              printf("start of wakeup\n");
    800021e6:	00006a17          	auipc	s4,0x6
    800021ea:	0eaa0a13          	addi	s4,s4,234 # 800082d0 <digits+0x290>
    // acquire(&p->lock);
      printf("in wakeup\n");
    800021ee:	00006997          	auipc	s3,0x6
    800021f2:	0fa98993          	addi	s3,s3,250 # 800082e8 <digits+0x2a8>
      // acquire(&p->lock);
    for(kt=p->kthread;kt<&p->kthread[NKT];kt++){
        if(kt !=mykthread()){
          acquire(&kt->t_lock);
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    800021f6:	4b89                	li	s7,2
          kt->t_state = RUNNABLE_t;
        }
        release(&kt->t_lock);
      // release(&p->lock);
          printf("out wakeup\n");
    800021f8:	00006b17          	auipc	s6,0x6
    800021fc:	100b0b13          	addi	s6,s6,256 # 800082f8 <digits+0x2b8>
          kt->t_state = RUNNABLE_t;
    80002200:	4c8d                	li	s9,3
    80002202:	a839                	j	80002220 <wakeup+0x66>
        release(&kt->t_lock);
    80002204:	854a                	mv	a0,s2
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	a84080e7          	jalr	-1404(ra) # 80000c8a <release>
          printf("out wakeup\n");
    8000220e:	855a                	mv	a0,s6
    80002210:	ffffe097          	auipc	ra,0xffffe
    80002214:	378080e7          	jalr	888(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002218:	1c048493          	addi	s1,s1,448
    8000221c:	049a8163          	beq	s5,s1,8000225e <wakeup+0xa4>
              printf("start of wakeup\n");
    80002220:	8552                	mv	a0,s4
    80002222:	ffffe097          	auipc	ra,0xffffe
    80002226:	366080e7          	jalr	870(ra) # 80000588 <printf>
      printf("in wakeup\n");
    8000222a:	854e                	mv	a0,s3
    8000222c:	ffffe097          	auipc	ra,0xffffe
    80002230:	35c080e7          	jalr	860(ra) # 80000588 <printf>
        if(kt !=mykthread()){
    80002234:	00000097          	auipc	ra,0x0
    80002238:	582080e7          	jalr	1410(ra) # 800027b6 <mykthread>
    8000223c:	8926                	mv	s2,s1
    8000223e:	fc950de3          	beq	a0,s1,80002218 <wakeup+0x5e>
          acquire(&kt->t_lock);
    80002242:	8526                	mv	a0,s1
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	992080e7          	jalr	-1646(ra) # 80000bd6 <acquire>
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    8000224c:	4c9c                	lw	a5,24(s1)
    8000224e:	fb779be3          	bne	a5,s7,80002204 <wakeup+0x4a>
    80002252:	709c                	ld	a5,32(s1)
    80002254:	fb8798e3          	bne	a5,s8,80002204 <wakeup+0x4a>
          kt->t_state = RUNNABLE_t;
    80002258:	0194ac23          	sw	s9,24(s1)
    8000225c:	b765                	j	80002204 <wakeup+0x4a>

       }
    }
    // release(&p->lock);
  }
}
    8000225e:	60e6                	ld	ra,88(sp)
    80002260:	6446                	ld	s0,80(sp)
    80002262:	64a6                	ld	s1,72(sp)
    80002264:	6906                	ld	s2,64(sp)
    80002266:	79e2                	ld	s3,56(sp)
    80002268:	7a42                	ld	s4,48(sp)
    8000226a:	7aa2                	ld	s5,40(sp)
    8000226c:	7b02                	ld	s6,32(sp)
    8000226e:	6be2                	ld	s7,24(sp)
    80002270:	6c42                	ld	s8,16(sp)
    80002272:	6ca2                	ld	s9,8(sp)
    80002274:	6125                	addi	sp,sp,96
    80002276:	8082                	ret

0000000080002278 <reparent>:
{
    80002278:	7179                	addi	sp,sp,-48
    8000227a:	f406                	sd	ra,40(sp)
    8000227c:	f022                	sd	s0,32(sp)
    8000227e:	ec26                	sd	s1,24(sp)
    80002280:	e84a                	sd	s2,16(sp)
    80002282:	e44e                	sd	s3,8(sp)
    80002284:	e052                	sd	s4,0(sp)
    80002286:	1800                	addi	s0,sp,48
    80002288:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000228a:	0000f497          	auipc	s1,0xf
    8000228e:	d9648493          	addi	s1,s1,-618 # 80011020 <proc>
      pp->parent = initproc;
    80002292:	00006a17          	auipc	s4,0x6
    80002296:	6e6a0a13          	addi	s4,s4,1766 # 80008978 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000229a:	00016997          	auipc	s3,0x16
    8000229e:	d8698993          	addi	s3,s3,-634 # 80018020 <tickslock>
    800022a2:	a029                	j	800022ac <reparent+0x34>
    800022a4:	1c048493          	addi	s1,s1,448
    800022a8:	01348d63          	beq	s1,s3,800022c2 <reparent+0x4a>
    if(pp->parent == p){
    800022ac:	78fc                	ld	a5,240(s1)
    800022ae:	ff279be3          	bne	a5,s2,800022a4 <reparent+0x2c>
      pp->parent = initproc;
    800022b2:	000a3503          	ld	a0,0(s4)
    800022b6:	f8e8                	sd	a0,240(s1)
      wakeup(initproc);
    800022b8:	00000097          	auipc	ra,0x0
    800022bc:	f02080e7          	jalr	-254(ra) # 800021ba <wakeup>
    800022c0:	b7d5                	j	800022a4 <reparent+0x2c>
}
    800022c2:	70a2                	ld	ra,40(sp)
    800022c4:	7402                	ld	s0,32(sp)
    800022c6:	64e2                	ld	s1,24(sp)
    800022c8:	6942                	ld	s2,16(sp)
    800022ca:	69a2                	ld	s3,8(sp)
    800022cc:	6a02                	ld	s4,0(sp)
    800022ce:	6145                	addi	sp,sp,48
    800022d0:	8082                	ret

00000000800022d2 <exit>:
{
    800022d2:	7179                	addi	sp,sp,-48
    800022d4:	f406                	sd	ra,40(sp)
    800022d6:	f022                	sd	s0,32(sp)
    800022d8:	ec26                	sd	s1,24(sp)
    800022da:	e84a                	sd	s2,16(sp)
    800022dc:	e44e                	sd	s3,8(sp)
    800022de:	e052                	sd	s4,0(sp)
    800022e0:	1800                	addi	s0,sp,48
    800022e2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	69c080e7          	jalr	1692(ra) # 80001980 <myproc>
    800022ec:	89aa                	mv	s3,a0
  if(p == initproc)
    800022ee:	00006797          	auipc	a5,0x6
    800022f2:	68a7b783          	ld	a5,1674(a5) # 80008978 <initproc>
    800022f6:	10850493          	addi	s1,a0,264
    800022fa:	18850913          	addi	s2,a0,392
    800022fe:	02a79363          	bne	a5,a0,80002324 <exit+0x52>
    panic("init exiting");
    80002302:	00006517          	auipc	a0,0x6
    80002306:	00650513          	addi	a0,a0,6 # 80008308 <digits+0x2c8>
    8000230a:	ffffe097          	auipc	ra,0xffffe
    8000230e:	234080e7          	jalr	564(ra) # 8000053e <panic>
      fileclose(f);
    80002312:	00002097          	auipc	ra,0x2
    80002316:	580080e7          	jalr	1408(ra) # 80004892 <fileclose>
      p->ofile[fd] = 0;
    8000231a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000231e:	04a1                	addi	s1,s1,8
    80002320:	01248563          	beq	s1,s2,8000232a <exit+0x58>
    if(p->ofile[fd]){
    80002324:	6088                	ld	a0,0(s1)
    80002326:	f575                	bnez	a0,80002312 <exit+0x40>
    80002328:	bfdd                	j	8000231e <exit+0x4c>
  begin_op();
    8000232a:	00002097          	auipc	ra,0x2
    8000232e:	09c080e7          	jalr	156(ra) # 800043c6 <begin_op>
  iput(p->cwd);
    80002332:	1889b503          	ld	a0,392(s3)
    80002336:	00002097          	auipc	ra,0x2
    8000233a:	888080e7          	jalr	-1912(ra) # 80003bbe <iput>
  end_op();
    8000233e:	00002097          	auipc	ra,0x2
    80002342:	108080e7          	jalr	264(ra) # 80004446 <end_op>
  p->cwd = 0;
    80002346:	1809b423          	sd	zero,392(s3)
  acquire(&wait_lock);
    8000234a:	0000f497          	auipc	s1,0xf
    8000234e:	8be48493          	addi	s1,s1,-1858 # 80010c08 <wait_lock>
    80002352:	8526                	mv	a0,s1
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	882080e7          	jalr	-1918(ra) # 80000bd6 <acquire>
  reparent(p);
    8000235c:	854e                	mv	a0,s3
    8000235e:	00000097          	auipc	ra,0x0
    80002362:	f1a080e7          	jalr	-230(ra) # 80002278 <reparent>
  wakeup(p->parent);
    80002366:	0f09b503          	ld	a0,240(s3)
    8000236a:	00000097          	auipc	ra,0x0
    8000236e:	e50080e7          	jalr	-432(ra) # 800021ba <wakeup>
  acquire(&p->lock);
    80002372:	854e                	mv	a0,s3
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	862080e7          	jalr	-1950(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    8000237c:	02898913          	addi	s2,s3,40
    80002380:	854a                	mv	a0,s2
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	854080e7          	jalr	-1964(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state=ZOMBIE_t;
    8000238a:	4795                	li	a5,5
    8000238c:	04f9a023          	sw	a5,64(s3)
  release(&p->kthread[0].t_lock);
    80002390:	854a                	mv	a0,s2
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	8f8080e7          	jalr	-1800(ra) # 80000c8a <release>
  p->xstate = status;
    8000239a:	0349a023          	sw	s4,32(s3)
  p->state = ZOMBIE;
    8000239e:	4789                	li	a5,2
    800023a0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	8e4080e7          	jalr	-1820(ra) # 80000c8a <release>
  sched();
    800023ae:	00000097          	auipc	ra,0x0
    800023b2:	bf8080e7          	jalr	-1032(ra) # 80001fa6 <sched>
  release(&p->lock);
    800023b6:	854e                	mv	a0,s3
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	8d2080e7          	jalr	-1838(ra) # 80000c8a <release>
  panic("zombie exit");
    800023c0:	00006517          	auipc	a0,0x6
    800023c4:	f5850513          	addi	a0,a0,-168 # 80008318 <digits+0x2d8>
    800023c8:	ffffe097          	auipc	ra,0xffffe
    800023cc:	176080e7          	jalr	374(ra) # 8000053e <panic>

00000000800023d0 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023d0:	7179                	addi	sp,sp,-48
    800023d2:	f406                	sd	ra,40(sp)
    800023d4:	f022                	sd	s0,32(sp)
    800023d6:	ec26                	sd	s1,24(sp)
    800023d8:	e84a                	sd	s2,16(sp)
    800023da:	e44e                	sd	s3,8(sp)
    800023dc:	1800                	addi	s0,sp,48
    800023de:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023e0:	0000f497          	auipc	s1,0xf
    800023e4:	c4048493          	addi	s1,s1,-960 # 80011020 <proc>
    800023e8:	00016997          	auipc	s3,0x16
    800023ec:	c3898993          	addi	s3,s3,-968 # 80018020 <tickslock>
    acquire(&p->lock);
    800023f0:	8526                	mv	a0,s1
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	7e4080e7          	jalr	2020(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800023fa:	50dc                	lw	a5,36(s1)
    800023fc:	01278d63          	beq	a5,s2,80002416 <kill+0x46>
      // }
      release(&p->lock);
      return 0;
    }
    
    release(&p->lock);
    80002400:	8526                	mv	a0,s1
    80002402:	fffff097          	auipc	ra,0xfffff
    80002406:	888080e7          	jalr	-1912(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000240a:	1c048493          	addi	s1,s1,448
    8000240e:	ff3491e3          	bne	s1,s3,800023f0 <kill+0x20>
  }
  return -1;
    80002412:	557d                	li	a0,-1
    80002414:	a80d                	j	80002446 <kill+0x76>
      p->killed = 1;
    80002416:	4785                	li	a5,1
    80002418:	ccdc                	sw	a5,28(s1)
        acquire(&t->t_lock);
    8000241a:	02848913          	addi	s2,s1,40
    8000241e:	854a                	mv	a0,s2
    80002420:	ffffe097          	auipc	ra,0xffffe
    80002424:	7b6080e7          	jalr	1974(ra) # 80000bd6 <acquire>
        if(t->t_state == SLEEPING_t) {
    80002428:	40b8                	lw	a4,64(s1)
    8000242a:	4789                	li	a5,2
    8000242c:	02f70463          	beq	a4,a5,80002454 <kill+0x84>
        release(&t->t_lock);
    80002430:	854a                	mv	a0,s2
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
      release(&p->lock);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	84e080e7          	jalr	-1970(ra) # 80000c8a <release>
      return 0;
    80002444:	4501                	li	a0,0
}
    80002446:	70a2                	ld	ra,40(sp)
    80002448:	7402                	ld	s0,32(sp)
    8000244a:	64e2                	ld	s1,24(sp)
    8000244c:	6942                	ld	s2,16(sp)
    8000244e:	69a2                	ld	s3,8(sp)
    80002450:	6145                	addi	sp,sp,48
    80002452:	8082                	ret
          t->t_state = RUNNABLE_t;
    80002454:	478d                	li	a5,3
    80002456:	c0bc                	sw	a5,64(s1)
    80002458:	bfe1                	j	80002430 <kill+0x60>

000000008000245a <setkilled>:


void
setkilled(struct proc *p)
{
    8000245a:	1101                	addi	sp,sp,-32
    8000245c:	ec06                	sd	ra,24(sp)
    8000245e:	e822                	sd	s0,16(sp)
    80002460:	e426                	sd	s1,8(sp)
    80002462:	1000                	addi	s0,sp,32
    80002464:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002466:	ffffe097          	auipc	ra,0xffffe
    8000246a:	770080e7          	jalr	1904(ra) # 80000bd6 <acquire>
  p->killed = 1;
    8000246e:	4785                	li	a5,1
    80002470:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	816080e7          	jalr	-2026(ra) # 80000c8a <release>
}
    8000247c:	60e2                	ld	ra,24(sp)
    8000247e:	6442                	ld	s0,16(sp)
    80002480:	64a2                	ld	s1,8(sp)
    80002482:	6105                	addi	sp,sp,32
    80002484:	8082                	ret

0000000080002486 <killed>:

int
killed(struct proc *p)
{
    80002486:	1101                	addi	sp,sp,-32
    80002488:	ec06                	sd	ra,24(sp)
    8000248a:	e822                	sd	s0,16(sp)
    8000248c:	e426                	sd	s1,8(sp)
    8000248e:	e04a                	sd	s2,0(sp)
    80002490:	1000                	addi	s0,sp,32
    80002492:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	742080e7          	jalr	1858(ra) # 80000bd6 <acquire>
  k = p->killed;
    8000249c:	01c4a903          	lw	s2,28(s1)
  release(&p->lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	7e8080e7          	jalr	2024(ra) # 80000c8a <release>
  return k;
}
    800024aa:	854a                	mv	a0,s2
    800024ac:	60e2                	ld	ra,24(sp)
    800024ae:	6442                	ld	s0,16(sp)
    800024b0:	64a2                	ld	s1,8(sp)
    800024b2:	6902                	ld	s2,0(sp)
    800024b4:	6105                	addi	sp,sp,32
    800024b6:	8082                	ret

00000000800024b8 <wait>:
{
    800024b8:	715d                	addi	sp,sp,-80
    800024ba:	e486                	sd	ra,72(sp)
    800024bc:	e0a2                	sd	s0,64(sp)
    800024be:	fc26                	sd	s1,56(sp)
    800024c0:	f84a                	sd	s2,48(sp)
    800024c2:	f44e                	sd	s3,40(sp)
    800024c4:	f052                	sd	s4,32(sp)
    800024c6:	ec56                	sd	s5,24(sp)
    800024c8:	e85a                	sd	s6,16(sp)
    800024ca:	e45e                	sd	s7,8(sp)
    800024cc:	e062                	sd	s8,0(sp)
    800024ce:	0880                	addi	s0,sp,80
    800024d0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	4ae080e7          	jalr	1198(ra) # 80001980 <myproc>
    800024da:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024dc:	0000e517          	auipc	a0,0xe
    800024e0:	72c50513          	addi	a0,a0,1836 # 80010c08 <wait_lock>
    800024e4:	ffffe097          	auipc	ra,0xffffe
    800024e8:	6f2080e7          	jalr	1778(ra) # 80000bd6 <acquire>
    havekids = 0;
    800024ec:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800024ee:	4a09                	li	s4,2
        havekids = 1;
    800024f0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024f2:	00016997          	auipc	s3,0x16
    800024f6:	b2e98993          	addi	s3,s3,-1234 # 80018020 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024fa:	0000ec17          	auipc	s8,0xe
    800024fe:	70ec0c13          	addi	s8,s8,1806 # 80010c08 <wait_lock>
    havekids = 0;
    80002502:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002504:	0000f497          	auipc	s1,0xf
    80002508:	b1c48493          	addi	s1,s1,-1252 # 80011020 <proc>
    8000250c:	a0bd                	j	8000257a <wait+0xc2>
          pid = pp->pid;
    8000250e:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002512:	000b0e63          	beqz	s6,8000252e <wait+0x76>
    80002516:	4691                	li	a3,4
    80002518:	02048613          	addi	a2,s1,32
    8000251c:	85da                	mv	a1,s6
    8000251e:	10093503          	ld	a0,256(s2)
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	146080e7          	jalr	326(ra) # 80001668 <copyout>
    8000252a:	02054563          	bltz	a0,80002554 <wait+0x9c>
          freeproc(pp);
    8000252e:	8526                	mv	a0,s1
    80002530:	fffff097          	auipc	ra,0xfffff
    80002534:	5c0080e7          	jalr	1472(ra) # 80001af0 <freeproc>
          release(&pp->lock);
    80002538:	8526                	mv	a0,s1
    8000253a:	ffffe097          	auipc	ra,0xffffe
    8000253e:	750080e7          	jalr	1872(ra) # 80000c8a <release>
          release(&wait_lock);
    80002542:	0000e517          	auipc	a0,0xe
    80002546:	6c650513          	addi	a0,a0,1734 # 80010c08 <wait_lock>
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	740080e7          	jalr	1856(ra) # 80000c8a <release>
          return pid;
    80002552:	a0b5                	j	800025be <wait+0x106>
            release(&pp->lock);
    80002554:	8526                	mv	a0,s1
    80002556:	ffffe097          	auipc	ra,0xffffe
    8000255a:	734080e7          	jalr	1844(ra) # 80000c8a <release>
            release(&wait_lock);
    8000255e:	0000e517          	auipc	a0,0xe
    80002562:	6aa50513          	addi	a0,a0,1706 # 80010c08 <wait_lock>
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	724080e7          	jalr	1828(ra) # 80000c8a <release>
            return -1;
    8000256e:	59fd                	li	s3,-1
    80002570:	a0b9                	j	800025be <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002572:	1c048493          	addi	s1,s1,448
    80002576:	03348463          	beq	s1,s3,8000259e <wait+0xe6>
      if(pp->parent == p){
    8000257a:	78fc                	ld	a5,240(s1)
    8000257c:	ff279be3          	bne	a5,s2,80002572 <wait+0xba>
        acquire(&pp->lock);
    80002580:	8526                	mv	a0,s1
    80002582:	ffffe097          	auipc	ra,0xffffe
    80002586:	654080e7          	jalr	1620(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    8000258a:	4c9c                	lw	a5,24(s1)
    8000258c:	f94781e3          	beq	a5,s4,8000250e <wait+0x56>
        release(&pp->lock);
    80002590:	8526                	mv	a0,s1
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	6f8080e7          	jalr	1784(ra) # 80000c8a <release>
        havekids = 1;
    8000259a:	8756                	mv	a4,s5
    8000259c:	bfd9                	j	80002572 <wait+0xba>
    if(!havekids || killed(p)){
    8000259e:	c719                	beqz	a4,800025ac <wait+0xf4>
    800025a0:	854a                	mv	a0,s2
    800025a2:	00000097          	auipc	ra,0x0
    800025a6:	ee4080e7          	jalr	-284(ra) # 80002486 <killed>
    800025aa:	c51d                	beqz	a0,800025d8 <wait+0x120>
      release(&wait_lock);
    800025ac:	0000e517          	auipc	a0,0xe
    800025b0:	65c50513          	addi	a0,a0,1628 # 80010c08 <wait_lock>
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	6d6080e7          	jalr	1750(ra) # 80000c8a <release>
      return -1;
    800025bc:	59fd                	li	s3,-1
}
    800025be:	854e                	mv	a0,s3
    800025c0:	60a6                	ld	ra,72(sp)
    800025c2:	6406                	ld	s0,64(sp)
    800025c4:	74e2                	ld	s1,56(sp)
    800025c6:	7942                	ld	s2,48(sp)
    800025c8:	79a2                	ld	s3,40(sp)
    800025ca:	7a02                	ld	s4,32(sp)
    800025cc:	6ae2                	ld	s5,24(sp)
    800025ce:	6b42                	ld	s6,16(sp)
    800025d0:	6ba2                	ld	s7,8(sp)
    800025d2:	6c02                	ld	s8,0(sp)
    800025d4:	6161                	addi	sp,sp,80
    800025d6:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025d8:	85e2                	mv	a1,s8
    800025da:	854a                	mv	a0,s2
    800025dc:	00000097          	auipc	ra,0x0
    800025e0:	b5e080e7          	jalr	-1186(ra) # 8000213a <sleep>
    havekids = 0;
    800025e4:	bf39                	j	80002502 <wait+0x4a>

00000000800025e6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025e6:	7179                	addi	sp,sp,-48
    800025e8:	f406                	sd	ra,40(sp)
    800025ea:	f022                	sd	s0,32(sp)
    800025ec:	ec26                	sd	s1,24(sp)
    800025ee:	e84a                	sd	s2,16(sp)
    800025f0:	e44e                	sd	s3,8(sp)
    800025f2:	e052                	sd	s4,0(sp)
    800025f4:	1800                	addi	s0,sp,48
    800025f6:	84aa                	mv	s1,a0
    800025f8:	892e                	mv	s2,a1
    800025fa:	89b2                	mv	s3,a2
    800025fc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025fe:	fffff097          	auipc	ra,0xfffff
    80002602:	382080e7          	jalr	898(ra) # 80001980 <myproc>
  if(user_dst){
    80002606:	c095                	beqz	s1,8000262a <either_copyout+0x44>
    return copyout(p->pagetable, dst, src, len);
    80002608:	86d2                	mv	a3,s4
    8000260a:	864e                	mv	a2,s3
    8000260c:	85ca                	mv	a1,s2
    8000260e:	10053503          	ld	a0,256(a0)
    80002612:	fffff097          	auipc	ra,0xfffff
    80002616:	056080e7          	jalr	86(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000261a:	70a2                	ld	ra,40(sp)
    8000261c:	7402                	ld	s0,32(sp)
    8000261e:	64e2                	ld	s1,24(sp)
    80002620:	6942                	ld	s2,16(sp)
    80002622:	69a2                	ld	s3,8(sp)
    80002624:	6a02                	ld	s4,0(sp)
    80002626:	6145                	addi	sp,sp,48
    80002628:	8082                	ret
    memmove((char *)dst, src, len);
    8000262a:	000a061b          	sext.w	a2,s4
    8000262e:	85ce                	mv	a1,s3
    80002630:	854a                	mv	a0,s2
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	6fc080e7          	jalr	1788(ra) # 80000d2e <memmove>
    return 0;
    8000263a:	8526                	mv	a0,s1
    8000263c:	bff9                	j	8000261a <either_copyout+0x34>

000000008000263e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000263e:	7179                	addi	sp,sp,-48
    80002640:	f406                	sd	ra,40(sp)
    80002642:	f022                	sd	s0,32(sp)
    80002644:	ec26                	sd	s1,24(sp)
    80002646:	e84a                	sd	s2,16(sp)
    80002648:	e44e                	sd	s3,8(sp)
    8000264a:	e052                	sd	s4,0(sp)
    8000264c:	1800                	addi	s0,sp,48
    8000264e:	892a                	mv	s2,a0
    80002650:	84ae                	mv	s1,a1
    80002652:	89b2                	mv	s3,a2
    80002654:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002656:	fffff097          	auipc	ra,0xfffff
    8000265a:	32a080e7          	jalr	810(ra) # 80001980 <myproc>
  if(user_src){
    8000265e:	c095                	beqz	s1,80002682 <either_copyin+0x44>
    return copyin(p->pagetable, dst, src, len);
    80002660:	86d2                	mv	a3,s4
    80002662:	864e                	mv	a2,s3
    80002664:	85ca                	mv	a1,s2
    80002666:	10053503          	ld	a0,256(a0)
    8000266a:	fffff097          	auipc	ra,0xfffff
    8000266e:	08a080e7          	jalr	138(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002672:	70a2                	ld	ra,40(sp)
    80002674:	7402                	ld	s0,32(sp)
    80002676:	64e2                	ld	s1,24(sp)
    80002678:	6942                	ld	s2,16(sp)
    8000267a:	69a2                	ld	s3,8(sp)
    8000267c:	6a02                	ld	s4,0(sp)
    8000267e:	6145                	addi	sp,sp,48
    80002680:	8082                	ret
    memmove(dst, (char*)src, len);
    80002682:	000a061b          	sext.w	a2,s4
    80002686:	85ce                	mv	a1,s3
    80002688:	854a                	mv	a0,s2
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	6a4080e7          	jalr	1700(ra) # 80000d2e <memmove>
    return 0;
    80002692:	8526                	mv	a0,s1
    80002694:	bff9                	j	80002672 <either_copyin+0x34>

0000000080002696 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002696:	715d                	addi	sp,sp,-80
    80002698:	e486                	sd	ra,72(sp)
    8000269a:	e0a2                	sd	s0,64(sp)
    8000269c:	fc26                	sd	s1,56(sp)
    8000269e:	f84a                	sd	s2,48(sp)
    800026a0:	f44e                	sd	s3,40(sp)
    800026a2:	f052                	sd	s4,32(sp)
    800026a4:	ec56                	sd	s5,24(sp)
    800026a6:	e85a                	sd	s6,16(sp)
    800026a8:	e45e                	sd	s7,8(sp)
    800026aa:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800026ac:	00006517          	auipc	a0,0x6
    800026b0:	c0c50513          	addi	a0,a0,-1012 # 800082b8 <digits+0x278>
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	ed4080e7          	jalr	-300(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026bc:	0000f497          	auipc	s1,0xf
    800026c0:	af448493          	addi	s1,s1,-1292 # 800111b0 <proc+0x190>
    800026c4:	00016917          	auipc	s2,0x16
    800026c8:	aec90913          	addi	s2,s2,-1300 # 800181b0 <bcache+0x178>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026cc:	4b09                	li	s6,2
      state = states[p->state];
    else
      state = "???";
    800026ce:	00006997          	auipc	s3,0x6
    800026d2:	c5a98993          	addi	s3,s3,-934 # 80008328 <digits+0x2e8>
    printf("%d %s %s", p->pid, state, p->name);
    800026d6:	00006a97          	auipc	s5,0x6
    800026da:	c5aa8a93          	addi	s5,s5,-934 # 80008330 <digits+0x2f0>
    printf("\n");
    800026de:	00006a17          	auipc	s4,0x6
    800026e2:	bdaa0a13          	addi	s4,s4,-1062 # 800082b8 <digits+0x278>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026e6:	00006b97          	auipc	s7,0x6
    800026ea:	c72b8b93          	addi	s7,s7,-910 # 80008358 <states.0>
    800026ee:	a00d                	j	80002710 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026f0:	e946a583          	lw	a1,-364(a3)
    800026f4:	8556                	mv	a0,s5
    800026f6:	ffffe097          	auipc	ra,0xffffe
    800026fa:	e92080e7          	jalr	-366(ra) # 80000588 <printf>
    printf("\n");
    800026fe:	8552                	mv	a0,s4
    80002700:	ffffe097          	auipc	ra,0xffffe
    80002704:	e88080e7          	jalr	-376(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002708:	1c048493          	addi	s1,s1,448
    8000270c:	03248163          	beq	s1,s2,8000272e <procdump+0x98>
    if(p->state == UNUSED)
    80002710:	86a6                	mv	a3,s1
    80002712:	e884a783          	lw	a5,-376(s1)
    80002716:	dbed                	beqz	a5,80002708 <procdump+0x72>
      state = "???";
    80002718:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000271a:	fcfb6be3          	bltu	s6,a5,800026f0 <procdump+0x5a>
    8000271e:	1782                	slli	a5,a5,0x20
    80002720:	9381                	srli	a5,a5,0x20
    80002722:	078e                	slli	a5,a5,0x3
    80002724:	97de                	add	a5,a5,s7
    80002726:	6390                	ld	a2,0(a5)
    80002728:	f661                	bnez	a2,800026f0 <procdump+0x5a>
      state = "???";
    8000272a:	864e                	mv	a2,s3
    8000272c:	b7d1                	j	800026f0 <procdump+0x5a>
  }
}
    8000272e:	60a6                	ld	ra,72(sp)
    80002730:	6406                	ld	s0,64(sp)
    80002732:	74e2                	ld	s1,56(sp)
    80002734:	7942                	ld	s2,48(sp)
    80002736:	79a2                	ld	s3,40(sp)
    80002738:	7a02                	ld	s4,32(sp)
    8000273a:	6ae2                	ld	s5,24(sp)
    8000273c:	6b42                	ld	s6,16(sp)
    8000273e:	6ba2                	ld	s7,8(sp)
    80002740:	6161                	addi	sp,sp,80
    80002742:	8082                	ret

0000000080002744 <kthreadinit>:
#include "defs.h"

extern struct proc proc[NPROC];
extern void forkret(void);
void kthreadinit(struct proc *p)
{
    80002744:	1101                	addi	sp,sp,-32
    80002746:	ec06                	sd	ra,24(sp)
    80002748:	e822                	sd	s0,16(sp)
    8000274a:	e426                	sd	s1,8(sp)
    8000274c:	1000                	addi	s0,sp,32
    8000274e:	84aa                	mv	s1,a0
  initlock(&(p->alloc_lock),"aloc_thread");
    80002750:	00006597          	auipc	a1,0x6
    80002754:	c2058593          	addi	a1,a1,-992 # 80008370 <states.0+0x18>
    80002758:	1a850513          	addi	a0,a0,424
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	3ea080e7          	jalr	1002(ra) # 80000b46 <initlock>
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
    80002764:	00006597          	auipc	a1,0x6
    80002768:	c1c58593          	addi	a1,a1,-996 # 80008380 <states.0+0x28>
    8000276c:	02848513          	addi	a0,s1,40
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	3d6080e7          	jalr	982(ra) # 80000b46 <initlock>
      kt->t_state = UNUSED_t;
    80002778:	0404a023          	sw	zero,64(s1)
      kt->process=p;
    8000277c:	f0a4                	sd	s1,96(s1)
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    8000277e:	0000f797          	auipc	a5,0xf
    80002782:	8a278793          	addi	a5,a5,-1886 # 80011020 <proc>
    80002786:	40f487b3          	sub	a5,s1,a5
    8000278a:	8799                	srai	a5,a5,0x6
    8000278c:	00006717          	auipc	a4,0x6
    80002790:	87473703          	ld	a4,-1932(a4) # 80008000 <etext>
    80002794:	02e787b3          	mul	a5,a5,a4
    80002798:	2785                	addiw	a5,a5,1
    8000279a:	00d7979b          	slliw	a5,a5,0xd
    8000279e:	04000737          	lui	a4,0x4000
    800027a2:	177d                	addi	a4,a4,-1
    800027a4:	0732                	slli	a4,a4,0xc
    800027a6:	40f707b3          	sub	a5,a4,a5
    800027aa:	ecfc                	sd	a5,216(s1)
  }
}
    800027ac:	60e2                	ld	ra,24(sp)
    800027ae:	6442                	ld	s0,16(sp)
    800027b0:	64a2                	ld	s1,8(sp)
    800027b2:	6105                	addi	sp,sp,32
    800027b4:	8082                	ret

00000000800027b6 <mykthread>:

struct kthread *mykthread()
{
    800027b6:	1101                	addi	sp,sp,-32
    800027b8:	ec06                	sd	ra,24(sp)
    800027ba:	e822                	sd	s0,16(sp)
    800027bc:	e426                	sd	s1,8(sp)
    800027be:	1000                	addi	s0,sp,32
  push_off();
    800027c0:	ffffe097          	auipc	ra,0xffffe
    800027c4:	3ca080e7          	jalr	970(ra) # 80000b8a <push_off>
  struct cpu *c = mycpu();
    800027c8:	fffff097          	auipc	ra,0xfffff
    800027cc:	19c080e7          	jalr	412(ra) # 80001964 <mycpu>
  struct kthread *kthread = c->kthread;
    800027d0:	6104                	ld	s1,0(a0)
  pop_off();
    800027d2:	ffffe097          	auipc	ra,0xffffe
    800027d6:	458080e7          	jalr	1112(ra) # 80000c2a <pop_off>
  return kthread;
}
    800027da:	8526                	mv	a0,s1
    800027dc:	60e2                	ld	ra,24(sp)
    800027de:	6442                	ld	s0,16(sp)
    800027e0:	64a2                	ld	s1,8(sp)
    800027e2:	6105                	addi	sp,sp,32
    800027e4:	8082                	ret

00000000800027e6 <alloctid>:

int alloctid(struct proc *p){
    800027e6:	7179                	addi	sp,sp,-48
    800027e8:	f406                	sd	ra,40(sp)
    800027ea:	f022                	sd	s0,32(sp)
    800027ec:	ec26                	sd	s1,24(sp)
    800027ee:	e84a                	sd	s2,16(sp)
    800027f0:	e44e                	sd	s3,8(sp)
    800027f2:	1800                	addi	s0,sp,48
    800027f4:	84aa                	mv	s1,a0
  int tid;
  acquire(&(p->alloc_lock));
    800027f6:	1a850993          	addi	s3,a0,424
    800027fa:	854e                	mv	a0,s3
    800027fc:	ffffe097          	auipc	ra,0xffffe
    80002800:	3da080e7          	jalr	986(ra) # 80000bd6 <acquire>
  tid = p->p_counter;
    80002804:	1a04a903          	lw	s2,416(s1)
  p->p_counter++;
    80002808:	0019079b          	addiw	a5,s2,1
    8000280c:	1af4a023          	sw	a5,416(s1)
  release(&(p->alloc_lock));
    80002810:	854e                	mv	a0,s3
    80002812:	ffffe097          	auipc	ra,0xffffe
    80002816:	478080e7          	jalr	1144(ra) # 80000c8a <release>
  return tid;
}
    8000281a:	854a                	mv	a0,s2
    8000281c:	70a2                	ld	ra,40(sp)
    8000281e:	7402                	ld	s0,32(sp)
    80002820:	64e2                	ld	s1,24(sp)
    80002822:	6942                	ld	s2,16(sp)
    80002824:	69a2                	ld	s3,8(sp)
    80002826:	6145                	addi	sp,sp,48
    80002828:	8082                	ret

000000008000282a <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    8000282a:	1141                	addi	sp,sp,-16
    8000282c:	e422                	sd	s0,8(sp)
    8000282e:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    80002830:	02850793          	addi	a5,a0,40
    80002834:	8d9d                	sub	a1,a1,a5
    80002836:	8599                	srai	a1,a1,0x6
    80002838:	00005797          	auipc	a5,0x5
    8000283c:	7d07b783          	ld	a5,2000(a5) # 80008008 <etext+0x8>
    80002840:	02f585bb          	mulw	a1,a1,a5
    80002844:	00359793          	slli	a5,a1,0x3
    80002848:	95be                	add	a1,a1,a5
    8000284a:	0596                	slli	a1,a1,0x5
    8000284c:	7568                	ld	a0,232(a0)
}
    8000284e:	952e                	add	a0,a0,a1
    80002850:	6422                	ld	s0,8(sp)
    80002852:	0141                	addi	sp,sp,16
    80002854:	8082                	ret

0000000080002856 <allockthread>:

struct kthread* allockthread(struct proc *p){
    80002856:	1101                	addi	sp,sp,-32
    80002858:	ec06                	sd	ra,24(sp)
    8000285a:	e822                	sd	s0,16(sp)
    8000285c:	e426                	sd	s1,8(sp)
    8000285e:	e04a                	sd	s2,0(sp)
    80002860:	1000                	addi	s0,sp,32
    80002862:	84aa                	mv	s1,a0
  
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    80002864:	02850913          	addi	s2,a0,40
    {
      acquire(&kt->t_lock);
    80002868:	854a                	mv	a0,s2
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	36c080e7          	jalr	876(ra) # 80000bd6 <acquire>
      if(kt->t_state == UNUSED_t) {
    80002872:	40bc                	lw	a5,64(s1)
    80002874:	cf91                	beqz	a5,80002890 <allockthread+0x3a>
        kt->context.ra = (uint64)forkret;
        kt->context.sp = kt->kstack + PGSIZE;
        return kt;
      } 
      else {
        release(&kt->t_lock);
    80002876:	854a                	mv	a0,s2
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	412080e7          	jalr	1042(ra) # 80000c8a <release>
      }
  }
  return 0;
    80002880:	4901                	li	s2,0
}
    80002882:	854a                	mv	a0,s2
    80002884:	60e2                	ld	ra,24(sp)
    80002886:	6442                	ld	s0,16(sp)
    80002888:	64a2                	ld	s1,8(sp)
    8000288a:	6902                	ld	s2,0(sp)
    8000288c:	6105                	addi	sp,sp,32
    8000288e:	8082                	ret
        kt->tid = alloctid(p);
    80002890:	8526                	mv	a0,s1
    80002892:	00000097          	auipc	ra,0x0
    80002896:	f54080e7          	jalr	-172(ra) # 800027e6 <alloctid>
    8000289a:	cca8                	sw	a0,88(s1)
        kt->t_state = USED_t;
    8000289c:	4785                	li	a5,1
    8000289e:	c0bc                	sw	a5,64(s1)
        kt->process=p;
    800028a0:	f0a4                	sd	s1,96(s1)
        kt->trapframe = get_kthread_trapframe(p,kt);
    800028a2:	85ca                	mv	a1,s2
    800028a4:	8526                	mv	a0,s1
    800028a6:	00000097          	auipc	ra,0x0
    800028aa:	f84080e7          	jalr	-124(ra) # 8000282a <get_kthread_trapframe>
    800028ae:	f0e8                	sd	a0,224(s1)
        memset(&kt->context, 0, sizeof(kt->context));   
    800028b0:	07000613          	li	a2,112
    800028b4:	4581                	li	a1,0
    800028b6:	06848513          	addi	a0,s1,104
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	418080e7          	jalr	1048(ra) # 80000cd2 <memset>
        kt->context.ra = (uint64)forkret;
    800028c2:	00000797          	auipc	a5,0x0
    800028c6:	82278793          	addi	a5,a5,-2014 # 800020e4 <forkret>
    800028ca:	f4bc                	sd	a5,104(s1)
        kt->context.sp = kt->kstack + PGSIZE;
    800028cc:	6cfc                	ld	a5,216(s1)
    800028ce:	6705                	lui	a4,0x1
    800028d0:	97ba                	add	a5,a5,a4
    800028d2:	f8bc                	sd	a5,112(s1)
        return kt;
    800028d4:	b77d                	j	80002882 <allockthread+0x2c>

00000000800028d6 <freethread>:

void
freethread(struct kthread *t){
    800028d6:	1101                	addi	sp,sp,-32
    800028d8:	ec06                	sd	ra,24(sp)
    800028da:	e822                	sd	s0,16(sp)
    800028dc:	e426                	sd	s1,8(sp)
    800028de:	1000                	addi	s0,sp,32
    800028e0:	84aa                	mv	s1,a0
  t->chan = 0;
    800028e2:	02053023          	sd	zero,32(a0)
  t->t_killed = 0;
    800028e6:	02052423          	sw	zero,40(a0)
  t->t_xstate = 0;
    800028ea:	02052623          	sw	zero,44(a0)
  t->t_state = UNUSED_t;
    800028ee:	00052c23          	sw	zero,24(a0)
  t->tid=0;
    800028f2:	02052823          	sw	zero,48(a0)
  t->process=0;
    800028f6:	02053c23          	sd	zero,56(a0)
  t->kstack=0;
    800028fa:	0a053823          	sd	zero,176(a0)
  if(t->trapframe)
    800028fe:	7d48                	ld	a0,184(a0)
    80002900:	c509                	beqz	a0,8000290a <freethread+0x34>
    kfree((void*)t->trapframe);
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	0e8080e7          	jalr	232(ra) # 800009ea <kfree>
  t->trapframe = 0;
    8000290a:	0a04bc23          	sd	zero,184(s1)
  memset(&t->context,0,sizeof(&t->context));
    8000290e:	4621                	li	a2,8
    80002910:	4581                	li	a1,0
    80002912:	04048513          	addi	a0,s1,64
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	3bc080e7          	jalr	956(ra) # 80000cd2 <memset>
  release(&t->t_lock);
    8000291e:	8526                	mv	a0,s1
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	36a080e7          	jalr	874(ra) # 80000c8a <release>
}
    80002928:	60e2                	ld	ra,24(sp)
    8000292a:	6442                	ld	s0,16(sp)
    8000292c:	64a2                	ld	s1,8(sp)
    8000292e:	6105                	addi	sp,sp,32
    80002930:	8082                	ret

0000000080002932 <swtch>:
    80002932:	00153023          	sd	ra,0(a0)
    80002936:	00253423          	sd	sp,8(a0)
    8000293a:	e900                	sd	s0,16(a0)
    8000293c:	ed04                	sd	s1,24(a0)
    8000293e:	03253023          	sd	s2,32(a0)
    80002942:	03353423          	sd	s3,40(a0)
    80002946:	03453823          	sd	s4,48(a0)
    8000294a:	03553c23          	sd	s5,56(a0)
    8000294e:	05653023          	sd	s6,64(a0)
    80002952:	05753423          	sd	s7,72(a0)
    80002956:	05853823          	sd	s8,80(a0)
    8000295a:	05953c23          	sd	s9,88(a0)
    8000295e:	07a53023          	sd	s10,96(a0)
    80002962:	07b53423          	sd	s11,104(a0)
    80002966:	0005b083          	ld	ra,0(a1)
    8000296a:	0085b103          	ld	sp,8(a1)
    8000296e:	6980                	ld	s0,16(a1)
    80002970:	6d84                	ld	s1,24(a1)
    80002972:	0205b903          	ld	s2,32(a1)
    80002976:	0285b983          	ld	s3,40(a1)
    8000297a:	0305ba03          	ld	s4,48(a1)
    8000297e:	0385ba83          	ld	s5,56(a1)
    80002982:	0405bb03          	ld	s6,64(a1)
    80002986:	0485bb83          	ld	s7,72(a1)
    8000298a:	0505bc03          	ld	s8,80(a1)
    8000298e:	0585bc83          	ld	s9,88(a1)
    80002992:	0605bd03          	ld	s10,96(a1)
    80002996:	0685bd83          	ld	s11,104(a1)
    8000299a:	8082                	ret

000000008000299c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000299c:	1141                	addi	sp,sp,-16
    8000299e:	e406                	sd	ra,8(sp)
    800029a0:	e022                	sd	s0,0(sp)
    800029a2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029a4:	00006597          	auipc	a1,0x6
    800029a8:	9ec58593          	addi	a1,a1,-1556 # 80008390 <states.0+0x38>
    800029ac:	00015517          	auipc	a0,0x15
    800029b0:	67450513          	addi	a0,a0,1652 # 80018020 <tickslock>
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	192080e7          	jalr	402(ra) # 80000b46 <initlock>
}
    800029bc:	60a2                	ld	ra,8(sp)
    800029be:	6402                	ld	s0,0(sp)
    800029c0:	0141                	addi	sp,sp,16
    800029c2:	8082                	ret

00000000800029c4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029c4:	1141                	addi	sp,sp,-16
    800029c6:	e422                	sd	s0,8(sp)
    800029c8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029ca:	00003797          	auipc	a5,0x3
    800029ce:	53678793          	addi	a5,a5,1334 # 80005f00 <kernelvec>
    800029d2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029d6:	6422                	ld	s0,8(sp)
    800029d8:	0141                	addi	sp,sp,16
    800029da:	8082                	ret

00000000800029dc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029dc:	1101                	addi	sp,sp,-32
    800029de:	ec06                	sd	ra,24(sp)
    800029e0:	e822                	sd	s0,16(sp)
    800029e2:	e426                	sd	s1,8(sp)
    800029e4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800029e6:	fffff097          	auipc	ra,0xfffff
    800029ea:	f9a080e7          	jalr	-102(ra) # 80001980 <myproc>
    800029ee:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    800029f0:	00000097          	auipc	ra,0x0
    800029f4:	dc6080e7          	jalr	-570(ra) # 800027b6 <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029f8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029fc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029fe:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a02:	00004617          	auipc	a2,0x4
    80002a06:	5fe60613          	addi	a2,a2,1534 # 80007000 <_trampoline>
    80002a0a:	00004697          	auipc	a3,0x4
    80002a0e:	5f668693          	addi	a3,a3,1526 # 80007000 <_trampoline>
    80002a12:	8e91                	sub	a3,a3,a2
    80002a14:	040007b7          	lui	a5,0x4000
    80002a18:	17fd                	addi	a5,a5,-1
    80002a1a:	07b2                	slli	a5,a5,0xc
    80002a1c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a1e:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a22:	7d58                	ld	a4,184(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a24:	180026f3          	csrr	a3,satp
    80002a28:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    80002a2a:	7d58                	ld	a4,184(a0)
    80002a2c:	7954                	ld	a3,176(a0)
    80002a2e:	6585                	lui	a1,0x1
    80002a30:	96ae                	add	a3,a3,a1
    80002a32:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    80002a34:	7d58                	ld	a4,184(a0)
    80002a36:	00000697          	auipc	a3,0x0
    80002a3a:	15e68693          	addi	a3,a3,350 # 80002b94 <usertrap>
    80002a3e:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a40:	7d58                	ld	a4,184(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a42:	8692                	mv	a3,tp
    80002a44:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a46:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a4a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a4e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a52:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    80002a56:	7d58                	ld	a4,184(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a58:	6f18                	ld	a4,24(a4)
    80002a5a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a5e:	1004b583          	ld	a1,256(s1)
    80002a62:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002a64:	02848493          	addi	s1,s1,40
    80002a68:	8d05                	sub	a0,a0,s1
    80002a6a:	8519                	srai	a0,a0,0x6
    80002a6c:	00005717          	auipc	a4,0x5
    80002a70:	59c73703          	ld	a4,1436(a4) # 80008008 <etext+0x8>
    80002a74:	02e50533          	mul	a0,a0,a4
    80002a78:	1502                	slli	a0,a0,0x20
    80002a7a:	9101                	srli	a0,a0,0x20
    80002a7c:	00351693          	slli	a3,a0,0x3
    80002a80:	9536                	add	a0,a0,a3
    80002a82:	0516                	slli	a0,a0,0x5
    80002a84:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a88:	00004717          	auipc	a4,0x4
    80002a8c:	60c70713          	addi	a4,a4,1548 # 80007094 <userret>
    80002a90:	8f11                	sub	a4,a4,a2
    80002a92:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002a94:	577d                	li	a4,-1
    80002a96:	177e                	slli	a4,a4,0x3f
    80002a98:	8dd9                	or	a1,a1,a4
    80002a9a:	16fd                	addi	a3,a3,-1
    80002a9c:	06b6                	slli	a3,a3,0xd
    80002a9e:	9536                	add	a0,a0,a3
    80002aa0:	9782                	jalr	a5
}
    80002aa2:	60e2                	ld	ra,24(sp)
    80002aa4:	6442                	ld	s0,16(sp)
    80002aa6:	64a2                	ld	s1,8(sp)
    80002aa8:	6105                	addi	sp,sp,32
    80002aaa:	8082                	ret

0000000080002aac <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002aac:	1101                	addi	sp,sp,-32
    80002aae:	ec06                	sd	ra,24(sp)
    80002ab0:	e822                	sd	s0,16(sp)
    80002ab2:	e426                	sd	s1,8(sp)
    80002ab4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ab6:	00015497          	auipc	s1,0x15
    80002aba:	56a48493          	addi	s1,s1,1386 # 80018020 <tickslock>
    80002abe:	8526                	mv	a0,s1
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	116080e7          	jalr	278(ra) # 80000bd6 <acquire>
  ticks++;
    80002ac8:	00006517          	auipc	a0,0x6
    80002acc:	eb850513          	addi	a0,a0,-328 # 80008980 <ticks>
    80002ad0:	411c                	lw	a5,0(a0)
    80002ad2:	2785                	addiw	a5,a5,1
    80002ad4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002ad6:	fffff097          	auipc	ra,0xfffff
    80002ada:	6e4080e7          	jalr	1764(ra) # 800021ba <wakeup>
  release(&tickslock);
    80002ade:	8526                	mv	a0,s1
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	1aa080e7          	jalr	426(ra) # 80000c8a <release>
}
    80002ae8:	60e2                	ld	ra,24(sp)
    80002aea:	6442                	ld	s0,16(sp)
    80002aec:	64a2                	ld	s1,8(sp)
    80002aee:	6105                	addi	sp,sp,32
    80002af0:	8082                	ret

0000000080002af2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002af2:	1101                	addi	sp,sp,-32
    80002af4:	ec06                	sd	ra,24(sp)
    80002af6:	e822                	sd	s0,16(sp)
    80002af8:	e426                	sd	s1,8(sp)
    80002afa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002afc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b00:	00074d63          	bltz	a4,80002b1a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b04:	57fd                	li	a5,-1
    80002b06:	17fe                	slli	a5,a5,0x3f
    80002b08:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b0a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b0c:	06f70363          	beq	a4,a5,80002b72 <devintr+0x80>
  }
}
    80002b10:	60e2                	ld	ra,24(sp)
    80002b12:	6442                	ld	s0,16(sp)
    80002b14:	64a2                	ld	s1,8(sp)
    80002b16:	6105                	addi	sp,sp,32
    80002b18:	8082                	ret
     (scause & 0xff) == 9){
    80002b1a:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b1e:	46a5                	li	a3,9
    80002b20:	fed792e3          	bne	a5,a3,80002b04 <devintr+0x12>
    int irq = plic_claim();
    80002b24:	00003097          	auipc	ra,0x3
    80002b28:	4e4080e7          	jalr	1252(ra) # 80006008 <plic_claim>
    80002b2c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b2e:	47a9                	li	a5,10
    80002b30:	02f50763          	beq	a0,a5,80002b5e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b34:	4785                	li	a5,1
    80002b36:	02f50963          	beq	a0,a5,80002b68 <devintr+0x76>
    return 1;
    80002b3a:	4505                	li	a0,1
    } else if(irq){
    80002b3c:	d8f1                	beqz	s1,80002b10 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b3e:	85a6                	mv	a1,s1
    80002b40:	00006517          	auipc	a0,0x6
    80002b44:	85850513          	addi	a0,a0,-1960 # 80008398 <states.0+0x40>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	a40080e7          	jalr	-1472(ra) # 80000588 <printf>
      plic_complete(irq);
    80002b50:	8526                	mv	a0,s1
    80002b52:	00003097          	auipc	ra,0x3
    80002b56:	4da080e7          	jalr	1242(ra) # 8000602c <plic_complete>
    return 1;
    80002b5a:	4505                	li	a0,1
    80002b5c:	bf55                	j	80002b10 <devintr+0x1e>
      uartintr();
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	e3c080e7          	jalr	-452(ra) # 8000099a <uartintr>
    80002b66:	b7ed                	j	80002b50 <devintr+0x5e>
      virtio_disk_intr();
    80002b68:	00004097          	auipc	ra,0x4
    80002b6c:	990080e7          	jalr	-1648(ra) # 800064f8 <virtio_disk_intr>
    80002b70:	b7c5                	j	80002b50 <devintr+0x5e>
    if(cpuid() == 0){
    80002b72:	fffff097          	auipc	ra,0xfffff
    80002b76:	de2080e7          	jalr	-542(ra) # 80001954 <cpuid>
    80002b7a:	c901                	beqz	a0,80002b8a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b7c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b80:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b82:	14479073          	csrw	sip,a5
    return 2;
    80002b86:	4509                	li	a0,2
    80002b88:	b761                	j	80002b10 <devintr+0x1e>
      clockintr();
    80002b8a:	00000097          	auipc	ra,0x0
    80002b8e:	f22080e7          	jalr	-222(ra) # 80002aac <clockintr>
    80002b92:	b7ed                	j	80002b7c <devintr+0x8a>

0000000080002b94 <usertrap>:
{
    80002b94:	1101                	addi	sp,sp,-32
    80002b96:	ec06                	sd	ra,24(sp)
    80002b98:	e822                	sd	s0,16(sp)
    80002b9a:	e426                	sd	s1,8(sp)
    80002b9c:	e04a                	sd	s2,0(sp)
    80002b9e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ba4:	1007f793          	andi	a5,a5,256
    80002ba8:	e7b9                	bnez	a5,80002bf6 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002baa:	00003797          	auipc	a5,0x3
    80002bae:	35678793          	addi	a5,a5,854 # 80005f00 <kernelvec>
    80002bb2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bb6:	fffff097          	auipc	ra,0xfffff
    80002bba:	dca080e7          	jalr	-566(ra) # 80001980 <myproc>
    80002bbe:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002bc0:	00000097          	auipc	ra,0x0
    80002bc4:	bf6080e7          	jalr	-1034(ra) # 800027b6 <mykthread>
    80002bc8:	892a                	mv	s2,a0
  kt->trapframe->epc = r_sepc();
    80002bca:	7d5c                	ld	a5,184(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bcc:	14102773          	csrr	a4,sepc
    80002bd0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002bd6:	47a1                	li	a5,8
    80002bd8:	02f70763          	beq	a4,a5,80002c06 <usertrap+0x72>
  } else if((which_dev = devintr()) != 0){
    80002bdc:	00000097          	auipc	ra,0x0
    80002be0:	f16080e7          	jalr	-234(ra) # 80002af2 <devintr>
    80002be4:	892a                	mv	s2,a0
    80002be6:	c541                	beqz	a0,80002c6e <usertrap+0xda>
  if(killed(p))
    80002be8:	8526                	mv	a0,s1
    80002bea:	00000097          	auipc	ra,0x0
    80002bee:	89c080e7          	jalr	-1892(ra) # 80002486 <killed>
    80002bf2:	c939                	beqz	a0,80002c48 <usertrap+0xb4>
    80002bf4:	a0a9                	j	80002c3e <usertrap+0xaa>
    panic("usertrap: not from user mode");
    80002bf6:	00005517          	auipc	a0,0x5
    80002bfa:	7c250513          	addi	a0,a0,1986 # 800083b8 <states.0+0x60>
    80002bfe:	ffffe097          	auipc	ra,0xffffe
    80002c02:	940080e7          	jalr	-1728(ra) # 8000053e <panic>
    if(killed(p))
    80002c06:	8526                	mv	a0,s1
    80002c08:	00000097          	auipc	ra,0x0
    80002c0c:	87e080e7          	jalr	-1922(ra) # 80002486 <killed>
    80002c10:	e929                	bnez	a0,80002c62 <usertrap+0xce>
    kt->trapframe->epc += 4;
    80002c12:	0b893703          	ld	a4,184(s2)
    80002c16:	6f1c                	ld	a5,24(a4)
    80002c18:	0791                	addi	a5,a5,4
    80002c1a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c20:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c24:	10079073          	csrw	sstatus,a5
    syscall();
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	2d8080e7          	jalr	728(ra) # 80002f00 <syscall>
  if(killed(p))
    80002c30:	8526                	mv	a0,s1
    80002c32:	00000097          	auipc	ra,0x0
    80002c36:	854080e7          	jalr	-1964(ra) # 80002486 <killed>
    80002c3a:	c911                	beqz	a0,80002c4e <usertrap+0xba>
    80002c3c:	4901                	li	s2,0
    exit(-1);
    80002c3e:	557d                	li	a0,-1
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	692080e7          	jalr	1682(ra) # 800022d2 <exit>
  if(which_dev == 2)
    80002c48:	4789                	li	a5,2
    80002c4a:	04f90f63          	beq	s2,a5,80002ca8 <usertrap+0x114>
  usertrapret();
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	d8e080e7          	jalr	-626(ra) # 800029dc <usertrapret>
}
    80002c56:	60e2                	ld	ra,24(sp)
    80002c58:	6442                	ld	s0,16(sp)
    80002c5a:	64a2                	ld	s1,8(sp)
    80002c5c:	6902                	ld	s2,0(sp)
    80002c5e:	6105                	addi	sp,sp,32
    80002c60:	8082                	ret
      exit(-1);
    80002c62:	557d                	li	a0,-1
    80002c64:	fffff097          	auipc	ra,0xfffff
    80002c68:	66e080e7          	jalr	1646(ra) # 800022d2 <exit>
    80002c6c:	b75d                	j	80002c12 <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c6e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c72:	50d0                	lw	a2,36(s1)
    80002c74:	00005517          	auipc	a0,0x5
    80002c78:	76450513          	addi	a0,a0,1892 # 800083d8 <states.0+0x80>
    80002c7c:	ffffe097          	auipc	ra,0xffffe
    80002c80:	90c080e7          	jalr	-1780(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c84:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c88:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c8c:	00005517          	auipc	a0,0x5
    80002c90:	77c50513          	addi	a0,a0,1916 # 80008408 <states.0+0xb0>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	8f4080e7          	jalr	-1804(ra) # 80000588 <printf>
    setkilled(p);
    80002c9c:	8526                	mv	a0,s1
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	7bc080e7          	jalr	1980(ra) # 8000245a <setkilled>
    80002ca6:	b769                	j	80002c30 <usertrap+0x9c>
    yield();
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	3d4080e7          	jalr	980(ra) # 8000207c <yield>
    80002cb0:	bf79                	j	80002c4e <usertrap+0xba>

0000000080002cb2 <kerneltrap>:
{
    80002cb2:	7179                	addi	sp,sp,-48
    80002cb4:	f406                	sd	ra,40(sp)
    80002cb6:	f022                	sd	s0,32(sp)
    80002cb8:	ec26                	sd	s1,24(sp)
    80002cba:	e84a                	sd	s2,16(sp)
    80002cbc:	e44e                	sd	s3,8(sp)
    80002cbe:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cc0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cc4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cc8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ccc:	1004f793          	andi	a5,s1,256
    80002cd0:	cb85                	beqz	a5,80002d00 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cd2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cd6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cd8:	ef85                	bnez	a5,80002d10 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cda:	00000097          	auipc	ra,0x0
    80002cde:	e18080e7          	jalr	-488(ra) # 80002af2 <devintr>
    80002ce2:	cd1d                	beqz	a0,80002d20 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002ce4:	4789                	li	a5,2
    80002ce6:	06f50a63          	beq	a0,a5,80002d5a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cea:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cee:	10049073          	csrw	sstatus,s1
}
    80002cf2:	70a2                	ld	ra,40(sp)
    80002cf4:	7402                	ld	s0,32(sp)
    80002cf6:	64e2                	ld	s1,24(sp)
    80002cf8:	6942                	ld	s2,16(sp)
    80002cfa:	69a2                	ld	s3,8(sp)
    80002cfc:	6145                	addi	sp,sp,48
    80002cfe:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d00:	00005517          	auipc	a0,0x5
    80002d04:	72850513          	addi	a0,a0,1832 # 80008428 <states.0+0xd0>
    80002d08:	ffffe097          	auipc	ra,0xffffe
    80002d0c:	836080e7          	jalr	-1994(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002d10:	00005517          	auipc	a0,0x5
    80002d14:	74050513          	addi	a0,a0,1856 # 80008450 <states.0+0xf8>
    80002d18:	ffffe097          	auipc	ra,0xffffe
    80002d1c:	826080e7          	jalr	-2010(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002d20:	85ce                	mv	a1,s3
    80002d22:	00005517          	auipc	a0,0x5
    80002d26:	74e50513          	addi	a0,a0,1870 # 80008470 <states.0+0x118>
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	85e080e7          	jalr	-1954(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d32:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d36:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d3a:	00005517          	auipc	a0,0x5
    80002d3e:	74650513          	addi	a0,a0,1862 # 80008480 <states.0+0x128>
    80002d42:	ffffe097          	auipc	ra,0xffffe
    80002d46:	846080e7          	jalr	-1978(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002d4a:	00005517          	auipc	a0,0x5
    80002d4e:	74e50513          	addi	a0,a0,1870 # 80008498 <states.0+0x140>
    80002d52:	ffffd097          	auipc	ra,0xffffd
    80002d56:	7ec080e7          	jalr	2028(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	c26080e7          	jalr	-986(ra) # 80001980 <myproc>
    80002d62:	d541                	beqz	a0,80002cea <kerneltrap+0x38>
    80002d64:	fffff097          	auipc	ra,0xfffff
    80002d68:	c1c080e7          	jalr	-996(ra) # 80001980 <myproc>
    80002d6c:	4138                	lw	a4,64(a0)
    80002d6e:	4791                	li	a5,4
    80002d70:	f6f71de3          	bne	a4,a5,80002cea <kerneltrap+0x38>
    yield();
    80002d74:	fffff097          	auipc	ra,0xfffff
    80002d78:	308080e7          	jalr	776(ra) # 8000207c <yield>
    80002d7c:	b7bd                	j	80002cea <kerneltrap+0x38>

0000000080002d7e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	1000                	addi	s0,sp,32
    80002d88:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    80002d8a:	00000097          	auipc	ra,0x0
    80002d8e:	a2c080e7          	jalr	-1492(ra) # 800027b6 <mykthread>
  switch (n) {
    80002d92:	4795                	li	a5,5
    80002d94:	0497e163          	bltu	a5,s1,80002dd6 <argraw+0x58>
    80002d98:	048a                	slli	s1,s1,0x2
    80002d9a:	00005717          	auipc	a4,0x5
    80002d9e:	73670713          	addi	a4,a4,1846 # 800084d0 <states.0+0x178>
    80002da2:	94ba                	add	s1,s1,a4
    80002da4:	409c                	lw	a5,0(s1)
    80002da6:	97ba                	add	a5,a5,a4
    80002da8:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    80002daa:	7d5c                	ld	a5,184(a0)
    80002dac:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002dae:	60e2                	ld	ra,24(sp)
    80002db0:	6442                	ld	s0,16(sp)
    80002db2:	64a2                	ld	s1,8(sp)
    80002db4:	6105                	addi	sp,sp,32
    80002db6:	8082                	ret
    return kt->trapframe->a1;
    80002db8:	7d5c                	ld	a5,184(a0)
    80002dba:	7fa8                	ld	a0,120(a5)
    80002dbc:	bfcd                	j	80002dae <argraw+0x30>
    return kt->trapframe->a2;
    80002dbe:	7d5c                	ld	a5,184(a0)
    80002dc0:	63c8                	ld	a0,128(a5)
    80002dc2:	b7f5                	j	80002dae <argraw+0x30>
    return kt->trapframe->a3;
    80002dc4:	7d5c                	ld	a5,184(a0)
    80002dc6:	67c8                	ld	a0,136(a5)
    80002dc8:	b7dd                	j	80002dae <argraw+0x30>
    return kt->trapframe->a4;
    80002dca:	7d5c                	ld	a5,184(a0)
    80002dcc:	6bc8                	ld	a0,144(a5)
    80002dce:	b7c5                	j	80002dae <argraw+0x30>
    return kt->trapframe->a5;
    80002dd0:	7d5c                	ld	a5,184(a0)
    80002dd2:	6fc8                	ld	a0,152(a5)
    80002dd4:	bfe9                	j	80002dae <argraw+0x30>
  panic("argraw");
    80002dd6:	00005517          	auipc	a0,0x5
    80002dda:	6d250513          	addi	a0,a0,1746 # 800084a8 <states.0+0x150>
    80002dde:	ffffd097          	auipc	ra,0xffffd
    80002de2:	760080e7          	jalr	1888(ra) # 8000053e <panic>

0000000080002de6 <fetchaddr>:
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	e426                	sd	s1,8(sp)
    80002dee:	e04a                	sd	s2,0(sp)
    80002df0:	1000                	addi	s0,sp,32
    80002df2:	84aa                	mv	s1,a0
    80002df4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	b8a080e7          	jalr	-1142(ra) # 80001980 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002dfe:	7d7c                	ld	a5,248(a0)
    80002e00:	02f4f963          	bgeu	s1,a5,80002e32 <fetchaddr+0x4c>
    80002e04:	00848713          	addi	a4,s1,8
    80002e08:	02e7e763          	bltu	a5,a4,80002e36 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e0c:	46a1                	li	a3,8
    80002e0e:	8626                	mv	a2,s1
    80002e10:	85ca                	mv	a1,s2
    80002e12:	10053503          	ld	a0,256(a0)
    80002e16:	fffff097          	auipc	ra,0xfffff
    80002e1a:	8de080e7          	jalr	-1826(ra) # 800016f4 <copyin>
    80002e1e:	00a03533          	snez	a0,a0
    80002e22:	40a00533          	neg	a0,a0
}
    80002e26:	60e2                	ld	ra,24(sp)
    80002e28:	6442                	ld	s0,16(sp)
    80002e2a:	64a2                	ld	s1,8(sp)
    80002e2c:	6902                	ld	s2,0(sp)
    80002e2e:	6105                	addi	sp,sp,32
    80002e30:	8082                	ret
    return -1;
    80002e32:	557d                	li	a0,-1
    80002e34:	bfcd                	j	80002e26 <fetchaddr+0x40>
    80002e36:	557d                	li	a0,-1
    80002e38:	b7fd                	j	80002e26 <fetchaddr+0x40>

0000000080002e3a <fetchstr>:
{
    80002e3a:	7179                	addi	sp,sp,-48
    80002e3c:	f406                	sd	ra,40(sp)
    80002e3e:	f022                	sd	s0,32(sp)
    80002e40:	ec26                	sd	s1,24(sp)
    80002e42:	e84a                	sd	s2,16(sp)
    80002e44:	e44e                	sd	s3,8(sp)
    80002e46:	1800                	addi	s0,sp,48
    80002e48:	892a                	mv	s2,a0
    80002e4a:	84ae                	mv	s1,a1
    80002e4c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e4e:	fffff097          	auipc	ra,0xfffff
    80002e52:	b32080e7          	jalr	-1230(ra) # 80001980 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e56:	86ce                	mv	a3,s3
    80002e58:	864a                	mv	a2,s2
    80002e5a:	85a6                	mv	a1,s1
    80002e5c:	10053503          	ld	a0,256(a0)
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	922080e7          	jalr	-1758(ra) # 80001782 <copyinstr>
    80002e68:	00054e63          	bltz	a0,80002e84 <fetchstr+0x4a>
  return strlen(buf);
    80002e6c:	8526                	mv	a0,s1
    80002e6e:	ffffe097          	auipc	ra,0xffffe
    80002e72:	fe0080e7          	jalr	-32(ra) # 80000e4e <strlen>
}
    80002e76:	70a2                	ld	ra,40(sp)
    80002e78:	7402                	ld	s0,32(sp)
    80002e7a:	64e2                	ld	s1,24(sp)
    80002e7c:	6942                	ld	s2,16(sp)
    80002e7e:	69a2                	ld	s3,8(sp)
    80002e80:	6145                	addi	sp,sp,48
    80002e82:	8082                	ret
    return -1;
    80002e84:	557d                	li	a0,-1
    80002e86:	bfc5                	j	80002e76 <fetchstr+0x3c>

0000000080002e88 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e88:	1101                	addi	sp,sp,-32
    80002e8a:	ec06                	sd	ra,24(sp)
    80002e8c:	e822                	sd	s0,16(sp)
    80002e8e:	e426                	sd	s1,8(sp)
    80002e90:	1000                	addi	s0,sp,32
    80002e92:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e94:	00000097          	auipc	ra,0x0
    80002e98:	eea080e7          	jalr	-278(ra) # 80002d7e <argraw>
    80002e9c:	c088                	sw	a0,0(s1)
}
    80002e9e:	60e2                	ld	ra,24(sp)
    80002ea0:	6442                	ld	s0,16(sp)
    80002ea2:	64a2                	ld	s1,8(sp)
    80002ea4:	6105                	addi	sp,sp,32
    80002ea6:	8082                	ret

0000000080002ea8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ea8:	1101                	addi	sp,sp,-32
    80002eaa:	ec06                	sd	ra,24(sp)
    80002eac:	e822                	sd	s0,16(sp)
    80002eae:	e426                	sd	s1,8(sp)
    80002eb0:	1000                	addi	s0,sp,32
    80002eb2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eb4:	00000097          	auipc	ra,0x0
    80002eb8:	eca080e7          	jalr	-310(ra) # 80002d7e <argraw>
    80002ebc:	e088                	sd	a0,0(s1)
}
    80002ebe:	60e2                	ld	ra,24(sp)
    80002ec0:	6442                	ld	s0,16(sp)
    80002ec2:	64a2                	ld	s1,8(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret

0000000080002ec8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ec8:	7179                	addi	sp,sp,-48
    80002eca:	f406                	sd	ra,40(sp)
    80002ecc:	f022                	sd	s0,32(sp)
    80002ece:	ec26                	sd	s1,24(sp)
    80002ed0:	e84a                	sd	s2,16(sp)
    80002ed2:	1800                	addi	s0,sp,48
    80002ed4:	84ae                	mv	s1,a1
    80002ed6:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ed8:	fd840593          	addi	a1,s0,-40
    80002edc:	00000097          	auipc	ra,0x0
    80002ee0:	fcc080e7          	jalr	-52(ra) # 80002ea8 <argaddr>
  return fetchstr(addr, buf, max);
    80002ee4:	864a                	mv	a2,s2
    80002ee6:	85a6                	mv	a1,s1
    80002ee8:	fd843503          	ld	a0,-40(s0)
    80002eec:	00000097          	auipc	ra,0x0
    80002ef0:	f4e080e7          	jalr	-178(ra) # 80002e3a <fetchstr>
}
    80002ef4:	70a2                	ld	ra,40(sp)
    80002ef6:	7402                	ld	s0,32(sp)
    80002ef8:	64e2                	ld	s1,24(sp)
    80002efa:	6942                	ld	s2,16(sp)
    80002efc:	6145                	addi	sp,sp,48
    80002efe:	8082                	ret

0000000080002f00 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002f00:	7179                	addi	sp,sp,-48
    80002f02:	f406                	sd	ra,40(sp)
    80002f04:	f022                	sd	s0,32(sp)
    80002f06:	ec26                	sd	s1,24(sp)
    80002f08:	e84a                	sd	s2,16(sp)
    80002f0a:	e44e                	sd	s3,8(sp)
    80002f0c:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002f0e:	fffff097          	auipc	ra,0xfffff
    80002f12:	a72080e7          	jalr	-1422(ra) # 80001980 <myproc>
    80002f16:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    80002f18:	00000097          	auipc	ra,0x0
    80002f1c:	89e080e7          	jalr	-1890(ra) # 800027b6 <mykthread>
    80002f20:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80002f22:	0b853983          	ld	s3,184(a0)
    80002f26:	0a89b783          	ld	a5,168(s3)
    80002f2a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f2e:	37fd                	addiw	a5,a5,-1
    80002f30:	4751                	li	a4,20
    80002f32:	00f76f63          	bltu	a4,a5,80002f50 <syscall+0x50>
    80002f36:	00369713          	slli	a4,a3,0x3
    80002f3a:	00005797          	auipc	a5,0x5
    80002f3e:	5ae78793          	addi	a5,a5,1454 # 800084e8 <syscalls>
    80002f42:	97ba                	add	a5,a5,a4
    80002f44:	639c                	ld	a5,0(a5)
    80002f46:	c789                	beqz	a5,80002f50 <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    80002f48:	9782                	jalr	a5
    80002f4a:	06a9b823          	sd	a0,112(s3)
    80002f4e:	a005                	j	80002f6e <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f50:	19090613          	addi	a2,s2,400
    80002f54:	02492583          	lw	a1,36(s2)
    80002f58:	00005517          	auipc	a0,0x5
    80002f5c:	55850513          	addi	a0,a0,1368 # 800084b0 <states.0+0x158>
    80002f60:	ffffd097          	auipc	ra,0xffffd
    80002f64:	628080e7          	jalr	1576(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    80002f68:	7cdc                	ld	a5,184(s1)
    80002f6a:	577d                	li	a4,-1
    80002f6c:	fbb8                	sd	a4,112(a5)
  }
}
    80002f6e:	70a2                	ld	ra,40(sp)
    80002f70:	7402                	ld	s0,32(sp)
    80002f72:	64e2                	ld	s1,24(sp)
    80002f74:	6942                	ld	s2,16(sp)
    80002f76:	69a2                	ld	s3,8(sp)
    80002f78:	6145                	addi	sp,sp,48
    80002f7a:	8082                	ret

0000000080002f7c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f7c:	1101                	addi	sp,sp,-32
    80002f7e:	ec06                	sd	ra,24(sp)
    80002f80:	e822                	sd	s0,16(sp)
    80002f82:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f84:	fec40593          	addi	a1,s0,-20
    80002f88:	4501                	li	a0,0
    80002f8a:	00000097          	auipc	ra,0x0
    80002f8e:	efe080e7          	jalr	-258(ra) # 80002e88 <argint>
  exit(n);
    80002f92:	fec42503          	lw	a0,-20(s0)
    80002f96:	fffff097          	auipc	ra,0xfffff
    80002f9a:	33c080e7          	jalr	828(ra) # 800022d2 <exit>
  return 0;  // not reached
}
    80002f9e:	4501                	li	a0,0
    80002fa0:	60e2                	ld	ra,24(sp)
    80002fa2:	6442                	ld	s0,16(sp)
    80002fa4:	6105                	addi	sp,sp,32
    80002fa6:	8082                	ret

0000000080002fa8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002fa8:	1141                	addi	sp,sp,-16
    80002faa:	e406                	sd	ra,8(sp)
    80002fac:	e022                	sd	s0,0(sp)
    80002fae:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002fb0:	fffff097          	auipc	ra,0xfffff
    80002fb4:	9d0080e7          	jalr	-1584(ra) # 80001980 <myproc>
}
    80002fb8:	5148                	lw	a0,36(a0)
    80002fba:	60a2                	ld	ra,8(sp)
    80002fbc:	6402                	ld	s0,0(sp)
    80002fbe:	0141                	addi	sp,sp,16
    80002fc0:	8082                	ret

0000000080002fc2 <sys_fork>:

uint64
sys_fork(void)
{
    80002fc2:	1141                	addi	sp,sp,-16
    80002fc4:	e406                	sd	ra,8(sp)
    80002fc6:	e022                	sd	s0,0(sp)
    80002fc8:	0800                	addi	s0,sp,16
  return fork();
    80002fca:	fffff097          	auipc	ra,0xfffff
    80002fce:	d7c080e7          	jalr	-644(ra) # 80001d46 <fork>
}
    80002fd2:	60a2                	ld	ra,8(sp)
    80002fd4:	6402                	ld	s0,0(sp)
    80002fd6:	0141                	addi	sp,sp,16
    80002fd8:	8082                	ret

0000000080002fda <sys_wait>:

uint64
sys_wait(void)
{
    80002fda:	1101                	addi	sp,sp,-32
    80002fdc:	ec06                	sd	ra,24(sp)
    80002fde:	e822                	sd	s0,16(sp)
    80002fe0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002fe2:	fe840593          	addi	a1,s0,-24
    80002fe6:	4501                	li	a0,0
    80002fe8:	00000097          	auipc	ra,0x0
    80002fec:	ec0080e7          	jalr	-320(ra) # 80002ea8 <argaddr>
  return wait(p);
    80002ff0:	fe843503          	ld	a0,-24(s0)
    80002ff4:	fffff097          	auipc	ra,0xfffff
    80002ff8:	4c4080e7          	jalr	1220(ra) # 800024b8 <wait>
}
    80002ffc:	60e2                	ld	ra,24(sp)
    80002ffe:	6442                	ld	s0,16(sp)
    80003000:	6105                	addi	sp,sp,32
    80003002:	8082                	ret

0000000080003004 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003004:	7179                	addi	sp,sp,-48
    80003006:	f406                	sd	ra,40(sp)
    80003008:	f022                	sd	s0,32(sp)
    8000300a:	ec26                	sd	s1,24(sp)
    8000300c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000300e:	fdc40593          	addi	a1,s0,-36
    80003012:	4501                	li	a0,0
    80003014:	00000097          	auipc	ra,0x0
    80003018:	e74080e7          	jalr	-396(ra) # 80002e88 <argint>
  addr = myproc()->sz;
    8000301c:	fffff097          	auipc	ra,0xfffff
    80003020:	964080e7          	jalr	-1692(ra) # 80001980 <myproc>
    80003024:	7d64                	ld	s1,248(a0)
  if(growproc(n) < 0)
    80003026:	fdc42503          	lw	a0,-36(s0)
    8000302a:	fffff097          	auipc	ra,0xfffff
    8000302e:	cbc080e7          	jalr	-836(ra) # 80001ce6 <growproc>
    80003032:	00054863          	bltz	a0,80003042 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003036:	8526                	mv	a0,s1
    80003038:	70a2                	ld	ra,40(sp)
    8000303a:	7402                	ld	s0,32(sp)
    8000303c:	64e2                	ld	s1,24(sp)
    8000303e:	6145                	addi	sp,sp,48
    80003040:	8082                	ret
    return -1;
    80003042:	54fd                	li	s1,-1
    80003044:	bfcd                	j	80003036 <sys_sbrk+0x32>

0000000080003046 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003046:	7139                	addi	sp,sp,-64
    80003048:	fc06                	sd	ra,56(sp)
    8000304a:	f822                	sd	s0,48(sp)
    8000304c:	f426                	sd	s1,40(sp)
    8000304e:	f04a                	sd	s2,32(sp)
    80003050:	ec4e                	sd	s3,24(sp)
    80003052:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003054:	fcc40593          	addi	a1,s0,-52
    80003058:	4501                	li	a0,0
    8000305a:	00000097          	auipc	ra,0x0
    8000305e:	e2e080e7          	jalr	-466(ra) # 80002e88 <argint>
  acquire(&tickslock);
    80003062:	00015517          	auipc	a0,0x15
    80003066:	fbe50513          	addi	a0,a0,-66 # 80018020 <tickslock>
    8000306a:	ffffe097          	auipc	ra,0xffffe
    8000306e:	b6c080e7          	jalr	-1172(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003072:	00006917          	auipc	s2,0x6
    80003076:	90e92903          	lw	s2,-1778(s2) # 80008980 <ticks>
  while(ticks - ticks0 < n){
    8000307a:	fcc42783          	lw	a5,-52(s0)
    8000307e:	cf9d                	beqz	a5,800030bc <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003080:	00015997          	auipc	s3,0x15
    80003084:	fa098993          	addi	s3,s3,-96 # 80018020 <tickslock>
    80003088:	00006497          	auipc	s1,0x6
    8000308c:	8f848493          	addi	s1,s1,-1800 # 80008980 <ticks>
    if(killed(myproc())){
    80003090:	fffff097          	auipc	ra,0xfffff
    80003094:	8f0080e7          	jalr	-1808(ra) # 80001980 <myproc>
    80003098:	fffff097          	auipc	ra,0xfffff
    8000309c:	3ee080e7          	jalr	1006(ra) # 80002486 <killed>
    800030a0:	ed15                	bnez	a0,800030dc <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800030a2:	85ce                	mv	a1,s3
    800030a4:	8526                	mv	a0,s1
    800030a6:	fffff097          	auipc	ra,0xfffff
    800030aa:	094080e7          	jalr	148(ra) # 8000213a <sleep>
  while(ticks - ticks0 < n){
    800030ae:	409c                	lw	a5,0(s1)
    800030b0:	412787bb          	subw	a5,a5,s2
    800030b4:	fcc42703          	lw	a4,-52(s0)
    800030b8:	fce7ece3          	bltu	a5,a4,80003090 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800030bc:	00015517          	auipc	a0,0x15
    800030c0:	f6450513          	addi	a0,a0,-156 # 80018020 <tickslock>
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	bc6080e7          	jalr	-1082(ra) # 80000c8a <release>
  return 0;
    800030cc:	4501                	li	a0,0
}
    800030ce:	70e2                	ld	ra,56(sp)
    800030d0:	7442                	ld	s0,48(sp)
    800030d2:	74a2                	ld	s1,40(sp)
    800030d4:	7902                	ld	s2,32(sp)
    800030d6:	69e2                	ld	s3,24(sp)
    800030d8:	6121                	addi	sp,sp,64
    800030da:	8082                	ret
      release(&tickslock);
    800030dc:	00015517          	auipc	a0,0x15
    800030e0:	f4450513          	addi	a0,a0,-188 # 80018020 <tickslock>
    800030e4:	ffffe097          	auipc	ra,0xffffe
    800030e8:	ba6080e7          	jalr	-1114(ra) # 80000c8a <release>
      return -1;
    800030ec:	557d                	li	a0,-1
    800030ee:	b7c5                	j	800030ce <sys_sleep+0x88>

00000000800030f0 <sys_kill>:

uint64
sys_kill(void)
{
    800030f0:	1101                	addi	sp,sp,-32
    800030f2:	ec06                	sd	ra,24(sp)
    800030f4:	e822                	sd	s0,16(sp)
    800030f6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800030f8:	fec40593          	addi	a1,s0,-20
    800030fc:	4501                	li	a0,0
    800030fe:	00000097          	auipc	ra,0x0
    80003102:	d8a080e7          	jalr	-630(ra) # 80002e88 <argint>
  return kill(pid);
    80003106:	fec42503          	lw	a0,-20(s0)
    8000310a:	fffff097          	auipc	ra,0xfffff
    8000310e:	2c6080e7          	jalr	710(ra) # 800023d0 <kill>
}
    80003112:	60e2                	ld	ra,24(sp)
    80003114:	6442                	ld	s0,16(sp)
    80003116:	6105                	addi	sp,sp,32
    80003118:	8082                	ret

000000008000311a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000311a:	1101                	addi	sp,sp,-32
    8000311c:	ec06                	sd	ra,24(sp)
    8000311e:	e822                	sd	s0,16(sp)
    80003120:	e426                	sd	s1,8(sp)
    80003122:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003124:	00015517          	auipc	a0,0x15
    80003128:	efc50513          	addi	a0,a0,-260 # 80018020 <tickslock>
    8000312c:	ffffe097          	auipc	ra,0xffffe
    80003130:	aaa080e7          	jalr	-1366(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003134:	00006497          	auipc	s1,0x6
    80003138:	84c4a483          	lw	s1,-1972(s1) # 80008980 <ticks>
  release(&tickslock);
    8000313c:	00015517          	auipc	a0,0x15
    80003140:	ee450513          	addi	a0,a0,-284 # 80018020 <tickslock>
    80003144:	ffffe097          	auipc	ra,0xffffe
    80003148:	b46080e7          	jalr	-1210(ra) # 80000c8a <release>
  return xticks;
}
    8000314c:	02049513          	slli	a0,s1,0x20
    80003150:	9101                	srli	a0,a0,0x20
    80003152:	60e2                	ld	ra,24(sp)
    80003154:	6442                	ld	s0,16(sp)
    80003156:	64a2                	ld	s1,8(sp)
    80003158:	6105                	addi	sp,sp,32
    8000315a:	8082                	ret

000000008000315c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000315c:	7179                	addi	sp,sp,-48
    8000315e:	f406                	sd	ra,40(sp)
    80003160:	f022                	sd	s0,32(sp)
    80003162:	ec26                	sd	s1,24(sp)
    80003164:	e84a                	sd	s2,16(sp)
    80003166:	e44e                	sd	s3,8(sp)
    80003168:	e052                	sd	s4,0(sp)
    8000316a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000316c:	00005597          	auipc	a1,0x5
    80003170:	42c58593          	addi	a1,a1,1068 # 80008598 <syscalls+0xb0>
    80003174:	00015517          	auipc	a0,0x15
    80003178:	ec450513          	addi	a0,a0,-316 # 80018038 <bcache>
    8000317c:	ffffe097          	auipc	ra,0xffffe
    80003180:	9ca080e7          	jalr	-1590(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003184:	0001d797          	auipc	a5,0x1d
    80003188:	eb478793          	addi	a5,a5,-332 # 80020038 <bcache+0x8000>
    8000318c:	0001d717          	auipc	a4,0x1d
    80003190:	11470713          	addi	a4,a4,276 # 800202a0 <bcache+0x8268>
    80003194:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003198:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000319c:	00015497          	auipc	s1,0x15
    800031a0:	eb448493          	addi	s1,s1,-332 # 80018050 <bcache+0x18>
    b->next = bcache.head.next;
    800031a4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800031a6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800031a8:	00005a17          	auipc	s4,0x5
    800031ac:	3f8a0a13          	addi	s4,s4,1016 # 800085a0 <syscalls+0xb8>
    b->next = bcache.head.next;
    800031b0:	2b893783          	ld	a5,696(s2)
    800031b4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800031b6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800031ba:	85d2                	mv	a1,s4
    800031bc:	01048513          	addi	a0,s1,16
    800031c0:	00001097          	auipc	ra,0x1
    800031c4:	4c4080e7          	jalr	1220(ra) # 80004684 <initsleeplock>
    bcache.head.next->prev = b;
    800031c8:	2b893783          	ld	a5,696(s2)
    800031cc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031ce:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031d2:	45848493          	addi	s1,s1,1112
    800031d6:	fd349de3          	bne	s1,s3,800031b0 <binit+0x54>
  }
}
    800031da:	70a2                	ld	ra,40(sp)
    800031dc:	7402                	ld	s0,32(sp)
    800031de:	64e2                	ld	s1,24(sp)
    800031e0:	6942                	ld	s2,16(sp)
    800031e2:	69a2                	ld	s3,8(sp)
    800031e4:	6a02                	ld	s4,0(sp)
    800031e6:	6145                	addi	sp,sp,48
    800031e8:	8082                	ret

00000000800031ea <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031ea:	7179                	addi	sp,sp,-48
    800031ec:	f406                	sd	ra,40(sp)
    800031ee:	f022                	sd	s0,32(sp)
    800031f0:	ec26                	sd	s1,24(sp)
    800031f2:	e84a                	sd	s2,16(sp)
    800031f4:	e44e                	sd	s3,8(sp)
    800031f6:	1800                	addi	s0,sp,48
    800031f8:	892a                	mv	s2,a0
    800031fa:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031fc:	00015517          	auipc	a0,0x15
    80003200:	e3c50513          	addi	a0,a0,-452 # 80018038 <bcache>
    80003204:	ffffe097          	auipc	ra,0xffffe
    80003208:	9d2080e7          	jalr	-1582(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000320c:	0001d497          	auipc	s1,0x1d
    80003210:	0e44b483          	ld	s1,228(s1) # 800202f0 <bcache+0x82b8>
    80003214:	0001d797          	auipc	a5,0x1d
    80003218:	08c78793          	addi	a5,a5,140 # 800202a0 <bcache+0x8268>
    8000321c:	02f48f63          	beq	s1,a5,8000325a <bread+0x70>
    80003220:	873e                	mv	a4,a5
    80003222:	a021                	j	8000322a <bread+0x40>
    80003224:	68a4                	ld	s1,80(s1)
    80003226:	02e48a63          	beq	s1,a4,8000325a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000322a:	449c                	lw	a5,8(s1)
    8000322c:	ff279ce3          	bne	a5,s2,80003224 <bread+0x3a>
    80003230:	44dc                	lw	a5,12(s1)
    80003232:	ff3799e3          	bne	a5,s3,80003224 <bread+0x3a>
      b->refcnt++;
    80003236:	40bc                	lw	a5,64(s1)
    80003238:	2785                	addiw	a5,a5,1
    8000323a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000323c:	00015517          	auipc	a0,0x15
    80003240:	dfc50513          	addi	a0,a0,-516 # 80018038 <bcache>
    80003244:	ffffe097          	auipc	ra,0xffffe
    80003248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000324c:	01048513          	addi	a0,s1,16
    80003250:	00001097          	auipc	ra,0x1
    80003254:	46e080e7          	jalr	1134(ra) # 800046be <acquiresleep>
      return b;
    80003258:	a8b9                	j	800032b6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000325a:	0001d497          	auipc	s1,0x1d
    8000325e:	08e4b483          	ld	s1,142(s1) # 800202e8 <bcache+0x82b0>
    80003262:	0001d797          	auipc	a5,0x1d
    80003266:	03e78793          	addi	a5,a5,62 # 800202a0 <bcache+0x8268>
    8000326a:	00f48863          	beq	s1,a5,8000327a <bread+0x90>
    8000326e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003270:	40bc                	lw	a5,64(s1)
    80003272:	cf81                	beqz	a5,8000328a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003274:	64a4                	ld	s1,72(s1)
    80003276:	fee49de3          	bne	s1,a4,80003270 <bread+0x86>
  panic("bget: no buffers");
    8000327a:	00005517          	auipc	a0,0x5
    8000327e:	32e50513          	addi	a0,a0,814 # 800085a8 <syscalls+0xc0>
    80003282:	ffffd097          	auipc	ra,0xffffd
    80003286:	2bc080e7          	jalr	700(ra) # 8000053e <panic>
      b->dev = dev;
    8000328a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000328e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003292:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003296:	4785                	li	a5,1
    80003298:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000329a:	00015517          	auipc	a0,0x15
    8000329e:	d9e50513          	addi	a0,a0,-610 # 80018038 <bcache>
    800032a2:	ffffe097          	auipc	ra,0xffffe
    800032a6:	9e8080e7          	jalr	-1560(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800032aa:	01048513          	addi	a0,s1,16
    800032ae:	00001097          	auipc	ra,0x1
    800032b2:	410080e7          	jalr	1040(ra) # 800046be <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800032b6:	409c                	lw	a5,0(s1)
    800032b8:	cb89                	beqz	a5,800032ca <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800032ba:	8526                	mv	a0,s1
    800032bc:	70a2                	ld	ra,40(sp)
    800032be:	7402                	ld	s0,32(sp)
    800032c0:	64e2                	ld	s1,24(sp)
    800032c2:	6942                	ld	s2,16(sp)
    800032c4:	69a2                	ld	s3,8(sp)
    800032c6:	6145                	addi	sp,sp,48
    800032c8:	8082                	ret
    virtio_disk_rw(b, 0);
    800032ca:	4581                	li	a1,0
    800032cc:	8526                	mv	a0,s1
    800032ce:	00003097          	auipc	ra,0x3
    800032d2:	ff6080e7          	jalr	-10(ra) # 800062c4 <virtio_disk_rw>
    b->valid = 1;
    800032d6:	4785                	li	a5,1
    800032d8:	c09c                	sw	a5,0(s1)
  return b;
    800032da:	b7c5                	j	800032ba <bread+0xd0>

00000000800032dc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032dc:	1101                	addi	sp,sp,-32
    800032de:	ec06                	sd	ra,24(sp)
    800032e0:	e822                	sd	s0,16(sp)
    800032e2:	e426                	sd	s1,8(sp)
    800032e4:	1000                	addi	s0,sp,32
    800032e6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032e8:	0541                	addi	a0,a0,16
    800032ea:	00001097          	auipc	ra,0x1
    800032ee:	46e080e7          	jalr	1134(ra) # 80004758 <holdingsleep>
    800032f2:	cd01                	beqz	a0,8000330a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032f4:	4585                	li	a1,1
    800032f6:	8526                	mv	a0,s1
    800032f8:	00003097          	auipc	ra,0x3
    800032fc:	fcc080e7          	jalr	-52(ra) # 800062c4 <virtio_disk_rw>
}
    80003300:	60e2                	ld	ra,24(sp)
    80003302:	6442                	ld	s0,16(sp)
    80003304:	64a2                	ld	s1,8(sp)
    80003306:	6105                	addi	sp,sp,32
    80003308:	8082                	ret
    panic("bwrite");
    8000330a:	00005517          	auipc	a0,0x5
    8000330e:	2b650513          	addi	a0,a0,694 # 800085c0 <syscalls+0xd8>
    80003312:	ffffd097          	auipc	ra,0xffffd
    80003316:	22c080e7          	jalr	556(ra) # 8000053e <panic>

000000008000331a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000331a:	1101                	addi	sp,sp,-32
    8000331c:	ec06                	sd	ra,24(sp)
    8000331e:	e822                	sd	s0,16(sp)
    80003320:	e426                	sd	s1,8(sp)
    80003322:	e04a                	sd	s2,0(sp)
    80003324:	1000                	addi	s0,sp,32
    80003326:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003328:	01050913          	addi	s2,a0,16
    8000332c:	854a                	mv	a0,s2
    8000332e:	00001097          	auipc	ra,0x1
    80003332:	42a080e7          	jalr	1066(ra) # 80004758 <holdingsleep>
    80003336:	c92d                	beqz	a0,800033a8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003338:	854a                	mv	a0,s2
    8000333a:	00001097          	auipc	ra,0x1
    8000333e:	3da080e7          	jalr	986(ra) # 80004714 <releasesleep>

  acquire(&bcache.lock);
    80003342:	00015517          	auipc	a0,0x15
    80003346:	cf650513          	addi	a0,a0,-778 # 80018038 <bcache>
    8000334a:	ffffe097          	auipc	ra,0xffffe
    8000334e:	88c080e7          	jalr	-1908(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003352:	40bc                	lw	a5,64(s1)
    80003354:	37fd                	addiw	a5,a5,-1
    80003356:	0007871b          	sext.w	a4,a5
    8000335a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000335c:	eb05                	bnez	a4,8000338c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000335e:	68bc                	ld	a5,80(s1)
    80003360:	64b8                	ld	a4,72(s1)
    80003362:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003364:	64bc                	ld	a5,72(s1)
    80003366:	68b8                	ld	a4,80(s1)
    80003368:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000336a:	0001d797          	auipc	a5,0x1d
    8000336e:	cce78793          	addi	a5,a5,-818 # 80020038 <bcache+0x8000>
    80003372:	2b87b703          	ld	a4,696(a5)
    80003376:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003378:	0001d717          	auipc	a4,0x1d
    8000337c:	f2870713          	addi	a4,a4,-216 # 800202a0 <bcache+0x8268>
    80003380:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003382:	2b87b703          	ld	a4,696(a5)
    80003386:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003388:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000338c:	00015517          	auipc	a0,0x15
    80003390:	cac50513          	addi	a0,a0,-852 # 80018038 <bcache>
    80003394:	ffffe097          	auipc	ra,0xffffe
    80003398:	8f6080e7          	jalr	-1802(ra) # 80000c8a <release>
}
    8000339c:	60e2                	ld	ra,24(sp)
    8000339e:	6442                	ld	s0,16(sp)
    800033a0:	64a2                	ld	s1,8(sp)
    800033a2:	6902                	ld	s2,0(sp)
    800033a4:	6105                	addi	sp,sp,32
    800033a6:	8082                	ret
    panic("brelse");
    800033a8:	00005517          	auipc	a0,0x5
    800033ac:	22050513          	addi	a0,a0,544 # 800085c8 <syscalls+0xe0>
    800033b0:	ffffd097          	auipc	ra,0xffffd
    800033b4:	18e080e7          	jalr	398(ra) # 8000053e <panic>

00000000800033b8 <bpin>:

void
bpin(struct buf *b) {
    800033b8:	1101                	addi	sp,sp,-32
    800033ba:	ec06                	sd	ra,24(sp)
    800033bc:	e822                	sd	s0,16(sp)
    800033be:	e426                	sd	s1,8(sp)
    800033c0:	1000                	addi	s0,sp,32
    800033c2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033c4:	00015517          	auipc	a0,0x15
    800033c8:	c7450513          	addi	a0,a0,-908 # 80018038 <bcache>
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	80a080e7          	jalr	-2038(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800033d4:	40bc                	lw	a5,64(s1)
    800033d6:	2785                	addiw	a5,a5,1
    800033d8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033da:	00015517          	auipc	a0,0x15
    800033de:	c5e50513          	addi	a0,a0,-930 # 80018038 <bcache>
    800033e2:	ffffe097          	auipc	ra,0xffffe
    800033e6:	8a8080e7          	jalr	-1880(ra) # 80000c8a <release>
}
    800033ea:	60e2                	ld	ra,24(sp)
    800033ec:	6442                	ld	s0,16(sp)
    800033ee:	64a2                	ld	s1,8(sp)
    800033f0:	6105                	addi	sp,sp,32
    800033f2:	8082                	ret

00000000800033f4 <bunpin>:

void
bunpin(struct buf *b) {
    800033f4:	1101                	addi	sp,sp,-32
    800033f6:	ec06                	sd	ra,24(sp)
    800033f8:	e822                	sd	s0,16(sp)
    800033fa:	e426                	sd	s1,8(sp)
    800033fc:	1000                	addi	s0,sp,32
    800033fe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003400:	00015517          	auipc	a0,0x15
    80003404:	c3850513          	addi	a0,a0,-968 # 80018038 <bcache>
    80003408:	ffffd097          	auipc	ra,0xffffd
    8000340c:	7ce080e7          	jalr	1998(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003410:	40bc                	lw	a5,64(s1)
    80003412:	37fd                	addiw	a5,a5,-1
    80003414:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003416:	00015517          	auipc	a0,0x15
    8000341a:	c2250513          	addi	a0,a0,-990 # 80018038 <bcache>
    8000341e:	ffffe097          	auipc	ra,0xffffe
    80003422:	86c080e7          	jalr	-1940(ra) # 80000c8a <release>
}
    80003426:	60e2                	ld	ra,24(sp)
    80003428:	6442                	ld	s0,16(sp)
    8000342a:	64a2                	ld	s1,8(sp)
    8000342c:	6105                	addi	sp,sp,32
    8000342e:	8082                	ret

0000000080003430 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003430:	1101                	addi	sp,sp,-32
    80003432:	ec06                	sd	ra,24(sp)
    80003434:	e822                	sd	s0,16(sp)
    80003436:	e426                	sd	s1,8(sp)
    80003438:	e04a                	sd	s2,0(sp)
    8000343a:	1000                	addi	s0,sp,32
    8000343c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000343e:	00d5d59b          	srliw	a1,a1,0xd
    80003442:	0001d797          	auipc	a5,0x1d
    80003446:	2d27a783          	lw	a5,722(a5) # 80020714 <sb+0x1c>
    8000344a:	9dbd                	addw	a1,a1,a5
    8000344c:	00000097          	auipc	ra,0x0
    80003450:	d9e080e7          	jalr	-610(ra) # 800031ea <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003454:	0074f713          	andi	a4,s1,7
    80003458:	4785                	li	a5,1
    8000345a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000345e:	14ce                	slli	s1,s1,0x33
    80003460:	90d9                	srli	s1,s1,0x36
    80003462:	00950733          	add	a4,a0,s1
    80003466:	05874703          	lbu	a4,88(a4)
    8000346a:	00e7f6b3          	and	a3,a5,a4
    8000346e:	c69d                	beqz	a3,8000349c <bfree+0x6c>
    80003470:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003472:	94aa                	add	s1,s1,a0
    80003474:	fff7c793          	not	a5,a5
    80003478:	8ff9                	and	a5,a5,a4
    8000347a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000347e:	00001097          	auipc	ra,0x1
    80003482:	120080e7          	jalr	288(ra) # 8000459e <log_write>
  brelse(bp);
    80003486:	854a                	mv	a0,s2
    80003488:	00000097          	auipc	ra,0x0
    8000348c:	e92080e7          	jalr	-366(ra) # 8000331a <brelse>
}
    80003490:	60e2                	ld	ra,24(sp)
    80003492:	6442                	ld	s0,16(sp)
    80003494:	64a2                	ld	s1,8(sp)
    80003496:	6902                	ld	s2,0(sp)
    80003498:	6105                	addi	sp,sp,32
    8000349a:	8082                	ret
    panic("freeing free block");
    8000349c:	00005517          	auipc	a0,0x5
    800034a0:	13450513          	addi	a0,a0,308 # 800085d0 <syscalls+0xe8>
    800034a4:	ffffd097          	auipc	ra,0xffffd
    800034a8:	09a080e7          	jalr	154(ra) # 8000053e <panic>

00000000800034ac <balloc>:
{
    800034ac:	711d                	addi	sp,sp,-96
    800034ae:	ec86                	sd	ra,88(sp)
    800034b0:	e8a2                	sd	s0,80(sp)
    800034b2:	e4a6                	sd	s1,72(sp)
    800034b4:	e0ca                	sd	s2,64(sp)
    800034b6:	fc4e                	sd	s3,56(sp)
    800034b8:	f852                	sd	s4,48(sp)
    800034ba:	f456                	sd	s5,40(sp)
    800034bc:	f05a                	sd	s6,32(sp)
    800034be:	ec5e                	sd	s7,24(sp)
    800034c0:	e862                	sd	s8,16(sp)
    800034c2:	e466                	sd	s9,8(sp)
    800034c4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034c6:	0001d797          	auipc	a5,0x1d
    800034ca:	2367a783          	lw	a5,566(a5) # 800206fc <sb+0x4>
    800034ce:	10078163          	beqz	a5,800035d0 <balloc+0x124>
    800034d2:	8baa                	mv	s7,a0
    800034d4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034d6:	0001db17          	auipc	s6,0x1d
    800034da:	222b0b13          	addi	s6,s6,546 # 800206f8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034de:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034e0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034e2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034e4:	6c89                	lui	s9,0x2
    800034e6:	a061                	j	8000356e <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034e8:	974a                	add	a4,a4,s2
    800034ea:	8fd5                	or	a5,a5,a3
    800034ec:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800034f0:	854a                	mv	a0,s2
    800034f2:	00001097          	auipc	ra,0x1
    800034f6:	0ac080e7          	jalr	172(ra) # 8000459e <log_write>
        brelse(bp);
    800034fa:	854a                	mv	a0,s2
    800034fc:	00000097          	auipc	ra,0x0
    80003500:	e1e080e7          	jalr	-482(ra) # 8000331a <brelse>
  bp = bread(dev, bno);
    80003504:	85a6                	mv	a1,s1
    80003506:	855e                	mv	a0,s7
    80003508:	00000097          	auipc	ra,0x0
    8000350c:	ce2080e7          	jalr	-798(ra) # 800031ea <bread>
    80003510:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003512:	40000613          	li	a2,1024
    80003516:	4581                	li	a1,0
    80003518:	05850513          	addi	a0,a0,88
    8000351c:	ffffd097          	auipc	ra,0xffffd
    80003520:	7b6080e7          	jalr	1974(ra) # 80000cd2 <memset>
  log_write(bp);
    80003524:	854a                	mv	a0,s2
    80003526:	00001097          	auipc	ra,0x1
    8000352a:	078080e7          	jalr	120(ra) # 8000459e <log_write>
  brelse(bp);
    8000352e:	854a                	mv	a0,s2
    80003530:	00000097          	auipc	ra,0x0
    80003534:	dea080e7          	jalr	-534(ra) # 8000331a <brelse>
}
    80003538:	8526                	mv	a0,s1
    8000353a:	60e6                	ld	ra,88(sp)
    8000353c:	6446                	ld	s0,80(sp)
    8000353e:	64a6                	ld	s1,72(sp)
    80003540:	6906                	ld	s2,64(sp)
    80003542:	79e2                	ld	s3,56(sp)
    80003544:	7a42                	ld	s4,48(sp)
    80003546:	7aa2                	ld	s5,40(sp)
    80003548:	7b02                	ld	s6,32(sp)
    8000354a:	6be2                	ld	s7,24(sp)
    8000354c:	6c42                	ld	s8,16(sp)
    8000354e:	6ca2                	ld	s9,8(sp)
    80003550:	6125                	addi	sp,sp,96
    80003552:	8082                	ret
    brelse(bp);
    80003554:	854a                	mv	a0,s2
    80003556:	00000097          	auipc	ra,0x0
    8000355a:	dc4080e7          	jalr	-572(ra) # 8000331a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000355e:	015c87bb          	addw	a5,s9,s5
    80003562:	00078a9b          	sext.w	s5,a5
    80003566:	004b2703          	lw	a4,4(s6)
    8000356a:	06eaf363          	bgeu	s5,a4,800035d0 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000356e:	41fad79b          	sraiw	a5,s5,0x1f
    80003572:	0137d79b          	srliw	a5,a5,0x13
    80003576:	015787bb          	addw	a5,a5,s5
    8000357a:	40d7d79b          	sraiw	a5,a5,0xd
    8000357e:	01cb2583          	lw	a1,28(s6)
    80003582:	9dbd                	addw	a1,a1,a5
    80003584:	855e                	mv	a0,s7
    80003586:	00000097          	auipc	ra,0x0
    8000358a:	c64080e7          	jalr	-924(ra) # 800031ea <bread>
    8000358e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003590:	004b2503          	lw	a0,4(s6)
    80003594:	000a849b          	sext.w	s1,s5
    80003598:	8662                	mv	a2,s8
    8000359a:	faa4fde3          	bgeu	s1,a0,80003554 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000359e:	41f6579b          	sraiw	a5,a2,0x1f
    800035a2:	01d7d69b          	srliw	a3,a5,0x1d
    800035a6:	00c6873b          	addw	a4,a3,a2
    800035aa:	00777793          	andi	a5,a4,7
    800035ae:	9f95                	subw	a5,a5,a3
    800035b0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800035b4:	4037571b          	sraiw	a4,a4,0x3
    800035b8:	00e906b3          	add	a3,s2,a4
    800035bc:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    800035c0:	00d7f5b3          	and	a1,a5,a3
    800035c4:	d195                	beqz	a1,800034e8 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035c6:	2605                	addiw	a2,a2,1
    800035c8:	2485                	addiw	s1,s1,1
    800035ca:	fd4618e3          	bne	a2,s4,8000359a <balloc+0xee>
    800035ce:	b759                	j	80003554 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800035d0:	00005517          	auipc	a0,0x5
    800035d4:	01850513          	addi	a0,a0,24 # 800085e8 <syscalls+0x100>
    800035d8:	ffffd097          	auipc	ra,0xffffd
    800035dc:	fb0080e7          	jalr	-80(ra) # 80000588 <printf>
  return 0;
    800035e0:	4481                	li	s1,0
    800035e2:	bf99                	j	80003538 <balloc+0x8c>

00000000800035e4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035e4:	7179                	addi	sp,sp,-48
    800035e6:	f406                	sd	ra,40(sp)
    800035e8:	f022                	sd	s0,32(sp)
    800035ea:	ec26                	sd	s1,24(sp)
    800035ec:	e84a                	sd	s2,16(sp)
    800035ee:	e44e                	sd	s3,8(sp)
    800035f0:	e052                	sd	s4,0(sp)
    800035f2:	1800                	addi	s0,sp,48
    800035f4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035f6:	47ad                	li	a5,11
    800035f8:	02b7e763          	bltu	a5,a1,80003626 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800035fc:	02059493          	slli	s1,a1,0x20
    80003600:	9081                	srli	s1,s1,0x20
    80003602:	048a                	slli	s1,s1,0x2
    80003604:	94aa                	add	s1,s1,a0
    80003606:	0504a903          	lw	s2,80(s1)
    8000360a:	06091e63          	bnez	s2,80003686 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000360e:	4108                	lw	a0,0(a0)
    80003610:	00000097          	auipc	ra,0x0
    80003614:	e9c080e7          	jalr	-356(ra) # 800034ac <balloc>
    80003618:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000361c:	06090563          	beqz	s2,80003686 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003620:	0524a823          	sw	s2,80(s1)
    80003624:	a08d                	j	80003686 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003626:	ff45849b          	addiw	s1,a1,-12
    8000362a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000362e:	0ff00793          	li	a5,255
    80003632:	08e7e563          	bltu	a5,a4,800036bc <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003636:	08052903          	lw	s2,128(a0)
    8000363a:	00091d63          	bnez	s2,80003654 <bmap+0x70>
      addr = balloc(ip->dev);
    8000363e:	4108                	lw	a0,0(a0)
    80003640:	00000097          	auipc	ra,0x0
    80003644:	e6c080e7          	jalr	-404(ra) # 800034ac <balloc>
    80003648:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000364c:	02090d63          	beqz	s2,80003686 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003650:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003654:	85ca                	mv	a1,s2
    80003656:	0009a503          	lw	a0,0(s3)
    8000365a:	00000097          	auipc	ra,0x0
    8000365e:	b90080e7          	jalr	-1136(ra) # 800031ea <bread>
    80003662:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003664:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003668:	02049593          	slli	a1,s1,0x20
    8000366c:	9181                	srli	a1,a1,0x20
    8000366e:	058a                	slli	a1,a1,0x2
    80003670:	00b784b3          	add	s1,a5,a1
    80003674:	0004a903          	lw	s2,0(s1)
    80003678:	02090063          	beqz	s2,80003698 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000367c:	8552                	mv	a0,s4
    8000367e:	00000097          	auipc	ra,0x0
    80003682:	c9c080e7          	jalr	-868(ra) # 8000331a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003686:	854a                	mv	a0,s2
    80003688:	70a2                	ld	ra,40(sp)
    8000368a:	7402                	ld	s0,32(sp)
    8000368c:	64e2                	ld	s1,24(sp)
    8000368e:	6942                	ld	s2,16(sp)
    80003690:	69a2                	ld	s3,8(sp)
    80003692:	6a02                	ld	s4,0(sp)
    80003694:	6145                	addi	sp,sp,48
    80003696:	8082                	ret
      addr = balloc(ip->dev);
    80003698:	0009a503          	lw	a0,0(s3)
    8000369c:	00000097          	auipc	ra,0x0
    800036a0:	e10080e7          	jalr	-496(ra) # 800034ac <balloc>
    800036a4:	0005091b          	sext.w	s2,a0
      if(addr){
    800036a8:	fc090ae3          	beqz	s2,8000367c <bmap+0x98>
        a[bn] = addr;
    800036ac:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800036b0:	8552                	mv	a0,s4
    800036b2:	00001097          	auipc	ra,0x1
    800036b6:	eec080e7          	jalr	-276(ra) # 8000459e <log_write>
    800036ba:	b7c9                	j	8000367c <bmap+0x98>
  panic("bmap: out of range");
    800036bc:	00005517          	auipc	a0,0x5
    800036c0:	f4450513          	addi	a0,a0,-188 # 80008600 <syscalls+0x118>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	e7a080e7          	jalr	-390(ra) # 8000053e <panic>

00000000800036cc <iget>:
{
    800036cc:	7179                	addi	sp,sp,-48
    800036ce:	f406                	sd	ra,40(sp)
    800036d0:	f022                	sd	s0,32(sp)
    800036d2:	ec26                	sd	s1,24(sp)
    800036d4:	e84a                	sd	s2,16(sp)
    800036d6:	e44e                	sd	s3,8(sp)
    800036d8:	e052                	sd	s4,0(sp)
    800036da:	1800                	addi	s0,sp,48
    800036dc:	89aa                	mv	s3,a0
    800036de:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036e0:	0001d517          	auipc	a0,0x1d
    800036e4:	03850513          	addi	a0,a0,56 # 80020718 <itable>
    800036e8:	ffffd097          	auipc	ra,0xffffd
    800036ec:	4ee080e7          	jalr	1262(ra) # 80000bd6 <acquire>
  empty = 0;
    800036f0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036f2:	0001d497          	auipc	s1,0x1d
    800036f6:	03e48493          	addi	s1,s1,62 # 80020730 <itable+0x18>
    800036fa:	0001f697          	auipc	a3,0x1f
    800036fe:	ac668693          	addi	a3,a3,-1338 # 800221c0 <log>
    80003702:	a039                	j	80003710 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003704:	02090b63          	beqz	s2,8000373a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003708:	08848493          	addi	s1,s1,136
    8000370c:	02d48a63          	beq	s1,a3,80003740 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003710:	449c                	lw	a5,8(s1)
    80003712:	fef059e3          	blez	a5,80003704 <iget+0x38>
    80003716:	4098                	lw	a4,0(s1)
    80003718:	ff3716e3          	bne	a4,s3,80003704 <iget+0x38>
    8000371c:	40d8                	lw	a4,4(s1)
    8000371e:	ff4713e3          	bne	a4,s4,80003704 <iget+0x38>
      ip->ref++;
    80003722:	2785                	addiw	a5,a5,1
    80003724:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003726:	0001d517          	auipc	a0,0x1d
    8000372a:	ff250513          	addi	a0,a0,-14 # 80020718 <itable>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	55c080e7          	jalr	1372(ra) # 80000c8a <release>
      return ip;
    80003736:	8926                	mv	s2,s1
    80003738:	a03d                	j	80003766 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000373a:	f7f9                	bnez	a5,80003708 <iget+0x3c>
    8000373c:	8926                	mv	s2,s1
    8000373e:	b7e9                	j	80003708 <iget+0x3c>
  if(empty == 0)
    80003740:	02090c63          	beqz	s2,80003778 <iget+0xac>
  ip->dev = dev;
    80003744:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003748:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000374c:	4785                	li	a5,1
    8000374e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003752:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003756:	0001d517          	auipc	a0,0x1d
    8000375a:	fc250513          	addi	a0,a0,-62 # 80020718 <itable>
    8000375e:	ffffd097          	auipc	ra,0xffffd
    80003762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80003766:	854a                	mv	a0,s2
    80003768:	70a2                	ld	ra,40(sp)
    8000376a:	7402                	ld	s0,32(sp)
    8000376c:	64e2                	ld	s1,24(sp)
    8000376e:	6942                	ld	s2,16(sp)
    80003770:	69a2                	ld	s3,8(sp)
    80003772:	6a02                	ld	s4,0(sp)
    80003774:	6145                	addi	sp,sp,48
    80003776:	8082                	ret
    panic("iget: no inodes");
    80003778:	00005517          	auipc	a0,0x5
    8000377c:	ea050513          	addi	a0,a0,-352 # 80008618 <syscalls+0x130>
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	dbe080e7          	jalr	-578(ra) # 8000053e <panic>

0000000080003788 <fsinit>:
fsinit(int dev) {
    80003788:	7179                	addi	sp,sp,-48
    8000378a:	f406                	sd	ra,40(sp)
    8000378c:	f022                	sd	s0,32(sp)
    8000378e:	ec26                	sd	s1,24(sp)
    80003790:	e84a                	sd	s2,16(sp)
    80003792:	e44e                	sd	s3,8(sp)
    80003794:	1800                	addi	s0,sp,48
    80003796:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003798:	4585                	li	a1,1
    8000379a:	00000097          	auipc	ra,0x0
    8000379e:	a50080e7          	jalr	-1456(ra) # 800031ea <bread>
    800037a2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037a4:	0001d997          	auipc	s3,0x1d
    800037a8:	f5498993          	addi	s3,s3,-172 # 800206f8 <sb>
    800037ac:	02000613          	li	a2,32
    800037b0:	05850593          	addi	a1,a0,88
    800037b4:	854e                	mv	a0,s3
    800037b6:	ffffd097          	auipc	ra,0xffffd
    800037ba:	578080e7          	jalr	1400(ra) # 80000d2e <memmove>
  brelse(bp);
    800037be:	8526                	mv	a0,s1
    800037c0:	00000097          	auipc	ra,0x0
    800037c4:	b5a080e7          	jalr	-1190(ra) # 8000331a <brelse>
  if(sb.magic != FSMAGIC)
    800037c8:	0009a703          	lw	a4,0(s3)
    800037cc:	102037b7          	lui	a5,0x10203
    800037d0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037d4:	02f71263          	bne	a4,a5,800037f8 <fsinit+0x70>
  initlog(dev, &sb);
    800037d8:	0001d597          	auipc	a1,0x1d
    800037dc:	f2058593          	addi	a1,a1,-224 # 800206f8 <sb>
    800037e0:	854a                	mv	a0,s2
    800037e2:	00001097          	auipc	ra,0x1
    800037e6:	b40080e7          	jalr	-1216(ra) # 80004322 <initlog>
}
    800037ea:	70a2                	ld	ra,40(sp)
    800037ec:	7402                	ld	s0,32(sp)
    800037ee:	64e2                	ld	s1,24(sp)
    800037f0:	6942                	ld	s2,16(sp)
    800037f2:	69a2                	ld	s3,8(sp)
    800037f4:	6145                	addi	sp,sp,48
    800037f6:	8082                	ret
    panic("invalid file system");
    800037f8:	00005517          	auipc	a0,0x5
    800037fc:	e3050513          	addi	a0,a0,-464 # 80008628 <syscalls+0x140>
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	d3e080e7          	jalr	-706(ra) # 8000053e <panic>

0000000080003808 <iinit>:
{
    80003808:	7179                	addi	sp,sp,-48
    8000380a:	f406                	sd	ra,40(sp)
    8000380c:	f022                	sd	s0,32(sp)
    8000380e:	ec26                	sd	s1,24(sp)
    80003810:	e84a                	sd	s2,16(sp)
    80003812:	e44e                	sd	s3,8(sp)
    80003814:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003816:	00005597          	auipc	a1,0x5
    8000381a:	e2a58593          	addi	a1,a1,-470 # 80008640 <syscalls+0x158>
    8000381e:	0001d517          	auipc	a0,0x1d
    80003822:	efa50513          	addi	a0,a0,-262 # 80020718 <itable>
    80003826:	ffffd097          	auipc	ra,0xffffd
    8000382a:	320080e7          	jalr	800(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000382e:	0001d497          	auipc	s1,0x1d
    80003832:	f1248493          	addi	s1,s1,-238 # 80020740 <itable+0x28>
    80003836:	0001f997          	auipc	s3,0x1f
    8000383a:	99a98993          	addi	s3,s3,-1638 # 800221d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000383e:	00005917          	auipc	s2,0x5
    80003842:	e0a90913          	addi	s2,s2,-502 # 80008648 <syscalls+0x160>
    80003846:	85ca                	mv	a1,s2
    80003848:	8526                	mv	a0,s1
    8000384a:	00001097          	auipc	ra,0x1
    8000384e:	e3a080e7          	jalr	-454(ra) # 80004684 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003852:	08848493          	addi	s1,s1,136
    80003856:	ff3498e3          	bne	s1,s3,80003846 <iinit+0x3e>
}
    8000385a:	70a2                	ld	ra,40(sp)
    8000385c:	7402                	ld	s0,32(sp)
    8000385e:	64e2                	ld	s1,24(sp)
    80003860:	6942                	ld	s2,16(sp)
    80003862:	69a2                	ld	s3,8(sp)
    80003864:	6145                	addi	sp,sp,48
    80003866:	8082                	ret

0000000080003868 <ialloc>:
{
    80003868:	715d                	addi	sp,sp,-80
    8000386a:	e486                	sd	ra,72(sp)
    8000386c:	e0a2                	sd	s0,64(sp)
    8000386e:	fc26                	sd	s1,56(sp)
    80003870:	f84a                	sd	s2,48(sp)
    80003872:	f44e                	sd	s3,40(sp)
    80003874:	f052                	sd	s4,32(sp)
    80003876:	ec56                	sd	s5,24(sp)
    80003878:	e85a                	sd	s6,16(sp)
    8000387a:	e45e                	sd	s7,8(sp)
    8000387c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000387e:	0001d717          	auipc	a4,0x1d
    80003882:	e8672703          	lw	a4,-378(a4) # 80020704 <sb+0xc>
    80003886:	4785                	li	a5,1
    80003888:	04e7fa63          	bgeu	a5,a4,800038dc <ialloc+0x74>
    8000388c:	8aaa                	mv	s5,a0
    8000388e:	8bae                	mv	s7,a1
    80003890:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003892:	0001da17          	auipc	s4,0x1d
    80003896:	e66a0a13          	addi	s4,s4,-410 # 800206f8 <sb>
    8000389a:	00048b1b          	sext.w	s6,s1
    8000389e:	0044d793          	srli	a5,s1,0x4
    800038a2:	018a2583          	lw	a1,24(s4)
    800038a6:	9dbd                	addw	a1,a1,a5
    800038a8:	8556                	mv	a0,s5
    800038aa:	00000097          	auipc	ra,0x0
    800038ae:	940080e7          	jalr	-1728(ra) # 800031ea <bread>
    800038b2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800038b4:	05850993          	addi	s3,a0,88
    800038b8:	00f4f793          	andi	a5,s1,15
    800038bc:	079a                	slli	a5,a5,0x6
    800038be:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800038c0:	00099783          	lh	a5,0(s3)
    800038c4:	c3a1                	beqz	a5,80003904 <ialloc+0x9c>
    brelse(bp);
    800038c6:	00000097          	auipc	ra,0x0
    800038ca:	a54080e7          	jalr	-1452(ra) # 8000331a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038ce:	0485                	addi	s1,s1,1
    800038d0:	00ca2703          	lw	a4,12(s4)
    800038d4:	0004879b          	sext.w	a5,s1
    800038d8:	fce7e1e3          	bltu	a5,a4,8000389a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800038dc:	00005517          	auipc	a0,0x5
    800038e0:	d7450513          	addi	a0,a0,-652 # 80008650 <syscalls+0x168>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	ca4080e7          	jalr	-860(ra) # 80000588 <printf>
  return 0;
    800038ec:	4501                	li	a0,0
}
    800038ee:	60a6                	ld	ra,72(sp)
    800038f0:	6406                	ld	s0,64(sp)
    800038f2:	74e2                	ld	s1,56(sp)
    800038f4:	7942                	ld	s2,48(sp)
    800038f6:	79a2                	ld	s3,40(sp)
    800038f8:	7a02                	ld	s4,32(sp)
    800038fa:	6ae2                	ld	s5,24(sp)
    800038fc:	6b42                	ld	s6,16(sp)
    800038fe:	6ba2                	ld	s7,8(sp)
    80003900:	6161                	addi	sp,sp,80
    80003902:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003904:	04000613          	li	a2,64
    80003908:	4581                	li	a1,0
    8000390a:	854e                	mv	a0,s3
    8000390c:	ffffd097          	auipc	ra,0xffffd
    80003910:	3c6080e7          	jalr	966(ra) # 80000cd2 <memset>
      dip->type = type;
    80003914:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003918:	854a                	mv	a0,s2
    8000391a:	00001097          	auipc	ra,0x1
    8000391e:	c84080e7          	jalr	-892(ra) # 8000459e <log_write>
      brelse(bp);
    80003922:	854a                	mv	a0,s2
    80003924:	00000097          	auipc	ra,0x0
    80003928:	9f6080e7          	jalr	-1546(ra) # 8000331a <brelse>
      return iget(dev, inum);
    8000392c:	85da                	mv	a1,s6
    8000392e:	8556                	mv	a0,s5
    80003930:	00000097          	auipc	ra,0x0
    80003934:	d9c080e7          	jalr	-612(ra) # 800036cc <iget>
    80003938:	bf5d                	j	800038ee <ialloc+0x86>

000000008000393a <iupdate>:
{
    8000393a:	1101                	addi	sp,sp,-32
    8000393c:	ec06                	sd	ra,24(sp)
    8000393e:	e822                	sd	s0,16(sp)
    80003940:	e426                	sd	s1,8(sp)
    80003942:	e04a                	sd	s2,0(sp)
    80003944:	1000                	addi	s0,sp,32
    80003946:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003948:	415c                	lw	a5,4(a0)
    8000394a:	0047d79b          	srliw	a5,a5,0x4
    8000394e:	0001d597          	auipc	a1,0x1d
    80003952:	dc25a583          	lw	a1,-574(a1) # 80020710 <sb+0x18>
    80003956:	9dbd                	addw	a1,a1,a5
    80003958:	4108                	lw	a0,0(a0)
    8000395a:	00000097          	auipc	ra,0x0
    8000395e:	890080e7          	jalr	-1904(ra) # 800031ea <bread>
    80003962:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003964:	05850793          	addi	a5,a0,88
    80003968:	40c8                	lw	a0,4(s1)
    8000396a:	893d                	andi	a0,a0,15
    8000396c:	051a                	slli	a0,a0,0x6
    8000396e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003970:	04449703          	lh	a4,68(s1)
    80003974:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003978:	04649703          	lh	a4,70(s1)
    8000397c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003980:	04849703          	lh	a4,72(s1)
    80003984:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003988:	04a49703          	lh	a4,74(s1)
    8000398c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003990:	44f8                	lw	a4,76(s1)
    80003992:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003994:	03400613          	li	a2,52
    80003998:	05048593          	addi	a1,s1,80
    8000399c:	0531                	addi	a0,a0,12
    8000399e:	ffffd097          	auipc	ra,0xffffd
    800039a2:	390080e7          	jalr	912(ra) # 80000d2e <memmove>
  log_write(bp);
    800039a6:	854a                	mv	a0,s2
    800039a8:	00001097          	auipc	ra,0x1
    800039ac:	bf6080e7          	jalr	-1034(ra) # 8000459e <log_write>
  brelse(bp);
    800039b0:	854a                	mv	a0,s2
    800039b2:	00000097          	auipc	ra,0x0
    800039b6:	968080e7          	jalr	-1688(ra) # 8000331a <brelse>
}
    800039ba:	60e2                	ld	ra,24(sp)
    800039bc:	6442                	ld	s0,16(sp)
    800039be:	64a2                	ld	s1,8(sp)
    800039c0:	6902                	ld	s2,0(sp)
    800039c2:	6105                	addi	sp,sp,32
    800039c4:	8082                	ret

00000000800039c6 <idup>:
{
    800039c6:	1101                	addi	sp,sp,-32
    800039c8:	ec06                	sd	ra,24(sp)
    800039ca:	e822                	sd	s0,16(sp)
    800039cc:	e426                	sd	s1,8(sp)
    800039ce:	1000                	addi	s0,sp,32
    800039d0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039d2:	0001d517          	auipc	a0,0x1d
    800039d6:	d4650513          	addi	a0,a0,-698 # 80020718 <itable>
    800039da:	ffffd097          	auipc	ra,0xffffd
    800039de:	1fc080e7          	jalr	508(ra) # 80000bd6 <acquire>
  ip->ref++;
    800039e2:	449c                	lw	a5,8(s1)
    800039e4:	2785                	addiw	a5,a5,1
    800039e6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039e8:	0001d517          	auipc	a0,0x1d
    800039ec:	d3050513          	addi	a0,a0,-720 # 80020718 <itable>
    800039f0:	ffffd097          	auipc	ra,0xffffd
    800039f4:	29a080e7          	jalr	666(ra) # 80000c8a <release>
}
    800039f8:	8526                	mv	a0,s1
    800039fa:	60e2                	ld	ra,24(sp)
    800039fc:	6442                	ld	s0,16(sp)
    800039fe:	64a2                	ld	s1,8(sp)
    80003a00:	6105                	addi	sp,sp,32
    80003a02:	8082                	ret

0000000080003a04 <ilock>:
{
    80003a04:	1101                	addi	sp,sp,-32
    80003a06:	ec06                	sd	ra,24(sp)
    80003a08:	e822                	sd	s0,16(sp)
    80003a0a:	e426                	sd	s1,8(sp)
    80003a0c:	e04a                	sd	s2,0(sp)
    80003a0e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a10:	c115                	beqz	a0,80003a34 <ilock+0x30>
    80003a12:	84aa                	mv	s1,a0
    80003a14:	451c                	lw	a5,8(a0)
    80003a16:	00f05f63          	blez	a5,80003a34 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a1a:	0541                	addi	a0,a0,16
    80003a1c:	00001097          	auipc	ra,0x1
    80003a20:	ca2080e7          	jalr	-862(ra) # 800046be <acquiresleep>
  if(ip->valid == 0){
    80003a24:	40bc                	lw	a5,64(s1)
    80003a26:	cf99                	beqz	a5,80003a44 <ilock+0x40>
}
    80003a28:	60e2                	ld	ra,24(sp)
    80003a2a:	6442                	ld	s0,16(sp)
    80003a2c:	64a2                	ld	s1,8(sp)
    80003a2e:	6902                	ld	s2,0(sp)
    80003a30:	6105                	addi	sp,sp,32
    80003a32:	8082                	ret
    panic("ilock");
    80003a34:	00005517          	auipc	a0,0x5
    80003a38:	c3450513          	addi	a0,a0,-972 # 80008668 <syscalls+0x180>
    80003a3c:	ffffd097          	auipc	ra,0xffffd
    80003a40:	b02080e7          	jalr	-1278(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a44:	40dc                	lw	a5,4(s1)
    80003a46:	0047d79b          	srliw	a5,a5,0x4
    80003a4a:	0001d597          	auipc	a1,0x1d
    80003a4e:	cc65a583          	lw	a1,-826(a1) # 80020710 <sb+0x18>
    80003a52:	9dbd                	addw	a1,a1,a5
    80003a54:	4088                	lw	a0,0(s1)
    80003a56:	fffff097          	auipc	ra,0xfffff
    80003a5a:	794080e7          	jalr	1940(ra) # 800031ea <bread>
    80003a5e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a60:	05850593          	addi	a1,a0,88
    80003a64:	40dc                	lw	a5,4(s1)
    80003a66:	8bbd                	andi	a5,a5,15
    80003a68:	079a                	slli	a5,a5,0x6
    80003a6a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a6c:	00059783          	lh	a5,0(a1)
    80003a70:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a74:	00259783          	lh	a5,2(a1)
    80003a78:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a7c:	00459783          	lh	a5,4(a1)
    80003a80:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a84:	00659783          	lh	a5,6(a1)
    80003a88:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a8c:	459c                	lw	a5,8(a1)
    80003a8e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a90:	03400613          	li	a2,52
    80003a94:	05b1                	addi	a1,a1,12
    80003a96:	05048513          	addi	a0,s1,80
    80003a9a:	ffffd097          	auipc	ra,0xffffd
    80003a9e:	294080e7          	jalr	660(ra) # 80000d2e <memmove>
    brelse(bp);
    80003aa2:	854a                	mv	a0,s2
    80003aa4:	00000097          	auipc	ra,0x0
    80003aa8:	876080e7          	jalr	-1930(ra) # 8000331a <brelse>
    ip->valid = 1;
    80003aac:	4785                	li	a5,1
    80003aae:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ab0:	04449783          	lh	a5,68(s1)
    80003ab4:	fbb5                	bnez	a5,80003a28 <ilock+0x24>
      panic("ilock: no type");
    80003ab6:	00005517          	auipc	a0,0x5
    80003aba:	bba50513          	addi	a0,a0,-1094 # 80008670 <syscalls+0x188>
    80003abe:	ffffd097          	auipc	ra,0xffffd
    80003ac2:	a80080e7          	jalr	-1408(ra) # 8000053e <panic>

0000000080003ac6 <iunlock>:
{
    80003ac6:	1101                	addi	sp,sp,-32
    80003ac8:	ec06                	sd	ra,24(sp)
    80003aca:	e822                	sd	s0,16(sp)
    80003acc:	e426                	sd	s1,8(sp)
    80003ace:	e04a                	sd	s2,0(sp)
    80003ad0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ad2:	c905                	beqz	a0,80003b02 <iunlock+0x3c>
    80003ad4:	84aa                	mv	s1,a0
    80003ad6:	01050913          	addi	s2,a0,16
    80003ada:	854a                	mv	a0,s2
    80003adc:	00001097          	auipc	ra,0x1
    80003ae0:	c7c080e7          	jalr	-900(ra) # 80004758 <holdingsleep>
    80003ae4:	cd19                	beqz	a0,80003b02 <iunlock+0x3c>
    80003ae6:	449c                	lw	a5,8(s1)
    80003ae8:	00f05d63          	blez	a5,80003b02 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003aec:	854a                	mv	a0,s2
    80003aee:	00001097          	auipc	ra,0x1
    80003af2:	c26080e7          	jalr	-986(ra) # 80004714 <releasesleep>
}
    80003af6:	60e2                	ld	ra,24(sp)
    80003af8:	6442                	ld	s0,16(sp)
    80003afa:	64a2                	ld	s1,8(sp)
    80003afc:	6902                	ld	s2,0(sp)
    80003afe:	6105                	addi	sp,sp,32
    80003b00:	8082                	ret
    panic("iunlock");
    80003b02:	00005517          	auipc	a0,0x5
    80003b06:	b7e50513          	addi	a0,a0,-1154 # 80008680 <syscalls+0x198>
    80003b0a:	ffffd097          	auipc	ra,0xffffd
    80003b0e:	a34080e7          	jalr	-1484(ra) # 8000053e <panic>

0000000080003b12 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b12:	7179                	addi	sp,sp,-48
    80003b14:	f406                	sd	ra,40(sp)
    80003b16:	f022                	sd	s0,32(sp)
    80003b18:	ec26                	sd	s1,24(sp)
    80003b1a:	e84a                	sd	s2,16(sp)
    80003b1c:	e44e                	sd	s3,8(sp)
    80003b1e:	e052                	sd	s4,0(sp)
    80003b20:	1800                	addi	s0,sp,48
    80003b22:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b24:	05050493          	addi	s1,a0,80
    80003b28:	08050913          	addi	s2,a0,128
    80003b2c:	a021                	j	80003b34 <itrunc+0x22>
    80003b2e:	0491                	addi	s1,s1,4
    80003b30:	01248d63          	beq	s1,s2,80003b4a <itrunc+0x38>
    if(ip->addrs[i]){
    80003b34:	408c                	lw	a1,0(s1)
    80003b36:	dde5                	beqz	a1,80003b2e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b38:	0009a503          	lw	a0,0(s3)
    80003b3c:	00000097          	auipc	ra,0x0
    80003b40:	8f4080e7          	jalr	-1804(ra) # 80003430 <bfree>
      ip->addrs[i] = 0;
    80003b44:	0004a023          	sw	zero,0(s1)
    80003b48:	b7dd                	j	80003b2e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b4a:	0809a583          	lw	a1,128(s3)
    80003b4e:	e185                	bnez	a1,80003b6e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b50:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b54:	854e                	mv	a0,s3
    80003b56:	00000097          	auipc	ra,0x0
    80003b5a:	de4080e7          	jalr	-540(ra) # 8000393a <iupdate>
}
    80003b5e:	70a2                	ld	ra,40(sp)
    80003b60:	7402                	ld	s0,32(sp)
    80003b62:	64e2                	ld	s1,24(sp)
    80003b64:	6942                	ld	s2,16(sp)
    80003b66:	69a2                	ld	s3,8(sp)
    80003b68:	6a02                	ld	s4,0(sp)
    80003b6a:	6145                	addi	sp,sp,48
    80003b6c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b6e:	0009a503          	lw	a0,0(s3)
    80003b72:	fffff097          	auipc	ra,0xfffff
    80003b76:	678080e7          	jalr	1656(ra) # 800031ea <bread>
    80003b7a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b7c:	05850493          	addi	s1,a0,88
    80003b80:	45850913          	addi	s2,a0,1112
    80003b84:	a021                	j	80003b8c <itrunc+0x7a>
    80003b86:	0491                	addi	s1,s1,4
    80003b88:	01248b63          	beq	s1,s2,80003b9e <itrunc+0x8c>
      if(a[j])
    80003b8c:	408c                	lw	a1,0(s1)
    80003b8e:	dde5                	beqz	a1,80003b86 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b90:	0009a503          	lw	a0,0(s3)
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	89c080e7          	jalr	-1892(ra) # 80003430 <bfree>
    80003b9c:	b7ed                	j	80003b86 <itrunc+0x74>
    brelse(bp);
    80003b9e:	8552                	mv	a0,s4
    80003ba0:	fffff097          	auipc	ra,0xfffff
    80003ba4:	77a080e7          	jalr	1914(ra) # 8000331a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ba8:	0809a583          	lw	a1,128(s3)
    80003bac:	0009a503          	lw	a0,0(s3)
    80003bb0:	00000097          	auipc	ra,0x0
    80003bb4:	880080e7          	jalr	-1920(ra) # 80003430 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003bb8:	0809a023          	sw	zero,128(s3)
    80003bbc:	bf51                	j	80003b50 <itrunc+0x3e>

0000000080003bbe <iput>:
{
    80003bbe:	1101                	addi	sp,sp,-32
    80003bc0:	ec06                	sd	ra,24(sp)
    80003bc2:	e822                	sd	s0,16(sp)
    80003bc4:	e426                	sd	s1,8(sp)
    80003bc6:	e04a                	sd	s2,0(sp)
    80003bc8:	1000                	addi	s0,sp,32
    80003bca:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bcc:	0001d517          	auipc	a0,0x1d
    80003bd0:	b4c50513          	addi	a0,a0,-1204 # 80020718 <itable>
    80003bd4:	ffffd097          	auipc	ra,0xffffd
    80003bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bdc:	4498                	lw	a4,8(s1)
    80003bde:	4785                	li	a5,1
    80003be0:	02f70363          	beq	a4,a5,80003c06 <iput+0x48>
  ip->ref--;
    80003be4:	449c                	lw	a5,8(s1)
    80003be6:	37fd                	addiw	a5,a5,-1
    80003be8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bea:	0001d517          	auipc	a0,0x1d
    80003bee:	b2e50513          	addi	a0,a0,-1234 # 80020718 <itable>
    80003bf2:	ffffd097          	auipc	ra,0xffffd
    80003bf6:	098080e7          	jalr	152(ra) # 80000c8a <release>
}
    80003bfa:	60e2                	ld	ra,24(sp)
    80003bfc:	6442                	ld	s0,16(sp)
    80003bfe:	64a2                	ld	s1,8(sp)
    80003c00:	6902                	ld	s2,0(sp)
    80003c02:	6105                	addi	sp,sp,32
    80003c04:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c06:	40bc                	lw	a5,64(s1)
    80003c08:	dff1                	beqz	a5,80003be4 <iput+0x26>
    80003c0a:	04a49783          	lh	a5,74(s1)
    80003c0e:	fbf9                	bnez	a5,80003be4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003c10:	01048913          	addi	s2,s1,16
    80003c14:	854a                	mv	a0,s2
    80003c16:	00001097          	auipc	ra,0x1
    80003c1a:	aa8080e7          	jalr	-1368(ra) # 800046be <acquiresleep>
    release(&itable.lock);
    80003c1e:	0001d517          	auipc	a0,0x1d
    80003c22:	afa50513          	addi	a0,a0,-1286 # 80020718 <itable>
    80003c26:	ffffd097          	auipc	ra,0xffffd
    80003c2a:	064080e7          	jalr	100(ra) # 80000c8a <release>
    itrunc(ip);
    80003c2e:	8526                	mv	a0,s1
    80003c30:	00000097          	auipc	ra,0x0
    80003c34:	ee2080e7          	jalr	-286(ra) # 80003b12 <itrunc>
    ip->type = 0;
    80003c38:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c3c:	8526                	mv	a0,s1
    80003c3e:	00000097          	auipc	ra,0x0
    80003c42:	cfc080e7          	jalr	-772(ra) # 8000393a <iupdate>
    ip->valid = 0;
    80003c46:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c4a:	854a                	mv	a0,s2
    80003c4c:	00001097          	auipc	ra,0x1
    80003c50:	ac8080e7          	jalr	-1336(ra) # 80004714 <releasesleep>
    acquire(&itable.lock);
    80003c54:	0001d517          	auipc	a0,0x1d
    80003c58:	ac450513          	addi	a0,a0,-1340 # 80020718 <itable>
    80003c5c:	ffffd097          	auipc	ra,0xffffd
    80003c60:	f7a080e7          	jalr	-134(ra) # 80000bd6 <acquire>
    80003c64:	b741                	j	80003be4 <iput+0x26>

0000000080003c66 <iunlockput>:
{
    80003c66:	1101                	addi	sp,sp,-32
    80003c68:	ec06                	sd	ra,24(sp)
    80003c6a:	e822                	sd	s0,16(sp)
    80003c6c:	e426                	sd	s1,8(sp)
    80003c6e:	1000                	addi	s0,sp,32
    80003c70:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c72:	00000097          	auipc	ra,0x0
    80003c76:	e54080e7          	jalr	-428(ra) # 80003ac6 <iunlock>
  iput(ip);
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	00000097          	auipc	ra,0x0
    80003c80:	f42080e7          	jalr	-190(ra) # 80003bbe <iput>
}
    80003c84:	60e2                	ld	ra,24(sp)
    80003c86:	6442                	ld	s0,16(sp)
    80003c88:	64a2                	ld	s1,8(sp)
    80003c8a:	6105                	addi	sp,sp,32
    80003c8c:	8082                	ret

0000000080003c8e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c8e:	1141                	addi	sp,sp,-16
    80003c90:	e422                	sd	s0,8(sp)
    80003c92:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c94:	411c                	lw	a5,0(a0)
    80003c96:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c98:	415c                	lw	a5,4(a0)
    80003c9a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c9c:	04451783          	lh	a5,68(a0)
    80003ca0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ca4:	04a51783          	lh	a5,74(a0)
    80003ca8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003cac:	04c56783          	lwu	a5,76(a0)
    80003cb0:	e99c                	sd	a5,16(a1)
}
    80003cb2:	6422                	ld	s0,8(sp)
    80003cb4:	0141                	addi	sp,sp,16
    80003cb6:	8082                	ret

0000000080003cb8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cb8:	457c                	lw	a5,76(a0)
    80003cba:	0ed7e963          	bltu	a5,a3,80003dac <readi+0xf4>
{
    80003cbe:	7159                	addi	sp,sp,-112
    80003cc0:	f486                	sd	ra,104(sp)
    80003cc2:	f0a2                	sd	s0,96(sp)
    80003cc4:	eca6                	sd	s1,88(sp)
    80003cc6:	e8ca                	sd	s2,80(sp)
    80003cc8:	e4ce                	sd	s3,72(sp)
    80003cca:	e0d2                	sd	s4,64(sp)
    80003ccc:	fc56                	sd	s5,56(sp)
    80003cce:	f85a                	sd	s6,48(sp)
    80003cd0:	f45e                	sd	s7,40(sp)
    80003cd2:	f062                	sd	s8,32(sp)
    80003cd4:	ec66                	sd	s9,24(sp)
    80003cd6:	e86a                	sd	s10,16(sp)
    80003cd8:	e46e                	sd	s11,8(sp)
    80003cda:	1880                	addi	s0,sp,112
    80003cdc:	8b2a                	mv	s6,a0
    80003cde:	8bae                	mv	s7,a1
    80003ce0:	8a32                	mv	s4,a2
    80003ce2:	84b6                	mv	s1,a3
    80003ce4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ce6:	9f35                	addw	a4,a4,a3
    return 0;
    80003ce8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cea:	0ad76063          	bltu	a4,a3,80003d8a <readi+0xd2>
  if(off + n > ip->size)
    80003cee:	00e7f463          	bgeu	a5,a4,80003cf6 <readi+0x3e>
    n = ip->size - off;
    80003cf2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cf6:	0a0a8963          	beqz	s5,80003da8 <readi+0xf0>
    80003cfa:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cfc:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d00:	5c7d                	li	s8,-1
    80003d02:	a82d                	j	80003d3c <readi+0x84>
    80003d04:	020d1d93          	slli	s11,s10,0x20
    80003d08:	020ddd93          	srli	s11,s11,0x20
    80003d0c:	05890793          	addi	a5,s2,88
    80003d10:	86ee                	mv	a3,s11
    80003d12:	963e                	add	a2,a2,a5
    80003d14:	85d2                	mv	a1,s4
    80003d16:	855e                	mv	a0,s7
    80003d18:	fffff097          	auipc	ra,0xfffff
    80003d1c:	8ce080e7          	jalr	-1842(ra) # 800025e6 <either_copyout>
    80003d20:	05850d63          	beq	a0,s8,80003d7a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d24:	854a                	mv	a0,s2
    80003d26:	fffff097          	auipc	ra,0xfffff
    80003d2a:	5f4080e7          	jalr	1524(ra) # 8000331a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d2e:	013d09bb          	addw	s3,s10,s3
    80003d32:	009d04bb          	addw	s1,s10,s1
    80003d36:	9a6e                	add	s4,s4,s11
    80003d38:	0559f763          	bgeu	s3,s5,80003d86 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003d3c:	00a4d59b          	srliw	a1,s1,0xa
    80003d40:	855a                	mv	a0,s6
    80003d42:	00000097          	auipc	ra,0x0
    80003d46:	8a2080e7          	jalr	-1886(ra) # 800035e4 <bmap>
    80003d4a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d4e:	cd85                	beqz	a1,80003d86 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d50:	000b2503          	lw	a0,0(s6)
    80003d54:	fffff097          	auipc	ra,0xfffff
    80003d58:	496080e7          	jalr	1174(ra) # 800031ea <bread>
    80003d5c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d5e:	3ff4f613          	andi	a2,s1,1023
    80003d62:	40cc87bb          	subw	a5,s9,a2
    80003d66:	413a873b          	subw	a4,s5,s3
    80003d6a:	8d3e                	mv	s10,a5
    80003d6c:	2781                	sext.w	a5,a5
    80003d6e:	0007069b          	sext.w	a3,a4
    80003d72:	f8f6f9e3          	bgeu	a3,a5,80003d04 <readi+0x4c>
    80003d76:	8d3a                	mv	s10,a4
    80003d78:	b771                	j	80003d04 <readi+0x4c>
      brelse(bp);
    80003d7a:	854a                	mv	a0,s2
    80003d7c:	fffff097          	auipc	ra,0xfffff
    80003d80:	59e080e7          	jalr	1438(ra) # 8000331a <brelse>
      tot = -1;
    80003d84:	59fd                	li	s3,-1
  }
  return tot;
    80003d86:	0009851b          	sext.w	a0,s3
}
    80003d8a:	70a6                	ld	ra,104(sp)
    80003d8c:	7406                	ld	s0,96(sp)
    80003d8e:	64e6                	ld	s1,88(sp)
    80003d90:	6946                	ld	s2,80(sp)
    80003d92:	69a6                	ld	s3,72(sp)
    80003d94:	6a06                	ld	s4,64(sp)
    80003d96:	7ae2                	ld	s5,56(sp)
    80003d98:	7b42                	ld	s6,48(sp)
    80003d9a:	7ba2                	ld	s7,40(sp)
    80003d9c:	7c02                	ld	s8,32(sp)
    80003d9e:	6ce2                	ld	s9,24(sp)
    80003da0:	6d42                	ld	s10,16(sp)
    80003da2:	6da2                	ld	s11,8(sp)
    80003da4:	6165                	addi	sp,sp,112
    80003da6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003da8:	89d6                	mv	s3,s5
    80003daa:	bff1                	j	80003d86 <readi+0xce>
    return 0;
    80003dac:	4501                	li	a0,0
}
    80003dae:	8082                	ret

0000000080003db0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003db0:	457c                	lw	a5,76(a0)
    80003db2:	10d7e863          	bltu	a5,a3,80003ec2 <writei+0x112>
{
    80003db6:	7159                	addi	sp,sp,-112
    80003db8:	f486                	sd	ra,104(sp)
    80003dba:	f0a2                	sd	s0,96(sp)
    80003dbc:	eca6                	sd	s1,88(sp)
    80003dbe:	e8ca                	sd	s2,80(sp)
    80003dc0:	e4ce                	sd	s3,72(sp)
    80003dc2:	e0d2                	sd	s4,64(sp)
    80003dc4:	fc56                	sd	s5,56(sp)
    80003dc6:	f85a                	sd	s6,48(sp)
    80003dc8:	f45e                	sd	s7,40(sp)
    80003dca:	f062                	sd	s8,32(sp)
    80003dcc:	ec66                	sd	s9,24(sp)
    80003dce:	e86a                	sd	s10,16(sp)
    80003dd0:	e46e                	sd	s11,8(sp)
    80003dd2:	1880                	addi	s0,sp,112
    80003dd4:	8aaa                	mv	s5,a0
    80003dd6:	8bae                	mv	s7,a1
    80003dd8:	8a32                	mv	s4,a2
    80003dda:	8936                	mv	s2,a3
    80003ddc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003dde:	00e687bb          	addw	a5,a3,a4
    80003de2:	0ed7e263          	bltu	a5,a3,80003ec6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003de6:	00043737          	lui	a4,0x43
    80003dea:	0ef76063          	bltu	a4,a5,80003eca <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dee:	0c0b0863          	beqz	s6,80003ebe <writei+0x10e>
    80003df2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003df4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003df8:	5c7d                	li	s8,-1
    80003dfa:	a091                	j	80003e3e <writei+0x8e>
    80003dfc:	020d1d93          	slli	s11,s10,0x20
    80003e00:	020ddd93          	srli	s11,s11,0x20
    80003e04:	05848793          	addi	a5,s1,88
    80003e08:	86ee                	mv	a3,s11
    80003e0a:	8652                	mv	a2,s4
    80003e0c:	85de                	mv	a1,s7
    80003e0e:	953e                	add	a0,a0,a5
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	82e080e7          	jalr	-2002(ra) # 8000263e <either_copyin>
    80003e18:	07850263          	beq	a0,s8,80003e7c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e1c:	8526                	mv	a0,s1
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	780080e7          	jalr	1920(ra) # 8000459e <log_write>
    brelse(bp);
    80003e26:	8526                	mv	a0,s1
    80003e28:	fffff097          	auipc	ra,0xfffff
    80003e2c:	4f2080e7          	jalr	1266(ra) # 8000331a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e30:	013d09bb          	addw	s3,s10,s3
    80003e34:	012d093b          	addw	s2,s10,s2
    80003e38:	9a6e                	add	s4,s4,s11
    80003e3a:	0569f663          	bgeu	s3,s6,80003e86 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003e3e:	00a9559b          	srliw	a1,s2,0xa
    80003e42:	8556                	mv	a0,s5
    80003e44:	fffff097          	auipc	ra,0xfffff
    80003e48:	7a0080e7          	jalr	1952(ra) # 800035e4 <bmap>
    80003e4c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e50:	c99d                	beqz	a1,80003e86 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e52:	000aa503          	lw	a0,0(s5)
    80003e56:	fffff097          	auipc	ra,0xfffff
    80003e5a:	394080e7          	jalr	916(ra) # 800031ea <bread>
    80003e5e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e60:	3ff97513          	andi	a0,s2,1023
    80003e64:	40ac87bb          	subw	a5,s9,a0
    80003e68:	413b073b          	subw	a4,s6,s3
    80003e6c:	8d3e                	mv	s10,a5
    80003e6e:	2781                	sext.w	a5,a5
    80003e70:	0007069b          	sext.w	a3,a4
    80003e74:	f8f6f4e3          	bgeu	a3,a5,80003dfc <writei+0x4c>
    80003e78:	8d3a                	mv	s10,a4
    80003e7a:	b749                	j	80003dfc <writei+0x4c>
      brelse(bp);
    80003e7c:	8526                	mv	a0,s1
    80003e7e:	fffff097          	auipc	ra,0xfffff
    80003e82:	49c080e7          	jalr	1180(ra) # 8000331a <brelse>
  }

  if(off > ip->size)
    80003e86:	04caa783          	lw	a5,76(s5)
    80003e8a:	0127f463          	bgeu	a5,s2,80003e92 <writei+0xe2>
    ip->size = off;
    80003e8e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e92:	8556                	mv	a0,s5
    80003e94:	00000097          	auipc	ra,0x0
    80003e98:	aa6080e7          	jalr	-1370(ra) # 8000393a <iupdate>

  return tot;
    80003e9c:	0009851b          	sext.w	a0,s3
}
    80003ea0:	70a6                	ld	ra,104(sp)
    80003ea2:	7406                	ld	s0,96(sp)
    80003ea4:	64e6                	ld	s1,88(sp)
    80003ea6:	6946                	ld	s2,80(sp)
    80003ea8:	69a6                	ld	s3,72(sp)
    80003eaa:	6a06                	ld	s4,64(sp)
    80003eac:	7ae2                	ld	s5,56(sp)
    80003eae:	7b42                	ld	s6,48(sp)
    80003eb0:	7ba2                	ld	s7,40(sp)
    80003eb2:	7c02                	ld	s8,32(sp)
    80003eb4:	6ce2                	ld	s9,24(sp)
    80003eb6:	6d42                	ld	s10,16(sp)
    80003eb8:	6da2                	ld	s11,8(sp)
    80003eba:	6165                	addi	sp,sp,112
    80003ebc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ebe:	89da                	mv	s3,s6
    80003ec0:	bfc9                	j	80003e92 <writei+0xe2>
    return -1;
    80003ec2:	557d                	li	a0,-1
}
    80003ec4:	8082                	ret
    return -1;
    80003ec6:	557d                	li	a0,-1
    80003ec8:	bfe1                	j	80003ea0 <writei+0xf0>
    return -1;
    80003eca:	557d                	li	a0,-1
    80003ecc:	bfd1                	j	80003ea0 <writei+0xf0>

0000000080003ece <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ece:	1141                	addi	sp,sp,-16
    80003ed0:	e406                	sd	ra,8(sp)
    80003ed2:	e022                	sd	s0,0(sp)
    80003ed4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ed6:	4639                	li	a2,14
    80003ed8:	ffffd097          	auipc	ra,0xffffd
    80003edc:	eca080e7          	jalr	-310(ra) # 80000da2 <strncmp>
}
    80003ee0:	60a2                	ld	ra,8(sp)
    80003ee2:	6402                	ld	s0,0(sp)
    80003ee4:	0141                	addi	sp,sp,16
    80003ee6:	8082                	ret

0000000080003ee8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ee8:	7139                	addi	sp,sp,-64
    80003eea:	fc06                	sd	ra,56(sp)
    80003eec:	f822                	sd	s0,48(sp)
    80003eee:	f426                	sd	s1,40(sp)
    80003ef0:	f04a                	sd	s2,32(sp)
    80003ef2:	ec4e                	sd	s3,24(sp)
    80003ef4:	e852                	sd	s4,16(sp)
    80003ef6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ef8:	04451703          	lh	a4,68(a0)
    80003efc:	4785                	li	a5,1
    80003efe:	00f71a63          	bne	a4,a5,80003f12 <dirlookup+0x2a>
    80003f02:	892a                	mv	s2,a0
    80003f04:	89ae                	mv	s3,a1
    80003f06:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f08:	457c                	lw	a5,76(a0)
    80003f0a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f0c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f0e:	e79d                	bnez	a5,80003f3c <dirlookup+0x54>
    80003f10:	a8a5                	j	80003f88 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f12:	00004517          	auipc	a0,0x4
    80003f16:	77650513          	addi	a0,a0,1910 # 80008688 <syscalls+0x1a0>
    80003f1a:	ffffc097          	auipc	ra,0xffffc
    80003f1e:	624080e7          	jalr	1572(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003f22:	00004517          	auipc	a0,0x4
    80003f26:	77e50513          	addi	a0,a0,1918 # 800086a0 <syscalls+0x1b8>
    80003f2a:	ffffc097          	auipc	ra,0xffffc
    80003f2e:	614080e7          	jalr	1556(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f32:	24c1                	addiw	s1,s1,16
    80003f34:	04c92783          	lw	a5,76(s2)
    80003f38:	04f4f763          	bgeu	s1,a5,80003f86 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f3c:	4741                	li	a4,16
    80003f3e:	86a6                	mv	a3,s1
    80003f40:	fc040613          	addi	a2,s0,-64
    80003f44:	4581                	li	a1,0
    80003f46:	854a                	mv	a0,s2
    80003f48:	00000097          	auipc	ra,0x0
    80003f4c:	d70080e7          	jalr	-656(ra) # 80003cb8 <readi>
    80003f50:	47c1                	li	a5,16
    80003f52:	fcf518e3          	bne	a0,a5,80003f22 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f56:	fc045783          	lhu	a5,-64(s0)
    80003f5a:	dfe1                	beqz	a5,80003f32 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f5c:	fc240593          	addi	a1,s0,-62
    80003f60:	854e                	mv	a0,s3
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	f6c080e7          	jalr	-148(ra) # 80003ece <namecmp>
    80003f6a:	f561                	bnez	a0,80003f32 <dirlookup+0x4a>
      if(poff)
    80003f6c:	000a0463          	beqz	s4,80003f74 <dirlookup+0x8c>
        *poff = off;
    80003f70:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f74:	fc045583          	lhu	a1,-64(s0)
    80003f78:	00092503          	lw	a0,0(s2)
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	750080e7          	jalr	1872(ra) # 800036cc <iget>
    80003f84:	a011                	j	80003f88 <dirlookup+0xa0>
  return 0;
    80003f86:	4501                	li	a0,0
}
    80003f88:	70e2                	ld	ra,56(sp)
    80003f8a:	7442                	ld	s0,48(sp)
    80003f8c:	74a2                	ld	s1,40(sp)
    80003f8e:	7902                	ld	s2,32(sp)
    80003f90:	69e2                	ld	s3,24(sp)
    80003f92:	6a42                	ld	s4,16(sp)
    80003f94:	6121                	addi	sp,sp,64
    80003f96:	8082                	ret

0000000080003f98 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f98:	711d                	addi	sp,sp,-96
    80003f9a:	ec86                	sd	ra,88(sp)
    80003f9c:	e8a2                	sd	s0,80(sp)
    80003f9e:	e4a6                	sd	s1,72(sp)
    80003fa0:	e0ca                	sd	s2,64(sp)
    80003fa2:	fc4e                	sd	s3,56(sp)
    80003fa4:	f852                	sd	s4,48(sp)
    80003fa6:	f456                	sd	s5,40(sp)
    80003fa8:	f05a                	sd	s6,32(sp)
    80003faa:	ec5e                	sd	s7,24(sp)
    80003fac:	e862                	sd	s8,16(sp)
    80003fae:	e466                	sd	s9,8(sp)
    80003fb0:	1080                	addi	s0,sp,96
    80003fb2:	84aa                	mv	s1,a0
    80003fb4:	8aae                	mv	s5,a1
    80003fb6:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003fb8:	00054703          	lbu	a4,0(a0)
    80003fbc:	02f00793          	li	a5,47
    80003fc0:	02f70363          	beq	a4,a5,80003fe6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003fc4:	ffffe097          	auipc	ra,0xffffe
    80003fc8:	9bc080e7          	jalr	-1604(ra) # 80001980 <myproc>
    80003fcc:	18853503          	ld	a0,392(a0)
    80003fd0:	00000097          	auipc	ra,0x0
    80003fd4:	9f6080e7          	jalr	-1546(ra) # 800039c6 <idup>
    80003fd8:	89aa                	mv	s3,a0
  while(*path == '/')
    80003fda:	02f00913          	li	s2,47
  len = path - s;
    80003fde:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003fe0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fe2:	4b85                	li	s7,1
    80003fe4:	a865                	j	8000409c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fe6:	4585                	li	a1,1
    80003fe8:	4505                	li	a0,1
    80003fea:	fffff097          	auipc	ra,0xfffff
    80003fee:	6e2080e7          	jalr	1762(ra) # 800036cc <iget>
    80003ff2:	89aa                	mv	s3,a0
    80003ff4:	b7dd                	j	80003fda <namex+0x42>
      iunlockput(ip);
    80003ff6:	854e                	mv	a0,s3
    80003ff8:	00000097          	auipc	ra,0x0
    80003ffc:	c6e080e7          	jalr	-914(ra) # 80003c66 <iunlockput>
      return 0;
    80004000:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004002:	854e                	mv	a0,s3
    80004004:	60e6                	ld	ra,88(sp)
    80004006:	6446                	ld	s0,80(sp)
    80004008:	64a6                	ld	s1,72(sp)
    8000400a:	6906                	ld	s2,64(sp)
    8000400c:	79e2                	ld	s3,56(sp)
    8000400e:	7a42                	ld	s4,48(sp)
    80004010:	7aa2                	ld	s5,40(sp)
    80004012:	7b02                	ld	s6,32(sp)
    80004014:	6be2                	ld	s7,24(sp)
    80004016:	6c42                	ld	s8,16(sp)
    80004018:	6ca2                	ld	s9,8(sp)
    8000401a:	6125                	addi	sp,sp,96
    8000401c:	8082                	ret
      iunlock(ip);
    8000401e:	854e                	mv	a0,s3
    80004020:	00000097          	auipc	ra,0x0
    80004024:	aa6080e7          	jalr	-1370(ra) # 80003ac6 <iunlock>
      return ip;
    80004028:	bfe9                	j	80004002 <namex+0x6a>
      iunlockput(ip);
    8000402a:	854e                	mv	a0,s3
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	c3a080e7          	jalr	-966(ra) # 80003c66 <iunlockput>
      return 0;
    80004034:	89e6                	mv	s3,s9
    80004036:	b7f1                	j	80004002 <namex+0x6a>
  len = path - s;
    80004038:	40b48633          	sub	a2,s1,a1
    8000403c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004040:	099c5463          	bge	s8,s9,800040c8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004044:	4639                	li	a2,14
    80004046:	8552                	mv	a0,s4
    80004048:	ffffd097          	auipc	ra,0xffffd
    8000404c:	ce6080e7          	jalr	-794(ra) # 80000d2e <memmove>
  while(*path == '/')
    80004050:	0004c783          	lbu	a5,0(s1)
    80004054:	01279763          	bne	a5,s2,80004062 <namex+0xca>
    path++;
    80004058:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000405a:	0004c783          	lbu	a5,0(s1)
    8000405e:	ff278de3          	beq	a5,s2,80004058 <namex+0xc0>
    ilock(ip);
    80004062:	854e                	mv	a0,s3
    80004064:	00000097          	auipc	ra,0x0
    80004068:	9a0080e7          	jalr	-1632(ra) # 80003a04 <ilock>
    if(ip->type != T_DIR){
    8000406c:	04499783          	lh	a5,68(s3)
    80004070:	f97793e3          	bne	a5,s7,80003ff6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004074:	000a8563          	beqz	s5,8000407e <namex+0xe6>
    80004078:	0004c783          	lbu	a5,0(s1)
    8000407c:	d3cd                	beqz	a5,8000401e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000407e:	865a                	mv	a2,s6
    80004080:	85d2                	mv	a1,s4
    80004082:	854e                	mv	a0,s3
    80004084:	00000097          	auipc	ra,0x0
    80004088:	e64080e7          	jalr	-412(ra) # 80003ee8 <dirlookup>
    8000408c:	8caa                	mv	s9,a0
    8000408e:	dd51                	beqz	a0,8000402a <namex+0x92>
    iunlockput(ip);
    80004090:	854e                	mv	a0,s3
    80004092:	00000097          	auipc	ra,0x0
    80004096:	bd4080e7          	jalr	-1068(ra) # 80003c66 <iunlockput>
    ip = next;
    8000409a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000409c:	0004c783          	lbu	a5,0(s1)
    800040a0:	05279763          	bne	a5,s2,800040ee <namex+0x156>
    path++;
    800040a4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040a6:	0004c783          	lbu	a5,0(s1)
    800040aa:	ff278de3          	beq	a5,s2,800040a4 <namex+0x10c>
  if(*path == 0)
    800040ae:	c79d                	beqz	a5,800040dc <namex+0x144>
    path++;
    800040b0:	85a6                	mv	a1,s1
  len = path - s;
    800040b2:	8cda                	mv	s9,s6
    800040b4:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800040b6:	01278963          	beq	a5,s2,800040c8 <namex+0x130>
    800040ba:	dfbd                	beqz	a5,80004038 <namex+0xa0>
    path++;
    800040bc:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800040be:	0004c783          	lbu	a5,0(s1)
    800040c2:	ff279ce3          	bne	a5,s2,800040ba <namex+0x122>
    800040c6:	bf8d                	j	80004038 <namex+0xa0>
    memmove(name, s, len);
    800040c8:	2601                	sext.w	a2,a2
    800040ca:	8552                	mv	a0,s4
    800040cc:	ffffd097          	auipc	ra,0xffffd
    800040d0:	c62080e7          	jalr	-926(ra) # 80000d2e <memmove>
    name[len] = 0;
    800040d4:	9cd2                	add	s9,s9,s4
    800040d6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800040da:	bf9d                	j	80004050 <namex+0xb8>
  if(nameiparent){
    800040dc:	f20a83e3          	beqz	s5,80004002 <namex+0x6a>
    iput(ip);
    800040e0:	854e                	mv	a0,s3
    800040e2:	00000097          	auipc	ra,0x0
    800040e6:	adc080e7          	jalr	-1316(ra) # 80003bbe <iput>
    return 0;
    800040ea:	4981                	li	s3,0
    800040ec:	bf19                	j	80004002 <namex+0x6a>
  if(*path == 0)
    800040ee:	d7fd                	beqz	a5,800040dc <namex+0x144>
  while(*path != '/' && *path != 0)
    800040f0:	0004c783          	lbu	a5,0(s1)
    800040f4:	85a6                	mv	a1,s1
    800040f6:	b7d1                	j	800040ba <namex+0x122>

00000000800040f8 <dirlink>:
{
    800040f8:	7139                	addi	sp,sp,-64
    800040fa:	fc06                	sd	ra,56(sp)
    800040fc:	f822                	sd	s0,48(sp)
    800040fe:	f426                	sd	s1,40(sp)
    80004100:	f04a                	sd	s2,32(sp)
    80004102:	ec4e                	sd	s3,24(sp)
    80004104:	e852                	sd	s4,16(sp)
    80004106:	0080                	addi	s0,sp,64
    80004108:	892a                	mv	s2,a0
    8000410a:	8a2e                	mv	s4,a1
    8000410c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000410e:	4601                	li	a2,0
    80004110:	00000097          	auipc	ra,0x0
    80004114:	dd8080e7          	jalr	-552(ra) # 80003ee8 <dirlookup>
    80004118:	e93d                	bnez	a0,8000418e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000411a:	04c92483          	lw	s1,76(s2)
    8000411e:	c49d                	beqz	s1,8000414c <dirlink+0x54>
    80004120:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004122:	4741                	li	a4,16
    80004124:	86a6                	mv	a3,s1
    80004126:	fc040613          	addi	a2,s0,-64
    8000412a:	4581                	li	a1,0
    8000412c:	854a                	mv	a0,s2
    8000412e:	00000097          	auipc	ra,0x0
    80004132:	b8a080e7          	jalr	-1142(ra) # 80003cb8 <readi>
    80004136:	47c1                	li	a5,16
    80004138:	06f51163          	bne	a0,a5,8000419a <dirlink+0xa2>
    if(de.inum == 0)
    8000413c:	fc045783          	lhu	a5,-64(s0)
    80004140:	c791                	beqz	a5,8000414c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004142:	24c1                	addiw	s1,s1,16
    80004144:	04c92783          	lw	a5,76(s2)
    80004148:	fcf4ede3          	bltu	s1,a5,80004122 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000414c:	4639                	li	a2,14
    8000414e:	85d2                	mv	a1,s4
    80004150:	fc240513          	addi	a0,s0,-62
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	c8a080e7          	jalr	-886(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000415c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004160:	4741                	li	a4,16
    80004162:	86a6                	mv	a3,s1
    80004164:	fc040613          	addi	a2,s0,-64
    80004168:	4581                	li	a1,0
    8000416a:	854a                	mv	a0,s2
    8000416c:	00000097          	auipc	ra,0x0
    80004170:	c44080e7          	jalr	-956(ra) # 80003db0 <writei>
    80004174:	1541                	addi	a0,a0,-16
    80004176:	00a03533          	snez	a0,a0
    8000417a:	40a00533          	neg	a0,a0
}
    8000417e:	70e2                	ld	ra,56(sp)
    80004180:	7442                	ld	s0,48(sp)
    80004182:	74a2                	ld	s1,40(sp)
    80004184:	7902                	ld	s2,32(sp)
    80004186:	69e2                	ld	s3,24(sp)
    80004188:	6a42                	ld	s4,16(sp)
    8000418a:	6121                	addi	sp,sp,64
    8000418c:	8082                	ret
    iput(ip);
    8000418e:	00000097          	auipc	ra,0x0
    80004192:	a30080e7          	jalr	-1488(ra) # 80003bbe <iput>
    return -1;
    80004196:	557d                	li	a0,-1
    80004198:	b7dd                	j	8000417e <dirlink+0x86>
      panic("dirlink read");
    8000419a:	00004517          	auipc	a0,0x4
    8000419e:	51650513          	addi	a0,a0,1302 # 800086b0 <syscalls+0x1c8>
    800041a2:	ffffc097          	auipc	ra,0xffffc
    800041a6:	39c080e7          	jalr	924(ra) # 8000053e <panic>

00000000800041aa <namei>:

struct inode*
namei(char *path)
{
    800041aa:	1101                	addi	sp,sp,-32
    800041ac:	ec06                	sd	ra,24(sp)
    800041ae:	e822                	sd	s0,16(sp)
    800041b0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041b2:	fe040613          	addi	a2,s0,-32
    800041b6:	4581                	li	a1,0
    800041b8:	00000097          	auipc	ra,0x0
    800041bc:	de0080e7          	jalr	-544(ra) # 80003f98 <namex>
}
    800041c0:	60e2                	ld	ra,24(sp)
    800041c2:	6442                	ld	s0,16(sp)
    800041c4:	6105                	addi	sp,sp,32
    800041c6:	8082                	ret

00000000800041c8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041c8:	1141                	addi	sp,sp,-16
    800041ca:	e406                	sd	ra,8(sp)
    800041cc:	e022                	sd	s0,0(sp)
    800041ce:	0800                	addi	s0,sp,16
    800041d0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041d2:	4585                	li	a1,1
    800041d4:	00000097          	auipc	ra,0x0
    800041d8:	dc4080e7          	jalr	-572(ra) # 80003f98 <namex>
}
    800041dc:	60a2                	ld	ra,8(sp)
    800041de:	6402                	ld	s0,0(sp)
    800041e0:	0141                	addi	sp,sp,16
    800041e2:	8082                	ret

00000000800041e4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041e4:	1101                	addi	sp,sp,-32
    800041e6:	ec06                	sd	ra,24(sp)
    800041e8:	e822                	sd	s0,16(sp)
    800041ea:	e426                	sd	s1,8(sp)
    800041ec:	e04a                	sd	s2,0(sp)
    800041ee:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041f0:	0001e917          	auipc	s2,0x1e
    800041f4:	fd090913          	addi	s2,s2,-48 # 800221c0 <log>
    800041f8:	01892583          	lw	a1,24(s2)
    800041fc:	02892503          	lw	a0,40(s2)
    80004200:	fffff097          	auipc	ra,0xfffff
    80004204:	fea080e7          	jalr	-22(ra) # 800031ea <bread>
    80004208:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000420a:	02c92683          	lw	a3,44(s2)
    8000420e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004210:	02d05763          	blez	a3,8000423e <write_head+0x5a>
    80004214:	0001e797          	auipc	a5,0x1e
    80004218:	fdc78793          	addi	a5,a5,-36 # 800221f0 <log+0x30>
    8000421c:	05c50713          	addi	a4,a0,92
    80004220:	36fd                	addiw	a3,a3,-1
    80004222:	1682                	slli	a3,a3,0x20
    80004224:	9281                	srli	a3,a3,0x20
    80004226:	068a                	slli	a3,a3,0x2
    80004228:	0001e617          	auipc	a2,0x1e
    8000422c:	fcc60613          	addi	a2,a2,-52 # 800221f4 <log+0x34>
    80004230:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004232:	4390                	lw	a2,0(a5)
    80004234:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004236:	0791                	addi	a5,a5,4
    80004238:	0711                	addi	a4,a4,4
    8000423a:	fed79ce3          	bne	a5,a3,80004232 <write_head+0x4e>
  }
  bwrite(buf);
    8000423e:	8526                	mv	a0,s1
    80004240:	fffff097          	auipc	ra,0xfffff
    80004244:	09c080e7          	jalr	156(ra) # 800032dc <bwrite>
  brelse(buf);
    80004248:	8526                	mv	a0,s1
    8000424a:	fffff097          	auipc	ra,0xfffff
    8000424e:	0d0080e7          	jalr	208(ra) # 8000331a <brelse>
}
    80004252:	60e2                	ld	ra,24(sp)
    80004254:	6442                	ld	s0,16(sp)
    80004256:	64a2                	ld	s1,8(sp)
    80004258:	6902                	ld	s2,0(sp)
    8000425a:	6105                	addi	sp,sp,32
    8000425c:	8082                	ret

000000008000425e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425e:	0001e797          	auipc	a5,0x1e
    80004262:	f8e7a783          	lw	a5,-114(a5) # 800221ec <log+0x2c>
    80004266:	0af05d63          	blez	a5,80004320 <install_trans+0xc2>
{
    8000426a:	7139                	addi	sp,sp,-64
    8000426c:	fc06                	sd	ra,56(sp)
    8000426e:	f822                	sd	s0,48(sp)
    80004270:	f426                	sd	s1,40(sp)
    80004272:	f04a                	sd	s2,32(sp)
    80004274:	ec4e                	sd	s3,24(sp)
    80004276:	e852                	sd	s4,16(sp)
    80004278:	e456                	sd	s5,8(sp)
    8000427a:	e05a                	sd	s6,0(sp)
    8000427c:	0080                	addi	s0,sp,64
    8000427e:	8b2a                	mv	s6,a0
    80004280:	0001ea97          	auipc	s5,0x1e
    80004284:	f70a8a93          	addi	s5,s5,-144 # 800221f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004288:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000428a:	0001e997          	auipc	s3,0x1e
    8000428e:	f3698993          	addi	s3,s3,-202 # 800221c0 <log>
    80004292:	a00d                	j	800042b4 <install_trans+0x56>
    brelse(lbuf);
    80004294:	854a                	mv	a0,s2
    80004296:	fffff097          	auipc	ra,0xfffff
    8000429a:	084080e7          	jalr	132(ra) # 8000331a <brelse>
    brelse(dbuf);
    8000429e:	8526                	mv	a0,s1
    800042a0:	fffff097          	auipc	ra,0xfffff
    800042a4:	07a080e7          	jalr	122(ra) # 8000331a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042a8:	2a05                	addiw	s4,s4,1
    800042aa:	0a91                	addi	s5,s5,4
    800042ac:	02c9a783          	lw	a5,44(s3)
    800042b0:	04fa5e63          	bge	s4,a5,8000430c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042b4:	0189a583          	lw	a1,24(s3)
    800042b8:	014585bb          	addw	a1,a1,s4
    800042bc:	2585                	addiw	a1,a1,1
    800042be:	0289a503          	lw	a0,40(s3)
    800042c2:	fffff097          	auipc	ra,0xfffff
    800042c6:	f28080e7          	jalr	-216(ra) # 800031ea <bread>
    800042ca:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042cc:	000aa583          	lw	a1,0(s5)
    800042d0:	0289a503          	lw	a0,40(s3)
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	f16080e7          	jalr	-234(ra) # 800031ea <bread>
    800042dc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042de:	40000613          	li	a2,1024
    800042e2:	05890593          	addi	a1,s2,88
    800042e6:	05850513          	addi	a0,a0,88
    800042ea:	ffffd097          	auipc	ra,0xffffd
    800042ee:	a44080e7          	jalr	-1468(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800042f2:	8526                	mv	a0,s1
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	fe8080e7          	jalr	-24(ra) # 800032dc <bwrite>
    if(recovering == 0)
    800042fc:	f80b1ce3          	bnez	s6,80004294 <install_trans+0x36>
      bunpin(dbuf);
    80004300:	8526                	mv	a0,s1
    80004302:	fffff097          	auipc	ra,0xfffff
    80004306:	0f2080e7          	jalr	242(ra) # 800033f4 <bunpin>
    8000430a:	b769                	j	80004294 <install_trans+0x36>
}
    8000430c:	70e2                	ld	ra,56(sp)
    8000430e:	7442                	ld	s0,48(sp)
    80004310:	74a2                	ld	s1,40(sp)
    80004312:	7902                	ld	s2,32(sp)
    80004314:	69e2                	ld	s3,24(sp)
    80004316:	6a42                	ld	s4,16(sp)
    80004318:	6aa2                	ld	s5,8(sp)
    8000431a:	6b02                	ld	s6,0(sp)
    8000431c:	6121                	addi	sp,sp,64
    8000431e:	8082                	ret
    80004320:	8082                	ret

0000000080004322 <initlog>:
{
    80004322:	7179                	addi	sp,sp,-48
    80004324:	f406                	sd	ra,40(sp)
    80004326:	f022                	sd	s0,32(sp)
    80004328:	ec26                	sd	s1,24(sp)
    8000432a:	e84a                	sd	s2,16(sp)
    8000432c:	e44e                	sd	s3,8(sp)
    8000432e:	1800                	addi	s0,sp,48
    80004330:	892a                	mv	s2,a0
    80004332:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004334:	0001e497          	auipc	s1,0x1e
    80004338:	e8c48493          	addi	s1,s1,-372 # 800221c0 <log>
    8000433c:	00004597          	auipc	a1,0x4
    80004340:	38458593          	addi	a1,a1,900 # 800086c0 <syscalls+0x1d8>
    80004344:	8526                	mv	a0,s1
    80004346:	ffffd097          	auipc	ra,0xffffd
    8000434a:	800080e7          	jalr	-2048(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000434e:	0149a583          	lw	a1,20(s3)
    80004352:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004354:	0109a783          	lw	a5,16(s3)
    80004358:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000435a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000435e:	854a                	mv	a0,s2
    80004360:	fffff097          	auipc	ra,0xfffff
    80004364:	e8a080e7          	jalr	-374(ra) # 800031ea <bread>
  log.lh.n = lh->n;
    80004368:	4d34                	lw	a3,88(a0)
    8000436a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000436c:	02d05563          	blez	a3,80004396 <initlog+0x74>
    80004370:	05c50793          	addi	a5,a0,92
    80004374:	0001e717          	auipc	a4,0x1e
    80004378:	e7c70713          	addi	a4,a4,-388 # 800221f0 <log+0x30>
    8000437c:	36fd                	addiw	a3,a3,-1
    8000437e:	1682                	slli	a3,a3,0x20
    80004380:	9281                	srli	a3,a3,0x20
    80004382:	068a                	slli	a3,a3,0x2
    80004384:	06050613          	addi	a2,a0,96
    80004388:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000438a:	4390                	lw	a2,0(a5)
    8000438c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000438e:	0791                	addi	a5,a5,4
    80004390:	0711                	addi	a4,a4,4
    80004392:	fed79ce3          	bne	a5,a3,8000438a <initlog+0x68>
  brelse(buf);
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	f84080e7          	jalr	-124(ra) # 8000331a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000439e:	4505                	li	a0,1
    800043a0:	00000097          	auipc	ra,0x0
    800043a4:	ebe080e7          	jalr	-322(ra) # 8000425e <install_trans>
  log.lh.n = 0;
    800043a8:	0001e797          	auipc	a5,0x1e
    800043ac:	e407a223          	sw	zero,-444(a5) # 800221ec <log+0x2c>
  write_head(); // clear the log
    800043b0:	00000097          	auipc	ra,0x0
    800043b4:	e34080e7          	jalr	-460(ra) # 800041e4 <write_head>
}
    800043b8:	70a2                	ld	ra,40(sp)
    800043ba:	7402                	ld	s0,32(sp)
    800043bc:	64e2                	ld	s1,24(sp)
    800043be:	6942                	ld	s2,16(sp)
    800043c0:	69a2                	ld	s3,8(sp)
    800043c2:	6145                	addi	sp,sp,48
    800043c4:	8082                	ret

00000000800043c6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043c6:	1101                	addi	sp,sp,-32
    800043c8:	ec06                	sd	ra,24(sp)
    800043ca:	e822                	sd	s0,16(sp)
    800043cc:	e426                	sd	s1,8(sp)
    800043ce:	e04a                	sd	s2,0(sp)
    800043d0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043d2:	0001e517          	auipc	a0,0x1e
    800043d6:	dee50513          	addi	a0,a0,-530 # 800221c0 <log>
    800043da:	ffffc097          	auipc	ra,0xffffc
    800043de:	7fc080e7          	jalr	2044(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800043e2:	0001e497          	auipc	s1,0x1e
    800043e6:	dde48493          	addi	s1,s1,-546 # 800221c0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043ea:	4979                	li	s2,30
    800043ec:	a039                	j	800043fa <begin_op+0x34>
      sleep(&log, &log.lock);
    800043ee:	85a6                	mv	a1,s1
    800043f0:	8526                	mv	a0,s1
    800043f2:	ffffe097          	auipc	ra,0xffffe
    800043f6:	d48080e7          	jalr	-696(ra) # 8000213a <sleep>
    if(log.committing){
    800043fa:	50dc                	lw	a5,36(s1)
    800043fc:	fbed                	bnez	a5,800043ee <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043fe:	509c                	lw	a5,32(s1)
    80004400:	0017871b          	addiw	a4,a5,1
    80004404:	0007069b          	sext.w	a3,a4
    80004408:	0027179b          	slliw	a5,a4,0x2
    8000440c:	9fb9                	addw	a5,a5,a4
    8000440e:	0017979b          	slliw	a5,a5,0x1
    80004412:	54d8                	lw	a4,44(s1)
    80004414:	9fb9                	addw	a5,a5,a4
    80004416:	00f95963          	bge	s2,a5,80004428 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000441a:	85a6                	mv	a1,s1
    8000441c:	8526                	mv	a0,s1
    8000441e:	ffffe097          	auipc	ra,0xffffe
    80004422:	d1c080e7          	jalr	-740(ra) # 8000213a <sleep>
    80004426:	bfd1                	j	800043fa <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004428:	0001e517          	auipc	a0,0x1e
    8000442c:	d9850513          	addi	a0,a0,-616 # 800221c0 <log>
    80004430:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004432:	ffffd097          	auipc	ra,0xffffd
    80004436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000443a:	60e2                	ld	ra,24(sp)
    8000443c:	6442                	ld	s0,16(sp)
    8000443e:	64a2                	ld	s1,8(sp)
    80004440:	6902                	ld	s2,0(sp)
    80004442:	6105                	addi	sp,sp,32
    80004444:	8082                	ret

0000000080004446 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004446:	7139                	addi	sp,sp,-64
    80004448:	fc06                	sd	ra,56(sp)
    8000444a:	f822                	sd	s0,48(sp)
    8000444c:	f426                	sd	s1,40(sp)
    8000444e:	f04a                	sd	s2,32(sp)
    80004450:	ec4e                	sd	s3,24(sp)
    80004452:	e852                	sd	s4,16(sp)
    80004454:	e456                	sd	s5,8(sp)
    80004456:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004458:	0001e497          	auipc	s1,0x1e
    8000445c:	d6848493          	addi	s1,s1,-664 # 800221c0 <log>
    80004460:	8526                	mv	a0,s1
    80004462:	ffffc097          	auipc	ra,0xffffc
    80004466:	774080e7          	jalr	1908(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000446a:	509c                	lw	a5,32(s1)
    8000446c:	37fd                	addiw	a5,a5,-1
    8000446e:	0007891b          	sext.w	s2,a5
    80004472:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004474:	50dc                	lw	a5,36(s1)
    80004476:	e7b9                	bnez	a5,800044c4 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004478:	04091e63          	bnez	s2,800044d4 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000447c:	0001e497          	auipc	s1,0x1e
    80004480:	d4448493          	addi	s1,s1,-700 # 800221c0 <log>
    80004484:	4785                	li	a5,1
    80004486:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004488:	8526                	mv	a0,s1
    8000448a:	ffffd097          	auipc	ra,0xffffd
    8000448e:	800080e7          	jalr	-2048(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004492:	54dc                	lw	a5,44(s1)
    80004494:	06f04763          	bgtz	a5,80004502 <end_op+0xbc>
    acquire(&log.lock);
    80004498:	0001e497          	auipc	s1,0x1e
    8000449c:	d2848493          	addi	s1,s1,-728 # 800221c0 <log>
    800044a0:	8526                	mv	a0,s1
    800044a2:	ffffc097          	auipc	ra,0xffffc
    800044a6:	734080e7          	jalr	1844(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800044aa:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800044ae:	8526                	mv	a0,s1
    800044b0:	ffffe097          	auipc	ra,0xffffe
    800044b4:	d0a080e7          	jalr	-758(ra) # 800021ba <wakeup>
    release(&log.lock);
    800044b8:	8526                	mv	a0,s1
    800044ba:	ffffc097          	auipc	ra,0xffffc
    800044be:	7d0080e7          	jalr	2000(ra) # 80000c8a <release>
}
    800044c2:	a03d                	j	800044f0 <end_op+0xaa>
    panic("log.committing");
    800044c4:	00004517          	auipc	a0,0x4
    800044c8:	20450513          	addi	a0,a0,516 # 800086c8 <syscalls+0x1e0>
    800044cc:	ffffc097          	auipc	ra,0xffffc
    800044d0:	072080e7          	jalr	114(ra) # 8000053e <panic>
    wakeup(&log);
    800044d4:	0001e497          	auipc	s1,0x1e
    800044d8:	cec48493          	addi	s1,s1,-788 # 800221c0 <log>
    800044dc:	8526                	mv	a0,s1
    800044de:	ffffe097          	auipc	ra,0xffffe
    800044e2:	cdc080e7          	jalr	-804(ra) # 800021ba <wakeup>
  release(&log.lock);
    800044e6:	8526                	mv	a0,s1
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	7a2080e7          	jalr	1954(ra) # 80000c8a <release>
}
    800044f0:	70e2                	ld	ra,56(sp)
    800044f2:	7442                	ld	s0,48(sp)
    800044f4:	74a2                	ld	s1,40(sp)
    800044f6:	7902                	ld	s2,32(sp)
    800044f8:	69e2                	ld	s3,24(sp)
    800044fa:	6a42                	ld	s4,16(sp)
    800044fc:	6aa2                	ld	s5,8(sp)
    800044fe:	6121                	addi	sp,sp,64
    80004500:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004502:	0001ea97          	auipc	s5,0x1e
    80004506:	ceea8a93          	addi	s5,s5,-786 # 800221f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000450a:	0001ea17          	auipc	s4,0x1e
    8000450e:	cb6a0a13          	addi	s4,s4,-842 # 800221c0 <log>
    80004512:	018a2583          	lw	a1,24(s4)
    80004516:	012585bb          	addw	a1,a1,s2
    8000451a:	2585                	addiw	a1,a1,1
    8000451c:	028a2503          	lw	a0,40(s4)
    80004520:	fffff097          	auipc	ra,0xfffff
    80004524:	cca080e7          	jalr	-822(ra) # 800031ea <bread>
    80004528:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000452a:	000aa583          	lw	a1,0(s5)
    8000452e:	028a2503          	lw	a0,40(s4)
    80004532:	fffff097          	auipc	ra,0xfffff
    80004536:	cb8080e7          	jalr	-840(ra) # 800031ea <bread>
    8000453a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000453c:	40000613          	li	a2,1024
    80004540:	05850593          	addi	a1,a0,88
    80004544:	05848513          	addi	a0,s1,88
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	7e6080e7          	jalr	2022(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004550:	8526                	mv	a0,s1
    80004552:	fffff097          	auipc	ra,0xfffff
    80004556:	d8a080e7          	jalr	-630(ra) # 800032dc <bwrite>
    brelse(from);
    8000455a:	854e                	mv	a0,s3
    8000455c:	fffff097          	auipc	ra,0xfffff
    80004560:	dbe080e7          	jalr	-578(ra) # 8000331a <brelse>
    brelse(to);
    80004564:	8526                	mv	a0,s1
    80004566:	fffff097          	auipc	ra,0xfffff
    8000456a:	db4080e7          	jalr	-588(ra) # 8000331a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000456e:	2905                	addiw	s2,s2,1
    80004570:	0a91                	addi	s5,s5,4
    80004572:	02ca2783          	lw	a5,44(s4)
    80004576:	f8f94ee3          	blt	s2,a5,80004512 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000457a:	00000097          	auipc	ra,0x0
    8000457e:	c6a080e7          	jalr	-918(ra) # 800041e4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004582:	4501                	li	a0,0
    80004584:	00000097          	auipc	ra,0x0
    80004588:	cda080e7          	jalr	-806(ra) # 8000425e <install_trans>
    log.lh.n = 0;
    8000458c:	0001e797          	auipc	a5,0x1e
    80004590:	c607a023          	sw	zero,-928(a5) # 800221ec <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004594:	00000097          	auipc	ra,0x0
    80004598:	c50080e7          	jalr	-944(ra) # 800041e4 <write_head>
    8000459c:	bdf5                	j	80004498 <end_op+0x52>

000000008000459e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000459e:	1101                	addi	sp,sp,-32
    800045a0:	ec06                	sd	ra,24(sp)
    800045a2:	e822                	sd	s0,16(sp)
    800045a4:	e426                	sd	s1,8(sp)
    800045a6:	e04a                	sd	s2,0(sp)
    800045a8:	1000                	addi	s0,sp,32
    800045aa:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800045ac:	0001e917          	auipc	s2,0x1e
    800045b0:	c1490913          	addi	s2,s2,-1004 # 800221c0 <log>
    800045b4:	854a                	mv	a0,s2
    800045b6:	ffffc097          	auipc	ra,0xffffc
    800045ba:	620080e7          	jalr	1568(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045be:	02c92603          	lw	a2,44(s2)
    800045c2:	47f5                	li	a5,29
    800045c4:	06c7c563          	blt	a5,a2,8000462e <log_write+0x90>
    800045c8:	0001e797          	auipc	a5,0x1e
    800045cc:	c147a783          	lw	a5,-1004(a5) # 800221dc <log+0x1c>
    800045d0:	37fd                	addiw	a5,a5,-1
    800045d2:	04f65e63          	bge	a2,a5,8000462e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045d6:	0001e797          	auipc	a5,0x1e
    800045da:	c0a7a783          	lw	a5,-1014(a5) # 800221e0 <log+0x20>
    800045de:	06f05063          	blez	a5,8000463e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045e2:	4781                	li	a5,0
    800045e4:	06c05563          	blez	a2,8000464e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045e8:	44cc                	lw	a1,12(s1)
    800045ea:	0001e717          	auipc	a4,0x1e
    800045ee:	c0670713          	addi	a4,a4,-1018 # 800221f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800045f2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045f4:	4314                	lw	a3,0(a4)
    800045f6:	04b68c63          	beq	a3,a1,8000464e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800045fa:	2785                	addiw	a5,a5,1
    800045fc:	0711                	addi	a4,a4,4
    800045fe:	fef61be3          	bne	a2,a5,800045f4 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004602:	0621                	addi	a2,a2,8
    80004604:	060a                	slli	a2,a2,0x2
    80004606:	0001e797          	auipc	a5,0x1e
    8000460a:	bba78793          	addi	a5,a5,-1094 # 800221c0 <log>
    8000460e:	963e                	add	a2,a2,a5
    80004610:	44dc                	lw	a5,12(s1)
    80004612:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004614:	8526                	mv	a0,s1
    80004616:	fffff097          	auipc	ra,0xfffff
    8000461a:	da2080e7          	jalr	-606(ra) # 800033b8 <bpin>
    log.lh.n++;
    8000461e:	0001e717          	auipc	a4,0x1e
    80004622:	ba270713          	addi	a4,a4,-1118 # 800221c0 <log>
    80004626:	575c                	lw	a5,44(a4)
    80004628:	2785                	addiw	a5,a5,1
    8000462a:	d75c                	sw	a5,44(a4)
    8000462c:	a835                	j	80004668 <log_write+0xca>
    panic("too big a transaction");
    8000462e:	00004517          	auipc	a0,0x4
    80004632:	0aa50513          	addi	a0,a0,170 # 800086d8 <syscalls+0x1f0>
    80004636:	ffffc097          	auipc	ra,0xffffc
    8000463a:	f08080e7          	jalr	-248(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000463e:	00004517          	auipc	a0,0x4
    80004642:	0b250513          	addi	a0,a0,178 # 800086f0 <syscalls+0x208>
    80004646:	ffffc097          	auipc	ra,0xffffc
    8000464a:	ef8080e7          	jalr	-264(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000464e:	00878713          	addi	a4,a5,8
    80004652:	00271693          	slli	a3,a4,0x2
    80004656:	0001e717          	auipc	a4,0x1e
    8000465a:	b6a70713          	addi	a4,a4,-1174 # 800221c0 <log>
    8000465e:	9736                	add	a4,a4,a3
    80004660:	44d4                	lw	a3,12(s1)
    80004662:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004664:	faf608e3          	beq	a2,a5,80004614 <log_write+0x76>
  }
  release(&log.lock);
    80004668:	0001e517          	auipc	a0,0x1e
    8000466c:	b5850513          	addi	a0,a0,-1192 # 800221c0 <log>
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	61a080e7          	jalr	1562(ra) # 80000c8a <release>
}
    80004678:	60e2                	ld	ra,24(sp)
    8000467a:	6442                	ld	s0,16(sp)
    8000467c:	64a2                	ld	s1,8(sp)
    8000467e:	6902                	ld	s2,0(sp)
    80004680:	6105                	addi	sp,sp,32
    80004682:	8082                	ret

0000000080004684 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004684:	1101                	addi	sp,sp,-32
    80004686:	ec06                	sd	ra,24(sp)
    80004688:	e822                	sd	s0,16(sp)
    8000468a:	e426                	sd	s1,8(sp)
    8000468c:	e04a                	sd	s2,0(sp)
    8000468e:	1000                	addi	s0,sp,32
    80004690:	84aa                	mv	s1,a0
    80004692:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004694:	00004597          	auipc	a1,0x4
    80004698:	07c58593          	addi	a1,a1,124 # 80008710 <syscalls+0x228>
    8000469c:	0521                	addi	a0,a0,8
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	4a8080e7          	jalr	1192(ra) # 80000b46 <initlock>
  lk->name = name;
    800046a6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800046aa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046ae:	0204a423          	sw	zero,40(s1)
}
    800046b2:	60e2                	ld	ra,24(sp)
    800046b4:	6442                	ld	s0,16(sp)
    800046b6:	64a2                	ld	s1,8(sp)
    800046b8:	6902                	ld	s2,0(sp)
    800046ba:	6105                	addi	sp,sp,32
    800046bc:	8082                	ret

00000000800046be <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046be:	1101                	addi	sp,sp,-32
    800046c0:	ec06                	sd	ra,24(sp)
    800046c2:	e822                	sd	s0,16(sp)
    800046c4:	e426                	sd	s1,8(sp)
    800046c6:	e04a                	sd	s2,0(sp)
    800046c8:	1000                	addi	s0,sp,32
    800046ca:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046cc:	00850913          	addi	s2,a0,8
    800046d0:	854a                	mv	a0,s2
    800046d2:	ffffc097          	auipc	ra,0xffffc
    800046d6:	504080e7          	jalr	1284(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800046da:	409c                	lw	a5,0(s1)
    800046dc:	cb89                	beqz	a5,800046ee <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046de:	85ca                	mv	a1,s2
    800046e0:	8526                	mv	a0,s1
    800046e2:	ffffe097          	auipc	ra,0xffffe
    800046e6:	a58080e7          	jalr	-1448(ra) # 8000213a <sleep>
  while (lk->locked) {
    800046ea:	409c                	lw	a5,0(s1)
    800046ec:	fbed                	bnez	a5,800046de <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046ee:	4785                	li	a5,1
    800046f0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046f2:	ffffd097          	auipc	ra,0xffffd
    800046f6:	28e080e7          	jalr	654(ra) # 80001980 <myproc>
    800046fa:	515c                	lw	a5,36(a0)
    800046fc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046fe:	854a                	mv	a0,s2
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	58a080e7          	jalr	1418(ra) # 80000c8a <release>
}
    80004708:	60e2                	ld	ra,24(sp)
    8000470a:	6442                	ld	s0,16(sp)
    8000470c:	64a2                	ld	s1,8(sp)
    8000470e:	6902                	ld	s2,0(sp)
    80004710:	6105                	addi	sp,sp,32
    80004712:	8082                	ret

0000000080004714 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004714:	1101                	addi	sp,sp,-32
    80004716:	ec06                	sd	ra,24(sp)
    80004718:	e822                	sd	s0,16(sp)
    8000471a:	e426                	sd	s1,8(sp)
    8000471c:	e04a                	sd	s2,0(sp)
    8000471e:	1000                	addi	s0,sp,32
    80004720:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004722:	00850913          	addi	s2,a0,8
    80004726:	854a                	mv	a0,s2
    80004728:	ffffc097          	auipc	ra,0xffffc
    8000472c:	4ae080e7          	jalr	1198(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004730:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004734:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004738:	8526                	mv	a0,s1
    8000473a:	ffffe097          	auipc	ra,0xffffe
    8000473e:	a80080e7          	jalr	-1408(ra) # 800021ba <wakeup>
  release(&lk->lk);
    80004742:	854a                	mv	a0,s2
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	546080e7          	jalr	1350(ra) # 80000c8a <release>
}
    8000474c:	60e2                	ld	ra,24(sp)
    8000474e:	6442                	ld	s0,16(sp)
    80004750:	64a2                	ld	s1,8(sp)
    80004752:	6902                	ld	s2,0(sp)
    80004754:	6105                	addi	sp,sp,32
    80004756:	8082                	ret

0000000080004758 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004758:	7179                	addi	sp,sp,-48
    8000475a:	f406                	sd	ra,40(sp)
    8000475c:	f022                	sd	s0,32(sp)
    8000475e:	ec26                	sd	s1,24(sp)
    80004760:	e84a                	sd	s2,16(sp)
    80004762:	e44e                	sd	s3,8(sp)
    80004764:	1800                	addi	s0,sp,48
    80004766:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004768:	00850913          	addi	s2,a0,8
    8000476c:	854a                	mv	a0,s2
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	468080e7          	jalr	1128(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004776:	409c                	lw	a5,0(s1)
    80004778:	ef99                	bnez	a5,80004796 <holdingsleep+0x3e>
    8000477a:	4481                	li	s1,0
  release(&lk->lk);
    8000477c:	854a                	mv	a0,s2
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	50c080e7          	jalr	1292(ra) # 80000c8a <release>
  return r;
}
    80004786:	8526                	mv	a0,s1
    80004788:	70a2                	ld	ra,40(sp)
    8000478a:	7402                	ld	s0,32(sp)
    8000478c:	64e2                	ld	s1,24(sp)
    8000478e:	6942                	ld	s2,16(sp)
    80004790:	69a2                	ld	s3,8(sp)
    80004792:	6145                	addi	sp,sp,48
    80004794:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004796:	0284a983          	lw	s3,40(s1)
    8000479a:	ffffd097          	auipc	ra,0xffffd
    8000479e:	1e6080e7          	jalr	486(ra) # 80001980 <myproc>
    800047a2:	5144                	lw	s1,36(a0)
    800047a4:	413484b3          	sub	s1,s1,s3
    800047a8:	0014b493          	seqz	s1,s1
    800047ac:	bfc1                	j	8000477c <holdingsleep+0x24>

00000000800047ae <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800047ae:	1141                	addi	sp,sp,-16
    800047b0:	e406                	sd	ra,8(sp)
    800047b2:	e022                	sd	s0,0(sp)
    800047b4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047b6:	00004597          	auipc	a1,0x4
    800047ba:	f6a58593          	addi	a1,a1,-150 # 80008720 <syscalls+0x238>
    800047be:	0001e517          	auipc	a0,0x1e
    800047c2:	b4a50513          	addi	a0,a0,-1206 # 80022308 <ftable>
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	380080e7          	jalr	896(ra) # 80000b46 <initlock>
}
    800047ce:	60a2                	ld	ra,8(sp)
    800047d0:	6402                	ld	s0,0(sp)
    800047d2:	0141                	addi	sp,sp,16
    800047d4:	8082                	ret

00000000800047d6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047d6:	1101                	addi	sp,sp,-32
    800047d8:	ec06                	sd	ra,24(sp)
    800047da:	e822                	sd	s0,16(sp)
    800047dc:	e426                	sd	s1,8(sp)
    800047de:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047e0:	0001e517          	auipc	a0,0x1e
    800047e4:	b2850513          	addi	a0,a0,-1240 # 80022308 <ftable>
    800047e8:	ffffc097          	auipc	ra,0xffffc
    800047ec:	3ee080e7          	jalr	1006(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047f0:	0001e497          	auipc	s1,0x1e
    800047f4:	b3048493          	addi	s1,s1,-1232 # 80022320 <ftable+0x18>
    800047f8:	0001f717          	auipc	a4,0x1f
    800047fc:	ac870713          	addi	a4,a4,-1336 # 800232c0 <disk>
    if(f->ref == 0){
    80004800:	40dc                	lw	a5,4(s1)
    80004802:	cf99                	beqz	a5,80004820 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004804:	02848493          	addi	s1,s1,40
    80004808:	fee49ce3          	bne	s1,a4,80004800 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000480c:	0001e517          	auipc	a0,0x1e
    80004810:	afc50513          	addi	a0,a0,-1284 # 80022308 <ftable>
    80004814:	ffffc097          	auipc	ra,0xffffc
    80004818:	476080e7          	jalr	1142(ra) # 80000c8a <release>
  return 0;
    8000481c:	4481                	li	s1,0
    8000481e:	a819                	j	80004834 <filealloc+0x5e>
      f->ref = 1;
    80004820:	4785                	li	a5,1
    80004822:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004824:	0001e517          	auipc	a0,0x1e
    80004828:	ae450513          	addi	a0,a0,-1308 # 80022308 <ftable>
    8000482c:	ffffc097          	auipc	ra,0xffffc
    80004830:	45e080e7          	jalr	1118(ra) # 80000c8a <release>
}
    80004834:	8526                	mv	a0,s1
    80004836:	60e2                	ld	ra,24(sp)
    80004838:	6442                	ld	s0,16(sp)
    8000483a:	64a2                	ld	s1,8(sp)
    8000483c:	6105                	addi	sp,sp,32
    8000483e:	8082                	ret

0000000080004840 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004840:	1101                	addi	sp,sp,-32
    80004842:	ec06                	sd	ra,24(sp)
    80004844:	e822                	sd	s0,16(sp)
    80004846:	e426                	sd	s1,8(sp)
    80004848:	1000                	addi	s0,sp,32
    8000484a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000484c:	0001e517          	auipc	a0,0x1e
    80004850:	abc50513          	addi	a0,a0,-1348 # 80022308 <ftable>
    80004854:	ffffc097          	auipc	ra,0xffffc
    80004858:	382080e7          	jalr	898(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000485c:	40dc                	lw	a5,4(s1)
    8000485e:	02f05263          	blez	a5,80004882 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004862:	2785                	addiw	a5,a5,1
    80004864:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004866:	0001e517          	auipc	a0,0x1e
    8000486a:	aa250513          	addi	a0,a0,-1374 # 80022308 <ftable>
    8000486e:	ffffc097          	auipc	ra,0xffffc
    80004872:	41c080e7          	jalr	1052(ra) # 80000c8a <release>
  return f;
}
    80004876:	8526                	mv	a0,s1
    80004878:	60e2                	ld	ra,24(sp)
    8000487a:	6442                	ld	s0,16(sp)
    8000487c:	64a2                	ld	s1,8(sp)
    8000487e:	6105                	addi	sp,sp,32
    80004880:	8082                	ret
    panic("filedup");
    80004882:	00004517          	auipc	a0,0x4
    80004886:	ea650513          	addi	a0,a0,-346 # 80008728 <syscalls+0x240>
    8000488a:	ffffc097          	auipc	ra,0xffffc
    8000488e:	cb4080e7          	jalr	-844(ra) # 8000053e <panic>

0000000080004892 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004892:	7139                	addi	sp,sp,-64
    80004894:	fc06                	sd	ra,56(sp)
    80004896:	f822                	sd	s0,48(sp)
    80004898:	f426                	sd	s1,40(sp)
    8000489a:	f04a                	sd	s2,32(sp)
    8000489c:	ec4e                	sd	s3,24(sp)
    8000489e:	e852                	sd	s4,16(sp)
    800048a0:	e456                	sd	s5,8(sp)
    800048a2:	0080                	addi	s0,sp,64
    800048a4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800048a6:	0001e517          	auipc	a0,0x1e
    800048aa:	a6250513          	addi	a0,a0,-1438 # 80022308 <ftable>
    800048ae:	ffffc097          	auipc	ra,0xffffc
    800048b2:	328080e7          	jalr	808(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800048b6:	40dc                	lw	a5,4(s1)
    800048b8:	06f05163          	blez	a5,8000491a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800048bc:	37fd                	addiw	a5,a5,-1
    800048be:	0007871b          	sext.w	a4,a5
    800048c2:	c0dc                	sw	a5,4(s1)
    800048c4:	06e04363          	bgtz	a4,8000492a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048c8:	0004a903          	lw	s2,0(s1)
    800048cc:	0094ca83          	lbu	s5,9(s1)
    800048d0:	0104ba03          	ld	s4,16(s1)
    800048d4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048d8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048dc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048e0:	0001e517          	auipc	a0,0x1e
    800048e4:	a2850513          	addi	a0,a0,-1496 # 80022308 <ftable>
    800048e8:	ffffc097          	auipc	ra,0xffffc
    800048ec:	3a2080e7          	jalr	930(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800048f0:	4785                	li	a5,1
    800048f2:	04f90d63          	beq	s2,a5,8000494c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048f6:	3979                	addiw	s2,s2,-2
    800048f8:	4785                	li	a5,1
    800048fa:	0527e063          	bltu	a5,s2,8000493a <fileclose+0xa8>
    begin_op();
    800048fe:	00000097          	auipc	ra,0x0
    80004902:	ac8080e7          	jalr	-1336(ra) # 800043c6 <begin_op>
    iput(ff.ip);
    80004906:	854e                	mv	a0,s3
    80004908:	fffff097          	auipc	ra,0xfffff
    8000490c:	2b6080e7          	jalr	694(ra) # 80003bbe <iput>
    end_op();
    80004910:	00000097          	auipc	ra,0x0
    80004914:	b36080e7          	jalr	-1226(ra) # 80004446 <end_op>
    80004918:	a00d                	j	8000493a <fileclose+0xa8>
    panic("fileclose");
    8000491a:	00004517          	auipc	a0,0x4
    8000491e:	e1650513          	addi	a0,a0,-490 # 80008730 <syscalls+0x248>
    80004922:	ffffc097          	auipc	ra,0xffffc
    80004926:	c1c080e7          	jalr	-996(ra) # 8000053e <panic>
    release(&ftable.lock);
    8000492a:	0001e517          	auipc	a0,0x1e
    8000492e:	9de50513          	addi	a0,a0,-1570 # 80022308 <ftable>
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	358080e7          	jalr	856(ra) # 80000c8a <release>
  }
}
    8000493a:	70e2                	ld	ra,56(sp)
    8000493c:	7442                	ld	s0,48(sp)
    8000493e:	74a2                	ld	s1,40(sp)
    80004940:	7902                	ld	s2,32(sp)
    80004942:	69e2                	ld	s3,24(sp)
    80004944:	6a42                	ld	s4,16(sp)
    80004946:	6aa2                	ld	s5,8(sp)
    80004948:	6121                	addi	sp,sp,64
    8000494a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000494c:	85d6                	mv	a1,s5
    8000494e:	8552                	mv	a0,s4
    80004950:	00000097          	auipc	ra,0x0
    80004954:	34c080e7          	jalr	844(ra) # 80004c9c <pipeclose>
    80004958:	b7cd                	j	8000493a <fileclose+0xa8>

000000008000495a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000495a:	715d                	addi	sp,sp,-80
    8000495c:	e486                	sd	ra,72(sp)
    8000495e:	e0a2                	sd	s0,64(sp)
    80004960:	fc26                	sd	s1,56(sp)
    80004962:	f84a                	sd	s2,48(sp)
    80004964:	f44e                	sd	s3,40(sp)
    80004966:	0880                	addi	s0,sp,80
    80004968:	84aa                	mv	s1,a0
    8000496a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000496c:	ffffd097          	auipc	ra,0xffffd
    80004970:	014080e7          	jalr	20(ra) # 80001980 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004974:	409c                	lw	a5,0(s1)
    80004976:	37f9                	addiw	a5,a5,-2
    80004978:	4705                	li	a4,1
    8000497a:	04f76763          	bltu	a4,a5,800049c8 <filestat+0x6e>
    8000497e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004980:	6c88                	ld	a0,24(s1)
    80004982:	fffff097          	auipc	ra,0xfffff
    80004986:	082080e7          	jalr	130(ra) # 80003a04 <ilock>
    stati(f->ip, &st);
    8000498a:	fb840593          	addi	a1,s0,-72
    8000498e:	6c88                	ld	a0,24(s1)
    80004990:	fffff097          	auipc	ra,0xfffff
    80004994:	2fe080e7          	jalr	766(ra) # 80003c8e <stati>
    iunlock(f->ip);
    80004998:	6c88                	ld	a0,24(s1)
    8000499a:	fffff097          	auipc	ra,0xfffff
    8000499e:	12c080e7          	jalr	300(ra) # 80003ac6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800049a2:	46e1                	li	a3,24
    800049a4:	fb840613          	addi	a2,s0,-72
    800049a8:	85ce                	mv	a1,s3
    800049aa:	10093503          	ld	a0,256(s2)
    800049ae:	ffffd097          	auipc	ra,0xffffd
    800049b2:	cba080e7          	jalr	-838(ra) # 80001668 <copyout>
    800049b6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800049ba:	60a6                	ld	ra,72(sp)
    800049bc:	6406                	ld	s0,64(sp)
    800049be:	74e2                	ld	s1,56(sp)
    800049c0:	7942                	ld	s2,48(sp)
    800049c2:	79a2                	ld	s3,40(sp)
    800049c4:	6161                	addi	sp,sp,80
    800049c6:	8082                	ret
  return -1;
    800049c8:	557d                	li	a0,-1
    800049ca:	bfc5                	j	800049ba <filestat+0x60>

00000000800049cc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800049cc:	7179                	addi	sp,sp,-48
    800049ce:	f406                	sd	ra,40(sp)
    800049d0:	f022                	sd	s0,32(sp)
    800049d2:	ec26                	sd	s1,24(sp)
    800049d4:	e84a                	sd	s2,16(sp)
    800049d6:	e44e                	sd	s3,8(sp)
    800049d8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049da:	00854783          	lbu	a5,8(a0)
    800049de:	c3d5                	beqz	a5,80004a82 <fileread+0xb6>
    800049e0:	84aa                	mv	s1,a0
    800049e2:	89ae                	mv	s3,a1
    800049e4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800049e6:	411c                	lw	a5,0(a0)
    800049e8:	4705                	li	a4,1
    800049ea:	04e78963          	beq	a5,a4,80004a3c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049ee:	470d                	li	a4,3
    800049f0:	04e78d63          	beq	a5,a4,80004a4a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800049f4:	4709                	li	a4,2
    800049f6:	06e79e63          	bne	a5,a4,80004a72 <fileread+0xa6>
    ilock(f->ip);
    800049fa:	6d08                	ld	a0,24(a0)
    800049fc:	fffff097          	auipc	ra,0xfffff
    80004a00:	008080e7          	jalr	8(ra) # 80003a04 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a04:	874a                	mv	a4,s2
    80004a06:	5094                	lw	a3,32(s1)
    80004a08:	864e                	mv	a2,s3
    80004a0a:	4585                	li	a1,1
    80004a0c:	6c88                	ld	a0,24(s1)
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	2aa080e7          	jalr	682(ra) # 80003cb8 <readi>
    80004a16:	892a                	mv	s2,a0
    80004a18:	00a05563          	blez	a0,80004a22 <fileread+0x56>
      f->off += r;
    80004a1c:	509c                	lw	a5,32(s1)
    80004a1e:	9fa9                	addw	a5,a5,a0
    80004a20:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a22:	6c88                	ld	a0,24(s1)
    80004a24:	fffff097          	auipc	ra,0xfffff
    80004a28:	0a2080e7          	jalr	162(ra) # 80003ac6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a2c:	854a                	mv	a0,s2
    80004a2e:	70a2                	ld	ra,40(sp)
    80004a30:	7402                	ld	s0,32(sp)
    80004a32:	64e2                	ld	s1,24(sp)
    80004a34:	6942                	ld	s2,16(sp)
    80004a36:	69a2                	ld	s3,8(sp)
    80004a38:	6145                	addi	sp,sp,48
    80004a3a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a3c:	6908                	ld	a0,16(a0)
    80004a3e:	00000097          	auipc	ra,0x0
    80004a42:	3c6080e7          	jalr	966(ra) # 80004e04 <piperead>
    80004a46:	892a                	mv	s2,a0
    80004a48:	b7d5                	j	80004a2c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a4a:	02451783          	lh	a5,36(a0)
    80004a4e:	03079693          	slli	a3,a5,0x30
    80004a52:	92c1                	srli	a3,a3,0x30
    80004a54:	4725                	li	a4,9
    80004a56:	02d76863          	bltu	a4,a3,80004a86 <fileread+0xba>
    80004a5a:	0792                	slli	a5,a5,0x4
    80004a5c:	0001e717          	auipc	a4,0x1e
    80004a60:	80c70713          	addi	a4,a4,-2036 # 80022268 <devsw>
    80004a64:	97ba                	add	a5,a5,a4
    80004a66:	639c                	ld	a5,0(a5)
    80004a68:	c38d                	beqz	a5,80004a8a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a6a:	4505                	li	a0,1
    80004a6c:	9782                	jalr	a5
    80004a6e:	892a                	mv	s2,a0
    80004a70:	bf75                	j	80004a2c <fileread+0x60>
    panic("fileread");
    80004a72:	00004517          	auipc	a0,0x4
    80004a76:	cce50513          	addi	a0,a0,-818 # 80008740 <syscalls+0x258>
    80004a7a:	ffffc097          	auipc	ra,0xffffc
    80004a7e:	ac4080e7          	jalr	-1340(ra) # 8000053e <panic>
    return -1;
    80004a82:	597d                	li	s2,-1
    80004a84:	b765                	j	80004a2c <fileread+0x60>
      return -1;
    80004a86:	597d                	li	s2,-1
    80004a88:	b755                	j	80004a2c <fileread+0x60>
    80004a8a:	597d                	li	s2,-1
    80004a8c:	b745                	j	80004a2c <fileread+0x60>

0000000080004a8e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a8e:	715d                	addi	sp,sp,-80
    80004a90:	e486                	sd	ra,72(sp)
    80004a92:	e0a2                	sd	s0,64(sp)
    80004a94:	fc26                	sd	s1,56(sp)
    80004a96:	f84a                	sd	s2,48(sp)
    80004a98:	f44e                	sd	s3,40(sp)
    80004a9a:	f052                	sd	s4,32(sp)
    80004a9c:	ec56                	sd	s5,24(sp)
    80004a9e:	e85a                	sd	s6,16(sp)
    80004aa0:	e45e                	sd	s7,8(sp)
    80004aa2:	e062                	sd	s8,0(sp)
    80004aa4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004aa6:	00954783          	lbu	a5,9(a0)
    80004aaa:	10078663          	beqz	a5,80004bb6 <filewrite+0x128>
    80004aae:	892a                	mv	s2,a0
    80004ab0:	8aae                	mv	s5,a1
    80004ab2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ab4:	411c                	lw	a5,0(a0)
    80004ab6:	4705                	li	a4,1
    80004ab8:	02e78263          	beq	a5,a4,80004adc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004abc:	470d                	li	a4,3
    80004abe:	02e78663          	beq	a5,a4,80004aea <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ac2:	4709                	li	a4,2
    80004ac4:	0ee79163          	bne	a5,a4,80004ba6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004ac8:	0ac05d63          	blez	a2,80004b82 <filewrite+0xf4>
    int i = 0;
    80004acc:	4981                	li	s3,0
    80004ace:	6b05                	lui	s6,0x1
    80004ad0:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004ad4:	6b85                	lui	s7,0x1
    80004ad6:	c00b8b9b          	addiw	s7,s7,-1024
    80004ada:	a861                	j	80004b72 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004adc:	6908                	ld	a0,16(a0)
    80004ade:	00000097          	auipc	ra,0x0
    80004ae2:	22e080e7          	jalr	558(ra) # 80004d0c <pipewrite>
    80004ae6:	8a2a                	mv	s4,a0
    80004ae8:	a045                	j	80004b88 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004aea:	02451783          	lh	a5,36(a0)
    80004aee:	03079693          	slli	a3,a5,0x30
    80004af2:	92c1                	srli	a3,a3,0x30
    80004af4:	4725                	li	a4,9
    80004af6:	0cd76263          	bltu	a4,a3,80004bba <filewrite+0x12c>
    80004afa:	0792                	slli	a5,a5,0x4
    80004afc:	0001d717          	auipc	a4,0x1d
    80004b00:	76c70713          	addi	a4,a4,1900 # 80022268 <devsw>
    80004b04:	97ba                	add	a5,a5,a4
    80004b06:	679c                	ld	a5,8(a5)
    80004b08:	cbdd                	beqz	a5,80004bbe <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004b0a:	4505                	li	a0,1
    80004b0c:	9782                	jalr	a5
    80004b0e:	8a2a                	mv	s4,a0
    80004b10:	a8a5                	j	80004b88 <filewrite+0xfa>
    80004b12:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004b16:	00000097          	auipc	ra,0x0
    80004b1a:	8b0080e7          	jalr	-1872(ra) # 800043c6 <begin_op>
      ilock(f->ip);
    80004b1e:	01893503          	ld	a0,24(s2)
    80004b22:	fffff097          	auipc	ra,0xfffff
    80004b26:	ee2080e7          	jalr	-286(ra) # 80003a04 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b2a:	8762                	mv	a4,s8
    80004b2c:	02092683          	lw	a3,32(s2)
    80004b30:	01598633          	add	a2,s3,s5
    80004b34:	4585                	li	a1,1
    80004b36:	01893503          	ld	a0,24(s2)
    80004b3a:	fffff097          	auipc	ra,0xfffff
    80004b3e:	276080e7          	jalr	630(ra) # 80003db0 <writei>
    80004b42:	84aa                	mv	s1,a0
    80004b44:	00a05763          	blez	a0,80004b52 <filewrite+0xc4>
        f->off += r;
    80004b48:	02092783          	lw	a5,32(s2)
    80004b4c:	9fa9                	addw	a5,a5,a0
    80004b4e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b52:	01893503          	ld	a0,24(s2)
    80004b56:	fffff097          	auipc	ra,0xfffff
    80004b5a:	f70080e7          	jalr	-144(ra) # 80003ac6 <iunlock>
      end_op();
    80004b5e:	00000097          	auipc	ra,0x0
    80004b62:	8e8080e7          	jalr	-1816(ra) # 80004446 <end_op>

      if(r != n1){
    80004b66:	009c1f63          	bne	s8,s1,80004b84 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004b6a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b6e:	0149db63          	bge	s3,s4,80004b84 <filewrite+0xf6>
      int n1 = n - i;
    80004b72:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b76:	84be                	mv	s1,a5
    80004b78:	2781                	sext.w	a5,a5
    80004b7a:	f8fb5ce3          	bge	s6,a5,80004b12 <filewrite+0x84>
    80004b7e:	84de                	mv	s1,s7
    80004b80:	bf49                	j	80004b12 <filewrite+0x84>
    int i = 0;
    80004b82:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b84:	013a1f63          	bne	s4,s3,80004ba2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b88:	8552                	mv	a0,s4
    80004b8a:	60a6                	ld	ra,72(sp)
    80004b8c:	6406                	ld	s0,64(sp)
    80004b8e:	74e2                	ld	s1,56(sp)
    80004b90:	7942                	ld	s2,48(sp)
    80004b92:	79a2                	ld	s3,40(sp)
    80004b94:	7a02                	ld	s4,32(sp)
    80004b96:	6ae2                	ld	s5,24(sp)
    80004b98:	6b42                	ld	s6,16(sp)
    80004b9a:	6ba2                	ld	s7,8(sp)
    80004b9c:	6c02                	ld	s8,0(sp)
    80004b9e:	6161                	addi	sp,sp,80
    80004ba0:	8082                	ret
    ret = (i == n ? n : -1);
    80004ba2:	5a7d                	li	s4,-1
    80004ba4:	b7d5                	j	80004b88 <filewrite+0xfa>
    panic("filewrite");
    80004ba6:	00004517          	auipc	a0,0x4
    80004baa:	baa50513          	addi	a0,a0,-1110 # 80008750 <syscalls+0x268>
    80004bae:	ffffc097          	auipc	ra,0xffffc
    80004bb2:	990080e7          	jalr	-1648(ra) # 8000053e <panic>
    return -1;
    80004bb6:	5a7d                	li	s4,-1
    80004bb8:	bfc1                	j	80004b88 <filewrite+0xfa>
      return -1;
    80004bba:	5a7d                	li	s4,-1
    80004bbc:	b7f1                	j	80004b88 <filewrite+0xfa>
    80004bbe:	5a7d                	li	s4,-1
    80004bc0:	b7e1                	j	80004b88 <filewrite+0xfa>

0000000080004bc2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004bc2:	7179                	addi	sp,sp,-48
    80004bc4:	f406                	sd	ra,40(sp)
    80004bc6:	f022                	sd	s0,32(sp)
    80004bc8:	ec26                	sd	s1,24(sp)
    80004bca:	e84a                	sd	s2,16(sp)
    80004bcc:	e44e                	sd	s3,8(sp)
    80004bce:	e052                	sd	s4,0(sp)
    80004bd0:	1800                	addi	s0,sp,48
    80004bd2:	84aa                	mv	s1,a0
    80004bd4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004bd6:	0005b023          	sd	zero,0(a1)
    80004bda:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004bde:	00000097          	auipc	ra,0x0
    80004be2:	bf8080e7          	jalr	-1032(ra) # 800047d6 <filealloc>
    80004be6:	e088                	sd	a0,0(s1)
    80004be8:	c551                	beqz	a0,80004c74 <pipealloc+0xb2>
    80004bea:	00000097          	auipc	ra,0x0
    80004bee:	bec080e7          	jalr	-1044(ra) # 800047d6 <filealloc>
    80004bf2:	00aa3023          	sd	a0,0(s4)
    80004bf6:	c92d                	beqz	a0,80004c68 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	eee080e7          	jalr	-274(ra) # 80000ae6 <kalloc>
    80004c00:	892a                	mv	s2,a0
    80004c02:	c125                	beqz	a0,80004c62 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c04:	4985                	li	s3,1
    80004c06:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c0a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c0e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c12:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c16:	00004597          	auipc	a1,0x4
    80004c1a:	b4a58593          	addi	a1,a1,-1206 # 80008760 <syscalls+0x278>
    80004c1e:	ffffc097          	auipc	ra,0xffffc
    80004c22:	f28080e7          	jalr	-216(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004c26:	609c                	ld	a5,0(s1)
    80004c28:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c2c:	609c                	ld	a5,0(s1)
    80004c2e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c32:	609c                	ld	a5,0(s1)
    80004c34:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c38:	609c                	ld	a5,0(s1)
    80004c3a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c3e:	000a3783          	ld	a5,0(s4)
    80004c42:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c46:	000a3783          	ld	a5,0(s4)
    80004c4a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c4e:	000a3783          	ld	a5,0(s4)
    80004c52:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c56:	000a3783          	ld	a5,0(s4)
    80004c5a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c5e:	4501                	li	a0,0
    80004c60:	a025                	j	80004c88 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c62:	6088                	ld	a0,0(s1)
    80004c64:	e501                	bnez	a0,80004c6c <pipealloc+0xaa>
    80004c66:	a039                	j	80004c74 <pipealloc+0xb2>
    80004c68:	6088                	ld	a0,0(s1)
    80004c6a:	c51d                	beqz	a0,80004c98 <pipealloc+0xd6>
    fileclose(*f0);
    80004c6c:	00000097          	auipc	ra,0x0
    80004c70:	c26080e7          	jalr	-986(ra) # 80004892 <fileclose>
  if(*f1)
    80004c74:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c78:	557d                	li	a0,-1
  if(*f1)
    80004c7a:	c799                	beqz	a5,80004c88 <pipealloc+0xc6>
    fileclose(*f1);
    80004c7c:	853e                	mv	a0,a5
    80004c7e:	00000097          	auipc	ra,0x0
    80004c82:	c14080e7          	jalr	-1004(ra) # 80004892 <fileclose>
  return -1;
    80004c86:	557d                	li	a0,-1
}
    80004c88:	70a2                	ld	ra,40(sp)
    80004c8a:	7402                	ld	s0,32(sp)
    80004c8c:	64e2                	ld	s1,24(sp)
    80004c8e:	6942                	ld	s2,16(sp)
    80004c90:	69a2                	ld	s3,8(sp)
    80004c92:	6a02                	ld	s4,0(sp)
    80004c94:	6145                	addi	sp,sp,48
    80004c96:	8082                	ret
  return -1;
    80004c98:	557d                	li	a0,-1
    80004c9a:	b7fd                	j	80004c88 <pipealloc+0xc6>

0000000080004c9c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c9c:	1101                	addi	sp,sp,-32
    80004c9e:	ec06                	sd	ra,24(sp)
    80004ca0:	e822                	sd	s0,16(sp)
    80004ca2:	e426                	sd	s1,8(sp)
    80004ca4:	e04a                	sd	s2,0(sp)
    80004ca6:	1000                	addi	s0,sp,32
    80004ca8:	84aa                	mv	s1,a0
    80004caa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	f2a080e7          	jalr	-214(ra) # 80000bd6 <acquire>
  if(writable){
    80004cb4:	02090d63          	beqz	s2,80004cee <pipeclose+0x52>
    pi->writeopen = 0;
    80004cb8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004cbc:	21848513          	addi	a0,s1,536
    80004cc0:	ffffd097          	auipc	ra,0xffffd
    80004cc4:	4fa080e7          	jalr	1274(ra) # 800021ba <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004cc8:	2204b783          	ld	a5,544(s1)
    80004ccc:	eb95                	bnez	a5,80004d00 <pipeclose+0x64>
    release(&pi->lock);
    80004cce:	8526                	mv	a0,s1
    80004cd0:	ffffc097          	auipc	ra,0xffffc
    80004cd4:	fba080e7          	jalr	-70(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004cd8:	8526                	mv	a0,s1
    80004cda:	ffffc097          	auipc	ra,0xffffc
    80004cde:	d10080e7          	jalr	-752(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004ce2:	60e2                	ld	ra,24(sp)
    80004ce4:	6442                	ld	s0,16(sp)
    80004ce6:	64a2                	ld	s1,8(sp)
    80004ce8:	6902                	ld	s2,0(sp)
    80004cea:	6105                	addi	sp,sp,32
    80004cec:	8082                	ret
    pi->readopen = 0;
    80004cee:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004cf2:	21c48513          	addi	a0,s1,540
    80004cf6:	ffffd097          	auipc	ra,0xffffd
    80004cfa:	4c4080e7          	jalr	1220(ra) # 800021ba <wakeup>
    80004cfe:	b7e9                	j	80004cc8 <pipeclose+0x2c>
    release(&pi->lock);
    80004d00:	8526                	mv	a0,s1
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	f88080e7          	jalr	-120(ra) # 80000c8a <release>
}
    80004d0a:	bfe1                	j	80004ce2 <pipeclose+0x46>

0000000080004d0c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d0c:	711d                	addi	sp,sp,-96
    80004d0e:	ec86                	sd	ra,88(sp)
    80004d10:	e8a2                	sd	s0,80(sp)
    80004d12:	e4a6                	sd	s1,72(sp)
    80004d14:	e0ca                	sd	s2,64(sp)
    80004d16:	fc4e                	sd	s3,56(sp)
    80004d18:	f852                	sd	s4,48(sp)
    80004d1a:	f456                	sd	s5,40(sp)
    80004d1c:	f05a                	sd	s6,32(sp)
    80004d1e:	ec5e                	sd	s7,24(sp)
    80004d20:	e862                	sd	s8,16(sp)
    80004d22:	1080                	addi	s0,sp,96
    80004d24:	84aa                	mv	s1,a0
    80004d26:	8aae                	mv	s5,a1
    80004d28:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d2a:	ffffd097          	auipc	ra,0xffffd
    80004d2e:	c56080e7          	jalr	-938(ra) # 80001980 <myproc>
    80004d32:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d34:	8526                	mv	a0,s1
    80004d36:	ffffc097          	auipc	ra,0xffffc
    80004d3a:	ea0080e7          	jalr	-352(ra) # 80000bd6 <acquire>
  while(i < n){
    80004d3e:	0b405663          	blez	s4,80004dea <pipewrite+0xde>
  int i = 0;
    80004d42:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d44:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d46:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d4a:	21c48b93          	addi	s7,s1,540
    80004d4e:	a089                	j	80004d90 <pipewrite+0x84>
      release(&pi->lock);
    80004d50:	8526                	mv	a0,s1
    80004d52:	ffffc097          	auipc	ra,0xffffc
    80004d56:	f38080e7          	jalr	-200(ra) # 80000c8a <release>
      return -1;
    80004d5a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d5c:	854a                	mv	a0,s2
    80004d5e:	60e6                	ld	ra,88(sp)
    80004d60:	6446                	ld	s0,80(sp)
    80004d62:	64a6                	ld	s1,72(sp)
    80004d64:	6906                	ld	s2,64(sp)
    80004d66:	79e2                	ld	s3,56(sp)
    80004d68:	7a42                	ld	s4,48(sp)
    80004d6a:	7aa2                	ld	s5,40(sp)
    80004d6c:	7b02                	ld	s6,32(sp)
    80004d6e:	6be2                	ld	s7,24(sp)
    80004d70:	6c42                	ld	s8,16(sp)
    80004d72:	6125                	addi	sp,sp,96
    80004d74:	8082                	ret
      wakeup(&pi->nread);
    80004d76:	8562                	mv	a0,s8
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	442080e7          	jalr	1090(ra) # 800021ba <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d80:	85a6                	mv	a1,s1
    80004d82:	855e                	mv	a0,s7
    80004d84:	ffffd097          	auipc	ra,0xffffd
    80004d88:	3b6080e7          	jalr	950(ra) # 8000213a <sleep>
  while(i < n){
    80004d8c:	07495063          	bge	s2,s4,80004dec <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d90:	2204a783          	lw	a5,544(s1)
    80004d94:	dfd5                	beqz	a5,80004d50 <pipewrite+0x44>
    80004d96:	854e                	mv	a0,s3
    80004d98:	ffffd097          	auipc	ra,0xffffd
    80004d9c:	6ee080e7          	jalr	1774(ra) # 80002486 <killed>
    80004da0:	f945                	bnez	a0,80004d50 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004da2:	2184a783          	lw	a5,536(s1)
    80004da6:	21c4a703          	lw	a4,540(s1)
    80004daa:	2007879b          	addiw	a5,a5,512
    80004dae:	fcf704e3          	beq	a4,a5,80004d76 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004db2:	4685                	li	a3,1
    80004db4:	01590633          	add	a2,s2,s5
    80004db8:	faf40593          	addi	a1,s0,-81
    80004dbc:	1009b503          	ld	a0,256(s3)
    80004dc0:	ffffd097          	auipc	ra,0xffffd
    80004dc4:	934080e7          	jalr	-1740(ra) # 800016f4 <copyin>
    80004dc8:	03650263          	beq	a0,s6,80004dec <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004dcc:	21c4a783          	lw	a5,540(s1)
    80004dd0:	0017871b          	addiw	a4,a5,1
    80004dd4:	20e4ae23          	sw	a4,540(s1)
    80004dd8:	1ff7f793          	andi	a5,a5,511
    80004ddc:	97a6                	add	a5,a5,s1
    80004dde:	faf44703          	lbu	a4,-81(s0)
    80004de2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004de6:	2905                	addiw	s2,s2,1
    80004de8:	b755                	j	80004d8c <pipewrite+0x80>
  int i = 0;
    80004dea:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004dec:	21848513          	addi	a0,s1,536
    80004df0:	ffffd097          	auipc	ra,0xffffd
    80004df4:	3ca080e7          	jalr	970(ra) # 800021ba <wakeup>
  release(&pi->lock);
    80004df8:	8526                	mv	a0,s1
    80004dfa:	ffffc097          	auipc	ra,0xffffc
    80004dfe:	e90080e7          	jalr	-368(ra) # 80000c8a <release>
  return i;
    80004e02:	bfa9                	j	80004d5c <pipewrite+0x50>

0000000080004e04 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e04:	715d                	addi	sp,sp,-80
    80004e06:	e486                	sd	ra,72(sp)
    80004e08:	e0a2                	sd	s0,64(sp)
    80004e0a:	fc26                	sd	s1,56(sp)
    80004e0c:	f84a                	sd	s2,48(sp)
    80004e0e:	f44e                	sd	s3,40(sp)
    80004e10:	f052                	sd	s4,32(sp)
    80004e12:	ec56                	sd	s5,24(sp)
    80004e14:	e85a                	sd	s6,16(sp)
    80004e16:	0880                	addi	s0,sp,80
    80004e18:	84aa                	mv	s1,a0
    80004e1a:	892e                	mv	s2,a1
    80004e1c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e1e:	ffffd097          	auipc	ra,0xffffd
    80004e22:	b62080e7          	jalr	-1182(ra) # 80001980 <myproc>
    80004e26:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e28:	8526                	mv	a0,s1
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	dac080e7          	jalr	-596(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e32:	2184a703          	lw	a4,536(s1)
    80004e36:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e3a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e3e:	02f71763          	bne	a4,a5,80004e6c <piperead+0x68>
    80004e42:	2244a783          	lw	a5,548(s1)
    80004e46:	c39d                	beqz	a5,80004e6c <piperead+0x68>
    if(killed(pr)){
    80004e48:	8552                	mv	a0,s4
    80004e4a:	ffffd097          	auipc	ra,0xffffd
    80004e4e:	63c080e7          	jalr	1596(ra) # 80002486 <killed>
    80004e52:	e941                	bnez	a0,80004ee2 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e54:	85a6                	mv	a1,s1
    80004e56:	854e                	mv	a0,s3
    80004e58:	ffffd097          	auipc	ra,0xffffd
    80004e5c:	2e2080e7          	jalr	738(ra) # 8000213a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e60:	2184a703          	lw	a4,536(s1)
    80004e64:	21c4a783          	lw	a5,540(s1)
    80004e68:	fcf70de3          	beq	a4,a5,80004e42 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e6c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e6e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e70:	05505363          	blez	s5,80004eb6 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004e74:	2184a783          	lw	a5,536(s1)
    80004e78:	21c4a703          	lw	a4,540(s1)
    80004e7c:	02f70d63          	beq	a4,a5,80004eb6 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e80:	0017871b          	addiw	a4,a5,1
    80004e84:	20e4ac23          	sw	a4,536(s1)
    80004e88:	1ff7f793          	andi	a5,a5,511
    80004e8c:	97a6                	add	a5,a5,s1
    80004e8e:	0187c783          	lbu	a5,24(a5)
    80004e92:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e96:	4685                	li	a3,1
    80004e98:	fbf40613          	addi	a2,s0,-65
    80004e9c:	85ca                	mv	a1,s2
    80004e9e:	100a3503          	ld	a0,256(s4)
    80004ea2:	ffffc097          	auipc	ra,0xffffc
    80004ea6:	7c6080e7          	jalr	1990(ra) # 80001668 <copyout>
    80004eaa:	01650663          	beq	a0,s6,80004eb6 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004eae:	2985                	addiw	s3,s3,1
    80004eb0:	0905                	addi	s2,s2,1
    80004eb2:	fd3a91e3          	bne	s5,s3,80004e74 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004eb6:	21c48513          	addi	a0,s1,540
    80004eba:	ffffd097          	auipc	ra,0xffffd
    80004ebe:	300080e7          	jalr	768(ra) # 800021ba <wakeup>
  release(&pi->lock);
    80004ec2:	8526                	mv	a0,s1
    80004ec4:	ffffc097          	auipc	ra,0xffffc
    80004ec8:	dc6080e7          	jalr	-570(ra) # 80000c8a <release>
  return i;
}
    80004ecc:	854e                	mv	a0,s3
    80004ece:	60a6                	ld	ra,72(sp)
    80004ed0:	6406                	ld	s0,64(sp)
    80004ed2:	74e2                	ld	s1,56(sp)
    80004ed4:	7942                	ld	s2,48(sp)
    80004ed6:	79a2                	ld	s3,40(sp)
    80004ed8:	7a02                	ld	s4,32(sp)
    80004eda:	6ae2                	ld	s5,24(sp)
    80004edc:	6b42                	ld	s6,16(sp)
    80004ede:	6161                	addi	sp,sp,80
    80004ee0:	8082                	ret
      release(&pi->lock);
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	ffffc097          	auipc	ra,0xffffc
    80004ee8:	da6080e7          	jalr	-602(ra) # 80000c8a <release>
      return -1;
    80004eec:	59fd                	li	s3,-1
    80004eee:	bff9                	j	80004ecc <piperead+0xc8>

0000000080004ef0 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004ef0:	1141                	addi	sp,sp,-16
    80004ef2:	e422                	sd	s0,8(sp)
    80004ef4:	0800                	addi	s0,sp,16
    80004ef6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004ef8:	8905                	andi	a0,a0,1
    80004efa:	c111                	beqz	a0,80004efe <flags2perm+0xe>
      perm = PTE_X;
    80004efc:	4521                	li	a0,8
    if(flags & 0x2)
    80004efe:	8b89                	andi	a5,a5,2
    80004f00:	c399                	beqz	a5,80004f06 <flags2perm+0x16>
      perm |= PTE_W;
    80004f02:	00456513          	ori	a0,a0,4
    return perm;
}
    80004f06:	6422                	ld	s0,8(sp)
    80004f08:	0141                	addi	sp,sp,16
    80004f0a:	8082                	ret

0000000080004f0c <exec>:

int
exec(char *path, char **argv)
{
    80004f0c:	de010113          	addi	sp,sp,-544
    80004f10:	20113c23          	sd	ra,536(sp)
    80004f14:	20813823          	sd	s0,528(sp)
    80004f18:	20913423          	sd	s1,520(sp)
    80004f1c:	21213023          	sd	s2,512(sp)
    80004f20:	ffce                	sd	s3,504(sp)
    80004f22:	fbd2                	sd	s4,496(sp)
    80004f24:	f7d6                	sd	s5,488(sp)
    80004f26:	f3da                	sd	s6,480(sp)
    80004f28:	efde                	sd	s7,472(sp)
    80004f2a:	ebe2                	sd	s8,464(sp)
    80004f2c:	e7e6                	sd	s9,456(sp)
    80004f2e:	e3ea                	sd	s10,448(sp)
    80004f30:	ff6e                	sd	s11,440(sp)
    80004f32:	1400                	addi	s0,sp,544
    80004f34:	892a                	mv	s2,a0
    80004f36:	dea43423          	sd	a0,-536(s0)
    80004f3a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f3e:	ffffd097          	auipc	ra,0xffffd
    80004f42:	a42080e7          	jalr	-1470(ra) # 80001980 <myproc>
    80004f46:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80004f48:	ffffe097          	auipc	ra,0xffffe
    80004f4c:	86e080e7          	jalr	-1938(ra) # 800027b6 <mykthread>

  begin_op();
    80004f50:	fffff097          	auipc	ra,0xfffff
    80004f54:	476080e7          	jalr	1142(ra) # 800043c6 <begin_op>

  if((ip = namei(path)) == 0){
    80004f58:	854a                	mv	a0,s2
    80004f5a:	fffff097          	auipc	ra,0xfffff
    80004f5e:	250080e7          	jalr	592(ra) # 800041aa <namei>
    80004f62:	c93d                	beqz	a0,80004fd8 <exec+0xcc>
    80004f64:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f66:	fffff097          	auipc	ra,0xfffff
    80004f6a:	a9e080e7          	jalr	-1378(ra) # 80003a04 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f6e:	04000713          	li	a4,64
    80004f72:	4681                	li	a3,0
    80004f74:	e5040613          	addi	a2,s0,-432
    80004f78:	4581                	li	a1,0
    80004f7a:	8556                	mv	a0,s5
    80004f7c:	fffff097          	auipc	ra,0xfffff
    80004f80:	d3c080e7          	jalr	-708(ra) # 80003cb8 <readi>
    80004f84:	04000793          	li	a5,64
    80004f88:	00f51a63          	bne	a0,a5,80004f9c <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f8c:	e5042703          	lw	a4,-432(s0)
    80004f90:	464c47b7          	lui	a5,0x464c4
    80004f94:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f98:	04f70663          	beq	a4,a5,80004fe4 <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f9c:	8556                	mv	a0,s5
    80004f9e:	fffff097          	auipc	ra,0xfffff
    80004fa2:	cc8080e7          	jalr	-824(ra) # 80003c66 <iunlockput>
    end_op();
    80004fa6:	fffff097          	auipc	ra,0xfffff
    80004faa:	4a0080e7          	jalr	1184(ra) # 80004446 <end_op>
  }
  return -1;
    80004fae:	557d                	li	a0,-1
}
    80004fb0:	21813083          	ld	ra,536(sp)
    80004fb4:	21013403          	ld	s0,528(sp)
    80004fb8:	20813483          	ld	s1,520(sp)
    80004fbc:	20013903          	ld	s2,512(sp)
    80004fc0:	79fe                	ld	s3,504(sp)
    80004fc2:	7a5e                	ld	s4,496(sp)
    80004fc4:	7abe                	ld	s5,488(sp)
    80004fc6:	7b1e                	ld	s6,480(sp)
    80004fc8:	6bfe                	ld	s7,472(sp)
    80004fca:	6c5e                	ld	s8,464(sp)
    80004fcc:	6cbe                	ld	s9,456(sp)
    80004fce:	6d1e                	ld	s10,448(sp)
    80004fd0:	7dfa                	ld	s11,440(sp)
    80004fd2:	22010113          	addi	sp,sp,544
    80004fd6:	8082                	ret
    end_op();
    80004fd8:	fffff097          	auipc	ra,0xfffff
    80004fdc:	46e080e7          	jalr	1134(ra) # 80004446 <end_op>
    return -1;
    80004fe0:	557d                	li	a0,-1
    80004fe2:	b7f9                	j	80004fb0 <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    80004fe4:	8526                	mv	a0,s1
    80004fe6:	ffffd097          	auipc	ra,0xffffd
    80004fea:	a1c080e7          	jalr	-1508(ra) # 80001a02 <proc_pagetable>
    80004fee:	8b2a                	mv	s6,a0
    80004ff0:	d555                	beqz	a0,80004f9c <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ff2:	e7042783          	lw	a5,-400(s0)
    80004ff6:	e8845703          	lhu	a4,-376(s0)
    80004ffa:	c735                	beqz	a4,80005066 <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ffc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ffe:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005002:	6a05                	lui	s4,0x1
    80005004:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005008:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000500c:	6d85                	lui	s11,0x1
    8000500e:	7d7d                	lui	s10,0xfffff
    80005010:	a4a9                	j	8000525a <exec+0x34e>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005012:	00003517          	auipc	a0,0x3
    80005016:	75650513          	addi	a0,a0,1878 # 80008768 <syscalls+0x280>
    8000501a:	ffffb097          	auipc	ra,0xffffb
    8000501e:	524080e7          	jalr	1316(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005022:	874a                	mv	a4,s2
    80005024:	009c86bb          	addw	a3,s9,s1
    80005028:	4581                	li	a1,0
    8000502a:	8556                	mv	a0,s5
    8000502c:	fffff097          	auipc	ra,0xfffff
    80005030:	c8c080e7          	jalr	-884(ra) # 80003cb8 <readi>
    80005034:	2501                	sext.w	a0,a0
    80005036:	1aa91f63          	bne	s2,a0,800051f4 <exec+0x2e8>
  for(i = 0; i < sz; i += PGSIZE){
    8000503a:	009d84bb          	addw	s1,s11,s1
    8000503e:	013d09bb          	addw	s3,s10,s3
    80005042:	1f74fc63          	bgeu	s1,s7,8000523a <exec+0x32e>
    pa = walkaddr(pagetable, va + i);
    80005046:	02049593          	slli	a1,s1,0x20
    8000504a:	9181                	srli	a1,a1,0x20
    8000504c:	95e2                	add	a1,a1,s8
    8000504e:	855a                	mv	a0,s6
    80005050:	ffffc097          	auipc	ra,0xffffc
    80005054:	00c080e7          	jalr	12(ra) # 8000105c <walkaddr>
    80005058:	862a                	mv	a2,a0
    if(pa == 0)
    8000505a:	dd45                	beqz	a0,80005012 <exec+0x106>
      n = PGSIZE;
    8000505c:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000505e:	fd49f2e3          	bgeu	s3,s4,80005022 <exec+0x116>
      n = sz - i;
    80005062:	894e                	mv	s2,s3
    80005064:	bf7d                	j	80005022 <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005066:	4901                	li	s2,0
  iunlockput(ip);
    80005068:	8556                	mv	a0,s5
    8000506a:	fffff097          	auipc	ra,0xfffff
    8000506e:	bfc080e7          	jalr	-1028(ra) # 80003c66 <iunlockput>
  end_op();
    80005072:	fffff097          	auipc	ra,0xfffff
    80005076:	3d4080e7          	jalr	980(ra) # 80004446 <end_op>
  p = myproc();
    8000507a:	ffffd097          	auipc	ra,0xffffd
    8000507e:	906080e7          	jalr	-1786(ra) # 80001980 <myproc>
    80005082:	8baa                	mv	s7,a0
  kt = mykthread();
    80005084:	ffffd097          	auipc	ra,0xffffd
    80005088:	732080e7          	jalr	1842(ra) # 800027b6 <mykthread>
    8000508c:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    8000508e:	0f8bbd83          	ld	s11,248(s7) # 10f8 <_entry-0x7fffef08>
  sz = PGROUNDUP(sz);
    80005092:	6785                	lui	a5,0x1
    80005094:	17fd                	addi	a5,a5,-1
    80005096:	993e                	add	s2,s2,a5
    80005098:	77fd                	lui	a5,0xfffff
    8000509a:	00f977b3          	and	a5,s2,a5
    8000509e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800050a2:	4691                	li	a3,4
    800050a4:	6609                	lui	a2,0x2
    800050a6:	963e                	add	a2,a2,a5
    800050a8:	85be                	mv	a1,a5
    800050aa:	855a                	mv	a0,s6
    800050ac:	ffffc097          	auipc	ra,0xffffc
    800050b0:	364080e7          	jalr	868(ra) # 80001410 <uvmalloc>
    800050b4:	8c2a                	mv	s8,a0
  ip = 0;
    800050b6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800050b8:	12050e63          	beqz	a0,800051f4 <exec+0x2e8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050bc:	75f9                	lui	a1,0xffffe
    800050be:	95aa                	add	a1,a1,a0
    800050c0:	855a                	mv	a0,s6
    800050c2:	ffffc097          	auipc	ra,0xffffc
    800050c6:	574080e7          	jalr	1396(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    800050ca:	7afd                	lui	s5,0xfffff
    800050cc:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800050ce:	df043783          	ld	a5,-528(s0)
    800050d2:	6388                	ld	a0,0(a5)
    800050d4:	c925                	beqz	a0,80005144 <exec+0x238>
    800050d6:	e9040993          	addi	s3,s0,-368
    800050da:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800050de:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050e0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050e2:	ffffc097          	auipc	ra,0xffffc
    800050e6:	d6c080e7          	jalr	-660(ra) # 80000e4e <strlen>
    800050ea:	0015079b          	addiw	a5,a0,1
    800050ee:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050f2:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800050f6:	13596663          	bltu	s2,s5,80005222 <exec+0x316>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050fa:	df043783          	ld	a5,-528(s0)
    800050fe:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffdbc00>
    80005102:	8552                	mv	a0,s4
    80005104:	ffffc097          	auipc	ra,0xffffc
    80005108:	d4a080e7          	jalr	-694(ra) # 80000e4e <strlen>
    8000510c:	0015069b          	addiw	a3,a0,1
    80005110:	8652                	mv	a2,s4
    80005112:	85ca                	mv	a1,s2
    80005114:	855a                	mv	a0,s6
    80005116:	ffffc097          	auipc	ra,0xffffc
    8000511a:	552080e7          	jalr	1362(ra) # 80001668 <copyout>
    8000511e:	10054663          	bltz	a0,8000522a <exec+0x31e>
    ustack[argc] = sp;
    80005122:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005126:	0485                	addi	s1,s1,1
    80005128:	df043783          	ld	a5,-528(s0)
    8000512c:	07a1                	addi	a5,a5,8
    8000512e:	def43823          	sd	a5,-528(s0)
    80005132:	6388                	ld	a0,0(a5)
    80005134:	c911                	beqz	a0,80005148 <exec+0x23c>
    if(argc >= MAXARG)
    80005136:	09a1                	addi	s3,s3,8
    80005138:	fb3c95e3          	bne	s9,s3,800050e2 <exec+0x1d6>
  sz = sz1;
    8000513c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005140:	4a81                	li	s5,0
    80005142:	a84d                	j	800051f4 <exec+0x2e8>
  sp = sz;
    80005144:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005146:	4481                	li	s1,0
  ustack[argc] = 0;
    80005148:	00349793          	slli	a5,s1,0x3
    8000514c:	f9040713          	addi	a4,s0,-112
    80005150:	97ba                	add	a5,a5,a4
    80005152:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005156:	00148693          	addi	a3,s1,1
    8000515a:	068e                	slli	a3,a3,0x3
    8000515c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005160:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005164:	01597663          	bgeu	s2,s5,80005170 <exec+0x264>
  sz = sz1;
    80005168:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000516c:	4a81                	li	s5,0
    8000516e:	a059                	j	800051f4 <exec+0x2e8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005170:	e9040613          	addi	a2,s0,-368
    80005174:	85ca                	mv	a1,s2
    80005176:	855a                	mv	a0,s6
    80005178:	ffffc097          	auipc	ra,0xffffc
    8000517c:	4f0080e7          	jalr	1264(ra) # 80001668 <copyout>
    80005180:	0a054963          	bltz	a0,80005232 <exec+0x326>
  kt->trapframe->a1 = sp;
    80005184:	0b8d3783          	ld	a5,184(s10) # fffffffffffff0b8 <end+0xffffffff7ffdbcb8>
    80005188:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000518c:	de843783          	ld	a5,-536(s0)
    80005190:	0007c703          	lbu	a4,0(a5)
    80005194:	cf11                	beqz	a4,800051b0 <exec+0x2a4>
    80005196:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005198:	02f00693          	li	a3,47
    8000519c:	a039                	j	800051aa <exec+0x29e>
      last = s+1;
    8000519e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800051a2:	0785                	addi	a5,a5,1
    800051a4:	fff7c703          	lbu	a4,-1(a5)
    800051a8:	c701                	beqz	a4,800051b0 <exec+0x2a4>
    if(*s == '/')
    800051aa:	fed71ce3          	bne	a4,a3,800051a2 <exec+0x296>
    800051ae:	bfc5                	j	8000519e <exec+0x292>
  safestrcpy(p->name, last, sizeof(p->name));
    800051b0:	4641                	li	a2,16
    800051b2:	de843583          	ld	a1,-536(s0)
    800051b6:	190b8513          	addi	a0,s7,400
    800051ba:	ffffc097          	auipc	ra,0xffffc
    800051be:	c62080e7          	jalr	-926(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800051c2:	100bb503          	ld	a0,256(s7)
  p->pagetable = pagetable;
    800051c6:	116bb023          	sd	s6,256(s7)
  p->sz = sz;
    800051ca:	0f8bbc23          	sd	s8,248(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    800051ce:	0b8d3783          	ld	a5,184(s10)
    800051d2:	e6843703          	ld	a4,-408(s0)
    800051d6:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    800051d8:	0b8d3783          	ld	a5,184(s10)
    800051dc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051e0:	85ee                	mv	a1,s11
    800051e2:	ffffd097          	auipc	ra,0xffffd
    800051e6:	8bc080e7          	jalr	-1860(ra) # 80001a9e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051ea:	0004851b          	sext.w	a0,s1
    800051ee:	b3c9                	j	80004fb0 <exec+0xa4>
    800051f0:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051f4:	df843583          	ld	a1,-520(s0)
    800051f8:	855a                	mv	a0,s6
    800051fa:	ffffd097          	auipc	ra,0xffffd
    800051fe:	8a4080e7          	jalr	-1884(ra) # 80001a9e <proc_freepagetable>
  if(ip){
    80005202:	d80a9de3          	bnez	s5,80004f9c <exec+0x90>
  return -1;
    80005206:	557d                	li	a0,-1
    80005208:	b365                	j	80004fb0 <exec+0xa4>
    8000520a:	df243c23          	sd	s2,-520(s0)
    8000520e:	b7dd                	j	800051f4 <exec+0x2e8>
    80005210:	df243c23          	sd	s2,-520(s0)
    80005214:	b7c5                	j	800051f4 <exec+0x2e8>
    80005216:	df243c23          	sd	s2,-520(s0)
    8000521a:	bfe9                	j	800051f4 <exec+0x2e8>
    8000521c:	df243c23          	sd	s2,-520(s0)
    80005220:	bfd1                	j	800051f4 <exec+0x2e8>
  sz = sz1;
    80005222:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005226:	4a81                	li	s5,0
    80005228:	b7f1                	j	800051f4 <exec+0x2e8>
  sz = sz1;
    8000522a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000522e:	4a81                	li	s5,0
    80005230:	b7d1                	j	800051f4 <exec+0x2e8>
  sz = sz1;
    80005232:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005236:	4a81                	li	s5,0
    80005238:	bf75                	j	800051f4 <exec+0x2e8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000523a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000523e:	e0843783          	ld	a5,-504(s0)
    80005242:	0017869b          	addiw	a3,a5,1
    80005246:	e0d43423          	sd	a3,-504(s0)
    8000524a:	e0043783          	ld	a5,-512(s0)
    8000524e:	0387879b          	addiw	a5,a5,56
    80005252:	e8845703          	lhu	a4,-376(s0)
    80005256:	e0e6d9e3          	bge	a3,a4,80005068 <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000525a:	2781                	sext.w	a5,a5
    8000525c:	e0f43023          	sd	a5,-512(s0)
    80005260:	03800713          	li	a4,56
    80005264:	86be                	mv	a3,a5
    80005266:	e1840613          	addi	a2,s0,-488
    8000526a:	4581                	li	a1,0
    8000526c:	8556                	mv	a0,s5
    8000526e:	fffff097          	auipc	ra,0xfffff
    80005272:	a4a080e7          	jalr	-1462(ra) # 80003cb8 <readi>
    80005276:	03800793          	li	a5,56
    8000527a:	f6f51be3          	bne	a0,a5,800051f0 <exec+0x2e4>
    if(ph.type != ELF_PROG_LOAD)
    8000527e:	e1842783          	lw	a5,-488(s0)
    80005282:	4705                	li	a4,1
    80005284:	fae79de3          	bne	a5,a4,8000523e <exec+0x332>
    if(ph.memsz < ph.filesz)
    80005288:	e4043483          	ld	s1,-448(s0)
    8000528c:	e3843783          	ld	a5,-456(s0)
    80005290:	f6f4ede3          	bltu	s1,a5,8000520a <exec+0x2fe>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005294:	e2843783          	ld	a5,-472(s0)
    80005298:	94be                	add	s1,s1,a5
    8000529a:	f6f4ebe3          	bltu	s1,a5,80005210 <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    8000529e:	de043703          	ld	a4,-544(s0)
    800052a2:	8ff9                	and	a5,a5,a4
    800052a4:	fbad                	bnez	a5,80005216 <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800052a6:	e1c42503          	lw	a0,-484(s0)
    800052aa:	00000097          	auipc	ra,0x0
    800052ae:	c46080e7          	jalr	-954(ra) # 80004ef0 <flags2perm>
    800052b2:	86aa                	mv	a3,a0
    800052b4:	8626                	mv	a2,s1
    800052b6:	85ca                	mv	a1,s2
    800052b8:	855a                	mv	a0,s6
    800052ba:	ffffc097          	auipc	ra,0xffffc
    800052be:	156080e7          	jalr	342(ra) # 80001410 <uvmalloc>
    800052c2:	dea43c23          	sd	a0,-520(s0)
    800052c6:	d939                	beqz	a0,8000521c <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052c8:	e2843c03          	ld	s8,-472(s0)
    800052cc:	e2042c83          	lw	s9,-480(s0)
    800052d0:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052d4:	f60b83e3          	beqz	s7,8000523a <exec+0x32e>
    800052d8:	89de                	mv	s3,s7
    800052da:	4481                	li	s1,0
    800052dc:	b3ad                	j	80005046 <exec+0x13a>

00000000800052de <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052de:	7179                	addi	sp,sp,-48
    800052e0:	f406                	sd	ra,40(sp)
    800052e2:	f022                	sd	s0,32(sp)
    800052e4:	ec26                	sd	s1,24(sp)
    800052e6:	e84a                	sd	s2,16(sp)
    800052e8:	1800                	addi	s0,sp,48
    800052ea:	892e                	mv	s2,a1
    800052ec:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800052ee:	fdc40593          	addi	a1,s0,-36
    800052f2:	ffffe097          	auipc	ra,0xffffe
    800052f6:	b96080e7          	jalr	-1130(ra) # 80002e88 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052fa:	fdc42703          	lw	a4,-36(s0)
    800052fe:	47bd                	li	a5,15
    80005300:	02e7eb63          	bltu	a5,a4,80005336 <argfd+0x58>
    80005304:	ffffc097          	auipc	ra,0xffffc
    80005308:	67c080e7          	jalr	1660(ra) # 80001980 <myproc>
    8000530c:	fdc42703          	lw	a4,-36(s0)
    80005310:	02070793          	addi	a5,a4,32
    80005314:	078e                	slli	a5,a5,0x3
    80005316:	953e                	add	a0,a0,a5
    80005318:	651c                	ld	a5,8(a0)
    8000531a:	c385                	beqz	a5,8000533a <argfd+0x5c>
    return -1;
  if(pfd)
    8000531c:	00090463          	beqz	s2,80005324 <argfd+0x46>
    *pfd = fd;
    80005320:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005324:	4501                	li	a0,0
  if(pf)
    80005326:	c091                	beqz	s1,8000532a <argfd+0x4c>
    *pf = f;
    80005328:	e09c                	sd	a5,0(s1)
}
    8000532a:	70a2                	ld	ra,40(sp)
    8000532c:	7402                	ld	s0,32(sp)
    8000532e:	64e2                	ld	s1,24(sp)
    80005330:	6942                	ld	s2,16(sp)
    80005332:	6145                	addi	sp,sp,48
    80005334:	8082                	ret
    return -1;
    80005336:	557d                	li	a0,-1
    80005338:	bfcd                	j	8000532a <argfd+0x4c>
    8000533a:	557d                	li	a0,-1
    8000533c:	b7fd                	j	8000532a <argfd+0x4c>

000000008000533e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000533e:	1101                	addi	sp,sp,-32
    80005340:	ec06                	sd	ra,24(sp)
    80005342:	e822                	sd	s0,16(sp)
    80005344:	e426                	sd	s1,8(sp)
    80005346:	1000                	addi	s0,sp,32
    80005348:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000534a:	ffffc097          	auipc	ra,0xffffc
    8000534e:	636080e7          	jalr	1590(ra) # 80001980 <myproc>
    80005352:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005354:	10850793          	addi	a5,a0,264
    80005358:	4501                	li	a0,0
    8000535a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000535c:	6398                	ld	a4,0(a5)
    8000535e:	cb19                	beqz	a4,80005374 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005360:	2505                	addiw	a0,a0,1
    80005362:	07a1                	addi	a5,a5,8
    80005364:	fed51ce3          	bne	a0,a3,8000535c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005368:	557d                	li	a0,-1
}
    8000536a:	60e2                	ld	ra,24(sp)
    8000536c:	6442                	ld	s0,16(sp)
    8000536e:	64a2                	ld	s1,8(sp)
    80005370:	6105                	addi	sp,sp,32
    80005372:	8082                	ret
      p->ofile[fd] = f;
    80005374:	02050793          	addi	a5,a0,32
    80005378:	078e                	slli	a5,a5,0x3
    8000537a:	963e                	add	a2,a2,a5
    8000537c:	e604                	sd	s1,8(a2)
      return fd;
    8000537e:	b7f5                	j	8000536a <fdalloc+0x2c>

0000000080005380 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005380:	715d                	addi	sp,sp,-80
    80005382:	e486                	sd	ra,72(sp)
    80005384:	e0a2                	sd	s0,64(sp)
    80005386:	fc26                	sd	s1,56(sp)
    80005388:	f84a                	sd	s2,48(sp)
    8000538a:	f44e                	sd	s3,40(sp)
    8000538c:	f052                	sd	s4,32(sp)
    8000538e:	ec56                	sd	s5,24(sp)
    80005390:	e85a                	sd	s6,16(sp)
    80005392:	0880                	addi	s0,sp,80
    80005394:	8b2e                	mv	s6,a1
    80005396:	89b2                	mv	s3,a2
    80005398:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000539a:	fb040593          	addi	a1,s0,-80
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	e2a080e7          	jalr	-470(ra) # 800041c8 <nameiparent>
    800053a6:	84aa                	mv	s1,a0
    800053a8:	14050f63          	beqz	a0,80005506 <create+0x186>
    return 0;

  ilock(dp);
    800053ac:	ffffe097          	auipc	ra,0xffffe
    800053b0:	658080e7          	jalr	1624(ra) # 80003a04 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800053b4:	4601                	li	a2,0
    800053b6:	fb040593          	addi	a1,s0,-80
    800053ba:	8526                	mv	a0,s1
    800053bc:	fffff097          	auipc	ra,0xfffff
    800053c0:	b2c080e7          	jalr	-1236(ra) # 80003ee8 <dirlookup>
    800053c4:	8aaa                	mv	s5,a0
    800053c6:	c931                	beqz	a0,8000541a <create+0x9a>
    iunlockput(dp);
    800053c8:	8526                	mv	a0,s1
    800053ca:	fffff097          	auipc	ra,0xfffff
    800053ce:	89c080e7          	jalr	-1892(ra) # 80003c66 <iunlockput>
    ilock(ip);
    800053d2:	8556                	mv	a0,s5
    800053d4:	ffffe097          	auipc	ra,0xffffe
    800053d8:	630080e7          	jalr	1584(ra) # 80003a04 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053dc:	000b059b          	sext.w	a1,s6
    800053e0:	4789                	li	a5,2
    800053e2:	02f59563          	bne	a1,a5,8000540c <create+0x8c>
    800053e6:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbc44>
    800053ea:	37f9                	addiw	a5,a5,-2
    800053ec:	17c2                	slli	a5,a5,0x30
    800053ee:	93c1                	srli	a5,a5,0x30
    800053f0:	4705                	li	a4,1
    800053f2:	00f76d63          	bltu	a4,a5,8000540c <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800053f6:	8556                	mv	a0,s5
    800053f8:	60a6                	ld	ra,72(sp)
    800053fa:	6406                	ld	s0,64(sp)
    800053fc:	74e2                	ld	s1,56(sp)
    800053fe:	7942                	ld	s2,48(sp)
    80005400:	79a2                	ld	s3,40(sp)
    80005402:	7a02                	ld	s4,32(sp)
    80005404:	6ae2                	ld	s5,24(sp)
    80005406:	6b42                	ld	s6,16(sp)
    80005408:	6161                	addi	sp,sp,80
    8000540a:	8082                	ret
    iunlockput(ip);
    8000540c:	8556                	mv	a0,s5
    8000540e:	fffff097          	auipc	ra,0xfffff
    80005412:	858080e7          	jalr	-1960(ra) # 80003c66 <iunlockput>
    return 0;
    80005416:	4a81                	li	s5,0
    80005418:	bff9                	j	800053f6 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000541a:	85da                	mv	a1,s6
    8000541c:	4088                	lw	a0,0(s1)
    8000541e:	ffffe097          	auipc	ra,0xffffe
    80005422:	44a080e7          	jalr	1098(ra) # 80003868 <ialloc>
    80005426:	8a2a                	mv	s4,a0
    80005428:	c539                	beqz	a0,80005476 <create+0xf6>
  ilock(ip);
    8000542a:	ffffe097          	auipc	ra,0xffffe
    8000542e:	5da080e7          	jalr	1498(ra) # 80003a04 <ilock>
  ip->major = major;
    80005432:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005436:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000543a:	4905                	li	s2,1
    8000543c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005440:	8552                	mv	a0,s4
    80005442:	ffffe097          	auipc	ra,0xffffe
    80005446:	4f8080e7          	jalr	1272(ra) # 8000393a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000544a:	000b059b          	sext.w	a1,s6
    8000544e:	03258b63          	beq	a1,s2,80005484 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005452:	004a2603          	lw	a2,4(s4)
    80005456:	fb040593          	addi	a1,s0,-80
    8000545a:	8526                	mv	a0,s1
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	c9c080e7          	jalr	-868(ra) # 800040f8 <dirlink>
    80005464:	06054f63          	bltz	a0,800054e2 <create+0x162>
  iunlockput(dp);
    80005468:	8526                	mv	a0,s1
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	7fc080e7          	jalr	2044(ra) # 80003c66 <iunlockput>
  return ip;
    80005472:	8ad2                	mv	s5,s4
    80005474:	b749                	j	800053f6 <create+0x76>
    iunlockput(dp);
    80005476:	8526                	mv	a0,s1
    80005478:	ffffe097          	auipc	ra,0xffffe
    8000547c:	7ee080e7          	jalr	2030(ra) # 80003c66 <iunlockput>
    return 0;
    80005480:	8ad2                	mv	s5,s4
    80005482:	bf95                	j	800053f6 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005484:	004a2603          	lw	a2,4(s4)
    80005488:	00003597          	auipc	a1,0x3
    8000548c:	30058593          	addi	a1,a1,768 # 80008788 <syscalls+0x2a0>
    80005490:	8552                	mv	a0,s4
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	c66080e7          	jalr	-922(ra) # 800040f8 <dirlink>
    8000549a:	04054463          	bltz	a0,800054e2 <create+0x162>
    8000549e:	40d0                	lw	a2,4(s1)
    800054a0:	00003597          	auipc	a1,0x3
    800054a4:	2f058593          	addi	a1,a1,752 # 80008790 <syscalls+0x2a8>
    800054a8:	8552                	mv	a0,s4
    800054aa:	fffff097          	auipc	ra,0xfffff
    800054ae:	c4e080e7          	jalr	-946(ra) # 800040f8 <dirlink>
    800054b2:	02054863          	bltz	a0,800054e2 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800054b6:	004a2603          	lw	a2,4(s4)
    800054ba:	fb040593          	addi	a1,s0,-80
    800054be:	8526                	mv	a0,s1
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	c38080e7          	jalr	-968(ra) # 800040f8 <dirlink>
    800054c8:	00054d63          	bltz	a0,800054e2 <create+0x162>
    dp->nlink++;  // for ".."
    800054cc:	04a4d783          	lhu	a5,74(s1)
    800054d0:	2785                	addiw	a5,a5,1
    800054d2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054d6:	8526                	mv	a0,s1
    800054d8:	ffffe097          	auipc	ra,0xffffe
    800054dc:	462080e7          	jalr	1122(ra) # 8000393a <iupdate>
    800054e0:	b761                	j	80005468 <create+0xe8>
  ip->nlink = 0;
    800054e2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800054e6:	8552                	mv	a0,s4
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	452080e7          	jalr	1106(ra) # 8000393a <iupdate>
  iunlockput(ip);
    800054f0:	8552                	mv	a0,s4
    800054f2:	ffffe097          	auipc	ra,0xffffe
    800054f6:	774080e7          	jalr	1908(ra) # 80003c66 <iunlockput>
  iunlockput(dp);
    800054fa:	8526                	mv	a0,s1
    800054fc:	ffffe097          	auipc	ra,0xffffe
    80005500:	76a080e7          	jalr	1898(ra) # 80003c66 <iunlockput>
  return 0;
    80005504:	bdcd                	j	800053f6 <create+0x76>
    return 0;
    80005506:	8aaa                	mv	s5,a0
    80005508:	b5fd                	j	800053f6 <create+0x76>

000000008000550a <sys_dup>:
{
    8000550a:	7179                	addi	sp,sp,-48
    8000550c:	f406                	sd	ra,40(sp)
    8000550e:	f022                	sd	s0,32(sp)
    80005510:	ec26                	sd	s1,24(sp)
    80005512:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005514:	fd840613          	addi	a2,s0,-40
    80005518:	4581                	li	a1,0
    8000551a:	4501                	li	a0,0
    8000551c:	00000097          	auipc	ra,0x0
    80005520:	dc2080e7          	jalr	-574(ra) # 800052de <argfd>
    return -1;
    80005524:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005526:	02054363          	bltz	a0,8000554c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000552a:	fd843503          	ld	a0,-40(s0)
    8000552e:	00000097          	auipc	ra,0x0
    80005532:	e10080e7          	jalr	-496(ra) # 8000533e <fdalloc>
    80005536:	84aa                	mv	s1,a0
    return -1;
    80005538:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000553a:	00054963          	bltz	a0,8000554c <sys_dup+0x42>
  filedup(f);
    8000553e:	fd843503          	ld	a0,-40(s0)
    80005542:	fffff097          	auipc	ra,0xfffff
    80005546:	2fe080e7          	jalr	766(ra) # 80004840 <filedup>
  return fd;
    8000554a:	87a6                	mv	a5,s1
}
    8000554c:	853e                	mv	a0,a5
    8000554e:	70a2                	ld	ra,40(sp)
    80005550:	7402                	ld	s0,32(sp)
    80005552:	64e2                	ld	s1,24(sp)
    80005554:	6145                	addi	sp,sp,48
    80005556:	8082                	ret

0000000080005558 <sys_read>:
{
    80005558:	7179                	addi	sp,sp,-48
    8000555a:	f406                	sd	ra,40(sp)
    8000555c:	f022                	sd	s0,32(sp)
    8000555e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005560:	fd840593          	addi	a1,s0,-40
    80005564:	4505                	li	a0,1
    80005566:	ffffe097          	auipc	ra,0xffffe
    8000556a:	942080e7          	jalr	-1726(ra) # 80002ea8 <argaddr>
  argint(2, &n);
    8000556e:	fe440593          	addi	a1,s0,-28
    80005572:	4509                	li	a0,2
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	914080e7          	jalr	-1772(ra) # 80002e88 <argint>
  if(argfd(0, 0, &f) < 0)
    8000557c:	fe840613          	addi	a2,s0,-24
    80005580:	4581                	li	a1,0
    80005582:	4501                	li	a0,0
    80005584:	00000097          	auipc	ra,0x0
    80005588:	d5a080e7          	jalr	-678(ra) # 800052de <argfd>
    8000558c:	87aa                	mv	a5,a0
    return -1;
    8000558e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005590:	0007cc63          	bltz	a5,800055a8 <sys_read+0x50>
  return fileread(f, p, n);
    80005594:	fe442603          	lw	a2,-28(s0)
    80005598:	fd843583          	ld	a1,-40(s0)
    8000559c:	fe843503          	ld	a0,-24(s0)
    800055a0:	fffff097          	auipc	ra,0xfffff
    800055a4:	42c080e7          	jalr	1068(ra) # 800049cc <fileread>
}
    800055a8:	70a2                	ld	ra,40(sp)
    800055aa:	7402                	ld	s0,32(sp)
    800055ac:	6145                	addi	sp,sp,48
    800055ae:	8082                	ret

00000000800055b0 <sys_write>:
{
    800055b0:	7179                	addi	sp,sp,-48
    800055b2:	f406                	sd	ra,40(sp)
    800055b4:	f022                	sd	s0,32(sp)
    800055b6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800055b8:	fd840593          	addi	a1,s0,-40
    800055bc:	4505                	li	a0,1
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	8ea080e7          	jalr	-1814(ra) # 80002ea8 <argaddr>
  argint(2, &n);
    800055c6:	fe440593          	addi	a1,s0,-28
    800055ca:	4509                	li	a0,2
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	8bc080e7          	jalr	-1860(ra) # 80002e88 <argint>
  if(argfd(0, 0, &f) < 0)
    800055d4:	fe840613          	addi	a2,s0,-24
    800055d8:	4581                	li	a1,0
    800055da:	4501                	li	a0,0
    800055dc:	00000097          	auipc	ra,0x0
    800055e0:	d02080e7          	jalr	-766(ra) # 800052de <argfd>
    800055e4:	87aa                	mv	a5,a0
    return -1;
    800055e6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055e8:	0007cc63          	bltz	a5,80005600 <sys_write+0x50>
  return filewrite(f, p, n);
    800055ec:	fe442603          	lw	a2,-28(s0)
    800055f0:	fd843583          	ld	a1,-40(s0)
    800055f4:	fe843503          	ld	a0,-24(s0)
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	496080e7          	jalr	1174(ra) # 80004a8e <filewrite>
}
    80005600:	70a2                	ld	ra,40(sp)
    80005602:	7402                	ld	s0,32(sp)
    80005604:	6145                	addi	sp,sp,48
    80005606:	8082                	ret

0000000080005608 <sys_close>:
{
    80005608:	1101                	addi	sp,sp,-32
    8000560a:	ec06                	sd	ra,24(sp)
    8000560c:	e822                	sd	s0,16(sp)
    8000560e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005610:	fe040613          	addi	a2,s0,-32
    80005614:	fec40593          	addi	a1,s0,-20
    80005618:	4501                	li	a0,0
    8000561a:	00000097          	auipc	ra,0x0
    8000561e:	cc4080e7          	jalr	-828(ra) # 800052de <argfd>
    return -1;
    80005622:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005624:	02054563          	bltz	a0,8000564e <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005628:	ffffc097          	auipc	ra,0xffffc
    8000562c:	358080e7          	jalr	856(ra) # 80001980 <myproc>
    80005630:	fec42783          	lw	a5,-20(s0)
    80005634:	02078793          	addi	a5,a5,32
    80005638:	078e                	slli	a5,a5,0x3
    8000563a:	97aa                	add	a5,a5,a0
    8000563c:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005640:	fe043503          	ld	a0,-32(s0)
    80005644:	fffff097          	auipc	ra,0xfffff
    80005648:	24e080e7          	jalr	590(ra) # 80004892 <fileclose>
  return 0;
    8000564c:	4781                	li	a5,0
}
    8000564e:	853e                	mv	a0,a5
    80005650:	60e2                	ld	ra,24(sp)
    80005652:	6442                	ld	s0,16(sp)
    80005654:	6105                	addi	sp,sp,32
    80005656:	8082                	ret

0000000080005658 <sys_fstat>:
{
    80005658:	1101                	addi	sp,sp,-32
    8000565a:	ec06                	sd	ra,24(sp)
    8000565c:	e822                	sd	s0,16(sp)
    8000565e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005660:	fe040593          	addi	a1,s0,-32
    80005664:	4505                	li	a0,1
    80005666:	ffffe097          	auipc	ra,0xffffe
    8000566a:	842080e7          	jalr	-1982(ra) # 80002ea8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000566e:	fe840613          	addi	a2,s0,-24
    80005672:	4581                	li	a1,0
    80005674:	4501                	li	a0,0
    80005676:	00000097          	auipc	ra,0x0
    8000567a:	c68080e7          	jalr	-920(ra) # 800052de <argfd>
    8000567e:	87aa                	mv	a5,a0
    return -1;
    80005680:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005682:	0007ca63          	bltz	a5,80005696 <sys_fstat+0x3e>
  return filestat(f, st);
    80005686:	fe043583          	ld	a1,-32(s0)
    8000568a:	fe843503          	ld	a0,-24(s0)
    8000568e:	fffff097          	auipc	ra,0xfffff
    80005692:	2cc080e7          	jalr	716(ra) # 8000495a <filestat>
}
    80005696:	60e2                	ld	ra,24(sp)
    80005698:	6442                	ld	s0,16(sp)
    8000569a:	6105                	addi	sp,sp,32
    8000569c:	8082                	ret

000000008000569e <sys_link>:
{
    8000569e:	7169                	addi	sp,sp,-304
    800056a0:	f606                	sd	ra,296(sp)
    800056a2:	f222                	sd	s0,288(sp)
    800056a4:	ee26                	sd	s1,280(sp)
    800056a6:	ea4a                	sd	s2,272(sp)
    800056a8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056aa:	08000613          	li	a2,128
    800056ae:	ed040593          	addi	a1,s0,-304
    800056b2:	4501                	li	a0,0
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	814080e7          	jalr	-2028(ra) # 80002ec8 <argstr>
    return -1;
    800056bc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056be:	10054e63          	bltz	a0,800057da <sys_link+0x13c>
    800056c2:	08000613          	li	a2,128
    800056c6:	f5040593          	addi	a1,s0,-176
    800056ca:	4505                	li	a0,1
    800056cc:	ffffd097          	auipc	ra,0xffffd
    800056d0:	7fc080e7          	jalr	2044(ra) # 80002ec8 <argstr>
    return -1;
    800056d4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056d6:	10054263          	bltz	a0,800057da <sys_link+0x13c>
  begin_op();
    800056da:	fffff097          	auipc	ra,0xfffff
    800056de:	cec080e7          	jalr	-788(ra) # 800043c6 <begin_op>
  if((ip = namei(old)) == 0){
    800056e2:	ed040513          	addi	a0,s0,-304
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	ac4080e7          	jalr	-1340(ra) # 800041aa <namei>
    800056ee:	84aa                	mv	s1,a0
    800056f0:	c551                	beqz	a0,8000577c <sys_link+0xde>
  ilock(ip);
    800056f2:	ffffe097          	auipc	ra,0xffffe
    800056f6:	312080e7          	jalr	786(ra) # 80003a04 <ilock>
  if(ip->type == T_DIR){
    800056fa:	04449703          	lh	a4,68(s1)
    800056fe:	4785                	li	a5,1
    80005700:	08f70463          	beq	a4,a5,80005788 <sys_link+0xea>
  ip->nlink++;
    80005704:	04a4d783          	lhu	a5,74(s1)
    80005708:	2785                	addiw	a5,a5,1
    8000570a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000570e:	8526                	mv	a0,s1
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	22a080e7          	jalr	554(ra) # 8000393a <iupdate>
  iunlock(ip);
    80005718:	8526                	mv	a0,s1
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	3ac080e7          	jalr	940(ra) # 80003ac6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005722:	fd040593          	addi	a1,s0,-48
    80005726:	f5040513          	addi	a0,s0,-176
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	a9e080e7          	jalr	-1378(ra) # 800041c8 <nameiparent>
    80005732:	892a                	mv	s2,a0
    80005734:	c935                	beqz	a0,800057a8 <sys_link+0x10a>
  ilock(dp);
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	2ce080e7          	jalr	718(ra) # 80003a04 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000573e:	00092703          	lw	a4,0(s2)
    80005742:	409c                	lw	a5,0(s1)
    80005744:	04f71d63          	bne	a4,a5,8000579e <sys_link+0x100>
    80005748:	40d0                	lw	a2,4(s1)
    8000574a:	fd040593          	addi	a1,s0,-48
    8000574e:	854a                	mv	a0,s2
    80005750:	fffff097          	auipc	ra,0xfffff
    80005754:	9a8080e7          	jalr	-1624(ra) # 800040f8 <dirlink>
    80005758:	04054363          	bltz	a0,8000579e <sys_link+0x100>
  iunlockput(dp);
    8000575c:	854a                	mv	a0,s2
    8000575e:	ffffe097          	auipc	ra,0xffffe
    80005762:	508080e7          	jalr	1288(ra) # 80003c66 <iunlockput>
  iput(ip);
    80005766:	8526                	mv	a0,s1
    80005768:	ffffe097          	auipc	ra,0xffffe
    8000576c:	456080e7          	jalr	1110(ra) # 80003bbe <iput>
  end_op();
    80005770:	fffff097          	auipc	ra,0xfffff
    80005774:	cd6080e7          	jalr	-810(ra) # 80004446 <end_op>
  return 0;
    80005778:	4781                	li	a5,0
    8000577a:	a085                	j	800057da <sys_link+0x13c>
    end_op();
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	cca080e7          	jalr	-822(ra) # 80004446 <end_op>
    return -1;
    80005784:	57fd                	li	a5,-1
    80005786:	a891                	j	800057da <sys_link+0x13c>
    iunlockput(ip);
    80005788:	8526                	mv	a0,s1
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	4dc080e7          	jalr	1244(ra) # 80003c66 <iunlockput>
    end_op();
    80005792:	fffff097          	auipc	ra,0xfffff
    80005796:	cb4080e7          	jalr	-844(ra) # 80004446 <end_op>
    return -1;
    8000579a:	57fd                	li	a5,-1
    8000579c:	a83d                	j	800057da <sys_link+0x13c>
    iunlockput(dp);
    8000579e:	854a                	mv	a0,s2
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	4c6080e7          	jalr	1222(ra) # 80003c66 <iunlockput>
  ilock(ip);
    800057a8:	8526                	mv	a0,s1
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	25a080e7          	jalr	602(ra) # 80003a04 <ilock>
  ip->nlink--;
    800057b2:	04a4d783          	lhu	a5,74(s1)
    800057b6:	37fd                	addiw	a5,a5,-1
    800057b8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057bc:	8526                	mv	a0,s1
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	17c080e7          	jalr	380(ra) # 8000393a <iupdate>
  iunlockput(ip);
    800057c6:	8526                	mv	a0,s1
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	49e080e7          	jalr	1182(ra) # 80003c66 <iunlockput>
  end_op();
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	c76080e7          	jalr	-906(ra) # 80004446 <end_op>
  return -1;
    800057d8:	57fd                	li	a5,-1
}
    800057da:	853e                	mv	a0,a5
    800057dc:	70b2                	ld	ra,296(sp)
    800057de:	7412                	ld	s0,288(sp)
    800057e0:	64f2                	ld	s1,280(sp)
    800057e2:	6952                	ld	s2,272(sp)
    800057e4:	6155                	addi	sp,sp,304
    800057e6:	8082                	ret

00000000800057e8 <sys_unlink>:
{
    800057e8:	7151                	addi	sp,sp,-240
    800057ea:	f586                	sd	ra,232(sp)
    800057ec:	f1a2                	sd	s0,224(sp)
    800057ee:	eda6                	sd	s1,216(sp)
    800057f0:	e9ca                	sd	s2,208(sp)
    800057f2:	e5ce                	sd	s3,200(sp)
    800057f4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057f6:	08000613          	li	a2,128
    800057fa:	f3040593          	addi	a1,s0,-208
    800057fe:	4501                	li	a0,0
    80005800:	ffffd097          	auipc	ra,0xffffd
    80005804:	6c8080e7          	jalr	1736(ra) # 80002ec8 <argstr>
    80005808:	18054163          	bltz	a0,8000598a <sys_unlink+0x1a2>
  begin_op();
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	bba080e7          	jalr	-1094(ra) # 800043c6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005814:	fb040593          	addi	a1,s0,-80
    80005818:	f3040513          	addi	a0,s0,-208
    8000581c:	fffff097          	auipc	ra,0xfffff
    80005820:	9ac080e7          	jalr	-1620(ra) # 800041c8 <nameiparent>
    80005824:	84aa                	mv	s1,a0
    80005826:	c979                	beqz	a0,800058fc <sys_unlink+0x114>
  ilock(dp);
    80005828:	ffffe097          	auipc	ra,0xffffe
    8000582c:	1dc080e7          	jalr	476(ra) # 80003a04 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005830:	00003597          	auipc	a1,0x3
    80005834:	f5858593          	addi	a1,a1,-168 # 80008788 <syscalls+0x2a0>
    80005838:	fb040513          	addi	a0,s0,-80
    8000583c:	ffffe097          	auipc	ra,0xffffe
    80005840:	692080e7          	jalr	1682(ra) # 80003ece <namecmp>
    80005844:	14050a63          	beqz	a0,80005998 <sys_unlink+0x1b0>
    80005848:	00003597          	auipc	a1,0x3
    8000584c:	f4858593          	addi	a1,a1,-184 # 80008790 <syscalls+0x2a8>
    80005850:	fb040513          	addi	a0,s0,-80
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	67a080e7          	jalr	1658(ra) # 80003ece <namecmp>
    8000585c:	12050e63          	beqz	a0,80005998 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005860:	f2c40613          	addi	a2,s0,-212
    80005864:	fb040593          	addi	a1,s0,-80
    80005868:	8526                	mv	a0,s1
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	67e080e7          	jalr	1662(ra) # 80003ee8 <dirlookup>
    80005872:	892a                	mv	s2,a0
    80005874:	12050263          	beqz	a0,80005998 <sys_unlink+0x1b0>
  ilock(ip);
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	18c080e7          	jalr	396(ra) # 80003a04 <ilock>
  if(ip->nlink < 1)
    80005880:	04a91783          	lh	a5,74(s2)
    80005884:	08f05263          	blez	a5,80005908 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005888:	04491703          	lh	a4,68(s2)
    8000588c:	4785                	li	a5,1
    8000588e:	08f70563          	beq	a4,a5,80005918 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005892:	4641                	li	a2,16
    80005894:	4581                	li	a1,0
    80005896:	fc040513          	addi	a0,s0,-64
    8000589a:	ffffb097          	auipc	ra,0xffffb
    8000589e:	438080e7          	jalr	1080(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058a2:	4741                	li	a4,16
    800058a4:	f2c42683          	lw	a3,-212(s0)
    800058a8:	fc040613          	addi	a2,s0,-64
    800058ac:	4581                	li	a1,0
    800058ae:	8526                	mv	a0,s1
    800058b0:	ffffe097          	auipc	ra,0xffffe
    800058b4:	500080e7          	jalr	1280(ra) # 80003db0 <writei>
    800058b8:	47c1                	li	a5,16
    800058ba:	0af51563          	bne	a0,a5,80005964 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800058be:	04491703          	lh	a4,68(s2)
    800058c2:	4785                	li	a5,1
    800058c4:	0af70863          	beq	a4,a5,80005974 <sys_unlink+0x18c>
  iunlockput(dp);
    800058c8:	8526                	mv	a0,s1
    800058ca:	ffffe097          	auipc	ra,0xffffe
    800058ce:	39c080e7          	jalr	924(ra) # 80003c66 <iunlockput>
  ip->nlink--;
    800058d2:	04a95783          	lhu	a5,74(s2)
    800058d6:	37fd                	addiw	a5,a5,-1
    800058d8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058dc:	854a                	mv	a0,s2
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	05c080e7          	jalr	92(ra) # 8000393a <iupdate>
  iunlockput(ip);
    800058e6:	854a                	mv	a0,s2
    800058e8:	ffffe097          	auipc	ra,0xffffe
    800058ec:	37e080e7          	jalr	894(ra) # 80003c66 <iunlockput>
  end_op();
    800058f0:	fffff097          	auipc	ra,0xfffff
    800058f4:	b56080e7          	jalr	-1194(ra) # 80004446 <end_op>
  return 0;
    800058f8:	4501                	li	a0,0
    800058fa:	a84d                	j	800059ac <sys_unlink+0x1c4>
    end_op();
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	b4a080e7          	jalr	-1206(ra) # 80004446 <end_op>
    return -1;
    80005904:	557d                	li	a0,-1
    80005906:	a05d                	j	800059ac <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005908:	00003517          	auipc	a0,0x3
    8000590c:	e9050513          	addi	a0,a0,-368 # 80008798 <syscalls+0x2b0>
    80005910:	ffffb097          	auipc	ra,0xffffb
    80005914:	c2e080e7          	jalr	-978(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005918:	04c92703          	lw	a4,76(s2)
    8000591c:	02000793          	li	a5,32
    80005920:	f6e7f9e3          	bgeu	a5,a4,80005892 <sys_unlink+0xaa>
    80005924:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005928:	4741                	li	a4,16
    8000592a:	86ce                	mv	a3,s3
    8000592c:	f1840613          	addi	a2,s0,-232
    80005930:	4581                	li	a1,0
    80005932:	854a                	mv	a0,s2
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	384080e7          	jalr	900(ra) # 80003cb8 <readi>
    8000593c:	47c1                	li	a5,16
    8000593e:	00f51b63          	bne	a0,a5,80005954 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005942:	f1845783          	lhu	a5,-232(s0)
    80005946:	e7a1                	bnez	a5,8000598e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005948:	29c1                	addiw	s3,s3,16
    8000594a:	04c92783          	lw	a5,76(s2)
    8000594e:	fcf9ede3          	bltu	s3,a5,80005928 <sys_unlink+0x140>
    80005952:	b781                	j	80005892 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005954:	00003517          	auipc	a0,0x3
    80005958:	e5c50513          	addi	a0,a0,-420 # 800087b0 <syscalls+0x2c8>
    8000595c:	ffffb097          	auipc	ra,0xffffb
    80005960:	be2080e7          	jalr	-1054(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005964:	00003517          	auipc	a0,0x3
    80005968:	e6450513          	addi	a0,a0,-412 # 800087c8 <syscalls+0x2e0>
    8000596c:	ffffb097          	auipc	ra,0xffffb
    80005970:	bd2080e7          	jalr	-1070(ra) # 8000053e <panic>
    dp->nlink--;
    80005974:	04a4d783          	lhu	a5,74(s1)
    80005978:	37fd                	addiw	a5,a5,-1
    8000597a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000597e:	8526                	mv	a0,s1
    80005980:	ffffe097          	auipc	ra,0xffffe
    80005984:	fba080e7          	jalr	-70(ra) # 8000393a <iupdate>
    80005988:	b781                	j	800058c8 <sys_unlink+0xe0>
    return -1;
    8000598a:	557d                	li	a0,-1
    8000598c:	a005                	j	800059ac <sys_unlink+0x1c4>
    iunlockput(ip);
    8000598e:	854a                	mv	a0,s2
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	2d6080e7          	jalr	726(ra) # 80003c66 <iunlockput>
  iunlockput(dp);
    80005998:	8526                	mv	a0,s1
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	2cc080e7          	jalr	716(ra) # 80003c66 <iunlockput>
  end_op();
    800059a2:	fffff097          	auipc	ra,0xfffff
    800059a6:	aa4080e7          	jalr	-1372(ra) # 80004446 <end_op>
  return -1;
    800059aa:	557d                	li	a0,-1
}
    800059ac:	70ae                	ld	ra,232(sp)
    800059ae:	740e                	ld	s0,224(sp)
    800059b0:	64ee                	ld	s1,216(sp)
    800059b2:	694e                	ld	s2,208(sp)
    800059b4:	69ae                	ld	s3,200(sp)
    800059b6:	616d                	addi	sp,sp,240
    800059b8:	8082                	ret

00000000800059ba <sys_open>:

uint64
sys_open(void)
{
    800059ba:	7131                	addi	sp,sp,-192
    800059bc:	fd06                	sd	ra,184(sp)
    800059be:	f922                	sd	s0,176(sp)
    800059c0:	f526                	sd	s1,168(sp)
    800059c2:	f14a                	sd	s2,160(sp)
    800059c4:	ed4e                	sd	s3,152(sp)
    800059c6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800059c8:	f4c40593          	addi	a1,s0,-180
    800059cc:	4505                	li	a0,1
    800059ce:	ffffd097          	auipc	ra,0xffffd
    800059d2:	4ba080e7          	jalr	1210(ra) # 80002e88 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059d6:	08000613          	li	a2,128
    800059da:	f5040593          	addi	a1,s0,-176
    800059de:	4501                	li	a0,0
    800059e0:	ffffd097          	auipc	ra,0xffffd
    800059e4:	4e8080e7          	jalr	1256(ra) # 80002ec8 <argstr>
    800059e8:	87aa                	mv	a5,a0
    return -1;
    800059ea:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059ec:	0a07c963          	bltz	a5,80005a9e <sys_open+0xe4>

  begin_op();
    800059f0:	fffff097          	auipc	ra,0xfffff
    800059f4:	9d6080e7          	jalr	-1578(ra) # 800043c6 <begin_op>

  if(omode & O_CREATE){
    800059f8:	f4c42783          	lw	a5,-180(s0)
    800059fc:	2007f793          	andi	a5,a5,512
    80005a00:	cfc5                	beqz	a5,80005ab8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a02:	4681                	li	a3,0
    80005a04:	4601                	li	a2,0
    80005a06:	4589                	li	a1,2
    80005a08:	f5040513          	addi	a0,s0,-176
    80005a0c:	00000097          	auipc	ra,0x0
    80005a10:	974080e7          	jalr	-1676(ra) # 80005380 <create>
    80005a14:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a16:	c959                	beqz	a0,80005aac <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a18:	04449703          	lh	a4,68(s1)
    80005a1c:	478d                	li	a5,3
    80005a1e:	00f71763          	bne	a4,a5,80005a2c <sys_open+0x72>
    80005a22:	0464d703          	lhu	a4,70(s1)
    80005a26:	47a5                	li	a5,9
    80005a28:	0ce7ed63          	bltu	a5,a4,80005b02 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	daa080e7          	jalr	-598(ra) # 800047d6 <filealloc>
    80005a34:	89aa                	mv	s3,a0
    80005a36:	10050363          	beqz	a0,80005b3c <sys_open+0x182>
    80005a3a:	00000097          	auipc	ra,0x0
    80005a3e:	904080e7          	jalr	-1788(ra) # 8000533e <fdalloc>
    80005a42:	892a                	mv	s2,a0
    80005a44:	0e054763          	bltz	a0,80005b32 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a48:	04449703          	lh	a4,68(s1)
    80005a4c:	478d                	li	a5,3
    80005a4e:	0cf70563          	beq	a4,a5,80005b18 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a52:	4789                	li	a5,2
    80005a54:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a58:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a5c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a60:	f4c42783          	lw	a5,-180(s0)
    80005a64:	0017c713          	xori	a4,a5,1
    80005a68:	8b05                	andi	a4,a4,1
    80005a6a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a6e:	0037f713          	andi	a4,a5,3
    80005a72:	00e03733          	snez	a4,a4
    80005a76:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a7a:	4007f793          	andi	a5,a5,1024
    80005a7e:	c791                	beqz	a5,80005a8a <sys_open+0xd0>
    80005a80:	04449703          	lh	a4,68(s1)
    80005a84:	4789                	li	a5,2
    80005a86:	0af70063          	beq	a4,a5,80005b26 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a8a:	8526                	mv	a0,s1
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	03a080e7          	jalr	58(ra) # 80003ac6 <iunlock>
  end_op();
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	9b2080e7          	jalr	-1614(ra) # 80004446 <end_op>

  return fd;
    80005a9c:	854a                	mv	a0,s2
}
    80005a9e:	70ea                	ld	ra,184(sp)
    80005aa0:	744a                	ld	s0,176(sp)
    80005aa2:	74aa                	ld	s1,168(sp)
    80005aa4:	790a                	ld	s2,160(sp)
    80005aa6:	69ea                	ld	s3,152(sp)
    80005aa8:	6129                	addi	sp,sp,192
    80005aaa:	8082                	ret
      end_op();
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	99a080e7          	jalr	-1638(ra) # 80004446 <end_op>
      return -1;
    80005ab4:	557d                	li	a0,-1
    80005ab6:	b7e5                	j	80005a9e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005ab8:	f5040513          	addi	a0,s0,-176
    80005abc:	ffffe097          	auipc	ra,0xffffe
    80005ac0:	6ee080e7          	jalr	1774(ra) # 800041aa <namei>
    80005ac4:	84aa                	mv	s1,a0
    80005ac6:	c905                	beqz	a0,80005af6 <sys_open+0x13c>
    ilock(ip);
    80005ac8:	ffffe097          	auipc	ra,0xffffe
    80005acc:	f3c080e7          	jalr	-196(ra) # 80003a04 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ad0:	04449703          	lh	a4,68(s1)
    80005ad4:	4785                	li	a5,1
    80005ad6:	f4f711e3          	bne	a4,a5,80005a18 <sys_open+0x5e>
    80005ada:	f4c42783          	lw	a5,-180(s0)
    80005ade:	d7b9                	beqz	a5,80005a2c <sys_open+0x72>
      iunlockput(ip);
    80005ae0:	8526                	mv	a0,s1
    80005ae2:	ffffe097          	auipc	ra,0xffffe
    80005ae6:	184080e7          	jalr	388(ra) # 80003c66 <iunlockput>
      end_op();
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	95c080e7          	jalr	-1700(ra) # 80004446 <end_op>
      return -1;
    80005af2:	557d                	li	a0,-1
    80005af4:	b76d                	j	80005a9e <sys_open+0xe4>
      end_op();
    80005af6:	fffff097          	auipc	ra,0xfffff
    80005afa:	950080e7          	jalr	-1712(ra) # 80004446 <end_op>
      return -1;
    80005afe:	557d                	li	a0,-1
    80005b00:	bf79                	j	80005a9e <sys_open+0xe4>
    iunlockput(ip);
    80005b02:	8526                	mv	a0,s1
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	162080e7          	jalr	354(ra) # 80003c66 <iunlockput>
    end_op();
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	93a080e7          	jalr	-1734(ra) # 80004446 <end_op>
    return -1;
    80005b14:	557d                	li	a0,-1
    80005b16:	b761                	j	80005a9e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b18:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b1c:	04649783          	lh	a5,70(s1)
    80005b20:	02f99223          	sh	a5,36(s3)
    80005b24:	bf25                	j	80005a5c <sys_open+0xa2>
    itrunc(ip);
    80005b26:	8526                	mv	a0,s1
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	fea080e7          	jalr	-22(ra) # 80003b12 <itrunc>
    80005b30:	bfa9                	j	80005a8a <sys_open+0xd0>
      fileclose(f);
    80005b32:	854e                	mv	a0,s3
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	d5e080e7          	jalr	-674(ra) # 80004892 <fileclose>
    iunlockput(ip);
    80005b3c:	8526                	mv	a0,s1
    80005b3e:	ffffe097          	auipc	ra,0xffffe
    80005b42:	128080e7          	jalr	296(ra) # 80003c66 <iunlockput>
    end_op();
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	900080e7          	jalr	-1792(ra) # 80004446 <end_op>
    return -1;
    80005b4e:	557d                	li	a0,-1
    80005b50:	b7b9                	j	80005a9e <sys_open+0xe4>

0000000080005b52 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b52:	7175                	addi	sp,sp,-144
    80005b54:	e506                	sd	ra,136(sp)
    80005b56:	e122                	sd	s0,128(sp)
    80005b58:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	86c080e7          	jalr	-1940(ra) # 800043c6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b62:	08000613          	li	a2,128
    80005b66:	f7040593          	addi	a1,s0,-144
    80005b6a:	4501                	li	a0,0
    80005b6c:	ffffd097          	auipc	ra,0xffffd
    80005b70:	35c080e7          	jalr	860(ra) # 80002ec8 <argstr>
    80005b74:	02054963          	bltz	a0,80005ba6 <sys_mkdir+0x54>
    80005b78:	4681                	li	a3,0
    80005b7a:	4601                	li	a2,0
    80005b7c:	4585                	li	a1,1
    80005b7e:	f7040513          	addi	a0,s0,-144
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	7fe080e7          	jalr	2046(ra) # 80005380 <create>
    80005b8a:	cd11                	beqz	a0,80005ba6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	0da080e7          	jalr	218(ra) # 80003c66 <iunlockput>
  end_op();
    80005b94:	fffff097          	auipc	ra,0xfffff
    80005b98:	8b2080e7          	jalr	-1870(ra) # 80004446 <end_op>
  return 0;
    80005b9c:	4501                	li	a0,0
}
    80005b9e:	60aa                	ld	ra,136(sp)
    80005ba0:	640a                	ld	s0,128(sp)
    80005ba2:	6149                	addi	sp,sp,144
    80005ba4:	8082                	ret
    end_op();
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	8a0080e7          	jalr	-1888(ra) # 80004446 <end_op>
    return -1;
    80005bae:	557d                	li	a0,-1
    80005bb0:	b7fd                	j	80005b9e <sys_mkdir+0x4c>

0000000080005bb2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005bb2:	7135                	addi	sp,sp,-160
    80005bb4:	ed06                	sd	ra,152(sp)
    80005bb6:	e922                	sd	s0,144(sp)
    80005bb8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	80c080e7          	jalr	-2036(ra) # 800043c6 <begin_op>
  argint(1, &major);
    80005bc2:	f6c40593          	addi	a1,s0,-148
    80005bc6:	4505                	li	a0,1
    80005bc8:	ffffd097          	auipc	ra,0xffffd
    80005bcc:	2c0080e7          	jalr	704(ra) # 80002e88 <argint>
  argint(2, &minor);
    80005bd0:	f6840593          	addi	a1,s0,-152
    80005bd4:	4509                	li	a0,2
    80005bd6:	ffffd097          	auipc	ra,0xffffd
    80005bda:	2b2080e7          	jalr	690(ra) # 80002e88 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bde:	08000613          	li	a2,128
    80005be2:	f7040593          	addi	a1,s0,-144
    80005be6:	4501                	li	a0,0
    80005be8:	ffffd097          	auipc	ra,0xffffd
    80005bec:	2e0080e7          	jalr	736(ra) # 80002ec8 <argstr>
    80005bf0:	02054b63          	bltz	a0,80005c26 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005bf4:	f6841683          	lh	a3,-152(s0)
    80005bf8:	f6c41603          	lh	a2,-148(s0)
    80005bfc:	458d                	li	a1,3
    80005bfe:	f7040513          	addi	a0,s0,-144
    80005c02:	fffff097          	auipc	ra,0xfffff
    80005c06:	77e080e7          	jalr	1918(ra) # 80005380 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c0a:	cd11                	beqz	a0,80005c26 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c0c:	ffffe097          	auipc	ra,0xffffe
    80005c10:	05a080e7          	jalr	90(ra) # 80003c66 <iunlockput>
  end_op();
    80005c14:	fffff097          	auipc	ra,0xfffff
    80005c18:	832080e7          	jalr	-1998(ra) # 80004446 <end_op>
  return 0;
    80005c1c:	4501                	li	a0,0
}
    80005c1e:	60ea                	ld	ra,152(sp)
    80005c20:	644a                	ld	s0,144(sp)
    80005c22:	610d                	addi	sp,sp,160
    80005c24:	8082                	ret
    end_op();
    80005c26:	fffff097          	auipc	ra,0xfffff
    80005c2a:	820080e7          	jalr	-2016(ra) # 80004446 <end_op>
    return -1;
    80005c2e:	557d                	li	a0,-1
    80005c30:	b7fd                	j	80005c1e <sys_mknod+0x6c>

0000000080005c32 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c32:	7135                	addi	sp,sp,-160
    80005c34:	ed06                	sd	ra,152(sp)
    80005c36:	e922                	sd	s0,144(sp)
    80005c38:	e526                	sd	s1,136(sp)
    80005c3a:	e14a                	sd	s2,128(sp)
    80005c3c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c3e:	ffffc097          	auipc	ra,0xffffc
    80005c42:	d42080e7          	jalr	-702(ra) # 80001980 <myproc>
    80005c46:	892a                	mv	s2,a0
  
  begin_op();
    80005c48:	ffffe097          	auipc	ra,0xffffe
    80005c4c:	77e080e7          	jalr	1918(ra) # 800043c6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c50:	08000613          	li	a2,128
    80005c54:	f6040593          	addi	a1,s0,-160
    80005c58:	4501                	li	a0,0
    80005c5a:	ffffd097          	auipc	ra,0xffffd
    80005c5e:	26e080e7          	jalr	622(ra) # 80002ec8 <argstr>
    80005c62:	04054b63          	bltz	a0,80005cb8 <sys_chdir+0x86>
    80005c66:	f6040513          	addi	a0,s0,-160
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	540080e7          	jalr	1344(ra) # 800041aa <namei>
    80005c72:	84aa                	mv	s1,a0
    80005c74:	c131                	beqz	a0,80005cb8 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	d8e080e7          	jalr	-626(ra) # 80003a04 <ilock>
  if(ip->type != T_DIR){
    80005c7e:	04449703          	lh	a4,68(s1)
    80005c82:	4785                	li	a5,1
    80005c84:	04f71063          	bne	a4,a5,80005cc4 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c88:	8526                	mv	a0,s1
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	e3c080e7          	jalr	-452(ra) # 80003ac6 <iunlock>
  iput(p->cwd);
    80005c92:	18893503          	ld	a0,392(s2)
    80005c96:	ffffe097          	auipc	ra,0xffffe
    80005c9a:	f28080e7          	jalr	-216(ra) # 80003bbe <iput>
  end_op();
    80005c9e:	ffffe097          	auipc	ra,0xffffe
    80005ca2:	7a8080e7          	jalr	1960(ra) # 80004446 <end_op>
  p->cwd = ip;
    80005ca6:	18993423          	sd	s1,392(s2)
  return 0;
    80005caa:	4501                	li	a0,0
}
    80005cac:	60ea                	ld	ra,152(sp)
    80005cae:	644a                	ld	s0,144(sp)
    80005cb0:	64aa                	ld	s1,136(sp)
    80005cb2:	690a                	ld	s2,128(sp)
    80005cb4:	610d                	addi	sp,sp,160
    80005cb6:	8082                	ret
    end_op();
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	78e080e7          	jalr	1934(ra) # 80004446 <end_op>
    return -1;
    80005cc0:	557d                	li	a0,-1
    80005cc2:	b7ed                	j	80005cac <sys_chdir+0x7a>
    iunlockput(ip);
    80005cc4:	8526                	mv	a0,s1
    80005cc6:	ffffe097          	auipc	ra,0xffffe
    80005cca:	fa0080e7          	jalr	-96(ra) # 80003c66 <iunlockput>
    end_op();
    80005cce:	ffffe097          	auipc	ra,0xffffe
    80005cd2:	778080e7          	jalr	1912(ra) # 80004446 <end_op>
    return -1;
    80005cd6:	557d                	li	a0,-1
    80005cd8:	bfd1                	j	80005cac <sys_chdir+0x7a>

0000000080005cda <sys_exec>:

uint64
sys_exec(void)
{
    80005cda:	7145                	addi	sp,sp,-464
    80005cdc:	e786                	sd	ra,456(sp)
    80005cde:	e3a2                	sd	s0,448(sp)
    80005ce0:	ff26                	sd	s1,440(sp)
    80005ce2:	fb4a                	sd	s2,432(sp)
    80005ce4:	f74e                	sd	s3,424(sp)
    80005ce6:	f352                	sd	s4,416(sp)
    80005ce8:	ef56                	sd	s5,408(sp)
    80005cea:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cec:	e3840593          	addi	a1,s0,-456
    80005cf0:	4505                	li	a0,1
    80005cf2:	ffffd097          	auipc	ra,0xffffd
    80005cf6:	1b6080e7          	jalr	438(ra) # 80002ea8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005cfa:	08000613          	li	a2,128
    80005cfe:	f4040593          	addi	a1,s0,-192
    80005d02:	4501                	li	a0,0
    80005d04:	ffffd097          	auipc	ra,0xffffd
    80005d08:	1c4080e7          	jalr	452(ra) # 80002ec8 <argstr>
    80005d0c:	87aa                	mv	a5,a0
    return -1;
    80005d0e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d10:	0c07c263          	bltz	a5,80005dd4 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005d14:	10000613          	li	a2,256
    80005d18:	4581                	li	a1,0
    80005d1a:	e4040513          	addi	a0,s0,-448
    80005d1e:	ffffb097          	auipc	ra,0xffffb
    80005d22:	fb4080e7          	jalr	-76(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d26:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d2a:	89a6                	mv	s3,s1
    80005d2c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d2e:	02000a13          	li	s4,32
    80005d32:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d36:	00391793          	slli	a5,s2,0x3
    80005d3a:	e3040593          	addi	a1,s0,-464
    80005d3e:	e3843503          	ld	a0,-456(s0)
    80005d42:	953e                	add	a0,a0,a5
    80005d44:	ffffd097          	auipc	ra,0xffffd
    80005d48:	0a2080e7          	jalr	162(ra) # 80002de6 <fetchaddr>
    80005d4c:	02054a63          	bltz	a0,80005d80 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005d50:	e3043783          	ld	a5,-464(s0)
    80005d54:	c3b9                	beqz	a5,80005d9a <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d56:	ffffb097          	auipc	ra,0xffffb
    80005d5a:	d90080e7          	jalr	-624(ra) # 80000ae6 <kalloc>
    80005d5e:	85aa                	mv	a1,a0
    80005d60:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d64:	cd11                	beqz	a0,80005d80 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d66:	6605                	lui	a2,0x1
    80005d68:	e3043503          	ld	a0,-464(s0)
    80005d6c:	ffffd097          	auipc	ra,0xffffd
    80005d70:	0ce080e7          	jalr	206(ra) # 80002e3a <fetchstr>
    80005d74:	00054663          	bltz	a0,80005d80 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005d78:	0905                	addi	s2,s2,1
    80005d7a:	09a1                	addi	s3,s3,8
    80005d7c:	fb491be3          	bne	s2,s4,80005d32 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d80:	10048913          	addi	s2,s1,256
    80005d84:	6088                	ld	a0,0(s1)
    80005d86:	c531                	beqz	a0,80005dd2 <sys_exec+0xf8>
    kfree(argv[i]);
    80005d88:	ffffb097          	auipc	ra,0xffffb
    80005d8c:	c62080e7          	jalr	-926(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d90:	04a1                	addi	s1,s1,8
    80005d92:	ff2499e3          	bne	s1,s2,80005d84 <sys_exec+0xaa>
  return -1;
    80005d96:	557d                	li	a0,-1
    80005d98:	a835                	j	80005dd4 <sys_exec+0xfa>
      argv[i] = 0;
    80005d9a:	0a8e                	slli	s5,s5,0x3
    80005d9c:	fc040793          	addi	a5,s0,-64
    80005da0:	9abe                	add	s5,s5,a5
    80005da2:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005da6:	e4040593          	addi	a1,s0,-448
    80005daa:	f4040513          	addi	a0,s0,-192
    80005dae:	fffff097          	auipc	ra,0xfffff
    80005db2:	15e080e7          	jalr	350(ra) # 80004f0c <exec>
    80005db6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005db8:	10048993          	addi	s3,s1,256
    80005dbc:	6088                	ld	a0,0(s1)
    80005dbe:	c901                	beqz	a0,80005dce <sys_exec+0xf4>
    kfree(argv[i]);
    80005dc0:	ffffb097          	auipc	ra,0xffffb
    80005dc4:	c2a080e7          	jalr	-982(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dc8:	04a1                	addi	s1,s1,8
    80005dca:	ff3499e3          	bne	s1,s3,80005dbc <sys_exec+0xe2>
  return ret;
    80005dce:	854a                	mv	a0,s2
    80005dd0:	a011                	j	80005dd4 <sys_exec+0xfa>
  return -1;
    80005dd2:	557d                	li	a0,-1
}
    80005dd4:	60be                	ld	ra,456(sp)
    80005dd6:	641e                	ld	s0,448(sp)
    80005dd8:	74fa                	ld	s1,440(sp)
    80005dda:	795a                	ld	s2,432(sp)
    80005ddc:	79ba                	ld	s3,424(sp)
    80005dde:	7a1a                	ld	s4,416(sp)
    80005de0:	6afa                	ld	s5,408(sp)
    80005de2:	6179                	addi	sp,sp,464
    80005de4:	8082                	ret

0000000080005de6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005de6:	7139                	addi	sp,sp,-64
    80005de8:	fc06                	sd	ra,56(sp)
    80005dea:	f822                	sd	s0,48(sp)
    80005dec:	f426                	sd	s1,40(sp)
    80005dee:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005df0:	ffffc097          	auipc	ra,0xffffc
    80005df4:	b90080e7          	jalr	-1136(ra) # 80001980 <myproc>
    80005df8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005dfa:	fd840593          	addi	a1,s0,-40
    80005dfe:	4501                	li	a0,0
    80005e00:	ffffd097          	auipc	ra,0xffffd
    80005e04:	0a8080e7          	jalr	168(ra) # 80002ea8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005e08:	fc840593          	addi	a1,s0,-56
    80005e0c:	fd040513          	addi	a0,s0,-48
    80005e10:	fffff097          	auipc	ra,0xfffff
    80005e14:	db2080e7          	jalr	-590(ra) # 80004bc2 <pipealloc>
    return -1;
    80005e18:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e1a:	0c054963          	bltz	a0,80005eec <sys_pipe+0x106>
  fd0 = -1;
    80005e1e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e22:	fd043503          	ld	a0,-48(s0)
    80005e26:	fffff097          	auipc	ra,0xfffff
    80005e2a:	518080e7          	jalr	1304(ra) # 8000533e <fdalloc>
    80005e2e:	fca42223          	sw	a0,-60(s0)
    80005e32:	0a054063          	bltz	a0,80005ed2 <sys_pipe+0xec>
    80005e36:	fc843503          	ld	a0,-56(s0)
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	504080e7          	jalr	1284(ra) # 8000533e <fdalloc>
    80005e42:	fca42023          	sw	a0,-64(s0)
    80005e46:	06054c63          	bltz	a0,80005ebe <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e4a:	4691                	li	a3,4
    80005e4c:	fc440613          	addi	a2,s0,-60
    80005e50:	fd843583          	ld	a1,-40(s0)
    80005e54:	1004b503          	ld	a0,256(s1)
    80005e58:	ffffc097          	auipc	ra,0xffffc
    80005e5c:	810080e7          	jalr	-2032(ra) # 80001668 <copyout>
    80005e60:	02054163          	bltz	a0,80005e82 <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e64:	4691                	li	a3,4
    80005e66:	fc040613          	addi	a2,s0,-64
    80005e6a:	fd843583          	ld	a1,-40(s0)
    80005e6e:	0591                	addi	a1,a1,4
    80005e70:	1004b503          	ld	a0,256(s1)
    80005e74:	ffffb097          	auipc	ra,0xffffb
    80005e78:	7f4080e7          	jalr	2036(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e7c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e7e:	06055763          	bgez	a0,80005eec <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80005e82:	fc442783          	lw	a5,-60(s0)
    80005e86:	02078793          	addi	a5,a5,32
    80005e8a:	078e                	slli	a5,a5,0x3
    80005e8c:	97a6                	add	a5,a5,s1
    80005e8e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e92:	fc042503          	lw	a0,-64(s0)
    80005e96:	02050513          	addi	a0,a0,32
    80005e9a:	050e                	slli	a0,a0,0x3
    80005e9c:	94aa                	add	s1,s1,a0
    80005e9e:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005ea2:	fd043503          	ld	a0,-48(s0)
    80005ea6:	fffff097          	auipc	ra,0xfffff
    80005eaa:	9ec080e7          	jalr	-1556(ra) # 80004892 <fileclose>
    fileclose(wf);
    80005eae:	fc843503          	ld	a0,-56(s0)
    80005eb2:	fffff097          	auipc	ra,0xfffff
    80005eb6:	9e0080e7          	jalr	-1568(ra) # 80004892 <fileclose>
    return -1;
    80005eba:	57fd                	li	a5,-1
    80005ebc:	a805                	j	80005eec <sys_pipe+0x106>
    if(fd0 >= 0)
    80005ebe:	fc442783          	lw	a5,-60(s0)
    80005ec2:	0007c863          	bltz	a5,80005ed2 <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80005ec6:	02078793          	addi	a5,a5,32
    80005eca:	078e                	slli	a5,a5,0x3
    80005ecc:	94be                	add	s1,s1,a5
    80005ece:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005ed2:	fd043503          	ld	a0,-48(s0)
    80005ed6:	fffff097          	auipc	ra,0xfffff
    80005eda:	9bc080e7          	jalr	-1604(ra) # 80004892 <fileclose>
    fileclose(wf);
    80005ede:	fc843503          	ld	a0,-56(s0)
    80005ee2:	fffff097          	auipc	ra,0xfffff
    80005ee6:	9b0080e7          	jalr	-1616(ra) # 80004892 <fileclose>
    return -1;
    80005eea:	57fd                	li	a5,-1
}
    80005eec:	853e                	mv	a0,a5
    80005eee:	70e2                	ld	ra,56(sp)
    80005ef0:	7442                	ld	s0,48(sp)
    80005ef2:	74a2                	ld	s1,40(sp)
    80005ef4:	6121                	addi	sp,sp,64
    80005ef6:	8082                	ret
	...

0000000080005f00 <kernelvec>:
    80005f00:	7111                	addi	sp,sp,-256
    80005f02:	e006                	sd	ra,0(sp)
    80005f04:	e40a                	sd	sp,8(sp)
    80005f06:	e80e                	sd	gp,16(sp)
    80005f08:	ec12                	sd	tp,24(sp)
    80005f0a:	f016                	sd	t0,32(sp)
    80005f0c:	f41a                	sd	t1,40(sp)
    80005f0e:	f81e                	sd	t2,48(sp)
    80005f10:	fc22                	sd	s0,56(sp)
    80005f12:	e0a6                	sd	s1,64(sp)
    80005f14:	e4aa                	sd	a0,72(sp)
    80005f16:	e8ae                	sd	a1,80(sp)
    80005f18:	ecb2                	sd	a2,88(sp)
    80005f1a:	f0b6                	sd	a3,96(sp)
    80005f1c:	f4ba                	sd	a4,104(sp)
    80005f1e:	f8be                	sd	a5,112(sp)
    80005f20:	fcc2                	sd	a6,120(sp)
    80005f22:	e146                	sd	a7,128(sp)
    80005f24:	e54a                	sd	s2,136(sp)
    80005f26:	e94e                	sd	s3,144(sp)
    80005f28:	ed52                	sd	s4,152(sp)
    80005f2a:	f156                	sd	s5,160(sp)
    80005f2c:	f55a                	sd	s6,168(sp)
    80005f2e:	f95e                	sd	s7,176(sp)
    80005f30:	fd62                	sd	s8,184(sp)
    80005f32:	e1e6                	sd	s9,192(sp)
    80005f34:	e5ea                	sd	s10,200(sp)
    80005f36:	e9ee                	sd	s11,208(sp)
    80005f38:	edf2                	sd	t3,216(sp)
    80005f3a:	f1f6                	sd	t4,224(sp)
    80005f3c:	f5fa                	sd	t5,232(sp)
    80005f3e:	f9fe                	sd	t6,240(sp)
    80005f40:	d73fc0ef          	jal	ra,80002cb2 <kerneltrap>
    80005f44:	6082                	ld	ra,0(sp)
    80005f46:	6122                	ld	sp,8(sp)
    80005f48:	61c2                	ld	gp,16(sp)
    80005f4a:	7282                	ld	t0,32(sp)
    80005f4c:	7322                	ld	t1,40(sp)
    80005f4e:	73c2                	ld	t2,48(sp)
    80005f50:	7462                	ld	s0,56(sp)
    80005f52:	6486                	ld	s1,64(sp)
    80005f54:	6526                	ld	a0,72(sp)
    80005f56:	65c6                	ld	a1,80(sp)
    80005f58:	6666                	ld	a2,88(sp)
    80005f5a:	7686                	ld	a3,96(sp)
    80005f5c:	7726                	ld	a4,104(sp)
    80005f5e:	77c6                	ld	a5,112(sp)
    80005f60:	7866                	ld	a6,120(sp)
    80005f62:	688a                	ld	a7,128(sp)
    80005f64:	692a                	ld	s2,136(sp)
    80005f66:	69ca                	ld	s3,144(sp)
    80005f68:	6a6a                	ld	s4,152(sp)
    80005f6a:	7a8a                	ld	s5,160(sp)
    80005f6c:	7b2a                	ld	s6,168(sp)
    80005f6e:	7bca                	ld	s7,176(sp)
    80005f70:	7c6a                	ld	s8,184(sp)
    80005f72:	6c8e                	ld	s9,192(sp)
    80005f74:	6d2e                	ld	s10,200(sp)
    80005f76:	6dce                	ld	s11,208(sp)
    80005f78:	6e6e                	ld	t3,216(sp)
    80005f7a:	7e8e                	ld	t4,224(sp)
    80005f7c:	7f2e                	ld	t5,232(sp)
    80005f7e:	7fce                	ld	t6,240(sp)
    80005f80:	6111                	addi	sp,sp,256
    80005f82:	10200073          	sret
    80005f86:	00000013          	nop
    80005f8a:	00000013          	nop
    80005f8e:	0001                	nop

0000000080005f90 <timervec>:
    80005f90:	34051573          	csrrw	a0,mscratch,a0
    80005f94:	e10c                	sd	a1,0(a0)
    80005f96:	e510                	sd	a2,8(a0)
    80005f98:	e914                	sd	a3,16(a0)
    80005f9a:	6d0c                	ld	a1,24(a0)
    80005f9c:	7110                	ld	a2,32(a0)
    80005f9e:	6194                	ld	a3,0(a1)
    80005fa0:	96b2                	add	a3,a3,a2
    80005fa2:	e194                	sd	a3,0(a1)
    80005fa4:	4589                	li	a1,2
    80005fa6:	14459073          	csrw	sip,a1
    80005faa:	6914                	ld	a3,16(a0)
    80005fac:	6510                	ld	a2,8(a0)
    80005fae:	610c                	ld	a1,0(a0)
    80005fb0:	34051573          	csrrw	a0,mscratch,a0
    80005fb4:	30200073          	mret
	...

0000000080005fba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005fba:	1141                	addi	sp,sp,-16
    80005fbc:	e422                	sd	s0,8(sp)
    80005fbe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fc0:	0c0007b7          	lui	a5,0xc000
    80005fc4:	4705                	li	a4,1
    80005fc6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fc8:	c3d8                	sw	a4,4(a5)
}
    80005fca:	6422                	ld	s0,8(sp)
    80005fcc:	0141                	addi	sp,sp,16
    80005fce:	8082                	ret

0000000080005fd0 <plicinithart>:

void
plicinithart(void)
{
    80005fd0:	1141                	addi	sp,sp,-16
    80005fd2:	e406                	sd	ra,8(sp)
    80005fd4:	e022                	sd	s0,0(sp)
    80005fd6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fd8:	ffffc097          	auipc	ra,0xffffc
    80005fdc:	97c080e7          	jalr	-1668(ra) # 80001954 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fe0:	0085171b          	slliw	a4,a0,0x8
    80005fe4:	0c0027b7          	lui	a5,0xc002
    80005fe8:	97ba                	add	a5,a5,a4
    80005fea:	40200713          	li	a4,1026
    80005fee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ff2:	00d5151b          	slliw	a0,a0,0xd
    80005ff6:	0c2017b7          	lui	a5,0xc201
    80005ffa:	953e                	add	a0,a0,a5
    80005ffc:	00052023          	sw	zero,0(a0)
}
    80006000:	60a2                	ld	ra,8(sp)
    80006002:	6402                	ld	s0,0(sp)
    80006004:	0141                	addi	sp,sp,16
    80006006:	8082                	ret

0000000080006008 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006008:	1141                	addi	sp,sp,-16
    8000600a:	e406                	sd	ra,8(sp)
    8000600c:	e022                	sd	s0,0(sp)
    8000600e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006010:	ffffc097          	auipc	ra,0xffffc
    80006014:	944080e7          	jalr	-1724(ra) # 80001954 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006018:	00d5179b          	slliw	a5,a0,0xd
    8000601c:	0c201537          	lui	a0,0xc201
    80006020:	953e                	add	a0,a0,a5
  return irq;
}
    80006022:	4148                	lw	a0,4(a0)
    80006024:	60a2                	ld	ra,8(sp)
    80006026:	6402                	ld	s0,0(sp)
    80006028:	0141                	addi	sp,sp,16
    8000602a:	8082                	ret

000000008000602c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000602c:	1101                	addi	sp,sp,-32
    8000602e:	ec06                	sd	ra,24(sp)
    80006030:	e822                	sd	s0,16(sp)
    80006032:	e426                	sd	s1,8(sp)
    80006034:	1000                	addi	s0,sp,32
    80006036:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006038:	ffffc097          	auipc	ra,0xffffc
    8000603c:	91c080e7          	jalr	-1764(ra) # 80001954 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006040:	00d5151b          	slliw	a0,a0,0xd
    80006044:	0c2017b7          	lui	a5,0xc201
    80006048:	97aa                	add	a5,a5,a0
    8000604a:	c3c4                	sw	s1,4(a5)
}
    8000604c:	60e2                	ld	ra,24(sp)
    8000604e:	6442                	ld	s0,16(sp)
    80006050:	64a2                	ld	s1,8(sp)
    80006052:	6105                	addi	sp,sp,32
    80006054:	8082                	ret

0000000080006056 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006056:	1141                	addi	sp,sp,-16
    80006058:	e406                	sd	ra,8(sp)
    8000605a:	e022                	sd	s0,0(sp)
    8000605c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000605e:	479d                	li	a5,7
    80006060:	04a7cc63          	blt	a5,a0,800060b8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006064:	0001d797          	auipc	a5,0x1d
    80006068:	25c78793          	addi	a5,a5,604 # 800232c0 <disk>
    8000606c:	97aa                	add	a5,a5,a0
    8000606e:	0187c783          	lbu	a5,24(a5)
    80006072:	ebb9                	bnez	a5,800060c8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006074:	00451613          	slli	a2,a0,0x4
    80006078:	0001d797          	auipc	a5,0x1d
    8000607c:	24878793          	addi	a5,a5,584 # 800232c0 <disk>
    80006080:	6394                	ld	a3,0(a5)
    80006082:	96b2                	add	a3,a3,a2
    80006084:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006088:	6398                	ld	a4,0(a5)
    8000608a:	9732                	add	a4,a4,a2
    8000608c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006090:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006094:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006098:	953e                	add	a0,a0,a5
    8000609a:	4785                	li	a5,1
    8000609c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800060a0:	0001d517          	auipc	a0,0x1d
    800060a4:	23850513          	addi	a0,a0,568 # 800232d8 <disk+0x18>
    800060a8:	ffffc097          	auipc	ra,0xffffc
    800060ac:	112080e7          	jalr	274(ra) # 800021ba <wakeup>
}
    800060b0:	60a2                	ld	ra,8(sp)
    800060b2:	6402                	ld	s0,0(sp)
    800060b4:	0141                	addi	sp,sp,16
    800060b6:	8082                	ret
    panic("free_desc 1");
    800060b8:	00002517          	auipc	a0,0x2
    800060bc:	72050513          	addi	a0,a0,1824 # 800087d8 <syscalls+0x2f0>
    800060c0:	ffffa097          	auipc	ra,0xffffa
    800060c4:	47e080e7          	jalr	1150(ra) # 8000053e <panic>
    panic("free_desc 2");
    800060c8:	00002517          	auipc	a0,0x2
    800060cc:	72050513          	addi	a0,a0,1824 # 800087e8 <syscalls+0x300>
    800060d0:	ffffa097          	auipc	ra,0xffffa
    800060d4:	46e080e7          	jalr	1134(ra) # 8000053e <panic>

00000000800060d8 <virtio_disk_init>:
{
    800060d8:	1101                	addi	sp,sp,-32
    800060da:	ec06                	sd	ra,24(sp)
    800060dc:	e822                	sd	s0,16(sp)
    800060de:	e426                	sd	s1,8(sp)
    800060e0:	e04a                	sd	s2,0(sp)
    800060e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060e4:	00002597          	auipc	a1,0x2
    800060e8:	71458593          	addi	a1,a1,1812 # 800087f8 <syscalls+0x310>
    800060ec:	0001d517          	auipc	a0,0x1d
    800060f0:	2fc50513          	addi	a0,a0,764 # 800233e8 <disk+0x128>
    800060f4:	ffffb097          	auipc	ra,0xffffb
    800060f8:	a52080e7          	jalr	-1454(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060fc:	100017b7          	lui	a5,0x10001
    80006100:	4398                	lw	a4,0(a5)
    80006102:	2701                	sext.w	a4,a4
    80006104:	747277b7          	lui	a5,0x74727
    80006108:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000610c:	14f71c63          	bne	a4,a5,80006264 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006110:	100017b7          	lui	a5,0x10001
    80006114:	43dc                	lw	a5,4(a5)
    80006116:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006118:	4709                	li	a4,2
    8000611a:	14e79563          	bne	a5,a4,80006264 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000611e:	100017b7          	lui	a5,0x10001
    80006122:	479c                	lw	a5,8(a5)
    80006124:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006126:	12e79f63          	bne	a5,a4,80006264 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000612a:	100017b7          	lui	a5,0x10001
    8000612e:	47d8                	lw	a4,12(a5)
    80006130:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006132:	554d47b7          	lui	a5,0x554d4
    80006136:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000613a:	12f71563          	bne	a4,a5,80006264 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000613e:	100017b7          	lui	a5,0x10001
    80006142:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006146:	4705                	li	a4,1
    80006148:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000614a:	470d                	li	a4,3
    8000614c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000614e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006150:	c7ffe737          	lui	a4,0xc7ffe
    80006154:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb35f>
    80006158:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000615a:	2701                	sext.w	a4,a4
    8000615c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000615e:	472d                	li	a4,11
    80006160:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006162:	5bbc                	lw	a5,112(a5)
    80006164:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006168:	8ba1                	andi	a5,a5,8
    8000616a:	10078563          	beqz	a5,80006274 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000616e:	100017b7          	lui	a5,0x10001
    80006172:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006176:	43fc                	lw	a5,68(a5)
    80006178:	2781                	sext.w	a5,a5
    8000617a:	10079563          	bnez	a5,80006284 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000617e:	100017b7          	lui	a5,0x10001
    80006182:	5bdc                	lw	a5,52(a5)
    80006184:	2781                	sext.w	a5,a5
  if(max == 0)
    80006186:	10078763          	beqz	a5,80006294 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000618a:	471d                	li	a4,7
    8000618c:	10f77c63          	bgeu	a4,a5,800062a4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006190:	ffffb097          	auipc	ra,0xffffb
    80006194:	956080e7          	jalr	-1706(ra) # 80000ae6 <kalloc>
    80006198:	0001d497          	auipc	s1,0x1d
    8000619c:	12848493          	addi	s1,s1,296 # 800232c0 <disk>
    800061a0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800061a2:	ffffb097          	auipc	ra,0xffffb
    800061a6:	944080e7          	jalr	-1724(ra) # 80000ae6 <kalloc>
    800061aa:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800061ac:	ffffb097          	auipc	ra,0xffffb
    800061b0:	93a080e7          	jalr	-1734(ra) # 80000ae6 <kalloc>
    800061b4:	87aa                	mv	a5,a0
    800061b6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800061b8:	6088                	ld	a0,0(s1)
    800061ba:	cd6d                	beqz	a0,800062b4 <virtio_disk_init+0x1dc>
    800061bc:	0001d717          	auipc	a4,0x1d
    800061c0:	10c73703          	ld	a4,268(a4) # 800232c8 <disk+0x8>
    800061c4:	cb65                	beqz	a4,800062b4 <virtio_disk_init+0x1dc>
    800061c6:	c7fd                	beqz	a5,800062b4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800061c8:	6605                	lui	a2,0x1
    800061ca:	4581                	li	a1,0
    800061cc:	ffffb097          	auipc	ra,0xffffb
    800061d0:	b06080e7          	jalr	-1274(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800061d4:	0001d497          	auipc	s1,0x1d
    800061d8:	0ec48493          	addi	s1,s1,236 # 800232c0 <disk>
    800061dc:	6605                	lui	a2,0x1
    800061de:	4581                	li	a1,0
    800061e0:	6488                	ld	a0,8(s1)
    800061e2:	ffffb097          	auipc	ra,0xffffb
    800061e6:	af0080e7          	jalr	-1296(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800061ea:	6605                	lui	a2,0x1
    800061ec:	4581                	li	a1,0
    800061ee:	6888                	ld	a0,16(s1)
    800061f0:	ffffb097          	auipc	ra,0xffffb
    800061f4:	ae2080e7          	jalr	-1310(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061f8:	100017b7          	lui	a5,0x10001
    800061fc:	4721                	li	a4,8
    800061fe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006200:	4098                	lw	a4,0(s1)
    80006202:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006206:	40d8                	lw	a4,4(s1)
    80006208:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000620c:	6498                	ld	a4,8(s1)
    8000620e:	0007069b          	sext.w	a3,a4
    80006212:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006216:	9701                	srai	a4,a4,0x20
    80006218:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000621c:	6898                	ld	a4,16(s1)
    8000621e:	0007069b          	sext.w	a3,a4
    80006222:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006226:	9701                	srai	a4,a4,0x20
    80006228:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000622c:	4705                	li	a4,1
    8000622e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006230:	00e48c23          	sb	a4,24(s1)
    80006234:	00e48ca3          	sb	a4,25(s1)
    80006238:	00e48d23          	sb	a4,26(s1)
    8000623c:	00e48da3          	sb	a4,27(s1)
    80006240:	00e48e23          	sb	a4,28(s1)
    80006244:	00e48ea3          	sb	a4,29(s1)
    80006248:	00e48f23          	sb	a4,30(s1)
    8000624c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006250:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006254:	0727a823          	sw	s2,112(a5)
}
    80006258:	60e2                	ld	ra,24(sp)
    8000625a:	6442                	ld	s0,16(sp)
    8000625c:	64a2                	ld	s1,8(sp)
    8000625e:	6902                	ld	s2,0(sp)
    80006260:	6105                	addi	sp,sp,32
    80006262:	8082                	ret
    panic("could not find virtio disk");
    80006264:	00002517          	auipc	a0,0x2
    80006268:	5a450513          	addi	a0,a0,1444 # 80008808 <syscalls+0x320>
    8000626c:	ffffa097          	auipc	ra,0xffffa
    80006270:	2d2080e7          	jalr	722(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006274:	00002517          	auipc	a0,0x2
    80006278:	5b450513          	addi	a0,a0,1460 # 80008828 <syscalls+0x340>
    8000627c:	ffffa097          	auipc	ra,0xffffa
    80006280:	2c2080e7          	jalr	706(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006284:	00002517          	auipc	a0,0x2
    80006288:	5c450513          	addi	a0,a0,1476 # 80008848 <syscalls+0x360>
    8000628c:	ffffa097          	auipc	ra,0xffffa
    80006290:	2b2080e7          	jalr	690(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006294:	00002517          	auipc	a0,0x2
    80006298:	5d450513          	addi	a0,a0,1492 # 80008868 <syscalls+0x380>
    8000629c:	ffffa097          	auipc	ra,0xffffa
    800062a0:	2a2080e7          	jalr	674(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800062a4:	00002517          	auipc	a0,0x2
    800062a8:	5e450513          	addi	a0,a0,1508 # 80008888 <syscalls+0x3a0>
    800062ac:	ffffa097          	auipc	ra,0xffffa
    800062b0:	292080e7          	jalr	658(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800062b4:	00002517          	auipc	a0,0x2
    800062b8:	5f450513          	addi	a0,a0,1524 # 800088a8 <syscalls+0x3c0>
    800062bc:	ffffa097          	auipc	ra,0xffffa
    800062c0:	282080e7          	jalr	642(ra) # 8000053e <panic>

00000000800062c4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062c4:	7119                	addi	sp,sp,-128
    800062c6:	fc86                	sd	ra,120(sp)
    800062c8:	f8a2                	sd	s0,112(sp)
    800062ca:	f4a6                	sd	s1,104(sp)
    800062cc:	f0ca                	sd	s2,96(sp)
    800062ce:	ecce                	sd	s3,88(sp)
    800062d0:	e8d2                	sd	s4,80(sp)
    800062d2:	e4d6                	sd	s5,72(sp)
    800062d4:	e0da                	sd	s6,64(sp)
    800062d6:	fc5e                	sd	s7,56(sp)
    800062d8:	f862                	sd	s8,48(sp)
    800062da:	f466                	sd	s9,40(sp)
    800062dc:	f06a                	sd	s10,32(sp)
    800062de:	ec6e                	sd	s11,24(sp)
    800062e0:	0100                	addi	s0,sp,128
    800062e2:	8aaa                	mv	s5,a0
    800062e4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062e6:	00c52d03          	lw	s10,12(a0)
    800062ea:	001d1d1b          	slliw	s10,s10,0x1
    800062ee:	1d02                	slli	s10,s10,0x20
    800062f0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800062f4:	0001d517          	auipc	a0,0x1d
    800062f8:	0f450513          	addi	a0,a0,244 # 800233e8 <disk+0x128>
    800062fc:	ffffb097          	auipc	ra,0xffffb
    80006300:	8da080e7          	jalr	-1830(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006304:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006306:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006308:	0001db97          	auipc	s7,0x1d
    8000630c:	fb8b8b93          	addi	s7,s7,-72 # 800232c0 <disk>
  for(int i = 0; i < 3; i++){
    80006310:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006312:	0001dc97          	auipc	s9,0x1d
    80006316:	0d6c8c93          	addi	s9,s9,214 # 800233e8 <disk+0x128>
    8000631a:	a08d                	j	8000637c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000631c:	00fb8733          	add	a4,s7,a5
    80006320:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006324:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006326:	0207c563          	bltz	a5,80006350 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000632a:	2905                	addiw	s2,s2,1
    8000632c:	0611                	addi	a2,a2,4
    8000632e:	05690c63          	beq	s2,s6,80006386 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006332:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006334:	0001d717          	auipc	a4,0x1d
    80006338:	f8c70713          	addi	a4,a4,-116 # 800232c0 <disk>
    8000633c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000633e:	01874683          	lbu	a3,24(a4)
    80006342:	fee9                	bnez	a3,8000631c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006344:	2785                	addiw	a5,a5,1
    80006346:	0705                	addi	a4,a4,1
    80006348:	fe979be3          	bne	a5,s1,8000633e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000634c:	57fd                	li	a5,-1
    8000634e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006350:	01205d63          	blez	s2,8000636a <virtio_disk_rw+0xa6>
    80006354:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006356:	000a2503          	lw	a0,0(s4)
    8000635a:	00000097          	auipc	ra,0x0
    8000635e:	cfc080e7          	jalr	-772(ra) # 80006056 <free_desc>
      for(int j = 0; j < i; j++)
    80006362:	2d85                	addiw	s11,s11,1
    80006364:	0a11                	addi	s4,s4,4
    80006366:	ffb918e3          	bne	s2,s11,80006356 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000636a:	85e6                	mv	a1,s9
    8000636c:	0001d517          	auipc	a0,0x1d
    80006370:	f6c50513          	addi	a0,a0,-148 # 800232d8 <disk+0x18>
    80006374:	ffffc097          	auipc	ra,0xffffc
    80006378:	dc6080e7          	jalr	-570(ra) # 8000213a <sleep>
  for(int i = 0; i < 3; i++){
    8000637c:	f8040a13          	addi	s4,s0,-128
{
    80006380:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006382:	894e                	mv	s2,s3
    80006384:	b77d                	j	80006332 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006386:	f8042583          	lw	a1,-128(s0)
    8000638a:	00a58793          	addi	a5,a1,10
    8000638e:	0792                	slli	a5,a5,0x4

  if(write)
    80006390:	0001d617          	auipc	a2,0x1d
    80006394:	f3060613          	addi	a2,a2,-208 # 800232c0 <disk>
    80006398:	00f60733          	add	a4,a2,a5
    8000639c:	018036b3          	snez	a3,s8
    800063a0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800063a2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800063a6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063aa:	f6078693          	addi	a3,a5,-160
    800063ae:	6218                	ld	a4,0(a2)
    800063b0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063b2:	00878513          	addi	a0,a5,8
    800063b6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063b8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063ba:	6208                	ld	a0,0(a2)
    800063bc:	96aa                	add	a3,a3,a0
    800063be:	4741                	li	a4,16
    800063c0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063c2:	4705                	li	a4,1
    800063c4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800063c8:	f8442703          	lw	a4,-124(s0)
    800063cc:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063d0:	0712                	slli	a4,a4,0x4
    800063d2:	953a                	add	a0,a0,a4
    800063d4:	058a8693          	addi	a3,s5,88
    800063d8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800063da:	6208                	ld	a0,0(a2)
    800063dc:	972a                	add	a4,a4,a0
    800063de:	40000693          	li	a3,1024
    800063e2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063e4:	001c3c13          	seqz	s8,s8
    800063e8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063ea:	001c6c13          	ori	s8,s8,1
    800063ee:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800063f2:	f8842603          	lw	a2,-120(s0)
    800063f6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063fa:	0001d697          	auipc	a3,0x1d
    800063fe:	ec668693          	addi	a3,a3,-314 # 800232c0 <disk>
    80006402:	00258713          	addi	a4,a1,2
    80006406:	0712                	slli	a4,a4,0x4
    80006408:	9736                	add	a4,a4,a3
    8000640a:	587d                	li	a6,-1
    8000640c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006410:	0612                	slli	a2,a2,0x4
    80006412:	9532                	add	a0,a0,a2
    80006414:	f9078793          	addi	a5,a5,-112
    80006418:	97b6                	add	a5,a5,a3
    8000641a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000641c:	629c                	ld	a5,0(a3)
    8000641e:	97b2                	add	a5,a5,a2
    80006420:	4605                	li	a2,1
    80006422:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006424:	4509                	li	a0,2
    80006426:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000642a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000642e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006432:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006436:	6698                	ld	a4,8(a3)
    80006438:	00275783          	lhu	a5,2(a4)
    8000643c:	8b9d                	andi	a5,a5,7
    8000643e:	0786                	slli	a5,a5,0x1
    80006440:	97ba                	add	a5,a5,a4
    80006442:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006446:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000644a:	6698                	ld	a4,8(a3)
    8000644c:	00275783          	lhu	a5,2(a4)
    80006450:	2785                	addiw	a5,a5,1
    80006452:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006456:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000645a:	100017b7          	lui	a5,0x10001
    8000645e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006462:	004aa783          	lw	a5,4(s5)
    80006466:	02c79163          	bne	a5,a2,80006488 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000646a:	0001d917          	auipc	s2,0x1d
    8000646e:	f7e90913          	addi	s2,s2,-130 # 800233e8 <disk+0x128>
  while(b->disk == 1) {
    80006472:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006474:	85ca                	mv	a1,s2
    80006476:	8556                	mv	a0,s5
    80006478:	ffffc097          	auipc	ra,0xffffc
    8000647c:	cc2080e7          	jalr	-830(ra) # 8000213a <sleep>
  while(b->disk == 1) {
    80006480:	004aa783          	lw	a5,4(s5)
    80006484:	fe9788e3          	beq	a5,s1,80006474 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006488:	f8042903          	lw	s2,-128(s0)
    8000648c:	00290793          	addi	a5,s2,2
    80006490:	00479713          	slli	a4,a5,0x4
    80006494:	0001d797          	auipc	a5,0x1d
    80006498:	e2c78793          	addi	a5,a5,-468 # 800232c0 <disk>
    8000649c:	97ba                	add	a5,a5,a4
    8000649e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800064a2:	0001d997          	auipc	s3,0x1d
    800064a6:	e1e98993          	addi	s3,s3,-482 # 800232c0 <disk>
    800064aa:	00491713          	slli	a4,s2,0x4
    800064ae:	0009b783          	ld	a5,0(s3)
    800064b2:	97ba                	add	a5,a5,a4
    800064b4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064b8:	854a                	mv	a0,s2
    800064ba:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064be:	00000097          	auipc	ra,0x0
    800064c2:	b98080e7          	jalr	-1128(ra) # 80006056 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064c6:	8885                	andi	s1,s1,1
    800064c8:	f0ed                	bnez	s1,800064aa <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064ca:	0001d517          	auipc	a0,0x1d
    800064ce:	f1e50513          	addi	a0,a0,-226 # 800233e8 <disk+0x128>
    800064d2:	ffffa097          	auipc	ra,0xffffa
    800064d6:	7b8080e7          	jalr	1976(ra) # 80000c8a <release>
}
    800064da:	70e6                	ld	ra,120(sp)
    800064dc:	7446                	ld	s0,112(sp)
    800064de:	74a6                	ld	s1,104(sp)
    800064e0:	7906                	ld	s2,96(sp)
    800064e2:	69e6                	ld	s3,88(sp)
    800064e4:	6a46                	ld	s4,80(sp)
    800064e6:	6aa6                	ld	s5,72(sp)
    800064e8:	6b06                	ld	s6,64(sp)
    800064ea:	7be2                	ld	s7,56(sp)
    800064ec:	7c42                	ld	s8,48(sp)
    800064ee:	7ca2                	ld	s9,40(sp)
    800064f0:	7d02                	ld	s10,32(sp)
    800064f2:	6de2                	ld	s11,24(sp)
    800064f4:	6109                	addi	sp,sp,128
    800064f6:	8082                	ret

00000000800064f8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064f8:	1101                	addi	sp,sp,-32
    800064fa:	ec06                	sd	ra,24(sp)
    800064fc:	e822                	sd	s0,16(sp)
    800064fe:	e426                	sd	s1,8(sp)
    80006500:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006502:	0001d497          	auipc	s1,0x1d
    80006506:	dbe48493          	addi	s1,s1,-578 # 800232c0 <disk>
    8000650a:	0001d517          	auipc	a0,0x1d
    8000650e:	ede50513          	addi	a0,a0,-290 # 800233e8 <disk+0x128>
    80006512:	ffffa097          	auipc	ra,0xffffa
    80006516:	6c4080e7          	jalr	1732(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000651a:	10001737          	lui	a4,0x10001
    8000651e:	533c                	lw	a5,96(a4)
    80006520:	8b8d                	andi	a5,a5,3
    80006522:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006524:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006528:	689c                	ld	a5,16(s1)
    8000652a:	0204d703          	lhu	a4,32(s1)
    8000652e:	0027d783          	lhu	a5,2(a5)
    80006532:	04f70863          	beq	a4,a5,80006582 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006536:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000653a:	6898                	ld	a4,16(s1)
    8000653c:	0204d783          	lhu	a5,32(s1)
    80006540:	8b9d                	andi	a5,a5,7
    80006542:	078e                	slli	a5,a5,0x3
    80006544:	97ba                	add	a5,a5,a4
    80006546:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006548:	00278713          	addi	a4,a5,2
    8000654c:	0712                	slli	a4,a4,0x4
    8000654e:	9726                	add	a4,a4,s1
    80006550:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006554:	e721                	bnez	a4,8000659c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006556:	0789                	addi	a5,a5,2
    80006558:	0792                	slli	a5,a5,0x4
    8000655a:	97a6                	add	a5,a5,s1
    8000655c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000655e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006562:	ffffc097          	auipc	ra,0xffffc
    80006566:	c58080e7          	jalr	-936(ra) # 800021ba <wakeup>

    disk.used_idx += 1;
    8000656a:	0204d783          	lhu	a5,32(s1)
    8000656e:	2785                	addiw	a5,a5,1
    80006570:	17c2                	slli	a5,a5,0x30
    80006572:	93c1                	srli	a5,a5,0x30
    80006574:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006578:	6898                	ld	a4,16(s1)
    8000657a:	00275703          	lhu	a4,2(a4)
    8000657e:	faf71ce3          	bne	a4,a5,80006536 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006582:	0001d517          	auipc	a0,0x1d
    80006586:	e6650513          	addi	a0,a0,-410 # 800233e8 <disk+0x128>
    8000658a:	ffffa097          	auipc	ra,0xffffa
    8000658e:	700080e7          	jalr	1792(ra) # 80000c8a <release>
}
    80006592:	60e2                	ld	ra,24(sp)
    80006594:	6442                	ld	s0,16(sp)
    80006596:	64a2                	ld	s1,8(sp)
    80006598:	6105                	addi	sp,sp,32
    8000659a:	8082                	ret
      panic("virtio_disk_intr status");
    8000659c:	00002517          	auipc	a0,0x2
    800065a0:	32450513          	addi	a0,a0,804 # 800088c0 <syscalls+0x3d8>
    800065a4:	ffffa097          	auipc	ra,0xffffa
    800065a8:	f9a080e7          	jalr	-102(ra) # 8000053e <panic>
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
