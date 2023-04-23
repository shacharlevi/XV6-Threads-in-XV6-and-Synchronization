
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	8be70713          	addi	a4,a4,-1858 # 80008910 <timer_scratch>
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
    80000068:	eac78793          	addi	a5,a5,-340 # 80005f10 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb47f>
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
    80000130:	49a080e7          	jalr	1178(ra) # 800025c6 <either_copyin>
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
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
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
    800001cc:	246080e7          	jalr	582(ra) # 8000240e <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f14080e7          	jalr	-236(ra) # 800020ea <sleep>
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
    80000216:	35c080e7          	jalr	860(ra) # 8000256e <either_copyout>
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
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
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
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
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
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
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
    800002f6:	32c080e7          	jalr	812(ra) # 8000261e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
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
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
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
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
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
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
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
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
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
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
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
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	d24080e7          	jalr	-732(ra) # 8000216a <wakeup>
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
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	d7078793          	addi	a5,a5,-656 # 800221e8 <devsw>
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
    8000054e:	5c07a323          	sw	zero,1478(a5) # 80010b10 <pr+0x18>
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
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	34f72923          	sw	a5,850(a4) # 800088d0 <panicked>
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
    800005be:	556dad83          	lw	s11,1366(s11) # 80010b10 <pr+0x18>
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
    800005fc:	50050513          	addi	a0,a0,1280 # 80010af8 <pr>
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
    8000075a:	3a250513          	addi	a0,a0,930 # 80010af8 <pr>
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
    80000776:	38648493          	addi	s1,s1,902 # 80010af8 <pr>
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
    800007d6:	34650513          	addi	a0,a0,838 # 80010b18 <uart_tx_lock>
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
    80000802:	0d27a783          	lw	a5,210(a5) # 800088d0 <panicked>
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
    8000083a:	0a27b783          	ld	a5,162(a5) # 800088d8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0a273703          	ld	a4,162(a4) # 800088e0 <uart_tx_w>
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
    80000864:	2b8a0a13          	addi	s4,s4,696 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	07048493          	addi	s1,s1,112 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	07098993          	addi	s3,s3,112 # 800088e0 <uart_tx_w>
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
    80000896:	8d8080e7          	jalr	-1832(ra) # 8000216a <wakeup>
    
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
    800008d2:	24a50513          	addi	a0,a0,586 # 80010b18 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	ff27a783          	lw	a5,-14(a5) # 800088d0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	ff873703          	ld	a4,-8(a4) # 800088e0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fe87b783          	ld	a5,-24(a5) # 800088d8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	21c98993          	addi	s3,s3,540 # 80010b18 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fd448493          	addi	s1,s1,-44 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fd490913          	addi	s2,s2,-44 # 800088e0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	7ce080e7          	jalr	1998(ra) # 800020ea <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1e648493          	addi	s1,s1,486 # 80010b18 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7bd23          	sd	a4,-102(a5) # 800088e0 <uart_tx_w>
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
    800009c0:	15c48493          	addi	s1,s1,348 # 80010b18 <uart_tx_lock>
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
    80000a02:	98278793          	addi	a5,a5,-1662 # 80023380 <end>
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
    80000a22:	13290913          	addi	s2,s2,306 # 80010b50 <kmem>
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
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	8b250513          	addi	a0,a0,-1870 # 80023380 <end>
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
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
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
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
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
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
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
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
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
    80000ec2:	a8c080e7          	jalr	-1396(ra) # 8000294a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	08a080e7          	jalr	138(ra) # 80005f50 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	ff4080e7          	jalr	-12(ra) # 80001ec2 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
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
    80000f3a:	9ec080e7          	jalr	-1556(ra) # 80002922 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a0c080e7          	jalr	-1524(ra) # 8000294a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	ff4080e7          	jalr	-12(ra) # 80005f3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	002080e7          	jalr	2(ra) # 80005f50 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	18c080e7          	jalr	396(ra) # 800030e2 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	830080e7          	jalr	-2000(ra) # 8000378e <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	7ce080e7          	jalr	1998(ra) # 80004734 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	0ea080e7          	jalr	234(ra) # 80006058 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	cbc080e7          	jalr	-836(ra) # 80001c32 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72223          	sw	a5,-1692(a4) # 800088e8 <started>
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
    80000f9c:	9587b783          	ld	a5,-1704(a5) # 800088f0 <kernel_pagetable>
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
    80001258:	68a7be23          	sd	a0,1692(a5) # 800088f0 <kernel_pagetable>
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
    80001852:	75290913          	addi	s2,s2,1874 # 80010fa0 <proc>
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
    8000186c:	738a8a93          	addi	s5,s5,1848 # 80017fa0 <tickslock>
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
    800018e8:	28c50513          	addi	a0,a0,652 # 80010b70 <pid_lock>
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	25a080e7          	jalr	602(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f4:	00007597          	auipc	a1,0x7
    800018f8:	8f458593          	addi	a1,a1,-1804 # 800081e8 <digits+0x1a8>
    800018fc:	0000f517          	auipc	a0,0xf
    80001900:	28c50513          	addi	a0,a0,652 # 80010b88 <wait_lock>
    80001904:	fffff097          	auipc	ra,0xfffff
    80001908:	242080e7          	jalr	578(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190c:	0000f497          	auipc	s1,0xf
    80001910:	69448493          	addi	s1,s1,1684 # 80010fa0 <proc>
     initlock(&p->lock, "proc"); 
    80001914:	00007997          	auipc	s3,0x7
    80001918:	8e498993          	addi	s3,s3,-1820 # 800081f8 <digits+0x1b8>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191c:	00016917          	auipc	s2,0x16
    80001920:	68490913          	addi	s2,s2,1668 # 80017fa0 <tickslock>
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
    8000193a:	d96080e7          	jalr	-618(ra) # 800026cc <kthreadinit>
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
    80001974:	23050513          	addi	a0,a0,560 # 80010ba0 <cpus>
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
    800019a0:	1d448493          	addi	s1,s1,468 # 80010b70 <pid_lock>
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
    800019e6:	18e90913          	addi	s2,s2,398 # 80010b70 <pid_lock>
    800019ea:	854a                	mv	a0,s2
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	1ea080e7          	jalr	490(ra) # 80000bd6 <acquire>
  pid = nextpid;
    800019f4:	00007797          	auipc	a5,0x7
    800019f8:	e7078793          	addi	a5,a5,-400 # 80008864 <nextpid>
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
    80001b2c:	d34080e7          	jalr	-716(ra) # 8000285c <freethread>
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
    80001b90:	41448493          	addi	s1,s1,1044 # 80010fa0 <proc>
    80001b94:	00016917          	auipc	s2,0x16
    80001b98:	40c90913          	addi	s2,s2,1036 # 80017fa0 <tickslock>
    acquire(&p->lock);
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	038080e7          	jalr	56(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001ba6:	4c9c                	lw	a5,24(s1)
    80001ba8:	cb99                	beqz	a5,80001bbe <allocproc+0x3e>
      release(&p->lock);
    80001baa:	8526                	mv	a0,s1
    80001bac:	fffff097          	auipc	ra,0xfffff
    80001bb0:	0de080e7          	jalr	222(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bb4:	1c048493          	addi	s1,s1,448
    80001bb8:	ff2492e3          	bne	s1,s2,80001b9c <allocproc+0x1c>
    80001bbc:	a835                	j	80001bf8 <allocproc+0x78>
  p->p_counter=1;
    80001bbe:	4905                	li	s2,1
    80001bc0:	1b24a023          	sw	s2,416(s1)
  p->pid = allocpid();
    80001bc4:	00000097          	auipc	ra,0x0
    80001bc8:	e12080e7          	jalr	-494(ra) # 800019d6 <allocpid>
    80001bcc:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001bce:	0124ac23          	sw	s2,24(s1)
  allockthread(p);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	00001097          	auipc	ra,0x1
    80001bd8:	c0a080e7          	jalr	-1014(ra) # 800027de <allockthread>
  if((p->base_trapframes = (struct trapframe *)kalloc()) == 0){
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	f0a080e7          	jalr	-246(ra) # 80000ae6 <kalloc>
    80001be4:	f4e8                	sd	a0,232(s1)
    80001be6:	c105                	beqz	a0,80001c06 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001be8:	8526                	mv	a0,s1
    80001bea:	00000097          	auipc	ra,0x0
    80001bee:	e32080e7          	jalr	-462(ra) # 80001a1c <proc_pagetable>
    80001bf2:	10a4b023          	sd	a0,256(s1)
  if(p->pagetable == 0){
    80001bf6:	c11d                	beqz	a0,80001c1c <allocproc+0x9c>
}
    80001bf8:	4501                	li	a0,0
    80001bfa:	60e2                	ld	ra,24(sp)
    80001bfc:	6442                	ld	s0,16(sp)
    80001bfe:	64a2                	ld	s1,8(sp)
    80001c00:	6902                	ld	s2,0(sp)
    80001c02:	6105                	addi	sp,sp,32
    80001c04:	8082                	ret
    freeproc(p);
    80001c06:	8526                	mv	a0,s1
    80001c08:	00000097          	auipc	ra,0x0
    80001c0c:	f02080e7          	jalr	-254(ra) # 80001b0a <freeproc>
    release(&p->lock);
    80001c10:	8526                	mv	a0,s1
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	078080e7          	jalr	120(ra) # 80000c8a <release>
    return 0;
    80001c1a:	bff9                	j	80001bf8 <allocproc+0x78>
    freeproc(p);
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	eec080e7          	jalr	-276(ra) # 80001b0a <freeproc>
    release(&p->lock);
    80001c26:	8526                	mv	a0,s1
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	062080e7          	jalr	98(ra) # 80000c8a <release>
    return 0;
    80001c30:	b7e1                	j	80001bf8 <allocproc+0x78>

0000000080001c32 <userinit>:
};

// Set up first user process.
void
userinit(void)
{
    80001c32:	1101                	addi	sp,sp,-32
    80001c34:	ec06                	sd	ra,24(sp)
    80001c36:	e822                	sd	s0,16(sp)
    80001c38:	e426                	sd	s1,8(sp)
    80001c3a:	e04a                	sd	s2,0(sp)
    80001c3c:	1000                	addi	s0,sp,32
  struct proc *p;
  p = allocproc();
    80001c3e:	00000097          	auipc	ra,0x0
    80001c42:	f42080e7          	jalr	-190(ra) # 80001b80 <allocproc>
    80001c46:	84aa                	mv	s1,a0
  initproc = p;
    80001c48:	00007797          	auipc	a5,0x7
    80001c4c:	caa7b823          	sd	a0,-848(a5) # 800088f8 <initproc>
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c50:	03400613          	li	a2,52
    80001c54:	00007597          	auipc	a1,0x7
    80001c58:	c1c58593          	addi	a1,a1,-996 # 80008870 <initcode>
    80001c5c:	10053503          	ld	a0,256(a0)
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	6f6080e7          	jalr	1782(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001c68:	6785                	lui	a5,0x1
    80001c6a:	fcfc                	sd	a5,248(s1)
  // prepare for the very first "return" from kernel to user.
  p->kthread[0].trapframe->epc = 0;      // user program counter
    80001c6c:	70f8                	ld	a4,224(s1)
    80001c6e:	00073c23          	sd	zero,24(a4)
  p->kthread[0].trapframe->sp = PGSIZE;  // user stack pointer
    80001c72:	70f8                	ld	a4,224(s1)
    80001c74:	fb1c                	sd	a5,48(a4)
  p->kthread[0].t_state=RUNNABLE_t;
    80001c76:	490d                	li	s2,3
    80001c78:	0524a023          	sw	s2,64(s1)
  release(&((p->kthread[0]).t_lock));
    80001c7c:	02848513          	addi	a0,s1,40
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001c88:	4641                	li	a2,16
    80001c8a:	00006597          	auipc	a1,0x6
    80001c8e:	57658593          	addi	a1,a1,1398 # 80008200 <digits+0x1c0>
    80001c92:	19048513          	addi	a0,s1,400
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	186080e7          	jalr	390(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001c9e:	00006517          	auipc	a0,0x6
    80001ca2:	57250513          	addi	a0,a0,1394 # 80008210 <digits+0x1d0>
    80001ca6:	00002097          	auipc	ra,0x2
    80001caa:	48a080e7          	jalr	1162(ra) # 80004130 <namei>
    80001cae:	18a4b423          	sd	a0,392(s1)

  p->state = RUNNABLE;
    80001cb2:	0124ac23          	sw	s2,24(s1)

  release(&p->lock);
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	fffff097          	auipc	ra,0xfffff
    80001cbc:	fd2080e7          	jalr	-46(ra) # 80000c8a <release>
}
    80001cc0:	60e2                	ld	ra,24(sp)
    80001cc2:	6442                	ld	s0,16(sp)
    80001cc4:	64a2                	ld	s1,8(sp)
    80001cc6:	6902                	ld	s2,0(sp)
    80001cc8:	6105                	addi	sp,sp,32
    80001cca:	8082                	ret

0000000080001ccc <growproc>:

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
    80001ccc:	1101                	addi	sp,sp,-32
    80001cce:	ec06                	sd	ra,24(sp)
    80001cd0:	e822                	sd	s0,16(sp)
    80001cd2:	e426                	sd	s1,8(sp)
    80001cd4:	e04a                	sd	s2,0(sp)
    80001cd6:	1000                	addi	s0,sp,32
    80001cd8:	892a                	mv	s2,a0
  uint64 sz;
  struct proc *p = myproc();
    80001cda:	00000097          	auipc	ra,0x0
    80001cde:	ca6080e7          	jalr	-858(ra) # 80001980 <myproc>
    80001ce2:	84aa                	mv	s1,a0

  sz = p->sz;
    80001ce4:	7d6c                	ld	a1,248(a0)
  if(n > 0){
    80001ce6:	01204c63          	bgtz	s2,80001cfe <growproc+0x32>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    80001cea:	02094763          	bltz	s2,80001d18 <growproc+0x4c>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
    80001cee:	fcec                	sd	a1,248(s1)
  return 0;
    80001cf0:	4501                	li	a0,0
}
    80001cf2:	60e2                	ld	ra,24(sp)
    80001cf4:	6442                	ld	s0,16(sp)
    80001cf6:	64a2                	ld	s1,8(sp)
    80001cf8:	6902                	ld	s2,0(sp)
    80001cfa:	6105                	addi	sp,sp,32
    80001cfc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001cfe:	4691                	li	a3,4
    80001d00:	00b90633          	add	a2,s2,a1
    80001d04:	10053503          	ld	a0,256(a0)
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	708080e7          	jalr	1800(ra) # 80001410 <uvmalloc>
    80001d10:	85aa                	mv	a1,a0
    80001d12:	fd71                	bnez	a0,80001cee <growproc+0x22>
      return -1;
    80001d14:	557d                	li	a0,-1
    80001d16:	bff1                	j	80001cf2 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d18:	00b90633          	add	a2,s2,a1
    80001d1c:	10053503          	ld	a0,256(a0)
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	6a8080e7          	jalr	1704(ra) # 800013c8 <uvmdealloc>
    80001d28:	85aa                	mv	a1,a0
    80001d2a:	b7d1                	j	80001cee <growproc+0x22>

0000000080001d2c <fork>:

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
    80001d2c:	7139                	addi	sp,sp,-64
    80001d2e:	fc06                	sd	ra,56(sp)
    80001d30:	f822                	sd	s0,48(sp)
    80001d32:	f426                	sd	s1,40(sp)
    80001d34:	f04a                	sd	s2,32(sp)
    80001d36:	ec4e                	sd	s3,24(sp)
    80001d38:	e852                	sd	s4,16(sp)
    80001d3a:	e456                	sd	s5,8(sp)
    80001d3c:	e05a                	sd	s6,0(sp)
    80001d3e:	0080                	addi	s0,sp,64
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
    80001d40:	00000097          	auipc	ra,0x0
    80001d44:	c40080e7          	jalr	-960(ra) # 80001980 <myproc>
    80001d48:	8aaa                	mv	s5,a0
  struct kthread *kt = mykthread();
    80001d4a:	00001097          	auipc	ra,0x1
    80001d4e:	9f4080e7          	jalr	-1548(ra) # 8000273e <mykthread>
    80001d52:	84aa                	mv	s1,a0

  // Allocate process.
  if((np = allocproc()) == 0){
    80001d54:	00000097          	auipc	ra,0x0
    80001d58:	e2c080e7          	jalr	-468(ra) # 80001b80 <allocproc>
    80001d5c:	16050163          	beqz	a0,80001ebe <fork+0x192>
    80001d60:	8a2a                	mv	s4,a0
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d62:	0f8ab603          	ld	a2,248(s5)
    80001d66:	10053583          	ld	a1,256(a0)
    80001d6a:	100ab503          	ld	a0,256(s5)
    80001d6e:	fffff097          	auipc	ra,0xfffff
    80001d72:	7f6080e7          	jalr	2038(ra) # 80001564 <uvmcopy>
    80001d76:	04054e63          	bltz	a0,80001dd2 <fork+0xa6>
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;
    80001d7a:	0f8ab783          	ld	a5,248(s5)
    80001d7e:	0efa3c23          	sd	a5,248(s4) # fffffffffffff0f8 <end+0xffffffff7ffdbd78>

  struct kthread *new_t=allockthread(np);
    80001d82:	8552                	mv	a0,s4
    80001d84:	00001097          	auipc	ra,0x1
    80001d88:	a5a080e7          	jalr	-1446(ra) # 800027de <allockthread>
    80001d8c:	8b2a                	mv	s6,a0
  if(new_t==0){
    80001d8e:	cd31                	beqz	a0,80001dea <fork+0xbe>
    freeproc(np);
     release(&np->lock);
    return -1;
  }
  // copy saved user registers.
  *(np->kthread[0].trapframe) = *(kt->trapframe);
    80001d90:	7cd4                	ld	a3,184(s1)
    80001d92:	87b6                	mv	a5,a3
    80001d94:	0e0a3703          	ld	a4,224(s4)
    80001d98:	12068693          	addi	a3,a3,288
    80001d9c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001da0:	6788                	ld	a0,8(a5)
    80001da2:	6b8c                	ld	a1,16(a5)
    80001da4:	6f90                	ld	a2,24(a5)
    80001da6:	01073023          	sd	a6,0(a4)
    80001daa:	e708                	sd	a0,8(a4)
    80001dac:	eb0c                	sd	a1,16(a4)
    80001dae:	ef10                	sd	a2,24(a4)
    80001db0:	02078793          	addi	a5,a5,32
    80001db4:	02070713          	addi	a4,a4,32
    80001db8:	fed792e3          	bne	a5,a3,80001d9c <fork+0x70>

  // Cause fork to return 0 in the child.
  new_t->trapframe->a0 = 0;
    80001dbc:	0b8b3783          	ld	a5,184(s6)
    80001dc0:	0607b823          	sd	zero,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    80001dc4:	108a8493          	addi	s1,s5,264
    80001dc8:	108a0913          	addi	s2,s4,264
    80001dcc:	188a8993          	addi	s3,s5,392
    80001dd0:	a099                	j	80001e16 <fork+0xea>
    freeproc(np);
    80001dd2:	8552                	mv	a0,s4
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	d36080e7          	jalr	-714(ra) # 80001b0a <freeproc>
    release(&np->lock);
    80001ddc:	8552                	mv	a0,s4
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	eac080e7          	jalr	-340(ra) # 80000c8a <release>
    return -1;
    80001de6:	597d                	li	s2,-1
    80001de8:	a0c1                	j	80001ea8 <fork+0x17c>
    freeproc(np);
    80001dea:	8552                	mv	a0,s4
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	d1e080e7          	jalr	-738(ra) # 80001b0a <freeproc>
     release(&np->lock);
    80001df4:	8552                	mv	a0,s4
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	e94080e7          	jalr	-364(ra) # 80000c8a <release>
    return -1;
    80001dfe:	597d                	li	s2,-1
    80001e00:	a065                	j	80001ea8 <fork+0x17c>
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
    80001e02:	00003097          	auipc	ra,0x3
    80001e06:	9c4080e7          	jalr	-1596(ra) # 800047c6 <filedup>
    80001e0a:	00a93023          	sd	a0,0(s2)
  for(i = 0; i < NOFILE; i++)
    80001e0e:	04a1                	addi	s1,s1,8
    80001e10:	0921                	addi	s2,s2,8
    80001e12:	01348563          	beq	s1,s3,80001e1c <fork+0xf0>
    if(p->ofile[i])
    80001e16:	6088                	ld	a0,0(s1)
    80001e18:	f56d                	bnez	a0,80001e02 <fork+0xd6>
    80001e1a:	bfd5                	j	80001e0e <fork+0xe2>
  np->cwd = idup(p->cwd);
    80001e1c:	188ab503          	ld	a0,392(s5)
    80001e20:	00002097          	auipc	ra,0x2
    80001e24:	b2c080e7          	jalr	-1236(ra) # 8000394c <idup>
    80001e28:	18aa3423          	sd	a0,392(s4)

  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e2c:	4641                	li	a2,16
    80001e2e:	190a8593          	addi	a1,s5,400
    80001e32:	190a0513          	addi	a0,s4,400
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	fe6080e7          	jalr	-26(ra) # 80000e1c <safestrcpy>

  pid = np->pid;
    80001e3e:	024a2903          	lw	s2,36(s4)

  release(&new_t->t_lock);
    80001e42:	855a                	mv	a0,s6
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	e46080e7          	jalr	-442(ra) # 80000c8a <release>
  release(&np->lock);
    80001e4c:	8552                	mv	a0,s4
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	e3c080e7          	jalr	-452(ra) # 80000c8a <release>

  acquire(&wait_lock);
    80001e56:	0000f497          	auipc	s1,0xf
    80001e5a:	d3248493          	addi	s1,s1,-718 # 80010b88 <wait_lock>
    80001e5e:	8526                	mv	a0,s1
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	d76080e7          	jalr	-650(ra) # 80000bd6 <acquire>
  acquire(&np->lock);
    80001e68:	8552                	mv	a0,s4
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	d6c080e7          	jalr	-660(ra) # 80000bd6 <acquire>
  acquire(&new_t->t_lock);
    80001e72:	855a                	mv	a0,s6
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	d62080e7          	jalr	-670(ra) # 80000bd6 <acquire>

  np->parent = p;
    80001e7c:	0f5a3823          	sd	s5,240(s4)
  np->state=RUNNABLE;
    80001e80:	478d                	li	a5,3
    80001e82:	00fa2c23          	sw	a5,24(s4)
  new_t->t_state = RUNNABLE_t;
    80001e86:	00fb2c23          	sw	a5,24(s6)

  release(&new_t->t_lock);
    80001e8a:	855a                	mv	a0,s6
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	dfe080e7          	jalr	-514(ra) # 80000c8a <release>
  release(&np->lock);
    80001e94:	8552                	mv	a0,s4
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	df4080e7          	jalr	-524(ra) # 80000c8a <release>
  release(&wait_lock);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	dea080e7          	jalr	-534(ra) # 80000c8a <release>


  return pid;
}
    80001ea8:	854a                	mv	a0,s2
    80001eaa:	70e2                	ld	ra,56(sp)
    80001eac:	7442                	ld	s0,48(sp)
    80001eae:	74a2                	ld	s1,40(sp)
    80001eb0:	7902                	ld	s2,32(sp)
    80001eb2:	69e2                	ld	s3,24(sp)
    80001eb4:	6a42                	ld	s4,16(sp)
    80001eb6:	6aa2                	ld	s5,8(sp)
    80001eb8:	6b02                	ld	s6,0(sp)
    80001eba:	6121                	addi	sp,sp,64
    80001ebc:	8082                	ret
    return -1;
    80001ebe:	597d                	li	s2,-1
    80001ec0:	b7e5                	j	80001ea8 <fork+0x17c>

0000000080001ec2 <scheduler>:
// }


void
scheduler(void)
{
    80001ec2:	715d                	addi	sp,sp,-80
    80001ec4:	e486                	sd	ra,72(sp)
    80001ec6:	e0a2                	sd	s0,64(sp)
    80001ec8:	fc26                	sd	s1,56(sp)
    80001eca:	f84a                	sd	s2,48(sp)
    80001ecc:	f44e                	sd	s3,40(sp)
    80001ece:	f052                	sd	s4,32(sp)
    80001ed0:	ec56                	sd	s5,24(sp)
    80001ed2:	e85a                	sd	s6,16(sp)
    80001ed4:	e45e                	sd	s7,8(sp)
    80001ed6:	0880                	addi	s0,sp,80
    80001ed8:	8792                	mv	a5,tp
  int id = r_tp();
    80001eda:	2781                	sext.w	a5,a5
  struct proc *p;
  struct cpu *c = mycpu();
  
  c->kthread = 0;
    80001edc:	00779b13          	slli	s6,a5,0x7
    80001ee0:	0000f717          	auipc	a4,0xf
    80001ee4:	c9070713          	addi	a4,a4,-880 # 80010b70 <pid_lock>
    80001ee8:	975a                	add	a4,a4,s6
    80001eea:	02073823          	sd	zero,48(a4)
        // Switch to chosen thread.
        t->process = p;
        //  t->trapframe = p->tr;
        t->t_state = RUNNING_t;
        c->kthread = t;
        swtch(&c->context, &t->context);
    80001eee:	0000f717          	auipc	a4,0xf
    80001ef2:	cba70713          	addi	a4,a4,-838 # 80010ba8 <cpus+0x8>
    80001ef6:	9b3a                	add	s6,s6,a4
      if(p->state == RUNNABLE) {
    80001ef8:	498d                	li	s3,3
        t->t_state = RUNNING_t;
    80001efa:	4b91                	li	s7,4
        c->kthread = t;
    80001efc:	079e                	slli	a5,a5,0x7
    80001efe:	0000fa97          	auipc	s5,0xf
    80001f02:	c72a8a93          	addi	s5,s5,-910 # 80010b70 <pid_lock>
    80001f06:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f08:	00016917          	auipc	s2,0x16
    80001f0c:	09890913          	addi	s2,s2,152 # 80017fa0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f10:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f14:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f18:	10079073          	csrw	sstatus,a5
    80001f1c:	0000f497          	auipc	s1,0xf
    80001f20:	08448493          	addi	s1,s1,132 # 80010fa0 <proc>
    80001f24:	a811                	j	80001f38 <scheduler+0x76>
        c->kthread = 0;
        t->process = 0;
        // t->trapframe = 0;
        release(&t->t_lock); // Release the thread lock
      }
      release(&p->lock);
    80001f26:	8526                	mv	a0,s1
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	d62080e7          	jalr	-670(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f30:	1c048493          	addi	s1,s1,448
    80001f34:	fd248ee3          	beq	s1,s2,80001f10 <scheduler+0x4e>
      acquire(&p->lock);
    80001f38:	8526                	mv	a0,s1
    80001f3a:	fffff097          	auipc	ra,0xfffff
    80001f3e:	c9c080e7          	jalr	-868(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f42:	4c9c                	lw	a5,24(s1)
    80001f44:	ff3791e3          	bne	a5,s3,80001f26 <scheduler+0x64>
        struct kthread *t = &p->kthread[0]; // Get the single thread in the process
    80001f48:	02848a13          	addi	s4,s1,40
        acquire(&t->t_lock); // Acquire the thread lock
    80001f4c:	8552                	mv	a0,s4
    80001f4e:	fffff097          	auipc	ra,0xfffff
    80001f52:	c88080e7          	jalr	-888(ra) # 80000bd6 <acquire>
        t->process = p;
    80001f56:	f0a4                	sd	s1,96(s1)
        t->t_state = RUNNING_t;
    80001f58:	0574a023          	sw	s7,64(s1)
        c->kthread = t;
    80001f5c:	034ab823          	sd	s4,48(s5)
        swtch(&c->context, &t->context);
    80001f60:	06848593          	addi	a1,s1,104
    80001f64:	855a                	mv	a0,s6
    80001f66:	00001097          	auipc	ra,0x1
    80001f6a:	952080e7          	jalr	-1710(ra) # 800028b8 <swtch>
        c->kthread = 0;
    80001f6e:	020ab823          	sd	zero,48(s5)
        t->process = 0;
    80001f72:	0604b023          	sd	zero,96(s1)
        release(&t->t_lock); // Release the thread lock
    80001f76:	8552                	mv	a0,s4
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	d12080e7          	jalr	-750(ra) # 80000c8a <release>
    80001f80:	b75d                	j	80001f26 <scheduler+0x64>

0000000080001f82 <sched>:
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    80001f82:	7179                	addi	sp,sp,-48
    80001f84:	f406                	sd	ra,40(sp)
    80001f86:	f022                	sd	s0,32(sp)
    80001f88:	ec26                	sd	s1,24(sp)
    80001f8a:	e84a                	sd	s2,16(sp)
    80001f8c:	e44e                	sd	s3,8(sp)
    80001f8e:	1800                	addi	s0,sp,48
  int intena;
  struct kthread *t = mykthread();
    80001f90:	00000097          	auipc	ra,0x0
    80001f94:	7ae080e7          	jalr	1966(ra) # 8000273e <mykthread>
    80001f98:	84aa                	mv	s1,a0

  if(!holding(&t->t_lock))
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	bc2080e7          	jalr	-1086(ra) # 80000b5c <holding>
    80001fa2:	c93d                	beqz	a0,80002018 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fa4:	8792                	mv	a5,tp
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    80001fa6:	2781                	sext.w	a5,a5
    80001fa8:	079e                	slli	a5,a5,0x7
    80001faa:	0000f717          	auipc	a4,0xf
    80001fae:	bc670713          	addi	a4,a4,-1082 # 80010b70 <pid_lock>
    80001fb2:	97ba                	add	a5,a5,a4
    80001fb4:	0a87a703          	lw	a4,168(a5)
    80001fb8:	4785                	li	a5,1
    80001fba:	06f71763          	bne	a4,a5,80002028 <sched+0xa6>
    panic("sched locks");
  if(t->t_state == RUNNING_t)
    80001fbe:	4c98                	lw	a4,24(s1)
    80001fc0:	4791                	li	a5,4
    80001fc2:	06f70b63          	beq	a4,a5,80002038 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fc6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fca:	8b89                	andi	a5,a5,2
    panic("sched running");
  if(intr_get())
    80001fcc:	efb5                	bnez	a5,80002048 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fce:	8792                	mv	a5,tp
    panic("sched interruptible");

  intena = mycpu()->intena;
    80001fd0:	0000f917          	auipc	s2,0xf
    80001fd4:	ba090913          	addi	s2,s2,-1120 # 80010b70 <pid_lock>
    80001fd8:	2781                	sext.w	a5,a5
    80001fda:	079e                	slli	a5,a5,0x7
    80001fdc:	97ca                	add	a5,a5,s2
    80001fde:	0ac7a983          	lw	s3,172(a5)
    80001fe2:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80001fe4:	2781                	sext.w	a5,a5
    80001fe6:	079e                	slli	a5,a5,0x7
    80001fe8:	0000f597          	auipc	a1,0xf
    80001fec:	bc058593          	addi	a1,a1,-1088 # 80010ba8 <cpus+0x8>
    80001ff0:	95be                	add	a1,a1,a5
    80001ff2:	04048513          	addi	a0,s1,64
    80001ff6:	00001097          	auipc	ra,0x1
    80001ffa:	8c2080e7          	jalr	-1854(ra) # 800028b8 <swtch>
    80001ffe:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002000:	2781                	sext.w	a5,a5
    80002002:	079e                	slli	a5,a5,0x7
    80002004:	97ca                	add	a5,a5,s2
    80002006:	0b37a623          	sw	s3,172(a5)
}
    8000200a:	70a2                	ld	ra,40(sp)
    8000200c:	7402                	ld	s0,32(sp)
    8000200e:	64e2                	ld	s1,24(sp)
    80002010:	6942                	ld	s2,16(sp)
    80002012:	69a2                	ld	s3,8(sp)
    80002014:	6145                	addi	sp,sp,48
    80002016:	8082                	ret
    panic("sched p->lock");
    80002018:	00006517          	auipc	a0,0x6
    8000201c:	20050513          	addi	a0,a0,512 # 80008218 <digits+0x1d8>
    80002020:	ffffe097          	auipc	ra,0xffffe
    80002024:	51e080e7          	jalr	1310(ra) # 8000053e <panic>
    panic("sched locks");
    80002028:	00006517          	auipc	a0,0x6
    8000202c:	20050513          	addi	a0,a0,512 # 80008228 <digits+0x1e8>
    80002030:	ffffe097          	auipc	ra,0xffffe
    80002034:	50e080e7          	jalr	1294(ra) # 8000053e <panic>
    panic("sched running");
    80002038:	00006517          	auipc	a0,0x6
    8000203c:	20050513          	addi	a0,a0,512 # 80008238 <digits+0x1f8>
    80002040:	ffffe097          	auipc	ra,0xffffe
    80002044:	4fe080e7          	jalr	1278(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002048:	00006517          	auipc	a0,0x6
    8000204c:	20050513          	addi	a0,a0,512 # 80008248 <digits+0x208>
    80002050:	ffffe097          	auipc	ra,0xffffe
    80002054:	4ee080e7          	jalr	1262(ra) # 8000053e <panic>

0000000080002058 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
    80002058:	1101                	addi	sp,sp,-32
    8000205a:	ec06                	sd	ra,24(sp)
    8000205c:	e822                	sd	s0,16(sp)
    8000205e:	e426                	sd	s1,8(sp)
    80002060:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002062:	00000097          	auipc	ra,0x0
    80002066:	91e080e7          	jalr	-1762(ra) # 80001980 <myproc>
    8000206a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	b6a080e7          	jalr	-1174(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002074:	478d                	li	a5,3
    80002076:	cc9c                	sw	a5,24(s1)
  sched();
    80002078:	00000097          	auipc	ra,0x0
    8000207c:	f0a080e7          	jalr	-246(ra) # 80001f82 <sched>
  release(&p->lock);
    80002080:	8526                	mv	a0,s1
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	c08080e7          	jalr	-1016(ra) # 80000c8a <release>
}
    8000208a:	60e2                	ld	ra,24(sp)
    8000208c:	6442                	ld	s0,16(sp)
    8000208e:	64a2                	ld	s1,8(sp)
    80002090:	6105                	addi	sp,sp,32
    80002092:	8082                	ret

0000000080002094 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80002094:	1141                	addi	sp,sp,-16
    80002096:	e406                	sd	ra,8(sp)
    80002098:	e022                	sd	s0,0(sp)
    8000209a:	0800                	addi	s0,sp,16
  static int first = 1;
  release(&(mykthread()->t_lock)); //still holding kt->lock from scheduler
    8000209c:	00000097          	auipc	ra,0x0
    800020a0:	6a2080e7          	jalr	1698(ra) # 8000273e <mykthread>
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	be6080e7          	jalr	-1050(ra) # 80000c8a <release>
  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800020ac:	00000097          	auipc	ra,0x0
    800020b0:	8d4080e7          	jalr	-1836(ra) # 80001980 <myproc>
    800020b4:	fffff097          	auipc	ra,0xfffff
    800020b8:	bd6080e7          	jalr	-1066(ra) # 80000c8a <release>

  if (first) {
    800020bc:	00006797          	auipc	a5,0x6
    800020c0:	7a47a783          	lw	a5,1956(a5) # 80008860 <first.1>
    800020c4:	eb89                	bnez	a5,800020d6 <forkret+0x42>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800020c6:	00001097          	auipc	ra,0x1
    800020ca:	89c080e7          	jalr	-1892(ra) # 80002962 <usertrapret>
}
    800020ce:	60a2                	ld	ra,8(sp)
    800020d0:	6402                	ld	s0,0(sp)
    800020d2:	0141                	addi	sp,sp,16
    800020d4:	8082                	ret
    first = 0;
    800020d6:	00006797          	auipc	a5,0x6
    800020da:	7807a523          	sw	zero,1930(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    800020de:	4505                	li	a0,1
    800020e0:	00001097          	auipc	ra,0x1
    800020e4:	62e080e7          	jalr	1582(ra) # 8000370e <fsinit>
    800020e8:	bff9                	j	800020c6 <forkret+0x32>

00000000800020ea <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020ea:	7179                	addi	sp,sp,-48
    800020ec:	f406                	sd	ra,40(sp)
    800020ee:	f022                	sd	s0,32(sp)
    800020f0:	ec26                	sd	s1,24(sp)
    800020f2:	e84a                	sd	s2,16(sp)
    800020f4:	e44e                	sd	s3,8(sp)
    800020f6:	e052                	sd	s4,0(sp)
    800020f8:	1800                	addi	s0,sp,48
    800020fa:	89aa                	mv	s3,a0
    800020fc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	882080e7          	jalr	-1918(ra) # 80001980 <myproc>
    80002106:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	ace080e7          	jalr	-1330(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    80002110:	02848a13          	addi	s4,s1,40
    80002114:	8552                	mv	a0,s4
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	ac0080e7          	jalr	-1344(ra) # 80000bd6 <acquire>
  release(lk);
    8000211e:	854a                	mv	a0,s2
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	b6a080e7          	jalr	-1174(ra) # 80000c8a <release>

  // Go to sleep.
  p->kthread[0].chan = chan;
    80002128:	0534b423          	sd	s3,72(s1)
  p->state = SLEEPING;
    8000212c:	4789                	li	a5,2
    8000212e:	cc9c                	sw	a5,24(s1)

  sched();
    80002130:	00000097          	auipc	ra,0x0
    80002134:	e52080e7          	jalr	-430(ra) # 80001f82 <sched>

  // Tidy up.
  p->kthread[0].chan= 0;
    80002138:	0404b423          	sd	zero,72(s1)

  // Reacquire original lock.
  release(&p->kthread[0].t_lock);
    8000213c:	8552                	mv	a0,s4
    8000213e:	fffff097          	auipc	ra,0xfffff
    80002142:	b4c080e7          	jalr	-1204(ra) # 80000c8a <release>
  release(&p->lock);
    80002146:	8526                	mv	a0,s1
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	b42080e7          	jalr	-1214(ra) # 80000c8a <release>
  acquire(lk);
    80002150:	854a                	mv	a0,s2
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	a84080e7          	jalr	-1404(ra) # 80000bd6 <acquire>
}
    8000215a:	70a2                	ld	ra,40(sp)
    8000215c:	7402                	ld	s0,32(sp)
    8000215e:	64e2                	ld	s1,24(sp)
    80002160:	6942                	ld	s2,16(sp)
    80002162:	69a2                	ld	s3,8(sp)
    80002164:	6a02                	ld	s4,0(sp)
    80002166:	6145                	addi	sp,sp,48
    80002168:	8082                	ret

000000008000216a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000216a:	7139                	addi	sp,sp,-64
    8000216c:	fc06                	sd	ra,56(sp)
    8000216e:	f822                	sd	s0,48(sp)
    80002170:	f426                	sd	s1,40(sp)
    80002172:	f04a                	sd	s2,32(sp)
    80002174:	ec4e                	sd	s3,24(sp)
    80002176:	e852                	sd	s4,16(sp)
    80002178:	e456                	sd	s5,8(sp)
    8000217a:	e05a                	sd	s6,0(sp)
    8000217c:	0080                	addi	s0,sp,64
    8000217e:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002180:	0000f497          	auipc	s1,0xf
    80002184:	e2048493          	addi	s1,s1,-480 # 80010fa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      acquire(&p->kthread[0].t_lock);
      if(p->state == SLEEPING && p->kthread[0].chan == chan) {
    80002188:	4a09                	li	s4,2
        p->state = RUNNABLE;
    8000218a:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000218c:	00016997          	auipc	s3,0x16
    80002190:	e1498993          	addi	s3,s3,-492 # 80017fa0 <tickslock>
    80002194:	a839                	j	800021b2 <wakeup+0x48>
      }
      release(&p->kthread[0].t_lock);
    80002196:	854a                	mv	a0,s2
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	af2080e7          	jalr	-1294(ra) # 80000c8a <release>
      release(&p->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	ae8080e7          	jalr	-1304(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021aa:	1c048493          	addi	s1,s1,448
    800021ae:	03348d63          	beq	s1,s3,800021e8 <wakeup+0x7e>
    if(p != myproc()){
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	7ce080e7          	jalr	1998(ra) # 80001980 <myproc>
    800021ba:	fea488e3          	beq	s1,a0,800021aa <wakeup+0x40>
      acquire(&p->lock);
    800021be:	8526                	mv	a0,s1
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	a16080e7          	jalr	-1514(ra) # 80000bd6 <acquire>
      acquire(&p->kthread[0].t_lock);
    800021c8:	02848913          	addi	s2,s1,40
    800021cc:	854a                	mv	a0,s2
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	a08080e7          	jalr	-1528(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->kthread[0].chan == chan) {
    800021d6:	4c9c                	lw	a5,24(s1)
    800021d8:	fb479fe3          	bne	a5,s4,80002196 <wakeup+0x2c>
    800021dc:	64bc                	ld	a5,72(s1)
    800021de:	fb579ce3          	bne	a5,s5,80002196 <wakeup+0x2c>
        p->state = RUNNABLE;
    800021e2:	0164ac23          	sw	s6,24(s1)
    800021e6:	bf45                	j	80002196 <wakeup+0x2c>
      
    }
  }
}
    800021e8:	70e2                	ld	ra,56(sp)
    800021ea:	7442                	ld	s0,48(sp)
    800021ec:	74a2                	ld	s1,40(sp)
    800021ee:	7902                	ld	s2,32(sp)
    800021f0:	69e2                	ld	s3,24(sp)
    800021f2:	6a42                	ld	s4,16(sp)
    800021f4:	6aa2                	ld	s5,8(sp)
    800021f6:	6b02                	ld	s6,0(sp)
    800021f8:	6121                	addi	sp,sp,64
    800021fa:	8082                	ret

00000000800021fc <reparent>:
{
    800021fc:	7179                	addi	sp,sp,-48
    800021fe:	f406                	sd	ra,40(sp)
    80002200:	f022                	sd	s0,32(sp)
    80002202:	ec26                	sd	s1,24(sp)
    80002204:	e84a                	sd	s2,16(sp)
    80002206:	e44e                	sd	s3,8(sp)
    80002208:	e052                	sd	s4,0(sp)
    8000220a:	1800                	addi	s0,sp,48
    8000220c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000220e:	0000f497          	auipc	s1,0xf
    80002212:	d9248493          	addi	s1,s1,-622 # 80010fa0 <proc>
      pp->parent = initproc;
    80002216:	00006a17          	auipc	s4,0x6
    8000221a:	6e2a0a13          	addi	s4,s4,1762 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000221e:	00016997          	auipc	s3,0x16
    80002222:	d8298993          	addi	s3,s3,-638 # 80017fa0 <tickslock>
    80002226:	a029                	j	80002230 <reparent+0x34>
    80002228:	1c048493          	addi	s1,s1,448
    8000222c:	01348d63          	beq	s1,s3,80002246 <reparent+0x4a>
    if(pp->parent == p){
    80002230:	78fc                	ld	a5,240(s1)
    80002232:	ff279be3          	bne	a5,s2,80002228 <reparent+0x2c>
      pp->parent = initproc;
    80002236:	000a3503          	ld	a0,0(s4)
    8000223a:	f8e8                	sd	a0,240(s1)
      wakeup(initproc);
    8000223c:	00000097          	auipc	ra,0x0
    80002240:	f2e080e7          	jalr	-210(ra) # 8000216a <wakeup>
    80002244:	b7d5                	j	80002228 <reparent+0x2c>
}
    80002246:	70a2                	ld	ra,40(sp)
    80002248:	7402                	ld	s0,32(sp)
    8000224a:	64e2                	ld	s1,24(sp)
    8000224c:	6942                	ld	s2,16(sp)
    8000224e:	69a2                	ld	s3,8(sp)
    80002250:	6a02                	ld	s4,0(sp)
    80002252:	6145                	addi	sp,sp,48
    80002254:	8082                	ret

0000000080002256 <exit>:
{
    80002256:	7139                	addi	sp,sp,-64
    80002258:	fc06                	sd	ra,56(sp)
    8000225a:	f822                	sd	s0,48(sp)
    8000225c:	f426                	sd	s1,40(sp)
    8000225e:	f04a                	sd	s2,32(sp)
    80002260:	ec4e                	sd	s3,24(sp)
    80002262:	e852                	sd	s4,16(sp)
    80002264:	e456                	sd	s5,8(sp)
    80002266:	0080                	addi	s0,sp,64
    80002268:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	716080e7          	jalr	1814(ra) # 80001980 <myproc>
    80002272:	89aa                	mv	s3,a0
  if(p == initproc)
    80002274:	00006797          	auipc	a5,0x6
    80002278:	6847b783          	ld	a5,1668(a5) # 800088f8 <initproc>
    8000227c:	10850493          	addi	s1,a0,264
    80002280:	18850913          	addi	s2,a0,392
    80002284:	02a79363          	bne	a5,a0,800022aa <exit+0x54>
    panic("init exiting");
    80002288:	00006517          	auipc	a0,0x6
    8000228c:	fd850513          	addi	a0,a0,-40 # 80008260 <digits+0x220>
    80002290:	ffffe097          	auipc	ra,0xffffe
    80002294:	2ae080e7          	jalr	686(ra) # 8000053e <panic>
      fileclose(f);
    80002298:	00002097          	auipc	ra,0x2
    8000229c:	580080e7          	jalr	1408(ra) # 80004818 <fileclose>
      p->ofile[fd] = 0;
    800022a0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022a4:	04a1                	addi	s1,s1,8
    800022a6:	01248563          	beq	s1,s2,800022b0 <exit+0x5a>
    if(p->ofile[fd]){
    800022aa:	6088                	ld	a0,0(s1)
    800022ac:	f575                	bnez	a0,80002298 <exit+0x42>
    800022ae:	bfdd                	j	800022a4 <exit+0x4e>
  begin_op();
    800022b0:	00002097          	auipc	ra,0x2
    800022b4:	09c080e7          	jalr	156(ra) # 8000434c <begin_op>
  iput(p->cwd);
    800022b8:	1889b503          	ld	a0,392(s3)
    800022bc:	00002097          	auipc	ra,0x2
    800022c0:	888080e7          	jalr	-1912(ra) # 80003b44 <iput>
  end_op();
    800022c4:	00002097          	auipc	ra,0x2
    800022c8:	108080e7          	jalr	264(ra) # 800043cc <end_op>
  p->cwd = 0;
    800022cc:	1809b423          	sd	zero,392(s3)
  acquire(&wait_lock);
    800022d0:	0000f497          	auipc	s1,0xf
    800022d4:	8b848493          	addi	s1,s1,-1864 # 80010b88 <wait_lock>
    800022d8:	8526                	mv	a0,s1
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	8fc080e7          	jalr	-1796(ra) # 80000bd6 <acquire>
  reparent(p);
    800022e2:	854e                	mv	a0,s3
    800022e4:	00000097          	auipc	ra,0x0
    800022e8:	f18080e7          	jalr	-232(ra) # 800021fc <reparent>
  wakeup(p->parent);
    800022ec:	0f09b503          	ld	a0,240(s3)
    800022f0:	00000097          	auipc	ra,0x0
    800022f4:	e7a080e7          	jalr	-390(ra) # 8000216a <wakeup>
  acquire(&p->lock);
    800022f8:	854e                	mv	a0,s3
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	8dc080e7          	jalr	-1828(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    80002302:	02898a93          	addi	s5,s3,40
    80002306:	8556                	mv	a0,s5
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	8ce080e7          	jalr	-1842(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state=ZOMBIE_t;
    80002310:	4915                	li	s2,5
    80002312:	0529a023          	sw	s2,64(s3)
  release(&p->kthread[0].t_lock);
    80002316:	8556                	mv	a0,s5
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	972080e7          	jalr	-1678(ra) # 80000c8a <release>
  p->xstate = status;
    80002320:	0349a023          	sw	s4,32(s3)
  p->state = ZOMBIE;
    80002324:	0129ac23          	sw	s2,24(s3)
  release(&wait_lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	960080e7          	jalr	-1696(ra) # 80000c8a <release>
  sched();
    80002332:	00000097          	auipc	ra,0x0
    80002336:	c50080e7          	jalr	-944(ra) # 80001f82 <sched>
  panic("zombie exit");
    8000233a:	00006517          	auipc	a0,0x6
    8000233e:	f3650513          	addi	a0,a0,-202 # 80008270 <digits+0x230>
    80002342:	ffffe097          	auipc	ra,0xffffe
    80002346:	1fc080e7          	jalr	508(ra) # 8000053e <panic>

000000008000234a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000234a:	7179                	addi	sp,sp,-48
    8000234c:	f406                	sd	ra,40(sp)
    8000234e:	f022                	sd	s0,32(sp)
    80002350:	ec26                	sd	s1,24(sp)
    80002352:	e84a                	sd	s2,16(sp)
    80002354:	e44e                	sd	s3,8(sp)
    80002356:	1800                	addi	s0,sp,48
    80002358:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000235a:	0000f497          	auipc	s1,0xf
    8000235e:	c4648493          	addi	s1,s1,-954 # 80010fa0 <proc>
    80002362:	00016997          	auipc	s3,0x16
    80002366:	c3e98993          	addi	s3,s3,-962 # 80017fa0 <tickslock>
    acquire(&p->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	86a080e7          	jalr	-1942(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002374:	50dc                	lw	a5,36(s1)
    80002376:	01278d63          	beq	a5,s2,80002390 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	90e080e7          	jalr	-1778(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002384:	1c048493          	addi	s1,s1,448
    80002388:	ff3491e3          	bne	s1,s3,8000236a <kill+0x20>
  }
  return -1;
    8000238c:	557d                	li	a0,-1
    8000238e:	a82d                	j	800023c8 <kill+0x7e>
      p->killed = 1;
    80002390:	4785                	li	a5,1
    80002392:	ccdc                	sw	a5,28(s1)
        acquire(&t->t_lock);
    80002394:	02848913          	addi	s2,s1,40
    80002398:	854a                	mv	a0,s2
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	83c080e7          	jalr	-1988(ra) # 80000bd6 <acquire>
        if(t->t_state == SLEEPING_t) {
    800023a2:	40b8                	lw	a4,64(s1)
    800023a4:	4789                	li	a5,2
    800023a6:	02f70863          	beq	a4,a5,800023d6 <kill+0x8c>
        release(&t->t_lock);
    800023aa:	854a                	mv	a0,s2
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	8de080e7          	jalr	-1826(ra) # 80000c8a <release>
      if(p->state == SLEEPING){
    800023b4:	4c98                	lw	a4,24(s1)
    800023b6:	4789                	li	a5,2
    800023b8:	02f70263          	beq	a4,a5,800023dc <kill+0x92>
      release(&p->lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	8cc080e7          	jalr	-1844(ra) # 80000c8a <release>
      return 0;
    800023c6:	4501                	li	a0,0
}
    800023c8:	70a2                	ld	ra,40(sp)
    800023ca:	7402                	ld	s0,32(sp)
    800023cc:	64e2                	ld	s1,24(sp)
    800023ce:	6942                	ld	s2,16(sp)
    800023d0:	69a2                	ld	s3,8(sp)
    800023d2:	6145                	addi	sp,sp,48
    800023d4:	8082                	ret
          t->t_state = RUNNABLE_t;
    800023d6:	478d                	li	a5,3
    800023d8:	c0bc                	sw	a5,64(s1)
    800023da:	bfc1                	j	800023aa <kill+0x60>
        p->state = RUNNABLE;
    800023dc:	478d                	li	a5,3
    800023de:	cc9c                	sw	a5,24(s1)
    800023e0:	bff1                	j	800023bc <kill+0x72>

00000000800023e2 <setkilled>:


void
setkilled(struct proc *p)
{
    800023e2:	1101                	addi	sp,sp,-32
    800023e4:	ec06                	sd	ra,24(sp)
    800023e6:	e822                	sd	s0,16(sp)
    800023e8:	e426                	sd	s1,8(sp)
    800023ea:	1000                	addi	s0,sp,32
    800023ec:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023ee:	ffffe097          	auipc	ra,0xffffe
    800023f2:	7e8080e7          	jalr	2024(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800023f6:	4785                	li	a5,1
    800023f8:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    800023fa:	8526                	mv	a0,s1
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	88e080e7          	jalr	-1906(ra) # 80000c8a <release>
}
    80002404:	60e2                	ld	ra,24(sp)
    80002406:	6442                	ld	s0,16(sp)
    80002408:	64a2                	ld	s1,8(sp)
    8000240a:	6105                	addi	sp,sp,32
    8000240c:	8082                	ret

000000008000240e <killed>:

int
killed(struct proc *p)
{
    8000240e:	1101                	addi	sp,sp,-32
    80002410:	ec06                	sd	ra,24(sp)
    80002412:	e822                	sd	s0,16(sp)
    80002414:	e426                	sd	s1,8(sp)
    80002416:	e04a                	sd	s2,0(sp)
    80002418:	1000                	addi	s0,sp,32
    8000241a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000241c:	ffffe097          	auipc	ra,0xffffe
    80002420:	7ba080e7          	jalr	1978(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002424:	01c4a903          	lw	s2,28(s1)
  release(&p->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	860080e7          	jalr	-1952(ra) # 80000c8a <release>
  return k;
}
    80002432:	854a                	mv	a0,s2
    80002434:	60e2                	ld	ra,24(sp)
    80002436:	6442                	ld	s0,16(sp)
    80002438:	64a2                	ld	s1,8(sp)
    8000243a:	6902                	ld	s2,0(sp)
    8000243c:	6105                	addi	sp,sp,32
    8000243e:	8082                	ret

0000000080002440 <wait>:
{
    80002440:	715d                	addi	sp,sp,-80
    80002442:	e486                	sd	ra,72(sp)
    80002444:	e0a2                	sd	s0,64(sp)
    80002446:	fc26                	sd	s1,56(sp)
    80002448:	f84a                	sd	s2,48(sp)
    8000244a:	f44e                	sd	s3,40(sp)
    8000244c:	f052                	sd	s4,32(sp)
    8000244e:	ec56                	sd	s5,24(sp)
    80002450:	e85a                	sd	s6,16(sp)
    80002452:	e45e                	sd	s7,8(sp)
    80002454:	e062                	sd	s8,0(sp)
    80002456:	0880                	addi	s0,sp,80
    80002458:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	526080e7          	jalr	1318(ra) # 80001980 <myproc>
    80002462:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002464:	0000e517          	auipc	a0,0xe
    80002468:	72450513          	addi	a0,a0,1828 # 80010b88 <wait_lock>
    8000246c:	ffffe097          	auipc	ra,0xffffe
    80002470:	76a080e7          	jalr	1898(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002474:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002476:	4a15                	li	s4,5
        havekids = 1;
    80002478:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000247a:	00016997          	auipc	s3,0x16
    8000247e:	b2698993          	addi	s3,s3,-1242 # 80017fa0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002482:	0000ec17          	auipc	s8,0xe
    80002486:	706c0c13          	addi	s8,s8,1798 # 80010b88 <wait_lock>
    havekids = 0;
    8000248a:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000248c:	0000f497          	auipc	s1,0xf
    80002490:	b1448493          	addi	s1,s1,-1260 # 80010fa0 <proc>
    80002494:	a0bd                	j	80002502 <wait+0xc2>
          pid = pp->pid;
    80002496:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000249a:	000b0e63          	beqz	s6,800024b6 <wait+0x76>
    8000249e:	4691                	li	a3,4
    800024a0:	02048613          	addi	a2,s1,32
    800024a4:	85da                	mv	a1,s6
    800024a6:	10093503          	ld	a0,256(s2)
    800024aa:	fffff097          	auipc	ra,0xfffff
    800024ae:	1be080e7          	jalr	446(ra) # 80001668 <copyout>
    800024b2:	02054563          	bltz	a0,800024dc <wait+0x9c>
          freeproc(pp);
    800024b6:	8526                	mv	a0,s1
    800024b8:	fffff097          	auipc	ra,0xfffff
    800024bc:	652080e7          	jalr	1618(ra) # 80001b0a <freeproc>
          release(&pp->lock);
    800024c0:	8526                	mv	a0,s1
    800024c2:	ffffe097          	auipc	ra,0xffffe
    800024c6:	7c8080e7          	jalr	1992(ra) # 80000c8a <release>
          release(&wait_lock);
    800024ca:	0000e517          	auipc	a0,0xe
    800024ce:	6be50513          	addi	a0,a0,1726 # 80010b88 <wait_lock>
    800024d2:	ffffe097          	auipc	ra,0xffffe
    800024d6:	7b8080e7          	jalr	1976(ra) # 80000c8a <release>
          return pid;
    800024da:	a0b5                	j	80002546 <wait+0x106>
            release(&pp->lock);
    800024dc:	8526                	mv	a0,s1
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	7ac080e7          	jalr	1964(ra) # 80000c8a <release>
            release(&wait_lock);
    800024e6:	0000e517          	auipc	a0,0xe
    800024ea:	6a250513          	addi	a0,a0,1698 # 80010b88 <wait_lock>
    800024ee:	ffffe097          	auipc	ra,0xffffe
    800024f2:	79c080e7          	jalr	1948(ra) # 80000c8a <release>
            return -1;
    800024f6:	59fd                	li	s3,-1
    800024f8:	a0b9                	j	80002546 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024fa:	1c048493          	addi	s1,s1,448
    800024fe:	03348463          	beq	s1,s3,80002526 <wait+0xe6>
      if(pp->parent == p){
    80002502:	78fc                	ld	a5,240(s1)
    80002504:	ff279be3          	bne	a5,s2,800024fa <wait+0xba>
        acquire(&pp->lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	6cc080e7          	jalr	1740(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002512:	4c9c                	lw	a5,24(s1)
    80002514:	f94781e3          	beq	a5,s4,80002496 <wait+0x56>
        release(&pp->lock);
    80002518:	8526                	mv	a0,s1
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	770080e7          	jalr	1904(ra) # 80000c8a <release>
        havekids = 1;
    80002522:	8756                	mv	a4,s5
    80002524:	bfd9                	j	800024fa <wait+0xba>
    if(!havekids || killed(p)){
    80002526:	c719                	beqz	a4,80002534 <wait+0xf4>
    80002528:	854a                	mv	a0,s2
    8000252a:	00000097          	auipc	ra,0x0
    8000252e:	ee4080e7          	jalr	-284(ra) # 8000240e <killed>
    80002532:	c51d                	beqz	a0,80002560 <wait+0x120>
      release(&wait_lock);
    80002534:	0000e517          	auipc	a0,0xe
    80002538:	65450513          	addi	a0,a0,1620 # 80010b88 <wait_lock>
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	74e080e7          	jalr	1870(ra) # 80000c8a <release>
      return -1;
    80002544:	59fd                	li	s3,-1
}
    80002546:	854e                	mv	a0,s3
    80002548:	60a6                	ld	ra,72(sp)
    8000254a:	6406                	ld	s0,64(sp)
    8000254c:	74e2                	ld	s1,56(sp)
    8000254e:	7942                	ld	s2,48(sp)
    80002550:	79a2                	ld	s3,40(sp)
    80002552:	7a02                	ld	s4,32(sp)
    80002554:	6ae2                	ld	s5,24(sp)
    80002556:	6b42                	ld	s6,16(sp)
    80002558:	6ba2                	ld	s7,8(sp)
    8000255a:	6c02                	ld	s8,0(sp)
    8000255c:	6161                	addi	sp,sp,80
    8000255e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002560:	85e2                	mv	a1,s8
    80002562:	854a                	mv	a0,s2
    80002564:	00000097          	auipc	ra,0x0
    80002568:	b86080e7          	jalr	-1146(ra) # 800020ea <sleep>
    havekids = 0;
    8000256c:	bf39                	j	8000248a <wait+0x4a>

000000008000256e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000256e:	7179                	addi	sp,sp,-48
    80002570:	f406                	sd	ra,40(sp)
    80002572:	f022                	sd	s0,32(sp)
    80002574:	ec26                	sd	s1,24(sp)
    80002576:	e84a                	sd	s2,16(sp)
    80002578:	e44e                	sd	s3,8(sp)
    8000257a:	e052                	sd	s4,0(sp)
    8000257c:	1800                	addi	s0,sp,48
    8000257e:	84aa                	mv	s1,a0
    80002580:	892e                	mv	s2,a1
    80002582:	89b2                	mv	s3,a2
    80002584:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002586:	fffff097          	auipc	ra,0xfffff
    8000258a:	3fa080e7          	jalr	1018(ra) # 80001980 <myproc>
  if(user_dst){
    8000258e:	c095                	beqz	s1,800025b2 <either_copyout+0x44>
    return copyout(p->pagetable, dst, src, len);
    80002590:	86d2                	mv	a3,s4
    80002592:	864e                	mv	a2,s3
    80002594:	85ca                	mv	a1,s2
    80002596:	10053503          	ld	a0,256(a0)
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	0ce080e7          	jalr	206(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025a2:	70a2                	ld	ra,40(sp)
    800025a4:	7402                	ld	s0,32(sp)
    800025a6:	64e2                	ld	s1,24(sp)
    800025a8:	6942                	ld	s2,16(sp)
    800025aa:	69a2                	ld	s3,8(sp)
    800025ac:	6a02                	ld	s4,0(sp)
    800025ae:	6145                	addi	sp,sp,48
    800025b0:	8082                	ret
    memmove((char *)dst, src, len);
    800025b2:	000a061b          	sext.w	a2,s4
    800025b6:	85ce                	mv	a1,s3
    800025b8:	854a                	mv	a0,s2
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	774080e7          	jalr	1908(ra) # 80000d2e <memmove>
    return 0;
    800025c2:	8526                	mv	a0,s1
    800025c4:	bff9                	j	800025a2 <either_copyout+0x34>

00000000800025c6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025c6:	7179                	addi	sp,sp,-48
    800025c8:	f406                	sd	ra,40(sp)
    800025ca:	f022                	sd	s0,32(sp)
    800025cc:	ec26                	sd	s1,24(sp)
    800025ce:	e84a                	sd	s2,16(sp)
    800025d0:	e44e                	sd	s3,8(sp)
    800025d2:	e052                	sd	s4,0(sp)
    800025d4:	1800                	addi	s0,sp,48
    800025d6:	892a                	mv	s2,a0
    800025d8:	84ae                	mv	s1,a1
    800025da:	89b2                	mv	s3,a2
    800025dc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025de:	fffff097          	auipc	ra,0xfffff
    800025e2:	3a2080e7          	jalr	930(ra) # 80001980 <myproc>
  if(user_src){
    800025e6:	c095                	beqz	s1,8000260a <either_copyin+0x44>
    return copyin(p->pagetable, dst, src, len);
    800025e8:	86d2                	mv	a3,s4
    800025ea:	864e                	mv	a2,s3
    800025ec:	85ca                	mv	a1,s2
    800025ee:	10053503          	ld	a0,256(a0)
    800025f2:	fffff097          	auipc	ra,0xfffff
    800025f6:	102080e7          	jalr	258(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025fa:	70a2                	ld	ra,40(sp)
    800025fc:	7402                	ld	s0,32(sp)
    800025fe:	64e2                	ld	s1,24(sp)
    80002600:	6942                	ld	s2,16(sp)
    80002602:	69a2                	ld	s3,8(sp)
    80002604:	6a02                	ld	s4,0(sp)
    80002606:	6145                	addi	sp,sp,48
    80002608:	8082                	ret
    memmove(dst, (char*)src, len);
    8000260a:	000a061b          	sext.w	a2,s4
    8000260e:	85ce                	mv	a1,s3
    80002610:	854a                	mv	a0,s2
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	71c080e7          	jalr	1820(ra) # 80000d2e <memmove>
    return 0;
    8000261a:	8526                	mv	a0,s1
    8000261c:	bff9                	j	800025fa <either_copyin+0x34>

000000008000261e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000261e:	715d                	addi	sp,sp,-80
    80002620:	e486                	sd	ra,72(sp)
    80002622:	e0a2                	sd	s0,64(sp)
    80002624:	fc26                	sd	s1,56(sp)
    80002626:	f84a                	sd	s2,48(sp)
    80002628:	f44e                	sd	s3,40(sp)
    8000262a:	f052                	sd	s4,32(sp)
    8000262c:	ec56                	sd	s5,24(sp)
    8000262e:	e85a                	sd	s6,16(sp)
    80002630:	e45e                	sd	s7,8(sp)
    80002632:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002634:	00006517          	auipc	a0,0x6
    80002638:	a9450513          	addi	a0,a0,-1388 # 800080c8 <digits+0x88>
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	f4c080e7          	jalr	-180(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002644:	0000f497          	auipc	s1,0xf
    80002648:	aec48493          	addi	s1,s1,-1300 # 80011130 <proc+0x190>
    8000264c:	00016917          	auipc	s2,0x16
    80002650:	ae490913          	addi	s2,s2,-1308 # 80018130 <bcache+0x178>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002654:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002656:	00006997          	auipc	s3,0x6
    8000265a:	c2a98993          	addi	s3,s3,-982 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000265e:	00006a97          	auipc	s5,0x6
    80002662:	c2aa8a93          	addi	s5,s5,-982 # 80008288 <digits+0x248>
    printf("\n");
    80002666:	00006a17          	auipc	s4,0x6
    8000266a:	a62a0a13          	addi	s4,s4,-1438 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000266e:	00006b97          	auipc	s7,0x6
    80002672:	c5ab8b93          	addi	s7,s7,-934 # 800082c8 <states.0>
    80002676:	a00d                	j	80002698 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002678:	e946a583          	lw	a1,-364(a3)
    8000267c:	8556                	mv	a0,s5
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	f0a080e7          	jalr	-246(ra) # 80000588 <printf>
    printf("\n");
    80002686:	8552                	mv	a0,s4
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	f00080e7          	jalr	-256(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002690:	1c048493          	addi	s1,s1,448
    80002694:	03248163          	beq	s1,s2,800026b6 <procdump+0x98>
    if(p->state == UNUSED)
    80002698:	86a6                	mv	a3,s1
    8000269a:	e884a783          	lw	a5,-376(s1)
    8000269e:	dbed                	beqz	a5,80002690 <procdump+0x72>
      state = "???";
    800026a0:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026a2:	fcfb6be3          	bltu	s6,a5,80002678 <procdump+0x5a>
    800026a6:	1782                	slli	a5,a5,0x20
    800026a8:	9381                	srli	a5,a5,0x20
    800026aa:	078e                	slli	a5,a5,0x3
    800026ac:	97de                	add	a5,a5,s7
    800026ae:	6390                	ld	a2,0(a5)
    800026b0:	f661                	bnez	a2,80002678 <procdump+0x5a>
      state = "???";
    800026b2:	864e                	mv	a2,s3
    800026b4:	b7d1                	j	80002678 <procdump+0x5a>
  }
}
    800026b6:	60a6                	ld	ra,72(sp)
    800026b8:	6406                	ld	s0,64(sp)
    800026ba:	74e2                	ld	s1,56(sp)
    800026bc:	7942                	ld	s2,48(sp)
    800026be:	79a2                	ld	s3,40(sp)
    800026c0:	7a02                	ld	s4,32(sp)
    800026c2:	6ae2                	ld	s5,24(sp)
    800026c4:	6b42                	ld	s6,16(sp)
    800026c6:	6ba2                	ld	s7,8(sp)
    800026c8:	6161                	addi	sp,sp,80
    800026ca:	8082                	ret

00000000800026cc <kthreadinit>:
#include "defs.h"

extern struct proc proc[NPROC];
extern void forkret(void);
void kthreadinit(struct proc *p)
{
    800026cc:	1101                	addi	sp,sp,-32
    800026ce:	ec06                	sd	ra,24(sp)
    800026d0:	e822                	sd	s0,16(sp)
    800026d2:	e426                	sd	s1,8(sp)
    800026d4:	1000                	addi	s0,sp,32
    800026d6:	84aa                	mv	s1,a0
  initlock(&(p->alloc_lock),"aloc_thread");
    800026d8:	00006597          	auipc	a1,0x6
    800026dc:	c2058593          	addi	a1,a1,-992 # 800082f8 <states.0+0x30>
    800026e0:	1a850513          	addi	a0,a0,424
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	462080e7          	jalr	1122(ra) # 80000b46 <initlock>
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
    800026ec:	00006597          	auipc	a1,0x6
    800026f0:	c1c58593          	addi	a1,a1,-996 # 80008308 <states.0+0x40>
    800026f4:	02848513          	addi	a0,s1,40
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	44e080e7          	jalr	1102(ra) # 80000b46 <initlock>
      kt->t_state = UNUSED_t;
    80002700:	0404a023          	sw	zero,64(s1)
      kt->process=p;
    80002704:	f0a4                	sd	s1,96(s1)
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    80002706:	0000f797          	auipc	a5,0xf
    8000270a:	89a78793          	addi	a5,a5,-1894 # 80010fa0 <proc>
    8000270e:	40f487b3          	sub	a5,s1,a5
    80002712:	8799                	srai	a5,a5,0x6
    80002714:	00006717          	auipc	a4,0x6
    80002718:	8ec73703          	ld	a4,-1812(a4) # 80008000 <etext>
    8000271c:	02e787b3          	mul	a5,a5,a4
    80002720:	2785                	addiw	a5,a5,1
    80002722:	00d7979b          	slliw	a5,a5,0xd
    80002726:	04000737          	lui	a4,0x4000
    8000272a:	177d                	addi	a4,a4,-1
    8000272c:	0732                	slli	a4,a4,0xc
    8000272e:	40f707b3          	sub	a5,a4,a5
    80002732:	ecfc                	sd	a5,216(s1)
  }
}
    80002734:	60e2                	ld	ra,24(sp)
    80002736:	6442                	ld	s0,16(sp)
    80002738:	64a2                	ld	s1,8(sp)
    8000273a:	6105                	addi	sp,sp,32
    8000273c:	8082                	ret

000000008000273e <mykthread>:

struct kthread *mykthread()
{
    8000273e:	1101                	addi	sp,sp,-32
    80002740:	ec06                	sd	ra,24(sp)
    80002742:	e822                	sd	s0,16(sp)
    80002744:	e426                	sd	s1,8(sp)
    80002746:	1000                	addi	s0,sp,32
  push_off();
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	442080e7          	jalr	1090(ra) # 80000b8a <push_off>
  struct cpu *c = mycpu();
    80002750:	fffff097          	auipc	ra,0xfffff
    80002754:	214080e7          	jalr	532(ra) # 80001964 <mycpu>
  struct kthread *kthread = c->kthread;
    80002758:	6104                	ld	s1,0(a0)
  pop_off();
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	4d0080e7          	jalr	1232(ra) # 80000c2a <pop_off>
  return kthread;
}
    80002762:	8526                	mv	a0,s1
    80002764:	60e2                	ld	ra,24(sp)
    80002766:	6442                	ld	s0,16(sp)
    80002768:	64a2                	ld	s1,8(sp)
    8000276a:	6105                	addi	sp,sp,32
    8000276c:	8082                	ret

000000008000276e <alloctid>:

int alloctid(struct proc *p){
    8000276e:	7179                	addi	sp,sp,-48
    80002770:	f406                	sd	ra,40(sp)
    80002772:	f022                	sd	s0,32(sp)
    80002774:	ec26                	sd	s1,24(sp)
    80002776:	e84a                	sd	s2,16(sp)
    80002778:	e44e                	sd	s3,8(sp)
    8000277a:	1800                	addi	s0,sp,48
    8000277c:	84aa                	mv	s1,a0
  int tid;
  acquire(&(p->alloc_lock));
    8000277e:	1a850993          	addi	s3,a0,424
    80002782:	854e                	mv	a0,s3
    80002784:	ffffe097          	auipc	ra,0xffffe
    80002788:	452080e7          	jalr	1106(ra) # 80000bd6 <acquire>
  tid = p->p_counter;
    8000278c:	1a04a903          	lw	s2,416(s1)
  p->p_counter++;
    80002790:	0019079b          	addiw	a5,s2,1
    80002794:	1af4a023          	sw	a5,416(s1)
  release(&(p->alloc_lock));
    80002798:	854e                	mv	a0,s3
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	4f0080e7          	jalr	1264(ra) # 80000c8a <release>
  return tid;
}
    800027a2:	854a                	mv	a0,s2
    800027a4:	70a2                	ld	ra,40(sp)
    800027a6:	7402                	ld	s0,32(sp)
    800027a8:	64e2                	ld	s1,24(sp)
    800027aa:	6942                	ld	s2,16(sp)
    800027ac:	69a2                	ld	s3,8(sp)
    800027ae:	6145                	addi	sp,sp,48
    800027b0:	8082                	ret

00000000800027b2 <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    800027b2:	1141                	addi	sp,sp,-16
    800027b4:	e422                	sd	s0,8(sp)
    800027b6:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    800027b8:	02850793          	addi	a5,a0,40
    800027bc:	8d9d                	sub	a1,a1,a5
    800027be:	8599                	srai	a1,a1,0x6
    800027c0:	00006797          	auipc	a5,0x6
    800027c4:	8487b783          	ld	a5,-1976(a5) # 80008008 <etext+0x8>
    800027c8:	02f585bb          	mulw	a1,a1,a5
    800027cc:	00359793          	slli	a5,a1,0x3
    800027d0:	95be                	add	a1,a1,a5
    800027d2:	0596                	slli	a1,a1,0x5
    800027d4:	7568                	ld	a0,232(a0)
}
    800027d6:	952e                	add	a0,a0,a1
    800027d8:	6422                	ld	s0,8(sp)
    800027da:	0141                	addi	sp,sp,16
    800027dc:	8082                	ret

00000000800027de <allockthread>:

struct kthread* allockthread(struct proc *p){
    800027de:	1101                	addi	sp,sp,-32
    800027e0:	ec06                	sd	ra,24(sp)
    800027e2:	e822                	sd	s0,16(sp)
    800027e4:	e426                	sd	s1,8(sp)
    800027e6:	e04a                	sd	s2,0(sp)
    800027e8:	1000                	addi	s0,sp,32
    800027ea:	84aa                	mv	s1,a0
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    800027ec:	02850913          	addi	s2,a0,40
    {
      acquire(&kt->t_lock);
    800027f0:	854a                	mv	a0,s2
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	3e4080e7          	jalr	996(ra) # 80000bd6 <acquire>
      if(kt->t_state == UNUSED_t) {
    800027fa:	40bc                	lw	a5,64(s1)
    800027fc:	cf91                	beqz	a5,80002818 <allockthread+0x3a>
        kt->context.ra = (uint64)forkret;
        kt->context.sp = kt->kstack + PGSIZE;
        return kt;
      } 
      else {
        release(&kt->t_lock);
    800027fe:	854a                	mv	a0,s2
    80002800:	ffffe097          	auipc	ra,0xffffe
    80002804:	48a080e7          	jalr	1162(ra) # 80000c8a <release>
      }
  }
  return 0;
    80002808:	4901                	li	s2,0
}
    8000280a:	854a                	mv	a0,s2
    8000280c:	60e2                	ld	ra,24(sp)
    8000280e:	6442                	ld	s0,16(sp)
    80002810:	64a2                	ld	s1,8(sp)
    80002812:	6902                	ld	s2,0(sp)
    80002814:	6105                	addi	sp,sp,32
    80002816:	8082                	ret
        kt->tid = alloctid(p);
    80002818:	8526                	mv	a0,s1
    8000281a:	00000097          	auipc	ra,0x0
    8000281e:	f54080e7          	jalr	-172(ra) # 8000276e <alloctid>
    80002822:	cca8                	sw	a0,88(s1)
        kt->t_state = USED_t;
    80002824:	4785                	li	a5,1
    80002826:	c0bc                	sw	a5,64(s1)
        kt->trapframe = get_kthread_trapframe(p,kt);
    80002828:	85ca                	mv	a1,s2
    8000282a:	8526                	mv	a0,s1
    8000282c:	00000097          	auipc	ra,0x0
    80002830:	f86080e7          	jalr	-122(ra) # 800027b2 <get_kthread_trapframe>
    80002834:	f0e8                	sd	a0,224(s1)
        memset(&kt->context, 0, sizeof(kt->context));
    80002836:	07000613          	li	a2,112
    8000283a:	4581                	li	a1,0
    8000283c:	06848513          	addi	a0,s1,104
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	492080e7          	jalr	1170(ra) # 80000cd2 <memset>
        kt->context.ra = (uint64)forkret;
    80002848:	00000797          	auipc	a5,0x0
    8000284c:	84c78793          	addi	a5,a5,-1972 # 80002094 <forkret>
    80002850:	f4bc                	sd	a5,104(s1)
        kt->context.sp = kt->kstack + PGSIZE;
    80002852:	6cfc                	ld	a5,216(s1)
    80002854:	6705                	lui	a4,0x1
    80002856:	97ba                	add	a5,a5,a4
    80002858:	f8bc                	sd	a5,112(s1)
        return kt;
    8000285a:	bf45                	j	8000280a <allockthread+0x2c>

000000008000285c <freethread>:

void
freethread(struct kthread *t){
    8000285c:	1101                	addi	sp,sp,-32
    8000285e:	ec06                	sd	ra,24(sp)
    80002860:	e822                	sd	s0,16(sp)
    80002862:	e426                	sd	s1,8(sp)
    80002864:	1000                	addi	s0,sp,32
    80002866:	84aa                	mv	s1,a0
  t->chan = 0;
    80002868:	02053023          	sd	zero,32(a0)
  t->t_killed = 0;
    8000286c:	02052423          	sw	zero,40(a0)
  t->t_xstate = 0;
    80002870:	02052623          	sw	zero,44(a0)
  t->t_state = UNUSED_t;
    80002874:	00052c23          	sw	zero,24(a0)
  t->tid=0;
    80002878:	02052823          	sw	zero,48(a0)
  t->process=0;
    8000287c:	02053c23          	sd	zero,56(a0)
  t->kstack=0;
    80002880:	0a053823          	sd	zero,176(a0)
  if(t->trapframe)
    80002884:	7d48                	ld	a0,184(a0)
    80002886:	c509                	beqz	a0,80002890 <freethread+0x34>
    kfree((void*)t->trapframe);
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	162080e7          	jalr	354(ra) # 800009ea <kfree>
  t->trapframe = 0;
    80002890:	0a04bc23          	sd	zero,184(s1)
  memset(&t->context,0,sizeof(&t->context));
    80002894:	4621                	li	a2,8
    80002896:	4581                	li	a1,0
    80002898:	04048513          	addi	a0,s1,64
    8000289c:	ffffe097          	auipc	ra,0xffffe
    800028a0:	436080e7          	jalr	1078(ra) # 80000cd2 <memset>
  release(&t->t_lock);
    800028a4:	8526                	mv	a0,s1
    800028a6:	ffffe097          	auipc	ra,0xffffe
    800028aa:	3e4080e7          	jalr	996(ra) # 80000c8a <release>
}
    800028ae:	60e2                	ld	ra,24(sp)
    800028b0:	6442                	ld	s0,16(sp)
    800028b2:	64a2                	ld	s1,8(sp)
    800028b4:	6105                	addi	sp,sp,32
    800028b6:	8082                	ret

00000000800028b8 <swtch>:
    800028b8:	00153023          	sd	ra,0(a0)
    800028bc:	00253423          	sd	sp,8(a0)
    800028c0:	e900                	sd	s0,16(a0)
    800028c2:	ed04                	sd	s1,24(a0)
    800028c4:	03253023          	sd	s2,32(a0)
    800028c8:	03353423          	sd	s3,40(a0)
    800028cc:	03453823          	sd	s4,48(a0)
    800028d0:	03553c23          	sd	s5,56(a0)
    800028d4:	05653023          	sd	s6,64(a0)
    800028d8:	05753423          	sd	s7,72(a0)
    800028dc:	05853823          	sd	s8,80(a0)
    800028e0:	05953c23          	sd	s9,88(a0)
    800028e4:	07a53023          	sd	s10,96(a0)
    800028e8:	07b53423          	sd	s11,104(a0)
    800028ec:	0005b083          	ld	ra,0(a1)
    800028f0:	0085b103          	ld	sp,8(a1)
    800028f4:	6980                	ld	s0,16(a1)
    800028f6:	6d84                	ld	s1,24(a1)
    800028f8:	0205b903          	ld	s2,32(a1)
    800028fc:	0285b983          	ld	s3,40(a1)
    80002900:	0305ba03          	ld	s4,48(a1)
    80002904:	0385ba83          	ld	s5,56(a1)
    80002908:	0405bb03          	ld	s6,64(a1)
    8000290c:	0485bb83          	ld	s7,72(a1)
    80002910:	0505bc03          	ld	s8,80(a1)
    80002914:	0585bc83          	ld	s9,88(a1)
    80002918:	0605bd03          	ld	s10,96(a1)
    8000291c:	0685bd83          	ld	s11,104(a1)
    80002920:	8082                	ret

0000000080002922 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002922:	1141                	addi	sp,sp,-16
    80002924:	e406                	sd	ra,8(sp)
    80002926:	e022                	sd	s0,0(sp)
    80002928:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000292a:	00006597          	auipc	a1,0x6
    8000292e:	9ee58593          	addi	a1,a1,-1554 # 80008318 <states.0+0x50>
    80002932:	00015517          	auipc	a0,0x15
    80002936:	66e50513          	addi	a0,a0,1646 # 80017fa0 <tickslock>
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	20c080e7          	jalr	524(ra) # 80000b46 <initlock>
}
    80002942:	60a2                	ld	ra,8(sp)
    80002944:	6402                	ld	s0,0(sp)
    80002946:	0141                	addi	sp,sp,16
    80002948:	8082                	ret

000000008000294a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000294a:	1141                	addi	sp,sp,-16
    8000294c:	e422                	sd	s0,8(sp)
    8000294e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002950:	00003797          	auipc	a5,0x3
    80002954:	53078793          	addi	a5,a5,1328 # 80005e80 <kernelvec>
    80002958:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000295c:	6422                	ld	s0,8(sp)
    8000295e:	0141                	addi	sp,sp,16
    80002960:	8082                	ret

0000000080002962 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002962:	1101                	addi	sp,sp,-32
    80002964:	ec06                	sd	ra,24(sp)
    80002966:	e822                	sd	s0,16(sp)
    80002968:	e426                	sd	s1,8(sp)
    8000296a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000296c:	fffff097          	auipc	ra,0xfffff
    80002970:	014080e7          	jalr	20(ra) # 80001980 <myproc>
    80002974:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002976:	00000097          	auipc	ra,0x0
    8000297a:	dc8080e7          	jalr	-568(ra) # 8000273e <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000297e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002982:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002984:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002988:	00004617          	auipc	a2,0x4
    8000298c:	67860613          	addi	a2,a2,1656 # 80007000 <_trampoline>
    80002990:	00004697          	auipc	a3,0x4
    80002994:	67068693          	addi	a3,a3,1648 # 80007000 <_trampoline>
    80002998:	8e91                	sub	a3,a3,a2
    8000299a:	040007b7          	lui	a5,0x4000
    8000299e:	17fd                	addi	a5,a5,-1
    800029a0:	07b2                	slli	a5,a5,0xc
    800029a2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029a4:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    800029a8:	7d58                	ld	a4,184(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029aa:	180026f3          	csrr	a3,satp
    800029ae:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    800029b0:	7d58                	ld	a4,184(a0)
    800029b2:	7954                	ld	a3,176(a0)
    800029b4:	6585                	lui	a1,0x1
    800029b6:	96ae                	add	a3,a3,a1
    800029b8:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    800029ba:	7d58                	ld	a4,184(a0)
    800029bc:	00000697          	auipc	a3,0x0
    800029c0:	15e68693          	addi	a3,a3,350 # 80002b1a <usertrap>
    800029c4:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029c6:	7d58                	ld	a4,184(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029c8:	8692                	mv	a3,tp
    800029ca:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029cc:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029d0:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029d4:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029d8:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    800029dc:	7d58                	ld	a4,184(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029de:	6f18                	ld	a4,24(a4)
    800029e0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029e4:	1004b583          	ld	a1,256(s1)
    800029e8:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    800029ea:	02848493          	addi	s1,s1,40
    800029ee:	8d05                	sub	a0,a0,s1
    800029f0:	8519                	srai	a0,a0,0x6
    800029f2:	00005717          	auipc	a4,0x5
    800029f6:	61673703          	ld	a4,1558(a4) # 80008008 <etext+0x8>
    800029fa:	02e50533          	mul	a0,a0,a4
    800029fe:	1502                	slli	a0,a0,0x20
    80002a00:	9101                	srli	a0,a0,0x20
    80002a02:	00351693          	slli	a3,a0,0x3
    80002a06:	9536                	add	a0,a0,a3
    80002a08:	0516                	slli	a0,a0,0x5
    80002a0a:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a0e:	00004717          	auipc	a4,0x4
    80002a12:	68670713          	addi	a4,a4,1670 # 80007094 <userret>
    80002a16:	8f11                	sub	a4,a4,a2
    80002a18:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002a1a:	577d                	li	a4,-1
    80002a1c:	177e                	slli	a4,a4,0x3f
    80002a1e:	8dd9                	or	a1,a1,a4
    80002a20:	16fd                	addi	a3,a3,-1
    80002a22:	06b6                	slli	a3,a3,0xd
    80002a24:	9536                	add	a0,a0,a3
    80002a26:	9782                	jalr	a5
}
    80002a28:	60e2                	ld	ra,24(sp)
    80002a2a:	6442                	ld	s0,16(sp)
    80002a2c:	64a2                	ld	s1,8(sp)
    80002a2e:	6105                	addi	sp,sp,32
    80002a30:	8082                	ret

0000000080002a32 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a32:	1101                	addi	sp,sp,-32
    80002a34:	ec06                	sd	ra,24(sp)
    80002a36:	e822                	sd	s0,16(sp)
    80002a38:	e426                	sd	s1,8(sp)
    80002a3a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a3c:	00015497          	auipc	s1,0x15
    80002a40:	56448493          	addi	s1,s1,1380 # 80017fa0 <tickslock>
    80002a44:	8526                	mv	a0,s1
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	190080e7          	jalr	400(ra) # 80000bd6 <acquire>
  ticks++;
    80002a4e:	00006517          	auipc	a0,0x6
    80002a52:	eb250513          	addi	a0,a0,-334 # 80008900 <ticks>
    80002a56:	411c                	lw	a5,0(a0)
    80002a58:	2785                	addiw	a5,a5,1
    80002a5a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a5c:	fffff097          	auipc	ra,0xfffff
    80002a60:	70e080e7          	jalr	1806(ra) # 8000216a <wakeup>
  release(&tickslock);
    80002a64:	8526                	mv	a0,s1
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	224080e7          	jalr	548(ra) # 80000c8a <release>
}
    80002a6e:	60e2                	ld	ra,24(sp)
    80002a70:	6442                	ld	s0,16(sp)
    80002a72:	64a2                	ld	s1,8(sp)
    80002a74:	6105                	addi	sp,sp,32
    80002a76:	8082                	ret

0000000080002a78 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a78:	1101                	addi	sp,sp,-32
    80002a7a:	ec06                	sd	ra,24(sp)
    80002a7c:	e822                	sd	s0,16(sp)
    80002a7e:	e426                	sd	s1,8(sp)
    80002a80:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a82:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a86:	00074d63          	bltz	a4,80002aa0 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a8a:	57fd                	li	a5,-1
    80002a8c:	17fe                	slli	a5,a5,0x3f
    80002a8e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a90:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a92:	06f70363          	beq	a4,a5,80002af8 <devintr+0x80>
  }
}
    80002a96:	60e2                	ld	ra,24(sp)
    80002a98:	6442                	ld	s0,16(sp)
    80002a9a:	64a2                	ld	s1,8(sp)
    80002a9c:	6105                	addi	sp,sp,32
    80002a9e:	8082                	ret
     (scause & 0xff) == 9){
    80002aa0:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002aa4:	46a5                	li	a3,9
    80002aa6:	fed792e3          	bne	a5,a3,80002a8a <devintr+0x12>
    int irq = plic_claim();
    80002aaa:	00003097          	auipc	ra,0x3
    80002aae:	4de080e7          	jalr	1246(ra) # 80005f88 <plic_claim>
    80002ab2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ab4:	47a9                	li	a5,10
    80002ab6:	02f50763          	beq	a0,a5,80002ae4 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002aba:	4785                	li	a5,1
    80002abc:	02f50963          	beq	a0,a5,80002aee <devintr+0x76>
    return 1;
    80002ac0:	4505                	li	a0,1
    } else if(irq){
    80002ac2:	d8f1                	beqz	s1,80002a96 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ac4:	85a6                	mv	a1,s1
    80002ac6:	00006517          	auipc	a0,0x6
    80002aca:	85a50513          	addi	a0,a0,-1958 # 80008320 <states.0+0x58>
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	aba080e7          	jalr	-1350(ra) # 80000588 <printf>
      plic_complete(irq);
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	00003097          	auipc	ra,0x3
    80002adc:	4d4080e7          	jalr	1236(ra) # 80005fac <plic_complete>
    return 1;
    80002ae0:	4505                	li	a0,1
    80002ae2:	bf55                	j	80002a96 <devintr+0x1e>
      uartintr();
    80002ae4:	ffffe097          	auipc	ra,0xffffe
    80002ae8:	eb6080e7          	jalr	-330(ra) # 8000099a <uartintr>
    80002aec:	b7ed                	j	80002ad6 <devintr+0x5e>
      virtio_disk_intr();
    80002aee:	00004097          	auipc	ra,0x4
    80002af2:	98a080e7          	jalr	-1654(ra) # 80006478 <virtio_disk_intr>
    80002af6:	b7c5                	j	80002ad6 <devintr+0x5e>
    if(cpuid() == 0){
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	e5c080e7          	jalr	-420(ra) # 80001954 <cpuid>
    80002b00:	c901                	beqz	a0,80002b10 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b02:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b06:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b08:	14479073          	csrw	sip,a5
    return 2;
    80002b0c:	4509                	li	a0,2
    80002b0e:	b761                	j	80002a96 <devintr+0x1e>
      clockintr();
    80002b10:	00000097          	auipc	ra,0x0
    80002b14:	f22080e7          	jalr	-222(ra) # 80002a32 <clockintr>
    80002b18:	b7ed                	j	80002b02 <devintr+0x8a>

0000000080002b1a <usertrap>:
{
    80002b1a:	1101                	addi	sp,sp,-32
    80002b1c:	ec06                	sd	ra,24(sp)
    80002b1e:	e822                	sd	s0,16(sp)
    80002b20:	e426                	sd	s1,8(sp)
    80002b22:	e04a                	sd	s2,0(sp)
    80002b24:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b26:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b2a:	1007f793          	andi	a5,a5,256
    80002b2e:	e7b9                	bnez	a5,80002b7c <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b30:	00003797          	auipc	a5,0x3
    80002b34:	35078793          	addi	a5,a5,848 # 80005e80 <kernelvec>
    80002b38:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b3c:	fffff097          	auipc	ra,0xfffff
    80002b40:	e44080e7          	jalr	-444(ra) # 80001980 <myproc>
    80002b44:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002b46:	00000097          	auipc	ra,0x0
    80002b4a:	bf8080e7          	jalr	-1032(ra) # 8000273e <mykthread>
    80002b4e:	892a                	mv	s2,a0
  kt->trapframe->epc = r_sepc();
    80002b50:	7d5c                	ld	a5,184(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b52:	14102773          	csrr	a4,sepc
    80002b56:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b58:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b5c:	47a1                	li	a5,8
    80002b5e:	02f70763          	beq	a4,a5,80002b8c <usertrap+0x72>
  } else if((which_dev = devintr()) != 0){
    80002b62:	00000097          	auipc	ra,0x0
    80002b66:	f16080e7          	jalr	-234(ra) # 80002a78 <devintr>
    80002b6a:	892a                	mv	s2,a0
    80002b6c:	c541                	beqz	a0,80002bf4 <usertrap+0xda>
  if(killed(p))
    80002b6e:	8526                	mv	a0,s1
    80002b70:	00000097          	auipc	ra,0x0
    80002b74:	89e080e7          	jalr	-1890(ra) # 8000240e <killed>
    80002b78:	c939                	beqz	a0,80002bce <usertrap+0xb4>
    80002b7a:	a0a9                	j	80002bc4 <usertrap+0xaa>
    panic("usertrap: not from user mode");
    80002b7c:	00005517          	auipc	a0,0x5
    80002b80:	7c450513          	addi	a0,a0,1988 # 80008340 <states.0+0x78>
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	9ba080e7          	jalr	-1606(ra) # 8000053e <panic>
    if(killed(p))
    80002b8c:	8526                	mv	a0,s1
    80002b8e:	00000097          	auipc	ra,0x0
    80002b92:	880080e7          	jalr	-1920(ra) # 8000240e <killed>
    80002b96:	e929                	bnez	a0,80002be8 <usertrap+0xce>
    kt->trapframe->epc += 4;
    80002b98:	0b893703          	ld	a4,184(s2)
    80002b9c:	6f1c                	ld	a5,24(a4)
    80002b9e:	0791                	addi	a5,a5,4
    80002ba0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ba6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002baa:	10079073          	csrw	sstatus,a5
    syscall();
    80002bae:	00000097          	auipc	ra,0x0
    80002bb2:	2d8080e7          	jalr	728(ra) # 80002e86 <syscall>
  if(killed(p))
    80002bb6:	8526                	mv	a0,s1
    80002bb8:	00000097          	auipc	ra,0x0
    80002bbc:	856080e7          	jalr	-1962(ra) # 8000240e <killed>
    80002bc0:	c911                	beqz	a0,80002bd4 <usertrap+0xba>
    80002bc2:	4901                	li	s2,0
    exit(-1);
    80002bc4:	557d                	li	a0,-1
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	690080e7          	jalr	1680(ra) # 80002256 <exit>
  if(which_dev == 2)
    80002bce:	4789                	li	a5,2
    80002bd0:	04f90f63          	beq	s2,a5,80002c2e <usertrap+0x114>
  usertrapret();
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	d8e080e7          	jalr	-626(ra) # 80002962 <usertrapret>
}
    80002bdc:	60e2                	ld	ra,24(sp)
    80002bde:	6442                	ld	s0,16(sp)
    80002be0:	64a2                	ld	s1,8(sp)
    80002be2:	6902                	ld	s2,0(sp)
    80002be4:	6105                	addi	sp,sp,32
    80002be6:	8082                	ret
      exit(-1);
    80002be8:	557d                	li	a0,-1
    80002bea:	fffff097          	auipc	ra,0xfffff
    80002bee:	66c080e7          	jalr	1644(ra) # 80002256 <exit>
    80002bf2:	b75d                	j	80002b98 <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bf8:	50d0                	lw	a2,36(s1)
    80002bfa:	00005517          	auipc	a0,0x5
    80002bfe:	76650513          	addi	a0,a0,1894 # 80008360 <states.0+0x98>
    80002c02:	ffffe097          	auipc	ra,0xffffe
    80002c06:	986080e7          	jalr	-1658(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c0e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c12:	00005517          	auipc	a0,0x5
    80002c16:	77e50513          	addi	a0,a0,1918 # 80008390 <states.0+0xc8>
    80002c1a:	ffffe097          	auipc	ra,0xffffe
    80002c1e:	96e080e7          	jalr	-1682(ra) # 80000588 <printf>
    setkilled(p);
    80002c22:	8526                	mv	a0,s1
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	7be080e7          	jalr	1982(ra) # 800023e2 <setkilled>
    80002c2c:	b769                	j	80002bb6 <usertrap+0x9c>
    yield();
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	42a080e7          	jalr	1066(ra) # 80002058 <yield>
    80002c36:	bf79                	j	80002bd4 <usertrap+0xba>

0000000080002c38 <kerneltrap>:
{
    80002c38:	7179                	addi	sp,sp,-48
    80002c3a:	f406                	sd	ra,40(sp)
    80002c3c:	f022                	sd	s0,32(sp)
    80002c3e:	ec26                	sd	s1,24(sp)
    80002c40:	e84a                	sd	s2,16(sp)
    80002c42:	e44e                	sd	s3,8(sp)
    80002c44:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c46:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c4a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c4e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c52:	1004f793          	andi	a5,s1,256
    80002c56:	cb85                	beqz	a5,80002c86 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c58:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c5c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c5e:	ef85                	bnez	a5,80002c96 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c60:	00000097          	auipc	ra,0x0
    80002c64:	e18080e7          	jalr	-488(ra) # 80002a78 <devintr>
    80002c68:	cd1d                	beqz	a0,80002ca6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002c6a:	4789                	li	a5,2
    80002c6c:	06f50a63          	beq	a0,a5,80002ce0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c70:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c74:	10049073          	csrw	sstatus,s1
}
    80002c78:	70a2                	ld	ra,40(sp)
    80002c7a:	7402                	ld	s0,32(sp)
    80002c7c:	64e2                	ld	s1,24(sp)
    80002c7e:	6942                	ld	s2,16(sp)
    80002c80:	69a2                	ld	s3,8(sp)
    80002c82:	6145                	addi	sp,sp,48
    80002c84:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c86:	00005517          	auipc	a0,0x5
    80002c8a:	72a50513          	addi	a0,a0,1834 # 800083b0 <states.0+0xe8>
    80002c8e:	ffffe097          	auipc	ra,0xffffe
    80002c92:	8b0080e7          	jalr	-1872(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002c96:	00005517          	auipc	a0,0x5
    80002c9a:	74250513          	addi	a0,a0,1858 # 800083d8 <states.0+0x110>
    80002c9e:	ffffe097          	auipc	ra,0xffffe
    80002ca2:	8a0080e7          	jalr	-1888(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002ca6:	85ce                	mv	a1,s3
    80002ca8:	00005517          	auipc	a0,0x5
    80002cac:	75050513          	addi	a0,a0,1872 # 800083f8 <states.0+0x130>
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	8d8080e7          	jalr	-1832(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cb8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cbc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cc0:	00005517          	auipc	a0,0x5
    80002cc4:	74850513          	addi	a0,a0,1864 # 80008408 <states.0+0x140>
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	8c0080e7          	jalr	-1856(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002cd0:	00005517          	auipc	a0,0x5
    80002cd4:	75050513          	addi	a0,a0,1872 # 80008420 <states.0+0x158>
    80002cd8:	ffffe097          	auipc	ra,0xffffe
    80002cdc:	866080e7          	jalr	-1946(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002ce0:	fffff097          	auipc	ra,0xfffff
    80002ce4:	ca0080e7          	jalr	-864(ra) # 80001980 <myproc>
    80002ce8:	d541                	beqz	a0,80002c70 <kerneltrap+0x38>
    80002cea:	fffff097          	auipc	ra,0xfffff
    80002cee:	c96080e7          	jalr	-874(ra) # 80001980 <myproc>
    80002cf2:	4138                	lw	a4,64(a0)
    80002cf4:	4791                	li	a5,4
    80002cf6:	f6f71de3          	bne	a4,a5,80002c70 <kerneltrap+0x38>
    yield();
    80002cfa:	fffff097          	auipc	ra,0xfffff
    80002cfe:	35e080e7          	jalr	862(ra) # 80002058 <yield>
    80002d02:	b7bd                	j	80002c70 <kerneltrap+0x38>

0000000080002d04 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d04:	1101                	addi	sp,sp,-32
    80002d06:	ec06                	sd	ra,24(sp)
    80002d08:	e822                	sd	s0,16(sp)
    80002d0a:	e426                	sd	s1,8(sp)
    80002d0c:	1000                	addi	s0,sp,32
    80002d0e:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    80002d10:	00000097          	auipc	ra,0x0
    80002d14:	a2e080e7          	jalr	-1490(ra) # 8000273e <mykthread>
  switch (n) {
    80002d18:	4795                	li	a5,5
    80002d1a:	0497e163          	bltu	a5,s1,80002d5c <argraw+0x58>
    80002d1e:	048a                	slli	s1,s1,0x2
    80002d20:	00005717          	auipc	a4,0x5
    80002d24:	73870713          	addi	a4,a4,1848 # 80008458 <states.0+0x190>
    80002d28:	94ba                	add	s1,s1,a4
    80002d2a:	409c                	lw	a5,0(s1)
    80002d2c:	97ba                	add	a5,a5,a4
    80002d2e:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    80002d30:	7d5c                	ld	a5,184(a0)
    80002d32:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d34:	60e2                	ld	ra,24(sp)
    80002d36:	6442                	ld	s0,16(sp)
    80002d38:	64a2                	ld	s1,8(sp)
    80002d3a:	6105                	addi	sp,sp,32
    80002d3c:	8082                	ret
    return kt->trapframe->a1;
    80002d3e:	7d5c                	ld	a5,184(a0)
    80002d40:	7fa8                	ld	a0,120(a5)
    80002d42:	bfcd                	j	80002d34 <argraw+0x30>
    return kt->trapframe->a2;
    80002d44:	7d5c                	ld	a5,184(a0)
    80002d46:	63c8                	ld	a0,128(a5)
    80002d48:	b7f5                	j	80002d34 <argraw+0x30>
    return kt->trapframe->a3;
    80002d4a:	7d5c                	ld	a5,184(a0)
    80002d4c:	67c8                	ld	a0,136(a5)
    80002d4e:	b7dd                	j	80002d34 <argraw+0x30>
    return kt->trapframe->a4;
    80002d50:	7d5c                	ld	a5,184(a0)
    80002d52:	6bc8                	ld	a0,144(a5)
    80002d54:	b7c5                	j	80002d34 <argraw+0x30>
    return kt->trapframe->a5;
    80002d56:	7d5c                	ld	a5,184(a0)
    80002d58:	6fc8                	ld	a0,152(a5)
    80002d5a:	bfe9                	j	80002d34 <argraw+0x30>
  panic("argraw");
    80002d5c:	00005517          	auipc	a0,0x5
    80002d60:	6d450513          	addi	a0,a0,1748 # 80008430 <states.0+0x168>
    80002d64:	ffffd097          	auipc	ra,0xffffd
    80002d68:	7da080e7          	jalr	2010(ra) # 8000053e <panic>

0000000080002d6c <fetchaddr>:
{
    80002d6c:	1101                	addi	sp,sp,-32
    80002d6e:	ec06                	sd	ra,24(sp)
    80002d70:	e822                	sd	s0,16(sp)
    80002d72:	e426                	sd	s1,8(sp)
    80002d74:	e04a                	sd	s2,0(sp)
    80002d76:	1000                	addi	s0,sp,32
    80002d78:	84aa                	mv	s1,a0
    80002d7a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d7c:	fffff097          	auipc	ra,0xfffff
    80002d80:	c04080e7          	jalr	-1020(ra) # 80001980 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d84:	7d7c                	ld	a5,248(a0)
    80002d86:	02f4f963          	bgeu	s1,a5,80002db8 <fetchaddr+0x4c>
    80002d8a:	00848713          	addi	a4,s1,8
    80002d8e:	02e7e763          	bltu	a5,a4,80002dbc <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d92:	46a1                	li	a3,8
    80002d94:	8626                	mv	a2,s1
    80002d96:	85ca                	mv	a1,s2
    80002d98:	10053503          	ld	a0,256(a0)
    80002d9c:	fffff097          	auipc	ra,0xfffff
    80002da0:	958080e7          	jalr	-1704(ra) # 800016f4 <copyin>
    80002da4:	00a03533          	snez	a0,a0
    80002da8:	40a00533          	neg	a0,a0
}
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	64a2                	ld	s1,8(sp)
    80002db2:	6902                	ld	s2,0(sp)
    80002db4:	6105                	addi	sp,sp,32
    80002db6:	8082                	ret
    return -1;
    80002db8:	557d                	li	a0,-1
    80002dba:	bfcd                	j	80002dac <fetchaddr+0x40>
    80002dbc:	557d                	li	a0,-1
    80002dbe:	b7fd                	j	80002dac <fetchaddr+0x40>

0000000080002dc0 <fetchstr>:
{
    80002dc0:	7179                	addi	sp,sp,-48
    80002dc2:	f406                	sd	ra,40(sp)
    80002dc4:	f022                	sd	s0,32(sp)
    80002dc6:	ec26                	sd	s1,24(sp)
    80002dc8:	e84a                	sd	s2,16(sp)
    80002dca:	e44e                	sd	s3,8(sp)
    80002dcc:	1800                	addi	s0,sp,48
    80002dce:	892a                	mv	s2,a0
    80002dd0:	84ae                	mv	s1,a1
    80002dd2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	bac080e7          	jalr	-1108(ra) # 80001980 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ddc:	86ce                	mv	a3,s3
    80002dde:	864a                	mv	a2,s2
    80002de0:	85a6                	mv	a1,s1
    80002de2:	10053503          	ld	a0,256(a0)
    80002de6:	fffff097          	auipc	ra,0xfffff
    80002dea:	99c080e7          	jalr	-1636(ra) # 80001782 <copyinstr>
    80002dee:	00054e63          	bltz	a0,80002e0a <fetchstr+0x4a>
  return strlen(buf);
    80002df2:	8526                	mv	a0,s1
    80002df4:	ffffe097          	auipc	ra,0xffffe
    80002df8:	05a080e7          	jalr	90(ra) # 80000e4e <strlen>
}
    80002dfc:	70a2                	ld	ra,40(sp)
    80002dfe:	7402                	ld	s0,32(sp)
    80002e00:	64e2                	ld	s1,24(sp)
    80002e02:	6942                	ld	s2,16(sp)
    80002e04:	69a2                	ld	s3,8(sp)
    80002e06:	6145                	addi	sp,sp,48
    80002e08:	8082                	ret
    return -1;
    80002e0a:	557d                	li	a0,-1
    80002e0c:	bfc5                	j	80002dfc <fetchstr+0x3c>

0000000080002e0e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e0e:	1101                	addi	sp,sp,-32
    80002e10:	ec06                	sd	ra,24(sp)
    80002e12:	e822                	sd	s0,16(sp)
    80002e14:	e426                	sd	s1,8(sp)
    80002e16:	1000                	addi	s0,sp,32
    80002e18:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e1a:	00000097          	auipc	ra,0x0
    80002e1e:	eea080e7          	jalr	-278(ra) # 80002d04 <argraw>
    80002e22:	c088                	sw	a0,0(s1)
}
    80002e24:	60e2                	ld	ra,24(sp)
    80002e26:	6442                	ld	s0,16(sp)
    80002e28:	64a2                	ld	s1,8(sp)
    80002e2a:	6105                	addi	sp,sp,32
    80002e2c:	8082                	ret

0000000080002e2e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e2e:	1101                	addi	sp,sp,-32
    80002e30:	ec06                	sd	ra,24(sp)
    80002e32:	e822                	sd	s0,16(sp)
    80002e34:	e426                	sd	s1,8(sp)
    80002e36:	1000                	addi	s0,sp,32
    80002e38:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e3a:	00000097          	auipc	ra,0x0
    80002e3e:	eca080e7          	jalr	-310(ra) # 80002d04 <argraw>
    80002e42:	e088                	sd	a0,0(s1)
}
    80002e44:	60e2                	ld	ra,24(sp)
    80002e46:	6442                	ld	s0,16(sp)
    80002e48:	64a2                	ld	s1,8(sp)
    80002e4a:	6105                	addi	sp,sp,32
    80002e4c:	8082                	ret

0000000080002e4e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e4e:	7179                	addi	sp,sp,-48
    80002e50:	f406                	sd	ra,40(sp)
    80002e52:	f022                	sd	s0,32(sp)
    80002e54:	ec26                	sd	s1,24(sp)
    80002e56:	e84a                	sd	s2,16(sp)
    80002e58:	1800                	addi	s0,sp,48
    80002e5a:	84ae                	mv	s1,a1
    80002e5c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e5e:	fd840593          	addi	a1,s0,-40
    80002e62:	00000097          	auipc	ra,0x0
    80002e66:	fcc080e7          	jalr	-52(ra) # 80002e2e <argaddr>
  return fetchstr(addr, buf, max);
    80002e6a:	864a                	mv	a2,s2
    80002e6c:	85a6                	mv	a1,s1
    80002e6e:	fd843503          	ld	a0,-40(s0)
    80002e72:	00000097          	auipc	ra,0x0
    80002e76:	f4e080e7          	jalr	-178(ra) # 80002dc0 <fetchstr>
}
    80002e7a:	70a2                	ld	ra,40(sp)
    80002e7c:	7402                	ld	s0,32(sp)
    80002e7e:	64e2                	ld	s1,24(sp)
    80002e80:	6942                	ld	s2,16(sp)
    80002e82:	6145                	addi	sp,sp,48
    80002e84:	8082                	ret

0000000080002e86 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e86:	7179                	addi	sp,sp,-48
    80002e88:	f406                	sd	ra,40(sp)
    80002e8a:	f022                	sd	s0,32(sp)
    80002e8c:	ec26                	sd	s1,24(sp)
    80002e8e:	e84a                	sd	s2,16(sp)
    80002e90:	e44e                	sd	s3,8(sp)
    80002e92:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002e94:	fffff097          	auipc	ra,0xfffff
    80002e98:	aec080e7          	jalr	-1300(ra) # 80001980 <myproc>
    80002e9c:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    80002e9e:	00000097          	auipc	ra,0x0
    80002ea2:	8a0080e7          	jalr	-1888(ra) # 8000273e <mykthread>
    80002ea6:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80002ea8:	0b853983          	ld	s3,184(a0)
    80002eac:	0a89b783          	ld	a5,168(s3)
    80002eb0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002eb4:	37fd                	addiw	a5,a5,-1
    80002eb6:	4751                	li	a4,20
    80002eb8:	00f76f63          	bltu	a4,a5,80002ed6 <syscall+0x50>
    80002ebc:	00369713          	slli	a4,a3,0x3
    80002ec0:	00005797          	auipc	a5,0x5
    80002ec4:	5b078793          	addi	a5,a5,1456 # 80008470 <syscalls>
    80002ec8:	97ba                	add	a5,a5,a4
    80002eca:	639c                	ld	a5,0(a5)
    80002ecc:	c789                	beqz	a5,80002ed6 <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    80002ece:	9782                	jalr	a5
    80002ed0:	06a9b823          	sd	a0,112(s3)
    80002ed4:	a005                	j	80002ef4 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ed6:	19090613          	addi	a2,s2,400
    80002eda:	02492583          	lw	a1,36(s2)
    80002ede:	00005517          	auipc	a0,0x5
    80002ee2:	55a50513          	addi	a0,a0,1370 # 80008438 <states.0+0x170>
    80002ee6:	ffffd097          	auipc	ra,0xffffd
    80002eea:	6a2080e7          	jalr	1698(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    80002eee:	7cdc                	ld	a5,184(s1)
    80002ef0:	577d                	li	a4,-1
    80002ef2:	fbb8                	sd	a4,112(a5)
  }
}
    80002ef4:	70a2                	ld	ra,40(sp)
    80002ef6:	7402                	ld	s0,32(sp)
    80002ef8:	64e2                	ld	s1,24(sp)
    80002efa:	6942                	ld	s2,16(sp)
    80002efc:	69a2                	ld	s3,8(sp)
    80002efe:	6145                	addi	sp,sp,48
    80002f00:	8082                	ret

0000000080002f02 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f02:	1101                	addi	sp,sp,-32
    80002f04:	ec06                	sd	ra,24(sp)
    80002f06:	e822                	sd	s0,16(sp)
    80002f08:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f0a:	fec40593          	addi	a1,s0,-20
    80002f0e:	4501                	li	a0,0
    80002f10:	00000097          	auipc	ra,0x0
    80002f14:	efe080e7          	jalr	-258(ra) # 80002e0e <argint>
  exit(n);
    80002f18:	fec42503          	lw	a0,-20(s0)
    80002f1c:	fffff097          	auipc	ra,0xfffff
    80002f20:	33a080e7          	jalr	826(ra) # 80002256 <exit>
  return 0;  // not reached
}
    80002f24:	4501                	li	a0,0
    80002f26:	60e2                	ld	ra,24(sp)
    80002f28:	6442                	ld	s0,16(sp)
    80002f2a:	6105                	addi	sp,sp,32
    80002f2c:	8082                	ret

0000000080002f2e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f2e:	1141                	addi	sp,sp,-16
    80002f30:	e406                	sd	ra,8(sp)
    80002f32:	e022                	sd	s0,0(sp)
    80002f34:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f36:	fffff097          	auipc	ra,0xfffff
    80002f3a:	a4a080e7          	jalr	-1462(ra) # 80001980 <myproc>
}
    80002f3e:	5148                	lw	a0,36(a0)
    80002f40:	60a2                	ld	ra,8(sp)
    80002f42:	6402                	ld	s0,0(sp)
    80002f44:	0141                	addi	sp,sp,16
    80002f46:	8082                	ret

0000000080002f48 <sys_fork>:

uint64
sys_fork(void)
{
    80002f48:	1141                	addi	sp,sp,-16
    80002f4a:	e406                	sd	ra,8(sp)
    80002f4c:	e022                	sd	s0,0(sp)
    80002f4e:	0800                	addi	s0,sp,16
  return fork();
    80002f50:	fffff097          	auipc	ra,0xfffff
    80002f54:	ddc080e7          	jalr	-548(ra) # 80001d2c <fork>
}
    80002f58:	60a2                	ld	ra,8(sp)
    80002f5a:	6402                	ld	s0,0(sp)
    80002f5c:	0141                	addi	sp,sp,16
    80002f5e:	8082                	ret

0000000080002f60 <sys_wait>:

uint64
sys_wait(void)
{
    80002f60:	1101                	addi	sp,sp,-32
    80002f62:	ec06                	sd	ra,24(sp)
    80002f64:	e822                	sd	s0,16(sp)
    80002f66:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f68:	fe840593          	addi	a1,s0,-24
    80002f6c:	4501                	li	a0,0
    80002f6e:	00000097          	auipc	ra,0x0
    80002f72:	ec0080e7          	jalr	-320(ra) # 80002e2e <argaddr>
  return wait(p);
    80002f76:	fe843503          	ld	a0,-24(s0)
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	4c6080e7          	jalr	1222(ra) # 80002440 <wait>
}
    80002f82:	60e2                	ld	ra,24(sp)
    80002f84:	6442                	ld	s0,16(sp)
    80002f86:	6105                	addi	sp,sp,32
    80002f88:	8082                	ret

0000000080002f8a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f8a:	7179                	addi	sp,sp,-48
    80002f8c:	f406                	sd	ra,40(sp)
    80002f8e:	f022                	sd	s0,32(sp)
    80002f90:	ec26                	sd	s1,24(sp)
    80002f92:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f94:	fdc40593          	addi	a1,s0,-36
    80002f98:	4501                	li	a0,0
    80002f9a:	00000097          	auipc	ra,0x0
    80002f9e:	e74080e7          	jalr	-396(ra) # 80002e0e <argint>
  addr = myproc()->sz;
    80002fa2:	fffff097          	auipc	ra,0xfffff
    80002fa6:	9de080e7          	jalr	-1570(ra) # 80001980 <myproc>
    80002faa:	7d64                	ld	s1,248(a0)
  if(growproc(n) < 0)
    80002fac:	fdc42503          	lw	a0,-36(s0)
    80002fb0:	fffff097          	auipc	ra,0xfffff
    80002fb4:	d1c080e7          	jalr	-740(ra) # 80001ccc <growproc>
    80002fb8:	00054863          	bltz	a0,80002fc8 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002fbc:	8526                	mv	a0,s1
    80002fbe:	70a2                	ld	ra,40(sp)
    80002fc0:	7402                	ld	s0,32(sp)
    80002fc2:	64e2                	ld	s1,24(sp)
    80002fc4:	6145                	addi	sp,sp,48
    80002fc6:	8082                	ret
    return -1;
    80002fc8:	54fd                	li	s1,-1
    80002fca:	bfcd                	j	80002fbc <sys_sbrk+0x32>

0000000080002fcc <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fcc:	7139                	addi	sp,sp,-64
    80002fce:	fc06                	sd	ra,56(sp)
    80002fd0:	f822                	sd	s0,48(sp)
    80002fd2:	f426                	sd	s1,40(sp)
    80002fd4:	f04a                	sd	s2,32(sp)
    80002fd6:	ec4e                	sd	s3,24(sp)
    80002fd8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002fda:	fcc40593          	addi	a1,s0,-52
    80002fde:	4501                	li	a0,0
    80002fe0:	00000097          	auipc	ra,0x0
    80002fe4:	e2e080e7          	jalr	-466(ra) # 80002e0e <argint>
  acquire(&tickslock);
    80002fe8:	00015517          	auipc	a0,0x15
    80002fec:	fb850513          	addi	a0,a0,-72 # 80017fa0 <tickslock>
    80002ff0:	ffffe097          	auipc	ra,0xffffe
    80002ff4:	be6080e7          	jalr	-1050(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002ff8:	00006917          	auipc	s2,0x6
    80002ffc:	90892903          	lw	s2,-1784(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80003000:	fcc42783          	lw	a5,-52(s0)
    80003004:	cf9d                	beqz	a5,80003042 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003006:	00015997          	auipc	s3,0x15
    8000300a:	f9a98993          	addi	s3,s3,-102 # 80017fa0 <tickslock>
    8000300e:	00006497          	auipc	s1,0x6
    80003012:	8f248493          	addi	s1,s1,-1806 # 80008900 <ticks>
    if(killed(myproc())){
    80003016:	fffff097          	auipc	ra,0xfffff
    8000301a:	96a080e7          	jalr	-1686(ra) # 80001980 <myproc>
    8000301e:	fffff097          	auipc	ra,0xfffff
    80003022:	3f0080e7          	jalr	1008(ra) # 8000240e <killed>
    80003026:	ed15                	bnez	a0,80003062 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003028:	85ce                	mv	a1,s3
    8000302a:	8526                	mv	a0,s1
    8000302c:	fffff097          	auipc	ra,0xfffff
    80003030:	0be080e7          	jalr	190(ra) # 800020ea <sleep>
  while(ticks - ticks0 < n){
    80003034:	409c                	lw	a5,0(s1)
    80003036:	412787bb          	subw	a5,a5,s2
    8000303a:	fcc42703          	lw	a4,-52(s0)
    8000303e:	fce7ece3          	bltu	a5,a4,80003016 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003042:	00015517          	auipc	a0,0x15
    80003046:	f5e50513          	addi	a0,a0,-162 # 80017fa0 <tickslock>
    8000304a:	ffffe097          	auipc	ra,0xffffe
    8000304e:	c40080e7          	jalr	-960(ra) # 80000c8a <release>
  return 0;
    80003052:	4501                	li	a0,0
}
    80003054:	70e2                	ld	ra,56(sp)
    80003056:	7442                	ld	s0,48(sp)
    80003058:	74a2                	ld	s1,40(sp)
    8000305a:	7902                	ld	s2,32(sp)
    8000305c:	69e2                	ld	s3,24(sp)
    8000305e:	6121                	addi	sp,sp,64
    80003060:	8082                	ret
      release(&tickslock);
    80003062:	00015517          	auipc	a0,0x15
    80003066:	f3e50513          	addi	a0,a0,-194 # 80017fa0 <tickslock>
    8000306a:	ffffe097          	auipc	ra,0xffffe
    8000306e:	c20080e7          	jalr	-992(ra) # 80000c8a <release>
      return -1;
    80003072:	557d                	li	a0,-1
    80003074:	b7c5                	j	80003054 <sys_sleep+0x88>

0000000080003076 <sys_kill>:

uint64
sys_kill(void)
{
    80003076:	1101                	addi	sp,sp,-32
    80003078:	ec06                	sd	ra,24(sp)
    8000307a:	e822                	sd	s0,16(sp)
    8000307c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000307e:	fec40593          	addi	a1,s0,-20
    80003082:	4501                	li	a0,0
    80003084:	00000097          	auipc	ra,0x0
    80003088:	d8a080e7          	jalr	-630(ra) # 80002e0e <argint>
  return kill(pid);
    8000308c:	fec42503          	lw	a0,-20(s0)
    80003090:	fffff097          	auipc	ra,0xfffff
    80003094:	2ba080e7          	jalr	698(ra) # 8000234a <kill>
}
    80003098:	60e2                	ld	ra,24(sp)
    8000309a:	6442                	ld	s0,16(sp)
    8000309c:	6105                	addi	sp,sp,32
    8000309e:	8082                	ret

00000000800030a0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030a0:	1101                	addi	sp,sp,-32
    800030a2:	ec06                	sd	ra,24(sp)
    800030a4:	e822                	sd	s0,16(sp)
    800030a6:	e426                	sd	s1,8(sp)
    800030a8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030aa:	00015517          	auipc	a0,0x15
    800030ae:	ef650513          	addi	a0,a0,-266 # 80017fa0 <tickslock>
    800030b2:	ffffe097          	auipc	ra,0xffffe
    800030b6:	b24080e7          	jalr	-1244(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800030ba:	00006497          	auipc	s1,0x6
    800030be:	8464a483          	lw	s1,-1978(s1) # 80008900 <ticks>
  release(&tickslock);
    800030c2:	00015517          	auipc	a0,0x15
    800030c6:	ede50513          	addi	a0,a0,-290 # 80017fa0 <tickslock>
    800030ca:	ffffe097          	auipc	ra,0xffffe
    800030ce:	bc0080e7          	jalr	-1088(ra) # 80000c8a <release>
  return xticks;
}
    800030d2:	02049513          	slli	a0,s1,0x20
    800030d6:	9101                	srli	a0,a0,0x20
    800030d8:	60e2                	ld	ra,24(sp)
    800030da:	6442                	ld	s0,16(sp)
    800030dc:	64a2                	ld	s1,8(sp)
    800030de:	6105                	addi	sp,sp,32
    800030e0:	8082                	ret

00000000800030e2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030e2:	7179                	addi	sp,sp,-48
    800030e4:	f406                	sd	ra,40(sp)
    800030e6:	f022                	sd	s0,32(sp)
    800030e8:	ec26                	sd	s1,24(sp)
    800030ea:	e84a                	sd	s2,16(sp)
    800030ec:	e44e                	sd	s3,8(sp)
    800030ee:	e052                	sd	s4,0(sp)
    800030f0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030f2:	00005597          	auipc	a1,0x5
    800030f6:	42e58593          	addi	a1,a1,1070 # 80008520 <syscalls+0xb0>
    800030fa:	00015517          	auipc	a0,0x15
    800030fe:	ebe50513          	addi	a0,a0,-322 # 80017fb8 <bcache>
    80003102:	ffffe097          	auipc	ra,0xffffe
    80003106:	a44080e7          	jalr	-1468(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000310a:	0001d797          	auipc	a5,0x1d
    8000310e:	eae78793          	addi	a5,a5,-338 # 8001ffb8 <bcache+0x8000>
    80003112:	0001d717          	auipc	a4,0x1d
    80003116:	10e70713          	addi	a4,a4,270 # 80020220 <bcache+0x8268>
    8000311a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000311e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003122:	00015497          	auipc	s1,0x15
    80003126:	eae48493          	addi	s1,s1,-338 # 80017fd0 <bcache+0x18>
    b->next = bcache.head.next;
    8000312a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000312c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000312e:	00005a17          	auipc	s4,0x5
    80003132:	3faa0a13          	addi	s4,s4,1018 # 80008528 <syscalls+0xb8>
    b->next = bcache.head.next;
    80003136:	2b893783          	ld	a5,696(s2)
    8000313a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000313c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003140:	85d2                	mv	a1,s4
    80003142:	01048513          	addi	a0,s1,16
    80003146:	00001097          	auipc	ra,0x1
    8000314a:	4c4080e7          	jalr	1220(ra) # 8000460a <initsleeplock>
    bcache.head.next->prev = b;
    8000314e:	2b893783          	ld	a5,696(s2)
    80003152:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003154:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003158:	45848493          	addi	s1,s1,1112
    8000315c:	fd349de3          	bne	s1,s3,80003136 <binit+0x54>
  }
}
    80003160:	70a2                	ld	ra,40(sp)
    80003162:	7402                	ld	s0,32(sp)
    80003164:	64e2                	ld	s1,24(sp)
    80003166:	6942                	ld	s2,16(sp)
    80003168:	69a2                	ld	s3,8(sp)
    8000316a:	6a02                	ld	s4,0(sp)
    8000316c:	6145                	addi	sp,sp,48
    8000316e:	8082                	ret

0000000080003170 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003170:	7179                	addi	sp,sp,-48
    80003172:	f406                	sd	ra,40(sp)
    80003174:	f022                	sd	s0,32(sp)
    80003176:	ec26                	sd	s1,24(sp)
    80003178:	e84a                	sd	s2,16(sp)
    8000317a:	e44e                	sd	s3,8(sp)
    8000317c:	1800                	addi	s0,sp,48
    8000317e:	892a                	mv	s2,a0
    80003180:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003182:	00015517          	auipc	a0,0x15
    80003186:	e3650513          	addi	a0,a0,-458 # 80017fb8 <bcache>
    8000318a:	ffffe097          	auipc	ra,0xffffe
    8000318e:	a4c080e7          	jalr	-1460(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003192:	0001d497          	auipc	s1,0x1d
    80003196:	0de4b483          	ld	s1,222(s1) # 80020270 <bcache+0x82b8>
    8000319a:	0001d797          	auipc	a5,0x1d
    8000319e:	08678793          	addi	a5,a5,134 # 80020220 <bcache+0x8268>
    800031a2:	02f48f63          	beq	s1,a5,800031e0 <bread+0x70>
    800031a6:	873e                	mv	a4,a5
    800031a8:	a021                	j	800031b0 <bread+0x40>
    800031aa:	68a4                	ld	s1,80(s1)
    800031ac:	02e48a63          	beq	s1,a4,800031e0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031b0:	449c                	lw	a5,8(s1)
    800031b2:	ff279ce3          	bne	a5,s2,800031aa <bread+0x3a>
    800031b6:	44dc                	lw	a5,12(s1)
    800031b8:	ff3799e3          	bne	a5,s3,800031aa <bread+0x3a>
      b->refcnt++;
    800031bc:	40bc                	lw	a5,64(s1)
    800031be:	2785                	addiw	a5,a5,1
    800031c0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031c2:	00015517          	auipc	a0,0x15
    800031c6:	df650513          	addi	a0,a0,-522 # 80017fb8 <bcache>
    800031ca:	ffffe097          	auipc	ra,0xffffe
    800031ce:	ac0080e7          	jalr	-1344(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031d2:	01048513          	addi	a0,s1,16
    800031d6:	00001097          	auipc	ra,0x1
    800031da:	46e080e7          	jalr	1134(ra) # 80004644 <acquiresleep>
      return b;
    800031de:	a8b9                	j	8000323c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031e0:	0001d497          	auipc	s1,0x1d
    800031e4:	0884b483          	ld	s1,136(s1) # 80020268 <bcache+0x82b0>
    800031e8:	0001d797          	auipc	a5,0x1d
    800031ec:	03878793          	addi	a5,a5,56 # 80020220 <bcache+0x8268>
    800031f0:	00f48863          	beq	s1,a5,80003200 <bread+0x90>
    800031f4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031f6:	40bc                	lw	a5,64(s1)
    800031f8:	cf81                	beqz	a5,80003210 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031fa:	64a4                	ld	s1,72(s1)
    800031fc:	fee49de3          	bne	s1,a4,800031f6 <bread+0x86>
  panic("bget: no buffers");
    80003200:	00005517          	auipc	a0,0x5
    80003204:	33050513          	addi	a0,a0,816 # 80008530 <syscalls+0xc0>
    80003208:	ffffd097          	auipc	ra,0xffffd
    8000320c:	336080e7          	jalr	822(ra) # 8000053e <panic>
      b->dev = dev;
    80003210:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003214:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003218:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000321c:	4785                	li	a5,1
    8000321e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003220:	00015517          	auipc	a0,0x15
    80003224:	d9850513          	addi	a0,a0,-616 # 80017fb8 <bcache>
    80003228:	ffffe097          	auipc	ra,0xffffe
    8000322c:	a62080e7          	jalr	-1438(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003230:	01048513          	addi	a0,s1,16
    80003234:	00001097          	auipc	ra,0x1
    80003238:	410080e7          	jalr	1040(ra) # 80004644 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000323c:	409c                	lw	a5,0(s1)
    8000323e:	cb89                	beqz	a5,80003250 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003240:	8526                	mv	a0,s1
    80003242:	70a2                	ld	ra,40(sp)
    80003244:	7402                	ld	s0,32(sp)
    80003246:	64e2                	ld	s1,24(sp)
    80003248:	6942                	ld	s2,16(sp)
    8000324a:	69a2                	ld	s3,8(sp)
    8000324c:	6145                	addi	sp,sp,48
    8000324e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003250:	4581                	li	a1,0
    80003252:	8526                	mv	a0,s1
    80003254:	00003097          	auipc	ra,0x3
    80003258:	ff0080e7          	jalr	-16(ra) # 80006244 <virtio_disk_rw>
    b->valid = 1;
    8000325c:	4785                	li	a5,1
    8000325e:	c09c                	sw	a5,0(s1)
  return b;
    80003260:	b7c5                	j	80003240 <bread+0xd0>

0000000080003262 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003262:	1101                	addi	sp,sp,-32
    80003264:	ec06                	sd	ra,24(sp)
    80003266:	e822                	sd	s0,16(sp)
    80003268:	e426                	sd	s1,8(sp)
    8000326a:	1000                	addi	s0,sp,32
    8000326c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000326e:	0541                	addi	a0,a0,16
    80003270:	00001097          	auipc	ra,0x1
    80003274:	46e080e7          	jalr	1134(ra) # 800046de <holdingsleep>
    80003278:	cd01                	beqz	a0,80003290 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000327a:	4585                	li	a1,1
    8000327c:	8526                	mv	a0,s1
    8000327e:	00003097          	auipc	ra,0x3
    80003282:	fc6080e7          	jalr	-58(ra) # 80006244 <virtio_disk_rw>
}
    80003286:	60e2                	ld	ra,24(sp)
    80003288:	6442                	ld	s0,16(sp)
    8000328a:	64a2                	ld	s1,8(sp)
    8000328c:	6105                	addi	sp,sp,32
    8000328e:	8082                	ret
    panic("bwrite");
    80003290:	00005517          	auipc	a0,0x5
    80003294:	2b850513          	addi	a0,a0,696 # 80008548 <syscalls+0xd8>
    80003298:	ffffd097          	auipc	ra,0xffffd
    8000329c:	2a6080e7          	jalr	678(ra) # 8000053e <panic>

00000000800032a0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032a0:	1101                	addi	sp,sp,-32
    800032a2:	ec06                	sd	ra,24(sp)
    800032a4:	e822                	sd	s0,16(sp)
    800032a6:	e426                	sd	s1,8(sp)
    800032a8:	e04a                	sd	s2,0(sp)
    800032aa:	1000                	addi	s0,sp,32
    800032ac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032ae:	01050913          	addi	s2,a0,16
    800032b2:	854a                	mv	a0,s2
    800032b4:	00001097          	auipc	ra,0x1
    800032b8:	42a080e7          	jalr	1066(ra) # 800046de <holdingsleep>
    800032bc:	c92d                	beqz	a0,8000332e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032be:	854a                	mv	a0,s2
    800032c0:	00001097          	auipc	ra,0x1
    800032c4:	3da080e7          	jalr	986(ra) # 8000469a <releasesleep>

  acquire(&bcache.lock);
    800032c8:	00015517          	auipc	a0,0x15
    800032cc:	cf050513          	addi	a0,a0,-784 # 80017fb8 <bcache>
    800032d0:	ffffe097          	auipc	ra,0xffffe
    800032d4:	906080e7          	jalr	-1786(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800032d8:	40bc                	lw	a5,64(s1)
    800032da:	37fd                	addiw	a5,a5,-1
    800032dc:	0007871b          	sext.w	a4,a5
    800032e0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032e2:	eb05                	bnez	a4,80003312 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032e4:	68bc                	ld	a5,80(s1)
    800032e6:	64b8                	ld	a4,72(s1)
    800032e8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800032ea:	64bc                	ld	a5,72(s1)
    800032ec:	68b8                	ld	a4,80(s1)
    800032ee:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032f0:	0001d797          	auipc	a5,0x1d
    800032f4:	cc878793          	addi	a5,a5,-824 # 8001ffb8 <bcache+0x8000>
    800032f8:	2b87b703          	ld	a4,696(a5)
    800032fc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032fe:	0001d717          	auipc	a4,0x1d
    80003302:	f2270713          	addi	a4,a4,-222 # 80020220 <bcache+0x8268>
    80003306:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003308:	2b87b703          	ld	a4,696(a5)
    8000330c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000330e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003312:	00015517          	auipc	a0,0x15
    80003316:	ca650513          	addi	a0,a0,-858 # 80017fb8 <bcache>
    8000331a:	ffffe097          	auipc	ra,0xffffe
    8000331e:	970080e7          	jalr	-1680(ra) # 80000c8a <release>
}
    80003322:	60e2                	ld	ra,24(sp)
    80003324:	6442                	ld	s0,16(sp)
    80003326:	64a2                	ld	s1,8(sp)
    80003328:	6902                	ld	s2,0(sp)
    8000332a:	6105                	addi	sp,sp,32
    8000332c:	8082                	ret
    panic("brelse");
    8000332e:	00005517          	auipc	a0,0x5
    80003332:	22250513          	addi	a0,a0,546 # 80008550 <syscalls+0xe0>
    80003336:	ffffd097          	auipc	ra,0xffffd
    8000333a:	208080e7          	jalr	520(ra) # 8000053e <panic>

000000008000333e <bpin>:

void
bpin(struct buf *b) {
    8000333e:	1101                	addi	sp,sp,-32
    80003340:	ec06                	sd	ra,24(sp)
    80003342:	e822                	sd	s0,16(sp)
    80003344:	e426                	sd	s1,8(sp)
    80003346:	1000                	addi	s0,sp,32
    80003348:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000334a:	00015517          	auipc	a0,0x15
    8000334e:	c6e50513          	addi	a0,a0,-914 # 80017fb8 <bcache>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	884080e7          	jalr	-1916(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000335a:	40bc                	lw	a5,64(s1)
    8000335c:	2785                	addiw	a5,a5,1
    8000335e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003360:	00015517          	auipc	a0,0x15
    80003364:	c5850513          	addi	a0,a0,-936 # 80017fb8 <bcache>
    80003368:	ffffe097          	auipc	ra,0xffffe
    8000336c:	922080e7          	jalr	-1758(ra) # 80000c8a <release>
}
    80003370:	60e2                	ld	ra,24(sp)
    80003372:	6442                	ld	s0,16(sp)
    80003374:	64a2                	ld	s1,8(sp)
    80003376:	6105                	addi	sp,sp,32
    80003378:	8082                	ret

000000008000337a <bunpin>:

void
bunpin(struct buf *b) {
    8000337a:	1101                	addi	sp,sp,-32
    8000337c:	ec06                	sd	ra,24(sp)
    8000337e:	e822                	sd	s0,16(sp)
    80003380:	e426                	sd	s1,8(sp)
    80003382:	1000                	addi	s0,sp,32
    80003384:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003386:	00015517          	auipc	a0,0x15
    8000338a:	c3250513          	addi	a0,a0,-974 # 80017fb8 <bcache>
    8000338e:	ffffe097          	auipc	ra,0xffffe
    80003392:	848080e7          	jalr	-1976(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003396:	40bc                	lw	a5,64(s1)
    80003398:	37fd                	addiw	a5,a5,-1
    8000339a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000339c:	00015517          	auipc	a0,0x15
    800033a0:	c1c50513          	addi	a0,a0,-996 # 80017fb8 <bcache>
    800033a4:	ffffe097          	auipc	ra,0xffffe
    800033a8:	8e6080e7          	jalr	-1818(ra) # 80000c8a <release>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6105                	addi	sp,sp,32
    800033b4:	8082                	ret

00000000800033b6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033b6:	1101                	addi	sp,sp,-32
    800033b8:	ec06                	sd	ra,24(sp)
    800033ba:	e822                	sd	s0,16(sp)
    800033bc:	e426                	sd	s1,8(sp)
    800033be:	e04a                	sd	s2,0(sp)
    800033c0:	1000                	addi	s0,sp,32
    800033c2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033c4:	00d5d59b          	srliw	a1,a1,0xd
    800033c8:	0001d797          	auipc	a5,0x1d
    800033cc:	2cc7a783          	lw	a5,716(a5) # 80020694 <sb+0x1c>
    800033d0:	9dbd                	addw	a1,a1,a5
    800033d2:	00000097          	auipc	ra,0x0
    800033d6:	d9e080e7          	jalr	-610(ra) # 80003170 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033da:	0074f713          	andi	a4,s1,7
    800033de:	4785                	li	a5,1
    800033e0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033e4:	14ce                	slli	s1,s1,0x33
    800033e6:	90d9                	srli	s1,s1,0x36
    800033e8:	00950733          	add	a4,a0,s1
    800033ec:	05874703          	lbu	a4,88(a4)
    800033f0:	00e7f6b3          	and	a3,a5,a4
    800033f4:	c69d                	beqz	a3,80003422 <bfree+0x6c>
    800033f6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033f8:	94aa                	add	s1,s1,a0
    800033fa:	fff7c793          	not	a5,a5
    800033fe:	8ff9                	and	a5,a5,a4
    80003400:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003404:	00001097          	auipc	ra,0x1
    80003408:	120080e7          	jalr	288(ra) # 80004524 <log_write>
  brelse(bp);
    8000340c:	854a                	mv	a0,s2
    8000340e:	00000097          	auipc	ra,0x0
    80003412:	e92080e7          	jalr	-366(ra) # 800032a0 <brelse>
}
    80003416:	60e2                	ld	ra,24(sp)
    80003418:	6442                	ld	s0,16(sp)
    8000341a:	64a2                	ld	s1,8(sp)
    8000341c:	6902                	ld	s2,0(sp)
    8000341e:	6105                	addi	sp,sp,32
    80003420:	8082                	ret
    panic("freeing free block");
    80003422:	00005517          	auipc	a0,0x5
    80003426:	13650513          	addi	a0,a0,310 # 80008558 <syscalls+0xe8>
    8000342a:	ffffd097          	auipc	ra,0xffffd
    8000342e:	114080e7          	jalr	276(ra) # 8000053e <panic>

0000000080003432 <balloc>:
{
    80003432:	711d                	addi	sp,sp,-96
    80003434:	ec86                	sd	ra,88(sp)
    80003436:	e8a2                	sd	s0,80(sp)
    80003438:	e4a6                	sd	s1,72(sp)
    8000343a:	e0ca                	sd	s2,64(sp)
    8000343c:	fc4e                	sd	s3,56(sp)
    8000343e:	f852                	sd	s4,48(sp)
    80003440:	f456                	sd	s5,40(sp)
    80003442:	f05a                	sd	s6,32(sp)
    80003444:	ec5e                	sd	s7,24(sp)
    80003446:	e862                	sd	s8,16(sp)
    80003448:	e466                	sd	s9,8(sp)
    8000344a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000344c:	0001d797          	auipc	a5,0x1d
    80003450:	2307a783          	lw	a5,560(a5) # 8002067c <sb+0x4>
    80003454:	10078163          	beqz	a5,80003556 <balloc+0x124>
    80003458:	8baa                	mv	s7,a0
    8000345a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000345c:	0001db17          	auipc	s6,0x1d
    80003460:	21cb0b13          	addi	s6,s6,540 # 80020678 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003464:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003466:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003468:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000346a:	6c89                	lui	s9,0x2
    8000346c:	a061                	j	800034f4 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000346e:	974a                	add	a4,a4,s2
    80003470:	8fd5                	or	a5,a5,a3
    80003472:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003476:	854a                	mv	a0,s2
    80003478:	00001097          	auipc	ra,0x1
    8000347c:	0ac080e7          	jalr	172(ra) # 80004524 <log_write>
        brelse(bp);
    80003480:	854a                	mv	a0,s2
    80003482:	00000097          	auipc	ra,0x0
    80003486:	e1e080e7          	jalr	-482(ra) # 800032a0 <brelse>
  bp = bread(dev, bno);
    8000348a:	85a6                	mv	a1,s1
    8000348c:	855e                	mv	a0,s7
    8000348e:	00000097          	auipc	ra,0x0
    80003492:	ce2080e7          	jalr	-798(ra) # 80003170 <bread>
    80003496:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003498:	40000613          	li	a2,1024
    8000349c:	4581                	li	a1,0
    8000349e:	05850513          	addi	a0,a0,88
    800034a2:	ffffe097          	auipc	ra,0xffffe
    800034a6:	830080e7          	jalr	-2000(ra) # 80000cd2 <memset>
  log_write(bp);
    800034aa:	854a                	mv	a0,s2
    800034ac:	00001097          	auipc	ra,0x1
    800034b0:	078080e7          	jalr	120(ra) # 80004524 <log_write>
  brelse(bp);
    800034b4:	854a                	mv	a0,s2
    800034b6:	00000097          	auipc	ra,0x0
    800034ba:	dea080e7          	jalr	-534(ra) # 800032a0 <brelse>
}
    800034be:	8526                	mv	a0,s1
    800034c0:	60e6                	ld	ra,88(sp)
    800034c2:	6446                	ld	s0,80(sp)
    800034c4:	64a6                	ld	s1,72(sp)
    800034c6:	6906                	ld	s2,64(sp)
    800034c8:	79e2                	ld	s3,56(sp)
    800034ca:	7a42                	ld	s4,48(sp)
    800034cc:	7aa2                	ld	s5,40(sp)
    800034ce:	7b02                	ld	s6,32(sp)
    800034d0:	6be2                	ld	s7,24(sp)
    800034d2:	6c42                	ld	s8,16(sp)
    800034d4:	6ca2                	ld	s9,8(sp)
    800034d6:	6125                	addi	sp,sp,96
    800034d8:	8082                	ret
    brelse(bp);
    800034da:	854a                	mv	a0,s2
    800034dc:	00000097          	auipc	ra,0x0
    800034e0:	dc4080e7          	jalr	-572(ra) # 800032a0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034e4:	015c87bb          	addw	a5,s9,s5
    800034e8:	00078a9b          	sext.w	s5,a5
    800034ec:	004b2703          	lw	a4,4(s6)
    800034f0:	06eaf363          	bgeu	s5,a4,80003556 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800034f4:	41fad79b          	sraiw	a5,s5,0x1f
    800034f8:	0137d79b          	srliw	a5,a5,0x13
    800034fc:	015787bb          	addw	a5,a5,s5
    80003500:	40d7d79b          	sraiw	a5,a5,0xd
    80003504:	01cb2583          	lw	a1,28(s6)
    80003508:	9dbd                	addw	a1,a1,a5
    8000350a:	855e                	mv	a0,s7
    8000350c:	00000097          	auipc	ra,0x0
    80003510:	c64080e7          	jalr	-924(ra) # 80003170 <bread>
    80003514:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003516:	004b2503          	lw	a0,4(s6)
    8000351a:	000a849b          	sext.w	s1,s5
    8000351e:	8662                	mv	a2,s8
    80003520:	faa4fde3          	bgeu	s1,a0,800034da <balloc+0xa8>
      m = 1 << (bi % 8);
    80003524:	41f6579b          	sraiw	a5,a2,0x1f
    80003528:	01d7d69b          	srliw	a3,a5,0x1d
    8000352c:	00c6873b          	addw	a4,a3,a2
    80003530:	00777793          	andi	a5,a4,7
    80003534:	9f95                	subw	a5,a5,a3
    80003536:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000353a:	4037571b          	sraiw	a4,a4,0x3
    8000353e:	00e906b3          	add	a3,s2,a4
    80003542:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    80003546:	00d7f5b3          	and	a1,a5,a3
    8000354a:	d195                	beqz	a1,8000346e <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000354c:	2605                	addiw	a2,a2,1
    8000354e:	2485                	addiw	s1,s1,1
    80003550:	fd4618e3          	bne	a2,s4,80003520 <balloc+0xee>
    80003554:	b759                	j	800034da <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003556:	00005517          	auipc	a0,0x5
    8000355a:	01a50513          	addi	a0,a0,26 # 80008570 <syscalls+0x100>
    8000355e:	ffffd097          	auipc	ra,0xffffd
    80003562:	02a080e7          	jalr	42(ra) # 80000588 <printf>
  return 0;
    80003566:	4481                	li	s1,0
    80003568:	bf99                	j	800034be <balloc+0x8c>

000000008000356a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000356a:	7179                	addi	sp,sp,-48
    8000356c:	f406                	sd	ra,40(sp)
    8000356e:	f022                	sd	s0,32(sp)
    80003570:	ec26                	sd	s1,24(sp)
    80003572:	e84a                	sd	s2,16(sp)
    80003574:	e44e                	sd	s3,8(sp)
    80003576:	e052                	sd	s4,0(sp)
    80003578:	1800                	addi	s0,sp,48
    8000357a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000357c:	47ad                	li	a5,11
    8000357e:	02b7e763          	bltu	a5,a1,800035ac <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003582:	02059493          	slli	s1,a1,0x20
    80003586:	9081                	srli	s1,s1,0x20
    80003588:	048a                	slli	s1,s1,0x2
    8000358a:	94aa                	add	s1,s1,a0
    8000358c:	0504a903          	lw	s2,80(s1)
    80003590:	06091e63          	bnez	s2,8000360c <bmap+0xa2>
      addr = balloc(ip->dev);
    80003594:	4108                	lw	a0,0(a0)
    80003596:	00000097          	auipc	ra,0x0
    8000359a:	e9c080e7          	jalr	-356(ra) # 80003432 <balloc>
    8000359e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035a2:	06090563          	beqz	s2,8000360c <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800035a6:	0524a823          	sw	s2,80(s1)
    800035aa:	a08d                	j	8000360c <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035ac:	ff45849b          	addiw	s1,a1,-12
    800035b0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035b4:	0ff00793          	li	a5,255
    800035b8:	08e7e563          	bltu	a5,a4,80003642 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800035bc:	08052903          	lw	s2,128(a0)
    800035c0:	00091d63          	bnez	s2,800035da <bmap+0x70>
      addr = balloc(ip->dev);
    800035c4:	4108                	lw	a0,0(a0)
    800035c6:	00000097          	auipc	ra,0x0
    800035ca:	e6c080e7          	jalr	-404(ra) # 80003432 <balloc>
    800035ce:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035d2:	02090d63          	beqz	s2,8000360c <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800035d6:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800035da:	85ca                	mv	a1,s2
    800035dc:	0009a503          	lw	a0,0(s3)
    800035e0:	00000097          	auipc	ra,0x0
    800035e4:	b90080e7          	jalr	-1136(ra) # 80003170 <bread>
    800035e8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035ea:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035ee:	02049593          	slli	a1,s1,0x20
    800035f2:	9181                	srli	a1,a1,0x20
    800035f4:	058a                	slli	a1,a1,0x2
    800035f6:	00b784b3          	add	s1,a5,a1
    800035fa:	0004a903          	lw	s2,0(s1)
    800035fe:	02090063          	beqz	s2,8000361e <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003602:	8552                	mv	a0,s4
    80003604:	00000097          	auipc	ra,0x0
    80003608:	c9c080e7          	jalr	-868(ra) # 800032a0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000360c:	854a                	mv	a0,s2
    8000360e:	70a2                	ld	ra,40(sp)
    80003610:	7402                	ld	s0,32(sp)
    80003612:	64e2                	ld	s1,24(sp)
    80003614:	6942                	ld	s2,16(sp)
    80003616:	69a2                	ld	s3,8(sp)
    80003618:	6a02                	ld	s4,0(sp)
    8000361a:	6145                	addi	sp,sp,48
    8000361c:	8082                	ret
      addr = balloc(ip->dev);
    8000361e:	0009a503          	lw	a0,0(s3)
    80003622:	00000097          	auipc	ra,0x0
    80003626:	e10080e7          	jalr	-496(ra) # 80003432 <balloc>
    8000362a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000362e:	fc090ae3          	beqz	s2,80003602 <bmap+0x98>
        a[bn] = addr;
    80003632:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003636:	8552                	mv	a0,s4
    80003638:	00001097          	auipc	ra,0x1
    8000363c:	eec080e7          	jalr	-276(ra) # 80004524 <log_write>
    80003640:	b7c9                	j	80003602 <bmap+0x98>
  panic("bmap: out of range");
    80003642:	00005517          	auipc	a0,0x5
    80003646:	f4650513          	addi	a0,a0,-186 # 80008588 <syscalls+0x118>
    8000364a:	ffffd097          	auipc	ra,0xffffd
    8000364e:	ef4080e7          	jalr	-268(ra) # 8000053e <panic>

0000000080003652 <iget>:
{
    80003652:	7179                	addi	sp,sp,-48
    80003654:	f406                	sd	ra,40(sp)
    80003656:	f022                	sd	s0,32(sp)
    80003658:	ec26                	sd	s1,24(sp)
    8000365a:	e84a                	sd	s2,16(sp)
    8000365c:	e44e                	sd	s3,8(sp)
    8000365e:	e052                	sd	s4,0(sp)
    80003660:	1800                	addi	s0,sp,48
    80003662:	89aa                	mv	s3,a0
    80003664:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003666:	0001d517          	auipc	a0,0x1d
    8000366a:	03250513          	addi	a0,a0,50 # 80020698 <itable>
    8000366e:	ffffd097          	auipc	ra,0xffffd
    80003672:	568080e7          	jalr	1384(ra) # 80000bd6 <acquire>
  empty = 0;
    80003676:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003678:	0001d497          	auipc	s1,0x1d
    8000367c:	03848493          	addi	s1,s1,56 # 800206b0 <itable+0x18>
    80003680:	0001f697          	auipc	a3,0x1f
    80003684:	ac068693          	addi	a3,a3,-1344 # 80022140 <log>
    80003688:	a039                	j	80003696 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000368a:	02090b63          	beqz	s2,800036c0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000368e:	08848493          	addi	s1,s1,136
    80003692:	02d48a63          	beq	s1,a3,800036c6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003696:	449c                	lw	a5,8(s1)
    80003698:	fef059e3          	blez	a5,8000368a <iget+0x38>
    8000369c:	4098                	lw	a4,0(s1)
    8000369e:	ff3716e3          	bne	a4,s3,8000368a <iget+0x38>
    800036a2:	40d8                	lw	a4,4(s1)
    800036a4:	ff4713e3          	bne	a4,s4,8000368a <iget+0x38>
      ip->ref++;
    800036a8:	2785                	addiw	a5,a5,1
    800036aa:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036ac:	0001d517          	auipc	a0,0x1d
    800036b0:	fec50513          	addi	a0,a0,-20 # 80020698 <itable>
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	5d6080e7          	jalr	1494(ra) # 80000c8a <release>
      return ip;
    800036bc:	8926                	mv	s2,s1
    800036be:	a03d                	j	800036ec <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036c0:	f7f9                	bnez	a5,8000368e <iget+0x3c>
    800036c2:	8926                	mv	s2,s1
    800036c4:	b7e9                	j	8000368e <iget+0x3c>
  if(empty == 0)
    800036c6:	02090c63          	beqz	s2,800036fe <iget+0xac>
  ip->dev = dev;
    800036ca:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036ce:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036d2:	4785                	li	a5,1
    800036d4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036d8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800036dc:	0001d517          	auipc	a0,0x1d
    800036e0:	fbc50513          	addi	a0,a0,-68 # 80020698 <itable>
    800036e4:	ffffd097          	auipc	ra,0xffffd
    800036e8:	5a6080e7          	jalr	1446(ra) # 80000c8a <release>
}
    800036ec:	854a                	mv	a0,s2
    800036ee:	70a2                	ld	ra,40(sp)
    800036f0:	7402                	ld	s0,32(sp)
    800036f2:	64e2                	ld	s1,24(sp)
    800036f4:	6942                	ld	s2,16(sp)
    800036f6:	69a2                	ld	s3,8(sp)
    800036f8:	6a02                	ld	s4,0(sp)
    800036fa:	6145                	addi	sp,sp,48
    800036fc:	8082                	ret
    panic("iget: no inodes");
    800036fe:	00005517          	auipc	a0,0x5
    80003702:	ea250513          	addi	a0,a0,-350 # 800085a0 <syscalls+0x130>
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	e38080e7          	jalr	-456(ra) # 8000053e <panic>

000000008000370e <fsinit>:
fsinit(int dev) {
    8000370e:	7179                	addi	sp,sp,-48
    80003710:	f406                	sd	ra,40(sp)
    80003712:	f022                	sd	s0,32(sp)
    80003714:	ec26                	sd	s1,24(sp)
    80003716:	e84a                	sd	s2,16(sp)
    80003718:	e44e                	sd	s3,8(sp)
    8000371a:	1800                	addi	s0,sp,48
    8000371c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000371e:	4585                	li	a1,1
    80003720:	00000097          	auipc	ra,0x0
    80003724:	a50080e7          	jalr	-1456(ra) # 80003170 <bread>
    80003728:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000372a:	0001d997          	auipc	s3,0x1d
    8000372e:	f4e98993          	addi	s3,s3,-178 # 80020678 <sb>
    80003732:	02000613          	li	a2,32
    80003736:	05850593          	addi	a1,a0,88
    8000373a:	854e                	mv	a0,s3
    8000373c:	ffffd097          	auipc	ra,0xffffd
    80003740:	5f2080e7          	jalr	1522(ra) # 80000d2e <memmove>
  brelse(bp);
    80003744:	8526                	mv	a0,s1
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	b5a080e7          	jalr	-1190(ra) # 800032a0 <brelse>
  if(sb.magic != FSMAGIC)
    8000374e:	0009a703          	lw	a4,0(s3)
    80003752:	102037b7          	lui	a5,0x10203
    80003756:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000375a:	02f71263          	bne	a4,a5,8000377e <fsinit+0x70>
  initlog(dev, &sb);
    8000375e:	0001d597          	auipc	a1,0x1d
    80003762:	f1a58593          	addi	a1,a1,-230 # 80020678 <sb>
    80003766:	854a                	mv	a0,s2
    80003768:	00001097          	auipc	ra,0x1
    8000376c:	b40080e7          	jalr	-1216(ra) # 800042a8 <initlog>
}
    80003770:	70a2                	ld	ra,40(sp)
    80003772:	7402                	ld	s0,32(sp)
    80003774:	64e2                	ld	s1,24(sp)
    80003776:	6942                	ld	s2,16(sp)
    80003778:	69a2                	ld	s3,8(sp)
    8000377a:	6145                	addi	sp,sp,48
    8000377c:	8082                	ret
    panic("invalid file system");
    8000377e:	00005517          	auipc	a0,0x5
    80003782:	e3250513          	addi	a0,a0,-462 # 800085b0 <syscalls+0x140>
    80003786:	ffffd097          	auipc	ra,0xffffd
    8000378a:	db8080e7          	jalr	-584(ra) # 8000053e <panic>

000000008000378e <iinit>:
{
    8000378e:	7179                	addi	sp,sp,-48
    80003790:	f406                	sd	ra,40(sp)
    80003792:	f022                	sd	s0,32(sp)
    80003794:	ec26                	sd	s1,24(sp)
    80003796:	e84a                	sd	s2,16(sp)
    80003798:	e44e                	sd	s3,8(sp)
    8000379a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000379c:	00005597          	auipc	a1,0x5
    800037a0:	e2c58593          	addi	a1,a1,-468 # 800085c8 <syscalls+0x158>
    800037a4:	0001d517          	auipc	a0,0x1d
    800037a8:	ef450513          	addi	a0,a0,-268 # 80020698 <itable>
    800037ac:	ffffd097          	auipc	ra,0xffffd
    800037b0:	39a080e7          	jalr	922(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037b4:	0001d497          	auipc	s1,0x1d
    800037b8:	f0c48493          	addi	s1,s1,-244 # 800206c0 <itable+0x28>
    800037bc:	0001f997          	auipc	s3,0x1f
    800037c0:	99498993          	addi	s3,s3,-1644 # 80022150 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800037c4:	00005917          	auipc	s2,0x5
    800037c8:	e0c90913          	addi	s2,s2,-500 # 800085d0 <syscalls+0x160>
    800037cc:	85ca                	mv	a1,s2
    800037ce:	8526                	mv	a0,s1
    800037d0:	00001097          	auipc	ra,0x1
    800037d4:	e3a080e7          	jalr	-454(ra) # 8000460a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037d8:	08848493          	addi	s1,s1,136
    800037dc:	ff3498e3          	bne	s1,s3,800037cc <iinit+0x3e>
}
    800037e0:	70a2                	ld	ra,40(sp)
    800037e2:	7402                	ld	s0,32(sp)
    800037e4:	64e2                	ld	s1,24(sp)
    800037e6:	6942                	ld	s2,16(sp)
    800037e8:	69a2                	ld	s3,8(sp)
    800037ea:	6145                	addi	sp,sp,48
    800037ec:	8082                	ret

00000000800037ee <ialloc>:
{
    800037ee:	715d                	addi	sp,sp,-80
    800037f0:	e486                	sd	ra,72(sp)
    800037f2:	e0a2                	sd	s0,64(sp)
    800037f4:	fc26                	sd	s1,56(sp)
    800037f6:	f84a                	sd	s2,48(sp)
    800037f8:	f44e                	sd	s3,40(sp)
    800037fa:	f052                	sd	s4,32(sp)
    800037fc:	ec56                	sd	s5,24(sp)
    800037fe:	e85a                	sd	s6,16(sp)
    80003800:	e45e                	sd	s7,8(sp)
    80003802:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003804:	0001d717          	auipc	a4,0x1d
    80003808:	e8072703          	lw	a4,-384(a4) # 80020684 <sb+0xc>
    8000380c:	4785                	li	a5,1
    8000380e:	04e7fa63          	bgeu	a5,a4,80003862 <ialloc+0x74>
    80003812:	8aaa                	mv	s5,a0
    80003814:	8bae                	mv	s7,a1
    80003816:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003818:	0001da17          	auipc	s4,0x1d
    8000381c:	e60a0a13          	addi	s4,s4,-416 # 80020678 <sb>
    80003820:	00048b1b          	sext.w	s6,s1
    80003824:	0044d793          	srli	a5,s1,0x4
    80003828:	018a2583          	lw	a1,24(s4)
    8000382c:	9dbd                	addw	a1,a1,a5
    8000382e:	8556                	mv	a0,s5
    80003830:	00000097          	auipc	ra,0x0
    80003834:	940080e7          	jalr	-1728(ra) # 80003170 <bread>
    80003838:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000383a:	05850993          	addi	s3,a0,88
    8000383e:	00f4f793          	andi	a5,s1,15
    80003842:	079a                	slli	a5,a5,0x6
    80003844:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003846:	00099783          	lh	a5,0(s3)
    8000384a:	c3a1                	beqz	a5,8000388a <ialloc+0x9c>
    brelse(bp);
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	a54080e7          	jalr	-1452(ra) # 800032a0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003854:	0485                	addi	s1,s1,1
    80003856:	00ca2703          	lw	a4,12(s4)
    8000385a:	0004879b          	sext.w	a5,s1
    8000385e:	fce7e1e3          	bltu	a5,a4,80003820 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003862:	00005517          	auipc	a0,0x5
    80003866:	d7650513          	addi	a0,a0,-650 # 800085d8 <syscalls+0x168>
    8000386a:	ffffd097          	auipc	ra,0xffffd
    8000386e:	d1e080e7          	jalr	-738(ra) # 80000588 <printf>
  return 0;
    80003872:	4501                	li	a0,0
}
    80003874:	60a6                	ld	ra,72(sp)
    80003876:	6406                	ld	s0,64(sp)
    80003878:	74e2                	ld	s1,56(sp)
    8000387a:	7942                	ld	s2,48(sp)
    8000387c:	79a2                	ld	s3,40(sp)
    8000387e:	7a02                	ld	s4,32(sp)
    80003880:	6ae2                	ld	s5,24(sp)
    80003882:	6b42                	ld	s6,16(sp)
    80003884:	6ba2                	ld	s7,8(sp)
    80003886:	6161                	addi	sp,sp,80
    80003888:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000388a:	04000613          	li	a2,64
    8000388e:	4581                	li	a1,0
    80003890:	854e                	mv	a0,s3
    80003892:	ffffd097          	auipc	ra,0xffffd
    80003896:	440080e7          	jalr	1088(ra) # 80000cd2 <memset>
      dip->type = type;
    8000389a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000389e:	854a                	mv	a0,s2
    800038a0:	00001097          	auipc	ra,0x1
    800038a4:	c84080e7          	jalr	-892(ra) # 80004524 <log_write>
      brelse(bp);
    800038a8:	854a                	mv	a0,s2
    800038aa:	00000097          	auipc	ra,0x0
    800038ae:	9f6080e7          	jalr	-1546(ra) # 800032a0 <brelse>
      return iget(dev, inum);
    800038b2:	85da                	mv	a1,s6
    800038b4:	8556                	mv	a0,s5
    800038b6:	00000097          	auipc	ra,0x0
    800038ba:	d9c080e7          	jalr	-612(ra) # 80003652 <iget>
    800038be:	bf5d                	j	80003874 <ialloc+0x86>

00000000800038c0 <iupdate>:
{
    800038c0:	1101                	addi	sp,sp,-32
    800038c2:	ec06                	sd	ra,24(sp)
    800038c4:	e822                	sd	s0,16(sp)
    800038c6:	e426                	sd	s1,8(sp)
    800038c8:	e04a                	sd	s2,0(sp)
    800038ca:	1000                	addi	s0,sp,32
    800038cc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038ce:	415c                	lw	a5,4(a0)
    800038d0:	0047d79b          	srliw	a5,a5,0x4
    800038d4:	0001d597          	auipc	a1,0x1d
    800038d8:	dbc5a583          	lw	a1,-580(a1) # 80020690 <sb+0x18>
    800038dc:	9dbd                	addw	a1,a1,a5
    800038de:	4108                	lw	a0,0(a0)
    800038e0:	00000097          	auipc	ra,0x0
    800038e4:	890080e7          	jalr	-1904(ra) # 80003170 <bread>
    800038e8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038ea:	05850793          	addi	a5,a0,88
    800038ee:	40c8                	lw	a0,4(s1)
    800038f0:	893d                	andi	a0,a0,15
    800038f2:	051a                	slli	a0,a0,0x6
    800038f4:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800038f6:	04449703          	lh	a4,68(s1)
    800038fa:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038fe:	04649703          	lh	a4,70(s1)
    80003902:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003906:	04849703          	lh	a4,72(s1)
    8000390a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000390e:	04a49703          	lh	a4,74(s1)
    80003912:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003916:	44f8                	lw	a4,76(s1)
    80003918:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000391a:	03400613          	li	a2,52
    8000391e:	05048593          	addi	a1,s1,80
    80003922:	0531                	addi	a0,a0,12
    80003924:	ffffd097          	auipc	ra,0xffffd
    80003928:	40a080e7          	jalr	1034(ra) # 80000d2e <memmove>
  log_write(bp);
    8000392c:	854a                	mv	a0,s2
    8000392e:	00001097          	auipc	ra,0x1
    80003932:	bf6080e7          	jalr	-1034(ra) # 80004524 <log_write>
  brelse(bp);
    80003936:	854a                	mv	a0,s2
    80003938:	00000097          	auipc	ra,0x0
    8000393c:	968080e7          	jalr	-1688(ra) # 800032a0 <brelse>
}
    80003940:	60e2                	ld	ra,24(sp)
    80003942:	6442                	ld	s0,16(sp)
    80003944:	64a2                	ld	s1,8(sp)
    80003946:	6902                	ld	s2,0(sp)
    80003948:	6105                	addi	sp,sp,32
    8000394a:	8082                	ret

000000008000394c <idup>:
{
    8000394c:	1101                	addi	sp,sp,-32
    8000394e:	ec06                	sd	ra,24(sp)
    80003950:	e822                	sd	s0,16(sp)
    80003952:	e426                	sd	s1,8(sp)
    80003954:	1000                	addi	s0,sp,32
    80003956:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003958:	0001d517          	auipc	a0,0x1d
    8000395c:	d4050513          	addi	a0,a0,-704 # 80020698 <itable>
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	276080e7          	jalr	630(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003968:	449c                	lw	a5,8(s1)
    8000396a:	2785                	addiw	a5,a5,1
    8000396c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000396e:	0001d517          	auipc	a0,0x1d
    80003972:	d2a50513          	addi	a0,a0,-726 # 80020698 <itable>
    80003976:	ffffd097          	auipc	ra,0xffffd
    8000397a:	314080e7          	jalr	788(ra) # 80000c8a <release>
}
    8000397e:	8526                	mv	a0,s1
    80003980:	60e2                	ld	ra,24(sp)
    80003982:	6442                	ld	s0,16(sp)
    80003984:	64a2                	ld	s1,8(sp)
    80003986:	6105                	addi	sp,sp,32
    80003988:	8082                	ret

000000008000398a <ilock>:
{
    8000398a:	1101                	addi	sp,sp,-32
    8000398c:	ec06                	sd	ra,24(sp)
    8000398e:	e822                	sd	s0,16(sp)
    80003990:	e426                	sd	s1,8(sp)
    80003992:	e04a                	sd	s2,0(sp)
    80003994:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003996:	c115                	beqz	a0,800039ba <ilock+0x30>
    80003998:	84aa                	mv	s1,a0
    8000399a:	451c                	lw	a5,8(a0)
    8000399c:	00f05f63          	blez	a5,800039ba <ilock+0x30>
  acquiresleep(&ip->lock);
    800039a0:	0541                	addi	a0,a0,16
    800039a2:	00001097          	auipc	ra,0x1
    800039a6:	ca2080e7          	jalr	-862(ra) # 80004644 <acquiresleep>
  if(ip->valid == 0){
    800039aa:	40bc                	lw	a5,64(s1)
    800039ac:	cf99                	beqz	a5,800039ca <ilock+0x40>
}
    800039ae:	60e2                	ld	ra,24(sp)
    800039b0:	6442                	ld	s0,16(sp)
    800039b2:	64a2                	ld	s1,8(sp)
    800039b4:	6902                	ld	s2,0(sp)
    800039b6:	6105                	addi	sp,sp,32
    800039b8:	8082                	ret
    panic("ilock");
    800039ba:	00005517          	auipc	a0,0x5
    800039be:	c3650513          	addi	a0,a0,-970 # 800085f0 <syscalls+0x180>
    800039c2:	ffffd097          	auipc	ra,0xffffd
    800039c6:	b7c080e7          	jalr	-1156(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039ca:	40dc                	lw	a5,4(s1)
    800039cc:	0047d79b          	srliw	a5,a5,0x4
    800039d0:	0001d597          	auipc	a1,0x1d
    800039d4:	cc05a583          	lw	a1,-832(a1) # 80020690 <sb+0x18>
    800039d8:	9dbd                	addw	a1,a1,a5
    800039da:	4088                	lw	a0,0(s1)
    800039dc:	fffff097          	auipc	ra,0xfffff
    800039e0:	794080e7          	jalr	1940(ra) # 80003170 <bread>
    800039e4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039e6:	05850593          	addi	a1,a0,88
    800039ea:	40dc                	lw	a5,4(s1)
    800039ec:	8bbd                	andi	a5,a5,15
    800039ee:	079a                	slli	a5,a5,0x6
    800039f0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039f2:	00059783          	lh	a5,0(a1)
    800039f6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039fa:	00259783          	lh	a5,2(a1)
    800039fe:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a02:	00459783          	lh	a5,4(a1)
    80003a06:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a0a:	00659783          	lh	a5,6(a1)
    80003a0e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a12:	459c                	lw	a5,8(a1)
    80003a14:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a16:	03400613          	li	a2,52
    80003a1a:	05b1                	addi	a1,a1,12
    80003a1c:	05048513          	addi	a0,s1,80
    80003a20:	ffffd097          	auipc	ra,0xffffd
    80003a24:	30e080e7          	jalr	782(ra) # 80000d2e <memmove>
    brelse(bp);
    80003a28:	854a                	mv	a0,s2
    80003a2a:	00000097          	auipc	ra,0x0
    80003a2e:	876080e7          	jalr	-1930(ra) # 800032a0 <brelse>
    ip->valid = 1;
    80003a32:	4785                	li	a5,1
    80003a34:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a36:	04449783          	lh	a5,68(s1)
    80003a3a:	fbb5                	bnez	a5,800039ae <ilock+0x24>
      panic("ilock: no type");
    80003a3c:	00005517          	auipc	a0,0x5
    80003a40:	bbc50513          	addi	a0,a0,-1092 # 800085f8 <syscalls+0x188>
    80003a44:	ffffd097          	auipc	ra,0xffffd
    80003a48:	afa080e7          	jalr	-1286(ra) # 8000053e <panic>

0000000080003a4c <iunlock>:
{
    80003a4c:	1101                	addi	sp,sp,-32
    80003a4e:	ec06                	sd	ra,24(sp)
    80003a50:	e822                	sd	s0,16(sp)
    80003a52:	e426                	sd	s1,8(sp)
    80003a54:	e04a                	sd	s2,0(sp)
    80003a56:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a58:	c905                	beqz	a0,80003a88 <iunlock+0x3c>
    80003a5a:	84aa                	mv	s1,a0
    80003a5c:	01050913          	addi	s2,a0,16
    80003a60:	854a                	mv	a0,s2
    80003a62:	00001097          	auipc	ra,0x1
    80003a66:	c7c080e7          	jalr	-900(ra) # 800046de <holdingsleep>
    80003a6a:	cd19                	beqz	a0,80003a88 <iunlock+0x3c>
    80003a6c:	449c                	lw	a5,8(s1)
    80003a6e:	00f05d63          	blez	a5,80003a88 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a72:	854a                	mv	a0,s2
    80003a74:	00001097          	auipc	ra,0x1
    80003a78:	c26080e7          	jalr	-986(ra) # 8000469a <releasesleep>
}
    80003a7c:	60e2                	ld	ra,24(sp)
    80003a7e:	6442                	ld	s0,16(sp)
    80003a80:	64a2                	ld	s1,8(sp)
    80003a82:	6902                	ld	s2,0(sp)
    80003a84:	6105                	addi	sp,sp,32
    80003a86:	8082                	ret
    panic("iunlock");
    80003a88:	00005517          	auipc	a0,0x5
    80003a8c:	b8050513          	addi	a0,a0,-1152 # 80008608 <syscalls+0x198>
    80003a90:	ffffd097          	auipc	ra,0xffffd
    80003a94:	aae080e7          	jalr	-1362(ra) # 8000053e <panic>

0000000080003a98 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a98:	7179                	addi	sp,sp,-48
    80003a9a:	f406                	sd	ra,40(sp)
    80003a9c:	f022                	sd	s0,32(sp)
    80003a9e:	ec26                	sd	s1,24(sp)
    80003aa0:	e84a                	sd	s2,16(sp)
    80003aa2:	e44e                	sd	s3,8(sp)
    80003aa4:	e052                	sd	s4,0(sp)
    80003aa6:	1800                	addi	s0,sp,48
    80003aa8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003aaa:	05050493          	addi	s1,a0,80
    80003aae:	08050913          	addi	s2,a0,128
    80003ab2:	a021                	j	80003aba <itrunc+0x22>
    80003ab4:	0491                	addi	s1,s1,4
    80003ab6:	01248d63          	beq	s1,s2,80003ad0 <itrunc+0x38>
    if(ip->addrs[i]){
    80003aba:	408c                	lw	a1,0(s1)
    80003abc:	dde5                	beqz	a1,80003ab4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003abe:	0009a503          	lw	a0,0(s3)
    80003ac2:	00000097          	auipc	ra,0x0
    80003ac6:	8f4080e7          	jalr	-1804(ra) # 800033b6 <bfree>
      ip->addrs[i] = 0;
    80003aca:	0004a023          	sw	zero,0(s1)
    80003ace:	b7dd                	j	80003ab4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ad0:	0809a583          	lw	a1,128(s3)
    80003ad4:	e185                	bnez	a1,80003af4 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ad6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ada:	854e                	mv	a0,s3
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	de4080e7          	jalr	-540(ra) # 800038c0 <iupdate>
}
    80003ae4:	70a2                	ld	ra,40(sp)
    80003ae6:	7402                	ld	s0,32(sp)
    80003ae8:	64e2                	ld	s1,24(sp)
    80003aea:	6942                	ld	s2,16(sp)
    80003aec:	69a2                	ld	s3,8(sp)
    80003aee:	6a02                	ld	s4,0(sp)
    80003af0:	6145                	addi	sp,sp,48
    80003af2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003af4:	0009a503          	lw	a0,0(s3)
    80003af8:	fffff097          	auipc	ra,0xfffff
    80003afc:	678080e7          	jalr	1656(ra) # 80003170 <bread>
    80003b00:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b02:	05850493          	addi	s1,a0,88
    80003b06:	45850913          	addi	s2,a0,1112
    80003b0a:	a021                	j	80003b12 <itrunc+0x7a>
    80003b0c:	0491                	addi	s1,s1,4
    80003b0e:	01248b63          	beq	s1,s2,80003b24 <itrunc+0x8c>
      if(a[j])
    80003b12:	408c                	lw	a1,0(s1)
    80003b14:	dde5                	beqz	a1,80003b0c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b16:	0009a503          	lw	a0,0(s3)
    80003b1a:	00000097          	auipc	ra,0x0
    80003b1e:	89c080e7          	jalr	-1892(ra) # 800033b6 <bfree>
    80003b22:	b7ed                	j	80003b0c <itrunc+0x74>
    brelse(bp);
    80003b24:	8552                	mv	a0,s4
    80003b26:	fffff097          	auipc	ra,0xfffff
    80003b2a:	77a080e7          	jalr	1914(ra) # 800032a0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b2e:	0809a583          	lw	a1,128(s3)
    80003b32:	0009a503          	lw	a0,0(s3)
    80003b36:	00000097          	auipc	ra,0x0
    80003b3a:	880080e7          	jalr	-1920(ra) # 800033b6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b3e:	0809a023          	sw	zero,128(s3)
    80003b42:	bf51                	j	80003ad6 <itrunc+0x3e>

0000000080003b44 <iput>:
{
    80003b44:	1101                	addi	sp,sp,-32
    80003b46:	ec06                	sd	ra,24(sp)
    80003b48:	e822                	sd	s0,16(sp)
    80003b4a:	e426                	sd	s1,8(sp)
    80003b4c:	e04a                	sd	s2,0(sp)
    80003b4e:	1000                	addi	s0,sp,32
    80003b50:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b52:	0001d517          	auipc	a0,0x1d
    80003b56:	b4650513          	addi	a0,a0,-1210 # 80020698 <itable>
    80003b5a:	ffffd097          	auipc	ra,0xffffd
    80003b5e:	07c080e7          	jalr	124(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b62:	4498                	lw	a4,8(s1)
    80003b64:	4785                	li	a5,1
    80003b66:	02f70363          	beq	a4,a5,80003b8c <iput+0x48>
  ip->ref--;
    80003b6a:	449c                	lw	a5,8(s1)
    80003b6c:	37fd                	addiw	a5,a5,-1
    80003b6e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b70:	0001d517          	auipc	a0,0x1d
    80003b74:	b2850513          	addi	a0,a0,-1240 # 80020698 <itable>
    80003b78:	ffffd097          	auipc	ra,0xffffd
    80003b7c:	112080e7          	jalr	274(ra) # 80000c8a <release>
}
    80003b80:	60e2                	ld	ra,24(sp)
    80003b82:	6442                	ld	s0,16(sp)
    80003b84:	64a2                	ld	s1,8(sp)
    80003b86:	6902                	ld	s2,0(sp)
    80003b88:	6105                	addi	sp,sp,32
    80003b8a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b8c:	40bc                	lw	a5,64(s1)
    80003b8e:	dff1                	beqz	a5,80003b6a <iput+0x26>
    80003b90:	04a49783          	lh	a5,74(s1)
    80003b94:	fbf9                	bnez	a5,80003b6a <iput+0x26>
    acquiresleep(&ip->lock);
    80003b96:	01048913          	addi	s2,s1,16
    80003b9a:	854a                	mv	a0,s2
    80003b9c:	00001097          	auipc	ra,0x1
    80003ba0:	aa8080e7          	jalr	-1368(ra) # 80004644 <acquiresleep>
    release(&itable.lock);
    80003ba4:	0001d517          	auipc	a0,0x1d
    80003ba8:	af450513          	addi	a0,a0,-1292 # 80020698 <itable>
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	0de080e7          	jalr	222(ra) # 80000c8a <release>
    itrunc(ip);
    80003bb4:	8526                	mv	a0,s1
    80003bb6:	00000097          	auipc	ra,0x0
    80003bba:	ee2080e7          	jalr	-286(ra) # 80003a98 <itrunc>
    ip->type = 0;
    80003bbe:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bc2:	8526                	mv	a0,s1
    80003bc4:	00000097          	auipc	ra,0x0
    80003bc8:	cfc080e7          	jalr	-772(ra) # 800038c0 <iupdate>
    ip->valid = 0;
    80003bcc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003bd0:	854a                	mv	a0,s2
    80003bd2:	00001097          	auipc	ra,0x1
    80003bd6:	ac8080e7          	jalr	-1336(ra) # 8000469a <releasesleep>
    acquire(&itable.lock);
    80003bda:	0001d517          	auipc	a0,0x1d
    80003bde:	abe50513          	addi	a0,a0,-1346 # 80020698 <itable>
    80003be2:	ffffd097          	auipc	ra,0xffffd
    80003be6:	ff4080e7          	jalr	-12(ra) # 80000bd6 <acquire>
    80003bea:	b741                	j	80003b6a <iput+0x26>

0000000080003bec <iunlockput>:
{
    80003bec:	1101                	addi	sp,sp,-32
    80003bee:	ec06                	sd	ra,24(sp)
    80003bf0:	e822                	sd	s0,16(sp)
    80003bf2:	e426                	sd	s1,8(sp)
    80003bf4:	1000                	addi	s0,sp,32
    80003bf6:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bf8:	00000097          	auipc	ra,0x0
    80003bfc:	e54080e7          	jalr	-428(ra) # 80003a4c <iunlock>
  iput(ip);
    80003c00:	8526                	mv	a0,s1
    80003c02:	00000097          	auipc	ra,0x0
    80003c06:	f42080e7          	jalr	-190(ra) # 80003b44 <iput>
}
    80003c0a:	60e2                	ld	ra,24(sp)
    80003c0c:	6442                	ld	s0,16(sp)
    80003c0e:	64a2                	ld	s1,8(sp)
    80003c10:	6105                	addi	sp,sp,32
    80003c12:	8082                	ret

0000000080003c14 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c14:	1141                	addi	sp,sp,-16
    80003c16:	e422                	sd	s0,8(sp)
    80003c18:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c1a:	411c                	lw	a5,0(a0)
    80003c1c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c1e:	415c                	lw	a5,4(a0)
    80003c20:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c22:	04451783          	lh	a5,68(a0)
    80003c26:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c2a:	04a51783          	lh	a5,74(a0)
    80003c2e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c32:	04c56783          	lwu	a5,76(a0)
    80003c36:	e99c                	sd	a5,16(a1)
}
    80003c38:	6422                	ld	s0,8(sp)
    80003c3a:	0141                	addi	sp,sp,16
    80003c3c:	8082                	ret

0000000080003c3e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c3e:	457c                	lw	a5,76(a0)
    80003c40:	0ed7e963          	bltu	a5,a3,80003d32 <readi+0xf4>
{
    80003c44:	7159                	addi	sp,sp,-112
    80003c46:	f486                	sd	ra,104(sp)
    80003c48:	f0a2                	sd	s0,96(sp)
    80003c4a:	eca6                	sd	s1,88(sp)
    80003c4c:	e8ca                	sd	s2,80(sp)
    80003c4e:	e4ce                	sd	s3,72(sp)
    80003c50:	e0d2                	sd	s4,64(sp)
    80003c52:	fc56                	sd	s5,56(sp)
    80003c54:	f85a                	sd	s6,48(sp)
    80003c56:	f45e                	sd	s7,40(sp)
    80003c58:	f062                	sd	s8,32(sp)
    80003c5a:	ec66                	sd	s9,24(sp)
    80003c5c:	e86a                	sd	s10,16(sp)
    80003c5e:	e46e                	sd	s11,8(sp)
    80003c60:	1880                	addi	s0,sp,112
    80003c62:	8b2a                	mv	s6,a0
    80003c64:	8bae                	mv	s7,a1
    80003c66:	8a32                	mv	s4,a2
    80003c68:	84b6                	mv	s1,a3
    80003c6a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c6c:	9f35                	addw	a4,a4,a3
    return 0;
    80003c6e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c70:	0ad76063          	bltu	a4,a3,80003d10 <readi+0xd2>
  if(off + n > ip->size)
    80003c74:	00e7f463          	bgeu	a5,a4,80003c7c <readi+0x3e>
    n = ip->size - off;
    80003c78:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c7c:	0a0a8963          	beqz	s5,80003d2e <readi+0xf0>
    80003c80:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c82:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c86:	5c7d                	li	s8,-1
    80003c88:	a82d                	j	80003cc2 <readi+0x84>
    80003c8a:	020d1d93          	slli	s11,s10,0x20
    80003c8e:	020ddd93          	srli	s11,s11,0x20
    80003c92:	05890793          	addi	a5,s2,88
    80003c96:	86ee                	mv	a3,s11
    80003c98:	963e                	add	a2,a2,a5
    80003c9a:	85d2                	mv	a1,s4
    80003c9c:	855e                	mv	a0,s7
    80003c9e:	fffff097          	auipc	ra,0xfffff
    80003ca2:	8d0080e7          	jalr	-1840(ra) # 8000256e <either_copyout>
    80003ca6:	05850d63          	beq	a0,s8,80003d00 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003caa:	854a                	mv	a0,s2
    80003cac:	fffff097          	auipc	ra,0xfffff
    80003cb0:	5f4080e7          	jalr	1524(ra) # 800032a0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cb4:	013d09bb          	addw	s3,s10,s3
    80003cb8:	009d04bb          	addw	s1,s10,s1
    80003cbc:	9a6e                	add	s4,s4,s11
    80003cbe:	0559f763          	bgeu	s3,s5,80003d0c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003cc2:	00a4d59b          	srliw	a1,s1,0xa
    80003cc6:	855a                	mv	a0,s6
    80003cc8:	00000097          	auipc	ra,0x0
    80003ccc:	8a2080e7          	jalr	-1886(ra) # 8000356a <bmap>
    80003cd0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003cd4:	cd85                	beqz	a1,80003d0c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003cd6:	000b2503          	lw	a0,0(s6)
    80003cda:	fffff097          	auipc	ra,0xfffff
    80003cde:	496080e7          	jalr	1174(ra) # 80003170 <bread>
    80003ce2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ce4:	3ff4f613          	andi	a2,s1,1023
    80003ce8:	40cc87bb          	subw	a5,s9,a2
    80003cec:	413a873b          	subw	a4,s5,s3
    80003cf0:	8d3e                	mv	s10,a5
    80003cf2:	2781                	sext.w	a5,a5
    80003cf4:	0007069b          	sext.w	a3,a4
    80003cf8:	f8f6f9e3          	bgeu	a3,a5,80003c8a <readi+0x4c>
    80003cfc:	8d3a                	mv	s10,a4
    80003cfe:	b771                	j	80003c8a <readi+0x4c>
      brelse(bp);
    80003d00:	854a                	mv	a0,s2
    80003d02:	fffff097          	auipc	ra,0xfffff
    80003d06:	59e080e7          	jalr	1438(ra) # 800032a0 <brelse>
      tot = -1;
    80003d0a:	59fd                	li	s3,-1
  }
  return tot;
    80003d0c:	0009851b          	sext.w	a0,s3
}
    80003d10:	70a6                	ld	ra,104(sp)
    80003d12:	7406                	ld	s0,96(sp)
    80003d14:	64e6                	ld	s1,88(sp)
    80003d16:	6946                	ld	s2,80(sp)
    80003d18:	69a6                	ld	s3,72(sp)
    80003d1a:	6a06                	ld	s4,64(sp)
    80003d1c:	7ae2                	ld	s5,56(sp)
    80003d1e:	7b42                	ld	s6,48(sp)
    80003d20:	7ba2                	ld	s7,40(sp)
    80003d22:	7c02                	ld	s8,32(sp)
    80003d24:	6ce2                	ld	s9,24(sp)
    80003d26:	6d42                	ld	s10,16(sp)
    80003d28:	6da2                	ld	s11,8(sp)
    80003d2a:	6165                	addi	sp,sp,112
    80003d2c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d2e:	89d6                	mv	s3,s5
    80003d30:	bff1                	j	80003d0c <readi+0xce>
    return 0;
    80003d32:	4501                	li	a0,0
}
    80003d34:	8082                	ret

0000000080003d36 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d36:	457c                	lw	a5,76(a0)
    80003d38:	10d7e863          	bltu	a5,a3,80003e48 <writei+0x112>
{
    80003d3c:	7159                	addi	sp,sp,-112
    80003d3e:	f486                	sd	ra,104(sp)
    80003d40:	f0a2                	sd	s0,96(sp)
    80003d42:	eca6                	sd	s1,88(sp)
    80003d44:	e8ca                	sd	s2,80(sp)
    80003d46:	e4ce                	sd	s3,72(sp)
    80003d48:	e0d2                	sd	s4,64(sp)
    80003d4a:	fc56                	sd	s5,56(sp)
    80003d4c:	f85a                	sd	s6,48(sp)
    80003d4e:	f45e                	sd	s7,40(sp)
    80003d50:	f062                	sd	s8,32(sp)
    80003d52:	ec66                	sd	s9,24(sp)
    80003d54:	e86a                	sd	s10,16(sp)
    80003d56:	e46e                	sd	s11,8(sp)
    80003d58:	1880                	addi	s0,sp,112
    80003d5a:	8aaa                	mv	s5,a0
    80003d5c:	8bae                	mv	s7,a1
    80003d5e:	8a32                	mv	s4,a2
    80003d60:	8936                	mv	s2,a3
    80003d62:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d64:	00e687bb          	addw	a5,a3,a4
    80003d68:	0ed7e263          	bltu	a5,a3,80003e4c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d6c:	00043737          	lui	a4,0x43
    80003d70:	0ef76063          	bltu	a4,a5,80003e50 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d74:	0c0b0863          	beqz	s6,80003e44 <writei+0x10e>
    80003d78:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d7a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d7e:	5c7d                	li	s8,-1
    80003d80:	a091                	j	80003dc4 <writei+0x8e>
    80003d82:	020d1d93          	slli	s11,s10,0x20
    80003d86:	020ddd93          	srli	s11,s11,0x20
    80003d8a:	05848793          	addi	a5,s1,88
    80003d8e:	86ee                	mv	a3,s11
    80003d90:	8652                	mv	a2,s4
    80003d92:	85de                	mv	a1,s7
    80003d94:	953e                	add	a0,a0,a5
    80003d96:	fffff097          	auipc	ra,0xfffff
    80003d9a:	830080e7          	jalr	-2000(ra) # 800025c6 <either_copyin>
    80003d9e:	07850263          	beq	a0,s8,80003e02 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003da2:	8526                	mv	a0,s1
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	780080e7          	jalr	1920(ra) # 80004524 <log_write>
    brelse(bp);
    80003dac:	8526                	mv	a0,s1
    80003dae:	fffff097          	auipc	ra,0xfffff
    80003db2:	4f2080e7          	jalr	1266(ra) # 800032a0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003db6:	013d09bb          	addw	s3,s10,s3
    80003dba:	012d093b          	addw	s2,s10,s2
    80003dbe:	9a6e                	add	s4,s4,s11
    80003dc0:	0569f663          	bgeu	s3,s6,80003e0c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003dc4:	00a9559b          	srliw	a1,s2,0xa
    80003dc8:	8556                	mv	a0,s5
    80003dca:	fffff097          	auipc	ra,0xfffff
    80003dce:	7a0080e7          	jalr	1952(ra) # 8000356a <bmap>
    80003dd2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003dd6:	c99d                	beqz	a1,80003e0c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003dd8:	000aa503          	lw	a0,0(s5)
    80003ddc:	fffff097          	auipc	ra,0xfffff
    80003de0:	394080e7          	jalr	916(ra) # 80003170 <bread>
    80003de4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003de6:	3ff97513          	andi	a0,s2,1023
    80003dea:	40ac87bb          	subw	a5,s9,a0
    80003dee:	413b073b          	subw	a4,s6,s3
    80003df2:	8d3e                	mv	s10,a5
    80003df4:	2781                	sext.w	a5,a5
    80003df6:	0007069b          	sext.w	a3,a4
    80003dfa:	f8f6f4e3          	bgeu	a3,a5,80003d82 <writei+0x4c>
    80003dfe:	8d3a                	mv	s10,a4
    80003e00:	b749                	j	80003d82 <writei+0x4c>
      brelse(bp);
    80003e02:	8526                	mv	a0,s1
    80003e04:	fffff097          	auipc	ra,0xfffff
    80003e08:	49c080e7          	jalr	1180(ra) # 800032a0 <brelse>
  }

  if(off > ip->size)
    80003e0c:	04caa783          	lw	a5,76(s5)
    80003e10:	0127f463          	bgeu	a5,s2,80003e18 <writei+0xe2>
    ip->size = off;
    80003e14:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e18:	8556                	mv	a0,s5
    80003e1a:	00000097          	auipc	ra,0x0
    80003e1e:	aa6080e7          	jalr	-1370(ra) # 800038c0 <iupdate>

  return tot;
    80003e22:	0009851b          	sext.w	a0,s3
}
    80003e26:	70a6                	ld	ra,104(sp)
    80003e28:	7406                	ld	s0,96(sp)
    80003e2a:	64e6                	ld	s1,88(sp)
    80003e2c:	6946                	ld	s2,80(sp)
    80003e2e:	69a6                	ld	s3,72(sp)
    80003e30:	6a06                	ld	s4,64(sp)
    80003e32:	7ae2                	ld	s5,56(sp)
    80003e34:	7b42                	ld	s6,48(sp)
    80003e36:	7ba2                	ld	s7,40(sp)
    80003e38:	7c02                	ld	s8,32(sp)
    80003e3a:	6ce2                	ld	s9,24(sp)
    80003e3c:	6d42                	ld	s10,16(sp)
    80003e3e:	6da2                	ld	s11,8(sp)
    80003e40:	6165                	addi	sp,sp,112
    80003e42:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e44:	89da                	mv	s3,s6
    80003e46:	bfc9                	j	80003e18 <writei+0xe2>
    return -1;
    80003e48:	557d                	li	a0,-1
}
    80003e4a:	8082                	ret
    return -1;
    80003e4c:	557d                	li	a0,-1
    80003e4e:	bfe1                	j	80003e26 <writei+0xf0>
    return -1;
    80003e50:	557d                	li	a0,-1
    80003e52:	bfd1                	j	80003e26 <writei+0xf0>

0000000080003e54 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e54:	1141                	addi	sp,sp,-16
    80003e56:	e406                	sd	ra,8(sp)
    80003e58:	e022                	sd	s0,0(sp)
    80003e5a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e5c:	4639                	li	a2,14
    80003e5e:	ffffd097          	auipc	ra,0xffffd
    80003e62:	f44080e7          	jalr	-188(ra) # 80000da2 <strncmp>
}
    80003e66:	60a2                	ld	ra,8(sp)
    80003e68:	6402                	ld	s0,0(sp)
    80003e6a:	0141                	addi	sp,sp,16
    80003e6c:	8082                	ret

0000000080003e6e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e6e:	7139                	addi	sp,sp,-64
    80003e70:	fc06                	sd	ra,56(sp)
    80003e72:	f822                	sd	s0,48(sp)
    80003e74:	f426                	sd	s1,40(sp)
    80003e76:	f04a                	sd	s2,32(sp)
    80003e78:	ec4e                	sd	s3,24(sp)
    80003e7a:	e852                	sd	s4,16(sp)
    80003e7c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e7e:	04451703          	lh	a4,68(a0)
    80003e82:	4785                	li	a5,1
    80003e84:	00f71a63          	bne	a4,a5,80003e98 <dirlookup+0x2a>
    80003e88:	892a                	mv	s2,a0
    80003e8a:	89ae                	mv	s3,a1
    80003e8c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e8e:	457c                	lw	a5,76(a0)
    80003e90:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e92:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e94:	e79d                	bnez	a5,80003ec2 <dirlookup+0x54>
    80003e96:	a8a5                	j	80003f0e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e98:	00004517          	auipc	a0,0x4
    80003e9c:	77850513          	addi	a0,a0,1912 # 80008610 <syscalls+0x1a0>
    80003ea0:	ffffc097          	auipc	ra,0xffffc
    80003ea4:	69e080e7          	jalr	1694(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003ea8:	00004517          	auipc	a0,0x4
    80003eac:	78050513          	addi	a0,a0,1920 # 80008628 <syscalls+0x1b8>
    80003eb0:	ffffc097          	auipc	ra,0xffffc
    80003eb4:	68e080e7          	jalr	1678(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eb8:	24c1                	addiw	s1,s1,16
    80003eba:	04c92783          	lw	a5,76(s2)
    80003ebe:	04f4f763          	bgeu	s1,a5,80003f0c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ec2:	4741                	li	a4,16
    80003ec4:	86a6                	mv	a3,s1
    80003ec6:	fc040613          	addi	a2,s0,-64
    80003eca:	4581                	li	a1,0
    80003ecc:	854a                	mv	a0,s2
    80003ece:	00000097          	auipc	ra,0x0
    80003ed2:	d70080e7          	jalr	-656(ra) # 80003c3e <readi>
    80003ed6:	47c1                	li	a5,16
    80003ed8:	fcf518e3          	bne	a0,a5,80003ea8 <dirlookup+0x3a>
    if(de.inum == 0)
    80003edc:	fc045783          	lhu	a5,-64(s0)
    80003ee0:	dfe1                	beqz	a5,80003eb8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ee2:	fc240593          	addi	a1,s0,-62
    80003ee6:	854e                	mv	a0,s3
    80003ee8:	00000097          	auipc	ra,0x0
    80003eec:	f6c080e7          	jalr	-148(ra) # 80003e54 <namecmp>
    80003ef0:	f561                	bnez	a0,80003eb8 <dirlookup+0x4a>
      if(poff)
    80003ef2:	000a0463          	beqz	s4,80003efa <dirlookup+0x8c>
        *poff = off;
    80003ef6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003efa:	fc045583          	lhu	a1,-64(s0)
    80003efe:	00092503          	lw	a0,0(s2)
    80003f02:	fffff097          	auipc	ra,0xfffff
    80003f06:	750080e7          	jalr	1872(ra) # 80003652 <iget>
    80003f0a:	a011                	j	80003f0e <dirlookup+0xa0>
  return 0;
    80003f0c:	4501                	li	a0,0
}
    80003f0e:	70e2                	ld	ra,56(sp)
    80003f10:	7442                	ld	s0,48(sp)
    80003f12:	74a2                	ld	s1,40(sp)
    80003f14:	7902                	ld	s2,32(sp)
    80003f16:	69e2                	ld	s3,24(sp)
    80003f18:	6a42                	ld	s4,16(sp)
    80003f1a:	6121                	addi	sp,sp,64
    80003f1c:	8082                	ret

0000000080003f1e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f1e:	711d                	addi	sp,sp,-96
    80003f20:	ec86                	sd	ra,88(sp)
    80003f22:	e8a2                	sd	s0,80(sp)
    80003f24:	e4a6                	sd	s1,72(sp)
    80003f26:	e0ca                	sd	s2,64(sp)
    80003f28:	fc4e                	sd	s3,56(sp)
    80003f2a:	f852                	sd	s4,48(sp)
    80003f2c:	f456                	sd	s5,40(sp)
    80003f2e:	f05a                	sd	s6,32(sp)
    80003f30:	ec5e                	sd	s7,24(sp)
    80003f32:	e862                	sd	s8,16(sp)
    80003f34:	e466                	sd	s9,8(sp)
    80003f36:	1080                	addi	s0,sp,96
    80003f38:	84aa                	mv	s1,a0
    80003f3a:	8aae                	mv	s5,a1
    80003f3c:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f3e:	00054703          	lbu	a4,0(a0)
    80003f42:	02f00793          	li	a5,47
    80003f46:	02f70363          	beq	a4,a5,80003f6c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f4a:	ffffe097          	auipc	ra,0xffffe
    80003f4e:	a36080e7          	jalr	-1482(ra) # 80001980 <myproc>
    80003f52:	18853503          	ld	a0,392(a0)
    80003f56:	00000097          	auipc	ra,0x0
    80003f5a:	9f6080e7          	jalr	-1546(ra) # 8000394c <idup>
    80003f5e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f60:	02f00913          	li	s2,47
  len = path - s;
    80003f64:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f66:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f68:	4b85                	li	s7,1
    80003f6a:	a865                	j	80004022 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f6c:	4585                	li	a1,1
    80003f6e:	4505                	li	a0,1
    80003f70:	fffff097          	auipc	ra,0xfffff
    80003f74:	6e2080e7          	jalr	1762(ra) # 80003652 <iget>
    80003f78:	89aa                	mv	s3,a0
    80003f7a:	b7dd                	j	80003f60 <namex+0x42>
      iunlockput(ip);
    80003f7c:	854e                	mv	a0,s3
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	c6e080e7          	jalr	-914(ra) # 80003bec <iunlockput>
      return 0;
    80003f86:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f88:	854e                	mv	a0,s3
    80003f8a:	60e6                	ld	ra,88(sp)
    80003f8c:	6446                	ld	s0,80(sp)
    80003f8e:	64a6                	ld	s1,72(sp)
    80003f90:	6906                	ld	s2,64(sp)
    80003f92:	79e2                	ld	s3,56(sp)
    80003f94:	7a42                	ld	s4,48(sp)
    80003f96:	7aa2                	ld	s5,40(sp)
    80003f98:	7b02                	ld	s6,32(sp)
    80003f9a:	6be2                	ld	s7,24(sp)
    80003f9c:	6c42                	ld	s8,16(sp)
    80003f9e:	6ca2                	ld	s9,8(sp)
    80003fa0:	6125                	addi	sp,sp,96
    80003fa2:	8082                	ret
      iunlock(ip);
    80003fa4:	854e                	mv	a0,s3
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	aa6080e7          	jalr	-1370(ra) # 80003a4c <iunlock>
      return ip;
    80003fae:	bfe9                	j	80003f88 <namex+0x6a>
      iunlockput(ip);
    80003fb0:	854e                	mv	a0,s3
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	c3a080e7          	jalr	-966(ra) # 80003bec <iunlockput>
      return 0;
    80003fba:	89e6                	mv	s3,s9
    80003fbc:	b7f1                	j	80003f88 <namex+0x6a>
  len = path - s;
    80003fbe:	40b48633          	sub	a2,s1,a1
    80003fc2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fc6:	099c5463          	bge	s8,s9,8000404e <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003fca:	4639                	li	a2,14
    80003fcc:	8552                	mv	a0,s4
    80003fce:	ffffd097          	auipc	ra,0xffffd
    80003fd2:	d60080e7          	jalr	-672(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003fd6:	0004c783          	lbu	a5,0(s1)
    80003fda:	01279763          	bne	a5,s2,80003fe8 <namex+0xca>
    path++;
    80003fde:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fe0:	0004c783          	lbu	a5,0(s1)
    80003fe4:	ff278de3          	beq	a5,s2,80003fde <namex+0xc0>
    ilock(ip);
    80003fe8:	854e                	mv	a0,s3
    80003fea:	00000097          	auipc	ra,0x0
    80003fee:	9a0080e7          	jalr	-1632(ra) # 8000398a <ilock>
    if(ip->type != T_DIR){
    80003ff2:	04499783          	lh	a5,68(s3)
    80003ff6:	f97793e3          	bne	a5,s7,80003f7c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ffa:	000a8563          	beqz	s5,80004004 <namex+0xe6>
    80003ffe:	0004c783          	lbu	a5,0(s1)
    80004002:	d3cd                	beqz	a5,80003fa4 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004004:	865a                	mv	a2,s6
    80004006:	85d2                	mv	a1,s4
    80004008:	854e                	mv	a0,s3
    8000400a:	00000097          	auipc	ra,0x0
    8000400e:	e64080e7          	jalr	-412(ra) # 80003e6e <dirlookup>
    80004012:	8caa                	mv	s9,a0
    80004014:	dd51                	beqz	a0,80003fb0 <namex+0x92>
    iunlockput(ip);
    80004016:	854e                	mv	a0,s3
    80004018:	00000097          	auipc	ra,0x0
    8000401c:	bd4080e7          	jalr	-1068(ra) # 80003bec <iunlockput>
    ip = next;
    80004020:	89e6                	mv	s3,s9
  while(*path == '/')
    80004022:	0004c783          	lbu	a5,0(s1)
    80004026:	05279763          	bne	a5,s2,80004074 <namex+0x156>
    path++;
    8000402a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000402c:	0004c783          	lbu	a5,0(s1)
    80004030:	ff278de3          	beq	a5,s2,8000402a <namex+0x10c>
  if(*path == 0)
    80004034:	c79d                	beqz	a5,80004062 <namex+0x144>
    path++;
    80004036:	85a6                	mv	a1,s1
  len = path - s;
    80004038:	8cda                	mv	s9,s6
    8000403a:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000403c:	01278963          	beq	a5,s2,8000404e <namex+0x130>
    80004040:	dfbd                	beqz	a5,80003fbe <namex+0xa0>
    path++;
    80004042:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004044:	0004c783          	lbu	a5,0(s1)
    80004048:	ff279ce3          	bne	a5,s2,80004040 <namex+0x122>
    8000404c:	bf8d                	j	80003fbe <namex+0xa0>
    memmove(name, s, len);
    8000404e:	2601                	sext.w	a2,a2
    80004050:	8552                	mv	a0,s4
    80004052:	ffffd097          	auipc	ra,0xffffd
    80004056:	cdc080e7          	jalr	-804(ra) # 80000d2e <memmove>
    name[len] = 0;
    8000405a:	9cd2                	add	s9,s9,s4
    8000405c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004060:	bf9d                	j	80003fd6 <namex+0xb8>
  if(nameiparent){
    80004062:	f20a83e3          	beqz	s5,80003f88 <namex+0x6a>
    iput(ip);
    80004066:	854e                	mv	a0,s3
    80004068:	00000097          	auipc	ra,0x0
    8000406c:	adc080e7          	jalr	-1316(ra) # 80003b44 <iput>
    return 0;
    80004070:	4981                	li	s3,0
    80004072:	bf19                	j	80003f88 <namex+0x6a>
  if(*path == 0)
    80004074:	d7fd                	beqz	a5,80004062 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004076:	0004c783          	lbu	a5,0(s1)
    8000407a:	85a6                	mv	a1,s1
    8000407c:	b7d1                	j	80004040 <namex+0x122>

000000008000407e <dirlink>:
{
    8000407e:	7139                	addi	sp,sp,-64
    80004080:	fc06                	sd	ra,56(sp)
    80004082:	f822                	sd	s0,48(sp)
    80004084:	f426                	sd	s1,40(sp)
    80004086:	f04a                	sd	s2,32(sp)
    80004088:	ec4e                	sd	s3,24(sp)
    8000408a:	e852                	sd	s4,16(sp)
    8000408c:	0080                	addi	s0,sp,64
    8000408e:	892a                	mv	s2,a0
    80004090:	8a2e                	mv	s4,a1
    80004092:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004094:	4601                	li	a2,0
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	dd8080e7          	jalr	-552(ra) # 80003e6e <dirlookup>
    8000409e:	e93d                	bnez	a0,80004114 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040a0:	04c92483          	lw	s1,76(s2)
    800040a4:	c49d                	beqz	s1,800040d2 <dirlink+0x54>
    800040a6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040a8:	4741                	li	a4,16
    800040aa:	86a6                	mv	a3,s1
    800040ac:	fc040613          	addi	a2,s0,-64
    800040b0:	4581                	li	a1,0
    800040b2:	854a                	mv	a0,s2
    800040b4:	00000097          	auipc	ra,0x0
    800040b8:	b8a080e7          	jalr	-1142(ra) # 80003c3e <readi>
    800040bc:	47c1                	li	a5,16
    800040be:	06f51163          	bne	a0,a5,80004120 <dirlink+0xa2>
    if(de.inum == 0)
    800040c2:	fc045783          	lhu	a5,-64(s0)
    800040c6:	c791                	beqz	a5,800040d2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040c8:	24c1                	addiw	s1,s1,16
    800040ca:	04c92783          	lw	a5,76(s2)
    800040ce:	fcf4ede3          	bltu	s1,a5,800040a8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040d2:	4639                	li	a2,14
    800040d4:	85d2                	mv	a1,s4
    800040d6:	fc240513          	addi	a0,s0,-62
    800040da:	ffffd097          	auipc	ra,0xffffd
    800040de:	d04080e7          	jalr	-764(ra) # 80000dde <strncpy>
  de.inum = inum;
    800040e2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040e6:	4741                	li	a4,16
    800040e8:	86a6                	mv	a3,s1
    800040ea:	fc040613          	addi	a2,s0,-64
    800040ee:	4581                	li	a1,0
    800040f0:	854a                	mv	a0,s2
    800040f2:	00000097          	auipc	ra,0x0
    800040f6:	c44080e7          	jalr	-956(ra) # 80003d36 <writei>
    800040fa:	1541                	addi	a0,a0,-16
    800040fc:	00a03533          	snez	a0,a0
    80004100:	40a00533          	neg	a0,a0
}
    80004104:	70e2                	ld	ra,56(sp)
    80004106:	7442                	ld	s0,48(sp)
    80004108:	74a2                	ld	s1,40(sp)
    8000410a:	7902                	ld	s2,32(sp)
    8000410c:	69e2                	ld	s3,24(sp)
    8000410e:	6a42                	ld	s4,16(sp)
    80004110:	6121                	addi	sp,sp,64
    80004112:	8082                	ret
    iput(ip);
    80004114:	00000097          	auipc	ra,0x0
    80004118:	a30080e7          	jalr	-1488(ra) # 80003b44 <iput>
    return -1;
    8000411c:	557d                	li	a0,-1
    8000411e:	b7dd                	j	80004104 <dirlink+0x86>
      panic("dirlink read");
    80004120:	00004517          	auipc	a0,0x4
    80004124:	51850513          	addi	a0,a0,1304 # 80008638 <syscalls+0x1c8>
    80004128:	ffffc097          	auipc	ra,0xffffc
    8000412c:	416080e7          	jalr	1046(ra) # 8000053e <panic>

0000000080004130 <namei>:

struct inode*
namei(char *path)
{
    80004130:	1101                	addi	sp,sp,-32
    80004132:	ec06                	sd	ra,24(sp)
    80004134:	e822                	sd	s0,16(sp)
    80004136:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004138:	fe040613          	addi	a2,s0,-32
    8000413c:	4581                	li	a1,0
    8000413e:	00000097          	auipc	ra,0x0
    80004142:	de0080e7          	jalr	-544(ra) # 80003f1e <namex>
}
    80004146:	60e2                	ld	ra,24(sp)
    80004148:	6442                	ld	s0,16(sp)
    8000414a:	6105                	addi	sp,sp,32
    8000414c:	8082                	ret

000000008000414e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000414e:	1141                	addi	sp,sp,-16
    80004150:	e406                	sd	ra,8(sp)
    80004152:	e022                	sd	s0,0(sp)
    80004154:	0800                	addi	s0,sp,16
    80004156:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004158:	4585                	li	a1,1
    8000415a:	00000097          	auipc	ra,0x0
    8000415e:	dc4080e7          	jalr	-572(ra) # 80003f1e <namex>
}
    80004162:	60a2                	ld	ra,8(sp)
    80004164:	6402                	ld	s0,0(sp)
    80004166:	0141                	addi	sp,sp,16
    80004168:	8082                	ret

000000008000416a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000416a:	1101                	addi	sp,sp,-32
    8000416c:	ec06                	sd	ra,24(sp)
    8000416e:	e822                	sd	s0,16(sp)
    80004170:	e426                	sd	s1,8(sp)
    80004172:	e04a                	sd	s2,0(sp)
    80004174:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004176:	0001e917          	auipc	s2,0x1e
    8000417a:	fca90913          	addi	s2,s2,-54 # 80022140 <log>
    8000417e:	01892583          	lw	a1,24(s2)
    80004182:	02892503          	lw	a0,40(s2)
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	fea080e7          	jalr	-22(ra) # 80003170 <bread>
    8000418e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004190:	02c92683          	lw	a3,44(s2)
    80004194:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004196:	02d05763          	blez	a3,800041c4 <write_head+0x5a>
    8000419a:	0001e797          	auipc	a5,0x1e
    8000419e:	fd678793          	addi	a5,a5,-42 # 80022170 <log+0x30>
    800041a2:	05c50713          	addi	a4,a0,92
    800041a6:	36fd                	addiw	a3,a3,-1
    800041a8:	1682                	slli	a3,a3,0x20
    800041aa:	9281                	srli	a3,a3,0x20
    800041ac:	068a                	slli	a3,a3,0x2
    800041ae:	0001e617          	auipc	a2,0x1e
    800041b2:	fc660613          	addi	a2,a2,-58 # 80022174 <log+0x34>
    800041b6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041b8:	4390                	lw	a2,0(a5)
    800041ba:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041bc:	0791                	addi	a5,a5,4
    800041be:	0711                	addi	a4,a4,4
    800041c0:	fed79ce3          	bne	a5,a3,800041b8 <write_head+0x4e>
  }
  bwrite(buf);
    800041c4:	8526                	mv	a0,s1
    800041c6:	fffff097          	auipc	ra,0xfffff
    800041ca:	09c080e7          	jalr	156(ra) # 80003262 <bwrite>
  brelse(buf);
    800041ce:	8526                	mv	a0,s1
    800041d0:	fffff097          	auipc	ra,0xfffff
    800041d4:	0d0080e7          	jalr	208(ra) # 800032a0 <brelse>
}
    800041d8:	60e2                	ld	ra,24(sp)
    800041da:	6442                	ld	s0,16(sp)
    800041dc:	64a2                	ld	s1,8(sp)
    800041de:	6902                	ld	s2,0(sp)
    800041e0:	6105                	addi	sp,sp,32
    800041e2:	8082                	ret

00000000800041e4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041e4:	0001e797          	auipc	a5,0x1e
    800041e8:	f887a783          	lw	a5,-120(a5) # 8002216c <log+0x2c>
    800041ec:	0af05d63          	blez	a5,800042a6 <install_trans+0xc2>
{
    800041f0:	7139                	addi	sp,sp,-64
    800041f2:	fc06                	sd	ra,56(sp)
    800041f4:	f822                	sd	s0,48(sp)
    800041f6:	f426                	sd	s1,40(sp)
    800041f8:	f04a                	sd	s2,32(sp)
    800041fa:	ec4e                	sd	s3,24(sp)
    800041fc:	e852                	sd	s4,16(sp)
    800041fe:	e456                	sd	s5,8(sp)
    80004200:	e05a                	sd	s6,0(sp)
    80004202:	0080                	addi	s0,sp,64
    80004204:	8b2a                	mv	s6,a0
    80004206:	0001ea97          	auipc	s5,0x1e
    8000420a:	f6aa8a93          	addi	s5,s5,-150 # 80022170 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000420e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004210:	0001e997          	auipc	s3,0x1e
    80004214:	f3098993          	addi	s3,s3,-208 # 80022140 <log>
    80004218:	a00d                	j	8000423a <install_trans+0x56>
    brelse(lbuf);
    8000421a:	854a                	mv	a0,s2
    8000421c:	fffff097          	auipc	ra,0xfffff
    80004220:	084080e7          	jalr	132(ra) # 800032a0 <brelse>
    brelse(dbuf);
    80004224:	8526                	mv	a0,s1
    80004226:	fffff097          	auipc	ra,0xfffff
    8000422a:	07a080e7          	jalr	122(ra) # 800032a0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000422e:	2a05                	addiw	s4,s4,1
    80004230:	0a91                	addi	s5,s5,4
    80004232:	02c9a783          	lw	a5,44(s3)
    80004236:	04fa5e63          	bge	s4,a5,80004292 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000423a:	0189a583          	lw	a1,24(s3)
    8000423e:	014585bb          	addw	a1,a1,s4
    80004242:	2585                	addiw	a1,a1,1
    80004244:	0289a503          	lw	a0,40(s3)
    80004248:	fffff097          	auipc	ra,0xfffff
    8000424c:	f28080e7          	jalr	-216(ra) # 80003170 <bread>
    80004250:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004252:	000aa583          	lw	a1,0(s5)
    80004256:	0289a503          	lw	a0,40(s3)
    8000425a:	fffff097          	auipc	ra,0xfffff
    8000425e:	f16080e7          	jalr	-234(ra) # 80003170 <bread>
    80004262:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004264:	40000613          	li	a2,1024
    80004268:	05890593          	addi	a1,s2,88
    8000426c:	05850513          	addi	a0,a0,88
    80004270:	ffffd097          	auipc	ra,0xffffd
    80004274:	abe080e7          	jalr	-1346(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004278:	8526                	mv	a0,s1
    8000427a:	fffff097          	auipc	ra,0xfffff
    8000427e:	fe8080e7          	jalr	-24(ra) # 80003262 <bwrite>
    if(recovering == 0)
    80004282:	f80b1ce3          	bnez	s6,8000421a <install_trans+0x36>
      bunpin(dbuf);
    80004286:	8526                	mv	a0,s1
    80004288:	fffff097          	auipc	ra,0xfffff
    8000428c:	0f2080e7          	jalr	242(ra) # 8000337a <bunpin>
    80004290:	b769                	j	8000421a <install_trans+0x36>
}
    80004292:	70e2                	ld	ra,56(sp)
    80004294:	7442                	ld	s0,48(sp)
    80004296:	74a2                	ld	s1,40(sp)
    80004298:	7902                	ld	s2,32(sp)
    8000429a:	69e2                	ld	s3,24(sp)
    8000429c:	6a42                	ld	s4,16(sp)
    8000429e:	6aa2                	ld	s5,8(sp)
    800042a0:	6b02                	ld	s6,0(sp)
    800042a2:	6121                	addi	sp,sp,64
    800042a4:	8082                	ret
    800042a6:	8082                	ret

00000000800042a8 <initlog>:
{
    800042a8:	7179                	addi	sp,sp,-48
    800042aa:	f406                	sd	ra,40(sp)
    800042ac:	f022                	sd	s0,32(sp)
    800042ae:	ec26                	sd	s1,24(sp)
    800042b0:	e84a                	sd	s2,16(sp)
    800042b2:	e44e                	sd	s3,8(sp)
    800042b4:	1800                	addi	s0,sp,48
    800042b6:	892a                	mv	s2,a0
    800042b8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042ba:	0001e497          	auipc	s1,0x1e
    800042be:	e8648493          	addi	s1,s1,-378 # 80022140 <log>
    800042c2:	00004597          	auipc	a1,0x4
    800042c6:	38658593          	addi	a1,a1,902 # 80008648 <syscalls+0x1d8>
    800042ca:	8526                	mv	a0,s1
    800042cc:	ffffd097          	auipc	ra,0xffffd
    800042d0:	87a080e7          	jalr	-1926(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800042d4:	0149a583          	lw	a1,20(s3)
    800042d8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800042da:	0109a783          	lw	a5,16(s3)
    800042de:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042e0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042e4:	854a                	mv	a0,s2
    800042e6:	fffff097          	auipc	ra,0xfffff
    800042ea:	e8a080e7          	jalr	-374(ra) # 80003170 <bread>
  log.lh.n = lh->n;
    800042ee:	4d34                	lw	a3,88(a0)
    800042f0:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042f2:	02d05563          	blez	a3,8000431c <initlog+0x74>
    800042f6:	05c50793          	addi	a5,a0,92
    800042fa:	0001e717          	auipc	a4,0x1e
    800042fe:	e7670713          	addi	a4,a4,-394 # 80022170 <log+0x30>
    80004302:	36fd                	addiw	a3,a3,-1
    80004304:	1682                	slli	a3,a3,0x20
    80004306:	9281                	srli	a3,a3,0x20
    80004308:	068a                	slli	a3,a3,0x2
    8000430a:	06050613          	addi	a2,a0,96
    8000430e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004310:	4390                	lw	a2,0(a5)
    80004312:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004314:	0791                	addi	a5,a5,4
    80004316:	0711                	addi	a4,a4,4
    80004318:	fed79ce3          	bne	a5,a3,80004310 <initlog+0x68>
  brelse(buf);
    8000431c:	fffff097          	auipc	ra,0xfffff
    80004320:	f84080e7          	jalr	-124(ra) # 800032a0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004324:	4505                	li	a0,1
    80004326:	00000097          	auipc	ra,0x0
    8000432a:	ebe080e7          	jalr	-322(ra) # 800041e4 <install_trans>
  log.lh.n = 0;
    8000432e:	0001e797          	auipc	a5,0x1e
    80004332:	e207af23          	sw	zero,-450(a5) # 8002216c <log+0x2c>
  write_head(); // clear the log
    80004336:	00000097          	auipc	ra,0x0
    8000433a:	e34080e7          	jalr	-460(ra) # 8000416a <write_head>
}
    8000433e:	70a2                	ld	ra,40(sp)
    80004340:	7402                	ld	s0,32(sp)
    80004342:	64e2                	ld	s1,24(sp)
    80004344:	6942                	ld	s2,16(sp)
    80004346:	69a2                	ld	s3,8(sp)
    80004348:	6145                	addi	sp,sp,48
    8000434a:	8082                	ret

000000008000434c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000434c:	1101                	addi	sp,sp,-32
    8000434e:	ec06                	sd	ra,24(sp)
    80004350:	e822                	sd	s0,16(sp)
    80004352:	e426                	sd	s1,8(sp)
    80004354:	e04a                	sd	s2,0(sp)
    80004356:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004358:	0001e517          	auipc	a0,0x1e
    8000435c:	de850513          	addi	a0,a0,-536 # 80022140 <log>
    80004360:	ffffd097          	auipc	ra,0xffffd
    80004364:	876080e7          	jalr	-1930(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004368:	0001e497          	auipc	s1,0x1e
    8000436c:	dd848493          	addi	s1,s1,-552 # 80022140 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004370:	4979                	li	s2,30
    80004372:	a039                	j	80004380 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004374:	85a6                	mv	a1,s1
    80004376:	8526                	mv	a0,s1
    80004378:	ffffe097          	auipc	ra,0xffffe
    8000437c:	d72080e7          	jalr	-654(ra) # 800020ea <sleep>
    if(log.committing){
    80004380:	50dc                	lw	a5,36(s1)
    80004382:	fbed                	bnez	a5,80004374 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004384:	509c                	lw	a5,32(s1)
    80004386:	0017871b          	addiw	a4,a5,1
    8000438a:	0007069b          	sext.w	a3,a4
    8000438e:	0027179b          	slliw	a5,a4,0x2
    80004392:	9fb9                	addw	a5,a5,a4
    80004394:	0017979b          	slliw	a5,a5,0x1
    80004398:	54d8                	lw	a4,44(s1)
    8000439a:	9fb9                	addw	a5,a5,a4
    8000439c:	00f95963          	bge	s2,a5,800043ae <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043a0:	85a6                	mv	a1,s1
    800043a2:	8526                	mv	a0,s1
    800043a4:	ffffe097          	auipc	ra,0xffffe
    800043a8:	d46080e7          	jalr	-698(ra) # 800020ea <sleep>
    800043ac:	bfd1                	j	80004380 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043ae:	0001e517          	auipc	a0,0x1e
    800043b2:	d9250513          	addi	a0,a0,-622 # 80022140 <log>
    800043b6:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800043b8:	ffffd097          	auipc	ra,0xffffd
    800043bc:	8d2080e7          	jalr	-1838(ra) # 80000c8a <release>
      break;
    }
  }
}
    800043c0:	60e2                	ld	ra,24(sp)
    800043c2:	6442                	ld	s0,16(sp)
    800043c4:	64a2                	ld	s1,8(sp)
    800043c6:	6902                	ld	s2,0(sp)
    800043c8:	6105                	addi	sp,sp,32
    800043ca:	8082                	ret

00000000800043cc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043cc:	7139                	addi	sp,sp,-64
    800043ce:	fc06                	sd	ra,56(sp)
    800043d0:	f822                	sd	s0,48(sp)
    800043d2:	f426                	sd	s1,40(sp)
    800043d4:	f04a                	sd	s2,32(sp)
    800043d6:	ec4e                	sd	s3,24(sp)
    800043d8:	e852                	sd	s4,16(sp)
    800043da:	e456                	sd	s5,8(sp)
    800043dc:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043de:	0001e497          	auipc	s1,0x1e
    800043e2:	d6248493          	addi	s1,s1,-670 # 80022140 <log>
    800043e6:	8526                	mv	a0,s1
    800043e8:	ffffc097          	auipc	ra,0xffffc
    800043ec:	7ee080e7          	jalr	2030(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800043f0:	509c                	lw	a5,32(s1)
    800043f2:	37fd                	addiw	a5,a5,-1
    800043f4:	0007891b          	sext.w	s2,a5
    800043f8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043fa:	50dc                	lw	a5,36(s1)
    800043fc:	e7b9                	bnez	a5,8000444a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043fe:	04091e63          	bnez	s2,8000445a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004402:	0001e497          	auipc	s1,0x1e
    80004406:	d3e48493          	addi	s1,s1,-706 # 80022140 <log>
    8000440a:	4785                	li	a5,1
    8000440c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000440e:	8526                	mv	a0,s1
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	87a080e7          	jalr	-1926(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004418:	54dc                	lw	a5,44(s1)
    8000441a:	06f04763          	bgtz	a5,80004488 <end_op+0xbc>
    acquire(&log.lock);
    8000441e:	0001e497          	auipc	s1,0x1e
    80004422:	d2248493          	addi	s1,s1,-734 # 80022140 <log>
    80004426:	8526                	mv	a0,s1
    80004428:	ffffc097          	auipc	ra,0xffffc
    8000442c:	7ae080e7          	jalr	1966(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004430:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004434:	8526                	mv	a0,s1
    80004436:	ffffe097          	auipc	ra,0xffffe
    8000443a:	d34080e7          	jalr	-716(ra) # 8000216a <wakeup>
    release(&log.lock);
    8000443e:	8526                	mv	a0,s1
    80004440:	ffffd097          	auipc	ra,0xffffd
    80004444:	84a080e7          	jalr	-1974(ra) # 80000c8a <release>
}
    80004448:	a03d                	j	80004476 <end_op+0xaa>
    panic("log.committing");
    8000444a:	00004517          	auipc	a0,0x4
    8000444e:	20650513          	addi	a0,a0,518 # 80008650 <syscalls+0x1e0>
    80004452:	ffffc097          	auipc	ra,0xffffc
    80004456:	0ec080e7          	jalr	236(ra) # 8000053e <panic>
    wakeup(&log);
    8000445a:	0001e497          	auipc	s1,0x1e
    8000445e:	ce648493          	addi	s1,s1,-794 # 80022140 <log>
    80004462:	8526                	mv	a0,s1
    80004464:	ffffe097          	auipc	ra,0xffffe
    80004468:	d06080e7          	jalr	-762(ra) # 8000216a <wakeup>
  release(&log.lock);
    8000446c:	8526                	mv	a0,s1
    8000446e:	ffffd097          	auipc	ra,0xffffd
    80004472:	81c080e7          	jalr	-2020(ra) # 80000c8a <release>
}
    80004476:	70e2                	ld	ra,56(sp)
    80004478:	7442                	ld	s0,48(sp)
    8000447a:	74a2                	ld	s1,40(sp)
    8000447c:	7902                	ld	s2,32(sp)
    8000447e:	69e2                	ld	s3,24(sp)
    80004480:	6a42                	ld	s4,16(sp)
    80004482:	6aa2                	ld	s5,8(sp)
    80004484:	6121                	addi	sp,sp,64
    80004486:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004488:	0001ea97          	auipc	s5,0x1e
    8000448c:	ce8a8a93          	addi	s5,s5,-792 # 80022170 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004490:	0001ea17          	auipc	s4,0x1e
    80004494:	cb0a0a13          	addi	s4,s4,-848 # 80022140 <log>
    80004498:	018a2583          	lw	a1,24(s4)
    8000449c:	012585bb          	addw	a1,a1,s2
    800044a0:	2585                	addiw	a1,a1,1
    800044a2:	028a2503          	lw	a0,40(s4)
    800044a6:	fffff097          	auipc	ra,0xfffff
    800044aa:	cca080e7          	jalr	-822(ra) # 80003170 <bread>
    800044ae:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044b0:	000aa583          	lw	a1,0(s5)
    800044b4:	028a2503          	lw	a0,40(s4)
    800044b8:	fffff097          	auipc	ra,0xfffff
    800044bc:	cb8080e7          	jalr	-840(ra) # 80003170 <bread>
    800044c0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044c2:	40000613          	li	a2,1024
    800044c6:	05850593          	addi	a1,a0,88
    800044ca:	05848513          	addi	a0,s1,88
    800044ce:	ffffd097          	auipc	ra,0xffffd
    800044d2:	860080e7          	jalr	-1952(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800044d6:	8526                	mv	a0,s1
    800044d8:	fffff097          	auipc	ra,0xfffff
    800044dc:	d8a080e7          	jalr	-630(ra) # 80003262 <bwrite>
    brelse(from);
    800044e0:	854e                	mv	a0,s3
    800044e2:	fffff097          	auipc	ra,0xfffff
    800044e6:	dbe080e7          	jalr	-578(ra) # 800032a0 <brelse>
    brelse(to);
    800044ea:	8526                	mv	a0,s1
    800044ec:	fffff097          	auipc	ra,0xfffff
    800044f0:	db4080e7          	jalr	-588(ra) # 800032a0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044f4:	2905                	addiw	s2,s2,1
    800044f6:	0a91                	addi	s5,s5,4
    800044f8:	02ca2783          	lw	a5,44(s4)
    800044fc:	f8f94ee3          	blt	s2,a5,80004498 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004500:	00000097          	auipc	ra,0x0
    80004504:	c6a080e7          	jalr	-918(ra) # 8000416a <write_head>
    install_trans(0); // Now install writes to home locations
    80004508:	4501                	li	a0,0
    8000450a:	00000097          	auipc	ra,0x0
    8000450e:	cda080e7          	jalr	-806(ra) # 800041e4 <install_trans>
    log.lh.n = 0;
    80004512:	0001e797          	auipc	a5,0x1e
    80004516:	c407ad23          	sw	zero,-934(a5) # 8002216c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000451a:	00000097          	auipc	ra,0x0
    8000451e:	c50080e7          	jalr	-944(ra) # 8000416a <write_head>
    80004522:	bdf5                	j	8000441e <end_op+0x52>

0000000080004524 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004524:	1101                	addi	sp,sp,-32
    80004526:	ec06                	sd	ra,24(sp)
    80004528:	e822                	sd	s0,16(sp)
    8000452a:	e426                	sd	s1,8(sp)
    8000452c:	e04a                	sd	s2,0(sp)
    8000452e:	1000                	addi	s0,sp,32
    80004530:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004532:	0001e917          	auipc	s2,0x1e
    80004536:	c0e90913          	addi	s2,s2,-1010 # 80022140 <log>
    8000453a:	854a                	mv	a0,s2
    8000453c:	ffffc097          	auipc	ra,0xffffc
    80004540:	69a080e7          	jalr	1690(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004544:	02c92603          	lw	a2,44(s2)
    80004548:	47f5                	li	a5,29
    8000454a:	06c7c563          	blt	a5,a2,800045b4 <log_write+0x90>
    8000454e:	0001e797          	auipc	a5,0x1e
    80004552:	c0e7a783          	lw	a5,-1010(a5) # 8002215c <log+0x1c>
    80004556:	37fd                	addiw	a5,a5,-1
    80004558:	04f65e63          	bge	a2,a5,800045b4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000455c:	0001e797          	auipc	a5,0x1e
    80004560:	c047a783          	lw	a5,-1020(a5) # 80022160 <log+0x20>
    80004564:	06f05063          	blez	a5,800045c4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004568:	4781                	li	a5,0
    8000456a:	06c05563          	blez	a2,800045d4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000456e:	44cc                	lw	a1,12(s1)
    80004570:	0001e717          	auipc	a4,0x1e
    80004574:	c0070713          	addi	a4,a4,-1024 # 80022170 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004578:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000457a:	4314                	lw	a3,0(a4)
    8000457c:	04b68c63          	beq	a3,a1,800045d4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004580:	2785                	addiw	a5,a5,1
    80004582:	0711                	addi	a4,a4,4
    80004584:	fef61be3          	bne	a2,a5,8000457a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004588:	0621                	addi	a2,a2,8
    8000458a:	060a                	slli	a2,a2,0x2
    8000458c:	0001e797          	auipc	a5,0x1e
    80004590:	bb478793          	addi	a5,a5,-1100 # 80022140 <log>
    80004594:	963e                	add	a2,a2,a5
    80004596:	44dc                	lw	a5,12(s1)
    80004598:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000459a:	8526                	mv	a0,s1
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	da2080e7          	jalr	-606(ra) # 8000333e <bpin>
    log.lh.n++;
    800045a4:	0001e717          	auipc	a4,0x1e
    800045a8:	b9c70713          	addi	a4,a4,-1124 # 80022140 <log>
    800045ac:	575c                	lw	a5,44(a4)
    800045ae:	2785                	addiw	a5,a5,1
    800045b0:	d75c                	sw	a5,44(a4)
    800045b2:	a835                	j	800045ee <log_write+0xca>
    panic("too big a transaction");
    800045b4:	00004517          	auipc	a0,0x4
    800045b8:	0ac50513          	addi	a0,a0,172 # 80008660 <syscalls+0x1f0>
    800045bc:	ffffc097          	auipc	ra,0xffffc
    800045c0:	f82080e7          	jalr	-126(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800045c4:	00004517          	auipc	a0,0x4
    800045c8:	0b450513          	addi	a0,a0,180 # 80008678 <syscalls+0x208>
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	f72080e7          	jalr	-142(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800045d4:	00878713          	addi	a4,a5,8
    800045d8:	00271693          	slli	a3,a4,0x2
    800045dc:	0001e717          	auipc	a4,0x1e
    800045e0:	b6470713          	addi	a4,a4,-1180 # 80022140 <log>
    800045e4:	9736                	add	a4,a4,a3
    800045e6:	44d4                	lw	a3,12(s1)
    800045e8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045ea:	faf608e3          	beq	a2,a5,8000459a <log_write+0x76>
  }
  release(&log.lock);
    800045ee:	0001e517          	auipc	a0,0x1e
    800045f2:	b5250513          	addi	a0,a0,-1198 # 80022140 <log>
    800045f6:	ffffc097          	auipc	ra,0xffffc
    800045fa:	694080e7          	jalr	1684(ra) # 80000c8a <release>
}
    800045fe:	60e2                	ld	ra,24(sp)
    80004600:	6442                	ld	s0,16(sp)
    80004602:	64a2                	ld	s1,8(sp)
    80004604:	6902                	ld	s2,0(sp)
    80004606:	6105                	addi	sp,sp,32
    80004608:	8082                	ret

000000008000460a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000460a:	1101                	addi	sp,sp,-32
    8000460c:	ec06                	sd	ra,24(sp)
    8000460e:	e822                	sd	s0,16(sp)
    80004610:	e426                	sd	s1,8(sp)
    80004612:	e04a                	sd	s2,0(sp)
    80004614:	1000                	addi	s0,sp,32
    80004616:	84aa                	mv	s1,a0
    80004618:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000461a:	00004597          	auipc	a1,0x4
    8000461e:	07e58593          	addi	a1,a1,126 # 80008698 <syscalls+0x228>
    80004622:	0521                	addi	a0,a0,8
    80004624:	ffffc097          	auipc	ra,0xffffc
    80004628:	522080e7          	jalr	1314(ra) # 80000b46 <initlock>
  lk->name = name;
    8000462c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004630:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004634:	0204a423          	sw	zero,40(s1)
}
    80004638:	60e2                	ld	ra,24(sp)
    8000463a:	6442                	ld	s0,16(sp)
    8000463c:	64a2                	ld	s1,8(sp)
    8000463e:	6902                	ld	s2,0(sp)
    80004640:	6105                	addi	sp,sp,32
    80004642:	8082                	ret

0000000080004644 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004644:	1101                	addi	sp,sp,-32
    80004646:	ec06                	sd	ra,24(sp)
    80004648:	e822                	sd	s0,16(sp)
    8000464a:	e426                	sd	s1,8(sp)
    8000464c:	e04a                	sd	s2,0(sp)
    8000464e:	1000                	addi	s0,sp,32
    80004650:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004652:	00850913          	addi	s2,a0,8
    80004656:	854a                	mv	a0,s2
    80004658:	ffffc097          	auipc	ra,0xffffc
    8000465c:	57e080e7          	jalr	1406(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004660:	409c                	lw	a5,0(s1)
    80004662:	cb89                	beqz	a5,80004674 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004664:	85ca                	mv	a1,s2
    80004666:	8526                	mv	a0,s1
    80004668:	ffffe097          	auipc	ra,0xffffe
    8000466c:	a82080e7          	jalr	-1406(ra) # 800020ea <sleep>
  while (lk->locked) {
    80004670:	409c                	lw	a5,0(s1)
    80004672:	fbed                	bnez	a5,80004664 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004674:	4785                	li	a5,1
    80004676:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004678:	ffffd097          	auipc	ra,0xffffd
    8000467c:	308080e7          	jalr	776(ra) # 80001980 <myproc>
    80004680:	515c                	lw	a5,36(a0)
    80004682:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004684:	854a                	mv	a0,s2
    80004686:	ffffc097          	auipc	ra,0xffffc
    8000468a:	604080e7          	jalr	1540(ra) # 80000c8a <release>
}
    8000468e:	60e2                	ld	ra,24(sp)
    80004690:	6442                	ld	s0,16(sp)
    80004692:	64a2                	ld	s1,8(sp)
    80004694:	6902                	ld	s2,0(sp)
    80004696:	6105                	addi	sp,sp,32
    80004698:	8082                	ret

000000008000469a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000469a:	1101                	addi	sp,sp,-32
    8000469c:	ec06                	sd	ra,24(sp)
    8000469e:	e822                	sd	s0,16(sp)
    800046a0:	e426                	sd	s1,8(sp)
    800046a2:	e04a                	sd	s2,0(sp)
    800046a4:	1000                	addi	s0,sp,32
    800046a6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046a8:	00850913          	addi	s2,a0,8
    800046ac:	854a                	mv	a0,s2
    800046ae:	ffffc097          	auipc	ra,0xffffc
    800046b2:	528080e7          	jalr	1320(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800046b6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046ba:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046be:	8526                	mv	a0,s1
    800046c0:	ffffe097          	auipc	ra,0xffffe
    800046c4:	aaa080e7          	jalr	-1366(ra) # 8000216a <wakeup>
  release(&lk->lk);
    800046c8:	854a                	mv	a0,s2
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	5c0080e7          	jalr	1472(ra) # 80000c8a <release>
}
    800046d2:	60e2                	ld	ra,24(sp)
    800046d4:	6442                	ld	s0,16(sp)
    800046d6:	64a2                	ld	s1,8(sp)
    800046d8:	6902                	ld	s2,0(sp)
    800046da:	6105                	addi	sp,sp,32
    800046dc:	8082                	ret

00000000800046de <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046de:	7179                	addi	sp,sp,-48
    800046e0:	f406                	sd	ra,40(sp)
    800046e2:	f022                	sd	s0,32(sp)
    800046e4:	ec26                	sd	s1,24(sp)
    800046e6:	e84a                	sd	s2,16(sp)
    800046e8:	e44e                	sd	s3,8(sp)
    800046ea:	1800                	addi	s0,sp,48
    800046ec:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046ee:	00850913          	addi	s2,a0,8
    800046f2:	854a                	mv	a0,s2
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	4e2080e7          	jalr	1250(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046fc:	409c                	lw	a5,0(s1)
    800046fe:	ef99                	bnez	a5,8000471c <holdingsleep+0x3e>
    80004700:	4481                	li	s1,0
  release(&lk->lk);
    80004702:	854a                	mv	a0,s2
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	586080e7          	jalr	1414(ra) # 80000c8a <release>
  return r;
}
    8000470c:	8526                	mv	a0,s1
    8000470e:	70a2                	ld	ra,40(sp)
    80004710:	7402                	ld	s0,32(sp)
    80004712:	64e2                	ld	s1,24(sp)
    80004714:	6942                	ld	s2,16(sp)
    80004716:	69a2                	ld	s3,8(sp)
    80004718:	6145                	addi	sp,sp,48
    8000471a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000471c:	0284a983          	lw	s3,40(s1)
    80004720:	ffffd097          	auipc	ra,0xffffd
    80004724:	260080e7          	jalr	608(ra) # 80001980 <myproc>
    80004728:	5144                	lw	s1,36(a0)
    8000472a:	413484b3          	sub	s1,s1,s3
    8000472e:	0014b493          	seqz	s1,s1
    80004732:	bfc1                	j	80004702 <holdingsleep+0x24>

0000000080004734 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004734:	1141                	addi	sp,sp,-16
    80004736:	e406                	sd	ra,8(sp)
    80004738:	e022                	sd	s0,0(sp)
    8000473a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000473c:	00004597          	auipc	a1,0x4
    80004740:	f6c58593          	addi	a1,a1,-148 # 800086a8 <syscalls+0x238>
    80004744:	0001e517          	auipc	a0,0x1e
    80004748:	b4450513          	addi	a0,a0,-1212 # 80022288 <ftable>
    8000474c:	ffffc097          	auipc	ra,0xffffc
    80004750:	3fa080e7          	jalr	1018(ra) # 80000b46 <initlock>
}
    80004754:	60a2                	ld	ra,8(sp)
    80004756:	6402                	ld	s0,0(sp)
    80004758:	0141                	addi	sp,sp,16
    8000475a:	8082                	ret

000000008000475c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000475c:	1101                	addi	sp,sp,-32
    8000475e:	ec06                	sd	ra,24(sp)
    80004760:	e822                	sd	s0,16(sp)
    80004762:	e426                	sd	s1,8(sp)
    80004764:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004766:	0001e517          	auipc	a0,0x1e
    8000476a:	b2250513          	addi	a0,a0,-1246 # 80022288 <ftable>
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	468080e7          	jalr	1128(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004776:	0001e497          	auipc	s1,0x1e
    8000477a:	b2a48493          	addi	s1,s1,-1238 # 800222a0 <ftable+0x18>
    8000477e:	0001f717          	auipc	a4,0x1f
    80004782:	ac270713          	addi	a4,a4,-1342 # 80023240 <disk>
    if(f->ref == 0){
    80004786:	40dc                	lw	a5,4(s1)
    80004788:	cf99                	beqz	a5,800047a6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000478a:	02848493          	addi	s1,s1,40
    8000478e:	fee49ce3          	bne	s1,a4,80004786 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004792:	0001e517          	auipc	a0,0x1e
    80004796:	af650513          	addi	a0,a0,-1290 # 80022288 <ftable>
    8000479a:	ffffc097          	auipc	ra,0xffffc
    8000479e:	4f0080e7          	jalr	1264(ra) # 80000c8a <release>
  return 0;
    800047a2:	4481                	li	s1,0
    800047a4:	a819                	j	800047ba <filealloc+0x5e>
      f->ref = 1;
    800047a6:	4785                	li	a5,1
    800047a8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047aa:	0001e517          	auipc	a0,0x1e
    800047ae:	ade50513          	addi	a0,a0,-1314 # 80022288 <ftable>
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	4d8080e7          	jalr	1240(ra) # 80000c8a <release>
}
    800047ba:	8526                	mv	a0,s1
    800047bc:	60e2                	ld	ra,24(sp)
    800047be:	6442                	ld	s0,16(sp)
    800047c0:	64a2                	ld	s1,8(sp)
    800047c2:	6105                	addi	sp,sp,32
    800047c4:	8082                	ret

00000000800047c6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047c6:	1101                	addi	sp,sp,-32
    800047c8:	ec06                	sd	ra,24(sp)
    800047ca:	e822                	sd	s0,16(sp)
    800047cc:	e426                	sd	s1,8(sp)
    800047ce:	1000                	addi	s0,sp,32
    800047d0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047d2:	0001e517          	auipc	a0,0x1e
    800047d6:	ab650513          	addi	a0,a0,-1354 # 80022288 <ftable>
    800047da:	ffffc097          	auipc	ra,0xffffc
    800047de:	3fc080e7          	jalr	1020(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047e2:	40dc                	lw	a5,4(s1)
    800047e4:	02f05263          	blez	a5,80004808 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047e8:	2785                	addiw	a5,a5,1
    800047ea:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047ec:	0001e517          	auipc	a0,0x1e
    800047f0:	a9c50513          	addi	a0,a0,-1380 # 80022288 <ftable>
    800047f4:	ffffc097          	auipc	ra,0xffffc
    800047f8:	496080e7          	jalr	1174(ra) # 80000c8a <release>
  return f;
}
    800047fc:	8526                	mv	a0,s1
    800047fe:	60e2                	ld	ra,24(sp)
    80004800:	6442                	ld	s0,16(sp)
    80004802:	64a2                	ld	s1,8(sp)
    80004804:	6105                	addi	sp,sp,32
    80004806:	8082                	ret
    panic("filedup");
    80004808:	00004517          	auipc	a0,0x4
    8000480c:	ea850513          	addi	a0,a0,-344 # 800086b0 <syscalls+0x240>
    80004810:	ffffc097          	auipc	ra,0xffffc
    80004814:	d2e080e7          	jalr	-722(ra) # 8000053e <panic>

0000000080004818 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004818:	7139                	addi	sp,sp,-64
    8000481a:	fc06                	sd	ra,56(sp)
    8000481c:	f822                	sd	s0,48(sp)
    8000481e:	f426                	sd	s1,40(sp)
    80004820:	f04a                	sd	s2,32(sp)
    80004822:	ec4e                	sd	s3,24(sp)
    80004824:	e852                	sd	s4,16(sp)
    80004826:	e456                	sd	s5,8(sp)
    80004828:	0080                	addi	s0,sp,64
    8000482a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000482c:	0001e517          	auipc	a0,0x1e
    80004830:	a5c50513          	addi	a0,a0,-1444 # 80022288 <ftable>
    80004834:	ffffc097          	auipc	ra,0xffffc
    80004838:	3a2080e7          	jalr	930(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000483c:	40dc                	lw	a5,4(s1)
    8000483e:	06f05163          	blez	a5,800048a0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004842:	37fd                	addiw	a5,a5,-1
    80004844:	0007871b          	sext.w	a4,a5
    80004848:	c0dc                	sw	a5,4(s1)
    8000484a:	06e04363          	bgtz	a4,800048b0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000484e:	0004a903          	lw	s2,0(s1)
    80004852:	0094ca83          	lbu	s5,9(s1)
    80004856:	0104ba03          	ld	s4,16(s1)
    8000485a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000485e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004862:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004866:	0001e517          	auipc	a0,0x1e
    8000486a:	a2250513          	addi	a0,a0,-1502 # 80022288 <ftable>
    8000486e:	ffffc097          	auipc	ra,0xffffc
    80004872:	41c080e7          	jalr	1052(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004876:	4785                	li	a5,1
    80004878:	04f90d63          	beq	s2,a5,800048d2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000487c:	3979                	addiw	s2,s2,-2
    8000487e:	4785                	li	a5,1
    80004880:	0527e063          	bltu	a5,s2,800048c0 <fileclose+0xa8>
    begin_op();
    80004884:	00000097          	auipc	ra,0x0
    80004888:	ac8080e7          	jalr	-1336(ra) # 8000434c <begin_op>
    iput(ff.ip);
    8000488c:	854e                	mv	a0,s3
    8000488e:	fffff097          	auipc	ra,0xfffff
    80004892:	2b6080e7          	jalr	694(ra) # 80003b44 <iput>
    end_op();
    80004896:	00000097          	auipc	ra,0x0
    8000489a:	b36080e7          	jalr	-1226(ra) # 800043cc <end_op>
    8000489e:	a00d                	j	800048c0 <fileclose+0xa8>
    panic("fileclose");
    800048a0:	00004517          	auipc	a0,0x4
    800048a4:	e1850513          	addi	a0,a0,-488 # 800086b8 <syscalls+0x248>
    800048a8:	ffffc097          	auipc	ra,0xffffc
    800048ac:	c96080e7          	jalr	-874(ra) # 8000053e <panic>
    release(&ftable.lock);
    800048b0:	0001e517          	auipc	a0,0x1e
    800048b4:	9d850513          	addi	a0,a0,-1576 # 80022288 <ftable>
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	3d2080e7          	jalr	978(ra) # 80000c8a <release>
  }
}
    800048c0:	70e2                	ld	ra,56(sp)
    800048c2:	7442                	ld	s0,48(sp)
    800048c4:	74a2                	ld	s1,40(sp)
    800048c6:	7902                	ld	s2,32(sp)
    800048c8:	69e2                	ld	s3,24(sp)
    800048ca:	6a42                	ld	s4,16(sp)
    800048cc:	6aa2                	ld	s5,8(sp)
    800048ce:	6121                	addi	sp,sp,64
    800048d0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048d2:	85d6                	mv	a1,s5
    800048d4:	8552                	mv	a0,s4
    800048d6:	00000097          	auipc	ra,0x0
    800048da:	34c080e7          	jalr	844(ra) # 80004c22 <pipeclose>
    800048de:	b7cd                	j	800048c0 <fileclose+0xa8>

00000000800048e0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048e0:	715d                	addi	sp,sp,-80
    800048e2:	e486                	sd	ra,72(sp)
    800048e4:	e0a2                	sd	s0,64(sp)
    800048e6:	fc26                	sd	s1,56(sp)
    800048e8:	f84a                	sd	s2,48(sp)
    800048ea:	f44e                	sd	s3,40(sp)
    800048ec:	0880                	addi	s0,sp,80
    800048ee:	84aa                	mv	s1,a0
    800048f0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048f2:	ffffd097          	auipc	ra,0xffffd
    800048f6:	08e080e7          	jalr	142(ra) # 80001980 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048fa:	409c                	lw	a5,0(s1)
    800048fc:	37f9                	addiw	a5,a5,-2
    800048fe:	4705                	li	a4,1
    80004900:	04f76763          	bltu	a4,a5,8000494e <filestat+0x6e>
    80004904:	892a                	mv	s2,a0
    ilock(f->ip);
    80004906:	6c88                	ld	a0,24(s1)
    80004908:	fffff097          	auipc	ra,0xfffff
    8000490c:	082080e7          	jalr	130(ra) # 8000398a <ilock>
    stati(f->ip, &st);
    80004910:	fb840593          	addi	a1,s0,-72
    80004914:	6c88                	ld	a0,24(s1)
    80004916:	fffff097          	auipc	ra,0xfffff
    8000491a:	2fe080e7          	jalr	766(ra) # 80003c14 <stati>
    iunlock(f->ip);
    8000491e:	6c88                	ld	a0,24(s1)
    80004920:	fffff097          	auipc	ra,0xfffff
    80004924:	12c080e7          	jalr	300(ra) # 80003a4c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004928:	46e1                	li	a3,24
    8000492a:	fb840613          	addi	a2,s0,-72
    8000492e:	85ce                	mv	a1,s3
    80004930:	10093503          	ld	a0,256(s2)
    80004934:	ffffd097          	auipc	ra,0xffffd
    80004938:	d34080e7          	jalr	-716(ra) # 80001668 <copyout>
    8000493c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004940:	60a6                	ld	ra,72(sp)
    80004942:	6406                	ld	s0,64(sp)
    80004944:	74e2                	ld	s1,56(sp)
    80004946:	7942                	ld	s2,48(sp)
    80004948:	79a2                	ld	s3,40(sp)
    8000494a:	6161                	addi	sp,sp,80
    8000494c:	8082                	ret
  return -1;
    8000494e:	557d                	li	a0,-1
    80004950:	bfc5                	j	80004940 <filestat+0x60>

0000000080004952 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004952:	7179                	addi	sp,sp,-48
    80004954:	f406                	sd	ra,40(sp)
    80004956:	f022                	sd	s0,32(sp)
    80004958:	ec26                	sd	s1,24(sp)
    8000495a:	e84a                	sd	s2,16(sp)
    8000495c:	e44e                	sd	s3,8(sp)
    8000495e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004960:	00854783          	lbu	a5,8(a0)
    80004964:	c3d5                	beqz	a5,80004a08 <fileread+0xb6>
    80004966:	84aa                	mv	s1,a0
    80004968:	89ae                	mv	s3,a1
    8000496a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000496c:	411c                	lw	a5,0(a0)
    8000496e:	4705                	li	a4,1
    80004970:	04e78963          	beq	a5,a4,800049c2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004974:	470d                	li	a4,3
    80004976:	04e78d63          	beq	a5,a4,800049d0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000497a:	4709                	li	a4,2
    8000497c:	06e79e63          	bne	a5,a4,800049f8 <fileread+0xa6>
    ilock(f->ip);
    80004980:	6d08                	ld	a0,24(a0)
    80004982:	fffff097          	auipc	ra,0xfffff
    80004986:	008080e7          	jalr	8(ra) # 8000398a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000498a:	874a                	mv	a4,s2
    8000498c:	5094                	lw	a3,32(s1)
    8000498e:	864e                	mv	a2,s3
    80004990:	4585                	li	a1,1
    80004992:	6c88                	ld	a0,24(s1)
    80004994:	fffff097          	auipc	ra,0xfffff
    80004998:	2aa080e7          	jalr	682(ra) # 80003c3e <readi>
    8000499c:	892a                	mv	s2,a0
    8000499e:	00a05563          	blez	a0,800049a8 <fileread+0x56>
      f->off += r;
    800049a2:	509c                	lw	a5,32(s1)
    800049a4:	9fa9                	addw	a5,a5,a0
    800049a6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049a8:	6c88                	ld	a0,24(s1)
    800049aa:	fffff097          	auipc	ra,0xfffff
    800049ae:	0a2080e7          	jalr	162(ra) # 80003a4c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049b2:	854a                	mv	a0,s2
    800049b4:	70a2                	ld	ra,40(sp)
    800049b6:	7402                	ld	s0,32(sp)
    800049b8:	64e2                	ld	s1,24(sp)
    800049ba:	6942                	ld	s2,16(sp)
    800049bc:	69a2                	ld	s3,8(sp)
    800049be:	6145                	addi	sp,sp,48
    800049c0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049c2:	6908                	ld	a0,16(a0)
    800049c4:	00000097          	auipc	ra,0x0
    800049c8:	3c6080e7          	jalr	966(ra) # 80004d8a <piperead>
    800049cc:	892a                	mv	s2,a0
    800049ce:	b7d5                	j	800049b2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049d0:	02451783          	lh	a5,36(a0)
    800049d4:	03079693          	slli	a3,a5,0x30
    800049d8:	92c1                	srli	a3,a3,0x30
    800049da:	4725                	li	a4,9
    800049dc:	02d76863          	bltu	a4,a3,80004a0c <fileread+0xba>
    800049e0:	0792                	slli	a5,a5,0x4
    800049e2:	0001e717          	auipc	a4,0x1e
    800049e6:	80670713          	addi	a4,a4,-2042 # 800221e8 <devsw>
    800049ea:	97ba                	add	a5,a5,a4
    800049ec:	639c                	ld	a5,0(a5)
    800049ee:	c38d                	beqz	a5,80004a10 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049f0:	4505                	li	a0,1
    800049f2:	9782                	jalr	a5
    800049f4:	892a                	mv	s2,a0
    800049f6:	bf75                	j	800049b2 <fileread+0x60>
    panic("fileread");
    800049f8:	00004517          	auipc	a0,0x4
    800049fc:	cd050513          	addi	a0,a0,-816 # 800086c8 <syscalls+0x258>
    80004a00:	ffffc097          	auipc	ra,0xffffc
    80004a04:	b3e080e7          	jalr	-1218(ra) # 8000053e <panic>
    return -1;
    80004a08:	597d                	li	s2,-1
    80004a0a:	b765                	j	800049b2 <fileread+0x60>
      return -1;
    80004a0c:	597d                	li	s2,-1
    80004a0e:	b755                	j	800049b2 <fileread+0x60>
    80004a10:	597d                	li	s2,-1
    80004a12:	b745                	j	800049b2 <fileread+0x60>

0000000080004a14 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a14:	715d                	addi	sp,sp,-80
    80004a16:	e486                	sd	ra,72(sp)
    80004a18:	e0a2                	sd	s0,64(sp)
    80004a1a:	fc26                	sd	s1,56(sp)
    80004a1c:	f84a                	sd	s2,48(sp)
    80004a1e:	f44e                	sd	s3,40(sp)
    80004a20:	f052                	sd	s4,32(sp)
    80004a22:	ec56                	sd	s5,24(sp)
    80004a24:	e85a                	sd	s6,16(sp)
    80004a26:	e45e                	sd	s7,8(sp)
    80004a28:	e062                	sd	s8,0(sp)
    80004a2a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a2c:	00954783          	lbu	a5,9(a0)
    80004a30:	10078663          	beqz	a5,80004b3c <filewrite+0x128>
    80004a34:	892a                	mv	s2,a0
    80004a36:	8aae                	mv	s5,a1
    80004a38:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a3a:	411c                	lw	a5,0(a0)
    80004a3c:	4705                	li	a4,1
    80004a3e:	02e78263          	beq	a5,a4,80004a62 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a42:	470d                	li	a4,3
    80004a44:	02e78663          	beq	a5,a4,80004a70 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a48:	4709                	li	a4,2
    80004a4a:	0ee79163          	bne	a5,a4,80004b2c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a4e:	0ac05d63          	blez	a2,80004b08 <filewrite+0xf4>
    int i = 0;
    80004a52:	4981                	li	s3,0
    80004a54:	6b05                	lui	s6,0x1
    80004a56:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a5a:	6b85                	lui	s7,0x1
    80004a5c:	c00b8b9b          	addiw	s7,s7,-1024
    80004a60:	a861                	j	80004af8 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004a62:	6908                	ld	a0,16(a0)
    80004a64:	00000097          	auipc	ra,0x0
    80004a68:	22e080e7          	jalr	558(ra) # 80004c92 <pipewrite>
    80004a6c:	8a2a                	mv	s4,a0
    80004a6e:	a045                	j	80004b0e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a70:	02451783          	lh	a5,36(a0)
    80004a74:	03079693          	slli	a3,a5,0x30
    80004a78:	92c1                	srli	a3,a3,0x30
    80004a7a:	4725                	li	a4,9
    80004a7c:	0cd76263          	bltu	a4,a3,80004b40 <filewrite+0x12c>
    80004a80:	0792                	slli	a5,a5,0x4
    80004a82:	0001d717          	auipc	a4,0x1d
    80004a86:	76670713          	addi	a4,a4,1894 # 800221e8 <devsw>
    80004a8a:	97ba                	add	a5,a5,a4
    80004a8c:	679c                	ld	a5,8(a5)
    80004a8e:	cbdd                	beqz	a5,80004b44 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a90:	4505                	li	a0,1
    80004a92:	9782                	jalr	a5
    80004a94:	8a2a                	mv	s4,a0
    80004a96:	a8a5                	j	80004b0e <filewrite+0xfa>
    80004a98:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a9c:	00000097          	auipc	ra,0x0
    80004aa0:	8b0080e7          	jalr	-1872(ra) # 8000434c <begin_op>
      ilock(f->ip);
    80004aa4:	01893503          	ld	a0,24(s2)
    80004aa8:	fffff097          	auipc	ra,0xfffff
    80004aac:	ee2080e7          	jalr	-286(ra) # 8000398a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ab0:	8762                	mv	a4,s8
    80004ab2:	02092683          	lw	a3,32(s2)
    80004ab6:	01598633          	add	a2,s3,s5
    80004aba:	4585                	li	a1,1
    80004abc:	01893503          	ld	a0,24(s2)
    80004ac0:	fffff097          	auipc	ra,0xfffff
    80004ac4:	276080e7          	jalr	630(ra) # 80003d36 <writei>
    80004ac8:	84aa                	mv	s1,a0
    80004aca:	00a05763          	blez	a0,80004ad8 <filewrite+0xc4>
        f->off += r;
    80004ace:	02092783          	lw	a5,32(s2)
    80004ad2:	9fa9                	addw	a5,a5,a0
    80004ad4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ad8:	01893503          	ld	a0,24(s2)
    80004adc:	fffff097          	auipc	ra,0xfffff
    80004ae0:	f70080e7          	jalr	-144(ra) # 80003a4c <iunlock>
      end_op();
    80004ae4:	00000097          	auipc	ra,0x0
    80004ae8:	8e8080e7          	jalr	-1816(ra) # 800043cc <end_op>

      if(r != n1){
    80004aec:	009c1f63          	bne	s8,s1,80004b0a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004af0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004af4:	0149db63          	bge	s3,s4,80004b0a <filewrite+0xf6>
      int n1 = n - i;
    80004af8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004afc:	84be                	mv	s1,a5
    80004afe:	2781                	sext.w	a5,a5
    80004b00:	f8fb5ce3          	bge	s6,a5,80004a98 <filewrite+0x84>
    80004b04:	84de                	mv	s1,s7
    80004b06:	bf49                	j	80004a98 <filewrite+0x84>
    int i = 0;
    80004b08:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b0a:	013a1f63          	bne	s4,s3,80004b28 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b0e:	8552                	mv	a0,s4
    80004b10:	60a6                	ld	ra,72(sp)
    80004b12:	6406                	ld	s0,64(sp)
    80004b14:	74e2                	ld	s1,56(sp)
    80004b16:	7942                	ld	s2,48(sp)
    80004b18:	79a2                	ld	s3,40(sp)
    80004b1a:	7a02                	ld	s4,32(sp)
    80004b1c:	6ae2                	ld	s5,24(sp)
    80004b1e:	6b42                	ld	s6,16(sp)
    80004b20:	6ba2                	ld	s7,8(sp)
    80004b22:	6c02                	ld	s8,0(sp)
    80004b24:	6161                	addi	sp,sp,80
    80004b26:	8082                	ret
    ret = (i == n ? n : -1);
    80004b28:	5a7d                	li	s4,-1
    80004b2a:	b7d5                	j	80004b0e <filewrite+0xfa>
    panic("filewrite");
    80004b2c:	00004517          	auipc	a0,0x4
    80004b30:	bac50513          	addi	a0,a0,-1108 # 800086d8 <syscalls+0x268>
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	a0a080e7          	jalr	-1526(ra) # 8000053e <panic>
    return -1;
    80004b3c:	5a7d                	li	s4,-1
    80004b3e:	bfc1                	j	80004b0e <filewrite+0xfa>
      return -1;
    80004b40:	5a7d                	li	s4,-1
    80004b42:	b7f1                	j	80004b0e <filewrite+0xfa>
    80004b44:	5a7d                	li	s4,-1
    80004b46:	b7e1                	j	80004b0e <filewrite+0xfa>

0000000080004b48 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b48:	7179                	addi	sp,sp,-48
    80004b4a:	f406                	sd	ra,40(sp)
    80004b4c:	f022                	sd	s0,32(sp)
    80004b4e:	ec26                	sd	s1,24(sp)
    80004b50:	e84a                	sd	s2,16(sp)
    80004b52:	e44e                	sd	s3,8(sp)
    80004b54:	e052                	sd	s4,0(sp)
    80004b56:	1800                	addi	s0,sp,48
    80004b58:	84aa                	mv	s1,a0
    80004b5a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b5c:	0005b023          	sd	zero,0(a1)
    80004b60:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b64:	00000097          	auipc	ra,0x0
    80004b68:	bf8080e7          	jalr	-1032(ra) # 8000475c <filealloc>
    80004b6c:	e088                	sd	a0,0(s1)
    80004b6e:	c551                	beqz	a0,80004bfa <pipealloc+0xb2>
    80004b70:	00000097          	auipc	ra,0x0
    80004b74:	bec080e7          	jalr	-1044(ra) # 8000475c <filealloc>
    80004b78:	00aa3023          	sd	a0,0(s4)
    80004b7c:	c92d                	beqz	a0,80004bee <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b7e:	ffffc097          	auipc	ra,0xffffc
    80004b82:	f68080e7          	jalr	-152(ra) # 80000ae6 <kalloc>
    80004b86:	892a                	mv	s2,a0
    80004b88:	c125                	beqz	a0,80004be8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b8a:	4985                	li	s3,1
    80004b8c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b90:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b94:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b98:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b9c:	00004597          	auipc	a1,0x4
    80004ba0:	b4c58593          	addi	a1,a1,-1204 # 800086e8 <syscalls+0x278>
    80004ba4:	ffffc097          	auipc	ra,0xffffc
    80004ba8:	fa2080e7          	jalr	-94(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004bac:	609c                	ld	a5,0(s1)
    80004bae:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bb2:	609c                	ld	a5,0(s1)
    80004bb4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bb8:	609c                	ld	a5,0(s1)
    80004bba:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bbe:	609c                	ld	a5,0(s1)
    80004bc0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bc4:	000a3783          	ld	a5,0(s4)
    80004bc8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bcc:	000a3783          	ld	a5,0(s4)
    80004bd0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bd4:	000a3783          	ld	a5,0(s4)
    80004bd8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bdc:	000a3783          	ld	a5,0(s4)
    80004be0:	0127b823          	sd	s2,16(a5)
  return 0;
    80004be4:	4501                	li	a0,0
    80004be6:	a025                	j	80004c0e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004be8:	6088                	ld	a0,0(s1)
    80004bea:	e501                	bnez	a0,80004bf2 <pipealloc+0xaa>
    80004bec:	a039                	j	80004bfa <pipealloc+0xb2>
    80004bee:	6088                	ld	a0,0(s1)
    80004bf0:	c51d                	beqz	a0,80004c1e <pipealloc+0xd6>
    fileclose(*f0);
    80004bf2:	00000097          	auipc	ra,0x0
    80004bf6:	c26080e7          	jalr	-986(ra) # 80004818 <fileclose>
  if(*f1)
    80004bfa:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bfe:	557d                	li	a0,-1
  if(*f1)
    80004c00:	c799                	beqz	a5,80004c0e <pipealloc+0xc6>
    fileclose(*f1);
    80004c02:	853e                	mv	a0,a5
    80004c04:	00000097          	auipc	ra,0x0
    80004c08:	c14080e7          	jalr	-1004(ra) # 80004818 <fileclose>
  return -1;
    80004c0c:	557d                	li	a0,-1
}
    80004c0e:	70a2                	ld	ra,40(sp)
    80004c10:	7402                	ld	s0,32(sp)
    80004c12:	64e2                	ld	s1,24(sp)
    80004c14:	6942                	ld	s2,16(sp)
    80004c16:	69a2                	ld	s3,8(sp)
    80004c18:	6a02                	ld	s4,0(sp)
    80004c1a:	6145                	addi	sp,sp,48
    80004c1c:	8082                	ret
  return -1;
    80004c1e:	557d                	li	a0,-1
    80004c20:	b7fd                	j	80004c0e <pipealloc+0xc6>

0000000080004c22 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c22:	1101                	addi	sp,sp,-32
    80004c24:	ec06                	sd	ra,24(sp)
    80004c26:	e822                	sd	s0,16(sp)
    80004c28:	e426                	sd	s1,8(sp)
    80004c2a:	e04a                	sd	s2,0(sp)
    80004c2c:	1000                	addi	s0,sp,32
    80004c2e:	84aa                	mv	s1,a0
    80004c30:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c32:	ffffc097          	auipc	ra,0xffffc
    80004c36:	fa4080e7          	jalr	-92(ra) # 80000bd6 <acquire>
  if(writable){
    80004c3a:	02090d63          	beqz	s2,80004c74 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c3e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c42:	21848513          	addi	a0,s1,536
    80004c46:	ffffd097          	auipc	ra,0xffffd
    80004c4a:	524080e7          	jalr	1316(ra) # 8000216a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c4e:	2204b783          	ld	a5,544(s1)
    80004c52:	eb95                	bnez	a5,80004c86 <pipeclose+0x64>
    release(&pi->lock);
    80004c54:	8526                	mv	a0,s1
    80004c56:	ffffc097          	auipc	ra,0xffffc
    80004c5a:	034080e7          	jalr	52(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004c5e:	8526                	mv	a0,s1
    80004c60:	ffffc097          	auipc	ra,0xffffc
    80004c64:	d8a080e7          	jalr	-630(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004c68:	60e2                	ld	ra,24(sp)
    80004c6a:	6442                	ld	s0,16(sp)
    80004c6c:	64a2                	ld	s1,8(sp)
    80004c6e:	6902                	ld	s2,0(sp)
    80004c70:	6105                	addi	sp,sp,32
    80004c72:	8082                	ret
    pi->readopen = 0;
    80004c74:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c78:	21c48513          	addi	a0,s1,540
    80004c7c:	ffffd097          	auipc	ra,0xffffd
    80004c80:	4ee080e7          	jalr	1262(ra) # 8000216a <wakeup>
    80004c84:	b7e9                	j	80004c4e <pipeclose+0x2c>
    release(&pi->lock);
    80004c86:	8526                	mv	a0,s1
    80004c88:	ffffc097          	auipc	ra,0xffffc
    80004c8c:	002080e7          	jalr	2(ra) # 80000c8a <release>
}
    80004c90:	bfe1                	j	80004c68 <pipeclose+0x46>

0000000080004c92 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c92:	711d                	addi	sp,sp,-96
    80004c94:	ec86                	sd	ra,88(sp)
    80004c96:	e8a2                	sd	s0,80(sp)
    80004c98:	e4a6                	sd	s1,72(sp)
    80004c9a:	e0ca                	sd	s2,64(sp)
    80004c9c:	fc4e                	sd	s3,56(sp)
    80004c9e:	f852                	sd	s4,48(sp)
    80004ca0:	f456                	sd	s5,40(sp)
    80004ca2:	f05a                	sd	s6,32(sp)
    80004ca4:	ec5e                	sd	s7,24(sp)
    80004ca6:	e862                	sd	s8,16(sp)
    80004ca8:	1080                	addi	s0,sp,96
    80004caa:	84aa                	mv	s1,a0
    80004cac:	8aae                	mv	s5,a1
    80004cae:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004cb0:	ffffd097          	auipc	ra,0xffffd
    80004cb4:	cd0080e7          	jalr	-816(ra) # 80001980 <myproc>
    80004cb8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004cba:	8526                	mv	a0,s1
    80004cbc:	ffffc097          	auipc	ra,0xffffc
    80004cc0:	f1a080e7          	jalr	-230(ra) # 80000bd6 <acquire>
  while(i < n){
    80004cc4:	0b405663          	blez	s4,80004d70 <pipewrite+0xde>
  int i = 0;
    80004cc8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cca:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ccc:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cd0:	21c48b93          	addi	s7,s1,540
    80004cd4:	a089                	j	80004d16 <pipewrite+0x84>
      release(&pi->lock);
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	ffffc097          	auipc	ra,0xffffc
    80004cdc:	fb2080e7          	jalr	-78(ra) # 80000c8a <release>
      return -1;
    80004ce0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ce2:	854a                	mv	a0,s2
    80004ce4:	60e6                	ld	ra,88(sp)
    80004ce6:	6446                	ld	s0,80(sp)
    80004ce8:	64a6                	ld	s1,72(sp)
    80004cea:	6906                	ld	s2,64(sp)
    80004cec:	79e2                	ld	s3,56(sp)
    80004cee:	7a42                	ld	s4,48(sp)
    80004cf0:	7aa2                	ld	s5,40(sp)
    80004cf2:	7b02                	ld	s6,32(sp)
    80004cf4:	6be2                	ld	s7,24(sp)
    80004cf6:	6c42                	ld	s8,16(sp)
    80004cf8:	6125                	addi	sp,sp,96
    80004cfa:	8082                	ret
      wakeup(&pi->nread);
    80004cfc:	8562                	mv	a0,s8
    80004cfe:	ffffd097          	auipc	ra,0xffffd
    80004d02:	46c080e7          	jalr	1132(ra) # 8000216a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d06:	85a6                	mv	a1,s1
    80004d08:	855e                	mv	a0,s7
    80004d0a:	ffffd097          	auipc	ra,0xffffd
    80004d0e:	3e0080e7          	jalr	992(ra) # 800020ea <sleep>
  while(i < n){
    80004d12:	07495063          	bge	s2,s4,80004d72 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d16:	2204a783          	lw	a5,544(s1)
    80004d1a:	dfd5                	beqz	a5,80004cd6 <pipewrite+0x44>
    80004d1c:	854e                	mv	a0,s3
    80004d1e:	ffffd097          	auipc	ra,0xffffd
    80004d22:	6f0080e7          	jalr	1776(ra) # 8000240e <killed>
    80004d26:	f945                	bnez	a0,80004cd6 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d28:	2184a783          	lw	a5,536(s1)
    80004d2c:	21c4a703          	lw	a4,540(s1)
    80004d30:	2007879b          	addiw	a5,a5,512
    80004d34:	fcf704e3          	beq	a4,a5,80004cfc <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d38:	4685                	li	a3,1
    80004d3a:	01590633          	add	a2,s2,s5
    80004d3e:	faf40593          	addi	a1,s0,-81
    80004d42:	1009b503          	ld	a0,256(s3)
    80004d46:	ffffd097          	auipc	ra,0xffffd
    80004d4a:	9ae080e7          	jalr	-1618(ra) # 800016f4 <copyin>
    80004d4e:	03650263          	beq	a0,s6,80004d72 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d52:	21c4a783          	lw	a5,540(s1)
    80004d56:	0017871b          	addiw	a4,a5,1
    80004d5a:	20e4ae23          	sw	a4,540(s1)
    80004d5e:	1ff7f793          	andi	a5,a5,511
    80004d62:	97a6                	add	a5,a5,s1
    80004d64:	faf44703          	lbu	a4,-81(s0)
    80004d68:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d6c:	2905                	addiw	s2,s2,1
    80004d6e:	b755                	j	80004d12 <pipewrite+0x80>
  int i = 0;
    80004d70:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d72:	21848513          	addi	a0,s1,536
    80004d76:	ffffd097          	auipc	ra,0xffffd
    80004d7a:	3f4080e7          	jalr	1012(ra) # 8000216a <wakeup>
  release(&pi->lock);
    80004d7e:	8526                	mv	a0,s1
    80004d80:	ffffc097          	auipc	ra,0xffffc
    80004d84:	f0a080e7          	jalr	-246(ra) # 80000c8a <release>
  return i;
    80004d88:	bfa9                	j	80004ce2 <pipewrite+0x50>

0000000080004d8a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d8a:	715d                	addi	sp,sp,-80
    80004d8c:	e486                	sd	ra,72(sp)
    80004d8e:	e0a2                	sd	s0,64(sp)
    80004d90:	fc26                	sd	s1,56(sp)
    80004d92:	f84a                	sd	s2,48(sp)
    80004d94:	f44e                	sd	s3,40(sp)
    80004d96:	f052                	sd	s4,32(sp)
    80004d98:	ec56                	sd	s5,24(sp)
    80004d9a:	e85a                	sd	s6,16(sp)
    80004d9c:	0880                	addi	s0,sp,80
    80004d9e:	84aa                	mv	s1,a0
    80004da0:	892e                	mv	s2,a1
    80004da2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004da4:	ffffd097          	auipc	ra,0xffffd
    80004da8:	bdc080e7          	jalr	-1060(ra) # 80001980 <myproc>
    80004dac:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004dae:	8526                	mv	a0,s1
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	e26080e7          	jalr	-474(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004db8:	2184a703          	lw	a4,536(s1)
    80004dbc:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dc0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dc4:	02f71763          	bne	a4,a5,80004df2 <piperead+0x68>
    80004dc8:	2244a783          	lw	a5,548(s1)
    80004dcc:	c39d                	beqz	a5,80004df2 <piperead+0x68>
    if(killed(pr)){
    80004dce:	8552                	mv	a0,s4
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	63e080e7          	jalr	1598(ra) # 8000240e <killed>
    80004dd8:	e941                	bnez	a0,80004e68 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dda:	85a6                	mv	a1,s1
    80004ddc:	854e                	mv	a0,s3
    80004dde:	ffffd097          	auipc	ra,0xffffd
    80004de2:	30c080e7          	jalr	780(ra) # 800020ea <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004de6:	2184a703          	lw	a4,536(s1)
    80004dea:	21c4a783          	lw	a5,540(s1)
    80004dee:	fcf70de3          	beq	a4,a5,80004dc8 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004df2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004df4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004df6:	05505363          	blez	s5,80004e3c <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004dfa:	2184a783          	lw	a5,536(s1)
    80004dfe:	21c4a703          	lw	a4,540(s1)
    80004e02:	02f70d63          	beq	a4,a5,80004e3c <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e06:	0017871b          	addiw	a4,a5,1
    80004e0a:	20e4ac23          	sw	a4,536(s1)
    80004e0e:	1ff7f793          	andi	a5,a5,511
    80004e12:	97a6                	add	a5,a5,s1
    80004e14:	0187c783          	lbu	a5,24(a5)
    80004e18:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e1c:	4685                	li	a3,1
    80004e1e:	fbf40613          	addi	a2,s0,-65
    80004e22:	85ca                	mv	a1,s2
    80004e24:	100a3503          	ld	a0,256(s4)
    80004e28:	ffffd097          	auipc	ra,0xffffd
    80004e2c:	840080e7          	jalr	-1984(ra) # 80001668 <copyout>
    80004e30:	01650663          	beq	a0,s6,80004e3c <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e34:	2985                	addiw	s3,s3,1
    80004e36:	0905                	addi	s2,s2,1
    80004e38:	fd3a91e3          	bne	s5,s3,80004dfa <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e3c:	21c48513          	addi	a0,s1,540
    80004e40:	ffffd097          	auipc	ra,0xffffd
    80004e44:	32a080e7          	jalr	810(ra) # 8000216a <wakeup>
  release(&pi->lock);
    80004e48:	8526                	mv	a0,s1
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	e40080e7          	jalr	-448(ra) # 80000c8a <release>
  return i;
}
    80004e52:	854e                	mv	a0,s3
    80004e54:	60a6                	ld	ra,72(sp)
    80004e56:	6406                	ld	s0,64(sp)
    80004e58:	74e2                	ld	s1,56(sp)
    80004e5a:	7942                	ld	s2,48(sp)
    80004e5c:	79a2                	ld	s3,40(sp)
    80004e5e:	7a02                	ld	s4,32(sp)
    80004e60:	6ae2                	ld	s5,24(sp)
    80004e62:	6b42                	ld	s6,16(sp)
    80004e64:	6161                	addi	sp,sp,80
    80004e66:	8082                	ret
      release(&pi->lock);
    80004e68:	8526                	mv	a0,s1
    80004e6a:	ffffc097          	auipc	ra,0xffffc
    80004e6e:	e20080e7          	jalr	-480(ra) # 80000c8a <release>
      return -1;
    80004e72:	59fd                	li	s3,-1
    80004e74:	bff9                	j	80004e52 <piperead+0xc8>

0000000080004e76 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e76:	1141                	addi	sp,sp,-16
    80004e78:	e422                	sd	s0,8(sp)
    80004e7a:	0800                	addi	s0,sp,16
    80004e7c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e7e:	8905                	andi	a0,a0,1
    80004e80:	c111                	beqz	a0,80004e84 <flags2perm+0xe>
      perm = PTE_X;
    80004e82:	4521                	li	a0,8
    if(flags & 0x2)
    80004e84:	8b89                	andi	a5,a5,2
    80004e86:	c399                	beqz	a5,80004e8c <flags2perm+0x16>
      perm |= PTE_W;
    80004e88:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e8c:	6422                	ld	s0,8(sp)
    80004e8e:	0141                	addi	sp,sp,16
    80004e90:	8082                	ret

0000000080004e92 <exec>:

int
exec(char *path, char **argv)
{
    80004e92:	de010113          	addi	sp,sp,-544
    80004e96:	20113c23          	sd	ra,536(sp)
    80004e9a:	20813823          	sd	s0,528(sp)
    80004e9e:	20913423          	sd	s1,520(sp)
    80004ea2:	21213023          	sd	s2,512(sp)
    80004ea6:	ffce                	sd	s3,504(sp)
    80004ea8:	fbd2                	sd	s4,496(sp)
    80004eaa:	f7d6                	sd	s5,488(sp)
    80004eac:	f3da                	sd	s6,480(sp)
    80004eae:	efde                	sd	s7,472(sp)
    80004eb0:	ebe2                	sd	s8,464(sp)
    80004eb2:	e7e6                	sd	s9,456(sp)
    80004eb4:	e3ea                	sd	s10,448(sp)
    80004eb6:	ff6e                	sd	s11,440(sp)
    80004eb8:	1400                	addi	s0,sp,544
    80004eba:	892a                	mv	s2,a0
    80004ebc:	dea43423          	sd	a0,-536(s0)
    80004ec0:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ec4:	ffffd097          	auipc	ra,0xffffd
    80004ec8:	abc080e7          	jalr	-1348(ra) # 80001980 <myproc>
    80004ecc:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80004ece:	ffffe097          	auipc	ra,0xffffe
    80004ed2:	870080e7          	jalr	-1936(ra) # 8000273e <mykthread>

  begin_op();
    80004ed6:	fffff097          	auipc	ra,0xfffff
    80004eda:	476080e7          	jalr	1142(ra) # 8000434c <begin_op>

  if((ip = namei(path)) == 0){
    80004ede:	854a                	mv	a0,s2
    80004ee0:	fffff097          	auipc	ra,0xfffff
    80004ee4:	250080e7          	jalr	592(ra) # 80004130 <namei>
    80004ee8:	c93d                	beqz	a0,80004f5e <exec+0xcc>
    80004eea:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004eec:	fffff097          	auipc	ra,0xfffff
    80004ef0:	a9e080e7          	jalr	-1378(ra) # 8000398a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ef4:	04000713          	li	a4,64
    80004ef8:	4681                	li	a3,0
    80004efa:	e5040613          	addi	a2,s0,-432
    80004efe:	4581                	li	a1,0
    80004f00:	8556                	mv	a0,s5
    80004f02:	fffff097          	auipc	ra,0xfffff
    80004f06:	d3c080e7          	jalr	-708(ra) # 80003c3e <readi>
    80004f0a:	04000793          	li	a5,64
    80004f0e:	00f51a63          	bne	a0,a5,80004f22 <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f12:	e5042703          	lw	a4,-432(s0)
    80004f16:	464c47b7          	lui	a5,0x464c4
    80004f1a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f1e:	04f70663          	beq	a4,a5,80004f6a <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f22:	8556                	mv	a0,s5
    80004f24:	fffff097          	auipc	ra,0xfffff
    80004f28:	cc8080e7          	jalr	-824(ra) # 80003bec <iunlockput>
    end_op();
    80004f2c:	fffff097          	auipc	ra,0xfffff
    80004f30:	4a0080e7          	jalr	1184(ra) # 800043cc <end_op>
  }
  return -1;
    80004f34:	557d                	li	a0,-1
}
    80004f36:	21813083          	ld	ra,536(sp)
    80004f3a:	21013403          	ld	s0,528(sp)
    80004f3e:	20813483          	ld	s1,520(sp)
    80004f42:	20013903          	ld	s2,512(sp)
    80004f46:	79fe                	ld	s3,504(sp)
    80004f48:	7a5e                	ld	s4,496(sp)
    80004f4a:	7abe                	ld	s5,488(sp)
    80004f4c:	7b1e                	ld	s6,480(sp)
    80004f4e:	6bfe                	ld	s7,472(sp)
    80004f50:	6c5e                	ld	s8,464(sp)
    80004f52:	6cbe                	ld	s9,456(sp)
    80004f54:	6d1e                	ld	s10,448(sp)
    80004f56:	7dfa                	ld	s11,440(sp)
    80004f58:	22010113          	addi	sp,sp,544
    80004f5c:	8082                	ret
    end_op();
    80004f5e:	fffff097          	auipc	ra,0xfffff
    80004f62:	46e080e7          	jalr	1134(ra) # 800043cc <end_op>
    return -1;
    80004f66:	557d                	li	a0,-1
    80004f68:	b7f9                	j	80004f36 <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f6a:	8526                	mv	a0,s1
    80004f6c:	ffffd097          	auipc	ra,0xffffd
    80004f70:	ab0080e7          	jalr	-1360(ra) # 80001a1c <proc_pagetable>
    80004f74:	8b2a                	mv	s6,a0
    80004f76:	d555                	beqz	a0,80004f22 <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f78:	e7042783          	lw	a5,-400(s0)
    80004f7c:	e8845703          	lhu	a4,-376(s0)
    80004f80:	c735                	beqz	a4,80004fec <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f82:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f84:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f88:	6a05                	lui	s4,0x1
    80004f8a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f8e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f92:	6d85                	lui	s11,0x1
    80004f94:	7d7d                	lui	s10,0xfffff
    80004f96:	a4a9                	j	800051e0 <exec+0x34e>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f98:	00003517          	auipc	a0,0x3
    80004f9c:	75850513          	addi	a0,a0,1880 # 800086f0 <syscalls+0x280>
    80004fa0:	ffffb097          	auipc	ra,0xffffb
    80004fa4:	59e080e7          	jalr	1438(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fa8:	874a                	mv	a4,s2
    80004faa:	009c86bb          	addw	a3,s9,s1
    80004fae:	4581                	li	a1,0
    80004fb0:	8556                	mv	a0,s5
    80004fb2:	fffff097          	auipc	ra,0xfffff
    80004fb6:	c8c080e7          	jalr	-884(ra) # 80003c3e <readi>
    80004fba:	2501                	sext.w	a0,a0
    80004fbc:	1aa91f63          	bne	s2,a0,8000517a <exec+0x2e8>
  for(i = 0; i < sz; i += PGSIZE){
    80004fc0:	009d84bb          	addw	s1,s11,s1
    80004fc4:	013d09bb          	addw	s3,s10,s3
    80004fc8:	1f74fc63          	bgeu	s1,s7,800051c0 <exec+0x32e>
    pa = walkaddr(pagetable, va + i);
    80004fcc:	02049593          	slli	a1,s1,0x20
    80004fd0:	9181                	srli	a1,a1,0x20
    80004fd2:	95e2                	add	a1,a1,s8
    80004fd4:	855a                	mv	a0,s6
    80004fd6:	ffffc097          	auipc	ra,0xffffc
    80004fda:	086080e7          	jalr	134(ra) # 8000105c <walkaddr>
    80004fde:	862a                	mv	a2,a0
    if(pa == 0)
    80004fe0:	dd45                	beqz	a0,80004f98 <exec+0x106>
      n = PGSIZE;
    80004fe2:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004fe4:	fd49f2e3          	bgeu	s3,s4,80004fa8 <exec+0x116>
      n = sz - i;
    80004fe8:	894e                	mv	s2,s3
    80004fea:	bf7d                	j	80004fa8 <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fec:	4901                	li	s2,0
  iunlockput(ip);
    80004fee:	8556                	mv	a0,s5
    80004ff0:	fffff097          	auipc	ra,0xfffff
    80004ff4:	bfc080e7          	jalr	-1028(ra) # 80003bec <iunlockput>
  end_op();
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	3d4080e7          	jalr	980(ra) # 800043cc <end_op>
  p = myproc();
    80005000:	ffffd097          	auipc	ra,0xffffd
    80005004:	980080e7          	jalr	-1664(ra) # 80001980 <myproc>
    80005008:	8baa                	mv	s7,a0
  kt = mykthread();
    8000500a:	ffffd097          	auipc	ra,0xffffd
    8000500e:	734080e7          	jalr	1844(ra) # 8000273e <mykthread>
    80005012:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80005014:	0f8bbd83          	ld	s11,248(s7) # 10f8 <_entry-0x7fffef08>
  sz = PGROUNDUP(sz);
    80005018:	6785                	lui	a5,0x1
    8000501a:	17fd                	addi	a5,a5,-1
    8000501c:	993e                	add	s2,s2,a5
    8000501e:	77fd                	lui	a5,0xfffff
    80005020:	00f977b3          	and	a5,s2,a5
    80005024:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005028:	4691                	li	a3,4
    8000502a:	6609                	lui	a2,0x2
    8000502c:	963e                	add	a2,a2,a5
    8000502e:	85be                	mv	a1,a5
    80005030:	855a                	mv	a0,s6
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	3de080e7          	jalr	990(ra) # 80001410 <uvmalloc>
    8000503a:	8c2a                	mv	s8,a0
  ip = 0;
    8000503c:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000503e:	12050e63          	beqz	a0,8000517a <exec+0x2e8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005042:	75f9                	lui	a1,0xffffe
    80005044:	95aa                	add	a1,a1,a0
    80005046:	855a                	mv	a0,s6
    80005048:	ffffc097          	auipc	ra,0xffffc
    8000504c:	5ee080e7          	jalr	1518(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005050:	7afd                	lui	s5,0xfffff
    80005052:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005054:	df043783          	ld	a5,-528(s0)
    80005058:	6388                	ld	a0,0(a5)
    8000505a:	c925                	beqz	a0,800050ca <exec+0x238>
    8000505c:	e9040993          	addi	s3,s0,-368
    80005060:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005064:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005066:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005068:	ffffc097          	auipc	ra,0xffffc
    8000506c:	de6080e7          	jalr	-538(ra) # 80000e4e <strlen>
    80005070:	0015079b          	addiw	a5,a0,1
    80005074:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005078:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000507c:	13596663          	bltu	s2,s5,800051a8 <exec+0x316>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005080:	df043783          	ld	a5,-528(s0)
    80005084:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffdbc80>
    80005088:	8552                	mv	a0,s4
    8000508a:	ffffc097          	auipc	ra,0xffffc
    8000508e:	dc4080e7          	jalr	-572(ra) # 80000e4e <strlen>
    80005092:	0015069b          	addiw	a3,a0,1
    80005096:	8652                	mv	a2,s4
    80005098:	85ca                	mv	a1,s2
    8000509a:	855a                	mv	a0,s6
    8000509c:	ffffc097          	auipc	ra,0xffffc
    800050a0:	5cc080e7          	jalr	1484(ra) # 80001668 <copyout>
    800050a4:	10054663          	bltz	a0,800051b0 <exec+0x31e>
    ustack[argc] = sp;
    800050a8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050ac:	0485                	addi	s1,s1,1
    800050ae:	df043783          	ld	a5,-528(s0)
    800050b2:	07a1                	addi	a5,a5,8
    800050b4:	def43823          	sd	a5,-528(s0)
    800050b8:	6388                	ld	a0,0(a5)
    800050ba:	c911                	beqz	a0,800050ce <exec+0x23c>
    if(argc >= MAXARG)
    800050bc:	09a1                	addi	s3,s3,8
    800050be:	fb3c95e3          	bne	s9,s3,80005068 <exec+0x1d6>
  sz = sz1;
    800050c2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050c6:	4a81                	li	s5,0
    800050c8:	a84d                	j	8000517a <exec+0x2e8>
  sp = sz;
    800050ca:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050cc:	4481                	li	s1,0
  ustack[argc] = 0;
    800050ce:	00349793          	slli	a5,s1,0x3
    800050d2:	f9040713          	addi	a4,s0,-112
    800050d6:	97ba                	add	a5,a5,a4
    800050d8:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800050dc:	00148693          	addi	a3,s1,1
    800050e0:	068e                	slli	a3,a3,0x3
    800050e2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050e6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050ea:	01597663          	bgeu	s2,s5,800050f6 <exec+0x264>
  sz = sz1;
    800050ee:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050f2:	4a81                	li	s5,0
    800050f4:	a059                	j	8000517a <exec+0x2e8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050f6:	e9040613          	addi	a2,s0,-368
    800050fa:	85ca                	mv	a1,s2
    800050fc:	855a                	mv	a0,s6
    800050fe:	ffffc097          	auipc	ra,0xffffc
    80005102:	56a080e7          	jalr	1386(ra) # 80001668 <copyout>
    80005106:	0a054963          	bltz	a0,800051b8 <exec+0x326>
  kt->trapframe->a1 = sp;
    8000510a:	0b8d3783          	ld	a5,184(s10) # fffffffffffff0b8 <end+0xffffffff7ffdbd38>
    8000510e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005112:	de843783          	ld	a5,-536(s0)
    80005116:	0007c703          	lbu	a4,0(a5)
    8000511a:	cf11                	beqz	a4,80005136 <exec+0x2a4>
    8000511c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000511e:	02f00693          	li	a3,47
    80005122:	a039                	j	80005130 <exec+0x29e>
      last = s+1;
    80005124:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005128:	0785                	addi	a5,a5,1
    8000512a:	fff7c703          	lbu	a4,-1(a5)
    8000512e:	c701                	beqz	a4,80005136 <exec+0x2a4>
    if(*s == '/')
    80005130:	fed71ce3          	bne	a4,a3,80005128 <exec+0x296>
    80005134:	bfc5                	j	80005124 <exec+0x292>
  safestrcpy(p->name, last, sizeof(p->name));
    80005136:	4641                	li	a2,16
    80005138:	de843583          	ld	a1,-536(s0)
    8000513c:	190b8513          	addi	a0,s7,400
    80005140:	ffffc097          	auipc	ra,0xffffc
    80005144:	cdc080e7          	jalr	-804(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005148:	100bb503          	ld	a0,256(s7)
  p->pagetable = pagetable;
    8000514c:	116bb023          	sd	s6,256(s7)
  p->sz = sz;
    80005150:	0f8bbc23          	sd	s8,248(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    80005154:	0b8d3783          	ld	a5,184(s10)
    80005158:	e6843703          	ld	a4,-408(s0)
    8000515c:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    8000515e:	0b8d3783          	ld	a5,184(s10)
    80005162:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005166:	85ee                	mv	a1,s11
    80005168:	ffffd097          	auipc	ra,0xffffd
    8000516c:	950080e7          	jalr	-1712(ra) # 80001ab8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005170:	0004851b          	sext.w	a0,s1
    80005174:	b3c9                	j	80004f36 <exec+0xa4>
    80005176:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000517a:	df843583          	ld	a1,-520(s0)
    8000517e:	855a                	mv	a0,s6
    80005180:	ffffd097          	auipc	ra,0xffffd
    80005184:	938080e7          	jalr	-1736(ra) # 80001ab8 <proc_freepagetable>
  if(ip){
    80005188:	d80a9de3          	bnez	s5,80004f22 <exec+0x90>
  return -1;
    8000518c:	557d                	li	a0,-1
    8000518e:	b365                	j	80004f36 <exec+0xa4>
    80005190:	df243c23          	sd	s2,-520(s0)
    80005194:	b7dd                	j	8000517a <exec+0x2e8>
    80005196:	df243c23          	sd	s2,-520(s0)
    8000519a:	b7c5                	j	8000517a <exec+0x2e8>
    8000519c:	df243c23          	sd	s2,-520(s0)
    800051a0:	bfe9                	j	8000517a <exec+0x2e8>
    800051a2:	df243c23          	sd	s2,-520(s0)
    800051a6:	bfd1                	j	8000517a <exec+0x2e8>
  sz = sz1;
    800051a8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051ac:	4a81                	li	s5,0
    800051ae:	b7f1                	j	8000517a <exec+0x2e8>
  sz = sz1;
    800051b0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051b4:	4a81                	li	s5,0
    800051b6:	b7d1                	j	8000517a <exec+0x2e8>
  sz = sz1;
    800051b8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051bc:	4a81                	li	s5,0
    800051be:	bf75                	j	8000517a <exec+0x2e8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051c0:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051c4:	e0843783          	ld	a5,-504(s0)
    800051c8:	0017869b          	addiw	a3,a5,1
    800051cc:	e0d43423          	sd	a3,-504(s0)
    800051d0:	e0043783          	ld	a5,-512(s0)
    800051d4:	0387879b          	addiw	a5,a5,56
    800051d8:	e8845703          	lhu	a4,-376(s0)
    800051dc:	e0e6d9e3          	bge	a3,a4,80004fee <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051e0:	2781                	sext.w	a5,a5
    800051e2:	e0f43023          	sd	a5,-512(s0)
    800051e6:	03800713          	li	a4,56
    800051ea:	86be                	mv	a3,a5
    800051ec:	e1840613          	addi	a2,s0,-488
    800051f0:	4581                	li	a1,0
    800051f2:	8556                	mv	a0,s5
    800051f4:	fffff097          	auipc	ra,0xfffff
    800051f8:	a4a080e7          	jalr	-1462(ra) # 80003c3e <readi>
    800051fc:	03800793          	li	a5,56
    80005200:	f6f51be3          	bne	a0,a5,80005176 <exec+0x2e4>
    if(ph.type != ELF_PROG_LOAD)
    80005204:	e1842783          	lw	a5,-488(s0)
    80005208:	4705                	li	a4,1
    8000520a:	fae79de3          	bne	a5,a4,800051c4 <exec+0x332>
    if(ph.memsz < ph.filesz)
    8000520e:	e4043483          	ld	s1,-448(s0)
    80005212:	e3843783          	ld	a5,-456(s0)
    80005216:	f6f4ede3          	bltu	s1,a5,80005190 <exec+0x2fe>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000521a:	e2843783          	ld	a5,-472(s0)
    8000521e:	94be                	add	s1,s1,a5
    80005220:	f6f4ebe3          	bltu	s1,a5,80005196 <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    80005224:	de043703          	ld	a4,-544(s0)
    80005228:	8ff9                	and	a5,a5,a4
    8000522a:	fbad                	bnez	a5,8000519c <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000522c:	e1c42503          	lw	a0,-484(s0)
    80005230:	00000097          	auipc	ra,0x0
    80005234:	c46080e7          	jalr	-954(ra) # 80004e76 <flags2perm>
    80005238:	86aa                	mv	a3,a0
    8000523a:	8626                	mv	a2,s1
    8000523c:	85ca                	mv	a1,s2
    8000523e:	855a                	mv	a0,s6
    80005240:	ffffc097          	auipc	ra,0xffffc
    80005244:	1d0080e7          	jalr	464(ra) # 80001410 <uvmalloc>
    80005248:	dea43c23          	sd	a0,-520(s0)
    8000524c:	d939                	beqz	a0,800051a2 <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000524e:	e2843c03          	ld	s8,-472(s0)
    80005252:	e2042c83          	lw	s9,-480(s0)
    80005256:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000525a:	f60b83e3          	beqz	s7,800051c0 <exec+0x32e>
    8000525e:	89de                	mv	s3,s7
    80005260:	4481                	li	s1,0
    80005262:	b3ad                	j	80004fcc <exec+0x13a>

0000000080005264 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005264:	7179                	addi	sp,sp,-48
    80005266:	f406                	sd	ra,40(sp)
    80005268:	f022                	sd	s0,32(sp)
    8000526a:	ec26                	sd	s1,24(sp)
    8000526c:	e84a                	sd	s2,16(sp)
    8000526e:	1800                	addi	s0,sp,48
    80005270:	892e                	mv	s2,a1
    80005272:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005274:	fdc40593          	addi	a1,s0,-36
    80005278:	ffffe097          	auipc	ra,0xffffe
    8000527c:	b96080e7          	jalr	-1130(ra) # 80002e0e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005280:	fdc42703          	lw	a4,-36(s0)
    80005284:	47bd                	li	a5,15
    80005286:	02e7eb63          	bltu	a5,a4,800052bc <argfd+0x58>
    8000528a:	ffffc097          	auipc	ra,0xffffc
    8000528e:	6f6080e7          	jalr	1782(ra) # 80001980 <myproc>
    80005292:	fdc42703          	lw	a4,-36(s0)
    80005296:	02070793          	addi	a5,a4,32
    8000529a:	078e                	slli	a5,a5,0x3
    8000529c:	953e                	add	a0,a0,a5
    8000529e:	651c                	ld	a5,8(a0)
    800052a0:	c385                	beqz	a5,800052c0 <argfd+0x5c>
    return -1;
  if(pfd)
    800052a2:	00090463          	beqz	s2,800052aa <argfd+0x46>
    *pfd = fd;
    800052a6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052aa:	4501                	li	a0,0
  if(pf)
    800052ac:	c091                	beqz	s1,800052b0 <argfd+0x4c>
    *pf = f;
    800052ae:	e09c                	sd	a5,0(s1)
}
    800052b0:	70a2                	ld	ra,40(sp)
    800052b2:	7402                	ld	s0,32(sp)
    800052b4:	64e2                	ld	s1,24(sp)
    800052b6:	6942                	ld	s2,16(sp)
    800052b8:	6145                	addi	sp,sp,48
    800052ba:	8082                	ret
    return -1;
    800052bc:	557d                	li	a0,-1
    800052be:	bfcd                	j	800052b0 <argfd+0x4c>
    800052c0:	557d                	li	a0,-1
    800052c2:	b7fd                	j	800052b0 <argfd+0x4c>

00000000800052c4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052c4:	1101                	addi	sp,sp,-32
    800052c6:	ec06                	sd	ra,24(sp)
    800052c8:	e822                	sd	s0,16(sp)
    800052ca:	e426                	sd	s1,8(sp)
    800052cc:	1000                	addi	s0,sp,32
    800052ce:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052d0:	ffffc097          	auipc	ra,0xffffc
    800052d4:	6b0080e7          	jalr	1712(ra) # 80001980 <myproc>
    800052d8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052da:	10850793          	addi	a5,a0,264
    800052de:	4501                	li	a0,0
    800052e0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052e2:	6398                	ld	a4,0(a5)
    800052e4:	cb19                	beqz	a4,800052fa <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052e6:	2505                	addiw	a0,a0,1
    800052e8:	07a1                	addi	a5,a5,8
    800052ea:	fed51ce3          	bne	a0,a3,800052e2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052ee:	557d                	li	a0,-1
}
    800052f0:	60e2                	ld	ra,24(sp)
    800052f2:	6442                	ld	s0,16(sp)
    800052f4:	64a2                	ld	s1,8(sp)
    800052f6:	6105                	addi	sp,sp,32
    800052f8:	8082                	ret
      p->ofile[fd] = f;
    800052fa:	02050793          	addi	a5,a0,32
    800052fe:	078e                	slli	a5,a5,0x3
    80005300:	963e                	add	a2,a2,a5
    80005302:	e604                	sd	s1,8(a2)
      return fd;
    80005304:	b7f5                	j	800052f0 <fdalloc+0x2c>

0000000080005306 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005306:	715d                	addi	sp,sp,-80
    80005308:	e486                	sd	ra,72(sp)
    8000530a:	e0a2                	sd	s0,64(sp)
    8000530c:	fc26                	sd	s1,56(sp)
    8000530e:	f84a                	sd	s2,48(sp)
    80005310:	f44e                	sd	s3,40(sp)
    80005312:	f052                	sd	s4,32(sp)
    80005314:	ec56                	sd	s5,24(sp)
    80005316:	e85a                	sd	s6,16(sp)
    80005318:	0880                	addi	s0,sp,80
    8000531a:	8b2e                	mv	s6,a1
    8000531c:	89b2                	mv	s3,a2
    8000531e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005320:	fb040593          	addi	a1,s0,-80
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	e2a080e7          	jalr	-470(ra) # 8000414e <nameiparent>
    8000532c:	84aa                	mv	s1,a0
    8000532e:	14050f63          	beqz	a0,8000548c <create+0x186>
    return 0;

  ilock(dp);
    80005332:	ffffe097          	auipc	ra,0xffffe
    80005336:	658080e7          	jalr	1624(ra) # 8000398a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000533a:	4601                	li	a2,0
    8000533c:	fb040593          	addi	a1,s0,-80
    80005340:	8526                	mv	a0,s1
    80005342:	fffff097          	auipc	ra,0xfffff
    80005346:	b2c080e7          	jalr	-1236(ra) # 80003e6e <dirlookup>
    8000534a:	8aaa                	mv	s5,a0
    8000534c:	c931                	beqz	a0,800053a0 <create+0x9a>
    iunlockput(dp);
    8000534e:	8526                	mv	a0,s1
    80005350:	fffff097          	auipc	ra,0xfffff
    80005354:	89c080e7          	jalr	-1892(ra) # 80003bec <iunlockput>
    ilock(ip);
    80005358:	8556                	mv	a0,s5
    8000535a:	ffffe097          	auipc	ra,0xffffe
    8000535e:	630080e7          	jalr	1584(ra) # 8000398a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005362:	000b059b          	sext.w	a1,s6
    80005366:	4789                	li	a5,2
    80005368:	02f59563          	bne	a1,a5,80005392 <create+0x8c>
    8000536c:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbcc4>
    80005370:	37f9                	addiw	a5,a5,-2
    80005372:	17c2                	slli	a5,a5,0x30
    80005374:	93c1                	srli	a5,a5,0x30
    80005376:	4705                	li	a4,1
    80005378:	00f76d63          	bltu	a4,a5,80005392 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000537c:	8556                	mv	a0,s5
    8000537e:	60a6                	ld	ra,72(sp)
    80005380:	6406                	ld	s0,64(sp)
    80005382:	74e2                	ld	s1,56(sp)
    80005384:	7942                	ld	s2,48(sp)
    80005386:	79a2                	ld	s3,40(sp)
    80005388:	7a02                	ld	s4,32(sp)
    8000538a:	6ae2                	ld	s5,24(sp)
    8000538c:	6b42                	ld	s6,16(sp)
    8000538e:	6161                	addi	sp,sp,80
    80005390:	8082                	ret
    iunlockput(ip);
    80005392:	8556                	mv	a0,s5
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	858080e7          	jalr	-1960(ra) # 80003bec <iunlockput>
    return 0;
    8000539c:	4a81                	li	s5,0
    8000539e:	bff9                	j	8000537c <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800053a0:	85da                	mv	a1,s6
    800053a2:	4088                	lw	a0,0(s1)
    800053a4:	ffffe097          	auipc	ra,0xffffe
    800053a8:	44a080e7          	jalr	1098(ra) # 800037ee <ialloc>
    800053ac:	8a2a                	mv	s4,a0
    800053ae:	c539                	beqz	a0,800053fc <create+0xf6>
  ilock(ip);
    800053b0:	ffffe097          	auipc	ra,0xffffe
    800053b4:	5da080e7          	jalr	1498(ra) # 8000398a <ilock>
  ip->major = major;
    800053b8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053bc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053c0:	4905                	li	s2,1
    800053c2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053c6:	8552                	mv	a0,s4
    800053c8:	ffffe097          	auipc	ra,0xffffe
    800053cc:	4f8080e7          	jalr	1272(ra) # 800038c0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053d0:	000b059b          	sext.w	a1,s6
    800053d4:	03258b63          	beq	a1,s2,8000540a <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800053d8:	004a2603          	lw	a2,4(s4)
    800053dc:	fb040593          	addi	a1,s0,-80
    800053e0:	8526                	mv	a0,s1
    800053e2:	fffff097          	auipc	ra,0xfffff
    800053e6:	c9c080e7          	jalr	-868(ra) # 8000407e <dirlink>
    800053ea:	06054f63          	bltz	a0,80005468 <create+0x162>
  iunlockput(dp);
    800053ee:	8526                	mv	a0,s1
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	7fc080e7          	jalr	2044(ra) # 80003bec <iunlockput>
  return ip;
    800053f8:	8ad2                	mv	s5,s4
    800053fa:	b749                	j	8000537c <create+0x76>
    iunlockput(dp);
    800053fc:	8526                	mv	a0,s1
    800053fe:	ffffe097          	auipc	ra,0xffffe
    80005402:	7ee080e7          	jalr	2030(ra) # 80003bec <iunlockput>
    return 0;
    80005406:	8ad2                	mv	s5,s4
    80005408:	bf95                	j	8000537c <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000540a:	004a2603          	lw	a2,4(s4)
    8000540e:	00003597          	auipc	a1,0x3
    80005412:	30258593          	addi	a1,a1,770 # 80008710 <syscalls+0x2a0>
    80005416:	8552                	mv	a0,s4
    80005418:	fffff097          	auipc	ra,0xfffff
    8000541c:	c66080e7          	jalr	-922(ra) # 8000407e <dirlink>
    80005420:	04054463          	bltz	a0,80005468 <create+0x162>
    80005424:	40d0                	lw	a2,4(s1)
    80005426:	00003597          	auipc	a1,0x3
    8000542a:	2f258593          	addi	a1,a1,754 # 80008718 <syscalls+0x2a8>
    8000542e:	8552                	mv	a0,s4
    80005430:	fffff097          	auipc	ra,0xfffff
    80005434:	c4e080e7          	jalr	-946(ra) # 8000407e <dirlink>
    80005438:	02054863          	bltz	a0,80005468 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000543c:	004a2603          	lw	a2,4(s4)
    80005440:	fb040593          	addi	a1,s0,-80
    80005444:	8526                	mv	a0,s1
    80005446:	fffff097          	auipc	ra,0xfffff
    8000544a:	c38080e7          	jalr	-968(ra) # 8000407e <dirlink>
    8000544e:	00054d63          	bltz	a0,80005468 <create+0x162>
    dp->nlink++;  // for ".."
    80005452:	04a4d783          	lhu	a5,74(s1)
    80005456:	2785                	addiw	a5,a5,1
    80005458:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000545c:	8526                	mv	a0,s1
    8000545e:	ffffe097          	auipc	ra,0xffffe
    80005462:	462080e7          	jalr	1122(ra) # 800038c0 <iupdate>
    80005466:	b761                	j	800053ee <create+0xe8>
  ip->nlink = 0;
    80005468:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000546c:	8552                	mv	a0,s4
    8000546e:	ffffe097          	auipc	ra,0xffffe
    80005472:	452080e7          	jalr	1106(ra) # 800038c0 <iupdate>
  iunlockput(ip);
    80005476:	8552                	mv	a0,s4
    80005478:	ffffe097          	auipc	ra,0xffffe
    8000547c:	774080e7          	jalr	1908(ra) # 80003bec <iunlockput>
  iunlockput(dp);
    80005480:	8526                	mv	a0,s1
    80005482:	ffffe097          	auipc	ra,0xffffe
    80005486:	76a080e7          	jalr	1898(ra) # 80003bec <iunlockput>
  return 0;
    8000548a:	bdcd                	j	8000537c <create+0x76>
    return 0;
    8000548c:	8aaa                	mv	s5,a0
    8000548e:	b5fd                	j	8000537c <create+0x76>

0000000080005490 <sys_dup>:
{
    80005490:	7179                	addi	sp,sp,-48
    80005492:	f406                	sd	ra,40(sp)
    80005494:	f022                	sd	s0,32(sp)
    80005496:	ec26                	sd	s1,24(sp)
    80005498:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000549a:	fd840613          	addi	a2,s0,-40
    8000549e:	4581                	li	a1,0
    800054a0:	4501                	li	a0,0
    800054a2:	00000097          	auipc	ra,0x0
    800054a6:	dc2080e7          	jalr	-574(ra) # 80005264 <argfd>
    return -1;
    800054aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054ac:	02054363          	bltz	a0,800054d2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800054b0:	fd843503          	ld	a0,-40(s0)
    800054b4:	00000097          	auipc	ra,0x0
    800054b8:	e10080e7          	jalr	-496(ra) # 800052c4 <fdalloc>
    800054bc:	84aa                	mv	s1,a0
    return -1;
    800054be:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054c0:	00054963          	bltz	a0,800054d2 <sys_dup+0x42>
  filedup(f);
    800054c4:	fd843503          	ld	a0,-40(s0)
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	2fe080e7          	jalr	766(ra) # 800047c6 <filedup>
  return fd;
    800054d0:	87a6                	mv	a5,s1
}
    800054d2:	853e                	mv	a0,a5
    800054d4:	70a2                	ld	ra,40(sp)
    800054d6:	7402                	ld	s0,32(sp)
    800054d8:	64e2                	ld	s1,24(sp)
    800054da:	6145                	addi	sp,sp,48
    800054dc:	8082                	ret

00000000800054de <sys_read>:
{
    800054de:	7179                	addi	sp,sp,-48
    800054e0:	f406                	sd	ra,40(sp)
    800054e2:	f022                	sd	s0,32(sp)
    800054e4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054e6:	fd840593          	addi	a1,s0,-40
    800054ea:	4505                	li	a0,1
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	942080e7          	jalr	-1726(ra) # 80002e2e <argaddr>
  argint(2, &n);
    800054f4:	fe440593          	addi	a1,s0,-28
    800054f8:	4509                	li	a0,2
    800054fa:	ffffe097          	auipc	ra,0xffffe
    800054fe:	914080e7          	jalr	-1772(ra) # 80002e0e <argint>
  if(argfd(0, 0, &f) < 0)
    80005502:	fe840613          	addi	a2,s0,-24
    80005506:	4581                	li	a1,0
    80005508:	4501                	li	a0,0
    8000550a:	00000097          	auipc	ra,0x0
    8000550e:	d5a080e7          	jalr	-678(ra) # 80005264 <argfd>
    80005512:	87aa                	mv	a5,a0
    return -1;
    80005514:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005516:	0007cc63          	bltz	a5,8000552e <sys_read+0x50>
  return fileread(f, p, n);
    8000551a:	fe442603          	lw	a2,-28(s0)
    8000551e:	fd843583          	ld	a1,-40(s0)
    80005522:	fe843503          	ld	a0,-24(s0)
    80005526:	fffff097          	auipc	ra,0xfffff
    8000552a:	42c080e7          	jalr	1068(ra) # 80004952 <fileread>
}
    8000552e:	70a2                	ld	ra,40(sp)
    80005530:	7402                	ld	s0,32(sp)
    80005532:	6145                	addi	sp,sp,48
    80005534:	8082                	ret

0000000080005536 <sys_write>:
{
    80005536:	7179                	addi	sp,sp,-48
    80005538:	f406                	sd	ra,40(sp)
    8000553a:	f022                	sd	s0,32(sp)
    8000553c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000553e:	fd840593          	addi	a1,s0,-40
    80005542:	4505                	li	a0,1
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	8ea080e7          	jalr	-1814(ra) # 80002e2e <argaddr>
  argint(2, &n);
    8000554c:	fe440593          	addi	a1,s0,-28
    80005550:	4509                	li	a0,2
    80005552:	ffffe097          	auipc	ra,0xffffe
    80005556:	8bc080e7          	jalr	-1860(ra) # 80002e0e <argint>
  if(argfd(0, 0, &f) < 0)
    8000555a:	fe840613          	addi	a2,s0,-24
    8000555e:	4581                	li	a1,0
    80005560:	4501                	li	a0,0
    80005562:	00000097          	auipc	ra,0x0
    80005566:	d02080e7          	jalr	-766(ra) # 80005264 <argfd>
    8000556a:	87aa                	mv	a5,a0
    return -1;
    8000556c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000556e:	0007cc63          	bltz	a5,80005586 <sys_write+0x50>
  return filewrite(f, p, n);
    80005572:	fe442603          	lw	a2,-28(s0)
    80005576:	fd843583          	ld	a1,-40(s0)
    8000557a:	fe843503          	ld	a0,-24(s0)
    8000557e:	fffff097          	auipc	ra,0xfffff
    80005582:	496080e7          	jalr	1174(ra) # 80004a14 <filewrite>
}
    80005586:	70a2                	ld	ra,40(sp)
    80005588:	7402                	ld	s0,32(sp)
    8000558a:	6145                	addi	sp,sp,48
    8000558c:	8082                	ret

000000008000558e <sys_close>:
{
    8000558e:	1101                	addi	sp,sp,-32
    80005590:	ec06                	sd	ra,24(sp)
    80005592:	e822                	sd	s0,16(sp)
    80005594:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005596:	fe040613          	addi	a2,s0,-32
    8000559a:	fec40593          	addi	a1,s0,-20
    8000559e:	4501                	li	a0,0
    800055a0:	00000097          	auipc	ra,0x0
    800055a4:	cc4080e7          	jalr	-828(ra) # 80005264 <argfd>
    return -1;
    800055a8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055aa:	02054563          	bltz	a0,800055d4 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    800055ae:	ffffc097          	auipc	ra,0xffffc
    800055b2:	3d2080e7          	jalr	978(ra) # 80001980 <myproc>
    800055b6:	fec42783          	lw	a5,-20(s0)
    800055ba:	02078793          	addi	a5,a5,32
    800055be:	078e                	slli	a5,a5,0x3
    800055c0:	97aa                	add	a5,a5,a0
    800055c2:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800055c6:	fe043503          	ld	a0,-32(s0)
    800055ca:	fffff097          	auipc	ra,0xfffff
    800055ce:	24e080e7          	jalr	590(ra) # 80004818 <fileclose>
  return 0;
    800055d2:	4781                	li	a5,0
}
    800055d4:	853e                	mv	a0,a5
    800055d6:	60e2                	ld	ra,24(sp)
    800055d8:	6442                	ld	s0,16(sp)
    800055da:	6105                	addi	sp,sp,32
    800055dc:	8082                	ret

00000000800055de <sys_fstat>:
{
    800055de:	1101                	addi	sp,sp,-32
    800055e0:	ec06                	sd	ra,24(sp)
    800055e2:	e822                	sd	s0,16(sp)
    800055e4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800055e6:	fe040593          	addi	a1,s0,-32
    800055ea:	4505                	li	a0,1
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	842080e7          	jalr	-1982(ra) # 80002e2e <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055f4:	fe840613          	addi	a2,s0,-24
    800055f8:	4581                	li	a1,0
    800055fa:	4501                	li	a0,0
    800055fc:	00000097          	auipc	ra,0x0
    80005600:	c68080e7          	jalr	-920(ra) # 80005264 <argfd>
    80005604:	87aa                	mv	a5,a0
    return -1;
    80005606:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005608:	0007ca63          	bltz	a5,8000561c <sys_fstat+0x3e>
  return filestat(f, st);
    8000560c:	fe043583          	ld	a1,-32(s0)
    80005610:	fe843503          	ld	a0,-24(s0)
    80005614:	fffff097          	auipc	ra,0xfffff
    80005618:	2cc080e7          	jalr	716(ra) # 800048e0 <filestat>
}
    8000561c:	60e2                	ld	ra,24(sp)
    8000561e:	6442                	ld	s0,16(sp)
    80005620:	6105                	addi	sp,sp,32
    80005622:	8082                	ret

0000000080005624 <sys_link>:
{
    80005624:	7169                	addi	sp,sp,-304
    80005626:	f606                	sd	ra,296(sp)
    80005628:	f222                	sd	s0,288(sp)
    8000562a:	ee26                	sd	s1,280(sp)
    8000562c:	ea4a                	sd	s2,272(sp)
    8000562e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005630:	08000613          	li	a2,128
    80005634:	ed040593          	addi	a1,s0,-304
    80005638:	4501                	li	a0,0
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	814080e7          	jalr	-2028(ra) # 80002e4e <argstr>
    return -1;
    80005642:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005644:	10054e63          	bltz	a0,80005760 <sys_link+0x13c>
    80005648:	08000613          	li	a2,128
    8000564c:	f5040593          	addi	a1,s0,-176
    80005650:	4505                	li	a0,1
    80005652:	ffffd097          	auipc	ra,0xffffd
    80005656:	7fc080e7          	jalr	2044(ra) # 80002e4e <argstr>
    return -1;
    8000565a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000565c:	10054263          	bltz	a0,80005760 <sys_link+0x13c>
  begin_op();
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	cec080e7          	jalr	-788(ra) # 8000434c <begin_op>
  if((ip = namei(old)) == 0){
    80005668:	ed040513          	addi	a0,s0,-304
    8000566c:	fffff097          	auipc	ra,0xfffff
    80005670:	ac4080e7          	jalr	-1340(ra) # 80004130 <namei>
    80005674:	84aa                	mv	s1,a0
    80005676:	c551                	beqz	a0,80005702 <sys_link+0xde>
  ilock(ip);
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	312080e7          	jalr	786(ra) # 8000398a <ilock>
  if(ip->type == T_DIR){
    80005680:	04449703          	lh	a4,68(s1)
    80005684:	4785                	li	a5,1
    80005686:	08f70463          	beq	a4,a5,8000570e <sys_link+0xea>
  ip->nlink++;
    8000568a:	04a4d783          	lhu	a5,74(s1)
    8000568e:	2785                	addiw	a5,a5,1
    80005690:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005694:	8526                	mv	a0,s1
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	22a080e7          	jalr	554(ra) # 800038c0 <iupdate>
  iunlock(ip);
    8000569e:	8526                	mv	a0,s1
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	3ac080e7          	jalr	940(ra) # 80003a4c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056a8:	fd040593          	addi	a1,s0,-48
    800056ac:	f5040513          	addi	a0,s0,-176
    800056b0:	fffff097          	auipc	ra,0xfffff
    800056b4:	a9e080e7          	jalr	-1378(ra) # 8000414e <nameiparent>
    800056b8:	892a                	mv	s2,a0
    800056ba:	c935                	beqz	a0,8000572e <sys_link+0x10a>
  ilock(dp);
    800056bc:	ffffe097          	auipc	ra,0xffffe
    800056c0:	2ce080e7          	jalr	718(ra) # 8000398a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056c4:	00092703          	lw	a4,0(s2)
    800056c8:	409c                	lw	a5,0(s1)
    800056ca:	04f71d63          	bne	a4,a5,80005724 <sys_link+0x100>
    800056ce:	40d0                	lw	a2,4(s1)
    800056d0:	fd040593          	addi	a1,s0,-48
    800056d4:	854a                	mv	a0,s2
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	9a8080e7          	jalr	-1624(ra) # 8000407e <dirlink>
    800056de:	04054363          	bltz	a0,80005724 <sys_link+0x100>
  iunlockput(dp);
    800056e2:	854a                	mv	a0,s2
    800056e4:	ffffe097          	auipc	ra,0xffffe
    800056e8:	508080e7          	jalr	1288(ra) # 80003bec <iunlockput>
  iput(ip);
    800056ec:	8526                	mv	a0,s1
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	456080e7          	jalr	1110(ra) # 80003b44 <iput>
  end_op();
    800056f6:	fffff097          	auipc	ra,0xfffff
    800056fa:	cd6080e7          	jalr	-810(ra) # 800043cc <end_op>
  return 0;
    800056fe:	4781                	li	a5,0
    80005700:	a085                	j	80005760 <sys_link+0x13c>
    end_op();
    80005702:	fffff097          	auipc	ra,0xfffff
    80005706:	cca080e7          	jalr	-822(ra) # 800043cc <end_op>
    return -1;
    8000570a:	57fd                	li	a5,-1
    8000570c:	a891                	j	80005760 <sys_link+0x13c>
    iunlockput(ip);
    8000570e:	8526                	mv	a0,s1
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	4dc080e7          	jalr	1244(ra) # 80003bec <iunlockput>
    end_op();
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	cb4080e7          	jalr	-844(ra) # 800043cc <end_op>
    return -1;
    80005720:	57fd                	li	a5,-1
    80005722:	a83d                	j	80005760 <sys_link+0x13c>
    iunlockput(dp);
    80005724:	854a                	mv	a0,s2
    80005726:	ffffe097          	auipc	ra,0xffffe
    8000572a:	4c6080e7          	jalr	1222(ra) # 80003bec <iunlockput>
  ilock(ip);
    8000572e:	8526                	mv	a0,s1
    80005730:	ffffe097          	auipc	ra,0xffffe
    80005734:	25a080e7          	jalr	602(ra) # 8000398a <ilock>
  ip->nlink--;
    80005738:	04a4d783          	lhu	a5,74(s1)
    8000573c:	37fd                	addiw	a5,a5,-1
    8000573e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005742:	8526                	mv	a0,s1
    80005744:	ffffe097          	auipc	ra,0xffffe
    80005748:	17c080e7          	jalr	380(ra) # 800038c0 <iupdate>
  iunlockput(ip);
    8000574c:	8526                	mv	a0,s1
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	49e080e7          	jalr	1182(ra) # 80003bec <iunlockput>
  end_op();
    80005756:	fffff097          	auipc	ra,0xfffff
    8000575a:	c76080e7          	jalr	-906(ra) # 800043cc <end_op>
  return -1;
    8000575e:	57fd                	li	a5,-1
}
    80005760:	853e                	mv	a0,a5
    80005762:	70b2                	ld	ra,296(sp)
    80005764:	7412                	ld	s0,288(sp)
    80005766:	64f2                	ld	s1,280(sp)
    80005768:	6952                	ld	s2,272(sp)
    8000576a:	6155                	addi	sp,sp,304
    8000576c:	8082                	ret

000000008000576e <sys_unlink>:
{
    8000576e:	7151                	addi	sp,sp,-240
    80005770:	f586                	sd	ra,232(sp)
    80005772:	f1a2                	sd	s0,224(sp)
    80005774:	eda6                	sd	s1,216(sp)
    80005776:	e9ca                	sd	s2,208(sp)
    80005778:	e5ce                	sd	s3,200(sp)
    8000577a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000577c:	08000613          	li	a2,128
    80005780:	f3040593          	addi	a1,s0,-208
    80005784:	4501                	li	a0,0
    80005786:	ffffd097          	auipc	ra,0xffffd
    8000578a:	6c8080e7          	jalr	1736(ra) # 80002e4e <argstr>
    8000578e:	18054163          	bltz	a0,80005910 <sys_unlink+0x1a2>
  begin_op();
    80005792:	fffff097          	auipc	ra,0xfffff
    80005796:	bba080e7          	jalr	-1094(ra) # 8000434c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000579a:	fb040593          	addi	a1,s0,-80
    8000579e:	f3040513          	addi	a0,s0,-208
    800057a2:	fffff097          	auipc	ra,0xfffff
    800057a6:	9ac080e7          	jalr	-1620(ra) # 8000414e <nameiparent>
    800057aa:	84aa                	mv	s1,a0
    800057ac:	c979                	beqz	a0,80005882 <sys_unlink+0x114>
  ilock(dp);
    800057ae:	ffffe097          	auipc	ra,0xffffe
    800057b2:	1dc080e7          	jalr	476(ra) # 8000398a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057b6:	00003597          	auipc	a1,0x3
    800057ba:	f5a58593          	addi	a1,a1,-166 # 80008710 <syscalls+0x2a0>
    800057be:	fb040513          	addi	a0,s0,-80
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	692080e7          	jalr	1682(ra) # 80003e54 <namecmp>
    800057ca:	14050a63          	beqz	a0,8000591e <sys_unlink+0x1b0>
    800057ce:	00003597          	auipc	a1,0x3
    800057d2:	f4a58593          	addi	a1,a1,-182 # 80008718 <syscalls+0x2a8>
    800057d6:	fb040513          	addi	a0,s0,-80
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	67a080e7          	jalr	1658(ra) # 80003e54 <namecmp>
    800057e2:	12050e63          	beqz	a0,8000591e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057e6:	f2c40613          	addi	a2,s0,-212
    800057ea:	fb040593          	addi	a1,s0,-80
    800057ee:	8526                	mv	a0,s1
    800057f0:	ffffe097          	auipc	ra,0xffffe
    800057f4:	67e080e7          	jalr	1662(ra) # 80003e6e <dirlookup>
    800057f8:	892a                	mv	s2,a0
    800057fa:	12050263          	beqz	a0,8000591e <sys_unlink+0x1b0>
  ilock(ip);
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	18c080e7          	jalr	396(ra) # 8000398a <ilock>
  if(ip->nlink < 1)
    80005806:	04a91783          	lh	a5,74(s2)
    8000580a:	08f05263          	blez	a5,8000588e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000580e:	04491703          	lh	a4,68(s2)
    80005812:	4785                	li	a5,1
    80005814:	08f70563          	beq	a4,a5,8000589e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005818:	4641                	li	a2,16
    8000581a:	4581                	li	a1,0
    8000581c:	fc040513          	addi	a0,s0,-64
    80005820:	ffffb097          	auipc	ra,0xffffb
    80005824:	4b2080e7          	jalr	1202(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005828:	4741                	li	a4,16
    8000582a:	f2c42683          	lw	a3,-212(s0)
    8000582e:	fc040613          	addi	a2,s0,-64
    80005832:	4581                	li	a1,0
    80005834:	8526                	mv	a0,s1
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	500080e7          	jalr	1280(ra) # 80003d36 <writei>
    8000583e:	47c1                	li	a5,16
    80005840:	0af51563          	bne	a0,a5,800058ea <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005844:	04491703          	lh	a4,68(s2)
    80005848:	4785                	li	a5,1
    8000584a:	0af70863          	beq	a4,a5,800058fa <sys_unlink+0x18c>
  iunlockput(dp);
    8000584e:	8526                	mv	a0,s1
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	39c080e7          	jalr	924(ra) # 80003bec <iunlockput>
  ip->nlink--;
    80005858:	04a95783          	lhu	a5,74(s2)
    8000585c:	37fd                	addiw	a5,a5,-1
    8000585e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005862:	854a                	mv	a0,s2
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	05c080e7          	jalr	92(ra) # 800038c0 <iupdate>
  iunlockput(ip);
    8000586c:	854a                	mv	a0,s2
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	37e080e7          	jalr	894(ra) # 80003bec <iunlockput>
  end_op();
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	b56080e7          	jalr	-1194(ra) # 800043cc <end_op>
  return 0;
    8000587e:	4501                	li	a0,0
    80005880:	a84d                	j	80005932 <sys_unlink+0x1c4>
    end_op();
    80005882:	fffff097          	auipc	ra,0xfffff
    80005886:	b4a080e7          	jalr	-1206(ra) # 800043cc <end_op>
    return -1;
    8000588a:	557d                	li	a0,-1
    8000588c:	a05d                	j	80005932 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000588e:	00003517          	auipc	a0,0x3
    80005892:	e9250513          	addi	a0,a0,-366 # 80008720 <syscalls+0x2b0>
    80005896:	ffffb097          	auipc	ra,0xffffb
    8000589a:	ca8080e7          	jalr	-856(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000589e:	04c92703          	lw	a4,76(s2)
    800058a2:	02000793          	li	a5,32
    800058a6:	f6e7f9e3          	bgeu	a5,a4,80005818 <sys_unlink+0xaa>
    800058aa:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058ae:	4741                	li	a4,16
    800058b0:	86ce                	mv	a3,s3
    800058b2:	f1840613          	addi	a2,s0,-232
    800058b6:	4581                	li	a1,0
    800058b8:	854a                	mv	a0,s2
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	384080e7          	jalr	900(ra) # 80003c3e <readi>
    800058c2:	47c1                	li	a5,16
    800058c4:	00f51b63          	bne	a0,a5,800058da <sys_unlink+0x16c>
    if(de.inum != 0)
    800058c8:	f1845783          	lhu	a5,-232(s0)
    800058cc:	e7a1                	bnez	a5,80005914 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058ce:	29c1                	addiw	s3,s3,16
    800058d0:	04c92783          	lw	a5,76(s2)
    800058d4:	fcf9ede3          	bltu	s3,a5,800058ae <sys_unlink+0x140>
    800058d8:	b781                	j	80005818 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058da:	00003517          	auipc	a0,0x3
    800058de:	e5e50513          	addi	a0,a0,-418 # 80008738 <syscalls+0x2c8>
    800058e2:	ffffb097          	auipc	ra,0xffffb
    800058e6:	c5c080e7          	jalr	-932(ra) # 8000053e <panic>
    panic("unlink: writei");
    800058ea:	00003517          	auipc	a0,0x3
    800058ee:	e6650513          	addi	a0,a0,-410 # 80008750 <syscalls+0x2e0>
    800058f2:	ffffb097          	auipc	ra,0xffffb
    800058f6:	c4c080e7          	jalr	-948(ra) # 8000053e <panic>
    dp->nlink--;
    800058fa:	04a4d783          	lhu	a5,74(s1)
    800058fe:	37fd                	addiw	a5,a5,-1
    80005900:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005904:	8526                	mv	a0,s1
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	fba080e7          	jalr	-70(ra) # 800038c0 <iupdate>
    8000590e:	b781                	j	8000584e <sys_unlink+0xe0>
    return -1;
    80005910:	557d                	li	a0,-1
    80005912:	a005                	j	80005932 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005914:	854a                	mv	a0,s2
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	2d6080e7          	jalr	726(ra) # 80003bec <iunlockput>
  iunlockput(dp);
    8000591e:	8526                	mv	a0,s1
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	2cc080e7          	jalr	716(ra) # 80003bec <iunlockput>
  end_op();
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	aa4080e7          	jalr	-1372(ra) # 800043cc <end_op>
  return -1;
    80005930:	557d                	li	a0,-1
}
    80005932:	70ae                	ld	ra,232(sp)
    80005934:	740e                	ld	s0,224(sp)
    80005936:	64ee                	ld	s1,216(sp)
    80005938:	694e                	ld	s2,208(sp)
    8000593a:	69ae                	ld	s3,200(sp)
    8000593c:	616d                	addi	sp,sp,240
    8000593e:	8082                	ret

0000000080005940 <sys_open>:

uint64
sys_open(void)
{
    80005940:	7131                	addi	sp,sp,-192
    80005942:	fd06                	sd	ra,184(sp)
    80005944:	f922                	sd	s0,176(sp)
    80005946:	f526                	sd	s1,168(sp)
    80005948:	f14a                	sd	s2,160(sp)
    8000594a:	ed4e                	sd	s3,152(sp)
    8000594c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000594e:	f4c40593          	addi	a1,s0,-180
    80005952:	4505                	li	a0,1
    80005954:	ffffd097          	auipc	ra,0xffffd
    80005958:	4ba080e7          	jalr	1210(ra) # 80002e0e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000595c:	08000613          	li	a2,128
    80005960:	f5040593          	addi	a1,s0,-176
    80005964:	4501                	li	a0,0
    80005966:	ffffd097          	auipc	ra,0xffffd
    8000596a:	4e8080e7          	jalr	1256(ra) # 80002e4e <argstr>
    8000596e:	87aa                	mv	a5,a0
    return -1;
    80005970:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005972:	0a07c963          	bltz	a5,80005a24 <sys_open+0xe4>

  begin_op();
    80005976:	fffff097          	auipc	ra,0xfffff
    8000597a:	9d6080e7          	jalr	-1578(ra) # 8000434c <begin_op>

  if(omode & O_CREATE){
    8000597e:	f4c42783          	lw	a5,-180(s0)
    80005982:	2007f793          	andi	a5,a5,512
    80005986:	cfc5                	beqz	a5,80005a3e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005988:	4681                	li	a3,0
    8000598a:	4601                	li	a2,0
    8000598c:	4589                	li	a1,2
    8000598e:	f5040513          	addi	a0,s0,-176
    80005992:	00000097          	auipc	ra,0x0
    80005996:	974080e7          	jalr	-1676(ra) # 80005306 <create>
    8000599a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000599c:	c959                	beqz	a0,80005a32 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000599e:	04449703          	lh	a4,68(s1)
    800059a2:	478d                	li	a5,3
    800059a4:	00f71763          	bne	a4,a5,800059b2 <sys_open+0x72>
    800059a8:	0464d703          	lhu	a4,70(s1)
    800059ac:	47a5                	li	a5,9
    800059ae:	0ce7ed63          	bltu	a5,a4,80005a88 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059b2:	fffff097          	auipc	ra,0xfffff
    800059b6:	daa080e7          	jalr	-598(ra) # 8000475c <filealloc>
    800059ba:	89aa                	mv	s3,a0
    800059bc:	10050363          	beqz	a0,80005ac2 <sys_open+0x182>
    800059c0:	00000097          	auipc	ra,0x0
    800059c4:	904080e7          	jalr	-1788(ra) # 800052c4 <fdalloc>
    800059c8:	892a                	mv	s2,a0
    800059ca:	0e054763          	bltz	a0,80005ab8 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059ce:	04449703          	lh	a4,68(s1)
    800059d2:	478d                	li	a5,3
    800059d4:	0cf70563          	beq	a4,a5,80005a9e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059d8:	4789                	li	a5,2
    800059da:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800059de:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800059e2:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800059e6:	f4c42783          	lw	a5,-180(s0)
    800059ea:	0017c713          	xori	a4,a5,1
    800059ee:	8b05                	andi	a4,a4,1
    800059f0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059f4:	0037f713          	andi	a4,a5,3
    800059f8:	00e03733          	snez	a4,a4
    800059fc:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a00:	4007f793          	andi	a5,a5,1024
    80005a04:	c791                	beqz	a5,80005a10 <sys_open+0xd0>
    80005a06:	04449703          	lh	a4,68(s1)
    80005a0a:	4789                	li	a5,2
    80005a0c:	0af70063          	beq	a4,a5,80005aac <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a10:	8526                	mv	a0,s1
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	03a080e7          	jalr	58(ra) # 80003a4c <iunlock>
  end_op();
    80005a1a:	fffff097          	auipc	ra,0xfffff
    80005a1e:	9b2080e7          	jalr	-1614(ra) # 800043cc <end_op>

  return fd;
    80005a22:	854a                	mv	a0,s2
}
    80005a24:	70ea                	ld	ra,184(sp)
    80005a26:	744a                	ld	s0,176(sp)
    80005a28:	74aa                	ld	s1,168(sp)
    80005a2a:	790a                	ld	s2,160(sp)
    80005a2c:	69ea                	ld	s3,152(sp)
    80005a2e:	6129                	addi	sp,sp,192
    80005a30:	8082                	ret
      end_op();
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	99a080e7          	jalr	-1638(ra) # 800043cc <end_op>
      return -1;
    80005a3a:	557d                	li	a0,-1
    80005a3c:	b7e5                	j	80005a24 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a3e:	f5040513          	addi	a0,s0,-176
    80005a42:	ffffe097          	auipc	ra,0xffffe
    80005a46:	6ee080e7          	jalr	1774(ra) # 80004130 <namei>
    80005a4a:	84aa                	mv	s1,a0
    80005a4c:	c905                	beqz	a0,80005a7c <sys_open+0x13c>
    ilock(ip);
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	f3c080e7          	jalr	-196(ra) # 8000398a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a56:	04449703          	lh	a4,68(s1)
    80005a5a:	4785                	li	a5,1
    80005a5c:	f4f711e3          	bne	a4,a5,8000599e <sys_open+0x5e>
    80005a60:	f4c42783          	lw	a5,-180(s0)
    80005a64:	d7b9                	beqz	a5,800059b2 <sys_open+0x72>
      iunlockput(ip);
    80005a66:	8526                	mv	a0,s1
    80005a68:	ffffe097          	auipc	ra,0xffffe
    80005a6c:	184080e7          	jalr	388(ra) # 80003bec <iunlockput>
      end_op();
    80005a70:	fffff097          	auipc	ra,0xfffff
    80005a74:	95c080e7          	jalr	-1700(ra) # 800043cc <end_op>
      return -1;
    80005a78:	557d                	li	a0,-1
    80005a7a:	b76d                	j	80005a24 <sys_open+0xe4>
      end_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	950080e7          	jalr	-1712(ra) # 800043cc <end_op>
      return -1;
    80005a84:	557d                	li	a0,-1
    80005a86:	bf79                	j	80005a24 <sys_open+0xe4>
    iunlockput(ip);
    80005a88:	8526                	mv	a0,s1
    80005a8a:	ffffe097          	auipc	ra,0xffffe
    80005a8e:	162080e7          	jalr	354(ra) # 80003bec <iunlockput>
    end_op();
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	93a080e7          	jalr	-1734(ra) # 800043cc <end_op>
    return -1;
    80005a9a:	557d                	li	a0,-1
    80005a9c:	b761                	j	80005a24 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a9e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005aa2:	04649783          	lh	a5,70(s1)
    80005aa6:	02f99223          	sh	a5,36(s3)
    80005aaa:	bf25                	j	800059e2 <sys_open+0xa2>
    itrunc(ip);
    80005aac:	8526                	mv	a0,s1
    80005aae:	ffffe097          	auipc	ra,0xffffe
    80005ab2:	fea080e7          	jalr	-22(ra) # 80003a98 <itrunc>
    80005ab6:	bfa9                	j	80005a10 <sys_open+0xd0>
      fileclose(f);
    80005ab8:	854e                	mv	a0,s3
    80005aba:	fffff097          	auipc	ra,0xfffff
    80005abe:	d5e080e7          	jalr	-674(ra) # 80004818 <fileclose>
    iunlockput(ip);
    80005ac2:	8526                	mv	a0,s1
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	128080e7          	jalr	296(ra) # 80003bec <iunlockput>
    end_op();
    80005acc:	fffff097          	auipc	ra,0xfffff
    80005ad0:	900080e7          	jalr	-1792(ra) # 800043cc <end_op>
    return -1;
    80005ad4:	557d                	li	a0,-1
    80005ad6:	b7b9                	j	80005a24 <sys_open+0xe4>

0000000080005ad8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ad8:	7175                	addi	sp,sp,-144
    80005ada:	e506                	sd	ra,136(sp)
    80005adc:	e122                	sd	s0,128(sp)
    80005ade:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	86c080e7          	jalr	-1940(ra) # 8000434c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ae8:	08000613          	li	a2,128
    80005aec:	f7040593          	addi	a1,s0,-144
    80005af0:	4501                	li	a0,0
    80005af2:	ffffd097          	auipc	ra,0xffffd
    80005af6:	35c080e7          	jalr	860(ra) # 80002e4e <argstr>
    80005afa:	02054963          	bltz	a0,80005b2c <sys_mkdir+0x54>
    80005afe:	4681                	li	a3,0
    80005b00:	4601                	li	a2,0
    80005b02:	4585                	li	a1,1
    80005b04:	f7040513          	addi	a0,s0,-144
    80005b08:	fffff097          	auipc	ra,0xfffff
    80005b0c:	7fe080e7          	jalr	2046(ra) # 80005306 <create>
    80005b10:	cd11                	beqz	a0,80005b2c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b12:	ffffe097          	auipc	ra,0xffffe
    80005b16:	0da080e7          	jalr	218(ra) # 80003bec <iunlockput>
  end_op();
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	8b2080e7          	jalr	-1870(ra) # 800043cc <end_op>
  return 0;
    80005b22:	4501                	li	a0,0
}
    80005b24:	60aa                	ld	ra,136(sp)
    80005b26:	640a                	ld	s0,128(sp)
    80005b28:	6149                	addi	sp,sp,144
    80005b2a:	8082                	ret
    end_op();
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	8a0080e7          	jalr	-1888(ra) # 800043cc <end_op>
    return -1;
    80005b34:	557d                	li	a0,-1
    80005b36:	b7fd                	j	80005b24 <sys_mkdir+0x4c>

0000000080005b38 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b38:	7135                	addi	sp,sp,-160
    80005b3a:	ed06                	sd	ra,152(sp)
    80005b3c:	e922                	sd	s0,144(sp)
    80005b3e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	80c080e7          	jalr	-2036(ra) # 8000434c <begin_op>
  argint(1, &major);
    80005b48:	f6c40593          	addi	a1,s0,-148
    80005b4c:	4505                	li	a0,1
    80005b4e:	ffffd097          	auipc	ra,0xffffd
    80005b52:	2c0080e7          	jalr	704(ra) # 80002e0e <argint>
  argint(2, &minor);
    80005b56:	f6840593          	addi	a1,s0,-152
    80005b5a:	4509                	li	a0,2
    80005b5c:	ffffd097          	auipc	ra,0xffffd
    80005b60:	2b2080e7          	jalr	690(ra) # 80002e0e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b64:	08000613          	li	a2,128
    80005b68:	f7040593          	addi	a1,s0,-144
    80005b6c:	4501                	li	a0,0
    80005b6e:	ffffd097          	auipc	ra,0xffffd
    80005b72:	2e0080e7          	jalr	736(ra) # 80002e4e <argstr>
    80005b76:	02054b63          	bltz	a0,80005bac <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b7a:	f6841683          	lh	a3,-152(s0)
    80005b7e:	f6c41603          	lh	a2,-148(s0)
    80005b82:	458d                	li	a1,3
    80005b84:	f7040513          	addi	a0,s0,-144
    80005b88:	fffff097          	auipc	ra,0xfffff
    80005b8c:	77e080e7          	jalr	1918(ra) # 80005306 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b90:	cd11                	beqz	a0,80005bac <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	05a080e7          	jalr	90(ra) # 80003bec <iunlockput>
  end_op();
    80005b9a:	fffff097          	auipc	ra,0xfffff
    80005b9e:	832080e7          	jalr	-1998(ra) # 800043cc <end_op>
  return 0;
    80005ba2:	4501                	li	a0,0
}
    80005ba4:	60ea                	ld	ra,152(sp)
    80005ba6:	644a                	ld	s0,144(sp)
    80005ba8:	610d                	addi	sp,sp,160
    80005baa:	8082                	ret
    end_op();
    80005bac:	fffff097          	auipc	ra,0xfffff
    80005bb0:	820080e7          	jalr	-2016(ra) # 800043cc <end_op>
    return -1;
    80005bb4:	557d                	li	a0,-1
    80005bb6:	b7fd                	j	80005ba4 <sys_mknod+0x6c>

0000000080005bb8 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bb8:	7135                	addi	sp,sp,-160
    80005bba:	ed06                	sd	ra,152(sp)
    80005bbc:	e922                	sd	s0,144(sp)
    80005bbe:	e526                	sd	s1,136(sp)
    80005bc0:	e14a                	sd	s2,128(sp)
    80005bc2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bc4:	ffffc097          	auipc	ra,0xffffc
    80005bc8:	dbc080e7          	jalr	-580(ra) # 80001980 <myproc>
    80005bcc:	892a                	mv	s2,a0
  
  begin_op();
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	77e080e7          	jalr	1918(ra) # 8000434c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bd6:	08000613          	li	a2,128
    80005bda:	f6040593          	addi	a1,s0,-160
    80005bde:	4501                	li	a0,0
    80005be0:	ffffd097          	auipc	ra,0xffffd
    80005be4:	26e080e7          	jalr	622(ra) # 80002e4e <argstr>
    80005be8:	04054b63          	bltz	a0,80005c3e <sys_chdir+0x86>
    80005bec:	f6040513          	addi	a0,s0,-160
    80005bf0:	ffffe097          	auipc	ra,0xffffe
    80005bf4:	540080e7          	jalr	1344(ra) # 80004130 <namei>
    80005bf8:	84aa                	mv	s1,a0
    80005bfa:	c131                	beqz	a0,80005c3e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bfc:	ffffe097          	auipc	ra,0xffffe
    80005c00:	d8e080e7          	jalr	-626(ra) # 8000398a <ilock>
  if(ip->type != T_DIR){
    80005c04:	04449703          	lh	a4,68(s1)
    80005c08:	4785                	li	a5,1
    80005c0a:	04f71063          	bne	a4,a5,80005c4a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c0e:	8526                	mv	a0,s1
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	e3c080e7          	jalr	-452(ra) # 80003a4c <iunlock>
  iput(p->cwd);
    80005c18:	18893503          	ld	a0,392(s2)
    80005c1c:	ffffe097          	auipc	ra,0xffffe
    80005c20:	f28080e7          	jalr	-216(ra) # 80003b44 <iput>
  end_op();
    80005c24:	ffffe097          	auipc	ra,0xffffe
    80005c28:	7a8080e7          	jalr	1960(ra) # 800043cc <end_op>
  p->cwd = ip;
    80005c2c:	18993423          	sd	s1,392(s2)
  return 0;
    80005c30:	4501                	li	a0,0
}
    80005c32:	60ea                	ld	ra,152(sp)
    80005c34:	644a                	ld	s0,144(sp)
    80005c36:	64aa                	ld	s1,136(sp)
    80005c38:	690a                	ld	s2,128(sp)
    80005c3a:	610d                	addi	sp,sp,160
    80005c3c:	8082                	ret
    end_op();
    80005c3e:	ffffe097          	auipc	ra,0xffffe
    80005c42:	78e080e7          	jalr	1934(ra) # 800043cc <end_op>
    return -1;
    80005c46:	557d                	li	a0,-1
    80005c48:	b7ed                	j	80005c32 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c4a:	8526                	mv	a0,s1
    80005c4c:	ffffe097          	auipc	ra,0xffffe
    80005c50:	fa0080e7          	jalr	-96(ra) # 80003bec <iunlockput>
    end_op();
    80005c54:	ffffe097          	auipc	ra,0xffffe
    80005c58:	778080e7          	jalr	1912(ra) # 800043cc <end_op>
    return -1;
    80005c5c:	557d                	li	a0,-1
    80005c5e:	bfd1                	j	80005c32 <sys_chdir+0x7a>

0000000080005c60 <sys_exec>:

uint64
sys_exec(void)
{
    80005c60:	7145                	addi	sp,sp,-464
    80005c62:	e786                	sd	ra,456(sp)
    80005c64:	e3a2                	sd	s0,448(sp)
    80005c66:	ff26                	sd	s1,440(sp)
    80005c68:	fb4a                	sd	s2,432(sp)
    80005c6a:	f74e                	sd	s3,424(sp)
    80005c6c:	f352                	sd	s4,416(sp)
    80005c6e:	ef56                	sd	s5,408(sp)
    80005c70:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c72:	e3840593          	addi	a1,s0,-456
    80005c76:	4505                	li	a0,1
    80005c78:	ffffd097          	auipc	ra,0xffffd
    80005c7c:	1b6080e7          	jalr	438(ra) # 80002e2e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c80:	08000613          	li	a2,128
    80005c84:	f4040593          	addi	a1,s0,-192
    80005c88:	4501                	li	a0,0
    80005c8a:	ffffd097          	auipc	ra,0xffffd
    80005c8e:	1c4080e7          	jalr	452(ra) # 80002e4e <argstr>
    80005c92:	87aa                	mv	a5,a0
    return -1;
    80005c94:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c96:	0c07c263          	bltz	a5,80005d5a <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c9a:	10000613          	li	a2,256
    80005c9e:	4581                	li	a1,0
    80005ca0:	e4040513          	addi	a0,s0,-448
    80005ca4:	ffffb097          	auipc	ra,0xffffb
    80005ca8:	02e080e7          	jalr	46(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005cac:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005cb0:	89a6                	mv	s3,s1
    80005cb2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005cb4:	02000a13          	li	s4,32
    80005cb8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cbc:	00391793          	slli	a5,s2,0x3
    80005cc0:	e3040593          	addi	a1,s0,-464
    80005cc4:	e3843503          	ld	a0,-456(s0)
    80005cc8:	953e                	add	a0,a0,a5
    80005cca:	ffffd097          	auipc	ra,0xffffd
    80005cce:	0a2080e7          	jalr	162(ra) # 80002d6c <fetchaddr>
    80005cd2:	02054a63          	bltz	a0,80005d06 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005cd6:	e3043783          	ld	a5,-464(s0)
    80005cda:	c3b9                	beqz	a5,80005d20 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cdc:	ffffb097          	auipc	ra,0xffffb
    80005ce0:	e0a080e7          	jalr	-502(ra) # 80000ae6 <kalloc>
    80005ce4:	85aa                	mv	a1,a0
    80005ce6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cea:	cd11                	beqz	a0,80005d06 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cec:	6605                	lui	a2,0x1
    80005cee:	e3043503          	ld	a0,-464(s0)
    80005cf2:	ffffd097          	auipc	ra,0xffffd
    80005cf6:	0ce080e7          	jalr	206(ra) # 80002dc0 <fetchstr>
    80005cfa:	00054663          	bltz	a0,80005d06 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005cfe:	0905                	addi	s2,s2,1
    80005d00:	09a1                	addi	s3,s3,8
    80005d02:	fb491be3          	bne	s2,s4,80005cb8 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d06:	10048913          	addi	s2,s1,256
    80005d0a:	6088                	ld	a0,0(s1)
    80005d0c:	c531                	beqz	a0,80005d58 <sys_exec+0xf8>
    kfree(argv[i]);
    80005d0e:	ffffb097          	auipc	ra,0xffffb
    80005d12:	cdc080e7          	jalr	-804(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d16:	04a1                	addi	s1,s1,8
    80005d18:	ff2499e3          	bne	s1,s2,80005d0a <sys_exec+0xaa>
  return -1;
    80005d1c:	557d                	li	a0,-1
    80005d1e:	a835                	j	80005d5a <sys_exec+0xfa>
      argv[i] = 0;
    80005d20:	0a8e                	slli	s5,s5,0x3
    80005d22:	fc040793          	addi	a5,s0,-64
    80005d26:	9abe                	add	s5,s5,a5
    80005d28:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d2c:	e4040593          	addi	a1,s0,-448
    80005d30:	f4040513          	addi	a0,s0,-192
    80005d34:	fffff097          	auipc	ra,0xfffff
    80005d38:	15e080e7          	jalr	350(ra) # 80004e92 <exec>
    80005d3c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d3e:	10048993          	addi	s3,s1,256
    80005d42:	6088                	ld	a0,0(s1)
    80005d44:	c901                	beqz	a0,80005d54 <sys_exec+0xf4>
    kfree(argv[i]);
    80005d46:	ffffb097          	auipc	ra,0xffffb
    80005d4a:	ca4080e7          	jalr	-860(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d4e:	04a1                	addi	s1,s1,8
    80005d50:	ff3499e3          	bne	s1,s3,80005d42 <sys_exec+0xe2>
  return ret;
    80005d54:	854a                	mv	a0,s2
    80005d56:	a011                	j	80005d5a <sys_exec+0xfa>
  return -1;
    80005d58:	557d                	li	a0,-1
}
    80005d5a:	60be                	ld	ra,456(sp)
    80005d5c:	641e                	ld	s0,448(sp)
    80005d5e:	74fa                	ld	s1,440(sp)
    80005d60:	795a                	ld	s2,432(sp)
    80005d62:	79ba                	ld	s3,424(sp)
    80005d64:	7a1a                	ld	s4,416(sp)
    80005d66:	6afa                	ld	s5,408(sp)
    80005d68:	6179                	addi	sp,sp,464
    80005d6a:	8082                	ret

0000000080005d6c <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d6c:	7139                	addi	sp,sp,-64
    80005d6e:	fc06                	sd	ra,56(sp)
    80005d70:	f822                	sd	s0,48(sp)
    80005d72:	f426                	sd	s1,40(sp)
    80005d74:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d76:	ffffc097          	auipc	ra,0xffffc
    80005d7a:	c0a080e7          	jalr	-1014(ra) # 80001980 <myproc>
    80005d7e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d80:	fd840593          	addi	a1,s0,-40
    80005d84:	4501                	li	a0,0
    80005d86:	ffffd097          	auipc	ra,0xffffd
    80005d8a:	0a8080e7          	jalr	168(ra) # 80002e2e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d8e:	fc840593          	addi	a1,s0,-56
    80005d92:	fd040513          	addi	a0,s0,-48
    80005d96:	fffff097          	auipc	ra,0xfffff
    80005d9a:	db2080e7          	jalr	-590(ra) # 80004b48 <pipealloc>
    return -1;
    80005d9e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005da0:	0c054963          	bltz	a0,80005e72 <sys_pipe+0x106>
  fd0 = -1;
    80005da4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005da8:	fd043503          	ld	a0,-48(s0)
    80005dac:	fffff097          	auipc	ra,0xfffff
    80005db0:	518080e7          	jalr	1304(ra) # 800052c4 <fdalloc>
    80005db4:	fca42223          	sw	a0,-60(s0)
    80005db8:	0a054063          	bltz	a0,80005e58 <sys_pipe+0xec>
    80005dbc:	fc843503          	ld	a0,-56(s0)
    80005dc0:	fffff097          	auipc	ra,0xfffff
    80005dc4:	504080e7          	jalr	1284(ra) # 800052c4 <fdalloc>
    80005dc8:	fca42023          	sw	a0,-64(s0)
    80005dcc:	06054c63          	bltz	a0,80005e44 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dd0:	4691                	li	a3,4
    80005dd2:	fc440613          	addi	a2,s0,-60
    80005dd6:	fd843583          	ld	a1,-40(s0)
    80005dda:	1004b503          	ld	a0,256(s1)
    80005dde:	ffffc097          	auipc	ra,0xffffc
    80005de2:	88a080e7          	jalr	-1910(ra) # 80001668 <copyout>
    80005de6:	02054163          	bltz	a0,80005e08 <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dea:	4691                	li	a3,4
    80005dec:	fc040613          	addi	a2,s0,-64
    80005df0:	fd843583          	ld	a1,-40(s0)
    80005df4:	0591                	addi	a1,a1,4
    80005df6:	1004b503          	ld	a0,256(s1)
    80005dfa:	ffffc097          	auipc	ra,0xffffc
    80005dfe:	86e080e7          	jalr	-1938(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e02:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e04:	06055763          	bgez	a0,80005e72 <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80005e08:	fc442783          	lw	a5,-60(s0)
    80005e0c:	02078793          	addi	a5,a5,32
    80005e10:	078e                	slli	a5,a5,0x3
    80005e12:	97a6                	add	a5,a5,s1
    80005e14:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e18:	fc042503          	lw	a0,-64(s0)
    80005e1c:	02050513          	addi	a0,a0,32
    80005e20:	050e                	slli	a0,a0,0x3
    80005e22:	94aa                	add	s1,s1,a0
    80005e24:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e28:	fd043503          	ld	a0,-48(s0)
    80005e2c:	fffff097          	auipc	ra,0xfffff
    80005e30:	9ec080e7          	jalr	-1556(ra) # 80004818 <fileclose>
    fileclose(wf);
    80005e34:	fc843503          	ld	a0,-56(s0)
    80005e38:	fffff097          	auipc	ra,0xfffff
    80005e3c:	9e0080e7          	jalr	-1568(ra) # 80004818 <fileclose>
    return -1;
    80005e40:	57fd                	li	a5,-1
    80005e42:	a805                	j	80005e72 <sys_pipe+0x106>
    if(fd0 >= 0)
    80005e44:	fc442783          	lw	a5,-60(s0)
    80005e48:	0007c863          	bltz	a5,80005e58 <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80005e4c:	02078793          	addi	a5,a5,32
    80005e50:	078e                	slli	a5,a5,0x3
    80005e52:	94be                	add	s1,s1,a5
    80005e54:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e58:	fd043503          	ld	a0,-48(s0)
    80005e5c:	fffff097          	auipc	ra,0xfffff
    80005e60:	9bc080e7          	jalr	-1604(ra) # 80004818 <fileclose>
    fileclose(wf);
    80005e64:	fc843503          	ld	a0,-56(s0)
    80005e68:	fffff097          	auipc	ra,0xfffff
    80005e6c:	9b0080e7          	jalr	-1616(ra) # 80004818 <fileclose>
    return -1;
    80005e70:	57fd                	li	a5,-1
}
    80005e72:	853e                	mv	a0,a5
    80005e74:	70e2                	ld	ra,56(sp)
    80005e76:	7442                	ld	s0,48(sp)
    80005e78:	74a2                	ld	s1,40(sp)
    80005e7a:	6121                	addi	sp,sp,64
    80005e7c:	8082                	ret
	...

0000000080005e80 <kernelvec>:
    80005e80:	7111                	addi	sp,sp,-256
    80005e82:	e006                	sd	ra,0(sp)
    80005e84:	e40a                	sd	sp,8(sp)
    80005e86:	e80e                	sd	gp,16(sp)
    80005e88:	ec12                	sd	tp,24(sp)
    80005e8a:	f016                	sd	t0,32(sp)
    80005e8c:	f41a                	sd	t1,40(sp)
    80005e8e:	f81e                	sd	t2,48(sp)
    80005e90:	fc22                	sd	s0,56(sp)
    80005e92:	e0a6                	sd	s1,64(sp)
    80005e94:	e4aa                	sd	a0,72(sp)
    80005e96:	e8ae                	sd	a1,80(sp)
    80005e98:	ecb2                	sd	a2,88(sp)
    80005e9a:	f0b6                	sd	a3,96(sp)
    80005e9c:	f4ba                	sd	a4,104(sp)
    80005e9e:	f8be                	sd	a5,112(sp)
    80005ea0:	fcc2                	sd	a6,120(sp)
    80005ea2:	e146                	sd	a7,128(sp)
    80005ea4:	e54a                	sd	s2,136(sp)
    80005ea6:	e94e                	sd	s3,144(sp)
    80005ea8:	ed52                	sd	s4,152(sp)
    80005eaa:	f156                	sd	s5,160(sp)
    80005eac:	f55a                	sd	s6,168(sp)
    80005eae:	f95e                	sd	s7,176(sp)
    80005eb0:	fd62                	sd	s8,184(sp)
    80005eb2:	e1e6                	sd	s9,192(sp)
    80005eb4:	e5ea                	sd	s10,200(sp)
    80005eb6:	e9ee                	sd	s11,208(sp)
    80005eb8:	edf2                	sd	t3,216(sp)
    80005eba:	f1f6                	sd	t4,224(sp)
    80005ebc:	f5fa                	sd	t5,232(sp)
    80005ebe:	f9fe                	sd	t6,240(sp)
    80005ec0:	d79fc0ef          	jal	ra,80002c38 <kerneltrap>
    80005ec4:	6082                	ld	ra,0(sp)
    80005ec6:	6122                	ld	sp,8(sp)
    80005ec8:	61c2                	ld	gp,16(sp)
    80005eca:	7282                	ld	t0,32(sp)
    80005ecc:	7322                	ld	t1,40(sp)
    80005ece:	73c2                	ld	t2,48(sp)
    80005ed0:	7462                	ld	s0,56(sp)
    80005ed2:	6486                	ld	s1,64(sp)
    80005ed4:	6526                	ld	a0,72(sp)
    80005ed6:	65c6                	ld	a1,80(sp)
    80005ed8:	6666                	ld	a2,88(sp)
    80005eda:	7686                	ld	a3,96(sp)
    80005edc:	7726                	ld	a4,104(sp)
    80005ede:	77c6                	ld	a5,112(sp)
    80005ee0:	7866                	ld	a6,120(sp)
    80005ee2:	688a                	ld	a7,128(sp)
    80005ee4:	692a                	ld	s2,136(sp)
    80005ee6:	69ca                	ld	s3,144(sp)
    80005ee8:	6a6a                	ld	s4,152(sp)
    80005eea:	7a8a                	ld	s5,160(sp)
    80005eec:	7b2a                	ld	s6,168(sp)
    80005eee:	7bca                	ld	s7,176(sp)
    80005ef0:	7c6a                	ld	s8,184(sp)
    80005ef2:	6c8e                	ld	s9,192(sp)
    80005ef4:	6d2e                	ld	s10,200(sp)
    80005ef6:	6dce                	ld	s11,208(sp)
    80005ef8:	6e6e                	ld	t3,216(sp)
    80005efa:	7e8e                	ld	t4,224(sp)
    80005efc:	7f2e                	ld	t5,232(sp)
    80005efe:	7fce                	ld	t6,240(sp)
    80005f00:	6111                	addi	sp,sp,256
    80005f02:	10200073          	sret
    80005f06:	00000013          	nop
    80005f0a:	00000013          	nop
    80005f0e:	0001                	nop

0000000080005f10 <timervec>:
    80005f10:	34051573          	csrrw	a0,mscratch,a0
    80005f14:	e10c                	sd	a1,0(a0)
    80005f16:	e510                	sd	a2,8(a0)
    80005f18:	e914                	sd	a3,16(a0)
    80005f1a:	6d0c                	ld	a1,24(a0)
    80005f1c:	7110                	ld	a2,32(a0)
    80005f1e:	6194                	ld	a3,0(a1)
    80005f20:	96b2                	add	a3,a3,a2
    80005f22:	e194                	sd	a3,0(a1)
    80005f24:	4589                	li	a1,2
    80005f26:	14459073          	csrw	sip,a1
    80005f2a:	6914                	ld	a3,16(a0)
    80005f2c:	6510                	ld	a2,8(a0)
    80005f2e:	610c                	ld	a1,0(a0)
    80005f30:	34051573          	csrrw	a0,mscratch,a0
    80005f34:	30200073          	mret
	...

0000000080005f3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f3a:	1141                	addi	sp,sp,-16
    80005f3c:	e422                	sd	s0,8(sp)
    80005f3e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f40:	0c0007b7          	lui	a5,0xc000
    80005f44:	4705                	li	a4,1
    80005f46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f48:	c3d8                	sw	a4,4(a5)
}
    80005f4a:	6422                	ld	s0,8(sp)
    80005f4c:	0141                	addi	sp,sp,16
    80005f4e:	8082                	ret

0000000080005f50 <plicinithart>:

void
plicinithart(void)
{
    80005f50:	1141                	addi	sp,sp,-16
    80005f52:	e406                	sd	ra,8(sp)
    80005f54:	e022                	sd	s0,0(sp)
    80005f56:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f58:	ffffc097          	auipc	ra,0xffffc
    80005f5c:	9fc080e7          	jalr	-1540(ra) # 80001954 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f60:	0085171b          	slliw	a4,a0,0x8
    80005f64:	0c0027b7          	lui	a5,0xc002
    80005f68:	97ba                	add	a5,a5,a4
    80005f6a:	40200713          	li	a4,1026
    80005f6e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f72:	00d5151b          	slliw	a0,a0,0xd
    80005f76:	0c2017b7          	lui	a5,0xc201
    80005f7a:	953e                	add	a0,a0,a5
    80005f7c:	00052023          	sw	zero,0(a0)
}
    80005f80:	60a2                	ld	ra,8(sp)
    80005f82:	6402                	ld	s0,0(sp)
    80005f84:	0141                	addi	sp,sp,16
    80005f86:	8082                	ret

0000000080005f88 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f88:	1141                	addi	sp,sp,-16
    80005f8a:	e406                	sd	ra,8(sp)
    80005f8c:	e022                	sd	s0,0(sp)
    80005f8e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f90:	ffffc097          	auipc	ra,0xffffc
    80005f94:	9c4080e7          	jalr	-1596(ra) # 80001954 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f98:	00d5179b          	slliw	a5,a0,0xd
    80005f9c:	0c201537          	lui	a0,0xc201
    80005fa0:	953e                	add	a0,a0,a5
  return irq;
}
    80005fa2:	4148                	lw	a0,4(a0)
    80005fa4:	60a2                	ld	ra,8(sp)
    80005fa6:	6402                	ld	s0,0(sp)
    80005fa8:	0141                	addi	sp,sp,16
    80005faa:	8082                	ret

0000000080005fac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fac:	1101                	addi	sp,sp,-32
    80005fae:	ec06                	sd	ra,24(sp)
    80005fb0:	e822                	sd	s0,16(sp)
    80005fb2:	e426                	sd	s1,8(sp)
    80005fb4:	1000                	addi	s0,sp,32
    80005fb6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fb8:	ffffc097          	auipc	ra,0xffffc
    80005fbc:	99c080e7          	jalr	-1636(ra) # 80001954 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fc0:	00d5151b          	slliw	a0,a0,0xd
    80005fc4:	0c2017b7          	lui	a5,0xc201
    80005fc8:	97aa                	add	a5,a5,a0
    80005fca:	c3c4                	sw	s1,4(a5)
}
    80005fcc:	60e2                	ld	ra,24(sp)
    80005fce:	6442                	ld	s0,16(sp)
    80005fd0:	64a2                	ld	s1,8(sp)
    80005fd2:	6105                	addi	sp,sp,32
    80005fd4:	8082                	ret

0000000080005fd6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fd6:	1141                	addi	sp,sp,-16
    80005fd8:	e406                	sd	ra,8(sp)
    80005fda:	e022                	sd	s0,0(sp)
    80005fdc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fde:	479d                	li	a5,7
    80005fe0:	04a7cc63          	blt	a5,a0,80006038 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005fe4:	0001d797          	auipc	a5,0x1d
    80005fe8:	25c78793          	addi	a5,a5,604 # 80023240 <disk>
    80005fec:	97aa                	add	a5,a5,a0
    80005fee:	0187c783          	lbu	a5,24(a5)
    80005ff2:	ebb9                	bnez	a5,80006048 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ff4:	00451613          	slli	a2,a0,0x4
    80005ff8:	0001d797          	auipc	a5,0x1d
    80005ffc:	24878793          	addi	a5,a5,584 # 80023240 <disk>
    80006000:	6394                	ld	a3,0(a5)
    80006002:	96b2                	add	a3,a3,a2
    80006004:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006008:	6398                	ld	a4,0(a5)
    8000600a:	9732                	add	a4,a4,a2
    8000600c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006010:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006014:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006018:	953e                	add	a0,a0,a5
    8000601a:	4785                	li	a5,1
    8000601c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006020:	0001d517          	auipc	a0,0x1d
    80006024:	23850513          	addi	a0,a0,568 # 80023258 <disk+0x18>
    80006028:	ffffc097          	auipc	ra,0xffffc
    8000602c:	142080e7          	jalr	322(ra) # 8000216a <wakeup>
}
    80006030:	60a2                	ld	ra,8(sp)
    80006032:	6402                	ld	s0,0(sp)
    80006034:	0141                	addi	sp,sp,16
    80006036:	8082                	ret
    panic("free_desc 1");
    80006038:	00002517          	auipc	a0,0x2
    8000603c:	72850513          	addi	a0,a0,1832 # 80008760 <syscalls+0x2f0>
    80006040:	ffffa097          	auipc	ra,0xffffa
    80006044:	4fe080e7          	jalr	1278(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006048:	00002517          	auipc	a0,0x2
    8000604c:	72850513          	addi	a0,a0,1832 # 80008770 <syscalls+0x300>
    80006050:	ffffa097          	auipc	ra,0xffffa
    80006054:	4ee080e7          	jalr	1262(ra) # 8000053e <panic>

0000000080006058 <virtio_disk_init>:
{
    80006058:	1101                	addi	sp,sp,-32
    8000605a:	ec06                	sd	ra,24(sp)
    8000605c:	e822                	sd	s0,16(sp)
    8000605e:	e426                	sd	s1,8(sp)
    80006060:	e04a                	sd	s2,0(sp)
    80006062:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006064:	00002597          	auipc	a1,0x2
    80006068:	71c58593          	addi	a1,a1,1820 # 80008780 <syscalls+0x310>
    8000606c:	0001d517          	auipc	a0,0x1d
    80006070:	2fc50513          	addi	a0,a0,764 # 80023368 <disk+0x128>
    80006074:	ffffb097          	auipc	ra,0xffffb
    80006078:	ad2080e7          	jalr	-1326(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000607c:	100017b7          	lui	a5,0x10001
    80006080:	4398                	lw	a4,0(a5)
    80006082:	2701                	sext.w	a4,a4
    80006084:	747277b7          	lui	a5,0x74727
    80006088:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000608c:	14f71c63          	bne	a4,a5,800061e4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006090:	100017b7          	lui	a5,0x10001
    80006094:	43dc                	lw	a5,4(a5)
    80006096:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006098:	4709                	li	a4,2
    8000609a:	14e79563          	bne	a5,a4,800061e4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000609e:	100017b7          	lui	a5,0x10001
    800060a2:	479c                	lw	a5,8(a5)
    800060a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060a6:	12e79f63          	bne	a5,a4,800061e4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060aa:	100017b7          	lui	a5,0x10001
    800060ae:	47d8                	lw	a4,12(a5)
    800060b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060b2:	554d47b7          	lui	a5,0x554d4
    800060b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060ba:	12f71563          	bne	a4,a5,800061e4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060be:	100017b7          	lui	a5,0x10001
    800060c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060c6:	4705                	li	a4,1
    800060c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ca:	470d                	li	a4,3
    800060cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060ce:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060d0:	c7ffe737          	lui	a4,0xc7ffe
    800060d4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb3df>
    800060d8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060da:	2701                	sext.w	a4,a4
    800060dc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060de:	472d                	li	a4,11
    800060e0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800060e2:	5bbc                	lw	a5,112(a5)
    800060e4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060e8:	8ba1                	andi	a5,a5,8
    800060ea:	10078563          	beqz	a5,800061f4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060ee:	100017b7          	lui	a5,0x10001
    800060f2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060f6:	43fc                	lw	a5,68(a5)
    800060f8:	2781                	sext.w	a5,a5
    800060fa:	10079563          	bnez	a5,80006204 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060fe:	100017b7          	lui	a5,0x10001
    80006102:	5bdc                	lw	a5,52(a5)
    80006104:	2781                	sext.w	a5,a5
  if(max == 0)
    80006106:	10078763          	beqz	a5,80006214 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000610a:	471d                	li	a4,7
    8000610c:	10f77c63          	bgeu	a4,a5,80006224 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006110:	ffffb097          	auipc	ra,0xffffb
    80006114:	9d6080e7          	jalr	-1578(ra) # 80000ae6 <kalloc>
    80006118:	0001d497          	auipc	s1,0x1d
    8000611c:	12848493          	addi	s1,s1,296 # 80023240 <disk>
    80006120:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006122:	ffffb097          	auipc	ra,0xffffb
    80006126:	9c4080e7          	jalr	-1596(ra) # 80000ae6 <kalloc>
    8000612a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000612c:	ffffb097          	auipc	ra,0xffffb
    80006130:	9ba080e7          	jalr	-1606(ra) # 80000ae6 <kalloc>
    80006134:	87aa                	mv	a5,a0
    80006136:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006138:	6088                	ld	a0,0(s1)
    8000613a:	cd6d                	beqz	a0,80006234 <virtio_disk_init+0x1dc>
    8000613c:	0001d717          	auipc	a4,0x1d
    80006140:	10c73703          	ld	a4,268(a4) # 80023248 <disk+0x8>
    80006144:	cb65                	beqz	a4,80006234 <virtio_disk_init+0x1dc>
    80006146:	c7fd                	beqz	a5,80006234 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006148:	6605                	lui	a2,0x1
    8000614a:	4581                	li	a1,0
    8000614c:	ffffb097          	auipc	ra,0xffffb
    80006150:	b86080e7          	jalr	-1146(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006154:	0001d497          	auipc	s1,0x1d
    80006158:	0ec48493          	addi	s1,s1,236 # 80023240 <disk>
    8000615c:	6605                	lui	a2,0x1
    8000615e:	4581                	li	a1,0
    80006160:	6488                	ld	a0,8(s1)
    80006162:	ffffb097          	auipc	ra,0xffffb
    80006166:	b70080e7          	jalr	-1168(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000616a:	6605                	lui	a2,0x1
    8000616c:	4581                	li	a1,0
    8000616e:	6888                	ld	a0,16(s1)
    80006170:	ffffb097          	auipc	ra,0xffffb
    80006174:	b62080e7          	jalr	-1182(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006178:	100017b7          	lui	a5,0x10001
    8000617c:	4721                	li	a4,8
    8000617e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006180:	4098                	lw	a4,0(s1)
    80006182:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006186:	40d8                	lw	a4,4(s1)
    80006188:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000618c:	6498                	ld	a4,8(s1)
    8000618e:	0007069b          	sext.w	a3,a4
    80006192:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006196:	9701                	srai	a4,a4,0x20
    80006198:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000619c:	6898                	ld	a4,16(s1)
    8000619e:	0007069b          	sext.w	a3,a4
    800061a2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800061a6:	9701                	srai	a4,a4,0x20
    800061a8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800061ac:	4705                	li	a4,1
    800061ae:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800061b0:	00e48c23          	sb	a4,24(s1)
    800061b4:	00e48ca3          	sb	a4,25(s1)
    800061b8:	00e48d23          	sb	a4,26(s1)
    800061bc:	00e48da3          	sb	a4,27(s1)
    800061c0:	00e48e23          	sb	a4,28(s1)
    800061c4:	00e48ea3          	sb	a4,29(s1)
    800061c8:	00e48f23          	sb	a4,30(s1)
    800061cc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800061d0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d4:	0727a823          	sw	s2,112(a5)
}
    800061d8:	60e2                	ld	ra,24(sp)
    800061da:	6442                	ld	s0,16(sp)
    800061dc:	64a2                	ld	s1,8(sp)
    800061de:	6902                	ld	s2,0(sp)
    800061e0:	6105                	addi	sp,sp,32
    800061e2:	8082                	ret
    panic("could not find virtio disk");
    800061e4:	00002517          	auipc	a0,0x2
    800061e8:	5ac50513          	addi	a0,a0,1452 # 80008790 <syscalls+0x320>
    800061ec:	ffffa097          	auipc	ra,0xffffa
    800061f0:	352080e7          	jalr	850(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800061f4:	00002517          	auipc	a0,0x2
    800061f8:	5bc50513          	addi	a0,a0,1468 # 800087b0 <syscalls+0x340>
    800061fc:	ffffa097          	auipc	ra,0xffffa
    80006200:	342080e7          	jalr	834(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006204:	00002517          	auipc	a0,0x2
    80006208:	5cc50513          	addi	a0,a0,1484 # 800087d0 <syscalls+0x360>
    8000620c:	ffffa097          	auipc	ra,0xffffa
    80006210:	332080e7          	jalr	818(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006214:	00002517          	auipc	a0,0x2
    80006218:	5dc50513          	addi	a0,a0,1500 # 800087f0 <syscalls+0x380>
    8000621c:	ffffa097          	auipc	ra,0xffffa
    80006220:	322080e7          	jalr	802(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006224:	00002517          	auipc	a0,0x2
    80006228:	5ec50513          	addi	a0,a0,1516 # 80008810 <syscalls+0x3a0>
    8000622c:	ffffa097          	auipc	ra,0xffffa
    80006230:	312080e7          	jalr	786(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006234:	00002517          	auipc	a0,0x2
    80006238:	5fc50513          	addi	a0,a0,1532 # 80008830 <syscalls+0x3c0>
    8000623c:	ffffa097          	auipc	ra,0xffffa
    80006240:	302080e7          	jalr	770(ra) # 8000053e <panic>

0000000080006244 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006244:	7119                	addi	sp,sp,-128
    80006246:	fc86                	sd	ra,120(sp)
    80006248:	f8a2                	sd	s0,112(sp)
    8000624a:	f4a6                	sd	s1,104(sp)
    8000624c:	f0ca                	sd	s2,96(sp)
    8000624e:	ecce                	sd	s3,88(sp)
    80006250:	e8d2                	sd	s4,80(sp)
    80006252:	e4d6                	sd	s5,72(sp)
    80006254:	e0da                	sd	s6,64(sp)
    80006256:	fc5e                	sd	s7,56(sp)
    80006258:	f862                	sd	s8,48(sp)
    8000625a:	f466                	sd	s9,40(sp)
    8000625c:	f06a                	sd	s10,32(sp)
    8000625e:	ec6e                	sd	s11,24(sp)
    80006260:	0100                	addi	s0,sp,128
    80006262:	8aaa                	mv	s5,a0
    80006264:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006266:	00c52d03          	lw	s10,12(a0)
    8000626a:	001d1d1b          	slliw	s10,s10,0x1
    8000626e:	1d02                	slli	s10,s10,0x20
    80006270:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006274:	0001d517          	auipc	a0,0x1d
    80006278:	0f450513          	addi	a0,a0,244 # 80023368 <disk+0x128>
    8000627c:	ffffb097          	auipc	ra,0xffffb
    80006280:	95a080e7          	jalr	-1702(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006284:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006286:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006288:	0001db97          	auipc	s7,0x1d
    8000628c:	fb8b8b93          	addi	s7,s7,-72 # 80023240 <disk>
  for(int i = 0; i < 3; i++){
    80006290:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006292:	0001dc97          	auipc	s9,0x1d
    80006296:	0d6c8c93          	addi	s9,s9,214 # 80023368 <disk+0x128>
    8000629a:	a08d                	j	800062fc <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000629c:	00fb8733          	add	a4,s7,a5
    800062a0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800062a4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800062a6:	0207c563          	bltz	a5,800062d0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800062aa:	2905                	addiw	s2,s2,1
    800062ac:	0611                	addi	a2,a2,4
    800062ae:	05690c63          	beq	s2,s6,80006306 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800062b2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800062b4:	0001d717          	auipc	a4,0x1d
    800062b8:	f8c70713          	addi	a4,a4,-116 # 80023240 <disk>
    800062bc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800062be:	01874683          	lbu	a3,24(a4)
    800062c2:	fee9                	bnez	a3,8000629c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800062c4:	2785                	addiw	a5,a5,1
    800062c6:	0705                	addi	a4,a4,1
    800062c8:	fe979be3          	bne	a5,s1,800062be <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800062cc:	57fd                	li	a5,-1
    800062ce:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800062d0:	01205d63          	blez	s2,800062ea <virtio_disk_rw+0xa6>
    800062d4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800062d6:	000a2503          	lw	a0,0(s4)
    800062da:	00000097          	auipc	ra,0x0
    800062de:	cfc080e7          	jalr	-772(ra) # 80005fd6 <free_desc>
      for(int j = 0; j < i; j++)
    800062e2:	2d85                	addiw	s11,s11,1
    800062e4:	0a11                	addi	s4,s4,4
    800062e6:	ffb918e3          	bne	s2,s11,800062d6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062ea:	85e6                	mv	a1,s9
    800062ec:	0001d517          	auipc	a0,0x1d
    800062f0:	f6c50513          	addi	a0,a0,-148 # 80023258 <disk+0x18>
    800062f4:	ffffc097          	auipc	ra,0xffffc
    800062f8:	df6080e7          	jalr	-522(ra) # 800020ea <sleep>
  for(int i = 0; i < 3; i++){
    800062fc:	f8040a13          	addi	s4,s0,-128
{
    80006300:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006302:	894e                	mv	s2,s3
    80006304:	b77d                	j	800062b2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006306:	f8042583          	lw	a1,-128(s0)
    8000630a:	00a58793          	addi	a5,a1,10
    8000630e:	0792                	slli	a5,a5,0x4

  if(write)
    80006310:	0001d617          	auipc	a2,0x1d
    80006314:	f3060613          	addi	a2,a2,-208 # 80023240 <disk>
    80006318:	00f60733          	add	a4,a2,a5
    8000631c:	018036b3          	snez	a3,s8
    80006320:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006322:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006326:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000632a:	f6078693          	addi	a3,a5,-160
    8000632e:	6218                	ld	a4,0(a2)
    80006330:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006332:	00878513          	addi	a0,a5,8
    80006336:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006338:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000633a:	6208                	ld	a0,0(a2)
    8000633c:	96aa                	add	a3,a3,a0
    8000633e:	4741                	li	a4,16
    80006340:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006342:	4705                	li	a4,1
    80006344:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006348:	f8442703          	lw	a4,-124(s0)
    8000634c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006350:	0712                	slli	a4,a4,0x4
    80006352:	953a                	add	a0,a0,a4
    80006354:	058a8693          	addi	a3,s5,88
    80006358:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000635a:	6208                	ld	a0,0(a2)
    8000635c:	972a                	add	a4,a4,a0
    8000635e:	40000693          	li	a3,1024
    80006362:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006364:	001c3c13          	seqz	s8,s8
    80006368:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000636a:	001c6c13          	ori	s8,s8,1
    8000636e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006372:	f8842603          	lw	a2,-120(s0)
    80006376:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000637a:	0001d697          	auipc	a3,0x1d
    8000637e:	ec668693          	addi	a3,a3,-314 # 80023240 <disk>
    80006382:	00258713          	addi	a4,a1,2
    80006386:	0712                	slli	a4,a4,0x4
    80006388:	9736                	add	a4,a4,a3
    8000638a:	587d                	li	a6,-1
    8000638c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006390:	0612                	slli	a2,a2,0x4
    80006392:	9532                	add	a0,a0,a2
    80006394:	f9078793          	addi	a5,a5,-112
    80006398:	97b6                	add	a5,a5,a3
    8000639a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000639c:	629c                	ld	a5,0(a3)
    8000639e:	97b2                	add	a5,a5,a2
    800063a0:	4605                	li	a2,1
    800063a2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063a4:	4509                	li	a0,2
    800063a6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800063aa:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063ae:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800063b2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063b6:	6698                	ld	a4,8(a3)
    800063b8:	00275783          	lhu	a5,2(a4)
    800063bc:	8b9d                	andi	a5,a5,7
    800063be:	0786                	slli	a5,a5,0x1
    800063c0:	97ba                	add	a5,a5,a4
    800063c2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800063c6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063ca:	6698                	ld	a4,8(a3)
    800063cc:	00275783          	lhu	a5,2(a4)
    800063d0:	2785                	addiw	a5,a5,1
    800063d2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800063d6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063da:	100017b7          	lui	a5,0x10001
    800063de:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063e2:	004aa783          	lw	a5,4(s5)
    800063e6:	02c79163          	bne	a5,a2,80006408 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800063ea:	0001d917          	auipc	s2,0x1d
    800063ee:	f7e90913          	addi	s2,s2,-130 # 80023368 <disk+0x128>
  while(b->disk == 1) {
    800063f2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800063f4:	85ca                	mv	a1,s2
    800063f6:	8556                	mv	a0,s5
    800063f8:	ffffc097          	auipc	ra,0xffffc
    800063fc:	cf2080e7          	jalr	-782(ra) # 800020ea <sleep>
  while(b->disk == 1) {
    80006400:	004aa783          	lw	a5,4(s5)
    80006404:	fe9788e3          	beq	a5,s1,800063f4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006408:	f8042903          	lw	s2,-128(s0)
    8000640c:	00290793          	addi	a5,s2,2
    80006410:	00479713          	slli	a4,a5,0x4
    80006414:	0001d797          	auipc	a5,0x1d
    80006418:	e2c78793          	addi	a5,a5,-468 # 80023240 <disk>
    8000641c:	97ba                	add	a5,a5,a4
    8000641e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006422:	0001d997          	auipc	s3,0x1d
    80006426:	e1e98993          	addi	s3,s3,-482 # 80023240 <disk>
    8000642a:	00491713          	slli	a4,s2,0x4
    8000642e:	0009b783          	ld	a5,0(s3)
    80006432:	97ba                	add	a5,a5,a4
    80006434:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006438:	854a                	mv	a0,s2
    8000643a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000643e:	00000097          	auipc	ra,0x0
    80006442:	b98080e7          	jalr	-1128(ra) # 80005fd6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006446:	8885                	andi	s1,s1,1
    80006448:	f0ed                	bnez	s1,8000642a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000644a:	0001d517          	auipc	a0,0x1d
    8000644e:	f1e50513          	addi	a0,a0,-226 # 80023368 <disk+0x128>
    80006452:	ffffb097          	auipc	ra,0xffffb
    80006456:	838080e7          	jalr	-1992(ra) # 80000c8a <release>
}
    8000645a:	70e6                	ld	ra,120(sp)
    8000645c:	7446                	ld	s0,112(sp)
    8000645e:	74a6                	ld	s1,104(sp)
    80006460:	7906                	ld	s2,96(sp)
    80006462:	69e6                	ld	s3,88(sp)
    80006464:	6a46                	ld	s4,80(sp)
    80006466:	6aa6                	ld	s5,72(sp)
    80006468:	6b06                	ld	s6,64(sp)
    8000646a:	7be2                	ld	s7,56(sp)
    8000646c:	7c42                	ld	s8,48(sp)
    8000646e:	7ca2                	ld	s9,40(sp)
    80006470:	7d02                	ld	s10,32(sp)
    80006472:	6de2                	ld	s11,24(sp)
    80006474:	6109                	addi	sp,sp,128
    80006476:	8082                	ret

0000000080006478 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006478:	1101                	addi	sp,sp,-32
    8000647a:	ec06                	sd	ra,24(sp)
    8000647c:	e822                	sd	s0,16(sp)
    8000647e:	e426                	sd	s1,8(sp)
    80006480:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006482:	0001d497          	auipc	s1,0x1d
    80006486:	dbe48493          	addi	s1,s1,-578 # 80023240 <disk>
    8000648a:	0001d517          	auipc	a0,0x1d
    8000648e:	ede50513          	addi	a0,a0,-290 # 80023368 <disk+0x128>
    80006492:	ffffa097          	auipc	ra,0xffffa
    80006496:	744080e7          	jalr	1860(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000649a:	10001737          	lui	a4,0x10001
    8000649e:	533c                	lw	a5,96(a4)
    800064a0:	8b8d                	andi	a5,a5,3
    800064a2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800064a4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800064a8:	689c                	ld	a5,16(s1)
    800064aa:	0204d703          	lhu	a4,32(s1)
    800064ae:	0027d783          	lhu	a5,2(a5)
    800064b2:	04f70863          	beq	a4,a5,80006502 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800064b6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064ba:	6898                	ld	a4,16(s1)
    800064bc:	0204d783          	lhu	a5,32(s1)
    800064c0:	8b9d                	andi	a5,a5,7
    800064c2:	078e                	slli	a5,a5,0x3
    800064c4:	97ba                	add	a5,a5,a4
    800064c6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800064c8:	00278713          	addi	a4,a5,2
    800064cc:	0712                	slli	a4,a4,0x4
    800064ce:	9726                	add	a4,a4,s1
    800064d0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800064d4:	e721                	bnez	a4,8000651c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800064d6:	0789                	addi	a5,a5,2
    800064d8:	0792                	slli	a5,a5,0x4
    800064da:	97a6                	add	a5,a5,s1
    800064dc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800064de:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064e2:	ffffc097          	auipc	ra,0xffffc
    800064e6:	c88080e7          	jalr	-888(ra) # 8000216a <wakeup>

    disk.used_idx += 1;
    800064ea:	0204d783          	lhu	a5,32(s1)
    800064ee:	2785                	addiw	a5,a5,1
    800064f0:	17c2                	slli	a5,a5,0x30
    800064f2:	93c1                	srli	a5,a5,0x30
    800064f4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064f8:	6898                	ld	a4,16(s1)
    800064fa:	00275703          	lhu	a4,2(a4)
    800064fe:	faf71ce3          	bne	a4,a5,800064b6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006502:	0001d517          	auipc	a0,0x1d
    80006506:	e6650513          	addi	a0,a0,-410 # 80023368 <disk+0x128>
    8000650a:	ffffa097          	auipc	ra,0xffffa
    8000650e:	780080e7          	jalr	1920(ra) # 80000c8a <release>
}
    80006512:	60e2                	ld	ra,24(sp)
    80006514:	6442                	ld	s0,16(sp)
    80006516:	64a2                	ld	s1,8(sp)
    80006518:	6105                	addi	sp,sp,32
    8000651a:	8082                	ret
      panic("virtio_disk_intr status");
    8000651c:	00002517          	auipc	a0,0x2
    80006520:	32c50513          	addi	a0,a0,812 # 80008848 <syscalls+0x3d8>
    80006524:	ffffa097          	auipc	ra,0xffffa
    80006528:	01a080e7          	jalr	26(ra) # 8000053e <panic>
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
