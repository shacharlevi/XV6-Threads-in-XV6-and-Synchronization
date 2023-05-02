
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	88013103          	ld	sp,-1920(sp) # 80008880 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	88e70713          	addi	a4,a4,-1906 # 800088e0 <timer_scratch>
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
    80000068:	e4c78793          	addi	a5,a5,-436 # 80005eb0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb4af>
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
    80000130:	44a080e7          	jalr	1098(ra) # 80002576 <either_copyin>
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
    8000018e:	89650513          	addi	a0,a0,-1898 # 80010a20 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	88648493          	addi	s1,s1,-1914 # 80010a20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	91690913          	addi	s2,s2,-1770 # 80010ab8 <cons+0x98>
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
    800001cc:	1f6080e7          	jalr	502(ra) # 800023be <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	ee6080e7          	jalr	-282(ra) # 800020bc <sleep>
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
    80000216:	30c080e7          	jalr	780(ra) # 8000251e <either_copyout>
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
    80000226:	00010517          	auipc	a0,0x10
    8000022a:	7fa50513          	addi	a0,a0,2042 # 80010a20 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00010517          	auipc	a0,0x10
    80000240:	7e450513          	addi	a0,a0,2020 # 80010a20 <cons>
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
    80000276:	84f72323          	sw	a5,-1978(a4) # 80010ab8 <cons+0x98>
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
    800002d0:	75450513          	addi	a0,a0,1876 # 80010a20 <cons>
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
    800002f6:	2dc080e7          	jalr	732(ra) # 800025ce <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	72650513          	addi	a0,a0,1830 # 80010a20 <cons>
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
    80000322:	70270713          	addi	a4,a4,1794 # 80010a20 <cons>
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
    8000034c:	6d878793          	addi	a5,a5,1752 # 80010a20 <cons>
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
    8000037a:	7427a783          	lw	a5,1858(a5) # 80010ab8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	69670713          	addi	a4,a4,1686 # 80010a20 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	68648493          	addi	s1,s1,1670 # 80010a20 <cons>
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
    800003da:	64a70713          	addi	a4,a4,1610 # 80010a20 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6cf72a23          	sw	a5,1748(a4) # 80010ac0 <cons+0xa0>
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
    80000416:	60e78793          	addi	a5,a5,1550 # 80010a20 <cons>
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
    8000043a:	68c7a323          	sw	a2,1670(a5) # 80010abc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	67a50513          	addi	a0,a0,1658 # 80010ab8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	cda080e7          	jalr	-806(ra) # 80002120 <wakeup>
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
    80000464:	5c050513          	addi	a0,a0,1472 # 80010a20 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	d4078793          	addi	a5,a5,-704 # 800221b8 <devsw>
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
    8000054e:	5807ab23          	sw	zero,1430(a5) # 80010ae0 <pr+0x18>
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
    80000582:	32f72123          	sw	a5,802(a4) # 800088a0 <panicked>
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
    800005be:	526dad83          	lw	s11,1318(s11) # 80010ae0 <pr+0x18>
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
    800005fc:	4d050513          	addi	a0,a0,1232 # 80010ac8 <pr>
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
    8000075a:	37250513          	addi	a0,a0,882 # 80010ac8 <pr>
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
    80000776:	35648493          	addi	s1,s1,854 # 80010ac8 <pr>
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
    800007d6:	31650513          	addi	a0,a0,790 # 80010ae8 <uart_tx_lock>
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
    80000802:	0a27a783          	lw	a5,162(a5) # 800088a0 <panicked>
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
    8000083a:	0727b783          	ld	a5,114(a5) # 800088a8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	07273703          	ld	a4,114(a4) # 800088b0 <uart_tx_w>
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
    80000864:	288a0a13          	addi	s4,s4,648 # 80010ae8 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	04048493          	addi	s1,s1,64 # 800088a8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	04098993          	addi	s3,s3,64 # 800088b0 <uart_tx_w>
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
    80000896:	88e080e7          	jalr	-1906(ra) # 80002120 <wakeup>
    
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
    800008d2:	21a50513          	addi	a0,a0,538 # 80010ae8 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	fc27a783          	lw	a5,-62(a5) # 800088a0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fc873703          	ld	a4,-56(a4) # 800088b0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fb87b783          	ld	a5,-72(a5) # 800088a8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	1ec98993          	addi	s3,s3,492 # 80010ae8 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fa448493          	addi	s1,s1,-92 # 800088a8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fa490913          	addi	s2,s2,-92 # 800088b0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	7a0080e7          	jalr	1952(ra) # 800020bc <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1b648493          	addi	s1,s1,438 # 80010ae8 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f6e7b523          	sd	a4,-150(a5) # 800088b0 <uart_tx_w>
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
    800009c0:	12c48493          	addi	s1,s1,300 # 80010ae8 <uart_tx_lock>
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
    80000a02:	95278793          	addi	a5,a5,-1710 # 80023350 <end>
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
    80000a22:	10290913          	addi	s2,s2,258 # 80010b20 <kmem>
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
    80000abe:	06650513          	addi	a0,a0,102 # 80010b20 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	88250513          	addi	a0,a0,-1918 # 80023350 <end>
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
    80000af4:	03048493          	addi	s1,s1,48 # 80010b20 <kmem>
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
    80000b0c:	01850513          	addi	a0,a0,24 # 80010b20 <kmem>
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
    80000b38:	fec50513          	addi	a0,a0,-20 # 80010b20 <kmem>
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
    80000e8c:	a3070713          	addi	a4,a4,-1488 # 800088b8 <started>
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
    80000ec2:	a2e080e7          	jalr	-1490(ra) # 800028ec <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	02a080e7          	jalr	42(ra) # 80005ef0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fdc080e7          	jalr	-36(ra) # 80001eaa <scheduler>
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
    80000f3a:	98e080e7          	jalr	-1650(ra) # 800028c4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	9ae080e7          	jalr	-1618(ra) # 800028ec <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	f94080e7          	jalr	-108(ra) # 80005eda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	fa2080e7          	jalr	-94(ra) # 80005ef0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	12e080e7          	jalr	302(ra) # 80003084 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	7d2080e7          	jalr	2002(ra) # 80003730 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	770080e7          	jalr	1904(ra) # 800046d6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	08a080e7          	jalr	138(ra) # 80005ff8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	ce0080e7          	jalr	-800(ra) # 80001c56 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	92f72a23          	sw	a5,-1740(a4) # 800088b8 <started>
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
    80000f9c:	9287b783          	ld	a5,-1752(a5) # 800088c0 <kernel_pagetable>
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
    80001258:	66a7b623          	sd	a0,1644(a5) # 800088c0 <kernel_pagetable>
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
    80001852:	72290913          	addi	s2,s2,1826 # 80010f70 <proc>
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
    8000186c:	708a8a93          	addi	s5,s5,1800 # 80017f70 <tickslock>
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
    800018e8:	25c50513          	addi	a0,a0,604 # 80010b40 <pid_lock>
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	25a080e7          	jalr	602(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f4:	00007597          	auipc	a1,0x7
    800018f8:	8f458593          	addi	a1,a1,-1804 # 800081e8 <digits+0x1a8>
    800018fc:	0000f517          	auipc	a0,0xf
    80001900:	25c50513          	addi	a0,a0,604 # 80010b58 <wait_lock>
    80001904:	fffff097          	auipc	ra,0xfffff
    80001908:	242080e7          	jalr	578(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190c:	0000f497          	auipc	s1,0xf
    80001910:	66448493          	addi	s1,s1,1636 # 80010f70 <proc>
     initlock(&p->lock, "proc"); 
    80001914:	00007997          	auipc	s3,0x7
    80001918:	8e498993          	addi	s3,s3,-1820 # 800081f8 <digits+0x1b8>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191c:	00016917          	auipc	s2,0x16
    80001920:	65490913          	addi	s2,s2,1620 # 80017f70 <tickslock>
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
    8000193a:	d46080e7          	jalr	-698(ra) # 8000267c <kthreadinit>
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
    80001974:	20050513          	addi	a0,a0,512 # 80010b70 <cpus>
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
    8000199c:	1a870713          	addi	a4,a4,424 # 80010b40 <pid_lock>
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
    800019cc:	17890913          	addi	s2,s2,376 # 80010b40 <pid_lock>
    800019d0:	854a                	mv	a0,s2
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	204080e7          	jalr	516(ra) # 80000bd6 <acquire>
  pid = nextpid;
    800019da:	00007797          	auipc	a5,0x7
    800019de:	e5a78793          	addi	a5,a5,-422 # 80008834 <nextpid>
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
    80001b12:	d00080e7          	jalr	-768(ra) # 8000280e <freethread>
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
    80001b78:	3fc48493          	addi	s1,s1,1020 # 80010f70 <proc>
    80001b7c:	00016917          	auipc	s2,0x16
    80001b80:	3f490913          	addi	s2,s2,1012 # 80017f70 <tickslock>
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
    80001bd0:	bc2080e7          	jalr	-1086(ra) # 8000278e <allockthread>
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
    80001c6e:	c4a7bf23          	sd	a0,-930(a5) # 800088c8 <initproc>
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c72:	03400613          	li	a2,52
    80001c76:	00007597          	auipc	a1,0x7
    80001c7a:	bca58593          	addi	a1,a1,-1078 # 80008840 <initcode>
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
    80001cca:	40c080e7          	jalr	1036(ra) # 800040d2 <namei>
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
    80001d66:	98c080e7          	jalr	-1652(ra) # 800026ee <mykthread>
    80001d6a:	84aa                	mv	s1,a0
  // Allocate process.
  if((np = allocproc()) == 0){
    80001d6c:	00000097          	auipc	ra,0x0
    80001d70:	dfa080e7          	jalr	-518(ra) # 80001b66 <allocproc>
    80001d74:	12050963          	beqz	a0,80001ea6 <fork+0x160>
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
    80001d8e:	04054763          	bltz	a0,80001ddc <fork+0x96>
    freeproc(np);
    release(&np->kthread[0].t_lock);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;
    80001d92:	0f8ab783          	ld	a5,248(s5)
    80001d96:	0efa3c23          	sd	a5,248(s4) # fffffffffffff0f8 <end+0xffffffff7ffdbda8>
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
    80001dc2:	fed792e3          	bne	a5,a3,80001da6 <fork+0x60>

  // Cause fork to return 0 in the child.
  np->kthread[0].trapframe->a0 = 0;
    80001dc6:	0e0a3783          	ld	a5,224(s4)
    80001dca:	0607b823          	sd	zero,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    80001dce:	108a8493          	addi	s1,s5,264
    80001dd2:	108a0913          	addi	s2,s4,264
    80001dd6:	188a8993          	addi	s3,s5,392
    80001dda:	a03d                	j	80001e08 <fork+0xc2>
    freeproc(np);
    80001ddc:	8552                	mv	a0,s4
    80001dde:	00000097          	auipc	ra,0x0
    80001de2:	d12080e7          	jalr	-750(ra) # 80001af0 <freeproc>
    release(&np->kthread[0].t_lock);
    80001de6:	028a0513          	addi	a0,s4,40
    80001dea:	fffff097          	auipc	ra,0xfffff
    80001dee:	ea0080e7          	jalr	-352(ra) # 80000c8a <release>
    release(&np->lock);
    80001df2:	8552                	mv	a0,s4
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	e96080e7          	jalr	-362(ra) # 80000c8a <release>
    return -1;
    80001dfc:	59fd                	li	s3,-1
    80001dfe:	a851                	j	80001e92 <fork+0x14c>
  for(i = 0; i < NOFILE; i++)
    80001e00:	04a1                	addi	s1,s1,8
    80001e02:	0921                	addi	s2,s2,8
    80001e04:	01348b63          	beq	s1,s3,80001e1a <fork+0xd4>
    if(p->ofile[i])
    80001e08:	6088                	ld	a0,0(s1)
    80001e0a:	d97d                	beqz	a0,80001e00 <fork+0xba>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e0c:	00003097          	auipc	ra,0x3
    80001e10:	95c080e7          	jalr	-1700(ra) # 80004768 <filedup>
    80001e14:	00a93023          	sd	a0,0(s2)
    80001e18:	b7e5                	j	80001e00 <fork+0xba>
  np->cwd = idup(p->cwd);
    80001e1a:	188ab503          	ld	a0,392(s5)
    80001e1e:	00002097          	auipc	ra,0x2
    80001e22:	ad0080e7          	jalr	-1328(ra) # 800038ee <idup>
    80001e26:	18aa3423          	sd	a0,392(s4)

  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e2a:	4641                	li	a2,16
    80001e2c:	190a8593          	addi	a1,s5,400
    80001e30:	190a0513          	addi	a0,s4,400
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	fe8080e7          	jalr	-24(ra) # 80000e1c <safestrcpy>

  pid = np->pid;
    80001e3c:	024a2983          	lw	s3,36(s4)

  release(&np->kthread[0].t_lock);///acqire in allockthread
    80001e40:	028a0493          	addi	s1,s4,40
    80001e44:	8526                	mv	a0,s1
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	e44080e7          	jalr	-444(ra) # 80000c8a <release>
  release(&np->lock);///acqire in allocproc
    80001e4e:	8552                	mv	a0,s4
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	e3a080e7          	jalr	-454(ra) # 80000c8a <release>

  acquire(&wait_lock);
    80001e58:	0000f917          	auipc	s2,0xf
    80001e5c:	d0090913          	addi	s2,s2,-768 # 80010b58 <wait_lock>
    80001e60:	854a                	mv	a0,s2
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	d74080e7          	jalr	-652(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e6a:	0f5a3823          	sd	s5,240(s4)
  release(&wait_lock);
    80001e6e:	854a                	mv	a0,s2
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	e1a080e7          	jalr	-486(ra) # 80000c8a <release>

  // acquire(&np->lock);
  acquire(&np->kthread[0].t_lock);
    80001e78:	8526                	mv	a0,s1
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	d5c080e7          	jalr	-676(ra) # 80000bd6 <acquire>
  np->kthread[0].t_state = RUNNABLE_t;
    80001e82:	478d                	li	a5,3
    80001e84:	04fa2023          	sw	a5,64(s4)
  release(&np->kthread[0].t_lock);
    80001e88:	8526                	mv	a0,s1
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	e00080e7          	jalr	-512(ra) # 80000c8a <release>
  // release(&np->lock);



  return pid;
}
    80001e92:	854e                	mv	a0,s3
    80001e94:	70e2                	ld	ra,56(sp)
    80001e96:	7442                	ld	s0,48(sp)
    80001e98:	74a2                	ld	s1,40(sp)
    80001e9a:	7902                	ld	s2,32(sp)
    80001e9c:	69e2                	ld	s3,24(sp)
    80001e9e:	6a42                	ld	s4,16(sp)
    80001ea0:	6aa2                	ld	s5,8(sp)
    80001ea2:	6121                	addi	sp,sp,64
    80001ea4:	8082                	ret
    return -1;
    80001ea6:	59fd                	li	s3,-1
    80001ea8:	b7ed                	j	80001e92 <fork+0x14c>

0000000080001eaa <scheduler>:
// }


void
scheduler(void)
{
    80001eaa:	715d                	addi	sp,sp,-80
    80001eac:	e486                	sd	ra,72(sp)
    80001eae:	e0a2                	sd	s0,64(sp)
    80001eb0:	fc26                	sd	s1,56(sp)
    80001eb2:	f84a                	sd	s2,48(sp)
    80001eb4:	f44e                	sd	s3,40(sp)
    80001eb6:	f052                	sd	s4,32(sp)
    80001eb8:	ec56                	sd	s5,24(sp)
    80001eba:	e85a                	sd	s6,16(sp)
    80001ebc:	e45e                	sd	s7,8(sp)
    80001ebe:	e062                	sd	s8,0(sp)
    80001ec0:	0880                	addi	s0,sp,80
    80001ec2:	8792                	mv	a5,tp
  int id = r_tp();
    80001ec4:	2781                	sext.w	a5,a5
  struct proc *p;
  struct cpu *c = mycpu();
  c->kthread = 0;
    80001ec6:	00779b93          	slli	s7,a5,0x7
    80001eca:	0000f717          	auipc	a4,0xf
    80001ece:	c7670713          	addi	a4,a4,-906 # 80010b40 <pid_lock>
    80001ed2:	975e                	add	a4,a4,s7
    80001ed4:	02073823          	sd	zero,48(a4)
          acquire(&kt->t_lock);
            if(kt->t_state == RUNNABLE_t) {

              kt->t_state = RUNNING_t;
              c->kthread=kt;
              swtch(&c->context, &kt->context);
    80001ed8:	0000f717          	auipc	a4,0xf
    80001edc:	ca070713          	addi	a4,a4,-864 # 80010b78 <cpus+0x8>
    80001ee0:	9bba                	add	s7,s7,a4
    80001ee2:	00016a17          	auipc	s4,0x16
    80001ee6:	0b6a0a13          	addi	s4,s4,182 # 80017f98 <bcache+0x10>
      if (p->state==USED){
    80001eea:	4985                	li	s3,1
            if(kt->t_state == RUNNABLE_t) {
    80001eec:	4a8d                	li	s5,3
              c->kthread=kt;
    80001eee:	079e                	slli	a5,a5,0x7
    80001ef0:	0000fb17          	auipc	s6,0xf
    80001ef4:	c50b0b13          	addi	s6,s6,-944 # 80010b40 <pid_lock>
    80001ef8:	9b3e                	add	s6,s6,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001efa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001efe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f02:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f06:	0000f497          	auipc	s1,0xf
    80001f0a:	09248493          	addi	s1,s1,146 # 80010f98 <proc+0x28>
              kt->t_state = RUNNING_t;
    80001f0e:	4c11                	li	s8,4
    80001f10:	a811                	j	80001f24 <scheduler+0x7a>
              c->kthread = 0;

            }
        release(&kt->t_lock); // Release the thread lock
    80001f12:	854a                	mv	a0,s2
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	d76080e7          	jalr	-650(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f1c:	1c048493          	addi	s1,s1,448
    80001f20:	fc9a0de3          	beq	s4,s1,80001efa <scheduler+0x50>
      if (p->state==USED){
    80001f24:	8926                	mv	s2,s1
    80001f26:	ff04a783          	lw	a5,-16(s1)
    80001f2a:	ff3799e3          	bne	a5,s3,80001f1c <scheduler+0x72>
          acquire(&kt->t_lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	ca6080e7          	jalr	-858(ra) # 80000bd6 <acquire>
            if(kt->t_state == RUNNABLE_t) {
    80001f38:	4c9c                	lw	a5,24(s1)
    80001f3a:	fd579ce3          	bne	a5,s5,80001f12 <scheduler+0x68>
              kt->t_state = RUNNING_t;
    80001f3e:	0184ac23          	sw	s8,24(s1)
              c->kthread=kt;
    80001f42:	029b3823          	sd	s1,48(s6)
              swtch(&c->context, &kt->context);
    80001f46:	04048593          	addi	a1,s1,64
    80001f4a:	855e                	mv	a0,s7
    80001f4c:	00001097          	auipc	ra,0x1
    80001f50:	90e080e7          	jalr	-1778(ra) # 8000285a <swtch>
              c->kthread = 0;
    80001f54:	020b3823          	sd	zero,48(s6)
    80001f58:	bf6d                	j	80001f12 <scheduler+0x68>

0000000080001f5a <sched>:
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    80001f5a:	7179                	addi	sp,sp,-48
    80001f5c:	f406                	sd	ra,40(sp)
    80001f5e:	f022                	sd	s0,32(sp)
    80001f60:	ec26                	sd	s1,24(sp)
    80001f62:	e84a                	sd	s2,16(sp)
    80001f64:	e44e                	sd	s3,8(sp)
    80001f66:	1800                	addi	s0,sp,48
  int intena;
  struct kthread *t = mykthread();
    80001f68:	00000097          	auipc	ra,0x0
    80001f6c:	786080e7          	jalr	1926(ra) # 800026ee <mykthread>
    80001f70:	84aa                	mv	s1,a0
  if(!holding(&t->t_lock))
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	bea080e7          	jalr	-1046(ra) # 80000b5c <holding>
    80001f7a:	c93d                	beqz	a0,80001ff0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f7c:	8792                	mv	a5,tp
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    80001f7e:	2781                	sext.w	a5,a5
    80001f80:	079e                	slli	a5,a5,0x7
    80001f82:	0000f717          	auipc	a4,0xf
    80001f86:	bbe70713          	addi	a4,a4,-1090 # 80010b40 <pid_lock>
    80001f8a:	97ba                	add	a5,a5,a4
    80001f8c:	0a87a703          	lw	a4,168(a5)
    80001f90:	4785                	li	a5,1
    80001f92:	06f71763          	bne	a4,a5,80002000 <sched+0xa6>
    panic("sched locks");
  if(t->t_state == RUNNING_t)
    80001f96:	4c98                	lw	a4,24(s1)
    80001f98:	4791                	li	a5,4
    80001f9a:	06f70b63          	beq	a4,a5,80002010 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f9e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fa2:	8b89                	andi	a5,a5,2
    panic("sched running");
  if(intr_get())
    80001fa4:	efb5                	bnez	a5,80002020 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fa6:	8792                	mv	a5,tp
    panic("sched interruptible");

  intena = mycpu()->intena;
    80001fa8:	0000f917          	auipc	s2,0xf
    80001fac:	b9890913          	addi	s2,s2,-1128 # 80010b40 <pid_lock>
    80001fb0:	2781                	sext.w	a5,a5
    80001fb2:	079e                	slli	a5,a5,0x7
    80001fb4:	97ca                	add	a5,a5,s2
    80001fb6:	0ac7a983          	lw	s3,172(a5)
    80001fba:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80001fbc:	2781                	sext.w	a5,a5
    80001fbe:	079e                	slli	a5,a5,0x7
    80001fc0:	0000f597          	auipc	a1,0xf
    80001fc4:	bb858593          	addi	a1,a1,-1096 # 80010b78 <cpus+0x8>
    80001fc8:	95be                	add	a1,a1,a5
    80001fca:	04048513          	addi	a0,s1,64
    80001fce:	00001097          	auipc	ra,0x1
    80001fd2:	88c080e7          	jalr	-1908(ra) # 8000285a <swtch>
    80001fd6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fd8:	2781                	sext.w	a5,a5
    80001fda:	079e                	slli	a5,a5,0x7
    80001fdc:	97ca                	add	a5,a5,s2
    80001fde:	0b37a623          	sw	s3,172(a5)
}
    80001fe2:	70a2                	ld	ra,40(sp)
    80001fe4:	7402                	ld	s0,32(sp)
    80001fe6:	64e2                	ld	s1,24(sp)
    80001fe8:	6942                	ld	s2,16(sp)
    80001fea:	69a2                	ld	s3,8(sp)
    80001fec:	6145                	addi	sp,sp,48
    80001fee:	8082                	ret
    panic("sched p->lock");
    80001ff0:	00006517          	auipc	a0,0x6
    80001ff4:	22850513          	addi	a0,a0,552 # 80008218 <digits+0x1d8>
    80001ff8:	ffffe097          	auipc	ra,0xffffe
    80001ffc:	546080e7          	jalr	1350(ra) # 8000053e <panic>
    panic("sched locks");
    80002000:	00006517          	auipc	a0,0x6
    80002004:	22850513          	addi	a0,a0,552 # 80008228 <digits+0x1e8>
    80002008:	ffffe097          	auipc	ra,0xffffe
    8000200c:	536080e7          	jalr	1334(ra) # 8000053e <panic>
    panic("sched running");
    80002010:	00006517          	auipc	a0,0x6
    80002014:	22850513          	addi	a0,a0,552 # 80008238 <digits+0x1f8>
    80002018:	ffffe097          	auipc	ra,0xffffe
    8000201c:	526080e7          	jalr	1318(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002020:	00006517          	auipc	a0,0x6
    80002024:	22850513          	addi	a0,a0,552 # 80008248 <digits+0x208>
    80002028:	ffffe097          	auipc	ra,0xffffe
    8000202c:	516080e7          	jalr	1302(ra) # 8000053e <panic>

0000000080002030 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
    80002030:	1101                	addi	sp,sp,-32
    80002032:	ec06                	sd	ra,24(sp)
    80002034:	e822                	sd	s0,16(sp)
    80002036:	e426                	sd	s1,8(sp)
    80002038:	e04a                	sd	s2,0(sp)
    8000203a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	944080e7          	jalr	-1724(ra) # 80001980 <myproc>
    80002044:	84aa                	mv	s1,a0
  // acquire(&p->lock);
  acquire(&p->kthread[0].t_lock);
    80002046:	02850913          	addi	s2,a0,40
    8000204a:	854a                	mv	a0,s2
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	b8a080e7          	jalr	-1142(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state = RUNNABLE_t;
    80002054:	478d                	li	a5,3
    80002056:	c0bc                	sw	a5,64(s1)
  // release(&p->lock);
     sched();
    80002058:	00000097          	auipc	ra,0x0
    8000205c:	f02080e7          	jalr	-254(ra) # 80001f5a <sched>
  release(&p->kthread[0].t_lock);
    80002060:	854a                	mv	a0,s2
    80002062:	fffff097          	auipc	ra,0xfffff
    80002066:	c28080e7          	jalr	-984(ra) # 80000c8a <release>
 
   

}
    8000206a:	60e2                	ld	ra,24(sp)
    8000206c:	6442                	ld	s0,16(sp)
    8000206e:	64a2                	ld	s1,8(sp)
    80002070:	6902                	ld	s2,0(sp)
    80002072:	6105                	addi	sp,sp,32
    80002074:	8082                	ret

0000000080002076 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80002076:	1141                	addi	sp,sp,-16
    80002078:	e406                	sd	ra,8(sp)
    8000207a:	e022                	sd	s0,0(sp)
    8000207c:	0800                	addi	s0,sp,16
  static int first = 1;
  release(&(mykthread()->t_lock)); //still holding kt->lock from scheduler
    8000207e:	00000097          	auipc	ra,0x0
    80002082:	670080e7          	jalr	1648(ra) # 800026ee <mykthread>
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	c04080e7          	jalr	-1020(ra) # 80000c8a <release>
  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);
  if (first) {
    8000208e:	00006797          	auipc	a5,0x6
    80002092:	7a27a783          	lw	a5,1954(a5) # 80008830 <first.1>
    80002096:	eb89                	bnez	a5,800020a8 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80002098:	00001097          	auipc	ra,0x1
    8000209c:	86c080e7          	jalr	-1940(ra) # 80002904 <usertrapret>
}
    800020a0:	60a2                	ld	ra,8(sp)
    800020a2:	6402                	ld	s0,0(sp)
    800020a4:	0141                	addi	sp,sp,16
    800020a6:	8082                	ret
    first = 0;
    800020a8:	00006797          	auipc	a5,0x6
    800020ac:	7807a423          	sw	zero,1928(a5) # 80008830 <first.1>
    fsinit(ROOTDEV);
    800020b0:	4505                	li	a0,1
    800020b2:	00001097          	auipc	ra,0x1
    800020b6:	5fe080e7          	jalr	1534(ra) # 800036b0 <fsinit>
    800020ba:	bff9                	j	80002098 <forkret+0x22>

00000000800020bc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020bc:	7179                	addi	sp,sp,-48
    800020be:	f406                	sd	ra,40(sp)
    800020c0:	f022                	sd	s0,32(sp)
    800020c2:	ec26                	sd	s1,24(sp)
    800020c4:	e84a                	sd	s2,16(sp)
    800020c6:	e44e                	sd	s3,8(sp)
    800020c8:	1800                	addi	s0,sp,48
    800020ca:	89aa                	mv	s3,a0
    800020cc:	892e                	mv	s2,a1
  struct kthread *kt = mykthread();
    800020ce:	00000097          	auipc	ra,0x0
    800020d2:	620080e7          	jalr	1568(ra) # 800026ee <mykthread>
    800020d6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.
  // acquire(&p->lock);  //DOC: sleeplock1 mayby return
  acquire(&kt->t_lock);
    800020d8:	fffff097          	auipc	ra,0xfffff
    800020dc:	afe080e7          	jalr	-1282(ra) # 80000bd6 <acquire>
  release(lk);
    800020e0:	854a                	mv	a0,s2
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	ba8080e7          	jalr	-1112(ra) # 80000c8a <release>

  // Go to sleep.
  kt->chan = chan;
    800020ea:	0334b023          	sd	s3,32(s1)
  kt->t_state = SLEEPING_t;
    800020ee:	4789                	li	a5,2
    800020f0:	cc9c                	sw	a5,24(s1)

  sched();
    800020f2:	00000097          	auipc	ra,0x0
    800020f6:	e68080e7          	jalr	-408(ra) # 80001f5a <sched>

  // Tidy up.
  kt->chan= 0;
    800020fa:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&kt->t_lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	b8a080e7          	jalr	-1142(ra) # 80000c8a <release>
  // release(&p->lock);//mayby return
  acquire(lk);
    80002108:	854a                	mv	a0,s2
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	acc080e7          	jalr	-1332(ra) # 80000bd6 <acquire>

}
    80002112:	70a2                	ld	ra,40(sp)
    80002114:	7402                	ld	s0,32(sp)
    80002116:	64e2                	ld	s1,24(sp)
    80002118:	6942                	ld	s2,16(sp)
    8000211a:	69a2                	ld	s3,8(sp)
    8000211c:	6145                	addi	sp,sp,48
    8000211e:	8082                	ret

0000000080002120 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002120:	7139                	addi	sp,sp,-64
    80002122:	fc06                	sd	ra,56(sp)
    80002124:	f822                	sd	s0,48(sp)
    80002126:	f426                	sd	s1,40(sp)
    80002128:	f04a                	sd	s2,32(sp)
    8000212a:	ec4e                	sd	s3,24(sp)
    8000212c:	e852                	sd	s4,16(sp)
    8000212e:	e456                	sd	s5,8(sp)
    80002130:	e05a                	sd	s6,0(sp)
    80002132:	0080                	addi	s0,sp,64
    80002134:	8aaa                	mv	s5,a0
  struct proc *p;
  struct kthread *kt;
  for(p = proc; p < &proc[NPROC]; p++) {
    80002136:	0000f497          	auipc	s1,0xf
    8000213a:	e6248493          	addi	s1,s1,-414 # 80010f98 <proc+0x28>
    8000213e:	00016997          	auipc	s3,0x16
    80002142:	e5a98993          	addi	s3,s3,-422 # 80017f98 <bcache+0x10>
    // acquire(&p->lock);
      // acquire(&p->lock);
    for(kt=p->kthread;kt<&p->kthread[NKT];kt++){
        if(kt !=mykthread()){
          acquire(&kt->t_lock);
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    80002146:	4a09                	li	s4,2
          kt->t_state = RUNNABLE_t;
    80002148:	4b0d                	li	s6,3
    8000214a:	a811                	j	8000215e <wakeup+0x3e>
        }
        release(&kt->t_lock);
    8000214c:	854a                	mv	a0,s2
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	b3c080e7          	jalr	-1220(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002156:	1c048493          	addi	s1,s1,448
    8000215a:	02998763          	beq	s3,s1,80002188 <wakeup+0x68>
        if(kt !=mykthread()){
    8000215e:	00000097          	auipc	ra,0x0
    80002162:	590080e7          	jalr	1424(ra) # 800026ee <mykthread>
    80002166:	8926                	mv	s2,s1
    80002168:	fe9507e3          	beq	a0,s1,80002156 <wakeup+0x36>
          acquire(&kt->t_lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	a68080e7          	jalr	-1432(ra) # 80000bd6 <acquire>
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    80002176:	4c9c                	lw	a5,24(s1)
    80002178:	fd479ae3          	bne	a5,s4,8000214c <wakeup+0x2c>
    8000217c:	709c                	ld	a5,32(s1)
    8000217e:	fd5797e3          	bne	a5,s5,8000214c <wakeup+0x2c>
          kt->t_state = RUNNABLE_t;
    80002182:	0164ac23          	sw	s6,24(s1)
    80002186:	b7d9                	j	8000214c <wakeup+0x2c>

       }
    }
    // release(&p->lock);
  }
}
    80002188:	70e2                	ld	ra,56(sp)
    8000218a:	7442                	ld	s0,48(sp)
    8000218c:	74a2                	ld	s1,40(sp)
    8000218e:	7902                	ld	s2,32(sp)
    80002190:	69e2                	ld	s3,24(sp)
    80002192:	6a42                	ld	s4,16(sp)
    80002194:	6aa2                	ld	s5,8(sp)
    80002196:	6b02                	ld	s6,0(sp)
    80002198:	6121                	addi	sp,sp,64
    8000219a:	8082                	ret

000000008000219c <reparent>:
{
    8000219c:	7179                	addi	sp,sp,-48
    8000219e:	f406                	sd	ra,40(sp)
    800021a0:	f022                	sd	s0,32(sp)
    800021a2:	ec26                	sd	s1,24(sp)
    800021a4:	e84a                	sd	s2,16(sp)
    800021a6:	e44e                	sd	s3,8(sp)
    800021a8:	e052                	sd	s4,0(sp)
    800021aa:	1800                	addi	s0,sp,48
    800021ac:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ae:	0000f497          	auipc	s1,0xf
    800021b2:	dc248493          	addi	s1,s1,-574 # 80010f70 <proc>
      pp->parent = initproc;
    800021b6:	00006a17          	auipc	s4,0x6
    800021ba:	712a0a13          	addi	s4,s4,1810 # 800088c8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021be:	00016997          	auipc	s3,0x16
    800021c2:	db298993          	addi	s3,s3,-590 # 80017f70 <tickslock>
    800021c6:	a029                	j	800021d0 <reparent+0x34>
    800021c8:	1c048493          	addi	s1,s1,448
    800021cc:	01348d63          	beq	s1,s3,800021e6 <reparent+0x4a>
    if(pp->parent == p){
    800021d0:	78fc                	ld	a5,240(s1)
    800021d2:	ff279be3          	bne	a5,s2,800021c8 <reparent+0x2c>
      pp->parent = initproc;
    800021d6:	000a3503          	ld	a0,0(s4)
    800021da:	f8e8                	sd	a0,240(s1)
      wakeup(initproc);
    800021dc:	00000097          	auipc	ra,0x0
    800021e0:	f44080e7          	jalr	-188(ra) # 80002120 <wakeup>
    800021e4:	b7d5                	j	800021c8 <reparent+0x2c>
}
    800021e6:	70a2                	ld	ra,40(sp)
    800021e8:	7402                	ld	s0,32(sp)
    800021ea:	64e2                	ld	s1,24(sp)
    800021ec:	6942                	ld	s2,16(sp)
    800021ee:	69a2                	ld	s3,8(sp)
    800021f0:	6a02                	ld	s4,0(sp)
    800021f2:	6145                	addi	sp,sp,48
    800021f4:	8082                	ret

00000000800021f6 <exit>:
{
    800021f6:	7179                	addi	sp,sp,-48
    800021f8:	f406                	sd	ra,40(sp)
    800021fa:	f022                	sd	s0,32(sp)
    800021fc:	ec26                	sd	s1,24(sp)
    800021fe:	e84a                	sd	s2,16(sp)
    80002200:	e44e                	sd	s3,8(sp)
    80002202:	e052                	sd	s4,0(sp)
    80002204:	1800                	addi	s0,sp,48
    80002206:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	778080e7          	jalr	1912(ra) # 80001980 <myproc>
    80002210:	892a                	mv	s2,a0
  if(p == initproc)
    80002212:	00006797          	auipc	a5,0x6
    80002216:	6b67b783          	ld	a5,1718(a5) # 800088c8 <initproc>
    8000221a:	10850493          	addi	s1,a0,264
    8000221e:	18850993          	addi	s3,a0,392
    80002222:	02a79363          	bne	a5,a0,80002248 <exit+0x52>
    panic("init exiting");
    80002226:	00006517          	auipc	a0,0x6
    8000222a:	03a50513          	addi	a0,a0,58 # 80008260 <digits+0x220>
    8000222e:	ffffe097          	auipc	ra,0xffffe
    80002232:	310080e7          	jalr	784(ra) # 8000053e <panic>
      fileclose(f);
    80002236:	00002097          	auipc	ra,0x2
    8000223a:	584080e7          	jalr	1412(ra) # 800047ba <fileclose>
      p->ofile[fd] = 0;
    8000223e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002242:	04a1                	addi	s1,s1,8
    80002244:	00998563          	beq	s3,s1,8000224e <exit+0x58>
    if(p->ofile[fd]){
    80002248:	6088                	ld	a0,0(s1)
    8000224a:	f575                	bnez	a0,80002236 <exit+0x40>
    8000224c:	bfdd                	j	80002242 <exit+0x4c>
  begin_op();
    8000224e:	00002097          	auipc	ra,0x2
    80002252:	0a0080e7          	jalr	160(ra) # 800042ee <begin_op>
  iput(p->cwd);
    80002256:	18893503          	ld	a0,392(s2)
    8000225a:	00002097          	auipc	ra,0x2
    8000225e:	88c080e7          	jalr	-1908(ra) # 80003ae6 <iput>
  end_op();
    80002262:	00002097          	auipc	ra,0x2
    80002266:	10c080e7          	jalr	268(ra) # 8000436e <end_op>
  p->cwd = 0;
    8000226a:	18093423          	sd	zero,392(s2)
  acquire(&wait_lock);
    8000226e:	0000f517          	auipc	a0,0xf
    80002272:	8ea50513          	addi	a0,a0,-1814 # 80010b58 <wait_lock>
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	960080e7          	jalr	-1696(ra) # 80000bd6 <acquire>
  reparent(p);
    8000227e:	854a                	mv	a0,s2
    80002280:	00000097          	auipc	ra,0x0
    80002284:	f1c080e7          	jalr	-228(ra) # 8000219c <reparent>
  wakeup(p->parent);
    80002288:	0f093503          	ld	a0,240(s2)
    8000228c:	00000097          	auipc	ra,0x0
    80002290:	e94080e7          	jalr	-364(ra) # 80002120 <wakeup>
  acquire(&p->lock);
    80002294:	854a                	mv	a0,s2
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	940080e7          	jalr	-1728(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000229e:	03492023          	sw	s4,32(s2)
  p->state = ZOMBIE;
    800022a2:	4789                	li	a5,2
    800022a4:	00f92c23          	sw	a5,24(s2)
  release(&p->lock);
    800022a8:	854a                	mv	a0,s2
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	9e0080e7          	jalr	-1568(ra) # 80000c8a <release>
    acquire(&kt->t_lock);
    800022b2:	02890493          	addi	s1,s2,40
    800022b6:	8526                	mv	a0,s1
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	91e080e7          	jalr	-1762(ra) # 80000bd6 <acquire>
    kt->t_xstate=status;
    800022c0:	05492a23          	sw	s4,84(s2)
    kt->t_state=ZOMBIE_t;
    800022c4:	4795                	li	a5,5
    800022c6:	04f92023          	sw	a5,64(s2)
    if(kt !=mykthread()){
    800022ca:	00000097          	auipc	ra,0x0
    800022ce:	424080e7          	jalr	1060(ra) # 800026ee <mykthread>
    800022d2:	00a48763          	beq	s1,a0,800022e0 <exit+0xea>
      release(&kt->t_lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	9b2080e7          	jalr	-1614(ra) # 80000c8a <release>
  release(&wait_lock);
    800022e0:	0000f517          	auipc	a0,0xf
    800022e4:	87850513          	addi	a0,a0,-1928 # 80010b58 <wait_lock>
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	9a2080e7          	jalr	-1630(ra) # 80000c8a <release>
  sched();
    800022f0:	00000097          	auipc	ra,0x0
    800022f4:	c6a080e7          	jalr	-918(ra) # 80001f5a <sched>
  panic("zombie exit");
    800022f8:	00006517          	auipc	a0,0x6
    800022fc:	f7850513          	addi	a0,a0,-136 # 80008270 <digits+0x230>
    80002300:	ffffe097          	auipc	ra,0xffffe
    80002304:	23e080e7          	jalr	574(ra) # 8000053e <panic>

0000000080002308 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002308:	7179                	addi	sp,sp,-48
    8000230a:	f406                	sd	ra,40(sp)
    8000230c:	f022                	sd	s0,32(sp)
    8000230e:	ec26                	sd	s1,24(sp)
    80002310:	e84a                	sd	s2,16(sp)
    80002312:	e44e                	sd	s3,8(sp)
    80002314:	1800                	addi	s0,sp,48
    80002316:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002318:	0000f497          	auipc	s1,0xf
    8000231c:	c5848493          	addi	s1,s1,-936 # 80010f70 <proc>
    80002320:	00016997          	auipc	s3,0x16
    80002324:	c5098993          	addi	s3,s3,-944 # 80017f70 <tickslock>
    acquire(&p->lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	8ac080e7          	jalr	-1876(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002332:	50dc                	lw	a5,36(s1)
    80002334:	01278d63          	beq	a5,s2,8000234e <kill+0x46>
      // }
      release(&p->lock);
      return 0;
    }
    
    release(&p->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	950080e7          	jalr	-1712(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002342:	1c048493          	addi	s1,s1,448
    80002346:	ff3491e3          	bne	s1,s3,80002328 <kill+0x20>
  }
  return -1;
    8000234a:	557d                	li	a0,-1
    8000234c:	a80d                	j	8000237e <kill+0x76>
      p->killed = 1;
    8000234e:	4785                	li	a5,1
    80002350:	ccdc                	sw	a5,28(s1)
        acquire(&t->t_lock);
    80002352:	02848913          	addi	s2,s1,40
    80002356:	854a                	mv	a0,s2
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	87e080e7          	jalr	-1922(ra) # 80000bd6 <acquire>
        if(t->t_state == SLEEPING_t) {
    80002360:	40b8                	lw	a4,64(s1)
    80002362:	4789                	li	a5,2
    80002364:	02f70463          	beq	a4,a5,8000238c <kill+0x84>
        release(&t->t_lock);
    80002368:	854a                	mv	a0,s2
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	920080e7          	jalr	-1760(ra) # 80000c8a <release>
      release(&p->lock);
    80002372:	8526                	mv	a0,s1
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	916080e7          	jalr	-1770(ra) # 80000c8a <release>
      return 0;
    8000237c:	4501                	li	a0,0
}
    8000237e:	70a2                	ld	ra,40(sp)
    80002380:	7402                	ld	s0,32(sp)
    80002382:	64e2                	ld	s1,24(sp)
    80002384:	6942                	ld	s2,16(sp)
    80002386:	69a2                	ld	s3,8(sp)
    80002388:	6145                	addi	sp,sp,48
    8000238a:	8082                	ret
          t->t_state = RUNNABLE_t;
    8000238c:	478d                	li	a5,3
    8000238e:	c0bc                	sw	a5,64(s1)
    80002390:	bfe1                	j	80002368 <kill+0x60>

0000000080002392 <setkilled>:


void
setkilled(struct proc *p)
{
    80002392:	1101                	addi	sp,sp,-32
    80002394:	ec06                	sd	ra,24(sp)
    80002396:	e822                	sd	s0,16(sp)
    80002398:	e426                	sd	s1,8(sp)
    8000239a:	1000                	addi	s0,sp,32
    8000239c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	838080e7          	jalr	-1992(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800023a6:	4785                	li	a5,1
    800023a8:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    800023aa:	8526                	mv	a0,s1
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	8de080e7          	jalr	-1826(ra) # 80000c8a <release>
}
    800023b4:	60e2                	ld	ra,24(sp)
    800023b6:	6442                	ld	s0,16(sp)
    800023b8:	64a2                	ld	s1,8(sp)
    800023ba:	6105                	addi	sp,sp,32
    800023bc:	8082                	ret

00000000800023be <killed>:

int
killed(struct proc *p)
{
    800023be:	1101                	addi	sp,sp,-32
    800023c0:	ec06                	sd	ra,24(sp)
    800023c2:	e822                	sd	s0,16(sp)
    800023c4:	e426                	sd	s1,8(sp)
    800023c6:	e04a                	sd	s2,0(sp)
    800023c8:	1000                	addi	s0,sp,32
    800023ca:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	80a080e7          	jalr	-2038(ra) # 80000bd6 <acquire>
  k = p->killed;
    800023d4:	01c4a903          	lw	s2,28(s1)
  release(&p->lock);
    800023d8:	8526                	mv	a0,s1
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	8b0080e7          	jalr	-1872(ra) # 80000c8a <release>
  return k;
}
    800023e2:	854a                	mv	a0,s2
    800023e4:	60e2                	ld	ra,24(sp)
    800023e6:	6442                	ld	s0,16(sp)
    800023e8:	64a2                	ld	s1,8(sp)
    800023ea:	6902                	ld	s2,0(sp)
    800023ec:	6105                	addi	sp,sp,32
    800023ee:	8082                	ret

00000000800023f0 <wait>:
{
    800023f0:	715d                	addi	sp,sp,-80
    800023f2:	e486                	sd	ra,72(sp)
    800023f4:	e0a2                	sd	s0,64(sp)
    800023f6:	fc26                	sd	s1,56(sp)
    800023f8:	f84a                	sd	s2,48(sp)
    800023fa:	f44e                	sd	s3,40(sp)
    800023fc:	f052                	sd	s4,32(sp)
    800023fe:	ec56                	sd	s5,24(sp)
    80002400:	e85a                	sd	s6,16(sp)
    80002402:	e45e                	sd	s7,8(sp)
    80002404:	e062                	sd	s8,0(sp)
    80002406:	0880                	addi	s0,sp,80
    80002408:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000240a:	fffff097          	auipc	ra,0xfffff
    8000240e:	576080e7          	jalr	1398(ra) # 80001980 <myproc>
    80002412:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002414:	0000e517          	auipc	a0,0xe
    80002418:	74450513          	addi	a0,a0,1860 # 80010b58 <wait_lock>
    8000241c:	ffffe097          	auipc	ra,0xffffe
    80002420:	7ba080e7          	jalr	1978(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002424:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002426:	4a09                	li	s4,2
        havekids = 1;
    80002428:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000242a:	00016997          	auipc	s3,0x16
    8000242e:	b4698993          	addi	s3,s3,-1210 # 80017f70 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002432:	0000ec17          	auipc	s8,0xe
    80002436:	726c0c13          	addi	s8,s8,1830 # 80010b58 <wait_lock>
    havekids = 0;
    8000243a:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000243c:	0000f497          	auipc	s1,0xf
    80002440:	b3448493          	addi	s1,s1,-1228 # 80010f70 <proc>
    80002444:	a0bd                	j	800024b2 <wait+0xc2>
          pid = pp->pid;
    80002446:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000244a:	000b0e63          	beqz	s6,80002466 <wait+0x76>
    8000244e:	4691                	li	a3,4
    80002450:	02048613          	addi	a2,s1,32
    80002454:	85da                	mv	a1,s6
    80002456:	10093503          	ld	a0,256(s2)
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	20e080e7          	jalr	526(ra) # 80001668 <copyout>
    80002462:	02054563          	bltz	a0,8000248c <wait+0x9c>
          freeproc(pp);
    80002466:	8526                	mv	a0,s1
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	688080e7          	jalr	1672(ra) # 80001af0 <freeproc>
          release(&pp->lock);
    80002470:	8526                	mv	a0,s1
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	818080e7          	jalr	-2024(ra) # 80000c8a <release>
          release(&wait_lock);
    8000247a:	0000e517          	auipc	a0,0xe
    8000247e:	6de50513          	addi	a0,a0,1758 # 80010b58 <wait_lock>
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	808080e7          	jalr	-2040(ra) # 80000c8a <release>
          return pid;
    8000248a:	a0b5                	j	800024f6 <wait+0x106>
            release(&pp->lock);
    8000248c:	8526                	mv	a0,s1
    8000248e:	ffffe097          	auipc	ra,0xffffe
    80002492:	7fc080e7          	jalr	2044(ra) # 80000c8a <release>
            release(&wait_lock);
    80002496:	0000e517          	auipc	a0,0xe
    8000249a:	6c250513          	addi	a0,a0,1730 # 80010b58 <wait_lock>
    8000249e:	ffffe097          	auipc	ra,0xffffe
    800024a2:	7ec080e7          	jalr	2028(ra) # 80000c8a <release>
            return -1;
    800024a6:	59fd                	li	s3,-1
    800024a8:	a0b9                	j	800024f6 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024aa:	1c048493          	addi	s1,s1,448
    800024ae:	03348463          	beq	s1,s3,800024d6 <wait+0xe6>
      if(pp->parent == p){
    800024b2:	78fc                	ld	a5,240(s1)
    800024b4:	ff279be3          	bne	a5,s2,800024aa <wait+0xba>
        acquire(&pp->lock);
    800024b8:	8526                	mv	a0,s1
    800024ba:	ffffe097          	auipc	ra,0xffffe
    800024be:	71c080e7          	jalr	1820(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    800024c2:	4c9c                	lw	a5,24(s1)
    800024c4:	f94781e3          	beq	a5,s4,80002446 <wait+0x56>
        release(&pp->lock);
    800024c8:	8526                	mv	a0,s1
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	7c0080e7          	jalr	1984(ra) # 80000c8a <release>
        havekids = 1;
    800024d2:	8756                	mv	a4,s5
    800024d4:	bfd9                	j	800024aa <wait+0xba>
    if(!havekids || killed(p)){
    800024d6:	c719                	beqz	a4,800024e4 <wait+0xf4>
    800024d8:	854a                	mv	a0,s2
    800024da:	00000097          	auipc	ra,0x0
    800024de:	ee4080e7          	jalr	-284(ra) # 800023be <killed>
    800024e2:	c51d                	beqz	a0,80002510 <wait+0x120>
      release(&wait_lock);
    800024e4:	0000e517          	auipc	a0,0xe
    800024e8:	67450513          	addi	a0,a0,1652 # 80010b58 <wait_lock>
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	79e080e7          	jalr	1950(ra) # 80000c8a <release>
      return -1;
    800024f4:	59fd                	li	s3,-1
}
    800024f6:	854e                	mv	a0,s3
    800024f8:	60a6                	ld	ra,72(sp)
    800024fa:	6406                	ld	s0,64(sp)
    800024fc:	74e2                	ld	s1,56(sp)
    800024fe:	7942                	ld	s2,48(sp)
    80002500:	79a2                	ld	s3,40(sp)
    80002502:	7a02                	ld	s4,32(sp)
    80002504:	6ae2                	ld	s5,24(sp)
    80002506:	6b42                	ld	s6,16(sp)
    80002508:	6ba2                	ld	s7,8(sp)
    8000250a:	6c02                	ld	s8,0(sp)
    8000250c:	6161                	addi	sp,sp,80
    8000250e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002510:	85e2                	mv	a1,s8
    80002512:	854a                	mv	a0,s2
    80002514:	00000097          	auipc	ra,0x0
    80002518:	ba8080e7          	jalr	-1112(ra) # 800020bc <sleep>
    havekids = 0;
    8000251c:	bf39                	j	8000243a <wait+0x4a>

000000008000251e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000251e:	7179                	addi	sp,sp,-48
    80002520:	f406                	sd	ra,40(sp)
    80002522:	f022                	sd	s0,32(sp)
    80002524:	ec26                	sd	s1,24(sp)
    80002526:	e84a                	sd	s2,16(sp)
    80002528:	e44e                	sd	s3,8(sp)
    8000252a:	e052                	sd	s4,0(sp)
    8000252c:	1800                	addi	s0,sp,48
    8000252e:	84aa                	mv	s1,a0
    80002530:	892e                	mv	s2,a1
    80002532:	89b2                	mv	s3,a2
    80002534:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002536:	fffff097          	auipc	ra,0xfffff
    8000253a:	44a080e7          	jalr	1098(ra) # 80001980 <myproc>
  if(user_dst){
    8000253e:	c095                	beqz	s1,80002562 <either_copyout+0x44>
    return copyout(p->pagetable, dst, src, len);
    80002540:	86d2                	mv	a3,s4
    80002542:	864e                	mv	a2,s3
    80002544:	85ca                	mv	a1,s2
    80002546:	10053503          	ld	a0,256(a0)
    8000254a:	fffff097          	auipc	ra,0xfffff
    8000254e:	11e080e7          	jalr	286(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002552:	70a2                	ld	ra,40(sp)
    80002554:	7402                	ld	s0,32(sp)
    80002556:	64e2                	ld	s1,24(sp)
    80002558:	6942                	ld	s2,16(sp)
    8000255a:	69a2                	ld	s3,8(sp)
    8000255c:	6a02                	ld	s4,0(sp)
    8000255e:	6145                	addi	sp,sp,48
    80002560:	8082                	ret
    memmove((char *)dst, src, len);
    80002562:	000a061b          	sext.w	a2,s4
    80002566:	85ce                	mv	a1,s3
    80002568:	854a                	mv	a0,s2
    8000256a:	ffffe097          	auipc	ra,0xffffe
    8000256e:	7c4080e7          	jalr	1988(ra) # 80000d2e <memmove>
    return 0;
    80002572:	8526                	mv	a0,s1
    80002574:	bff9                	j	80002552 <either_copyout+0x34>

0000000080002576 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002576:	7179                	addi	sp,sp,-48
    80002578:	f406                	sd	ra,40(sp)
    8000257a:	f022                	sd	s0,32(sp)
    8000257c:	ec26                	sd	s1,24(sp)
    8000257e:	e84a                	sd	s2,16(sp)
    80002580:	e44e                	sd	s3,8(sp)
    80002582:	e052                	sd	s4,0(sp)
    80002584:	1800                	addi	s0,sp,48
    80002586:	892a                	mv	s2,a0
    80002588:	84ae                	mv	s1,a1
    8000258a:	89b2                	mv	s3,a2
    8000258c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000258e:	fffff097          	auipc	ra,0xfffff
    80002592:	3f2080e7          	jalr	1010(ra) # 80001980 <myproc>
  if(user_src){
    80002596:	c095                	beqz	s1,800025ba <either_copyin+0x44>
    return copyin(p->pagetable, dst, src, len);
    80002598:	86d2                	mv	a3,s4
    8000259a:	864e                	mv	a2,s3
    8000259c:	85ca                	mv	a1,s2
    8000259e:	10053503          	ld	a0,256(a0)
    800025a2:	fffff097          	auipc	ra,0xfffff
    800025a6:	152080e7          	jalr	338(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025aa:	70a2                	ld	ra,40(sp)
    800025ac:	7402                	ld	s0,32(sp)
    800025ae:	64e2                	ld	s1,24(sp)
    800025b0:	6942                	ld	s2,16(sp)
    800025b2:	69a2                	ld	s3,8(sp)
    800025b4:	6a02                	ld	s4,0(sp)
    800025b6:	6145                	addi	sp,sp,48
    800025b8:	8082                	ret
    memmove(dst, (char*)src, len);
    800025ba:	000a061b          	sext.w	a2,s4
    800025be:	85ce                	mv	a1,s3
    800025c0:	854a                	mv	a0,s2
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	76c080e7          	jalr	1900(ra) # 80000d2e <memmove>
    return 0;
    800025ca:	8526                	mv	a0,s1
    800025cc:	bff9                	j	800025aa <either_copyin+0x34>

00000000800025ce <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025ce:	715d                	addi	sp,sp,-80
    800025d0:	e486                	sd	ra,72(sp)
    800025d2:	e0a2                	sd	s0,64(sp)
    800025d4:	fc26                	sd	s1,56(sp)
    800025d6:	f84a                	sd	s2,48(sp)
    800025d8:	f44e                	sd	s3,40(sp)
    800025da:	f052                	sd	s4,32(sp)
    800025dc:	ec56                	sd	s5,24(sp)
    800025de:	e85a                	sd	s6,16(sp)
    800025e0:	e45e                	sd	s7,8(sp)
    800025e2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025e4:	00006517          	auipc	a0,0x6
    800025e8:	ae450513          	addi	a0,a0,-1308 # 800080c8 <digits+0x88>
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	f9c080e7          	jalr	-100(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025f4:	0000f497          	auipc	s1,0xf
    800025f8:	b0c48493          	addi	s1,s1,-1268 # 80011100 <proc+0x190>
    800025fc:	00016917          	auipc	s2,0x16
    80002600:	b0490913          	addi	s2,s2,-1276 # 80018100 <bcache+0x178>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002604:	4b09                	li	s6,2
      state = states[p->state];
    else
      state = "???";
    80002606:	00006997          	auipc	s3,0x6
    8000260a:	c7a98993          	addi	s3,s3,-902 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000260e:	00006a97          	auipc	s5,0x6
    80002612:	c7aa8a93          	addi	s5,s5,-902 # 80008288 <digits+0x248>
    printf("\n");
    80002616:	00006a17          	auipc	s4,0x6
    8000261a:	ab2a0a13          	addi	s4,s4,-1358 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000261e:	00006b97          	auipc	s7,0x6
    80002622:	c92b8b93          	addi	s7,s7,-878 # 800082b0 <states.0>
    80002626:	a00d                	j	80002648 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002628:	e946a583          	lw	a1,-364(a3)
    8000262c:	8556                	mv	a0,s5
    8000262e:	ffffe097          	auipc	ra,0xffffe
    80002632:	f5a080e7          	jalr	-166(ra) # 80000588 <printf>
    printf("\n");
    80002636:	8552                	mv	a0,s4
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	f50080e7          	jalr	-176(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002640:	1c048493          	addi	s1,s1,448
    80002644:	03248163          	beq	s1,s2,80002666 <procdump+0x98>
    if(p->state == UNUSED)
    80002648:	86a6                	mv	a3,s1
    8000264a:	e884a783          	lw	a5,-376(s1)
    8000264e:	dbed                	beqz	a5,80002640 <procdump+0x72>
      state = "???";
    80002650:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002652:	fcfb6be3          	bltu	s6,a5,80002628 <procdump+0x5a>
    80002656:	1782                	slli	a5,a5,0x20
    80002658:	9381                	srli	a5,a5,0x20
    8000265a:	078e                	slli	a5,a5,0x3
    8000265c:	97de                	add	a5,a5,s7
    8000265e:	6390                	ld	a2,0(a5)
    80002660:	f661                	bnez	a2,80002628 <procdump+0x5a>
      state = "???";
    80002662:	864e                	mv	a2,s3
    80002664:	b7d1                	j	80002628 <procdump+0x5a>
  }
}
    80002666:	60a6                	ld	ra,72(sp)
    80002668:	6406                	ld	s0,64(sp)
    8000266a:	74e2                	ld	s1,56(sp)
    8000266c:	7942                	ld	s2,48(sp)
    8000266e:	79a2                	ld	s3,40(sp)
    80002670:	7a02                	ld	s4,32(sp)
    80002672:	6ae2                	ld	s5,24(sp)
    80002674:	6b42                	ld	s6,16(sp)
    80002676:	6ba2                	ld	s7,8(sp)
    80002678:	6161                	addi	sp,sp,80
    8000267a:	8082                	ret

000000008000267c <kthreadinit>:
#include "defs.h"

extern struct proc proc[NPROC];
extern void forkret(void);
void kthreadinit(struct proc *p)
{
    8000267c:	1101                	addi	sp,sp,-32
    8000267e:	ec06                	sd	ra,24(sp)
    80002680:	e822                	sd	s0,16(sp)
    80002682:	e426                	sd	s1,8(sp)
    80002684:	1000                	addi	s0,sp,32
    80002686:	84aa                	mv	s1,a0
  initlock(&(p->alloc_lock),"aloc_thread");
    80002688:	00006597          	auipc	a1,0x6
    8000268c:	c4058593          	addi	a1,a1,-960 # 800082c8 <states.0+0x18>
    80002690:	1a850513          	addi	a0,a0,424
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	4b2080e7          	jalr	1202(ra) # 80000b46 <initlock>
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
    8000269c:	00006597          	auipc	a1,0x6
    800026a0:	c3c58593          	addi	a1,a1,-964 # 800082d8 <states.0+0x28>
    800026a4:	02848513          	addi	a0,s1,40
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	49e080e7          	jalr	1182(ra) # 80000b46 <initlock>
      kt->t_state = UNUSED_t;
    800026b0:	0404a023          	sw	zero,64(s1)
      kt->process=p;
    800026b4:	f0a4                	sd	s1,96(s1)
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    800026b6:	0000f797          	auipc	a5,0xf
    800026ba:	8ba78793          	addi	a5,a5,-1862 # 80010f70 <proc>
    800026be:	40f487b3          	sub	a5,s1,a5
    800026c2:	8799                	srai	a5,a5,0x6
    800026c4:	00006717          	auipc	a4,0x6
    800026c8:	93c73703          	ld	a4,-1732(a4) # 80008000 <etext>
    800026cc:	02e787b3          	mul	a5,a5,a4
    800026d0:	2785                	addiw	a5,a5,1
    800026d2:	00d7979b          	slliw	a5,a5,0xd
    800026d6:	04000737          	lui	a4,0x4000
    800026da:	177d                	addi	a4,a4,-1
    800026dc:	0732                	slli	a4,a4,0xc
    800026de:	40f707b3          	sub	a5,a4,a5
    800026e2:	ecfc                	sd	a5,216(s1)
  }
}
    800026e4:	60e2                	ld	ra,24(sp)
    800026e6:	6442                	ld	s0,16(sp)
    800026e8:	64a2                	ld	s1,8(sp)
    800026ea:	6105                	addi	sp,sp,32
    800026ec:	8082                	ret

00000000800026ee <mykthread>:

struct kthread *mykthread()
{
    800026ee:	1101                	addi	sp,sp,-32
    800026f0:	ec06                	sd	ra,24(sp)
    800026f2:	e822                	sd	s0,16(sp)
    800026f4:	e426                	sd	s1,8(sp)
    800026f6:	1000                	addi	s0,sp,32
  push_off();
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	492080e7          	jalr	1170(ra) # 80000b8a <push_off>
  struct cpu *c = mycpu();
    80002700:	fffff097          	auipc	ra,0xfffff
    80002704:	264080e7          	jalr	612(ra) # 80001964 <mycpu>
  struct kthread *kthread = c->kthread;
    80002708:	6104                	ld	s1,0(a0)
  pop_off();
    8000270a:	ffffe097          	auipc	ra,0xffffe
    8000270e:	520080e7          	jalr	1312(ra) # 80000c2a <pop_off>
  return kthread;
}
    80002712:	8526                	mv	a0,s1
    80002714:	60e2                	ld	ra,24(sp)
    80002716:	6442                	ld	s0,16(sp)
    80002718:	64a2                	ld	s1,8(sp)
    8000271a:	6105                	addi	sp,sp,32
    8000271c:	8082                	ret

000000008000271e <alloctid>:

int alloctid(struct proc *p){
    8000271e:	7179                	addi	sp,sp,-48
    80002720:	f406                	sd	ra,40(sp)
    80002722:	f022                	sd	s0,32(sp)
    80002724:	ec26                	sd	s1,24(sp)
    80002726:	e84a                	sd	s2,16(sp)
    80002728:	e44e                	sd	s3,8(sp)
    8000272a:	1800                	addi	s0,sp,48
    8000272c:	84aa                	mv	s1,a0
  int tid;
  acquire(&(p->alloc_lock));
    8000272e:	1a850993          	addi	s3,a0,424
    80002732:	854e                	mv	a0,s3
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	4a2080e7          	jalr	1186(ra) # 80000bd6 <acquire>
  tid = p->p_counter;
    8000273c:	1a04a903          	lw	s2,416(s1)
  p->p_counter++;
    80002740:	0019079b          	addiw	a5,s2,1
    80002744:	1af4a023          	sw	a5,416(s1)
  release(&(p->alloc_lock));
    80002748:	854e                	mv	a0,s3
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	540080e7          	jalr	1344(ra) # 80000c8a <release>
  return tid;
}
    80002752:	854a                	mv	a0,s2
    80002754:	70a2                	ld	ra,40(sp)
    80002756:	7402                	ld	s0,32(sp)
    80002758:	64e2                	ld	s1,24(sp)
    8000275a:	6942                	ld	s2,16(sp)
    8000275c:	69a2                	ld	s3,8(sp)
    8000275e:	6145                	addi	sp,sp,48
    80002760:	8082                	ret

0000000080002762 <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    80002762:	1141                	addi	sp,sp,-16
    80002764:	e422                	sd	s0,8(sp)
    80002766:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    80002768:	02850793          	addi	a5,a0,40
    8000276c:	8d9d                	sub	a1,a1,a5
    8000276e:	8599                	srai	a1,a1,0x6
    80002770:	00006797          	auipc	a5,0x6
    80002774:	8987b783          	ld	a5,-1896(a5) # 80008008 <etext+0x8>
    80002778:	02f585bb          	mulw	a1,a1,a5
    8000277c:	00359793          	slli	a5,a1,0x3
    80002780:	95be                	add	a1,a1,a5
    80002782:	0596                	slli	a1,a1,0x5
    80002784:	7568                	ld	a0,232(a0)
}
    80002786:	952e                	add	a0,a0,a1
    80002788:	6422                	ld	s0,8(sp)
    8000278a:	0141                	addi	sp,sp,16
    8000278c:	8082                	ret

000000008000278e <allockthread>:

struct kthread* allockthread(struct proc *p){
    8000278e:	1101                	addi	sp,sp,-32
    80002790:	ec06                	sd	ra,24(sp)
    80002792:	e822                	sd	s0,16(sp)
    80002794:	e426                	sd	s1,8(sp)
    80002796:	e04a                	sd	s2,0(sp)
    80002798:	1000                	addi	s0,sp,32
    8000279a:	84aa                	mv	s1,a0
  
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    8000279c:	02850913          	addi	s2,a0,40
    {
      acquire(&kt->t_lock);
    800027a0:	854a                	mv	a0,s2
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	434080e7          	jalr	1076(ra) # 80000bd6 <acquire>
      if(kt->t_state == UNUSED_t) {
    800027aa:	40bc                	lw	a5,64(s1)
    800027ac:	cf91                	beqz	a5,800027c8 <allockthread+0x3a>
        kt->context.ra = (uint64)forkret;
        kt->context.sp = kt->kstack + PGSIZE;
        return kt;
      } 
      else {
        release(&kt->t_lock);
    800027ae:	854a                	mv	a0,s2
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	4da080e7          	jalr	1242(ra) # 80000c8a <release>
      }
  }
  return 0;
    800027b8:	4901                	li	s2,0
}
    800027ba:	854a                	mv	a0,s2
    800027bc:	60e2                	ld	ra,24(sp)
    800027be:	6442                	ld	s0,16(sp)
    800027c0:	64a2                	ld	s1,8(sp)
    800027c2:	6902                	ld	s2,0(sp)
    800027c4:	6105                	addi	sp,sp,32
    800027c6:	8082                	ret
        kt->tid = alloctid(p);
    800027c8:	8526                	mv	a0,s1
    800027ca:	00000097          	auipc	ra,0x0
    800027ce:	f54080e7          	jalr	-172(ra) # 8000271e <alloctid>
    800027d2:	cca8                	sw	a0,88(s1)
        kt->t_state = USED_t;
    800027d4:	4785                	li	a5,1
    800027d6:	c0bc                	sw	a5,64(s1)
        kt->process=p;
    800027d8:	f0a4                	sd	s1,96(s1)
        kt->trapframe = get_kthread_trapframe(p,kt);
    800027da:	85ca                	mv	a1,s2
    800027dc:	8526                	mv	a0,s1
    800027de:	00000097          	auipc	ra,0x0
    800027e2:	f84080e7          	jalr	-124(ra) # 80002762 <get_kthread_trapframe>
    800027e6:	f0e8                	sd	a0,224(s1)
        memset(&kt->context, 0, sizeof(kt->context));   
    800027e8:	07000613          	li	a2,112
    800027ec:	4581                	li	a1,0
    800027ee:	06848513          	addi	a0,s1,104
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	4e0080e7          	jalr	1248(ra) # 80000cd2 <memset>
        kt->context.ra = (uint64)forkret;
    800027fa:	00000797          	auipc	a5,0x0
    800027fe:	87c78793          	addi	a5,a5,-1924 # 80002076 <forkret>
    80002802:	f4bc                	sd	a5,104(s1)
        kt->context.sp = kt->kstack + PGSIZE;
    80002804:	6cfc                	ld	a5,216(s1)
    80002806:	6705                	lui	a4,0x1
    80002808:	97ba                	add	a5,a5,a4
    8000280a:	f8bc                	sd	a5,112(s1)
        return kt;
    8000280c:	b77d                	j	800027ba <allockthread+0x2c>

000000008000280e <freethread>:

void
freethread(struct kthread *t){
    8000280e:	1101                	addi	sp,sp,-32
    80002810:	ec06                	sd	ra,24(sp)
    80002812:	e822                	sd	s0,16(sp)
    80002814:	e426                	sd	s1,8(sp)
    80002816:	1000                	addi	s0,sp,32
    80002818:	84aa                	mv	s1,a0
  t->chan = 0;//
    8000281a:	02053023          	sd	zero,32(a0)
  t->t_killed = 0;//
    8000281e:	02052423          	sw	zero,40(a0)
  t->t_xstate = 0;//
    80002822:	02052623          	sw	zero,44(a0)
  t->t_state = UNUSED_t;//
    80002826:	00052c23          	sw	zero,24(a0)
  t->tid=0;//
    8000282a:	02052823          	sw	zero,48(a0)
  t->process=0;//
    8000282e:	02053c23          	sd	zero,56(a0)
  // t->kstack=0;
  // if(t->trapframe)
  //   kfree((void*)t->trapframe);
  t->trapframe = 0;//
    80002832:	0a053c23          	sd	zero,184(a0)
  memset(&t->context,0,sizeof(&t->context));//
    80002836:	4621                	li	a2,8
    80002838:	4581                	li	a1,0
    8000283a:	04050513          	addi	a0,a0,64
    8000283e:	ffffe097          	auipc	ra,0xffffe
    80002842:	494080e7          	jalr	1172(ra) # 80000cd2 <memset>
  release(&t->t_lock);
    80002846:	8526                	mv	a0,s1
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	442080e7          	jalr	1090(ra) # 80000c8a <release>
}
    80002850:	60e2                	ld	ra,24(sp)
    80002852:	6442                	ld	s0,16(sp)
    80002854:	64a2                	ld	s1,8(sp)
    80002856:	6105                	addi	sp,sp,32
    80002858:	8082                	ret

000000008000285a <swtch>:
    8000285a:	00153023          	sd	ra,0(a0)
    8000285e:	00253423          	sd	sp,8(a0)
    80002862:	e900                	sd	s0,16(a0)
    80002864:	ed04                	sd	s1,24(a0)
    80002866:	03253023          	sd	s2,32(a0)
    8000286a:	03353423          	sd	s3,40(a0)
    8000286e:	03453823          	sd	s4,48(a0)
    80002872:	03553c23          	sd	s5,56(a0)
    80002876:	05653023          	sd	s6,64(a0)
    8000287a:	05753423          	sd	s7,72(a0)
    8000287e:	05853823          	sd	s8,80(a0)
    80002882:	05953c23          	sd	s9,88(a0)
    80002886:	07a53023          	sd	s10,96(a0)
    8000288a:	07b53423          	sd	s11,104(a0)
    8000288e:	0005b083          	ld	ra,0(a1)
    80002892:	0085b103          	ld	sp,8(a1)
    80002896:	6980                	ld	s0,16(a1)
    80002898:	6d84                	ld	s1,24(a1)
    8000289a:	0205b903          	ld	s2,32(a1)
    8000289e:	0285b983          	ld	s3,40(a1)
    800028a2:	0305ba03          	ld	s4,48(a1)
    800028a6:	0385ba83          	ld	s5,56(a1)
    800028aa:	0405bb03          	ld	s6,64(a1)
    800028ae:	0485bb83          	ld	s7,72(a1)
    800028b2:	0505bc03          	ld	s8,80(a1)
    800028b6:	0585bc83          	ld	s9,88(a1)
    800028ba:	0605bd03          	ld	s10,96(a1)
    800028be:	0685bd83          	ld	s11,104(a1)
    800028c2:	8082                	ret

00000000800028c4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028c4:	1141                	addi	sp,sp,-16
    800028c6:	e406                	sd	ra,8(sp)
    800028c8:	e022                	sd	s0,0(sp)
    800028ca:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028cc:	00006597          	auipc	a1,0x6
    800028d0:	a1c58593          	addi	a1,a1,-1508 # 800082e8 <states.0+0x38>
    800028d4:	00015517          	auipc	a0,0x15
    800028d8:	69c50513          	addi	a0,a0,1692 # 80017f70 <tickslock>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	26a080e7          	jalr	618(ra) # 80000b46 <initlock>
}
    800028e4:	60a2                	ld	ra,8(sp)
    800028e6:	6402                	ld	s0,0(sp)
    800028e8:	0141                	addi	sp,sp,16
    800028ea:	8082                	ret

00000000800028ec <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028ec:	1141                	addi	sp,sp,-16
    800028ee:	e422                	sd	s0,8(sp)
    800028f0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f2:	00003797          	auipc	a5,0x3
    800028f6:	52e78793          	addi	a5,a5,1326 # 80005e20 <kernelvec>
    800028fa:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028fe:	6422                	ld	s0,8(sp)
    80002900:	0141                	addi	sp,sp,16
    80002902:	8082                	ret

0000000080002904 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002904:	1101                	addi	sp,sp,-32
    80002906:	ec06                	sd	ra,24(sp)
    80002908:	e822                	sd	s0,16(sp)
    8000290a:	e426                	sd	s1,8(sp)
    8000290c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000290e:	fffff097          	auipc	ra,0xfffff
    80002912:	072080e7          	jalr	114(ra) # 80001980 <myproc>
    80002916:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002918:	00000097          	auipc	ra,0x0
    8000291c:	dd6080e7          	jalr	-554(ra) # 800026ee <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002920:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002924:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002926:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000292a:	00004617          	auipc	a2,0x4
    8000292e:	6d660613          	addi	a2,a2,1750 # 80007000 <_trampoline>
    80002932:	00004697          	auipc	a3,0x4
    80002936:	6ce68693          	addi	a3,a3,1742 # 80007000 <_trampoline>
    8000293a:	8e91                	sub	a3,a3,a2
    8000293c:	040007b7          	lui	a5,0x4000
    80002940:	17fd                	addi	a5,a5,-1
    80002942:	07b2                	slli	a5,a5,0xc
    80002944:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002946:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    8000294a:	7d58                	ld	a4,184(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000294c:	180026f3          	csrr	a3,satp
    80002950:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    80002952:	7d58                	ld	a4,184(a0)
    80002954:	7954                	ld	a3,176(a0)
    80002956:	6585                	lui	a1,0x1
    80002958:	96ae                	add	a3,a3,a1
    8000295a:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    8000295c:	7d58                	ld	a4,184(a0)
    8000295e:	00000697          	auipc	a3,0x0
    80002962:	15e68693          	addi	a3,a3,350 # 80002abc <usertrap>
    80002966:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002968:	7d58                	ld	a4,184(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000296a:	8692                	mv	a3,tp
    8000296c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002972:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002976:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000297a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    8000297e:	7d58                	ld	a4,184(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002980:	6f18                	ld	a4,24(a4)
    80002982:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002986:	1004b583          	ld	a1,256(s1)
    8000298a:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    8000298c:	02848493          	addi	s1,s1,40
    80002990:	8d05                	sub	a0,a0,s1
    80002992:	8519                	srai	a0,a0,0x6
    80002994:	00005717          	auipc	a4,0x5
    80002998:	67473703          	ld	a4,1652(a4) # 80008008 <etext+0x8>
    8000299c:	02e50533          	mul	a0,a0,a4
    800029a0:	1502                	slli	a0,a0,0x20
    800029a2:	9101                	srli	a0,a0,0x20
    800029a4:	00351693          	slli	a3,a0,0x3
    800029a8:	9536                	add	a0,a0,a3
    800029aa:	0516                	slli	a0,a0,0x5
    800029ac:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800029b0:	00004717          	auipc	a4,0x4
    800029b4:	6e470713          	addi	a4,a4,1764 # 80007094 <userret>
    800029b8:	8f11                	sub	a4,a4,a2
    800029ba:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    800029bc:	577d                	li	a4,-1
    800029be:	177e                	slli	a4,a4,0x3f
    800029c0:	8dd9                	or	a1,a1,a4
    800029c2:	16fd                	addi	a3,a3,-1
    800029c4:	06b6                	slli	a3,a3,0xd
    800029c6:	9536                	add	a0,a0,a3
    800029c8:	9782                	jalr	a5
}
    800029ca:	60e2                	ld	ra,24(sp)
    800029cc:	6442                	ld	s0,16(sp)
    800029ce:	64a2                	ld	s1,8(sp)
    800029d0:	6105                	addi	sp,sp,32
    800029d2:	8082                	ret

00000000800029d4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029d4:	1101                	addi	sp,sp,-32
    800029d6:	ec06                	sd	ra,24(sp)
    800029d8:	e822                	sd	s0,16(sp)
    800029da:	e426                	sd	s1,8(sp)
    800029dc:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029de:	00015497          	auipc	s1,0x15
    800029e2:	59248493          	addi	s1,s1,1426 # 80017f70 <tickslock>
    800029e6:	8526                	mv	a0,s1
    800029e8:	ffffe097          	auipc	ra,0xffffe
    800029ec:	1ee080e7          	jalr	494(ra) # 80000bd6 <acquire>
  ticks++;
    800029f0:	00006517          	auipc	a0,0x6
    800029f4:	ee050513          	addi	a0,a0,-288 # 800088d0 <ticks>
    800029f8:	411c                	lw	a5,0(a0)
    800029fa:	2785                	addiw	a5,a5,1
    800029fc:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029fe:	fffff097          	auipc	ra,0xfffff
    80002a02:	722080e7          	jalr	1826(ra) # 80002120 <wakeup>
  release(&tickslock);
    80002a06:	8526                	mv	a0,s1
    80002a08:	ffffe097          	auipc	ra,0xffffe
    80002a0c:	282080e7          	jalr	642(ra) # 80000c8a <release>
}
    80002a10:	60e2                	ld	ra,24(sp)
    80002a12:	6442                	ld	s0,16(sp)
    80002a14:	64a2                	ld	s1,8(sp)
    80002a16:	6105                	addi	sp,sp,32
    80002a18:	8082                	ret

0000000080002a1a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a1a:	1101                	addi	sp,sp,-32
    80002a1c:	ec06                	sd	ra,24(sp)
    80002a1e:	e822                	sd	s0,16(sp)
    80002a20:	e426                	sd	s1,8(sp)
    80002a22:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a24:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a28:	00074d63          	bltz	a4,80002a42 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a2c:	57fd                	li	a5,-1
    80002a2e:	17fe                	slli	a5,a5,0x3f
    80002a30:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a32:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a34:	06f70363          	beq	a4,a5,80002a9a <devintr+0x80>
  }
}
    80002a38:	60e2                	ld	ra,24(sp)
    80002a3a:	6442                	ld	s0,16(sp)
    80002a3c:	64a2                	ld	s1,8(sp)
    80002a3e:	6105                	addi	sp,sp,32
    80002a40:	8082                	ret
     (scause & 0xff) == 9){
    80002a42:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a46:	46a5                	li	a3,9
    80002a48:	fed792e3          	bne	a5,a3,80002a2c <devintr+0x12>
    int irq = plic_claim();
    80002a4c:	00003097          	auipc	ra,0x3
    80002a50:	4dc080e7          	jalr	1244(ra) # 80005f28 <plic_claim>
    80002a54:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a56:	47a9                	li	a5,10
    80002a58:	02f50763          	beq	a0,a5,80002a86 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a5c:	4785                	li	a5,1
    80002a5e:	02f50963          	beq	a0,a5,80002a90 <devintr+0x76>
    return 1;
    80002a62:	4505                	li	a0,1
    } else if(irq){
    80002a64:	d8f1                	beqz	s1,80002a38 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a66:	85a6                	mv	a1,s1
    80002a68:	00006517          	auipc	a0,0x6
    80002a6c:	88850513          	addi	a0,a0,-1912 # 800082f0 <states.0+0x40>
    80002a70:	ffffe097          	auipc	ra,0xffffe
    80002a74:	b18080e7          	jalr	-1256(ra) # 80000588 <printf>
      plic_complete(irq);
    80002a78:	8526                	mv	a0,s1
    80002a7a:	00003097          	auipc	ra,0x3
    80002a7e:	4d2080e7          	jalr	1234(ra) # 80005f4c <plic_complete>
    return 1;
    80002a82:	4505                	li	a0,1
    80002a84:	bf55                	j	80002a38 <devintr+0x1e>
      uartintr();
    80002a86:	ffffe097          	auipc	ra,0xffffe
    80002a8a:	f14080e7          	jalr	-236(ra) # 8000099a <uartintr>
    80002a8e:	b7ed                	j	80002a78 <devintr+0x5e>
      virtio_disk_intr();
    80002a90:	00004097          	auipc	ra,0x4
    80002a94:	988080e7          	jalr	-1656(ra) # 80006418 <virtio_disk_intr>
    80002a98:	b7c5                	j	80002a78 <devintr+0x5e>
    if(cpuid() == 0){
    80002a9a:	fffff097          	auipc	ra,0xfffff
    80002a9e:	eba080e7          	jalr	-326(ra) # 80001954 <cpuid>
    80002aa2:	c901                	beqz	a0,80002ab2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002aa4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002aa8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002aaa:	14479073          	csrw	sip,a5
    return 2;
    80002aae:	4509                	li	a0,2
    80002ab0:	b761                	j	80002a38 <devintr+0x1e>
      clockintr();
    80002ab2:	00000097          	auipc	ra,0x0
    80002ab6:	f22080e7          	jalr	-222(ra) # 800029d4 <clockintr>
    80002aba:	b7ed                	j	80002aa4 <devintr+0x8a>

0000000080002abc <usertrap>:
{
    80002abc:	1101                	addi	sp,sp,-32
    80002abe:	ec06                	sd	ra,24(sp)
    80002ac0:	e822                	sd	s0,16(sp)
    80002ac2:	e426                	sd	s1,8(sp)
    80002ac4:	e04a                	sd	s2,0(sp)
    80002ac6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ac8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002acc:	1007f793          	andi	a5,a5,256
    80002ad0:	e7b9                	bnez	a5,80002b1e <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ad2:	00003797          	auipc	a5,0x3
    80002ad6:	34e78793          	addi	a5,a5,846 # 80005e20 <kernelvec>
    80002ada:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ade:	fffff097          	auipc	ra,0xfffff
    80002ae2:	ea2080e7          	jalr	-350(ra) # 80001980 <myproc>
    80002ae6:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002ae8:	00000097          	auipc	ra,0x0
    80002aec:	c06080e7          	jalr	-1018(ra) # 800026ee <mykthread>
    80002af0:	892a                	mv	s2,a0
  kt->trapframe->epc = r_sepc();
    80002af2:	7d5c                	ld	a5,184(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002af4:	14102773          	csrr	a4,sepc
    80002af8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002afa:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002afe:	47a1                	li	a5,8
    80002b00:	02f70763          	beq	a4,a5,80002b2e <usertrap+0x72>
  } else if((which_dev = devintr()) != 0){
    80002b04:	00000097          	auipc	ra,0x0
    80002b08:	f16080e7          	jalr	-234(ra) # 80002a1a <devintr>
    80002b0c:	892a                	mv	s2,a0
    80002b0e:	c541                	beqz	a0,80002b96 <usertrap+0xda>
  if(killed(p))
    80002b10:	8526                	mv	a0,s1
    80002b12:	00000097          	auipc	ra,0x0
    80002b16:	8ac080e7          	jalr	-1876(ra) # 800023be <killed>
    80002b1a:	c939                	beqz	a0,80002b70 <usertrap+0xb4>
    80002b1c:	a0a9                	j	80002b66 <usertrap+0xaa>
    panic("usertrap: not from user mode");
    80002b1e:	00005517          	auipc	a0,0x5
    80002b22:	7f250513          	addi	a0,a0,2034 # 80008310 <states.0+0x60>
    80002b26:	ffffe097          	auipc	ra,0xffffe
    80002b2a:	a18080e7          	jalr	-1512(ra) # 8000053e <panic>
    if(killed(p))
    80002b2e:	8526                	mv	a0,s1
    80002b30:	00000097          	auipc	ra,0x0
    80002b34:	88e080e7          	jalr	-1906(ra) # 800023be <killed>
    80002b38:	e929                	bnez	a0,80002b8a <usertrap+0xce>
    kt->trapframe->epc += 4;
    80002b3a:	0b893703          	ld	a4,184(s2)
    80002b3e:	6f1c                	ld	a5,24(a4)
    80002b40:	0791                	addi	a5,a5,4
    80002b42:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b44:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b48:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b4c:	10079073          	csrw	sstatus,a5
    syscall();
    80002b50:	00000097          	auipc	ra,0x0
    80002b54:	2d8080e7          	jalr	728(ra) # 80002e28 <syscall>
  if(killed(p))
    80002b58:	8526                	mv	a0,s1
    80002b5a:	00000097          	auipc	ra,0x0
    80002b5e:	864080e7          	jalr	-1948(ra) # 800023be <killed>
    80002b62:	c911                	beqz	a0,80002b76 <usertrap+0xba>
    80002b64:	4901                	li	s2,0
    exit(-1);
    80002b66:	557d                	li	a0,-1
    80002b68:	fffff097          	auipc	ra,0xfffff
    80002b6c:	68e080e7          	jalr	1678(ra) # 800021f6 <exit>
  if(which_dev == 2)
    80002b70:	4789                	li	a5,2
    80002b72:	04f90f63          	beq	s2,a5,80002bd0 <usertrap+0x114>
  usertrapret();
    80002b76:	00000097          	auipc	ra,0x0
    80002b7a:	d8e080e7          	jalr	-626(ra) # 80002904 <usertrapret>
}
    80002b7e:	60e2                	ld	ra,24(sp)
    80002b80:	6442                	ld	s0,16(sp)
    80002b82:	64a2                	ld	s1,8(sp)
    80002b84:	6902                	ld	s2,0(sp)
    80002b86:	6105                	addi	sp,sp,32
    80002b88:	8082                	ret
      exit(-1);
    80002b8a:	557d                	li	a0,-1
    80002b8c:	fffff097          	auipc	ra,0xfffff
    80002b90:	66a080e7          	jalr	1642(ra) # 800021f6 <exit>
    80002b94:	b75d                	j	80002b3a <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b96:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b9a:	50d0                	lw	a2,36(s1)
    80002b9c:	00005517          	auipc	a0,0x5
    80002ba0:	79450513          	addi	a0,a0,1940 # 80008330 <states.0+0x80>
    80002ba4:	ffffe097          	auipc	ra,0xffffe
    80002ba8:	9e4080e7          	jalr	-1564(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bac:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bb0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bb4:	00005517          	auipc	a0,0x5
    80002bb8:	7ac50513          	addi	a0,a0,1964 # 80008360 <states.0+0xb0>
    80002bbc:	ffffe097          	auipc	ra,0xffffe
    80002bc0:	9cc080e7          	jalr	-1588(ra) # 80000588 <printf>
    setkilled(p);
    80002bc4:	8526                	mv	a0,s1
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	7cc080e7          	jalr	1996(ra) # 80002392 <setkilled>
    80002bce:	b769                	j	80002b58 <usertrap+0x9c>
    yield();
    80002bd0:	fffff097          	auipc	ra,0xfffff
    80002bd4:	460080e7          	jalr	1120(ra) # 80002030 <yield>
    80002bd8:	bf79                	j	80002b76 <usertrap+0xba>

0000000080002bda <kerneltrap>:
{
    80002bda:	7179                	addi	sp,sp,-48
    80002bdc:	f406                	sd	ra,40(sp)
    80002bde:	f022                	sd	s0,32(sp)
    80002be0:	ec26                	sd	s1,24(sp)
    80002be2:	e84a                	sd	s2,16(sp)
    80002be4:	e44e                	sd	s3,8(sp)
    80002be6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bec:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bf4:	1004f793          	andi	a5,s1,256
    80002bf8:	cb85                	beqz	a5,80002c28 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bfa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bfe:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c00:	ef85                	bnez	a5,80002c38 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c02:	00000097          	auipc	ra,0x0
    80002c06:	e18080e7          	jalr	-488(ra) # 80002a1a <devintr>
    80002c0a:	cd1d                	beqz	a0,80002c48 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002c0c:	4789                	li	a5,2
    80002c0e:	06f50a63          	beq	a0,a5,80002c82 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c12:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c16:	10049073          	csrw	sstatus,s1
}
    80002c1a:	70a2                	ld	ra,40(sp)
    80002c1c:	7402                	ld	s0,32(sp)
    80002c1e:	64e2                	ld	s1,24(sp)
    80002c20:	6942                	ld	s2,16(sp)
    80002c22:	69a2                	ld	s3,8(sp)
    80002c24:	6145                	addi	sp,sp,48
    80002c26:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	75850513          	addi	a0,a0,1880 # 80008380 <states.0+0xd0>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002c38:	00005517          	auipc	a0,0x5
    80002c3c:	77050513          	addi	a0,a0,1904 # 800083a8 <states.0+0xf8>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	8fe080e7          	jalr	-1794(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002c48:	85ce                	mv	a1,s3
    80002c4a:	00005517          	auipc	a0,0x5
    80002c4e:	77e50513          	addi	a0,a0,1918 # 800083c8 <states.0+0x118>
    80002c52:	ffffe097          	auipc	ra,0xffffe
    80002c56:	936080e7          	jalr	-1738(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c5a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c5e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c62:	00005517          	auipc	a0,0x5
    80002c66:	77650513          	addi	a0,a0,1910 # 800083d8 <states.0+0x128>
    80002c6a:	ffffe097          	auipc	ra,0xffffe
    80002c6e:	91e080e7          	jalr	-1762(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002c72:	00005517          	auipc	a0,0x5
    80002c76:	77e50513          	addi	a0,a0,1918 # 800083f0 <states.0+0x140>
    80002c7a:	ffffe097          	auipc	ra,0xffffe
    80002c7e:	8c4080e7          	jalr	-1852(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	cfe080e7          	jalr	-770(ra) # 80001980 <myproc>
    80002c8a:	d541                	beqz	a0,80002c12 <kerneltrap+0x38>
    80002c8c:	fffff097          	auipc	ra,0xfffff
    80002c90:	cf4080e7          	jalr	-780(ra) # 80001980 <myproc>
    80002c94:	4138                	lw	a4,64(a0)
    80002c96:	4791                	li	a5,4
    80002c98:	f6f71de3          	bne	a4,a5,80002c12 <kerneltrap+0x38>
    yield();
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	394080e7          	jalr	916(ra) # 80002030 <yield>
    80002ca4:	b7bd                	j	80002c12 <kerneltrap+0x38>

0000000080002ca6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ca6:	1101                	addi	sp,sp,-32
    80002ca8:	ec06                	sd	ra,24(sp)
    80002caa:	e822                	sd	s0,16(sp)
    80002cac:	e426                	sd	s1,8(sp)
    80002cae:	1000                	addi	s0,sp,32
    80002cb0:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    80002cb2:	00000097          	auipc	ra,0x0
    80002cb6:	a3c080e7          	jalr	-1476(ra) # 800026ee <mykthread>
  switch (n) {
    80002cba:	4795                	li	a5,5
    80002cbc:	0497e163          	bltu	a5,s1,80002cfe <argraw+0x58>
    80002cc0:	048a                	slli	s1,s1,0x2
    80002cc2:	00005717          	auipc	a4,0x5
    80002cc6:	76670713          	addi	a4,a4,1894 # 80008428 <states.0+0x178>
    80002cca:	94ba                	add	s1,s1,a4
    80002ccc:	409c                	lw	a5,0(s1)
    80002cce:	97ba                	add	a5,a5,a4
    80002cd0:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    80002cd2:	7d5c                	ld	a5,184(a0)
    80002cd4:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cd6:	60e2                	ld	ra,24(sp)
    80002cd8:	6442                	ld	s0,16(sp)
    80002cda:	64a2                	ld	s1,8(sp)
    80002cdc:	6105                	addi	sp,sp,32
    80002cde:	8082                	ret
    return kt->trapframe->a1;
    80002ce0:	7d5c                	ld	a5,184(a0)
    80002ce2:	7fa8                	ld	a0,120(a5)
    80002ce4:	bfcd                	j	80002cd6 <argraw+0x30>
    return kt->trapframe->a2;
    80002ce6:	7d5c                	ld	a5,184(a0)
    80002ce8:	63c8                	ld	a0,128(a5)
    80002cea:	b7f5                	j	80002cd6 <argraw+0x30>
    return kt->trapframe->a3;
    80002cec:	7d5c                	ld	a5,184(a0)
    80002cee:	67c8                	ld	a0,136(a5)
    80002cf0:	b7dd                	j	80002cd6 <argraw+0x30>
    return kt->trapframe->a4;
    80002cf2:	7d5c                	ld	a5,184(a0)
    80002cf4:	6bc8                	ld	a0,144(a5)
    80002cf6:	b7c5                	j	80002cd6 <argraw+0x30>
    return kt->trapframe->a5;
    80002cf8:	7d5c                	ld	a5,184(a0)
    80002cfa:	6fc8                	ld	a0,152(a5)
    80002cfc:	bfe9                	j	80002cd6 <argraw+0x30>
  panic("argraw");
    80002cfe:	00005517          	auipc	a0,0x5
    80002d02:	70250513          	addi	a0,a0,1794 # 80008400 <states.0+0x150>
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	838080e7          	jalr	-1992(ra) # 8000053e <panic>

0000000080002d0e <fetchaddr>:
{
    80002d0e:	1101                	addi	sp,sp,-32
    80002d10:	ec06                	sd	ra,24(sp)
    80002d12:	e822                	sd	s0,16(sp)
    80002d14:	e426                	sd	s1,8(sp)
    80002d16:	e04a                	sd	s2,0(sp)
    80002d18:	1000                	addi	s0,sp,32
    80002d1a:	84aa                	mv	s1,a0
    80002d1c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	c62080e7          	jalr	-926(ra) # 80001980 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d26:	7d7c                	ld	a5,248(a0)
    80002d28:	02f4f963          	bgeu	s1,a5,80002d5a <fetchaddr+0x4c>
    80002d2c:	00848713          	addi	a4,s1,8
    80002d30:	02e7e763          	bltu	a5,a4,80002d5e <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d34:	46a1                	li	a3,8
    80002d36:	8626                	mv	a2,s1
    80002d38:	85ca                	mv	a1,s2
    80002d3a:	10053503          	ld	a0,256(a0)
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	9b6080e7          	jalr	-1610(ra) # 800016f4 <copyin>
    80002d46:	00a03533          	snez	a0,a0
    80002d4a:	40a00533          	neg	a0,a0
}
    80002d4e:	60e2                	ld	ra,24(sp)
    80002d50:	6442                	ld	s0,16(sp)
    80002d52:	64a2                	ld	s1,8(sp)
    80002d54:	6902                	ld	s2,0(sp)
    80002d56:	6105                	addi	sp,sp,32
    80002d58:	8082                	ret
    return -1;
    80002d5a:	557d                	li	a0,-1
    80002d5c:	bfcd                	j	80002d4e <fetchaddr+0x40>
    80002d5e:	557d                	li	a0,-1
    80002d60:	b7fd                	j	80002d4e <fetchaddr+0x40>

0000000080002d62 <fetchstr>:
{
    80002d62:	7179                	addi	sp,sp,-48
    80002d64:	f406                	sd	ra,40(sp)
    80002d66:	f022                	sd	s0,32(sp)
    80002d68:	ec26                	sd	s1,24(sp)
    80002d6a:	e84a                	sd	s2,16(sp)
    80002d6c:	e44e                	sd	s3,8(sp)
    80002d6e:	1800                	addi	s0,sp,48
    80002d70:	892a                	mv	s2,a0
    80002d72:	84ae                	mv	s1,a1
    80002d74:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d76:	fffff097          	auipc	ra,0xfffff
    80002d7a:	c0a080e7          	jalr	-1014(ra) # 80001980 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d7e:	86ce                	mv	a3,s3
    80002d80:	864a                	mv	a2,s2
    80002d82:	85a6                	mv	a1,s1
    80002d84:	10053503          	ld	a0,256(a0)
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	9fa080e7          	jalr	-1542(ra) # 80001782 <copyinstr>
    80002d90:	00054e63          	bltz	a0,80002dac <fetchstr+0x4a>
  return strlen(buf);
    80002d94:	8526                	mv	a0,s1
    80002d96:	ffffe097          	auipc	ra,0xffffe
    80002d9a:	0b8080e7          	jalr	184(ra) # 80000e4e <strlen>
}
    80002d9e:	70a2                	ld	ra,40(sp)
    80002da0:	7402                	ld	s0,32(sp)
    80002da2:	64e2                	ld	s1,24(sp)
    80002da4:	6942                	ld	s2,16(sp)
    80002da6:	69a2                	ld	s3,8(sp)
    80002da8:	6145                	addi	sp,sp,48
    80002daa:	8082                	ret
    return -1;
    80002dac:	557d                	li	a0,-1
    80002dae:	bfc5                	j	80002d9e <fetchstr+0x3c>

0000000080002db0 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002db0:	1101                	addi	sp,sp,-32
    80002db2:	ec06                	sd	ra,24(sp)
    80002db4:	e822                	sd	s0,16(sp)
    80002db6:	e426                	sd	s1,8(sp)
    80002db8:	1000                	addi	s0,sp,32
    80002dba:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dbc:	00000097          	auipc	ra,0x0
    80002dc0:	eea080e7          	jalr	-278(ra) # 80002ca6 <argraw>
    80002dc4:	c088                	sw	a0,0(s1)
}
    80002dc6:	60e2                	ld	ra,24(sp)
    80002dc8:	6442                	ld	s0,16(sp)
    80002dca:	64a2                	ld	s1,8(sp)
    80002dcc:	6105                	addi	sp,sp,32
    80002dce:	8082                	ret

0000000080002dd0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	e426                	sd	s1,8(sp)
    80002dd8:	1000                	addi	s0,sp,32
    80002dda:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ddc:	00000097          	auipc	ra,0x0
    80002de0:	eca080e7          	jalr	-310(ra) # 80002ca6 <argraw>
    80002de4:	e088                	sd	a0,0(s1)
}
    80002de6:	60e2                	ld	ra,24(sp)
    80002de8:	6442                	ld	s0,16(sp)
    80002dea:	64a2                	ld	s1,8(sp)
    80002dec:	6105                	addi	sp,sp,32
    80002dee:	8082                	ret

0000000080002df0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002df0:	7179                	addi	sp,sp,-48
    80002df2:	f406                	sd	ra,40(sp)
    80002df4:	f022                	sd	s0,32(sp)
    80002df6:	ec26                	sd	s1,24(sp)
    80002df8:	e84a                	sd	s2,16(sp)
    80002dfa:	1800                	addi	s0,sp,48
    80002dfc:	84ae                	mv	s1,a1
    80002dfe:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e00:	fd840593          	addi	a1,s0,-40
    80002e04:	00000097          	auipc	ra,0x0
    80002e08:	fcc080e7          	jalr	-52(ra) # 80002dd0 <argaddr>
  return fetchstr(addr, buf, max);
    80002e0c:	864a                	mv	a2,s2
    80002e0e:	85a6                	mv	a1,s1
    80002e10:	fd843503          	ld	a0,-40(s0)
    80002e14:	00000097          	auipc	ra,0x0
    80002e18:	f4e080e7          	jalr	-178(ra) # 80002d62 <fetchstr>
}
    80002e1c:	70a2                	ld	ra,40(sp)
    80002e1e:	7402                	ld	s0,32(sp)
    80002e20:	64e2                	ld	s1,24(sp)
    80002e22:	6942                	ld	s2,16(sp)
    80002e24:	6145                	addi	sp,sp,48
    80002e26:	8082                	ret

0000000080002e28 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e28:	7179                	addi	sp,sp,-48
    80002e2a:	f406                	sd	ra,40(sp)
    80002e2c:	f022                	sd	s0,32(sp)
    80002e2e:	ec26                	sd	s1,24(sp)
    80002e30:	e84a                	sd	s2,16(sp)
    80002e32:	e44e                	sd	s3,8(sp)
    80002e34:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	b4a080e7          	jalr	-1206(ra) # 80001980 <myproc>
    80002e3e:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    80002e40:	00000097          	auipc	ra,0x0
    80002e44:	8ae080e7          	jalr	-1874(ra) # 800026ee <mykthread>
    80002e48:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80002e4a:	0b853983          	ld	s3,184(a0)
    80002e4e:	0a89b783          	ld	a5,168(s3)
    80002e52:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e56:	37fd                	addiw	a5,a5,-1
    80002e58:	4751                	li	a4,20
    80002e5a:	00f76f63          	bltu	a4,a5,80002e78 <syscall+0x50>
    80002e5e:	00369713          	slli	a4,a3,0x3
    80002e62:	00005797          	auipc	a5,0x5
    80002e66:	5de78793          	addi	a5,a5,1502 # 80008440 <syscalls>
    80002e6a:	97ba                	add	a5,a5,a4
    80002e6c:	639c                	ld	a5,0(a5)
    80002e6e:	c789                	beqz	a5,80002e78 <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    80002e70:	9782                	jalr	a5
    80002e72:	06a9b823          	sd	a0,112(s3)
    80002e76:	a005                	j	80002e96 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e78:	19090613          	addi	a2,s2,400
    80002e7c:	02492583          	lw	a1,36(s2)
    80002e80:	00005517          	auipc	a0,0x5
    80002e84:	58850513          	addi	a0,a0,1416 # 80008408 <states.0+0x158>
    80002e88:	ffffd097          	auipc	ra,0xffffd
    80002e8c:	700080e7          	jalr	1792(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    80002e90:	7cdc                	ld	a5,184(s1)
    80002e92:	577d                	li	a4,-1
    80002e94:	fbb8                	sd	a4,112(a5)
  }
}
    80002e96:	70a2                	ld	ra,40(sp)
    80002e98:	7402                	ld	s0,32(sp)
    80002e9a:	64e2                	ld	s1,24(sp)
    80002e9c:	6942                	ld	s2,16(sp)
    80002e9e:	69a2                	ld	s3,8(sp)
    80002ea0:	6145                	addi	sp,sp,48
    80002ea2:	8082                	ret

0000000080002ea4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ea4:	1101                	addi	sp,sp,-32
    80002ea6:	ec06                	sd	ra,24(sp)
    80002ea8:	e822                	sd	s0,16(sp)
    80002eaa:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002eac:	fec40593          	addi	a1,s0,-20
    80002eb0:	4501                	li	a0,0
    80002eb2:	00000097          	auipc	ra,0x0
    80002eb6:	efe080e7          	jalr	-258(ra) # 80002db0 <argint>
  exit(n);
    80002eba:	fec42503          	lw	a0,-20(s0)
    80002ebe:	fffff097          	auipc	ra,0xfffff
    80002ec2:	338080e7          	jalr	824(ra) # 800021f6 <exit>
  return 0;  // not reached
}
    80002ec6:	4501                	li	a0,0
    80002ec8:	60e2                	ld	ra,24(sp)
    80002eca:	6442                	ld	s0,16(sp)
    80002ecc:	6105                	addi	sp,sp,32
    80002ece:	8082                	ret

0000000080002ed0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ed0:	1141                	addi	sp,sp,-16
    80002ed2:	e406                	sd	ra,8(sp)
    80002ed4:	e022                	sd	s0,0(sp)
    80002ed6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ed8:	fffff097          	auipc	ra,0xfffff
    80002edc:	aa8080e7          	jalr	-1368(ra) # 80001980 <myproc>
}
    80002ee0:	5148                	lw	a0,36(a0)
    80002ee2:	60a2                	ld	ra,8(sp)
    80002ee4:	6402                	ld	s0,0(sp)
    80002ee6:	0141                	addi	sp,sp,16
    80002ee8:	8082                	ret

0000000080002eea <sys_fork>:

uint64
sys_fork(void)
{
    80002eea:	1141                	addi	sp,sp,-16
    80002eec:	e406                	sd	ra,8(sp)
    80002eee:	e022                	sd	s0,0(sp)
    80002ef0:	0800                	addi	s0,sp,16
  return fork();
    80002ef2:	fffff097          	auipc	ra,0xfffff
    80002ef6:	e54080e7          	jalr	-428(ra) # 80001d46 <fork>
}
    80002efa:	60a2                	ld	ra,8(sp)
    80002efc:	6402                	ld	s0,0(sp)
    80002efe:	0141                	addi	sp,sp,16
    80002f00:	8082                	ret

0000000080002f02 <sys_wait>:

uint64
sys_wait(void)
{
    80002f02:	1101                	addi	sp,sp,-32
    80002f04:	ec06                	sd	ra,24(sp)
    80002f06:	e822                	sd	s0,16(sp)
    80002f08:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f0a:	fe840593          	addi	a1,s0,-24
    80002f0e:	4501                	li	a0,0
    80002f10:	00000097          	auipc	ra,0x0
    80002f14:	ec0080e7          	jalr	-320(ra) # 80002dd0 <argaddr>
  return wait(p);
    80002f18:	fe843503          	ld	a0,-24(s0)
    80002f1c:	fffff097          	auipc	ra,0xfffff
    80002f20:	4d4080e7          	jalr	1236(ra) # 800023f0 <wait>
}
    80002f24:	60e2                	ld	ra,24(sp)
    80002f26:	6442                	ld	s0,16(sp)
    80002f28:	6105                	addi	sp,sp,32
    80002f2a:	8082                	ret

0000000080002f2c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f2c:	7179                	addi	sp,sp,-48
    80002f2e:	f406                	sd	ra,40(sp)
    80002f30:	f022                	sd	s0,32(sp)
    80002f32:	ec26                	sd	s1,24(sp)
    80002f34:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f36:	fdc40593          	addi	a1,s0,-36
    80002f3a:	4501                	li	a0,0
    80002f3c:	00000097          	auipc	ra,0x0
    80002f40:	e74080e7          	jalr	-396(ra) # 80002db0 <argint>
  addr = myproc()->sz;
    80002f44:	fffff097          	auipc	ra,0xfffff
    80002f48:	a3c080e7          	jalr	-1476(ra) # 80001980 <myproc>
    80002f4c:	7d64                	ld	s1,248(a0)
  if(growproc(n) < 0)
    80002f4e:	fdc42503          	lw	a0,-36(s0)
    80002f52:	fffff097          	auipc	ra,0xfffff
    80002f56:	d94080e7          	jalr	-620(ra) # 80001ce6 <growproc>
    80002f5a:	00054863          	bltz	a0,80002f6a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f5e:	8526                	mv	a0,s1
    80002f60:	70a2                	ld	ra,40(sp)
    80002f62:	7402                	ld	s0,32(sp)
    80002f64:	64e2                	ld	s1,24(sp)
    80002f66:	6145                	addi	sp,sp,48
    80002f68:	8082                	ret
    return -1;
    80002f6a:	54fd                	li	s1,-1
    80002f6c:	bfcd                	j	80002f5e <sys_sbrk+0x32>

0000000080002f6e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f6e:	7139                	addi	sp,sp,-64
    80002f70:	fc06                	sd	ra,56(sp)
    80002f72:	f822                	sd	s0,48(sp)
    80002f74:	f426                	sd	s1,40(sp)
    80002f76:	f04a                	sd	s2,32(sp)
    80002f78:	ec4e                	sd	s3,24(sp)
    80002f7a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f7c:	fcc40593          	addi	a1,s0,-52
    80002f80:	4501                	li	a0,0
    80002f82:	00000097          	auipc	ra,0x0
    80002f86:	e2e080e7          	jalr	-466(ra) # 80002db0 <argint>
  acquire(&tickslock);
    80002f8a:	00015517          	auipc	a0,0x15
    80002f8e:	fe650513          	addi	a0,a0,-26 # 80017f70 <tickslock>
    80002f92:	ffffe097          	auipc	ra,0xffffe
    80002f96:	c44080e7          	jalr	-956(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002f9a:	00006917          	auipc	s2,0x6
    80002f9e:	93692903          	lw	s2,-1738(s2) # 800088d0 <ticks>
  while(ticks - ticks0 < n){
    80002fa2:	fcc42783          	lw	a5,-52(s0)
    80002fa6:	cf9d                	beqz	a5,80002fe4 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fa8:	00015997          	auipc	s3,0x15
    80002fac:	fc898993          	addi	s3,s3,-56 # 80017f70 <tickslock>
    80002fb0:	00006497          	auipc	s1,0x6
    80002fb4:	92048493          	addi	s1,s1,-1760 # 800088d0 <ticks>
    if(killed(myproc())){
    80002fb8:	fffff097          	auipc	ra,0xfffff
    80002fbc:	9c8080e7          	jalr	-1592(ra) # 80001980 <myproc>
    80002fc0:	fffff097          	auipc	ra,0xfffff
    80002fc4:	3fe080e7          	jalr	1022(ra) # 800023be <killed>
    80002fc8:	ed15                	bnez	a0,80003004 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002fca:	85ce                	mv	a1,s3
    80002fcc:	8526                	mv	a0,s1
    80002fce:	fffff097          	auipc	ra,0xfffff
    80002fd2:	0ee080e7          	jalr	238(ra) # 800020bc <sleep>
  while(ticks - ticks0 < n){
    80002fd6:	409c                	lw	a5,0(s1)
    80002fd8:	412787bb          	subw	a5,a5,s2
    80002fdc:	fcc42703          	lw	a4,-52(s0)
    80002fe0:	fce7ece3          	bltu	a5,a4,80002fb8 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002fe4:	00015517          	auipc	a0,0x15
    80002fe8:	f8c50513          	addi	a0,a0,-116 # 80017f70 <tickslock>
    80002fec:	ffffe097          	auipc	ra,0xffffe
    80002ff0:	c9e080e7          	jalr	-866(ra) # 80000c8a <release>
  return 0;
    80002ff4:	4501                	li	a0,0
}
    80002ff6:	70e2                	ld	ra,56(sp)
    80002ff8:	7442                	ld	s0,48(sp)
    80002ffa:	74a2                	ld	s1,40(sp)
    80002ffc:	7902                	ld	s2,32(sp)
    80002ffe:	69e2                	ld	s3,24(sp)
    80003000:	6121                	addi	sp,sp,64
    80003002:	8082                	ret
      release(&tickslock);
    80003004:	00015517          	auipc	a0,0x15
    80003008:	f6c50513          	addi	a0,a0,-148 # 80017f70 <tickslock>
    8000300c:	ffffe097          	auipc	ra,0xffffe
    80003010:	c7e080e7          	jalr	-898(ra) # 80000c8a <release>
      return -1;
    80003014:	557d                	li	a0,-1
    80003016:	b7c5                	j	80002ff6 <sys_sleep+0x88>

0000000080003018 <sys_kill>:

uint64
sys_kill(void)
{
    80003018:	1101                	addi	sp,sp,-32
    8000301a:	ec06                	sd	ra,24(sp)
    8000301c:	e822                	sd	s0,16(sp)
    8000301e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003020:	fec40593          	addi	a1,s0,-20
    80003024:	4501                	li	a0,0
    80003026:	00000097          	auipc	ra,0x0
    8000302a:	d8a080e7          	jalr	-630(ra) # 80002db0 <argint>
  return kill(pid);
    8000302e:	fec42503          	lw	a0,-20(s0)
    80003032:	fffff097          	auipc	ra,0xfffff
    80003036:	2d6080e7          	jalr	726(ra) # 80002308 <kill>
}
    8000303a:	60e2                	ld	ra,24(sp)
    8000303c:	6442                	ld	s0,16(sp)
    8000303e:	6105                	addi	sp,sp,32
    80003040:	8082                	ret

0000000080003042 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003042:	1101                	addi	sp,sp,-32
    80003044:	ec06                	sd	ra,24(sp)
    80003046:	e822                	sd	s0,16(sp)
    80003048:	e426                	sd	s1,8(sp)
    8000304a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000304c:	00015517          	auipc	a0,0x15
    80003050:	f2450513          	addi	a0,a0,-220 # 80017f70 <tickslock>
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	b82080e7          	jalr	-1150(ra) # 80000bd6 <acquire>
  xticks = ticks;
    8000305c:	00006497          	auipc	s1,0x6
    80003060:	8744a483          	lw	s1,-1932(s1) # 800088d0 <ticks>
  release(&tickslock);
    80003064:	00015517          	auipc	a0,0x15
    80003068:	f0c50513          	addi	a0,a0,-244 # 80017f70 <tickslock>
    8000306c:	ffffe097          	auipc	ra,0xffffe
    80003070:	c1e080e7          	jalr	-994(ra) # 80000c8a <release>
  return xticks;
}
    80003074:	02049513          	slli	a0,s1,0x20
    80003078:	9101                	srli	a0,a0,0x20
    8000307a:	60e2                	ld	ra,24(sp)
    8000307c:	6442                	ld	s0,16(sp)
    8000307e:	64a2                	ld	s1,8(sp)
    80003080:	6105                	addi	sp,sp,32
    80003082:	8082                	ret

0000000080003084 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003084:	7179                	addi	sp,sp,-48
    80003086:	f406                	sd	ra,40(sp)
    80003088:	f022                	sd	s0,32(sp)
    8000308a:	ec26                	sd	s1,24(sp)
    8000308c:	e84a                	sd	s2,16(sp)
    8000308e:	e44e                	sd	s3,8(sp)
    80003090:	e052                	sd	s4,0(sp)
    80003092:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003094:	00005597          	auipc	a1,0x5
    80003098:	45c58593          	addi	a1,a1,1116 # 800084f0 <syscalls+0xb0>
    8000309c:	00015517          	auipc	a0,0x15
    800030a0:	eec50513          	addi	a0,a0,-276 # 80017f88 <bcache>
    800030a4:	ffffe097          	auipc	ra,0xffffe
    800030a8:	aa2080e7          	jalr	-1374(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030ac:	0001d797          	auipc	a5,0x1d
    800030b0:	edc78793          	addi	a5,a5,-292 # 8001ff88 <bcache+0x8000>
    800030b4:	0001d717          	auipc	a4,0x1d
    800030b8:	13c70713          	addi	a4,a4,316 # 800201f0 <bcache+0x8268>
    800030bc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030c0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030c4:	00015497          	auipc	s1,0x15
    800030c8:	edc48493          	addi	s1,s1,-292 # 80017fa0 <bcache+0x18>
    b->next = bcache.head.next;
    800030cc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030ce:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030d0:	00005a17          	auipc	s4,0x5
    800030d4:	428a0a13          	addi	s4,s4,1064 # 800084f8 <syscalls+0xb8>
    b->next = bcache.head.next;
    800030d8:	2b893783          	ld	a5,696(s2)
    800030dc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030de:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030e2:	85d2                	mv	a1,s4
    800030e4:	01048513          	addi	a0,s1,16
    800030e8:	00001097          	auipc	ra,0x1
    800030ec:	4c4080e7          	jalr	1220(ra) # 800045ac <initsleeplock>
    bcache.head.next->prev = b;
    800030f0:	2b893783          	ld	a5,696(s2)
    800030f4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030f6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030fa:	45848493          	addi	s1,s1,1112
    800030fe:	fd349de3          	bne	s1,s3,800030d8 <binit+0x54>
  }
}
    80003102:	70a2                	ld	ra,40(sp)
    80003104:	7402                	ld	s0,32(sp)
    80003106:	64e2                	ld	s1,24(sp)
    80003108:	6942                	ld	s2,16(sp)
    8000310a:	69a2                	ld	s3,8(sp)
    8000310c:	6a02                	ld	s4,0(sp)
    8000310e:	6145                	addi	sp,sp,48
    80003110:	8082                	ret

0000000080003112 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003112:	7179                	addi	sp,sp,-48
    80003114:	f406                	sd	ra,40(sp)
    80003116:	f022                	sd	s0,32(sp)
    80003118:	ec26                	sd	s1,24(sp)
    8000311a:	e84a                	sd	s2,16(sp)
    8000311c:	e44e                	sd	s3,8(sp)
    8000311e:	1800                	addi	s0,sp,48
    80003120:	892a                	mv	s2,a0
    80003122:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003124:	00015517          	auipc	a0,0x15
    80003128:	e6450513          	addi	a0,a0,-412 # 80017f88 <bcache>
    8000312c:	ffffe097          	auipc	ra,0xffffe
    80003130:	aaa080e7          	jalr	-1366(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003134:	0001d497          	auipc	s1,0x1d
    80003138:	10c4b483          	ld	s1,268(s1) # 80020240 <bcache+0x82b8>
    8000313c:	0001d797          	auipc	a5,0x1d
    80003140:	0b478793          	addi	a5,a5,180 # 800201f0 <bcache+0x8268>
    80003144:	02f48f63          	beq	s1,a5,80003182 <bread+0x70>
    80003148:	873e                	mv	a4,a5
    8000314a:	a021                	j	80003152 <bread+0x40>
    8000314c:	68a4                	ld	s1,80(s1)
    8000314e:	02e48a63          	beq	s1,a4,80003182 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003152:	449c                	lw	a5,8(s1)
    80003154:	ff279ce3          	bne	a5,s2,8000314c <bread+0x3a>
    80003158:	44dc                	lw	a5,12(s1)
    8000315a:	ff3799e3          	bne	a5,s3,8000314c <bread+0x3a>
      b->refcnt++;
    8000315e:	40bc                	lw	a5,64(s1)
    80003160:	2785                	addiw	a5,a5,1
    80003162:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003164:	00015517          	auipc	a0,0x15
    80003168:	e2450513          	addi	a0,a0,-476 # 80017f88 <bcache>
    8000316c:	ffffe097          	auipc	ra,0xffffe
    80003170:	b1e080e7          	jalr	-1250(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003174:	01048513          	addi	a0,s1,16
    80003178:	00001097          	auipc	ra,0x1
    8000317c:	46e080e7          	jalr	1134(ra) # 800045e6 <acquiresleep>
      return b;
    80003180:	a8b9                	j	800031de <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003182:	0001d497          	auipc	s1,0x1d
    80003186:	0b64b483          	ld	s1,182(s1) # 80020238 <bcache+0x82b0>
    8000318a:	0001d797          	auipc	a5,0x1d
    8000318e:	06678793          	addi	a5,a5,102 # 800201f0 <bcache+0x8268>
    80003192:	00f48863          	beq	s1,a5,800031a2 <bread+0x90>
    80003196:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003198:	40bc                	lw	a5,64(s1)
    8000319a:	cf81                	beqz	a5,800031b2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000319c:	64a4                	ld	s1,72(s1)
    8000319e:	fee49de3          	bne	s1,a4,80003198 <bread+0x86>
  panic("bget: no buffers");
    800031a2:	00005517          	auipc	a0,0x5
    800031a6:	35e50513          	addi	a0,a0,862 # 80008500 <syscalls+0xc0>
    800031aa:	ffffd097          	auipc	ra,0xffffd
    800031ae:	394080e7          	jalr	916(ra) # 8000053e <panic>
      b->dev = dev;
    800031b2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031b6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031ba:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031be:	4785                	li	a5,1
    800031c0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031c2:	00015517          	auipc	a0,0x15
    800031c6:	dc650513          	addi	a0,a0,-570 # 80017f88 <bcache>
    800031ca:	ffffe097          	auipc	ra,0xffffe
    800031ce:	ac0080e7          	jalr	-1344(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031d2:	01048513          	addi	a0,s1,16
    800031d6:	00001097          	auipc	ra,0x1
    800031da:	410080e7          	jalr	1040(ra) # 800045e6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031de:	409c                	lw	a5,0(s1)
    800031e0:	cb89                	beqz	a5,800031f2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031e2:	8526                	mv	a0,s1
    800031e4:	70a2                	ld	ra,40(sp)
    800031e6:	7402                	ld	s0,32(sp)
    800031e8:	64e2                	ld	s1,24(sp)
    800031ea:	6942                	ld	s2,16(sp)
    800031ec:	69a2                	ld	s3,8(sp)
    800031ee:	6145                	addi	sp,sp,48
    800031f0:	8082                	ret
    virtio_disk_rw(b, 0);
    800031f2:	4581                	li	a1,0
    800031f4:	8526                	mv	a0,s1
    800031f6:	00003097          	auipc	ra,0x3
    800031fa:	fee080e7          	jalr	-18(ra) # 800061e4 <virtio_disk_rw>
    b->valid = 1;
    800031fe:	4785                	li	a5,1
    80003200:	c09c                	sw	a5,0(s1)
  return b;
    80003202:	b7c5                	j	800031e2 <bread+0xd0>

0000000080003204 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003204:	1101                	addi	sp,sp,-32
    80003206:	ec06                	sd	ra,24(sp)
    80003208:	e822                	sd	s0,16(sp)
    8000320a:	e426                	sd	s1,8(sp)
    8000320c:	1000                	addi	s0,sp,32
    8000320e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003210:	0541                	addi	a0,a0,16
    80003212:	00001097          	auipc	ra,0x1
    80003216:	46e080e7          	jalr	1134(ra) # 80004680 <holdingsleep>
    8000321a:	cd01                	beqz	a0,80003232 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000321c:	4585                	li	a1,1
    8000321e:	8526                	mv	a0,s1
    80003220:	00003097          	auipc	ra,0x3
    80003224:	fc4080e7          	jalr	-60(ra) # 800061e4 <virtio_disk_rw>
}
    80003228:	60e2                	ld	ra,24(sp)
    8000322a:	6442                	ld	s0,16(sp)
    8000322c:	64a2                	ld	s1,8(sp)
    8000322e:	6105                	addi	sp,sp,32
    80003230:	8082                	ret
    panic("bwrite");
    80003232:	00005517          	auipc	a0,0x5
    80003236:	2e650513          	addi	a0,a0,742 # 80008518 <syscalls+0xd8>
    8000323a:	ffffd097          	auipc	ra,0xffffd
    8000323e:	304080e7          	jalr	772(ra) # 8000053e <panic>

0000000080003242 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003242:	1101                	addi	sp,sp,-32
    80003244:	ec06                	sd	ra,24(sp)
    80003246:	e822                	sd	s0,16(sp)
    80003248:	e426                	sd	s1,8(sp)
    8000324a:	e04a                	sd	s2,0(sp)
    8000324c:	1000                	addi	s0,sp,32
    8000324e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003250:	01050913          	addi	s2,a0,16
    80003254:	854a                	mv	a0,s2
    80003256:	00001097          	auipc	ra,0x1
    8000325a:	42a080e7          	jalr	1066(ra) # 80004680 <holdingsleep>
    8000325e:	c92d                	beqz	a0,800032d0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003260:	854a                	mv	a0,s2
    80003262:	00001097          	auipc	ra,0x1
    80003266:	3da080e7          	jalr	986(ra) # 8000463c <releasesleep>

  acquire(&bcache.lock);
    8000326a:	00015517          	auipc	a0,0x15
    8000326e:	d1e50513          	addi	a0,a0,-738 # 80017f88 <bcache>
    80003272:	ffffe097          	auipc	ra,0xffffe
    80003276:	964080e7          	jalr	-1692(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000327a:	40bc                	lw	a5,64(s1)
    8000327c:	37fd                	addiw	a5,a5,-1
    8000327e:	0007871b          	sext.w	a4,a5
    80003282:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003284:	eb05                	bnez	a4,800032b4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003286:	68bc                	ld	a5,80(s1)
    80003288:	64b8                	ld	a4,72(s1)
    8000328a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000328c:	64bc                	ld	a5,72(s1)
    8000328e:	68b8                	ld	a4,80(s1)
    80003290:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003292:	0001d797          	auipc	a5,0x1d
    80003296:	cf678793          	addi	a5,a5,-778 # 8001ff88 <bcache+0x8000>
    8000329a:	2b87b703          	ld	a4,696(a5)
    8000329e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032a0:	0001d717          	auipc	a4,0x1d
    800032a4:	f5070713          	addi	a4,a4,-176 # 800201f0 <bcache+0x8268>
    800032a8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032aa:	2b87b703          	ld	a4,696(a5)
    800032ae:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032b0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032b4:	00015517          	auipc	a0,0x15
    800032b8:	cd450513          	addi	a0,a0,-812 # 80017f88 <bcache>
    800032bc:	ffffe097          	auipc	ra,0xffffe
    800032c0:	9ce080e7          	jalr	-1586(ra) # 80000c8a <release>
}
    800032c4:	60e2                	ld	ra,24(sp)
    800032c6:	6442                	ld	s0,16(sp)
    800032c8:	64a2                	ld	s1,8(sp)
    800032ca:	6902                	ld	s2,0(sp)
    800032cc:	6105                	addi	sp,sp,32
    800032ce:	8082                	ret
    panic("brelse");
    800032d0:	00005517          	auipc	a0,0x5
    800032d4:	25050513          	addi	a0,a0,592 # 80008520 <syscalls+0xe0>
    800032d8:	ffffd097          	auipc	ra,0xffffd
    800032dc:	266080e7          	jalr	614(ra) # 8000053e <panic>

00000000800032e0 <bpin>:

void
bpin(struct buf *b) {
    800032e0:	1101                	addi	sp,sp,-32
    800032e2:	ec06                	sd	ra,24(sp)
    800032e4:	e822                	sd	s0,16(sp)
    800032e6:	e426                	sd	s1,8(sp)
    800032e8:	1000                	addi	s0,sp,32
    800032ea:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032ec:	00015517          	auipc	a0,0x15
    800032f0:	c9c50513          	addi	a0,a0,-868 # 80017f88 <bcache>
    800032f4:	ffffe097          	auipc	ra,0xffffe
    800032f8:	8e2080e7          	jalr	-1822(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800032fc:	40bc                	lw	a5,64(s1)
    800032fe:	2785                	addiw	a5,a5,1
    80003300:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003302:	00015517          	auipc	a0,0x15
    80003306:	c8650513          	addi	a0,a0,-890 # 80017f88 <bcache>
    8000330a:	ffffe097          	auipc	ra,0xffffe
    8000330e:	980080e7          	jalr	-1664(ra) # 80000c8a <release>
}
    80003312:	60e2                	ld	ra,24(sp)
    80003314:	6442                	ld	s0,16(sp)
    80003316:	64a2                	ld	s1,8(sp)
    80003318:	6105                	addi	sp,sp,32
    8000331a:	8082                	ret

000000008000331c <bunpin>:

void
bunpin(struct buf *b) {
    8000331c:	1101                	addi	sp,sp,-32
    8000331e:	ec06                	sd	ra,24(sp)
    80003320:	e822                	sd	s0,16(sp)
    80003322:	e426                	sd	s1,8(sp)
    80003324:	1000                	addi	s0,sp,32
    80003326:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003328:	00015517          	auipc	a0,0x15
    8000332c:	c6050513          	addi	a0,a0,-928 # 80017f88 <bcache>
    80003330:	ffffe097          	auipc	ra,0xffffe
    80003334:	8a6080e7          	jalr	-1882(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003338:	40bc                	lw	a5,64(s1)
    8000333a:	37fd                	addiw	a5,a5,-1
    8000333c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000333e:	00015517          	auipc	a0,0x15
    80003342:	c4a50513          	addi	a0,a0,-950 # 80017f88 <bcache>
    80003346:	ffffe097          	auipc	ra,0xffffe
    8000334a:	944080e7          	jalr	-1724(ra) # 80000c8a <release>
}
    8000334e:	60e2                	ld	ra,24(sp)
    80003350:	6442                	ld	s0,16(sp)
    80003352:	64a2                	ld	s1,8(sp)
    80003354:	6105                	addi	sp,sp,32
    80003356:	8082                	ret

0000000080003358 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003358:	1101                	addi	sp,sp,-32
    8000335a:	ec06                	sd	ra,24(sp)
    8000335c:	e822                	sd	s0,16(sp)
    8000335e:	e426                	sd	s1,8(sp)
    80003360:	e04a                	sd	s2,0(sp)
    80003362:	1000                	addi	s0,sp,32
    80003364:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003366:	00d5d59b          	srliw	a1,a1,0xd
    8000336a:	0001d797          	auipc	a5,0x1d
    8000336e:	2fa7a783          	lw	a5,762(a5) # 80020664 <sb+0x1c>
    80003372:	9dbd                	addw	a1,a1,a5
    80003374:	00000097          	auipc	ra,0x0
    80003378:	d9e080e7          	jalr	-610(ra) # 80003112 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000337c:	0074f713          	andi	a4,s1,7
    80003380:	4785                	li	a5,1
    80003382:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003386:	14ce                	slli	s1,s1,0x33
    80003388:	90d9                	srli	s1,s1,0x36
    8000338a:	00950733          	add	a4,a0,s1
    8000338e:	05874703          	lbu	a4,88(a4)
    80003392:	00e7f6b3          	and	a3,a5,a4
    80003396:	c69d                	beqz	a3,800033c4 <bfree+0x6c>
    80003398:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000339a:	94aa                	add	s1,s1,a0
    8000339c:	fff7c793          	not	a5,a5
    800033a0:	8ff9                	and	a5,a5,a4
    800033a2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800033a6:	00001097          	auipc	ra,0x1
    800033aa:	120080e7          	jalr	288(ra) # 800044c6 <log_write>
  brelse(bp);
    800033ae:	854a                	mv	a0,s2
    800033b0:	00000097          	auipc	ra,0x0
    800033b4:	e92080e7          	jalr	-366(ra) # 80003242 <brelse>
}
    800033b8:	60e2                	ld	ra,24(sp)
    800033ba:	6442                	ld	s0,16(sp)
    800033bc:	64a2                	ld	s1,8(sp)
    800033be:	6902                	ld	s2,0(sp)
    800033c0:	6105                	addi	sp,sp,32
    800033c2:	8082                	ret
    panic("freeing free block");
    800033c4:	00005517          	auipc	a0,0x5
    800033c8:	16450513          	addi	a0,a0,356 # 80008528 <syscalls+0xe8>
    800033cc:	ffffd097          	auipc	ra,0xffffd
    800033d0:	172080e7          	jalr	370(ra) # 8000053e <panic>

00000000800033d4 <balloc>:
{
    800033d4:	711d                	addi	sp,sp,-96
    800033d6:	ec86                	sd	ra,88(sp)
    800033d8:	e8a2                	sd	s0,80(sp)
    800033da:	e4a6                	sd	s1,72(sp)
    800033dc:	e0ca                	sd	s2,64(sp)
    800033de:	fc4e                	sd	s3,56(sp)
    800033e0:	f852                	sd	s4,48(sp)
    800033e2:	f456                	sd	s5,40(sp)
    800033e4:	f05a                	sd	s6,32(sp)
    800033e6:	ec5e                	sd	s7,24(sp)
    800033e8:	e862                	sd	s8,16(sp)
    800033ea:	e466                	sd	s9,8(sp)
    800033ec:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033ee:	0001d797          	auipc	a5,0x1d
    800033f2:	25e7a783          	lw	a5,606(a5) # 8002064c <sb+0x4>
    800033f6:	10078163          	beqz	a5,800034f8 <balloc+0x124>
    800033fa:	8baa                	mv	s7,a0
    800033fc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033fe:	0001db17          	auipc	s6,0x1d
    80003402:	24ab0b13          	addi	s6,s6,586 # 80020648 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003406:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003408:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000340a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000340c:	6c89                	lui	s9,0x2
    8000340e:	a061                	j	80003496 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003410:	974a                	add	a4,a4,s2
    80003412:	8fd5                	or	a5,a5,a3
    80003414:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003418:	854a                	mv	a0,s2
    8000341a:	00001097          	auipc	ra,0x1
    8000341e:	0ac080e7          	jalr	172(ra) # 800044c6 <log_write>
        brelse(bp);
    80003422:	854a                	mv	a0,s2
    80003424:	00000097          	auipc	ra,0x0
    80003428:	e1e080e7          	jalr	-482(ra) # 80003242 <brelse>
  bp = bread(dev, bno);
    8000342c:	85a6                	mv	a1,s1
    8000342e:	855e                	mv	a0,s7
    80003430:	00000097          	auipc	ra,0x0
    80003434:	ce2080e7          	jalr	-798(ra) # 80003112 <bread>
    80003438:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000343a:	40000613          	li	a2,1024
    8000343e:	4581                	li	a1,0
    80003440:	05850513          	addi	a0,a0,88
    80003444:	ffffe097          	auipc	ra,0xffffe
    80003448:	88e080e7          	jalr	-1906(ra) # 80000cd2 <memset>
  log_write(bp);
    8000344c:	854a                	mv	a0,s2
    8000344e:	00001097          	auipc	ra,0x1
    80003452:	078080e7          	jalr	120(ra) # 800044c6 <log_write>
  brelse(bp);
    80003456:	854a                	mv	a0,s2
    80003458:	00000097          	auipc	ra,0x0
    8000345c:	dea080e7          	jalr	-534(ra) # 80003242 <brelse>
}
    80003460:	8526                	mv	a0,s1
    80003462:	60e6                	ld	ra,88(sp)
    80003464:	6446                	ld	s0,80(sp)
    80003466:	64a6                	ld	s1,72(sp)
    80003468:	6906                	ld	s2,64(sp)
    8000346a:	79e2                	ld	s3,56(sp)
    8000346c:	7a42                	ld	s4,48(sp)
    8000346e:	7aa2                	ld	s5,40(sp)
    80003470:	7b02                	ld	s6,32(sp)
    80003472:	6be2                	ld	s7,24(sp)
    80003474:	6c42                	ld	s8,16(sp)
    80003476:	6ca2                	ld	s9,8(sp)
    80003478:	6125                	addi	sp,sp,96
    8000347a:	8082                	ret
    brelse(bp);
    8000347c:	854a                	mv	a0,s2
    8000347e:	00000097          	auipc	ra,0x0
    80003482:	dc4080e7          	jalr	-572(ra) # 80003242 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003486:	015c87bb          	addw	a5,s9,s5
    8000348a:	00078a9b          	sext.w	s5,a5
    8000348e:	004b2703          	lw	a4,4(s6)
    80003492:	06eaf363          	bgeu	s5,a4,800034f8 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003496:	41fad79b          	sraiw	a5,s5,0x1f
    8000349a:	0137d79b          	srliw	a5,a5,0x13
    8000349e:	015787bb          	addw	a5,a5,s5
    800034a2:	40d7d79b          	sraiw	a5,a5,0xd
    800034a6:	01cb2583          	lw	a1,28(s6)
    800034aa:	9dbd                	addw	a1,a1,a5
    800034ac:	855e                	mv	a0,s7
    800034ae:	00000097          	auipc	ra,0x0
    800034b2:	c64080e7          	jalr	-924(ra) # 80003112 <bread>
    800034b6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034b8:	004b2503          	lw	a0,4(s6)
    800034bc:	000a849b          	sext.w	s1,s5
    800034c0:	8662                	mv	a2,s8
    800034c2:	faa4fde3          	bgeu	s1,a0,8000347c <balloc+0xa8>
      m = 1 << (bi % 8);
    800034c6:	41f6579b          	sraiw	a5,a2,0x1f
    800034ca:	01d7d69b          	srliw	a3,a5,0x1d
    800034ce:	00c6873b          	addw	a4,a3,a2
    800034d2:	00777793          	andi	a5,a4,7
    800034d6:	9f95                	subw	a5,a5,a3
    800034d8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034dc:	4037571b          	sraiw	a4,a4,0x3
    800034e0:	00e906b3          	add	a3,s2,a4
    800034e4:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    800034e8:	00d7f5b3          	and	a1,a5,a3
    800034ec:	d195                	beqz	a1,80003410 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ee:	2605                	addiw	a2,a2,1
    800034f0:	2485                	addiw	s1,s1,1
    800034f2:	fd4618e3          	bne	a2,s4,800034c2 <balloc+0xee>
    800034f6:	b759                	j	8000347c <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800034f8:	00005517          	auipc	a0,0x5
    800034fc:	04850513          	addi	a0,a0,72 # 80008540 <syscalls+0x100>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	088080e7          	jalr	136(ra) # 80000588 <printf>
  return 0;
    80003508:	4481                	li	s1,0
    8000350a:	bf99                	j	80003460 <balloc+0x8c>

000000008000350c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000350c:	7179                	addi	sp,sp,-48
    8000350e:	f406                	sd	ra,40(sp)
    80003510:	f022                	sd	s0,32(sp)
    80003512:	ec26                	sd	s1,24(sp)
    80003514:	e84a                	sd	s2,16(sp)
    80003516:	e44e                	sd	s3,8(sp)
    80003518:	e052                	sd	s4,0(sp)
    8000351a:	1800                	addi	s0,sp,48
    8000351c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000351e:	47ad                	li	a5,11
    80003520:	02b7e763          	bltu	a5,a1,8000354e <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003524:	02059493          	slli	s1,a1,0x20
    80003528:	9081                	srli	s1,s1,0x20
    8000352a:	048a                	slli	s1,s1,0x2
    8000352c:	94aa                	add	s1,s1,a0
    8000352e:	0504a903          	lw	s2,80(s1)
    80003532:	06091e63          	bnez	s2,800035ae <bmap+0xa2>
      addr = balloc(ip->dev);
    80003536:	4108                	lw	a0,0(a0)
    80003538:	00000097          	auipc	ra,0x0
    8000353c:	e9c080e7          	jalr	-356(ra) # 800033d4 <balloc>
    80003540:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003544:	06090563          	beqz	s2,800035ae <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003548:	0524a823          	sw	s2,80(s1)
    8000354c:	a08d                	j	800035ae <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000354e:	ff45849b          	addiw	s1,a1,-12
    80003552:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003556:	0ff00793          	li	a5,255
    8000355a:	08e7e563          	bltu	a5,a4,800035e4 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000355e:	08052903          	lw	s2,128(a0)
    80003562:	00091d63          	bnez	s2,8000357c <bmap+0x70>
      addr = balloc(ip->dev);
    80003566:	4108                	lw	a0,0(a0)
    80003568:	00000097          	auipc	ra,0x0
    8000356c:	e6c080e7          	jalr	-404(ra) # 800033d4 <balloc>
    80003570:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003574:	02090d63          	beqz	s2,800035ae <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003578:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000357c:	85ca                	mv	a1,s2
    8000357e:	0009a503          	lw	a0,0(s3)
    80003582:	00000097          	auipc	ra,0x0
    80003586:	b90080e7          	jalr	-1136(ra) # 80003112 <bread>
    8000358a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000358c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003590:	02049593          	slli	a1,s1,0x20
    80003594:	9181                	srli	a1,a1,0x20
    80003596:	058a                	slli	a1,a1,0x2
    80003598:	00b784b3          	add	s1,a5,a1
    8000359c:	0004a903          	lw	s2,0(s1)
    800035a0:	02090063          	beqz	s2,800035c0 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035a4:	8552                	mv	a0,s4
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	c9c080e7          	jalr	-868(ra) # 80003242 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800035ae:	854a                	mv	a0,s2
    800035b0:	70a2                	ld	ra,40(sp)
    800035b2:	7402                	ld	s0,32(sp)
    800035b4:	64e2                	ld	s1,24(sp)
    800035b6:	6942                	ld	s2,16(sp)
    800035b8:	69a2                	ld	s3,8(sp)
    800035ba:	6a02                	ld	s4,0(sp)
    800035bc:	6145                	addi	sp,sp,48
    800035be:	8082                	ret
      addr = balloc(ip->dev);
    800035c0:	0009a503          	lw	a0,0(s3)
    800035c4:	00000097          	auipc	ra,0x0
    800035c8:	e10080e7          	jalr	-496(ra) # 800033d4 <balloc>
    800035cc:	0005091b          	sext.w	s2,a0
      if(addr){
    800035d0:	fc090ae3          	beqz	s2,800035a4 <bmap+0x98>
        a[bn] = addr;
    800035d4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035d8:	8552                	mv	a0,s4
    800035da:	00001097          	auipc	ra,0x1
    800035de:	eec080e7          	jalr	-276(ra) # 800044c6 <log_write>
    800035e2:	b7c9                	j	800035a4 <bmap+0x98>
  panic("bmap: out of range");
    800035e4:	00005517          	auipc	a0,0x5
    800035e8:	f7450513          	addi	a0,a0,-140 # 80008558 <syscalls+0x118>
    800035ec:	ffffd097          	auipc	ra,0xffffd
    800035f0:	f52080e7          	jalr	-174(ra) # 8000053e <panic>

00000000800035f4 <iget>:
{
    800035f4:	7179                	addi	sp,sp,-48
    800035f6:	f406                	sd	ra,40(sp)
    800035f8:	f022                	sd	s0,32(sp)
    800035fa:	ec26                	sd	s1,24(sp)
    800035fc:	e84a                	sd	s2,16(sp)
    800035fe:	e44e                	sd	s3,8(sp)
    80003600:	e052                	sd	s4,0(sp)
    80003602:	1800                	addi	s0,sp,48
    80003604:	89aa                	mv	s3,a0
    80003606:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003608:	0001d517          	auipc	a0,0x1d
    8000360c:	06050513          	addi	a0,a0,96 # 80020668 <itable>
    80003610:	ffffd097          	auipc	ra,0xffffd
    80003614:	5c6080e7          	jalr	1478(ra) # 80000bd6 <acquire>
  empty = 0;
    80003618:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000361a:	0001d497          	auipc	s1,0x1d
    8000361e:	06648493          	addi	s1,s1,102 # 80020680 <itable+0x18>
    80003622:	0001f697          	auipc	a3,0x1f
    80003626:	aee68693          	addi	a3,a3,-1298 # 80022110 <log>
    8000362a:	a039                	j	80003638 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000362c:	02090b63          	beqz	s2,80003662 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003630:	08848493          	addi	s1,s1,136
    80003634:	02d48a63          	beq	s1,a3,80003668 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003638:	449c                	lw	a5,8(s1)
    8000363a:	fef059e3          	blez	a5,8000362c <iget+0x38>
    8000363e:	4098                	lw	a4,0(s1)
    80003640:	ff3716e3          	bne	a4,s3,8000362c <iget+0x38>
    80003644:	40d8                	lw	a4,4(s1)
    80003646:	ff4713e3          	bne	a4,s4,8000362c <iget+0x38>
      ip->ref++;
    8000364a:	2785                	addiw	a5,a5,1
    8000364c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000364e:	0001d517          	auipc	a0,0x1d
    80003652:	01a50513          	addi	a0,a0,26 # 80020668 <itable>
    80003656:	ffffd097          	auipc	ra,0xffffd
    8000365a:	634080e7          	jalr	1588(ra) # 80000c8a <release>
      return ip;
    8000365e:	8926                	mv	s2,s1
    80003660:	a03d                	j	8000368e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003662:	f7f9                	bnez	a5,80003630 <iget+0x3c>
    80003664:	8926                	mv	s2,s1
    80003666:	b7e9                	j	80003630 <iget+0x3c>
  if(empty == 0)
    80003668:	02090c63          	beqz	s2,800036a0 <iget+0xac>
  ip->dev = dev;
    8000366c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003670:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003674:	4785                	li	a5,1
    80003676:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000367a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000367e:	0001d517          	auipc	a0,0x1d
    80003682:	fea50513          	addi	a0,a0,-22 # 80020668 <itable>
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	604080e7          	jalr	1540(ra) # 80000c8a <release>
}
    8000368e:	854a                	mv	a0,s2
    80003690:	70a2                	ld	ra,40(sp)
    80003692:	7402                	ld	s0,32(sp)
    80003694:	64e2                	ld	s1,24(sp)
    80003696:	6942                	ld	s2,16(sp)
    80003698:	69a2                	ld	s3,8(sp)
    8000369a:	6a02                	ld	s4,0(sp)
    8000369c:	6145                	addi	sp,sp,48
    8000369e:	8082                	ret
    panic("iget: no inodes");
    800036a0:	00005517          	auipc	a0,0x5
    800036a4:	ed050513          	addi	a0,a0,-304 # 80008570 <syscalls+0x130>
    800036a8:	ffffd097          	auipc	ra,0xffffd
    800036ac:	e96080e7          	jalr	-362(ra) # 8000053e <panic>

00000000800036b0 <fsinit>:
fsinit(int dev) {
    800036b0:	7179                	addi	sp,sp,-48
    800036b2:	f406                	sd	ra,40(sp)
    800036b4:	f022                	sd	s0,32(sp)
    800036b6:	ec26                	sd	s1,24(sp)
    800036b8:	e84a                	sd	s2,16(sp)
    800036ba:	e44e                	sd	s3,8(sp)
    800036bc:	1800                	addi	s0,sp,48
    800036be:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036c0:	4585                	li	a1,1
    800036c2:	00000097          	auipc	ra,0x0
    800036c6:	a50080e7          	jalr	-1456(ra) # 80003112 <bread>
    800036ca:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036cc:	0001d997          	auipc	s3,0x1d
    800036d0:	f7c98993          	addi	s3,s3,-132 # 80020648 <sb>
    800036d4:	02000613          	li	a2,32
    800036d8:	05850593          	addi	a1,a0,88
    800036dc:	854e                	mv	a0,s3
    800036de:	ffffd097          	auipc	ra,0xffffd
    800036e2:	650080e7          	jalr	1616(ra) # 80000d2e <memmove>
  brelse(bp);
    800036e6:	8526                	mv	a0,s1
    800036e8:	00000097          	auipc	ra,0x0
    800036ec:	b5a080e7          	jalr	-1190(ra) # 80003242 <brelse>
  if(sb.magic != FSMAGIC)
    800036f0:	0009a703          	lw	a4,0(s3)
    800036f4:	102037b7          	lui	a5,0x10203
    800036f8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036fc:	02f71263          	bne	a4,a5,80003720 <fsinit+0x70>
  initlog(dev, &sb);
    80003700:	0001d597          	auipc	a1,0x1d
    80003704:	f4858593          	addi	a1,a1,-184 # 80020648 <sb>
    80003708:	854a                	mv	a0,s2
    8000370a:	00001097          	auipc	ra,0x1
    8000370e:	b40080e7          	jalr	-1216(ra) # 8000424a <initlog>
}
    80003712:	70a2                	ld	ra,40(sp)
    80003714:	7402                	ld	s0,32(sp)
    80003716:	64e2                	ld	s1,24(sp)
    80003718:	6942                	ld	s2,16(sp)
    8000371a:	69a2                	ld	s3,8(sp)
    8000371c:	6145                	addi	sp,sp,48
    8000371e:	8082                	ret
    panic("invalid file system");
    80003720:	00005517          	auipc	a0,0x5
    80003724:	e6050513          	addi	a0,a0,-416 # 80008580 <syscalls+0x140>
    80003728:	ffffd097          	auipc	ra,0xffffd
    8000372c:	e16080e7          	jalr	-490(ra) # 8000053e <panic>

0000000080003730 <iinit>:
{
    80003730:	7179                	addi	sp,sp,-48
    80003732:	f406                	sd	ra,40(sp)
    80003734:	f022                	sd	s0,32(sp)
    80003736:	ec26                	sd	s1,24(sp)
    80003738:	e84a                	sd	s2,16(sp)
    8000373a:	e44e                	sd	s3,8(sp)
    8000373c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000373e:	00005597          	auipc	a1,0x5
    80003742:	e5a58593          	addi	a1,a1,-422 # 80008598 <syscalls+0x158>
    80003746:	0001d517          	auipc	a0,0x1d
    8000374a:	f2250513          	addi	a0,a0,-222 # 80020668 <itable>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	3f8080e7          	jalr	1016(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003756:	0001d497          	auipc	s1,0x1d
    8000375a:	f3a48493          	addi	s1,s1,-198 # 80020690 <itable+0x28>
    8000375e:	0001f997          	auipc	s3,0x1f
    80003762:	9c298993          	addi	s3,s3,-1598 # 80022120 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003766:	00005917          	auipc	s2,0x5
    8000376a:	e3a90913          	addi	s2,s2,-454 # 800085a0 <syscalls+0x160>
    8000376e:	85ca                	mv	a1,s2
    80003770:	8526                	mv	a0,s1
    80003772:	00001097          	auipc	ra,0x1
    80003776:	e3a080e7          	jalr	-454(ra) # 800045ac <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000377a:	08848493          	addi	s1,s1,136
    8000377e:	ff3498e3          	bne	s1,s3,8000376e <iinit+0x3e>
}
    80003782:	70a2                	ld	ra,40(sp)
    80003784:	7402                	ld	s0,32(sp)
    80003786:	64e2                	ld	s1,24(sp)
    80003788:	6942                	ld	s2,16(sp)
    8000378a:	69a2                	ld	s3,8(sp)
    8000378c:	6145                	addi	sp,sp,48
    8000378e:	8082                	ret

0000000080003790 <ialloc>:
{
    80003790:	715d                	addi	sp,sp,-80
    80003792:	e486                	sd	ra,72(sp)
    80003794:	e0a2                	sd	s0,64(sp)
    80003796:	fc26                	sd	s1,56(sp)
    80003798:	f84a                	sd	s2,48(sp)
    8000379a:	f44e                	sd	s3,40(sp)
    8000379c:	f052                	sd	s4,32(sp)
    8000379e:	ec56                	sd	s5,24(sp)
    800037a0:	e85a                	sd	s6,16(sp)
    800037a2:	e45e                	sd	s7,8(sp)
    800037a4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037a6:	0001d717          	auipc	a4,0x1d
    800037aa:	eae72703          	lw	a4,-338(a4) # 80020654 <sb+0xc>
    800037ae:	4785                	li	a5,1
    800037b0:	04e7fa63          	bgeu	a5,a4,80003804 <ialloc+0x74>
    800037b4:	8aaa                	mv	s5,a0
    800037b6:	8bae                	mv	s7,a1
    800037b8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037ba:	0001da17          	auipc	s4,0x1d
    800037be:	e8ea0a13          	addi	s4,s4,-370 # 80020648 <sb>
    800037c2:	00048b1b          	sext.w	s6,s1
    800037c6:	0044d793          	srli	a5,s1,0x4
    800037ca:	018a2583          	lw	a1,24(s4)
    800037ce:	9dbd                	addw	a1,a1,a5
    800037d0:	8556                	mv	a0,s5
    800037d2:	00000097          	auipc	ra,0x0
    800037d6:	940080e7          	jalr	-1728(ra) # 80003112 <bread>
    800037da:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037dc:	05850993          	addi	s3,a0,88
    800037e0:	00f4f793          	andi	a5,s1,15
    800037e4:	079a                	slli	a5,a5,0x6
    800037e6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037e8:	00099783          	lh	a5,0(s3)
    800037ec:	c3a1                	beqz	a5,8000382c <ialloc+0x9c>
    brelse(bp);
    800037ee:	00000097          	auipc	ra,0x0
    800037f2:	a54080e7          	jalr	-1452(ra) # 80003242 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037f6:	0485                	addi	s1,s1,1
    800037f8:	00ca2703          	lw	a4,12(s4)
    800037fc:	0004879b          	sext.w	a5,s1
    80003800:	fce7e1e3          	bltu	a5,a4,800037c2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003804:	00005517          	auipc	a0,0x5
    80003808:	da450513          	addi	a0,a0,-604 # 800085a8 <syscalls+0x168>
    8000380c:	ffffd097          	auipc	ra,0xffffd
    80003810:	d7c080e7          	jalr	-644(ra) # 80000588 <printf>
  return 0;
    80003814:	4501                	li	a0,0
}
    80003816:	60a6                	ld	ra,72(sp)
    80003818:	6406                	ld	s0,64(sp)
    8000381a:	74e2                	ld	s1,56(sp)
    8000381c:	7942                	ld	s2,48(sp)
    8000381e:	79a2                	ld	s3,40(sp)
    80003820:	7a02                	ld	s4,32(sp)
    80003822:	6ae2                	ld	s5,24(sp)
    80003824:	6b42                	ld	s6,16(sp)
    80003826:	6ba2                	ld	s7,8(sp)
    80003828:	6161                	addi	sp,sp,80
    8000382a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000382c:	04000613          	li	a2,64
    80003830:	4581                	li	a1,0
    80003832:	854e                	mv	a0,s3
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	49e080e7          	jalr	1182(ra) # 80000cd2 <memset>
      dip->type = type;
    8000383c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003840:	854a                	mv	a0,s2
    80003842:	00001097          	auipc	ra,0x1
    80003846:	c84080e7          	jalr	-892(ra) # 800044c6 <log_write>
      brelse(bp);
    8000384a:	854a                	mv	a0,s2
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	9f6080e7          	jalr	-1546(ra) # 80003242 <brelse>
      return iget(dev, inum);
    80003854:	85da                	mv	a1,s6
    80003856:	8556                	mv	a0,s5
    80003858:	00000097          	auipc	ra,0x0
    8000385c:	d9c080e7          	jalr	-612(ra) # 800035f4 <iget>
    80003860:	bf5d                	j	80003816 <ialloc+0x86>

0000000080003862 <iupdate>:
{
    80003862:	1101                	addi	sp,sp,-32
    80003864:	ec06                	sd	ra,24(sp)
    80003866:	e822                	sd	s0,16(sp)
    80003868:	e426                	sd	s1,8(sp)
    8000386a:	e04a                	sd	s2,0(sp)
    8000386c:	1000                	addi	s0,sp,32
    8000386e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003870:	415c                	lw	a5,4(a0)
    80003872:	0047d79b          	srliw	a5,a5,0x4
    80003876:	0001d597          	auipc	a1,0x1d
    8000387a:	dea5a583          	lw	a1,-534(a1) # 80020660 <sb+0x18>
    8000387e:	9dbd                	addw	a1,a1,a5
    80003880:	4108                	lw	a0,0(a0)
    80003882:	00000097          	auipc	ra,0x0
    80003886:	890080e7          	jalr	-1904(ra) # 80003112 <bread>
    8000388a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000388c:	05850793          	addi	a5,a0,88
    80003890:	40c8                	lw	a0,4(s1)
    80003892:	893d                	andi	a0,a0,15
    80003894:	051a                	slli	a0,a0,0x6
    80003896:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003898:	04449703          	lh	a4,68(s1)
    8000389c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038a0:	04649703          	lh	a4,70(s1)
    800038a4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038a8:	04849703          	lh	a4,72(s1)
    800038ac:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038b0:	04a49703          	lh	a4,74(s1)
    800038b4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038b8:	44f8                	lw	a4,76(s1)
    800038ba:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038bc:	03400613          	li	a2,52
    800038c0:	05048593          	addi	a1,s1,80
    800038c4:	0531                	addi	a0,a0,12
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	468080e7          	jalr	1128(ra) # 80000d2e <memmove>
  log_write(bp);
    800038ce:	854a                	mv	a0,s2
    800038d0:	00001097          	auipc	ra,0x1
    800038d4:	bf6080e7          	jalr	-1034(ra) # 800044c6 <log_write>
  brelse(bp);
    800038d8:	854a                	mv	a0,s2
    800038da:	00000097          	auipc	ra,0x0
    800038de:	968080e7          	jalr	-1688(ra) # 80003242 <brelse>
}
    800038e2:	60e2                	ld	ra,24(sp)
    800038e4:	6442                	ld	s0,16(sp)
    800038e6:	64a2                	ld	s1,8(sp)
    800038e8:	6902                	ld	s2,0(sp)
    800038ea:	6105                	addi	sp,sp,32
    800038ec:	8082                	ret

00000000800038ee <idup>:
{
    800038ee:	1101                	addi	sp,sp,-32
    800038f0:	ec06                	sd	ra,24(sp)
    800038f2:	e822                	sd	s0,16(sp)
    800038f4:	e426                	sd	s1,8(sp)
    800038f6:	1000                	addi	s0,sp,32
    800038f8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038fa:	0001d517          	auipc	a0,0x1d
    800038fe:	d6e50513          	addi	a0,a0,-658 # 80020668 <itable>
    80003902:	ffffd097          	auipc	ra,0xffffd
    80003906:	2d4080e7          	jalr	724(ra) # 80000bd6 <acquire>
  ip->ref++;
    8000390a:	449c                	lw	a5,8(s1)
    8000390c:	2785                	addiw	a5,a5,1
    8000390e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003910:	0001d517          	auipc	a0,0x1d
    80003914:	d5850513          	addi	a0,a0,-680 # 80020668 <itable>
    80003918:	ffffd097          	auipc	ra,0xffffd
    8000391c:	372080e7          	jalr	882(ra) # 80000c8a <release>
}
    80003920:	8526                	mv	a0,s1
    80003922:	60e2                	ld	ra,24(sp)
    80003924:	6442                	ld	s0,16(sp)
    80003926:	64a2                	ld	s1,8(sp)
    80003928:	6105                	addi	sp,sp,32
    8000392a:	8082                	ret

000000008000392c <ilock>:
{
    8000392c:	1101                	addi	sp,sp,-32
    8000392e:	ec06                	sd	ra,24(sp)
    80003930:	e822                	sd	s0,16(sp)
    80003932:	e426                	sd	s1,8(sp)
    80003934:	e04a                	sd	s2,0(sp)
    80003936:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003938:	c115                	beqz	a0,8000395c <ilock+0x30>
    8000393a:	84aa                	mv	s1,a0
    8000393c:	451c                	lw	a5,8(a0)
    8000393e:	00f05f63          	blez	a5,8000395c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003942:	0541                	addi	a0,a0,16
    80003944:	00001097          	auipc	ra,0x1
    80003948:	ca2080e7          	jalr	-862(ra) # 800045e6 <acquiresleep>
  if(ip->valid == 0){
    8000394c:	40bc                	lw	a5,64(s1)
    8000394e:	cf99                	beqz	a5,8000396c <ilock+0x40>
}
    80003950:	60e2                	ld	ra,24(sp)
    80003952:	6442                	ld	s0,16(sp)
    80003954:	64a2                	ld	s1,8(sp)
    80003956:	6902                	ld	s2,0(sp)
    80003958:	6105                	addi	sp,sp,32
    8000395a:	8082                	ret
    panic("ilock");
    8000395c:	00005517          	auipc	a0,0x5
    80003960:	c6450513          	addi	a0,a0,-924 # 800085c0 <syscalls+0x180>
    80003964:	ffffd097          	auipc	ra,0xffffd
    80003968:	bda080e7          	jalr	-1062(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000396c:	40dc                	lw	a5,4(s1)
    8000396e:	0047d79b          	srliw	a5,a5,0x4
    80003972:	0001d597          	auipc	a1,0x1d
    80003976:	cee5a583          	lw	a1,-786(a1) # 80020660 <sb+0x18>
    8000397a:	9dbd                	addw	a1,a1,a5
    8000397c:	4088                	lw	a0,0(s1)
    8000397e:	fffff097          	auipc	ra,0xfffff
    80003982:	794080e7          	jalr	1940(ra) # 80003112 <bread>
    80003986:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003988:	05850593          	addi	a1,a0,88
    8000398c:	40dc                	lw	a5,4(s1)
    8000398e:	8bbd                	andi	a5,a5,15
    80003990:	079a                	slli	a5,a5,0x6
    80003992:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003994:	00059783          	lh	a5,0(a1)
    80003998:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000399c:	00259783          	lh	a5,2(a1)
    800039a0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039a4:	00459783          	lh	a5,4(a1)
    800039a8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039ac:	00659783          	lh	a5,6(a1)
    800039b0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039b4:	459c                	lw	a5,8(a1)
    800039b6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039b8:	03400613          	li	a2,52
    800039bc:	05b1                	addi	a1,a1,12
    800039be:	05048513          	addi	a0,s1,80
    800039c2:	ffffd097          	auipc	ra,0xffffd
    800039c6:	36c080e7          	jalr	876(ra) # 80000d2e <memmove>
    brelse(bp);
    800039ca:	854a                	mv	a0,s2
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	876080e7          	jalr	-1930(ra) # 80003242 <brelse>
    ip->valid = 1;
    800039d4:	4785                	li	a5,1
    800039d6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039d8:	04449783          	lh	a5,68(s1)
    800039dc:	fbb5                	bnez	a5,80003950 <ilock+0x24>
      panic("ilock: no type");
    800039de:	00005517          	auipc	a0,0x5
    800039e2:	bea50513          	addi	a0,a0,-1046 # 800085c8 <syscalls+0x188>
    800039e6:	ffffd097          	auipc	ra,0xffffd
    800039ea:	b58080e7          	jalr	-1192(ra) # 8000053e <panic>

00000000800039ee <iunlock>:
{
    800039ee:	1101                	addi	sp,sp,-32
    800039f0:	ec06                	sd	ra,24(sp)
    800039f2:	e822                	sd	s0,16(sp)
    800039f4:	e426                	sd	s1,8(sp)
    800039f6:	e04a                	sd	s2,0(sp)
    800039f8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039fa:	c905                	beqz	a0,80003a2a <iunlock+0x3c>
    800039fc:	84aa                	mv	s1,a0
    800039fe:	01050913          	addi	s2,a0,16
    80003a02:	854a                	mv	a0,s2
    80003a04:	00001097          	auipc	ra,0x1
    80003a08:	c7c080e7          	jalr	-900(ra) # 80004680 <holdingsleep>
    80003a0c:	cd19                	beqz	a0,80003a2a <iunlock+0x3c>
    80003a0e:	449c                	lw	a5,8(s1)
    80003a10:	00f05d63          	blez	a5,80003a2a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a14:	854a                	mv	a0,s2
    80003a16:	00001097          	auipc	ra,0x1
    80003a1a:	c26080e7          	jalr	-986(ra) # 8000463c <releasesleep>
}
    80003a1e:	60e2                	ld	ra,24(sp)
    80003a20:	6442                	ld	s0,16(sp)
    80003a22:	64a2                	ld	s1,8(sp)
    80003a24:	6902                	ld	s2,0(sp)
    80003a26:	6105                	addi	sp,sp,32
    80003a28:	8082                	ret
    panic("iunlock");
    80003a2a:	00005517          	auipc	a0,0x5
    80003a2e:	bae50513          	addi	a0,a0,-1106 # 800085d8 <syscalls+0x198>
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	b0c080e7          	jalr	-1268(ra) # 8000053e <panic>

0000000080003a3a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a3a:	7179                	addi	sp,sp,-48
    80003a3c:	f406                	sd	ra,40(sp)
    80003a3e:	f022                	sd	s0,32(sp)
    80003a40:	ec26                	sd	s1,24(sp)
    80003a42:	e84a                	sd	s2,16(sp)
    80003a44:	e44e                	sd	s3,8(sp)
    80003a46:	e052                	sd	s4,0(sp)
    80003a48:	1800                	addi	s0,sp,48
    80003a4a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a4c:	05050493          	addi	s1,a0,80
    80003a50:	08050913          	addi	s2,a0,128
    80003a54:	a021                	j	80003a5c <itrunc+0x22>
    80003a56:	0491                	addi	s1,s1,4
    80003a58:	01248d63          	beq	s1,s2,80003a72 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a5c:	408c                	lw	a1,0(s1)
    80003a5e:	dde5                	beqz	a1,80003a56 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a60:	0009a503          	lw	a0,0(s3)
    80003a64:	00000097          	auipc	ra,0x0
    80003a68:	8f4080e7          	jalr	-1804(ra) # 80003358 <bfree>
      ip->addrs[i] = 0;
    80003a6c:	0004a023          	sw	zero,0(s1)
    80003a70:	b7dd                	j	80003a56 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a72:	0809a583          	lw	a1,128(s3)
    80003a76:	e185                	bnez	a1,80003a96 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a78:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a7c:	854e                	mv	a0,s3
    80003a7e:	00000097          	auipc	ra,0x0
    80003a82:	de4080e7          	jalr	-540(ra) # 80003862 <iupdate>
}
    80003a86:	70a2                	ld	ra,40(sp)
    80003a88:	7402                	ld	s0,32(sp)
    80003a8a:	64e2                	ld	s1,24(sp)
    80003a8c:	6942                	ld	s2,16(sp)
    80003a8e:	69a2                	ld	s3,8(sp)
    80003a90:	6a02                	ld	s4,0(sp)
    80003a92:	6145                	addi	sp,sp,48
    80003a94:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a96:	0009a503          	lw	a0,0(s3)
    80003a9a:	fffff097          	auipc	ra,0xfffff
    80003a9e:	678080e7          	jalr	1656(ra) # 80003112 <bread>
    80003aa2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003aa4:	05850493          	addi	s1,a0,88
    80003aa8:	45850913          	addi	s2,a0,1112
    80003aac:	a021                	j	80003ab4 <itrunc+0x7a>
    80003aae:	0491                	addi	s1,s1,4
    80003ab0:	01248b63          	beq	s1,s2,80003ac6 <itrunc+0x8c>
      if(a[j])
    80003ab4:	408c                	lw	a1,0(s1)
    80003ab6:	dde5                	beqz	a1,80003aae <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003ab8:	0009a503          	lw	a0,0(s3)
    80003abc:	00000097          	auipc	ra,0x0
    80003ac0:	89c080e7          	jalr	-1892(ra) # 80003358 <bfree>
    80003ac4:	b7ed                	j	80003aae <itrunc+0x74>
    brelse(bp);
    80003ac6:	8552                	mv	a0,s4
    80003ac8:	fffff097          	auipc	ra,0xfffff
    80003acc:	77a080e7          	jalr	1914(ra) # 80003242 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ad0:	0809a583          	lw	a1,128(s3)
    80003ad4:	0009a503          	lw	a0,0(s3)
    80003ad8:	00000097          	auipc	ra,0x0
    80003adc:	880080e7          	jalr	-1920(ra) # 80003358 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ae0:	0809a023          	sw	zero,128(s3)
    80003ae4:	bf51                	j	80003a78 <itrunc+0x3e>

0000000080003ae6 <iput>:
{
    80003ae6:	1101                	addi	sp,sp,-32
    80003ae8:	ec06                	sd	ra,24(sp)
    80003aea:	e822                	sd	s0,16(sp)
    80003aec:	e426                	sd	s1,8(sp)
    80003aee:	e04a                	sd	s2,0(sp)
    80003af0:	1000                	addi	s0,sp,32
    80003af2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003af4:	0001d517          	auipc	a0,0x1d
    80003af8:	b7450513          	addi	a0,a0,-1164 # 80020668 <itable>
    80003afc:	ffffd097          	auipc	ra,0xffffd
    80003b00:	0da080e7          	jalr	218(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b04:	4498                	lw	a4,8(s1)
    80003b06:	4785                	li	a5,1
    80003b08:	02f70363          	beq	a4,a5,80003b2e <iput+0x48>
  ip->ref--;
    80003b0c:	449c                	lw	a5,8(s1)
    80003b0e:	37fd                	addiw	a5,a5,-1
    80003b10:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b12:	0001d517          	auipc	a0,0x1d
    80003b16:	b5650513          	addi	a0,a0,-1194 # 80020668 <itable>
    80003b1a:	ffffd097          	auipc	ra,0xffffd
    80003b1e:	170080e7          	jalr	368(ra) # 80000c8a <release>
}
    80003b22:	60e2                	ld	ra,24(sp)
    80003b24:	6442                	ld	s0,16(sp)
    80003b26:	64a2                	ld	s1,8(sp)
    80003b28:	6902                	ld	s2,0(sp)
    80003b2a:	6105                	addi	sp,sp,32
    80003b2c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b2e:	40bc                	lw	a5,64(s1)
    80003b30:	dff1                	beqz	a5,80003b0c <iput+0x26>
    80003b32:	04a49783          	lh	a5,74(s1)
    80003b36:	fbf9                	bnez	a5,80003b0c <iput+0x26>
    acquiresleep(&ip->lock);
    80003b38:	01048913          	addi	s2,s1,16
    80003b3c:	854a                	mv	a0,s2
    80003b3e:	00001097          	auipc	ra,0x1
    80003b42:	aa8080e7          	jalr	-1368(ra) # 800045e6 <acquiresleep>
    release(&itable.lock);
    80003b46:	0001d517          	auipc	a0,0x1d
    80003b4a:	b2250513          	addi	a0,a0,-1246 # 80020668 <itable>
    80003b4e:	ffffd097          	auipc	ra,0xffffd
    80003b52:	13c080e7          	jalr	316(ra) # 80000c8a <release>
    itrunc(ip);
    80003b56:	8526                	mv	a0,s1
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	ee2080e7          	jalr	-286(ra) # 80003a3a <itrunc>
    ip->type = 0;
    80003b60:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b64:	8526                	mv	a0,s1
    80003b66:	00000097          	auipc	ra,0x0
    80003b6a:	cfc080e7          	jalr	-772(ra) # 80003862 <iupdate>
    ip->valid = 0;
    80003b6e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b72:	854a                	mv	a0,s2
    80003b74:	00001097          	auipc	ra,0x1
    80003b78:	ac8080e7          	jalr	-1336(ra) # 8000463c <releasesleep>
    acquire(&itable.lock);
    80003b7c:	0001d517          	auipc	a0,0x1d
    80003b80:	aec50513          	addi	a0,a0,-1300 # 80020668 <itable>
    80003b84:	ffffd097          	auipc	ra,0xffffd
    80003b88:	052080e7          	jalr	82(ra) # 80000bd6 <acquire>
    80003b8c:	b741                	j	80003b0c <iput+0x26>

0000000080003b8e <iunlockput>:
{
    80003b8e:	1101                	addi	sp,sp,-32
    80003b90:	ec06                	sd	ra,24(sp)
    80003b92:	e822                	sd	s0,16(sp)
    80003b94:	e426                	sd	s1,8(sp)
    80003b96:	1000                	addi	s0,sp,32
    80003b98:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	e54080e7          	jalr	-428(ra) # 800039ee <iunlock>
  iput(ip);
    80003ba2:	8526                	mv	a0,s1
    80003ba4:	00000097          	auipc	ra,0x0
    80003ba8:	f42080e7          	jalr	-190(ra) # 80003ae6 <iput>
}
    80003bac:	60e2                	ld	ra,24(sp)
    80003bae:	6442                	ld	s0,16(sp)
    80003bb0:	64a2                	ld	s1,8(sp)
    80003bb2:	6105                	addi	sp,sp,32
    80003bb4:	8082                	ret

0000000080003bb6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bb6:	1141                	addi	sp,sp,-16
    80003bb8:	e422                	sd	s0,8(sp)
    80003bba:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bbc:	411c                	lw	a5,0(a0)
    80003bbe:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bc0:	415c                	lw	a5,4(a0)
    80003bc2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bc4:	04451783          	lh	a5,68(a0)
    80003bc8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bcc:	04a51783          	lh	a5,74(a0)
    80003bd0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bd4:	04c56783          	lwu	a5,76(a0)
    80003bd8:	e99c                	sd	a5,16(a1)
}
    80003bda:	6422                	ld	s0,8(sp)
    80003bdc:	0141                	addi	sp,sp,16
    80003bde:	8082                	ret

0000000080003be0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003be0:	457c                	lw	a5,76(a0)
    80003be2:	0ed7e963          	bltu	a5,a3,80003cd4 <readi+0xf4>
{
    80003be6:	7159                	addi	sp,sp,-112
    80003be8:	f486                	sd	ra,104(sp)
    80003bea:	f0a2                	sd	s0,96(sp)
    80003bec:	eca6                	sd	s1,88(sp)
    80003bee:	e8ca                	sd	s2,80(sp)
    80003bf0:	e4ce                	sd	s3,72(sp)
    80003bf2:	e0d2                	sd	s4,64(sp)
    80003bf4:	fc56                	sd	s5,56(sp)
    80003bf6:	f85a                	sd	s6,48(sp)
    80003bf8:	f45e                	sd	s7,40(sp)
    80003bfa:	f062                	sd	s8,32(sp)
    80003bfc:	ec66                	sd	s9,24(sp)
    80003bfe:	e86a                	sd	s10,16(sp)
    80003c00:	e46e                	sd	s11,8(sp)
    80003c02:	1880                	addi	s0,sp,112
    80003c04:	8b2a                	mv	s6,a0
    80003c06:	8bae                	mv	s7,a1
    80003c08:	8a32                	mv	s4,a2
    80003c0a:	84b6                	mv	s1,a3
    80003c0c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c0e:	9f35                	addw	a4,a4,a3
    return 0;
    80003c10:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c12:	0ad76063          	bltu	a4,a3,80003cb2 <readi+0xd2>
  if(off + n > ip->size)
    80003c16:	00e7f463          	bgeu	a5,a4,80003c1e <readi+0x3e>
    n = ip->size - off;
    80003c1a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c1e:	0a0a8963          	beqz	s5,80003cd0 <readi+0xf0>
    80003c22:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c24:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c28:	5c7d                	li	s8,-1
    80003c2a:	a82d                	j	80003c64 <readi+0x84>
    80003c2c:	020d1d93          	slli	s11,s10,0x20
    80003c30:	020ddd93          	srli	s11,s11,0x20
    80003c34:	05890793          	addi	a5,s2,88
    80003c38:	86ee                	mv	a3,s11
    80003c3a:	963e                	add	a2,a2,a5
    80003c3c:	85d2                	mv	a1,s4
    80003c3e:	855e                	mv	a0,s7
    80003c40:	fffff097          	auipc	ra,0xfffff
    80003c44:	8de080e7          	jalr	-1826(ra) # 8000251e <either_copyout>
    80003c48:	05850d63          	beq	a0,s8,80003ca2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c4c:	854a                	mv	a0,s2
    80003c4e:	fffff097          	auipc	ra,0xfffff
    80003c52:	5f4080e7          	jalr	1524(ra) # 80003242 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c56:	013d09bb          	addw	s3,s10,s3
    80003c5a:	009d04bb          	addw	s1,s10,s1
    80003c5e:	9a6e                	add	s4,s4,s11
    80003c60:	0559f763          	bgeu	s3,s5,80003cae <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c64:	00a4d59b          	srliw	a1,s1,0xa
    80003c68:	855a                	mv	a0,s6
    80003c6a:	00000097          	auipc	ra,0x0
    80003c6e:	8a2080e7          	jalr	-1886(ra) # 8000350c <bmap>
    80003c72:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c76:	cd85                	beqz	a1,80003cae <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c78:	000b2503          	lw	a0,0(s6)
    80003c7c:	fffff097          	auipc	ra,0xfffff
    80003c80:	496080e7          	jalr	1174(ra) # 80003112 <bread>
    80003c84:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c86:	3ff4f613          	andi	a2,s1,1023
    80003c8a:	40cc87bb          	subw	a5,s9,a2
    80003c8e:	413a873b          	subw	a4,s5,s3
    80003c92:	8d3e                	mv	s10,a5
    80003c94:	2781                	sext.w	a5,a5
    80003c96:	0007069b          	sext.w	a3,a4
    80003c9a:	f8f6f9e3          	bgeu	a3,a5,80003c2c <readi+0x4c>
    80003c9e:	8d3a                	mv	s10,a4
    80003ca0:	b771                	j	80003c2c <readi+0x4c>
      brelse(bp);
    80003ca2:	854a                	mv	a0,s2
    80003ca4:	fffff097          	auipc	ra,0xfffff
    80003ca8:	59e080e7          	jalr	1438(ra) # 80003242 <brelse>
      tot = -1;
    80003cac:	59fd                	li	s3,-1
  }
  return tot;
    80003cae:	0009851b          	sext.w	a0,s3
}
    80003cb2:	70a6                	ld	ra,104(sp)
    80003cb4:	7406                	ld	s0,96(sp)
    80003cb6:	64e6                	ld	s1,88(sp)
    80003cb8:	6946                	ld	s2,80(sp)
    80003cba:	69a6                	ld	s3,72(sp)
    80003cbc:	6a06                	ld	s4,64(sp)
    80003cbe:	7ae2                	ld	s5,56(sp)
    80003cc0:	7b42                	ld	s6,48(sp)
    80003cc2:	7ba2                	ld	s7,40(sp)
    80003cc4:	7c02                	ld	s8,32(sp)
    80003cc6:	6ce2                	ld	s9,24(sp)
    80003cc8:	6d42                	ld	s10,16(sp)
    80003cca:	6da2                	ld	s11,8(sp)
    80003ccc:	6165                	addi	sp,sp,112
    80003cce:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cd0:	89d6                	mv	s3,s5
    80003cd2:	bff1                	j	80003cae <readi+0xce>
    return 0;
    80003cd4:	4501                	li	a0,0
}
    80003cd6:	8082                	ret

0000000080003cd8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cd8:	457c                	lw	a5,76(a0)
    80003cda:	10d7e863          	bltu	a5,a3,80003dea <writei+0x112>
{
    80003cde:	7159                	addi	sp,sp,-112
    80003ce0:	f486                	sd	ra,104(sp)
    80003ce2:	f0a2                	sd	s0,96(sp)
    80003ce4:	eca6                	sd	s1,88(sp)
    80003ce6:	e8ca                	sd	s2,80(sp)
    80003ce8:	e4ce                	sd	s3,72(sp)
    80003cea:	e0d2                	sd	s4,64(sp)
    80003cec:	fc56                	sd	s5,56(sp)
    80003cee:	f85a                	sd	s6,48(sp)
    80003cf0:	f45e                	sd	s7,40(sp)
    80003cf2:	f062                	sd	s8,32(sp)
    80003cf4:	ec66                	sd	s9,24(sp)
    80003cf6:	e86a                	sd	s10,16(sp)
    80003cf8:	e46e                	sd	s11,8(sp)
    80003cfa:	1880                	addi	s0,sp,112
    80003cfc:	8aaa                	mv	s5,a0
    80003cfe:	8bae                	mv	s7,a1
    80003d00:	8a32                	mv	s4,a2
    80003d02:	8936                	mv	s2,a3
    80003d04:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d06:	00e687bb          	addw	a5,a3,a4
    80003d0a:	0ed7e263          	bltu	a5,a3,80003dee <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d0e:	00043737          	lui	a4,0x43
    80003d12:	0ef76063          	bltu	a4,a5,80003df2 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d16:	0c0b0863          	beqz	s6,80003de6 <writei+0x10e>
    80003d1a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d1c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d20:	5c7d                	li	s8,-1
    80003d22:	a091                	j	80003d66 <writei+0x8e>
    80003d24:	020d1d93          	slli	s11,s10,0x20
    80003d28:	020ddd93          	srli	s11,s11,0x20
    80003d2c:	05848793          	addi	a5,s1,88
    80003d30:	86ee                	mv	a3,s11
    80003d32:	8652                	mv	a2,s4
    80003d34:	85de                	mv	a1,s7
    80003d36:	953e                	add	a0,a0,a5
    80003d38:	fffff097          	auipc	ra,0xfffff
    80003d3c:	83e080e7          	jalr	-1986(ra) # 80002576 <either_copyin>
    80003d40:	07850263          	beq	a0,s8,80003da4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d44:	8526                	mv	a0,s1
    80003d46:	00000097          	auipc	ra,0x0
    80003d4a:	780080e7          	jalr	1920(ra) # 800044c6 <log_write>
    brelse(bp);
    80003d4e:	8526                	mv	a0,s1
    80003d50:	fffff097          	auipc	ra,0xfffff
    80003d54:	4f2080e7          	jalr	1266(ra) # 80003242 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d58:	013d09bb          	addw	s3,s10,s3
    80003d5c:	012d093b          	addw	s2,s10,s2
    80003d60:	9a6e                	add	s4,s4,s11
    80003d62:	0569f663          	bgeu	s3,s6,80003dae <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d66:	00a9559b          	srliw	a1,s2,0xa
    80003d6a:	8556                	mv	a0,s5
    80003d6c:	fffff097          	auipc	ra,0xfffff
    80003d70:	7a0080e7          	jalr	1952(ra) # 8000350c <bmap>
    80003d74:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d78:	c99d                	beqz	a1,80003dae <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d7a:	000aa503          	lw	a0,0(s5)
    80003d7e:	fffff097          	auipc	ra,0xfffff
    80003d82:	394080e7          	jalr	916(ra) # 80003112 <bread>
    80003d86:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d88:	3ff97513          	andi	a0,s2,1023
    80003d8c:	40ac87bb          	subw	a5,s9,a0
    80003d90:	413b073b          	subw	a4,s6,s3
    80003d94:	8d3e                	mv	s10,a5
    80003d96:	2781                	sext.w	a5,a5
    80003d98:	0007069b          	sext.w	a3,a4
    80003d9c:	f8f6f4e3          	bgeu	a3,a5,80003d24 <writei+0x4c>
    80003da0:	8d3a                	mv	s10,a4
    80003da2:	b749                	j	80003d24 <writei+0x4c>
      brelse(bp);
    80003da4:	8526                	mv	a0,s1
    80003da6:	fffff097          	auipc	ra,0xfffff
    80003daa:	49c080e7          	jalr	1180(ra) # 80003242 <brelse>
  }

  if(off > ip->size)
    80003dae:	04caa783          	lw	a5,76(s5)
    80003db2:	0127f463          	bgeu	a5,s2,80003dba <writei+0xe2>
    ip->size = off;
    80003db6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003dba:	8556                	mv	a0,s5
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	aa6080e7          	jalr	-1370(ra) # 80003862 <iupdate>

  return tot;
    80003dc4:	0009851b          	sext.w	a0,s3
}
    80003dc8:	70a6                	ld	ra,104(sp)
    80003dca:	7406                	ld	s0,96(sp)
    80003dcc:	64e6                	ld	s1,88(sp)
    80003dce:	6946                	ld	s2,80(sp)
    80003dd0:	69a6                	ld	s3,72(sp)
    80003dd2:	6a06                	ld	s4,64(sp)
    80003dd4:	7ae2                	ld	s5,56(sp)
    80003dd6:	7b42                	ld	s6,48(sp)
    80003dd8:	7ba2                	ld	s7,40(sp)
    80003dda:	7c02                	ld	s8,32(sp)
    80003ddc:	6ce2                	ld	s9,24(sp)
    80003dde:	6d42                	ld	s10,16(sp)
    80003de0:	6da2                	ld	s11,8(sp)
    80003de2:	6165                	addi	sp,sp,112
    80003de4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003de6:	89da                	mv	s3,s6
    80003de8:	bfc9                	j	80003dba <writei+0xe2>
    return -1;
    80003dea:	557d                	li	a0,-1
}
    80003dec:	8082                	ret
    return -1;
    80003dee:	557d                	li	a0,-1
    80003df0:	bfe1                	j	80003dc8 <writei+0xf0>
    return -1;
    80003df2:	557d                	li	a0,-1
    80003df4:	bfd1                	j	80003dc8 <writei+0xf0>

0000000080003df6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003df6:	1141                	addi	sp,sp,-16
    80003df8:	e406                	sd	ra,8(sp)
    80003dfa:	e022                	sd	s0,0(sp)
    80003dfc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dfe:	4639                	li	a2,14
    80003e00:	ffffd097          	auipc	ra,0xffffd
    80003e04:	fa2080e7          	jalr	-94(ra) # 80000da2 <strncmp>
}
    80003e08:	60a2                	ld	ra,8(sp)
    80003e0a:	6402                	ld	s0,0(sp)
    80003e0c:	0141                	addi	sp,sp,16
    80003e0e:	8082                	ret

0000000080003e10 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e10:	7139                	addi	sp,sp,-64
    80003e12:	fc06                	sd	ra,56(sp)
    80003e14:	f822                	sd	s0,48(sp)
    80003e16:	f426                	sd	s1,40(sp)
    80003e18:	f04a                	sd	s2,32(sp)
    80003e1a:	ec4e                	sd	s3,24(sp)
    80003e1c:	e852                	sd	s4,16(sp)
    80003e1e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e20:	04451703          	lh	a4,68(a0)
    80003e24:	4785                	li	a5,1
    80003e26:	00f71a63          	bne	a4,a5,80003e3a <dirlookup+0x2a>
    80003e2a:	892a                	mv	s2,a0
    80003e2c:	89ae                	mv	s3,a1
    80003e2e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e30:	457c                	lw	a5,76(a0)
    80003e32:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e34:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e36:	e79d                	bnez	a5,80003e64 <dirlookup+0x54>
    80003e38:	a8a5                	j	80003eb0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e3a:	00004517          	auipc	a0,0x4
    80003e3e:	7a650513          	addi	a0,a0,1958 # 800085e0 <syscalls+0x1a0>
    80003e42:	ffffc097          	auipc	ra,0xffffc
    80003e46:	6fc080e7          	jalr	1788(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003e4a:	00004517          	auipc	a0,0x4
    80003e4e:	7ae50513          	addi	a0,a0,1966 # 800085f8 <syscalls+0x1b8>
    80003e52:	ffffc097          	auipc	ra,0xffffc
    80003e56:	6ec080e7          	jalr	1772(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e5a:	24c1                	addiw	s1,s1,16
    80003e5c:	04c92783          	lw	a5,76(s2)
    80003e60:	04f4f763          	bgeu	s1,a5,80003eae <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e64:	4741                	li	a4,16
    80003e66:	86a6                	mv	a3,s1
    80003e68:	fc040613          	addi	a2,s0,-64
    80003e6c:	4581                	li	a1,0
    80003e6e:	854a                	mv	a0,s2
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	d70080e7          	jalr	-656(ra) # 80003be0 <readi>
    80003e78:	47c1                	li	a5,16
    80003e7a:	fcf518e3          	bne	a0,a5,80003e4a <dirlookup+0x3a>
    if(de.inum == 0)
    80003e7e:	fc045783          	lhu	a5,-64(s0)
    80003e82:	dfe1                	beqz	a5,80003e5a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e84:	fc240593          	addi	a1,s0,-62
    80003e88:	854e                	mv	a0,s3
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	f6c080e7          	jalr	-148(ra) # 80003df6 <namecmp>
    80003e92:	f561                	bnez	a0,80003e5a <dirlookup+0x4a>
      if(poff)
    80003e94:	000a0463          	beqz	s4,80003e9c <dirlookup+0x8c>
        *poff = off;
    80003e98:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e9c:	fc045583          	lhu	a1,-64(s0)
    80003ea0:	00092503          	lw	a0,0(s2)
    80003ea4:	fffff097          	auipc	ra,0xfffff
    80003ea8:	750080e7          	jalr	1872(ra) # 800035f4 <iget>
    80003eac:	a011                	j	80003eb0 <dirlookup+0xa0>
  return 0;
    80003eae:	4501                	li	a0,0
}
    80003eb0:	70e2                	ld	ra,56(sp)
    80003eb2:	7442                	ld	s0,48(sp)
    80003eb4:	74a2                	ld	s1,40(sp)
    80003eb6:	7902                	ld	s2,32(sp)
    80003eb8:	69e2                	ld	s3,24(sp)
    80003eba:	6a42                	ld	s4,16(sp)
    80003ebc:	6121                	addi	sp,sp,64
    80003ebe:	8082                	ret

0000000080003ec0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ec0:	711d                	addi	sp,sp,-96
    80003ec2:	ec86                	sd	ra,88(sp)
    80003ec4:	e8a2                	sd	s0,80(sp)
    80003ec6:	e4a6                	sd	s1,72(sp)
    80003ec8:	e0ca                	sd	s2,64(sp)
    80003eca:	fc4e                	sd	s3,56(sp)
    80003ecc:	f852                	sd	s4,48(sp)
    80003ece:	f456                	sd	s5,40(sp)
    80003ed0:	f05a                	sd	s6,32(sp)
    80003ed2:	ec5e                	sd	s7,24(sp)
    80003ed4:	e862                	sd	s8,16(sp)
    80003ed6:	e466                	sd	s9,8(sp)
    80003ed8:	1080                	addi	s0,sp,96
    80003eda:	84aa                	mv	s1,a0
    80003edc:	8aae                	mv	s5,a1
    80003ede:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ee0:	00054703          	lbu	a4,0(a0)
    80003ee4:	02f00793          	li	a5,47
    80003ee8:	02f70363          	beq	a4,a5,80003f0e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003eec:	ffffe097          	auipc	ra,0xffffe
    80003ef0:	a94080e7          	jalr	-1388(ra) # 80001980 <myproc>
    80003ef4:	18853503          	ld	a0,392(a0)
    80003ef8:	00000097          	auipc	ra,0x0
    80003efc:	9f6080e7          	jalr	-1546(ra) # 800038ee <idup>
    80003f00:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f02:	02f00913          	li	s2,47
  len = path - s;
    80003f06:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f08:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f0a:	4b85                	li	s7,1
    80003f0c:	a865                	j	80003fc4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f0e:	4585                	li	a1,1
    80003f10:	4505                	li	a0,1
    80003f12:	fffff097          	auipc	ra,0xfffff
    80003f16:	6e2080e7          	jalr	1762(ra) # 800035f4 <iget>
    80003f1a:	89aa                	mv	s3,a0
    80003f1c:	b7dd                	j	80003f02 <namex+0x42>
      iunlockput(ip);
    80003f1e:	854e                	mv	a0,s3
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	c6e080e7          	jalr	-914(ra) # 80003b8e <iunlockput>
      return 0;
    80003f28:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f2a:	854e                	mv	a0,s3
    80003f2c:	60e6                	ld	ra,88(sp)
    80003f2e:	6446                	ld	s0,80(sp)
    80003f30:	64a6                	ld	s1,72(sp)
    80003f32:	6906                	ld	s2,64(sp)
    80003f34:	79e2                	ld	s3,56(sp)
    80003f36:	7a42                	ld	s4,48(sp)
    80003f38:	7aa2                	ld	s5,40(sp)
    80003f3a:	7b02                	ld	s6,32(sp)
    80003f3c:	6be2                	ld	s7,24(sp)
    80003f3e:	6c42                	ld	s8,16(sp)
    80003f40:	6ca2                	ld	s9,8(sp)
    80003f42:	6125                	addi	sp,sp,96
    80003f44:	8082                	ret
      iunlock(ip);
    80003f46:	854e                	mv	a0,s3
    80003f48:	00000097          	auipc	ra,0x0
    80003f4c:	aa6080e7          	jalr	-1370(ra) # 800039ee <iunlock>
      return ip;
    80003f50:	bfe9                	j	80003f2a <namex+0x6a>
      iunlockput(ip);
    80003f52:	854e                	mv	a0,s3
    80003f54:	00000097          	auipc	ra,0x0
    80003f58:	c3a080e7          	jalr	-966(ra) # 80003b8e <iunlockput>
      return 0;
    80003f5c:	89e6                	mv	s3,s9
    80003f5e:	b7f1                	j	80003f2a <namex+0x6a>
  len = path - s;
    80003f60:	40b48633          	sub	a2,s1,a1
    80003f64:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f68:	099c5463          	bge	s8,s9,80003ff0 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f6c:	4639                	li	a2,14
    80003f6e:	8552                	mv	a0,s4
    80003f70:	ffffd097          	auipc	ra,0xffffd
    80003f74:	dbe080e7          	jalr	-578(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003f78:	0004c783          	lbu	a5,0(s1)
    80003f7c:	01279763          	bne	a5,s2,80003f8a <namex+0xca>
    path++;
    80003f80:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f82:	0004c783          	lbu	a5,0(s1)
    80003f86:	ff278de3          	beq	a5,s2,80003f80 <namex+0xc0>
    ilock(ip);
    80003f8a:	854e                	mv	a0,s3
    80003f8c:	00000097          	auipc	ra,0x0
    80003f90:	9a0080e7          	jalr	-1632(ra) # 8000392c <ilock>
    if(ip->type != T_DIR){
    80003f94:	04499783          	lh	a5,68(s3)
    80003f98:	f97793e3          	bne	a5,s7,80003f1e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f9c:	000a8563          	beqz	s5,80003fa6 <namex+0xe6>
    80003fa0:	0004c783          	lbu	a5,0(s1)
    80003fa4:	d3cd                	beqz	a5,80003f46 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fa6:	865a                	mv	a2,s6
    80003fa8:	85d2                	mv	a1,s4
    80003faa:	854e                	mv	a0,s3
    80003fac:	00000097          	auipc	ra,0x0
    80003fb0:	e64080e7          	jalr	-412(ra) # 80003e10 <dirlookup>
    80003fb4:	8caa                	mv	s9,a0
    80003fb6:	dd51                	beqz	a0,80003f52 <namex+0x92>
    iunlockput(ip);
    80003fb8:	854e                	mv	a0,s3
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	bd4080e7          	jalr	-1068(ra) # 80003b8e <iunlockput>
    ip = next;
    80003fc2:	89e6                	mv	s3,s9
  while(*path == '/')
    80003fc4:	0004c783          	lbu	a5,0(s1)
    80003fc8:	05279763          	bne	a5,s2,80004016 <namex+0x156>
    path++;
    80003fcc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fce:	0004c783          	lbu	a5,0(s1)
    80003fd2:	ff278de3          	beq	a5,s2,80003fcc <namex+0x10c>
  if(*path == 0)
    80003fd6:	c79d                	beqz	a5,80004004 <namex+0x144>
    path++;
    80003fd8:	85a6                	mv	a1,s1
  len = path - s;
    80003fda:	8cda                	mv	s9,s6
    80003fdc:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003fde:	01278963          	beq	a5,s2,80003ff0 <namex+0x130>
    80003fe2:	dfbd                	beqz	a5,80003f60 <namex+0xa0>
    path++;
    80003fe4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fe6:	0004c783          	lbu	a5,0(s1)
    80003fea:	ff279ce3          	bne	a5,s2,80003fe2 <namex+0x122>
    80003fee:	bf8d                	j	80003f60 <namex+0xa0>
    memmove(name, s, len);
    80003ff0:	2601                	sext.w	a2,a2
    80003ff2:	8552                	mv	a0,s4
    80003ff4:	ffffd097          	auipc	ra,0xffffd
    80003ff8:	d3a080e7          	jalr	-710(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003ffc:	9cd2                	add	s9,s9,s4
    80003ffe:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004002:	bf9d                	j	80003f78 <namex+0xb8>
  if(nameiparent){
    80004004:	f20a83e3          	beqz	s5,80003f2a <namex+0x6a>
    iput(ip);
    80004008:	854e                	mv	a0,s3
    8000400a:	00000097          	auipc	ra,0x0
    8000400e:	adc080e7          	jalr	-1316(ra) # 80003ae6 <iput>
    return 0;
    80004012:	4981                	li	s3,0
    80004014:	bf19                	j	80003f2a <namex+0x6a>
  if(*path == 0)
    80004016:	d7fd                	beqz	a5,80004004 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004018:	0004c783          	lbu	a5,0(s1)
    8000401c:	85a6                	mv	a1,s1
    8000401e:	b7d1                	j	80003fe2 <namex+0x122>

0000000080004020 <dirlink>:
{
    80004020:	7139                	addi	sp,sp,-64
    80004022:	fc06                	sd	ra,56(sp)
    80004024:	f822                	sd	s0,48(sp)
    80004026:	f426                	sd	s1,40(sp)
    80004028:	f04a                	sd	s2,32(sp)
    8000402a:	ec4e                	sd	s3,24(sp)
    8000402c:	e852                	sd	s4,16(sp)
    8000402e:	0080                	addi	s0,sp,64
    80004030:	892a                	mv	s2,a0
    80004032:	8a2e                	mv	s4,a1
    80004034:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004036:	4601                	li	a2,0
    80004038:	00000097          	auipc	ra,0x0
    8000403c:	dd8080e7          	jalr	-552(ra) # 80003e10 <dirlookup>
    80004040:	e93d                	bnez	a0,800040b6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004042:	04c92483          	lw	s1,76(s2)
    80004046:	c49d                	beqz	s1,80004074 <dirlink+0x54>
    80004048:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000404a:	4741                	li	a4,16
    8000404c:	86a6                	mv	a3,s1
    8000404e:	fc040613          	addi	a2,s0,-64
    80004052:	4581                	li	a1,0
    80004054:	854a                	mv	a0,s2
    80004056:	00000097          	auipc	ra,0x0
    8000405a:	b8a080e7          	jalr	-1142(ra) # 80003be0 <readi>
    8000405e:	47c1                	li	a5,16
    80004060:	06f51163          	bne	a0,a5,800040c2 <dirlink+0xa2>
    if(de.inum == 0)
    80004064:	fc045783          	lhu	a5,-64(s0)
    80004068:	c791                	beqz	a5,80004074 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000406a:	24c1                	addiw	s1,s1,16
    8000406c:	04c92783          	lw	a5,76(s2)
    80004070:	fcf4ede3          	bltu	s1,a5,8000404a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004074:	4639                	li	a2,14
    80004076:	85d2                	mv	a1,s4
    80004078:	fc240513          	addi	a0,s0,-62
    8000407c:	ffffd097          	auipc	ra,0xffffd
    80004080:	d62080e7          	jalr	-670(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004084:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004088:	4741                	li	a4,16
    8000408a:	86a6                	mv	a3,s1
    8000408c:	fc040613          	addi	a2,s0,-64
    80004090:	4581                	li	a1,0
    80004092:	854a                	mv	a0,s2
    80004094:	00000097          	auipc	ra,0x0
    80004098:	c44080e7          	jalr	-956(ra) # 80003cd8 <writei>
    8000409c:	1541                	addi	a0,a0,-16
    8000409e:	00a03533          	snez	a0,a0
    800040a2:	40a00533          	neg	a0,a0
}
    800040a6:	70e2                	ld	ra,56(sp)
    800040a8:	7442                	ld	s0,48(sp)
    800040aa:	74a2                	ld	s1,40(sp)
    800040ac:	7902                	ld	s2,32(sp)
    800040ae:	69e2                	ld	s3,24(sp)
    800040b0:	6a42                	ld	s4,16(sp)
    800040b2:	6121                	addi	sp,sp,64
    800040b4:	8082                	ret
    iput(ip);
    800040b6:	00000097          	auipc	ra,0x0
    800040ba:	a30080e7          	jalr	-1488(ra) # 80003ae6 <iput>
    return -1;
    800040be:	557d                	li	a0,-1
    800040c0:	b7dd                	j	800040a6 <dirlink+0x86>
      panic("dirlink read");
    800040c2:	00004517          	auipc	a0,0x4
    800040c6:	54650513          	addi	a0,a0,1350 # 80008608 <syscalls+0x1c8>
    800040ca:	ffffc097          	auipc	ra,0xffffc
    800040ce:	474080e7          	jalr	1140(ra) # 8000053e <panic>

00000000800040d2 <namei>:

struct inode*
namei(char *path)
{
    800040d2:	1101                	addi	sp,sp,-32
    800040d4:	ec06                	sd	ra,24(sp)
    800040d6:	e822                	sd	s0,16(sp)
    800040d8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040da:	fe040613          	addi	a2,s0,-32
    800040de:	4581                	li	a1,0
    800040e0:	00000097          	auipc	ra,0x0
    800040e4:	de0080e7          	jalr	-544(ra) # 80003ec0 <namex>
}
    800040e8:	60e2                	ld	ra,24(sp)
    800040ea:	6442                	ld	s0,16(sp)
    800040ec:	6105                	addi	sp,sp,32
    800040ee:	8082                	ret

00000000800040f0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040f0:	1141                	addi	sp,sp,-16
    800040f2:	e406                	sd	ra,8(sp)
    800040f4:	e022                	sd	s0,0(sp)
    800040f6:	0800                	addi	s0,sp,16
    800040f8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040fa:	4585                	li	a1,1
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	dc4080e7          	jalr	-572(ra) # 80003ec0 <namex>
}
    80004104:	60a2                	ld	ra,8(sp)
    80004106:	6402                	ld	s0,0(sp)
    80004108:	0141                	addi	sp,sp,16
    8000410a:	8082                	ret

000000008000410c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000410c:	1101                	addi	sp,sp,-32
    8000410e:	ec06                	sd	ra,24(sp)
    80004110:	e822                	sd	s0,16(sp)
    80004112:	e426                	sd	s1,8(sp)
    80004114:	e04a                	sd	s2,0(sp)
    80004116:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004118:	0001e917          	auipc	s2,0x1e
    8000411c:	ff890913          	addi	s2,s2,-8 # 80022110 <log>
    80004120:	01892583          	lw	a1,24(s2)
    80004124:	02892503          	lw	a0,40(s2)
    80004128:	fffff097          	auipc	ra,0xfffff
    8000412c:	fea080e7          	jalr	-22(ra) # 80003112 <bread>
    80004130:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004132:	02c92683          	lw	a3,44(s2)
    80004136:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004138:	02d05763          	blez	a3,80004166 <write_head+0x5a>
    8000413c:	0001e797          	auipc	a5,0x1e
    80004140:	00478793          	addi	a5,a5,4 # 80022140 <log+0x30>
    80004144:	05c50713          	addi	a4,a0,92
    80004148:	36fd                	addiw	a3,a3,-1
    8000414a:	1682                	slli	a3,a3,0x20
    8000414c:	9281                	srli	a3,a3,0x20
    8000414e:	068a                	slli	a3,a3,0x2
    80004150:	0001e617          	auipc	a2,0x1e
    80004154:	ff460613          	addi	a2,a2,-12 # 80022144 <log+0x34>
    80004158:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000415a:	4390                	lw	a2,0(a5)
    8000415c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000415e:	0791                	addi	a5,a5,4
    80004160:	0711                	addi	a4,a4,4
    80004162:	fed79ce3          	bne	a5,a3,8000415a <write_head+0x4e>
  }
  bwrite(buf);
    80004166:	8526                	mv	a0,s1
    80004168:	fffff097          	auipc	ra,0xfffff
    8000416c:	09c080e7          	jalr	156(ra) # 80003204 <bwrite>
  brelse(buf);
    80004170:	8526                	mv	a0,s1
    80004172:	fffff097          	auipc	ra,0xfffff
    80004176:	0d0080e7          	jalr	208(ra) # 80003242 <brelse>
}
    8000417a:	60e2                	ld	ra,24(sp)
    8000417c:	6442                	ld	s0,16(sp)
    8000417e:	64a2                	ld	s1,8(sp)
    80004180:	6902                	ld	s2,0(sp)
    80004182:	6105                	addi	sp,sp,32
    80004184:	8082                	ret

0000000080004186 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004186:	0001e797          	auipc	a5,0x1e
    8000418a:	fb67a783          	lw	a5,-74(a5) # 8002213c <log+0x2c>
    8000418e:	0af05d63          	blez	a5,80004248 <install_trans+0xc2>
{
    80004192:	7139                	addi	sp,sp,-64
    80004194:	fc06                	sd	ra,56(sp)
    80004196:	f822                	sd	s0,48(sp)
    80004198:	f426                	sd	s1,40(sp)
    8000419a:	f04a                	sd	s2,32(sp)
    8000419c:	ec4e                	sd	s3,24(sp)
    8000419e:	e852                	sd	s4,16(sp)
    800041a0:	e456                	sd	s5,8(sp)
    800041a2:	e05a                	sd	s6,0(sp)
    800041a4:	0080                	addi	s0,sp,64
    800041a6:	8b2a                	mv	s6,a0
    800041a8:	0001ea97          	auipc	s5,0x1e
    800041ac:	f98a8a93          	addi	s5,s5,-104 # 80022140 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041b0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041b2:	0001e997          	auipc	s3,0x1e
    800041b6:	f5e98993          	addi	s3,s3,-162 # 80022110 <log>
    800041ba:	a00d                	j	800041dc <install_trans+0x56>
    brelse(lbuf);
    800041bc:	854a                	mv	a0,s2
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	084080e7          	jalr	132(ra) # 80003242 <brelse>
    brelse(dbuf);
    800041c6:	8526                	mv	a0,s1
    800041c8:	fffff097          	auipc	ra,0xfffff
    800041cc:	07a080e7          	jalr	122(ra) # 80003242 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041d0:	2a05                	addiw	s4,s4,1
    800041d2:	0a91                	addi	s5,s5,4
    800041d4:	02c9a783          	lw	a5,44(s3)
    800041d8:	04fa5e63          	bge	s4,a5,80004234 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041dc:	0189a583          	lw	a1,24(s3)
    800041e0:	014585bb          	addw	a1,a1,s4
    800041e4:	2585                	addiw	a1,a1,1
    800041e6:	0289a503          	lw	a0,40(s3)
    800041ea:	fffff097          	auipc	ra,0xfffff
    800041ee:	f28080e7          	jalr	-216(ra) # 80003112 <bread>
    800041f2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041f4:	000aa583          	lw	a1,0(s5)
    800041f8:	0289a503          	lw	a0,40(s3)
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	f16080e7          	jalr	-234(ra) # 80003112 <bread>
    80004204:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004206:	40000613          	li	a2,1024
    8000420a:	05890593          	addi	a1,s2,88
    8000420e:	05850513          	addi	a0,a0,88
    80004212:	ffffd097          	auipc	ra,0xffffd
    80004216:	b1c080e7          	jalr	-1252(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000421a:	8526                	mv	a0,s1
    8000421c:	fffff097          	auipc	ra,0xfffff
    80004220:	fe8080e7          	jalr	-24(ra) # 80003204 <bwrite>
    if(recovering == 0)
    80004224:	f80b1ce3          	bnez	s6,800041bc <install_trans+0x36>
      bunpin(dbuf);
    80004228:	8526                	mv	a0,s1
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	0f2080e7          	jalr	242(ra) # 8000331c <bunpin>
    80004232:	b769                	j	800041bc <install_trans+0x36>
}
    80004234:	70e2                	ld	ra,56(sp)
    80004236:	7442                	ld	s0,48(sp)
    80004238:	74a2                	ld	s1,40(sp)
    8000423a:	7902                	ld	s2,32(sp)
    8000423c:	69e2                	ld	s3,24(sp)
    8000423e:	6a42                	ld	s4,16(sp)
    80004240:	6aa2                	ld	s5,8(sp)
    80004242:	6b02                	ld	s6,0(sp)
    80004244:	6121                	addi	sp,sp,64
    80004246:	8082                	ret
    80004248:	8082                	ret

000000008000424a <initlog>:
{
    8000424a:	7179                	addi	sp,sp,-48
    8000424c:	f406                	sd	ra,40(sp)
    8000424e:	f022                	sd	s0,32(sp)
    80004250:	ec26                	sd	s1,24(sp)
    80004252:	e84a                	sd	s2,16(sp)
    80004254:	e44e                	sd	s3,8(sp)
    80004256:	1800                	addi	s0,sp,48
    80004258:	892a                	mv	s2,a0
    8000425a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000425c:	0001e497          	auipc	s1,0x1e
    80004260:	eb448493          	addi	s1,s1,-332 # 80022110 <log>
    80004264:	00004597          	auipc	a1,0x4
    80004268:	3b458593          	addi	a1,a1,948 # 80008618 <syscalls+0x1d8>
    8000426c:	8526                	mv	a0,s1
    8000426e:	ffffd097          	auipc	ra,0xffffd
    80004272:	8d8080e7          	jalr	-1832(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004276:	0149a583          	lw	a1,20(s3)
    8000427a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000427c:	0109a783          	lw	a5,16(s3)
    80004280:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004282:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004286:	854a                	mv	a0,s2
    80004288:	fffff097          	auipc	ra,0xfffff
    8000428c:	e8a080e7          	jalr	-374(ra) # 80003112 <bread>
  log.lh.n = lh->n;
    80004290:	4d34                	lw	a3,88(a0)
    80004292:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004294:	02d05563          	blez	a3,800042be <initlog+0x74>
    80004298:	05c50793          	addi	a5,a0,92
    8000429c:	0001e717          	auipc	a4,0x1e
    800042a0:	ea470713          	addi	a4,a4,-348 # 80022140 <log+0x30>
    800042a4:	36fd                	addiw	a3,a3,-1
    800042a6:	1682                	slli	a3,a3,0x20
    800042a8:	9281                	srli	a3,a3,0x20
    800042aa:	068a                	slli	a3,a3,0x2
    800042ac:	06050613          	addi	a2,a0,96
    800042b0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800042b2:	4390                	lw	a2,0(a5)
    800042b4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042b6:	0791                	addi	a5,a5,4
    800042b8:	0711                	addi	a4,a4,4
    800042ba:	fed79ce3          	bne	a5,a3,800042b2 <initlog+0x68>
  brelse(buf);
    800042be:	fffff097          	auipc	ra,0xfffff
    800042c2:	f84080e7          	jalr	-124(ra) # 80003242 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042c6:	4505                	li	a0,1
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	ebe080e7          	jalr	-322(ra) # 80004186 <install_trans>
  log.lh.n = 0;
    800042d0:	0001e797          	auipc	a5,0x1e
    800042d4:	e607a623          	sw	zero,-404(a5) # 8002213c <log+0x2c>
  write_head(); // clear the log
    800042d8:	00000097          	auipc	ra,0x0
    800042dc:	e34080e7          	jalr	-460(ra) # 8000410c <write_head>
}
    800042e0:	70a2                	ld	ra,40(sp)
    800042e2:	7402                	ld	s0,32(sp)
    800042e4:	64e2                	ld	s1,24(sp)
    800042e6:	6942                	ld	s2,16(sp)
    800042e8:	69a2                	ld	s3,8(sp)
    800042ea:	6145                	addi	sp,sp,48
    800042ec:	8082                	ret

00000000800042ee <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042ee:	1101                	addi	sp,sp,-32
    800042f0:	ec06                	sd	ra,24(sp)
    800042f2:	e822                	sd	s0,16(sp)
    800042f4:	e426                	sd	s1,8(sp)
    800042f6:	e04a                	sd	s2,0(sp)
    800042f8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042fa:	0001e517          	auipc	a0,0x1e
    800042fe:	e1650513          	addi	a0,a0,-490 # 80022110 <log>
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	8d4080e7          	jalr	-1836(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    8000430a:	0001e497          	auipc	s1,0x1e
    8000430e:	e0648493          	addi	s1,s1,-506 # 80022110 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004312:	4979                	li	s2,30
    80004314:	a039                	j	80004322 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004316:	85a6                	mv	a1,s1
    80004318:	8526                	mv	a0,s1
    8000431a:	ffffe097          	auipc	ra,0xffffe
    8000431e:	da2080e7          	jalr	-606(ra) # 800020bc <sleep>
    if(log.committing){
    80004322:	50dc                	lw	a5,36(s1)
    80004324:	fbed                	bnez	a5,80004316 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004326:	509c                	lw	a5,32(s1)
    80004328:	0017871b          	addiw	a4,a5,1
    8000432c:	0007069b          	sext.w	a3,a4
    80004330:	0027179b          	slliw	a5,a4,0x2
    80004334:	9fb9                	addw	a5,a5,a4
    80004336:	0017979b          	slliw	a5,a5,0x1
    8000433a:	54d8                	lw	a4,44(s1)
    8000433c:	9fb9                	addw	a5,a5,a4
    8000433e:	00f95963          	bge	s2,a5,80004350 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004342:	85a6                	mv	a1,s1
    80004344:	8526                	mv	a0,s1
    80004346:	ffffe097          	auipc	ra,0xffffe
    8000434a:	d76080e7          	jalr	-650(ra) # 800020bc <sleep>
    8000434e:	bfd1                	j	80004322 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004350:	0001e517          	auipc	a0,0x1e
    80004354:	dc050513          	addi	a0,a0,-576 # 80022110 <log>
    80004358:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000435a:	ffffd097          	auipc	ra,0xffffd
    8000435e:	930080e7          	jalr	-1744(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004362:	60e2                	ld	ra,24(sp)
    80004364:	6442                	ld	s0,16(sp)
    80004366:	64a2                	ld	s1,8(sp)
    80004368:	6902                	ld	s2,0(sp)
    8000436a:	6105                	addi	sp,sp,32
    8000436c:	8082                	ret

000000008000436e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000436e:	7139                	addi	sp,sp,-64
    80004370:	fc06                	sd	ra,56(sp)
    80004372:	f822                	sd	s0,48(sp)
    80004374:	f426                	sd	s1,40(sp)
    80004376:	f04a                	sd	s2,32(sp)
    80004378:	ec4e                	sd	s3,24(sp)
    8000437a:	e852                	sd	s4,16(sp)
    8000437c:	e456                	sd	s5,8(sp)
    8000437e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004380:	0001e497          	auipc	s1,0x1e
    80004384:	d9048493          	addi	s1,s1,-624 # 80022110 <log>
    80004388:	8526                	mv	a0,s1
    8000438a:	ffffd097          	auipc	ra,0xffffd
    8000438e:	84c080e7          	jalr	-1972(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004392:	509c                	lw	a5,32(s1)
    80004394:	37fd                	addiw	a5,a5,-1
    80004396:	0007891b          	sext.w	s2,a5
    8000439a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000439c:	50dc                	lw	a5,36(s1)
    8000439e:	e7b9                	bnez	a5,800043ec <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043a0:	04091e63          	bnez	s2,800043fc <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043a4:	0001e497          	auipc	s1,0x1e
    800043a8:	d6c48493          	addi	s1,s1,-660 # 80022110 <log>
    800043ac:	4785                	li	a5,1
    800043ae:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043b0:	8526                	mv	a0,s1
    800043b2:	ffffd097          	auipc	ra,0xffffd
    800043b6:	8d8080e7          	jalr	-1832(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043ba:	54dc                	lw	a5,44(s1)
    800043bc:	06f04763          	bgtz	a5,8000442a <end_op+0xbc>
    acquire(&log.lock);
    800043c0:	0001e497          	auipc	s1,0x1e
    800043c4:	d5048493          	addi	s1,s1,-688 # 80022110 <log>
    800043c8:	8526                	mv	a0,s1
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	80c080e7          	jalr	-2036(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800043d2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043d6:	8526                	mv	a0,s1
    800043d8:	ffffe097          	auipc	ra,0xffffe
    800043dc:	d48080e7          	jalr	-696(ra) # 80002120 <wakeup>
    release(&log.lock);
    800043e0:	8526                	mv	a0,s1
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	8a8080e7          	jalr	-1880(ra) # 80000c8a <release>
}
    800043ea:	a03d                	j	80004418 <end_op+0xaa>
    panic("log.committing");
    800043ec:	00004517          	auipc	a0,0x4
    800043f0:	23450513          	addi	a0,a0,564 # 80008620 <syscalls+0x1e0>
    800043f4:	ffffc097          	auipc	ra,0xffffc
    800043f8:	14a080e7          	jalr	330(ra) # 8000053e <panic>
    wakeup(&log);
    800043fc:	0001e497          	auipc	s1,0x1e
    80004400:	d1448493          	addi	s1,s1,-748 # 80022110 <log>
    80004404:	8526                	mv	a0,s1
    80004406:	ffffe097          	auipc	ra,0xffffe
    8000440a:	d1a080e7          	jalr	-742(ra) # 80002120 <wakeup>
  release(&log.lock);
    8000440e:	8526                	mv	a0,s1
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	87a080e7          	jalr	-1926(ra) # 80000c8a <release>
}
    80004418:	70e2                	ld	ra,56(sp)
    8000441a:	7442                	ld	s0,48(sp)
    8000441c:	74a2                	ld	s1,40(sp)
    8000441e:	7902                	ld	s2,32(sp)
    80004420:	69e2                	ld	s3,24(sp)
    80004422:	6a42                	ld	s4,16(sp)
    80004424:	6aa2                	ld	s5,8(sp)
    80004426:	6121                	addi	sp,sp,64
    80004428:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000442a:	0001ea97          	auipc	s5,0x1e
    8000442e:	d16a8a93          	addi	s5,s5,-746 # 80022140 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004432:	0001ea17          	auipc	s4,0x1e
    80004436:	cdea0a13          	addi	s4,s4,-802 # 80022110 <log>
    8000443a:	018a2583          	lw	a1,24(s4)
    8000443e:	012585bb          	addw	a1,a1,s2
    80004442:	2585                	addiw	a1,a1,1
    80004444:	028a2503          	lw	a0,40(s4)
    80004448:	fffff097          	auipc	ra,0xfffff
    8000444c:	cca080e7          	jalr	-822(ra) # 80003112 <bread>
    80004450:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004452:	000aa583          	lw	a1,0(s5)
    80004456:	028a2503          	lw	a0,40(s4)
    8000445a:	fffff097          	auipc	ra,0xfffff
    8000445e:	cb8080e7          	jalr	-840(ra) # 80003112 <bread>
    80004462:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004464:	40000613          	li	a2,1024
    80004468:	05850593          	addi	a1,a0,88
    8000446c:	05848513          	addi	a0,s1,88
    80004470:	ffffd097          	auipc	ra,0xffffd
    80004474:	8be080e7          	jalr	-1858(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004478:	8526                	mv	a0,s1
    8000447a:	fffff097          	auipc	ra,0xfffff
    8000447e:	d8a080e7          	jalr	-630(ra) # 80003204 <bwrite>
    brelse(from);
    80004482:	854e                	mv	a0,s3
    80004484:	fffff097          	auipc	ra,0xfffff
    80004488:	dbe080e7          	jalr	-578(ra) # 80003242 <brelse>
    brelse(to);
    8000448c:	8526                	mv	a0,s1
    8000448e:	fffff097          	auipc	ra,0xfffff
    80004492:	db4080e7          	jalr	-588(ra) # 80003242 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004496:	2905                	addiw	s2,s2,1
    80004498:	0a91                	addi	s5,s5,4
    8000449a:	02ca2783          	lw	a5,44(s4)
    8000449e:	f8f94ee3          	blt	s2,a5,8000443a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044a2:	00000097          	auipc	ra,0x0
    800044a6:	c6a080e7          	jalr	-918(ra) # 8000410c <write_head>
    install_trans(0); // Now install writes to home locations
    800044aa:	4501                	li	a0,0
    800044ac:	00000097          	auipc	ra,0x0
    800044b0:	cda080e7          	jalr	-806(ra) # 80004186 <install_trans>
    log.lh.n = 0;
    800044b4:	0001e797          	auipc	a5,0x1e
    800044b8:	c807a423          	sw	zero,-888(a5) # 8002213c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044bc:	00000097          	auipc	ra,0x0
    800044c0:	c50080e7          	jalr	-944(ra) # 8000410c <write_head>
    800044c4:	bdf5                	j	800043c0 <end_op+0x52>

00000000800044c6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044c6:	1101                	addi	sp,sp,-32
    800044c8:	ec06                	sd	ra,24(sp)
    800044ca:	e822                	sd	s0,16(sp)
    800044cc:	e426                	sd	s1,8(sp)
    800044ce:	e04a                	sd	s2,0(sp)
    800044d0:	1000                	addi	s0,sp,32
    800044d2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044d4:	0001e917          	auipc	s2,0x1e
    800044d8:	c3c90913          	addi	s2,s2,-964 # 80022110 <log>
    800044dc:	854a                	mv	a0,s2
    800044de:	ffffc097          	auipc	ra,0xffffc
    800044e2:	6f8080e7          	jalr	1784(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044e6:	02c92603          	lw	a2,44(s2)
    800044ea:	47f5                	li	a5,29
    800044ec:	06c7c563          	blt	a5,a2,80004556 <log_write+0x90>
    800044f0:	0001e797          	auipc	a5,0x1e
    800044f4:	c3c7a783          	lw	a5,-964(a5) # 8002212c <log+0x1c>
    800044f8:	37fd                	addiw	a5,a5,-1
    800044fa:	04f65e63          	bge	a2,a5,80004556 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044fe:	0001e797          	auipc	a5,0x1e
    80004502:	c327a783          	lw	a5,-974(a5) # 80022130 <log+0x20>
    80004506:	06f05063          	blez	a5,80004566 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000450a:	4781                	li	a5,0
    8000450c:	06c05563          	blez	a2,80004576 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004510:	44cc                	lw	a1,12(s1)
    80004512:	0001e717          	auipc	a4,0x1e
    80004516:	c2e70713          	addi	a4,a4,-978 # 80022140 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000451a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000451c:	4314                	lw	a3,0(a4)
    8000451e:	04b68c63          	beq	a3,a1,80004576 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004522:	2785                	addiw	a5,a5,1
    80004524:	0711                	addi	a4,a4,4
    80004526:	fef61be3          	bne	a2,a5,8000451c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000452a:	0621                	addi	a2,a2,8
    8000452c:	060a                	slli	a2,a2,0x2
    8000452e:	0001e797          	auipc	a5,0x1e
    80004532:	be278793          	addi	a5,a5,-1054 # 80022110 <log>
    80004536:	963e                	add	a2,a2,a5
    80004538:	44dc                	lw	a5,12(s1)
    8000453a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000453c:	8526                	mv	a0,s1
    8000453e:	fffff097          	auipc	ra,0xfffff
    80004542:	da2080e7          	jalr	-606(ra) # 800032e0 <bpin>
    log.lh.n++;
    80004546:	0001e717          	auipc	a4,0x1e
    8000454a:	bca70713          	addi	a4,a4,-1078 # 80022110 <log>
    8000454e:	575c                	lw	a5,44(a4)
    80004550:	2785                	addiw	a5,a5,1
    80004552:	d75c                	sw	a5,44(a4)
    80004554:	a835                	j	80004590 <log_write+0xca>
    panic("too big a transaction");
    80004556:	00004517          	auipc	a0,0x4
    8000455a:	0da50513          	addi	a0,a0,218 # 80008630 <syscalls+0x1f0>
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	fe0080e7          	jalr	-32(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004566:	00004517          	auipc	a0,0x4
    8000456a:	0e250513          	addi	a0,a0,226 # 80008648 <syscalls+0x208>
    8000456e:	ffffc097          	auipc	ra,0xffffc
    80004572:	fd0080e7          	jalr	-48(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004576:	00878713          	addi	a4,a5,8
    8000457a:	00271693          	slli	a3,a4,0x2
    8000457e:	0001e717          	auipc	a4,0x1e
    80004582:	b9270713          	addi	a4,a4,-1134 # 80022110 <log>
    80004586:	9736                	add	a4,a4,a3
    80004588:	44d4                	lw	a3,12(s1)
    8000458a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000458c:	faf608e3          	beq	a2,a5,8000453c <log_write+0x76>
  }
  release(&log.lock);
    80004590:	0001e517          	auipc	a0,0x1e
    80004594:	b8050513          	addi	a0,a0,-1152 # 80022110 <log>
    80004598:	ffffc097          	auipc	ra,0xffffc
    8000459c:	6f2080e7          	jalr	1778(ra) # 80000c8a <release>
}
    800045a0:	60e2                	ld	ra,24(sp)
    800045a2:	6442                	ld	s0,16(sp)
    800045a4:	64a2                	ld	s1,8(sp)
    800045a6:	6902                	ld	s2,0(sp)
    800045a8:	6105                	addi	sp,sp,32
    800045aa:	8082                	ret

00000000800045ac <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045ac:	1101                	addi	sp,sp,-32
    800045ae:	ec06                	sd	ra,24(sp)
    800045b0:	e822                	sd	s0,16(sp)
    800045b2:	e426                	sd	s1,8(sp)
    800045b4:	e04a                	sd	s2,0(sp)
    800045b6:	1000                	addi	s0,sp,32
    800045b8:	84aa                	mv	s1,a0
    800045ba:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045bc:	00004597          	auipc	a1,0x4
    800045c0:	0ac58593          	addi	a1,a1,172 # 80008668 <syscalls+0x228>
    800045c4:	0521                	addi	a0,a0,8
    800045c6:	ffffc097          	auipc	ra,0xffffc
    800045ca:	580080e7          	jalr	1408(ra) # 80000b46 <initlock>
  lk->name = name;
    800045ce:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045d2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045d6:	0204a423          	sw	zero,40(s1)
}
    800045da:	60e2                	ld	ra,24(sp)
    800045dc:	6442                	ld	s0,16(sp)
    800045de:	64a2                	ld	s1,8(sp)
    800045e0:	6902                	ld	s2,0(sp)
    800045e2:	6105                	addi	sp,sp,32
    800045e4:	8082                	ret

00000000800045e6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045e6:	1101                	addi	sp,sp,-32
    800045e8:	ec06                	sd	ra,24(sp)
    800045ea:	e822                	sd	s0,16(sp)
    800045ec:	e426                	sd	s1,8(sp)
    800045ee:	e04a                	sd	s2,0(sp)
    800045f0:	1000                	addi	s0,sp,32
    800045f2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045f4:	00850913          	addi	s2,a0,8
    800045f8:	854a                	mv	a0,s2
    800045fa:	ffffc097          	auipc	ra,0xffffc
    800045fe:	5dc080e7          	jalr	1500(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004602:	409c                	lw	a5,0(s1)
    80004604:	cb89                	beqz	a5,80004616 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004606:	85ca                	mv	a1,s2
    80004608:	8526                	mv	a0,s1
    8000460a:	ffffe097          	auipc	ra,0xffffe
    8000460e:	ab2080e7          	jalr	-1358(ra) # 800020bc <sleep>
  while (lk->locked) {
    80004612:	409c                	lw	a5,0(s1)
    80004614:	fbed                	bnez	a5,80004606 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004616:	4785                	li	a5,1
    80004618:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000461a:	ffffd097          	auipc	ra,0xffffd
    8000461e:	366080e7          	jalr	870(ra) # 80001980 <myproc>
    80004622:	515c                	lw	a5,36(a0)
    80004624:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004626:	854a                	mv	a0,s2
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	662080e7          	jalr	1634(ra) # 80000c8a <release>
}
    80004630:	60e2                	ld	ra,24(sp)
    80004632:	6442                	ld	s0,16(sp)
    80004634:	64a2                	ld	s1,8(sp)
    80004636:	6902                	ld	s2,0(sp)
    80004638:	6105                	addi	sp,sp,32
    8000463a:	8082                	ret

000000008000463c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000463c:	1101                	addi	sp,sp,-32
    8000463e:	ec06                	sd	ra,24(sp)
    80004640:	e822                	sd	s0,16(sp)
    80004642:	e426                	sd	s1,8(sp)
    80004644:	e04a                	sd	s2,0(sp)
    80004646:	1000                	addi	s0,sp,32
    80004648:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000464a:	00850913          	addi	s2,a0,8
    8000464e:	854a                	mv	a0,s2
    80004650:	ffffc097          	auipc	ra,0xffffc
    80004654:	586080e7          	jalr	1414(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004658:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000465c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004660:	8526                	mv	a0,s1
    80004662:	ffffe097          	auipc	ra,0xffffe
    80004666:	abe080e7          	jalr	-1346(ra) # 80002120 <wakeup>
  release(&lk->lk);
    8000466a:	854a                	mv	a0,s2
    8000466c:	ffffc097          	auipc	ra,0xffffc
    80004670:	61e080e7          	jalr	1566(ra) # 80000c8a <release>
}
    80004674:	60e2                	ld	ra,24(sp)
    80004676:	6442                	ld	s0,16(sp)
    80004678:	64a2                	ld	s1,8(sp)
    8000467a:	6902                	ld	s2,0(sp)
    8000467c:	6105                	addi	sp,sp,32
    8000467e:	8082                	ret

0000000080004680 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004680:	7179                	addi	sp,sp,-48
    80004682:	f406                	sd	ra,40(sp)
    80004684:	f022                	sd	s0,32(sp)
    80004686:	ec26                	sd	s1,24(sp)
    80004688:	e84a                	sd	s2,16(sp)
    8000468a:	e44e                	sd	s3,8(sp)
    8000468c:	1800                	addi	s0,sp,48
    8000468e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004690:	00850913          	addi	s2,a0,8
    80004694:	854a                	mv	a0,s2
    80004696:	ffffc097          	auipc	ra,0xffffc
    8000469a:	540080e7          	jalr	1344(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000469e:	409c                	lw	a5,0(s1)
    800046a0:	ef99                	bnez	a5,800046be <holdingsleep+0x3e>
    800046a2:	4481                	li	s1,0
  release(&lk->lk);
    800046a4:	854a                	mv	a0,s2
    800046a6:	ffffc097          	auipc	ra,0xffffc
    800046aa:	5e4080e7          	jalr	1508(ra) # 80000c8a <release>
  return r;
}
    800046ae:	8526                	mv	a0,s1
    800046b0:	70a2                	ld	ra,40(sp)
    800046b2:	7402                	ld	s0,32(sp)
    800046b4:	64e2                	ld	s1,24(sp)
    800046b6:	6942                	ld	s2,16(sp)
    800046b8:	69a2                	ld	s3,8(sp)
    800046ba:	6145                	addi	sp,sp,48
    800046bc:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046be:	0284a983          	lw	s3,40(s1)
    800046c2:	ffffd097          	auipc	ra,0xffffd
    800046c6:	2be080e7          	jalr	702(ra) # 80001980 <myproc>
    800046ca:	5144                	lw	s1,36(a0)
    800046cc:	413484b3          	sub	s1,s1,s3
    800046d0:	0014b493          	seqz	s1,s1
    800046d4:	bfc1                	j	800046a4 <holdingsleep+0x24>

00000000800046d6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046d6:	1141                	addi	sp,sp,-16
    800046d8:	e406                	sd	ra,8(sp)
    800046da:	e022                	sd	s0,0(sp)
    800046dc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046de:	00004597          	auipc	a1,0x4
    800046e2:	f9a58593          	addi	a1,a1,-102 # 80008678 <syscalls+0x238>
    800046e6:	0001e517          	auipc	a0,0x1e
    800046ea:	b7250513          	addi	a0,a0,-1166 # 80022258 <ftable>
    800046ee:	ffffc097          	auipc	ra,0xffffc
    800046f2:	458080e7          	jalr	1112(ra) # 80000b46 <initlock>
}
    800046f6:	60a2                	ld	ra,8(sp)
    800046f8:	6402                	ld	s0,0(sp)
    800046fa:	0141                	addi	sp,sp,16
    800046fc:	8082                	ret

00000000800046fe <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046fe:	1101                	addi	sp,sp,-32
    80004700:	ec06                	sd	ra,24(sp)
    80004702:	e822                	sd	s0,16(sp)
    80004704:	e426                	sd	s1,8(sp)
    80004706:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004708:	0001e517          	auipc	a0,0x1e
    8000470c:	b5050513          	addi	a0,a0,-1200 # 80022258 <ftable>
    80004710:	ffffc097          	auipc	ra,0xffffc
    80004714:	4c6080e7          	jalr	1222(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004718:	0001e497          	auipc	s1,0x1e
    8000471c:	b5848493          	addi	s1,s1,-1192 # 80022270 <ftable+0x18>
    80004720:	0001f717          	auipc	a4,0x1f
    80004724:	af070713          	addi	a4,a4,-1296 # 80023210 <disk>
    if(f->ref == 0){
    80004728:	40dc                	lw	a5,4(s1)
    8000472a:	cf99                	beqz	a5,80004748 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000472c:	02848493          	addi	s1,s1,40
    80004730:	fee49ce3          	bne	s1,a4,80004728 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004734:	0001e517          	auipc	a0,0x1e
    80004738:	b2450513          	addi	a0,a0,-1244 # 80022258 <ftable>
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	54e080e7          	jalr	1358(ra) # 80000c8a <release>
  return 0;
    80004744:	4481                	li	s1,0
    80004746:	a819                	j	8000475c <filealloc+0x5e>
      f->ref = 1;
    80004748:	4785                	li	a5,1
    8000474a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000474c:	0001e517          	auipc	a0,0x1e
    80004750:	b0c50513          	addi	a0,a0,-1268 # 80022258 <ftable>
    80004754:	ffffc097          	auipc	ra,0xffffc
    80004758:	536080e7          	jalr	1334(ra) # 80000c8a <release>
}
    8000475c:	8526                	mv	a0,s1
    8000475e:	60e2                	ld	ra,24(sp)
    80004760:	6442                	ld	s0,16(sp)
    80004762:	64a2                	ld	s1,8(sp)
    80004764:	6105                	addi	sp,sp,32
    80004766:	8082                	ret

0000000080004768 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004768:	1101                	addi	sp,sp,-32
    8000476a:	ec06                	sd	ra,24(sp)
    8000476c:	e822                	sd	s0,16(sp)
    8000476e:	e426                	sd	s1,8(sp)
    80004770:	1000                	addi	s0,sp,32
    80004772:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004774:	0001e517          	auipc	a0,0x1e
    80004778:	ae450513          	addi	a0,a0,-1308 # 80022258 <ftable>
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	45a080e7          	jalr	1114(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004784:	40dc                	lw	a5,4(s1)
    80004786:	02f05263          	blez	a5,800047aa <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000478a:	2785                	addiw	a5,a5,1
    8000478c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000478e:	0001e517          	auipc	a0,0x1e
    80004792:	aca50513          	addi	a0,a0,-1334 # 80022258 <ftable>
    80004796:	ffffc097          	auipc	ra,0xffffc
    8000479a:	4f4080e7          	jalr	1268(ra) # 80000c8a <release>
  return f;
}
    8000479e:	8526                	mv	a0,s1
    800047a0:	60e2                	ld	ra,24(sp)
    800047a2:	6442                	ld	s0,16(sp)
    800047a4:	64a2                	ld	s1,8(sp)
    800047a6:	6105                	addi	sp,sp,32
    800047a8:	8082                	ret
    panic("filedup");
    800047aa:	00004517          	auipc	a0,0x4
    800047ae:	ed650513          	addi	a0,a0,-298 # 80008680 <syscalls+0x240>
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	d8c080e7          	jalr	-628(ra) # 8000053e <panic>

00000000800047ba <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047ba:	7139                	addi	sp,sp,-64
    800047bc:	fc06                	sd	ra,56(sp)
    800047be:	f822                	sd	s0,48(sp)
    800047c0:	f426                	sd	s1,40(sp)
    800047c2:	f04a                	sd	s2,32(sp)
    800047c4:	ec4e                	sd	s3,24(sp)
    800047c6:	e852                	sd	s4,16(sp)
    800047c8:	e456                	sd	s5,8(sp)
    800047ca:	0080                	addi	s0,sp,64
    800047cc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047ce:	0001e517          	auipc	a0,0x1e
    800047d2:	a8a50513          	addi	a0,a0,-1398 # 80022258 <ftable>
    800047d6:	ffffc097          	auipc	ra,0xffffc
    800047da:	400080e7          	jalr	1024(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047de:	40dc                	lw	a5,4(s1)
    800047e0:	06f05163          	blez	a5,80004842 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047e4:	37fd                	addiw	a5,a5,-1
    800047e6:	0007871b          	sext.w	a4,a5
    800047ea:	c0dc                	sw	a5,4(s1)
    800047ec:	06e04363          	bgtz	a4,80004852 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047f0:	0004a903          	lw	s2,0(s1)
    800047f4:	0094ca83          	lbu	s5,9(s1)
    800047f8:	0104ba03          	ld	s4,16(s1)
    800047fc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004800:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004804:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004808:	0001e517          	auipc	a0,0x1e
    8000480c:	a5050513          	addi	a0,a0,-1456 # 80022258 <ftable>
    80004810:	ffffc097          	auipc	ra,0xffffc
    80004814:	47a080e7          	jalr	1146(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004818:	4785                	li	a5,1
    8000481a:	04f90d63          	beq	s2,a5,80004874 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000481e:	3979                	addiw	s2,s2,-2
    80004820:	4785                	li	a5,1
    80004822:	0527e063          	bltu	a5,s2,80004862 <fileclose+0xa8>
    begin_op();
    80004826:	00000097          	auipc	ra,0x0
    8000482a:	ac8080e7          	jalr	-1336(ra) # 800042ee <begin_op>
    iput(ff.ip);
    8000482e:	854e                	mv	a0,s3
    80004830:	fffff097          	auipc	ra,0xfffff
    80004834:	2b6080e7          	jalr	694(ra) # 80003ae6 <iput>
    end_op();
    80004838:	00000097          	auipc	ra,0x0
    8000483c:	b36080e7          	jalr	-1226(ra) # 8000436e <end_op>
    80004840:	a00d                	j	80004862 <fileclose+0xa8>
    panic("fileclose");
    80004842:	00004517          	auipc	a0,0x4
    80004846:	e4650513          	addi	a0,a0,-442 # 80008688 <syscalls+0x248>
    8000484a:	ffffc097          	auipc	ra,0xffffc
    8000484e:	cf4080e7          	jalr	-780(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004852:	0001e517          	auipc	a0,0x1e
    80004856:	a0650513          	addi	a0,a0,-1530 # 80022258 <ftable>
    8000485a:	ffffc097          	auipc	ra,0xffffc
    8000485e:	430080e7          	jalr	1072(ra) # 80000c8a <release>
  }
}
    80004862:	70e2                	ld	ra,56(sp)
    80004864:	7442                	ld	s0,48(sp)
    80004866:	74a2                	ld	s1,40(sp)
    80004868:	7902                	ld	s2,32(sp)
    8000486a:	69e2                	ld	s3,24(sp)
    8000486c:	6a42                	ld	s4,16(sp)
    8000486e:	6aa2                	ld	s5,8(sp)
    80004870:	6121                	addi	sp,sp,64
    80004872:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004874:	85d6                	mv	a1,s5
    80004876:	8552                	mv	a0,s4
    80004878:	00000097          	auipc	ra,0x0
    8000487c:	34c080e7          	jalr	844(ra) # 80004bc4 <pipeclose>
    80004880:	b7cd                	j	80004862 <fileclose+0xa8>

0000000080004882 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004882:	715d                	addi	sp,sp,-80
    80004884:	e486                	sd	ra,72(sp)
    80004886:	e0a2                	sd	s0,64(sp)
    80004888:	fc26                	sd	s1,56(sp)
    8000488a:	f84a                	sd	s2,48(sp)
    8000488c:	f44e                	sd	s3,40(sp)
    8000488e:	0880                	addi	s0,sp,80
    80004890:	84aa                	mv	s1,a0
    80004892:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004894:	ffffd097          	auipc	ra,0xffffd
    80004898:	0ec080e7          	jalr	236(ra) # 80001980 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000489c:	409c                	lw	a5,0(s1)
    8000489e:	37f9                	addiw	a5,a5,-2
    800048a0:	4705                	li	a4,1
    800048a2:	04f76763          	bltu	a4,a5,800048f0 <filestat+0x6e>
    800048a6:	892a                	mv	s2,a0
    ilock(f->ip);
    800048a8:	6c88                	ld	a0,24(s1)
    800048aa:	fffff097          	auipc	ra,0xfffff
    800048ae:	082080e7          	jalr	130(ra) # 8000392c <ilock>
    stati(f->ip, &st);
    800048b2:	fb840593          	addi	a1,s0,-72
    800048b6:	6c88                	ld	a0,24(s1)
    800048b8:	fffff097          	auipc	ra,0xfffff
    800048bc:	2fe080e7          	jalr	766(ra) # 80003bb6 <stati>
    iunlock(f->ip);
    800048c0:	6c88                	ld	a0,24(s1)
    800048c2:	fffff097          	auipc	ra,0xfffff
    800048c6:	12c080e7          	jalr	300(ra) # 800039ee <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048ca:	46e1                	li	a3,24
    800048cc:	fb840613          	addi	a2,s0,-72
    800048d0:	85ce                	mv	a1,s3
    800048d2:	10093503          	ld	a0,256(s2)
    800048d6:	ffffd097          	auipc	ra,0xffffd
    800048da:	d92080e7          	jalr	-622(ra) # 80001668 <copyout>
    800048de:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048e2:	60a6                	ld	ra,72(sp)
    800048e4:	6406                	ld	s0,64(sp)
    800048e6:	74e2                	ld	s1,56(sp)
    800048e8:	7942                	ld	s2,48(sp)
    800048ea:	79a2                	ld	s3,40(sp)
    800048ec:	6161                	addi	sp,sp,80
    800048ee:	8082                	ret
  return -1;
    800048f0:	557d                	li	a0,-1
    800048f2:	bfc5                	j	800048e2 <filestat+0x60>

00000000800048f4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048f4:	7179                	addi	sp,sp,-48
    800048f6:	f406                	sd	ra,40(sp)
    800048f8:	f022                	sd	s0,32(sp)
    800048fa:	ec26                	sd	s1,24(sp)
    800048fc:	e84a                	sd	s2,16(sp)
    800048fe:	e44e                	sd	s3,8(sp)
    80004900:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004902:	00854783          	lbu	a5,8(a0)
    80004906:	c3d5                	beqz	a5,800049aa <fileread+0xb6>
    80004908:	84aa                	mv	s1,a0
    8000490a:	89ae                	mv	s3,a1
    8000490c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000490e:	411c                	lw	a5,0(a0)
    80004910:	4705                	li	a4,1
    80004912:	04e78963          	beq	a5,a4,80004964 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004916:	470d                	li	a4,3
    80004918:	04e78d63          	beq	a5,a4,80004972 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000491c:	4709                	li	a4,2
    8000491e:	06e79e63          	bne	a5,a4,8000499a <fileread+0xa6>
    ilock(f->ip);
    80004922:	6d08                	ld	a0,24(a0)
    80004924:	fffff097          	auipc	ra,0xfffff
    80004928:	008080e7          	jalr	8(ra) # 8000392c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000492c:	874a                	mv	a4,s2
    8000492e:	5094                	lw	a3,32(s1)
    80004930:	864e                	mv	a2,s3
    80004932:	4585                	li	a1,1
    80004934:	6c88                	ld	a0,24(s1)
    80004936:	fffff097          	auipc	ra,0xfffff
    8000493a:	2aa080e7          	jalr	682(ra) # 80003be0 <readi>
    8000493e:	892a                	mv	s2,a0
    80004940:	00a05563          	blez	a0,8000494a <fileread+0x56>
      f->off += r;
    80004944:	509c                	lw	a5,32(s1)
    80004946:	9fa9                	addw	a5,a5,a0
    80004948:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000494a:	6c88                	ld	a0,24(s1)
    8000494c:	fffff097          	auipc	ra,0xfffff
    80004950:	0a2080e7          	jalr	162(ra) # 800039ee <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004954:	854a                	mv	a0,s2
    80004956:	70a2                	ld	ra,40(sp)
    80004958:	7402                	ld	s0,32(sp)
    8000495a:	64e2                	ld	s1,24(sp)
    8000495c:	6942                	ld	s2,16(sp)
    8000495e:	69a2                	ld	s3,8(sp)
    80004960:	6145                	addi	sp,sp,48
    80004962:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004964:	6908                	ld	a0,16(a0)
    80004966:	00000097          	auipc	ra,0x0
    8000496a:	3c6080e7          	jalr	966(ra) # 80004d2c <piperead>
    8000496e:	892a                	mv	s2,a0
    80004970:	b7d5                	j	80004954 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004972:	02451783          	lh	a5,36(a0)
    80004976:	03079693          	slli	a3,a5,0x30
    8000497a:	92c1                	srli	a3,a3,0x30
    8000497c:	4725                	li	a4,9
    8000497e:	02d76863          	bltu	a4,a3,800049ae <fileread+0xba>
    80004982:	0792                	slli	a5,a5,0x4
    80004984:	0001e717          	auipc	a4,0x1e
    80004988:	83470713          	addi	a4,a4,-1996 # 800221b8 <devsw>
    8000498c:	97ba                	add	a5,a5,a4
    8000498e:	639c                	ld	a5,0(a5)
    80004990:	c38d                	beqz	a5,800049b2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004992:	4505                	li	a0,1
    80004994:	9782                	jalr	a5
    80004996:	892a                	mv	s2,a0
    80004998:	bf75                	j	80004954 <fileread+0x60>
    panic("fileread");
    8000499a:	00004517          	auipc	a0,0x4
    8000499e:	cfe50513          	addi	a0,a0,-770 # 80008698 <syscalls+0x258>
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	b9c080e7          	jalr	-1124(ra) # 8000053e <panic>
    return -1;
    800049aa:	597d                	li	s2,-1
    800049ac:	b765                	j	80004954 <fileread+0x60>
      return -1;
    800049ae:	597d                	li	s2,-1
    800049b0:	b755                	j	80004954 <fileread+0x60>
    800049b2:	597d                	li	s2,-1
    800049b4:	b745                	j	80004954 <fileread+0x60>

00000000800049b6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800049b6:	715d                	addi	sp,sp,-80
    800049b8:	e486                	sd	ra,72(sp)
    800049ba:	e0a2                	sd	s0,64(sp)
    800049bc:	fc26                	sd	s1,56(sp)
    800049be:	f84a                	sd	s2,48(sp)
    800049c0:	f44e                	sd	s3,40(sp)
    800049c2:	f052                	sd	s4,32(sp)
    800049c4:	ec56                	sd	s5,24(sp)
    800049c6:	e85a                	sd	s6,16(sp)
    800049c8:	e45e                	sd	s7,8(sp)
    800049ca:	e062                	sd	s8,0(sp)
    800049cc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049ce:	00954783          	lbu	a5,9(a0)
    800049d2:	10078663          	beqz	a5,80004ade <filewrite+0x128>
    800049d6:	892a                	mv	s2,a0
    800049d8:	8aae                	mv	s5,a1
    800049da:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049dc:	411c                	lw	a5,0(a0)
    800049de:	4705                	li	a4,1
    800049e0:	02e78263          	beq	a5,a4,80004a04 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049e4:	470d                	li	a4,3
    800049e6:	02e78663          	beq	a5,a4,80004a12 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049ea:	4709                	li	a4,2
    800049ec:	0ee79163          	bne	a5,a4,80004ace <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049f0:	0ac05d63          	blez	a2,80004aaa <filewrite+0xf4>
    int i = 0;
    800049f4:	4981                	li	s3,0
    800049f6:	6b05                	lui	s6,0x1
    800049f8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049fc:	6b85                	lui	s7,0x1
    800049fe:	c00b8b9b          	addiw	s7,s7,-1024
    80004a02:	a861                	j	80004a9a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004a04:	6908                	ld	a0,16(a0)
    80004a06:	00000097          	auipc	ra,0x0
    80004a0a:	22e080e7          	jalr	558(ra) # 80004c34 <pipewrite>
    80004a0e:	8a2a                	mv	s4,a0
    80004a10:	a045                	j	80004ab0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a12:	02451783          	lh	a5,36(a0)
    80004a16:	03079693          	slli	a3,a5,0x30
    80004a1a:	92c1                	srli	a3,a3,0x30
    80004a1c:	4725                	li	a4,9
    80004a1e:	0cd76263          	bltu	a4,a3,80004ae2 <filewrite+0x12c>
    80004a22:	0792                	slli	a5,a5,0x4
    80004a24:	0001d717          	auipc	a4,0x1d
    80004a28:	79470713          	addi	a4,a4,1940 # 800221b8 <devsw>
    80004a2c:	97ba                	add	a5,a5,a4
    80004a2e:	679c                	ld	a5,8(a5)
    80004a30:	cbdd                	beqz	a5,80004ae6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a32:	4505                	li	a0,1
    80004a34:	9782                	jalr	a5
    80004a36:	8a2a                	mv	s4,a0
    80004a38:	a8a5                	j	80004ab0 <filewrite+0xfa>
    80004a3a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a3e:	00000097          	auipc	ra,0x0
    80004a42:	8b0080e7          	jalr	-1872(ra) # 800042ee <begin_op>
      ilock(f->ip);
    80004a46:	01893503          	ld	a0,24(s2)
    80004a4a:	fffff097          	auipc	ra,0xfffff
    80004a4e:	ee2080e7          	jalr	-286(ra) # 8000392c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a52:	8762                	mv	a4,s8
    80004a54:	02092683          	lw	a3,32(s2)
    80004a58:	01598633          	add	a2,s3,s5
    80004a5c:	4585                	li	a1,1
    80004a5e:	01893503          	ld	a0,24(s2)
    80004a62:	fffff097          	auipc	ra,0xfffff
    80004a66:	276080e7          	jalr	630(ra) # 80003cd8 <writei>
    80004a6a:	84aa                	mv	s1,a0
    80004a6c:	00a05763          	blez	a0,80004a7a <filewrite+0xc4>
        f->off += r;
    80004a70:	02092783          	lw	a5,32(s2)
    80004a74:	9fa9                	addw	a5,a5,a0
    80004a76:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a7a:	01893503          	ld	a0,24(s2)
    80004a7e:	fffff097          	auipc	ra,0xfffff
    80004a82:	f70080e7          	jalr	-144(ra) # 800039ee <iunlock>
      end_op();
    80004a86:	00000097          	auipc	ra,0x0
    80004a8a:	8e8080e7          	jalr	-1816(ra) # 8000436e <end_op>

      if(r != n1){
    80004a8e:	009c1f63          	bne	s8,s1,80004aac <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a92:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a96:	0149db63          	bge	s3,s4,80004aac <filewrite+0xf6>
      int n1 = n - i;
    80004a9a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a9e:	84be                	mv	s1,a5
    80004aa0:	2781                	sext.w	a5,a5
    80004aa2:	f8fb5ce3          	bge	s6,a5,80004a3a <filewrite+0x84>
    80004aa6:	84de                	mv	s1,s7
    80004aa8:	bf49                	j	80004a3a <filewrite+0x84>
    int i = 0;
    80004aaa:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004aac:	013a1f63          	bne	s4,s3,80004aca <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ab0:	8552                	mv	a0,s4
    80004ab2:	60a6                	ld	ra,72(sp)
    80004ab4:	6406                	ld	s0,64(sp)
    80004ab6:	74e2                	ld	s1,56(sp)
    80004ab8:	7942                	ld	s2,48(sp)
    80004aba:	79a2                	ld	s3,40(sp)
    80004abc:	7a02                	ld	s4,32(sp)
    80004abe:	6ae2                	ld	s5,24(sp)
    80004ac0:	6b42                	ld	s6,16(sp)
    80004ac2:	6ba2                	ld	s7,8(sp)
    80004ac4:	6c02                	ld	s8,0(sp)
    80004ac6:	6161                	addi	sp,sp,80
    80004ac8:	8082                	ret
    ret = (i == n ? n : -1);
    80004aca:	5a7d                	li	s4,-1
    80004acc:	b7d5                	j	80004ab0 <filewrite+0xfa>
    panic("filewrite");
    80004ace:	00004517          	auipc	a0,0x4
    80004ad2:	bda50513          	addi	a0,a0,-1062 # 800086a8 <syscalls+0x268>
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	a68080e7          	jalr	-1432(ra) # 8000053e <panic>
    return -1;
    80004ade:	5a7d                	li	s4,-1
    80004ae0:	bfc1                	j	80004ab0 <filewrite+0xfa>
      return -1;
    80004ae2:	5a7d                	li	s4,-1
    80004ae4:	b7f1                	j	80004ab0 <filewrite+0xfa>
    80004ae6:	5a7d                	li	s4,-1
    80004ae8:	b7e1                	j	80004ab0 <filewrite+0xfa>

0000000080004aea <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004aea:	7179                	addi	sp,sp,-48
    80004aec:	f406                	sd	ra,40(sp)
    80004aee:	f022                	sd	s0,32(sp)
    80004af0:	ec26                	sd	s1,24(sp)
    80004af2:	e84a                	sd	s2,16(sp)
    80004af4:	e44e                	sd	s3,8(sp)
    80004af6:	e052                	sd	s4,0(sp)
    80004af8:	1800                	addi	s0,sp,48
    80004afa:	84aa                	mv	s1,a0
    80004afc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004afe:	0005b023          	sd	zero,0(a1)
    80004b02:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b06:	00000097          	auipc	ra,0x0
    80004b0a:	bf8080e7          	jalr	-1032(ra) # 800046fe <filealloc>
    80004b0e:	e088                	sd	a0,0(s1)
    80004b10:	c551                	beqz	a0,80004b9c <pipealloc+0xb2>
    80004b12:	00000097          	auipc	ra,0x0
    80004b16:	bec080e7          	jalr	-1044(ra) # 800046fe <filealloc>
    80004b1a:	00aa3023          	sd	a0,0(s4)
    80004b1e:	c92d                	beqz	a0,80004b90 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b20:	ffffc097          	auipc	ra,0xffffc
    80004b24:	fc6080e7          	jalr	-58(ra) # 80000ae6 <kalloc>
    80004b28:	892a                	mv	s2,a0
    80004b2a:	c125                	beqz	a0,80004b8a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b2c:	4985                	li	s3,1
    80004b2e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b32:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b36:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b3a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b3e:	00004597          	auipc	a1,0x4
    80004b42:	b7a58593          	addi	a1,a1,-1158 # 800086b8 <syscalls+0x278>
    80004b46:	ffffc097          	auipc	ra,0xffffc
    80004b4a:	000080e7          	jalr	ra # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004b4e:	609c                	ld	a5,0(s1)
    80004b50:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b54:	609c                	ld	a5,0(s1)
    80004b56:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b5a:	609c                	ld	a5,0(s1)
    80004b5c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b60:	609c                	ld	a5,0(s1)
    80004b62:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b66:	000a3783          	ld	a5,0(s4)
    80004b6a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b6e:	000a3783          	ld	a5,0(s4)
    80004b72:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b76:	000a3783          	ld	a5,0(s4)
    80004b7a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b7e:	000a3783          	ld	a5,0(s4)
    80004b82:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b86:	4501                	li	a0,0
    80004b88:	a025                	j	80004bb0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b8a:	6088                	ld	a0,0(s1)
    80004b8c:	e501                	bnez	a0,80004b94 <pipealloc+0xaa>
    80004b8e:	a039                	j	80004b9c <pipealloc+0xb2>
    80004b90:	6088                	ld	a0,0(s1)
    80004b92:	c51d                	beqz	a0,80004bc0 <pipealloc+0xd6>
    fileclose(*f0);
    80004b94:	00000097          	auipc	ra,0x0
    80004b98:	c26080e7          	jalr	-986(ra) # 800047ba <fileclose>
  if(*f1)
    80004b9c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ba0:	557d                	li	a0,-1
  if(*f1)
    80004ba2:	c799                	beqz	a5,80004bb0 <pipealloc+0xc6>
    fileclose(*f1);
    80004ba4:	853e                	mv	a0,a5
    80004ba6:	00000097          	auipc	ra,0x0
    80004baa:	c14080e7          	jalr	-1004(ra) # 800047ba <fileclose>
  return -1;
    80004bae:	557d                	li	a0,-1
}
    80004bb0:	70a2                	ld	ra,40(sp)
    80004bb2:	7402                	ld	s0,32(sp)
    80004bb4:	64e2                	ld	s1,24(sp)
    80004bb6:	6942                	ld	s2,16(sp)
    80004bb8:	69a2                	ld	s3,8(sp)
    80004bba:	6a02                	ld	s4,0(sp)
    80004bbc:	6145                	addi	sp,sp,48
    80004bbe:	8082                	ret
  return -1;
    80004bc0:	557d                	li	a0,-1
    80004bc2:	b7fd                	j	80004bb0 <pipealloc+0xc6>

0000000080004bc4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bc4:	1101                	addi	sp,sp,-32
    80004bc6:	ec06                	sd	ra,24(sp)
    80004bc8:	e822                	sd	s0,16(sp)
    80004bca:	e426                	sd	s1,8(sp)
    80004bcc:	e04a                	sd	s2,0(sp)
    80004bce:	1000                	addi	s0,sp,32
    80004bd0:	84aa                	mv	s1,a0
    80004bd2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bd4:	ffffc097          	auipc	ra,0xffffc
    80004bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
  if(writable){
    80004bdc:	02090d63          	beqz	s2,80004c16 <pipeclose+0x52>
    pi->writeopen = 0;
    80004be0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004be4:	21848513          	addi	a0,s1,536
    80004be8:	ffffd097          	auipc	ra,0xffffd
    80004bec:	538080e7          	jalr	1336(ra) # 80002120 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bf0:	2204b783          	ld	a5,544(s1)
    80004bf4:	eb95                	bnez	a5,80004c28 <pipeclose+0x64>
    release(&pi->lock);
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	092080e7          	jalr	146(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004c00:	8526                	mv	a0,s1
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	de8080e7          	jalr	-536(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004c0a:	60e2                	ld	ra,24(sp)
    80004c0c:	6442                	ld	s0,16(sp)
    80004c0e:	64a2                	ld	s1,8(sp)
    80004c10:	6902                	ld	s2,0(sp)
    80004c12:	6105                	addi	sp,sp,32
    80004c14:	8082                	ret
    pi->readopen = 0;
    80004c16:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c1a:	21c48513          	addi	a0,s1,540
    80004c1e:	ffffd097          	auipc	ra,0xffffd
    80004c22:	502080e7          	jalr	1282(ra) # 80002120 <wakeup>
    80004c26:	b7e9                	j	80004bf0 <pipeclose+0x2c>
    release(&pi->lock);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	060080e7          	jalr	96(ra) # 80000c8a <release>
}
    80004c32:	bfe1                	j	80004c0a <pipeclose+0x46>

0000000080004c34 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c34:	711d                	addi	sp,sp,-96
    80004c36:	ec86                	sd	ra,88(sp)
    80004c38:	e8a2                	sd	s0,80(sp)
    80004c3a:	e4a6                	sd	s1,72(sp)
    80004c3c:	e0ca                	sd	s2,64(sp)
    80004c3e:	fc4e                	sd	s3,56(sp)
    80004c40:	f852                	sd	s4,48(sp)
    80004c42:	f456                	sd	s5,40(sp)
    80004c44:	f05a                	sd	s6,32(sp)
    80004c46:	ec5e                	sd	s7,24(sp)
    80004c48:	e862                	sd	s8,16(sp)
    80004c4a:	1080                	addi	s0,sp,96
    80004c4c:	84aa                	mv	s1,a0
    80004c4e:	8aae                	mv	s5,a1
    80004c50:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c52:	ffffd097          	auipc	ra,0xffffd
    80004c56:	d2e080e7          	jalr	-722(ra) # 80001980 <myproc>
    80004c5a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	f78080e7          	jalr	-136(ra) # 80000bd6 <acquire>
  while(i < n){
    80004c66:	0b405663          	blez	s4,80004d12 <pipewrite+0xde>
  int i = 0;
    80004c6a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c6c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c6e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c72:	21c48b93          	addi	s7,s1,540
    80004c76:	a089                	j	80004cb8 <pipewrite+0x84>
      release(&pi->lock);
    80004c78:	8526                	mv	a0,s1
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	010080e7          	jalr	16(ra) # 80000c8a <release>
      return -1;
    80004c82:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c84:	854a                	mv	a0,s2
    80004c86:	60e6                	ld	ra,88(sp)
    80004c88:	6446                	ld	s0,80(sp)
    80004c8a:	64a6                	ld	s1,72(sp)
    80004c8c:	6906                	ld	s2,64(sp)
    80004c8e:	79e2                	ld	s3,56(sp)
    80004c90:	7a42                	ld	s4,48(sp)
    80004c92:	7aa2                	ld	s5,40(sp)
    80004c94:	7b02                	ld	s6,32(sp)
    80004c96:	6be2                	ld	s7,24(sp)
    80004c98:	6c42                	ld	s8,16(sp)
    80004c9a:	6125                	addi	sp,sp,96
    80004c9c:	8082                	ret
      wakeup(&pi->nread);
    80004c9e:	8562                	mv	a0,s8
    80004ca0:	ffffd097          	auipc	ra,0xffffd
    80004ca4:	480080e7          	jalr	1152(ra) # 80002120 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ca8:	85a6                	mv	a1,s1
    80004caa:	855e                	mv	a0,s7
    80004cac:	ffffd097          	auipc	ra,0xffffd
    80004cb0:	410080e7          	jalr	1040(ra) # 800020bc <sleep>
  while(i < n){
    80004cb4:	07495063          	bge	s2,s4,80004d14 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004cb8:	2204a783          	lw	a5,544(s1)
    80004cbc:	dfd5                	beqz	a5,80004c78 <pipewrite+0x44>
    80004cbe:	854e                	mv	a0,s3
    80004cc0:	ffffd097          	auipc	ra,0xffffd
    80004cc4:	6fe080e7          	jalr	1790(ra) # 800023be <killed>
    80004cc8:	f945                	bnez	a0,80004c78 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cca:	2184a783          	lw	a5,536(s1)
    80004cce:	21c4a703          	lw	a4,540(s1)
    80004cd2:	2007879b          	addiw	a5,a5,512
    80004cd6:	fcf704e3          	beq	a4,a5,80004c9e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cda:	4685                	li	a3,1
    80004cdc:	01590633          	add	a2,s2,s5
    80004ce0:	faf40593          	addi	a1,s0,-81
    80004ce4:	1009b503          	ld	a0,256(s3)
    80004ce8:	ffffd097          	auipc	ra,0xffffd
    80004cec:	a0c080e7          	jalr	-1524(ra) # 800016f4 <copyin>
    80004cf0:	03650263          	beq	a0,s6,80004d14 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cf4:	21c4a783          	lw	a5,540(s1)
    80004cf8:	0017871b          	addiw	a4,a5,1
    80004cfc:	20e4ae23          	sw	a4,540(s1)
    80004d00:	1ff7f793          	andi	a5,a5,511
    80004d04:	97a6                	add	a5,a5,s1
    80004d06:	faf44703          	lbu	a4,-81(s0)
    80004d0a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d0e:	2905                	addiw	s2,s2,1
    80004d10:	b755                	j	80004cb4 <pipewrite+0x80>
  int i = 0;
    80004d12:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d14:	21848513          	addi	a0,s1,536
    80004d18:	ffffd097          	auipc	ra,0xffffd
    80004d1c:	408080e7          	jalr	1032(ra) # 80002120 <wakeup>
  release(&pi->lock);
    80004d20:	8526                	mv	a0,s1
    80004d22:	ffffc097          	auipc	ra,0xffffc
    80004d26:	f68080e7          	jalr	-152(ra) # 80000c8a <release>
  return i;
    80004d2a:	bfa9                	j	80004c84 <pipewrite+0x50>

0000000080004d2c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d2c:	715d                	addi	sp,sp,-80
    80004d2e:	e486                	sd	ra,72(sp)
    80004d30:	e0a2                	sd	s0,64(sp)
    80004d32:	fc26                	sd	s1,56(sp)
    80004d34:	f84a                	sd	s2,48(sp)
    80004d36:	f44e                	sd	s3,40(sp)
    80004d38:	f052                	sd	s4,32(sp)
    80004d3a:	ec56                	sd	s5,24(sp)
    80004d3c:	e85a                	sd	s6,16(sp)
    80004d3e:	0880                	addi	s0,sp,80
    80004d40:	84aa                	mv	s1,a0
    80004d42:	892e                	mv	s2,a1
    80004d44:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d46:	ffffd097          	auipc	ra,0xffffd
    80004d4a:	c3a080e7          	jalr	-966(ra) # 80001980 <myproc>
    80004d4e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d50:	8526                	mv	a0,s1
    80004d52:	ffffc097          	auipc	ra,0xffffc
    80004d56:	e84080e7          	jalr	-380(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d5a:	2184a703          	lw	a4,536(s1)
    80004d5e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d62:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d66:	02f71763          	bne	a4,a5,80004d94 <piperead+0x68>
    80004d6a:	2244a783          	lw	a5,548(s1)
    80004d6e:	c39d                	beqz	a5,80004d94 <piperead+0x68>
    if(killed(pr)){
    80004d70:	8552                	mv	a0,s4
    80004d72:	ffffd097          	auipc	ra,0xffffd
    80004d76:	64c080e7          	jalr	1612(ra) # 800023be <killed>
    80004d7a:	e941                	bnez	a0,80004e0a <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d7c:	85a6                	mv	a1,s1
    80004d7e:	854e                	mv	a0,s3
    80004d80:	ffffd097          	auipc	ra,0xffffd
    80004d84:	33c080e7          	jalr	828(ra) # 800020bc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d88:	2184a703          	lw	a4,536(s1)
    80004d8c:	21c4a783          	lw	a5,540(s1)
    80004d90:	fcf70de3          	beq	a4,a5,80004d6a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d94:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d96:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d98:	05505363          	blez	s5,80004dde <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004d9c:	2184a783          	lw	a5,536(s1)
    80004da0:	21c4a703          	lw	a4,540(s1)
    80004da4:	02f70d63          	beq	a4,a5,80004dde <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004da8:	0017871b          	addiw	a4,a5,1
    80004dac:	20e4ac23          	sw	a4,536(s1)
    80004db0:	1ff7f793          	andi	a5,a5,511
    80004db4:	97a6                	add	a5,a5,s1
    80004db6:	0187c783          	lbu	a5,24(a5)
    80004dba:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dbe:	4685                	li	a3,1
    80004dc0:	fbf40613          	addi	a2,s0,-65
    80004dc4:	85ca                	mv	a1,s2
    80004dc6:	100a3503          	ld	a0,256(s4)
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	89e080e7          	jalr	-1890(ra) # 80001668 <copyout>
    80004dd2:	01650663          	beq	a0,s6,80004dde <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dd6:	2985                	addiw	s3,s3,1
    80004dd8:	0905                	addi	s2,s2,1
    80004dda:	fd3a91e3          	bne	s5,s3,80004d9c <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dde:	21c48513          	addi	a0,s1,540
    80004de2:	ffffd097          	auipc	ra,0xffffd
    80004de6:	33e080e7          	jalr	830(ra) # 80002120 <wakeup>
  release(&pi->lock);
    80004dea:	8526                	mv	a0,s1
    80004dec:	ffffc097          	auipc	ra,0xffffc
    80004df0:	e9e080e7          	jalr	-354(ra) # 80000c8a <release>
  return i;
}
    80004df4:	854e                	mv	a0,s3
    80004df6:	60a6                	ld	ra,72(sp)
    80004df8:	6406                	ld	s0,64(sp)
    80004dfa:	74e2                	ld	s1,56(sp)
    80004dfc:	7942                	ld	s2,48(sp)
    80004dfe:	79a2                	ld	s3,40(sp)
    80004e00:	7a02                	ld	s4,32(sp)
    80004e02:	6ae2                	ld	s5,24(sp)
    80004e04:	6b42                	ld	s6,16(sp)
    80004e06:	6161                	addi	sp,sp,80
    80004e08:	8082                	ret
      release(&pi->lock);
    80004e0a:	8526                	mv	a0,s1
    80004e0c:	ffffc097          	auipc	ra,0xffffc
    80004e10:	e7e080e7          	jalr	-386(ra) # 80000c8a <release>
      return -1;
    80004e14:	59fd                	li	s3,-1
    80004e16:	bff9                	j	80004df4 <piperead+0xc8>

0000000080004e18 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e18:	1141                	addi	sp,sp,-16
    80004e1a:	e422                	sd	s0,8(sp)
    80004e1c:	0800                	addi	s0,sp,16
    80004e1e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e20:	8905                	andi	a0,a0,1
    80004e22:	c111                	beqz	a0,80004e26 <flags2perm+0xe>
      perm = PTE_X;
    80004e24:	4521                	li	a0,8
    if(flags & 0x2)
    80004e26:	8b89                	andi	a5,a5,2
    80004e28:	c399                	beqz	a5,80004e2e <flags2perm+0x16>
      perm |= PTE_W;
    80004e2a:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e2e:	6422                	ld	s0,8(sp)
    80004e30:	0141                	addi	sp,sp,16
    80004e32:	8082                	ret

0000000080004e34 <exec>:

int
exec(char *path, char **argv)
{
    80004e34:	de010113          	addi	sp,sp,-544
    80004e38:	20113c23          	sd	ra,536(sp)
    80004e3c:	20813823          	sd	s0,528(sp)
    80004e40:	20913423          	sd	s1,520(sp)
    80004e44:	21213023          	sd	s2,512(sp)
    80004e48:	ffce                	sd	s3,504(sp)
    80004e4a:	fbd2                	sd	s4,496(sp)
    80004e4c:	f7d6                	sd	s5,488(sp)
    80004e4e:	f3da                	sd	s6,480(sp)
    80004e50:	efde                	sd	s7,472(sp)
    80004e52:	ebe2                	sd	s8,464(sp)
    80004e54:	e7e6                	sd	s9,456(sp)
    80004e56:	e3ea                	sd	s10,448(sp)
    80004e58:	ff6e                	sd	s11,440(sp)
    80004e5a:	1400                	addi	s0,sp,544
    80004e5c:	892a                	mv	s2,a0
    80004e5e:	dea43423          	sd	a0,-536(s0)
    80004e62:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e66:	ffffd097          	auipc	ra,0xffffd
    80004e6a:	b1a080e7          	jalr	-1254(ra) # 80001980 <myproc>
    80004e6e:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80004e70:	ffffe097          	auipc	ra,0xffffe
    80004e74:	87e080e7          	jalr	-1922(ra) # 800026ee <mykthread>

  begin_op();
    80004e78:	fffff097          	auipc	ra,0xfffff
    80004e7c:	476080e7          	jalr	1142(ra) # 800042ee <begin_op>

  if((ip = namei(path)) == 0){
    80004e80:	854a                	mv	a0,s2
    80004e82:	fffff097          	auipc	ra,0xfffff
    80004e86:	250080e7          	jalr	592(ra) # 800040d2 <namei>
    80004e8a:	c93d                	beqz	a0,80004f00 <exec+0xcc>
    80004e8c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e8e:	fffff097          	auipc	ra,0xfffff
    80004e92:	a9e080e7          	jalr	-1378(ra) # 8000392c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e96:	04000713          	li	a4,64
    80004e9a:	4681                	li	a3,0
    80004e9c:	e5040613          	addi	a2,s0,-432
    80004ea0:	4581                	li	a1,0
    80004ea2:	8556                	mv	a0,s5
    80004ea4:	fffff097          	auipc	ra,0xfffff
    80004ea8:	d3c080e7          	jalr	-708(ra) # 80003be0 <readi>
    80004eac:	04000793          	li	a5,64
    80004eb0:	00f51a63          	bne	a0,a5,80004ec4 <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004eb4:	e5042703          	lw	a4,-432(s0)
    80004eb8:	464c47b7          	lui	a5,0x464c4
    80004ebc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ec0:	04f70663          	beq	a4,a5,80004f0c <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ec4:	8556                	mv	a0,s5
    80004ec6:	fffff097          	auipc	ra,0xfffff
    80004eca:	cc8080e7          	jalr	-824(ra) # 80003b8e <iunlockput>
    end_op();
    80004ece:	fffff097          	auipc	ra,0xfffff
    80004ed2:	4a0080e7          	jalr	1184(ra) # 8000436e <end_op>
  }
  return -1;
    80004ed6:	557d                	li	a0,-1
}
    80004ed8:	21813083          	ld	ra,536(sp)
    80004edc:	21013403          	ld	s0,528(sp)
    80004ee0:	20813483          	ld	s1,520(sp)
    80004ee4:	20013903          	ld	s2,512(sp)
    80004ee8:	79fe                	ld	s3,504(sp)
    80004eea:	7a5e                	ld	s4,496(sp)
    80004eec:	7abe                	ld	s5,488(sp)
    80004eee:	7b1e                	ld	s6,480(sp)
    80004ef0:	6bfe                	ld	s7,472(sp)
    80004ef2:	6c5e                	ld	s8,464(sp)
    80004ef4:	6cbe                	ld	s9,456(sp)
    80004ef6:	6d1e                	ld	s10,448(sp)
    80004ef8:	7dfa                	ld	s11,440(sp)
    80004efa:	22010113          	addi	sp,sp,544
    80004efe:	8082                	ret
    end_op();
    80004f00:	fffff097          	auipc	ra,0xfffff
    80004f04:	46e080e7          	jalr	1134(ra) # 8000436e <end_op>
    return -1;
    80004f08:	557d                	li	a0,-1
    80004f0a:	b7f9                	j	80004ed8 <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f0c:	8526                	mv	a0,s1
    80004f0e:	ffffd097          	auipc	ra,0xffffd
    80004f12:	af4080e7          	jalr	-1292(ra) # 80001a02 <proc_pagetable>
    80004f16:	8b2a                	mv	s6,a0
    80004f18:	d555                	beqz	a0,80004ec4 <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f1a:	e7042783          	lw	a5,-400(s0)
    80004f1e:	e8845703          	lhu	a4,-376(s0)
    80004f22:	c735                	beqz	a4,80004f8e <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f24:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f26:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f2a:	6a05                	lui	s4,0x1
    80004f2c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f30:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f34:	6d85                	lui	s11,0x1
    80004f36:	7d7d                	lui	s10,0xfffff
    80004f38:	a4a9                	j	80005182 <exec+0x34e>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f3a:	00003517          	auipc	a0,0x3
    80004f3e:	78650513          	addi	a0,a0,1926 # 800086c0 <syscalls+0x280>
    80004f42:	ffffb097          	auipc	ra,0xffffb
    80004f46:	5fc080e7          	jalr	1532(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f4a:	874a                	mv	a4,s2
    80004f4c:	009c86bb          	addw	a3,s9,s1
    80004f50:	4581                	li	a1,0
    80004f52:	8556                	mv	a0,s5
    80004f54:	fffff097          	auipc	ra,0xfffff
    80004f58:	c8c080e7          	jalr	-884(ra) # 80003be0 <readi>
    80004f5c:	2501                	sext.w	a0,a0
    80004f5e:	1aa91f63          	bne	s2,a0,8000511c <exec+0x2e8>
  for(i = 0; i < sz; i += PGSIZE){
    80004f62:	009d84bb          	addw	s1,s11,s1
    80004f66:	013d09bb          	addw	s3,s10,s3
    80004f6a:	1f74fc63          	bgeu	s1,s7,80005162 <exec+0x32e>
    pa = walkaddr(pagetable, va + i);
    80004f6e:	02049593          	slli	a1,s1,0x20
    80004f72:	9181                	srli	a1,a1,0x20
    80004f74:	95e2                	add	a1,a1,s8
    80004f76:	855a                	mv	a0,s6
    80004f78:	ffffc097          	auipc	ra,0xffffc
    80004f7c:	0e4080e7          	jalr	228(ra) # 8000105c <walkaddr>
    80004f80:	862a                	mv	a2,a0
    if(pa == 0)
    80004f82:	dd45                	beqz	a0,80004f3a <exec+0x106>
      n = PGSIZE;
    80004f84:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f86:	fd49f2e3          	bgeu	s3,s4,80004f4a <exec+0x116>
      n = sz - i;
    80004f8a:	894e                	mv	s2,s3
    80004f8c:	bf7d                	j	80004f4a <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f8e:	4901                	li	s2,0
  iunlockput(ip);
    80004f90:	8556                	mv	a0,s5
    80004f92:	fffff097          	auipc	ra,0xfffff
    80004f96:	bfc080e7          	jalr	-1028(ra) # 80003b8e <iunlockput>
  end_op();
    80004f9a:	fffff097          	auipc	ra,0xfffff
    80004f9e:	3d4080e7          	jalr	980(ra) # 8000436e <end_op>
  p = myproc();
    80004fa2:	ffffd097          	auipc	ra,0xffffd
    80004fa6:	9de080e7          	jalr	-1570(ra) # 80001980 <myproc>
    80004faa:	8baa                	mv	s7,a0
  kt = mykthread();
    80004fac:	ffffd097          	auipc	ra,0xffffd
    80004fb0:	742080e7          	jalr	1858(ra) # 800026ee <mykthread>
    80004fb4:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004fb6:	0f8bbd83          	ld	s11,248(s7) # 10f8 <_entry-0x7fffef08>
  sz = PGROUNDUP(sz);
    80004fba:	6785                	lui	a5,0x1
    80004fbc:	17fd                	addi	a5,a5,-1
    80004fbe:	993e                	add	s2,s2,a5
    80004fc0:	77fd                	lui	a5,0xfffff
    80004fc2:	00f977b3          	and	a5,s2,a5
    80004fc6:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fca:	4691                	li	a3,4
    80004fcc:	6609                	lui	a2,0x2
    80004fce:	963e                	add	a2,a2,a5
    80004fd0:	85be                	mv	a1,a5
    80004fd2:	855a                	mv	a0,s6
    80004fd4:	ffffc097          	auipc	ra,0xffffc
    80004fd8:	43c080e7          	jalr	1084(ra) # 80001410 <uvmalloc>
    80004fdc:	8c2a                	mv	s8,a0
  ip = 0;
    80004fde:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fe0:	12050e63          	beqz	a0,8000511c <exec+0x2e8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fe4:	75f9                	lui	a1,0xffffe
    80004fe6:	95aa                	add	a1,a1,a0
    80004fe8:	855a                	mv	a0,s6
    80004fea:	ffffc097          	auipc	ra,0xffffc
    80004fee:	64c080e7          	jalr	1612(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ff2:	7afd                	lui	s5,0xfffff
    80004ff4:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004ff6:	df043783          	ld	a5,-528(s0)
    80004ffa:	6388                	ld	a0,0(a5)
    80004ffc:	c925                	beqz	a0,8000506c <exec+0x238>
    80004ffe:	e9040993          	addi	s3,s0,-368
    80005002:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005006:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005008:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000500a:	ffffc097          	auipc	ra,0xffffc
    8000500e:	e44080e7          	jalr	-444(ra) # 80000e4e <strlen>
    80005012:	0015079b          	addiw	a5,a0,1
    80005016:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000501a:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000501e:	13596663          	bltu	s2,s5,8000514a <exec+0x316>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005022:	df043783          	ld	a5,-528(s0)
    80005026:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffdbcb0>
    8000502a:	8552                	mv	a0,s4
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	e22080e7          	jalr	-478(ra) # 80000e4e <strlen>
    80005034:	0015069b          	addiw	a3,a0,1
    80005038:	8652                	mv	a2,s4
    8000503a:	85ca                	mv	a1,s2
    8000503c:	855a                	mv	a0,s6
    8000503e:	ffffc097          	auipc	ra,0xffffc
    80005042:	62a080e7          	jalr	1578(ra) # 80001668 <copyout>
    80005046:	10054663          	bltz	a0,80005152 <exec+0x31e>
    ustack[argc] = sp;
    8000504a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000504e:	0485                	addi	s1,s1,1
    80005050:	df043783          	ld	a5,-528(s0)
    80005054:	07a1                	addi	a5,a5,8
    80005056:	def43823          	sd	a5,-528(s0)
    8000505a:	6388                	ld	a0,0(a5)
    8000505c:	c911                	beqz	a0,80005070 <exec+0x23c>
    if(argc >= MAXARG)
    8000505e:	09a1                	addi	s3,s3,8
    80005060:	fb3c95e3          	bne	s9,s3,8000500a <exec+0x1d6>
  sz = sz1;
    80005064:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005068:	4a81                	li	s5,0
    8000506a:	a84d                	j	8000511c <exec+0x2e8>
  sp = sz;
    8000506c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000506e:	4481                	li	s1,0
  ustack[argc] = 0;
    80005070:	00349793          	slli	a5,s1,0x3
    80005074:	f9040713          	addi	a4,s0,-112
    80005078:	97ba                	add	a5,a5,a4
    8000507a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000507e:	00148693          	addi	a3,s1,1
    80005082:	068e                	slli	a3,a3,0x3
    80005084:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005088:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000508c:	01597663          	bgeu	s2,s5,80005098 <exec+0x264>
  sz = sz1;
    80005090:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005094:	4a81                	li	s5,0
    80005096:	a059                	j	8000511c <exec+0x2e8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005098:	e9040613          	addi	a2,s0,-368
    8000509c:	85ca                	mv	a1,s2
    8000509e:	855a                	mv	a0,s6
    800050a0:	ffffc097          	auipc	ra,0xffffc
    800050a4:	5c8080e7          	jalr	1480(ra) # 80001668 <copyout>
    800050a8:	0a054963          	bltz	a0,8000515a <exec+0x326>
  kt->trapframe->a1 = sp;
    800050ac:	0b8d3783          	ld	a5,184(s10) # fffffffffffff0b8 <end+0xffffffff7ffdbd68>
    800050b0:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050b4:	de843783          	ld	a5,-536(s0)
    800050b8:	0007c703          	lbu	a4,0(a5)
    800050bc:	cf11                	beqz	a4,800050d8 <exec+0x2a4>
    800050be:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050c0:	02f00693          	li	a3,47
    800050c4:	a039                	j	800050d2 <exec+0x29e>
      last = s+1;
    800050c6:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050ca:	0785                	addi	a5,a5,1
    800050cc:	fff7c703          	lbu	a4,-1(a5)
    800050d0:	c701                	beqz	a4,800050d8 <exec+0x2a4>
    if(*s == '/')
    800050d2:	fed71ce3          	bne	a4,a3,800050ca <exec+0x296>
    800050d6:	bfc5                	j	800050c6 <exec+0x292>
  safestrcpy(p->name, last, sizeof(p->name));
    800050d8:	4641                	li	a2,16
    800050da:	de843583          	ld	a1,-536(s0)
    800050de:	190b8513          	addi	a0,s7,400
    800050e2:	ffffc097          	auipc	ra,0xffffc
    800050e6:	d3a080e7          	jalr	-710(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800050ea:	100bb503          	ld	a0,256(s7)
  p->pagetable = pagetable;
    800050ee:	116bb023          	sd	s6,256(s7)
  p->sz = sz;
    800050f2:	0f8bbc23          	sd	s8,248(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    800050f6:	0b8d3783          	ld	a5,184(s10)
    800050fa:	e6843703          	ld	a4,-408(s0)
    800050fe:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    80005100:	0b8d3783          	ld	a5,184(s10)
    80005104:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005108:	85ee                	mv	a1,s11
    8000510a:	ffffd097          	auipc	ra,0xffffd
    8000510e:	994080e7          	jalr	-1644(ra) # 80001a9e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005112:	0004851b          	sext.w	a0,s1
    80005116:	b3c9                	j	80004ed8 <exec+0xa4>
    80005118:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000511c:	df843583          	ld	a1,-520(s0)
    80005120:	855a                	mv	a0,s6
    80005122:	ffffd097          	auipc	ra,0xffffd
    80005126:	97c080e7          	jalr	-1668(ra) # 80001a9e <proc_freepagetable>
  if(ip){
    8000512a:	d80a9de3          	bnez	s5,80004ec4 <exec+0x90>
  return -1;
    8000512e:	557d                	li	a0,-1
    80005130:	b365                	j	80004ed8 <exec+0xa4>
    80005132:	df243c23          	sd	s2,-520(s0)
    80005136:	b7dd                	j	8000511c <exec+0x2e8>
    80005138:	df243c23          	sd	s2,-520(s0)
    8000513c:	b7c5                	j	8000511c <exec+0x2e8>
    8000513e:	df243c23          	sd	s2,-520(s0)
    80005142:	bfe9                	j	8000511c <exec+0x2e8>
    80005144:	df243c23          	sd	s2,-520(s0)
    80005148:	bfd1                	j	8000511c <exec+0x2e8>
  sz = sz1;
    8000514a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000514e:	4a81                	li	s5,0
    80005150:	b7f1                	j	8000511c <exec+0x2e8>
  sz = sz1;
    80005152:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005156:	4a81                	li	s5,0
    80005158:	b7d1                	j	8000511c <exec+0x2e8>
  sz = sz1;
    8000515a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000515e:	4a81                	li	s5,0
    80005160:	bf75                	j	8000511c <exec+0x2e8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005162:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005166:	e0843783          	ld	a5,-504(s0)
    8000516a:	0017869b          	addiw	a3,a5,1
    8000516e:	e0d43423          	sd	a3,-504(s0)
    80005172:	e0043783          	ld	a5,-512(s0)
    80005176:	0387879b          	addiw	a5,a5,56
    8000517a:	e8845703          	lhu	a4,-376(s0)
    8000517e:	e0e6d9e3          	bge	a3,a4,80004f90 <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005182:	2781                	sext.w	a5,a5
    80005184:	e0f43023          	sd	a5,-512(s0)
    80005188:	03800713          	li	a4,56
    8000518c:	86be                	mv	a3,a5
    8000518e:	e1840613          	addi	a2,s0,-488
    80005192:	4581                	li	a1,0
    80005194:	8556                	mv	a0,s5
    80005196:	fffff097          	auipc	ra,0xfffff
    8000519a:	a4a080e7          	jalr	-1462(ra) # 80003be0 <readi>
    8000519e:	03800793          	li	a5,56
    800051a2:	f6f51be3          	bne	a0,a5,80005118 <exec+0x2e4>
    if(ph.type != ELF_PROG_LOAD)
    800051a6:	e1842783          	lw	a5,-488(s0)
    800051aa:	4705                	li	a4,1
    800051ac:	fae79de3          	bne	a5,a4,80005166 <exec+0x332>
    if(ph.memsz < ph.filesz)
    800051b0:	e4043483          	ld	s1,-448(s0)
    800051b4:	e3843783          	ld	a5,-456(s0)
    800051b8:	f6f4ede3          	bltu	s1,a5,80005132 <exec+0x2fe>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051bc:	e2843783          	ld	a5,-472(s0)
    800051c0:	94be                	add	s1,s1,a5
    800051c2:	f6f4ebe3          	bltu	s1,a5,80005138 <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    800051c6:	de043703          	ld	a4,-544(s0)
    800051ca:	8ff9                	and	a5,a5,a4
    800051cc:	fbad                	bnez	a5,8000513e <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051ce:	e1c42503          	lw	a0,-484(s0)
    800051d2:	00000097          	auipc	ra,0x0
    800051d6:	c46080e7          	jalr	-954(ra) # 80004e18 <flags2perm>
    800051da:	86aa                	mv	a3,a0
    800051dc:	8626                	mv	a2,s1
    800051de:	85ca                	mv	a1,s2
    800051e0:	855a                	mv	a0,s6
    800051e2:	ffffc097          	auipc	ra,0xffffc
    800051e6:	22e080e7          	jalr	558(ra) # 80001410 <uvmalloc>
    800051ea:	dea43c23          	sd	a0,-520(s0)
    800051ee:	d939                	beqz	a0,80005144 <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051f0:	e2843c03          	ld	s8,-472(s0)
    800051f4:	e2042c83          	lw	s9,-480(s0)
    800051f8:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051fc:	f60b83e3          	beqz	s7,80005162 <exec+0x32e>
    80005200:	89de                	mv	s3,s7
    80005202:	4481                	li	s1,0
    80005204:	b3ad                	j	80004f6e <exec+0x13a>

0000000080005206 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005206:	7179                	addi	sp,sp,-48
    80005208:	f406                	sd	ra,40(sp)
    8000520a:	f022                	sd	s0,32(sp)
    8000520c:	ec26                	sd	s1,24(sp)
    8000520e:	e84a                	sd	s2,16(sp)
    80005210:	1800                	addi	s0,sp,48
    80005212:	892e                	mv	s2,a1
    80005214:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005216:	fdc40593          	addi	a1,s0,-36
    8000521a:	ffffe097          	auipc	ra,0xffffe
    8000521e:	b96080e7          	jalr	-1130(ra) # 80002db0 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005222:	fdc42703          	lw	a4,-36(s0)
    80005226:	47bd                	li	a5,15
    80005228:	02e7eb63          	bltu	a5,a4,8000525e <argfd+0x58>
    8000522c:	ffffc097          	auipc	ra,0xffffc
    80005230:	754080e7          	jalr	1876(ra) # 80001980 <myproc>
    80005234:	fdc42703          	lw	a4,-36(s0)
    80005238:	02070793          	addi	a5,a4,32
    8000523c:	078e                	slli	a5,a5,0x3
    8000523e:	953e                	add	a0,a0,a5
    80005240:	651c                	ld	a5,8(a0)
    80005242:	c385                	beqz	a5,80005262 <argfd+0x5c>
    return -1;
  if(pfd)
    80005244:	00090463          	beqz	s2,8000524c <argfd+0x46>
    *pfd = fd;
    80005248:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000524c:	4501                	li	a0,0
  if(pf)
    8000524e:	c091                	beqz	s1,80005252 <argfd+0x4c>
    *pf = f;
    80005250:	e09c                	sd	a5,0(s1)
}
    80005252:	70a2                	ld	ra,40(sp)
    80005254:	7402                	ld	s0,32(sp)
    80005256:	64e2                	ld	s1,24(sp)
    80005258:	6942                	ld	s2,16(sp)
    8000525a:	6145                	addi	sp,sp,48
    8000525c:	8082                	ret
    return -1;
    8000525e:	557d                	li	a0,-1
    80005260:	bfcd                	j	80005252 <argfd+0x4c>
    80005262:	557d                	li	a0,-1
    80005264:	b7fd                	j	80005252 <argfd+0x4c>

0000000080005266 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005266:	1101                	addi	sp,sp,-32
    80005268:	ec06                	sd	ra,24(sp)
    8000526a:	e822                	sd	s0,16(sp)
    8000526c:	e426                	sd	s1,8(sp)
    8000526e:	1000                	addi	s0,sp,32
    80005270:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005272:	ffffc097          	auipc	ra,0xffffc
    80005276:	70e080e7          	jalr	1806(ra) # 80001980 <myproc>
    8000527a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000527c:	10850793          	addi	a5,a0,264
    80005280:	4501                	li	a0,0
    80005282:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005284:	6398                	ld	a4,0(a5)
    80005286:	cb19                	beqz	a4,8000529c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005288:	2505                	addiw	a0,a0,1
    8000528a:	07a1                	addi	a5,a5,8
    8000528c:	fed51ce3          	bne	a0,a3,80005284 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005290:	557d                	li	a0,-1
}
    80005292:	60e2                	ld	ra,24(sp)
    80005294:	6442                	ld	s0,16(sp)
    80005296:	64a2                	ld	s1,8(sp)
    80005298:	6105                	addi	sp,sp,32
    8000529a:	8082                	ret
      p->ofile[fd] = f;
    8000529c:	02050793          	addi	a5,a0,32
    800052a0:	078e                	slli	a5,a5,0x3
    800052a2:	963e                	add	a2,a2,a5
    800052a4:	e604                	sd	s1,8(a2)
      return fd;
    800052a6:	b7f5                	j	80005292 <fdalloc+0x2c>

00000000800052a8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052a8:	715d                	addi	sp,sp,-80
    800052aa:	e486                	sd	ra,72(sp)
    800052ac:	e0a2                	sd	s0,64(sp)
    800052ae:	fc26                	sd	s1,56(sp)
    800052b0:	f84a                	sd	s2,48(sp)
    800052b2:	f44e                	sd	s3,40(sp)
    800052b4:	f052                	sd	s4,32(sp)
    800052b6:	ec56                	sd	s5,24(sp)
    800052b8:	e85a                	sd	s6,16(sp)
    800052ba:	0880                	addi	s0,sp,80
    800052bc:	8b2e                	mv	s6,a1
    800052be:	89b2                	mv	s3,a2
    800052c0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052c2:	fb040593          	addi	a1,s0,-80
    800052c6:	fffff097          	auipc	ra,0xfffff
    800052ca:	e2a080e7          	jalr	-470(ra) # 800040f0 <nameiparent>
    800052ce:	84aa                	mv	s1,a0
    800052d0:	14050f63          	beqz	a0,8000542e <create+0x186>
    return 0;

  ilock(dp);
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	658080e7          	jalr	1624(ra) # 8000392c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052dc:	4601                	li	a2,0
    800052de:	fb040593          	addi	a1,s0,-80
    800052e2:	8526                	mv	a0,s1
    800052e4:	fffff097          	auipc	ra,0xfffff
    800052e8:	b2c080e7          	jalr	-1236(ra) # 80003e10 <dirlookup>
    800052ec:	8aaa                	mv	s5,a0
    800052ee:	c931                	beqz	a0,80005342 <create+0x9a>
    iunlockput(dp);
    800052f0:	8526                	mv	a0,s1
    800052f2:	fffff097          	auipc	ra,0xfffff
    800052f6:	89c080e7          	jalr	-1892(ra) # 80003b8e <iunlockput>
    ilock(ip);
    800052fa:	8556                	mv	a0,s5
    800052fc:	ffffe097          	auipc	ra,0xffffe
    80005300:	630080e7          	jalr	1584(ra) # 8000392c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005304:	000b059b          	sext.w	a1,s6
    80005308:	4789                	li	a5,2
    8000530a:	02f59563          	bne	a1,a5,80005334 <create+0x8c>
    8000530e:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbcf4>
    80005312:	37f9                	addiw	a5,a5,-2
    80005314:	17c2                	slli	a5,a5,0x30
    80005316:	93c1                	srli	a5,a5,0x30
    80005318:	4705                	li	a4,1
    8000531a:	00f76d63          	bltu	a4,a5,80005334 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000531e:	8556                	mv	a0,s5
    80005320:	60a6                	ld	ra,72(sp)
    80005322:	6406                	ld	s0,64(sp)
    80005324:	74e2                	ld	s1,56(sp)
    80005326:	7942                	ld	s2,48(sp)
    80005328:	79a2                	ld	s3,40(sp)
    8000532a:	7a02                	ld	s4,32(sp)
    8000532c:	6ae2                	ld	s5,24(sp)
    8000532e:	6b42                	ld	s6,16(sp)
    80005330:	6161                	addi	sp,sp,80
    80005332:	8082                	ret
    iunlockput(ip);
    80005334:	8556                	mv	a0,s5
    80005336:	fffff097          	auipc	ra,0xfffff
    8000533a:	858080e7          	jalr	-1960(ra) # 80003b8e <iunlockput>
    return 0;
    8000533e:	4a81                	li	s5,0
    80005340:	bff9                	j	8000531e <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005342:	85da                	mv	a1,s6
    80005344:	4088                	lw	a0,0(s1)
    80005346:	ffffe097          	auipc	ra,0xffffe
    8000534a:	44a080e7          	jalr	1098(ra) # 80003790 <ialloc>
    8000534e:	8a2a                	mv	s4,a0
    80005350:	c539                	beqz	a0,8000539e <create+0xf6>
  ilock(ip);
    80005352:	ffffe097          	auipc	ra,0xffffe
    80005356:	5da080e7          	jalr	1498(ra) # 8000392c <ilock>
  ip->major = major;
    8000535a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000535e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005362:	4905                	li	s2,1
    80005364:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005368:	8552                	mv	a0,s4
    8000536a:	ffffe097          	auipc	ra,0xffffe
    8000536e:	4f8080e7          	jalr	1272(ra) # 80003862 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005372:	000b059b          	sext.w	a1,s6
    80005376:	03258b63          	beq	a1,s2,800053ac <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000537a:	004a2603          	lw	a2,4(s4)
    8000537e:	fb040593          	addi	a1,s0,-80
    80005382:	8526                	mv	a0,s1
    80005384:	fffff097          	auipc	ra,0xfffff
    80005388:	c9c080e7          	jalr	-868(ra) # 80004020 <dirlink>
    8000538c:	06054f63          	bltz	a0,8000540a <create+0x162>
  iunlockput(dp);
    80005390:	8526                	mv	a0,s1
    80005392:	ffffe097          	auipc	ra,0xffffe
    80005396:	7fc080e7          	jalr	2044(ra) # 80003b8e <iunlockput>
  return ip;
    8000539a:	8ad2                	mv	s5,s4
    8000539c:	b749                	j	8000531e <create+0x76>
    iunlockput(dp);
    8000539e:	8526                	mv	a0,s1
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	7ee080e7          	jalr	2030(ra) # 80003b8e <iunlockput>
    return 0;
    800053a8:	8ad2                	mv	s5,s4
    800053aa:	bf95                	j	8000531e <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053ac:	004a2603          	lw	a2,4(s4)
    800053b0:	00003597          	auipc	a1,0x3
    800053b4:	33058593          	addi	a1,a1,816 # 800086e0 <syscalls+0x2a0>
    800053b8:	8552                	mv	a0,s4
    800053ba:	fffff097          	auipc	ra,0xfffff
    800053be:	c66080e7          	jalr	-922(ra) # 80004020 <dirlink>
    800053c2:	04054463          	bltz	a0,8000540a <create+0x162>
    800053c6:	40d0                	lw	a2,4(s1)
    800053c8:	00003597          	auipc	a1,0x3
    800053cc:	32058593          	addi	a1,a1,800 # 800086e8 <syscalls+0x2a8>
    800053d0:	8552                	mv	a0,s4
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	c4e080e7          	jalr	-946(ra) # 80004020 <dirlink>
    800053da:	02054863          	bltz	a0,8000540a <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800053de:	004a2603          	lw	a2,4(s4)
    800053e2:	fb040593          	addi	a1,s0,-80
    800053e6:	8526                	mv	a0,s1
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	c38080e7          	jalr	-968(ra) # 80004020 <dirlink>
    800053f0:	00054d63          	bltz	a0,8000540a <create+0x162>
    dp->nlink++;  // for ".."
    800053f4:	04a4d783          	lhu	a5,74(s1)
    800053f8:	2785                	addiw	a5,a5,1
    800053fa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800053fe:	8526                	mv	a0,s1
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	462080e7          	jalr	1122(ra) # 80003862 <iupdate>
    80005408:	b761                	j	80005390 <create+0xe8>
  ip->nlink = 0;
    8000540a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000540e:	8552                	mv	a0,s4
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	452080e7          	jalr	1106(ra) # 80003862 <iupdate>
  iunlockput(ip);
    80005418:	8552                	mv	a0,s4
    8000541a:	ffffe097          	auipc	ra,0xffffe
    8000541e:	774080e7          	jalr	1908(ra) # 80003b8e <iunlockput>
  iunlockput(dp);
    80005422:	8526                	mv	a0,s1
    80005424:	ffffe097          	auipc	ra,0xffffe
    80005428:	76a080e7          	jalr	1898(ra) # 80003b8e <iunlockput>
  return 0;
    8000542c:	bdcd                	j	8000531e <create+0x76>
    return 0;
    8000542e:	8aaa                	mv	s5,a0
    80005430:	b5fd                	j	8000531e <create+0x76>

0000000080005432 <sys_dup>:
{
    80005432:	7179                	addi	sp,sp,-48
    80005434:	f406                	sd	ra,40(sp)
    80005436:	f022                	sd	s0,32(sp)
    80005438:	ec26                	sd	s1,24(sp)
    8000543a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000543c:	fd840613          	addi	a2,s0,-40
    80005440:	4581                	li	a1,0
    80005442:	4501                	li	a0,0
    80005444:	00000097          	auipc	ra,0x0
    80005448:	dc2080e7          	jalr	-574(ra) # 80005206 <argfd>
    return -1;
    8000544c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000544e:	02054363          	bltz	a0,80005474 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005452:	fd843503          	ld	a0,-40(s0)
    80005456:	00000097          	auipc	ra,0x0
    8000545a:	e10080e7          	jalr	-496(ra) # 80005266 <fdalloc>
    8000545e:	84aa                	mv	s1,a0
    return -1;
    80005460:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005462:	00054963          	bltz	a0,80005474 <sys_dup+0x42>
  filedup(f);
    80005466:	fd843503          	ld	a0,-40(s0)
    8000546a:	fffff097          	auipc	ra,0xfffff
    8000546e:	2fe080e7          	jalr	766(ra) # 80004768 <filedup>
  return fd;
    80005472:	87a6                	mv	a5,s1
}
    80005474:	853e                	mv	a0,a5
    80005476:	70a2                	ld	ra,40(sp)
    80005478:	7402                	ld	s0,32(sp)
    8000547a:	64e2                	ld	s1,24(sp)
    8000547c:	6145                	addi	sp,sp,48
    8000547e:	8082                	ret

0000000080005480 <sys_read>:
{
    80005480:	7179                	addi	sp,sp,-48
    80005482:	f406                	sd	ra,40(sp)
    80005484:	f022                	sd	s0,32(sp)
    80005486:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005488:	fd840593          	addi	a1,s0,-40
    8000548c:	4505                	li	a0,1
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	942080e7          	jalr	-1726(ra) # 80002dd0 <argaddr>
  argint(2, &n);
    80005496:	fe440593          	addi	a1,s0,-28
    8000549a:	4509                	li	a0,2
    8000549c:	ffffe097          	auipc	ra,0xffffe
    800054a0:	914080e7          	jalr	-1772(ra) # 80002db0 <argint>
  if(argfd(0, 0, &f) < 0)
    800054a4:	fe840613          	addi	a2,s0,-24
    800054a8:	4581                	li	a1,0
    800054aa:	4501                	li	a0,0
    800054ac:	00000097          	auipc	ra,0x0
    800054b0:	d5a080e7          	jalr	-678(ra) # 80005206 <argfd>
    800054b4:	87aa                	mv	a5,a0
    return -1;
    800054b6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054b8:	0007cc63          	bltz	a5,800054d0 <sys_read+0x50>
  return fileread(f, p, n);
    800054bc:	fe442603          	lw	a2,-28(s0)
    800054c0:	fd843583          	ld	a1,-40(s0)
    800054c4:	fe843503          	ld	a0,-24(s0)
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	42c080e7          	jalr	1068(ra) # 800048f4 <fileread>
}
    800054d0:	70a2                	ld	ra,40(sp)
    800054d2:	7402                	ld	s0,32(sp)
    800054d4:	6145                	addi	sp,sp,48
    800054d6:	8082                	ret

00000000800054d8 <sys_write>:
{
    800054d8:	7179                	addi	sp,sp,-48
    800054da:	f406                	sd	ra,40(sp)
    800054dc:	f022                	sd	s0,32(sp)
    800054de:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054e0:	fd840593          	addi	a1,s0,-40
    800054e4:	4505                	li	a0,1
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	8ea080e7          	jalr	-1814(ra) # 80002dd0 <argaddr>
  argint(2, &n);
    800054ee:	fe440593          	addi	a1,s0,-28
    800054f2:	4509                	li	a0,2
    800054f4:	ffffe097          	auipc	ra,0xffffe
    800054f8:	8bc080e7          	jalr	-1860(ra) # 80002db0 <argint>
  if(argfd(0, 0, &f) < 0)
    800054fc:	fe840613          	addi	a2,s0,-24
    80005500:	4581                	li	a1,0
    80005502:	4501                	li	a0,0
    80005504:	00000097          	auipc	ra,0x0
    80005508:	d02080e7          	jalr	-766(ra) # 80005206 <argfd>
    8000550c:	87aa                	mv	a5,a0
    return -1;
    8000550e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005510:	0007cc63          	bltz	a5,80005528 <sys_write+0x50>
  return filewrite(f, p, n);
    80005514:	fe442603          	lw	a2,-28(s0)
    80005518:	fd843583          	ld	a1,-40(s0)
    8000551c:	fe843503          	ld	a0,-24(s0)
    80005520:	fffff097          	auipc	ra,0xfffff
    80005524:	496080e7          	jalr	1174(ra) # 800049b6 <filewrite>
}
    80005528:	70a2                	ld	ra,40(sp)
    8000552a:	7402                	ld	s0,32(sp)
    8000552c:	6145                	addi	sp,sp,48
    8000552e:	8082                	ret

0000000080005530 <sys_close>:
{
    80005530:	1101                	addi	sp,sp,-32
    80005532:	ec06                	sd	ra,24(sp)
    80005534:	e822                	sd	s0,16(sp)
    80005536:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005538:	fe040613          	addi	a2,s0,-32
    8000553c:	fec40593          	addi	a1,s0,-20
    80005540:	4501                	li	a0,0
    80005542:	00000097          	auipc	ra,0x0
    80005546:	cc4080e7          	jalr	-828(ra) # 80005206 <argfd>
    return -1;
    8000554a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000554c:	02054563          	bltz	a0,80005576 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005550:	ffffc097          	auipc	ra,0xffffc
    80005554:	430080e7          	jalr	1072(ra) # 80001980 <myproc>
    80005558:	fec42783          	lw	a5,-20(s0)
    8000555c:	02078793          	addi	a5,a5,32
    80005560:	078e                	slli	a5,a5,0x3
    80005562:	97aa                	add	a5,a5,a0
    80005564:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005568:	fe043503          	ld	a0,-32(s0)
    8000556c:	fffff097          	auipc	ra,0xfffff
    80005570:	24e080e7          	jalr	590(ra) # 800047ba <fileclose>
  return 0;
    80005574:	4781                	li	a5,0
}
    80005576:	853e                	mv	a0,a5
    80005578:	60e2                	ld	ra,24(sp)
    8000557a:	6442                	ld	s0,16(sp)
    8000557c:	6105                	addi	sp,sp,32
    8000557e:	8082                	ret

0000000080005580 <sys_fstat>:
{
    80005580:	1101                	addi	sp,sp,-32
    80005582:	ec06                	sd	ra,24(sp)
    80005584:	e822                	sd	s0,16(sp)
    80005586:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005588:	fe040593          	addi	a1,s0,-32
    8000558c:	4505                	li	a0,1
    8000558e:	ffffe097          	auipc	ra,0xffffe
    80005592:	842080e7          	jalr	-1982(ra) # 80002dd0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005596:	fe840613          	addi	a2,s0,-24
    8000559a:	4581                	li	a1,0
    8000559c:	4501                	li	a0,0
    8000559e:	00000097          	auipc	ra,0x0
    800055a2:	c68080e7          	jalr	-920(ra) # 80005206 <argfd>
    800055a6:	87aa                	mv	a5,a0
    return -1;
    800055a8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055aa:	0007ca63          	bltz	a5,800055be <sys_fstat+0x3e>
  return filestat(f, st);
    800055ae:	fe043583          	ld	a1,-32(s0)
    800055b2:	fe843503          	ld	a0,-24(s0)
    800055b6:	fffff097          	auipc	ra,0xfffff
    800055ba:	2cc080e7          	jalr	716(ra) # 80004882 <filestat>
}
    800055be:	60e2                	ld	ra,24(sp)
    800055c0:	6442                	ld	s0,16(sp)
    800055c2:	6105                	addi	sp,sp,32
    800055c4:	8082                	ret

00000000800055c6 <sys_link>:
{
    800055c6:	7169                	addi	sp,sp,-304
    800055c8:	f606                	sd	ra,296(sp)
    800055ca:	f222                	sd	s0,288(sp)
    800055cc:	ee26                	sd	s1,280(sp)
    800055ce:	ea4a                	sd	s2,272(sp)
    800055d0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055d2:	08000613          	li	a2,128
    800055d6:	ed040593          	addi	a1,s0,-304
    800055da:	4501                	li	a0,0
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	814080e7          	jalr	-2028(ra) # 80002df0 <argstr>
    return -1;
    800055e4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055e6:	10054e63          	bltz	a0,80005702 <sys_link+0x13c>
    800055ea:	08000613          	li	a2,128
    800055ee:	f5040593          	addi	a1,s0,-176
    800055f2:	4505                	li	a0,1
    800055f4:	ffffd097          	auipc	ra,0xffffd
    800055f8:	7fc080e7          	jalr	2044(ra) # 80002df0 <argstr>
    return -1;
    800055fc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055fe:	10054263          	bltz	a0,80005702 <sys_link+0x13c>
  begin_op();
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	cec080e7          	jalr	-788(ra) # 800042ee <begin_op>
  if((ip = namei(old)) == 0){
    8000560a:	ed040513          	addi	a0,s0,-304
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	ac4080e7          	jalr	-1340(ra) # 800040d2 <namei>
    80005616:	84aa                	mv	s1,a0
    80005618:	c551                	beqz	a0,800056a4 <sys_link+0xde>
  ilock(ip);
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	312080e7          	jalr	786(ra) # 8000392c <ilock>
  if(ip->type == T_DIR){
    80005622:	04449703          	lh	a4,68(s1)
    80005626:	4785                	li	a5,1
    80005628:	08f70463          	beq	a4,a5,800056b0 <sys_link+0xea>
  ip->nlink++;
    8000562c:	04a4d783          	lhu	a5,74(s1)
    80005630:	2785                	addiw	a5,a5,1
    80005632:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005636:	8526                	mv	a0,s1
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	22a080e7          	jalr	554(ra) # 80003862 <iupdate>
  iunlock(ip);
    80005640:	8526                	mv	a0,s1
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	3ac080e7          	jalr	940(ra) # 800039ee <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000564a:	fd040593          	addi	a1,s0,-48
    8000564e:	f5040513          	addi	a0,s0,-176
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	a9e080e7          	jalr	-1378(ra) # 800040f0 <nameiparent>
    8000565a:	892a                	mv	s2,a0
    8000565c:	c935                	beqz	a0,800056d0 <sys_link+0x10a>
  ilock(dp);
    8000565e:	ffffe097          	auipc	ra,0xffffe
    80005662:	2ce080e7          	jalr	718(ra) # 8000392c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005666:	00092703          	lw	a4,0(s2)
    8000566a:	409c                	lw	a5,0(s1)
    8000566c:	04f71d63          	bne	a4,a5,800056c6 <sys_link+0x100>
    80005670:	40d0                	lw	a2,4(s1)
    80005672:	fd040593          	addi	a1,s0,-48
    80005676:	854a                	mv	a0,s2
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	9a8080e7          	jalr	-1624(ra) # 80004020 <dirlink>
    80005680:	04054363          	bltz	a0,800056c6 <sys_link+0x100>
  iunlockput(dp);
    80005684:	854a                	mv	a0,s2
    80005686:	ffffe097          	auipc	ra,0xffffe
    8000568a:	508080e7          	jalr	1288(ra) # 80003b8e <iunlockput>
  iput(ip);
    8000568e:	8526                	mv	a0,s1
    80005690:	ffffe097          	auipc	ra,0xffffe
    80005694:	456080e7          	jalr	1110(ra) # 80003ae6 <iput>
  end_op();
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	cd6080e7          	jalr	-810(ra) # 8000436e <end_op>
  return 0;
    800056a0:	4781                	li	a5,0
    800056a2:	a085                	j	80005702 <sys_link+0x13c>
    end_op();
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	cca080e7          	jalr	-822(ra) # 8000436e <end_op>
    return -1;
    800056ac:	57fd                	li	a5,-1
    800056ae:	a891                	j	80005702 <sys_link+0x13c>
    iunlockput(ip);
    800056b0:	8526                	mv	a0,s1
    800056b2:	ffffe097          	auipc	ra,0xffffe
    800056b6:	4dc080e7          	jalr	1244(ra) # 80003b8e <iunlockput>
    end_op();
    800056ba:	fffff097          	auipc	ra,0xfffff
    800056be:	cb4080e7          	jalr	-844(ra) # 8000436e <end_op>
    return -1;
    800056c2:	57fd                	li	a5,-1
    800056c4:	a83d                	j	80005702 <sys_link+0x13c>
    iunlockput(dp);
    800056c6:	854a                	mv	a0,s2
    800056c8:	ffffe097          	auipc	ra,0xffffe
    800056cc:	4c6080e7          	jalr	1222(ra) # 80003b8e <iunlockput>
  ilock(ip);
    800056d0:	8526                	mv	a0,s1
    800056d2:	ffffe097          	auipc	ra,0xffffe
    800056d6:	25a080e7          	jalr	602(ra) # 8000392c <ilock>
  ip->nlink--;
    800056da:	04a4d783          	lhu	a5,74(s1)
    800056de:	37fd                	addiw	a5,a5,-1
    800056e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	17c080e7          	jalr	380(ra) # 80003862 <iupdate>
  iunlockput(ip);
    800056ee:	8526                	mv	a0,s1
    800056f0:	ffffe097          	auipc	ra,0xffffe
    800056f4:	49e080e7          	jalr	1182(ra) # 80003b8e <iunlockput>
  end_op();
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	c76080e7          	jalr	-906(ra) # 8000436e <end_op>
  return -1;
    80005700:	57fd                	li	a5,-1
}
    80005702:	853e                	mv	a0,a5
    80005704:	70b2                	ld	ra,296(sp)
    80005706:	7412                	ld	s0,288(sp)
    80005708:	64f2                	ld	s1,280(sp)
    8000570a:	6952                	ld	s2,272(sp)
    8000570c:	6155                	addi	sp,sp,304
    8000570e:	8082                	ret

0000000080005710 <sys_unlink>:
{
    80005710:	7151                	addi	sp,sp,-240
    80005712:	f586                	sd	ra,232(sp)
    80005714:	f1a2                	sd	s0,224(sp)
    80005716:	eda6                	sd	s1,216(sp)
    80005718:	e9ca                	sd	s2,208(sp)
    8000571a:	e5ce                	sd	s3,200(sp)
    8000571c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000571e:	08000613          	li	a2,128
    80005722:	f3040593          	addi	a1,s0,-208
    80005726:	4501                	li	a0,0
    80005728:	ffffd097          	auipc	ra,0xffffd
    8000572c:	6c8080e7          	jalr	1736(ra) # 80002df0 <argstr>
    80005730:	18054163          	bltz	a0,800058b2 <sys_unlink+0x1a2>
  begin_op();
    80005734:	fffff097          	auipc	ra,0xfffff
    80005738:	bba080e7          	jalr	-1094(ra) # 800042ee <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000573c:	fb040593          	addi	a1,s0,-80
    80005740:	f3040513          	addi	a0,s0,-208
    80005744:	fffff097          	auipc	ra,0xfffff
    80005748:	9ac080e7          	jalr	-1620(ra) # 800040f0 <nameiparent>
    8000574c:	84aa                	mv	s1,a0
    8000574e:	c979                	beqz	a0,80005824 <sys_unlink+0x114>
  ilock(dp);
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	1dc080e7          	jalr	476(ra) # 8000392c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005758:	00003597          	auipc	a1,0x3
    8000575c:	f8858593          	addi	a1,a1,-120 # 800086e0 <syscalls+0x2a0>
    80005760:	fb040513          	addi	a0,s0,-80
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	692080e7          	jalr	1682(ra) # 80003df6 <namecmp>
    8000576c:	14050a63          	beqz	a0,800058c0 <sys_unlink+0x1b0>
    80005770:	00003597          	auipc	a1,0x3
    80005774:	f7858593          	addi	a1,a1,-136 # 800086e8 <syscalls+0x2a8>
    80005778:	fb040513          	addi	a0,s0,-80
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	67a080e7          	jalr	1658(ra) # 80003df6 <namecmp>
    80005784:	12050e63          	beqz	a0,800058c0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005788:	f2c40613          	addi	a2,s0,-212
    8000578c:	fb040593          	addi	a1,s0,-80
    80005790:	8526                	mv	a0,s1
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	67e080e7          	jalr	1662(ra) # 80003e10 <dirlookup>
    8000579a:	892a                	mv	s2,a0
    8000579c:	12050263          	beqz	a0,800058c0 <sys_unlink+0x1b0>
  ilock(ip);
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	18c080e7          	jalr	396(ra) # 8000392c <ilock>
  if(ip->nlink < 1)
    800057a8:	04a91783          	lh	a5,74(s2)
    800057ac:	08f05263          	blez	a5,80005830 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057b0:	04491703          	lh	a4,68(s2)
    800057b4:	4785                	li	a5,1
    800057b6:	08f70563          	beq	a4,a5,80005840 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057ba:	4641                	li	a2,16
    800057bc:	4581                	li	a1,0
    800057be:	fc040513          	addi	a0,s0,-64
    800057c2:	ffffb097          	auipc	ra,0xffffb
    800057c6:	510080e7          	jalr	1296(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057ca:	4741                	li	a4,16
    800057cc:	f2c42683          	lw	a3,-212(s0)
    800057d0:	fc040613          	addi	a2,s0,-64
    800057d4:	4581                	li	a1,0
    800057d6:	8526                	mv	a0,s1
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	500080e7          	jalr	1280(ra) # 80003cd8 <writei>
    800057e0:	47c1                	li	a5,16
    800057e2:	0af51563          	bne	a0,a5,8000588c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057e6:	04491703          	lh	a4,68(s2)
    800057ea:	4785                	li	a5,1
    800057ec:	0af70863          	beq	a4,a5,8000589c <sys_unlink+0x18c>
  iunlockput(dp);
    800057f0:	8526                	mv	a0,s1
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	39c080e7          	jalr	924(ra) # 80003b8e <iunlockput>
  ip->nlink--;
    800057fa:	04a95783          	lhu	a5,74(s2)
    800057fe:	37fd                	addiw	a5,a5,-1
    80005800:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005804:	854a                	mv	a0,s2
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	05c080e7          	jalr	92(ra) # 80003862 <iupdate>
  iunlockput(ip);
    8000580e:	854a                	mv	a0,s2
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	37e080e7          	jalr	894(ra) # 80003b8e <iunlockput>
  end_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	b56080e7          	jalr	-1194(ra) # 8000436e <end_op>
  return 0;
    80005820:	4501                	li	a0,0
    80005822:	a84d                	j	800058d4 <sys_unlink+0x1c4>
    end_op();
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	b4a080e7          	jalr	-1206(ra) # 8000436e <end_op>
    return -1;
    8000582c:	557d                	li	a0,-1
    8000582e:	a05d                	j	800058d4 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005830:	00003517          	auipc	a0,0x3
    80005834:	ec050513          	addi	a0,a0,-320 # 800086f0 <syscalls+0x2b0>
    80005838:	ffffb097          	auipc	ra,0xffffb
    8000583c:	d06080e7          	jalr	-762(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005840:	04c92703          	lw	a4,76(s2)
    80005844:	02000793          	li	a5,32
    80005848:	f6e7f9e3          	bgeu	a5,a4,800057ba <sys_unlink+0xaa>
    8000584c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005850:	4741                	li	a4,16
    80005852:	86ce                	mv	a3,s3
    80005854:	f1840613          	addi	a2,s0,-232
    80005858:	4581                	li	a1,0
    8000585a:	854a                	mv	a0,s2
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	384080e7          	jalr	900(ra) # 80003be0 <readi>
    80005864:	47c1                	li	a5,16
    80005866:	00f51b63          	bne	a0,a5,8000587c <sys_unlink+0x16c>
    if(de.inum != 0)
    8000586a:	f1845783          	lhu	a5,-232(s0)
    8000586e:	e7a1                	bnez	a5,800058b6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005870:	29c1                	addiw	s3,s3,16
    80005872:	04c92783          	lw	a5,76(s2)
    80005876:	fcf9ede3          	bltu	s3,a5,80005850 <sys_unlink+0x140>
    8000587a:	b781                	j	800057ba <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000587c:	00003517          	auipc	a0,0x3
    80005880:	e8c50513          	addi	a0,a0,-372 # 80008708 <syscalls+0x2c8>
    80005884:	ffffb097          	auipc	ra,0xffffb
    80005888:	cba080e7          	jalr	-838(ra) # 8000053e <panic>
    panic("unlink: writei");
    8000588c:	00003517          	auipc	a0,0x3
    80005890:	e9450513          	addi	a0,a0,-364 # 80008720 <syscalls+0x2e0>
    80005894:	ffffb097          	auipc	ra,0xffffb
    80005898:	caa080e7          	jalr	-854(ra) # 8000053e <panic>
    dp->nlink--;
    8000589c:	04a4d783          	lhu	a5,74(s1)
    800058a0:	37fd                	addiw	a5,a5,-1
    800058a2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058a6:	8526                	mv	a0,s1
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	fba080e7          	jalr	-70(ra) # 80003862 <iupdate>
    800058b0:	b781                	j	800057f0 <sys_unlink+0xe0>
    return -1;
    800058b2:	557d                	li	a0,-1
    800058b4:	a005                	j	800058d4 <sys_unlink+0x1c4>
    iunlockput(ip);
    800058b6:	854a                	mv	a0,s2
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	2d6080e7          	jalr	726(ra) # 80003b8e <iunlockput>
  iunlockput(dp);
    800058c0:	8526                	mv	a0,s1
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	2cc080e7          	jalr	716(ra) # 80003b8e <iunlockput>
  end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	aa4080e7          	jalr	-1372(ra) # 8000436e <end_op>
  return -1;
    800058d2:	557d                	li	a0,-1
}
    800058d4:	70ae                	ld	ra,232(sp)
    800058d6:	740e                	ld	s0,224(sp)
    800058d8:	64ee                	ld	s1,216(sp)
    800058da:	694e                	ld	s2,208(sp)
    800058dc:	69ae                	ld	s3,200(sp)
    800058de:	616d                	addi	sp,sp,240
    800058e0:	8082                	ret

00000000800058e2 <sys_open>:

uint64
sys_open(void)
{
    800058e2:	7131                	addi	sp,sp,-192
    800058e4:	fd06                	sd	ra,184(sp)
    800058e6:	f922                	sd	s0,176(sp)
    800058e8:	f526                	sd	s1,168(sp)
    800058ea:	f14a                	sd	s2,160(sp)
    800058ec:	ed4e                	sd	s3,152(sp)
    800058ee:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800058f0:	f4c40593          	addi	a1,s0,-180
    800058f4:	4505                	li	a0,1
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	4ba080e7          	jalr	1210(ra) # 80002db0 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058fe:	08000613          	li	a2,128
    80005902:	f5040593          	addi	a1,s0,-176
    80005906:	4501                	li	a0,0
    80005908:	ffffd097          	auipc	ra,0xffffd
    8000590c:	4e8080e7          	jalr	1256(ra) # 80002df0 <argstr>
    80005910:	87aa                	mv	a5,a0
    return -1;
    80005912:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005914:	0a07c963          	bltz	a5,800059c6 <sys_open+0xe4>

  begin_op();
    80005918:	fffff097          	auipc	ra,0xfffff
    8000591c:	9d6080e7          	jalr	-1578(ra) # 800042ee <begin_op>

  if(omode & O_CREATE){
    80005920:	f4c42783          	lw	a5,-180(s0)
    80005924:	2007f793          	andi	a5,a5,512
    80005928:	cfc5                	beqz	a5,800059e0 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000592a:	4681                	li	a3,0
    8000592c:	4601                	li	a2,0
    8000592e:	4589                	li	a1,2
    80005930:	f5040513          	addi	a0,s0,-176
    80005934:	00000097          	auipc	ra,0x0
    80005938:	974080e7          	jalr	-1676(ra) # 800052a8 <create>
    8000593c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000593e:	c959                	beqz	a0,800059d4 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005940:	04449703          	lh	a4,68(s1)
    80005944:	478d                	li	a5,3
    80005946:	00f71763          	bne	a4,a5,80005954 <sys_open+0x72>
    8000594a:	0464d703          	lhu	a4,70(s1)
    8000594e:	47a5                	li	a5,9
    80005950:	0ce7ed63          	bltu	a5,a4,80005a2a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	daa080e7          	jalr	-598(ra) # 800046fe <filealloc>
    8000595c:	89aa                	mv	s3,a0
    8000595e:	10050363          	beqz	a0,80005a64 <sys_open+0x182>
    80005962:	00000097          	auipc	ra,0x0
    80005966:	904080e7          	jalr	-1788(ra) # 80005266 <fdalloc>
    8000596a:	892a                	mv	s2,a0
    8000596c:	0e054763          	bltz	a0,80005a5a <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005970:	04449703          	lh	a4,68(s1)
    80005974:	478d                	li	a5,3
    80005976:	0cf70563          	beq	a4,a5,80005a40 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000597a:	4789                	li	a5,2
    8000597c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005980:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005984:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005988:	f4c42783          	lw	a5,-180(s0)
    8000598c:	0017c713          	xori	a4,a5,1
    80005990:	8b05                	andi	a4,a4,1
    80005992:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005996:	0037f713          	andi	a4,a5,3
    8000599a:	00e03733          	snez	a4,a4
    8000599e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059a2:	4007f793          	andi	a5,a5,1024
    800059a6:	c791                	beqz	a5,800059b2 <sys_open+0xd0>
    800059a8:	04449703          	lh	a4,68(s1)
    800059ac:	4789                	li	a5,2
    800059ae:	0af70063          	beq	a4,a5,80005a4e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800059b2:	8526                	mv	a0,s1
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	03a080e7          	jalr	58(ra) # 800039ee <iunlock>
  end_op();
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	9b2080e7          	jalr	-1614(ra) # 8000436e <end_op>

  return fd;
    800059c4:	854a                	mv	a0,s2
}
    800059c6:	70ea                	ld	ra,184(sp)
    800059c8:	744a                	ld	s0,176(sp)
    800059ca:	74aa                	ld	s1,168(sp)
    800059cc:	790a                	ld	s2,160(sp)
    800059ce:	69ea                	ld	s3,152(sp)
    800059d0:	6129                	addi	sp,sp,192
    800059d2:	8082                	ret
      end_op();
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	99a080e7          	jalr	-1638(ra) # 8000436e <end_op>
      return -1;
    800059dc:	557d                	li	a0,-1
    800059de:	b7e5                	j	800059c6 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059e0:	f5040513          	addi	a0,s0,-176
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	6ee080e7          	jalr	1774(ra) # 800040d2 <namei>
    800059ec:	84aa                	mv	s1,a0
    800059ee:	c905                	beqz	a0,80005a1e <sys_open+0x13c>
    ilock(ip);
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	f3c080e7          	jalr	-196(ra) # 8000392c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059f8:	04449703          	lh	a4,68(s1)
    800059fc:	4785                	li	a5,1
    800059fe:	f4f711e3          	bne	a4,a5,80005940 <sys_open+0x5e>
    80005a02:	f4c42783          	lw	a5,-180(s0)
    80005a06:	d7b9                	beqz	a5,80005954 <sys_open+0x72>
      iunlockput(ip);
    80005a08:	8526                	mv	a0,s1
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	184080e7          	jalr	388(ra) # 80003b8e <iunlockput>
      end_op();
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	95c080e7          	jalr	-1700(ra) # 8000436e <end_op>
      return -1;
    80005a1a:	557d                	li	a0,-1
    80005a1c:	b76d                	j	800059c6 <sys_open+0xe4>
      end_op();
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	950080e7          	jalr	-1712(ra) # 8000436e <end_op>
      return -1;
    80005a26:	557d                	li	a0,-1
    80005a28:	bf79                	j	800059c6 <sys_open+0xe4>
    iunlockput(ip);
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	162080e7          	jalr	354(ra) # 80003b8e <iunlockput>
    end_op();
    80005a34:	fffff097          	auipc	ra,0xfffff
    80005a38:	93a080e7          	jalr	-1734(ra) # 8000436e <end_op>
    return -1;
    80005a3c:	557d                	li	a0,-1
    80005a3e:	b761                	j	800059c6 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a40:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a44:	04649783          	lh	a5,70(s1)
    80005a48:	02f99223          	sh	a5,36(s3)
    80005a4c:	bf25                	j	80005984 <sys_open+0xa2>
    itrunc(ip);
    80005a4e:	8526                	mv	a0,s1
    80005a50:	ffffe097          	auipc	ra,0xffffe
    80005a54:	fea080e7          	jalr	-22(ra) # 80003a3a <itrunc>
    80005a58:	bfa9                	j	800059b2 <sys_open+0xd0>
      fileclose(f);
    80005a5a:	854e                	mv	a0,s3
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	d5e080e7          	jalr	-674(ra) # 800047ba <fileclose>
    iunlockput(ip);
    80005a64:	8526                	mv	a0,s1
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	128080e7          	jalr	296(ra) # 80003b8e <iunlockput>
    end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	900080e7          	jalr	-1792(ra) # 8000436e <end_op>
    return -1;
    80005a76:	557d                	li	a0,-1
    80005a78:	b7b9                	j	800059c6 <sys_open+0xe4>

0000000080005a7a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a7a:	7175                	addi	sp,sp,-144
    80005a7c:	e506                	sd	ra,136(sp)
    80005a7e:	e122                	sd	s0,128(sp)
    80005a80:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a82:	fffff097          	auipc	ra,0xfffff
    80005a86:	86c080e7          	jalr	-1940(ra) # 800042ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a8a:	08000613          	li	a2,128
    80005a8e:	f7040593          	addi	a1,s0,-144
    80005a92:	4501                	li	a0,0
    80005a94:	ffffd097          	auipc	ra,0xffffd
    80005a98:	35c080e7          	jalr	860(ra) # 80002df0 <argstr>
    80005a9c:	02054963          	bltz	a0,80005ace <sys_mkdir+0x54>
    80005aa0:	4681                	li	a3,0
    80005aa2:	4601                	li	a2,0
    80005aa4:	4585                	li	a1,1
    80005aa6:	f7040513          	addi	a0,s0,-144
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	7fe080e7          	jalr	2046(ra) # 800052a8 <create>
    80005ab2:	cd11                	beqz	a0,80005ace <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	0da080e7          	jalr	218(ra) # 80003b8e <iunlockput>
  end_op();
    80005abc:	fffff097          	auipc	ra,0xfffff
    80005ac0:	8b2080e7          	jalr	-1870(ra) # 8000436e <end_op>
  return 0;
    80005ac4:	4501                	li	a0,0
}
    80005ac6:	60aa                	ld	ra,136(sp)
    80005ac8:	640a                	ld	s0,128(sp)
    80005aca:	6149                	addi	sp,sp,144
    80005acc:	8082                	ret
    end_op();
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	8a0080e7          	jalr	-1888(ra) # 8000436e <end_op>
    return -1;
    80005ad6:	557d                	li	a0,-1
    80005ad8:	b7fd                	j	80005ac6 <sys_mkdir+0x4c>

0000000080005ada <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ada:	7135                	addi	sp,sp,-160
    80005adc:	ed06                	sd	ra,152(sp)
    80005ade:	e922                	sd	s0,144(sp)
    80005ae0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ae2:	fffff097          	auipc	ra,0xfffff
    80005ae6:	80c080e7          	jalr	-2036(ra) # 800042ee <begin_op>
  argint(1, &major);
    80005aea:	f6c40593          	addi	a1,s0,-148
    80005aee:	4505                	li	a0,1
    80005af0:	ffffd097          	auipc	ra,0xffffd
    80005af4:	2c0080e7          	jalr	704(ra) # 80002db0 <argint>
  argint(2, &minor);
    80005af8:	f6840593          	addi	a1,s0,-152
    80005afc:	4509                	li	a0,2
    80005afe:	ffffd097          	auipc	ra,0xffffd
    80005b02:	2b2080e7          	jalr	690(ra) # 80002db0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b06:	08000613          	li	a2,128
    80005b0a:	f7040593          	addi	a1,s0,-144
    80005b0e:	4501                	li	a0,0
    80005b10:	ffffd097          	auipc	ra,0xffffd
    80005b14:	2e0080e7          	jalr	736(ra) # 80002df0 <argstr>
    80005b18:	02054b63          	bltz	a0,80005b4e <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b1c:	f6841683          	lh	a3,-152(s0)
    80005b20:	f6c41603          	lh	a2,-148(s0)
    80005b24:	458d                	li	a1,3
    80005b26:	f7040513          	addi	a0,s0,-144
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	77e080e7          	jalr	1918(ra) # 800052a8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b32:	cd11                	beqz	a0,80005b4e <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b34:	ffffe097          	auipc	ra,0xffffe
    80005b38:	05a080e7          	jalr	90(ra) # 80003b8e <iunlockput>
  end_op();
    80005b3c:	fffff097          	auipc	ra,0xfffff
    80005b40:	832080e7          	jalr	-1998(ra) # 8000436e <end_op>
  return 0;
    80005b44:	4501                	li	a0,0
}
    80005b46:	60ea                	ld	ra,152(sp)
    80005b48:	644a                	ld	s0,144(sp)
    80005b4a:	610d                	addi	sp,sp,160
    80005b4c:	8082                	ret
    end_op();
    80005b4e:	fffff097          	auipc	ra,0xfffff
    80005b52:	820080e7          	jalr	-2016(ra) # 8000436e <end_op>
    return -1;
    80005b56:	557d                	li	a0,-1
    80005b58:	b7fd                	j	80005b46 <sys_mknod+0x6c>

0000000080005b5a <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b5a:	7135                	addi	sp,sp,-160
    80005b5c:	ed06                	sd	ra,152(sp)
    80005b5e:	e922                	sd	s0,144(sp)
    80005b60:	e526                	sd	s1,136(sp)
    80005b62:	e14a                	sd	s2,128(sp)
    80005b64:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b66:	ffffc097          	auipc	ra,0xffffc
    80005b6a:	e1a080e7          	jalr	-486(ra) # 80001980 <myproc>
    80005b6e:	892a                	mv	s2,a0
  
  begin_op();
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	77e080e7          	jalr	1918(ra) # 800042ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b78:	08000613          	li	a2,128
    80005b7c:	f6040593          	addi	a1,s0,-160
    80005b80:	4501                	li	a0,0
    80005b82:	ffffd097          	auipc	ra,0xffffd
    80005b86:	26e080e7          	jalr	622(ra) # 80002df0 <argstr>
    80005b8a:	04054b63          	bltz	a0,80005be0 <sys_chdir+0x86>
    80005b8e:	f6040513          	addi	a0,s0,-160
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	540080e7          	jalr	1344(ra) # 800040d2 <namei>
    80005b9a:	84aa                	mv	s1,a0
    80005b9c:	c131                	beqz	a0,80005be0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b9e:	ffffe097          	auipc	ra,0xffffe
    80005ba2:	d8e080e7          	jalr	-626(ra) # 8000392c <ilock>
  if(ip->type != T_DIR){
    80005ba6:	04449703          	lh	a4,68(s1)
    80005baa:	4785                	li	a5,1
    80005bac:	04f71063          	bne	a4,a5,80005bec <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bb0:	8526                	mv	a0,s1
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	e3c080e7          	jalr	-452(ra) # 800039ee <iunlock>
  iput(p->cwd);
    80005bba:	18893503          	ld	a0,392(s2)
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	f28080e7          	jalr	-216(ra) # 80003ae6 <iput>
  end_op();
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	7a8080e7          	jalr	1960(ra) # 8000436e <end_op>
  p->cwd = ip;
    80005bce:	18993423          	sd	s1,392(s2)
  return 0;
    80005bd2:	4501                	li	a0,0
}
    80005bd4:	60ea                	ld	ra,152(sp)
    80005bd6:	644a                	ld	s0,144(sp)
    80005bd8:	64aa                	ld	s1,136(sp)
    80005bda:	690a                	ld	s2,128(sp)
    80005bdc:	610d                	addi	sp,sp,160
    80005bde:	8082                	ret
    end_op();
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	78e080e7          	jalr	1934(ra) # 8000436e <end_op>
    return -1;
    80005be8:	557d                	li	a0,-1
    80005bea:	b7ed                	j	80005bd4 <sys_chdir+0x7a>
    iunlockput(ip);
    80005bec:	8526                	mv	a0,s1
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	fa0080e7          	jalr	-96(ra) # 80003b8e <iunlockput>
    end_op();
    80005bf6:	ffffe097          	auipc	ra,0xffffe
    80005bfa:	778080e7          	jalr	1912(ra) # 8000436e <end_op>
    return -1;
    80005bfe:	557d                	li	a0,-1
    80005c00:	bfd1                	j	80005bd4 <sys_chdir+0x7a>

0000000080005c02 <sys_exec>:

uint64
sys_exec(void)
{
    80005c02:	7145                	addi	sp,sp,-464
    80005c04:	e786                	sd	ra,456(sp)
    80005c06:	e3a2                	sd	s0,448(sp)
    80005c08:	ff26                	sd	s1,440(sp)
    80005c0a:	fb4a                	sd	s2,432(sp)
    80005c0c:	f74e                	sd	s3,424(sp)
    80005c0e:	f352                	sd	s4,416(sp)
    80005c10:	ef56                	sd	s5,408(sp)
    80005c12:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c14:	e3840593          	addi	a1,s0,-456
    80005c18:	4505                	li	a0,1
    80005c1a:	ffffd097          	auipc	ra,0xffffd
    80005c1e:	1b6080e7          	jalr	438(ra) # 80002dd0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c22:	08000613          	li	a2,128
    80005c26:	f4040593          	addi	a1,s0,-192
    80005c2a:	4501                	li	a0,0
    80005c2c:	ffffd097          	auipc	ra,0xffffd
    80005c30:	1c4080e7          	jalr	452(ra) # 80002df0 <argstr>
    80005c34:	87aa                	mv	a5,a0
    return -1;
    80005c36:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c38:	0c07c263          	bltz	a5,80005cfc <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c3c:	10000613          	li	a2,256
    80005c40:	4581                	li	a1,0
    80005c42:	e4040513          	addi	a0,s0,-448
    80005c46:	ffffb097          	auipc	ra,0xffffb
    80005c4a:	08c080e7          	jalr	140(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c4e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c52:	89a6                	mv	s3,s1
    80005c54:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c56:	02000a13          	li	s4,32
    80005c5a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c5e:	00391793          	slli	a5,s2,0x3
    80005c62:	e3040593          	addi	a1,s0,-464
    80005c66:	e3843503          	ld	a0,-456(s0)
    80005c6a:	953e                	add	a0,a0,a5
    80005c6c:	ffffd097          	auipc	ra,0xffffd
    80005c70:	0a2080e7          	jalr	162(ra) # 80002d0e <fetchaddr>
    80005c74:	02054a63          	bltz	a0,80005ca8 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c78:	e3043783          	ld	a5,-464(s0)
    80005c7c:	c3b9                	beqz	a5,80005cc2 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c7e:	ffffb097          	auipc	ra,0xffffb
    80005c82:	e68080e7          	jalr	-408(ra) # 80000ae6 <kalloc>
    80005c86:	85aa                	mv	a1,a0
    80005c88:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c8c:	cd11                	beqz	a0,80005ca8 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c8e:	6605                	lui	a2,0x1
    80005c90:	e3043503          	ld	a0,-464(s0)
    80005c94:	ffffd097          	auipc	ra,0xffffd
    80005c98:	0ce080e7          	jalr	206(ra) # 80002d62 <fetchstr>
    80005c9c:	00054663          	bltz	a0,80005ca8 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005ca0:	0905                	addi	s2,s2,1
    80005ca2:	09a1                	addi	s3,s3,8
    80005ca4:	fb491be3          	bne	s2,s4,80005c5a <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ca8:	10048913          	addi	s2,s1,256
    80005cac:	6088                	ld	a0,0(s1)
    80005cae:	c531                	beqz	a0,80005cfa <sys_exec+0xf8>
    kfree(argv[i]);
    80005cb0:	ffffb097          	auipc	ra,0xffffb
    80005cb4:	d3a080e7          	jalr	-710(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cb8:	04a1                	addi	s1,s1,8
    80005cba:	ff2499e3          	bne	s1,s2,80005cac <sys_exec+0xaa>
  return -1;
    80005cbe:	557d                	li	a0,-1
    80005cc0:	a835                	j	80005cfc <sys_exec+0xfa>
      argv[i] = 0;
    80005cc2:	0a8e                	slli	s5,s5,0x3
    80005cc4:	fc040793          	addi	a5,s0,-64
    80005cc8:	9abe                	add	s5,s5,a5
    80005cca:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005cce:	e4040593          	addi	a1,s0,-448
    80005cd2:	f4040513          	addi	a0,s0,-192
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	15e080e7          	jalr	350(ra) # 80004e34 <exec>
    80005cde:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ce0:	10048993          	addi	s3,s1,256
    80005ce4:	6088                	ld	a0,0(s1)
    80005ce6:	c901                	beqz	a0,80005cf6 <sys_exec+0xf4>
    kfree(argv[i]);
    80005ce8:	ffffb097          	auipc	ra,0xffffb
    80005cec:	d02080e7          	jalr	-766(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cf0:	04a1                	addi	s1,s1,8
    80005cf2:	ff3499e3          	bne	s1,s3,80005ce4 <sys_exec+0xe2>
  return ret;
    80005cf6:	854a                	mv	a0,s2
    80005cf8:	a011                	j	80005cfc <sys_exec+0xfa>
  return -1;
    80005cfa:	557d                	li	a0,-1
}
    80005cfc:	60be                	ld	ra,456(sp)
    80005cfe:	641e                	ld	s0,448(sp)
    80005d00:	74fa                	ld	s1,440(sp)
    80005d02:	795a                	ld	s2,432(sp)
    80005d04:	79ba                	ld	s3,424(sp)
    80005d06:	7a1a                	ld	s4,416(sp)
    80005d08:	6afa                	ld	s5,408(sp)
    80005d0a:	6179                	addi	sp,sp,464
    80005d0c:	8082                	ret

0000000080005d0e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d0e:	7139                	addi	sp,sp,-64
    80005d10:	fc06                	sd	ra,56(sp)
    80005d12:	f822                	sd	s0,48(sp)
    80005d14:	f426                	sd	s1,40(sp)
    80005d16:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d18:	ffffc097          	auipc	ra,0xffffc
    80005d1c:	c68080e7          	jalr	-920(ra) # 80001980 <myproc>
    80005d20:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d22:	fd840593          	addi	a1,s0,-40
    80005d26:	4501                	li	a0,0
    80005d28:	ffffd097          	auipc	ra,0xffffd
    80005d2c:	0a8080e7          	jalr	168(ra) # 80002dd0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d30:	fc840593          	addi	a1,s0,-56
    80005d34:	fd040513          	addi	a0,s0,-48
    80005d38:	fffff097          	auipc	ra,0xfffff
    80005d3c:	db2080e7          	jalr	-590(ra) # 80004aea <pipealloc>
    return -1;
    80005d40:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d42:	0c054963          	bltz	a0,80005e14 <sys_pipe+0x106>
  fd0 = -1;
    80005d46:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d4a:	fd043503          	ld	a0,-48(s0)
    80005d4e:	fffff097          	auipc	ra,0xfffff
    80005d52:	518080e7          	jalr	1304(ra) # 80005266 <fdalloc>
    80005d56:	fca42223          	sw	a0,-60(s0)
    80005d5a:	0a054063          	bltz	a0,80005dfa <sys_pipe+0xec>
    80005d5e:	fc843503          	ld	a0,-56(s0)
    80005d62:	fffff097          	auipc	ra,0xfffff
    80005d66:	504080e7          	jalr	1284(ra) # 80005266 <fdalloc>
    80005d6a:	fca42023          	sw	a0,-64(s0)
    80005d6e:	06054c63          	bltz	a0,80005de6 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d72:	4691                	li	a3,4
    80005d74:	fc440613          	addi	a2,s0,-60
    80005d78:	fd843583          	ld	a1,-40(s0)
    80005d7c:	1004b503          	ld	a0,256(s1)
    80005d80:	ffffc097          	auipc	ra,0xffffc
    80005d84:	8e8080e7          	jalr	-1816(ra) # 80001668 <copyout>
    80005d88:	02054163          	bltz	a0,80005daa <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d8c:	4691                	li	a3,4
    80005d8e:	fc040613          	addi	a2,s0,-64
    80005d92:	fd843583          	ld	a1,-40(s0)
    80005d96:	0591                	addi	a1,a1,4
    80005d98:	1004b503          	ld	a0,256(s1)
    80005d9c:	ffffc097          	auipc	ra,0xffffc
    80005da0:	8cc080e7          	jalr	-1844(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005da4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005da6:	06055763          	bgez	a0,80005e14 <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80005daa:	fc442783          	lw	a5,-60(s0)
    80005dae:	02078793          	addi	a5,a5,32
    80005db2:	078e                	slli	a5,a5,0x3
    80005db4:	97a6                	add	a5,a5,s1
    80005db6:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005dba:	fc042503          	lw	a0,-64(s0)
    80005dbe:	02050513          	addi	a0,a0,32
    80005dc2:	050e                	slli	a0,a0,0x3
    80005dc4:	94aa                	add	s1,s1,a0
    80005dc6:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005dca:	fd043503          	ld	a0,-48(s0)
    80005dce:	fffff097          	auipc	ra,0xfffff
    80005dd2:	9ec080e7          	jalr	-1556(ra) # 800047ba <fileclose>
    fileclose(wf);
    80005dd6:	fc843503          	ld	a0,-56(s0)
    80005dda:	fffff097          	auipc	ra,0xfffff
    80005dde:	9e0080e7          	jalr	-1568(ra) # 800047ba <fileclose>
    return -1;
    80005de2:	57fd                	li	a5,-1
    80005de4:	a805                	j	80005e14 <sys_pipe+0x106>
    if(fd0 >= 0)
    80005de6:	fc442783          	lw	a5,-60(s0)
    80005dea:	0007c863          	bltz	a5,80005dfa <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80005dee:	02078793          	addi	a5,a5,32
    80005df2:	078e                	slli	a5,a5,0x3
    80005df4:	94be                	add	s1,s1,a5
    80005df6:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005dfa:	fd043503          	ld	a0,-48(s0)
    80005dfe:	fffff097          	auipc	ra,0xfffff
    80005e02:	9bc080e7          	jalr	-1604(ra) # 800047ba <fileclose>
    fileclose(wf);
    80005e06:	fc843503          	ld	a0,-56(s0)
    80005e0a:	fffff097          	auipc	ra,0xfffff
    80005e0e:	9b0080e7          	jalr	-1616(ra) # 800047ba <fileclose>
    return -1;
    80005e12:	57fd                	li	a5,-1
}
    80005e14:	853e                	mv	a0,a5
    80005e16:	70e2                	ld	ra,56(sp)
    80005e18:	7442                	ld	s0,48(sp)
    80005e1a:	74a2                	ld	s1,40(sp)
    80005e1c:	6121                	addi	sp,sp,64
    80005e1e:	8082                	ret

0000000080005e20 <kernelvec>:
    80005e20:	7111                	addi	sp,sp,-256
    80005e22:	e006                	sd	ra,0(sp)
    80005e24:	e40a                	sd	sp,8(sp)
    80005e26:	e80e                	sd	gp,16(sp)
    80005e28:	ec12                	sd	tp,24(sp)
    80005e2a:	f016                	sd	t0,32(sp)
    80005e2c:	f41a                	sd	t1,40(sp)
    80005e2e:	f81e                	sd	t2,48(sp)
    80005e30:	fc22                	sd	s0,56(sp)
    80005e32:	e0a6                	sd	s1,64(sp)
    80005e34:	e4aa                	sd	a0,72(sp)
    80005e36:	e8ae                	sd	a1,80(sp)
    80005e38:	ecb2                	sd	a2,88(sp)
    80005e3a:	f0b6                	sd	a3,96(sp)
    80005e3c:	f4ba                	sd	a4,104(sp)
    80005e3e:	f8be                	sd	a5,112(sp)
    80005e40:	fcc2                	sd	a6,120(sp)
    80005e42:	e146                	sd	a7,128(sp)
    80005e44:	e54a                	sd	s2,136(sp)
    80005e46:	e94e                	sd	s3,144(sp)
    80005e48:	ed52                	sd	s4,152(sp)
    80005e4a:	f156                	sd	s5,160(sp)
    80005e4c:	f55a                	sd	s6,168(sp)
    80005e4e:	f95e                	sd	s7,176(sp)
    80005e50:	fd62                	sd	s8,184(sp)
    80005e52:	e1e6                	sd	s9,192(sp)
    80005e54:	e5ea                	sd	s10,200(sp)
    80005e56:	e9ee                	sd	s11,208(sp)
    80005e58:	edf2                	sd	t3,216(sp)
    80005e5a:	f1f6                	sd	t4,224(sp)
    80005e5c:	f5fa                	sd	t5,232(sp)
    80005e5e:	f9fe                	sd	t6,240(sp)
    80005e60:	d7bfc0ef          	jal	ra,80002bda <kerneltrap>
    80005e64:	6082                	ld	ra,0(sp)
    80005e66:	6122                	ld	sp,8(sp)
    80005e68:	61c2                	ld	gp,16(sp)
    80005e6a:	7282                	ld	t0,32(sp)
    80005e6c:	7322                	ld	t1,40(sp)
    80005e6e:	73c2                	ld	t2,48(sp)
    80005e70:	7462                	ld	s0,56(sp)
    80005e72:	6486                	ld	s1,64(sp)
    80005e74:	6526                	ld	a0,72(sp)
    80005e76:	65c6                	ld	a1,80(sp)
    80005e78:	6666                	ld	a2,88(sp)
    80005e7a:	7686                	ld	a3,96(sp)
    80005e7c:	7726                	ld	a4,104(sp)
    80005e7e:	77c6                	ld	a5,112(sp)
    80005e80:	7866                	ld	a6,120(sp)
    80005e82:	688a                	ld	a7,128(sp)
    80005e84:	692a                	ld	s2,136(sp)
    80005e86:	69ca                	ld	s3,144(sp)
    80005e88:	6a6a                	ld	s4,152(sp)
    80005e8a:	7a8a                	ld	s5,160(sp)
    80005e8c:	7b2a                	ld	s6,168(sp)
    80005e8e:	7bca                	ld	s7,176(sp)
    80005e90:	7c6a                	ld	s8,184(sp)
    80005e92:	6c8e                	ld	s9,192(sp)
    80005e94:	6d2e                	ld	s10,200(sp)
    80005e96:	6dce                	ld	s11,208(sp)
    80005e98:	6e6e                	ld	t3,216(sp)
    80005e9a:	7e8e                	ld	t4,224(sp)
    80005e9c:	7f2e                	ld	t5,232(sp)
    80005e9e:	7fce                	ld	t6,240(sp)
    80005ea0:	6111                	addi	sp,sp,256
    80005ea2:	10200073          	sret
    80005ea6:	00000013          	nop
    80005eaa:	00000013          	nop
    80005eae:	0001                	nop

0000000080005eb0 <timervec>:
    80005eb0:	34051573          	csrrw	a0,mscratch,a0
    80005eb4:	e10c                	sd	a1,0(a0)
    80005eb6:	e510                	sd	a2,8(a0)
    80005eb8:	e914                	sd	a3,16(a0)
    80005eba:	6d0c                	ld	a1,24(a0)
    80005ebc:	7110                	ld	a2,32(a0)
    80005ebe:	6194                	ld	a3,0(a1)
    80005ec0:	96b2                	add	a3,a3,a2
    80005ec2:	e194                	sd	a3,0(a1)
    80005ec4:	4589                	li	a1,2
    80005ec6:	14459073          	csrw	sip,a1
    80005eca:	6914                	ld	a3,16(a0)
    80005ecc:	6510                	ld	a2,8(a0)
    80005ece:	610c                	ld	a1,0(a0)
    80005ed0:	34051573          	csrrw	a0,mscratch,a0
    80005ed4:	30200073          	mret
	...

0000000080005eda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eda:	1141                	addi	sp,sp,-16
    80005edc:	e422                	sd	s0,8(sp)
    80005ede:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ee0:	0c0007b7          	lui	a5,0xc000
    80005ee4:	4705                	li	a4,1
    80005ee6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ee8:	c3d8                	sw	a4,4(a5)
}
    80005eea:	6422                	ld	s0,8(sp)
    80005eec:	0141                	addi	sp,sp,16
    80005eee:	8082                	ret

0000000080005ef0 <plicinithart>:

void
plicinithart(void)
{
    80005ef0:	1141                	addi	sp,sp,-16
    80005ef2:	e406                	sd	ra,8(sp)
    80005ef4:	e022                	sd	s0,0(sp)
    80005ef6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ef8:	ffffc097          	auipc	ra,0xffffc
    80005efc:	a5c080e7          	jalr	-1444(ra) # 80001954 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f00:	0085171b          	slliw	a4,a0,0x8
    80005f04:	0c0027b7          	lui	a5,0xc002
    80005f08:	97ba                	add	a5,a5,a4
    80005f0a:	40200713          	li	a4,1026
    80005f0e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f12:	00d5151b          	slliw	a0,a0,0xd
    80005f16:	0c2017b7          	lui	a5,0xc201
    80005f1a:	953e                	add	a0,a0,a5
    80005f1c:	00052023          	sw	zero,0(a0)
}
    80005f20:	60a2                	ld	ra,8(sp)
    80005f22:	6402                	ld	s0,0(sp)
    80005f24:	0141                	addi	sp,sp,16
    80005f26:	8082                	ret

0000000080005f28 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f28:	1141                	addi	sp,sp,-16
    80005f2a:	e406                	sd	ra,8(sp)
    80005f2c:	e022                	sd	s0,0(sp)
    80005f2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f30:	ffffc097          	auipc	ra,0xffffc
    80005f34:	a24080e7          	jalr	-1500(ra) # 80001954 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f38:	00d5179b          	slliw	a5,a0,0xd
    80005f3c:	0c201537          	lui	a0,0xc201
    80005f40:	953e                	add	a0,a0,a5
  return irq;
}
    80005f42:	4148                	lw	a0,4(a0)
    80005f44:	60a2                	ld	ra,8(sp)
    80005f46:	6402                	ld	s0,0(sp)
    80005f48:	0141                	addi	sp,sp,16
    80005f4a:	8082                	ret

0000000080005f4c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f4c:	1101                	addi	sp,sp,-32
    80005f4e:	ec06                	sd	ra,24(sp)
    80005f50:	e822                	sd	s0,16(sp)
    80005f52:	e426                	sd	s1,8(sp)
    80005f54:	1000                	addi	s0,sp,32
    80005f56:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f58:	ffffc097          	auipc	ra,0xffffc
    80005f5c:	9fc080e7          	jalr	-1540(ra) # 80001954 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f60:	00d5151b          	slliw	a0,a0,0xd
    80005f64:	0c2017b7          	lui	a5,0xc201
    80005f68:	97aa                	add	a5,a5,a0
    80005f6a:	c3c4                	sw	s1,4(a5)
}
    80005f6c:	60e2                	ld	ra,24(sp)
    80005f6e:	6442                	ld	s0,16(sp)
    80005f70:	64a2                	ld	s1,8(sp)
    80005f72:	6105                	addi	sp,sp,32
    80005f74:	8082                	ret

0000000080005f76 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f76:	1141                	addi	sp,sp,-16
    80005f78:	e406                	sd	ra,8(sp)
    80005f7a:	e022                	sd	s0,0(sp)
    80005f7c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f7e:	479d                	li	a5,7
    80005f80:	04a7cc63          	blt	a5,a0,80005fd8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f84:	0001d797          	auipc	a5,0x1d
    80005f88:	28c78793          	addi	a5,a5,652 # 80023210 <disk>
    80005f8c:	97aa                	add	a5,a5,a0
    80005f8e:	0187c783          	lbu	a5,24(a5)
    80005f92:	ebb9                	bnez	a5,80005fe8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f94:	00451613          	slli	a2,a0,0x4
    80005f98:	0001d797          	auipc	a5,0x1d
    80005f9c:	27878793          	addi	a5,a5,632 # 80023210 <disk>
    80005fa0:	6394                	ld	a3,0(a5)
    80005fa2:	96b2                	add	a3,a3,a2
    80005fa4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005fa8:	6398                	ld	a4,0(a5)
    80005faa:	9732                	add	a4,a4,a2
    80005fac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005fb0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005fb4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005fb8:	953e                	add	a0,a0,a5
    80005fba:	4785                	li	a5,1
    80005fbc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005fc0:	0001d517          	auipc	a0,0x1d
    80005fc4:	26850513          	addi	a0,a0,616 # 80023228 <disk+0x18>
    80005fc8:	ffffc097          	auipc	ra,0xffffc
    80005fcc:	158080e7          	jalr	344(ra) # 80002120 <wakeup>
}
    80005fd0:	60a2                	ld	ra,8(sp)
    80005fd2:	6402                	ld	s0,0(sp)
    80005fd4:	0141                	addi	sp,sp,16
    80005fd6:	8082                	ret
    panic("free_desc 1");
    80005fd8:	00002517          	auipc	a0,0x2
    80005fdc:	75850513          	addi	a0,a0,1880 # 80008730 <syscalls+0x2f0>
    80005fe0:	ffffa097          	auipc	ra,0xffffa
    80005fe4:	55e080e7          	jalr	1374(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005fe8:	00002517          	auipc	a0,0x2
    80005fec:	75850513          	addi	a0,a0,1880 # 80008740 <syscalls+0x300>
    80005ff0:	ffffa097          	auipc	ra,0xffffa
    80005ff4:	54e080e7          	jalr	1358(ra) # 8000053e <panic>

0000000080005ff8 <virtio_disk_init>:
{
    80005ff8:	1101                	addi	sp,sp,-32
    80005ffa:	ec06                	sd	ra,24(sp)
    80005ffc:	e822                	sd	s0,16(sp)
    80005ffe:	e426                	sd	s1,8(sp)
    80006000:	e04a                	sd	s2,0(sp)
    80006002:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006004:	00002597          	auipc	a1,0x2
    80006008:	74c58593          	addi	a1,a1,1868 # 80008750 <syscalls+0x310>
    8000600c:	0001d517          	auipc	a0,0x1d
    80006010:	32c50513          	addi	a0,a0,812 # 80023338 <disk+0x128>
    80006014:	ffffb097          	auipc	ra,0xffffb
    80006018:	b32080e7          	jalr	-1230(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000601c:	100017b7          	lui	a5,0x10001
    80006020:	4398                	lw	a4,0(a5)
    80006022:	2701                	sext.w	a4,a4
    80006024:	747277b7          	lui	a5,0x74727
    80006028:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000602c:	14f71c63          	bne	a4,a5,80006184 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006030:	100017b7          	lui	a5,0x10001
    80006034:	43dc                	lw	a5,4(a5)
    80006036:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006038:	4709                	li	a4,2
    8000603a:	14e79563          	bne	a5,a4,80006184 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000603e:	100017b7          	lui	a5,0x10001
    80006042:	479c                	lw	a5,8(a5)
    80006044:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006046:	12e79f63          	bne	a5,a4,80006184 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000604a:	100017b7          	lui	a5,0x10001
    8000604e:	47d8                	lw	a4,12(a5)
    80006050:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006052:	554d47b7          	lui	a5,0x554d4
    80006056:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000605a:	12f71563          	bne	a4,a5,80006184 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000605e:	100017b7          	lui	a5,0x10001
    80006062:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006066:	4705                	li	a4,1
    80006068:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000606a:	470d                	li	a4,3
    8000606c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000606e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006070:	c7ffe737          	lui	a4,0xc7ffe
    80006074:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb40f>
    80006078:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000607a:	2701                	sext.w	a4,a4
    8000607c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000607e:	472d                	li	a4,11
    80006080:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006082:	5bbc                	lw	a5,112(a5)
    80006084:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006088:	8ba1                	andi	a5,a5,8
    8000608a:	10078563          	beqz	a5,80006194 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000608e:	100017b7          	lui	a5,0x10001
    80006092:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006096:	43fc                	lw	a5,68(a5)
    80006098:	2781                	sext.w	a5,a5
    8000609a:	10079563          	bnez	a5,800061a4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000609e:	100017b7          	lui	a5,0x10001
    800060a2:	5bdc                	lw	a5,52(a5)
    800060a4:	2781                	sext.w	a5,a5
  if(max == 0)
    800060a6:	10078763          	beqz	a5,800061b4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800060aa:	471d                	li	a4,7
    800060ac:	10f77c63          	bgeu	a4,a5,800061c4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800060b0:	ffffb097          	auipc	ra,0xffffb
    800060b4:	a36080e7          	jalr	-1482(ra) # 80000ae6 <kalloc>
    800060b8:	0001d497          	auipc	s1,0x1d
    800060bc:	15848493          	addi	s1,s1,344 # 80023210 <disk>
    800060c0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060c2:	ffffb097          	auipc	ra,0xffffb
    800060c6:	a24080e7          	jalr	-1500(ra) # 80000ae6 <kalloc>
    800060ca:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060cc:	ffffb097          	auipc	ra,0xffffb
    800060d0:	a1a080e7          	jalr	-1510(ra) # 80000ae6 <kalloc>
    800060d4:	87aa                	mv	a5,a0
    800060d6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060d8:	6088                	ld	a0,0(s1)
    800060da:	cd6d                	beqz	a0,800061d4 <virtio_disk_init+0x1dc>
    800060dc:	0001d717          	auipc	a4,0x1d
    800060e0:	13c73703          	ld	a4,316(a4) # 80023218 <disk+0x8>
    800060e4:	cb65                	beqz	a4,800061d4 <virtio_disk_init+0x1dc>
    800060e6:	c7fd                	beqz	a5,800061d4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800060e8:	6605                	lui	a2,0x1
    800060ea:	4581                	li	a1,0
    800060ec:	ffffb097          	auipc	ra,0xffffb
    800060f0:	be6080e7          	jalr	-1050(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060f4:	0001d497          	auipc	s1,0x1d
    800060f8:	11c48493          	addi	s1,s1,284 # 80023210 <disk>
    800060fc:	6605                	lui	a2,0x1
    800060fe:	4581                	li	a1,0
    80006100:	6488                	ld	a0,8(s1)
    80006102:	ffffb097          	auipc	ra,0xffffb
    80006106:	bd0080e7          	jalr	-1072(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000610a:	6605                	lui	a2,0x1
    8000610c:	4581                	li	a1,0
    8000610e:	6888                	ld	a0,16(s1)
    80006110:	ffffb097          	auipc	ra,0xffffb
    80006114:	bc2080e7          	jalr	-1086(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006118:	100017b7          	lui	a5,0x10001
    8000611c:	4721                	li	a4,8
    8000611e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006120:	4098                	lw	a4,0(s1)
    80006122:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006126:	40d8                	lw	a4,4(s1)
    80006128:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000612c:	6498                	ld	a4,8(s1)
    8000612e:	0007069b          	sext.w	a3,a4
    80006132:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006136:	9701                	srai	a4,a4,0x20
    80006138:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000613c:	6898                	ld	a4,16(s1)
    8000613e:	0007069b          	sext.w	a3,a4
    80006142:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006146:	9701                	srai	a4,a4,0x20
    80006148:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000614c:	4705                	li	a4,1
    8000614e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006150:	00e48c23          	sb	a4,24(s1)
    80006154:	00e48ca3          	sb	a4,25(s1)
    80006158:	00e48d23          	sb	a4,26(s1)
    8000615c:	00e48da3          	sb	a4,27(s1)
    80006160:	00e48e23          	sb	a4,28(s1)
    80006164:	00e48ea3          	sb	a4,29(s1)
    80006168:	00e48f23          	sb	a4,30(s1)
    8000616c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006170:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006174:	0727a823          	sw	s2,112(a5)
}
    80006178:	60e2                	ld	ra,24(sp)
    8000617a:	6442                	ld	s0,16(sp)
    8000617c:	64a2                	ld	s1,8(sp)
    8000617e:	6902                	ld	s2,0(sp)
    80006180:	6105                	addi	sp,sp,32
    80006182:	8082                	ret
    panic("could not find virtio disk");
    80006184:	00002517          	auipc	a0,0x2
    80006188:	5dc50513          	addi	a0,a0,1500 # 80008760 <syscalls+0x320>
    8000618c:	ffffa097          	auipc	ra,0xffffa
    80006190:	3b2080e7          	jalr	946(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006194:	00002517          	auipc	a0,0x2
    80006198:	5ec50513          	addi	a0,a0,1516 # 80008780 <syscalls+0x340>
    8000619c:	ffffa097          	auipc	ra,0xffffa
    800061a0:	3a2080e7          	jalr	930(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800061a4:	00002517          	auipc	a0,0x2
    800061a8:	5fc50513          	addi	a0,a0,1532 # 800087a0 <syscalls+0x360>
    800061ac:	ffffa097          	auipc	ra,0xffffa
    800061b0:	392080e7          	jalr	914(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800061b4:	00002517          	auipc	a0,0x2
    800061b8:	60c50513          	addi	a0,a0,1548 # 800087c0 <syscalls+0x380>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	382080e7          	jalr	898(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800061c4:	00002517          	auipc	a0,0x2
    800061c8:	61c50513          	addi	a0,a0,1564 # 800087e0 <syscalls+0x3a0>
    800061cc:	ffffa097          	auipc	ra,0xffffa
    800061d0:	372080e7          	jalr	882(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800061d4:	00002517          	auipc	a0,0x2
    800061d8:	62c50513          	addi	a0,a0,1580 # 80008800 <syscalls+0x3c0>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	362080e7          	jalr	866(ra) # 8000053e <panic>

00000000800061e4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061e4:	7119                	addi	sp,sp,-128
    800061e6:	fc86                	sd	ra,120(sp)
    800061e8:	f8a2                	sd	s0,112(sp)
    800061ea:	f4a6                	sd	s1,104(sp)
    800061ec:	f0ca                	sd	s2,96(sp)
    800061ee:	ecce                	sd	s3,88(sp)
    800061f0:	e8d2                	sd	s4,80(sp)
    800061f2:	e4d6                	sd	s5,72(sp)
    800061f4:	e0da                	sd	s6,64(sp)
    800061f6:	fc5e                	sd	s7,56(sp)
    800061f8:	f862                	sd	s8,48(sp)
    800061fa:	f466                	sd	s9,40(sp)
    800061fc:	f06a                	sd	s10,32(sp)
    800061fe:	ec6e                	sd	s11,24(sp)
    80006200:	0100                	addi	s0,sp,128
    80006202:	8aaa                	mv	s5,a0
    80006204:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006206:	00c52d03          	lw	s10,12(a0)
    8000620a:	001d1d1b          	slliw	s10,s10,0x1
    8000620e:	1d02                	slli	s10,s10,0x20
    80006210:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006214:	0001d517          	auipc	a0,0x1d
    80006218:	12450513          	addi	a0,a0,292 # 80023338 <disk+0x128>
    8000621c:	ffffb097          	auipc	ra,0xffffb
    80006220:	9ba080e7          	jalr	-1606(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006224:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006226:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006228:	0001db97          	auipc	s7,0x1d
    8000622c:	fe8b8b93          	addi	s7,s7,-24 # 80023210 <disk>
  for(int i = 0; i < 3; i++){
    80006230:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006232:	0001dc97          	auipc	s9,0x1d
    80006236:	106c8c93          	addi	s9,s9,262 # 80023338 <disk+0x128>
    8000623a:	a08d                	j	8000629c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000623c:	00fb8733          	add	a4,s7,a5
    80006240:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006244:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006246:	0207c563          	bltz	a5,80006270 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000624a:	2905                	addiw	s2,s2,1
    8000624c:	0611                	addi	a2,a2,4
    8000624e:	05690c63          	beq	s2,s6,800062a6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006252:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006254:	0001d717          	auipc	a4,0x1d
    80006258:	fbc70713          	addi	a4,a4,-68 # 80023210 <disk>
    8000625c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000625e:	01874683          	lbu	a3,24(a4)
    80006262:	fee9                	bnez	a3,8000623c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006264:	2785                	addiw	a5,a5,1
    80006266:	0705                	addi	a4,a4,1
    80006268:	fe979be3          	bne	a5,s1,8000625e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000626c:	57fd                	li	a5,-1
    8000626e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006270:	01205d63          	blez	s2,8000628a <virtio_disk_rw+0xa6>
    80006274:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006276:	000a2503          	lw	a0,0(s4)
    8000627a:	00000097          	auipc	ra,0x0
    8000627e:	cfc080e7          	jalr	-772(ra) # 80005f76 <free_desc>
      for(int j = 0; j < i; j++)
    80006282:	2d85                	addiw	s11,s11,1
    80006284:	0a11                	addi	s4,s4,4
    80006286:	ffb918e3          	bne	s2,s11,80006276 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000628a:	85e6                	mv	a1,s9
    8000628c:	0001d517          	auipc	a0,0x1d
    80006290:	f9c50513          	addi	a0,a0,-100 # 80023228 <disk+0x18>
    80006294:	ffffc097          	auipc	ra,0xffffc
    80006298:	e28080e7          	jalr	-472(ra) # 800020bc <sleep>
  for(int i = 0; i < 3; i++){
    8000629c:	f8040a13          	addi	s4,s0,-128
{
    800062a0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062a2:	894e                	mv	s2,s3
    800062a4:	b77d                	j	80006252 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062a6:	f8042583          	lw	a1,-128(s0)
    800062aa:	00a58793          	addi	a5,a1,10
    800062ae:	0792                	slli	a5,a5,0x4

  if(write)
    800062b0:	0001d617          	auipc	a2,0x1d
    800062b4:	f6060613          	addi	a2,a2,-160 # 80023210 <disk>
    800062b8:	00f60733          	add	a4,a2,a5
    800062bc:	018036b3          	snez	a3,s8
    800062c0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062c2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800062c6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062ca:	f6078693          	addi	a3,a5,-160
    800062ce:	6218                	ld	a4,0(a2)
    800062d0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062d2:	00878513          	addi	a0,a5,8
    800062d6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062d8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062da:	6208                	ld	a0,0(a2)
    800062dc:	96aa                	add	a3,a3,a0
    800062de:	4741                	li	a4,16
    800062e0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062e2:	4705                	li	a4,1
    800062e4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800062e8:	f8442703          	lw	a4,-124(s0)
    800062ec:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062f0:	0712                	slli	a4,a4,0x4
    800062f2:	953a                	add	a0,a0,a4
    800062f4:	058a8693          	addi	a3,s5,88
    800062f8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800062fa:	6208                	ld	a0,0(a2)
    800062fc:	972a                	add	a4,a4,a0
    800062fe:	40000693          	li	a3,1024
    80006302:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006304:	001c3c13          	seqz	s8,s8
    80006308:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000630a:	001c6c13          	ori	s8,s8,1
    8000630e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006312:	f8842603          	lw	a2,-120(s0)
    80006316:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000631a:	0001d697          	auipc	a3,0x1d
    8000631e:	ef668693          	addi	a3,a3,-266 # 80023210 <disk>
    80006322:	00258713          	addi	a4,a1,2
    80006326:	0712                	slli	a4,a4,0x4
    80006328:	9736                	add	a4,a4,a3
    8000632a:	587d                	li	a6,-1
    8000632c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006330:	0612                	slli	a2,a2,0x4
    80006332:	9532                	add	a0,a0,a2
    80006334:	f9078793          	addi	a5,a5,-112
    80006338:	97b6                	add	a5,a5,a3
    8000633a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000633c:	629c                	ld	a5,0(a3)
    8000633e:	97b2                	add	a5,a5,a2
    80006340:	4605                	li	a2,1
    80006342:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006344:	4509                	li	a0,2
    80006346:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000634a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000634e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006352:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006356:	6698                	ld	a4,8(a3)
    80006358:	00275783          	lhu	a5,2(a4)
    8000635c:	8b9d                	andi	a5,a5,7
    8000635e:	0786                	slli	a5,a5,0x1
    80006360:	97ba                	add	a5,a5,a4
    80006362:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006366:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000636a:	6698                	ld	a4,8(a3)
    8000636c:	00275783          	lhu	a5,2(a4)
    80006370:	2785                	addiw	a5,a5,1
    80006372:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006376:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000637a:	100017b7          	lui	a5,0x10001
    8000637e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006382:	004aa783          	lw	a5,4(s5)
    80006386:	02c79163          	bne	a5,a2,800063a8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000638a:	0001d917          	auipc	s2,0x1d
    8000638e:	fae90913          	addi	s2,s2,-82 # 80023338 <disk+0x128>
  while(b->disk == 1) {
    80006392:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006394:	85ca                	mv	a1,s2
    80006396:	8556                	mv	a0,s5
    80006398:	ffffc097          	auipc	ra,0xffffc
    8000639c:	d24080e7          	jalr	-732(ra) # 800020bc <sleep>
  while(b->disk == 1) {
    800063a0:	004aa783          	lw	a5,4(s5)
    800063a4:	fe9788e3          	beq	a5,s1,80006394 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800063a8:	f8042903          	lw	s2,-128(s0)
    800063ac:	00290793          	addi	a5,s2,2
    800063b0:	00479713          	slli	a4,a5,0x4
    800063b4:	0001d797          	auipc	a5,0x1d
    800063b8:	e5c78793          	addi	a5,a5,-420 # 80023210 <disk>
    800063bc:	97ba                	add	a5,a5,a4
    800063be:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063c2:	0001d997          	auipc	s3,0x1d
    800063c6:	e4e98993          	addi	s3,s3,-434 # 80023210 <disk>
    800063ca:	00491713          	slli	a4,s2,0x4
    800063ce:	0009b783          	ld	a5,0(s3)
    800063d2:	97ba                	add	a5,a5,a4
    800063d4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063d8:	854a                	mv	a0,s2
    800063da:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063de:	00000097          	auipc	ra,0x0
    800063e2:	b98080e7          	jalr	-1128(ra) # 80005f76 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063e6:	8885                	andi	s1,s1,1
    800063e8:	f0ed                	bnez	s1,800063ca <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063ea:	0001d517          	auipc	a0,0x1d
    800063ee:	f4e50513          	addi	a0,a0,-178 # 80023338 <disk+0x128>
    800063f2:	ffffb097          	auipc	ra,0xffffb
    800063f6:	898080e7          	jalr	-1896(ra) # 80000c8a <release>
}
    800063fa:	70e6                	ld	ra,120(sp)
    800063fc:	7446                	ld	s0,112(sp)
    800063fe:	74a6                	ld	s1,104(sp)
    80006400:	7906                	ld	s2,96(sp)
    80006402:	69e6                	ld	s3,88(sp)
    80006404:	6a46                	ld	s4,80(sp)
    80006406:	6aa6                	ld	s5,72(sp)
    80006408:	6b06                	ld	s6,64(sp)
    8000640a:	7be2                	ld	s7,56(sp)
    8000640c:	7c42                	ld	s8,48(sp)
    8000640e:	7ca2                	ld	s9,40(sp)
    80006410:	7d02                	ld	s10,32(sp)
    80006412:	6de2                	ld	s11,24(sp)
    80006414:	6109                	addi	sp,sp,128
    80006416:	8082                	ret

0000000080006418 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006418:	1101                	addi	sp,sp,-32
    8000641a:	ec06                	sd	ra,24(sp)
    8000641c:	e822                	sd	s0,16(sp)
    8000641e:	e426                	sd	s1,8(sp)
    80006420:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006422:	0001d497          	auipc	s1,0x1d
    80006426:	dee48493          	addi	s1,s1,-530 # 80023210 <disk>
    8000642a:	0001d517          	auipc	a0,0x1d
    8000642e:	f0e50513          	addi	a0,a0,-242 # 80023338 <disk+0x128>
    80006432:	ffffa097          	auipc	ra,0xffffa
    80006436:	7a4080e7          	jalr	1956(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000643a:	10001737          	lui	a4,0x10001
    8000643e:	533c                	lw	a5,96(a4)
    80006440:	8b8d                	andi	a5,a5,3
    80006442:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006444:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006448:	689c                	ld	a5,16(s1)
    8000644a:	0204d703          	lhu	a4,32(s1)
    8000644e:	0027d783          	lhu	a5,2(a5)
    80006452:	04f70863          	beq	a4,a5,800064a2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006456:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000645a:	6898                	ld	a4,16(s1)
    8000645c:	0204d783          	lhu	a5,32(s1)
    80006460:	8b9d                	andi	a5,a5,7
    80006462:	078e                	slli	a5,a5,0x3
    80006464:	97ba                	add	a5,a5,a4
    80006466:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006468:	00278713          	addi	a4,a5,2
    8000646c:	0712                	slli	a4,a4,0x4
    8000646e:	9726                	add	a4,a4,s1
    80006470:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006474:	e721                	bnez	a4,800064bc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006476:	0789                	addi	a5,a5,2
    80006478:	0792                	slli	a5,a5,0x4
    8000647a:	97a6                	add	a5,a5,s1
    8000647c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000647e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006482:	ffffc097          	auipc	ra,0xffffc
    80006486:	c9e080e7          	jalr	-866(ra) # 80002120 <wakeup>

    disk.used_idx += 1;
    8000648a:	0204d783          	lhu	a5,32(s1)
    8000648e:	2785                	addiw	a5,a5,1
    80006490:	17c2                	slli	a5,a5,0x30
    80006492:	93c1                	srli	a5,a5,0x30
    80006494:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006498:	6898                	ld	a4,16(s1)
    8000649a:	00275703          	lhu	a4,2(a4)
    8000649e:	faf71ce3          	bne	a4,a5,80006456 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800064a2:	0001d517          	auipc	a0,0x1d
    800064a6:	e9650513          	addi	a0,a0,-362 # 80023338 <disk+0x128>
    800064aa:	ffffa097          	auipc	ra,0xffffa
    800064ae:	7e0080e7          	jalr	2016(ra) # 80000c8a <release>
}
    800064b2:	60e2                	ld	ra,24(sp)
    800064b4:	6442                	ld	s0,16(sp)
    800064b6:	64a2                	ld	s1,8(sp)
    800064b8:	6105                	addi	sp,sp,32
    800064ba:	8082                	ret
      panic("virtio_disk_intr status");
    800064bc:	00002517          	auipc	a0,0x2
    800064c0:	35c50513          	addi	a0,a0,860 # 80008818 <syscalls+0x3d8>
    800064c4:	ffffa097          	auipc	ra,0xffffa
    800064c8:	07a080e7          	jalr	122(ra) # 8000053e <panic>
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
