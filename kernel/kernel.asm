
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
    80000068:	e6c78793          	addi	a5,a5,-404 # 80005ed0 <timervec>
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
    80000130:	454080e7          	jalr	1108(ra) # 80002580 <either_copyin>
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
    800001cc:	200080e7          	jalr	512(ra) # 800023c8 <killed>
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
    80000216:	316080e7          	jalr	790(ra) # 80002528 <either_copyout>
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
    800002f6:	2e6080e7          	jalr	742(ra) # 800025d8 <procdump>
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
    80000ec2:	a48080e7          	jalr	-1464(ra) # 80002906 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	04a080e7          	jalr	74(ra) # 80005f10 <plicinithart>
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
    80000f3a:	9a8080e7          	jalr	-1624(ra) # 800028de <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	9c8080e7          	jalr	-1592(ra) # 80002906 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	fb4080e7          	jalr	-76(ra) # 80005efa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	fc2080e7          	jalr	-62(ra) # 80005f10 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	148080e7          	jalr	328(ra) # 8000309e <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	7ec080e7          	jalr	2028(ra) # 8000374a <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	78a080e7          	jalr	1930(ra) # 800046f0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	0aa080e7          	jalr	170(ra) # 80006018 <virtio_disk_init>
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
    8000193a:	d50080e7          	jalr	-688(ra) # 80002686 <kthreadinit>
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
    80001b12:	d0a080e7          	jalr	-758(ra) # 80002818 <freethread>
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
    80001bd0:	bcc080e7          	jalr	-1076(ra) # 80002798 <allockthread>
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
    80001cca:	426080e7          	jalr	1062(ra) # 800040ec <namei>
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
    80001d66:	996080e7          	jalr	-1642(ra) # 800026f8 <mykthread>
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
    80001e10:	976080e7          	jalr	-1674(ra) # 80004782 <filedup>
    80001e14:	00a93023          	sd	a0,0(s2)
    80001e18:	b7e5                	j	80001e00 <fork+0xba>
  np->cwd = idup(p->cwd);
    80001e1a:	188ab503          	ld	a0,392(s5)
    80001e1e:	00002097          	auipc	ra,0x2
    80001e22:	aea080e7          	jalr	-1302(ra) # 80003908 <idup>
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
    80001f50:	928080e7          	jalr	-1752(ra) # 80002874 <swtch>
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
    80001f6c:	790080e7          	jalr	1936(ra) # 800026f8 <mykthread>
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
    80001fd2:	8a6080e7          	jalr	-1882(ra) # 80002874 <swtch>
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
    80002082:	67a080e7          	jalr	1658(ra) # 800026f8 <mykthread>
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
    8000209c:	886080e7          	jalr	-1914(ra) # 8000291e <usertrapret>
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
    800020b6:	618080e7          	jalr	1560(ra) # 800036ca <fsinit>
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
    8000216c:	590080e7          	jalr	1424(ra) # 800026f8 <mykthread>
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
    8000221a:	892a                	mv	s2,a0
  if(p == initproc)
    8000221c:	00006797          	auipc	a5,0x6
    80002220:	6ac7b783          	ld	a5,1708(a5) # 800088c8 <initproc>
    80002224:	10850493          	addi	s1,a0,264
    80002228:	18850993          	addi	s3,a0,392
    8000222c:	02a79363          	bne	a5,a0,80002252 <exit+0x52>
    panic("init exiting");
    80002230:	00006517          	auipc	a0,0x6
    80002234:	03050513          	addi	a0,a0,48 # 80008260 <digits+0x220>
    80002238:	ffffe097          	auipc	ra,0xffffe
    8000223c:	306080e7          	jalr	774(ra) # 8000053e <panic>
      fileclose(f);
    80002240:	00002097          	auipc	ra,0x2
    80002244:	594080e7          	jalr	1428(ra) # 800047d4 <fileclose>
      p->ofile[fd] = 0;
    80002248:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000224c:	04a1                	addi	s1,s1,8
    8000224e:	00998563          	beq	s3,s1,80002258 <exit+0x58>
    if(p->ofile[fd]){
    80002252:	6088                	ld	a0,0(s1)
    80002254:	f575                	bnez	a0,80002240 <exit+0x40>
    80002256:	bfdd                	j	8000224c <exit+0x4c>
  begin_op();
    80002258:	00002097          	auipc	ra,0x2
    8000225c:	0b0080e7          	jalr	176(ra) # 80004308 <begin_op>
  iput(p->cwd);
    80002260:	18893503          	ld	a0,392(s2)
    80002264:	00002097          	auipc	ra,0x2
    80002268:	89c080e7          	jalr	-1892(ra) # 80003b00 <iput>
  end_op();
    8000226c:	00002097          	auipc	ra,0x2
    80002270:	11c080e7          	jalr	284(ra) # 80004388 <end_op>
  p->cwd = 0;
    80002274:	18093423          	sd	zero,392(s2)
  acquire(&wait_lock);
    80002278:	0000f517          	auipc	a0,0xf
    8000227c:	8e050513          	addi	a0,a0,-1824 # 80010b58 <wait_lock>
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	956080e7          	jalr	-1706(ra) # 80000bd6 <acquire>
  reparent(p);
    80002288:	854a                	mv	a0,s2
    8000228a:	00000097          	auipc	ra,0x0
    8000228e:	f1c080e7          	jalr	-228(ra) # 800021a6 <reparent>
  wakeup(p->parent);
    80002292:	0f093503          	ld	a0,240(s2)
    80002296:	00000097          	auipc	ra,0x0
    8000229a:	e94080e7          	jalr	-364(ra) # 8000212a <wakeup>
  acquire(&p->lock);
    8000229e:	854a                	mv	a0,s2
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	936080e7          	jalr	-1738(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800022a8:	03492023          	sw	s4,32(s2)
  p->state = ZOMBIE;
    800022ac:	4789                	li	a5,2
    800022ae:	00f92c23          	sw	a5,24(s2)
  release(&p->lock);
    800022b2:	854a                	mv	a0,s2
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	9d6080e7          	jalr	-1578(ra) # 80000c8a <release>
    acquire(&kt->t_lock);
    800022bc:	02890493          	addi	s1,s2,40
    800022c0:	8526                	mv	a0,s1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	914080e7          	jalr	-1772(ra) # 80000bd6 <acquire>
    kt->t_xstate=status;
    800022ca:	05492a23          	sw	s4,84(s2)
    kt->t_state=ZOMBIE_t;
    800022ce:	4795                	li	a5,5
    800022d0:	04f92023          	sw	a5,64(s2)
    if(kt !=mykthread()){
    800022d4:	00000097          	auipc	ra,0x0
    800022d8:	424080e7          	jalr	1060(ra) # 800026f8 <mykthread>
    800022dc:	00a48763          	beq	s1,a0,800022ea <exit+0xea>
      release(&kt->t_lock);
    800022e0:	8526                	mv	a0,s1
    800022e2:	fffff097          	auipc	ra,0xfffff
    800022e6:	9a8080e7          	jalr	-1624(ra) # 80000c8a <release>
  release(&wait_lock);
    800022ea:	0000f517          	auipc	a0,0xf
    800022ee:	86e50513          	addi	a0,a0,-1938 # 80010b58 <wait_lock>
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	998080e7          	jalr	-1640(ra) # 80000c8a <release>
  sched();
    800022fa:	00000097          	auipc	ra,0x0
    800022fe:	c60080e7          	jalr	-928(ra) # 80001f5a <sched>
  panic("zombie exit");
    80002302:	00006517          	auipc	a0,0x6
    80002306:	f6e50513          	addi	a0,a0,-146 # 80008270 <digits+0x230>
    8000230a:	ffffe097          	auipc	ra,0xffffe
    8000230e:	234080e7          	jalr	564(ra) # 8000053e <panic>

0000000080002312 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002312:	7179                	addi	sp,sp,-48
    80002314:	f406                	sd	ra,40(sp)
    80002316:	f022                	sd	s0,32(sp)
    80002318:	ec26                	sd	s1,24(sp)
    8000231a:	e84a                	sd	s2,16(sp)
    8000231c:	e44e                	sd	s3,8(sp)
    8000231e:	1800                	addi	s0,sp,48
    80002320:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002322:	0000f497          	auipc	s1,0xf
    80002326:	c4e48493          	addi	s1,s1,-946 # 80010f70 <proc>
    8000232a:	00016997          	auipc	s3,0x16
    8000232e:	c4698993          	addi	s3,s3,-954 # 80017f70 <tickslock>
    acquire(&p->lock);
    80002332:	8526                	mv	a0,s1
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	8a2080e7          	jalr	-1886(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    8000233c:	50dc                	lw	a5,36(s1)
    8000233e:	01278d63          	beq	a5,s2,80002358 <kill+0x46>
      // }
      release(&p->lock);
      return 0;
    }
    
    release(&p->lock);
    80002342:	8526                	mv	a0,s1
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	946080e7          	jalr	-1722(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234c:	1c048493          	addi	s1,s1,448
    80002350:	ff3491e3          	bne	s1,s3,80002332 <kill+0x20>
  }
  return -1;
    80002354:	557d                	li	a0,-1
    80002356:	a80d                	j	80002388 <kill+0x76>
      p->killed = 1;
    80002358:	4785                	li	a5,1
    8000235a:	ccdc                	sw	a5,28(s1)
        acquire(&t->t_lock);
    8000235c:	02848913          	addi	s2,s1,40
    80002360:	854a                	mv	a0,s2
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	874080e7          	jalr	-1932(ra) # 80000bd6 <acquire>
        if(t->t_state == SLEEPING_t) {
    8000236a:	40b8                	lw	a4,64(s1)
    8000236c:	4789                	li	a5,2
    8000236e:	02f70463          	beq	a4,a5,80002396 <kill+0x84>
        release(&t->t_lock);
    80002372:	854a                	mv	a0,s2
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	916080e7          	jalr	-1770(ra) # 80000c8a <release>
      release(&p->lock);
    8000237c:	8526                	mv	a0,s1
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	90c080e7          	jalr	-1780(ra) # 80000c8a <release>
      return 0;
    80002386:	4501                	li	a0,0
}
    80002388:	70a2                	ld	ra,40(sp)
    8000238a:	7402                	ld	s0,32(sp)
    8000238c:	64e2                	ld	s1,24(sp)
    8000238e:	6942                	ld	s2,16(sp)
    80002390:	69a2                	ld	s3,8(sp)
    80002392:	6145                	addi	sp,sp,48
    80002394:	8082                	ret
          t->t_state = RUNNABLE_t;
    80002396:	478d                	li	a5,3
    80002398:	c0bc                	sw	a5,64(s1)
    8000239a:	bfe1                	j	80002372 <kill+0x60>

000000008000239c <setkilled>:


void
setkilled(struct proc *p)
{
    8000239c:	1101                	addi	sp,sp,-32
    8000239e:	ec06                	sd	ra,24(sp)
    800023a0:	e822                	sd	s0,16(sp)
    800023a2:	e426                	sd	s1,8(sp)
    800023a4:	1000                	addi	s0,sp,32
    800023a6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	82e080e7          	jalr	-2002(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800023b0:	4785                	li	a5,1
    800023b2:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    800023b4:	8526                	mv	a0,s1
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	8d4080e7          	jalr	-1836(ra) # 80000c8a <release>
}
    800023be:	60e2                	ld	ra,24(sp)
    800023c0:	6442                	ld	s0,16(sp)
    800023c2:	64a2                	ld	s1,8(sp)
    800023c4:	6105                	addi	sp,sp,32
    800023c6:	8082                	ret

00000000800023c8 <killed>:

int
killed(struct proc *p)
{
    800023c8:	1101                	addi	sp,sp,-32
    800023ca:	ec06                	sd	ra,24(sp)
    800023cc:	e822                	sd	s0,16(sp)
    800023ce:	e426                	sd	s1,8(sp)
    800023d0:	e04a                	sd	s2,0(sp)
    800023d2:	1000                	addi	s0,sp,32
    800023d4:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023d6:	fffff097          	auipc	ra,0xfffff
    800023da:	800080e7          	jalr	-2048(ra) # 80000bd6 <acquire>
  k = p->killed;
    800023de:	01c4a903          	lw	s2,28(s1)
  release(&p->lock);
    800023e2:	8526                	mv	a0,s1
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8a6080e7          	jalr	-1882(ra) # 80000c8a <release>
  return k;
}
    800023ec:	854a                	mv	a0,s2
    800023ee:	60e2                	ld	ra,24(sp)
    800023f0:	6442                	ld	s0,16(sp)
    800023f2:	64a2                	ld	s1,8(sp)
    800023f4:	6902                	ld	s2,0(sp)
    800023f6:	6105                	addi	sp,sp,32
    800023f8:	8082                	ret

00000000800023fa <wait>:
{
    800023fa:	715d                	addi	sp,sp,-80
    800023fc:	e486                	sd	ra,72(sp)
    800023fe:	e0a2                	sd	s0,64(sp)
    80002400:	fc26                	sd	s1,56(sp)
    80002402:	f84a                	sd	s2,48(sp)
    80002404:	f44e                	sd	s3,40(sp)
    80002406:	f052                	sd	s4,32(sp)
    80002408:	ec56                	sd	s5,24(sp)
    8000240a:	e85a                	sd	s6,16(sp)
    8000240c:	e45e                	sd	s7,8(sp)
    8000240e:	e062                	sd	s8,0(sp)
    80002410:	0880                	addi	s0,sp,80
    80002412:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	56c080e7          	jalr	1388(ra) # 80001980 <myproc>
    8000241c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000241e:	0000e517          	auipc	a0,0xe
    80002422:	73a50513          	addi	a0,a0,1850 # 80010b58 <wait_lock>
    80002426:	ffffe097          	auipc	ra,0xffffe
    8000242a:	7b0080e7          	jalr	1968(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000242e:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002430:	4a09                	li	s4,2
        havekids = 1;
    80002432:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002434:	00016997          	auipc	s3,0x16
    80002438:	b3c98993          	addi	s3,s3,-1220 # 80017f70 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000243c:	0000ec17          	auipc	s8,0xe
    80002440:	71cc0c13          	addi	s8,s8,1820 # 80010b58 <wait_lock>
    havekids = 0;
    80002444:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002446:	0000f497          	auipc	s1,0xf
    8000244a:	b2a48493          	addi	s1,s1,-1238 # 80010f70 <proc>
    8000244e:	a0bd                	j	800024bc <wait+0xc2>
          pid = pp->pid;
    80002450:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002454:	000b0e63          	beqz	s6,80002470 <wait+0x76>
    80002458:	4691                	li	a3,4
    8000245a:	02048613          	addi	a2,s1,32
    8000245e:	85da                	mv	a1,s6
    80002460:	10093503          	ld	a0,256(s2)
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	204080e7          	jalr	516(ra) # 80001668 <copyout>
    8000246c:	02054563          	bltz	a0,80002496 <wait+0x9c>
          freeproc(pp);
    80002470:	8526                	mv	a0,s1
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	67e080e7          	jalr	1662(ra) # 80001af0 <freeproc>
          release(&pp->lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	80e080e7          	jalr	-2034(ra) # 80000c8a <release>
          release(&wait_lock);
    80002484:	0000e517          	auipc	a0,0xe
    80002488:	6d450513          	addi	a0,a0,1748 # 80010b58 <wait_lock>
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	7fe080e7          	jalr	2046(ra) # 80000c8a <release>
          return pid;
    80002494:	a0b5                	j	80002500 <wait+0x106>
            release(&pp->lock);
    80002496:	8526                	mv	a0,s1
    80002498:	ffffe097          	auipc	ra,0xffffe
    8000249c:	7f2080e7          	jalr	2034(ra) # 80000c8a <release>
            release(&wait_lock);
    800024a0:	0000e517          	auipc	a0,0xe
    800024a4:	6b850513          	addi	a0,a0,1720 # 80010b58 <wait_lock>
    800024a8:	ffffe097          	auipc	ra,0xffffe
    800024ac:	7e2080e7          	jalr	2018(ra) # 80000c8a <release>
            return -1;
    800024b0:	59fd                	li	s3,-1
    800024b2:	a0b9                	j	80002500 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b4:	1c048493          	addi	s1,s1,448
    800024b8:	03348463          	beq	s1,s3,800024e0 <wait+0xe6>
      if(pp->parent == p){
    800024bc:	78fc                	ld	a5,240(s1)
    800024be:	ff279be3          	bne	a5,s2,800024b4 <wait+0xba>
        acquire(&pp->lock);
    800024c2:	8526                	mv	a0,s1
    800024c4:	ffffe097          	auipc	ra,0xffffe
    800024c8:	712080e7          	jalr	1810(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    800024cc:	4c9c                	lw	a5,24(s1)
    800024ce:	f94781e3          	beq	a5,s4,80002450 <wait+0x56>
        release(&pp->lock);
    800024d2:	8526                	mv	a0,s1
    800024d4:	ffffe097          	auipc	ra,0xffffe
    800024d8:	7b6080e7          	jalr	1974(ra) # 80000c8a <release>
        havekids = 1;
    800024dc:	8756                	mv	a4,s5
    800024de:	bfd9                	j	800024b4 <wait+0xba>
    if(!havekids || killed(p)){
    800024e0:	c719                	beqz	a4,800024ee <wait+0xf4>
    800024e2:	854a                	mv	a0,s2
    800024e4:	00000097          	auipc	ra,0x0
    800024e8:	ee4080e7          	jalr	-284(ra) # 800023c8 <killed>
    800024ec:	c51d                	beqz	a0,8000251a <wait+0x120>
      release(&wait_lock);
    800024ee:	0000e517          	auipc	a0,0xe
    800024f2:	66a50513          	addi	a0,a0,1642 # 80010b58 <wait_lock>
    800024f6:	ffffe097          	auipc	ra,0xffffe
    800024fa:	794080e7          	jalr	1940(ra) # 80000c8a <release>
      return -1;
    800024fe:	59fd                	li	s3,-1
}
    80002500:	854e                	mv	a0,s3
    80002502:	60a6                	ld	ra,72(sp)
    80002504:	6406                	ld	s0,64(sp)
    80002506:	74e2                	ld	s1,56(sp)
    80002508:	7942                	ld	s2,48(sp)
    8000250a:	79a2                	ld	s3,40(sp)
    8000250c:	7a02                	ld	s4,32(sp)
    8000250e:	6ae2                	ld	s5,24(sp)
    80002510:	6b42                	ld	s6,16(sp)
    80002512:	6ba2                	ld	s7,8(sp)
    80002514:	6c02                	ld	s8,0(sp)
    80002516:	6161                	addi	sp,sp,80
    80002518:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000251a:	85e2                	mv	a1,s8
    8000251c:	854a                	mv	a0,s2
    8000251e:	00000097          	auipc	ra,0x0
    80002522:	b9e080e7          	jalr	-1122(ra) # 800020bc <sleep>
    havekids = 0;
    80002526:	bf39                	j	80002444 <wait+0x4a>

0000000080002528 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002528:	7179                	addi	sp,sp,-48
    8000252a:	f406                	sd	ra,40(sp)
    8000252c:	f022                	sd	s0,32(sp)
    8000252e:	ec26                	sd	s1,24(sp)
    80002530:	e84a                	sd	s2,16(sp)
    80002532:	e44e                	sd	s3,8(sp)
    80002534:	e052                	sd	s4,0(sp)
    80002536:	1800                	addi	s0,sp,48
    80002538:	84aa                	mv	s1,a0
    8000253a:	892e                	mv	s2,a1
    8000253c:	89b2                	mv	s3,a2
    8000253e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002540:	fffff097          	auipc	ra,0xfffff
    80002544:	440080e7          	jalr	1088(ra) # 80001980 <myproc>
  if(user_dst){
    80002548:	c095                	beqz	s1,8000256c <either_copyout+0x44>
    return copyout(p->pagetable, dst, src, len);
    8000254a:	86d2                	mv	a3,s4
    8000254c:	864e                	mv	a2,s3
    8000254e:	85ca                	mv	a1,s2
    80002550:	10053503          	ld	a0,256(a0)
    80002554:	fffff097          	auipc	ra,0xfffff
    80002558:	114080e7          	jalr	276(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000255c:	70a2                	ld	ra,40(sp)
    8000255e:	7402                	ld	s0,32(sp)
    80002560:	64e2                	ld	s1,24(sp)
    80002562:	6942                	ld	s2,16(sp)
    80002564:	69a2                	ld	s3,8(sp)
    80002566:	6a02                	ld	s4,0(sp)
    80002568:	6145                	addi	sp,sp,48
    8000256a:	8082                	ret
    memmove((char *)dst, src, len);
    8000256c:	000a061b          	sext.w	a2,s4
    80002570:	85ce                	mv	a1,s3
    80002572:	854a                	mv	a0,s2
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	7ba080e7          	jalr	1978(ra) # 80000d2e <memmove>
    return 0;
    8000257c:	8526                	mv	a0,s1
    8000257e:	bff9                	j	8000255c <either_copyout+0x34>

0000000080002580 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002580:	7179                	addi	sp,sp,-48
    80002582:	f406                	sd	ra,40(sp)
    80002584:	f022                	sd	s0,32(sp)
    80002586:	ec26                	sd	s1,24(sp)
    80002588:	e84a                	sd	s2,16(sp)
    8000258a:	e44e                	sd	s3,8(sp)
    8000258c:	e052                	sd	s4,0(sp)
    8000258e:	1800                	addi	s0,sp,48
    80002590:	892a                	mv	s2,a0
    80002592:	84ae                	mv	s1,a1
    80002594:	89b2                	mv	s3,a2
    80002596:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002598:	fffff097          	auipc	ra,0xfffff
    8000259c:	3e8080e7          	jalr	1000(ra) # 80001980 <myproc>
  if(user_src){
    800025a0:	c095                	beqz	s1,800025c4 <either_copyin+0x44>
    return copyin(p->pagetable, dst, src, len);
    800025a2:	86d2                	mv	a3,s4
    800025a4:	864e                	mv	a2,s3
    800025a6:	85ca                	mv	a1,s2
    800025a8:	10053503          	ld	a0,256(a0)
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	148080e7          	jalr	328(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025b4:	70a2                	ld	ra,40(sp)
    800025b6:	7402                	ld	s0,32(sp)
    800025b8:	64e2                	ld	s1,24(sp)
    800025ba:	6942                	ld	s2,16(sp)
    800025bc:	69a2                	ld	s3,8(sp)
    800025be:	6a02                	ld	s4,0(sp)
    800025c0:	6145                	addi	sp,sp,48
    800025c2:	8082                	ret
    memmove(dst, (char*)src, len);
    800025c4:	000a061b          	sext.w	a2,s4
    800025c8:	85ce                	mv	a1,s3
    800025ca:	854a                	mv	a0,s2
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	762080e7          	jalr	1890(ra) # 80000d2e <memmove>
    return 0;
    800025d4:	8526                	mv	a0,s1
    800025d6:	bff9                	j	800025b4 <either_copyin+0x34>

00000000800025d8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025d8:	715d                	addi	sp,sp,-80
    800025da:	e486                	sd	ra,72(sp)
    800025dc:	e0a2                	sd	s0,64(sp)
    800025de:	fc26                	sd	s1,56(sp)
    800025e0:	f84a                	sd	s2,48(sp)
    800025e2:	f44e                	sd	s3,40(sp)
    800025e4:	f052                	sd	s4,32(sp)
    800025e6:	ec56                	sd	s5,24(sp)
    800025e8:	e85a                	sd	s6,16(sp)
    800025ea:	e45e                	sd	s7,8(sp)
    800025ec:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025ee:	00006517          	auipc	a0,0x6
    800025f2:	ada50513          	addi	a0,a0,-1318 # 800080c8 <digits+0x88>
    800025f6:	ffffe097          	auipc	ra,0xffffe
    800025fa:	f92080e7          	jalr	-110(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025fe:	0000f497          	auipc	s1,0xf
    80002602:	b0248493          	addi	s1,s1,-1278 # 80011100 <proc+0x190>
    80002606:	00016917          	auipc	s2,0x16
    8000260a:	afa90913          	addi	s2,s2,-1286 # 80018100 <bcache+0x178>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000260e:	4b09                	li	s6,2
      state = states[p->state];
    else
      state = "???";
    80002610:	00006997          	auipc	s3,0x6
    80002614:	c7098993          	addi	s3,s3,-912 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002618:	00006a97          	auipc	s5,0x6
    8000261c:	c70a8a93          	addi	s5,s5,-912 # 80008288 <digits+0x248>
    printf("\n");
    80002620:	00006a17          	auipc	s4,0x6
    80002624:	aa8a0a13          	addi	s4,s4,-1368 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002628:	00006b97          	auipc	s7,0x6
    8000262c:	c88b8b93          	addi	s7,s7,-888 # 800082b0 <states.0>
    80002630:	a00d                	j	80002652 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002632:	e946a583          	lw	a1,-364(a3)
    80002636:	8556                	mv	a0,s5
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	f50080e7          	jalr	-176(ra) # 80000588 <printf>
    printf("\n");
    80002640:	8552                	mv	a0,s4
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	f46080e7          	jalr	-186(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000264a:	1c048493          	addi	s1,s1,448
    8000264e:	03248163          	beq	s1,s2,80002670 <procdump+0x98>
    if(p->state == UNUSED)
    80002652:	86a6                	mv	a3,s1
    80002654:	e884a783          	lw	a5,-376(s1)
    80002658:	dbed                	beqz	a5,8000264a <procdump+0x72>
      state = "???";
    8000265a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000265c:	fcfb6be3          	bltu	s6,a5,80002632 <procdump+0x5a>
    80002660:	1782                	slli	a5,a5,0x20
    80002662:	9381                	srli	a5,a5,0x20
    80002664:	078e                	slli	a5,a5,0x3
    80002666:	97de                	add	a5,a5,s7
    80002668:	6390                	ld	a2,0(a5)
    8000266a:	f661                	bnez	a2,80002632 <procdump+0x5a>
      state = "???";
    8000266c:	864e                	mv	a2,s3
    8000266e:	b7d1                	j	80002632 <procdump+0x5a>
  }
}
    80002670:	60a6                	ld	ra,72(sp)
    80002672:	6406                	ld	s0,64(sp)
    80002674:	74e2                	ld	s1,56(sp)
    80002676:	7942                	ld	s2,48(sp)
    80002678:	79a2                	ld	s3,40(sp)
    8000267a:	7a02                	ld	s4,32(sp)
    8000267c:	6ae2                	ld	s5,24(sp)
    8000267e:	6b42                	ld	s6,16(sp)
    80002680:	6ba2                	ld	s7,8(sp)
    80002682:	6161                	addi	sp,sp,80
    80002684:	8082                	ret

0000000080002686 <kthreadinit>:
#include "defs.h"

extern struct proc proc[NPROC];
extern void forkret(void);
void kthreadinit(struct proc *p)
{
    80002686:	1101                	addi	sp,sp,-32
    80002688:	ec06                	sd	ra,24(sp)
    8000268a:	e822                	sd	s0,16(sp)
    8000268c:	e426                	sd	s1,8(sp)
    8000268e:	1000                	addi	s0,sp,32
    80002690:	84aa                	mv	s1,a0
  initlock(&(p->alloc_lock),"aloc_thread");
    80002692:	00006597          	auipc	a1,0x6
    80002696:	c3658593          	addi	a1,a1,-970 # 800082c8 <states.0+0x18>
    8000269a:	1a850513          	addi	a0,a0,424
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	4a8080e7          	jalr	1192(ra) # 80000b46 <initlock>
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
    800026a6:	00006597          	auipc	a1,0x6
    800026aa:	c3258593          	addi	a1,a1,-974 # 800082d8 <states.0+0x28>
    800026ae:	02848513          	addi	a0,s1,40
    800026b2:	ffffe097          	auipc	ra,0xffffe
    800026b6:	494080e7          	jalr	1172(ra) # 80000b46 <initlock>
      kt->t_state = UNUSED_t;
    800026ba:	0404a023          	sw	zero,64(s1)
      kt->process=p;
    800026be:	f0a4                	sd	s1,96(s1)
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    800026c0:	0000f797          	auipc	a5,0xf
    800026c4:	8b078793          	addi	a5,a5,-1872 # 80010f70 <proc>
    800026c8:	40f487b3          	sub	a5,s1,a5
    800026cc:	8799                	srai	a5,a5,0x6
    800026ce:	00006717          	auipc	a4,0x6
    800026d2:	93273703          	ld	a4,-1742(a4) # 80008000 <etext>
    800026d6:	02e787b3          	mul	a5,a5,a4
    800026da:	2785                	addiw	a5,a5,1
    800026dc:	00d7979b          	slliw	a5,a5,0xd
    800026e0:	04000737          	lui	a4,0x4000
    800026e4:	177d                	addi	a4,a4,-1
    800026e6:	0732                	slli	a4,a4,0xc
    800026e8:	40f707b3          	sub	a5,a4,a5
    800026ec:	ecfc                	sd	a5,216(s1)
  }
}
    800026ee:	60e2                	ld	ra,24(sp)
    800026f0:	6442                	ld	s0,16(sp)
    800026f2:	64a2                	ld	s1,8(sp)
    800026f4:	6105                	addi	sp,sp,32
    800026f6:	8082                	ret

00000000800026f8 <mykthread>:

struct kthread *mykthread()
{
    800026f8:	1101                	addi	sp,sp,-32
    800026fa:	ec06                	sd	ra,24(sp)
    800026fc:	e822                	sd	s0,16(sp)
    800026fe:	e426                	sd	s1,8(sp)
    80002700:	1000                	addi	s0,sp,32
  push_off();
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	488080e7          	jalr	1160(ra) # 80000b8a <push_off>
  struct cpu *c = mycpu();
    8000270a:	fffff097          	auipc	ra,0xfffff
    8000270e:	25a080e7          	jalr	602(ra) # 80001964 <mycpu>
  struct kthread *kthread = c->kthread;
    80002712:	6104                	ld	s1,0(a0)
  pop_off();
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	516080e7          	jalr	1302(ra) # 80000c2a <pop_off>
  return kthread;
}
    8000271c:	8526                	mv	a0,s1
    8000271e:	60e2                	ld	ra,24(sp)
    80002720:	6442                	ld	s0,16(sp)
    80002722:	64a2                	ld	s1,8(sp)
    80002724:	6105                	addi	sp,sp,32
    80002726:	8082                	ret

0000000080002728 <alloctid>:

int alloctid(struct proc *p){
    80002728:	7179                	addi	sp,sp,-48
    8000272a:	f406                	sd	ra,40(sp)
    8000272c:	f022                	sd	s0,32(sp)
    8000272e:	ec26                	sd	s1,24(sp)
    80002730:	e84a                	sd	s2,16(sp)
    80002732:	e44e                	sd	s3,8(sp)
    80002734:	1800                	addi	s0,sp,48
    80002736:	84aa                	mv	s1,a0
  int tid;
  acquire(&(p->alloc_lock));
    80002738:	1a850993          	addi	s3,a0,424
    8000273c:	854e                	mv	a0,s3
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	498080e7          	jalr	1176(ra) # 80000bd6 <acquire>
  tid = p->p_counter;
    80002746:	1a04a903          	lw	s2,416(s1)
  p->p_counter++;
    8000274a:	0019079b          	addiw	a5,s2,1
    8000274e:	1af4a023          	sw	a5,416(s1)
  release(&(p->alloc_lock));
    80002752:	854e                	mv	a0,s3
    80002754:	ffffe097          	auipc	ra,0xffffe
    80002758:	536080e7          	jalr	1334(ra) # 80000c8a <release>
  return tid;
}
    8000275c:	854a                	mv	a0,s2
    8000275e:	70a2                	ld	ra,40(sp)
    80002760:	7402                	ld	s0,32(sp)
    80002762:	64e2                	ld	s1,24(sp)
    80002764:	6942                	ld	s2,16(sp)
    80002766:	69a2                	ld	s3,8(sp)
    80002768:	6145                	addi	sp,sp,48
    8000276a:	8082                	ret

000000008000276c <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    8000276c:	1141                	addi	sp,sp,-16
    8000276e:	e422                	sd	s0,8(sp)
    80002770:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    80002772:	02850793          	addi	a5,a0,40
    80002776:	8d9d                	sub	a1,a1,a5
    80002778:	8599                	srai	a1,a1,0x6
    8000277a:	00006797          	auipc	a5,0x6
    8000277e:	88e7b783          	ld	a5,-1906(a5) # 80008008 <etext+0x8>
    80002782:	02f585bb          	mulw	a1,a1,a5
    80002786:	00359793          	slli	a5,a1,0x3
    8000278a:	95be                	add	a1,a1,a5
    8000278c:	0596                	slli	a1,a1,0x5
    8000278e:	7568                	ld	a0,232(a0)
}
    80002790:	952e                	add	a0,a0,a1
    80002792:	6422                	ld	s0,8(sp)
    80002794:	0141                	addi	sp,sp,16
    80002796:	8082                	ret

0000000080002798 <allockthread>:

struct kthread* allockthread(struct proc *p){
    80002798:	1101                	addi	sp,sp,-32
    8000279a:	ec06                	sd	ra,24(sp)
    8000279c:	e822                	sd	s0,16(sp)
    8000279e:	e426                	sd	s1,8(sp)
    800027a0:	e04a                	sd	s2,0(sp)
    800027a2:	1000                	addi	s0,sp,32
    800027a4:	84aa                	mv	s1,a0
  
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    800027a6:	02850913          	addi	s2,a0,40
    {
      acquire(&kt->t_lock);
    800027aa:	854a                	mv	a0,s2
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	42a080e7          	jalr	1066(ra) # 80000bd6 <acquire>
      if(kt->t_state == UNUSED_t) {
    800027b4:	40bc                	lw	a5,64(s1)
    800027b6:	cf91                	beqz	a5,800027d2 <allockthread+0x3a>
        kt->context.ra = (uint64)forkret;
        kt->context.sp = kt->kstack + PGSIZE;
        return kt;
      } 
      else {
        release(&kt->t_lock);
    800027b8:	854a                	mv	a0,s2
    800027ba:	ffffe097          	auipc	ra,0xffffe
    800027be:	4d0080e7          	jalr	1232(ra) # 80000c8a <release>
      }
  }
  return 0;
    800027c2:	4901                	li	s2,0
}
    800027c4:	854a                	mv	a0,s2
    800027c6:	60e2                	ld	ra,24(sp)
    800027c8:	6442                	ld	s0,16(sp)
    800027ca:	64a2                	ld	s1,8(sp)
    800027cc:	6902                	ld	s2,0(sp)
    800027ce:	6105                	addi	sp,sp,32
    800027d0:	8082                	ret
        kt->tid = alloctid(p);
    800027d2:	8526                	mv	a0,s1
    800027d4:	00000097          	auipc	ra,0x0
    800027d8:	f54080e7          	jalr	-172(ra) # 80002728 <alloctid>
    800027dc:	cca8                	sw	a0,88(s1)
        kt->t_state = USED_t;
    800027de:	4785                	li	a5,1
    800027e0:	c0bc                	sw	a5,64(s1)
        kt->process=p;
    800027e2:	f0a4                	sd	s1,96(s1)
        kt->trapframe = get_kthread_trapframe(p,kt);
    800027e4:	85ca                	mv	a1,s2
    800027e6:	8526                	mv	a0,s1
    800027e8:	00000097          	auipc	ra,0x0
    800027ec:	f84080e7          	jalr	-124(ra) # 8000276c <get_kthread_trapframe>
    800027f0:	f0e8                	sd	a0,224(s1)
        memset(&kt->context, 0, sizeof(kt->context));   
    800027f2:	07000613          	li	a2,112
    800027f6:	4581                	li	a1,0
    800027f8:	06848513          	addi	a0,s1,104
    800027fc:	ffffe097          	auipc	ra,0xffffe
    80002800:	4d6080e7          	jalr	1238(ra) # 80000cd2 <memset>
        kt->context.ra = (uint64)forkret;
    80002804:	00000797          	auipc	a5,0x0
    80002808:	87278793          	addi	a5,a5,-1934 # 80002076 <forkret>
    8000280c:	f4bc                	sd	a5,104(s1)
        kt->context.sp = kt->kstack + PGSIZE;
    8000280e:	6cfc                	ld	a5,216(s1)
    80002810:	6705                	lui	a4,0x1
    80002812:	97ba                	add	a5,a5,a4
    80002814:	f8bc                	sd	a5,112(s1)
        return kt;
    80002816:	b77d                	j	800027c4 <allockthread+0x2c>

0000000080002818 <freethread>:

void
freethread(struct kthread *t){
    80002818:	1101                	addi	sp,sp,-32
    8000281a:	ec06                	sd	ra,24(sp)
    8000281c:	e822                	sd	s0,16(sp)
    8000281e:	e426                	sd	s1,8(sp)
    80002820:	1000                	addi	s0,sp,32
    80002822:	84aa                	mv	s1,a0
  t->chan = 0;
    80002824:	02053023          	sd	zero,32(a0)
  t->t_killed = 0;
    80002828:	02052423          	sw	zero,40(a0)
  t->t_xstate = 0;
    8000282c:	02052623          	sw	zero,44(a0)
  t->t_state = UNUSED_t;
    80002830:	00052c23          	sw	zero,24(a0)
  t->tid=0;
    80002834:	02052823          	sw	zero,48(a0)
  t->process=0;
    80002838:	02053c23          	sd	zero,56(a0)
  t->kstack=0;
    8000283c:	0a053823          	sd	zero,176(a0)
  if(t->trapframe)
    80002840:	7d48                	ld	a0,184(a0)
    80002842:	c509                	beqz	a0,8000284c <freethread+0x34>
    kfree((void*)t->trapframe);
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	1a6080e7          	jalr	422(ra) # 800009ea <kfree>
  t->trapframe = 0;
    8000284c:	0a04bc23          	sd	zero,184(s1)
  memset(&t->context,0,sizeof(&t->context));
    80002850:	4621                	li	a2,8
    80002852:	4581                	li	a1,0
    80002854:	04048513          	addi	a0,s1,64
    80002858:	ffffe097          	auipc	ra,0xffffe
    8000285c:	47a080e7          	jalr	1146(ra) # 80000cd2 <memset>
  release(&t->t_lock);
    80002860:	8526                	mv	a0,s1
    80002862:	ffffe097          	auipc	ra,0xffffe
    80002866:	428080e7          	jalr	1064(ra) # 80000c8a <release>
}
    8000286a:	60e2                	ld	ra,24(sp)
    8000286c:	6442                	ld	s0,16(sp)
    8000286e:	64a2                	ld	s1,8(sp)
    80002870:	6105                	addi	sp,sp,32
    80002872:	8082                	ret

0000000080002874 <swtch>:
    80002874:	00153023          	sd	ra,0(a0)
    80002878:	00253423          	sd	sp,8(a0)
    8000287c:	e900                	sd	s0,16(a0)
    8000287e:	ed04                	sd	s1,24(a0)
    80002880:	03253023          	sd	s2,32(a0)
    80002884:	03353423          	sd	s3,40(a0)
    80002888:	03453823          	sd	s4,48(a0)
    8000288c:	03553c23          	sd	s5,56(a0)
    80002890:	05653023          	sd	s6,64(a0)
    80002894:	05753423          	sd	s7,72(a0)
    80002898:	05853823          	sd	s8,80(a0)
    8000289c:	05953c23          	sd	s9,88(a0)
    800028a0:	07a53023          	sd	s10,96(a0)
    800028a4:	07b53423          	sd	s11,104(a0)
    800028a8:	0005b083          	ld	ra,0(a1)
    800028ac:	0085b103          	ld	sp,8(a1)
    800028b0:	6980                	ld	s0,16(a1)
    800028b2:	6d84                	ld	s1,24(a1)
    800028b4:	0205b903          	ld	s2,32(a1)
    800028b8:	0285b983          	ld	s3,40(a1)
    800028bc:	0305ba03          	ld	s4,48(a1)
    800028c0:	0385ba83          	ld	s5,56(a1)
    800028c4:	0405bb03          	ld	s6,64(a1)
    800028c8:	0485bb83          	ld	s7,72(a1)
    800028cc:	0505bc03          	ld	s8,80(a1)
    800028d0:	0585bc83          	ld	s9,88(a1)
    800028d4:	0605bd03          	ld	s10,96(a1)
    800028d8:	0685bd83          	ld	s11,104(a1)
    800028dc:	8082                	ret

00000000800028de <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028de:	1141                	addi	sp,sp,-16
    800028e0:	e406                	sd	ra,8(sp)
    800028e2:	e022                	sd	s0,0(sp)
    800028e4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028e6:	00006597          	auipc	a1,0x6
    800028ea:	a0258593          	addi	a1,a1,-1534 # 800082e8 <states.0+0x38>
    800028ee:	00015517          	auipc	a0,0x15
    800028f2:	68250513          	addi	a0,a0,1666 # 80017f70 <tickslock>
    800028f6:	ffffe097          	auipc	ra,0xffffe
    800028fa:	250080e7          	jalr	592(ra) # 80000b46 <initlock>
}
    800028fe:	60a2                	ld	ra,8(sp)
    80002900:	6402                	ld	s0,0(sp)
    80002902:	0141                	addi	sp,sp,16
    80002904:	8082                	ret

0000000080002906 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002906:	1141                	addi	sp,sp,-16
    80002908:	e422                	sd	s0,8(sp)
    8000290a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000290c:	00003797          	auipc	a5,0x3
    80002910:	53478793          	addi	a5,a5,1332 # 80005e40 <kernelvec>
    80002914:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002918:	6422                	ld	s0,8(sp)
    8000291a:	0141                	addi	sp,sp,16
    8000291c:	8082                	ret

000000008000291e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000291e:	1101                	addi	sp,sp,-32
    80002920:	ec06                	sd	ra,24(sp)
    80002922:	e822                	sd	s0,16(sp)
    80002924:	e426                	sd	s1,8(sp)
    80002926:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002928:	fffff097          	auipc	ra,0xfffff
    8000292c:	058080e7          	jalr	88(ra) # 80001980 <myproc>
    80002930:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002932:	00000097          	auipc	ra,0x0
    80002936:	dc6080e7          	jalr	-570(ra) # 800026f8 <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000293a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000293e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002940:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002944:	00004617          	auipc	a2,0x4
    80002948:	6bc60613          	addi	a2,a2,1724 # 80007000 <_trampoline>
    8000294c:	00004697          	auipc	a3,0x4
    80002950:	6b468693          	addi	a3,a3,1716 # 80007000 <_trampoline>
    80002954:	8e91                	sub	a3,a3,a2
    80002956:	040007b7          	lui	a5,0x4000
    8000295a:	17fd                	addi	a5,a5,-1
    8000295c:	07b2                	slli	a5,a5,0xc
    8000295e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002960:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    80002964:	7d58                	ld	a4,184(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002966:	180026f3          	csrr	a3,satp
    8000296a:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    8000296c:	7d58                	ld	a4,184(a0)
    8000296e:	7954                	ld	a3,176(a0)
    80002970:	6585                	lui	a1,0x1
    80002972:	96ae                	add	a3,a3,a1
    80002974:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    80002976:	7d58                	ld	a4,184(a0)
    80002978:	00000697          	auipc	a3,0x0
    8000297c:	15e68693          	addi	a3,a3,350 # 80002ad6 <usertrap>
    80002980:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002982:	7d58                	ld	a4,184(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002984:	8692                	mv	a3,tp
    80002986:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002988:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000298c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002990:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002994:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    80002998:	7d58                	ld	a4,184(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000299a:	6f18                	ld	a4,24(a4)
    8000299c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029a0:	1004b583          	ld	a1,256(s1)
    800029a4:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    800029a6:	02848493          	addi	s1,s1,40
    800029aa:	8d05                	sub	a0,a0,s1
    800029ac:	8519                	srai	a0,a0,0x6
    800029ae:	00005717          	auipc	a4,0x5
    800029b2:	65a73703          	ld	a4,1626(a4) # 80008008 <etext+0x8>
    800029b6:	02e50533          	mul	a0,a0,a4
    800029ba:	1502                	slli	a0,a0,0x20
    800029bc:	9101                	srli	a0,a0,0x20
    800029be:	00351693          	slli	a3,a0,0x3
    800029c2:	9536                	add	a0,a0,a3
    800029c4:	0516                	slli	a0,a0,0x5
    800029c6:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800029ca:	00004717          	auipc	a4,0x4
    800029ce:	6ca70713          	addi	a4,a4,1738 # 80007094 <userret>
    800029d2:	8f11                	sub	a4,a4,a2
    800029d4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    800029d6:	577d                	li	a4,-1
    800029d8:	177e                	slli	a4,a4,0x3f
    800029da:	8dd9                	or	a1,a1,a4
    800029dc:	16fd                	addi	a3,a3,-1
    800029de:	06b6                	slli	a3,a3,0xd
    800029e0:	9536                	add	a0,a0,a3
    800029e2:	9782                	jalr	a5
}
    800029e4:	60e2                	ld	ra,24(sp)
    800029e6:	6442                	ld	s0,16(sp)
    800029e8:	64a2                	ld	s1,8(sp)
    800029ea:	6105                	addi	sp,sp,32
    800029ec:	8082                	ret

00000000800029ee <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029ee:	1101                	addi	sp,sp,-32
    800029f0:	ec06                	sd	ra,24(sp)
    800029f2:	e822                	sd	s0,16(sp)
    800029f4:	e426                	sd	s1,8(sp)
    800029f6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029f8:	00015497          	auipc	s1,0x15
    800029fc:	57848493          	addi	s1,s1,1400 # 80017f70 <tickslock>
    80002a00:	8526                	mv	a0,s1
    80002a02:	ffffe097          	auipc	ra,0xffffe
    80002a06:	1d4080e7          	jalr	468(ra) # 80000bd6 <acquire>
  ticks++;
    80002a0a:	00006517          	auipc	a0,0x6
    80002a0e:	ec650513          	addi	a0,a0,-314 # 800088d0 <ticks>
    80002a12:	411c                	lw	a5,0(a0)
    80002a14:	2785                	addiw	a5,a5,1
    80002a16:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a18:	fffff097          	auipc	ra,0xfffff
    80002a1c:	712080e7          	jalr	1810(ra) # 8000212a <wakeup>
  release(&tickslock);
    80002a20:	8526                	mv	a0,s1
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	268080e7          	jalr	616(ra) # 80000c8a <release>
}
    80002a2a:	60e2                	ld	ra,24(sp)
    80002a2c:	6442                	ld	s0,16(sp)
    80002a2e:	64a2                	ld	s1,8(sp)
    80002a30:	6105                	addi	sp,sp,32
    80002a32:	8082                	ret

0000000080002a34 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a34:	1101                	addi	sp,sp,-32
    80002a36:	ec06                	sd	ra,24(sp)
    80002a38:	e822                	sd	s0,16(sp)
    80002a3a:	e426                	sd	s1,8(sp)
    80002a3c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a3e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a42:	00074d63          	bltz	a4,80002a5c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a46:	57fd                	li	a5,-1
    80002a48:	17fe                	slli	a5,a5,0x3f
    80002a4a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a4c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a4e:	06f70363          	beq	a4,a5,80002ab4 <devintr+0x80>
  }
}
    80002a52:	60e2                	ld	ra,24(sp)
    80002a54:	6442                	ld	s0,16(sp)
    80002a56:	64a2                	ld	s1,8(sp)
    80002a58:	6105                	addi	sp,sp,32
    80002a5a:	8082                	ret
     (scause & 0xff) == 9){
    80002a5c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a60:	46a5                	li	a3,9
    80002a62:	fed792e3          	bne	a5,a3,80002a46 <devintr+0x12>
    int irq = plic_claim();
    80002a66:	00003097          	auipc	ra,0x3
    80002a6a:	4e2080e7          	jalr	1250(ra) # 80005f48 <plic_claim>
    80002a6e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a70:	47a9                	li	a5,10
    80002a72:	02f50763          	beq	a0,a5,80002aa0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a76:	4785                	li	a5,1
    80002a78:	02f50963          	beq	a0,a5,80002aaa <devintr+0x76>
    return 1;
    80002a7c:	4505                	li	a0,1
    } else if(irq){
    80002a7e:	d8f1                	beqz	s1,80002a52 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a80:	85a6                	mv	a1,s1
    80002a82:	00006517          	auipc	a0,0x6
    80002a86:	86e50513          	addi	a0,a0,-1938 # 800082f0 <states.0+0x40>
    80002a8a:	ffffe097          	auipc	ra,0xffffe
    80002a8e:	afe080e7          	jalr	-1282(ra) # 80000588 <printf>
      plic_complete(irq);
    80002a92:	8526                	mv	a0,s1
    80002a94:	00003097          	auipc	ra,0x3
    80002a98:	4d8080e7          	jalr	1240(ra) # 80005f6c <plic_complete>
    return 1;
    80002a9c:	4505                	li	a0,1
    80002a9e:	bf55                	j	80002a52 <devintr+0x1e>
      uartintr();
    80002aa0:	ffffe097          	auipc	ra,0xffffe
    80002aa4:	efa080e7          	jalr	-262(ra) # 8000099a <uartintr>
    80002aa8:	b7ed                	j	80002a92 <devintr+0x5e>
      virtio_disk_intr();
    80002aaa:	00004097          	auipc	ra,0x4
    80002aae:	98e080e7          	jalr	-1650(ra) # 80006438 <virtio_disk_intr>
    80002ab2:	b7c5                	j	80002a92 <devintr+0x5e>
    if(cpuid() == 0){
    80002ab4:	fffff097          	auipc	ra,0xfffff
    80002ab8:	ea0080e7          	jalr	-352(ra) # 80001954 <cpuid>
    80002abc:	c901                	beqz	a0,80002acc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002abe:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ac2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ac4:	14479073          	csrw	sip,a5
    return 2;
    80002ac8:	4509                	li	a0,2
    80002aca:	b761                	j	80002a52 <devintr+0x1e>
      clockintr();
    80002acc:	00000097          	auipc	ra,0x0
    80002ad0:	f22080e7          	jalr	-222(ra) # 800029ee <clockintr>
    80002ad4:	b7ed                	j	80002abe <devintr+0x8a>

0000000080002ad6 <usertrap>:
{
    80002ad6:	1101                	addi	sp,sp,-32
    80002ad8:	ec06                	sd	ra,24(sp)
    80002ada:	e822                	sd	s0,16(sp)
    80002adc:	e426                	sd	s1,8(sp)
    80002ade:	e04a                	sd	s2,0(sp)
    80002ae0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ae6:	1007f793          	andi	a5,a5,256
    80002aea:	e7b9                	bnez	a5,80002b38 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aec:	00003797          	auipc	a5,0x3
    80002af0:	35478793          	addi	a5,a5,852 # 80005e40 <kernelvec>
    80002af4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	e88080e7          	jalr	-376(ra) # 80001980 <myproc>
    80002b00:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002b02:	00000097          	auipc	ra,0x0
    80002b06:	bf6080e7          	jalr	-1034(ra) # 800026f8 <mykthread>
    80002b0a:	892a                	mv	s2,a0
  kt->trapframe->epc = r_sepc();
    80002b0c:	7d5c                	ld	a5,184(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b0e:	14102773          	csrr	a4,sepc
    80002b12:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b14:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b18:	47a1                	li	a5,8
    80002b1a:	02f70763          	beq	a4,a5,80002b48 <usertrap+0x72>
  } else if((which_dev = devintr()) != 0){
    80002b1e:	00000097          	auipc	ra,0x0
    80002b22:	f16080e7          	jalr	-234(ra) # 80002a34 <devintr>
    80002b26:	892a                	mv	s2,a0
    80002b28:	c541                	beqz	a0,80002bb0 <usertrap+0xda>
  if(killed(p))
    80002b2a:	8526                	mv	a0,s1
    80002b2c:	00000097          	auipc	ra,0x0
    80002b30:	89c080e7          	jalr	-1892(ra) # 800023c8 <killed>
    80002b34:	c939                	beqz	a0,80002b8a <usertrap+0xb4>
    80002b36:	a0a9                	j	80002b80 <usertrap+0xaa>
    panic("usertrap: not from user mode");
    80002b38:	00005517          	auipc	a0,0x5
    80002b3c:	7d850513          	addi	a0,a0,2008 # 80008310 <states.0+0x60>
    80002b40:	ffffe097          	auipc	ra,0xffffe
    80002b44:	9fe080e7          	jalr	-1538(ra) # 8000053e <panic>
    if(killed(p))
    80002b48:	8526                	mv	a0,s1
    80002b4a:	00000097          	auipc	ra,0x0
    80002b4e:	87e080e7          	jalr	-1922(ra) # 800023c8 <killed>
    80002b52:	e929                	bnez	a0,80002ba4 <usertrap+0xce>
    kt->trapframe->epc += 4;
    80002b54:	0b893703          	ld	a4,184(s2)
    80002b58:	6f1c                	ld	a5,24(a4)
    80002b5a:	0791                	addi	a5,a5,4
    80002b5c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b5e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b62:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b66:	10079073          	csrw	sstatus,a5
    syscall();
    80002b6a:	00000097          	auipc	ra,0x0
    80002b6e:	2d8080e7          	jalr	728(ra) # 80002e42 <syscall>
  if(killed(p))
    80002b72:	8526                	mv	a0,s1
    80002b74:	00000097          	auipc	ra,0x0
    80002b78:	854080e7          	jalr	-1964(ra) # 800023c8 <killed>
    80002b7c:	c911                	beqz	a0,80002b90 <usertrap+0xba>
    80002b7e:	4901                	li	s2,0
    exit(-1);
    80002b80:	557d                	li	a0,-1
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	67e080e7          	jalr	1662(ra) # 80002200 <exit>
  if(which_dev == 2)
    80002b8a:	4789                	li	a5,2
    80002b8c:	04f90f63          	beq	s2,a5,80002bea <usertrap+0x114>
  usertrapret();
    80002b90:	00000097          	auipc	ra,0x0
    80002b94:	d8e080e7          	jalr	-626(ra) # 8000291e <usertrapret>
}
    80002b98:	60e2                	ld	ra,24(sp)
    80002b9a:	6442                	ld	s0,16(sp)
    80002b9c:	64a2                	ld	s1,8(sp)
    80002b9e:	6902                	ld	s2,0(sp)
    80002ba0:	6105                	addi	sp,sp,32
    80002ba2:	8082                	ret
      exit(-1);
    80002ba4:	557d                	li	a0,-1
    80002ba6:	fffff097          	auipc	ra,0xfffff
    80002baa:	65a080e7          	jalr	1626(ra) # 80002200 <exit>
    80002bae:	b75d                	j	80002b54 <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bb4:	50d0                	lw	a2,36(s1)
    80002bb6:	00005517          	auipc	a0,0x5
    80002bba:	77a50513          	addi	a0,a0,1914 # 80008330 <states.0+0x80>
    80002bbe:	ffffe097          	auipc	ra,0xffffe
    80002bc2:	9ca080e7          	jalr	-1590(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bc6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bca:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bce:	00005517          	auipc	a0,0x5
    80002bd2:	79250513          	addi	a0,a0,1938 # 80008360 <states.0+0xb0>
    80002bd6:	ffffe097          	auipc	ra,0xffffe
    80002bda:	9b2080e7          	jalr	-1614(ra) # 80000588 <printf>
    setkilled(p);
    80002bde:	8526                	mv	a0,s1
    80002be0:	fffff097          	auipc	ra,0xfffff
    80002be4:	7bc080e7          	jalr	1980(ra) # 8000239c <setkilled>
    80002be8:	b769                	j	80002b72 <usertrap+0x9c>
    yield();
    80002bea:	fffff097          	auipc	ra,0xfffff
    80002bee:	446080e7          	jalr	1094(ra) # 80002030 <yield>
    80002bf2:	bf79                	j	80002b90 <usertrap+0xba>

0000000080002bf4 <kerneltrap>:
{
    80002bf4:	7179                	addi	sp,sp,-48
    80002bf6:	f406                	sd	ra,40(sp)
    80002bf8:	f022                	sd	s0,32(sp)
    80002bfa:	ec26                	sd	s1,24(sp)
    80002bfc:	e84a                	sd	s2,16(sp)
    80002bfe:	e44e                	sd	s3,8(sp)
    80002c00:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c02:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c06:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c0a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c0e:	1004f793          	andi	a5,s1,256
    80002c12:	cb85                	beqz	a5,80002c42 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c14:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c18:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c1a:	ef85                	bnez	a5,80002c52 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c1c:	00000097          	auipc	ra,0x0
    80002c20:	e18080e7          	jalr	-488(ra) # 80002a34 <devintr>
    80002c24:	cd1d                	beqz	a0,80002c62 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002c26:	4789                	li	a5,2
    80002c28:	06f50a63          	beq	a0,a5,80002c9c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c2c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c30:	10049073          	csrw	sstatus,s1
}
    80002c34:	70a2                	ld	ra,40(sp)
    80002c36:	7402                	ld	s0,32(sp)
    80002c38:	64e2                	ld	s1,24(sp)
    80002c3a:	6942                	ld	s2,16(sp)
    80002c3c:	69a2                	ld	s3,8(sp)
    80002c3e:	6145                	addi	sp,sp,48
    80002c40:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c42:	00005517          	auipc	a0,0x5
    80002c46:	73e50513          	addi	a0,a0,1854 # 80008380 <states.0+0xd0>
    80002c4a:	ffffe097          	auipc	ra,0xffffe
    80002c4e:	8f4080e7          	jalr	-1804(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002c52:	00005517          	auipc	a0,0x5
    80002c56:	75650513          	addi	a0,a0,1878 # 800083a8 <states.0+0xf8>
    80002c5a:	ffffe097          	auipc	ra,0xffffe
    80002c5e:	8e4080e7          	jalr	-1820(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002c62:	85ce                	mv	a1,s3
    80002c64:	00005517          	auipc	a0,0x5
    80002c68:	76450513          	addi	a0,a0,1892 # 800083c8 <states.0+0x118>
    80002c6c:	ffffe097          	auipc	ra,0xffffe
    80002c70:	91c080e7          	jalr	-1764(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c74:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c78:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c7c:	00005517          	auipc	a0,0x5
    80002c80:	75c50513          	addi	a0,a0,1884 # 800083d8 <states.0+0x128>
    80002c84:	ffffe097          	auipc	ra,0xffffe
    80002c88:	904080e7          	jalr	-1788(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002c8c:	00005517          	auipc	a0,0x5
    80002c90:	76450513          	addi	a0,a0,1892 # 800083f0 <states.0+0x140>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	8aa080e7          	jalr	-1878(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	ce4080e7          	jalr	-796(ra) # 80001980 <myproc>
    80002ca4:	d541                	beqz	a0,80002c2c <kerneltrap+0x38>
    80002ca6:	fffff097          	auipc	ra,0xfffff
    80002caa:	cda080e7          	jalr	-806(ra) # 80001980 <myproc>
    80002cae:	4138                	lw	a4,64(a0)
    80002cb0:	4791                	li	a5,4
    80002cb2:	f6f71de3          	bne	a4,a5,80002c2c <kerneltrap+0x38>
    yield();
    80002cb6:	fffff097          	auipc	ra,0xfffff
    80002cba:	37a080e7          	jalr	890(ra) # 80002030 <yield>
    80002cbe:	b7bd                	j	80002c2c <kerneltrap+0x38>

0000000080002cc0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cc0:	1101                	addi	sp,sp,-32
    80002cc2:	ec06                	sd	ra,24(sp)
    80002cc4:	e822                	sd	s0,16(sp)
    80002cc6:	e426                	sd	s1,8(sp)
    80002cc8:	1000                	addi	s0,sp,32
    80002cca:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    80002ccc:	00000097          	auipc	ra,0x0
    80002cd0:	a2c080e7          	jalr	-1492(ra) # 800026f8 <mykthread>
  switch (n) {
    80002cd4:	4795                	li	a5,5
    80002cd6:	0497e163          	bltu	a5,s1,80002d18 <argraw+0x58>
    80002cda:	048a                	slli	s1,s1,0x2
    80002cdc:	00005717          	auipc	a4,0x5
    80002ce0:	74c70713          	addi	a4,a4,1868 # 80008428 <states.0+0x178>
    80002ce4:	94ba                	add	s1,s1,a4
    80002ce6:	409c                	lw	a5,0(s1)
    80002ce8:	97ba                	add	a5,a5,a4
    80002cea:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    80002cec:	7d5c                	ld	a5,184(a0)
    80002cee:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cf0:	60e2                	ld	ra,24(sp)
    80002cf2:	6442                	ld	s0,16(sp)
    80002cf4:	64a2                	ld	s1,8(sp)
    80002cf6:	6105                	addi	sp,sp,32
    80002cf8:	8082                	ret
    return kt->trapframe->a1;
    80002cfa:	7d5c                	ld	a5,184(a0)
    80002cfc:	7fa8                	ld	a0,120(a5)
    80002cfe:	bfcd                	j	80002cf0 <argraw+0x30>
    return kt->trapframe->a2;
    80002d00:	7d5c                	ld	a5,184(a0)
    80002d02:	63c8                	ld	a0,128(a5)
    80002d04:	b7f5                	j	80002cf0 <argraw+0x30>
    return kt->trapframe->a3;
    80002d06:	7d5c                	ld	a5,184(a0)
    80002d08:	67c8                	ld	a0,136(a5)
    80002d0a:	b7dd                	j	80002cf0 <argraw+0x30>
    return kt->trapframe->a4;
    80002d0c:	7d5c                	ld	a5,184(a0)
    80002d0e:	6bc8                	ld	a0,144(a5)
    80002d10:	b7c5                	j	80002cf0 <argraw+0x30>
    return kt->trapframe->a5;
    80002d12:	7d5c                	ld	a5,184(a0)
    80002d14:	6fc8                	ld	a0,152(a5)
    80002d16:	bfe9                	j	80002cf0 <argraw+0x30>
  panic("argraw");
    80002d18:	00005517          	auipc	a0,0x5
    80002d1c:	6e850513          	addi	a0,a0,1768 # 80008400 <states.0+0x150>
    80002d20:	ffffe097          	auipc	ra,0xffffe
    80002d24:	81e080e7          	jalr	-2018(ra) # 8000053e <panic>

0000000080002d28 <fetchaddr>:
{
    80002d28:	1101                	addi	sp,sp,-32
    80002d2a:	ec06                	sd	ra,24(sp)
    80002d2c:	e822                	sd	s0,16(sp)
    80002d2e:	e426                	sd	s1,8(sp)
    80002d30:	e04a                	sd	s2,0(sp)
    80002d32:	1000                	addi	s0,sp,32
    80002d34:	84aa                	mv	s1,a0
    80002d36:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d38:	fffff097          	auipc	ra,0xfffff
    80002d3c:	c48080e7          	jalr	-952(ra) # 80001980 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d40:	7d7c                	ld	a5,248(a0)
    80002d42:	02f4f963          	bgeu	s1,a5,80002d74 <fetchaddr+0x4c>
    80002d46:	00848713          	addi	a4,s1,8
    80002d4a:	02e7e763          	bltu	a5,a4,80002d78 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d4e:	46a1                	li	a3,8
    80002d50:	8626                	mv	a2,s1
    80002d52:	85ca                	mv	a1,s2
    80002d54:	10053503          	ld	a0,256(a0)
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	99c080e7          	jalr	-1636(ra) # 800016f4 <copyin>
    80002d60:	00a03533          	snez	a0,a0
    80002d64:	40a00533          	neg	a0,a0
}
    80002d68:	60e2                	ld	ra,24(sp)
    80002d6a:	6442                	ld	s0,16(sp)
    80002d6c:	64a2                	ld	s1,8(sp)
    80002d6e:	6902                	ld	s2,0(sp)
    80002d70:	6105                	addi	sp,sp,32
    80002d72:	8082                	ret
    return -1;
    80002d74:	557d                	li	a0,-1
    80002d76:	bfcd                	j	80002d68 <fetchaddr+0x40>
    80002d78:	557d                	li	a0,-1
    80002d7a:	b7fd                	j	80002d68 <fetchaddr+0x40>

0000000080002d7c <fetchstr>:
{
    80002d7c:	7179                	addi	sp,sp,-48
    80002d7e:	f406                	sd	ra,40(sp)
    80002d80:	f022                	sd	s0,32(sp)
    80002d82:	ec26                	sd	s1,24(sp)
    80002d84:	e84a                	sd	s2,16(sp)
    80002d86:	e44e                	sd	s3,8(sp)
    80002d88:	1800                	addi	s0,sp,48
    80002d8a:	892a                	mv	s2,a0
    80002d8c:	84ae                	mv	s1,a1
    80002d8e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	bf0080e7          	jalr	-1040(ra) # 80001980 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d98:	86ce                	mv	a3,s3
    80002d9a:	864a                	mv	a2,s2
    80002d9c:	85a6                	mv	a1,s1
    80002d9e:	10053503          	ld	a0,256(a0)
    80002da2:	fffff097          	auipc	ra,0xfffff
    80002da6:	9e0080e7          	jalr	-1568(ra) # 80001782 <copyinstr>
    80002daa:	00054e63          	bltz	a0,80002dc6 <fetchstr+0x4a>
  return strlen(buf);
    80002dae:	8526                	mv	a0,s1
    80002db0:	ffffe097          	auipc	ra,0xffffe
    80002db4:	09e080e7          	jalr	158(ra) # 80000e4e <strlen>
}
    80002db8:	70a2                	ld	ra,40(sp)
    80002dba:	7402                	ld	s0,32(sp)
    80002dbc:	64e2                	ld	s1,24(sp)
    80002dbe:	6942                	ld	s2,16(sp)
    80002dc0:	69a2                	ld	s3,8(sp)
    80002dc2:	6145                	addi	sp,sp,48
    80002dc4:	8082                	ret
    return -1;
    80002dc6:	557d                	li	a0,-1
    80002dc8:	bfc5                	j	80002db8 <fetchstr+0x3c>

0000000080002dca <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	1000                	addi	s0,sp,32
    80002dd4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	eea080e7          	jalr	-278(ra) # 80002cc0 <argraw>
    80002dde:	c088                	sw	a0,0(s1)
}
    80002de0:	60e2                	ld	ra,24(sp)
    80002de2:	6442                	ld	s0,16(sp)
    80002de4:	64a2                	ld	s1,8(sp)
    80002de6:	6105                	addi	sp,sp,32
    80002de8:	8082                	ret

0000000080002dea <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002dea:	1101                	addi	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	e426                	sd	s1,8(sp)
    80002df2:	1000                	addi	s0,sp,32
    80002df4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002df6:	00000097          	auipc	ra,0x0
    80002dfa:	eca080e7          	jalr	-310(ra) # 80002cc0 <argraw>
    80002dfe:	e088                	sd	a0,0(s1)
}
    80002e00:	60e2                	ld	ra,24(sp)
    80002e02:	6442                	ld	s0,16(sp)
    80002e04:	64a2                	ld	s1,8(sp)
    80002e06:	6105                	addi	sp,sp,32
    80002e08:	8082                	ret

0000000080002e0a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e0a:	7179                	addi	sp,sp,-48
    80002e0c:	f406                	sd	ra,40(sp)
    80002e0e:	f022                	sd	s0,32(sp)
    80002e10:	ec26                	sd	s1,24(sp)
    80002e12:	e84a                	sd	s2,16(sp)
    80002e14:	1800                	addi	s0,sp,48
    80002e16:	84ae                	mv	s1,a1
    80002e18:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e1a:	fd840593          	addi	a1,s0,-40
    80002e1e:	00000097          	auipc	ra,0x0
    80002e22:	fcc080e7          	jalr	-52(ra) # 80002dea <argaddr>
  return fetchstr(addr, buf, max);
    80002e26:	864a                	mv	a2,s2
    80002e28:	85a6                	mv	a1,s1
    80002e2a:	fd843503          	ld	a0,-40(s0)
    80002e2e:	00000097          	auipc	ra,0x0
    80002e32:	f4e080e7          	jalr	-178(ra) # 80002d7c <fetchstr>
}
    80002e36:	70a2                	ld	ra,40(sp)
    80002e38:	7402                	ld	s0,32(sp)
    80002e3a:	64e2                	ld	s1,24(sp)
    80002e3c:	6942                	ld	s2,16(sp)
    80002e3e:	6145                	addi	sp,sp,48
    80002e40:	8082                	ret

0000000080002e42 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e42:	7179                	addi	sp,sp,-48
    80002e44:	f406                	sd	ra,40(sp)
    80002e46:	f022                	sd	s0,32(sp)
    80002e48:	ec26                	sd	s1,24(sp)
    80002e4a:	e84a                	sd	s2,16(sp)
    80002e4c:	e44e                	sd	s3,8(sp)
    80002e4e:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002e50:	fffff097          	auipc	ra,0xfffff
    80002e54:	b30080e7          	jalr	-1232(ra) # 80001980 <myproc>
    80002e58:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    80002e5a:	00000097          	auipc	ra,0x0
    80002e5e:	89e080e7          	jalr	-1890(ra) # 800026f8 <mykthread>
    80002e62:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80002e64:	0b853983          	ld	s3,184(a0)
    80002e68:	0a89b783          	ld	a5,168(s3)
    80002e6c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e70:	37fd                	addiw	a5,a5,-1
    80002e72:	4751                	li	a4,20
    80002e74:	00f76f63          	bltu	a4,a5,80002e92 <syscall+0x50>
    80002e78:	00369713          	slli	a4,a3,0x3
    80002e7c:	00005797          	auipc	a5,0x5
    80002e80:	5c478793          	addi	a5,a5,1476 # 80008440 <syscalls>
    80002e84:	97ba                	add	a5,a5,a4
    80002e86:	639c                	ld	a5,0(a5)
    80002e88:	c789                	beqz	a5,80002e92 <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    80002e8a:	9782                	jalr	a5
    80002e8c:	06a9b823          	sd	a0,112(s3)
    80002e90:	a005                	j	80002eb0 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e92:	19090613          	addi	a2,s2,400
    80002e96:	02492583          	lw	a1,36(s2)
    80002e9a:	00005517          	auipc	a0,0x5
    80002e9e:	56e50513          	addi	a0,a0,1390 # 80008408 <states.0+0x158>
    80002ea2:	ffffd097          	auipc	ra,0xffffd
    80002ea6:	6e6080e7          	jalr	1766(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    80002eaa:	7cdc                	ld	a5,184(s1)
    80002eac:	577d                	li	a4,-1
    80002eae:	fbb8                	sd	a4,112(a5)
  }
}
    80002eb0:	70a2                	ld	ra,40(sp)
    80002eb2:	7402                	ld	s0,32(sp)
    80002eb4:	64e2                	ld	s1,24(sp)
    80002eb6:	6942                	ld	s2,16(sp)
    80002eb8:	69a2                	ld	s3,8(sp)
    80002eba:	6145                	addi	sp,sp,48
    80002ebc:	8082                	ret

0000000080002ebe <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ebe:	1101                	addi	sp,sp,-32
    80002ec0:	ec06                	sd	ra,24(sp)
    80002ec2:	e822                	sd	s0,16(sp)
    80002ec4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ec6:	fec40593          	addi	a1,s0,-20
    80002eca:	4501                	li	a0,0
    80002ecc:	00000097          	auipc	ra,0x0
    80002ed0:	efe080e7          	jalr	-258(ra) # 80002dca <argint>
  exit(n);
    80002ed4:	fec42503          	lw	a0,-20(s0)
    80002ed8:	fffff097          	auipc	ra,0xfffff
    80002edc:	328080e7          	jalr	808(ra) # 80002200 <exit>
  return 0;  // not reached
}
    80002ee0:	4501                	li	a0,0
    80002ee2:	60e2                	ld	ra,24(sp)
    80002ee4:	6442                	ld	s0,16(sp)
    80002ee6:	6105                	addi	sp,sp,32
    80002ee8:	8082                	ret

0000000080002eea <sys_getpid>:

uint64
sys_getpid(void)
{
    80002eea:	1141                	addi	sp,sp,-16
    80002eec:	e406                	sd	ra,8(sp)
    80002eee:	e022                	sd	s0,0(sp)
    80002ef0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ef2:	fffff097          	auipc	ra,0xfffff
    80002ef6:	a8e080e7          	jalr	-1394(ra) # 80001980 <myproc>
}
    80002efa:	5148                	lw	a0,36(a0)
    80002efc:	60a2                	ld	ra,8(sp)
    80002efe:	6402                	ld	s0,0(sp)
    80002f00:	0141                	addi	sp,sp,16
    80002f02:	8082                	ret

0000000080002f04 <sys_fork>:

uint64
sys_fork(void)
{
    80002f04:	1141                	addi	sp,sp,-16
    80002f06:	e406                	sd	ra,8(sp)
    80002f08:	e022                	sd	s0,0(sp)
    80002f0a:	0800                	addi	s0,sp,16
  return fork();
    80002f0c:	fffff097          	auipc	ra,0xfffff
    80002f10:	e3a080e7          	jalr	-454(ra) # 80001d46 <fork>
}
    80002f14:	60a2                	ld	ra,8(sp)
    80002f16:	6402                	ld	s0,0(sp)
    80002f18:	0141                	addi	sp,sp,16
    80002f1a:	8082                	ret

0000000080002f1c <sys_wait>:

uint64
sys_wait(void)
{
    80002f1c:	1101                	addi	sp,sp,-32
    80002f1e:	ec06                	sd	ra,24(sp)
    80002f20:	e822                	sd	s0,16(sp)
    80002f22:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f24:	fe840593          	addi	a1,s0,-24
    80002f28:	4501                	li	a0,0
    80002f2a:	00000097          	auipc	ra,0x0
    80002f2e:	ec0080e7          	jalr	-320(ra) # 80002dea <argaddr>
  return wait(p);
    80002f32:	fe843503          	ld	a0,-24(s0)
    80002f36:	fffff097          	auipc	ra,0xfffff
    80002f3a:	4c4080e7          	jalr	1220(ra) # 800023fa <wait>
}
    80002f3e:	60e2                	ld	ra,24(sp)
    80002f40:	6442                	ld	s0,16(sp)
    80002f42:	6105                	addi	sp,sp,32
    80002f44:	8082                	ret

0000000080002f46 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f46:	7179                	addi	sp,sp,-48
    80002f48:	f406                	sd	ra,40(sp)
    80002f4a:	f022                	sd	s0,32(sp)
    80002f4c:	ec26                	sd	s1,24(sp)
    80002f4e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f50:	fdc40593          	addi	a1,s0,-36
    80002f54:	4501                	li	a0,0
    80002f56:	00000097          	auipc	ra,0x0
    80002f5a:	e74080e7          	jalr	-396(ra) # 80002dca <argint>
  addr = myproc()->sz;
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	a22080e7          	jalr	-1502(ra) # 80001980 <myproc>
    80002f66:	7d64                	ld	s1,248(a0)
  if(growproc(n) < 0)
    80002f68:	fdc42503          	lw	a0,-36(s0)
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	d7a080e7          	jalr	-646(ra) # 80001ce6 <growproc>
    80002f74:	00054863          	bltz	a0,80002f84 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f78:	8526                	mv	a0,s1
    80002f7a:	70a2                	ld	ra,40(sp)
    80002f7c:	7402                	ld	s0,32(sp)
    80002f7e:	64e2                	ld	s1,24(sp)
    80002f80:	6145                	addi	sp,sp,48
    80002f82:	8082                	ret
    return -1;
    80002f84:	54fd                	li	s1,-1
    80002f86:	bfcd                	j	80002f78 <sys_sbrk+0x32>

0000000080002f88 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f88:	7139                	addi	sp,sp,-64
    80002f8a:	fc06                	sd	ra,56(sp)
    80002f8c:	f822                	sd	s0,48(sp)
    80002f8e:	f426                	sd	s1,40(sp)
    80002f90:	f04a                	sd	s2,32(sp)
    80002f92:	ec4e                	sd	s3,24(sp)
    80002f94:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f96:	fcc40593          	addi	a1,s0,-52
    80002f9a:	4501                	li	a0,0
    80002f9c:	00000097          	auipc	ra,0x0
    80002fa0:	e2e080e7          	jalr	-466(ra) # 80002dca <argint>
  acquire(&tickslock);
    80002fa4:	00015517          	auipc	a0,0x15
    80002fa8:	fcc50513          	addi	a0,a0,-52 # 80017f70 <tickslock>
    80002fac:	ffffe097          	auipc	ra,0xffffe
    80002fb0:	c2a080e7          	jalr	-982(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002fb4:	00006917          	auipc	s2,0x6
    80002fb8:	91c92903          	lw	s2,-1764(s2) # 800088d0 <ticks>
  while(ticks - ticks0 < n){
    80002fbc:	fcc42783          	lw	a5,-52(s0)
    80002fc0:	cf9d                	beqz	a5,80002ffe <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fc2:	00015997          	auipc	s3,0x15
    80002fc6:	fae98993          	addi	s3,s3,-82 # 80017f70 <tickslock>
    80002fca:	00006497          	auipc	s1,0x6
    80002fce:	90648493          	addi	s1,s1,-1786 # 800088d0 <ticks>
    if(killed(myproc())){
    80002fd2:	fffff097          	auipc	ra,0xfffff
    80002fd6:	9ae080e7          	jalr	-1618(ra) # 80001980 <myproc>
    80002fda:	fffff097          	auipc	ra,0xfffff
    80002fde:	3ee080e7          	jalr	1006(ra) # 800023c8 <killed>
    80002fe2:	ed15                	bnez	a0,8000301e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002fe4:	85ce                	mv	a1,s3
    80002fe6:	8526                	mv	a0,s1
    80002fe8:	fffff097          	auipc	ra,0xfffff
    80002fec:	0d4080e7          	jalr	212(ra) # 800020bc <sleep>
  while(ticks - ticks0 < n){
    80002ff0:	409c                	lw	a5,0(s1)
    80002ff2:	412787bb          	subw	a5,a5,s2
    80002ff6:	fcc42703          	lw	a4,-52(s0)
    80002ffa:	fce7ece3          	bltu	a5,a4,80002fd2 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002ffe:	00015517          	auipc	a0,0x15
    80003002:	f7250513          	addi	a0,a0,-142 # 80017f70 <tickslock>
    80003006:	ffffe097          	auipc	ra,0xffffe
    8000300a:	c84080e7          	jalr	-892(ra) # 80000c8a <release>
  return 0;
    8000300e:	4501                	li	a0,0
}
    80003010:	70e2                	ld	ra,56(sp)
    80003012:	7442                	ld	s0,48(sp)
    80003014:	74a2                	ld	s1,40(sp)
    80003016:	7902                	ld	s2,32(sp)
    80003018:	69e2                	ld	s3,24(sp)
    8000301a:	6121                	addi	sp,sp,64
    8000301c:	8082                	ret
      release(&tickslock);
    8000301e:	00015517          	auipc	a0,0x15
    80003022:	f5250513          	addi	a0,a0,-174 # 80017f70 <tickslock>
    80003026:	ffffe097          	auipc	ra,0xffffe
    8000302a:	c64080e7          	jalr	-924(ra) # 80000c8a <release>
      return -1;
    8000302e:	557d                	li	a0,-1
    80003030:	b7c5                	j	80003010 <sys_sleep+0x88>

0000000080003032 <sys_kill>:

uint64
sys_kill(void)
{
    80003032:	1101                	addi	sp,sp,-32
    80003034:	ec06                	sd	ra,24(sp)
    80003036:	e822                	sd	s0,16(sp)
    80003038:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000303a:	fec40593          	addi	a1,s0,-20
    8000303e:	4501                	li	a0,0
    80003040:	00000097          	auipc	ra,0x0
    80003044:	d8a080e7          	jalr	-630(ra) # 80002dca <argint>
  return kill(pid);
    80003048:	fec42503          	lw	a0,-20(s0)
    8000304c:	fffff097          	auipc	ra,0xfffff
    80003050:	2c6080e7          	jalr	710(ra) # 80002312 <kill>
}
    80003054:	60e2                	ld	ra,24(sp)
    80003056:	6442                	ld	s0,16(sp)
    80003058:	6105                	addi	sp,sp,32
    8000305a:	8082                	ret

000000008000305c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000305c:	1101                	addi	sp,sp,-32
    8000305e:	ec06                	sd	ra,24(sp)
    80003060:	e822                	sd	s0,16(sp)
    80003062:	e426                	sd	s1,8(sp)
    80003064:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003066:	00015517          	auipc	a0,0x15
    8000306a:	f0a50513          	addi	a0,a0,-246 # 80017f70 <tickslock>
    8000306e:	ffffe097          	auipc	ra,0xffffe
    80003072:	b68080e7          	jalr	-1176(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003076:	00006497          	auipc	s1,0x6
    8000307a:	85a4a483          	lw	s1,-1958(s1) # 800088d0 <ticks>
  release(&tickslock);
    8000307e:	00015517          	auipc	a0,0x15
    80003082:	ef250513          	addi	a0,a0,-270 # 80017f70 <tickslock>
    80003086:	ffffe097          	auipc	ra,0xffffe
    8000308a:	c04080e7          	jalr	-1020(ra) # 80000c8a <release>
  return xticks;
}
    8000308e:	02049513          	slli	a0,s1,0x20
    80003092:	9101                	srli	a0,a0,0x20
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	64a2                	ld	s1,8(sp)
    8000309a:	6105                	addi	sp,sp,32
    8000309c:	8082                	ret

000000008000309e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000309e:	7179                	addi	sp,sp,-48
    800030a0:	f406                	sd	ra,40(sp)
    800030a2:	f022                	sd	s0,32(sp)
    800030a4:	ec26                	sd	s1,24(sp)
    800030a6:	e84a                	sd	s2,16(sp)
    800030a8:	e44e                	sd	s3,8(sp)
    800030aa:	e052                	sd	s4,0(sp)
    800030ac:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030ae:	00005597          	auipc	a1,0x5
    800030b2:	44258593          	addi	a1,a1,1090 # 800084f0 <syscalls+0xb0>
    800030b6:	00015517          	auipc	a0,0x15
    800030ba:	ed250513          	addi	a0,a0,-302 # 80017f88 <bcache>
    800030be:	ffffe097          	auipc	ra,0xffffe
    800030c2:	a88080e7          	jalr	-1400(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030c6:	0001d797          	auipc	a5,0x1d
    800030ca:	ec278793          	addi	a5,a5,-318 # 8001ff88 <bcache+0x8000>
    800030ce:	0001d717          	auipc	a4,0x1d
    800030d2:	12270713          	addi	a4,a4,290 # 800201f0 <bcache+0x8268>
    800030d6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030da:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030de:	00015497          	auipc	s1,0x15
    800030e2:	ec248493          	addi	s1,s1,-318 # 80017fa0 <bcache+0x18>
    b->next = bcache.head.next;
    800030e6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030e8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030ea:	00005a17          	auipc	s4,0x5
    800030ee:	40ea0a13          	addi	s4,s4,1038 # 800084f8 <syscalls+0xb8>
    b->next = bcache.head.next;
    800030f2:	2b893783          	ld	a5,696(s2)
    800030f6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030f8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030fc:	85d2                	mv	a1,s4
    800030fe:	01048513          	addi	a0,s1,16
    80003102:	00001097          	auipc	ra,0x1
    80003106:	4c4080e7          	jalr	1220(ra) # 800045c6 <initsleeplock>
    bcache.head.next->prev = b;
    8000310a:	2b893783          	ld	a5,696(s2)
    8000310e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003110:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003114:	45848493          	addi	s1,s1,1112
    80003118:	fd349de3          	bne	s1,s3,800030f2 <binit+0x54>
  }
}
    8000311c:	70a2                	ld	ra,40(sp)
    8000311e:	7402                	ld	s0,32(sp)
    80003120:	64e2                	ld	s1,24(sp)
    80003122:	6942                	ld	s2,16(sp)
    80003124:	69a2                	ld	s3,8(sp)
    80003126:	6a02                	ld	s4,0(sp)
    80003128:	6145                	addi	sp,sp,48
    8000312a:	8082                	ret

000000008000312c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000312c:	7179                	addi	sp,sp,-48
    8000312e:	f406                	sd	ra,40(sp)
    80003130:	f022                	sd	s0,32(sp)
    80003132:	ec26                	sd	s1,24(sp)
    80003134:	e84a                	sd	s2,16(sp)
    80003136:	e44e                	sd	s3,8(sp)
    80003138:	1800                	addi	s0,sp,48
    8000313a:	892a                	mv	s2,a0
    8000313c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000313e:	00015517          	auipc	a0,0x15
    80003142:	e4a50513          	addi	a0,a0,-438 # 80017f88 <bcache>
    80003146:	ffffe097          	auipc	ra,0xffffe
    8000314a:	a90080e7          	jalr	-1392(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000314e:	0001d497          	auipc	s1,0x1d
    80003152:	0f24b483          	ld	s1,242(s1) # 80020240 <bcache+0x82b8>
    80003156:	0001d797          	auipc	a5,0x1d
    8000315a:	09a78793          	addi	a5,a5,154 # 800201f0 <bcache+0x8268>
    8000315e:	02f48f63          	beq	s1,a5,8000319c <bread+0x70>
    80003162:	873e                	mv	a4,a5
    80003164:	a021                	j	8000316c <bread+0x40>
    80003166:	68a4                	ld	s1,80(s1)
    80003168:	02e48a63          	beq	s1,a4,8000319c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000316c:	449c                	lw	a5,8(s1)
    8000316e:	ff279ce3          	bne	a5,s2,80003166 <bread+0x3a>
    80003172:	44dc                	lw	a5,12(s1)
    80003174:	ff3799e3          	bne	a5,s3,80003166 <bread+0x3a>
      b->refcnt++;
    80003178:	40bc                	lw	a5,64(s1)
    8000317a:	2785                	addiw	a5,a5,1
    8000317c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000317e:	00015517          	auipc	a0,0x15
    80003182:	e0a50513          	addi	a0,a0,-502 # 80017f88 <bcache>
    80003186:	ffffe097          	auipc	ra,0xffffe
    8000318a:	b04080e7          	jalr	-1276(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000318e:	01048513          	addi	a0,s1,16
    80003192:	00001097          	auipc	ra,0x1
    80003196:	46e080e7          	jalr	1134(ra) # 80004600 <acquiresleep>
      return b;
    8000319a:	a8b9                	j	800031f8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000319c:	0001d497          	auipc	s1,0x1d
    800031a0:	09c4b483          	ld	s1,156(s1) # 80020238 <bcache+0x82b0>
    800031a4:	0001d797          	auipc	a5,0x1d
    800031a8:	04c78793          	addi	a5,a5,76 # 800201f0 <bcache+0x8268>
    800031ac:	00f48863          	beq	s1,a5,800031bc <bread+0x90>
    800031b0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031b2:	40bc                	lw	a5,64(s1)
    800031b4:	cf81                	beqz	a5,800031cc <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031b6:	64a4                	ld	s1,72(s1)
    800031b8:	fee49de3          	bne	s1,a4,800031b2 <bread+0x86>
  panic("bget: no buffers");
    800031bc:	00005517          	auipc	a0,0x5
    800031c0:	34450513          	addi	a0,a0,836 # 80008500 <syscalls+0xc0>
    800031c4:	ffffd097          	auipc	ra,0xffffd
    800031c8:	37a080e7          	jalr	890(ra) # 8000053e <panic>
      b->dev = dev;
    800031cc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031d0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031d4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031d8:	4785                	li	a5,1
    800031da:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031dc:	00015517          	auipc	a0,0x15
    800031e0:	dac50513          	addi	a0,a0,-596 # 80017f88 <bcache>
    800031e4:	ffffe097          	auipc	ra,0xffffe
    800031e8:	aa6080e7          	jalr	-1370(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031ec:	01048513          	addi	a0,s1,16
    800031f0:	00001097          	auipc	ra,0x1
    800031f4:	410080e7          	jalr	1040(ra) # 80004600 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031f8:	409c                	lw	a5,0(s1)
    800031fa:	cb89                	beqz	a5,8000320c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031fc:	8526                	mv	a0,s1
    800031fe:	70a2                	ld	ra,40(sp)
    80003200:	7402                	ld	s0,32(sp)
    80003202:	64e2                	ld	s1,24(sp)
    80003204:	6942                	ld	s2,16(sp)
    80003206:	69a2                	ld	s3,8(sp)
    80003208:	6145                	addi	sp,sp,48
    8000320a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000320c:	4581                	li	a1,0
    8000320e:	8526                	mv	a0,s1
    80003210:	00003097          	auipc	ra,0x3
    80003214:	ff4080e7          	jalr	-12(ra) # 80006204 <virtio_disk_rw>
    b->valid = 1;
    80003218:	4785                	li	a5,1
    8000321a:	c09c                	sw	a5,0(s1)
  return b;
    8000321c:	b7c5                	j	800031fc <bread+0xd0>

000000008000321e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000321e:	1101                	addi	sp,sp,-32
    80003220:	ec06                	sd	ra,24(sp)
    80003222:	e822                	sd	s0,16(sp)
    80003224:	e426                	sd	s1,8(sp)
    80003226:	1000                	addi	s0,sp,32
    80003228:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000322a:	0541                	addi	a0,a0,16
    8000322c:	00001097          	auipc	ra,0x1
    80003230:	46e080e7          	jalr	1134(ra) # 8000469a <holdingsleep>
    80003234:	cd01                	beqz	a0,8000324c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003236:	4585                	li	a1,1
    80003238:	8526                	mv	a0,s1
    8000323a:	00003097          	auipc	ra,0x3
    8000323e:	fca080e7          	jalr	-54(ra) # 80006204 <virtio_disk_rw>
}
    80003242:	60e2                	ld	ra,24(sp)
    80003244:	6442                	ld	s0,16(sp)
    80003246:	64a2                	ld	s1,8(sp)
    80003248:	6105                	addi	sp,sp,32
    8000324a:	8082                	ret
    panic("bwrite");
    8000324c:	00005517          	auipc	a0,0x5
    80003250:	2cc50513          	addi	a0,a0,716 # 80008518 <syscalls+0xd8>
    80003254:	ffffd097          	auipc	ra,0xffffd
    80003258:	2ea080e7          	jalr	746(ra) # 8000053e <panic>

000000008000325c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000325c:	1101                	addi	sp,sp,-32
    8000325e:	ec06                	sd	ra,24(sp)
    80003260:	e822                	sd	s0,16(sp)
    80003262:	e426                	sd	s1,8(sp)
    80003264:	e04a                	sd	s2,0(sp)
    80003266:	1000                	addi	s0,sp,32
    80003268:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000326a:	01050913          	addi	s2,a0,16
    8000326e:	854a                	mv	a0,s2
    80003270:	00001097          	auipc	ra,0x1
    80003274:	42a080e7          	jalr	1066(ra) # 8000469a <holdingsleep>
    80003278:	c92d                	beqz	a0,800032ea <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000327a:	854a                	mv	a0,s2
    8000327c:	00001097          	auipc	ra,0x1
    80003280:	3da080e7          	jalr	986(ra) # 80004656 <releasesleep>

  acquire(&bcache.lock);
    80003284:	00015517          	auipc	a0,0x15
    80003288:	d0450513          	addi	a0,a0,-764 # 80017f88 <bcache>
    8000328c:	ffffe097          	auipc	ra,0xffffe
    80003290:	94a080e7          	jalr	-1718(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003294:	40bc                	lw	a5,64(s1)
    80003296:	37fd                	addiw	a5,a5,-1
    80003298:	0007871b          	sext.w	a4,a5
    8000329c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000329e:	eb05                	bnez	a4,800032ce <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032a0:	68bc                	ld	a5,80(s1)
    800032a2:	64b8                	ld	a4,72(s1)
    800032a4:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800032a6:	64bc                	ld	a5,72(s1)
    800032a8:	68b8                	ld	a4,80(s1)
    800032aa:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032ac:	0001d797          	auipc	a5,0x1d
    800032b0:	cdc78793          	addi	a5,a5,-804 # 8001ff88 <bcache+0x8000>
    800032b4:	2b87b703          	ld	a4,696(a5)
    800032b8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032ba:	0001d717          	auipc	a4,0x1d
    800032be:	f3670713          	addi	a4,a4,-202 # 800201f0 <bcache+0x8268>
    800032c2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032c4:	2b87b703          	ld	a4,696(a5)
    800032c8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032ca:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032ce:	00015517          	auipc	a0,0x15
    800032d2:	cba50513          	addi	a0,a0,-838 # 80017f88 <bcache>
    800032d6:	ffffe097          	auipc	ra,0xffffe
    800032da:	9b4080e7          	jalr	-1612(ra) # 80000c8a <release>
}
    800032de:	60e2                	ld	ra,24(sp)
    800032e0:	6442                	ld	s0,16(sp)
    800032e2:	64a2                	ld	s1,8(sp)
    800032e4:	6902                	ld	s2,0(sp)
    800032e6:	6105                	addi	sp,sp,32
    800032e8:	8082                	ret
    panic("brelse");
    800032ea:	00005517          	auipc	a0,0x5
    800032ee:	23650513          	addi	a0,a0,566 # 80008520 <syscalls+0xe0>
    800032f2:	ffffd097          	auipc	ra,0xffffd
    800032f6:	24c080e7          	jalr	588(ra) # 8000053e <panic>

00000000800032fa <bpin>:

void
bpin(struct buf *b) {
    800032fa:	1101                	addi	sp,sp,-32
    800032fc:	ec06                	sd	ra,24(sp)
    800032fe:	e822                	sd	s0,16(sp)
    80003300:	e426                	sd	s1,8(sp)
    80003302:	1000                	addi	s0,sp,32
    80003304:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003306:	00015517          	auipc	a0,0x15
    8000330a:	c8250513          	addi	a0,a0,-894 # 80017f88 <bcache>
    8000330e:	ffffe097          	auipc	ra,0xffffe
    80003312:	8c8080e7          	jalr	-1848(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003316:	40bc                	lw	a5,64(s1)
    80003318:	2785                	addiw	a5,a5,1
    8000331a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000331c:	00015517          	auipc	a0,0x15
    80003320:	c6c50513          	addi	a0,a0,-916 # 80017f88 <bcache>
    80003324:	ffffe097          	auipc	ra,0xffffe
    80003328:	966080e7          	jalr	-1690(ra) # 80000c8a <release>
}
    8000332c:	60e2                	ld	ra,24(sp)
    8000332e:	6442                	ld	s0,16(sp)
    80003330:	64a2                	ld	s1,8(sp)
    80003332:	6105                	addi	sp,sp,32
    80003334:	8082                	ret

0000000080003336 <bunpin>:

void
bunpin(struct buf *b) {
    80003336:	1101                	addi	sp,sp,-32
    80003338:	ec06                	sd	ra,24(sp)
    8000333a:	e822                	sd	s0,16(sp)
    8000333c:	e426                	sd	s1,8(sp)
    8000333e:	1000                	addi	s0,sp,32
    80003340:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003342:	00015517          	auipc	a0,0x15
    80003346:	c4650513          	addi	a0,a0,-954 # 80017f88 <bcache>
    8000334a:	ffffe097          	auipc	ra,0xffffe
    8000334e:	88c080e7          	jalr	-1908(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003352:	40bc                	lw	a5,64(s1)
    80003354:	37fd                	addiw	a5,a5,-1
    80003356:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003358:	00015517          	auipc	a0,0x15
    8000335c:	c3050513          	addi	a0,a0,-976 # 80017f88 <bcache>
    80003360:	ffffe097          	auipc	ra,0xffffe
    80003364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
}
    80003368:	60e2                	ld	ra,24(sp)
    8000336a:	6442                	ld	s0,16(sp)
    8000336c:	64a2                	ld	s1,8(sp)
    8000336e:	6105                	addi	sp,sp,32
    80003370:	8082                	ret

0000000080003372 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003372:	1101                	addi	sp,sp,-32
    80003374:	ec06                	sd	ra,24(sp)
    80003376:	e822                	sd	s0,16(sp)
    80003378:	e426                	sd	s1,8(sp)
    8000337a:	e04a                	sd	s2,0(sp)
    8000337c:	1000                	addi	s0,sp,32
    8000337e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003380:	00d5d59b          	srliw	a1,a1,0xd
    80003384:	0001d797          	auipc	a5,0x1d
    80003388:	2e07a783          	lw	a5,736(a5) # 80020664 <sb+0x1c>
    8000338c:	9dbd                	addw	a1,a1,a5
    8000338e:	00000097          	auipc	ra,0x0
    80003392:	d9e080e7          	jalr	-610(ra) # 8000312c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003396:	0074f713          	andi	a4,s1,7
    8000339a:	4785                	li	a5,1
    8000339c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033a0:	14ce                	slli	s1,s1,0x33
    800033a2:	90d9                	srli	s1,s1,0x36
    800033a4:	00950733          	add	a4,a0,s1
    800033a8:	05874703          	lbu	a4,88(a4)
    800033ac:	00e7f6b3          	and	a3,a5,a4
    800033b0:	c69d                	beqz	a3,800033de <bfree+0x6c>
    800033b2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033b4:	94aa                	add	s1,s1,a0
    800033b6:	fff7c793          	not	a5,a5
    800033ba:	8ff9                	and	a5,a5,a4
    800033bc:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800033c0:	00001097          	auipc	ra,0x1
    800033c4:	120080e7          	jalr	288(ra) # 800044e0 <log_write>
  brelse(bp);
    800033c8:	854a                	mv	a0,s2
    800033ca:	00000097          	auipc	ra,0x0
    800033ce:	e92080e7          	jalr	-366(ra) # 8000325c <brelse>
}
    800033d2:	60e2                	ld	ra,24(sp)
    800033d4:	6442                	ld	s0,16(sp)
    800033d6:	64a2                	ld	s1,8(sp)
    800033d8:	6902                	ld	s2,0(sp)
    800033da:	6105                	addi	sp,sp,32
    800033dc:	8082                	ret
    panic("freeing free block");
    800033de:	00005517          	auipc	a0,0x5
    800033e2:	14a50513          	addi	a0,a0,330 # 80008528 <syscalls+0xe8>
    800033e6:	ffffd097          	auipc	ra,0xffffd
    800033ea:	158080e7          	jalr	344(ra) # 8000053e <panic>

00000000800033ee <balloc>:
{
    800033ee:	711d                	addi	sp,sp,-96
    800033f0:	ec86                	sd	ra,88(sp)
    800033f2:	e8a2                	sd	s0,80(sp)
    800033f4:	e4a6                	sd	s1,72(sp)
    800033f6:	e0ca                	sd	s2,64(sp)
    800033f8:	fc4e                	sd	s3,56(sp)
    800033fa:	f852                	sd	s4,48(sp)
    800033fc:	f456                	sd	s5,40(sp)
    800033fe:	f05a                	sd	s6,32(sp)
    80003400:	ec5e                	sd	s7,24(sp)
    80003402:	e862                	sd	s8,16(sp)
    80003404:	e466                	sd	s9,8(sp)
    80003406:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003408:	0001d797          	auipc	a5,0x1d
    8000340c:	2447a783          	lw	a5,580(a5) # 8002064c <sb+0x4>
    80003410:	10078163          	beqz	a5,80003512 <balloc+0x124>
    80003414:	8baa                	mv	s7,a0
    80003416:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003418:	0001db17          	auipc	s6,0x1d
    8000341c:	230b0b13          	addi	s6,s6,560 # 80020648 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003420:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003422:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003424:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003426:	6c89                	lui	s9,0x2
    80003428:	a061                	j	800034b0 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000342a:	974a                	add	a4,a4,s2
    8000342c:	8fd5                	or	a5,a5,a3
    8000342e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003432:	854a                	mv	a0,s2
    80003434:	00001097          	auipc	ra,0x1
    80003438:	0ac080e7          	jalr	172(ra) # 800044e0 <log_write>
        brelse(bp);
    8000343c:	854a                	mv	a0,s2
    8000343e:	00000097          	auipc	ra,0x0
    80003442:	e1e080e7          	jalr	-482(ra) # 8000325c <brelse>
  bp = bread(dev, bno);
    80003446:	85a6                	mv	a1,s1
    80003448:	855e                	mv	a0,s7
    8000344a:	00000097          	auipc	ra,0x0
    8000344e:	ce2080e7          	jalr	-798(ra) # 8000312c <bread>
    80003452:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003454:	40000613          	li	a2,1024
    80003458:	4581                	li	a1,0
    8000345a:	05850513          	addi	a0,a0,88
    8000345e:	ffffe097          	auipc	ra,0xffffe
    80003462:	874080e7          	jalr	-1932(ra) # 80000cd2 <memset>
  log_write(bp);
    80003466:	854a                	mv	a0,s2
    80003468:	00001097          	auipc	ra,0x1
    8000346c:	078080e7          	jalr	120(ra) # 800044e0 <log_write>
  brelse(bp);
    80003470:	854a                	mv	a0,s2
    80003472:	00000097          	auipc	ra,0x0
    80003476:	dea080e7          	jalr	-534(ra) # 8000325c <brelse>
}
    8000347a:	8526                	mv	a0,s1
    8000347c:	60e6                	ld	ra,88(sp)
    8000347e:	6446                	ld	s0,80(sp)
    80003480:	64a6                	ld	s1,72(sp)
    80003482:	6906                	ld	s2,64(sp)
    80003484:	79e2                	ld	s3,56(sp)
    80003486:	7a42                	ld	s4,48(sp)
    80003488:	7aa2                	ld	s5,40(sp)
    8000348a:	7b02                	ld	s6,32(sp)
    8000348c:	6be2                	ld	s7,24(sp)
    8000348e:	6c42                	ld	s8,16(sp)
    80003490:	6ca2                	ld	s9,8(sp)
    80003492:	6125                	addi	sp,sp,96
    80003494:	8082                	ret
    brelse(bp);
    80003496:	854a                	mv	a0,s2
    80003498:	00000097          	auipc	ra,0x0
    8000349c:	dc4080e7          	jalr	-572(ra) # 8000325c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034a0:	015c87bb          	addw	a5,s9,s5
    800034a4:	00078a9b          	sext.w	s5,a5
    800034a8:	004b2703          	lw	a4,4(s6)
    800034ac:	06eaf363          	bgeu	s5,a4,80003512 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800034b0:	41fad79b          	sraiw	a5,s5,0x1f
    800034b4:	0137d79b          	srliw	a5,a5,0x13
    800034b8:	015787bb          	addw	a5,a5,s5
    800034bc:	40d7d79b          	sraiw	a5,a5,0xd
    800034c0:	01cb2583          	lw	a1,28(s6)
    800034c4:	9dbd                	addw	a1,a1,a5
    800034c6:	855e                	mv	a0,s7
    800034c8:	00000097          	auipc	ra,0x0
    800034cc:	c64080e7          	jalr	-924(ra) # 8000312c <bread>
    800034d0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034d2:	004b2503          	lw	a0,4(s6)
    800034d6:	000a849b          	sext.w	s1,s5
    800034da:	8662                	mv	a2,s8
    800034dc:	faa4fde3          	bgeu	s1,a0,80003496 <balloc+0xa8>
      m = 1 << (bi % 8);
    800034e0:	41f6579b          	sraiw	a5,a2,0x1f
    800034e4:	01d7d69b          	srliw	a3,a5,0x1d
    800034e8:	00c6873b          	addw	a4,a3,a2
    800034ec:	00777793          	andi	a5,a4,7
    800034f0:	9f95                	subw	a5,a5,a3
    800034f2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034f6:	4037571b          	sraiw	a4,a4,0x3
    800034fa:	00e906b3          	add	a3,s2,a4
    800034fe:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    80003502:	00d7f5b3          	and	a1,a5,a3
    80003506:	d195                	beqz	a1,8000342a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003508:	2605                	addiw	a2,a2,1
    8000350a:	2485                	addiw	s1,s1,1
    8000350c:	fd4618e3          	bne	a2,s4,800034dc <balloc+0xee>
    80003510:	b759                	j	80003496 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003512:	00005517          	auipc	a0,0x5
    80003516:	02e50513          	addi	a0,a0,46 # 80008540 <syscalls+0x100>
    8000351a:	ffffd097          	auipc	ra,0xffffd
    8000351e:	06e080e7          	jalr	110(ra) # 80000588 <printf>
  return 0;
    80003522:	4481                	li	s1,0
    80003524:	bf99                	j	8000347a <balloc+0x8c>

0000000080003526 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003526:	7179                	addi	sp,sp,-48
    80003528:	f406                	sd	ra,40(sp)
    8000352a:	f022                	sd	s0,32(sp)
    8000352c:	ec26                	sd	s1,24(sp)
    8000352e:	e84a                	sd	s2,16(sp)
    80003530:	e44e                	sd	s3,8(sp)
    80003532:	e052                	sd	s4,0(sp)
    80003534:	1800                	addi	s0,sp,48
    80003536:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003538:	47ad                	li	a5,11
    8000353a:	02b7e763          	bltu	a5,a1,80003568 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000353e:	02059493          	slli	s1,a1,0x20
    80003542:	9081                	srli	s1,s1,0x20
    80003544:	048a                	slli	s1,s1,0x2
    80003546:	94aa                	add	s1,s1,a0
    80003548:	0504a903          	lw	s2,80(s1)
    8000354c:	06091e63          	bnez	s2,800035c8 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003550:	4108                	lw	a0,0(a0)
    80003552:	00000097          	auipc	ra,0x0
    80003556:	e9c080e7          	jalr	-356(ra) # 800033ee <balloc>
    8000355a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000355e:	06090563          	beqz	s2,800035c8 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003562:	0524a823          	sw	s2,80(s1)
    80003566:	a08d                	j	800035c8 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003568:	ff45849b          	addiw	s1,a1,-12
    8000356c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003570:	0ff00793          	li	a5,255
    80003574:	08e7e563          	bltu	a5,a4,800035fe <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003578:	08052903          	lw	s2,128(a0)
    8000357c:	00091d63          	bnez	s2,80003596 <bmap+0x70>
      addr = balloc(ip->dev);
    80003580:	4108                	lw	a0,0(a0)
    80003582:	00000097          	auipc	ra,0x0
    80003586:	e6c080e7          	jalr	-404(ra) # 800033ee <balloc>
    8000358a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000358e:	02090d63          	beqz	s2,800035c8 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003592:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003596:	85ca                	mv	a1,s2
    80003598:	0009a503          	lw	a0,0(s3)
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	b90080e7          	jalr	-1136(ra) # 8000312c <bread>
    800035a4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035a6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035aa:	02049593          	slli	a1,s1,0x20
    800035ae:	9181                	srli	a1,a1,0x20
    800035b0:	058a                	slli	a1,a1,0x2
    800035b2:	00b784b3          	add	s1,a5,a1
    800035b6:	0004a903          	lw	s2,0(s1)
    800035ba:	02090063          	beqz	s2,800035da <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035be:	8552                	mv	a0,s4
    800035c0:	00000097          	auipc	ra,0x0
    800035c4:	c9c080e7          	jalr	-868(ra) # 8000325c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800035c8:	854a                	mv	a0,s2
    800035ca:	70a2                	ld	ra,40(sp)
    800035cc:	7402                	ld	s0,32(sp)
    800035ce:	64e2                	ld	s1,24(sp)
    800035d0:	6942                	ld	s2,16(sp)
    800035d2:	69a2                	ld	s3,8(sp)
    800035d4:	6a02                	ld	s4,0(sp)
    800035d6:	6145                	addi	sp,sp,48
    800035d8:	8082                	ret
      addr = balloc(ip->dev);
    800035da:	0009a503          	lw	a0,0(s3)
    800035de:	00000097          	auipc	ra,0x0
    800035e2:	e10080e7          	jalr	-496(ra) # 800033ee <balloc>
    800035e6:	0005091b          	sext.w	s2,a0
      if(addr){
    800035ea:	fc090ae3          	beqz	s2,800035be <bmap+0x98>
        a[bn] = addr;
    800035ee:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035f2:	8552                	mv	a0,s4
    800035f4:	00001097          	auipc	ra,0x1
    800035f8:	eec080e7          	jalr	-276(ra) # 800044e0 <log_write>
    800035fc:	b7c9                	j	800035be <bmap+0x98>
  panic("bmap: out of range");
    800035fe:	00005517          	auipc	a0,0x5
    80003602:	f5a50513          	addi	a0,a0,-166 # 80008558 <syscalls+0x118>
    80003606:	ffffd097          	auipc	ra,0xffffd
    8000360a:	f38080e7          	jalr	-200(ra) # 8000053e <panic>

000000008000360e <iget>:
{
    8000360e:	7179                	addi	sp,sp,-48
    80003610:	f406                	sd	ra,40(sp)
    80003612:	f022                	sd	s0,32(sp)
    80003614:	ec26                	sd	s1,24(sp)
    80003616:	e84a                	sd	s2,16(sp)
    80003618:	e44e                	sd	s3,8(sp)
    8000361a:	e052                	sd	s4,0(sp)
    8000361c:	1800                	addi	s0,sp,48
    8000361e:	89aa                	mv	s3,a0
    80003620:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003622:	0001d517          	auipc	a0,0x1d
    80003626:	04650513          	addi	a0,a0,70 # 80020668 <itable>
    8000362a:	ffffd097          	auipc	ra,0xffffd
    8000362e:	5ac080e7          	jalr	1452(ra) # 80000bd6 <acquire>
  empty = 0;
    80003632:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003634:	0001d497          	auipc	s1,0x1d
    80003638:	04c48493          	addi	s1,s1,76 # 80020680 <itable+0x18>
    8000363c:	0001f697          	auipc	a3,0x1f
    80003640:	ad468693          	addi	a3,a3,-1324 # 80022110 <log>
    80003644:	a039                	j	80003652 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003646:	02090b63          	beqz	s2,8000367c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000364a:	08848493          	addi	s1,s1,136
    8000364e:	02d48a63          	beq	s1,a3,80003682 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003652:	449c                	lw	a5,8(s1)
    80003654:	fef059e3          	blez	a5,80003646 <iget+0x38>
    80003658:	4098                	lw	a4,0(s1)
    8000365a:	ff3716e3          	bne	a4,s3,80003646 <iget+0x38>
    8000365e:	40d8                	lw	a4,4(s1)
    80003660:	ff4713e3          	bne	a4,s4,80003646 <iget+0x38>
      ip->ref++;
    80003664:	2785                	addiw	a5,a5,1
    80003666:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003668:	0001d517          	auipc	a0,0x1d
    8000366c:	00050513          	mv	a0,a0
    80003670:	ffffd097          	auipc	ra,0xffffd
    80003674:	61a080e7          	jalr	1562(ra) # 80000c8a <release>
      return ip;
    80003678:	8926                	mv	s2,s1
    8000367a:	a03d                	j	800036a8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000367c:	f7f9                	bnez	a5,8000364a <iget+0x3c>
    8000367e:	8926                	mv	s2,s1
    80003680:	b7e9                	j	8000364a <iget+0x3c>
  if(empty == 0)
    80003682:	02090c63          	beqz	s2,800036ba <iget+0xac>
  ip->dev = dev;
    80003686:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000368a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000368e:	4785                	li	a5,1
    80003690:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003694:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003698:	0001d517          	auipc	a0,0x1d
    8000369c:	fd050513          	addi	a0,a0,-48 # 80020668 <itable>
    800036a0:	ffffd097          	auipc	ra,0xffffd
    800036a4:	5ea080e7          	jalr	1514(ra) # 80000c8a <release>
}
    800036a8:	854a                	mv	a0,s2
    800036aa:	70a2                	ld	ra,40(sp)
    800036ac:	7402                	ld	s0,32(sp)
    800036ae:	64e2                	ld	s1,24(sp)
    800036b0:	6942                	ld	s2,16(sp)
    800036b2:	69a2                	ld	s3,8(sp)
    800036b4:	6a02                	ld	s4,0(sp)
    800036b6:	6145                	addi	sp,sp,48
    800036b8:	8082                	ret
    panic("iget: no inodes");
    800036ba:	00005517          	auipc	a0,0x5
    800036be:	eb650513          	addi	a0,a0,-330 # 80008570 <syscalls+0x130>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	e7c080e7          	jalr	-388(ra) # 8000053e <panic>

00000000800036ca <fsinit>:
fsinit(int dev) {
    800036ca:	7179                	addi	sp,sp,-48
    800036cc:	f406                	sd	ra,40(sp)
    800036ce:	f022                	sd	s0,32(sp)
    800036d0:	ec26                	sd	s1,24(sp)
    800036d2:	e84a                	sd	s2,16(sp)
    800036d4:	e44e                	sd	s3,8(sp)
    800036d6:	1800                	addi	s0,sp,48
    800036d8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036da:	4585                	li	a1,1
    800036dc:	00000097          	auipc	ra,0x0
    800036e0:	a50080e7          	jalr	-1456(ra) # 8000312c <bread>
    800036e4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036e6:	0001d997          	auipc	s3,0x1d
    800036ea:	f6298993          	addi	s3,s3,-158 # 80020648 <sb>
    800036ee:	02000613          	li	a2,32
    800036f2:	05850593          	addi	a1,a0,88
    800036f6:	854e                	mv	a0,s3
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	636080e7          	jalr	1590(ra) # 80000d2e <memmove>
  brelse(bp);
    80003700:	8526                	mv	a0,s1
    80003702:	00000097          	auipc	ra,0x0
    80003706:	b5a080e7          	jalr	-1190(ra) # 8000325c <brelse>
  if(sb.magic != FSMAGIC)
    8000370a:	0009a703          	lw	a4,0(s3)
    8000370e:	102037b7          	lui	a5,0x10203
    80003712:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003716:	02f71263          	bne	a4,a5,8000373a <fsinit+0x70>
  initlog(dev, &sb);
    8000371a:	0001d597          	auipc	a1,0x1d
    8000371e:	f2e58593          	addi	a1,a1,-210 # 80020648 <sb>
    80003722:	854a                	mv	a0,s2
    80003724:	00001097          	auipc	ra,0x1
    80003728:	b40080e7          	jalr	-1216(ra) # 80004264 <initlog>
}
    8000372c:	70a2                	ld	ra,40(sp)
    8000372e:	7402                	ld	s0,32(sp)
    80003730:	64e2                	ld	s1,24(sp)
    80003732:	6942                	ld	s2,16(sp)
    80003734:	69a2                	ld	s3,8(sp)
    80003736:	6145                	addi	sp,sp,48
    80003738:	8082                	ret
    panic("invalid file system");
    8000373a:	00005517          	auipc	a0,0x5
    8000373e:	e4650513          	addi	a0,a0,-442 # 80008580 <syscalls+0x140>
    80003742:	ffffd097          	auipc	ra,0xffffd
    80003746:	dfc080e7          	jalr	-516(ra) # 8000053e <panic>

000000008000374a <iinit>:
{
    8000374a:	7179                	addi	sp,sp,-48
    8000374c:	f406                	sd	ra,40(sp)
    8000374e:	f022                	sd	s0,32(sp)
    80003750:	ec26                	sd	s1,24(sp)
    80003752:	e84a                	sd	s2,16(sp)
    80003754:	e44e                	sd	s3,8(sp)
    80003756:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003758:	00005597          	auipc	a1,0x5
    8000375c:	e4058593          	addi	a1,a1,-448 # 80008598 <syscalls+0x158>
    80003760:	0001d517          	auipc	a0,0x1d
    80003764:	f0850513          	addi	a0,a0,-248 # 80020668 <itable>
    80003768:	ffffd097          	auipc	ra,0xffffd
    8000376c:	3de080e7          	jalr	990(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003770:	0001d497          	auipc	s1,0x1d
    80003774:	f2048493          	addi	s1,s1,-224 # 80020690 <itable+0x28>
    80003778:	0001f997          	auipc	s3,0x1f
    8000377c:	9a898993          	addi	s3,s3,-1624 # 80022120 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003780:	00005917          	auipc	s2,0x5
    80003784:	e2090913          	addi	s2,s2,-480 # 800085a0 <syscalls+0x160>
    80003788:	85ca                	mv	a1,s2
    8000378a:	8526                	mv	a0,s1
    8000378c:	00001097          	auipc	ra,0x1
    80003790:	e3a080e7          	jalr	-454(ra) # 800045c6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003794:	08848493          	addi	s1,s1,136
    80003798:	ff3498e3          	bne	s1,s3,80003788 <iinit+0x3e>
}
    8000379c:	70a2                	ld	ra,40(sp)
    8000379e:	7402                	ld	s0,32(sp)
    800037a0:	64e2                	ld	s1,24(sp)
    800037a2:	6942                	ld	s2,16(sp)
    800037a4:	69a2                	ld	s3,8(sp)
    800037a6:	6145                	addi	sp,sp,48
    800037a8:	8082                	ret

00000000800037aa <ialloc>:
{
    800037aa:	715d                	addi	sp,sp,-80
    800037ac:	e486                	sd	ra,72(sp)
    800037ae:	e0a2                	sd	s0,64(sp)
    800037b0:	fc26                	sd	s1,56(sp)
    800037b2:	f84a                	sd	s2,48(sp)
    800037b4:	f44e                	sd	s3,40(sp)
    800037b6:	f052                	sd	s4,32(sp)
    800037b8:	ec56                	sd	s5,24(sp)
    800037ba:	e85a                	sd	s6,16(sp)
    800037bc:	e45e                	sd	s7,8(sp)
    800037be:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037c0:	0001d717          	auipc	a4,0x1d
    800037c4:	e9472703          	lw	a4,-364(a4) # 80020654 <sb+0xc>
    800037c8:	4785                	li	a5,1
    800037ca:	04e7fa63          	bgeu	a5,a4,8000381e <ialloc+0x74>
    800037ce:	8aaa                	mv	s5,a0
    800037d0:	8bae                	mv	s7,a1
    800037d2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037d4:	0001da17          	auipc	s4,0x1d
    800037d8:	e74a0a13          	addi	s4,s4,-396 # 80020648 <sb>
    800037dc:	00048b1b          	sext.w	s6,s1
    800037e0:	0044d793          	srli	a5,s1,0x4
    800037e4:	018a2583          	lw	a1,24(s4)
    800037e8:	9dbd                	addw	a1,a1,a5
    800037ea:	8556                	mv	a0,s5
    800037ec:	00000097          	auipc	ra,0x0
    800037f0:	940080e7          	jalr	-1728(ra) # 8000312c <bread>
    800037f4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037f6:	05850993          	addi	s3,a0,88
    800037fa:	00f4f793          	andi	a5,s1,15
    800037fe:	079a                	slli	a5,a5,0x6
    80003800:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003802:	00099783          	lh	a5,0(s3)
    80003806:	c3a1                	beqz	a5,80003846 <ialloc+0x9c>
    brelse(bp);
    80003808:	00000097          	auipc	ra,0x0
    8000380c:	a54080e7          	jalr	-1452(ra) # 8000325c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003810:	0485                	addi	s1,s1,1
    80003812:	00ca2703          	lw	a4,12(s4)
    80003816:	0004879b          	sext.w	a5,s1
    8000381a:	fce7e1e3          	bltu	a5,a4,800037dc <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000381e:	00005517          	auipc	a0,0x5
    80003822:	d8a50513          	addi	a0,a0,-630 # 800085a8 <syscalls+0x168>
    80003826:	ffffd097          	auipc	ra,0xffffd
    8000382a:	d62080e7          	jalr	-670(ra) # 80000588 <printf>
  return 0;
    8000382e:	4501                	li	a0,0
}
    80003830:	60a6                	ld	ra,72(sp)
    80003832:	6406                	ld	s0,64(sp)
    80003834:	74e2                	ld	s1,56(sp)
    80003836:	7942                	ld	s2,48(sp)
    80003838:	79a2                	ld	s3,40(sp)
    8000383a:	7a02                	ld	s4,32(sp)
    8000383c:	6ae2                	ld	s5,24(sp)
    8000383e:	6b42                	ld	s6,16(sp)
    80003840:	6ba2                	ld	s7,8(sp)
    80003842:	6161                	addi	sp,sp,80
    80003844:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003846:	04000613          	li	a2,64
    8000384a:	4581                	li	a1,0
    8000384c:	854e                	mv	a0,s3
    8000384e:	ffffd097          	auipc	ra,0xffffd
    80003852:	484080e7          	jalr	1156(ra) # 80000cd2 <memset>
      dip->type = type;
    80003856:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000385a:	854a                	mv	a0,s2
    8000385c:	00001097          	auipc	ra,0x1
    80003860:	c84080e7          	jalr	-892(ra) # 800044e0 <log_write>
      brelse(bp);
    80003864:	854a                	mv	a0,s2
    80003866:	00000097          	auipc	ra,0x0
    8000386a:	9f6080e7          	jalr	-1546(ra) # 8000325c <brelse>
      return iget(dev, inum);
    8000386e:	85da                	mv	a1,s6
    80003870:	8556                	mv	a0,s5
    80003872:	00000097          	auipc	ra,0x0
    80003876:	d9c080e7          	jalr	-612(ra) # 8000360e <iget>
    8000387a:	bf5d                	j	80003830 <ialloc+0x86>

000000008000387c <iupdate>:
{
    8000387c:	1101                	addi	sp,sp,-32
    8000387e:	ec06                	sd	ra,24(sp)
    80003880:	e822                	sd	s0,16(sp)
    80003882:	e426                	sd	s1,8(sp)
    80003884:	e04a                	sd	s2,0(sp)
    80003886:	1000                	addi	s0,sp,32
    80003888:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000388a:	415c                	lw	a5,4(a0)
    8000388c:	0047d79b          	srliw	a5,a5,0x4
    80003890:	0001d597          	auipc	a1,0x1d
    80003894:	dd05a583          	lw	a1,-560(a1) # 80020660 <sb+0x18>
    80003898:	9dbd                	addw	a1,a1,a5
    8000389a:	4108                	lw	a0,0(a0)
    8000389c:	00000097          	auipc	ra,0x0
    800038a0:	890080e7          	jalr	-1904(ra) # 8000312c <bread>
    800038a4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038a6:	05850793          	addi	a5,a0,88
    800038aa:	40c8                	lw	a0,4(s1)
    800038ac:	893d                	andi	a0,a0,15
    800038ae:	051a                	slli	a0,a0,0x6
    800038b0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800038b2:	04449703          	lh	a4,68(s1)
    800038b6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038ba:	04649703          	lh	a4,70(s1)
    800038be:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038c2:	04849703          	lh	a4,72(s1)
    800038c6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038ca:	04a49703          	lh	a4,74(s1)
    800038ce:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038d2:	44f8                	lw	a4,76(s1)
    800038d4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038d6:	03400613          	li	a2,52
    800038da:	05048593          	addi	a1,s1,80
    800038de:	0531                	addi	a0,a0,12
    800038e0:	ffffd097          	auipc	ra,0xffffd
    800038e4:	44e080e7          	jalr	1102(ra) # 80000d2e <memmove>
  log_write(bp);
    800038e8:	854a                	mv	a0,s2
    800038ea:	00001097          	auipc	ra,0x1
    800038ee:	bf6080e7          	jalr	-1034(ra) # 800044e0 <log_write>
  brelse(bp);
    800038f2:	854a                	mv	a0,s2
    800038f4:	00000097          	auipc	ra,0x0
    800038f8:	968080e7          	jalr	-1688(ra) # 8000325c <brelse>
}
    800038fc:	60e2                	ld	ra,24(sp)
    800038fe:	6442                	ld	s0,16(sp)
    80003900:	64a2                	ld	s1,8(sp)
    80003902:	6902                	ld	s2,0(sp)
    80003904:	6105                	addi	sp,sp,32
    80003906:	8082                	ret

0000000080003908 <idup>:
{
    80003908:	1101                	addi	sp,sp,-32
    8000390a:	ec06                	sd	ra,24(sp)
    8000390c:	e822                	sd	s0,16(sp)
    8000390e:	e426                	sd	s1,8(sp)
    80003910:	1000                	addi	s0,sp,32
    80003912:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003914:	0001d517          	auipc	a0,0x1d
    80003918:	d5450513          	addi	a0,a0,-684 # 80020668 <itable>
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	2ba080e7          	jalr	698(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003924:	449c                	lw	a5,8(s1)
    80003926:	2785                	addiw	a5,a5,1
    80003928:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000392a:	0001d517          	auipc	a0,0x1d
    8000392e:	d3e50513          	addi	a0,a0,-706 # 80020668 <itable>
    80003932:	ffffd097          	auipc	ra,0xffffd
    80003936:	358080e7          	jalr	856(ra) # 80000c8a <release>
}
    8000393a:	8526                	mv	a0,s1
    8000393c:	60e2                	ld	ra,24(sp)
    8000393e:	6442                	ld	s0,16(sp)
    80003940:	64a2                	ld	s1,8(sp)
    80003942:	6105                	addi	sp,sp,32
    80003944:	8082                	ret

0000000080003946 <ilock>:
{
    80003946:	1101                	addi	sp,sp,-32
    80003948:	ec06                	sd	ra,24(sp)
    8000394a:	e822                	sd	s0,16(sp)
    8000394c:	e426                	sd	s1,8(sp)
    8000394e:	e04a                	sd	s2,0(sp)
    80003950:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003952:	c115                	beqz	a0,80003976 <ilock+0x30>
    80003954:	84aa                	mv	s1,a0
    80003956:	451c                	lw	a5,8(a0)
    80003958:	00f05f63          	blez	a5,80003976 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000395c:	0541                	addi	a0,a0,16
    8000395e:	00001097          	auipc	ra,0x1
    80003962:	ca2080e7          	jalr	-862(ra) # 80004600 <acquiresleep>
  if(ip->valid == 0){
    80003966:	40bc                	lw	a5,64(s1)
    80003968:	cf99                	beqz	a5,80003986 <ilock+0x40>
}
    8000396a:	60e2                	ld	ra,24(sp)
    8000396c:	6442                	ld	s0,16(sp)
    8000396e:	64a2                	ld	s1,8(sp)
    80003970:	6902                	ld	s2,0(sp)
    80003972:	6105                	addi	sp,sp,32
    80003974:	8082                	ret
    panic("ilock");
    80003976:	00005517          	auipc	a0,0x5
    8000397a:	c4a50513          	addi	a0,a0,-950 # 800085c0 <syscalls+0x180>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	bc0080e7          	jalr	-1088(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003986:	40dc                	lw	a5,4(s1)
    80003988:	0047d79b          	srliw	a5,a5,0x4
    8000398c:	0001d597          	auipc	a1,0x1d
    80003990:	cd45a583          	lw	a1,-812(a1) # 80020660 <sb+0x18>
    80003994:	9dbd                	addw	a1,a1,a5
    80003996:	4088                	lw	a0,0(s1)
    80003998:	fffff097          	auipc	ra,0xfffff
    8000399c:	794080e7          	jalr	1940(ra) # 8000312c <bread>
    800039a0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039a2:	05850593          	addi	a1,a0,88
    800039a6:	40dc                	lw	a5,4(s1)
    800039a8:	8bbd                	andi	a5,a5,15
    800039aa:	079a                	slli	a5,a5,0x6
    800039ac:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039ae:	00059783          	lh	a5,0(a1)
    800039b2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039b6:	00259783          	lh	a5,2(a1)
    800039ba:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039be:	00459783          	lh	a5,4(a1)
    800039c2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039c6:	00659783          	lh	a5,6(a1)
    800039ca:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039ce:	459c                	lw	a5,8(a1)
    800039d0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039d2:	03400613          	li	a2,52
    800039d6:	05b1                	addi	a1,a1,12
    800039d8:	05048513          	addi	a0,s1,80
    800039dc:	ffffd097          	auipc	ra,0xffffd
    800039e0:	352080e7          	jalr	850(ra) # 80000d2e <memmove>
    brelse(bp);
    800039e4:	854a                	mv	a0,s2
    800039e6:	00000097          	auipc	ra,0x0
    800039ea:	876080e7          	jalr	-1930(ra) # 8000325c <brelse>
    ip->valid = 1;
    800039ee:	4785                	li	a5,1
    800039f0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039f2:	04449783          	lh	a5,68(s1)
    800039f6:	fbb5                	bnez	a5,8000396a <ilock+0x24>
      panic("ilock: no type");
    800039f8:	00005517          	auipc	a0,0x5
    800039fc:	bd050513          	addi	a0,a0,-1072 # 800085c8 <syscalls+0x188>
    80003a00:	ffffd097          	auipc	ra,0xffffd
    80003a04:	b3e080e7          	jalr	-1218(ra) # 8000053e <panic>

0000000080003a08 <iunlock>:
{
    80003a08:	1101                	addi	sp,sp,-32
    80003a0a:	ec06                	sd	ra,24(sp)
    80003a0c:	e822                	sd	s0,16(sp)
    80003a0e:	e426                	sd	s1,8(sp)
    80003a10:	e04a                	sd	s2,0(sp)
    80003a12:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a14:	c905                	beqz	a0,80003a44 <iunlock+0x3c>
    80003a16:	84aa                	mv	s1,a0
    80003a18:	01050913          	addi	s2,a0,16
    80003a1c:	854a                	mv	a0,s2
    80003a1e:	00001097          	auipc	ra,0x1
    80003a22:	c7c080e7          	jalr	-900(ra) # 8000469a <holdingsleep>
    80003a26:	cd19                	beqz	a0,80003a44 <iunlock+0x3c>
    80003a28:	449c                	lw	a5,8(s1)
    80003a2a:	00f05d63          	blez	a5,80003a44 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a2e:	854a                	mv	a0,s2
    80003a30:	00001097          	auipc	ra,0x1
    80003a34:	c26080e7          	jalr	-986(ra) # 80004656 <releasesleep>
}
    80003a38:	60e2                	ld	ra,24(sp)
    80003a3a:	6442                	ld	s0,16(sp)
    80003a3c:	64a2                	ld	s1,8(sp)
    80003a3e:	6902                	ld	s2,0(sp)
    80003a40:	6105                	addi	sp,sp,32
    80003a42:	8082                	ret
    panic("iunlock");
    80003a44:	00005517          	auipc	a0,0x5
    80003a48:	b9450513          	addi	a0,a0,-1132 # 800085d8 <syscalls+0x198>
    80003a4c:	ffffd097          	auipc	ra,0xffffd
    80003a50:	af2080e7          	jalr	-1294(ra) # 8000053e <panic>

0000000080003a54 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a54:	7179                	addi	sp,sp,-48
    80003a56:	f406                	sd	ra,40(sp)
    80003a58:	f022                	sd	s0,32(sp)
    80003a5a:	ec26                	sd	s1,24(sp)
    80003a5c:	e84a                	sd	s2,16(sp)
    80003a5e:	e44e                	sd	s3,8(sp)
    80003a60:	e052                	sd	s4,0(sp)
    80003a62:	1800                	addi	s0,sp,48
    80003a64:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a66:	05050493          	addi	s1,a0,80
    80003a6a:	08050913          	addi	s2,a0,128
    80003a6e:	a021                	j	80003a76 <itrunc+0x22>
    80003a70:	0491                	addi	s1,s1,4
    80003a72:	01248d63          	beq	s1,s2,80003a8c <itrunc+0x38>
    if(ip->addrs[i]){
    80003a76:	408c                	lw	a1,0(s1)
    80003a78:	dde5                	beqz	a1,80003a70 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a7a:	0009a503          	lw	a0,0(s3)
    80003a7e:	00000097          	auipc	ra,0x0
    80003a82:	8f4080e7          	jalr	-1804(ra) # 80003372 <bfree>
      ip->addrs[i] = 0;
    80003a86:	0004a023          	sw	zero,0(s1)
    80003a8a:	b7dd                	j	80003a70 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a8c:	0809a583          	lw	a1,128(s3)
    80003a90:	e185                	bnez	a1,80003ab0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a92:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a96:	854e                	mv	a0,s3
    80003a98:	00000097          	auipc	ra,0x0
    80003a9c:	de4080e7          	jalr	-540(ra) # 8000387c <iupdate>
}
    80003aa0:	70a2                	ld	ra,40(sp)
    80003aa2:	7402                	ld	s0,32(sp)
    80003aa4:	64e2                	ld	s1,24(sp)
    80003aa6:	6942                	ld	s2,16(sp)
    80003aa8:	69a2                	ld	s3,8(sp)
    80003aaa:	6a02                	ld	s4,0(sp)
    80003aac:	6145                	addi	sp,sp,48
    80003aae:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ab0:	0009a503          	lw	a0,0(s3)
    80003ab4:	fffff097          	auipc	ra,0xfffff
    80003ab8:	678080e7          	jalr	1656(ra) # 8000312c <bread>
    80003abc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003abe:	05850493          	addi	s1,a0,88
    80003ac2:	45850913          	addi	s2,a0,1112
    80003ac6:	a021                	j	80003ace <itrunc+0x7a>
    80003ac8:	0491                	addi	s1,s1,4
    80003aca:	01248b63          	beq	s1,s2,80003ae0 <itrunc+0x8c>
      if(a[j])
    80003ace:	408c                	lw	a1,0(s1)
    80003ad0:	dde5                	beqz	a1,80003ac8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003ad2:	0009a503          	lw	a0,0(s3)
    80003ad6:	00000097          	auipc	ra,0x0
    80003ada:	89c080e7          	jalr	-1892(ra) # 80003372 <bfree>
    80003ade:	b7ed                	j	80003ac8 <itrunc+0x74>
    brelse(bp);
    80003ae0:	8552                	mv	a0,s4
    80003ae2:	fffff097          	auipc	ra,0xfffff
    80003ae6:	77a080e7          	jalr	1914(ra) # 8000325c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003aea:	0809a583          	lw	a1,128(s3)
    80003aee:	0009a503          	lw	a0,0(s3)
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	880080e7          	jalr	-1920(ra) # 80003372 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003afa:	0809a023          	sw	zero,128(s3)
    80003afe:	bf51                	j	80003a92 <itrunc+0x3e>

0000000080003b00 <iput>:
{
    80003b00:	1101                	addi	sp,sp,-32
    80003b02:	ec06                	sd	ra,24(sp)
    80003b04:	e822                	sd	s0,16(sp)
    80003b06:	e426                	sd	s1,8(sp)
    80003b08:	e04a                	sd	s2,0(sp)
    80003b0a:	1000                	addi	s0,sp,32
    80003b0c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b0e:	0001d517          	auipc	a0,0x1d
    80003b12:	b5a50513          	addi	a0,a0,-1190 # 80020668 <itable>
    80003b16:	ffffd097          	auipc	ra,0xffffd
    80003b1a:	0c0080e7          	jalr	192(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b1e:	4498                	lw	a4,8(s1)
    80003b20:	4785                	li	a5,1
    80003b22:	02f70363          	beq	a4,a5,80003b48 <iput+0x48>
  ip->ref--;
    80003b26:	449c                	lw	a5,8(s1)
    80003b28:	37fd                	addiw	a5,a5,-1
    80003b2a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b2c:	0001d517          	auipc	a0,0x1d
    80003b30:	b3c50513          	addi	a0,a0,-1220 # 80020668 <itable>
    80003b34:	ffffd097          	auipc	ra,0xffffd
    80003b38:	156080e7          	jalr	342(ra) # 80000c8a <release>
}
    80003b3c:	60e2                	ld	ra,24(sp)
    80003b3e:	6442                	ld	s0,16(sp)
    80003b40:	64a2                	ld	s1,8(sp)
    80003b42:	6902                	ld	s2,0(sp)
    80003b44:	6105                	addi	sp,sp,32
    80003b46:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b48:	40bc                	lw	a5,64(s1)
    80003b4a:	dff1                	beqz	a5,80003b26 <iput+0x26>
    80003b4c:	04a49783          	lh	a5,74(s1)
    80003b50:	fbf9                	bnez	a5,80003b26 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b52:	01048913          	addi	s2,s1,16
    80003b56:	854a                	mv	a0,s2
    80003b58:	00001097          	auipc	ra,0x1
    80003b5c:	aa8080e7          	jalr	-1368(ra) # 80004600 <acquiresleep>
    release(&itable.lock);
    80003b60:	0001d517          	auipc	a0,0x1d
    80003b64:	b0850513          	addi	a0,a0,-1272 # 80020668 <itable>
    80003b68:	ffffd097          	auipc	ra,0xffffd
    80003b6c:	122080e7          	jalr	290(ra) # 80000c8a <release>
    itrunc(ip);
    80003b70:	8526                	mv	a0,s1
    80003b72:	00000097          	auipc	ra,0x0
    80003b76:	ee2080e7          	jalr	-286(ra) # 80003a54 <itrunc>
    ip->type = 0;
    80003b7a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b7e:	8526                	mv	a0,s1
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	cfc080e7          	jalr	-772(ra) # 8000387c <iupdate>
    ip->valid = 0;
    80003b88:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b8c:	854a                	mv	a0,s2
    80003b8e:	00001097          	auipc	ra,0x1
    80003b92:	ac8080e7          	jalr	-1336(ra) # 80004656 <releasesleep>
    acquire(&itable.lock);
    80003b96:	0001d517          	auipc	a0,0x1d
    80003b9a:	ad250513          	addi	a0,a0,-1326 # 80020668 <itable>
    80003b9e:	ffffd097          	auipc	ra,0xffffd
    80003ba2:	038080e7          	jalr	56(ra) # 80000bd6 <acquire>
    80003ba6:	b741                	j	80003b26 <iput+0x26>

0000000080003ba8 <iunlockput>:
{
    80003ba8:	1101                	addi	sp,sp,-32
    80003baa:	ec06                	sd	ra,24(sp)
    80003bac:	e822                	sd	s0,16(sp)
    80003bae:	e426                	sd	s1,8(sp)
    80003bb0:	1000                	addi	s0,sp,32
    80003bb2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bb4:	00000097          	auipc	ra,0x0
    80003bb8:	e54080e7          	jalr	-428(ra) # 80003a08 <iunlock>
  iput(ip);
    80003bbc:	8526                	mv	a0,s1
    80003bbe:	00000097          	auipc	ra,0x0
    80003bc2:	f42080e7          	jalr	-190(ra) # 80003b00 <iput>
}
    80003bc6:	60e2                	ld	ra,24(sp)
    80003bc8:	6442                	ld	s0,16(sp)
    80003bca:	64a2                	ld	s1,8(sp)
    80003bcc:	6105                	addi	sp,sp,32
    80003bce:	8082                	ret

0000000080003bd0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bd0:	1141                	addi	sp,sp,-16
    80003bd2:	e422                	sd	s0,8(sp)
    80003bd4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bd6:	411c                	lw	a5,0(a0)
    80003bd8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bda:	415c                	lw	a5,4(a0)
    80003bdc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bde:	04451783          	lh	a5,68(a0)
    80003be2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003be6:	04a51783          	lh	a5,74(a0)
    80003bea:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bee:	04c56783          	lwu	a5,76(a0)
    80003bf2:	e99c                	sd	a5,16(a1)
}
    80003bf4:	6422                	ld	s0,8(sp)
    80003bf6:	0141                	addi	sp,sp,16
    80003bf8:	8082                	ret

0000000080003bfa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bfa:	457c                	lw	a5,76(a0)
    80003bfc:	0ed7e963          	bltu	a5,a3,80003cee <readi+0xf4>
{
    80003c00:	7159                	addi	sp,sp,-112
    80003c02:	f486                	sd	ra,104(sp)
    80003c04:	f0a2                	sd	s0,96(sp)
    80003c06:	eca6                	sd	s1,88(sp)
    80003c08:	e8ca                	sd	s2,80(sp)
    80003c0a:	e4ce                	sd	s3,72(sp)
    80003c0c:	e0d2                	sd	s4,64(sp)
    80003c0e:	fc56                	sd	s5,56(sp)
    80003c10:	f85a                	sd	s6,48(sp)
    80003c12:	f45e                	sd	s7,40(sp)
    80003c14:	f062                	sd	s8,32(sp)
    80003c16:	ec66                	sd	s9,24(sp)
    80003c18:	e86a                	sd	s10,16(sp)
    80003c1a:	e46e                	sd	s11,8(sp)
    80003c1c:	1880                	addi	s0,sp,112
    80003c1e:	8b2a                	mv	s6,a0
    80003c20:	8bae                	mv	s7,a1
    80003c22:	8a32                	mv	s4,a2
    80003c24:	84b6                	mv	s1,a3
    80003c26:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c28:	9f35                	addw	a4,a4,a3
    return 0;
    80003c2a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c2c:	0ad76063          	bltu	a4,a3,80003ccc <readi+0xd2>
  if(off + n > ip->size)
    80003c30:	00e7f463          	bgeu	a5,a4,80003c38 <readi+0x3e>
    n = ip->size - off;
    80003c34:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c38:	0a0a8963          	beqz	s5,80003cea <readi+0xf0>
    80003c3c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c3e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c42:	5c7d                	li	s8,-1
    80003c44:	a82d                	j	80003c7e <readi+0x84>
    80003c46:	020d1d93          	slli	s11,s10,0x20
    80003c4a:	020ddd93          	srli	s11,s11,0x20
    80003c4e:	05890793          	addi	a5,s2,88
    80003c52:	86ee                	mv	a3,s11
    80003c54:	963e                	add	a2,a2,a5
    80003c56:	85d2                	mv	a1,s4
    80003c58:	855e                	mv	a0,s7
    80003c5a:	fffff097          	auipc	ra,0xfffff
    80003c5e:	8ce080e7          	jalr	-1842(ra) # 80002528 <either_copyout>
    80003c62:	05850d63          	beq	a0,s8,80003cbc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c66:	854a                	mv	a0,s2
    80003c68:	fffff097          	auipc	ra,0xfffff
    80003c6c:	5f4080e7          	jalr	1524(ra) # 8000325c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c70:	013d09bb          	addw	s3,s10,s3
    80003c74:	009d04bb          	addw	s1,s10,s1
    80003c78:	9a6e                	add	s4,s4,s11
    80003c7a:	0559f763          	bgeu	s3,s5,80003cc8 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c7e:	00a4d59b          	srliw	a1,s1,0xa
    80003c82:	855a                	mv	a0,s6
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	8a2080e7          	jalr	-1886(ra) # 80003526 <bmap>
    80003c8c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c90:	cd85                	beqz	a1,80003cc8 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c92:	000b2503          	lw	a0,0(s6)
    80003c96:	fffff097          	auipc	ra,0xfffff
    80003c9a:	496080e7          	jalr	1174(ra) # 8000312c <bread>
    80003c9e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ca0:	3ff4f613          	andi	a2,s1,1023
    80003ca4:	40cc87bb          	subw	a5,s9,a2
    80003ca8:	413a873b          	subw	a4,s5,s3
    80003cac:	8d3e                	mv	s10,a5
    80003cae:	2781                	sext.w	a5,a5
    80003cb0:	0007069b          	sext.w	a3,a4
    80003cb4:	f8f6f9e3          	bgeu	a3,a5,80003c46 <readi+0x4c>
    80003cb8:	8d3a                	mv	s10,a4
    80003cba:	b771                	j	80003c46 <readi+0x4c>
      brelse(bp);
    80003cbc:	854a                	mv	a0,s2
    80003cbe:	fffff097          	auipc	ra,0xfffff
    80003cc2:	59e080e7          	jalr	1438(ra) # 8000325c <brelse>
      tot = -1;
    80003cc6:	59fd                	li	s3,-1
  }
  return tot;
    80003cc8:	0009851b          	sext.w	a0,s3
}
    80003ccc:	70a6                	ld	ra,104(sp)
    80003cce:	7406                	ld	s0,96(sp)
    80003cd0:	64e6                	ld	s1,88(sp)
    80003cd2:	6946                	ld	s2,80(sp)
    80003cd4:	69a6                	ld	s3,72(sp)
    80003cd6:	6a06                	ld	s4,64(sp)
    80003cd8:	7ae2                	ld	s5,56(sp)
    80003cda:	7b42                	ld	s6,48(sp)
    80003cdc:	7ba2                	ld	s7,40(sp)
    80003cde:	7c02                	ld	s8,32(sp)
    80003ce0:	6ce2                	ld	s9,24(sp)
    80003ce2:	6d42                	ld	s10,16(sp)
    80003ce4:	6da2                	ld	s11,8(sp)
    80003ce6:	6165                	addi	sp,sp,112
    80003ce8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cea:	89d6                	mv	s3,s5
    80003cec:	bff1                	j	80003cc8 <readi+0xce>
    return 0;
    80003cee:	4501                	li	a0,0
}
    80003cf0:	8082                	ret

0000000080003cf2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cf2:	457c                	lw	a5,76(a0)
    80003cf4:	10d7e863          	bltu	a5,a3,80003e04 <writei+0x112>
{
    80003cf8:	7159                	addi	sp,sp,-112
    80003cfa:	f486                	sd	ra,104(sp)
    80003cfc:	f0a2                	sd	s0,96(sp)
    80003cfe:	eca6                	sd	s1,88(sp)
    80003d00:	e8ca                	sd	s2,80(sp)
    80003d02:	e4ce                	sd	s3,72(sp)
    80003d04:	e0d2                	sd	s4,64(sp)
    80003d06:	fc56                	sd	s5,56(sp)
    80003d08:	f85a                	sd	s6,48(sp)
    80003d0a:	f45e                	sd	s7,40(sp)
    80003d0c:	f062                	sd	s8,32(sp)
    80003d0e:	ec66                	sd	s9,24(sp)
    80003d10:	e86a                	sd	s10,16(sp)
    80003d12:	e46e                	sd	s11,8(sp)
    80003d14:	1880                	addi	s0,sp,112
    80003d16:	8aaa                	mv	s5,a0
    80003d18:	8bae                	mv	s7,a1
    80003d1a:	8a32                	mv	s4,a2
    80003d1c:	8936                	mv	s2,a3
    80003d1e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d20:	00e687bb          	addw	a5,a3,a4
    80003d24:	0ed7e263          	bltu	a5,a3,80003e08 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d28:	00043737          	lui	a4,0x43
    80003d2c:	0ef76063          	bltu	a4,a5,80003e0c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d30:	0c0b0863          	beqz	s6,80003e00 <writei+0x10e>
    80003d34:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d36:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d3a:	5c7d                	li	s8,-1
    80003d3c:	a091                	j	80003d80 <writei+0x8e>
    80003d3e:	020d1d93          	slli	s11,s10,0x20
    80003d42:	020ddd93          	srli	s11,s11,0x20
    80003d46:	05848793          	addi	a5,s1,88
    80003d4a:	86ee                	mv	a3,s11
    80003d4c:	8652                	mv	a2,s4
    80003d4e:	85de                	mv	a1,s7
    80003d50:	953e                	add	a0,a0,a5
    80003d52:	fffff097          	auipc	ra,0xfffff
    80003d56:	82e080e7          	jalr	-2002(ra) # 80002580 <either_copyin>
    80003d5a:	07850263          	beq	a0,s8,80003dbe <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d5e:	8526                	mv	a0,s1
    80003d60:	00000097          	auipc	ra,0x0
    80003d64:	780080e7          	jalr	1920(ra) # 800044e0 <log_write>
    brelse(bp);
    80003d68:	8526                	mv	a0,s1
    80003d6a:	fffff097          	auipc	ra,0xfffff
    80003d6e:	4f2080e7          	jalr	1266(ra) # 8000325c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d72:	013d09bb          	addw	s3,s10,s3
    80003d76:	012d093b          	addw	s2,s10,s2
    80003d7a:	9a6e                	add	s4,s4,s11
    80003d7c:	0569f663          	bgeu	s3,s6,80003dc8 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d80:	00a9559b          	srliw	a1,s2,0xa
    80003d84:	8556                	mv	a0,s5
    80003d86:	fffff097          	auipc	ra,0xfffff
    80003d8a:	7a0080e7          	jalr	1952(ra) # 80003526 <bmap>
    80003d8e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d92:	c99d                	beqz	a1,80003dc8 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d94:	000aa503          	lw	a0,0(s5)
    80003d98:	fffff097          	auipc	ra,0xfffff
    80003d9c:	394080e7          	jalr	916(ra) # 8000312c <bread>
    80003da0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003da2:	3ff97513          	andi	a0,s2,1023
    80003da6:	40ac87bb          	subw	a5,s9,a0
    80003daa:	413b073b          	subw	a4,s6,s3
    80003dae:	8d3e                	mv	s10,a5
    80003db0:	2781                	sext.w	a5,a5
    80003db2:	0007069b          	sext.w	a3,a4
    80003db6:	f8f6f4e3          	bgeu	a3,a5,80003d3e <writei+0x4c>
    80003dba:	8d3a                	mv	s10,a4
    80003dbc:	b749                	j	80003d3e <writei+0x4c>
      brelse(bp);
    80003dbe:	8526                	mv	a0,s1
    80003dc0:	fffff097          	auipc	ra,0xfffff
    80003dc4:	49c080e7          	jalr	1180(ra) # 8000325c <brelse>
  }

  if(off > ip->size)
    80003dc8:	04caa783          	lw	a5,76(s5)
    80003dcc:	0127f463          	bgeu	a5,s2,80003dd4 <writei+0xe2>
    ip->size = off;
    80003dd0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003dd4:	8556                	mv	a0,s5
    80003dd6:	00000097          	auipc	ra,0x0
    80003dda:	aa6080e7          	jalr	-1370(ra) # 8000387c <iupdate>

  return tot;
    80003dde:	0009851b          	sext.w	a0,s3
}
    80003de2:	70a6                	ld	ra,104(sp)
    80003de4:	7406                	ld	s0,96(sp)
    80003de6:	64e6                	ld	s1,88(sp)
    80003de8:	6946                	ld	s2,80(sp)
    80003dea:	69a6                	ld	s3,72(sp)
    80003dec:	6a06                	ld	s4,64(sp)
    80003dee:	7ae2                	ld	s5,56(sp)
    80003df0:	7b42                	ld	s6,48(sp)
    80003df2:	7ba2                	ld	s7,40(sp)
    80003df4:	7c02                	ld	s8,32(sp)
    80003df6:	6ce2                	ld	s9,24(sp)
    80003df8:	6d42                	ld	s10,16(sp)
    80003dfa:	6da2                	ld	s11,8(sp)
    80003dfc:	6165                	addi	sp,sp,112
    80003dfe:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e00:	89da                	mv	s3,s6
    80003e02:	bfc9                	j	80003dd4 <writei+0xe2>
    return -1;
    80003e04:	557d                	li	a0,-1
}
    80003e06:	8082                	ret
    return -1;
    80003e08:	557d                	li	a0,-1
    80003e0a:	bfe1                	j	80003de2 <writei+0xf0>
    return -1;
    80003e0c:	557d                	li	a0,-1
    80003e0e:	bfd1                	j	80003de2 <writei+0xf0>

0000000080003e10 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e10:	1141                	addi	sp,sp,-16
    80003e12:	e406                	sd	ra,8(sp)
    80003e14:	e022                	sd	s0,0(sp)
    80003e16:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e18:	4639                	li	a2,14
    80003e1a:	ffffd097          	auipc	ra,0xffffd
    80003e1e:	f88080e7          	jalr	-120(ra) # 80000da2 <strncmp>
}
    80003e22:	60a2                	ld	ra,8(sp)
    80003e24:	6402                	ld	s0,0(sp)
    80003e26:	0141                	addi	sp,sp,16
    80003e28:	8082                	ret

0000000080003e2a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e2a:	7139                	addi	sp,sp,-64
    80003e2c:	fc06                	sd	ra,56(sp)
    80003e2e:	f822                	sd	s0,48(sp)
    80003e30:	f426                	sd	s1,40(sp)
    80003e32:	f04a                	sd	s2,32(sp)
    80003e34:	ec4e                	sd	s3,24(sp)
    80003e36:	e852                	sd	s4,16(sp)
    80003e38:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e3a:	04451703          	lh	a4,68(a0)
    80003e3e:	4785                	li	a5,1
    80003e40:	00f71a63          	bne	a4,a5,80003e54 <dirlookup+0x2a>
    80003e44:	892a                	mv	s2,a0
    80003e46:	89ae                	mv	s3,a1
    80003e48:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e4a:	457c                	lw	a5,76(a0)
    80003e4c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e4e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e50:	e79d                	bnez	a5,80003e7e <dirlookup+0x54>
    80003e52:	a8a5                	j	80003eca <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e54:	00004517          	auipc	a0,0x4
    80003e58:	78c50513          	addi	a0,a0,1932 # 800085e0 <syscalls+0x1a0>
    80003e5c:	ffffc097          	auipc	ra,0xffffc
    80003e60:	6e2080e7          	jalr	1762(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003e64:	00004517          	auipc	a0,0x4
    80003e68:	79450513          	addi	a0,a0,1940 # 800085f8 <syscalls+0x1b8>
    80003e6c:	ffffc097          	auipc	ra,0xffffc
    80003e70:	6d2080e7          	jalr	1746(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e74:	24c1                	addiw	s1,s1,16
    80003e76:	04c92783          	lw	a5,76(s2)
    80003e7a:	04f4f763          	bgeu	s1,a5,80003ec8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e7e:	4741                	li	a4,16
    80003e80:	86a6                	mv	a3,s1
    80003e82:	fc040613          	addi	a2,s0,-64
    80003e86:	4581                	li	a1,0
    80003e88:	854a                	mv	a0,s2
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	d70080e7          	jalr	-656(ra) # 80003bfa <readi>
    80003e92:	47c1                	li	a5,16
    80003e94:	fcf518e3          	bne	a0,a5,80003e64 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e98:	fc045783          	lhu	a5,-64(s0)
    80003e9c:	dfe1                	beqz	a5,80003e74 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e9e:	fc240593          	addi	a1,s0,-62
    80003ea2:	854e                	mv	a0,s3
    80003ea4:	00000097          	auipc	ra,0x0
    80003ea8:	f6c080e7          	jalr	-148(ra) # 80003e10 <namecmp>
    80003eac:	f561                	bnez	a0,80003e74 <dirlookup+0x4a>
      if(poff)
    80003eae:	000a0463          	beqz	s4,80003eb6 <dirlookup+0x8c>
        *poff = off;
    80003eb2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003eb6:	fc045583          	lhu	a1,-64(s0)
    80003eba:	00092503          	lw	a0,0(s2)
    80003ebe:	fffff097          	auipc	ra,0xfffff
    80003ec2:	750080e7          	jalr	1872(ra) # 8000360e <iget>
    80003ec6:	a011                	j	80003eca <dirlookup+0xa0>
  return 0;
    80003ec8:	4501                	li	a0,0
}
    80003eca:	70e2                	ld	ra,56(sp)
    80003ecc:	7442                	ld	s0,48(sp)
    80003ece:	74a2                	ld	s1,40(sp)
    80003ed0:	7902                	ld	s2,32(sp)
    80003ed2:	69e2                	ld	s3,24(sp)
    80003ed4:	6a42                	ld	s4,16(sp)
    80003ed6:	6121                	addi	sp,sp,64
    80003ed8:	8082                	ret

0000000080003eda <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003eda:	711d                	addi	sp,sp,-96
    80003edc:	ec86                	sd	ra,88(sp)
    80003ede:	e8a2                	sd	s0,80(sp)
    80003ee0:	e4a6                	sd	s1,72(sp)
    80003ee2:	e0ca                	sd	s2,64(sp)
    80003ee4:	fc4e                	sd	s3,56(sp)
    80003ee6:	f852                	sd	s4,48(sp)
    80003ee8:	f456                	sd	s5,40(sp)
    80003eea:	f05a                	sd	s6,32(sp)
    80003eec:	ec5e                	sd	s7,24(sp)
    80003eee:	e862                	sd	s8,16(sp)
    80003ef0:	e466                	sd	s9,8(sp)
    80003ef2:	1080                	addi	s0,sp,96
    80003ef4:	84aa                	mv	s1,a0
    80003ef6:	8aae                	mv	s5,a1
    80003ef8:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003efa:	00054703          	lbu	a4,0(a0)
    80003efe:	02f00793          	li	a5,47
    80003f02:	02f70363          	beq	a4,a5,80003f28 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f06:	ffffe097          	auipc	ra,0xffffe
    80003f0a:	a7a080e7          	jalr	-1414(ra) # 80001980 <myproc>
    80003f0e:	18853503          	ld	a0,392(a0)
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	9f6080e7          	jalr	-1546(ra) # 80003908 <idup>
    80003f1a:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f1c:	02f00913          	li	s2,47
  len = path - s;
    80003f20:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f22:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f24:	4b85                	li	s7,1
    80003f26:	a865                	j	80003fde <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f28:	4585                	li	a1,1
    80003f2a:	4505                	li	a0,1
    80003f2c:	fffff097          	auipc	ra,0xfffff
    80003f30:	6e2080e7          	jalr	1762(ra) # 8000360e <iget>
    80003f34:	89aa                	mv	s3,a0
    80003f36:	b7dd                	j	80003f1c <namex+0x42>
      iunlockput(ip);
    80003f38:	854e                	mv	a0,s3
    80003f3a:	00000097          	auipc	ra,0x0
    80003f3e:	c6e080e7          	jalr	-914(ra) # 80003ba8 <iunlockput>
      return 0;
    80003f42:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f44:	854e                	mv	a0,s3
    80003f46:	60e6                	ld	ra,88(sp)
    80003f48:	6446                	ld	s0,80(sp)
    80003f4a:	64a6                	ld	s1,72(sp)
    80003f4c:	6906                	ld	s2,64(sp)
    80003f4e:	79e2                	ld	s3,56(sp)
    80003f50:	7a42                	ld	s4,48(sp)
    80003f52:	7aa2                	ld	s5,40(sp)
    80003f54:	7b02                	ld	s6,32(sp)
    80003f56:	6be2                	ld	s7,24(sp)
    80003f58:	6c42                	ld	s8,16(sp)
    80003f5a:	6ca2                	ld	s9,8(sp)
    80003f5c:	6125                	addi	sp,sp,96
    80003f5e:	8082                	ret
      iunlock(ip);
    80003f60:	854e                	mv	a0,s3
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	aa6080e7          	jalr	-1370(ra) # 80003a08 <iunlock>
      return ip;
    80003f6a:	bfe9                	j	80003f44 <namex+0x6a>
      iunlockput(ip);
    80003f6c:	854e                	mv	a0,s3
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	c3a080e7          	jalr	-966(ra) # 80003ba8 <iunlockput>
      return 0;
    80003f76:	89e6                	mv	s3,s9
    80003f78:	b7f1                	j	80003f44 <namex+0x6a>
  len = path - s;
    80003f7a:	40b48633          	sub	a2,s1,a1
    80003f7e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f82:	099c5463          	bge	s8,s9,8000400a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f86:	4639                	li	a2,14
    80003f88:	8552                	mv	a0,s4
    80003f8a:	ffffd097          	auipc	ra,0xffffd
    80003f8e:	da4080e7          	jalr	-604(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003f92:	0004c783          	lbu	a5,0(s1)
    80003f96:	01279763          	bne	a5,s2,80003fa4 <namex+0xca>
    path++;
    80003f9a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f9c:	0004c783          	lbu	a5,0(s1)
    80003fa0:	ff278de3          	beq	a5,s2,80003f9a <namex+0xc0>
    ilock(ip);
    80003fa4:	854e                	mv	a0,s3
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	9a0080e7          	jalr	-1632(ra) # 80003946 <ilock>
    if(ip->type != T_DIR){
    80003fae:	04499783          	lh	a5,68(s3)
    80003fb2:	f97793e3          	bne	a5,s7,80003f38 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003fb6:	000a8563          	beqz	s5,80003fc0 <namex+0xe6>
    80003fba:	0004c783          	lbu	a5,0(s1)
    80003fbe:	d3cd                	beqz	a5,80003f60 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fc0:	865a                	mv	a2,s6
    80003fc2:	85d2                	mv	a1,s4
    80003fc4:	854e                	mv	a0,s3
    80003fc6:	00000097          	auipc	ra,0x0
    80003fca:	e64080e7          	jalr	-412(ra) # 80003e2a <dirlookup>
    80003fce:	8caa                	mv	s9,a0
    80003fd0:	dd51                	beqz	a0,80003f6c <namex+0x92>
    iunlockput(ip);
    80003fd2:	854e                	mv	a0,s3
    80003fd4:	00000097          	auipc	ra,0x0
    80003fd8:	bd4080e7          	jalr	-1068(ra) # 80003ba8 <iunlockput>
    ip = next;
    80003fdc:	89e6                	mv	s3,s9
  while(*path == '/')
    80003fde:	0004c783          	lbu	a5,0(s1)
    80003fe2:	05279763          	bne	a5,s2,80004030 <namex+0x156>
    path++;
    80003fe6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fe8:	0004c783          	lbu	a5,0(s1)
    80003fec:	ff278de3          	beq	a5,s2,80003fe6 <namex+0x10c>
  if(*path == 0)
    80003ff0:	c79d                	beqz	a5,8000401e <namex+0x144>
    path++;
    80003ff2:	85a6                	mv	a1,s1
  len = path - s;
    80003ff4:	8cda                	mv	s9,s6
    80003ff6:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003ff8:	01278963          	beq	a5,s2,8000400a <namex+0x130>
    80003ffc:	dfbd                	beqz	a5,80003f7a <namex+0xa0>
    path++;
    80003ffe:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004000:	0004c783          	lbu	a5,0(s1)
    80004004:	ff279ce3          	bne	a5,s2,80003ffc <namex+0x122>
    80004008:	bf8d                	j	80003f7a <namex+0xa0>
    memmove(name, s, len);
    8000400a:	2601                	sext.w	a2,a2
    8000400c:	8552                	mv	a0,s4
    8000400e:	ffffd097          	auipc	ra,0xffffd
    80004012:	d20080e7          	jalr	-736(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004016:	9cd2                	add	s9,s9,s4
    80004018:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000401c:	bf9d                	j	80003f92 <namex+0xb8>
  if(nameiparent){
    8000401e:	f20a83e3          	beqz	s5,80003f44 <namex+0x6a>
    iput(ip);
    80004022:	854e                	mv	a0,s3
    80004024:	00000097          	auipc	ra,0x0
    80004028:	adc080e7          	jalr	-1316(ra) # 80003b00 <iput>
    return 0;
    8000402c:	4981                	li	s3,0
    8000402e:	bf19                	j	80003f44 <namex+0x6a>
  if(*path == 0)
    80004030:	d7fd                	beqz	a5,8000401e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004032:	0004c783          	lbu	a5,0(s1)
    80004036:	85a6                	mv	a1,s1
    80004038:	b7d1                	j	80003ffc <namex+0x122>

000000008000403a <dirlink>:
{
    8000403a:	7139                	addi	sp,sp,-64
    8000403c:	fc06                	sd	ra,56(sp)
    8000403e:	f822                	sd	s0,48(sp)
    80004040:	f426                	sd	s1,40(sp)
    80004042:	f04a                	sd	s2,32(sp)
    80004044:	ec4e                	sd	s3,24(sp)
    80004046:	e852                	sd	s4,16(sp)
    80004048:	0080                	addi	s0,sp,64
    8000404a:	892a                	mv	s2,a0
    8000404c:	8a2e                	mv	s4,a1
    8000404e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004050:	4601                	li	a2,0
    80004052:	00000097          	auipc	ra,0x0
    80004056:	dd8080e7          	jalr	-552(ra) # 80003e2a <dirlookup>
    8000405a:	e93d                	bnez	a0,800040d0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000405c:	04c92483          	lw	s1,76(s2)
    80004060:	c49d                	beqz	s1,8000408e <dirlink+0x54>
    80004062:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004064:	4741                	li	a4,16
    80004066:	86a6                	mv	a3,s1
    80004068:	fc040613          	addi	a2,s0,-64
    8000406c:	4581                	li	a1,0
    8000406e:	854a                	mv	a0,s2
    80004070:	00000097          	auipc	ra,0x0
    80004074:	b8a080e7          	jalr	-1142(ra) # 80003bfa <readi>
    80004078:	47c1                	li	a5,16
    8000407a:	06f51163          	bne	a0,a5,800040dc <dirlink+0xa2>
    if(de.inum == 0)
    8000407e:	fc045783          	lhu	a5,-64(s0)
    80004082:	c791                	beqz	a5,8000408e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004084:	24c1                	addiw	s1,s1,16
    80004086:	04c92783          	lw	a5,76(s2)
    8000408a:	fcf4ede3          	bltu	s1,a5,80004064 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000408e:	4639                	li	a2,14
    80004090:	85d2                	mv	a1,s4
    80004092:	fc240513          	addi	a0,s0,-62
    80004096:	ffffd097          	auipc	ra,0xffffd
    8000409a:	d48080e7          	jalr	-696(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000409e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040a2:	4741                	li	a4,16
    800040a4:	86a6                	mv	a3,s1
    800040a6:	fc040613          	addi	a2,s0,-64
    800040aa:	4581                	li	a1,0
    800040ac:	854a                	mv	a0,s2
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	c44080e7          	jalr	-956(ra) # 80003cf2 <writei>
    800040b6:	1541                	addi	a0,a0,-16
    800040b8:	00a03533          	snez	a0,a0
    800040bc:	40a00533          	neg	a0,a0
}
    800040c0:	70e2                	ld	ra,56(sp)
    800040c2:	7442                	ld	s0,48(sp)
    800040c4:	74a2                	ld	s1,40(sp)
    800040c6:	7902                	ld	s2,32(sp)
    800040c8:	69e2                	ld	s3,24(sp)
    800040ca:	6a42                	ld	s4,16(sp)
    800040cc:	6121                	addi	sp,sp,64
    800040ce:	8082                	ret
    iput(ip);
    800040d0:	00000097          	auipc	ra,0x0
    800040d4:	a30080e7          	jalr	-1488(ra) # 80003b00 <iput>
    return -1;
    800040d8:	557d                	li	a0,-1
    800040da:	b7dd                	j	800040c0 <dirlink+0x86>
      panic("dirlink read");
    800040dc:	00004517          	auipc	a0,0x4
    800040e0:	52c50513          	addi	a0,a0,1324 # 80008608 <syscalls+0x1c8>
    800040e4:	ffffc097          	auipc	ra,0xffffc
    800040e8:	45a080e7          	jalr	1114(ra) # 8000053e <panic>

00000000800040ec <namei>:

struct inode*
namei(char *path)
{
    800040ec:	1101                	addi	sp,sp,-32
    800040ee:	ec06                	sd	ra,24(sp)
    800040f0:	e822                	sd	s0,16(sp)
    800040f2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040f4:	fe040613          	addi	a2,s0,-32
    800040f8:	4581                	li	a1,0
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	de0080e7          	jalr	-544(ra) # 80003eda <namex>
}
    80004102:	60e2                	ld	ra,24(sp)
    80004104:	6442                	ld	s0,16(sp)
    80004106:	6105                	addi	sp,sp,32
    80004108:	8082                	ret

000000008000410a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000410a:	1141                	addi	sp,sp,-16
    8000410c:	e406                	sd	ra,8(sp)
    8000410e:	e022                	sd	s0,0(sp)
    80004110:	0800                	addi	s0,sp,16
    80004112:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004114:	4585                	li	a1,1
    80004116:	00000097          	auipc	ra,0x0
    8000411a:	dc4080e7          	jalr	-572(ra) # 80003eda <namex>
}
    8000411e:	60a2                	ld	ra,8(sp)
    80004120:	6402                	ld	s0,0(sp)
    80004122:	0141                	addi	sp,sp,16
    80004124:	8082                	ret

0000000080004126 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004126:	1101                	addi	sp,sp,-32
    80004128:	ec06                	sd	ra,24(sp)
    8000412a:	e822                	sd	s0,16(sp)
    8000412c:	e426                	sd	s1,8(sp)
    8000412e:	e04a                	sd	s2,0(sp)
    80004130:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004132:	0001e917          	auipc	s2,0x1e
    80004136:	fde90913          	addi	s2,s2,-34 # 80022110 <log>
    8000413a:	01892583          	lw	a1,24(s2)
    8000413e:	02892503          	lw	a0,40(s2)
    80004142:	fffff097          	auipc	ra,0xfffff
    80004146:	fea080e7          	jalr	-22(ra) # 8000312c <bread>
    8000414a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000414c:	02c92683          	lw	a3,44(s2)
    80004150:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004152:	02d05763          	blez	a3,80004180 <write_head+0x5a>
    80004156:	0001e797          	auipc	a5,0x1e
    8000415a:	fea78793          	addi	a5,a5,-22 # 80022140 <log+0x30>
    8000415e:	05c50713          	addi	a4,a0,92
    80004162:	36fd                	addiw	a3,a3,-1
    80004164:	1682                	slli	a3,a3,0x20
    80004166:	9281                	srli	a3,a3,0x20
    80004168:	068a                	slli	a3,a3,0x2
    8000416a:	0001e617          	auipc	a2,0x1e
    8000416e:	fda60613          	addi	a2,a2,-38 # 80022144 <log+0x34>
    80004172:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004174:	4390                	lw	a2,0(a5)
    80004176:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004178:	0791                	addi	a5,a5,4
    8000417a:	0711                	addi	a4,a4,4
    8000417c:	fed79ce3          	bne	a5,a3,80004174 <write_head+0x4e>
  }
  bwrite(buf);
    80004180:	8526                	mv	a0,s1
    80004182:	fffff097          	auipc	ra,0xfffff
    80004186:	09c080e7          	jalr	156(ra) # 8000321e <bwrite>
  brelse(buf);
    8000418a:	8526                	mv	a0,s1
    8000418c:	fffff097          	auipc	ra,0xfffff
    80004190:	0d0080e7          	jalr	208(ra) # 8000325c <brelse>
}
    80004194:	60e2                	ld	ra,24(sp)
    80004196:	6442                	ld	s0,16(sp)
    80004198:	64a2                	ld	s1,8(sp)
    8000419a:	6902                	ld	s2,0(sp)
    8000419c:	6105                	addi	sp,sp,32
    8000419e:	8082                	ret

00000000800041a0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a0:	0001e797          	auipc	a5,0x1e
    800041a4:	f9c7a783          	lw	a5,-100(a5) # 8002213c <log+0x2c>
    800041a8:	0af05d63          	blez	a5,80004262 <install_trans+0xc2>
{
    800041ac:	7139                	addi	sp,sp,-64
    800041ae:	fc06                	sd	ra,56(sp)
    800041b0:	f822                	sd	s0,48(sp)
    800041b2:	f426                	sd	s1,40(sp)
    800041b4:	f04a                	sd	s2,32(sp)
    800041b6:	ec4e                	sd	s3,24(sp)
    800041b8:	e852                	sd	s4,16(sp)
    800041ba:	e456                	sd	s5,8(sp)
    800041bc:	e05a                	sd	s6,0(sp)
    800041be:	0080                	addi	s0,sp,64
    800041c0:	8b2a                	mv	s6,a0
    800041c2:	0001ea97          	auipc	s5,0x1e
    800041c6:	f7ea8a93          	addi	s5,s5,-130 # 80022140 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ca:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041cc:	0001e997          	auipc	s3,0x1e
    800041d0:	f4498993          	addi	s3,s3,-188 # 80022110 <log>
    800041d4:	a00d                	j	800041f6 <install_trans+0x56>
    brelse(lbuf);
    800041d6:	854a                	mv	a0,s2
    800041d8:	fffff097          	auipc	ra,0xfffff
    800041dc:	084080e7          	jalr	132(ra) # 8000325c <brelse>
    brelse(dbuf);
    800041e0:	8526                	mv	a0,s1
    800041e2:	fffff097          	auipc	ra,0xfffff
    800041e6:	07a080e7          	jalr	122(ra) # 8000325c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ea:	2a05                	addiw	s4,s4,1
    800041ec:	0a91                	addi	s5,s5,4
    800041ee:	02c9a783          	lw	a5,44(s3)
    800041f2:	04fa5e63          	bge	s4,a5,8000424e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041f6:	0189a583          	lw	a1,24(s3)
    800041fa:	014585bb          	addw	a1,a1,s4
    800041fe:	2585                	addiw	a1,a1,1
    80004200:	0289a503          	lw	a0,40(s3)
    80004204:	fffff097          	auipc	ra,0xfffff
    80004208:	f28080e7          	jalr	-216(ra) # 8000312c <bread>
    8000420c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000420e:	000aa583          	lw	a1,0(s5)
    80004212:	0289a503          	lw	a0,40(s3)
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	f16080e7          	jalr	-234(ra) # 8000312c <bread>
    8000421e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004220:	40000613          	li	a2,1024
    80004224:	05890593          	addi	a1,s2,88
    80004228:	05850513          	addi	a0,a0,88
    8000422c:	ffffd097          	auipc	ra,0xffffd
    80004230:	b02080e7          	jalr	-1278(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004234:	8526                	mv	a0,s1
    80004236:	fffff097          	auipc	ra,0xfffff
    8000423a:	fe8080e7          	jalr	-24(ra) # 8000321e <bwrite>
    if(recovering == 0)
    8000423e:	f80b1ce3          	bnez	s6,800041d6 <install_trans+0x36>
      bunpin(dbuf);
    80004242:	8526                	mv	a0,s1
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	0f2080e7          	jalr	242(ra) # 80003336 <bunpin>
    8000424c:	b769                	j	800041d6 <install_trans+0x36>
}
    8000424e:	70e2                	ld	ra,56(sp)
    80004250:	7442                	ld	s0,48(sp)
    80004252:	74a2                	ld	s1,40(sp)
    80004254:	7902                	ld	s2,32(sp)
    80004256:	69e2                	ld	s3,24(sp)
    80004258:	6a42                	ld	s4,16(sp)
    8000425a:	6aa2                	ld	s5,8(sp)
    8000425c:	6b02                	ld	s6,0(sp)
    8000425e:	6121                	addi	sp,sp,64
    80004260:	8082                	ret
    80004262:	8082                	ret

0000000080004264 <initlog>:
{
    80004264:	7179                	addi	sp,sp,-48
    80004266:	f406                	sd	ra,40(sp)
    80004268:	f022                	sd	s0,32(sp)
    8000426a:	ec26                	sd	s1,24(sp)
    8000426c:	e84a                	sd	s2,16(sp)
    8000426e:	e44e                	sd	s3,8(sp)
    80004270:	1800                	addi	s0,sp,48
    80004272:	892a                	mv	s2,a0
    80004274:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004276:	0001e497          	auipc	s1,0x1e
    8000427a:	e9a48493          	addi	s1,s1,-358 # 80022110 <log>
    8000427e:	00004597          	auipc	a1,0x4
    80004282:	39a58593          	addi	a1,a1,922 # 80008618 <syscalls+0x1d8>
    80004286:	8526                	mv	a0,s1
    80004288:	ffffd097          	auipc	ra,0xffffd
    8000428c:	8be080e7          	jalr	-1858(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004290:	0149a583          	lw	a1,20(s3)
    80004294:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004296:	0109a783          	lw	a5,16(s3)
    8000429a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000429c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042a0:	854a                	mv	a0,s2
    800042a2:	fffff097          	auipc	ra,0xfffff
    800042a6:	e8a080e7          	jalr	-374(ra) # 8000312c <bread>
  log.lh.n = lh->n;
    800042aa:	4d34                	lw	a3,88(a0)
    800042ac:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042ae:	02d05563          	blez	a3,800042d8 <initlog+0x74>
    800042b2:	05c50793          	addi	a5,a0,92
    800042b6:	0001e717          	auipc	a4,0x1e
    800042ba:	e8a70713          	addi	a4,a4,-374 # 80022140 <log+0x30>
    800042be:	36fd                	addiw	a3,a3,-1
    800042c0:	1682                	slli	a3,a3,0x20
    800042c2:	9281                	srli	a3,a3,0x20
    800042c4:	068a                	slli	a3,a3,0x2
    800042c6:	06050613          	addi	a2,a0,96
    800042ca:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800042cc:	4390                	lw	a2,0(a5)
    800042ce:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042d0:	0791                	addi	a5,a5,4
    800042d2:	0711                	addi	a4,a4,4
    800042d4:	fed79ce3          	bne	a5,a3,800042cc <initlog+0x68>
  brelse(buf);
    800042d8:	fffff097          	auipc	ra,0xfffff
    800042dc:	f84080e7          	jalr	-124(ra) # 8000325c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042e0:	4505                	li	a0,1
    800042e2:	00000097          	auipc	ra,0x0
    800042e6:	ebe080e7          	jalr	-322(ra) # 800041a0 <install_trans>
  log.lh.n = 0;
    800042ea:	0001e797          	auipc	a5,0x1e
    800042ee:	e407a923          	sw	zero,-430(a5) # 8002213c <log+0x2c>
  write_head(); // clear the log
    800042f2:	00000097          	auipc	ra,0x0
    800042f6:	e34080e7          	jalr	-460(ra) # 80004126 <write_head>
}
    800042fa:	70a2                	ld	ra,40(sp)
    800042fc:	7402                	ld	s0,32(sp)
    800042fe:	64e2                	ld	s1,24(sp)
    80004300:	6942                	ld	s2,16(sp)
    80004302:	69a2                	ld	s3,8(sp)
    80004304:	6145                	addi	sp,sp,48
    80004306:	8082                	ret

0000000080004308 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004308:	1101                	addi	sp,sp,-32
    8000430a:	ec06                	sd	ra,24(sp)
    8000430c:	e822                	sd	s0,16(sp)
    8000430e:	e426                	sd	s1,8(sp)
    80004310:	e04a                	sd	s2,0(sp)
    80004312:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004314:	0001e517          	auipc	a0,0x1e
    80004318:	dfc50513          	addi	a0,a0,-516 # 80022110 <log>
    8000431c:	ffffd097          	auipc	ra,0xffffd
    80004320:	8ba080e7          	jalr	-1862(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004324:	0001e497          	auipc	s1,0x1e
    80004328:	dec48493          	addi	s1,s1,-532 # 80022110 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000432c:	4979                	li	s2,30
    8000432e:	a039                	j	8000433c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004330:	85a6                	mv	a1,s1
    80004332:	8526                	mv	a0,s1
    80004334:	ffffe097          	auipc	ra,0xffffe
    80004338:	d88080e7          	jalr	-632(ra) # 800020bc <sleep>
    if(log.committing){
    8000433c:	50dc                	lw	a5,36(s1)
    8000433e:	fbed                	bnez	a5,80004330 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004340:	509c                	lw	a5,32(s1)
    80004342:	0017871b          	addiw	a4,a5,1
    80004346:	0007069b          	sext.w	a3,a4
    8000434a:	0027179b          	slliw	a5,a4,0x2
    8000434e:	9fb9                	addw	a5,a5,a4
    80004350:	0017979b          	slliw	a5,a5,0x1
    80004354:	54d8                	lw	a4,44(s1)
    80004356:	9fb9                	addw	a5,a5,a4
    80004358:	00f95963          	bge	s2,a5,8000436a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000435c:	85a6                	mv	a1,s1
    8000435e:	8526                	mv	a0,s1
    80004360:	ffffe097          	auipc	ra,0xffffe
    80004364:	d5c080e7          	jalr	-676(ra) # 800020bc <sleep>
    80004368:	bfd1                	j	8000433c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000436a:	0001e517          	auipc	a0,0x1e
    8000436e:	da650513          	addi	a0,a0,-602 # 80022110 <log>
    80004372:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	916080e7          	jalr	-1770(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000437c:	60e2                	ld	ra,24(sp)
    8000437e:	6442                	ld	s0,16(sp)
    80004380:	64a2                	ld	s1,8(sp)
    80004382:	6902                	ld	s2,0(sp)
    80004384:	6105                	addi	sp,sp,32
    80004386:	8082                	ret

0000000080004388 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004388:	7139                	addi	sp,sp,-64
    8000438a:	fc06                	sd	ra,56(sp)
    8000438c:	f822                	sd	s0,48(sp)
    8000438e:	f426                	sd	s1,40(sp)
    80004390:	f04a                	sd	s2,32(sp)
    80004392:	ec4e                	sd	s3,24(sp)
    80004394:	e852                	sd	s4,16(sp)
    80004396:	e456                	sd	s5,8(sp)
    80004398:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000439a:	0001e497          	auipc	s1,0x1e
    8000439e:	d7648493          	addi	s1,s1,-650 # 80022110 <log>
    800043a2:	8526                	mv	a0,s1
    800043a4:	ffffd097          	auipc	ra,0xffffd
    800043a8:	832080e7          	jalr	-1998(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800043ac:	509c                	lw	a5,32(s1)
    800043ae:	37fd                	addiw	a5,a5,-1
    800043b0:	0007891b          	sext.w	s2,a5
    800043b4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043b6:	50dc                	lw	a5,36(s1)
    800043b8:	e7b9                	bnez	a5,80004406 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043ba:	04091e63          	bnez	s2,80004416 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043be:	0001e497          	auipc	s1,0x1e
    800043c2:	d5248493          	addi	s1,s1,-686 # 80022110 <log>
    800043c6:	4785                	li	a5,1
    800043c8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043ca:	8526                	mv	a0,s1
    800043cc:	ffffd097          	auipc	ra,0xffffd
    800043d0:	8be080e7          	jalr	-1858(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043d4:	54dc                	lw	a5,44(s1)
    800043d6:	06f04763          	bgtz	a5,80004444 <end_op+0xbc>
    acquire(&log.lock);
    800043da:	0001e497          	auipc	s1,0x1e
    800043de:	d3648493          	addi	s1,s1,-714 # 80022110 <log>
    800043e2:	8526                	mv	a0,s1
    800043e4:	ffffc097          	auipc	ra,0xffffc
    800043e8:	7f2080e7          	jalr	2034(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800043ec:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043f0:	8526                	mv	a0,s1
    800043f2:	ffffe097          	auipc	ra,0xffffe
    800043f6:	d38080e7          	jalr	-712(ra) # 8000212a <wakeup>
    release(&log.lock);
    800043fa:	8526                	mv	a0,s1
    800043fc:	ffffd097          	auipc	ra,0xffffd
    80004400:	88e080e7          	jalr	-1906(ra) # 80000c8a <release>
}
    80004404:	a03d                	j	80004432 <end_op+0xaa>
    panic("log.committing");
    80004406:	00004517          	auipc	a0,0x4
    8000440a:	21a50513          	addi	a0,a0,538 # 80008620 <syscalls+0x1e0>
    8000440e:	ffffc097          	auipc	ra,0xffffc
    80004412:	130080e7          	jalr	304(ra) # 8000053e <panic>
    wakeup(&log);
    80004416:	0001e497          	auipc	s1,0x1e
    8000441a:	cfa48493          	addi	s1,s1,-774 # 80022110 <log>
    8000441e:	8526                	mv	a0,s1
    80004420:	ffffe097          	auipc	ra,0xffffe
    80004424:	d0a080e7          	jalr	-758(ra) # 8000212a <wakeup>
  release(&log.lock);
    80004428:	8526                	mv	a0,s1
    8000442a:	ffffd097          	auipc	ra,0xffffd
    8000442e:	860080e7          	jalr	-1952(ra) # 80000c8a <release>
}
    80004432:	70e2                	ld	ra,56(sp)
    80004434:	7442                	ld	s0,48(sp)
    80004436:	74a2                	ld	s1,40(sp)
    80004438:	7902                	ld	s2,32(sp)
    8000443a:	69e2                	ld	s3,24(sp)
    8000443c:	6a42                	ld	s4,16(sp)
    8000443e:	6aa2                	ld	s5,8(sp)
    80004440:	6121                	addi	sp,sp,64
    80004442:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004444:	0001ea97          	auipc	s5,0x1e
    80004448:	cfca8a93          	addi	s5,s5,-772 # 80022140 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000444c:	0001ea17          	auipc	s4,0x1e
    80004450:	cc4a0a13          	addi	s4,s4,-828 # 80022110 <log>
    80004454:	018a2583          	lw	a1,24(s4)
    80004458:	012585bb          	addw	a1,a1,s2
    8000445c:	2585                	addiw	a1,a1,1
    8000445e:	028a2503          	lw	a0,40(s4)
    80004462:	fffff097          	auipc	ra,0xfffff
    80004466:	cca080e7          	jalr	-822(ra) # 8000312c <bread>
    8000446a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000446c:	000aa583          	lw	a1,0(s5)
    80004470:	028a2503          	lw	a0,40(s4)
    80004474:	fffff097          	auipc	ra,0xfffff
    80004478:	cb8080e7          	jalr	-840(ra) # 8000312c <bread>
    8000447c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000447e:	40000613          	li	a2,1024
    80004482:	05850593          	addi	a1,a0,88
    80004486:	05848513          	addi	a0,s1,88
    8000448a:	ffffd097          	auipc	ra,0xffffd
    8000448e:	8a4080e7          	jalr	-1884(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004492:	8526                	mv	a0,s1
    80004494:	fffff097          	auipc	ra,0xfffff
    80004498:	d8a080e7          	jalr	-630(ra) # 8000321e <bwrite>
    brelse(from);
    8000449c:	854e                	mv	a0,s3
    8000449e:	fffff097          	auipc	ra,0xfffff
    800044a2:	dbe080e7          	jalr	-578(ra) # 8000325c <brelse>
    brelse(to);
    800044a6:	8526                	mv	a0,s1
    800044a8:	fffff097          	auipc	ra,0xfffff
    800044ac:	db4080e7          	jalr	-588(ra) # 8000325c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044b0:	2905                	addiw	s2,s2,1
    800044b2:	0a91                	addi	s5,s5,4
    800044b4:	02ca2783          	lw	a5,44(s4)
    800044b8:	f8f94ee3          	blt	s2,a5,80004454 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044bc:	00000097          	auipc	ra,0x0
    800044c0:	c6a080e7          	jalr	-918(ra) # 80004126 <write_head>
    install_trans(0); // Now install writes to home locations
    800044c4:	4501                	li	a0,0
    800044c6:	00000097          	auipc	ra,0x0
    800044ca:	cda080e7          	jalr	-806(ra) # 800041a0 <install_trans>
    log.lh.n = 0;
    800044ce:	0001e797          	auipc	a5,0x1e
    800044d2:	c607a723          	sw	zero,-914(a5) # 8002213c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044d6:	00000097          	auipc	ra,0x0
    800044da:	c50080e7          	jalr	-944(ra) # 80004126 <write_head>
    800044de:	bdf5                	j	800043da <end_op+0x52>

00000000800044e0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044e0:	1101                	addi	sp,sp,-32
    800044e2:	ec06                	sd	ra,24(sp)
    800044e4:	e822                	sd	s0,16(sp)
    800044e6:	e426                	sd	s1,8(sp)
    800044e8:	e04a                	sd	s2,0(sp)
    800044ea:	1000                	addi	s0,sp,32
    800044ec:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044ee:	0001e917          	auipc	s2,0x1e
    800044f2:	c2290913          	addi	s2,s2,-990 # 80022110 <log>
    800044f6:	854a                	mv	a0,s2
    800044f8:	ffffc097          	auipc	ra,0xffffc
    800044fc:	6de080e7          	jalr	1758(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004500:	02c92603          	lw	a2,44(s2)
    80004504:	47f5                	li	a5,29
    80004506:	06c7c563          	blt	a5,a2,80004570 <log_write+0x90>
    8000450a:	0001e797          	auipc	a5,0x1e
    8000450e:	c227a783          	lw	a5,-990(a5) # 8002212c <log+0x1c>
    80004512:	37fd                	addiw	a5,a5,-1
    80004514:	04f65e63          	bge	a2,a5,80004570 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004518:	0001e797          	auipc	a5,0x1e
    8000451c:	c187a783          	lw	a5,-1000(a5) # 80022130 <log+0x20>
    80004520:	06f05063          	blez	a5,80004580 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004524:	4781                	li	a5,0
    80004526:	06c05563          	blez	a2,80004590 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000452a:	44cc                	lw	a1,12(s1)
    8000452c:	0001e717          	auipc	a4,0x1e
    80004530:	c1470713          	addi	a4,a4,-1004 # 80022140 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004534:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004536:	4314                	lw	a3,0(a4)
    80004538:	04b68c63          	beq	a3,a1,80004590 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000453c:	2785                	addiw	a5,a5,1
    8000453e:	0711                	addi	a4,a4,4
    80004540:	fef61be3          	bne	a2,a5,80004536 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004544:	0621                	addi	a2,a2,8
    80004546:	060a                	slli	a2,a2,0x2
    80004548:	0001e797          	auipc	a5,0x1e
    8000454c:	bc878793          	addi	a5,a5,-1080 # 80022110 <log>
    80004550:	963e                	add	a2,a2,a5
    80004552:	44dc                	lw	a5,12(s1)
    80004554:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004556:	8526                	mv	a0,s1
    80004558:	fffff097          	auipc	ra,0xfffff
    8000455c:	da2080e7          	jalr	-606(ra) # 800032fa <bpin>
    log.lh.n++;
    80004560:	0001e717          	auipc	a4,0x1e
    80004564:	bb070713          	addi	a4,a4,-1104 # 80022110 <log>
    80004568:	575c                	lw	a5,44(a4)
    8000456a:	2785                	addiw	a5,a5,1
    8000456c:	d75c                	sw	a5,44(a4)
    8000456e:	a835                	j	800045aa <log_write+0xca>
    panic("too big a transaction");
    80004570:	00004517          	auipc	a0,0x4
    80004574:	0c050513          	addi	a0,a0,192 # 80008630 <syscalls+0x1f0>
    80004578:	ffffc097          	auipc	ra,0xffffc
    8000457c:	fc6080e7          	jalr	-58(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004580:	00004517          	auipc	a0,0x4
    80004584:	0c850513          	addi	a0,a0,200 # 80008648 <syscalls+0x208>
    80004588:	ffffc097          	auipc	ra,0xffffc
    8000458c:	fb6080e7          	jalr	-74(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004590:	00878713          	addi	a4,a5,8
    80004594:	00271693          	slli	a3,a4,0x2
    80004598:	0001e717          	auipc	a4,0x1e
    8000459c:	b7870713          	addi	a4,a4,-1160 # 80022110 <log>
    800045a0:	9736                	add	a4,a4,a3
    800045a2:	44d4                	lw	a3,12(s1)
    800045a4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045a6:	faf608e3          	beq	a2,a5,80004556 <log_write+0x76>
  }
  release(&log.lock);
    800045aa:	0001e517          	auipc	a0,0x1e
    800045ae:	b6650513          	addi	a0,a0,-1178 # 80022110 <log>
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	6d8080e7          	jalr	1752(ra) # 80000c8a <release>
}
    800045ba:	60e2                	ld	ra,24(sp)
    800045bc:	6442                	ld	s0,16(sp)
    800045be:	64a2                	ld	s1,8(sp)
    800045c0:	6902                	ld	s2,0(sp)
    800045c2:	6105                	addi	sp,sp,32
    800045c4:	8082                	ret

00000000800045c6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045c6:	1101                	addi	sp,sp,-32
    800045c8:	ec06                	sd	ra,24(sp)
    800045ca:	e822                	sd	s0,16(sp)
    800045cc:	e426                	sd	s1,8(sp)
    800045ce:	e04a                	sd	s2,0(sp)
    800045d0:	1000                	addi	s0,sp,32
    800045d2:	84aa                	mv	s1,a0
    800045d4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045d6:	00004597          	auipc	a1,0x4
    800045da:	09258593          	addi	a1,a1,146 # 80008668 <syscalls+0x228>
    800045de:	0521                	addi	a0,a0,8
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	566080e7          	jalr	1382(ra) # 80000b46 <initlock>
  lk->name = name;
    800045e8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045ec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045f0:	0204a423          	sw	zero,40(s1)
}
    800045f4:	60e2                	ld	ra,24(sp)
    800045f6:	6442                	ld	s0,16(sp)
    800045f8:	64a2                	ld	s1,8(sp)
    800045fa:	6902                	ld	s2,0(sp)
    800045fc:	6105                	addi	sp,sp,32
    800045fe:	8082                	ret

0000000080004600 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004600:	1101                	addi	sp,sp,-32
    80004602:	ec06                	sd	ra,24(sp)
    80004604:	e822                	sd	s0,16(sp)
    80004606:	e426                	sd	s1,8(sp)
    80004608:	e04a                	sd	s2,0(sp)
    8000460a:	1000                	addi	s0,sp,32
    8000460c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000460e:	00850913          	addi	s2,a0,8
    80004612:	854a                	mv	a0,s2
    80004614:	ffffc097          	auipc	ra,0xffffc
    80004618:	5c2080e7          	jalr	1474(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000461c:	409c                	lw	a5,0(s1)
    8000461e:	cb89                	beqz	a5,80004630 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004620:	85ca                	mv	a1,s2
    80004622:	8526                	mv	a0,s1
    80004624:	ffffe097          	auipc	ra,0xffffe
    80004628:	a98080e7          	jalr	-1384(ra) # 800020bc <sleep>
  while (lk->locked) {
    8000462c:	409c                	lw	a5,0(s1)
    8000462e:	fbed                	bnez	a5,80004620 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004630:	4785                	li	a5,1
    80004632:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004634:	ffffd097          	auipc	ra,0xffffd
    80004638:	34c080e7          	jalr	844(ra) # 80001980 <myproc>
    8000463c:	515c                	lw	a5,36(a0)
    8000463e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004640:	854a                	mv	a0,s2
    80004642:	ffffc097          	auipc	ra,0xffffc
    80004646:	648080e7          	jalr	1608(ra) # 80000c8a <release>
}
    8000464a:	60e2                	ld	ra,24(sp)
    8000464c:	6442                	ld	s0,16(sp)
    8000464e:	64a2                	ld	s1,8(sp)
    80004650:	6902                	ld	s2,0(sp)
    80004652:	6105                	addi	sp,sp,32
    80004654:	8082                	ret

0000000080004656 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004656:	1101                	addi	sp,sp,-32
    80004658:	ec06                	sd	ra,24(sp)
    8000465a:	e822                	sd	s0,16(sp)
    8000465c:	e426                	sd	s1,8(sp)
    8000465e:	e04a                	sd	s2,0(sp)
    80004660:	1000                	addi	s0,sp,32
    80004662:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004664:	00850913          	addi	s2,a0,8
    80004668:	854a                	mv	a0,s2
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	56c080e7          	jalr	1388(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004672:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004676:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000467a:	8526                	mv	a0,s1
    8000467c:	ffffe097          	auipc	ra,0xffffe
    80004680:	aae080e7          	jalr	-1362(ra) # 8000212a <wakeup>
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

000000008000469a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000469a:	7179                	addi	sp,sp,-48
    8000469c:	f406                	sd	ra,40(sp)
    8000469e:	f022                	sd	s0,32(sp)
    800046a0:	ec26                	sd	s1,24(sp)
    800046a2:	e84a                	sd	s2,16(sp)
    800046a4:	e44e                	sd	s3,8(sp)
    800046a6:	1800                	addi	s0,sp,48
    800046a8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046aa:	00850913          	addi	s2,a0,8
    800046ae:	854a                	mv	a0,s2
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	526080e7          	jalr	1318(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046b8:	409c                	lw	a5,0(s1)
    800046ba:	ef99                	bnez	a5,800046d8 <holdingsleep+0x3e>
    800046bc:	4481                	li	s1,0
  release(&lk->lk);
    800046be:	854a                	mv	a0,s2
    800046c0:	ffffc097          	auipc	ra,0xffffc
    800046c4:	5ca080e7          	jalr	1482(ra) # 80000c8a <release>
  return r;
}
    800046c8:	8526                	mv	a0,s1
    800046ca:	70a2                	ld	ra,40(sp)
    800046cc:	7402                	ld	s0,32(sp)
    800046ce:	64e2                	ld	s1,24(sp)
    800046d0:	6942                	ld	s2,16(sp)
    800046d2:	69a2                	ld	s3,8(sp)
    800046d4:	6145                	addi	sp,sp,48
    800046d6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046d8:	0284a983          	lw	s3,40(s1)
    800046dc:	ffffd097          	auipc	ra,0xffffd
    800046e0:	2a4080e7          	jalr	676(ra) # 80001980 <myproc>
    800046e4:	5144                	lw	s1,36(a0)
    800046e6:	413484b3          	sub	s1,s1,s3
    800046ea:	0014b493          	seqz	s1,s1
    800046ee:	bfc1                	j	800046be <holdingsleep+0x24>

00000000800046f0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046f0:	1141                	addi	sp,sp,-16
    800046f2:	e406                	sd	ra,8(sp)
    800046f4:	e022                	sd	s0,0(sp)
    800046f6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046f8:	00004597          	auipc	a1,0x4
    800046fc:	f8058593          	addi	a1,a1,-128 # 80008678 <syscalls+0x238>
    80004700:	0001e517          	auipc	a0,0x1e
    80004704:	b5850513          	addi	a0,a0,-1192 # 80022258 <ftable>
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	43e080e7          	jalr	1086(ra) # 80000b46 <initlock>
}
    80004710:	60a2                	ld	ra,8(sp)
    80004712:	6402                	ld	s0,0(sp)
    80004714:	0141                	addi	sp,sp,16
    80004716:	8082                	ret

0000000080004718 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004718:	1101                	addi	sp,sp,-32
    8000471a:	ec06                	sd	ra,24(sp)
    8000471c:	e822                	sd	s0,16(sp)
    8000471e:	e426                	sd	s1,8(sp)
    80004720:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004722:	0001e517          	auipc	a0,0x1e
    80004726:	b3650513          	addi	a0,a0,-1226 # 80022258 <ftable>
    8000472a:	ffffc097          	auipc	ra,0xffffc
    8000472e:	4ac080e7          	jalr	1196(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004732:	0001e497          	auipc	s1,0x1e
    80004736:	b3e48493          	addi	s1,s1,-1218 # 80022270 <ftable+0x18>
    8000473a:	0001f717          	auipc	a4,0x1f
    8000473e:	ad670713          	addi	a4,a4,-1322 # 80023210 <disk>
    if(f->ref == 0){
    80004742:	40dc                	lw	a5,4(s1)
    80004744:	cf99                	beqz	a5,80004762 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004746:	02848493          	addi	s1,s1,40
    8000474a:	fee49ce3          	bne	s1,a4,80004742 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000474e:	0001e517          	auipc	a0,0x1e
    80004752:	b0a50513          	addi	a0,a0,-1270 # 80022258 <ftable>
    80004756:	ffffc097          	auipc	ra,0xffffc
    8000475a:	534080e7          	jalr	1332(ra) # 80000c8a <release>
  return 0;
    8000475e:	4481                	li	s1,0
    80004760:	a819                	j	80004776 <filealloc+0x5e>
      f->ref = 1;
    80004762:	4785                	li	a5,1
    80004764:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004766:	0001e517          	auipc	a0,0x1e
    8000476a:	af250513          	addi	a0,a0,-1294 # 80022258 <ftable>
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	51c080e7          	jalr	1308(ra) # 80000c8a <release>
}
    80004776:	8526                	mv	a0,s1
    80004778:	60e2                	ld	ra,24(sp)
    8000477a:	6442                	ld	s0,16(sp)
    8000477c:	64a2                	ld	s1,8(sp)
    8000477e:	6105                	addi	sp,sp,32
    80004780:	8082                	ret

0000000080004782 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004782:	1101                	addi	sp,sp,-32
    80004784:	ec06                	sd	ra,24(sp)
    80004786:	e822                	sd	s0,16(sp)
    80004788:	e426                	sd	s1,8(sp)
    8000478a:	1000                	addi	s0,sp,32
    8000478c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000478e:	0001e517          	auipc	a0,0x1e
    80004792:	aca50513          	addi	a0,a0,-1334 # 80022258 <ftable>
    80004796:	ffffc097          	auipc	ra,0xffffc
    8000479a:	440080e7          	jalr	1088(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000479e:	40dc                	lw	a5,4(s1)
    800047a0:	02f05263          	blez	a5,800047c4 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047a4:	2785                	addiw	a5,a5,1
    800047a6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047a8:	0001e517          	auipc	a0,0x1e
    800047ac:	ab050513          	addi	a0,a0,-1360 # 80022258 <ftable>
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	4da080e7          	jalr	1242(ra) # 80000c8a <release>
  return f;
}
    800047b8:	8526                	mv	a0,s1
    800047ba:	60e2                	ld	ra,24(sp)
    800047bc:	6442                	ld	s0,16(sp)
    800047be:	64a2                	ld	s1,8(sp)
    800047c0:	6105                	addi	sp,sp,32
    800047c2:	8082                	ret
    panic("filedup");
    800047c4:	00004517          	auipc	a0,0x4
    800047c8:	ebc50513          	addi	a0,a0,-324 # 80008680 <syscalls+0x240>
    800047cc:	ffffc097          	auipc	ra,0xffffc
    800047d0:	d72080e7          	jalr	-654(ra) # 8000053e <panic>

00000000800047d4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047d4:	7139                	addi	sp,sp,-64
    800047d6:	fc06                	sd	ra,56(sp)
    800047d8:	f822                	sd	s0,48(sp)
    800047da:	f426                	sd	s1,40(sp)
    800047dc:	f04a                	sd	s2,32(sp)
    800047de:	ec4e                	sd	s3,24(sp)
    800047e0:	e852                	sd	s4,16(sp)
    800047e2:	e456                	sd	s5,8(sp)
    800047e4:	0080                	addi	s0,sp,64
    800047e6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047e8:	0001e517          	auipc	a0,0x1e
    800047ec:	a7050513          	addi	a0,a0,-1424 # 80022258 <ftable>
    800047f0:	ffffc097          	auipc	ra,0xffffc
    800047f4:	3e6080e7          	jalr	998(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047f8:	40dc                	lw	a5,4(s1)
    800047fa:	06f05163          	blez	a5,8000485c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047fe:	37fd                	addiw	a5,a5,-1
    80004800:	0007871b          	sext.w	a4,a5
    80004804:	c0dc                	sw	a5,4(s1)
    80004806:	06e04363          	bgtz	a4,8000486c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000480a:	0004a903          	lw	s2,0(s1)
    8000480e:	0094ca83          	lbu	s5,9(s1)
    80004812:	0104ba03          	ld	s4,16(s1)
    80004816:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000481a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000481e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004822:	0001e517          	auipc	a0,0x1e
    80004826:	a3650513          	addi	a0,a0,-1482 # 80022258 <ftable>
    8000482a:	ffffc097          	auipc	ra,0xffffc
    8000482e:	460080e7          	jalr	1120(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004832:	4785                	li	a5,1
    80004834:	04f90d63          	beq	s2,a5,8000488e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004838:	3979                	addiw	s2,s2,-2
    8000483a:	4785                	li	a5,1
    8000483c:	0527e063          	bltu	a5,s2,8000487c <fileclose+0xa8>
    begin_op();
    80004840:	00000097          	auipc	ra,0x0
    80004844:	ac8080e7          	jalr	-1336(ra) # 80004308 <begin_op>
    iput(ff.ip);
    80004848:	854e                	mv	a0,s3
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	2b6080e7          	jalr	694(ra) # 80003b00 <iput>
    end_op();
    80004852:	00000097          	auipc	ra,0x0
    80004856:	b36080e7          	jalr	-1226(ra) # 80004388 <end_op>
    8000485a:	a00d                	j	8000487c <fileclose+0xa8>
    panic("fileclose");
    8000485c:	00004517          	auipc	a0,0x4
    80004860:	e2c50513          	addi	a0,a0,-468 # 80008688 <syscalls+0x248>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	cda080e7          	jalr	-806(ra) # 8000053e <panic>
    release(&ftable.lock);
    8000486c:	0001e517          	auipc	a0,0x1e
    80004870:	9ec50513          	addi	a0,a0,-1556 # 80022258 <ftable>
    80004874:	ffffc097          	auipc	ra,0xffffc
    80004878:	416080e7          	jalr	1046(ra) # 80000c8a <release>
  }
}
    8000487c:	70e2                	ld	ra,56(sp)
    8000487e:	7442                	ld	s0,48(sp)
    80004880:	74a2                	ld	s1,40(sp)
    80004882:	7902                	ld	s2,32(sp)
    80004884:	69e2                	ld	s3,24(sp)
    80004886:	6a42                	ld	s4,16(sp)
    80004888:	6aa2                	ld	s5,8(sp)
    8000488a:	6121                	addi	sp,sp,64
    8000488c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000488e:	85d6                	mv	a1,s5
    80004890:	8552                	mv	a0,s4
    80004892:	00000097          	auipc	ra,0x0
    80004896:	34c080e7          	jalr	844(ra) # 80004bde <pipeclose>
    8000489a:	b7cd                	j	8000487c <fileclose+0xa8>

000000008000489c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000489c:	715d                	addi	sp,sp,-80
    8000489e:	e486                	sd	ra,72(sp)
    800048a0:	e0a2                	sd	s0,64(sp)
    800048a2:	fc26                	sd	s1,56(sp)
    800048a4:	f84a                	sd	s2,48(sp)
    800048a6:	f44e                	sd	s3,40(sp)
    800048a8:	0880                	addi	s0,sp,80
    800048aa:	84aa                	mv	s1,a0
    800048ac:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048ae:	ffffd097          	auipc	ra,0xffffd
    800048b2:	0d2080e7          	jalr	210(ra) # 80001980 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048b6:	409c                	lw	a5,0(s1)
    800048b8:	37f9                	addiw	a5,a5,-2
    800048ba:	4705                	li	a4,1
    800048bc:	04f76763          	bltu	a4,a5,8000490a <filestat+0x6e>
    800048c0:	892a                	mv	s2,a0
    ilock(f->ip);
    800048c2:	6c88                	ld	a0,24(s1)
    800048c4:	fffff097          	auipc	ra,0xfffff
    800048c8:	082080e7          	jalr	130(ra) # 80003946 <ilock>
    stati(f->ip, &st);
    800048cc:	fb840593          	addi	a1,s0,-72
    800048d0:	6c88                	ld	a0,24(s1)
    800048d2:	fffff097          	auipc	ra,0xfffff
    800048d6:	2fe080e7          	jalr	766(ra) # 80003bd0 <stati>
    iunlock(f->ip);
    800048da:	6c88                	ld	a0,24(s1)
    800048dc:	fffff097          	auipc	ra,0xfffff
    800048e0:	12c080e7          	jalr	300(ra) # 80003a08 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048e4:	46e1                	li	a3,24
    800048e6:	fb840613          	addi	a2,s0,-72
    800048ea:	85ce                	mv	a1,s3
    800048ec:	10093503          	ld	a0,256(s2)
    800048f0:	ffffd097          	auipc	ra,0xffffd
    800048f4:	d78080e7          	jalr	-648(ra) # 80001668 <copyout>
    800048f8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048fc:	60a6                	ld	ra,72(sp)
    800048fe:	6406                	ld	s0,64(sp)
    80004900:	74e2                	ld	s1,56(sp)
    80004902:	7942                	ld	s2,48(sp)
    80004904:	79a2                	ld	s3,40(sp)
    80004906:	6161                	addi	sp,sp,80
    80004908:	8082                	ret
  return -1;
    8000490a:	557d                	li	a0,-1
    8000490c:	bfc5                	j	800048fc <filestat+0x60>

000000008000490e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000490e:	7179                	addi	sp,sp,-48
    80004910:	f406                	sd	ra,40(sp)
    80004912:	f022                	sd	s0,32(sp)
    80004914:	ec26                	sd	s1,24(sp)
    80004916:	e84a                	sd	s2,16(sp)
    80004918:	e44e                	sd	s3,8(sp)
    8000491a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000491c:	00854783          	lbu	a5,8(a0)
    80004920:	c3d5                	beqz	a5,800049c4 <fileread+0xb6>
    80004922:	84aa                	mv	s1,a0
    80004924:	89ae                	mv	s3,a1
    80004926:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004928:	411c                	lw	a5,0(a0)
    8000492a:	4705                	li	a4,1
    8000492c:	04e78963          	beq	a5,a4,8000497e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004930:	470d                	li	a4,3
    80004932:	04e78d63          	beq	a5,a4,8000498c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004936:	4709                	li	a4,2
    80004938:	06e79e63          	bne	a5,a4,800049b4 <fileread+0xa6>
    ilock(f->ip);
    8000493c:	6d08                	ld	a0,24(a0)
    8000493e:	fffff097          	auipc	ra,0xfffff
    80004942:	008080e7          	jalr	8(ra) # 80003946 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004946:	874a                	mv	a4,s2
    80004948:	5094                	lw	a3,32(s1)
    8000494a:	864e                	mv	a2,s3
    8000494c:	4585                	li	a1,1
    8000494e:	6c88                	ld	a0,24(s1)
    80004950:	fffff097          	auipc	ra,0xfffff
    80004954:	2aa080e7          	jalr	682(ra) # 80003bfa <readi>
    80004958:	892a                	mv	s2,a0
    8000495a:	00a05563          	blez	a0,80004964 <fileread+0x56>
      f->off += r;
    8000495e:	509c                	lw	a5,32(s1)
    80004960:	9fa9                	addw	a5,a5,a0
    80004962:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004964:	6c88                	ld	a0,24(s1)
    80004966:	fffff097          	auipc	ra,0xfffff
    8000496a:	0a2080e7          	jalr	162(ra) # 80003a08 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000496e:	854a                	mv	a0,s2
    80004970:	70a2                	ld	ra,40(sp)
    80004972:	7402                	ld	s0,32(sp)
    80004974:	64e2                	ld	s1,24(sp)
    80004976:	6942                	ld	s2,16(sp)
    80004978:	69a2                	ld	s3,8(sp)
    8000497a:	6145                	addi	sp,sp,48
    8000497c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000497e:	6908                	ld	a0,16(a0)
    80004980:	00000097          	auipc	ra,0x0
    80004984:	3c6080e7          	jalr	966(ra) # 80004d46 <piperead>
    80004988:	892a                	mv	s2,a0
    8000498a:	b7d5                	j	8000496e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000498c:	02451783          	lh	a5,36(a0)
    80004990:	03079693          	slli	a3,a5,0x30
    80004994:	92c1                	srli	a3,a3,0x30
    80004996:	4725                	li	a4,9
    80004998:	02d76863          	bltu	a4,a3,800049c8 <fileread+0xba>
    8000499c:	0792                	slli	a5,a5,0x4
    8000499e:	0001e717          	auipc	a4,0x1e
    800049a2:	81a70713          	addi	a4,a4,-2022 # 800221b8 <devsw>
    800049a6:	97ba                	add	a5,a5,a4
    800049a8:	639c                	ld	a5,0(a5)
    800049aa:	c38d                	beqz	a5,800049cc <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049ac:	4505                	li	a0,1
    800049ae:	9782                	jalr	a5
    800049b0:	892a                	mv	s2,a0
    800049b2:	bf75                	j	8000496e <fileread+0x60>
    panic("fileread");
    800049b4:	00004517          	auipc	a0,0x4
    800049b8:	ce450513          	addi	a0,a0,-796 # 80008698 <syscalls+0x258>
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	b82080e7          	jalr	-1150(ra) # 8000053e <panic>
    return -1;
    800049c4:	597d                	li	s2,-1
    800049c6:	b765                	j	8000496e <fileread+0x60>
      return -1;
    800049c8:	597d                	li	s2,-1
    800049ca:	b755                	j	8000496e <fileread+0x60>
    800049cc:	597d                	li	s2,-1
    800049ce:	b745                	j	8000496e <fileread+0x60>

00000000800049d0 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800049d0:	715d                	addi	sp,sp,-80
    800049d2:	e486                	sd	ra,72(sp)
    800049d4:	e0a2                	sd	s0,64(sp)
    800049d6:	fc26                	sd	s1,56(sp)
    800049d8:	f84a                	sd	s2,48(sp)
    800049da:	f44e                	sd	s3,40(sp)
    800049dc:	f052                	sd	s4,32(sp)
    800049de:	ec56                	sd	s5,24(sp)
    800049e0:	e85a                	sd	s6,16(sp)
    800049e2:	e45e                	sd	s7,8(sp)
    800049e4:	e062                	sd	s8,0(sp)
    800049e6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049e8:	00954783          	lbu	a5,9(a0)
    800049ec:	10078663          	beqz	a5,80004af8 <filewrite+0x128>
    800049f0:	892a                	mv	s2,a0
    800049f2:	8aae                	mv	s5,a1
    800049f4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049f6:	411c                	lw	a5,0(a0)
    800049f8:	4705                	li	a4,1
    800049fa:	02e78263          	beq	a5,a4,80004a1e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049fe:	470d                	li	a4,3
    80004a00:	02e78663          	beq	a5,a4,80004a2c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a04:	4709                	li	a4,2
    80004a06:	0ee79163          	bne	a5,a4,80004ae8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a0a:	0ac05d63          	blez	a2,80004ac4 <filewrite+0xf4>
    int i = 0;
    80004a0e:	4981                	li	s3,0
    80004a10:	6b05                	lui	s6,0x1
    80004a12:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a16:	6b85                	lui	s7,0x1
    80004a18:	c00b8b9b          	addiw	s7,s7,-1024
    80004a1c:	a861                	j	80004ab4 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004a1e:	6908                	ld	a0,16(a0)
    80004a20:	00000097          	auipc	ra,0x0
    80004a24:	22e080e7          	jalr	558(ra) # 80004c4e <pipewrite>
    80004a28:	8a2a                	mv	s4,a0
    80004a2a:	a045                	j	80004aca <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a2c:	02451783          	lh	a5,36(a0)
    80004a30:	03079693          	slli	a3,a5,0x30
    80004a34:	92c1                	srli	a3,a3,0x30
    80004a36:	4725                	li	a4,9
    80004a38:	0cd76263          	bltu	a4,a3,80004afc <filewrite+0x12c>
    80004a3c:	0792                	slli	a5,a5,0x4
    80004a3e:	0001d717          	auipc	a4,0x1d
    80004a42:	77a70713          	addi	a4,a4,1914 # 800221b8 <devsw>
    80004a46:	97ba                	add	a5,a5,a4
    80004a48:	679c                	ld	a5,8(a5)
    80004a4a:	cbdd                	beqz	a5,80004b00 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a4c:	4505                	li	a0,1
    80004a4e:	9782                	jalr	a5
    80004a50:	8a2a                	mv	s4,a0
    80004a52:	a8a5                	j	80004aca <filewrite+0xfa>
    80004a54:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a58:	00000097          	auipc	ra,0x0
    80004a5c:	8b0080e7          	jalr	-1872(ra) # 80004308 <begin_op>
      ilock(f->ip);
    80004a60:	01893503          	ld	a0,24(s2)
    80004a64:	fffff097          	auipc	ra,0xfffff
    80004a68:	ee2080e7          	jalr	-286(ra) # 80003946 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a6c:	8762                	mv	a4,s8
    80004a6e:	02092683          	lw	a3,32(s2)
    80004a72:	01598633          	add	a2,s3,s5
    80004a76:	4585                	li	a1,1
    80004a78:	01893503          	ld	a0,24(s2)
    80004a7c:	fffff097          	auipc	ra,0xfffff
    80004a80:	276080e7          	jalr	630(ra) # 80003cf2 <writei>
    80004a84:	84aa                	mv	s1,a0
    80004a86:	00a05763          	blez	a0,80004a94 <filewrite+0xc4>
        f->off += r;
    80004a8a:	02092783          	lw	a5,32(s2)
    80004a8e:	9fa9                	addw	a5,a5,a0
    80004a90:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a94:	01893503          	ld	a0,24(s2)
    80004a98:	fffff097          	auipc	ra,0xfffff
    80004a9c:	f70080e7          	jalr	-144(ra) # 80003a08 <iunlock>
      end_op();
    80004aa0:	00000097          	auipc	ra,0x0
    80004aa4:	8e8080e7          	jalr	-1816(ra) # 80004388 <end_op>

      if(r != n1){
    80004aa8:	009c1f63          	bne	s8,s1,80004ac6 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004aac:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ab0:	0149db63          	bge	s3,s4,80004ac6 <filewrite+0xf6>
      int n1 = n - i;
    80004ab4:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004ab8:	84be                	mv	s1,a5
    80004aba:	2781                	sext.w	a5,a5
    80004abc:	f8fb5ce3          	bge	s6,a5,80004a54 <filewrite+0x84>
    80004ac0:	84de                	mv	s1,s7
    80004ac2:	bf49                	j	80004a54 <filewrite+0x84>
    int i = 0;
    80004ac4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004ac6:	013a1f63          	bne	s4,s3,80004ae4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004aca:	8552                	mv	a0,s4
    80004acc:	60a6                	ld	ra,72(sp)
    80004ace:	6406                	ld	s0,64(sp)
    80004ad0:	74e2                	ld	s1,56(sp)
    80004ad2:	7942                	ld	s2,48(sp)
    80004ad4:	79a2                	ld	s3,40(sp)
    80004ad6:	7a02                	ld	s4,32(sp)
    80004ad8:	6ae2                	ld	s5,24(sp)
    80004ada:	6b42                	ld	s6,16(sp)
    80004adc:	6ba2                	ld	s7,8(sp)
    80004ade:	6c02                	ld	s8,0(sp)
    80004ae0:	6161                	addi	sp,sp,80
    80004ae2:	8082                	ret
    ret = (i == n ? n : -1);
    80004ae4:	5a7d                	li	s4,-1
    80004ae6:	b7d5                	j	80004aca <filewrite+0xfa>
    panic("filewrite");
    80004ae8:	00004517          	auipc	a0,0x4
    80004aec:	bc050513          	addi	a0,a0,-1088 # 800086a8 <syscalls+0x268>
    80004af0:	ffffc097          	auipc	ra,0xffffc
    80004af4:	a4e080e7          	jalr	-1458(ra) # 8000053e <panic>
    return -1;
    80004af8:	5a7d                	li	s4,-1
    80004afa:	bfc1                	j	80004aca <filewrite+0xfa>
      return -1;
    80004afc:	5a7d                	li	s4,-1
    80004afe:	b7f1                	j	80004aca <filewrite+0xfa>
    80004b00:	5a7d                	li	s4,-1
    80004b02:	b7e1                	j	80004aca <filewrite+0xfa>

0000000080004b04 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b04:	7179                	addi	sp,sp,-48
    80004b06:	f406                	sd	ra,40(sp)
    80004b08:	f022                	sd	s0,32(sp)
    80004b0a:	ec26                	sd	s1,24(sp)
    80004b0c:	e84a                	sd	s2,16(sp)
    80004b0e:	e44e                	sd	s3,8(sp)
    80004b10:	e052                	sd	s4,0(sp)
    80004b12:	1800                	addi	s0,sp,48
    80004b14:	84aa                	mv	s1,a0
    80004b16:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b18:	0005b023          	sd	zero,0(a1)
    80004b1c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b20:	00000097          	auipc	ra,0x0
    80004b24:	bf8080e7          	jalr	-1032(ra) # 80004718 <filealloc>
    80004b28:	e088                	sd	a0,0(s1)
    80004b2a:	c551                	beqz	a0,80004bb6 <pipealloc+0xb2>
    80004b2c:	00000097          	auipc	ra,0x0
    80004b30:	bec080e7          	jalr	-1044(ra) # 80004718 <filealloc>
    80004b34:	00aa3023          	sd	a0,0(s4)
    80004b38:	c92d                	beqz	a0,80004baa <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b3a:	ffffc097          	auipc	ra,0xffffc
    80004b3e:	fac080e7          	jalr	-84(ra) # 80000ae6 <kalloc>
    80004b42:	892a                	mv	s2,a0
    80004b44:	c125                	beqz	a0,80004ba4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b46:	4985                	li	s3,1
    80004b48:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b4c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b50:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b54:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b58:	00004597          	auipc	a1,0x4
    80004b5c:	b6058593          	addi	a1,a1,-1184 # 800086b8 <syscalls+0x278>
    80004b60:	ffffc097          	auipc	ra,0xffffc
    80004b64:	fe6080e7          	jalr	-26(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004b68:	609c                	ld	a5,0(s1)
    80004b6a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b6e:	609c                	ld	a5,0(s1)
    80004b70:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b74:	609c                	ld	a5,0(s1)
    80004b76:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b7a:	609c                	ld	a5,0(s1)
    80004b7c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b80:	000a3783          	ld	a5,0(s4)
    80004b84:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b88:	000a3783          	ld	a5,0(s4)
    80004b8c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b90:	000a3783          	ld	a5,0(s4)
    80004b94:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b98:	000a3783          	ld	a5,0(s4)
    80004b9c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ba0:	4501                	li	a0,0
    80004ba2:	a025                	j	80004bca <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ba4:	6088                	ld	a0,0(s1)
    80004ba6:	e501                	bnez	a0,80004bae <pipealloc+0xaa>
    80004ba8:	a039                	j	80004bb6 <pipealloc+0xb2>
    80004baa:	6088                	ld	a0,0(s1)
    80004bac:	c51d                	beqz	a0,80004bda <pipealloc+0xd6>
    fileclose(*f0);
    80004bae:	00000097          	auipc	ra,0x0
    80004bb2:	c26080e7          	jalr	-986(ra) # 800047d4 <fileclose>
  if(*f1)
    80004bb6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bba:	557d                	li	a0,-1
  if(*f1)
    80004bbc:	c799                	beqz	a5,80004bca <pipealloc+0xc6>
    fileclose(*f1);
    80004bbe:	853e                	mv	a0,a5
    80004bc0:	00000097          	auipc	ra,0x0
    80004bc4:	c14080e7          	jalr	-1004(ra) # 800047d4 <fileclose>
  return -1;
    80004bc8:	557d                	li	a0,-1
}
    80004bca:	70a2                	ld	ra,40(sp)
    80004bcc:	7402                	ld	s0,32(sp)
    80004bce:	64e2                	ld	s1,24(sp)
    80004bd0:	6942                	ld	s2,16(sp)
    80004bd2:	69a2                	ld	s3,8(sp)
    80004bd4:	6a02                	ld	s4,0(sp)
    80004bd6:	6145                	addi	sp,sp,48
    80004bd8:	8082                	ret
  return -1;
    80004bda:	557d                	li	a0,-1
    80004bdc:	b7fd                	j	80004bca <pipealloc+0xc6>

0000000080004bde <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bde:	1101                	addi	sp,sp,-32
    80004be0:	ec06                	sd	ra,24(sp)
    80004be2:	e822                	sd	s0,16(sp)
    80004be4:	e426                	sd	s1,8(sp)
    80004be6:	e04a                	sd	s2,0(sp)
    80004be8:	1000                	addi	s0,sp,32
    80004bea:	84aa                	mv	s1,a0
    80004bec:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bee:	ffffc097          	auipc	ra,0xffffc
    80004bf2:	fe8080e7          	jalr	-24(ra) # 80000bd6 <acquire>
  if(writable){
    80004bf6:	02090d63          	beqz	s2,80004c30 <pipeclose+0x52>
    pi->writeopen = 0;
    80004bfa:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bfe:	21848513          	addi	a0,s1,536
    80004c02:	ffffd097          	auipc	ra,0xffffd
    80004c06:	528080e7          	jalr	1320(ra) # 8000212a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c0a:	2204b783          	ld	a5,544(s1)
    80004c0e:	eb95                	bnez	a5,80004c42 <pipeclose+0x64>
    release(&pi->lock);
    80004c10:	8526                	mv	a0,s1
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	078080e7          	jalr	120(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004c1a:	8526                	mv	a0,s1
    80004c1c:	ffffc097          	auipc	ra,0xffffc
    80004c20:	dce080e7          	jalr	-562(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004c24:	60e2                	ld	ra,24(sp)
    80004c26:	6442                	ld	s0,16(sp)
    80004c28:	64a2                	ld	s1,8(sp)
    80004c2a:	6902                	ld	s2,0(sp)
    80004c2c:	6105                	addi	sp,sp,32
    80004c2e:	8082                	ret
    pi->readopen = 0;
    80004c30:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c34:	21c48513          	addi	a0,s1,540
    80004c38:	ffffd097          	auipc	ra,0xffffd
    80004c3c:	4f2080e7          	jalr	1266(ra) # 8000212a <wakeup>
    80004c40:	b7e9                	j	80004c0a <pipeclose+0x2c>
    release(&pi->lock);
    80004c42:	8526                	mv	a0,s1
    80004c44:	ffffc097          	auipc	ra,0xffffc
    80004c48:	046080e7          	jalr	70(ra) # 80000c8a <release>
}
    80004c4c:	bfe1                	j	80004c24 <pipeclose+0x46>

0000000080004c4e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c4e:	711d                	addi	sp,sp,-96
    80004c50:	ec86                	sd	ra,88(sp)
    80004c52:	e8a2                	sd	s0,80(sp)
    80004c54:	e4a6                	sd	s1,72(sp)
    80004c56:	e0ca                	sd	s2,64(sp)
    80004c58:	fc4e                	sd	s3,56(sp)
    80004c5a:	f852                	sd	s4,48(sp)
    80004c5c:	f456                	sd	s5,40(sp)
    80004c5e:	f05a                	sd	s6,32(sp)
    80004c60:	ec5e                	sd	s7,24(sp)
    80004c62:	e862                	sd	s8,16(sp)
    80004c64:	1080                	addi	s0,sp,96
    80004c66:	84aa                	mv	s1,a0
    80004c68:	8aae                	mv	s5,a1
    80004c6a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c6c:	ffffd097          	auipc	ra,0xffffd
    80004c70:	d14080e7          	jalr	-748(ra) # 80001980 <myproc>
    80004c74:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c76:	8526                	mv	a0,s1
    80004c78:	ffffc097          	auipc	ra,0xffffc
    80004c7c:	f5e080e7          	jalr	-162(ra) # 80000bd6 <acquire>
  while(i < n){
    80004c80:	0b405663          	blez	s4,80004d2c <pipewrite+0xde>
  int i = 0;
    80004c84:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c86:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c88:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c8c:	21c48b93          	addi	s7,s1,540
    80004c90:	a089                	j	80004cd2 <pipewrite+0x84>
      release(&pi->lock);
    80004c92:	8526                	mv	a0,s1
    80004c94:	ffffc097          	auipc	ra,0xffffc
    80004c98:	ff6080e7          	jalr	-10(ra) # 80000c8a <release>
      return -1;
    80004c9c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c9e:	854a                	mv	a0,s2
    80004ca0:	60e6                	ld	ra,88(sp)
    80004ca2:	6446                	ld	s0,80(sp)
    80004ca4:	64a6                	ld	s1,72(sp)
    80004ca6:	6906                	ld	s2,64(sp)
    80004ca8:	79e2                	ld	s3,56(sp)
    80004caa:	7a42                	ld	s4,48(sp)
    80004cac:	7aa2                	ld	s5,40(sp)
    80004cae:	7b02                	ld	s6,32(sp)
    80004cb0:	6be2                	ld	s7,24(sp)
    80004cb2:	6c42                	ld	s8,16(sp)
    80004cb4:	6125                	addi	sp,sp,96
    80004cb6:	8082                	ret
      wakeup(&pi->nread);
    80004cb8:	8562                	mv	a0,s8
    80004cba:	ffffd097          	auipc	ra,0xffffd
    80004cbe:	470080e7          	jalr	1136(ra) # 8000212a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cc2:	85a6                	mv	a1,s1
    80004cc4:	855e                	mv	a0,s7
    80004cc6:	ffffd097          	auipc	ra,0xffffd
    80004cca:	3f6080e7          	jalr	1014(ra) # 800020bc <sleep>
  while(i < n){
    80004cce:	07495063          	bge	s2,s4,80004d2e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004cd2:	2204a783          	lw	a5,544(s1)
    80004cd6:	dfd5                	beqz	a5,80004c92 <pipewrite+0x44>
    80004cd8:	854e                	mv	a0,s3
    80004cda:	ffffd097          	auipc	ra,0xffffd
    80004cde:	6ee080e7          	jalr	1774(ra) # 800023c8 <killed>
    80004ce2:	f945                	bnez	a0,80004c92 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ce4:	2184a783          	lw	a5,536(s1)
    80004ce8:	21c4a703          	lw	a4,540(s1)
    80004cec:	2007879b          	addiw	a5,a5,512
    80004cf0:	fcf704e3          	beq	a4,a5,80004cb8 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cf4:	4685                	li	a3,1
    80004cf6:	01590633          	add	a2,s2,s5
    80004cfa:	faf40593          	addi	a1,s0,-81
    80004cfe:	1009b503          	ld	a0,256(s3)
    80004d02:	ffffd097          	auipc	ra,0xffffd
    80004d06:	9f2080e7          	jalr	-1550(ra) # 800016f4 <copyin>
    80004d0a:	03650263          	beq	a0,s6,80004d2e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d0e:	21c4a783          	lw	a5,540(s1)
    80004d12:	0017871b          	addiw	a4,a5,1
    80004d16:	20e4ae23          	sw	a4,540(s1)
    80004d1a:	1ff7f793          	andi	a5,a5,511
    80004d1e:	97a6                	add	a5,a5,s1
    80004d20:	faf44703          	lbu	a4,-81(s0)
    80004d24:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d28:	2905                	addiw	s2,s2,1
    80004d2a:	b755                	j	80004cce <pipewrite+0x80>
  int i = 0;
    80004d2c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d2e:	21848513          	addi	a0,s1,536
    80004d32:	ffffd097          	auipc	ra,0xffffd
    80004d36:	3f8080e7          	jalr	1016(ra) # 8000212a <wakeup>
  release(&pi->lock);
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	ffffc097          	auipc	ra,0xffffc
    80004d40:	f4e080e7          	jalr	-178(ra) # 80000c8a <release>
  return i;
    80004d44:	bfa9                	j	80004c9e <pipewrite+0x50>

0000000080004d46 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d46:	715d                	addi	sp,sp,-80
    80004d48:	e486                	sd	ra,72(sp)
    80004d4a:	e0a2                	sd	s0,64(sp)
    80004d4c:	fc26                	sd	s1,56(sp)
    80004d4e:	f84a                	sd	s2,48(sp)
    80004d50:	f44e                	sd	s3,40(sp)
    80004d52:	f052                	sd	s4,32(sp)
    80004d54:	ec56                	sd	s5,24(sp)
    80004d56:	e85a                	sd	s6,16(sp)
    80004d58:	0880                	addi	s0,sp,80
    80004d5a:	84aa                	mv	s1,a0
    80004d5c:	892e                	mv	s2,a1
    80004d5e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d60:	ffffd097          	auipc	ra,0xffffd
    80004d64:	c20080e7          	jalr	-992(ra) # 80001980 <myproc>
    80004d68:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	ffffc097          	auipc	ra,0xffffc
    80004d70:	e6a080e7          	jalr	-406(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d74:	2184a703          	lw	a4,536(s1)
    80004d78:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d7c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d80:	02f71763          	bne	a4,a5,80004dae <piperead+0x68>
    80004d84:	2244a783          	lw	a5,548(s1)
    80004d88:	c39d                	beqz	a5,80004dae <piperead+0x68>
    if(killed(pr)){
    80004d8a:	8552                	mv	a0,s4
    80004d8c:	ffffd097          	auipc	ra,0xffffd
    80004d90:	63c080e7          	jalr	1596(ra) # 800023c8 <killed>
    80004d94:	e941                	bnez	a0,80004e24 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d96:	85a6                	mv	a1,s1
    80004d98:	854e                	mv	a0,s3
    80004d9a:	ffffd097          	auipc	ra,0xffffd
    80004d9e:	322080e7          	jalr	802(ra) # 800020bc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004da2:	2184a703          	lw	a4,536(s1)
    80004da6:	21c4a783          	lw	a5,540(s1)
    80004daa:	fcf70de3          	beq	a4,a5,80004d84 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dae:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004db0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004db2:	05505363          	blez	s5,80004df8 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004db6:	2184a783          	lw	a5,536(s1)
    80004dba:	21c4a703          	lw	a4,540(s1)
    80004dbe:	02f70d63          	beq	a4,a5,80004df8 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dc2:	0017871b          	addiw	a4,a5,1
    80004dc6:	20e4ac23          	sw	a4,536(s1)
    80004dca:	1ff7f793          	andi	a5,a5,511
    80004dce:	97a6                	add	a5,a5,s1
    80004dd0:	0187c783          	lbu	a5,24(a5)
    80004dd4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dd8:	4685                	li	a3,1
    80004dda:	fbf40613          	addi	a2,s0,-65
    80004dde:	85ca                	mv	a1,s2
    80004de0:	100a3503          	ld	a0,256(s4)
    80004de4:	ffffd097          	auipc	ra,0xffffd
    80004de8:	884080e7          	jalr	-1916(ra) # 80001668 <copyout>
    80004dec:	01650663          	beq	a0,s6,80004df8 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004df0:	2985                	addiw	s3,s3,1
    80004df2:	0905                	addi	s2,s2,1
    80004df4:	fd3a91e3          	bne	s5,s3,80004db6 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004df8:	21c48513          	addi	a0,s1,540
    80004dfc:	ffffd097          	auipc	ra,0xffffd
    80004e00:	32e080e7          	jalr	814(ra) # 8000212a <wakeup>
  release(&pi->lock);
    80004e04:	8526                	mv	a0,s1
    80004e06:	ffffc097          	auipc	ra,0xffffc
    80004e0a:	e84080e7          	jalr	-380(ra) # 80000c8a <release>
  return i;
}
    80004e0e:	854e                	mv	a0,s3
    80004e10:	60a6                	ld	ra,72(sp)
    80004e12:	6406                	ld	s0,64(sp)
    80004e14:	74e2                	ld	s1,56(sp)
    80004e16:	7942                	ld	s2,48(sp)
    80004e18:	79a2                	ld	s3,40(sp)
    80004e1a:	7a02                	ld	s4,32(sp)
    80004e1c:	6ae2                	ld	s5,24(sp)
    80004e1e:	6b42                	ld	s6,16(sp)
    80004e20:	6161                	addi	sp,sp,80
    80004e22:	8082                	ret
      release(&pi->lock);
    80004e24:	8526                	mv	a0,s1
    80004e26:	ffffc097          	auipc	ra,0xffffc
    80004e2a:	e64080e7          	jalr	-412(ra) # 80000c8a <release>
      return -1;
    80004e2e:	59fd                	li	s3,-1
    80004e30:	bff9                	j	80004e0e <piperead+0xc8>

0000000080004e32 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e32:	1141                	addi	sp,sp,-16
    80004e34:	e422                	sd	s0,8(sp)
    80004e36:	0800                	addi	s0,sp,16
    80004e38:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e3a:	8905                	andi	a0,a0,1
    80004e3c:	c111                	beqz	a0,80004e40 <flags2perm+0xe>
      perm = PTE_X;
    80004e3e:	4521                	li	a0,8
    if(flags & 0x2)
    80004e40:	8b89                	andi	a5,a5,2
    80004e42:	c399                	beqz	a5,80004e48 <flags2perm+0x16>
      perm |= PTE_W;
    80004e44:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e48:	6422                	ld	s0,8(sp)
    80004e4a:	0141                	addi	sp,sp,16
    80004e4c:	8082                	ret

0000000080004e4e <exec>:

int
exec(char *path, char **argv)
{
    80004e4e:	de010113          	addi	sp,sp,-544
    80004e52:	20113c23          	sd	ra,536(sp)
    80004e56:	20813823          	sd	s0,528(sp)
    80004e5a:	20913423          	sd	s1,520(sp)
    80004e5e:	21213023          	sd	s2,512(sp)
    80004e62:	ffce                	sd	s3,504(sp)
    80004e64:	fbd2                	sd	s4,496(sp)
    80004e66:	f7d6                	sd	s5,488(sp)
    80004e68:	f3da                	sd	s6,480(sp)
    80004e6a:	efde                	sd	s7,472(sp)
    80004e6c:	ebe2                	sd	s8,464(sp)
    80004e6e:	e7e6                	sd	s9,456(sp)
    80004e70:	e3ea                	sd	s10,448(sp)
    80004e72:	ff6e                	sd	s11,440(sp)
    80004e74:	1400                	addi	s0,sp,544
    80004e76:	892a                	mv	s2,a0
    80004e78:	dea43423          	sd	a0,-536(s0)
    80004e7c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e80:	ffffd097          	auipc	ra,0xffffd
    80004e84:	b00080e7          	jalr	-1280(ra) # 80001980 <myproc>
    80004e88:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80004e8a:	ffffe097          	auipc	ra,0xffffe
    80004e8e:	86e080e7          	jalr	-1938(ra) # 800026f8 <mykthread>

  begin_op();
    80004e92:	fffff097          	auipc	ra,0xfffff
    80004e96:	476080e7          	jalr	1142(ra) # 80004308 <begin_op>

  if((ip = namei(path)) == 0){
    80004e9a:	854a                	mv	a0,s2
    80004e9c:	fffff097          	auipc	ra,0xfffff
    80004ea0:	250080e7          	jalr	592(ra) # 800040ec <namei>
    80004ea4:	c93d                	beqz	a0,80004f1a <exec+0xcc>
    80004ea6:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ea8:	fffff097          	auipc	ra,0xfffff
    80004eac:	a9e080e7          	jalr	-1378(ra) # 80003946 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004eb0:	04000713          	li	a4,64
    80004eb4:	4681                	li	a3,0
    80004eb6:	e5040613          	addi	a2,s0,-432
    80004eba:	4581                	li	a1,0
    80004ebc:	8556                	mv	a0,s5
    80004ebe:	fffff097          	auipc	ra,0xfffff
    80004ec2:	d3c080e7          	jalr	-708(ra) # 80003bfa <readi>
    80004ec6:	04000793          	li	a5,64
    80004eca:	00f51a63          	bne	a0,a5,80004ede <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004ece:	e5042703          	lw	a4,-432(s0)
    80004ed2:	464c47b7          	lui	a5,0x464c4
    80004ed6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004eda:	04f70663          	beq	a4,a5,80004f26 <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ede:	8556                	mv	a0,s5
    80004ee0:	fffff097          	auipc	ra,0xfffff
    80004ee4:	cc8080e7          	jalr	-824(ra) # 80003ba8 <iunlockput>
    end_op();
    80004ee8:	fffff097          	auipc	ra,0xfffff
    80004eec:	4a0080e7          	jalr	1184(ra) # 80004388 <end_op>
  }
  return -1;
    80004ef0:	557d                	li	a0,-1
}
    80004ef2:	21813083          	ld	ra,536(sp)
    80004ef6:	21013403          	ld	s0,528(sp)
    80004efa:	20813483          	ld	s1,520(sp)
    80004efe:	20013903          	ld	s2,512(sp)
    80004f02:	79fe                	ld	s3,504(sp)
    80004f04:	7a5e                	ld	s4,496(sp)
    80004f06:	7abe                	ld	s5,488(sp)
    80004f08:	7b1e                	ld	s6,480(sp)
    80004f0a:	6bfe                	ld	s7,472(sp)
    80004f0c:	6c5e                	ld	s8,464(sp)
    80004f0e:	6cbe                	ld	s9,456(sp)
    80004f10:	6d1e                	ld	s10,448(sp)
    80004f12:	7dfa                	ld	s11,440(sp)
    80004f14:	22010113          	addi	sp,sp,544
    80004f18:	8082                	ret
    end_op();
    80004f1a:	fffff097          	auipc	ra,0xfffff
    80004f1e:	46e080e7          	jalr	1134(ra) # 80004388 <end_op>
    return -1;
    80004f22:	557d                	li	a0,-1
    80004f24:	b7f9                	j	80004ef2 <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f26:	8526                	mv	a0,s1
    80004f28:	ffffd097          	auipc	ra,0xffffd
    80004f2c:	ada080e7          	jalr	-1318(ra) # 80001a02 <proc_pagetable>
    80004f30:	8b2a                	mv	s6,a0
    80004f32:	d555                	beqz	a0,80004ede <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f34:	e7042783          	lw	a5,-400(s0)
    80004f38:	e8845703          	lhu	a4,-376(s0)
    80004f3c:	c735                	beqz	a4,80004fa8 <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f3e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f40:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f44:	6a05                	lui	s4,0x1
    80004f46:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f4a:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f4e:	6d85                	lui	s11,0x1
    80004f50:	7d7d                	lui	s10,0xfffff
    80004f52:	a4a9                	j	8000519c <exec+0x34e>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f54:	00003517          	auipc	a0,0x3
    80004f58:	76c50513          	addi	a0,a0,1900 # 800086c0 <syscalls+0x280>
    80004f5c:	ffffb097          	auipc	ra,0xffffb
    80004f60:	5e2080e7          	jalr	1506(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f64:	874a                	mv	a4,s2
    80004f66:	009c86bb          	addw	a3,s9,s1
    80004f6a:	4581                	li	a1,0
    80004f6c:	8556                	mv	a0,s5
    80004f6e:	fffff097          	auipc	ra,0xfffff
    80004f72:	c8c080e7          	jalr	-884(ra) # 80003bfa <readi>
    80004f76:	2501                	sext.w	a0,a0
    80004f78:	1aa91f63          	bne	s2,a0,80005136 <exec+0x2e8>
  for(i = 0; i < sz; i += PGSIZE){
    80004f7c:	009d84bb          	addw	s1,s11,s1
    80004f80:	013d09bb          	addw	s3,s10,s3
    80004f84:	1f74fc63          	bgeu	s1,s7,8000517c <exec+0x32e>
    pa = walkaddr(pagetable, va + i);
    80004f88:	02049593          	slli	a1,s1,0x20
    80004f8c:	9181                	srli	a1,a1,0x20
    80004f8e:	95e2                	add	a1,a1,s8
    80004f90:	855a                	mv	a0,s6
    80004f92:	ffffc097          	auipc	ra,0xffffc
    80004f96:	0ca080e7          	jalr	202(ra) # 8000105c <walkaddr>
    80004f9a:	862a                	mv	a2,a0
    if(pa == 0)
    80004f9c:	dd45                	beqz	a0,80004f54 <exec+0x106>
      n = PGSIZE;
    80004f9e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004fa0:	fd49f2e3          	bgeu	s3,s4,80004f64 <exec+0x116>
      n = sz - i;
    80004fa4:	894e                	mv	s2,s3
    80004fa6:	bf7d                	j	80004f64 <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fa8:	4901                	li	s2,0
  iunlockput(ip);
    80004faa:	8556                	mv	a0,s5
    80004fac:	fffff097          	auipc	ra,0xfffff
    80004fb0:	bfc080e7          	jalr	-1028(ra) # 80003ba8 <iunlockput>
  end_op();
    80004fb4:	fffff097          	auipc	ra,0xfffff
    80004fb8:	3d4080e7          	jalr	980(ra) # 80004388 <end_op>
  p = myproc();
    80004fbc:	ffffd097          	auipc	ra,0xffffd
    80004fc0:	9c4080e7          	jalr	-1596(ra) # 80001980 <myproc>
    80004fc4:	8baa                	mv	s7,a0
  kt = mykthread();
    80004fc6:	ffffd097          	auipc	ra,0xffffd
    80004fca:	732080e7          	jalr	1842(ra) # 800026f8 <mykthread>
    80004fce:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004fd0:	0f8bbd83          	ld	s11,248(s7) # 10f8 <_entry-0x7fffef08>
  sz = PGROUNDUP(sz);
    80004fd4:	6785                	lui	a5,0x1
    80004fd6:	17fd                	addi	a5,a5,-1
    80004fd8:	993e                	add	s2,s2,a5
    80004fda:	77fd                	lui	a5,0xfffff
    80004fdc:	00f977b3          	and	a5,s2,a5
    80004fe0:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fe4:	4691                	li	a3,4
    80004fe6:	6609                	lui	a2,0x2
    80004fe8:	963e                	add	a2,a2,a5
    80004fea:	85be                	mv	a1,a5
    80004fec:	855a                	mv	a0,s6
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	422080e7          	jalr	1058(ra) # 80001410 <uvmalloc>
    80004ff6:	8c2a                	mv	s8,a0
  ip = 0;
    80004ff8:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004ffa:	12050e63          	beqz	a0,80005136 <exec+0x2e8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ffe:	75f9                	lui	a1,0xffffe
    80005000:	95aa                	add	a1,a1,a0
    80005002:	855a                	mv	a0,s6
    80005004:	ffffc097          	auipc	ra,0xffffc
    80005008:	632080e7          	jalr	1586(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    8000500c:	7afd                	lui	s5,0xfffff
    8000500e:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005010:	df043783          	ld	a5,-528(s0)
    80005014:	6388                	ld	a0,0(a5)
    80005016:	c925                	beqz	a0,80005086 <exec+0x238>
    80005018:	e9040993          	addi	s3,s0,-368
    8000501c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005020:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005022:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005024:	ffffc097          	auipc	ra,0xffffc
    80005028:	e2a080e7          	jalr	-470(ra) # 80000e4e <strlen>
    8000502c:	0015079b          	addiw	a5,a0,1
    80005030:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005034:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005038:	13596663          	bltu	s2,s5,80005164 <exec+0x316>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000503c:	df043783          	ld	a5,-528(s0)
    80005040:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffdbcb0>
    80005044:	8552                	mv	a0,s4
    80005046:	ffffc097          	auipc	ra,0xffffc
    8000504a:	e08080e7          	jalr	-504(ra) # 80000e4e <strlen>
    8000504e:	0015069b          	addiw	a3,a0,1
    80005052:	8652                	mv	a2,s4
    80005054:	85ca                	mv	a1,s2
    80005056:	855a                	mv	a0,s6
    80005058:	ffffc097          	auipc	ra,0xffffc
    8000505c:	610080e7          	jalr	1552(ra) # 80001668 <copyout>
    80005060:	10054663          	bltz	a0,8000516c <exec+0x31e>
    ustack[argc] = sp;
    80005064:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005068:	0485                	addi	s1,s1,1
    8000506a:	df043783          	ld	a5,-528(s0)
    8000506e:	07a1                	addi	a5,a5,8
    80005070:	def43823          	sd	a5,-528(s0)
    80005074:	6388                	ld	a0,0(a5)
    80005076:	c911                	beqz	a0,8000508a <exec+0x23c>
    if(argc >= MAXARG)
    80005078:	09a1                	addi	s3,s3,8
    8000507a:	fb3c95e3          	bne	s9,s3,80005024 <exec+0x1d6>
  sz = sz1;
    8000507e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005082:	4a81                	li	s5,0
    80005084:	a84d                	j	80005136 <exec+0x2e8>
  sp = sz;
    80005086:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005088:	4481                	li	s1,0
  ustack[argc] = 0;
    8000508a:	00349793          	slli	a5,s1,0x3
    8000508e:	f9040713          	addi	a4,s0,-112
    80005092:	97ba                	add	a5,a5,a4
    80005094:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005098:	00148693          	addi	a3,s1,1
    8000509c:	068e                	slli	a3,a3,0x3
    8000509e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050a2:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050a6:	01597663          	bgeu	s2,s5,800050b2 <exec+0x264>
  sz = sz1;
    800050aa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050ae:	4a81                	li	s5,0
    800050b0:	a059                	j	80005136 <exec+0x2e8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050b2:	e9040613          	addi	a2,s0,-368
    800050b6:	85ca                	mv	a1,s2
    800050b8:	855a                	mv	a0,s6
    800050ba:	ffffc097          	auipc	ra,0xffffc
    800050be:	5ae080e7          	jalr	1454(ra) # 80001668 <copyout>
    800050c2:	0a054963          	bltz	a0,80005174 <exec+0x326>
  kt->trapframe->a1 = sp;
    800050c6:	0b8d3783          	ld	a5,184(s10) # fffffffffffff0b8 <end+0xffffffff7ffdbd68>
    800050ca:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050ce:	de843783          	ld	a5,-536(s0)
    800050d2:	0007c703          	lbu	a4,0(a5)
    800050d6:	cf11                	beqz	a4,800050f2 <exec+0x2a4>
    800050d8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050da:	02f00693          	li	a3,47
    800050de:	a039                	j	800050ec <exec+0x29e>
      last = s+1;
    800050e0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050e4:	0785                	addi	a5,a5,1
    800050e6:	fff7c703          	lbu	a4,-1(a5)
    800050ea:	c701                	beqz	a4,800050f2 <exec+0x2a4>
    if(*s == '/')
    800050ec:	fed71ce3          	bne	a4,a3,800050e4 <exec+0x296>
    800050f0:	bfc5                	j	800050e0 <exec+0x292>
  safestrcpy(p->name, last, sizeof(p->name));
    800050f2:	4641                	li	a2,16
    800050f4:	de843583          	ld	a1,-536(s0)
    800050f8:	190b8513          	addi	a0,s7,400
    800050fc:	ffffc097          	auipc	ra,0xffffc
    80005100:	d20080e7          	jalr	-736(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005104:	100bb503          	ld	a0,256(s7)
  p->pagetable = pagetable;
    80005108:	116bb023          	sd	s6,256(s7)
  p->sz = sz;
    8000510c:	0f8bbc23          	sd	s8,248(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    80005110:	0b8d3783          	ld	a5,184(s10)
    80005114:	e6843703          	ld	a4,-408(s0)
    80005118:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    8000511a:	0b8d3783          	ld	a5,184(s10)
    8000511e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005122:	85ee                	mv	a1,s11
    80005124:	ffffd097          	auipc	ra,0xffffd
    80005128:	97a080e7          	jalr	-1670(ra) # 80001a9e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000512c:	0004851b          	sext.w	a0,s1
    80005130:	b3c9                	j	80004ef2 <exec+0xa4>
    80005132:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005136:	df843583          	ld	a1,-520(s0)
    8000513a:	855a                	mv	a0,s6
    8000513c:	ffffd097          	auipc	ra,0xffffd
    80005140:	962080e7          	jalr	-1694(ra) # 80001a9e <proc_freepagetable>
  if(ip){
    80005144:	d80a9de3          	bnez	s5,80004ede <exec+0x90>
  return -1;
    80005148:	557d                	li	a0,-1
    8000514a:	b365                	j	80004ef2 <exec+0xa4>
    8000514c:	df243c23          	sd	s2,-520(s0)
    80005150:	b7dd                	j	80005136 <exec+0x2e8>
    80005152:	df243c23          	sd	s2,-520(s0)
    80005156:	b7c5                	j	80005136 <exec+0x2e8>
    80005158:	df243c23          	sd	s2,-520(s0)
    8000515c:	bfe9                	j	80005136 <exec+0x2e8>
    8000515e:	df243c23          	sd	s2,-520(s0)
    80005162:	bfd1                	j	80005136 <exec+0x2e8>
  sz = sz1;
    80005164:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005168:	4a81                	li	s5,0
    8000516a:	b7f1                	j	80005136 <exec+0x2e8>
  sz = sz1;
    8000516c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005170:	4a81                	li	s5,0
    80005172:	b7d1                	j	80005136 <exec+0x2e8>
  sz = sz1;
    80005174:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005178:	4a81                	li	s5,0
    8000517a:	bf75                	j	80005136 <exec+0x2e8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000517c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005180:	e0843783          	ld	a5,-504(s0)
    80005184:	0017869b          	addiw	a3,a5,1
    80005188:	e0d43423          	sd	a3,-504(s0)
    8000518c:	e0043783          	ld	a5,-512(s0)
    80005190:	0387879b          	addiw	a5,a5,56
    80005194:	e8845703          	lhu	a4,-376(s0)
    80005198:	e0e6d9e3          	bge	a3,a4,80004faa <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000519c:	2781                	sext.w	a5,a5
    8000519e:	e0f43023          	sd	a5,-512(s0)
    800051a2:	03800713          	li	a4,56
    800051a6:	86be                	mv	a3,a5
    800051a8:	e1840613          	addi	a2,s0,-488
    800051ac:	4581                	li	a1,0
    800051ae:	8556                	mv	a0,s5
    800051b0:	fffff097          	auipc	ra,0xfffff
    800051b4:	a4a080e7          	jalr	-1462(ra) # 80003bfa <readi>
    800051b8:	03800793          	li	a5,56
    800051bc:	f6f51be3          	bne	a0,a5,80005132 <exec+0x2e4>
    if(ph.type != ELF_PROG_LOAD)
    800051c0:	e1842783          	lw	a5,-488(s0)
    800051c4:	4705                	li	a4,1
    800051c6:	fae79de3          	bne	a5,a4,80005180 <exec+0x332>
    if(ph.memsz < ph.filesz)
    800051ca:	e4043483          	ld	s1,-448(s0)
    800051ce:	e3843783          	ld	a5,-456(s0)
    800051d2:	f6f4ede3          	bltu	s1,a5,8000514c <exec+0x2fe>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051d6:	e2843783          	ld	a5,-472(s0)
    800051da:	94be                	add	s1,s1,a5
    800051dc:	f6f4ebe3          	bltu	s1,a5,80005152 <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    800051e0:	de043703          	ld	a4,-544(s0)
    800051e4:	8ff9                	and	a5,a5,a4
    800051e6:	fbad                	bnez	a5,80005158 <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051e8:	e1c42503          	lw	a0,-484(s0)
    800051ec:	00000097          	auipc	ra,0x0
    800051f0:	c46080e7          	jalr	-954(ra) # 80004e32 <flags2perm>
    800051f4:	86aa                	mv	a3,a0
    800051f6:	8626                	mv	a2,s1
    800051f8:	85ca                	mv	a1,s2
    800051fa:	855a                	mv	a0,s6
    800051fc:	ffffc097          	auipc	ra,0xffffc
    80005200:	214080e7          	jalr	532(ra) # 80001410 <uvmalloc>
    80005204:	dea43c23          	sd	a0,-520(s0)
    80005208:	d939                	beqz	a0,8000515e <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000520a:	e2843c03          	ld	s8,-472(s0)
    8000520e:	e2042c83          	lw	s9,-480(s0)
    80005212:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005216:	f60b83e3          	beqz	s7,8000517c <exec+0x32e>
    8000521a:	89de                	mv	s3,s7
    8000521c:	4481                	li	s1,0
    8000521e:	b3ad                	j	80004f88 <exec+0x13a>

0000000080005220 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005220:	7179                	addi	sp,sp,-48
    80005222:	f406                	sd	ra,40(sp)
    80005224:	f022                	sd	s0,32(sp)
    80005226:	ec26                	sd	s1,24(sp)
    80005228:	e84a                	sd	s2,16(sp)
    8000522a:	1800                	addi	s0,sp,48
    8000522c:	892e                	mv	s2,a1
    8000522e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005230:	fdc40593          	addi	a1,s0,-36
    80005234:	ffffe097          	auipc	ra,0xffffe
    80005238:	b96080e7          	jalr	-1130(ra) # 80002dca <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000523c:	fdc42703          	lw	a4,-36(s0)
    80005240:	47bd                	li	a5,15
    80005242:	02e7eb63          	bltu	a5,a4,80005278 <argfd+0x58>
    80005246:	ffffc097          	auipc	ra,0xffffc
    8000524a:	73a080e7          	jalr	1850(ra) # 80001980 <myproc>
    8000524e:	fdc42703          	lw	a4,-36(s0)
    80005252:	02070793          	addi	a5,a4,32
    80005256:	078e                	slli	a5,a5,0x3
    80005258:	953e                	add	a0,a0,a5
    8000525a:	651c                	ld	a5,8(a0)
    8000525c:	c385                	beqz	a5,8000527c <argfd+0x5c>
    return -1;
  if(pfd)
    8000525e:	00090463          	beqz	s2,80005266 <argfd+0x46>
    *pfd = fd;
    80005262:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005266:	4501                	li	a0,0
  if(pf)
    80005268:	c091                	beqz	s1,8000526c <argfd+0x4c>
    *pf = f;
    8000526a:	e09c                	sd	a5,0(s1)
}
    8000526c:	70a2                	ld	ra,40(sp)
    8000526e:	7402                	ld	s0,32(sp)
    80005270:	64e2                	ld	s1,24(sp)
    80005272:	6942                	ld	s2,16(sp)
    80005274:	6145                	addi	sp,sp,48
    80005276:	8082                	ret
    return -1;
    80005278:	557d                	li	a0,-1
    8000527a:	bfcd                	j	8000526c <argfd+0x4c>
    8000527c:	557d                	li	a0,-1
    8000527e:	b7fd                	j	8000526c <argfd+0x4c>

0000000080005280 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005280:	1101                	addi	sp,sp,-32
    80005282:	ec06                	sd	ra,24(sp)
    80005284:	e822                	sd	s0,16(sp)
    80005286:	e426                	sd	s1,8(sp)
    80005288:	1000                	addi	s0,sp,32
    8000528a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000528c:	ffffc097          	auipc	ra,0xffffc
    80005290:	6f4080e7          	jalr	1780(ra) # 80001980 <myproc>
    80005294:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005296:	10850793          	addi	a5,a0,264
    8000529a:	4501                	li	a0,0
    8000529c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000529e:	6398                	ld	a4,0(a5)
    800052a0:	cb19                	beqz	a4,800052b6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052a2:	2505                	addiw	a0,a0,1
    800052a4:	07a1                	addi	a5,a5,8
    800052a6:	fed51ce3          	bne	a0,a3,8000529e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052aa:	557d                	li	a0,-1
}
    800052ac:	60e2                	ld	ra,24(sp)
    800052ae:	6442                	ld	s0,16(sp)
    800052b0:	64a2                	ld	s1,8(sp)
    800052b2:	6105                	addi	sp,sp,32
    800052b4:	8082                	ret
      p->ofile[fd] = f;
    800052b6:	02050793          	addi	a5,a0,32
    800052ba:	078e                	slli	a5,a5,0x3
    800052bc:	963e                	add	a2,a2,a5
    800052be:	e604                	sd	s1,8(a2)
      return fd;
    800052c0:	b7f5                	j	800052ac <fdalloc+0x2c>

00000000800052c2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052c2:	715d                	addi	sp,sp,-80
    800052c4:	e486                	sd	ra,72(sp)
    800052c6:	e0a2                	sd	s0,64(sp)
    800052c8:	fc26                	sd	s1,56(sp)
    800052ca:	f84a                	sd	s2,48(sp)
    800052cc:	f44e                	sd	s3,40(sp)
    800052ce:	f052                	sd	s4,32(sp)
    800052d0:	ec56                	sd	s5,24(sp)
    800052d2:	e85a                	sd	s6,16(sp)
    800052d4:	0880                	addi	s0,sp,80
    800052d6:	8b2e                	mv	s6,a1
    800052d8:	89b2                	mv	s3,a2
    800052da:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052dc:	fb040593          	addi	a1,s0,-80
    800052e0:	fffff097          	auipc	ra,0xfffff
    800052e4:	e2a080e7          	jalr	-470(ra) # 8000410a <nameiparent>
    800052e8:	84aa                	mv	s1,a0
    800052ea:	14050f63          	beqz	a0,80005448 <create+0x186>
    return 0;

  ilock(dp);
    800052ee:	ffffe097          	auipc	ra,0xffffe
    800052f2:	658080e7          	jalr	1624(ra) # 80003946 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052f6:	4601                	li	a2,0
    800052f8:	fb040593          	addi	a1,s0,-80
    800052fc:	8526                	mv	a0,s1
    800052fe:	fffff097          	auipc	ra,0xfffff
    80005302:	b2c080e7          	jalr	-1236(ra) # 80003e2a <dirlookup>
    80005306:	8aaa                	mv	s5,a0
    80005308:	c931                	beqz	a0,8000535c <create+0x9a>
    iunlockput(dp);
    8000530a:	8526                	mv	a0,s1
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	89c080e7          	jalr	-1892(ra) # 80003ba8 <iunlockput>
    ilock(ip);
    80005314:	8556                	mv	a0,s5
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	630080e7          	jalr	1584(ra) # 80003946 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000531e:	000b059b          	sext.w	a1,s6
    80005322:	4789                	li	a5,2
    80005324:	02f59563          	bne	a1,a5,8000534e <create+0x8c>
    80005328:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbcf4>
    8000532c:	37f9                	addiw	a5,a5,-2
    8000532e:	17c2                	slli	a5,a5,0x30
    80005330:	93c1                	srli	a5,a5,0x30
    80005332:	4705                	li	a4,1
    80005334:	00f76d63          	bltu	a4,a5,8000534e <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005338:	8556                	mv	a0,s5
    8000533a:	60a6                	ld	ra,72(sp)
    8000533c:	6406                	ld	s0,64(sp)
    8000533e:	74e2                	ld	s1,56(sp)
    80005340:	7942                	ld	s2,48(sp)
    80005342:	79a2                	ld	s3,40(sp)
    80005344:	7a02                	ld	s4,32(sp)
    80005346:	6ae2                	ld	s5,24(sp)
    80005348:	6b42                	ld	s6,16(sp)
    8000534a:	6161                	addi	sp,sp,80
    8000534c:	8082                	ret
    iunlockput(ip);
    8000534e:	8556                	mv	a0,s5
    80005350:	fffff097          	auipc	ra,0xfffff
    80005354:	858080e7          	jalr	-1960(ra) # 80003ba8 <iunlockput>
    return 0;
    80005358:	4a81                	li	s5,0
    8000535a:	bff9                	j	80005338 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000535c:	85da                	mv	a1,s6
    8000535e:	4088                	lw	a0,0(s1)
    80005360:	ffffe097          	auipc	ra,0xffffe
    80005364:	44a080e7          	jalr	1098(ra) # 800037aa <ialloc>
    80005368:	8a2a                	mv	s4,a0
    8000536a:	c539                	beqz	a0,800053b8 <create+0xf6>
  ilock(ip);
    8000536c:	ffffe097          	auipc	ra,0xffffe
    80005370:	5da080e7          	jalr	1498(ra) # 80003946 <ilock>
  ip->major = major;
    80005374:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005378:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000537c:	4905                	li	s2,1
    8000537e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005382:	8552                	mv	a0,s4
    80005384:	ffffe097          	auipc	ra,0xffffe
    80005388:	4f8080e7          	jalr	1272(ra) # 8000387c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000538c:	000b059b          	sext.w	a1,s6
    80005390:	03258b63          	beq	a1,s2,800053c6 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005394:	004a2603          	lw	a2,4(s4)
    80005398:	fb040593          	addi	a1,s0,-80
    8000539c:	8526                	mv	a0,s1
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	c9c080e7          	jalr	-868(ra) # 8000403a <dirlink>
    800053a6:	06054f63          	bltz	a0,80005424 <create+0x162>
  iunlockput(dp);
    800053aa:	8526                	mv	a0,s1
    800053ac:	ffffe097          	auipc	ra,0xffffe
    800053b0:	7fc080e7          	jalr	2044(ra) # 80003ba8 <iunlockput>
  return ip;
    800053b4:	8ad2                	mv	s5,s4
    800053b6:	b749                	j	80005338 <create+0x76>
    iunlockput(dp);
    800053b8:	8526                	mv	a0,s1
    800053ba:	ffffe097          	auipc	ra,0xffffe
    800053be:	7ee080e7          	jalr	2030(ra) # 80003ba8 <iunlockput>
    return 0;
    800053c2:	8ad2                	mv	s5,s4
    800053c4:	bf95                	j	80005338 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053c6:	004a2603          	lw	a2,4(s4)
    800053ca:	00003597          	auipc	a1,0x3
    800053ce:	31658593          	addi	a1,a1,790 # 800086e0 <syscalls+0x2a0>
    800053d2:	8552                	mv	a0,s4
    800053d4:	fffff097          	auipc	ra,0xfffff
    800053d8:	c66080e7          	jalr	-922(ra) # 8000403a <dirlink>
    800053dc:	04054463          	bltz	a0,80005424 <create+0x162>
    800053e0:	40d0                	lw	a2,4(s1)
    800053e2:	00003597          	auipc	a1,0x3
    800053e6:	30658593          	addi	a1,a1,774 # 800086e8 <syscalls+0x2a8>
    800053ea:	8552                	mv	a0,s4
    800053ec:	fffff097          	auipc	ra,0xfffff
    800053f0:	c4e080e7          	jalr	-946(ra) # 8000403a <dirlink>
    800053f4:	02054863          	bltz	a0,80005424 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800053f8:	004a2603          	lw	a2,4(s4)
    800053fc:	fb040593          	addi	a1,s0,-80
    80005400:	8526                	mv	a0,s1
    80005402:	fffff097          	auipc	ra,0xfffff
    80005406:	c38080e7          	jalr	-968(ra) # 8000403a <dirlink>
    8000540a:	00054d63          	bltz	a0,80005424 <create+0x162>
    dp->nlink++;  // for ".."
    8000540e:	04a4d783          	lhu	a5,74(s1)
    80005412:	2785                	addiw	a5,a5,1
    80005414:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005418:	8526                	mv	a0,s1
    8000541a:	ffffe097          	auipc	ra,0xffffe
    8000541e:	462080e7          	jalr	1122(ra) # 8000387c <iupdate>
    80005422:	b761                	j	800053aa <create+0xe8>
  ip->nlink = 0;
    80005424:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005428:	8552                	mv	a0,s4
    8000542a:	ffffe097          	auipc	ra,0xffffe
    8000542e:	452080e7          	jalr	1106(ra) # 8000387c <iupdate>
  iunlockput(ip);
    80005432:	8552                	mv	a0,s4
    80005434:	ffffe097          	auipc	ra,0xffffe
    80005438:	774080e7          	jalr	1908(ra) # 80003ba8 <iunlockput>
  iunlockput(dp);
    8000543c:	8526                	mv	a0,s1
    8000543e:	ffffe097          	auipc	ra,0xffffe
    80005442:	76a080e7          	jalr	1898(ra) # 80003ba8 <iunlockput>
  return 0;
    80005446:	bdcd                	j	80005338 <create+0x76>
    return 0;
    80005448:	8aaa                	mv	s5,a0
    8000544a:	b5fd                	j	80005338 <create+0x76>

000000008000544c <sys_dup>:
{
    8000544c:	7179                	addi	sp,sp,-48
    8000544e:	f406                	sd	ra,40(sp)
    80005450:	f022                	sd	s0,32(sp)
    80005452:	ec26                	sd	s1,24(sp)
    80005454:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005456:	fd840613          	addi	a2,s0,-40
    8000545a:	4581                	li	a1,0
    8000545c:	4501                	li	a0,0
    8000545e:	00000097          	auipc	ra,0x0
    80005462:	dc2080e7          	jalr	-574(ra) # 80005220 <argfd>
    return -1;
    80005466:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005468:	02054363          	bltz	a0,8000548e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000546c:	fd843503          	ld	a0,-40(s0)
    80005470:	00000097          	auipc	ra,0x0
    80005474:	e10080e7          	jalr	-496(ra) # 80005280 <fdalloc>
    80005478:	84aa                	mv	s1,a0
    return -1;
    8000547a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000547c:	00054963          	bltz	a0,8000548e <sys_dup+0x42>
  filedup(f);
    80005480:	fd843503          	ld	a0,-40(s0)
    80005484:	fffff097          	auipc	ra,0xfffff
    80005488:	2fe080e7          	jalr	766(ra) # 80004782 <filedup>
  return fd;
    8000548c:	87a6                	mv	a5,s1
}
    8000548e:	853e                	mv	a0,a5
    80005490:	70a2                	ld	ra,40(sp)
    80005492:	7402                	ld	s0,32(sp)
    80005494:	64e2                	ld	s1,24(sp)
    80005496:	6145                	addi	sp,sp,48
    80005498:	8082                	ret

000000008000549a <sys_read>:
{
    8000549a:	7179                	addi	sp,sp,-48
    8000549c:	f406                	sd	ra,40(sp)
    8000549e:	f022                	sd	s0,32(sp)
    800054a0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054a2:	fd840593          	addi	a1,s0,-40
    800054a6:	4505                	li	a0,1
    800054a8:	ffffe097          	auipc	ra,0xffffe
    800054ac:	942080e7          	jalr	-1726(ra) # 80002dea <argaddr>
  argint(2, &n);
    800054b0:	fe440593          	addi	a1,s0,-28
    800054b4:	4509                	li	a0,2
    800054b6:	ffffe097          	auipc	ra,0xffffe
    800054ba:	914080e7          	jalr	-1772(ra) # 80002dca <argint>
  if(argfd(0, 0, &f) < 0)
    800054be:	fe840613          	addi	a2,s0,-24
    800054c2:	4581                	li	a1,0
    800054c4:	4501                	li	a0,0
    800054c6:	00000097          	auipc	ra,0x0
    800054ca:	d5a080e7          	jalr	-678(ra) # 80005220 <argfd>
    800054ce:	87aa                	mv	a5,a0
    return -1;
    800054d0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054d2:	0007cc63          	bltz	a5,800054ea <sys_read+0x50>
  return fileread(f, p, n);
    800054d6:	fe442603          	lw	a2,-28(s0)
    800054da:	fd843583          	ld	a1,-40(s0)
    800054de:	fe843503          	ld	a0,-24(s0)
    800054e2:	fffff097          	auipc	ra,0xfffff
    800054e6:	42c080e7          	jalr	1068(ra) # 8000490e <fileread>
}
    800054ea:	70a2                	ld	ra,40(sp)
    800054ec:	7402                	ld	s0,32(sp)
    800054ee:	6145                	addi	sp,sp,48
    800054f0:	8082                	ret

00000000800054f2 <sys_write>:
{
    800054f2:	7179                	addi	sp,sp,-48
    800054f4:	f406                	sd	ra,40(sp)
    800054f6:	f022                	sd	s0,32(sp)
    800054f8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054fa:	fd840593          	addi	a1,s0,-40
    800054fe:	4505                	li	a0,1
    80005500:	ffffe097          	auipc	ra,0xffffe
    80005504:	8ea080e7          	jalr	-1814(ra) # 80002dea <argaddr>
  argint(2, &n);
    80005508:	fe440593          	addi	a1,s0,-28
    8000550c:	4509                	li	a0,2
    8000550e:	ffffe097          	auipc	ra,0xffffe
    80005512:	8bc080e7          	jalr	-1860(ra) # 80002dca <argint>
  if(argfd(0, 0, &f) < 0)
    80005516:	fe840613          	addi	a2,s0,-24
    8000551a:	4581                	li	a1,0
    8000551c:	4501                	li	a0,0
    8000551e:	00000097          	auipc	ra,0x0
    80005522:	d02080e7          	jalr	-766(ra) # 80005220 <argfd>
    80005526:	87aa                	mv	a5,a0
    return -1;
    80005528:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000552a:	0007cc63          	bltz	a5,80005542 <sys_write+0x50>
  return filewrite(f, p, n);
    8000552e:	fe442603          	lw	a2,-28(s0)
    80005532:	fd843583          	ld	a1,-40(s0)
    80005536:	fe843503          	ld	a0,-24(s0)
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	496080e7          	jalr	1174(ra) # 800049d0 <filewrite>
}
    80005542:	70a2                	ld	ra,40(sp)
    80005544:	7402                	ld	s0,32(sp)
    80005546:	6145                	addi	sp,sp,48
    80005548:	8082                	ret

000000008000554a <sys_close>:
{
    8000554a:	1101                	addi	sp,sp,-32
    8000554c:	ec06                	sd	ra,24(sp)
    8000554e:	e822                	sd	s0,16(sp)
    80005550:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005552:	fe040613          	addi	a2,s0,-32
    80005556:	fec40593          	addi	a1,s0,-20
    8000555a:	4501                	li	a0,0
    8000555c:	00000097          	auipc	ra,0x0
    80005560:	cc4080e7          	jalr	-828(ra) # 80005220 <argfd>
    return -1;
    80005564:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005566:	02054563          	bltz	a0,80005590 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    8000556a:	ffffc097          	auipc	ra,0xffffc
    8000556e:	416080e7          	jalr	1046(ra) # 80001980 <myproc>
    80005572:	fec42783          	lw	a5,-20(s0)
    80005576:	02078793          	addi	a5,a5,32
    8000557a:	078e                	slli	a5,a5,0x3
    8000557c:	97aa                	add	a5,a5,a0
    8000557e:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005582:	fe043503          	ld	a0,-32(s0)
    80005586:	fffff097          	auipc	ra,0xfffff
    8000558a:	24e080e7          	jalr	590(ra) # 800047d4 <fileclose>
  return 0;
    8000558e:	4781                	li	a5,0
}
    80005590:	853e                	mv	a0,a5
    80005592:	60e2                	ld	ra,24(sp)
    80005594:	6442                	ld	s0,16(sp)
    80005596:	6105                	addi	sp,sp,32
    80005598:	8082                	ret

000000008000559a <sys_fstat>:
{
    8000559a:	1101                	addi	sp,sp,-32
    8000559c:	ec06                	sd	ra,24(sp)
    8000559e:	e822                	sd	s0,16(sp)
    800055a0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800055a2:	fe040593          	addi	a1,s0,-32
    800055a6:	4505                	li	a0,1
    800055a8:	ffffe097          	auipc	ra,0xffffe
    800055ac:	842080e7          	jalr	-1982(ra) # 80002dea <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055b0:	fe840613          	addi	a2,s0,-24
    800055b4:	4581                	li	a1,0
    800055b6:	4501                	li	a0,0
    800055b8:	00000097          	auipc	ra,0x0
    800055bc:	c68080e7          	jalr	-920(ra) # 80005220 <argfd>
    800055c0:	87aa                	mv	a5,a0
    return -1;
    800055c2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055c4:	0007ca63          	bltz	a5,800055d8 <sys_fstat+0x3e>
  return filestat(f, st);
    800055c8:	fe043583          	ld	a1,-32(s0)
    800055cc:	fe843503          	ld	a0,-24(s0)
    800055d0:	fffff097          	auipc	ra,0xfffff
    800055d4:	2cc080e7          	jalr	716(ra) # 8000489c <filestat>
}
    800055d8:	60e2                	ld	ra,24(sp)
    800055da:	6442                	ld	s0,16(sp)
    800055dc:	6105                	addi	sp,sp,32
    800055de:	8082                	ret

00000000800055e0 <sys_link>:
{
    800055e0:	7169                	addi	sp,sp,-304
    800055e2:	f606                	sd	ra,296(sp)
    800055e4:	f222                	sd	s0,288(sp)
    800055e6:	ee26                	sd	s1,280(sp)
    800055e8:	ea4a                	sd	s2,272(sp)
    800055ea:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ec:	08000613          	li	a2,128
    800055f0:	ed040593          	addi	a1,s0,-304
    800055f4:	4501                	li	a0,0
    800055f6:	ffffe097          	auipc	ra,0xffffe
    800055fa:	814080e7          	jalr	-2028(ra) # 80002e0a <argstr>
    return -1;
    800055fe:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005600:	10054e63          	bltz	a0,8000571c <sys_link+0x13c>
    80005604:	08000613          	li	a2,128
    80005608:	f5040593          	addi	a1,s0,-176
    8000560c:	4505                	li	a0,1
    8000560e:	ffffd097          	auipc	ra,0xffffd
    80005612:	7fc080e7          	jalr	2044(ra) # 80002e0a <argstr>
    return -1;
    80005616:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005618:	10054263          	bltz	a0,8000571c <sys_link+0x13c>
  begin_op();
    8000561c:	fffff097          	auipc	ra,0xfffff
    80005620:	cec080e7          	jalr	-788(ra) # 80004308 <begin_op>
  if((ip = namei(old)) == 0){
    80005624:	ed040513          	addi	a0,s0,-304
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	ac4080e7          	jalr	-1340(ra) # 800040ec <namei>
    80005630:	84aa                	mv	s1,a0
    80005632:	c551                	beqz	a0,800056be <sys_link+0xde>
  ilock(ip);
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	312080e7          	jalr	786(ra) # 80003946 <ilock>
  if(ip->type == T_DIR){
    8000563c:	04449703          	lh	a4,68(s1)
    80005640:	4785                	li	a5,1
    80005642:	08f70463          	beq	a4,a5,800056ca <sys_link+0xea>
  ip->nlink++;
    80005646:	04a4d783          	lhu	a5,74(s1)
    8000564a:	2785                	addiw	a5,a5,1
    8000564c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005650:	8526                	mv	a0,s1
    80005652:	ffffe097          	auipc	ra,0xffffe
    80005656:	22a080e7          	jalr	554(ra) # 8000387c <iupdate>
  iunlock(ip);
    8000565a:	8526                	mv	a0,s1
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	3ac080e7          	jalr	940(ra) # 80003a08 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005664:	fd040593          	addi	a1,s0,-48
    80005668:	f5040513          	addi	a0,s0,-176
    8000566c:	fffff097          	auipc	ra,0xfffff
    80005670:	a9e080e7          	jalr	-1378(ra) # 8000410a <nameiparent>
    80005674:	892a                	mv	s2,a0
    80005676:	c935                	beqz	a0,800056ea <sys_link+0x10a>
  ilock(dp);
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	2ce080e7          	jalr	718(ra) # 80003946 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005680:	00092703          	lw	a4,0(s2)
    80005684:	409c                	lw	a5,0(s1)
    80005686:	04f71d63          	bne	a4,a5,800056e0 <sys_link+0x100>
    8000568a:	40d0                	lw	a2,4(s1)
    8000568c:	fd040593          	addi	a1,s0,-48
    80005690:	854a                	mv	a0,s2
    80005692:	fffff097          	auipc	ra,0xfffff
    80005696:	9a8080e7          	jalr	-1624(ra) # 8000403a <dirlink>
    8000569a:	04054363          	bltz	a0,800056e0 <sys_link+0x100>
  iunlockput(dp);
    8000569e:	854a                	mv	a0,s2
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	508080e7          	jalr	1288(ra) # 80003ba8 <iunlockput>
  iput(ip);
    800056a8:	8526                	mv	a0,s1
    800056aa:	ffffe097          	auipc	ra,0xffffe
    800056ae:	456080e7          	jalr	1110(ra) # 80003b00 <iput>
  end_op();
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	cd6080e7          	jalr	-810(ra) # 80004388 <end_op>
  return 0;
    800056ba:	4781                	li	a5,0
    800056bc:	a085                	j	8000571c <sys_link+0x13c>
    end_op();
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	cca080e7          	jalr	-822(ra) # 80004388 <end_op>
    return -1;
    800056c6:	57fd                	li	a5,-1
    800056c8:	a891                	j	8000571c <sys_link+0x13c>
    iunlockput(ip);
    800056ca:	8526                	mv	a0,s1
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	4dc080e7          	jalr	1244(ra) # 80003ba8 <iunlockput>
    end_op();
    800056d4:	fffff097          	auipc	ra,0xfffff
    800056d8:	cb4080e7          	jalr	-844(ra) # 80004388 <end_op>
    return -1;
    800056dc:	57fd                	li	a5,-1
    800056de:	a83d                	j	8000571c <sys_link+0x13c>
    iunlockput(dp);
    800056e0:	854a                	mv	a0,s2
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	4c6080e7          	jalr	1222(ra) # 80003ba8 <iunlockput>
  ilock(ip);
    800056ea:	8526                	mv	a0,s1
    800056ec:	ffffe097          	auipc	ra,0xffffe
    800056f0:	25a080e7          	jalr	602(ra) # 80003946 <ilock>
  ip->nlink--;
    800056f4:	04a4d783          	lhu	a5,74(s1)
    800056f8:	37fd                	addiw	a5,a5,-1
    800056fa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056fe:	8526                	mv	a0,s1
    80005700:	ffffe097          	auipc	ra,0xffffe
    80005704:	17c080e7          	jalr	380(ra) # 8000387c <iupdate>
  iunlockput(ip);
    80005708:	8526                	mv	a0,s1
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	49e080e7          	jalr	1182(ra) # 80003ba8 <iunlockput>
  end_op();
    80005712:	fffff097          	auipc	ra,0xfffff
    80005716:	c76080e7          	jalr	-906(ra) # 80004388 <end_op>
  return -1;
    8000571a:	57fd                	li	a5,-1
}
    8000571c:	853e                	mv	a0,a5
    8000571e:	70b2                	ld	ra,296(sp)
    80005720:	7412                	ld	s0,288(sp)
    80005722:	64f2                	ld	s1,280(sp)
    80005724:	6952                	ld	s2,272(sp)
    80005726:	6155                	addi	sp,sp,304
    80005728:	8082                	ret

000000008000572a <sys_unlink>:
{
    8000572a:	7151                	addi	sp,sp,-240
    8000572c:	f586                	sd	ra,232(sp)
    8000572e:	f1a2                	sd	s0,224(sp)
    80005730:	eda6                	sd	s1,216(sp)
    80005732:	e9ca                	sd	s2,208(sp)
    80005734:	e5ce                	sd	s3,200(sp)
    80005736:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005738:	08000613          	li	a2,128
    8000573c:	f3040593          	addi	a1,s0,-208
    80005740:	4501                	li	a0,0
    80005742:	ffffd097          	auipc	ra,0xffffd
    80005746:	6c8080e7          	jalr	1736(ra) # 80002e0a <argstr>
    8000574a:	18054163          	bltz	a0,800058cc <sys_unlink+0x1a2>
  begin_op();
    8000574e:	fffff097          	auipc	ra,0xfffff
    80005752:	bba080e7          	jalr	-1094(ra) # 80004308 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005756:	fb040593          	addi	a1,s0,-80
    8000575a:	f3040513          	addi	a0,s0,-208
    8000575e:	fffff097          	auipc	ra,0xfffff
    80005762:	9ac080e7          	jalr	-1620(ra) # 8000410a <nameiparent>
    80005766:	84aa                	mv	s1,a0
    80005768:	c979                	beqz	a0,8000583e <sys_unlink+0x114>
  ilock(dp);
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	1dc080e7          	jalr	476(ra) # 80003946 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005772:	00003597          	auipc	a1,0x3
    80005776:	f6e58593          	addi	a1,a1,-146 # 800086e0 <syscalls+0x2a0>
    8000577a:	fb040513          	addi	a0,s0,-80
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	692080e7          	jalr	1682(ra) # 80003e10 <namecmp>
    80005786:	14050a63          	beqz	a0,800058da <sys_unlink+0x1b0>
    8000578a:	00003597          	auipc	a1,0x3
    8000578e:	f5e58593          	addi	a1,a1,-162 # 800086e8 <syscalls+0x2a8>
    80005792:	fb040513          	addi	a0,s0,-80
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	67a080e7          	jalr	1658(ra) # 80003e10 <namecmp>
    8000579e:	12050e63          	beqz	a0,800058da <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057a2:	f2c40613          	addi	a2,s0,-212
    800057a6:	fb040593          	addi	a1,s0,-80
    800057aa:	8526                	mv	a0,s1
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	67e080e7          	jalr	1662(ra) # 80003e2a <dirlookup>
    800057b4:	892a                	mv	s2,a0
    800057b6:	12050263          	beqz	a0,800058da <sys_unlink+0x1b0>
  ilock(ip);
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	18c080e7          	jalr	396(ra) # 80003946 <ilock>
  if(ip->nlink < 1)
    800057c2:	04a91783          	lh	a5,74(s2)
    800057c6:	08f05263          	blez	a5,8000584a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057ca:	04491703          	lh	a4,68(s2)
    800057ce:	4785                	li	a5,1
    800057d0:	08f70563          	beq	a4,a5,8000585a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057d4:	4641                	li	a2,16
    800057d6:	4581                	li	a1,0
    800057d8:	fc040513          	addi	a0,s0,-64
    800057dc:	ffffb097          	auipc	ra,0xffffb
    800057e0:	4f6080e7          	jalr	1270(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057e4:	4741                	li	a4,16
    800057e6:	f2c42683          	lw	a3,-212(s0)
    800057ea:	fc040613          	addi	a2,s0,-64
    800057ee:	4581                	li	a1,0
    800057f0:	8526                	mv	a0,s1
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	500080e7          	jalr	1280(ra) # 80003cf2 <writei>
    800057fa:	47c1                	li	a5,16
    800057fc:	0af51563          	bne	a0,a5,800058a6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005800:	04491703          	lh	a4,68(s2)
    80005804:	4785                	li	a5,1
    80005806:	0af70863          	beq	a4,a5,800058b6 <sys_unlink+0x18c>
  iunlockput(dp);
    8000580a:	8526                	mv	a0,s1
    8000580c:	ffffe097          	auipc	ra,0xffffe
    80005810:	39c080e7          	jalr	924(ra) # 80003ba8 <iunlockput>
  ip->nlink--;
    80005814:	04a95783          	lhu	a5,74(s2)
    80005818:	37fd                	addiw	a5,a5,-1
    8000581a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000581e:	854a                	mv	a0,s2
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	05c080e7          	jalr	92(ra) # 8000387c <iupdate>
  iunlockput(ip);
    80005828:	854a                	mv	a0,s2
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	37e080e7          	jalr	894(ra) # 80003ba8 <iunlockput>
  end_op();
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	b56080e7          	jalr	-1194(ra) # 80004388 <end_op>
  return 0;
    8000583a:	4501                	li	a0,0
    8000583c:	a84d                	j	800058ee <sys_unlink+0x1c4>
    end_op();
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	b4a080e7          	jalr	-1206(ra) # 80004388 <end_op>
    return -1;
    80005846:	557d                	li	a0,-1
    80005848:	a05d                	j	800058ee <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000584a:	00003517          	auipc	a0,0x3
    8000584e:	ea650513          	addi	a0,a0,-346 # 800086f0 <syscalls+0x2b0>
    80005852:	ffffb097          	auipc	ra,0xffffb
    80005856:	cec080e7          	jalr	-788(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000585a:	04c92703          	lw	a4,76(s2)
    8000585e:	02000793          	li	a5,32
    80005862:	f6e7f9e3          	bgeu	a5,a4,800057d4 <sys_unlink+0xaa>
    80005866:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000586a:	4741                	li	a4,16
    8000586c:	86ce                	mv	a3,s3
    8000586e:	f1840613          	addi	a2,s0,-232
    80005872:	4581                	li	a1,0
    80005874:	854a                	mv	a0,s2
    80005876:	ffffe097          	auipc	ra,0xffffe
    8000587a:	384080e7          	jalr	900(ra) # 80003bfa <readi>
    8000587e:	47c1                	li	a5,16
    80005880:	00f51b63          	bne	a0,a5,80005896 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005884:	f1845783          	lhu	a5,-232(s0)
    80005888:	e7a1                	bnez	a5,800058d0 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000588a:	29c1                	addiw	s3,s3,16
    8000588c:	04c92783          	lw	a5,76(s2)
    80005890:	fcf9ede3          	bltu	s3,a5,8000586a <sys_unlink+0x140>
    80005894:	b781                	j	800057d4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005896:	00003517          	auipc	a0,0x3
    8000589a:	e7250513          	addi	a0,a0,-398 # 80008708 <syscalls+0x2c8>
    8000589e:	ffffb097          	auipc	ra,0xffffb
    800058a2:	ca0080e7          	jalr	-864(ra) # 8000053e <panic>
    panic("unlink: writei");
    800058a6:	00003517          	auipc	a0,0x3
    800058aa:	e7a50513          	addi	a0,a0,-390 # 80008720 <syscalls+0x2e0>
    800058ae:	ffffb097          	auipc	ra,0xffffb
    800058b2:	c90080e7          	jalr	-880(ra) # 8000053e <panic>
    dp->nlink--;
    800058b6:	04a4d783          	lhu	a5,74(s1)
    800058ba:	37fd                	addiw	a5,a5,-1
    800058bc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058c0:	8526                	mv	a0,s1
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	fba080e7          	jalr	-70(ra) # 8000387c <iupdate>
    800058ca:	b781                	j	8000580a <sys_unlink+0xe0>
    return -1;
    800058cc:	557d                	li	a0,-1
    800058ce:	a005                	j	800058ee <sys_unlink+0x1c4>
    iunlockput(ip);
    800058d0:	854a                	mv	a0,s2
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	2d6080e7          	jalr	726(ra) # 80003ba8 <iunlockput>
  iunlockput(dp);
    800058da:	8526                	mv	a0,s1
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	2cc080e7          	jalr	716(ra) # 80003ba8 <iunlockput>
  end_op();
    800058e4:	fffff097          	auipc	ra,0xfffff
    800058e8:	aa4080e7          	jalr	-1372(ra) # 80004388 <end_op>
  return -1;
    800058ec:	557d                	li	a0,-1
}
    800058ee:	70ae                	ld	ra,232(sp)
    800058f0:	740e                	ld	s0,224(sp)
    800058f2:	64ee                	ld	s1,216(sp)
    800058f4:	694e                	ld	s2,208(sp)
    800058f6:	69ae                	ld	s3,200(sp)
    800058f8:	616d                	addi	sp,sp,240
    800058fa:	8082                	ret

00000000800058fc <sys_open>:

uint64
sys_open(void)
{
    800058fc:	7131                	addi	sp,sp,-192
    800058fe:	fd06                	sd	ra,184(sp)
    80005900:	f922                	sd	s0,176(sp)
    80005902:	f526                	sd	s1,168(sp)
    80005904:	f14a                	sd	s2,160(sp)
    80005906:	ed4e                	sd	s3,152(sp)
    80005908:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000590a:	f4c40593          	addi	a1,s0,-180
    8000590e:	4505                	li	a0,1
    80005910:	ffffd097          	auipc	ra,0xffffd
    80005914:	4ba080e7          	jalr	1210(ra) # 80002dca <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005918:	08000613          	li	a2,128
    8000591c:	f5040593          	addi	a1,s0,-176
    80005920:	4501                	li	a0,0
    80005922:	ffffd097          	auipc	ra,0xffffd
    80005926:	4e8080e7          	jalr	1256(ra) # 80002e0a <argstr>
    8000592a:	87aa                	mv	a5,a0
    return -1;
    8000592c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000592e:	0a07c963          	bltz	a5,800059e0 <sys_open+0xe4>

  begin_op();
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	9d6080e7          	jalr	-1578(ra) # 80004308 <begin_op>

  if(omode & O_CREATE){
    8000593a:	f4c42783          	lw	a5,-180(s0)
    8000593e:	2007f793          	andi	a5,a5,512
    80005942:	cfc5                	beqz	a5,800059fa <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005944:	4681                	li	a3,0
    80005946:	4601                	li	a2,0
    80005948:	4589                	li	a1,2
    8000594a:	f5040513          	addi	a0,s0,-176
    8000594e:	00000097          	auipc	ra,0x0
    80005952:	974080e7          	jalr	-1676(ra) # 800052c2 <create>
    80005956:	84aa                	mv	s1,a0
    if(ip == 0){
    80005958:	c959                	beqz	a0,800059ee <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000595a:	04449703          	lh	a4,68(s1)
    8000595e:	478d                	li	a5,3
    80005960:	00f71763          	bne	a4,a5,8000596e <sys_open+0x72>
    80005964:	0464d703          	lhu	a4,70(s1)
    80005968:	47a5                	li	a5,9
    8000596a:	0ce7ed63          	bltu	a5,a4,80005a44 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	daa080e7          	jalr	-598(ra) # 80004718 <filealloc>
    80005976:	89aa                	mv	s3,a0
    80005978:	10050363          	beqz	a0,80005a7e <sys_open+0x182>
    8000597c:	00000097          	auipc	ra,0x0
    80005980:	904080e7          	jalr	-1788(ra) # 80005280 <fdalloc>
    80005984:	892a                	mv	s2,a0
    80005986:	0e054763          	bltz	a0,80005a74 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000598a:	04449703          	lh	a4,68(s1)
    8000598e:	478d                	li	a5,3
    80005990:	0cf70563          	beq	a4,a5,80005a5a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005994:	4789                	li	a5,2
    80005996:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000599a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000599e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800059a2:	f4c42783          	lw	a5,-180(s0)
    800059a6:	0017c713          	xori	a4,a5,1
    800059aa:	8b05                	andi	a4,a4,1
    800059ac:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059b0:	0037f713          	andi	a4,a5,3
    800059b4:	00e03733          	snez	a4,a4
    800059b8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059bc:	4007f793          	andi	a5,a5,1024
    800059c0:	c791                	beqz	a5,800059cc <sys_open+0xd0>
    800059c2:	04449703          	lh	a4,68(s1)
    800059c6:	4789                	li	a5,2
    800059c8:	0af70063          	beq	a4,a5,80005a68 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800059cc:	8526                	mv	a0,s1
    800059ce:	ffffe097          	auipc	ra,0xffffe
    800059d2:	03a080e7          	jalr	58(ra) # 80003a08 <iunlock>
  end_op();
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	9b2080e7          	jalr	-1614(ra) # 80004388 <end_op>

  return fd;
    800059de:	854a                	mv	a0,s2
}
    800059e0:	70ea                	ld	ra,184(sp)
    800059e2:	744a                	ld	s0,176(sp)
    800059e4:	74aa                	ld	s1,168(sp)
    800059e6:	790a                	ld	s2,160(sp)
    800059e8:	69ea                	ld	s3,152(sp)
    800059ea:	6129                	addi	sp,sp,192
    800059ec:	8082                	ret
      end_op();
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	99a080e7          	jalr	-1638(ra) # 80004388 <end_op>
      return -1;
    800059f6:	557d                	li	a0,-1
    800059f8:	b7e5                	j	800059e0 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059fa:	f5040513          	addi	a0,s0,-176
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	6ee080e7          	jalr	1774(ra) # 800040ec <namei>
    80005a06:	84aa                	mv	s1,a0
    80005a08:	c905                	beqz	a0,80005a38 <sys_open+0x13c>
    ilock(ip);
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	f3c080e7          	jalr	-196(ra) # 80003946 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a12:	04449703          	lh	a4,68(s1)
    80005a16:	4785                	li	a5,1
    80005a18:	f4f711e3          	bne	a4,a5,8000595a <sys_open+0x5e>
    80005a1c:	f4c42783          	lw	a5,-180(s0)
    80005a20:	d7b9                	beqz	a5,8000596e <sys_open+0x72>
      iunlockput(ip);
    80005a22:	8526                	mv	a0,s1
    80005a24:	ffffe097          	auipc	ra,0xffffe
    80005a28:	184080e7          	jalr	388(ra) # 80003ba8 <iunlockput>
      end_op();
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	95c080e7          	jalr	-1700(ra) # 80004388 <end_op>
      return -1;
    80005a34:	557d                	li	a0,-1
    80005a36:	b76d                	j	800059e0 <sys_open+0xe4>
      end_op();
    80005a38:	fffff097          	auipc	ra,0xfffff
    80005a3c:	950080e7          	jalr	-1712(ra) # 80004388 <end_op>
      return -1;
    80005a40:	557d                	li	a0,-1
    80005a42:	bf79                	j	800059e0 <sys_open+0xe4>
    iunlockput(ip);
    80005a44:	8526                	mv	a0,s1
    80005a46:	ffffe097          	auipc	ra,0xffffe
    80005a4a:	162080e7          	jalr	354(ra) # 80003ba8 <iunlockput>
    end_op();
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	93a080e7          	jalr	-1734(ra) # 80004388 <end_op>
    return -1;
    80005a56:	557d                	li	a0,-1
    80005a58:	b761                	j	800059e0 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a5a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a5e:	04649783          	lh	a5,70(s1)
    80005a62:	02f99223          	sh	a5,36(s3)
    80005a66:	bf25                	j	8000599e <sys_open+0xa2>
    itrunc(ip);
    80005a68:	8526                	mv	a0,s1
    80005a6a:	ffffe097          	auipc	ra,0xffffe
    80005a6e:	fea080e7          	jalr	-22(ra) # 80003a54 <itrunc>
    80005a72:	bfa9                	j	800059cc <sys_open+0xd0>
      fileclose(f);
    80005a74:	854e                	mv	a0,s3
    80005a76:	fffff097          	auipc	ra,0xfffff
    80005a7a:	d5e080e7          	jalr	-674(ra) # 800047d4 <fileclose>
    iunlockput(ip);
    80005a7e:	8526                	mv	a0,s1
    80005a80:	ffffe097          	auipc	ra,0xffffe
    80005a84:	128080e7          	jalr	296(ra) # 80003ba8 <iunlockput>
    end_op();
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	900080e7          	jalr	-1792(ra) # 80004388 <end_op>
    return -1;
    80005a90:	557d                	li	a0,-1
    80005a92:	b7b9                	j	800059e0 <sys_open+0xe4>

0000000080005a94 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a94:	7175                	addi	sp,sp,-144
    80005a96:	e506                	sd	ra,136(sp)
    80005a98:	e122                	sd	s0,128(sp)
    80005a9a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a9c:	fffff097          	auipc	ra,0xfffff
    80005aa0:	86c080e7          	jalr	-1940(ra) # 80004308 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005aa4:	08000613          	li	a2,128
    80005aa8:	f7040593          	addi	a1,s0,-144
    80005aac:	4501                	li	a0,0
    80005aae:	ffffd097          	auipc	ra,0xffffd
    80005ab2:	35c080e7          	jalr	860(ra) # 80002e0a <argstr>
    80005ab6:	02054963          	bltz	a0,80005ae8 <sys_mkdir+0x54>
    80005aba:	4681                	li	a3,0
    80005abc:	4601                	li	a2,0
    80005abe:	4585                	li	a1,1
    80005ac0:	f7040513          	addi	a0,s0,-144
    80005ac4:	fffff097          	auipc	ra,0xfffff
    80005ac8:	7fe080e7          	jalr	2046(ra) # 800052c2 <create>
    80005acc:	cd11                	beqz	a0,80005ae8 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	0da080e7          	jalr	218(ra) # 80003ba8 <iunlockput>
  end_op();
    80005ad6:	fffff097          	auipc	ra,0xfffff
    80005ada:	8b2080e7          	jalr	-1870(ra) # 80004388 <end_op>
  return 0;
    80005ade:	4501                	li	a0,0
}
    80005ae0:	60aa                	ld	ra,136(sp)
    80005ae2:	640a                	ld	s0,128(sp)
    80005ae4:	6149                	addi	sp,sp,144
    80005ae6:	8082                	ret
    end_op();
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	8a0080e7          	jalr	-1888(ra) # 80004388 <end_op>
    return -1;
    80005af0:	557d                	li	a0,-1
    80005af2:	b7fd                	j	80005ae0 <sys_mkdir+0x4c>

0000000080005af4 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005af4:	7135                	addi	sp,sp,-160
    80005af6:	ed06                	sd	ra,152(sp)
    80005af8:	e922                	sd	s0,144(sp)
    80005afa:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	80c080e7          	jalr	-2036(ra) # 80004308 <begin_op>
  argint(1, &major);
    80005b04:	f6c40593          	addi	a1,s0,-148
    80005b08:	4505                	li	a0,1
    80005b0a:	ffffd097          	auipc	ra,0xffffd
    80005b0e:	2c0080e7          	jalr	704(ra) # 80002dca <argint>
  argint(2, &minor);
    80005b12:	f6840593          	addi	a1,s0,-152
    80005b16:	4509                	li	a0,2
    80005b18:	ffffd097          	auipc	ra,0xffffd
    80005b1c:	2b2080e7          	jalr	690(ra) # 80002dca <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b20:	08000613          	li	a2,128
    80005b24:	f7040593          	addi	a1,s0,-144
    80005b28:	4501                	li	a0,0
    80005b2a:	ffffd097          	auipc	ra,0xffffd
    80005b2e:	2e0080e7          	jalr	736(ra) # 80002e0a <argstr>
    80005b32:	02054b63          	bltz	a0,80005b68 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b36:	f6841683          	lh	a3,-152(s0)
    80005b3a:	f6c41603          	lh	a2,-148(s0)
    80005b3e:	458d                	li	a1,3
    80005b40:	f7040513          	addi	a0,s0,-144
    80005b44:	fffff097          	auipc	ra,0xfffff
    80005b48:	77e080e7          	jalr	1918(ra) # 800052c2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b4c:	cd11                	beqz	a0,80005b68 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b4e:	ffffe097          	auipc	ra,0xffffe
    80005b52:	05a080e7          	jalr	90(ra) # 80003ba8 <iunlockput>
  end_op();
    80005b56:	fffff097          	auipc	ra,0xfffff
    80005b5a:	832080e7          	jalr	-1998(ra) # 80004388 <end_op>
  return 0;
    80005b5e:	4501                	li	a0,0
}
    80005b60:	60ea                	ld	ra,152(sp)
    80005b62:	644a                	ld	s0,144(sp)
    80005b64:	610d                	addi	sp,sp,160
    80005b66:	8082                	ret
    end_op();
    80005b68:	fffff097          	auipc	ra,0xfffff
    80005b6c:	820080e7          	jalr	-2016(ra) # 80004388 <end_op>
    return -1;
    80005b70:	557d                	li	a0,-1
    80005b72:	b7fd                	j	80005b60 <sys_mknod+0x6c>

0000000080005b74 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b74:	7135                	addi	sp,sp,-160
    80005b76:	ed06                	sd	ra,152(sp)
    80005b78:	e922                	sd	s0,144(sp)
    80005b7a:	e526                	sd	s1,136(sp)
    80005b7c:	e14a                	sd	s2,128(sp)
    80005b7e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b80:	ffffc097          	auipc	ra,0xffffc
    80005b84:	e00080e7          	jalr	-512(ra) # 80001980 <myproc>
    80005b88:	892a                	mv	s2,a0
  
  begin_op();
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	77e080e7          	jalr	1918(ra) # 80004308 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b92:	08000613          	li	a2,128
    80005b96:	f6040593          	addi	a1,s0,-160
    80005b9a:	4501                	li	a0,0
    80005b9c:	ffffd097          	auipc	ra,0xffffd
    80005ba0:	26e080e7          	jalr	622(ra) # 80002e0a <argstr>
    80005ba4:	04054b63          	bltz	a0,80005bfa <sys_chdir+0x86>
    80005ba8:	f6040513          	addi	a0,s0,-160
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	540080e7          	jalr	1344(ra) # 800040ec <namei>
    80005bb4:	84aa                	mv	s1,a0
    80005bb6:	c131                	beqz	a0,80005bfa <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bb8:	ffffe097          	auipc	ra,0xffffe
    80005bbc:	d8e080e7          	jalr	-626(ra) # 80003946 <ilock>
  if(ip->type != T_DIR){
    80005bc0:	04449703          	lh	a4,68(s1)
    80005bc4:	4785                	li	a5,1
    80005bc6:	04f71063          	bne	a4,a5,80005c06 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bca:	8526                	mv	a0,s1
    80005bcc:	ffffe097          	auipc	ra,0xffffe
    80005bd0:	e3c080e7          	jalr	-452(ra) # 80003a08 <iunlock>
  iput(p->cwd);
    80005bd4:	18893503          	ld	a0,392(s2)
    80005bd8:	ffffe097          	auipc	ra,0xffffe
    80005bdc:	f28080e7          	jalr	-216(ra) # 80003b00 <iput>
  end_op();
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	7a8080e7          	jalr	1960(ra) # 80004388 <end_op>
  p->cwd = ip;
    80005be8:	18993423          	sd	s1,392(s2)
  return 0;
    80005bec:	4501                	li	a0,0
}
    80005bee:	60ea                	ld	ra,152(sp)
    80005bf0:	644a                	ld	s0,144(sp)
    80005bf2:	64aa                	ld	s1,136(sp)
    80005bf4:	690a                	ld	s2,128(sp)
    80005bf6:	610d                	addi	sp,sp,160
    80005bf8:	8082                	ret
    end_op();
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	78e080e7          	jalr	1934(ra) # 80004388 <end_op>
    return -1;
    80005c02:	557d                	li	a0,-1
    80005c04:	b7ed                	j	80005bee <sys_chdir+0x7a>
    iunlockput(ip);
    80005c06:	8526                	mv	a0,s1
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	fa0080e7          	jalr	-96(ra) # 80003ba8 <iunlockput>
    end_op();
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	778080e7          	jalr	1912(ra) # 80004388 <end_op>
    return -1;
    80005c18:	557d                	li	a0,-1
    80005c1a:	bfd1                	j	80005bee <sys_chdir+0x7a>

0000000080005c1c <sys_exec>:

uint64
sys_exec(void)
{
    80005c1c:	7145                	addi	sp,sp,-464
    80005c1e:	e786                	sd	ra,456(sp)
    80005c20:	e3a2                	sd	s0,448(sp)
    80005c22:	ff26                	sd	s1,440(sp)
    80005c24:	fb4a                	sd	s2,432(sp)
    80005c26:	f74e                	sd	s3,424(sp)
    80005c28:	f352                	sd	s4,416(sp)
    80005c2a:	ef56                	sd	s5,408(sp)
    80005c2c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c2e:	e3840593          	addi	a1,s0,-456
    80005c32:	4505                	li	a0,1
    80005c34:	ffffd097          	auipc	ra,0xffffd
    80005c38:	1b6080e7          	jalr	438(ra) # 80002dea <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c3c:	08000613          	li	a2,128
    80005c40:	f4040593          	addi	a1,s0,-192
    80005c44:	4501                	li	a0,0
    80005c46:	ffffd097          	auipc	ra,0xffffd
    80005c4a:	1c4080e7          	jalr	452(ra) # 80002e0a <argstr>
    80005c4e:	87aa                	mv	a5,a0
    return -1;
    80005c50:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c52:	0c07c263          	bltz	a5,80005d16 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c56:	10000613          	li	a2,256
    80005c5a:	4581                	li	a1,0
    80005c5c:	e4040513          	addi	a0,s0,-448
    80005c60:	ffffb097          	auipc	ra,0xffffb
    80005c64:	072080e7          	jalr	114(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c68:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c6c:	89a6                	mv	s3,s1
    80005c6e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c70:	02000a13          	li	s4,32
    80005c74:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c78:	00391793          	slli	a5,s2,0x3
    80005c7c:	e3040593          	addi	a1,s0,-464
    80005c80:	e3843503          	ld	a0,-456(s0)
    80005c84:	953e                	add	a0,a0,a5
    80005c86:	ffffd097          	auipc	ra,0xffffd
    80005c8a:	0a2080e7          	jalr	162(ra) # 80002d28 <fetchaddr>
    80005c8e:	02054a63          	bltz	a0,80005cc2 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c92:	e3043783          	ld	a5,-464(s0)
    80005c96:	c3b9                	beqz	a5,80005cdc <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c98:	ffffb097          	auipc	ra,0xffffb
    80005c9c:	e4e080e7          	jalr	-434(ra) # 80000ae6 <kalloc>
    80005ca0:	85aa                	mv	a1,a0
    80005ca2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ca6:	cd11                	beqz	a0,80005cc2 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ca8:	6605                	lui	a2,0x1
    80005caa:	e3043503          	ld	a0,-464(s0)
    80005cae:	ffffd097          	auipc	ra,0xffffd
    80005cb2:	0ce080e7          	jalr	206(ra) # 80002d7c <fetchstr>
    80005cb6:	00054663          	bltz	a0,80005cc2 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005cba:	0905                	addi	s2,s2,1
    80005cbc:	09a1                	addi	s3,s3,8
    80005cbe:	fb491be3          	bne	s2,s4,80005c74 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc2:	10048913          	addi	s2,s1,256
    80005cc6:	6088                	ld	a0,0(s1)
    80005cc8:	c531                	beqz	a0,80005d14 <sys_exec+0xf8>
    kfree(argv[i]);
    80005cca:	ffffb097          	auipc	ra,0xffffb
    80005cce:	d20080e7          	jalr	-736(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cd2:	04a1                	addi	s1,s1,8
    80005cd4:	ff2499e3          	bne	s1,s2,80005cc6 <sys_exec+0xaa>
  return -1;
    80005cd8:	557d                	li	a0,-1
    80005cda:	a835                	j	80005d16 <sys_exec+0xfa>
      argv[i] = 0;
    80005cdc:	0a8e                	slli	s5,s5,0x3
    80005cde:	fc040793          	addi	a5,s0,-64
    80005ce2:	9abe                	add	s5,s5,a5
    80005ce4:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ce8:	e4040593          	addi	a1,s0,-448
    80005cec:	f4040513          	addi	a0,s0,-192
    80005cf0:	fffff097          	auipc	ra,0xfffff
    80005cf4:	15e080e7          	jalr	350(ra) # 80004e4e <exec>
    80005cf8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cfa:	10048993          	addi	s3,s1,256
    80005cfe:	6088                	ld	a0,0(s1)
    80005d00:	c901                	beqz	a0,80005d10 <sys_exec+0xf4>
    kfree(argv[i]);
    80005d02:	ffffb097          	auipc	ra,0xffffb
    80005d06:	ce8080e7          	jalr	-792(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d0a:	04a1                	addi	s1,s1,8
    80005d0c:	ff3499e3          	bne	s1,s3,80005cfe <sys_exec+0xe2>
  return ret;
    80005d10:	854a                	mv	a0,s2
    80005d12:	a011                	j	80005d16 <sys_exec+0xfa>
  return -1;
    80005d14:	557d                	li	a0,-1
}
    80005d16:	60be                	ld	ra,456(sp)
    80005d18:	641e                	ld	s0,448(sp)
    80005d1a:	74fa                	ld	s1,440(sp)
    80005d1c:	795a                	ld	s2,432(sp)
    80005d1e:	79ba                	ld	s3,424(sp)
    80005d20:	7a1a                	ld	s4,416(sp)
    80005d22:	6afa                	ld	s5,408(sp)
    80005d24:	6179                	addi	sp,sp,464
    80005d26:	8082                	ret

0000000080005d28 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d28:	7139                	addi	sp,sp,-64
    80005d2a:	fc06                	sd	ra,56(sp)
    80005d2c:	f822                	sd	s0,48(sp)
    80005d2e:	f426                	sd	s1,40(sp)
    80005d30:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d32:	ffffc097          	auipc	ra,0xffffc
    80005d36:	c4e080e7          	jalr	-946(ra) # 80001980 <myproc>
    80005d3a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d3c:	fd840593          	addi	a1,s0,-40
    80005d40:	4501                	li	a0,0
    80005d42:	ffffd097          	auipc	ra,0xffffd
    80005d46:	0a8080e7          	jalr	168(ra) # 80002dea <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d4a:	fc840593          	addi	a1,s0,-56
    80005d4e:	fd040513          	addi	a0,s0,-48
    80005d52:	fffff097          	auipc	ra,0xfffff
    80005d56:	db2080e7          	jalr	-590(ra) # 80004b04 <pipealloc>
    return -1;
    80005d5a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d5c:	0c054963          	bltz	a0,80005e2e <sys_pipe+0x106>
  fd0 = -1;
    80005d60:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d64:	fd043503          	ld	a0,-48(s0)
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	518080e7          	jalr	1304(ra) # 80005280 <fdalloc>
    80005d70:	fca42223          	sw	a0,-60(s0)
    80005d74:	0a054063          	bltz	a0,80005e14 <sys_pipe+0xec>
    80005d78:	fc843503          	ld	a0,-56(s0)
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	504080e7          	jalr	1284(ra) # 80005280 <fdalloc>
    80005d84:	fca42023          	sw	a0,-64(s0)
    80005d88:	06054c63          	bltz	a0,80005e00 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d8c:	4691                	li	a3,4
    80005d8e:	fc440613          	addi	a2,s0,-60
    80005d92:	fd843583          	ld	a1,-40(s0)
    80005d96:	1004b503          	ld	a0,256(s1)
    80005d9a:	ffffc097          	auipc	ra,0xffffc
    80005d9e:	8ce080e7          	jalr	-1842(ra) # 80001668 <copyout>
    80005da2:	02054163          	bltz	a0,80005dc4 <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005da6:	4691                	li	a3,4
    80005da8:	fc040613          	addi	a2,s0,-64
    80005dac:	fd843583          	ld	a1,-40(s0)
    80005db0:	0591                	addi	a1,a1,4
    80005db2:	1004b503          	ld	a0,256(s1)
    80005db6:	ffffc097          	auipc	ra,0xffffc
    80005dba:	8b2080e7          	jalr	-1870(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005dbe:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dc0:	06055763          	bgez	a0,80005e2e <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80005dc4:	fc442783          	lw	a5,-60(s0)
    80005dc8:	02078793          	addi	a5,a5,32
    80005dcc:	078e                	slli	a5,a5,0x3
    80005dce:	97a6                	add	a5,a5,s1
    80005dd0:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005dd4:	fc042503          	lw	a0,-64(s0)
    80005dd8:	02050513          	addi	a0,a0,32
    80005ddc:	050e                	slli	a0,a0,0x3
    80005dde:	94aa                	add	s1,s1,a0
    80005de0:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005de4:	fd043503          	ld	a0,-48(s0)
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	9ec080e7          	jalr	-1556(ra) # 800047d4 <fileclose>
    fileclose(wf);
    80005df0:	fc843503          	ld	a0,-56(s0)
    80005df4:	fffff097          	auipc	ra,0xfffff
    80005df8:	9e0080e7          	jalr	-1568(ra) # 800047d4 <fileclose>
    return -1;
    80005dfc:	57fd                	li	a5,-1
    80005dfe:	a805                	j	80005e2e <sys_pipe+0x106>
    if(fd0 >= 0)
    80005e00:	fc442783          	lw	a5,-60(s0)
    80005e04:	0007c863          	bltz	a5,80005e14 <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80005e08:	02078793          	addi	a5,a5,32
    80005e0c:	078e                	slli	a5,a5,0x3
    80005e0e:	94be                	add	s1,s1,a5
    80005e10:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e14:	fd043503          	ld	a0,-48(s0)
    80005e18:	fffff097          	auipc	ra,0xfffff
    80005e1c:	9bc080e7          	jalr	-1604(ra) # 800047d4 <fileclose>
    fileclose(wf);
    80005e20:	fc843503          	ld	a0,-56(s0)
    80005e24:	fffff097          	auipc	ra,0xfffff
    80005e28:	9b0080e7          	jalr	-1616(ra) # 800047d4 <fileclose>
    return -1;
    80005e2c:	57fd                	li	a5,-1
}
    80005e2e:	853e                	mv	a0,a5
    80005e30:	70e2                	ld	ra,56(sp)
    80005e32:	7442                	ld	s0,48(sp)
    80005e34:	74a2                	ld	s1,40(sp)
    80005e36:	6121                	addi	sp,sp,64
    80005e38:	8082                	ret
    80005e3a:	0000                	unimp
    80005e3c:	0000                	unimp
	...

0000000080005e40 <kernelvec>:
    80005e40:	7111                	addi	sp,sp,-256
    80005e42:	e006                	sd	ra,0(sp)
    80005e44:	e40a                	sd	sp,8(sp)
    80005e46:	e80e                	sd	gp,16(sp)
    80005e48:	ec12                	sd	tp,24(sp)
    80005e4a:	f016                	sd	t0,32(sp)
    80005e4c:	f41a                	sd	t1,40(sp)
    80005e4e:	f81e                	sd	t2,48(sp)
    80005e50:	fc22                	sd	s0,56(sp)
    80005e52:	e0a6                	sd	s1,64(sp)
    80005e54:	e4aa                	sd	a0,72(sp)
    80005e56:	e8ae                	sd	a1,80(sp)
    80005e58:	ecb2                	sd	a2,88(sp)
    80005e5a:	f0b6                	sd	a3,96(sp)
    80005e5c:	f4ba                	sd	a4,104(sp)
    80005e5e:	f8be                	sd	a5,112(sp)
    80005e60:	fcc2                	sd	a6,120(sp)
    80005e62:	e146                	sd	a7,128(sp)
    80005e64:	e54a                	sd	s2,136(sp)
    80005e66:	e94e                	sd	s3,144(sp)
    80005e68:	ed52                	sd	s4,152(sp)
    80005e6a:	f156                	sd	s5,160(sp)
    80005e6c:	f55a                	sd	s6,168(sp)
    80005e6e:	f95e                	sd	s7,176(sp)
    80005e70:	fd62                	sd	s8,184(sp)
    80005e72:	e1e6                	sd	s9,192(sp)
    80005e74:	e5ea                	sd	s10,200(sp)
    80005e76:	e9ee                	sd	s11,208(sp)
    80005e78:	edf2                	sd	t3,216(sp)
    80005e7a:	f1f6                	sd	t4,224(sp)
    80005e7c:	f5fa                	sd	t5,232(sp)
    80005e7e:	f9fe                	sd	t6,240(sp)
    80005e80:	d75fc0ef          	jal	ra,80002bf4 <kerneltrap>
    80005e84:	6082                	ld	ra,0(sp)
    80005e86:	6122                	ld	sp,8(sp)
    80005e88:	61c2                	ld	gp,16(sp)
    80005e8a:	7282                	ld	t0,32(sp)
    80005e8c:	7322                	ld	t1,40(sp)
    80005e8e:	73c2                	ld	t2,48(sp)
    80005e90:	7462                	ld	s0,56(sp)
    80005e92:	6486                	ld	s1,64(sp)
    80005e94:	6526                	ld	a0,72(sp)
    80005e96:	65c6                	ld	a1,80(sp)
    80005e98:	6666                	ld	a2,88(sp)
    80005e9a:	7686                	ld	a3,96(sp)
    80005e9c:	7726                	ld	a4,104(sp)
    80005e9e:	77c6                	ld	a5,112(sp)
    80005ea0:	7866                	ld	a6,120(sp)
    80005ea2:	688a                	ld	a7,128(sp)
    80005ea4:	692a                	ld	s2,136(sp)
    80005ea6:	69ca                	ld	s3,144(sp)
    80005ea8:	6a6a                	ld	s4,152(sp)
    80005eaa:	7a8a                	ld	s5,160(sp)
    80005eac:	7b2a                	ld	s6,168(sp)
    80005eae:	7bca                	ld	s7,176(sp)
    80005eb0:	7c6a                	ld	s8,184(sp)
    80005eb2:	6c8e                	ld	s9,192(sp)
    80005eb4:	6d2e                	ld	s10,200(sp)
    80005eb6:	6dce                	ld	s11,208(sp)
    80005eb8:	6e6e                	ld	t3,216(sp)
    80005eba:	7e8e                	ld	t4,224(sp)
    80005ebc:	7f2e                	ld	t5,232(sp)
    80005ebe:	7fce                	ld	t6,240(sp)
    80005ec0:	6111                	addi	sp,sp,256
    80005ec2:	10200073          	sret
    80005ec6:	00000013          	nop
    80005eca:	00000013          	nop
    80005ece:	0001                	nop

0000000080005ed0 <timervec>:
    80005ed0:	34051573          	csrrw	a0,mscratch,a0
    80005ed4:	e10c                	sd	a1,0(a0)
    80005ed6:	e510                	sd	a2,8(a0)
    80005ed8:	e914                	sd	a3,16(a0)
    80005eda:	6d0c                	ld	a1,24(a0)
    80005edc:	7110                	ld	a2,32(a0)
    80005ede:	6194                	ld	a3,0(a1)
    80005ee0:	96b2                	add	a3,a3,a2
    80005ee2:	e194                	sd	a3,0(a1)
    80005ee4:	4589                	li	a1,2
    80005ee6:	14459073          	csrw	sip,a1
    80005eea:	6914                	ld	a3,16(a0)
    80005eec:	6510                	ld	a2,8(a0)
    80005eee:	610c                	ld	a1,0(a0)
    80005ef0:	34051573          	csrrw	a0,mscratch,a0
    80005ef4:	30200073          	mret
	...

0000000080005efa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005efa:	1141                	addi	sp,sp,-16
    80005efc:	e422                	sd	s0,8(sp)
    80005efe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f00:	0c0007b7          	lui	a5,0xc000
    80005f04:	4705                	li	a4,1
    80005f06:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f08:	c3d8                	sw	a4,4(a5)
}
    80005f0a:	6422                	ld	s0,8(sp)
    80005f0c:	0141                	addi	sp,sp,16
    80005f0e:	8082                	ret

0000000080005f10 <plicinithart>:

void
plicinithart(void)
{
    80005f10:	1141                	addi	sp,sp,-16
    80005f12:	e406                	sd	ra,8(sp)
    80005f14:	e022                	sd	s0,0(sp)
    80005f16:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f18:	ffffc097          	auipc	ra,0xffffc
    80005f1c:	a3c080e7          	jalr	-1476(ra) # 80001954 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f20:	0085171b          	slliw	a4,a0,0x8
    80005f24:	0c0027b7          	lui	a5,0xc002
    80005f28:	97ba                	add	a5,a5,a4
    80005f2a:	40200713          	li	a4,1026
    80005f2e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f32:	00d5151b          	slliw	a0,a0,0xd
    80005f36:	0c2017b7          	lui	a5,0xc201
    80005f3a:	953e                	add	a0,a0,a5
    80005f3c:	00052023          	sw	zero,0(a0)
}
    80005f40:	60a2                	ld	ra,8(sp)
    80005f42:	6402                	ld	s0,0(sp)
    80005f44:	0141                	addi	sp,sp,16
    80005f46:	8082                	ret

0000000080005f48 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f48:	1141                	addi	sp,sp,-16
    80005f4a:	e406                	sd	ra,8(sp)
    80005f4c:	e022                	sd	s0,0(sp)
    80005f4e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f50:	ffffc097          	auipc	ra,0xffffc
    80005f54:	a04080e7          	jalr	-1532(ra) # 80001954 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f58:	00d5179b          	slliw	a5,a0,0xd
    80005f5c:	0c201537          	lui	a0,0xc201
    80005f60:	953e                	add	a0,a0,a5
  return irq;
}
    80005f62:	4148                	lw	a0,4(a0)
    80005f64:	60a2                	ld	ra,8(sp)
    80005f66:	6402                	ld	s0,0(sp)
    80005f68:	0141                	addi	sp,sp,16
    80005f6a:	8082                	ret

0000000080005f6c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f6c:	1101                	addi	sp,sp,-32
    80005f6e:	ec06                	sd	ra,24(sp)
    80005f70:	e822                	sd	s0,16(sp)
    80005f72:	e426                	sd	s1,8(sp)
    80005f74:	1000                	addi	s0,sp,32
    80005f76:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f78:	ffffc097          	auipc	ra,0xffffc
    80005f7c:	9dc080e7          	jalr	-1572(ra) # 80001954 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f80:	00d5151b          	slliw	a0,a0,0xd
    80005f84:	0c2017b7          	lui	a5,0xc201
    80005f88:	97aa                	add	a5,a5,a0
    80005f8a:	c3c4                	sw	s1,4(a5)
}
    80005f8c:	60e2                	ld	ra,24(sp)
    80005f8e:	6442                	ld	s0,16(sp)
    80005f90:	64a2                	ld	s1,8(sp)
    80005f92:	6105                	addi	sp,sp,32
    80005f94:	8082                	ret

0000000080005f96 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f96:	1141                	addi	sp,sp,-16
    80005f98:	e406                	sd	ra,8(sp)
    80005f9a:	e022                	sd	s0,0(sp)
    80005f9c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f9e:	479d                	li	a5,7
    80005fa0:	04a7cc63          	blt	a5,a0,80005ff8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005fa4:	0001d797          	auipc	a5,0x1d
    80005fa8:	26c78793          	addi	a5,a5,620 # 80023210 <disk>
    80005fac:	97aa                	add	a5,a5,a0
    80005fae:	0187c783          	lbu	a5,24(a5)
    80005fb2:	ebb9                	bnez	a5,80006008 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005fb4:	00451613          	slli	a2,a0,0x4
    80005fb8:	0001d797          	auipc	a5,0x1d
    80005fbc:	25878793          	addi	a5,a5,600 # 80023210 <disk>
    80005fc0:	6394                	ld	a3,0(a5)
    80005fc2:	96b2                	add	a3,a3,a2
    80005fc4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005fc8:	6398                	ld	a4,0(a5)
    80005fca:	9732                	add	a4,a4,a2
    80005fcc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005fd0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005fd4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005fd8:	953e                	add	a0,a0,a5
    80005fda:	4785                	li	a5,1
    80005fdc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005fe0:	0001d517          	auipc	a0,0x1d
    80005fe4:	24850513          	addi	a0,a0,584 # 80023228 <disk+0x18>
    80005fe8:	ffffc097          	auipc	ra,0xffffc
    80005fec:	142080e7          	jalr	322(ra) # 8000212a <wakeup>
}
    80005ff0:	60a2                	ld	ra,8(sp)
    80005ff2:	6402                	ld	s0,0(sp)
    80005ff4:	0141                	addi	sp,sp,16
    80005ff6:	8082                	ret
    panic("free_desc 1");
    80005ff8:	00002517          	auipc	a0,0x2
    80005ffc:	73850513          	addi	a0,a0,1848 # 80008730 <syscalls+0x2f0>
    80006000:	ffffa097          	auipc	ra,0xffffa
    80006004:	53e080e7          	jalr	1342(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006008:	00002517          	auipc	a0,0x2
    8000600c:	73850513          	addi	a0,a0,1848 # 80008740 <syscalls+0x300>
    80006010:	ffffa097          	auipc	ra,0xffffa
    80006014:	52e080e7          	jalr	1326(ra) # 8000053e <panic>

0000000080006018 <virtio_disk_init>:
{
    80006018:	1101                	addi	sp,sp,-32
    8000601a:	ec06                	sd	ra,24(sp)
    8000601c:	e822                	sd	s0,16(sp)
    8000601e:	e426                	sd	s1,8(sp)
    80006020:	e04a                	sd	s2,0(sp)
    80006022:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006024:	00002597          	auipc	a1,0x2
    80006028:	72c58593          	addi	a1,a1,1836 # 80008750 <syscalls+0x310>
    8000602c:	0001d517          	auipc	a0,0x1d
    80006030:	30c50513          	addi	a0,a0,780 # 80023338 <disk+0x128>
    80006034:	ffffb097          	auipc	ra,0xffffb
    80006038:	b12080e7          	jalr	-1262(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000603c:	100017b7          	lui	a5,0x10001
    80006040:	4398                	lw	a4,0(a5)
    80006042:	2701                	sext.w	a4,a4
    80006044:	747277b7          	lui	a5,0x74727
    80006048:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000604c:	14f71c63          	bne	a4,a5,800061a4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006050:	100017b7          	lui	a5,0x10001
    80006054:	43dc                	lw	a5,4(a5)
    80006056:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006058:	4709                	li	a4,2
    8000605a:	14e79563          	bne	a5,a4,800061a4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000605e:	100017b7          	lui	a5,0x10001
    80006062:	479c                	lw	a5,8(a5)
    80006064:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006066:	12e79f63          	bne	a5,a4,800061a4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000606a:	100017b7          	lui	a5,0x10001
    8000606e:	47d8                	lw	a4,12(a5)
    80006070:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006072:	554d47b7          	lui	a5,0x554d4
    80006076:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000607a:	12f71563          	bne	a4,a5,800061a4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000607e:	100017b7          	lui	a5,0x10001
    80006082:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006086:	4705                	li	a4,1
    80006088:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000608a:	470d                	li	a4,3
    8000608c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000608e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006090:	c7ffe737          	lui	a4,0xc7ffe
    80006094:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb40f>
    80006098:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000609a:	2701                	sext.w	a4,a4
    8000609c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000609e:	472d                	li	a4,11
    800060a0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800060a2:	5bbc                	lw	a5,112(a5)
    800060a4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060a8:	8ba1                	andi	a5,a5,8
    800060aa:	10078563          	beqz	a5,800061b4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060ae:	100017b7          	lui	a5,0x10001
    800060b2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060b6:	43fc                	lw	a5,68(a5)
    800060b8:	2781                	sext.w	a5,a5
    800060ba:	10079563          	bnez	a5,800061c4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060be:	100017b7          	lui	a5,0x10001
    800060c2:	5bdc                	lw	a5,52(a5)
    800060c4:	2781                	sext.w	a5,a5
  if(max == 0)
    800060c6:	10078763          	beqz	a5,800061d4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800060ca:	471d                	li	a4,7
    800060cc:	10f77c63          	bgeu	a4,a5,800061e4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800060d0:	ffffb097          	auipc	ra,0xffffb
    800060d4:	a16080e7          	jalr	-1514(ra) # 80000ae6 <kalloc>
    800060d8:	0001d497          	auipc	s1,0x1d
    800060dc:	13848493          	addi	s1,s1,312 # 80023210 <disk>
    800060e0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060e2:	ffffb097          	auipc	ra,0xffffb
    800060e6:	a04080e7          	jalr	-1532(ra) # 80000ae6 <kalloc>
    800060ea:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060ec:	ffffb097          	auipc	ra,0xffffb
    800060f0:	9fa080e7          	jalr	-1542(ra) # 80000ae6 <kalloc>
    800060f4:	87aa                	mv	a5,a0
    800060f6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060f8:	6088                	ld	a0,0(s1)
    800060fa:	cd6d                	beqz	a0,800061f4 <virtio_disk_init+0x1dc>
    800060fc:	0001d717          	auipc	a4,0x1d
    80006100:	11c73703          	ld	a4,284(a4) # 80023218 <disk+0x8>
    80006104:	cb65                	beqz	a4,800061f4 <virtio_disk_init+0x1dc>
    80006106:	c7fd                	beqz	a5,800061f4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006108:	6605                	lui	a2,0x1
    8000610a:	4581                	li	a1,0
    8000610c:	ffffb097          	auipc	ra,0xffffb
    80006110:	bc6080e7          	jalr	-1082(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006114:	0001d497          	auipc	s1,0x1d
    80006118:	0fc48493          	addi	s1,s1,252 # 80023210 <disk>
    8000611c:	6605                	lui	a2,0x1
    8000611e:	4581                	li	a1,0
    80006120:	6488                	ld	a0,8(s1)
    80006122:	ffffb097          	auipc	ra,0xffffb
    80006126:	bb0080e7          	jalr	-1104(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000612a:	6605                	lui	a2,0x1
    8000612c:	4581                	li	a1,0
    8000612e:	6888                	ld	a0,16(s1)
    80006130:	ffffb097          	auipc	ra,0xffffb
    80006134:	ba2080e7          	jalr	-1118(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006138:	100017b7          	lui	a5,0x10001
    8000613c:	4721                	li	a4,8
    8000613e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006140:	4098                	lw	a4,0(s1)
    80006142:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006146:	40d8                	lw	a4,4(s1)
    80006148:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000614c:	6498                	ld	a4,8(s1)
    8000614e:	0007069b          	sext.w	a3,a4
    80006152:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006156:	9701                	srai	a4,a4,0x20
    80006158:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000615c:	6898                	ld	a4,16(s1)
    8000615e:	0007069b          	sext.w	a3,a4
    80006162:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006166:	9701                	srai	a4,a4,0x20
    80006168:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000616c:	4705                	li	a4,1
    8000616e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006170:	00e48c23          	sb	a4,24(s1)
    80006174:	00e48ca3          	sb	a4,25(s1)
    80006178:	00e48d23          	sb	a4,26(s1)
    8000617c:	00e48da3          	sb	a4,27(s1)
    80006180:	00e48e23          	sb	a4,28(s1)
    80006184:	00e48ea3          	sb	a4,29(s1)
    80006188:	00e48f23          	sb	a4,30(s1)
    8000618c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006190:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006194:	0727a823          	sw	s2,112(a5)
}
    80006198:	60e2                	ld	ra,24(sp)
    8000619a:	6442                	ld	s0,16(sp)
    8000619c:	64a2                	ld	s1,8(sp)
    8000619e:	6902                	ld	s2,0(sp)
    800061a0:	6105                	addi	sp,sp,32
    800061a2:	8082                	ret
    panic("could not find virtio disk");
    800061a4:	00002517          	auipc	a0,0x2
    800061a8:	5bc50513          	addi	a0,a0,1468 # 80008760 <syscalls+0x320>
    800061ac:	ffffa097          	auipc	ra,0xffffa
    800061b0:	392080e7          	jalr	914(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800061b4:	00002517          	auipc	a0,0x2
    800061b8:	5cc50513          	addi	a0,a0,1484 # 80008780 <syscalls+0x340>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	382080e7          	jalr	898(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800061c4:	00002517          	auipc	a0,0x2
    800061c8:	5dc50513          	addi	a0,a0,1500 # 800087a0 <syscalls+0x360>
    800061cc:	ffffa097          	auipc	ra,0xffffa
    800061d0:	372080e7          	jalr	882(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800061d4:	00002517          	auipc	a0,0x2
    800061d8:	5ec50513          	addi	a0,a0,1516 # 800087c0 <syscalls+0x380>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	362080e7          	jalr	866(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800061e4:	00002517          	auipc	a0,0x2
    800061e8:	5fc50513          	addi	a0,a0,1532 # 800087e0 <syscalls+0x3a0>
    800061ec:	ffffa097          	auipc	ra,0xffffa
    800061f0:	352080e7          	jalr	850(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800061f4:	00002517          	auipc	a0,0x2
    800061f8:	60c50513          	addi	a0,a0,1548 # 80008800 <syscalls+0x3c0>
    800061fc:	ffffa097          	auipc	ra,0xffffa
    80006200:	342080e7          	jalr	834(ra) # 8000053e <panic>

0000000080006204 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006204:	7119                	addi	sp,sp,-128
    80006206:	fc86                	sd	ra,120(sp)
    80006208:	f8a2                	sd	s0,112(sp)
    8000620a:	f4a6                	sd	s1,104(sp)
    8000620c:	f0ca                	sd	s2,96(sp)
    8000620e:	ecce                	sd	s3,88(sp)
    80006210:	e8d2                	sd	s4,80(sp)
    80006212:	e4d6                	sd	s5,72(sp)
    80006214:	e0da                	sd	s6,64(sp)
    80006216:	fc5e                	sd	s7,56(sp)
    80006218:	f862                	sd	s8,48(sp)
    8000621a:	f466                	sd	s9,40(sp)
    8000621c:	f06a                	sd	s10,32(sp)
    8000621e:	ec6e                	sd	s11,24(sp)
    80006220:	0100                	addi	s0,sp,128
    80006222:	8aaa                	mv	s5,a0
    80006224:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006226:	00c52d03          	lw	s10,12(a0)
    8000622a:	001d1d1b          	slliw	s10,s10,0x1
    8000622e:	1d02                	slli	s10,s10,0x20
    80006230:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006234:	0001d517          	auipc	a0,0x1d
    80006238:	10450513          	addi	a0,a0,260 # 80023338 <disk+0x128>
    8000623c:	ffffb097          	auipc	ra,0xffffb
    80006240:	99a080e7          	jalr	-1638(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006244:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006246:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006248:	0001db97          	auipc	s7,0x1d
    8000624c:	fc8b8b93          	addi	s7,s7,-56 # 80023210 <disk>
  for(int i = 0; i < 3; i++){
    80006250:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006252:	0001dc97          	auipc	s9,0x1d
    80006256:	0e6c8c93          	addi	s9,s9,230 # 80023338 <disk+0x128>
    8000625a:	a08d                	j	800062bc <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000625c:	00fb8733          	add	a4,s7,a5
    80006260:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006264:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006266:	0207c563          	bltz	a5,80006290 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000626a:	2905                	addiw	s2,s2,1
    8000626c:	0611                	addi	a2,a2,4
    8000626e:	05690c63          	beq	s2,s6,800062c6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006272:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006274:	0001d717          	auipc	a4,0x1d
    80006278:	f9c70713          	addi	a4,a4,-100 # 80023210 <disk>
    8000627c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000627e:	01874683          	lbu	a3,24(a4)
    80006282:	fee9                	bnez	a3,8000625c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006284:	2785                	addiw	a5,a5,1
    80006286:	0705                	addi	a4,a4,1
    80006288:	fe979be3          	bne	a5,s1,8000627e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000628c:	57fd                	li	a5,-1
    8000628e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006290:	01205d63          	blez	s2,800062aa <virtio_disk_rw+0xa6>
    80006294:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006296:	000a2503          	lw	a0,0(s4)
    8000629a:	00000097          	auipc	ra,0x0
    8000629e:	cfc080e7          	jalr	-772(ra) # 80005f96 <free_desc>
      for(int j = 0; j < i; j++)
    800062a2:	2d85                	addiw	s11,s11,1
    800062a4:	0a11                	addi	s4,s4,4
    800062a6:	ffb918e3          	bne	s2,s11,80006296 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062aa:	85e6                	mv	a1,s9
    800062ac:	0001d517          	auipc	a0,0x1d
    800062b0:	f7c50513          	addi	a0,a0,-132 # 80023228 <disk+0x18>
    800062b4:	ffffc097          	auipc	ra,0xffffc
    800062b8:	e08080e7          	jalr	-504(ra) # 800020bc <sleep>
  for(int i = 0; i < 3; i++){
    800062bc:	f8040a13          	addi	s4,s0,-128
{
    800062c0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062c2:	894e                	mv	s2,s3
    800062c4:	b77d                	j	80006272 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062c6:	f8042583          	lw	a1,-128(s0)
    800062ca:	00a58793          	addi	a5,a1,10
    800062ce:	0792                	slli	a5,a5,0x4

  if(write)
    800062d0:	0001d617          	auipc	a2,0x1d
    800062d4:	f4060613          	addi	a2,a2,-192 # 80023210 <disk>
    800062d8:	00f60733          	add	a4,a2,a5
    800062dc:	018036b3          	snez	a3,s8
    800062e0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062e2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800062e6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062ea:	f6078693          	addi	a3,a5,-160
    800062ee:	6218                	ld	a4,0(a2)
    800062f0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062f2:	00878513          	addi	a0,a5,8
    800062f6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062f8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062fa:	6208                	ld	a0,0(a2)
    800062fc:	96aa                	add	a3,a3,a0
    800062fe:	4741                	li	a4,16
    80006300:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006302:	4705                	li	a4,1
    80006304:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006308:	f8442703          	lw	a4,-124(s0)
    8000630c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006310:	0712                	slli	a4,a4,0x4
    80006312:	953a                	add	a0,a0,a4
    80006314:	058a8693          	addi	a3,s5,88
    80006318:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000631a:	6208                	ld	a0,0(a2)
    8000631c:	972a                	add	a4,a4,a0
    8000631e:	40000693          	li	a3,1024
    80006322:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006324:	001c3c13          	seqz	s8,s8
    80006328:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000632a:	001c6c13          	ori	s8,s8,1
    8000632e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006332:	f8842603          	lw	a2,-120(s0)
    80006336:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000633a:	0001d697          	auipc	a3,0x1d
    8000633e:	ed668693          	addi	a3,a3,-298 # 80023210 <disk>
    80006342:	00258713          	addi	a4,a1,2
    80006346:	0712                	slli	a4,a4,0x4
    80006348:	9736                	add	a4,a4,a3
    8000634a:	587d                	li	a6,-1
    8000634c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006350:	0612                	slli	a2,a2,0x4
    80006352:	9532                	add	a0,a0,a2
    80006354:	f9078793          	addi	a5,a5,-112
    80006358:	97b6                	add	a5,a5,a3
    8000635a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000635c:	629c                	ld	a5,0(a3)
    8000635e:	97b2                	add	a5,a5,a2
    80006360:	4605                	li	a2,1
    80006362:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006364:	4509                	li	a0,2
    80006366:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000636a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000636e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006372:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006376:	6698                	ld	a4,8(a3)
    80006378:	00275783          	lhu	a5,2(a4)
    8000637c:	8b9d                	andi	a5,a5,7
    8000637e:	0786                	slli	a5,a5,0x1
    80006380:	97ba                	add	a5,a5,a4
    80006382:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006386:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000638a:	6698                	ld	a4,8(a3)
    8000638c:	00275783          	lhu	a5,2(a4)
    80006390:	2785                	addiw	a5,a5,1
    80006392:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006396:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000639a:	100017b7          	lui	a5,0x10001
    8000639e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063a2:	004aa783          	lw	a5,4(s5)
    800063a6:	02c79163          	bne	a5,a2,800063c8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800063aa:	0001d917          	auipc	s2,0x1d
    800063ae:	f8e90913          	addi	s2,s2,-114 # 80023338 <disk+0x128>
  while(b->disk == 1) {
    800063b2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800063b4:	85ca                	mv	a1,s2
    800063b6:	8556                	mv	a0,s5
    800063b8:	ffffc097          	auipc	ra,0xffffc
    800063bc:	d04080e7          	jalr	-764(ra) # 800020bc <sleep>
  while(b->disk == 1) {
    800063c0:	004aa783          	lw	a5,4(s5)
    800063c4:	fe9788e3          	beq	a5,s1,800063b4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800063c8:	f8042903          	lw	s2,-128(s0)
    800063cc:	00290793          	addi	a5,s2,2
    800063d0:	00479713          	slli	a4,a5,0x4
    800063d4:	0001d797          	auipc	a5,0x1d
    800063d8:	e3c78793          	addi	a5,a5,-452 # 80023210 <disk>
    800063dc:	97ba                	add	a5,a5,a4
    800063de:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063e2:	0001d997          	auipc	s3,0x1d
    800063e6:	e2e98993          	addi	s3,s3,-466 # 80023210 <disk>
    800063ea:	00491713          	slli	a4,s2,0x4
    800063ee:	0009b783          	ld	a5,0(s3)
    800063f2:	97ba                	add	a5,a5,a4
    800063f4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063f8:	854a                	mv	a0,s2
    800063fa:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063fe:	00000097          	auipc	ra,0x0
    80006402:	b98080e7          	jalr	-1128(ra) # 80005f96 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006406:	8885                	andi	s1,s1,1
    80006408:	f0ed                	bnez	s1,800063ea <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000640a:	0001d517          	auipc	a0,0x1d
    8000640e:	f2e50513          	addi	a0,a0,-210 # 80023338 <disk+0x128>
    80006412:	ffffb097          	auipc	ra,0xffffb
    80006416:	878080e7          	jalr	-1928(ra) # 80000c8a <release>
}
    8000641a:	70e6                	ld	ra,120(sp)
    8000641c:	7446                	ld	s0,112(sp)
    8000641e:	74a6                	ld	s1,104(sp)
    80006420:	7906                	ld	s2,96(sp)
    80006422:	69e6                	ld	s3,88(sp)
    80006424:	6a46                	ld	s4,80(sp)
    80006426:	6aa6                	ld	s5,72(sp)
    80006428:	6b06                	ld	s6,64(sp)
    8000642a:	7be2                	ld	s7,56(sp)
    8000642c:	7c42                	ld	s8,48(sp)
    8000642e:	7ca2                	ld	s9,40(sp)
    80006430:	7d02                	ld	s10,32(sp)
    80006432:	6de2                	ld	s11,24(sp)
    80006434:	6109                	addi	sp,sp,128
    80006436:	8082                	ret

0000000080006438 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006438:	1101                	addi	sp,sp,-32
    8000643a:	ec06                	sd	ra,24(sp)
    8000643c:	e822                	sd	s0,16(sp)
    8000643e:	e426                	sd	s1,8(sp)
    80006440:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006442:	0001d497          	auipc	s1,0x1d
    80006446:	dce48493          	addi	s1,s1,-562 # 80023210 <disk>
    8000644a:	0001d517          	auipc	a0,0x1d
    8000644e:	eee50513          	addi	a0,a0,-274 # 80023338 <disk+0x128>
    80006452:	ffffa097          	auipc	ra,0xffffa
    80006456:	784080e7          	jalr	1924(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000645a:	10001737          	lui	a4,0x10001
    8000645e:	533c                	lw	a5,96(a4)
    80006460:	8b8d                	andi	a5,a5,3
    80006462:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006464:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006468:	689c                	ld	a5,16(s1)
    8000646a:	0204d703          	lhu	a4,32(s1)
    8000646e:	0027d783          	lhu	a5,2(a5)
    80006472:	04f70863          	beq	a4,a5,800064c2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006476:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000647a:	6898                	ld	a4,16(s1)
    8000647c:	0204d783          	lhu	a5,32(s1)
    80006480:	8b9d                	andi	a5,a5,7
    80006482:	078e                	slli	a5,a5,0x3
    80006484:	97ba                	add	a5,a5,a4
    80006486:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006488:	00278713          	addi	a4,a5,2
    8000648c:	0712                	slli	a4,a4,0x4
    8000648e:	9726                	add	a4,a4,s1
    80006490:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006494:	e721                	bnez	a4,800064dc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006496:	0789                	addi	a5,a5,2
    80006498:	0792                	slli	a5,a5,0x4
    8000649a:	97a6                	add	a5,a5,s1
    8000649c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000649e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064a2:	ffffc097          	auipc	ra,0xffffc
    800064a6:	c88080e7          	jalr	-888(ra) # 8000212a <wakeup>

    disk.used_idx += 1;
    800064aa:	0204d783          	lhu	a5,32(s1)
    800064ae:	2785                	addiw	a5,a5,1
    800064b0:	17c2                	slli	a5,a5,0x30
    800064b2:	93c1                	srli	a5,a5,0x30
    800064b4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064b8:	6898                	ld	a4,16(s1)
    800064ba:	00275703          	lhu	a4,2(a4)
    800064be:	faf71ce3          	bne	a4,a5,80006476 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800064c2:	0001d517          	auipc	a0,0x1d
    800064c6:	e7650513          	addi	a0,a0,-394 # 80023338 <disk+0x128>
    800064ca:	ffffa097          	auipc	ra,0xffffa
    800064ce:	7c0080e7          	jalr	1984(ra) # 80000c8a <release>
}
    800064d2:	60e2                	ld	ra,24(sp)
    800064d4:	6442                	ld	s0,16(sp)
    800064d6:	64a2                	ld	s1,8(sp)
    800064d8:	6105                	addi	sp,sp,32
    800064da:	8082                	ret
      panic("virtio_disk_intr status");
    800064dc:	00002517          	auipc	a0,0x2
    800064e0:	33c50513          	addi	a0,a0,828 # 80008818 <syscalls+0x3d8>
    800064e4:	ffffa097          	auipc	ra,0xffffa
    800064e8:	05a080e7          	jalr	90(ra) # 8000053e <panic>
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
