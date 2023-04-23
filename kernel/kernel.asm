
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	89013103          	ld	sp,-1904(sp) # 80008890 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	89e70713          	addi	a4,a4,-1890 # 800088f0 <timer_scratch>
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
    80000068:	efc78793          	addi	a5,a5,-260 # 80005f60 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb49f>
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
    80000130:	4de080e7          	jalr	1246(ra) # 8000260a <either_copyin>
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
    8000018e:	8a650513          	addi	a0,a0,-1882 # 80010a30 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	89648493          	addi	s1,s1,-1898 # 80010a30 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	92690913          	addi	s2,s2,-1754 # 80010ac8 <cons+0x98>
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
    800001cc:	28a080e7          	jalr	650(ra) # 80002452 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f66080e7          	jalr	-154(ra) # 8000213c <sleep>
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
    80000216:	3a0080e7          	jalr	928(ra) # 800025b2 <either_copyout>
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
    8000022a:	80a50513          	addi	a0,a0,-2038 # 80010a30 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00010517          	auipc	a0,0x10
    80000240:	7f450513          	addi	a0,a0,2036 # 80010a30 <cons>
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
    80000276:	84f72b23          	sw	a5,-1962(a4) # 80010ac8 <cons+0x98>
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
    800002d0:	76450513          	addi	a0,a0,1892 # 80010a30 <cons>
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
    800002f6:	370080e7          	jalr	880(ra) # 80002662 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	73650513          	addi	a0,a0,1846 # 80010a30 <cons>
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
    80000322:	71270713          	addi	a4,a4,1810 # 80010a30 <cons>
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
    8000034c:	6e878793          	addi	a5,a5,1768 # 80010a30 <cons>
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
    8000037a:	7527a783          	lw	a5,1874(a5) # 80010ac8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6a670713          	addi	a4,a4,1702 # 80010a30 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	69648493          	addi	s1,s1,1686 # 80010a30 <cons>
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
    800003da:	65a70713          	addi	a4,a4,1626 # 80010a30 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6ef72223          	sw	a5,1764(a4) # 80010ad0 <cons+0xa0>
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
    80000416:	61e78793          	addi	a5,a5,1566 # 80010a30 <cons>
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
    8000043a:	68c7ab23          	sw	a2,1686(a5) # 80010acc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	68a50513          	addi	a0,a0,1674 # 80010ac8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	d76080e7          	jalr	-650(ra) # 800021bc <wakeup>
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
    80000464:	5d050513          	addi	a0,a0,1488 # 80010a30 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	d5078793          	addi	a5,a5,-688 # 800221c8 <devsw>
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
    8000054e:	5a07a323          	sw	zero,1446(a5) # 80010af0 <pr+0x18>
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
    80000582:	32f72923          	sw	a5,818(a4) # 800088b0 <panicked>
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
    800005be:	536dad83          	lw	s11,1334(s11) # 80010af0 <pr+0x18>
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
    800005fc:	4e050513          	addi	a0,a0,1248 # 80010ad8 <pr>
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
    8000075a:	38250513          	addi	a0,a0,898 # 80010ad8 <pr>
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
    80000776:	36648493          	addi	s1,s1,870 # 80010ad8 <pr>
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
    800007d6:	32650513          	addi	a0,a0,806 # 80010af8 <uart_tx_lock>
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
    80000802:	0b27a783          	lw	a5,178(a5) # 800088b0 <panicked>
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
    8000083a:	0827b783          	ld	a5,130(a5) # 800088b8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	08273703          	ld	a4,130(a4) # 800088c0 <uart_tx_w>
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
    80000864:	298a0a13          	addi	s4,s4,664 # 80010af8 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	05048493          	addi	s1,s1,80 # 800088b8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	05098993          	addi	s3,s3,80 # 800088c0 <uart_tx_w>
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
    80000896:	92a080e7          	jalr	-1750(ra) # 800021bc <wakeup>
    
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
    800008d2:	22a50513          	addi	a0,a0,554 # 80010af8 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	fd27a783          	lw	a5,-46(a5) # 800088b0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fd873703          	ld	a4,-40(a4) # 800088c0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fc87b783          	ld	a5,-56(a5) # 800088b8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	1fc98993          	addi	s3,s3,508 # 80010af8 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fb448493          	addi	s1,s1,-76 # 800088b8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fb490913          	addi	s2,s2,-76 # 800088c0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	820080e7          	jalr	-2016(ra) # 8000213c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1c648493          	addi	s1,s1,454 # 80010af8 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f6e7bd23          	sd	a4,-134(a5) # 800088c0 <uart_tx_w>
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
    800009c0:	13c48493          	addi	s1,s1,316 # 80010af8 <uart_tx_lock>
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
    80000a02:	96278793          	addi	a5,a5,-1694 # 80023360 <end>
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
    80000a22:	11290913          	addi	s2,s2,274 # 80010b30 <kmem>
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
    80000abe:	07650513          	addi	a0,a0,118 # 80010b30 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	89250513          	addi	a0,a0,-1902 # 80023360 <end>
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
    80000af4:	04048493          	addi	s1,s1,64 # 80010b30 <kmem>
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
    80000b0c:	02850513          	addi	a0,a0,40 # 80010b30 <kmem>
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
    80000b38:	ffc50513          	addi	a0,a0,-4 # 80010b30 <kmem>
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
    80000e8c:	a4070713          	addi	a4,a4,-1472 # 800088c8 <started>
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
    80000ec2:	ad2080e7          	jalr	-1326(ra) # 80002990 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	0da080e7          	jalr	218(ra) # 80005fa0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	006080e7          	jalr	6(ra) # 80001ed4 <scheduler>
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
    80000f3a:	a32080e7          	jalr	-1486(ra) # 80002968 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a52080e7          	jalr	-1454(ra) # 80002990 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	044080e7          	jalr	68(ra) # 80005f8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	052080e7          	jalr	82(ra) # 80005fa0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	1d2080e7          	jalr	466(ra) # 80003128 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	876080e7          	jalr	-1930(ra) # 800037d4 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	814080e7          	jalr	-2028(ra) # 8000477a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	13a080e7          	jalr	314(ra) # 800060a8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	cde080e7          	jalr	-802(ra) # 80001c54 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	94f72223          	sw	a5,-1724(a4) # 800088c8 <started>
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
    80000f9c:	9387b783          	ld	a5,-1736(a5) # 800088d0 <kernel_pagetable>
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
    80001258:	66a7be23          	sd	a0,1660(a5) # 800088d0 <kernel_pagetable>
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
    80001852:	73290913          	addi	s2,s2,1842 # 80010f80 <proc>
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
    8000186c:	718a8a93          	addi	s5,s5,1816 # 80017f80 <tickslock>
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
    800018e8:	26c50513          	addi	a0,a0,620 # 80010b50 <pid_lock>
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	25a080e7          	jalr	602(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f4:	00007597          	auipc	a1,0x7
    800018f8:	8f458593          	addi	a1,a1,-1804 # 800081e8 <digits+0x1a8>
    800018fc:	0000f517          	auipc	a0,0xf
    80001900:	26c50513          	addi	a0,a0,620 # 80010b68 <wait_lock>
    80001904:	fffff097          	auipc	ra,0xfffff
    80001908:	242080e7          	jalr	578(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190c:	0000f497          	auipc	s1,0xf
    80001910:	67448493          	addi	s1,s1,1652 # 80010f80 <proc>
     initlock(&p->lock, "proc"); 
    80001914:	00007997          	auipc	s3,0x7
    80001918:	8e498993          	addi	s3,s3,-1820 # 800081f8 <digits+0x1b8>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191c:	00016917          	auipc	s2,0x16
    80001920:	66490913          	addi	s2,s2,1636 # 80017f80 <tickslock>
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
    8000193a:	dda080e7          	jalr	-550(ra) # 80002710 <kthreadinit>
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
    80001974:	21050513          	addi	a0,a0,528 # 80010b80 <cpus>
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
    800019a0:	1b448493          	addi	s1,s1,436 # 80010b50 <pid_lock>
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
    800019e6:	16e90913          	addi	s2,s2,366 # 80010b50 <pid_lock>
    800019ea:	854a                	mv	a0,s2
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	1ea080e7          	jalr	490(ra) # 80000bd6 <acquire>
  pid = nextpid;
    800019f4:	00007797          	auipc	a5,0x7
    800019f8:	e5078793          	addi	a5,a5,-432 # 80008844 <nextpid>
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
    80001b2c:	d7a080e7          	jalr	-646(ra) # 800028a2 <freethread>
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
    80001b90:	3f448493          	addi	s1,s1,1012 # 80010f80 <proc>
    80001b94:	00016917          	auipc	s2,0x16
    80001b98:	3ec90913          	addi	s2,s2,1004 # 80017f80 <tickslock>
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
    80001bbc:	4901                	li	s2,0
    80001bbe:	a091                	j	80001c02 <allocproc+0x82>
  p->p_counter=1;
    80001bc0:	4905                	li	s2,1
    80001bc2:	1b24a023          	sw	s2,416(s1)
  p->pid = allocpid();
    80001bc6:	00000097          	auipc	ra,0x0
    80001bca:	e10080e7          	jalr	-496(ra) # 800019d6 <allocpid>
    80001bce:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001bd0:	0124ac23          	sw	s2,24(s1)
  struct kthread *new_t=allockthread(p);
    80001bd4:	8526                	mv	a0,s1
    80001bd6:	00001097          	auipc	ra,0x1
    80001bda:	c4c080e7          	jalr	-948(ra) # 80002822 <allockthread>
  if(new_t==0){
    80001bde:	c90d                	beqz	a0,80001c10 <allocproc+0x90>
  if((p->base_trapframes = (struct trapframe *)kalloc()) == 0){
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	f06080e7          	jalr	-250(ra) # 80000ae6 <kalloc>
    80001be8:	892a                	mv	s2,a0
    80001bea:	f4e8                	sd	a0,232(s1)
    80001bec:	cd15                	beqz	a0,80001c28 <allocproc+0xa8>
  p->pagetable = proc_pagetable(p);
    80001bee:	8526                	mv	a0,s1
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	e2c080e7          	jalr	-468(ra) # 80001a1c <proc_pagetable>
    80001bf8:	892a                	mv	s2,a0
    80001bfa:	10a4b023          	sd	a0,256(s1)
  if(p->pagetable == 0){
    80001bfe:	c121                	beqz	a0,80001c3e <allocproc+0xbe>
  return 0;
    80001c00:	4901                	li	s2,0
}
    80001c02:	854a                	mv	a0,s2
    80001c04:	60e2                	ld	ra,24(sp)
    80001c06:	6442                	ld	s0,16(sp)
    80001c08:	64a2                	ld	s1,8(sp)
    80001c0a:	6902                	ld	s2,0(sp)
    80001c0c:	6105                	addi	sp,sp,32
    80001c0e:	8082                	ret
    freeproc(p);
    80001c10:	8526                	mv	a0,s1
    80001c12:	00000097          	auipc	ra,0x0
    80001c16:	ef8080e7          	jalr	-264(ra) # 80001b0a <freeproc>
     release(&p->lock);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	fffff097          	auipc	ra,0xfffff
    80001c20:	06e080e7          	jalr	110(ra) # 80000c8a <release>
    return (struct proc *)-1;
    80001c24:	597d                	li	s2,-1
    80001c26:	bff1                	j	80001c02 <allocproc+0x82>
    freeproc(p);
    80001c28:	8526                	mv	a0,s1
    80001c2a:	00000097          	auipc	ra,0x0
    80001c2e:	ee0080e7          	jalr	-288(ra) # 80001b0a <freeproc>
    release(&p->lock);
    80001c32:	8526                	mv	a0,s1
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	056080e7          	jalr	86(ra) # 80000c8a <release>
    return 0;
    80001c3c:	b7d9                	j	80001c02 <allocproc+0x82>
    freeproc(p);
    80001c3e:	8526                	mv	a0,s1
    80001c40:	00000097          	auipc	ra,0x0
    80001c44:	eca080e7          	jalr	-310(ra) # 80001b0a <freeproc>
    release(&p->lock);
    80001c48:	8526                	mv	a0,s1
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	040080e7          	jalr	64(ra) # 80000c8a <release>
    return 0;
    80001c52:	bf45                	j	80001c02 <allocproc+0x82>

0000000080001c54 <userinit>:
};

// Set up first user process.
void
userinit(void)
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
  struct proc *p;
  p = allocproc();
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	f20080e7          	jalr	-224(ra) # 80001b80 <allocproc>
    80001c68:	84aa                	mv	s1,a0
  initproc = p;
    80001c6a:	00007797          	auipc	a5,0x7
    80001c6e:	c6a7b723          	sd	a0,-914(a5) # 800088d8 <initproc>
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c72:	03400613          	li	a2,52
    80001c76:	00007597          	auipc	a1,0x7
    80001c7a:	bda58593          	addi	a1,a1,-1062 # 80008850 <initcode>
    80001c7e:	10053503          	ld	a0,256(a0)
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	6d4080e7          	jalr	1748(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001c8a:	6905                	lui	s2,0x1
    80001c8c:	0f24bc23          	sd	s2,248(s1)
  // prepare for the very first "return" from kernel to user.
  mykthread()->trapframe->epc = 0;      // user program counter
    80001c90:	00001097          	auipc	ra,0x1
    80001c94:	af2080e7          	jalr	-1294(ra) # 80002782 <mykthread>
    80001c98:	7d5c                	ld	a5,184(a0)
    80001c9a:	0007bc23          	sd	zero,24(a5)
  mykthread()->trapframe->sp = PGSIZE;  // user stack pointer
    80001c9e:	00001097          	auipc	ra,0x1
    80001ca2:	ae4080e7          	jalr	-1308(ra) # 80002782 <mykthread>
    80001ca6:	7d5c                	ld	a5,184(a0)
    80001ca8:	0327b823          	sd	s2,48(a5)
  mykthread()->t_state=RUNNABLE_t;
    80001cac:	00001097          	auipc	ra,0x1
    80001cb0:	ad6080e7          	jalr	-1322(ra) # 80002782 <mykthread>
    80001cb4:	478d                	li	a5,3
    80001cb6:	cd1c                	sw	a5,24(a0)
  release(&(mykthread()->t_lock));
    80001cb8:	00001097          	auipc	ra,0x1
    80001cbc:	aca080e7          	jalr	-1334(ra) # 80002782 <mykthread>
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	fca080e7          	jalr	-54(ra) # 80000c8a <release>
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc8:	4641                	li	a2,16
    80001cca:	00006597          	auipc	a1,0x6
    80001cce:	53658593          	addi	a1,a1,1334 # 80008200 <digits+0x1c0>
    80001cd2:	19048513          	addi	a0,s1,400
    80001cd6:	fffff097          	auipc	ra,0xfffff
    80001cda:	146080e7          	jalr	326(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cde:	00006517          	auipc	a0,0x6
    80001ce2:	53250513          	addi	a0,a0,1330 # 80008210 <digits+0x1d0>
    80001ce6:	00002097          	auipc	ra,0x2
    80001cea:	490080e7          	jalr	1168(ra) # 80004176 <namei>
    80001cee:	18a4b423          	sd	a0,392(s1)

  // p->state = RUNNABLE;

  release(&p->lock);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	fffff097          	auipc	ra,0xfffff
    80001cf8:	f96080e7          	jalr	-106(ra) # 80000c8a <release>
}
    80001cfc:	60e2                	ld	ra,24(sp)
    80001cfe:	6442                	ld	s0,16(sp)
    80001d00:	64a2                	ld	s1,8(sp)
    80001d02:	6902                	ld	s2,0(sp)
    80001d04:	6105                	addi	sp,sp,32
    80001d06:	8082                	ret

0000000080001d08 <growproc>:

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
    80001d08:	1101                	addi	sp,sp,-32
    80001d0a:	ec06                	sd	ra,24(sp)
    80001d0c:	e822                	sd	s0,16(sp)
    80001d0e:	e426                	sd	s1,8(sp)
    80001d10:	e04a                	sd	s2,0(sp)
    80001d12:	1000                	addi	s0,sp,32
    80001d14:	892a                	mv	s2,a0
  uint64 sz;
  struct proc *p = myproc();
    80001d16:	00000097          	auipc	ra,0x0
    80001d1a:	c6a080e7          	jalr	-918(ra) # 80001980 <myproc>
    80001d1e:	84aa                	mv	s1,a0

  sz = p->sz;
    80001d20:	7d6c                	ld	a1,248(a0)
  if(n > 0){
    80001d22:	01204c63          	bgtz	s2,80001d3a <growproc+0x32>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    80001d26:	02094763          	bltz	s2,80001d54 <growproc+0x4c>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
    80001d2a:	fcec                	sd	a1,248(s1)
  return 0;
    80001d2c:	4501                	li	a0,0
}
    80001d2e:	60e2                	ld	ra,24(sp)
    80001d30:	6442                	ld	s0,16(sp)
    80001d32:	64a2                	ld	s1,8(sp)
    80001d34:	6902                	ld	s2,0(sp)
    80001d36:	6105                	addi	sp,sp,32
    80001d38:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d3a:	4691                	li	a3,4
    80001d3c:	00b90633          	add	a2,s2,a1
    80001d40:	10053503          	ld	a0,256(a0)
    80001d44:	fffff097          	auipc	ra,0xfffff
    80001d48:	6cc080e7          	jalr	1740(ra) # 80001410 <uvmalloc>
    80001d4c:	85aa                	mv	a1,a0
    80001d4e:	fd71                	bnez	a0,80001d2a <growproc+0x22>
      return -1;
    80001d50:	557d                	li	a0,-1
    80001d52:	bff1                	j	80001d2e <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d54:	00b90633          	add	a2,s2,a1
    80001d58:	10053503          	ld	a0,256(a0)
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	66c080e7          	jalr	1644(ra) # 800013c8 <uvmdealloc>
    80001d64:	85aa                	mv	a1,a0
    80001d66:	b7d1                	j	80001d2a <growproc+0x22>

0000000080001d68 <fork>:

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
    80001d68:	7139                	addi	sp,sp,-64
    80001d6a:	fc06                	sd	ra,56(sp)
    80001d6c:	f822                	sd	s0,48(sp)
    80001d6e:	f426                	sd	s1,40(sp)
    80001d70:	f04a                	sd	s2,32(sp)
    80001d72:	ec4e                	sd	s3,24(sp)
    80001d74:	e852                	sd	s4,16(sp)
    80001d76:	e456                	sd	s5,8(sp)
    80001d78:	0080                	addi	s0,sp,64
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
    80001d7a:	00000097          	auipc	ra,0x0
    80001d7e:	c06080e7          	jalr	-1018(ra) # 80001980 <myproc>
    80001d82:	8aaa                	mv	s5,a0
  struct kthread *kt = mykthread();
    80001d84:	00001097          	auipc	ra,0x1
    80001d88:	9fe080e7          	jalr	-1538(ra) # 80002782 <mykthread>
    80001d8c:	84aa                	mv	s1,a0

  // Allocate process.
  if((np = allocproc()) == 0){
    80001d8e:	00000097          	auipc	ra,0x0
    80001d92:	df2080e7          	jalr	-526(ra) # 80001b80 <allocproc>
    80001d96:	12050d63          	beqz	a0,80001ed0 <fork+0x168>
    80001d9a:	89aa                	mv	s3,a0
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d9c:	0f8ab603          	ld	a2,248(s5)
    80001da0:	10053583          	ld	a1,256(a0)
    80001da4:	100ab503          	ld	a0,256(s5)
    80001da8:	fffff097          	auipc	ra,0xfffff
    80001dac:	7bc080e7          	jalr	1980(ra) # 80001564 <uvmcopy>
    80001db0:	04054763          	bltz	a0,80001dfe <fork+0x96>
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;
    80001db4:	0f8ab783          	ld	a5,248(s5)
    80001db8:	0ef9bc23          	sd	a5,248(s3)
  //   freeproc(np);
  //    release(&np->lock);
  //   return -1;
  // }
  // copy saved user registers.
  *(np->kthread[0].trapframe) = *(kt->trapframe);
    80001dbc:	7cd4                	ld	a3,184(s1)
    80001dbe:	87b6                	mv	a5,a3
    80001dc0:	0e09b703          	ld	a4,224(s3)
    80001dc4:	12068693          	addi	a3,a3,288
    80001dc8:	0007b803          	ld	a6,0(a5)
    80001dcc:	6788                	ld	a0,8(a5)
    80001dce:	6b8c                	ld	a1,16(a5)
    80001dd0:	6f90                	ld	a2,24(a5)
    80001dd2:	01073023          	sd	a6,0(a4)
    80001dd6:	e708                	sd	a0,8(a4)
    80001dd8:	eb0c                	sd	a1,16(a4)
    80001dda:	ef10                	sd	a2,24(a4)
    80001ddc:	02078793          	addi	a5,a5,32
    80001de0:	02070713          	addi	a4,a4,32
    80001de4:	fed792e3          	bne	a5,a3,80001dc8 <fork+0x60>

  // Cause fork to return 0 in the child.
  np->kthread[0].trapframe->a0 = 0;
    80001de8:	0e09b783          	ld	a5,224(s3)
    80001dec:	0607b823          	sd	zero,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    80001df0:	108a8493          	addi	s1,s5,264
    80001df4:	10898913          	addi	s2,s3,264
    80001df8:	188a8a13          	addi	s4,s5,392
    80001dfc:	a00d                	j	80001e1e <fork+0xb6>
    freeproc(np);
    80001dfe:	854e                	mv	a0,s3
    80001e00:	00000097          	auipc	ra,0x0
    80001e04:	d0a080e7          	jalr	-758(ra) # 80001b0a <freeproc>
    release(&np->lock);
    80001e08:	854e                	mv	a0,s3
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	e80080e7          	jalr	-384(ra) # 80000c8a <release>
    return -1;
    80001e12:	5a7d                	li	s4,-1
    80001e14:	a065                	j	80001ebc <fork+0x154>
  for(i = 0; i < NOFILE; i++)
    80001e16:	04a1                	addi	s1,s1,8
    80001e18:	0921                	addi	s2,s2,8
    80001e1a:	01448b63          	beq	s1,s4,80001e30 <fork+0xc8>
    if(p->ofile[i])
    80001e1e:	6088                	ld	a0,0(s1)
    80001e20:	d97d                	beqz	a0,80001e16 <fork+0xae>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e22:	00003097          	auipc	ra,0x3
    80001e26:	9ea080e7          	jalr	-1558(ra) # 8000480c <filedup>
    80001e2a:	00a93023          	sd	a0,0(s2) # 1000 <_entry-0x7ffff000>
    80001e2e:	b7e5                	j	80001e16 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001e30:	188ab503          	ld	a0,392(s5)
    80001e34:	00002097          	auipc	ra,0x2
    80001e38:	b5e080e7          	jalr	-1186(ra) # 80003992 <idup>
    80001e3c:	18a9b423          	sd	a0,392(s3)

  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e40:	4641                	li	a2,16
    80001e42:	190a8593          	addi	a1,s5,400
    80001e46:	19098513          	addi	a0,s3,400
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	fd2080e7          	jalr	-46(ra) # 80000e1c <safestrcpy>

  pid = np->pid;
    80001e52:	0249aa03          	lw	s4,36(s3)

  release(&np->kthread[0].t_lock);///acqire in allockthread
    80001e56:	02898493          	addi	s1,s3,40
    80001e5a:	8526                	mv	a0,s1
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	e2e080e7          	jalr	-466(ra) # 80000c8a <release>
  release(&np->lock);///acqire in allocproc
    80001e64:	854e                	mv	a0,s3
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	e24080e7          	jalr	-476(ra) # 80000c8a <release>

  acquire(&wait_lock);
    80001e6e:	0000f917          	auipc	s2,0xf
    80001e72:	cfa90913          	addi	s2,s2,-774 # 80010b68 <wait_lock>
    80001e76:	854a                	mv	a0,s2
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	d5e080e7          	jalr	-674(ra) # 80000bd6 <acquire>
  acquire(&np->lock);
    80001e80:	854e                	mv	a0,s3
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	d54080e7          	jalr	-684(ra) # 80000bd6 <acquire>
  acquire(&np->kthread[0].t_lock);
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	d4a080e7          	jalr	-694(ra) # 80000bd6 <acquire>

  np->parent = p;
    80001e94:	0f59b823          	sd	s5,240(s3)
  // np->state=RUNNABLE;
  np->kthread[0].t_state = RUNNABLE_t;
    80001e98:	478d                	li	a5,3
    80001e9a:	04f9a023          	sw	a5,64(s3)

  release(&np->kthread[0].t_lock);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	dea080e7          	jalr	-534(ra) # 80000c8a <release>
  release(&np->lock);
    80001ea8:	854e                	mv	a0,s3
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	de0080e7          	jalr	-544(ra) # 80000c8a <release>
  release(&wait_lock);
    80001eb2:	854a                	mv	a0,s2
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	dd6080e7          	jalr	-554(ra) # 80000c8a <release>


  return pid;
}
    80001ebc:	8552                	mv	a0,s4
    80001ebe:	70e2                	ld	ra,56(sp)
    80001ec0:	7442                	ld	s0,48(sp)
    80001ec2:	74a2                	ld	s1,40(sp)
    80001ec4:	7902                	ld	s2,32(sp)
    80001ec6:	69e2                	ld	s3,24(sp)
    80001ec8:	6a42                	ld	s4,16(sp)
    80001eca:	6aa2                	ld	s5,8(sp)
    80001ecc:	6121                	addi	sp,sp,64
    80001ece:	8082                	ret
    return -1;
    80001ed0:	5a7d                	li	s4,-1
    80001ed2:	b7ed                	j	80001ebc <fork+0x154>

0000000080001ed4 <scheduler>:
// }


void
scheduler(void)
{
    80001ed4:	715d                	addi	sp,sp,-80
    80001ed6:	e486                	sd	ra,72(sp)
    80001ed8:	e0a2                	sd	s0,64(sp)
    80001eda:	fc26                	sd	s1,56(sp)
    80001edc:	f84a                	sd	s2,48(sp)
    80001ede:	f44e                	sd	s3,40(sp)
    80001ee0:	f052                	sd	s4,32(sp)
    80001ee2:	ec56                	sd	s5,24(sp)
    80001ee4:	e85a                	sd	s6,16(sp)
    80001ee6:	e45e                	sd	s7,8(sp)
    80001ee8:	0880                	addi	s0,sp,80
    80001eea:	8792                	mv	a5,tp
  int id = r_tp();
    80001eec:	2781                	sext.w	a5,a5
  struct proc *p;
  struct cpu *c = mycpu();
  
  c->kthread = 0;
    80001eee:	00779b13          	slli	s6,a5,0x7
    80001ef2:	0000f717          	auipc	a4,0xf
    80001ef6:	c5e70713          	addi	a4,a4,-930 # 80010b50 <pid_lock>
    80001efa:	975a                	add	a4,a4,s6
    80001efc:	02073823          	sd	zero,48(a4)
        // Switch to chosen thread.
        t->process = p;
        //  t->trapframe = p->tr;
        t->t_state = RUNNING_t;
        c->kthread = t;
        swtch(&c->context, &t->context);
    80001f00:	0000f717          	auipc	a4,0xf
    80001f04:	c8870713          	addi	a4,a4,-888 # 80010b88 <cpus+0x8>
    80001f08:	9b3a                	add	s6,s6,a4
      if(p->kthread[0].t_state == RUNNABLE_t) {
    80001f0a:	4a0d                	li	s4,3
        t->t_state = RUNNING_t;
    80001f0c:	4b91                	li	s7,4
        c->kthread = t;
    80001f0e:	079e                	slli	a5,a5,0x7
    80001f10:	0000fa97          	auipc	s5,0xf
    80001f14:	c40a8a93          	addi	s5,s5,-960 # 80010b50 <pid_lock>
    80001f18:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00016997          	auipc	s3,0x16
    80001f1e:	06698993          	addi	s3,s3,102 # 80017f80 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f22:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f26:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f2a:	10079073          	csrw	sstatus,a5
    80001f2e:	0000f497          	auipc	s1,0xf
    80001f32:	05248493          	addi	s1,s1,82 # 80010f80 <proc>
    80001f36:	a839                	j	80001f54 <scheduler+0x80>
        c->kthread = 0;
        t->process = 0;
        // t->trapframe = 0;
        release(&t->t_lock); // Release the thread lock
      }
      release(&p->kthread[0].t_lock);
    80001f38:	854a                	mv	a0,s2
    80001f3a:	fffff097          	auipc	ra,0xfffff
    80001f3e:	d50080e7          	jalr	-688(ra) # 80000c8a <release>
      release(&p->lock);
    80001f42:	8526                	mv	a0,s1
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	d46080e7          	jalr	-698(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f4c:	1c048493          	addi	s1,s1,448
    80001f50:	fd3489e3          	beq	s1,s3,80001f22 <scheduler+0x4e>
      acquire(&p->lock);
    80001f54:	8526                	mv	a0,s1
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	c80080e7          	jalr	-896(ra) # 80000bd6 <acquire>
      acquire(&p->kthread[0].t_lock);
    80001f5e:	02848913          	addi	s2,s1,40
    80001f62:	854a                	mv	a0,s2
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	c72080e7          	jalr	-910(ra) # 80000bd6 <acquire>
      if(p->kthread[0].t_state == RUNNABLE_t) {
    80001f6c:	40bc                	lw	a5,64(s1)
    80001f6e:	fd4795e3          	bne	a5,s4,80001f38 <scheduler+0x64>
        acquire(&t->t_lock); // Acquire the thread lock
    80001f72:	854a                	mv	a0,s2
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	c62080e7          	jalr	-926(ra) # 80000bd6 <acquire>
        t->process = p;
    80001f7c:	f0a4                	sd	s1,96(s1)
        t->t_state = RUNNING_t;
    80001f7e:	0574a023          	sw	s7,64(s1)
        c->kthread = t;
    80001f82:	032ab823          	sd	s2,48(s5)
        swtch(&c->context, &t->context);
    80001f86:	06848593          	addi	a1,s1,104
    80001f8a:	855a                	mv	a0,s6
    80001f8c:	00001097          	auipc	ra,0x1
    80001f90:	972080e7          	jalr	-1678(ra) # 800028fe <swtch>
        c->kthread = 0;
    80001f94:	020ab823          	sd	zero,48(s5)
        t->process = 0;
    80001f98:	0604b023          	sd	zero,96(s1)
        release(&t->t_lock); // Release the thread lock
    80001f9c:	854a                	mv	a0,s2
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	cec080e7          	jalr	-788(ra) # 80000c8a <release>
    80001fa6:	bf49                	j	80001f38 <scheduler+0x64>

0000000080001fa8 <sched>:
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    80001fa8:	7179                	addi	sp,sp,-48
    80001faa:	f406                	sd	ra,40(sp)
    80001fac:	f022                	sd	s0,32(sp)
    80001fae:	ec26                	sd	s1,24(sp)
    80001fb0:	e84a                	sd	s2,16(sp)
    80001fb2:	e44e                	sd	s3,8(sp)
    80001fb4:	1800                	addi	s0,sp,48
  int intena;
  struct kthread *t = mykthread();
    80001fb6:	00000097          	auipc	ra,0x0
    80001fba:	7cc080e7          	jalr	1996(ra) # 80002782 <mykthread>
    80001fbe:	84aa                	mv	s1,a0

  if(!holding(&t->t_lock))
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	b9c080e7          	jalr	-1124(ra) # 80000b5c <holding>
    80001fc8:	c93d                	beqz	a0,8000203e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fca:	8792                	mv	a5,tp
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    80001fcc:	2781                	sext.w	a5,a5
    80001fce:	079e                	slli	a5,a5,0x7
    80001fd0:	0000f717          	auipc	a4,0xf
    80001fd4:	b8070713          	addi	a4,a4,-1152 # 80010b50 <pid_lock>
    80001fd8:	97ba                	add	a5,a5,a4
    80001fda:	0a87a703          	lw	a4,168(a5)
    80001fde:	4785                	li	a5,1
    80001fe0:	06f71763          	bne	a4,a5,8000204e <sched+0xa6>
    panic("sched locks");
  if(t->t_state == RUNNING_t)
    80001fe4:	4c98                	lw	a4,24(s1)
    80001fe6:	4791                	li	a5,4
    80001fe8:	06f70b63          	beq	a4,a5,8000205e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fec:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ff0:	8b89                	andi	a5,a5,2
    panic("sched running");
  if(intr_get())
    80001ff2:	efb5                	bnez	a5,8000206e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ff4:	8792                	mv	a5,tp
    panic("sched interruptible");

  intena = mycpu()->intena;
    80001ff6:	0000f917          	auipc	s2,0xf
    80001ffa:	b5a90913          	addi	s2,s2,-1190 # 80010b50 <pid_lock>
    80001ffe:	2781                	sext.w	a5,a5
    80002000:	079e                	slli	a5,a5,0x7
    80002002:	97ca                	add	a5,a5,s2
    80002004:	0ac7a983          	lw	s3,172(a5)
    80002008:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    8000200a:	2781                	sext.w	a5,a5
    8000200c:	079e                	slli	a5,a5,0x7
    8000200e:	0000f597          	auipc	a1,0xf
    80002012:	b7a58593          	addi	a1,a1,-1158 # 80010b88 <cpus+0x8>
    80002016:	95be                	add	a1,a1,a5
    80002018:	04048513          	addi	a0,s1,64
    8000201c:	00001097          	auipc	ra,0x1
    80002020:	8e2080e7          	jalr	-1822(ra) # 800028fe <swtch>
    80002024:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002026:	2781                	sext.w	a5,a5
    80002028:	079e                	slli	a5,a5,0x7
    8000202a:	97ca                	add	a5,a5,s2
    8000202c:	0b37a623          	sw	s3,172(a5)
}
    80002030:	70a2                	ld	ra,40(sp)
    80002032:	7402                	ld	s0,32(sp)
    80002034:	64e2                	ld	s1,24(sp)
    80002036:	6942                	ld	s2,16(sp)
    80002038:	69a2                	ld	s3,8(sp)
    8000203a:	6145                	addi	sp,sp,48
    8000203c:	8082                	ret
    panic("sched p->lock");
    8000203e:	00006517          	auipc	a0,0x6
    80002042:	1da50513          	addi	a0,a0,474 # 80008218 <digits+0x1d8>
    80002046:	ffffe097          	auipc	ra,0xffffe
    8000204a:	4f8080e7          	jalr	1272(ra) # 8000053e <panic>
    panic("sched locks");
    8000204e:	00006517          	auipc	a0,0x6
    80002052:	1da50513          	addi	a0,a0,474 # 80008228 <digits+0x1e8>
    80002056:	ffffe097          	auipc	ra,0xffffe
    8000205a:	4e8080e7          	jalr	1256(ra) # 8000053e <panic>
    panic("sched running");
    8000205e:	00006517          	auipc	a0,0x6
    80002062:	1da50513          	addi	a0,a0,474 # 80008238 <digits+0x1f8>
    80002066:	ffffe097          	auipc	ra,0xffffe
    8000206a:	4d8080e7          	jalr	1240(ra) # 8000053e <panic>
    panic("sched interruptible");
    8000206e:	00006517          	auipc	a0,0x6
    80002072:	1da50513          	addi	a0,a0,474 # 80008248 <digits+0x208>
    80002076:	ffffe097          	auipc	ra,0xffffe
    8000207a:	4c8080e7          	jalr	1224(ra) # 8000053e <panic>

000000008000207e <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
    8000207e:	1101                	addi	sp,sp,-32
    80002080:	ec06                	sd	ra,24(sp)
    80002082:	e822                	sd	s0,16(sp)
    80002084:	e426                	sd	s1,8(sp)
    80002086:	e04a                	sd	s2,0(sp)
    80002088:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	8f6080e7          	jalr	-1802(ra) # 80001980 <myproc>
    80002092:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	b42080e7          	jalr	-1214(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    8000209c:	02848913          	addi	s2,s1,40
    800020a0:	854a                	mv	a0,s2
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	b34080e7          	jalr	-1228(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state = RUNNABLE_t;
    800020aa:	478d                	li	a5,3
    800020ac:	c0bc                	sw	a5,64(s1)
  sched();
    800020ae:	00000097          	auipc	ra,0x0
    800020b2:	efa080e7          	jalr	-262(ra) # 80001fa8 <sched>
  release(&p->kthread[0].t_lock);
    800020b6:	854a                	mv	a0,s2
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	bd2080e7          	jalr	-1070(ra) # 80000c8a <release>
  release(&p->lock);
    800020c0:	8526                	mv	a0,s1
    800020c2:	fffff097          	auipc	ra,0xfffff
    800020c6:	bc8080e7          	jalr	-1080(ra) # 80000c8a <release>
}
    800020ca:	60e2                	ld	ra,24(sp)
    800020cc:	6442                	ld	s0,16(sp)
    800020ce:	64a2                	ld	s1,8(sp)
    800020d0:	6902                	ld	s2,0(sp)
    800020d2:	6105                	addi	sp,sp,32
    800020d4:	8082                	ret

00000000800020d6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800020d6:	1141                	addi	sp,sp,-16
    800020d8:	e406                	sd	ra,8(sp)
    800020da:	e022                	sd	s0,0(sp)
    800020dc:	0800                	addi	s0,sp,16
  printf("forkret\n");
    800020de:	00006517          	auipc	a0,0x6
    800020e2:	18250513          	addi	a0,a0,386 # 80008260 <digits+0x220>
    800020e6:	ffffe097          	auipc	ra,0xffffe
    800020ea:	4a2080e7          	jalr	1186(ra) # 80000588 <printf>
  static int first = 1;
  release(&(mykthread()->t_lock)); //still holding kt->lock from scheduler
    800020ee:	00000097          	auipc	ra,0x0
    800020f2:	694080e7          	jalr	1684(ra) # 80002782 <mykthread>
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	b94080e7          	jalr	-1132(ra) # 80000c8a <release>
  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	882080e7          	jalr	-1918(ra) # 80001980 <myproc>
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	b84080e7          	jalr	-1148(ra) # 80000c8a <release>

  if (first) {
    8000210e:	00006797          	auipc	a5,0x6
    80002112:	7327a783          	lw	a5,1842(a5) # 80008840 <first.1>
    80002116:	eb89                	bnez	a5,80002128 <forkret+0x52>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80002118:	00001097          	auipc	ra,0x1
    8000211c:	890080e7          	jalr	-1904(ra) # 800029a8 <usertrapret>
}
    80002120:	60a2                	ld	ra,8(sp)
    80002122:	6402                	ld	s0,0(sp)
    80002124:	0141                	addi	sp,sp,16
    80002126:	8082                	ret
    first = 0;
    80002128:	00006797          	auipc	a5,0x6
    8000212c:	7007ac23          	sw	zero,1816(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80002130:	4505                	li	a0,1
    80002132:	00001097          	auipc	ra,0x1
    80002136:	622080e7          	jalr	1570(ra) # 80003754 <fsinit>
    8000213a:	bff9                	j	80002118 <forkret+0x42>

000000008000213c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000213c:	7179                	addi	sp,sp,-48
    8000213e:	f406                	sd	ra,40(sp)
    80002140:	f022                	sd	s0,32(sp)
    80002142:	ec26                	sd	s1,24(sp)
    80002144:	e84a                	sd	s2,16(sp)
    80002146:	e44e                	sd	s3,8(sp)
    80002148:	e052                	sd	s4,0(sp)
    8000214a:	1800                	addi	s0,sp,48
    8000214c:	89aa                	mv	s3,a0
    8000214e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002150:	00000097          	auipc	ra,0x0
    80002154:	830080e7          	jalr	-2000(ra) # 80001980 <myproc>
    80002158:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	a7c080e7          	jalr	-1412(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    80002162:	02848a13          	addi	s4,s1,40
    80002166:	8552                	mv	a0,s4
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	a6e080e7          	jalr	-1426(ra) # 80000bd6 <acquire>
  release(lk);
    80002170:	854a                	mv	a0,s2
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	b18080e7          	jalr	-1256(ra) # 80000c8a <release>

  // Go to sleep.
  p->kthread[0].chan = chan;
    8000217a:	0534b423          	sd	s3,72(s1)
  p->kthread[0].t_state = SLEEPING_t;
    8000217e:	4789                	li	a5,2
    80002180:	c0bc                	sw	a5,64(s1)

  sched();
    80002182:	00000097          	auipc	ra,0x0
    80002186:	e26080e7          	jalr	-474(ra) # 80001fa8 <sched>

  // Tidy up.
  p->kthread[0].chan= 0;
    8000218a:	0404b423          	sd	zero,72(s1)

  // Reacquire original lock.
  release(&p->kthread[0].t_lock);
    8000218e:	8552                	mv	a0,s4
    80002190:	fffff097          	auipc	ra,0xfffff
    80002194:	afa080e7          	jalr	-1286(ra) # 80000c8a <release>
  release(&p->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	af0080e7          	jalr	-1296(ra) # 80000c8a <release>
  acquire(lk);
    800021a2:	854a                	mv	a0,s2
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	a32080e7          	jalr	-1486(ra) # 80000bd6 <acquire>
}
    800021ac:	70a2                	ld	ra,40(sp)
    800021ae:	7402                	ld	s0,32(sp)
    800021b0:	64e2                	ld	s1,24(sp)
    800021b2:	6942                	ld	s2,16(sp)
    800021b4:	69a2                	ld	s3,8(sp)
    800021b6:	6a02                	ld	s4,0(sp)
    800021b8:	6145                	addi	sp,sp,48
    800021ba:	8082                	ret

00000000800021bc <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021bc:	7139                	addi	sp,sp,-64
    800021be:	fc06                	sd	ra,56(sp)
    800021c0:	f822                	sd	s0,48(sp)
    800021c2:	f426                	sd	s1,40(sp)
    800021c4:	f04a                	sd	s2,32(sp)
    800021c6:	ec4e                	sd	s3,24(sp)
    800021c8:	e852                	sd	s4,16(sp)
    800021ca:	e456                	sd	s5,8(sp)
    800021cc:	e05a                	sd	s6,0(sp)
    800021ce:	0080                	addi	s0,sp,64
    800021d0:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021d2:	0000f497          	auipc	s1,0xf
    800021d6:	dae48493          	addi	s1,s1,-594 # 80010f80 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      acquire(&p->kthread[0].t_lock);
      if(p->kthread[0].t_state == SLEEPING_t && p->kthread[0].chan == chan) {
    800021da:	4a09                	li	s4,2
        p->kthread[0].t_state = RUNNABLE_t;
    800021dc:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021de:	00016997          	auipc	s3,0x16
    800021e2:	da298993          	addi	s3,s3,-606 # 80017f80 <tickslock>
    800021e6:	a839                	j	80002204 <wakeup+0x48>
      }
      release(&p->kthread[0].t_lock);
    800021e8:	854a                	mv	a0,s2
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	aa0080e7          	jalr	-1376(ra) # 80000c8a <release>
      release(&p->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	a96080e7          	jalr	-1386(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021fc:	1c048493          	addi	s1,s1,448
    80002200:	03348d63          	beq	s1,s3,8000223a <wakeup+0x7e>
    if(p != myproc()){
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	77c080e7          	jalr	1916(ra) # 80001980 <myproc>
    8000220c:	fea488e3          	beq	s1,a0,800021fc <wakeup+0x40>
      acquire(&p->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	9c4080e7          	jalr	-1596(ra) # 80000bd6 <acquire>
      acquire(&p->kthread[0].t_lock);
    8000221a:	02848913          	addi	s2,s1,40
    8000221e:	854a                	mv	a0,s2
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	9b6080e7          	jalr	-1610(ra) # 80000bd6 <acquire>
      if(p->kthread[0].t_state == SLEEPING_t && p->kthread[0].chan == chan) {
    80002228:	40bc                	lw	a5,64(s1)
    8000222a:	fb479fe3          	bne	a5,s4,800021e8 <wakeup+0x2c>
    8000222e:	64bc                	ld	a5,72(s1)
    80002230:	fb579ce3          	bne	a5,s5,800021e8 <wakeup+0x2c>
        p->kthread[0].t_state = RUNNABLE_t;
    80002234:	0564a023          	sw	s6,64(s1)
    80002238:	bf45                	j	800021e8 <wakeup+0x2c>
      
    }
  }
}
    8000223a:	70e2                	ld	ra,56(sp)
    8000223c:	7442                	ld	s0,48(sp)
    8000223e:	74a2                	ld	s1,40(sp)
    80002240:	7902                	ld	s2,32(sp)
    80002242:	69e2                	ld	s3,24(sp)
    80002244:	6a42                	ld	s4,16(sp)
    80002246:	6aa2                	ld	s5,8(sp)
    80002248:	6b02                	ld	s6,0(sp)
    8000224a:	6121                	addi	sp,sp,64
    8000224c:	8082                	ret

000000008000224e <reparent>:
{
    8000224e:	7179                	addi	sp,sp,-48
    80002250:	f406                	sd	ra,40(sp)
    80002252:	f022                	sd	s0,32(sp)
    80002254:	ec26                	sd	s1,24(sp)
    80002256:	e84a                	sd	s2,16(sp)
    80002258:	e44e                	sd	s3,8(sp)
    8000225a:	e052                	sd	s4,0(sp)
    8000225c:	1800                	addi	s0,sp,48
    8000225e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002260:	0000f497          	auipc	s1,0xf
    80002264:	d2048493          	addi	s1,s1,-736 # 80010f80 <proc>
      pp->parent = initproc;
    80002268:	00006a17          	auipc	s4,0x6
    8000226c:	670a0a13          	addi	s4,s4,1648 # 800088d8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002270:	00016997          	auipc	s3,0x16
    80002274:	d1098993          	addi	s3,s3,-752 # 80017f80 <tickslock>
    80002278:	a029                	j	80002282 <reparent+0x34>
    8000227a:	1c048493          	addi	s1,s1,448
    8000227e:	01348d63          	beq	s1,s3,80002298 <reparent+0x4a>
    if(pp->parent == p){
    80002282:	78fc                	ld	a5,240(s1)
    80002284:	ff279be3          	bne	a5,s2,8000227a <reparent+0x2c>
      pp->parent = initproc;
    80002288:	000a3503          	ld	a0,0(s4)
    8000228c:	f8e8                	sd	a0,240(s1)
      wakeup(initproc);
    8000228e:	00000097          	auipc	ra,0x0
    80002292:	f2e080e7          	jalr	-210(ra) # 800021bc <wakeup>
    80002296:	b7d5                	j	8000227a <reparent+0x2c>
}
    80002298:	70a2                	ld	ra,40(sp)
    8000229a:	7402                	ld	s0,32(sp)
    8000229c:	64e2                	ld	s1,24(sp)
    8000229e:	6942                	ld	s2,16(sp)
    800022a0:	69a2                	ld	s3,8(sp)
    800022a2:	6a02                	ld	s4,0(sp)
    800022a4:	6145                	addi	sp,sp,48
    800022a6:	8082                	ret

00000000800022a8 <exit>:
{
    800022a8:	7179                	addi	sp,sp,-48
    800022aa:	f406                	sd	ra,40(sp)
    800022ac:	f022                	sd	s0,32(sp)
    800022ae:	ec26                	sd	s1,24(sp)
    800022b0:	e84a                	sd	s2,16(sp)
    800022b2:	e44e                	sd	s3,8(sp)
    800022b4:	e052                	sd	s4,0(sp)
    800022b6:	1800                	addi	s0,sp,48
    800022b8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	6c6080e7          	jalr	1734(ra) # 80001980 <myproc>
    800022c2:	89aa                	mv	s3,a0
  if(p == initproc)
    800022c4:	00006797          	auipc	a5,0x6
    800022c8:	6147b783          	ld	a5,1556(a5) # 800088d8 <initproc>
    800022cc:	10850493          	addi	s1,a0,264
    800022d0:	18850913          	addi	s2,a0,392
    800022d4:	02a79363          	bne	a5,a0,800022fa <exit+0x52>
    panic("init exiting");
    800022d8:	00006517          	auipc	a0,0x6
    800022dc:	f9850513          	addi	a0,a0,-104 # 80008270 <digits+0x230>
    800022e0:	ffffe097          	auipc	ra,0xffffe
    800022e4:	25e080e7          	jalr	606(ra) # 8000053e <panic>
      fileclose(f);
    800022e8:	00002097          	auipc	ra,0x2
    800022ec:	576080e7          	jalr	1398(ra) # 8000485e <fileclose>
      p->ofile[fd] = 0;
    800022f0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022f4:	04a1                	addi	s1,s1,8
    800022f6:	01248563          	beq	s1,s2,80002300 <exit+0x58>
    if(p->ofile[fd]){
    800022fa:	6088                	ld	a0,0(s1)
    800022fc:	f575                	bnez	a0,800022e8 <exit+0x40>
    800022fe:	bfdd                	j	800022f4 <exit+0x4c>
  begin_op();
    80002300:	00002097          	auipc	ra,0x2
    80002304:	092080e7          	jalr	146(ra) # 80004392 <begin_op>
  iput(p->cwd);
    80002308:	1889b503          	ld	a0,392(s3)
    8000230c:	00002097          	auipc	ra,0x2
    80002310:	87e080e7          	jalr	-1922(ra) # 80003b8a <iput>
  end_op();
    80002314:	00002097          	auipc	ra,0x2
    80002318:	0fe080e7          	jalr	254(ra) # 80004412 <end_op>
  p->cwd = 0;
    8000231c:	1809b423          	sd	zero,392(s3)
  acquire(&wait_lock);
    80002320:	0000f497          	auipc	s1,0xf
    80002324:	84848493          	addi	s1,s1,-1976 # 80010b68 <wait_lock>
    80002328:	8526                	mv	a0,s1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	8ac080e7          	jalr	-1876(ra) # 80000bd6 <acquire>
  reparent(p);
    80002332:	854e                	mv	a0,s3
    80002334:	00000097          	auipc	ra,0x0
    80002338:	f1a080e7          	jalr	-230(ra) # 8000224e <reparent>
  wakeup(p->parent);
    8000233c:	0f09b503          	ld	a0,240(s3)
    80002340:	00000097          	auipc	ra,0x0
    80002344:	e7c080e7          	jalr	-388(ra) # 800021bc <wakeup>
  acquire(&p->lock);
    80002348:	854e                	mv	a0,s3
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	88c080e7          	jalr	-1908(ra) # 80000bd6 <acquire>
  acquire(&p->kthread[0].t_lock);
    80002352:	02898913          	addi	s2,s3,40
    80002356:	854a                	mv	a0,s2
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	87e080e7          	jalr	-1922(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state=ZOMBIE_t;
    80002360:	4795                	li	a5,5
    80002362:	04f9a023          	sw	a5,64(s3)
  release(&p->kthread[0].t_lock);
    80002366:	854a                	mv	a0,s2
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	922080e7          	jalr	-1758(ra) # 80000c8a <release>
  p->xstate = status;
    80002370:	0349a023          	sw	s4,32(s3)
  p->state = ZOMBIE;
    80002374:	4789                	li	a5,2
    80002376:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	90e080e7          	jalr	-1778(ra) # 80000c8a <release>
  sched();
    80002384:	00000097          	auipc	ra,0x0
    80002388:	c24080e7          	jalr	-988(ra) # 80001fa8 <sched>
  panic("zombie exit");
    8000238c:	00006517          	auipc	a0,0x6
    80002390:	ef450513          	addi	a0,a0,-268 # 80008280 <digits+0x240>
    80002394:	ffffe097          	auipc	ra,0xffffe
    80002398:	1aa080e7          	jalr	426(ra) # 8000053e <panic>

000000008000239c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000239c:	7179                	addi	sp,sp,-48
    8000239e:	f406                	sd	ra,40(sp)
    800023a0:	f022                	sd	s0,32(sp)
    800023a2:	ec26                	sd	s1,24(sp)
    800023a4:	e84a                	sd	s2,16(sp)
    800023a6:	e44e                	sd	s3,8(sp)
    800023a8:	1800                	addi	s0,sp,48
    800023aa:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023ac:	0000f497          	auipc	s1,0xf
    800023b0:	bd448493          	addi	s1,s1,-1068 # 80010f80 <proc>
    800023b4:	00016997          	auipc	s3,0x16
    800023b8:	bcc98993          	addi	s3,s3,-1076 # 80017f80 <tickslock>
    acquire(&p->lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	818080e7          	jalr	-2024(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800023c6:	50dc                	lw	a5,36(s1)
    800023c8:	01278d63          	beq	a5,s2,800023e2 <kill+0x46>
      // }
      release(&p->lock);
      return 0;
    }
    
    release(&p->lock);
    800023cc:	8526                	mv	a0,s1
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	8bc080e7          	jalr	-1860(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023d6:	1c048493          	addi	s1,s1,448
    800023da:	ff3491e3          	bne	s1,s3,800023bc <kill+0x20>
  }
  return -1;
    800023de:	557d                	li	a0,-1
    800023e0:	a80d                	j	80002412 <kill+0x76>
      p->killed = 1;
    800023e2:	4785                	li	a5,1
    800023e4:	ccdc                	sw	a5,28(s1)
        acquire(&t->t_lock);
    800023e6:	02848913          	addi	s2,s1,40
    800023ea:	854a                	mv	a0,s2
    800023ec:	ffffe097          	auipc	ra,0xffffe
    800023f0:	7ea080e7          	jalr	2026(ra) # 80000bd6 <acquire>
        if(t->t_state == SLEEPING_t) {
    800023f4:	40b8                	lw	a4,64(s1)
    800023f6:	4789                	li	a5,2
    800023f8:	02f70463          	beq	a4,a5,80002420 <kill+0x84>
        release(&t->t_lock);
    800023fc:	854a                	mv	a0,s2
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	88c080e7          	jalr	-1908(ra) # 80000c8a <release>
      release(&p->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	882080e7          	jalr	-1918(ra) # 80000c8a <release>
      return 0;
    80002410:	4501                	li	a0,0
}
    80002412:	70a2                	ld	ra,40(sp)
    80002414:	7402                	ld	s0,32(sp)
    80002416:	64e2                	ld	s1,24(sp)
    80002418:	6942                	ld	s2,16(sp)
    8000241a:	69a2                	ld	s3,8(sp)
    8000241c:	6145                	addi	sp,sp,48
    8000241e:	8082                	ret
          t->t_state = RUNNABLE_t;
    80002420:	478d                	li	a5,3
    80002422:	c0bc                	sw	a5,64(s1)
    80002424:	bfe1                	j	800023fc <kill+0x60>

0000000080002426 <setkilled>:


void
setkilled(struct proc *p)
{
    80002426:	1101                	addi	sp,sp,-32
    80002428:	ec06                	sd	ra,24(sp)
    8000242a:	e822                	sd	s0,16(sp)
    8000242c:	e426                	sd	s1,8(sp)
    8000242e:	1000                	addi	s0,sp,32
    80002430:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002432:	ffffe097          	auipc	ra,0xffffe
    80002436:	7a4080e7          	jalr	1956(ra) # 80000bd6 <acquire>
  p->killed = 1;
    8000243a:	4785                	li	a5,1
    8000243c:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	84a080e7          	jalr	-1974(ra) # 80000c8a <release>
}
    80002448:	60e2                	ld	ra,24(sp)
    8000244a:	6442                	ld	s0,16(sp)
    8000244c:	64a2                	ld	s1,8(sp)
    8000244e:	6105                	addi	sp,sp,32
    80002450:	8082                	ret

0000000080002452 <killed>:

int
killed(struct proc *p)
{
    80002452:	1101                	addi	sp,sp,-32
    80002454:	ec06                	sd	ra,24(sp)
    80002456:	e822                	sd	s0,16(sp)
    80002458:	e426                	sd	s1,8(sp)
    8000245a:	e04a                	sd	s2,0(sp)
    8000245c:	1000                	addi	s0,sp,32
    8000245e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002460:	ffffe097          	auipc	ra,0xffffe
    80002464:	776080e7          	jalr	1910(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002468:	01c4a903          	lw	s2,28(s1)
  release(&p->lock);
    8000246c:	8526                	mv	a0,s1
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	81c080e7          	jalr	-2020(ra) # 80000c8a <release>
  return k;
}
    80002476:	854a                	mv	a0,s2
    80002478:	60e2                	ld	ra,24(sp)
    8000247a:	6442                	ld	s0,16(sp)
    8000247c:	64a2                	ld	s1,8(sp)
    8000247e:	6902                	ld	s2,0(sp)
    80002480:	6105                	addi	sp,sp,32
    80002482:	8082                	ret

0000000080002484 <wait>:
{
    80002484:	715d                	addi	sp,sp,-80
    80002486:	e486                	sd	ra,72(sp)
    80002488:	e0a2                	sd	s0,64(sp)
    8000248a:	fc26                	sd	s1,56(sp)
    8000248c:	f84a                	sd	s2,48(sp)
    8000248e:	f44e                	sd	s3,40(sp)
    80002490:	f052                	sd	s4,32(sp)
    80002492:	ec56                	sd	s5,24(sp)
    80002494:	e85a                	sd	s6,16(sp)
    80002496:	e45e                	sd	s7,8(sp)
    80002498:	e062                	sd	s8,0(sp)
    8000249a:	0880                	addi	s0,sp,80
    8000249c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000249e:	fffff097          	auipc	ra,0xfffff
    800024a2:	4e2080e7          	jalr	1250(ra) # 80001980 <myproc>
    800024a6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024a8:	0000e517          	auipc	a0,0xe
    800024ac:	6c050513          	addi	a0,a0,1728 # 80010b68 <wait_lock>
    800024b0:	ffffe097          	auipc	ra,0xffffe
    800024b4:	726080e7          	jalr	1830(ra) # 80000bd6 <acquire>
    havekids = 0;
    800024b8:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800024ba:	4a09                	li	s4,2
        havekids = 1;
    800024bc:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024be:	00016997          	auipc	s3,0x16
    800024c2:	ac298993          	addi	s3,s3,-1342 # 80017f80 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024c6:	0000ec17          	auipc	s8,0xe
    800024ca:	6a2c0c13          	addi	s8,s8,1698 # 80010b68 <wait_lock>
    havekids = 0;
    800024ce:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024d0:	0000f497          	auipc	s1,0xf
    800024d4:	ab048493          	addi	s1,s1,-1360 # 80010f80 <proc>
    800024d8:	a0bd                	j	80002546 <wait+0xc2>
          pid = pp->pid;
    800024da:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024de:	000b0e63          	beqz	s6,800024fa <wait+0x76>
    800024e2:	4691                	li	a3,4
    800024e4:	02048613          	addi	a2,s1,32
    800024e8:	85da                	mv	a1,s6
    800024ea:	10093503          	ld	a0,256(s2)
    800024ee:	fffff097          	auipc	ra,0xfffff
    800024f2:	17a080e7          	jalr	378(ra) # 80001668 <copyout>
    800024f6:	02054563          	bltz	a0,80002520 <wait+0x9c>
          freeproc(pp);
    800024fa:	8526                	mv	a0,s1
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	60e080e7          	jalr	1550(ra) # 80001b0a <freeproc>
          release(&pp->lock);
    80002504:	8526                	mv	a0,s1
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	784080e7          	jalr	1924(ra) # 80000c8a <release>
          release(&wait_lock);
    8000250e:	0000e517          	auipc	a0,0xe
    80002512:	65a50513          	addi	a0,a0,1626 # 80010b68 <wait_lock>
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	774080e7          	jalr	1908(ra) # 80000c8a <release>
          return pid;
    8000251e:	a0b5                	j	8000258a <wait+0x106>
            release(&pp->lock);
    80002520:	8526                	mv	a0,s1
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	768080e7          	jalr	1896(ra) # 80000c8a <release>
            release(&wait_lock);
    8000252a:	0000e517          	auipc	a0,0xe
    8000252e:	63e50513          	addi	a0,a0,1598 # 80010b68 <wait_lock>
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	758080e7          	jalr	1880(ra) # 80000c8a <release>
            return -1;
    8000253a:	59fd                	li	s3,-1
    8000253c:	a0b9                	j	8000258a <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000253e:	1c048493          	addi	s1,s1,448
    80002542:	03348463          	beq	s1,s3,8000256a <wait+0xe6>
      if(pp->parent == p){
    80002546:	78fc                	ld	a5,240(s1)
    80002548:	ff279be3          	bne	a5,s2,8000253e <wait+0xba>
        acquire(&pp->lock);
    8000254c:	8526                	mv	a0,s1
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	688080e7          	jalr	1672(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002556:	4c9c                	lw	a5,24(s1)
    80002558:	f94781e3          	beq	a5,s4,800024da <wait+0x56>
        release(&pp->lock);
    8000255c:	8526                	mv	a0,s1
    8000255e:	ffffe097          	auipc	ra,0xffffe
    80002562:	72c080e7          	jalr	1836(ra) # 80000c8a <release>
        havekids = 1;
    80002566:	8756                	mv	a4,s5
    80002568:	bfd9                	j	8000253e <wait+0xba>
    if(!havekids || killed(p)){
    8000256a:	c719                	beqz	a4,80002578 <wait+0xf4>
    8000256c:	854a                	mv	a0,s2
    8000256e:	00000097          	auipc	ra,0x0
    80002572:	ee4080e7          	jalr	-284(ra) # 80002452 <killed>
    80002576:	c51d                	beqz	a0,800025a4 <wait+0x120>
      release(&wait_lock);
    80002578:	0000e517          	auipc	a0,0xe
    8000257c:	5f050513          	addi	a0,a0,1520 # 80010b68 <wait_lock>
    80002580:	ffffe097          	auipc	ra,0xffffe
    80002584:	70a080e7          	jalr	1802(ra) # 80000c8a <release>
      return -1;
    80002588:	59fd                	li	s3,-1
}
    8000258a:	854e                	mv	a0,s3
    8000258c:	60a6                	ld	ra,72(sp)
    8000258e:	6406                	ld	s0,64(sp)
    80002590:	74e2                	ld	s1,56(sp)
    80002592:	7942                	ld	s2,48(sp)
    80002594:	79a2                	ld	s3,40(sp)
    80002596:	7a02                	ld	s4,32(sp)
    80002598:	6ae2                	ld	s5,24(sp)
    8000259a:	6b42                	ld	s6,16(sp)
    8000259c:	6ba2                	ld	s7,8(sp)
    8000259e:	6c02                	ld	s8,0(sp)
    800025a0:	6161                	addi	sp,sp,80
    800025a2:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025a4:	85e2                	mv	a1,s8
    800025a6:	854a                	mv	a0,s2
    800025a8:	00000097          	auipc	ra,0x0
    800025ac:	b94080e7          	jalr	-1132(ra) # 8000213c <sleep>
    havekids = 0;
    800025b0:	bf39                	j	800024ce <wait+0x4a>

00000000800025b2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025b2:	7179                	addi	sp,sp,-48
    800025b4:	f406                	sd	ra,40(sp)
    800025b6:	f022                	sd	s0,32(sp)
    800025b8:	ec26                	sd	s1,24(sp)
    800025ba:	e84a                	sd	s2,16(sp)
    800025bc:	e44e                	sd	s3,8(sp)
    800025be:	e052                	sd	s4,0(sp)
    800025c0:	1800                	addi	s0,sp,48
    800025c2:	84aa                	mv	s1,a0
    800025c4:	892e                	mv	s2,a1
    800025c6:	89b2                	mv	s3,a2
    800025c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ca:	fffff097          	auipc	ra,0xfffff
    800025ce:	3b6080e7          	jalr	950(ra) # 80001980 <myproc>
  if(user_dst){
    800025d2:	c095                	beqz	s1,800025f6 <either_copyout+0x44>
    return copyout(p->pagetable, dst, src, len);
    800025d4:	86d2                	mv	a3,s4
    800025d6:	864e                	mv	a2,s3
    800025d8:	85ca                	mv	a1,s2
    800025da:	10053503          	ld	a0,256(a0)
    800025de:	fffff097          	auipc	ra,0xfffff
    800025e2:	08a080e7          	jalr	138(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025e6:	70a2                	ld	ra,40(sp)
    800025e8:	7402                	ld	s0,32(sp)
    800025ea:	64e2                	ld	s1,24(sp)
    800025ec:	6942                	ld	s2,16(sp)
    800025ee:	69a2                	ld	s3,8(sp)
    800025f0:	6a02                	ld	s4,0(sp)
    800025f2:	6145                	addi	sp,sp,48
    800025f4:	8082                	ret
    memmove((char *)dst, src, len);
    800025f6:	000a061b          	sext.w	a2,s4
    800025fa:	85ce                	mv	a1,s3
    800025fc:	854a                	mv	a0,s2
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	730080e7          	jalr	1840(ra) # 80000d2e <memmove>
    return 0;
    80002606:	8526                	mv	a0,s1
    80002608:	bff9                	j	800025e6 <either_copyout+0x34>

000000008000260a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000260a:	7179                	addi	sp,sp,-48
    8000260c:	f406                	sd	ra,40(sp)
    8000260e:	f022                	sd	s0,32(sp)
    80002610:	ec26                	sd	s1,24(sp)
    80002612:	e84a                	sd	s2,16(sp)
    80002614:	e44e                	sd	s3,8(sp)
    80002616:	e052                	sd	s4,0(sp)
    80002618:	1800                	addi	s0,sp,48
    8000261a:	892a                	mv	s2,a0
    8000261c:	84ae                	mv	s1,a1
    8000261e:	89b2                	mv	s3,a2
    80002620:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002622:	fffff097          	auipc	ra,0xfffff
    80002626:	35e080e7          	jalr	862(ra) # 80001980 <myproc>
  if(user_src){
    8000262a:	c095                	beqz	s1,8000264e <either_copyin+0x44>
    return copyin(p->pagetable, dst, src, len);
    8000262c:	86d2                	mv	a3,s4
    8000262e:	864e                	mv	a2,s3
    80002630:	85ca                	mv	a1,s2
    80002632:	10053503          	ld	a0,256(a0)
    80002636:	fffff097          	auipc	ra,0xfffff
    8000263a:	0be080e7          	jalr	190(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000263e:	70a2                	ld	ra,40(sp)
    80002640:	7402                	ld	s0,32(sp)
    80002642:	64e2                	ld	s1,24(sp)
    80002644:	6942                	ld	s2,16(sp)
    80002646:	69a2                	ld	s3,8(sp)
    80002648:	6a02                	ld	s4,0(sp)
    8000264a:	6145                	addi	sp,sp,48
    8000264c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000264e:	000a061b          	sext.w	a2,s4
    80002652:	85ce                	mv	a1,s3
    80002654:	854a                	mv	a0,s2
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	6d8080e7          	jalr	1752(ra) # 80000d2e <memmove>
    return 0;
    8000265e:	8526                	mv	a0,s1
    80002660:	bff9                	j	8000263e <either_copyin+0x34>

0000000080002662 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002662:	715d                	addi	sp,sp,-80
    80002664:	e486                	sd	ra,72(sp)
    80002666:	e0a2                	sd	s0,64(sp)
    80002668:	fc26                	sd	s1,56(sp)
    8000266a:	f84a                	sd	s2,48(sp)
    8000266c:	f44e                	sd	s3,40(sp)
    8000266e:	f052                	sd	s4,32(sp)
    80002670:	ec56                	sd	s5,24(sp)
    80002672:	e85a                	sd	s6,16(sp)
    80002674:	e45e                	sd	s7,8(sp)
    80002676:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002678:	00006517          	auipc	a0,0x6
    8000267c:	a5050513          	addi	a0,a0,-1456 # 800080c8 <digits+0x88>
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	f08080e7          	jalr	-248(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002688:	0000f497          	auipc	s1,0xf
    8000268c:	a8848493          	addi	s1,s1,-1400 # 80011110 <proc+0x190>
    80002690:	00016917          	auipc	s2,0x16
    80002694:	a8090913          	addi	s2,s2,-1408 # 80018110 <bcache+0x178>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002698:	4b09                	li	s6,2
      state = states[p->state];
    else
      state = "???";
    8000269a:	00006997          	auipc	s3,0x6
    8000269e:	bf698993          	addi	s3,s3,-1034 # 80008290 <digits+0x250>
    printf("%d %s %s", p->pid, state, p->name);
    800026a2:	00006a97          	auipc	s5,0x6
    800026a6:	bf6a8a93          	addi	s5,s5,-1034 # 80008298 <digits+0x258>
    printf("\n");
    800026aa:	00006a17          	auipc	s4,0x6
    800026ae:	a1ea0a13          	addi	s4,s4,-1506 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b2:	00006b97          	auipc	s7,0x6
    800026b6:	c0eb8b93          	addi	s7,s7,-1010 # 800082c0 <states.0>
    800026ba:	a00d                	j	800026dc <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026bc:	e946a583          	lw	a1,-364(a3)
    800026c0:	8556                	mv	a0,s5
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	ec6080e7          	jalr	-314(ra) # 80000588 <printf>
    printf("\n");
    800026ca:	8552                	mv	a0,s4
    800026cc:	ffffe097          	auipc	ra,0xffffe
    800026d0:	ebc080e7          	jalr	-324(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026d4:	1c048493          	addi	s1,s1,448
    800026d8:	03248163          	beq	s1,s2,800026fa <procdump+0x98>
    if(p->state == UNUSED)
    800026dc:	86a6                	mv	a3,s1
    800026de:	e884a783          	lw	a5,-376(s1)
    800026e2:	dbed                	beqz	a5,800026d4 <procdump+0x72>
      state = "???";
    800026e4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026e6:	fcfb6be3          	bltu	s6,a5,800026bc <procdump+0x5a>
    800026ea:	1782                	slli	a5,a5,0x20
    800026ec:	9381                	srli	a5,a5,0x20
    800026ee:	078e                	slli	a5,a5,0x3
    800026f0:	97de                	add	a5,a5,s7
    800026f2:	6390                	ld	a2,0(a5)
    800026f4:	f661                	bnez	a2,800026bc <procdump+0x5a>
      state = "???";
    800026f6:	864e                	mv	a2,s3
    800026f8:	b7d1                	j	800026bc <procdump+0x5a>
  }
}
    800026fa:	60a6                	ld	ra,72(sp)
    800026fc:	6406                	ld	s0,64(sp)
    800026fe:	74e2                	ld	s1,56(sp)
    80002700:	7942                	ld	s2,48(sp)
    80002702:	79a2                	ld	s3,40(sp)
    80002704:	7a02                	ld	s4,32(sp)
    80002706:	6ae2                	ld	s5,24(sp)
    80002708:	6b42                	ld	s6,16(sp)
    8000270a:	6ba2                	ld	s7,8(sp)
    8000270c:	6161                	addi	sp,sp,80
    8000270e:	8082                	ret

0000000080002710 <kthreadinit>:
#include "defs.h"

extern struct proc proc[NPROC];
extern void forkret(void);
void kthreadinit(struct proc *p)
{
    80002710:	1101                	addi	sp,sp,-32
    80002712:	ec06                	sd	ra,24(sp)
    80002714:	e822                	sd	s0,16(sp)
    80002716:	e426                	sd	s1,8(sp)
    80002718:	1000                	addi	s0,sp,32
    8000271a:	84aa                	mv	s1,a0
  initlock(&(p->alloc_lock),"aloc_thread");
    8000271c:	00006597          	auipc	a1,0x6
    80002720:	bbc58593          	addi	a1,a1,-1092 # 800082d8 <states.0+0x18>
    80002724:	1a850513          	addi	a0,a0,424
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	41e080e7          	jalr	1054(ra) # 80000b46 <initlock>
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {
    initlock(&kt->t_lock, "thread_lock"); 
    80002730:	00006597          	auipc	a1,0x6
    80002734:	bb858593          	addi	a1,a1,-1096 # 800082e8 <states.0+0x28>
    80002738:	02848513          	addi	a0,s1,40
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	40a080e7          	jalr	1034(ra) # 80000b46 <initlock>
      kt->t_state = UNUSED_t;
    80002744:	0404a023          	sw	zero,64(s1)
      kt->process=p;
    80002748:	f0a4                	sd	s1,96(s1)
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    8000274a:	0000f797          	auipc	a5,0xf
    8000274e:	83678793          	addi	a5,a5,-1994 # 80010f80 <proc>
    80002752:	40f487b3          	sub	a5,s1,a5
    80002756:	8799                	srai	a5,a5,0x6
    80002758:	00006717          	auipc	a4,0x6
    8000275c:	8a873703          	ld	a4,-1880(a4) # 80008000 <etext>
    80002760:	02e787b3          	mul	a5,a5,a4
    80002764:	2785                	addiw	a5,a5,1
    80002766:	00d7979b          	slliw	a5,a5,0xd
    8000276a:	04000737          	lui	a4,0x4000
    8000276e:	177d                	addi	a4,a4,-1
    80002770:	0732                	slli	a4,a4,0xc
    80002772:	40f707b3          	sub	a5,a4,a5
    80002776:	ecfc                	sd	a5,216(s1)
  }
}
    80002778:	60e2                	ld	ra,24(sp)
    8000277a:	6442                	ld	s0,16(sp)
    8000277c:	64a2                	ld	s1,8(sp)
    8000277e:	6105                	addi	sp,sp,32
    80002780:	8082                	ret

0000000080002782 <mykthread>:

struct kthread *mykthread()
{
    80002782:	1101                	addi	sp,sp,-32
    80002784:	ec06                	sd	ra,24(sp)
    80002786:	e822                	sd	s0,16(sp)
    80002788:	e426                	sd	s1,8(sp)
    8000278a:	1000                	addi	s0,sp,32
  push_off();
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	3fe080e7          	jalr	1022(ra) # 80000b8a <push_off>
  struct cpu *c = mycpu();
    80002794:	fffff097          	auipc	ra,0xfffff
    80002798:	1d0080e7          	jalr	464(ra) # 80001964 <mycpu>
  struct kthread *kthread = c->kthread;
    8000279c:	6104                	ld	s1,0(a0)
  pop_off();
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	48c080e7          	jalr	1164(ra) # 80000c2a <pop_off>
  return kthread;
}
    800027a6:	8526                	mv	a0,s1
    800027a8:	60e2                	ld	ra,24(sp)
    800027aa:	6442                	ld	s0,16(sp)
    800027ac:	64a2                	ld	s1,8(sp)
    800027ae:	6105                	addi	sp,sp,32
    800027b0:	8082                	ret

00000000800027b2 <alloctid>:

int alloctid(struct proc *p){
    800027b2:	7179                	addi	sp,sp,-48
    800027b4:	f406                	sd	ra,40(sp)
    800027b6:	f022                	sd	s0,32(sp)
    800027b8:	ec26                	sd	s1,24(sp)
    800027ba:	e84a                	sd	s2,16(sp)
    800027bc:	e44e                	sd	s3,8(sp)
    800027be:	1800                	addi	s0,sp,48
    800027c0:	84aa                	mv	s1,a0
  int tid;
  acquire(&(p->alloc_lock));
    800027c2:	1a850993          	addi	s3,a0,424
    800027c6:	854e                	mv	a0,s3
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	40e080e7          	jalr	1038(ra) # 80000bd6 <acquire>
  tid = p->p_counter;
    800027d0:	1a04a903          	lw	s2,416(s1)
  p->p_counter++;
    800027d4:	0019079b          	addiw	a5,s2,1
    800027d8:	1af4a023          	sw	a5,416(s1)
  release(&(p->alloc_lock));
    800027dc:	854e                	mv	a0,s3
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	4ac080e7          	jalr	1196(ra) # 80000c8a <release>
  return tid;
}
    800027e6:	854a                	mv	a0,s2
    800027e8:	70a2                	ld	ra,40(sp)
    800027ea:	7402                	ld	s0,32(sp)
    800027ec:	64e2                	ld	s1,24(sp)
    800027ee:	6942                	ld	s2,16(sp)
    800027f0:	69a2                	ld	s3,8(sp)
    800027f2:	6145                	addi	sp,sp,48
    800027f4:	8082                	ret

00000000800027f6 <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    800027f6:	1141                	addi	sp,sp,-16
    800027f8:	e422                	sd	s0,8(sp)
    800027fa:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    800027fc:	02850793          	addi	a5,a0,40
    80002800:	8d9d                	sub	a1,a1,a5
    80002802:	8599                	srai	a1,a1,0x6
    80002804:	00006797          	auipc	a5,0x6
    80002808:	8047b783          	ld	a5,-2044(a5) # 80008008 <etext+0x8>
    8000280c:	02f585bb          	mulw	a1,a1,a5
    80002810:	00359793          	slli	a5,a1,0x3
    80002814:	95be                	add	a1,a1,a5
    80002816:	0596                	slli	a1,a1,0x5
    80002818:	7568                	ld	a0,232(a0)
}
    8000281a:	952e                	add	a0,a0,a1
    8000281c:	6422                	ld	s0,8(sp)
    8000281e:	0141                	addi	sp,sp,16
    80002820:	8082                	ret

0000000080002822 <allockthread>:

struct kthread* allockthread(struct proc *p){
    80002822:	1101                	addi	sp,sp,-32
    80002824:	ec06                	sd	ra,24(sp)
    80002826:	e822                	sd	s0,16(sp)
    80002828:	e426                	sd	s1,8(sp)
    8000282a:	e04a                	sd	s2,0(sp)
    8000282c:	1000                	addi	s0,sp,32
    8000282e:	84aa                	mv	s1,a0
  
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    80002830:	02850913          	addi	s2,a0,40
    {
      acquire(&kt->t_lock);
    80002834:	854a                	mv	a0,s2
    80002836:	ffffe097          	auipc	ra,0xffffe
    8000283a:	3a0080e7          	jalr	928(ra) # 80000bd6 <acquire>
      if(kt->t_state == UNUSED_t) {
    8000283e:	40bc                	lw	a5,64(s1)
    80002840:	cf91                	beqz	a5,8000285c <allockthread+0x3a>
        kt->context.ra = (uint64)forkret;
        kt->context.sp = kt->kstack + PGSIZE;
        return kt;
      } 
      else {
        release(&kt->t_lock);
    80002842:	854a                	mv	a0,s2
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	446080e7          	jalr	1094(ra) # 80000c8a <release>
      }
  }
  return 0;
    8000284c:	4901                	li	s2,0
}
    8000284e:	854a                	mv	a0,s2
    80002850:	60e2                	ld	ra,24(sp)
    80002852:	6442                	ld	s0,16(sp)
    80002854:	64a2                	ld	s1,8(sp)
    80002856:	6902                	ld	s2,0(sp)
    80002858:	6105                	addi	sp,sp,32
    8000285a:	8082                	ret
        kt->tid = alloctid(p);
    8000285c:	8526                	mv	a0,s1
    8000285e:	00000097          	auipc	ra,0x0
    80002862:	f54080e7          	jalr	-172(ra) # 800027b2 <alloctid>
    80002866:	cca8                	sw	a0,88(s1)
        kt->t_state = USED_t;
    80002868:	4785                	li	a5,1
    8000286a:	c0bc                	sw	a5,64(s1)
        kt->process=p;
    8000286c:	f0a4                	sd	s1,96(s1)
        kt->trapframe = get_kthread_trapframe(p,kt);
    8000286e:	85ca                	mv	a1,s2
    80002870:	8526                	mv	a0,s1
    80002872:	00000097          	auipc	ra,0x0
    80002876:	f84080e7          	jalr	-124(ra) # 800027f6 <get_kthread_trapframe>
    8000287a:	f0e8                	sd	a0,224(s1)
        memset(&kt->context, 0, sizeof(kt->context));   
    8000287c:	07000613          	li	a2,112
    80002880:	4581                	li	a1,0
    80002882:	06848513          	addi	a0,s1,104
    80002886:	ffffe097          	auipc	ra,0xffffe
    8000288a:	44c080e7          	jalr	1100(ra) # 80000cd2 <memset>
        kt->context.ra = (uint64)forkret;
    8000288e:	00000797          	auipc	a5,0x0
    80002892:	84878793          	addi	a5,a5,-1976 # 800020d6 <forkret>
    80002896:	f4bc                	sd	a5,104(s1)
        kt->context.sp = kt->kstack + PGSIZE;
    80002898:	6cfc                	ld	a5,216(s1)
    8000289a:	6705                	lui	a4,0x1
    8000289c:	97ba                	add	a5,a5,a4
    8000289e:	f8bc                	sd	a5,112(s1)
        return kt;
    800028a0:	b77d                	j	8000284e <allockthread+0x2c>

00000000800028a2 <freethread>:

void
freethread(struct kthread *t){
    800028a2:	1101                	addi	sp,sp,-32
    800028a4:	ec06                	sd	ra,24(sp)
    800028a6:	e822                	sd	s0,16(sp)
    800028a8:	e426                	sd	s1,8(sp)
    800028aa:	1000                	addi	s0,sp,32
    800028ac:	84aa                	mv	s1,a0
  t->chan = 0;
    800028ae:	02053023          	sd	zero,32(a0)
  t->t_killed = 0;
    800028b2:	02052423          	sw	zero,40(a0)
  t->t_xstate = 0;
    800028b6:	02052623          	sw	zero,44(a0)
  t->t_state = UNUSED_t;
    800028ba:	00052c23          	sw	zero,24(a0)
  t->tid=0;
    800028be:	02052823          	sw	zero,48(a0)
  t->process=0;
    800028c2:	02053c23          	sd	zero,56(a0)
  t->kstack=0;
    800028c6:	0a053823          	sd	zero,176(a0)
  if(t->trapframe)
    800028ca:	7d48                	ld	a0,184(a0)
    800028cc:	c509                	beqz	a0,800028d6 <freethread+0x34>
    kfree((void*)t->trapframe);
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	11c080e7          	jalr	284(ra) # 800009ea <kfree>
  t->trapframe = 0;
    800028d6:	0a04bc23          	sd	zero,184(s1)
  memset(&t->context,0,sizeof(&t->context));
    800028da:	4621                	li	a2,8
    800028dc:	4581                	li	a1,0
    800028de:	04048513          	addi	a0,s1,64
    800028e2:	ffffe097          	auipc	ra,0xffffe
    800028e6:	3f0080e7          	jalr	1008(ra) # 80000cd2 <memset>
  release(&t->t_lock);
    800028ea:	8526                	mv	a0,s1
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	39e080e7          	jalr	926(ra) # 80000c8a <release>
}
    800028f4:	60e2                	ld	ra,24(sp)
    800028f6:	6442                	ld	s0,16(sp)
    800028f8:	64a2                	ld	s1,8(sp)
    800028fa:	6105                	addi	sp,sp,32
    800028fc:	8082                	ret

00000000800028fe <swtch>:
    800028fe:	00153023          	sd	ra,0(a0)
    80002902:	00253423          	sd	sp,8(a0)
    80002906:	e900                	sd	s0,16(a0)
    80002908:	ed04                	sd	s1,24(a0)
    8000290a:	03253023          	sd	s2,32(a0)
    8000290e:	03353423          	sd	s3,40(a0)
    80002912:	03453823          	sd	s4,48(a0)
    80002916:	03553c23          	sd	s5,56(a0)
    8000291a:	05653023          	sd	s6,64(a0)
    8000291e:	05753423          	sd	s7,72(a0)
    80002922:	05853823          	sd	s8,80(a0)
    80002926:	05953c23          	sd	s9,88(a0)
    8000292a:	07a53023          	sd	s10,96(a0)
    8000292e:	07b53423          	sd	s11,104(a0)
    80002932:	0005b083          	ld	ra,0(a1)
    80002936:	0085b103          	ld	sp,8(a1)
    8000293a:	6980                	ld	s0,16(a1)
    8000293c:	6d84                	ld	s1,24(a1)
    8000293e:	0205b903          	ld	s2,32(a1)
    80002942:	0285b983          	ld	s3,40(a1)
    80002946:	0305ba03          	ld	s4,48(a1)
    8000294a:	0385ba83          	ld	s5,56(a1)
    8000294e:	0405bb03          	ld	s6,64(a1)
    80002952:	0485bb83          	ld	s7,72(a1)
    80002956:	0505bc03          	ld	s8,80(a1)
    8000295a:	0585bc83          	ld	s9,88(a1)
    8000295e:	0605bd03          	ld	s10,96(a1)
    80002962:	0685bd83          	ld	s11,104(a1)
    80002966:	8082                	ret

0000000080002968 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002968:	1141                	addi	sp,sp,-16
    8000296a:	e406                	sd	ra,8(sp)
    8000296c:	e022                	sd	s0,0(sp)
    8000296e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002970:	00006597          	auipc	a1,0x6
    80002974:	98858593          	addi	a1,a1,-1656 # 800082f8 <states.0+0x38>
    80002978:	00015517          	auipc	a0,0x15
    8000297c:	60850513          	addi	a0,a0,1544 # 80017f80 <tickslock>
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	1c6080e7          	jalr	454(ra) # 80000b46 <initlock>
}
    80002988:	60a2                	ld	ra,8(sp)
    8000298a:	6402                	ld	s0,0(sp)
    8000298c:	0141                	addi	sp,sp,16
    8000298e:	8082                	ret

0000000080002990 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002990:	1141                	addi	sp,sp,-16
    80002992:	e422                	sd	s0,8(sp)
    80002994:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002996:	00003797          	auipc	a5,0x3
    8000299a:	53a78793          	addi	a5,a5,1338 # 80005ed0 <kernelvec>
    8000299e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029a2:	6422                	ld	s0,8(sp)
    800029a4:	0141                	addi	sp,sp,16
    800029a6:	8082                	ret

00000000800029a8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029a8:	1101                	addi	sp,sp,-32
    800029aa:	ec06                	sd	ra,24(sp)
    800029ac:	e822                	sd	s0,16(sp)
    800029ae:	e426                	sd	s1,8(sp)
    800029b0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800029b2:	fffff097          	auipc	ra,0xfffff
    800029b6:	fce080e7          	jalr	-50(ra) # 80001980 <myproc>
    800029ba:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    800029bc:	00000097          	auipc	ra,0x0
    800029c0:	dc6080e7          	jalr	-570(ra) # 80002782 <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029c8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ca:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029ce:	00004617          	auipc	a2,0x4
    800029d2:	63260613          	addi	a2,a2,1586 # 80007000 <_trampoline>
    800029d6:	00004697          	auipc	a3,0x4
    800029da:	62a68693          	addi	a3,a3,1578 # 80007000 <_trampoline>
    800029de:	8e91                	sub	a3,a3,a2
    800029e0:	040007b7          	lui	a5,0x4000
    800029e4:	17fd                	addi	a5,a5,-1
    800029e6:	07b2                	slli	a5,a5,0xc
    800029e8:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029ea:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    800029ee:	7d58                	ld	a4,184(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029f0:	180026f3          	csrr	a3,satp
    800029f4:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    800029f6:	7d58                	ld	a4,184(a0)
    800029f8:	7954                	ld	a3,176(a0)
    800029fa:	6585                	lui	a1,0x1
    800029fc:	96ae                	add	a3,a3,a1
    800029fe:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    80002a00:	7d58                	ld	a4,184(a0)
    80002a02:	00000697          	auipc	a3,0x0
    80002a06:	15e68693          	addi	a3,a3,350 # 80002b60 <usertrap>
    80002a0a:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a0c:	7d58                	ld	a4,184(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a0e:	8692                	mv	a3,tp
    80002a10:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a12:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a16:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a1a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a1e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    80002a22:	7d58                	ld	a4,184(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a24:	6f18                	ld	a4,24(a4)
    80002a26:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a2a:	1004b583          	ld	a1,256(s1)
    80002a2e:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002a30:	02848493          	addi	s1,s1,40
    80002a34:	8d05                	sub	a0,a0,s1
    80002a36:	8519                	srai	a0,a0,0x6
    80002a38:	00005717          	auipc	a4,0x5
    80002a3c:	5d073703          	ld	a4,1488(a4) # 80008008 <etext+0x8>
    80002a40:	02e50533          	mul	a0,a0,a4
    80002a44:	1502                	slli	a0,a0,0x20
    80002a46:	9101                	srli	a0,a0,0x20
    80002a48:	00351693          	slli	a3,a0,0x3
    80002a4c:	9536                	add	a0,a0,a3
    80002a4e:	0516                	slli	a0,a0,0x5
    80002a50:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a54:	00004717          	auipc	a4,0x4
    80002a58:	64070713          	addi	a4,a4,1600 # 80007094 <userret>
    80002a5c:	8f11                	sub	a4,a4,a2
    80002a5e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002a60:	577d                	li	a4,-1
    80002a62:	177e                	slli	a4,a4,0x3f
    80002a64:	8dd9                	or	a1,a1,a4
    80002a66:	16fd                	addi	a3,a3,-1
    80002a68:	06b6                	slli	a3,a3,0xd
    80002a6a:	9536                	add	a0,a0,a3
    80002a6c:	9782                	jalr	a5
}
    80002a6e:	60e2                	ld	ra,24(sp)
    80002a70:	6442                	ld	s0,16(sp)
    80002a72:	64a2                	ld	s1,8(sp)
    80002a74:	6105                	addi	sp,sp,32
    80002a76:	8082                	ret

0000000080002a78 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a78:	1101                	addi	sp,sp,-32
    80002a7a:	ec06                	sd	ra,24(sp)
    80002a7c:	e822                	sd	s0,16(sp)
    80002a7e:	e426                	sd	s1,8(sp)
    80002a80:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a82:	00015497          	auipc	s1,0x15
    80002a86:	4fe48493          	addi	s1,s1,1278 # 80017f80 <tickslock>
    80002a8a:	8526                	mv	a0,s1
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	14a080e7          	jalr	330(ra) # 80000bd6 <acquire>
  ticks++;
    80002a94:	00006517          	auipc	a0,0x6
    80002a98:	e4c50513          	addi	a0,a0,-436 # 800088e0 <ticks>
    80002a9c:	411c                	lw	a5,0(a0)
    80002a9e:	2785                	addiw	a5,a5,1
    80002aa0:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002aa2:	fffff097          	auipc	ra,0xfffff
    80002aa6:	71a080e7          	jalr	1818(ra) # 800021bc <wakeup>
  release(&tickslock);
    80002aaa:	8526                	mv	a0,s1
    80002aac:	ffffe097          	auipc	ra,0xffffe
    80002ab0:	1de080e7          	jalr	478(ra) # 80000c8a <release>
}
    80002ab4:	60e2                	ld	ra,24(sp)
    80002ab6:	6442                	ld	s0,16(sp)
    80002ab8:	64a2                	ld	s1,8(sp)
    80002aba:	6105                	addi	sp,sp,32
    80002abc:	8082                	ret

0000000080002abe <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002abe:	1101                	addi	sp,sp,-32
    80002ac0:	ec06                	sd	ra,24(sp)
    80002ac2:	e822                	sd	s0,16(sp)
    80002ac4:	e426                	sd	s1,8(sp)
    80002ac6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ac8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002acc:	00074d63          	bltz	a4,80002ae6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002ad0:	57fd                	li	a5,-1
    80002ad2:	17fe                	slli	a5,a5,0x3f
    80002ad4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ad6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ad8:	06f70363          	beq	a4,a5,80002b3e <devintr+0x80>
  }
}
    80002adc:	60e2                	ld	ra,24(sp)
    80002ade:	6442                	ld	s0,16(sp)
    80002ae0:	64a2                	ld	s1,8(sp)
    80002ae2:	6105                	addi	sp,sp,32
    80002ae4:	8082                	ret
     (scause & 0xff) == 9){
    80002ae6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002aea:	46a5                	li	a3,9
    80002aec:	fed792e3          	bne	a5,a3,80002ad0 <devintr+0x12>
    int irq = plic_claim();
    80002af0:	00003097          	auipc	ra,0x3
    80002af4:	4e8080e7          	jalr	1256(ra) # 80005fd8 <plic_claim>
    80002af8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002afa:	47a9                	li	a5,10
    80002afc:	02f50763          	beq	a0,a5,80002b2a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b00:	4785                	li	a5,1
    80002b02:	02f50963          	beq	a0,a5,80002b34 <devintr+0x76>
    return 1;
    80002b06:	4505                	li	a0,1
    } else if(irq){
    80002b08:	d8f1                	beqz	s1,80002adc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b0a:	85a6                	mv	a1,s1
    80002b0c:	00005517          	auipc	a0,0x5
    80002b10:	7f450513          	addi	a0,a0,2036 # 80008300 <states.0+0x40>
    80002b14:	ffffe097          	auipc	ra,0xffffe
    80002b18:	a74080e7          	jalr	-1420(ra) # 80000588 <printf>
      plic_complete(irq);
    80002b1c:	8526                	mv	a0,s1
    80002b1e:	00003097          	auipc	ra,0x3
    80002b22:	4de080e7          	jalr	1246(ra) # 80005ffc <plic_complete>
    return 1;
    80002b26:	4505                	li	a0,1
    80002b28:	bf55                	j	80002adc <devintr+0x1e>
      uartintr();
    80002b2a:	ffffe097          	auipc	ra,0xffffe
    80002b2e:	e70080e7          	jalr	-400(ra) # 8000099a <uartintr>
    80002b32:	b7ed                	j	80002b1c <devintr+0x5e>
      virtio_disk_intr();
    80002b34:	00004097          	auipc	ra,0x4
    80002b38:	994080e7          	jalr	-1644(ra) # 800064c8 <virtio_disk_intr>
    80002b3c:	b7c5                	j	80002b1c <devintr+0x5e>
    if(cpuid() == 0){
    80002b3e:	fffff097          	auipc	ra,0xfffff
    80002b42:	e16080e7          	jalr	-490(ra) # 80001954 <cpuid>
    80002b46:	c901                	beqz	a0,80002b56 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b48:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b4c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b4e:	14479073          	csrw	sip,a5
    return 2;
    80002b52:	4509                	li	a0,2
    80002b54:	b761                	j	80002adc <devintr+0x1e>
      clockintr();
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	f22080e7          	jalr	-222(ra) # 80002a78 <clockintr>
    80002b5e:	b7ed                	j	80002b48 <devintr+0x8a>

0000000080002b60 <usertrap>:
{
    80002b60:	1101                	addi	sp,sp,-32
    80002b62:	ec06                	sd	ra,24(sp)
    80002b64:	e822                	sd	s0,16(sp)
    80002b66:	e426                	sd	s1,8(sp)
    80002b68:	e04a                	sd	s2,0(sp)
    80002b6a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b6c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b70:	1007f793          	andi	a5,a5,256
    80002b74:	e7b9                	bnez	a5,80002bc2 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b76:	00003797          	auipc	a5,0x3
    80002b7a:	35a78793          	addi	a5,a5,858 # 80005ed0 <kernelvec>
    80002b7e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	dfe080e7          	jalr	-514(ra) # 80001980 <myproc>
    80002b8a:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	bf6080e7          	jalr	-1034(ra) # 80002782 <mykthread>
    80002b94:	892a                	mv	s2,a0
  kt->trapframe->epc = r_sepc();
    80002b96:	7d5c                	ld	a5,184(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b98:	14102773          	csrr	a4,sepc
    80002b9c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b9e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002ba2:	47a1                	li	a5,8
    80002ba4:	02f70763          	beq	a4,a5,80002bd2 <usertrap+0x72>
  } else if((which_dev = devintr()) != 0){
    80002ba8:	00000097          	auipc	ra,0x0
    80002bac:	f16080e7          	jalr	-234(ra) # 80002abe <devintr>
    80002bb0:	892a                	mv	s2,a0
    80002bb2:	c541                	beqz	a0,80002c3a <usertrap+0xda>
  if(killed(p))
    80002bb4:	8526                	mv	a0,s1
    80002bb6:	00000097          	auipc	ra,0x0
    80002bba:	89c080e7          	jalr	-1892(ra) # 80002452 <killed>
    80002bbe:	c939                	beqz	a0,80002c14 <usertrap+0xb4>
    80002bc0:	a0a9                	j	80002c0a <usertrap+0xaa>
    panic("usertrap: not from user mode");
    80002bc2:	00005517          	auipc	a0,0x5
    80002bc6:	75e50513          	addi	a0,a0,1886 # 80008320 <states.0+0x60>
    80002bca:	ffffe097          	auipc	ra,0xffffe
    80002bce:	974080e7          	jalr	-1676(ra) # 8000053e <panic>
    if(killed(p))
    80002bd2:	8526                	mv	a0,s1
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	87e080e7          	jalr	-1922(ra) # 80002452 <killed>
    80002bdc:	e929                	bnez	a0,80002c2e <usertrap+0xce>
    kt->trapframe->epc += 4;
    80002bde:	0b893703          	ld	a4,184(s2)
    80002be2:	6f1c                	ld	a5,24(a4)
    80002be4:	0791                	addi	a5,a5,4
    80002be6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002be8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bf0:	10079073          	csrw	sstatus,a5
    syscall();
    80002bf4:	00000097          	auipc	ra,0x0
    80002bf8:	2d8080e7          	jalr	728(ra) # 80002ecc <syscall>
  if(killed(p))
    80002bfc:	8526                	mv	a0,s1
    80002bfe:	00000097          	auipc	ra,0x0
    80002c02:	854080e7          	jalr	-1964(ra) # 80002452 <killed>
    80002c06:	c911                	beqz	a0,80002c1a <usertrap+0xba>
    80002c08:	4901                	li	s2,0
    exit(-1);
    80002c0a:	557d                	li	a0,-1
    80002c0c:	fffff097          	auipc	ra,0xfffff
    80002c10:	69c080e7          	jalr	1692(ra) # 800022a8 <exit>
  if(which_dev == 2)
    80002c14:	4789                	li	a5,2
    80002c16:	04f90f63          	beq	s2,a5,80002c74 <usertrap+0x114>
  usertrapret();
    80002c1a:	00000097          	auipc	ra,0x0
    80002c1e:	d8e080e7          	jalr	-626(ra) # 800029a8 <usertrapret>
}
    80002c22:	60e2                	ld	ra,24(sp)
    80002c24:	6442                	ld	s0,16(sp)
    80002c26:	64a2                	ld	s1,8(sp)
    80002c28:	6902                	ld	s2,0(sp)
    80002c2a:	6105                	addi	sp,sp,32
    80002c2c:	8082                	ret
      exit(-1);
    80002c2e:	557d                	li	a0,-1
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	678080e7          	jalr	1656(ra) # 800022a8 <exit>
    80002c38:	b75d                	j	80002bde <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c3a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c3e:	50d0                	lw	a2,36(s1)
    80002c40:	00005517          	auipc	a0,0x5
    80002c44:	70050513          	addi	a0,a0,1792 # 80008340 <states.0+0x80>
    80002c48:	ffffe097          	auipc	ra,0xffffe
    80002c4c:	940080e7          	jalr	-1728(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c50:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c54:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c58:	00005517          	auipc	a0,0x5
    80002c5c:	71850513          	addi	a0,a0,1816 # 80008370 <states.0+0xb0>
    80002c60:	ffffe097          	auipc	ra,0xffffe
    80002c64:	928080e7          	jalr	-1752(ra) # 80000588 <printf>
    setkilled(p);
    80002c68:	8526                	mv	a0,s1
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	7bc080e7          	jalr	1980(ra) # 80002426 <setkilled>
    80002c72:	b769                	j	80002bfc <usertrap+0x9c>
    yield();
    80002c74:	fffff097          	auipc	ra,0xfffff
    80002c78:	40a080e7          	jalr	1034(ra) # 8000207e <yield>
    80002c7c:	bf79                	j	80002c1a <usertrap+0xba>

0000000080002c7e <kerneltrap>:
{
    80002c7e:	7179                	addi	sp,sp,-48
    80002c80:	f406                	sd	ra,40(sp)
    80002c82:	f022                	sd	s0,32(sp)
    80002c84:	ec26                	sd	s1,24(sp)
    80002c86:	e84a                	sd	s2,16(sp)
    80002c88:	e44e                	sd	s3,8(sp)
    80002c8a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c8c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c90:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c94:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c98:	1004f793          	andi	a5,s1,256
    80002c9c:	cb85                	beqz	a5,80002ccc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c9e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ca2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002ca4:	ef85                	bnez	a5,80002cdc <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002ca6:	00000097          	auipc	ra,0x0
    80002caa:	e18080e7          	jalr	-488(ra) # 80002abe <devintr>
    80002cae:	cd1d                	beqz	a0,80002cec <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002cb0:	4789                	li	a5,2
    80002cb2:	06f50a63          	beq	a0,a5,80002d26 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cb6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cba:	10049073          	csrw	sstatus,s1
}
    80002cbe:	70a2                	ld	ra,40(sp)
    80002cc0:	7402                	ld	s0,32(sp)
    80002cc2:	64e2                	ld	s1,24(sp)
    80002cc4:	6942                	ld	s2,16(sp)
    80002cc6:	69a2                	ld	s3,8(sp)
    80002cc8:	6145                	addi	sp,sp,48
    80002cca:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ccc:	00005517          	auipc	a0,0x5
    80002cd0:	6c450513          	addi	a0,a0,1732 # 80008390 <states.0+0xd0>
    80002cd4:	ffffe097          	auipc	ra,0xffffe
    80002cd8:	86a080e7          	jalr	-1942(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002cdc:	00005517          	auipc	a0,0x5
    80002ce0:	6dc50513          	addi	a0,a0,1756 # 800083b8 <states.0+0xf8>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	85a080e7          	jalr	-1958(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002cec:	85ce                	mv	a1,s3
    80002cee:	00005517          	auipc	a0,0x5
    80002cf2:	6ea50513          	addi	a0,a0,1770 # 800083d8 <states.0+0x118>
    80002cf6:	ffffe097          	auipc	ra,0xffffe
    80002cfa:	892080e7          	jalr	-1902(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cfe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d02:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d06:	00005517          	auipc	a0,0x5
    80002d0a:	6e250513          	addi	a0,a0,1762 # 800083e8 <states.0+0x128>
    80002d0e:	ffffe097          	auipc	ra,0xffffe
    80002d12:	87a080e7          	jalr	-1926(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002d16:	00005517          	auipc	a0,0x5
    80002d1a:	6ea50513          	addi	a0,a0,1770 # 80008400 <states.0+0x140>
    80002d1e:	ffffe097          	auipc	ra,0xffffe
    80002d22:	820080e7          	jalr	-2016(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	c5a080e7          	jalr	-934(ra) # 80001980 <myproc>
    80002d2e:	d541                	beqz	a0,80002cb6 <kerneltrap+0x38>
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	c50080e7          	jalr	-944(ra) # 80001980 <myproc>
    80002d38:	4138                	lw	a4,64(a0)
    80002d3a:	4791                	li	a5,4
    80002d3c:	f6f71de3          	bne	a4,a5,80002cb6 <kerneltrap+0x38>
    yield();
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	33e080e7          	jalr	830(ra) # 8000207e <yield>
    80002d48:	b7bd                	j	80002cb6 <kerneltrap+0x38>

0000000080002d4a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d4a:	1101                	addi	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	e426                	sd	s1,8(sp)
    80002d52:	1000                	addi	s0,sp,32
    80002d54:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	a2c080e7          	jalr	-1492(ra) # 80002782 <mykthread>
  switch (n) {
    80002d5e:	4795                	li	a5,5
    80002d60:	0497e163          	bltu	a5,s1,80002da2 <argraw+0x58>
    80002d64:	048a                	slli	s1,s1,0x2
    80002d66:	00005717          	auipc	a4,0x5
    80002d6a:	6d270713          	addi	a4,a4,1746 # 80008438 <states.0+0x178>
    80002d6e:	94ba                	add	s1,s1,a4
    80002d70:	409c                	lw	a5,0(s1)
    80002d72:	97ba                	add	a5,a5,a4
    80002d74:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    80002d76:	7d5c                	ld	a5,184(a0)
    80002d78:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d7a:	60e2                	ld	ra,24(sp)
    80002d7c:	6442                	ld	s0,16(sp)
    80002d7e:	64a2                	ld	s1,8(sp)
    80002d80:	6105                	addi	sp,sp,32
    80002d82:	8082                	ret
    return kt->trapframe->a1;
    80002d84:	7d5c                	ld	a5,184(a0)
    80002d86:	7fa8                	ld	a0,120(a5)
    80002d88:	bfcd                	j	80002d7a <argraw+0x30>
    return kt->trapframe->a2;
    80002d8a:	7d5c                	ld	a5,184(a0)
    80002d8c:	63c8                	ld	a0,128(a5)
    80002d8e:	b7f5                	j	80002d7a <argraw+0x30>
    return kt->trapframe->a3;
    80002d90:	7d5c                	ld	a5,184(a0)
    80002d92:	67c8                	ld	a0,136(a5)
    80002d94:	b7dd                	j	80002d7a <argraw+0x30>
    return kt->trapframe->a4;
    80002d96:	7d5c                	ld	a5,184(a0)
    80002d98:	6bc8                	ld	a0,144(a5)
    80002d9a:	b7c5                	j	80002d7a <argraw+0x30>
    return kt->trapframe->a5;
    80002d9c:	7d5c                	ld	a5,184(a0)
    80002d9e:	6fc8                	ld	a0,152(a5)
    80002da0:	bfe9                	j	80002d7a <argraw+0x30>
  panic("argraw");
    80002da2:	00005517          	auipc	a0,0x5
    80002da6:	66e50513          	addi	a0,a0,1646 # 80008410 <states.0+0x150>
    80002daa:	ffffd097          	auipc	ra,0xffffd
    80002dae:	794080e7          	jalr	1940(ra) # 8000053e <panic>

0000000080002db2 <fetchaddr>:
{
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	e426                	sd	s1,8(sp)
    80002dba:	e04a                	sd	s2,0(sp)
    80002dbc:	1000                	addi	s0,sp,32
    80002dbe:	84aa                	mv	s1,a0
    80002dc0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dc2:	fffff097          	auipc	ra,0xfffff
    80002dc6:	bbe080e7          	jalr	-1090(ra) # 80001980 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002dca:	7d7c                	ld	a5,248(a0)
    80002dcc:	02f4f963          	bgeu	s1,a5,80002dfe <fetchaddr+0x4c>
    80002dd0:	00848713          	addi	a4,s1,8
    80002dd4:	02e7e763          	bltu	a5,a4,80002e02 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002dd8:	46a1                	li	a3,8
    80002dda:	8626                	mv	a2,s1
    80002ddc:	85ca                	mv	a1,s2
    80002dde:	10053503          	ld	a0,256(a0)
    80002de2:	fffff097          	auipc	ra,0xfffff
    80002de6:	912080e7          	jalr	-1774(ra) # 800016f4 <copyin>
    80002dea:	00a03533          	snez	a0,a0
    80002dee:	40a00533          	neg	a0,a0
}
    80002df2:	60e2                	ld	ra,24(sp)
    80002df4:	6442                	ld	s0,16(sp)
    80002df6:	64a2                	ld	s1,8(sp)
    80002df8:	6902                	ld	s2,0(sp)
    80002dfa:	6105                	addi	sp,sp,32
    80002dfc:	8082                	ret
    return -1;
    80002dfe:	557d                	li	a0,-1
    80002e00:	bfcd                	j	80002df2 <fetchaddr+0x40>
    80002e02:	557d                	li	a0,-1
    80002e04:	b7fd                	j	80002df2 <fetchaddr+0x40>

0000000080002e06 <fetchstr>:
{
    80002e06:	7179                	addi	sp,sp,-48
    80002e08:	f406                	sd	ra,40(sp)
    80002e0a:	f022                	sd	s0,32(sp)
    80002e0c:	ec26                	sd	s1,24(sp)
    80002e0e:	e84a                	sd	s2,16(sp)
    80002e10:	e44e                	sd	s3,8(sp)
    80002e12:	1800                	addi	s0,sp,48
    80002e14:	892a                	mv	s2,a0
    80002e16:	84ae                	mv	s1,a1
    80002e18:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e1a:	fffff097          	auipc	ra,0xfffff
    80002e1e:	b66080e7          	jalr	-1178(ra) # 80001980 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e22:	86ce                	mv	a3,s3
    80002e24:	864a                	mv	a2,s2
    80002e26:	85a6                	mv	a1,s1
    80002e28:	10053503          	ld	a0,256(a0)
    80002e2c:	fffff097          	auipc	ra,0xfffff
    80002e30:	956080e7          	jalr	-1706(ra) # 80001782 <copyinstr>
    80002e34:	00054e63          	bltz	a0,80002e50 <fetchstr+0x4a>
  return strlen(buf);
    80002e38:	8526                	mv	a0,s1
    80002e3a:	ffffe097          	auipc	ra,0xffffe
    80002e3e:	014080e7          	jalr	20(ra) # 80000e4e <strlen>
}
    80002e42:	70a2                	ld	ra,40(sp)
    80002e44:	7402                	ld	s0,32(sp)
    80002e46:	64e2                	ld	s1,24(sp)
    80002e48:	6942                	ld	s2,16(sp)
    80002e4a:	69a2                	ld	s3,8(sp)
    80002e4c:	6145                	addi	sp,sp,48
    80002e4e:	8082                	ret
    return -1;
    80002e50:	557d                	li	a0,-1
    80002e52:	bfc5                	j	80002e42 <fetchstr+0x3c>

0000000080002e54 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	1000                	addi	s0,sp,32
    80002e5e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e60:	00000097          	auipc	ra,0x0
    80002e64:	eea080e7          	jalr	-278(ra) # 80002d4a <argraw>
    80002e68:	c088                	sw	a0,0(s1)
}
    80002e6a:	60e2                	ld	ra,24(sp)
    80002e6c:	6442                	ld	s0,16(sp)
    80002e6e:	64a2                	ld	s1,8(sp)
    80002e70:	6105                	addi	sp,sp,32
    80002e72:	8082                	ret

0000000080002e74 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e74:	1101                	addi	sp,sp,-32
    80002e76:	ec06                	sd	ra,24(sp)
    80002e78:	e822                	sd	s0,16(sp)
    80002e7a:	e426                	sd	s1,8(sp)
    80002e7c:	1000                	addi	s0,sp,32
    80002e7e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e80:	00000097          	auipc	ra,0x0
    80002e84:	eca080e7          	jalr	-310(ra) # 80002d4a <argraw>
    80002e88:	e088                	sd	a0,0(s1)
}
    80002e8a:	60e2                	ld	ra,24(sp)
    80002e8c:	6442                	ld	s0,16(sp)
    80002e8e:	64a2                	ld	s1,8(sp)
    80002e90:	6105                	addi	sp,sp,32
    80002e92:	8082                	ret

0000000080002e94 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e94:	7179                	addi	sp,sp,-48
    80002e96:	f406                	sd	ra,40(sp)
    80002e98:	f022                	sd	s0,32(sp)
    80002e9a:	ec26                	sd	s1,24(sp)
    80002e9c:	e84a                	sd	s2,16(sp)
    80002e9e:	1800                	addi	s0,sp,48
    80002ea0:	84ae                	mv	s1,a1
    80002ea2:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ea4:	fd840593          	addi	a1,s0,-40
    80002ea8:	00000097          	auipc	ra,0x0
    80002eac:	fcc080e7          	jalr	-52(ra) # 80002e74 <argaddr>
  return fetchstr(addr, buf, max);
    80002eb0:	864a                	mv	a2,s2
    80002eb2:	85a6                	mv	a1,s1
    80002eb4:	fd843503          	ld	a0,-40(s0)
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	f4e080e7          	jalr	-178(ra) # 80002e06 <fetchstr>
}
    80002ec0:	70a2                	ld	ra,40(sp)
    80002ec2:	7402                	ld	s0,32(sp)
    80002ec4:	64e2                	ld	s1,24(sp)
    80002ec6:	6942                	ld	s2,16(sp)
    80002ec8:	6145                	addi	sp,sp,48
    80002eca:	8082                	ret

0000000080002ecc <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002ecc:	7179                	addi	sp,sp,-48
    80002ece:	f406                	sd	ra,40(sp)
    80002ed0:	f022                	sd	s0,32(sp)
    80002ed2:	ec26                	sd	s1,24(sp)
    80002ed4:	e84a                	sd	s2,16(sp)
    80002ed6:	e44e                	sd	s3,8(sp)
    80002ed8:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002eda:	fffff097          	auipc	ra,0xfffff
    80002ede:	aa6080e7          	jalr	-1370(ra) # 80001980 <myproc>
    80002ee2:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    80002ee4:	00000097          	auipc	ra,0x0
    80002ee8:	89e080e7          	jalr	-1890(ra) # 80002782 <mykthread>
    80002eec:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80002eee:	0b853983          	ld	s3,184(a0)
    80002ef2:	0a89b783          	ld	a5,168(s3)
    80002ef6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002efa:	37fd                	addiw	a5,a5,-1
    80002efc:	4751                	li	a4,20
    80002efe:	00f76f63          	bltu	a4,a5,80002f1c <syscall+0x50>
    80002f02:	00369713          	slli	a4,a3,0x3
    80002f06:	00005797          	auipc	a5,0x5
    80002f0a:	54a78793          	addi	a5,a5,1354 # 80008450 <syscalls>
    80002f0e:	97ba                	add	a5,a5,a4
    80002f10:	639c                	ld	a5,0(a5)
    80002f12:	c789                	beqz	a5,80002f1c <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    80002f14:	9782                	jalr	a5
    80002f16:	06a9b823          	sd	a0,112(s3)
    80002f1a:	a005                	j	80002f3a <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f1c:	19090613          	addi	a2,s2,400
    80002f20:	02492583          	lw	a1,36(s2)
    80002f24:	00005517          	auipc	a0,0x5
    80002f28:	4f450513          	addi	a0,a0,1268 # 80008418 <states.0+0x158>
    80002f2c:	ffffd097          	auipc	ra,0xffffd
    80002f30:	65c080e7          	jalr	1628(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    80002f34:	7cdc                	ld	a5,184(s1)
    80002f36:	577d                	li	a4,-1
    80002f38:	fbb8                	sd	a4,112(a5)
  }
}
    80002f3a:	70a2                	ld	ra,40(sp)
    80002f3c:	7402                	ld	s0,32(sp)
    80002f3e:	64e2                	ld	s1,24(sp)
    80002f40:	6942                	ld	s2,16(sp)
    80002f42:	69a2                	ld	s3,8(sp)
    80002f44:	6145                	addi	sp,sp,48
    80002f46:	8082                	ret

0000000080002f48 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f48:	1101                	addi	sp,sp,-32
    80002f4a:	ec06                	sd	ra,24(sp)
    80002f4c:	e822                	sd	s0,16(sp)
    80002f4e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f50:	fec40593          	addi	a1,s0,-20
    80002f54:	4501                	li	a0,0
    80002f56:	00000097          	auipc	ra,0x0
    80002f5a:	efe080e7          	jalr	-258(ra) # 80002e54 <argint>
  exit(n);
    80002f5e:	fec42503          	lw	a0,-20(s0)
    80002f62:	fffff097          	auipc	ra,0xfffff
    80002f66:	346080e7          	jalr	838(ra) # 800022a8 <exit>
  return 0;  // not reached
}
    80002f6a:	4501                	li	a0,0
    80002f6c:	60e2                	ld	ra,24(sp)
    80002f6e:	6442                	ld	s0,16(sp)
    80002f70:	6105                	addi	sp,sp,32
    80002f72:	8082                	ret

0000000080002f74 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f74:	1141                	addi	sp,sp,-16
    80002f76:	e406                	sd	ra,8(sp)
    80002f78:	e022                	sd	s0,0(sp)
    80002f7a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f7c:	fffff097          	auipc	ra,0xfffff
    80002f80:	a04080e7          	jalr	-1532(ra) # 80001980 <myproc>
}
    80002f84:	5148                	lw	a0,36(a0)
    80002f86:	60a2                	ld	ra,8(sp)
    80002f88:	6402                	ld	s0,0(sp)
    80002f8a:	0141                	addi	sp,sp,16
    80002f8c:	8082                	ret

0000000080002f8e <sys_fork>:

uint64
sys_fork(void)
{
    80002f8e:	1141                	addi	sp,sp,-16
    80002f90:	e406                	sd	ra,8(sp)
    80002f92:	e022                	sd	s0,0(sp)
    80002f94:	0800                	addi	s0,sp,16
  return fork();
    80002f96:	fffff097          	auipc	ra,0xfffff
    80002f9a:	dd2080e7          	jalr	-558(ra) # 80001d68 <fork>
}
    80002f9e:	60a2                	ld	ra,8(sp)
    80002fa0:	6402                	ld	s0,0(sp)
    80002fa2:	0141                	addi	sp,sp,16
    80002fa4:	8082                	ret

0000000080002fa6 <sys_wait>:

uint64
sys_wait(void)
{
    80002fa6:	1101                	addi	sp,sp,-32
    80002fa8:	ec06                	sd	ra,24(sp)
    80002faa:	e822                	sd	s0,16(sp)
    80002fac:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002fae:	fe840593          	addi	a1,s0,-24
    80002fb2:	4501                	li	a0,0
    80002fb4:	00000097          	auipc	ra,0x0
    80002fb8:	ec0080e7          	jalr	-320(ra) # 80002e74 <argaddr>
  return wait(p);
    80002fbc:	fe843503          	ld	a0,-24(s0)
    80002fc0:	fffff097          	auipc	ra,0xfffff
    80002fc4:	4c4080e7          	jalr	1220(ra) # 80002484 <wait>
}
    80002fc8:	60e2                	ld	ra,24(sp)
    80002fca:	6442                	ld	s0,16(sp)
    80002fcc:	6105                	addi	sp,sp,32
    80002fce:	8082                	ret

0000000080002fd0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fd0:	7179                	addi	sp,sp,-48
    80002fd2:	f406                	sd	ra,40(sp)
    80002fd4:	f022                	sd	s0,32(sp)
    80002fd6:	ec26                	sd	s1,24(sp)
    80002fd8:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002fda:	fdc40593          	addi	a1,s0,-36
    80002fde:	4501                	li	a0,0
    80002fe0:	00000097          	auipc	ra,0x0
    80002fe4:	e74080e7          	jalr	-396(ra) # 80002e54 <argint>
  addr = myproc()->sz;
    80002fe8:	fffff097          	auipc	ra,0xfffff
    80002fec:	998080e7          	jalr	-1640(ra) # 80001980 <myproc>
    80002ff0:	7d64                	ld	s1,248(a0)
  if(growproc(n) < 0)
    80002ff2:	fdc42503          	lw	a0,-36(s0)
    80002ff6:	fffff097          	auipc	ra,0xfffff
    80002ffa:	d12080e7          	jalr	-750(ra) # 80001d08 <growproc>
    80002ffe:	00054863          	bltz	a0,8000300e <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003002:	8526                	mv	a0,s1
    80003004:	70a2                	ld	ra,40(sp)
    80003006:	7402                	ld	s0,32(sp)
    80003008:	64e2                	ld	s1,24(sp)
    8000300a:	6145                	addi	sp,sp,48
    8000300c:	8082                	ret
    return -1;
    8000300e:	54fd                	li	s1,-1
    80003010:	bfcd                	j	80003002 <sys_sbrk+0x32>

0000000080003012 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003012:	7139                	addi	sp,sp,-64
    80003014:	fc06                	sd	ra,56(sp)
    80003016:	f822                	sd	s0,48(sp)
    80003018:	f426                	sd	s1,40(sp)
    8000301a:	f04a                	sd	s2,32(sp)
    8000301c:	ec4e                	sd	s3,24(sp)
    8000301e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003020:	fcc40593          	addi	a1,s0,-52
    80003024:	4501                	li	a0,0
    80003026:	00000097          	auipc	ra,0x0
    8000302a:	e2e080e7          	jalr	-466(ra) # 80002e54 <argint>
  acquire(&tickslock);
    8000302e:	00015517          	auipc	a0,0x15
    80003032:	f5250513          	addi	a0,a0,-174 # 80017f80 <tickslock>
    80003036:	ffffe097          	auipc	ra,0xffffe
    8000303a:	ba0080e7          	jalr	-1120(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    8000303e:	00006917          	auipc	s2,0x6
    80003042:	8a292903          	lw	s2,-1886(s2) # 800088e0 <ticks>
  while(ticks - ticks0 < n){
    80003046:	fcc42783          	lw	a5,-52(s0)
    8000304a:	cf9d                	beqz	a5,80003088 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000304c:	00015997          	auipc	s3,0x15
    80003050:	f3498993          	addi	s3,s3,-204 # 80017f80 <tickslock>
    80003054:	00006497          	auipc	s1,0x6
    80003058:	88c48493          	addi	s1,s1,-1908 # 800088e0 <ticks>
    if(killed(myproc())){
    8000305c:	fffff097          	auipc	ra,0xfffff
    80003060:	924080e7          	jalr	-1756(ra) # 80001980 <myproc>
    80003064:	fffff097          	auipc	ra,0xfffff
    80003068:	3ee080e7          	jalr	1006(ra) # 80002452 <killed>
    8000306c:	ed15                	bnez	a0,800030a8 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000306e:	85ce                	mv	a1,s3
    80003070:	8526                	mv	a0,s1
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	0ca080e7          	jalr	202(ra) # 8000213c <sleep>
  while(ticks - ticks0 < n){
    8000307a:	409c                	lw	a5,0(s1)
    8000307c:	412787bb          	subw	a5,a5,s2
    80003080:	fcc42703          	lw	a4,-52(s0)
    80003084:	fce7ece3          	bltu	a5,a4,8000305c <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003088:	00015517          	auipc	a0,0x15
    8000308c:	ef850513          	addi	a0,a0,-264 # 80017f80 <tickslock>
    80003090:	ffffe097          	auipc	ra,0xffffe
    80003094:	bfa080e7          	jalr	-1030(ra) # 80000c8a <release>
  return 0;
    80003098:	4501                	li	a0,0
}
    8000309a:	70e2                	ld	ra,56(sp)
    8000309c:	7442                	ld	s0,48(sp)
    8000309e:	74a2                	ld	s1,40(sp)
    800030a0:	7902                	ld	s2,32(sp)
    800030a2:	69e2                	ld	s3,24(sp)
    800030a4:	6121                	addi	sp,sp,64
    800030a6:	8082                	ret
      release(&tickslock);
    800030a8:	00015517          	auipc	a0,0x15
    800030ac:	ed850513          	addi	a0,a0,-296 # 80017f80 <tickslock>
    800030b0:	ffffe097          	auipc	ra,0xffffe
    800030b4:	bda080e7          	jalr	-1062(ra) # 80000c8a <release>
      return -1;
    800030b8:	557d                	li	a0,-1
    800030ba:	b7c5                	j	8000309a <sys_sleep+0x88>

00000000800030bc <sys_kill>:

uint64
sys_kill(void)
{
    800030bc:	1101                	addi	sp,sp,-32
    800030be:	ec06                	sd	ra,24(sp)
    800030c0:	e822                	sd	s0,16(sp)
    800030c2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800030c4:	fec40593          	addi	a1,s0,-20
    800030c8:	4501                	li	a0,0
    800030ca:	00000097          	auipc	ra,0x0
    800030ce:	d8a080e7          	jalr	-630(ra) # 80002e54 <argint>
  return kill(pid);
    800030d2:	fec42503          	lw	a0,-20(s0)
    800030d6:	fffff097          	auipc	ra,0xfffff
    800030da:	2c6080e7          	jalr	710(ra) # 8000239c <kill>
}
    800030de:	60e2                	ld	ra,24(sp)
    800030e0:	6442                	ld	s0,16(sp)
    800030e2:	6105                	addi	sp,sp,32
    800030e4:	8082                	ret

00000000800030e6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030e6:	1101                	addi	sp,sp,-32
    800030e8:	ec06                	sd	ra,24(sp)
    800030ea:	e822                	sd	s0,16(sp)
    800030ec:	e426                	sd	s1,8(sp)
    800030ee:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030f0:	00015517          	auipc	a0,0x15
    800030f4:	e9050513          	addi	a0,a0,-368 # 80017f80 <tickslock>
    800030f8:	ffffe097          	auipc	ra,0xffffe
    800030fc:	ade080e7          	jalr	-1314(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003100:	00005497          	auipc	s1,0x5
    80003104:	7e04a483          	lw	s1,2016(s1) # 800088e0 <ticks>
  release(&tickslock);
    80003108:	00015517          	auipc	a0,0x15
    8000310c:	e7850513          	addi	a0,a0,-392 # 80017f80 <tickslock>
    80003110:	ffffe097          	auipc	ra,0xffffe
    80003114:	b7a080e7          	jalr	-1158(ra) # 80000c8a <release>
  return xticks;
}
    80003118:	02049513          	slli	a0,s1,0x20
    8000311c:	9101                	srli	a0,a0,0x20
    8000311e:	60e2                	ld	ra,24(sp)
    80003120:	6442                	ld	s0,16(sp)
    80003122:	64a2                	ld	s1,8(sp)
    80003124:	6105                	addi	sp,sp,32
    80003126:	8082                	ret

0000000080003128 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003128:	7179                	addi	sp,sp,-48
    8000312a:	f406                	sd	ra,40(sp)
    8000312c:	f022                	sd	s0,32(sp)
    8000312e:	ec26                	sd	s1,24(sp)
    80003130:	e84a                	sd	s2,16(sp)
    80003132:	e44e                	sd	s3,8(sp)
    80003134:	e052                	sd	s4,0(sp)
    80003136:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003138:	00005597          	auipc	a1,0x5
    8000313c:	3c858593          	addi	a1,a1,968 # 80008500 <syscalls+0xb0>
    80003140:	00015517          	auipc	a0,0x15
    80003144:	e5850513          	addi	a0,a0,-424 # 80017f98 <bcache>
    80003148:	ffffe097          	auipc	ra,0xffffe
    8000314c:	9fe080e7          	jalr	-1538(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003150:	0001d797          	auipc	a5,0x1d
    80003154:	e4878793          	addi	a5,a5,-440 # 8001ff98 <bcache+0x8000>
    80003158:	0001d717          	auipc	a4,0x1d
    8000315c:	0a870713          	addi	a4,a4,168 # 80020200 <bcache+0x8268>
    80003160:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003164:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003168:	00015497          	auipc	s1,0x15
    8000316c:	e4848493          	addi	s1,s1,-440 # 80017fb0 <bcache+0x18>
    b->next = bcache.head.next;
    80003170:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003172:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003174:	00005a17          	auipc	s4,0x5
    80003178:	394a0a13          	addi	s4,s4,916 # 80008508 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000317c:	2b893783          	ld	a5,696(s2)
    80003180:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003182:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003186:	85d2                	mv	a1,s4
    80003188:	01048513          	addi	a0,s1,16
    8000318c:	00001097          	auipc	ra,0x1
    80003190:	4c4080e7          	jalr	1220(ra) # 80004650 <initsleeplock>
    bcache.head.next->prev = b;
    80003194:	2b893783          	ld	a5,696(s2)
    80003198:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000319a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000319e:	45848493          	addi	s1,s1,1112
    800031a2:	fd349de3          	bne	s1,s3,8000317c <binit+0x54>
  }
}
    800031a6:	70a2                	ld	ra,40(sp)
    800031a8:	7402                	ld	s0,32(sp)
    800031aa:	64e2                	ld	s1,24(sp)
    800031ac:	6942                	ld	s2,16(sp)
    800031ae:	69a2                	ld	s3,8(sp)
    800031b0:	6a02                	ld	s4,0(sp)
    800031b2:	6145                	addi	sp,sp,48
    800031b4:	8082                	ret

00000000800031b6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031b6:	7179                	addi	sp,sp,-48
    800031b8:	f406                	sd	ra,40(sp)
    800031ba:	f022                	sd	s0,32(sp)
    800031bc:	ec26                	sd	s1,24(sp)
    800031be:	e84a                	sd	s2,16(sp)
    800031c0:	e44e                	sd	s3,8(sp)
    800031c2:	1800                	addi	s0,sp,48
    800031c4:	892a                	mv	s2,a0
    800031c6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031c8:	00015517          	auipc	a0,0x15
    800031cc:	dd050513          	addi	a0,a0,-560 # 80017f98 <bcache>
    800031d0:	ffffe097          	auipc	ra,0xffffe
    800031d4:	a06080e7          	jalr	-1530(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031d8:	0001d497          	auipc	s1,0x1d
    800031dc:	0784b483          	ld	s1,120(s1) # 80020250 <bcache+0x82b8>
    800031e0:	0001d797          	auipc	a5,0x1d
    800031e4:	02078793          	addi	a5,a5,32 # 80020200 <bcache+0x8268>
    800031e8:	02f48f63          	beq	s1,a5,80003226 <bread+0x70>
    800031ec:	873e                	mv	a4,a5
    800031ee:	a021                	j	800031f6 <bread+0x40>
    800031f0:	68a4                	ld	s1,80(s1)
    800031f2:	02e48a63          	beq	s1,a4,80003226 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031f6:	449c                	lw	a5,8(s1)
    800031f8:	ff279ce3          	bne	a5,s2,800031f0 <bread+0x3a>
    800031fc:	44dc                	lw	a5,12(s1)
    800031fe:	ff3799e3          	bne	a5,s3,800031f0 <bread+0x3a>
      b->refcnt++;
    80003202:	40bc                	lw	a5,64(s1)
    80003204:	2785                	addiw	a5,a5,1
    80003206:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003208:	00015517          	auipc	a0,0x15
    8000320c:	d9050513          	addi	a0,a0,-624 # 80017f98 <bcache>
    80003210:	ffffe097          	auipc	ra,0xffffe
    80003214:	a7a080e7          	jalr	-1414(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003218:	01048513          	addi	a0,s1,16
    8000321c:	00001097          	auipc	ra,0x1
    80003220:	46e080e7          	jalr	1134(ra) # 8000468a <acquiresleep>
      return b;
    80003224:	a8b9                	j	80003282 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003226:	0001d497          	auipc	s1,0x1d
    8000322a:	0224b483          	ld	s1,34(s1) # 80020248 <bcache+0x82b0>
    8000322e:	0001d797          	auipc	a5,0x1d
    80003232:	fd278793          	addi	a5,a5,-46 # 80020200 <bcache+0x8268>
    80003236:	00f48863          	beq	s1,a5,80003246 <bread+0x90>
    8000323a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000323c:	40bc                	lw	a5,64(s1)
    8000323e:	cf81                	beqz	a5,80003256 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003240:	64a4                	ld	s1,72(s1)
    80003242:	fee49de3          	bne	s1,a4,8000323c <bread+0x86>
  panic("bget: no buffers");
    80003246:	00005517          	auipc	a0,0x5
    8000324a:	2ca50513          	addi	a0,a0,714 # 80008510 <syscalls+0xc0>
    8000324e:	ffffd097          	auipc	ra,0xffffd
    80003252:	2f0080e7          	jalr	752(ra) # 8000053e <panic>
      b->dev = dev;
    80003256:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000325a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000325e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003262:	4785                	li	a5,1
    80003264:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003266:	00015517          	auipc	a0,0x15
    8000326a:	d3250513          	addi	a0,a0,-718 # 80017f98 <bcache>
    8000326e:	ffffe097          	auipc	ra,0xffffe
    80003272:	a1c080e7          	jalr	-1508(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003276:	01048513          	addi	a0,s1,16
    8000327a:	00001097          	auipc	ra,0x1
    8000327e:	410080e7          	jalr	1040(ra) # 8000468a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003282:	409c                	lw	a5,0(s1)
    80003284:	cb89                	beqz	a5,80003296 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003286:	8526                	mv	a0,s1
    80003288:	70a2                	ld	ra,40(sp)
    8000328a:	7402                	ld	s0,32(sp)
    8000328c:	64e2                	ld	s1,24(sp)
    8000328e:	6942                	ld	s2,16(sp)
    80003290:	69a2                	ld	s3,8(sp)
    80003292:	6145                	addi	sp,sp,48
    80003294:	8082                	ret
    virtio_disk_rw(b, 0);
    80003296:	4581                	li	a1,0
    80003298:	8526                	mv	a0,s1
    8000329a:	00003097          	auipc	ra,0x3
    8000329e:	ffa080e7          	jalr	-6(ra) # 80006294 <virtio_disk_rw>
    b->valid = 1;
    800032a2:	4785                	li	a5,1
    800032a4:	c09c                	sw	a5,0(s1)
  return b;
    800032a6:	b7c5                	j	80003286 <bread+0xd0>

00000000800032a8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032a8:	1101                	addi	sp,sp,-32
    800032aa:	ec06                	sd	ra,24(sp)
    800032ac:	e822                	sd	s0,16(sp)
    800032ae:	e426                	sd	s1,8(sp)
    800032b0:	1000                	addi	s0,sp,32
    800032b2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032b4:	0541                	addi	a0,a0,16
    800032b6:	00001097          	auipc	ra,0x1
    800032ba:	46e080e7          	jalr	1134(ra) # 80004724 <holdingsleep>
    800032be:	cd01                	beqz	a0,800032d6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032c0:	4585                	li	a1,1
    800032c2:	8526                	mv	a0,s1
    800032c4:	00003097          	auipc	ra,0x3
    800032c8:	fd0080e7          	jalr	-48(ra) # 80006294 <virtio_disk_rw>
}
    800032cc:	60e2                	ld	ra,24(sp)
    800032ce:	6442                	ld	s0,16(sp)
    800032d0:	64a2                	ld	s1,8(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret
    panic("bwrite");
    800032d6:	00005517          	auipc	a0,0x5
    800032da:	25250513          	addi	a0,a0,594 # 80008528 <syscalls+0xd8>
    800032de:	ffffd097          	auipc	ra,0xffffd
    800032e2:	260080e7          	jalr	608(ra) # 8000053e <panic>

00000000800032e6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032e6:	1101                	addi	sp,sp,-32
    800032e8:	ec06                	sd	ra,24(sp)
    800032ea:	e822                	sd	s0,16(sp)
    800032ec:	e426                	sd	s1,8(sp)
    800032ee:	e04a                	sd	s2,0(sp)
    800032f0:	1000                	addi	s0,sp,32
    800032f2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032f4:	01050913          	addi	s2,a0,16
    800032f8:	854a                	mv	a0,s2
    800032fa:	00001097          	auipc	ra,0x1
    800032fe:	42a080e7          	jalr	1066(ra) # 80004724 <holdingsleep>
    80003302:	c92d                	beqz	a0,80003374 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003304:	854a                	mv	a0,s2
    80003306:	00001097          	auipc	ra,0x1
    8000330a:	3da080e7          	jalr	986(ra) # 800046e0 <releasesleep>

  acquire(&bcache.lock);
    8000330e:	00015517          	auipc	a0,0x15
    80003312:	c8a50513          	addi	a0,a0,-886 # 80017f98 <bcache>
    80003316:	ffffe097          	auipc	ra,0xffffe
    8000331a:	8c0080e7          	jalr	-1856(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000331e:	40bc                	lw	a5,64(s1)
    80003320:	37fd                	addiw	a5,a5,-1
    80003322:	0007871b          	sext.w	a4,a5
    80003326:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003328:	eb05                	bnez	a4,80003358 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000332a:	68bc                	ld	a5,80(s1)
    8000332c:	64b8                	ld	a4,72(s1)
    8000332e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003330:	64bc                	ld	a5,72(s1)
    80003332:	68b8                	ld	a4,80(s1)
    80003334:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003336:	0001d797          	auipc	a5,0x1d
    8000333a:	c6278793          	addi	a5,a5,-926 # 8001ff98 <bcache+0x8000>
    8000333e:	2b87b703          	ld	a4,696(a5)
    80003342:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003344:	0001d717          	auipc	a4,0x1d
    80003348:	ebc70713          	addi	a4,a4,-324 # 80020200 <bcache+0x8268>
    8000334c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000334e:	2b87b703          	ld	a4,696(a5)
    80003352:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003354:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003358:	00015517          	auipc	a0,0x15
    8000335c:	c4050513          	addi	a0,a0,-960 # 80017f98 <bcache>
    80003360:	ffffe097          	auipc	ra,0xffffe
    80003364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
}
    80003368:	60e2                	ld	ra,24(sp)
    8000336a:	6442                	ld	s0,16(sp)
    8000336c:	64a2                	ld	s1,8(sp)
    8000336e:	6902                	ld	s2,0(sp)
    80003370:	6105                	addi	sp,sp,32
    80003372:	8082                	ret
    panic("brelse");
    80003374:	00005517          	auipc	a0,0x5
    80003378:	1bc50513          	addi	a0,a0,444 # 80008530 <syscalls+0xe0>
    8000337c:	ffffd097          	auipc	ra,0xffffd
    80003380:	1c2080e7          	jalr	450(ra) # 8000053e <panic>

0000000080003384 <bpin>:

void
bpin(struct buf *b) {
    80003384:	1101                	addi	sp,sp,-32
    80003386:	ec06                	sd	ra,24(sp)
    80003388:	e822                	sd	s0,16(sp)
    8000338a:	e426                	sd	s1,8(sp)
    8000338c:	1000                	addi	s0,sp,32
    8000338e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003390:	00015517          	auipc	a0,0x15
    80003394:	c0850513          	addi	a0,a0,-1016 # 80017f98 <bcache>
    80003398:	ffffe097          	auipc	ra,0xffffe
    8000339c:	83e080e7          	jalr	-1986(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800033a0:	40bc                	lw	a5,64(s1)
    800033a2:	2785                	addiw	a5,a5,1
    800033a4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033a6:	00015517          	auipc	a0,0x15
    800033aa:	bf250513          	addi	a0,a0,-1038 # 80017f98 <bcache>
    800033ae:	ffffe097          	auipc	ra,0xffffe
    800033b2:	8dc080e7          	jalr	-1828(ra) # 80000c8a <release>
}
    800033b6:	60e2                	ld	ra,24(sp)
    800033b8:	6442                	ld	s0,16(sp)
    800033ba:	64a2                	ld	s1,8(sp)
    800033bc:	6105                	addi	sp,sp,32
    800033be:	8082                	ret

00000000800033c0 <bunpin>:

void
bunpin(struct buf *b) {
    800033c0:	1101                	addi	sp,sp,-32
    800033c2:	ec06                	sd	ra,24(sp)
    800033c4:	e822                	sd	s0,16(sp)
    800033c6:	e426                	sd	s1,8(sp)
    800033c8:	1000                	addi	s0,sp,32
    800033ca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033cc:	00015517          	auipc	a0,0x15
    800033d0:	bcc50513          	addi	a0,a0,-1076 # 80017f98 <bcache>
    800033d4:	ffffe097          	auipc	ra,0xffffe
    800033d8:	802080e7          	jalr	-2046(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800033dc:	40bc                	lw	a5,64(s1)
    800033de:	37fd                	addiw	a5,a5,-1
    800033e0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033e2:	00015517          	auipc	a0,0x15
    800033e6:	bb650513          	addi	a0,a0,-1098 # 80017f98 <bcache>
    800033ea:	ffffe097          	auipc	ra,0xffffe
    800033ee:	8a0080e7          	jalr	-1888(ra) # 80000c8a <release>
}
    800033f2:	60e2                	ld	ra,24(sp)
    800033f4:	6442                	ld	s0,16(sp)
    800033f6:	64a2                	ld	s1,8(sp)
    800033f8:	6105                	addi	sp,sp,32
    800033fa:	8082                	ret

00000000800033fc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033fc:	1101                	addi	sp,sp,-32
    800033fe:	ec06                	sd	ra,24(sp)
    80003400:	e822                	sd	s0,16(sp)
    80003402:	e426                	sd	s1,8(sp)
    80003404:	e04a                	sd	s2,0(sp)
    80003406:	1000                	addi	s0,sp,32
    80003408:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000340a:	00d5d59b          	srliw	a1,a1,0xd
    8000340e:	0001d797          	auipc	a5,0x1d
    80003412:	2667a783          	lw	a5,614(a5) # 80020674 <sb+0x1c>
    80003416:	9dbd                	addw	a1,a1,a5
    80003418:	00000097          	auipc	ra,0x0
    8000341c:	d9e080e7          	jalr	-610(ra) # 800031b6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003420:	0074f713          	andi	a4,s1,7
    80003424:	4785                	li	a5,1
    80003426:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000342a:	14ce                	slli	s1,s1,0x33
    8000342c:	90d9                	srli	s1,s1,0x36
    8000342e:	00950733          	add	a4,a0,s1
    80003432:	05874703          	lbu	a4,88(a4)
    80003436:	00e7f6b3          	and	a3,a5,a4
    8000343a:	c69d                	beqz	a3,80003468 <bfree+0x6c>
    8000343c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000343e:	94aa                	add	s1,s1,a0
    80003440:	fff7c793          	not	a5,a5
    80003444:	8ff9                	and	a5,a5,a4
    80003446:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000344a:	00001097          	auipc	ra,0x1
    8000344e:	120080e7          	jalr	288(ra) # 8000456a <log_write>
  brelse(bp);
    80003452:	854a                	mv	a0,s2
    80003454:	00000097          	auipc	ra,0x0
    80003458:	e92080e7          	jalr	-366(ra) # 800032e6 <brelse>
}
    8000345c:	60e2                	ld	ra,24(sp)
    8000345e:	6442                	ld	s0,16(sp)
    80003460:	64a2                	ld	s1,8(sp)
    80003462:	6902                	ld	s2,0(sp)
    80003464:	6105                	addi	sp,sp,32
    80003466:	8082                	ret
    panic("freeing free block");
    80003468:	00005517          	auipc	a0,0x5
    8000346c:	0d050513          	addi	a0,a0,208 # 80008538 <syscalls+0xe8>
    80003470:	ffffd097          	auipc	ra,0xffffd
    80003474:	0ce080e7          	jalr	206(ra) # 8000053e <panic>

0000000080003478 <balloc>:
{
    80003478:	711d                	addi	sp,sp,-96
    8000347a:	ec86                	sd	ra,88(sp)
    8000347c:	e8a2                	sd	s0,80(sp)
    8000347e:	e4a6                	sd	s1,72(sp)
    80003480:	e0ca                	sd	s2,64(sp)
    80003482:	fc4e                	sd	s3,56(sp)
    80003484:	f852                	sd	s4,48(sp)
    80003486:	f456                	sd	s5,40(sp)
    80003488:	f05a                	sd	s6,32(sp)
    8000348a:	ec5e                	sd	s7,24(sp)
    8000348c:	e862                	sd	s8,16(sp)
    8000348e:	e466                	sd	s9,8(sp)
    80003490:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003492:	0001d797          	auipc	a5,0x1d
    80003496:	1ca7a783          	lw	a5,458(a5) # 8002065c <sb+0x4>
    8000349a:	10078163          	beqz	a5,8000359c <balloc+0x124>
    8000349e:	8baa                	mv	s7,a0
    800034a0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034a2:	0001db17          	auipc	s6,0x1d
    800034a6:	1b6b0b13          	addi	s6,s6,438 # 80020658 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034aa:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034ac:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ae:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034b0:	6c89                	lui	s9,0x2
    800034b2:	a061                	j	8000353a <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034b4:	974a                	add	a4,a4,s2
    800034b6:	8fd5                	or	a5,a5,a3
    800034b8:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800034bc:	854a                	mv	a0,s2
    800034be:	00001097          	auipc	ra,0x1
    800034c2:	0ac080e7          	jalr	172(ra) # 8000456a <log_write>
        brelse(bp);
    800034c6:	854a                	mv	a0,s2
    800034c8:	00000097          	auipc	ra,0x0
    800034cc:	e1e080e7          	jalr	-482(ra) # 800032e6 <brelse>
  bp = bread(dev, bno);
    800034d0:	85a6                	mv	a1,s1
    800034d2:	855e                	mv	a0,s7
    800034d4:	00000097          	auipc	ra,0x0
    800034d8:	ce2080e7          	jalr	-798(ra) # 800031b6 <bread>
    800034dc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034de:	40000613          	li	a2,1024
    800034e2:	4581                	li	a1,0
    800034e4:	05850513          	addi	a0,a0,88
    800034e8:	ffffd097          	auipc	ra,0xffffd
    800034ec:	7ea080e7          	jalr	2026(ra) # 80000cd2 <memset>
  log_write(bp);
    800034f0:	854a                	mv	a0,s2
    800034f2:	00001097          	auipc	ra,0x1
    800034f6:	078080e7          	jalr	120(ra) # 8000456a <log_write>
  brelse(bp);
    800034fa:	854a                	mv	a0,s2
    800034fc:	00000097          	auipc	ra,0x0
    80003500:	dea080e7          	jalr	-534(ra) # 800032e6 <brelse>
}
    80003504:	8526                	mv	a0,s1
    80003506:	60e6                	ld	ra,88(sp)
    80003508:	6446                	ld	s0,80(sp)
    8000350a:	64a6                	ld	s1,72(sp)
    8000350c:	6906                	ld	s2,64(sp)
    8000350e:	79e2                	ld	s3,56(sp)
    80003510:	7a42                	ld	s4,48(sp)
    80003512:	7aa2                	ld	s5,40(sp)
    80003514:	7b02                	ld	s6,32(sp)
    80003516:	6be2                	ld	s7,24(sp)
    80003518:	6c42                	ld	s8,16(sp)
    8000351a:	6ca2                	ld	s9,8(sp)
    8000351c:	6125                	addi	sp,sp,96
    8000351e:	8082                	ret
    brelse(bp);
    80003520:	854a                	mv	a0,s2
    80003522:	00000097          	auipc	ra,0x0
    80003526:	dc4080e7          	jalr	-572(ra) # 800032e6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000352a:	015c87bb          	addw	a5,s9,s5
    8000352e:	00078a9b          	sext.w	s5,a5
    80003532:	004b2703          	lw	a4,4(s6)
    80003536:	06eaf363          	bgeu	s5,a4,8000359c <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000353a:	41fad79b          	sraiw	a5,s5,0x1f
    8000353e:	0137d79b          	srliw	a5,a5,0x13
    80003542:	015787bb          	addw	a5,a5,s5
    80003546:	40d7d79b          	sraiw	a5,a5,0xd
    8000354a:	01cb2583          	lw	a1,28(s6)
    8000354e:	9dbd                	addw	a1,a1,a5
    80003550:	855e                	mv	a0,s7
    80003552:	00000097          	auipc	ra,0x0
    80003556:	c64080e7          	jalr	-924(ra) # 800031b6 <bread>
    8000355a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000355c:	004b2503          	lw	a0,4(s6)
    80003560:	000a849b          	sext.w	s1,s5
    80003564:	8662                	mv	a2,s8
    80003566:	faa4fde3          	bgeu	s1,a0,80003520 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000356a:	41f6579b          	sraiw	a5,a2,0x1f
    8000356e:	01d7d69b          	srliw	a3,a5,0x1d
    80003572:	00c6873b          	addw	a4,a3,a2
    80003576:	00777793          	andi	a5,a4,7
    8000357a:	9f95                	subw	a5,a5,a3
    8000357c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003580:	4037571b          	sraiw	a4,a4,0x3
    80003584:	00e906b3          	add	a3,s2,a4
    80003588:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    8000358c:	00d7f5b3          	and	a1,a5,a3
    80003590:	d195                	beqz	a1,800034b4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003592:	2605                	addiw	a2,a2,1
    80003594:	2485                	addiw	s1,s1,1
    80003596:	fd4618e3          	bne	a2,s4,80003566 <balloc+0xee>
    8000359a:	b759                	j	80003520 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000359c:	00005517          	auipc	a0,0x5
    800035a0:	fb450513          	addi	a0,a0,-76 # 80008550 <syscalls+0x100>
    800035a4:	ffffd097          	auipc	ra,0xffffd
    800035a8:	fe4080e7          	jalr	-28(ra) # 80000588 <printf>
  return 0;
    800035ac:	4481                	li	s1,0
    800035ae:	bf99                	j	80003504 <balloc+0x8c>

00000000800035b0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035b0:	7179                	addi	sp,sp,-48
    800035b2:	f406                	sd	ra,40(sp)
    800035b4:	f022                	sd	s0,32(sp)
    800035b6:	ec26                	sd	s1,24(sp)
    800035b8:	e84a                	sd	s2,16(sp)
    800035ba:	e44e                	sd	s3,8(sp)
    800035bc:	e052                	sd	s4,0(sp)
    800035be:	1800                	addi	s0,sp,48
    800035c0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035c2:	47ad                	li	a5,11
    800035c4:	02b7e763          	bltu	a5,a1,800035f2 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800035c8:	02059493          	slli	s1,a1,0x20
    800035cc:	9081                	srli	s1,s1,0x20
    800035ce:	048a                	slli	s1,s1,0x2
    800035d0:	94aa                	add	s1,s1,a0
    800035d2:	0504a903          	lw	s2,80(s1)
    800035d6:	06091e63          	bnez	s2,80003652 <bmap+0xa2>
      addr = balloc(ip->dev);
    800035da:	4108                	lw	a0,0(a0)
    800035dc:	00000097          	auipc	ra,0x0
    800035e0:	e9c080e7          	jalr	-356(ra) # 80003478 <balloc>
    800035e4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035e8:	06090563          	beqz	s2,80003652 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800035ec:	0524a823          	sw	s2,80(s1)
    800035f0:	a08d                	j	80003652 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035f2:	ff45849b          	addiw	s1,a1,-12
    800035f6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035fa:	0ff00793          	li	a5,255
    800035fe:	08e7e563          	bltu	a5,a4,80003688 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003602:	08052903          	lw	s2,128(a0)
    80003606:	00091d63          	bnez	s2,80003620 <bmap+0x70>
      addr = balloc(ip->dev);
    8000360a:	4108                	lw	a0,0(a0)
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	e6c080e7          	jalr	-404(ra) # 80003478 <balloc>
    80003614:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003618:	02090d63          	beqz	s2,80003652 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000361c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003620:	85ca                	mv	a1,s2
    80003622:	0009a503          	lw	a0,0(s3)
    80003626:	00000097          	auipc	ra,0x0
    8000362a:	b90080e7          	jalr	-1136(ra) # 800031b6 <bread>
    8000362e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003630:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003634:	02049593          	slli	a1,s1,0x20
    80003638:	9181                	srli	a1,a1,0x20
    8000363a:	058a                	slli	a1,a1,0x2
    8000363c:	00b784b3          	add	s1,a5,a1
    80003640:	0004a903          	lw	s2,0(s1)
    80003644:	02090063          	beqz	s2,80003664 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003648:	8552                	mv	a0,s4
    8000364a:	00000097          	auipc	ra,0x0
    8000364e:	c9c080e7          	jalr	-868(ra) # 800032e6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003652:	854a                	mv	a0,s2
    80003654:	70a2                	ld	ra,40(sp)
    80003656:	7402                	ld	s0,32(sp)
    80003658:	64e2                	ld	s1,24(sp)
    8000365a:	6942                	ld	s2,16(sp)
    8000365c:	69a2                	ld	s3,8(sp)
    8000365e:	6a02                	ld	s4,0(sp)
    80003660:	6145                	addi	sp,sp,48
    80003662:	8082                	ret
      addr = balloc(ip->dev);
    80003664:	0009a503          	lw	a0,0(s3)
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	e10080e7          	jalr	-496(ra) # 80003478 <balloc>
    80003670:	0005091b          	sext.w	s2,a0
      if(addr){
    80003674:	fc090ae3          	beqz	s2,80003648 <bmap+0x98>
        a[bn] = addr;
    80003678:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000367c:	8552                	mv	a0,s4
    8000367e:	00001097          	auipc	ra,0x1
    80003682:	eec080e7          	jalr	-276(ra) # 8000456a <log_write>
    80003686:	b7c9                	j	80003648 <bmap+0x98>
  panic("bmap: out of range");
    80003688:	00005517          	auipc	a0,0x5
    8000368c:	ee050513          	addi	a0,a0,-288 # 80008568 <syscalls+0x118>
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	eae080e7          	jalr	-338(ra) # 8000053e <panic>

0000000080003698 <iget>:
{
    80003698:	7179                	addi	sp,sp,-48
    8000369a:	f406                	sd	ra,40(sp)
    8000369c:	f022                	sd	s0,32(sp)
    8000369e:	ec26                	sd	s1,24(sp)
    800036a0:	e84a                	sd	s2,16(sp)
    800036a2:	e44e                	sd	s3,8(sp)
    800036a4:	e052                	sd	s4,0(sp)
    800036a6:	1800                	addi	s0,sp,48
    800036a8:	89aa                	mv	s3,a0
    800036aa:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036ac:	0001d517          	auipc	a0,0x1d
    800036b0:	fcc50513          	addi	a0,a0,-52 # 80020678 <itable>
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	522080e7          	jalr	1314(ra) # 80000bd6 <acquire>
  empty = 0;
    800036bc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036be:	0001d497          	auipc	s1,0x1d
    800036c2:	fd248493          	addi	s1,s1,-46 # 80020690 <itable+0x18>
    800036c6:	0001f697          	auipc	a3,0x1f
    800036ca:	a5a68693          	addi	a3,a3,-1446 # 80022120 <log>
    800036ce:	a039                	j	800036dc <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036d0:	02090b63          	beqz	s2,80003706 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036d4:	08848493          	addi	s1,s1,136
    800036d8:	02d48a63          	beq	s1,a3,8000370c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036dc:	449c                	lw	a5,8(s1)
    800036de:	fef059e3          	blez	a5,800036d0 <iget+0x38>
    800036e2:	4098                	lw	a4,0(s1)
    800036e4:	ff3716e3          	bne	a4,s3,800036d0 <iget+0x38>
    800036e8:	40d8                	lw	a4,4(s1)
    800036ea:	ff4713e3          	bne	a4,s4,800036d0 <iget+0x38>
      ip->ref++;
    800036ee:	2785                	addiw	a5,a5,1
    800036f0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036f2:	0001d517          	auipc	a0,0x1d
    800036f6:	f8650513          	addi	a0,a0,-122 # 80020678 <itable>
    800036fa:	ffffd097          	auipc	ra,0xffffd
    800036fe:	590080e7          	jalr	1424(ra) # 80000c8a <release>
      return ip;
    80003702:	8926                	mv	s2,s1
    80003704:	a03d                	j	80003732 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003706:	f7f9                	bnez	a5,800036d4 <iget+0x3c>
    80003708:	8926                	mv	s2,s1
    8000370a:	b7e9                	j	800036d4 <iget+0x3c>
  if(empty == 0)
    8000370c:	02090c63          	beqz	s2,80003744 <iget+0xac>
  ip->dev = dev;
    80003710:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003714:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003718:	4785                	li	a5,1
    8000371a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000371e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003722:	0001d517          	auipc	a0,0x1d
    80003726:	f5650513          	addi	a0,a0,-170 # 80020678 <itable>
    8000372a:	ffffd097          	auipc	ra,0xffffd
    8000372e:	560080e7          	jalr	1376(ra) # 80000c8a <release>
}
    80003732:	854a                	mv	a0,s2
    80003734:	70a2                	ld	ra,40(sp)
    80003736:	7402                	ld	s0,32(sp)
    80003738:	64e2                	ld	s1,24(sp)
    8000373a:	6942                	ld	s2,16(sp)
    8000373c:	69a2                	ld	s3,8(sp)
    8000373e:	6a02                	ld	s4,0(sp)
    80003740:	6145                	addi	sp,sp,48
    80003742:	8082                	ret
    panic("iget: no inodes");
    80003744:	00005517          	auipc	a0,0x5
    80003748:	e3c50513          	addi	a0,a0,-452 # 80008580 <syscalls+0x130>
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	df2080e7          	jalr	-526(ra) # 8000053e <panic>

0000000080003754 <fsinit>:
fsinit(int dev) {
    80003754:	7179                	addi	sp,sp,-48
    80003756:	f406                	sd	ra,40(sp)
    80003758:	f022                	sd	s0,32(sp)
    8000375a:	ec26                	sd	s1,24(sp)
    8000375c:	e84a                	sd	s2,16(sp)
    8000375e:	e44e                	sd	s3,8(sp)
    80003760:	1800                	addi	s0,sp,48
    80003762:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003764:	4585                	li	a1,1
    80003766:	00000097          	auipc	ra,0x0
    8000376a:	a50080e7          	jalr	-1456(ra) # 800031b6 <bread>
    8000376e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003770:	0001d997          	auipc	s3,0x1d
    80003774:	ee898993          	addi	s3,s3,-280 # 80020658 <sb>
    80003778:	02000613          	li	a2,32
    8000377c:	05850593          	addi	a1,a0,88
    80003780:	854e                	mv	a0,s3
    80003782:	ffffd097          	auipc	ra,0xffffd
    80003786:	5ac080e7          	jalr	1452(ra) # 80000d2e <memmove>
  brelse(bp);
    8000378a:	8526                	mv	a0,s1
    8000378c:	00000097          	auipc	ra,0x0
    80003790:	b5a080e7          	jalr	-1190(ra) # 800032e6 <brelse>
  if(sb.magic != FSMAGIC)
    80003794:	0009a703          	lw	a4,0(s3)
    80003798:	102037b7          	lui	a5,0x10203
    8000379c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037a0:	02f71263          	bne	a4,a5,800037c4 <fsinit+0x70>
  initlog(dev, &sb);
    800037a4:	0001d597          	auipc	a1,0x1d
    800037a8:	eb458593          	addi	a1,a1,-332 # 80020658 <sb>
    800037ac:	854a                	mv	a0,s2
    800037ae:	00001097          	auipc	ra,0x1
    800037b2:	b40080e7          	jalr	-1216(ra) # 800042ee <initlog>
}
    800037b6:	70a2                	ld	ra,40(sp)
    800037b8:	7402                	ld	s0,32(sp)
    800037ba:	64e2                	ld	s1,24(sp)
    800037bc:	6942                	ld	s2,16(sp)
    800037be:	69a2                	ld	s3,8(sp)
    800037c0:	6145                	addi	sp,sp,48
    800037c2:	8082                	ret
    panic("invalid file system");
    800037c4:	00005517          	auipc	a0,0x5
    800037c8:	dcc50513          	addi	a0,a0,-564 # 80008590 <syscalls+0x140>
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	d72080e7          	jalr	-654(ra) # 8000053e <panic>

00000000800037d4 <iinit>:
{
    800037d4:	7179                	addi	sp,sp,-48
    800037d6:	f406                	sd	ra,40(sp)
    800037d8:	f022                	sd	s0,32(sp)
    800037da:	ec26                	sd	s1,24(sp)
    800037dc:	e84a                	sd	s2,16(sp)
    800037de:	e44e                	sd	s3,8(sp)
    800037e0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800037e2:	00005597          	auipc	a1,0x5
    800037e6:	dc658593          	addi	a1,a1,-570 # 800085a8 <syscalls+0x158>
    800037ea:	0001d517          	auipc	a0,0x1d
    800037ee:	e8e50513          	addi	a0,a0,-370 # 80020678 <itable>
    800037f2:	ffffd097          	auipc	ra,0xffffd
    800037f6:	354080e7          	jalr	852(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037fa:	0001d497          	auipc	s1,0x1d
    800037fe:	ea648493          	addi	s1,s1,-346 # 800206a0 <itable+0x28>
    80003802:	0001f997          	auipc	s3,0x1f
    80003806:	92e98993          	addi	s3,s3,-1746 # 80022130 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000380a:	00005917          	auipc	s2,0x5
    8000380e:	da690913          	addi	s2,s2,-602 # 800085b0 <syscalls+0x160>
    80003812:	85ca                	mv	a1,s2
    80003814:	8526                	mv	a0,s1
    80003816:	00001097          	auipc	ra,0x1
    8000381a:	e3a080e7          	jalr	-454(ra) # 80004650 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000381e:	08848493          	addi	s1,s1,136
    80003822:	ff3498e3          	bne	s1,s3,80003812 <iinit+0x3e>
}
    80003826:	70a2                	ld	ra,40(sp)
    80003828:	7402                	ld	s0,32(sp)
    8000382a:	64e2                	ld	s1,24(sp)
    8000382c:	6942                	ld	s2,16(sp)
    8000382e:	69a2                	ld	s3,8(sp)
    80003830:	6145                	addi	sp,sp,48
    80003832:	8082                	ret

0000000080003834 <ialloc>:
{
    80003834:	715d                	addi	sp,sp,-80
    80003836:	e486                	sd	ra,72(sp)
    80003838:	e0a2                	sd	s0,64(sp)
    8000383a:	fc26                	sd	s1,56(sp)
    8000383c:	f84a                	sd	s2,48(sp)
    8000383e:	f44e                	sd	s3,40(sp)
    80003840:	f052                	sd	s4,32(sp)
    80003842:	ec56                	sd	s5,24(sp)
    80003844:	e85a                	sd	s6,16(sp)
    80003846:	e45e                	sd	s7,8(sp)
    80003848:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000384a:	0001d717          	auipc	a4,0x1d
    8000384e:	e1a72703          	lw	a4,-486(a4) # 80020664 <sb+0xc>
    80003852:	4785                	li	a5,1
    80003854:	04e7fa63          	bgeu	a5,a4,800038a8 <ialloc+0x74>
    80003858:	8aaa                	mv	s5,a0
    8000385a:	8bae                	mv	s7,a1
    8000385c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000385e:	0001da17          	auipc	s4,0x1d
    80003862:	dfaa0a13          	addi	s4,s4,-518 # 80020658 <sb>
    80003866:	00048b1b          	sext.w	s6,s1
    8000386a:	0044d793          	srli	a5,s1,0x4
    8000386e:	018a2583          	lw	a1,24(s4)
    80003872:	9dbd                	addw	a1,a1,a5
    80003874:	8556                	mv	a0,s5
    80003876:	00000097          	auipc	ra,0x0
    8000387a:	940080e7          	jalr	-1728(ra) # 800031b6 <bread>
    8000387e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003880:	05850993          	addi	s3,a0,88
    80003884:	00f4f793          	andi	a5,s1,15
    80003888:	079a                	slli	a5,a5,0x6
    8000388a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000388c:	00099783          	lh	a5,0(s3)
    80003890:	c3a1                	beqz	a5,800038d0 <ialloc+0x9c>
    brelse(bp);
    80003892:	00000097          	auipc	ra,0x0
    80003896:	a54080e7          	jalr	-1452(ra) # 800032e6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000389a:	0485                	addi	s1,s1,1
    8000389c:	00ca2703          	lw	a4,12(s4)
    800038a0:	0004879b          	sext.w	a5,s1
    800038a4:	fce7e1e3          	bltu	a5,a4,80003866 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800038a8:	00005517          	auipc	a0,0x5
    800038ac:	d1050513          	addi	a0,a0,-752 # 800085b8 <syscalls+0x168>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	cd8080e7          	jalr	-808(ra) # 80000588 <printf>
  return 0;
    800038b8:	4501                	li	a0,0
}
    800038ba:	60a6                	ld	ra,72(sp)
    800038bc:	6406                	ld	s0,64(sp)
    800038be:	74e2                	ld	s1,56(sp)
    800038c0:	7942                	ld	s2,48(sp)
    800038c2:	79a2                	ld	s3,40(sp)
    800038c4:	7a02                	ld	s4,32(sp)
    800038c6:	6ae2                	ld	s5,24(sp)
    800038c8:	6b42                	ld	s6,16(sp)
    800038ca:	6ba2                	ld	s7,8(sp)
    800038cc:	6161                	addi	sp,sp,80
    800038ce:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038d0:	04000613          	li	a2,64
    800038d4:	4581                	li	a1,0
    800038d6:	854e                	mv	a0,s3
    800038d8:	ffffd097          	auipc	ra,0xffffd
    800038dc:	3fa080e7          	jalr	1018(ra) # 80000cd2 <memset>
      dip->type = type;
    800038e0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038e4:	854a                	mv	a0,s2
    800038e6:	00001097          	auipc	ra,0x1
    800038ea:	c84080e7          	jalr	-892(ra) # 8000456a <log_write>
      brelse(bp);
    800038ee:	854a                	mv	a0,s2
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	9f6080e7          	jalr	-1546(ra) # 800032e6 <brelse>
      return iget(dev, inum);
    800038f8:	85da                	mv	a1,s6
    800038fa:	8556                	mv	a0,s5
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	d9c080e7          	jalr	-612(ra) # 80003698 <iget>
    80003904:	bf5d                	j	800038ba <ialloc+0x86>

0000000080003906 <iupdate>:
{
    80003906:	1101                	addi	sp,sp,-32
    80003908:	ec06                	sd	ra,24(sp)
    8000390a:	e822                	sd	s0,16(sp)
    8000390c:	e426                	sd	s1,8(sp)
    8000390e:	e04a                	sd	s2,0(sp)
    80003910:	1000                	addi	s0,sp,32
    80003912:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003914:	415c                	lw	a5,4(a0)
    80003916:	0047d79b          	srliw	a5,a5,0x4
    8000391a:	0001d597          	auipc	a1,0x1d
    8000391e:	d565a583          	lw	a1,-682(a1) # 80020670 <sb+0x18>
    80003922:	9dbd                	addw	a1,a1,a5
    80003924:	4108                	lw	a0,0(a0)
    80003926:	00000097          	auipc	ra,0x0
    8000392a:	890080e7          	jalr	-1904(ra) # 800031b6 <bread>
    8000392e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003930:	05850793          	addi	a5,a0,88
    80003934:	40c8                	lw	a0,4(s1)
    80003936:	893d                	andi	a0,a0,15
    80003938:	051a                	slli	a0,a0,0x6
    8000393a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000393c:	04449703          	lh	a4,68(s1)
    80003940:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003944:	04649703          	lh	a4,70(s1)
    80003948:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000394c:	04849703          	lh	a4,72(s1)
    80003950:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003954:	04a49703          	lh	a4,74(s1)
    80003958:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000395c:	44f8                	lw	a4,76(s1)
    8000395e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003960:	03400613          	li	a2,52
    80003964:	05048593          	addi	a1,s1,80
    80003968:	0531                	addi	a0,a0,12
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	3c4080e7          	jalr	964(ra) # 80000d2e <memmove>
  log_write(bp);
    80003972:	854a                	mv	a0,s2
    80003974:	00001097          	auipc	ra,0x1
    80003978:	bf6080e7          	jalr	-1034(ra) # 8000456a <log_write>
  brelse(bp);
    8000397c:	854a                	mv	a0,s2
    8000397e:	00000097          	auipc	ra,0x0
    80003982:	968080e7          	jalr	-1688(ra) # 800032e6 <brelse>
}
    80003986:	60e2                	ld	ra,24(sp)
    80003988:	6442                	ld	s0,16(sp)
    8000398a:	64a2                	ld	s1,8(sp)
    8000398c:	6902                	ld	s2,0(sp)
    8000398e:	6105                	addi	sp,sp,32
    80003990:	8082                	ret

0000000080003992 <idup>:
{
    80003992:	1101                	addi	sp,sp,-32
    80003994:	ec06                	sd	ra,24(sp)
    80003996:	e822                	sd	s0,16(sp)
    80003998:	e426                	sd	s1,8(sp)
    8000399a:	1000                	addi	s0,sp,32
    8000399c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000399e:	0001d517          	auipc	a0,0x1d
    800039a2:	cda50513          	addi	a0,a0,-806 # 80020678 <itable>
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	230080e7          	jalr	560(ra) # 80000bd6 <acquire>
  ip->ref++;
    800039ae:	449c                	lw	a5,8(s1)
    800039b0:	2785                	addiw	a5,a5,1
    800039b2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039b4:	0001d517          	auipc	a0,0x1d
    800039b8:	cc450513          	addi	a0,a0,-828 # 80020678 <itable>
    800039bc:	ffffd097          	auipc	ra,0xffffd
    800039c0:	2ce080e7          	jalr	718(ra) # 80000c8a <release>
}
    800039c4:	8526                	mv	a0,s1
    800039c6:	60e2                	ld	ra,24(sp)
    800039c8:	6442                	ld	s0,16(sp)
    800039ca:	64a2                	ld	s1,8(sp)
    800039cc:	6105                	addi	sp,sp,32
    800039ce:	8082                	ret

00000000800039d0 <ilock>:
{
    800039d0:	1101                	addi	sp,sp,-32
    800039d2:	ec06                	sd	ra,24(sp)
    800039d4:	e822                	sd	s0,16(sp)
    800039d6:	e426                	sd	s1,8(sp)
    800039d8:	e04a                	sd	s2,0(sp)
    800039da:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039dc:	c115                	beqz	a0,80003a00 <ilock+0x30>
    800039de:	84aa                	mv	s1,a0
    800039e0:	451c                	lw	a5,8(a0)
    800039e2:	00f05f63          	blez	a5,80003a00 <ilock+0x30>
  acquiresleep(&ip->lock);
    800039e6:	0541                	addi	a0,a0,16
    800039e8:	00001097          	auipc	ra,0x1
    800039ec:	ca2080e7          	jalr	-862(ra) # 8000468a <acquiresleep>
  if(ip->valid == 0){
    800039f0:	40bc                	lw	a5,64(s1)
    800039f2:	cf99                	beqz	a5,80003a10 <ilock+0x40>
}
    800039f4:	60e2                	ld	ra,24(sp)
    800039f6:	6442                	ld	s0,16(sp)
    800039f8:	64a2                	ld	s1,8(sp)
    800039fa:	6902                	ld	s2,0(sp)
    800039fc:	6105                	addi	sp,sp,32
    800039fe:	8082                	ret
    panic("ilock");
    80003a00:	00005517          	auipc	a0,0x5
    80003a04:	bd050513          	addi	a0,a0,-1072 # 800085d0 <syscalls+0x180>
    80003a08:	ffffd097          	auipc	ra,0xffffd
    80003a0c:	b36080e7          	jalr	-1226(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a10:	40dc                	lw	a5,4(s1)
    80003a12:	0047d79b          	srliw	a5,a5,0x4
    80003a16:	0001d597          	auipc	a1,0x1d
    80003a1a:	c5a5a583          	lw	a1,-934(a1) # 80020670 <sb+0x18>
    80003a1e:	9dbd                	addw	a1,a1,a5
    80003a20:	4088                	lw	a0,0(s1)
    80003a22:	fffff097          	auipc	ra,0xfffff
    80003a26:	794080e7          	jalr	1940(ra) # 800031b6 <bread>
    80003a2a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a2c:	05850593          	addi	a1,a0,88
    80003a30:	40dc                	lw	a5,4(s1)
    80003a32:	8bbd                	andi	a5,a5,15
    80003a34:	079a                	slli	a5,a5,0x6
    80003a36:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a38:	00059783          	lh	a5,0(a1)
    80003a3c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a40:	00259783          	lh	a5,2(a1)
    80003a44:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a48:	00459783          	lh	a5,4(a1)
    80003a4c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a50:	00659783          	lh	a5,6(a1)
    80003a54:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a58:	459c                	lw	a5,8(a1)
    80003a5a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a5c:	03400613          	li	a2,52
    80003a60:	05b1                	addi	a1,a1,12
    80003a62:	05048513          	addi	a0,s1,80
    80003a66:	ffffd097          	auipc	ra,0xffffd
    80003a6a:	2c8080e7          	jalr	712(ra) # 80000d2e <memmove>
    brelse(bp);
    80003a6e:	854a                	mv	a0,s2
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	876080e7          	jalr	-1930(ra) # 800032e6 <brelse>
    ip->valid = 1;
    80003a78:	4785                	li	a5,1
    80003a7a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a7c:	04449783          	lh	a5,68(s1)
    80003a80:	fbb5                	bnez	a5,800039f4 <ilock+0x24>
      panic("ilock: no type");
    80003a82:	00005517          	auipc	a0,0x5
    80003a86:	b5650513          	addi	a0,a0,-1194 # 800085d8 <syscalls+0x188>
    80003a8a:	ffffd097          	auipc	ra,0xffffd
    80003a8e:	ab4080e7          	jalr	-1356(ra) # 8000053e <panic>

0000000080003a92 <iunlock>:
{
    80003a92:	1101                	addi	sp,sp,-32
    80003a94:	ec06                	sd	ra,24(sp)
    80003a96:	e822                	sd	s0,16(sp)
    80003a98:	e426                	sd	s1,8(sp)
    80003a9a:	e04a                	sd	s2,0(sp)
    80003a9c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a9e:	c905                	beqz	a0,80003ace <iunlock+0x3c>
    80003aa0:	84aa                	mv	s1,a0
    80003aa2:	01050913          	addi	s2,a0,16
    80003aa6:	854a                	mv	a0,s2
    80003aa8:	00001097          	auipc	ra,0x1
    80003aac:	c7c080e7          	jalr	-900(ra) # 80004724 <holdingsleep>
    80003ab0:	cd19                	beqz	a0,80003ace <iunlock+0x3c>
    80003ab2:	449c                	lw	a5,8(s1)
    80003ab4:	00f05d63          	blez	a5,80003ace <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ab8:	854a                	mv	a0,s2
    80003aba:	00001097          	auipc	ra,0x1
    80003abe:	c26080e7          	jalr	-986(ra) # 800046e0 <releasesleep>
}
    80003ac2:	60e2                	ld	ra,24(sp)
    80003ac4:	6442                	ld	s0,16(sp)
    80003ac6:	64a2                	ld	s1,8(sp)
    80003ac8:	6902                	ld	s2,0(sp)
    80003aca:	6105                	addi	sp,sp,32
    80003acc:	8082                	ret
    panic("iunlock");
    80003ace:	00005517          	auipc	a0,0x5
    80003ad2:	b1a50513          	addi	a0,a0,-1254 # 800085e8 <syscalls+0x198>
    80003ad6:	ffffd097          	auipc	ra,0xffffd
    80003ada:	a68080e7          	jalr	-1432(ra) # 8000053e <panic>

0000000080003ade <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ade:	7179                	addi	sp,sp,-48
    80003ae0:	f406                	sd	ra,40(sp)
    80003ae2:	f022                	sd	s0,32(sp)
    80003ae4:	ec26                	sd	s1,24(sp)
    80003ae6:	e84a                	sd	s2,16(sp)
    80003ae8:	e44e                	sd	s3,8(sp)
    80003aea:	e052                	sd	s4,0(sp)
    80003aec:	1800                	addi	s0,sp,48
    80003aee:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003af0:	05050493          	addi	s1,a0,80
    80003af4:	08050913          	addi	s2,a0,128
    80003af8:	a021                	j	80003b00 <itrunc+0x22>
    80003afa:	0491                	addi	s1,s1,4
    80003afc:	01248d63          	beq	s1,s2,80003b16 <itrunc+0x38>
    if(ip->addrs[i]){
    80003b00:	408c                	lw	a1,0(s1)
    80003b02:	dde5                	beqz	a1,80003afa <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b04:	0009a503          	lw	a0,0(s3)
    80003b08:	00000097          	auipc	ra,0x0
    80003b0c:	8f4080e7          	jalr	-1804(ra) # 800033fc <bfree>
      ip->addrs[i] = 0;
    80003b10:	0004a023          	sw	zero,0(s1)
    80003b14:	b7dd                	j	80003afa <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b16:	0809a583          	lw	a1,128(s3)
    80003b1a:	e185                	bnez	a1,80003b3a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b1c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b20:	854e                	mv	a0,s3
    80003b22:	00000097          	auipc	ra,0x0
    80003b26:	de4080e7          	jalr	-540(ra) # 80003906 <iupdate>
}
    80003b2a:	70a2                	ld	ra,40(sp)
    80003b2c:	7402                	ld	s0,32(sp)
    80003b2e:	64e2                	ld	s1,24(sp)
    80003b30:	6942                	ld	s2,16(sp)
    80003b32:	69a2                	ld	s3,8(sp)
    80003b34:	6a02                	ld	s4,0(sp)
    80003b36:	6145                	addi	sp,sp,48
    80003b38:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b3a:	0009a503          	lw	a0,0(s3)
    80003b3e:	fffff097          	auipc	ra,0xfffff
    80003b42:	678080e7          	jalr	1656(ra) # 800031b6 <bread>
    80003b46:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b48:	05850493          	addi	s1,a0,88
    80003b4c:	45850913          	addi	s2,a0,1112
    80003b50:	a021                	j	80003b58 <itrunc+0x7a>
    80003b52:	0491                	addi	s1,s1,4
    80003b54:	01248b63          	beq	s1,s2,80003b6a <itrunc+0x8c>
      if(a[j])
    80003b58:	408c                	lw	a1,0(s1)
    80003b5a:	dde5                	beqz	a1,80003b52 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b5c:	0009a503          	lw	a0,0(s3)
    80003b60:	00000097          	auipc	ra,0x0
    80003b64:	89c080e7          	jalr	-1892(ra) # 800033fc <bfree>
    80003b68:	b7ed                	j	80003b52 <itrunc+0x74>
    brelse(bp);
    80003b6a:	8552                	mv	a0,s4
    80003b6c:	fffff097          	auipc	ra,0xfffff
    80003b70:	77a080e7          	jalr	1914(ra) # 800032e6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b74:	0809a583          	lw	a1,128(s3)
    80003b78:	0009a503          	lw	a0,0(s3)
    80003b7c:	00000097          	auipc	ra,0x0
    80003b80:	880080e7          	jalr	-1920(ra) # 800033fc <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b84:	0809a023          	sw	zero,128(s3)
    80003b88:	bf51                	j	80003b1c <itrunc+0x3e>

0000000080003b8a <iput>:
{
    80003b8a:	1101                	addi	sp,sp,-32
    80003b8c:	ec06                	sd	ra,24(sp)
    80003b8e:	e822                	sd	s0,16(sp)
    80003b90:	e426                	sd	s1,8(sp)
    80003b92:	e04a                	sd	s2,0(sp)
    80003b94:	1000                	addi	s0,sp,32
    80003b96:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b98:	0001d517          	auipc	a0,0x1d
    80003b9c:	ae050513          	addi	a0,a0,-1312 # 80020678 <itable>
    80003ba0:	ffffd097          	auipc	ra,0xffffd
    80003ba4:	036080e7          	jalr	54(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ba8:	4498                	lw	a4,8(s1)
    80003baa:	4785                	li	a5,1
    80003bac:	02f70363          	beq	a4,a5,80003bd2 <iput+0x48>
  ip->ref--;
    80003bb0:	449c                	lw	a5,8(s1)
    80003bb2:	37fd                	addiw	a5,a5,-1
    80003bb4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bb6:	0001d517          	auipc	a0,0x1d
    80003bba:	ac250513          	addi	a0,a0,-1342 # 80020678 <itable>
    80003bbe:	ffffd097          	auipc	ra,0xffffd
    80003bc2:	0cc080e7          	jalr	204(ra) # 80000c8a <release>
}
    80003bc6:	60e2                	ld	ra,24(sp)
    80003bc8:	6442                	ld	s0,16(sp)
    80003bca:	64a2                	ld	s1,8(sp)
    80003bcc:	6902                	ld	s2,0(sp)
    80003bce:	6105                	addi	sp,sp,32
    80003bd0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bd2:	40bc                	lw	a5,64(s1)
    80003bd4:	dff1                	beqz	a5,80003bb0 <iput+0x26>
    80003bd6:	04a49783          	lh	a5,74(s1)
    80003bda:	fbf9                	bnez	a5,80003bb0 <iput+0x26>
    acquiresleep(&ip->lock);
    80003bdc:	01048913          	addi	s2,s1,16
    80003be0:	854a                	mv	a0,s2
    80003be2:	00001097          	auipc	ra,0x1
    80003be6:	aa8080e7          	jalr	-1368(ra) # 8000468a <acquiresleep>
    release(&itable.lock);
    80003bea:	0001d517          	auipc	a0,0x1d
    80003bee:	a8e50513          	addi	a0,a0,-1394 # 80020678 <itable>
    80003bf2:	ffffd097          	auipc	ra,0xffffd
    80003bf6:	098080e7          	jalr	152(ra) # 80000c8a <release>
    itrunc(ip);
    80003bfa:	8526                	mv	a0,s1
    80003bfc:	00000097          	auipc	ra,0x0
    80003c00:	ee2080e7          	jalr	-286(ra) # 80003ade <itrunc>
    ip->type = 0;
    80003c04:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c08:	8526                	mv	a0,s1
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	cfc080e7          	jalr	-772(ra) # 80003906 <iupdate>
    ip->valid = 0;
    80003c12:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c16:	854a                	mv	a0,s2
    80003c18:	00001097          	auipc	ra,0x1
    80003c1c:	ac8080e7          	jalr	-1336(ra) # 800046e0 <releasesleep>
    acquire(&itable.lock);
    80003c20:	0001d517          	auipc	a0,0x1d
    80003c24:	a5850513          	addi	a0,a0,-1448 # 80020678 <itable>
    80003c28:	ffffd097          	auipc	ra,0xffffd
    80003c2c:	fae080e7          	jalr	-82(ra) # 80000bd6 <acquire>
    80003c30:	b741                	j	80003bb0 <iput+0x26>

0000000080003c32 <iunlockput>:
{
    80003c32:	1101                	addi	sp,sp,-32
    80003c34:	ec06                	sd	ra,24(sp)
    80003c36:	e822                	sd	s0,16(sp)
    80003c38:	e426                	sd	s1,8(sp)
    80003c3a:	1000                	addi	s0,sp,32
    80003c3c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c3e:	00000097          	auipc	ra,0x0
    80003c42:	e54080e7          	jalr	-428(ra) # 80003a92 <iunlock>
  iput(ip);
    80003c46:	8526                	mv	a0,s1
    80003c48:	00000097          	auipc	ra,0x0
    80003c4c:	f42080e7          	jalr	-190(ra) # 80003b8a <iput>
}
    80003c50:	60e2                	ld	ra,24(sp)
    80003c52:	6442                	ld	s0,16(sp)
    80003c54:	64a2                	ld	s1,8(sp)
    80003c56:	6105                	addi	sp,sp,32
    80003c58:	8082                	ret

0000000080003c5a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c5a:	1141                	addi	sp,sp,-16
    80003c5c:	e422                	sd	s0,8(sp)
    80003c5e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c60:	411c                	lw	a5,0(a0)
    80003c62:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c64:	415c                	lw	a5,4(a0)
    80003c66:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c68:	04451783          	lh	a5,68(a0)
    80003c6c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c70:	04a51783          	lh	a5,74(a0)
    80003c74:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c78:	04c56783          	lwu	a5,76(a0)
    80003c7c:	e99c                	sd	a5,16(a1)
}
    80003c7e:	6422                	ld	s0,8(sp)
    80003c80:	0141                	addi	sp,sp,16
    80003c82:	8082                	ret

0000000080003c84 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c84:	457c                	lw	a5,76(a0)
    80003c86:	0ed7e963          	bltu	a5,a3,80003d78 <readi+0xf4>
{
    80003c8a:	7159                	addi	sp,sp,-112
    80003c8c:	f486                	sd	ra,104(sp)
    80003c8e:	f0a2                	sd	s0,96(sp)
    80003c90:	eca6                	sd	s1,88(sp)
    80003c92:	e8ca                	sd	s2,80(sp)
    80003c94:	e4ce                	sd	s3,72(sp)
    80003c96:	e0d2                	sd	s4,64(sp)
    80003c98:	fc56                	sd	s5,56(sp)
    80003c9a:	f85a                	sd	s6,48(sp)
    80003c9c:	f45e                	sd	s7,40(sp)
    80003c9e:	f062                	sd	s8,32(sp)
    80003ca0:	ec66                	sd	s9,24(sp)
    80003ca2:	e86a                	sd	s10,16(sp)
    80003ca4:	e46e                	sd	s11,8(sp)
    80003ca6:	1880                	addi	s0,sp,112
    80003ca8:	8b2a                	mv	s6,a0
    80003caa:	8bae                	mv	s7,a1
    80003cac:	8a32                	mv	s4,a2
    80003cae:	84b6                	mv	s1,a3
    80003cb0:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003cb2:	9f35                	addw	a4,a4,a3
    return 0;
    80003cb4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cb6:	0ad76063          	bltu	a4,a3,80003d56 <readi+0xd2>
  if(off + n > ip->size)
    80003cba:	00e7f463          	bgeu	a5,a4,80003cc2 <readi+0x3e>
    n = ip->size - off;
    80003cbe:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cc2:	0a0a8963          	beqz	s5,80003d74 <readi+0xf0>
    80003cc6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cc8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ccc:	5c7d                	li	s8,-1
    80003cce:	a82d                	j	80003d08 <readi+0x84>
    80003cd0:	020d1d93          	slli	s11,s10,0x20
    80003cd4:	020ddd93          	srli	s11,s11,0x20
    80003cd8:	05890793          	addi	a5,s2,88
    80003cdc:	86ee                	mv	a3,s11
    80003cde:	963e                	add	a2,a2,a5
    80003ce0:	85d2                	mv	a1,s4
    80003ce2:	855e                	mv	a0,s7
    80003ce4:	fffff097          	auipc	ra,0xfffff
    80003ce8:	8ce080e7          	jalr	-1842(ra) # 800025b2 <either_copyout>
    80003cec:	05850d63          	beq	a0,s8,80003d46 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cf0:	854a                	mv	a0,s2
    80003cf2:	fffff097          	auipc	ra,0xfffff
    80003cf6:	5f4080e7          	jalr	1524(ra) # 800032e6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cfa:	013d09bb          	addw	s3,s10,s3
    80003cfe:	009d04bb          	addw	s1,s10,s1
    80003d02:	9a6e                	add	s4,s4,s11
    80003d04:	0559f763          	bgeu	s3,s5,80003d52 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003d08:	00a4d59b          	srliw	a1,s1,0xa
    80003d0c:	855a                	mv	a0,s6
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	8a2080e7          	jalr	-1886(ra) # 800035b0 <bmap>
    80003d16:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d1a:	cd85                	beqz	a1,80003d52 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d1c:	000b2503          	lw	a0,0(s6)
    80003d20:	fffff097          	auipc	ra,0xfffff
    80003d24:	496080e7          	jalr	1174(ra) # 800031b6 <bread>
    80003d28:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d2a:	3ff4f613          	andi	a2,s1,1023
    80003d2e:	40cc87bb          	subw	a5,s9,a2
    80003d32:	413a873b          	subw	a4,s5,s3
    80003d36:	8d3e                	mv	s10,a5
    80003d38:	2781                	sext.w	a5,a5
    80003d3a:	0007069b          	sext.w	a3,a4
    80003d3e:	f8f6f9e3          	bgeu	a3,a5,80003cd0 <readi+0x4c>
    80003d42:	8d3a                	mv	s10,a4
    80003d44:	b771                	j	80003cd0 <readi+0x4c>
      brelse(bp);
    80003d46:	854a                	mv	a0,s2
    80003d48:	fffff097          	auipc	ra,0xfffff
    80003d4c:	59e080e7          	jalr	1438(ra) # 800032e6 <brelse>
      tot = -1;
    80003d50:	59fd                	li	s3,-1
  }
  return tot;
    80003d52:	0009851b          	sext.w	a0,s3
}
    80003d56:	70a6                	ld	ra,104(sp)
    80003d58:	7406                	ld	s0,96(sp)
    80003d5a:	64e6                	ld	s1,88(sp)
    80003d5c:	6946                	ld	s2,80(sp)
    80003d5e:	69a6                	ld	s3,72(sp)
    80003d60:	6a06                	ld	s4,64(sp)
    80003d62:	7ae2                	ld	s5,56(sp)
    80003d64:	7b42                	ld	s6,48(sp)
    80003d66:	7ba2                	ld	s7,40(sp)
    80003d68:	7c02                	ld	s8,32(sp)
    80003d6a:	6ce2                	ld	s9,24(sp)
    80003d6c:	6d42                	ld	s10,16(sp)
    80003d6e:	6da2                	ld	s11,8(sp)
    80003d70:	6165                	addi	sp,sp,112
    80003d72:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d74:	89d6                	mv	s3,s5
    80003d76:	bff1                	j	80003d52 <readi+0xce>
    return 0;
    80003d78:	4501                	li	a0,0
}
    80003d7a:	8082                	ret

0000000080003d7c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d7c:	457c                	lw	a5,76(a0)
    80003d7e:	10d7e863          	bltu	a5,a3,80003e8e <writei+0x112>
{
    80003d82:	7159                	addi	sp,sp,-112
    80003d84:	f486                	sd	ra,104(sp)
    80003d86:	f0a2                	sd	s0,96(sp)
    80003d88:	eca6                	sd	s1,88(sp)
    80003d8a:	e8ca                	sd	s2,80(sp)
    80003d8c:	e4ce                	sd	s3,72(sp)
    80003d8e:	e0d2                	sd	s4,64(sp)
    80003d90:	fc56                	sd	s5,56(sp)
    80003d92:	f85a                	sd	s6,48(sp)
    80003d94:	f45e                	sd	s7,40(sp)
    80003d96:	f062                	sd	s8,32(sp)
    80003d98:	ec66                	sd	s9,24(sp)
    80003d9a:	e86a                	sd	s10,16(sp)
    80003d9c:	e46e                	sd	s11,8(sp)
    80003d9e:	1880                	addi	s0,sp,112
    80003da0:	8aaa                	mv	s5,a0
    80003da2:	8bae                	mv	s7,a1
    80003da4:	8a32                	mv	s4,a2
    80003da6:	8936                	mv	s2,a3
    80003da8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003daa:	00e687bb          	addw	a5,a3,a4
    80003dae:	0ed7e263          	bltu	a5,a3,80003e92 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003db2:	00043737          	lui	a4,0x43
    80003db6:	0ef76063          	bltu	a4,a5,80003e96 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dba:	0c0b0863          	beqz	s6,80003e8a <writei+0x10e>
    80003dbe:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dc0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dc4:	5c7d                	li	s8,-1
    80003dc6:	a091                	j	80003e0a <writei+0x8e>
    80003dc8:	020d1d93          	slli	s11,s10,0x20
    80003dcc:	020ddd93          	srli	s11,s11,0x20
    80003dd0:	05848793          	addi	a5,s1,88
    80003dd4:	86ee                	mv	a3,s11
    80003dd6:	8652                	mv	a2,s4
    80003dd8:	85de                	mv	a1,s7
    80003dda:	953e                	add	a0,a0,a5
    80003ddc:	fffff097          	auipc	ra,0xfffff
    80003de0:	82e080e7          	jalr	-2002(ra) # 8000260a <either_copyin>
    80003de4:	07850263          	beq	a0,s8,80003e48 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003de8:	8526                	mv	a0,s1
    80003dea:	00000097          	auipc	ra,0x0
    80003dee:	780080e7          	jalr	1920(ra) # 8000456a <log_write>
    brelse(bp);
    80003df2:	8526                	mv	a0,s1
    80003df4:	fffff097          	auipc	ra,0xfffff
    80003df8:	4f2080e7          	jalr	1266(ra) # 800032e6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dfc:	013d09bb          	addw	s3,s10,s3
    80003e00:	012d093b          	addw	s2,s10,s2
    80003e04:	9a6e                	add	s4,s4,s11
    80003e06:	0569f663          	bgeu	s3,s6,80003e52 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003e0a:	00a9559b          	srliw	a1,s2,0xa
    80003e0e:	8556                	mv	a0,s5
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	7a0080e7          	jalr	1952(ra) # 800035b0 <bmap>
    80003e18:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e1c:	c99d                	beqz	a1,80003e52 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e1e:	000aa503          	lw	a0,0(s5)
    80003e22:	fffff097          	auipc	ra,0xfffff
    80003e26:	394080e7          	jalr	916(ra) # 800031b6 <bread>
    80003e2a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e2c:	3ff97513          	andi	a0,s2,1023
    80003e30:	40ac87bb          	subw	a5,s9,a0
    80003e34:	413b073b          	subw	a4,s6,s3
    80003e38:	8d3e                	mv	s10,a5
    80003e3a:	2781                	sext.w	a5,a5
    80003e3c:	0007069b          	sext.w	a3,a4
    80003e40:	f8f6f4e3          	bgeu	a3,a5,80003dc8 <writei+0x4c>
    80003e44:	8d3a                	mv	s10,a4
    80003e46:	b749                	j	80003dc8 <writei+0x4c>
      brelse(bp);
    80003e48:	8526                	mv	a0,s1
    80003e4a:	fffff097          	auipc	ra,0xfffff
    80003e4e:	49c080e7          	jalr	1180(ra) # 800032e6 <brelse>
  }

  if(off > ip->size)
    80003e52:	04caa783          	lw	a5,76(s5)
    80003e56:	0127f463          	bgeu	a5,s2,80003e5e <writei+0xe2>
    ip->size = off;
    80003e5a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e5e:	8556                	mv	a0,s5
    80003e60:	00000097          	auipc	ra,0x0
    80003e64:	aa6080e7          	jalr	-1370(ra) # 80003906 <iupdate>

  return tot;
    80003e68:	0009851b          	sext.w	a0,s3
}
    80003e6c:	70a6                	ld	ra,104(sp)
    80003e6e:	7406                	ld	s0,96(sp)
    80003e70:	64e6                	ld	s1,88(sp)
    80003e72:	6946                	ld	s2,80(sp)
    80003e74:	69a6                	ld	s3,72(sp)
    80003e76:	6a06                	ld	s4,64(sp)
    80003e78:	7ae2                	ld	s5,56(sp)
    80003e7a:	7b42                	ld	s6,48(sp)
    80003e7c:	7ba2                	ld	s7,40(sp)
    80003e7e:	7c02                	ld	s8,32(sp)
    80003e80:	6ce2                	ld	s9,24(sp)
    80003e82:	6d42                	ld	s10,16(sp)
    80003e84:	6da2                	ld	s11,8(sp)
    80003e86:	6165                	addi	sp,sp,112
    80003e88:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e8a:	89da                	mv	s3,s6
    80003e8c:	bfc9                	j	80003e5e <writei+0xe2>
    return -1;
    80003e8e:	557d                	li	a0,-1
}
    80003e90:	8082                	ret
    return -1;
    80003e92:	557d                	li	a0,-1
    80003e94:	bfe1                	j	80003e6c <writei+0xf0>
    return -1;
    80003e96:	557d                	li	a0,-1
    80003e98:	bfd1                	j	80003e6c <writei+0xf0>

0000000080003e9a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e9a:	1141                	addi	sp,sp,-16
    80003e9c:	e406                	sd	ra,8(sp)
    80003e9e:	e022                	sd	s0,0(sp)
    80003ea0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ea2:	4639                	li	a2,14
    80003ea4:	ffffd097          	auipc	ra,0xffffd
    80003ea8:	efe080e7          	jalr	-258(ra) # 80000da2 <strncmp>
}
    80003eac:	60a2                	ld	ra,8(sp)
    80003eae:	6402                	ld	s0,0(sp)
    80003eb0:	0141                	addi	sp,sp,16
    80003eb2:	8082                	ret

0000000080003eb4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003eb4:	7139                	addi	sp,sp,-64
    80003eb6:	fc06                	sd	ra,56(sp)
    80003eb8:	f822                	sd	s0,48(sp)
    80003eba:	f426                	sd	s1,40(sp)
    80003ebc:	f04a                	sd	s2,32(sp)
    80003ebe:	ec4e                	sd	s3,24(sp)
    80003ec0:	e852                	sd	s4,16(sp)
    80003ec2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ec4:	04451703          	lh	a4,68(a0)
    80003ec8:	4785                	li	a5,1
    80003eca:	00f71a63          	bne	a4,a5,80003ede <dirlookup+0x2a>
    80003ece:	892a                	mv	s2,a0
    80003ed0:	89ae                	mv	s3,a1
    80003ed2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ed4:	457c                	lw	a5,76(a0)
    80003ed6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ed8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eda:	e79d                	bnez	a5,80003f08 <dirlookup+0x54>
    80003edc:	a8a5                	j	80003f54 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ede:	00004517          	auipc	a0,0x4
    80003ee2:	71250513          	addi	a0,a0,1810 # 800085f0 <syscalls+0x1a0>
    80003ee6:	ffffc097          	auipc	ra,0xffffc
    80003eea:	658080e7          	jalr	1624(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003eee:	00004517          	auipc	a0,0x4
    80003ef2:	71a50513          	addi	a0,a0,1818 # 80008608 <syscalls+0x1b8>
    80003ef6:	ffffc097          	auipc	ra,0xffffc
    80003efa:	648080e7          	jalr	1608(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003efe:	24c1                	addiw	s1,s1,16
    80003f00:	04c92783          	lw	a5,76(s2)
    80003f04:	04f4f763          	bgeu	s1,a5,80003f52 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f08:	4741                	li	a4,16
    80003f0a:	86a6                	mv	a3,s1
    80003f0c:	fc040613          	addi	a2,s0,-64
    80003f10:	4581                	li	a1,0
    80003f12:	854a                	mv	a0,s2
    80003f14:	00000097          	auipc	ra,0x0
    80003f18:	d70080e7          	jalr	-656(ra) # 80003c84 <readi>
    80003f1c:	47c1                	li	a5,16
    80003f1e:	fcf518e3          	bne	a0,a5,80003eee <dirlookup+0x3a>
    if(de.inum == 0)
    80003f22:	fc045783          	lhu	a5,-64(s0)
    80003f26:	dfe1                	beqz	a5,80003efe <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f28:	fc240593          	addi	a1,s0,-62
    80003f2c:	854e                	mv	a0,s3
    80003f2e:	00000097          	auipc	ra,0x0
    80003f32:	f6c080e7          	jalr	-148(ra) # 80003e9a <namecmp>
    80003f36:	f561                	bnez	a0,80003efe <dirlookup+0x4a>
      if(poff)
    80003f38:	000a0463          	beqz	s4,80003f40 <dirlookup+0x8c>
        *poff = off;
    80003f3c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f40:	fc045583          	lhu	a1,-64(s0)
    80003f44:	00092503          	lw	a0,0(s2)
    80003f48:	fffff097          	auipc	ra,0xfffff
    80003f4c:	750080e7          	jalr	1872(ra) # 80003698 <iget>
    80003f50:	a011                	j	80003f54 <dirlookup+0xa0>
  return 0;
    80003f52:	4501                	li	a0,0
}
    80003f54:	70e2                	ld	ra,56(sp)
    80003f56:	7442                	ld	s0,48(sp)
    80003f58:	74a2                	ld	s1,40(sp)
    80003f5a:	7902                	ld	s2,32(sp)
    80003f5c:	69e2                	ld	s3,24(sp)
    80003f5e:	6a42                	ld	s4,16(sp)
    80003f60:	6121                	addi	sp,sp,64
    80003f62:	8082                	ret

0000000080003f64 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f64:	711d                	addi	sp,sp,-96
    80003f66:	ec86                	sd	ra,88(sp)
    80003f68:	e8a2                	sd	s0,80(sp)
    80003f6a:	e4a6                	sd	s1,72(sp)
    80003f6c:	e0ca                	sd	s2,64(sp)
    80003f6e:	fc4e                	sd	s3,56(sp)
    80003f70:	f852                	sd	s4,48(sp)
    80003f72:	f456                	sd	s5,40(sp)
    80003f74:	f05a                	sd	s6,32(sp)
    80003f76:	ec5e                	sd	s7,24(sp)
    80003f78:	e862                	sd	s8,16(sp)
    80003f7a:	e466                	sd	s9,8(sp)
    80003f7c:	1080                	addi	s0,sp,96
    80003f7e:	84aa                	mv	s1,a0
    80003f80:	8aae                	mv	s5,a1
    80003f82:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f84:	00054703          	lbu	a4,0(a0)
    80003f88:	02f00793          	li	a5,47
    80003f8c:	02f70363          	beq	a4,a5,80003fb2 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f90:	ffffe097          	auipc	ra,0xffffe
    80003f94:	9f0080e7          	jalr	-1552(ra) # 80001980 <myproc>
    80003f98:	18853503          	ld	a0,392(a0)
    80003f9c:	00000097          	auipc	ra,0x0
    80003fa0:	9f6080e7          	jalr	-1546(ra) # 80003992 <idup>
    80003fa4:	89aa                	mv	s3,a0
  while(*path == '/')
    80003fa6:	02f00913          	li	s2,47
  len = path - s;
    80003faa:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003fac:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fae:	4b85                	li	s7,1
    80003fb0:	a865                	j	80004068 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fb2:	4585                	li	a1,1
    80003fb4:	4505                	li	a0,1
    80003fb6:	fffff097          	auipc	ra,0xfffff
    80003fba:	6e2080e7          	jalr	1762(ra) # 80003698 <iget>
    80003fbe:	89aa                	mv	s3,a0
    80003fc0:	b7dd                	j	80003fa6 <namex+0x42>
      iunlockput(ip);
    80003fc2:	854e                	mv	a0,s3
    80003fc4:	00000097          	auipc	ra,0x0
    80003fc8:	c6e080e7          	jalr	-914(ra) # 80003c32 <iunlockput>
      return 0;
    80003fcc:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fce:	854e                	mv	a0,s3
    80003fd0:	60e6                	ld	ra,88(sp)
    80003fd2:	6446                	ld	s0,80(sp)
    80003fd4:	64a6                	ld	s1,72(sp)
    80003fd6:	6906                	ld	s2,64(sp)
    80003fd8:	79e2                	ld	s3,56(sp)
    80003fda:	7a42                	ld	s4,48(sp)
    80003fdc:	7aa2                	ld	s5,40(sp)
    80003fde:	7b02                	ld	s6,32(sp)
    80003fe0:	6be2                	ld	s7,24(sp)
    80003fe2:	6c42                	ld	s8,16(sp)
    80003fe4:	6ca2                	ld	s9,8(sp)
    80003fe6:	6125                	addi	sp,sp,96
    80003fe8:	8082                	ret
      iunlock(ip);
    80003fea:	854e                	mv	a0,s3
    80003fec:	00000097          	auipc	ra,0x0
    80003ff0:	aa6080e7          	jalr	-1370(ra) # 80003a92 <iunlock>
      return ip;
    80003ff4:	bfe9                	j	80003fce <namex+0x6a>
      iunlockput(ip);
    80003ff6:	854e                	mv	a0,s3
    80003ff8:	00000097          	auipc	ra,0x0
    80003ffc:	c3a080e7          	jalr	-966(ra) # 80003c32 <iunlockput>
      return 0;
    80004000:	89e6                	mv	s3,s9
    80004002:	b7f1                	j	80003fce <namex+0x6a>
  len = path - s;
    80004004:	40b48633          	sub	a2,s1,a1
    80004008:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000400c:	099c5463          	bge	s8,s9,80004094 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004010:	4639                	li	a2,14
    80004012:	8552                	mv	a0,s4
    80004014:	ffffd097          	auipc	ra,0xffffd
    80004018:	d1a080e7          	jalr	-742(ra) # 80000d2e <memmove>
  while(*path == '/')
    8000401c:	0004c783          	lbu	a5,0(s1)
    80004020:	01279763          	bne	a5,s2,8000402e <namex+0xca>
    path++;
    80004024:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004026:	0004c783          	lbu	a5,0(s1)
    8000402a:	ff278de3          	beq	a5,s2,80004024 <namex+0xc0>
    ilock(ip);
    8000402e:	854e                	mv	a0,s3
    80004030:	00000097          	auipc	ra,0x0
    80004034:	9a0080e7          	jalr	-1632(ra) # 800039d0 <ilock>
    if(ip->type != T_DIR){
    80004038:	04499783          	lh	a5,68(s3)
    8000403c:	f97793e3          	bne	a5,s7,80003fc2 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004040:	000a8563          	beqz	s5,8000404a <namex+0xe6>
    80004044:	0004c783          	lbu	a5,0(s1)
    80004048:	d3cd                	beqz	a5,80003fea <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000404a:	865a                	mv	a2,s6
    8000404c:	85d2                	mv	a1,s4
    8000404e:	854e                	mv	a0,s3
    80004050:	00000097          	auipc	ra,0x0
    80004054:	e64080e7          	jalr	-412(ra) # 80003eb4 <dirlookup>
    80004058:	8caa                	mv	s9,a0
    8000405a:	dd51                	beqz	a0,80003ff6 <namex+0x92>
    iunlockput(ip);
    8000405c:	854e                	mv	a0,s3
    8000405e:	00000097          	auipc	ra,0x0
    80004062:	bd4080e7          	jalr	-1068(ra) # 80003c32 <iunlockput>
    ip = next;
    80004066:	89e6                	mv	s3,s9
  while(*path == '/')
    80004068:	0004c783          	lbu	a5,0(s1)
    8000406c:	05279763          	bne	a5,s2,800040ba <namex+0x156>
    path++;
    80004070:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004072:	0004c783          	lbu	a5,0(s1)
    80004076:	ff278de3          	beq	a5,s2,80004070 <namex+0x10c>
  if(*path == 0)
    8000407a:	c79d                	beqz	a5,800040a8 <namex+0x144>
    path++;
    8000407c:	85a6                	mv	a1,s1
  len = path - s;
    8000407e:	8cda                	mv	s9,s6
    80004080:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004082:	01278963          	beq	a5,s2,80004094 <namex+0x130>
    80004086:	dfbd                	beqz	a5,80004004 <namex+0xa0>
    path++;
    80004088:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000408a:	0004c783          	lbu	a5,0(s1)
    8000408e:	ff279ce3          	bne	a5,s2,80004086 <namex+0x122>
    80004092:	bf8d                	j	80004004 <namex+0xa0>
    memmove(name, s, len);
    80004094:	2601                	sext.w	a2,a2
    80004096:	8552                	mv	a0,s4
    80004098:	ffffd097          	auipc	ra,0xffffd
    8000409c:	c96080e7          	jalr	-874(ra) # 80000d2e <memmove>
    name[len] = 0;
    800040a0:	9cd2                	add	s9,s9,s4
    800040a2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800040a6:	bf9d                	j	8000401c <namex+0xb8>
  if(nameiparent){
    800040a8:	f20a83e3          	beqz	s5,80003fce <namex+0x6a>
    iput(ip);
    800040ac:	854e                	mv	a0,s3
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	adc080e7          	jalr	-1316(ra) # 80003b8a <iput>
    return 0;
    800040b6:	4981                	li	s3,0
    800040b8:	bf19                	j	80003fce <namex+0x6a>
  if(*path == 0)
    800040ba:	d7fd                	beqz	a5,800040a8 <namex+0x144>
  while(*path != '/' && *path != 0)
    800040bc:	0004c783          	lbu	a5,0(s1)
    800040c0:	85a6                	mv	a1,s1
    800040c2:	b7d1                	j	80004086 <namex+0x122>

00000000800040c4 <dirlink>:
{
    800040c4:	7139                	addi	sp,sp,-64
    800040c6:	fc06                	sd	ra,56(sp)
    800040c8:	f822                	sd	s0,48(sp)
    800040ca:	f426                	sd	s1,40(sp)
    800040cc:	f04a                	sd	s2,32(sp)
    800040ce:	ec4e                	sd	s3,24(sp)
    800040d0:	e852                	sd	s4,16(sp)
    800040d2:	0080                	addi	s0,sp,64
    800040d4:	892a                	mv	s2,a0
    800040d6:	8a2e                	mv	s4,a1
    800040d8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040da:	4601                	li	a2,0
    800040dc:	00000097          	auipc	ra,0x0
    800040e0:	dd8080e7          	jalr	-552(ra) # 80003eb4 <dirlookup>
    800040e4:	e93d                	bnez	a0,8000415a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040e6:	04c92483          	lw	s1,76(s2)
    800040ea:	c49d                	beqz	s1,80004118 <dirlink+0x54>
    800040ec:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040ee:	4741                	li	a4,16
    800040f0:	86a6                	mv	a3,s1
    800040f2:	fc040613          	addi	a2,s0,-64
    800040f6:	4581                	li	a1,0
    800040f8:	854a                	mv	a0,s2
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	b8a080e7          	jalr	-1142(ra) # 80003c84 <readi>
    80004102:	47c1                	li	a5,16
    80004104:	06f51163          	bne	a0,a5,80004166 <dirlink+0xa2>
    if(de.inum == 0)
    80004108:	fc045783          	lhu	a5,-64(s0)
    8000410c:	c791                	beqz	a5,80004118 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000410e:	24c1                	addiw	s1,s1,16
    80004110:	04c92783          	lw	a5,76(s2)
    80004114:	fcf4ede3          	bltu	s1,a5,800040ee <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004118:	4639                	li	a2,14
    8000411a:	85d2                	mv	a1,s4
    8000411c:	fc240513          	addi	a0,s0,-62
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	cbe080e7          	jalr	-834(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004128:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000412c:	4741                	li	a4,16
    8000412e:	86a6                	mv	a3,s1
    80004130:	fc040613          	addi	a2,s0,-64
    80004134:	4581                	li	a1,0
    80004136:	854a                	mv	a0,s2
    80004138:	00000097          	auipc	ra,0x0
    8000413c:	c44080e7          	jalr	-956(ra) # 80003d7c <writei>
    80004140:	1541                	addi	a0,a0,-16
    80004142:	00a03533          	snez	a0,a0
    80004146:	40a00533          	neg	a0,a0
}
    8000414a:	70e2                	ld	ra,56(sp)
    8000414c:	7442                	ld	s0,48(sp)
    8000414e:	74a2                	ld	s1,40(sp)
    80004150:	7902                	ld	s2,32(sp)
    80004152:	69e2                	ld	s3,24(sp)
    80004154:	6a42                	ld	s4,16(sp)
    80004156:	6121                	addi	sp,sp,64
    80004158:	8082                	ret
    iput(ip);
    8000415a:	00000097          	auipc	ra,0x0
    8000415e:	a30080e7          	jalr	-1488(ra) # 80003b8a <iput>
    return -1;
    80004162:	557d                	li	a0,-1
    80004164:	b7dd                	j	8000414a <dirlink+0x86>
      panic("dirlink read");
    80004166:	00004517          	auipc	a0,0x4
    8000416a:	4b250513          	addi	a0,a0,1202 # 80008618 <syscalls+0x1c8>
    8000416e:	ffffc097          	auipc	ra,0xffffc
    80004172:	3d0080e7          	jalr	976(ra) # 8000053e <panic>

0000000080004176 <namei>:

struct inode*
namei(char *path)
{
    80004176:	1101                	addi	sp,sp,-32
    80004178:	ec06                	sd	ra,24(sp)
    8000417a:	e822                	sd	s0,16(sp)
    8000417c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000417e:	fe040613          	addi	a2,s0,-32
    80004182:	4581                	li	a1,0
    80004184:	00000097          	auipc	ra,0x0
    80004188:	de0080e7          	jalr	-544(ra) # 80003f64 <namex>
}
    8000418c:	60e2                	ld	ra,24(sp)
    8000418e:	6442                	ld	s0,16(sp)
    80004190:	6105                	addi	sp,sp,32
    80004192:	8082                	ret

0000000080004194 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004194:	1141                	addi	sp,sp,-16
    80004196:	e406                	sd	ra,8(sp)
    80004198:	e022                	sd	s0,0(sp)
    8000419a:	0800                	addi	s0,sp,16
    8000419c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000419e:	4585                	li	a1,1
    800041a0:	00000097          	auipc	ra,0x0
    800041a4:	dc4080e7          	jalr	-572(ra) # 80003f64 <namex>
}
    800041a8:	60a2                	ld	ra,8(sp)
    800041aa:	6402                	ld	s0,0(sp)
    800041ac:	0141                	addi	sp,sp,16
    800041ae:	8082                	ret

00000000800041b0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041b0:	1101                	addi	sp,sp,-32
    800041b2:	ec06                	sd	ra,24(sp)
    800041b4:	e822                	sd	s0,16(sp)
    800041b6:	e426                	sd	s1,8(sp)
    800041b8:	e04a                	sd	s2,0(sp)
    800041ba:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041bc:	0001e917          	auipc	s2,0x1e
    800041c0:	f6490913          	addi	s2,s2,-156 # 80022120 <log>
    800041c4:	01892583          	lw	a1,24(s2)
    800041c8:	02892503          	lw	a0,40(s2)
    800041cc:	fffff097          	auipc	ra,0xfffff
    800041d0:	fea080e7          	jalr	-22(ra) # 800031b6 <bread>
    800041d4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041d6:	02c92683          	lw	a3,44(s2)
    800041da:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041dc:	02d05763          	blez	a3,8000420a <write_head+0x5a>
    800041e0:	0001e797          	auipc	a5,0x1e
    800041e4:	f7078793          	addi	a5,a5,-144 # 80022150 <log+0x30>
    800041e8:	05c50713          	addi	a4,a0,92
    800041ec:	36fd                	addiw	a3,a3,-1
    800041ee:	1682                	slli	a3,a3,0x20
    800041f0:	9281                	srli	a3,a3,0x20
    800041f2:	068a                	slli	a3,a3,0x2
    800041f4:	0001e617          	auipc	a2,0x1e
    800041f8:	f6060613          	addi	a2,a2,-160 # 80022154 <log+0x34>
    800041fc:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041fe:	4390                	lw	a2,0(a5)
    80004200:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004202:	0791                	addi	a5,a5,4
    80004204:	0711                	addi	a4,a4,4
    80004206:	fed79ce3          	bne	a5,a3,800041fe <write_head+0x4e>
  }
  bwrite(buf);
    8000420a:	8526                	mv	a0,s1
    8000420c:	fffff097          	auipc	ra,0xfffff
    80004210:	09c080e7          	jalr	156(ra) # 800032a8 <bwrite>
  brelse(buf);
    80004214:	8526                	mv	a0,s1
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	0d0080e7          	jalr	208(ra) # 800032e6 <brelse>
}
    8000421e:	60e2                	ld	ra,24(sp)
    80004220:	6442                	ld	s0,16(sp)
    80004222:	64a2                	ld	s1,8(sp)
    80004224:	6902                	ld	s2,0(sp)
    80004226:	6105                	addi	sp,sp,32
    80004228:	8082                	ret

000000008000422a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000422a:	0001e797          	auipc	a5,0x1e
    8000422e:	f227a783          	lw	a5,-222(a5) # 8002214c <log+0x2c>
    80004232:	0af05d63          	blez	a5,800042ec <install_trans+0xc2>
{
    80004236:	7139                	addi	sp,sp,-64
    80004238:	fc06                	sd	ra,56(sp)
    8000423a:	f822                	sd	s0,48(sp)
    8000423c:	f426                	sd	s1,40(sp)
    8000423e:	f04a                	sd	s2,32(sp)
    80004240:	ec4e                	sd	s3,24(sp)
    80004242:	e852                	sd	s4,16(sp)
    80004244:	e456                	sd	s5,8(sp)
    80004246:	e05a                	sd	s6,0(sp)
    80004248:	0080                	addi	s0,sp,64
    8000424a:	8b2a                	mv	s6,a0
    8000424c:	0001ea97          	auipc	s5,0x1e
    80004250:	f04a8a93          	addi	s5,s5,-252 # 80022150 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004254:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004256:	0001e997          	auipc	s3,0x1e
    8000425a:	eca98993          	addi	s3,s3,-310 # 80022120 <log>
    8000425e:	a00d                	j	80004280 <install_trans+0x56>
    brelse(lbuf);
    80004260:	854a                	mv	a0,s2
    80004262:	fffff097          	auipc	ra,0xfffff
    80004266:	084080e7          	jalr	132(ra) # 800032e6 <brelse>
    brelse(dbuf);
    8000426a:	8526                	mv	a0,s1
    8000426c:	fffff097          	auipc	ra,0xfffff
    80004270:	07a080e7          	jalr	122(ra) # 800032e6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004274:	2a05                	addiw	s4,s4,1
    80004276:	0a91                	addi	s5,s5,4
    80004278:	02c9a783          	lw	a5,44(s3)
    8000427c:	04fa5e63          	bge	s4,a5,800042d8 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004280:	0189a583          	lw	a1,24(s3)
    80004284:	014585bb          	addw	a1,a1,s4
    80004288:	2585                	addiw	a1,a1,1
    8000428a:	0289a503          	lw	a0,40(s3)
    8000428e:	fffff097          	auipc	ra,0xfffff
    80004292:	f28080e7          	jalr	-216(ra) # 800031b6 <bread>
    80004296:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004298:	000aa583          	lw	a1,0(s5)
    8000429c:	0289a503          	lw	a0,40(s3)
    800042a0:	fffff097          	auipc	ra,0xfffff
    800042a4:	f16080e7          	jalr	-234(ra) # 800031b6 <bread>
    800042a8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042aa:	40000613          	li	a2,1024
    800042ae:	05890593          	addi	a1,s2,88
    800042b2:	05850513          	addi	a0,a0,88
    800042b6:	ffffd097          	auipc	ra,0xffffd
    800042ba:	a78080e7          	jalr	-1416(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800042be:	8526                	mv	a0,s1
    800042c0:	fffff097          	auipc	ra,0xfffff
    800042c4:	fe8080e7          	jalr	-24(ra) # 800032a8 <bwrite>
    if(recovering == 0)
    800042c8:	f80b1ce3          	bnez	s6,80004260 <install_trans+0x36>
      bunpin(dbuf);
    800042cc:	8526                	mv	a0,s1
    800042ce:	fffff097          	auipc	ra,0xfffff
    800042d2:	0f2080e7          	jalr	242(ra) # 800033c0 <bunpin>
    800042d6:	b769                	j	80004260 <install_trans+0x36>
}
    800042d8:	70e2                	ld	ra,56(sp)
    800042da:	7442                	ld	s0,48(sp)
    800042dc:	74a2                	ld	s1,40(sp)
    800042de:	7902                	ld	s2,32(sp)
    800042e0:	69e2                	ld	s3,24(sp)
    800042e2:	6a42                	ld	s4,16(sp)
    800042e4:	6aa2                	ld	s5,8(sp)
    800042e6:	6b02                	ld	s6,0(sp)
    800042e8:	6121                	addi	sp,sp,64
    800042ea:	8082                	ret
    800042ec:	8082                	ret

00000000800042ee <initlog>:
{
    800042ee:	7179                	addi	sp,sp,-48
    800042f0:	f406                	sd	ra,40(sp)
    800042f2:	f022                	sd	s0,32(sp)
    800042f4:	ec26                	sd	s1,24(sp)
    800042f6:	e84a                	sd	s2,16(sp)
    800042f8:	e44e                	sd	s3,8(sp)
    800042fa:	1800                	addi	s0,sp,48
    800042fc:	892a                	mv	s2,a0
    800042fe:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004300:	0001e497          	auipc	s1,0x1e
    80004304:	e2048493          	addi	s1,s1,-480 # 80022120 <log>
    80004308:	00004597          	auipc	a1,0x4
    8000430c:	32058593          	addi	a1,a1,800 # 80008628 <syscalls+0x1d8>
    80004310:	8526                	mv	a0,s1
    80004312:	ffffd097          	auipc	ra,0xffffd
    80004316:	834080e7          	jalr	-1996(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000431a:	0149a583          	lw	a1,20(s3)
    8000431e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004320:	0109a783          	lw	a5,16(s3)
    80004324:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004326:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000432a:	854a                	mv	a0,s2
    8000432c:	fffff097          	auipc	ra,0xfffff
    80004330:	e8a080e7          	jalr	-374(ra) # 800031b6 <bread>
  log.lh.n = lh->n;
    80004334:	4d34                	lw	a3,88(a0)
    80004336:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004338:	02d05563          	blez	a3,80004362 <initlog+0x74>
    8000433c:	05c50793          	addi	a5,a0,92
    80004340:	0001e717          	auipc	a4,0x1e
    80004344:	e1070713          	addi	a4,a4,-496 # 80022150 <log+0x30>
    80004348:	36fd                	addiw	a3,a3,-1
    8000434a:	1682                	slli	a3,a3,0x20
    8000434c:	9281                	srli	a3,a3,0x20
    8000434e:	068a                	slli	a3,a3,0x2
    80004350:	06050613          	addi	a2,a0,96
    80004354:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004356:	4390                	lw	a2,0(a5)
    80004358:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000435a:	0791                	addi	a5,a5,4
    8000435c:	0711                	addi	a4,a4,4
    8000435e:	fed79ce3          	bne	a5,a3,80004356 <initlog+0x68>
  brelse(buf);
    80004362:	fffff097          	auipc	ra,0xfffff
    80004366:	f84080e7          	jalr	-124(ra) # 800032e6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000436a:	4505                	li	a0,1
    8000436c:	00000097          	auipc	ra,0x0
    80004370:	ebe080e7          	jalr	-322(ra) # 8000422a <install_trans>
  log.lh.n = 0;
    80004374:	0001e797          	auipc	a5,0x1e
    80004378:	dc07ac23          	sw	zero,-552(a5) # 8002214c <log+0x2c>
  write_head(); // clear the log
    8000437c:	00000097          	auipc	ra,0x0
    80004380:	e34080e7          	jalr	-460(ra) # 800041b0 <write_head>
}
    80004384:	70a2                	ld	ra,40(sp)
    80004386:	7402                	ld	s0,32(sp)
    80004388:	64e2                	ld	s1,24(sp)
    8000438a:	6942                	ld	s2,16(sp)
    8000438c:	69a2                	ld	s3,8(sp)
    8000438e:	6145                	addi	sp,sp,48
    80004390:	8082                	ret

0000000080004392 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004392:	1101                	addi	sp,sp,-32
    80004394:	ec06                	sd	ra,24(sp)
    80004396:	e822                	sd	s0,16(sp)
    80004398:	e426                	sd	s1,8(sp)
    8000439a:	e04a                	sd	s2,0(sp)
    8000439c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000439e:	0001e517          	auipc	a0,0x1e
    800043a2:	d8250513          	addi	a0,a0,-638 # 80022120 <log>
    800043a6:	ffffd097          	auipc	ra,0xffffd
    800043aa:	830080e7          	jalr	-2000(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800043ae:	0001e497          	auipc	s1,0x1e
    800043b2:	d7248493          	addi	s1,s1,-654 # 80022120 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043b6:	4979                	li	s2,30
    800043b8:	a039                	j	800043c6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800043ba:	85a6                	mv	a1,s1
    800043bc:	8526                	mv	a0,s1
    800043be:	ffffe097          	auipc	ra,0xffffe
    800043c2:	d7e080e7          	jalr	-642(ra) # 8000213c <sleep>
    if(log.committing){
    800043c6:	50dc                	lw	a5,36(s1)
    800043c8:	fbed                	bnez	a5,800043ba <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043ca:	509c                	lw	a5,32(s1)
    800043cc:	0017871b          	addiw	a4,a5,1
    800043d0:	0007069b          	sext.w	a3,a4
    800043d4:	0027179b          	slliw	a5,a4,0x2
    800043d8:	9fb9                	addw	a5,a5,a4
    800043da:	0017979b          	slliw	a5,a5,0x1
    800043de:	54d8                	lw	a4,44(s1)
    800043e0:	9fb9                	addw	a5,a5,a4
    800043e2:	00f95963          	bge	s2,a5,800043f4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043e6:	85a6                	mv	a1,s1
    800043e8:	8526                	mv	a0,s1
    800043ea:	ffffe097          	auipc	ra,0xffffe
    800043ee:	d52080e7          	jalr	-686(ra) # 8000213c <sleep>
    800043f2:	bfd1                	j	800043c6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043f4:	0001e517          	auipc	a0,0x1e
    800043f8:	d2c50513          	addi	a0,a0,-724 # 80022120 <log>
    800043fc:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800043fe:	ffffd097          	auipc	ra,0xffffd
    80004402:	88c080e7          	jalr	-1908(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004406:	60e2                	ld	ra,24(sp)
    80004408:	6442                	ld	s0,16(sp)
    8000440a:	64a2                	ld	s1,8(sp)
    8000440c:	6902                	ld	s2,0(sp)
    8000440e:	6105                	addi	sp,sp,32
    80004410:	8082                	ret

0000000080004412 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004412:	7139                	addi	sp,sp,-64
    80004414:	fc06                	sd	ra,56(sp)
    80004416:	f822                	sd	s0,48(sp)
    80004418:	f426                	sd	s1,40(sp)
    8000441a:	f04a                	sd	s2,32(sp)
    8000441c:	ec4e                	sd	s3,24(sp)
    8000441e:	e852                	sd	s4,16(sp)
    80004420:	e456                	sd	s5,8(sp)
    80004422:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004424:	0001e497          	auipc	s1,0x1e
    80004428:	cfc48493          	addi	s1,s1,-772 # 80022120 <log>
    8000442c:	8526                	mv	a0,s1
    8000442e:	ffffc097          	auipc	ra,0xffffc
    80004432:	7a8080e7          	jalr	1960(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004436:	509c                	lw	a5,32(s1)
    80004438:	37fd                	addiw	a5,a5,-1
    8000443a:	0007891b          	sext.w	s2,a5
    8000443e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004440:	50dc                	lw	a5,36(s1)
    80004442:	e7b9                	bnez	a5,80004490 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004444:	04091e63          	bnez	s2,800044a0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004448:	0001e497          	auipc	s1,0x1e
    8000444c:	cd848493          	addi	s1,s1,-808 # 80022120 <log>
    80004450:	4785                	li	a5,1
    80004452:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004454:	8526                	mv	a0,s1
    80004456:	ffffd097          	auipc	ra,0xffffd
    8000445a:	834080e7          	jalr	-1996(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000445e:	54dc                	lw	a5,44(s1)
    80004460:	06f04763          	bgtz	a5,800044ce <end_op+0xbc>
    acquire(&log.lock);
    80004464:	0001e497          	auipc	s1,0x1e
    80004468:	cbc48493          	addi	s1,s1,-836 # 80022120 <log>
    8000446c:	8526                	mv	a0,s1
    8000446e:	ffffc097          	auipc	ra,0xffffc
    80004472:	768080e7          	jalr	1896(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004476:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000447a:	8526                	mv	a0,s1
    8000447c:	ffffe097          	auipc	ra,0xffffe
    80004480:	d40080e7          	jalr	-704(ra) # 800021bc <wakeup>
    release(&log.lock);
    80004484:	8526                	mv	a0,s1
    80004486:	ffffd097          	auipc	ra,0xffffd
    8000448a:	804080e7          	jalr	-2044(ra) # 80000c8a <release>
}
    8000448e:	a03d                	j	800044bc <end_op+0xaa>
    panic("log.committing");
    80004490:	00004517          	auipc	a0,0x4
    80004494:	1a050513          	addi	a0,a0,416 # 80008630 <syscalls+0x1e0>
    80004498:	ffffc097          	auipc	ra,0xffffc
    8000449c:	0a6080e7          	jalr	166(ra) # 8000053e <panic>
    wakeup(&log);
    800044a0:	0001e497          	auipc	s1,0x1e
    800044a4:	c8048493          	addi	s1,s1,-896 # 80022120 <log>
    800044a8:	8526                	mv	a0,s1
    800044aa:	ffffe097          	auipc	ra,0xffffe
    800044ae:	d12080e7          	jalr	-750(ra) # 800021bc <wakeup>
  release(&log.lock);
    800044b2:	8526                	mv	a0,s1
    800044b4:	ffffc097          	auipc	ra,0xffffc
    800044b8:	7d6080e7          	jalr	2006(ra) # 80000c8a <release>
}
    800044bc:	70e2                	ld	ra,56(sp)
    800044be:	7442                	ld	s0,48(sp)
    800044c0:	74a2                	ld	s1,40(sp)
    800044c2:	7902                	ld	s2,32(sp)
    800044c4:	69e2                	ld	s3,24(sp)
    800044c6:	6a42                	ld	s4,16(sp)
    800044c8:	6aa2                	ld	s5,8(sp)
    800044ca:	6121                	addi	sp,sp,64
    800044cc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ce:	0001ea97          	auipc	s5,0x1e
    800044d2:	c82a8a93          	addi	s5,s5,-894 # 80022150 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044d6:	0001ea17          	auipc	s4,0x1e
    800044da:	c4aa0a13          	addi	s4,s4,-950 # 80022120 <log>
    800044de:	018a2583          	lw	a1,24(s4)
    800044e2:	012585bb          	addw	a1,a1,s2
    800044e6:	2585                	addiw	a1,a1,1
    800044e8:	028a2503          	lw	a0,40(s4)
    800044ec:	fffff097          	auipc	ra,0xfffff
    800044f0:	cca080e7          	jalr	-822(ra) # 800031b6 <bread>
    800044f4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044f6:	000aa583          	lw	a1,0(s5)
    800044fa:	028a2503          	lw	a0,40(s4)
    800044fe:	fffff097          	auipc	ra,0xfffff
    80004502:	cb8080e7          	jalr	-840(ra) # 800031b6 <bread>
    80004506:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004508:	40000613          	li	a2,1024
    8000450c:	05850593          	addi	a1,a0,88
    80004510:	05848513          	addi	a0,s1,88
    80004514:	ffffd097          	auipc	ra,0xffffd
    80004518:	81a080e7          	jalr	-2022(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000451c:	8526                	mv	a0,s1
    8000451e:	fffff097          	auipc	ra,0xfffff
    80004522:	d8a080e7          	jalr	-630(ra) # 800032a8 <bwrite>
    brelse(from);
    80004526:	854e                	mv	a0,s3
    80004528:	fffff097          	auipc	ra,0xfffff
    8000452c:	dbe080e7          	jalr	-578(ra) # 800032e6 <brelse>
    brelse(to);
    80004530:	8526                	mv	a0,s1
    80004532:	fffff097          	auipc	ra,0xfffff
    80004536:	db4080e7          	jalr	-588(ra) # 800032e6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000453a:	2905                	addiw	s2,s2,1
    8000453c:	0a91                	addi	s5,s5,4
    8000453e:	02ca2783          	lw	a5,44(s4)
    80004542:	f8f94ee3          	blt	s2,a5,800044de <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004546:	00000097          	auipc	ra,0x0
    8000454a:	c6a080e7          	jalr	-918(ra) # 800041b0 <write_head>
    install_trans(0); // Now install writes to home locations
    8000454e:	4501                	li	a0,0
    80004550:	00000097          	auipc	ra,0x0
    80004554:	cda080e7          	jalr	-806(ra) # 8000422a <install_trans>
    log.lh.n = 0;
    80004558:	0001e797          	auipc	a5,0x1e
    8000455c:	be07aa23          	sw	zero,-1036(a5) # 8002214c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004560:	00000097          	auipc	ra,0x0
    80004564:	c50080e7          	jalr	-944(ra) # 800041b0 <write_head>
    80004568:	bdf5                	j	80004464 <end_op+0x52>

000000008000456a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000456a:	1101                	addi	sp,sp,-32
    8000456c:	ec06                	sd	ra,24(sp)
    8000456e:	e822                	sd	s0,16(sp)
    80004570:	e426                	sd	s1,8(sp)
    80004572:	e04a                	sd	s2,0(sp)
    80004574:	1000                	addi	s0,sp,32
    80004576:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004578:	0001e917          	auipc	s2,0x1e
    8000457c:	ba890913          	addi	s2,s2,-1112 # 80022120 <log>
    80004580:	854a                	mv	a0,s2
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	654080e7          	jalr	1620(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000458a:	02c92603          	lw	a2,44(s2)
    8000458e:	47f5                	li	a5,29
    80004590:	06c7c563          	blt	a5,a2,800045fa <log_write+0x90>
    80004594:	0001e797          	auipc	a5,0x1e
    80004598:	ba87a783          	lw	a5,-1112(a5) # 8002213c <log+0x1c>
    8000459c:	37fd                	addiw	a5,a5,-1
    8000459e:	04f65e63          	bge	a2,a5,800045fa <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045a2:	0001e797          	auipc	a5,0x1e
    800045a6:	b9e7a783          	lw	a5,-1122(a5) # 80022140 <log+0x20>
    800045aa:	06f05063          	blez	a5,8000460a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045ae:	4781                	li	a5,0
    800045b0:	06c05563          	blez	a2,8000461a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045b4:	44cc                	lw	a1,12(s1)
    800045b6:	0001e717          	auipc	a4,0x1e
    800045ba:	b9a70713          	addi	a4,a4,-1126 # 80022150 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800045be:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045c0:	4314                	lw	a3,0(a4)
    800045c2:	04b68c63          	beq	a3,a1,8000461a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800045c6:	2785                	addiw	a5,a5,1
    800045c8:	0711                	addi	a4,a4,4
    800045ca:	fef61be3          	bne	a2,a5,800045c0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045ce:	0621                	addi	a2,a2,8
    800045d0:	060a                	slli	a2,a2,0x2
    800045d2:	0001e797          	auipc	a5,0x1e
    800045d6:	b4e78793          	addi	a5,a5,-1202 # 80022120 <log>
    800045da:	963e                	add	a2,a2,a5
    800045dc:	44dc                	lw	a5,12(s1)
    800045de:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045e0:	8526                	mv	a0,s1
    800045e2:	fffff097          	auipc	ra,0xfffff
    800045e6:	da2080e7          	jalr	-606(ra) # 80003384 <bpin>
    log.lh.n++;
    800045ea:	0001e717          	auipc	a4,0x1e
    800045ee:	b3670713          	addi	a4,a4,-1226 # 80022120 <log>
    800045f2:	575c                	lw	a5,44(a4)
    800045f4:	2785                	addiw	a5,a5,1
    800045f6:	d75c                	sw	a5,44(a4)
    800045f8:	a835                	j	80004634 <log_write+0xca>
    panic("too big a transaction");
    800045fa:	00004517          	auipc	a0,0x4
    800045fe:	04650513          	addi	a0,a0,70 # 80008640 <syscalls+0x1f0>
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	f3c080e7          	jalr	-196(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000460a:	00004517          	auipc	a0,0x4
    8000460e:	04e50513          	addi	a0,a0,78 # 80008658 <syscalls+0x208>
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000461a:	00878713          	addi	a4,a5,8
    8000461e:	00271693          	slli	a3,a4,0x2
    80004622:	0001e717          	auipc	a4,0x1e
    80004626:	afe70713          	addi	a4,a4,-1282 # 80022120 <log>
    8000462a:	9736                	add	a4,a4,a3
    8000462c:	44d4                	lw	a3,12(s1)
    8000462e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004630:	faf608e3          	beq	a2,a5,800045e0 <log_write+0x76>
  }
  release(&log.lock);
    80004634:	0001e517          	auipc	a0,0x1e
    80004638:	aec50513          	addi	a0,a0,-1300 # 80022120 <log>
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	64e080e7          	jalr	1614(ra) # 80000c8a <release>
}
    80004644:	60e2                	ld	ra,24(sp)
    80004646:	6442                	ld	s0,16(sp)
    80004648:	64a2                	ld	s1,8(sp)
    8000464a:	6902                	ld	s2,0(sp)
    8000464c:	6105                	addi	sp,sp,32
    8000464e:	8082                	ret

0000000080004650 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004650:	1101                	addi	sp,sp,-32
    80004652:	ec06                	sd	ra,24(sp)
    80004654:	e822                	sd	s0,16(sp)
    80004656:	e426                	sd	s1,8(sp)
    80004658:	e04a                	sd	s2,0(sp)
    8000465a:	1000                	addi	s0,sp,32
    8000465c:	84aa                	mv	s1,a0
    8000465e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004660:	00004597          	auipc	a1,0x4
    80004664:	01858593          	addi	a1,a1,24 # 80008678 <syscalls+0x228>
    80004668:	0521                	addi	a0,a0,8
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	4dc080e7          	jalr	1244(ra) # 80000b46 <initlock>
  lk->name = name;
    80004672:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004676:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000467a:	0204a423          	sw	zero,40(s1)
}
    8000467e:	60e2                	ld	ra,24(sp)
    80004680:	6442                	ld	s0,16(sp)
    80004682:	64a2                	ld	s1,8(sp)
    80004684:	6902                	ld	s2,0(sp)
    80004686:	6105                	addi	sp,sp,32
    80004688:	8082                	ret

000000008000468a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000468a:	1101                	addi	sp,sp,-32
    8000468c:	ec06                	sd	ra,24(sp)
    8000468e:	e822                	sd	s0,16(sp)
    80004690:	e426                	sd	s1,8(sp)
    80004692:	e04a                	sd	s2,0(sp)
    80004694:	1000                	addi	s0,sp,32
    80004696:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004698:	00850913          	addi	s2,a0,8
    8000469c:	854a                	mv	a0,s2
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	538080e7          	jalr	1336(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800046a6:	409c                	lw	a5,0(s1)
    800046a8:	cb89                	beqz	a5,800046ba <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046aa:	85ca                	mv	a1,s2
    800046ac:	8526                	mv	a0,s1
    800046ae:	ffffe097          	auipc	ra,0xffffe
    800046b2:	a8e080e7          	jalr	-1394(ra) # 8000213c <sleep>
  while (lk->locked) {
    800046b6:	409c                	lw	a5,0(s1)
    800046b8:	fbed                	bnez	a5,800046aa <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046ba:	4785                	li	a5,1
    800046bc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046be:	ffffd097          	auipc	ra,0xffffd
    800046c2:	2c2080e7          	jalr	706(ra) # 80001980 <myproc>
    800046c6:	515c                	lw	a5,36(a0)
    800046c8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046ca:	854a                	mv	a0,s2
    800046cc:	ffffc097          	auipc	ra,0xffffc
    800046d0:	5be080e7          	jalr	1470(ra) # 80000c8a <release>
}
    800046d4:	60e2                	ld	ra,24(sp)
    800046d6:	6442                	ld	s0,16(sp)
    800046d8:	64a2                	ld	s1,8(sp)
    800046da:	6902                	ld	s2,0(sp)
    800046dc:	6105                	addi	sp,sp,32
    800046de:	8082                	ret

00000000800046e0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046e0:	1101                	addi	sp,sp,-32
    800046e2:	ec06                	sd	ra,24(sp)
    800046e4:	e822                	sd	s0,16(sp)
    800046e6:	e426                	sd	s1,8(sp)
    800046e8:	e04a                	sd	s2,0(sp)
    800046ea:	1000                	addi	s0,sp,32
    800046ec:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046ee:	00850913          	addi	s2,a0,8
    800046f2:	854a                	mv	a0,s2
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	4e2080e7          	jalr	1250(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800046fc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004700:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004704:	8526                	mv	a0,s1
    80004706:	ffffe097          	auipc	ra,0xffffe
    8000470a:	ab6080e7          	jalr	-1354(ra) # 800021bc <wakeup>
  release(&lk->lk);
    8000470e:	854a                	mv	a0,s2
    80004710:	ffffc097          	auipc	ra,0xffffc
    80004714:	57a080e7          	jalr	1402(ra) # 80000c8a <release>
}
    80004718:	60e2                	ld	ra,24(sp)
    8000471a:	6442                	ld	s0,16(sp)
    8000471c:	64a2                	ld	s1,8(sp)
    8000471e:	6902                	ld	s2,0(sp)
    80004720:	6105                	addi	sp,sp,32
    80004722:	8082                	ret

0000000080004724 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004724:	7179                	addi	sp,sp,-48
    80004726:	f406                	sd	ra,40(sp)
    80004728:	f022                	sd	s0,32(sp)
    8000472a:	ec26                	sd	s1,24(sp)
    8000472c:	e84a                	sd	s2,16(sp)
    8000472e:	e44e                	sd	s3,8(sp)
    80004730:	1800                	addi	s0,sp,48
    80004732:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004734:	00850913          	addi	s2,a0,8
    80004738:	854a                	mv	a0,s2
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	49c080e7          	jalr	1180(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004742:	409c                	lw	a5,0(s1)
    80004744:	ef99                	bnez	a5,80004762 <holdingsleep+0x3e>
    80004746:	4481                	li	s1,0
  release(&lk->lk);
    80004748:	854a                	mv	a0,s2
    8000474a:	ffffc097          	auipc	ra,0xffffc
    8000474e:	540080e7          	jalr	1344(ra) # 80000c8a <release>
  return r;
}
    80004752:	8526                	mv	a0,s1
    80004754:	70a2                	ld	ra,40(sp)
    80004756:	7402                	ld	s0,32(sp)
    80004758:	64e2                	ld	s1,24(sp)
    8000475a:	6942                	ld	s2,16(sp)
    8000475c:	69a2                	ld	s3,8(sp)
    8000475e:	6145                	addi	sp,sp,48
    80004760:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004762:	0284a983          	lw	s3,40(s1)
    80004766:	ffffd097          	auipc	ra,0xffffd
    8000476a:	21a080e7          	jalr	538(ra) # 80001980 <myproc>
    8000476e:	5144                	lw	s1,36(a0)
    80004770:	413484b3          	sub	s1,s1,s3
    80004774:	0014b493          	seqz	s1,s1
    80004778:	bfc1                	j	80004748 <holdingsleep+0x24>

000000008000477a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000477a:	1141                	addi	sp,sp,-16
    8000477c:	e406                	sd	ra,8(sp)
    8000477e:	e022                	sd	s0,0(sp)
    80004780:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004782:	00004597          	auipc	a1,0x4
    80004786:	f0658593          	addi	a1,a1,-250 # 80008688 <syscalls+0x238>
    8000478a:	0001e517          	auipc	a0,0x1e
    8000478e:	ade50513          	addi	a0,a0,-1314 # 80022268 <ftable>
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	3b4080e7          	jalr	948(ra) # 80000b46 <initlock>
}
    8000479a:	60a2                	ld	ra,8(sp)
    8000479c:	6402                	ld	s0,0(sp)
    8000479e:	0141                	addi	sp,sp,16
    800047a0:	8082                	ret

00000000800047a2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047a2:	1101                	addi	sp,sp,-32
    800047a4:	ec06                	sd	ra,24(sp)
    800047a6:	e822                	sd	s0,16(sp)
    800047a8:	e426                	sd	s1,8(sp)
    800047aa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047ac:	0001e517          	auipc	a0,0x1e
    800047b0:	abc50513          	addi	a0,a0,-1348 # 80022268 <ftable>
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	422080e7          	jalr	1058(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047bc:	0001e497          	auipc	s1,0x1e
    800047c0:	ac448493          	addi	s1,s1,-1340 # 80022280 <ftable+0x18>
    800047c4:	0001f717          	auipc	a4,0x1f
    800047c8:	a5c70713          	addi	a4,a4,-1444 # 80023220 <disk>
    if(f->ref == 0){
    800047cc:	40dc                	lw	a5,4(s1)
    800047ce:	cf99                	beqz	a5,800047ec <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047d0:	02848493          	addi	s1,s1,40
    800047d4:	fee49ce3          	bne	s1,a4,800047cc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047d8:	0001e517          	auipc	a0,0x1e
    800047dc:	a9050513          	addi	a0,a0,-1392 # 80022268 <ftable>
    800047e0:	ffffc097          	auipc	ra,0xffffc
    800047e4:	4aa080e7          	jalr	1194(ra) # 80000c8a <release>
  return 0;
    800047e8:	4481                	li	s1,0
    800047ea:	a819                	j	80004800 <filealloc+0x5e>
      f->ref = 1;
    800047ec:	4785                	li	a5,1
    800047ee:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047f0:	0001e517          	auipc	a0,0x1e
    800047f4:	a7850513          	addi	a0,a0,-1416 # 80022268 <ftable>
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	492080e7          	jalr	1170(ra) # 80000c8a <release>
}
    80004800:	8526                	mv	a0,s1
    80004802:	60e2                	ld	ra,24(sp)
    80004804:	6442                	ld	s0,16(sp)
    80004806:	64a2                	ld	s1,8(sp)
    80004808:	6105                	addi	sp,sp,32
    8000480a:	8082                	ret

000000008000480c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000480c:	1101                	addi	sp,sp,-32
    8000480e:	ec06                	sd	ra,24(sp)
    80004810:	e822                	sd	s0,16(sp)
    80004812:	e426                	sd	s1,8(sp)
    80004814:	1000                	addi	s0,sp,32
    80004816:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004818:	0001e517          	auipc	a0,0x1e
    8000481c:	a5050513          	addi	a0,a0,-1456 # 80022268 <ftable>
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	3b6080e7          	jalr	950(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004828:	40dc                	lw	a5,4(s1)
    8000482a:	02f05263          	blez	a5,8000484e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000482e:	2785                	addiw	a5,a5,1
    80004830:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004832:	0001e517          	auipc	a0,0x1e
    80004836:	a3650513          	addi	a0,a0,-1482 # 80022268 <ftable>
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	450080e7          	jalr	1104(ra) # 80000c8a <release>
  return f;
}
    80004842:	8526                	mv	a0,s1
    80004844:	60e2                	ld	ra,24(sp)
    80004846:	6442                	ld	s0,16(sp)
    80004848:	64a2                	ld	s1,8(sp)
    8000484a:	6105                	addi	sp,sp,32
    8000484c:	8082                	ret
    panic("filedup");
    8000484e:	00004517          	auipc	a0,0x4
    80004852:	e4250513          	addi	a0,a0,-446 # 80008690 <syscalls+0x240>
    80004856:	ffffc097          	auipc	ra,0xffffc
    8000485a:	ce8080e7          	jalr	-792(ra) # 8000053e <panic>

000000008000485e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000485e:	7139                	addi	sp,sp,-64
    80004860:	fc06                	sd	ra,56(sp)
    80004862:	f822                	sd	s0,48(sp)
    80004864:	f426                	sd	s1,40(sp)
    80004866:	f04a                	sd	s2,32(sp)
    80004868:	ec4e                	sd	s3,24(sp)
    8000486a:	e852                	sd	s4,16(sp)
    8000486c:	e456                	sd	s5,8(sp)
    8000486e:	0080                	addi	s0,sp,64
    80004870:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004872:	0001e517          	auipc	a0,0x1e
    80004876:	9f650513          	addi	a0,a0,-1546 # 80022268 <ftable>
    8000487a:	ffffc097          	auipc	ra,0xffffc
    8000487e:	35c080e7          	jalr	860(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004882:	40dc                	lw	a5,4(s1)
    80004884:	06f05163          	blez	a5,800048e6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004888:	37fd                	addiw	a5,a5,-1
    8000488a:	0007871b          	sext.w	a4,a5
    8000488e:	c0dc                	sw	a5,4(s1)
    80004890:	06e04363          	bgtz	a4,800048f6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004894:	0004a903          	lw	s2,0(s1)
    80004898:	0094ca83          	lbu	s5,9(s1)
    8000489c:	0104ba03          	ld	s4,16(s1)
    800048a0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048a4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048a8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048ac:	0001e517          	auipc	a0,0x1e
    800048b0:	9bc50513          	addi	a0,a0,-1604 # 80022268 <ftable>
    800048b4:	ffffc097          	auipc	ra,0xffffc
    800048b8:	3d6080e7          	jalr	982(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800048bc:	4785                	li	a5,1
    800048be:	04f90d63          	beq	s2,a5,80004918 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048c2:	3979                	addiw	s2,s2,-2
    800048c4:	4785                	li	a5,1
    800048c6:	0527e063          	bltu	a5,s2,80004906 <fileclose+0xa8>
    begin_op();
    800048ca:	00000097          	auipc	ra,0x0
    800048ce:	ac8080e7          	jalr	-1336(ra) # 80004392 <begin_op>
    iput(ff.ip);
    800048d2:	854e                	mv	a0,s3
    800048d4:	fffff097          	auipc	ra,0xfffff
    800048d8:	2b6080e7          	jalr	694(ra) # 80003b8a <iput>
    end_op();
    800048dc:	00000097          	auipc	ra,0x0
    800048e0:	b36080e7          	jalr	-1226(ra) # 80004412 <end_op>
    800048e4:	a00d                	j	80004906 <fileclose+0xa8>
    panic("fileclose");
    800048e6:	00004517          	auipc	a0,0x4
    800048ea:	db250513          	addi	a0,a0,-590 # 80008698 <syscalls+0x248>
    800048ee:	ffffc097          	auipc	ra,0xffffc
    800048f2:	c50080e7          	jalr	-944(ra) # 8000053e <panic>
    release(&ftable.lock);
    800048f6:	0001e517          	auipc	a0,0x1e
    800048fa:	97250513          	addi	a0,a0,-1678 # 80022268 <ftable>
    800048fe:	ffffc097          	auipc	ra,0xffffc
    80004902:	38c080e7          	jalr	908(ra) # 80000c8a <release>
  }
}
    80004906:	70e2                	ld	ra,56(sp)
    80004908:	7442                	ld	s0,48(sp)
    8000490a:	74a2                	ld	s1,40(sp)
    8000490c:	7902                	ld	s2,32(sp)
    8000490e:	69e2                	ld	s3,24(sp)
    80004910:	6a42                	ld	s4,16(sp)
    80004912:	6aa2                	ld	s5,8(sp)
    80004914:	6121                	addi	sp,sp,64
    80004916:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004918:	85d6                	mv	a1,s5
    8000491a:	8552                	mv	a0,s4
    8000491c:	00000097          	auipc	ra,0x0
    80004920:	34c080e7          	jalr	844(ra) # 80004c68 <pipeclose>
    80004924:	b7cd                	j	80004906 <fileclose+0xa8>

0000000080004926 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004926:	715d                	addi	sp,sp,-80
    80004928:	e486                	sd	ra,72(sp)
    8000492a:	e0a2                	sd	s0,64(sp)
    8000492c:	fc26                	sd	s1,56(sp)
    8000492e:	f84a                	sd	s2,48(sp)
    80004930:	f44e                	sd	s3,40(sp)
    80004932:	0880                	addi	s0,sp,80
    80004934:	84aa                	mv	s1,a0
    80004936:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004938:	ffffd097          	auipc	ra,0xffffd
    8000493c:	048080e7          	jalr	72(ra) # 80001980 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004940:	409c                	lw	a5,0(s1)
    80004942:	37f9                	addiw	a5,a5,-2
    80004944:	4705                	li	a4,1
    80004946:	04f76763          	bltu	a4,a5,80004994 <filestat+0x6e>
    8000494a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000494c:	6c88                	ld	a0,24(s1)
    8000494e:	fffff097          	auipc	ra,0xfffff
    80004952:	082080e7          	jalr	130(ra) # 800039d0 <ilock>
    stati(f->ip, &st);
    80004956:	fb840593          	addi	a1,s0,-72
    8000495a:	6c88                	ld	a0,24(s1)
    8000495c:	fffff097          	auipc	ra,0xfffff
    80004960:	2fe080e7          	jalr	766(ra) # 80003c5a <stati>
    iunlock(f->ip);
    80004964:	6c88                	ld	a0,24(s1)
    80004966:	fffff097          	auipc	ra,0xfffff
    8000496a:	12c080e7          	jalr	300(ra) # 80003a92 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000496e:	46e1                	li	a3,24
    80004970:	fb840613          	addi	a2,s0,-72
    80004974:	85ce                	mv	a1,s3
    80004976:	10093503          	ld	a0,256(s2)
    8000497a:	ffffd097          	auipc	ra,0xffffd
    8000497e:	cee080e7          	jalr	-786(ra) # 80001668 <copyout>
    80004982:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004986:	60a6                	ld	ra,72(sp)
    80004988:	6406                	ld	s0,64(sp)
    8000498a:	74e2                	ld	s1,56(sp)
    8000498c:	7942                	ld	s2,48(sp)
    8000498e:	79a2                	ld	s3,40(sp)
    80004990:	6161                	addi	sp,sp,80
    80004992:	8082                	ret
  return -1;
    80004994:	557d                	li	a0,-1
    80004996:	bfc5                	j	80004986 <filestat+0x60>

0000000080004998 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004998:	7179                	addi	sp,sp,-48
    8000499a:	f406                	sd	ra,40(sp)
    8000499c:	f022                	sd	s0,32(sp)
    8000499e:	ec26                	sd	s1,24(sp)
    800049a0:	e84a                	sd	s2,16(sp)
    800049a2:	e44e                	sd	s3,8(sp)
    800049a4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049a6:	00854783          	lbu	a5,8(a0)
    800049aa:	c3d5                	beqz	a5,80004a4e <fileread+0xb6>
    800049ac:	84aa                	mv	s1,a0
    800049ae:	89ae                	mv	s3,a1
    800049b0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800049b2:	411c                	lw	a5,0(a0)
    800049b4:	4705                	li	a4,1
    800049b6:	04e78963          	beq	a5,a4,80004a08 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049ba:	470d                	li	a4,3
    800049bc:	04e78d63          	beq	a5,a4,80004a16 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800049c0:	4709                	li	a4,2
    800049c2:	06e79e63          	bne	a5,a4,80004a3e <fileread+0xa6>
    ilock(f->ip);
    800049c6:	6d08                	ld	a0,24(a0)
    800049c8:	fffff097          	auipc	ra,0xfffff
    800049cc:	008080e7          	jalr	8(ra) # 800039d0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049d0:	874a                	mv	a4,s2
    800049d2:	5094                	lw	a3,32(s1)
    800049d4:	864e                	mv	a2,s3
    800049d6:	4585                	li	a1,1
    800049d8:	6c88                	ld	a0,24(s1)
    800049da:	fffff097          	auipc	ra,0xfffff
    800049de:	2aa080e7          	jalr	682(ra) # 80003c84 <readi>
    800049e2:	892a                	mv	s2,a0
    800049e4:	00a05563          	blez	a0,800049ee <fileread+0x56>
      f->off += r;
    800049e8:	509c                	lw	a5,32(s1)
    800049ea:	9fa9                	addw	a5,a5,a0
    800049ec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049ee:	6c88                	ld	a0,24(s1)
    800049f0:	fffff097          	auipc	ra,0xfffff
    800049f4:	0a2080e7          	jalr	162(ra) # 80003a92 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049f8:	854a                	mv	a0,s2
    800049fa:	70a2                	ld	ra,40(sp)
    800049fc:	7402                	ld	s0,32(sp)
    800049fe:	64e2                	ld	s1,24(sp)
    80004a00:	6942                	ld	s2,16(sp)
    80004a02:	69a2                	ld	s3,8(sp)
    80004a04:	6145                	addi	sp,sp,48
    80004a06:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a08:	6908                	ld	a0,16(a0)
    80004a0a:	00000097          	auipc	ra,0x0
    80004a0e:	3c6080e7          	jalr	966(ra) # 80004dd0 <piperead>
    80004a12:	892a                	mv	s2,a0
    80004a14:	b7d5                	j	800049f8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a16:	02451783          	lh	a5,36(a0)
    80004a1a:	03079693          	slli	a3,a5,0x30
    80004a1e:	92c1                	srli	a3,a3,0x30
    80004a20:	4725                	li	a4,9
    80004a22:	02d76863          	bltu	a4,a3,80004a52 <fileread+0xba>
    80004a26:	0792                	slli	a5,a5,0x4
    80004a28:	0001d717          	auipc	a4,0x1d
    80004a2c:	7a070713          	addi	a4,a4,1952 # 800221c8 <devsw>
    80004a30:	97ba                	add	a5,a5,a4
    80004a32:	639c                	ld	a5,0(a5)
    80004a34:	c38d                	beqz	a5,80004a56 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a36:	4505                	li	a0,1
    80004a38:	9782                	jalr	a5
    80004a3a:	892a                	mv	s2,a0
    80004a3c:	bf75                	j	800049f8 <fileread+0x60>
    panic("fileread");
    80004a3e:	00004517          	auipc	a0,0x4
    80004a42:	c6a50513          	addi	a0,a0,-918 # 800086a8 <syscalls+0x258>
    80004a46:	ffffc097          	auipc	ra,0xffffc
    80004a4a:	af8080e7          	jalr	-1288(ra) # 8000053e <panic>
    return -1;
    80004a4e:	597d                	li	s2,-1
    80004a50:	b765                	j	800049f8 <fileread+0x60>
      return -1;
    80004a52:	597d                	li	s2,-1
    80004a54:	b755                	j	800049f8 <fileread+0x60>
    80004a56:	597d                	li	s2,-1
    80004a58:	b745                	j	800049f8 <fileread+0x60>

0000000080004a5a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a5a:	715d                	addi	sp,sp,-80
    80004a5c:	e486                	sd	ra,72(sp)
    80004a5e:	e0a2                	sd	s0,64(sp)
    80004a60:	fc26                	sd	s1,56(sp)
    80004a62:	f84a                	sd	s2,48(sp)
    80004a64:	f44e                	sd	s3,40(sp)
    80004a66:	f052                	sd	s4,32(sp)
    80004a68:	ec56                	sd	s5,24(sp)
    80004a6a:	e85a                	sd	s6,16(sp)
    80004a6c:	e45e                	sd	s7,8(sp)
    80004a6e:	e062                	sd	s8,0(sp)
    80004a70:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a72:	00954783          	lbu	a5,9(a0)
    80004a76:	10078663          	beqz	a5,80004b82 <filewrite+0x128>
    80004a7a:	892a                	mv	s2,a0
    80004a7c:	8aae                	mv	s5,a1
    80004a7e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a80:	411c                	lw	a5,0(a0)
    80004a82:	4705                	li	a4,1
    80004a84:	02e78263          	beq	a5,a4,80004aa8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a88:	470d                	li	a4,3
    80004a8a:	02e78663          	beq	a5,a4,80004ab6 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a8e:	4709                	li	a4,2
    80004a90:	0ee79163          	bne	a5,a4,80004b72 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a94:	0ac05d63          	blez	a2,80004b4e <filewrite+0xf4>
    int i = 0;
    80004a98:	4981                	li	s3,0
    80004a9a:	6b05                	lui	s6,0x1
    80004a9c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004aa0:	6b85                	lui	s7,0x1
    80004aa2:	c00b8b9b          	addiw	s7,s7,-1024
    80004aa6:	a861                	j	80004b3e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004aa8:	6908                	ld	a0,16(a0)
    80004aaa:	00000097          	auipc	ra,0x0
    80004aae:	22e080e7          	jalr	558(ra) # 80004cd8 <pipewrite>
    80004ab2:	8a2a                	mv	s4,a0
    80004ab4:	a045                	j	80004b54 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ab6:	02451783          	lh	a5,36(a0)
    80004aba:	03079693          	slli	a3,a5,0x30
    80004abe:	92c1                	srli	a3,a3,0x30
    80004ac0:	4725                	li	a4,9
    80004ac2:	0cd76263          	bltu	a4,a3,80004b86 <filewrite+0x12c>
    80004ac6:	0792                	slli	a5,a5,0x4
    80004ac8:	0001d717          	auipc	a4,0x1d
    80004acc:	70070713          	addi	a4,a4,1792 # 800221c8 <devsw>
    80004ad0:	97ba                	add	a5,a5,a4
    80004ad2:	679c                	ld	a5,8(a5)
    80004ad4:	cbdd                	beqz	a5,80004b8a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ad6:	4505                	li	a0,1
    80004ad8:	9782                	jalr	a5
    80004ada:	8a2a                	mv	s4,a0
    80004adc:	a8a5                	j	80004b54 <filewrite+0xfa>
    80004ade:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004ae2:	00000097          	auipc	ra,0x0
    80004ae6:	8b0080e7          	jalr	-1872(ra) # 80004392 <begin_op>
      ilock(f->ip);
    80004aea:	01893503          	ld	a0,24(s2)
    80004aee:	fffff097          	auipc	ra,0xfffff
    80004af2:	ee2080e7          	jalr	-286(ra) # 800039d0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004af6:	8762                	mv	a4,s8
    80004af8:	02092683          	lw	a3,32(s2)
    80004afc:	01598633          	add	a2,s3,s5
    80004b00:	4585                	li	a1,1
    80004b02:	01893503          	ld	a0,24(s2)
    80004b06:	fffff097          	auipc	ra,0xfffff
    80004b0a:	276080e7          	jalr	630(ra) # 80003d7c <writei>
    80004b0e:	84aa                	mv	s1,a0
    80004b10:	00a05763          	blez	a0,80004b1e <filewrite+0xc4>
        f->off += r;
    80004b14:	02092783          	lw	a5,32(s2)
    80004b18:	9fa9                	addw	a5,a5,a0
    80004b1a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b1e:	01893503          	ld	a0,24(s2)
    80004b22:	fffff097          	auipc	ra,0xfffff
    80004b26:	f70080e7          	jalr	-144(ra) # 80003a92 <iunlock>
      end_op();
    80004b2a:	00000097          	auipc	ra,0x0
    80004b2e:	8e8080e7          	jalr	-1816(ra) # 80004412 <end_op>

      if(r != n1){
    80004b32:	009c1f63          	bne	s8,s1,80004b50 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004b36:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b3a:	0149db63          	bge	s3,s4,80004b50 <filewrite+0xf6>
      int n1 = n - i;
    80004b3e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b42:	84be                	mv	s1,a5
    80004b44:	2781                	sext.w	a5,a5
    80004b46:	f8fb5ce3          	bge	s6,a5,80004ade <filewrite+0x84>
    80004b4a:	84de                	mv	s1,s7
    80004b4c:	bf49                	j	80004ade <filewrite+0x84>
    int i = 0;
    80004b4e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b50:	013a1f63          	bne	s4,s3,80004b6e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b54:	8552                	mv	a0,s4
    80004b56:	60a6                	ld	ra,72(sp)
    80004b58:	6406                	ld	s0,64(sp)
    80004b5a:	74e2                	ld	s1,56(sp)
    80004b5c:	7942                	ld	s2,48(sp)
    80004b5e:	79a2                	ld	s3,40(sp)
    80004b60:	7a02                	ld	s4,32(sp)
    80004b62:	6ae2                	ld	s5,24(sp)
    80004b64:	6b42                	ld	s6,16(sp)
    80004b66:	6ba2                	ld	s7,8(sp)
    80004b68:	6c02                	ld	s8,0(sp)
    80004b6a:	6161                	addi	sp,sp,80
    80004b6c:	8082                	ret
    ret = (i == n ? n : -1);
    80004b6e:	5a7d                	li	s4,-1
    80004b70:	b7d5                	j	80004b54 <filewrite+0xfa>
    panic("filewrite");
    80004b72:	00004517          	auipc	a0,0x4
    80004b76:	b4650513          	addi	a0,a0,-1210 # 800086b8 <syscalls+0x268>
    80004b7a:	ffffc097          	auipc	ra,0xffffc
    80004b7e:	9c4080e7          	jalr	-1596(ra) # 8000053e <panic>
    return -1;
    80004b82:	5a7d                	li	s4,-1
    80004b84:	bfc1                	j	80004b54 <filewrite+0xfa>
      return -1;
    80004b86:	5a7d                	li	s4,-1
    80004b88:	b7f1                	j	80004b54 <filewrite+0xfa>
    80004b8a:	5a7d                	li	s4,-1
    80004b8c:	b7e1                	j	80004b54 <filewrite+0xfa>

0000000080004b8e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b8e:	7179                	addi	sp,sp,-48
    80004b90:	f406                	sd	ra,40(sp)
    80004b92:	f022                	sd	s0,32(sp)
    80004b94:	ec26                	sd	s1,24(sp)
    80004b96:	e84a                	sd	s2,16(sp)
    80004b98:	e44e                	sd	s3,8(sp)
    80004b9a:	e052                	sd	s4,0(sp)
    80004b9c:	1800                	addi	s0,sp,48
    80004b9e:	84aa                	mv	s1,a0
    80004ba0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ba2:	0005b023          	sd	zero,0(a1)
    80004ba6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004baa:	00000097          	auipc	ra,0x0
    80004bae:	bf8080e7          	jalr	-1032(ra) # 800047a2 <filealloc>
    80004bb2:	e088                	sd	a0,0(s1)
    80004bb4:	c551                	beqz	a0,80004c40 <pipealloc+0xb2>
    80004bb6:	00000097          	auipc	ra,0x0
    80004bba:	bec080e7          	jalr	-1044(ra) # 800047a2 <filealloc>
    80004bbe:	00aa3023          	sd	a0,0(s4)
    80004bc2:	c92d                	beqz	a0,80004c34 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004bc4:	ffffc097          	auipc	ra,0xffffc
    80004bc8:	f22080e7          	jalr	-222(ra) # 80000ae6 <kalloc>
    80004bcc:	892a                	mv	s2,a0
    80004bce:	c125                	beqz	a0,80004c2e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004bd0:	4985                	li	s3,1
    80004bd2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004bd6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004bda:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004bde:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004be2:	00004597          	auipc	a1,0x4
    80004be6:	ae658593          	addi	a1,a1,-1306 # 800086c8 <syscalls+0x278>
    80004bea:	ffffc097          	auipc	ra,0xffffc
    80004bee:	f5c080e7          	jalr	-164(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004bf2:	609c                	ld	a5,0(s1)
    80004bf4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bf8:	609c                	ld	a5,0(s1)
    80004bfa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bfe:	609c                	ld	a5,0(s1)
    80004c00:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c04:	609c                	ld	a5,0(s1)
    80004c06:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c0a:	000a3783          	ld	a5,0(s4)
    80004c0e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c12:	000a3783          	ld	a5,0(s4)
    80004c16:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c1a:	000a3783          	ld	a5,0(s4)
    80004c1e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c22:	000a3783          	ld	a5,0(s4)
    80004c26:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c2a:	4501                	li	a0,0
    80004c2c:	a025                	j	80004c54 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c2e:	6088                	ld	a0,0(s1)
    80004c30:	e501                	bnez	a0,80004c38 <pipealloc+0xaa>
    80004c32:	a039                	j	80004c40 <pipealloc+0xb2>
    80004c34:	6088                	ld	a0,0(s1)
    80004c36:	c51d                	beqz	a0,80004c64 <pipealloc+0xd6>
    fileclose(*f0);
    80004c38:	00000097          	auipc	ra,0x0
    80004c3c:	c26080e7          	jalr	-986(ra) # 8000485e <fileclose>
  if(*f1)
    80004c40:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c44:	557d                	li	a0,-1
  if(*f1)
    80004c46:	c799                	beqz	a5,80004c54 <pipealloc+0xc6>
    fileclose(*f1);
    80004c48:	853e                	mv	a0,a5
    80004c4a:	00000097          	auipc	ra,0x0
    80004c4e:	c14080e7          	jalr	-1004(ra) # 8000485e <fileclose>
  return -1;
    80004c52:	557d                	li	a0,-1
}
    80004c54:	70a2                	ld	ra,40(sp)
    80004c56:	7402                	ld	s0,32(sp)
    80004c58:	64e2                	ld	s1,24(sp)
    80004c5a:	6942                	ld	s2,16(sp)
    80004c5c:	69a2                	ld	s3,8(sp)
    80004c5e:	6a02                	ld	s4,0(sp)
    80004c60:	6145                	addi	sp,sp,48
    80004c62:	8082                	ret
  return -1;
    80004c64:	557d                	li	a0,-1
    80004c66:	b7fd                	j	80004c54 <pipealloc+0xc6>

0000000080004c68 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c68:	1101                	addi	sp,sp,-32
    80004c6a:	ec06                	sd	ra,24(sp)
    80004c6c:	e822                	sd	s0,16(sp)
    80004c6e:	e426                	sd	s1,8(sp)
    80004c70:	e04a                	sd	s2,0(sp)
    80004c72:	1000                	addi	s0,sp,32
    80004c74:	84aa                	mv	s1,a0
    80004c76:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c78:	ffffc097          	auipc	ra,0xffffc
    80004c7c:	f5e080e7          	jalr	-162(ra) # 80000bd6 <acquire>
  if(writable){
    80004c80:	02090d63          	beqz	s2,80004cba <pipeclose+0x52>
    pi->writeopen = 0;
    80004c84:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c88:	21848513          	addi	a0,s1,536
    80004c8c:	ffffd097          	auipc	ra,0xffffd
    80004c90:	530080e7          	jalr	1328(ra) # 800021bc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c94:	2204b783          	ld	a5,544(s1)
    80004c98:	eb95                	bnez	a5,80004ccc <pipeclose+0x64>
    release(&pi->lock);
    80004c9a:	8526                	mv	a0,s1
    80004c9c:	ffffc097          	auipc	ra,0xffffc
    80004ca0:	fee080e7          	jalr	-18(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004ca4:	8526                	mv	a0,s1
    80004ca6:	ffffc097          	auipc	ra,0xffffc
    80004caa:	d44080e7          	jalr	-700(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004cae:	60e2                	ld	ra,24(sp)
    80004cb0:	6442                	ld	s0,16(sp)
    80004cb2:	64a2                	ld	s1,8(sp)
    80004cb4:	6902                	ld	s2,0(sp)
    80004cb6:	6105                	addi	sp,sp,32
    80004cb8:	8082                	ret
    pi->readopen = 0;
    80004cba:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004cbe:	21c48513          	addi	a0,s1,540
    80004cc2:	ffffd097          	auipc	ra,0xffffd
    80004cc6:	4fa080e7          	jalr	1274(ra) # 800021bc <wakeup>
    80004cca:	b7e9                	j	80004c94 <pipeclose+0x2c>
    release(&pi->lock);
    80004ccc:	8526                	mv	a0,s1
    80004cce:	ffffc097          	auipc	ra,0xffffc
    80004cd2:	fbc080e7          	jalr	-68(ra) # 80000c8a <release>
}
    80004cd6:	bfe1                	j	80004cae <pipeclose+0x46>

0000000080004cd8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cd8:	711d                	addi	sp,sp,-96
    80004cda:	ec86                	sd	ra,88(sp)
    80004cdc:	e8a2                	sd	s0,80(sp)
    80004cde:	e4a6                	sd	s1,72(sp)
    80004ce0:	e0ca                	sd	s2,64(sp)
    80004ce2:	fc4e                	sd	s3,56(sp)
    80004ce4:	f852                	sd	s4,48(sp)
    80004ce6:	f456                	sd	s5,40(sp)
    80004ce8:	f05a                	sd	s6,32(sp)
    80004cea:	ec5e                	sd	s7,24(sp)
    80004cec:	e862                	sd	s8,16(sp)
    80004cee:	1080                	addi	s0,sp,96
    80004cf0:	84aa                	mv	s1,a0
    80004cf2:	8aae                	mv	s5,a1
    80004cf4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004cf6:	ffffd097          	auipc	ra,0xffffd
    80004cfa:	c8a080e7          	jalr	-886(ra) # 80001980 <myproc>
    80004cfe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d00:	8526                	mv	a0,s1
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	ed4080e7          	jalr	-300(ra) # 80000bd6 <acquire>
  while(i < n){
    80004d0a:	0b405663          	blez	s4,80004db6 <pipewrite+0xde>
  int i = 0;
    80004d0e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d10:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d12:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d16:	21c48b93          	addi	s7,s1,540
    80004d1a:	a089                	j	80004d5c <pipewrite+0x84>
      release(&pi->lock);
    80004d1c:	8526                	mv	a0,s1
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	f6c080e7          	jalr	-148(ra) # 80000c8a <release>
      return -1;
    80004d26:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d28:	854a                	mv	a0,s2
    80004d2a:	60e6                	ld	ra,88(sp)
    80004d2c:	6446                	ld	s0,80(sp)
    80004d2e:	64a6                	ld	s1,72(sp)
    80004d30:	6906                	ld	s2,64(sp)
    80004d32:	79e2                	ld	s3,56(sp)
    80004d34:	7a42                	ld	s4,48(sp)
    80004d36:	7aa2                	ld	s5,40(sp)
    80004d38:	7b02                	ld	s6,32(sp)
    80004d3a:	6be2                	ld	s7,24(sp)
    80004d3c:	6c42                	ld	s8,16(sp)
    80004d3e:	6125                	addi	sp,sp,96
    80004d40:	8082                	ret
      wakeup(&pi->nread);
    80004d42:	8562                	mv	a0,s8
    80004d44:	ffffd097          	auipc	ra,0xffffd
    80004d48:	478080e7          	jalr	1144(ra) # 800021bc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d4c:	85a6                	mv	a1,s1
    80004d4e:	855e                	mv	a0,s7
    80004d50:	ffffd097          	auipc	ra,0xffffd
    80004d54:	3ec080e7          	jalr	1004(ra) # 8000213c <sleep>
  while(i < n){
    80004d58:	07495063          	bge	s2,s4,80004db8 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d5c:	2204a783          	lw	a5,544(s1)
    80004d60:	dfd5                	beqz	a5,80004d1c <pipewrite+0x44>
    80004d62:	854e                	mv	a0,s3
    80004d64:	ffffd097          	auipc	ra,0xffffd
    80004d68:	6ee080e7          	jalr	1774(ra) # 80002452 <killed>
    80004d6c:	f945                	bnez	a0,80004d1c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d6e:	2184a783          	lw	a5,536(s1)
    80004d72:	21c4a703          	lw	a4,540(s1)
    80004d76:	2007879b          	addiw	a5,a5,512
    80004d7a:	fcf704e3          	beq	a4,a5,80004d42 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d7e:	4685                	li	a3,1
    80004d80:	01590633          	add	a2,s2,s5
    80004d84:	faf40593          	addi	a1,s0,-81
    80004d88:	1009b503          	ld	a0,256(s3)
    80004d8c:	ffffd097          	auipc	ra,0xffffd
    80004d90:	968080e7          	jalr	-1688(ra) # 800016f4 <copyin>
    80004d94:	03650263          	beq	a0,s6,80004db8 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d98:	21c4a783          	lw	a5,540(s1)
    80004d9c:	0017871b          	addiw	a4,a5,1
    80004da0:	20e4ae23          	sw	a4,540(s1)
    80004da4:	1ff7f793          	andi	a5,a5,511
    80004da8:	97a6                	add	a5,a5,s1
    80004daa:	faf44703          	lbu	a4,-81(s0)
    80004dae:	00e78c23          	sb	a4,24(a5)
      i++;
    80004db2:	2905                	addiw	s2,s2,1
    80004db4:	b755                	j	80004d58 <pipewrite+0x80>
  int i = 0;
    80004db6:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004db8:	21848513          	addi	a0,s1,536
    80004dbc:	ffffd097          	auipc	ra,0xffffd
    80004dc0:	400080e7          	jalr	1024(ra) # 800021bc <wakeup>
  release(&pi->lock);
    80004dc4:	8526                	mv	a0,s1
    80004dc6:	ffffc097          	auipc	ra,0xffffc
    80004dca:	ec4080e7          	jalr	-316(ra) # 80000c8a <release>
  return i;
    80004dce:	bfa9                	j	80004d28 <pipewrite+0x50>

0000000080004dd0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004dd0:	715d                	addi	sp,sp,-80
    80004dd2:	e486                	sd	ra,72(sp)
    80004dd4:	e0a2                	sd	s0,64(sp)
    80004dd6:	fc26                	sd	s1,56(sp)
    80004dd8:	f84a                	sd	s2,48(sp)
    80004dda:	f44e                	sd	s3,40(sp)
    80004ddc:	f052                	sd	s4,32(sp)
    80004dde:	ec56                	sd	s5,24(sp)
    80004de0:	e85a                	sd	s6,16(sp)
    80004de2:	0880                	addi	s0,sp,80
    80004de4:	84aa                	mv	s1,a0
    80004de6:	892e                	mv	s2,a1
    80004de8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dea:	ffffd097          	auipc	ra,0xffffd
    80004dee:	b96080e7          	jalr	-1130(ra) # 80001980 <myproc>
    80004df2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004df4:	8526                	mv	a0,s1
    80004df6:	ffffc097          	auipc	ra,0xffffc
    80004dfa:	de0080e7          	jalr	-544(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dfe:	2184a703          	lw	a4,536(s1)
    80004e02:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e06:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e0a:	02f71763          	bne	a4,a5,80004e38 <piperead+0x68>
    80004e0e:	2244a783          	lw	a5,548(s1)
    80004e12:	c39d                	beqz	a5,80004e38 <piperead+0x68>
    if(killed(pr)){
    80004e14:	8552                	mv	a0,s4
    80004e16:	ffffd097          	auipc	ra,0xffffd
    80004e1a:	63c080e7          	jalr	1596(ra) # 80002452 <killed>
    80004e1e:	e941                	bnez	a0,80004eae <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e20:	85a6                	mv	a1,s1
    80004e22:	854e                	mv	a0,s3
    80004e24:	ffffd097          	auipc	ra,0xffffd
    80004e28:	318080e7          	jalr	792(ra) # 8000213c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e2c:	2184a703          	lw	a4,536(s1)
    80004e30:	21c4a783          	lw	a5,540(s1)
    80004e34:	fcf70de3          	beq	a4,a5,80004e0e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e38:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e3a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e3c:	05505363          	blez	s5,80004e82 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004e40:	2184a783          	lw	a5,536(s1)
    80004e44:	21c4a703          	lw	a4,540(s1)
    80004e48:	02f70d63          	beq	a4,a5,80004e82 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e4c:	0017871b          	addiw	a4,a5,1
    80004e50:	20e4ac23          	sw	a4,536(s1)
    80004e54:	1ff7f793          	andi	a5,a5,511
    80004e58:	97a6                	add	a5,a5,s1
    80004e5a:	0187c783          	lbu	a5,24(a5)
    80004e5e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e62:	4685                	li	a3,1
    80004e64:	fbf40613          	addi	a2,s0,-65
    80004e68:	85ca                	mv	a1,s2
    80004e6a:	100a3503          	ld	a0,256(s4)
    80004e6e:	ffffc097          	auipc	ra,0xffffc
    80004e72:	7fa080e7          	jalr	2042(ra) # 80001668 <copyout>
    80004e76:	01650663          	beq	a0,s6,80004e82 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e7a:	2985                	addiw	s3,s3,1
    80004e7c:	0905                	addi	s2,s2,1
    80004e7e:	fd3a91e3          	bne	s5,s3,80004e40 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e82:	21c48513          	addi	a0,s1,540
    80004e86:	ffffd097          	auipc	ra,0xffffd
    80004e8a:	336080e7          	jalr	822(ra) # 800021bc <wakeup>
  release(&pi->lock);
    80004e8e:	8526                	mv	a0,s1
    80004e90:	ffffc097          	auipc	ra,0xffffc
    80004e94:	dfa080e7          	jalr	-518(ra) # 80000c8a <release>
  return i;
}
    80004e98:	854e                	mv	a0,s3
    80004e9a:	60a6                	ld	ra,72(sp)
    80004e9c:	6406                	ld	s0,64(sp)
    80004e9e:	74e2                	ld	s1,56(sp)
    80004ea0:	7942                	ld	s2,48(sp)
    80004ea2:	79a2                	ld	s3,40(sp)
    80004ea4:	7a02                	ld	s4,32(sp)
    80004ea6:	6ae2                	ld	s5,24(sp)
    80004ea8:	6b42                	ld	s6,16(sp)
    80004eaa:	6161                	addi	sp,sp,80
    80004eac:	8082                	ret
      release(&pi->lock);
    80004eae:	8526                	mv	a0,s1
    80004eb0:	ffffc097          	auipc	ra,0xffffc
    80004eb4:	dda080e7          	jalr	-550(ra) # 80000c8a <release>
      return -1;
    80004eb8:	59fd                	li	s3,-1
    80004eba:	bff9                	j	80004e98 <piperead+0xc8>

0000000080004ebc <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004ebc:	1141                	addi	sp,sp,-16
    80004ebe:	e422                	sd	s0,8(sp)
    80004ec0:	0800                	addi	s0,sp,16
    80004ec2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004ec4:	8905                	andi	a0,a0,1
    80004ec6:	c111                	beqz	a0,80004eca <flags2perm+0xe>
      perm = PTE_X;
    80004ec8:	4521                	li	a0,8
    if(flags & 0x2)
    80004eca:	8b89                	andi	a5,a5,2
    80004ecc:	c399                	beqz	a5,80004ed2 <flags2perm+0x16>
      perm |= PTE_W;
    80004ece:	00456513          	ori	a0,a0,4
    return perm;
}
    80004ed2:	6422                	ld	s0,8(sp)
    80004ed4:	0141                	addi	sp,sp,16
    80004ed6:	8082                	ret

0000000080004ed8 <exec>:

int
exec(char *path, char **argv)
{
    80004ed8:	de010113          	addi	sp,sp,-544
    80004edc:	20113c23          	sd	ra,536(sp)
    80004ee0:	20813823          	sd	s0,528(sp)
    80004ee4:	20913423          	sd	s1,520(sp)
    80004ee8:	21213023          	sd	s2,512(sp)
    80004eec:	ffce                	sd	s3,504(sp)
    80004eee:	fbd2                	sd	s4,496(sp)
    80004ef0:	f7d6                	sd	s5,488(sp)
    80004ef2:	f3da                	sd	s6,480(sp)
    80004ef4:	efde                	sd	s7,472(sp)
    80004ef6:	ebe2                	sd	s8,464(sp)
    80004ef8:	e7e6                	sd	s9,456(sp)
    80004efa:	e3ea                	sd	s10,448(sp)
    80004efc:	ff6e                	sd	s11,440(sp)
    80004efe:	1400                	addi	s0,sp,544
    80004f00:	892a                	mv	s2,a0
    80004f02:	dea43423          	sd	a0,-536(s0)
    80004f06:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f0a:	ffffd097          	auipc	ra,0xffffd
    80004f0e:	a76080e7          	jalr	-1418(ra) # 80001980 <myproc>
    80004f12:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80004f14:	ffffe097          	auipc	ra,0xffffe
    80004f18:	86e080e7          	jalr	-1938(ra) # 80002782 <mykthread>

  begin_op();
    80004f1c:	fffff097          	auipc	ra,0xfffff
    80004f20:	476080e7          	jalr	1142(ra) # 80004392 <begin_op>

  if((ip = namei(path)) == 0){
    80004f24:	854a                	mv	a0,s2
    80004f26:	fffff097          	auipc	ra,0xfffff
    80004f2a:	250080e7          	jalr	592(ra) # 80004176 <namei>
    80004f2e:	c93d                	beqz	a0,80004fa4 <exec+0xcc>
    80004f30:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f32:	fffff097          	auipc	ra,0xfffff
    80004f36:	a9e080e7          	jalr	-1378(ra) # 800039d0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f3a:	04000713          	li	a4,64
    80004f3e:	4681                	li	a3,0
    80004f40:	e5040613          	addi	a2,s0,-432
    80004f44:	4581                	li	a1,0
    80004f46:	8556                	mv	a0,s5
    80004f48:	fffff097          	auipc	ra,0xfffff
    80004f4c:	d3c080e7          	jalr	-708(ra) # 80003c84 <readi>
    80004f50:	04000793          	li	a5,64
    80004f54:	00f51a63          	bne	a0,a5,80004f68 <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f58:	e5042703          	lw	a4,-432(s0)
    80004f5c:	464c47b7          	lui	a5,0x464c4
    80004f60:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f64:	04f70663          	beq	a4,a5,80004fb0 <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f68:	8556                	mv	a0,s5
    80004f6a:	fffff097          	auipc	ra,0xfffff
    80004f6e:	cc8080e7          	jalr	-824(ra) # 80003c32 <iunlockput>
    end_op();
    80004f72:	fffff097          	auipc	ra,0xfffff
    80004f76:	4a0080e7          	jalr	1184(ra) # 80004412 <end_op>
  }
  return -1;
    80004f7a:	557d                	li	a0,-1
}
    80004f7c:	21813083          	ld	ra,536(sp)
    80004f80:	21013403          	ld	s0,528(sp)
    80004f84:	20813483          	ld	s1,520(sp)
    80004f88:	20013903          	ld	s2,512(sp)
    80004f8c:	79fe                	ld	s3,504(sp)
    80004f8e:	7a5e                	ld	s4,496(sp)
    80004f90:	7abe                	ld	s5,488(sp)
    80004f92:	7b1e                	ld	s6,480(sp)
    80004f94:	6bfe                	ld	s7,472(sp)
    80004f96:	6c5e                	ld	s8,464(sp)
    80004f98:	6cbe                	ld	s9,456(sp)
    80004f9a:	6d1e                	ld	s10,448(sp)
    80004f9c:	7dfa                	ld	s11,440(sp)
    80004f9e:	22010113          	addi	sp,sp,544
    80004fa2:	8082                	ret
    end_op();
    80004fa4:	fffff097          	auipc	ra,0xfffff
    80004fa8:	46e080e7          	jalr	1134(ra) # 80004412 <end_op>
    return -1;
    80004fac:	557d                	li	a0,-1
    80004fae:	b7f9                	j	80004f7c <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    80004fb0:	8526                	mv	a0,s1
    80004fb2:	ffffd097          	auipc	ra,0xffffd
    80004fb6:	a6a080e7          	jalr	-1430(ra) # 80001a1c <proc_pagetable>
    80004fba:	8b2a                	mv	s6,a0
    80004fbc:	d555                	beqz	a0,80004f68 <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fbe:	e7042783          	lw	a5,-400(s0)
    80004fc2:	e8845703          	lhu	a4,-376(s0)
    80004fc6:	c735                	beqz	a4,80005032 <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fc8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fca:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004fce:	6a05                	lui	s4,0x1
    80004fd0:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004fd4:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004fd8:	6d85                	lui	s11,0x1
    80004fda:	7d7d                	lui	s10,0xfffff
    80004fdc:	a4a9                	j	80005226 <exec+0x34e>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004fde:	00003517          	auipc	a0,0x3
    80004fe2:	6f250513          	addi	a0,a0,1778 # 800086d0 <syscalls+0x280>
    80004fe6:	ffffb097          	auipc	ra,0xffffb
    80004fea:	558080e7          	jalr	1368(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fee:	874a                	mv	a4,s2
    80004ff0:	009c86bb          	addw	a3,s9,s1
    80004ff4:	4581                	li	a1,0
    80004ff6:	8556                	mv	a0,s5
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	c8c080e7          	jalr	-884(ra) # 80003c84 <readi>
    80005000:	2501                	sext.w	a0,a0
    80005002:	1aa91f63          	bne	s2,a0,800051c0 <exec+0x2e8>
  for(i = 0; i < sz; i += PGSIZE){
    80005006:	009d84bb          	addw	s1,s11,s1
    8000500a:	013d09bb          	addw	s3,s10,s3
    8000500e:	1f74fc63          	bgeu	s1,s7,80005206 <exec+0x32e>
    pa = walkaddr(pagetable, va + i);
    80005012:	02049593          	slli	a1,s1,0x20
    80005016:	9181                	srli	a1,a1,0x20
    80005018:	95e2                	add	a1,a1,s8
    8000501a:	855a                	mv	a0,s6
    8000501c:	ffffc097          	auipc	ra,0xffffc
    80005020:	040080e7          	jalr	64(ra) # 8000105c <walkaddr>
    80005024:	862a                	mv	a2,a0
    if(pa == 0)
    80005026:	dd45                	beqz	a0,80004fde <exec+0x106>
      n = PGSIZE;
    80005028:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000502a:	fd49f2e3          	bgeu	s3,s4,80004fee <exec+0x116>
      n = sz - i;
    8000502e:	894e                	mv	s2,s3
    80005030:	bf7d                	j	80004fee <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005032:	4901                	li	s2,0
  iunlockput(ip);
    80005034:	8556                	mv	a0,s5
    80005036:	fffff097          	auipc	ra,0xfffff
    8000503a:	bfc080e7          	jalr	-1028(ra) # 80003c32 <iunlockput>
  end_op();
    8000503e:	fffff097          	auipc	ra,0xfffff
    80005042:	3d4080e7          	jalr	980(ra) # 80004412 <end_op>
  p = myproc();
    80005046:	ffffd097          	auipc	ra,0xffffd
    8000504a:	93a080e7          	jalr	-1734(ra) # 80001980 <myproc>
    8000504e:	8baa                	mv	s7,a0
  kt = mykthread();
    80005050:	ffffd097          	auipc	ra,0xffffd
    80005054:	732080e7          	jalr	1842(ra) # 80002782 <mykthread>
    80005058:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    8000505a:	0f8bbd83          	ld	s11,248(s7) # 10f8 <_entry-0x7fffef08>
  sz = PGROUNDUP(sz);
    8000505e:	6785                	lui	a5,0x1
    80005060:	17fd                	addi	a5,a5,-1
    80005062:	993e                	add	s2,s2,a5
    80005064:	77fd                	lui	a5,0xfffff
    80005066:	00f977b3          	and	a5,s2,a5
    8000506a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000506e:	4691                	li	a3,4
    80005070:	6609                	lui	a2,0x2
    80005072:	963e                	add	a2,a2,a5
    80005074:	85be                	mv	a1,a5
    80005076:	855a                	mv	a0,s6
    80005078:	ffffc097          	auipc	ra,0xffffc
    8000507c:	398080e7          	jalr	920(ra) # 80001410 <uvmalloc>
    80005080:	8c2a                	mv	s8,a0
  ip = 0;
    80005082:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005084:	12050e63          	beqz	a0,800051c0 <exec+0x2e8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005088:	75f9                	lui	a1,0xffffe
    8000508a:	95aa                	add	a1,a1,a0
    8000508c:	855a                	mv	a0,s6
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	5a8080e7          	jalr	1448(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005096:	7afd                	lui	s5,0xfffff
    80005098:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000509a:	df043783          	ld	a5,-528(s0)
    8000509e:	6388                	ld	a0,0(a5)
    800050a0:	c925                	beqz	a0,80005110 <exec+0x238>
    800050a2:	e9040993          	addi	s3,s0,-368
    800050a6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800050aa:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050ac:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050ae:	ffffc097          	auipc	ra,0xffffc
    800050b2:	da0080e7          	jalr	-608(ra) # 80000e4e <strlen>
    800050b6:	0015079b          	addiw	a5,a0,1
    800050ba:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050be:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800050c2:	13596663          	bltu	s2,s5,800051ee <exec+0x316>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050c6:	df043783          	ld	a5,-528(s0)
    800050ca:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffdbca0>
    800050ce:	8552                	mv	a0,s4
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	d7e080e7          	jalr	-642(ra) # 80000e4e <strlen>
    800050d8:	0015069b          	addiw	a3,a0,1
    800050dc:	8652                	mv	a2,s4
    800050de:	85ca                	mv	a1,s2
    800050e0:	855a                	mv	a0,s6
    800050e2:	ffffc097          	auipc	ra,0xffffc
    800050e6:	586080e7          	jalr	1414(ra) # 80001668 <copyout>
    800050ea:	10054663          	bltz	a0,800051f6 <exec+0x31e>
    ustack[argc] = sp;
    800050ee:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050f2:	0485                	addi	s1,s1,1
    800050f4:	df043783          	ld	a5,-528(s0)
    800050f8:	07a1                	addi	a5,a5,8
    800050fa:	def43823          	sd	a5,-528(s0)
    800050fe:	6388                	ld	a0,0(a5)
    80005100:	c911                	beqz	a0,80005114 <exec+0x23c>
    if(argc >= MAXARG)
    80005102:	09a1                	addi	s3,s3,8
    80005104:	fb3c95e3          	bne	s9,s3,800050ae <exec+0x1d6>
  sz = sz1;
    80005108:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000510c:	4a81                	li	s5,0
    8000510e:	a84d                	j	800051c0 <exec+0x2e8>
  sp = sz;
    80005110:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005112:	4481                	li	s1,0
  ustack[argc] = 0;
    80005114:	00349793          	slli	a5,s1,0x3
    80005118:	f9040713          	addi	a4,s0,-112
    8000511c:	97ba                	add	a5,a5,a4
    8000511e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005122:	00148693          	addi	a3,s1,1
    80005126:	068e                	slli	a3,a3,0x3
    80005128:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000512c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005130:	01597663          	bgeu	s2,s5,8000513c <exec+0x264>
  sz = sz1;
    80005134:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005138:	4a81                	li	s5,0
    8000513a:	a059                	j	800051c0 <exec+0x2e8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000513c:	e9040613          	addi	a2,s0,-368
    80005140:	85ca                	mv	a1,s2
    80005142:	855a                	mv	a0,s6
    80005144:	ffffc097          	auipc	ra,0xffffc
    80005148:	524080e7          	jalr	1316(ra) # 80001668 <copyout>
    8000514c:	0a054963          	bltz	a0,800051fe <exec+0x326>
  kt->trapframe->a1 = sp;
    80005150:	0b8d3783          	ld	a5,184(s10) # fffffffffffff0b8 <end+0xffffffff7ffdbd58>
    80005154:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005158:	de843783          	ld	a5,-536(s0)
    8000515c:	0007c703          	lbu	a4,0(a5)
    80005160:	cf11                	beqz	a4,8000517c <exec+0x2a4>
    80005162:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005164:	02f00693          	li	a3,47
    80005168:	a039                	j	80005176 <exec+0x29e>
      last = s+1;
    8000516a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000516e:	0785                	addi	a5,a5,1
    80005170:	fff7c703          	lbu	a4,-1(a5)
    80005174:	c701                	beqz	a4,8000517c <exec+0x2a4>
    if(*s == '/')
    80005176:	fed71ce3          	bne	a4,a3,8000516e <exec+0x296>
    8000517a:	bfc5                	j	8000516a <exec+0x292>
  safestrcpy(p->name, last, sizeof(p->name));
    8000517c:	4641                	li	a2,16
    8000517e:	de843583          	ld	a1,-536(s0)
    80005182:	190b8513          	addi	a0,s7,400
    80005186:	ffffc097          	auipc	ra,0xffffc
    8000518a:	c96080e7          	jalr	-874(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000518e:	100bb503          	ld	a0,256(s7)
  p->pagetable = pagetable;
    80005192:	116bb023          	sd	s6,256(s7)
  p->sz = sz;
    80005196:	0f8bbc23          	sd	s8,248(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    8000519a:	0b8d3783          	ld	a5,184(s10)
    8000519e:	e6843703          	ld	a4,-408(s0)
    800051a2:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    800051a4:	0b8d3783          	ld	a5,184(s10)
    800051a8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051ac:	85ee                	mv	a1,s11
    800051ae:	ffffd097          	auipc	ra,0xffffd
    800051b2:	90a080e7          	jalr	-1782(ra) # 80001ab8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051b6:	0004851b          	sext.w	a0,s1
    800051ba:	b3c9                	j	80004f7c <exec+0xa4>
    800051bc:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051c0:	df843583          	ld	a1,-520(s0)
    800051c4:	855a                	mv	a0,s6
    800051c6:	ffffd097          	auipc	ra,0xffffd
    800051ca:	8f2080e7          	jalr	-1806(ra) # 80001ab8 <proc_freepagetable>
  if(ip){
    800051ce:	d80a9de3          	bnez	s5,80004f68 <exec+0x90>
  return -1;
    800051d2:	557d                	li	a0,-1
    800051d4:	b365                	j	80004f7c <exec+0xa4>
    800051d6:	df243c23          	sd	s2,-520(s0)
    800051da:	b7dd                	j	800051c0 <exec+0x2e8>
    800051dc:	df243c23          	sd	s2,-520(s0)
    800051e0:	b7c5                	j	800051c0 <exec+0x2e8>
    800051e2:	df243c23          	sd	s2,-520(s0)
    800051e6:	bfe9                	j	800051c0 <exec+0x2e8>
    800051e8:	df243c23          	sd	s2,-520(s0)
    800051ec:	bfd1                	j	800051c0 <exec+0x2e8>
  sz = sz1;
    800051ee:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051f2:	4a81                	li	s5,0
    800051f4:	b7f1                	j	800051c0 <exec+0x2e8>
  sz = sz1;
    800051f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051fa:	4a81                	li	s5,0
    800051fc:	b7d1                	j	800051c0 <exec+0x2e8>
  sz = sz1;
    800051fe:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005202:	4a81                	li	s5,0
    80005204:	bf75                	j	800051c0 <exec+0x2e8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005206:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000520a:	e0843783          	ld	a5,-504(s0)
    8000520e:	0017869b          	addiw	a3,a5,1
    80005212:	e0d43423          	sd	a3,-504(s0)
    80005216:	e0043783          	ld	a5,-512(s0)
    8000521a:	0387879b          	addiw	a5,a5,56
    8000521e:	e8845703          	lhu	a4,-376(s0)
    80005222:	e0e6d9e3          	bge	a3,a4,80005034 <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005226:	2781                	sext.w	a5,a5
    80005228:	e0f43023          	sd	a5,-512(s0)
    8000522c:	03800713          	li	a4,56
    80005230:	86be                	mv	a3,a5
    80005232:	e1840613          	addi	a2,s0,-488
    80005236:	4581                	li	a1,0
    80005238:	8556                	mv	a0,s5
    8000523a:	fffff097          	auipc	ra,0xfffff
    8000523e:	a4a080e7          	jalr	-1462(ra) # 80003c84 <readi>
    80005242:	03800793          	li	a5,56
    80005246:	f6f51be3          	bne	a0,a5,800051bc <exec+0x2e4>
    if(ph.type != ELF_PROG_LOAD)
    8000524a:	e1842783          	lw	a5,-488(s0)
    8000524e:	4705                	li	a4,1
    80005250:	fae79de3          	bne	a5,a4,8000520a <exec+0x332>
    if(ph.memsz < ph.filesz)
    80005254:	e4043483          	ld	s1,-448(s0)
    80005258:	e3843783          	ld	a5,-456(s0)
    8000525c:	f6f4ede3          	bltu	s1,a5,800051d6 <exec+0x2fe>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005260:	e2843783          	ld	a5,-472(s0)
    80005264:	94be                	add	s1,s1,a5
    80005266:	f6f4ebe3          	bltu	s1,a5,800051dc <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    8000526a:	de043703          	ld	a4,-544(s0)
    8000526e:	8ff9                	and	a5,a5,a4
    80005270:	fbad                	bnez	a5,800051e2 <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005272:	e1c42503          	lw	a0,-484(s0)
    80005276:	00000097          	auipc	ra,0x0
    8000527a:	c46080e7          	jalr	-954(ra) # 80004ebc <flags2perm>
    8000527e:	86aa                	mv	a3,a0
    80005280:	8626                	mv	a2,s1
    80005282:	85ca                	mv	a1,s2
    80005284:	855a                	mv	a0,s6
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	18a080e7          	jalr	394(ra) # 80001410 <uvmalloc>
    8000528e:	dea43c23          	sd	a0,-520(s0)
    80005292:	d939                	beqz	a0,800051e8 <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005294:	e2843c03          	ld	s8,-472(s0)
    80005298:	e2042c83          	lw	s9,-480(s0)
    8000529c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052a0:	f60b83e3          	beqz	s7,80005206 <exec+0x32e>
    800052a4:	89de                	mv	s3,s7
    800052a6:	4481                	li	s1,0
    800052a8:	b3ad                	j	80005012 <exec+0x13a>

00000000800052aa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052aa:	7179                	addi	sp,sp,-48
    800052ac:	f406                	sd	ra,40(sp)
    800052ae:	f022                	sd	s0,32(sp)
    800052b0:	ec26                	sd	s1,24(sp)
    800052b2:	e84a                	sd	s2,16(sp)
    800052b4:	1800                	addi	s0,sp,48
    800052b6:	892e                	mv	s2,a1
    800052b8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800052ba:	fdc40593          	addi	a1,s0,-36
    800052be:	ffffe097          	auipc	ra,0xffffe
    800052c2:	b96080e7          	jalr	-1130(ra) # 80002e54 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052c6:	fdc42703          	lw	a4,-36(s0)
    800052ca:	47bd                	li	a5,15
    800052cc:	02e7eb63          	bltu	a5,a4,80005302 <argfd+0x58>
    800052d0:	ffffc097          	auipc	ra,0xffffc
    800052d4:	6b0080e7          	jalr	1712(ra) # 80001980 <myproc>
    800052d8:	fdc42703          	lw	a4,-36(s0)
    800052dc:	02070793          	addi	a5,a4,32
    800052e0:	078e                	slli	a5,a5,0x3
    800052e2:	953e                	add	a0,a0,a5
    800052e4:	651c                	ld	a5,8(a0)
    800052e6:	c385                	beqz	a5,80005306 <argfd+0x5c>
    return -1;
  if(pfd)
    800052e8:	00090463          	beqz	s2,800052f0 <argfd+0x46>
    *pfd = fd;
    800052ec:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052f0:	4501                	li	a0,0
  if(pf)
    800052f2:	c091                	beqz	s1,800052f6 <argfd+0x4c>
    *pf = f;
    800052f4:	e09c                	sd	a5,0(s1)
}
    800052f6:	70a2                	ld	ra,40(sp)
    800052f8:	7402                	ld	s0,32(sp)
    800052fa:	64e2                	ld	s1,24(sp)
    800052fc:	6942                	ld	s2,16(sp)
    800052fe:	6145                	addi	sp,sp,48
    80005300:	8082                	ret
    return -1;
    80005302:	557d                	li	a0,-1
    80005304:	bfcd                	j	800052f6 <argfd+0x4c>
    80005306:	557d                	li	a0,-1
    80005308:	b7fd                	j	800052f6 <argfd+0x4c>

000000008000530a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000530a:	1101                	addi	sp,sp,-32
    8000530c:	ec06                	sd	ra,24(sp)
    8000530e:	e822                	sd	s0,16(sp)
    80005310:	e426                	sd	s1,8(sp)
    80005312:	1000                	addi	s0,sp,32
    80005314:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005316:	ffffc097          	auipc	ra,0xffffc
    8000531a:	66a080e7          	jalr	1642(ra) # 80001980 <myproc>
    8000531e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005320:	10850793          	addi	a5,a0,264
    80005324:	4501                	li	a0,0
    80005326:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005328:	6398                	ld	a4,0(a5)
    8000532a:	cb19                	beqz	a4,80005340 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000532c:	2505                	addiw	a0,a0,1
    8000532e:	07a1                	addi	a5,a5,8
    80005330:	fed51ce3          	bne	a0,a3,80005328 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005334:	557d                	li	a0,-1
}
    80005336:	60e2                	ld	ra,24(sp)
    80005338:	6442                	ld	s0,16(sp)
    8000533a:	64a2                	ld	s1,8(sp)
    8000533c:	6105                	addi	sp,sp,32
    8000533e:	8082                	ret
      p->ofile[fd] = f;
    80005340:	02050793          	addi	a5,a0,32
    80005344:	078e                	slli	a5,a5,0x3
    80005346:	963e                	add	a2,a2,a5
    80005348:	e604                	sd	s1,8(a2)
      return fd;
    8000534a:	b7f5                	j	80005336 <fdalloc+0x2c>

000000008000534c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000534c:	715d                	addi	sp,sp,-80
    8000534e:	e486                	sd	ra,72(sp)
    80005350:	e0a2                	sd	s0,64(sp)
    80005352:	fc26                	sd	s1,56(sp)
    80005354:	f84a                	sd	s2,48(sp)
    80005356:	f44e                	sd	s3,40(sp)
    80005358:	f052                	sd	s4,32(sp)
    8000535a:	ec56                	sd	s5,24(sp)
    8000535c:	e85a                	sd	s6,16(sp)
    8000535e:	0880                	addi	s0,sp,80
    80005360:	8b2e                	mv	s6,a1
    80005362:	89b2                	mv	s3,a2
    80005364:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005366:	fb040593          	addi	a1,s0,-80
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	e2a080e7          	jalr	-470(ra) # 80004194 <nameiparent>
    80005372:	84aa                	mv	s1,a0
    80005374:	14050f63          	beqz	a0,800054d2 <create+0x186>
    return 0;

  ilock(dp);
    80005378:	ffffe097          	auipc	ra,0xffffe
    8000537c:	658080e7          	jalr	1624(ra) # 800039d0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005380:	4601                	li	a2,0
    80005382:	fb040593          	addi	a1,s0,-80
    80005386:	8526                	mv	a0,s1
    80005388:	fffff097          	auipc	ra,0xfffff
    8000538c:	b2c080e7          	jalr	-1236(ra) # 80003eb4 <dirlookup>
    80005390:	8aaa                	mv	s5,a0
    80005392:	c931                	beqz	a0,800053e6 <create+0x9a>
    iunlockput(dp);
    80005394:	8526                	mv	a0,s1
    80005396:	fffff097          	auipc	ra,0xfffff
    8000539a:	89c080e7          	jalr	-1892(ra) # 80003c32 <iunlockput>
    ilock(ip);
    8000539e:	8556                	mv	a0,s5
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	630080e7          	jalr	1584(ra) # 800039d0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053a8:	000b059b          	sext.w	a1,s6
    800053ac:	4789                	li	a5,2
    800053ae:	02f59563          	bne	a1,a5,800053d8 <create+0x8c>
    800053b2:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbce4>
    800053b6:	37f9                	addiw	a5,a5,-2
    800053b8:	17c2                	slli	a5,a5,0x30
    800053ba:	93c1                	srli	a5,a5,0x30
    800053bc:	4705                	li	a4,1
    800053be:	00f76d63          	bltu	a4,a5,800053d8 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800053c2:	8556                	mv	a0,s5
    800053c4:	60a6                	ld	ra,72(sp)
    800053c6:	6406                	ld	s0,64(sp)
    800053c8:	74e2                	ld	s1,56(sp)
    800053ca:	7942                	ld	s2,48(sp)
    800053cc:	79a2                	ld	s3,40(sp)
    800053ce:	7a02                	ld	s4,32(sp)
    800053d0:	6ae2                	ld	s5,24(sp)
    800053d2:	6b42                	ld	s6,16(sp)
    800053d4:	6161                	addi	sp,sp,80
    800053d6:	8082                	ret
    iunlockput(ip);
    800053d8:	8556                	mv	a0,s5
    800053da:	fffff097          	auipc	ra,0xfffff
    800053de:	858080e7          	jalr	-1960(ra) # 80003c32 <iunlockput>
    return 0;
    800053e2:	4a81                	li	s5,0
    800053e4:	bff9                	j	800053c2 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800053e6:	85da                	mv	a1,s6
    800053e8:	4088                	lw	a0,0(s1)
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	44a080e7          	jalr	1098(ra) # 80003834 <ialloc>
    800053f2:	8a2a                	mv	s4,a0
    800053f4:	c539                	beqz	a0,80005442 <create+0xf6>
  ilock(ip);
    800053f6:	ffffe097          	auipc	ra,0xffffe
    800053fa:	5da080e7          	jalr	1498(ra) # 800039d0 <ilock>
  ip->major = major;
    800053fe:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005402:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005406:	4905                	li	s2,1
    80005408:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000540c:	8552                	mv	a0,s4
    8000540e:	ffffe097          	auipc	ra,0xffffe
    80005412:	4f8080e7          	jalr	1272(ra) # 80003906 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005416:	000b059b          	sext.w	a1,s6
    8000541a:	03258b63          	beq	a1,s2,80005450 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000541e:	004a2603          	lw	a2,4(s4)
    80005422:	fb040593          	addi	a1,s0,-80
    80005426:	8526                	mv	a0,s1
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	c9c080e7          	jalr	-868(ra) # 800040c4 <dirlink>
    80005430:	06054f63          	bltz	a0,800054ae <create+0x162>
  iunlockput(dp);
    80005434:	8526                	mv	a0,s1
    80005436:	ffffe097          	auipc	ra,0xffffe
    8000543a:	7fc080e7          	jalr	2044(ra) # 80003c32 <iunlockput>
  return ip;
    8000543e:	8ad2                	mv	s5,s4
    80005440:	b749                	j	800053c2 <create+0x76>
    iunlockput(dp);
    80005442:	8526                	mv	a0,s1
    80005444:	ffffe097          	auipc	ra,0xffffe
    80005448:	7ee080e7          	jalr	2030(ra) # 80003c32 <iunlockput>
    return 0;
    8000544c:	8ad2                	mv	s5,s4
    8000544e:	bf95                	j	800053c2 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005450:	004a2603          	lw	a2,4(s4)
    80005454:	00003597          	auipc	a1,0x3
    80005458:	29c58593          	addi	a1,a1,668 # 800086f0 <syscalls+0x2a0>
    8000545c:	8552                	mv	a0,s4
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	c66080e7          	jalr	-922(ra) # 800040c4 <dirlink>
    80005466:	04054463          	bltz	a0,800054ae <create+0x162>
    8000546a:	40d0                	lw	a2,4(s1)
    8000546c:	00003597          	auipc	a1,0x3
    80005470:	28c58593          	addi	a1,a1,652 # 800086f8 <syscalls+0x2a8>
    80005474:	8552                	mv	a0,s4
    80005476:	fffff097          	auipc	ra,0xfffff
    8000547a:	c4e080e7          	jalr	-946(ra) # 800040c4 <dirlink>
    8000547e:	02054863          	bltz	a0,800054ae <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005482:	004a2603          	lw	a2,4(s4)
    80005486:	fb040593          	addi	a1,s0,-80
    8000548a:	8526                	mv	a0,s1
    8000548c:	fffff097          	auipc	ra,0xfffff
    80005490:	c38080e7          	jalr	-968(ra) # 800040c4 <dirlink>
    80005494:	00054d63          	bltz	a0,800054ae <create+0x162>
    dp->nlink++;  // for ".."
    80005498:	04a4d783          	lhu	a5,74(s1)
    8000549c:	2785                	addiw	a5,a5,1
    8000549e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054a2:	8526                	mv	a0,s1
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	462080e7          	jalr	1122(ra) # 80003906 <iupdate>
    800054ac:	b761                	j	80005434 <create+0xe8>
  ip->nlink = 0;
    800054ae:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800054b2:	8552                	mv	a0,s4
    800054b4:	ffffe097          	auipc	ra,0xffffe
    800054b8:	452080e7          	jalr	1106(ra) # 80003906 <iupdate>
  iunlockput(ip);
    800054bc:	8552                	mv	a0,s4
    800054be:	ffffe097          	auipc	ra,0xffffe
    800054c2:	774080e7          	jalr	1908(ra) # 80003c32 <iunlockput>
  iunlockput(dp);
    800054c6:	8526                	mv	a0,s1
    800054c8:	ffffe097          	auipc	ra,0xffffe
    800054cc:	76a080e7          	jalr	1898(ra) # 80003c32 <iunlockput>
  return 0;
    800054d0:	bdcd                	j	800053c2 <create+0x76>
    return 0;
    800054d2:	8aaa                	mv	s5,a0
    800054d4:	b5fd                	j	800053c2 <create+0x76>

00000000800054d6 <sys_dup>:
{
    800054d6:	7179                	addi	sp,sp,-48
    800054d8:	f406                	sd	ra,40(sp)
    800054da:	f022                	sd	s0,32(sp)
    800054dc:	ec26                	sd	s1,24(sp)
    800054de:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054e0:	fd840613          	addi	a2,s0,-40
    800054e4:	4581                	li	a1,0
    800054e6:	4501                	li	a0,0
    800054e8:	00000097          	auipc	ra,0x0
    800054ec:	dc2080e7          	jalr	-574(ra) # 800052aa <argfd>
    return -1;
    800054f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054f2:	02054363          	bltz	a0,80005518 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800054f6:	fd843503          	ld	a0,-40(s0)
    800054fa:	00000097          	auipc	ra,0x0
    800054fe:	e10080e7          	jalr	-496(ra) # 8000530a <fdalloc>
    80005502:	84aa                	mv	s1,a0
    return -1;
    80005504:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005506:	00054963          	bltz	a0,80005518 <sys_dup+0x42>
  filedup(f);
    8000550a:	fd843503          	ld	a0,-40(s0)
    8000550e:	fffff097          	auipc	ra,0xfffff
    80005512:	2fe080e7          	jalr	766(ra) # 8000480c <filedup>
  return fd;
    80005516:	87a6                	mv	a5,s1
}
    80005518:	853e                	mv	a0,a5
    8000551a:	70a2                	ld	ra,40(sp)
    8000551c:	7402                	ld	s0,32(sp)
    8000551e:	64e2                	ld	s1,24(sp)
    80005520:	6145                	addi	sp,sp,48
    80005522:	8082                	ret

0000000080005524 <sys_read>:
{
    80005524:	7179                	addi	sp,sp,-48
    80005526:	f406                	sd	ra,40(sp)
    80005528:	f022                	sd	s0,32(sp)
    8000552a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000552c:	fd840593          	addi	a1,s0,-40
    80005530:	4505                	li	a0,1
    80005532:	ffffe097          	auipc	ra,0xffffe
    80005536:	942080e7          	jalr	-1726(ra) # 80002e74 <argaddr>
  argint(2, &n);
    8000553a:	fe440593          	addi	a1,s0,-28
    8000553e:	4509                	li	a0,2
    80005540:	ffffe097          	auipc	ra,0xffffe
    80005544:	914080e7          	jalr	-1772(ra) # 80002e54 <argint>
  if(argfd(0, 0, &f) < 0)
    80005548:	fe840613          	addi	a2,s0,-24
    8000554c:	4581                	li	a1,0
    8000554e:	4501                	li	a0,0
    80005550:	00000097          	auipc	ra,0x0
    80005554:	d5a080e7          	jalr	-678(ra) # 800052aa <argfd>
    80005558:	87aa                	mv	a5,a0
    return -1;
    8000555a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000555c:	0007cc63          	bltz	a5,80005574 <sys_read+0x50>
  return fileread(f, p, n);
    80005560:	fe442603          	lw	a2,-28(s0)
    80005564:	fd843583          	ld	a1,-40(s0)
    80005568:	fe843503          	ld	a0,-24(s0)
    8000556c:	fffff097          	auipc	ra,0xfffff
    80005570:	42c080e7          	jalr	1068(ra) # 80004998 <fileread>
}
    80005574:	70a2                	ld	ra,40(sp)
    80005576:	7402                	ld	s0,32(sp)
    80005578:	6145                	addi	sp,sp,48
    8000557a:	8082                	ret

000000008000557c <sys_write>:
{
    8000557c:	7179                	addi	sp,sp,-48
    8000557e:	f406                	sd	ra,40(sp)
    80005580:	f022                	sd	s0,32(sp)
    80005582:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005584:	fd840593          	addi	a1,s0,-40
    80005588:	4505                	li	a0,1
    8000558a:	ffffe097          	auipc	ra,0xffffe
    8000558e:	8ea080e7          	jalr	-1814(ra) # 80002e74 <argaddr>
  argint(2, &n);
    80005592:	fe440593          	addi	a1,s0,-28
    80005596:	4509                	li	a0,2
    80005598:	ffffe097          	auipc	ra,0xffffe
    8000559c:	8bc080e7          	jalr	-1860(ra) # 80002e54 <argint>
  if(argfd(0, 0, &f) < 0)
    800055a0:	fe840613          	addi	a2,s0,-24
    800055a4:	4581                	li	a1,0
    800055a6:	4501                	li	a0,0
    800055a8:	00000097          	auipc	ra,0x0
    800055ac:	d02080e7          	jalr	-766(ra) # 800052aa <argfd>
    800055b0:	87aa                	mv	a5,a0
    return -1;
    800055b2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055b4:	0007cc63          	bltz	a5,800055cc <sys_write+0x50>
  return filewrite(f, p, n);
    800055b8:	fe442603          	lw	a2,-28(s0)
    800055bc:	fd843583          	ld	a1,-40(s0)
    800055c0:	fe843503          	ld	a0,-24(s0)
    800055c4:	fffff097          	auipc	ra,0xfffff
    800055c8:	496080e7          	jalr	1174(ra) # 80004a5a <filewrite>
}
    800055cc:	70a2                	ld	ra,40(sp)
    800055ce:	7402                	ld	s0,32(sp)
    800055d0:	6145                	addi	sp,sp,48
    800055d2:	8082                	ret

00000000800055d4 <sys_close>:
{
    800055d4:	1101                	addi	sp,sp,-32
    800055d6:	ec06                	sd	ra,24(sp)
    800055d8:	e822                	sd	s0,16(sp)
    800055da:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055dc:	fe040613          	addi	a2,s0,-32
    800055e0:	fec40593          	addi	a1,s0,-20
    800055e4:	4501                	li	a0,0
    800055e6:	00000097          	auipc	ra,0x0
    800055ea:	cc4080e7          	jalr	-828(ra) # 800052aa <argfd>
    return -1;
    800055ee:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055f0:	02054563          	bltz	a0,8000561a <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    800055f4:	ffffc097          	auipc	ra,0xffffc
    800055f8:	38c080e7          	jalr	908(ra) # 80001980 <myproc>
    800055fc:	fec42783          	lw	a5,-20(s0)
    80005600:	02078793          	addi	a5,a5,32
    80005604:	078e                	slli	a5,a5,0x3
    80005606:	97aa                	add	a5,a5,a0
    80005608:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000560c:	fe043503          	ld	a0,-32(s0)
    80005610:	fffff097          	auipc	ra,0xfffff
    80005614:	24e080e7          	jalr	590(ra) # 8000485e <fileclose>
  return 0;
    80005618:	4781                	li	a5,0
}
    8000561a:	853e                	mv	a0,a5
    8000561c:	60e2                	ld	ra,24(sp)
    8000561e:	6442                	ld	s0,16(sp)
    80005620:	6105                	addi	sp,sp,32
    80005622:	8082                	ret

0000000080005624 <sys_fstat>:
{
    80005624:	1101                	addi	sp,sp,-32
    80005626:	ec06                	sd	ra,24(sp)
    80005628:	e822                	sd	s0,16(sp)
    8000562a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000562c:	fe040593          	addi	a1,s0,-32
    80005630:	4505                	li	a0,1
    80005632:	ffffe097          	auipc	ra,0xffffe
    80005636:	842080e7          	jalr	-1982(ra) # 80002e74 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000563a:	fe840613          	addi	a2,s0,-24
    8000563e:	4581                	li	a1,0
    80005640:	4501                	li	a0,0
    80005642:	00000097          	auipc	ra,0x0
    80005646:	c68080e7          	jalr	-920(ra) # 800052aa <argfd>
    8000564a:	87aa                	mv	a5,a0
    return -1;
    8000564c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000564e:	0007ca63          	bltz	a5,80005662 <sys_fstat+0x3e>
  return filestat(f, st);
    80005652:	fe043583          	ld	a1,-32(s0)
    80005656:	fe843503          	ld	a0,-24(s0)
    8000565a:	fffff097          	auipc	ra,0xfffff
    8000565e:	2cc080e7          	jalr	716(ra) # 80004926 <filestat>
}
    80005662:	60e2                	ld	ra,24(sp)
    80005664:	6442                	ld	s0,16(sp)
    80005666:	6105                	addi	sp,sp,32
    80005668:	8082                	ret

000000008000566a <sys_link>:
{
    8000566a:	7169                	addi	sp,sp,-304
    8000566c:	f606                	sd	ra,296(sp)
    8000566e:	f222                	sd	s0,288(sp)
    80005670:	ee26                	sd	s1,280(sp)
    80005672:	ea4a                	sd	s2,272(sp)
    80005674:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005676:	08000613          	li	a2,128
    8000567a:	ed040593          	addi	a1,s0,-304
    8000567e:	4501                	li	a0,0
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	814080e7          	jalr	-2028(ra) # 80002e94 <argstr>
    return -1;
    80005688:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000568a:	10054e63          	bltz	a0,800057a6 <sys_link+0x13c>
    8000568e:	08000613          	li	a2,128
    80005692:	f5040593          	addi	a1,s0,-176
    80005696:	4505                	li	a0,1
    80005698:	ffffd097          	auipc	ra,0xffffd
    8000569c:	7fc080e7          	jalr	2044(ra) # 80002e94 <argstr>
    return -1;
    800056a0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056a2:	10054263          	bltz	a0,800057a6 <sys_link+0x13c>
  begin_op();
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	cec080e7          	jalr	-788(ra) # 80004392 <begin_op>
  if((ip = namei(old)) == 0){
    800056ae:	ed040513          	addi	a0,s0,-304
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	ac4080e7          	jalr	-1340(ra) # 80004176 <namei>
    800056ba:	84aa                	mv	s1,a0
    800056bc:	c551                	beqz	a0,80005748 <sys_link+0xde>
  ilock(ip);
    800056be:	ffffe097          	auipc	ra,0xffffe
    800056c2:	312080e7          	jalr	786(ra) # 800039d0 <ilock>
  if(ip->type == T_DIR){
    800056c6:	04449703          	lh	a4,68(s1)
    800056ca:	4785                	li	a5,1
    800056cc:	08f70463          	beq	a4,a5,80005754 <sys_link+0xea>
  ip->nlink++;
    800056d0:	04a4d783          	lhu	a5,74(s1)
    800056d4:	2785                	addiw	a5,a5,1
    800056d6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056da:	8526                	mv	a0,s1
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	22a080e7          	jalr	554(ra) # 80003906 <iupdate>
  iunlock(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	3ac080e7          	jalr	940(ra) # 80003a92 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056ee:	fd040593          	addi	a1,s0,-48
    800056f2:	f5040513          	addi	a0,s0,-176
    800056f6:	fffff097          	auipc	ra,0xfffff
    800056fa:	a9e080e7          	jalr	-1378(ra) # 80004194 <nameiparent>
    800056fe:	892a                	mv	s2,a0
    80005700:	c935                	beqz	a0,80005774 <sys_link+0x10a>
  ilock(dp);
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	2ce080e7          	jalr	718(ra) # 800039d0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000570a:	00092703          	lw	a4,0(s2)
    8000570e:	409c                	lw	a5,0(s1)
    80005710:	04f71d63          	bne	a4,a5,8000576a <sys_link+0x100>
    80005714:	40d0                	lw	a2,4(s1)
    80005716:	fd040593          	addi	a1,s0,-48
    8000571a:	854a                	mv	a0,s2
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	9a8080e7          	jalr	-1624(ra) # 800040c4 <dirlink>
    80005724:	04054363          	bltz	a0,8000576a <sys_link+0x100>
  iunlockput(dp);
    80005728:	854a                	mv	a0,s2
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	508080e7          	jalr	1288(ra) # 80003c32 <iunlockput>
  iput(ip);
    80005732:	8526                	mv	a0,s1
    80005734:	ffffe097          	auipc	ra,0xffffe
    80005738:	456080e7          	jalr	1110(ra) # 80003b8a <iput>
  end_op();
    8000573c:	fffff097          	auipc	ra,0xfffff
    80005740:	cd6080e7          	jalr	-810(ra) # 80004412 <end_op>
  return 0;
    80005744:	4781                	li	a5,0
    80005746:	a085                	j	800057a6 <sys_link+0x13c>
    end_op();
    80005748:	fffff097          	auipc	ra,0xfffff
    8000574c:	cca080e7          	jalr	-822(ra) # 80004412 <end_op>
    return -1;
    80005750:	57fd                	li	a5,-1
    80005752:	a891                	j	800057a6 <sys_link+0x13c>
    iunlockput(ip);
    80005754:	8526                	mv	a0,s1
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	4dc080e7          	jalr	1244(ra) # 80003c32 <iunlockput>
    end_op();
    8000575e:	fffff097          	auipc	ra,0xfffff
    80005762:	cb4080e7          	jalr	-844(ra) # 80004412 <end_op>
    return -1;
    80005766:	57fd                	li	a5,-1
    80005768:	a83d                	j	800057a6 <sys_link+0x13c>
    iunlockput(dp);
    8000576a:	854a                	mv	a0,s2
    8000576c:	ffffe097          	auipc	ra,0xffffe
    80005770:	4c6080e7          	jalr	1222(ra) # 80003c32 <iunlockput>
  ilock(ip);
    80005774:	8526                	mv	a0,s1
    80005776:	ffffe097          	auipc	ra,0xffffe
    8000577a:	25a080e7          	jalr	602(ra) # 800039d0 <ilock>
  ip->nlink--;
    8000577e:	04a4d783          	lhu	a5,74(s1)
    80005782:	37fd                	addiw	a5,a5,-1
    80005784:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005788:	8526                	mv	a0,s1
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	17c080e7          	jalr	380(ra) # 80003906 <iupdate>
  iunlockput(ip);
    80005792:	8526                	mv	a0,s1
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	49e080e7          	jalr	1182(ra) # 80003c32 <iunlockput>
  end_op();
    8000579c:	fffff097          	auipc	ra,0xfffff
    800057a0:	c76080e7          	jalr	-906(ra) # 80004412 <end_op>
  return -1;
    800057a4:	57fd                	li	a5,-1
}
    800057a6:	853e                	mv	a0,a5
    800057a8:	70b2                	ld	ra,296(sp)
    800057aa:	7412                	ld	s0,288(sp)
    800057ac:	64f2                	ld	s1,280(sp)
    800057ae:	6952                	ld	s2,272(sp)
    800057b0:	6155                	addi	sp,sp,304
    800057b2:	8082                	ret

00000000800057b4 <sys_unlink>:
{
    800057b4:	7151                	addi	sp,sp,-240
    800057b6:	f586                	sd	ra,232(sp)
    800057b8:	f1a2                	sd	s0,224(sp)
    800057ba:	eda6                	sd	s1,216(sp)
    800057bc:	e9ca                	sd	s2,208(sp)
    800057be:	e5ce                	sd	s3,200(sp)
    800057c0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057c2:	08000613          	li	a2,128
    800057c6:	f3040593          	addi	a1,s0,-208
    800057ca:	4501                	li	a0,0
    800057cc:	ffffd097          	auipc	ra,0xffffd
    800057d0:	6c8080e7          	jalr	1736(ra) # 80002e94 <argstr>
    800057d4:	18054163          	bltz	a0,80005956 <sys_unlink+0x1a2>
  begin_op();
    800057d8:	fffff097          	auipc	ra,0xfffff
    800057dc:	bba080e7          	jalr	-1094(ra) # 80004392 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057e0:	fb040593          	addi	a1,s0,-80
    800057e4:	f3040513          	addi	a0,s0,-208
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	9ac080e7          	jalr	-1620(ra) # 80004194 <nameiparent>
    800057f0:	84aa                	mv	s1,a0
    800057f2:	c979                	beqz	a0,800058c8 <sys_unlink+0x114>
  ilock(dp);
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	1dc080e7          	jalr	476(ra) # 800039d0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057fc:	00003597          	auipc	a1,0x3
    80005800:	ef458593          	addi	a1,a1,-268 # 800086f0 <syscalls+0x2a0>
    80005804:	fb040513          	addi	a0,s0,-80
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	692080e7          	jalr	1682(ra) # 80003e9a <namecmp>
    80005810:	14050a63          	beqz	a0,80005964 <sys_unlink+0x1b0>
    80005814:	00003597          	auipc	a1,0x3
    80005818:	ee458593          	addi	a1,a1,-284 # 800086f8 <syscalls+0x2a8>
    8000581c:	fb040513          	addi	a0,s0,-80
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	67a080e7          	jalr	1658(ra) # 80003e9a <namecmp>
    80005828:	12050e63          	beqz	a0,80005964 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000582c:	f2c40613          	addi	a2,s0,-212
    80005830:	fb040593          	addi	a1,s0,-80
    80005834:	8526                	mv	a0,s1
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	67e080e7          	jalr	1662(ra) # 80003eb4 <dirlookup>
    8000583e:	892a                	mv	s2,a0
    80005840:	12050263          	beqz	a0,80005964 <sys_unlink+0x1b0>
  ilock(ip);
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	18c080e7          	jalr	396(ra) # 800039d0 <ilock>
  if(ip->nlink < 1)
    8000584c:	04a91783          	lh	a5,74(s2)
    80005850:	08f05263          	blez	a5,800058d4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005854:	04491703          	lh	a4,68(s2)
    80005858:	4785                	li	a5,1
    8000585a:	08f70563          	beq	a4,a5,800058e4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000585e:	4641                	li	a2,16
    80005860:	4581                	li	a1,0
    80005862:	fc040513          	addi	a0,s0,-64
    80005866:	ffffb097          	auipc	ra,0xffffb
    8000586a:	46c080e7          	jalr	1132(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000586e:	4741                	li	a4,16
    80005870:	f2c42683          	lw	a3,-212(s0)
    80005874:	fc040613          	addi	a2,s0,-64
    80005878:	4581                	li	a1,0
    8000587a:	8526                	mv	a0,s1
    8000587c:	ffffe097          	auipc	ra,0xffffe
    80005880:	500080e7          	jalr	1280(ra) # 80003d7c <writei>
    80005884:	47c1                	li	a5,16
    80005886:	0af51563          	bne	a0,a5,80005930 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000588a:	04491703          	lh	a4,68(s2)
    8000588e:	4785                	li	a5,1
    80005890:	0af70863          	beq	a4,a5,80005940 <sys_unlink+0x18c>
  iunlockput(dp);
    80005894:	8526                	mv	a0,s1
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	39c080e7          	jalr	924(ra) # 80003c32 <iunlockput>
  ip->nlink--;
    8000589e:	04a95783          	lhu	a5,74(s2)
    800058a2:	37fd                	addiw	a5,a5,-1
    800058a4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058a8:	854a                	mv	a0,s2
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	05c080e7          	jalr	92(ra) # 80003906 <iupdate>
  iunlockput(ip);
    800058b2:	854a                	mv	a0,s2
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	37e080e7          	jalr	894(ra) # 80003c32 <iunlockput>
  end_op();
    800058bc:	fffff097          	auipc	ra,0xfffff
    800058c0:	b56080e7          	jalr	-1194(ra) # 80004412 <end_op>
  return 0;
    800058c4:	4501                	li	a0,0
    800058c6:	a84d                	j	80005978 <sys_unlink+0x1c4>
    end_op();
    800058c8:	fffff097          	auipc	ra,0xfffff
    800058cc:	b4a080e7          	jalr	-1206(ra) # 80004412 <end_op>
    return -1;
    800058d0:	557d                	li	a0,-1
    800058d2:	a05d                	j	80005978 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800058d4:	00003517          	auipc	a0,0x3
    800058d8:	e2c50513          	addi	a0,a0,-468 # 80008700 <syscalls+0x2b0>
    800058dc:	ffffb097          	auipc	ra,0xffffb
    800058e0:	c62080e7          	jalr	-926(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058e4:	04c92703          	lw	a4,76(s2)
    800058e8:	02000793          	li	a5,32
    800058ec:	f6e7f9e3          	bgeu	a5,a4,8000585e <sys_unlink+0xaa>
    800058f0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058f4:	4741                	li	a4,16
    800058f6:	86ce                	mv	a3,s3
    800058f8:	f1840613          	addi	a2,s0,-232
    800058fc:	4581                	li	a1,0
    800058fe:	854a                	mv	a0,s2
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	384080e7          	jalr	900(ra) # 80003c84 <readi>
    80005908:	47c1                	li	a5,16
    8000590a:	00f51b63          	bne	a0,a5,80005920 <sys_unlink+0x16c>
    if(de.inum != 0)
    8000590e:	f1845783          	lhu	a5,-232(s0)
    80005912:	e7a1                	bnez	a5,8000595a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005914:	29c1                	addiw	s3,s3,16
    80005916:	04c92783          	lw	a5,76(s2)
    8000591a:	fcf9ede3          	bltu	s3,a5,800058f4 <sys_unlink+0x140>
    8000591e:	b781                	j	8000585e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005920:	00003517          	auipc	a0,0x3
    80005924:	df850513          	addi	a0,a0,-520 # 80008718 <syscalls+0x2c8>
    80005928:	ffffb097          	auipc	ra,0xffffb
    8000592c:	c16080e7          	jalr	-1002(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005930:	00003517          	auipc	a0,0x3
    80005934:	e0050513          	addi	a0,a0,-512 # 80008730 <syscalls+0x2e0>
    80005938:	ffffb097          	auipc	ra,0xffffb
    8000593c:	c06080e7          	jalr	-1018(ra) # 8000053e <panic>
    dp->nlink--;
    80005940:	04a4d783          	lhu	a5,74(s1)
    80005944:	37fd                	addiw	a5,a5,-1
    80005946:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000594a:	8526                	mv	a0,s1
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	fba080e7          	jalr	-70(ra) # 80003906 <iupdate>
    80005954:	b781                	j	80005894 <sys_unlink+0xe0>
    return -1;
    80005956:	557d                	li	a0,-1
    80005958:	a005                	j	80005978 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000595a:	854a                	mv	a0,s2
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	2d6080e7          	jalr	726(ra) # 80003c32 <iunlockput>
  iunlockput(dp);
    80005964:	8526                	mv	a0,s1
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	2cc080e7          	jalr	716(ra) # 80003c32 <iunlockput>
  end_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	aa4080e7          	jalr	-1372(ra) # 80004412 <end_op>
  return -1;
    80005976:	557d                	li	a0,-1
}
    80005978:	70ae                	ld	ra,232(sp)
    8000597a:	740e                	ld	s0,224(sp)
    8000597c:	64ee                	ld	s1,216(sp)
    8000597e:	694e                	ld	s2,208(sp)
    80005980:	69ae                	ld	s3,200(sp)
    80005982:	616d                	addi	sp,sp,240
    80005984:	8082                	ret

0000000080005986 <sys_open>:

uint64
sys_open(void)
{
    80005986:	7131                	addi	sp,sp,-192
    80005988:	fd06                	sd	ra,184(sp)
    8000598a:	f922                	sd	s0,176(sp)
    8000598c:	f526                	sd	s1,168(sp)
    8000598e:	f14a                	sd	s2,160(sp)
    80005990:	ed4e                	sd	s3,152(sp)
    80005992:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005994:	f4c40593          	addi	a1,s0,-180
    80005998:	4505                	li	a0,1
    8000599a:	ffffd097          	auipc	ra,0xffffd
    8000599e:	4ba080e7          	jalr	1210(ra) # 80002e54 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059a2:	08000613          	li	a2,128
    800059a6:	f5040593          	addi	a1,s0,-176
    800059aa:	4501                	li	a0,0
    800059ac:	ffffd097          	auipc	ra,0xffffd
    800059b0:	4e8080e7          	jalr	1256(ra) # 80002e94 <argstr>
    800059b4:	87aa                	mv	a5,a0
    return -1;
    800059b6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059b8:	0a07c963          	bltz	a5,80005a6a <sys_open+0xe4>

  begin_op();
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	9d6080e7          	jalr	-1578(ra) # 80004392 <begin_op>

  if(omode & O_CREATE){
    800059c4:	f4c42783          	lw	a5,-180(s0)
    800059c8:	2007f793          	andi	a5,a5,512
    800059cc:	cfc5                	beqz	a5,80005a84 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800059ce:	4681                	li	a3,0
    800059d0:	4601                	li	a2,0
    800059d2:	4589                	li	a1,2
    800059d4:	f5040513          	addi	a0,s0,-176
    800059d8:	00000097          	auipc	ra,0x0
    800059dc:	974080e7          	jalr	-1676(ra) # 8000534c <create>
    800059e0:	84aa                	mv	s1,a0
    if(ip == 0){
    800059e2:	c959                	beqz	a0,80005a78 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800059e4:	04449703          	lh	a4,68(s1)
    800059e8:	478d                	li	a5,3
    800059ea:	00f71763          	bne	a4,a5,800059f8 <sys_open+0x72>
    800059ee:	0464d703          	lhu	a4,70(s1)
    800059f2:	47a5                	li	a5,9
    800059f4:	0ce7ed63          	bltu	a5,a4,80005ace <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	daa080e7          	jalr	-598(ra) # 800047a2 <filealloc>
    80005a00:	89aa                	mv	s3,a0
    80005a02:	10050363          	beqz	a0,80005b08 <sys_open+0x182>
    80005a06:	00000097          	auipc	ra,0x0
    80005a0a:	904080e7          	jalr	-1788(ra) # 8000530a <fdalloc>
    80005a0e:	892a                	mv	s2,a0
    80005a10:	0e054763          	bltz	a0,80005afe <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a14:	04449703          	lh	a4,68(s1)
    80005a18:	478d                	li	a5,3
    80005a1a:	0cf70563          	beq	a4,a5,80005ae4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a1e:	4789                	li	a5,2
    80005a20:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a24:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a28:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a2c:	f4c42783          	lw	a5,-180(s0)
    80005a30:	0017c713          	xori	a4,a5,1
    80005a34:	8b05                	andi	a4,a4,1
    80005a36:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a3a:	0037f713          	andi	a4,a5,3
    80005a3e:	00e03733          	snez	a4,a4
    80005a42:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a46:	4007f793          	andi	a5,a5,1024
    80005a4a:	c791                	beqz	a5,80005a56 <sys_open+0xd0>
    80005a4c:	04449703          	lh	a4,68(s1)
    80005a50:	4789                	li	a5,2
    80005a52:	0af70063          	beq	a4,a5,80005af2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a56:	8526                	mv	a0,s1
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	03a080e7          	jalr	58(ra) # 80003a92 <iunlock>
  end_op();
    80005a60:	fffff097          	auipc	ra,0xfffff
    80005a64:	9b2080e7          	jalr	-1614(ra) # 80004412 <end_op>

  return fd;
    80005a68:	854a                	mv	a0,s2
}
    80005a6a:	70ea                	ld	ra,184(sp)
    80005a6c:	744a                	ld	s0,176(sp)
    80005a6e:	74aa                	ld	s1,168(sp)
    80005a70:	790a                	ld	s2,160(sp)
    80005a72:	69ea                	ld	s3,152(sp)
    80005a74:	6129                	addi	sp,sp,192
    80005a76:	8082                	ret
      end_op();
    80005a78:	fffff097          	auipc	ra,0xfffff
    80005a7c:	99a080e7          	jalr	-1638(ra) # 80004412 <end_op>
      return -1;
    80005a80:	557d                	li	a0,-1
    80005a82:	b7e5                	j	80005a6a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a84:	f5040513          	addi	a0,s0,-176
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	6ee080e7          	jalr	1774(ra) # 80004176 <namei>
    80005a90:	84aa                	mv	s1,a0
    80005a92:	c905                	beqz	a0,80005ac2 <sys_open+0x13c>
    ilock(ip);
    80005a94:	ffffe097          	auipc	ra,0xffffe
    80005a98:	f3c080e7          	jalr	-196(ra) # 800039d0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a9c:	04449703          	lh	a4,68(s1)
    80005aa0:	4785                	li	a5,1
    80005aa2:	f4f711e3          	bne	a4,a5,800059e4 <sys_open+0x5e>
    80005aa6:	f4c42783          	lw	a5,-180(s0)
    80005aaa:	d7b9                	beqz	a5,800059f8 <sys_open+0x72>
      iunlockput(ip);
    80005aac:	8526                	mv	a0,s1
    80005aae:	ffffe097          	auipc	ra,0xffffe
    80005ab2:	184080e7          	jalr	388(ra) # 80003c32 <iunlockput>
      end_op();
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	95c080e7          	jalr	-1700(ra) # 80004412 <end_op>
      return -1;
    80005abe:	557d                	li	a0,-1
    80005ac0:	b76d                	j	80005a6a <sys_open+0xe4>
      end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	950080e7          	jalr	-1712(ra) # 80004412 <end_op>
      return -1;
    80005aca:	557d                	li	a0,-1
    80005acc:	bf79                	j	80005a6a <sys_open+0xe4>
    iunlockput(ip);
    80005ace:	8526                	mv	a0,s1
    80005ad0:	ffffe097          	auipc	ra,0xffffe
    80005ad4:	162080e7          	jalr	354(ra) # 80003c32 <iunlockput>
    end_op();
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	93a080e7          	jalr	-1734(ra) # 80004412 <end_op>
    return -1;
    80005ae0:	557d                	li	a0,-1
    80005ae2:	b761                	j	80005a6a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ae4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ae8:	04649783          	lh	a5,70(s1)
    80005aec:	02f99223          	sh	a5,36(s3)
    80005af0:	bf25                	j	80005a28 <sys_open+0xa2>
    itrunc(ip);
    80005af2:	8526                	mv	a0,s1
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	fea080e7          	jalr	-22(ra) # 80003ade <itrunc>
    80005afc:	bfa9                	j	80005a56 <sys_open+0xd0>
      fileclose(f);
    80005afe:	854e                	mv	a0,s3
    80005b00:	fffff097          	auipc	ra,0xfffff
    80005b04:	d5e080e7          	jalr	-674(ra) # 8000485e <fileclose>
    iunlockput(ip);
    80005b08:	8526                	mv	a0,s1
    80005b0a:	ffffe097          	auipc	ra,0xffffe
    80005b0e:	128080e7          	jalr	296(ra) # 80003c32 <iunlockput>
    end_op();
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	900080e7          	jalr	-1792(ra) # 80004412 <end_op>
    return -1;
    80005b1a:	557d                	li	a0,-1
    80005b1c:	b7b9                	j	80005a6a <sys_open+0xe4>

0000000080005b1e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b1e:	7175                	addi	sp,sp,-144
    80005b20:	e506                	sd	ra,136(sp)
    80005b22:	e122                	sd	s0,128(sp)
    80005b24:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	86c080e7          	jalr	-1940(ra) # 80004392 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b2e:	08000613          	li	a2,128
    80005b32:	f7040593          	addi	a1,s0,-144
    80005b36:	4501                	li	a0,0
    80005b38:	ffffd097          	auipc	ra,0xffffd
    80005b3c:	35c080e7          	jalr	860(ra) # 80002e94 <argstr>
    80005b40:	02054963          	bltz	a0,80005b72 <sys_mkdir+0x54>
    80005b44:	4681                	li	a3,0
    80005b46:	4601                	li	a2,0
    80005b48:	4585                	li	a1,1
    80005b4a:	f7040513          	addi	a0,s0,-144
    80005b4e:	fffff097          	auipc	ra,0xfffff
    80005b52:	7fe080e7          	jalr	2046(ra) # 8000534c <create>
    80005b56:	cd11                	beqz	a0,80005b72 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	0da080e7          	jalr	218(ra) # 80003c32 <iunlockput>
  end_op();
    80005b60:	fffff097          	auipc	ra,0xfffff
    80005b64:	8b2080e7          	jalr	-1870(ra) # 80004412 <end_op>
  return 0;
    80005b68:	4501                	li	a0,0
}
    80005b6a:	60aa                	ld	ra,136(sp)
    80005b6c:	640a                	ld	s0,128(sp)
    80005b6e:	6149                	addi	sp,sp,144
    80005b70:	8082                	ret
    end_op();
    80005b72:	fffff097          	auipc	ra,0xfffff
    80005b76:	8a0080e7          	jalr	-1888(ra) # 80004412 <end_op>
    return -1;
    80005b7a:	557d                	li	a0,-1
    80005b7c:	b7fd                	j	80005b6a <sys_mkdir+0x4c>

0000000080005b7e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b7e:	7135                	addi	sp,sp,-160
    80005b80:	ed06                	sd	ra,152(sp)
    80005b82:	e922                	sd	s0,144(sp)
    80005b84:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	80c080e7          	jalr	-2036(ra) # 80004392 <begin_op>
  argint(1, &major);
    80005b8e:	f6c40593          	addi	a1,s0,-148
    80005b92:	4505                	li	a0,1
    80005b94:	ffffd097          	auipc	ra,0xffffd
    80005b98:	2c0080e7          	jalr	704(ra) # 80002e54 <argint>
  argint(2, &minor);
    80005b9c:	f6840593          	addi	a1,s0,-152
    80005ba0:	4509                	li	a0,2
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	2b2080e7          	jalr	690(ra) # 80002e54 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005baa:	08000613          	li	a2,128
    80005bae:	f7040593          	addi	a1,s0,-144
    80005bb2:	4501                	li	a0,0
    80005bb4:	ffffd097          	auipc	ra,0xffffd
    80005bb8:	2e0080e7          	jalr	736(ra) # 80002e94 <argstr>
    80005bbc:	02054b63          	bltz	a0,80005bf2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005bc0:	f6841683          	lh	a3,-152(s0)
    80005bc4:	f6c41603          	lh	a2,-148(s0)
    80005bc8:	458d                	li	a1,3
    80005bca:	f7040513          	addi	a0,s0,-144
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	77e080e7          	jalr	1918(ra) # 8000534c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bd6:	cd11                	beqz	a0,80005bf2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bd8:	ffffe097          	auipc	ra,0xffffe
    80005bdc:	05a080e7          	jalr	90(ra) # 80003c32 <iunlockput>
  end_op();
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	832080e7          	jalr	-1998(ra) # 80004412 <end_op>
  return 0;
    80005be8:	4501                	li	a0,0
}
    80005bea:	60ea                	ld	ra,152(sp)
    80005bec:	644a                	ld	s0,144(sp)
    80005bee:	610d                	addi	sp,sp,160
    80005bf0:	8082                	ret
    end_op();
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	820080e7          	jalr	-2016(ra) # 80004412 <end_op>
    return -1;
    80005bfa:	557d                	li	a0,-1
    80005bfc:	b7fd                	j	80005bea <sys_mknod+0x6c>

0000000080005bfe <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bfe:	7135                	addi	sp,sp,-160
    80005c00:	ed06                	sd	ra,152(sp)
    80005c02:	e922                	sd	s0,144(sp)
    80005c04:	e526                	sd	s1,136(sp)
    80005c06:	e14a                	sd	s2,128(sp)
    80005c08:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c0a:	ffffc097          	auipc	ra,0xffffc
    80005c0e:	d76080e7          	jalr	-650(ra) # 80001980 <myproc>
    80005c12:	892a                	mv	s2,a0
  
  begin_op();
    80005c14:	ffffe097          	auipc	ra,0xffffe
    80005c18:	77e080e7          	jalr	1918(ra) # 80004392 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c1c:	08000613          	li	a2,128
    80005c20:	f6040593          	addi	a1,s0,-160
    80005c24:	4501                	li	a0,0
    80005c26:	ffffd097          	auipc	ra,0xffffd
    80005c2a:	26e080e7          	jalr	622(ra) # 80002e94 <argstr>
    80005c2e:	04054b63          	bltz	a0,80005c84 <sys_chdir+0x86>
    80005c32:	f6040513          	addi	a0,s0,-160
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	540080e7          	jalr	1344(ra) # 80004176 <namei>
    80005c3e:	84aa                	mv	s1,a0
    80005c40:	c131                	beqz	a0,80005c84 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c42:	ffffe097          	auipc	ra,0xffffe
    80005c46:	d8e080e7          	jalr	-626(ra) # 800039d0 <ilock>
  if(ip->type != T_DIR){
    80005c4a:	04449703          	lh	a4,68(s1)
    80005c4e:	4785                	li	a5,1
    80005c50:	04f71063          	bne	a4,a5,80005c90 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c54:	8526                	mv	a0,s1
    80005c56:	ffffe097          	auipc	ra,0xffffe
    80005c5a:	e3c080e7          	jalr	-452(ra) # 80003a92 <iunlock>
  iput(p->cwd);
    80005c5e:	18893503          	ld	a0,392(s2)
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	f28080e7          	jalr	-216(ra) # 80003b8a <iput>
  end_op();
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	7a8080e7          	jalr	1960(ra) # 80004412 <end_op>
  p->cwd = ip;
    80005c72:	18993423          	sd	s1,392(s2)
  return 0;
    80005c76:	4501                	li	a0,0
}
    80005c78:	60ea                	ld	ra,152(sp)
    80005c7a:	644a                	ld	s0,144(sp)
    80005c7c:	64aa                	ld	s1,136(sp)
    80005c7e:	690a                	ld	s2,128(sp)
    80005c80:	610d                	addi	sp,sp,160
    80005c82:	8082                	ret
    end_op();
    80005c84:	ffffe097          	auipc	ra,0xffffe
    80005c88:	78e080e7          	jalr	1934(ra) # 80004412 <end_op>
    return -1;
    80005c8c:	557d                	li	a0,-1
    80005c8e:	b7ed                	j	80005c78 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c90:	8526                	mv	a0,s1
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	fa0080e7          	jalr	-96(ra) # 80003c32 <iunlockput>
    end_op();
    80005c9a:	ffffe097          	auipc	ra,0xffffe
    80005c9e:	778080e7          	jalr	1912(ra) # 80004412 <end_op>
    return -1;
    80005ca2:	557d                	li	a0,-1
    80005ca4:	bfd1                	j	80005c78 <sys_chdir+0x7a>

0000000080005ca6 <sys_exec>:

uint64
sys_exec(void)
{
    80005ca6:	7145                	addi	sp,sp,-464
    80005ca8:	e786                	sd	ra,456(sp)
    80005caa:	e3a2                	sd	s0,448(sp)
    80005cac:	ff26                	sd	s1,440(sp)
    80005cae:	fb4a                	sd	s2,432(sp)
    80005cb0:	f74e                	sd	s3,424(sp)
    80005cb2:	f352                	sd	s4,416(sp)
    80005cb4:	ef56                	sd	s5,408(sp)
    80005cb6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cb8:	e3840593          	addi	a1,s0,-456
    80005cbc:	4505                	li	a0,1
    80005cbe:	ffffd097          	auipc	ra,0xffffd
    80005cc2:	1b6080e7          	jalr	438(ra) # 80002e74 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005cc6:	08000613          	li	a2,128
    80005cca:	f4040593          	addi	a1,s0,-192
    80005cce:	4501                	li	a0,0
    80005cd0:	ffffd097          	auipc	ra,0xffffd
    80005cd4:	1c4080e7          	jalr	452(ra) # 80002e94 <argstr>
    80005cd8:	87aa                	mv	a5,a0
    return -1;
    80005cda:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005cdc:	0c07c263          	bltz	a5,80005da0 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005ce0:	10000613          	li	a2,256
    80005ce4:	4581                	li	a1,0
    80005ce6:	e4040513          	addi	a0,s0,-448
    80005cea:	ffffb097          	auipc	ra,0xffffb
    80005cee:	fe8080e7          	jalr	-24(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005cf2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005cf6:	89a6                	mv	s3,s1
    80005cf8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005cfa:	02000a13          	li	s4,32
    80005cfe:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d02:	00391793          	slli	a5,s2,0x3
    80005d06:	e3040593          	addi	a1,s0,-464
    80005d0a:	e3843503          	ld	a0,-456(s0)
    80005d0e:	953e                	add	a0,a0,a5
    80005d10:	ffffd097          	auipc	ra,0xffffd
    80005d14:	0a2080e7          	jalr	162(ra) # 80002db2 <fetchaddr>
    80005d18:	02054a63          	bltz	a0,80005d4c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005d1c:	e3043783          	ld	a5,-464(s0)
    80005d20:	c3b9                	beqz	a5,80005d66 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d22:	ffffb097          	auipc	ra,0xffffb
    80005d26:	dc4080e7          	jalr	-572(ra) # 80000ae6 <kalloc>
    80005d2a:	85aa                	mv	a1,a0
    80005d2c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d30:	cd11                	beqz	a0,80005d4c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d32:	6605                	lui	a2,0x1
    80005d34:	e3043503          	ld	a0,-464(s0)
    80005d38:	ffffd097          	auipc	ra,0xffffd
    80005d3c:	0ce080e7          	jalr	206(ra) # 80002e06 <fetchstr>
    80005d40:	00054663          	bltz	a0,80005d4c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005d44:	0905                	addi	s2,s2,1
    80005d46:	09a1                	addi	s3,s3,8
    80005d48:	fb491be3          	bne	s2,s4,80005cfe <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d4c:	10048913          	addi	s2,s1,256
    80005d50:	6088                	ld	a0,0(s1)
    80005d52:	c531                	beqz	a0,80005d9e <sys_exec+0xf8>
    kfree(argv[i]);
    80005d54:	ffffb097          	auipc	ra,0xffffb
    80005d58:	c96080e7          	jalr	-874(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d5c:	04a1                	addi	s1,s1,8
    80005d5e:	ff2499e3          	bne	s1,s2,80005d50 <sys_exec+0xaa>
  return -1;
    80005d62:	557d                	li	a0,-1
    80005d64:	a835                	j	80005da0 <sys_exec+0xfa>
      argv[i] = 0;
    80005d66:	0a8e                	slli	s5,s5,0x3
    80005d68:	fc040793          	addi	a5,s0,-64
    80005d6c:	9abe                	add	s5,s5,a5
    80005d6e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d72:	e4040593          	addi	a1,s0,-448
    80005d76:	f4040513          	addi	a0,s0,-192
    80005d7a:	fffff097          	auipc	ra,0xfffff
    80005d7e:	15e080e7          	jalr	350(ra) # 80004ed8 <exec>
    80005d82:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d84:	10048993          	addi	s3,s1,256
    80005d88:	6088                	ld	a0,0(s1)
    80005d8a:	c901                	beqz	a0,80005d9a <sys_exec+0xf4>
    kfree(argv[i]);
    80005d8c:	ffffb097          	auipc	ra,0xffffb
    80005d90:	c5e080e7          	jalr	-930(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d94:	04a1                	addi	s1,s1,8
    80005d96:	ff3499e3          	bne	s1,s3,80005d88 <sys_exec+0xe2>
  return ret;
    80005d9a:	854a                	mv	a0,s2
    80005d9c:	a011                	j	80005da0 <sys_exec+0xfa>
  return -1;
    80005d9e:	557d                	li	a0,-1
}
    80005da0:	60be                	ld	ra,456(sp)
    80005da2:	641e                	ld	s0,448(sp)
    80005da4:	74fa                	ld	s1,440(sp)
    80005da6:	795a                	ld	s2,432(sp)
    80005da8:	79ba                	ld	s3,424(sp)
    80005daa:	7a1a                	ld	s4,416(sp)
    80005dac:	6afa                	ld	s5,408(sp)
    80005dae:	6179                	addi	sp,sp,464
    80005db0:	8082                	ret

0000000080005db2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005db2:	7139                	addi	sp,sp,-64
    80005db4:	fc06                	sd	ra,56(sp)
    80005db6:	f822                	sd	s0,48(sp)
    80005db8:	f426                	sd	s1,40(sp)
    80005dba:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dbc:	ffffc097          	auipc	ra,0xffffc
    80005dc0:	bc4080e7          	jalr	-1084(ra) # 80001980 <myproc>
    80005dc4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005dc6:	fd840593          	addi	a1,s0,-40
    80005dca:	4501                	li	a0,0
    80005dcc:	ffffd097          	auipc	ra,0xffffd
    80005dd0:	0a8080e7          	jalr	168(ra) # 80002e74 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005dd4:	fc840593          	addi	a1,s0,-56
    80005dd8:	fd040513          	addi	a0,s0,-48
    80005ddc:	fffff097          	auipc	ra,0xfffff
    80005de0:	db2080e7          	jalr	-590(ra) # 80004b8e <pipealloc>
    return -1;
    80005de4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005de6:	0c054963          	bltz	a0,80005eb8 <sys_pipe+0x106>
  fd0 = -1;
    80005dea:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005dee:	fd043503          	ld	a0,-48(s0)
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	518080e7          	jalr	1304(ra) # 8000530a <fdalloc>
    80005dfa:	fca42223          	sw	a0,-60(s0)
    80005dfe:	0a054063          	bltz	a0,80005e9e <sys_pipe+0xec>
    80005e02:	fc843503          	ld	a0,-56(s0)
    80005e06:	fffff097          	auipc	ra,0xfffff
    80005e0a:	504080e7          	jalr	1284(ra) # 8000530a <fdalloc>
    80005e0e:	fca42023          	sw	a0,-64(s0)
    80005e12:	06054c63          	bltz	a0,80005e8a <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e16:	4691                	li	a3,4
    80005e18:	fc440613          	addi	a2,s0,-60
    80005e1c:	fd843583          	ld	a1,-40(s0)
    80005e20:	1004b503          	ld	a0,256(s1)
    80005e24:	ffffc097          	auipc	ra,0xffffc
    80005e28:	844080e7          	jalr	-1980(ra) # 80001668 <copyout>
    80005e2c:	02054163          	bltz	a0,80005e4e <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e30:	4691                	li	a3,4
    80005e32:	fc040613          	addi	a2,s0,-64
    80005e36:	fd843583          	ld	a1,-40(s0)
    80005e3a:	0591                	addi	a1,a1,4
    80005e3c:	1004b503          	ld	a0,256(s1)
    80005e40:	ffffc097          	auipc	ra,0xffffc
    80005e44:	828080e7          	jalr	-2008(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e48:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e4a:	06055763          	bgez	a0,80005eb8 <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80005e4e:	fc442783          	lw	a5,-60(s0)
    80005e52:	02078793          	addi	a5,a5,32
    80005e56:	078e                	slli	a5,a5,0x3
    80005e58:	97a6                	add	a5,a5,s1
    80005e5a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e5e:	fc042503          	lw	a0,-64(s0)
    80005e62:	02050513          	addi	a0,a0,32
    80005e66:	050e                	slli	a0,a0,0x3
    80005e68:	94aa                	add	s1,s1,a0
    80005e6a:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e6e:	fd043503          	ld	a0,-48(s0)
    80005e72:	fffff097          	auipc	ra,0xfffff
    80005e76:	9ec080e7          	jalr	-1556(ra) # 8000485e <fileclose>
    fileclose(wf);
    80005e7a:	fc843503          	ld	a0,-56(s0)
    80005e7e:	fffff097          	auipc	ra,0xfffff
    80005e82:	9e0080e7          	jalr	-1568(ra) # 8000485e <fileclose>
    return -1;
    80005e86:	57fd                	li	a5,-1
    80005e88:	a805                	j	80005eb8 <sys_pipe+0x106>
    if(fd0 >= 0)
    80005e8a:	fc442783          	lw	a5,-60(s0)
    80005e8e:	0007c863          	bltz	a5,80005e9e <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80005e92:	02078793          	addi	a5,a5,32
    80005e96:	078e                	slli	a5,a5,0x3
    80005e98:	94be                	add	s1,s1,a5
    80005e9a:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e9e:	fd043503          	ld	a0,-48(s0)
    80005ea2:	fffff097          	auipc	ra,0xfffff
    80005ea6:	9bc080e7          	jalr	-1604(ra) # 8000485e <fileclose>
    fileclose(wf);
    80005eaa:	fc843503          	ld	a0,-56(s0)
    80005eae:	fffff097          	auipc	ra,0xfffff
    80005eb2:	9b0080e7          	jalr	-1616(ra) # 8000485e <fileclose>
    return -1;
    80005eb6:	57fd                	li	a5,-1
}
    80005eb8:	853e                	mv	a0,a5
    80005eba:	70e2                	ld	ra,56(sp)
    80005ebc:	7442                	ld	s0,48(sp)
    80005ebe:	74a2                	ld	s1,40(sp)
    80005ec0:	6121                	addi	sp,sp,64
    80005ec2:	8082                	ret
	...

0000000080005ed0 <kernelvec>:
    80005ed0:	7111                	addi	sp,sp,-256
    80005ed2:	e006                	sd	ra,0(sp)
    80005ed4:	e40a                	sd	sp,8(sp)
    80005ed6:	e80e                	sd	gp,16(sp)
    80005ed8:	ec12                	sd	tp,24(sp)
    80005eda:	f016                	sd	t0,32(sp)
    80005edc:	f41a                	sd	t1,40(sp)
    80005ede:	f81e                	sd	t2,48(sp)
    80005ee0:	fc22                	sd	s0,56(sp)
    80005ee2:	e0a6                	sd	s1,64(sp)
    80005ee4:	e4aa                	sd	a0,72(sp)
    80005ee6:	e8ae                	sd	a1,80(sp)
    80005ee8:	ecb2                	sd	a2,88(sp)
    80005eea:	f0b6                	sd	a3,96(sp)
    80005eec:	f4ba                	sd	a4,104(sp)
    80005eee:	f8be                	sd	a5,112(sp)
    80005ef0:	fcc2                	sd	a6,120(sp)
    80005ef2:	e146                	sd	a7,128(sp)
    80005ef4:	e54a                	sd	s2,136(sp)
    80005ef6:	e94e                	sd	s3,144(sp)
    80005ef8:	ed52                	sd	s4,152(sp)
    80005efa:	f156                	sd	s5,160(sp)
    80005efc:	f55a                	sd	s6,168(sp)
    80005efe:	f95e                	sd	s7,176(sp)
    80005f00:	fd62                	sd	s8,184(sp)
    80005f02:	e1e6                	sd	s9,192(sp)
    80005f04:	e5ea                	sd	s10,200(sp)
    80005f06:	e9ee                	sd	s11,208(sp)
    80005f08:	edf2                	sd	t3,216(sp)
    80005f0a:	f1f6                	sd	t4,224(sp)
    80005f0c:	f5fa                	sd	t5,232(sp)
    80005f0e:	f9fe                	sd	t6,240(sp)
    80005f10:	d6ffc0ef          	jal	ra,80002c7e <kerneltrap>
    80005f14:	6082                	ld	ra,0(sp)
    80005f16:	6122                	ld	sp,8(sp)
    80005f18:	61c2                	ld	gp,16(sp)
    80005f1a:	7282                	ld	t0,32(sp)
    80005f1c:	7322                	ld	t1,40(sp)
    80005f1e:	73c2                	ld	t2,48(sp)
    80005f20:	7462                	ld	s0,56(sp)
    80005f22:	6486                	ld	s1,64(sp)
    80005f24:	6526                	ld	a0,72(sp)
    80005f26:	65c6                	ld	a1,80(sp)
    80005f28:	6666                	ld	a2,88(sp)
    80005f2a:	7686                	ld	a3,96(sp)
    80005f2c:	7726                	ld	a4,104(sp)
    80005f2e:	77c6                	ld	a5,112(sp)
    80005f30:	7866                	ld	a6,120(sp)
    80005f32:	688a                	ld	a7,128(sp)
    80005f34:	692a                	ld	s2,136(sp)
    80005f36:	69ca                	ld	s3,144(sp)
    80005f38:	6a6a                	ld	s4,152(sp)
    80005f3a:	7a8a                	ld	s5,160(sp)
    80005f3c:	7b2a                	ld	s6,168(sp)
    80005f3e:	7bca                	ld	s7,176(sp)
    80005f40:	7c6a                	ld	s8,184(sp)
    80005f42:	6c8e                	ld	s9,192(sp)
    80005f44:	6d2e                	ld	s10,200(sp)
    80005f46:	6dce                	ld	s11,208(sp)
    80005f48:	6e6e                	ld	t3,216(sp)
    80005f4a:	7e8e                	ld	t4,224(sp)
    80005f4c:	7f2e                	ld	t5,232(sp)
    80005f4e:	7fce                	ld	t6,240(sp)
    80005f50:	6111                	addi	sp,sp,256
    80005f52:	10200073          	sret
    80005f56:	00000013          	nop
    80005f5a:	00000013          	nop
    80005f5e:	0001                	nop

0000000080005f60 <timervec>:
    80005f60:	34051573          	csrrw	a0,mscratch,a0
    80005f64:	e10c                	sd	a1,0(a0)
    80005f66:	e510                	sd	a2,8(a0)
    80005f68:	e914                	sd	a3,16(a0)
    80005f6a:	6d0c                	ld	a1,24(a0)
    80005f6c:	7110                	ld	a2,32(a0)
    80005f6e:	6194                	ld	a3,0(a1)
    80005f70:	96b2                	add	a3,a3,a2
    80005f72:	e194                	sd	a3,0(a1)
    80005f74:	4589                	li	a1,2
    80005f76:	14459073          	csrw	sip,a1
    80005f7a:	6914                	ld	a3,16(a0)
    80005f7c:	6510                	ld	a2,8(a0)
    80005f7e:	610c                	ld	a1,0(a0)
    80005f80:	34051573          	csrrw	a0,mscratch,a0
    80005f84:	30200073          	mret
	...

0000000080005f8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f8a:	1141                	addi	sp,sp,-16
    80005f8c:	e422                	sd	s0,8(sp)
    80005f8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f90:	0c0007b7          	lui	a5,0xc000
    80005f94:	4705                	li	a4,1
    80005f96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f98:	c3d8                	sw	a4,4(a5)
}
    80005f9a:	6422                	ld	s0,8(sp)
    80005f9c:	0141                	addi	sp,sp,16
    80005f9e:	8082                	ret

0000000080005fa0 <plicinithart>:

void
plicinithart(void)
{
    80005fa0:	1141                	addi	sp,sp,-16
    80005fa2:	e406                	sd	ra,8(sp)
    80005fa4:	e022                	sd	s0,0(sp)
    80005fa6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fa8:	ffffc097          	auipc	ra,0xffffc
    80005fac:	9ac080e7          	jalr	-1620(ra) # 80001954 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fb0:	0085171b          	slliw	a4,a0,0x8
    80005fb4:	0c0027b7          	lui	a5,0xc002
    80005fb8:	97ba                	add	a5,a5,a4
    80005fba:	40200713          	li	a4,1026
    80005fbe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fc2:	00d5151b          	slliw	a0,a0,0xd
    80005fc6:	0c2017b7          	lui	a5,0xc201
    80005fca:	953e                	add	a0,a0,a5
    80005fcc:	00052023          	sw	zero,0(a0)
}
    80005fd0:	60a2                	ld	ra,8(sp)
    80005fd2:	6402                	ld	s0,0(sp)
    80005fd4:	0141                	addi	sp,sp,16
    80005fd6:	8082                	ret

0000000080005fd8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fd8:	1141                	addi	sp,sp,-16
    80005fda:	e406                	sd	ra,8(sp)
    80005fdc:	e022                	sd	s0,0(sp)
    80005fde:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fe0:	ffffc097          	auipc	ra,0xffffc
    80005fe4:	974080e7          	jalr	-1676(ra) # 80001954 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fe8:	00d5179b          	slliw	a5,a0,0xd
    80005fec:	0c201537          	lui	a0,0xc201
    80005ff0:	953e                	add	a0,a0,a5
  return irq;
}
    80005ff2:	4148                	lw	a0,4(a0)
    80005ff4:	60a2                	ld	ra,8(sp)
    80005ff6:	6402                	ld	s0,0(sp)
    80005ff8:	0141                	addi	sp,sp,16
    80005ffa:	8082                	ret

0000000080005ffc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ffc:	1101                	addi	sp,sp,-32
    80005ffe:	ec06                	sd	ra,24(sp)
    80006000:	e822                	sd	s0,16(sp)
    80006002:	e426                	sd	s1,8(sp)
    80006004:	1000                	addi	s0,sp,32
    80006006:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006008:	ffffc097          	auipc	ra,0xffffc
    8000600c:	94c080e7          	jalr	-1716(ra) # 80001954 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006010:	00d5151b          	slliw	a0,a0,0xd
    80006014:	0c2017b7          	lui	a5,0xc201
    80006018:	97aa                	add	a5,a5,a0
    8000601a:	c3c4                	sw	s1,4(a5)
}
    8000601c:	60e2                	ld	ra,24(sp)
    8000601e:	6442                	ld	s0,16(sp)
    80006020:	64a2                	ld	s1,8(sp)
    80006022:	6105                	addi	sp,sp,32
    80006024:	8082                	ret

0000000080006026 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006026:	1141                	addi	sp,sp,-16
    80006028:	e406                	sd	ra,8(sp)
    8000602a:	e022                	sd	s0,0(sp)
    8000602c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000602e:	479d                	li	a5,7
    80006030:	04a7cc63          	blt	a5,a0,80006088 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006034:	0001d797          	auipc	a5,0x1d
    80006038:	1ec78793          	addi	a5,a5,492 # 80023220 <disk>
    8000603c:	97aa                	add	a5,a5,a0
    8000603e:	0187c783          	lbu	a5,24(a5)
    80006042:	ebb9                	bnez	a5,80006098 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006044:	00451613          	slli	a2,a0,0x4
    80006048:	0001d797          	auipc	a5,0x1d
    8000604c:	1d878793          	addi	a5,a5,472 # 80023220 <disk>
    80006050:	6394                	ld	a3,0(a5)
    80006052:	96b2                	add	a3,a3,a2
    80006054:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006058:	6398                	ld	a4,0(a5)
    8000605a:	9732                	add	a4,a4,a2
    8000605c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006060:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006064:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006068:	953e                	add	a0,a0,a5
    8000606a:	4785                	li	a5,1
    8000606c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006070:	0001d517          	auipc	a0,0x1d
    80006074:	1c850513          	addi	a0,a0,456 # 80023238 <disk+0x18>
    80006078:	ffffc097          	auipc	ra,0xffffc
    8000607c:	144080e7          	jalr	324(ra) # 800021bc <wakeup>
}
    80006080:	60a2                	ld	ra,8(sp)
    80006082:	6402                	ld	s0,0(sp)
    80006084:	0141                	addi	sp,sp,16
    80006086:	8082                	ret
    panic("free_desc 1");
    80006088:	00002517          	auipc	a0,0x2
    8000608c:	6b850513          	addi	a0,a0,1720 # 80008740 <syscalls+0x2f0>
    80006090:	ffffa097          	auipc	ra,0xffffa
    80006094:	4ae080e7          	jalr	1198(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006098:	00002517          	auipc	a0,0x2
    8000609c:	6b850513          	addi	a0,a0,1720 # 80008750 <syscalls+0x300>
    800060a0:	ffffa097          	auipc	ra,0xffffa
    800060a4:	49e080e7          	jalr	1182(ra) # 8000053e <panic>

00000000800060a8 <virtio_disk_init>:
{
    800060a8:	1101                	addi	sp,sp,-32
    800060aa:	ec06                	sd	ra,24(sp)
    800060ac:	e822                	sd	s0,16(sp)
    800060ae:	e426                	sd	s1,8(sp)
    800060b0:	e04a                	sd	s2,0(sp)
    800060b2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060b4:	00002597          	auipc	a1,0x2
    800060b8:	6ac58593          	addi	a1,a1,1708 # 80008760 <syscalls+0x310>
    800060bc:	0001d517          	auipc	a0,0x1d
    800060c0:	28c50513          	addi	a0,a0,652 # 80023348 <disk+0x128>
    800060c4:	ffffb097          	auipc	ra,0xffffb
    800060c8:	a82080e7          	jalr	-1406(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060cc:	100017b7          	lui	a5,0x10001
    800060d0:	4398                	lw	a4,0(a5)
    800060d2:	2701                	sext.w	a4,a4
    800060d4:	747277b7          	lui	a5,0x74727
    800060d8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060dc:	14f71c63          	bne	a4,a5,80006234 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060e0:	100017b7          	lui	a5,0x10001
    800060e4:	43dc                	lw	a5,4(a5)
    800060e6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060e8:	4709                	li	a4,2
    800060ea:	14e79563          	bne	a5,a4,80006234 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060ee:	100017b7          	lui	a5,0x10001
    800060f2:	479c                	lw	a5,8(a5)
    800060f4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060f6:	12e79f63          	bne	a5,a4,80006234 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060fa:	100017b7          	lui	a5,0x10001
    800060fe:	47d8                	lw	a4,12(a5)
    80006100:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006102:	554d47b7          	lui	a5,0x554d4
    80006106:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000610a:	12f71563          	bne	a4,a5,80006234 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000610e:	100017b7          	lui	a5,0x10001
    80006112:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006116:	4705                	li	a4,1
    80006118:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000611a:	470d                	li	a4,3
    8000611c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000611e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006120:	c7ffe737          	lui	a4,0xc7ffe
    80006124:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb3ff>
    80006128:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000612a:	2701                	sext.w	a4,a4
    8000612c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000612e:	472d                	li	a4,11
    80006130:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006132:	5bbc                	lw	a5,112(a5)
    80006134:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006138:	8ba1                	andi	a5,a5,8
    8000613a:	10078563          	beqz	a5,80006244 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000613e:	100017b7          	lui	a5,0x10001
    80006142:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006146:	43fc                	lw	a5,68(a5)
    80006148:	2781                	sext.w	a5,a5
    8000614a:	10079563          	bnez	a5,80006254 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000614e:	100017b7          	lui	a5,0x10001
    80006152:	5bdc                	lw	a5,52(a5)
    80006154:	2781                	sext.w	a5,a5
  if(max == 0)
    80006156:	10078763          	beqz	a5,80006264 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000615a:	471d                	li	a4,7
    8000615c:	10f77c63          	bgeu	a4,a5,80006274 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006160:	ffffb097          	auipc	ra,0xffffb
    80006164:	986080e7          	jalr	-1658(ra) # 80000ae6 <kalloc>
    80006168:	0001d497          	auipc	s1,0x1d
    8000616c:	0b848493          	addi	s1,s1,184 # 80023220 <disk>
    80006170:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006172:	ffffb097          	auipc	ra,0xffffb
    80006176:	974080e7          	jalr	-1676(ra) # 80000ae6 <kalloc>
    8000617a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000617c:	ffffb097          	auipc	ra,0xffffb
    80006180:	96a080e7          	jalr	-1686(ra) # 80000ae6 <kalloc>
    80006184:	87aa                	mv	a5,a0
    80006186:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006188:	6088                	ld	a0,0(s1)
    8000618a:	cd6d                	beqz	a0,80006284 <virtio_disk_init+0x1dc>
    8000618c:	0001d717          	auipc	a4,0x1d
    80006190:	09c73703          	ld	a4,156(a4) # 80023228 <disk+0x8>
    80006194:	cb65                	beqz	a4,80006284 <virtio_disk_init+0x1dc>
    80006196:	c7fd                	beqz	a5,80006284 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006198:	6605                	lui	a2,0x1
    8000619a:	4581                	li	a1,0
    8000619c:	ffffb097          	auipc	ra,0xffffb
    800061a0:	b36080e7          	jalr	-1226(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800061a4:	0001d497          	auipc	s1,0x1d
    800061a8:	07c48493          	addi	s1,s1,124 # 80023220 <disk>
    800061ac:	6605                	lui	a2,0x1
    800061ae:	4581                	li	a1,0
    800061b0:	6488                	ld	a0,8(s1)
    800061b2:	ffffb097          	auipc	ra,0xffffb
    800061b6:	b20080e7          	jalr	-1248(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800061ba:	6605                	lui	a2,0x1
    800061bc:	4581                	li	a1,0
    800061be:	6888                	ld	a0,16(s1)
    800061c0:	ffffb097          	auipc	ra,0xffffb
    800061c4:	b12080e7          	jalr	-1262(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061c8:	100017b7          	lui	a5,0x10001
    800061cc:	4721                	li	a4,8
    800061ce:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800061d0:	4098                	lw	a4,0(s1)
    800061d2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800061d6:	40d8                	lw	a4,4(s1)
    800061d8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800061dc:	6498                	ld	a4,8(s1)
    800061de:	0007069b          	sext.w	a3,a4
    800061e2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800061e6:	9701                	srai	a4,a4,0x20
    800061e8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800061ec:	6898                	ld	a4,16(s1)
    800061ee:	0007069b          	sext.w	a3,a4
    800061f2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800061f6:	9701                	srai	a4,a4,0x20
    800061f8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800061fc:	4705                	li	a4,1
    800061fe:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006200:	00e48c23          	sb	a4,24(s1)
    80006204:	00e48ca3          	sb	a4,25(s1)
    80006208:	00e48d23          	sb	a4,26(s1)
    8000620c:	00e48da3          	sb	a4,27(s1)
    80006210:	00e48e23          	sb	a4,28(s1)
    80006214:	00e48ea3          	sb	a4,29(s1)
    80006218:	00e48f23          	sb	a4,30(s1)
    8000621c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006220:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006224:	0727a823          	sw	s2,112(a5)
}
    80006228:	60e2                	ld	ra,24(sp)
    8000622a:	6442                	ld	s0,16(sp)
    8000622c:	64a2                	ld	s1,8(sp)
    8000622e:	6902                	ld	s2,0(sp)
    80006230:	6105                	addi	sp,sp,32
    80006232:	8082                	ret
    panic("could not find virtio disk");
    80006234:	00002517          	auipc	a0,0x2
    80006238:	53c50513          	addi	a0,a0,1340 # 80008770 <syscalls+0x320>
    8000623c:	ffffa097          	auipc	ra,0xffffa
    80006240:	302080e7          	jalr	770(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006244:	00002517          	auipc	a0,0x2
    80006248:	54c50513          	addi	a0,a0,1356 # 80008790 <syscalls+0x340>
    8000624c:	ffffa097          	auipc	ra,0xffffa
    80006250:	2f2080e7          	jalr	754(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006254:	00002517          	auipc	a0,0x2
    80006258:	55c50513          	addi	a0,a0,1372 # 800087b0 <syscalls+0x360>
    8000625c:	ffffa097          	auipc	ra,0xffffa
    80006260:	2e2080e7          	jalr	738(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006264:	00002517          	auipc	a0,0x2
    80006268:	56c50513          	addi	a0,a0,1388 # 800087d0 <syscalls+0x380>
    8000626c:	ffffa097          	auipc	ra,0xffffa
    80006270:	2d2080e7          	jalr	722(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006274:	00002517          	auipc	a0,0x2
    80006278:	57c50513          	addi	a0,a0,1404 # 800087f0 <syscalls+0x3a0>
    8000627c:	ffffa097          	auipc	ra,0xffffa
    80006280:	2c2080e7          	jalr	706(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006284:	00002517          	auipc	a0,0x2
    80006288:	58c50513          	addi	a0,a0,1420 # 80008810 <syscalls+0x3c0>
    8000628c:	ffffa097          	auipc	ra,0xffffa
    80006290:	2b2080e7          	jalr	690(ra) # 8000053e <panic>

0000000080006294 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006294:	7119                	addi	sp,sp,-128
    80006296:	fc86                	sd	ra,120(sp)
    80006298:	f8a2                	sd	s0,112(sp)
    8000629a:	f4a6                	sd	s1,104(sp)
    8000629c:	f0ca                	sd	s2,96(sp)
    8000629e:	ecce                	sd	s3,88(sp)
    800062a0:	e8d2                	sd	s4,80(sp)
    800062a2:	e4d6                	sd	s5,72(sp)
    800062a4:	e0da                	sd	s6,64(sp)
    800062a6:	fc5e                	sd	s7,56(sp)
    800062a8:	f862                	sd	s8,48(sp)
    800062aa:	f466                	sd	s9,40(sp)
    800062ac:	f06a                	sd	s10,32(sp)
    800062ae:	ec6e                	sd	s11,24(sp)
    800062b0:	0100                	addi	s0,sp,128
    800062b2:	8aaa                	mv	s5,a0
    800062b4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062b6:	00c52d03          	lw	s10,12(a0)
    800062ba:	001d1d1b          	slliw	s10,s10,0x1
    800062be:	1d02                	slli	s10,s10,0x20
    800062c0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800062c4:	0001d517          	auipc	a0,0x1d
    800062c8:	08450513          	addi	a0,a0,132 # 80023348 <disk+0x128>
    800062cc:	ffffb097          	auipc	ra,0xffffb
    800062d0:	90a080e7          	jalr	-1782(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800062d4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800062d6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800062d8:	0001db97          	auipc	s7,0x1d
    800062dc:	f48b8b93          	addi	s7,s7,-184 # 80023220 <disk>
  for(int i = 0; i < 3; i++){
    800062e0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062e2:	0001dc97          	auipc	s9,0x1d
    800062e6:	066c8c93          	addi	s9,s9,102 # 80023348 <disk+0x128>
    800062ea:	a08d                	j	8000634c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800062ec:	00fb8733          	add	a4,s7,a5
    800062f0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800062f4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800062f6:	0207c563          	bltz	a5,80006320 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800062fa:	2905                	addiw	s2,s2,1
    800062fc:	0611                	addi	a2,a2,4
    800062fe:	05690c63          	beq	s2,s6,80006356 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006302:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006304:	0001d717          	auipc	a4,0x1d
    80006308:	f1c70713          	addi	a4,a4,-228 # 80023220 <disk>
    8000630c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000630e:	01874683          	lbu	a3,24(a4)
    80006312:	fee9                	bnez	a3,800062ec <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006314:	2785                	addiw	a5,a5,1
    80006316:	0705                	addi	a4,a4,1
    80006318:	fe979be3          	bne	a5,s1,8000630e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000631c:	57fd                	li	a5,-1
    8000631e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006320:	01205d63          	blez	s2,8000633a <virtio_disk_rw+0xa6>
    80006324:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006326:	000a2503          	lw	a0,0(s4)
    8000632a:	00000097          	auipc	ra,0x0
    8000632e:	cfc080e7          	jalr	-772(ra) # 80006026 <free_desc>
      for(int j = 0; j < i; j++)
    80006332:	2d85                	addiw	s11,s11,1
    80006334:	0a11                	addi	s4,s4,4
    80006336:	ffb918e3          	bne	s2,s11,80006326 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000633a:	85e6                	mv	a1,s9
    8000633c:	0001d517          	auipc	a0,0x1d
    80006340:	efc50513          	addi	a0,a0,-260 # 80023238 <disk+0x18>
    80006344:	ffffc097          	auipc	ra,0xffffc
    80006348:	df8080e7          	jalr	-520(ra) # 8000213c <sleep>
  for(int i = 0; i < 3; i++){
    8000634c:	f8040a13          	addi	s4,s0,-128
{
    80006350:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006352:	894e                	mv	s2,s3
    80006354:	b77d                	j	80006302 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006356:	f8042583          	lw	a1,-128(s0)
    8000635a:	00a58793          	addi	a5,a1,10
    8000635e:	0792                	slli	a5,a5,0x4

  if(write)
    80006360:	0001d617          	auipc	a2,0x1d
    80006364:	ec060613          	addi	a2,a2,-320 # 80023220 <disk>
    80006368:	00f60733          	add	a4,a2,a5
    8000636c:	018036b3          	snez	a3,s8
    80006370:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006372:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006376:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000637a:	f6078693          	addi	a3,a5,-160
    8000637e:	6218                	ld	a4,0(a2)
    80006380:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006382:	00878513          	addi	a0,a5,8
    80006386:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006388:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000638a:	6208                	ld	a0,0(a2)
    8000638c:	96aa                	add	a3,a3,a0
    8000638e:	4741                	li	a4,16
    80006390:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006392:	4705                	li	a4,1
    80006394:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006398:	f8442703          	lw	a4,-124(s0)
    8000639c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063a0:	0712                	slli	a4,a4,0x4
    800063a2:	953a                	add	a0,a0,a4
    800063a4:	058a8693          	addi	a3,s5,88
    800063a8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800063aa:	6208                	ld	a0,0(a2)
    800063ac:	972a                	add	a4,a4,a0
    800063ae:	40000693          	li	a3,1024
    800063b2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063b4:	001c3c13          	seqz	s8,s8
    800063b8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063ba:	001c6c13          	ori	s8,s8,1
    800063be:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800063c2:	f8842603          	lw	a2,-120(s0)
    800063c6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063ca:	0001d697          	auipc	a3,0x1d
    800063ce:	e5668693          	addi	a3,a3,-426 # 80023220 <disk>
    800063d2:	00258713          	addi	a4,a1,2
    800063d6:	0712                	slli	a4,a4,0x4
    800063d8:	9736                	add	a4,a4,a3
    800063da:	587d                	li	a6,-1
    800063dc:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063e0:	0612                	slli	a2,a2,0x4
    800063e2:	9532                	add	a0,a0,a2
    800063e4:	f9078793          	addi	a5,a5,-112
    800063e8:	97b6                	add	a5,a5,a3
    800063ea:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800063ec:	629c                	ld	a5,0(a3)
    800063ee:	97b2                	add	a5,a5,a2
    800063f0:	4605                	li	a2,1
    800063f2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063f4:	4509                	li	a0,2
    800063f6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800063fa:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063fe:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006402:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006406:	6698                	ld	a4,8(a3)
    80006408:	00275783          	lhu	a5,2(a4)
    8000640c:	8b9d                	andi	a5,a5,7
    8000640e:	0786                	slli	a5,a5,0x1
    80006410:	97ba                	add	a5,a5,a4
    80006412:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006416:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000641a:	6698                	ld	a4,8(a3)
    8000641c:	00275783          	lhu	a5,2(a4)
    80006420:	2785                	addiw	a5,a5,1
    80006422:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006426:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000642a:	100017b7          	lui	a5,0x10001
    8000642e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006432:	004aa783          	lw	a5,4(s5)
    80006436:	02c79163          	bne	a5,a2,80006458 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000643a:	0001d917          	auipc	s2,0x1d
    8000643e:	f0e90913          	addi	s2,s2,-242 # 80023348 <disk+0x128>
  while(b->disk == 1) {
    80006442:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006444:	85ca                	mv	a1,s2
    80006446:	8556                	mv	a0,s5
    80006448:	ffffc097          	auipc	ra,0xffffc
    8000644c:	cf4080e7          	jalr	-780(ra) # 8000213c <sleep>
  while(b->disk == 1) {
    80006450:	004aa783          	lw	a5,4(s5)
    80006454:	fe9788e3          	beq	a5,s1,80006444 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006458:	f8042903          	lw	s2,-128(s0)
    8000645c:	00290793          	addi	a5,s2,2
    80006460:	00479713          	slli	a4,a5,0x4
    80006464:	0001d797          	auipc	a5,0x1d
    80006468:	dbc78793          	addi	a5,a5,-580 # 80023220 <disk>
    8000646c:	97ba                	add	a5,a5,a4
    8000646e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006472:	0001d997          	auipc	s3,0x1d
    80006476:	dae98993          	addi	s3,s3,-594 # 80023220 <disk>
    8000647a:	00491713          	slli	a4,s2,0x4
    8000647e:	0009b783          	ld	a5,0(s3)
    80006482:	97ba                	add	a5,a5,a4
    80006484:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006488:	854a                	mv	a0,s2
    8000648a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000648e:	00000097          	auipc	ra,0x0
    80006492:	b98080e7          	jalr	-1128(ra) # 80006026 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006496:	8885                	andi	s1,s1,1
    80006498:	f0ed                	bnez	s1,8000647a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000649a:	0001d517          	auipc	a0,0x1d
    8000649e:	eae50513          	addi	a0,a0,-338 # 80023348 <disk+0x128>
    800064a2:	ffffa097          	auipc	ra,0xffffa
    800064a6:	7e8080e7          	jalr	2024(ra) # 80000c8a <release>
}
    800064aa:	70e6                	ld	ra,120(sp)
    800064ac:	7446                	ld	s0,112(sp)
    800064ae:	74a6                	ld	s1,104(sp)
    800064b0:	7906                	ld	s2,96(sp)
    800064b2:	69e6                	ld	s3,88(sp)
    800064b4:	6a46                	ld	s4,80(sp)
    800064b6:	6aa6                	ld	s5,72(sp)
    800064b8:	6b06                	ld	s6,64(sp)
    800064ba:	7be2                	ld	s7,56(sp)
    800064bc:	7c42                	ld	s8,48(sp)
    800064be:	7ca2                	ld	s9,40(sp)
    800064c0:	7d02                	ld	s10,32(sp)
    800064c2:	6de2                	ld	s11,24(sp)
    800064c4:	6109                	addi	sp,sp,128
    800064c6:	8082                	ret

00000000800064c8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064c8:	1101                	addi	sp,sp,-32
    800064ca:	ec06                	sd	ra,24(sp)
    800064cc:	e822                	sd	s0,16(sp)
    800064ce:	e426                	sd	s1,8(sp)
    800064d0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064d2:	0001d497          	auipc	s1,0x1d
    800064d6:	d4e48493          	addi	s1,s1,-690 # 80023220 <disk>
    800064da:	0001d517          	auipc	a0,0x1d
    800064de:	e6e50513          	addi	a0,a0,-402 # 80023348 <disk+0x128>
    800064e2:	ffffa097          	auipc	ra,0xffffa
    800064e6:	6f4080e7          	jalr	1780(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064ea:	10001737          	lui	a4,0x10001
    800064ee:	533c                	lw	a5,96(a4)
    800064f0:	8b8d                	andi	a5,a5,3
    800064f2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800064f4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800064f8:	689c                	ld	a5,16(s1)
    800064fa:	0204d703          	lhu	a4,32(s1)
    800064fe:	0027d783          	lhu	a5,2(a5)
    80006502:	04f70863          	beq	a4,a5,80006552 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006506:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000650a:	6898                	ld	a4,16(s1)
    8000650c:	0204d783          	lhu	a5,32(s1)
    80006510:	8b9d                	andi	a5,a5,7
    80006512:	078e                	slli	a5,a5,0x3
    80006514:	97ba                	add	a5,a5,a4
    80006516:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006518:	00278713          	addi	a4,a5,2
    8000651c:	0712                	slli	a4,a4,0x4
    8000651e:	9726                	add	a4,a4,s1
    80006520:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006524:	e721                	bnez	a4,8000656c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006526:	0789                	addi	a5,a5,2
    80006528:	0792                	slli	a5,a5,0x4
    8000652a:	97a6                	add	a5,a5,s1
    8000652c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000652e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006532:	ffffc097          	auipc	ra,0xffffc
    80006536:	c8a080e7          	jalr	-886(ra) # 800021bc <wakeup>

    disk.used_idx += 1;
    8000653a:	0204d783          	lhu	a5,32(s1)
    8000653e:	2785                	addiw	a5,a5,1
    80006540:	17c2                	slli	a5,a5,0x30
    80006542:	93c1                	srli	a5,a5,0x30
    80006544:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006548:	6898                	ld	a4,16(s1)
    8000654a:	00275703          	lhu	a4,2(a4)
    8000654e:	faf71ce3          	bne	a4,a5,80006506 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006552:	0001d517          	auipc	a0,0x1d
    80006556:	df650513          	addi	a0,a0,-522 # 80023348 <disk+0x128>
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	730080e7          	jalr	1840(ra) # 80000c8a <release>
}
    80006562:	60e2                	ld	ra,24(sp)
    80006564:	6442                	ld	s0,16(sp)
    80006566:	64a2                	ld	s1,8(sp)
    80006568:	6105                	addi	sp,sp,32
    8000656a:	8082                	ret
      panic("virtio_disk_intr status");
    8000656c:	00002517          	auipc	a0,0x2
    80006570:	2bc50513          	addi	a0,a0,700 # 80008828 <syscalls+0x3d8>
    80006574:	ffffa097          	auipc	ra,0xffffa
    80006578:	fca080e7          	jalr	-54(ra) # 8000053e <panic>
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
