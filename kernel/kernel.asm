
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
    80000068:	c1c78793          	addi	a5,a5,-996 # 80005c80 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc69f>
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
    80000130:	36c080e7          	jalr	876(ra) # 80002498 <either_copyin>
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
    800001cc:	11a080e7          	jalr	282(ra) # 800022e2 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e64080e7          	jalr	-412(ra) # 8000203a <sleep>
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
    80000216:	230080e7          	jalr	560(ra) # 80002442 <either_copyout>
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
    800002f6:	1fc080e7          	jalr	508(ra) # 800024ee <procdump>
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
    8000044a:	c58080e7          	jalr	-936(ra) # 8000209e <wakeup>
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
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	b5078793          	addi	a5,a5,-1200 # 80020fc8 <devsw>
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
    80000896:	80c080e7          	jalr	-2036(ra) # 8000209e <wakeup>
    
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
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	71e080e7          	jalr	1822(ra) # 8000203a <sleep>
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
    800009fe:	00021797          	auipc	a5,0x21
    80000a02:	76278793          	addi	a5,a5,1890 # 80022160 <end>
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
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	69250513          	addi	a0,a0,1682 # 80022160 <end>
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
    80000ec2:	814080e7          	jalr	-2028(ra) # 800026d2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	dfa080e7          	jalr	-518(ra) # 80005cc0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fba080e7          	jalr	-70(ra) # 80001e88 <scheduler>
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
    80000f36:	00001097          	auipc	ra,0x1
    80000f3a:	774080e7          	jalr	1908(ra) # 800026aa <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	794080e7          	jalr	1940(ra) # 800026d2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	d64080e7          	jalr	-668(ra) # 80005caa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	d72080e7          	jalr	-654(ra) # 80005cc0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	f02080e7          	jalr	-254(ra) # 80002e58 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	5a6080e7          	jalr	1446(ra) # 80003504 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	544080e7          	jalr	1348(ra) # 800044aa <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	e5a080e7          	jalr	-422(ra) # 80005dc8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	cec080e7          	jalr	-788(ra) # 80001c62 <userinit>
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
    80001868:	00015a97          	auipc	s5,0x15
    8000186c:	518a8a93          	addi	s5,s5,1304 # 80016d80 <tickslock>
      uint64 va = KSTACK((int) ((p - proc) * NKT + (kt - p->kthread)));
    80001870:	417904b3          	sub	s1,s2,s7
    80001874:	848d                	srai	s1,s1,0x3
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
    800018a0:	17890913          	addi	s2,s2,376
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
    8000191c:	00015917          	auipc	s2,0x15
    80001920:	46490913          	addi	s2,s2,1124 # 80016d80 <tickslock>
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
    8000193a:	c66080e7          	jalr	-922(ra) # 8000259c <kthreadinit>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193e:	17848493          	addi	s1,s1,376
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
    80001988:	1000                	addi	s0,sp,32
  push_off();
    8000198a:	fffff097          	auipc	ra,0xfffff
    8000198e:	200080e7          	jalr	512(ra) # 80000b8a <push_off>
    80001992:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001994:	2781                	sext.w	a5,a5
    80001996:	079e                	slli	a5,a5,0x7
    80001998:	0000f717          	auipc	a4,0xf
    8000199c:	1b870713          	addi	a4,a4,440 # 80010b50 <pid_lock>
    800019a0:	97ba                	add	a5,a5,a4
    800019a2:	7b84                	ld	s1,48(a5)
  pop_off();
    800019a4:	fffff097          	auipc	ra,0xfffff
    800019a8:	286080e7          	jalr	646(ra) # 80000c2a <pop_off>
  return p;
}
    800019ac:	8526                	mv	a0,s1
    800019ae:	60e2                	ld	ra,24(sp)
    800019b0:	6442                	ld	s0,16(sp)
    800019b2:	64a2                	ld	s1,8(sp)
    800019b4:	6105                	addi	sp,sp,32
    800019b6:	8082                	ret

00000000800019b8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019b8:	1141                	addi	sp,sp,-16
    800019ba:	e406                	sd	ra,8(sp)
    800019bc:	e022                	sd	s0,0(sp)
    800019be:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019c0:	00000097          	auipc	ra,0x0
    800019c4:	fc0080e7          	jalr	-64(ra) # 80001980 <myproc>
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	2c2080e7          	jalr	706(ra) # 80000c8a <release>

  if (first) {
    800019d0:	00007797          	auipc	a5,0x7
    800019d4:	e707a783          	lw	a5,-400(a5) # 80008840 <first.1>
    800019d8:	eb89                	bnez	a5,800019ea <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019da:	00001097          	auipc	ra,0x1
    800019de:	d10080e7          	jalr	-752(ra) # 800026ea <usertrapret>
}
    800019e2:	60a2                	ld	ra,8(sp)
    800019e4:	6402                	ld	s0,0(sp)
    800019e6:	0141                	addi	sp,sp,16
    800019e8:	8082                	ret
    first = 0;
    800019ea:	00007797          	auipc	a5,0x7
    800019ee:	e407ab23          	sw	zero,-426(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    800019f2:	4505                	li	a0,1
    800019f4:	00002097          	auipc	ra,0x2
    800019f8:	a90080e7          	jalr	-1392(ra) # 80003484 <fsinit>
    800019fc:	bff9                	j	800019da <forkret+0x22>

00000000800019fe <allocpid>:
{
    800019fe:	1101                	addi	sp,sp,-32
    80001a00:	ec06                	sd	ra,24(sp)
    80001a02:	e822                	sd	s0,16(sp)
    80001a04:	e426                	sd	s1,8(sp)
    80001a06:	e04a                	sd	s2,0(sp)
    80001a08:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a0a:	0000f917          	auipc	s2,0xf
    80001a0e:	14690913          	addi	s2,s2,326 # 80010b50 <pid_lock>
    80001a12:	854a                	mv	a0,s2
    80001a14:	fffff097          	auipc	ra,0xfffff
    80001a18:	1c2080e7          	jalr	450(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a1c:	00007797          	auipc	a5,0x7
    80001a20:	e2878793          	addi	a5,a5,-472 # 80008844 <nextpid>
    80001a24:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a26:	0014871b          	addiw	a4,s1,1
    80001a2a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a2c:	854a                	mv	a0,s2
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	25c080e7          	jalr	604(ra) # 80000c8a <release>
}
    80001a36:	8526                	mv	a0,s1
    80001a38:	60e2                	ld	ra,24(sp)
    80001a3a:	6442                	ld	s0,16(sp)
    80001a3c:	64a2                	ld	s1,8(sp)
    80001a3e:	6902                	ld	s2,0(sp)
    80001a40:	6105                	addi	sp,sp,32
    80001a42:	8082                	ret

0000000080001a44 <proc_pagetable>:
{
    80001a44:	1101                	addi	sp,sp,-32
    80001a46:	ec06                	sd	ra,24(sp)
    80001a48:	e822                	sd	s0,16(sp)
    80001a4a:	e426                	sd	s1,8(sp)
    80001a4c:	e04a                	sd	s2,0(sp)
    80001a4e:	1000                	addi	s0,sp,32
    80001a50:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a52:	00000097          	auipc	ra,0x0
    80001a56:	8d6080e7          	jalr	-1834(ra) # 80001328 <uvmcreate>
    80001a5a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a5c:	c121                	beqz	a0,80001a9c <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a5e:	4729                	li	a4,10
    80001a60:	00005697          	auipc	a3,0x5
    80001a64:	5a068693          	addi	a3,a3,1440 # 80007000 <_trampoline>
    80001a68:	6605                	lui	a2,0x1
    80001a6a:	040005b7          	lui	a1,0x4000
    80001a6e:	15fd                	addi	a1,a1,-1
    80001a70:	05b2                	slli	a1,a1,0xc
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	62c080e7          	jalr	1580(ra) # 8000109e <mappages>
    80001a7a:	02054863          	bltz	a0,80001aaa <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME(0), PGSIZE,
    80001a7e:	4719                	li	a4,6
    80001a80:	04893683          	ld	a3,72(s2)
    80001a84:	6605                	lui	a2,0x1
    80001a86:	020005b7          	lui	a1,0x2000
    80001a8a:	15fd                	addi	a1,a1,-1
    80001a8c:	05b6                	slli	a1,a1,0xd
    80001a8e:	8526                	mv	a0,s1
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	60e080e7          	jalr	1550(ra) # 8000109e <mappages>
    80001a98:	02054163          	bltz	a0,80001aba <proc_pagetable+0x76>
}
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	60e2                	ld	ra,24(sp)
    80001aa0:	6442                	ld	s0,16(sp)
    80001aa2:	64a2                	ld	s1,8(sp)
    80001aa4:	6902                	ld	s2,0(sp)
    80001aa6:	6105                	addi	sp,sp,32
    80001aa8:	8082                	ret
    uvmfree(pagetable, 0);
    80001aaa:	4581                	li	a1,0
    80001aac:	8526                	mv	a0,s1
    80001aae:	00000097          	auipc	ra,0x0
    80001ab2:	a7e080e7          	jalr	-1410(ra) # 8000152c <uvmfree>
    return 0;
    80001ab6:	4481                	li	s1,0
    80001ab8:	b7d5                	j	80001a9c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aba:	4681                	li	a3,0
    80001abc:	4605                	li	a2,1
    80001abe:	040005b7          	lui	a1,0x4000
    80001ac2:	15fd                	addi	a1,a1,-1
    80001ac4:	05b2                	slli	a1,a1,0xc
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	fffff097          	auipc	ra,0xfffff
    80001acc:	79c080e7          	jalr	1948(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ad0:	4581                	li	a1,0
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	a58080e7          	jalr	-1448(ra) # 8000152c <uvmfree>
    return 0;
    80001adc:	4481                	li	s1,0
    80001ade:	bf7d                	j	80001a9c <proc_pagetable+0x58>

0000000080001ae0 <proc_freepagetable>:
{
    80001ae0:	1101                	addi	sp,sp,-32
    80001ae2:	ec06                	sd	ra,24(sp)
    80001ae4:	e822                	sd	s0,16(sp)
    80001ae6:	e426                	sd	s1,8(sp)
    80001ae8:	e04a                	sd	s2,0(sp)
    80001aea:	1000                	addi	s0,sp,32
    80001aec:	84aa                	mv	s1,a0
    80001aee:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001af0:	4681                	li	a3,0
    80001af2:	4605                	li	a2,1
    80001af4:	040005b7          	lui	a1,0x4000
    80001af8:	15fd                	addi	a1,a1,-1
    80001afa:	05b2                	slli	a1,a1,0xc
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	768080e7          	jalr	1896(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME(0), 1, 0);
    80001b04:	4681                	li	a3,0
    80001b06:	4605                	li	a2,1
    80001b08:	020005b7          	lui	a1,0x2000
    80001b0c:	15fd                	addi	a1,a1,-1
    80001b0e:	05b6                	slli	a1,a1,0xd
    80001b10:	8526                	mv	a0,s1
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	752080e7          	jalr	1874(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b1a:	85ca                	mv	a1,s2
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	00000097          	auipc	ra,0x0
    80001b22:	a0e080e7          	jalr	-1522(ra) # 8000152c <uvmfree>
}
    80001b26:	60e2                	ld	ra,24(sp)
    80001b28:	6442                	ld	s0,16(sp)
    80001b2a:	64a2                	ld	s1,8(sp)
    80001b2c:	6902                	ld	s2,0(sp)
    80001b2e:	6105                	addi	sp,sp,32
    80001b30:	8082                	ret

0000000080001b32 <freeproc>:
{
    80001b32:	1101                	addi	sp,sp,-32
    80001b34:	ec06                	sd	ra,24(sp)
    80001b36:	e822                	sd	s0,16(sp)
    80001b38:	e426                	sd	s1,8(sp)
    80001b3a:	1000                	addi	s0,sp,32
    80001b3c:	84aa                	mv	s1,a0
  if(p->base_trapframes)
    80001b3e:	6528                	ld	a0,72(a0)
    80001b40:	c509                	beqz	a0,80001b4a <freeproc+0x18>
    kfree((void*)p->base_trapframes);
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	ea8080e7          	jalr	-344(ra) # 800009ea <kfree>
  p->base_trapframes = 0;
    80001b4a:	0404b423          	sd	zero,72(s1)
  if(p->pagetable)
    80001b4e:	74a8                	ld	a0,104(s1)
    80001b50:	c511                	beqz	a0,80001b5c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b52:	70ac                	ld	a1,96(s1)
    80001b54:	00000097          	auipc	ra,0x0
    80001b58:	f8c080e7          	jalr	-116(ra) # 80001ae0 <proc_freepagetable>
  p->pagetable = 0;
    80001b5c:	0604b423          	sd	zero,104(s1)
  p->sz = 0;
    80001b60:	0604b023          	sd	zero,96(s1)
  p->pid = 0;
    80001b64:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b68:	0404b823          	sd	zero,80(s1)
  p->name[0] = 0;
    80001b6c:	16048423          	sb	zero,360(s1)
  p->chan = 0;
    80001b70:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b74:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b78:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b7c:	0004ac23          	sw	zero,24(s1)
}
    80001b80:	60e2                	ld	ra,24(sp)
    80001b82:	6442                	ld	s0,16(sp)
    80001b84:	64a2                	ld	s1,8(sp)
    80001b86:	6105                	addi	sp,sp,32
    80001b88:	8082                	ret

0000000080001b8a <allocproc>:
{
    80001b8a:	1101                	addi	sp,sp,-32
    80001b8c:	ec06                	sd	ra,24(sp)
    80001b8e:	e822                	sd	s0,16(sp)
    80001b90:	e426                	sd	s1,8(sp)
    80001b92:	e04a                	sd	s2,0(sp)
    80001b94:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b96:	0000f497          	auipc	s1,0xf
    80001b9a:	3ea48493          	addi	s1,s1,1002 # 80010f80 <proc>
    80001b9e:	00015917          	auipc	s2,0x15
    80001ba2:	1e290913          	addi	s2,s2,482 # 80016d80 <tickslock>
    acquire(&p->lock);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	02e080e7          	jalr	46(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bb0:	4c9c                	lw	a5,24(s1)
    80001bb2:	cf81                	beqz	a5,80001bca <allocproc+0x40>
      release(&p->lock);
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	fffff097          	auipc	ra,0xfffff
    80001bba:	0d4080e7          	jalr	212(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbe:	17848493          	addi	s1,s1,376
    80001bc2:	ff2492e3          	bne	s1,s2,80001ba6 <allocproc+0x1c>
  return 0;
    80001bc6:	4481                	li	s1,0
    80001bc8:	a8b1                	j	80001c24 <allocproc+0x9a>
  p->pid = allocpid();
    80001bca:	00000097          	auipc	ra,0x0
    80001bce:	e34080e7          	jalr	-460(ra) # 800019fe <allocpid>
    80001bd2:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bd4:	4785                	li	a5,1
    80001bd6:	cc9c                	sw	a5,24(s1)
  if((p->base_trapframes = (struct trapframe *)kalloc()) == 0){
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	f0e080e7          	jalr	-242(ra) # 80000ae6 <kalloc>
    80001be0:	892a                	mv	s2,a0
    80001be2:	e4a8                	sd	a0,72(s1)
    80001be4:	c539                	beqz	a0,80001c32 <allocproc+0xa8>
  p->pagetable = proc_pagetable(p);
    80001be6:	8526                	mv	a0,s1
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	e5c080e7          	jalr	-420(ra) # 80001a44 <proc_pagetable>
    80001bf0:	892a                	mv	s2,a0
    80001bf2:	f4a8                	sd	a0,104(s1)
  if(p->pagetable == 0){
    80001bf4:	c939                	beqz	a0,80001c4a <allocproc+0xc0>
  memset(&p->context, 0, sizeof(p->context));
    80001bf6:	07000613          	li	a2,112
    80001bfa:	4581                	li	a1,0
    80001bfc:	07048513          	addi	a0,s1,112
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	0d2080e7          	jalr	210(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c08:	00000797          	auipc	a5,0x0
    80001c0c:	db078793          	addi	a5,a5,-592 # 800019b8 <forkret>
    80001c10:	f8bc                	sd	a5,112(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c12:	6cbc                	ld	a5,88(s1)
    80001c14:	6705                	lui	a4,0x1
    80001c16:	97ba                	add	a5,a5,a4
    80001c18:	fcbc                	sd	a5,120(s1)
  allocproc_help_function(p);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	00001097          	auipc	ra,0x1
    80001c20:	9f8080e7          	jalr	-1544(ra) # 80002614 <allocproc_help_function>
}
    80001c24:	8526                	mv	a0,s1
    80001c26:	60e2                	ld	ra,24(sp)
    80001c28:	6442                	ld	s0,16(sp)
    80001c2a:	64a2                	ld	s1,8(sp)
    80001c2c:	6902                	ld	s2,0(sp)
    80001c2e:	6105                	addi	sp,sp,32
    80001c30:	8082                	ret
    freeproc(p);
    80001c32:	8526                	mv	a0,s1
    80001c34:	00000097          	auipc	ra,0x0
    80001c38:	efe080e7          	jalr	-258(ra) # 80001b32 <freeproc>
    release(&p->lock);
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	04c080e7          	jalr	76(ra) # 80000c8a <release>
    return 0;
    80001c46:	84ca                	mv	s1,s2
    80001c48:	bff1                	j	80001c24 <allocproc+0x9a>
    freeproc(p);
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	00000097          	auipc	ra,0x0
    80001c50:	ee6080e7          	jalr	-282(ra) # 80001b32 <freeproc>
    release(&p->lock);
    80001c54:	8526                	mv	a0,s1
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	034080e7          	jalr	52(ra) # 80000c8a <release>
    return 0;
    80001c5e:	84ca                	mv	s1,s2
    80001c60:	b7d1                	j	80001c24 <allocproc+0x9a>

0000000080001c62 <userinit>:
{
    80001c62:	1101                	addi	sp,sp,-32
    80001c64:	ec06                	sd	ra,24(sp)
    80001c66:	e822                	sd	s0,16(sp)
    80001c68:	e426                	sd	s1,8(sp)
    80001c6a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c6c:	00000097          	auipc	ra,0x0
    80001c70:	f1e080e7          	jalr	-226(ra) # 80001b8a <allocproc>
    80001c74:	84aa                	mv	s1,a0
  initproc = p;
    80001c76:	00007797          	auipc	a5,0x7
    80001c7a:	c6a7b123          	sd	a0,-926(a5) # 800088d8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c7e:	03400613          	li	a2,52
    80001c82:	00007597          	auipc	a1,0x7
    80001c86:	bce58593          	addi	a1,a1,-1074 # 80008850 <initcode>
    80001c8a:	7528                	ld	a0,104(a0)
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	6ca080e7          	jalr	1738(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001c94:	6785                	lui	a5,0x1
    80001c96:	f0bc                	sd	a5,96(s1)
  p->kthread[0].trapframe->epc = 0;      // user program counter
    80001c98:	60b8                	ld	a4,64(s1)
    80001c9a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->kthread[0].trapframe->sp = PGSIZE;  // user stack pointer
    80001c9e:	60b8                	ld	a4,64(s1)
    80001ca0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ca2:	4641                	li	a2,16
    80001ca4:	00006597          	auipc	a1,0x6
    80001ca8:	55c58593          	addi	a1,a1,1372 # 80008200 <digits+0x1c0>
    80001cac:	16848513          	addi	a0,s1,360
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	16c080e7          	jalr	364(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cb8:	00006517          	auipc	a0,0x6
    80001cbc:	55850513          	addi	a0,a0,1368 # 80008210 <digits+0x1d0>
    80001cc0:	00002097          	auipc	ra,0x2
    80001cc4:	1e6080e7          	jalr	486(ra) # 80003ea6 <namei>
    80001cc8:	16a4b023          	sd	a0,352(s1)
  p->state = RUNNABLE;
    80001ccc:	478d                	li	a5,3
    80001cce:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cd0:	8526                	mv	a0,s1
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	fb8080e7          	jalr	-72(ra) # 80000c8a <release>
}
    80001cda:	60e2                	ld	ra,24(sp)
    80001cdc:	6442                	ld	s0,16(sp)
    80001cde:	64a2                	ld	s1,8(sp)
    80001ce0:	6105                	addi	sp,sp,32
    80001ce2:	8082                	ret

0000000080001ce4 <growproc>:
{
    80001ce4:	1101                	addi	sp,sp,-32
    80001ce6:	ec06                	sd	ra,24(sp)
    80001ce8:	e822                	sd	s0,16(sp)
    80001cea:	e426                	sd	s1,8(sp)
    80001cec:	e04a                	sd	s2,0(sp)
    80001cee:	1000                	addi	s0,sp,32
    80001cf0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001cf2:	00000097          	auipc	ra,0x0
    80001cf6:	c8e080e7          	jalr	-882(ra) # 80001980 <myproc>
    80001cfa:	84aa                	mv	s1,a0
  sz = p->sz;
    80001cfc:	712c                	ld	a1,96(a0)
  if(n > 0){
    80001cfe:	01204c63          	bgtz	s2,80001d16 <growproc+0x32>
  } else if(n < 0){
    80001d02:	02094663          	bltz	s2,80001d2e <growproc+0x4a>
  p->sz = sz;
    80001d06:	f0ac                	sd	a1,96(s1)
  return 0;
    80001d08:	4501                	li	a0,0
}
    80001d0a:	60e2                	ld	ra,24(sp)
    80001d0c:	6442                	ld	s0,16(sp)
    80001d0e:	64a2                	ld	s1,8(sp)
    80001d10:	6902                	ld	s2,0(sp)
    80001d12:	6105                	addi	sp,sp,32
    80001d14:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d16:	4691                	li	a3,4
    80001d18:	00b90633          	add	a2,s2,a1
    80001d1c:	7528                	ld	a0,104(a0)
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	6f2080e7          	jalr	1778(ra) # 80001410 <uvmalloc>
    80001d26:	85aa                	mv	a1,a0
    80001d28:	fd79                	bnez	a0,80001d06 <growproc+0x22>
      return -1;
    80001d2a:	557d                	li	a0,-1
    80001d2c:	bff9                	j	80001d0a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d2e:	00b90633          	add	a2,s2,a1
    80001d32:	7528                	ld	a0,104(a0)
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	694080e7          	jalr	1684(ra) # 800013c8 <uvmdealloc>
    80001d3c:	85aa                	mv	a1,a0
    80001d3e:	b7e1                	j	80001d06 <growproc+0x22>

0000000080001d40 <fork>:
{
    80001d40:	7139                	addi	sp,sp,-64
    80001d42:	fc06                	sd	ra,56(sp)
    80001d44:	f822                	sd	s0,48(sp)
    80001d46:	f426                	sd	s1,40(sp)
    80001d48:	f04a                	sd	s2,32(sp)
    80001d4a:	ec4e                	sd	s3,24(sp)
    80001d4c:	e852                	sd	s4,16(sp)
    80001d4e:	e456                	sd	s5,8(sp)
    80001d50:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d52:	00000097          	auipc	ra,0x0
    80001d56:	c2e080e7          	jalr	-978(ra) # 80001980 <myproc>
    80001d5a:	8aaa                	mv	s5,a0
  struct kthread *kt = mykthread();
    80001d5c:	00001097          	auipc	ra,0x1
    80001d60:	87a080e7          	jalr	-1926(ra) # 800025d6 <mykthread>
    80001d64:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){
    80001d66:	00000097          	auipc	ra,0x0
    80001d6a:	e24080e7          	jalr	-476(ra) # 80001b8a <allocproc>
    80001d6e:	10050b63          	beqz	a0,80001e84 <fork+0x144>
    80001d72:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d74:	060ab603          	ld	a2,96(s5)
    80001d78:	752c                	ld	a1,104(a0)
    80001d7a:	068ab503          	ld	a0,104(s5)
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	7e6080e7          	jalr	2022(ra) # 80001564 <uvmcopy>
    80001d86:	04054763          	bltz	a0,80001dd4 <fork+0x94>
  np->sz = p->sz;
    80001d8a:	060ab783          	ld	a5,96(s5)
    80001d8e:	06fa3023          	sd	a5,96(s4) # fffffffffffff060 <end+0xffffffff7ffdcf00>
  *(np->kthread[0].trapframe) = *(kt->trapframe);
    80001d92:	6494                	ld	a3,8(s1)
    80001d94:	87b6                	mv	a5,a3
    80001d96:	040a3703          	ld	a4,64(s4)
    80001d9a:	12068693          	addi	a3,a3,288
    80001d9e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001da2:	6788                	ld	a0,8(a5)
    80001da4:	6b8c                	ld	a1,16(a5)
    80001da6:	6f90                	ld	a2,24(a5)
    80001da8:	01073023          	sd	a6,0(a4)
    80001dac:	e708                	sd	a0,8(a4)
    80001dae:	eb0c                	sd	a1,16(a4)
    80001db0:	ef10                	sd	a2,24(a4)
    80001db2:	02078793          	addi	a5,a5,32
    80001db6:	02070713          	addi	a4,a4,32
    80001dba:	fed792e3          	bne	a5,a3,80001d9e <fork+0x5e>
  np->kthread[0].trapframe->a0 = 0;
    80001dbe:	040a3783          	ld	a5,64(s4)
    80001dc2:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dc6:	0e0a8493          	addi	s1,s5,224
    80001dca:	0e0a0913          	addi	s2,s4,224
    80001dce:	160a8993          	addi	s3,s5,352
    80001dd2:	a00d                	j	80001df4 <fork+0xb4>
    freeproc(np);
    80001dd4:	8552                	mv	a0,s4
    80001dd6:	00000097          	auipc	ra,0x0
    80001dda:	d5c080e7          	jalr	-676(ra) # 80001b32 <freeproc>
    release(&np->lock);
    80001dde:	8552                	mv	a0,s4
    80001de0:	fffff097          	auipc	ra,0xfffff
    80001de4:	eaa080e7          	jalr	-342(ra) # 80000c8a <release>
    return -1;
    80001de8:	597d                	li	s2,-1
    80001dea:	a059                	j	80001e70 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001dec:	04a1                	addi	s1,s1,8
    80001dee:	0921                	addi	s2,s2,8
    80001df0:	01348b63          	beq	s1,s3,80001e06 <fork+0xc6>
    if(p->ofile[i])
    80001df4:	6088                	ld	a0,0(s1)
    80001df6:	d97d                	beqz	a0,80001dec <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    80001df8:	00002097          	auipc	ra,0x2
    80001dfc:	744080e7          	jalr	1860(ra) # 8000453c <filedup>
    80001e00:	00a93023          	sd	a0,0(s2)
    80001e04:	b7e5                	j	80001dec <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e06:	160ab503          	ld	a0,352(s5)
    80001e0a:	00002097          	auipc	ra,0x2
    80001e0e:	8b8080e7          	jalr	-1864(ra) # 800036c2 <idup>
    80001e12:	16aa3023          	sd	a0,352(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e16:	4641                	li	a2,16
    80001e18:	168a8593          	addi	a1,s5,360
    80001e1c:	168a0513          	addi	a0,s4,360
    80001e20:	fffff097          	auipc	ra,0xfffff
    80001e24:	ffc080e7          	jalr	-4(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e28:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e2c:	8552                	mv	a0,s4
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	e5c080e7          	jalr	-420(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e36:	0000f497          	auipc	s1,0xf
    80001e3a:	d3248493          	addi	s1,s1,-718 # 80010b68 <wait_lock>
    80001e3e:	8526                	mv	a0,s1
    80001e40:	fffff097          	auipc	ra,0xfffff
    80001e44:	d96080e7          	jalr	-618(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e48:	055a3823          	sd	s5,80(s4)
  release(&wait_lock);
    80001e4c:	8526                	mv	a0,s1
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	e3c080e7          	jalr	-452(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e56:	8552                	mv	a0,s4
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	d7e080e7          	jalr	-642(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e60:	478d                	li	a5,3
    80001e62:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e66:	8552                	mv	a0,s4
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	e22080e7          	jalr	-478(ra) # 80000c8a <release>
}
    80001e70:	854a                	mv	a0,s2
    80001e72:	70e2                	ld	ra,56(sp)
    80001e74:	7442                	ld	s0,48(sp)
    80001e76:	74a2                	ld	s1,40(sp)
    80001e78:	7902                	ld	s2,32(sp)
    80001e7a:	69e2                	ld	s3,24(sp)
    80001e7c:	6a42                	ld	s4,16(sp)
    80001e7e:	6aa2                	ld	s5,8(sp)
    80001e80:	6121                	addi	sp,sp,64
    80001e82:	8082                	ret
    return -1;
    80001e84:	597d                	li	s2,-1
    80001e86:	b7ed                	j	80001e70 <fork+0x130>

0000000080001e88 <scheduler>:
{
    80001e88:	7139                	addi	sp,sp,-64
    80001e8a:	fc06                	sd	ra,56(sp)
    80001e8c:	f822                	sd	s0,48(sp)
    80001e8e:	f426                	sd	s1,40(sp)
    80001e90:	f04a                	sd	s2,32(sp)
    80001e92:	ec4e                	sd	s3,24(sp)
    80001e94:	e852                	sd	s4,16(sp)
    80001e96:	e456                	sd	s5,8(sp)
    80001e98:	e05a                	sd	s6,0(sp)
    80001e9a:	0080                	addi	s0,sp,64
    80001e9c:	8792                	mv	a5,tp
  int id = r_tp();
    80001e9e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ea0:	00779a93          	slli	s5,a5,0x7
    80001ea4:	0000f717          	auipc	a4,0xf
    80001ea8:	cac70713          	addi	a4,a4,-852 # 80010b50 <pid_lock>
    80001eac:	9756                	add	a4,a4,s5
    80001eae:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001eb2:	0000f717          	auipc	a4,0xf
    80001eb6:	cd670713          	addi	a4,a4,-810 # 80010b88 <cpus+0x8>
    80001eba:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ebc:	498d                	li	s3,3
        p->state = RUNNING;
    80001ebe:	4b11                	li	s6,4
        c->proc = p;
    80001ec0:	079e                	slli	a5,a5,0x7
    80001ec2:	0000fa17          	auipc	s4,0xf
    80001ec6:	c8ea0a13          	addi	s4,s4,-882 # 80010b50 <pid_lock>
    80001eca:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ecc:	00015917          	auipc	s2,0x15
    80001ed0:	eb490913          	addi	s2,s2,-332 # 80016d80 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ed4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ed8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001edc:	10079073          	csrw	sstatus,a5
    80001ee0:	0000f497          	auipc	s1,0xf
    80001ee4:	0a048493          	addi	s1,s1,160 # 80010f80 <proc>
    80001ee8:	a811                	j	80001efc <scheduler+0x74>
      release(&p->lock);
    80001eea:	8526                	mv	a0,s1
    80001eec:	fffff097          	auipc	ra,0xfffff
    80001ef0:	d9e080e7          	jalr	-610(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ef4:	17848493          	addi	s1,s1,376
    80001ef8:	fd248ee3          	beq	s1,s2,80001ed4 <scheduler+0x4c>
      acquire(&p->lock);
    80001efc:	8526                	mv	a0,s1
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	cd8080e7          	jalr	-808(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f06:	4c9c                	lw	a5,24(s1)
    80001f08:	ff3791e3          	bne	a5,s3,80001eea <scheduler+0x62>
        p->state = RUNNING;
    80001f0c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f10:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f14:	07048593          	addi	a1,s1,112
    80001f18:	8556                	mv	a0,s5
    80001f1a:	00000097          	auipc	ra,0x0
    80001f1e:	726080e7          	jalr	1830(ra) # 80002640 <swtch>
        c->proc = 0;
    80001f22:	020a3823          	sd	zero,48(s4)
    80001f26:	b7d1                	j	80001eea <scheduler+0x62>

0000000080001f28 <sched>:
{
    80001f28:	7179                	addi	sp,sp,-48
    80001f2a:	f406                	sd	ra,40(sp)
    80001f2c:	f022                	sd	s0,32(sp)
    80001f2e:	ec26                	sd	s1,24(sp)
    80001f30:	e84a                	sd	s2,16(sp)
    80001f32:	e44e                	sd	s3,8(sp)
    80001f34:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f36:	00000097          	auipc	ra,0x0
    80001f3a:	a4a080e7          	jalr	-1462(ra) # 80001980 <myproc>
    80001f3e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	c1c080e7          	jalr	-996(ra) # 80000b5c <holding>
    80001f48:	c93d                	beqz	a0,80001fbe <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f4a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f4c:	2781                	sext.w	a5,a5
    80001f4e:	079e                	slli	a5,a5,0x7
    80001f50:	0000f717          	auipc	a4,0xf
    80001f54:	c0070713          	addi	a4,a4,-1024 # 80010b50 <pid_lock>
    80001f58:	97ba                	add	a5,a5,a4
    80001f5a:	0a87a703          	lw	a4,168(a5)
    80001f5e:	4785                	li	a5,1
    80001f60:	06f71763          	bne	a4,a5,80001fce <sched+0xa6>
  if(p->state == RUNNING)
    80001f64:	4c98                	lw	a4,24(s1)
    80001f66:	4791                	li	a5,4
    80001f68:	06f70b63          	beq	a4,a5,80001fde <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f6c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f70:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f72:	efb5                	bnez	a5,80001fee <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f74:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f76:	0000f917          	auipc	s2,0xf
    80001f7a:	bda90913          	addi	s2,s2,-1062 # 80010b50 <pid_lock>
    80001f7e:	2781                	sext.w	a5,a5
    80001f80:	079e                	slli	a5,a5,0x7
    80001f82:	97ca                	add	a5,a5,s2
    80001f84:	0ac7a983          	lw	s3,172(a5)
    80001f88:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f8a:	2781                	sext.w	a5,a5
    80001f8c:	079e                	slli	a5,a5,0x7
    80001f8e:	0000f597          	auipc	a1,0xf
    80001f92:	bfa58593          	addi	a1,a1,-1030 # 80010b88 <cpus+0x8>
    80001f96:	95be                	add	a1,a1,a5
    80001f98:	07048513          	addi	a0,s1,112
    80001f9c:	00000097          	auipc	ra,0x0
    80001fa0:	6a4080e7          	jalr	1700(ra) # 80002640 <swtch>
    80001fa4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fa6:	2781                	sext.w	a5,a5
    80001fa8:	079e                	slli	a5,a5,0x7
    80001faa:	97ca                	add	a5,a5,s2
    80001fac:	0b37a623          	sw	s3,172(a5)
}
    80001fb0:	70a2                	ld	ra,40(sp)
    80001fb2:	7402                	ld	s0,32(sp)
    80001fb4:	64e2                	ld	s1,24(sp)
    80001fb6:	6942                	ld	s2,16(sp)
    80001fb8:	69a2                	ld	s3,8(sp)
    80001fba:	6145                	addi	sp,sp,48
    80001fbc:	8082                	ret
    panic("sched p->lock");
    80001fbe:	00006517          	auipc	a0,0x6
    80001fc2:	25a50513          	addi	a0,a0,602 # 80008218 <digits+0x1d8>
    80001fc6:	ffffe097          	auipc	ra,0xffffe
    80001fca:	578080e7          	jalr	1400(ra) # 8000053e <panic>
    panic("sched locks");
    80001fce:	00006517          	auipc	a0,0x6
    80001fd2:	25a50513          	addi	a0,a0,602 # 80008228 <digits+0x1e8>
    80001fd6:	ffffe097          	auipc	ra,0xffffe
    80001fda:	568080e7          	jalr	1384(ra) # 8000053e <panic>
    panic("sched running");
    80001fde:	00006517          	auipc	a0,0x6
    80001fe2:	25a50513          	addi	a0,a0,602 # 80008238 <digits+0x1f8>
    80001fe6:	ffffe097          	auipc	ra,0xffffe
    80001fea:	558080e7          	jalr	1368(ra) # 8000053e <panic>
    panic("sched interruptible");
    80001fee:	00006517          	auipc	a0,0x6
    80001ff2:	25a50513          	addi	a0,a0,602 # 80008248 <digits+0x208>
    80001ff6:	ffffe097          	auipc	ra,0xffffe
    80001ffa:	548080e7          	jalr	1352(ra) # 8000053e <panic>

0000000080001ffe <yield>:
{
    80001ffe:	1101                	addi	sp,sp,-32
    80002000:	ec06                	sd	ra,24(sp)
    80002002:	e822                	sd	s0,16(sp)
    80002004:	e426                	sd	s1,8(sp)
    80002006:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002008:	00000097          	auipc	ra,0x0
    8000200c:	978080e7          	jalr	-1672(ra) # 80001980 <myproc>
    80002010:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002012:	fffff097          	auipc	ra,0xfffff
    80002016:	bc4080e7          	jalr	-1084(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000201a:	478d                	li	a5,3
    8000201c:	cc9c                	sw	a5,24(s1)
  sched();
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	f0a080e7          	jalr	-246(ra) # 80001f28 <sched>
  release(&p->lock);
    80002026:	8526                	mv	a0,s1
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	c62080e7          	jalr	-926(ra) # 80000c8a <release>
}
    80002030:	60e2                	ld	ra,24(sp)
    80002032:	6442                	ld	s0,16(sp)
    80002034:	64a2                	ld	s1,8(sp)
    80002036:	6105                	addi	sp,sp,32
    80002038:	8082                	ret

000000008000203a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000203a:	7179                	addi	sp,sp,-48
    8000203c:	f406                	sd	ra,40(sp)
    8000203e:	f022                	sd	s0,32(sp)
    80002040:	ec26                	sd	s1,24(sp)
    80002042:	e84a                	sd	s2,16(sp)
    80002044:	e44e                	sd	s3,8(sp)
    80002046:	1800                	addi	s0,sp,48
    80002048:	89aa                	mv	s3,a0
    8000204a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000204c:	00000097          	auipc	ra,0x0
    80002050:	934080e7          	jalr	-1740(ra) # 80001980 <myproc>
    80002054:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	b80080e7          	jalr	-1152(ra) # 80000bd6 <acquire>
  release(lk);
    8000205e:	854a                	mv	a0,s2
    80002060:	fffff097          	auipc	ra,0xfffff
    80002064:	c2a080e7          	jalr	-982(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002068:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000206c:	4789                	li	a5,2
    8000206e:	cc9c                	sw	a5,24(s1)

  sched();
    80002070:	00000097          	auipc	ra,0x0
    80002074:	eb8080e7          	jalr	-328(ra) # 80001f28 <sched>

  // Tidy up.
  p->chan = 0;
    80002078:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	c0c080e7          	jalr	-1012(ra) # 80000c8a <release>
  acquire(lk);
    80002086:	854a                	mv	a0,s2
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	b4e080e7          	jalr	-1202(ra) # 80000bd6 <acquire>
}
    80002090:	70a2                	ld	ra,40(sp)
    80002092:	7402                	ld	s0,32(sp)
    80002094:	64e2                	ld	s1,24(sp)
    80002096:	6942                	ld	s2,16(sp)
    80002098:	69a2                	ld	s3,8(sp)
    8000209a:	6145                	addi	sp,sp,48
    8000209c:	8082                	ret

000000008000209e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000209e:	7139                	addi	sp,sp,-64
    800020a0:	fc06                	sd	ra,56(sp)
    800020a2:	f822                	sd	s0,48(sp)
    800020a4:	f426                	sd	s1,40(sp)
    800020a6:	f04a                	sd	s2,32(sp)
    800020a8:	ec4e                	sd	s3,24(sp)
    800020aa:	e852                	sd	s4,16(sp)
    800020ac:	e456                	sd	s5,8(sp)
    800020ae:	0080                	addi	s0,sp,64
    800020b0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020b2:	0000f497          	auipc	s1,0xf
    800020b6:	ece48493          	addi	s1,s1,-306 # 80010f80 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020ba:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020bc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020be:	00015917          	auipc	s2,0x15
    800020c2:	cc290913          	addi	s2,s2,-830 # 80016d80 <tickslock>
    800020c6:	a811                	j	800020da <wakeup+0x3c>
      }
      release(&p->lock);
    800020c8:	8526                	mv	a0,s1
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	bc0080e7          	jalr	-1088(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d2:	17848493          	addi	s1,s1,376
    800020d6:	03248663          	beq	s1,s2,80002102 <wakeup+0x64>
    if(p != myproc()){
    800020da:	00000097          	auipc	ra,0x0
    800020de:	8a6080e7          	jalr	-1882(ra) # 80001980 <myproc>
    800020e2:	fea488e3          	beq	s1,a0,800020d2 <wakeup+0x34>
      acquire(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	aee080e7          	jalr	-1298(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800020f0:	4c9c                	lw	a5,24(s1)
    800020f2:	fd379be3          	bne	a5,s3,800020c8 <wakeup+0x2a>
    800020f6:	709c                	ld	a5,32(s1)
    800020f8:	fd4798e3          	bne	a5,s4,800020c8 <wakeup+0x2a>
        p->state = RUNNABLE;
    800020fc:	0154ac23          	sw	s5,24(s1)
    80002100:	b7e1                	j	800020c8 <wakeup+0x2a>
    }
  }
}
    80002102:	70e2                	ld	ra,56(sp)
    80002104:	7442                	ld	s0,48(sp)
    80002106:	74a2                	ld	s1,40(sp)
    80002108:	7902                	ld	s2,32(sp)
    8000210a:	69e2                	ld	s3,24(sp)
    8000210c:	6a42                	ld	s4,16(sp)
    8000210e:	6aa2                	ld	s5,8(sp)
    80002110:	6121                	addi	sp,sp,64
    80002112:	8082                	ret

0000000080002114 <reparent>:
{
    80002114:	7179                	addi	sp,sp,-48
    80002116:	f406                	sd	ra,40(sp)
    80002118:	f022                	sd	s0,32(sp)
    8000211a:	ec26                	sd	s1,24(sp)
    8000211c:	e84a                	sd	s2,16(sp)
    8000211e:	e44e                	sd	s3,8(sp)
    80002120:	e052                	sd	s4,0(sp)
    80002122:	1800                	addi	s0,sp,48
    80002124:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002126:	0000f497          	auipc	s1,0xf
    8000212a:	e5a48493          	addi	s1,s1,-422 # 80010f80 <proc>
      pp->parent = initproc;
    8000212e:	00006a17          	auipc	s4,0x6
    80002132:	7aaa0a13          	addi	s4,s4,1962 # 800088d8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002136:	00015997          	auipc	s3,0x15
    8000213a:	c4a98993          	addi	s3,s3,-950 # 80016d80 <tickslock>
    8000213e:	a029                	j	80002148 <reparent+0x34>
    80002140:	17848493          	addi	s1,s1,376
    80002144:	01348d63          	beq	s1,s3,8000215e <reparent+0x4a>
    if(pp->parent == p){
    80002148:	68bc                	ld	a5,80(s1)
    8000214a:	ff279be3          	bne	a5,s2,80002140 <reparent+0x2c>
      pp->parent = initproc;
    8000214e:	000a3503          	ld	a0,0(s4)
    80002152:	e8a8                	sd	a0,80(s1)
      wakeup(initproc);
    80002154:	00000097          	auipc	ra,0x0
    80002158:	f4a080e7          	jalr	-182(ra) # 8000209e <wakeup>
    8000215c:	b7d5                	j	80002140 <reparent+0x2c>
}
    8000215e:	70a2                	ld	ra,40(sp)
    80002160:	7402                	ld	s0,32(sp)
    80002162:	64e2                	ld	s1,24(sp)
    80002164:	6942                	ld	s2,16(sp)
    80002166:	69a2                	ld	s3,8(sp)
    80002168:	6a02                	ld	s4,0(sp)
    8000216a:	6145                	addi	sp,sp,48
    8000216c:	8082                	ret

000000008000216e <exit>:
{
    8000216e:	7179                	addi	sp,sp,-48
    80002170:	f406                	sd	ra,40(sp)
    80002172:	f022                	sd	s0,32(sp)
    80002174:	ec26                	sd	s1,24(sp)
    80002176:	e84a                	sd	s2,16(sp)
    80002178:	e44e                	sd	s3,8(sp)
    8000217a:	e052                	sd	s4,0(sp)
    8000217c:	1800                	addi	s0,sp,48
    8000217e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002180:	00000097          	auipc	ra,0x0
    80002184:	800080e7          	jalr	-2048(ra) # 80001980 <myproc>
    80002188:	89aa                	mv	s3,a0
  if(p == initproc)
    8000218a:	00006797          	auipc	a5,0x6
    8000218e:	74e7b783          	ld	a5,1870(a5) # 800088d8 <initproc>
    80002192:	0e050493          	addi	s1,a0,224
    80002196:	16050913          	addi	s2,a0,352
    8000219a:	02a79363          	bne	a5,a0,800021c0 <exit+0x52>
    panic("init exiting");
    8000219e:	00006517          	auipc	a0,0x6
    800021a2:	0c250513          	addi	a0,a0,194 # 80008260 <digits+0x220>
    800021a6:	ffffe097          	auipc	ra,0xffffe
    800021aa:	398080e7          	jalr	920(ra) # 8000053e <panic>
      fileclose(f);
    800021ae:	00002097          	auipc	ra,0x2
    800021b2:	3e0080e7          	jalr	992(ra) # 8000458e <fileclose>
      p->ofile[fd] = 0;
    800021b6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021ba:	04a1                	addi	s1,s1,8
    800021bc:	01248563          	beq	s1,s2,800021c6 <exit+0x58>
    if(p->ofile[fd]){
    800021c0:	6088                	ld	a0,0(s1)
    800021c2:	f575                	bnez	a0,800021ae <exit+0x40>
    800021c4:	bfdd                	j	800021ba <exit+0x4c>
  begin_op();
    800021c6:	00002097          	auipc	ra,0x2
    800021ca:	efc080e7          	jalr	-260(ra) # 800040c2 <begin_op>
  iput(p->cwd);
    800021ce:	1609b503          	ld	a0,352(s3)
    800021d2:	00001097          	auipc	ra,0x1
    800021d6:	6e8080e7          	jalr	1768(ra) # 800038ba <iput>
  end_op();
    800021da:	00002097          	auipc	ra,0x2
    800021de:	f68080e7          	jalr	-152(ra) # 80004142 <end_op>
  p->cwd = 0;
    800021e2:	1609b023          	sd	zero,352(s3)
  acquire(&wait_lock);
    800021e6:	0000f497          	auipc	s1,0xf
    800021ea:	98248493          	addi	s1,s1,-1662 # 80010b68 <wait_lock>
    800021ee:	8526                	mv	a0,s1
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	9e6080e7          	jalr	-1562(ra) # 80000bd6 <acquire>
  reparent(p);
    800021f8:	854e                	mv	a0,s3
    800021fa:	00000097          	auipc	ra,0x0
    800021fe:	f1a080e7          	jalr	-230(ra) # 80002114 <reparent>
  wakeup(p->parent);
    80002202:	0509b503          	ld	a0,80(s3)
    80002206:	00000097          	auipc	ra,0x0
    8000220a:	e98080e7          	jalr	-360(ra) # 8000209e <wakeup>
  acquire(&p->lock);
    8000220e:	854e                	mv	a0,s3
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	9c6080e7          	jalr	-1594(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002218:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000221c:	4795                	li	a5,5
    8000221e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002222:	8526                	mv	a0,s1
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	a66080e7          	jalr	-1434(ra) # 80000c8a <release>
  sched();
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	cfc080e7          	jalr	-772(ra) # 80001f28 <sched>
  panic("zombie exit");
    80002234:	00006517          	auipc	a0,0x6
    80002238:	03c50513          	addi	a0,a0,60 # 80008270 <digits+0x230>
    8000223c:	ffffe097          	auipc	ra,0xffffe
    80002240:	302080e7          	jalr	770(ra) # 8000053e <panic>

0000000080002244 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002244:	7179                	addi	sp,sp,-48
    80002246:	f406                	sd	ra,40(sp)
    80002248:	f022                	sd	s0,32(sp)
    8000224a:	ec26                	sd	s1,24(sp)
    8000224c:	e84a                	sd	s2,16(sp)
    8000224e:	e44e                	sd	s3,8(sp)
    80002250:	1800                	addi	s0,sp,48
    80002252:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002254:	0000f497          	auipc	s1,0xf
    80002258:	d2c48493          	addi	s1,s1,-724 # 80010f80 <proc>
    8000225c:	00015997          	auipc	s3,0x15
    80002260:	b2498993          	addi	s3,s3,-1244 # 80016d80 <tickslock>
    acquire(&p->lock);
    80002264:	8526                	mv	a0,s1
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	970080e7          	jalr	-1680(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    8000226e:	589c                	lw	a5,48(s1)
    80002270:	01278d63          	beq	a5,s2,8000228a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002274:	8526                	mv	a0,s1
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	a14080e7          	jalr	-1516(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000227e:	17848493          	addi	s1,s1,376
    80002282:	ff3491e3          	bne	s1,s3,80002264 <kill+0x20>
  }
  return -1;
    80002286:	557d                	li	a0,-1
    80002288:	a829                	j	800022a2 <kill+0x5e>
      p->killed = 1;
    8000228a:	4785                	li	a5,1
    8000228c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000228e:	4c98                	lw	a4,24(s1)
    80002290:	4789                	li	a5,2
    80002292:	00f70f63          	beq	a4,a5,800022b0 <kill+0x6c>
      release(&p->lock);
    80002296:	8526                	mv	a0,s1
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	9f2080e7          	jalr	-1550(ra) # 80000c8a <release>
      return 0;
    800022a0:	4501                	li	a0,0
}
    800022a2:	70a2                	ld	ra,40(sp)
    800022a4:	7402                	ld	s0,32(sp)
    800022a6:	64e2                	ld	s1,24(sp)
    800022a8:	6942                	ld	s2,16(sp)
    800022aa:	69a2                	ld	s3,8(sp)
    800022ac:	6145                	addi	sp,sp,48
    800022ae:	8082                	ret
        p->state = RUNNABLE;
    800022b0:	478d                	li	a5,3
    800022b2:	cc9c                	sw	a5,24(s1)
    800022b4:	b7cd                	j	80002296 <kill+0x52>

00000000800022b6 <setkilled>:

void
setkilled(struct proc *p)
{
    800022b6:	1101                	addi	sp,sp,-32
    800022b8:	ec06                	sd	ra,24(sp)
    800022ba:	e822                	sd	s0,16(sp)
    800022bc:	e426                	sd	s1,8(sp)
    800022be:	1000                	addi	s0,sp,32
    800022c0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	914080e7          	jalr	-1772(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022ca:	4785                	li	a5,1
    800022cc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022ce:	8526                	mv	a0,s1
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	9ba080e7          	jalr	-1606(ra) # 80000c8a <release>
}
    800022d8:	60e2                	ld	ra,24(sp)
    800022da:	6442                	ld	s0,16(sp)
    800022dc:	64a2                	ld	s1,8(sp)
    800022de:	6105                	addi	sp,sp,32
    800022e0:	8082                	ret

00000000800022e2 <killed>:

int
killed(struct proc *p)
{
    800022e2:	1101                	addi	sp,sp,-32
    800022e4:	ec06                	sd	ra,24(sp)
    800022e6:	e822                	sd	s0,16(sp)
    800022e8:	e426                	sd	s1,8(sp)
    800022ea:	e04a                	sd	s2,0(sp)
    800022ec:	1000                	addi	s0,sp,32
    800022ee:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	8e6080e7          	jalr	-1818(ra) # 80000bd6 <acquire>
  k = p->killed;
    800022f8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800022fc:	8526                	mv	a0,s1
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	98c080e7          	jalr	-1652(ra) # 80000c8a <release>
  return k;
}
    80002306:	854a                	mv	a0,s2
    80002308:	60e2                	ld	ra,24(sp)
    8000230a:	6442                	ld	s0,16(sp)
    8000230c:	64a2                	ld	s1,8(sp)
    8000230e:	6902                	ld	s2,0(sp)
    80002310:	6105                	addi	sp,sp,32
    80002312:	8082                	ret

0000000080002314 <wait>:
{
    80002314:	715d                	addi	sp,sp,-80
    80002316:	e486                	sd	ra,72(sp)
    80002318:	e0a2                	sd	s0,64(sp)
    8000231a:	fc26                	sd	s1,56(sp)
    8000231c:	f84a                	sd	s2,48(sp)
    8000231e:	f44e                	sd	s3,40(sp)
    80002320:	f052                	sd	s4,32(sp)
    80002322:	ec56                	sd	s5,24(sp)
    80002324:	e85a                	sd	s6,16(sp)
    80002326:	e45e                	sd	s7,8(sp)
    80002328:	e062                	sd	s8,0(sp)
    8000232a:	0880                	addi	s0,sp,80
    8000232c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	652080e7          	jalr	1618(ra) # 80001980 <myproc>
    80002336:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002338:	0000f517          	auipc	a0,0xf
    8000233c:	83050513          	addi	a0,a0,-2000 # 80010b68 <wait_lock>
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	896080e7          	jalr	-1898(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002348:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000234a:	4a15                	li	s4,5
        havekids = 1;
    8000234c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000234e:	00015997          	auipc	s3,0x15
    80002352:	a3298993          	addi	s3,s3,-1486 # 80016d80 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002356:	0000fc17          	auipc	s8,0xf
    8000235a:	812c0c13          	addi	s8,s8,-2030 # 80010b68 <wait_lock>
    havekids = 0;
    8000235e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002360:	0000f497          	auipc	s1,0xf
    80002364:	c2048493          	addi	s1,s1,-992 # 80010f80 <proc>
    80002368:	a0bd                	j	800023d6 <wait+0xc2>
          pid = pp->pid;
    8000236a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000236e:	000b0e63          	beqz	s6,8000238a <wait+0x76>
    80002372:	4691                	li	a3,4
    80002374:	02c48613          	addi	a2,s1,44
    80002378:	85da                	mv	a1,s6
    8000237a:	06893503          	ld	a0,104(s2)
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	2ea080e7          	jalr	746(ra) # 80001668 <copyout>
    80002386:	02054563          	bltz	a0,800023b0 <wait+0x9c>
          freeproc(pp);
    8000238a:	8526                	mv	a0,s1
    8000238c:	fffff097          	auipc	ra,0xfffff
    80002390:	7a6080e7          	jalr	1958(ra) # 80001b32 <freeproc>
          release(&pp->lock);
    80002394:	8526                	mv	a0,s1
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	8f4080e7          	jalr	-1804(ra) # 80000c8a <release>
          release(&wait_lock);
    8000239e:	0000e517          	auipc	a0,0xe
    800023a2:	7ca50513          	addi	a0,a0,1994 # 80010b68 <wait_lock>
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	8e4080e7          	jalr	-1820(ra) # 80000c8a <release>
          return pid;
    800023ae:	a0b5                	j	8000241a <wait+0x106>
            release(&pp->lock);
    800023b0:	8526                	mv	a0,s1
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	8d8080e7          	jalr	-1832(ra) # 80000c8a <release>
            release(&wait_lock);
    800023ba:	0000e517          	auipc	a0,0xe
    800023be:	7ae50513          	addi	a0,a0,1966 # 80010b68 <wait_lock>
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	8c8080e7          	jalr	-1848(ra) # 80000c8a <release>
            return -1;
    800023ca:	59fd                	li	s3,-1
    800023cc:	a0b9                	j	8000241a <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ce:	17848493          	addi	s1,s1,376
    800023d2:	03348463          	beq	s1,s3,800023fa <wait+0xe6>
      if(pp->parent == p){
    800023d6:	68bc                	ld	a5,80(s1)
    800023d8:	ff279be3          	bne	a5,s2,800023ce <wait+0xba>
        acquire(&pp->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	ffffe097          	auipc	ra,0xffffe
    800023e2:	7f8080e7          	jalr	2040(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    800023e6:	4c9c                	lw	a5,24(s1)
    800023e8:	f94781e3          	beq	a5,s4,8000236a <wait+0x56>
        release(&pp->lock);
    800023ec:	8526                	mv	a0,s1
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	89c080e7          	jalr	-1892(ra) # 80000c8a <release>
        havekids = 1;
    800023f6:	8756                	mv	a4,s5
    800023f8:	bfd9                	j	800023ce <wait+0xba>
    if(!havekids || killed(p)){
    800023fa:	c719                	beqz	a4,80002408 <wait+0xf4>
    800023fc:	854a                	mv	a0,s2
    800023fe:	00000097          	auipc	ra,0x0
    80002402:	ee4080e7          	jalr	-284(ra) # 800022e2 <killed>
    80002406:	c51d                	beqz	a0,80002434 <wait+0x120>
      release(&wait_lock);
    80002408:	0000e517          	auipc	a0,0xe
    8000240c:	76050513          	addi	a0,a0,1888 # 80010b68 <wait_lock>
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	87a080e7          	jalr	-1926(ra) # 80000c8a <release>
      return -1;
    80002418:	59fd                	li	s3,-1
}
    8000241a:	854e                	mv	a0,s3
    8000241c:	60a6                	ld	ra,72(sp)
    8000241e:	6406                	ld	s0,64(sp)
    80002420:	74e2                	ld	s1,56(sp)
    80002422:	7942                	ld	s2,48(sp)
    80002424:	79a2                	ld	s3,40(sp)
    80002426:	7a02                	ld	s4,32(sp)
    80002428:	6ae2                	ld	s5,24(sp)
    8000242a:	6b42                	ld	s6,16(sp)
    8000242c:	6ba2                	ld	s7,8(sp)
    8000242e:	6c02                	ld	s8,0(sp)
    80002430:	6161                	addi	sp,sp,80
    80002432:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002434:	85e2                	mv	a1,s8
    80002436:	854a                	mv	a0,s2
    80002438:	00000097          	auipc	ra,0x0
    8000243c:	c02080e7          	jalr	-1022(ra) # 8000203a <sleep>
    havekids = 0;
    80002440:	bf39                	j	8000235e <wait+0x4a>

0000000080002442 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002442:	7179                	addi	sp,sp,-48
    80002444:	f406                	sd	ra,40(sp)
    80002446:	f022                	sd	s0,32(sp)
    80002448:	ec26                	sd	s1,24(sp)
    8000244a:	e84a                	sd	s2,16(sp)
    8000244c:	e44e                	sd	s3,8(sp)
    8000244e:	e052                	sd	s4,0(sp)
    80002450:	1800                	addi	s0,sp,48
    80002452:	84aa                	mv	s1,a0
    80002454:	892e                	mv	s2,a1
    80002456:	89b2                	mv	s3,a2
    80002458:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	526080e7          	jalr	1318(ra) # 80001980 <myproc>
  if(user_dst){
    80002462:	c08d                	beqz	s1,80002484 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002464:	86d2                	mv	a3,s4
    80002466:	864e                	mv	a2,s3
    80002468:	85ca                	mv	a1,s2
    8000246a:	7528                	ld	a0,104(a0)
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	1fc080e7          	jalr	508(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002474:	70a2                	ld	ra,40(sp)
    80002476:	7402                	ld	s0,32(sp)
    80002478:	64e2                	ld	s1,24(sp)
    8000247a:	6942                	ld	s2,16(sp)
    8000247c:	69a2                	ld	s3,8(sp)
    8000247e:	6a02                	ld	s4,0(sp)
    80002480:	6145                	addi	sp,sp,48
    80002482:	8082                	ret
    memmove((char *)dst, src, len);
    80002484:	000a061b          	sext.w	a2,s4
    80002488:	85ce                	mv	a1,s3
    8000248a:	854a                	mv	a0,s2
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	8a2080e7          	jalr	-1886(ra) # 80000d2e <memmove>
    return 0;
    80002494:	8526                	mv	a0,s1
    80002496:	bff9                	j	80002474 <either_copyout+0x32>

0000000080002498 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002498:	7179                	addi	sp,sp,-48
    8000249a:	f406                	sd	ra,40(sp)
    8000249c:	f022                	sd	s0,32(sp)
    8000249e:	ec26                	sd	s1,24(sp)
    800024a0:	e84a                	sd	s2,16(sp)
    800024a2:	e44e                	sd	s3,8(sp)
    800024a4:	e052                	sd	s4,0(sp)
    800024a6:	1800                	addi	s0,sp,48
    800024a8:	892a                	mv	s2,a0
    800024aa:	84ae                	mv	s1,a1
    800024ac:	89b2                	mv	s3,a2
    800024ae:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	4d0080e7          	jalr	1232(ra) # 80001980 <myproc>
  if(user_src){
    800024b8:	c08d                	beqz	s1,800024da <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024ba:	86d2                	mv	a3,s4
    800024bc:	864e                	mv	a2,s3
    800024be:	85ca                	mv	a1,s2
    800024c0:	7528                	ld	a0,104(a0)
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	232080e7          	jalr	562(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ca:	70a2                	ld	ra,40(sp)
    800024cc:	7402                	ld	s0,32(sp)
    800024ce:	64e2                	ld	s1,24(sp)
    800024d0:	6942                	ld	s2,16(sp)
    800024d2:	69a2                	ld	s3,8(sp)
    800024d4:	6a02                	ld	s4,0(sp)
    800024d6:	6145                	addi	sp,sp,48
    800024d8:	8082                	ret
    memmove(dst, (char*)src, len);
    800024da:	000a061b          	sext.w	a2,s4
    800024de:	85ce                	mv	a1,s3
    800024e0:	854a                	mv	a0,s2
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	84c080e7          	jalr	-1972(ra) # 80000d2e <memmove>
    return 0;
    800024ea:	8526                	mv	a0,s1
    800024ec:	bff9                	j	800024ca <either_copyin+0x32>

00000000800024ee <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024ee:	715d                	addi	sp,sp,-80
    800024f0:	e486                	sd	ra,72(sp)
    800024f2:	e0a2                	sd	s0,64(sp)
    800024f4:	fc26                	sd	s1,56(sp)
    800024f6:	f84a                	sd	s2,48(sp)
    800024f8:	f44e                	sd	s3,40(sp)
    800024fa:	f052                	sd	s4,32(sp)
    800024fc:	ec56                	sd	s5,24(sp)
    800024fe:	e85a                	sd	s6,16(sp)
    80002500:	e45e                	sd	s7,8(sp)
    80002502:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002504:	00006517          	auipc	a0,0x6
    80002508:	bc450513          	addi	a0,a0,-1084 # 800080c8 <digits+0x88>
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	07c080e7          	jalr	124(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002514:	0000f497          	auipc	s1,0xf
    80002518:	bd448493          	addi	s1,s1,-1068 # 800110e8 <proc+0x168>
    8000251c:	00015917          	auipc	s2,0x15
    80002520:	9cc90913          	addi	s2,s2,-1588 # 80016ee8 <bcache+0x150>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002524:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002526:	00006997          	auipc	s3,0x6
    8000252a:	d5a98993          	addi	s3,s3,-678 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000252e:	00006a97          	auipc	s5,0x6
    80002532:	d5aa8a93          	addi	s5,s5,-678 # 80008288 <digits+0x248>
    printf("\n");
    80002536:	00006a17          	auipc	s4,0x6
    8000253a:	b92a0a13          	addi	s4,s4,-1134 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000253e:	00006b97          	auipc	s7,0x6
    80002542:	d8ab8b93          	addi	s7,s7,-630 # 800082c8 <states.0>
    80002546:	a00d                	j	80002568 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002548:	ec86a583          	lw	a1,-312(a3)
    8000254c:	8556                	mv	a0,s5
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	03a080e7          	jalr	58(ra) # 80000588 <printf>
    printf("\n");
    80002556:	8552                	mv	a0,s4
    80002558:	ffffe097          	auipc	ra,0xffffe
    8000255c:	030080e7          	jalr	48(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002560:	17848493          	addi	s1,s1,376
    80002564:	03248163          	beq	s1,s2,80002586 <procdump+0x98>
    if(p->state == UNUSED)
    80002568:	86a6                	mv	a3,s1
    8000256a:	eb04a783          	lw	a5,-336(s1)
    8000256e:	dbed                	beqz	a5,80002560 <procdump+0x72>
      state = "???";
    80002570:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002572:	fcfb6be3          	bltu	s6,a5,80002548 <procdump+0x5a>
    80002576:	1782                	slli	a5,a5,0x20
    80002578:	9381                	srli	a5,a5,0x20
    8000257a:	078e                	slli	a5,a5,0x3
    8000257c:	97de                	add	a5,a5,s7
    8000257e:	6390                	ld	a2,0(a5)
    80002580:	f661                	bnez	a2,80002548 <procdump+0x5a>
      state = "???";
    80002582:	864e                	mv	a2,s3
    80002584:	b7d1                	j	80002548 <procdump+0x5a>
  }
}
    80002586:	60a6                	ld	ra,72(sp)
    80002588:	6406                	ld	s0,64(sp)
    8000258a:	74e2                	ld	s1,56(sp)
    8000258c:	7942                	ld	s2,48(sp)
    8000258e:	79a2                	ld	s3,40(sp)
    80002590:	7a02                	ld	s4,32(sp)
    80002592:	6ae2                	ld	s5,24(sp)
    80002594:	6b42                	ld	s6,16(sp)
    80002596:	6ba2                	ld	s7,8(sp)
    80002598:	6161                	addi	sp,sp,80
    8000259a:	8082                	ret

000000008000259c <kthreadinit>:
#include "defs.h"

extern struct proc proc[NPROC];

void kthreadinit(struct proc *p)
{
    8000259c:	1141                	addi	sp,sp,-16
    8000259e:	e422                	sd	s0,8(sp)
    800025a0:	0800                	addi	s0,sp,16
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
  {

    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    800025a2:	0000f797          	auipc	a5,0xf
    800025a6:	9de78793          	addi	a5,a5,-1570 # 80010f80 <proc>
    800025aa:	40f507b3          	sub	a5,a0,a5
    800025ae:	878d                	srai	a5,a5,0x3
    800025b0:	00006717          	auipc	a4,0x6
    800025b4:	a5073703          	ld	a4,-1456(a4) # 80008000 <etext>
    800025b8:	02e787b3          	mul	a5,a5,a4
    800025bc:	2785                	addiw	a5,a5,1
    800025be:	00d7979b          	slliw	a5,a5,0xd
    800025c2:	04000737          	lui	a4,0x4000
    800025c6:	177d                	addi	a4,a4,-1
    800025c8:	0732                	slli	a4,a4,0xc
    800025ca:	40f707b3          	sub	a5,a4,a5
    800025ce:	fd1c                	sd	a5,56(a0)
  }
}
    800025d0:	6422                	ld	s0,8(sp)
    800025d2:	0141                	addi	sp,sp,16
    800025d4:	8082                	ret

00000000800025d6 <mykthread>:

struct kthread *mykthread()
{
    800025d6:	1141                	addi	sp,sp,-16
    800025d8:	e406                	sd	ra,8(sp)
    800025da:	e022                	sd	s0,0(sp)
    800025dc:	0800                	addi	s0,sp,16
  return &myproc()->kthread[0];
    800025de:	fffff097          	auipc	ra,0xfffff
    800025e2:	3a2080e7          	jalr	930(ra) # 80001980 <myproc>
}
    800025e6:	03850513          	addi	a0,a0,56
    800025ea:	60a2                	ld	ra,8(sp)
    800025ec:	6402                	ld	s0,0(sp)
    800025ee:	0141                	addi	sp,sp,16
    800025f0:	8082                	ret

00000000800025f2 <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    800025f2:	1141                	addi	sp,sp,-16
    800025f4:	e422                	sd	s0,8(sp)
    800025f6:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    800025f8:	03850793          	addi	a5,a0,56
    800025fc:	8d9d                	sub	a1,a1,a5
    800025fe:	8591                	srai	a1,a1,0x4
    80002600:	2581                	sext.w	a1,a1
    80002602:	00359793          	slli	a5,a1,0x3
    80002606:	95be                	add	a1,a1,a5
    80002608:	0596                	slli	a1,a1,0x5
    8000260a:	6528                	ld	a0,72(a0)
}
    8000260c:	952e                	add	a0,a0,a1
    8000260e:	6422                	ld	s0,8(sp)
    80002610:	0141                	addi	sp,sp,16
    80002612:	8082                	ret

0000000080002614 <allocproc_help_function>:

// TODO: delte this after you are done with task 2.2
void allocproc_help_function(struct proc *p) {
    80002614:	1101                	addi	sp,sp,-32
    80002616:	ec06                	sd	ra,24(sp)
    80002618:	e822                	sd	s0,16(sp)
    8000261a:	e426                	sd	s1,8(sp)
    8000261c:	1000                	addi	s0,sp,32
    8000261e:	84aa                	mv	s1,a0
  p->kthread->trapframe = get_kthread_trapframe(p, p->kthread);
    80002620:	03850593          	addi	a1,a0,56
    80002624:	00000097          	auipc	ra,0x0
    80002628:	fce080e7          	jalr	-50(ra) # 800025f2 <get_kthread_trapframe>
    8000262c:	e0a8                	sd	a0,64(s1)

  p->context.sp = p->kthread->kstack + PGSIZE;
    8000262e:	7c9c                	ld	a5,56(s1)
    80002630:	6705                	lui	a4,0x1
    80002632:	97ba                	add	a5,a5,a4
    80002634:	fcbc                	sd	a5,120(s1)
    80002636:	60e2                	ld	ra,24(sp)
    80002638:	6442                	ld	s0,16(sp)
    8000263a:	64a2                	ld	s1,8(sp)
    8000263c:	6105                	addi	sp,sp,32
    8000263e:	8082                	ret

0000000080002640 <swtch>:
    80002640:	00153023          	sd	ra,0(a0)
    80002644:	00253423          	sd	sp,8(a0)
    80002648:	e900                	sd	s0,16(a0)
    8000264a:	ed04                	sd	s1,24(a0)
    8000264c:	03253023          	sd	s2,32(a0)
    80002650:	03353423          	sd	s3,40(a0)
    80002654:	03453823          	sd	s4,48(a0)
    80002658:	03553c23          	sd	s5,56(a0)
    8000265c:	05653023          	sd	s6,64(a0)
    80002660:	05753423          	sd	s7,72(a0)
    80002664:	05853823          	sd	s8,80(a0)
    80002668:	05953c23          	sd	s9,88(a0)
    8000266c:	07a53023          	sd	s10,96(a0)
    80002670:	07b53423          	sd	s11,104(a0)
    80002674:	0005b083          	ld	ra,0(a1)
    80002678:	0085b103          	ld	sp,8(a1)
    8000267c:	6980                	ld	s0,16(a1)
    8000267e:	6d84                	ld	s1,24(a1)
    80002680:	0205b903          	ld	s2,32(a1)
    80002684:	0285b983          	ld	s3,40(a1)
    80002688:	0305ba03          	ld	s4,48(a1)
    8000268c:	0385ba83          	ld	s5,56(a1)
    80002690:	0405bb03          	ld	s6,64(a1)
    80002694:	0485bb83          	ld	s7,72(a1)
    80002698:	0505bc03          	ld	s8,80(a1)
    8000269c:	0585bc83          	ld	s9,88(a1)
    800026a0:	0605bd03          	ld	s10,96(a1)
    800026a4:	0685bd83          	ld	s11,104(a1)
    800026a8:	8082                	ret

00000000800026aa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026aa:	1141                	addi	sp,sp,-16
    800026ac:	e406                	sd	ra,8(sp)
    800026ae:	e022                	sd	s0,0(sp)
    800026b0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026b2:	00006597          	auipc	a1,0x6
    800026b6:	c4658593          	addi	a1,a1,-954 # 800082f8 <states.0+0x30>
    800026ba:	00014517          	auipc	a0,0x14
    800026be:	6c650513          	addi	a0,a0,1734 # 80016d80 <tickslock>
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	484080e7          	jalr	1156(ra) # 80000b46 <initlock>
}
    800026ca:	60a2                	ld	ra,8(sp)
    800026cc:	6402                	ld	s0,0(sp)
    800026ce:	0141                	addi	sp,sp,16
    800026d0:	8082                	ret

00000000800026d2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026d2:	1141                	addi	sp,sp,-16
    800026d4:	e422                	sd	s0,8(sp)
    800026d6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026d8:	00003797          	auipc	a5,0x3
    800026dc:	51878793          	addi	a5,a5,1304 # 80005bf0 <kernelvec>
    800026e0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026e4:	6422                	ld	s0,8(sp)
    800026e6:	0141                	addi	sp,sp,16
    800026e8:	8082                	ret

00000000800026ea <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026ea:	1101                	addi	sp,sp,-32
    800026ec:	ec06                	sd	ra,24(sp)
    800026ee:	e822                	sd	s0,16(sp)
    800026f0:	e426                	sd	s1,8(sp)
    800026f2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800026f4:	fffff097          	auipc	ra,0xfffff
    800026f8:	28c080e7          	jalr	652(ra) # 80001980 <myproc>
    800026fc:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    800026fe:	00000097          	auipc	ra,0x0
    80002702:	ed8080e7          	jalr	-296(ra) # 800025d6 <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002706:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000270a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000270c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002710:	00005617          	auipc	a2,0x5
    80002714:	8f060613          	addi	a2,a2,-1808 # 80007000 <_trampoline>
    80002718:	00005697          	auipc	a3,0x5
    8000271c:	8e868693          	addi	a3,a3,-1816 # 80007000 <_trampoline>
    80002720:	8e91                	sub	a3,a3,a2
    80002722:	040007b7          	lui	a5,0x4000
    80002726:	17fd                	addi	a5,a5,-1
    80002728:	07b2                	slli	a5,a5,0xc
    8000272a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000272c:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    80002730:	6518                	ld	a4,8(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002732:	180026f3          	csrr	a3,satp
    80002736:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    80002738:	6518                	ld	a4,8(a0)
    8000273a:	6114                	ld	a3,0(a0)
    8000273c:	6585                	lui	a1,0x1
    8000273e:	96ae                	add	a3,a3,a1
    80002740:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    80002742:	6518                	ld	a4,8(a0)
    80002744:	00000697          	auipc	a3,0x0
    80002748:	15068693          	addi	a3,a3,336 # 80002894 <usertrap>
    8000274c:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000274e:	6518                	ld	a4,8(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002750:	8692                	mv	a3,tp
    80002752:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002754:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002758:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000275c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002760:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    80002764:	6518                	ld	a4,8(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002766:	6f18                	ld	a4,24(a4)
    80002768:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000276c:	74ac                	ld	a1,104(s1)
    8000276e:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002770:	03848493          	addi	s1,s1,56
    80002774:	8d05                	sub	a0,a0,s1
    80002776:	8511                	srai	a0,a0,0x4
    80002778:	1502                	slli	a0,a0,0x20
    8000277a:	9101                	srli	a0,a0,0x20
    8000277c:	00351693          	slli	a3,a0,0x3
    80002780:	9536                	add	a0,a0,a3
    80002782:	0516                	slli	a0,a0,0x5
    80002784:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002788:	00005717          	auipc	a4,0x5
    8000278c:	90c70713          	addi	a4,a4,-1780 # 80007094 <userret>
    80002790:	8f11                	sub	a4,a4,a2
    80002792:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002794:	577d                	li	a4,-1
    80002796:	177e                	slli	a4,a4,0x3f
    80002798:	8dd9                	or	a1,a1,a4
    8000279a:	16fd                	addi	a3,a3,-1
    8000279c:	06b6                	slli	a3,a3,0xd
    8000279e:	9536                	add	a0,a0,a3
    800027a0:	9782                	jalr	a5
}
    800027a2:	60e2                	ld	ra,24(sp)
    800027a4:	6442                	ld	s0,16(sp)
    800027a6:	64a2                	ld	s1,8(sp)
    800027a8:	6105                	addi	sp,sp,32
    800027aa:	8082                	ret

00000000800027ac <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027ac:	1101                	addi	sp,sp,-32
    800027ae:	ec06                	sd	ra,24(sp)
    800027b0:	e822                	sd	s0,16(sp)
    800027b2:	e426                	sd	s1,8(sp)
    800027b4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027b6:	00014497          	auipc	s1,0x14
    800027ba:	5ca48493          	addi	s1,s1,1482 # 80016d80 <tickslock>
    800027be:	8526                	mv	a0,s1
    800027c0:	ffffe097          	auipc	ra,0xffffe
    800027c4:	416080e7          	jalr	1046(ra) # 80000bd6 <acquire>
  ticks++;
    800027c8:	00006517          	auipc	a0,0x6
    800027cc:	11850513          	addi	a0,a0,280 # 800088e0 <ticks>
    800027d0:	411c                	lw	a5,0(a0)
    800027d2:	2785                	addiw	a5,a5,1
    800027d4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027d6:	00000097          	auipc	ra,0x0
    800027da:	8c8080e7          	jalr	-1848(ra) # 8000209e <wakeup>
  release(&tickslock);
    800027de:	8526                	mv	a0,s1
    800027e0:	ffffe097          	auipc	ra,0xffffe
    800027e4:	4aa080e7          	jalr	1194(ra) # 80000c8a <release>
}
    800027e8:	60e2                	ld	ra,24(sp)
    800027ea:	6442                	ld	s0,16(sp)
    800027ec:	64a2                	ld	s1,8(sp)
    800027ee:	6105                	addi	sp,sp,32
    800027f0:	8082                	ret

00000000800027f2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027f2:	1101                	addi	sp,sp,-32
    800027f4:	ec06                	sd	ra,24(sp)
    800027f6:	e822                	sd	s0,16(sp)
    800027f8:	e426                	sd	s1,8(sp)
    800027fa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027fc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002800:	00074d63          	bltz	a4,8000281a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002804:	57fd                	li	a5,-1
    80002806:	17fe                	slli	a5,a5,0x3f
    80002808:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000280a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000280c:	06f70363          	beq	a4,a5,80002872 <devintr+0x80>
  }
}
    80002810:	60e2                	ld	ra,24(sp)
    80002812:	6442                	ld	s0,16(sp)
    80002814:	64a2                	ld	s1,8(sp)
    80002816:	6105                	addi	sp,sp,32
    80002818:	8082                	ret
     (scause & 0xff) == 9){
    8000281a:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000281e:	46a5                	li	a3,9
    80002820:	fed792e3          	bne	a5,a3,80002804 <devintr+0x12>
    int irq = plic_claim();
    80002824:	00003097          	auipc	ra,0x3
    80002828:	4d4080e7          	jalr	1236(ra) # 80005cf8 <plic_claim>
    8000282c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000282e:	47a9                	li	a5,10
    80002830:	02f50763          	beq	a0,a5,8000285e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002834:	4785                	li	a5,1
    80002836:	02f50963          	beq	a0,a5,80002868 <devintr+0x76>
    return 1;
    8000283a:	4505                	li	a0,1
    } else if(irq){
    8000283c:	d8f1                	beqz	s1,80002810 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000283e:	85a6                	mv	a1,s1
    80002840:	00006517          	auipc	a0,0x6
    80002844:	ac050513          	addi	a0,a0,-1344 # 80008300 <states.0+0x38>
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	d40080e7          	jalr	-704(ra) # 80000588 <printf>
      plic_complete(irq);
    80002850:	8526                	mv	a0,s1
    80002852:	00003097          	auipc	ra,0x3
    80002856:	4ca080e7          	jalr	1226(ra) # 80005d1c <plic_complete>
    return 1;
    8000285a:	4505                	li	a0,1
    8000285c:	bf55                	j	80002810 <devintr+0x1e>
      uartintr();
    8000285e:	ffffe097          	auipc	ra,0xffffe
    80002862:	13c080e7          	jalr	316(ra) # 8000099a <uartintr>
    80002866:	b7ed                	j	80002850 <devintr+0x5e>
      virtio_disk_intr();
    80002868:	00004097          	auipc	ra,0x4
    8000286c:	980080e7          	jalr	-1664(ra) # 800061e8 <virtio_disk_intr>
    80002870:	b7c5                	j	80002850 <devintr+0x5e>
    if(cpuid() == 0){
    80002872:	fffff097          	auipc	ra,0xfffff
    80002876:	0e2080e7          	jalr	226(ra) # 80001954 <cpuid>
    8000287a:	c901                	beqz	a0,8000288a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000287c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002880:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002882:	14479073          	csrw	sip,a5
    return 2;
    80002886:	4509                	li	a0,2
    80002888:	b761                	j	80002810 <devintr+0x1e>
      clockintr();
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	f22080e7          	jalr	-222(ra) # 800027ac <clockintr>
    80002892:	b7ed                	j	8000287c <devintr+0x8a>

0000000080002894 <usertrap>:
{
    80002894:	1101                	addi	sp,sp,-32
    80002896:	ec06                	sd	ra,24(sp)
    80002898:	e822                	sd	s0,16(sp)
    8000289a:	e426                	sd	s1,8(sp)
    8000289c:	e04a                	sd	s2,0(sp)
    8000289e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028a4:	1007f793          	andi	a5,a5,256
    800028a8:	e7b9                	bnez	a5,800028f6 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028aa:	00003797          	auipc	a5,0x3
    800028ae:	34678793          	addi	a5,a5,838 # 80005bf0 <kernelvec>
    800028b2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028b6:	fffff097          	auipc	ra,0xfffff
    800028ba:	0ca080e7          	jalr	202(ra) # 80001980 <myproc>
    800028be:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    800028c0:	00000097          	auipc	ra,0x0
    800028c4:	d16080e7          	jalr	-746(ra) # 800025d6 <mykthread>
    800028c8:	892a                	mv	s2,a0
  kt->trapframe->epc = r_sepc();
    800028ca:	651c                	ld	a5,8(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028cc:	14102773          	csrr	a4,sepc
    800028d0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028d6:	47a1                	li	a5,8
    800028d8:	02f70763          	beq	a4,a5,80002906 <usertrap+0x72>
  } else if((which_dev = devintr()) != 0){
    800028dc:	00000097          	auipc	ra,0x0
    800028e0:	f16080e7          	jalr	-234(ra) # 800027f2 <devintr>
    800028e4:	892a                	mv	s2,a0
    800028e6:	c541                	beqz	a0,8000296e <usertrap+0xda>
  if(killed(p))
    800028e8:	8526                	mv	a0,s1
    800028ea:	00000097          	auipc	ra,0x0
    800028ee:	9f8080e7          	jalr	-1544(ra) # 800022e2 <killed>
    800028f2:	c939                	beqz	a0,80002948 <usertrap+0xb4>
    800028f4:	a0a9                	j	8000293e <usertrap+0xaa>
    panic("usertrap: not from user mode");
    800028f6:	00006517          	auipc	a0,0x6
    800028fa:	a2a50513          	addi	a0,a0,-1494 # 80008320 <states.0+0x58>
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	c40080e7          	jalr	-960(ra) # 8000053e <panic>
    if(killed(p))
    80002906:	8526                	mv	a0,s1
    80002908:	00000097          	auipc	ra,0x0
    8000290c:	9da080e7          	jalr	-1574(ra) # 800022e2 <killed>
    80002910:	e929                	bnez	a0,80002962 <usertrap+0xce>
    kt->trapframe->epc += 4;
    80002912:	00893703          	ld	a4,8(s2)
    80002916:	6f1c                	ld	a5,24(a4)
    80002918:	0791                	addi	a5,a5,4
    8000291a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002920:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002924:	10079073          	csrw	sstatus,a5
    syscall();
    80002928:	00000097          	auipc	ra,0x0
    8000292c:	2d4080e7          	jalr	724(ra) # 80002bfc <syscall>
  if(killed(p))
    80002930:	8526                	mv	a0,s1
    80002932:	00000097          	auipc	ra,0x0
    80002936:	9b0080e7          	jalr	-1616(ra) # 800022e2 <killed>
    8000293a:	c911                	beqz	a0,8000294e <usertrap+0xba>
    8000293c:	4901                	li	s2,0
    exit(-1);
    8000293e:	557d                	li	a0,-1
    80002940:	00000097          	auipc	ra,0x0
    80002944:	82e080e7          	jalr	-2002(ra) # 8000216e <exit>
  if(which_dev == 2)
    80002948:	4789                	li	a5,2
    8000294a:	04f90f63          	beq	s2,a5,800029a8 <usertrap+0x114>
  usertrapret();
    8000294e:	00000097          	auipc	ra,0x0
    80002952:	d9c080e7          	jalr	-612(ra) # 800026ea <usertrapret>
}
    80002956:	60e2                	ld	ra,24(sp)
    80002958:	6442                	ld	s0,16(sp)
    8000295a:	64a2                	ld	s1,8(sp)
    8000295c:	6902                	ld	s2,0(sp)
    8000295e:	6105                	addi	sp,sp,32
    80002960:	8082                	ret
      exit(-1);
    80002962:	557d                	li	a0,-1
    80002964:	00000097          	auipc	ra,0x0
    80002968:	80a080e7          	jalr	-2038(ra) # 8000216e <exit>
    8000296c:	b75d                	j	80002912 <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000296e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002972:	5890                	lw	a2,48(s1)
    80002974:	00006517          	auipc	a0,0x6
    80002978:	9cc50513          	addi	a0,a0,-1588 # 80008340 <states.0+0x78>
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	c0c080e7          	jalr	-1012(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002984:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002988:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000298c:	00006517          	auipc	a0,0x6
    80002990:	9e450513          	addi	a0,a0,-1564 # 80008370 <states.0+0xa8>
    80002994:	ffffe097          	auipc	ra,0xffffe
    80002998:	bf4080e7          	jalr	-1036(ra) # 80000588 <printf>
    setkilled(p);
    8000299c:	8526                	mv	a0,s1
    8000299e:	00000097          	auipc	ra,0x0
    800029a2:	918080e7          	jalr	-1768(ra) # 800022b6 <setkilled>
    800029a6:	b769                	j	80002930 <usertrap+0x9c>
    yield();
    800029a8:	fffff097          	auipc	ra,0xfffff
    800029ac:	656080e7          	jalr	1622(ra) # 80001ffe <yield>
    800029b0:	bf79                	j	8000294e <usertrap+0xba>

00000000800029b2 <kerneltrap>:
{
    800029b2:	7179                	addi	sp,sp,-48
    800029b4:	f406                	sd	ra,40(sp)
    800029b6:	f022                	sd	s0,32(sp)
    800029b8:	ec26                	sd	s1,24(sp)
    800029ba:	e84a                	sd	s2,16(sp)
    800029bc:	e44e                	sd	s3,8(sp)
    800029be:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029c0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029c8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029cc:	1004f793          	andi	a5,s1,256
    800029d0:	cb85                	beqz	a5,80002a00 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029d6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029d8:	ef85                	bnez	a5,80002a10 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029da:	00000097          	auipc	ra,0x0
    800029de:	e18080e7          	jalr	-488(ra) # 800027f2 <devintr>
    800029e2:	cd1d                	beqz	a0,80002a20 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029e4:	4789                	li	a5,2
    800029e6:	06f50a63          	beq	a0,a5,80002a5a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029ea:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ee:	10049073          	csrw	sstatus,s1
}
    800029f2:	70a2                	ld	ra,40(sp)
    800029f4:	7402                	ld	s0,32(sp)
    800029f6:	64e2                	ld	s1,24(sp)
    800029f8:	6942                	ld	s2,16(sp)
    800029fa:	69a2                	ld	s3,8(sp)
    800029fc:	6145                	addi	sp,sp,48
    800029fe:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a00:	00006517          	auipc	a0,0x6
    80002a04:	99050513          	addi	a0,a0,-1648 # 80008390 <states.0+0xc8>
    80002a08:	ffffe097          	auipc	ra,0xffffe
    80002a0c:	b36080e7          	jalr	-1226(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002a10:	00006517          	auipc	a0,0x6
    80002a14:	9a850513          	addi	a0,a0,-1624 # 800083b8 <states.0+0xf0>
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	b26080e7          	jalr	-1242(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002a20:	85ce                	mv	a1,s3
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	9b650513          	addi	a0,a0,-1610 # 800083d8 <states.0+0x110>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	b5e080e7          	jalr	-1186(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a32:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a36:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a3a:	00006517          	auipc	a0,0x6
    80002a3e:	9ae50513          	addi	a0,a0,-1618 # 800083e8 <states.0+0x120>
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	b46080e7          	jalr	-1210(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002a4a:	00006517          	auipc	a0,0x6
    80002a4e:	9b650513          	addi	a0,a0,-1610 # 80008400 <states.0+0x138>
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	aec080e7          	jalr	-1300(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	f26080e7          	jalr	-218(ra) # 80001980 <myproc>
    80002a62:	d541                	beqz	a0,800029ea <kerneltrap+0x38>
    80002a64:	fffff097          	auipc	ra,0xfffff
    80002a68:	f1c080e7          	jalr	-228(ra) # 80001980 <myproc>
    80002a6c:	4d18                	lw	a4,24(a0)
    80002a6e:	4791                	li	a5,4
    80002a70:	f6f71de3          	bne	a4,a5,800029ea <kerneltrap+0x38>
    yield();
    80002a74:	fffff097          	auipc	ra,0xfffff
    80002a78:	58a080e7          	jalr	1418(ra) # 80001ffe <yield>
    80002a7c:	b7bd                	j	800029ea <kerneltrap+0x38>

0000000080002a7e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a7e:	1101                	addi	sp,sp,-32
    80002a80:	ec06                	sd	ra,24(sp)
    80002a82:	e822                	sd	s0,16(sp)
    80002a84:	e426                	sd	s1,8(sp)
    80002a86:	1000                	addi	s0,sp,32
    80002a88:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    80002a8a:	00000097          	auipc	ra,0x0
    80002a8e:	b4c080e7          	jalr	-1204(ra) # 800025d6 <mykthread>
  switch (n) {
    80002a92:	4795                	li	a5,5
    80002a94:	0497e163          	bltu	a5,s1,80002ad6 <argraw+0x58>
    80002a98:	048a                	slli	s1,s1,0x2
    80002a9a:	00006717          	auipc	a4,0x6
    80002a9e:	99e70713          	addi	a4,a4,-1634 # 80008438 <states.0+0x170>
    80002aa2:	94ba                	add	s1,s1,a4
    80002aa4:	409c                	lw	a5,0(s1)
    80002aa6:	97ba                	add	a5,a5,a4
    80002aa8:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    80002aaa:	651c                	ld	a5,8(a0)
    80002aac:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002aae:	60e2                	ld	ra,24(sp)
    80002ab0:	6442                	ld	s0,16(sp)
    80002ab2:	64a2                	ld	s1,8(sp)
    80002ab4:	6105                	addi	sp,sp,32
    80002ab6:	8082                	ret
    return kt->trapframe->a1;
    80002ab8:	651c                	ld	a5,8(a0)
    80002aba:	7fa8                	ld	a0,120(a5)
    80002abc:	bfcd                	j	80002aae <argraw+0x30>
    return kt->trapframe->a2;
    80002abe:	651c                	ld	a5,8(a0)
    80002ac0:	63c8                	ld	a0,128(a5)
    80002ac2:	b7f5                	j	80002aae <argraw+0x30>
    return kt->trapframe->a3;
    80002ac4:	651c                	ld	a5,8(a0)
    80002ac6:	67c8                	ld	a0,136(a5)
    80002ac8:	b7dd                	j	80002aae <argraw+0x30>
    return kt->trapframe->a4;
    80002aca:	651c                	ld	a5,8(a0)
    80002acc:	6bc8                	ld	a0,144(a5)
    80002ace:	b7c5                	j	80002aae <argraw+0x30>
    return kt->trapframe->a5;
    80002ad0:	651c                	ld	a5,8(a0)
    80002ad2:	6fc8                	ld	a0,152(a5)
    80002ad4:	bfe9                	j	80002aae <argraw+0x30>
  panic("argraw");
    80002ad6:	00006517          	auipc	a0,0x6
    80002ada:	93a50513          	addi	a0,a0,-1734 # 80008410 <states.0+0x148>
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	a60080e7          	jalr	-1440(ra) # 8000053e <panic>

0000000080002ae6 <fetchaddr>:
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	e426                	sd	s1,8(sp)
    80002aee:	e04a                	sd	s2,0(sp)
    80002af0:	1000                	addi	s0,sp,32
    80002af2:	84aa                	mv	s1,a0
    80002af4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	e8a080e7          	jalr	-374(ra) # 80001980 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002afe:	713c                	ld	a5,96(a0)
    80002b00:	02f4f863          	bgeu	s1,a5,80002b30 <fetchaddr+0x4a>
    80002b04:	00848713          	addi	a4,s1,8
    80002b08:	02e7e663          	bltu	a5,a4,80002b34 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b0c:	46a1                	li	a3,8
    80002b0e:	8626                	mv	a2,s1
    80002b10:	85ca                	mv	a1,s2
    80002b12:	7528                	ld	a0,104(a0)
    80002b14:	fffff097          	auipc	ra,0xfffff
    80002b18:	be0080e7          	jalr	-1056(ra) # 800016f4 <copyin>
    80002b1c:	00a03533          	snez	a0,a0
    80002b20:	40a00533          	neg	a0,a0
}
    80002b24:	60e2                	ld	ra,24(sp)
    80002b26:	6442                	ld	s0,16(sp)
    80002b28:	64a2                	ld	s1,8(sp)
    80002b2a:	6902                	ld	s2,0(sp)
    80002b2c:	6105                	addi	sp,sp,32
    80002b2e:	8082                	ret
    return -1;
    80002b30:	557d                	li	a0,-1
    80002b32:	bfcd                	j	80002b24 <fetchaddr+0x3e>
    80002b34:	557d                	li	a0,-1
    80002b36:	b7fd                	j	80002b24 <fetchaddr+0x3e>

0000000080002b38 <fetchstr>:
{
    80002b38:	7179                	addi	sp,sp,-48
    80002b3a:	f406                	sd	ra,40(sp)
    80002b3c:	f022                	sd	s0,32(sp)
    80002b3e:	ec26                	sd	s1,24(sp)
    80002b40:	e84a                	sd	s2,16(sp)
    80002b42:	e44e                	sd	s3,8(sp)
    80002b44:	1800                	addi	s0,sp,48
    80002b46:	892a                	mv	s2,a0
    80002b48:	84ae                	mv	s1,a1
    80002b4a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	e34080e7          	jalr	-460(ra) # 80001980 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b54:	86ce                	mv	a3,s3
    80002b56:	864a                	mv	a2,s2
    80002b58:	85a6                	mv	a1,s1
    80002b5a:	7528                	ld	a0,104(a0)
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	c26080e7          	jalr	-986(ra) # 80001782 <copyinstr>
    80002b64:	00054e63          	bltz	a0,80002b80 <fetchstr+0x48>
  return strlen(buf);
    80002b68:	8526                	mv	a0,s1
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	2e4080e7          	jalr	740(ra) # 80000e4e <strlen>
}
    80002b72:	70a2                	ld	ra,40(sp)
    80002b74:	7402                	ld	s0,32(sp)
    80002b76:	64e2                	ld	s1,24(sp)
    80002b78:	6942                	ld	s2,16(sp)
    80002b7a:	69a2                	ld	s3,8(sp)
    80002b7c:	6145                	addi	sp,sp,48
    80002b7e:	8082                	ret
    return -1;
    80002b80:	557d                	li	a0,-1
    80002b82:	bfc5                	j	80002b72 <fetchstr+0x3a>

0000000080002b84 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b84:	1101                	addi	sp,sp,-32
    80002b86:	ec06                	sd	ra,24(sp)
    80002b88:	e822                	sd	s0,16(sp)
    80002b8a:	e426                	sd	s1,8(sp)
    80002b8c:	1000                	addi	s0,sp,32
    80002b8e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b90:	00000097          	auipc	ra,0x0
    80002b94:	eee080e7          	jalr	-274(ra) # 80002a7e <argraw>
    80002b98:	c088                	sw	a0,0(s1)
}
    80002b9a:	60e2                	ld	ra,24(sp)
    80002b9c:	6442                	ld	s0,16(sp)
    80002b9e:	64a2                	ld	s1,8(sp)
    80002ba0:	6105                	addi	sp,sp,32
    80002ba2:	8082                	ret

0000000080002ba4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ba4:	1101                	addi	sp,sp,-32
    80002ba6:	ec06                	sd	ra,24(sp)
    80002ba8:	e822                	sd	s0,16(sp)
    80002baa:	e426                	sd	s1,8(sp)
    80002bac:	1000                	addi	s0,sp,32
    80002bae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bb0:	00000097          	auipc	ra,0x0
    80002bb4:	ece080e7          	jalr	-306(ra) # 80002a7e <argraw>
    80002bb8:	e088                	sd	a0,0(s1)
}
    80002bba:	60e2                	ld	ra,24(sp)
    80002bbc:	6442                	ld	s0,16(sp)
    80002bbe:	64a2                	ld	s1,8(sp)
    80002bc0:	6105                	addi	sp,sp,32
    80002bc2:	8082                	ret

0000000080002bc4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bc4:	7179                	addi	sp,sp,-48
    80002bc6:	f406                	sd	ra,40(sp)
    80002bc8:	f022                	sd	s0,32(sp)
    80002bca:	ec26                	sd	s1,24(sp)
    80002bcc:	e84a                	sd	s2,16(sp)
    80002bce:	1800                	addi	s0,sp,48
    80002bd0:	84ae                	mv	s1,a1
    80002bd2:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002bd4:	fd840593          	addi	a1,s0,-40
    80002bd8:	00000097          	auipc	ra,0x0
    80002bdc:	fcc080e7          	jalr	-52(ra) # 80002ba4 <argaddr>
  return fetchstr(addr, buf, max);
    80002be0:	864a                	mv	a2,s2
    80002be2:	85a6                	mv	a1,s1
    80002be4:	fd843503          	ld	a0,-40(s0)
    80002be8:	00000097          	auipc	ra,0x0
    80002bec:	f50080e7          	jalr	-176(ra) # 80002b38 <fetchstr>
}
    80002bf0:	70a2                	ld	ra,40(sp)
    80002bf2:	7402                	ld	s0,32(sp)
    80002bf4:	64e2                	ld	s1,24(sp)
    80002bf6:	6942                	ld	s2,16(sp)
    80002bf8:	6145                	addi	sp,sp,48
    80002bfa:	8082                	ret

0000000080002bfc <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002bfc:	7179                	addi	sp,sp,-48
    80002bfe:	f406                	sd	ra,40(sp)
    80002c00:	f022                	sd	s0,32(sp)
    80002c02:	ec26                	sd	s1,24(sp)
    80002c04:	e84a                	sd	s2,16(sp)
    80002c06:	e44e                	sd	s3,8(sp)
    80002c08:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002c0a:	fffff097          	auipc	ra,0xfffff
    80002c0e:	d76080e7          	jalr	-650(ra) # 80001980 <myproc>
    80002c12:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    80002c14:	00000097          	auipc	ra,0x0
    80002c18:	9c2080e7          	jalr	-1598(ra) # 800025d6 <mykthread>
    80002c1c:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80002c1e:	00853983          	ld	s3,8(a0)
    80002c22:	0a89b783          	ld	a5,168(s3)
    80002c26:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c2a:	37fd                	addiw	a5,a5,-1
    80002c2c:	4751                	li	a4,20
    80002c2e:	00f76f63          	bltu	a4,a5,80002c4c <syscall+0x50>
    80002c32:	00369713          	slli	a4,a3,0x3
    80002c36:	00006797          	auipc	a5,0x6
    80002c3a:	81a78793          	addi	a5,a5,-2022 # 80008450 <syscalls>
    80002c3e:	97ba                	add	a5,a5,a4
    80002c40:	639c                	ld	a5,0(a5)
    80002c42:	c789                	beqz	a5,80002c4c <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    80002c44:	9782                	jalr	a5
    80002c46:	06a9b823          	sd	a0,112(s3)
    80002c4a:	a005                	j	80002c6a <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c4c:	16890613          	addi	a2,s2,360
    80002c50:	03092583          	lw	a1,48(s2)
    80002c54:	00005517          	auipc	a0,0x5
    80002c58:	7c450513          	addi	a0,a0,1988 # 80008418 <states.0+0x150>
    80002c5c:	ffffe097          	auipc	ra,0xffffe
    80002c60:	92c080e7          	jalr	-1748(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    80002c64:	649c                	ld	a5,8(s1)
    80002c66:	577d                	li	a4,-1
    80002c68:	fbb8                	sd	a4,112(a5)
  }
}
    80002c6a:	70a2                	ld	ra,40(sp)
    80002c6c:	7402                	ld	s0,32(sp)
    80002c6e:	64e2                	ld	s1,24(sp)
    80002c70:	6942                	ld	s2,16(sp)
    80002c72:	69a2                	ld	s3,8(sp)
    80002c74:	6145                	addi	sp,sp,48
    80002c76:	8082                	ret

0000000080002c78 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c78:	1101                	addi	sp,sp,-32
    80002c7a:	ec06                	sd	ra,24(sp)
    80002c7c:	e822                	sd	s0,16(sp)
    80002c7e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c80:	fec40593          	addi	a1,s0,-20
    80002c84:	4501                	li	a0,0
    80002c86:	00000097          	auipc	ra,0x0
    80002c8a:	efe080e7          	jalr	-258(ra) # 80002b84 <argint>
  exit(n);
    80002c8e:	fec42503          	lw	a0,-20(s0)
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	4dc080e7          	jalr	1244(ra) # 8000216e <exit>
  return 0;  // not reached
}
    80002c9a:	4501                	li	a0,0
    80002c9c:	60e2                	ld	ra,24(sp)
    80002c9e:	6442                	ld	s0,16(sp)
    80002ca0:	6105                	addi	sp,sp,32
    80002ca2:	8082                	ret

0000000080002ca4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ca4:	1141                	addi	sp,sp,-16
    80002ca6:	e406                	sd	ra,8(sp)
    80002ca8:	e022                	sd	s0,0(sp)
    80002caa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cac:	fffff097          	auipc	ra,0xfffff
    80002cb0:	cd4080e7          	jalr	-812(ra) # 80001980 <myproc>
}
    80002cb4:	5908                	lw	a0,48(a0)
    80002cb6:	60a2                	ld	ra,8(sp)
    80002cb8:	6402                	ld	s0,0(sp)
    80002cba:	0141                	addi	sp,sp,16
    80002cbc:	8082                	ret

0000000080002cbe <sys_fork>:

uint64
sys_fork(void)
{
    80002cbe:	1141                	addi	sp,sp,-16
    80002cc0:	e406                	sd	ra,8(sp)
    80002cc2:	e022                	sd	s0,0(sp)
    80002cc4:	0800                	addi	s0,sp,16
  return fork();
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	07a080e7          	jalr	122(ra) # 80001d40 <fork>
}
    80002cce:	60a2                	ld	ra,8(sp)
    80002cd0:	6402                	ld	s0,0(sp)
    80002cd2:	0141                	addi	sp,sp,16
    80002cd4:	8082                	ret

0000000080002cd6 <sys_wait>:

uint64
sys_wait(void)
{
    80002cd6:	1101                	addi	sp,sp,-32
    80002cd8:	ec06                	sd	ra,24(sp)
    80002cda:	e822                	sd	s0,16(sp)
    80002cdc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002cde:	fe840593          	addi	a1,s0,-24
    80002ce2:	4501                	li	a0,0
    80002ce4:	00000097          	auipc	ra,0x0
    80002ce8:	ec0080e7          	jalr	-320(ra) # 80002ba4 <argaddr>
  return wait(p);
    80002cec:	fe843503          	ld	a0,-24(s0)
    80002cf0:	fffff097          	auipc	ra,0xfffff
    80002cf4:	624080e7          	jalr	1572(ra) # 80002314 <wait>
}
    80002cf8:	60e2                	ld	ra,24(sp)
    80002cfa:	6442                	ld	s0,16(sp)
    80002cfc:	6105                	addi	sp,sp,32
    80002cfe:	8082                	ret

0000000080002d00 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d00:	7179                	addi	sp,sp,-48
    80002d02:	f406                	sd	ra,40(sp)
    80002d04:	f022                	sd	s0,32(sp)
    80002d06:	ec26                	sd	s1,24(sp)
    80002d08:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d0a:	fdc40593          	addi	a1,s0,-36
    80002d0e:	4501                	li	a0,0
    80002d10:	00000097          	auipc	ra,0x0
    80002d14:	e74080e7          	jalr	-396(ra) # 80002b84 <argint>
  addr = myproc()->sz;
    80002d18:	fffff097          	auipc	ra,0xfffff
    80002d1c:	c68080e7          	jalr	-920(ra) # 80001980 <myproc>
    80002d20:	7124                	ld	s1,96(a0)
  if(growproc(n) < 0)
    80002d22:	fdc42503          	lw	a0,-36(s0)
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	fbe080e7          	jalr	-66(ra) # 80001ce4 <growproc>
    80002d2e:	00054863          	bltz	a0,80002d3e <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002d32:	8526                	mv	a0,s1
    80002d34:	70a2                	ld	ra,40(sp)
    80002d36:	7402                	ld	s0,32(sp)
    80002d38:	64e2                	ld	s1,24(sp)
    80002d3a:	6145                	addi	sp,sp,48
    80002d3c:	8082                	ret
    return -1;
    80002d3e:	54fd                	li	s1,-1
    80002d40:	bfcd                	j	80002d32 <sys_sbrk+0x32>

0000000080002d42 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d42:	7139                	addi	sp,sp,-64
    80002d44:	fc06                	sd	ra,56(sp)
    80002d46:	f822                	sd	s0,48(sp)
    80002d48:	f426                	sd	s1,40(sp)
    80002d4a:	f04a                	sd	s2,32(sp)
    80002d4c:	ec4e                	sd	s3,24(sp)
    80002d4e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d50:	fcc40593          	addi	a1,s0,-52
    80002d54:	4501                	li	a0,0
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	e2e080e7          	jalr	-466(ra) # 80002b84 <argint>
  acquire(&tickslock);
    80002d5e:	00014517          	auipc	a0,0x14
    80002d62:	02250513          	addi	a0,a0,34 # 80016d80 <tickslock>
    80002d66:	ffffe097          	auipc	ra,0xffffe
    80002d6a:	e70080e7          	jalr	-400(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002d6e:	00006917          	auipc	s2,0x6
    80002d72:	b7292903          	lw	s2,-1166(s2) # 800088e0 <ticks>
  while(ticks - ticks0 < n){
    80002d76:	fcc42783          	lw	a5,-52(s0)
    80002d7a:	cf9d                	beqz	a5,80002db8 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d7c:	00014997          	auipc	s3,0x14
    80002d80:	00498993          	addi	s3,s3,4 # 80016d80 <tickslock>
    80002d84:	00006497          	auipc	s1,0x6
    80002d88:	b5c48493          	addi	s1,s1,-1188 # 800088e0 <ticks>
    if(killed(myproc())){
    80002d8c:	fffff097          	auipc	ra,0xfffff
    80002d90:	bf4080e7          	jalr	-1036(ra) # 80001980 <myproc>
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	54e080e7          	jalr	1358(ra) # 800022e2 <killed>
    80002d9c:	ed15                	bnez	a0,80002dd8 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d9e:	85ce                	mv	a1,s3
    80002da0:	8526                	mv	a0,s1
    80002da2:	fffff097          	auipc	ra,0xfffff
    80002da6:	298080e7          	jalr	664(ra) # 8000203a <sleep>
  while(ticks - ticks0 < n){
    80002daa:	409c                	lw	a5,0(s1)
    80002dac:	412787bb          	subw	a5,a5,s2
    80002db0:	fcc42703          	lw	a4,-52(s0)
    80002db4:	fce7ece3          	bltu	a5,a4,80002d8c <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002db8:	00014517          	auipc	a0,0x14
    80002dbc:	fc850513          	addi	a0,a0,-56 # 80016d80 <tickslock>
    80002dc0:	ffffe097          	auipc	ra,0xffffe
    80002dc4:	eca080e7          	jalr	-310(ra) # 80000c8a <release>
  return 0;
    80002dc8:	4501                	li	a0,0
}
    80002dca:	70e2                	ld	ra,56(sp)
    80002dcc:	7442                	ld	s0,48(sp)
    80002dce:	74a2                	ld	s1,40(sp)
    80002dd0:	7902                	ld	s2,32(sp)
    80002dd2:	69e2                	ld	s3,24(sp)
    80002dd4:	6121                	addi	sp,sp,64
    80002dd6:	8082                	ret
      release(&tickslock);
    80002dd8:	00014517          	auipc	a0,0x14
    80002ddc:	fa850513          	addi	a0,a0,-88 # 80016d80 <tickslock>
    80002de0:	ffffe097          	auipc	ra,0xffffe
    80002de4:	eaa080e7          	jalr	-342(ra) # 80000c8a <release>
      return -1;
    80002de8:	557d                	li	a0,-1
    80002dea:	b7c5                	j	80002dca <sys_sleep+0x88>

0000000080002dec <sys_kill>:

uint64
sys_kill(void)
{
    80002dec:	1101                	addi	sp,sp,-32
    80002dee:	ec06                	sd	ra,24(sp)
    80002df0:	e822                	sd	s0,16(sp)
    80002df2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002df4:	fec40593          	addi	a1,s0,-20
    80002df8:	4501                	li	a0,0
    80002dfa:	00000097          	auipc	ra,0x0
    80002dfe:	d8a080e7          	jalr	-630(ra) # 80002b84 <argint>
  return kill(pid);
    80002e02:	fec42503          	lw	a0,-20(s0)
    80002e06:	fffff097          	auipc	ra,0xfffff
    80002e0a:	43e080e7          	jalr	1086(ra) # 80002244 <kill>
}
    80002e0e:	60e2                	ld	ra,24(sp)
    80002e10:	6442                	ld	s0,16(sp)
    80002e12:	6105                	addi	sp,sp,32
    80002e14:	8082                	ret

0000000080002e16 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e16:	1101                	addi	sp,sp,-32
    80002e18:	ec06                	sd	ra,24(sp)
    80002e1a:	e822                	sd	s0,16(sp)
    80002e1c:	e426                	sd	s1,8(sp)
    80002e1e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e20:	00014517          	auipc	a0,0x14
    80002e24:	f6050513          	addi	a0,a0,-160 # 80016d80 <tickslock>
    80002e28:	ffffe097          	auipc	ra,0xffffe
    80002e2c:	dae080e7          	jalr	-594(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002e30:	00006497          	auipc	s1,0x6
    80002e34:	ab04a483          	lw	s1,-1360(s1) # 800088e0 <ticks>
  release(&tickslock);
    80002e38:	00014517          	auipc	a0,0x14
    80002e3c:	f4850513          	addi	a0,a0,-184 # 80016d80 <tickslock>
    80002e40:	ffffe097          	auipc	ra,0xffffe
    80002e44:	e4a080e7          	jalr	-438(ra) # 80000c8a <release>
  return xticks;
}
    80002e48:	02049513          	slli	a0,s1,0x20
    80002e4c:	9101                	srli	a0,a0,0x20
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	64a2                	ld	s1,8(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret

0000000080002e58 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e58:	7179                	addi	sp,sp,-48
    80002e5a:	f406                	sd	ra,40(sp)
    80002e5c:	f022                	sd	s0,32(sp)
    80002e5e:	ec26                	sd	s1,24(sp)
    80002e60:	e84a                	sd	s2,16(sp)
    80002e62:	e44e                	sd	s3,8(sp)
    80002e64:	e052                	sd	s4,0(sp)
    80002e66:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e68:	00005597          	auipc	a1,0x5
    80002e6c:	69858593          	addi	a1,a1,1688 # 80008500 <syscalls+0xb0>
    80002e70:	00014517          	auipc	a0,0x14
    80002e74:	f2850513          	addi	a0,a0,-216 # 80016d98 <bcache>
    80002e78:	ffffe097          	auipc	ra,0xffffe
    80002e7c:	cce080e7          	jalr	-818(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e80:	0001c797          	auipc	a5,0x1c
    80002e84:	f1878793          	addi	a5,a5,-232 # 8001ed98 <bcache+0x8000>
    80002e88:	0001c717          	auipc	a4,0x1c
    80002e8c:	17870713          	addi	a4,a4,376 # 8001f000 <bcache+0x8268>
    80002e90:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e94:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e98:	00014497          	auipc	s1,0x14
    80002e9c:	f1848493          	addi	s1,s1,-232 # 80016db0 <bcache+0x18>
    b->next = bcache.head.next;
    80002ea0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ea2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ea4:	00005a17          	auipc	s4,0x5
    80002ea8:	664a0a13          	addi	s4,s4,1636 # 80008508 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002eac:	2b893783          	ld	a5,696(s2)
    80002eb0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002eb2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002eb6:	85d2                	mv	a1,s4
    80002eb8:	01048513          	addi	a0,s1,16
    80002ebc:	00001097          	auipc	ra,0x1
    80002ec0:	4c4080e7          	jalr	1220(ra) # 80004380 <initsleeplock>
    bcache.head.next->prev = b;
    80002ec4:	2b893783          	ld	a5,696(s2)
    80002ec8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002eca:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ece:	45848493          	addi	s1,s1,1112
    80002ed2:	fd349de3          	bne	s1,s3,80002eac <binit+0x54>
  }
}
    80002ed6:	70a2                	ld	ra,40(sp)
    80002ed8:	7402                	ld	s0,32(sp)
    80002eda:	64e2                	ld	s1,24(sp)
    80002edc:	6942                	ld	s2,16(sp)
    80002ede:	69a2                	ld	s3,8(sp)
    80002ee0:	6a02                	ld	s4,0(sp)
    80002ee2:	6145                	addi	sp,sp,48
    80002ee4:	8082                	ret

0000000080002ee6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ee6:	7179                	addi	sp,sp,-48
    80002ee8:	f406                	sd	ra,40(sp)
    80002eea:	f022                	sd	s0,32(sp)
    80002eec:	ec26                	sd	s1,24(sp)
    80002eee:	e84a                	sd	s2,16(sp)
    80002ef0:	e44e                	sd	s3,8(sp)
    80002ef2:	1800                	addi	s0,sp,48
    80002ef4:	892a                	mv	s2,a0
    80002ef6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ef8:	00014517          	auipc	a0,0x14
    80002efc:	ea050513          	addi	a0,a0,-352 # 80016d98 <bcache>
    80002f00:	ffffe097          	auipc	ra,0xffffe
    80002f04:	cd6080e7          	jalr	-810(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f08:	0001c497          	auipc	s1,0x1c
    80002f0c:	1484b483          	ld	s1,328(s1) # 8001f050 <bcache+0x82b8>
    80002f10:	0001c797          	auipc	a5,0x1c
    80002f14:	0f078793          	addi	a5,a5,240 # 8001f000 <bcache+0x8268>
    80002f18:	02f48f63          	beq	s1,a5,80002f56 <bread+0x70>
    80002f1c:	873e                	mv	a4,a5
    80002f1e:	a021                	j	80002f26 <bread+0x40>
    80002f20:	68a4                	ld	s1,80(s1)
    80002f22:	02e48a63          	beq	s1,a4,80002f56 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f26:	449c                	lw	a5,8(s1)
    80002f28:	ff279ce3          	bne	a5,s2,80002f20 <bread+0x3a>
    80002f2c:	44dc                	lw	a5,12(s1)
    80002f2e:	ff3799e3          	bne	a5,s3,80002f20 <bread+0x3a>
      b->refcnt++;
    80002f32:	40bc                	lw	a5,64(s1)
    80002f34:	2785                	addiw	a5,a5,1
    80002f36:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f38:	00014517          	auipc	a0,0x14
    80002f3c:	e6050513          	addi	a0,a0,-416 # 80016d98 <bcache>
    80002f40:	ffffe097          	auipc	ra,0xffffe
    80002f44:	d4a080e7          	jalr	-694(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f48:	01048513          	addi	a0,s1,16
    80002f4c:	00001097          	auipc	ra,0x1
    80002f50:	46e080e7          	jalr	1134(ra) # 800043ba <acquiresleep>
      return b;
    80002f54:	a8b9                	j	80002fb2 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f56:	0001c497          	auipc	s1,0x1c
    80002f5a:	0f24b483          	ld	s1,242(s1) # 8001f048 <bcache+0x82b0>
    80002f5e:	0001c797          	auipc	a5,0x1c
    80002f62:	0a278793          	addi	a5,a5,162 # 8001f000 <bcache+0x8268>
    80002f66:	00f48863          	beq	s1,a5,80002f76 <bread+0x90>
    80002f6a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f6c:	40bc                	lw	a5,64(s1)
    80002f6e:	cf81                	beqz	a5,80002f86 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f70:	64a4                	ld	s1,72(s1)
    80002f72:	fee49de3          	bne	s1,a4,80002f6c <bread+0x86>
  panic("bget: no buffers");
    80002f76:	00005517          	auipc	a0,0x5
    80002f7a:	59a50513          	addi	a0,a0,1434 # 80008510 <syscalls+0xc0>
    80002f7e:	ffffd097          	auipc	ra,0xffffd
    80002f82:	5c0080e7          	jalr	1472(ra) # 8000053e <panic>
      b->dev = dev;
    80002f86:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f8a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f8e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f92:	4785                	li	a5,1
    80002f94:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f96:	00014517          	auipc	a0,0x14
    80002f9a:	e0250513          	addi	a0,a0,-510 # 80016d98 <bcache>
    80002f9e:	ffffe097          	auipc	ra,0xffffe
    80002fa2:	cec080e7          	jalr	-788(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002fa6:	01048513          	addi	a0,s1,16
    80002faa:	00001097          	auipc	ra,0x1
    80002fae:	410080e7          	jalr	1040(ra) # 800043ba <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fb2:	409c                	lw	a5,0(s1)
    80002fb4:	cb89                	beqz	a5,80002fc6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fb6:	8526                	mv	a0,s1
    80002fb8:	70a2                	ld	ra,40(sp)
    80002fba:	7402                	ld	s0,32(sp)
    80002fbc:	64e2                	ld	s1,24(sp)
    80002fbe:	6942                	ld	s2,16(sp)
    80002fc0:	69a2                	ld	s3,8(sp)
    80002fc2:	6145                	addi	sp,sp,48
    80002fc4:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fc6:	4581                	li	a1,0
    80002fc8:	8526                	mv	a0,s1
    80002fca:	00003097          	auipc	ra,0x3
    80002fce:	fea080e7          	jalr	-22(ra) # 80005fb4 <virtio_disk_rw>
    b->valid = 1;
    80002fd2:	4785                	li	a5,1
    80002fd4:	c09c                	sw	a5,0(s1)
  return b;
    80002fd6:	b7c5                	j	80002fb6 <bread+0xd0>

0000000080002fd8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fd8:	1101                	addi	sp,sp,-32
    80002fda:	ec06                	sd	ra,24(sp)
    80002fdc:	e822                	sd	s0,16(sp)
    80002fde:	e426                	sd	s1,8(sp)
    80002fe0:	1000                	addi	s0,sp,32
    80002fe2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fe4:	0541                	addi	a0,a0,16
    80002fe6:	00001097          	auipc	ra,0x1
    80002fea:	46e080e7          	jalr	1134(ra) # 80004454 <holdingsleep>
    80002fee:	cd01                	beqz	a0,80003006 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ff0:	4585                	li	a1,1
    80002ff2:	8526                	mv	a0,s1
    80002ff4:	00003097          	auipc	ra,0x3
    80002ff8:	fc0080e7          	jalr	-64(ra) # 80005fb4 <virtio_disk_rw>
}
    80002ffc:	60e2                	ld	ra,24(sp)
    80002ffe:	6442                	ld	s0,16(sp)
    80003000:	64a2                	ld	s1,8(sp)
    80003002:	6105                	addi	sp,sp,32
    80003004:	8082                	ret
    panic("bwrite");
    80003006:	00005517          	auipc	a0,0x5
    8000300a:	52250513          	addi	a0,a0,1314 # 80008528 <syscalls+0xd8>
    8000300e:	ffffd097          	auipc	ra,0xffffd
    80003012:	530080e7          	jalr	1328(ra) # 8000053e <panic>

0000000080003016 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003016:	1101                	addi	sp,sp,-32
    80003018:	ec06                	sd	ra,24(sp)
    8000301a:	e822                	sd	s0,16(sp)
    8000301c:	e426                	sd	s1,8(sp)
    8000301e:	e04a                	sd	s2,0(sp)
    80003020:	1000                	addi	s0,sp,32
    80003022:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003024:	01050913          	addi	s2,a0,16
    80003028:	854a                	mv	a0,s2
    8000302a:	00001097          	auipc	ra,0x1
    8000302e:	42a080e7          	jalr	1066(ra) # 80004454 <holdingsleep>
    80003032:	c92d                	beqz	a0,800030a4 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003034:	854a                	mv	a0,s2
    80003036:	00001097          	auipc	ra,0x1
    8000303a:	3da080e7          	jalr	986(ra) # 80004410 <releasesleep>

  acquire(&bcache.lock);
    8000303e:	00014517          	auipc	a0,0x14
    80003042:	d5a50513          	addi	a0,a0,-678 # 80016d98 <bcache>
    80003046:	ffffe097          	auipc	ra,0xffffe
    8000304a:	b90080e7          	jalr	-1136(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000304e:	40bc                	lw	a5,64(s1)
    80003050:	37fd                	addiw	a5,a5,-1
    80003052:	0007871b          	sext.w	a4,a5
    80003056:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003058:	eb05                	bnez	a4,80003088 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000305a:	68bc                	ld	a5,80(s1)
    8000305c:	64b8                	ld	a4,72(s1)
    8000305e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003060:	64bc                	ld	a5,72(s1)
    80003062:	68b8                	ld	a4,80(s1)
    80003064:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003066:	0001c797          	auipc	a5,0x1c
    8000306a:	d3278793          	addi	a5,a5,-718 # 8001ed98 <bcache+0x8000>
    8000306e:	2b87b703          	ld	a4,696(a5)
    80003072:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003074:	0001c717          	auipc	a4,0x1c
    80003078:	f8c70713          	addi	a4,a4,-116 # 8001f000 <bcache+0x8268>
    8000307c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000307e:	2b87b703          	ld	a4,696(a5)
    80003082:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003084:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003088:	00014517          	auipc	a0,0x14
    8000308c:	d1050513          	addi	a0,a0,-752 # 80016d98 <bcache>
    80003090:	ffffe097          	auipc	ra,0xffffe
    80003094:	bfa080e7          	jalr	-1030(ra) # 80000c8a <release>
}
    80003098:	60e2                	ld	ra,24(sp)
    8000309a:	6442                	ld	s0,16(sp)
    8000309c:	64a2                	ld	s1,8(sp)
    8000309e:	6902                	ld	s2,0(sp)
    800030a0:	6105                	addi	sp,sp,32
    800030a2:	8082                	ret
    panic("brelse");
    800030a4:	00005517          	auipc	a0,0x5
    800030a8:	48c50513          	addi	a0,a0,1164 # 80008530 <syscalls+0xe0>
    800030ac:	ffffd097          	auipc	ra,0xffffd
    800030b0:	492080e7          	jalr	1170(ra) # 8000053e <panic>

00000000800030b4 <bpin>:

void
bpin(struct buf *b) {
    800030b4:	1101                	addi	sp,sp,-32
    800030b6:	ec06                	sd	ra,24(sp)
    800030b8:	e822                	sd	s0,16(sp)
    800030ba:	e426                	sd	s1,8(sp)
    800030bc:	1000                	addi	s0,sp,32
    800030be:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030c0:	00014517          	auipc	a0,0x14
    800030c4:	cd850513          	addi	a0,a0,-808 # 80016d98 <bcache>
    800030c8:	ffffe097          	auipc	ra,0xffffe
    800030cc:	b0e080e7          	jalr	-1266(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800030d0:	40bc                	lw	a5,64(s1)
    800030d2:	2785                	addiw	a5,a5,1
    800030d4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030d6:	00014517          	auipc	a0,0x14
    800030da:	cc250513          	addi	a0,a0,-830 # 80016d98 <bcache>
    800030de:	ffffe097          	auipc	ra,0xffffe
    800030e2:	bac080e7          	jalr	-1108(ra) # 80000c8a <release>
}
    800030e6:	60e2                	ld	ra,24(sp)
    800030e8:	6442                	ld	s0,16(sp)
    800030ea:	64a2                	ld	s1,8(sp)
    800030ec:	6105                	addi	sp,sp,32
    800030ee:	8082                	ret

00000000800030f0 <bunpin>:

void
bunpin(struct buf *b) {
    800030f0:	1101                	addi	sp,sp,-32
    800030f2:	ec06                	sd	ra,24(sp)
    800030f4:	e822                	sd	s0,16(sp)
    800030f6:	e426                	sd	s1,8(sp)
    800030f8:	1000                	addi	s0,sp,32
    800030fa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030fc:	00014517          	auipc	a0,0x14
    80003100:	c9c50513          	addi	a0,a0,-868 # 80016d98 <bcache>
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	ad2080e7          	jalr	-1326(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000310c:	40bc                	lw	a5,64(s1)
    8000310e:	37fd                	addiw	a5,a5,-1
    80003110:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003112:	00014517          	auipc	a0,0x14
    80003116:	c8650513          	addi	a0,a0,-890 # 80016d98 <bcache>
    8000311a:	ffffe097          	auipc	ra,0xffffe
    8000311e:	b70080e7          	jalr	-1168(ra) # 80000c8a <release>
}
    80003122:	60e2                	ld	ra,24(sp)
    80003124:	6442                	ld	s0,16(sp)
    80003126:	64a2                	ld	s1,8(sp)
    80003128:	6105                	addi	sp,sp,32
    8000312a:	8082                	ret

000000008000312c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000312c:	1101                	addi	sp,sp,-32
    8000312e:	ec06                	sd	ra,24(sp)
    80003130:	e822                	sd	s0,16(sp)
    80003132:	e426                	sd	s1,8(sp)
    80003134:	e04a                	sd	s2,0(sp)
    80003136:	1000                	addi	s0,sp,32
    80003138:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000313a:	00d5d59b          	srliw	a1,a1,0xd
    8000313e:	0001c797          	auipc	a5,0x1c
    80003142:	3367a783          	lw	a5,822(a5) # 8001f474 <sb+0x1c>
    80003146:	9dbd                	addw	a1,a1,a5
    80003148:	00000097          	auipc	ra,0x0
    8000314c:	d9e080e7          	jalr	-610(ra) # 80002ee6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003150:	0074f713          	andi	a4,s1,7
    80003154:	4785                	li	a5,1
    80003156:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000315a:	14ce                	slli	s1,s1,0x33
    8000315c:	90d9                	srli	s1,s1,0x36
    8000315e:	00950733          	add	a4,a0,s1
    80003162:	05874703          	lbu	a4,88(a4)
    80003166:	00e7f6b3          	and	a3,a5,a4
    8000316a:	c69d                	beqz	a3,80003198 <bfree+0x6c>
    8000316c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000316e:	94aa                	add	s1,s1,a0
    80003170:	fff7c793          	not	a5,a5
    80003174:	8ff9                	and	a5,a5,a4
    80003176:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000317a:	00001097          	auipc	ra,0x1
    8000317e:	120080e7          	jalr	288(ra) # 8000429a <log_write>
  brelse(bp);
    80003182:	854a                	mv	a0,s2
    80003184:	00000097          	auipc	ra,0x0
    80003188:	e92080e7          	jalr	-366(ra) # 80003016 <brelse>
}
    8000318c:	60e2                	ld	ra,24(sp)
    8000318e:	6442                	ld	s0,16(sp)
    80003190:	64a2                	ld	s1,8(sp)
    80003192:	6902                	ld	s2,0(sp)
    80003194:	6105                	addi	sp,sp,32
    80003196:	8082                	ret
    panic("freeing free block");
    80003198:	00005517          	auipc	a0,0x5
    8000319c:	3a050513          	addi	a0,a0,928 # 80008538 <syscalls+0xe8>
    800031a0:	ffffd097          	auipc	ra,0xffffd
    800031a4:	39e080e7          	jalr	926(ra) # 8000053e <panic>

00000000800031a8 <balloc>:
{
    800031a8:	711d                	addi	sp,sp,-96
    800031aa:	ec86                	sd	ra,88(sp)
    800031ac:	e8a2                	sd	s0,80(sp)
    800031ae:	e4a6                	sd	s1,72(sp)
    800031b0:	e0ca                	sd	s2,64(sp)
    800031b2:	fc4e                	sd	s3,56(sp)
    800031b4:	f852                	sd	s4,48(sp)
    800031b6:	f456                	sd	s5,40(sp)
    800031b8:	f05a                	sd	s6,32(sp)
    800031ba:	ec5e                	sd	s7,24(sp)
    800031bc:	e862                	sd	s8,16(sp)
    800031be:	e466                	sd	s9,8(sp)
    800031c0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031c2:	0001c797          	auipc	a5,0x1c
    800031c6:	29a7a783          	lw	a5,666(a5) # 8001f45c <sb+0x4>
    800031ca:	10078163          	beqz	a5,800032cc <balloc+0x124>
    800031ce:	8baa                	mv	s7,a0
    800031d0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031d2:	0001cb17          	auipc	s6,0x1c
    800031d6:	286b0b13          	addi	s6,s6,646 # 8001f458 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031da:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031dc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031de:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031e0:	6c89                	lui	s9,0x2
    800031e2:	a061                	j	8000326a <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031e4:	974a                	add	a4,a4,s2
    800031e6:	8fd5                	or	a5,a5,a3
    800031e8:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800031ec:	854a                	mv	a0,s2
    800031ee:	00001097          	auipc	ra,0x1
    800031f2:	0ac080e7          	jalr	172(ra) # 8000429a <log_write>
        brelse(bp);
    800031f6:	854a                	mv	a0,s2
    800031f8:	00000097          	auipc	ra,0x0
    800031fc:	e1e080e7          	jalr	-482(ra) # 80003016 <brelse>
  bp = bread(dev, bno);
    80003200:	85a6                	mv	a1,s1
    80003202:	855e                	mv	a0,s7
    80003204:	00000097          	auipc	ra,0x0
    80003208:	ce2080e7          	jalr	-798(ra) # 80002ee6 <bread>
    8000320c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000320e:	40000613          	li	a2,1024
    80003212:	4581                	li	a1,0
    80003214:	05850513          	addi	a0,a0,88
    80003218:	ffffe097          	auipc	ra,0xffffe
    8000321c:	aba080e7          	jalr	-1350(ra) # 80000cd2 <memset>
  log_write(bp);
    80003220:	854a                	mv	a0,s2
    80003222:	00001097          	auipc	ra,0x1
    80003226:	078080e7          	jalr	120(ra) # 8000429a <log_write>
  brelse(bp);
    8000322a:	854a                	mv	a0,s2
    8000322c:	00000097          	auipc	ra,0x0
    80003230:	dea080e7          	jalr	-534(ra) # 80003016 <brelse>
}
    80003234:	8526                	mv	a0,s1
    80003236:	60e6                	ld	ra,88(sp)
    80003238:	6446                	ld	s0,80(sp)
    8000323a:	64a6                	ld	s1,72(sp)
    8000323c:	6906                	ld	s2,64(sp)
    8000323e:	79e2                	ld	s3,56(sp)
    80003240:	7a42                	ld	s4,48(sp)
    80003242:	7aa2                	ld	s5,40(sp)
    80003244:	7b02                	ld	s6,32(sp)
    80003246:	6be2                	ld	s7,24(sp)
    80003248:	6c42                	ld	s8,16(sp)
    8000324a:	6ca2                	ld	s9,8(sp)
    8000324c:	6125                	addi	sp,sp,96
    8000324e:	8082                	ret
    brelse(bp);
    80003250:	854a                	mv	a0,s2
    80003252:	00000097          	auipc	ra,0x0
    80003256:	dc4080e7          	jalr	-572(ra) # 80003016 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000325a:	015c87bb          	addw	a5,s9,s5
    8000325e:	00078a9b          	sext.w	s5,a5
    80003262:	004b2703          	lw	a4,4(s6)
    80003266:	06eaf363          	bgeu	s5,a4,800032cc <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000326a:	41fad79b          	sraiw	a5,s5,0x1f
    8000326e:	0137d79b          	srliw	a5,a5,0x13
    80003272:	015787bb          	addw	a5,a5,s5
    80003276:	40d7d79b          	sraiw	a5,a5,0xd
    8000327a:	01cb2583          	lw	a1,28(s6)
    8000327e:	9dbd                	addw	a1,a1,a5
    80003280:	855e                	mv	a0,s7
    80003282:	00000097          	auipc	ra,0x0
    80003286:	c64080e7          	jalr	-924(ra) # 80002ee6 <bread>
    8000328a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000328c:	004b2503          	lw	a0,4(s6)
    80003290:	000a849b          	sext.w	s1,s5
    80003294:	8662                	mv	a2,s8
    80003296:	faa4fde3          	bgeu	s1,a0,80003250 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000329a:	41f6579b          	sraiw	a5,a2,0x1f
    8000329e:	01d7d69b          	srliw	a3,a5,0x1d
    800032a2:	00c6873b          	addw	a4,a3,a2
    800032a6:	00777793          	andi	a5,a4,7
    800032aa:	9f95                	subw	a5,a5,a3
    800032ac:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032b0:	4037571b          	sraiw	a4,a4,0x3
    800032b4:	00e906b3          	add	a3,s2,a4
    800032b8:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    800032bc:	00d7f5b3          	and	a1,a5,a3
    800032c0:	d195                	beqz	a1,800031e4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c2:	2605                	addiw	a2,a2,1
    800032c4:	2485                	addiw	s1,s1,1
    800032c6:	fd4618e3          	bne	a2,s4,80003296 <balloc+0xee>
    800032ca:	b759                	j	80003250 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800032cc:	00005517          	auipc	a0,0x5
    800032d0:	28450513          	addi	a0,a0,644 # 80008550 <syscalls+0x100>
    800032d4:	ffffd097          	auipc	ra,0xffffd
    800032d8:	2b4080e7          	jalr	692(ra) # 80000588 <printf>
  return 0;
    800032dc:	4481                	li	s1,0
    800032de:	bf99                	j	80003234 <balloc+0x8c>

00000000800032e0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032e0:	7179                	addi	sp,sp,-48
    800032e2:	f406                	sd	ra,40(sp)
    800032e4:	f022                	sd	s0,32(sp)
    800032e6:	ec26                	sd	s1,24(sp)
    800032e8:	e84a                	sd	s2,16(sp)
    800032ea:	e44e                	sd	s3,8(sp)
    800032ec:	e052                	sd	s4,0(sp)
    800032ee:	1800                	addi	s0,sp,48
    800032f0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032f2:	47ad                	li	a5,11
    800032f4:	02b7e763          	bltu	a5,a1,80003322 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800032f8:	02059493          	slli	s1,a1,0x20
    800032fc:	9081                	srli	s1,s1,0x20
    800032fe:	048a                	slli	s1,s1,0x2
    80003300:	94aa                	add	s1,s1,a0
    80003302:	0504a903          	lw	s2,80(s1)
    80003306:	06091e63          	bnez	s2,80003382 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000330a:	4108                	lw	a0,0(a0)
    8000330c:	00000097          	auipc	ra,0x0
    80003310:	e9c080e7          	jalr	-356(ra) # 800031a8 <balloc>
    80003314:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003318:	06090563          	beqz	s2,80003382 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000331c:	0524a823          	sw	s2,80(s1)
    80003320:	a08d                	j	80003382 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003322:	ff45849b          	addiw	s1,a1,-12
    80003326:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000332a:	0ff00793          	li	a5,255
    8000332e:	08e7e563          	bltu	a5,a4,800033b8 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003332:	08052903          	lw	s2,128(a0)
    80003336:	00091d63          	bnez	s2,80003350 <bmap+0x70>
      addr = balloc(ip->dev);
    8000333a:	4108                	lw	a0,0(a0)
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	e6c080e7          	jalr	-404(ra) # 800031a8 <balloc>
    80003344:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003348:	02090d63          	beqz	s2,80003382 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000334c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003350:	85ca                	mv	a1,s2
    80003352:	0009a503          	lw	a0,0(s3)
    80003356:	00000097          	auipc	ra,0x0
    8000335a:	b90080e7          	jalr	-1136(ra) # 80002ee6 <bread>
    8000335e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003360:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003364:	02049593          	slli	a1,s1,0x20
    80003368:	9181                	srli	a1,a1,0x20
    8000336a:	058a                	slli	a1,a1,0x2
    8000336c:	00b784b3          	add	s1,a5,a1
    80003370:	0004a903          	lw	s2,0(s1)
    80003374:	02090063          	beqz	s2,80003394 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003378:	8552                	mv	a0,s4
    8000337a:	00000097          	auipc	ra,0x0
    8000337e:	c9c080e7          	jalr	-868(ra) # 80003016 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003382:	854a                	mv	a0,s2
    80003384:	70a2                	ld	ra,40(sp)
    80003386:	7402                	ld	s0,32(sp)
    80003388:	64e2                	ld	s1,24(sp)
    8000338a:	6942                	ld	s2,16(sp)
    8000338c:	69a2                	ld	s3,8(sp)
    8000338e:	6a02                	ld	s4,0(sp)
    80003390:	6145                	addi	sp,sp,48
    80003392:	8082                	ret
      addr = balloc(ip->dev);
    80003394:	0009a503          	lw	a0,0(s3)
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	e10080e7          	jalr	-496(ra) # 800031a8 <balloc>
    800033a0:	0005091b          	sext.w	s2,a0
      if(addr){
    800033a4:	fc090ae3          	beqz	s2,80003378 <bmap+0x98>
        a[bn] = addr;
    800033a8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800033ac:	8552                	mv	a0,s4
    800033ae:	00001097          	auipc	ra,0x1
    800033b2:	eec080e7          	jalr	-276(ra) # 8000429a <log_write>
    800033b6:	b7c9                	j	80003378 <bmap+0x98>
  panic("bmap: out of range");
    800033b8:	00005517          	auipc	a0,0x5
    800033bc:	1b050513          	addi	a0,a0,432 # 80008568 <syscalls+0x118>
    800033c0:	ffffd097          	auipc	ra,0xffffd
    800033c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800033c8 <iget>:
{
    800033c8:	7179                	addi	sp,sp,-48
    800033ca:	f406                	sd	ra,40(sp)
    800033cc:	f022                	sd	s0,32(sp)
    800033ce:	ec26                	sd	s1,24(sp)
    800033d0:	e84a                	sd	s2,16(sp)
    800033d2:	e44e                	sd	s3,8(sp)
    800033d4:	e052                	sd	s4,0(sp)
    800033d6:	1800                	addi	s0,sp,48
    800033d8:	89aa                	mv	s3,a0
    800033da:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033dc:	0001c517          	auipc	a0,0x1c
    800033e0:	09c50513          	addi	a0,a0,156 # 8001f478 <itable>
    800033e4:	ffffd097          	auipc	ra,0xffffd
    800033e8:	7f2080e7          	jalr	2034(ra) # 80000bd6 <acquire>
  empty = 0;
    800033ec:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033ee:	0001c497          	auipc	s1,0x1c
    800033f2:	0a248493          	addi	s1,s1,162 # 8001f490 <itable+0x18>
    800033f6:	0001e697          	auipc	a3,0x1e
    800033fa:	b2a68693          	addi	a3,a3,-1238 # 80020f20 <log>
    800033fe:	a039                	j	8000340c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003400:	02090b63          	beqz	s2,80003436 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003404:	08848493          	addi	s1,s1,136
    80003408:	02d48a63          	beq	s1,a3,8000343c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000340c:	449c                	lw	a5,8(s1)
    8000340e:	fef059e3          	blez	a5,80003400 <iget+0x38>
    80003412:	4098                	lw	a4,0(s1)
    80003414:	ff3716e3          	bne	a4,s3,80003400 <iget+0x38>
    80003418:	40d8                	lw	a4,4(s1)
    8000341a:	ff4713e3          	bne	a4,s4,80003400 <iget+0x38>
      ip->ref++;
    8000341e:	2785                	addiw	a5,a5,1
    80003420:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003422:	0001c517          	auipc	a0,0x1c
    80003426:	05650513          	addi	a0,a0,86 # 8001f478 <itable>
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	860080e7          	jalr	-1952(ra) # 80000c8a <release>
      return ip;
    80003432:	8926                	mv	s2,s1
    80003434:	a03d                	j	80003462 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003436:	f7f9                	bnez	a5,80003404 <iget+0x3c>
    80003438:	8926                	mv	s2,s1
    8000343a:	b7e9                	j	80003404 <iget+0x3c>
  if(empty == 0)
    8000343c:	02090c63          	beqz	s2,80003474 <iget+0xac>
  ip->dev = dev;
    80003440:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003444:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003448:	4785                	li	a5,1
    8000344a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000344e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003452:	0001c517          	auipc	a0,0x1c
    80003456:	02650513          	addi	a0,a0,38 # 8001f478 <itable>
    8000345a:	ffffe097          	auipc	ra,0xffffe
    8000345e:	830080e7          	jalr	-2000(ra) # 80000c8a <release>
}
    80003462:	854a                	mv	a0,s2
    80003464:	70a2                	ld	ra,40(sp)
    80003466:	7402                	ld	s0,32(sp)
    80003468:	64e2                	ld	s1,24(sp)
    8000346a:	6942                	ld	s2,16(sp)
    8000346c:	69a2                	ld	s3,8(sp)
    8000346e:	6a02                	ld	s4,0(sp)
    80003470:	6145                	addi	sp,sp,48
    80003472:	8082                	ret
    panic("iget: no inodes");
    80003474:	00005517          	auipc	a0,0x5
    80003478:	10c50513          	addi	a0,a0,268 # 80008580 <syscalls+0x130>
    8000347c:	ffffd097          	auipc	ra,0xffffd
    80003480:	0c2080e7          	jalr	194(ra) # 8000053e <panic>

0000000080003484 <fsinit>:
fsinit(int dev) {
    80003484:	7179                	addi	sp,sp,-48
    80003486:	f406                	sd	ra,40(sp)
    80003488:	f022                	sd	s0,32(sp)
    8000348a:	ec26                	sd	s1,24(sp)
    8000348c:	e84a                	sd	s2,16(sp)
    8000348e:	e44e                	sd	s3,8(sp)
    80003490:	1800                	addi	s0,sp,48
    80003492:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003494:	4585                	li	a1,1
    80003496:	00000097          	auipc	ra,0x0
    8000349a:	a50080e7          	jalr	-1456(ra) # 80002ee6 <bread>
    8000349e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034a0:	0001c997          	auipc	s3,0x1c
    800034a4:	fb898993          	addi	s3,s3,-72 # 8001f458 <sb>
    800034a8:	02000613          	li	a2,32
    800034ac:	05850593          	addi	a1,a0,88
    800034b0:	854e                	mv	a0,s3
    800034b2:	ffffe097          	auipc	ra,0xffffe
    800034b6:	87c080e7          	jalr	-1924(ra) # 80000d2e <memmove>
  brelse(bp);
    800034ba:	8526                	mv	a0,s1
    800034bc:	00000097          	auipc	ra,0x0
    800034c0:	b5a080e7          	jalr	-1190(ra) # 80003016 <brelse>
  if(sb.magic != FSMAGIC)
    800034c4:	0009a703          	lw	a4,0(s3)
    800034c8:	102037b7          	lui	a5,0x10203
    800034cc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034d0:	02f71263          	bne	a4,a5,800034f4 <fsinit+0x70>
  initlog(dev, &sb);
    800034d4:	0001c597          	auipc	a1,0x1c
    800034d8:	f8458593          	addi	a1,a1,-124 # 8001f458 <sb>
    800034dc:	854a                	mv	a0,s2
    800034de:	00001097          	auipc	ra,0x1
    800034e2:	b40080e7          	jalr	-1216(ra) # 8000401e <initlog>
}
    800034e6:	70a2                	ld	ra,40(sp)
    800034e8:	7402                	ld	s0,32(sp)
    800034ea:	64e2                	ld	s1,24(sp)
    800034ec:	6942                	ld	s2,16(sp)
    800034ee:	69a2                	ld	s3,8(sp)
    800034f0:	6145                	addi	sp,sp,48
    800034f2:	8082                	ret
    panic("invalid file system");
    800034f4:	00005517          	auipc	a0,0x5
    800034f8:	09c50513          	addi	a0,a0,156 # 80008590 <syscalls+0x140>
    800034fc:	ffffd097          	auipc	ra,0xffffd
    80003500:	042080e7          	jalr	66(ra) # 8000053e <panic>

0000000080003504 <iinit>:
{
    80003504:	7179                	addi	sp,sp,-48
    80003506:	f406                	sd	ra,40(sp)
    80003508:	f022                	sd	s0,32(sp)
    8000350a:	ec26                	sd	s1,24(sp)
    8000350c:	e84a                	sd	s2,16(sp)
    8000350e:	e44e                	sd	s3,8(sp)
    80003510:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003512:	00005597          	auipc	a1,0x5
    80003516:	09658593          	addi	a1,a1,150 # 800085a8 <syscalls+0x158>
    8000351a:	0001c517          	auipc	a0,0x1c
    8000351e:	f5e50513          	addi	a0,a0,-162 # 8001f478 <itable>
    80003522:	ffffd097          	auipc	ra,0xffffd
    80003526:	624080e7          	jalr	1572(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000352a:	0001c497          	auipc	s1,0x1c
    8000352e:	f7648493          	addi	s1,s1,-138 # 8001f4a0 <itable+0x28>
    80003532:	0001e997          	auipc	s3,0x1e
    80003536:	9fe98993          	addi	s3,s3,-1538 # 80020f30 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000353a:	00005917          	auipc	s2,0x5
    8000353e:	07690913          	addi	s2,s2,118 # 800085b0 <syscalls+0x160>
    80003542:	85ca                	mv	a1,s2
    80003544:	8526                	mv	a0,s1
    80003546:	00001097          	auipc	ra,0x1
    8000354a:	e3a080e7          	jalr	-454(ra) # 80004380 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000354e:	08848493          	addi	s1,s1,136
    80003552:	ff3498e3          	bne	s1,s3,80003542 <iinit+0x3e>
}
    80003556:	70a2                	ld	ra,40(sp)
    80003558:	7402                	ld	s0,32(sp)
    8000355a:	64e2                	ld	s1,24(sp)
    8000355c:	6942                	ld	s2,16(sp)
    8000355e:	69a2                	ld	s3,8(sp)
    80003560:	6145                	addi	sp,sp,48
    80003562:	8082                	ret

0000000080003564 <ialloc>:
{
    80003564:	715d                	addi	sp,sp,-80
    80003566:	e486                	sd	ra,72(sp)
    80003568:	e0a2                	sd	s0,64(sp)
    8000356a:	fc26                	sd	s1,56(sp)
    8000356c:	f84a                	sd	s2,48(sp)
    8000356e:	f44e                	sd	s3,40(sp)
    80003570:	f052                	sd	s4,32(sp)
    80003572:	ec56                	sd	s5,24(sp)
    80003574:	e85a                	sd	s6,16(sp)
    80003576:	e45e                	sd	s7,8(sp)
    80003578:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000357a:	0001c717          	auipc	a4,0x1c
    8000357e:	eea72703          	lw	a4,-278(a4) # 8001f464 <sb+0xc>
    80003582:	4785                	li	a5,1
    80003584:	04e7fa63          	bgeu	a5,a4,800035d8 <ialloc+0x74>
    80003588:	8aaa                	mv	s5,a0
    8000358a:	8bae                	mv	s7,a1
    8000358c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000358e:	0001ca17          	auipc	s4,0x1c
    80003592:	ecaa0a13          	addi	s4,s4,-310 # 8001f458 <sb>
    80003596:	00048b1b          	sext.w	s6,s1
    8000359a:	0044d793          	srli	a5,s1,0x4
    8000359e:	018a2583          	lw	a1,24(s4)
    800035a2:	9dbd                	addw	a1,a1,a5
    800035a4:	8556                	mv	a0,s5
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	940080e7          	jalr	-1728(ra) # 80002ee6 <bread>
    800035ae:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035b0:	05850993          	addi	s3,a0,88
    800035b4:	00f4f793          	andi	a5,s1,15
    800035b8:	079a                	slli	a5,a5,0x6
    800035ba:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035bc:	00099783          	lh	a5,0(s3)
    800035c0:	c3a1                	beqz	a5,80003600 <ialloc+0x9c>
    brelse(bp);
    800035c2:	00000097          	auipc	ra,0x0
    800035c6:	a54080e7          	jalr	-1452(ra) # 80003016 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035ca:	0485                	addi	s1,s1,1
    800035cc:	00ca2703          	lw	a4,12(s4)
    800035d0:	0004879b          	sext.w	a5,s1
    800035d4:	fce7e1e3          	bltu	a5,a4,80003596 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800035d8:	00005517          	auipc	a0,0x5
    800035dc:	fe050513          	addi	a0,a0,-32 # 800085b8 <syscalls+0x168>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	fa8080e7          	jalr	-88(ra) # 80000588 <printf>
  return 0;
    800035e8:	4501                	li	a0,0
}
    800035ea:	60a6                	ld	ra,72(sp)
    800035ec:	6406                	ld	s0,64(sp)
    800035ee:	74e2                	ld	s1,56(sp)
    800035f0:	7942                	ld	s2,48(sp)
    800035f2:	79a2                	ld	s3,40(sp)
    800035f4:	7a02                	ld	s4,32(sp)
    800035f6:	6ae2                	ld	s5,24(sp)
    800035f8:	6b42                	ld	s6,16(sp)
    800035fa:	6ba2                	ld	s7,8(sp)
    800035fc:	6161                	addi	sp,sp,80
    800035fe:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003600:	04000613          	li	a2,64
    80003604:	4581                	li	a1,0
    80003606:	854e                	mv	a0,s3
    80003608:	ffffd097          	auipc	ra,0xffffd
    8000360c:	6ca080e7          	jalr	1738(ra) # 80000cd2 <memset>
      dip->type = type;
    80003610:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003614:	854a                	mv	a0,s2
    80003616:	00001097          	auipc	ra,0x1
    8000361a:	c84080e7          	jalr	-892(ra) # 8000429a <log_write>
      brelse(bp);
    8000361e:	854a                	mv	a0,s2
    80003620:	00000097          	auipc	ra,0x0
    80003624:	9f6080e7          	jalr	-1546(ra) # 80003016 <brelse>
      return iget(dev, inum);
    80003628:	85da                	mv	a1,s6
    8000362a:	8556                	mv	a0,s5
    8000362c:	00000097          	auipc	ra,0x0
    80003630:	d9c080e7          	jalr	-612(ra) # 800033c8 <iget>
    80003634:	bf5d                	j	800035ea <ialloc+0x86>

0000000080003636 <iupdate>:
{
    80003636:	1101                	addi	sp,sp,-32
    80003638:	ec06                	sd	ra,24(sp)
    8000363a:	e822                	sd	s0,16(sp)
    8000363c:	e426                	sd	s1,8(sp)
    8000363e:	e04a                	sd	s2,0(sp)
    80003640:	1000                	addi	s0,sp,32
    80003642:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003644:	415c                	lw	a5,4(a0)
    80003646:	0047d79b          	srliw	a5,a5,0x4
    8000364a:	0001c597          	auipc	a1,0x1c
    8000364e:	e265a583          	lw	a1,-474(a1) # 8001f470 <sb+0x18>
    80003652:	9dbd                	addw	a1,a1,a5
    80003654:	4108                	lw	a0,0(a0)
    80003656:	00000097          	auipc	ra,0x0
    8000365a:	890080e7          	jalr	-1904(ra) # 80002ee6 <bread>
    8000365e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003660:	05850793          	addi	a5,a0,88
    80003664:	40c8                	lw	a0,4(s1)
    80003666:	893d                	andi	a0,a0,15
    80003668:	051a                	slli	a0,a0,0x6
    8000366a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000366c:	04449703          	lh	a4,68(s1)
    80003670:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003674:	04649703          	lh	a4,70(s1)
    80003678:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000367c:	04849703          	lh	a4,72(s1)
    80003680:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003684:	04a49703          	lh	a4,74(s1)
    80003688:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000368c:	44f8                	lw	a4,76(s1)
    8000368e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003690:	03400613          	li	a2,52
    80003694:	05048593          	addi	a1,s1,80
    80003698:	0531                	addi	a0,a0,12
    8000369a:	ffffd097          	auipc	ra,0xffffd
    8000369e:	694080e7          	jalr	1684(ra) # 80000d2e <memmove>
  log_write(bp);
    800036a2:	854a                	mv	a0,s2
    800036a4:	00001097          	auipc	ra,0x1
    800036a8:	bf6080e7          	jalr	-1034(ra) # 8000429a <log_write>
  brelse(bp);
    800036ac:	854a                	mv	a0,s2
    800036ae:	00000097          	auipc	ra,0x0
    800036b2:	968080e7          	jalr	-1688(ra) # 80003016 <brelse>
}
    800036b6:	60e2                	ld	ra,24(sp)
    800036b8:	6442                	ld	s0,16(sp)
    800036ba:	64a2                	ld	s1,8(sp)
    800036bc:	6902                	ld	s2,0(sp)
    800036be:	6105                	addi	sp,sp,32
    800036c0:	8082                	ret

00000000800036c2 <idup>:
{
    800036c2:	1101                	addi	sp,sp,-32
    800036c4:	ec06                	sd	ra,24(sp)
    800036c6:	e822                	sd	s0,16(sp)
    800036c8:	e426                	sd	s1,8(sp)
    800036ca:	1000                	addi	s0,sp,32
    800036cc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036ce:	0001c517          	auipc	a0,0x1c
    800036d2:	daa50513          	addi	a0,a0,-598 # 8001f478 <itable>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	500080e7          	jalr	1280(ra) # 80000bd6 <acquire>
  ip->ref++;
    800036de:	449c                	lw	a5,8(s1)
    800036e0:	2785                	addiw	a5,a5,1
    800036e2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036e4:	0001c517          	auipc	a0,0x1c
    800036e8:	d9450513          	addi	a0,a0,-620 # 8001f478 <itable>
    800036ec:	ffffd097          	auipc	ra,0xffffd
    800036f0:	59e080e7          	jalr	1438(ra) # 80000c8a <release>
}
    800036f4:	8526                	mv	a0,s1
    800036f6:	60e2                	ld	ra,24(sp)
    800036f8:	6442                	ld	s0,16(sp)
    800036fa:	64a2                	ld	s1,8(sp)
    800036fc:	6105                	addi	sp,sp,32
    800036fe:	8082                	ret

0000000080003700 <ilock>:
{
    80003700:	1101                	addi	sp,sp,-32
    80003702:	ec06                	sd	ra,24(sp)
    80003704:	e822                	sd	s0,16(sp)
    80003706:	e426                	sd	s1,8(sp)
    80003708:	e04a                	sd	s2,0(sp)
    8000370a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000370c:	c115                	beqz	a0,80003730 <ilock+0x30>
    8000370e:	84aa                	mv	s1,a0
    80003710:	451c                	lw	a5,8(a0)
    80003712:	00f05f63          	blez	a5,80003730 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003716:	0541                	addi	a0,a0,16
    80003718:	00001097          	auipc	ra,0x1
    8000371c:	ca2080e7          	jalr	-862(ra) # 800043ba <acquiresleep>
  if(ip->valid == 0){
    80003720:	40bc                	lw	a5,64(s1)
    80003722:	cf99                	beqz	a5,80003740 <ilock+0x40>
}
    80003724:	60e2                	ld	ra,24(sp)
    80003726:	6442                	ld	s0,16(sp)
    80003728:	64a2                	ld	s1,8(sp)
    8000372a:	6902                	ld	s2,0(sp)
    8000372c:	6105                	addi	sp,sp,32
    8000372e:	8082                	ret
    panic("ilock");
    80003730:	00005517          	auipc	a0,0x5
    80003734:	ea050513          	addi	a0,a0,-352 # 800085d0 <syscalls+0x180>
    80003738:	ffffd097          	auipc	ra,0xffffd
    8000373c:	e06080e7          	jalr	-506(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003740:	40dc                	lw	a5,4(s1)
    80003742:	0047d79b          	srliw	a5,a5,0x4
    80003746:	0001c597          	auipc	a1,0x1c
    8000374a:	d2a5a583          	lw	a1,-726(a1) # 8001f470 <sb+0x18>
    8000374e:	9dbd                	addw	a1,a1,a5
    80003750:	4088                	lw	a0,0(s1)
    80003752:	fffff097          	auipc	ra,0xfffff
    80003756:	794080e7          	jalr	1940(ra) # 80002ee6 <bread>
    8000375a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000375c:	05850593          	addi	a1,a0,88
    80003760:	40dc                	lw	a5,4(s1)
    80003762:	8bbd                	andi	a5,a5,15
    80003764:	079a                	slli	a5,a5,0x6
    80003766:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003768:	00059783          	lh	a5,0(a1)
    8000376c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003770:	00259783          	lh	a5,2(a1)
    80003774:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003778:	00459783          	lh	a5,4(a1)
    8000377c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003780:	00659783          	lh	a5,6(a1)
    80003784:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003788:	459c                	lw	a5,8(a1)
    8000378a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000378c:	03400613          	li	a2,52
    80003790:	05b1                	addi	a1,a1,12
    80003792:	05048513          	addi	a0,s1,80
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	598080e7          	jalr	1432(ra) # 80000d2e <memmove>
    brelse(bp);
    8000379e:	854a                	mv	a0,s2
    800037a0:	00000097          	auipc	ra,0x0
    800037a4:	876080e7          	jalr	-1930(ra) # 80003016 <brelse>
    ip->valid = 1;
    800037a8:	4785                	li	a5,1
    800037aa:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037ac:	04449783          	lh	a5,68(s1)
    800037b0:	fbb5                	bnez	a5,80003724 <ilock+0x24>
      panic("ilock: no type");
    800037b2:	00005517          	auipc	a0,0x5
    800037b6:	e2650513          	addi	a0,a0,-474 # 800085d8 <syscalls+0x188>
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	d84080e7          	jalr	-636(ra) # 8000053e <panic>

00000000800037c2 <iunlock>:
{
    800037c2:	1101                	addi	sp,sp,-32
    800037c4:	ec06                	sd	ra,24(sp)
    800037c6:	e822                	sd	s0,16(sp)
    800037c8:	e426                	sd	s1,8(sp)
    800037ca:	e04a                	sd	s2,0(sp)
    800037cc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037ce:	c905                	beqz	a0,800037fe <iunlock+0x3c>
    800037d0:	84aa                	mv	s1,a0
    800037d2:	01050913          	addi	s2,a0,16
    800037d6:	854a                	mv	a0,s2
    800037d8:	00001097          	auipc	ra,0x1
    800037dc:	c7c080e7          	jalr	-900(ra) # 80004454 <holdingsleep>
    800037e0:	cd19                	beqz	a0,800037fe <iunlock+0x3c>
    800037e2:	449c                	lw	a5,8(s1)
    800037e4:	00f05d63          	blez	a5,800037fe <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037e8:	854a                	mv	a0,s2
    800037ea:	00001097          	auipc	ra,0x1
    800037ee:	c26080e7          	jalr	-986(ra) # 80004410 <releasesleep>
}
    800037f2:	60e2                	ld	ra,24(sp)
    800037f4:	6442                	ld	s0,16(sp)
    800037f6:	64a2                	ld	s1,8(sp)
    800037f8:	6902                	ld	s2,0(sp)
    800037fa:	6105                	addi	sp,sp,32
    800037fc:	8082                	ret
    panic("iunlock");
    800037fe:	00005517          	auipc	a0,0x5
    80003802:	dea50513          	addi	a0,a0,-534 # 800085e8 <syscalls+0x198>
    80003806:	ffffd097          	auipc	ra,0xffffd
    8000380a:	d38080e7          	jalr	-712(ra) # 8000053e <panic>

000000008000380e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000380e:	7179                	addi	sp,sp,-48
    80003810:	f406                	sd	ra,40(sp)
    80003812:	f022                	sd	s0,32(sp)
    80003814:	ec26                	sd	s1,24(sp)
    80003816:	e84a                	sd	s2,16(sp)
    80003818:	e44e                	sd	s3,8(sp)
    8000381a:	e052                	sd	s4,0(sp)
    8000381c:	1800                	addi	s0,sp,48
    8000381e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003820:	05050493          	addi	s1,a0,80
    80003824:	08050913          	addi	s2,a0,128
    80003828:	a021                	j	80003830 <itrunc+0x22>
    8000382a:	0491                	addi	s1,s1,4
    8000382c:	01248d63          	beq	s1,s2,80003846 <itrunc+0x38>
    if(ip->addrs[i]){
    80003830:	408c                	lw	a1,0(s1)
    80003832:	dde5                	beqz	a1,8000382a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003834:	0009a503          	lw	a0,0(s3)
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	8f4080e7          	jalr	-1804(ra) # 8000312c <bfree>
      ip->addrs[i] = 0;
    80003840:	0004a023          	sw	zero,0(s1)
    80003844:	b7dd                	j	8000382a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003846:	0809a583          	lw	a1,128(s3)
    8000384a:	e185                	bnez	a1,8000386a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000384c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003850:	854e                	mv	a0,s3
    80003852:	00000097          	auipc	ra,0x0
    80003856:	de4080e7          	jalr	-540(ra) # 80003636 <iupdate>
}
    8000385a:	70a2                	ld	ra,40(sp)
    8000385c:	7402                	ld	s0,32(sp)
    8000385e:	64e2                	ld	s1,24(sp)
    80003860:	6942                	ld	s2,16(sp)
    80003862:	69a2                	ld	s3,8(sp)
    80003864:	6a02                	ld	s4,0(sp)
    80003866:	6145                	addi	sp,sp,48
    80003868:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000386a:	0009a503          	lw	a0,0(s3)
    8000386e:	fffff097          	auipc	ra,0xfffff
    80003872:	678080e7          	jalr	1656(ra) # 80002ee6 <bread>
    80003876:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003878:	05850493          	addi	s1,a0,88
    8000387c:	45850913          	addi	s2,a0,1112
    80003880:	a021                	j	80003888 <itrunc+0x7a>
    80003882:	0491                	addi	s1,s1,4
    80003884:	01248b63          	beq	s1,s2,8000389a <itrunc+0x8c>
      if(a[j])
    80003888:	408c                	lw	a1,0(s1)
    8000388a:	dde5                	beqz	a1,80003882 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000388c:	0009a503          	lw	a0,0(s3)
    80003890:	00000097          	auipc	ra,0x0
    80003894:	89c080e7          	jalr	-1892(ra) # 8000312c <bfree>
    80003898:	b7ed                	j	80003882 <itrunc+0x74>
    brelse(bp);
    8000389a:	8552                	mv	a0,s4
    8000389c:	fffff097          	auipc	ra,0xfffff
    800038a0:	77a080e7          	jalr	1914(ra) # 80003016 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038a4:	0809a583          	lw	a1,128(s3)
    800038a8:	0009a503          	lw	a0,0(s3)
    800038ac:	00000097          	auipc	ra,0x0
    800038b0:	880080e7          	jalr	-1920(ra) # 8000312c <bfree>
    ip->addrs[NDIRECT] = 0;
    800038b4:	0809a023          	sw	zero,128(s3)
    800038b8:	bf51                	j	8000384c <itrunc+0x3e>

00000000800038ba <iput>:
{
    800038ba:	1101                	addi	sp,sp,-32
    800038bc:	ec06                	sd	ra,24(sp)
    800038be:	e822                	sd	s0,16(sp)
    800038c0:	e426                	sd	s1,8(sp)
    800038c2:	e04a                	sd	s2,0(sp)
    800038c4:	1000                	addi	s0,sp,32
    800038c6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038c8:	0001c517          	auipc	a0,0x1c
    800038cc:	bb050513          	addi	a0,a0,-1104 # 8001f478 <itable>
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	306080e7          	jalr	774(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038d8:	4498                	lw	a4,8(s1)
    800038da:	4785                	li	a5,1
    800038dc:	02f70363          	beq	a4,a5,80003902 <iput+0x48>
  ip->ref--;
    800038e0:	449c                	lw	a5,8(s1)
    800038e2:	37fd                	addiw	a5,a5,-1
    800038e4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038e6:	0001c517          	auipc	a0,0x1c
    800038ea:	b9250513          	addi	a0,a0,-1134 # 8001f478 <itable>
    800038ee:	ffffd097          	auipc	ra,0xffffd
    800038f2:	39c080e7          	jalr	924(ra) # 80000c8a <release>
}
    800038f6:	60e2                	ld	ra,24(sp)
    800038f8:	6442                	ld	s0,16(sp)
    800038fa:	64a2                	ld	s1,8(sp)
    800038fc:	6902                	ld	s2,0(sp)
    800038fe:	6105                	addi	sp,sp,32
    80003900:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003902:	40bc                	lw	a5,64(s1)
    80003904:	dff1                	beqz	a5,800038e0 <iput+0x26>
    80003906:	04a49783          	lh	a5,74(s1)
    8000390a:	fbf9                	bnez	a5,800038e0 <iput+0x26>
    acquiresleep(&ip->lock);
    8000390c:	01048913          	addi	s2,s1,16
    80003910:	854a                	mv	a0,s2
    80003912:	00001097          	auipc	ra,0x1
    80003916:	aa8080e7          	jalr	-1368(ra) # 800043ba <acquiresleep>
    release(&itable.lock);
    8000391a:	0001c517          	auipc	a0,0x1c
    8000391e:	b5e50513          	addi	a0,a0,-1186 # 8001f478 <itable>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	368080e7          	jalr	872(ra) # 80000c8a <release>
    itrunc(ip);
    8000392a:	8526                	mv	a0,s1
    8000392c:	00000097          	auipc	ra,0x0
    80003930:	ee2080e7          	jalr	-286(ra) # 8000380e <itrunc>
    ip->type = 0;
    80003934:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003938:	8526                	mv	a0,s1
    8000393a:	00000097          	auipc	ra,0x0
    8000393e:	cfc080e7          	jalr	-772(ra) # 80003636 <iupdate>
    ip->valid = 0;
    80003942:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003946:	854a                	mv	a0,s2
    80003948:	00001097          	auipc	ra,0x1
    8000394c:	ac8080e7          	jalr	-1336(ra) # 80004410 <releasesleep>
    acquire(&itable.lock);
    80003950:	0001c517          	auipc	a0,0x1c
    80003954:	b2850513          	addi	a0,a0,-1240 # 8001f478 <itable>
    80003958:	ffffd097          	auipc	ra,0xffffd
    8000395c:	27e080e7          	jalr	638(ra) # 80000bd6 <acquire>
    80003960:	b741                	j	800038e0 <iput+0x26>

0000000080003962 <iunlockput>:
{
    80003962:	1101                	addi	sp,sp,-32
    80003964:	ec06                	sd	ra,24(sp)
    80003966:	e822                	sd	s0,16(sp)
    80003968:	e426                	sd	s1,8(sp)
    8000396a:	1000                	addi	s0,sp,32
    8000396c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000396e:	00000097          	auipc	ra,0x0
    80003972:	e54080e7          	jalr	-428(ra) # 800037c2 <iunlock>
  iput(ip);
    80003976:	8526                	mv	a0,s1
    80003978:	00000097          	auipc	ra,0x0
    8000397c:	f42080e7          	jalr	-190(ra) # 800038ba <iput>
}
    80003980:	60e2                	ld	ra,24(sp)
    80003982:	6442                	ld	s0,16(sp)
    80003984:	64a2                	ld	s1,8(sp)
    80003986:	6105                	addi	sp,sp,32
    80003988:	8082                	ret

000000008000398a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000398a:	1141                	addi	sp,sp,-16
    8000398c:	e422                	sd	s0,8(sp)
    8000398e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003990:	411c                	lw	a5,0(a0)
    80003992:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003994:	415c                	lw	a5,4(a0)
    80003996:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003998:	04451783          	lh	a5,68(a0)
    8000399c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039a0:	04a51783          	lh	a5,74(a0)
    800039a4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039a8:	04c56783          	lwu	a5,76(a0)
    800039ac:	e99c                	sd	a5,16(a1)
}
    800039ae:	6422                	ld	s0,8(sp)
    800039b0:	0141                	addi	sp,sp,16
    800039b2:	8082                	ret

00000000800039b4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039b4:	457c                	lw	a5,76(a0)
    800039b6:	0ed7e963          	bltu	a5,a3,80003aa8 <readi+0xf4>
{
    800039ba:	7159                	addi	sp,sp,-112
    800039bc:	f486                	sd	ra,104(sp)
    800039be:	f0a2                	sd	s0,96(sp)
    800039c0:	eca6                	sd	s1,88(sp)
    800039c2:	e8ca                	sd	s2,80(sp)
    800039c4:	e4ce                	sd	s3,72(sp)
    800039c6:	e0d2                	sd	s4,64(sp)
    800039c8:	fc56                	sd	s5,56(sp)
    800039ca:	f85a                	sd	s6,48(sp)
    800039cc:	f45e                	sd	s7,40(sp)
    800039ce:	f062                	sd	s8,32(sp)
    800039d0:	ec66                	sd	s9,24(sp)
    800039d2:	e86a                	sd	s10,16(sp)
    800039d4:	e46e                	sd	s11,8(sp)
    800039d6:	1880                	addi	s0,sp,112
    800039d8:	8b2a                	mv	s6,a0
    800039da:	8bae                	mv	s7,a1
    800039dc:	8a32                	mv	s4,a2
    800039de:	84b6                	mv	s1,a3
    800039e0:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039e2:	9f35                	addw	a4,a4,a3
    return 0;
    800039e4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039e6:	0ad76063          	bltu	a4,a3,80003a86 <readi+0xd2>
  if(off + n > ip->size)
    800039ea:	00e7f463          	bgeu	a5,a4,800039f2 <readi+0x3e>
    n = ip->size - off;
    800039ee:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039f2:	0a0a8963          	beqz	s5,80003aa4 <readi+0xf0>
    800039f6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039f8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039fc:	5c7d                	li	s8,-1
    800039fe:	a82d                	j	80003a38 <readi+0x84>
    80003a00:	020d1d93          	slli	s11,s10,0x20
    80003a04:	020ddd93          	srli	s11,s11,0x20
    80003a08:	05890793          	addi	a5,s2,88
    80003a0c:	86ee                	mv	a3,s11
    80003a0e:	963e                	add	a2,a2,a5
    80003a10:	85d2                	mv	a1,s4
    80003a12:	855e                	mv	a0,s7
    80003a14:	fffff097          	auipc	ra,0xfffff
    80003a18:	a2e080e7          	jalr	-1490(ra) # 80002442 <either_copyout>
    80003a1c:	05850d63          	beq	a0,s8,80003a76 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a20:	854a                	mv	a0,s2
    80003a22:	fffff097          	auipc	ra,0xfffff
    80003a26:	5f4080e7          	jalr	1524(ra) # 80003016 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a2a:	013d09bb          	addw	s3,s10,s3
    80003a2e:	009d04bb          	addw	s1,s10,s1
    80003a32:	9a6e                	add	s4,s4,s11
    80003a34:	0559f763          	bgeu	s3,s5,80003a82 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a38:	00a4d59b          	srliw	a1,s1,0xa
    80003a3c:	855a                	mv	a0,s6
    80003a3e:	00000097          	auipc	ra,0x0
    80003a42:	8a2080e7          	jalr	-1886(ra) # 800032e0 <bmap>
    80003a46:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a4a:	cd85                	beqz	a1,80003a82 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a4c:	000b2503          	lw	a0,0(s6)
    80003a50:	fffff097          	auipc	ra,0xfffff
    80003a54:	496080e7          	jalr	1174(ra) # 80002ee6 <bread>
    80003a58:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a5a:	3ff4f613          	andi	a2,s1,1023
    80003a5e:	40cc87bb          	subw	a5,s9,a2
    80003a62:	413a873b          	subw	a4,s5,s3
    80003a66:	8d3e                	mv	s10,a5
    80003a68:	2781                	sext.w	a5,a5
    80003a6a:	0007069b          	sext.w	a3,a4
    80003a6e:	f8f6f9e3          	bgeu	a3,a5,80003a00 <readi+0x4c>
    80003a72:	8d3a                	mv	s10,a4
    80003a74:	b771                	j	80003a00 <readi+0x4c>
      brelse(bp);
    80003a76:	854a                	mv	a0,s2
    80003a78:	fffff097          	auipc	ra,0xfffff
    80003a7c:	59e080e7          	jalr	1438(ra) # 80003016 <brelse>
      tot = -1;
    80003a80:	59fd                	li	s3,-1
  }
  return tot;
    80003a82:	0009851b          	sext.w	a0,s3
}
    80003a86:	70a6                	ld	ra,104(sp)
    80003a88:	7406                	ld	s0,96(sp)
    80003a8a:	64e6                	ld	s1,88(sp)
    80003a8c:	6946                	ld	s2,80(sp)
    80003a8e:	69a6                	ld	s3,72(sp)
    80003a90:	6a06                	ld	s4,64(sp)
    80003a92:	7ae2                	ld	s5,56(sp)
    80003a94:	7b42                	ld	s6,48(sp)
    80003a96:	7ba2                	ld	s7,40(sp)
    80003a98:	7c02                	ld	s8,32(sp)
    80003a9a:	6ce2                	ld	s9,24(sp)
    80003a9c:	6d42                	ld	s10,16(sp)
    80003a9e:	6da2                	ld	s11,8(sp)
    80003aa0:	6165                	addi	sp,sp,112
    80003aa2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aa4:	89d6                	mv	s3,s5
    80003aa6:	bff1                	j	80003a82 <readi+0xce>
    return 0;
    80003aa8:	4501                	li	a0,0
}
    80003aaa:	8082                	ret

0000000080003aac <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aac:	457c                	lw	a5,76(a0)
    80003aae:	10d7e863          	bltu	a5,a3,80003bbe <writei+0x112>
{
    80003ab2:	7159                	addi	sp,sp,-112
    80003ab4:	f486                	sd	ra,104(sp)
    80003ab6:	f0a2                	sd	s0,96(sp)
    80003ab8:	eca6                	sd	s1,88(sp)
    80003aba:	e8ca                	sd	s2,80(sp)
    80003abc:	e4ce                	sd	s3,72(sp)
    80003abe:	e0d2                	sd	s4,64(sp)
    80003ac0:	fc56                	sd	s5,56(sp)
    80003ac2:	f85a                	sd	s6,48(sp)
    80003ac4:	f45e                	sd	s7,40(sp)
    80003ac6:	f062                	sd	s8,32(sp)
    80003ac8:	ec66                	sd	s9,24(sp)
    80003aca:	e86a                	sd	s10,16(sp)
    80003acc:	e46e                	sd	s11,8(sp)
    80003ace:	1880                	addi	s0,sp,112
    80003ad0:	8aaa                	mv	s5,a0
    80003ad2:	8bae                	mv	s7,a1
    80003ad4:	8a32                	mv	s4,a2
    80003ad6:	8936                	mv	s2,a3
    80003ad8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ada:	00e687bb          	addw	a5,a3,a4
    80003ade:	0ed7e263          	bltu	a5,a3,80003bc2 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ae2:	00043737          	lui	a4,0x43
    80003ae6:	0ef76063          	bltu	a4,a5,80003bc6 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aea:	0c0b0863          	beqz	s6,80003bba <writei+0x10e>
    80003aee:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003af0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003af4:	5c7d                	li	s8,-1
    80003af6:	a091                	j	80003b3a <writei+0x8e>
    80003af8:	020d1d93          	slli	s11,s10,0x20
    80003afc:	020ddd93          	srli	s11,s11,0x20
    80003b00:	05848793          	addi	a5,s1,88
    80003b04:	86ee                	mv	a3,s11
    80003b06:	8652                	mv	a2,s4
    80003b08:	85de                	mv	a1,s7
    80003b0a:	953e                	add	a0,a0,a5
    80003b0c:	fffff097          	auipc	ra,0xfffff
    80003b10:	98c080e7          	jalr	-1652(ra) # 80002498 <either_copyin>
    80003b14:	07850263          	beq	a0,s8,80003b78 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b18:	8526                	mv	a0,s1
    80003b1a:	00000097          	auipc	ra,0x0
    80003b1e:	780080e7          	jalr	1920(ra) # 8000429a <log_write>
    brelse(bp);
    80003b22:	8526                	mv	a0,s1
    80003b24:	fffff097          	auipc	ra,0xfffff
    80003b28:	4f2080e7          	jalr	1266(ra) # 80003016 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b2c:	013d09bb          	addw	s3,s10,s3
    80003b30:	012d093b          	addw	s2,s10,s2
    80003b34:	9a6e                	add	s4,s4,s11
    80003b36:	0569f663          	bgeu	s3,s6,80003b82 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b3a:	00a9559b          	srliw	a1,s2,0xa
    80003b3e:	8556                	mv	a0,s5
    80003b40:	fffff097          	auipc	ra,0xfffff
    80003b44:	7a0080e7          	jalr	1952(ra) # 800032e0 <bmap>
    80003b48:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b4c:	c99d                	beqz	a1,80003b82 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b4e:	000aa503          	lw	a0,0(s5)
    80003b52:	fffff097          	auipc	ra,0xfffff
    80003b56:	394080e7          	jalr	916(ra) # 80002ee6 <bread>
    80003b5a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b5c:	3ff97513          	andi	a0,s2,1023
    80003b60:	40ac87bb          	subw	a5,s9,a0
    80003b64:	413b073b          	subw	a4,s6,s3
    80003b68:	8d3e                	mv	s10,a5
    80003b6a:	2781                	sext.w	a5,a5
    80003b6c:	0007069b          	sext.w	a3,a4
    80003b70:	f8f6f4e3          	bgeu	a3,a5,80003af8 <writei+0x4c>
    80003b74:	8d3a                	mv	s10,a4
    80003b76:	b749                	j	80003af8 <writei+0x4c>
      brelse(bp);
    80003b78:	8526                	mv	a0,s1
    80003b7a:	fffff097          	auipc	ra,0xfffff
    80003b7e:	49c080e7          	jalr	1180(ra) # 80003016 <brelse>
  }

  if(off > ip->size)
    80003b82:	04caa783          	lw	a5,76(s5)
    80003b86:	0127f463          	bgeu	a5,s2,80003b8e <writei+0xe2>
    ip->size = off;
    80003b8a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b8e:	8556                	mv	a0,s5
    80003b90:	00000097          	auipc	ra,0x0
    80003b94:	aa6080e7          	jalr	-1370(ra) # 80003636 <iupdate>

  return tot;
    80003b98:	0009851b          	sext.w	a0,s3
}
    80003b9c:	70a6                	ld	ra,104(sp)
    80003b9e:	7406                	ld	s0,96(sp)
    80003ba0:	64e6                	ld	s1,88(sp)
    80003ba2:	6946                	ld	s2,80(sp)
    80003ba4:	69a6                	ld	s3,72(sp)
    80003ba6:	6a06                	ld	s4,64(sp)
    80003ba8:	7ae2                	ld	s5,56(sp)
    80003baa:	7b42                	ld	s6,48(sp)
    80003bac:	7ba2                	ld	s7,40(sp)
    80003bae:	7c02                	ld	s8,32(sp)
    80003bb0:	6ce2                	ld	s9,24(sp)
    80003bb2:	6d42                	ld	s10,16(sp)
    80003bb4:	6da2                	ld	s11,8(sp)
    80003bb6:	6165                	addi	sp,sp,112
    80003bb8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bba:	89da                	mv	s3,s6
    80003bbc:	bfc9                	j	80003b8e <writei+0xe2>
    return -1;
    80003bbe:	557d                	li	a0,-1
}
    80003bc0:	8082                	ret
    return -1;
    80003bc2:	557d                	li	a0,-1
    80003bc4:	bfe1                	j	80003b9c <writei+0xf0>
    return -1;
    80003bc6:	557d                	li	a0,-1
    80003bc8:	bfd1                	j	80003b9c <writei+0xf0>

0000000080003bca <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bca:	1141                	addi	sp,sp,-16
    80003bcc:	e406                	sd	ra,8(sp)
    80003bce:	e022                	sd	s0,0(sp)
    80003bd0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bd2:	4639                	li	a2,14
    80003bd4:	ffffd097          	auipc	ra,0xffffd
    80003bd8:	1ce080e7          	jalr	462(ra) # 80000da2 <strncmp>
}
    80003bdc:	60a2                	ld	ra,8(sp)
    80003bde:	6402                	ld	s0,0(sp)
    80003be0:	0141                	addi	sp,sp,16
    80003be2:	8082                	ret

0000000080003be4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003be4:	7139                	addi	sp,sp,-64
    80003be6:	fc06                	sd	ra,56(sp)
    80003be8:	f822                	sd	s0,48(sp)
    80003bea:	f426                	sd	s1,40(sp)
    80003bec:	f04a                	sd	s2,32(sp)
    80003bee:	ec4e                	sd	s3,24(sp)
    80003bf0:	e852                	sd	s4,16(sp)
    80003bf2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003bf4:	04451703          	lh	a4,68(a0)
    80003bf8:	4785                	li	a5,1
    80003bfa:	00f71a63          	bne	a4,a5,80003c0e <dirlookup+0x2a>
    80003bfe:	892a                	mv	s2,a0
    80003c00:	89ae                	mv	s3,a1
    80003c02:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c04:	457c                	lw	a5,76(a0)
    80003c06:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c08:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c0a:	e79d                	bnez	a5,80003c38 <dirlookup+0x54>
    80003c0c:	a8a5                	j	80003c84 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c0e:	00005517          	auipc	a0,0x5
    80003c12:	9e250513          	addi	a0,a0,-1566 # 800085f0 <syscalls+0x1a0>
    80003c16:	ffffd097          	auipc	ra,0xffffd
    80003c1a:	928080e7          	jalr	-1752(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003c1e:	00005517          	auipc	a0,0x5
    80003c22:	9ea50513          	addi	a0,a0,-1558 # 80008608 <syscalls+0x1b8>
    80003c26:	ffffd097          	auipc	ra,0xffffd
    80003c2a:	918080e7          	jalr	-1768(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c2e:	24c1                	addiw	s1,s1,16
    80003c30:	04c92783          	lw	a5,76(s2)
    80003c34:	04f4f763          	bgeu	s1,a5,80003c82 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c38:	4741                	li	a4,16
    80003c3a:	86a6                	mv	a3,s1
    80003c3c:	fc040613          	addi	a2,s0,-64
    80003c40:	4581                	li	a1,0
    80003c42:	854a                	mv	a0,s2
    80003c44:	00000097          	auipc	ra,0x0
    80003c48:	d70080e7          	jalr	-656(ra) # 800039b4 <readi>
    80003c4c:	47c1                	li	a5,16
    80003c4e:	fcf518e3          	bne	a0,a5,80003c1e <dirlookup+0x3a>
    if(de.inum == 0)
    80003c52:	fc045783          	lhu	a5,-64(s0)
    80003c56:	dfe1                	beqz	a5,80003c2e <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c58:	fc240593          	addi	a1,s0,-62
    80003c5c:	854e                	mv	a0,s3
    80003c5e:	00000097          	auipc	ra,0x0
    80003c62:	f6c080e7          	jalr	-148(ra) # 80003bca <namecmp>
    80003c66:	f561                	bnez	a0,80003c2e <dirlookup+0x4a>
      if(poff)
    80003c68:	000a0463          	beqz	s4,80003c70 <dirlookup+0x8c>
        *poff = off;
    80003c6c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c70:	fc045583          	lhu	a1,-64(s0)
    80003c74:	00092503          	lw	a0,0(s2)
    80003c78:	fffff097          	auipc	ra,0xfffff
    80003c7c:	750080e7          	jalr	1872(ra) # 800033c8 <iget>
    80003c80:	a011                	j	80003c84 <dirlookup+0xa0>
  return 0;
    80003c82:	4501                	li	a0,0
}
    80003c84:	70e2                	ld	ra,56(sp)
    80003c86:	7442                	ld	s0,48(sp)
    80003c88:	74a2                	ld	s1,40(sp)
    80003c8a:	7902                	ld	s2,32(sp)
    80003c8c:	69e2                	ld	s3,24(sp)
    80003c8e:	6a42                	ld	s4,16(sp)
    80003c90:	6121                	addi	sp,sp,64
    80003c92:	8082                	ret

0000000080003c94 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c94:	711d                	addi	sp,sp,-96
    80003c96:	ec86                	sd	ra,88(sp)
    80003c98:	e8a2                	sd	s0,80(sp)
    80003c9a:	e4a6                	sd	s1,72(sp)
    80003c9c:	e0ca                	sd	s2,64(sp)
    80003c9e:	fc4e                	sd	s3,56(sp)
    80003ca0:	f852                	sd	s4,48(sp)
    80003ca2:	f456                	sd	s5,40(sp)
    80003ca4:	f05a                	sd	s6,32(sp)
    80003ca6:	ec5e                	sd	s7,24(sp)
    80003ca8:	e862                	sd	s8,16(sp)
    80003caa:	e466                	sd	s9,8(sp)
    80003cac:	1080                	addi	s0,sp,96
    80003cae:	84aa                	mv	s1,a0
    80003cb0:	8aae                	mv	s5,a1
    80003cb2:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cb4:	00054703          	lbu	a4,0(a0)
    80003cb8:	02f00793          	li	a5,47
    80003cbc:	02f70363          	beq	a4,a5,80003ce2 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cc0:	ffffe097          	auipc	ra,0xffffe
    80003cc4:	cc0080e7          	jalr	-832(ra) # 80001980 <myproc>
    80003cc8:	16053503          	ld	a0,352(a0)
    80003ccc:	00000097          	auipc	ra,0x0
    80003cd0:	9f6080e7          	jalr	-1546(ra) # 800036c2 <idup>
    80003cd4:	89aa                	mv	s3,a0
  while(*path == '/')
    80003cd6:	02f00913          	li	s2,47
  len = path - s;
    80003cda:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003cdc:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cde:	4b85                	li	s7,1
    80003ce0:	a865                	j	80003d98 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003ce2:	4585                	li	a1,1
    80003ce4:	4505                	li	a0,1
    80003ce6:	fffff097          	auipc	ra,0xfffff
    80003cea:	6e2080e7          	jalr	1762(ra) # 800033c8 <iget>
    80003cee:	89aa                	mv	s3,a0
    80003cf0:	b7dd                	j	80003cd6 <namex+0x42>
      iunlockput(ip);
    80003cf2:	854e                	mv	a0,s3
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	c6e080e7          	jalr	-914(ra) # 80003962 <iunlockput>
      return 0;
    80003cfc:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cfe:	854e                	mv	a0,s3
    80003d00:	60e6                	ld	ra,88(sp)
    80003d02:	6446                	ld	s0,80(sp)
    80003d04:	64a6                	ld	s1,72(sp)
    80003d06:	6906                	ld	s2,64(sp)
    80003d08:	79e2                	ld	s3,56(sp)
    80003d0a:	7a42                	ld	s4,48(sp)
    80003d0c:	7aa2                	ld	s5,40(sp)
    80003d0e:	7b02                	ld	s6,32(sp)
    80003d10:	6be2                	ld	s7,24(sp)
    80003d12:	6c42                	ld	s8,16(sp)
    80003d14:	6ca2                	ld	s9,8(sp)
    80003d16:	6125                	addi	sp,sp,96
    80003d18:	8082                	ret
      iunlock(ip);
    80003d1a:	854e                	mv	a0,s3
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	aa6080e7          	jalr	-1370(ra) # 800037c2 <iunlock>
      return ip;
    80003d24:	bfe9                	j	80003cfe <namex+0x6a>
      iunlockput(ip);
    80003d26:	854e                	mv	a0,s3
    80003d28:	00000097          	auipc	ra,0x0
    80003d2c:	c3a080e7          	jalr	-966(ra) # 80003962 <iunlockput>
      return 0;
    80003d30:	89e6                	mv	s3,s9
    80003d32:	b7f1                	j	80003cfe <namex+0x6a>
  len = path - s;
    80003d34:	40b48633          	sub	a2,s1,a1
    80003d38:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d3c:	099c5463          	bge	s8,s9,80003dc4 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d40:	4639                	li	a2,14
    80003d42:	8552                	mv	a0,s4
    80003d44:	ffffd097          	auipc	ra,0xffffd
    80003d48:	fea080e7          	jalr	-22(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003d4c:	0004c783          	lbu	a5,0(s1)
    80003d50:	01279763          	bne	a5,s2,80003d5e <namex+0xca>
    path++;
    80003d54:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d56:	0004c783          	lbu	a5,0(s1)
    80003d5a:	ff278de3          	beq	a5,s2,80003d54 <namex+0xc0>
    ilock(ip);
    80003d5e:	854e                	mv	a0,s3
    80003d60:	00000097          	auipc	ra,0x0
    80003d64:	9a0080e7          	jalr	-1632(ra) # 80003700 <ilock>
    if(ip->type != T_DIR){
    80003d68:	04499783          	lh	a5,68(s3)
    80003d6c:	f97793e3          	bne	a5,s7,80003cf2 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d70:	000a8563          	beqz	s5,80003d7a <namex+0xe6>
    80003d74:	0004c783          	lbu	a5,0(s1)
    80003d78:	d3cd                	beqz	a5,80003d1a <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d7a:	865a                	mv	a2,s6
    80003d7c:	85d2                	mv	a1,s4
    80003d7e:	854e                	mv	a0,s3
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	e64080e7          	jalr	-412(ra) # 80003be4 <dirlookup>
    80003d88:	8caa                	mv	s9,a0
    80003d8a:	dd51                	beqz	a0,80003d26 <namex+0x92>
    iunlockput(ip);
    80003d8c:	854e                	mv	a0,s3
    80003d8e:	00000097          	auipc	ra,0x0
    80003d92:	bd4080e7          	jalr	-1068(ra) # 80003962 <iunlockput>
    ip = next;
    80003d96:	89e6                	mv	s3,s9
  while(*path == '/')
    80003d98:	0004c783          	lbu	a5,0(s1)
    80003d9c:	05279763          	bne	a5,s2,80003dea <namex+0x156>
    path++;
    80003da0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003da2:	0004c783          	lbu	a5,0(s1)
    80003da6:	ff278de3          	beq	a5,s2,80003da0 <namex+0x10c>
  if(*path == 0)
    80003daa:	c79d                	beqz	a5,80003dd8 <namex+0x144>
    path++;
    80003dac:	85a6                	mv	a1,s1
  len = path - s;
    80003dae:	8cda                	mv	s9,s6
    80003db0:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003db2:	01278963          	beq	a5,s2,80003dc4 <namex+0x130>
    80003db6:	dfbd                	beqz	a5,80003d34 <namex+0xa0>
    path++;
    80003db8:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003dba:	0004c783          	lbu	a5,0(s1)
    80003dbe:	ff279ce3          	bne	a5,s2,80003db6 <namex+0x122>
    80003dc2:	bf8d                	j	80003d34 <namex+0xa0>
    memmove(name, s, len);
    80003dc4:	2601                	sext.w	a2,a2
    80003dc6:	8552                	mv	a0,s4
    80003dc8:	ffffd097          	auipc	ra,0xffffd
    80003dcc:	f66080e7          	jalr	-154(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003dd0:	9cd2                	add	s9,s9,s4
    80003dd2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003dd6:	bf9d                	j	80003d4c <namex+0xb8>
  if(nameiparent){
    80003dd8:	f20a83e3          	beqz	s5,80003cfe <namex+0x6a>
    iput(ip);
    80003ddc:	854e                	mv	a0,s3
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	adc080e7          	jalr	-1316(ra) # 800038ba <iput>
    return 0;
    80003de6:	4981                	li	s3,0
    80003de8:	bf19                	j	80003cfe <namex+0x6a>
  if(*path == 0)
    80003dea:	d7fd                	beqz	a5,80003dd8 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003dec:	0004c783          	lbu	a5,0(s1)
    80003df0:	85a6                	mv	a1,s1
    80003df2:	b7d1                	j	80003db6 <namex+0x122>

0000000080003df4 <dirlink>:
{
    80003df4:	7139                	addi	sp,sp,-64
    80003df6:	fc06                	sd	ra,56(sp)
    80003df8:	f822                	sd	s0,48(sp)
    80003dfa:	f426                	sd	s1,40(sp)
    80003dfc:	f04a                	sd	s2,32(sp)
    80003dfe:	ec4e                	sd	s3,24(sp)
    80003e00:	e852                	sd	s4,16(sp)
    80003e02:	0080                	addi	s0,sp,64
    80003e04:	892a                	mv	s2,a0
    80003e06:	8a2e                	mv	s4,a1
    80003e08:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e0a:	4601                	li	a2,0
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	dd8080e7          	jalr	-552(ra) # 80003be4 <dirlookup>
    80003e14:	e93d                	bnez	a0,80003e8a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e16:	04c92483          	lw	s1,76(s2)
    80003e1a:	c49d                	beqz	s1,80003e48 <dirlink+0x54>
    80003e1c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e1e:	4741                	li	a4,16
    80003e20:	86a6                	mv	a3,s1
    80003e22:	fc040613          	addi	a2,s0,-64
    80003e26:	4581                	li	a1,0
    80003e28:	854a                	mv	a0,s2
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	b8a080e7          	jalr	-1142(ra) # 800039b4 <readi>
    80003e32:	47c1                	li	a5,16
    80003e34:	06f51163          	bne	a0,a5,80003e96 <dirlink+0xa2>
    if(de.inum == 0)
    80003e38:	fc045783          	lhu	a5,-64(s0)
    80003e3c:	c791                	beqz	a5,80003e48 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e3e:	24c1                	addiw	s1,s1,16
    80003e40:	04c92783          	lw	a5,76(s2)
    80003e44:	fcf4ede3          	bltu	s1,a5,80003e1e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e48:	4639                	li	a2,14
    80003e4a:	85d2                	mv	a1,s4
    80003e4c:	fc240513          	addi	a0,s0,-62
    80003e50:	ffffd097          	auipc	ra,0xffffd
    80003e54:	f8e080e7          	jalr	-114(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003e58:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e5c:	4741                	li	a4,16
    80003e5e:	86a6                	mv	a3,s1
    80003e60:	fc040613          	addi	a2,s0,-64
    80003e64:	4581                	li	a1,0
    80003e66:	854a                	mv	a0,s2
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	c44080e7          	jalr	-956(ra) # 80003aac <writei>
    80003e70:	1541                	addi	a0,a0,-16
    80003e72:	00a03533          	snez	a0,a0
    80003e76:	40a00533          	neg	a0,a0
}
    80003e7a:	70e2                	ld	ra,56(sp)
    80003e7c:	7442                	ld	s0,48(sp)
    80003e7e:	74a2                	ld	s1,40(sp)
    80003e80:	7902                	ld	s2,32(sp)
    80003e82:	69e2                	ld	s3,24(sp)
    80003e84:	6a42                	ld	s4,16(sp)
    80003e86:	6121                	addi	sp,sp,64
    80003e88:	8082                	ret
    iput(ip);
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	a30080e7          	jalr	-1488(ra) # 800038ba <iput>
    return -1;
    80003e92:	557d                	li	a0,-1
    80003e94:	b7dd                	j	80003e7a <dirlink+0x86>
      panic("dirlink read");
    80003e96:	00004517          	auipc	a0,0x4
    80003e9a:	78250513          	addi	a0,a0,1922 # 80008618 <syscalls+0x1c8>
    80003e9e:	ffffc097          	auipc	ra,0xffffc
    80003ea2:	6a0080e7          	jalr	1696(ra) # 8000053e <panic>

0000000080003ea6 <namei>:

struct inode*
namei(char *path)
{
    80003ea6:	1101                	addi	sp,sp,-32
    80003ea8:	ec06                	sd	ra,24(sp)
    80003eaa:	e822                	sd	s0,16(sp)
    80003eac:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003eae:	fe040613          	addi	a2,s0,-32
    80003eb2:	4581                	li	a1,0
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	de0080e7          	jalr	-544(ra) # 80003c94 <namex>
}
    80003ebc:	60e2                	ld	ra,24(sp)
    80003ebe:	6442                	ld	s0,16(sp)
    80003ec0:	6105                	addi	sp,sp,32
    80003ec2:	8082                	ret

0000000080003ec4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ec4:	1141                	addi	sp,sp,-16
    80003ec6:	e406                	sd	ra,8(sp)
    80003ec8:	e022                	sd	s0,0(sp)
    80003eca:	0800                	addi	s0,sp,16
    80003ecc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ece:	4585                	li	a1,1
    80003ed0:	00000097          	auipc	ra,0x0
    80003ed4:	dc4080e7          	jalr	-572(ra) # 80003c94 <namex>
}
    80003ed8:	60a2                	ld	ra,8(sp)
    80003eda:	6402                	ld	s0,0(sp)
    80003edc:	0141                	addi	sp,sp,16
    80003ede:	8082                	ret

0000000080003ee0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ee0:	1101                	addi	sp,sp,-32
    80003ee2:	ec06                	sd	ra,24(sp)
    80003ee4:	e822                	sd	s0,16(sp)
    80003ee6:	e426                	sd	s1,8(sp)
    80003ee8:	e04a                	sd	s2,0(sp)
    80003eea:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003eec:	0001d917          	auipc	s2,0x1d
    80003ef0:	03490913          	addi	s2,s2,52 # 80020f20 <log>
    80003ef4:	01892583          	lw	a1,24(s2)
    80003ef8:	02892503          	lw	a0,40(s2)
    80003efc:	fffff097          	auipc	ra,0xfffff
    80003f00:	fea080e7          	jalr	-22(ra) # 80002ee6 <bread>
    80003f04:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f06:	02c92683          	lw	a3,44(s2)
    80003f0a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f0c:	02d05763          	blez	a3,80003f3a <write_head+0x5a>
    80003f10:	0001d797          	auipc	a5,0x1d
    80003f14:	04078793          	addi	a5,a5,64 # 80020f50 <log+0x30>
    80003f18:	05c50713          	addi	a4,a0,92
    80003f1c:	36fd                	addiw	a3,a3,-1
    80003f1e:	1682                	slli	a3,a3,0x20
    80003f20:	9281                	srli	a3,a3,0x20
    80003f22:	068a                	slli	a3,a3,0x2
    80003f24:	0001d617          	auipc	a2,0x1d
    80003f28:	03060613          	addi	a2,a2,48 # 80020f54 <log+0x34>
    80003f2c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f2e:	4390                	lw	a2,0(a5)
    80003f30:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f32:	0791                	addi	a5,a5,4
    80003f34:	0711                	addi	a4,a4,4
    80003f36:	fed79ce3          	bne	a5,a3,80003f2e <write_head+0x4e>
  }
  bwrite(buf);
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	fffff097          	auipc	ra,0xfffff
    80003f40:	09c080e7          	jalr	156(ra) # 80002fd8 <bwrite>
  brelse(buf);
    80003f44:	8526                	mv	a0,s1
    80003f46:	fffff097          	auipc	ra,0xfffff
    80003f4a:	0d0080e7          	jalr	208(ra) # 80003016 <brelse>
}
    80003f4e:	60e2                	ld	ra,24(sp)
    80003f50:	6442                	ld	s0,16(sp)
    80003f52:	64a2                	ld	s1,8(sp)
    80003f54:	6902                	ld	s2,0(sp)
    80003f56:	6105                	addi	sp,sp,32
    80003f58:	8082                	ret

0000000080003f5a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f5a:	0001d797          	auipc	a5,0x1d
    80003f5e:	ff27a783          	lw	a5,-14(a5) # 80020f4c <log+0x2c>
    80003f62:	0af05d63          	blez	a5,8000401c <install_trans+0xc2>
{
    80003f66:	7139                	addi	sp,sp,-64
    80003f68:	fc06                	sd	ra,56(sp)
    80003f6a:	f822                	sd	s0,48(sp)
    80003f6c:	f426                	sd	s1,40(sp)
    80003f6e:	f04a                	sd	s2,32(sp)
    80003f70:	ec4e                	sd	s3,24(sp)
    80003f72:	e852                	sd	s4,16(sp)
    80003f74:	e456                	sd	s5,8(sp)
    80003f76:	e05a                	sd	s6,0(sp)
    80003f78:	0080                	addi	s0,sp,64
    80003f7a:	8b2a                	mv	s6,a0
    80003f7c:	0001da97          	auipc	s5,0x1d
    80003f80:	fd4a8a93          	addi	s5,s5,-44 # 80020f50 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f84:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f86:	0001d997          	auipc	s3,0x1d
    80003f8a:	f9a98993          	addi	s3,s3,-102 # 80020f20 <log>
    80003f8e:	a00d                	j	80003fb0 <install_trans+0x56>
    brelse(lbuf);
    80003f90:	854a                	mv	a0,s2
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	084080e7          	jalr	132(ra) # 80003016 <brelse>
    brelse(dbuf);
    80003f9a:	8526                	mv	a0,s1
    80003f9c:	fffff097          	auipc	ra,0xfffff
    80003fa0:	07a080e7          	jalr	122(ra) # 80003016 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fa4:	2a05                	addiw	s4,s4,1
    80003fa6:	0a91                	addi	s5,s5,4
    80003fa8:	02c9a783          	lw	a5,44(s3)
    80003fac:	04fa5e63          	bge	s4,a5,80004008 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fb0:	0189a583          	lw	a1,24(s3)
    80003fb4:	014585bb          	addw	a1,a1,s4
    80003fb8:	2585                	addiw	a1,a1,1
    80003fba:	0289a503          	lw	a0,40(s3)
    80003fbe:	fffff097          	auipc	ra,0xfffff
    80003fc2:	f28080e7          	jalr	-216(ra) # 80002ee6 <bread>
    80003fc6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fc8:	000aa583          	lw	a1,0(s5)
    80003fcc:	0289a503          	lw	a0,40(s3)
    80003fd0:	fffff097          	auipc	ra,0xfffff
    80003fd4:	f16080e7          	jalr	-234(ra) # 80002ee6 <bread>
    80003fd8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fda:	40000613          	li	a2,1024
    80003fde:	05890593          	addi	a1,s2,88
    80003fe2:	05850513          	addi	a0,a0,88
    80003fe6:	ffffd097          	auipc	ra,0xffffd
    80003fea:	d48080e7          	jalr	-696(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fee:	8526                	mv	a0,s1
    80003ff0:	fffff097          	auipc	ra,0xfffff
    80003ff4:	fe8080e7          	jalr	-24(ra) # 80002fd8 <bwrite>
    if(recovering == 0)
    80003ff8:	f80b1ce3          	bnez	s6,80003f90 <install_trans+0x36>
      bunpin(dbuf);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	fffff097          	auipc	ra,0xfffff
    80004002:	0f2080e7          	jalr	242(ra) # 800030f0 <bunpin>
    80004006:	b769                	j	80003f90 <install_trans+0x36>
}
    80004008:	70e2                	ld	ra,56(sp)
    8000400a:	7442                	ld	s0,48(sp)
    8000400c:	74a2                	ld	s1,40(sp)
    8000400e:	7902                	ld	s2,32(sp)
    80004010:	69e2                	ld	s3,24(sp)
    80004012:	6a42                	ld	s4,16(sp)
    80004014:	6aa2                	ld	s5,8(sp)
    80004016:	6b02                	ld	s6,0(sp)
    80004018:	6121                	addi	sp,sp,64
    8000401a:	8082                	ret
    8000401c:	8082                	ret

000000008000401e <initlog>:
{
    8000401e:	7179                	addi	sp,sp,-48
    80004020:	f406                	sd	ra,40(sp)
    80004022:	f022                	sd	s0,32(sp)
    80004024:	ec26                	sd	s1,24(sp)
    80004026:	e84a                	sd	s2,16(sp)
    80004028:	e44e                	sd	s3,8(sp)
    8000402a:	1800                	addi	s0,sp,48
    8000402c:	892a                	mv	s2,a0
    8000402e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004030:	0001d497          	auipc	s1,0x1d
    80004034:	ef048493          	addi	s1,s1,-272 # 80020f20 <log>
    80004038:	00004597          	auipc	a1,0x4
    8000403c:	5f058593          	addi	a1,a1,1520 # 80008628 <syscalls+0x1d8>
    80004040:	8526                	mv	a0,s1
    80004042:	ffffd097          	auipc	ra,0xffffd
    80004046:	b04080e7          	jalr	-1276(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000404a:	0149a583          	lw	a1,20(s3)
    8000404e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004050:	0109a783          	lw	a5,16(s3)
    80004054:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004056:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000405a:	854a                	mv	a0,s2
    8000405c:	fffff097          	auipc	ra,0xfffff
    80004060:	e8a080e7          	jalr	-374(ra) # 80002ee6 <bread>
  log.lh.n = lh->n;
    80004064:	4d34                	lw	a3,88(a0)
    80004066:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004068:	02d05563          	blez	a3,80004092 <initlog+0x74>
    8000406c:	05c50793          	addi	a5,a0,92
    80004070:	0001d717          	auipc	a4,0x1d
    80004074:	ee070713          	addi	a4,a4,-288 # 80020f50 <log+0x30>
    80004078:	36fd                	addiw	a3,a3,-1
    8000407a:	1682                	slli	a3,a3,0x20
    8000407c:	9281                	srli	a3,a3,0x20
    8000407e:	068a                	slli	a3,a3,0x2
    80004080:	06050613          	addi	a2,a0,96
    80004084:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004086:	4390                	lw	a2,0(a5)
    80004088:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000408a:	0791                	addi	a5,a5,4
    8000408c:	0711                	addi	a4,a4,4
    8000408e:	fed79ce3          	bne	a5,a3,80004086 <initlog+0x68>
  brelse(buf);
    80004092:	fffff097          	auipc	ra,0xfffff
    80004096:	f84080e7          	jalr	-124(ra) # 80003016 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000409a:	4505                	li	a0,1
    8000409c:	00000097          	auipc	ra,0x0
    800040a0:	ebe080e7          	jalr	-322(ra) # 80003f5a <install_trans>
  log.lh.n = 0;
    800040a4:	0001d797          	auipc	a5,0x1d
    800040a8:	ea07a423          	sw	zero,-344(a5) # 80020f4c <log+0x2c>
  write_head(); // clear the log
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	e34080e7          	jalr	-460(ra) # 80003ee0 <write_head>
}
    800040b4:	70a2                	ld	ra,40(sp)
    800040b6:	7402                	ld	s0,32(sp)
    800040b8:	64e2                	ld	s1,24(sp)
    800040ba:	6942                	ld	s2,16(sp)
    800040bc:	69a2                	ld	s3,8(sp)
    800040be:	6145                	addi	sp,sp,48
    800040c0:	8082                	ret

00000000800040c2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040c2:	1101                	addi	sp,sp,-32
    800040c4:	ec06                	sd	ra,24(sp)
    800040c6:	e822                	sd	s0,16(sp)
    800040c8:	e426                	sd	s1,8(sp)
    800040ca:	e04a                	sd	s2,0(sp)
    800040cc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040ce:	0001d517          	auipc	a0,0x1d
    800040d2:	e5250513          	addi	a0,a0,-430 # 80020f20 <log>
    800040d6:	ffffd097          	auipc	ra,0xffffd
    800040da:	b00080e7          	jalr	-1280(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800040de:	0001d497          	auipc	s1,0x1d
    800040e2:	e4248493          	addi	s1,s1,-446 # 80020f20 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040e6:	4979                	li	s2,30
    800040e8:	a039                	j	800040f6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800040ea:	85a6                	mv	a1,s1
    800040ec:	8526                	mv	a0,s1
    800040ee:	ffffe097          	auipc	ra,0xffffe
    800040f2:	f4c080e7          	jalr	-180(ra) # 8000203a <sleep>
    if(log.committing){
    800040f6:	50dc                	lw	a5,36(s1)
    800040f8:	fbed                	bnez	a5,800040ea <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040fa:	509c                	lw	a5,32(s1)
    800040fc:	0017871b          	addiw	a4,a5,1
    80004100:	0007069b          	sext.w	a3,a4
    80004104:	0027179b          	slliw	a5,a4,0x2
    80004108:	9fb9                	addw	a5,a5,a4
    8000410a:	0017979b          	slliw	a5,a5,0x1
    8000410e:	54d8                	lw	a4,44(s1)
    80004110:	9fb9                	addw	a5,a5,a4
    80004112:	00f95963          	bge	s2,a5,80004124 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004116:	85a6                	mv	a1,s1
    80004118:	8526                	mv	a0,s1
    8000411a:	ffffe097          	auipc	ra,0xffffe
    8000411e:	f20080e7          	jalr	-224(ra) # 8000203a <sleep>
    80004122:	bfd1                	j	800040f6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004124:	0001d517          	auipc	a0,0x1d
    80004128:	dfc50513          	addi	a0,a0,-516 # 80020f20 <log>
    8000412c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000412e:	ffffd097          	auipc	ra,0xffffd
    80004132:	b5c080e7          	jalr	-1188(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004136:	60e2                	ld	ra,24(sp)
    80004138:	6442                	ld	s0,16(sp)
    8000413a:	64a2                	ld	s1,8(sp)
    8000413c:	6902                	ld	s2,0(sp)
    8000413e:	6105                	addi	sp,sp,32
    80004140:	8082                	ret

0000000080004142 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004142:	7139                	addi	sp,sp,-64
    80004144:	fc06                	sd	ra,56(sp)
    80004146:	f822                	sd	s0,48(sp)
    80004148:	f426                	sd	s1,40(sp)
    8000414a:	f04a                	sd	s2,32(sp)
    8000414c:	ec4e                	sd	s3,24(sp)
    8000414e:	e852                	sd	s4,16(sp)
    80004150:	e456                	sd	s5,8(sp)
    80004152:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004154:	0001d497          	auipc	s1,0x1d
    80004158:	dcc48493          	addi	s1,s1,-564 # 80020f20 <log>
    8000415c:	8526                	mv	a0,s1
    8000415e:	ffffd097          	auipc	ra,0xffffd
    80004162:	a78080e7          	jalr	-1416(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004166:	509c                	lw	a5,32(s1)
    80004168:	37fd                	addiw	a5,a5,-1
    8000416a:	0007891b          	sext.w	s2,a5
    8000416e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004170:	50dc                	lw	a5,36(s1)
    80004172:	e7b9                	bnez	a5,800041c0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004174:	04091e63          	bnez	s2,800041d0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004178:	0001d497          	auipc	s1,0x1d
    8000417c:	da848493          	addi	s1,s1,-600 # 80020f20 <log>
    80004180:	4785                	li	a5,1
    80004182:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004184:	8526                	mv	a0,s1
    80004186:	ffffd097          	auipc	ra,0xffffd
    8000418a:	b04080e7          	jalr	-1276(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000418e:	54dc                	lw	a5,44(s1)
    80004190:	06f04763          	bgtz	a5,800041fe <end_op+0xbc>
    acquire(&log.lock);
    80004194:	0001d497          	auipc	s1,0x1d
    80004198:	d8c48493          	addi	s1,s1,-628 # 80020f20 <log>
    8000419c:	8526                	mv	a0,s1
    8000419e:	ffffd097          	auipc	ra,0xffffd
    800041a2:	a38080e7          	jalr	-1480(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800041a6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041aa:	8526                	mv	a0,s1
    800041ac:	ffffe097          	auipc	ra,0xffffe
    800041b0:	ef2080e7          	jalr	-270(ra) # 8000209e <wakeup>
    release(&log.lock);
    800041b4:	8526                	mv	a0,s1
    800041b6:	ffffd097          	auipc	ra,0xffffd
    800041ba:	ad4080e7          	jalr	-1324(ra) # 80000c8a <release>
}
    800041be:	a03d                	j	800041ec <end_op+0xaa>
    panic("log.committing");
    800041c0:	00004517          	auipc	a0,0x4
    800041c4:	47050513          	addi	a0,a0,1136 # 80008630 <syscalls+0x1e0>
    800041c8:	ffffc097          	auipc	ra,0xffffc
    800041cc:	376080e7          	jalr	886(ra) # 8000053e <panic>
    wakeup(&log);
    800041d0:	0001d497          	auipc	s1,0x1d
    800041d4:	d5048493          	addi	s1,s1,-688 # 80020f20 <log>
    800041d8:	8526                	mv	a0,s1
    800041da:	ffffe097          	auipc	ra,0xffffe
    800041de:	ec4080e7          	jalr	-316(ra) # 8000209e <wakeup>
  release(&log.lock);
    800041e2:	8526                	mv	a0,s1
    800041e4:	ffffd097          	auipc	ra,0xffffd
    800041e8:	aa6080e7          	jalr	-1370(ra) # 80000c8a <release>
}
    800041ec:	70e2                	ld	ra,56(sp)
    800041ee:	7442                	ld	s0,48(sp)
    800041f0:	74a2                	ld	s1,40(sp)
    800041f2:	7902                	ld	s2,32(sp)
    800041f4:	69e2                	ld	s3,24(sp)
    800041f6:	6a42                	ld	s4,16(sp)
    800041f8:	6aa2                	ld	s5,8(sp)
    800041fa:	6121                	addi	sp,sp,64
    800041fc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041fe:	0001da97          	auipc	s5,0x1d
    80004202:	d52a8a93          	addi	s5,s5,-686 # 80020f50 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004206:	0001da17          	auipc	s4,0x1d
    8000420a:	d1aa0a13          	addi	s4,s4,-742 # 80020f20 <log>
    8000420e:	018a2583          	lw	a1,24(s4)
    80004212:	012585bb          	addw	a1,a1,s2
    80004216:	2585                	addiw	a1,a1,1
    80004218:	028a2503          	lw	a0,40(s4)
    8000421c:	fffff097          	auipc	ra,0xfffff
    80004220:	cca080e7          	jalr	-822(ra) # 80002ee6 <bread>
    80004224:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004226:	000aa583          	lw	a1,0(s5)
    8000422a:	028a2503          	lw	a0,40(s4)
    8000422e:	fffff097          	auipc	ra,0xfffff
    80004232:	cb8080e7          	jalr	-840(ra) # 80002ee6 <bread>
    80004236:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004238:	40000613          	li	a2,1024
    8000423c:	05850593          	addi	a1,a0,88
    80004240:	05848513          	addi	a0,s1,88
    80004244:	ffffd097          	auipc	ra,0xffffd
    80004248:	aea080e7          	jalr	-1302(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000424c:	8526                	mv	a0,s1
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	d8a080e7          	jalr	-630(ra) # 80002fd8 <bwrite>
    brelse(from);
    80004256:	854e                	mv	a0,s3
    80004258:	fffff097          	auipc	ra,0xfffff
    8000425c:	dbe080e7          	jalr	-578(ra) # 80003016 <brelse>
    brelse(to);
    80004260:	8526                	mv	a0,s1
    80004262:	fffff097          	auipc	ra,0xfffff
    80004266:	db4080e7          	jalr	-588(ra) # 80003016 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000426a:	2905                	addiw	s2,s2,1
    8000426c:	0a91                	addi	s5,s5,4
    8000426e:	02ca2783          	lw	a5,44(s4)
    80004272:	f8f94ee3          	blt	s2,a5,8000420e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004276:	00000097          	auipc	ra,0x0
    8000427a:	c6a080e7          	jalr	-918(ra) # 80003ee0 <write_head>
    install_trans(0); // Now install writes to home locations
    8000427e:	4501                	li	a0,0
    80004280:	00000097          	auipc	ra,0x0
    80004284:	cda080e7          	jalr	-806(ra) # 80003f5a <install_trans>
    log.lh.n = 0;
    80004288:	0001d797          	auipc	a5,0x1d
    8000428c:	cc07a223          	sw	zero,-828(a5) # 80020f4c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004290:	00000097          	auipc	ra,0x0
    80004294:	c50080e7          	jalr	-944(ra) # 80003ee0 <write_head>
    80004298:	bdf5                	j	80004194 <end_op+0x52>

000000008000429a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000429a:	1101                	addi	sp,sp,-32
    8000429c:	ec06                	sd	ra,24(sp)
    8000429e:	e822                	sd	s0,16(sp)
    800042a0:	e426                	sd	s1,8(sp)
    800042a2:	e04a                	sd	s2,0(sp)
    800042a4:	1000                	addi	s0,sp,32
    800042a6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800042a8:	0001d917          	auipc	s2,0x1d
    800042ac:	c7890913          	addi	s2,s2,-904 # 80020f20 <log>
    800042b0:	854a                	mv	a0,s2
    800042b2:	ffffd097          	auipc	ra,0xffffd
    800042b6:	924080e7          	jalr	-1756(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042ba:	02c92603          	lw	a2,44(s2)
    800042be:	47f5                	li	a5,29
    800042c0:	06c7c563          	blt	a5,a2,8000432a <log_write+0x90>
    800042c4:	0001d797          	auipc	a5,0x1d
    800042c8:	c787a783          	lw	a5,-904(a5) # 80020f3c <log+0x1c>
    800042cc:	37fd                	addiw	a5,a5,-1
    800042ce:	04f65e63          	bge	a2,a5,8000432a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042d2:	0001d797          	auipc	a5,0x1d
    800042d6:	c6e7a783          	lw	a5,-914(a5) # 80020f40 <log+0x20>
    800042da:	06f05063          	blez	a5,8000433a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042de:	4781                	li	a5,0
    800042e0:	06c05563          	blez	a2,8000434a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042e4:	44cc                	lw	a1,12(s1)
    800042e6:	0001d717          	auipc	a4,0x1d
    800042ea:	c6a70713          	addi	a4,a4,-918 # 80020f50 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042ee:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042f0:	4314                	lw	a3,0(a4)
    800042f2:	04b68c63          	beq	a3,a1,8000434a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042f6:	2785                	addiw	a5,a5,1
    800042f8:	0711                	addi	a4,a4,4
    800042fa:	fef61be3          	bne	a2,a5,800042f0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042fe:	0621                	addi	a2,a2,8
    80004300:	060a                	slli	a2,a2,0x2
    80004302:	0001d797          	auipc	a5,0x1d
    80004306:	c1e78793          	addi	a5,a5,-994 # 80020f20 <log>
    8000430a:	963e                	add	a2,a2,a5
    8000430c:	44dc                	lw	a5,12(s1)
    8000430e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004310:	8526                	mv	a0,s1
    80004312:	fffff097          	auipc	ra,0xfffff
    80004316:	da2080e7          	jalr	-606(ra) # 800030b4 <bpin>
    log.lh.n++;
    8000431a:	0001d717          	auipc	a4,0x1d
    8000431e:	c0670713          	addi	a4,a4,-1018 # 80020f20 <log>
    80004322:	575c                	lw	a5,44(a4)
    80004324:	2785                	addiw	a5,a5,1
    80004326:	d75c                	sw	a5,44(a4)
    80004328:	a835                	j	80004364 <log_write+0xca>
    panic("too big a transaction");
    8000432a:	00004517          	auipc	a0,0x4
    8000432e:	31650513          	addi	a0,a0,790 # 80008640 <syscalls+0x1f0>
    80004332:	ffffc097          	auipc	ra,0xffffc
    80004336:	20c080e7          	jalr	524(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000433a:	00004517          	auipc	a0,0x4
    8000433e:	31e50513          	addi	a0,a0,798 # 80008658 <syscalls+0x208>
    80004342:	ffffc097          	auipc	ra,0xffffc
    80004346:	1fc080e7          	jalr	508(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000434a:	00878713          	addi	a4,a5,8
    8000434e:	00271693          	slli	a3,a4,0x2
    80004352:	0001d717          	auipc	a4,0x1d
    80004356:	bce70713          	addi	a4,a4,-1074 # 80020f20 <log>
    8000435a:	9736                	add	a4,a4,a3
    8000435c:	44d4                	lw	a3,12(s1)
    8000435e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004360:	faf608e3          	beq	a2,a5,80004310 <log_write+0x76>
  }
  release(&log.lock);
    80004364:	0001d517          	auipc	a0,0x1d
    80004368:	bbc50513          	addi	a0,a0,-1092 # 80020f20 <log>
    8000436c:	ffffd097          	auipc	ra,0xffffd
    80004370:	91e080e7          	jalr	-1762(ra) # 80000c8a <release>
}
    80004374:	60e2                	ld	ra,24(sp)
    80004376:	6442                	ld	s0,16(sp)
    80004378:	64a2                	ld	s1,8(sp)
    8000437a:	6902                	ld	s2,0(sp)
    8000437c:	6105                	addi	sp,sp,32
    8000437e:	8082                	ret

0000000080004380 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004380:	1101                	addi	sp,sp,-32
    80004382:	ec06                	sd	ra,24(sp)
    80004384:	e822                	sd	s0,16(sp)
    80004386:	e426                	sd	s1,8(sp)
    80004388:	e04a                	sd	s2,0(sp)
    8000438a:	1000                	addi	s0,sp,32
    8000438c:	84aa                	mv	s1,a0
    8000438e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004390:	00004597          	auipc	a1,0x4
    80004394:	2e858593          	addi	a1,a1,744 # 80008678 <syscalls+0x228>
    80004398:	0521                	addi	a0,a0,8
    8000439a:	ffffc097          	auipc	ra,0xffffc
    8000439e:	7ac080e7          	jalr	1964(ra) # 80000b46 <initlock>
  lk->name = name;
    800043a2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043a6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043aa:	0204a423          	sw	zero,40(s1)
}
    800043ae:	60e2                	ld	ra,24(sp)
    800043b0:	6442                	ld	s0,16(sp)
    800043b2:	64a2                	ld	s1,8(sp)
    800043b4:	6902                	ld	s2,0(sp)
    800043b6:	6105                	addi	sp,sp,32
    800043b8:	8082                	ret

00000000800043ba <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043ba:	1101                	addi	sp,sp,-32
    800043bc:	ec06                	sd	ra,24(sp)
    800043be:	e822                	sd	s0,16(sp)
    800043c0:	e426                	sd	s1,8(sp)
    800043c2:	e04a                	sd	s2,0(sp)
    800043c4:	1000                	addi	s0,sp,32
    800043c6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043c8:	00850913          	addi	s2,a0,8
    800043cc:	854a                	mv	a0,s2
    800043ce:	ffffd097          	auipc	ra,0xffffd
    800043d2:	808080e7          	jalr	-2040(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800043d6:	409c                	lw	a5,0(s1)
    800043d8:	cb89                	beqz	a5,800043ea <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043da:	85ca                	mv	a1,s2
    800043dc:	8526                	mv	a0,s1
    800043de:	ffffe097          	auipc	ra,0xffffe
    800043e2:	c5c080e7          	jalr	-932(ra) # 8000203a <sleep>
  while (lk->locked) {
    800043e6:	409c                	lw	a5,0(s1)
    800043e8:	fbed                	bnez	a5,800043da <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043ea:	4785                	li	a5,1
    800043ec:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043ee:	ffffd097          	auipc	ra,0xffffd
    800043f2:	592080e7          	jalr	1426(ra) # 80001980 <myproc>
    800043f6:	591c                	lw	a5,48(a0)
    800043f8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043fa:	854a                	mv	a0,s2
    800043fc:	ffffd097          	auipc	ra,0xffffd
    80004400:	88e080e7          	jalr	-1906(ra) # 80000c8a <release>
}
    80004404:	60e2                	ld	ra,24(sp)
    80004406:	6442                	ld	s0,16(sp)
    80004408:	64a2                	ld	s1,8(sp)
    8000440a:	6902                	ld	s2,0(sp)
    8000440c:	6105                	addi	sp,sp,32
    8000440e:	8082                	ret

0000000080004410 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004410:	1101                	addi	sp,sp,-32
    80004412:	ec06                	sd	ra,24(sp)
    80004414:	e822                	sd	s0,16(sp)
    80004416:	e426                	sd	s1,8(sp)
    80004418:	e04a                	sd	s2,0(sp)
    8000441a:	1000                	addi	s0,sp,32
    8000441c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000441e:	00850913          	addi	s2,a0,8
    80004422:	854a                	mv	a0,s2
    80004424:	ffffc097          	auipc	ra,0xffffc
    80004428:	7b2080e7          	jalr	1970(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000442c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004430:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004434:	8526                	mv	a0,s1
    80004436:	ffffe097          	auipc	ra,0xffffe
    8000443a:	c68080e7          	jalr	-920(ra) # 8000209e <wakeup>
  release(&lk->lk);
    8000443e:	854a                	mv	a0,s2
    80004440:	ffffd097          	auipc	ra,0xffffd
    80004444:	84a080e7          	jalr	-1974(ra) # 80000c8a <release>
}
    80004448:	60e2                	ld	ra,24(sp)
    8000444a:	6442                	ld	s0,16(sp)
    8000444c:	64a2                	ld	s1,8(sp)
    8000444e:	6902                	ld	s2,0(sp)
    80004450:	6105                	addi	sp,sp,32
    80004452:	8082                	ret

0000000080004454 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004454:	7179                	addi	sp,sp,-48
    80004456:	f406                	sd	ra,40(sp)
    80004458:	f022                	sd	s0,32(sp)
    8000445a:	ec26                	sd	s1,24(sp)
    8000445c:	e84a                	sd	s2,16(sp)
    8000445e:	e44e                	sd	s3,8(sp)
    80004460:	1800                	addi	s0,sp,48
    80004462:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004464:	00850913          	addi	s2,a0,8
    80004468:	854a                	mv	a0,s2
    8000446a:	ffffc097          	auipc	ra,0xffffc
    8000446e:	76c080e7          	jalr	1900(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004472:	409c                	lw	a5,0(s1)
    80004474:	ef99                	bnez	a5,80004492 <holdingsleep+0x3e>
    80004476:	4481                	li	s1,0
  release(&lk->lk);
    80004478:	854a                	mv	a0,s2
    8000447a:	ffffd097          	auipc	ra,0xffffd
    8000447e:	810080e7          	jalr	-2032(ra) # 80000c8a <release>
  return r;
}
    80004482:	8526                	mv	a0,s1
    80004484:	70a2                	ld	ra,40(sp)
    80004486:	7402                	ld	s0,32(sp)
    80004488:	64e2                	ld	s1,24(sp)
    8000448a:	6942                	ld	s2,16(sp)
    8000448c:	69a2                	ld	s3,8(sp)
    8000448e:	6145                	addi	sp,sp,48
    80004490:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004492:	0284a983          	lw	s3,40(s1)
    80004496:	ffffd097          	auipc	ra,0xffffd
    8000449a:	4ea080e7          	jalr	1258(ra) # 80001980 <myproc>
    8000449e:	5904                	lw	s1,48(a0)
    800044a0:	413484b3          	sub	s1,s1,s3
    800044a4:	0014b493          	seqz	s1,s1
    800044a8:	bfc1                	j	80004478 <holdingsleep+0x24>

00000000800044aa <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044aa:	1141                	addi	sp,sp,-16
    800044ac:	e406                	sd	ra,8(sp)
    800044ae:	e022                	sd	s0,0(sp)
    800044b0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044b2:	00004597          	auipc	a1,0x4
    800044b6:	1d658593          	addi	a1,a1,470 # 80008688 <syscalls+0x238>
    800044ba:	0001d517          	auipc	a0,0x1d
    800044be:	bae50513          	addi	a0,a0,-1106 # 80021068 <ftable>
    800044c2:	ffffc097          	auipc	ra,0xffffc
    800044c6:	684080e7          	jalr	1668(ra) # 80000b46 <initlock>
}
    800044ca:	60a2                	ld	ra,8(sp)
    800044cc:	6402                	ld	s0,0(sp)
    800044ce:	0141                	addi	sp,sp,16
    800044d0:	8082                	ret

00000000800044d2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044d2:	1101                	addi	sp,sp,-32
    800044d4:	ec06                	sd	ra,24(sp)
    800044d6:	e822                	sd	s0,16(sp)
    800044d8:	e426                	sd	s1,8(sp)
    800044da:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044dc:	0001d517          	auipc	a0,0x1d
    800044e0:	b8c50513          	addi	a0,a0,-1140 # 80021068 <ftable>
    800044e4:	ffffc097          	auipc	ra,0xffffc
    800044e8:	6f2080e7          	jalr	1778(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044ec:	0001d497          	auipc	s1,0x1d
    800044f0:	b9448493          	addi	s1,s1,-1132 # 80021080 <ftable+0x18>
    800044f4:	0001e717          	auipc	a4,0x1e
    800044f8:	b2c70713          	addi	a4,a4,-1236 # 80022020 <disk>
    if(f->ref == 0){
    800044fc:	40dc                	lw	a5,4(s1)
    800044fe:	cf99                	beqz	a5,8000451c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004500:	02848493          	addi	s1,s1,40
    80004504:	fee49ce3          	bne	s1,a4,800044fc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004508:	0001d517          	auipc	a0,0x1d
    8000450c:	b6050513          	addi	a0,a0,-1184 # 80021068 <ftable>
    80004510:	ffffc097          	auipc	ra,0xffffc
    80004514:	77a080e7          	jalr	1914(ra) # 80000c8a <release>
  return 0;
    80004518:	4481                	li	s1,0
    8000451a:	a819                	j	80004530 <filealloc+0x5e>
      f->ref = 1;
    8000451c:	4785                	li	a5,1
    8000451e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004520:	0001d517          	auipc	a0,0x1d
    80004524:	b4850513          	addi	a0,a0,-1208 # 80021068 <ftable>
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	762080e7          	jalr	1890(ra) # 80000c8a <release>
}
    80004530:	8526                	mv	a0,s1
    80004532:	60e2                	ld	ra,24(sp)
    80004534:	6442                	ld	s0,16(sp)
    80004536:	64a2                	ld	s1,8(sp)
    80004538:	6105                	addi	sp,sp,32
    8000453a:	8082                	ret

000000008000453c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000453c:	1101                	addi	sp,sp,-32
    8000453e:	ec06                	sd	ra,24(sp)
    80004540:	e822                	sd	s0,16(sp)
    80004542:	e426                	sd	s1,8(sp)
    80004544:	1000                	addi	s0,sp,32
    80004546:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004548:	0001d517          	auipc	a0,0x1d
    8000454c:	b2050513          	addi	a0,a0,-1248 # 80021068 <ftable>
    80004550:	ffffc097          	auipc	ra,0xffffc
    80004554:	686080e7          	jalr	1670(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004558:	40dc                	lw	a5,4(s1)
    8000455a:	02f05263          	blez	a5,8000457e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000455e:	2785                	addiw	a5,a5,1
    80004560:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004562:	0001d517          	auipc	a0,0x1d
    80004566:	b0650513          	addi	a0,a0,-1274 # 80021068 <ftable>
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	720080e7          	jalr	1824(ra) # 80000c8a <release>
  return f;
}
    80004572:	8526                	mv	a0,s1
    80004574:	60e2                	ld	ra,24(sp)
    80004576:	6442                	ld	s0,16(sp)
    80004578:	64a2                	ld	s1,8(sp)
    8000457a:	6105                	addi	sp,sp,32
    8000457c:	8082                	ret
    panic("filedup");
    8000457e:	00004517          	auipc	a0,0x4
    80004582:	11250513          	addi	a0,a0,274 # 80008690 <syscalls+0x240>
    80004586:	ffffc097          	auipc	ra,0xffffc
    8000458a:	fb8080e7          	jalr	-72(ra) # 8000053e <panic>

000000008000458e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000458e:	7139                	addi	sp,sp,-64
    80004590:	fc06                	sd	ra,56(sp)
    80004592:	f822                	sd	s0,48(sp)
    80004594:	f426                	sd	s1,40(sp)
    80004596:	f04a                	sd	s2,32(sp)
    80004598:	ec4e                	sd	s3,24(sp)
    8000459a:	e852                	sd	s4,16(sp)
    8000459c:	e456                	sd	s5,8(sp)
    8000459e:	0080                	addi	s0,sp,64
    800045a0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045a2:	0001d517          	auipc	a0,0x1d
    800045a6:	ac650513          	addi	a0,a0,-1338 # 80021068 <ftable>
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	62c080e7          	jalr	1580(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800045b2:	40dc                	lw	a5,4(s1)
    800045b4:	06f05163          	blez	a5,80004616 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045b8:	37fd                	addiw	a5,a5,-1
    800045ba:	0007871b          	sext.w	a4,a5
    800045be:	c0dc                	sw	a5,4(s1)
    800045c0:	06e04363          	bgtz	a4,80004626 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045c4:	0004a903          	lw	s2,0(s1)
    800045c8:	0094ca83          	lbu	s5,9(s1)
    800045cc:	0104ba03          	ld	s4,16(s1)
    800045d0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045d4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045d8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045dc:	0001d517          	auipc	a0,0x1d
    800045e0:	a8c50513          	addi	a0,a0,-1396 # 80021068 <ftable>
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	6a6080e7          	jalr	1702(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800045ec:	4785                	li	a5,1
    800045ee:	04f90d63          	beq	s2,a5,80004648 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045f2:	3979                	addiw	s2,s2,-2
    800045f4:	4785                	li	a5,1
    800045f6:	0527e063          	bltu	a5,s2,80004636 <fileclose+0xa8>
    begin_op();
    800045fa:	00000097          	auipc	ra,0x0
    800045fe:	ac8080e7          	jalr	-1336(ra) # 800040c2 <begin_op>
    iput(ff.ip);
    80004602:	854e                	mv	a0,s3
    80004604:	fffff097          	auipc	ra,0xfffff
    80004608:	2b6080e7          	jalr	694(ra) # 800038ba <iput>
    end_op();
    8000460c:	00000097          	auipc	ra,0x0
    80004610:	b36080e7          	jalr	-1226(ra) # 80004142 <end_op>
    80004614:	a00d                	j	80004636 <fileclose+0xa8>
    panic("fileclose");
    80004616:	00004517          	auipc	a0,0x4
    8000461a:	08250513          	addi	a0,a0,130 # 80008698 <syscalls+0x248>
    8000461e:	ffffc097          	auipc	ra,0xffffc
    80004622:	f20080e7          	jalr	-224(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004626:	0001d517          	auipc	a0,0x1d
    8000462a:	a4250513          	addi	a0,a0,-1470 # 80021068 <ftable>
    8000462e:	ffffc097          	auipc	ra,0xffffc
    80004632:	65c080e7          	jalr	1628(ra) # 80000c8a <release>
  }
}
    80004636:	70e2                	ld	ra,56(sp)
    80004638:	7442                	ld	s0,48(sp)
    8000463a:	74a2                	ld	s1,40(sp)
    8000463c:	7902                	ld	s2,32(sp)
    8000463e:	69e2                	ld	s3,24(sp)
    80004640:	6a42                	ld	s4,16(sp)
    80004642:	6aa2                	ld	s5,8(sp)
    80004644:	6121                	addi	sp,sp,64
    80004646:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004648:	85d6                	mv	a1,s5
    8000464a:	8552                	mv	a0,s4
    8000464c:	00000097          	auipc	ra,0x0
    80004650:	34c080e7          	jalr	844(ra) # 80004998 <pipeclose>
    80004654:	b7cd                	j	80004636 <fileclose+0xa8>

0000000080004656 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004656:	715d                	addi	sp,sp,-80
    80004658:	e486                	sd	ra,72(sp)
    8000465a:	e0a2                	sd	s0,64(sp)
    8000465c:	fc26                	sd	s1,56(sp)
    8000465e:	f84a                	sd	s2,48(sp)
    80004660:	f44e                	sd	s3,40(sp)
    80004662:	0880                	addi	s0,sp,80
    80004664:	84aa                	mv	s1,a0
    80004666:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004668:	ffffd097          	auipc	ra,0xffffd
    8000466c:	318080e7          	jalr	792(ra) # 80001980 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004670:	409c                	lw	a5,0(s1)
    80004672:	37f9                	addiw	a5,a5,-2
    80004674:	4705                	li	a4,1
    80004676:	04f76763          	bltu	a4,a5,800046c4 <filestat+0x6e>
    8000467a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000467c:	6c88                	ld	a0,24(s1)
    8000467e:	fffff097          	auipc	ra,0xfffff
    80004682:	082080e7          	jalr	130(ra) # 80003700 <ilock>
    stati(f->ip, &st);
    80004686:	fb840593          	addi	a1,s0,-72
    8000468a:	6c88                	ld	a0,24(s1)
    8000468c:	fffff097          	auipc	ra,0xfffff
    80004690:	2fe080e7          	jalr	766(ra) # 8000398a <stati>
    iunlock(f->ip);
    80004694:	6c88                	ld	a0,24(s1)
    80004696:	fffff097          	auipc	ra,0xfffff
    8000469a:	12c080e7          	jalr	300(ra) # 800037c2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000469e:	46e1                	li	a3,24
    800046a0:	fb840613          	addi	a2,s0,-72
    800046a4:	85ce                	mv	a1,s3
    800046a6:	06893503          	ld	a0,104(s2)
    800046aa:	ffffd097          	auipc	ra,0xffffd
    800046ae:	fbe080e7          	jalr	-66(ra) # 80001668 <copyout>
    800046b2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046b6:	60a6                	ld	ra,72(sp)
    800046b8:	6406                	ld	s0,64(sp)
    800046ba:	74e2                	ld	s1,56(sp)
    800046bc:	7942                	ld	s2,48(sp)
    800046be:	79a2                	ld	s3,40(sp)
    800046c0:	6161                	addi	sp,sp,80
    800046c2:	8082                	ret
  return -1;
    800046c4:	557d                	li	a0,-1
    800046c6:	bfc5                	j	800046b6 <filestat+0x60>

00000000800046c8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046c8:	7179                	addi	sp,sp,-48
    800046ca:	f406                	sd	ra,40(sp)
    800046cc:	f022                	sd	s0,32(sp)
    800046ce:	ec26                	sd	s1,24(sp)
    800046d0:	e84a                	sd	s2,16(sp)
    800046d2:	e44e                	sd	s3,8(sp)
    800046d4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046d6:	00854783          	lbu	a5,8(a0)
    800046da:	c3d5                	beqz	a5,8000477e <fileread+0xb6>
    800046dc:	84aa                	mv	s1,a0
    800046de:	89ae                	mv	s3,a1
    800046e0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046e2:	411c                	lw	a5,0(a0)
    800046e4:	4705                	li	a4,1
    800046e6:	04e78963          	beq	a5,a4,80004738 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046ea:	470d                	li	a4,3
    800046ec:	04e78d63          	beq	a5,a4,80004746 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046f0:	4709                	li	a4,2
    800046f2:	06e79e63          	bne	a5,a4,8000476e <fileread+0xa6>
    ilock(f->ip);
    800046f6:	6d08                	ld	a0,24(a0)
    800046f8:	fffff097          	auipc	ra,0xfffff
    800046fc:	008080e7          	jalr	8(ra) # 80003700 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004700:	874a                	mv	a4,s2
    80004702:	5094                	lw	a3,32(s1)
    80004704:	864e                	mv	a2,s3
    80004706:	4585                	li	a1,1
    80004708:	6c88                	ld	a0,24(s1)
    8000470a:	fffff097          	auipc	ra,0xfffff
    8000470e:	2aa080e7          	jalr	682(ra) # 800039b4 <readi>
    80004712:	892a                	mv	s2,a0
    80004714:	00a05563          	blez	a0,8000471e <fileread+0x56>
      f->off += r;
    80004718:	509c                	lw	a5,32(s1)
    8000471a:	9fa9                	addw	a5,a5,a0
    8000471c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000471e:	6c88                	ld	a0,24(s1)
    80004720:	fffff097          	auipc	ra,0xfffff
    80004724:	0a2080e7          	jalr	162(ra) # 800037c2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004728:	854a                	mv	a0,s2
    8000472a:	70a2                	ld	ra,40(sp)
    8000472c:	7402                	ld	s0,32(sp)
    8000472e:	64e2                	ld	s1,24(sp)
    80004730:	6942                	ld	s2,16(sp)
    80004732:	69a2                	ld	s3,8(sp)
    80004734:	6145                	addi	sp,sp,48
    80004736:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004738:	6908                	ld	a0,16(a0)
    8000473a:	00000097          	auipc	ra,0x0
    8000473e:	3c6080e7          	jalr	966(ra) # 80004b00 <piperead>
    80004742:	892a                	mv	s2,a0
    80004744:	b7d5                	j	80004728 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004746:	02451783          	lh	a5,36(a0)
    8000474a:	03079693          	slli	a3,a5,0x30
    8000474e:	92c1                	srli	a3,a3,0x30
    80004750:	4725                	li	a4,9
    80004752:	02d76863          	bltu	a4,a3,80004782 <fileread+0xba>
    80004756:	0792                	slli	a5,a5,0x4
    80004758:	0001d717          	auipc	a4,0x1d
    8000475c:	87070713          	addi	a4,a4,-1936 # 80020fc8 <devsw>
    80004760:	97ba                	add	a5,a5,a4
    80004762:	639c                	ld	a5,0(a5)
    80004764:	c38d                	beqz	a5,80004786 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004766:	4505                	li	a0,1
    80004768:	9782                	jalr	a5
    8000476a:	892a                	mv	s2,a0
    8000476c:	bf75                	j	80004728 <fileread+0x60>
    panic("fileread");
    8000476e:	00004517          	auipc	a0,0x4
    80004772:	f3a50513          	addi	a0,a0,-198 # 800086a8 <syscalls+0x258>
    80004776:	ffffc097          	auipc	ra,0xffffc
    8000477a:	dc8080e7          	jalr	-568(ra) # 8000053e <panic>
    return -1;
    8000477e:	597d                	li	s2,-1
    80004780:	b765                	j	80004728 <fileread+0x60>
      return -1;
    80004782:	597d                	li	s2,-1
    80004784:	b755                	j	80004728 <fileread+0x60>
    80004786:	597d                	li	s2,-1
    80004788:	b745                	j	80004728 <fileread+0x60>

000000008000478a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000478a:	715d                	addi	sp,sp,-80
    8000478c:	e486                	sd	ra,72(sp)
    8000478e:	e0a2                	sd	s0,64(sp)
    80004790:	fc26                	sd	s1,56(sp)
    80004792:	f84a                	sd	s2,48(sp)
    80004794:	f44e                	sd	s3,40(sp)
    80004796:	f052                	sd	s4,32(sp)
    80004798:	ec56                	sd	s5,24(sp)
    8000479a:	e85a                	sd	s6,16(sp)
    8000479c:	e45e                	sd	s7,8(sp)
    8000479e:	e062                	sd	s8,0(sp)
    800047a0:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800047a2:	00954783          	lbu	a5,9(a0)
    800047a6:	10078663          	beqz	a5,800048b2 <filewrite+0x128>
    800047aa:	892a                	mv	s2,a0
    800047ac:	8aae                	mv	s5,a1
    800047ae:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047b0:	411c                	lw	a5,0(a0)
    800047b2:	4705                	li	a4,1
    800047b4:	02e78263          	beq	a5,a4,800047d8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047b8:	470d                	li	a4,3
    800047ba:	02e78663          	beq	a5,a4,800047e6 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047be:	4709                	li	a4,2
    800047c0:	0ee79163          	bne	a5,a4,800048a2 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047c4:	0ac05d63          	blez	a2,8000487e <filewrite+0xf4>
    int i = 0;
    800047c8:	4981                	li	s3,0
    800047ca:	6b05                	lui	s6,0x1
    800047cc:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800047d0:	6b85                	lui	s7,0x1
    800047d2:	c00b8b9b          	addiw	s7,s7,-1024
    800047d6:	a861                	j	8000486e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800047d8:	6908                	ld	a0,16(a0)
    800047da:	00000097          	auipc	ra,0x0
    800047de:	22e080e7          	jalr	558(ra) # 80004a08 <pipewrite>
    800047e2:	8a2a                	mv	s4,a0
    800047e4:	a045                	j	80004884 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047e6:	02451783          	lh	a5,36(a0)
    800047ea:	03079693          	slli	a3,a5,0x30
    800047ee:	92c1                	srli	a3,a3,0x30
    800047f0:	4725                	li	a4,9
    800047f2:	0cd76263          	bltu	a4,a3,800048b6 <filewrite+0x12c>
    800047f6:	0792                	slli	a5,a5,0x4
    800047f8:	0001c717          	auipc	a4,0x1c
    800047fc:	7d070713          	addi	a4,a4,2000 # 80020fc8 <devsw>
    80004800:	97ba                	add	a5,a5,a4
    80004802:	679c                	ld	a5,8(a5)
    80004804:	cbdd                	beqz	a5,800048ba <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004806:	4505                	li	a0,1
    80004808:	9782                	jalr	a5
    8000480a:	8a2a                	mv	s4,a0
    8000480c:	a8a5                	j	80004884 <filewrite+0xfa>
    8000480e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004812:	00000097          	auipc	ra,0x0
    80004816:	8b0080e7          	jalr	-1872(ra) # 800040c2 <begin_op>
      ilock(f->ip);
    8000481a:	01893503          	ld	a0,24(s2)
    8000481e:	fffff097          	auipc	ra,0xfffff
    80004822:	ee2080e7          	jalr	-286(ra) # 80003700 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004826:	8762                	mv	a4,s8
    80004828:	02092683          	lw	a3,32(s2)
    8000482c:	01598633          	add	a2,s3,s5
    80004830:	4585                	li	a1,1
    80004832:	01893503          	ld	a0,24(s2)
    80004836:	fffff097          	auipc	ra,0xfffff
    8000483a:	276080e7          	jalr	630(ra) # 80003aac <writei>
    8000483e:	84aa                	mv	s1,a0
    80004840:	00a05763          	blez	a0,8000484e <filewrite+0xc4>
        f->off += r;
    80004844:	02092783          	lw	a5,32(s2)
    80004848:	9fa9                	addw	a5,a5,a0
    8000484a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000484e:	01893503          	ld	a0,24(s2)
    80004852:	fffff097          	auipc	ra,0xfffff
    80004856:	f70080e7          	jalr	-144(ra) # 800037c2 <iunlock>
      end_op();
    8000485a:	00000097          	auipc	ra,0x0
    8000485e:	8e8080e7          	jalr	-1816(ra) # 80004142 <end_op>

      if(r != n1){
    80004862:	009c1f63          	bne	s8,s1,80004880 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004866:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000486a:	0149db63          	bge	s3,s4,80004880 <filewrite+0xf6>
      int n1 = n - i;
    8000486e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004872:	84be                	mv	s1,a5
    80004874:	2781                	sext.w	a5,a5
    80004876:	f8fb5ce3          	bge	s6,a5,8000480e <filewrite+0x84>
    8000487a:	84de                	mv	s1,s7
    8000487c:	bf49                	j	8000480e <filewrite+0x84>
    int i = 0;
    8000487e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004880:	013a1f63          	bne	s4,s3,8000489e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004884:	8552                	mv	a0,s4
    80004886:	60a6                	ld	ra,72(sp)
    80004888:	6406                	ld	s0,64(sp)
    8000488a:	74e2                	ld	s1,56(sp)
    8000488c:	7942                	ld	s2,48(sp)
    8000488e:	79a2                	ld	s3,40(sp)
    80004890:	7a02                	ld	s4,32(sp)
    80004892:	6ae2                	ld	s5,24(sp)
    80004894:	6b42                	ld	s6,16(sp)
    80004896:	6ba2                	ld	s7,8(sp)
    80004898:	6c02                	ld	s8,0(sp)
    8000489a:	6161                	addi	sp,sp,80
    8000489c:	8082                	ret
    ret = (i == n ? n : -1);
    8000489e:	5a7d                	li	s4,-1
    800048a0:	b7d5                	j	80004884 <filewrite+0xfa>
    panic("filewrite");
    800048a2:	00004517          	auipc	a0,0x4
    800048a6:	e1650513          	addi	a0,a0,-490 # 800086b8 <syscalls+0x268>
    800048aa:	ffffc097          	auipc	ra,0xffffc
    800048ae:	c94080e7          	jalr	-876(ra) # 8000053e <panic>
    return -1;
    800048b2:	5a7d                	li	s4,-1
    800048b4:	bfc1                	j	80004884 <filewrite+0xfa>
      return -1;
    800048b6:	5a7d                	li	s4,-1
    800048b8:	b7f1                	j	80004884 <filewrite+0xfa>
    800048ba:	5a7d                	li	s4,-1
    800048bc:	b7e1                	j	80004884 <filewrite+0xfa>

00000000800048be <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048be:	7179                	addi	sp,sp,-48
    800048c0:	f406                	sd	ra,40(sp)
    800048c2:	f022                	sd	s0,32(sp)
    800048c4:	ec26                	sd	s1,24(sp)
    800048c6:	e84a                	sd	s2,16(sp)
    800048c8:	e44e                	sd	s3,8(sp)
    800048ca:	e052                	sd	s4,0(sp)
    800048cc:	1800                	addi	s0,sp,48
    800048ce:	84aa                	mv	s1,a0
    800048d0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048d2:	0005b023          	sd	zero,0(a1)
    800048d6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048da:	00000097          	auipc	ra,0x0
    800048de:	bf8080e7          	jalr	-1032(ra) # 800044d2 <filealloc>
    800048e2:	e088                	sd	a0,0(s1)
    800048e4:	c551                	beqz	a0,80004970 <pipealloc+0xb2>
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	bec080e7          	jalr	-1044(ra) # 800044d2 <filealloc>
    800048ee:	00aa3023          	sd	a0,0(s4)
    800048f2:	c92d                	beqz	a0,80004964 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	1f2080e7          	jalr	498(ra) # 80000ae6 <kalloc>
    800048fc:	892a                	mv	s2,a0
    800048fe:	c125                	beqz	a0,8000495e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004900:	4985                	li	s3,1
    80004902:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004906:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000490a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000490e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004912:	00004597          	auipc	a1,0x4
    80004916:	db658593          	addi	a1,a1,-586 # 800086c8 <syscalls+0x278>
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	22c080e7          	jalr	556(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004922:	609c                	ld	a5,0(s1)
    80004924:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004928:	609c                	ld	a5,0(s1)
    8000492a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000492e:	609c                	ld	a5,0(s1)
    80004930:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004934:	609c                	ld	a5,0(s1)
    80004936:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000493a:	000a3783          	ld	a5,0(s4)
    8000493e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004942:	000a3783          	ld	a5,0(s4)
    80004946:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000494a:	000a3783          	ld	a5,0(s4)
    8000494e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004952:	000a3783          	ld	a5,0(s4)
    80004956:	0127b823          	sd	s2,16(a5)
  return 0;
    8000495a:	4501                	li	a0,0
    8000495c:	a025                	j	80004984 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000495e:	6088                	ld	a0,0(s1)
    80004960:	e501                	bnez	a0,80004968 <pipealloc+0xaa>
    80004962:	a039                	j	80004970 <pipealloc+0xb2>
    80004964:	6088                	ld	a0,0(s1)
    80004966:	c51d                	beqz	a0,80004994 <pipealloc+0xd6>
    fileclose(*f0);
    80004968:	00000097          	auipc	ra,0x0
    8000496c:	c26080e7          	jalr	-986(ra) # 8000458e <fileclose>
  if(*f1)
    80004970:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004974:	557d                	li	a0,-1
  if(*f1)
    80004976:	c799                	beqz	a5,80004984 <pipealloc+0xc6>
    fileclose(*f1);
    80004978:	853e                	mv	a0,a5
    8000497a:	00000097          	auipc	ra,0x0
    8000497e:	c14080e7          	jalr	-1004(ra) # 8000458e <fileclose>
  return -1;
    80004982:	557d                	li	a0,-1
}
    80004984:	70a2                	ld	ra,40(sp)
    80004986:	7402                	ld	s0,32(sp)
    80004988:	64e2                	ld	s1,24(sp)
    8000498a:	6942                	ld	s2,16(sp)
    8000498c:	69a2                	ld	s3,8(sp)
    8000498e:	6a02                	ld	s4,0(sp)
    80004990:	6145                	addi	sp,sp,48
    80004992:	8082                	ret
  return -1;
    80004994:	557d                	li	a0,-1
    80004996:	b7fd                	j	80004984 <pipealloc+0xc6>

0000000080004998 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004998:	1101                	addi	sp,sp,-32
    8000499a:	ec06                	sd	ra,24(sp)
    8000499c:	e822                	sd	s0,16(sp)
    8000499e:	e426                	sd	s1,8(sp)
    800049a0:	e04a                	sd	s2,0(sp)
    800049a2:	1000                	addi	s0,sp,32
    800049a4:	84aa                	mv	s1,a0
    800049a6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049a8:	ffffc097          	auipc	ra,0xffffc
    800049ac:	22e080e7          	jalr	558(ra) # 80000bd6 <acquire>
  if(writable){
    800049b0:	02090d63          	beqz	s2,800049ea <pipeclose+0x52>
    pi->writeopen = 0;
    800049b4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049b8:	21848513          	addi	a0,s1,536
    800049bc:	ffffd097          	auipc	ra,0xffffd
    800049c0:	6e2080e7          	jalr	1762(ra) # 8000209e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049c4:	2204b783          	ld	a5,544(s1)
    800049c8:	eb95                	bnez	a5,800049fc <pipeclose+0x64>
    release(&pi->lock);
    800049ca:	8526                	mv	a0,s1
    800049cc:	ffffc097          	auipc	ra,0xffffc
    800049d0:	2be080e7          	jalr	702(ra) # 80000c8a <release>
    kfree((char*)pi);
    800049d4:	8526                	mv	a0,s1
    800049d6:	ffffc097          	auipc	ra,0xffffc
    800049da:	014080e7          	jalr	20(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    800049de:	60e2                	ld	ra,24(sp)
    800049e0:	6442                	ld	s0,16(sp)
    800049e2:	64a2                	ld	s1,8(sp)
    800049e4:	6902                	ld	s2,0(sp)
    800049e6:	6105                	addi	sp,sp,32
    800049e8:	8082                	ret
    pi->readopen = 0;
    800049ea:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049ee:	21c48513          	addi	a0,s1,540
    800049f2:	ffffd097          	auipc	ra,0xffffd
    800049f6:	6ac080e7          	jalr	1708(ra) # 8000209e <wakeup>
    800049fa:	b7e9                	j	800049c4 <pipeclose+0x2c>
    release(&pi->lock);
    800049fc:	8526                	mv	a0,s1
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	28c080e7          	jalr	652(ra) # 80000c8a <release>
}
    80004a06:	bfe1                	j	800049de <pipeclose+0x46>

0000000080004a08 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a08:	711d                	addi	sp,sp,-96
    80004a0a:	ec86                	sd	ra,88(sp)
    80004a0c:	e8a2                	sd	s0,80(sp)
    80004a0e:	e4a6                	sd	s1,72(sp)
    80004a10:	e0ca                	sd	s2,64(sp)
    80004a12:	fc4e                	sd	s3,56(sp)
    80004a14:	f852                	sd	s4,48(sp)
    80004a16:	f456                	sd	s5,40(sp)
    80004a18:	f05a                	sd	s6,32(sp)
    80004a1a:	ec5e                	sd	s7,24(sp)
    80004a1c:	e862                	sd	s8,16(sp)
    80004a1e:	1080                	addi	s0,sp,96
    80004a20:	84aa                	mv	s1,a0
    80004a22:	8aae                	mv	s5,a1
    80004a24:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a26:	ffffd097          	auipc	ra,0xffffd
    80004a2a:	f5a080e7          	jalr	-166(ra) # 80001980 <myproc>
    80004a2e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a30:	8526                	mv	a0,s1
    80004a32:	ffffc097          	auipc	ra,0xffffc
    80004a36:	1a4080e7          	jalr	420(ra) # 80000bd6 <acquire>
  while(i < n){
    80004a3a:	0b405663          	blez	s4,80004ae6 <pipewrite+0xde>
  int i = 0;
    80004a3e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a40:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a42:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a46:	21c48b93          	addi	s7,s1,540
    80004a4a:	a089                	j	80004a8c <pipewrite+0x84>
      release(&pi->lock);
    80004a4c:	8526                	mv	a0,s1
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	23c080e7          	jalr	572(ra) # 80000c8a <release>
      return -1;
    80004a56:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a58:	854a                	mv	a0,s2
    80004a5a:	60e6                	ld	ra,88(sp)
    80004a5c:	6446                	ld	s0,80(sp)
    80004a5e:	64a6                	ld	s1,72(sp)
    80004a60:	6906                	ld	s2,64(sp)
    80004a62:	79e2                	ld	s3,56(sp)
    80004a64:	7a42                	ld	s4,48(sp)
    80004a66:	7aa2                	ld	s5,40(sp)
    80004a68:	7b02                	ld	s6,32(sp)
    80004a6a:	6be2                	ld	s7,24(sp)
    80004a6c:	6c42                	ld	s8,16(sp)
    80004a6e:	6125                	addi	sp,sp,96
    80004a70:	8082                	ret
      wakeup(&pi->nread);
    80004a72:	8562                	mv	a0,s8
    80004a74:	ffffd097          	auipc	ra,0xffffd
    80004a78:	62a080e7          	jalr	1578(ra) # 8000209e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a7c:	85a6                	mv	a1,s1
    80004a7e:	855e                	mv	a0,s7
    80004a80:	ffffd097          	auipc	ra,0xffffd
    80004a84:	5ba080e7          	jalr	1466(ra) # 8000203a <sleep>
  while(i < n){
    80004a88:	07495063          	bge	s2,s4,80004ae8 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a8c:	2204a783          	lw	a5,544(s1)
    80004a90:	dfd5                	beqz	a5,80004a4c <pipewrite+0x44>
    80004a92:	854e                	mv	a0,s3
    80004a94:	ffffe097          	auipc	ra,0xffffe
    80004a98:	84e080e7          	jalr	-1970(ra) # 800022e2 <killed>
    80004a9c:	f945                	bnez	a0,80004a4c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a9e:	2184a783          	lw	a5,536(s1)
    80004aa2:	21c4a703          	lw	a4,540(s1)
    80004aa6:	2007879b          	addiw	a5,a5,512
    80004aaa:	fcf704e3          	beq	a4,a5,80004a72 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aae:	4685                	li	a3,1
    80004ab0:	01590633          	add	a2,s2,s5
    80004ab4:	faf40593          	addi	a1,s0,-81
    80004ab8:	0689b503          	ld	a0,104(s3)
    80004abc:	ffffd097          	auipc	ra,0xffffd
    80004ac0:	c38080e7          	jalr	-968(ra) # 800016f4 <copyin>
    80004ac4:	03650263          	beq	a0,s6,80004ae8 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ac8:	21c4a783          	lw	a5,540(s1)
    80004acc:	0017871b          	addiw	a4,a5,1
    80004ad0:	20e4ae23          	sw	a4,540(s1)
    80004ad4:	1ff7f793          	andi	a5,a5,511
    80004ad8:	97a6                	add	a5,a5,s1
    80004ada:	faf44703          	lbu	a4,-81(s0)
    80004ade:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ae2:	2905                	addiw	s2,s2,1
    80004ae4:	b755                	j	80004a88 <pipewrite+0x80>
  int i = 0;
    80004ae6:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ae8:	21848513          	addi	a0,s1,536
    80004aec:	ffffd097          	auipc	ra,0xffffd
    80004af0:	5b2080e7          	jalr	1458(ra) # 8000209e <wakeup>
  release(&pi->lock);
    80004af4:	8526                	mv	a0,s1
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	194080e7          	jalr	404(ra) # 80000c8a <release>
  return i;
    80004afe:	bfa9                	j	80004a58 <pipewrite+0x50>

0000000080004b00 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b00:	715d                	addi	sp,sp,-80
    80004b02:	e486                	sd	ra,72(sp)
    80004b04:	e0a2                	sd	s0,64(sp)
    80004b06:	fc26                	sd	s1,56(sp)
    80004b08:	f84a                	sd	s2,48(sp)
    80004b0a:	f44e                	sd	s3,40(sp)
    80004b0c:	f052                	sd	s4,32(sp)
    80004b0e:	ec56                	sd	s5,24(sp)
    80004b10:	e85a                	sd	s6,16(sp)
    80004b12:	0880                	addi	s0,sp,80
    80004b14:	84aa                	mv	s1,a0
    80004b16:	892e                	mv	s2,a1
    80004b18:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b1a:	ffffd097          	auipc	ra,0xffffd
    80004b1e:	e66080e7          	jalr	-410(ra) # 80001980 <myproc>
    80004b22:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b24:	8526                	mv	a0,s1
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	0b0080e7          	jalr	176(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b2e:	2184a703          	lw	a4,536(s1)
    80004b32:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b36:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b3a:	02f71763          	bne	a4,a5,80004b68 <piperead+0x68>
    80004b3e:	2244a783          	lw	a5,548(s1)
    80004b42:	c39d                	beqz	a5,80004b68 <piperead+0x68>
    if(killed(pr)){
    80004b44:	8552                	mv	a0,s4
    80004b46:	ffffd097          	auipc	ra,0xffffd
    80004b4a:	79c080e7          	jalr	1948(ra) # 800022e2 <killed>
    80004b4e:	e941                	bnez	a0,80004bde <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b50:	85a6                	mv	a1,s1
    80004b52:	854e                	mv	a0,s3
    80004b54:	ffffd097          	auipc	ra,0xffffd
    80004b58:	4e6080e7          	jalr	1254(ra) # 8000203a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b5c:	2184a703          	lw	a4,536(s1)
    80004b60:	21c4a783          	lw	a5,540(s1)
    80004b64:	fcf70de3          	beq	a4,a5,80004b3e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b68:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b6a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b6c:	05505363          	blez	s5,80004bb2 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004b70:	2184a783          	lw	a5,536(s1)
    80004b74:	21c4a703          	lw	a4,540(s1)
    80004b78:	02f70d63          	beq	a4,a5,80004bb2 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b7c:	0017871b          	addiw	a4,a5,1
    80004b80:	20e4ac23          	sw	a4,536(s1)
    80004b84:	1ff7f793          	andi	a5,a5,511
    80004b88:	97a6                	add	a5,a5,s1
    80004b8a:	0187c783          	lbu	a5,24(a5)
    80004b8e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b92:	4685                	li	a3,1
    80004b94:	fbf40613          	addi	a2,s0,-65
    80004b98:	85ca                	mv	a1,s2
    80004b9a:	068a3503          	ld	a0,104(s4)
    80004b9e:	ffffd097          	auipc	ra,0xffffd
    80004ba2:	aca080e7          	jalr	-1334(ra) # 80001668 <copyout>
    80004ba6:	01650663          	beq	a0,s6,80004bb2 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004baa:	2985                	addiw	s3,s3,1
    80004bac:	0905                	addi	s2,s2,1
    80004bae:	fd3a91e3          	bne	s5,s3,80004b70 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bb2:	21c48513          	addi	a0,s1,540
    80004bb6:	ffffd097          	auipc	ra,0xffffd
    80004bba:	4e8080e7          	jalr	1256(ra) # 8000209e <wakeup>
  release(&pi->lock);
    80004bbe:	8526                	mv	a0,s1
    80004bc0:	ffffc097          	auipc	ra,0xffffc
    80004bc4:	0ca080e7          	jalr	202(ra) # 80000c8a <release>
  return i;
}
    80004bc8:	854e                	mv	a0,s3
    80004bca:	60a6                	ld	ra,72(sp)
    80004bcc:	6406                	ld	s0,64(sp)
    80004bce:	74e2                	ld	s1,56(sp)
    80004bd0:	7942                	ld	s2,48(sp)
    80004bd2:	79a2                	ld	s3,40(sp)
    80004bd4:	7a02                	ld	s4,32(sp)
    80004bd6:	6ae2                	ld	s5,24(sp)
    80004bd8:	6b42                	ld	s6,16(sp)
    80004bda:	6161                	addi	sp,sp,80
    80004bdc:	8082                	ret
      release(&pi->lock);
    80004bde:	8526                	mv	a0,s1
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	0aa080e7          	jalr	170(ra) # 80000c8a <release>
      return -1;
    80004be8:	59fd                	li	s3,-1
    80004bea:	bff9                	j	80004bc8 <piperead+0xc8>

0000000080004bec <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004bec:	1141                	addi	sp,sp,-16
    80004bee:	e422                	sd	s0,8(sp)
    80004bf0:	0800                	addi	s0,sp,16
    80004bf2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004bf4:	8905                	andi	a0,a0,1
    80004bf6:	c111                	beqz	a0,80004bfa <flags2perm+0xe>
      perm = PTE_X;
    80004bf8:	4521                	li	a0,8
    if(flags & 0x2)
    80004bfa:	8b89                	andi	a5,a5,2
    80004bfc:	c399                	beqz	a5,80004c02 <flags2perm+0x16>
      perm |= PTE_W;
    80004bfe:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c02:	6422                	ld	s0,8(sp)
    80004c04:	0141                	addi	sp,sp,16
    80004c06:	8082                	ret

0000000080004c08 <exec>:

int
exec(char *path, char **argv)
{
    80004c08:	de010113          	addi	sp,sp,-544
    80004c0c:	20113c23          	sd	ra,536(sp)
    80004c10:	20813823          	sd	s0,528(sp)
    80004c14:	20913423          	sd	s1,520(sp)
    80004c18:	21213023          	sd	s2,512(sp)
    80004c1c:	ffce                	sd	s3,504(sp)
    80004c1e:	fbd2                	sd	s4,496(sp)
    80004c20:	f7d6                	sd	s5,488(sp)
    80004c22:	f3da                	sd	s6,480(sp)
    80004c24:	efde                	sd	s7,472(sp)
    80004c26:	ebe2                	sd	s8,464(sp)
    80004c28:	e7e6                	sd	s9,456(sp)
    80004c2a:	e3ea                	sd	s10,448(sp)
    80004c2c:	ff6e                	sd	s11,440(sp)
    80004c2e:	1400                	addi	s0,sp,544
    80004c30:	892a                	mv	s2,a0
    80004c32:	dea43423          	sd	a0,-536(s0)
    80004c36:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c3a:	ffffd097          	auipc	ra,0xffffd
    80004c3e:	d46080e7          	jalr	-698(ra) # 80001980 <myproc>
    80004c42:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80004c44:	ffffe097          	auipc	ra,0xffffe
    80004c48:	992080e7          	jalr	-1646(ra) # 800025d6 <mykthread>

  begin_op();
    80004c4c:	fffff097          	auipc	ra,0xfffff
    80004c50:	476080e7          	jalr	1142(ra) # 800040c2 <begin_op>

  if((ip = namei(path)) == 0){
    80004c54:	854a                	mv	a0,s2
    80004c56:	fffff097          	auipc	ra,0xfffff
    80004c5a:	250080e7          	jalr	592(ra) # 80003ea6 <namei>
    80004c5e:	c93d                	beqz	a0,80004cd4 <exec+0xcc>
    80004c60:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	a9e080e7          	jalr	-1378(ra) # 80003700 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c6a:	04000713          	li	a4,64
    80004c6e:	4681                	li	a3,0
    80004c70:	e5040613          	addi	a2,s0,-432
    80004c74:	4581                	li	a1,0
    80004c76:	8556                	mv	a0,s5
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	d3c080e7          	jalr	-708(ra) # 800039b4 <readi>
    80004c80:	04000793          	li	a5,64
    80004c84:	00f51a63          	bne	a0,a5,80004c98 <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c88:	e5042703          	lw	a4,-432(s0)
    80004c8c:	464c47b7          	lui	a5,0x464c4
    80004c90:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c94:	04f70663          	beq	a4,a5,80004ce0 <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c98:	8556                	mv	a0,s5
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	cc8080e7          	jalr	-824(ra) # 80003962 <iunlockput>
    end_op();
    80004ca2:	fffff097          	auipc	ra,0xfffff
    80004ca6:	4a0080e7          	jalr	1184(ra) # 80004142 <end_op>
  }
  return -1;
    80004caa:	557d                	li	a0,-1
}
    80004cac:	21813083          	ld	ra,536(sp)
    80004cb0:	21013403          	ld	s0,528(sp)
    80004cb4:	20813483          	ld	s1,520(sp)
    80004cb8:	20013903          	ld	s2,512(sp)
    80004cbc:	79fe                	ld	s3,504(sp)
    80004cbe:	7a5e                	ld	s4,496(sp)
    80004cc0:	7abe                	ld	s5,488(sp)
    80004cc2:	7b1e                	ld	s6,480(sp)
    80004cc4:	6bfe                	ld	s7,472(sp)
    80004cc6:	6c5e                	ld	s8,464(sp)
    80004cc8:	6cbe                	ld	s9,456(sp)
    80004cca:	6d1e                	ld	s10,448(sp)
    80004ccc:	7dfa                	ld	s11,440(sp)
    80004cce:	22010113          	addi	sp,sp,544
    80004cd2:	8082                	ret
    end_op();
    80004cd4:	fffff097          	auipc	ra,0xfffff
    80004cd8:	46e080e7          	jalr	1134(ra) # 80004142 <end_op>
    return -1;
    80004cdc:	557d                	li	a0,-1
    80004cde:	b7f9                	j	80004cac <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	ffffd097          	auipc	ra,0xffffd
    80004ce6:	d62080e7          	jalr	-670(ra) # 80001a44 <proc_pagetable>
    80004cea:	8b2a                	mv	s6,a0
    80004cec:	d555                	beqz	a0,80004c98 <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cee:	e7042783          	lw	a5,-400(s0)
    80004cf2:	e8845703          	lhu	a4,-376(s0)
    80004cf6:	c735                	beqz	a4,80004d62 <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cf8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cfa:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004cfe:	6a05                	lui	s4,0x1
    80004d00:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004d04:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004d08:	6d85                	lui	s11,0x1
    80004d0a:	7d7d                	lui	s10,0xfffff
    80004d0c:	a4a9                	j	80004f56 <exec+0x34e>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d0e:	00004517          	auipc	a0,0x4
    80004d12:	9c250513          	addi	a0,a0,-1598 # 800086d0 <syscalls+0x280>
    80004d16:	ffffc097          	auipc	ra,0xffffc
    80004d1a:	828080e7          	jalr	-2008(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d1e:	874a                	mv	a4,s2
    80004d20:	009c86bb          	addw	a3,s9,s1
    80004d24:	4581                	li	a1,0
    80004d26:	8556                	mv	a0,s5
    80004d28:	fffff097          	auipc	ra,0xfffff
    80004d2c:	c8c080e7          	jalr	-884(ra) # 800039b4 <readi>
    80004d30:	2501                	sext.w	a0,a0
    80004d32:	1aa91f63          	bne	s2,a0,80004ef0 <exec+0x2e8>
  for(i = 0; i < sz; i += PGSIZE){
    80004d36:	009d84bb          	addw	s1,s11,s1
    80004d3a:	013d09bb          	addw	s3,s10,s3
    80004d3e:	1f74fc63          	bgeu	s1,s7,80004f36 <exec+0x32e>
    pa = walkaddr(pagetable, va + i);
    80004d42:	02049593          	slli	a1,s1,0x20
    80004d46:	9181                	srli	a1,a1,0x20
    80004d48:	95e2                	add	a1,a1,s8
    80004d4a:	855a                	mv	a0,s6
    80004d4c:	ffffc097          	auipc	ra,0xffffc
    80004d50:	310080e7          	jalr	784(ra) # 8000105c <walkaddr>
    80004d54:	862a                	mv	a2,a0
    if(pa == 0)
    80004d56:	dd45                	beqz	a0,80004d0e <exec+0x106>
      n = PGSIZE;
    80004d58:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d5a:	fd49f2e3          	bgeu	s3,s4,80004d1e <exec+0x116>
      n = sz - i;
    80004d5e:	894e                	mv	s2,s3
    80004d60:	bf7d                	j	80004d1e <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d62:	4901                	li	s2,0
  iunlockput(ip);
    80004d64:	8556                	mv	a0,s5
    80004d66:	fffff097          	auipc	ra,0xfffff
    80004d6a:	bfc080e7          	jalr	-1028(ra) # 80003962 <iunlockput>
  end_op();
    80004d6e:	fffff097          	auipc	ra,0xfffff
    80004d72:	3d4080e7          	jalr	980(ra) # 80004142 <end_op>
  p = myproc();
    80004d76:	ffffd097          	auipc	ra,0xffffd
    80004d7a:	c0a080e7          	jalr	-1014(ra) # 80001980 <myproc>
    80004d7e:	8baa                	mv	s7,a0
  kt = mykthread();
    80004d80:	ffffe097          	auipc	ra,0xffffe
    80004d84:	856080e7          	jalr	-1962(ra) # 800025d6 <mykthread>
    80004d88:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004d8a:	060bbd83          	ld	s11,96(s7) # 1060 <_entry-0x7fffefa0>
  sz = PGROUNDUP(sz);
    80004d8e:	6785                	lui	a5,0x1
    80004d90:	17fd                	addi	a5,a5,-1
    80004d92:	993e                	add	s2,s2,a5
    80004d94:	77fd                	lui	a5,0xfffff
    80004d96:	00f977b3          	and	a5,s2,a5
    80004d9a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d9e:	4691                	li	a3,4
    80004da0:	6609                	lui	a2,0x2
    80004da2:	963e                	add	a2,a2,a5
    80004da4:	85be                	mv	a1,a5
    80004da6:	855a                	mv	a0,s6
    80004da8:	ffffc097          	auipc	ra,0xffffc
    80004dac:	668080e7          	jalr	1640(ra) # 80001410 <uvmalloc>
    80004db0:	8c2a                	mv	s8,a0
  ip = 0;
    80004db2:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004db4:	12050e63          	beqz	a0,80004ef0 <exec+0x2e8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004db8:	75f9                	lui	a1,0xffffe
    80004dba:	95aa                	add	a1,a1,a0
    80004dbc:	855a                	mv	a0,s6
    80004dbe:	ffffd097          	auipc	ra,0xffffd
    80004dc2:	878080e7          	jalr	-1928(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80004dc6:	7afd                	lui	s5,0xfffff
    80004dc8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004dca:	df043783          	ld	a5,-528(s0)
    80004dce:	6388                	ld	a0,0(a5)
    80004dd0:	c925                	beqz	a0,80004e40 <exec+0x238>
    80004dd2:	e9040993          	addi	s3,s0,-368
    80004dd6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004dda:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004ddc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004dde:	ffffc097          	auipc	ra,0xffffc
    80004de2:	070080e7          	jalr	112(ra) # 80000e4e <strlen>
    80004de6:	0015079b          	addiw	a5,a0,1
    80004dea:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dee:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004df2:	13596663          	bltu	s2,s5,80004f1e <exec+0x316>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004df6:	df043783          	ld	a5,-528(s0)
    80004dfa:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffdcea0>
    80004dfe:	8552                	mv	a0,s4
    80004e00:	ffffc097          	auipc	ra,0xffffc
    80004e04:	04e080e7          	jalr	78(ra) # 80000e4e <strlen>
    80004e08:	0015069b          	addiw	a3,a0,1
    80004e0c:	8652                	mv	a2,s4
    80004e0e:	85ca                	mv	a1,s2
    80004e10:	855a                	mv	a0,s6
    80004e12:	ffffd097          	auipc	ra,0xffffd
    80004e16:	856080e7          	jalr	-1962(ra) # 80001668 <copyout>
    80004e1a:	10054663          	bltz	a0,80004f26 <exec+0x31e>
    ustack[argc] = sp;
    80004e1e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e22:	0485                	addi	s1,s1,1
    80004e24:	df043783          	ld	a5,-528(s0)
    80004e28:	07a1                	addi	a5,a5,8
    80004e2a:	def43823          	sd	a5,-528(s0)
    80004e2e:	6388                	ld	a0,0(a5)
    80004e30:	c911                	beqz	a0,80004e44 <exec+0x23c>
    if(argc >= MAXARG)
    80004e32:	09a1                	addi	s3,s3,8
    80004e34:	fb3c95e3          	bne	s9,s3,80004dde <exec+0x1d6>
  sz = sz1;
    80004e38:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e3c:	4a81                	li	s5,0
    80004e3e:	a84d                	j	80004ef0 <exec+0x2e8>
  sp = sz;
    80004e40:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e42:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e44:	00349793          	slli	a5,s1,0x3
    80004e48:	f9040713          	addi	a4,s0,-112
    80004e4c:	97ba                	add	a5,a5,a4
    80004e4e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e52:	00148693          	addi	a3,s1,1
    80004e56:	068e                	slli	a3,a3,0x3
    80004e58:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e5c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e60:	01597663          	bgeu	s2,s5,80004e6c <exec+0x264>
  sz = sz1;
    80004e64:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e68:	4a81                	li	s5,0
    80004e6a:	a059                	j	80004ef0 <exec+0x2e8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e6c:	e9040613          	addi	a2,s0,-368
    80004e70:	85ca                	mv	a1,s2
    80004e72:	855a                	mv	a0,s6
    80004e74:	ffffc097          	auipc	ra,0xffffc
    80004e78:	7f4080e7          	jalr	2036(ra) # 80001668 <copyout>
    80004e7c:	0a054963          	bltz	a0,80004f2e <exec+0x326>
  kt->trapframe->a1 = sp;
    80004e80:	008d3783          	ld	a5,8(s10) # fffffffffffff008 <end+0xffffffff7ffdcea8>
    80004e84:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e88:	de843783          	ld	a5,-536(s0)
    80004e8c:	0007c703          	lbu	a4,0(a5)
    80004e90:	cf11                	beqz	a4,80004eac <exec+0x2a4>
    80004e92:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e94:	02f00693          	li	a3,47
    80004e98:	a039                	j	80004ea6 <exec+0x29e>
      last = s+1;
    80004e9a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e9e:	0785                	addi	a5,a5,1
    80004ea0:	fff7c703          	lbu	a4,-1(a5)
    80004ea4:	c701                	beqz	a4,80004eac <exec+0x2a4>
    if(*s == '/')
    80004ea6:	fed71ce3          	bne	a4,a3,80004e9e <exec+0x296>
    80004eaa:	bfc5                	j	80004e9a <exec+0x292>
  safestrcpy(p->name, last, sizeof(p->name));
    80004eac:	4641                	li	a2,16
    80004eae:	de843583          	ld	a1,-536(s0)
    80004eb2:	168b8513          	addi	a0,s7,360
    80004eb6:	ffffc097          	auipc	ra,0xffffc
    80004eba:	f66080e7          	jalr	-154(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004ebe:	068bb503          	ld	a0,104(s7)
  p->pagetable = pagetable;
    80004ec2:	076bb423          	sd	s6,104(s7)
  p->sz = sz;
    80004ec6:	078bb023          	sd	s8,96(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    80004eca:	008d3783          	ld	a5,8(s10)
    80004ece:	e6843703          	ld	a4,-408(s0)
    80004ed2:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    80004ed4:	008d3783          	ld	a5,8(s10)
    80004ed8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004edc:	85ee                	mv	a1,s11
    80004ede:	ffffd097          	auipc	ra,0xffffd
    80004ee2:	c02080e7          	jalr	-1022(ra) # 80001ae0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ee6:	0004851b          	sext.w	a0,s1
    80004eea:	b3c9                	j	80004cac <exec+0xa4>
    80004eec:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ef0:	df843583          	ld	a1,-520(s0)
    80004ef4:	855a                	mv	a0,s6
    80004ef6:	ffffd097          	auipc	ra,0xffffd
    80004efa:	bea080e7          	jalr	-1046(ra) # 80001ae0 <proc_freepagetable>
  if(ip){
    80004efe:	d80a9de3          	bnez	s5,80004c98 <exec+0x90>
  return -1;
    80004f02:	557d                	li	a0,-1
    80004f04:	b365                	j	80004cac <exec+0xa4>
    80004f06:	df243c23          	sd	s2,-520(s0)
    80004f0a:	b7dd                	j	80004ef0 <exec+0x2e8>
    80004f0c:	df243c23          	sd	s2,-520(s0)
    80004f10:	b7c5                	j	80004ef0 <exec+0x2e8>
    80004f12:	df243c23          	sd	s2,-520(s0)
    80004f16:	bfe9                	j	80004ef0 <exec+0x2e8>
    80004f18:	df243c23          	sd	s2,-520(s0)
    80004f1c:	bfd1                	j	80004ef0 <exec+0x2e8>
  sz = sz1;
    80004f1e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f22:	4a81                	li	s5,0
    80004f24:	b7f1                	j	80004ef0 <exec+0x2e8>
  sz = sz1;
    80004f26:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f2a:	4a81                	li	s5,0
    80004f2c:	b7d1                	j	80004ef0 <exec+0x2e8>
  sz = sz1;
    80004f2e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f32:	4a81                	li	s5,0
    80004f34:	bf75                	j	80004ef0 <exec+0x2e8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f36:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f3a:	e0843783          	ld	a5,-504(s0)
    80004f3e:	0017869b          	addiw	a3,a5,1
    80004f42:	e0d43423          	sd	a3,-504(s0)
    80004f46:	e0043783          	ld	a5,-512(s0)
    80004f4a:	0387879b          	addiw	a5,a5,56
    80004f4e:	e8845703          	lhu	a4,-376(s0)
    80004f52:	e0e6d9e3          	bge	a3,a4,80004d64 <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f56:	2781                	sext.w	a5,a5
    80004f58:	e0f43023          	sd	a5,-512(s0)
    80004f5c:	03800713          	li	a4,56
    80004f60:	86be                	mv	a3,a5
    80004f62:	e1840613          	addi	a2,s0,-488
    80004f66:	4581                	li	a1,0
    80004f68:	8556                	mv	a0,s5
    80004f6a:	fffff097          	auipc	ra,0xfffff
    80004f6e:	a4a080e7          	jalr	-1462(ra) # 800039b4 <readi>
    80004f72:	03800793          	li	a5,56
    80004f76:	f6f51be3          	bne	a0,a5,80004eec <exec+0x2e4>
    if(ph.type != ELF_PROG_LOAD)
    80004f7a:	e1842783          	lw	a5,-488(s0)
    80004f7e:	4705                	li	a4,1
    80004f80:	fae79de3          	bne	a5,a4,80004f3a <exec+0x332>
    if(ph.memsz < ph.filesz)
    80004f84:	e4043483          	ld	s1,-448(s0)
    80004f88:	e3843783          	ld	a5,-456(s0)
    80004f8c:	f6f4ede3          	bltu	s1,a5,80004f06 <exec+0x2fe>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f90:	e2843783          	ld	a5,-472(s0)
    80004f94:	94be                	add	s1,s1,a5
    80004f96:	f6f4ebe3          	bltu	s1,a5,80004f0c <exec+0x304>
    if(ph.vaddr % PGSIZE != 0)
    80004f9a:	de043703          	ld	a4,-544(s0)
    80004f9e:	8ff9                	and	a5,a5,a4
    80004fa0:	fbad                	bnez	a5,80004f12 <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004fa2:	e1c42503          	lw	a0,-484(s0)
    80004fa6:	00000097          	auipc	ra,0x0
    80004faa:	c46080e7          	jalr	-954(ra) # 80004bec <flags2perm>
    80004fae:	86aa                	mv	a3,a0
    80004fb0:	8626                	mv	a2,s1
    80004fb2:	85ca                	mv	a1,s2
    80004fb4:	855a                	mv	a0,s6
    80004fb6:	ffffc097          	auipc	ra,0xffffc
    80004fba:	45a080e7          	jalr	1114(ra) # 80001410 <uvmalloc>
    80004fbe:	dea43c23          	sd	a0,-520(s0)
    80004fc2:	d939                	beqz	a0,80004f18 <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fc4:	e2843c03          	ld	s8,-472(s0)
    80004fc8:	e2042c83          	lw	s9,-480(s0)
    80004fcc:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fd0:	f60b83e3          	beqz	s7,80004f36 <exec+0x32e>
    80004fd4:	89de                	mv	s3,s7
    80004fd6:	4481                	li	s1,0
    80004fd8:	b3ad                	j	80004d42 <exec+0x13a>

0000000080004fda <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fda:	7179                	addi	sp,sp,-48
    80004fdc:	f406                	sd	ra,40(sp)
    80004fde:	f022                	sd	s0,32(sp)
    80004fe0:	ec26                	sd	s1,24(sp)
    80004fe2:	e84a                	sd	s2,16(sp)
    80004fe4:	1800                	addi	s0,sp,48
    80004fe6:	892e                	mv	s2,a1
    80004fe8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004fea:	fdc40593          	addi	a1,s0,-36
    80004fee:	ffffe097          	auipc	ra,0xffffe
    80004ff2:	b96080e7          	jalr	-1130(ra) # 80002b84 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ff6:	fdc42703          	lw	a4,-36(s0)
    80004ffa:	47bd                	li	a5,15
    80004ffc:	02e7eb63          	bltu	a5,a4,80005032 <argfd+0x58>
    80005000:	ffffd097          	auipc	ra,0xffffd
    80005004:	980080e7          	jalr	-1664(ra) # 80001980 <myproc>
    80005008:	fdc42703          	lw	a4,-36(s0)
    8000500c:	01c70793          	addi	a5,a4,28
    80005010:	078e                	slli	a5,a5,0x3
    80005012:	953e                	add	a0,a0,a5
    80005014:	611c                	ld	a5,0(a0)
    80005016:	c385                	beqz	a5,80005036 <argfd+0x5c>
    return -1;
  if(pfd)
    80005018:	00090463          	beqz	s2,80005020 <argfd+0x46>
    *pfd = fd;
    8000501c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005020:	4501                	li	a0,0
  if(pf)
    80005022:	c091                	beqz	s1,80005026 <argfd+0x4c>
    *pf = f;
    80005024:	e09c                	sd	a5,0(s1)
}
    80005026:	70a2                	ld	ra,40(sp)
    80005028:	7402                	ld	s0,32(sp)
    8000502a:	64e2                	ld	s1,24(sp)
    8000502c:	6942                	ld	s2,16(sp)
    8000502e:	6145                	addi	sp,sp,48
    80005030:	8082                	ret
    return -1;
    80005032:	557d                	li	a0,-1
    80005034:	bfcd                	j	80005026 <argfd+0x4c>
    80005036:	557d                	li	a0,-1
    80005038:	b7fd                	j	80005026 <argfd+0x4c>

000000008000503a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000503a:	1101                	addi	sp,sp,-32
    8000503c:	ec06                	sd	ra,24(sp)
    8000503e:	e822                	sd	s0,16(sp)
    80005040:	e426                	sd	s1,8(sp)
    80005042:	1000                	addi	s0,sp,32
    80005044:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005046:	ffffd097          	auipc	ra,0xffffd
    8000504a:	93a080e7          	jalr	-1734(ra) # 80001980 <myproc>
    8000504e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005050:	0e050793          	addi	a5,a0,224
    80005054:	4501                	li	a0,0
    80005056:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005058:	6398                	ld	a4,0(a5)
    8000505a:	cb19                	beqz	a4,80005070 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000505c:	2505                	addiw	a0,a0,1
    8000505e:	07a1                	addi	a5,a5,8
    80005060:	fed51ce3          	bne	a0,a3,80005058 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005064:	557d                	li	a0,-1
}
    80005066:	60e2                	ld	ra,24(sp)
    80005068:	6442                	ld	s0,16(sp)
    8000506a:	64a2                	ld	s1,8(sp)
    8000506c:	6105                	addi	sp,sp,32
    8000506e:	8082                	ret
      p->ofile[fd] = f;
    80005070:	01c50793          	addi	a5,a0,28
    80005074:	078e                	slli	a5,a5,0x3
    80005076:	963e                	add	a2,a2,a5
    80005078:	e204                	sd	s1,0(a2)
      return fd;
    8000507a:	b7f5                	j	80005066 <fdalloc+0x2c>

000000008000507c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000507c:	715d                	addi	sp,sp,-80
    8000507e:	e486                	sd	ra,72(sp)
    80005080:	e0a2                	sd	s0,64(sp)
    80005082:	fc26                	sd	s1,56(sp)
    80005084:	f84a                	sd	s2,48(sp)
    80005086:	f44e                	sd	s3,40(sp)
    80005088:	f052                	sd	s4,32(sp)
    8000508a:	ec56                	sd	s5,24(sp)
    8000508c:	e85a                	sd	s6,16(sp)
    8000508e:	0880                	addi	s0,sp,80
    80005090:	8b2e                	mv	s6,a1
    80005092:	89b2                	mv	s3,a2
    80005094:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005096:	fb040593          	addi	a1,s0,-80
    8000509a:	fffff097          	auipc	ra,0xfffff
    8000509e:	e2a080e7          	jalr	-470(ra) # 80003ec4 <nameiparent>
    800050a2:	84aa                	mv	s1,a0
    800050a4:	14050f63          	beqz	a0,80005202 <create+0x186>
    return 0;

  ilock(dp);
    800050a8:	ffffe097          	auipc	ra,0xffffe
    800050ac:	658080e7          	jalr	1624(ra) # 80003700 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050b0:	4601                	li	a2,0
    800050b2:	fb040593          	addi	a1,s0,-80
    800050b6:	8526                	mv	a0,s1
    800050b8:	fffff097          	auipc	ra,0xfffff
    800050bc:	b2c080e7          	jalr	-1236(ra) # 80003be4 <dirlookup>
    800050c0:	8aaa                	mv	s5,a0
    800050c2:	c931                	beqz	a0,80005116 <create+0x9a>
    iunlockput(dp);
    800050c4:	8526                	mv	a0,s1
    800050c6:	fffff097          	auipc	ra,0xfffff
    800050ca:	89c080e7          	jalr	-1892(ra) # 80003962 <iunlockput>
    ilock(ip);
    800050ce:	8556                	mv	a0,s5
    800050d0:	ffffe097          	auipc	ra,0xffffe
    800050d4:	630080e7          	jalr	1584(ra) # 80003700 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050d8:	000b059b          	sext.w	a1,s6
    800050dc:	4789                	li	a5,2
    800050de:	02f59563          	bne	a1,a5,80005108 <create+0x8c>
    800050e2:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdcee4>
    800050e6:	37f9                	addiw	a5,a5,-2
    800050e8:	17c2                	slli	a5,a5,0x30
    800050ea:	93c1                	srli	a5,a5,0x30
    800050ec:	4705                	li	a4,1
    800050ee:	00f76d63          	bltu	a4,a5,80005108 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050f2:	8556                	mv	a0,s5
    800050f4:	60a6                	ld	ra,72(sp)
    800050f6:	6406                	ld	s0,64(sp)
    800050f8:	74e2                	ld	s1,56(sp)
    800050fa:	7942                	ld	s2,48(sp)
    800050fc:	79a2                	ld	s3,40(sp)
    800050fe:	7a02                	ld	s4,32(sp)
    80005100:	6ae2                	ld	s5,24(sp)
    80005102:	6b42                	ld	s6,16(sp)
    80005104:	6161                	addi	sp,sp,80
    80005106:	8082                	ret
    iunlockput(ip);
    80005108:	8556                	mv	a0,s5
    8000510a:	fffff097          	auipc	ra,0xfffff
    8000510e:	858080e7          	jalr	-1960(ra) # 80003962 <iunlockput>
    return 0;
    80005112:	4a81                	li	s5,0
    80005114:	bff9                	j	800050f2 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005116:	85da                	mv	a1,s6
    80005118:	4088                	lw	a0,0(s1)
    8000511a:	ffffe097          	auipc	ra,0xffffe
    8000511e:	44a080e7          	jalr	1098(ra) # 80003564 <ialloc>
    80005122:	8a2a                	mv	s4,a0
    80005124:	c539                	beqz	a0,80005172 <create+0xf6>
  ilock(ip);
    80005126:	ffffe097          	auipc	ra,0xffffe
    8000512a:	5da080e7          	jalr	1498(ra) # 80003700 <ilock>
  ip->major = major;
    8000512e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005132:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005136:	4905                	li	s2,1
    80005138:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000513c:	8552                	mv	a0,s4
    8000513e:	ffffe097          	auipc	ra,0xffffe
    80005142:	4f8080e7          	jalr	1272(ra) # 80003636 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005146:	000b059b          	sext.w	a1,s6
    8000514a:	03258b63          	beq	a1,s2,80005180 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000514e:	004a2603          	lw	a2,4(s4)
    80005152:	fb040593          	addi	a1,s0,-80
    80005156:	8526                	mv	a0,s1
    80005158:	fffff097          	auipc	ra,0xfffff
    8000515c:	c9c080e7          	jalr	-868(ra) # 80003df4 <dirlink>
    80005160:	06054f63          	bltz	a0,800051de <create+0x162>
  iunlockput(dp);
    80005164:	8526                	mv	a0,s1
    80005166:	ffffe097          	auipc	ra,0xffffe
    8000516a:	7fc080e7          	jalr	2044(ra) # 80003962 <iunlockput>
  return ip;
    8000516e:	8ad2                	mv	s5,s4
    80005170:	b749                	j	800050f2 <create+0x76>
    iunlockput(dp);
    80005172:	8526                	mv	a0,s1
    80005174:	ffffe097          	auipc	ra,0xffffe
    80005178:	7ee080e7          	jalr	2030(ra) # 80003962 <iunlockput>
    return 0;
    8000517c:	8ad2                	mv	s5,s4
    8000517e:	bf95                	j	800050f2 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005180:	004a2603          	lw	a2,4(s4)
    80005184:	00003597          	auipc	a1,0x3
    80005188:	56c58593          	addi	a1,a1,1388 # 800086f0 <syscalls+0x2a0>
    8000518c:	8552                	mv	a0,s4
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	c66080e7          	jalr	-922(ra) # 80003df4 <dirlink>
    80005196:	04054463          	bltz	a0,800051de <create+0x162>
    8000519a:	40d0                	lw	a2,4(s1)
    8000519c:	00003597          	auipc	a1,0x3
    800051a0:	55c58593          	addi	a1,a1,1372 # 800086f8 <syscalls+0x2a8>
    800051a4:	8552                	mv	a0,s4
    800051a6:	fffff097          	auipc	ra,0xfffff
    800051aa:	c4e080e7          	jalr	-946(ra) # 80003df4 <dirlink>
    800051ae:	02054863          	bltz	a0,800051de <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800051b2:	004a2603          	lw	a2,4(s4)
    800051b6:	fb040593          	addi	a1,s0,-80
    800051ba:	8526                	mv	a0,s1
    800051bc:	fffff097          	auipc	ra,0xfffff
    800051c0:	c38080e7          	jalr	-968(ra) # 80003df4 <dirlink>
    800051c4:	00054d63          	bltz	a0,800051de <create+0x162>
    dp->nlink++;  // for ".."
    800051c8:	04a4d783          	lhu	a5,74(s1)
    800051cc:	2785                	addiw	a5,a5,1
    800051ce:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051d2:	8526                	mv	a0,s1
    800051d4:	ffffe097          	auipc	ra,0xffffe
    800051d8:	462080e7          	jalr	1122(ra) # 80003636 <iupdate>
    800051dc:	b761                	j	80005164 <create+0xe8>
  ip->nlink = 0;
    800051de:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800051e2:	8552                	mv	a0,s4
    800051e4:	ffffe097          	auipc	ra,0xffffe
    800051e8:	452080e7          	jalr	1106(ra) # 80003636 <iupdate>
  iunlockput(ip);
    800051ec:	8552                	mv	a0,s4
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	774080e7          	jalr	1908(ra) # 80003962 <iunlockput>
  iunlockput(dp);
    800051f6:	8526                	mv	a0,s1
    800051f8:	ffffe097          	auipc	ra,0xffffe
    800051fc:	76a080e7          	jalr	1898(ra) # 80003962 <iunlockput>
  return 0;
    80005200:	bdcd                	j	800050f2 <create+0x76>
    return 0;
    80005202:	8aaa                	mv	s5,a0
    80005204:	b5fd                	j	800050f2 <create+0x76>

0000000080005206 <sys_dup>:
{
    80005206:	7179                	addi	sp,sp,-48
    80005208:	f406                	sd	ra,40(sp)
    8000520a:	f022                	sd	s0,32(sp)
    8000520c:	ec26                	sd	s1,24(sp)
    8000520e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005210:	fd840613          	addi	a2,s0,-40
    80005214:	4581                	li	a1,0
    80005216:	4501                	li	a0,0
    80005218:	00000097          	auipc	ra,0x0
    8000521c:	dc2080e7          	jalr	-574(ra) # 80004fda <argfd>
    return -1;
    80005220:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005222:	02054363          	bltz	a0,80005248 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005226:	fd843503          	ld	a0,-40(s0)
    8000522a:	00000097          	auipc	ra,0x0
    8000522e:	e10080e7          	jalr	-496(ra) # 8000503a <fdalloc>
    80005232:	84aa                	mv	s1,a0
    return -1;
    80005234:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005236:	00054963          	bltz	a0,80005248 <sys_dup+0x42>
  filedup(f);
    8000523a:	fd843503          	ld	a0,-40(s0)
    8000523e:	fffff097          	auipc	ra,0xfffff
    80005242:	2fe080e7          	jalr	766(ra) # 8000453c <filedup>
  return fd;
    80005246:	87a6                	mv	a5,s1
}
    80005248:	853e                	mv	a0,a5
    8000524a:	70a2                	ld	ra,40(sp)
    8000524c:	7402                	ld	s0,32(sp)
    8000524e:	64e2                	ld	s1,24(sp)
    80005250:	6145                	addi	sp,sp,48
    80005252:	8082                	ret

0000000080005254 <sys_read>:
{
    80005254:	7179                	addi	sp,sp,-48
    80005256:	f406                	sd	ra,40(sp)
    80005258:	f022                	sd	s0,32(sp)
    8000525a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000525c:	fd840593          	addi	a1,s0,-40
    80005260:	4505                	li	a0,1
    80005262:	ffffe097          	auipc	ra,0xffffe
    80005266:	942080e7          	jalr	-1726(ra) # 80002ba4 <argaddr>
  argint(2, &n);
    8000526a:	fe440593          	addi	a1,s0,-28
    8000526e:	4509                	li	a0,2
    80005270:	ffffe097          	auipc	ra,0xffffe
    80005274:	914080e7          	jalr	-1772(ra) # 80002b84 <argint>
  if(argfd(0, 0, &f) < 0)
    80005278:	fe840613          	addi	a2,s0,-24
    8000527c:	4581                	li	a1,0
    8000527e:	4501                	li	a0,0
    80005280:	00000097          	auipc	ra,0x0
    80005284:	d5a080e7          	jalr	-678(ra) # 80004fda <argfd>
    80005288:	87aa                	mv	a5,a0
    return -1;
    8000528a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000528c:	0007cc63          	bltz	a5,800052a4 <sys_read+0x50>
  return fileread(f, p, n);
    80005290:	fe442603          	lw	a2,-28(s0)
    80005294:	fd843583          	ld	a1,-40(s0)
    80005298:	fe843503          	ld	a0,-24(s0)
    8000529c:	fffff097          	auipc	ra,0xfffff
    800052a0:	42c080e7          	jalr	1068(ra) # 800046c8 <fileread>
}
    800052a4:	70a2                	ld	ra,40(sp)
    800052a6:	7402                	ld	s0,32(sp)
    800052a8:	6145                	addi	sp,sp,48
    800052aa:	8082                	ret

00000000800052ac <sys_write>:
{
    800052ac:	7179                	addi	sp,sp,-48
    800052ae:	f406                	sd	ra,40(sp)
    800052b0:	f022                	sd	s0,32(sp)
    800052b2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052b4:	fd840593          	addi	a1,s0,-40
    800052b8:	4505                	li	a0,1
    800052ba:	ffffe097          	auipc	ra,0xffffe
    800052be:	8ea080e7          	jalr	-1814(ra) # 80002ba4 <argaddr>
  argint(2, &n);
    800052c2:	fe440593          	addi	a1,s0,-28
    800052c6:	4509                	li	a0,2
    800052c8:	ffffe097          	auipc	ra,0xffffe
    800052cc:	8bc080e7          	jalr	-1860(ra) # 80002b84 <argint>
  if(argfd(0, 0, &f) < 0)
    800052d0:	fe840613          	addi	a2,s0,-24
    800052d4:	4581                	li	a1,0
    800052d6:	4501                	li	a0,0
    800052d8:	00000097          	auipc	ra,0x0
    800052dc:	d02080e7          	jalr	-766(ra) # 80004fda <argfd>
    800052e0:	87aa                	mv	a5,a0
    return -1;
    800052e2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052e4:	0007cc63          	bltz	a5,800052fc <sys_write+0x50>
  return filewrite(f, p, n);
    800052e8:	fe442603          	lw	a2,-28(s0)
    800052ec:	fd843583          	ld	a1,-40(s0)
    800052f0:	fe843503          	ld	a0,-24(s0)
    800052f4:	fffff097          	auipc	ra,0xfffff
    800052f8:	496080e7          	jalr	1174(ra) # 8000478a <filewrite>
}
    800052fc:	70a2                	ld	ra,40(sp)
    800052fe:	7402                	ld	s0,32(sp)
    80005300:	6145                	addi	sp,sp,48
    80005302:	8082                	ret

0000000080005304 <sys_close>:
{
    80005304:	1101                	addi	sp,sp,-32
    80005306:	ec06                	sd	ra,24(sp)
    80005308:	e822                	sd	s0,16(sp)
    8000530a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000530c:	fe040613          	addi	a2,s0,-32
    80005310:	fec40593          	addi	a1,s0,-20
    80005314:	4501                	li	a0,0
    80005316:	00000097          	auipc	ra,0x0
    8000531a:	cc4080e7          	jalr	-828(ra) # 80004fda <argfd>
    return -1;
    8000531e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005320:	02054463          	bltz	a0,80005348 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005324:	ffffc097          	auipc	ra,0xffffc
    80005328:	65c080e7          	jalr	1628(ra) # 80001980 <myproc>
    8000532c:	fec42783          	lw	a5,-20(s0)
    80005330:	07f1                	addi	a5,a5,28
    80005332:	078e                	slli	a5,a5,0x3
    80005334:	97aa                	add	a5,a5,a0
    80005336:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000533a:	fe043503          	ld	a0,-32(s0)
    8000533e:	fffff097          	auipc	ra,0xfffff
    80005342:	250080e7          	jalr	592(ra) # 8000458e <fileclose>
  return 0;
    80005346:	4781                	li	a5,0
}
    80005348:	853e                	mv	a0,a5
    8000534a:	60e2                	ld	ra,24(sp)
    8000534c:	6442                	ld	s0,16(sp)
    8000534e:	6105                	addi	sp,sp,32
    80005350:	8082                	ret

0000000080005352 <sys_fstat>:
{
    80005352:	1101                	addi	sp,sp,-32
    80005354:	ec06                	sd	ra,24(sp)
    80005356:	e822                	sd	s0,16(sp)
    80005358:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000535a:	fe040593          	addi	a1,s0,-32
    8000535e:	4505                	li	a0,1
    80005360:	ffffe097          	auipc	ra,0xffffe
    80005364:	844080e7          	jalr	-1980(ra) # 80002ba4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005368:	fe840613          	addi	a2,s0,-24
    8000536c:	4581                	li	a1,0
    8000536e:	4501                	li	a0,0
    80005370:	00000097          	auipc	ra,0x0
    80005374:	c6a080e7          	jalr	-918(ra) # 80004fda <argfd>
    80005378:	87aa                	mv	a5,a0
    return -1;
    8000537a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000537c:	0007ca63          	bltz	a5,80005390 <sys_fstat+0x3e>
  return filestat(f, st);
    80005380:	fe043583          	ld	a1,-32(s0)
    80005384:	fe843503          	ld	a0,-24(s0)
    80005388:	fffff097          	auipc	ra,0xfffff
    8000538c:	2ce080e7          	jalr	718(ra) # 80004656 <filestat>
}
    80005390:	60e2                	ld	ra,24(sp)
    80005392:	6442                	ld	s0,16(sp)
    80005394:	6105                	addi	sp,sp,32
    80005396:	8082                	ret

0000000080005398 <sys_link>:
{
    80005398:	7169                	addi	sp,sp,-304
    8000539a:	f606                	sd	ra,296(sp)
    8000539c:	f222                	sd	s0,288(sp)
    8000539e:	ee26                	sd	s1,280(sp)
    800053a0:	ea4a                	sd	s2,272(sp)
    800053a2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053a4:	08000613          	li	a2,128
    800053a8:	ed040593          	addi	a1,s0,-304
    800053ac:	4501                	li	a0,0
    800053ae:	ffffe097          	auipc	ra,0xffffe
    800053b2:	816080e7          	jalr	-2026(ra) # 80002bc4 <argstr>
    return -1;
    800053b6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053b8:	10054e63          	bltz	a0,800054d4 <sys_link+0x13c>
    800053bc:	08000613          	li	a2,128
    800053c0:	f5040593          	addi	a1,s0,-176
    800053c4:	4505                	li	a0,1
    800053c6:	ffffd097          	auipc	ra,0xffffd
    800053ca:	7fe080e7          	jalr	2046(ra) # 80002bc4 <argstr>
    return -1;
    800053ce:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053d0:	10054263          	bltz	a0,800054d4 <sys_link+0x13c>
  begin_op();
    800053d4:	fffff097          	auipc	ra,0xfffff
    800053d8:	cee080e7          	jalr	-786(ra) # 800040c2 <begin_op>
  if((ip = namei(old)) == 0){
    800053dc:	ed040513          	addi	a0,s0,-304
    800053e0:	fffff097          	auipc	ra,0xfffff
    800053e4:	ac6080e7          	jalr	-1338(ra) # 80003ea6 <namei>
    800053e8:	84aa                	mv	s1,a0
    800053ea:	c551                	beqz	a0,80005476 <sys_link+0xde>
  ilock(ip);
    800053ec:	ffffe097          	auipc	ra,0xffffe
    800053f0:	314080e7          	jalr	788(ra) # 80003700 <ilock>
  if(ip->type == T_DIR){
    800053f4:	04449703          	lh	a4,68(s1)
    800053f8:	4785                	li	a5,1
    800053fa:	08f70463          	beq	a4,a5,80005482 <sys_link+0xea>
  ip->nlink++;
    800053fe:	04a4d783          	lhu	a5,74(s1)
    80005402:	2785                	addiw	a5,a5,1
    80005404:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005408:	8526                	mv	a0,s1
    8000540a:	ffffe097          	auipc	ra,0xffffe
    8000540e:	22c080e7          	jalr	556(ra) # 80003636 <iupdate>
  iunlock(ip);
    80005412:	8526                	mv	a0,s1
    80005414:	ffffe097          	auipc	ra,0xffffe
    80005418:	3ae080e7          	jalr	942(ra) # 800037c2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000541c:	fd040593          	addi	a1,s0,-48
    80005420:	f5040513          	addi	a0,s0,-176
    80005424:	fffff097          	auipc	ra,0xfffff
    80005428:	aa0080e7          	jalr	-1376(ra) # 80003ec4 <nameiparent>
    8000542c:	892a                	mv	s2,a0
    8000542e:	c935                	beqz	a0,800054a2 <sys_link+0x10a>
  ilock(dp);
    80005430:	ffffe097          	auipc	ra,0xffffe
    80005434:	2d0080e7          	jalr	720(ra) # 80003700 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005438:	00092703          	lw	a4,0(s2)
    8000543c:	409c                	lw	a5,0(s1)
    8000543e:	04f71d63          	bne	a4,a5,80005498 <sys_link+0x100>
    80005442:	40d0                	lw	a2,4(s1)
    80005444:	fd040593          	addi	a1,s0,-48
    80005448:	854a                	mv	a0,s2
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	9aa080e7          	jalr	-1622(ra) # 80003df4 <dirlink>
    80005452:	04054363          	bltz	a0,80005498 <sys_link+0x100>
  iunlockput(dp);
    80005456:	854a                	mv	a0,s2
    80005458:	ffffe097          	auipc	ra,0xffffe
    8000545c:	50a080e7          	jalr	1290(ra) # 80003962 <iunlockput>
  iput(ip);
    80005460:	8526                	mv	a0,s1
    80005462:	ffffe097          	auipc	ra,0xffffe
    80005466:	458080e7          	jalr	1112(ra) # 800038ba <iput>
  end_op();
    8000546a:	fffff097          	auipc	ra,0xfffff
    8000546e:	cd8080e7          	jalr	-808(ra) # 80004142 <end_op>
  return 0;
    80005472:	4781                	li	a5,0
    80005474:	a085                	j	800054d4 <sys_link+0x13c>
    end_op();
    80005476:	fffff097          	auipc	ra,0xfffff
    8000547a:	ccc080e7          	jalr	-820(ra) # 80004142 <end_op>
    return -1;
    8000547e:	57fd                	li	a5,-1
    80005480:	a891                	j	800054d4 <sys_link+0x13c>
    iunlockput(ip);
    80005482:	8526                	mv	a0,s1
    80005484:	ffffe097          	auipc	ra,0xffffe
    80005488:	4de080e7          	jalr	1246(ra) # 80003962 <iunlockput>
    end_op();
    8000548c:	fffff097          	auipc	ra,0xfffff
    80005490:	cb6080e7          	jalr	-842(ra) # 80004142 <end_op>
    return -1;
    80005494:	57fd                	li	a5,-1
    80005496:	a83d                	j	800054d4 <sys_link+0x13c>
    iunlockput(dp);
    80005498:	854a                	mv	a0,s2
    8000549a:	ffffe097          	auipc	ra,0xffffe
    8000549e:	4c8080e7          	jalr	1224(ra) # 80003962 <iunlockput>
  ilock(ip);
    800054a2:	8526                	mv	a0,s1
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	25c080e7          	jalr	604(ra) # 80003700 <ilock>
  ip->nlink--;
    800054ac:	04a4d783          	lhu	a5,74(s1)
    800054b0:	37fd                	addiw	a5,a5,-1
    800054b2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054b6:	8526                	mv	a0,s1
    800054b8:	ffffe097          	auipc	ra,0xffffe
    800054bc:	17e080e7          	jalr	382(ra) # 80003636 <iupdate>
  iunlockput(ip);
    800054c0:	8526                	mv	a0,s1
    800054c2:	ffffe097          	auipc	ra,0xffffe
    800054c6:	4a0080e7          	jalr	1184(ra) # 80003962 <iunlockput>
  end_op();
    800054ca:	fffff097          	auipc	ra,0xfffff
    800054ce:	c78080e7          	jalr	-904(ra) # 80004142 <end_op>
  return -1;
    800054d2:	57fd                	li	a5,-1
}
    800054d4:	853e                	mv	a0,a5
    800054d6:	70b2                	ld	ra,296(sp)
    800054d8:	7412                	ld	s0,288(sp)
    800054da:	64f2                	ld	s1,280(sp)
    800054dc:	6952                	ld	s2,272(sp)
    800054de:	6155                	addi	sp,sp,304
    800054e0:	8082                	ret

00000000800054e2 <sys_unlink>:
{
    800054e2:	7151                	addi	sp,sp,-240
    800054e4:	f586                	sd	ra,232(sp)
    800054e6:	f1a2                	sd	s0,224(sp)
    800054e8:	eda6                	sd	s1,216(sp)
    800054ea:	e9ca                	sd	s2,208(sp)
    800054ec:	e5ce                	sd	s3,200(sp)
    800054ee:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054f0:	08000613          	li	a2,128
    800054f4:	f3040593          	addi	a1,s0,-208
    800054f8:	4501                	li	a0,0
    800054fa:	ffffd097          	auipc	ra,0xffffd
    800054fe:	6ca080e7          	jalr	1738(ra) # 80002bc4 <argstr>
    80005502:	18054163          	bltz	a0,80005684 <sys_unlink+0x1a2>
  begin_op();
    80005506:	fffff097          	auipc	ra,0xfffff
    8000550a:	bbc080e7          	jalr	-1092(ra) # 800040c2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000550e:	fb040593          	addi	a1,s0,-80
    80005512:	f3040513          	addi	a0,s0,-208
    80005516:	fffff097          	auipc	ra,0xfffff
    8000551a:	9ae080e7          	jalr	-1618(ra) # 80003ec4 <nameiparent>
    8000551e:	84aa                	mv	s1,a0
    80005520:	c979                	beqz	a0,800055f6 <sys_unlink+0x114>
  ilock(dp);
    80005522:	ffffe097          	auipc	ra,0xffffe
    80005526:	1de080e7          	jalr	478(ra) # 80003700 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000552a:	00003597          	auipc	a1,0x3
    8000552e:	1c658593          	addi	a1,a1,454 # 800086f0 <syscalls+0x2a0>
    80005532:	fb040513          	addi	a0,s0,-80
    80005536:	ffffe097          	auipc	ra,0xffffe
    8000553a:	694080e7          	jalr	1684(ra) # 80003bca <namecmp>
    8000553e:	14050a63          	beqz	a0,80005692 <sys_unlink+0x1b0>
    80005542:	00003597          	auipc	a1,0x3
    80005546:	1b658593          	addi	a1,a1,438 # 800086f8 <syscalls+0x2a8>
    8000554a:	fb040513          	addi	a0,s0,-80
    8000554e:	ffffe097          	auipc	ra,0xffffe
    80005552:	67c080e7          	jalr	1660(ra) # 80003bca <namecmp>
    80005556:	12050e63          	beqz	a0,80005692 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000555a:	f2c40613          	addi	a2,s0,-212
    8000555e:	fb040593          	addi	a1,s0,-80
    80005562:	8526                	mv	a0,s1
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	680080e7          	jalr	1664(ra) # 80003be4 <dirlookup>
    8000556c:	892a                	mv	s2,a0
    8000556e:	12050263          	beqz	a0,80005692 <sys_unlink+0x1b0>
  ilock(ip);
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	18e080e7          	jalr	398(ra) # 80003700 <ilock>
  if(ip->nlink < 1)
    8000557a:	04a91783          	lh	a5,74(s2)
    8000557e:	08f05263          	blez	a5,80005602 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005582:	04491703          	lh	a4,68(s2)
    80005586:	4785                	li	a5,1
    80005588:	08f70563          	beq	a4,a5,80005612 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000558c:	4641                	li	a2,16
    8000558e:	4581                	li	a1,0
    80005590:	fc040513          	addi	a0,s0,-64
    80005594:	ffffb097          	auipc	ra,0xffffb
    80005598:	73e080e7          	jalr	1854(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000559c:	4741                	li	a4,16
    8000559e:	f2c42683          	lw	a3,-212(s0)
    800055a2:	fc040613          	addi	a2,s0,-64
    800055a6:	4581                	li	a1,0
    800055a8:	8526                	mv	a0,s1
    800055aa:	ffffe097          	auipc	ra,0xffffe
    800055ae:	502080e7          	jalr	1282(ra) # 80003aac <writei>
    800055b2:	47c1                	li	a5,16
    800055b4:	0af51563          	bne	a0,a5,8000565e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055b8:	04491703          	lh	a4,68(s2)
    800055bc:	4785                	li	a5,1
    800055be:	0af70863          	beq	a4,a5,8000566e <sys_unlink+0x18c>
  iunlockput(dp);
    800055c2:	8526                	mv	a0,s1
    800055c4:	ffffe097          	auipc	ra,0xffffe
    800055c8:	39e080e7          	jalr	926(ra) # 80003962 <iunlockput>
  ip->nlink--;
    800055cc:	04a95783          	lhu	a5,74(s2)
    800055d0:	37fd                	addiw	a5,a5,-1
    800055d2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055d6:	854a                	mv	a0,s2
    800055d8:	ffffe097          	auipc	ra,0xffffe
    800055dc:	05e080e7          	jalr	94(ra) # 80003636 <iupdate>
  iunlockput(ip);
    800055e0:	854a                	mv	a0,s2
    800055e2:	ffffe097          	auipc	ra,0xffffe
    800055e6:	380080e7          	jalr	896(ra) # 80003962 <iunlockput>
  end_op();
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	b58080e7          	jalr	-1192(ra) # 80004142 <end_op>
  return 0;
    800055f2:	4501                	li	a0,0
    800055f4:	a84d                	j	800056a6 <sys_unlink+0x1c4>
    end_op();
    800055f6:	fffff097          	auipc	ra,0xfffff
    800055fa:	b4c080e7          	jalr	-1204(ra) # 80004142 <end_op>
    return -1;
    800055fe:	557d                	li	a0,-1
    80005600:	a05d                	j	800056a6 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005602:	00003517          	auipc	a0,0x3
    80005606:	0fe50513          	addi	a0,a0,254 # 80008700 <syscalls+0x2b0>
    8000560a:	ffffb097          	auipc	ra,0xffffb
    8000560e:	f34080e7          	jalr	-204(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005612:	04c92703          	lw	a4,76(s2)
    80005616:	02000793          	li	a5,32
    8000561a:	f6e7f9e3          	bgeu	a5,a4,8000558c <sys_unlink+0xaa>
    8000561e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005622:	4741                	li	a4,16
    80005624:	86ce                	mv	a3,s3
    80005626:	f1840613          	addi	a2,s0,-232
    8000562a:	4581                	li	a1,0
    8000562c:	854a                	mv	a0,s2
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	386080e7          	jalr	902(ra) # 800039b4 <readi>
    80005636:	47c1                	li	a5,16
    80005638:	00f51b63          	bne	a0,a5,8000564e <sys_unlink+0x16c>
    if(de.inum != 0)
    8000563c:	f1845783          	lhu	a5,-232(s0)
    80005640:	e7a1                	bnez	a5,80005688 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005642:	29c1                	addiw	s3,s3,16
    80005644:	04c92783          	lw	a5,76(s2)
    80005648:	fcf9ede3          	bltu	s3,a5,80005622 <sys_unlink+0x140>
    8000564c:	b781                	j	8000558c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000564e:	00003517          	auipc	a0,0x3
    80005652:	0ca50513          	addi	a0,a0,202 # 80008718 <syscalls+0x2c8>
    80005656:	ffffb097          	auipc	ra,0xffffb
    8000565a:	ee8080e7          	jalr	-280(ra) # 8000053e <panic>
    panic("unlink: writei");
    8000565e:	00003517          	auipc	a0,0x3
    80005662:	0d250513          	addi	a0,a0,210 # 80008730 <syscalls+0x2e0>
    80005666:	ffffb097          	auipc	ra,0xffffb
    8000566a:	ed8080e7          	jalr	-296(ra) # 8000053e <panic>
    dp->nlink--;
    8000566e:	04a4d783          	lhu	a5,74(s1)
    80005672:	37fd                	addiw	a5,a5,-1
    80005674:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005678:	8526                	mv	a0,s1
    8000567a:	ffffe097          	auipc	ra,0xffffe
    8000567e:	fbc080e7          	jalr	-68(ra) # 80003636 <iupdate>
    80005682:	b781                	j	800055c2 <sys_unlink+0xe0>
    return -1;
    80005684:	557d                	li	a0,-1
    80005686:	a005                	j	800056a6 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005688:	854a                	mv	a0,s2
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	2d8080e7          	jalr	728(ra) # 80003962 <iunlockput>
  iunlockput(dp);
    80005692:	8526                	mv	a0,s1
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	2ce080e7          	jalr	718(ra) # 80003962 <iunlockput>
  end_op();
    8000569c:	fffff097          	auipc	ra,0xfffff
    800056a0:	aa6080e7          	jalr	-1370(ra) # 80004142 <end_op>
  return -1;
    800056a4:	557d                	li	a0,-1
}
    800056a6:	70ae                	ld	ra,232(sp)
    800056a8:	740e                	ld	s0,224(sp)
    800056aa:	64ee                	ld	s1,216(sp)
    800056ac:	694e                	ld	s2,208(sp)
    800056ae:	69ae                	ld	s3,200(sp)
    800056b0:	616d                	addi	sp,sp,240
    800056b2:	8082                	ret

00000000800056b4 <sys_open>:

uint64
sys_open(void)
{
    800056b4:	7131                	addi	sp,sp,-192
    800056b6:	fd06                	sd	ra,184(sp)
    800056b8:	f922                	sd	s0,176(sp)
    800056ba:	f526                	sd	s1,168(sp)
    800056bc:	f14a                	sd	s2,160(sp)
    800056be:	ed4e                	sd	s3,152(sp)
    800056c0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800056c2:	f4c40593          	addi	a1,s0,-180
    800056c6:	4505                	li	a0,1
    800056c8:	ffffd097          	auipc	ra,0xffffd
    800056cc:	4bc080e7          	jalr	1212(ra) # 80002b84 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056d0:	08000613          	li	a2,128
    800056d4:	f5040593          	addi	a1,s0,-176
    800056d8:	4501                	li	a0,0
    800056da:	ffffd097          	auipc	ra,0xffffd
    800056de:	4ea080e7          	jalr	1258(ra) # 80002bc4 <argstr>
    800056e2:	87aa                	mv	a5,a0
    return -1;
    800056e4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056e6:	0a07c963          	bltz	a5,80005798 <sys_open+0xe4>

  begin_op();
    800056ea:	fffff097          	auipc	ra,0xfffff
    800056ee:	9d8080e7          	jalr	-1576(ra) # 800040c2 <begin_op>

  if(omode & O_CREATE){
    800056f2:	f4c42783          	lw	a5,-180(s0)
    800056f6:	2007f793          	andi	a5,a5,512
    800056fa:	cfc5                	beqz	a5,800057b2 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056fc:	4681                	li	a3,0
    800056fe:	4601                	li	a2,0
    80005700:	4589                	li	a1,2
    80005702:	f5040513          	addi	a0,s0,-176
    80005706:	00000097          	auipc	ra,0x0
    8000570a:	976080e7          	jalr	-1674(ra) # 8000507c <create>
    8000570e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005710:	c959                	beqz	a0,800057a6 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005712:	04449703          	lh	a4,68(s1)
    80005716:	478d                	li	a5,3
    80005718:	00f71763          	bne	a4,a5,80005726 <sys_open+0x72>
    8000571c:	0464d703          	lhu	a4,70(s1)
    80005720:	47a5                	li	a5,9
    80005722:	0ce7ed63          	bltu	a5,a4,800057fc <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	dac080e7          	jalr	-596(ra) # 800044d2 <filealloc>
    8000572e:	89aa                	mv	s3,a0
    80005730:	10050363          	beqz	a0,80005836 <sys_open+0x182>
    80005734:	00000097          	auipc	ra,0x0
    80005738:	906080e7          	jalr	-1786(ra) # 8000503a <fdalloc>
    8000573c:	892a                	mv	s2,a0
    8000573e:	0e054763          	bltz	a0,8000582c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005742:	04449703          	lh	a4,68(s1)
    80005746:	478d                	li	a5,3
    80005748:	0cf70563          	beq	a4,a5,80005812 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000574c:	4789                	li	a5,2
    8000574e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005752:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005756:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000575a:	f4c42783          	lw	a5,-180(s0)
    8000575e:	0017c713          	xori	a4,a5,1
    80005762:	8b05                	andi	a4,a4,1
    80005764:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005768:	0037f713          	andi	a4,a5,3
    8000576c:	00e03733          	snez	a4,a4
    80005770:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005774:	4007f793          	andi	a5,a5,1024
    80005778:	c791                	beqz	a5,80005784 <sys_open+0xd0>
    8000577a:	04449703          	lh	a4,68(s1)
    8000577e:	4789                	li	a5,2
    80005780:	0af70063          	beq	a4,a5,80005820 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005784:	8526                	mv	a0,s1
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	03c080e7          	jalr	60(ra) # 800037c2 <iunlock>
  end_op();
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	9b4080e7          	jalr	-1612(ra) # 80004142 <end_op>

  return fd;
    80005796:	854a                	mv	a0,s2
}
    80005798:	70ea                	ld	ra,184(sp)
    8000579a:	744a                	ld	s0,176(sp)
    8000579c:	74aa                	ld	s1,168(sp)
    8000579e:	790a                	ld	s2,160(sp)
    800057a0:	69ea                	ld	s3,152(sp)
    800057a2:	6129                	addi	sp,sp,192
    800057a4:	8082                	ret
      end_op();
    800057a6:	fffff097          	auipc	ra,0xfffff
    800057aa:	99c080e7          	jalr	-1636(ra) # 80004142 <end_op>
      return -1;
    800057ae:	557d                	li	a0,-1
    800057b0:	b7e5                	j	80005798 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800057b2:	f5040513          	addi	a0,s0,-176
    800057b6:	ffffe097          	auipc	ra,0xffffe
    800057ba:	6f0080e7          	jalr	1776(ra) # 80003ea6 <namei>
    800057be:	84aa                	mv	s1,a0
    800057c0:	c905                	beqz	a0,800057f0 <sys_open+0x13c>
    ilock(ip);
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	f3e080e7          	jalr	-194(ra) # 80003700 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057ca:	04449703          	lh	a4,68(s1)
    800057ce:	4785                	li	a5,1
    800057d0:	f4f711e3          	bne	a4,a5,80005712 <sys_open+0x5e>
    800057d4:	f4c42783          	lw	a5,-180(s0)
    800057d8:	d7b9                	beqz	a5,80005726 <sys_open+0x72>
      iunlockput(ip);
    800057da:	8526                	mv	a0,s1
    800057dc:	ffffe097          	auipc	ra,0xffffe
    800057e0:	186080e7          	jalr	390(ra) # 80003962 <iunlockput>
      end_op();
    800057e4:	fffff097          	auipc	ra,0xfffff
    800057e8:	95e080e7          	jalr	-1698(ra) # 80004142 <end_op>
      return -1;
    800057ec:	557d                	li	a0,-1
    800057ee:	b76d                	j	80005798 <sys_open+0xe4>
      end_op();
    800057f0:	fffff097          	auipc	ra,0xfffff
    800057f4:	952080e7          	jalr	-1710(ra) # 80004142 <end_op>
      return -1;
    800057f8:	557d                	li	a0,-1
    800057fa:	bf79                	j	80005798 <sys_open+0xe4>
    iunlockput(ip);
    800057fc:	8526                	mv	a0,s1
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	164080e7          	jalr	356(ra) # 80003962 <iunlockput>
    end_op();
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	93c080e7          	jalr	-1732(ra) # 80004142 <end_op>
    return -1;
    8000580e:	557d                	li	a0,-1
    80005810:	b761                	j	80005798 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005812:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005816:	04649783          	lh	a5,70(s1)
    8000581a:	02f99223          	sh	a5,36(s3)
    8000581e:	bf25                	j	80005756 <sys_open+0xa2>
    itrunc(ip);
    80005820:	8526                	mv	a0,s1
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	fec080e7          	jalr	-20(ra) # 8000380e <itrunc>
    8000582a:	bfa9                	j	80005784 <sys_open+0xd0>
      fileclose(f);
    8000582c:	854e                	mv	a0,s3
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	d60080e7          	jalr	-672(ra) # 8000458e <fileclose>
    iunlockput(ip);
    80005836:	8526                	mv	a0,s1
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	12a080e7          	jalr	298(ra) # 80003962 <iunlockput>
    end_op();
    80005840:	fffff097          	auipc	ra,0xfffff
    80005844:	902080e7          	jalr	-1790(ra) # 80004142 <end_op>
    return -1;
    80005848:	557d                	li	a0,-1
    8000584a:	b7b9                	j	80005798 <sys_open+0xe4>

000000008000584c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000584c:	7175                	addi	sp,sp,-144
    8000584e:	e506                	sd	ra,136(sp)
    80005850:	e122                	sd	s0,128(sp)
    80005852:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005854:	fffff097          	auipc	ra,0xfffff
    80005858:	86e080e7          	jalr	-1938(ra) # 800040c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000585c:	08000613          	li	a2,128
    80005860:	f7040593          	addi	a1,s0,-144
    80005864:	4501                	li	a0,0
    80005866:	ffffd097          	auipc	ra,0xffffd
    8000586a:	35e080e7          	jalr	862(ra) # 80002bc4 <argstr>
    8000586e:	02054963          	bltz	a0,800058a0 <sys_mkdir+0x54>
    80005872:	4681                	li	a3,0
    80005874:	4601                	li	a2,0
    80005876:	4585                	li	a1,1
    80005878:	f7040513          	addi	a0,s0,-144
    8000587c:	00000097          	auipc	ra,0x0
    80005880:	800080e7          	jalr	-2048(ra) # 8000507c <create>
    80005884:	cd11                	beqz	a0,800058a0 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	0dc080e7          	jalr	220(ra) # 80003962 <iunlockput>
  end_op();
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	8b4080e7          	jalr	-1868(ra) # 80004142 <end_op>
  return 0;
    80005896:	4501                	li	a0,0
}
    80005898:	60aa                	ld	ra,136(sp)
    8000589a:	640a                	ld	s0,128(sp)
    8000589c:	6149                	addi	sp,sp,144
    8000589e:	8082                	ret
    end_op();
    800058a0:	fffff097          	auipc	ra,0xfffff
    800058a4:	8a2080e7          	jalr	-1886(ra) # 80004142 <end_op>
    return -1;
    800058a8:	557d                	li	a0,-1
    800058aa:	b7fd                	j	80005898 <sys_mkdir+0x4c>

00000000800058ac <sys_mknod>:

uint64
sys_mknod(void)
{
    800058ac:	7135                	addi	sp,sp,-160
    800058ae:	ed06                	sd	ra,152(sp)
    800058b0:	e922                	sd	s0,144(sp)
    800058b2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058b4:	fffff097          	auipc	ra,0xfffff
    800058b8:	80e080e7          	jalr	-2034(ra) # 800040c2 <begin_op>
  argint(1, &major);
    800058bc:	f6c40593          	addi	a1,s0,-148
    800058c0:	4505                	li	a0,1
    800058c2:	ffffd097          	auipc	ra,0xffffd
    800058c6:	2c2080e7          	jalr	706(ra) # 80002b84 <argint>
  argint(2, &minor);
    800058ca:	f6840593          	addi	a1,s0,-152
    800058ce:	4509                	li	a0,2
    800058d0:	ffffd097          	auipc	ra,0xffffd
    800058d4:	2b4080e7          	jalr	692(ra) # 80002b84 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058d8:	08000613          	li	a2,128
    800058dc:	f7040593          	addi	a1,s0,-144
    800058e0:	4501                	li	a0,0
    800058e2:	ffffd097          	auipc	ra,0xffffd
    800058e6:	2e2080e7          	jalr	738(ra) # 80002bc4 <argstr>
    800058ea:	02054b63          	bltz	a0,80005920 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058ee:	f6841683          	lh	a3,-152(s0)
    800058f2:	f6c41603          	lh	a2,-148(s0)
    800058f6:	458d                	li	a1,3
    800058f8:	f7040513          	addi	a0,s0,-144
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	780080e7          	jalr	1920(ra) # 8000507c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005904:	cd11                	beqz	a0,80005920 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	05c080e7          	jalr	92(ra) # 80003962 <iunlockput>
  end_op();
    8000590e:	fffff097          	auipc	ra,0xfffff
    80005912:	834080e7          	jalr	-1996(ra) # 80004142 <end_op>
  return 0;
    80005916:	4501                	li	a0,0
}
    80005918:	60ea                	ld	ra,152(sp)
    8000591a:	644a                	ld	s0,144(sp)
    8000591c:	610d                	addi	sp,sp,160
    8000591e:	8082                	ret
    end_op();
    80005920:	fffff097          	auipc	ra,0xfffff
    80005924:	822080e7          	jalr	-2014(ra) # 80004142 <end_op>
    return -1;
    80005928:	557d                	li	a0,-1
    8000592a:	b7fd                	j	80005918 <sys_mknod+0x6c>

000000008000592c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000592c:	7135                	addi	sp,sp,-160
    8000592e:	ed06                	sd	ra,152(sp)
    80005930:	e922                	sd	s0,144(sp)
    80005932:	e526                	sd	s1,136(sp)
    80005934:	e14a                	sd	s2,128(sp)
    80005936:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005938:	ffffc097          	auipc	ra,0xffffc
    8000593c:	048080e7          	jalr	72(ra) # 80001980 <myproc>
    80005940:	892a                	mv	s2,a0
  
  begin_op();
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	780080e7          	jalr	1920(ra) # 800040c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000594a:	08000613          	li	a2,128
    8000594e:	f6040593          	addi	a1,s0,-160
    80005952:	4501                	li	a0,0
    80005954:	ffffd097          	auipc	ra,0xffffd
    80005958:	270080e7          	jalr	624(ra) # 80002bc4 <argstr>
    8000595c:	04054b63          	bltz	a0,800059b2 <sys_chdir+0x86>
    80005960:	f6040513          	addi	a0,s0,-160
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	542080e7          	jalr	1346(ra) # 80003ea6 <namei>
    8000596c:	84aa                	mv	s1,a0
    8000596e:	c131                	beqz	a0,800059b2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	d90080e7          	jalr	-624(ra) # 80003700 <ilock>
  if(ip->type != T_DIR){
    80005978:	04449703          	lh	a4,68(s1)
    8000597c:	4785                	li	a5,1
    8000597e:	04f71063          	bne	a4,a5,800059be <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005982:	8526                	mv	a0,s1
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	e3e080e7          	jalr	-450(ra) # 800037c2 <iunlock>
  iput(p->cwd);
    8000598c:	16093503          	ld	a0,352(s2)
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	f2a080e7          	jalr	-214(ra) # 800038ba <iput>
  end_op();
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	7aa080e7          	jalr	1962(ra) # 80004142 <end_op>
  p->cwd = ip;
    800059a0:	16993023          	sd	s1,352(s2)
  return 0;
    800059a4:	4501                	li	a0,0
}
    800059a6:	60ea                	ld	ra,152(sp)
    800059a8:	644a                	ld	s0,144(sp)
    800059aa:	64aa                	ld	s1,136(sp)
    800059ac:	690a                	ld	s2,128(sp)
    800059ae:	610d                	addi	sp,sp,160
    800059b0:	8082                	ret
    end_op();
    800059b2:	ffffe097          	auipc	ra,0xffffe
    800059b6:	790080e7          	jalr	1936(ra) # 80004142 <end_op>
    return -1;
    800059ba:	557d                	li	a0,-1
    800059bc:	b7ed                	j	800059a6 <sys_chdir+0x7a>
    iunlockput(ip);
    800059be:	8526                	mv	a0,s1
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	fa2080e7          	jalr	-94(ra) # 80003962 <iunlockput>
    end_op();
    800059c8:	ffffe097          	auipc	ra,0xffffe
    800059cc:	77a080e7          	jalr	1914(ra) # 80004142 <end_op>
    return -1;
    800059d0:	557d                	li	a0,-1
    800059d2:	bfd1                	j	800059a6 <sys_chdir+0x7a>

00000000800059d4 <sys_exec>:

uint64
sys_exec(void)
{
    800059d4:	7145                	addi	sp,sp,-464
    800059d6:	e786                	sd	ra,456(sp)
    800059d8:	e3a2                	sd	s0,448(sp)
    800059da:	ff26                	sd	s1,440(sp)
    800059dc:	fb4a                	sd	s2,432(sp)
    800059de:	f74e                	sd	s3,424(sp)
    800059e0:	f352                	sd	s4,416(sp)
    800059e2:	ef56                	sd	s5,408(sp)
    800059e4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800059e6:	e3840593          	addi	a1,s0,-456
    800059ea:	4505                	li	a0,1
    800059ec:	ffffd097          	auipc	ra,0xffffd
    800059f0:	1b8080e7          	jalr	440(ra) # 80002ba4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800059f4:	08000613          	li	a2,128
    800059f8:	f4040593          	addi	a1,s0,-192
    800059fc:	4501                	li	a0,0
    800059fe:	ffffd097          	auipc	ra,0xffffd
    80005a02:	1c6080e7          	jalr	454(ra) # 80002bc4 <argstr>
    80005a06:	87aa                	mv	a5,a0
    return -1;
    80005a08:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a0a:	0c07c263          	bltz	a5,80005ace <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005a0e:	10000613          	li	a2,256
    80005a12:	4581                	li	a1,0
    80005a14:	e4040513          	addi	a0,s0,-448
    80005a18:	ffffb097          	auipc	ra,0xffffb
    80005a1c:	2ba080e7          	jalr	698(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a20:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a24:	89a6                	mv	s3,s1
    80005a26:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a28:	02000a13          	li	s4,32
    80005a2c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a30:	00391793          	slli	a5,s2,0x3
    80005a34:	e3040593          	addi	a1,s0,-464
    80005a38:	e3843503          	ld	a0,-456(s0)
    80005a3c:	953e                	add	a0,a0,a5
    80005a3e:	ffffd097          	auipc	ra,0xffffd
    80005a42:	0a8080e7          	jalr	168(ra) # 80002ae6 <fetchaddr>
    80005a46:	02054a63          	bltz	a0,80005a7a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005a4a:	e3043783          	ld	a5,-464(s0)
    80005a4e:	c3b9                	beqz	a5,80005a94 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a50:	ffffb097          	auipc	ra,0xffffb
    80005a54:	096080e7          	jalr	150(ra) # 80000ae6 <kalloc>
    80005a58:	85aa                	mv	a1,a0
    80005a5a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a5e:	cd11                	beqz	a0,80005a7a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a60:	6605                	lui	a2,0x1
    80005a62:	e3043503          	ld	a0,-464(s0)
    80005a66:	ffffd097          	auipc	ra,0xffffd
    80005a6a:	0d2080e7          	jalr	210(ra) # 80002b38 <fetchstr>
    80005a6e:	00054663          	bltz	a0,80005a7a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005a72:	0905                	addi	s2,s2,1
    80005a74:	09a1                	addi	s3,s3,8
    80005a76:	fb491be3          	bne	s2,s4,80005a2c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a7a:	10048913          	addi	s2,s1,256
    80005a7e:	6088                	ld	a0,0(s1)
    80005a80:	c531                	beqz	a0,80005acc <sys_exec+0xf8>
    kfree(argv[i]);
    80005a82:	ffffb097          	auipc	ra,0xffffb
    80005a86:	f68080e7          	jalr	-152(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a8a:	04a1                	addi	s1,s1,8
    80005a8c:	ff2499e3          	bne	s1,s2,80005a7e <sys_exec+0xaa>
  return -1;
    80005a90:	557d                	li	a0,-1
    80005a92:	a835                	j	80005ace <sys_exec+0xfa>
      argv[i] = 0;
    80005a94:	0a8e                	slli	s5,s5,0x3
    80005a96:	fc040793          	addi	a5,s0,-64
    80005a9a:	9abe                	add	s5,s5,a5
    80005a9c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005aa0:	e4040593          	addi	a1,s0,-448
    80005aa4:	f4040513          	addi	a0,s0,-192
    80005aa8:	fffff097          	auipc	ra,0xfffff
    80005aac:	160080e7          	jalr	352(ra) # 80004c08 <exec>
    80005ab0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ab2:	10048993          	addi	s3,s1,256
    80005ab6:	6088                	ld	a0,0(s1)
    80005ab8:	c901                	beqz	a0,80005ac8 <sys_exec+0xf4>
    kfree(argv[i]);
    80005aba:	ffffb097          	auipc	ra,0xffffb
    80005abe:	f30080e7          	jalr	-208(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ac2:	04a1                	addi	s1,s1,8
    80005ac4:	ff3499e3          	bne	s1,s3,80005ab6 <sys_exec+0xe2>
  return ret;
    80005ac8:	854a                	mv	a0,s2
    80005aca:	a011                	j	80005ace <sys_exec+0xfa>
  return -1;
    80005acc:	557d                	li	a0,-1
}
    80005ace:	60be                	ld	ra,456(sp)
    80005ad0:	641e                	ld	s0,448(sp)
    80005ad2:	74fa                	ld	s1,440(sp)
    80005ad4:	795a                	ld	s2,432(sp)
    80005ad6:	79ba                	ld	s3,424(sp)
    80005ad8:	7a1a                	ld	s4,416(sp)
    80005ada:	6afa                	ld	s5,408(sp)
    80005adc:	6179                	addi	sp,sp,464
    80005ade:	8082                	ret

0000000080005ae0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ae0:	7139                	addi	sp,sp,-64
    80005ae2:	fc06                	sd	ra,56(sp)
    80005ae4:	f822                	sd	s0,48(sp)
    80005ae6:	f426                	sd	s1,40(sp)
    80005ae8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005aea:	ffffc097          	auipc	ra,0xffffc
    80005aee:	e96080e7          	jalr	-362(ra) # 80001980 <myproc>
    80005af2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005af4:	fd840593          	addi	a1,s0,-40
    80005af8:	4501                	li	a0,0
    80005afa:	ffffd097          	auipc	ra,0xffffd
    80005afe:	0aa080e7          	jalr	170(ra) # 80002ba4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b02:	fc840593          	addi	a1,s0,-56
    80005b06:	fd040513          	addi	a0,s0,-48
    80005b0a:	fffff097          	auipc	ra,0xfffff
    80005b0e:	db4080e7          	jalr	-588(ra) # 800048be <pipealloc>
    return -1;
    80005b12:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b14:	0c054463          	bltz	a0,80005bdc <sys_pipe+0xfc>
  fd0 = -1;
    80005b18:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b1c:	fd043503          	ld	a0,-48(s0)
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	51a080e7          	jalr	1306(ra) # 8000503a <fdalloc>
    80005b28:	fca42223          	sw	a0,-60(s0)
    80005b2c:	08054b63          	bltz	a0,80005bc2 <sys_pipe+0xe2>
    80005b30:	fc843503          	ld	a0,-56(s0)
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	506080e7          	jalr	1286(ra) # 8000503a <fdalloc>
    80005b3c:	fca42023          	sw	a0,-64(s0)
    80005b40:	06054863          	bltz	a0,80005bb0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b44:	4691                	li	a3,4
    80005b46:	fc440613          	addi	a2,s0,-60
    80005b4a:	fd843583          	ld	a1,-40(s0)
    80005b4e:	74a8                	ld	a0,104(s1)
    80005b50:	ffffc097          	auipc	ra,0xffffc
    80005b54:	b18080e7          	jalr	-1256(ra) # 80001668 <copyout>
    80005b58:	02054063          	bltz	a0,80005b78 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b5c:	4691                	li	a3,4
    80005b5e:	fc040613          	addi	a2,s0,-64
    80005b62:	fd843583          	ld	a1,-40(s0)
    80005b66:	0591                	addi	a1,a1,4
    80005b68:	74a8                	ld	a0,104(s1)
    80005b6a:	ffffc097          	auipc	ra,0xffffc
    80005b6e:	afe080e7          	jalr	-1282(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b72:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b74:	06055463          	bgez	a0,80005bdc <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b78:	fc442783          	lw	a5,-60(s0)
    80005b7c:	07f1                	addi	a5,a5,28
    80005b7e:	078e                	slli	a5,a5,0x3
    80005b80:	97a6                	add	a5,a5,s1
    80005b82:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b86:	fc042503          	lw	a0,-64(s0)
    80005b8a:	0571                	addi	a0,a0,28
    80005b8c:	050e                	slli	a0,a0,0x3
    80005b8e:	94aa                	add	s1,s1,a0
    80005b90:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b94:	fd043503          	ld	a0,-48(s0)
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	9f6080e7          	jalr	-1546(ra) # 8000458e <fileclose>
    fileclose(wf);
    80005ba0:	fc843503          	ld	a0,-56(s0)
    80005ba4:	fffff097          	auipc	ra,0xfffff
    80005ba8:	9ea080e7          	jalr	-1558(ra) # 8000458e <fileclose>
    return -1;
    80005bac:	57fd                	li	a5,-1
    80005bae:	a03d                	j	80005bdc <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005bb0:	fc442783          	lw	a5,-60(s0)
    80005bb4:	0007c763          	bltz	a5,80005bc2 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005bb8:	07f1                	addi	a5,a5,28
    80005bba:	078e                	slli	a5,a5,0x3
    80005bbc:	94be                	add	s1,s1,a5
    80005bbe:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005bc2:	fd043503          	ld	a0,-48(s0)
    80005bc6:	fffff097          	auipc	ra,0xfffff
    80005bca:	9c8080e7          	jalr	-1592(ra) # 8000458e <fileclose>
    fileclose(wf);
    80005bce:	fc843503          	ld	a0,-56(s0)
    80005bd2:	fffff097          	auipc	ra,0xfffff
    80005bd6:	9bc080e7          	jalr	-1604(ra) # 8000458e <fileclose>
    return -1;
    80005bda:	57fd                	li	a5,-1
}
    80005bdc:	853e                	mv	a0,a5
    80005bde:	70e2                	ld	ra,56(sp)
    80005be0:	7442                	ld	s0,48(sp)
    80005be2:	74a2                	ld	s1,40(sp)
    80005be4:	6121                	addi	sp,sp,64
    80005be6:	8082                	ret
	...

0000000080005bf0 <kernelvec>:
    80005bf0:	7111                	addi	sp,sp,-256
    80005bf2:	e006                	sd	ra,0(sp)
    80005bf4:	e40a                	sd	sp,8(sp)
    80005bf6:	e80e                	sd	gp,16(sp)
    80005bf8:	ec12                	sd	tp,24(sp)
    80005bfa:	f016                	sd	t0,32(sp)
    80005bfc:	f41a                	sd	t1,40(sp)
    80005bfe:	f81e                	sd	t2,48(sp)
    80005c00:	fc22                	sd	s0,56(sp)
    80005c02:	e0a6                	sd	s1,64(sp)
    80005c04:	e4aa                	sd	a0,72(sp)
    80005c06:	e8ae                	sd	a1,80(sp)
    80005c08:	ecb2                	sd	a2,88(sp)
    80005c0a:	f0b6                	sd	a3,96(sp)
    80005c0c:	f4ba                	sd	a4,104(sp)
    80005c0e:	f8be                	sd	a5,112(sp)
    80005c10:	fcc2                	sd	a6,120(sp)
    80005c12:	e146                	sd	a7,128(sp)
    80005c14:	e54a                	sd	s2,136(sp)
    80005c16:	e94e                	sd	s3,144(sp)
    80005c18:	ed52                	sd	s4,152(sp)
    80005c1a:	f156                	sd	s5,160(sp)
    80005c1c:	f55a                	sd	s6,168(sp)
    80005c1e:	f95e                	sd	s7,176(sp)
    80005c20:	fd62                	sd	s8,184(sp)
    80005c22:	e1e6                	sd	s9,192(sp)
    80005c24:	e5ea                	sd	s10,200(sp)
    80005c26:	e9ee                	sd	s11,208(sp)
    80005c28:	edf2                	sd	t3,216(sp)
    80005c2a:	f1f6                	sd	t4,224(sp)
    80005c2c:	f5fa                	sd	t5,232(sp)
    80005c2e:	f9fe                	sd	t6,240(sp)
    80005c30:	d83fc0ef          	jal	ra,800029b2 <kerneltrap>
    80005c34:	6082                	ld	ra,0(sp)
    80005c36:	6122                	ld	sp,8(sp)
    80005c38:	61c2                	ld	gp,16(sp)
    80005c3a:	7282                	ld	t0,32(sp)
    80005c3c:	7322                	ld	t1,40(sp)
    80005c3e:	73c2                	ld	t2,48(sp)
    80005c40:	7462                	ld	s0,56(sp)
    80005c42:	6486                	ld	s1,64(sp)
    80005c44:	6526                	ld	a0,72(sp)
    80005c46:	65c6                	ld	a1,80(sp)
    80005c48:	6666                	ld	a2,88(sp)
    80005c4a:	7686                	ld	a3,96(sp)
    80005c4c:	7726                	ld	a4,104(sp)
    80005c4e:	77c6                	ld	a5,112(sp)
    80005c50:	7866                	ld	a6,120(sp)
    80005c52:	688a                	ld	a7,128(sp)
    80005c54:	692a                	ld	s2,136(sp)
    80005c56:	69ca                	ld	s3,144(sp)
    80005c58:	6a6a                	ld	s4,152(sp)
    80005c5a:	7a8a                	ld	s5,160(sp)
    80005c5c:	7b2a                	ld	s6,168(sp)
    80005c5e:	7bca                	ld	s7,176(sp)
    80005c60:	7c6a                	ld	s8,184(sp)
    80005c62:	6c8e                	ld	s9,192(sp)
    80005c64:	6d2e                	ld	s10,200(sp)
    80005c66:	6dce                	ld	s11,208(sp)
    80005c68:	6e6e                	ld	t3,216(sp)
    80005c6a:	7e8e                	ld	t4,224(sp)
    80005c6c:	7f2e                	ld	t5,232(sp)
    80005c6e:	7fce                	ld	t6,240(sp)
    80005c70:	6111                	addi	sp,sp,256
    80005c72:	10200073          	sret
    80005c76:	00000013          	nop
    80005c7a:	00000013          	nop
    80005c7e:	0001                	nop

0000000080005c80 <timervec>:
    80005c80:	34051573          	csrrw	a0,mscratch,a0
    80005c84:	e10c                	sd	a1,0(a0)
    80005c86:	e510                	sd	a2,8(a0)
    80005c88:	e914                	sd	a3,16(a0)
    80005c8a:	6d0c                	ld	a1,24(a0)
    80005c8c:	7110                	ld	a2,32(a0)
    80005c8e:	6194                	ld	a3,0(a1)
    80005c90:	96b2                	add	a3,a3,a2
    80005c92:	e194                	sd	a3,0(a1)
    80005c94:	4589                	li	a1,2
    80005c96:	14459073          	csrw	sip,a1
    80005c9a:	6914                	ld	a3,16(a0)
    80005c9c:	6510                	ld	a2,8(a0)
    80005c9e:	610c                	ld	a1,0(a0)
    80005ca0:	34051573          	csrrw	a0,mscratch,a0
    80005ca4:	30200073          	mret
	...

0000000080005caa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005caa:	1141                	addi	sp,sp,-16
    80005cac:	e422                	sd	s0,8(sp)
    80005cae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005cb0:	0c0007b7          	lui	a5,0xc000
    80005cb4:	4705                	li	a4,1
    80005cb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005cb8:	c3d8                	sw	a4,4(a5)
}
    80005cba:	6422                	ld	s0,8(sp)
    80005cbc:	0141                	addi	sp,sp,16
    80005cbe:	8082                	ret

0000000080005cc0 <plicinithart>:

void
plicinithart(void)
{
    80005cc0:	1141                	addi	sp,sp,-16
    80005cc2:	e406                	sd	ra,8(sp)
    80005cc4:	e022                	sd	s0,0(sp)
    80005cc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cc8:	ffffc097          	auipc	ra,0xffffc
    80005ccc:	c8c080e7          	jalr	-884(ra) # 80001954 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cd0:	0085171b          	slliw	a4,a0,0x8
    80005cd4:	0c0027b7          	lui	a5,0xc002
    80005cd8:	97ba                	add	a5,a5,a4
    80005cda:	40200713          	li	a4,1026
    80005cde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ce2:	00d5151b          	slliw	a0,a0,0xd
    80005ce6:	0c2017b7          	lui	a5,0xc201
    80005cea:	953e                	add	a0,a0,a5
    80005cec:	00052023          	sw	zero,0(a0)
}
    80005cf0:	60a2                	ld	ra,8(sp)
    80005cf2:	6402                	ld	s0,0(sp)
    80005cf4:	0141                	addi	sp,sp,16
    80005cf6:	8082                	ret

0000000080005cf8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cf8:	1141                	addi	sp,sp,-16
    80005cfa:	e406                	sd	ra,8(sp)
    80005cfc:	e022                	sd	s0,0(sp)
    80005cfe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d00:	ffffc097          	auipc	ra,0xffffc
    80005d04:	c54080e7          	jalr	-940(ra) # 80001954 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d08:	00d5179b          	slliw	a5,a0,0xd
    80005d0c:	0c201537          	lui	a0,0xc201
    80005d10:	953e                	add	a0,a0,a5
  return irq;
}
    80005d12:	4148                	lw	a0,4(a0)
    80005d14:	60a2                	ld	ra,8(sp)
    80005d16:	6402                	ld	s0,0(sp)
    80005d18:	0141                	addi	sp,sp,16
    80005d1a:	8082                	ret

0000000080005d1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d1c:	1101                	addi	sp,sp,-32
    80005d1e:	ec06                	sd	ra,24(sp)
    80005d20:	e822                	sd	s0,16(sp)
    80005d22:	e426                	sd	s1,8(sp)
    80005d24:	1000                	addi	s0,sp,32
    80005d26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d28:	ffffc097          	auipc	ra,0xffffc
    80005d2c:	c2c080e7          	jalr	-980(ra) # 80001954 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d30:	00d5151b          	slliw	a0,a0,0xd
    80005d34:	0c2017b7          	lui	a5,0xc201
    80005d38:	97aa                	add	a5,a5,a0
    80005d3a:	c3c4                	sw	s1,4(a5)
}
    80005d3c:	60e2                	ld	ra,24(sp)
    80005d3e:	6442                	ld	s0,16(sp)
    80005d40:	64a2                	ld	s1,8(sp)
    80005d42:	6105                	addi	sp,sp,32
    80005d44:	8082                	ret

0000000080005d46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d46:	1141                	addi	sp,sp,-16
    80005d48:	e406                	sd	ra,8(sp)
    80005d4a:	e022                	sd	s0,0(sp)
    80005d4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d4e:	479d                	li	a5,7
    80005d50:	04a7cc63          	blt	a5,a0,80005da8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d54:	0001c797          	auipc	a5,0x1c
    80005d58:	2cc78793          	addi	a5,a5,716 # 80022020 <disk>
    80005d5c:	97aa                	add	a5,a5,a0
    80005d5e:	0187c783          	lbu	a5,24(a5)
    80005d62:	ebb9                	bnez	a5,80005db8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d64:	00451613          	slli	a2,a0,0x4
    80005d68:	0001c797          	auipc	a5,0x1c
    80005d6c:	2b878793          	addi	a5,a5,696 # 80022020 <disk>
    80005d70:	6394                	ld	a3,0(a5)
    80005d72:	96b2                	add	a3,a3,a2
    80005d74:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005d78:	6398                	ld	a4,0(a5)
    80005d7a:	9732                	add	a4,a4,a2
    80005d7c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d80:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d84:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d88:	953e                	add	a0,a0,a5
    80005d8a:	4785                	li	a5,1
    80005d8c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005d90:	0001c517          	auipc	a0,0x1c
    80005d94:	2a850513          	addi	a0,a0,680 # 80022038 <disk+0x18>
    80005d98:	ffffc097          	auipc	ra,0xffffc
    80005d9c:	306080e7          	jalr	774(ra) # 8000209e <wakeup>
}
    80005da0:	60a2                	ld	ra,8(sp)
    80005da2:	6402                	ld	s0,0(sp)
    80005da4:	0141                	addi	sp,sp,16
    80005da6:	8082                	ret
    panic("free_desc 1");
    80005da8:	00003517          	auipc	a0,0x3
    80005dac:	99850513          	addi	a0,a0,-1640 # 80008740 <syscalls+0x2f0>
    80005db0:	ffffa097          	auipc	ra,0xffffa
    80005db4:	78e080e7          	jalr	1934(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005db8:	00003517          	auipc	a0,0x3
    80005dbc:	99850513          	addi	a0,a0,-1640 # 80008750 <syscalls+0x300>
    80005dc0:	ffffa097          	auipc	ra,0xffffa
    80005dc4:	77e080e7          	jalr	1918(ra) # 8000053e <panic>

0000000080005dc8 <virtio_disk_init>:
{
    80005dc8:	1101                	addi	sp,sp,-32
    80005dca:	ec06                	sd	ra,24(sp)
    80005dcc:	e822                	sd	s0,16(sp)
    80005dce:	e426                	sd	s1,8(sp)
    80005dd0:	e04a                	sd	s2,0(sp)
    80005dd2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005dd4:	00003597          	auipc	a1,0x3
    80005dd8:	98c58593          	addi	a1,a1,-1652 # 80008760 <syscalls+0x310>
    80005ddc:	0001c517          	auipc	a0,0x1c
    80005de0:	36c50513          	addi	a0,a0,876 # 80022148 <disk+0x128>
    80005de4:	ffffb097          	auipc	ra,0xffffb
    80005de8:	d62080e7          	jalr	-670(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dec:	100017b7          	lui	a5,0x10001
    80005df0:	4398                	lw	a4,0(a5)
    80005df2:	2701                	sext.w	a4,a4
    80005df4:	747277b7          	lui	a5,0x74727
    80005df8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005dfc:	14f71c63          	bne	a4,a5,80005f54 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e00:	100017b7          	lui	a5,0x10001
    80005e04:	43dc                	lw	a5,4(a5)
    80005e06:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e08:	4709                	li	a4,2
    80005e0a:	14e79563          	bne	a5,a4,80005f54 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e0e:	100017b7          	lui	a5,0x10001
    80005e12:	479c                	lw	a5,8(a5)
    80005e14:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e16:	12e79f63          	bne	a5,a4,80005f54 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e1a:	100017b7          	lui	a5,0x10001
    80005e1e:	47d8                	lw	a4,12(a5)
    80005e20:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e22:	554d47b7          	lui	a5,0x554d4
    80005e26:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e2a:	12f71563          	bne	a4,a5,80005f54 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e2e:	100017b7          	lui	a5,0x10001
    80005e32:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e36:	4705                	li	a4,1
    80005e38:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e3a:	470d                	li	a4,3
    80005e3c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e3e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e40:	c7ffe737          	lui	a4,0xc7ffe
    80005e44:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc5ff>
    80005e48:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e4a:	2701                	sext.w	a4,a4
    80005e4c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e4e:	472d                	li	a4,11
    80005e50:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e52:	5bbc                	lw	a5,112(a5)
    80005e54:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e58:	8ba1                	andi	a5,a5,8
    80005e5a:	10078563          	beqz	a5,80005f64 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e5e:	100017b7          	lui	a5,0x10001
    80005e62:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e66:	43fc                	lw	a5,68(a5)
    80005e68:	2781                	sext.w	a5,a5
    80005e6a:	10079563          	bnez	a5,80005f74 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e6e:	100017b7          	lui	a5,0x10001
    80005e72:	5bdc                	lw	a5,52(a5)
    80005e74:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e76:	10078763          	beqz	a5,80005f84 <virtio_disk_init+0x1bc>
  if(max < NUM)
    80005e7a:	471d                	li	a4,7
    80005e7c:	10f77c63          	bgeu	a4,a5,80005f94 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80005e80:	ffffb097          	auipc	ra,0xffffb
    80005e84:	c66080e7          	jalr	-922(ra) # 80000ae6 <kalloc>
    80005e88:	0001c497          	auipc	s1,0x1c
    80005e8c:	19848493          	addi	s1,s1,408 # 80022020 <disk>
    80005e90:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e92:	ffffb097          	auipc	ra,0xffffb
    80005e96:	c54080e7          	jalr	-940(ra) # 80000ae6 <kalloc>
    80005e9a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e9c:	ffffb097          	auipc	ra,0xffffb
    80005ea0:	c4a080e7          	jalr	-950(ra) # 80000ae6 <kalloc>
    80005ea4:	87aa                	mv	a5,a0
    80005ea6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ea8:	6088                	ld	a0,0(s1)
    80005eaa:	cd6d                	beqz	a0,80005fa4 <virtio_disk_init+0x1dc>
    80005eac:	0001c717          	auipc	a4,0x1c
    80005eb0:	17c73703          	ld	a4,380(a4) # 80022028 <disk+0x8>
    80005eb4:	cb65                	beqz	a4,80005fa4 <virtio_disk_init+0x1dc>
    80005eb6:	c7fd                	beqz	a5,80005fa4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80005eb8:	6605                	lui	a2,0x1
    80005eba:	4581                	li	a1,0
    80005ebc:	ffffb097          	auipc	ra,0xffffb
    80005ec0:	e16080e7          	jalr	-490(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ec4:	0001c497          	auipc	s1,0x1c
    80005ec8:	15c48493          	addi	s1,s1,348 # 80022020 <disk>
    80005ecc:	6605                	lui	a2,0x1
    80005ece:	4581                	li	a1,0
    80005ed0:	6488                	ld	a0,8(s1)
    80005ed2:	ffffb097          	auipc	ra,0xffffb
    80005ed6:	e00080e7          	jalr	-512(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005eda:	6605                	lui	a2,0x1
    80005edc:	4581                	li	a1,0
    80005ede:	6888                	ld	a0,16(s1)
    80005ee0:	ffffb097          	auipc	ra,0xffffb
    80005ee4:	df2080e7          	jalr	-526(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ee8:	100017b7          	lui	a5,0x10001
    80005eec:	4721                	li	a4,8
    80005eee:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005ef0:	4098                	lw	a4,0(s1)
    80005ef2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005ef6:	40d8                	lw	a4,4(s1)
    80005ef8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005efc:	6498                	ld	a4,8(s1)
    80005efe:	0007069b          	sext.w	a3,a4
    80005f02:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f06:	9701                	srai	a4,a4,0x20
    80005f08:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f0c:	6898                	ld	a4,16(s1)
    80005f0e:	0007069b          	sext.w	a3,a4
    80005f12:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f16:	9701                	srai	a4,a4,0x20
    80005f18:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f1c:	4705                	li	a4,1
    80005f1e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f20:	00e48c23          	sb	a4,24(s1)
    80005f24:	00e48ca3          	sb	a4,25(s1)
    80005f28:	00e48d23          	sb	a4,26(s1)
    80005f2c:	00e48da3          	sb	a4,27(s1)
    80005f30:	00e48e23          	sb	a4,28(s1)
    80005f34:	00e48ea3          	sb	a4,29(s1)
    80005f38:	00e48f23          	sb	a4,30(s1)
    80005f3c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f40:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f44:	0727a823          	sw	s2,112(a5)
}
    80005f48:	60e2                	ld	ra,24(sp)
    80005f4a:	6442                	ld	s0,16(sp)
    80005f4c:	64a2                	ld	s1,8(sp)
    80005f4e:	6902                	ld	s2,0(sp)
    80005f50:	6105                	addi	sp,sp,32
    80005f52:	8082                	ret
    panic("could not find virtio disk");
    80005f54:	00003517          	auipc	a0,0x3
    80005f58:	81c50513          	addi	a0,a0,-2020 # 80008770 <syscalls+0x320>
    80005f5c:	ffffa097          	auipc	ra,0xffffa
    80005f60:	5e2080e7          	jalr	1506(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f64:	00003517          	auipc	a0,0x3
    80005f68:	82c50513          	addi	a0,a0,-2004 # 80008790 <syscalls+0x340>
    80005f6c:	ffffa097          	auipc	ra,0xffffa
    80005f70:	5d2080e7          	jalr	1490(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80005f74:	00003517          	auipc	a0,0x3
    80005f78:	83c50513          	addi	a0,a0,-1988 # 800087b0 <syscalls+0x360>
    80005f7c:	ffffa097          	auipc	ra,0xffffa
    80005f80:	5c2080e7          	jalr	1474(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80005f84:	00003517          	auipc	a0,0x3
    80005f88:	84c50513          	addi	a0,a0,-1972 # 800087d0 <syscalls+0x380>
    80005f8c:	ffffa097          	auipc	ra,0xffffa
    80005f90:	5b2080e7          	jalr	1458(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80005f94:	00003517          	auipc	a0,0x3
    80005f98:	85c50513          	addi	a0,a0,-1956 # 800087f0 <syscalls+0x3a0>
    80005f9c:	ffffa097          	auipc	ra,0xffffa
    80005fa0:	5a2080e7          	jalr	1442(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80005fa4:	00003517          	auipc	a0,0x3
    80005fa8:	86c50513          	addi	a0,a0,-1940 # 80008810 <syscalls+0x3c0>
    80005fac:	ffffa097          	auipc	ra,0xffffa
    80005fb0:	592080e7          	jalr	1426(ra) # 8000053e <panic>

0000000080005fb4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fb4:	7119                	addi	sp,sp,-128
    80005fb6:	fc86                	sd	ra,120(sp)
    80005fb8:	f8a2                	sd	s0,112(sp)
    80005fba:	f4a6                	sd	s1,104(sp)
    80005fbc:	f0ca                	sd	s2,96(sp)
    80005fbe:	ecce                	sd	s3,88(sp)
    80005fc0:	e8d2                	sd	s4,80(sp)
    80005fc2:	e4d6                	sd	s5,72(sp)
    80005fc4:	e0da                	sd	s6,64(sp)
    80005fc6:	fc5e                	sd	s7,56(sp)
    80005fc8:	f862                	sd	s8,48(sp)
    80005fca:	f466                	sd	s9,40(sp)
    80005fcc:	f06a                	sd	s10,32(sp)
    80005fce:	ec6e                	sd	s11,24(sp)
    80005fd0:	0100                	addi	s0,sp,128
    80005fd2:	8aaa                	mv	s5,a0
    80005fd4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fd6:	00c52d03          	lw	s10,12(a0)
    80005fda:	001d1d1b          	slliw	s10,s10,0x1
    80005fde:	1d02                	slli	s10,s10,0x20
    80005fe0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005fe4:	0001c517          	auipc	a0,0x1c
    80005fe8:	16450513          	addi	a0,a0,356 # 80022148 <disk+0x128>
    80005fec:	ffffb097          	auipc	ra,0xffffb
    80005ff0:	bea080e7          	jalr	-1046(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005ff4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005ff6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005ff8:	0001cb97          	auipc	s7,0x1c
    80005ffc:	028b8b93          	addi	s7,s7,40 # 80022020 <disk>
  for(int i = 0; i < 3; i++){
    80006000:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006002:	0001cc97          	auipc	s9,0x1c
    80006006:	146c8c93          	addi	s9,s9,326 # 80022148 <disk+0x128>
    8000600a:	a08d                	j	8000606c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000600c:	00fb8733          	add	a4,s7,a5
    80006010:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006014:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006016:	0207c563          	bltz	a5,80006040 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000601a:	2905                	addiw	s2,s2,1
    8000601c:	0611                	addi	a2,a2,4
    8000601e:	05690c63          	beq	s2,s6,80006076 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006022:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006024:	0001c717          	auipc	a4,0x1c
    80006028:	ffc70713          	addi	a4,a4,-4 # 80022020 <disk>
    8000602c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000602e:	01874683          	lbu	a3,24(a4)
    80006032:	fee9                	bnez	a3,8000600c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006034:	2785                	addiw	a5,a5,1
    80006036:	0705                	addi	a4,a4,1
    80006038:	fe979be3          	bne	a5,s1,8000602e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000603c:	57fd                	li	a5,-1
    8000603e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006040:	01205d63          	blez	s2,8000605a <virtio_disk_rw+0xa6>
    80006044:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006046:	000a2503          	lw	a0,0(s4)
    8000604a:	00000097          	auipc	ra,0x0
    8000604e:	cfc080e7          	jalr	-772(ra) # 80005d46 <free_desc>
      for(int j = 0; j < i; j++)
    80006052:	2d85                	addiw	s11,s11,1
    80006054:	0a11                	addi	s4,s4,4
    80006056:	ffb918e3          	bne	s2,s11,80006046 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000605a:	85e6                	mv	a1,s9
    8000605c:	0001c517          	auipc	a0,0x1c
    80006060:	fdc50513          	addi	a0,a0,-36 # 80022038 <disk+0x18>
    80006064:	ffffc097          	auipc	ra,0xffffc
    80006068:	fd6080e7          	jalr	-42(ra) # 8000203a <sleep>
  for(int i = 0; i < 3; i++){
    8000606c:	f8040a13          	addi	s4,s0,-128
{
    80006070:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006072:	894e                	mv	s2,s3
    80006074:	b77d                	j	80006022 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006076:	f8042583          	lw	a1,-128(s0)
    8000607a:	00a58793          	addi	a5,a1,10
    8000607e:	0792                	slli	a5,a5,0x4

  if(write)
    80006080:	0001c617          	auipc	a2,0x1c
    80006084:	fa060613          	addi	a2,a2,-96 # 80022020 <disk>
    80006088:	00f60733          	add	a4,a2,a5
    8000608c:	018036b3          	snez	a3,s8
    80006090:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006092:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006096:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000609a:	f6078693          	addi	a3,a5,-160
    8000609e:	6218                	ld	a4,0(a2)
    800060a0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060a2:	00878513          	addi	a0,a5,8
    800060a6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060a8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060aa:	6208                	ld	a0,0(a2)
    800060ac:	96aa                	add	a3,a3,a0
    800060ae:	4741                	li	a4,16
    800060b0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060b2:	4705                	li	a4,1
    800060b4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800060b8:	f8442703          	lw	a4,-124(s0)
    800060bc:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060c0:	0712                	slli	a4,a4,0x4
    800060c2:	953a                	add	a0,a0,a4
    800060c4:	058a8693          	addi	a3,s5,88
    800060c8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800060ca:	6208                	ld	a0,0(a2)
    800060cc:	972a                	add	a4,a4,a0
    800060ce:	40000693          	li	a3,1024
    800060d2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800060d4:	001c3c13          	seqz	s8,s8
    800060d8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060da:	001c6c13          	ori	s8,s8,1
    800060de:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800060e2:	f8842603          	lw	a2,-120(s0)
    800060e6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060ea:	0001c697          	auipc	a3,0x1c
    800060ee:	f3668693          	addi	a3,a3,-202 # 80022020 <disk>
    800060f2:	00258713          	addi	a4,a1,2
    800060f6:	0712                	slli	a4,a4,0x4
    800060f8:	9736                	add	a4,a4,a3
    800060fa:	587d                	li	a6,-1
    800060fc:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006100:	0612                	slli	a2,a2,0x4
    80006102:	9532                	add	a0,a0,a2
    80006104:	f9078793          	addi	a5,a5,-112
    80006108:	97b6                	add	a5,a5,a3
    8000610a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000610c:	629c                	ld	a5,0(a3)
    8000610e:	97b2                	add	a5,a5,a2
    80006110:	4605                	li	a2,1
    80006112:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006114:	4509                	li	a0,2
    80006116:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000611a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000611e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006122:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006126:	6698                	ld	a4,8(a3)
    80006128:	00275783          	lhu	a5,2(a4)
    8000612c:	8b9d                	andi	a5,a5,7
    8000612e:	0786                	slli	a5,a5,0x1
    80006130:	97ba                	add	a5,a5,a4
    80006132:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006136:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000613a:	6698                	ld	a4,8(a3)
    8000613c:	00275783          	lhu	a5,2(a4)
    80006140:	2785                	addiw	a5,a5,1
    80006142:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006146:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000614a:	100017b7          	lui	a5,0x10001
    8000614e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006152:	004aa783          	lw	a5,4(s5)
    80006156:	02c79163          	bne	a5,a2,80006178 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000615a:	0001c917          	auipc	s2,0x1c
    8000615e:	fee90913          	addi	s2,s2,-18 # 80022148 <disk+0x128>
  while(b->disk == 1) {
    80006162:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006164:	85ca                	mv	a1,s2
    80006166:	8556                	mv	a0,s5
    80006168:	ffffc097          	auipc	ra,0xffffc
    8000616c:	ed2080e7          	jalr	-302(ra) # 8000203a <sleep>
  while(b->disk == 1) {
    80006170:	004aa783          	lw	a5,4(s5)
    80006174:	fe9788e3          	beq	a5,s1,80006164 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006178:	f8042903          	lw	s2,-128(s0)
    8000617c:	00290793          	addi	a5,s2,2
    80006180:	00479713          	slli	a4,a5,0x4
    80006184:	0001c797          	auipc	a5,0x1c
    80006188:	e9c78793          	addi	a5,a5,-356 # 80022020 <disk>
    8000618c:	97ba                	add	a5,a5,a4
    8000618e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006192:	0001c997          	auipc	s3,0x1c
    80006196:	e8e98993          	addi	s3,s3,-370 # 80022020 <disk>
    8000619a:	00491713          	slli	a4,s2,0x4
    8000619e:	0009b783          	ld	a5,0(s3)
    800061a2:	97ba                	add	a5,a5,a4
    800061a4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061a8:	854a                	mv	a0,s2
    800061aa:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061ae:	00000097          	auipc	ra,0x0
    800061b2:	b98080e7          	jalr	-1128(ra) # 80005d46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061b6:	8885                	andi	s1,s1,1
    800061b8:	f0ed                	bnez	s1,8000619a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061ba:	0001c517          	auipc	a0,0x1c
    800061be:	f8e50513          	addi	a0,a0,-114 # 80022148 <disk+0x128>
    800061c2:	ffffb097          	auipc	ra,0xffffb
    800061c6:	ac8080e7          	jalr	-1336(ra) # 80000c8a <release>
}
    800061ca:	70e6                	ld	ra,120(sp)
    800061cc:	7446                	ld	s0,112(sp)
    800061ce:	74a6                	ld	s1,104(sp)
    800061d0:	7906                	ld	s2,96(sp)
    800061d2:	69e6                	ld	s3,88(sp)
    800061d4:	6a46                	ld	s4,80(sp)
    800061d6:	6aa6                	ld	s5,72(sp)
    800061d8:	6b06                	ld	s6,64(sp)
    800061da:	7be2                	ld	s7,56(sp)
    800061dc:	7c42                	ld	s8,48(sp)
    800061de:	7ca2                	ld	s9,40(sp)
    800061e0:	7d02                	ld	s10,32(sp)
    800061e2:	6de2                	ld	s11,24(sp)
    800061e4:	6109                	addi	sp,sp,128
    800061e6:	8082                	ret

00000000800061e8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061e8:	1101                	addi	sp,sp,-32
    800061ea:	ec06                	sd	ra,24(sp)
    800061ec:	e822                	sd	s0,16(sp)
    800061ee:	e426                	sd	s1,8(sp)
    800061f0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061f2:	0001c497          	auipc	s1,0x1c
    800061f6:	e2e48493          	addi	s1,s1,-466 # 80022020 <disk>
    800061fa:	0001c517          	auipc	a0,0x1c
    800061fe:	f4e50513          	addi	a0,a0,-178 # 80022148 <disk+0x128>
    80006202:	ffffb097          	auipc	ra,0xffffb
    80006206:	9d4080e7          	jalr	-1580(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000620a:	10001737          	lui	a4,0x10001
    8000620e:	533c                	lw	a5,96(a4)
    80006210:	8b8d                	andi	a5,a5,3
    80006212:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006214:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006218:	689c                	ld	a5,16(s1)
    8000621a:	0204d703          	lhu	a4,32(s1)
    8000621e:	0027d783          	lhu	a5,2(a5)
    80006222:	04f70863          	beq	a4,a5,80006272 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006226:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000622a:	6898                	ld	a4,16(s1)
    8000622c:	0204d783          	lhu	a5,32(s1)
    80006230:	8b9d                	andi	a5,a5,7
    80006232:	078e                	slli	a5,a5,0x3
    80006234:	97ba                	add	a5,a5,a4
    80006236:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006238:	00278713          	addi	a4,a5,2
    8000623c:	0712                	slli	a4,a4,0x4
    8000623e:	9726                	add	a4,a4,s1
    80006240:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006244:	e721                	bnez	a4,8000628c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006246:	0789                	addi	a5,a5,2
    80006248:	0792                	slli	a5,a5,0x4
    8000624a:	97a6                	add	a5,a5,s1
    8000624c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000624e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006252:	ffffc097          	auipc	ra,0xffffc
    80006256:	e4c080e7          	jalr	-436(ra) # 8000209e <wakeup>

    disk.used_idx += 1;
    8000625a:	0204d783          	lhu	a5,32(s1)
    8000625e:	2785                	addiw	a5,a5,1
    80006260:	17c2                	slli	a5,a5,0x30
    80006262:	93c1                	srli	a5,a5,0x30
    80006264:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006268:	6898                	ld	a4,16(s1)
    8000626a:	00275703          	lhu	a4,2(a4)
    8000626e:	faf71ce3          	bne	a4,a5,80006226 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006272:	0001c517          	auipc	a0,0x1c
    80006276:	ed650513          	addi	a0,a0,-298 # 80022148 <disk+0x128>
    8000627a:	ffffb097          	auipc	ra,0xffffb
    8000627e:	a10080e7          	jalr	-1520(ra) # 80000c8a <release>
}
    80006282:	60e2                	ld	ra,24(sp)
    80006284:	6442                	ld	s0,16(sp)
    80006286:	64a2                	ld	s1,8(sp)
    80006288:	6105                	addi	sp,sp,32
    8000628a:	8082                	ret
      panic("virtio_disk_intr status");
    8000628c:	00002517          	auipc	a0,0x2
    80006290:	59c50513          	addi	a0,a0,1436 # 80008828 <syscalls+0x3d8>
    80006294:	ffffa097          	auipc	ra,0xffffa
    80006298:	2aa080e7          	jalr	682(ra) # 8000053e <panic>
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
