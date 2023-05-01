
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
    80000068:	e5c78793          	addi	a5,a5,-420 # 80005ec0 <timervec>
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
    80000130:	440080e7          	jalr	1088(ra) # 8000256c <either_copyin>
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
    800001cc:	1ec080e7          	jalr	492(ra) # 800023b4 <killed>
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
    80000216:	302080e7          	jalr	770(ra) # 80002514 <either_copyout>
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
    800002f6:	2d2080e7          	jalr	722(ra) # 800025c4 <procdump>
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
    8000044a:	ce4080e7          	jalr	-796(ra) # 8000212a <wakeup>
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
    80000896:	898080e7          	jalr	-1896(ra) # 8000212a <wakeup>
    
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
    80000ec2:	a34080e7          	jalr	-1484(ra) # 800028f2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	03a080e7          	jalr	58(ra) # 80005f00 <plicinithart>
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
    80000f3a:	994080e7          	jalr	-1644(ra) # 800028ca <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	9b4080e7          	jalr	-1612(ra) # 800028f2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	fa4080e7          	jalr	-92(ra) # 80005eea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	fb2080e7          	jalr	-78(ra) # 80005f00 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	134080e7          	jalr	308(ra) # 8000308a <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	7d8080e7          	jalr	2008(ra) # 80003736 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	776080e7          	jalr	1910(ra) # 800046dc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	09a080e7          	jalr	154(ra) # 80006008 <virtio_disk_init>
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
    8000193a:	d3c080e7          	jalr	-708(ra) # 80002672 <kthreadinit>
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
    80001b12:	cf6080e7          	jalr	-778(ra) # 80002804 <freethread>
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
    80001bd0:	bb8080e7          	jalr	-1096(ra) # 80002784 <allockthread>
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
    80001cca:	412080e7          	jalr	1042(ra) # 800040d8 <namei>
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
    80001d66:	982080e7          	jalr	-1662(ra) # 800026e4 <mykthread>
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
    80001e10:	962080e7          	jalr	-1694(ra) # 8000476e <filedup>
    80001e14:	00a93023          	sd	a0,0(s2)
    80001e18:	b7e5                	j	80001e00 <fork+0xba>
  np->cwd = idup(p->cwd);
    80001e1a:	188ab503          	ld	a0,392(s5)
    80001e1e:	00002097          	auipc	ra,0x2
    80001e22:	ad6080e7          	jalr	-1322(ra) # 800038f4 <idup>
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
    80001f50:	914080e7          	jalr	-1772(ra) # 80002860 <swtch>
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
    80001f6c:	77c080e7          	jalr	1916(ra) # 800026e4 <mykthread>
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
    80001fd2:	892080e7          	jalr	-1902(ra) # 80002860 <swtch>
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
    80002082:	666080e7          	jalr	1638(ra) # 800026e4 <mykthread>
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
    8000209c:	872080e7          	jalr	-1934(ra) # 8000290a <usertrapret>
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
    800020b6:	604080e7          	jalr	1540(ra) # 800036b6 <fsinit>
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
    800020c8:	e052                	sd	s4,0(sp)
    800020ca:	1800                	addi	s0,sp,48
    800020cc:	89aa                	mv	s3,a0
    800020ce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	8b0080e7          	jalr	-1872(ra) # 80001980 <myproc>
    800020d8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.
  // acquire(&p->lock);  //DOC: sleeplock1 mayby return
  acquire(&p->kthread[0].t_lock);
    800020da:	02850a13          	addi	s4,a0,40
    800020de:	8552                	mv	a0,s4
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	af6080e7          	jalr	-1290(ra) # 80000bd6 <acquire>
  release(lk);
    800020e8:	854a                	mv	a0,s2
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	ba0080e7          	jalr	-1120(ra) # 80000c8a <release>

  // Go to sleep.
  p->kthread[0].chan = chan;
    800020f2:	0534b423          	sd	s3,72(s1)
  p->kthread[0].t_state = SLEEPING_t;
    800020f6:	4789                	li	a5,2
    800020f8:	c0bc                	sw	a5,64(s1)

  sched();
    800020fa:	00000097          	auipc	ra,0x0
    800020fe:	e60080e7          	jalr	-416(ra) # 80001f5a <sched>

  // Tidy up.
  p->kthread[0].chan= 0;
    80002102:	0404b423          	sd	zero,72(s1)

  // Reacquire original lock.
  release(&p->kthread[0].t_lock);
    80002106:	8552                	mv	a0,s4
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	b82080e7          	jalr	-1150(ra) # 80000c8a <release>
  // release(&p->lock);//mayby return
  acquire(lk);
    80002110:	854a                	mv	a0,s2
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	ac4080e7          	jalr	-1340(ra) # 80000bd6 <acquire>

}
    8000211a:	70a2                	ld	ra,40(sp)
    8000211c:	7402                	ld	s0,32(sp)
    8000211e:	64e2                	ld	s1,24(sp)
    80002120:	6942                	ld	s2,16(sp)
    80002122:	69a2                	ld	s3,8(sp)
    80002124:	6a02                	ld	s4,0(sp)
    80002126:	6145                	addi	sp,sp,48
    80002128:	8082                	ret

000000008000212a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000212a:	7139                	addi	sp,sp,-64
    8000212c:	fc06                	sd	ra,56(sp)
    8000212e:	f822                	sd	s0,48(sp)
    80002130:	f426                	sd	s1,40(sp)
    80002132:	f04a                	sd	s2,32(sp)
    80002134:	ec4e                	sd	s3,24(sp)
    80002136:	e852                	sd	s4,16(sp)
    80002138:	e456                	sd	s5,8(sp)
    8000213a:	e05a                	sd	s6,0(sp)
    8000213c:	0080                	addi	s0,sp,64
    8000213e:	8aaa                	mv	s5,a0
  struct proc *p;
  struct kthread *kt;
  for(p = proc; p < &proc[NPROC]; p++) {
    80002140:	0000f497          	auipc	s1,0xf
    80002144:	e5848493          	addi	s1,s1,-424 # 80010f98 <proc+0x28>
    80002148:	00016997          	auipc	s3,0x16
    8000214c:	e5098993          	addi	s3,s3,-432 # 80017f98 <bcache+0x10>
    // acquire(&p->lock);
      // acquire(&p->lock);
    for(kt=p->kthread;kt<&p->kthread[NKT];kt++){
        if(kt !=mykthread()){
          acquire(&kt->t_lock);
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    80002150:	4a09                	li	s4,2
          kt->t_state = RUNNABLE_t;
    80002152:	4b0d                	li	s6,3
    80002154:	a811                	j	80002168 <wakeup+0x3e>
        }
        release(&kt->t_lock);
    80002156:	854a                	mv	a0,s2
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	b32080e7          	jalr	-1230(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002160:	1c048493          	addi	s1,s1,448
    80002164:	02998763          	beq	s3,s1,80002192 <wakeup+0x68>
        if(kt !=mykthread()){
    80002168:	00000097          	auipc	ra,0x0
    8000216c:	57c080e7          	jalr	1404(ra) # 800026e4 <mykthread>
    80002170:	8926                	mv	s2,s1
    80002172:	fe9507e3          	beq	a0,s1,80002160 <wakeup+0x36>
          acquire(&kt->t_lock);
    80002176:	8526                	mv	a0,s1
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	a5e080e7          	jalr	-1442(ra) # 80000bd6 <acquire>
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    80002180:	4c9c                	lw	a5,24(s1)
    80002182:	fd479ae3          	bne	a5,s4,80002156 <wakeup+0x2c>
    80002186:	709c                	ld	a5,32(s1)
    80002188:	fd5797e3          	bne	a5,s5,80002156 <wakeup+0x2c>
          kt->t_state = RUNNABLE_t;
    8000218c:	0164ac23          	sw	s6,24(s1)
    80002190:	b7d9                	j	80002156 <wakeup+0x2c>

       }
    }
    // release(&p->lock);
  }
}
    80002192:	70e2                	ld	ra,56(sp)
    80002194:	7442                	ld	s0,48(sp)
    80002196:	74a2                	ld	s1,40(sp)
    80002198:	7902                	ld	s2,32(sp)
    8000219a:	69e2                	ld	s3,24(sp)
    8000219c:	6a42                	ld	s4,16(sp)
    8000219e:	6aa2                	ld	s5,8(sp)
    800021a0:	6b02                	ld	s6,0(sp)
    800021a2:	6121                	addi	sp,sp,64
    800021a4:	8082                	ret

00000000800021a6 <reparent>:
{
    800021a6:	7179                	addi	sp,sp,-48
    800021a8:	f406                	sd	ra,40(sp)
    800021aa:	f022                	sd	s0,32(sp)
    800021ac:	ec26                	sd	s1,24(sp)
    800021ae:	e84a                	sd	s2,16(sp)
    800021b0:	e44e                	sd	s3,8(sp)
    800021b2:	e052                	sd	s4,0(sp)
    800021b4:	1800                	addi	s0,sp,48
    800021b6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b8:	0000f497          	auipc	s1,0xf
    800021bc:	db848493          	addi	s1,s1,-584 # 80010f70 <proc>
      pp->parent = initproc;
    800021c0:	00006a17          	auipc	s4,0x6
    800021c4:	708a0a13          	addi	s4,s4,1800 # 800088c8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021c8:	00016997          	auipc	s3,0x16
    800021cc:	da898993          	addi	s3,s3,-600 # 80017f70 <tickslock>
    800021d0:	a029                	j	800021da <reparent+0x34>
    800021d2:	1c048493          	addi	s1,s1,448
    800021d6:	01348d63          	beq	s1,s3,800021f0 <reparent+0x4a>
    if(pp->parent == p){
    800021da:	78fc                	ld	a5,240(s1)
    800021dc:	ff279be3          	bne	a5,s2,800021d2 <reparent+0x2c>
      pp->parent = initproc;
    800021e0:	000a3503          	ld	a0,0(s4)
    800021e4:	f8e8                	sd	a0,240(s1)
      wakeup(initproc);
    800021e6:	00000097          	auipc	ra,0x0
    800021ea:	f44080e7          	jalr	-188(ra) # 8000212a <wakeup>
    800021ee:	b7d5                	j	800021d2 <reparent+0x2c>
}
    800021f0:	70a2                	ld	ra,40(sp)
    800021f2:	7402                	ld	s0,32(sp)
    800021f4:	64e2                	ld	s1,24(sp)
    800021f6:	6942                	ld	s2,16(sp)
    800021f8:	69a2                	ld	s3,8(sp)
    800021fa:	6a02                	ld	s4,0(sp)
    800021fc:	6145                	addi	sp,sp,48
    800021fe:	8082                	ret

0000000080002200 <exit>:
{
    80002200:	7179                	addi	sp,sp,-48
    80002202:	f406                	sd	ra,40(sp)
    80002204:	f022                	sd	s0,32(sp)
    80002206:	ec26                	sd	s1,24(sp)
    80002208:	e84a                	sd	s2,16(sp)
    8000220a:	e44e                	sd	s3,8(sp)
    8000220c:	e052                	sd	s4,0(sp)
    8000220e:	1800                	addi	s0,sp,48
    80002210:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	76e080e7          	jalr	1902(ra) # 80001980 <myproc>
    8000221a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000221c:	00006797          	auipc	a5,0x6
    80002220:	6ac7b783          	ld	a5,1708(a5) # 800088c8 <initproc>
    80002224:	10850493          	addi	s1,a0,264
    80002228:	18850913          	addi	s2,a0,392
    8000222c:	02a79363          	bne	a5,a0,80002252 <exit+0x52>
    panic("init exiting");
    80002230:	00006517          	auipc	a0,0x6
    80002234:	03050513          	addi	a0,a0,48 # 80008260 <digits+0x220>
    80002238:	ffffe097          	auipc	ra,0xffffe
    8000223c:	306080e7          	jalr	774(ra) # 8000053e <panic>
      fileclose(f);
    80002240:	00002097          	auipc	ra,0x2
    80002244:	580080e7          	jalr	1408(ra) # 800047c0 <fileclose>
      p->ofile[fd] = 0;
    80002248:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000224c:	04a1                	addi	s1,s1,8
    8000224e:	01248563          	beq	s1,s2,80002258 <exit+0x58>
    if(p->ofile[fd]){
    80002252:	6088                	ld	a0,0(s1)
    80002254:	f575                	bnez	a0,80002240 <exit+0x40>
    80002256:	bfdd                	j	8000224c <exit+0x4c>
  begin_op();
    80002258:	00002097          	auipc	ra,0x2
    8000225c:	09c080e7          	jalr	156(ra) # 800042f4 <begin_op>
  iput(p->cwd);
    80002260:	1889b503          	ld	a0,392(s3)
    80002264:	00002097          	auipc	ra,0x2
    80002268:	888080e7          	jalr	-1912(ra) # 80003aec <iput>
  end_op();
    8000226c:	00002097          	auipc	ra,0x2
    80002270:	108080e7          	jalr	264(ra) # 80004374 <end_op>
  p->cwd = 0;
    80002274:	1809b423          	sd	zero,392(s3)
  acquire(&wait_lock);
    80002278:	0000f917          	auipc	s2,0xf
    8000227c:	8e090913          	addi	s2,s2,-1824 # 80010b58 <wait_lock>
    80002280:	854a                	mv	a0,s2
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	954080e7          	jalr	-1708(ra) # 80000bd6 <acquire>
  reparent(p);
    8000228a:	854e                	mv	a0,s3
    8000228c:	00000097          	auipc	ra,0x0
    80002290:	f1a080e7          	jalr	-230(ra) # 800021a6 <reparent>
  wakeup(p->parent);
    80002294:	0f09b503          	ld	a0,240(s3)
    80002298:	00000097          	auipc	ra,0x0
    8000229c:	e92080e7          	jalr	-366(ra) # 8000212a <wakeup>
  acquire(&p->lock);
    800022a0:	854e                	mv	a0,s3
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	934080e7          	jalr	-1740(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    800022aa:	02898493          	addi	s1,s3,40
    800022ae:	8526                	mv	a0,s1
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	926080e7          	jalr	-1754(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state=ZOMBIE_t;
    800022b8:	4795                	li	a5,5
    800022ba:	04f9a023          	sw	a5,64(s3)
  p->xstate = status;
    800022be:	0349a023          	sw	s4,32(s3)
  p->state = ZOMBIE;
    800022c2:	4789                	li	a5,2
    800022c4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022c8:	854a                	mv	a0,s2
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	9c0080e7          	jalr	-1600(ra) # 80000c8a <release>
  release(&p->lock);
    800022d2:	854e                	mv	a0,s3
    800022d4:	fffff097          	auipc	ra,0xfffff
    800022d8:	9b6080e7          	jalr	-1610(ra) # 80000c8a <release>
  sched();
    800022dc:	00000097          	auipc	ra,0x0
    800022e0:	c7e080e7          	jalr	-898(ra) # 80001f5a <sched>
  release(&p->kthread[0].t_lock);
    800022e4:	8526                	mv	a0,s1
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	9a4080e7          	jalr	-1628(ra) # 80000c8a <release>
  panic("zombie exit");
    800022ee:	00006517          	auipc	a0,0x6
    800022f2:	f8250513          	addi	a0,a0,-126 # 80008270 <digits+0x230>
    800022f6:	ffffe097          	auipc	ra,0xffffe
    800022fa:	248080e7          	jalr	584(ra) # 8000053e <panic>

00000000800022fe <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022fe:	7179                	addi	sp,sp,-48
    80002300:	f406                	sd	ra,40(sp)
    80002302:	f022                	sd	s0,32(sp)
    80002304:	ec26                	sd	s1,24(sp)
    80002306:	e84a                	sd	s2,16(sp)
    80002308:	e44e                	sd	s3,8(sp)
    8000230a:	1800                	addi	s0,sp,48
    8000230c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000230e:	0000f497          	auipc	s1,0xf
    80002312:	c6248493          	addi	s1,s1,-926 # 80010f70 <proc>
    80002316:	00016997          	auipc	s3,0x16
    8000231a:	c5a98993          	addi	s3,s3,-934 # 80017f70 <tickslock>
    acquire(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	8b6080e7          	jalr	-1866(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002328:	50dc                	lw	a5,36(s1)
    8000232a:	01278d63          	beq	a5,s2,80002344 <kill+0x46>
      // }
      release(&p->lock);
      return 0;
    }
    
    release(&p->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	95a080e7          	jalr	-1702(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002338:	1c048493          	addi	s1,s1,448
    8000233c:	ff3491e3          	bne	s1,s3,8000231e <kill+0x20>
  }
  return -1;
    80002340:	557d                	li	a0,-1
    80002342:	a80d                	j	80002374 <kill+0x76>
      p->killed = 1;
    80002344:	4785                	li	a5,1
    80002346:	ccdc                	sw	a5,28(s1)
        acquire(&t->t_lock);
    80002348:	02848913          	addi	s2,s1,40
    8000234c:	854a                	mv	a0,s2
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	888080e7          	jalr	-1912(ra) # 80000bd6 <acquire>
        if(t->t_state == SLEEPING_t) {
    80002356:	40b8                	lw	a4,64(s1)
    80002358:	4789                	li	a5,2
    8000235a:	02f70463          	beq	a4,a5,80002382 <kill+0x84>
        release(&t->t_lock);
    8000235e:	854a                	mv	a0,s2
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
      release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	920080e7          	jalr	-1760(ra) # 80000c8a <release>
      return 0;
    80002372:	4501                	li	a0,0
}
    80002374:	70a2                	ld	ra,40(sp)
    80002376:	7402                	ld	s0,32(sp)
    80002378:	64e2                	ld	s1,24(sp)
    8000237a:	6942                	ld	s2,16(sp)
    8000237c:	69a2                	ld	s3,8(sp)
    8000237e:	6145                	addi	sp,sp,48
    80002380:	8082                	ret
          t->t_state = RUNNABLE_t;
    80002382:	478d                	li	a5,3
    80002384:	c0bc                	sw	a5,64(s1)
    80002386:	bfe1                	j	8000235e <kill+0x60>

0000000080002388 <setkilled>:


void
setkilled(struct proc *p)
{
    80002388:	1101                	addi	sp,sp,-32
    8000238a:	ec06                	sd	ra,24(sp)
    8000238c:	e822                	sd	s0,16(sp)
    8000238e:	e426                	sd	s1,8(sp)
    80002390:	1000                	addi	s0,sp,32
    80002392:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	842080e7          	jalr	-1982(ra) # 80000bd6 <acquire>
  p->killed = 1;
    8000239c:	4785                	li	a5,1
    8000239e:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    800023a0:	8526                	mv	a0,s1
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	8e8080e7          	jalr	-1816(ra) # 80000c8a <release>
}
    800023aa:	60e2                	ld	ra,24(sp)
    800023ac:	6442                	ld	s0,16(sp)
    800023ae:	64a2                	ld	s1,8(sp)
    800023b0:	6105                	addi	sp,sp,32
    800023b2:	8082                	ret

00000000800023b4 <killed>:

int
killed(struct proc *p)
{
    800023b4:	1101                	addi	sp,sp,-32
    800023b6:	ec06                	sd	ra,24(sp)
    800023b8:	e822                	sd	s0,16(sp)
    800023ba:	e426                	sd	s1,8(sp)
    800023bc:	e04a                	sd	s2,0(sp)
    800023be:	1000                	addi	s0,sp,32
    800023c0:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	814080e7          	jalr	-2028(ra) # 80000bd6 <acquire>
  k = p->killed;
    800023ca:	01c4a903          	lw	s2,28(s1)
  release(&p->lock);
    800023ce:	8526                	mv	a0,s1
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	8ba080e7          	jalr	-1862(ra) # 80000c8a <release>
  return k;
}
    800023d8:	854a                	mv	a0,s2
    800023da:	60e2                	ld	ra,24(sp)
    800023dc:	6442                	ld	s0,16(sp)
    800023de:	64a2                	ld	s1,8(sp)
    800023e0:	6902                	ld	s2,0(sp)
    800023e2:	6105                	addi	sp,sp,32
    800023e4:	8082                	ret

00000000800023e6 <wait>:
{
    800023e6:	715d                	addi	sp,sp,-80
    800023e8:	e486                	sd	ra,72(sp)
    800023ea:	e0a2                	sd	s0,64(sp)
    800023ec:	fc26                	sd	s1,56(sp)
    800023ee:	f84a                	sd	s2,48(sp)
    800023f0:	f44e                	sd	s3,40(sp)
    800023f2:	f052                	sd	s4,32(sp)
    800023f4:	ec56                	sd	s5,24(sp)
    800023f6:	e85a                	sd	s6,16(sp)
    800023f8:	e45e                	sd	s7,8(sp)
    800023fa:	e062                	sd	s8,0(sp)
    800023fc:	0880                	addi	s0,sp,80
    800023fe:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	580080e7          	jalr	1408(ra) # 80001980 <myproc>
    80002408:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000240a:	0000e517          	auipc	a0,0xe
    8000240e:	74e50513          	addi	a0,a0,1870 # 80010b58 <wait_lock>
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	7c4080e7          	jalr	1988(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000241a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000241c:	4a09                	li	s4,2
        havekids = 1;
    8000241e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002420:	00016997          	auipc	s3,0x16
    80002424:	b5098993          	addi	s3,s3,-1200 # 80017f70 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002428:	0000ec17          	auipc	s8,0xe
    8000242c:	730c0c13          	addi	s8,s8,1840 # 80010b58 <wait_lock>
    havekids = 0;
    80002430:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002432:	0000f497          	auipc	s1,0xf
    80002436:	b3e48493          	addi	s1,s1,-1218 # 80010f70 <proc>
    8000243a:	a0bd                	j	800024a8 <wait+0xc2>
          pid = pp->pid;
    8000243c:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002440:	000b0e63          	beqz	s6,8000245c <wait+0x76>
    80002444:	4691                	li	a3,4
    80002446:	02048613          	addi	a2,s1,32
    8000244a:	85da                	mv	a1,s6
    8000244c:	10093503          	ld	a0,256(s2)
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	218080e7          	jalr	536(ra) # 80001668 <copyout>
    80002458:	02054563          	bltz	a0,80002482 <wait+0x9c>
          freeproc(pp);
    8000245c:	8526                	mv	a0,s1
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	692080e7          	jalr	1682(ra) # 80001af0 <freeproc>
          release(&pp->lock);
    80002466:	8526                	mv	a0,s1
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	822080e7          	jalr	-2014(ra) # 80000c8a <release>
          release(&wait_lock);
    80002470:	0000e517          	auipc	a0,0xe
    80002474:	6e850513          	addi	a0,a0,1768 # 80010b58 <wait_lock>
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	812080e7          	jalr	-2030(ra) # 80000c8a <release>
          return pid;
    80002480:	a0b5                	j	800024ec <wait+0x106>
            release(&pp->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	806080e7          	jalr	-2042(ra) # 80000c8a <release>
            release(&wait_lock);
    8000248c:	0000e517          	auipc	a0,0xe
    80002490:	6cc50513          	addi	a0,a0,1740 # 80010b58 <wait_lock>
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	7f6080e7          	jalr	2038(ra) # 80000c8a <release>
            return -1;
    8000249c:	59fd                	li	s3,-1
    8000249e:	a0b9                	j	800024ec <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024a0:	1c048493          	addi	s1,s1,448
    800024a4:	03348463          	beq	s1,s3,800024cc <wait+0xe6>
      if(pp->parent == p){
    800024a8:	78fc                	ld	a5,240(s1)
    800024aa:	ff279be3          	bne	a5,s2,800024a0 <wait+0xba>
        acquire(&pp->lock);
    800024ae:	8526                	mv	a0,s1
    800024b0:	ffffe097          	auipc	ra,0xffffe
    800024b4:	726080e7          	jalr	1830(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    800024b8:	4c9c                	lw	a5,24(s1)
    800024ba:	f94781e3          	beq	a5,s4,8000243c <wait+0x56>
        release(&pp->lock);
    800024be:	8526                	mv	a0,s1
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	7ca080e7          	jalr	1994(ra) # 80000c8a <release>
        havekids = 1;
    800024c8:	8756                	mv	a4,s5
    800024ca:	bfd9                	j	800024a0 <wait+0xba>
    if(!havekids || killed(p)){
    800024cc:	c719                	beqz	a4,800024da <wait+0xf4>
    800024ce:	854a                	mv	a0,s2
    800024d0:	00000097          	auipc	ra,0x0
    800024d4:	ee4080e7          	jalr	-284(ra) # 800023b4 <killed>
    800024d8:	c51d                	beqz	a0,80002506 <wait+0x120>
      release(&wait_lock);
    800024da:	0000e517          	auipc	a0,0xe
    800024de:	67e50513          	addi	a0,a0,1662 # 80010b58 <wait_lock>
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	7a8080e7          	jalr	1960(ra) # 80000c8a <release>
      return -1;
    800024ea:	59fd                	li	s3,-1
}
    800024ec:	854e                	mv	a0,s3
    800024ee:	60a6                	ld	ra,72(sp)
    800024f0:	6406                	ld	s0,64(sp)
    800024f2:	74e2                	ld	s1,56(sp)
    800024f4:	7942                	ld	s2,48(sp)
    800024f6:	79a2                	ld	s3,40(sp)
    800024f8:	7a02                	ld	s4,32(sp)
    800024fa:	6ae2                	ld	s5,24(sp)
    800024fc:	6b42                	ld	s6,16(sp)
    800024fe:	6ba2                	ld	s7,8(sp)
    80002500:	6c02                	ld	s8,0(sp)
    80002502:	6161                	addi	sp,sp,80
    80002504:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002506:	85e2                	mv	a1,s8
    80002508:	854a                	mv	a0,s2
    8000250a:	00000097          	auipc	ra,0x0
    8000250e:	bb2080e7          	jalr	-1102(ra) # 800020bc <sleep>
    havekids = 0;
    80002512:	bf39                	j	80002430 <wait+0x4a>

0000000080002514 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002514:	7179                	addi	sp,sp,-48
    80002516:	f406                	sd	ra,40(sp)
    80002518:	f022                	sd	s0,32(sp)
    8000251a:	ec26                	sd	s1,24(sp)
    8000251c:	e84a                	sd	s2,16(sp)
    8000251e:	e44e                	sd	s3,8(sp)
    80002520:	e052                	sd	s4,0(sp)
    80002522:	1800                	addi	s0,sp,48
    80002524:	84aa                	mv	s1,a0
    80002526:	892e                	mv	s2,a1
    80002528:	89b2                	mv	s3,a2
    8000252a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000252c:	fffff097          	auipc	ra,0xfffff
    80002530:	454080e7          	jalr	1108(ra) # 80001980 <myproc>
  if(user_dst){
    80002534:	c095                	beqz	s1,80002558 <either_copyout+0x44>
    return copyout(p->pagetable, dst, src, len);
    80002536:	86d2                	mv	a3,s4
    80002538:	864e                	mv	a2,s3
    8000253a:	85ca                	mv	a1,s2
    8000253c:	10053503          	ld	a0,256(a0)
    80002540:	fffff097          	auipc	ra,0xfffff
    80002544:	128080e7          	jalr	296(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002548:	70a2                	ld	ra,40(sp)
    8000254a:	7402                	ld	s0,32(sp)
    8000254c:	64e2                	ld	s1,24(sp)
    8000254e:	6942                	ld	s2,16(sp)
    80002550:	69a2                	ld	s3,8(sp)
    80002552:	6a02                	ld	s4,0(sp)
    80002554:	6145                	addi	sp,sp,48
    80002556:	8082                	ret
    memmove((char *)dst, src, len);
    80002558:	000a061b          	sext.w	a2,s4
    8000255c:	85ce                	mv	a1,s3
    8000255e:	854a                	mv	a0,s2
    80002560:	ffffe097          	auipc	ra,0xffffe
    80002564:	7ce080e7          	jalr	1998(ra) # 80000d2e <memmove>
    return 0;
    80002568:	8526                	mv	a0,s1
    8000256a:	bff9                	j	80002548 <either_copyout+0x34>

000000008000256c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000256c:	7179                	addi	sp,sp,-48
    8000256e:	f406                	sd	ra,40(sp)
    80002570:	f022                	sd	s0,32(sp)
    80002572:	ec26                	sd	s1,24(sp)
    80002574:	e84a                	sd	s2,16(sp)
    80002576:	e44e                	sd	s3,8(sp)
    80002578:	e052                	sd	s4,0(sp)
    8000257a:	1800                	addi	s0,sp,48
    8000257c:	892a                	mv	s2,a0
    8000257e:	84ae                	mv	s1,a1
    80002580:	89b2                	mv	s3,a2
    80002582:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002584:	fffff097          	auipc	ra,0xfffff
    80002588:	3fc080e7          	jalr	1020(ra) # 80001980 <myproc>
  if(user_src){
    8000258c:	c095                	beqz	s1,800025b0 <either_copyin+0x44>
    return copyin(p->pagetable, dst, src, len);
    8000258e:	86d2                	mv	a3,s4
    80002590:	864e                	mv	a2,s3
    80002592:	85ca                	mv	a1,s2
    80002594:	10053503          	ld	a0,256(a0)
    80002598:	fffff097          	auipc	ra,0xfffff
    8000259c:	15c080e7          	jalr	348(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025a0:	70a2                	ld	ra,40(sp)
    800025a2:	7402                	ld	s0,32(sp)
    800025a4:	64e2                	ld	s1,24(sp)
    800025a6:	6942                	ld	s2,16(sp)
    800025a8:	69a2                	ld	s3,8(sp)
    800025aa:	6a02                	ld	s4,0(sp)
    800025ac:	6145                	addi	sp,sp,48
    800025ae:	8082                	ret
    memmove(dst, (char*)src, len);
    800025b0:	000a061b          	sext.w	a2,s4
    800025b4:	85ce                	mv	a1,s3
    800025b6:	854a                	mv	a0,s2
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    return 0;
    800025c0:	8526                	mv	a0,s1
    800025c2:	bff9                	j	800025a0 <either_copyin+0x34>

00000000800025c4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025c4:	715d                	addi	sp,sp,-80
    800025c6:	e486                	sd	ra,72(sp)
    800025c8:	e0a2                	sd	s0,64(sp)
    800025ca:	fc26                	sd	s1,56(sp)
    800025cc:	f84a                	sd	s2,48(sp)
    800025ce:	f44e                	sd	s3,40(sp)
    800025d0:	f052                	sd	s4,32(sp)
    800025d2:	ec56                	sd	s5,24(sp)
    800025d4:	e85a                	sd	s6,16(sp)
    800025d6:	e45e                	sd	s7,8(sp)
    800025d8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025da:	00006517          	auipc	a0,0x6
    800025de:	aee50513          	addi	a0,a0,-1298 # 800080c8 <digits+0x88>
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	fa6080e7          	jalr	-90(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ea:	0000f497          	auipc	s1,0xf
    800025ee:	b1648493          	addi	s1,s1,-1258 # 80011100 <proc+0x190>
    800025f2:	00016917          	auipc	s2,0x16
    800025f6:	b0e90913          	addi	s2,s2,-1266 # 80018100 <bcache+0x178>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025fa:	4b09                	li	s6,2
      state = states[p->state];
    else
      state = "???";
    800025fc:	00006997          	auipc	s3,0x6
    80002600:	c8498993          	addi	s3,s3,-892 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002604:	00006a97          	auipc	s5,0x6
    80002608:	c84a8a93          	addi	s5,s5,-892 # 80008288 <digits+0x248>
    printf("\n");
    8000260c:	00006a17          	auipc	s4,0x6
    80002610:	abca0a13          	addi	s4,s4,-1348 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002614:	00006b97          	auipc	s7,0x6
    80002618:	c9cb8b93          	addi	s7,s7,-868 # 800082b0 <states.0>
    8000261c:	a00d                	j	8000263e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000261e:	e946a583          	lw	a1,-364(a3)
    80002622:	8556                	mv	a0,s5
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	f64080e7          	jalr	-156(ra) # 80000588 <printf>
    printf("\n");
    8000262c:	8552                	mv	a0,s4
    8000262e:	ffffe097          	auipc	ra,0xffffe
    80002632:	f5a080e7          	jalr	-166(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002636:	1c048493          	addi	s1,s1,448
    8000263a:	03248163          	beq	s1,s2,8000265c <procdump+0x98>
    if(p->state == UNUSED)
    8000263e:	86a6                	mv	a3,s1
    80002640:	e884a783          	lw	a5,-376(s1)
    80002644:	dbed                	beqz	a5,80002636 <procdump+0x72>
      state = "???";
    80002646:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002648:	fcfb6be3          	bltu	s6,a5,8000261e <procdump+0x5a>
    8000264c:	1782                	slli	a5,a5,0x20
    8000264e:	9381                	srli	a5,a5,0x20
    80002650:	078e                	slli	a5,a5,0x3
    80002652:	97de                	add	a5,a5,s7
    80002654:	6390                	ld	a2,0(a5)
    80002656:	f661                	bnez	a2,8000261e <procdump+0x5a>
      state = "???";
    80002658:	864e                	mv	a2,s3
    8000265a:	b7d1                	j	8000261e <procdump+0x5a>
  }
}
    8000265c:	60a6                	ld	ra,72(sp)
    8000265e:	6406                	ld	s0,64(sp)
    80002660:	74e2                	ld	s1,56(sp)
    80002662:	7942                	ld	s2,48(sp)
    80002664:	79a2                	ld	s3,40(sp)
    80002666:	7a02                	ld	s4,32(sp)
    80002668:	6ae2                	ld	s5,24(sp)
    8000266a:	6b42                	ld	s6,16(sp)
    8000266c:	6ba2                	ld	s7,8(sp)
    8000266e:	6161                	addi	sp,sp,80
    80002670:	8082                	ret

0000000080002672 <kthreadinit>:
#include "defs.h"

extern struct proc proc[NPROC];
extern void forkret(void);
void kthreadinit(struct proc *p)
{
    80002672:	1101                	addi	sp,sp,-32
    80002674:	ec06                	sd	ra,24(sp)
    80002676:	e822                	sd	s0,16(sp)
    80002678:	e426                	sd	s1,8(sp)
    8000267a:	1000                	addi	s0,sp,32
    8000267c:	84aa                	mv	s1,a0
  initlock(&(p->alloc_lock),"aloc_thread");
    8000267e:	00006597          	auipc	a1,0x6
    80002682:	c4a58593          	addi	a1,a1,-950 # 800082c8 <states.0+0x18>
    80002686:	1a850513          	addi	a0,a0,424
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	4bc080e7          	jalr	1212(ra) # 80000b46 <initlock>
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
    80002692:	00006597          	auipc	a1,0x6
    80002696:	c4658593          	addi	a1,a1,-954 # 800082d8 <states.0+0x28>
    8000269a:	02848513          	addi	a0,s1,40
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	4a8080e7          	jalr	1192(ra) # 80000b46 <initlock>
      kt->t_state = UNUSED_t;
    800026a6:	0404a023          	sw	zero,64(s1)
      kt->process=p;
    800026aa:	f0a4                	sd	s1,96(s1)
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    800026ac:	0000f797          	auipc	a5,0xf
    800026b0:	8c478793          	addi	a5,a5,-1852 # 80010f70 <proc>
    800026b4:	40f487b3          	sub	a5,s1,a5
    800026b8:	8799                	srai	a5,a5,0x6
    800026ba:	00006717          	auipc	a4,0x6
    800026be:	94673703          	ld	a4,-1722(a4) # 80008000 <etext>
    800026c2:	02e787b3          	mul	a5,a5,a4
    800026c6:	2785                	addiw	a5,a5,1
    800026c8:	00d7979b          	slliw	a5,a5,0xd
    800026cc:	04000737          	lui	a4,0x4000
    800026d0:	177d                	addi	a4,a4,-1
    800026d2:	0732                	slli	a4,a4,0xc
    800026d4:	40f707b3          	sub	a5,a4,a5
    800026d8:	ecfc                	sd	a5,216(s1)
  }
}
    800026da:	60e2                	ld	ra,24(sp)
    800026dc:	6442                	ld	s0,16(sp)
    800026de:	64a2                	ld	s1,8(sp)
    800026e0:	6105                	addi	sp,sp,32
    800026e2:	8082                	ret

00000000800026e4 <mykthread>:

struct kthread *mykthread()
{
    800026e4:	1101                	addi	sp,sp,-32
    800026e6:	ec06                	sd	ra,24(sp)
    800026e8:	e822                	sd	s0,16(sp)
    800026ea:	e426                	sd	s1,8(sp)
    800026ec:	1000                	addi	s0,sp,32
  push_off();
    800026ee:	ffffe097          	auipc	ra,0xffffe
    800026f2:	49c080e7          	jalr	1180(ra) # 80000b8a <push_off>
  struct cpu *c = mycpu();
    800026f6:	fffff097          	auipc	ra,0xfffff
    800026fa:	26e080e7          	jalr	622(ra) # 80001964 <mycpu>
  struct kthread *kthread = c->kthread;
    800026fe:	6104                	ld	s1,0(a0)
  pop_off();
    80002700:	ffffe097          	auipc	ra,0xffffe
    80002704:	52a080e7          	jalr	1322(ra) # 80000c2a <pop_off>
  return kthread;
}
    80002708:	8526                	mv	a0,s1
    8000270a:	60e2                	ld	ra,24(sp)
    8000270c:	6442                	ld	s0,16(sp)
    8000270e:	64a2                	ld	s1,8(sp)
    80002710:	6105                	addi	sp,sp,32
    80002712:	8082                	ret

0000000080002714 <alloctid>:

int alloctid(struct proc *p){
    80002714:	7179                	addi	sp,sp,-48
    80002716:	f406                	sd	ra,40(sp)
    80002718:	f022                	sd	s0,32(sp)
    8000271a:	ec26                	sd	s1,24(sp)
    8000271c:	e84a                	sd	s2,16(sp)
    8000271e:	e44e                	sd	s3,8(sp)
    80002720:	1800                	addi	s0,sp,48
    80002722:	84aa                	mv	s1,a0
  int tid;
  acquire(&(p->alloc_lock));
    80002724:	1a850993          	addi	s3,a0,424
    80002728:	854e                	mv	a0,s3
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	4ac080e7          	jalr	1196(ra) # 80000bd6 <acquire>
  tid = p->p_counter;
    80002732:	1a04a903          	lw	s2,416(s1)
  p->p_counter++;
    80002736:	0019079b          	addiw	a5,s2,1
    8000273a:	1af4a023          	sw	a5,416(s1)
  release(&(p->alloc_lock));
    8000273e:	854e                	mv	a0,s3
    80002740:	ffffe097          	auipc	ra,0xffffe
    80002744:	54a080e7          	jalr	1354(ra) # 80000c8a <release>
  return tid;
}
    80002748:	854a                	mv	a0,s2
    8000274a:	70a2                	ld	ra,40(sp)
    8000274c:	7402                	ld	s0,32(sp)
    8000274e:	64e2                	ld	s1,24(sp)
    80002750:	6942                	ld	s2,16(sp)
    80002752:	69a2                	ld	s3,8(sp)
    80002754:	6145                	addi	sp,sp,48
    80002756:	8082                	ret

0000000080002758 <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    80002758:	1141                	addi	sp,sp,-16
    8000275a:	e422                	sd	s0,8(sp)
    8000275c:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    8000275e:	02850793          	addi	a5,a0,40
    80002762:	8d9d                	sub	a1,a1,a5
    80002764:	8599                	srai	a1,a1,0x6
    80002766:	00006797          	auipc	a5,0x6
    8000276a:	8a27b783          	ld	a5,-1886(a5) # 80008008 <etext+0x8>
    8000276e:	02f585bb          	mulw	a1,a1,a5
    80002772:	00359793          	slli	a5,a1,0x3
    80002776:	95be                	add	a1,a1,a5
    80002778:	0596                	slli	a1,a1,0x5
    8000277a:	7568                	ld	a0,232(a0)
}
    8000277c:	952e                	add	a0,a0,a1
    8000277e:	6422                	ld	s0,8(sp)
    80002780:	0141                	addi	sp,sp,16
    80002782:	8082                	ret

0000000080002784 <allockthread>:

struct kthread* allockthread(struct proc *p){
    80002784:	1101                	addi	sp,sp,-32
    80002786:	ec06                	sd	ra,24(sp)
    80002788:	e822                	sd	s0,16(sp)
    8000278a:	e426                	sd	s1,8(sp)
    8000278c:	e04a                	sd	s2,0(sp)
    8000278e:	1000                	addi	s0,sp,32
    80002790:	84aa                	mv	s1,a0
  
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    80002792:	02850913          	addi	s2,a0,40
    {
      acquire(&kt->t_lock);
    80002796:	854a                	mv	a0,s2
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	43e080e7          	jalr	1086(ra) # 80000bd6 <acquire>
      if(kt->t_state == UNUSED_t) {
    800027a0:	40bc                	lw	a5,64(s1)
    800027a2:	cf91                	beqz	a5,800027be <allockthread+0x3a>
        kt->context.ra = (uint64)forkret;
        kt->context.sp = kt->kstack + PGSIZE;
        return kt;
      } 
      else {
        release(&kt->t_lock);
    800027a4:	854a                	mv	a0,s2
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	4e4080e7          	jalr	1252(ra) # 80000c8a <release>
      }
  }
  return 0;
    800027ae:	4901                	li	s2,0
}
    800027b0:	854a                	mv	a0,s2
    800027b2:	60e2                	ld	ra,24(sp)
    800027b4:	6442                	ld	s0,16(sp)
    800027b6:	64a2                	ld	s1,8(sp)
    800027b8:	6902                	ld	s2,0(sp)
    800027ba:	6105                	addi	sp,sp,32
    800027bc:	8082                	ret
        kt->tid = alloctid(p);
    800027be:	8526                	mv	a0,s1
    800027c0:	00000097          	auipc	ra,0x0
    800027c4:	f54080e7          	jalr	-172(ra) # 80002714 <alloctid>
    800027c8:	cca8                	sw	a0,88(s1)
        kt->t_state = USED_t;
    800027ca:	4785                	li	a5,1
    800027cc:	c0bc                	sw	a5,64(s1)
        kt->process=p;
    800027ce:	f0a4                	sd	s1,96(s1)
        kt->trapframe = get_kthread_trapframe(p,kt);
    800027d0:	85ca                	mv	a1,s2
    800027d2:	8526                	mv	a0,s1
    800027d4:	00000097          	auipc	ra,0x0
    800027d8:	f84080e7          	jalr	-124(ra) # 80002758 <get_kthread_trapframe>
    800027dc:	f0e8                	sd	a0,224(s1)
        memset(&kt->context, 0, sizeof(kt->context));   
    800027de:	07000613          	li	a2,112
    800027e2:	4581                	li	a1,0
    800027e4:	06848513          	addi	a0,s1,104
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	4ea080e7          	jalr	1258(ra) # 80000cd2 <memset>
        kt->context.ra = (uint64)forkret;
    800027f0:	00000797          	auipc	a5,0x0
    800027f4:	88678793          	addi	a5,a5,-1914 # 80002076 <forkret>
    800027f8:	f4bc                	sd	a5,104(s1)
        kt->context.sp = kt->kstack + PGSIZE;
    800027fa:	6cfc                	ld	a5,216(s1)
    800027fc:	6705                	lui	a4,0x1
    800027fe:	97ba                	add	a5,a5,a4
    80002800:	f8bc                	sd	a5,112(s1)
        return kt;
    80002802:	b77d                	j	800027b0 <allockthread+0x2c>

0000000080002804 <freethread>:

void
freethread(struct kthread *t){
    80002804:	1101                	addi	sp,sp,-32
    80002806:	ec06                	sd	ra,24(sp)
    80002808:	e822                	sd	s0,16(sp)
    8000280a:	e426                	sd	s1,8(sp)
    8000280c:	1000                	addi	s0,sp,32
    8000280e:	84aa                	mv	s1,a0
  t->chan = 0;
    80002810:	02053023          	sd	zero,32(a0)
  t->t_killed = 0;
    80002814:	02052423          	sw	zero,40(a0)
  t->t_xstate = 0;
    80002818:	02052623          	sw	zero,44(a0)
  t->t_state = UNUSED_t;
    8000281c:	00052c23          	sw	zero,24(a0)
  t->tid=0;
    80002820:	02052823          	sw	zero,48(a0)
  t->process=0;
    80002824:	02053c23          	sd	zero,56(a0)
  t->kstack=0;
    80002828:	0a053823          	sd	zero,176(a0)
  if(t->trapframe)
    8000282c:	7d48                	ld	a0,184(a0)
    8000282e:	c509                	beqz	a0,80002838 <freethread+0x34>
    kfree((void*)t->trapframe);
    80002830:	ffffe097          	auipc	ra,0xffffe
    80002834:	1ba080e7          	jalr	442(ra) # 800009ea <kfree>
  t->trapframe = 0;
    80002838:	0a04bc23          	sd	zero,184(s1)
  memset(&t->context,0,sizeof(&t->context));
    8000283c:	4621                	li	a2,8
    8000283e:	4581                	li	a1,0
    80002840:	04048513          	addi	a0,s1,64
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	48e080e7          	jalr	1166(ra) # 80000cd2 <memset>
  release(&t->t_lock);
    8000284c:	8526                	mv	a0,s1
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	43c080e7          	jalr	1084(ra) # 80000c8a <release>
}
    80002856:	60e2                	ld	ra,24(sp)
    80002858:	6442                	ld	s0,16(sp)
    8000285a:	64a2                	ld	s1,8(sp)
    8000285c:	6105                	addi	sp,sp,32
    8000285e:	8082                	ret

0000000080002860 <swtch>:
    80002860:	00153023          	sd	ra,0(a0)
    80002864:	00253423          	sd	sp,8(a0)
    80002868:	e900                	sd	s0,16(a0)
    8000286a:	ed04                	sd	s1,24(a0)
    8000286c:	03253023          	sd	s2,32(a0)
    80002870:	03353423          	sd	s3,40(a0)
    80002874:	03453823          	sd	s4,48(a0)
    80002878:	03553c23          	sd	s5,56(a0)
    8000287c:	05653023          	sd	s6,64(a0)
    80002880:	05753423          	sd	s7,72(a0)
    80002884:	05853823          	sd	s8,80(a0)
    80002888:	05953c23          	sd	s9,88(a0)
    8000288c:	07a53023          	sd	s10,96(a0)
    80002890:	07b53423          	sd	s11,104(a0)
    80002894:	0005b083          	ld	ra,0(a1)
    80002898:	0085b103          	ld	sp,8(a1)
    8000289c:	6980                	ld	s0,16(a1)
    8000289e:	6d84                	ld	s1,24(a1)
    800028a0:	0205b903          	ld	s2,32(a1)
    800028a4:	0285b983          	ld	s3,40(a1)
    800028a8:	0305ba03          	ld	s4,48(a1)
    800028ac:	0385ba83          	ld	s5,56(a1)
    800028b0:	0405bb03          	ld	s6,64(a1)
    800028b4:	0485bb83          	ld	s7,72(a1)
    800028b8:	0505bc03          	ld	s8,80(a1)
    800028bc:	0585bc83          	ld	s9,88(a1)
    800028c0:	0605bd03          	ld	s10,96(a1)
    800028c4:	0685bd83          	ld	s11,104(a1)
    800028c8:	8082                	ret

00000000800028ca <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028ca:	1141                	addi	sp,sp,-16
    800028cc:	e406                	sd	ra,8(sp)
    800028ce:	e022                	sd	s0,0(sp)
    800028d0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028d2:	00006597          	auipc	a1,0x6
    800028d6:	a1658593          	addi	a1,a1,-1514 # 800082e8 <states.0+0x38>
    800028da:	00015517          	auipc	a0,0x15
    800028de:	69650513          	addi	a0,a0,1686 # 80017f70 <tickslock>
    800028e2:	ffffe097          	auipc	ra,0xffffe
    800028e6:	264080e7          	jalr	612(ra) # 80000b46 <initlock>
}
    800028ea:	60a2                	ld	ra,8(sp)
    800028ec:	6402                	ld	s0,0(sp)
    800028ee:	0141                	addi	sp,sp,16
    800028f0:	8082                	ret

00000000800028f2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028f2:	1141                	addi	sp,sp,-16
    800028f4:	e422                	sd	s0,8(sp)
    800028f6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f8:	00003797          	auipc	a5,0x3
    800028fc:	53878793          	addi	a5,a5,1336 # 80005e30 <kernelvec>
    80002900:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002904:	6422                	ld	s0,8(sp)
    80002906:	0141                	addi	sp,sp,16
    80002908:	8082                	ret

000000008000290a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000290a:	1101                	addi	sp,sp,-32
    8000290c:	ec06                	sd	ra,24(sp)
    8000290e:	e822                	sd	s0,16(sp)
    80002910:	e426                	sd	s1,8(sp)
    80002912:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002914:	fffff097          	auipc	ra,0xfffff
    80002918:	06c080e7          	jalr	108(ra) # 80001980 <myproc>
    8000291c:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    8000291e:	00000097          	auipc	ra,0x0
    80002922:	dc6080e7          	jalr	-570(ra) # 800026e4 <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002926:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000292a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000292c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002930:	00004617          	auipc	a2,0x4
    80002934:	6d060613          	addi	a2,a2,1744 # 80007000 <_trampoline>
    80002938:	00004697          	auipc	a3,0x4
    8000293c:	6c868693          	addi	a3,a3,1736 # 80007000 <_trampoline>
    80002940:	8e91                	sub	a3,a3,a2
    80002942:	040007b7          	lui	a5,0x4000
    80002946:	17fd                	addi	a5,a5,-1
    80002948:	07b2                	slli	a5,a5,0xc
    8000294a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000294c:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    80002950:	7d58                	ld	a4,184(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002952:	180026f3          	csrr	a3,satp
    80002956:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    80002958:	7d58                	ld	a4,184(a0)
    8000295a:	7954                	ld	a3,176(a0)
    8000295c:	6585                	lui	a1,0x1
    8000295e:	96ae                	add	a3,a3,a1
    80002960:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    80002962:	7d58                	ld	a4,184(a0)
    80002964:	00000697          	auipc	a3,0x0
    80002968:	15e68693          	addi	a3,a3,350 # 80002ac2 <usertrap>
    8000296c:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000296e:	7d58                	ld	a4,184(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002970:	8692                	mv	a3,tp
    80002972:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002974:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002978:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000297c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002980:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    80002984:	7d58                	ld	a4,184(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002986:	6f18                	ld	a4,24(a4)
    80002988:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000298c:	1004b583          	ld	a1,256(s1)
    80002990:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002992:	02848493          	addi	s1,s1,40
    80002996:	8d05                	sub	a0,a0,s1
    80002998:	8519                	srai	a0,a0,0x6
    8000299a:	00005717          	auipc	a4,0x5
    8000299e:	66e73703          	ld	a4,1646(a4) # 80008008 <etext+0x8>
    800029a2:	02e50533          	mul	a0,a0,a4
    800029a6:	1502                	slli	a0,a0,0x20
    800029a8:	9101                	srli	a0,a0,0x20
    800029aa:	00351693          	slli	a3,a0,0x3
    800029ae:	9536                	add	a0,a0,a3
    800029b0:	0516                	slli	a0,a0,0x5
    800029b2:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800029b6:	00004717          	auipc	a4,0x4
    800029ba:	6de70713          	addi	a4,a4,1758 # 80007094 <userret>
    800029be:	8f11                	sub	a4,a4,a2
    800029c0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    800029c2:	577d                	li	a4,-1
    800029c4:	177e                	slli	a4,a4,0x3f
    800029c6:	8dd9                	or	a1,a1,a4
    800029c8:	16fd                	addi	a3,a3,-1
    800029ca:	06b6                	slli	a3,a3,0xd
    800029cc:	9536                	add	a0,a0,a3
    800029ce:	9782                	jalr	a5
}
    800029d0:	60e2                	ld	ra,24(sp)
    800029d2:	6442                	ld	s0,16(sp)
    800029d4:	64a2                	ld	s1,8(sp)
    800029d6:	6105                	addi	sp,sp,32
    800029d8:	8082                	ret

00000000800029da <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029da:	1101                	addi	sp,sp,-32
    800029dc:	ec06                	sd	ra,24(sp)
    800029de:	e822                	sd	s0,16(sp)
    800029e0:	e426                	sd	s1,8(sp)
    800029e2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029e4:	00015497          	auipc	s1,0x15
    800029e8:	58c48493          	addi	s1,s1,1420 # 80017f70 <tickslock>
    800029ec:	8526                	mv	a0,s1
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	1e8080e7          	jalr	488(ra) # 80000bd6 <acquire>
  ticks++;
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	eda50513          	addi	a0,a0,-294 # 800088d0 <ticks>
    800029fe:	411c                	lw	a5,0(a0)
    80002a00:	2785                	addiw	a5,a5,1
    80002a02:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a04:	fffff097          	auipc	ra,0xfffff
    80002a08:	726080e7          	jalr	1830(ra) # 8000212a <wakeup>
  release(&tickslock);
    80002a0c:	8526                	mv	a0,s1
    80002a0e:	ffffe097          	auipc	ra,0xffffe
    80002a12:	27c080e7          	jalr	636(ra) # 80000c8a <release>
}
    80002a16:	60e2                	ld	ra,24(sp)
    80002a18:	6442                	ld	s0,16(sp)
    80002a1a:	64a2                	ld	s1,8(sp)
    80002a1c:	6105                	addi	sp,sp,32
    80002a1e:	8082                	ret

0000000080002a20 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a20:	1101                	addi	sp,sp,-32
    80002a22:	ec06                	sd	ra,24(sp)
    80002a24:	e822                	sd	s0,16(sp)
    80002a26:	e426                	sd	s1,8(sp)
    80002a28:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a2a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a2e:	00074d63          	bltz	a4,80002a48 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a32:	57fd                	li	a5,-1
    80002a34:	17fe                	slli	a5,a5,0x3f
    80002a36:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a38:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a3a:	06f70363          	beq	a4,a5,80002aa0 <devintr+0x80>
  }
}
    80002a3e:	60e2                	ld	ra,24(sp)
    80002a40:	6442                	ld	s0,16(sp)
    80002a42:	64a2                	ld	s1,8(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret
     (scause & 0xff) == 9){
    80002a48:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a4c:	46a5                	li	a3,9
    80002a4e:	fed792e3          	bne	a5,a3,80002a32 <devintr+0x12>
    int irq = plic_claim();
    80002a52:	00003097          	auipc	ra,0x3
    80002a56:	4e6080e7          	jalr	1254(ra) # 80005f38 <plic_claim>
    80002a5a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a5c:	47a9                	li	a5,10
    80002a5e:	02f50763          	beq	a0,a5,80002a8c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a62:	4785                	li	a5,1
    80002a64:	02f50963          	beq	a0,a5,80002a96 <devintr+0x76>
    return 1;
    80002a68:	4505                	li	a0,1
    } else if(irq){
    80002a6a:	d8f1                	beqz	s1,80002a3e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a6c:	85a6                	mv	a1,s1
    80002a6e:	00006517          	auipc	a0,0x6
    80002a72:	88250513          	addi	a0,a0,-1918 # 800082f0 <states.0+0x40>
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	b12080e7          	jalr	-1262(ra) # 80000588 <printf>
      plic_complete(irq);
    80002a7e:	8526                	mv	a0,s1
    80002a80:	00003097          	auipc	ra,0x3
    80002a84:	4dc080e7          	jalr	1244(ra) # 80005f5c <plic_complete>
    return 1;
    80002a88:	4505                	li	a0,1
    80002a8a:	bf55                	j	80002a3e <devintr+0x1e>
      uartintr();
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	f0e080e7          	jalr	-242(ra) # 8000099a <uartintr>
    80002a94:	b7ed                	j	80002a7e <devintr+0x5e>
      virtio_disk_intr();
    80002a96:	00004097          	auipc	ra,0x4
    80002a9a:	992080e7          	jalr	-1646(ra) # 80006428 <virtio_disk_intr>
    80002a9e:	b7c5                	j	80002a7e <devintr+0x5e>
    if(cpuid() == 0){
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	eb4080e7          	jalr	-332(ra) # 80001954 <cpuid>
    80002aa8:	c901                	beqz	a0,80002ab8 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002aaa:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002aae:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ab0:	14479073          	csrw	sip,a5
    return 2;
    80002ab4:	4509                	li	a0,2
    80002ab6:	b761                	j	80002a3e <devintr+0x1e>
      clockintr();
    80002ab8:	00000097          	auipc	ra,0x0
    80002abc:	f22080e7          	jalr	-222(ra) # 800029da <clockintr>
    80002ac0:	b7ed                	j	80002aaa <devintr+0x8a>

0000000080002ac2 <usertrap>:
{
    80002ac2:	1101                	addi	sp,sp,-32
    80002ac4:	ec06                	sd	ra,24(sp)
    80002ac6:	e822                	sd	s0,16(sp)
    80002ac8:	e426                	sd	s1,8(sp)
    80002aca:	e04a                	sd	s2,0(sp)
    80002acc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ace:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ad2:	1007f793          	andi	a5,a5,256
    80002ad6:	e7b9                	bnez	a5,80002b24 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ad8:	00003797          	auipc	a5,0x3
    80002adc:	35878793          	addi	a5,a5,856 # 80005e30 <kernelvec>
    80002ae0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ae4:	fffff097          	auipc	ra,0xfffff
    80002ae8:	e9c080e7          	jalr	-356(ra) # 80001980 <myproc>
    80002aec:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	bf6080e7          	jalr	-1034(ra) # 800026e4 <mykthread>
    80002af6:	892a                	mv	s2,a0
  kt->trapframe->epc = r_sepc();
    80002af8:	7d5c                	ld	a5,184(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002afa:	14102773          	csrr	a4,sepc
    80002afe:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b00:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b04:	47a1                	li	a5,8
    80002b06:	02f70763          	beq	a4,a5,80002b34 <usertrap+0x72>
  } else if((which_dev = devintr()) != 0){
    80002b0a:	00000097          	auipc	ra,0x0
    80002b0e:	f16080e7          	jalr	-234(ra) # 80002a20 <devintr>
    80002b12:	892a                	mv	s2,a0
    80002b14:	c541                	beqz	a0,80002b9c <usertrap+0xda>
  if(killed(p))
    80002b16:	8526                	mv	a0,s1
    80002b18:	00000097          	auipc	ra,0x0
    80002b1c:	89c080e7          	jalr	-1892(ra) # 800023b4 <killed>
    80002b20:	c939                	beqz	a0,80002b76 <usertrap+0xb4>
    80002b22:	a0a9                	j	80002b6c <usertrap+0xaa>
    panic("usertrap: not from user mode");
    80002b24:	00005517          	auipc	a0,0x5
    80002b28:	7ec50513          	addi	a0,a0,2028 # 80008310 <states.0+0x60>
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	a12080e7          	jalr	-1518(ra) # 8000053e <panic>
    if(killed(p))
    80002b34:	8526                	mv	a0,s1
    80002b36:	00000097          	auipc	ra,0x0
    80002b3a:	87e080e7          	jalr	-1922(ra) # 800023b4 <killed>
    80002b3e:	e929                	bnez	a0,80002b90 <usertrap+0xce>
    kt->trapframe->epc += 4;
    80002b40:	0b893703          	ld	a4,184(s2)
    80002b44:	6f1c                	ld	a5,24(a4)
    80002b46:	0791                	addi	a5,a5,4
    80002b48:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b4a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b4e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b52:	10079073          	csrw	sstatus,a5
    syscall();
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	2d8080e7          	jalr	728(ra) # 80002e2e <syscall>
  if(killed(p))
    80002b5e:	8526                	mv	a0,s1
    80002b60:	00000097          	auipc	ra,0x0
    80002b64:	854080e7          	jalr	-1964(ra) # 800023b4 <killed>
    80002b68:	c911                	beqz	a0,80002b7c <usertrap+0xba>
    80002b6a:	4901                	li	s2,0
    exit(-1);
    80002b6c:	557d                	li	a0,-1
    80002b6e:	fffff097          	auipc	ra,0xfffff
    80002b72:	692080e7          	jalr	1682(ra) # 80002200 <exit>
  if(which_dev == 2)
    80002b76:	4789                	li	a5,2
    80002b78:	04f90f63          	beq	s2,a5,80002bd6 <usertrap+0x114>
  usertrapret();
    80002b7c:	00000097          	auipc	ra,0x0
    80002b80:	d8e080e7          	jalr	-626(ra) # 8000290a <usertrapret>
}
    80002b84:	60e2                	ld	ra,24(sp)
    80002b86:	6442                	ld	s0,16(sp)
    80002b88:	64a2                	ld	s1,8(sp)
    80002b8a:	6902                	ld	s2,0(sp)
    80002b8c:	6105                	addi	sp,sp,32
    80002b8e:	8082                	ret
      exit(-1);
    80002b90:	557d                	li	a0,-1
    80002b92:	fffff097          	auipc	ra,0xfffff
    80002b96:	66e080e7          	jalr	1646(ra) # 80002200 <exit>
    80002b9a:	b75d                	j	80002b40 <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b9c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ba0:	50d0                	lw	a2,36(s1)
    80002ba2:	00005517          	auipc	a0,0x5
    80002ba6:	78e50513          	addi	a0,a0,1934 # 80008330 <states.0+0x80>
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	9de080e7          	jalr	-1570(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bb2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bb6:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bba:	00005517          	auipc	a0,0x5
    80002bbe:	7a650513          	addi	a0,a0,1958 # 80008360 <states.0+0xb0>
    80002bc2:	ffffe097          	auipc	ra,0xffffe
    80002bc6:	9c6080e7          	jalr	-1594(ra) # 80000588 <printf>
    setkilled(p);
    80002bca:	8526                	mv	a0,s1
    80002bcc:	fffff097          	auipc	ra,0xfffff
    80002bd0:	7bc080e7          	jalr	1980(ra) # 80002388 <setkilled>
    80002bd4:	b769                	j	80002b5e <usertrap+0x9c>
    yield();
    80002bd6:	fffff097          	auipc	ra,0xfffff
    80002bda:	45a080e7          	jalr	1114(ra) # 80002030 <yield>
    80002bde:	bf79                	j	80002b7c <usertrap+0xba>

0000000080002be0 <kerneltrap>:
{
    80002be0:	7179                	addi	sp,sp,-48
    80002be2:	f406                	sd	ra,40(sp)
    80002be4:	f022                	sd	s0,32(sp)
    80002be6:	ec26                	sd	s1,24(sp)
    80002be8:	e84a                	sd	s2,16(sp)
    80002bea:	e44e                	sd	s3,8(sp)
    80002bec:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bee:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bfa:	1004f793          	andi	a5,s1,256
    80002bfe:	cb85                	beqz	a5,80002c2e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c04:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c06:	ef85                	bnez	a5,80002c3e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c08:	00000097          	auipc	ra,0x0
    80002c0c:	e18080e7          	jalr	-488(ra) # 80002a20 <devintr>
    80002c10:	cd1d                	beqz	a0,80002c4e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002c12:	4789                	li	a5,2
    80002c14:	06f50a63          	beq	a0,a5,80002c88 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c18:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c1c:	10049073          	csrw	sstatus,s1
}
    80002c20:	70a2                	ld	ra,40(sp)
    80002c22:	7402                	ld	s0,32(sp)
    80002c24:	64e2                	ld	s1,24(sp)
    80002c26:	6942                	ld	s2,16(sp)
    80002c28:	69a2                	ld	s3,8(sp)
    80002c2a:	6145                	addi	sp,sp,48
    80002c2c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c2e:	00005517          	auipc	a0,0x5
    80002c32:	75250513          	addi	a0,a0,1874 # 80008380 <states.0+0xd0>
    80002c36:	ffffe097          	auipc	ra,0xffffe
    80002c3a:	908080e7          	jalr	-1784(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002c3e:	00005517          	auipc	a0,0x5
    80002c42:	76a50513          	addi	a0,a0,1898 # 800083a8 <states.0+0xf8>
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	8f8080e7          	jalr	-1800(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002c4e:	85ce                	mv	a1,s3
    80002c50:	00005517          	auipc	a0,0x5
    80002c54:	77850513          	addi	a0,a0,1912 # 800083c8 <states.0+0x118>
    80002c58:	ffffe097          	auipc	ra,0xffffe
    80002c5c:	930080e7          	jalr	-1744(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c60:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c64:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c68:	00005517          	auipc	a0,0x5
    80002c6c:	77050513          	addi	a0,a0,1904 # 800083d8 <states.0+0x128>
    80002c70:	ffffe097          	auipc	ra,0xffffe
    80002c74:	918080e7          	jalr	-1768(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002c78:	00005517          	auipc	a0,0x5
    80002c7c:	77850513          	addi	a0,a0,1912 # 800083f0 <states.0+0x140>
    80002c80:	ffffe097          	auipc	ra,0xffffe
    80002c84:	8be080e7          	jalr	-1858(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002c88:	fffff097          	auipc	ra,0xfffff
    80002c8c:	cf8080e7          	jalr	-776(ra) # 80001980 <myproc>
    80002c90:	d541                	beqz	a0,80002c18 <kerneltrap+0x38>
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	cee080e7          	jalr	-786(ra) # 80001980 <myproc>
    80002c9a:	4138                	lw	a4,64(a0)
    80002c9c:	4791                	li	a5,4
    80002c9e:	f6f71de3          	bne	a4,a5,80002c18 <kerneltrap+0x38>
    yield();
    80002ca2:	fffff097          	auipc	ra,0xfffff
    80002ca6:	38e080e7          	jalr	910(ra) # 80002030 <yield>
    80002caa:	b7bd                	j	80002c18 <kerneltrap+0x38>

0000000080002cac <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cac:	1101                	addi	sp,sp,-32
    80002cae:	ec06                	sd	ra,24(sp)
    80002cb0:	e822                	sd	s0,16(sp)
    80002cb2:	e426                	sd	s1,8(sp)
    80002cb4:	1000                	addi	s0,sp,32
    80002cb6:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    80002cb8:	00000097          	auipc	ra,0x0
    80002cbc:	a2c080e7          	jalr	-1492(ra) # 800026e4 <mykthread>
  switch (n) {
    80002cc0:	4795                	li	a5,5
    80002cc2:	0497e163          	bltu	a5,s1,80002d04 <argraw+0x58>
    80002cc6:	048a                	slli	s1,s1,0x2
    80002cc8:	00005717          	auipc	a4,0x5
    80002ccc:	76070713          	addi	a4,a4,1888 # 80008428 <states.0+0x178>
    80002cd0:	94ba                	add	s1,s1,a4
    80002cd2:	409c                	lw	a5,0(s1)
    80002cd4:	97ba                	add	a5,a5,a4
    80002cd6:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    80002cd8:	7d5c                	ld	a5,184(a0)
    80002cda:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cdc:	60e2                	ld	ra,24(sp)
    80002cde:	6442                	ld	s0,16(sp)
    80002ce0:	64a2                	ld	s1,8(sp)
    80002ce2:	6105                	addi	sp,sp,32
    80002ce4:	8082                	ret
    return kt->trapframe->a1;
    80002ce6:	7d5c                	ld	a5,184(a0)
    80002ce8:	7fa8                	ld	a0,120(a5)
    80002cea:	bfcd                	j	80002cdc <argraw+0x30>
    return kt->trapframe->a2;
    80002cec:	7d5c                	ld	a5,184(a0)
    80002cee:	63c8                	ld	a0,128(a5)
    80002cf0:	b7f5                	j	80002cdc <argraw+0x30>
    return kt->trapframe->a3;
    80002cf2:	7d5c                	ld	a5,184(a0)
    80002cf4:	67c8                	ld	a0,136(a5)
    80002cf6:	b7dd                	j	80002cdc <argraw+0x30>
    return kt->trapframe->a4;
    80002cf8:	7d5c                	ld	a5,184(a0)
    80002cfa:	6bc8                	ld	a0,144(a5)
    80002cfc:	b7c5                	j	80002cdc <argraw+0x30>
    return kt->trapframe->a5;
    80002cfe:	7d5c                	ld	a5,184(a0)
    80002d00:	6fc8                	ld	a0,152(a5)
    80002d02:	bfe9                	j	80002cdc <argraw+0x30>
  panic("argraw");
    80002d04:	00005517          	auipc	a0,0x5
    80002d08:	6fc50513          	addi	a0,a0,1788 # 80008400 <states.0+0x150>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	832080e7          	jalr	-1998(ra) # 8000053e <panic>

0000000080002d14 <fetchaddr>:
{
    80002d14:	1101                	addi	sp,sp,-32
    80002d16:	ec06                	sd	ra,24(sp)
    80002d18:	e822                	sd	s0,16(sp)
    80002d1a:	e426                	sd	s1,8(sp)
    80002d1c:	e04a                	sd	s2,0(sp)
    80002d1e:	1000                	addi	s0,sp,32
    80002d20:	84aa                	mv	s1,a0
    80002d22:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d24:	fffff097          	auipc	ra,0xfffff
    80002d28:	c5c080e7          	jalr	-932(ra) # 80001980 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d2c:	7d7c                	ld	a5,248(a0)
    80002d2e:	02f4f963          	bgeu	s1,a5,80002d60 <fetchaddr+0x4c>
    80002d32:	00848713          	addi	a4,s1,8
    80002d36:	02e7e763          	bltu	a5,a4,80002d64 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d3a:	46a1                	li	a3,8
    80002d3c:	8626                	mv	a2,s1
    80002d3e:	85ca                	mv	a1,s2
    80002d40:	10053503          	ld	a0,256(a0)
    80002d44:	fffff097          	auipc	ra,0xfffff
    80002d48:	9b0080e7          	jalr	-1616(ra) # 800016f4 <copyin>
    80002d4c:	00a03533          	snez	a0,a0
    80002d50:	40a00533          	neg	a0,a0
}
    80002d54:	60e2                	ld	ra,24(sp)
    80002d56:	6442                	ld	s0,16(sp)
    80002d58:	64a2                	ld	s1,8(sp)
    80002d5a:	6902                	ld	s2,0(sp)
    80002d5c:	6105                	addi	sp,sp,32
    80002d5e:	8082                	ret
    return -1;
    80002d60:	557d                	li	a0,-1
    80002d62:	bfcd                	j	80002d54 <fetchaddr+0x40>
    80002d64:	557d                	li	a0,-1
    80002d66:	b7fd                	j	80002d54 <fetchaddr+0x40>

0000000080002d68 <fetchstr>:
{
    80002d68:	7179                	addi	sp,sp,-48
    80002d6a:	f406                	sd	ra,40(sp)
    80002d6c:	f022                	sd	s0,32(sp)
    80002d6e:	ec26                	sd	s1,24(sp)
    80002d70:	e84a                	sd	s2,16(sp)
    80002d72:	e44e                	sd	s3,8(sp)
    80002d74:	1800                	addi	s0,sp,48
    80002d76:	892a                	mv	s2,a0
    80002d78:	84ae                	mv	s1,a1
    80002d7a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d7c:	fffff097          	auipc	ra,0xfffff
    80002d80:	c04080e7          	jalr	-1020(ra) # 80001980 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d84:	86ce                	mv	a3,s3
    80002d86:	864a                	mv	a2,s2
    80002d88:	85a6                	mv	a1,s1
    80002d8a:	10053503          	ld	a0,256(a0)
    80002d8e:	fffff097          	auipc	ra,0xfffff
    80002d92:	9f4080e7          	jalr	-1548(ra) # 80001782 <copyinstr>
    80002d96:	00054e63          	bltz	a0,80002db2 <fetchstr+0x4a>
  return strlen(buf);
    80002d9a:	8526                	mv	a0,s1
    80002d9c:	ffffe097          	auipc	ra,0xffffe
    80002da0:	0b2080e7          	jalr	178(ra) # 80000e4e <strlen>
}
    80002da4:	70a2                	ld	ra,40(sp)
    80002da6:	7402                	ld	s0,32(sp)
    80002da8:	64e2                	ld	s1,24(sp)
    80002daa:	6942                	ld	s2,16(sp)
    80002dac:	69a2                	ld	s3,8(sp)
    80002dae:	6145                	addi	sp,sp,48
    80002db0:	8082                	ret
    return -1;
    80002db2:	557d                	li	a0,-1
    80002db4:	bfc5                	j	80002da4 <fetchstr+0x3c>

0000000080002db6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002db6:	1101                	addi	sp,sp,-32
    80002db8:	ec06                	sd	ra,24(sp)
    80002dba:	e822                	sd	s0,16(sp)
    80002dbc:	e426                	sd	s1,8(sp)
    80002dbe:	1000                	addi	s0,sp,32
    80002dc0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dc2:	00000097          	auipc	ra,0x0
    80002dc6:	eea080e7          	jalr	-278(ra) # 80002cac <argraw>
    80002dca:	c088                	sw	a0,0(s1)
}
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	64a2                	ld	s1,8(sp)
    80002dd2:	6105                	addi	sp,sp,32
    80002dd4:	8082                	ret

0000000080002dd6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002dd6:	1101                	addi	sp,sp,-32
    80002dd8:	ec06                	sd	ra,24(sp)
    80002dda:	e822                	sd	s0,16(sp)
    80002ddc:	e426                	sd	s1,8(sp)
    80002dde:	1000                	addi	s0,sp,32
    80002de0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002de2:	00000097          	auipc	ra,0x0
    80002de6:	eca080e7          	jalr	-310(ra) # 80002cac <argraw>
    80002dea:	e088                	sd	a0,0(s1)
}
    80002dec:	60e2                	ld	ra,24(sp)
    80002dee:	6442                	ld	s0,16(sp)
    80002df0:	64a2                	ld	s1,8(sp)
    80002df2:	6105                	addi	sp,sp,32
    80002df4:	8082                	ret

0000000080002df6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002df6:	7179                	addi	sp,sp,-48
    80002df8:	f406                	sd	ra,40(sp)
    80002dfa:	f022                	sd	s0,32(sp)
    80002dfc:	ec26                	sd	s1,24(sp)
    80002dfe:	e84a                	sd	s2,16(sp)
    80002e00:	1800                	addi	s0,sp,48
    80002e02:	84ae                	mv	s1,a1
    80002e04:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e06:	fd840593          	addi	a1,s0,-40
    80002e0a:	00000097          	auipc	ra,0x0
    80002e0e:	fcc080e7          	jalr	-52(ra) # 80002dd6 <argaddr>
  return fetchstr(addr, buf, max);
    80002e12:	864a                	mv	a2,s2
    80002e14:	85a6                	mv	a1,s1
    80002e16:	fd843503          	ld	a0,-40(s0)
    80002e1a:	00000097          	auipc	ra,0x0
    80002e1e:	f4e080e7          	jalr	-178(ra) # 80002d68 <fetchstr>
}
    80002e22:	70a2                	ld	ra,40(sp)
    80002e24:	7402                	ld	s0,32(sp)
    80002e26:	64e2                	ld	s1,24(sp)
    80002e28:	6942                	ld	s2,16(sp)
    80002e2a:	6145                	addi	sp,sp,48
    80002e2c:	8082                	ret

0000000080002e2e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e2e:	7179                	addi	sp,sp,-48
    80002e30:	f406                	sd	ra,40(sp)
    80002e32:	f022                	sd	s0,32(sp)
    80002e34:	ec26                	sd	s1,24(sp)
    80002e36:	e84a                	sd	s2,16(sp)
    80002e38:	e44e                	sd	s3,8(sp)
    80002e3a:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002e3c:	fffff097          	auipc	ra,0xfffff
    80002e40:	b44080e7          	jalr	-1212(ra) # 80001980 <myproc>
    80002e44:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    80002e46:	00000097          	auipc	ra,0x0
    80002e4a:	89e080e7          	jalr	-1890(ra) # 800026e4 <mykthread>
    80002e4e:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80002e50:	0b853983          	ld	s3,184(a0)
    80002e54:	0a89b783          	ld	a5,168(s3)
    80002e58:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e5c:	37fd                	addiw	a5,a5,-1
    80002e5e:	4751                	li	a4,20
    80002e60:	00f76f63          	bltu	a4,a5,80002e7e <syscall+0x50>
    80002e64:	00369713          	slli	a4,a3,0x3
    80002e68:	00005797          	auipc	a5,0x5
    80002e6c:	5d878793          	addi	a5,a5,1496 # 80008440 <syscalls>
    80002e70:	97ba                	add	a5,a5,a4
    80002e72:	639c                	ld	a5,0(a5)
    80002e74:	c789                	beqz	a5,80002e7e <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    80002e76:	9782                	jalr	a5
    80002e78:	06a9b823          	sd	a0,112(s3)
    80002e7c:	a005                	j	80002e9c <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e7e:	19090613          	addi	a2,s2,400
    80002e82:	02492583          	lw	a1,36(s2)
    80002e86:	00005517          	auipc	a0,0x5
    80002e8a:	58250513          	addi	a0,a0,1410 # 80008408 <states.0+0x158>
    80002e8e:	ffffd097          	auipc	ra,0xffffd
    80002e92:	6fa080e7          	jalr	1786(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    80002e96:	7cdc                	ld	a5,184(s1)
    80002e98:	577d                	li	a4,-1
    80002e9a:	fbb8                	sd	a4,112(a5)
  }
}
    80002e9c:	70a2                	ld	ra,40(sp)
    80002e9e:	7402                	ld	s0,32(sp)
    80002ea0:	64e2                	ld	s1,24(sp)
    80002ea2:	6942                	ld	s2,16(sp)
    80002ea4:	69a2                	ld	s3,8(sp)
    80002ea6:	6145                	addi	sp,sp,48
    80002ea8:	8082                	ret

0000000080002eaa <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002eaa:	1101                	addi	sp,sp,-32
    80002eac:	ec06                	sd	ra,24(sp)
    80002eae:	e822                	sd	s0,16(sp)
    80002eb0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002eb2:	fec40593          	addi	a1,s0,-20
    80002eb6:	4501                	li	a0,0
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	efe080e7          	jalr	-258(ra) # 80002db6 <argint>
  exit(n);
    80002ec0:	fec42503          	lw	a0,-20(s0)
    80002ec4:	fffff097          	auipc	ra,0xfffff
    80002ec8:	33c080e7          	jalr	828(ra) # 80002200 <exit>
  return 0;  // not reached
}
    80002ecc:	4501                	li	a0,0
    80002ece:	60e2                	ld	ra,24(sp)
    80002ed0:	6442                	ld	s0,16(sp)
    80002ed2:	6105                	addi	sp,sp,32
    80002ed4:	8082                	ret

0000000080002ed6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ed6:	1141                	addi	sp,sp,-16
    80002ed8:	e406                	sd	ra,8(sp)
    80002eda:	e022                	sd	s0,0(sp)
    80002edc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ede:	fffff097          	auipc	ra,0xfffff
    80002ee2:	aa2080e7          	jalr	-1374(ra) # 80001980 <myproc>
}
    80002ee6:	5148                	lw	a0,36(a0)
    80002ee8:	60a2                	ld	ra,8(sp)
    80002eea:	6402                	ld	s0,0(sp)
    80002eec:	0141                	addi	sp,sp,16
    80002eee:	8082                	ret

0000000080002ef0 <sys_fork>:

uint64
sys_fork(void)
{
    80002ef0:	1141                	addi	sp,sp,-16
    80002ef2:	e406                	sd	ra,8(sp)
    80002ef4:	e022                	sd	s0,0(sp)
    80002ef6:	0800                	addi	s0,sp,16
  return fork();
    80002ef8:	fffff097          	auipc	ra,0xfffff
    80002efc:	e4e080e7          	jalr	-434(ra) # 80001d46 <fork>
}
    80002f00:	60a2                	ld	ra,8(sp)
    80002f02:	6402                	ld	s0,0(sp)
    80002f04:	0141                	addi	sp,sp,16
    80002f06:	8082                	ret

0000000080002f08 <sys_wait>:

uint64
sys_wait(void)
{
    80002f08:	1101                	addi	sp,sp,-32
    80002f0a:	ec06                	sd	ra,24(sp)
    80002f0c:	e822                	sd	s0,16(sp)
    80002f0e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f10:	fe840593          	addi	a1,s0,-24
    80002f14:	4501                	li	a0,0
    80002f16:	00000097          	auipc	ra,0x0
    80002f1a:	ec0080e7          	jalr	-320(ra) # 80002dd6 <argaddr>
  return wait(p);
    80002f1e:	fe843503          	ld	a0,-24(s0)
    80002f22:	fffff097          	auipc	ra,0xfffff
    80002f26:	4c4080e7          	jalr	1220(ra) # 800023e6 <wait>
}
    80002f2a:	60e2                	ld	ra,24(sp)
    80002f2c:	6442                	ld	s0,16(sp)
    80002f2e:	6105                	addi	sp,sp,32
    80002f30:	8082                	ret

0000000080002f32 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f32:	7179                	addi	sp,sp,-48
    80002f34:	f406                	sd	ra,40(sp)
    80002f36:	f022                	sd	s0,32(sp)
    80002f38:	ec26                	sd	s1,24(sp)
    80002f3a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f3c:	fdc40593          	addi	a1,s0,-36
    80002f40:	4501                	li	a0,0
    80002f42:	00000097          	auipc	ra,0x0
    80002f46:	e74080e7          	jalr	-396(ra) # 80002db6 <argint>
  addr = myproc()->sz;
    80002f4a:	fffff097          	auipc	ra,0xfffff
    80002f4e:	a36080e7          	jalr	-1482(ra) # 80001980 <myproc>
    80002f52:	7d64                	ld	s1,248(a0)
  if(growproc(n) < 0)
    80002f54:	fdc42503          	lw	a0,-36(s0)
    80002f58:	fffff097          	auipc	ra,0xfffff
    80002f5c:	d8e080e7          	jalr	-626(ra) # 80001ce6 <growproc>
    80002f60:	00054863          	bltz	a0,80002f70 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f64:	8526                	mv	a0,s1
    80002f66:	70a2                	ld	ra,40(sp)
    80002f68:	7402                	ld	s0,32(sp)
    80002f6a:	64e2                	ld	s1,24(sp)
    80002f6c:	6145                	addi	sp,sp,48
    80002f6e:	8082                	ret
    return -1;
    80002f70:	54fd                	li	s1,-1
    80002f72:	bfcd                	j	80002f64 <sys_sbrk+0x32>

0000000080002f74 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f74:	7139                	addi	sp,sp,-64
    80002f76:	fc06                	sd	ra,56(sp)
    80002f78:	f822                	sd	s0,48(sp)
    80002f7a:	f426                	sd	s1,40(sp)
    80002f7c:	f04a                	sd	s2,32(sp)
    80002f7e:	ec4e                	sd	s3,24(sp)
    80002f80:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f82:	fcc40593          	addi	a1,s0,-52
    80002f86:	4501                	li	a0,0
    80002f88:	00000097          	auipc	ra,0x0
    80002f8c:	e2e080e7          	jalr	-466(ra) # 80002db6 <argint>
  acquire(&tickslock);
    80002f90:	00015517          	auipc	a0,0x15
    80002f94:	fe050513          	addi	a0,a0,-32 # 80017f70 <tickslock>
    80002f98:	ffffe097          	auipc	ra,0xffffe
    80002f9c:	c3e080e7          	jalr	-962(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002fa0:	00006917          	auipc	s2,0x6
    80002fa4:	93092903          	lw	s2,-1744(s2) # 800088d0 <ticks>
  while(ticks - ticks0 < n){
    80002fa8:	fcc42783          	lw	a5,-52(s0)
    80002fac:	cf9d                	beqz	a5,80002fea <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fae:	00015997          	auipc	s3,0x15
    80002fb2:	fc298993          	addi	s3,s3,-62 # 80017f70 <tickslock>
    80002fb6:	00006497          	auipc	s1,0x6
    80002fba:	91a48493          	addi	s1,s1,-1766 # 800088d0 <ticks>
    if(killed(myproc())){
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	9c2080e7          	jalr	-1598(ra) # 80001980 <myproc>
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	3ee080e7          	jalr	1006(ra) # 800023b4 <killed>
    80002fce:	ed15                	bnez	a0,8000300a <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002fd0:	85ce                	mv	a1,s3
    80002fd2:	8526                	mv	a0,s1
    80002fd4:	fffff097          	auipc	ra,0xfffff
    80002fd8:	0e8080e7          	jalr	232(ra) # 800020bc <sleep>
  while(ticks - ticks0 < n){
    80002fdc:	409c                	lw	a5,0(s1)
    80002fde:	412787bb          	subw	a5,a5,s2
    80002fe2:	fcc42703          	lw	a4,-52(s0)
    80002fe6:	fce7ece3          	bltu	a5,a4,80002fbe <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002fea:	00015517          	auipc	a0,0x15
    80002fee:	f8650513          	addi	a0,a0,-122 # 80017f70 <tickslock>
    80002ff2:	ffffe097          	auipc	ra,0xffffe
    80002ff6:	c98080e7          	jalr	-872(ra) # 80000c8a <release>
  return 0;
    80002ffa:	4501                	li	a0,0
}
    80002ffc:	70e2                	ld	ra,56(sp)
    80002ffe:	7442                	ld	s0,48(sp)
    80003000:	74a2                	ld	s1,40(sp)
    80003002:	7902                	ld	s2,32(sp)
    80003004:	69e2                	ld	s3,24(sp)
    80003006:	6121                	addi	sp,sp,64
    80003008:	8082                	ret
      release(&tickslock);
    8000300a:	00015517          	auipc	a0,0x15
    8000300e:	f6650513          	addi	a0,a0,-154 # 80017f70 <tickslock>
    80003012:	ffffe097          	auipc	ra,0xffffe
    80003016:	c78080e7          	jalr	-904(ra) # 80000c8a <release>
      return -1;
    8000301a:	557d                	li	a0,-1
    8000301c:	b7c5                	j	80002ffc <sys_sleep+0x88>

000000008000301e <sys_kill>:

uint64
sys_kill(void)
{
    8000301e:	1101                	addi	sp,sp,-32
    80003020:	ec06                	sd	ra,24(sp)
    80003022:	e822                	sd	s0,16(sp)
    80003024:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003026:	fec40593          	addi	a1,s0,-20
    8000302a:	4501                	li	a0,0
    8000302c:	00000097          	auipc	ra,0x0
    80003030:	d8a080e7          	jalr	-630(ra) # 80002db6 <argint>
  return kill(pid);
    80003034:	fec42503          	lw	a0,-20(s0)
    80003038:	fffff097          	auipc	ra,0xfffff
    8000303c:	2c6080e7          	jalr	710(ra) # 800022fe <kill>
}
    80003040:	60e2                	ld	ra,24(sp)
    80003042:	6442                	ld	s0,16(sp)
    80003044:	6105                	addi	sp,sp,32
    80003046:	8082                	ret

0000000080003048 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003048:	1101                	addi	sp,sp,-32
    8000304a:	ec06                	sd	ra,24(sp)
    8000304c:	e822                	sd	s0,16(sp)
    8000304e:	e426                	sd	s1,8(sp)
    80003050:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003052:	00015517          	auipc	a0,0x15
    80003056:	f1e50513          	addi	a0,a0,-226 # 80017f70 <tickslock>
    8000305a:	ffffe097          	auipc	ra,0xffffe
    8000305e:	b7c080e7          	jalr	-1156(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003062:	00006497          	auipc	s1,0x6
    80003066:	86e4a483          	lw	s1,-1938(s1) # 800088d0 <ticks>
  release(&tickslock);
    8000306a:	00015517          	auipc	a0,0x15
    8000306e:	f0650513          	addi	a0,a0,-250 # 80017f70 <tickslock>
    80003072:	ffffe097          	auipc	ra,0xffffe
    80003076:	c18080e7          	jalr	-1000(ra) # 80000c8a <release>
  return xticks;
}
    8000307a:	02049513          	slli	a0,s1,0x20
    8000307e:	9101                	srli	a0,a0,0x20
    80003080:	60e2                	ld	ra,24(sp)
    80003082:	6442                	ld	s0,16(sp)
    80003084:	64a2                	ld	s1,8(sp)
    80003086:	6105                	addi	sp,sp,32
    80003088:	8082                	ret

000000008000308a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000308a:	7179                	addi	sp,sp,-48
    8000308c:	f406                	sd	ra,40(sp)
    8000308e:	f022                	sd	s0,32(sp)
    80003090:	ec26                	sd	s1,24(sp)
    80003092:	e84a                	sd	s2,16(sp)
    80003094:	e44e                	sd	s3,8(sp)
    80003096:	e052                	sd	s4,0(sp)
    80003098:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000309a:	00005597          	auipc	a1,0x5
    8000309e:	45658593          	addi	a1,a1,1110 # 800084f0 <syscalls+0xb0>
    800030a2:	00015517          	auipc	a0,0x15
    800030a6:	ee650513          	addi	a0,a0,-282 # 80017f88 <bcache>
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	a9c080e7          	jalr	-1380(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030b2:	0001d797          	auipc	a5,0x1d
    800030b6:	ed678793          	addi	a5,a5,-298 # 8001ff88 <bcache+0x8000>
    800030ba:	0001d717          	auipc	a4,0x1d
    800030be:	13670713          	addi	a4,a4,310 # 800201f0 <bcache+0x8268>
    800030c2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030c6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ca:	00015497          	auipc	s1,0x15
    800030ce:	ed648493          	addi	s1,s1,-298 # 80017fa0 <bcache+0x18>
    b->next = bcache.head.next;
    800030d2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030d4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030d6:	00005a17          	auipc	s4,0x5
    800030da:	422a0a13          	addi	s4,s4,1058 # 800084f8 <syscalls+0xb8>
    b->next = bcache.head.next;
    800030de:	2b893783          	ld	a5,696(s2)
    800030e2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030e4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030e8:	85d2                	mv	a1,s4
    800030ea:	01048513          	addi	a0,s1,16
    800030ee:	00001097          	auipc	ra,0x1
    800030f2:	4c4080e7          	jalr	1220(ra) # 800045b2 <initsleeplock>
    bcache.head.next->prev = b;
    800030f6:	2b893783          	ld	a5,696(s2)
    800030fa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030fc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003100:	45848493          	addi	s1,s1,1112
    80003104:	fd349de3          	bne	s1,s3,800030de <binit+0x54>
  }
}
    80003108:	70a2                	ld	ra,40(sp)
    8000310a:	7402                	ld	s0,32(sp)
    8000310c:	64e2                	ld	s1,24(sp)
    8000310e:	6942                	ld	s2,16(sp)
    80003110:	69a2                	ld	s3,8(sp)
    80003112:	6a02                	ld	s4,0(sp)
    80003114:	6145                	addi	sp,sp,48
    80003116:	8082                	ret

0000000080003118 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003118:	7179                	addi	sp,sp,-48
    8000311a:	f406                	sd	ra,40(sp)
    8000311c:	f022                	sd	s0,32(sp)
    8000311e:	ec26                	sd	s1,24(sp)
    80003120:	e84a                	sd	s2,16(sp)
    80003122:	e44e                	sd	s3,8(sp)
    80003124:	1800                	addi	s0,sp,48
    80003126:	892a                	mv	s2,a0
    80003128:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000312a:	00015517          	auipc	a0,0x15
    8000312e:	e5e50513          	addi	a0,a0,-418 # 80017f88 <bcache>
    80003132:	ffffe097          	auipc	ra,0xffffe
    80003136:	aa4080e7          	jalr	-1372(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000313a:	0001d497          	auipc	s1,0x1d
    8000313e:	1064b483          	ld	s1,262(s1) # 80020240 <bcache+0x82b8>
    80003142:	0001d797          	auipc	a5,0x1d
    80003146:	0ae78793          	addi	a5,a5,174 # 800201f0 <bcache+0x8268>
    8000314a:	02f48f63          	beq	s1,a5,80003188 <bread+0x70>
    8000314e:	873e                	mv	a4,a5
    80003150:	a021                	j	80003158 <bread+0x40>
    80003152:	68a4                	ld	s1,80(s1)
    80003154:	02e48a63          	beq	s1,a4,80003188 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003158:	449c                	lw	a5,8(s1)
    8000315a:	ff279ce3          	bne	a5,s2,80003152 <bread+0x3a>
    8000315e:	44dc                	lw	a5,12(s1)
    80003160:	ff3799e3          	bne	a5,s3,80003152 <bread+0x3a>
      b->refcnt++;
    80003164:	40bc                	lw	a5,64(s1)
    80003166:	2785                	addiw	a5,a5,1
    80003168:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000316a:	00015517          	auipc	a0,0x15
    8000316e:	e1e50513          	addi	a0,a0,-482 # 80017f88 <bcache>
    80003172:	ffffe097          	auipc	ra,0xffffe
    80003176:	b18080e7          	jalr	-1256(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000317a:	01048513          	addi	a0,s1,16
    8000317e:	00001097          	auipc	ra,0x1
    80003182:	46e080e7          	jalr	1134(ra) # 800045ec <acquiresleep>
      return b;
    80003186:	a8b9                	j	800031e4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003188:	0001d497          	auipc	s1,0x1d
    8000318c:	0b04b483          	ld	s1,176(s1) # 80020238 <bcache+0x82b0>
    80003190:	0001d797          	auipc	a5,0x1d
    80003194:	06078793          	addi	a5,a5,96 # 800201f0 <bcache+0x8268>
    80003198:	00f48863          	beq	s1,a5,800031a8 <bread+0x90>
    8000319c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000319e:	40bc                	lw	a5,64(s1)
    800031a0:	cf81                	beqz	a5,800031b8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031a2:	64a4                	ld	s1,72(s1)
    800031a4:	fee49de3          	bne	s1,a4,8000319e <bread+0x86>
  panic("bget: no buffers");
    800031a8:	00005517          	auipc	a0,0x5
    800031ac:	35850513          	addi	a0,a0,856 # 80008500 <syscalls+0xc0>
    800031b0:	ffffd097          	auipc	ra,0xffffd
    800031b4:	38e080e7          	jalr	910(ra) # 8000053e <panic>
      b->dev = dev;
    800031b8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031bc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031c0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031c4:	4785                	li	a5,1
    800031c6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031c8:	00015517          	auipc	a0,0x15
    800031cc:	dc050513          	addi	a0,a0,-576 # 80017f88 <bcache>
    800031d0:	ffffe097          	auipc	ra,0xffffe
    800031d4:	aba080e7          	jalr	-1350(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031d8:	01048513          	addi	a0,s1,16
    800031dc:	00001097          	auipc	ra,0x1
    800031e0:	410080e7          	jalr	1040(ra) # 800045ec <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031e4:	409c                	lw	a5,0(s1)
    800031e6:	cb89                	beqz	a5,800031f8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031e8:	8526                	mv	a0,s1
    800031ea:	70a2                	ld	ra,40(sp)
    800031ec:	7402                	ld	s0,32(sp)
    800031ee:	64e2                	ld	s1,24(sp)
    800031f0:	6942                	ld	s2,16(sp)
    800031f2:	69a2                	ld	s3,8(sp)
    800031f4:	6145                	addi	sp,sp,48
    800031f6:	8082                	ret
    virtio_disk_rw(b, 0);
    800031f8:	4581                	li	a1,0
    800031fa:	8526                	mv	a0,s1
    800031fc:	00003097          	auipc	ra,0x3
    80003200:	ff8080e7          	jalr	-8(ra) # 800061f4 <virtio_disk_rw>
    b->valid = 1;
    80003204:	4785                	li	a5,1
    80003206:	c09c                	sw	a5,0(s1)
  return b;
    80003208:	b7c5                	j	800031e8 <bread+0xd0>

000000008000320a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000320a:	1101                	addi	sp,sp,-32
    8000320c:	ec06                	sd	ra,24(sp)
    8000320e:	e822                	sd	s0,16(sp)
    80003210:	e426                	sd	s1,8(sp)
    80003212:	1000                	addi	s0,sp,32
    80003214:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003216:	0541                	addi	a0,a0,16
    80003218:	00001097          	auipc	ra,0x1
    8000321c:	46e080e7          	jalr	1134(ra) # 80004686 <holdingsleep>
    80003220:	cd01                	beqz	a0,80003238 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003222:	4585                	li	a1,1
    80003224:	8526                	mv	a0,s1
    80003226:	00003097          	auipc	ra,0x3
    8000322a:	fce080e7          	jalr	-50(ra) # 800061f4 <virtio_disk_rw>
}
    8000322e:	60e2                	ld	ra,24(sp)
    80003230:	6442                	ld	s0,16(sp)
    80003232:	64a2                	ld	s1,8(sp)
    80003234:	6105                	addi	sp,sp,32
    80003236:	8082                	ret
    panic("bwrite");
    80003238:	00005517          	auipc	a0,0x5
    8000323c:	2e050513          	addi	a0,a0,736 # 80008518 <syscalls+0xd8>
    80003240:	ffffd097          	auipc	ra,0xffffd
    80003244:	2fe080e7          	jalr	766(ra) # 8000053e <panic>

0000000080003248 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003248:	1101                	addi	sp,sp,-32
    8000324a:	ec06                	sd	ra,24(sp)
    8000324c:	e822                	sd	s0,16(sp)
    8000324e:	e426                	sd	s1,8(sp)
    80003250:	e04a                	sd	s2,0(sp)
    80003252:	1000                	addi	s0,sp,32
    80003254:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003256:	01050913          	addi	s2,a0,16
    8000325a:	854a                	mv	a0,s2
    8000325c:	00001097          	auipc	ra,0x1
    80003260:	42a080e7          	jalr	1066(ra) # 80004686 <holdingsleep>
    80003264:	c92d                	beqz	a0,800032d6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003266:	854a                	mv	a0,s2
    80003268:	00001097          	auipc	ra,0x1
    8000326c:	3da080e7          	jalr	986(ra) # 80004642 <releasesleep>

  acquire(&bcache.lock);
    80003270:	00015517          	auipc	a0,0x15
    80003274:	d1850513          	addi	a0,a0,-744 # 80017f88 <bcache>
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	95e080e7          	jalr	-1698(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003280:	40bc                	lw	a5,64(s1)
    80003282:	37fd                	addiw	a5,a5,-1
    80003284:	0007871b          	sext.w	a4,a5
    80003288:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000328a:	eb05                	bnez	a4,800032ba <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000328c:	68bc                	ld	a5,80(s1)
    8000328e:	64b8                	ld	a4,72(s1)
    80003290:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003292:	64bc                	ld	a5,72(s1)
    80003294:	68b8                	ld	a4,80(s1)
    80003296:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003298:	0001d797          	auipc	a5,0x1d
    8000329c:	cf078793          	addi	a5,a5,-784 # 8001ff88 <bcache+0x8000>
    800032a0:	2b87b703          	ld	a4,696(a5)
    800032a4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032a6:	0001d717          	auipc	a4,0x1d
    800032aa:	f4a70713          	addi	a4,a4,-182 # 800201f0 <bcache+0x8268>
    800032ae:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032b0:	2b87b703          	ld	a4,696(a5)
    800032b4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032b6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032ba:	00015517          	auipc	a0,0x15
    800032be:	cce50513          	addi	a0,a0,-818 # 80017f88 <bcache>
    800032c2:	ffffe097          	auipc	ra,0xffffe
    800032c6:	9c8080e7          	jalr	-1592(ra) # 80000c8a <release>
}
    800032ca:	60e2                	ld	ra,24(sp)
    800032cc:	6442                	ld	s0,16(sp)
    800032ce:	64a2                	ld	s1,8(sp)
    800032d0:	6902                	ld	s2,0(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret
    panic("brelse");
    800032d6:	00005517          	auipc	a0,0x5
    800032da:	24a50513          	addi	a0,a0,586 # 80008520 <syscalls+0xe0>
    800032de:	ffffd097          	auipc	ra,0xffffd
    800032e2:	260080e7          	jalr	608(ra) # 8000053e <panic>

00000000800032e6 <bpin>:

void
bpin(struct buf *b) {
    800032e6:	1101                	addi	sp,sp,-32
    800032e8:	ec06                	sd	ra,24(sp)
    800032ea:	e822                	sd	s0,16(sp)
    800032ec:	e426                	sd	s1,8(sp)
    800032ee:	1000                	addi	s0,sp,32
    800032f0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032f2:	00015517          	auipc	a0,0x15
    800032f6:	c9650513          	addi	a0,a0,-874 # 80017f88 <bcache>
    800032fa:	ffffe097          	auipc	ra,0xffffe
    800032fe:	8dc080e7          	jalr	-1828(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003302:	40bc                	lw	a5,64(s1)
    80003304:	2785                	addiw	a5,a5,1
    80003306:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003308:	00015517          	auipc	a0,0x15
    8000330c:	c8050513          	addi	a0,a0,-896 # 80017f88 <bcache>
    80003310:	ffffe097          	auipc	ra,0xffffe
    80003314:	97a080e7          	jalr	-1670(ra) # 80000c8a <release>
}
    80003318:	60e2                	ld	ra,24(sp)
    8000331a:	6442                	ld	s0,16(sp)
    8000331c:	64a2                	ld	s1,8(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret

0000000080003322 <bunpin>:

void
bunpin(struct buf *b) {
    80003322:	1101                	addi	sp,sp,-32
    80003324:	ec06                	sd	ra,24(sp)
    80003326:	e822                	sd	s0,16(sp)
    80003328:	e426                	sd	s1,8(sp)
    8000332a:	1000                	addi	s0,sp,32
    8000332c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000332e:	00015517          	auipc	a0,0x15
    80003332:	c5a50513          	addi	a0,a0,-934 # 80017f88 <bcache>
    80003336:	ffffe097          	auipc	ra,0xffffe
    8000333a:	8a0080e7          	jalr	-1888(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000333e:	40bc                	lw	a5,64(s1)
    80003340:	37fd                	addiw	a5,a5,-1
    80003342:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003344:	00015517          	auipc	a0,0x15
    80003348:	c4450513          	addi	a0,a0,-956 # 80017f88 <bcache>
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	93e080e7          	jalr	-1730(ra) # 80000c8a <release>
}
    80003354:	60e2                	ld	ra,24(sp)
    80003356:	6442                	ld	s0,16(sp)
    80003358:	64a2                	ld	s1,8(sp)
    8000335a:	6105                	addi	sp,sp,32
    8000335c:	8082                	ret

000000008000335e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000335e:	1101                	addi	sp,sp,-32
    80003360:	ec06                	sd	ra,24(sp)
    80003362:	e822                	sd	s0,16(sp)
    80003364:	e426                	sd	s1,8(sp)
    80003366:	e04a                	sd	s2,0(sp)
    80003368:	1000                	addi	s0,sp,32
    8000336a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000336c:	00d5d59b          	srliw	a1,a1,0xd
    80003370:	0001d797          	auipc	a5,0x1d
    80003374:	2f47a783          	lw	a5,756(a5) # 80020664 <sb+0x1c>
    80003378:	9dbd                	addw	a1,a1,a5
    8000337a:	00000097          	auipc	ra,0x0
    8000337e:	d9e080e7          	jalr	-610(ra) # 80003118 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003382:	0074f713          	andi	a4,s1,7
    80003386:	4785                	li	a5,1
    80003388:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000338c:	14ce                	slli	s1,s1,0x33
    8000338e:	90d9                	srli	s1,s1,0x36
    80003390:	00950733          	add	a4,a0,s1
    80003394:	05874703          	lbu	a4,88(a4)
    80003398:	00e7f6b3          	and	a3,a5,a4
    8000339c:	c69d                	beqz	a3,800033ca <bfree+0x6c>
    8000339e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033a0:	94aa                	add	s1,s1,a0
    800033a2:	fff7c793          	not	a5,a5
    800033a6:	8ff9                	and	a5,a5,a4
    800033a8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800033ac:	00001097          	auipc	ra,0x1
    800033b0:	120080e7          	jalr	288(ra) # 800044cc <log_write>
  brelse(bp);
    800033b4:	854a                	mv	a0,s2
    800033b6:	00000097          	auipc	ra,0x0
    800033ba:	e92080e7          	jalr	-366(ra) # 80003248 <brelse>
}
    800033be:	60e2                	ld	ra,24(sp)
    800033c0:	6442                	ld	s0,16(sp)
    800033c2:	64a2                	ld	s1,8(sp)
    800033c4:	6902                	ld	s2,0(sp)
    800033c6:	6105                	addi	sp,sp,32
    800033c8:	8082                	ret
    panic("freeing free block");
    800033ca:	00005517          	auipc	a0,0x5
    800033ce:	15e50513          	addi	a0,a0,350 # 80008528 <syscalls+0xe8>
    800033d2:	ffffd097          	auipc	ra,0xffffd
    800033d6:	16c080e7          	jalr	364(ra) # 8000053e <panic>

00000000800033da <balloc>:
{
    800033da:	711d                	addi	sp,sp,-96
    800033dc:	ec86                	sd	ra,88(sp)
    800033de:	e8a2                	sd	s0,80(sp)
    800033e0:	e4a6                	sd	s1,72(sp)
    800033e2:	e0ca                	sd	s2,64(sp)
    800033e4:	fc4e                	sd	s3,56(sp)
    800033e6:	f852                	sd	s4,48(sp)
    800033e8:	f456                	sd	s5,40(sp)
    800033ea:	f05a                	sd	s6,32(sp)
    800033ec:	ec5e                	sd	s7,24(sp)
    800033ee:	e862                	sd	s8,16(sp)
    800033f0:	e466                	sd	s9,8(sp)
    800033f2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033f4:	0001d797          	auipc	a5,0x1d
    800033f8:	2587a783          	lw	a5,600(a5) # 8002064c <sb+0x4>
    800033fc:	10078163          	beqz	a5,800034fe <balloc+0x124>
    80003400:	8baa                	mv	s7,a0
    80003402:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003404:	0001db17          	auipc	s6,0x1d
    80003408:	244b0b13          	addi	s6,s6,580 # 80020648 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000340c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000340e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003410:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003412:	6c89                	lui	s9,0x2
    80003414:	a061                	j	8000349c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003416:	974a                	add	a4,a4,s2
    80003418:	8fd5                	or	a5,a5,a3
    8000341a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000341e:	854a                	mv	a0,s2
    80003420:	00001097          	auipc	ra,0x1
    80003424:	0ac080e7          	jalr	172(ra) # 800044cc <log_write>
        brelse(bp);
    80003428:	854a                	mv	a0,s2
    8000342a:	00000097          	auipc	ra,0x0
    8000342e:	e1e080e7          	jalr	-482(ra) # 80003248 <brelse>
  bp = bread(dev, bno);
    80003432:	85a6                	mv	a1,s1
    80003434:	855e                	mv	a0,s7
    80003436:	00000097          	auipc	ra,0x0
    8000343a:	ce2080e7          	jalr	-798(ra) # 80003118 <bread>
    8000343e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003440:	40000613          	li	a2,1024
    80003444:	4581                	li	a1,0
    80003446:	05850513          	addi	a0,a0,88
    8000344a:	ffffe097          	auipc	ra,0xffffe
    8000344e:	888080e7          	jalr	-1912(ra) # 80000cd2 <memset>
  log_write(bp);
    80003452:	854a                	mv	a0,s2
    80003454:	00001097          	auipc	ra,0x1
    80003458:	078080e7          	jalr	120(ra) # 800044cc <log_write>
  brelse(bp);
    8000345c:	854a                	mv	a0,s2
    8000345e:	00000097          	auipc	ra,0x0
    80003462:	dea080e7          	jalr	-534(ra) # 80003248 <brelse>
}
    80003466:	8526                	mv	a0,s1
    80003468:	60e6                	ld	ra,88(sp)
    8000346a:	6446                	ld	s0,80(sp)
    8000346c:	64a6                	ld	s1,72(sp)
    8000346e:	6906                	ld	s2,64(sp)
    80003470:	79e2                	ld	s3,56(sp)
    80003472:	7a42                	ld	s4,48(sp)
    80003474:	7aa2                	ld	s5,40(sp)
    80003476:	7b02                	ld	s6,32(sp)
    80003478:	6be2                	ld	s7,24(sp)
    8000347a:	6c42                	ld	s8,16(sp)
    8000347c:	6ca2                	ld	s9,8(sp)
    8000347e:	6125                	addi	sp,sp,96
    80003480:	8082                	ret
    brelse(bp);
    80003482:	854a                	mv	a0,s2
    80003484:	00000097          	auipc	ra,0x0
    80003488:	dc4080e7          	jalr	-572(ra) # 80003248 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000348c:	015c87bb          	addw	a5,s9,s5
    80003490:	00078a9b          	sext.w	s5,a5
    80003494:	004b2703          	lw	a4,4(s6)
    80003498:	06eaf363          	bgeu	s5,a4,800034fe <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000349c:	41fad79b          	sraiw	a5,s5,0x1f
    800034a0:	0137d79b          	srliw	a5,a5,0x13
    800034a4:	015787bb          	addw	a5,a5,s5
    800034a8:	40d7d79b          	sraiw	a5,a5,0xd
    800034ac:	01cb2583          	lw	a1,28(s6)
    800034b0:	9dbd                	addw	a1,a1,a5
    800034b2:	855e                	mv	a0,s7
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	c64080e7          	jalr	-924(ra) # 80003118 <bread>
    800034bc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034be:	004b2503          	lw	a0,4(s6)
    800034c2:	000a849b          	sext.w	s1,s5
    800034c6:	8662                	mv	a2,s8
    800034c8:	faa4fde3          	bgeu	s1,a0,80003482 <balloc+0xa8>
      m = 1 << (bi % 8);
    800034cc:	41f6579b          	sraiw	a5,a2,0x1f
    800034d0:	01d7d69b          	srliw	a3,a5,0x1d
    800034d4:	00c6873b          	addw	a4,a3,a2
    800034d8:	00777793          	andi	a5,a4,7
    800034dc:	9f95                	subw	a5,a5,a3
    800034de:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034e2:	4037571b          	sraiw	a4,a4,0x3
    800034e6:	00e906b3          	add	a3,s2,a4
    800034ea:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    800034ee:	00d7f5b3          	and	a1,a5,a3
    800034f2:	d195                	beqz	a1,80003416 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034f4:	2605                	addiw	a2,a2,1
    800034f6:	2485                	addiw	s1,s1,1
    800034f8:	fd4618e3          	bne	a2,s4,800034c8 <balloc+0xee>
    800034fc:	b759                	j	80003482 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800034fe:	00005517          	auipc	a0,0x5
    80003502:	04250513          	addi	a0,a0,66 # 80008540 <syscalls+0x100>
    80003506:	ffffd097          	auipc	ra,0xffffd
    8000350a:	082080e7          	jalr	130(ra) # 80000588 <printf>
  return 0;
    8000350e:	4481                	li	s1,0
    80003510:	bf99                	j	80003466 <balloc+0x8c>

0000000080003512 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003512:	7179                	addi	sp,sp,-48
    80003514:	f406                	sd	ra,40(sp)
    80003516:	f022                	sd	s0,32(sp)
    80003518:	ec26                	sd	s1,24(sp)
    8000351a:	e84a                	sd	s2,16(sp)
    8000351c:	e44e                	sd	s3,8(sp)
    8000351e:	e052                	sd	s4,0(sp)
    80003520:	1800                	addi	s0,sp,48
    80003522:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003524:	47ad                	li	a5,11
    80003526:	02b7e763          	bltu	a5,a1,80003554 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000352a:	02059493          	slli	s1,a1,0x20
    8000352e:	9081                	srli	s1,s1,0x20
    80003530:	048a                	slli	s1,s1,0x2
    80003532:	94aa                	add	s1,s1,a0
    80003534:	0504a903          	lw	s2,80(s1)
    80003538:	06091e63          	bnez	s2,800035b4 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000353c:	4108                	lw	a0,0(a0)
    8000353e:	00000097          	auipc	ra,0x0
    80003542:	e9c080e7          	jalr	-356(ra) # 800033da <balloc>
    80003546:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000354a:	06090563          	beqz	s2,800035b4 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000354e:	0524a823          	sw	s2,80(s1)
    80003552:	a08d                	j	800035b4 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003554:	ff45849b          	addiw	s1,a1,-12
    80003558:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000355c:	0ff00793          	li	a5,255
    80003560:	08e7e563          	bltu	a5,a4,800035ea <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003564:	08052903          	lw	s2,128(a0)
    80003568:	00091d63          	bnez	s2,80003582 <bmap+0x70>
      addr = balloc(ip->dev);
    8000356c:	4108                	lw	a0,0(a0)
    8000356e:	00000097          	auipc	ra,0x0
    80003572:	e6c080e7          	jalr	-404(ra) # 800033da <balloc>
    80003576:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000357a:	02090d63          	beqz	s2,800035b4 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000357e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003582:	85ca                	mv	a1,s2
    80003584:	0009a503          	lw	a0,0(s3)
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	b90080e7          	jalr	-1136(ra) # 80003118 <bread>
    80003590:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003592:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003596:	02049593          	slli	a1,s1,0x20
    8000359a:	9181                	srli	a1,a1,0x20
    8000359c:	058a                	slli	a1,a1,0x2
    8000359e:	00b784b3          	add	s1,a5,a1
    800035a2:	0004a903          	lw	s2,0(s1)
    800035a6:	02090063          	beqz	s2,800035c6 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035aa:	8552                	mv	a0,s4
    800035ac:	00000097          	auipc	ra,0x0
    800035b0:	c9c080e7          	jalr	-868(ra) # 80003248 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800035b4:	854a                	mv	a0,s2
    800035b6:	70a2                	ld	ra,40(sp)
    800035b8:	7402                	ld	s0,32(sp)
    800035ba:	64e2                	ld	s1,24(sp)
    800035bc:	6942                	ld	s2,16(sp)
    800035be:	69a2                	ld	s3,8(sp)
    800035c0:	6a02                	ld	s4,0(sp)
    800035c2:	6145                	addi	sp,sp,48
    800035c4:	8082                	ret
      addr = balloc(ip->dev);
    800035c6:	0009a503          	lw	a0,0(s3)
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	e10080e7          	jalr	-496(ra) # 800033da <balloc>
    800035d2:	0005091b          	sext.w	s2,a0
      if(addr){
    800035d6:	fc090ae3          	beqz	s2,800035aa <bmap+0x98>
        a[bn] = addr;
    800035da:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035de:	8552                	mv	a0,s4
    800035e0:	00001097          	auipc	ra,0x1
    800035e4:	eec080e7          	jalr	-276(ra) # 800044cc <log_write>
    800035e8:	b7c9                	j	800035aa <bmap+0x98>
  panic("bmap: out of range");
    800035ea:	00005517          	auipc	a0,0x5
    800035ee:	f6e50513          	addi	a0,a0,-146 # 80008558 <syscalls+0x118>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	f4c080e7          	jalr	-180(ra) # 8000053e <panic>

00000000800035fa <iget>:
{
    800035fa:	7179                	addi	sp,sp,-48
    800035fc:	f406                	sd	ra,40(sp)
    800035fe:	f022                	sd	s0,32(sp)
    80003600:	ec26                	sd	s1,24(sp)
    80003602:	e84a                	sd	s2,16(sp)
    80003604:	e44e                	sd	s3,8(sp)
    80003606:	e052                	sd	s4,0(sp)
    80003608:	1800                	addi	s0,sp,48
    8000360a:	89aa                	mv	s3,a0
    8000360c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000360e:	0001d517          	auipc	a0,0x1d
    80003612:	05a50513          	addi	a0,a0,90 # 80020668 <itable>
    80003616:	ffffd097          	auipc	ra,0xffffd
    8000361a:	5c0080e7          	jalr	1472(ra) # 80000bd6 <acquire>
  empty = 0;
    8000361e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003620:	0001d497          	auipc	s1,0x1d
    80003624:	06048493          	addi	s1,s1,96 # 80020680 <itable+0x18>
    80003628:	0001f697          	auipc	a3,0x1f
    8000362c:	ae868693          	addi	a3,a3,-1304 # 80022110 <log>
    80003630:	a039                	j	8000363e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003632:	02090b63          	beqz	s2,80003668 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003636:	08848493          	addi	s1,s1,136
    8000363a:	02d48a63          	beq	s1,a3,8000366e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000363e:	449c                	lw	a5,8(s1)
    80003640:	fef059e3          	blez	a5,80003632 <iget+0x38>
    80003644:	4098                	lw	a4,0(s1)
    80003646:	ff3716e3          	bne	a4,s3,80003632 <iget+0x38>
    8000364a:	40d8                	lw	a4,4(s1)
    8000364c:	ff4713e3          	bne	a4,s4,80003632 <iget+0x38>
      ip->ref++;
    80003650:	2785                	addiw	a5,a5,1
    80003652:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003654:	0001d517          	auipc	a0,0x1d
    80003658:	01450513          	addi	a0,a0,20 # 80020668 <itable>
    8000365c:	ffffd097          	auipc	ra,0xffffd
    80003660:	62e080e7          	jalr	1582(ra) # 80000c8a <release>
      return ip;
    80003664:	8926                	mv	s2,s1
    80003666:	a03d                	j	80003694 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003668:	f7f9                	bnez	a5,80003636 <iget+0x3c>
    8000366a:	8926                	mv	s2,s1
    8000366c:	b7e9                	j	80003636 <iget+0x3c>
  if(empty == 0)
    8000366e:	02090c63          	beqz	s2,800036a6 <iget+0xac>
  ip->dev = dev;
    80003672:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003676:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000367a:	4785                	li	a5,1
    8000367c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003680:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003684:	0001d517          	auipc	a0,0x1d
    80003688:	fe450513          	addi	a0,a0,-28 # 80020668 <itable>
    8000368c:	ffffd097          	auipc	ra,0xffffd
    80003690:	5fe080e7          	jalr	1534(ra) # 80000c8a <release>
}
    80003694:	854a                	mv	a0,s2
    80003696:	70a2                	ld	ra,40(sp)
    80003698:	7402                	ld	s0,32(sp)
    8000369a:	64e2                	ld	s1,24(sp)
    8000369c:	6942                	ld	s2,16(sp)
    8000369e:	69a2                	ld	s3,8(sp)
    800036a0:	6a02                	ld	s4,0(sp)
    800036a2:	6145                	addi	sp,sp,48
    800036a4:	8082                	ret
    panic("iget: no inodes");
    800036a6:	00005517          	auipc	a0,0x5
    800036aa:	eca50513          	addi	a0,a0,-310 # 80008570 <syscalls+0x130>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	e90080e7          	jalr	-368(ra) # 8000053e <panic>

00000000800036b6 <fsinit>:
fsinit(int dev) {
    800036b6:	7179                	addi	sp,sp,-48
    800036b8:	f406                	sd	ra,40(sp)
    800036ba:	f022                	sd	s0,32(sp)
    800036bc:	ec26                	sd	s1,24(sp)
    800036be:	e84a                	sd	s2,16(sp)
    800036c0:	e44e                	sd	s3,8(sp)
    800036c2:	1800                	addi	s0,sp,48
    800036c4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036c6:	4585                	li	a1,1
    800036c8:	00000097          	auipc	ra,0x0
    800036cc:	a50080e7          	jalr	-1456(ra) # 80003118 <bread>
    800036d0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036d2:	0001d997          	auipc	s3,0x1d
    800036d6:	f7698993          	addi	s3,s3,-138 # 80020648 <sb>
    800036da:	02000613          	li	a2,32
    800036de:	05850593          	addi	a1,a0,88
    800036e2:	854e                	mv	a0,s3
    800036e4:	ffffd097          	auipc	ra,0xffffd
    800036e8:	64a080e7          	jalr	1610(ra) # 80000d2e <memmove>
  brelse(bp);
    800036ec:	8526                	mv	a0,s1
    800036ee:	00000097          	auipc	ra,0x0
    800036f2:	b5a080e7          	jalr	-1190(ra) # 80003248 <brelse>
  if(sb.magic != FSMAGIC)
    800036f6:	0009a703          	lw	a4,0(s3)
    800036fa:	102037b7          	lui	a5,0x10203
    800036fe:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003702:	02f71263          	bne	a4,a5,80003726 <fsinit+0x70>
  initlog(dev, &sb);
    80003706:	0001d597          	auipc	a1,0x1d
    8000370a:	f4258593          	addi	a1,a1,-190 # 80020648 <sb>
    8000370e:	854a                	mv	a0,s2
    80003710:	00001097          	auipc	ra,0x1
    80003714:	b40080e7          	jalr	-1216(ra) # 80004250 <initlog>
}
    80003718:	70a2                	ld	ra,40(sp)
    8000371a:	7402                	ld	s0,32(sp)
    8000371c:	64e2                	ld	s1,24(sp)
    8000371e:	6942                	ld	s2,16(sp)
    80003720:	69a2                	ld	s3,8(sp)
    80003722:	6145                	addi	sp,sp,48
    80003724:	8082                	ret
    panic("invalid file system");
    80003726:	00005517          	auipc	a0,0x5
    8000372a:	e5a50513          	addi	a0,a0,-422 # 80008580 <syscalls+0x140>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	e10080e7          	jalr	-496(ra) # 8000053e <panic>

0000000080003736 <iinit>:
{
    80003736:	7179                	addi	sp,sp,-48
    80003738:	f406                	sd	ra,40(sp)
    8000373a:	f022                	sd	s0,32(sp)
    8000373c:	ec26                	sd	s1,24(sp)
    8000373e:	e84a                	sd	s2,16(sp)
    80003740:	e44e                	sd	s3,8(sp)
    80003742:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003744:	00005597          	auipc	a1,0x5
    80003748:	e5458593          	addi	a1,a1,-428 # 80008598 <syscalls+0x158>
    8000374c:	0001d517          	auipc	a0,0x1d
    80003750:	f1c50513          	addi	a0,a0,-228 # 80020668 <itable>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	3f2080e7          	jalr	1010(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000375c:	0001d497          	auipc	s1,0x1d
    80003760:	f3448493          	addi	s1,s1,-204 # 80020690 <itable+0x28>
    80003764:	0001f997          	auipc	s3,0x1f
    80003768:	9bc98993          	addi	s3,s3,-1604 # 80022120 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000376c:	00005917          	auipc	s2,0x5
    80003770:	e3490913          	addi	s2,s2,-460 # 800085a0 <syscalls+0x160>
    80003774:	85ca                	mv	a1,s2
    80003776:	8526                	mv	a0,s1
    80003778:	00001097          	auipc	ra,0x1
    8000377c:	e3a080e7          	jalr	-454(ra) # 800045b2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003780:	08848493          	addi	s1,s1,136
    80003784:	ff3498e3          	bne	s1,s3,80003774 <iinit+0x3e>
}
    80003788:	70a2                	ld	ra,40(sp)
    8000378a:	7402                	ld	s0,32(sp)
    8000378c:	64e2                	ld	s1,24(sp)
    8000378e:	6942                	ld	s2,16(sp)
    80003790:	69a2                	ld	s3,8(sp)
    80003792:	6145                	addi	sp,sp,48
    80003794:	8082                	ret

0000000080003796 <ialloc>:
{
    80003796:	715d                	addi	sp,sp,-80
    80003798:	e486                	sd	ra,72(sp)
    8000379a:	e0a2                	sd	s0,64(sp)
    8000379c:	fc26                	sd	s1,56(sp)
    8000379e:	f84a                	sd	s2,48(sp)
    800037a0:	f44e                	sd	s3,40(sp)
    800037a2:	f052                	sd	s4,32(sp)
    800037a4:	ec56                	sd	s5,24(sp)
    800037a6:	e85a                	sd	s6,16(sp)
    800037a8:	e45e                	sd	s7,8(sp)
    800037aa:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037ac:	0001d717          	auipc	a4,0x1d
    800037b0:	ea872703          	lw	a4,-344(a4) # 80020654 <sb+0xc>
    800037b4:	4785                	li	a5,1
    800037b6:	04e7fa63          	bgeu	a5,a4,8000380a <ialloc+0x74>
    800037ba:	8aaa                	mv	s5,a0
    800037bc:	8bae                	mv	s7,a1
    800037be:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037c0:	0001da17          	auipc	s4,0x1d
    800037c4:	e88a0a13          	addi	s4,s4,-376 # 80020648 <sb>
    800037c8:	00048b1b          	sext.w	s6,s1
    800037cc:	0044d793          	srli	a5,s1,0x4
    800037d0:	018a2583          	lw	a1,24(s4)
    800037d4:	9dbd                	addw	a1,a1,a5
    800037d6:	8556                	mv	a0,s5
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	940080e7          	jalr	-1728(ra) # 80003118 <bread>
    800037e0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037e2:	05850993          	addi	s3,a0,88
    800037e6:	00f4f793          	andi	a5,s1,15
    800037ea:	079a                	slli	a5,a5,0x6
    800037ec:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037ee:	00099783          	lh	a5,0(s3)
    800037f2:	c3a1                	beqz	a5,80003832 <ialloc+0x9c>
    brelse(bp);
    800037f4:	00000097          	auipc	ra,0x0
    800037f8:	a54080e7          	jalr	-1452(ra) # 80003248 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037fc:	0485                	addi	s1,s1,1
    800037fe:	00ca2703          	lw	a4,12(s4)
    80003802:	0004879b          	sext.w	a5,s1
    80003806:	fce7e1e3          	bltu	a5,a4,800037c8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000380a:	00005517          	auipc	a0,0x5
    8000380e:	d9e50513          	addi	a0,a0,-610 # 800085a8 <syscalls+0x168>
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	d76080e7          	jalr	-650(ra) # 80000588 <printf>
  return 0;
    8000381a:	4501                	li	a0,0
}
    8000381c:	60a6                	ld	ra,72(sp)
    8000381e:	6406                	ld	s0,64(sp)
    80003820:	74e2                	ld	s1,56(sp)
    80003822:	7942                	ld	s2,48(sp)
    80003824:	79a2                	ld	s3,40(sp)
    80003826:	7a02                	ld	s4,32(sp)
    80003828:	6ae2                	ld	s5,24(sp)
    8000382a:	6b42                	ld	s6,16(sp)
    8000382c:	6ba2                	ld	s7,8(sp)
    8000382e:	6161                	addi	sp,sp,80
    80003830:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003832:	04000613          	li	a2,64
    80003836:	4581                	li	a1,0
    80003838:	854e                	mv	a0,s3
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	498080e7          	jalr	1176(ra) # 80000cd2 <memset>
      dip->type = type;
    80003842:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003846:	854a                	mv	a0,s2
    80003848:	00001097          	auipc	ra,0x1
    8000384c:	c84080e7          	jalr	-892(ra) # 800044cc <log_write>
      brelse(bp);
    80003850:	854a                	mv	a0,s2
    80003852:	00000097          	auipc	ra,0x0
    80003856:	9f6080e7          	jalr	-1546(ra) # 80003248 <brelse>
      return iget(dev, inum);
    8000385a:	85da                	mv	a1,s6
    8000385c:	8556                	mv	a0,s5
    8000385e:	00000097          	auipc	ra,0x0
    80003862:	d9c080e7          	jalr	-612(ra) # 800035fa <iget>
    80003866:	bf5d                	j	8000381c <ialloc+0x86>

0000000080003868 <iupdate>:
{
    80003868:	1101                	addi	sp,sp,-32
    8000386a:	ec06                	sd	ra,24(sp)
    8000386c:	e822                	sd	s0,16(sp)
    8000386e:	e426                	sd	s1,8(sp)
    80003870:	e04a                	sd	s2,0(sp)
    80003872:	1000                	addi	s0,sp,32
    80003874:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003876:	415c                	lw	a5,4(a0)
    80003878:	0047d79b          	srliw	a5,a5,0x4
    8000387c:	0001d597          	auipc	a1,0x1d
    80003880:	de45a583          	lw	a1,-540(a1) # 80020660 <sb+0x18>
    80003884:	9dbd                	addw	a1,a1,a5
    80003886:	4108                	lw	a0,0(a0)
    80003888:	00000097          	auipc	ra,0x0
    8000388c:	890080e7          	jalr	-1904(ra) # 80003118 <bread>
    80003890:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003892:	05850793          	addi	a5,a0,88
    80003896:	40c8                	lw	a0,4(s1)
    80003898:	893d                	andi	a0,a0,15
    8000389a:	051a                	slli	a0,a0,0x6
    8000389c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000389e:	04449703          	lh	a4,68(s1)
    800038a2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038a6:	04649703          	lh	a4,70(s1)
    800038aa:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038ae:	04849703          	lh	a4,72(s1)
    800038b2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038b6:	04a49703          	lh	a4,74(s1)
    800038ba:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038be:	44f8                	lw	a4,76(s1)
    800038c0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038c2:	03400613          	li	a2,52
    800038c6:	05048593          	addi	a1,s1,80
    800038ca:	0531                	addi	a0,a0,12
    800038cc:	ffffd097          	auipc	ra,0xffffd
    800038d0:	462080e7          	jalr	1122(ra) # 80000d2e <memmove>
  log_write(bp);
    800038d4:	854a                	mv	a0,s2
    800038d6:	00001097          	auipc	ra,0x1
    800038da:	bf6080e7          	jalr	-1034(ra) # 800044cc <log_write>
  brelse(bp);
    800038de:	854a                	mv	a0,s2
    800038e0:	00000097          	auipc	ra,0x0
    800038e4:	968080e7          	jalr	-1688(ra) # 80003248 <brelse>
}
    800038e8:	60e2                	ld	ra,24(sp)
    800038ea:	6442                	ld	s0,16(sp)
    800038ec:	64a2                	ld	s1,8(sp)
    800038ee:	6902                	ld	s2,0(sp)
    800038f0:	6105                	addi	sp,sp,32
    800038f2:	8082                	ret

00000000800038f4 <idup>:
{
    800038f4:	1101                	addi	sp,sp,-32
    800038f6:	ec06                	sd	ra,24(sp)
    800038f8:	e822                	sd	s0,16(sp)
    800038fa:	e426                	sd	s1,8(sp)
    800038fc:	1000                	addi	s0,sp,32
    800038fe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003900:	0001d517          	auipc	a0,0x1d
    80003904:	d6850513          	addi	a0,a0,-664 # 80020668 <itable>
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	2ce080e7          	jalr	718(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003910:	449c                	lw	a5,8(s1)
    80003912:	2785                	addiw	a5,a5,1
    80003914:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003916:	0001d517          	auipc	a0,0x1d
    8000391a:	d5250513          	addi	a0,a0,-686 # 80020668 <itable>
    8000391e:	ffffd097          	auipc	ra,0xffffd
    80003922:	36c080e7          	jalr	876(ra) # 80000c8a <release>
}
    80003926:	8526                	mv	a0,s1
    80003928:	60e2                	ld	ra,24(sp)
    8000392a:	6442                	ld	s0,16(sp)
    8000392c:	64a2                	ld	s1,8(sp)
    8000392e:	6105                	addi	sp,sp,32
    80003930:	8082                	ret

0000000080003932 <ilock>:
{
    80003932:	1101                	addi	sp,sp,-32
    80003934:	ec06                	sd	ra,24(sp)
    80003936:	e822                	sd	s0,16(sp)
    80003938:	e426                	sd	s1,8(sp)
    8000393a:	e04a                	sd	s2,0(sp)
    8000393c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000393e:	c115                	beqz	a0,80003962 <ilock+0x30>
    80003940:	84aa                	mv	s1,a0
    80003942:	451c                	lw	a5,8(a0)
    80003944:	00f05f63          	blez	a5,80003962 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003948:	0541                	addi	a0,a0,16
    8000394a:	00001097          	auipc	ra,0x1
    8000394e:	ca2080e7          	jalr	-862(ra) # 800045ec <acquiresleep>
  if(ip->valid == 0){
    80003952:	40bc                	lw	a5,64(s1)
    80003954:	cf99                	beqz	a5,80003972 <ilock+0x40>
}
    80003956:	60e2                	ld	ra,24(sp)
    80003958:	6442                	ld	s0,16(sp)
    8000395a:	64a2                	ld	s1,8(sp)
    8000395c:	6902                	ld	s2,0(sp)
    8000395e:	6105                	addi	sp,sp,32
    80003960:	8082                	ret
    panic("ilock");
    80003962:	00005517          	auipc	a0,0x5
    80003966:	c5e50513          	addi	a0,a0,-930 # 800085c0 <syscalls+0x180>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	bd4080e7          	jalr	-1068(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003972:	40dc                	lw	a5,4(s1)
    80003974:	0047d79b          	srliw	a5,a5,0x4
    80003978:	0001d597          	auipc	a1,0x1d
    8000397c:	ce85a583          	lw	a1,-792(a1) # 80020660 <sb+0x18>
    80003980:	9dbd                	addw	a1,a1,a5
    80003982:	4088                	lw	a0,0(s1)
    80003984:	fffff097          	auipc	ra,0xfffff
    80003988:	794080e7          	jalr	1940(ra) # 80003118 <bread>
    8000398c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000398e:	05850593          	addi	a1,a0,88
    80003992:	40dc                	lw	a5,4(s1)
    80003994:	8bbd                	andi	a5,a5,15
    80003996:	079a                	slli	a5,a5,0x6
    80003998:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000399a:	00059783          	lh	a5,0(a1)
    8000399e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039a2:	00259783          	lh	a5,2(a1)
    800039a6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039aa:	00459783          	lh	a5,4(a1)
    800039ae:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039b2:	00659783          	lh	a5,6(a1)
    800039b6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039ba:	459c                	lw	a5,8(a1)
    800039bc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039be:	03400613          	li	a2,52
    800039c2:	05b1                	addi	a1,a1,12
    800039c4:	05048513          	addi	a0,s1,80
    800039c8:	ffffd097          	auipc	ra,0xffffd
    800039cc:	366080e7          	jalr	870(ra) # 80000d2e <memmove>
    brelse(bp);
    800039d0:	854a                	mv	a0,s2
    800039d2:	00000097          	auipc	ra,0x0
    800039d6:	876080e7          	jalr	-1930(ra) # 80003248 <brelse>
    ip->valid = 1;
    800039da:	4785                	li	a5,1
    800039dc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039de:	04449783          	lh	a5,68(s1)
    800039e2:	fbb5                	bnez	a5,80003956 <ilock+0x24>
      panic("ilock: no type");
    800039e4:	00005517          	auipc	a0,0x5
    800039e8:	be450513          	addi	a0,a0,-1052 # 800085c8 <syscalls+0x188>
    800039ec:	ffffd097          	auipc	ra,0xffffd
    800039f0:	b52080e7          	jalr	-1198(ra) # 8000053e <panic>

00000000800039f4 <iunlock>:
{
    800039f4:	1101                	addi	sp,sp,-32
    800039f6:	ec06                	sd	ra,24(sp)
    800039f8:	e822                	sd	s0,16(sp)
    800039fa:	e426                	sd	s1,8(sp)
    800039fc:	e04a                	sd	s2,0(sp)
    800039fe:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a00:	c905                	beqz	a0,80003a30 <iunlock+0x3c>
    80003a02:	84aa                	mv	s1,a0
    80003a04:	01050913          	addi	s2,a0,16
    80003a08:	854a                	mv	a0,s2
    80003a0a:	00001097          	auipc	ra,0x1
    80003a0e:	c7c080e7          	jalr	-900(ra) # 80004686 <holdingsleep>
    80003a12:	cd19                	beqz	a0,80003a30 <iunlock+0x3c>
    80003a14:	449c                	lw	a5,8(s1)
    80003a16:	00f05d63          	blez	a5,80003a30 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a1a:	854a                	mv	a0,s2
    80003a1c:	00001097          	auipc	ra,0x1
    80003a20:	c26080e7          	jalr	-986(ra) # 80004642 <releasesleep>
}
    80003a24:	60e2                	ld	ra,24(sp)
    80003a26:	6442                	ld	s0,16(sp)
    80003a28:	64a2                	ld	s1,8(sp)
    80003a2a:	6902                	ld	s2,0(sp)
    80003a2c:	6105                	addi	sp,sp,32
    80003a2e:	8082                	ret
    panic("iunlock");
    80003a30:	00005517          	auipc	a0,0x5
    80003a34:	ba850513          	addi	a0,a0,-1112 # 800085d8 <syscalls+0x198>
    80003a38:	ffffd097          	auipc	ra,0xffffd
    80003a3c:	b06080e7          	jalr	-1274(ra) # 8000053e <panic>

0000000080003a40 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a40:	7179                	addi	sp,sp,-48
    80003a42:	f406                	sd	ra,40(sp)
    80003a44:	f022                	sd	s0,32(sp)
    80003a46:	ec26                	sd	s1,24(sp)
    80003a48:	e84a                	sd	s2,16(sp)
    80003a4a:	e44e                	sd	s3,8(sp)
    80003a4c:	e052                	sd	s4,0(sp)
    80003a4e:	1800                	addi	s0,sp,48
    80003a50:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a52:	05050493          	addi	s1,a0,80
    80003a56:	08050913          	addi	s2,a0,128
    80003a5a:	a021                	j	80003a62 <itrunc+0x22>
    80003a5c:	0491                	addi	s1,s1,4
    80003a5e:	01248d63          	beq	s1,s2,80003a78 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a62:	408c                	lw	a1,0(s1)
    80003a64:	dde5                	beqz	a1,80003a5c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a66:	0009a503          	lw	a0,0(s3)
    80003a6a:	00000097          	auipc	ra,0x0
    80003a6e:	8f4080e7          	jalr	-1804(ra) # 8000335e <bfree>
      ip->addrs[i] = 0;
    80003a72:	0004a023          	sw	zero,0(s1)
    80003a76:	b7dd                	j	80003a5c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a78:	0809a583          	lw	a1,128(s3)
    80003a7c:	e185                	bnez	a1,80003a9c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a7e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a82:	854e                	mv	a0,s3
    80003a84:	00000097          	auipc	ra,0x0
    80003a88:	de4080e7          	jalr	-540(ra) # 80003868 <iupdate>
}
    80003a8c:	70a2                	ld	ra,40(sp)
    80003a8e:	7402                	ld	s0,32(sp)
    80003a90:	64e2                	ld	s1,24(sp)
    80003a92:	6942                	ld	s2,16(sp)
    80003a94:	69a2                	ld	s3,8(sp)
    80003a96:	6a02                	ld	s4,0(sp)
    80003a98:	6145                	addi	sp,sp,48
    80003a9a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a9c:	0009a503          	lw	a0,0(s3)
    80003aa0:	fffff097          	auipc	ra,0xfffff
    80003aa4:	678080e7          	jalr	1656(ra) # 80003118 <bread>
    80003aa8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003aaa:	05850493          	addi	s1,a0,88
    80003aae:	45850913          	addi	s2,a0,1112
    80003ab2:	a021                	j	80003aba <itrunc+0x7a>
    80003ab4:	0491                	addi	s1,s1,4
    80003ab6:	01248b63          	beq	s1,s2,80003acc <itrunc+0x8c>
      if(a[j])
    80003aba:	408c                	lw	a1,0(s1)
    80003abc:	dde5                	beqz	a1,80003ab4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003abe:	0009a503          	lw	a0,0(s3)
    80003ac2:	00000097          	auipc	ra,0x0
    80003ac6:	89c080e7          	jalr	-1892(ra) # 8000335e <bfree>
    80003aca:	b7ed                	j	80003ab4 <itrunc+0x74>
    brelse(bp);
    80003acc:	8552                	mv	a0,s4
    80003ace:	fffff097          	auipc	ra,0xfffff
    80003ad2:	77a080e7          	jalr	1914(ra) # 80003248 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ad6:	0809a583          	lw	a1,128(s3)
    80003ada:	0009a503          	lw	a0,0(s3)
    80003ade:	00000097          	auipc	ra,0x0
    80003ae2:	880080e7          	jalr	-1920(ra) # 8000335e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ae6:	0809a023          	sw	zero,128(s3)
    80003aea:	bf51                	j	80003a7e <itrunc+0x3e>

0000000080003aec <iput>:
{
    80003aec:	1101                	addi	sp,sp,-32
    80003aee:	ec06                	sd	ra,24(sp)
    80003af0:	e822                	sd	s0,16(sp)
    80003af2:	e426                	sd	s1,8(sp)
    80003af4:	e04a                	sd	s2,0(sp)
    80003af6:	1000                	addi	s0,sp,32
    80003af8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003afa:	0001d517          	auipc	a0,0x1d
    80003afe:	b6e50513          	addi	a0,a0,-1170 # 80020668 <itable>
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	0d4080e7          	jalr	212(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b0a:	4498                	lw	a4,8(s1)
    80003b0c:	4785                	li	a5,1
    80003b0e:	02f70363          	beq	a4,a5,80003b34 <iput+0x48>
  ip->ref--;
    80003b12:	449c                	lw	a5,8(s1)
    80003b14:	37fd                	addiw	a5,a5,-1
    80003b16:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b18:	0001d517          	auipc	a0,0x1d
    80003b1c:	b5050513          	addi	a0,a0,-1200 # 80020668 <itable>
    80003b20:	ffffd097          	auipc	ra,0xffffd
    80003b24:	16a080e7          	jalr	362(ra) # 80000c8a <release>
}
    80003b28:	60e2                	ld	ra,24(sp)
    80003b2a:	6442                	ld	s0,16(sp)
    80003b2c:	64a2                	ld	s1,8(sp)
    80003b2e:	6902                	ld	s2,0(sp)
    80003b30:	6105                	addi	sp,sp,32
    80003b32:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b34:	40bc                	lw	a5,64(s1)
    80003b36:	dff1                	beqz	a5,80003b12 <iput+0x26>
    80003b38:	04a49783          	lh	a5,74(s1)
    80003b3c:	fbf9                	bnez	a5,80003b12 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b3e:	01048913          	addi	s2,s1,16
    80003b42:	854a                	mv	a0,s2
    80003b44:	00001097          	auipc	ra,0x1
    80003b48:	aa8080e7          	jalr	-1368(ra) # 800045ec <acquiresleep>
    release(&itable.lock);
    80003b4c:	0001d517          	auipc	a0,0x1d
    80003b50:	b1c50513          	addi	a0,a0,-1252 # 80020668 <itable>
    80003b54:	ffffd097          	auipc	ra,0xffffd
    80003b58:	136080e7          	jalr	310(ra) # 80000c8a <release>
    itrunc(ip);
    80003b5c:	8526                	mv	a0,s1
    80003b5e:	00000097          	auipc	ra,0x0
    80003b62:	ee2080e7          	jalr	-286(ra) # 80003a40 <itrunc>
    ip->type = 0;
    80003b66:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b6a:	8526                	mv	a0,s1
    80003b6c:	00000097          	auipc	ra,0x0
    80003b70:	cfc080e7          	jalr	-772(ra) # 80003868 <iupdate>
    ip->valid = 0;
    80003b74:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b78:	854a                	mv	a0,s2
    80003b7a:	00001097          	auipc	ra,0x1
    80003b7e:	ac8080e7          	jalr	-1336(ra) # 80004642 <releasesleep>
    acquire(&itable.lock);
    80003b82:	0001d517          	auipc	a0,0x1d
    80003b86:	ae650513          	addi	a0,a0,-1306 # 80020668 <itable>
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	04c080e7          	jalr	76(ra) # 80000bd6 <acquire>
    80003b92:	b741                	j	80003b12 <iput+0x26>

0000000080003b94 <iunlockput>:
{
    80003b94:	1101                	addi	sp,sp,-32
    80003b96:	ec06                	sd	ra,24(sp)
    80003b98:	e822                	sd	s0,16(sp)
    80003b9a:	e426                	sd	s1,8(sp)
    80003b9c:	1000                	addi	s0,sp,32
    80003b9e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ba0:	00000097          	auipc	ra,0x0
    80003ba4:	e54080e7          	jalr	-428(ra) # 800039f4 <iunlock>
  iput(ip);
    80003ba8:	8526                	mv	a0,s1
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	f42080e7          	jalr	-190(ra) # 80003aec <iput>
}
    80003bb2:	60e2                	ld	ra,24(sp)
    80003bb4:	6442                	ld	s0,16(sp)
    80003bb6:	64a2                	ld	s1,8(sp)
    80003bb8:	6105                	addi	sp,sp,32
    80003bba:	8082                	ret

0000000080003bbc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bbc:	1141                	addi	sp,sp,-16
    80003bbe:	e422                	sd	s0,8(sp)
    80003bc0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bc2:	411c                	lw	a5,0(a0)
    80003bc4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bc6:	415c                	lw	a5,4(a0)
    80003bc8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bca:	04451783          	lh	a5,68(a0)
    80003bce:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bd2:	04a51783          	lh	a5,74(a0)
    80003bd6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bda:	04c56783          	lwu	a5,76(a0)
    80003bde:	e99c                	sd	a5,16(a1)
}
    80003be0:	6422                	ld	s0,8(sp)
    80003be2:	0141                	addi	sp,sp,16
    80003be4:	8082                	ret

0000000080003be6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003be6:	457c                	lw	a5,76(a0)
    80003be8:	0ed7e963          	bltu	a5,a3,80003cda <readi+0xf4>
{
    80003bec:	7159                	addi	sp,sp,-112
    80003bee:	f486                	sd	ra,104(sp)
    80003bf0:	f0a2                	sd	s0,96(sp)
    80003bf2:	eca6                	sd	s1,88(sp)
    80003bf4:	e8ca                	sd	s2,80(sp)
    80003bf6:	e4ce                	sd	s3,72(sp)
    80003bf8:	e0d2                	sd	s4,64(sp)
    80003bfa:	fc56                	sd	s5,56(sp)
    80003bfc:	f85a                	sd	s6,48(sp)
    80003bfe:	f45e                	sd	s7,40(sp)
    80003c00:	f062                	sd	s8,32(sp)
    80003c02:	ec66                	sd	s9,24(sp)
    80003c04:	e86a                	sd	s10,16(sp)
    80003c06:	e46e                	sd	s11,8(sp)
    80003c08:	1880                	addi	s0,sp,112
    80003c0a:	8b2a                	mv	s6,a0
    80003c0c:	8bae                	mv	s7,a1
    80003c0e:	8a32                	mv	s4,a2
    80003c10:	84b6                	mv	s1,a3
    80003c12:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c14:	9f35                	addw	a4,a4,a3
    return 0;
    80003c16:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c18:	0ad76063          	bltu	a4,a3,80003cb8 <readi+0xd2>
  if(off + n > ip->size)
    80003c1c:	00e7f463          	bgeu	a5,a4,80003c24 <readi+0x3e>
    n = ip->size - off;
    80003c20:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c24:	0a0a8963          	beqz	s5,80003cd6 <readi+0xf0>
    80003c28:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c2a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c2e:	5c7d                	li	s8,-1
    80003c30:	a82d                	j	80003c6a <readi+0x84>
    80003c32:	020d1d93          	slli	s11,s10,0x20
    80003c36:	020ddd93          	srli	s11,s11,0x20
    80003c3a:	05890793          	addi	a5,s2,88
    80003c3e:	86ee                	mv	a3,s11
    80003c40:	963e                	add	a2,a2,a5
    80003c42:	85d2                	mv	a1,s4
    80003c44:	855e                	mv	a0,s7
    80003c46:	fffff097          	auipc	ra,0xfffff
    80003c4a:	8ce080e7          	jalr	-1842(ra) # 80002514 <either_copyout>
    80003c4e:	05850d63          	beq	a0,s8,80003ca8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c52:	854a                	mv	a0,s2
    80003c54:	fffff097          	auipc	ra,0xfffff
    80003c58:	5f4080e7          	jalr	1524(ra) # 80003248 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c5c:	013d09bb          	addw	s3,s10,s3
    80003c60:	009d04bb          	addw	s1,s10,s1
    80003c64:	9a6e                	add	s4,s4,s11
    80003c66:	0559f763          	bgeu	s3,s5,80003cb4 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c6a:	00a4d59b          	srliw	a1,s1,0xa
    80003c6e:	855a                	mv	a0,s6
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	8a2080e7          	jalr	-1886(ra) # 80003512 <bmap>
    80003c78:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c7c:	cd85                	beqz	a1,80003cb4 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c7e:	000b2503          	lw	a0,0(s6)
    80003c82:	fffff097          	auipc	ra,0xfffff
    80003c86:	496080e7          	jalr	1174(ra) # 80003118 <bread>
    80003c8a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c8c:	3ff4f613          	andi	a2,s1,1023
    80003c90:	40cc87bb          	subw	a5,s9,a2
    80003c94:	413a873b          	subw	a4,s5,s3
    80003c98:	8d3e                	mv	s10,a5
    80003c9a:	2781                	sext.w	a5,a5
    80003c9c:	0007069b          	sext.w	a3,a4
    80003ca0:	f8f6f9e3          	bgeu	a3,a5,80003c32 <readi+0x4c>
    80003ca4:	8d3a                	mv	s10,a4
    80003ca6:	b771                	j	80003c32 <readi+0x4c>
      brelse(bp);
    80003ca8:	854a                	mv	a0,s2
    80003caa:	fffff097          	auipc	ra,0xfffff
    80003cae:	59e080e7          	jalr	1438(ra) # 80003248 <brelse>
      tot = -1;
    80003cb2:	59fd                	li	s3,-1
  }
  return tot;
    80003cb4:	0009851b          	sext.w	a0,s3
}
    80003cb8:	70a6                	ld	ra,104(sp)
    80003cba:	7406                	ld	s0,96(sp)
    80003cbc:	64e6                	ld	s1,88(sp)
    80003cbe:	6946                	ld	s2,80(sp)
    80003cc0:	69a6                	ld	s3,72(sp)
    80003cc2:	6a06                	ld	s4,64(sp)
    80003cc4:	7ae2                	ld	s5,56(sp)
    80003cc6:	7b42                	ld	s6,48(sp)
    80003cc8:	7ba2                	ld	s7,40(sp)
    80003cca:	7c02                	ld	s8,32(sp)
    80003ccc:	6ce2                	ld	s9,24(sp)
    80003cce:	6d42                	ld	s10,16(sp)
    80003cd0:	6da2                	ld	s11,8(sp)
    80003cd2:	6165                	addi	sp,sp,112
    80003cd4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cd6:	89d6                	mv	s3,s5
    80003cd8:	bff1                	j	80003cb4 <readi+0xce>
    return 0;
    80003cda:	4501                	li	a0,0
}
    80003cdc:	8082                	ret

0000000080003cde <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cde:	457c                	lw	a5,76(a0)
    80003ce0:	10d7e863          	bltu	a5,a3,80003df0 <writei+0x112>
{
    80003ce4:	7159                	addi	sp,sp,-112
    80003ce6:	f486                	sd	ra,104(sp)
    80003ce8:	f0a2                	sd	s0,96(sp)
    80003cea:	eca6                	sd	s1,88(sp)
    80003cec:	e8ca                	sd	s2,80(sp)
    80003cee:	e4ce                	sd	s3,72(sp)
    80003cf0:	e0d2                	sd	s4,64(sp)
    80003cf2:	fc56                	sd	s5,56(sp)
    80003cf4:	f85a                	sd	s6,48(sp)
    80003cf6:	f45e                	sd	s7,40(sp)
    80003cf8:	f062                	sd	s8,32(sp)
    80003cfa:	ec66                	sd	s9,24(sp)
    80003cfc:	e86a                	sd	s10,16(sp)
    80003cfe:	e46e                	sd	s11,8(sp)
    80003d00:	1880                	addi	s0,sp,112
    80003d02:	8aaa                	mv	s5,a0
    80003d04:	8bae                	mv	s7,a1
    80003d06:	8a32                	mv	s4,a2
    80003d08:	8936                	mv	s2,a3
    80003d0a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d0c:	00e687bb          	addw	a5,a3,a4
    80003d10:	0ed7e263          	bltu	a5,a3,80003df4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d14:	00043737          	lui	a4,0x43
    80003d18:	0ef76063          	bltu	a4,a5,80003df8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d1c:	0c0b0863          	beqz	s6,80003dec <writei+0x10e>
    80003d20:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d22:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d26:	5c7d                	li	s8,-1
    80003d28:	a091                	j	80003d6c <writei+0x8e>
    80003d2a:	020d1d93          	slli	s11,s10,0x20
    80003d2e:	020ddd93          	srli	s11,s11,0x20
    80003d32:	05848793          	addi	a5,s1,88
    80003d36:	86ee                	mv	a3,s11
    80003d38:	8652                	mv	a2,s4
    80003d3a:	85de                	mv	a1,s7
    80003d3c:	953e                	add	a0,a0,a5
    80003d3e:	fffff097          	auipc	ra,0xfffff
    80003d42:	82e080e7          	jalr	-2002(ra) # 8000256c <either_copyin>
    80003d46:	07850263          	beq	a0,s8,80003daa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d4a:	8526                	mv	a0,s1
    80003d4c:	00000097          	auipc	ra,0x0
    80003d50:	780080e7          	jalr	1920(ra) # 800044cc <log_write>
    brelse(bp);
    80003d54:	8526                	mv	a0,s1
    80003d56:	fffff097          	auipc	ra,0xfffff
    80003d5a:	4f2080e7          	jalr	1266(ra) # 80003248 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d5e:	013d09bb          	addw	s3,s10,s3
    80003d62:	012d093b          	addw	s2,s10,s2
    80003d66:	9a6e                	add	s4,s4,s11
    80003d68:	0569f663          	bgeu	s3,s6,80003db4 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d6c:	00a9559b          	srliw	a1,s2,0xa
    80003d70:	8556                	mv	a0,s5
    80003d72:	fffff097          	auipc	ra,0xfffff
    80003d76:	7a0080e7          	jalr	1952(ra) # 80003512 <bmap>
    80003d7a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d7e:	c99d                	beqz	a1,80003db4 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d80:	000aa503          	lw	a0,0(s5)
    80003d84:	fffff097          	auipc	ra,0xfffff
    80003d88:	394080e7          	jalr	916(ra) # 80003118 <bread>
    80003d8c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d8e:	3ff97513          	andi	a0,s2,1023
    80003d92:	40ac87bb          	subw	a5,s9,a0
    80003d96:	413b073b          	subw	a4,s6,s3
    80003d9a:	8d3e                	mv	s10,a5
    80003d9c:	2781                	sext.w	a5,a5
    80003d9e:	0007069b          	sext.w	a3,a4
    80003da2:	f8f6f4e3          	bgeu	a3,a5,80003d2a <writei+0x4c>
    80003da6:	8d3a                	mv	s10,a4
    80003da8:	b749                	j	80003d2a <writei+0x4c>
      brelse(bp);
    80003daa:	8526                	mv	a0,s1
    80003dac:	fffff097          	auipc	ra,0xfffff
    80003db0:	49c080e7          	jalr	1180(ra) # 80003248 <brelse>
  }

  if(off > ip->size)
    80003db4:	04caa783          	lw	a5,76(s5)
    80003db8:	0127f463          	bgeu	a5,s2,80003dc0 <writei+0xe2>
    ip->size = off;
    80003dbc:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003dc0:	8556                	mv	a0,s5
    80003dc2:	00000097          	auipc	ra,0x0
    80003dc6:	aa6080e7          	jalr	-1370(ra) # 80003868 <iupdate>

  return tot;
    80003dca:	0009851b          	sext.w	a0,s3
}
    80003dce:	70a6                	ld	ra,104(sp)
    80003dd0:	7406                	ld	s0,96(sp)
    80003dd2:	64e6                	ld	s1,88(sp)
    80003dd4:	6946                	ld	s2,80(sp)
    80003dd6:	69a6                	ld	s3,72(sp)
    80003dd8:	6a06                	ld	s4,64(sp)
    80003dda:	7ae2                	ld	s5,56(sp)
    80003ddc:	7b42                	ld	s6,48(sp)
    80003dde:	7ba2                	ld	s7,40(sp)
    80003de0:	7c02                	ld	s8,32(sp)
    80003de2:	6ce2                	ld	s9,24(sp)
    80003de4:	6d42                	ld	s10,16(sp)
    80003de6:	6da2                	ld	s11,8(sp)
    80003de8:	6165                	addi	sp,sp,112
    80003dea:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dec:	89da                	mv	s3,s6
    80003dee:	bfc9                	j	80003dc0 <writei+0xe2>
    return -1;
    80003df0:	557d                	li	a0,-1
}
    80003df2:	8082                	ret
    return -1;
    80003df4:	557d                	li	a0,-1
    80003df6:	bfe1                	j	80003dce <writei+0xf0>
    return -1;
    80003df8:	557d                	li	a0,-1
    80003dfa:	bfd1                	j	80003dce <writei+0xf0>

0000000080003dfc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dfc:	1141                	addi	sp,sp,-16
    80003dfe:	e406                	sd	ra,8(sp)
    80003e00:	e022                	sd	s0,0(sp)
    80003e02:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e04:	4639                	li	a2,14
    80003e06:	ffffd097          	auipc	ra,0xffffd
    80003e0a:	f9c080e7          	jalr	-100(ra) # 80000da2 <strncmp>
}
    80003e0e:	60a2                	ld	ra,8(sp)
    80003e10:	6402                	ld	s0,0(sp)
    80003e12:	0141                	addi	sp,sp,16
    80003e14:	8082                	ret

0000000080003e16 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e16:	7139                	addi	sp,sp,-64
    80003e18:	fc06                	sd	ra,56(sp)
    80003e1a:	f822                	sd	s0,48(sp)
    80003e1c:	f426                	sd	s1,40(sp)
    80003e1e:	f04a                	sd	s2,32(sp)
    80003e20:	ec4e                	sd	s3,24(sp)
    80003e22:	e852                	sd	s4,16(sp)
    80003e24:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e26:	04451703          	lh	a4,68(a0)
    80003e2a:	4785                	li	a5,1
    80003e2c:	00f71a63          	bne	a4,a5,80003e40 <dirlookup+0x2a>
    80003e30:	892a                	mv	s2,a0
    80003e32:	89ae                	mv	s3,a1
    80003e34:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e36:	457c                	lw	a5,76(a0)
    80003e38:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e3a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e3c:	e79d                	bnez	a5,80003e6a <dirlookup+0x54>
    80003e3e:	a8a5                	j	80003eb6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e40:	00004517          	auipc	a0,0x4
    80003e44:	7a050513          	addi	a0,a0,1952 # 800085e0 <syscalls+0x1a0>
    80003e48:	ffffc097          	auipc	ra,0xffffc
    80003e4c:	6f6080e7          	jalr	1782(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003e50:	00004517          	auipc	a0,0x4
    80003e54:	7a850513          	addi	a0,a0,1960 # 800085f8 <syscalls+0x1b8>
    80003e58:	ffffc097          	auipc	ra,0xffffc
    80003e5c:	6e6080e7          	jalr	1766(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e60:	24c1                	addiw	s1,s1,16
    80003e62:	04c92783          	lw	a5,76(s2)
    80003e66:	04f4f763          	bgeu	s1,a5,80003eb4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e6a:	4741                	li	a4,16
    80003e6c:	86a6                	mv	a3,s1
    80003e6e:	fc040613          	addi	a2,s0,-64
    80003e72:	4581                	li	a1,0
    80003e74:	854a                	mv	a0,s2
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	d70080e7          	jalr	-656(ra) # 80003be6 <readi>
    80003e7e:	47c1                	li	a5,16
    80003e80:	fcf518e3          	bne	a0,a5,80003e50 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e84:	fc045783          	lhu	a5,-64(s0)
    80003e88:	dfe1                	beqz	a5,80003e60 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e8a:	fc240593          	addi	a1,s0,-62
    80003e8e:	854e                	mv	a0,s3
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	f6c080e7          	jalr	-148(ra) # 80003dfc <namecmp>
    80003e98:	f561                	bnez	a0,80003e60 <dirlookup+0x4a>
      if(poff)
    80003e9a:	000a0463          	beqz	s4,80003ea2 <dirlookup+0x8c>
        *poff = off;
    80003e9e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ea2:	fc045583          	lhu	a1,-64(s0)
    80003ea6:	00092503          	lw	a0,0(s2)
    80003eaa:	fffff097          	auipc	ra,0xfffff
    80003eae:	750080e7          	jalr	1872(ra) # 800035fa <iget>
    80003eb2:	a011                	j	80003eb6 <dirlookup+0xa0>
  return 0;
    80003eb4:	4501                	li	a0,0
}
    80003eb6:	70e2                	ld	ra,56(sp)
    80003eb8:	7442                	ld	s0,48(sp)
    80003eba:	74a2                	ld	s1,40(sp)
    80003ebc:	7902                	ld	s2,32(sp)
    80003ebe:	69e2                	ld	s3,24(sp)
    80003ec0:	6a42                	ld	s4,16(sp)
    80003ec2:	6121                	addi	sp,sp,64
    80003ec4:	8082                	ret

0000000080003ec6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ec6:	711d                	addi	sp,sp,-96
    80003ec8:	ec86                	sd	ra,88(sp)
    80003eca:	e8a2                	sd	s0,80(sp)
    80003ecc:	e4a6                	sd	s1,72(sp)
    80003ece:	e0ca                	sd	s2,64(sp)
    80003ed0:	fc4e                	sd	s3,56(sp)
    80003ed2:	f852                	sd	s4,48(sp)
    80003ed4:	f456                	sd	s5,40(sp)
    80003ed6:	f05a                	sd	s6,32(sp)
    80003ed8:	ec5e                	sd	s7,24(sp)
    80003eda:	e862                	sd	s8,16(sp)
    80003edc:	e466                	sd	s9,8(sp)
    80003ede:	1080                	addi	s0,sp,96
    80003ee0:	84aa                	mv	s1,a0
    80003ee2:	8aae                	mv	s5,a1
    80003ee4:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ee6:	00054703          	lbu	a4,0(a0)
    80003eea:	02f00793          	li	a5,47
    80003eee:	02f70363          	beq	a4,a5,80003f14 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ef2:	ffffe097          	auipc	ra,0xffffe
    80003ef6:	a8e080e7          	jalr	-1394(ra) # 80001980 <myproc>
    80003efa:	18853503          	ld	a0,392(a0)
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	9f6080e7          	jalr	-1546(ra) # 800038f4 <idup>
    80003f06:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f08:	02f00913          	li	s2,47
  len = path - s;
    80003f0c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f0e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f10:	4b85                	li	s7,1
    80003f12:	a865                	j	80003fca <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f14:	4585                	li	a1,1
    80003f16:	4505                	li	a0,1
    80003f18:	fffff097          	auipc	ra,0xfffff
    80003f1c:	6e2080e7          	jalr	1762(ra) # 800035fa <iget>
    80003f20:	89aa                	mv	s3,a0
    80003f22:	b7dd                	j	80003f08 <namex+0x42>
      iunlockput(ip);
    80003f24:	854e                	mv	a0,s3
    80003f26:	00000097          	auipc	ra,0x0
    80003f2a:	c6e080e7          	jalr	-914(ra) # 80003b94 <iunlockput>
      return 0;
    80003f2e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f30:	854e                	mv	a0,s3
    80003f32:	60e6                	ld	ra,88(sp)
    80003f34:	6446                	ld	s0,80(sp)
    80003f36:	64a6                	ld	s1,72(sp)
    80003f38:	6906                	ld	s2,64(sp)
    80003f3a:	79e2                	ld	s3,56(sp)
    80003f3c:	7a42                	ld	s4,48(sp)
    80003f3e:	7aa2                	ld	s5,40(sp)
    80003f40:	7b02                	ld	s6,32(sp)
    80003f42:	6be2                	ld	s7,24(sp)
    80003f44:	6c42                	ld	s8,16(sp)
    80003f46:	6ca2                	ld	s9,8(sp)
    80003f48:	6125                	addi	sp,sp,96
    80003f4a:	8082                	ret
      iunlock(ip);
    80003f4c:	854e                	mv	a0,s3
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	aa6080e7          	jalr	-1370(ra) # 800039f4 <iunlock>
      return ip;
    80003f56:	bfe9                	j	80003f30 <namex+0x6a>
      iunlockput(ip);
    80003f58:	854e                	mv	a0,s3
    80003f5a:	00000097          	auipc	ra,0x0
    80003f5e:	c3a080e7          	jalr	-966(ra) # 80003b94 <iunlockput>
      return 0;
    80003f62:	89e6                	mv	s3,s9
    80003f64:	b7f1                	j	80003f30 <namex+0x6a>
  len = path - s;
    80003f66:	40b48633          	sub	a2,s1,a1
    80003f6a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f6e:	099c5463          	bge	s8,s9,80003ff6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f72:	4639                	li	a2,14
    80003f74:	8552                	mv	a0,s4
    80003f76:	ffffd097          	auipc	ra,0xffffd
    80003f7a:	db8080e7          	jalr	-584(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003f7e:	0004c783          	lbu	a5,0(s1)
    80003f82:	01279763          	bne	a5,s2,80003f90 <namex+0xca>
    path++;
    80003f86:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f88:	0004c783          	lbu	a5,0(s1)
    80003f8c:	ff278de3          	beq	a5,s2,80003f86 <namex+0xc0>
    ilock(ip);
    80003f90:	854e                	mv	a0,s3
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	9a0080e7          	jalr	-1632(ra) # 80003932 <ilock>
    if(ip->type != T_DIR){
    80003f9a:	04499783          	lh	a5,68(s3)
    80003f9e:	f97793e3          	bne	a5,s7,80003f24 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003fa2:	000a8563          	beqz	s5,80003fac <namex+0xe6>
    80003fa6:	0004c783          	lbu	a5,0(s1)
    80003faa:	d3cd                	beqz	a5,80003f4c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fac:	865a                	mv	a2,s6
    80003fae:	85d2                	mv	a1,s4
    80003fb0:	854e                	mv	a0,s3
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	e64080e7          	jalr	-412(ra) # 80003e16 <dirlookup>
    80003fba:	8caa                	mv	s9,a0
    80003fbc:	dd51                	beqz	a0,80003f58 <namex+0x92>
    iunlockput(ip);
    80003fbe:	854e                	mv	a0,s3
    80003fc0:	00000097          	auipc	ra,0x0
    80003fc4:	bd4080e7          	jalr	-1068(ra) # 80003b94 <iunlockput>
    ip = next;
    80003fc8:	89e6                	mv	s3,s9
  while(*path == '/')
    80003fca:	0004c783          	lbu	a5,0(s1)
    80003fce:	05279763          	bne	a5,s2,8000401c <namex+0x156>
    path++;
    80003fd2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fd4:	0004c783          	lbu	a5,0(s1)
    80003fd8:	ff278de3          	beq	a5,s2,80003fd2 <namex+0x10c>
  if(*path == 0)
    80003fdc:	c79d                	beqz	a5,8000400a <namex+0x144>
    path++;
    80003fde:	85a6                	mv	a1,s1
  len = path - s;
    80003fe0:	8cda                	mv	s9,s6
    80003fe2:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003fe4:	01278963          	beq	a5,s2,80003ff6 <namex+0x130>
    80003fe8:	dfbd                	beqz	a5,80003f66 <namex+0xa0>
    path++;
    80003fea:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fec:	0004c783          	lbu	a5,0(s1)
    80003ff0:	ff279ce3          	bne	a5,s2,80003fe8 <namex+0x122>
    80003ff4:	bf8d                	j	80003f66 <namex+0xa0>
    memmove(name, s, len);
    80003ff6:	2601                	sext.w	a2,a2
    80003ff8:	8552                	mv	a0,s4
    80003ffa:	ffffd097          	auipc	ra,0xffffd
    80003ffe:	d34080e7          	jalr	-716(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004002:	9cd2                	add	s9,s9,s4
    80004004:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004008:	bf9d                	j	80003f7e <namex+0xb8>
  if(nameiparent){
    8000400a:	f20a83e3          	beqz	s5,80003f30 <namex+0x6a>
    iput(ip);
    8000400e:	854e                	mv	a0,s3
    80004010:	00000097          	auipc	ra,0x0
    80004014:	adc080e7          	jalr	-1316(ra) # 80003aec <iput>
    return 0;
    80004018:	4981                	li	s3,0
    8000401a:	bf19                	j	80003f30 <namex+0x6a>
  if(*path == 0)
    8000401c:	d7fd                	beqz	a5,8000400a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000401e:	0004c783          	lbu	a5,0(s1)
    80004022:	85a6                	mv	a1,s1
    80004024:	b7d1                	j	80003fe8 <namex+0x122>

0000000080004026 <dirlink>:
{
    80004026:	7139                	addi	sp,sp,-64
    80004028:	fc06                	sd	ra,56(sp)
    8000402a:	f822                	sd	s0,48(sp)
    8000402c:	f426                	sd	s1,40(sp)
    8000402e:	f04a                	sd	s2,32(sp)
    80004030:	ec4e                	sd	s3,24(sp)
    80004032:	e852                	sd	s4,16(sp)
    80004034:	0080                	addi	s0,sp,64
    80004036:	892a                	mv	s2,a0
    80004038:	8a2e                	mv	s4,a1
    8000403a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000403c:	4601                	li	a2,0
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	dd8080e7          	jalr	-552(ra) # 80003e16 <dirlookup>
    80004046:	e93d                	bnez	a0,800040bc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004048:	04c92483          	lw	s1,76(s2)
    8000404c:	c49d                	beqz	s1,8000407a <dirlink+0x54>
    8000404e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004050:	4741                	li	a4,16
    80004052:	86a6                	mv	a3,s1
    80004054:	fc040613          	addi	a2,s0,-64
    80004058:	4581                	li	a1,0
    8000405a:	854a                	mv	a0,s2
    8000405c:	00000097          	auipc	ra,0x0
    80004060:	b8a080e7          	jalr	-1142(ra) # 80003be6 <readi>
    80004064:	47c1                	li	a5,16
    80004066:	06f51163          	bne	a0,a5,800040c8 <dirlink+0xa2>
    if(de.inum == 0)
    8000406a:	fc045783          	lhu	a5,-64(s0)
    8000406e:	c791                	beqz	a5,8000407a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004070:	24c1                	addiw	s1,s1,16
    80004072:	04c92783          	lw	a5,76(s2)
    80004076:	fcf4ede3          	bltu	s1,a5,80004050 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000407a:	4639                	li	a2,14
    8000407c:	85d2                	mv	a1,s4
    8000407e:	fc240513          	addi	a0,s0,-62
    80004082:	ffffd097          	auipc	ra,0xffffd
    80004086:	d5c080e7          	jalr	-676(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000408a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000408e:	4741                	li	a4,16
    80004090:	86a6                	mv	a3,s1
    80004092:	fc040613          	addi	a2,s0,-64
    80004096:	4581                	li	a1,0
    80004098:	854a                	mv	a0,s2
    8000409a:	00000097          	auipc	ra,0x0
    8000409e:	c44080e7          	jalr	-956(ra) # 80003cde <writei>
    800040a2:	1541                	addi	a0,a0,-16
    800040a4:	00a03533          	snez	a0,a0
    800040a8:	40a00533          	neg	a0,a0
}
    800040ac:	70e2                	ld	ra,56(sp)
    800040ae:	7442                	ld	s0,48(sp)
    800040b0:	74a2                	ld	s1,40(sp)
    800040b2:	7902                	ld	s2,32(sp)
    800040b4:	69e2                	ld	s3,24(sp)
    800040b6:	6a42                	ld	s4,16(sp)
    800040b8:	6121                	addi	sp,sp,64
    800040ba:	8082                	ret
    iput(ip);
    800040bc:	00000097          	auipc	ra,0x0
    800040c0:	a30080e7          	jalr	-1488(ra) # 80003aec <iput>
    return -1;
    800040c4:	557d                	li	a0,-1
    800040c6:	b7dd                	j	800040ac <dirlink+0x86>
      panic("dirlink read");
    800040c8:	00004517          	auipc	a0,0x4
    800040cc:	54050513          	addi	a0,a0,1344 # 80008608 <syscalls+0x1c8>
    800040d0:	ffffc097          	auipc	ra,0xffffc
    800040d4:	46e080e7          	jalr	1134(ra) # 8000053e <panic>

00000000800040d8 <namei>:

struct inode*
namei(char *path)
{
    800040d8:	1101                	addi	sp,sp,-32
    800040da:	ec06                	sd	ra,24(sp)
    800040dc:	e822                	sd	s0,16(sp)
    800040de:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040e0:	fe040613          	addi	a2,s0,-32
    800040e4:	4581                	li	a1,0
    800040e6:	00000097          	auipc	ra,0x0
    800040ea:	de0080e7          	jalr	-544(ra) # 80003ec6 <namex>
}
    800040ee:	60e2                	ld	ra,24(sp)
    800040f0:	6442                	ld	s0,16(sp)
    800040f2:	6105                	addi	sp,sp,32
    800040f4:	8082                	ret

00000000800040f6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040f6:	1141                	addi	sp,sp,-16
    800040f8:	e406                	sd	ra,8(sp)
    800040fa:	e022                	sd	s0,0(sp)
    800040fc:	0800                	addi	s0,sp,16
    800040fe:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004100:	4585                	li	a1,1
    80004102:	00000097          	auipc	ra,0x0
    80004106:	dc4080e7          	jalr	-572(ra) # 80003ec6 <namex>
}
    8000410a:	60a2                	ld	ra,8(sp)
    8000410c:	6402                	ld	s0,0(sp)
    8000410e:	0141                	addi	sp,sp,16
    80004110:	8082                	ret

0000000080004112 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004112:	1101                	addi	sp,sp,-32
    80004114:	ec06                	sd	ra,24(sp)
    80004116:	e822                	sd	s0,16(sp)
    80004118:	e426                	sd	s1,8(sp)
    8000411a:	e04a                	sd	s2,0(sp)
    8000411c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000411e:	0001e917          	auipc	s2,0x1e
    80004122:	ff290913          	addi	s2,s2,-14 # 80022110 <log>
    80004126:	01892583          	lw	a1,24(s2)
    8000412a:	02892503          	lw	a0,40(s2)
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	fea080e7          	jalr	-22(ra) # 80003118 <bread>
    80004136:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004138:	02c92683          	lw	a3,44(s2)
    8000413c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000413e:	02d05763          	blez	a3,8000416c <write_head+0x5a>
    80004142:	0001e797          	auipc	a5,0x1e
    80004146:	ffe78793          	addi	a5,a5,-2 # 80022140 <log+0x30>
    8000414a:	05c50713          	addi	a4,a0,92
    8000414e:	36fd                	addiw	a3,a3,-1
    80004150:	1682                	slli	a3,a3,0x20
    80004152:	9281                	srli	a3,a3,0x20
    80004154:	068a                	slli	a3,a3,0x2
    80004156:	0001e617          	auipc	a2,0x1e
    8000415a:	fee60613          	addi	a2,a2,-18 # 80022144 <log+0x34>
    8000415e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004160:	4390                	lw	a2,0(a5)
    80004162:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004164:	0791                	addi	a5,a5,4
    80004166:	0711                	addi	a4,a4,4
    80004168:	fed79ce3          	bne	a5,a3,80004160 <write_head+0x4e>
  }
  bwrite(buf);
    8000416c:	8526                	mv	a0,s1
    8000416e:	fffff097          	auipc	ra,0xfffff
    80004172:	09c080e7          	jalr	156(ra) # 8000320a <bwrite>
  brelse(buf);
    80004176:	8526                	mv	a0,s1
    80004178:	fffff097          	auipc	ra,0xfffff
    8000417c:	0d0080e7          	jalr	208(ra) # 80003248 <brelse>
}
    80004180:	60e2                	ld	ra,24(sp)
    80004182:	6442                	ld	s0,16(sp)
    80004184:	64a2                	ld	s1,8(sp)
    80004186:	6902                	ld	s2,0(sp)
    80004188:	6105                	addi	sp,sp,32
    8000418a:	8082                	ret

000000008000418c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000418c:	0001e797          	auipc	a5,0x1e
    80004190:	fb07a783          	lw	a5,-80(a5) # 8002213c <log+0x2c>
    80004194:	0af05d63          	blez	a5,8000424e <install_trans+0xc2>
{
    80004198:	7139                	addi	sp,sp,-64
    8000419a:	fc06                	sd	ra,56(sp)
    8000419c:	f822                	sd	s0,48(sp)
    8000419e:	f426                	sd	s1,40(sp)
    800041a0:	f04a                	sd	s2,32(sp)
    800041a2:	ec4e                	sd	s3,24(sp)
    800041a4:	e852                	sd	s4,16(sp)
    800041a6:	e456                	sd	s5,8(sp)
    800041a8:	e05a                	sd	s6,0(sp)
    800041aa:	0080                	addi	s0,sp,64
    800041ac:	8b2a                	mv	s6,a0
    800041ae:	0001ea97          	auipc	s5,0x1e
    800041b2:	f92a8a93          	addi	s5,s5,-110 # 80022140 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041b6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041b8:	0001e997          	auipc	s3,0x1e
    800041bc:	f5898993          	addi	s3,s3,-168 # 80022110 <log>
    800041c0:	a00d                	j	800041e2 <install_trans+0x56>
    brelse(lbuf);
    800041c2:	854a                	mv	a0,s2
    800041c4:	fffff097          	auipc	ra,0xfffff
    800041c8:	084080e7          	jalr	132(ra) # 80003248 <brelse>
    brelse(dbuf);
    800041cc:	8526                	mv	a0,s1
    800041ce:	fffff097          	auipc	ra,0xfffff
    800041d2:	07a080e7          	jalr	122(ra) # 80003248 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041d6:	2a05                	addiw	s4,s4,1
    800041d8:	0a91                	addi	s5,s5,4
    800041da:	02c9a783          	lw	a5,44(s3)
    800041de:	04fa5e63          	bge	s4,a5,8000423a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041e2:	0189a583          	lw	a1,24(s3)
    800041e6:	014585bb          	addw	a1,a1,s4
    800041ea:	2585                	addiw	a1,a1,1
    800041ec:	0289a503          	lw	a0,40(s3)
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	f28080e7          	jalr	-216(ra) # 80003118 <bread>
    800041f8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041fa:	000aa583          	lw	a1,0(s5)
    800041fe:	0289a503          	lw	a0,40(s3)
    80004202:	fffff097          	auipc	ra,0xfffff
    80004206:	f16080e7          	jalr	-234(ra) # 80003118 <bread>
    8000420a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000420c:	40000613          	li	a2,1024
    80004210:	05890593          	addi	a1,s2,88
    80004214:	05850513          	addi	a0,a0,88
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	b16080e7          	jalr	-1258(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004220:	8526                	mv	a0,s1
    80004222:	fffff097          	auipc	ra,0xfffff
    80004226:	fe8080e7          	jalr	-24(ra) # 8000320a <bwrite>
    if(recovering == 0)
    8000422a:	f80b1ce3          	bnez	s6,800041c2 <install_trans+0x36>
      bunpin(dbuf);
    8000422e:	8526                	mv	a0,s1
    80004230:	fffff097          	auipc	ra,0xfffff
    80004234:	0f2080e7          	jalr	242(ra) # 80003322 <bunpin>
    80004238:	b769                	j	800041c2 <install_trans+0x36>
}
    8000423a:	70e2                	ld	ra,56(sp)
    8000423c:	7442                	ld	s0,48(sp)
    8000423e:	74a2                	ld	s1,40(sp)
    80004240:	7902                	ld	s2,32(sp)
    80004242:	69e2                	ld	s3,24(sp)
    80004244:	6a42                	ld	s4,16(sp)
    80004246:	6aa2                	ld	s5,8(sp)
    80004248:	6b02                	ld	s6,0(sp)
    8000424a:	6121                	addi	sp,sp,64
    8000424c:	8082                	ret
    8000424e:	8082                	ret

0000000080004250 <initlog>:
{
    80004250:	7179                	addi	sp,sp,-48
    80004252:	f406                	sd	ra,40(sp)
    80004254:	f022                	sd	s0,32(sp)
    80004256:	ec26                	sd	s1,24(sp)
    80004258:	e84a                	sd	s2,16(sp)
    8000425a:	e44e                	sd	s3,8(sp)
    8000425c:	1800                	addi	s0,sp,48
    8000425e:	892a                	mv	s2,a0
    80004260:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004262:	0001e497          	auipc	s1,0x1e
    80004266:	eae48493          	addi	s1,s1,-338 # 80022110 <log>
    8000426a:	00004597          	auipc	a1,0x4
    8000426e:	3ae58593          	addi	a1,a1,942 # 80008618 <syscalls+0x1d8>
    80004272:	8526                	mv	a0,s1
    80004274:	ffffd097          	auipc	ra,0xffffd
    80004278:	8d2080e7          	jalr	-1838(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000427c:	0149a583          	lw	a1,20(s3)
    80004280:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004282:	0109a783          	lw	a5,16(s3)
    80004286:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004288:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000428c:	854a                	mv	a0,s2
    8000428e:	fffff097          	auipc	ra,0xfffff
    80004292:	e8a080e7          	jalr	-374(ra) # 80003118 <bread>
  log.lh.n = lh->n;
    80004296:	4d34                	lw	a3,88(a0)
    80004298:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000429a:	02d05563          	blez	a3,800042c4 <initlog+0x74>
    8000429e:	05c50793          	addi	a5,a0,92
    800042a2:	0001e717          	auipc	a4,0x1e
    800042a6:	e9e70713          	addi	a4,a4,-354 # 80022140 <log+0x30>
    800042aa:	36fd                	addiw	a3,a3,-1
    800042ac:	1682                	slli	a3,a3,0x20
    800042ae:	9281                	srli	a3,a3,0x20
    800042b0:	068a                	slli	a3,a3,0x2
    800042b2:	06050613          	addi	a2,a0,96
    800042b6:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800042b8:	4390                	lw	a2,0(a5)
    800042ba:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042bc:	0791                	addi	a5,a5,4
    800042be:	0711                	addi	a4,a4,4
    800042c0:	fed79ce3          	bne	a5,a3,800042b8 <initlog+0x68>
  brelse(buf);
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	f84080e7          	jalr	-124(ra) # 80003248 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042cc:	4505                	li	a0,1
    800042ce:	00000097          	auipc	ra,0x0
    800042d2:	ebe080e7          	jalr	-322(ra) # 8000418c <install_trans>
  log.lh.n = 0;
    800042d6:	0001e797          	auipc	a5,0x1e
    800042da:	e607a323          	sw	zero,-410(a5) # 8002213c <log+0x2c>
  write_head(); // clear the log
    800042de:	00000097          	auipc	ra,0x0
    800042e2:	e34080e7          	jalr	-460(ra) # 80004112 <write_head>
}
    800042e6:	70a2                	ld	ra,40(sp)
    800042e8:	7402                	ld	s0,32(sp)
    800042ea:	64e2                	ld	s1,24(sp)
    800042ec:	6942                	ld	s2,16(sp)
    800042ee:	69a2                	ld	s3,8(sp)
    800042f0:	6145                	addi	sp,sp,48
    800042f2:	8082                	ret

00000000800042f4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042f4:	1101                	addi	sp,sp,-32
    800042f6:	ec06                	sd	ra,24(sp)
    800042f8:	e822                	sd	s0,16(sp)
    800042fa:	e426                	sd	s1,8(sp)
    800042fc:	e04a                	sd	s2,0(sp)
    800042fe:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004300:	0001e517          	auipc	a0,0x1e
    80004304:	e1050513          	addi	a0,a0,-496 # 80022110 <log>
    80004308:	ffffd097          	auipc	ra,0xffffd
    8000430c:	8ce080e7          	jalr	-1842(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004310:	0001e497          	auipc	s1,0x1e
    80004314:	e0048493          	addi	s1,s1,-512 # 80022110 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004318:	4979                	li	s2,30
    8000431a:	a039                	j	80004328 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000431c:	85a6                	mv	a1,s1
    8000431e:	8526                	mv	a0,s1
    80004320:	ffffe097          	auipc	ra,0xffffe
    80004324:	d9c080e7          	jalr	-612(ra) # 800020bc <sleep>
    if(log.committing){
    80004328:	50dc                	lw	a5,36(s1)
    8000432a:	fbed                	bnez	a5,8000431c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000432c:	509c                	lw	a5,32(s1)
    8000432e:	0017871b          	addiw	a4,a5,1
    80004332:	0007069b          	sext.w	a3,a4
    80004336:	0027179b          	slliw	a5,a4,0x2
    8000433a:	9fb9                	addw	a5,a5,a4
    8000433c:	0017979b          	slliw	a5,a5,0x1
    80004340:	54d8                	lw	a4,44(s1)
    80004342:	9fb9                	addw	a5,a5,a4
    80004344:	00f95963          	bge	s2,a5,80004356 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004348:	85a6                	mv	a1,s1
    8000434a:	8526                	mv	a0,s1
    8000434c:	ffffe097          	auipc	ra,0xffffe
    80004350:	d70080e7          	jalr	-656(ra) # 800020bc <sleep>
    80004354:	bfd1                	j	80004328 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004356:	0001e517          	auipc	a0,0x1e
    8000435a:	dba50513          	addi	a0,a0,-582 # 80022110 <log>
    8000435e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004360:	ffffd097          	auipc	ra,0xffffd
    80004364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004368:	60e2                	ld	ra,24(sp)
    8000436a:	6442                	ld	s0,16(sp)
    8000436c:	64a2                	ld	s1,8(sp)
    8000436e:	6902                	ld	s2,0(sp)
    80004370:	6105                	addi	sp,sp,32
    80004372:	8082                	ret

0000000080004374 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004374:	7139                	addi	sp,sp,-64
    80004376:	fc06                	sd	ra,56(sp)
    80004378:	f822                	sd	s0,48(sp)
    8000437a:	f426                	sd	s1,40(sp)
    8000437c:	f04a                	sd	s2,32(sp)
    8000437e:	ec4e                	sd	s3,24(sp)
    80004380:	e852                	sd	s4,16(sp)
    80004382:	e456                	sd	s5,8(sp)
    80004384:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004386:	0001e497          	auipc	s1,0x1e
    8000438a:	d8a48493          	addi	s1,s1,-630 # 80022110 <log>
    8000438e:	8526                	mv	a0,s1
    80004390:	ffffd097          	auipc	ra,0xffffd
    80004394:	846080e7          	jalr	-1978(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004398:	509c                	lw	a5,32(s1)
    8000439a:	37fd                	addiw	a5,a5,-1
    8000439c:	0007891b          	sext.w	s2,a5
    800043a0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043a2:	50dc                	lw	a5,36(s1)
    800043a4:	e7b9                	bnez	a5,800043f2 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043a6:	04091e63          	bnez	s2,80004402 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043aa:	0001e497          	auipc	s1,0x1e
    800043ae:	d6648493          	addi	s1,s1,-666 # 80022110 <log>
    800043b2:	4785                	li	a5,1
    800043b4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043b6:	8526                	mv	a0,s1
    800043b8:	ffffd097          	auipc	ra,0xffffd
    800043bc:	8d2080e7          	jalr	-1838(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043c0:	54dc                	lw	a5,44(s1)
    800043c2:	06f04763          	bgtz	a5,80004430 <end_op+0xbc>
    acquire(&log.lock);
    800043c6:	0001e497          	auipc	s1,0x1e
    800043ca:	d4a48493          	addi	s1,s1,-694 # 80022110 <log>
    800043ce:	8526                	mv	a0,s1
    800043d0:	ffffd097          	auipc	ra,0xffffd
    800043d4:	806080e7          	jalr	-2042(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800043d8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043dc:	8526                	mv	a0,s1
    800043de:	ffffe097          	auipc	ra,0xffffe
    800043e2:	d4c080e7          	jalr	-692(ra) # 8000212a <wakeup>
    release(&log.lock);
    800043e6:	8526                	mv	a0,s1
    800043e8:	ffffd097          	auipc	ra,0xffffd
    800043ec:	8a2080e7          	jalr	-1886(ra) # 80000c8a <release>
}
    800043f0:	a03d                	j	8000441e <end_op+0xaa>
    panic("log.committing");
    800043f2:	00004517          	auipc	a0,0x4
    800043f6:	22e50513          	addi	a0,a0,558 # 80008620 <syscalls+0x1e0>
    800043fa:	ffffc097          	auipc	ra,0xffffc
    800043fe:	144080e7          	jalr	324(ra) # 8000053e <panic>
    wakeup(&log);
    80004402:	0001e497          	auipc	s1,0x1e
    80004406:	d0e48493          	addi	s1,s1,-754 # 80022110 <log>
    8000440a:	8526                	mv	a0,s1
    8000440c:	ffffe097          	auipc	ra,0xffffe
    80004410:	d1e080e7          	jalr	-738(ra) # 8000212a <wakeup>
  release(&log.lock);
    80004414:	8526                	mv	a0,s1
    80004416:	ffffd097          	auipc	ra,0xffffd
    8000441a:	874080e7          	jalr	-1932(ra) # 80000c8a <release>
}
    8000441e:	70e2                	ld	ra,56(sp)
    80004420:	7442                	ld	s0,48(sp)
    80004422:	74a2                	ld	s1,40(sp)
    80004424:	7902                	ld	s2,32(sp)
    80004426:	69e2                	ld	s3,24(sp)
    80004428:	6a42                	ld	s4,16(sp)
    8000442a:	6aa2                	ld	s5,8(sp)
    8000442c:	6121                	addi	sp,sp,64
    8000442e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004430:	0001ea97          	auipc	s5,0x1e
    80004434:	d10a8a93          	addi	s5,s5,-752 # 80022140 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004438:	0001ea17          	auipc	s4,0x1e
    8000443c:	cd8a0a13          	addi	s4,s4,-808 # 80022110 <log>
    80004440:	018a2583          	lw	a1,24(s4)
    80004444:	012585bb          	addw	a1,a1,s2
    80004448:	2585                	addiw	a1,a1,1
    8000444a:	028a2503          	lw	a0,40(s4)
    8000444e:	fffff097          	auipc	ra,0xfffff
    80004452:	cca080e7          	jalr	-822(ra) # 80003118 <bread>
    80004456:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004458:	000aa583          	lw	a1,0(s5)
    8000445c:	028a2503          	lw	a0,40(s4)
    80004460:	fffff097          	auipc	ra,0xfffff
    80004464:	cb8080e7          	jalr	-840(ra) # 80003118 <bread>
    80004468:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000446a:	40000613          	li	a2,1024
    8000446e:	05850593          	addi	a1,a0,88
    80004472:	05848513          	addi	a0,s1,88
    80004476:	ffffd097          	auipc	ra,0xffffd
    8000447a:	8b8080e7          	jalr	-1864(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000447e:	8526                	mv	a0,s1
    80004480:	fffff097          	auipc	ra,0xfffff
    80004484:	d8a080e7          	jalr	-630(ra) # 8000320a <bwrite>
    brelse(from);
    80004488:	854e                	mv	a0,s3
    8000448a:	fffff097          	auipc	ra,0xfffff
    8000448e:	dbe080e7          	jalr	-578(ra) # 80003248 <brelse>
    brelse(to);
    80004492:	8526                	mv	a0,s1
    80004494:	fffff097          	auipc	ra,0xfffff
    80004498:	db4080e7          	jalr	-588(ra) # 80003248 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000449c:	2905                	addiw	s2,s2,1
    8000449e:	0a91                	addi	s5,s5,4
    800044a0:	02ca2783          	lw	a5,44(s4)
    800044a4:	f8f94ee3          	blt	s2,a5,80004440 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044a8:	00000097          	auipc	ra,0x0
    800044ac:	c6a080e7          	jalr	-918(ra) # 80004112 <write_head>
    install_trans(0); // Now install writes to home locations
    800044b0:	4501                	li	a0,0
    800044b2:	00000097          	auipc	ra,0x0
    800044b6:	cda080e7          	jalr	-806(ra) # 8000418c <install_trans>
    log.lh.n = 0;
    800044ba:	0001e797          	auipc	a5,0x1e
    800044be:	c807a123          	sw	zero,-894(a5) # 8002213c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044c2:	00000097          	auipc	ra,0x0
    800044c6:	c50080e7          	jalr	-944(ra) # 80004112 <write_head>
    800044ca:	bdf5                	j	800043c6 <end_op+0x52>

00000000800044cc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044cc:	1101                	addi	sp,sp,-32
    800044ce:	ec06                	sd	ra,24(sp)
    800044d0:	e822                	sd	s0,16(sp)
    800044d2:	e426                	sd	s1,8(sp)
    800044d4:	e04a                	sd	s2,0(sp)
    800044d6:	1000                	addi	s0,sp,32
    800044d8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044da:	0001e917          	auipc	s2,0x1e
    800044de:	c3690913          	addi	s2,s2,-970 # 80022110 <log>
    800044e2:	854a                	mv	a0,s2
    800044e4:	ffffc097          	auipc	ra,0xffffc
    800044e8:	6f2080e7          	jalr	1778(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044ec:	02c92603          	lw	a2,44(s2)
    800044f0:	47f5                	li	a5,29
    800044f2:	06c7c563          	blt	a5,a2,8000455c <log_write+0x90>
    800044f6:	0001e797          	auipc	a5,0x1e
    800044fa:	c367a783          	lw	a5,-970(a5) # 8002212c <log+0x1c>
    800044fe:	37fd                	addiw	a5,a5,-1
    80004500:	04f65e63          	bge	a2,a5,8000455c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004504:	0001e797          	auipc	a5,0x1e
    80004508:	c2c7a783          	lw	a5,-980(a5) # 80022130 <log+0x20>
    8000450c:	06f05063          	blez	a5,8000456c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004510:	4781                	li	a5,0
    80004512:	06c05563          	blez	a2,8000457c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004516:	44cc                	lw	a1,12(s1)
    80004518:	0001e717          	auipc	a4,0x1e
    8000451c:	c2870713          	addi	a4,a4,-984 # 80022140 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004520:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004522:	4314                	lw	a3,0(a4)
    80004524:	04b68c63          	beq	a3,a1,8000457c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004528:	2785                	addiw	a5,a5,1
    8000452a:	0711                	addi	a4,a4,4
    8000452c:	fef61be3          	bne	a2,a5,80004522 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004530:	0621                	addi	a2,a2,8
    80004532:	060a                	slli	a2,a2,0x2
    80004534:	0001e797          	auipc	a5,0x1e
    80004538:	bdc78793          	addi	a5,a5,-1060 # 80022110 <log>
    8000453c:	963e                	add	a2,a2,a5
    8000453e:	44dc                	lw	a5,12(s1)
    80004540:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004542:	8526                	mv	a0,s1
    80004544:	fffff097          	auipc	ra,0xfffff
    80004548:	da2080e7          	jalr	-606(ra) # 800032e6 <bpin>
    log.lh.n++;
    8000454c:	0001e717          	auipc	a4,0x1e
    80004550:	bc470713          	addi	a4,a4,-1084 # 80022110 <log>
    80004554:	575c                	lw	a5,44(a4)
    80004556:	2785                	addiw	a5,a5,1
    80004558:	d75c                	sw	a5,44(a4)
    8000455a:	a835                	j	80004596 <log_write+0xca>
    panic("too big a transaction");
    8000455c:	00004517          	auipc	a0,0x4
    80004560:	0d450513          	addi	a0,a0,212 # 80008630 <syscalls+0x1f0>
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	fda080e7          	jalr	-38(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000456c:	00004517          	auipc	a0,0x4
    80004570:	0dc50513          	addi	a0,a0,220 # 80008648 <syscalls+0x208>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	fca080e7          	jalr	-54(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000457c:	00878713          	addi	a4,a5,8
    80004580:	00271693          	slli	a3,a4,0x2
    80004584:	0001e717          	auipc	a4,0x1e
    80004588:	b8c70713          	addi	a4,a4,-1140 # 80022110 <log>
    8000458c:	9736                	add	a4,a4,a3
    8000458e:	44d4                	lw	a3,12(s1)
    80004590:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004592:	faf608e3          	beq	a2,a5,80004542 <log_write+0x76>
  }
  release(&log.lock);
    80004596:	0001e517          	auipc	a0,0x1e
    8000459a:	b7a50513          	addi	a0,a0,-1158 # 80022110 <log>
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	6ec080e7          	jalr	1772(ra) # 80000c8a <release>
}
    800045a6:	60e2                	ld	ra,24(sp)
    800045a8:	6442                	ld	s0,16(sp)
    800045aa:	64a2                	ld	s1,8(sp)
    800045ac:	6902                	ld	s2,0(sp)
    800045ae:	6105                	addi	sp,sp,32
    800045b0:	8082                	ret

00000000800045b2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045b2:	1101                	addi	sp,sp,-32
    800045b4:	ec06                	sd	ra,24(sp)
    800045b6:	e822                	sd	s0,16(sp)
    800045b8:	e426                	sd	s1,8(sp)
    800045ba:	e04a                	sd	s2,0(sp)
    800045bc:	1000                	addi	s0,sp,32
    800045be:	84aa                	mv	s1,a0
    800045c0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045c2:	00004597          	auipc	a1,0x4
    800045c6:	0a658593          	addi	a1,a1,166 # 80008668 <syscalls+0x228>
    800045ca:	0521                	addi	a0,a0,8
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	57a080e7          	jalr	1402(ra) # 80000b46 <initlock>
  lk->name = name;
    800045d4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045d8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045dc:	0204a423          	sw	zero,40(s1)
}
    800045e0:	60e2                	ld	ra,24(sp)
    800045e2:	6442                	ld	s0,16(sp)
    800045e4:	64a2                	ld	s1,8(sp)
    800045e6:	6902                	ld	s2,0(sp)
    800045e8:	6105                	addi	sp,sp,32
    800045ea:	8082                	ret

00000000800045ec <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045ec:	1101                	addi	sp,sp,-32
    800045ee:	ec06                	sd	ra,24(sp)
    800045f0:	e822                	sd	s0,16(sp)
    800045f2:	e426                	sd	s1,8(sp)
    800045f4:	e04a                	sd	s2,0(sp)
    800045f6:	1000                	addi	s0,sp,32
    800045f8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045fa:	00850913          	addi	s2,a0,8
    800045fe:	854a                	mv	a0,s2
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004608:	409c                	lw	a5,0(s1)
    8000460a:	cb89                	beqz	a5,8000461c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000460c:	85ca                	mv	a1,s2
    8000460e:	8526                	mv	a0,s1
    80004610:	ffffe097          	auipc	ra,0xffffe
    80004614:	aac080e7          	jalr	-1364(ra) # 800020bc <sleep>
  while (lk->locked) {
    80004618:	409c                	lw	a5,0(s1)
    8000461a:	fbed                	bnez	a5,8000460c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000461c:	4785                	li	a5,1
    8000461e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004620:	ffffd097          	auipc	ra,0xffffd
    80004624:	360080e7          	jalr	864(ra) # 80001980 <myproc>
    80004628:	515c                	lw	a5,36(a0)
    8000462a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000462c:	854a                	mv	a0,s2
    8000462e:	ffffc097          	auipc	ra,0xffffc
    80004632:	65c080e7          	jalr	1628(ra) # 80000c8a <release>
}
    80004636:	60e2                	ld	ra,24(sp)
    80004638:	6442                	ld	s0,16(sp)
    8000463a:	64a2                	ld	s1,8(sp)
    8000463c:	6902                	ld	s2,0(sp)
    8000463e:	6105                	addi	sp,sp,32
    80004640:	8082                	ret

0000000080004642 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004642:	1101                	addi	sp,sp,-32
    80004644:	ec06                	sd	ra,24(sp)
    80004646:	e822                	sd	s0,16(sp)
    80004648:	e426                	sd	s1,8(sp)
    8000464a:	e04a                	sd	s2,0(sp)
    8000464c:	1000                	addi	s0,sp,32
    8000464e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004650:	00850913          	addi	s2,a0,8
    80004654:	854a                	mv	a0,s2
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	580080e7          	jalr	1408(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000465e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004662:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004666:	8526                	mv	a0,s1
    80004668:	ffffe097          	auipc	ra,0xffffe
    8000466c:	ac2080e7          	jalr	-1342(ra) # 8000212a <wakeup>
  release(&lk->lk);
    80004670:	854a                	mv	a0,s2
    80004672:	ffffc097          	auipc	ra,0xffffc
    80004676:	618080e7          	jalr	1560(ra) # 80000c8a <release>
}
    8000467a:	60e2                	ld	ra,24(sp)
    8000467c:	6442                	ld	s0,16(sp)
    8000467e:	64a2                	ld	s1,8(sp)
    80004680:	6902                	ld	s2,0(sp)
    80004682:	6105                	addi	sp,sp,32
    80004684:	8082                	ret

0000000080004686 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004686:	7179                	addi	sp,sp,-48
    80004688:	f406                	sd	ra,40(sp)
    8000468a:	f022                	sd	s0,32(sp)
    8000468c:	ec26                	sd	s1,24(sp)
    8000468e:	e84a                	sd	s2,16(sp)
    80004690:	e44e                	sd	s3,8(sp)
    80004692:	1800                	addi	s0,sp,48
    80004694:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004696:	00850913          	addi	s2,a0,8
    8000469a:	854a                	mv	a0,s2
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	53a080e7          	jalr	1338(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046a4:	409c                	lw	a5,0(s1)
    800046a6:	ef99                	bnez	a5,800046c4 <holdingsleep+0x3e>
    800046a8:	4481                	li	s1,0
  release(&lk->lk);
    800046aa:	854a                	mv	a0,s2
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	5de080e7          	jalr	1502(ra) # 80000c8a <release>
  return r;
}
    800046b4:	8526                	mv	a0,s1
    800046b6:	70a2                	ld	ra,40(sp)
    800046b8:	7402                	ld	s0,32(sp)
    800046ba:	64e2                	ld	s1,24(sp)
    800046bc:	6942                	ld	s2,16(sp)
    800046be:	69a2                	ld	s3,8(sp)
    800046c0:	6145                	addi	sp,sp,48
    800046c2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046c4:	0284a983          	lw	s3,40(s1)
    800046c8:	ffffd097          	auipc	ra,0xffffd
    800046cc:	2b8080e7          	jalr	696(ra) # 80001980 <myproc>
    800046d0:	5144                	lw	s1,36(a0)
    800046d2:	413484b3          	sub	s1,s1,s3
    800046d6:	0014b493          	seqz	s1,s1
    800046da:	bfc1                	j	800046aa <holdingsleep+0x24>

00000000800046dc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046dc:	1141                	addi	sp,sp,-16
    800046de:	e406                	sd	ra,8(sp)
    800046e0:	e022                	sd	s0,0(sp)
    800046e2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046e4:	00004597          	auipc	a1,0x4
    800046e8:	f9458593          	addi	a1,a1,-108 # 80008678 <syscalls+0x238>
    800046ec:	0001e517          	auipc	a0,0x1e
    800046f0:	b6c50513          	addi	a0,a0,-1172 # 80022258 <ftable>
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	452080e7          	jalr	1106(ra) # 80000b46 <initlock>
}
    800046fc:	60a2                	ld	ra,8(sp)
    800046fe:	6402                	ld	s0,0(sp)
    80004700:	0141                	addi	sp,sp,16
    80004702:	8082                	ret

0000000080004704 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004704:	1101                	addi	sp,sp,-32
    80004706:	ec06                	sd	ra,24(sp)
    80004708:	e822                	sd	s0,16(sp)
    8000470a:	e426                	sd	s1,8(sp)
    8000470c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000470e:	0001e517          	auipc	a0,0x1e
    80004712:	b4a50513          	addi	a0,a0,-1206 # 80022258 <ftable>
    80004716:	ffffc097          	auipc	ra,0xffffc
    8000471a:	4c0080e7          	jalr	1216(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000471e:	0001e497          	auipc	s1,0x1e
    80004722:	b5248493          	addi	s1,s1,-1198 # 80022270 <ftable+0x18>
    80004726:	0001f717          	auipc	a4,0x1f
    8000472a:	aea70713          	addi	a4,a4,-1302 # 80023210 <disk>
    if(f->ref == 0){
    8000472e:	40dc                	lw	a5,4(s1)
    80004730:	cf99                	beqz	a5,8000474e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004732:	02848493          	addi	s1,s1,40
    80004736:	fee49ce3          	bne	s1,a4,8000472e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000473a:	0001e517          	auipc	a0,0x1e
    8000473e:	b1e50513          	addi	a0,a0,-1250 # 80022258 <ftable>
    80004742:	ffffc097          	auipc	ra,0xffffc
    80004746:	548080e7          	jalr	1352(ra) # 80000c8a <release>
  return 0;
    8000474a:	4481                	li	s1,0
    8000474c:	a819                	j	80004762 <filealloc+0x5e>
      f->ref = 1;
    8000474e:	4785                	li	a5,1
    80004750:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004752:	0001e517          	auipc	a0,0x1e
    80004756:	b0650513          	addi	a0,a0,-1274 # 80022258 <ftable>
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	530080e7          	jalr	1328(ra) # 80000c8a <release>
}
    80004762:	8526                	mv	a0,s1
    80004764:	60e2                	ld	ra,24(sp)
    80004766:	6442                	ld	s0,16(sp)
    80004768:	64a2                	ld	s1,8(sp)
    8000476a:	6105                	addi	sp,sp,32
    8000476c:	8082                	ret

000000008000476e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000476e:	1101                	addi	sp,sp,-32
    80004770:	ec06                	sd	ra,24(sp)
    80004772:	e822                	sd	s0,16(sp)
    80004774:	e426                	sd	s1,8(sp)
    80004776:	1000                	addi	s0,sp,32
    80004778:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000477a:	0001e517          	auipc	a0,0x1e
    8000477e:	ade50513          	addi	a0,a0,-1314 # 80022258 <ftable>
    80004782:	ffffc097          	auipc	ra,0xffffc
    80004786:	454080e7          	jalr	1108(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000478a:	40dc                	lw	a5,4(s1)
    8000478c:	02f05263          	blez	a5,800047b0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004790:	2785                	addiw	a5,a5,1
    80004792:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004794:	0001e517          	auipc	a0,0x1e
    80004798:	ac450513          	addi	a0,a0,-1340 # 80022258 <ftable>
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	4ee080e7          	jalr	1262(ra) # 80000c8a <release>
  return f;
}
    800047a4:	8526                	mv	a0,s1
    800047a6:	60e2                	ld	ra,24(sp)
    800047a8:	6442                	ld	s0,16(sp)
    800047aa:	64a2                	ld	s1,8(sp)
    800047ac:	6105                	addi	sp,sp,32
    800047ae:	8082                	ret
    panic("filedup");
    800047b0:	00004517          	auipc	a0,0x4
    800047b4:	ed050513          	addi	a0,a0,-304 # 80008680 <syscalls+0x240>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	d86080e7          	jalr	-634(ra) # 8000053e <panic>

00000000800047c0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047c0:	7139                	addi	sp,sp,-64
    800047c2:	fc06                	sd	ra,56(sp)
    800047c4:	f822                	sd	s0,48(sp)
    800047c6:	f426                	sd	s1,40(sp)
    800047c8:	f04a                	sd	s2,32(sp)
    800047ca:	ec4e                	sd	s3,24(sp)
    800047cc:	e852                	sd	s4,16(sp)
    800047ce:	e456                	sd	s5,8(sp)
    800047d0:	0080                	addi	s0,sp,64
    800047d2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047d4:	0001e517          	auipc	a0,0x1e
    800047d8:	a8450513          	addi	a0,a0,-1404 # 80022258 <ftable>
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	3fa080e7          	jalr	1018(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047e4:	40dc                	lw	a5,4(s1)
    800047e6:	06f05163          	blez	a5,80004848 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047ea:	37fd                	addiw	a5,a5,-1
    800047ec:	0007871b          	sext.w	a4,a5
    800047f0:	c0dc                	sw	a5,4(s1)
    800047f2:	06e04363          	bgtz	a4,80004858 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047f6:	0004a903          	lw	s2,0(s1)
    800047fa:	0094ca83          	lbu	s5,9(s1)
    800047fe:	0104ba03          	ld	s4,16(s1)
    80004802:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004806:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000480a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000480e:	0001e517          	auipc	a0,0x1e
    80004812:	a4a50513          	addi	a0,a0,-1462 # 80022258 <ftable>
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	474080e7          	jalr	1140(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    8000481e:	4785                	li	a5,1
    80004820:	04f90d63          	beq	s2,a5,8000487a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004824:	3979                	addiw	s2,s2,-2
    80004826:	4785                	li	a5,1
    80004828:	0527e063          	bltu	a5,s2,80004868 <fileclose+0xa8>
    begin_op();
    8000482c:	00000097          	auipc	ra,0x0
    80004830:	ac8080e7          	jalr	-1336(ra) # 800042f4 <begin_op>
    iput(ff.ip);
    80004834:	854e                	mv	a0,s3
    80004836:	fffff097          	auipc	ra,0xfffff
    8000483a:	2b6080e7          	jalr	694(ra) # 80003aec <iput>
    end_op();
    8000483e:	00000097          	auipc	ra,0x0
    80004842:	b36080e7          	jalr	-1226(ra) # 80004374 <end_op>
    80004846:	a00d                	j	80004868 <fileclose+0xa8>
    panic("fileclose");
    80004848:	00004517          	auipc	a0,0x4
    8000484c:	e4050513          	addi	a0,a0,-448 # 80008688 <syscalls+0x248>
    80004850:	ffffc097          	auipc	ra,0xffffc
    80004854:	cee080e7          	jalr	-786(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004858:	0001e517          	auipc	a0,0x1e
    8000485c:	a0050513          	addi	a0,a0,-1536 # 80022258 <ftable>
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	42a080e7          	jalr	1066(ra) # 80000c8a <release>
  }
}
    80004868:	70e2                	ld	ra,56(sp)
    8000486a:	7442                	ld	s0,48(sp)
    8000486c:	74a2                	ld	s1,40(sp)
    8000486e:	7902                	ld	s2,32(sp)
    80004870:	69e2                	ld	s3,24(sp)
    80004872:	6a42                	ld	s4,16(sp)
    80004874:	6aa2                	ld	s5,8(sp)
    80004876:	6121                	addi	sp,sp,64
    80004878:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000487a:	85d6                	mv	a1,s5
    8000487c:	8552                	mv	a0,s4
    8000487e:	00000097          	auipc	ra,0x0
    80004882:	34c080e7          	jalr	844(ra) # 80004bca <pipeclose>
    80004886:	b7cd                	j	80004868 <fileclose+0xa8>

0000000080004888 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004888:	715d                	addi	sp,sp,-80
    8000488a:	e486                	sd	ra,72(sp)
    8000488c:	e0a2                	sd	s0,64(sp)
    8000488e:	fc26                	sd	s1,56(sp)
    80004890:	f84a                	sd	s2,48(sp)
    80004892:	f44e                	sd	s3,40(sp)
    80004894:	0880                	addi	s0,sp,80
    80004896:	84aa                	mv	s1,a0
    80004898:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000489a:	ffffd097          	auipc	ra,0xffffd
    8000489e:	0e6080e7          	jalr	230(ra) # 80001980 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048a2:	409c                	lw	a5,0(s1)
    800048a4:	37f9                	addiw	a5,a5,-2
    800048a6:	4705                	li	a4,1
    800048a8:	04f76763          	bltu	a4,a5,800048f6 <filestat+0x6e>
    800048ac:	892a                	mv	s2,a0
    ilock(f->ip);
    800048ae:	6c88                	ld	a0,24(s1)
    800048b0:	fffff097          	auipc	ra,0xfffff
    800048b4:	082080e7          	jalr	130(ra) # 80003932 <ilock>
    stati(f->ip, &st);
    800048b8:	fb840593          	addi	a1,s0,-72
    800048bc:	6c88                	ld	a0,24(s1)
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	2fe080e7          	jalr	766(ra) # 80003bbc <stati>
    iunlock(f->ip);
    800048c6:	6c88                	ld	a0,24(s1)
    800048c8:	fffff097          	auipc	ra,0xfffff
    800048cc:	12c080e7          	jalr	300(ra) # 800039f4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048d0:	46e1                	li	a3,24
    800048d2:	fb840613          	addi	a2,s0,-72
    800048d6:	85ce                	mv	a1,s3
    800048d8:	10093503          	ld	a0,256(s2)
    800048dc:	ffffd097          	auipc	ra,0xffffd
    800048e0:	d8c080e7          	jalr	-628(ra) # 80001668 <copyout>
    800048e4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048e8:	60a6                	ld	ra,72(sp)
    800048ea:	6406                	ld	s0,64(sp)
    800048ec:	74e2                	ld	s1,56(sp)
    800048ee:	7942                	ld	s2,48(sp)
    800048f0:	79a2                	ld	s3,40(sp)
    800048f2:	6161                	addi	sp,sp,80
    800048f4:	8082                	ret
  return -1;
    800048f6:	557d                	li	a0,-1
    800048f8:	bfc5                	j	800048e8 <filestat+0x60>

00000000800048fa <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048fa:	7179                	addi	sp,sp,-48
    800048fc:	f406                	sd	ra,40(sp)
    800048fe:	f022                	sd	s0,32(sp)
    80004900:	ec26                	sd	s1,24(sp)
    80004902:	e84a                	sd	s2,16(sp)
    80004904:	e44e                	sd	s3,8(sp)
    80004906:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004908:	00854783          	lbu	a5,8(a0)
    8000490c:	c3d5                	beqz	a5,800049b0 <fileread+0xb6>
    8000490e:	84aa                	mv	s1,a0
    80004910:	89ae                	mv	s3,a1
    80004912:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004914:	411c                	lw	a5,0(a0)
    80004916:	4705                	li	a4,1
    80004918:	04e78963          	beq	a5,a4,8000496a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000491c:	470d                	li	a4,3
    8000491e:	04e78d63          	beq	a5,a4,80004978 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004922:	4709                	li	a4,2
    80004924:	06e79e63          	bne	a5,a4,800049a0 <fileread+0xa6>
    ilock(f->ip);
    80004928:	6d08                	ld	a0,24(a0)
    8000492a:	fffff097          	auipc	ra,0xfffff
    8000492e:	008080e7          	jalr	8(ra) # 80003932 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004932:	874a                	mv	a4,s2
    80004934:	5094                	lw	a3,32(s1)
    80004936:	864e                	mv	a2,s3
    80004938:	4585                	li	a1,1
    8000493a:	6c88                	ld	a0,24(s1)
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	2aa080e7          	jalr	682(ra) # 80003be6 <readi>
    80004944:	892a                	mv	s2,a0
    80004946:	00a05563          	blez	a0,80004950 <fileread+0x56>
      f->off += r;
    8000494a:	509c                	lw	a5,32(s1)
    8000494c:	9fa9                	addw	a5,a5,a0
    8000494e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004950:	6c88                	ld	a0,24(s1)
    80004952:	fffff097          	auipc	ra,0xfffff
    80004956:	0a2080e7          	jalr	162(ra) # 800039f4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000495a:	854a                	mv	a0,s2
    8000495c:	70a2                	ld	ra,40(sp)
    8000495e:	7402                	ld	s0,32(sp)
    80004960:	64e2                	ld	s1,24(sp)
    80004962:	6942                	ld	s2,16(sp)
    80004964:	69a2                	ld	s3,8(sp)
    80004966:	6145                	addi	sp,sp,48
    80004968:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000496a:	6908                	ld	a0,16(a0)
    8000496c:	00000097          	auipc	ra,0x0
    80004970:	3c6080e7          	jalr	966(ra) # 80004d32 <piperead>
    80004974:	892a                	mv	s2,a0
    80004976:	b7d5                	j	8000495a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004978:	02451783          	lh	a5,36(a0)
    8000497c:	03079693          	slli	a3,a5,0x30
    80004980:	92c1                	srli	a3,a3,0x30
    80004982:	4725                	li	a4,9
    80004984:	02d76863          	bltu	a4,a3,800049b4 <fileread+0xba>
    80004988:	0792                	slli	a5,a5,0x4
    8000498a:	0001e717          	auipc	a4,0x1e
    8000498e:	82e70713          	addi	a4,a4,-2002 # 800221b8 <devsw>
    80004992:	97ba                	add	a5,a5,a4
    80004994:	639c                	ld	a5,0(a5)
    80004996:	c38d                	beqz	a5,800049b8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004998:	4505                	li	a0,1
    8000499a:	9782                	jalr	a5
    8000499c:	892a                	mv	s2,a0
    8000499e:	bf75                	j	8000495a <fileread+0x60>
    panic("fileread");
    800049a0:	00004517          	auipc	a0,0x4
    800049a4:	cf850513          	addi	a0,a0,-776 # 80008698 <syscalls+0x258>
    800049a8:	ffffc097          	auipc	ra,0xffffc
    800049ac:	b96080e7          	jalr	-1130(ra) # 8000053e <panic>
    return -1;
    800049b0:	597d                	li	s2,-1
    800049b2:	b765                	j	8000495a <fileread+0x60>
      return -1;
    800049b4:	597d                	li	s2,-1
    800049b6:	b755                	j	8000495a <fileread+0x60>
    800049b8:	597d                	li	s2,-1
    800049ba:	b745                	j	8000495a <fileread+0x60>

00000000800049bc <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800049bc:	715d                	addi	sp,sp,-80
    800049be:	e486                	sd	ra,72(sp)
    800049c0:	e0a2                	sd	s0,64(sp)
    800049c2:	fc26                	sd	s1,56(sp)
    800049c4:	f84a                	sd	s2,48(sp)
    800049c6:	f44e                	sd	s3,40(sp)
    800049c8:	f052                	sd	s4,32(sp)
    800049ca:	ec56                	sd	s5,24(sp)
    800049cc:	e85a                	sd	s6,16(sp)
    800049ce:	e45e                	sd	s7,8(sp)
    800049d0:	e062                	sd	s8,0(sp)
    800049d2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049d4:	00954783          	lbu	a5,9(a0)
    800049d8:	10078663          	beqz	a5,80004ae4 <filewrite+0x128>
    800049dc:	892a                	mv	s2,a0
    800049de:	8aae                	mv	s5,a1
    800049e0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049e2:	411c                	lw	a5,0(a0)
    800049e4:	4705                	li	a4,1
    800049e6:	02e78263          	beq	a5,a4,80004a0a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049ea:	470d                	li	a4,3
    800049ec:	02e78663          	beq	a5,a4,80004a18 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049f0:	4709                	li	a4,2
    800049f2:	0ee79163          	bne	a5,a4,80004ad4 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049f6:	0ac05d63          	blez	a2,80004ab0 <filewrite+0xf4>
    int i = 0;
    800049fa:	4981                	li	s3,0
    800049fc:	6b05                	lui	s6,0x1
    800049fe:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a02:	6b85                	lui	s7,0x1
    80004a04:	c00b8b9b          	addiw	s7,s7,-1024
    80004a08:	a861                	j	80004aa0 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004a0a:	6908                	ld	a0,16(a0)
    80004a0c:	00000097          	auipc	ra,0x0
    80004a10:	22e080e7          	jalr	558(ra) # 80004c3a <pipewrite>
    80004a14:	8a2a                	mv	s4,a0
    80004a16:	a045                	j	80004ab6 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a18:	02451783          	lh	a5,36(a0)
    80004a1c:	03079693          	slli	a3,a5,0x30
    80004a20:	92c1                	srli	a3,a3,0x30
    80004a22:	4725                	li	a4,9
    80004a24:	0cd76263          	bltu	a4,a3,80004ae8 <filewrite+0x12c>
    80004a28:	0792                	slli	a5,a5,0x4
    80004a2a:	0001d717          	auipc	a4,0x1d
    80004a2e:	78e70713          	addi	a4,a4,1934 # 800221b8 <devsw>
    80004a32:	97ba                	add	a5,a5,a4
    80004a34:	679c                	ld	a5,8(a5)
    80004a36:	cbdd                	beqz	a5,80004aec <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a38:	4505                	li	a0,1
    80004a3a:	9782                	jalr	a5
    80004a3c:	8a2a                	mv	s4,a0
    80004a3e:	a8a5                	j	80004ab6 <filewrite+0xfa>
    80004a40:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a44:	00000097          	auipc	ra,0x0
    80004a48:	8b0080e7          	jalr	-1872(ra) # 800042f4 <begin_op>
      ilock(f->ip);
    80004a4c:	01893503          	ld	a0,24(s2)
    80004a50:	fffff097          	auipc	ra,0xfffff
    80004a54:	ee2080e7          	jalr	-286(ra) # 80003932 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a58:	8762                	mv	a4,s8
    80004a5a:	02092683          	lw	a3,32(s2)
    80004a5e:	01598633          	add	a2,s3,s5
    80004a62:	4585                	li	a1,1
    80004a64:	01893503          	ld	a0,24(s2)
    80004a68:	fffff097          	auipc	ra,0xfffff
    80004a6c:	276080e7          	jalr	630(ra) # 80003cde <writei>
    80004a70:	84aa                	mv	s1,a0
    80004a72:	00a05763          	blez	a0,80004a80 <filewrite+0xc4>
        f->off += r;
    80004a76:	02092783          	lw	a5,32(s2)
    80004a7a:	9fa9                	addw	a5,a5,a0
    80004a7c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a80:	01893503          	ld	a0,24(s2)
    80004a84:	fffff097          	auipc	ra,0xfffff
    80004a88:	f70080e7          	jalr	-144(ra) # 800039f4 <iunlock>
      end_op();
    80004a8c:	00000097          	auipc	ra,0x0
    80004a90:	8e8080e7          	jalr	-1816(ra) # 80004374 <end_op>

      if(r != n1){
    80004a94:	009c1f63          	bne	s8,s1,80004ab2 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a98:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a9c:	0149db63          	bge	s3,s4,80004ab2 <filewrite+0xf6>
      int n1 = n - i;
    80004aa0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004aa4:	84be                	mv	s1,a5
    80004aa6:	2781                	sext.w	a5,a5
    80004aa8:	f8fb5ce3          	bge	s6,a5,80004a40 <filewrite+0x84>
    80004aac:	84de                	mv	s1,s7
    80004aae:	bf49                	j	80004a40 <filewrite+0x84>
    int i = 0;
    80004ab0:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004ab2:	013a1f63          	bne	s4,s3,80004ad0 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ab6:	8552                	mv	a0,s4
    80004ab8:	60a6                	ld	ra,72(sp)
    80004aba:	6406                	ld	s0,64(sp)
    80004abc:	74e2                	ld	s1,56(sp)
    80004abe:	7942                	ld	s2,48(sp)
    80004ac0:	79a2                	ld	s3,40(sp)
    80004ac2:	7a02                	ld	s4,32(sp)
    80004ac4:	6ae2                	ld	s5,24(sp)
    80004ac6:	6b42                	ld	s6,16(sp)
    80004ac8:	6ba2                	ld	s7,8(sp)
    80004aca:	6c02                	ld	s8,0(sp)
    80004acc:	6161                	addi	sp,sp,80
    80004ace:	8082                	ret
    ret = (i == n ? n : -1);
    80004ad0:	5a7d                	li	s4,-1
    80004ad2:	b7d5                	j	80004ab6 <filewrite+0xfa>
    panic("filewrite");
    80004ad4:	00004517          	auipc	a0,0x4
    80004ad8:	bd450513          	addi	a0,a0,-1068 # 800086a8 <syscalls+0x268>
    80004adc:	ffffc097          	auipc	ra,0xffffc
    80004ae0:	a62080e7          	jalr	-1438(ra) # 8000053e <panic>
    return -1;
    80004ae4:	5a7d                	li	s4,-1
    80004ae6:	bfc1                	j	80004ab6 <filewrite+0xfa>
      return -1;
    80004ae8:	5a7d                	li	s4,-1
    80004aea:	b7f1                	j	80004ab6 <filewrite+0xfa>
    80004aec:	5a7d                	li	s4,-1
    80004aee:	b7e1                	j	80004ab6 <filewrite+0xfa>

0000000080004af0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004af0:	7179                	addi	sp,sp,-48
    80004af2:	f406                	sd	ra,40(sp)
    80004af4:	f022                	sd	s0,32(sp)
    80004af6:	ec26                	sd	s1,24(sp)
    80004af8:	e84a                	sd	s2,16(sp)
    80004afa:	e44e                	sd	s3,8(sp)
    80004afc:	e052                	sd	s4,0(sp)
    80004afe:	1800                	addi	s0,sp,48
    80004b00:	84aa                	mv	s1,a0
    80004b02:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b04:	0005b023          	sd	zero,0(a1)
    80004b08:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b0c:	00000097          	auipc	ra,0x0
    80004b10:	bf8080e7          	jalr	-1032(ra) # 80004704 <filealloc>
    80004b14:	e088                	sd	a0,0(s1)
    80004b16:	c551                	beqz	a0,80004ba2 <pipealloc+0xb2>
    80004b18:	00000097          	auipc	ra,0x0
    80004b1c:	bec080e7          	jalr	-1044(ra) # 80004704 <filealloc>
    80004b20:	00aa3023          	sd	a0,0(s4)
    80004b24:	c92d                	beqz	a0,80004b96 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	fc0080e7          	jalr	-64(ra) # 80000ae6 <kalloc>
    80004b2e:	892a                	mv	s2,a0
    80004b30:	c125                	beqz	a0,80004b90 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b32:	4985                	li	s3,1
    80004b34:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b38:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b3c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b40:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b44:	00004597          	auipc	a1,0x4
    80004b48:	b7458593          	addi	a1,a1,-1164 # 800086b8 <syscalls+0x278>
    80004b4c:	ffffc097          	auipc	ra,0xffffc
    80004b50:	ffa080e7          	jalr	-6(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004b54:	609c                	ld	a5,0(s1)
    80004b56:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b5a:	609c                	ld	a5,0(s1)
    80004b5c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b60:	609c                	ld	a5,0(s1)
    80004b62:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b66:	609c                	ld	a5,0(s1)
    80004b68:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b6c:	000a3783          	ld	a5,0(s4)
    80004b70:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b74:	000a3783          	ld	a5,0(s4)
    80004b78:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b7c:	000a3783          	ld	a5,0(s4)
    80004b80:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b84:	000a3783          	ld	a5,0(s4)
    80004b88:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b8c:	4501                	li	a0,0
    80004b8e:	a025                	j	80004bb6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b90:	6088                	ld	a0,0(s1)
    80004b92:	e501                	bnez	a0,80004b9a <pipealloc+0xaa>
    80004b94:	a039                	j	80004ba2 <pipealloc+0xb2>
    80004b96:	6088                	ld	a0,0(s1)
    80004b98:	c51d                	beqz	a0,80004bc6 <pipealloc+0xd6>
    fileclose(*f0);
    80004b9a:	00000097          	auipc	ra,0x0
    80004b9e:	c26080e7          	jalr	-986(ra) # 800047c0 <fileclose>
  if(*f1)
    80004ba2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ba6:	557d                	li	a0,-1
  if(*f1)
    80004ba8:	c799                	beqz	a5,80004bb6 <pipealloc+0xc6>
    fileclose(*f1);
    80004baa:	853e                	mv	a0,a5
    80004bac:	00000097          	auipc	ra,0x0
    80004bb0:	c14080e7          	jalr	-1004(ra) # 800047c0 <fileclose>
  return -1;
    80004bb4:	557d                	li	a0,-1
}
    80004bb6:	70a2                	ld	ra,40(sp)
    80004bb8:	7402                	ld	s0,32(sp)
    80004bba:	64e2                	ld	s1,24(sp)
    80004bbc:	6942                	ld	s2,16(sp)
    80004bbe:	69a2                	ld	s3,8(sp)
    80004bc0:	6a02                	ld	s4,0(sp)
    80004bc2:	6145                	addi	sp,sp,48
    80004bc4:	8082                	ret
  return -1;
    80004bc6:	557d                	li	a0,-1
    80004bc8:	b7fd                	j	80004bb6 <pipealloc+0xc6>

0000000080004bca <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bca:	1101                	addi	sp,sp,-32
    80004bcc:	ec06                	sd	ra,24(sp)
    80004bce:	e822                	sd	s0,16(sp)
    80004bd0:	e426                	sd	s1,8(sp)
    80004bd2:	e04a                	sd	s2,0(sp)
    80004bd4:	1000                	addi	s0,sp,32
    80004bd6:	84aa                	mv	s1,a0
    80004bd8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	ffc080e7          	jalr	-4(ra) # 80000bd6 <acquire>
  if(writable){
    80004be2:	02090d63          	beqz	s2,80004c1c <pipeclose+0x52>
    pi->writeopen = 0;
    80004be6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bea:	21848513          	addi	a0,s1,536
    80004bee:	ffffd097          	auipc	ra,0xffffd
    80004bf2:	53c080e7          	jalr	1340(ra) # 8000212a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bf6:	2204b783          	ld	a5,544(s1)
    80004bfa:	eb95                	bnez	a5,80004c2e <pipeclose+0x64>
    release(&pi->lock);
    80004bfc:	8526                	mv	a0,s1
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	08c080e7          	jalr	140(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004c06:	8526                	mv	a0,s1
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	de2080e7          	jalr	-542(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004c10:	60e2                	ld	ra,24(sp)
    80004c12:	6442                	ld	s0,16(sp)
    80004c14:	64a2                	ld	s1,8(sp)
    80004c16:	6902                	ld	s2,0(sp)
    80004c18:	6105                	addi	sp,sp,32
    80004c1a:	8082                	ret
    pi->readopen = 0;
    80004c1c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c20:	21c48513          	addi	a0,s1,540
    80004c24:	ffffd097          	auipc	ra,0xffffd
    80004c28:	506080e7          	jalr	1286(ra) # 8000212a <wakeup>
    80004c2c:	b7e9                	j	80004bf6 <pipeclose+0x2c>
    release(&pi->lock);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	05a080e7          	jalr	90(ra) # 80000c8a <release>
}
    80004c38:	bfe1                	j	80004c10 <pipeclose+0x46>

0000000080004c3a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c3a:	711d                	addi	sp,sp,-96
    80004c3c:	ec86                	sd	ra,88(sp)
    80004c3e:	e8a2                	sd	s0,80(sp)
    80004c40:	e4a6                	sd	s1,72(sp)
    80004c42:	e0ca                	sd	s2,64(sp)
    80004c44:	fc4e                	sd	s3,56(sp)
    80004c46:	f852                	sd	s4,48(sp)
    80004c48:	f456                	sd	s5,40(sp)
    80004c4a:	f05a                	sd	s6,32(sp)
    80004c4c:	ec5e                	sd	s7,24(sp)
    80004c4e:	e862                	sd	s8,16(sp)
    80004c50:	1080                	addi	s0,sp,96
    80004c52:	84aa                	mv	s1,a0
    80004c54:	8aae                	mv	s5,a1
    80004c56:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c58:	ffffd097          	auipc	ra,0xffffd
    80004c5c:	d28080e7          	jalr	-728(ra) # 80001980 <myproc>
    80004c60:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c62:	8526                	mv	a0,s1
    80004c64:	ffffc097          	auipc	ra,0xffffc
    80004c68:	f72080e7          	jalr	-142(ra) # 80000bd6 <acquire>
  while(i < n){
    80004c6c:	0b405663          	blez	s4,80004d18 <pipewrite+0xde>
  int i = 0;
    80004c70:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c72:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c74:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c78:	21c48b93          	addi	s7,s1,540
    80004c7c:	a089                	j	80004cbe <pipewrite+0x84>
      release(&pi->lock);
    80004c7e:	8526                	mv	a0,s1
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
      return -1;
    80004c88:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c8a:	854a                	mv	a0,s2
    80004c8c:	60e6                	ld	ra,88(sp)
    80004c8e:	6446                	ld	s0,80(sp)
    80004c90:	64a6                	ld	s1,72(sp)
    80004c92:	6906                	ld	s2,64(sp)
    80004c94:	79e2                	ld	s3,56(sp)
    80004c96:	7a42                	ld	s4,48(sp)
    80004c98:	7aa2                	ld	s5,40(sp)
    80004c9a:	7b02                	ld	s6,32(sp)
    80004c9c:	6be2                	ld	s7,24(sp)
    80004c9e:	6c42                	ld	s8,16(sp)
    80004ca0:	6125                	addi	sp,sp,96
    80004ca2:	8082                	ret
      wakeup(&pi->nread);
    80004ca4:	8562                	mv	a0,s8
    80004ca6:	ffffd097          	auipc	ra,0xffffd
    80004caa:	484080e7          	jalr	1156(ra) # 8000212a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cae:	85a6                	mv	a1,s1
    80004cb0:	855e                	mv	a0,s7
    80004cb2:	ffffd097          	auipc	ra,0xffffd
    80004cb6:	40a080e7          	jalr	1034(ra) # 800020bc <sleep>
  while(i < n){
    80004cba:	07495063          	bge	s2,s4,80004d1a <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004cbe:	2204a783          	lw	a5,544(s1)
    80004cc2:	dfd5                	beqz	a5,80004c7e <pipewrite+0x44>
    80004cc4:	854e                	mv	a0,s3
    80004cc6:	ffffd097          	auipc	ra,0xffffd
    80004cca:	6ee080e7          	jalr	1774(ra) # 800023b4 <killed>
    80004cce:	f945                	bnez	a0,80004c7e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cd0:	2184a783          	lw	a5,536(s1)
    80004cd4:	21c4a703          	lw	a4,540(s1)
    80004cd8:	2007879b          	addiw	a5,a5,512
    80004cdc:	fcf704e3          	beq	a4,a5,80004ca4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ce0:	4685                	li	a3,1
    80004ce2:	01590633          	add	a2,s2,s5
    80004ce6:	faf40593          	addi	a1,s0,-81
    80004cea:	1009b503          	ld	a0,256(s3)
    80004cee:	ffffd097          	auipc	ra,0xffffd
    80004cf2:	a06080e7          	jalr	-1530(ra) # 800016f4 <copyin>
    80004cf6:	03650263          	beq	a0,s6,80004d1a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cfa:	21c4a783          	lw	a5,540(s1)
    80004cfe:	0017871b          	addiw	a4,a5,1
    80004d02:	20e4ae23          	sw	a4,540(s1)
    80004d06:	1ff7f793          	andi	a5,a5,511
    80004d0a:	97a6                	add	a5,a5,s1
    80004d0c:	faf44703          	lbu	a4,-81(s0)
    80004d10:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d14:	2905                	addiw	s2,s2,1
    80004d16:	b755                	j	80004cba <pipewrite+0x80>
  int i = 0;
    80004d18:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d1a:	21848513          	addi	a0,s1,536
    80004d1e:	ffffd097          	auipc	ra,0xffffd
    80004d22:	40c080e7          	jalr	1036(ra) # 8000212a <wakeup>
  release(&pi->lock);
    80004d26:	8526                	mv	a0,s1
    80004d28:	ffffc097          	auipc	ra,0xffffc
    80004d2c:	f62080e7          	jalr	-158(ra) # 80000c8a <release>
  return i;
    80004d30:	bfa9                	j	80004c8a <pipewrite+0x50>

0000000080004d32 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d32:	715d                	addi	sp,sp,-80
    80004d34:	e486                	sd	ra,72(sp)
    80004d36:	e0a2                	sd	s0,64(sp)
    80004d38:	fc26                	sd	s1,56(sp)
    80004d3a:	f84a                	sd	s2,48(sp)
    80004d3c:	f44e                	sd	s3,40(sp)
    80004d3e:	f052                	sd	s4,32(sp)
    80004d40:	ec56                	sd	s5,24(sp)
    80004d42:	e85a                	sd	s6,16(sp)
    80004d44:	0880                	addi	s0,sp,80
    80004d46:	84aa                	mv	s1,a0
    80004d48:	892e                	mv	s2,a1
    80004d4a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d4c:	ffffd097          	auipc	ra,0xffffd
    80004d50:	c34080e7          	jalr	-972(ra) # 80001980 <myproc>
    80004d54:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d56:	8526                	mv	a0,s1
    80004d58:	ffffc097          	auipc	ra,0xffffc
    80004d5c:	e7e080e7          	jalr	-386(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d60:	2184a703          	lw	a4,536(s1)
    80004d64:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d68:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d6c:	02f71763          	bne	a4,a5,80004d9a <piperead+0x68>
    80004d70:	2244a783          	lw	a5,548(s1)
    80004d74:	c39d                	beqz	a5,80004d9a <piperead+0x68>
    if(killed(pr)){
    80004d76:	8552                	mv	a0,s4
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	63c080e7          	jalr	1596(ra) # 800023b4 <killed>
    80004d80:	e941                	bnez	a0,80004e10 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d82:	85a6                	mv	a1,s1
    80004d84:	854e                	mv	a0,s3
    80004d86:	ffffd097          	auipc	ra,0xffffd
    80004d8a:	336080e7          	jalr	822(ra) # 800020bc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d8e:	2184a703          	lw	a4,536(s1)
    80004d92:	21c4a783          	lw	a5,540(s1)
    80004d96:	fcf70de3          	beq	a4,a5,80004d70 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d9a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d9c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d9e:	05505363          	blez	s5,80004de4 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004da2:	2184a783          	lw	a5,536(s1)
    80004da6:	21c4a703          	lw	a4,540(s1)
    80004daa:	02f70d63          	beq	a4,a5,80004de4 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dae:	0017871b          	addiw	a4,a5,1
    80004db2:	20e4ac23          	sw	a4,536(s1)
    80004db6:	1ff7f793          	andi	a5,a5,511
    80004dba:	97a6                	add	a5,a5,s1
    80004dbc:	0187c783          	lbu	a5,24(a5)
    80004dc0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dc4:	4685                	li	a3,1
    80004dc6:	fbf40613          	addi	a2,s0,-65
    80004dca:	85ca                	mv	a1,s2
    80004dcc:	100a3503          	ld	a0,256(s4)
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	898080e7          	jalr	-1896(ra) # 80001668 <copyout>
    80004dd8:	01650663          	beq	a0,s6,80004de4 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ddc:	2985                	addiw	s3,s3,1
    80004dde:	0905                	addi	s2,s2,1
    80004de0:	fd3a91e3          	bne	s5,s3,80004da2 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004de4:	21c48513          	addi	a0,s1,540
    80004de8:	ffffd097          	auipc	ra,0xffffd
    80004dec:	342080e7          	jalr	834(ra) # 8000212a <wakeup>
  release(&pi->lock);
    80004df0:	8526                	mv	a0,s1
    80004df2:	ffffc097          	auipc	ra,0xffffc
    80004df6:	e98080e7          	jalr	-360(ra) # 80000c8a <release>
  return i;
}
    80004dfa:	854e                	mv	a0,s3
    80004dfc:	60a6                	ld	ra,72(sp)
    80004dfe:	6406                	ld	s0,64(sp)
    80004e00:	74e2                	ld	s1,56(sp)
    80004e02:	7942                	ld	s2,48(sp)
    80004e04:	79a2                	ld	s3,40(sp)
    80004e06:	7a02                	ld	s4,32(sp)
    80004e08:	6ae2                	ld	s5,24(sp)
    80004e0a:	6b42                	ld	s6,16(sp)
    80004e0c:	6161                	addi	sp,sp,80
    80004e0e:	8082                	ret
      release(&pi->lock);
    80004e10:	8526                	mv	a0,s1
    80004e12:	ffffc097          	auipc	ra,0xffffc
    80004e16:	e78080e7          	jalr	-392(ra) # 80000c8a <release>
      return -1;
    80004e1a:	59fd                	li	s3,-1
    80004e1c:	bff9                	j	80004dfa <piperead+0xc8>

0000000080004e1e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e1e:	1141                	addi	sp,sp,-16
    80004e20:	e422                	sd	s0,8(sp)
    80004e22:	0800                	addi	s0,sp,16
    80004e24:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e26:	8905                	andi	a0,a0,1
    80004e28:	c111                	beqz	a0,80004e2c <flags2perm+0xe>
      perm = PTE_X;
    80004e2a:	4521                	li	a0,8
    if(flags & 0x2)
    80004e2c:	8b89                	andi	a5,a5,2
    80004e2e:	c399                	beqz	a5,80004e34 <flags2perm+0x16>
      perm |= PTE_W;
    80004e30:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e34:	6422                	ld	s0,8(sp)
    80004e36:	0141                	addi	sp,sp,16
    80004e38:	8082                	ret

0000000080004e3a <exec>:

int
exec(char *path, char **argv)
{
    80004e3a:	de010113          	addi	sp,sp,-544
    80004e3e:	20113c23          	sd	ra,536(sp)
    80004e42:	20813823          	sd	s0,528(sp)
    80004e46:	20913423          	sd	s1,520(sp)
    80004e4a:	21213023          	sd	s2,512(sp)
    80004e4e:	ffce                	sd	s3,504(sp)
    80004e50:	fbd2                	sd	s4,496(sp)
    80004e52:	f7d6                	sd	s5,488(sp)
    80004e54:	f3da                	sd	s6,480(sp)
    80004e56:	efde                	sd	s7,472(sp)
    80004e58:	ebe2                	sd	s8,464(sp)
    80004e5a:	e7e6                	sd	s9,456(sp)
    80004e5c:	e3ea                	sd	s10,448(sp)
    80004e5e:	ff6e                	sd	s11,440(sp)
    80004e60:	1400                	addi	s0,sp,544
    80004e62:	892a                	mv	s2,a0
    80004e64:	dea43423          	sd	a0,-536(s0)
    80004e68:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e6c:	ffffd097          	auipc	ra,0xffffd
    80004e70:	b14080e7          	jalr	-1260(ra) # 80001980 <myproc>
    80004e74:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80004e76:	ffffe097          	auipc	ra,0xffffe
    80004e7a:	86e080e7          	jalr	-1938(ra) # 800026e4 <mykthread>

  begin_op();
    80004e7e:	fffff097          	auipc	ra,0xfffff
    80004e82:	476080e7          	jalr	1142(ra) # 800042f4 <begin_op>

  if((ip = namei(path)) == 0){
    80004e86:	854a                	mv	a0,s2
    80004e88:	fffff097          	auipc	ra,0xfffff
    80004e8c:	250080e7          	jalr	592(ra) # 800040d8 <namei>
    80004e90:	c93d                	beqz	a0,80004f06 <exec+0xcc>
    80004e92:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e94:	fffff097          	auipc	ra,0xfffff
    80004e98:	a9e080e7          	jalr	-1378(ra) # 80003932 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e9c:	04000713          	li	a4,64
    80004ea0:	4681                	li	a3,0
    80004ea2:	e5040613          	addi	a2,s0,-432
    80004ea6:	4581                	li	a1,0
    80004ea8:	8556                	mv	a0,s5
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	d3c080e7          	jalr	-708(ra) # 80003be6 <readi>
    80004eb2:	04000793          	li	a5,64
    80004eb6:	00f51a63          	bne	a0,a5,80004eca <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004eba:	e5042703          	lw	a4,-432(s0)
    80004ebe:	464c47b7          	lui	a5,0x464c4
    80004ec2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ec6:	04f70663          	beq	a4,a5,80004f12 <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004eca:	8556                	mv	a0,s5
    80004ecc:	fffff097          	auipc	ra,0xfffff
    80004ed0:	cc8080e7          	jalr	-824(ra) # 80003b94 <iunlockput>
    end_op();
    80004ed4:	fffff097          	auipc	ra,0xfffff
    80004ed8:	4a0080e7          	jalr	1184(ra) # 80004374 <end_op>
  }
  return -1;
    80004edc:	557d                	li	a0,-1
}
    80004ede:	21813083          	ld	ra,536(sp)
    80004ee2:	21013403          	ld	s0,528(sp)
    80004ee6:	20813483          	ld	s1,520(sp)
    80004eea:	20013903          	ld	s2,512(sp)
    80004eee:	79fe                	ld	s3,504(sp)
    80004ef0:	7a5e                	ld	s4,496(sp)
    80004ef2:	7abe                	ld	s5,488(sp)
    80004ef4:	7b1e                	ld	s6,480(sp)
    80004ef6:	6bfe                	ld	s7,472(sp)
    80004ef8:	6c5e                	ld	s8,464(sp)
    80004efa:	6cbe                	ld	s9,456(sp)
    80004efc:	6d1e                	ld	s10,448(sp)
    80004efe:	7dfa                	ld	s11,440(sp)
    80004f00:	22010113          	addi	sp,sp,544
    80004f04:	8082                	ret
    end_op();
    80004f06:	fffff097          	auipc	ra,0xfffff
    80004f0a:	46e080e7          	jalr	1134(ra) # 80004374 <end_op>
    return -1;
    80004f0e:	557d                	li	a0,-1
    80004f10:	b7f9                	j	80004ede <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f12:	8526                	mv	a0,s1
    80004f14:	ffffd097          	auipc	ra,0xffffd
    80004f18:	aee080e7          	jalr	-1298(ra) # 80001a02 <proc_pagetable>
    80004f1c:	8b2a                	mv	s6,a0
    80004f1e:	d555                	beqz	a0,80004eca <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f20:	e7042783          	lw	a5,-400(s0)
    80004f24:	e8845703          	lhu	a4,-376(s0)
    80004f28:	c735                	beqz	a4,80004f94 <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f2a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f2c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f30:	6a05                	lui	s4,0x1
    80004f32:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f36:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f3a:	6d85                	lui	s11,0x1
    80004f3c:	7d7d                	lui	s10,0xfffff
    80004f3e:	a4a9                	j	80005188 <exec+0x34e>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f40:	00003517          	auipc	a0,0x3
    80004f44:	78050513          	addi	a0,a0,1920 # 800086c0 <syscalls+0x280>
    80004f48:	ffffb097          	auipc	ra,0xffffb
    80004f4c:	5f6080e7          	jalr	1526(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f50:	874a                	mv	a4,s2
    80004f52:	009c86bb          	addw	a3,s9,s1
    80004f56:	4581                	li	a1,0
    80004f58:	8556                	mv	a0,s5
    80004f5a:	fffff097          	auipc	ra,0xfffff
    80004f5e:	c8c080e7          	jalr	-884(ra) # 80003be6 <readi>
    80004f62:	2501                	sext.w	a0,a0
    80004f64:	1aa91f63          	bne	s2,a0,80005122 <exec+0x2e8>
  for(i = 0; i < sz; i += PGSIZE){
    80004f68:	009d84bb          	addw	s1,s11,s1
    80004f6c:	013d09bb          	addw	s3,s10,s3
    80004f70:	1f74fc63          	bgeu	s1,s7,80005168 <exec+0x32e>
    pa = walkaddr(pagetable, va + i);
    80004f74:	02049593          	slli	a1,s1,0x20
    80004f78:	9181                	srli	a1,a1,0x20
    80004f7a:	95e2                	add	a1,a1,s8
    80004f7c:	855a                	mv	a0,s6
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	0de080e7          	jalr	222(ra) # 8000105c <walkaddr>
    80004f86:	862a                	mv	a2,a0
    if(pa == 0)
    80004f88:	dd45                	beqz	a0,80004f40 <exec+0x106>
      n = PGSIZE;
    80004f8a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f8c:	fd49f2e3          	bgeu	s3,s4,80004f50 <exec+0x116>
      n = sz - i;
    80004f90:	894e                	mv	s2,s3
    80004f92:	bf7d                	j	80004f50 <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f94:	4901                	li	s2,0
  iunlockput(ip);
    80004f96:	8556                	mv	a0,s5
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	bfc080e7          	jalr	-1028(ra) # 80003b94 <iunlockput>
  end_op();
    80004fa0:	fffff097          	auipc	ra,0xfffff
    80004fa4:	3d4080e7          	jalr	980(ra) # 80004374 <end_op>
  p = myproc();
    80004fa8:	ffffd097          	auipc	ra,0xffffd
    80004fac:	9d8080e7          	jalr	-1576(ra) # 80001980 <myproc>
    80004fb0:	8baa                	mv	s7,a0
  kt = mykthread();
    80004fb2:	ffffd097          	auipc	ra,0xffffd
    80004fb6:	732080e7          	jalr	1842(ra) # 800026e4 <mykthread>
    80004fba:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004fbc:	0f8bbd83          	ld	s11,248(s7) # 10f8 <_entry-0x7fffef08>
  sz = PGROUNDUP(sz);
    80004fc0:	6785                	lui	a5,0x1
    80004fc2:	17fd                	addi	a5,a5,-1
    80004fc4:	993e                	add	s2,s2,a5
    80004fc6:	77fd                	lui	a5,0xfffff
    80004fc8:	00f977b3          	and	a5,s2,a5
    80004fcc:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fd0:	4691                	li	a3,4
    80004fd2:	6609                	lui	a2,0x2
    80004fd4:	963e                	add	a2,a2,a5
    80004fd6:	85be                	mv	a1,a5
    80004fd8:	855a                	mv	a0,s6
    80004fda:	ffffc097          	auipc	ra,0xffffc
    80004fde:	436080e7          	jalr	1078(ra) # 80001410 <uvmalloc>
    80004fe2:	8c2a                	mv	s8,a0
  ip = 0;
    80004fe4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fe6:	12050e63          	beqz	a0,80005122 <exec+0x2e8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fea:	75f9                	lui	a1,0xffffe
    80004fec:	95aa                	add	a1,a1,a0
    80004fee:	855a                	mv	a0,s6
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	646080e7          	jalr	1606(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ff8:	7afd                	lui	s5,0xfffff
    80004ffa:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004ffc:	df043783          	ld	a5,-528(s0)
    80005000:	6388                	ld	a0,0(a5)
    80005002:	c925                	beqz	a0,80005072 <exec+0x238>
    80005004:	e9040993          	addi	s3,s0,-368
    80005008:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000500c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000500e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005010:	ffffc097          	auipc	ra,0xffffc
    80005014:	e3e080e7          	jalr	-450(ra) # 80000e4e <strlen>
    80005018:	0015079b          	addiw	a5,a0,1
    8000501c:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005020:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005024:	13596663          	bltu	s2,s5,80005150 <exec+0x316>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005028:	df043783          	ld	a5,-528(s0)
    8000502c:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffdbcb0>
    80005030:	8552                	mv	a0,s4
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	e1c080e7          	jalr	-484(ra) # 80000e4e <strlen>
    8000503a:	0015069b          	addiw	a3,a0,1
    8000503e:	8652                	mv	a2,s4
    80005040:	85ca                	mv	a1,s2
    80005042:	855a                	mv	a0,s6
    80005044:	ffffc097          	auipc	ra,0xffffc
    80005048:	624080e7          	jalr	1572(ra) # 80001668 <copyout>
    8000504c:	10054663          	bltz	a0,80005158 <exec+0x31e>
    ustack[argc] = sp;
    80005050:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005054:	0485                	addi	s1,s1,1
    80005056:	df043783          	ld	a5,-528(s0)
    8000505a:	07a1                	addi	a5,a5,8
    8000505c:	def43823          	sd	a5,-528(s0)
    80005060:	6388                	ld	a0,0(a5)
    80005062:	c911                	beqz	a0,80005076 <exec+0x23c>
    if(argc >= MAXARG)
    80005064:	09a1                	addi	s3,s3,8
    80005066:	fb3c95e3          	bne	s9,s3,80005010 <exec+0x1d6>
  sz = sz1;
    8000506a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000506e:	4a81                	li	s5,0
    80005070:	a84d                	j	80005122 <exec+0x2e8>
  sp = sz;
    80005072:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005074:	4481                	li	s1,0
  ustack[argc] = 0;
    80005076:	00349793          	slli	a5,s1,0x3
    8000507a:	f9040713          	addi	a4,s0,-112
    8000507e:	97ba                	add	a5,a5,a4
    80005080:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005084:	00148693          	addi	a3,s1,1
    80005088:	068e                	slli	a3,a3,0x3
    8000508a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000508e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005092:	01597663          	bgeu	s2,s5,8000509e <exec+0x264>
  sz = sz1;
    80005096:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000509a:	4a81                	li	s5,0
    8000509c:	a059                	j	80005122 <exec+0x2e8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000509e:	e9040613          	addi	a2,s0,-368
    800050a2:	85ca                	mv	a1,s2
    800050a4:	855a                	mv	a0,s6
    800050a6:	ffffc097          	auipc	ra,0xffffc
    800050aa:	5c2080e7          	jalr	1474(ra) # 80001668 <copyout>
    800050ae:	0a054963          	bltz	a0,80005160 <exec+0x326>
  kt->trapframe->a1 = sp;
    800050b2:	0b8d3783          	ld	a5,184(s10) # fffffffffffff0b8 <end+0xffffffff7ffdbd68>
    800050b6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050ba:	de843783          	ld	a5,-536(s0)
    800050be:	0007c703          	lbu	a4,0(a5)
    800050c2:	cf11                	beqz	a4,800050de <exec+0x2a4>
    800050c4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050c6:	02f00693          	li	a3,47
    800050ca:	a039                	j	800050d8 <exec+0x29e>
      last = s+1;
    800050cc:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050d0:	0785                	addi	a5,a5,1
    800050d2:	fff7c703          	lbu	a4,-1(a5)
    800050d6:	c701                	beqz	a4,800050de <exec+0x2a4>
    if(*s == '/')
    800050d8:	fed71ce3          	bne	a4,a3,800050d0 <exec+0x296>
    800050dc:	bfc5                	j	800050cc <exec+0x292>
  safestrcpy(p->name, last, sizeof(p->name));
    800050de:	4641                	li	a2,16
    800050e0:	de843583          	ld	a1,-536(s0)
    800050e4:	190b8513          	addi	a0,s7,400
    800050e8:	ffffc097          	auipc	ra,0xffffc
    800050ec:	d34080e7          	jalr	-716(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800050f0:	100bb503          	ld	a0,256(s7)
  p->pagetable = pagetable;
    800050f4:	116bb023          	sd	s6,256(s7)
  p->sz = sz;
    800050f8:	0f8bbc23          	sd	s8,248(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    800050fc:	0b8d3783          	ld	a5,184(s10)
    80005100:	e6843703          	ld	a4,-408(s0)
    80005104:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    80005106:	0b8d3783          	ld	a5,184(s10)
    8000510a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000510e:	85ee                	mv	a1,s11
    80005110:	ffffd097          	auipc	ra,0xffffd
    80005114:	98e080e7          	jalr	-1650(ra) # 80001a9e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005118:	0004851b          	sext.w	a0,s1
    8000511c:	b3c9                	j	80004ede <exec+0xa4>
    8000511e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005122:	df843583          	ld	a1,-520(s0)
    80005126:	855a                	mv	a0,s6
    80005128:	ffffd097          	auipc	ra,0xffffd
    8000512c:	976080e7          	jalr	-1674(ra) # 80001a9e <proc_freepagetable>
  if(ip){
    80005130:	d80a9de3          	bnez	s5,80004eca <exec+0x90>
  return -1;
    80005134:	557d                	li	a0,-1
    80005136:	b365                	j	80004ede <exec+0xa4>
    80005138:	df243c23          	sd	s2,-520(s0)
    8000513c:	b7dd                	j	80005122 <exec+0x2e8>
    8000513e:	df243c23          	sd	s2,-520(s0)
    80005142:	b7c5                	j	80005122 <exec+0x2e8>
    80005144:	df243c23          	sd	s2,-520(s0)
    80005148:	bfe9                	j	80005122 <exec+0x2e8>
    8000514a:	df243c23          	sd	s2,-520(s0)
    8000514e:	bfd1                	j	80005122 <exec+0x2e8>
  sz = sz1;
    80005150:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005154:	4a81                	li	s5,0
    80005156:	b7f1                	j	80005122 <exec+0x2e8>
  sz = sz1;
    80005158:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000515c:	4a81                	li	s5,0
    8000515e:	b7d1                	j	80005122 <exec+0x2e8>
  sz = sz1;
    80005160:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005164:	4a81                	li	s5,0
    80005166:	bf75                	j	80005122 <exec+0x2e8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005168:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000516c:	e0843783          	ld	a5,-504(s0)
    80005170:	0017869b          	addiw	a3,a5,1
    80005174:	e0d43423          	sd	a3,-504(s0)
    80005178:	e0043783          	ld	a5,-512(s0)
    8000517c:	0387879b          	addiw	a5,a5,56
    80005180:	e8845703          	lhu	a4,-376(s0)
    80005184:	e0e6d9e3          	bge	a3,a4,80004f96 <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005188:	2781                	sext.w	a5,a5
    8000518a:	e0f43023          	sd	a5,-512(s0)
    8000518e:	03800713          	li	a4,56
    80005192:	86be                	mv	a3,a5
    80005194:	e1840613          	addi	a2,s0,-488
    80005198:	4581                	li	a1,0
    8000519a:	8556                	mv	a0,s5
    8000519c:	fffff097          	auipc	ra,0xfffff
    800051a0:	a4a080e7          	jalr	-1462(ra) # 80003be6 <readi>
    800051a4:	03800793          	li	a5,56
    800051a8:	f6f51be3          	bne	a0,a5,8000511e <exec+0x2e4>
    if(ph.type != ELF_PROG_LOAD)
    800051ac:	e1842783          	lw	a5,-488(s0)
    800051b0:	4705                	li	a4,1
    800051b2:	fae79de3          	bne	a5,a4,8000516c <exec+0x332>
    if(ph.memsz < ph.filesz)
    800051b6:	e4043483          	ld	s1,-448(s0)
    800051ba:	e3843783          	ld	a5,-456(s0)
    800051be:	f6f4ede3          	bltu	s1,a5,80005138 <exec+0x2fe>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051c2:	e2843783          	ld	a5,-472(s0)
    800051c6:	94be                	add	s1,s1,a5
    800051c8:	f6f4ebe3          	bltu	s1,a5,8000513e <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    800051cc:	de043703          	ld	a4,-544(s0)
    800051d0:	8ff9                	and	a5,a5,a4
    800051d2:	fbad                	bnez	a5,80005144 <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051d4:	e1c42503          	lw	a0,-484(s0)
    800051d8:	00000097          	auipc	ra,0x0
    800051dc:	c46080e7          	jalr	-954(ra) # 80004e1e <flags2perm>
    800051e0:	86aa                	mv	a3,a0
    800051e2:	8626                	mv	a2,s1
    800051e4:	85ca                	mv	a1,s2
    800051e6:	855a                	mv	a0,s6
    800051e8:	ffffc097          	auipc	ra,0xffffc
    800051ec:	228080e7          	jalr	552(ra) # 80001410 <uvmalloc>
    800051f0:	dea43c23          	sd	a0,-520(s0)
    800051f4:	d939                	beqz	a0,8000514a <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051f6:	e2843c03          	ld	s8,-472(s0)
    800051fa:	e2042c83          	lw	s9,-480(s0)
    800051fe:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005202:	f60b83e3          	beqz	s7,80005168 <exec+0x32e>
    80005206:	89de                	mv	s3,s7
    80005208:	4481                	li	s1,0
    8000520a:	b3ad                	j	80004f74 <exec+0x13a>

000000008000520c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000520c:	7179                	addi	sp,sp,-48
    8000520e:	f406                	sd	ra,40(sp)
    80005210:	f022                	sd	s0,32(sp)
    80005212:	ec26                	sd	s1,24(sp)
    80005214:	e84a                	sd	s2,16(sp)
    80005216:	1800                	addi	s0,sp,48
    80005218:	892e                	mv	s2,a1
    8000521a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000521c:	fdc40593          	addi	a1,s0,-36
    80005220:	ffffe097          	auipc	ra,0xffffe
    80005224:	b96080e7          	jalr	-1130(ra) # 80002db6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005228:	fdc42703          	lw	a4,-36(s0)
    8000522c:	47bd                	li	a5,15
    8000522e:	02e7eb63          	bltu	a5,a4,80005264 <argfd+0x58>
    80005232:	ffffc097          	auipc	ra,0xffffc
    80005236:	74e080e7          	jalr	1870(ra) # 80001980 <myproc>
    8000523a:	fdc42703          	lw	a4,-36(s0)
    8000523e:	02070793          	addi	a5,a4,32
    80005242:	078e                	slli	a5,a5,0x3
    80005244:	953e                	add	a0,a0,a5
    80005246:	651c                	ld	a5,8(a0)
    80005248:	c385                	beqz	a5,80005268 <argfd+0x5c>
    return -1;
  if(pfd)
    8000524a:	00090463          	beqz	s2,80005252 <argfd+0x46>
    *pfd = fd;
    8000524e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005252:	4501                	li	a0,0
  if(pf)
    80005254:	c091                	beqz	s1,80005258 <argfd+0x4c>
    *pf = f;
    80005256:	e09c                	sd	a5,0(s1)
}
    80005258:	70a2                	ld	ra,40(sp)
    8000525a:	7402                	ld	s0,32(sp)
    8000525c:	64e2                	ld	s1,24(sp)
    8000525e:	6942                	ld	s2,16(sp)
    80005260:	6145                	addi	sp,sp,48
    80005262:	8082                	ret
    return -1;
    80005264:	557d                	li	a0,-1
    80005266:	bfcd                	j	80005258 <argfd+0x4c>
    80005268:	557d                	li	a0,-1
    8000526a:	b7fd                	j	80005258 <argfd+0x4c>

000000008000526c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000526c:	1101                	addi	sp,sp,-32
    8000526e:	ec06                	sd	ra,24(sp)
    80005270:	e822                	sd	s0,16(sp)
    80005272:	e426                	sd	s1,8(sp)
    80005274:	1000                	addi	s0,sp,32
    80005276:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005278:	ffffc097          	auipc	ra,0xffffc
    8000527c:	708080e7          	jalr	1800(ra) # 80001980 <myproc>
    80005280:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005282:	10850793          	addi	a5,a0,264
    80005286:	4501                	li	a0,0
    80005288:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000528a:	6398                	ld	a4,0(a5)
    8000528c:	cb19                	beqz	a4,800052a2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000528e:	2505                	addiw	a0,a0,1
    80005290:	07a1                	addi	a5,a5,8
    80005292:	fed51ce3          	bne	a0,a3,8000528a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005296:	557d                	li	a0,-1
}
    80005298:	60e2                	ld	ra,24(sp)
    8000529a:	6442                	ld	s0,16(sp)
    8000529c:	64a2                	ld	s1,8(sp)
    8000529e:	6105                	addi	sp,sp,32
    800052a0:	8082                	ret
      p->ofile[fd] = f;
    800052a2:	02050793          	addi	a5,a0,32
    800052a6:	078e                	slli	a5,a5,0x3
    800052a8:	963e                	add	a2,a2,a5
    800052aa:	e604                	sd	s1,8(a2)
      return fd;
    800052ac:	b7f5                	j	80005298 <fdalloc+0x2c>

00000000800052ae <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052ae:	715d                	addi	sp,sp,-80
    800052b0:	e486                	sd	ra,72(sp)
    800052b2:	e0a2                	sd	s0,64(sp)
    800052b4:	fc26                	sd	s1,56(sp)
    800052b6:	f84a                	sd	s2,48(sp)
    800052b8:	f44e                	sd	s3,40(sp)
    800052ba:	f052                	sd	s4,32(sp)
    800052bc:	ec56                	sd	s5,24(sp)
    800052be:	e85a                	sd	s6,16(sp)
    800052c0:	0880                	addi	s0,sp,80
    800052c2:	8b2e                	mv	s6,a1
    800052c4:	89b2                	mv	s3,a2
    800052c6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052c8:	fb040593          	addi	a1,s0,-80
    800052cc:	fffff097          	auipc	ra,0xfffff
    800052d0:	e2a080e7          	jalr	-470(ra) # 800040f6 <nameiparent>
    800052d4:	84aa                	mv	s1,a0
    800052d6:	14050f63          	beqz	a0,80005434 <create+0x186>
    return 0;

  ilock(dp);
    800052da:	ffffe097          	auipc	ra,0xffffe
    800052de:	658080e7          	jalr	1624(ra) # 80003932 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052e2:	4601                	li	a2,0
    800052e4:	fb040593          	addi	a1,s0,-80
    800052e8:	8526                	mv	a0,s1
    800052ea:	fffff097          	auipc	ra,0xfffff
    800052ee:	b2c080e7          	jalr	-1236(ra) # 80003e16 <dirlookup>
    800052f2:	8aaa                	mv	s5,a0
    800052f4:	c931                	beqz	a0,80005348 <create+0x9a>
    iunlockput(dp);
    800052f6:	8526                	mv	a0,s1
    800052f8:	fffff097          	auipc	ra,0xfffff
    800052fc:	89c080e7          	jalr	-1892(ra) # 80003b94 <iunlockput>
    ilock(ip);
    80005300:	8556                	mv	a0,s5
    80005302:	ffffe097          	auipc	ra,0xffffe
    80005306:	630080e7          	jalr	1584(ra) # 80003932 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000530a:	000b059b          	sext.w	a1,s6
    8000530e:	4789                	li	a5,2
    80005310:	02f59563          	bne	a1,a5,8000533a <create+0x8c>
    80005314:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbcf4>
    80005318:	37f9                	addiw	a5,a5,-2
    8000531a:	17c2                	slli	a5,a5,0x30
    8000531c:	93c1                	srli	a5,a5,0x30
    8000531e:	4705                	li	a4,1
    80005320:	00f76d63          	bltu	a4,a5,8000533a <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005324:	8556                	mv	a0,s5
    80005326:	60a6                	ld	ra,72(sp)
    80005328:	6406                	ld	s0,64(sp)
    8000532a:	74e2                	ld	s1,56(sp)
    8000532c:	7942                	ld	s2,48(sp)
    8000532e:	79a2                	ld	s3,40(sp)
    80005330:	7a02                	ld	s4,32(sp)
    80005332:	6ae2                	ld	s5,24(sp)
    80005334:	6b42                	ld	s6,16(sp)
    80005336:	6161                	addi	sp,sp,80
    80005338:	8082                	ret
    iunlockput(ip);
    8000533a:	8556                	mv	a0,s5
    8000533c:	fffff097          	auipc	ra,0xfffff
    80005340:	858080e7          	jalr	-1960(ra) # 80003b94 <iunlockput>
    return 0;
    80005344:	4a81                	li	s5,0
    80005346:	bff9                	j	80005324 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005348:	85da                	mv	a1,s6
    8000534a:	4088                	lw	a0,0(s1)
    8000534c:	ffffe097          	auipc	ra,0xffffe
    80005350:	44a080e7          	jalr	1098(ra) # 80003796 <ialloc>
    80005354:	8a2a                	mv	s4,a0
    80005356:	c539                	beqz	a0,800053a4 <create+0xf6>
  ilock(ip);
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	5da080e7          	jalr	1498(ra) # 80003932 <ilock>
  ip->major = major;
    80005360:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005364:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005368:	4905                	li	s2,1
    8000536a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000536e:	8552                	mv	a0,s4
    80005370:	ffffe097          	auipc	ra,0xffffe
    80005374:	4f8080e7          	jalr	1272(ra) # 80003868 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005378:	000b059b          	sext.w	a1,s6
    8000537c:	03258b63          	beq	a1,s2,800053b2 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005380:	004a2603          	lw	a2,4(s4)
    80005384:	fb040593          	addi	a1,s0,-80
    80005388:	8526                	mv	a0,s1
    8000538a:	fffff097          	auipc	ra,0xfffff
    8000538e:	c9c080e7          	jalr	-868(ra) # 80004026 <dirlink>
    80005392:	06054f63          	bltz	a0,80005410 <create+0x162>
  iunlockput(dp);
    80005396:	8526                	mv	a0,s1
    80005398:	ffffe097          	auipc	ra,0xffffe
    8000539c:	7fc080e7          	jalr	2044(ra) # 80003b94 <iunlockput>
  return ip;
    800053a0:	8ad2                	mv	s5,s4
    800053a2:	b749                	j	80005324 <create+0x76>
    iunlockput(dp);
    800053a4:	8526                	mv	a0,s1
    800053a6:	ffffe097          	auipc	ra,0xffffe
    800053aa:	7ee080e7          	jalr	2030(ra) # 80003b94 <iunlockput>
    return 0;
    800053ae:	8ad2                	mv	s5,s4
    800053b0:	bf95                	j	80005324 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053b2:	004a2603          	lw	a2,4(s4)
    800053b6:	00003597          	auipc	a1,0x3
    800053ba:	32a58593          	addi	a1,a1,810 # 800086e0 <syscalls+0x2a0>
    800053be:	8552                	mv	a0,s4
    800053c0:	fffff097          	auipc	ra,0xfffff
    800053c4:	c66080e7          	jalr	-922(ra) # 80004026 <dirlink>
    800053c8:	04054463          	bltz	a0,80005410 <create+0x162>
    800053cc:	40d0                	lw	a2,4(s1)
    800053ce:	00003597          	auipc	a1,0x3
    800053d2:	31a58593          	addi	a1,a1,794 # 800086e8 <syscalls+0x2a8>
    800053d6:	8552                	mv	a0,s4
    800053d8:	fffff097          	auipc	ra,0xfffff
    800053dc:	c4e080e7          	jalr	-946(ra) # 80004026 <dirlink>
    800053e0:	02054863          	bltz	a0,80005410 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800053e4:	004a2603          	lw	a2,4(s4)
    800053e8:	fb040593          	addi	a1,s0,-80
    800053ec:	8526                	mv	a0,s1
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	c38080e7          	jalr	-968(ra) # 80004026 <dirlink>
    800053f6:	00054d63          	bltz	a0,80005410 <create+0x162>
    dp->nlink++;  // for ".."
    800053fa:	04a4d783          	lhu	a5,74(s1)
    800053fe:	2785                	addiw	a5,a5,1
    80005400:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005404:	8526                	mv	a0,s1
    80005406:	ffffe097          	auipc	ra,0xffffe
    8000540a:	462080e7          	jalr	1122(ra) # 80003868 <iupdate>
    8000540e:	b761                	j	80005396 <create+0xe8>
  ip->nlink = 0;
    80005410:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005414:	8552                	mv	a0,s4
    80005416:	ffffe097          	auipc	ra,0xffffe
    8000541a:	452080e7          	jalr	1106(ra) # 80003868 <iupdate>
  iunlockput(ip);
    8000541e:	8552                	mv	a0,s4
    80005420:	ffffe097          	auipc	ra,0xffffe
    80005424:	774080e7          	jalr	1908(ra) # 80003b94 <iunlockput>
  iunlockput(dp);
    80005428:	8526                	mv	a0,s1
    8000542a:	ffffe097          	auipc	ra,0xffffe
    8000542e:	76a080e7          	jalr	1898(ra) # 80003b94 <iunlockput>
  return 0;
    80005432:	bdcd                	j	80005324 <create+0x76>
    return 0;
    80005434:	8aaa                	mv	s5,a0
    80005436:	b5fd                	j	80005324 <create+0x76>

0000000080005438 <sys_dup>:
{
    80005438:	7179                	addi	sp,sp,-48
    8000543a:	f406                	sd	ra,40(sp)
    8000543c:	f022                	sd	s0,32(sp)
    8000543e:	ec26                	sd	s1,24(sp)
    80005440:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005442:	fd840613          	addi	a2,s0,-40
    80005446:	4581                	li	a1,0
    80005448:	4501                	li	a0,0
    8000544a:	00000097          	auipc	ra,0x0
    8000544e:	dc2080e7          	jalr	-574(ra) # 8000520c <argfd>
    return -1;
    80005452:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005454:	02054363          	bltz	a0,8000547a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005458:	fd843503          	ld	a0,-40(s0)
    8000545c:	00000097          	auipc	ra,0x0
    80005460:	e10080e7          	jalr	-496(ra) # 8000526c <fdalloc>
    80005464:	84aa                	mv	s1,a0
    return -1;
    80005466:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005468:	00054963          	bltz	a0,8000547a <sys_dup+0x42>
  filedup(f);
    8000546c:	fd843503          	ld	a0,-40(s0)
    80005470:	fffff097          	auipc	ra,0xfffff
    80005474:	2fe080e7          	jalr	766(ra) # 8000476e <filedup>
  return fd;
    80005478:	87a6                	mv	a5,s1
}
    8000547a:	853e                	mv	a0,a5
    8000547c:	70a2                	ld	ra,40(sp)
    8000547e:	7402                	ld	s0,32(sp)
    80005480:	64e2                	ld	s1,24(sp)
    80005482:	6145                	addi	sp,sp,48
    80005484:	8082                	ret

0000000080005486 <sys_read>:
{
    80005486:	7179                	addi	sp,sp,-48
    80005488:	f406                	sd	ra,40(sp)
    8000548a:	f022                	sd	s0,32(sp)
    8000548c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000548e:	fd840593          	addi	a1,s0,-40
    80005492:	4505                	li	a0,1
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	942080e7          	jalr	-1726(ra) # 80002dd6 <argaddr>
  argint(2, &n);
    8000549c:	fe440593          	addi	a1,s0,-28
    800054a0:	4509                	li	a0,2
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	914080e7          	jalr	-1772(ra) # 80002db6 <argint>
  if(argfd(0, 0, &f) < 0)
    800054aa:	fe840613          	addi	a2,s0,-24
    800054ae:	4581                	li	a1,0
    800054b0:	4501                	li	a0,0
    800054b2:	00000097          	auipc	ra,0x0
    800054b6:	d5a080e7          	jalr	-678(ra) # 8000520c <argfd>
    800054ba:	87aa                	mv	a5,a0
    return -1;
    800054bc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054be:	0007cc63          	bltz	a5,800054d6 <sys_read+0x50>
  return fileread(f, p, n);
    800054c2:	fe442603          	lw	a2,-28(s0)
    800054c6:	fd843583          	ld	a1,-40(s0)
    800054ca:	fe843503          	ld	a0,-24(s0)
    800054ce:	fffff097          	auipc	ra,0xfffff
    800054d2:	42c080e7          	jalr	1068(ra) # 800048fa <fileread>
}
    800054d6:	70a2                	ld	ra,40(sp)
    800054d8:	7402                	ld	s0,32(sp)
    800054da:	6145                	addi	sp,sp,48
    800054dc:	8082                	ret

00000000800054de <sys_write>:
{
    800054de:	7179                	addi	sp,sp,-48
    800054e0:	f406                	sd	ra,40(sp)
    800054e2:	f022                	sd	s0,32(sp)
    800054e4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054e6:	fd840593          	addi	a1,s0,-40
    800054ea:	4505                	li	a0,1
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	8ea080e7          	jalr	-1814(ra) # 80002dd6 <argaddr>
  argint(2, &n);
    800054f4:	fe440593          	addi	a1,s0,-28
    800054f8:	4509                	li	a0,2
    800054fa:	ffffe097          	auipc	ra,0xffffe
    800054fe:	8bc080e7          	jalr	-1860(ra) # 80002db6 <argint>
  if(argfd(0, 0, &f) < 0)
    80005502:	fe840613          	addi	a2,s0,-24
    80005506:	4581                	li	a1,0
    80005508:	4501                	li	a0,0
    8000550a:	00000097          	auipc	ra,0x0
    8000550e:	d02080e7          	jalr	-766(ra) # 8000520c <argfd>
    80005512:	87aa                	mv	a5,a0
    return -1;
    80005514:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005516:	0007cc63          	bltz	a5,8000552e <sys_write+0x50>
  return filewrite(f, p, n);
    8000551a:	fe442603          	lw	a2,-28(s0)
    8000551e:	fd843583          	ld	a1,-40(s0)
    80005522:	fe843503          	ld	a0,-24(s0)
    80005526:	fffff097          	auipc	ra,0xfffff
    8000552a:	496080e7          	jalr	1174(ra) # 800049bc <filewrite>
}
    8000552e:	70a2                	ld	ra,40(sp)
    80005530:	7402                	ld	s0,32(sp)
    80005532:	6145                	addi	sp,sp,48
    80005534:	8082                	ret

0000000080005536 <sys_close>:
{
    80005536:	1101                	addi	sp,sp,-32
    80005538:	ec06                	sd	ra,24(sp)
    8000553a:	e822                	sd	s0,16(sp)
    8000553c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000553e:	fe040613          	addi	a2,s0,-32
    80005542:	fec40593          	addi	a1,s0,-20
    80005546:	4501                	li	a0,0
    80005548:	00000097          	auipc	ra,0x0
    8000554c:	cc4080e7          	jalr	-828(ra) # 8000520c <argfd>
    return -1;
    80005550:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005552:	02054563          	bltz	a0,8000557c <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005556:	ffffc097          	auipc	ra,0xffffc
    8000555a:	42a080e7          	jalr	1066(ra) # 80001980 <myproc>
    8000555e:	fec42783          	lw	a5,-20(s0)
    80005562:	02078793          	addi	a5,a5,32
    80005566:	078e                	slli	a5,a5,0x3
    80005568:	97aa                	add	a5,a5,a0
    8000556a:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000556e:	fe043503          	ld	a0,-32(s0)
    80005572:	fffff097          	auipc	ra,0xfffff
    80005576:	24e080e7          	jalr	590(ra) # 800047c0 <fileclose>
  return 0;
    8000557a:	4781                	li	a5,0
}
    8000557c:	853e                	mv	a0,a5
    8000557e:	60e2                	ld	ra,24(sp)
    80005580:	6442                	ld	s0,16(sp)
    80005582:	6105                	addi	sp,sp,32
    80005584:	8082                	ret

0000000080005586 <sys_fstat>:
{
    80005586:	1101                	addi	sp,sp,-32
    80005588:	ec06                	sd	ra,24(sp)
    8000558a:	e822                	sd	s0,16(sp)
    8000558c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000558e:	fe040593          	addi	a1,s0,-32
    80005592:	4505                	li	a0,1
    80005594:	ffffe097          	auipc	ra,0xffffe
    80005598:	842080e7          	jalr	-1982(ra) # 80002dd6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000559c:	fe840613          	addi	a2,s0,-24
    800055a0:	4581                	li	a1,0
    800055a2:	4501                	li	a0,0
    800055a4:	00000097          	auipc	ra,0x0
    800055a8:	c68080e7          	jalr	-920(ra) # 8000520c <argfd>
    800055ac:	87aa                	mv	a5,a0
    return -1;
    800055ae:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055b0:	0007ca63          	bltz	a5,800055c4 <sys_fstat+0x3e>
  return filestat(f, st);
    800055b4:	fe043583          	ld	a1,-32(s0)
    800055b8:	fe843503          	ld	a0,-24(s0)
    800055bc:	fffff097          	auipc	ra,0xfffff
    800055c0:	2cc080e7          	jalr	716(ra) # 80004888 <filestat>
}
    800055c4:	60e2                	ld	ra,24(sp)
    800055c6:	6442                	ld	s0,16(sp)
    800055c8:	6105                	addi	sp,sp,32
    800055ca:	8082                	ret

00000000800055cc <sys_link>:
{
    800055cc:	7169                	addi	sp,sp,-304
    800055ce:	f606                	sd	ra,296(sp)
    800055d0:	f222                	sd	s0,288(sp)
    800055d2:	ee26                	sd	s1,280(sp)
    800055d4:	ea4a                	sd	s2,272(sp)
    800055d6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055d8:	08000613          	li	a2,128
    800055dc:	ed040593          	addi	a1,s0,-304
    800055e0:	4501                	li	a0,0
    800055e2:	ffffe097          	auipc	ra,0xffffe
    800055e6:	814080e7          	jalr	-2028(ra) # 80002df6 <argstr>
    return -1;
    800055ea:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ec:	10054e63          	bltz	a0,80005708 <sys_link+0x13c>
    800055f0:	08000613          	li	a2,128
    800055f4:	f5040593          	addi	a1,s0,-176
    800055f8:	4505                	li	a0,1
    800055fa:	ffffd097          	auipc	ra,0xffffd
    800055fe:	7fc080e7          	jalr	2044(ra) # 80002df6 <argstr>
    return -1;
    80005602:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005604:	10054263          	bltz	a0,80005708 <sys_link+0x13c>
  begin_op();
    80005608:	fffff097          	auipc	ra,0xfffff
    8000560c:	cec080e7          	jalr	-788(ra) # 800042f4 <begin_op>
  if((ip = namei(old)) == 0){
    80005610:	ed040513          	addi	a0,s0,-304
    80005614:	fffff097          	auipc	ra,0xfffff
    80005618:	ac4080e7          	jalr	-1340(ra) # 800040d8 <namei>
    8000561c:	84aa                	mv	s1,a0
    8000561e:	c551                	beqz	a0,800056aa <sys_link+0xde>
  ilock(ip);
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	312080e7          	jalr	786(ra) # 80003932 <ilock>
  if(ip->type == T_DIR){
    80005628:	04449703          	lh	a4,68(s1)
    8000562c:	4785                	li	a5,1
    8000562e:	08f70463          	beq	a4,a5,800056b6 <sys_link+0xea>
  ip->nlink++;
    80005632:	04a4d783          	lhu	a5,74(s1)
    80005636:	2785                	addiw	a5,a5,1
    80005638:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000563c:	8526                	mv	a0,s1
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	22a080e7          	jalr	554(ra) # 80003868 <iupdate>
  iunlock(ip);
    80005646:	8526                	mv	a0,s1
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	3ac080e7          	jalr	940(ra) # 800039f4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005650:	fd040593          	addi	a1,s0,-48
    80005654:	f5040513          	addi	a0,s0,-176
    80005658:	fffff097          	auipc	ra,0xfffff
    8000565c:	a9e080e7          	jalr	-1378(ra) # 800040f6 <nameiparent>
    80005660:	892a                	mv	s2,a0
    80005662:	c935                	beqz	a0,800056d6 <sys_link+0x10a>
  ilock(dp);
    80005664:	ffffe097          	auipc	ra,0xffffe
    80005668:	2ce080e7          	jalr	718(ra) # 80003932 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000566c:	00092703          	lw	a4,0(s2)
    80005670:	409c                	lw	a5,0(s1)
    80005672:	04f71d63          	bne	a4,a5,800056cc <sys_link+0x100>
    80005676:	40d0                	lw	a2,4(s1)
    80005678:	fd040593          	addi	a1,s0,-48
    8000567c:	854a                	mv	a0,s2
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	9a8080e7          	jalr	-1624(ra) # 80004026 <dirlink>
    80005686:	04054363          	bltz	a0,800056cc <sys_link+0x100>
  iunlockput(dp);
    8000568a:	854a                	mv	a0,s2
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	508080e7          	jalr	1288(ra) # 80003b94 <iunlockput>
  iput(ip);
    80005694:	8526                	mv	a0,s1
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	456080e7          	jalr	1110(ra) # 80003aec <iput>
  end_op();
    8000569e:	fffff097          	auipc	ra,0xfffff
    800056a2:	cd6080e7          	jalr	-810(ra) # 80004374 <end_op>
  return 0;
    800056a6:	4781                	li	a5,0
    800056a8:	a085                	j	80005708 <sys_link+0x13c>
    end_op();
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	cca080e7          	jalr	-822(ra) # 80004374 <end_op>
    return -1;
    800056b2:	57fd                	li	a5,-1
    800056b4:	a891                	j	80005708 <sys_link+0x13c>
    iunlockput(ip);
    800056b6:	8526                	mv	a0,s1
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	4dc080e7          	jalr	1244(ra) # 80003b94 <iunlockput>
    end_op();
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	cb4080e7          	jalr	-844(ra) # 80004374 <end_op>
    return -1;
    800056c8:	57fd                	li	a5,-1
    800056ca:	a83d                	j	80005708 <sys_link+0x13c>
    iunlockput(dp);
    800056cc:	854a                	mv	a0,s2
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	4c6080e7          	jalr	1222(ra) # 80003b94 <iunlockput>
  ilock(ip);
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	25a080e7          	jalr	602(ra) # 80003932 <ilock>
  ip->nlink--;
    800056e0:	04a4d783          	lhu	a5,74(s1)
    800056e4:	37fd                	addiw	a5,a5,-1
    800056e6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056ea:	8526                	mv	a0,s1
    800056ec:	ffffe097          	auipc	ra,0xffffe
    800056f0:	17c080e7          	jalr	380(ra) # 80003868 <iupdate>
  iunlockput(ip);
    800056f4:	8526                	mv	a0,s1
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	49e080e7          	jalr	1182(ra) # 80003b94 <iunlockput>
  end_op();
    800056fe:	fffff097          	auipc	ra,0xfffff
    80005702:	c76080e7          	jalr	-906(ra) # 80004374 <end_op>
  return -1;
    80005706:	57fd                	li	a5,-1
}
    80005708:	853e                	mv	a0,a5
    8000570a:	70b2                	ld	ra,296(sp)
    8000570c:	7412                	ld	s0,288(sp)
    8000570e:	64f2                	ld	s1,280(sp)
    80005710:	6952                	ld	s2,272(sp)
    80005712:	6155                	addi	sp,sp,304
    80005714:	8082                	ret

0000000080005716 <sys_unlink>:
{
    80005716:	7151                	addi	sp,sp,-240
    80005718:	f586                	sd	ra,232(sp)
    8000571a:	f1a2                	sd	s0,224(sp)
    8000571c:	eda6                	sd	s1,216(sp)
    8000571e:	e9ca                	sd	s2,208(sp)
    80005720:	e5ce                	sd	s3,200(sp)
    80005722:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005724:	08000613          	li	a2,128
    80005728:	f3040593          	addi	a1,s0,-208
    8000572c:	4501                	li	a0,0
    8000572e:	ffffd097          	auipc	ra,0xffffd
    80005732:	6c8080e7          	jalr	1736(ra) # 80002df6 <argstr>
    80005736:	18054163          	bltz	a0,800058b8 <sys_unlink+0x1a2>
  begin_op();
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	bba080e7          	jalr	-1094(ra) # 800042f4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005742:	fb040593          	addi	a1,s0,-80
    80005746:	f3040513          	addi	a0,s0,-208
    8000574a:	fffff097          	auipc	ra,0xfffff
    8000574e:	9ac080e7          	jalr	-1620(ra) # 800040f6 <nameiparent>
    80005752:	84aa                	mv	s1,a0
    80005754:	c979                	beqz	a0,8000582a <sys_unlink+0x114>
  ilock(dp);
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	1dc080e7          	jalr	476(ra) # 80003932 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000575e:	00003597          	auipc	a1,0x3
    80005762:	f8258593          	addi	a1,a1,-126 # 800086e0 <syscalls+0x2a0>
    80005766:	fb040513          	addi	a0,s0,-80
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	692080e7          	jalr	1682(ra) # 80003dfc <namecmp>
    80005772:	14050a63          	beqz	a0,800058c6 <sys_unlink+0x1b0>
    80005776:	00003597          	auipc	a1,0x3
    8000577a:	f7258593          	addi	a1,a1,-142 # 800086e8 <syscalls+0x2a8>
    8000577e:	fb040513          	addi	a0,s0,-80
    80005782:	ffffe097          	auipc	ra,0xffffe
    80005786:	67a080e7          	jalr	1658(ra) # 80003dfc <namecmp>
    8000578a:	12050e63          	beqz	a0,800058c6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000578e:	f2c40613          	addi	a2,s0,-212
    80005792:	fb040593          	addi	a1,s0,-80
    80005796:	8526                	mv	a0,s1
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	67e080e7          	jalr	1662(ra) # 80003e16 <dirlookup>
    800057a0:	892a                	mv	s2,a0
    800057a2:	12050263          	beqz	a0,800058c6 <sys_unlink+0x1b0>
  ilock(ip);
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	18c080e7          	jalr	396(ra) # 80003932 <ilock>
  if(ip->nlink < 1)
    800057ae:	04a91783          	lh	a5,74(s2)
    800057b2:	08f05263          	blez	a5,80005836 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057b6:	04491703          	lh	a4,68(s2)
    800057ba:	4785                	li	a5,1
    800057bc:	08f70563          	beq	a4,a5,80005846 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057c0:	4641                	li	a2,16
    800057c2:	4581                	li	a1,0
    800057c4:	fc040513          	addi	a0,s0,-64
    800057c8:	ffffb097          	auipc	ra,0xffffb
    800057cc:	50a080e7          	jalr	1290(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057d0:	4741                	li	a4,16
    800057d2:	f2c42683          	lw	a3,-212(s0)
    800057d6:	fc040613          	addi	a2,s0,-64
    800057da:	4581                	li	a1,0
    800057dc:	8526                	mv	a0,s1
    800057de:	ffffe097          	auipc	ra,0xffffe
    800057e2:	500080e7          	jalr	1280(ra) # 80003cde <writei>
    800057e6:	47c1                	li	a5,16
    800057e8:	0af51563          	bne	a0,a5,80005892 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057ec:	04491703          	lh	a4,68(s2)
    800057f0:	4785                	li	a5,1
    800057f2:	0af70863          	beq	a4,a5,800058a2 <sys_unlink+0x18c>
  iunlockput(dp);
    800057f6:	8526                	mv	a0,s1
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	39c080e7          	jalr	924(ra) # 80003b94 <iunlockput>
  ip->nlink--;
    80005800:	04a95783          	lhu	a5,74(s2)
    80005804:	37fd                	addiw	a5,a5,-1
    80005806:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000580a:	854a                	mv	a0,s2
    8000580c:	ffffe097          	auipc	ra,0xffffe
    80005810:	05c080e7          	jalr	92(ra) # 80003868 <iupdate>
  iunlockput(ip);
    80005814:	854a                	mv	a0,s2
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	37e080e7          	jalr	894(ra) # 80003b94 <iunlockput>
  end_op();
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	b56080e7          	jalr	-1194(ra) # 80004374 <end_op>
  return 0;
    80005826:	4501                	li	a0,0
    80005828:	a84d                	j	800058da <sys_unlink+0x1c4>
    end_op();
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	b4a080e7          	jalr	-1206(ra) # 80004374 <end_op>
    return -1;
    80005832:	557d                	li	a0,-1
    80005834:	a05d                	j	800058da <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005836:	00003517          	auipc	a0,0x3
    8000583a:	eba50513          	addi	a0,a0,-326 # 800086f0 <syscalls+0x2b0>
    8000583e:	ffffb097          	auipc	ra,0xffffb
    80005842:	d00080e7          	jalr	-768(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005846:	04c92703          	lw	a4,76(s2)
    8000584a:	02000793          	li	a5,32
    8000584e:	f6e7f9e3          	bgeu	a5,a4,800057c0 <sys_unlink+0xaa>
    80005852:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005856:	4741                	li	a4,16
    80005858:	86ce                	mv	a3,s3
    8000585a:	f1840613          	addi	a2,s0,-232
    8000585e:	4581                	li	a1,0
    80005860:	854a                	mv	a0,s2
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	384080e7          	jalr	900(ra) # 80003be6 <readi>
    8000586a:	47c1                	li	a5,16
    8000586c:	00f51b63          	bne	a0,a5,80005882 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005870:	f1845783          	lhu	a5,-232(s0)
    80005874:	e7a1                	bnez	a5,800058bc <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005876:	29c1                	addiw	s3,s3,16
    80005878:	04c92783          	lw	a5,76(s2)
    8000587c:	fcf9ede3          	bltu	s3,a5,80005856 <sys_unlink+0x140>
    80005880:	b781                	j	800057c0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005882:	00003517          	auipc	a0,0x3
    80005886:	e8650513          	addi	a0,a0,-378 # 80008708 <syscalls+0x2c8>
    8000588a:	ffffb097          	auipc	ra,0xffffb
    8000588e:	cb4080e7          	jalr	-844(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005892:	00003517          	auipc	a0,0x3
    80005896:	e8e50513          	addi	a0,a0,-370 # 80008720 <syscalls+0x2e0>
    8000589a:	ffffb097          	auipc	ra,0xffffb
    8000589e:	ca4080e7          	jalr	-860(ra) # 8000053e <panic>
    dp->nlink--;
    800058a2:	04a4d783          	lhu	a5,74(s1)
    800058a6:	37fd                	addiw	a5,a5,-1
    800058a8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058ac:	8526                	mv	a0,s1
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	fba080e7          	jalr	-70(ra) # 80003868 <iupdate>
    800058b6:	b781                	j	800057f6 <sys_unlink+0xe0>
    return -1;
    800058b8:	557d                	li	a0,-1
    800058ba:	a005                	j	800058da <sys_unlink+0x1c4>
    iunlockput(ip);
    800058bc:	854a                	mv	a0,s2
    800058be:	ffffe097          	auipc	ra,0xffffe
    800058c2:	2d6080e7          	jalr	726(ra) # 80003b94 <iunlockput>
  iunlockput(dp);
    800058c6:	8526                	mv	a0,s1
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	2cc080e7          	jalr	716(ra) # 80003b94 <iunlockput>
  end_op();
    800058d0:	fffff097          	auipc	ra,0xfffff
    800058d4:	aa4080e7          	jalr	-1372(ra) # 80004374 <end_op>
  return -1;
    800058d8:	557d                	li	a0,-1
}
    800058da:	70ae                	ld	ra,232(sp)
    800058dc:	740e                	ld	s0,224(sp)
    800058de:	64ee                	ld	s1,216(sp)
    800058e0:	694e                	ld	s2,208(sp)
    800058e2:	69ae                	ld	s3,200(sp)
    800058e4:	616d                	addi	sp,sp,240
    800058e6:	8082                	ret

00000000800058e8 <sys_open>:

uint64
sys_open(void)
{
    800058e8:	7131                	addi	sp,sp,-192
    800058ea:	fd06                	sd	ra,184(sp)
    800058ec:	f922                	sd	s0,176(sp)
    800058ee:	f526                	sd	s1,168(sp)
    800058f0:	f14a                	sd	s2,160(sp)
    800058f2:	ed4e                	sd	s3,152(sp)
    800058f4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800058f6:	f4c40593          	addi	a1,s0,-180
    800058fa:	4505                	li	a0,1
    800058fc:	ffffd097          	auipc	ra,0xffffd
    80005900:	4ba080e7          	jalr	1210(ra) # 80002db6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005904:	08000613          	li	a2,128
    80005908:	f5040593          	addi	a1,s0,-176
    8000590c:	4501                	li	a0,0
    8000590e:	ffffd097          	auipc	ra,0xffffd
    80005912:	4e8080e7          	jalr	1256(ra) # 80002df6 <argstr>
    80005916:	87aa                	mv	a5,a0
    return -1;
    80005918:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000591a:	0a07c963          	bltz	a5,800059cc <sys_open+0xe4>

  begin_op();
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	9d6080e7          	jalr	-1578(ra) # 800042f4 <begin_op>

  if(omode & O_CREATE){
    80005926:	f4c42783          	lw	a5,-180(s0)
    8000592a:	2007f793          	andi	a5,a5,512
    8000592e:	cfc5                	beqz	a5,800059e6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005930:	4681                	li	a3,0
    80005932:	4601                	li	a2,0
    80005934:	4589                	li	a1,2
    80005936:	f5040513          	addi	a0,s0,-176
    8000593a:	00000097          	auipc	ra,0x0
    8000593e:	974080e7          	jalr	-1676(ra) # 800052ae <create>
    80005942:	84aa                	mv	s1,a0
    if(ip == 0){
    80005944:	c959                	beqz	a0,800059da <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005946:	04449703          	lh	a4,68(s1)
    8000594a:	478d                	li	a5,3
    8000594c:	00f71763          	bne	a4,a5,8000595a <sys_open+0x72>
    80005950:	0464d703          	lhu	a4,70(s1)
    80005954:	47a5                	li	a5,9
    80005956:	0ce7ed63          	bltu	a5,a4,80005a30 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	daa080e7          	jalr	-598(ra) # 80004704 <filealloc>
    80005962:	89aa                	mv	s3,a0
    80005964:	10050363          	beqz	a0,80005a6a <sys_open+0x182>
    80005968:	00000097          	auipc	ra,0x0
    8000596c:	904080e7          	jalr	-1788(ra) # 8000526c <fdalloc>
    80005970:	892a                	mv	s2,a0
    80005972:	0e054763          	bltz	a0,80005a60 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005976:	04449703          	lh	a4,68(s1)
    8000597a:	478d                	li	a5,3
    8000597c:	0cf70563          	beq	a4,a5,80005a46 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005980:	4789                	li	a5,2
    80005982:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005986:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000598a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000598e:	f4c42783          	lw	a5,-180(s0)
    80005992:	0017c713          	xori	a4,a5,1
    80005996:	8b05                	andi	a4,a4,1
    80005998:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000599c:	0037f713          	andi	a4,a5,3
    800059a0:	00e03733          	snez	a4,a4
    800059a4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059a8:	4007f793          	andi	a5,a5,1024
    800059ac:	c791                	beqz	a5,800059b8 <sys_open+0xd0>
    800059ae:	04449703          	lh	a4,68(s1)
    800059b2:	4789                	li	a5,2
    800059b4:	0af70063          	beq	a4,a5,80005a54 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800059b8:	8526                	mv	a0,s1
    800059ba:	ffffe097          	auipc	ra,0xffffe
    800059be:	03a080e7          	jalr	58(ra) # 800039f4 <iunlock>
  end_op();
    800059c2:	fffff097          	auipc	ra,0xfffff
    800059c6:	9b2080e7          	jalr	-1614(ra) # 80004374 <end_op>

  return fd;
    800059ca:	854a                	mv	a0,s2
}
    800059cc:	70ea                	ld	ra,184(sp)
    800059ce:	744a                	ld	s0,176(sp)
    800059d0:	74aa                	ld	s1,168(sp)
    800059d2:	790a                	ld	s2,160(sp)
    800059d4:	69ea                	ld	s3,152(sp)
    800059d6:	6129                	addi	sp,sp,192
    800059d8:	8082                	ret
      end_op();
    800059da:	fffff097          	auipc	ra,0xfffff
    800059de:	99a080e7          	jalr	-1638(ra) # 80004374 <end_op>
      return -1;
    800059e2:	557d                	li	a0,-1
    800059e4:	b7e5                	j	800059cc <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059e6:	f5040513          	addi	a0,s0,-176
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	6ee080e7          	jalr	1774(ra) # 800040d8 <namei>
    800059f2:	84aa                	mv	s1,a0
    800059f4:	c905                	beqz	a0,80005a24 <sys_open+0x13c>
    ilock(ip);
    800059f6:	ffffe097          	auipc	ra,0xffffe
    800059fa:	f3c080e7          	jalr	-196(ra) # 80003932 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059fe:	04449703          	lh	a4,68(s1)
    80005a02:	4785                	li	a5,1
    80005a04:	f4f711e3          	bne	a4,a5,80005946 <sys_open+0x5e>
    80005a08:	f4c42783          	lw	a5,-180(s0)
    80005a0c:	d7b9                	beqz	a5,8000595a <sys_open+0x72>
      iunlockput(ip);
    80005a0e:	8526                	mv	a0,s1
    80005a10:	ffffe097          	auipc	ra,0xffffe
    80005a14:	184080e7          	jalr	388(ra) # 80003b94 <iunlockput>
      end_op();
    80005a18:	fffff097          	auipc	ra,0xfffff
    80005a1c:	95c080e7          	jalr	-1700(ra) # 80004374 <end_op>
      return -1;
    80005a20:	557d                	li	a0,-1
    80005a22:	b76d                	j	800059cc <sys_open+0xe4>
      end_op();
    80005a24:	fffff097          	auipc	ra,0xfffff
    80005a28:	950080e7          	jalr	-1712(ra) # 80004374 <end_op>
      return -1;
    80005a2c:	557d                	li	a0,-1
    80005a2e:	bf79                	j	800059cc <sys_open+0xe4>
    iunlockput(ip);
    80005a30:	8526                	mv	a0,s1
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	162080e7          	jalr	354(ra) # 80003b94 <iunlockput>
    end_op();
    80005a3a:	fffff097          	auipc	ra,0xfffff
    80005a3e:	93a080e7          	jalr	-1734(ra) # 80004374 <end_op>
    return -1;
    80005a42:	557d                	li	a0,-1
    80005a44:	b761                	j	800059cc <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a46:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a4a:	04649783          	lh	a5,70(s1)
    80005a4e:	02f99223          	sh	a5,36(s3)
    80005a52:	bf25                	j	8000598a <sys_open+0xa2>
    itrunc(ip);
    80005a54:	8526                	mv	a0,s1
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	fea080e7          	jalr	-22(ra) # 80003a40 <itrunc>
    80005a5e:	bfa9                	j	800059b8 <sys_open+0xd0>
      fileclose(f);
    80005a60:	854e                	mv	a0,s3
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	d5e080e7          	jalr	-674(ra) # 800047c0 <fileclose>
    iunlockput(ip);
    80005a6a:	8526                	mv	a0,s1
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	128080e7          	jalr	296(ra) # 80003b94 <iunlockput>
    end_op();
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	900080e7          	jalr	-1792(ra) # 80004374 <end_op>
    return -1;
    80005a7c:	557d                	li	a0,-1
    80005a7e:	b7b9                	j	800059cc <sys_open+0xe4>

0000000080005a80 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a80:	7175                	addi	sp,sp,-144
    80005a82:	e506                	sd	ra,136(sp)
    80005a84:	e122                	sd	s0,128(sp)
    80005a86:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	86c080e7          	jalr	-1940(ra) # 800042f4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a90:	08000613          	li	a2,128
    80005a94:	f7040593          	addi	a1,s0,-144
    80005a98:	4501                	li	a0,0
    80005a9a:	ffffd097          	auipc	ra,0xffffd
    80005a9e:	35c080e7          	jalr	860(ra) # 80002df6 <argstr>
    80005aa2:	02054963          	bltz	a0,80005ad4 <sys_mkdir+0x54>
    80005aa6:	4681                	li	a3,0
    80005aa8:	4601                	li	a2,0
    80005aaa:	4585                	li	a1,1
    80005aac:	f7040513          	addi	a0,s0,-144
    80005ab0:	fffff097          	auipc	ra,0xfffff
    80005ab4:	7fe080e7          	jalr	2046(ra) # 800052ae <create>
    80005ab8:	cd11                	beqz	a0,80005ad4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	0da080e7          	jalr	218(ra) # 80003b94 <iunlockput>
  end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	8b2080e7          	jalr	-1870(ra) # 80004374 <end_op>
  return 0;
    80005aca:	4501                	li	a0,0
}
    80005acc:	60aa                	ld	ra,136(sp)
    80005ace:	640a                	ld	s0,128(sp)
    80005ad0:	6149                	addi	sp,sp,144
    80005ad2:	8082                	ret
    end_op();
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	8a0080e7          	jalr	-1888(ra) # 80004374 <end_op>
    return -1;
    80005adc:	557d                	li	a0,-1
    80005ade:	b7fd                	j	80005acc <sys_mkdir+0x4c>

0000000080005ae0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ae0:	7135                	addi	sp,sp,-160
    80005ae2:	ed06                	sd	ra,152(sp)
    80005ae4:	e922                	sd	s0,144(sp)
    80005ae6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	80c080e7          	jalr	-2036(ra) # 800042f4 <begin_op>
  argint(1, &major);
    80005af0:	f6c40593          	addi	a1,s0,-148
    80005af4:	4505                	li	a0,1
    80005af6:	ffffd097          	auipc	ra,0xffffd
    80005afa:	2c0080e7          	jalr	704(ra) # 80002db6 <argint>
  argint(2, &minor);
    80005afe:	f6840593          	addi	a1,s0,-152
    80005b02:	4509                	li	a0,2
    80005b04:	ffffd097          	auipc	ra,0xffffd
    80005b08:	2b2080e7          	jalr	690(ra) # 80002db6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b0c:	08000613          	li	a2,128
    80005b10:	f7040593          	addi	a1,s0,-144
    80005b14:	4501                	li	a0,0
    80005b16:	ffffd097          	auipc	ra,0xffffd
    80005b1a:	2e0080e7          	jalr	736(ra) # 80002df6 <argstr>
    80005b1e:	02054b63          	bltz	a0,80005b54 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b22:	f6841683          	lh	a3,-152(s0)
    80005b26:	f6c41603          	lh	a2,-148(s0)
    80005b2a:	458d                	li	a1,3
    80005b2c:	f7040513          	addi	a0,s0,-144
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	77e080e7          	jalr	1918(ra) # 800052ae <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b38:	cd11                	beqz	a0,80005b54 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b3a:	ffffe097          	auipc	ra,0xffffe
    80005b3e:	05a080e7          	jalr	90(ra) # 80003b94 <iunlockput>
  end_op();
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	832080e7          	jalr	-1998(ra) # 80004374 <end_op>
  return 0;
    80005b4a:	4501                	li	a0,0
}
    80005b4c:	60ea                	ld	ra,152(sp)
    80005b4e:	644a                	ld	s0,144(sp)
    80005b50:	610d                	addi	sp,sp,160
    80005b52:	8082                	ret
    end_op();
    80005b54:	fffff097          	auipc	ra,0xfffff
    80005b58:	820080e7          	jalr	-2016(ra) # 80004374 <end_op>
    return -1;
    80005b5c:	557d                	li	a0,-1
    80005b5e:	b7fd                	j	80005b4c <sys_mknod+0x6c>

0000000080005b60 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b60:	7135                	addi	sp,sp,-160
    80005b62:	ed06                	sd	ra,152(sp)
    80005b64:	e922                	sd	s0,144(sp)
    80005b66:	e526                	sd	s1,136(sp)
    80005b68:	e14a                	sd	s2,128(sp)
    80005b6a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b6c:	ffffc097          	auipc	ra,0xffffc
    80005b70:	e14080e7          	jalr	-492(ra) # 80001980 <myproc>
    80005b74:	892a                	mv	s2,a0
  
  begin_op();
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	77e080e7          	jalr	1918(ra) # 800042f4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b7e:	08000613          	li	a2,128
    80005b82:	f6040593          	addi	a1,s0,-160
    80005b86:	4501                	li	a0,0
    80005b88:	ffffd097          	auipc	ra,0xffffd
    80005b8c:	26e080e7          	jalr	622(ra) # 80002df6 <argstr>
    80005b90:	04054b63          	bltz	a0,80005be6 <sys_chdir+0x86>
    80005b94:	f6040513          	addi	a0,s0,-160
    80005b98:	ffffe097          	auipc	ra,0xffffe
    80005b9c:	540080e7          	jalr	1344(ra) # 800040d8 <namei>
    80005ba0:	84aa                	mv	s1,a0
    80005ba2:	c131                	beqz	a0,80005be6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	d8e080e7          	jalr	-626(ra) # 80003932 <ilock>
  if(ip->type != T_DIR){
    80005bac:	04449703          	lh	a4,68(s1)
    80005bb0:	4785                	li	a5,1
    80005bb2:	04f71063          	bne	a4,a5,80005bf2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bb6:	8526                	mv	a0,s1
    80005bb8:	ffffe097          	auipc	ra,0xffffe
    80005bbc:	e3c080e7          	jalr	-452(ra) # 800039f4 <iunlock>
  iput(p->cwd);
    80005bc0:	18893503          	ld	a0,392(s2)
    80005bc4:	ffffe097          	auipc	ra,0xffffe
    80005bc8:	f28080e7          	jalr	-216(ra) # 80003aec <iput>
  end_op();
    80005bcc:	ffffe097          	auipc	ra,0xffffe
    80005bd0:	7a8080e7          	jalr	1960(ra) # 80004374 <end_op>
  p->cwd = ip;
    80005bd4:	18993423          	sd	s1,392(s2)
  return 0;
    80005bd8:	4501                	li	a0,0
}
    80005bda:	60ea                	ld	ra,152(sp)
    80005bdc:	644a                	ld	s0,144(sp)
    80005bde:	64aa                	ld	s1,136(sp)
    80005be0:	690a                	ld	s2,128(sp)
    80005be2:	610d                	addi	sp,sp,160
    80005be4:	8082                	ret
    end_op();
    80005be6:	ffffe097          	auipc	ra,0xffffe
    80005bea:	78e080e7          	jalr	1934(ra) # 80004374 <end_op>
    return -1;
    80005bee:	557d                	li	a0,-1
    80005bf0:	b7ed                	j	80005bda <sys_chdir+0x7a>
    iunlockput(ip);
    80005bf2:	8526                	mv	a0,s1
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	fa0080e7          	jalr	-96(ra) # 80003b94 <iunlockput>
    end_op();
    80005bfc:	ffffe097          	auipc	ra,0xffffe
    80005c00:	778080e7          	jalr	1912(ra) # 80004374 <end_op>
    return -1;
    80005c04:	557d                	li	a0,-1
    80005c06:	bfd1                	j	80005bda <sys_chdir+0x7a>

0000000080005c08 <sys_exec>:

uint64
sys_exec(void)
{
    80005c08:	7145                	addi	sp,sp,-464
    80005c0a:	e786                	sd	ra,456(sp)
    80005c0c:	e3a2                	sd	s0,448(sp)
    80005c0e:	ff26                	sd	s1,440(sp)
    80005c10:	fb4a                	sd	s2,432(sp)
    80005c12:	f74e                	sd	s3,424(sp)
    80005c14:	f352                	sd	s4,416(sp)
    80005c16:	ef56                	sd	s5,408(sp)
    80005c18:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c1a:	e3840593          	addi	a1,s0,-456
    80005c1e:	4505                	li	a0,1
    80005c20:	ffffd097          	auipc	ra,0xffffd
    80005c24:	1b6080e7          	jalr	438(ra) # 80002dd6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c28:	08000613          	li	a2,128
    80005c2c:	f4040593          	addi	a1,s0,-192
    80005c30:	4501                	li	a0,0
    80005c32:	ffffd097          	auipc	ra,0xffffd
    80005c36:	1c4080e7          	jalr	452(ra) # 80002df6 <argstr>
    80005c3a:	87aa                	mv	a5,a0
    return -1;
    80005c3c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c3e:	0c07c263          	bltz	a5,80005d02 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c42:	10000613          	li	a2,256
    80005c46:	4581                	li	a1,0
    80005c48:	e4040513          	addi	a0,s0,-448
    80005c4c:	ffffb097          	auipc	ra,0xffffb
    80005c50:	086080e7          	jalr	134(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c54:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c58:	89a6                	mv	s3,s1
    80005c5a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c5c:	02000a13          	li	s4,32
    80005c60:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c64:	00391793          	slli	a5,s2,0x3
    80005c68:	e3040593          	addi	a1,s0,-464
    80005c6c:	e3843503          	ld	a0,-456(s0)
    80005c70:	953e                	add	a0,a0,a5
    80005c72:	ffffd097          	auipc	ra,0xffffd
    80005c76:	0a2080e7          	jalr	162(ra) # 80002d14 <fetchaddr>
    80005c7a:	02054a63          	bltz	a0,80005cae <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c7e:	e3043783          	ld	a5,-464(s0)
    80005c82:	c3b9                	beqz	a5,80005cc8 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c84:	ffffb097          	auipc	ra,0xffffb
    80005c88:	e62080e7          	jalr	-414(ra) # 80000ae6 <kalloc>
    80005c8c:	85aa                	mv	a1,a0
    80005c8e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c92:	cd11                	beqz	a0,80005cae <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c94:	6605                	lui	a2,0x1
    80005c96:	e3043503          	ld	a0,-464(s0)
    80005c9a:	ffffd097          	auipc	ra,0xffffd
    80005c9e:	0ce080e7          	jalr	206(ra) # 80002d68 <fetchstr>
    80005ca2:	00054663          	bltz	a0,80005cae <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005ca6:	0905                	addi	s2,s2,1
    80005ca8:	09a1                	addi	s3,s3,8
    80005caa:	fb491be3          	bne	s2,s4,80005c60 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cae:	10048913          	addi	s2,s1,256
    80005cb2:	6088                	ld	a0,0(s1)
    80005cb4:	c531                	beqz	a0,80005d00 <sys_exec+0xf8>
    kfree(argv[i]);
    80005cb6:	ffffb097          	auipc	ra,0xffffb
    80005cba:	d34080e7          	jalr	-716(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cbe:	04a1                	addi	s1,s1,8
    80005cc0:	ff2499e3          	bne	s1,s2,80005cb2 <sys_exec+0xaa>
  return -1;
    80005cc4:	557d                	li	a0,-1
    80005cc6:	a835                	j	80005d02 <sys_exec+0xfa>
      argv[i] = 0;
    80005cc8:	0a8e                	slli	s5,s5,0x3
    80005cca:	fc040793          	addi	a5,s0,-64
    80005cce:	9abe                	add	s5,s5,a5
    80005cd0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005cd4:	e4040593          	addi	a1,s0,-448
    80005cd8:	f4040513          	addi	a0,s0,-192
    80005cdc:	fffff097          	auipc	ra,0xfffff
    80005ce0:	15e080e7          	jalr	350(ra) # 80004e3a <exec>
    80005ce4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ce6:	10048993          	addi	s3,s1,256
    80005cea:	6088                	ld	a0,0(s1)
    80005cec:	c901                	beqz	a0,80005cfc <sys_exec+0xf4>
    kfree(argv[i]);
    80005cee:	ffffb097          	auipc	ra,0xffffb
    80005cf2:	cfc080e7          	jalr	-772(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cf6:	04a1                	addi	s1,s1,8
    80005cf8:	ff3499e3          	bne	s1,s3,80005cea <sys_exec+0xe2>
  return ret;
    80005cfc:	854a                	mv	a0,s2
    80005cfe:	a011                	j	80005d02 <sys_exec+0xfa>
  return -1;
    80005d00:	557d                	li	a0,-1
}
    80005d02:	60be                	ld	ra,456(sp)
    80005d04:	641e                	ld	s0,448(sp)
    80005d06:	74fa                	ld	s1,440(sp)
    80005d08:	795a                	ld	s2,432(sp)
    80005d0a:	79ba                	ld	s3,424(sp)
    80005d0c:	7a1a                	ld	s4,416(sp)
    80005d0e:	6afa                	ld	s5,408(sp)
    80005d10:	6179                	addi	sp,sp,464
    80005d12:	8082                	ret

0000000080005d14 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d14:	7139                	addi	sp,sp,-64
    80005d16:	fc06                	sd	ra,56(sp)
    80005d18:	f822                	sd	s0,48(sp)
    80005d1a:	f426                	sd	s1,40(sp)
    80005d1c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d1e:	ffffc097          	auipc	ra,0xffffc
    80005d22:	c62080e7          	jalr	-926(ra) # 80001980 <myproc>
    80005d26:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d28:	fd840593          	addi	a1,s0,-40
    80005d2c:	4501                	li	a0,0
    80005d2e:	ffffd097          	auipc	ra,0xffffd
    80005d32:	0a8080e7          	jalr	168(ra) # 80002dd6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d36:	fc840593          	addi	a1,s0,-56
    80005d3a:	fd040513          	addi	a0,s0,-48
    80005d3e:	fffff097          	auipc	ra,0xfffff
    80005d42:	db2080e7          	jalr	-590(ra) # 80004af0 <pipealloc>
    return -1;
    80005d46:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d48:	0c054963          	bltz	a0,80005e1a <sys_pipe+0x106>
  fd0 = -1;
    80005d4c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d50:	fd043503          	ld	a0,-48(s0)
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	518080e7          	jalr	1304(ra) # 8000526c <fdalloc>
    80005d5c:	fca42223          	sw	a0,-60(s0)
    80005d60:	0a054063          	bltz	a0,80005e00 <sys_pipe+0xec>
    80005d64:	fc843503          	ld	a0,-56(s0)
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	504080e7          	jalr	1284(ra) # 8000526c <fdalloc>
    80005d70:	fca42023          	sw	a0,-64(s0)
    80005d74:	06054c63          	bltz	a0,80005dec <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d78:	4691                	li	a3,4
    80005d7a:	fc440613          	addi	a2,s0,-60
    80005d7e:	fd843583          	ld	a1,-40(s0)
    80005d82:	1004b503          	ld	a0,256(s1)
    80005d86:	ffffc097          	auipc	ra,0xffffc
    80005d8a:	8e2080e7          	jalr	-1822(ra) # 80001668 <copyout>
    80005d8e:	02054163          	bltz	a0,80005db0 <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d92:	4691                	li	a3,4
    80005d94:	fc040613          	addi	a2,s0,-64
    80005d98:	fd843583          	ld	a1,-40(s0)
    80005d9c:	0591                	addi	a1,a1,4
    80005d9e:	1004b503          	ld	a0,256(s1)
    80005da2:	ffffc097          	auipc	ra,0xffffc
    80005da6:	8c6080e7          	jalr	-1850(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005daa:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dac:	06055763          	bgez	a0,80005e1a <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80005db0:	fc442783          	lw	a5,-60(s0)
    80005db4:	02078793          	addi	a5,a5,32
    80005db8:	078e                	slli	a5,a5,0x3
    80005dba:	97a6                	add	a5,a5,s1
    80005dbc:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005dc0:	fc042503          	lw	a0,-64(s0)
    80005dc4:	02050513          	addi	a0,a0,32
    80005dc8:	050e                	slli	a0,a0,0x3
    80005dca:	94aa                	add	s1,s1,a0
    80005dcc:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005dd0:	fd043503          	ld	a0,-48(s0)
    80005dd4:	fffff097          	auipc	ra,0xfffff
    80005dd8:	9ec080e7          	jalr	-1556(ra) # 800047c0 <fileclose>
    fileclose(wf);
    80005ddc:	fc843503          	ld	a0,-56(s0)
    80005de0:	fffff097          	auipc	ra,0xfffff
    80005de4:	9e0080e7          	jalr	-1568(ra) # 800047c0 <fileclose>
    return -1;
    80005de8:	57fd                	li	a5,-1
    80005dea:	a805                	j	80005e1a <sys_pipe+0x106>
    if(fd0 >= 0)
    80005dec:	fc442783          	lw	a5,-60(s0)
    80005df0:	0007c863          	bltz	a5,80005e00 <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80005df4:	02078793          	addi	a5,a5,32
    80005df8:	078e                	slli	a5,a5,0x3
    80005dfa:	94be                	add	s1,s1,a5
    80005dfc:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e00:	fd043503          	ld	a0,-48(s0)
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	9bc080e7          	jalr	-1604(ra) # 800047c0 <fileclose>
    fileclose(wf);
    80005e0c:	fc843503          	ld	a0,-56(s0)
    80005e10:	fffff097          	auipc	ra,0xfffff
    80005e14:	9b0080e7          	jalr	-1616(ra) # 800047c0 <fileclose>
    return -1;
    80005e18:	57fd                	li	a5,-1
}
    80005e1a:	853e                	mv	a0,a5
    80005e1c:	70e2                	ld	ra,56(sp)
    80005e1e:	7442                	ld	s0,48(sp)
    80005e20:	74a2                	ld	s1,40(sp)
    80005e22:	6121                	addi	sp,sp,64
    80005e24:	8082                	ret
	...

0000000080005e30 <kernelvec>:
    80005e30:	7111                	addi	sp,sp,-256
    80005e32:	e006                	sd	ra,0(sp)
    80005e34:	e40a                	sd	sp,8(sp)
    80005e36:	e80e                	sd	gp,16(sp)
    80005e38:	ec12                	sd	tp,24(sp)
    80005e3a:	f016                	sd	t0,32(sp)
    80005e3c:	f41a                	sd	t1,40(sp)
    80005e3e:	f81e                	sd	t2,48(sp)
    80005e40:	fc22                	sd	s0,56(sp)
    80005e42:	e0a6                	sd	s1,64(sp)
    80005e44:	e4aa                	sd	a0,72(sp)
    80005e46:	e8ae                	sd	a1,80(sp)
    80005e48:	ecb2                	sd	a2,88(sp)
    80005e4a:	f0b6                	sd	a3,96(sp)
    80005e4c:	f4ba                	sd	a4,104(sp)
    80005e4e:	f8be                	sd	a5,112(sp)
    80005e50:	fcc2                	sd	a6,120(sp)
    80005e52:	e146                	sd	a7,128(sp)
    80005e54:	e54a                	sd	s2,136(sp)
    80005e56:	e94e                	sd	s3,144(sp)
    80005e58:	ed52                	sd	s4,152(sp)
    80005e5a:	f156                	sd	s5,160(sp)
    80005e5c:	f55a                	sd	s6,168(sp)
    80005e5e:	f95e                	sd	s7,176(sp)
    80005e60:	fd62                	sd	s8,184(sp)
    80005e62:	e1e6                	sd	s9,192(sp)
    80005e64:	e5ea                	sd	s10,200(sp)
    80005e66:	e9ee                	sd	s11,208(sp)
    80005e68:	edf2                	sd	t3,216(sp)
    80005e6a:	f1f6                	sd	t4,224(sp)
    80005e6c:	f5fa                	sd	t5,232(sp)
    80005e6e:	f9fe                	sd	t6,240(sp)
    80005e70:	d71fc0ef          	jal	ra,80002be0 <kerneltrap>
    80005e74:	6082                	ld	ra,0(sp)
    80005e76:	6122                	ld	sp,8(sp)
    80005e78:	61c2                	ld	gp,16(sp)
    80005e7a:	7282                	ld	t0,32(sp)
    80005e7c:	7322                	ld	t1,40(sp)
    80005e7e:	73c2                	ld	t2,48(sp)
    80005e80:	7462                	ld	s0,56(sp)
    80005e82:	6486                	ld	s1,64(sp)
    80005e84:	6526                	ld	a0,72(sp)
    80005e86:	65c6                	ld	a1,80(sp)
    80005e88:	6666                	ld	a2,88(sp)
    80005e8a:	7686                	ld	a3,96(sp)
    80005e8c:	7726                	ld	a4,104(sp)
    80005e8e:	77c6                	ld	a5,112(sp)
    80005e90:	7866                	ld	a6,120(sp)
    80005e92:	688a                	ld	a7,128(sp)
    80005e94:	692a                	ld	s2,136(sp)
    80005e96:	69ca                	ld	s3,144(sp)
    80005e98:	6a6a                	ld	s4,152(sp)
    80005e9a:	7a8a                	ld	s5,160(sp)
    80005e9c:	7b2a                	ld	s6,168(sp)
    80005e9e:	7bca                	ld	s7,176(sp)
    80005ea0:	7c6a                	ld	s8,184(sp)
    80005ea2:	6c8e                	ld	s9,192(sp)
    80005ea4:	6d2e                	ld	s10,200(sp)
    80005ea6:	6dce                	ld	s11,208(sp)
    80005ea8:	6e6e                	ld	t3,216(sp)
    80005eaa:	7e8e                	ld	t4,224(sp)
    80005eac:	7f2e                	ld	t5,232(sp)
    80005eae:	7fce                	ld	t6,240(sp)
    80005eb0:	6111                	addi	sp,sp,256
    80005eb2:	10200073          	sret
    80005eb6:	00000013          	nop
    80005eba:	00000013          	nop
    80005ebe:	0001                	nop

0000000080005ec0 <timervec>:
    80005ec0:	34051573          	csrrw	a0,mscratch,a0
    80005ec4:	e10c                	sd	a1,0(a0)
    80005ec6:	e510                	sd	a2,8(a0)
    80005ec8:	e914                	sd	a3,16(a0)
    80005eca:	6d0c                	ld	a1,24(a0)
    80005ecc:	7110                	ld	a2,32(a0)
    80005ece:	6194                	ld	a3,0(a1)
    80005ed0:	96b2                	add	a3,a3,a2
    80005ed2:	e194                	sd	a3,0(a1)
    80005ed4:	4589                	li	a1,2
    80005ed6:	14459073          	csrw	sip,a1
    80005eda:	6914                	ld	a3,16(a0)
    80005edc:	6510                	ld	a2,8(a0)
    80005ede:	610c                	ld	a1,0(a0)
    80005ee0:	34051573          	csrrw	a0,mscratch,a0
    80005ee4:	30200073          	mret
	...

0000000080005eea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eea:	1141                	addi	sp,sp,-16
    80005eec:	e422                	sd	s0,8(sp)
    80005eee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ef0:	0c0007b7          	lui	a5,0xc000
    80005ef4:	4705                	li	a4,1
    80005ef6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ef8:	c3d8                	sw	a4,4(a5)
}
    80005efa:	6422                	ld	s0,8(sp)
    80005efc:	0141                	addi	sp,sp,16
    80005efe:	8082                	ret

0000000080005f00 <plicinithart>:

void
plicinithart(void)
{
    80005f00:	1141                	addi	sp,sp,-16
    80005f02:	e406                	sd	ra,8(sp)
    80005f04:	e022                	sd	s0,0(sp)
    80005f06:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f08:	ffffc097          	auipc	ra,0xffffc
    80005f0c:	a4c080e7          	jalr	-1460(ra) # 80001954 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f10:	0085171b          	slliw	a4,a0,0x8
    80005f14:	0c0027b7          	lui	a5,0xc002
    80005f18:	97ba                	add	a5,a5,a4
    80005f1a:	40200713          	li	a4,1026
    80005f1e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f22:	00d5151b          	slliw	a0,a0,0xd
    80005f26:	0c2017b7          	lui	a5,0xc201
    80005f2a:	953e                	add	a0,a0,a5
    80005f2c:	00052023          	sw	zero,0(a0)
}
    80005f30:	60a2                	ld	ra,8(sp)
    80005f32:	6402                	ld	s0,0(sp)
    80005f34:	0141                	addi	sp,sp,16
    80005f36:	8082                	ret

0000000080005f38 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f38:	1141                	addi	sp,sp,-16
    80005f3a:	e406                	sd	ra,8(sp)
    80005f3c:	e022                	sd	s0,0(sp)
    80005f3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f40:	ffffc097          	auipc	ra,0xffffc
    80005f44:	a14080e7          	jalr	-1516(ra) # 80001954 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f48:	00d5179b          	slliw	a5,a0,0xd
    80005f4c:	0c201537          	lui	a0,0xc201
    80005f50:	953e                	add	a0,a0,a5
  return irq;
}
    80005f52:	4148                	lw	a0,4(a0)
    80005f54:	60a2                	ld	ra,8(sp)
    80005f56:	6402                	ld	s0,0(sp)
    80005f58:	0141                	addi	sp,sp,16
    80005f5a:	8082                	ret

0000000080005f5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f5c:	1101                	addi	sp,sp,-32
    80005f5e:	ec06                	sd	ra,24(sp)
    80005f60:	e822                	sd	s0,16(sp)
    80005f62:	e426                	sd	s1,8(sp)
    80005f64:	1000                	addi	s0,sp,32
    80005f66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f68:	ffffc097          	auipc	ra,0xffffc
    80005f6c:	9ec080e7          	jalr	-1556(ra) # 80001954 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f70:	00d5151b          	slliw	a0,a0,0xd
    80005f74:	0c2017b7          	lui	a5,0xc201
    80005f78:	97aa                	add	a5,a5,a0
    80005f7a:	c3c4                	sw	s1,4(a5)
}
    80005f7c:	60e2                	ld	ra,24(sp)
    80005f7e:	6442                	ld	s0,16(sp)
    80005f80:	64a2                	ld	s1,8(sp)
    80005f82:	6105                	addi	sp,sp,32
    80005f84:	8082                	ret

0000000080005f86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f86:	1141                	addi	sp,sp,-16
    80005f88:	e406                	sd	ra,8(sp)
    80005f8a:	e022                	sd	s0,0(sp)
    80005f8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f8e:	479d                	li	a5,7
    80005f90:	04a7cc63          	blt	a5,a0,80005fe8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f94:	0001d797          	auipc	a5,0x1d
    80005f98:	27c78793          	addi	a5,a5,636 # 80023210 <disk>
    80005f9c:	97aa                	add	a5,a5,a0
    80005f9e:	0187c783          	lbu	a5,24(a5)
    80005fa2:	ebb9                	bnez	a5,80005ff8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005fa4:	00451613          	slli	a2,a0,0x4
    80005fa8:	0001d797          	auipc	a5,0x1d
    80005fac:	26878793          	addi	a5,a5,616 # 80023210 <disk>
    80005fb0:	6394                	ld	a3,0(a5)
    80005fb2:	96b2                	add	a3,a3,a2
    80005fb4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005fb8:	6398                	ld	a4,0(a5)
    80005fba:	9732                	add	a4,a4,a2
    80005fbc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005fc0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005fc4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005fc8:	953e                	add	a0,a0,a5
    80005fca:	4785                	li	a5,1
    80005fcc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005fd0:	0001d517          	auipc	a0,0x1d
    80005fd4:	25850513          	addi	a0,a0,600 # 80023228 <disk+0x18>
    80005fd8:	ffffc097          	auipc	ra,0xffffc
    80005fdc:	152080e7          	jalr	338(ra) # 8000212a <wakeup>
}
    80005fe0:	60a2                	ld	ra,8(sp)
    80005fe2:	6402                	ld	s0,0(sp)
    80005fe4:	0141                	addi	sp,sp,16
    80005fe6:	8082                	ret
    panic("free_desc 1");
    80005fe8:	00002517          	auipc	a0,0x2
    80005fec:	74850513          	addi	a0,a0,1864 # 80008730 <syscalls+0x2f0>
    80005ff0:	ffffa097          	auipc	ra,0xffffa
    80005ff4:	54e080e7          	jalr	1358(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005ff8:	00002517          	auipc	a0,0x2
    80005ffc:	74850513          	addi	a0,a0,1864 # 80008740 <syscalls+0x300>
    80006000:	ffffa097          	auipc	ra,0xffffa
    80006004:	53e080e7          	jalr	1342(ra) # 8000053e <panic>

0000000080006008 <virtio_disk_init>:
{
    80006008:	1101                	addi	sp,sp,-32
    8000600a:	ec06                	sd	ra,24(sp)
    8000600c:	e822                	sd	s0,16(sp)
    8000600e:	e426                	sd	s1,8(sp)
    80006010:	e04a                	sd	s2,0(sp)
    80006012:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006014:	00002597          	auipc	a1,0x2
    80006018:	73c58593          	addi	a1,a1,1852 # 80008750 <syscalls+0x310>
    8000601c:	0001d517          	auipc	a0,0x1d
    80006020:	31c50513          	addi	a0,a0,796 # 80023338 <disk+0x128>
    80006024:	ffffb097          	auipc	ra,0xffffb
    80006028:	b22080e7          	jalr	-1246(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000602c:	100017b7          	lui	a5,0x10001
    80006030:	4398                	lw	a4,0(a5)
    80006032:	2701                	sext.w	a4,a4
    80006034:	747277b7          	lui	a5,0x74727
    80006038:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000603c:	14f71c63          	bne	a4,a5,80006194 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006040:	100017b7          	lui	a5,0x10001
    80006044:	43dc                	lw	a5,4(a5)
    80006046:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006048:	4709                	li	a4,2
    8000604a:	14e79563          	bne	a5,a4,80006194 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000604e:	100017b7          	lui	a5,0x10001
    80006052:	479c                	lw	a5,8(a5)
    80006054:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006056:	12e79f63          	bne	a5,a4,80006194 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000605a:	100017b7          	lui	a5,0x10001
    8000605e:	47d8                	lw	a4,12(a5)
    80006060:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006062:	554d47b7          	lui	a5,0x554d4
    80006066:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000606a:	12f71563          	bne	a4,a5,80006194 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000606e:	100017b7          	lui	a5,0x10001
    80006072:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006076:	4705                	li	a4,1
    80006078:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000607a:	470d                	li	a4,3
    8000607c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000607e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006080:	c7ffe737          	lui	a4,0xc7ffe
    80006084:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb40f>
    80006088:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000608a:	2701                	sext.w	a4,a4
    8000608c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000608e:	472d                	li	a4,11
    80006090:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006092:	5bbc                	lw	a5,112(a5)
    80006094:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006098:	8ba1                	andi	a5,a5,8
    8000609a:	10078563          	beqz	a5,800061a4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000609e:	100017b7          	lui	a5,0x10001
    800060a2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060a6:	43fc                	lw	a5,68(a5)
    800060a8:	2781                	sext.w	a5,a5
    800060aa:	10079563          	bnez	a5,800061b4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060ae:	100017b7          	lui	a5,0x10001
    800060b2:	5bdc                	lw	a5,52(a5)
    800060b4:	2781                	sext.w	a5,a5
  if(max == 0)
    800060b6:	10078763          	beqz	a5,800061c4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800060ba:	471d                	li	a4,7
    800060bc:	10f77c63          	bgeu	a4,a5,800061d4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800060c0:	ffffb097          	auipc	ra,0xffffb
    800060c4:	a26080e7          	jalr	-1498(ra) # 80000ae6 <kalloc>
    800060c8:	0001d497          	auipc	s1,0x1d
    800060cc:	14848493          	addi	s1,s1,328 # 80023210 <disk>
    800060d0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060d2:	ffffb097          	auipc	ra,0xffffb
    800060d6:	a14080e7          	jalr	-1516(ra) # 80000ae6 <kalloc>
    800060da:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060dc:	ffffb097          	auipc	ra,0xffffb
    800060e0:	a0a080e7          	jalr	-1526(ra) # 80000ae6 <kalloc>
    800060e4:	87aa                	mv	a5,a0
    800060e6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060e8:	6088                	ld	a0,0(s1)
    800060ea:	cd6d                	beqz	a0,800061e4 <virtio_disk_init+0x1dc>
    800060ec:	0001d717          	auipc	a4,0x1d
    800060f0:	12c73703          	ld	a4,300(a4) # 80023218 <disk+0x8>
    800060f4:	cb65                	beqz	a4,800061e4 <virtio_disk_init+0x1dc>
    800060f6:	c7fd                	beqz	a5,800061e4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800060f8:	6605                	lui	a2,0x1
    800060fa:	4581                	li	a1,0
    800060fc:	ffffb097          	auipc	ra,0xffffb
    80006100:	bd6080e7          	jalr	-1066(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006104:	0001d497          	auipc	s1,0x1d
    80006108:	10c48493          	addi	s1,s1,268 # 80023210 <disk>
    8000610c:	6605                	lui	a2,0x1
    8000610e:	4581                	li	a1,0
    80006110:	6488                	ld	a0,8(s1)
    80006112:	ffffb097          	auipc	ra,0xffffb
    80006116:	bc0080e7          	jalr	-1088(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000611a:	6605                	lui	a2,0x1
    8000611c:	4581                	li	a1,0
    8000611e:	6888                	ld	a0,16(s1)
    80006120:	ffffb097          	auipc	ra,0xffffb
    80006124:	bb2080e7          	jalr	-1102(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006128:	100017b7          	lui	a5,0x10001
    8000612c:	4721                	li	a4,8
    8000612e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006130:	4098                	lw	a4,0(s1)
    80006132:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006136:	40d8                	lw	a4,4(s1)
    80006138:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000613c:	6498                	ld	a4,8(s1)
    8000613e:	0007069b          	sext.w	a3,a4
    80006142:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006146:	9701                	srai	a4,a4,0x20
    80006148:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000614c:	6898                	ld	a4,16(s1)
    8000614e:	0007069b          	sext.w	a3,a4
    80006152:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006156:	9701                	srai	a4,a4,0x20
    80006158:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000615c:	4705                	li	a4,1
    8000615e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006160:	00e48c23          	sb	a4,24(s1)
    80006164:	00e48ca3          	sb	a4,25(s1)
    80006168:	00e48d23          	sb	a4,26(s1)
    8000616c:	00e48da3          	sb	a4,27(s1)
    80006170:	00e48e23          	sb	a4,28(s1)
    80006174:	00e48ea3          	sb	a4,29(s1)
    80006178:	00e48f23          	sb	a4,30(s1)
    8000617c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006180:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006184:	0727a823          	sw	s2,112(a5)
}
    80006188:	60e2                	ld	ra,24(sp)
    8000618a:	6442                	ld	s0,16(sp)
    8000618c:	64a2                	ld	s1,8(sp)
    8000618e:	6902                	ld	s2,0(sp)
    80006190:	6105                	addi	sp,sp,32
    80006192:	8082                	ret
    panic("could not find virtio disk");
    80006194:	00002517          	auipc	a0,0x2
    80006198:	5cc50513          	addi	a0,a0,1484 # 80008760 <syscalls+0x320>
    8000619c:	ffffa097          	auipc	ra,0xffffa
    800061a0:	3a2080e7          	jalr	930(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800061a4:	00002517          	auipc	a0,0x2
    800061a8:	5dc50513          	addi	a0,a0,1500 # 80008780 <syscalls+0x340>
    800061ac:	ffffa097          	auipc	ra,0xffffa
    800061b0:	392080e7          	jalr	914(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800061b4:	00002517          	auipc	a0,0x2
    800061b8:	5ec50513          	addi	a0,a0,1516 # 800087a0 <syscalls+0x360>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	382080e7          	jalr	898(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800061c4:	00002517          	auipc	a0,0x2
    800061c8:	5fc50513          	addi	a0,a0,1532 # 800087c0 <syscalls+0x380>
    800061cc:	ffffa097          	auipc	ra,0xffffa
    800061d0:	372080e7          	jalr	882(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800061d4:	00002517          	auipc	a0,0x2
    800061d8:	60c50513          	addi	a0,a0,1548 # 800087e0 <syscalls+0x3a0>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	362080e7          	jalr	866(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800061e4:	00002517          	auipc	a0,0x2
    800061e8:	61c50513          	addi	a0,a0,1564 # 80008800 <syscalls+0x3c0>
    800061ec:	ffffa097          	auipc	ra,0xffffa
    800061f0:	352080e7          	jalr	850(ra) # 8000053e <panic>

00000000800061f4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061f4:	7119                	addi	sp,sp,-128
    800061f6:	fc86                	sd	ra,120(sp)
    800061f8:	f8a2                	sd	s0,112(sp)
    800061fa:	f4a6                	sd	s1,104(sp)
    800061fc:	f0ca                	sd	s2,96(sp)
    800061fe:	ecce                	sd	s3,88(sp)
    80006200:	e8d2                	sd	s4,80(sp)
    80006202:	e4d6                	sd	s5,72(sp)
    80006204:	e0da                	sd	s6,64(sp)
    80006206:	fc5e                	sd	s7,56(sp)
    80006208:	f862                	sd	s8,48(sp)
    8000620a:	f466                	sd	s9,40(sp)
    8000620c:	f06a                	sd	s10,32(sp)
    8000620e:	ec6e                	sd	s11,24(sp)
    80006210:	0100                	addi	s0,sp,128
    80006212:	8aaa                	mv	s5,a0
    80006214:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006216:	00c52d03          	lw	s10,12(a0)
    8000621a:	001d1d1b          	slliw	s10,s10,0x1
    8000621e:	1d02                	slli	s10,s10,0x20
    80006220:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006224:	0001d517          	auipc	a0,0x1d
    80006228:	11450513          	addi	a0,a0,276 # 80023338 <disk+0x128>
    8000622c:	ffffb097          	auipc	ra,0xffffb
    80006230:	9aa080e7          	jalr	-1622(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006234:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006236:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006238:	0001db97          	auipc	s7,0x1d
    8000623c:	fd8b8b93          	addi	s7,s7,-40 # 80023210 <disk>
  for(int i = 0; i < 3; i++){
    80006240:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006242:	0001dc97          	auipc	s9,0x1d
    80006246:	0f6c8c93          	addi	s9,s9,246 # 80023338 <disk+0x128>
    8000624a:	a08d                	j	800062ac <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000624c:	00fb8733          	add	a4,s7,a5
    80006250:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006254:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006256:	0207c563          	bltz	a5,80006280 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000625a:	2905                	addiw	s2,s2,1
    8000625c:	0611                	addi	a2,a2,4
    8000625e:	05690c63          	beq	s2,s6,800062b6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006262:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006264:	0001d717          	auipc	a4,0x1d
    80006268:	fac70713          	addi	a4,a4,-84 # 80023210 <disk>
    8000626c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000626e:	01874683          	lbu	a3,24(a4)
    80006272:	fee9                	bnez	a3,8000624c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006274:	2785                	addiw	a5,a5,1
    80006276:	0705                	addi	a4,a4,1
    80006278:	fe979be3          	bne	a5,s1,8000626e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000627c:	57fd                	li	a5,-1
    8000627e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006280:	01205d63          	blez	s2,8000629a <virtio_disk_rw+0xa6>
    80006284:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006286:	000a2503          	lw	a0,0(s4)
    8000628a:	00000097          	auipc	ra,0x0
    8000628e:	cfc080e7          	jalr	-772(ra) # 80005f86 <free_desc>
      for(int j = 0; j < i; j++)
    80006292:	2d85                	addiw	s11,s11,1
    80006294:	0a11                	addi	s4,s4,4
    80006296:	ffb918e3          	bne	s2,s11,80006286 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000629a:	85e6                	mv	a1,s9
    8000629c:	0001d517          	auipc	a0,0x1d
    800062a0:	f8c50513          	addi	a0,a0,-116 # 80023228 <disk+0x18>
    800062a4:	ffffc097          	auipc	ra,0xffffc
    800062a8:	e18080e7          	jalr	-488(ra) # 800020bc <sleep>
  for(int i = 0; i < 3; i++){
    800062ac:	f8040a13          	addi	s4,s0,-128
{
    800062b0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062b2:	894e                	mv	s2,s3
    800062b4:	b77d                	j	80006262 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062b6:	f8042583          	lw	a1,-128(s0)
    800062ba:	00a58793          	addi	a5,a1,10
    800062be:	0792                	slli	a5,a5,0x4

  if(write)
    800062c0:	0001d617          	auipc	a2,0x1d
    800062c4:	f5060613          	addi	a2,a2,-176 # 80023210 <disk>
    800062c8:	00f60733          	add	a4,a2,a5
    800062cc:	018036b3          	snez	a3,s8
    800062d0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062d2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800062d6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062da:	f6078693          	addi	a3,a5,-160
    800062de:	6218                	ld	a4,0(a2)
    800062e0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062e2:	00878513          	addi	a0,a5,8
    800062e6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062e8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062ea:	6208                	ld	a0,0(a2)
    800062ec:	96aa                	add	a3,a3,a0
    800062ee:	4741                	li	a4,16
    800062f0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062f2:	4705                	li	a4,1
    800062f4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800062f8:	f8442703          	lw	a4,-124(s0)
    800062fc:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006300:	0712                	slli	a4,a4,0x4
    80006302:	953a                	add	a0,a0,a4
    80006304:	058a8693          	addi	a3,s5,88
    80006308:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000630a:	6208                	ld	a0,0(a2)
    8000630c:	972a                	add	a4,a4,a0
    8000630e:	40000693          	li	a3,1024
    80006312:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006314:	001c3c13          	seqz	s8,s8
    80006318:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000631a:	001c6c13          	ori	s8,s8,1
    8000631e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006322:	f8842603          	lw	a2,-120(s0)
    80006326:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000632a:	0001d697          	auipc	a3,0x1d
    8000632e:	ee668693          	addi	a3,a3,-282 # 80023210 <disk>
    80006332:	00258713          	addi	a4,a1,2
    80006336:	0712                	slli	a4,a4,0x4
    80006338:	9736                	add	a4,a4,a3
    8000633a:	587d                	li	a6,-1
    8000633c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006340:	0612                	slli	a2,a2,0x4
    80006342:	9532                	add	a0,a0,a2
    80006344:	f9078793          	addi	a5,a5,-112
    80006348:	97b6                	add	a5,a5,a3
    8000634a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000634c:	629c                	ld	a5,0(a3)
    8000634e:	97b2                	add	a5,a5,a2
    80006350:	4605                	li	a2,1
    80006352:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006354:	4509                	li	a0,2
    80006356:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000635a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000635e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006362:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006366:	6698                	ld	a4,8(a3)
    80006368:	00275783          	lhu	a5,2(a4)
    8000636c:	8b9d                	andi	a5,a5,7
    8000636e:	0786                	slli	a5,a5,0x1
    80006370:	97ba                	add	a5,a5,a4
    80006372:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006376:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000637a:	6698                	ld	a4,8(a3)
    8000637c:	00275783          	lhu	a5,2(a4)
    80006380:	2785                	addiw	a5,a5,1
    80006382:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006386:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000638a:	100017b7          	lui	a5,0x10001
    8000638e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006392:	004aa783          	lw	a5,4(s5)
    80006396:	02c79163          	bne	a5,a2,800063b8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000639a:	0001d917          	auipc	s2,0x1d
    8000639e:	f9e90913          	addi	s2,s2,-98 # 80023338 <disk+0x128>
  while(b->disk == 1) {
    800063a2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800063a4:	85ca                	mv	a1,s2
    800063a6:	8556                	mv	a0,s5
    800063a8:	ffffc097          	auipc	ra,0xffffc
    800063ac:	d14080e7          	jalr	-748(ra) # 800020bc <sleep>
  while(b->disk == 1) {
    800063b0:	004aa783          	lw	a5,4(s5)
    800063b4:	fe9788e3          	beq	a5,s1,800063a4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800063b8:	f8042903          	lw	s2,-128(s0)
    800063bc:	00290793          	addi	a5,s2,2
    800063c0:	00479713          	slli	a4,a5,0x4
    800063c4:	0001d797          	auipc	a5,0x1d
    800063c8:	e4c78793          	addi	a5,a5,-436 # 80023210 <disk>
    800063cc:	97ba                	add	a5,a5,a4
    800063ce:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063d2:	0001d997          	auipc	s3,0x1d
    800063d6:	e3e98993          	addi	s3,s3,-450 # 80023210 <disk>
    800063da:	00491713          	slli	a4,s2,0x4
    800063de:	0009b783          	ld	a5,0(s3)
    800063e2:	97ba                	add	a5,a5,a4
    800063e4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063e8:	854a                	mv	a0,s2
    800063ea:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063ee:	00000097          	auipc	ra,0x0
    800063f2:	b98080e7          	jalr	-1128(ra) # 80005f86 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063f6:	8885                	andi	s1,s1,1
    800063f8:	f0ed                	bnez	s1,800063da <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063fa:	0001d517          	auipc	a0,0x1d
    800063fe:	f3e50513          	addi	a0,a0,-194 # 80023338 <disk+0x128>
    80006402:	ffffb097          	auipc	ra,0xffffb
    80006406:	888080e7          	jalr	-1912(ra) # 80000c8a <release>
}
    8000640a:	70e6                	ld	ra,120(sp)
    8000640c:	7446                	ld	s0,112(sp)
    8000640e:	74a6                	ld	s1,104(sp)
    80006410:	7906                	ld	s2,96(sp)
    80006412:	69e6                	ld	s3,88(sp)
    80006414:	6a46                	ld	s4,80(sp)
    80006416:	6aa6                	ld	s5,72(sp)
    80006418:	6b06                	ld	s6,64(sp)
    8000641a:	7be2                	ld	s7,56(sp)
    8000641c:	7c42                	ld	s8,48(sp)
    8000641e:	7ca2                	ld	s9,40(sp)
    80006420:	7d02                	ld	s10,32(sp)
    80006422:	6de2                	ld	s11,24(sp)
    80006424:	6109                	addi	sp,sp,128
    80006426:	8082                	ret

0000000080006428 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006428:	1101                	addi	sp,sp,-32
    8000642a:	ec06                	sd	ra,24(sp)
    8000642c:	e822                	sd	s0,16(sp)
    8000642e:	e426                	sd	s1,8(sp)
    80006430:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006432:	0001d497          	auipc	s1,0x1d
    80006436:	dde48493          	addi	s1,s1,-546 # 80023210 <disk>
    8000643a:	0001d517          	auipc	a0,0x1d
    8000643e:	efe50513          	addi	a0,a0,-258 # 80023338 <disk+0x128>
    80006442:	ffffa097          	auipc	ra,0xffffa
    80006446:	794080e7          	jalr	1940(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000644a:	10001737          	lui	a4,0x10001
    8000644e:	533c                	lw	a5,96(a4)
    80006450:	8b8d                	andi	a5,a5,3
    80006452:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006454:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006458:	689c                	ld	a5,16(s1)
    8000645a:	0204d703          	lhu	a4,32(s1)
    8000645e:	0027d783          	lhu	a5,2(a5)
    80006462:	04f70863          	beq	a4,a5,800064b2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006466:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000646a:	6898                	ld	a4,16(s1)
    8000646c:	0204d783          	lhu	a5,32(s1)
    80006470:	8b9d                	andi	a5,a5,7
    80006472:	078e                	slli	a5,a5,0x3
    80006474:	97ba                	add	a5,a5,a4
    80006476:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006478:	00278713          	addi	a4,a5,2
    8000647c:	0712                	slli	a4,a4,0x4
    8000647e:	9726                	add	a4,a4,s1
    80006480:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006484:	e721                	bnez	a4,800064cc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006486:	0789                	addi	a5,a5,2
    80006488:	0792                	slli	a5,a5,0x4
    8000648a:	97a6                	add	a5,a5,s1
    8000648c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000648e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006492:	ffffc097          	auipc	ra,0xffffc
    80006496:	c98080e7          	jalr	-872(ra) # 8000212a <wakeup>

    disk.used_idx += 1;
    8000649a:	0204d783          	lhu	a5,32(s1)
    8000649e:	2785                	addiw	a5,a5,1
    800064a0:	17c2                	slli	a5,a5,0x30
    800064a2:	93c1                	srli	a5,a5,0x30
    800064a4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064a8:	6898                	ld	a4,16(s1)
    800064aa:	00275703          	lhu	a4,2(a4)
    800064ae:	faf71ce3          	bne	a4,a5,80006466 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800064b2:	0001d517          	auipc	a0,0x1d
    800064b6:	e8650513          	addi	a0,a0,-378 # 80023338 <disk+0x128>
    800064ba:	ffffa097          	auipc	ra,0xffffa
    800064be:	7d0080e7          	jalr	2000(ra) # 80000c8a <release>
}
    800064c2:	60e2                	ld	ra,24(sp)
    800064c4:	6442                	ld	s0,16(sp)
    800064c6:	64a2                	ld	s1,8(sp)
    800064c8:	6105                	addi	sp,sp,32
    800064ca:	8082                	ret
      panic("virtio_disk_intr status");
    800064cc:	00002517          	auipc	a0,0x2
    800064d0:	34c50513          	addi	a0,a0,844 # 80008818 <syscalls+0x3d8>
    800064d4:	ffffa097          	auipc	ra,0xffffa
    800064d8:	06a080e7          	jalr	106(ra) # 8000053e <panic>
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
